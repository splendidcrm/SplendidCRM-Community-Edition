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
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

namespace SplendidCRM.Administration.Users
{
	/// <summary>
	/// Summary description for Password.
	/// </summary>
	public class Password : SplendidPage
	{
		protected SplendidPassword ctlNEW_PASSWORD_STRENGTH;

		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( !IsPostBack )
			{
				ctlNEW_PASSWORD_STRENGTH.PreferredPasswordLength             = Crm.Password.PreferredPasswordLength            ;
				ctlNEW_PASSWORD_STRENGTH.MinimumLowerCaseCharacters          = Crm.Password.MinimumLowerCaseCharacters         ;
				ctlNEW_PASSWORD_STRENGTH.MinimumUpperCaseCharacters          = Crm.Password.MinimumUpperCaseCharacters         ;
				ctlNEW_PASSWORD_STRENGTH.MinimumNumericCharacters            = Crm.Password.MinimumNumericCharacters           ;
				ctlNEW_PASSWORD_STRENGTH.MinimumSymbolCharacters             = Crm.Password.MinimumSymbolCharacters            ;
				ctlNEW_PASSWORD_STRENGTH.PrefixText                          = Crm.Password.PrefixText                         ;
				ctlNEW_PASSWORD_STRENGTH.TextStrengthDescriptions            = Crm.Password.TextStrengthDescriptions           ;
				ctlNEW_PASSWORD_STRENGTH.SymbolCharacters                    = Crm.Password.SymbolCharacters                   ;
				ctlNEW_PASSWORD_STRENGTH.ComplexityNumber                    = Crm.Password.ComplexityNumber                   ;

				ctlNEW_PASSWORD_STRENGTH.MessageRemainingCharacters          = L10n.Term("Users.LBL_PASSWORD_REMAINING_CHARACTERS");
				ctlNEW_PASSWORD_STRENGTH.MessageRemainingNumbers             = L10n.Term("Users.LBL_PASSWORD_REMAINING_NUMBERS"   );
				ctlNEW_PASSWORD_STRENGTH.MessageRemainingLowerCase           = L10n.Term("Users.LBL_PASSWORD_REMAINING_LOWERCASE" );
				ctlNEW_PASSWORD_STRENGTH.MessageRemainingUpperCase           = L10n.Term("Users.LBL_PASSWORD_REMAINING_UPPERCASE" );
				ctlNEW_PASSWORD_STRENGTH.MessageRemainingMixedCase           = L10n.Term("Users.LBL_PASSWORD_REMAINING_MIXEDCASE" );
				ctlNEW_PASSWORD_STRENGTH.MessageRemainingSymbols             = L10n.Term("Users.LBL_PASSWORD_REMAINING_SYMBOLS"   );
				ctlNEW_PASSWORD_STRENGTH.MessageSatisfied                    = L10n.Term("Users.LBL_PASSWORD_SATISFIED"           );
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
		}
		#endregion
	}
}

