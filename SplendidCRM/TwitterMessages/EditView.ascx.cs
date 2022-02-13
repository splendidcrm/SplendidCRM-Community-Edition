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
using System.IO;
using System.Text;
using System.Data;
using System.Data.Common;
using System.Drawing;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Net;
using System.Net.Mail;
using System.Collections;
using System.Diagnostics;
using CKEditor.NET;

namespace SplendidCRM.TwitterMessages
{
	/// <summary>
	///		Summary description for EditView.
	/// </summary>
	public class EditView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		protected _controls.DynamicButtons ctlFooterButtons ;

		protected string          sTWITTER_STATUS              ;
		protected string          sTWITTER_TYPE                ;
		protected Guid            gID                          ;
		protected HtmlTable       tblMain                      ;
		protected PlaceHolder     plcSubPanel                  ;

		protected HiddenField     txtOAUTH_TOKEN               ;
		protected HiddenField     txtOAUTH_SECRET              ;
		protected HiddenField     txtOAUTH_VERIFIER            ;
		protected HiddenField     txtOAUTH_ACCESS_TOKEN        ;
		protected HiddenField     txtOAUTH_ACCESS_SECRET       ;
		protected Button          btnOAuthChanged              ;

		private void GetOAuthAccessTokens()
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				sSQL = "select *                                   " + ControlChars.CrLf
				     + "  from vwOAUTH_TOKENS                      " + ControlChars.CrLf
				     + " where NAME             = @NAME            " + ControlChars.CrLf
				     + "   and ASSIGNED_USER_ID = @ASSIGNED_USER_ID" + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@NAME"            , "Twitter");
					Sql.AddParameter(cmd, "@ASSIGNED_USER_ID", Security.USER_ID);
					if ( bDebug )
						RegisterClientScriptBlock("vwOAUTH_TOKENS", Sql.ClientScriptBlock(cmd));

