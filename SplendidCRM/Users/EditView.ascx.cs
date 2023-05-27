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
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Xml;
using System.Globalization;
using System.Threading;
using System.Diagnostics;

namespace SplendidCRM.Users
{
	/// <summary>
	///		Summary description for EditView.
	/// </summary>
	public class EditView : SplendidControl
	{
		#region Properties
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		// 01/13/2010 Paul.  Add footer buttons. 
		protected _controls.DynamicButtons ctlFooterButtons ;
		protected Users.FacebookButtons    ctlFacebookButtons;

		// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
		//private const string sEMPTY_PASSWORD = "******";
		protected Guid            gID                             ;
		protected HtmlTable       tblMain                         ;
		//protected HtmlTable       tblAddress                      ;
		protected HtmlTable       tblMailOptions                  ;

		protected TextBox         txtFIRST_NAME                   ;
		protected TextBox         txtLAST_NAME                    ;
		protected TextBox         txtUSER_NAME                    ;
		protected TextBox         txtPASSWORD                     ;
		protected TableCell       tdPASSWORD_Label                ;
		protected TableCell       tdPASSWORD_Field                ;
		// 11/21/2014 Paul.  Add User Picture. 
		protected HiddenField     PICTURE                         ;
		protected HtmlImage       imgPICTURE                      ;

		protected DropDownList    lstSTATUS                       ;
		// user_settings
		protected CheckBox        chkIS_ADMIN                     ;
		// 03/16/2010 Paul.  Add IS_ADMIN_DELEGATE. 
		protected CheckBox        chkIS_ADMIN_DELEGATE            ;
		protected CheckBox        chkPORTAL_ONLY                  ;
		protected CheckBox        chkRECEIVE_NOTIFICATIONS        ;
		// 03/04/2011 Paul.  We need to allow the admin to set the flag to force a password change. 
		protected CheckBox        chkSYSTEM_GENERATED_PASSWORD    ;
		protected DropDownList    lstTHEME                        ;
		protected DropDownList    lstLANGUAGE                     ;
		protected DropDownList    lstDATE_FORMAT                  ;
		protected DropDownList    lstTIME_FORMAT                  ;
		protected DropDownList    lstTIMEZONE                     ;
		protected CheckBox        chkSAVE_QUERY                   ;
		// 02/26/2010 Paul.  Allow users to configure use of tabs. 
		protected CheckBox        chkGROUP_TABS                   ;
		protected CheckBox        chkSUBPANEL_TABS                ;
		protected DropDownList    lstCURRENCY                     ;

		// 05/06/2009 Paul.  Add DEFAULT_TEAM to support SugarCRM migration. 
		protected TableCell       tdDEFAULT_TEAM_Label            ;
		protected TableCell       tdDEFAULT_TEAM_Field            ;
		protected bool            bMyAccount                      ;
		protected RequiredFieldValidator reqLAST_NAME;
		protected RequiredFieldValidator reqUSER_NAME;
		
		protected Button          btnSmtpTest                     ;
		protected Label           lblSmtpAuthorizedStatus         ;
		// 03/25/2011 Paul.  Add support for Google Apps. 
		protected Table           tblGoogleAppsPanel              ;
		protected HtmlTable       tblGoogleAppsOptions            ;
		protected Button          btnGoogleAppsAuthorize          ;
		protected Button          btnGoogleAppsDelete             ;
		protected Button          btnGoogleAppsTest               ;
		protected Button          btnGoogleAuthorized             ;
		protected Button          btnGoogleAppsRefreshToken       ;
		protected Label           lblGoogleAppsAuthorized         ;
		protected Label           lblGoogleAuthorizedStatus       ;
		// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
		protected TextBox         OAUTH_ACCESS_TOKEN              ;
		protected TextBox         OAUTH_REFRESH_TOKEN             ;
		protected TextBox         OAUTH_EXPIRES_IN                ;
		protected TextBox         OAUTH_CODE                      ;
		// 12/13/2011 Paul.  Add support for Apple iCloud. 
		protected Table           tblICloudPanel                  ;
		protected HtmlTable       tblICloudOptions                ;
		protected Button          btnICloudTest                   ;
		protected Button          btnICloudAuthorize              ;
		protected Button          btnICloudDelete                 ;
		protected Button          btnICloudAuthorized             ;
		protected Button          btnICloudRefreshToken           ;
		protected Label           lblICloudAuthorized             ;
		protected Label           lblCloudAuthorizedStatus        ;
		
