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
using System.Web;
using System.Data;
using System.Text;
using System.Drawing;
using System.Drawing.Imaging;
using System.Collections.Generic;
using System.Web.Script.Serialization;
using System.Diagnostics;
using Spring.Json;

namespace SplendidCRM
{
	public class OrderUtils
	{
		public static void DiscountPrice(string sPRICING_FORMULA, float fPRICING_FACTOR, Decimal dCOST_PRICE, Decimal dLIST_PRICE, ref Decimal dDISCOUNT_PRICE)
		{
			if ( fPRICING_FACTOR > 0 )
			{
				switch ( sPRICING_FORMULA )
				{
					case "Fixed"             :
						break;
					case "ProfitMargin"      :
						dDISCOUNT_PRICE = dCOST_PRICE * 100 / (100 - (Decimal) fPRICING_FACTOR);
						break;
					case "PercentageMarkup"  :
						dDISCOUNT_PRICE = dCOST_PRICE * (1 + (Decimal) (fPRICING_FACTOR /100));
						break;
					case "PercentageDiscount":
						dDISCOUNT_PRICE = (dLIST_PRICE * (Decimal) (1 - (fPRICING_FACTOR /100))*100)/100;
						break;
					case "FixedDiscount":
						dDISCOUNT_PRICE = dLIST_PRICE - (Decimal) fPRICING_FACTOR;
						break;
					case "IsList"            :
						dDISCOUNT_PRICE = dLIST_PRICE;
						break;
				}
			}
		}
		
		public static void DiscountValue(string sPRICING_FORMULA, float fPRICING_FACTOR, Decimal dCOST_PRICE, Decimal dLIST_PRICE, ref Decimal dDISCOUNT_VALUE)
		{
			if ( fPRICING_FACTOR > 0 )
			{
				switch ( sPRICING_FORMULA )
				{
					case "PercentageDiscount":
						dDISCOUNT_VALUE = (dLIST_PRICE * (Decimal) (fPRICING_FACTOR /100)*100)/100;
						break;
					case "FixedDiscount"     :
						dDISCOUNT_VALUE = (Decimal) fPRICING_FACTOR;
						break;
				}
			}
		}
		
		public static void DiscountPrice(Guid gDISCOUNT_ID, Decimal dCOST_PRICE, Decimal dLIST_PRICE, ref Decimal dDISCOUNT_PRICE, ref string sPRICING_FORMULA, ref float fPRICING_FACTOR)
		{
			DataTable dtDISCOUNTS = SplendidCache.Discounts();
			if ( dtDISCOUNTS != null )
			{
				DataRow[] row = dtDISCOUNTS.Select("ID = '" + gDISCOUNT_ID.ToString() + "'");
				if ( row.Length == 1 )
				{
					sPRICING_FORMULA = Sql.ToString(row[0]["PRICING_FORMULA"]);
					fPRICING_FACTOR  = Sql.ToFloat (row[0]["PRICING_FACTOR" ]);
					DiscountPrice(sPRICING_FORMULA, fPRICING_FACTOR, dCOST_PRICE, dLIST_PRICE, ref dDISCOUNT_PRICE);
				}
			}
		}
		
		public static void DiscountValue(Guid gDISCOUNT_ID, Decimal dCOST_PRICE, Decimal dLIST_PRICE, ref Decimal dDISCOUNT_VALUE, ref string sDISCOUNT_NAME, ref string sPRICING_FORMULA, ref float fPRICING_FACTOR)
		{
			DataTable dtDISCOUNTS = SplendidCache.Discounts();
			if ( dtDISCOUNTS != null )
			{
				DataRow[] row = dtDISCOUNTS.Select("ID = '" + gDISCOUNT_ID.ToString() + "'");
				if ( row.Length == 1 )
				{
					sPRICING_FORMULA = Sql.ToString(row[0]["PRICING_FORMULA"]);
					fPRICING_FACTOR  = Sql.ToFloat (row[0]["PRICING_FACTOR" ]);
					sDISCOUNT_NAME   = Sql.ToString(row[0]["NAME"           ]);
					DiscountValue(sPRICING_FORMULA, fPRICING_FACTOR, dCOST_PRICE, dLIST_PRICE, ref dDISCOUNT_VALUE);
				}
			}
		}

