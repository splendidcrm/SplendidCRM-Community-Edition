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
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Xml;
using System.Globalization;
using System.Threading;

namespace SplendidCRM.Users
{
	/// <summary>
	///		Summary description for UserWizard.
	/// </summary>
	public class UserWizard : SplendidControl
	{
		protected Label        lblError              ;
		
		protected int          nWizardPanel          ;
		protected Table        tblUserSettings       ;
		protected Table        tblUserLocale         ;
		protected Table        tblMailSettings       ;

		// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
		//private const string sEMPTY_PASSWORD = "**********";
		protected TextBox      FIRST_NAME            ;
		protected TextBox      LAST_NAME             ;
		protected TextBox      EMAIL1                ;
		protected TextBox      PHONE_WORK            ;
		protected TextBox      PHONE_MOBILE          ;
		protected TextBox      ADDRESS_STREET        ;
		protected TextBox      ADDRESS_CITY          ;
		protected TextBox      ADDRESS_STATE         ;
		protected TextBox      ADDRESS_POSTALCODE    ;
		protected TextBox      ADDRESS_COUNTRY       ;

		protected DropDownList lstLANGUAGE           ;
		protected DropDownList lstDATE_FORMAT        ;
		protected DropDownList lstTIME_FORMAT        ;
		protected DropDownList lstCURRENCY           ;
		protected DropDownList lstTIMEZONE           ;
		
		protected Label        MAIL_SMTPSERVER       ;
		protected TextBox      MAIL_SMTPUSER         ;
		protected TextBox      MAIL_SMTPPASS         ;

		protected RequiredFieldValidator     LAST_NAME_REQUIRED;
		protected RequiredFieldValidator     EMAIL1_REQUIRED   ;
		protected RegularExpressionValidator EMAIL1_VALIDATOR  ;

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

