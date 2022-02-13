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
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.TwitterMessages
{
	/// <summary>
	/// Summary description for InboundView.
	/// </summary>
	public class InboundView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;

		protected long        lTWITTER_ID      ;
		protected Guid        gID              ;
		protected HtmlTable   tblMain          ;
		protected PlaceHolder plcSubPanel      ;

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
			bool bSignInVisible  = false;
			bool bSendVisible    = false;
			bool bSignOutVisible = false;
			bool bDraftStatus    = false;
			string sTwitterConsumerKey    = Sql.ToString(Application["CONFIG.Twitter.ConsumerKey"   ]);
			string sTwitterConsumerSecret = Sql.ToString(Application["CONFIG.Twitter.ConsumerSecret"]);
			if ( !Sql.IsEmptyString(sTwitterConsumerKey) && !Sql.IsEmptyString(sTwitterConsumerSecret) )
			{
				bSignInVisible  = Sql.IsEmptyString(txtOAUTH_VERIFIER.Value);
				bSendVisible    = !bSignInVisible;
				bSignOutVisible = !bSignInVisible;
				bDraftStatus    = lTWITTER_ID > 0;
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
						if ( btnSignIn1 != null )
							btnSignIn1.OnClientClick = "window.open('" + authenticateUrl + "', '" + "TwitterPopup" + "', 'width=600,height=360,status=1,toolbar=0,location=0,resizable=1'); return false;";
					}
				}
				catch(Exception ex)
				{
					ctlDynamicButtons.ErrorText = ex.Message;
				}
			}
			ctlDynamicButtons.ShowButton  ("Retweet", bDraftStatus && bSendVisible   );
			ctlDynamicButtons.ShowButton  ("SignIn" , bDraftStatus && bSignInVisible );
			ctlDynamicButtons.ShowButton  ("SignOut", bDraftStatus && bSignOutVisible);
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
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
				try
				{
					SqlProcs.spTWITTER_MESSAGES_Delete(gID);
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					ctlDynamicButtons.ErrorText = ex.Message;
				}
				Response.Redirect("default.aspx");
			}
			else if ( e.CommandName == "Retweet" )
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
						
						try
						{
							Spring.Social.Twitter.Api.ITwitter twitter = twitterServiceProvider.GetApi(txtOAUTH_ACCESS_TOKEN.Value, txtOAUTH_ACCESS_SECRET.Value);
							twitter.TimelineOperations.RetweetAsync(lTWITTER_ID).Wait();
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
								twitter.TimelineOperations.RetweetAsync(lTWITTER_ID).Wait();
							}
							else
							{
								SplendidError.SystemError(new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
								ctlDynamicButtons.ErrorText = Utils.ExpandException(ex);
								UpdateButtons();
								return;
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
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "view") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					string sTwitterConsumerKey    = Sql.ToString(Application["CONFIG.Twitter.ConsumerKey"   ]);
					string sTwitterConsumerSecret = Sql.ToString(Application["CONFIG.Twitter.ConsumerSecret"]);
					if ( Sql.IsEmptyString(sTwitterConsumerKey) || Sql.IsEmptyString(sTwitterConsumerSecret) )
					{
						ctlDynamicButtons.ErrorText = L10n.Term("Twitter.ERR_TWITTER_SETUP");
						// 10/29/2013 Paul.  Change to warning so that Precompile does not stop. 
						ctlDynamicButtons.ErrorClass = "warning";
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
					if ( !Sql.IsEmptyGuid(gID) )
					{
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							sSQL = "select *                  " + ControlChars.CrLf
							     + "  from vwTWITTER_MESSAGES_Edit" + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Security.Filter(cmd, m_sMODULE, "view");
								Sql.AppendParameter(cmd, gID, "ID", false);
								con.Open();
								
								if ( bDebug )
									RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));
								
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dtCurrent = new DataTable() )
									{
										da.Fill(dtCurrent);
										if ( dtCurrent.Rows.Count > 0 )
										{
											DataRow rdr = dtCurrent.Rows[0];
											this.ApplyDetailViewPreLoadEventRules(m_sMODULE + ".DetailView", rdr);
											
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											
											this.AppendDetailViewRelationships(m_sMODULE + ".DetailView", plcSubPanel);
											this.AppendDetailViewFields(m_sMODULE + ".DetailView", tblMain, rdr);
											
											string sSUBJECT = Sql.ToString(rdr["NAME"]);
											new DynamicControl(this, "NAME").Text = sSUBJECT;
											
											lTWITTER_ID = Sql.ToLong(rdr["TWITTER_ID"]);
											ViewState["TWITTER_ID"] = lTWITTER_ID;
											string sEMAIL_TYPE = Sql.ToString(rdr["TYPE"]).ToLower();
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.EnableModuleLabel = false;
											switch ( sEMAIL_TYPE )
											{
												case "archived":
													ctlDynamicButtons.Title = "<a href=\"default.aspx\">" + L10n.Term("TwitterMessages.LBL_ARCHIVED_MODULE_NAME") + "</a><span class=\"pointer\">&raquo;</span>" + ctlDynamicButtons.Title;
													break;
												case "inbound":
													ctlDynamicButtons.Title = "<a href=\"default.aspx\">" + L10n.Term("TwitterMessages.LBL_INBOUND_TITLE") + "</a><span class=\"pointer\">&raquo;</span>" + ctlDynamicButtons.Title;
													string sEMAIL_STATUS = Sql.ToString(rdr["STATUS"]).ToLower();
													if ( sEMAIL_STATUS == "unread" )
													{
														SqlProcs.spTWITTER_MESSAGES_UpdateStatus(gID, "read", 0);
													}
													break;
												case "out":
													ctlDynamicButtons.Title = "<a href=\"default.aspx\">" + L10n.Term("TwitterMessages.LBL_LIST_FORM_SENT_TITLE") + "</a><span class=\"pointer\">&raquo;</span>" + ctlDynamicButtons.Title;
													Response.Redirect("view.aspx?ID=" + gID.ToString());
													break;
												case "sent":
													ctlDynamicButtons.Title = "<a href=\"default.aspx\">" + L10n.Term("TwitterMessages.LBL_LIST_FORM_SENT_TITLE") + "</a><span class=\"pointer\">&raquo;</span>" + ctlDynamicButtons.Title;
													break;
												case "campaign":
													ctlDynamicButtons.Title = "<a href=\"default.aspx\">" + L10n.Term("TwitterMessages.LBL_LIST_FORM_SENT_TITLE") + "</a><span class=\"pointer\">&raquo;</span>" + ctlDynamicButtons.Title;
													Response.Redirect("view.aspx?ID=" + gID.ToString());
													break;
												default:
													sEMAIL_TYPE = "draft";
													ctlDynamicButtons.Title = "<a href=\"default.aspx\">" + L10n.Term("TwitterMessages.LBL_NEW_FORM_TITLE" ) + "</a><span class=\"pointer\">&raquo;</span>" + ctlDynamicButtons.Title;
													Response.Redirect("edit.aspx?ID=" + gID.ToString());
													break;
											}
											Page.Items["ASSIGNED_USER_ID"] = Sql.ToGuid(rdr["ASSIGNED_USER_ID"]);
											ctlDynamicButtons.AppendButtons(m_sMODULE + ".InboundView", Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											UpdateButtons();
											this.ApplyDetailViewPostLoadEventRules(m_sMODULE + "." + LayoutDetailView, rdr);
										}
										else
										{
											plcSubPanel.Visible = false;
											ctlDynamicButtons.AppendButtons(m_sMODULE + ".InboundView", Guid.Empty, Guid.Empty);
											ctlDynamicButtons.DisableAll();
											UpdateButtons();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
										}
									}
								}
							}
						}
					}
				}
				else
				{
					lTWITTER_ID = Sql.ToLong(ViewState["TWITTER_ID"]);
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
			this.Load += new System.EventHandler(this.Page_Load);
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "TwitterMessages";
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				this.AppendDetailViewRelationships(m_sMODULE + ".DetailView", plcSubPanel);
				this.AppendDetailViewFields(m_sMODULE + ".DetailView", tblMain, null);
				ctlDynamicButtons.AppendButtons(m_sMODULE + ".InboundView", Guid.Empty, Guid.Empty);
				UpdateButtons();
			}
		}
		#endregion
	}
}

