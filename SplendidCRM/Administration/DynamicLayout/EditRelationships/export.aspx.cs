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

namespace SplendidCRM.Administration.DynamicLayout.EditRelationships
{
	/// <summary>
	/// Summary description for Export.
	/// </summary>
	public class Export : System.Web.UI.Page
	{
		private void Page_Load(object sender, System.EventArgs e)
		{
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.GetUserAccess("DynamicLayout", "export") >= 0);
			if ( !this.Visible )
				return;
			
			string sNAME = Sql.ToString(Request["NAME"]);
			if ( !Sql.IsEmptyString(sNAME) )
			{
				StringBuilder sb = new StringBuilder();
				// 08/17/2024 Paul.  Mark record as deleted instead of deleting. 
				//sb.AppendLine("delete from EDITVIEWS_RELATIONSHIPS where EDIT_NAME = '" + sNAME + "';");
				sb.AppendLine("update EDITVIEWS_RELATIONSHIPS set DELETED = 1, DATE_MODIFIED_UTC = getutcdate(), MODIFIED_USER_ID = null where DELETED = 0 and EDIT_NAME = '" + sNAME + "';");
				
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select *                          " + ControlChars.CrLf
					     + "  from vwEDITVIEWS_RELATIONSHIPS  " + ControlChars.CrLf
					     + " where EDIT_NAME  = @EDIT_NAME    " + ControlChars.CrLf
					     + " order by RELATIONSHIP_ORDER      " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@EDIT_NAME", sNAME);
					
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dtFields = new DataTable() )
							{
								da.Fill(dtFields);
								if ( dtFields.Rows.Count > 0 )
								{
									int nRELATIONSHIP_ORDER_Length = 2;
									int nEDIT_NAME_Length          = 4;
									int nMODULE_NAME_Length        = 4;
									int nCONTROL_NAME_Length       = 4;
									int nTITLE_Length              = 4;
									int nALTERNATE_VIEW_Length     = 4;
									foreach(DataRow row in dtFields.Rows)
									{
										nRELATIONSHIP_ORDER_Length = Math.Max(nRELATIONSHIP_ORDER_Length, Sql.EscapeSQL(Sql.ToString(row["RELATIONSHIP_ORDER"     ])).Length);
										nEDIT_NAME_Length          = Math.Max(nEDIT_NAME_Length         , Sql.EscapeSQL(Sql.ToString(row["EDIT_NAME"              ])).Length + 2);
										nMODULE_NAME_Length        = Math.Max(nMODULE_NAME_Length       , Sql.EscapeSQL(Sql.ToString(row["MODULE_NAME"            ])).Length + 2);
										nCONTROL_NAME_Length       = Math.Max(nCONTROL_NAME_Length      , Sql.EscapeSQL(Sql.ToString(row["CONTROL_NAME"           ])).Length + 2);
										nTITLE_Length              = Math.Max(nTITLE_Length             , Sql.EscapeSQL(Sql.ToString(row["TITLE"                  ])).Length + 2);
										nALTERNATE_VIEW_Length     = Math.Max(nALTERNATE_VIEW_Length    , Sql.EscapeSQL(Sql.ToString(row["ALTERNATE_VIEW"         ])).Length + 2);
									}

									sb.AppendLine("if not exists(select * from EDITVIEWS_RELATIONSHIPS where EDIT_NAME = '" + sNAME + "' and DELETED = 0) begin -- then");
									sb.AppendLine("	print 'EDITVIEWS_RELATIONSHIPS " + sNAME + "';");

									for ( int nRELATIONSHIP_ORDER = 0; nRELATIONSHIP_ORDER < dtFields.Rows.Count; nRELATIONSHIP_ORDER++ )
									{
										DataRow row = dtFields.Rows[nRELATIONSHIP_ORDER];
										string sEDIT_NAME               = Sql.ToString(row["EDIT_NAME"              ]);
										string sMODULE_NAME             = Sql.ToString(row["MODULE_NAME"            ]);
										string sCONTROL_NAME            = Sql.ToString(row["CONTROL_NAME"           ]);
										string sRELATIONSHIP_ENABLED    = Sql.ToString(row["RELATIONSHIP_ENABLED"   ]);
										string sRELATIONSHIP_ORDER      = Sql.ToString(row["RELATIONSHIP_ORDER"     ]);
										string sNEW_RECORD_ENABLED      = Sql.ToString(row["NEW_RECORD_ENABLED"     ]);
										string sEXISTING_RECORD_ENABLED = Sql.ToString(row["EXISTING_RECORD_ENABLED"]);
										string sTITLE                   = Sql.ToString(row["TITLE"                  ]);
										string sALTERNATE_VIEW          = Sql.ToString(row["ALTERNATE_VIEW"         ]);

										// 08/17/2024 Paul.  Renumber to prevent gaps. 
										sRELATIONSHIP_ORDER = nRELATIONSHIP_ORDER.ToString();
										sRELATIONSHIP_ORDER = Strings.Space(nRELATIONSHIP_ORDER_Length - sRELATIONSHIP_ORDER.Length) + sRELATIONSHIP_ORDER;
										sb.AppendLine("	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly "
											+ Sql.FormatSQL(sEDIT_NAME              , nEDIT_NAME_Length     ) + ", "
											+ Sql.FormatSQL(sMODULE_NAME            , nMODULE_NAME_Length   ) + ", "
											+ Sql.FormatSQL(sCONTROL_NAME           , nCONTROL_NAME_Length  ) + ", "
											+               sRELATIONSHIP_ENABLED                             + ", "
											+               sRELATIONSHIP_ORDER                               + ", "
											+               sNEW_RECORD_ENABLED                               + ", "
											+               sEXISTING_RECORD_ENABLED                          + ", "
											+ Sql.FormatSQL(sTITLE                  , nTITLE_Length         ) + ", "
											+ Sql.FormatSQL(sALTERNATE_VIEW         , nALTERNATE_VIEW_Length)
											+ ";");
									}
									sb.AppendLine("end -- if;");
								}
							}
						}
					}
				}
				sb.AppendLine("GO");
				sb.AppendLine("");
				// 08/17/2024 Paul.  The correct MIME type is text/plain. 
				Response.ContentType = "text/plain";
				// 08/17/2024 Paul.  Use our own encoding so that a space does not get converted to a +. 
				// 08/17/2024 Paul.  Must include all parts of the name in the encoding. 
				Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(Request.Browser, "EDITVIEWS_RELATIONSHIPS " + sNAME + ".1.sql"));
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