		protected void SaveUserSettings()
		{
			LAST_NAME_REQUIRED.Validate();
			EMAIL1_REQUIRED   .Validate();
			EMAIL1_VALIDATOR  .Validate();
			if ( LAST_NAME_REQUIRED.IsValid && EMAIL1_REQUIRED.IsValid && EMAIL1_VALIDATOR.IsValid )
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					DataRow   rowCurrent = null;
					DataTable dtCurrent  = new DataTable();
					string sSQL ;
					sSQL = "select *           " + ControlChars.CrLf
					     + "  from vwUSERS_Edit" + ControlChars.CrLf
					     + " where ID = @ID    " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@ID", Security.USER_ID);
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dtCurrent);
							if ( dtCurrent.Rows.Count == 0 )
								throw(new Exception("User not found."));
							else
								rowCurrent = dtCurrent.Rows[0];
						}
					}
					
					Guid gID = Security.USER_ID;
					// 04/20/2016 Paul.  Provide a way to allow each user to have their own SMTP server. 
					SqlProcs.spUSERS_Update
						( ref gID
						, Sql.ToString(rowCurrent["USER_NAME"])
						, FIRST_NAME.Text
						, LAST_NAME .Text
						, Sql.ToGuid   (rowCurrent["REPORTS_TO_ID"        ])
						, Sql.ToBoolean(rowCurrent["IS_ADMIN"             ])
						, Sql.ToBoolean(rowCurrent["RECEIVE_NOTIFICATIONS"])
						, Sql.ToString (rowCurrent["DESCRIPTION"          ])
						, Sql.ToString (rowCurrent["TITLE"                ])
						, Sql.ToString (rowCurrent["DEPARTMENT"           ])
						, Sql.ToString (rowCurrent["PHONE_HOME"           ])
						, PHONE_MOBILE      .Text
						, PHONE_WORK        .Text
						, Sql.ToString (rowCurrent["PHONE_OTHER"          ])
						, Sql.ToString (rowCurrent["PHONE_FAX"            ])
						, EMAIL1            .Text
						, Sql.ToString (rowCurrent["EMAIL2"               ])
						, Sql.ToString (rowCurrent["STATUS"               ])
						, ADDRESS_STREET    .Text
						, ADDRESS_CITY      .Text
						, ADDRESS_STATE     .Text
						, ADDRESS_POSTALCODE.Text
						, ADDRESS_COUNTRY   .Text
						, Sql.ToString (rowCurrent["USER_PREFERENCES"     ])
						, Sql.ToBoolean(rowCurrent["PORTAL_ONLY"          ])
						, Sql.ToString (rowCurrent["EMPLOYEE_STATUS"      ])
						, Sql.ToString (rowCurrent["MESSENGER_ID"         ])
						, Sql.ToString (rowCurrent["MESSENGER_TYPE"       ])
						, String.Empty // MODULE
						, Guid.Empty   // PARENT_ID
						, Sql.ToBoolean(rowCurrent["IS_GROUP"             ])
						, Sql.ToGuid   (rowCurrent["DEFAULT_TEAM"         ])
						, Sql.ToBoolean(rowCurrent["IS_ADMIN_DELEGATE"    ])
						, Sql.ToString (rowCurrent["MAIL_SMTPUSER"        ])
						, Sql.ToString (rowCurrent["MAIL_SMTPPASS"        ])
						// 03/04/2011 Paul.  We need to allow the admin to set the flag to force a password change. 
						, Sql.ToBoolean(Session["SYSTEM_GENERATED_PASSWORD"])
						// 03/25/2011 Paul.  Add support for Google Apps. 
						, Sql.ToBoolean(rowCurrent["GOOGLEAPPS_SYNC_CONTACTS"])
						, Sql.ToBoolean(rowCurrent["GOOGLEAPPS_SYNC_CALENDAR"])
						, Sql.ToString (rowCurrent["GOOGLEAPPS_USERNAME"     ])
						, Sql.ToString (rowCurrent["GOOGLEAPPS_PASSWORD"     ])
						// 03/25/2011 Paul.  Create a separate field for the Facebook ID. 
						, Sql.ToString (rowCurrent["FACEBOOK_ID"             ])
						// 12/13/2011 Paul.  Add support for Apple iCloud. 
						, Sql.ToBoolean(rowCurrent["ICLOUD_SYNC_CONTACTS"])
						, Sql.ToBoolean(rowCurrent["ICLOUD_SYNC_CALENDAR"])
						, Sql.ToString (rowCurrent["ICLOUD_USERNAME"     ])
						, Sql.ToString (rowCurrent["ICLOUD_PASSWORD"     ])
						// 12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
						, Sql.ToString (rowCurrent["THEME"               ])
						, Sql.ToString (rowCurrent["DATE_FORMAT"         ])
						, Sql.ToString (rowCurrent["TIME_FORMAT"         ])
						, Sql.ToString (rowCurrent["LANG"                ])
						, Sql.ToGuid   (rowCurrent["CURRENCY_ID"         ])
						, Sql.ToGuid   (rowCurrent["TIMEZONE_ID"         ])
						, Sql.ToBoolean(rowCurrent["SAVE_QUERY"          ])
						, Sql.ToBoolean(rowCurrent["GROUP_TABS"          ])
						, Sql.ToBoolean(rowCurrent["SUBPANEL_TABS"       ])
						// 09/20/2013 Paul.  Move EXTENSION to the main table. 
						, Sql.ToString (rowCurrent["EXTENSION"           ])
						// 09/27/2013 Paul.  SMS messages need to be opt-in. 
						, Sql.ToString (rowCurrent["SMS_OPT_IN"          ])
						// 11/21/2014 Paul.  Add User Picture. 
						, Sql.ToString (rowCurrent["PICTURE"             ])
						// 04/20/2016 Paul.  Provide a way to allow each user to have their own SMTP server. 
						, Sql.ToString (rowCurrent["MAIL_SMTPSERVER"     ])
						, Sql.ToInteger(rowCurrent["MAIL_SMTPPORT"       ])
						, Sql.ToBoolean(rowCurrent["MAIL_SMTPAUTH_REQ"   ])
						, Sql.ToInteger(rowCurrent["MAIL_SMTPSSL"        ])
						// 02/01/2017 Paul.  Add support for Exchange using Username/Password. 
						, Sql.ToString (rowCurrent["MAIL_SENDTYPE"       ])
						);
				}
			}
		}

		protected void SaveUserLocale()
		{
			//string sUSER_PREFERENCES = Sql.ToString(ViewState["USER_PREFERENCES"]);
			//if ( Sql.IsEmptyString(sUSER_PREFERENCES) )
			//	sUSER_PREFERENCES = "<xml></xml>";
			
			//XmlDocument xml = SplendidInit.InitUserPreferences(sUSER_PREFERENCES);
			//XmlUtil.SetSingleNode(xml, "culture"    , lstLANGUAGE.SelectedValue   );
			//XmlUtil.SetSingleNode(xml, "dateformat" , lstDATE_FORMAT.SelectedValue);
			//XmlUtil.SetSingleNode(xml, "timeformat" , lstTIME_FORMAT.SelectedValue);
			//XmlUtil.SetSingleNode(xml, "timezone"   , lstTIMEZONE.SelectedValue   );
			//XmlUtil.SetSingleNode(xml, "currency_id", lstCURRENCY.SelectedValue   );
			
			//SqlProcs.spUSERS_PreferencesUpdate(Security.USER_ID, xml.OuterXml);
			//ViewState["USER_PREFERENCES"] = xml.OuterXml;
			
			// 12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
			SqlProcs.spUSERS_WizardUpdate(Security.USER_ID, lstDATE_FORMAT.SelectedValue, lstTIME_FORMAT.SelectedValue, lstLANGUAGE.SelectedValue, Sql.ToGuid(lstCURRENCY.SelectedValue), Sql.ToGuid(lstTIMEZONE.SelectedValue));
			SplendidInit.LoadUserPreferences(Security.USER_ID, String.Empty, lstLANGUAGE.SelectedValue);
		}

		protected void SaveMailSettings()
		{
			Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
			Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
			string sMAIL_SMTPPASS = MAIL_SMTPPASS.Text;
			string sENCRYPTED_EMAIL_PASSWORD = String.Empty;
			// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
			if ( sMAIL_SMTPPASS == Sql.sEMPTY_PASSWORD )
			{
				sENCRYPTED_EMAIL_PASSWORD = Sql.ToString(ViewState["mail_smtppass"]);
			}
			else if ( !Sql.IsEmptyString(sMAIL_SMTPPASS) )
			{
				sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sMAIL_SMTPPASS, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
				ViewState["mail_smtppass"] = sENCRYPTED_EMAIL_PASSWORD;
				// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
				MAIL_SMTPPASS.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
			}
			
			// 07/09/2010 Paul.  SMTP values belong in the OUTBOUND_EMAILS table. 
			// 04/20/2016 Paul.  Provide a way to allow each user to have their own SMTP server. 
			// 02/01/2017 Paul.  Add support for Exchange using Username/Password. 
			string sMAIL_SENDTYPE = "smtp";
			SqlProcs.spOUTBOUND_EMAILS_UpdateUser(Security.USER_ID, MAIL_SMTPUSER.Text, sENCRYPTED_EMAIL_PASSWORD, String.Empty, 0, false, 0, sMAIL_SENDTYPE);
			Security.MAIL_SMTPUSER = MAIL_SMTPUSER.Text;
			Security.MAIL_SMTPPASS = sENCRYPTED_EMAIL_PASSWORD;
			// 07/18/2013 Paul.  Add support for multiple outbound emails. 
			SplendidCache.ClearOutboundMail();
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Skip" )
				{
					// 06/15/2017 Paul.  Add support for HTML5 Home Page. 
					Response.Redirect(Sql.ToString(Application["Modules.Home.RelativePath"]));
				}
				else if ( e.CommandName == "Finish" )
				{
					// 07/29/2010 Paul.  The Mail Settings is the last page, so we will get a Finish event and not a Next event. 
					if ( tblMailSettings.Visible )
					{
						SaveMailSettings();
					}
					// 06/15/2017 Paul.  Add support for HTML5 Home Page. 
					Response.Redirect(Sql.ToString(Application["Modules.Home.RelativePath"]));
				}
				else if ( e.CommandName == "Next" )
				{
					if ( tblUserSettings.Visible )
					{
						SaveUserSettings();
					}
					else if ( tblUserLocale.Visible )
					{
						SaveUserLocale();
					}
					else if ( tblMailSettings.Visible )
					{
						SaveMailSettings();
					}
					nWizardPanel++;
					ActivatePanel();
					ViewState["WizardPanel"] = nWizardPanel;
				}
				else if ( e.CommandName == "Back" )
				{
					if ( nWizardPanel > 0 )
					{
						nWizardPanel--;
						ActivatePanel();
						ViewState["WizardPanel"] = nWizardPanel;
					}
				}
				else if ( e.CommandName == "Smtp.Test" )
				{
					Guid gINBOUND_EMAIL_KEY = Sql.ToGuid(Application["CONFIG.InboundEmailKey"]);
					Guid gINBOUND_EMAIL_IV  = Sql.ToGuid(Application["CONFIG.InboundEmailIV" ]);
					string sMAIL_SMTPPASS = MAIL_SMTPPASS.Text;
					// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
					if ( sMAIL_SMTPPASS == Sql.sEMPTY_PASSWORD )
					{
						sMAIL_SMTPPASS = Sql.ToString(ViewState["mail_smtppass"]);
						if ( !Sql.IsEmptyString(sMAIL_SMTPPASS) )
							sMAIL_SMTPPASS = Security.DecryptPassword(sMAIL_SMTPPASS, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
					}
					string sSmtpServer      = Sql.ToString (Application["CONFIG.smtpserver"  ]);
					int    nSmtpPort        = Sql.ToInteger(Application["CONFIG.smtpport"    ]);
					bool   bSmtpAuthReq     = Sql.ToBoolean(Application["CONFIG.smtpauth_req"]);
					bool   bSmtpSSL         = Sql.ToBoolean(Application["CONFIG.smtpssl"     ]);
					string sSmtpUser        = MAIL_SMTPUSER    .Text;
					string sSmtpPassword    = sMAIL_SMTPPASS;
					string sFromName        = (FIRST_NAME.Text + " " + LAST_NAME.Text).Trim();
					string sFromAddress     = EMAIL1.Text;
					EmailUtils.SendTestMessage(Application, sSmtpServer, nSmtpPort, bSmtpAuthReq, bSmtpSSL, sSmtpUser, sSmtpPassword, sFromAddress, sFromName, sFromAddress, sFromName);
					lblError.Text = "Send was successful.";
					// 07/29/2010 Paul.  Only save the password if the send was successful. 
					if ( !Sql.IsEmptyString(sMAIL_SMTPPASS) )
					{
						string sENCRYPTED_EMAIL_PASSWORD = Security.EncryptPassword(sMAIL_SMTPPASS, gINBOUND_EMAIL_KEY, gINBOUND_EMAIL_IV);
						ViewState["mail_smtppass"] = sENCRYPTED_EMAIL_PASSWORD;
						// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
						MAIL_SMTPPASS.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void ActivatePanel()
		{
			tblUserSettings.Visible = (nWizardPanel == 0);
			tblUserLocale  .Visible = (nWizardPanel == 1);
			tblMailSettings.Visible = (nWizardPanel == 2);
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
			if ( !IsPostBack )
			{
				try
				{
					// 10/18/2010 Paul.  The required fields need to be bound manually. 
					LAST_NAME_REQUIRED.Validate();
					EMAIL1_REQUIRED   .Validate();
					EMAIL1_VALIDATOR  .Validate();

					lstLANGUAGE.DataSource = SplendidCache.Languages();
					lstLANGUAGE.DataBind();
					lstCURRENCY.DataSource = SplendidCache.Currencies();
					lstCURRENCY.DataBind();
					lstTIMEZONE.DataSource = SplendidCache.TimezonesListbox();
					lstTIMEZONE.DataBind();
					// 07/09/2010 Paul.  Need to initialize the date/time dropdowns. 
					// 07/09/2010 Paul.  Need to initialize all locale values from the system defaults. 
					try
					{
						// 08/19/2010 Paul.  Check the list before assigning the value. 
						Utils.SetSelectedValue(lstLANGUAGE, L10N.NormalizeCulture(Sql.ToString(Application["CONFIG.default_language"])));
						lstLANGUAGE_Changed(null, null);
					}
					catch(Exception ex)
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
					}
					try
					{
						// 08/19/2010 Paul.  Check the list before assigning the value. 
						Utils.SetSelectedValue(lstDATE_FORMAT, Sql.ToString(Application["CONFIG.default_date_format"]));
					}
					catch(Exception ex)
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
					}
					try
					{
						// 08/19/2010 Paul.  Check the list before assigning the value. 
						Utils.SetSelectedValue(lstTIME_FORMAT, Sql.ToString(Application["CONFIG.default_time_format"]));
					}
					catch(Exception ex)
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
					}
					try
					{
						string sCURRENCY = Sql.ToString(Application["CONFIG.default_currency"]);
						if ( !Sql.IsEmptyString(sCURRENCY) )
						{
							// 07/09/2010 Paul.  Normalize the GUID so that there will not be a case significant issue. 
							// 08/19/2010 Paul.  Check the list before assigning the value. 
							Utils.SetValue(lstCURRENCY, Sql.ToGuid(sCURRENCY).ToString());
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
					}
					try
					{
						string sTIMEZONE = Sql.ToString(Application["CONFIG.default_timezone"]);
						if ( !Sql.IsEmptyString(sTIMEZONE) )
						{
							// 07/09/2010 Paul.  Normalize the GUID so that there will not be a case significant issue. 
							// 08/19/2010 Paul.  Check the list before assigning the value. 
							Utils.SetValue(lstTIMEZONE, Sql.ToGuid(sTIMEZONE).ToString());
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
					}
					
					MAIL_SMTPSERVER.Text = Sql.ToString(Application["CONFIG.smtpserver"]);
					
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sSQL ;
						sSQL = "select *           " + ControlChars.CrLf
						     + "  from vwUSERS_Edit" + ControlChars.CrLf
						     + " where ID = @ID    " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@ID", Security.USER_ID);

							if ( bDebug )
								RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

							using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
							{
								if ( rdr.Read() )
								{
									FIRST_NAME        .Text = Sql.ToString (rdr["FIRST_NAME"        ]);
									LAST_NAME         .Text = Sql.ToString (rdr["LAST_NAME"         ]);
									EMAIL1            .Text = Sql.ToString (rdr["EMAIL1"            ]);
									PHONE_WORK        .Text = Sql.ToString (rdr["PHONE_WORK"        ]);
									PHONE_MOBILE      .Text = Sql.ToString (rdr["PHONE_MOBILE"      ]);
									ADDRESS_STREET    .Text = Sql.ToString (rdr["ADDRESS_STREET"    ]);
									ADDRESS_CITY      .Text = Sql.ToString (rdr["ADDRESS_CITY"      ]);
									ADDRESS_STATE     .Text = Sql.ToString (rdr["ADDRESS_STATE"     ]);
									ADDRESS_POSTALCODE.Text = Sql.ToString (rdr["ADDRESS_POSTALCODE"]);
									ADDRESS_COUNTRY   .Text = Sql.ToString (rdr["ADDRESS_COUNTRY"   ]);

									string sUSER_PREFERENCES = Sql.ToString(rdr["USER_PREFERENCES"]);
									if ( !Sql.IsEmptyString(sUSER_PREFERENCES) )
									{
										XmlDocument xml = SplendidInit.InitUserPreferences(sUSER_PREFERENCES);
										try
										{
											ViewState["USER_PREFERENCES"] = xml.OuterXml;
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
												string sTIMEZONE = XmlUtil.SelectSingleNode(xml, "timezone");
												if ( !Sql.IsEmptyString(sTIMEZONE) )
												{
													// 07/09/2010 Paul.  Normalize the GUID so that there will not be a case significant issue. 
													// 08/19/2010 Paul.  Check the list before assigning the value. 
													Utils.SetValue(lstTIMEZONE, Sql.ToGuid(sTIMEZONE).ToString());
												}
											}
											catch(Exception ex)
											{
												SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
											}
											try
											{
												string sCURRENCY = XmlUtil.SelectSingleNode(xml, "currency_id");
												if ( !Sql.IsEmptyString(sCURRENCY) )
												{
													// 07/09/2010 Paul.  Normalize the GUID so that there will not be a case significant issue. 
													// 08/19/2010 Paul.  Check the list before assigning the value. 
													Utils.SetValue(lstCURRENCY, Sql.ToGuid(sCURRENCY).ToString());
												}
											}
											catch(Exception ex)
											{
												SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
											}
											
											MAIL_SMTPUSER.Text = XmlUtil.SelectSingleNode(xml, "mail_smtpuser");
											ViewState["mail_smtppass"] = XmlUtil.SelectSingleNode(xml, "mail_smtppass");
											// 08/06/2005 Paul.  Never return password to user. 
											if ( !Sql.IsEmptyString(ViewState["mail_smtppass"]) )
											{
												// 11/08/2019 Paul.  Move sEMPTY_PASSWORD to Sql. 
												MAIL_SMTPPASS.Attributes.Add("value", Sql.sEMPTY_PASSWORD);
											}
										}
										catch(Exception ex)
										{
											SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
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
					lblError.Text = ex.Message;
				}
				ViewState["WizardPanel"] = 0;
				ActivatePanel();
			}
			nWizardPanel = Sql.ToInteger(ViewState["WizardPanel"]);
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
			m_sMODULE = "Users";
		}
		#endregion
	}
}

