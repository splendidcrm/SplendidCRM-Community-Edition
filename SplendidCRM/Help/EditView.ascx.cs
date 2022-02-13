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
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
using CKEditor.NET;

namespace SplendidCRM.Help
{
	/// <summary>
	///		Summary description for EditView.
	/// </summary>
	public class EditView : SplendidControl
	{
		protected _controls.DynamicButtons ctlDynamicButtons;
		// 01/13/2010 Paul.  Add footer buttons. 
		protected _controls.DynamicButtons ctlFooterButtons ;

		protected Guid            gID                          ;
		protected string          sNAME                        ;
		protected string          sMODULE                      ;
		// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
		protected CKEditorControl txtDISPLAY_TEXT              ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Save" )
			{
				if ( Page.IsValid )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
						using ( IDbTransaction trn = Sql.BeginTransaction(con) )
						{
							try
							{
								SqlProcs.spTERMINOLOGY_HELP_Update(ref gID, sNAME, L10n.NAME, sMODULE, txtDISPLAY_TEXT.Text);
								trn.Commit();
							}
							catch(Exception ex)
							{
								trn.Rollback();
								SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
								ctlDynamicButtons.ErrorText = ex.Message;
								return;
							}
						}
					}
					Response.Redirect("view.aspx?NAME=" + sNAME + "&MODULE=" + sMODULE);
				}
			}
			else if ( e.CommandName == "Cancel" )
			{
				Response.Redirect("view.aspx?NAME=" + sNAME + "&MODULE=" + sMODULE);
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			Utils.SetPageTitle(Page, L10n.Term(".moduleList." + m_sMODULE));
			// 10/25/2006 Paul.  There is a config flag to disable the wiki entirely. 
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "edit") >= 0) && Sql.ToBoolean(Application["CONFIG.enable_help_wiki"]);
			if ( !this.Visible )
				return;

			try
			{
				gID     = Sql.ToGuid  (Request["ID"    ]);
				sNAME   = Sql.ToString(Request["NAME"  ]);
				sMODULE = Sql.ToString(Request["MODULE"]);
				if ( !Sql.IsEmptyGuid(gID) )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						string sSQL ;
						sSQL = "select *                 " + ControlChars.CrLf
						     + "  from vwTERMINOLOGY_HELP" + ControlChars.CrLf
						     + " where ID = @ID          " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@ID", gID);
							con.Open();

							if ( bDebug )
								RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

							// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dtCurrent = new DataTable() )
								{
									da.Fill(dtCurrent);
									if ( dtCurrent.Rows.Count > 0 )
									{
										DataRow rdr = dtCurrent.Rows[0];
										sNAME   = Sql.ToString(rdr["NAME"       ]);
										sMODULE = Sql.ToString(rdr["MODULE_NAME"]);
										Utils.SetPageTitle(Page, L10n.Term(".moduleList." + sMODULE) + " - " + L10n.Term(".LNK_HELP"));

										if ( !IsPostBack )
										{
											txtDISPLAY_TEXT.Text = Sql.ToString(rdr["DISPLAY_TEXT"]);
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											// 06/24/2008 Paul.  Help text does not have an assigned user id. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, rdr);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, rdr);
										}
									}
								}
							}
						}
					}
				}
				else
				{
					if ( !IsPostBack )
					{
						// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		#region Web Form Designer generated code
		override protected void OnInit(EventArgs e)
		{
			//
			// CODEGEN: This Task is required by the ASP.NET Web Form Designer.
			//
			InitializeComponent();
			base.OnInit(e);
		}
		
		/// <summary>
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			ctlFooterButtons .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Help";
			if ( IsPostBack )
			{
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
			}
		}
		#endregion
	}
}

