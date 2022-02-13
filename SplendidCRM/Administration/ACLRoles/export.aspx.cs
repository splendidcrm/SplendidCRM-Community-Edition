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

namespace SplendidCRM.Administration.ACLRoles
{
	/// <summary>
	/// Summary description for Export.
	/// </summary>
	public class Export : System.Web.UI.Page
	{
		private void Page_Load(object sender, System.EventArgs e)
		{
			this.Visible = (SplendidCRM.Security.AdminUserAccess("ACLRoles", "export") >= 0);
			if ( !this.Visible )
				return;
			
			Guid gID = Sql.ToGuid(Request["ID"]);
			if ( !Sql.IsEmptyString(gID) )
			{
				string sNAME        = String.Empty;
				string sDESCRIPTION = String.Empty;
				StringBuilder sb = new StringBuilder();
				sb.AppendLine("if not exists(select * from ACL_ROLES where ID = '" + gID.ToString() + "') begin -- then");
				
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select *               " + ControlChars.CrLf
					     + "  from vwACL_ROLES_Edit" + ControlChars.CrLf
					     + " where ID = @ID        " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@ID", gID);
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dtCurrent = new DataTable() )
							{
								da.Fill(dtCurrent);
								if ( dtCurrent.Rows.Count > 0 )
								{
									DataRow rdr = dtCurrent.Rows[0];
									sNAME        = Sql.ToString(rdr["NAME"       ]);
									sDESCRIPTION = Sql.ToString(rdr["DESCRIPTION"]);
									sb.AppendLine("	exec dbo.spACL_ROLES_Update '" + gID.ToString() + "', null, " + Sql.FormatSQL(sNAME, 0) + ", " + Sql.FormatSQL(sDESCRIPTION, 0) + ";");
								}
							}
						}
					}
					
					// 09/26/2017 Paul.  Add Archive access right. 
					sSQL = "select MODULE_NAME          " + ControlChars.CrLf
					     + "     , DISPLAY_NAME         " + ControlChars.CrLf
					     + "     , ACLACCESS_ADMIN      " + ControlChars.CrLf
					     + "     , ACLACCESS_ACCESS     " + ControlChars.CrLf
					     + "     , ACLACCESS_VIEW       " + ControlChars.CrLf
					     + "     , ACLACCESS_LIST       " + ControlChars.CrLf
					     + "     , ACLACCESS_EDIT       " + ControlChars.CrLf
					     + "     , ACLACCESS_DELETE     " + ControlChars.CrLf
					     + "     , ACLACCESS_IMPORT     " + ControlChars.CrLf
					     + "     , ACLACCESS_EXPORT     " + ControlChars.CrLf
					     + "     , ACLACCESS_ARCHIVE    " + ControlChars.CrLf
					     + "     , IS_ADMIN             " + ControlChars.CrLf
					     + "  from vwACL_ACCESS_ByRole  " + ControlChars.CrLf
					     + " where ROLE_ID = @ROLE_ID   " + ControlChars.CrLf
					     + " order by IS_ADMIN, MODULE_NAME" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@ROLE_ID", gID);
					
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dtFields = new DataTable() )
							{
								da.Fill(dtFields);
								if ( dtFields.Rows.Count > 0 )
								{
									foreach(DataRow row in dtFields.Rows)
									{
										string sMODULE_NAME      = Sql.ToString (row["MODULE_NAME"       ]);
										int    nACLACCESS_ACCESS = Sql.ToInteger(row["ACLACCESS_ACCESS"  ]);
										int    nACLACCESS_VIEW   = Sql.ToInteger(row["ACLACCESS_VIEW"    ]);
										int    nACLACCESS_LIST   = Sql.ToInteger(row["ACLACCESS_LIST"    ]);
										int    nACLACCESS_EDIT   = Sql.ToInteger(row["ACLACCESS_EDIT"    ]);
										int    nACLACCESS_DELETE = Sql.ToInteger(row["ACLACCESS_DELETE"  ]);
										int    nACLACCESS_IMPORT = Sql.ToInteger(row["ACLACCESS_IMPORT"  ]);
										int    nACLACCESS_EXPORT = Sql.ToInteger(row["ACLACCESS_EXPORT"  ]);
										int    nACLACCESS_ARCHIVE= Sql.ToInteger(row["ACLACCESS_ARCHIVE" ]);
										
										sb.AppendLine("	exec dbo.spACL_ROLES_ACTIONS_Update null, null, '" + gID.ToString() + "', 'access', " + Sql.FormatSQL(sMODULE_NAME, 0) + ", " + nACLACCESS_ACCESS.ToString() + ";");
										sb.AppendLine("	exec dbo.spACL_ROLES_ACTIONS_Update null, null, '" + gID.ToString() + "', 'view'  , " + Sql.FormatSQL(sMODULE_NAME, 0) + ", " + nACLACCESS_VIEW  .ToString() + ";");
										sb.AppendLine("	exec dbo.spACL_ROLES_ACTIONS_Update null, null, '" + gID.ToString() + "', 'list'  , " + Sql.FormatSQL(sMODULE_NAME, 0) + ", " + nACLACCESS_LIST  .ToString() + ";");
										sb.AppendLine("	exec dbo.spACL_ROLES_ACTIONS_Update null, null, '" + gID.ToString() + "', 'edit'  , " + Sql.FormatSQL(sMODULE_NAME, 0) + ", " + nACLACCESS_EDIT  .ToString() + ";");
										sb.AppendLine("	exec dbo.spACL_ROLES_ACTIONS_Update null, null, '" + gID.ToString() + "', 'delete', " + Sql.FormatSQL(sMODULE_NAME, 0) + ", " + nACLACCESS_DELETE.ToString() + ";");
										sb.AppendLine("	exec dbo.spACL_ROLES_ACTIONS_Update null, null, '" + gID.ToString() + "', 'import', " + Sql.FormatSQL(sMODULE_NAME, 0) + ", " + nACLACCESS_IMPORT.ToString() + ";");
										sb.AppendLine("	exec dbo.spACL_ROLES_ACTIONS_Update null, null, '" + gID.ToString() + "', 'export', " + Sql.FormatSQL(sMODULE_NAME, 0) + ", " + nACLACCESS_EXPORT.ToString() + ";");
										// 09/26/2017 Paul.  Add Archive access right. 
										sb.AppendLine("	exec dbo.spACL_ROLES_ACTIONS_Update null, null, '" + gID.ToString() + "', 'archive', " + Sql.FormatSQL(sMODULE_NAME, 0) + ", " + nACLACCESS_ARCHIVE.ToString() + ";");
									}
								}
							}
						}
					}
				}
				sb.AppendLine("end -- if;");
				sb.AppendLine("GO");
				sb.AppendLine("");
				Response.ContentType = "text/txt";
				// 12/17/2017 Paul.  File extension will use 3 so that it is after ACL_ACTIONS_Initialize. 
				Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(Request.Browser, "ACL_ROLES " + sNAME + ".3.sql"));
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

