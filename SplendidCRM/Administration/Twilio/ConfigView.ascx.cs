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
using System.Net;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Administration.Twilio
{
	/// <summary>
	///		Summary description for ConfigView.
	/// </summary>
	public class ConfigView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		protected _controls.DynamicButtons ctlFooterButtons ;

		protected TextBox      ACCOUNT_SID             ;
		protected TextBox      AUTH_TOKEN              ;
		protected TextBox      FROM_PHONE              ;
		protected CheckBox     LOG_INBOUND_MESSAGES    ;
		protected Label        MESSAGE_REQUEST_URL     ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Save" || e.CommandName == "Test" )
			{
				try
				{
					ACCOUNT_SID.Text = ACCOUNT_SID.Text.Trim();
					AUTH_TOKEN .Text = AUTH_TOKEN .Text.Trim();
					FROM_PHONE .Text = FROM_PHONE .Text.Trim();
					
					if ( Page.IsValid )
					{
						if ( e.CommandName == "Test" )
						{
							string sResult = TwilioManager.ValidateLogin(Application, ACCOUNT_SID.Text, AUTH_TOKEN.Text);
							if ( Sql.IsEmptyString(sResult) )
								ctlDynamicButtons.ErrorText = L10n.Term("Twilio.LBL_CONNECTION_SUCCESSFUL");
							else
								ctlDynamicButtons.ErrorText = String.Format(L10n.Term("Twilio.ERR_FAILED_TO_CONNECT"), sResult);
						}
						else if ( e.CommandName == "Save" )
						{
							Application["CONFIG.Twilio.AccountSID"        ] = ACCOUNT_SID.Text;
							Application["CONFIG.Twilio.AuthToken"         ] = AUTH_TOKEN .Text;
							Application["CONFIG.Twilio.FromPhone"         ] = FROM_PHONE .Text;
							Application["CONFIG.Twilio.LogInboundMessages"] = LOG_INBOUND_MESSAGES.Checked;
							
							SqlProcs.spCONFIG_Update("system", "Twilio.AccountSID"        , Sql.ToString(Application["CONFIG.Twilio.AccountSID"        ]));
							SqlProcs.spCONFIG_Update("system", "Twilio.AuthToken"         , Sql.ToString(Application["CONFIG.Twilio.AuthToken"         ]));
							SqlProcs.spCONFIG_Update("system", "Twilio.FromPhone"         , Sql.ToString(Application["CONFIG.Twilio.FromPhone"         ]));
							SqlProcs.spCONFIG_Update("system", "Twilio.LogInboundMessages", Sql.ToString(Application["CONFIG.Twilio.LogInboundMessages"]));
							
							DbProviderFactory dbf = DbProviderFactories.GetFactory();
							using ( IDbConnection con = dbf.CreateConnection() )
							{
								con.Open();
								string sSQL ;
								int nOutboundRecords = 0;
								sSQL = "select count(*)           " + ControlChars.CrLf
								     + "  from vwOUTBOUND_SMS_Edit" + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									nOutboundRecords = Sql.ToInteger(cmd.ExecuteScalar());
								}
								if ( nOutboundRecords == 0 )
								{
									using ( IDbTransaction trn = Sql.BeginTransaction(con) )
									{
										try
										{
											Guid gID = Guid.Empty;
											SqlProcs.spOUTBOUND_SMS_Update
												( ref gID
												, "Twilio Default"
												, Guid.Empty
												, FROM_PHONE.Text
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
							}
							Response.Redirect("../default.aspx");
						}
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					ctlDynamicButtons.ErrorText = ex.Message;
					return;
				}
			}
			else if ( e.CommandName == "Cancel" )
			{
				Response.Redirect("../default.aspx");
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term("Twilio.LBL_TWILIO_SETTINGS"));
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
			{
				Parent.DataBind();
				return;
			}

			try
			{
				if ( !IsPostBack )
				{
					ctlDynamicButtons.AppendButtons(m_sMODULE + ".EditView", Guid.Empty, null);
					ctlFooterButtons .AppendButtons(m_sMODULE + ".EditView", Guid.Empty, null);

					ACCOUNT_SID         .Text    = Sql.ToString (Application["CONFIG.Twilio.AccountSID"        ]);
					AUTH_TOKEN          .Text    = Sql.ToString (Application["CONFIG.Twilio.AuthToken"         ]);
					FROM_PHONE          .Text    = Sql.ToString (Application["CONFIG.Twilio.FromPhone"         ]);
					LOG_INBOUND_MESSAGES.Checked = Sql.ToBoolean(Application["CONFIG.Twilio.LogInboundMessages"]);

					// http://www.twilio.com/docs/api/twiml
					// http://www.twilio.com/docs/api/twiml/sms/message
					string sSiteURL = Crm.Config.SiteURL(Application);
					MESSAGE_REQUEST_URL.Text = sSiteURL + "TwiML.aspx";
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
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			ctlFooterButtons .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Twilio";
			SetAdminMenu(m_sMODULE);
			if ( IsPostBack )
			{
				ctlDynamicButtons.AppendButtons(m_sMODULE + ".EditView", Guid.Empty, null);
				ctlFooterButtons .AppendButtons(m_sMODULE + ".EditView", Guid.Empty, null);
			}
		}
		#endregion
	}
}
