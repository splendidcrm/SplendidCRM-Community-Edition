/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved."
 *********************************************************************************************************************/
using System;
using System.Data;
using System.Data.Common;
using System.Collections;
using System.Text;
using System.IO;
using System.Diagnostics;

namespace SplendidCRM.Administration.EditCustomFields
{
	/// <summary>
	/// Summary description for Export.
	/// </summary>
	public class Export : System.Web.UI.Page
	{
		private void Page_Load(object sender, System.EventArgs e)
		{
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.GetUserAccess("EditCustomFields", "export") >= 0);
			if ( !this.Visible )
				return;
			
			string sMODULE_NAME = Sql.ToString(Request["MODULE_NAME"]);
			if ( !Sql.IsEmptyString(sMODULE_NAME) )
			{
				StringBuilder sb = new StringBuilder();
				
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select *                             " + ControlChars.CrLf
					     + "  from vwFIELDS_META_DATA            " + ControlChars.CrLf
					     + " where CUSTOM_MODULE = @CUSTOM_MODULE" + ControlChars.CrLf
					     + " order by NAME                       " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@CUSTOM_MODULE", sMODULE_NAME);
					
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dtFields = new DataTable() )
							{
								da.Fill(dtFields);
								if ( dtFields.Rows.Count > 0 )
								{
									int nNAME_Length            = 2;
									int nLABEL_Length           = 2;
									int nCUSTOM_MODULE_Length   = 2;
									int nDATA_TYPE_Length       = 2;
									int nREQUIRED_OPTION_Length = 2;
									int nDEFAULT_VALUE_Length   = 2;
									int nEXT1_Length            = 2;
									foreach(DataRow row in dtFields.Rows)
									{
										nNAME_Length            = Math.Max(nNAME_Length           , Sql.EscapeSQL(Sql.ToString(row["NAME"           ])).Length);
										nLABEL_Length           = Math.Max(nLABEL_Length          , Sql.EscapeSQL(Sql.ToString(row["LABEL"          ])).Length + 2);
										nCUSTOM_MODULE_Length   = Math.Max(nCUSTOM_MODULE_Length  , Sql.EscapeSQL(Sql.ToString(row["CUSTOM_MODULE"  ])).Length + 2);
										nDATA_TYPE_Length       = Math.Max(nDATA_TYPE_Length      , Sql.EscapeSQL(Sql.ToString(row["DATA_TYPE"      ])).Length + 2);
										nREQUIRED_OPTION_Length = Math.Max(nREQUIRED_OPTION_Length, Sql.EscapeSQL(Sql.ToString(row["REQUIRED_OPTION"])).Length + 2);
										nDEFAULT_VALUE_Length   = Math.Max(nDEFAULT_VALUE_Length  , Sql.EscapeSQL(Sql.ToString(row["DEFAULT_VALUE"  ])).Length + 2);
										nEXT1_Length            = Math.Max(nEXT1_Length           , Sql.EscapeSQL(Sql.ToString(row["EXT1"           ])).Length + 2);
									}
									foreach(DataRow row in dtFields.Rows)
									{
										Guid   gID              = Sql.ToGuid   (row["ID"             ]);
										string sNAME            = Sql.ToString (row["NAME"           ]);
										string sLABEL           = Sql.ToString (row["LABEL"          ]);
										string sCUSTOM_MODULE   = Sql.ToString (row["CUSTOM_MODULE"  ]);
										string sDATA_TYPE       = Sql.ToString (row["DATA_TYPE"      ]);
										int    nMAX_SIZE        = Sql.ToInteger(row["MAX_SIZE"       ]);
										string sREQUIRED_OPTION = Sql.ToString (row["REQUIRED_OPTION"]);
										string sDEFAULT_VALUE   = Sql.ToString (row["DEFAULT_VALUE"  ]);
										string sEXT1            = Sql.ToString (row["EXT1"           ]);
										bool   bMASS_UPDATE     = Sql.ToBoolean(row["MASS_UPDATE"    ]);
										bool   bAUDITED         = Sql.ToBoolean(row["AUDITED"        ]);
										bool   bREQUIRED        = sREQUIRED_OPTION != "optional";
										string sFIELD_NAME      = sNAME.ToUpper();
										if ( sFIELD_NAME.EndsWith("_C") )
											sFIELD_NAME = sFIELD_NAME.Substring(0, sFIELD_NAME.Length - 2);
										// 04/10/2014 Paul.  We need to filter on the custom table, not the module name. 
										string sCUSTOM_TABLE    = Crm.Modules.TableName(sCUSTOM_MODULE) + "_CSTM";
										sb.AppendLine("if not exists (select * from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME = '" + sCUSTOM_TABLE + "' and COLUMN_NAME = '" + sNAME + "') begin -- then");
										sb.AppendLine("	print 'Adding " + sCUSTOM_TABLE + "." + sNAME + "';");
										sb.Append("	exec dbo.spFIELDS_META_DATA_Insert");
										sb.Append("  null"                                                   );  // ID
										sb.Append(", null"                                                   );  // MODIFIED_USER_ID
										sb.Append(", " + Sql.FormatSQL(sFIELD_NAME   , nNAME_Length - 2     ));  // NAME
										sb.Append(", " + Sql.FormatSQL(sLABEL        , nLABEL_Length        ));  // LABEL
										sb.Append(", " + Sql.FormatSQL(sFIELD_NAME   , nNAME_Length - 2     ));  // LABEL_TERM
										sb.Append(", " + Sql.FormatSQL(sCUSTOM_MODULE, nCUSTOM_MODULE_Length));  // CUSTOM_MODULE
										sb.Append(", " + Sql.FormatSQL(sDATA_TYPE    , nDATA_TYPE_Length    ));  // DATA_TYPE
										sb.Append(", " + (nMAX_SIZE > 0 ? nMAX_SIZE.ToString() : "null")     );  // MAX_SIZE
										sb.Append(", " + (bREQUIRED     ? "1" : "0")                         );  // REQUIRED
										sb.Append(", " + (bAUDITED      ? "1" : "0")                         );  // AUDITED
										sb.Append(", " + Sql.FormatSQL(sDEFAULT_VALUE, nDEFAULT_VALUE_Length));  // DEFAULT_VALUE
										sb.Append(", " + Sql.FormatSQL(sEXT1         , nEXT1_Length         ));  // DROPDOWN_LIST
										sb.Append(", " + (bMASS_UPDATE  ? "1" : "0")                         );  // MASS_UPDATE
										// 03/11/2016 Paul.  Allow disable recompile so that we can do in the background. 
										sb.Append(", false"                                                  );  // DISABLE_RECOMPILE
										sb.AppendLine(";");
										sb.AppendLine("end -- if;");
									}
								}
							}
						}
					}
				}
				sb.AppendLine("GO");
				sb.AppendLine("");
				// 08/17/2024 Paul.  The correct MIME type is text/plain. 
				Response.ContentType = "text/plain";
				string sTABLE_NAME = Crm.Modules.TableName(sMODULE_NAME);
				Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(Request.Browser, sTABLE_NAME + ".2.sql"));
				Response.Write(sb.ToString());
			}
		}

		#region Web Form Designer generated code
		override protected void OnInit(EventArgs e)
		{
			//
			// CODEGEN: This call is required by the ASP.NET Web Form Designer.
			//
			InitializeComponent();
			base.OnInit(e);
		}
		
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);
		}
		#endregion
	}
}

