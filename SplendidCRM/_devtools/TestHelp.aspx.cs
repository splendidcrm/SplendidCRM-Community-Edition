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
using System.Text;
using System.Data;
using System.Data.Common;
using System.Collections;
using System.Web.UI.WebControls;
using System.Diagnostics;

namespace SplendidCRM._devtools
{
	/// <summary>
	/// Summary description for TestHelp.
	/// </summary>
	public class TestHelp : SplendidPage
	{
		protected DataTable dtMain    ;
		protected Label     lblCurrent;
		protected Label     lblStatus ;
		protected Label     lblErrors ;
		protected ListBox   lstFiles  ;
		protected DataGrid  grdMain   ;
		protected StringBuilder sbHelpScripts;

		void Page_Load(object sender, System.EventArgs e)
		{
			// 01/11/2006 Paul.  Only a developer/administrator should see this. 
			if ( !(SplendidCRM.Security.AdminUserAccess("Administration", "access") >= 0) )
				return;

			try
			{
				sbHelpScripts = new StringBuilder();
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					sSQL = "select vwTERMINOLOGY_HELP.NAME                                    " + ControlChars.CrLf
					     + "     , vwTERMINOLOGY_HELP.MODULE_NAME                             " + ControlChars.CrLf
					     + "     , vwTERMINOLOGY_HELP.DISPLAY_TEXT                            " + ControlChars.CrLf
					     + "     , vwMODULES.IS_ADMIN                                         " + ControlChars.CrLf
					     + "  from vwTERMINOLOGY_HELP                                         " + ControlChars.CrLf
					     + " inner join vwMODULES                                             " + ControlChars.CrLf
					     + "         on vwMODULES.MODULE_NAME = vwTERMINOLOGY_HELP.MODULE_NAME" + ControlChars.CrLf
					     + " where vwTERMINOLOGY_HELP.LANG    = @LANG                         " + ControlChars.CrLf
					     + " order by vwMODULES.IS_ADMIN asc, vwTERMINOLOGY_HELP.MODULE_NAME, vwTERMINOLOGY_HELP.NAME asc" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@LANG", L10n.NAME);
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								//dt.Columns.Add("HELP_SCRIPT");
								foreach ( DataRow row in dt.Rows )
								{
									row["NAME"] = Sql.ToString(row["MODULE_NAME"]) + "." + Sql.ToString(row["NAME"]);
									string sDISPLAY_TEXT = Sql.ToString(row["DISPLAY_TEXT"]);
									int nStartScript = sDISPLAY_TEXT.IndexOf("<script type=\"text/javascript\">");
									if ( nStartScript >= 0 )
									{
										string sEndScript = "</script>";
										int nEndScript = sDISPLAY_TEXT.IndexOf(sEndScript, nStartScript);
										if ( nEndScript >= 0 )
										{
											string sHELP_SCRIPT  = sDISPLAY_TEXT.Substring(nStartScript, nEndScript + sEndScript.Length - nStartScript);
											//row["HELP_SCRIPT"] = sHELP_SCRIPT;
											sbHelpScripts.Append(sHELP_SCRIPT);
										}
									}
								}
								dt.AcceptChanges();
								
								DataView vwMain = new DataView(dt);
								vwMain.Sort = "IS_ADMIN asc, NAME asc";
								lstFiles.DataSource = vwMain;
								lstFiles.DataBind();
								//grdMain.DataSource = vwMain;
								//grdMain.DataBind();
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				lblStatus.Text = ex.Message;
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