		public class CurrencyLayerETag
		{
			public string   ETag;
			public DateTime Date;
			public float    Rate;
		}

		// 04/30/2016 Paul.  The primary function uses the default currency of the user as the source. 
		public static float GetCurrencyConversionRate(HttpApplicationState Application, string sDestinationCurrency, StringBuilder sbErrors)
		{
			// 04/30/2016 Paul.  Require the Application so that we can get the base currency. 
			string sSourceCurrency = SplendidDefaults.BaseCurrencyISO(Application);
			object oRate = HttpRuntime.Cache.Get("CurrencyLayer." + sSourceCurrency + sDestinationCurrency);
			float dRate = 1.0F;
			if ( oRate == null )
			{
				string sAccessKey      = Sql.ToString (Application["CONFIG.CurrencyLayer.AccessKey"     ]);
				bool   bLogConversions = Sql.ToBoolean(Application["CONFIG.CurrencyLayer.LogConversions"]);
				if ( String.Compare(sSourceCurrency, sDestinationCurrency, true) != 0 )
					dRate = GetCurrencyConversionRate(Application, sAccessKey, bLogConversions, sSourceCurrency, sDestinationCurrency, sbErrors);
			}
			else
			{
				dRate = Sql.ToFloat(oRate);
			}
			return dRate;
		}

