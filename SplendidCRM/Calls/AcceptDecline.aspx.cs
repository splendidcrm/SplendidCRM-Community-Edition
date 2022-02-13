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
using System.Collections;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Calls
{
	/// <summary>
	/// Summary description for AcceptDecline.
	/// </summary>
	public class AcceptDecline : SplendidPage
	{
		protected Literal         litReminder;
		protected Label           lblError   ;

		override protected bool AuthenticationRequired()
		{
			return false;
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				Guid   gID            = Sql.ToGuid  (Request["ID"           ]);
				Guid   gINVITEE_ID    = Sql.ToGuid  (Request["INVITEE_ID"   ]);
				string sACCEPT_STATUS = Sql.ToString(Request["ACCEPT_STATUS"]).ToLower();
				if ( sACCEPT_STATUS != "accept" && sACCEPT_STATUS != "tentative" && sACCEPT_STATUS != "decline" )
					sACCEPT_STATUS = String.Empty;
				if ( !Sql.IsEmptyGuid(gID) && !Sql.IsEmptyGuid(gINVITEE_ID) && !Sql.IsEmptyString(sACCEPT_STATUS) )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sSQL;
						sSQL = "select *                          " + ControlChars.CrLf
						     + "  from vwACTIVITIES_Invitees      " + ControlChars.CrLf
						     + " where ID            = @ID        " + ControlChars.CrLf
						     + "   and INVITEE_ID    = @INVITEE_ID" + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@ID"        , gID        );
							Sql.AddParameter(cmd, "@INVITEE_ID", gINVITEE_ID);
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									if ( dt.Rows.Count > 0 )
									{
										DataRow row = dt.Rows[0];
										string sACTIVITY_TYPE = Sql.ToString(row["ACTIVITY_TYPE"]);
										string sINVITEE_TYPE  = Sql.ToString(row["INVITEE_TYPE" ]);
										string sINVITEE_LANG  = Sql.ToString(row["LANG"         ]);
										Guid   gTIMEZONE_ID   = Sql.ToGuid  (row["TIMEZONE_ID"  ]);
										
										if ( sACTIVITY_TYPE == "Calls" )
											SqlProcs.spCALLS_UpdateAcceptStatus(gID, sINVITEE_TYPE, gINVITEE_ID, sACCEPT_STATUS);
										else if ( sACTIVITY_TYPE == "Meetings" )
											SqlProcs.spMEETINGS_UpdateAcceptStatus(gID, sINVITEE_TYPE, gINVITEE_ID, sACCEPT_STATUS);
										
										// 12/26/2012 Paul.  If this is a user, then view the record. 
										if ( sINVITEE_TYPE == "Users" )
											Response.Redirect("~/" + sACTIVITY_TYPE + "/view.aspx?ID=" + gID.ToString());
										
										// 12/26/2012 Paul.  If this is not a user, then display the Reminder message. 
										string     sSiteURL         = Crm.Config.SiteURL(Application);
										Guid       gDefaultTimezone = Sql.ToGuid  (Application["CONFIG.default_timezone"]);
										string     sDefaultLanguage = Sql.ToString(Application["CONFIG.default_language"]);
										L10N       L10nEN           = new L10N("en-US");
										DataView   vwColumns        = EmailUtils.SortedTableColumns(dt);
										Hashtable  hashEnumsColumns = EmailUtils.EnumColumns(Application, "Calls");
										
										if ( !Sql.IsEmptyGuid(gTIMEZONE_ID) )
											gTIMEZONE_ID = gDefaultTimezone;
										if ( !Sql.IsEmptyString(sINVITEE_LANG) )
											sINVITEE_LANG = sDefaultLanguage;
										// 04/20/2018 Paul.  Alternate language mapping to convert en-CA to en_US. 
										sINVITEE_LANG = L10N.AlternateLanguage(Application, sINVITEE_LANG);
										
										L10N     L10n = new L10N(sINVITEE_LANG);
										TimeZone T10n = TimeZone.CreateTimeZone(gTIMEZONE_ID);
										row["DATE_START"] = T10n.FromServerTime(Sql.ToDateTime(row["DATE_START"]));
										row["DATE_END"  ] = T10n.FromServerTime(Sql.ToDateTime(row["DATE_END"  ]));
										
										// 12/25/2012 Paul.  The reminder mssages are pulled from the terminology table so that they can be localized. 
										string sSubjectMsg = "MSG_CONTACT_REMINDER_SUBJECT";
										string sBodyMsg    = "MSG_CONTACT_REMINDER_BODY"   ;
										string sSubject    = L10n.Term(sACTIVITY_TYPE + "." + sSubjectMsg);
										string sBodyHtml   = L10n.Term(sACTIVITY_TYPE + "." + sBodyMsg   );
										// 12/25/2012 Paul.  First fallback is English. 
										if ( Sql.IsEmptyString(sSubject) )
											sSubject    = L10nEN.Term(sACTIVITY_TYPE + "." + sSubjectMsg);
										if ( Sql.IsEmptyString(sBodyHtml) )
											sBodyHtml   = L10nEN.Term(sACTIVITY_TYPE + "." + sBodyMsg   );
										// 12/25/2012 Paul.  Second fallback is embedded string. 
										if ( Sql.IsEmptyString(sSubject) )
											sSubject = sACTIVITY_TYPE + " Reminder - $activity_name";
										if ( Sql.IsEmptyString(sBodyHtml) )
											sBodyHtml = "$activity_name\n$activity_date_start\n";
										
										// 12/26/2012 Paul.  Remove the URLs as the remaining page is for a non-user. 
										string sViewURL    = String.Empty;
										string sEditURL    = String.Empty;
										string sAcceptURL  = String.Empty;
										sBodyHtml = sBodyHtml.Replace("$view_url"  , sViewURL  );
										sBodyHtml = sBodyHtml.Replace("$edit_url"  , sEditURL  );
										sBodyHtml = sBodyHtml.Replace("$accept_url", sAcceptURL);
										sBodyHtml = sBodyHtml.Replace("href=\"~/", "\"" + sSiteURL);
										sBodyHtml = sBodyHtml.Replace("href=\'~/", "\'" + sSiteURL);  // 12/25/2012 Paul.  Also watch for single quote. 
										
										string sFillPrefix = sACTIVITY_TYPE;
										if ( sFillPrefix.EndsWith("s") )
											sFillPrefix = sFillPrefix.Substring(0, sFillPrefix.Length-1);
										sSubject  = EmailUtils.FillEmail(Application, sSubject , sFillPrefix, row, vwColumns, null, hashEnumsColumns);
										sBodyHtml = EmailUtils.FillEmail(Application, sBodyHtml, sFillPrefix, row, vwColumns, null, hashEnumsColumns);
										if ( sBodyHtml.Contains("$activity_") )
										{
											sFillPrefix = "activity";
											sSubject  = EmailUtils.FillEmail(Application, sSubject , sFillPrefix, row, vwColumns, null, hashEnumsColumns);
											sBodyHtml = EmailUtils.FillEmail(Application, sBodyHtml, sFillPrefix, row, vwColumns, null, hashEnumsColumns);
										}
										litReminder.Text = sBodyHtml.Replace("\n", "<br />\n");
									}
									else
									{
										lblError.Text = L10n.Term(".LBL_EMAIL_SEARCH_NO_RESULTS");
									}
								}
							}
						}
					}
				}
				else
				{
					lblError.Text = L10n.Term(".ERR_MISSING_REQUIRED_FIELDS");
				}
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