		// 01/15/2017 Paul.  Add support for Office 365 OAuth. 
		protected Table           tblOffice365Panel               ;
		protected HtmlTable       tblOffice365Options             ;
		protected Button          btnOffice365Authorize           ;
		protected Button          btnOffice365Delete              ;
		protected Button          btnOffice365Test                ;
		protected Button          btnOffice365Authorized          ;
		protected Button          btnOffice365RefreshToken        ;
		protected Label           lblOffice365Authorized          ;
		protected Label           lblOffice365AuthorizedStatus    ;
		// 02/01/2017 Paul.  Add support for Exchange using Username/Password. 
		protected Table           tblSmtpPanel                    ;
		protected HtmlTable       tblSmtp                         ;

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
		#endregion

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
			#region Save
			// 03/15/2014 Paul.  Enable override of concurrency error. 
			if ( e.CommandName == "Save" || e.CommandName == "SaveConcurrency" )
			{
				try
				{
					// 01/16/2006 Paul.  Enable validator before validating page. 
					this.ValidateEditViewFields(m_sMODULE + "." + LayoutEditView   );
					this.ValidateEditViewFields(m_sMODULE + ".EditAddress");
					// 11/10/2010 Paul.  Apply Business Rules. 
					this.ApplyEditViewValidationEventRules(m_sMODULE + "." + LayoutEditView   );
					this.ApplyEditViewValidationEventRules(m_sMODULE + ".EditAddress");
					if ( Page.IsValid )
					{
						string sUSER_PREFERENCES = String.Empty;
						string sMAIL_SMTPPASS = Sql.ToString(ViewState["mail_smtppass"]);
						string sGOOGLEAPPS_PASSWORD = Sql.ToString(ViewState["GOOGLEAPPS_PASSWORD"]);
						string sICLOUD_PASSWORD     = Sql.ToString(ViewState["ICLOUD_PASSWORD"    ]);
						//XmlDocument xml = new XmlDocument();
						// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
						// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
						// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
						//xml.XmlResolver = null;
						try
						{
							//12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
							/*
							try
							{
								sUSER_PREFERENCES = Sql.ToString(ViewState["USER_PREFERENCES"]);
								xml.LoadXml(sUSER_PREFERENCES);
							}
							catch(Exception ex)
							{
								SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
								xml.AppendChild(xml.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
								xml.AppendChild(xml.CreateElement("USER_PREFERENCE"));
							}
							// user_settings
							// 08/12/2009 Paul.  A customer wants the ability to turn off the saved searches, both globally and on a per user basis. 
							XmlUtil.SetSingleNode(xml, "save_query"          , chkSAVE_QUERY.Checked ? "true" : "false");
							// 02/26/2010 Paul.  Allow users to configure use of tabs. 
							XmlUtil.SetSingleNode(xml, "group_tabs"          , chkGROUP_TABS.Checked ? "true" : "false");
							XmlUtil.SetSingleNode(xml, "subpanel_tabs"       , chkSUBPANEL_TABS.Checked ? "true" : "false");
							XmlUtil.SetSingleNode(xml, "culture"             , lstLANGUAGE.SelectedValue             );
							XmlUtil.SetSingleNode(xml, "theme"               , lstTHEME.SelectedValue                );
							XmlUtil.SetSingleNode(xml, "dateformat"          , lstDATE_FORMAT.SelectedValue          );
							XmlUtil.SetSingleNode(xml, "timeformat"          , lstTIME_FORMAT.SelectedValue          );
							XmlUtil.SetSingleNode(xml, "timezone"            , lstTIMEZONE.SelectedValue             );
							XmlUtil.SetSingleNode(xml, "currency_id"         , lstCURRENCY.SelectedValue             );
							*/
							// 02/29/2008 Paul.  The config value should only be used as an override.  We should default to the .NET culture value. 
							//CultureInfo culture = CultureInfo.CreateSpecificCulture(lstLANGUAGE.SelectedValue);
							// 08/05/2006 Paul.  Remove stub of unsupported code. Reminder is not supported at this time. 
							//XmlUtil.SetSingleNode(xml, "reminder_time"       , chkSHOULD_REMIND.Checked ? lstREMINDER_TIME.SelectedValue : "0" );
							// mail_options
							
							Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
							Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
							// 08/06/2005 Paul.  Password might be our empty value. 
							TextBox txtMAIL_SMTPPASS = FindControl("MAIL_SMTPPASS") as TextBox;
							if ( txtMAIL_SMTPPASS != null )
							{
								// 08/05/2006 Paul.  Allow the password to be cleared. 
								// 07/08/2010 Paul.  We want to save the password for later use. 
								sMAIL_SMTPPASS = txtMAIL_SMTPPASS.Text;
								// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
								if ( sMAIL_SMTPPASS == Sql.sEMPTY_PASSWORD )
								{
									sMAIL_SMTPPASS = Sql.ToString(ViewState["mail_smtppass"]);
								}
								else if ( !Sql.IsEmptyString(sMAIL_SMTPPASS) )
								{
									string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sMAIL_SMTPPASS, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
									if ( Security.DecryptPassword(sENCRYPTED_EMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sMAIL_SMTPPASS )
										throw(new Exception("Decryption failed"));
									sMAIL_SMTPPASS = sENCRYPTED_EMAIL_PASSWORD;
									ViewState["mail_smtppass"] = sMAIL_SMTPPASS;
									// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
									txtMAIL_SMTPPASS.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
								}
							}
							TextBox txtGOOGLEAPPS_PASSWORD = FindControl("GOOGLEAPPS_PASSWORD") as TextBox;
							if ( txtGOOGLEAPPS_PASSWORD != null )
							{
								// 08/05/2006 Paul.  Allow the password to be cleared. 
								// 07/08/2010 Paul.  We want to save the password for later use. 
								sGOOGLEAPPS_PASSWORD = txtGOOGLEAPPS_PASSWORD.Text;
								// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
								if ( sGOOGLEAPPS_PASSWORD == Sql.sEMPTY_PASSWORD )
								{
									sGOOGLEAPPS_PASSWORD = Sql.ToString(ViewState["GOOGLEAPPS_PASSWORD"]);
								}
								else if ( !Sql.IsEmptyString(sGOOGLEAPPS_PASSWORD) )
								{
									string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sGOOGLEAPPS_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
									if ( Security.DecryptPassword(sENCRYPTED_EMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sGOOGLEAPPS_PASSWORD )
										throw(new Exception("Decryption failed"));
									sGOOGLEAPPS_PASSWORD = sENCRYPTED_EMAIL_PASSWORD;
									ViewState["GOOGLEAPPS_PASSWORD"] = sGOOGLEAPPS_PASSWORD;
									// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
									txtGOOGLEAPPS_PASSWORD.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
								}
							}
							// 12/13/2011 Paul.  Add support for Apple iCloud. 
							TextBox txtICLOUD_PASSWORD = FindControl("ICLOUD_PASSWORD") as TextBox;
							if ( txtICLOUD_PASSWORD != null )
							{
								// 08/05/2006 Paul.  Allow the password to be cleared. 
								// 07/08/2010 Paul.  We want to save the password for later use. 
								sICLOUD_PASSWORD = txtICLOUD_PASSWORD.Text;
								// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
								if ( sICLOUD_PASSWORD == Sql.sEMPTY_PASSWORD )
								{
									sICLOUD_PASSWORD = Sql.ToString(ViewState["ICLOUD_PASSWORD"]);
								}
								else if ( !Sql.IsEmptyString(sICLOUD_PASSWORD) )
								{
									string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sICLOUD_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
									if ( Security.DecryptPassword(sENCRYPTED_EMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV) != sICLOUD_PASSWORD )
										throw(new Exception("Decryption failed"));
									sICLOUD_PASSWORD = sENCRYPTED_EMAIL_PASSWORD;
									ViewState["ICLOUD_PASSWORD"] = sICLOUD_PASSWORD;
									// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
									txtICLOUD_PASSWORD.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
								}
							}
							
							// 07/08/2010 Paul.  The user must share the global mail server, so all we need here is the user name and password. 
							//XmlUtil.SetSingleNode(xml, "mail_fromname"       , new DynamicControl(this, "MAIL_FROMNAME"    ).Text   );
							//XmlUtil.SetSingleNode(xml, "mail_fromaddress"    , new DynamicControl(this, "MAIL_FROMADDRESS" ).Text   );
							//XmlUtil.SetSingleNode(xml, "mail_smtpserver"     , new DynamicControl(this, "MAIL_SMTPSERVER"  ).Text   );
							//XmlUtil.SetSingleNode(xml, "mail_smtpport"       , new DynamicControl(this, "MAIL_SMTPPORT"    ).Text   );
							//XmlUtil.SetSingleNode(xml, "mail_sendtype"       , new DynamicControl(this, "MAIL_SENDTYPE"    ).Text   );
							//XmlUtil.SetSingleNode(xml, "mail_smtpauth_req"   , new DynamicControl(this, "MAIL_SMTPAUTH_REQ").Checked ? "true" : "false");
							// 07/09/2010 Paul.  Move the SMTP values from USER_PREFERENCES to the main table to make it easier to access. 
							//XmlUtil.SetSingleNode(xml, "mail_smtpuser"       , new DynamicControl(this, "MAIL_SMTPUSER"    ).Text   );
							//XmlUtil.SetSingleNode(xml, "mail_smtppass"       , sMAIL_SMTPPASS);
							
						}
						catch(Exception ex)
						{
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						}
						//12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
						//if ( Sql.ToBoolean(Application["CONFIG.XML_UserPreferences"]) )
						//	sUSER_PREFERENCES = xml.OuterXml;
						//else
						//	sUSER_PREFERENCES = XmlUtil.ConvertToPHP(xml.DocumentElement);
						
						// 12/06/2005 Paul.  Need to prevent duplicate users. 
						string sUSER_NAME = txtUSER_NAME.Text.Trim();
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						try
						{
							// 11/10/2006 Paul.  If the decimal and group separate match, then .NET will not be able to parse decimals. 
							// The exception "Input string was not in a correct format." is thrown. 
							if ( !Sql.IsEmptyString(sUSER_NAME) )
							{
								using ( IDbConnection con = dbf.CreateConnection() )
								{
									string sSQL ;
									sSQL = "select USER_NAME             " + ControlChars.CrLf
									     + "  from vwUSERS               " + ControlChars.CrLf
									     + " where USER_NAME = @USER_NAME" + ControlChars.CrLf;
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.CommandText = sSQL;
										Sql.AddParameter(cmd, "@USER_NAME", sUSER_NAME);
										if ( !Sql.IsEmptyGuid(gID) )
										{
											// 12/06/2005 Paul.  Only include the ID if it is not null as we cannot compare NULL to anything. 
											cmd.CommandText += "   and ID <> @ID" + ControlChars.CrLf;
											Sql.AddParameter(cmd, "@ID", gID);
										}
										con.Open();
										using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
										{
											if ( rdr.Read() )
											{
												string sMESSAGE = String.Empty;
												sMESSAGE = String.Format(L10n.Term("Users.ERR_USER_NAME_EXISTS_1") + "{0}" + L10n.Term("Users.ERR_USER_NAME_EXISTS_2"), sUSER_NAME);
												throw(new Exception(sMESSAGE));
											}
										}
									}
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							ctlDynamicButtons .ErrorText = ex.Message;
							//ctlFacebookButtons.ErrorText = ex.Message;
							return;
						}

						// 09/09/2009 Paul.  Use the new function to get the table name. 
						string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
						DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							string sSQL ;
							// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
							DataRow   rowCurrent = null;
							DataTable dtCurrent  = new DataTable();
							if ( !Sql.IsEmptyGuid(gID) )
							{
								sSQL = "select *           " + ControlChars.CrLf
								     + "  from vwUSERS_Edit" + ControlChars.CrLf;
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
											// 12/09/2008 Paul.  Throw an exception if the record has been edited since the last load. 
											DateTime dtLAST_DATE_MODIFIED = Sql.ToDateTime(ViewState["LAST_DATE_MODIFIED"]);
											// 03/15/2014 Paul.  Enable override of concurrency error. 
											if ( Sql.ToBoolean(Application["CONFIG.enable_concurrency_check"])  && (e.CommandName != "SaveConcurrency") && dtLAST_DATE_MODIFIED != DateTime.MinValue && Sql.ToDateTime(rowCurrent["DATE_MODIFIED"]) > dtLAST_DATE_MODIFIED )
											{
												// 03/15/2014 Paul.  Dynamic Buttons is not used in this area. 
												//ctlDynamicButtons.ShowButton("SaveConcurrency", true);
												//ctlFooterButtons .ShowButton("SaveConcurrency", true);
												throw(new Exception(String.Format(L10n.Term(".ERR_CONCURRENCY_OVERRIDE"), dtLAST_DATE_MODIFIED)));
											}
										}
										else
										{
											// 11/19/2007 Paul.  If the record is not found, clear the ID so that the record cannot be updated.
											// It is possible that the record exists, but that ACL rules prevent it from being selected. 
											gID = Guid.Empty;
										}
									}
								}
							}

							// 11/10/2010 Paul.  Apply Business Rules. 
							this.ApplyEditViewPreSaveEventRules(m_sMODULE + "." + LayoutEditView   , rowCurrent);
							this.ApplyEditViewPreSaveEventRules(m_sMODULE + ".EditAddress", rowCurrent);
							
							// 09/01/2015 Paul.  Pull non-transaction code ouside transaction code. 
							bool bNewUser = Sql.IsEmptyGuid(gID);
							// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									// 04/24/2006 Paul.  Upgrade to SugarCRM 4.2 Schema. 
									// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
									// 05/06/2009 Paul.  Add DEFAULT_TEAM to support SugarCRM migration. 
									SqlProcs.spUSERS_Update
										( ref gID
										, sUSER_NAME
										, txtFIRST_NAME.Text
										, txtLAST_NAME .Text
										, new DynamicControl(this, rowCurrent, "REPORTS_TO_ID"     ).ID
										, (Security.IS_ADMIN ? chkIS_ADMIN.Checked : Sql.ToBoolean(ViewState["IS_ADMIN"]) )
										, chkRECEIVE_NOTIFICATIONS.Checked
										, new DynamicControl(this, rowCurrent, "DESCRIPTION"       ).Text
										, new DynamicControl(this, rowCurrent, "TITLE"             ).Text
										, new DynamicControl(this, rowCurrent, "DEPARTMENT"        ).Text
										, new DynamicControl(this, rowCurrent, "PHONE_HOME"        ).Text
										, new DynamicControl(this, rowCurrent, "PHONE_MOBILE"      ).Text
										, new DynamicControl(this, rowCurrent, "PHONE_WORK"        ).Text
										, new DynamicControl(this, rowCurrent, "PHONE_OTHER"       ).Text
										, new DynamicControl(this, rowCurrent, "PHONE_FAX"         ).Text
										, new DynamicControl(this, rowCurrent, "EMAIL1"            ).Text
										, new DynamicControl(this, rowCurrent, "EMAIL2"            ).Text
										, lstSTATUS.SelectedValue
										, new DynamicControl(this, rowCurrent, "ADDRESS_STREET"    ).Text
										, new DynamicControl(this, rowCurrent, "ADDRESS_CITY"      ).Text
										, new DynamicControl(this, rowCurrent, "ADDRESS_STATE"     ).Text
										, new DynamicControl(this, rowCurrent, "ADDRESS_POSTALCODE").Text
										, new DynamicControl(this, rowCurrent, "ADDRESS_COUNTRY"   ).Text
										, sUSER_PREFERENCES
										, chkPORTAL_ONLY.Checked
										, new DynamicControl(this, rowCurrent, "EMPLOYEE_STATUS"   ).SelectedValue
										, new DynamicControl(this, rowCurrent, "MESSENGER_ID"      ).Text
										, new DynamicControl(this, rowCurrent, "MESSENGER_TYPE"    ).SelectedValue
										, sMODULE
										, gPARENT_ID
										, new DynamicControl(this, rowCurrent, "IS_GROUP"          ).Checked
										, new DynamicControl(this, rowCurrent, "DEFAULT_TEAM"      ).ID
										// 03/16/2010 Paul.  Add IS_ADMIN_DELEGATE. 
										, ((SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0) ? chkIS_ADMIN_DELEGATE.Checked : Sql.ToBoolean(ViewState["IS_ADMIN_DELEGATE"]) )
										, new DynamicControl(this, rowCurrent, "MAIL_SMTPUSER"     ).Text
										, sMAIL_SMTPPASS
										// 03/04/2011 Paul.  We need to allow the admin to set the flag to force a password change. 
										, chkSYSTEM_GENERATED_PASSWORD.Checked
										// 03/25/2011 Paul.  Add support for Google Apps. 
										, new DynamicControl(this, "GOOGLEAPPS_SYNC_CONTACTS"      ).Checked
										, new DynamicControl(this, "GOOGLEAPPS_SYNC_CALENDAR"      ).Checked
										, new DynamicControl(this, "GOOGLEAPPS_USERNAME"           ).Text
										, sGOOGLEAPPS_PASSWORD
										, new DynamicControl(this, "FACEBOOK_ID"                   ).Text
										// 12/13/2011 Paul.  Add support for Apple iCloud. 
										, new DynamicControl(this, "ICLOUD_SYNC_CONTACTS"          ).Checked
										, new DynamicControl(this, "ICLOUD_SYNC_CALENDAR"          ).Checked
										, new DynamicControl(this, "ICLOUD_USERNAME"               ).Text
										, sICLOUD_PASSWORD
										// 12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
										, lstTHEME.SelectedValue
										, lstDATE_FORMAT.SelectedValue
										, lstTIME_FORMAT.SelectedValue
										, lstLANGUAGE.SelectedValue
										, Sql.ToGuid(lstCURRENCY.SelectedValue)
										, Sql.ToGuid(lstTIMEZONE.SelectedValue)
										, chkSAVE_QUERY.Checked
										, chkGROUP_TABS.Checked
										, chkSUBPANEL_TABS.Checked
										// 09/20/2013 Paul.  Move EXTENSION to the main table. 
										, new DynamicControl(this, "EXTENSION"                     ).Text
										// 09/27/2013 Paul.  SMS messages need to be opt-in. 
										, new DynamicControl(this, "SMS_OPT_IN"                    ).SelectedValue
										// 11/21/2014 Paul.  Add User Picture. 
										, new DynamicControl(this, rowCurrent, "PICTURE"           ).Text
										// 04/20/2016 Paul.  Provide a way to allow each user to have their own SMTP server. 
										, new DynamicControl(this, "MAIL_SMTPSERVER"               ).Text
										, new DynamicControl(this, "MAIL_SMTPPORT"                 ).IntegerValue
										, new DynamicControl(this, "MAIL_SMTPAUTH_REQ"             ).Checked
										, (new DynamicControl(this, "MAIL_SMTPSSL"                 ).Checked ? 1 : 0)
										// 02/01/2017 Paul.  Add support for Exchange using Username/Password. 
										, new DynamicControl(this, "MAIL_SENDTYPE"                 ).Text
										, trn
										);
									SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
									// 11/27/2009 Paul.  The password field only exists if this is a new user. 
									if ( tdPASSWORD_Label.Visible && (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0) )
									{
										txtPASSWORD.Text = txtPASSWORD.Text.Trim();
										if ( !Sql.IsEmptyString(txtPASSWORD.Text) )
											SqlProcs.spUSERS_PasswordUpdate(gID, Security.HashPassword(txtPASSWORD.Text), trn);
									}

									// 11/11/2008 Paul.  Display an error message if max users has been exceeded. 
									// 02/09/2009 Paul.  We need to check the ActiveUsers in the middle of the transaction. 
									// This is so that a user can be disabled without throwing the max users exception. 
									// 04/07/2015 Paul.  Change active user logic to use same as stored procedure. 
									// 05/04/2015 Paul.  We have new users for HubSpot, iContact and ConstantContact, so make more room. 
									int nActiveUsers = 0;
									sSQL = "select count(*)          " + ControlChars.CrLf
									     + "  from vwUSERS_Login     " + ControlChars.CrLf
									     + " where ID > '00000000-0000-0000-0000-00000000000F'" + ControlChars.CrLf;
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.Transaction = trn;
										cmd.CommandText = sSQL;
										nActiveUsers = Sql.ToInteger(cmd.ExecuteScalar());
									}
									int nMaxUsers = Sql.ToInteger(Crm.Config.Value("max_users"));
									if ( nMaxUsers > 0 && nActiveUsers > nMaxUsers )
										throw(new Exception(L10n.Term("Users.ERR_MAX_USERS")));

									// 04/17/2018 Paul.  Enable Exchange Sync when configuring Exchange or Office365. 
									string sEMAIL1 = new DynamicControl(this, "EMAIL1").Text;
									if ( Sql.ToBoolean(Application["CONFIG.Exchange.DefaultEnableExchangeFolders"]) && !Sql.IsEmptyString(sEMAIL1) )
									{
										string sMAIL_SENDTYPE = new DynamicControl(this, "MAIL_SENDTYPE").Text;
										string sMAIL_SMTPUSER = new DynamicControl(this, "MAIL_SMTPUSER").Text;
										if (  (sMAIL_SENDTYPE == "Exchange-Password" && !Sql.IsEmptyString(sMAIL_SMTPUSER) && !Sql.IsEmptyString(sMAIL_SMTPPASS)) 
										   || (sMAIL_SENDTYPE == "Office365"         && Sql.ToBoolean(Session["OFFICE365_OAUTH_ENABLED"])) 
										   )
										{
											string sEXCHANGE_ALIAS    = sUSER_NAME;
											string sEXCHANGE_EMAIL    = sEMAIL1   ;
											string sIMPERSONATED_TYPE = Sql.ToString(Application["CONFIG.Exchange.ImpersonatedType"]);
											Guid gEXCHNAGE_USER_ID = Guid.Empty;
											SqlProcs.spEXCHANGE_USERS_Update
												( ref gEXCHNAGE_USER_ID
												, sEXCHANGE_ALIAS
												, sEXCHANGE_EMAIL
												, sIMPERSONATED_TYPE
												, gID  // 05/01/2018 Paul.  This user. 
												, trn
												);
										}
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
								// 09/01/2015 Paul.  Pull non-transaction code ouside transaction code. 
								try
								{
									// 07/18/2013 Paul.  Add support for multiple outbound emails. 
									SplendidCache.ClearOutboundMail();
									// 09/09/2006 Paul.  Refresh cached user information. 
									// 05/26/2019 Paul.  Clear the React client data. 
									if ( bNewUser || Security.IS_ADMIN )
										SplendidCache.ClearUsers();
									// 08/27/2005 Paul. Reload session with user preferences. 
									// 08/30/2005 Paul. Only reload preferences the user is editing his own profile. 
									// We want to allow an administrator to update other user profiles. 
									if ( Security.USER_ID == gID )
										SplendidInit.LoadUserPreferences(gID, lstTHEME.SelectedValue, lstLANGUAGE.SelectedValue);
									// 09/05/2013 Paul.  Use the Application as a cache for the Asterisk extension as we can correct by editing a user. 
									// 09/20/2013 Paul.  Move EXTENSION to the main table. 
									string sEXTENSION = new DynamicControl(this, "EXTENSION").Text;
									if ( !Sql.IsEmptyString(sEXTENSION) )
									{
										Application["Users.EXTENSION." + sEXTENSION + ".USER_ID"] = gID;
										Application["Users.EXTENSION." + sEXTENSION + ".TEAM_ID"] = new DynamicControl(this, rowCurrent, "DEFAULT_TEAM").ID;
									}
									string sPREV_EXTENSION = Sql.ToString(ViewState["EXTENSION"]);
									if ( sEXTENSION != sPREV_EXTENSION && !Sql.IsEmptyString(sPREV_EXTENSION) )
									{
										Application.Remove("Users.EXTENSION." + sPREV_EXTENSION + ".USER_ID");
										Application.Remove("Users.EXTENSION." + sPREV_EXTENSION + ".TEAM_ID");
									}
									// 12/06/2013 Paul.  Update the devices being monitored if the extension has changed. 
									// 09/01/2015 Paul.  Pull extension update outside transaction. 
									string sAvayaHost     = Sql.ToString (Application["CONFIG.Avaya.Host"         ]);
									int    nAvayaPort     = Sql.ToInteger(Application["CONFIG.Avaya.Port"         ]);
									string sAvayaUsername = Sql.ToString (Application["CONFIG.Avaya.UserName"     ]);
									string sAvayaPassword = Sql.ToString (Application["CONFIG.Avaya.Password"     ]);
									if ( !Sql.IsEmptyString(sAvayaHost) && nAvayaPort > 0 && !Sql.IsEmptyString(sAvayaUsername) && !Sql.IsEmptyString(sAvayaPassword) )
									{
										if ( sEXTENSION != sPREV_EXTENSION )
										{
											AvayaManager.Instance.MonitorDevices();
										}
									}
								}
								catch(Exception ex)
								{
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									ctlDynamicButtons .ErrorText = ex.Message;
									return;
								}
							}
							// 08/26/2010 Paul.  Add new record to tracker. 
							sSQL = "select FULL_NAME   " + ControlChars.CrLf
							     + "  from vwUSERS_Edit" + ControlChars.CrLf
							     + " where ID = @ID    " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@ID", gID);
								string sNAME = Sql.ToString(cmd.ExecuteScalar());
								// 03/08/2012 Paul.  Add ACTION to the tracker table so that we can create quick user activity reports. 
								SqlProcs.spTRACKER_Update
									( Security.USER_ID
									, m_sMODULE
									, gID
									, sNAME
									, "save"
									);
							}
							// 11/10/2010 Paul.  Apply Business Rules. 
							// 12/10/2012 Paul.  Provide access to the item data. 
							rowCurrent = Crm.Modules.ItemEdit(m_sMODULE, gID);
							this.ApplyEditViewPostSaveEventRules(m_sMODULE + "." + LayoutEditView   , rowCurrent);
							this.ApplyEditViewPostSaveEventRules(m_sMODULE + ".EditAddress", rowCurrent);
						}
						
