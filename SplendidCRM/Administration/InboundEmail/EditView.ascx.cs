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
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Administration.InboundEmail
{
	/// <summary>
	///		Summary description for EditView.
	/// </summary>
	public class EditView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		// 01/13/2010 Paul.  Add footer buttons. 
		protected _controls.DynamicButtons ctlFooterButtons ;

		// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
		//private const string sEMPTY_PASSWORD = "**********";
		protected Guid            gID                             ;
		protected HtmlTable       tblMain                         ;
		protected HtmlTable       tblOptions                      ;
		protected HtmlTable       tblSmtp                         ;
		// 01/26/2017 Paul.  Add support for Office 365 OAuth. 
		protected HiddenField     NEW_ID                          ;
		protected TextBox         OAUTH_ACCESS_TOKEN              ;
		protected TextBox         OAUTH_REFRESH_TOKEN             ;
		protected TextBox         OAUTH_EXPIRES_IN                ;
		protected TextBox         OAUTH_CODE                      ;
		protected Table           tblSmtpPanel                    ;
		protected Table           tblOffice365Panel               ;
		protected HtmlTable       tblOffice365Options             ;
		protected Button          btnOffice365Authorize           ;
		protected Button          btnOffice365Delete              ;
		protected Button          btnOffice365Test                ;
		protected Button          btnOffice365Authorized          ;
		protected Button          btnOffice365RefreshToken        ;
		protected Label           lblOffice365Authorized          ;
		protected Label           lblOffice365AuthorizedStatus    ;
		protected Table           tblGoogleAppsPanel              ;
		protected HtmlTable       tblGoogleAppsOptions            ;
		protected Button          btnGoogleAppsAuthorize          ;
		protected Button          btnGoogleAppsDelete             ;
		protected Button          btnGoogleAppsTest               ;
		protected Button          btnGoogleAuthorized             ;
		protected Button          btnGoogleAppsRefreshToken       ;
		protected Label           lblGoogleAppsAuthorized         ;
		protected Label           lblGoogleAuthorizedStatus       ;


		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			// 03/15/2014 Paul.  Enable override of concurrency error. 
			if ( e.CommandName == "Save" || e.CommandName == "SaveConcurrency" )
			{
				try
				{
					// 01/16/2006 Paul.  Enable validator before validating page. 
					this.ValidateEditViewFields(m_sMODULE + "." + LayoutEditView   );
					this.ValidateEditViewFields(m_sMODULE + ".EditOptions");
					// 01/26/2017 Paul.  Add support for Office 365 OAuth. 
					string sMAIL_SENDTYPE = new DynamicControl(this, "SERVICE").SelectedValue;
					if ( Sql.IsEmptyString(sMAIL_SENDTYPE) )
						sMAIL_SENDTYPE = "pop3";
					if ( String.Compare(sMAIL_SENDTYPE, "pop3", true) == 0 || String.Compare(sMAIL_SENDTYPE, "imap", true) == 0 )
					{
						this.ValidateEditViewFields(m_sMODULE + ".SmtpView");
					}
					// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
					else if ( String.Compare(sMAIL_SENDTYPE, "Exchange-Password", true) == 0  )
					{
						this.ValidateEditViewFields(m_sMODULE + ".ExchangeView");
						new DynamicControl(this, "SERVER_URL"    ).Text    = String.Empty;
						new DynamicControl(this, "PORT"          ).Text    = String.Empty;
						new DynamicControl(this, "MAILBOX_SSL"   ).Checked = false;
					}
					else
					{
						new DynamicControl(this, "SERVER_URL"    ).Text    = String.Empty;
						new DynamicControl(this, "PORT"          ).Text    = String.Empty;
						new DynamicControl(this, "EMAIL_USER"    ).Text    = String.Empty;
						new DynamicControl(this, "EMAIL_PASSWORD").Text    = String.Empty;
						new DynamicControl(this, "MAILBOX_SSL"   ).Checked = false;
					}
					if ( Page.IsValid )
					{
						string sEMAIL_PASSWORD = String.Empty;
						// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
						if ( String.Compare(sMAIL_SENDTYPE, "Exchange-Password", true) == 0 || String.Compare(sMAIL_SENDTYPE, "pop3", true) == 0 || String.Compare(sMAIL_SENDTYPE, "imap", true) == 0 )
						{
							// 01/08/2008 Paul.  If the encryption key does not exist, then we must create it and we must save it back to the database. 
							// 01/08/2008 Paul.  SugarCRM uses blowfish for the inbound email encryption, but we will not since .NET 2.0 does not support blowfish natively. 
							Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
							Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
							// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
							sEMAIL_PASSWORD = Sql.sEMPTY_PASSWORD;
							TextBox EMAIL_PASSWORD = FindControl("EMAIL_PASSWORD") as TextBox;
							if ( EMAIL_PASSWORD != null )
								sEMAIL_PASSWORD = EMAIL_PASSWORD.Text;
							// 07/08/2010 Paul.  We want to save the password for later use. 
							// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
							if ( sEMAIL_PASSWORD == Sql.sEMPTY_PASSWORD )
							{
								sEMAIL_PASSWORD = Sql.ToString(ViewState["smtppass"]);
							}
							else
							{
								string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sEMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
								if ( Security.DecryptPassword(sENCRYPTED_EMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sEMAIL_PASSWORD )
									throw(new Exception("Decryption failed"));
								sEMAIL_PASSWORD = sENCRYPTED_EMAIL_PASSWORD;
								if ( EMAIL_PASSWORD != null )
									EMAIL_PASSWORD.Attributes.Add("value", sEMAIL_PASSWORD);
							}
						}
						else if ( String.Compare(sMAIL_SENDTYPE, "Office365", true) == 0 )
						{
							string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
							string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
							Office365AccessToken token = SplendidCRM.ActiveDirectory.Office365RefreshAccessToken(Application, sOAuthClientID, sOAuthClientSecret, gID, false);
							// 02/09/2017 Paul.  Use Microsoft Graph REST API to get email. 
							MicrosoftGraphProfile profile = SplendidCRM.ActiveDirectory.GetProfile(Application, token.AccessToken);
							if ( profile != null )
							{
								new DynamicControl(this, "EMAIL_USER").Text = Sql.ToString(profile.EmailAddress);
							}
						}
						else if ( String.Compare(sMAIL_SENDTYPE, "GoogleApps", true) == 0 )
						{
							string sMAILBOX = new DynamicControl(this, "MAILBOX").Text;
							if ( String.Compare(sMAILBOX, "INBOX", true) == 0 )
							{
								new DynamicControl(this, "MAILBOX").Text = sMAILBOX.ToUpper();
							}
							StringBuilder sbErrors = new StringBuilder();
							bool bValidSource = SplendidCRM.GoogleApps.TestMailbox(Application, gID, sMAILBOX, sbErrors);
							if ( !bValidSource )
								throw(new Exception(sbErrors.ToString()));
							// 02/09/2017 Paul.  Grab the Email address to help construct a unique message ID. 
							new DynamicControl(this, "EMAIL_USER").Text = SplendidCRM.GoogleApps.GetEmailAddress(Application, gID, sbErrors);
						}
						
						// 09/09/2009 Paul.  Use the new function to get the table name. 
						string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
						DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
							DataRow   rowCurrent = null;
							DataTable dtCurrent  = new DataTable();
							if ( !Sql.IsEmptyGuid(gID) )
							{
								string sSQL ;
								sSQL = "select *                    " + ControlChars.CrLf
								     + "  from vwINBOUND_EMAILS_Edit" + ControlChars.CrLf
								     + " where ID = @ID             " + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@ID", gID);
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										da.Fill(dtCurrent);
										if ( dtCurrent.Rows.Count > 0 )
										{
											rowCurrent = dtCurrent.Rows[0];
											// 12/09/2008 Paul.  Throw an exception if the record has been edited since the last load. 
											DateTime dtLAST_DATE_MODIFIED = Sql.ToDateTime(ViewState["LAST_DATE_MODIFIED"]);
											// 03/15/2014 Paul.  Enable override of concurrency error. 
											if ( Sql.ToBoolean(Application["CONFIG.enable_concurrency_check"])  && (e.CommandName != "SaveConcurrency") && dtLAST_DATE_MODIFIED != DateTime.MinValue && Sql.ToDateTime(rowCurrent["DATE_MODIFIED"]) > dtLAST_DATE_MODIFIED )
											{
												ctlDynamicButtons.ShowButton("SaveConcurrency", true);
												ctlFooterButtons .ShowButton("SaveConcurrency", true);
												throw(new Exception(String.Format(L10n.Term(".ERR_CONCURRENCY_OVERRIDE"), dtLAST_DATE_MODIFIED)));
											}
										}
										else
										{
											// 01/17/2017 Paul.  We do not want to clear the ID because we want to use the NEW_ID value. 
											//gID = Guid.Empty;
										}
									}
								}
							}
							// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									// 04/12/2011 Paul.  Stop forcing the mailbox to be INBOX. 
									// 04/19/2011 Paul.  Add IS_PERSONAL to exclude EmailClient inbound from being included in monitored list. 
									// 01/23/2013 Paul.  Add REPLY_TO_NAME and REPLY_TO_ADDR. 
									SqlProcs.spINBOUND_EMAILS_Update
										( ref gID
										, new DynamicControl(this, rowCurrent, "NAME"          ).Text
										, new DynamicControl(this, rowCurrent, "STATUS"        ).SelectedValue
										, new DynamicControl(this, rowCurrent, "SERVER_URL"    ).Text
										, new DynamicControl(this, rowCurrent, "EMAIL_USER"    ).Text
										, sEMAIL_PASSWORD
										, new DynamicControl(this, rowCurrent, "PORT"          ).IntegerValue
										, new DynamicControl(this, rowCurrent, "MAILBOX_SSL"   ).Checked
										, new DynamicControl(this, rowCurrent, "SERVICE"       ).SelectedValue
										, new DynamicControl(this, rowCurrent, "MAILBOX"       ).Text
										, new DynamicControl(this, rowCurrent, "MARK_READ"     ).Checked
										, new DynamicControl(this, rowCurrent, "ONLY_SINCE"    ).Checked
										, new DynamicControl(this, rowCurrent, "MAILBOX_TYPE"  ).SelectedValue
										, new DynamicControl(this, rowCurrent, "TEMPLATE_ID"   ).ID
										, new DynamicControl(this, rowCurrent, "GROUP_ID"      ).ID
										, new DynamicControl(this, rowCurrent, "FROM_NAME"     ).Text
										, new DynamicControl(this, rowCurrent, "FROM_ADDR"     ).Text
										, new DynamicControl(this, rowCurrent, "FILTER_DOMAIN" ).Text
										, new DynamicControl(this, rowCurrent, "IS_PERSONAL"   ).Checked
										, new DynamicControl(this, rowCurrent, "REPLY_TO_NAME" ).Text
										, new DynamicControl(this, rowCurrent, "REPLY_TO_ADDR" ).Text
										// 01/28/2017 Paul.  TEAM_ID for inbound emails. 
										, new DynamicControl(this, rowCurrent, "GROUP_TEAM_ID" ).ID
										, trn
										);
									SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
									SqlProcs.spTRACKER_Update
										( Security.USER_ID
										, m_sMODULE
										, gID
										, new DynamicControl(this, rowCurrent, "NAME").Text
										, "save"
										, trn
										);
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
						SplendidCache.ClearEmailGroups();
						SplendidCache.ClearInboundEmails();
						Response.Redirect("view.aspx?ID=" + gID.ToString());
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					ctlDynamicButtons.ErrorText = ex.Message;
				}
			}
			else if ( e.CommandName == "Test" )
			{
				try
				{
					// 01/16/2006 Paul.  Enable validator before validating page. 
					this.ValidateEditViewFields(m_sMODULE + "." + LayoutEditView);
					this.ValidateEditViewFields(m_sMODULE + ".EditOptions"      );
					string sMAIL_SENDTYPE = new DynamicControl(this, "SERVICE").SelectedValue;
					if ( Sql.IsEmptyString(sMAIL_SENDTYPE) )
						sMAIL_SENDTYPE = "pop3";
					if ( String.Compare(sMAIL_SENDTYPE, "pop3", true) == 0 || String.Compare(sMAIL_SENDTYPE, "imap", true) == 0 )
					{
						this.ValidateEditViewFields(m_sMODULE + ".SmtpView");
					}
					// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
					else if ( String.Compare(sMAIL_SENDTYPE, "Exchange-Password", true) == 0  )
					{
						this.ValidateEditViewFields(m_sMODULE + ".ExchangeView");
					}

					if ( Page.IsValid )
					{
						Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
						Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
						// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
						string sEMAIL_PASSWORD = Sql.sEMPTY_PASSWORD;
						TextBox EMAIL_PASSWORD = FindControl("EMAIL_PASSWORD") as TextBox;
						if ( EMAIL_PASSWORD != null )
							sEMAIL_PASSWORD = EMAIL_PASSWORD.Text;
						// 07/08/2010 Paul.  We want to save the password for later use. 
						// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
						if ( sEMAIL_PASSWORD == Sql.sEMPTY_PASSWORD )
						{
							sEMAIL_PASSWORD = Sql.ToString(ViewState["smtppass"]);
							if ( !Sql.IsEmptyString(sEMAIL_PASSWORD) )
								sEMAIL_PASSWORD = Security.DecryptPassword(sEMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
						}
						else
						{
							string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sEMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
							if ( Security.DecryptPassword(sENCRYPTED_EMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sEMAIL_PASSWORD )
								throw(new Exception("Decryption failed"));
							if ( EMAIL_PASSWORD != null )
							{
								// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
								EMAIL_PASSWORD.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
							}
						}
						string sSERVICE     = new DynamicControl(this, "SERVICE"       ).SelectedValue;
						string sSERVER_URL  = new DynamicControl(this, "SERVER_URL"    ).Text;
						int    nPORT        = new DynamicControl(this, "PORT"          ).IntegerValue;
						bool   bMAILBOX_SSL = new DynamicControl(this, "MAILBOX_SSL"   ).Checked;
						string sEMAIL_USER  = new DynamicControl(this, "EMAIL_USER"    ).Text;
						string sMAILBOX     = new DynamicControl(this, "MAILBOX"       ).Text;
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
							throw(new Exception("This is not the correct button to test this service: " + sSERVICE));
						}
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					ctlDynamicButtons.ErrorText = ex.Message;
				}
			}
			// 01/17/2017 Paul.  Google now uses OAuth 2.0. 
			else if ( e.CommandName == "GoogleApps.Test" )
			{
				try
				{
					StringBuilder sbErrors = new StringBuilder();
					string sMAILBOX = new DynamicControl(this, "MAILBOX").Text;
					SplendidCRM.GoogleApps.TestMailbox(Application, gID, sMAILBOX, sbErrors);
					lblGoogleAuthorizedStatus.Text = sbErrors.ToString();
				}
				catch(Exception ex)
				{
					lblGoogleAuthorizedStatus.Text = ex.Message;
				}
			}
			else if ( e.CommandName == "GoogleApps.Authorize" )
			{
				try
				{
					DateTime dtOAUTH_EXPIRES_AT = DateTime.Now.AddSeconds(Sql.ToInteger(OAUTH_EXPIRES_IN.Text));
					// 01/19/2017 Paul.  Name must match SEND_TYPE. 
					SqlProcs.spOAUTH_TOKENS_Update(gID, "GoogleApps", OAUTH_ACCESS_TOKEN.Text, String.Empty, dtOAUTH_EXPIRES_AT, OAUTH_REFRESH_TOKEN.Text);
					Application["CONFIG.GoogleApps." + gID.ToString() + ".OAuthAccessToken" ] = OAUTH_ACCESS_TOKEN.Text ;
					Application["CONFIG.GoogleApps." + gID.ToString() + ".OAuthRefreshToken"] = OAUTH_REFRESH_TOKEN.Text;
					Application["CONFIG.GoogleApps." + gID.ToString() + ".OAuthExpiresAt"   ] = dtOAUTH_EXPIRES_AT.ToShortDateString() + " " + dtOAUTH_EXPIRES_AT.ToShortTimeString();
					lblGoogleAuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
					btnGoogleAppsAuthorize   .Visible = false;
					btnGoogleAppsDelete      .Visible = true ;
					btnGoogleAppsTest        .Visible = true ;
					btnGoogleAppsRefreshToken.Visible = true && bDebug;
					lblGoogleAppsAuthorized  .Visible = true ;
				}
				catch(Exception ex)
				{
					lblGoogleAuthorizedStatus.Text = ex.Message;
				}
			}
			else if ( e.CommandName == "GoogleApps.Delete" )
			{
				try
				{
					// 01/19/2017 Paul.  Name must match SEND_TYPE. 
					SqlProcs.spOAUTH_TOKENS_Delete(gID, "GoogleApps");
					btnGoogleAppsAuthorize   .Visible = true ;
					btnGoogleAppsDelete      .Visible = false;
					btnGoogleAppsTest        .Visible = false;
					btnGoogleAppsRefreshToken.Visible = false;
					lblGoogleAppsAuthorized  .Visible = false;
				}
				catch(Exception ex)
				{
					lblOffice365AuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			else if ( e.CommandName == "GoogleApps.RefreshToken" )
			{
				try
				{
					SplendidCRM.GoogleApps.RefreshAccessToken(Application, gID, true);
					lblGoogleAuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
				}
				catch(Exception ex)
				{
					lblGoogleAuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			// 01/16/2017 Paul.  Add support for Office 365 OAuth. 
			else if ( e.CommandName == "Office365.Authorize" )
			{
				try
				{
					string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
					string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
					// 11/09/2019 Paul.  Pass the RedirectURL so that we can call from the React client. 
					SplendidCRM.ActiveDirectory.Office365AcquireAccessToken(Context, sOAuthClientID, sOAuthClientSecret, gID, OAUTH_CODE.Text, String.Empty);
					lblOffice365AuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
					btnOffice365Authorize   .Visible = false;
					btnOffice365Delete      .Visible = true ;
					btnOffice365Test        .Visible = true ;
					btnOffice365RefreshToken.Visible = true && bDebug;
					lblOffice365Authorized  .Visible = true ;
				}
				catch(Exception ex)
				{
					lblOffice365AuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			else if ( e.CommandName == "Office365.RefreshToken" )
			{
				try
				{
					string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
					string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
					SplendidCRM.ActiveDirectory.Office365RefreshAccessToken(Application, sOAuthClientID, sOAuthClientSecret, gID, true);
					lblOffice365AuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
				}
				catch(Exception ex)
				{
					lblOffice365AuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			else if ( e.CommandName == "Office365.Delete" )
			{
				try
				{
					SqlProcs.spOAUTH_TOKENS_Delete(gID, "Office365");
					btnOffice365Authorize   .Visible = true ;
					btnOffice365Delete      .Visible = false;
					btnOffice365Test        .Visible = false;
					btnOffice365RefreshToken.Visible = false;
					lblOffice365Authorized  .Visible = false;
				}
				catch(Exception ex)
				{
					lblOffice365AuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			else if ( e.CommandName == "Office365.Test" )
			{
				try
				{
					StringBuilder sbErrors = new StringBuilder();
					string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
					string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
					string sMAILBOX           = new DynamicControl(this, "MAILBOX"       ).Text;
					// 12/13/2020 Paul.  Move Office365 methods to Office365utils. 
					Office365Utils.ValidateExchange(Application, sOAuthClientID, sOAuthClientSecret, gID, sMAILBOX, sbErrors);
					lblOffice365AuthorizedStatus.Text = sbErrors.ToString();
#if DEBUG
					Office365AccessToken token = SplendidCRM.ActiveDirectory.Office365RefreshAccessToken(Application, sOAuthClientID, sOAuthClientSecret, gID, false);
					// 02/09/2017 Paul.  Use Microsoft Graph REST API to get email. 
					MicrosoftGraphProfile profile = SplendidCRM.ActiveDirectory.GetProfile(Application, token.AccessToken);
					if ( profile != null )
						Debug.WriteLine(Sql.ToString(profile.EmailAddress));
#endif
				}
				catch(Exception ex)
				{
					lblOffice365AuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			else if ( e.CommandName == "Cancel" )
			{
				if ( Sql.IsEmptyGuid(gID) )
					Response.Redirect("default.aspx");
				else
					Response.Redirect("view.aspx?ID=" + gID.ToString());
			}
		}

		protected void MAIL_SENDTYPE_SelectedIndexChanged(object sender, EventArgs e)
		{
			DropDownList lstMAIL_SENDTYPE = FindControl("SERVICE") as DropDownList;
			if ( lstMAIL_SENDTYPE != null )
			{
				string sMAIL_SENDTYPE = lstMAIL_SENDTYPE.SelectedValue;
				bool bSmtp     = (String.Compare(sMAIL_SENDTYPE, "pop3", true) == 0 || String.Compare(sMAIL_SENDTYPE, "imap", true) == 0 || sMAIL_SENDTYPE == String.Empty);
				// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
				bool bExchange = (String.Compare(sMAIL_SENDTYPE, "Exchange-Password", true) == 0);
				tblSmtpPanel.Visible = bSmtp || bExchange;
				new DynamicControl(this, "SERVER_URL"                ).Visible = bSmtp;
				new DynamicControl(this, "SERVER_URL_LABEL"          ).Visible = bSmtp;
				new DynamicControl(this, "SERVER_URL_REQUIRED_SYMBOL").Visible = bSmtp;
				new DynamicControl(this, "PORT"                      ).Visible = bSmtp;
				new DynamicControl(this, "PORT_LABEL"                ).Visible = bSmtp;
				new DynamicControl(this, "PORT_REQUIRED_SYMBOL"      ).Visible = bSmtp;
				new DynamicControl(this, "MAILBOX_SSL"               ).Visible = bSmtp;
				new DynamicControl(this, "MAILBOX_SSL_LABEL"         ).Visible = bSmtp;
				RequiredFieldValidator reqSERVER_URL = FindControl("SERVER_URL_REQUIRED") as RequiredFieldValidator;
				if ( reqSERVER_URL != null )
				{
					reqSERVER_URL.Enabled = bSmtp;
					reqSERVER_URL.EnableClientScript = bSmtp;
				}
				RequiredFieldValidator reqPORT = FindControl("PORT_REQUIRED") as RequiredFieldValidator;
				if ( reqPORT != null )
				{
					reqPORT.Enabled = bSmtp;
					reqPORT.EnableClientScript = bSmtp;
				}

				tblOffice365Panel .Visible = (String.Compare(sMAIL_SENDTYPE, "Office365" , true) == 0);
				tblGoogleAppsPanel.Visible = (String.Compare(sMAIL_SENDTYPE, "GoogleApps", true) == 0);
				ctlDynamicButtons.ShowButton("Test", bSmtp || bExchange);
				ctlFooterButtons .ShowButton("Test", bSmtp || bExchange);

				if ( Sql.IsEmptyString(Application["CONFIG.Exchange.ClientID"]) || Sql.IsEmptyString(Application["CONFIG.Exchange.ClientSecret"]) )
				{
					lblOffice365AuthorizedStatus.Text = L10n.Term("OutboundEmail.LBL_OFFICE365_NOT_ENABLED");
					lblOffice365AuthorizedStatus.CssClass = "error";
				}
				if ( !Sql.ToBoolean(Context.Application["CONFIG.GoogleApps.Enabled"]) )
				{
					lblGoogleAuthorizedStatus.Text = L10n.Term("OutboundEmail.LBL_GOOGLEAPPS_NOT_ENABLED");
					lblGoogleAuthorizedStatus.CssClass = "error";
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			try
			{
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
					ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
					ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
					// 01/26/2017 Paul.  The NEW_ID field is used in case we need to save OAuth for a new record. 
					if ( !Sql.IsEmptyGuid(gID) )
						NEW_ID.Value = gID.ToString();
					else
						NEW_ID.Value = Guid.NewGuid().ToString();
					//Debug.WriteLine("NEW_ID = " + NEW_ID.Value);

					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
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
								if ( !Sql.IsEmptyGuid(gDuplicateID) )
								{
									Sql.AddParameter(cmd, "@ID", gDuplicateID);
									gID = Guid.Empty;
								}
								else
								{
									Sql.AddParameter(cmd, "@ID", gID);
								}
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
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);

											this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain   , rdr);
											this.AppendEditViewFields(m_sMODULE + ".EditOptions"      , tblOptions, rdr);
											this.AppendEditViewFields(m_sMODULE + ".SmtpView"         , tblSmtp   , rdr);
											// 01/26/2017 Paul.  Separate view for Smtp values
											DropDownList lstMAIL_SENDTYPE = FindControl("SERVICE") as DropDownList;
											if ( lstMAIL_SENDTYPE != null )
											{
												lstMAIL_SENDTYPE.AutoPostBack = true;
												lstMAIL_SENDTYPE.SelectedIndexChanged += new EventHandler(MAIL_SENDTYPE_SelectedIndexChanged);
												MAIL_SENDTYPE_SelectedIndexChanged(null, null);
											}
											TextBox EMAIL_PASSWORD = FindControl("EMAIL_PASSWORD") as TextBox;
											if ( EMAIL_PASSWORD != null )
												EMAIL_PASSWORD.TextMode = TextBoxMode.Password;
											// 01/08/2008 Paul.  Don't display the password. 
											// 01/08/2008 Paul.  Browsers don't display passwords. 
											// 07/08/2010 Paul.  We want to save the password for later use. 
											string sEMAIL_PASSWORD = Sql.ToString(rdr["EMAIL_PASSWORD"]);
											if ( !Sql.IsEmptyString(sEMAIL_PASSWORD) )
											{
												ViewState["smtppass"] = sEMAIL_PASSWORD;
												if ( EMAIL_PASSWORD != null )
												{
													// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
													//txtEMAIL_PASSWORD.Text = Sql.sEMPTY_PASSWORD;
													EMAIL_PASSWORD.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
												}
											}
											// 04/19/2011 Paul.  A personal email can only have two types, None and Bounce. 
											DropDownList GROUP_ID = FindControl("GROUP_ID") as DropDownList;
											if ( Sql.ToBoolean(rdr["IS_PERSONAL"]) )
											{
												DropDownList MAILBOX_TYPE = FindControl("MAILBOX_TYPE") as DropDownList;
												if ( MAILBOX_TYPE != null )
												{
													MAILBOX_TYPE.Items.Clear();
													MAILBOX_TYPE.Items.Add(new ListItem(L10n.Term(".LBL_NONE"), ""));
													MAILBOX_TYPE.Items.Add(new ListItem(Sql.ToString(L10n.Term(".dom_mailbox_type.", "bounce")), "bounce"));
													try
													{
														Utils.SetSelectedValue(MAILBOX_TYPE, Sql.ToString(rdr["MAILBOX_TYPE"]));
													}
													catch
													{
													}
												}
												if ( GROUP_ID != null )
												{
													GROUP_ID.Visible = false;
												}
												Literal GROUP_ID_LABEL = FindControl("GROUP_ID_LABEL") as Literal;
												if ( GROUP_ID_LABEL != null )
												{
													GROUP_ID_LABEL.Visible = false;
													// 04/19/2011 Paul.  We also want to hide the required field indicator. 
													if ( GROUP_ID_LABEL.Parent.Controls.Count == 2 )
													{
														GROUP_ID_LABEL.Parent.Controls[0].Visible = false;
														GROUP_ID_LABEL.Parent.Controls[1].Visible = false;
													}
												}
											}
											else
											{
												if ( GROUP_ID != null )
												{
													GROUP_ID.Items.Insert(0, new ListItem(L10n.Term("InboundEmail.LBL_CREATE_NEW_GROUP"), ""));
												}
											}
											// 12/09/2008 Paul.  Throw an exception if the record has been edited since the last load. 
											ViewState["LAST_DATE_MODIFIED"] = Sql.ToDateTime(rdr["DATE_MODIFIED"]);
											// 01/26/2017 Paul.  Add support for Office 365 OAuth. 
											try
											{
												bool bOFFICE365_OAUTH_ENABLED = Sql.ToBoolean(rdr["OFFICE365_OAUTH_ENABLED"]);
												btnOffice365Authorize   .Visible = !bOFFICE365_OAUTH_ENABLED && !Sql.IsEmptyString(Application["CONFIG.Exchange.ClientID"]) && !Sql.IsEmptyString(Application["CONFIG.Exchange.ClientSecret"]);
												btnOffice365Delete      .Visible =  bOFFICE365_OAUTH_ENABLED;
												btnOffice365Test        .Visible =  bOFFICE365_OAUTH_ENABLED;
												btnOffice365RefreshToken.Visible =  bOFFICE365_OAUTH_ENABLED && bDebug;
												lblOffice365Authorized  .Visible =  bOFFICE365_OAUTH_ENABLED;
											}
											catch(Exception ex)
											{
												SplendidError.SystemError(new StackTrace(true).GetFrame(0), "OFFICE365_OAUTH_ENABLED is not defined. " + ex.Message);
											}
											try
											{
												bool bGOOGLEAPPS_OAUTH_ENABLED = Sql.ToBoolean(rdr["GOOGLEAPPS_OAUTH_ENABLED"]);
												btnGoogleAppsAuthorize   .Visible = !bGOOGLEAPPS_OAUTH_ENABLED && Sql.ToBoolean(Context.Application["CONFIG.GoogleApps.Enabled"]);;
												btnGoogleAppsDelete      .Visible =  bGOOGLEAPPS_OAUTH_ENABLED;
												btnGoogleAppsTest        .Visible =  bGOOGLEAPPS_OAUTH_ENABLED;
												btnGoogleAppsRefreshToken.Visible =  bGOOGLEAPPS_OAUTH_ENABLED && bDebug;
												lblGoogleAppsAuthorized  .Visible =  bGOOGLEAPPS_OAUTH_ENABLED;
											}
											catch(Exception ex)
											{
												SplendidError.SystemError(new StackTrace(true).GetFrame(0), "GOOGLEAPPS_OAUTH_ENABLED is not defined. " + ex.Message);
											}
										}
									}
								}
							}
						}
					}
					else
					{
						this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain   , null);
						this.AppendEditViewFields(m_sMODULE + ".EditOptions"      , tblOptions, null);
						this.AppendEditViewFields(m_sMODULE + ".SmtpView"         , tblSmtp   , null);
						// 01/17/2017 Paul.  Separate view for Smtp values
						DropDownList lstMAIL_SENDTYPE = FindControl("SERVICE") as DropDownList;
						if ( lstMAIL_SENDTYPE != null )
						{
							lstMAIL_SENDTYPE.AutoPostBack = true;
							lstMAIL_SENDTYPE.SelectedIndexChanged += new EventHandler(MAIL_SENDTYPE_SelectedIndexChanged);
							MAIL_SENDTYPE_SelectedIndexChanged(null, null);
						}
						TextBox EMAIL_PASSWORD = FindControl("EMAIL_PASSWORD") as TextBox;
						if ( EMAIL_PASSWORD != null )
							EMAIL_PASSWORD.TextMode = TextBoxMode.Password;
						// 03/18/2008 Paul.  The default value of bounce should only apply to new record. 
						DropDownList MAILBOX_TYPE = FindControl("MAILBOX_TYPE") as DropDownList;
						if ( MAILBOX_TYPE != null )
						{
							try
							{
								// 08/19/2010 Paul.  Check the list before assigning the value. 
								Utils.SetSelectedValue(MAILBOX_TYPE, "bounce");
							}
							catch
							{
							}
						}
						new DynamicControl(this, "MAILBOX").Text = "Inbox";
						DropDownList GROUP_ID = FindControl("GROUP_ID") as DropDownList;
						if ( GROUP_ID != null )
						{
							GROUP_ID.Items.Insert(0, new ListItem(L10n.Term("InboundEmail.LBL_CREATE_NEW_GROUP"), ""));
						}
						btnOffice365Authorize .Visible = true;
						bool bOFFICE365_OAUTH_ENABLED = false;
						btnOffice365Authorize   .Visible = !bOFFICE365_OAUTH_ENABLED && !Sql.IsEmptyString(Application["CONFIG.Exchange.ClientID"]) && !Sql.IsEmptyString(Application["CONFIG.Exchange.ClientSecret"]);
						btnOffice365Delete      .Visible =  bOFFICE365_OAUTH_ENABLED;
						btnOffice365Test        .Visible =  bOFFICE365_OAUTH_ENABLED;
						btnOffice365RefreshToken.Visible =  bOFFICE365_OAUTH_ENABLED && bDebug;
						lblOffice365Authorized  .Visible =  bOFFICE365_OAUTH_ENABLED;
						bool bGOOGLEAPPS_OAUTH_ENABLED = false;
						btnGoogleAppsAuthorize   .Visible = !bGOOGLEAPPS_OAUTH_ENABLED && Sql.ToBoolean(Context.Application["CONFIG.GoogleApps.Enabled"]);;
						btnGoogleAppsDelete      .Visible =  bGOOGLEAPPS_OAUTH_ENABLED;
						btnGoogleAppsTest        .Visible =  bGOOGLEAPPS_OAUTH_ENABLED;
						btnGoogleAppsRefreshToken.Visible =  bGOOGLEAPPS_OAUTH_ENABLED && bDebug;
						lblGoogleAppsAuthorized  .Visible =  bGOOGLEAPPS_OAUTH_ENABLED;
					}
				}
				else
				{
					if ( Sql.IsEmptyGuid(gID) )
						gID = Sql.ToGuid(NEW_ID.Value);
					// 12/02/2005 Paul.  When validation fails, the header title does not retain its value.  Update manually. 
					// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
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
			m_sMODULE = "InboundEmail";
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				// 12/02/2005 Paul.  Need to add the edit fields in order for events to fire. 
				this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain   , null);
				this.AppendEditViewFields(m_sMODULE + ".EditOptions"      , tblOptions, null);
				this.AppendEditViewFields(m_sMODULE + ".SmtpView"         , tblSmtp   , null);
				// 01/17/2017 Paul.  Separate view for Smtp values
				DropDownList lstMAIL_SENDTYPE = FindControl("SERVICE") as DropDownList;
				if ( lstMAIL_SENDTYPE != null )
				{
					lstMAIL_SENDTYPE.AutoPostBack = true;
					lstMAIL_SENDTYPE.SelectedIndexChanged += new EventHandler(MAIL_SENDTYPE_SelectedIndexChanged);
				}
				TextBox EMAIL_PASSWORD = FindControl("EMAIL_PASSWORD") as TextBox;
				if ( EMAIL_PASSWORD != null )
					EMAIL_PASSWORD.TextMode = TextBoxMode.Password;
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
			}
		}
		#endregion
	}
}

