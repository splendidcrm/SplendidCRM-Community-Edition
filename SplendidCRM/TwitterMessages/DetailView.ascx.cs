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
	/// Summary description for DetailView.
	/// </summary>
	public class DetailView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons ctlDynamicButtons;

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
			// 10/10/2017 Paul.  Use a single try/catch. 
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
					SqlProcs.spTWITTER_MESSAGES_Delete(gID);
					Response.Redirect("default.aspx");
				}
				else if ( e.CommandName == "Cancel" )
				{
					Response.Redirect("default.aspx");
				}
				else if ( e.CommandName == "Retweet" )
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
				else if ( e.CommandName == "SignOut" )
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
				else if ( e.CommandName == "OAuthToken" )
				{
					if ( !Sql.IsEmptyString(txtOAUTH_TOKEN.Value) && !Sql.IsEmptyString(txtOAUTH_SECRET.Value) && !Sql.IsEmptyString(txtOAUTH_VERIFIER.Value) )
					{
						SqlProcs.spOAUTHKEYS_Update(Security.USER_ID, "Twitter", txtOAUTH_TOKEN.Value, txtOAUTH_SECRET.Value, txtOAUTH_VERIFIER.Value);
					}
					UpdateButtons();
				}
				// 10/10/2017 Paul.  Add Archive access right. 
				else if ( e.CommandName == "Archive.MoveData" )
				{
					ArchiveUtils archive = new ArchiveUtils(Context);
					ctlDynamicButtons.ErrorText = archive.MoveData(m_sMODULE, gID);
					if ( Sql.IsEmptyString(ctlDynamicButtons.ErrorText) )
						Response.Redirect("view.aspx?ID=" + gID.ToString() + "&ArchiveView=1");
				}
				else if ( e.CommandName == "Archive.RecoverData" )
				{
					ArchiveUtils archive = new ArchiveUtils(Context);
					ctlDynamicButtons.ErrorText = archive.RecoverData(m_sMODULE, gID);
					if ( Sql.IsEmptyString(ctlDynamicButtons.ErrorText) )
						Response.Redirect("view.aspx?ID=" + gID.ToString());
				}
				else
				{
					throw(new Exception("Unknown command: " + e.CommandName));
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
							// 10/08/2017 Paul.  Add Archive access right. 
							// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
							sSQL = "select *"               + ControlChars.CrLf
							     + Sql.AppendRecordLevelSecurityField(m_sMODULE, "view", m_sVIEW_NAME)
							     + "  from " + m_sVIEW_NAME + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								// 10/08/2017 Paul.  Add Archive access right. 
								Security.Filter(cmd, m_sMODULE, (ArchiveViewExists() ? "archive" : "view"));
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
										// 10/31/2017 Paul.  Provide a way to inject Record level ACL. 
										if ( dtCurrent.Rows.Count > 0 && (SplendidCRM.Security.GetRecordAccess(dtCurrent.Rows[0], m_sMODULE, "view", "ASSIGNED_USER_ID") >= 0) )
										{
											DataRow rdr = dtCurrent.Rows[0];
											this.ApplyDetailViewPreLoadEventRules(m_sMODULE + "." + LayoutDetailView, rdr);
											
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											// 10/10/2017 Paul.  Don't update tracker in ArchiveView. 
											if ( !ArchiveView() )
												Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											
											this.AppendDetailViewRelationships(m_sMODULE + "." + LayoutDetailView, plcSubPanel);
											this.AppendDetailViewFields(m_sMODULE + "." + LayoutDetailView, tblMain, rdr);
											
											lTWITTER_ID = Sql.ToLong(rdr["TWITTER_ID"]);
											ViewState["TWITTER_ID"] = lTWITTER_ID;
											string sEMAIL_TYPE = Sql.ToString(rdr["TYPE"]).ToLower();
											ctlDynamicButtons.EnableModuleLabel = false;
											switch ( sEMAIL_TYPE )
											{
												case "inbound":
													Response.Redirect("inbound.aspx?ID=" + gID.ToString());
													break;
												case "out":
													ctlDynamicButtons.Title = "<a href=\"default.aspx\">" + L10n.Term("TwitterMessages.LBL_LIST_FORM_SENT_TITLE") + "</a><span class=\"pointer\">&raquo;</span>" + ctlDynamicButtons.Title;
													ctlDynamicButtons.ShowButton("Edit"     , false);
													ctlDynamicButtons.ShowButton("Duplicate", false);
													break;
												case "sent":
													Response.Redirect("inbound.aspx?ID=" + gID.ToString());
													break;
												default:
													sEMAIL_TYPE = "draft";
													Response.Redirect("edit.aspx?ID=" + gID.ToString());
													break;
											}
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
											Page.Items["ASSIGNED_USER_ID"] = Sql.ToGuid(rdr["ASSIGNED_USER_ID"]);
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											// 10/10/2017 Paul.  Add Archive access right. 
											int nACLACCESS_Archive = Security.GetUserAccess(m_sMODULE, "archive");
											ctlDynamicButtons.ShowButton("Archive.MoveData"   , (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) && !ArchiveView() && ArchiveEnabled());
											ctlDynamicButtons.ShowButton("Archive.RecoverData", (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) &&  ArchiveView() && ArchiveEnabled());
											// 10/31/2017 Paul.  Provide a way to inject Record level ACL. 
											ctlDynamicButtons.ShowButton("Duplicate", (SplendidCRM.Security.GetRecordAccess(rdr, m_sMODULE, "edit"  , "ASSIGNED_USER_ID") >= 0) && ctlDynamicButtons.IsButtonVisible("Duplicate"));
											ctlDynamicButtons.ShowButton("Edit"     , (SplendidCRM.Security.GetRecordAccess(rdr, m_sMODULE, "edit"  , "ASSIGNED_USER_ID") >= 0) && ctlDynamicButtons.IsButtonVisible("Edit"     ));
											ctlDynamicButtons.ShowButton("Delete"   , (SplendidCRM.Security.GetRecordAccess(rdr, m_sMODULE, "delete", "ASSIGNED_USER_ID") >= 0) && ctlDynamicButtons.IsButtonVisible("Delete"   ));
											UpdateButtons();
											this.ApplyDetailViewPostLoadEventRules(m_sMODULE + "." + LayoutDetailView, rdr);
										}
										else
										{
											plcSubPanel.Visible = false;
											
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
											UpdateButtons();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
										}
									}
								}
							}
						}
					}
					else
					{
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
						ctlDynamicButtons.DisableAll();
						UpdateButtons();
					}
				}
				else
				{
					// 06/07/2015 Paul.  Seven theme DetailView.master uses an UpdatePanel, so we need to recall the title. 
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
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
			// 10/08/2017 Paul.  Add Archive access right. 
			string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
			m_sVIEW_NAME = "vw" + sTABLE_NAME;
			if ( ArchiveViewExists() )
				m_sVIEW_NAME += "_ARCHIVE";
			else
				m_sVIEW_NAME += "_Edit";
			this.LayoutDetailView = (ArchiveViewExists() ? "ArchiveView" : "DetailView");
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				this.AppendDetailViewRelationships(m_sMODULE + "." + LayoutDetailView, plcSubPanel);
				this.AppendDetailViewFields(m_sMODULE + "." + LayoutDetailView, tblMain, null);
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
				UpdateButtons();
			}
		}
		#endregion
	}
}