					using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
					{
						if ( rdr.Read() )
						{
							txtOAUTH_ACCESS_TOKEN .Value = Sql.ToString(rdr["TOKEN" ]);
							txtOAUTH_ACCESS_SECRET.Value = Sql.ToString(rdr["SECRET"]);
						}
					}
				}
			}
		}

		protected void UpdateButtons()
		{
			bool bDraftStatus    = sTWITTER_TYPE == "draft";
			bool bSignInVisible  = false;
			bool bSendVisible    = false;
			bool bSignOutVisible = false;
			string sTwitterConsumerKey    = Sql.ToString(Application["CONFIG.Twitter.ConsumerKey"   ]);
			string sTwitterConsumerSecret = Sql.ToString(Application["CONFIG.Twitter.ConsumerSecret"]);
			if ( !Sql.IsEmptyString(sTwitterConsumerKey) && !Sql.IsEmptyString(sTwitterConsumerSecret) )
			{
				bSignInVisible  = Sql.IsEmptyString(txtOAUTH_VERIFIER.Value);
				bSendVisible    = !bSignInVisible;
				bSignOutVisible = !bSignInVisible;
				bDraftStatus    = (sTWITTER_TYPE == "draft" || (sTWITTER_TYPE == "out" && sTWITTER_STATUS == "send_error"));
				try
				{
					if ( bSignInVisible )
					{
						string sRedirectURL = Request.Url.Scheme + "://" + Request.Url.Host + Sql.ToString(Application["rootURL"]) + "Import/OAuthLanding.aspx";
						// 04/08/2012 Paul.  We were getting (401) Unauthorized until we specified a valid Callback URL in the Twitter Application (http://dev.twitter.com). 
						Spring.Social.Twitter.Connect.TwitterServiceProvider twitterServiceProvider = new Spring.Social.Twitter.Connect.TwitterServiceProvider(sTwitterConsumerKey, sTwitterConsumerSecret);
						// 10/21/2013 Paul.  We must use the Async call when Spring.NET is compiled using .NET 4.0. 
						Spring.Social.OAuth1.OAuthToken oauthToken = twitterServiceProvider.OAuthOperations.FetchRequestTokenAsync(sRedirectURL, null).Result;
						string authenticateUrl = twitterServiceProvider.OAuthOperations.BuildAuthorizeUrl(oauthToken.Value, null);
						txtOAUTH_TOKEN        .Value = oauthToken.Value ;
						txtOAUTH_SECRET       .Value = oauthToken.Secret;
						txtOAUTH_VERIFIER     .Value = String.Empty     ;
						txtOAUTH_ACCESS_TOKEN .Value = String.Empty     ;
						txtOAUTH_ACCESS_SECRET.Value = String.Empty     ;
					
						Button btnSignIn1 = ctlDynamicButtons.FindButton("SignIn");
						Button btnSignIn2 = ctlFooterButtons .FindButton("SignIn");
						if ( btnSignIn1 != null ) btnSignIn1.OnClientClick = "window.open('" + authenticateUrl + "', '" + "TwitterPopup" + "', 'width=600,height=360,status=1,toolbar=0,location=0,resizable=1'); return false;";
						if ( btnSignIn2 != null ) btnSignIn2.OnClientClick = "window.open('" + authenticateUrl + "', '" + "TwitterPopup" + "', 'width=600,height=360,status=1,toolbar=0,location=0,resizable=1'); return false;";
					}
				}
				catch(Exception ex)
				{
					ctlDynamicButtons.ErrorText = ex.Message;
				}
			}
			ctlDynamicButtons.ShowButton  ("Save"   , bDraftStatus);
			ctlDynamicButtons.ShowButton  ("Send"   , bDraftStatus && bSendVisible   );
			ctlDynamicButtons.ShowButton  ("SignIn" , bDraftStatus && bSignInVisible );
			ctlDynamicButtons.ShowButton  ("SignOut", bDraftStatus && bSignOutVisible);
				
			ctlFooterButtons .ShowButton  ("Save"   , bDraftStatus);
			ctlFooterButtons .ShowButton  ("Send"   , bDraftStatus && bSendVisible   );
			ctlFooterButtons .ShowButton  ("SignIn" , bDraftStatus && bSignInVisible );
			ctlFooterButtons .ShowButton  ("SignOut", bDraftStatus && bSignOutVisible);
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			Guid   gPARENT_ID   = Sql.ToGuid(Request["PARENT_ID"]);
			string sMODULE      = String.Empty;
			string sPARENT_TYPE = String.Empty;
			string sPARENT_NAME = String.Empty;
			try
			{
				SqlProcs.spPARENT_Get(ref gPARENT_ID, ref sMODULE, ref sPARENT_TYPE, ref sPARENT_NAME);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				// The only possible error is a connection failure, so just ignore all errors. 
				gPARENT_ID = Guid.Empty;
			}
			// 03/15/2014 Paul.  Enable override of concurrency error. 
			if ( e.CommandName == "Save" || e.CommandName == "SaveConcurrency" || e.CommandName == "Send" )
			{
				try
				{
					this.ValidateEditViewFields(m_sMODULE + "." + LayoutEditView);
					this.ApplyEditViewValidationEventRules(m_sMODULE + "." + LayoutEditView);
					
					if ( plcSubPanel.Visible )
					{
						foreach ( Control ctl in plcSubPanel.Controls )
						{
							InlineEditControl ctlSubPanel = ctl as InlineEditControl;
							if ( ctlSubPanel != null )
							{
								ctlSubPanel.ValidateEditViewFields();
							}
						}
					}
					if ( Page.IsValid )
					{
						string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
						DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							DataRow   rowCurrent = null;
							DataTable dtCurrent  = new DataTable();
							if ( !Sql.IsEmptyGuid(gID) )
							{
								string sSQL ;
								sSQL = "select *"               + ControlChars.CrLf
								     + "  from " + m_sVIEW_NAME + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Security.Filter(cmd, m_sMODULE, "edit");
									Sql.AppendParameter(cmd, gID, "ID", false);
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										da.Fill(dtCurrent);
										if ( dtCurrent.Rows.Count > 0 )
										{
											rowCurrent = dtCurrent.Rows[0];
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
											gID = Guid.Empty;
										}
									}
								}
							}
							
							this.ApplyEditViewPreSaveEventRules(m_sMODULE + "." + LayoutEditView, rowCurrent);
							
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									if ( e.CommandName == "Send" )
									{
										if ( sTWITTER_TYPE == "draft" )
											sTWITTER_TYPE = "out";
									}
									
									SqlProcs.spTWITTER_MESSAGES_Update
										( ref gID
										, new DynamicControl(this, rowCurrent, "ASSIGNED_USER_ID"     ).ID
										, new DynamicControl(this, rowCurrent, "TEAM_ID"              ).ID
										, new DynamicControl(this, rowCurrent, "TEAM_SET_LIST"        ).Text
										, new DynamicControl(this, rowCurrent, "NAME"                 ).Text
										, new DynamicControl(this, rowCurrent, "NAME"                 ).Text
										, new DynamicControl(this, rowCurrent, "DATE_START"           ).DateValue
										, new DynamicControl(this, rowCurrent, "PARENT_ID_PARENT_TYPE").SelectedValue
										, new DynamicControl(this, rowCurrent, "PARENT_ID"            ).ID
										, sTWITTER_TYPE
										, new DynamicControl(this, rowCurrent, "TWITTER_ID"           ).LongValue
										, new DynamicControl(this, rowCurrent, "TWITTER_USER_ID"      ).LongValue
										, new DynamicControl(this, rowCurrent, "TWITTER_FULL_NAME"    ).Text
										, new DynamicControl(this, rowCurrent, "TWITTER_SCREEN_NAME"  ).Text
										, new DynamicControl(this, rowCurrent, "ORIGINAL_ID"          ).LongValue
										, new DynamicControl(this, rowCurrent, "ORIGINAL_USER_ID"     ).LongValue
										, new DynamicControl(this, rowCurrent, "ORIGINAL_FULL_NAME"   ).Text
										, new DynamicControl(this, rowCurrent, "ORIGINAL_SCREEN_NAME" ).Text
										// 05/17/2017 Paul.  Add Tags module. 
										, new DynamicControl(this, rowCurrent, "TAG_SET_NAME"         ).Text
										// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
										, new DynamicControl(this, rowCurrent, "IS_PRIVATE"           ).Checked
										// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
										, new DynamicControl(this, rowCurrent, "ASSIGNED_SET_LIST"    ).Text
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
									if ( plcSubPanel.Visible )
									{
										foreach ( Control ctl in plcSubPanel.Controls )
										{
											InlineEditControl ctlSubPanel = ctl as InlineEditControl;
											if ( ctlSubPanel != null )
											{
												ctlSubPanel.Save(gID, m_sMODULE, trn);
											}
										}
									}
									trn.Commit();
									ViewState["ID"] = gID;
									SplendidCache.ClearFavorites();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0),  Utils.ExpandException(ex));
									ctlDynamicButtons.ErrorText = Utils.ExpandException(ex);
									return;
								}
								if ( e.CommandName == "Send" )
								{
									try
									{
										if ( !Utils.IsOfflineClient )
										{
											string sTwitterConsumerKey    = Sql.ToString(Application["CONFIG.Twitter.ConsumerKey"   ]);
											string sTwitterConsumerSecret = Sql.ToString(Application["CONFIG.Twitter.ConsumerSecret"]);
											Spring.Social.Twitter.Connect.TwitterServiceProvider twitterServiceProvider = new Spring.Social.Twitter.Connect.TwitterServiceProvider(sTwitterConsumerKey, sTwitterConsumerSecret);
											Spring.Social.OAuth1.OAuthToken oauthToken = new Spring.Social.OAuth1.OAuthToken(txtOAUTH_TOKEN.Value, txtOAUTH_SECRET.Value);
											
											// 04/08/2012 Paul.  First try and load an existing access token. 
											bool bNewAccessToken = false;
											if ( Sql.IsEmptyString(txtOAUTH_ACCESS_TOKEN.Value) )
											{
												GetOAuthAccessTokens();
											}
											if ( Sql.IsEmptyString(txtOAUTH_ACCESS_TOKEN.Value) )
											{
												Spring.Social.OAuth1.AuthorizedRequestToken requestToken = new Spring.Social.OAuth1.AuthorizedRequestToken(oauthToken, txtOAUTH_VERIFIER.Value);
												Spring.Social.OAuth1.OAuthToken oauthAccessToken = twitterServiceProvider.OAuthOperations.ExchangeForAccessTokenAsync(requestToken, null).Result;
												txtOAUTH_ACCESS_TOKEN .Value = oauthAccessToken.Value ;
												txtOAUTH_ACCESS_SECRET.Value = oauthAccessToken.Secret;
												// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
												SqlProcs.spOAUTH_TOKENS_Update(Security.USER_ID, "Twitter", oauthAccessToken.Value, oauthAccessToken.Secret, DateTime.MinValue, String.Empty);
												bNewAccessToken = true;
											}
											
											string sTWEET = new DynamicControl(this, rowCurrent, "NAME").Text;
											Spring.Social.Twitter.Api.Tweet tweet = null;
											try
											{
												Spring.Social.Twitter.Api.ITwitter twitter = twitterServiceProvider.GetApi(txtOAUTH_ACCESS_TOKEN.Value, txtOAUTH_ACCESS_SECRET.Value);
												tweet = twitter.TimelineOperations.UpdateStatusAsync(sTWEET).Result;
												SqlProcs.spTWITTER_MESSAGES_UpdateStatus(gID, "sent", tweet.ID);
											}
											catch(Exception ex)
											{
												if ( ex.Message == "The remote server returned an error: (400) Bad Request." )
													throw;
												SqlProcs.spOAUTH_TOKENS_Delete(Security.USER_ID, "Twitter");
												// 04/08/2012 Paul.  The access token may have expired, so if the first request fails, then try again using an updated token. 
												if ( !bNewAccessToken )
												{
													try
													{
														Spring.Social.OAuth1.AuthorizedRequestToken requestToken = new Spring.Social.OAuth1.AuthorizedRequestToken(oauthToken, txtOAUTH_VERIFIER.Value);
														Spring.Social.OAuth1.OAuthToken oauthAccessToken = twitterServiceProvider.OAuthOperations.ExchangeForAccessTokenAsync(requestToken, null).Result;
														txtOAUTH_ACCESS_TOKEN .Value = oauthAccessToken.Value ;
														txtOAUTH_ACCESS_SECRET.Value = oauthAccessToken.Secret;
														// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
														SqlProcs.spOAUTH_TOKENS_Update(Security.USER_ID, "Twitter", oauthAccessToken.Value, oauthAccessToken.Secret, DateTime.MinValue, String.Empty);
														bNewAccessToken = true;
													}
													catch(Exception ex1)
													{
														SqlProcs.spOAUTHKEYS_Delete(Security.USER_ID, "Twitter");
														SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex1);
														txtOAUTH_TOKEN        .Value = String.Empty;
														txtOAUTH_SECRET       .Value = String.Empty;
														txtOAUTH_VERIFIER     .Value = String.Empty;
														txtOAUTH_ACCESS_TOKEN .Value = String.Empty;
														txtOAUTH_ACCESS_SECRET.Value = String.Empty;
														UpdateButtons();
														throw;
													}
													Spring.Social.Twitter.Api.ITwitter twitter = twitterServiceProvider.GetApi(txtOAUTH_ACCESS_TOKEN.Value, txtOAUTH_ACCESS_SECRET.Value);
													tweet = twitter.TimelineOperations.UpdateStatusAsync(sTWEET).Result;
													SqlProcs.spTWITTER_MESSAGES_UpdateStatus(gID, "sent", tweet.ID);
												}
												else
												{
													SqlProcs.spTWITTER_MESSAGES_UpdateStatus(gID, "send_error", 0);
													SplendidError.SystemError(new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
													ctlDynamicButtons.ErrorText = Utils.ExpandException(ex);
													sTWITTER_STATUS = "send_error";
													UpdateButtons();
													return;
												}
											}
										}
									}
									catch(Exception ex)
									{
										SqlProcs.spTWITTER_MESSAGES_UpdateStatus(gID, "send_error", 0);
										SplendidError.SystemError(new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
										ctlDynamicButtons.ErrorText = Utils.ExpandException(ex);
										sTWITTER_STATUS = "send_error";
										UpdateButtons();
										return;
									}
								}
							}
							rowCurrent = Crm.Modules.ItemEdit(m_sMODULE, gID);
							this.ApplyEditViewPostSaveEventRules(m_sMODULE + "." + LayoutEditView, rowCurrent);
						}
						if ( !Sql.IsEmptyString(RulesRedirectURL) )
							Response.Redirect(RulesRedirectURL);
						else if ( !Sql.IsEmptyGuid(gPARENT_ID) )
							Response.Redirect("~/" + sMODULE + "/view.aspx?ID=" + gPARENT_ID.ToString());
						else if ( sTWITTER_TYPE == "draft" )
							Response.Redirect("default.aspx");
						else
							Response.Redirect("view.aspx?ID=" + gID.ToString());
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					ctlDynamicButtons.ErrorText = ex.Message;
				}
			}
			else if ( e.CommandName == "Cancel" )
			{
				if ( !Sql.IsEmptyGuid(gPARENT_ID) )
					Response.Redirect("~/" + sMODULE + "/view.aspx?ID=" + gPARENT_ID.ToString());
				else if ( Sql.IsEmptyGuid(gID) || Sql.ToString(ViewState["TYPE"]) == "draft" )
					Response.Redirect("default.aspx");
				else
					Response.Redirect("view.aspx?ID=" + gID.ToString());
			}
			else if ( e.CommandName == "SignOut" )
			{
				try
				{
					// 04/08/2012 Paul.  When the OAuth key is deleted, the access tokens become invalid, so delete them. 
					SqlProcs.spOAUTHKEYS_Delete(Security.USER_ID, "Twitter");
					txtOAUTH_TOKEN        .Value = String.Empty;
					txtOAUTH_SECRET       .Value = String.Empty;
					txtOAUTH_VERIFIER     .Value = String.Empty;
					txtOAUTH_ACCESS_TOKEN .Value = String.Empty;
					txtOAUTH_ACCESS_SECRET.Value = String.Empty;
					UpdateButtons();
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					ctlDynamicButtons.ErrorText = ex.Message;
				}
			}
			else if ( e.CommandName == "OAuthToken" )
			{
				try
				{
					if ( !Sql.IsEmptyString(txtOAUTH_TOKEN.Value) && !Sql.IsEmptyString(txtOAUTH_SECRET.Value) && !Sql.IsEmptyString(txtOAUTH_VERIFIER.Value) )
					{
						SqlProcs.spOAUTHKEYS_Update(Security.USER_ID, "Twitter", txtOAUTH_TOKEN.Value, txtOAUTH_SECRET.Value, txtOAUTH_VERIFIER.Value);
					}
					UpdateButtons();
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					ctlDynamicButtons.ErrorText = ex.Message;
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				gID = Sql.ToGuid(ViewState["ID"]);
				if ( !IsPostBack )
				{
					if ( Sql.IsEmptyGuid(gID) )
						gID = Sql.ToGuid(Request["ID"]);
					sTWITTER_TYPE = "draft";
					
					string sTwitterConsumerKey    = Sql.ToString(Application["CONFIG.Twitter.ConsumerKey"   ]);
					string sTwitterConsumerSecret = Sql.ToString(Application["CONFIG.Twitter.ConsumerSecret"]);
					if ( Sql.IsEmptyString(sTwitterConsumerKey) || Sql.IsEmptyString(sTwitterConsumerSecret) )
					{
						ctlDynamicButtons.ErrorText = L10n.Term("Twitter.ERR_TWITTER_SETUP");
						// 10/29/2013 Paul.  Change to warning so that Precompile does not stop. 
						ctlDynamicButtons.ErrorClass = "warning";
					}
					if ( Sql.IsEmptyGuid(gID) )
					{
						// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
						ctlDynamicButtons.EnableModuleLabel = false;
						ctlDynamicButtons.Title = "<a href=\"default.aspx\">" + L10n.Term("TwitterMessages.LBL_NEW_FORM_TITLE") + "</a><span class=\"pointer\">&raquo;</span>";
						ViewState["TYPE"] = sTWITTER_TYPE;
						ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
					}
					
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sSQL;
						sSQL = "select *                                   " + ControlChars.CrLf
						     + "  from vwOAUTHKEYS                         " + ControlChars.CrLf
						     + " where NAME             = @NAME            " + ControlChars.CrLf
						     + "   and ASSIGNED_USER_ID = @ASSIGNED_USER_ID" + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@NAME"            , "Twitter");
							Sql.AddParameter(cmd, "@ASSIGNED_USER_ID", Security.USER_ID);
							if ( bDebug )
								RegisterClientScriptBlock("vwOAUTHKEYS", Sql.ClientScriptBlock(cmd));

							using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
							{
								if ( rdr.Read() )
								{
									txtOAUTH_TOKEN   .Value = Sql.ToString(rdr["TOKEN"   ]);
									txtOAUTH_SECRET  .Value = Sql.ToString(rdr["SECRET"  ]);
									txtOAUTH_VERIFIER.Value = Sql.ToString(rdr["VERIFIER"]);
								}
							}
						}
					}
					string sRequestType = Sql.ToString(Request["type"]).ToLower();
					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
							sSQL = "select *"               + ControlChars.CrLf
							     + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
							     + "  from " + m_sVIEW_NAME + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Security.Filter(cmd, m_sMODULE, "edit");
								if ( !Sql.IsEmptyGuid(gDuplicateID) )
								{
									Sql.AppendParameter(cmd, gDuplicateID, "ID", false);
									gID = Guid.Empty;
								}
								else
								{
									Sql.AppendParameter(cmd, gID, "ID", false);
								}
								con.Open();
								
								if ( bDebug )
									RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));
								
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dtCurrent = new DataTable() )
									{
										da.Fill(dtCurrent);
										// 10/31/2017 Paul.  Provide a way to inject Record level ACL. 
										if ( dtCurrent.Rows.Count > 0 && (SplendidCRM.Security.GetRecordAccess(dtCurrent.Rows[0], m_sMODULE, "edit", "ASSIGNED_USER_ID") >= 0) )
										{
											DataRow rdr = dtCurrent.Rows[0];
											this.ApplyEditViewPreLoadEventRules(m_sMODULE + "." + LayoutEditView, rdr);
											
											ctlDynamicButtons.Title += Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
											ViewState["ID"] = gID;
											
											this.AppendEditViewRelationships(m_sMODULE + "." + LayoutEditView, plcSubPanel, Sql.IsEmptyGuid(Request["ID"]));
											this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain       , rdr);
											
											TextBox txtNAME = this.FindControl("NAME") as TextBox;
											if ( txtNAME != null )
												txtNAME.Focus();
											
											sTWITTER_TYPE   = Sql.ToString(rdr["TYPE"  ]).ToLower();
											sTWITTER_STATUS = Sql.ToString(rdr["STATUS"]).ToLower();
											if ( !Sql.IsEmptyGuid(gDuplicateID) )
											{
												sTWITTER_TYPE   = "draft";
												sTWITTER_STATUS = "draft";
											}
											if ( sRequestType == "retweet" )
											{
												sTWITTER_TYPE = "draft";
											}
											if ( (sTWITTER_TYPE == "out" && sTWITTER_STATUS == "draft") || sTWITTER_TYPE == "sent" )
											{
												Response.Redirect("view.aspx?ID=" + gID.ToString());
												return;
											}
											else if ( sTWITTER_TYPE == "inbound" )
											{
												Response.Redirect("inbound.aspx?ID=" + gID.ToString());
												return;
											}
											switch ( sTWITTER_TYPE )
											{
												case "out":
													// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
													ctlDynamicButtons.Title = "<a href=\"default.aspx\">" + L10n.Term("TwitterMessages.LBL_LIST_FORM_SENT_TITLE") + "</a><span class=\"pointer\">&raquo;</span>" + txtNAME.Text;
													break;
												default:
													sTWITTER_TYPE = "draft";
													// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
													ctlDynamicButtons.Title = "<a href=\"default.aspx\">" + L10n.Term("TwitterMessages.LBL_NEW_FORM_TITLE" ) + "</a><span class=\"pointer\">&raquo;</span>" + txtNAME.Text;
													break;
											}
											ctlDynamicButtons.EnableModuleLabel = false;
											
											ViewState["TYPE"] = sTWITTER_TYPE;
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											ctlDynamicButtons.Visible  = !PrintView;
											ctlFooterButtons .Visible  = !PrintView;
											UpdateButtons();
											ViewState["LAST_DATE_MODIFIED"] = Sql.ToDateTime(rdr["DATE_MODIFIED"]);
											
											ViewState ["NAME"            ] = Sql.ToString(rdr["NAME"            ]);
											ViewState ["ASSIGNED_USER_ID"] = Sql.ToGuid  (rdr["ASSIGNED_USER_ID"]);
											Page.Items["NAME"            ] = ViewState ["NAME"            ];
											Page.Items["ASSIGNED_USER_ID"] = ViewState ["ASSIGNED_USER_ID"];
											
											this.ApplyEditViewPostLoadEventRules(m_sMODULE + "." + LayoutEditView, rdr);
										}
										else
										{
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
											ctlFooterButtons .DisableAll();
											UpdateButtons();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
											plcSubPanel.Visible = false;
										}
									}
								}
							}
						}
					}
					else
					{
						this.AppendEditViewRelationships(m_sMODULE + "." + LayoutEditView, plcSubPanel, Sql.IsEmptyGuid(Request["ID"]));
						this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, null);
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						ctlDynamicButtons.Visible  = !PrintView;
						ctlFooterButtons .Visible  = !PrintView;
						UpdateButtons();
						
						TextBox txtNAME = this.FindControl("NAME") as TextBox;
						if ( txtNAME != null )
							txtNAME.Focus();
						
						Guid gPARENT_ID = Sql.ToGuid(Request["PARENT_ID"]);
						if ( !Sql.IsEmptyGuid(gPARENT_ID) )
						{
							// 04/14/2016 Paul.  New spPARENT_GetWithTeam procedure so that we can inherit Assigned To and Team values. 
							string sMODULE           = String.Empty;
							string sPARENT_TYPE      = String.Empty;
							string sPARENT_NAME      = String.Empty;
							Guid   gASSIGNED_USER_ID = Guid.Empty;
							string sASSIGNED_TO      = String.Empty;
							string sASSIGNED_TO_NAME = String.Empty;
							Guid   gTEAM_ID          = Guid.Empty;
							string sTEAM_NAME        = String.Empty;
							Guid   gTEAM_SET_ID      = Guid.Empty;
							// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
							Guid   gASSIGNED_SET_ID  = Guid.Empty;
							SqlProcs.spPARENT_GetWithTeam(ref gPARENT_ID, ref sMODULE, ref sPARENT_TYPE, ref sPARENT_NAME, ref gASSIGNED_USER_ID, ref sASSIGNED_TO, ref sASSIGNED_TO_NAME, ref gTEAM_ID, ref sTEAM_NAME, ref gTEAM_SET_ID, ref gASSIGNED_SET_ID);
							if ( !Sql.IsEmptyGuid(gPARENT_ID) )
							{
								// 12/17/2013 Paul.  sMODULE contains the internal module name and sPARENT_TYPE contains the folder name (only different for Projects and ProjectTasks). 
								// 01/23/2015 Paul.  Need to exclude Project and ProjectTask.  Not entirely sure why we update the parent type in the first place, but it is safer to leave the code. 
								if ( sPARENT_TYPE != "Project" && sPARENT_TYPE != "ProjectTask" )
									sPARENT_TYPE = sMODULE;
								new DynamicControl(this, "PARENT_ID"  ).ID   = gPARENT_ID;
								new DynamicControl(this, "PARENT_NAME").Text = sPARENT_NAME;
								new DynamicControl(this, "PARENT_ID_PARENT_TYPE").SelectedValue = sPARENT_TYPE;
								// 04/14/2016 Paul.  New spPARENT_GetWithTeam procedure so that we can inherit Assigned To and Team values. 
								if ( Sql.ToBoolean(Application["CONFIG.inherit_assigned_user"]) )
								{
									new DynamicControl(this, "ASSIGNED_USER_ID").ID   = gASSIGNED_USER_ID;
									new DynamicControl(this, "ASSIGNED_TO"     ).Text = sASSIGNED_TO     ;
									new DynamicControl(this, "ASSIGNED_TO_NAME").Text = sASSIGNED_TO_NAME;
									// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
									if ( Crm.Config.enable_dynamic_assignment() )
									{
										SplendidCRM._controls.UserSelect ctlUserSelect = FindControl("ASSIGNED_SET_NAME") as SplendidCRM._controls.UserSelect;
										if ( ctlUserSelect != null )
											ctlUserSelect.LoadLineItems(gASSIGNED_SET_ID, true, true);
									}
								}
								if ( Sql.ToBoolean(Application["CONFIG.inherit_team"]) )
								{
									new DynamicControl(this, "TEAM_ID"  ).ID   = gTEAM_ID  ;
									new DynamicControl(this, "TEAM_NAME").Text = sTEAM_NAME;
									SplendidCRM._controls.TeamSelect ctlTeamSelect = FindControl("TEAM_SET_NAME") as SplendidCRM._controls.TeamSelect;
									if ( ctlTeamSelect != null )
										ctlTeamSelect.LoadLineItems(gTEAM_SET_ID, true, true);
								}
							}
						}
						this.ApplyEditViewNewEventRules(m_sMODULE + "." + LayoutEditView);
					}
				}
				else
				{
					if ( Sql.IsEmptyGuid(gID) )
						ctlDynamicButtons.EnableModuleLabel = false;
					// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
					sTWITTER_TYPE = Sql.ToString(ViewState["TYPE"]);
					Page.Items["NAME"            ] = ViewState ["NAME"            ];
					Page.Items["ASSIGNED_USER_ID"] = ViewState ["ASSIGNED_USER_ID"];
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
			// CODEGEN: This Meeting is required by the ASP.NET Web Form Designer.
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
			m_sMODULE = "TwitterMessages";
			// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
			m_sVIEW_NAME = "vw" + Crm.Modules.TableName(m_sMODULE) + "_Edit";
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				this.AppendEditViewRelationships(m_sMODULE + "." + LayoutEditView, plcSubPanel, Sql.IsEmptyGuid(Request["ID"]));
				this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, null);
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				UpdateButtons();
				Page.Validators.Add(new RulesValidator(this));
			}
		}
		#endregion
	}
}

