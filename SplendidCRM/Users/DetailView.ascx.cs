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
using System.Xml;
using System.Diagnostics;

namespace SplendidCRM.Users
{
	/// <summary>
	/// Summary description for DetailView.
	/// </summary>
	public class DetailView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons ctlDynamicButtons;
		protected _controls.DynamicButtons ctlExchangeButtons  ;
		protected _controls.DynamicButtons ctlGoogleAppsButtons;
		protected _controls.DynamicButtons ctlICloudButtons    ;
		protected Administration.ACLRoles.AccessView ctlAccessView;
		// 09/10/2012 Paul.  Add User Signatures. 
		protected Users.Signatures ctlSignatures;
		// 03/08/2007 Paul.  We need to pass the MyAccount flag to the Roles and Teams control. 
		protected Users.Roles  ctlRoles;
		protected Users.Teams  ctlTeams;
		protected Users.Logins ctlLogins;
		// 10/24/2014 Paul.  Add SurveyResults. 
		protected PlaceHolder plcSubPanel      ;

		// main
		protected Guid      gID                             ;
		protected HtmlTable tblMain                         ;
		protected HtmlTable tblMailOptions                  ;
		// 03/25/2011 Paul.  Add support for Google Apps. 
		protected HtmlTable tblGoogleAppsOptions            ;
		protected Panel     pnlGoogleAppsOptions            ;
		// 12/13/2011 Paul.  Add support for Apple iCloud. 
		protected HtmlTable tblICloudOptions                ;
		protected Panel     pnlICloudOptions                ;

		protected Label     txtNAME                         ;
		protected Label     txtUSER_NAME                    ;
		protected Label     txtSTATUS                       ;
		// 11/21/2014 Paul.  Add User Picture. 
		protected HtmlImage imgPICTURE                      ;
		// user_settings
		protected CheckBox  chkIS_ADMIN                     ;
		// 03/16/2010 Paul.  Add IS_ADMIN_DELEGATE. 
		protected CheckBox  chkIS_ADMIN_DELEGATE            ;
		protected CheckBox  chkPORTAL_ONLY                  ;
		protected CheckBox  chkRECEIVE_NOTIFICATIONS        ;
		// 03/04/2011 Paul.  We need to allow the admin to set the flag to force a password change. 
		protected CheckBox  chkSYSTEM_GENERATED_PASSWORD    ;
		// 05/14/2016 Paul.  Display theme in detail view. 
		protected Label     txtTHEME                        ;
		protected Label     txtLANGUAGE                     ;
		protected Label     txtDATEFORMAT                   ;
		protected Label     txtTIMEFORMAT                   ;
		protected Label     txtTIMEZONE                     ;
		protected CheckBox  chkSAVE_QUERY                   ;
		// 02/26/2010 Paul.  Allow users to configure use of tabs. 
		protected CheckBox  chkGROUP_TABS                   ;
		protected CheckBox  chkSUBPANEL_TABS                ;
		protected Label     txtCURRENCY                     ;
		// 08/05/2006 Paul.  Remove stub of unsupported code. Reminder is not supported at this time. 
		//protected CheckBox  chkREMINDER                     ;
		//protected Label     txtREMINDER_TIME                ;

		// 05/06/2009 Paul.  Add DEFAULT_TEAM to support SugarCRM migration. 
		protected TableCell       tdDEFAULT_TEAM_Label            ;
		protected TableCell       tdDEFAULT_TEAM_Field            ;
		protected bool            bMyAccount                      ;

		protected HtmlInputHidden txtOLD_PASSWORD                 ;
		protected HtmlInputHidden txtNEW_PASSWORD                 ;
		protected HtmlInputHidden txtCONFIRM_PASSWORD             ;

