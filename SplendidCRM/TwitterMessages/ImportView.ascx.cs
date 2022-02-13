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

namespace SplendidCRM.TwitterMessages
{
	/// <summary>
	///		Summary description for ImportView.
	/// </summary>
	public class ImportView : SplendidControl
	{
		protected _controls.DynamicButtons ctlDynamicButtons;
		protected _controls.CheckAll       ctlCheckAll      ;

		protected UniqueStringCollection arrSelectFields;
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected Label         lblError       ;
		protected TextBox       txtSEARCH_TEXT ;

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
			bool bSearchVisible  = false;
			bool bSignOutVisible = false;
			string sTwitterConsumerKey    = Sql.ToString(Application["CONFIG.Twitter.ConsumerKey"   ]);
			string sTwitterConsumerSecret = Sql.ToString(Application["CONFIG.Twitter.ConsumerSecret"]);
			if ( !Sql.IsEmptyString(sTwitterConsumerKey) && !Sql.IsEmptyString(sTwitterConsumerSecret) )
			{
				bSignInVisible  = Sql.IsEmptyString(txtOAUTH_VERIFIER.Value);
				bSearchVisible  = !bSignInVisible;
				bSignOutVisible = !bSignInVisible;
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
			ctlDynamicButtons.ShowButton  ("Search" , bSearchVisible );
			ctlDynamicButtons.ShowButton  ("SignIn" , bSignInVisible );
			ctlDynamicButtons.ShowButton  ("SignOut", bSignOutVisible);
			ctlDynamicButtons.ShowButton  ("Import" , bSearchVisible );
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Search" )
				{
					Cache.Remove("Twwiter.Import." + Security.USER_ID.ToString());
					grdMain.CurrentPageIndex = 0;
					try
					{
						Bind(true);
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						lblError.Text += ex.Message;
					}
				}
				else if ( e.CommandName == "SelectAll" )
				{
					ctlCheckAll.SelectAll(vwMain, "TWITTER_ID");
					grdMain.DataBind();
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
				else if ( e.CommandName == "Import" )
				{
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( arrID != null )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							StringBuilder sbErrors = new StringBuilder();
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								int nImported = 0;
								try
								{
									foreach ( string sTWITTER_ID in arrID )
									{
										try
										{
											vwMain.RowFilter = "TWITTER_ID = " + sTWITTER_ID;
											if ( vwMain.Count > 0 )
											{
												nImported++;
												DataRowView row = vwMain[0];
												Guid gID = Guid.Empty;
												SqlProcs.spTWITTER_MESSAGES_Update
													( ref gID
													, Security.USER_ID  // ASSIGNED_USER_ID
													, Security.TEAM_ID  // TEAM_ID
													, String.Empty      // TEAM_SET_LIST
													, Sql.ToString  (row["NAME"                ])
													, Sql.ToString  (row["DESCRIPTION"         ])
													, Sql.ToDateTime(row["DATE_START"          ])
													, Sql.ToString  (row["PARENT_TYPE"         ])
													, Sql.ToGuid    (row["PARENT_ID"           ])
													, "inbound"         // TYPE
													, Sql.ToInt64   (row["TWITTER_ID"          ])
													, Sql.ToInt64   (row["TWITTER_USER_ID"     ])
													, Sql.ToString  (row["TWITTER_FULL_NAME"   ])
													, Sql.ToString  (row["TWITTER_SCREEN_NAME" ])
													, Sql.ToInt64   (row["ORIGINAL_ID"         ])
													, Sql.ToInt64   (row["ORIGINAL_USER_ID"    ])
													, Sql.ToString  (row["ORIGINAL_FULL_NAME"  ])
													, Sql.ToString  (row["ORIGINAL_SCREEN_NAME"])
													// 05/17/2017 Paul.  Add Tags module. 
													, String.Empty  // TAG_SET_NAME
													// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
													, false         // IS_PRIVATE
													// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
													, String.Empty  // ASSIGNED_SET_LIST
													, trn
													);
											}
										}
										catch(Exception ex)
										{
											sbErrors.AppendLine("Error importing Tweets " + sTWITTER_ID + ".  " + Utils.ExpandException(ex) + "<br>");
										}
									}
									if ( sbErrors.Length > 0 )
									{
										throw(new Exception(sbErrors.ToString()));
									}
									trn.Commit();
									ctlDynamicButtons.ErrorText = nImported.ToString()   + " " + L10n.Term("Import.LBL_SUCCESSFULLY" );
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0),  Utils.ExpandException(ex));
									ctlDynamicButtons.ErrorText = Utils.ExpandException(ex);
								}
							}
						}
					}
					else
					{
						ctlDynamicButtons.ErrorText = L10n.Term("Import.LBL_NOTHING");
					}
					vwMain.RowFilter = "";
					grdMain.DataBind();
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void Bind(bool bBind)
		{
			if ( !Sql.IsEmptyString(Context.Application["CONFIG.Twitter.ConsumerKey"]) && !Sql.IsEmptyString(Context.Application["CONFIG.Twitter.ConsumerSecret"]) )
			{
				DataTable dt = Cache.Get("Twwiter.Import." + Security.USER_ID.ToString()) as DataTable;
				if ( dt == null )
				{
					Spring.Social.Twitter.Api.SearchResults result = null;
					try
					{
						if ( !Utils.IsOfflineClient && !Sql.IsEmptyString(txtSEARCH_TEXT.Text) )
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
								result = twitter.SearchOperations.SearchAsync(txtSEARCH_TEXT.Text, 100).Result;
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
									result = twitter.SearchOperations.SearchAsync(txtSEARCH_TEXT.Text, 100).Result;
								}
								else
								{
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
									ctlDynamicButtons.ErrorText = Utils.ExpandException(ex);
									UpdateButtons();
									return;
								}
							}
							if ( result != null )
							{
								dt = SocialImport.CreateTable(result);
								Cache.Insert("Twwiter.Import." + Security.USER_ID.ToString(), dt, null, DateTime.Now.AddMinutes(1), System.Web.Caching.Cache.NoSlidingExpiration);
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						ctlDynamicButtons.ErrorText = ex.Message;
					}
				}
				
				if ( dt != null )
				{
					vwMain = dt.DefaultView;
					grdMain.DataSource = vwMain ;
					if ( bBind )
					{
						grdMain.SortColumn = "DATE_START";
						grdMain.SortOrder  = "desc" ;
						grdMain.ApplySort();
						grdMain.DataBind();
					}
				}
				ctlDynamicButtons.EnableButton("Import" , (vwMain != null && vwMain.Count > 0) );
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(m_sMODULE + ".LBL_LIST_FORM_TITLE"));
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "list") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				if ( !IsPostBack )
				{
					Cache.Remove("Twwiter.Import." + Security.USER_ID.ToString());
					
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
				}
				UpdateButtons();
				Bind(!IsPostBack);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
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
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			ctlCheckAll      .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "TwitterMessages";
			SetMenu(m_sMODULE);
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("NAME");
			this.AppendGridColumns(grdMain, m_sMODULE + ".ImportView", arrSelectFields);
			ctlDynamicButtons.AppendButtons(m_sMODULE + ".ImportView", Guid.Empty, Guid.Empty);
		}
		#endregion
	}
}

