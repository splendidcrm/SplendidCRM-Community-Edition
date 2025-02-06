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

namespace SplendidCRM.Administration.Shortcuts
{
	/// <summary>
	/// Summary description for Export.
	/// </summary>
	public class Export : System.Web.UI.Page
	{
		private void Page_Load(object sender, System.EventArgs e)
		{
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			// 08/15/2017 Paul.  Correct to allow admin delegates. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess("Shortcuts", "export") >= 0);
			if ( !this.Visible )
				return;
			
			string sNAME = Sql.ToString(Request["NAME"]);
			if ( !Sql.IsEmptyString(sNAME) )
			{
				StringBuilder sb = new StringBuilder();
				// 03/15/2018 Paul.  Mark record as deleted instead of deleting. 
				//sb.AppendLine("delete from SHORTCUTS where MODULE_NAME = '" + sNAME + "';");
				sb.AppendLine("update SHORTCUTS set DELETED = 1, DATE_MODIFIED_UTC = getutcdate(), MODIFIED_USER_ID = null where DELETED = 0 and MODULE_NAME = '" + sNAME + "';");
				
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select *                         " + ControlChars.CrLf
					     + "  from vwSHORTCUTS               " + ControlChars.CrLf
					     + " where MODULE_NAME = @MODULE_NAME" + ControlChars.CrLf
					     + " order by SHORTCUT_ORDER         " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@MODULE_NAME", sNAME);
					
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dtFields = new DataTable() )
							{
								da.Fill(dtFields);
								if ( dtFields.Rows.Count > 0 )
								{
									int nSHORTCUT_ORDER_Length   = 2;
									int nDISPLAY_NAME_Length     = 4;
									int nRELATIVE_PATH_Length    = 4;
									int nIMAGE_NAME_Length       = 4;
									int nSHORTCUT_MODULE_Length  = 4;
									int nSHORTCUT_ACLTYPE_Length = 4;
									foreach(DataRow row in dtFields.Rows)
									{
										nSHORTCUT_ORDER_Length   = Math.Max(nSHORTCUT_ORDER_Length  , Sql.EscapeSQL(Sql.ToString(row["SHORTCUT_ORDER"  ])).Length);
										nDISPLAY_NAME_Length     = Math.Max(nDISPLAY_NAME_Length    , Sql.EscapeSQL(Sql.ToString(row["DISPLAY_NAME"    ])).Length + 2);
										nRELATIVE_PATH_Length    = Math.Max(nRELATIVE_PATH_Length   , Sql.EscapeSQL(Sql.ToString(row["RELATIVE_PATH"   ])).Length + 2);
										nIMAGE_NAME_Length       = Math.Max(nIMAGE_NAME_Length      , Sql.EscapeSQL(Sql.ToString(row["IMAGE_NAME"      ])).Length + 2);
										nSHORTCUT_MODULE_Length  = Math.Max(nSHORTCUT_MODULE_Length , Sql.EscapeSQL(Sql.ToString(row["SHORTCUT_MODULE" ])).Length + 2);
										nSHORTCUT_ACLTYPE_Length = Math.Max(nSHORTCUT_ACLTYPE_Length, Sql.EscapeSQL(Sql.ToString(row["SHORTCUT_ACLTYPE"])).Length + 2);
									}

									sb.AppendLine("if not exists(select * from SHORTCUTS where MODULE_NAME = '" + sNAME + "' and DELETED = 0) begin -- then");
									sb.AppendLine("	print 'SHORTCUTS " + sNAME + "';");

									foreach(DataRow row in dtFields.Rows)
									{
										string sMODULE_NAME      = Sql.ToString (row["MODULE_NAME"     ]);
										string sDISPLAY_NAME     = Sql.ToString (row["DISPLAY_NAME"    ]);
										string sRELATIVE_PATH    = Sql.ToString (row["RELATIVE_PATH"   ]);
										string sIMAGE_NAME       = Sql.ToString (row["IMAGE_NAME"      ]);
										int    nSHORTCUT_ENABLED = Sql.ToInteger(row["SHORTCUT_ENABLED"]);
										string sSHORTCUT_ORDER   = Sql.ToString (row["SHORTCUT_ORDER"  ]);
										string sSHORTCUT_MODULE  = Sql.ToString (row["SHORTCUT_MODULE" ]);
										string sSHORTCUT_ACLTYPE = Sql.ToString (row["SHORTCUT_ACLTYPE"]);
										
										sSHORTCUT_ORDER = Strings.Space(nSHORTCUT_ORDER_Length - sSHORTCUT_ORDER.Length) + sSHORTCUT_ORDER;
										sb.AppendLine("	exec dbo.spSHORTCUTS_InsertOnly null, '" + sMODULE_NAME + "', " + Sql.FormatSQL(sDISPLAY_NAME, nDISPLAY_NAME_Length) + ", " + Sql.FormatSQL(sRELATIVE_PATH, nRELATIVE_PATH_Length) + ", " + Sql.FormatSQL(sIMAGE_NAME, nIMAGE_NAME_Length) + ", " + nSHORTCUT_ENABLED.ToString() + ", " + sSHORTCUT_ORDER + ", " + Sql.FormatSQL(sSHORTCUT_MODULE, nSHORTCUT_MODULE_Length) + ", " + Sql.FormatSQL(sSHORTCUT_ACLTYPE, nSHORTCUT_ACLTYPE_Length) + ";");
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
				// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
				// 02/16/2010 Paul.  Must include all parts of the name in the encoding. 
				Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(Request.Browser, "SHORTCUTS " + sNAME + ".1.sql"));
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

