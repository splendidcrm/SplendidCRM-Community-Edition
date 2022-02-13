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
using System.Data;
using System.Data.Common;
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Xml;
using System.Globalization;
using System.Threading;
using System.Diagnostics;

namespace SplendidCRM.Users
{
	/// <summary>
	///		Summary description for PasswordExpired.
	/// </summary>
	public class PasswordExpiredView : SplendidControl
	{
		protected SplendidPassword ctlNEW_PASSWORD_STRENGTH;
		protected _controls.ModuleHeader ctlModuleHeader;

		protected Label           lblError                        ;
		protected TableRow        trOLD_PASSWORD                  ;
		protected TextBox         txtOLD_PASSWORD                 ;
		protected TextBox         txtNEW_PASSWORD                 ;
		protected TextBox         txtCONFIRM_PASSWORD             ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "ChangePassword" )
				{
					if ( txtNEW_PASSWORD.Text == txtCONFIRM_PASSWORD.Text )
					{
						SplendidPassword ctlNEW_PASSWORD_STRENGTH = new SplendidPassword();
						ctlNEW_PASSWORD_STRENGTH.PreferredPasswordLength             = Crm.Password.PreferredPasswordLength            ;
						ctlNEW_PASSWORD_STRENGTH.MinimumLowerCaseCharacters          = Crm.Password.MinimumLowerCaseCharacters         ;
						ctlNEW_PASSWORD_STRENGTH.MinimumUpperCaseCharacters          = Crm.Password.MinimumUpperCaseCharacters         ;
						ctlNEW_PASSWORD_STRENGTH.MinimumNumericCharacters            = Crm.Password.MinimumNumericCharacters           ;
						ctlNEW_PASSWORD_STRENGTH.MinimumSymbolCharacters             = Crm.Password.MinimumSymbolCharacters            ;
						ctlNEW_PASSWORD_STRENGTH.PrefixText                          = Crm.Password.PrefixText                         ;
						ctlNEW_PASSWORD_STRENGTH.TextStrengthDescriptions            = Crm.Password.TextStrengthDescriptions           ;
						ctlNEW_PASSWORD_STRENGTH.SymbolCharacters                    = Crm.Password.SymbolCharacters                   ;
						ctlNEW_PASSWORD_STRENGTH.ComplexityNumber                    = Crm.Password.ComplexityNumber                   ;
						string sPASSWORD_REQUIREMENTS = String.Empty;
						if ( ctlNEW_PASSWORD_STRENGTH.IsValid(txtNEW_PASSWORD.Text, ref sPASSWORD_REQUIREMENTS) )
						{
							string sUSER_HASH = Security.HashPassword(txtNEW_PASSWORD.Text);
							DbProviderFactory dbf = DbProviderFactories.GetFactory();
							using ( IDbConnection con = dbf.CreateConnection() )
							{
								con.Open();
								string sSQL;
								if ( trOLD_PASSWORD.Visible )
								{
									sSQL = "select *              " + ControlChars.CrLf
									     + "  from vwUSERS_Login  " + ControlChars.CrLf
									     + " where ID        = @ID" + ControlChars.CrLf;
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.CommandText = sSQL;
										Sql.AddParameter(cmd, "@ID", Security.USER_ID);
										// 02/13/2009 Paul.  We need to allow a user with a blank password to change his password. 
										if ( !Sql.IsEmptyString(txtOLD_PASSWORD.Text) )
										{
											cmd.CommandText += "   and USER_HASH = @USER_HASH" + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@USER_HASH", sUSER_HASH);
										}
										else
										{
											// 11/19/2005 Paul.  Handle the special case of the password stored as NULL or empty string. 
											cmd.CommandText += "   and (USER_HASH = '' or USER_HASH is null)" + ControlChars.CrLf;
										}
										using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
										{
											if ( !rdr.Read() )
											{
												lblError.Text = L10n.Term("Users.ERR_PASSWORD_INCORRECT_OLD");
												return;
											}
										}
									}
								}
								// 02/20/2011 Paul.  Prevent use of previous passwords. 
								sSQL = "select count(*)                " + ControlChars.CrLf
								     + "  from vwUSERS_PASSWORD_HISTORY" + ControlChars.CrLf
								     + " where USER_ID   = @USER_ID    " + ControlChars.CrLf
								     + "   and USER_HASH = @USER_HASH  " + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@USER_ID"  , Security.USER_ID);
									Sql.AddParameter(cmd, "@USER_HASH", sUSER_HASH      );
									int nLastPassword = Sql.ToInteger(cmd.ExecuteScalar());
									if ( nLastPassword == 0 )
									{
										SqlProcs.spUSERS_PasswordUpdate(Security.USER_ID, sUSER_HASH);
										// 03/05/2011 Paul.  Make sure to clear the system generated flag, otherwise we will be redirected back here. 
										Session["SYSTEM_GENERATED_PASSWORD"] = false;
										LoginRedirect();
									}
									else
									{
										lblError.Text = L10n.Term("Users.ERR_CANNOT_REUSE_PASSWORD");
									}
								}
							}
						}
						else
						{
							lblError.Text = sPASSWORD_REQUIREMENTS;
						}
					}
					else
					{
						lblError.Text = L10n.Term("Users.ERR_REENTER_PASSWORDS") ;
					}
				}
			}
			catch(Exception ex)
			{
				lblError.Text = ex.Message;
				return;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 08/18/2011 Paul.  Make sure to use the terminology table for the browser title. 
			SetPageTitle(L10n.Term(".LBL_BROWSER_TITLE"));
			try
			{
				if ( !IsPostBack )
				{
					trOLD_PASSWORD.Visible = !Sql.ToBoolean(Session["SYSTEM_GENERATED_PASSWORD"]);

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
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
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

