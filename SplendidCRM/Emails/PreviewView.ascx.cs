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
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Emails
{
	/// <summary>
	/// Summary description for PreviewView.
	/// </summary>
	public class PreviewView : SplendidControl
	{
		protected _controls.ModuleHeader   ctlModuleHeader  ;
		protected _controls.DynamicButtons ctlDynamicButtons;
		protected _controls.DynamicButtons ctlFooterButtons ;

		protected Guid        gID              ;
		protected HtmlTable   tblMain          ;
		protected PlaceHolder plcSubPanel      ;
		protected Repeater    ctlAttachments   ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Forward" )
				{
					Response.Redirect("edit.aspx?type=forward&DuplicateID=" + gID.ToString());
				}
				else if ( e.CommandName == "Reply" )
				{
					Response.Redirect("edit.aspx?type=reply&DuplicateID=" + gID.ToString());
				}
				else if ( e.CommandName == "Reply All" )
				{
					Response.Redirect("edit.aspx?type=replyall&DuplicateID=" + gID.ToString());
				}
				else if ( e.CommandName == "Delete" )
				{
					SqlProcs.spEMAILS_Delete(gID);
					Response.Redirect("default.aspx");
				}
				else if ( e.CommandName == "Save" )
				{
					string[] arrID = Request.Form.GetValues("chkMain");
					if ( arrID != null )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									foreach ( string sID_MODULE in arrID )
									{
										string[] arrID_MODULE = sID_MODULE.Split('|');
										if ( arrID_MODULE.Length == 2 )
										{
											Guid   gPARENT_ID   = Sql.ToGuid(arrID_MODULE[0]);
											string sPARENT_TYPE = arrID_MODULE[1];
											SqlProcs.spEMAILS_RELATED_Update(gID, sPARENT_TYPE, gPARENT_ID, trn);
										}
									}
									trn.Commit();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									throw(new Exception(ex.Message, ex.InnerException));
								}
							}
						}
						Response.Redirect("view.aspx?ID=" + gID.ToString());
					}
				}
				else if ( e.CommandName == "Cancel" )
				{
					// 06/15/2017 Paul.  Add support for HTML5 Home Page. 
					Response.Redirect(Sql.ToString(Application["Modules.Home.RelativePath"]));
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "view") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				gID = Sql.ToGuid(Request["ID"]);
				if ( !Sql.IsEmptyGuid(gID) )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						string sSQL ;
						sSQL = "select *            " + ControlChars.CrLf
						     + "  from vwEMAILS_Edit" + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Security.Filter(cmd, m_sMODULE, "view");
							Sql.AppendParameter(cmd, gID, "ID", false);
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
										ctlModuleHeader.Title = Sql.ToString(rdr["NAME"]);
										SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlModuleHeader.Title);
										Utils.UpdateTracker(Page, m_sMODULE, gID, ctlModuleHeader.Title);
										
										this.AppendDetailViewFields(m_sMODULE + ".DetailView", tblMain, rdr);
										string sDESCRIPTION_HTML = Sql.ToString(rdr["DESCRIPTION_HTML"]);
										if ( !Sql.IsEmptyString(sDESCRIPTION_HTML) )
											new DynamicControl(this, "DESCRIPTION").Text = sDESCRIPTION_HTML;

										StringBuilder sbUnifiedSearch = new StringBuilder();
										string sFROM_ADDR = Sql.ToString(rdr["FROM_ADDR"]);
										string sFROM_NAME = Sql.ToString(rdr["FROM_NAME"]);
										sbUnifiedSearch.Append(sFROM_ADDR);
										if ( sFROM_ADDR.Contains("@") )
											sbUnifiedSearch.Append(" or *@" + sFROM_ADDR.Split('@')[1]);
										// 11/05/2010 Paul.  We need to remove the Email Address from the FROM_NAME. 
										if ( sFROM_NAME.IndexOf('<') >= 0 )
											sFROM_NAME = sFROM_NAME.Substring(0, sFROM_NAME.IndexOf('<'));
										sFROM_NAME = sFROM_NAME.Replace("\"", String.Empty).Trim();
										if ( !Sql.IsEmptyString(sFROM_NAME) && sFROM_NAME != sFROM_ADDR )
											sbUnifiedSearch.Append(" or \"" + sFROM_NAME + "\"");
										Page.Items["txtUnifiedSearch"] = sbUnifiedSearch.ToString();
										
										string sEMAIL_TYPE = Sql.ToString(rdr["TYPE"]).ToLower();
										ctlModuleHeader.EnableModuleLabel = false;
										switch ( sEMAIL_TYPE )
										{
											case "archived":
												ctlModuleHeader.Title = L10n.Term("Emails.LBL_ARCHIVED_MODULE_NAME") + ":" + ctlModuleHeader.Title;
												break;
											case "inbound":
												ctlModuleHeader.Title = L10n.Term("Emails.LBL_INBOUND_TITLE") + ":" + ctlModuleHeader.Title;
												break;
											case "out":
												ctlModuleHeader.Title = L10n.Term("Emails.LBL_LIST_FORM_SENT_TITLE") + ":" + ctlModuleHeader.Title;
												break;
											case "sent":
												ctlModuleHeader.Title = L10n.Term("Emails.LBL_LIST_FORM_SENT_TITLE") + ":" + ctlModuleHeader.Title;
												break;
											case "campaign":
												ctlModuleHeader.Title = L10n.Term("Emails.LBL_LIST_FORM_SENT_TITLE") + ":" + ctlModuleHeader.Title;
												break;
											default:
												sEMAIL_TYPE = "draft";
												ctlModuleHeader.Title = L10n.Term("Emails.LBL_COMPOSE_MODULE_NAME" ) + ":" + ctlModuleHeader.Title;
												// 01/21/2006 Paul.  Draft messages go directly to edit mode. 
												Response.Redirect("edit.aspx?ID=" + gID.ToString());
												break;
										}
										Guid gASSIGNED_USER_ID = Sql.ToGuid(rdr["ASSIGNED_USER_ID"]);
										Page.Items["ASSIGNED_USER_ID"] = gASSIGNED_USER_ID;
										ctlDynamicButtons.AppendButtons(m_sMODULE + ".PreviewView", gASSIGNED_USER_ID, rdr);
										ctlFooterButtons .AppendButtons(m_sMODULE + ".PreviewView", gASSIGNED_USER_ID, rdr);
									}
									else
									{
										plcSubPanel.Visible = false;
										ctlDynamicButtons.DisableAll();
										ctlFooterButtons .DisableAll();
										ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
									}
								}
							}
						}
						sSQL = "select *                   " + ControlChars.CrLf
						     + "  from vwEMAILS_Attachments" + ControlChars.CrLf
						     + " where EMAIL_ID = @EMAIL_ID" + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@EMAIL_ID", gID);

							if ( bDebug )
								RegisterClientScriptBlock("vwEMAILS_Attachments", Sql.ClientScriptBlock(cmd));

							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									ctlAttachments.DataSource = dt.DefaultView;
									ctlAttachments.DataBind();
								}
							}
						}
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
			this.Load                 += new System.EventHandler(this.Page_Load);
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			ctlFooterButtons .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Emails";
			SetMenu(m_sMODULE);
			this.AppendDetailViewRelationships("Home.UnifiedSearch", plcSubPanel);
			if ( IsPostBack )
			{
				// 02/13/2013 Paul.  DetailView should be rebuilt on postback. 
				this.AppendDetailViewFields(m_sMODULE + ".DetailView", tblMain, null);
				ctlDynamicButtons.AppendButtons(m_sMODULE + ".PreviewView", Guid.Empty, Guid.Empty);
				ctlFooterButtons .AppendButtons(m_sMODULE + ".PreviewView", Guid.Empty, Guid.Empty);
			}
		}
		#endregion
	}
}

