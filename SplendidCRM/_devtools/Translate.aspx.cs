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
using System.Net.Http;
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
using System.Threading.Tasks;
using System.Xml;
using System.Diagnostics;

namespace SplendidCRM._devtools
{
	/// <summary>
	/// Summary description for Translate.
	/// </summary>
	public class Translate : System.Web.UI.Page
	{
		protected DataTable dtMain;
		protected string    sLang ;

		void Page_Load(object sender, System.EventArgs e)
		{
			// 05/18/2008 Paul.  Increase timeout to support slower machines. 
			Server.ScriptTimeout = 600;
			Response.Buffer = false;
			dtMain = new DataTable();
			// 01/11/2006 Paul.  Only a developer/administrator should see this. 
			if ( !SplendidCRM.Security.IS_ADMIN )
				return;

			sLang = Sql.ToString(Request["Lang"]);
			if ( sLang == "en-US" )
				return;
#if DEBUG
			if ( Sql.IsEmptyString(sLang) )
				sLang = "all";
#endif
			if ( !Sql.IsEmptyString(sLang) )
			{
				// 07/22/2017 Paul.  Provide a way to perform all translations. 
				List<string> arrLang = new List<string>();
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				if ( sLang == "all" )
				{
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						string sSQL;
						sSQL = "select NAME       " + ControlChars.CrLf
						     + "  from vwLANGUAGES" + ControlChars.CrLf
						     + " order by NAME    " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									foreach ( DataRow row in dt.Rows )
									{
										sLang = Sql.ToString(row["NAME"]);
										arrLang.Add(sLang);
									}
								}
							}
						}
					}
				}
				else
				{
					arrLang.Add(sLang);
				}
				int nErrors = 0;
				JavaScriptSerializer json = new JavaScriptSerializer();
				json.MaxJsonLength = int.MaxValue;
				for ( int j = 0; j < arrLang.Count && Response.IsClientConnected && nErrors < 20; j++ )
				{
					sLang = arrLang[j];
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						string sSQL;
						// 05/24/2008 Paul.  Use an outer join so that we only translate missing terms. 
						// 07/20/2017 Paul.  Match NAME and NAME null. 
						sSQL = "select ENGLISH.NAME                                     " + ControlChars.CrLf
						     + "     , ENGLISH.MODULE_NAME                              " + ControlChars.CrLf
						     + "     , ENGLISH.LIST_NAME                                " + ControlChars.CrLf
						     + "     , ENGLISH.LIST_ORDER                               " + ControlChars.CrLf
						     + "     , ENGLISH.DISPLAY_NAME                             " + ControlChars.CrLf
						     + "  from            vwTERMINOLOGY             ENGLISH     " + ControlChars.CrLf
						     + "  left outer join vwTERMINOLOGY             TRANSLATED  " + ControlChars.CrLf
						     + "               on lower(TRANSLATED.LANG) = lower(@LANG) " + ControlChars.CrLf
						     + "              and (TRANSLATED.NAME        = ENGLISH.NAME        or TRANSLATED.NAME        is null and ENGLISH.NAME        is null)" + ControlChars.CrLf
						     + "              and (TRANSLATED.MODULE_NAME = ENGLISH.MODULE_NAME or TRANSLATED.MODULE_NAME is null and ENGLISH.MODULE_NAME is null)" + ControlChars.CrLf
						     + "              and (TRANSLATED.LIST_NAME   = ENGLISH.LIST_NAME   or TRANSLATED.LIST_NAME   is null and ENGLISH.LIST_NAME   is null)" + ControlChars.CrLf
						     + " where lower(ENGLISH.LANG) = lower('en-US')             " + ControlChars.CrLf
						     + "   and TRANSLATED.ID is null                            " + ControlChars.CrLf
						     + " order by ENGLISH.MODULE_NAME, ENGLISH.LIST_NAME, ENGLISH.LIST_ORDER, ENGLISH.NAME" + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							// 03/06/2006 Paul.  Oracle is case sensitive, and we modify the case of L10n.NAME to be lower. 
							Sql.AddParameter(cmd, "@LANG", sLang);
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dt = new DataTable() )
								{
									dtMain = new DataTable();
									da.Fill(dtMain);
								}
							}
						}
					}
					CultureInfo culture = null;
					try
					{
						// 07/21/2017 Paul.  sr-SP-Latn is an invalid culture identifier
						culture = new CultureInfo(sLang);
					}
					catch
					{
					}
					if ( culture == null )
					{
						Response.Write("Unknown language: " + sLang + "<br />"+ ControlChars.CrLf);
						continue;  // throw(new Exception("Unknown language: " + sLang));
					}
					SqlProcs.spLANGUAGES_InsertOnly(sLang, culture.LCID, true, culture.NativeName, culture.DisplayName);

					string sTranslatorKey    = Sql.ToString(Application["CONFIG.MicrosoftTranslator.Key"   ]);
					string sTranslatorRegion = Sql.ToString(Application["CONFIG.MicrosoftTranslator.Region"]);
					for ( int i = 0 ; i < dtMain.Rows.Count && Response.IsClientConnected && nErrors < 20; i++ )
					{
#if DEBUG
//						if ( i >= 10 )
//							break;
#endif
						DataRow row = dtMain.Rows[i];
						string sNAME         = Sql.ToString (row["NAME"        ]);
						string sMODULE_NAME  = Sql.ToString (row["MODULE_NAME" ]);
						string sLIST_NAME    = Sql.ToString (row["LIST_NAME"   ]);
						Int32  nLIST_ORDER   = Sql.ToInteger(row["LIST_ORDER"  ]);
						string sDISPLAY_NAME = Sql.ToString (row["DISPLAY_NAME"]);
						string sLANG         = sLang;
						// 02/02/2009 Paul.  Some languages use 10 characters. 
						if ( sLANG.Length == 5 )
							sLANG = sLang.Substring(0, 2).ToLower() + "-" + sLang.Substring(3, 2).ToUpper();

						try
						{
							// 05/18/2008 Paul.  No need to translate empty strings or single characters. 
							if ( sDISPLAY_NAME.Length > 1 )
							{
								string sToLang = sLang.Split('-')[0];
								// 05/18/2008 Paul.  The only time we use the 5-character code is when requesting Chinese. 
								// 08/01/2013 Paul.  Microsoft Translator uses zh-CHS for Chinese (Simplified) and zh-CHT for Chinese (Traditional). 
								if ( sLANG == "zh-CN" )
									sToLang = "zh-CHS";
								else if ( sLANG == "zh-TW" )
									sToLang = "zh-CHT";
								// 05/18/2008 Paul.  Not sure why Google uses NO. 
								// 08/01/2013 Paul.  Microsoft Translator also uses NO. 
								if ( sLANG == "nb-NO" || sLANG == "nn-NO" )
									sToLang = "no";
								// 07/21/2017 paul.  Exceptions to the 2-leter. 
								if ( sLANG == "bs-Latn" )
									sToLang = sLANG;
								if ( sLANG == "sr-Cyrl" )
									sToLang = sLANG;
								if ( sLANG == "sr-Latn" )
									sToLang = sLANG;
								
								// 08/02/2017 Paul.  Some terms are not translated.  These stream labels are used to allow customization but they should not be translated. 
								if ( sNAME == "LBL_STREAM_FIELDS_CREATED" || sNAME == "LBL_STREAM_FIELDS_UPDATED" )
								{
									SqlProcs.spTERMINOLOGY_InsertOnly(sNAME, sLANG, sMODULE_NAME, sLIST_NAME, nLIST_ORDER, sDISPLAY_NAME);
									continue;
								}
								
								// 11/29/2021 Paul.  Update to Microsoft Translator 3.0
								object[] body = new object[] { new { Text = sDISPLAY_NAME } };
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
																		Response.Write(sToLang + ": " + sTranslation + "<br />"+ ControlChars.CrLf);
																		sDISPLAY_NAME = sTranslation;
																		SqlProcs.spTERMINOLOGY_InsertOnly(sNAME, sLANG, sMODULE_NAME, sLIST_NAME, nLIST_ORDER, sDISPLAY_NAME);
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
											nErrors++;
											Response.Write("<font color=red>" + objResponse.StatusCode + " " + objResponse.StatusDescription + " (" + sMODULE_NAME + "." + sNAME + ")" + "</font><br />"+ ControlChars.CrLf);
										}
									}
								}
							}
							else
							{
								SqlProcs.spTERMINOLOGY_InsertOnly(sNAME, sLANG, sMODULE_NAME, sLIST_NAME, nLIST_ORDER, sDISPLAY_NAME);
							}
						}
						catch(Exception ex)
						{
							nErrors++;
							Response.Write("<font color=red>" + ex.Message + "</font><br />"+ ControlChars.CrLf);
						}
					}
				}
				dtMain = new DataTable();
				// 05/18/2008 Paul.  Cannot redirect when response buffering is off. 
				//Response.Redirect("Terminology.aspx");
#if !DEBUG
				if ( nErrors == 0 )
					Response.Write("<script type=\"text/javascript\">window.location.href='Terminology.aspx';</script>");
#endif
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
