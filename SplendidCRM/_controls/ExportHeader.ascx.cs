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
using System.Net;
using System.Text;
using System.Data;
using System.Data.Common;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.Script.Serialization;
using System.Diagnostics;

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for ExportHeader.
	/// </summary>
	public class ExportHeader : SplendidControl
	{
		public CommandEventHandler Command ;
		protected string          sModule         = String.Empty;
		protected string          sTitle          = String.Empty;
		protected DropDownList    lstEXPORT_RANGE ;
		protected DropDownList    lstEXPORT_FORMAT;
		protected Button          btnExport       ;
		
		protected Button          btnPhoneBurnerDialSession       ;
		protected Button          btnPhoneBurnerAuthorize         ;
		protected Button          btnPhoneBurnerAuthorized        ;
		protected Label           lblPhoneBurnerAuthorizedStatus  ;
		protected TextBox         AUTHORIZATION_CODE              ;


		protected void Page_Command(object sender, CommandEventArgs e)
		{
			// 09/07/2020 Paul.  Save PhoneBurner token. 
			if ( e.CommandName == "PhoneBurner.Authorize" )
			{
				// 11/11/2019 Paul.  TLS12 is now requird. 
				if ( !ServicePointManager.SecurityProtocol.HasFlag(SecurityProtocolType.Tls12) )
				{
					ServicePointManager.SecurityProtocol = ServicePointManager.SecurityProtocol | SecurityProtocolType.Tls12;
				}
				try
				{
					string sOAUTH_CLIENT_ID     = Sql.ToString(Application["CONFIG.PhoneBurner.ClientID"    ]);
					string sOAUTH_CLIENT_SECRET = Sql.ToString(Application["CONFIG.PhoneBurner.ClientSecret"]);

					// https://www.phoneburner.com/developer/authentication
					HttpWebRequest objRequest = (HttpWebRequest) WebRequest.Create("https://www.phoneburner.com/oauth/accesstoken");
					objRequest.Headers.Add("cache-control", "no-cache");
					objRequest.KeepAlive         = false;
					objRequest.AllowAutoRedirect = false;
					objRequest.Timeout           = 120000;  // 120 seconds
					objRequest.ContentType       = "application/x-www-form-urlencoded";
					objRequest.Method            = "POST";
					
					string sREDIRECT_URL = Request.Url.Scheme + "://" + Request.Url.Host + Sql.ToString(Application["rootURL"]) + "Administration/PhoneBurner/OAuthLanding.aspx";
					string sData = "grant_type=authorization_code&client_id=" + sOAUTH_CLIENT_ID + "&client_secret=" + sOAUTH_CLIENT_SECRET + "&code=" + AUTHORIZATION_CODE.Text + "&redirect_uri=" + HttpUtility.UrlEncode(sREDIRECT_URL);
					objRequest.ContentLength = sData.Length;
					using ( StreamWriter stm = new StreamWriter(objRequest.GetRequestStream(), System.Text.Encoding.ASCII) )
					{
						stm.Write(sData);
					}
					
					string sResponse = String.Empty;
					// 11/12/2019 Paul.  Cannot connect. 
					// CloudFront: The distribution supports only cachable requests
					using ( HttpWebResponse objResponse = (HttpWebResponse) objRequest.GetResponse() )
					{
						if ( objResponse != null )
						{
							if ( objResponse.StatusCode != HttpStatusCode.OK && objResponse.StatusCode != HttpStatusCode.Found )
							{
								throw(new Exception(objResponse.StatusCode + " " + objResponse.StatusDescription));
							}
							else
							{
								using ( StreamReader stm = new StreamReader(objResponse.GetResponseStream()) )
								{
									sResponse = stm.ReadToEnd();
									// Access tokens expire after 6 hours,
									JavaScriptSerializer json = new JavaScriptSerializer();
									Spring.Social.PhoneBurner.RefreshToken token = json.Deserialize<Spring.Social.PhoneBurner.RefreshToken>(sResponse);
									DateTime dtOAUTH_EXPIRES_AT = DateTime.Now.AddSeconds(token.expires_in);

									SqlProcs.spOAUTH_TOKENS_Update(Security.USER_ID, "PhoneBurner", token.access_token, String.Empty, dtOAUTH_EXPIRES_AT, token.refresh_token);
									Application["CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthAccessToken" ] = token.access_token ;
									Application["CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthRefreshToken"] = token.refresh_token;
									Application["CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthExpiresAt"   ] = dtOAUTH_EXPIRES_AT.ToShortDateString() + " " + dtOAUTH_EXPIRES_AT.ToShortTimeString();
									btnPhoneBurnerDialSession.DataBind();
									btnPhoneBurnerAuthorize  .DataBind();
									// 09/09/2020 Paul.  We need to redirect so that the javascript variable gets set and the SignalR gets initialized. 
									Response.Redirect(Request.RawUrl);
								}
							}
						}
					}
				}
				catch(WebException ex)
				{
					string sResponse = String.Empty;
					using (Stream stream = ex.Response.GetResponseStream() )
					{
						using ( StreamReader reader = new StreamReader(stream) )
						{
							sResponse = reader.ReadToEnd();
						}
					}
					lblPhoneBurnerAuthorizedStatus.Text = ex.Message + " " + sResponse;
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					lblPhoneBurnerAuthorizedStatus.Text = ex.Message;
				}
			}
			else if ( e.CommandName == "PhoneBurner.BeginDialSession" )
			{
				DateTime dtOAUTH_EXPIRES_AT = DateTime.MinValue;
				try
				{
					if ( !Sql.IsEmptyString(Application["CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthExpiresAt"]) )
					{
						dtOAUTH_EXPIRES_AT = Sql.ToDateTime(Application["CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthExpiresAt"]);
					}
				}
				catch
				{
				}
				if ( dtOAUTH_EXPIRES_AT < DateTime.Now )
				{
					Application.Remove("CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthAccessToken" );
					Application.Remove("CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthRefreshToken");
					Application.Remove("CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthExpiresAt"   );
					btnPhoneBurnerDialSession.DataBind();
					btnPhoneBurnerAuthorize  .DataBind();
				}
				string sOAuthAccessToken = Sql.ToString(Application["CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthAccessToken" ]);
				if ( Sql.IsEmptyString(sOAuthAccessToken) )
				{
					lblPhoneBurnerAuthorizedStatus.Text =  L10n.Term("PhoneBurner.ERR_AUTHORIZATION_EXPIRED");
				}
				else if ( Command != null )
				{
					Command(this, e) ;
				}
			}
			else if ( Command != null )
			{
				Command(this, e) ;
			}
		}

		// 02/08/2008 Paul.  We need to determine if the export button has been clicked inside Page_Load. 
		public string ExportUniqueID
		{
			get
			{
				return btnExport.UniqueID;
			}
		}

		// 08/26/2020 Paul.  We need to determine if the PhoneBurner button has been clicked inside Page_Load. 
		public string PhoneBurnerUniqueID
		{
			get
			{
				return btnPhoneBurnerDialSession.UniqueID;
			}
		}

		public string Module
		{
			get
			{
				return sModule;
			}
			set
			{
				sModule = value;
			}
		}

		public string Title
		{
			get
			{
				return sTitle;
			}
			set
			{
				sTitle = value;
			}
		}

		public string ExportRange
		{
			get
			{
				return lstEXPORT_RANGE.SelectedValue;
			}
		}

		public string ExportFormat
		{
			get
			{
				return lstEXPORT_FORMAT.SelectedValue;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( !IsPostBack )
			{
				lstEXPORT_RANGE.Items.Add(new ListItem(L10n.Term(".LBL_LISTVIEW_OPTION_ENTIRE"  ), "All"     ));
				lstEXPORT_RANGE.Items.Add(new ListItem(L10n.Term(".LBL_LISTVIEW_OPTION_CURRENT" ), "Page"    ));
				lstEXPORT_RANGE.Items.Add(new ListItem(L10n.Term(".LBL_LISTVIEW_OPTION_SELECTED"), "Selected"));
				
				lstEXPORT_FORMAT.Items.Add(new ListItem(L10n.Term("Import.LBL_XML_SPREADSHEET"  ), "Excel"   ));
				lstEXPORT_FORMAT.Items.Add(new ListItem(L10n.Term("Import.LBL_XML"              ), "xml"     ));
				lstEXPORT_FORMAT.Items.Add(new ListItem(L10n.Term("Import.LBL_CUSTOM_CSV"       ), "csv"     ));
				lstEXPORT_FORMAT.Items.Add(new ListItem(L10n.Term("Import.LBL_CUSTOM_TAB"       ), "tab"     ));

				// 09/07/2020 Paul.  Cache PhoneBurner token. 
				if ( (Sql.ToBoolean(Application["CONFIG.PhoneBurner.Enabled"]) && Module == Sql.ToString(Application["CONFIG.PhoneBurner.SyncModules"])) )
				{
					// 09/07/2020 Paul.  We have to continually check if the access token has expired. 
					// 09/07/2020 Paul.  This is a heavily used control.  Only re-check if the button is pressed. 
					/*
					if ( !Sql.IsEmptyString(Application["CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthAccessToken"]) )
					{
						DateTime dtOAUTH_EXPIRES_AT = DateTime.MinValue;
						try
						{
							if ( !Sql.IsEmptyString(Application["CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthExpiresAt"]) )
							{
								dtOAUTH_EXPIRES_AT = Sql.ToDateTime(Application["CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthExpiresAt"]);
							}
						}
						catch
						{
						}
						if ( dtOAUTH_EXPIRES_AT < DateTime.Now )
						{
							Application.Remove("CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthAccessToken" );
							Application.Remove("CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthRefreshToken");
							Application.Remove("CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthExpiresAt"   );
						}
					}
					*/
					DateTime dtOAUTH_EXPIRES_AT = SplendidCache.GetOAuthTokenExpiresAt(HttpContext.Current.Application, "PhoneBurner", Security.USER_ID);
				}
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
		}
		#endregion
	}
}

