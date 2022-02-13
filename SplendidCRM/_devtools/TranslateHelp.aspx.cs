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
using System.Collections.Generic;
using System.Web;
using System.Web.Script.Serialization;
using System.Runtime.Serialization.Json;
using System.Runtime.Serialization;
using System.Globalization;
using System.Threading;

namespace SplendidCRM._devtools
{
	/// <summary>
	/// Summary description for TranslateHelp.
	/// </summary>
	public class TranslateHelp : System.Web.UI.Page
	{
		protected DataTable dtMain;
		protected string    sLang ;

		void Page_Load(object sender, System.EventArgs e)
		{
			dtMain = new DataTable();
			// 01/11/2006 Paul.  Only a developer/administrator should see this. 
			if ( !SplendidCRM.Security.IS_ADMIN )
				return;

			sLang = Sql.ToString(Request["Lang"]);
			if ( sLang == "en-US" )
				return;
			if ( !Sql.IsEmptyString(sLang) )
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					// 05/24/2008 Paul.  Use an outer join so that we only translate missing terms. 
					sSQL = "select ENGLISH.NAME                                     " + ControlChars.CrLf
					     + "     , ENGLISH.MODULE_NAME                              " + ControlChars.CrLf
					     + "     , ENGLISH.DISPLAY_TEXT                             " + ControlChars.CrLf
					     + "  from            vwTERMINOLOGY_HELP        ENGLISH     " + ControlChars.CrLf
					     + "  left outer join vwTERMINOLOGY_HELP        TRANSLATED  " + ControlChars.CrLf
					     + "               on TRANSLATED.NAME         = ENGLISH.NAME" + ControlChars.CrLf
					     + "              and lower(TRANSLATED.LANG) = lower(@LANG) " + ControlChars.CrLf
					     + "              and (TRANSLATED.MODULE_NAME = ENGLISH.MODULE_NAME or TRANSLATED.MODULE_NAME is null and ENGLISH.MODULE_NAME is null)" + ControlChars.CrLf
					     + " where lower(ENGLISH.LANG) = lower('en-US')             " + ControlChars.CrLf
					     + "   and TRANSLATED.ID is null                            " + ControlChars.CrLf
					     + " order by ENGLISH.MODULE_NAME, ENGLISH.NAME             " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@LANG", sLang);
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dtMain);
							}
						}
					}
				}
				CultureInfo culture = new CultureInfo(sLang);
				if ( culture == null )
					throw(new Exception("Unknown language: " + sLang));
				SqlProcs.spLANGUAGES_InsertOnly(sLang, culture.LCID, true, culture.NativeName, culture.DisplayName);

				int nErrors = 0;
				JavaScriptSerializer json = new JavaScriptSerializer();
				json.MaxJsonLength = int.MaxValue;
				// 05/18/2008 Paul.  Increase timeout to support slower machines. 
				Server.ScriptTimeout = 600;
				Response.Buffer = false;
				bool bInvalidTranslation = false;
				string sTranslatorKey    = Sql.ToString(Application["CONFIG.MicrosoftTranslator.Key"   ]);
				string sTranslatorRegion = Sql.ToString(Application["CONFIG.MicrosoftTranslator.Region"]);
				for ( int i = 0 ; i < dtMain.Rows.Count && Response.IsClientConnected && !bInvalidTranslation && nErrors < 20; i++ )
				{
					DataRow row = dtMain.Rows[i];
					string sNAME         = Sql.ToString (row["NAME"        ]);
					string sMODULE_NAME  = Sql.ToString (row["MODULE_NAME" ]);
					string sDISPLAY_TEXT = Sql.ToString (row["DISPLAY_TEXT"]);
					string sLANG         = sLang;
					// 02/02/2009 Paul.  Some languages use 10 characters. 
					if ( sLANG.Length == 5 )
						sLANG = sLang.Substring(0, 2).ToLower() + "-" + sLang.Substring(3, 2).ToUpper();

					try
					{
						// 05/18/2008 Paul.  No need to translate empty strings or single characters. 
						if ( sDISPLAY_TEXT.Length > 1 )
						{
							string sToLang = sLang.Substring(0, 2);
							// 05/18/2008 Paul.  The only time we use the 5-character code is when requesting Chinese. 
							if ( sLANG == "zh-CN" || sLANG == "zh-TW" )
								sToLang = sLANG;
							// 05/18/2008 Paul.  Not sure why Google uses NO. 
							//if ( sLANG == "nb-NO" || sLANG == "nn-NO" )
							//	sToLang = "no";
							//if ( sLANG == "fil-PH" )
							//	sToLang = "tl";

							bool bPartialFailure = false;
							StringBuilder sb = new StringBuilder();
							using ( StringWriter wtr = new StringWriter(sb) )
							{
								using ( StringReader rdr = new StringReader(sDISPLAY_TEXT) )
								{
									string sDISPLAY_TEXT_LINE = null;
									while ( (sDISPLAY_TEXT_LINE = rdr.ReadLine()) != null && !bInvalidTranslation )
									{
										sDISPLAY_TEXT_LINE = sDISPLAY_TEXT_LINE.Trim();
										if ( sDISPLAY_TEXT_LINE.Length == 0 )
										{
											wtr.WriteLine(sDISPLAY_TEXT_LINE);
											continue;
										}
										else if ( sDISPLAY_TEXT_LINE.StartsWith("<") && sDISPLAY_TEXT_LINE.EndsWith(">") && !sDISPLAY_TEXT_LINE.Contains(" ") )
										{
											// 05/24/2008 Paul.  HTML tags should pass through. 
											wtr.WriteLine(sDISPLAY_TEXT_LINE);
											continue;
										}
										else
										{
											// 11/29/2021 Paul.  Update to Microsoft Translator 3.0
											object[] body = new object[] { new { Text = sDISPLAY_TEXT_LINE } };
											string requestBody = Newtonsoft.Json.JsonConvert.SerializeObject(body);
											string sURL = "https://api.cognitive.microsofttranslator.com/translate?api-version=3.0&from=en" + "&to=" + sToLang;
											HttpWebRequest objRequest = (HttpWebRequest) WebRequest.Create(sURL);
											objRequest.KeepAlive         = false;
											objRequest.AllowAutoRedirect = false;
											objRequest.Timeout           = 15000;  //15 seconds
											objRequest.Method            = "POST";
											objRequest.ContentType       = "application/json";
											objRequest.Headers.Add("Ocp-Apim-Subscription-Key"   , sTranslatorKey   );
											objRequest.Headers.Add("Ocp-Apim-Subscription-Region", sTranslatorRegion);
											objRequest.ContentLength = requestBody.Length;
											using ( Stream outputStream = objRequest.GetRequestStream() )
											{
												byte[] bytes = System.Text.Encoding.UTF8.GetBytes(requestBody);
												outputStream.Write(bytes, 0, bytes.Length);
											}

											// 01/11/2011 Paul.  Make sure to dispose of the response object as soon as possible. 
											using ( HttpWebResponse objResponse = (HttpWebResponse) objRequest.GetResponse() )
											{
												if ( objResponse != null )
												{
													if ( objResponse.StatusCode == HttpStatusCode.OK || objResponse.StatusCode == HttpStatusCode.Found )
													{
														using ( StreamReader readStream = new StreamReader(objResponse.GetResponseStream(), System.Text.Encoding.UTF8) )
														{
															string sJsonResponse = readStream.ReadToEnd();
															System.Collections.ArrayList lst = json.Deserialize<System.Collections.ArrayList>(sJsonResponse);
															foreach ( Dictionary<string, object> dict in lst )
															{
																foreach ( string name in dict.Keys )
																{
																	if ( name == "translations" )
																	{
																		System.Collections.ArrayList translations = dict[name] as System.Collections.ArrayList;
																		if ( translations != null )
																		{
																			foreach ( Dictionary<string, object> trans in translations )
																			{
																				if ( trans.ContainsKey("text") )
																				{
																					string sTranslation = Sql.ToString(trans["text"]);
																					Response.Write(sTranslation + "<br />"+ ControlChars.CrLf);
																					wtr.WriteLine(sTranslation);
																				}
																			}
																		}
																	}
																}
															}
														}
													}
													else
													{
														bPartialFailure = true;
														nErrors++;
														Response.Write("<font color=red>" + objResponse.StatusCode + " " + objResponse.StatusDescription + " (" + sMODULE_NAME + "." + sNAME + ")" + "</font><br />"+ ControlChars.CrLf);
														break;
													}
												}
											}
										}
									}
								}
							}
							if ( !bInvalidTranslation && !bPartialFailure )
							{
								sDISPLAY_TEXT = sb.ToString();
								SqlProcs.spTERMINOLOGY_HELP_InsertOnly(sNAME, sLANG, sMODULE_NAME, sDISPLAY_TEXT);
							}
						}
						else
						{
							SqlProcs.spTERMINOLOGY_HELP_InsertOnly(sNAME, sLANG, sMODULE_NAME, sDISPLAY_TEXT);
						}
					}
					catch(Exception ex)
					{
						nErrors++;
						Response.Write("<font color=red>" + ex.Message + "</font><br />"+ ControlChars.CrLf);
					}
				}
				dtMain = new DataTable();
				// 05/18/2008 Paul.  Cannot redirect when response buffering is off. 
				//Response.Redirect("TerminologyHelp.aspx");
				if ( nErrors == 0 )
					Response.Write("<script type=\"text/javascript\">window.location.href='TerminologyHelp.aspx';</script>");
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
