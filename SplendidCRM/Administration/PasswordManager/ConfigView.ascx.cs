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

namespace SplendidCRM.Administration.PasswordManager
{
	/// <summary>
	///		Summary description for ConfigView.
	/// </summary>
	public class ConfigView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		protected _controls.DynamicButtons ctlFooterButtons ;

		protected TextBox      PREFERRED_PASSWORD_LENGTH    ;
		protected TextBox      MINIMUM_LOWER_CASE_CHARACTERS;
		protected TextBox      MINIMUM_UPPER_CASE_CHARACTERS;
		protected TextBox      MINIMUM_NUMERIC_CHARACTERS   ;
		protected TextBox      MINIMUM_SYMBOL_CHARACTERS    ;
		protected TextBox      SYMBOL_CHARACTERS            ;
		protected TextBox      COMPLEXITY_NUMBER            ;
		protected TextBox      HISTORY_MAXIMUM              ;
		protected TextBox      LOGIN_LOCKOUT_COUNT          ;
		protected TextBox      EXPIRATION_DAYS              ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Save" )
			{
				try
				{
					if ( Page.IsValid )
					{
						Application["CONFIG.Password.PreferredPasswordLength"   ] = Sql.ToInteger(PREFERRED_PASSWORD_LENGTH    .Text);
						Application["CONFIG.Password.MinimumLowerCaseCharacters"] = Sql.ToInteger(MINIMUM_LOWER_CASE_CHARACTERS.Text);
						Application["CONFIG.Password.MinimumUpperCaseCharacters"] = Sql.ToInteger(MINIMUM_UPPER_CASE_CHARACTERS.Text);
						Application["CONFIG.Password.MinimumNumericCharacters"  ] = Sql.ToInteger(MINIMUM_NUMERIC_CHARACTERS   .Text);
						Application["CONFIG.Password.MinimumSymbolCharacters"   ] = Sql.ToInteger(MINIMUM_SYMBOL_CHARACTERS    .Text);
						Application["CONFIG.Password.SymbolCharacters"          ] = SYMBOL_CHARACTERS.Text.Trim();
						Application["CONFIG.Password.ComplexityNumber"          ] = Sql.ToInteger(COMPLEXITY_NUMBER            .Text);
						Application["CONFIG.Password.HistoryMaximum"            ] = Sql.ToInteger(HISTORY_MAXIMUM              .Text);
						Application["CONFIG.Password.LoginLockoutCount"         ] = Sql.ToInteger(LOGIN_LOCKOUT_COUNT          .Text);
						Application["CONFIG.Password.ExpirationDays"            ] = Sql.ToInteger(EXPIRATION_DAYS              .Text);

						SqlProcs.spCONFIG_Update("security", "Password.PreferredPasswordLength"   , Sql.ToString(Application["CONFIG.Password.PreferredPasswordLength"   ]));
						SqlProcs.spCONFIG_Update("security", "Password.MinimumLowerCaseCharacters", Sql.ToString(Application["CONFIG.Password.MinimumLowerCaseCharacters"]));
						SqlProcs.spCONFIG_Update("security", "Password.MinimumUpperCaseCharacters", Sql.ToString(Application["CONFIG.Password.MinimumUpperCaseCharacters"]));
						SqlProcs.spCONFIG_Update("security", "Password.MinimumNumericCharacters"  , Sql.ToString(Application["CONFIG.Password.MinimumNumericCharacters"  ]));
						SqlProcs.spCONFIG_Update("security", "Password.MinimumSymbolCharacters"   , Sql.ToString(Application["CONFIG.Password.MinimumSymbolCharacters"   ]));
						SqlProcs.spCONFIG_Update("security", "Password.SymbolCharacters"          , Sql.ToString(Application["CONFIG.Password.SymbolCharacters"          ]));
						SqlProcs.spCONFIG_Update("security", "Password.ComplexityNumber"          , Sql.ToString(Application["CONFIG.Password.ComplexityNumber"          ]));
						SqlProcs.spCONFIG_Update("security", "Password.HistoryMaximum"            , Sql.ToString(Application["CONFIG.Password.HistoryMaximum"            ]));
						SqlProcs.spCONFIG_Update("security", "Password.LoginLockoutCount"         , Sql.ToString(Application["CONFIG.Password.LoginLockoutCount"         ]));
						SqlProcs.spCONFIG_Update("security", "Password.ExpirationDays"            , Sql.ToString(Application["CONFIG.Password.ExpirationDays"            ]));
						Response.Redirect("../default.aspx");
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
			SetPageTitle(L10n.Term("Administration.LBL_MANAGE_PASSWORD_TITLE"));
			this.Visible = (SplendidCRM.Security.AdminUserAccess("config", "edit") >= 0);
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

					PREFERRED_PASSWORD_LENGTH    .Text = Sql.ToString(Application["CONFIG.Password.PreferredPasswordLength"   ]);
					MINIMUM_LOWER_CASE_CHARACTERS.Text = Sql.ToString(Application["CONFIG.Password.MinimumLowerCaseCharacters"]);
					MINIMUM_UPPER_CASE_CHARACTERS.Text = Sql.ToString(Application["CONFIG.Password.MinimumUpperCaseCharacters"]);
					MINIMUM_NUMERIC_CHARACTERS   .Text = Sql.ToString(Application["CONFIG.Password.MinimumNumericCharacters"  ]);
					MINIMUM_SYMBOL_CHARACTERS    .Text = Sql.ToString(Application["CONFIG.Password.MinimumSymbolCharacters"   ]);
					SYMBOL_CHARACTERS            .Text = Sql.ToString(Application["CONFIG.Password.SymbolCharacters"          ]);
					COMPLEXITY_NUMBER            .Text = Sql.ToString(Application["CONFIG.Password.ComplexityNumber"          ]);
					HISTORY_MAXIMUM              .Text = Sql.ToString(Application["CONFIG.Password.HistoryMaximum"            ]);
					LOGIN_LOCKOUT_COUNT          .Text = Sql.ToString(Application["CONFIG.Password.LoginLockoutCount"         ]);
					EXPIRATION_DAYS              .Text = Sql.ToString(Application["CONFIG.Password.ExpirationDays"            ]);
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
			m_sMODULE = "PasswordManager";
			// 07/24/2010 Paul.  We need an admin flag for the areas that don't have a record in the Modules table. 
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
