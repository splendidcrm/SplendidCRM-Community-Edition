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
using System.Collections.Generic;
using System.Diagnostics;

namespace SplendidCRM.Administration.InboundEmail
{
	/// <summary>
	/// Summary description for DetailView.
	/// </summary>
	public class DetailView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons ctlDynamicButtons;

		// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
		//private const string sEMPTY_PASSWORD = "**********";
		protected Guid        gID              ;
		protected HtmlTable   tblMain          ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Edit" )
				{
					Response.Redirect("edit.aspx?ID=" + gID.ToString());
				}
				else if ( e.CommandName == "Duplicate" )
				{
					Response.Redirect("edit.aspx?DuplicateID=" + gID.ToString());
				}
				else if ( e.CommandName == "Delete" )
				{
					SqlProcs.spINBOUND_EMAILS_Delete(gID);
					Response.Redirect("default.aspx");
				}
				else if ( e.CommandName == "Test" )
				{
					Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
					Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
					string sEMAIL_PASSWORD = Sql.ToString(ViewState["smtppass"]);
					if ( !Sql.IsEmptyString(sEMAIL_PASSWORD) )
						sEMAIL_PASSWORD = Security.DecryptPassword(sEMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
					
					// 01/28/2017 Paul.  Use ViewState so that we get original values. 
					string sSERVICE     = Sql.ToString (ViewState["SERVICE"    ]);
					string sSERVER_URL  = Sql.ToString (ViewState["SERVER_URL" ]);
					int    nPORT        = Sql.ToInteger(ViewState["PORT"       ]);
					bool   bMAILBOX_SSL = Sql.ToBoolean(ViewState["MAILBOX_SSL"]);
					string sEMAIL_USER  = Sql.ToString (ViewState["EMAIL_USER" ]);
					string sMAILBOX     = Sql.ToString (ViewState["MAILBOX"    ]);
					StringBuilder sbErrors = new StringBuilder();
					if ( String.Compare(sSERVICE, "pop3", true) == 0 )
					{
						PopUtils.Validate(Context, sSERVER_URL, nPORT, bMAILBOX_SSL, sEMAIL_USER, sEMAIL_PASSWORD, sbErrors);
						ctlDynamicButtons.ErrorText = sbErrors.ToString();
					}
					else if ( String.Compare(sSERVICE, "imap", true) == 0 )
					{
						ImapUtils.Validate(Context, sSERVER_URL, nPORT, bMAILBOX_SSL, sEMAIL_USER, sEMAIL_PASSWORD, sMAILBOX, sbErrors);
						ctlDynamicButtons.ErrorText = sbErrors.ToString();
					}
					// 01/16/2017 Paul.  Add support for Office 365 OAuth. 
					else if ( String.Compare(sSERVICE, "GoogleApps", true) == 0 )
					{
						SplendidCRM.GoogleApps.TestMailbox(Application, gID, sMAILBOX, sbErrors);
						ctlDynamicButtons.ErrorText = sbErrors.ToString();
					}
					else if ( String.Compare(sSERVICE, "Office365", true) == 0 )
					{
						string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
						string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
						// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
						string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
						// 12/13/2020 Paul.  Move Office365 methods to Office365utils. 
						Office365Utils.ValidateExchange(Application, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, gID, sMAILBOX, sbErrors);
						ctlDynamicButtons.ErrorText = sbErrors.ToString();
					}
					// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
					else if ( String.Compare(sSERVICE, "Exchange-Password", true) == 0 )
					{
						string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sEMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
						string sIMPERSONATED_TYPE        = Sql.ToString (Application["CONFIG.Exchange.ImpersonatedType" ]);
						sSERVER_URL = Sql.ToString (Application["CONFIG.Exchange.ServerURL"]);
						// 12/13/2017 Paul.  Allow version to be changed. 
						string sEXCHANGE_VERSION = Sql.ToString(Application["CONFIG.Exchange.Version"]);
						ExchangeUtils.ValidateExchange(Application, sSERVER_URL, sEMAIL_USER, sENCRYPTED_EMAIL_PASSWORD, true, sIMPERSONATED_TYPE, sEXCHANGE_VERSION, sbErrors);
						ctlDynamicButtons.ErrorText = sbErrors.ToString();
					}
					else
					{
						throw(new Exception("Unknown/unsupported mail service: " + sSERVICE));
					}
				}
				// 07/18/2023 Paul.  Provide a way to archive imported messages. 
				else if ( e.CommandName == "Archive" )
				{
					string sSERVICE     = Sql.ToString (ViewState["SERVICE"    ]);
					string sMAILBOX     = Sql.ToString (ViewState["MAILBOX"    ]);
					bool bOFFICE365_OAUTH_ENABLED  = Sql.ToBoolean(ViewState["OFFICE365_OAUTH_ENABLED" ]);
					if ( String.Compare(sSERVICE, "Office365", true) == 0 )
					{
						Spring.Social.Office365.Office365Sync.UserSync User = new Spring.Social.Office365.Office365Sync.UserSync(Context, String.Empty, String.Empty, String.Empty, String.Empty, gID, false, bOFFICE365_OAUTH_ENABLED);
						string sFOLDER_ID = Office365Utils.GetFolderId(Context, String.Empty, String.Empty, gID, sMAILBOX);
						if ( Sql.IsEmptyString(sFOLDER_ID) )
							throw(new Exception("Could not find folder " + sMAILBOX));
						
						string sOAUTH_CLIENT_ID     = Sql.ToString (User.Context.Application["CONFIG.Exchange.ClientID"         ]);
						string sOAUTH_CLIENT_SECRET = Sql.ToString (User.Context.Application["CONFIG.Exchange.ClientSecret"     ]);
						string sOAuthDirectoryTenatID = Sql.ToString(User.Context.Application["CONFIG.Exchange.DirectoryTenantID"]);
						Office365AccessToken token = ActiveDirectory.Office365RefreshAccessToken(User.Context.Application, sOAuthDirectoryTenatID, sOAUTH_CLIENT_ID, sOAUTH_CLIENT_SECRET, User.USER_ID, false);
						Spring.Social.Office365.Api.IOffice365 service = Spring.Social.Office365.Office365Sync.CreateApi(User.Context.Application, token.access_token);
						
						string sARCHIVE_FOLDER_ID   = String.Empty;
						string sARCHIVE_FOLDER_NAME = Sql.ToString (User.Context.Application["CONFIG.Exchange.ArchiveFolderName"]);
						if ( Sql.IsEmptyString(sARCHIVE_FOLDER_NAME) )
							sARCHIVE_FOLDER_NAME = "Archive";
						IList<Spring.Social.Office365.Api.MailFolder> fResults = service.FolderOperations.GetChildFolders(sFOLDER_ID, sARCHIVE_FOLDER_NAME);
						if ( fResults.Count > 0 )
						{
							sARCHIVE_FOLDER_ID = fResults[0].Id;
						}
						else
						{
							Debug.WriteLine("Archive:  Creating Archive folder: " + sARCHIVE_FOLDER_NAME);
							Spring.Social.Office365.Api.MailFolder fldArchive = service.FolderOperations.Insert(sFOLDER_ID, sARCHIVE_FOLDER_NAME);
							sARCHIVE_FOLDER_ID = fldArchive.Id;
						}
						Debug.WriteLine("Archive:  Archive Folder ID: " + sARCHIVE_FOLDER_ID);

						int nPageSize   = 200;
						int nPageOffset = 0;
						string sort = "lastModifiedDateTime desc";
						Spring.Social.Office365.Api.MessagePagination results = service.FolderOperations.GetMessageIds(sFOLDER_ID, sort, nPageOffset, nPageSize);
						if ( results != null )
						{
							Debug.WriteLine("Archive:  Message Count " + results.count.ToString());
							DbProviderFactory dbf = DbProviderFactories.GetFactory();
							using ( IDbConnection con = dbf.CreateConnection() )
							{
								con.Open();
								using ( IDbCommand cmdExistingEmails = con.CreateCommand() )
								{
									String sSQL;
									sSQL = "select count(*)                " + ControlChars.CrLf
									     + "  from vwEMAILS_Inbound        " + ControlChars.CrLf
									     + " where MESSAGE_ID = @MESSAGE_ID" + ControlChars.CrLf;
									cmdExistingEmails.CommandText = sSQL;
									cmdExistingEmails.CommandTimeout = 0;
									IDbDataParameter parMESSAGE_ID = Sql.AddParameter(cmdExistingEmails, "@MESSAGE_ID", String.Empty, 851);
									
									for ( int i = 0; i < results.messages.Count; i++ )
									{
										Spring.Social.Office365.Api.Message msg = results.messages[i];
										parMESSAGE_ID.Value = msg.Id;
										if ( Sql.ToInteger(cmdExistingEmails.ExecuteScalar()) > 0 )
										{
											Debug.WriteLine((i + 1).ToString() + ".  Archiving  " + msg.Id + " " + (msg.LastModifiedDateTime.HasValue ? msg.LastModifiedDateTime.ToString() : ""));
											//service.MailOperations.Move(msg.Id, sARCHIVE_FOLDER_ID);
										}
										else
										{
											Debug.WriteLine((i + 1).ToString() + ".  Not Found  " + msg.Id + " " + (msg.LastModifiedDateTime.HasValue ? msg.LastModifiedDateTime.ToString() : ""));
										}
									}
								}
							}
						}
					}
					else
					{
						throw(new Exception("Archive not supported with this email service"));
					}
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
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "view") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			try
			{
				gID = Sql.ToGuid(Request["ID"]);
				// 11/28/2005 Paul.  We must always populate the table, otherwise it will disappear during event processing. 
				// 03/19/2008 Paul.  Place AppendDetailViewFields inside OnInit to avoid having to re-populate the data. 
				if ( !IsPostBack )
				{
					if ( !Sql.IsEmptyGuid(gID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							sSQL = "select *                    " + ControlChars.CrLf
							     + "  from vwINBOUND_EMAILS_Edit" + ControlChars.CrLf
							     + " where ID = @ID             " + ControlChars.CrLf;
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
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											
											this.AppendDetailViewFields(m_sMODULE + "." + LayoutDetailView, tblMain, rdr);
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, rdr);
											string sEMAIL_PASSWORD = Sql.ToString(rdr["EMAIL_PASSWORD"]);
											if ( !Sql.IsEmptyString(sEMAIL_PASSWORD) )
											{
												ViewState["smtppass"] = sEMAIL_PASSWORD;
											}
											// 01/28/2017 Paul.  Use ViewState so that we get original values. 
											ViewState["SERVICE"    ] = Sql.ToString (rdr["SERVICE"    ]);
											ViewState["SERVER_URL" ] = Sql.ToString (rdr["SERVER_URL" ]);
											ViewState["PORT"       ] = Sql.ToInteger(rdr["PORT"       ]);
											ViewState["MAILBOX_SSL"] = Sql.ToBoolean(rdr["MAILBOX_SSL"]);
											ViewState["EMAIL_USER" ] = Sql.ToString (rdr["EMAIL_USER" ]);
											ViewState["MAILBOX"    ] = Sql.ToString (rdr["MAILBOX"    ]);
										}
										else
										{
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
										}
									}
								}
							}
						}
					}
					else
					{
						// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
						ctlDynamicButtons.DisableAll();
						//ctlDynamicButtons.ErrorText = L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + "ID";
					}
				}
				// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
				//Page.DataBind();
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
			this.Load += new System.EventHandler(this.Page_Load);
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "InboundEmail";
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				this.AppendDetailViewFields(m_sMODULE + "." + LayoutDetailView, tblMain, null);
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
			}
		}
		#endregion
	}
}