						if ( !Sql.IsEmptyString(RulesRedirectURL) )
							Response.Redirect(RulesRedirectURL);
						else if ( !Sql.IsEmptyGuid(gPARENT_ID) )
							Response.Redirect("~/" + sMODULE + "/view.aspx?ID=" + gPARENT_ID.ToString());
						else if ( bMyAccount )
							Response.Redirect("MyAccount.aspx");
						else
							Response.Redirect("view.aspx?ID=" + gID.ToString());
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					ctlDynamicButtons .ErrorText = ex.Message;
					//ctlFacebookButtons.ErrorText = ex.Message;
				}
			}
			#endregion
			#region Smtp.Test
			// 07/08/2010 Paul.  Provide the ability to test the email settings. 
			else if ( e.CommandName == "Smtp.Test" )
			{
				try
				{
					TextBox txtMAIL_SMTPUSER = FindControl("MAIL_SMTPUSER") as TextBox;
					TextBox txtMAIL_SMTPPASS = FindControl("MAIL_SMTPPASS") as TextBox;
					string sFROM_ADDR         = new DynamicControl(this, "EMAIL1").Text;
					string sFROM_NAME         = (txtFIRST_NAME.Text + " " + txtLAST_NAME.Text).Trim();
					if ( Sql.IsEmptyString(sFROM_ADDR) )
					{
						lblSmtpAuthorizedStatus.Text = L10n.Term("Users.ERR_EMAIL_REQUIRED_TO_TEST");
					}
					else if ( txtMAIL_SMTPUSER != null && txtMAIL_SMTPPASS != null )
					{
						Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
						Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
						string sMAIL_SMTPPASS            = txtMAIL_SMTPPASS.Text;
						string sENCRYPTED_EMAIL_PASSWORD = String.Empty;
						// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
						if ( sMAIL_SMTPPASS == Sql.sEMPTY_PASSWORD )
						{
							sENCRYPTED_EMAIL_PASSWORD = Sql.ToString(ViewState["mail_smtppass"]);
							if ( !Sql.IsEmptyString(sENCRYPTED_EMAIL_PASSWORD) )
								sMAIL_SMTPPASS = Security.DecryptPassword(sENCRYPTED_EMAIL_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
						}
						else if ( !Sql.IsEmptyString(sMAIL_SMTPPASS) )
						{
							sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sMAIL_SMTPPASS, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
							ViewState["mail_smtppass"] = sENCRYPTED_EMAIL_PASSWORD;
							// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
							txtMAIL_SMTPPASS.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
						}
						string sMAIL_SMTPSERVER   = new DynamicControl(this, "MAIL_SMTPSERVER"  ).Text;
						int    nMAIL_SMTPPORT     = new DynamicControl(this, "MAIL_SMTPPORT"    ).IntegerValue;
						bool   bMAIL_SMTPAUTH_REQ = new DynamicControl(this, "MAIL_SMTPAUTH_REQ").Checked;
						bool   bMAIL_SMTPSSL      = new DynamicControl(this, "MAIL_SMTPSSL"     ).Checked;
						string sMAIL_SENDTYPE     = new DynamicControl(this, "MAIL_SENDTYPE"    ).Text;
						string sMAIL_SMTPUSER     = new DynamicControl(this, "MAIL_SMTPUSER"    ).Text;
						if ( String.Compare(sMAIL_SENDTYPE, "smtp", true) == 0 )
						{
							// 02/02/2017 Paul.  Global values are only used if server left blank. 
							if ( Sql.IsEmptyString(sMAIL_SMTPSERVER) )
							{
								sMAIL_SMTPSERVER   = Sql.ToString (Application["CONFIG.smtpserver"  ]);
								nMAIL_SMTPPORT     = Sql.ToInteger(Application["CONFIG.smtpport"    ]);
								bMAIL_SMTPAUTH_REQ = Sql.ToBoolean(Application["CONFIG.smtpauth_req"]);
								bMAIL_SMTPSSL      = Sql.ToBoolean(Application["CONFIG.smtpssl"     ]);
							}
							EmailUtils.SendTestMessage(Application, sMAIL_SMTPSERVER, nMAIL_SMTPPORT, bMAIL_SMTPAUTH_REQ, bMAIL_SMTPSSL, sMAIL_SMTPUSER, sMAIL_SMTPPASS, sFROM_ADDR, sFROM_NAME, sFROM_ADDR, sFROM_NAME);
							lblSmtpAuthorizedStatus.Text = L10n.Term("Users.LBL_SEND_SUCCESSFUL");
							//ctlFacebookButtons.ErrorText = L10n.Term("Users.LBL_SEND_SUCCESSFUL");
						}
						// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
						else if ( String.Compare(sMAIL_SENDTYPE, "Exchange-Password", true) == 0 )
						{
							string sIMPERSONATED_TYPE        = Sql.ToString (Application["CONFIG.Exchange.ImpersonatedType"]);
							string sSERVER_URL               = Sql.ToString (Application["CONFIG.Exchange.ServerURL"       ]);
							ExchangeUtils.SendTestMessage(Application, sSERVER_URL, sMAIL_SMTPUSER, sENCRYPTED_EMAIL_PASSWORD, sFROM_ADDR, sFROM_NAME, sFROM_ADDR, sFROM_NAME);
							//ctlDynamicButtons.ErrorText = "Send was successful.";
							lblSmtpAuthorizedStatus.Text = L10n.Term("Users.LBL_SEND_SUCCESSFUL");
						}
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					lblSmtpAuthorizedStatus.Text = ex.Message;
					//ctlFacebookButtons.ErrorText = ex.Message;
				}
			}
			#endregion
			#region Apple iCloud
			// 12/13/2011 Paul.  Add support for Apple iCloud. 
			else if ( e.CommandName == "iCloud.Test" )
			{
				try
				{
					StringBuilder sbErrors = new StringBuilder();
					//SplendidCRM.iCloudSync.TestAccessToken(Application, gID, sbErrors);
					lblCloudAuthorizedStatus.Text = sbErrors.ToString();
					/*
					Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
					Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
					TextBox txtMAIL_SMTPUSER       = FindControl("MAIL_SMTPUSER"      ) as TextBox;
					TextBox txtMAIL_SMTPPASS       = FindControl("MAIL_SMTPPASS"      ) as TextBox;
					TextBox txtICLOUD_USERNAME = FindControl("ICLOUD_USERNAME") as TextBox;
					TextBox txtICLOUD_PASSWORD = FindControl("ICLOUD_PASSWORD") as TextBox;
					if ( txtICLOUD_USERNAME != null && txtICLOUD_PASSWORD != null )
					{
						string sICLOUD_USERNAME = txtICLOUD_USERNAME.Text;
						string sICLOUD_PASSWORD = txtICLOUD_PASSWORD.Text;
						// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
						if ( sICLOUD_PASSWORD == Sql.sEMPTY_PASSWORD )
						{
							sICLOUD_PASSWORD = Sql.ToString(ViewState["ICLOUD_PASSWORD"]);
							if ( !Sql.IsEmptyString(sICLOUD_PASSWORD) )
								sICLOUD_PASSWORD = Security.DecryptPassword(sICLOUD_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
						}
						else if ( !Sql.IsEmptyString(sICLOUD_PASSWORD) )
						{
							string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sICLOUD_PASSWORD, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
							ViewState["ICLOUD_PASSWORD"] = sENCRYPTED_EMAIL_PASSWORD;
							// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
							txtICLOUD_PASSWORD.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
						}
						// 03/25/2011 Paul.  Use SMTP values if the Google values have not been provided. 
						if ( Sql.IsEmptyString(sICLOUD_USERNAME) && txtMAIL_SMTPUSER != null )
						{
							sICLOUD_USERNAME = txtMAIL_SMTPUSER.Text;
						}
						if ( Sql.IsEmptyString(sICLOUD_PASSWORD) && txtMAIL_SMTPPASS != null )
						{
							string sMAIL_SMTPPASS = txtMAIL_SMTPPASS.Text;
							// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
							if ( sMAIL_SMTPPASS == Sql.sEMPTY_PASSWORD )
							{
								sMAIL_SMTPPASS = Sql.ToString(ViewState["mail_smtppass"]);
								if ( !Sql.IsEmptyString(sMAIL_SMTPPASS) )
									sMAIL_SMTPPASS = Security.DecryptPassword(sMAIL_SMTPPASS, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
							}
							else if ( !Sql.IsEmptyString(sMAIL_SMTPPASS) )
							{
								string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sMAIL_SMTPPASS, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
								ViewState["mail_smtppass"] = sENCRYPTED_EMAIL_PASSWORD;
								// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
								txtMAIL_SMTPPASS.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
							}
							sICLOUD_PASSWORD = sMAIL_SMTPPASS;
						}
						
						StringBuilder sbErrors = new StringBuilder();
						// 07/09/2020 Paul.  Use SMTP values if the Google values have not been provided. 
						iCloudSync.Validate_iCloud(Application, sICLOUD_USERNAME, sICLOUD_PASSWORD, sbErrors);
						if ( sbErrors.Length > 0 )
						{
							ctlDynamicButtons .ErrorText = sbErrors.ToString();
							//ctlFacebookButtons.ErrorText = sbErrors.ToString();
						}
						else
						{
							ctlDynamicButtons .ErrorText = L10n.Term("Users.LBL_ICLOUD_TEST_SUCCESSFUL");
							//ctlFacebookButtons.ErrorText = L10n.Term("Users.LBL_ICLOUD_TEST_SUCCESSFUL");
						}
					}
					*/
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					lblCloudAuthorizedStatus.Text = ex.Message;
				}
			}
			// 02/13/2022 Paul.  Sign in with Apple now uses OAuth 2.0. 
			else if ( e.CommandName == "iCloud.Authorize" )
			{
				try
				{
					string sCode       = OAUTH_CODE.Text;
					string sIdToken    = OAUTH_ACCESS_TOKEN.Text;
					StringBuilder sbErrors = new StringBuilder();
					SplendidCRM.iCloudSync.AcquireAccessToken(Context, gID, sCode, sIdToken, sbErrors);
					if ( sbErrors.Length == 0 )
					{
						lblCloudAuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
						btnICloudAuthorize      .Visible = false;
						btnICloudDelete         .Visible = true ;
						btnICloudTest           .Visible = true ;
						btnICloudRefreshToken   .Visible = true && bDebug;
						lblCloudAuthorizedStatus.Visible = true ;
						Session["ICLOUD_OAUTH_ENABLED"] = true;
					}
					else
					{
						throw(new Exception(sbErrors.ToString()));
					}
				}
				catch(Exception ex)
				{
					lblCloudAuthorizedStatus.Text = ex.Message;
					Session["ICLOUD_OAUTH_ENABLED"] = false;
				}
			}
			else if ( e.CommandName == "iCloud.Delete" )
			{
				try
				{
					SqlProcs.spOAUTH_TOKENS_Delete(gID, "iCloud");
					btnICloudAuthorize   .Visible = true ;
					btnICloudDelete      .Visible = false;
					btnICloudTest        .Visible = false;
					btnICloudRefreshToken.Visible = false;
					lblICloudAuthorized  .Visible = false;
					Session["ICLOUD_OAUTH_ENABLED"] = false;
				}
				catch(Exception ex)
				{
					lblCloudAuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			else if ( e.CommandName == "iCloud.RefreshToken" )
			{
				try
				{
					SplendidCRM.iCloudSync.RefreshAccessToken(Context, gID, true);
					lblCloudAuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
					Session["ICLOUD_OAUTH_ENABLED"] = true;
				}
				catch(Exception ex)
				{
					lblCloudAuthorizedStatus.Text =  Utils.ExpandException(ex);
					Session["ICLOUD_OAUTH_ENABLED"] = false;
				}
			}
			#endregion
			#region GoogleApps
			// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
			else if ( e.CommandName == "GoogleApps.Authorize" )
			{
				try
				{
					DateTime dtOAUTH_EXPIRES_AT = DateTime.Now.AddSeconds(Sql.ToInteger(OAUTH_EXPIRES_IN.Text));
					SqlProcs.spOAUTH_TOKENS_Update(gID, "GoogleApps", OAUTH_ACCESS_TOKEN.Text, String.Empty, dtOAUTH_EXPIRES_AT, OAUTH_REFRESH_TOKEN.Text);
					Application["CONFIG.GoogleApps." + gID.ToString() + ".OAuthAccessToken" ] = OAUTH_ACCESS_TOKEN.Text ;
					Application["CONFIG.GoogleApps." + gID.ToString() + ".OAuthRefreshToken"] = OAUTH_REFRESH_TOKEN.Text;
					Application["CONFIG.GoogleApps." + gID.ToString() + ".OAuthExpiresAt"   ] = dtOAUTH_EXPIRES_AT.ToShortDateString() + " " + dtOAUTH_EXPIRES_AT.ToShortTimeString();
					// 01/19/2017 Paul.  We want an OUTBOUND_EMAILS mapping to the office365 OAuth record. 
					// 02/04/2017 Paul.  OutboundEmail NAME will be system when Gmail is the primary send type.  Otherwise this is just an older-style GoogleApps sync. 
					string sMAIL_SENDTYPE = new DynamicControl(this, "MAIL_SENDTYPE").Text;
					if ( String.Compare(sMAIL_SENDTYPE, "GoogleApps", true) == 0 )
					{
						Guid gOUTBOUND_EMAIL_ID = Guid.Empty;
						SqlProcs.spOUTBOUND_EMAILS_Update(ref gOUTBOUND_EMAIL_ID, "system", "system-override", gID, "GoogleApps", null, null, 0, null, null, false, 0, null, null, Guid.Empty, null);
					}
					lblGoogleAuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
					btnGoogleAppsAuthorize   .Visible = false;
					btnGoogleAppsDelete      .Visible = true ;
					btnGoogleAppsTest        .Visible = true ;
					btnGoogleAppsRefreshToken.Visible = true && bDebug;
					lblGoogleAppsAuthorized  .Visible = true ;
					Session["GOOGLEAPPS_OAUTH_ENABLED"] = true;
					// 02/09/2017 Paul.  Update the email address. 
					StringBuilder sbErrors = new StringBuilder();
					// 07/14/2020 Paul.  If email not accessible, just ignore as we have a valid token. 
					// Google.Apis.Requests.RequestError Mail service not enabled [400] Errors [ Message[Mail service not enabled] Location[ - ] Reason[failedPrecondition] Domain[global] ]
					string sEMAIL1 = SplendidCRM.GoogleApps.GetEmailAddress(Application, gID, sbErrors);
					if ( sbErrors.Length == 0 )
						new DynamicControl(this, "EMAIL1").Text = sEMAIL1;
				}
				catch(Exception ex)
				{
					lblGoogleAuthorizedStatus.Text = ex.Message;
					Session["GOOGLEAPPS_OAUTH_ENABLED"] = false;
				}
			}
			else if ( e.CommandName == "GoogleApps.Delete" )
			{
				try
				{
					SqlProcs.spOAUTH_TOKENS_Delete(gID, "GoogleApps");
					btnGoogleAppsAuthorize   .Visible = true ;
					btnGoogleAppsDelete      .Visible = false;
					btnGoogleAppsTest        .Visible = false;
					btnGoogleAppsRefreshToken.Visible = false;
					lblGoogleAppsAuthorized  .Visible = false;
					Session["GOOGLEAPPS_OAUTH_ENABLED"] = false;
				}
				catch(Exception ex)
				{
					lblGoogleAuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			else if ( e.CommandName == "GoogleApps.Test" )
			{
				try
				{
					StringBuilder sbErrors = new StringBuilder();
					SplendidCRM.GoogleApps.TestAccessToken(Application, gID, sbErrors);
					string sFROM_ADDR = new DynamicControl(this, "EMAIL1").Text;
					string sFROM_NAME = (txtFIRST_NAME.Text + " " + txtLAST_NAME.Text).Trim();
					SplendidCRM.GoogleApps.SendTestMessage(Application, gID, sFROM_ADDR, sFROM_NAME, sFROM_ADDR, sFROM_NAME);
					lblGoogleAuthorizedStatus.Text = sbErrors.ToString();
				}
				catch(Exception ex)
				{
					lblGoogleAuthorizedStatus.Text = ex.Message;
				}
			}
			else if ( e.CommandName == "GoogleApps.RefreshToken" )
			{
				try
				{
					SplendidCRM.GoogleApps.RefreshAccessToken(Application, gID, true);
					lblGoogleAuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
					Session["GOOGLEAPPS_OAUTH_ENABLED"] = true;
				}
				catch(Exception ex)
				{
					lblGoogleAuthorizedStatus.Text =  Utils.ExpandException(ex);
					Session["GOOGLEAPPS_OAUTH_ENABLED"] = false;
				}
			}
			#endregion
			#region Office365
			// 01/16/2017 Paul.  Add support for Office 365 OAuth. 
			else if ( e.CommandName == "Office365.Authorize" )
			{
				try
				{
					string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
					string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
					// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
					string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
					// 11/09/2019 Paul.  Pass the RedirectURL so that we can call from the React client. 
					Office365AccessToken token = SplendidCRM.ActiveDirectory.Office365AcquireAccessToken(Context, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, gID, OAUTH_CODE.Text, String.Empty);
					// 01/19/2017 Paul.  We want an OUTBOUND_EMAILS mapping to the office365 OAuth record. 
					// 02/04/2017 Paul.  OutboundEmail NAME is "system" as it will be the primary email for the user. 
					Guid gOUTBOUND_EMAIL_ID = Guid.Empty;
					SqlProcs.spOUTBOUND_EMAILS_Update(ref gOUTBOUND_EMAIL_ID, "system", "system-override", gID, "Office365", null, null, 0, null, null, false, 0, null, null, Guid.Empty, null);
					lblOffice365AuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
					btnOffice365Authorize   .Visible = false;
					btnOffice365Delete      .Visible = true ;
					btnOffice365Test        .Visible = true ;
					btnOffice365RefreshToken.Visible = true && bDebug;
					lblOffice365Authorized  .Visible = true ;
					Session["OFFICE365_OAUTH_ENABLED"] = true;
					string sEMAIL1 = new DynamicControl(this, "EMAIL1").Text;
					// 02/09/2017 Paul.  Use Microsoft Graph REST API to get email. 
					MicrosoftGraphProfile profile = SplendidCRM.ActiveDirectory.GetProfile(Application, token.AccessToken);
					if ( profile != null )
					{
						// 04/06/2021 Paul.  Office365 may not return the email. 
						if ( !Sql.IsEmptyString(profile.EmailAddress) )
						{
							sEMAIL1 = Sql.ToString(profile.EmailAddress);
							new DynamicControl(this, "EMAIL1").Text = sEMAIL1;
						}
					}
					// 04/06/2021 Paul.  Automatically enable the folder when authorizing Office365.. 
					if ( Sql.ToBoolean(Application["CONFIG.Exchange.DefaultEnableExchangeFolders"]) )
					{
						string sEXCHANGE_ALIAS    = txtUSER_NAME.Text.Trim();
						string sEXCHANGE_EMAIL    = sEMAIL1   ;
						string sIMPERSONATED_TYPE = Sql.ToString(Application["CONFIG.Exchange.ImpersonatedType"]);
						Guid gEXCHNAGE_USER_ID = Guid.Empty;
						SqlProcs.spEXCHANGE_USERS_Update
							( ref gEXCHNAGE_USER_ID
							, sEXCHANGE_ALIAS
							, sEXCHANGE_EMAIL
							, sIMPERSONATED_TYPE
							, gID  // 05/01/2018 Paul.  This user. 
							);
					}
				}
				catch(Exception ex)
				{
					lblOffice365AuthorizedStatus.Text =  Utils.ExpandException(ex);
					Session["OFFICE365_OAUTH_ENABLED"] = false;
				}
			}
			else if ( e.CommandName == "Office365.RefreshToken" )
			{
				try
				{
					string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
					string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
					// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
					string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
					SplendidCRM.ActiveDirectory.Office365RefreshAccessToken(Application, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, gID, true);
					lblOffice365AuthorizedStatus.Text = L10n.Term("OAuth.LBL_TEST_SUCCESSFUL");
					Session["OFFICE365_OAUTH_ENABLED"] = true;
				}
				catch(Exception ex)
				{
					lblOffice365AuthorizedStatus.Text =  Utils.ExpandException(ex);
					Session["OFFICE365_OAUTH_ENABLED"] = false;
				}
			}
			else if ( e.CommandName == "Office365.Delete" )
			{
				try
				{
					SqlProcs.spOAUTH_TOKENS_Delete(gID, "Office365");
					btnOffice365Authorize   .Visible = true ;
					btnOffice365Delete      .Visible = false;
					btnOffice365Test        .Visible = false;
					btnOffice365RefreshToken.Visible = false;
					lblOffice365Authorized  .Visible = false;
					Session["OFFICE365_OAUTH_ENABLED"] = false;
				}
				catch(Exception ex)
				{
					lblOffice365AuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			else if ( e.CommandName == "Office365.Test" )
			{
				try
				{
					StringBuilder sbErrors = new StringBuilder();
					string sOAuthClientID     = Sql.ToString(Application["CONFIG.Exchange.ClientID"    ]);
					string sOAuthClientSecret = Sql.ToString(Application["CONFIG.Exchange.ClientSecret"]);
					// 02/04/2023 Paul.  Directory Tenant is now required for single tenant app registrations. 
					string sOAuthDirectoryTenatID = Sql.ToString(Application["CONFIG.Exchange.DirectoryTenantID"]);
					SplendidCRM.ActiveDirectory.Office365TestAccessToken(Application, sOAuthDirectoryTenatID, sOAuthClientID, sOAuthClientSecret, gID, sbErrors);
					lblOffice365AuthorizedStatus.Text = sbErrors.ToString();
					try
					{
						string sFROM_ADDR = new DynamicControl(this, "EMAIL1").Text;
						string sFROM_NAME = (txtFIRST_NAME.Text + " " + txtLAST_NAME.Text).Trim();
						// 12/13/2020 Paul.  Move Office365 methods to Office365utils. 
						Office365Utils.SendTestMessage(Application, gID, sFROM_ADDR, sFROM_NAME, sFROM_ADDR, sFROM_NAME);
						lblOffice365AuthorizedStatus.Text += L10n.Term("Users.LBL_SEND_SUCCESSFUL");
					}
					catch(Exception ex)
					{
						lblOffice365AuthorizedStatus.Text += Utils.ExpandException(ex);
					}
				}
				catch(Exception ex)
				{
					lblOffice365AuthorizedStatus.Text =  Utils.ExpandException(ex);
				}
			}
			#endregion
			else if ( e.CommandName == "Cancel" )
			{
				if ( !Sql.IsEmptyGuid(gPARENT_ID) )
					Response.Redirect("~/" + sMODULE + "/view.aspx?ID=" + gPARENT_ID.ToString());
				else if ( bMyAccount )
					Response.Redirect("MyAccount.aspx");
				else if ( Sql.IsEmptyGuid(gID) )
					Response.Redirect("default.aspx");
				else
					Response.Redirect("view.aspx?ID=" + gID.ToString());
			}
		}

		protected void lstLANGUAGE_Changed(Object sender, EventArgs e)
		{
			if ( lstLANGUAGE.SelectedValue.Length > 0 )
			{
				CultureInfo oldCulture   = Thread.CurrentThread.CurrentCulture   ;
				CultureInfo oldUICulture = Thread.CurrentThread.CurrentUICulture ;
				Thread.CurrentThread.CurrentCulture   = CultureInfo.CreateSpecificCulture(lstLANGUAGE.SelectedValue);
				Thread.CurrentThread.CurrentUICulture = new CultureInfo(lstLANGUAGE.SelectedValue);

				DateTime dtNow = T10n.FromServerTime(DateTime.Now);
				DateTimeFormatInfo oDateInfo   = Thread.CurrentThread.CurrentCulture.DateTimeFormat;
				NumberFormatInfo   oNumberInfo = Thread.CurrentThread.CurrentCulture.NumberFormat  ;

				String[] aDateTimePatterns = oDateInfo.GetAllDateTimePatterns();

				lstDATE_FORMAT.Items.Clear();
				lstTIME_FORMAT.Items.Clear();
				foreach ( string sPattern in aDateTimePatterns )
				{
					// 11/12/2005 Paul.  Only allow patterns that have a full year. 
					// 10/15/2013 Paul.  Allow 2-digit year. 
					if ( sPattern.IndexOf("yy") >= 0 && sPattern.IndexOf("dd") >= 0 && sPattern.IndexOf("mm") <  0 )
						lstDATE_FORMAT.Items.Add(new ListItem(sPattern + "   " + dtNow.ToString(sPattern), sPattern));
					if ( sPattern.IndexOf("yy") <  0 && sPattern.IndexOf("mm") >= 0 )
						lstTIME_FORMAT.Items.Add(new ListItem(sPattern + "   " + dtNow.ToString(sPattern), sPattern));
				}
				Thread.CurrentThread.CurrentCulture = oldCulture  ;
				Thread.CurrentThread.CurrentCulture = oldUICulture;
			}
		}

		// 02/01/2017 Paul.  Add support for Exchange using Username/Password. 
		protected void MAIL_SENDTYPE_SelectedIndexChanged(object sender, EventArgs e)
		{
			DropDownList lstMAIL_SENDTYPE = FindControl("MAIL_SENDTYPE") as DropDownList;
			if ( lstMAIL_SENDTYPE != null )
			{
				string sMAIL_SENDTYPE = lstMAIL_SENDTYPE.SelectedValue;
				// 02/01/2017 Paul.  Blank is acceptable, but means that SMTP is not validated. 
				bool bSmtp = (String.Compare(sMAIL_SENDTYPE, "smtp", true) == 0);
				// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
				bool bExchange = (String.Compare(sMAIL_SENDTYPE, "Exchange-Password", true) == 0);
				tblSmtpPanel.Visible = bSmtp || bExchange;
				btnSmtpTest.Visible  = bSmtp || bExchange;
				new DynamicControl(this, "MAIL_SMTPSERVER"                ).Visible = bSmtp;
				new DynamicControl(this, "MAIL_SMTPSERVER_LABEL"          ).Visible = bSmtp;
				new DynamicControl(this, "MAIL_SMTPSERVER_REQUIRED_SYMBOL").Visible = bSmtp;
				new DynamicControl(this, "MAIL_SMTPPORT"                  ).Visible = bSmtp;
				new DynamicControl(this, "MAIL_SMTPPORT_LABEL"            ).Visible = bSmtp;
				new DynamicControl(this, "MAIL_SMTPPORT_REQUIRED_SYMBOL"  ).Visible = bSmtp;
				new DynamicControl(this, "MAIL_SMTPAUTH_REQ"              ).Visible = bSmtp;
				new DynamicControl(this, "MAIL_SMTPAUTH_REQ_LABEL"        ).Visible = bSmtp;
				new DynamicControl(this, "MAIL_SMTPSSL"                   ).Visible = bSmtp;
				new DynamicControl(this, "MAIL_SMTPSSL_LABEL"             ).Visible = bSmtp;
				// 02/02/2017 Paul.  Server and Port are only required if system values are not available. This allows for global settings. 
				if ( Sql.IsEmptyString(Application["CONFIG.smtpserver" ]) )
				{
					RequiredFieldValidator reqSERVER_URL = FindControl("MAIL_SMTPSERVER_REQUIRED") as RequiredFieldValidator;
					if ( reqSERVER_URL != null )
					{
						reqSERVER_URL.Enabled = bSmtp;
						reqSERVER_URL.EnableClientScript = bSmtp;
					}
					RequiredFieldValidator reqPORT = FindControl("MAIL_SMTPPORT_REQUIRED") as RequiredFieldValidator;
					if ( reqPORT != null )
					{
						reqPORT.Enabled = bSmtp;
						reqPORT.EnableClientScript = bSmtp;
					}
				}
				tblOffice365Panel .Visible = (String.Compare(sMAIL_SENDTYPE, "Office365" , true) == 0) && !Sql.IsEmptyGuid(gID);
				// 02/01/2017 Paul.  Always show Google Apps as old versions allowed SMTP send and Google sync. 
				// 07/24/2018 Paul.  Disable Google and iCloud. 
				tblGoogleAppsPanel.Visible = (tblGoogleAppsOptions.Rows.Count > 1) && !Sql.IsEmptyGuid(gID) && Sql.ToBoolean(Context.Application["CONFIG.GoogleApps.Enabled"]);
				tblICloudPanel    .Visible = (tblICloudOptions    .Rows.Count > 1) && !Sql.IsEmptyGuid(gID) && Sql.ToBoolean(Context.Application["CONFIG.iCloud.Enabled"]);
				// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
				btnGoogleAppsAuthorize.Enabled = GoogleApps.GoogleAppsEnabled(Application) && !Sql.IsEmptyGuid(gID);
				ctlDynamicButtons.ShowButton("Test", bSmtp || bExchange);
				ctlFooterButtons .ShowButton("Test", bSmtp || bExchange);

				if ( bExchange && Sql.IsEmptyString(Application["CONFIG.Exchange.ServerURL"]) )
				{
					lblSmtpAuthorizedStatus.Text = L10n.Term("OutboundEmail.LBL_EXCHANGE_NOT_ENABLED");
				}
				if ( Sql.IsEmptyString(Application["CONFIG.Exchange.ClientID"]) || Sql.IsEmptyString(Application["CONFIG.Exchange.ClientSecret"]) )
				{
					lblOffice365AuthorizedStatus.Text = L10n.Term("OutboundEmail.LBL_OFFICE365_NOT_ENABLED");
				}
				if ( !GoogleApps.GoogleAppsEnabled(Application) )
				{
					lblGoogleAuthorizedStatus.Text = L10n.Term("OutboundEmail.LBL_GOOGLEAPPS_NOT_ENABLED");
				}
				if ( !Sql.ToBoolean(Context.Application["CONFIG.iCloud.Enabled"]) )
				{
					
					lblCloudAuthorizedStatus.Text = L10n.Term("Users.LBL_ICLOUD_NOT_ENABLED");
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 07/11/2006 Paul.  Users must be able to view and edit their own settings. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = bMyAccount || (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			reqUSER_NAME.DataBind();
			reqLAST_NAME.DataBind();
			try
			{
				// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
				//Page.DataBind();
				gID = Sql.ToGuid(Request["ID"]);
				if ( bMyAccount )
				{
					gID = Security.USER_ID;
				}
				// 07/12/2006 Paul.  Status can only be edited by an administrator. 
				lstSTATUS.Enabled = false;
				// 12/06/2005 Paul.  A user can only edit his own user name if Windows Authentication is off. 
				if ( SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0 )
				{
					// 12/06/2005 Paul.  An administrator can always edit the user name.  This is to allow him to pre-add any NTLM users. 
					txtUSER_NAME.Enabled = true;
					lstSTATUS.Enabled = true;
				}
				else if ( gID == Security.USER_ID )
				{
					// 12/06/2005 Paul.  If editing yourself, then you can only edit if not NTLM. 
					// txtUSER_NAME.Enabled = !Security.IsWindowsAuthentication();
					// 11/26/2006 Paul.  A user cannot edit their own user name. This is a job for the admin. 
					txtUSER_NAME.Enabled = false;
				}
				else
				{
					// 12/06/2005 Paul.  If not an administrator and not editing yourself, then the name cannot be edited. 
					txtUSER_NAME.Enabled = false;
				}

				if ( !IsPostBack )
				{
					// 'date_formats' => array('Y-m-d'=>'2006-12-23', 'm-d-Y'=>'12-23-2006', 'Y/m/d'=>'2006/12/23', 'm/d/Y'=>'12/23/2006')
					// 'time_formats' => array('H:i'=>'23:00', 'h:ia'=>'11:00pm', 'h:iA'=>'11:00PM', 'H.i'=>'23.00', 'h.ia'=>'11.00pm', 'h.iA'=>'11.00PM' )
					lstSTATUS         .DataSource = SplendidCache.List("user_status_dom");
					lstSTATUS         .DataBind();
					// 08/05/2006 Paul.  Remove stub of unsupported code. Reminder is not supported at this time. 
					//lstREMINDER_TIME  .DataSource = SplendidCache.List("reminder_time_dom");
					//lstREMINDER_TIME  .DataBind();
					lstTIMEZONE       .DataSource = SplendidCache.TimezonesListbox();
					lstTIMEZONE       .DataBind();
					lstCURRENCY       .DataSource = SplendidCache.Currencies();
					lstCURRENCY       .DataBind();

					lstLANGUAGE.DataSource = SplendidCache.Languages();
					lstLANGUAGE.DataBind();
					lstLANGUAGE_Changed(null, null);
					lstTHEME.DataSource = SplendidCache.Themes();
					lstTHEME.DataBind();
					// 05/06/2009 Paul.  Add DEFAULT_TEAM to support SugarCRM migration. 
					tdDEFAULT_TEAM_Label.Visible = Crm.Config.enable_team_management();
					tdDEFAULT_TEAM_Field.Visible = tdDEFAULT_TEAM_Label.Visible;
					// 03/19/2011 Paul.  Facebook button should not be visible on an offline client. 
					bool bFacebookEnabled =!PrintView && !Utils.IsOfflineClient && Sql.ToBoolean(Application["CONFIG.facebook.EnableLogin"]) && !Sql.IsEmptyString(Application["CONFIG.facebook.AppID"]);
					ctlFacebookButtons.Visible = bFacebookEnabled;
					// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
					ctlDynamicButtons .Visible = !PrintView;

					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
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
								if ( !Sql.IsEmptyGuid(gDuplicateID) )
								{
									Sql.AddParameter(cmd, "@ID", gDuplicateID);
									gID = Guid.Empty;
								}
								else
								{
									Sql.AddParameter(cmd, "@ID", gID);
								}
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
											this.ApplyEditViewPreLoadEventRules(m_sMODULE + "." + LayoutEditView, rdr);
											
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = Sql.ToString(rdr["FULL_NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title + " (" + Sql.ToString(rdr["USER_NAME"]) + ")");
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
											
											this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain       , rdr);
											// 07/08/2010 Paul.  Move Users.EditAddress fields to Users.EditView
											//this.AppendEditViewFields(m_sMODULE + ".EditAddress"    , tblAddress    , rdr);
											// 08/05/2006 Paul.  Use the dynamic grid to create the fields, but populate manually. 
											// 02/01/2017 Paul.  EditMailOptions is not longer populated manually. 
											this.AppendEditViewFields(m_sMODULE + ".EditMailOptions"      , tblMailOptions      , rdr);
											// 02/01/2017 Paul.  Add support for Exchange using Username/Password. 
											this.AppendEditViewFields(m_sMODULE + ".SmtpView"             , tblSmtp             , rdr);
											// 01/16/2017 Paul.  Add support for Google Apps. The fields will be manually populated to prevent the password from getting to the browser. 
											this.AppendEditViewFields(m_sMODULE + ".EditGoogleAppsOptions", tblGoogleAppsOptions, rdr);
											// 01/16/2017 Paul.  Add support for Apple iCloud. The fields will be manually populated to prevent the password from getting to the browser. 
											this.AppendEditViewFields(m_sMODULE + ".EditICloudOptions"    , tblICloudOptions    , rdr);
											DropDownList lstMAIL_SENDTYPE = FindControl("MAIL_SENDTYPE") as DropDownList;
											if ( lstMAIL_SENDTYPE != null )
											{
												lstMAIL_SENDTYPE.AutoPostBack = true;
												lstMAIL_SENDTYPE.SelectedIndexChanged += new EventHandler(MAIL_SENDTYPE_SelectedIndexChanged);
												MAIL_SENDTYPE_SelectedIndexChanged(null, null);
											}
											// 04/20/2016 Paul.  Provide a way to allow each user to have their own SMTP server. 
											// 02/01/2017 Paul.  New method to manage sending mail. 
											//if ( !Sql.ToBoolean(Application["CONFIG.enable_separate_smtp_server"]) )
											//{
											//	new DynamicControl(this, "MAIL_SMTPSERVER"        ).Visible = false;
											//	new DynamicControl(this, "MAIL_SMTPPORT"          ).Visible = false;
											//	new DynamicControl(this, "MAIL_SMTPAUTH_REQ"      ).Visible = false;
											//	new DynamicControl(this, "MAIL_SMTPSSL"           ).Visible = false;
											//	new DynamicControl(this, "MAIL_SMTPSERVER_LABEL"  ).Visible = false;
											//	new DynamicControl(this, "MAIL_SMTPPORT_LABEL"    ).Visible = false;
											//	new DynamicControl(this, "MAIL_SMTPAUTH_REQ_LABEL").Visible = false;
											//	new DynamicControl(this, "MAIL_SMTPSSL_LABEL"     ).Visible = false;
											//}
											// 01/16/2017 Paul.  Move GoogleApps and iCloud up as it should not be applied just within a User. 
											// 03/25/2011 Paul.  Add support for Google Apps. The fields will be manually populated to prevent the password from getting to the browser. 
											//this.AppendEditViewFields(m_sMODULE + ".EditGoogleAppsOptions", tblGoogleAppsOptions, null);
											//tblGoogleAppsPanel.Visible = (tblGoogleAppsOptions.Rows.Count > 1) && Sql.ToBoolean(Context.Application["CONFIG.GoogleApps.Enabled"]);
											// 12/13/2011 Paul.  Add support for Apple iCloud. The fields will be manually populated to prevent the password from getting to the browser. 
											//this.AppendEditViewFields(m_sMODULE + ".EditICloudOptions", tblICloudOptions, null);
											//tblICloudPanel.Visible = (tblICloudOptions.Rows.Count > 1) && Sql.ToBoolean(Context.Application["CONFIG.iCloud.Enabled"]);
											
											// 03/28/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											// 11/29/2008 Paul   Dynamic buttons don't work well for user admin. 
											//ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, rdr);
											//ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, rdr);

											// 01/20/2008 Paul.  The mail options panel is manually populated. 
											// 02/01/2017 Paul.  EditMailOptions is not longer populated manually. 
											//new DynamicControl(this, "EMAIL1").Text = Sql.ToString (rdr["EMAIL1"]);
											//new DynamicControl(this, "EMAIL2").Text = Sql.ToString (rdr["EMAIL2"]);
											// 05/06/2009 Paul.  Add DEFAULT_TEAM to support SugarCRM migration. 
											new DynamicControl(this, "DEFAULT_TEAM"     ).Text = Sql.ToString (rdr["DEFAULT_TEAM"     ]);
											new DynamicControl(this, "DEFAULT_TEAM_NAME").Text = Sql.ToString (rdr["DEFAULT_TEAM_NAME"]);

											// main
											txtUSER_NAME            .Text    = Sql.ToString (rdr["USER_NAME"            ]);
											txtFIRST_NAME           .Text    = Sql.ToString (rdr["FIRST_NAME"           ]);
											txtLAST_NAME            .Text    = Sql.ToString (rdr["LAST_NAME"            ]);
											// 11/21/2014 Paul.  Add User Picture. 
											PICTURE                 .Value   = Sql.ToString (rdr["PICTURE"              ]);
											imgPICTURE              .Src     = Sql.ToString (rdr["PICTURE"              ]);
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
											try
											{
												bool bOFFICE365_OAUTH_ENABLED = Sql.ToBoolean(rdr["OFFICE365_OAUTH_ENABLED"]);
												btnOffice365Authorize   .Visible = !bOFFICE365_OAUTH_ENABLED;
												btnOffice365Delete      .Visible =  bOFFICE365_OAUTH_ENABLED;
												btnOffice365Test        .Visible =  bOFFICE365_OAUTH_ENABLED;
												btnOffice365RefreshToken.Visible =  bOFFICE365_OAUTH_ENABLED && bDebug;
												lblOffice365Authorized  .Visible =  bOFFICE365_OAUTH_ENABLED;
											}
											catch(Exception ex)
											{
												SplendidError.SystemError(new StackTrace(true).GetFrame(0), "OFFICE365_OAUTH_ENABLED is not defined. " + ex.Message);
											}
											try
											{
												bool bGOOGLEAPPS_OAUTH_ENABLED = Sql.ToBoolean(rdr["GOOGLEAPPS_OAUTH_ENABLED"]);
												btnGoogleAppsAuthorize   .Visible = !bGOOGLEAPPS_OAUTH_ENABLED;
												btnGoogleAppsDelete      .Visible =  bGOOGLEAPPS_OAUTH_ENABLED;
												btnGoogleAppsTest        .Visible =  bGOOGLEAPPS_OAUTH_ENABLED;
												btnGoogleAppsRefreshToken.Visible =  bGOOGLEAPPS_OAUTH_ENABLED && bDebug;
												lblGoogleAppsAuthorized  .Visible =  bGOOGLEAPPS_OAUTH_ENABLED;
											}
											catch(Exception ex)
											{
												SplendidError.SystemError(new StackTrace(true).GetFrame(0), "GOOGLEAPPS_OAUTH_ENABLED is not defined. " + ex.Message);
											}
											// 02/13/2022 Paul.  Sign in with Apple now uses OAuth 2.0. 
											try
											{
												bool bICLOUD_OAUTH_ENABLED = Sql.ToBoolean(rdr["ICLOUD_OAUTH_ENABLED"]);
												btnICloudAuthorize   .Visible = !bICLOUD_OAUTH_ENABLED;
												btnICloudDelete      .Visible =  bICLOUD_OAUTH_ENABLED;
												btnICloudTest        .Visible =  bICLOUD_OAUTH_ENABLED;
												btnICloudRefreshToken.Visible =  bICLOUD_OAUTH_ENABLED && bDebug;
												lblICloudAuthorized  .Visible =  bICLOUD_OAUTH_ENABLED;
											}
											catch(Exception ex)
											{
												SplendidError.SystemError(new StackTrace(true).GetFrame(0), "APPLE_OAUTH_ENABLED is not defined. " + ex.Message);
											}
											// 12/04/2005 Paul.  Only allow the admin flag to be changed if the current user is an admin. 
											chkIS_ADMIN.Enabled = Security.IS_ADMIN;
											// 03/16/2010 Paul.  Add IS_ADMIN_DELEGATE. 
											chkIS_ADMIN_DELEGATE.Enabled = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
											// 12/04/2005 Paul.  Save admin flag in ViewState to prevent hacking. 
											ViewState["IS_ADMIN"] = Sql.ToBoolean(rdr["IS_ADMIN"]);
											ViewState["IS_ADMIN_DELEGATE"] = Sql.ToBoolean(rdr["IS_ADMIN_DELEGATE"]);

											try
											{
												// 08/19/2010 Paul.  Check the list before assigning the value. 
												Utils.SetSelectedValue(lstSTATUS, Sql.ToString (rdr["STATUS"               ]));
											}
											catch(Exception ex)
											{
												SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
											}
											
											//12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
											/*
											string sUSER_PREFERENCES = Sql.ToString(rdr["USER_PREFERENCES"]);
											if ( !Sql.IsEmptyString(sUSER_PREFERENCES) )
											{
												XmlDocument xml = SplendidInit.InitUserPreferences(sUSER_PREFERENCES);
												try
												{
													ViewState["USER_PREFERENCES"] = xml.OuterXml;
													// user_settings
													// 08/12/2009 Paul.  A customer wants the ability to turn off the saved searches, both globally and on a per user basis. 
													chkSAVE_QUERY.Checked = Sql.ToBoolean(XmlUtil.SelectSingleNode(xml, "save_query"));
													// 02/26/2010 Paul.  Allow users to configure use of tabs. 
													chkGROUP_TABS.Checked = Sql.ToBoolean(XmlUtil.SelectSingleNode(xml, "group_tabs"));
													chkSUBPANEL_TABS.Checked = Sql.ToBoolean(XmlUtil.SelectSingleNode(xml, "subpanel_tabs"));
													try
													{
														// 08/19/2010 Paul.  Check the list before assigning the value. 
														Utils.SetSelectedValue(lstLANGUAGE, L10N.NormalizeCulture(XmlUtil.SelectSingleNode(xml, "culture")));
														lstLANGUAGE_Changed(null, null);
													}
													catch(Exception ex)
													{
														SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
													}
													try
													{
														// 02/29/2008 Paul.  Theme was not being set properly.  We were setting the language to the theme. 
														// 08/19/2010 Paul.  Check the list before assigning the value. 
														Utils.SetSelectedValue(lstTHEME, XmlUtil.SelectSingleNode(xml, "theme"));
													}
													catch(Exception ex)
													{
														SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
													}
													try
													{
														// 08/19/2010 Paul.  Check the list before assigning the value. 
														Utils.SetSelectedValue(lstDATE_FORMAT, XmlUtil.SelectSingleNode(xml, "dateformat"));
													}
													catch(Exception ex)
													{
														SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
													}
													try
													{
														// 08/19/2010 Paul.  Check the list before assigning the value. 
														Utils.SetSelectedValue(lstTIME_FORMAT, XmlUtil.SelectSingleNode(xml, "timeformat"));
													}
													catch(Exception ex)
													{
														SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
													}
													try
													{
														// 08/19/2010 Paul.  Check the list before assigning the value. 
														Utils.SetValue(lstTIMEZONE, XmlUtil.SelectSingleNode(xml, "timezone"));
													}
													catch(Exception ex)
													{
														SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
													}
													try
													{
														// 08/19/2010 Paul.  Check the list before assigning the value. 
														Utils.SetValue(lstCURRENCY, XmlUtil.SelectSingleNode(xml, "currency_id"));
													}
													catch(Exception ex)
													{
														SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
													}
													
													// mail_options
													// 07/08/2010 Paul.  The user must share the global mail server, so all we need here is the user name and password. 
													//new DynamicControl(this, "MAIL_FROMNAME"    ).Text    =               XmlUtil.SelectSingleNode(xml, "mail_fromname"        );
													//new DynamicControl(this, "MAIL_FROMADDRESS" ).Text    =               XmlUtil.SelectSingleNode(xml, "mail_fromaddress"     );
													//new DynamicControl(this, "MAIL_SENDTYPE"    ).Text    =               XmlUtil.SelectSingleNode(xml, "mail_sendtype"        );
													//new DynamicControl(this, "MAIL_SMTPSERVER"  ).Text    =               XmlUtil.SelectSingleNode(xml, "mail_smtpserver"      );
													//new DynamicControl(this, "MAIL_SMTPPORT"    ).Text    =               XmlUtil.SelectSingleNode(xml, "mail_smtpport"        );
													//new DynamicControl(this, "MAIL_SMTPAUTH_REQ").Checked = Sql.ToBoolean(XmlUtil.SelectSingleNode(xml, "mail_smtpauth_req"    ));
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
												// user_settings
												// 08/12/2009 Paul.  A customer wants the ability to turn off the saved searches, both globally and on a per user basis. 
												chkSAVE_QUERY   .Checked = Sql.ToBoolean(Sql.ToString(rdr["SAVE_QUERY"   ]));
												// 02/26/2010 Paul.  Allow users to configure use of tabs. 
												chkGROUP_TABS   .Checked = Sql.ToBoolean(Sql.ToString(rdr["GROUP_TABS"   ]));
												chkSUBPANEL_TABS.Checked = Sql.ToBoolean(Sql.ToString(rdr["SUBPANEL_TABS"]));
												try
												{
													// 08/19/2010 Paul.  Check the list before assigning the value. 
													Utils.SetSelectedValue(lstLANGUAGE, L10N.NormalizeCulture(Sql.ToString(rdr["LANG"])));
													lstLANGUAGE_Changed(null, null);
												}
												catch(Exception ex)
												{
													SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
												}
												try
												{
													// 02/29/2008 Paul.  Theme was not being set properly.  We were setting the language to the theme. 
													// 08/19/2010 Paul.  Check the list before assigning the value. 
													// 08/09/2017 Paul.  The theme may be blank, so we need to check for empty and possibly use system default. 
													string sTheme = Sql.ToString(rdr["THEME"]);
													if ( Sql.IsEmptyString(sTheme) || Sql.ToBoolean(Application["CONFIG.disable_theme_change"]) )
														sTheme = SplendidDefaults.Theme();
													Utils.SetSelectedValue(lstTHEME, sTheme);
													if ( Sql.ToBoolean(Application["CONFIG.disable_theme_change"]) )
														lstTHEME.Enabled = false;
												}
												catch(Exception ex)
												{
													SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
												}
												try
												{
													// 08/19/2010 Paul.  Check the list before assigning the value. 
													Utils.SetSelectedValue(lstDATE_FORMAT, Sql.ToString(rdr["DATE_FORMAT"]));
												}
												catch(Exception ex)
												{
													SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
												}
												try
												{
													// 08/19/2010 Paul.  Check the list before assigning the value. 
													Utils.SetSelectedValue(lstTIME_FORMAT, Sql.ToString(rdr["TIME_FORMAT"]));
												}
												catch(Exception ex)
												{
													SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
												}
												try
												{
													// 08/19/2010 Paul.  Check the list before assigning the value. 
													Utils.SetValue(lstTIMEZONE, Sql.ToString(rdr["TIMEZONE_ID"]));
												}
												catch(Exception ex)
												{
													SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
												}
												try
												{
													// 08/19/2010 Paul.  Check the list before assigning the value. 
													Utils.SetValue(lstCURRENCY, Sql.ToString(rdr["CURRENCY_ID"]));
												}
												catch(Exception ex)
												{
													SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
												}
											}
											catch(Exception ex)
											{
												SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
											}
											// 07/09/2010 Paul.  Move the SMTP values from USER_PREFERENCES to the main table to make it easier to access. 
											try
											{
												// 07/09/2010 Paul.  Move the SMTP values from USER_PREFERENCES to the main table to make it easier to access. 
												new DynamicControl(this, "MAIL_SMTPUSER"    ).Text    =               Sql.ToString (rdr["MAIL_SMTPUSER"               ]);
												//new DynamicControl(this, "MAIL_SMTPPASS"    ).Text    =               Sql.ToString (rdr["MAIL_SMTPPASS"               ]);
												
												string sMAIL_SMTPPASS = Sql.ToString (rdr["MAIL_SMTPPASS"]);
												ViewState["mail_smtppass"] = sMAIL_SMTPPASS;
												// 08/06/2005 Paul.  Never return password to user. 
												TextBox MAIL_SMTPPASS = FindControl("MAIL_SMTPPASS") as TextBox;
												if ( MAIL_SMTPPASS != null )
													MAIL_SMTPPASS.TextMode = TextBoxMode.Password;
												//btnSmtpTest.Visible = (txtMAIL_SMTPPASS != null);
												if ( MAIL_SMTPPASS != null && !Sql.IsEmptyString(sMAIL_SMTPPASS) )
												{
													// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
													// txtMAIL_SMTPPASS.Text = Sql.sEMPTY_PASSWORD;
													MAIL_SMTPPASS.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
												}
												// 06/02/2016 Paul.  Provide a way to allow each user to have their own SMTP server. 
												//if ( Sql.ToBoolean(Application["CONFIG.enable_separate_smtp_server"]) )
												//{
												//	new DynamicControl(this, "MAIL_SMTPSERVER"        ).Text    = Sql.ToString (rdr["MAIL_SMTPSERVER"  ]);
												//	new DynamicControl(this, "MAIL_SMTPPORT"          ).Text    = Sql.ToString (rdr["MAIL_SMTPPORT"    ]);
												//	new DynamicControl(this, "MAIL_SMTPAUTH_REQ"      ).Checked = Sql.ToBoolean(rdr["MAIL_SMTPAUTH_REQ"]);
												//	new DynamicControl(this, "MAIL_SMTPSSL"           ).Checked = Sql.ToBoolean(rdr["MAIL_SMTPSSL"     ]);
												//}
											}
											catch(Exception ex)
											{
												SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
											}
											// 03/25/2011 Paul.  Add support for Google Apps. 
											try
											{
												new DynamicControl(this, "GOOGLEAPPS_SYNC_CONTACTS").Checked = Sql.ToBoolean(rdr["GOOGLEAPPS_SYNC_CONTACTS"]);
												new DynamicControl(this, "GOOGLEAPPS_SYNC_CALENDAR").Checked = Sql.ToBoolean(rdr["GOOGLEAPPS_SYNC_CALENDAR"]);
												new DynamicControl(this, "GOOGLEAPPS_USERNAME"     ).Text    = Sql.ToString (rdr["GOOGLEAPPS_USERNAME"     ]);
												//new DynamicControl(this, "GOOGLEAPPS_PASSWORD"     ).Text    = Sql.ToString (rdr["GOOGLEAPPS_PASSWORD"     ]);
												
												string sGOOGLEAPPS_PASSWORD = Sql.ToString (rdr["GOOGLEAPPS_PASSWORD"]);
												ViewState["GOOGLEAPPS_PASSWORD"] = sGOOGLEAPPS_PASSWORD;
												// 03/25/2011 Paul.  Never return password to user. 
												TextBox txtGOOGLEAPPS_PASSWORD = FindControl("GOOGLEAPPS_PASSWORD") as TextBox;
												if ( txtGOOGLEAPPS_PASSWORD != null && !Sql.IsEmptyString(sGOOGLEAPPS_PASSWORD) )
												{
													// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
													txtGOOGLEAPPS_PASSWORD.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
												}
											}
											catch(Exception ex)
											{
												SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
											}
											// 12/13/2011 Paul.  Add support for Apple iCloud. 
											try
											{
												new DynamicControl(this, "ICLOUD_SYNC_CONTACTS").Checked = Sql.ToBoolean(rdr["ICLOUD_SYNC_CONTACTS"]);
												new DynamicControl(this, "ICLOUD_SYNC_CALENDAR").Checked = Sql.ToBoolean(rdr["ICLOUD_SYNC_CALENDAR"]);
												new DynamicControl(this, "ICLOUD_USERNAME"     ).Text    = Sql.ToString (rdr["ICLOUD_USERNAME"     ]);
												//new DynamicControl(this, "ICLOUD_PASSWORD"     ).Text    = Sql.ToString (rdr["ICLOUD_PASSWORD"     ]);
												
												string sICLOUD_PASSWORD = Sql.ToString (rdr["ICLOUD_PASSWORD"]);
												ViewState["ICLOUD_PASSWORD"] = sICLOUD_PASSWORD;
												// 12/13/2011 Paul.  Never return password to user. 
												TextBox txtICLOUD_PASSWORD = FindControl("ICLOUD_PASSWORD") as TextBox;
												if ( txtICLOUD_PASSWORD != null && !Sql.IsEmptyString(sICLOUD_PASSWORD) )
												{

													txtICLOUD_PASSWORD.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
												}
											}
											catch(Exception ex)
											{
												SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
											}
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, rdr);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, rdr);
											ctlDynamicButtons.Visible  = !PrintView;
											ctlFooterButtons .Visible  = !PrintView;
											
											// 12/09/2008 Paul.  Throw an exception if the record has been edited since the last load. 
											ViewState["LAST_DATE_MODIFIED"] = Sql.ToDateTime(rdr["DATE_MODIFIED"]);
											// 09/05/2013 Paul.  Use the Application as a cache for the Asterisk extension as we can correct by editing a user. 
											// 09/20/2013 Paul.  Move EXTENSION to the main table. 
											ViewState["EXTENSION"] = Sql.ToString(rdr["EXTENSION"]);
											// 11/10/2010 Paul.  Apply Business Rules. 
											this.ApplyEditViewPostLoadEventRules(m_sMODULE + "." + LayoutEditView, rdr);
										}
										else
										{
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
											ctlFooterButtons .DisableAll();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
										}
									}
								}
							}
						}
						// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
						ctlDynamicButtons.ShowButton("Facebook", bFacebookEnabled);
					}
					else
					{
						// 11/27/2009 Paul.  The password field only exists if this is a new user. 
						tdPASSWORD_Label.Visible = true;
						tdPASSWORD_Field.Visible = true;

						// 11/11/2008 Paul.  Display an error message if max users has been exceeded. 
						// 04/07/2015 Paul.  Change active user logic to use same as stored procedure. 
						int nActiveUsers = Crm.Users.ActiveUsers();
						int nMaxUsers = Sql.ToInteger(Crm.Config.Value("max_users"));
						if ( nMaxUsers > 0 && nActiveUsers > nMaxUsers )
						{
							ctlDynamicButtons .ErrorText = L10n.Term("Users.ERR_MAX_USERS");
							//ctlFacebookButtons.ErrorText = L10n.Term("Users.ERR_MAX_USERS");
						}

						this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain       , null);
						// 07/08/2010 Paul.  Move Users.EditAddress fields to Users.EditView
						//this.AppendEditViewFields(m_sMODULE + ".EditAddress"    , tblAddress    , null);
						this.AppendEditViewFields(m_sMODULE + ".EditMailOptions"      , tblMailOptions      , null);
						// 02/01/2017 Paul.  Add support for Exchange using Username/Password. 
						this.AppendEditViewFields(m_sMODULE + ".SmtpView"             , tblSmtp             , null);
						// 01/16/2017 Paul.  Add support for Office 365 OAuth. 
						// 01/16/2017 Paul.  Add support for Google Apps. The fields will be manually populated to prevent the password from getting to the browser. 
						this.AppendEditViewFields(m_sMODULE + ".EditGoogleAppsOptions", tblGoogleAppsOptions, null);
						// 01/16/2017 Paul.  Add support for Apple iCloud. The fields will be manually populated to prevent the password from getting to the browser. 
						this.AppendEditViewFields(m_sMODULE + ".EditICloudOptions"    , tblICloudOptions    , null);

						DropDownList lstMAIL_SENDTYPE = FindControl("MAIL_SENDTYPE") as DropDownList;
						if ( lstMAIL_SENDTYPE != null )
						{
							lstMAIL_SENDTYPE.AutoPostBack = true;
							lstMAIL_SENDTYPE.SelectedIndexChanged += new EventHandler(MAIL_SENDTYPE_SelectedIndexChanged);
							MAIL_SENDTYPE_SelectedIndexChanged(null, null);
						}
						// 04/20/2016 Paul.  Provide a way to allow each user to have their own SMTP server. 
						// 02/01/2017 Paul.  New method to manage sending mail. 
						//if ( !Sql.ToBoolean(Application["CONFIG.enable_separate_smtp_server"]) )
						//{
						//	new DynamicControl(this, "MAIL_SMTPSERVER"        ).Visible = false;
						//	new DynamicControl(this, "MAIL_SMTPPORT"          ).Visible = false;
						//	new DynamicControl(this, "MAIL_SMTPAUTH_REQ"      ).Visible = false;
						//	new DynamicControl(this, "MAIL_SMTPSSL"           ).Visible = false;
						//	new DynamicControl(this, "MAIL_SMTPSERVER_LABEL"  ).Visible = false;
						//	new DynamicControl(this, "MAIL_SMTPPORT_LABEL"    ).Visible = false;
						//	new DynamicControl(this, "MAIL_SMTPAUTH_REQ_LABEL").Visible = false;
						//	new DynamicControl(this, "MAIL_SMTPSSL_LABEL"     ).Visible = false;
						//}
						// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
						// 11/29/2008 Paul   Dynamic buttons don't work well for user admin. 
						//ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						//ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						
						// 02/01/2017 Paul.  Add support for Exchange using Username/Password. 
						TextBox MAIL_SMTPPASS = FindControl("MAIL_SMTPPASS") as TextBox;
						if ( MAIL_SMTPPASS != null )
							MAIL_SMTPPASS.TextMode = TextBoxMode.Password;
						//btnSmtpTest.Visible = (MAIL_SMTPPASS != null);
						btnOffice365Authorize .Visible = true;
						bool bOFFICE365_OAUTH_ENABLED = false;
						btnOffice365Authorize   .Visible = !bOFFICE365_OAUTH_ENABLED && !Sql.IsEmptyString(Application["CONFIG.Exchange.ClientID"]) && !Sql.IsEmptyString(Application["CONFIG.Exchange.ClientSecret"]);
						btnOffice365Delete      .Visible =  bOFFICE365_OAUTH_ENABLED;
						btnOffice365Test        .Visible =  bOFFICE365_OAUTH_ENABLED;
						btnOffice365RefreshToken.Visible =  bOFFICE365_OAUTH_ENABLED && bDebug;
						lblOffice365Authorized  .Visible =  bOFFICE365_OAUTH_ENABLED;
						bool bGOOGLEAPPS_OAUTH_ENABLED = false;
						btnGoogleAppsAuthorize   .Visible = !bGOOGLEAPPS_OAUTH_ENABLED && Sql.ToBoolean(Context.Application["CONFIG.GoogleApps.Enabled"]);
						btnGoogleAppsDelete      .Visible =  bGOOGLEAPPS_OAUTH_ENABLED;
						btnGoogleAppsTest        .Visible =  bGOOGLEAPPS_OAUTH_ENABLED;
						btnGoogleAppsRefreshToken.Visible =  bGOOGLEAPPS_OAUTH_ENABLED && bDebug;
						lblGoogleAppsAuthorized  .Visible =  bGOOGLEAPPS_OAUTH_ENABLED;
						// 02/13/2022 Paul.  Sign in with Apple now uses OAuth 2.0. 
						bool bICLOUD_OAUTH_ENABLED = false;
						btnICloudAuthorize   .Visible = !bICLOUD_OAUTH_ENABLED && Sql.ToBoolean(Context.Application["CONFIG.iCloud.Enabled"]);
						btnICloudDelete      .Visible =  bICLOUD_OAUTH_ENABLED;
						btnICloudTest        .Visible =  bICLOUD_OAUTH_ENABLED;
						btnICloudRefreshToken.Visible =  bICLOUD_OAUTH_ENABLED && bDebug;
						lblICloudAuthorized  .Visible =  bICLOUD_OAUTH_ENABLED;

						try
						{
							// 08/19/2010 Paul.  Check the list before assigning the value. 
							Utils.SetSelectedValue(this.lstTHEME, SplendidDefaults.Theme());
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						try
						{
							// 11/27/2009 Paul.  The default language should pull from Config. 
							// 11/27/2009 Paul.  Make sure to normalize as the default format may be 'en_us'. 
							string sDefault = L10N.NormalizeCulture(Sql.ToString(Application["CONFIG.default_language"]));
							if ( Sql.IsEmptyString(sDefault) )
								sDefault = "en-US";
							// 08/19/2010 Paul.  Check the list before assigning the value. 
							Utils.SetSelectedValue(lstLANGUAGE, sDefault);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						try
						{
							lstLANGUAGE_Changed(null, null);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						// 11/27/2009 Paul.  Make sure that the language is first as it can change the date and time formats. 
						try
						{
							// 11/27/2009 Paul.  The default date format should pull from Config. 
							string sDefault = Sql.ToString(Application["CONFIG.default_date_format"]);
							if ( !Sql.IsEmptyString(sDefault) )
								// 08/19/2010 Paul.  Check the list before assigning the value. 
								Utils.SetSelectedValue(this.lstDATE_FORMAT, sDefault);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						try
						{
							// 11/27/2009 Paul.  The default time format should pull from Config. 
							string sDefault = Sql.ToString(Application["CONFIG.default_time_format"]);
							if ( !Sql.IsEmptyString(sDefault) )
								// 08/19/2010 Paul.  Check the list before assigning the value. 
								Utils.SetSelectedValue(this.lstTIME_FORMAT, sDefault);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						try
						{
							// 11/27/2009 Paul.  The default time zone should pull from Config. 
							string sDefault = Sql.ToString(Application["CONFIG.default_timezone"]);
							if ( !Sql.IsEmptyString(sDefault) )
								// 08/19/2010 Paul.  Check the list before assigning the value. 
								Utils.SetValue(this.lstTIMEZONE, sDefault.ToLower());
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						try
						{
							// 11/27/2009 Paul.  The default currency should pull from Config. 
							string sDefault = Sql.ToString(Application["CONFIG.default_currency"]);
							if ( !Sql.IsEmptyString(sDefault) )
								// 08/19/2010 Paul.  Check the list before assigning the value. 
								Utils.SetValue(this.lstCURRENCY, sDefault.ToLower());
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						// 02/27/2010 Paul.  For a new user, the Group Tabs and SubPanel Tabs flags may not have been saved, so manually include. 
						// 02/11/2010 Paul.  Set the default value for Save Query. 
						chkSAVE_QUERY   .Checked = Sql.ToBoolean(Application["CONFIG.save_query"   ]) || Sql.ToBoolean(Session["USER_SETTINGS/SAVE_QUERY"      ]);
						// 02/26/2010 Paul.  Allow users to configure use of tabs. 
						chkGROUP_TABS   .Checked = Sql.ToBoolean(Application["CONFIG.group_tabs"   ]) || Sql.ToBoolean(Session["USER_SETTINGS/GROUP_TABS"      ]);
						chkSUBPANEL_TABS.Checked = Sql.ToBoolean(Application["CONFIG.subpanel_tabs"]) || Sql.ToBoolean(Session["USER_SETTINGS/SUBPANEL_TABS"   ]);
						// 11/10/2010 Paul.  Apply Business Rules. 
						this.ApplyEditViewNewEventRules(m_sMODULE + "." + LayoutEditView);
						this.ApplyEditViewNewEventRules(m_sMODULE + ".EditMailOptions");
						// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						ctlDynamicButtons.Visible  = !PrintView;
						ctlFooterButtons .Visible  = !PrintView;
					}
				}
				else
				{
					// 12/02/2005 Paul.  When validation fails, the header title does not retain its value.  Update manually. 
					// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons .ErrorText = ex.Message;
				//ctlFacebookButtons.ErrorText = ex.Message;
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
			ctlDynamicButtons .Command += new CommandEventHandler(Page_Command);
			ctlFooterButtons  .Command += new CommandEventHandler(Page_Command);
			// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
			//ctlFacebookButtons.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Users";
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				// 12/02/2005 Paul.  Need to add the edit fields in order for events to fire. 
				this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain       , null);
				// 07/08/2010 Paul.  Move Users.EditAddress fields to Users.EditView
				//this.AppendEditViewFields(m_sMODULE + ".EditAddress"    , tblAddress    , null);
				this.AppendEditViewFields(m_sMODULE + ".EditMailOptions"      , tblMailOptions      , null);
				this.AppendEditViewFields(m_sMODULE + ".SmtpView"             , tblSmtp             , null);
				// 03/25/2011 Paul.  Add support for Google Apps. 
				this.AppendEditViewFields(m_sMODULE + ".EditGoogleAppsOptions", tblGoogleAppsOptions, null);
				// 12/13/2011 Paul.  Add support for Apple iCloud. 
				this.AppendEditViewFields(m_sMODULE + ".EditICloudOptions"    , tblICloudOptions    , null);

				DropDownList lstMAIL_SENDTYPE = FindControl("MAIL_SENDTYPE") as DropDownList;
				if ( lstMAIL_SENDTYPE != null )
				{
					lstMAIL_SENDTYPE.AutoPostBack = true;
					lstMAIL_SENDTYPE.SelectedIndexChanged += new EventHandler(MAIL_SENDTYPE_SelectedIndexChanged);
				}
				TextBox MAIL_SMTPPASS = FindControl("MAIL_SMTPPASS") as TextBox;
				if ( MAIL_SMTPPASS != null )
					MAIL_SMTPPASS.TextMode = TextBoxMode.Password;
				// 02/01/2017 Paul.  Add support for Exchange using Username/Password. 
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				// 11/29/2008 Paul   Dynamic buttons don't work well for user admin. 
				//ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				//ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				// 11/10/2010 Paul.  Make sure to add the RulesValidator early in the pipeline. 
				// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				Page.Validators.Add(new RulesValidator(this));
			}
		}
		#endregion
	}
}