		public bool MyAccount
		{
			get
			{
				return bMyAccount;
			}
			set
			{
				bMyAccount = value;
			}
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Edit" )
				{
					if ( bMyAccount )
						Response.Redirect("EditMyAccount.aspx");
					else
						Response.Redirect("edit.aspx?ID=" + gID.ToString());
				}
				else if ( e.CommandName == "Duplicate" )
				{
					Response.Redirect("edit.aspx?DuplicateID=" + gID.ToString());
				}
				else if ( e.CommandName == "Delete" )
				{
					SqlProcs.spUSERS_Delete(gID);
					Response.Redirect("default.aspx");
				}
				else if ( e.CommandName == "Cancel" )
				{
					Response.Redirect("default.aspx");
				}
				else if ( e.CommandName == "Exchange.Sync" || e.CommandName == "Exchange.SyncAll" )
				{
					// 11/27/2021 Paul.  Separate call for Office365. 
					string sSERVER_URL          = Sql.ToString (Context.Application["CONFIG.Exchange.ServerURL"   ]);
					string sOAUTH_CLIENT_ID     = Sql.ToString (Context.Application["CONFIG.Exchange.ClientID"    ]);
					string sOAUTH_CLIENT_SECRET = Sql.ToString (Context.Application["CONFIG.Exchange.ClientSecret"]);
					if ( !Sql.IsEmptyString(sSERVER_URL) && !Sql.IsEmptyString(sOAUTH_CLIENT_ID) && !Sql.IsEmptyString(sOAUTH_CLIENT_SECRET) )
					{
						Spring.Social.Office365.Office365Sync.UserSync User = Spring.Social.Office365.Office365Sync.UserSync.Create(Context, gID, e.CommandName.EndsWith(".SyncAll"));
						if ( User != null )
						{
							ctlDynamicButtons.ErrorText = L10n.Term("Users.LBL_SYNC_BACKGROUND");
							System.Threading.Thread t = new System.Threading.Thread(User.Start);
							t.Start();
						}
					}
					else
					{
						// 12/21/2010 Paul.  Sync buttons on Users.DetailView. 
						ExchangeSync.UserSync User = ExchangeSync.UserSync.Create(Context, gID, e.CommandName.EndsWith(".SyncAll"));
						if ( User != null )
						{
							ctlDynamicButtons.ErrorText = L10n.Term("Users.LBL_SYNC_BACKGROUND");
							System.Threading.Thread t = new System.Threading.Thread(User.Start);
							t.Start();
						}
					}
				}
				else if ( e.CommandName == "GoogleApps.Sync" || e.CommandName == "GoogleApps.SyncAll" )
				{
					// 12/21/2010 Paul.  Sync buttons on Users.DetailView. 
					GoogleSync.UserSync User = GoogleSync.UserSync.Create(Context, gID, e.CommandName.EndsWith(".SyncAll"));
					if ( User != null )
					{
						ctlDynamicButtons.ErrorText = L10n.Term("Users.LBL_SYNC_BACKGROUND");
						System.Threading.Thread t = new System.Threading.Thread(User.Start);
						t.Start();
					}
				}
				else if ( e.CommandName == "iCloud.Sync" || e.CommandName == "iCloud.SyncAll" )
				{
					// 12/21/2010 Paul.  Sync buttons on Users.DetailView. 
					iCloudSync.UserSync User = iCloudSync.UserSync.Create(Context, gID, e.CommandName.EndsWith(".SyncAll"));
					if ( User != null )
					{
						ctlDynamicButtons.ErrorText = L10n.Term("Users.LBL_SYNC_BACKGROUND");
						System.Threading.Thread t = new System.Threading.Thread(User.Start);
						t.Start();
					}
				}
				// 10/09/2020 Paul.  ResetDefaults was never previously coded. 
				else if ( e.CommandName == "ResetDefaults" )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						string sSQL ;
						sSQL = "select *           " + ControlChars.CrLf
						     + "  from vwUSERS_Edit" + ControlChars.CrLf
						     + " where ID = @ID    " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@ID", gID);
							con.Open();
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dtCurrent = new DataTable() )
								{
									da.Fill(dtCurrent);
									if ( dtCurrent.Rows.Count > 0 )
									{
										DataRow rowCurrent = dtCurrent.Rows[0];
										using ( IDbTransaction trn = Sql.BeginTransaction(con) )
										{
											try
											{
												DataTable dtMetadata     = SplendidCache.SqlColumns("USERS");
												DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated("USERS");
												IDbCommand cmdUpdate = null;
												cmdUpdate = SqlProcs.Factory(con, "spUSERS_Update");
												cmdUpdate.Transaction = trn;
												
												foreach ( DataColumn col in rowCurrent.Table.Columns )
												{
													IDbDataParameter par = Sql.FindParameter(cmdUpdate, col.ColumnName);
													if ( par != null )
													{
														switch ( col.ColumnName)
														{
															case "MODIFIED_USER_ID" :  par.Value = Sql.ToDBGuid(Security.USER_ID);  break;
															case "DATE_MODIFIED_UTC":  break;
															case "THEME"            :  par.Value = SplendidDefaults.Theme()     ;  break;
															case "LANG"             :  par.Value = SplendidDefaults.Culture()   ;  break;
															case "DATE_FORMAT"      :  par.Value = SplendidDefaults.DateFormat();  break;
															case "TIME_FORMAT"      :  par.Value = SplendidDefaults.TimeFormat();  break;
															case "TIMEZONE_ID"      :  par.Value = Sql.ToDBGuid(SplendidDefaults.TimeZone()  );  break;
															case "CURRENCY_ID"      :  par.Value = Sql.ToDBGuid(SplendidDefaults.CurrencyID());  break;
															case "SAVE_QUERY"       :  par.Value = Sql.ToBoolean(Application["CONFIG.save_query"   ]);  break;
															case "GROUP_TABS"       :  par.Value = Sql.ToBoolean(Application["CONFIG.group_tabs"   ]);  break;
															case "SUBPANEL_TABS"    :  par.Value = Sql.ToBoolean(Application["CONFIG.subpanel_tabs"]);  break;
															default                 :  par.Value = rowCurrent[col.ColumnName];  break;
														}
													}
												}
												// 09/015/2016 Paul.  This is 10-year old code that makes no sense.  The parent of a user can only be another user, not an Email, Call or Meeting. 
												// 10/09/2020 Paul.  PARENT_TYPE and PARENT_ID are not returned from vwUSERS, but they are required fields in the procedure. 
												Sql.SetParameter(cmdUpdate, "@PARENT_TYPE", String.Empty);
												Sql.SetParameter(cmdUpdate, "@PARENT_ID"  , Guid.Empty  );
												cmdUpdate.ExecuteNonQuery();
												// 10/09/2020 Paul.  Ping the custom table so that custom field audit table gets updated. 
												using ( IDbCommand cmdCSTM = con.CreateCommand() )
												{
													cmdCSTM.Transaction = trn;
													cmdCSTM.CommandType = CommandType.Text;
													cmdCSTM.CommandText  = "update USERS_CSTM  " + ControlChars.CrLf;
													cmdCSTM.CommandText += "   set ID_C =  ID_C" + ControlChars.CrLf;
													cmdCSTM.CommandText += " where ID_C = @ID_C" + ControlChars.CrLf;
													Sql.AddParameter(cmdCSTM, "@ID_C", gID);
													cmdCSTM.ExecuteNonQuery();
												}
												trn.Commit();
											}
											catch(Exception ex)
											{
												trn.Rollback();
												SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
												ctlDynamicButtons .ErrorText = ex.Message;
												//ctlFacebookButtons.ErrorText = ex.Message;
												return;
											}
											if ( Security.USER_ID == gID )
											{
												SplendidInit.LoadUserPreferences(gID, SplendidDefaults.Theme(), SplendidDefaults.Culture());
												Response.Redirect("MyAccount.aspx");
											}
										}
									}
								}
							}
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

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 07/11/2006 Paul.  Users must be able to view and edit their own settings. 
			this.Visible = bMyAccount || (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "view") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			try
			{
				gID = Sql.ToGuid(Request["ID"]);
				if ( bMyAccount )
				{
					// 11/19/2005 Paul.  SugarCRM 3.5.0 allows administrator to duplicate itself. 
					gID = Security.USER_ID;
				}
				ctlAccessView.USER_ID = gID;
				// 04/07/2016 Paul.  Provide a way to hide the access view. 
				ctlAccessView.Visible = Security.IS_ADMIN || !Sql.ToBoolean(Application["CONFIG.hide_user_access_view"]);

				if ( !Sql.IsEmptyString(txtNEW_PASSWORD.Value) )
				{
					bool bValidOldPassword = false;
					if ( !(SplendidCRM.Security.AdminUserAccess(m_sMODULE, "view") >= 0) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							// 07/17/2006 Paul.  The USER_HASH has been removed from the main vwUSERS view to prevent its use in reports. 
							sSQL = "select *                     " + ControlChars.CrLf
							     + "  from vwUSERS_Login         " + ControlChars.CrLf
							     + " where ID        = @ID       " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@ID", gID);
								// 02/13/2009 Paul.  We need to allow a user with a blank password to change his password. 
								if ( !Sql.IsEmptyString(txtOLD_PASSWORD.Value) )
								{
									string sUSER_HASH = Security.HashPassword(txtOLD_PASSWORD.Value);
									cmd.CommandText += "   and USER_HASH = @USER_HASH" + ControlChars.CrLf;
									Sql.AddParameter(cmd, "@USER_HASH", sUSER_HASH);
								}
								else
								{
									// 11/19/2005 Paul.  Handle the special case of the password stored as NULL or empty string. 
									cmd.CommandText += "   and (USER_HASH = '' or USER_HASH is null)" + ControlChars.CrLf;
								}
								con.Open();
								using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
								{
									if ( rdr.Read() )
									{
										bValidOldPassword = true;
									}
								}
							}
						}
						if ( !bValidOldPassword )
						{
							ctlDynamicButtons.ErrorText = L10n.Term("Users.ERR_PASSWORD_INCORRECT_OLD");
						}
					}
					if ( bValidOldPassword || (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0) )
					{
						if ( txtNEW_PASSWORD.Value == txtCONFIRM_PASSWORD.Value )
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
							if ( ctlNEW_PASSWORD_STRENGTH.IsValid(txtNEW_PASSWORD.Value, ref sPASSWORD_REQUIREMENTS) )
							{
								string sUSER_HASH = Security.HashPassword(txtNEW_PASSWORD.Value);
								DbProviderFactory dbf = DbProviderFactories.GetFactory();
								using ( IDbConnection con = dbf.CreateConnection() )
								{
									con.Open();
									string sSQL;
									// 02/20/2011 Paul.  Prevent use of previous passwords. 
									sSQL = "select count(*)                " + ControlChars.CrLf
									     + "  from vwUSERS_PASSWORD_HISTORY" + ControlChars.CrLf
									     + " where USER_ID   = @USER_ID    " + ControlChars.CrLf
									     + "   and USER_HASH = @USER_HASH  " + ControlChars.CrLf;
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.CommandText = sSQL;
										Sql.AddParameter(cmd, "@USER_ID"  , gID       );
										Sql.AddParameter(cmd, "@USER_HASH", sUSER_HASH);
										int nLastPassword = Sql.ToInteger(cmd.ExecuteScalar());
										if ( nLastPassword == 0 )
										{
											SqlProcs.spUSERS_PasswordUpdate(gID, sUSER_HASH);
											// 02/23/2011 Paul.  Clear any existing failures so that the user can login. 
											// This is how an administrator will reset the failure count. 
											SplendidInit.LoginTracking(Application, txtUSER_NAME.Text, true);
											if ( bMyAccount )
												Response.Redirect("MyAccount.aspx");
											else
												Response.Redirect("view.aspx?ID=" + gID.ToString());
										}
										else
										{
											ctlDynamicButtons.ErrorText = L10n.Term("Users.ERR_CANNOT_REUSE_PASSWORD");
										}
									}
								}
							}
							else
							{
								ctlDynamicButtons.ErrorText = sPASSWORD_REQUIREMENTS;
							}
						}
						else
						{
							ctlDynamicButtons.ErrorText = L10n.Term("Users.ERR_REENTER_PASSWORDS") ;
						}
					}
				}
				// 12/22/2011 Paul.  Always read the data so that we can use the Sync buttons. 
				//if ( !IsPostBack )
				if ( true )
				{
					// 05/06/2009 Paul.  Add DEFAULT_TEAM to support SugarCRM migration. 
					// 09/16/2018 Paul.  Create a multi-tenant system. 
					tdDEFAULT_TEAM_Label.Visible = Crm.Config.enable_team_management() && !Crm.Config.enable_multi_tenant_teams();
					tdDEFAULT_TEAM_Field.Visible = tdDEFAULT_TEAM_Label.Visible;
					if ( !Sql.IsEmptyGuid(gID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							sSQL = "select *           " + ControlChars.CrLf
							     + "  from vwUSERS_Edit" + ControlChars.CrLf
							     + " where ID = @ID    " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@ID", gID);
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
											// 11/11/2010 Paul.  Apply Business Rules. 
											this.ApplyDetailViewPreLoadEventRules(m_sMODULE + "." + LayoutDetailView , rdr);
											this.ApplyDetailViewPreLoadEventRules(m_sMODULE + ".MailOptions"      , rdr);
											this.ApplyDetailViewPreLoadEventRules(m_sMODULE + ".GoogleAppsOptions", rdr);
											this.ApplyDetailViewPreLoadEventRules(m_sMODULE + ".iCloudOptions"    , rdr);
											
											ctlDynamicButtons.Title = Sql.ToString(rdr["FULL_NAME"]) + " (" + Sql.ToString(rdr["USER_NAME"]) + ")";
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											
											// main
											txtNAME                 .Text = Sql.ToString(rdr["FULL_NAME"]);
											txtUSER_NAME            .Text = Sql.ToString(rdr["USER_NAME"]);
											txtSTATUS               .Text = Sql.ToString(L10n.Term(".user_status_dom."    , rdr["STATUS"         ]));
											// 11/21/2014 Paul.  Add User Picture. 
											imgPICTURE              .Src  = Sql.ToString(rdr["PICTURE"  ]);
											// user_settings
											chkIS_ADMIN             .Checked = Sql.ToBoolean(rdr["IS_ADMIN"             ]);
											// 03/16/2010 Paul.  Add IS_ADMIN_DELEGATE. 
											chkIS_ADMIN_DELEGATE    .Checked = Sql.ToBoolean(rdr["IS_ADMIN_DELEGATE"    ]);
											chkPORTAL_ONLY          .Checked = Sql.ToBoolean(rdr["PORTAL_ONLY"          ]);
											chkRECEIVE_NOTIFICATIONS.Checked = Sql.ToBoolean(rdr["RECEIVE_NOTIFICATIONS"]);
											try
											{
												// 03/04/2011 Paul.  We need to allow the admin to set the flag to force a password change. 
												chkSYSTEM_GENERATED_PASSWORD.Checked = Sql.ToBoolean(rdr["SYSTEM_GENERATED_PASSWORD"]);
											}
											catch(Exception ex)
											{
												SplendidError.SystemError(new StackTrace(true).GetFrame(0), "SYSTEM_GENERATED_PASSWORD is not defined. " + ex.Message);
											}

											this.AppendDetailViewFields(m_sMODULE + "." + LayoutDetailView , tblMain       , rdr);
											// 08/05/2006 Paul.  MailOptions are populated manually. 
											this.AppendDetailViewFields(m_sMODULE + ".MailOptions", tblMailOptions, null);
											// 03/25/2011 Paul.  Add support for Google Apps. 
											this.AppendDetailViewFields(m_sMODULE + ".GoogleAppsOptions", tblGoogleAppsOptions, rdr);
											pnlGoogleAppsOptions.Visible = (tblGoogleAppsOptions.Rows.Count > 1) && Sql.ToBoolean(Context.Application["CONFIG.GoogleApps.Enabled"]);
											// 12/13/2011 Paul.  Add support for Apple iCloud. 
											this.AppendDetailViewFields(m_sMODULE + ".iCloudOptions", tblICloudOptions, rdr);
											pnlICloudOptions.Visible = (tblICloudOptions.Rows.Count > 1) && Sql.ToBoolean(Context.Application["CONFIG.iCloud.Enabled"]);
											
											// 01/20/2008 Paul.  The mail options panel is manually populated. 
											new DynamicControl(this, "EMAIL1").Text = Sql.ToString (rdr["EMAIL1"]);
											new DynamicControl(this, "EMAIL2").Text = Sql.ToString (rdr["EMAIL2"]);
											// 05/06/2009 Paul.  Add DEFAULT_TEAM to support SugarCRM migration. 
											new DynamicControl(this, "DEFAULT_TEAM_NAME").Text = Sql.ToString (rdr["DEFAULT_TEAM_NAME"]);
											
											// 03/28/2008 Paul.  Need to update
											// 06/05/2015 Paul.  Use separate set of buttons for MyAccount to prevent 2 edit buttons from being in the same list. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView + (bMyAccount ? ".MyAccount" : String.Empty), Guid.Empty, rdr);
											// 12/21/2010 Paul.  Sync buttons on Users.DetailView.
											ctlExchangeButtons  .AppendButtons("Users.ExchangeSync", Guid.Empty, rdr);
											ctlGoogleAppsButtons.AppendButtons("Users.GoogleSync"  , Guid.Empty, rdr);
											ctlICloudButtons    .AppendButtons("Users.iCloudSync"  , Guid.Empty, rdr);
											// 09/03/2008 Paul.  We have two edit buttons and need to disable one of them. 
											// 11/27/2009 Paul.  The user cannot be changed at the offline client. 
											ctlDynamicButtons.ShowButton("EditMyAccount",  bMyAccount && !Utils.IsOfflineClient);
											ctlDynamicButtons.ShowButton("Edit"         , !bMyAccount && !Utils.IsOfflineClient);
											ctlExchangeButtons  .Visible = !Sql.IsEmptyString(Application["CONFIG.Exchange.ServerURL"]);
											ctlGoogleAppsButtons.Visible = !Sql.IsEmptyString(rdr["GOOGLEAPPS_USERNAME"]);
											ctlICloudButtons    .Visible = !Sql.IsEmptyString(rdr["ICLOUD_USERNAME"    ]);
											
											//12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
											/*
											string sUSER_PREFERENCES = Sql.ToString(rdr["USER_PREFERENCES"]);
											if ( !Sql.IsEmptyString(sUSER_PREFERENCES) )
											{
												XmlDocument xml = SplendidInit.InitUserPreferences(sUSER_PREFERENCES);
												try
												{
													// user_settings
													txtLANGUAGE.Text = L10N.NormalizeCulture(XmlUtil.SelectSingleNode(xml, "culture"));
													try
													{
														DataView vwLanguages = new DataView(SplendidCache.Languages());
														vwLanguages.RowFilter = "NAME = '" + txtLANGUAGE.Text + "'";
														if ( vwLanguages.Count > 0 )
															txtLANGUAGE.Text = Sql.ToString(vwLanguages[0]["NATIVE_NAME"]);
													}
													catch(Exception ex)
													{
														SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
													}
													txtDATEFORMAT           .Text    =               XmlUtil.SelectSingleNode(xml, "dateformat"           );
													txtTIMEFORMAT           .Text    =               XmlUtil.SelectSingleNode(xml, "timeformat"           );
													// 08/12/2009 Paul.  A customer wants the ability to turn off the saved searches, both globally and on a per user basis. 
													chkSAVE_QUERY           .Checked = Sql.ToBoolean(XmlUtil.SelectSingleNode(xml, "save_query"           ));
													// 02/26/2010 Paul.  Allow users to configure use of tabs. 
													chkGROUP_TABS           .Checked = Sql.ToBoolean(XmlUtil.SelectSingleNode(xml, "group_tabs"           ));
													chkSUBPANEL_TABS        .Checked = Sql.ToBoolean(XmlUtil.SelectSingleNode(xml, "subpanel_tabs"        ));
													// mail_options
													new DynamicControl(this, "MAIL_FROMNAME"    ).Text    =               XmlUtil.SelectSingleNode(xml, "mail_fromname"        );
													new DynamicControl(this, "MAIL_FROMADDRESS" ).Text    =               XmlUtil.SelectSingleNode(xml, "mail_fromaddress"     );
													new DynamicControl(this, "MAIL_SENDTYPE"    ).Text    =               XmlUtil.SelectSingleNode(xml, "mail_sendtype"        );
													new DynamicControl(this, "MAIL_SMTPSERVER"  ).Text    =               XmlUtil.SelectSingleNode(xml, "mail_smtpserver"      );
													new DynamicControl(this, "MAIL_SMTPPORT"    ).Text    =               XmlUtil.SelectSingleNode(xml, "mail_smtpport"        );
													new DynamicControl(this, "MAIL_SMTPAUTH_REQ").Checked = Sql.ToBoolean(XmlUtil.SelectSingleNode(xml, "mail_smtpauth_req"    ));
													// 07/09/2010 Paul.  Move the SMTP values from USER_PREFERENCES to the main table to make it easier to access. 
													new DynamicControl(this, "MAIL_SMTPUSER"    ).Text    =               Sql.ToString (rdr["MAIL_SMTPUSER"               ]);
													
													string sTIMEZONE = XmlUtil.SelectSingleNode(xml, "timezone");
													DataView vwTimezones = new DataView(SplendidCache.Timezones());
													vwTimezones.RowFilter    = "ID = '" + sTIMEZONE + "'";
													if ( vwTimezones.Count > 0 )
														txtTIMEZONE.Text = Sql.ToString(vwTimezones[0]["NAME"]);

													string sCURRENCY = XmlUtil.SelectSingleNode(xml, "currency_id");
													DataView vwCurrencies = new DataView(SplendidCache.Currencies());
													vwCurrencies.RowFilter    = "ID = '" + sCURRENCY + "'";
													if ( vwCurrencies.Count > 0 )
														txtCURRENCY.Text = Sql.ToString(vwCurrencies[0]["NAME_SYMBOL"]);
													// 08/05/2006 Paul.  Remove stub of unsupported code. Reminder is not supported at this time. 
													//try
													//{
													//	int nREMINDER_TIME = Sql.ToInteger(XmlUtil.SelectSingleNode(xml, "reminder_time"));
													//	if ( nREMINDER_TIME > 0 )
													//	{
													//		txtREMINDER_TIME.Text = L10n.Term(".reminder_time_options." + nREMINDER_TIME.ToString());
													//		chkREMINDER.Checked = true;
													//	}
													//}
													//catch(Exception ex)
													//{
													//	SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
													//}
												}
												catch(Exception ex)
												{
													SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
												}
											}
											*/
											//12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
											try
											{
													txtLANGUAGE.Text = Sql.ToString(rdr["LANG"]);
													try
													{
														DataView vwLanguages = new DataView(SplendidCache.Languages());
														vwLanguages.RowFilter = "NAME = '" + txtLANGUAGE.Text + "'";
														if ( vwLanguages.Count > 0 )
															txtLANGUAGE.Text = Sql.ToString(vwLanguages[0]["NATIVE_NAME"]);
													}
													catch(Exception ex)
													{
														SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
													}
													txtDATEFORMAT           .Text    = Sql.ToString (rdr["DATE_FORMAT"  ]);
													txtTIMEFORMAT           .Text    = Sql.ToString (rdr["TIME_FORMAT"  ]);
													// 08/12/2009 Paul.  A customer wants the ability to turn off the saved searches, both globally and on a per user basis. 
													chkSAVE_QUERY           .Checked = Sql.ToBoolean(rdr["SAVE_QUERY"   ]);
													// 02/26/2010 Paul.  Allow users to configure use of tabs. 
													chkGROUP_TABS           .Checked = Sql.ToBoolean(rdr["GROUP_TABS"   ]);
													chkSUBPANEL_TABS        .Checked = Sql.ToBoolean(rdr["SUBPANEL_TABS"]);
													// mail_options
													// 07/09/2010 Paul.  Move the SMTP values from USER_PREFERENCES to the main table to make it easier to access. 
													new DynamicControl(this, "MAIL_SMTPUSER").Text = Sql.ToString (rdr["MAIL_SMTPUSER"]);
													
													string sTIMEZONE = Sql.ToString(rdr["TIMEZONE_ID"]);
													DataView vwTimezones = new DataView(SplendidCache.Timezones());
													vwTimezones.RowFilter    = "ID = '" + sTIMEZONE + "'";
													if ( vwTimezones.Count > 0 )
														txtTIMEZONE.Text = Sql.ToString(vwTimezones[0]["NAME"]);
													
													string sCURRENCY = Sql.ToString(rdr["CURRENCY_ID"]);
													DataView vwCurrencies = new DataView(SplendidCache.Currencies());
													vwCurrencies.RowFilter    = "ID = '" + sCURRENCY + "'";
													if ( vwCurrencies.Count > 0 )
														txtCURRENCY.Text = Sql.ToString(vwCurrencies[0]["NAME_SYMBOL"]);
													// 05/14/2016 Paul.  Display theme in detail view. 
													txtTHEME                .Text    = Sql.ToString (rdr["THEME"        ]);
											}
											catch(Exception ex)
											{
												SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
											}
											
											// 11/10/2010 Paul.  Apply Business Rules. 
											this.ApplyDetailViewPostLoadEventRules(m_sMODULE + "." + LayoutDetailView , rdr);
											this.ApplyDetailViewPostLoadEventRules(m_sMODULE + ".MailOptions"      , rdr);
											this.ApplyDetailViewPostLoadEventRules(m_sMODULE + ".GoogleAppsOptions", rdr);
											this.ApplyDetailViewPostLoadEventRules(m_sMODULE + ".iCloudOptions"    , rdr);
											// 10/24/2014 Paul.  Add SurveyResults. 
											// 03/09/2015 Paul.  When Show SubPanels is enabled, we have a problem.  So keep AppendDetailViewRelationships in Page_Load as done above. 
											//if ( !IsPostBack )
												this.AppendDetailViewRelationships(m_sMODULE + ".DetailView", plcSubPanel);
										}
										else
										{
											plcSubPanel.Visible = false;
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											// 06/05/2015 Paul.  Use separate set of buttons for MyAccount to prevent 2 edit buttons from being in the same list. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView + (bMyAccount ? ".MyAccount" : String.Empty), Guid.Empty, null);
											// 12/21/2010 Paul.  Sync buttons on Users.DetailView.
											ctlExchangeButtons  .AppendButtons("Users.ExchangeSync", Guid.Empty, null);
											ctlGoogleAppsButtons.AppendButtons("Users.GoogleSync"  , Guid.Empty, null);
											ctlICloudButtons    .AppendButtons("Users.iCloudSync"  , Guid.Empty, null);
											// 09/03/2008 Paul.  We have two edit buttons and need to disable one of them. 
											ctlDynamicButtons.ShowButton("EditMyAccount",  bMyAccount);
											ctlDynamicButtons.ShowButton("Edit"         , !bMyAccount);
											ctlDynamicButtons.DisableAll();
											ctlExchangeButtons  .DisableAll();
											ctlGoogleAppsButtons.DisableAll();
											ctlICloudButtons    .DisableAll();
											ctlExchangeButtons  .Visible = false;
											ctlGoogleAppsButtons.Visible = false;
											ctlICloudButtons    .Visible = false;
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
										}
									}
								}
							}
						}
					}
					else
					{
						// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
						// 06/05/2015 Paul.  Use separate set of buttons for MyAccount to prevent 2 edit buttons from being in the same list. 
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView + (bMyAccount ? ".MyAccount" : String.Empty), Guid.Empty, null);
						// 12/21/2010 Paul.  Sync buttons on Users.DetailView.
						ctlExchangeButtons  .AppendButtons("Users.ExchangeSync", Guid.Empty, null);
						ctlGoogleAppsButtons.AppendButtons("Users.GoogleSync"  , Guid.Empty, null);
						ctlICloudButtons    .AppendButtons("Users.iCloudSync"  , Guid.Empty, null);
						// 09/03/2008 Paul.  We have two edit buttons and need to disable one of them. 
						ctlDynamicButtons.ShowButton("EditMyAccount",  bMyAccount);
						ctlDynamicButtons.ShowButton("Edit"         , !bMyAccount);
						ctlDynamicButtons.DisableAll();
						ctlExchangeButtons  .DisableAll();
						ctlGoogleAppsButtons.DisableAll();
						ctlICloudButtons    .DisableAll();
						ctlExchangeButtons  .Visible = false;
						ctlGoogleAppsButtons.Visible = false;
						ctlICloudButtons    .Visible = false;
						//ctlDynamicButtons.ErrorText = L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + "ID";
					}
				}
				else
				{
					// 11/06/2008 Paul.  The dynamic buttons are already being added in InitializeComponent() when !IsPostBack. 
					//// 03/28/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
					//ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView + (bMyAccount ? ".MyAccount" : String.Empty), Guid.Empty, null);
					//// 09/03/2008 Paul.  We have two edit buttons and need to disable one of them. 
					//ctlDynamicButtons.ShowButton("EditMyAccount",  bMyAccount);
					//ctlDynamicButtons.ShowButton("Edit"         , !bMyAccount);
				}
				if ( bMyAccount )
				{
					// 11/19/2005 Paul.  SugarCRM 3.5.0 allows administrator to duplicate itself. 
					// 03/28/2008 Paul.  An administrator can still duplicate, but not from My Account page. 
					ctlDynamicButtons.ShowButton("Duplicate", false);
				}
				// 12/06/2005 Paul.  The password button is only visible if not windows authentication or Admin.
				// The reason to allow the admin to change a password is so that the admin can prepare to turn off windows authentication. 
				// 11/27/2009 Paul.  The password cannot be changed at the offline client. 
				ctlDynamicButtons.ShowButton("ChangePassword", (!Security.IsWindowsAuthentication() || (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0)) && !Utils.IsOfflineClient);
				// 07/09/2010 Paul.  The user cannot be reset at the offline client. 
				// 10/09/2020 Paul.  ResetDefaults was never previously coded. 
				ctlDynamicButtons.ShowButton("ResetDefaults" , bMyAccount || (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0) && !Utils.IsOfflineClient);
				// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
				//Page.DataBind();
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
			// 04/14/2008 Paul.  Need to handle the button events. 
			ctlDynamicButtons   .Command += new CommandEventHandler(Page_Command);
			ctlExchangeButtons  .Command += new CommandEventHandler(Page_Command);
			ctlGoogleAppsButtons.Command += new CommandEventHandler(Page_Command);
			ctlICloudButtons    .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Users";
			SetMenu(m_sMODULE);

			// 09/10/2012 Paul.  Add User Signatures. 
			ctlSignatures.MyAccount = bMyAccount;
			// 03/08/2007 Paul.  We need to disable the buttons unless the user is an administrator. 
			ctlRoles.MyAccount = bMyAccount;
			ctlTeams.MyAccount = bMyAccount;
			ctlLogins.MyAccount = bMyAccount;
			// 12/22/2011 Paul.  Always read the data so that we can use the Sync buttons. So we don't need to add the buttons inside OnInit(). 
			/*
			if ( IsPostBack )
			{
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView + (bMyAccount ? ".MyAccount" : String.Empty), Guid.Empty, null);
				// 12/21/2010 Paul.  Sync buttons on Users.DetailView.
				ctlExchangeButtons  .AppendButtons("Users.ExchangeSync", Guid.Empty, null);
				ctlGoogleAppsButtons.AppendButtons("Users.GoogleSync"  , Guid.Empty, null);
				ctlICloudButtons    .AppendButtons("Users.iCloudSync"  , Guid.Empty, null);
				// 09/03/2008 Paul.  We have two edit buttons and need to disable one of them. 
				ctlDynamicButtons.ShowButton("EditMyAccount",  bMyAccount);
				ctlDynamicButtons.ShowButton("Edit"         , !bMyAccount);
			}
			*/
			// 10/24/2014 Paul.  Add SurveyResults. 
			// 03/09/2015 Paul.  When Show SubPanels is enabled, we have a problem.  So keep AppendDetailViewRelationships in Page_Load as done above. 
			//if ( IsPostBack )
			//{
			//	this.AppendDetailViewRelationships(m_sMODULE + ".DetailView", plcSubPanel);
			//}
		}
		#endregion
	}
}