		public static float GetCurrencyConversionRate(HttpApplicationState Application, string sAccessKey, bool bLogConversions, string sSourceCurrency, string sDestinationCurrency, StringBuilder sbErrors)
		{
			float dRate = 1.0F;
			try
			{
				if ( String.Compare(sSourceCurrency, sDestinationCurrency, true) == 0 )
				{
					dRate = 1.0F;
				}
				else if ( !Sql.IsEmptyString(sAccessKey) )
				{
					bool bUseEncryptedUrl = Sql.ToBoolean(Application["CONFIG.CurrencyLayer.UseEncryptedUrl"]);
					string sBaseURL = (bUseEncryptedUrl ? "https" : "http") + "://apilayer.net/api/live?access_key=";
					HttpWebRequest objRequest = (HttpWebRequest) WebRequest.Create(sBaseURL + sAccessKey + "&source=" + sSourceCurrency.ToUpper() + "&currencies=" + sDestinationCurrency.ToUpper());
					objRequest.KeepAlive         = false;
					objRequest.AllowAutoRedirect = false;
					objRequest.Timeout           = 15000;  //15 seconds
					objRequest.Method            = "GET";
					// 04/30/2016 Paul.  Support ETags for efficient lookups. 
					CurrencyLayerETag oETag = Application["CurrencyLayer." + sSourceCurrency + sDestinationCurrency] as CurrencyLayerETag;
					if ( oETag != null )
					{
						objRequest.Headers.Add("If-None-Match", oETag.ETag);
						objRequest.IfModifiedSince = oETag.Date;
					}
					using ( HttpWebResponse objResponse = (HttpWebResponse) objRequest.GetResponse() )
					{
						if ( objResponse != null )
						{
							if ( objResponse.StatusCode == HttpStatusCode.OK || objResponse.StatusCode == HttpStatusCode.Found )
							{
								using ( StreamReader readStream = new StreamReader(objResponse.GetResponseStream(), System.Text.Encoding.UTF8) )
								{
									string sJsonResponse = readStream.ReadToEnd();
									JsonValue json = JsonValue.Parse(sJsonResponse);
									bool   bSuccess   = json.GetValueOrDefault<bool  >("success"  );
									string sTimestamp = json.GetValueOrDefault<string>("timestamp");
									string sSource    = json.GetValueOrDefault<string>("source"   );
									// {"success":false,"error":{"code":105,"info":"Access Restricted - Your current Subscription Plan does not support HTTPS Encryption."}}
									if ( bSuccess && json.ContainsName("quotes") )
									{
										JsonValue jsonQuotes = json.GetValue("quotes");
										dRate = jsonQuotes.GetValueOrDefault<float>(sSourceCurrency.ToUpper() + sDestinationCurrency.ToUpper());
										int nRateLifetime = Sql.ToInteger(Application["CONFIG.CurrencyLayer.RateLifetime"]);
										if ( nRateLifetime <= 0 )
											nRateLifetime = 90;
										HttpRuntime.Cache.Insert("CurrencyLayer." + sSourceCurrency + sDestinationCurrency, dRate, null, DateTime.Now.AddMinutes(nRateLifetime), System.Web.Caching.Cache.NoSlidingExpiration);
										oETag = new CurrencyLayerETag();
										oETag.ETag = objResponse.Headers.Get("ETag");
										oETag.Rate = dRate;
										DateTime.TryParse(objResponse.Headers.Get("Date"), out oETag.Date);
										Application["CurrencyLayer." + sSourceCurrency + sDestinationCurrency] = oETag;
										
										DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
										using ( IDbConnection con = dbf.CreateConnection() )
										{
											con.Open();
											using ( IDbTransaction trn = Sql.BeginTransaction(con) )
											{
												try
												{
													Guid gSYSTEM_CURRENCY_LOG = Guid.Empty;
													if ( bLogConversions )
													{
														SqlProcs.spSYSTEM_CURRENCY_LOG_InsertOnly
															( ref gSYSTEM_CURRENCY_LOG
															, "CurrencyLayer"       // SERVICE_NAME
															, sSourceCurrency       // SOURCE_ISO4217
															, sDestinationCurrency  // DESTINATION_ISO4217
															, dRate                 // CONVERSION_RATE
															, sJsonResponse         // RAW_CONTENT
															, trn
															);
													}
													// 04/30/2016 Paul.  We have to update the currency record as it is used inside stored procedures. 
													if ( sSourceCurrency == SplendidDefaults.BaseCurrencyISO(Application) )
													{
														SqlProcs.spCURRENCIES_UpdateRateByISO
															( sDestinationCurrency
															, dRate
															, gSYSTEM_CURRENCY_LOG
															, trn
															);
													}
													trn.Commit();
												}
												catch
												{
													trn.Rollback();
													throw;
												}
											}
										}
									}
									else if ( json.ContainsName("error") )
									{
										JsonValue jsonError = json.GetValue("error");
										string sInfo = jsonError.GetValue<string>("info");
										sbErrors.Append(sInfo);
									}
									else
									{
										sbErrors.Append("Conversion not found for " + sSourceCurrency + " to " + sDestinationCurrency + ".");
									}
								}
							}
							else if ( objResponse.StatusCode == HttpStatusCode.NotModified )
							{
								dRate = oETag.Rate;
							}
							else
							{
								sbErrors.Append(objResponse.StatusDescription);
							}
						}
					}
				}
				else
				{
					sbErrors.Append("CurrencyLayer access key is empty.");
				}
				if ( sbErrors.Length > 0 )
				{
					SplendidError.SystemMessage(Application, "Error", new StackTrace(true).GetFrame(0), "CurrencyLayer " + sSourceCurrency + sDestinationCurrency + ": " + sbErrors.ToString());
				}
			}
			catch(Exception ex)
			{
				sbErrors.AppendLine(ex.Message);
				SplendidError.SystemMessage(Application, "Error", new StackTrace(true).GetFrame(0), "CurrencyLayer " + sSourceCurrency + sDestinationCurrency + ": " + Utils.ExpandException(ex));
			}
			return dRate;
		}
	}
}
