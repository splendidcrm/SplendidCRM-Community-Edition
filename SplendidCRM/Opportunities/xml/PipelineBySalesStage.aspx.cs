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
using System.Xml;
using System.Data;
using System.Data.Common;
using System.Collections;
using System.Diagnostics;

namespace SplendidCRM.Opportunities.xml
{
	/// <summary>
	/// Summary description for PipelineBySalesStage.
	/// </summary>
	public class PipelineBySalesStage : SplendidPage
	{
		const string m_sMODULE = "Opportunities";

		private void Page_Load(object sender, System.EventArgs e)
		{
			XmlDocument xml = new XmlDocument();
			// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
			// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
			// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
			xml.XmlResolver = null;
			try
			{
				// 09/15/2005 Paul.  Values will always be in the query string. 
				int      nCHART_LENGTH = Sql.ToInteger (Request.QueryString["CHART_LENGTH"]);
				DateTime dtDATE_START  = T10n.ToServerTime(Sql.ToDateTime(Request.QueryString["DATE_START"  ]));
				DateTime dtDATE_END    = T10n.ToServerTime(Sql.ToDateTime(Request.QueryString["DATE_END"    ]));
				if ( dtDATE_START == DateTime.MinValue )
				{
					// 09/14/2005 Paul.  SugarCRM uses a max date of 01/01/2100. 
					dtDATE_START = DateTime.Today;
				}
				if ( dtDATE_END == DateTime.MinValue )
				{
					// 09/14/2005 Paul.  SugarCRM uses a max date of 01/01/2100. 
					// 07/06/2016 Paul.  Use +5 years instead of 2100 to reduce truncation when displaying year as yy. 
					dtDATE_END = new DateTime(DateTime.Today.Year + 5, 1, 1);
				}
				// 09/15/2005 Paul.  Values will always be in the query string. 
				string[] arrASSIGNED_USER_ID = Request.QueryString.GetValues("ASSIGNED_USER_ID");
				// 09/15/2005 Paul.  Values will always be in the query string. 
				string[] arrSALES_STAGE = Request.QueryString.GetValues("SALES_STAGE");

				xml.LoadXml(SplendidCache.XmlFile(Server.MapPath(Session["themeURL"] + "BarChart.xml")));
				XmlNode nodeRoot        = xml.SelectSingleNode("graphData");
				XmlNode nodeXData       = xml.CreateElement("xData"      );
				XmlNode nodeYData       = xml.CreateElement("yData"      );
				XmlNode nodeColorLegend = xml.CreateElement("colorLegend");
				XmlNode nodeGraphInfo   = xml.CreateElement("graphInfo"  );
				XmlNode nodeChartColors = nodeRoot.SelectSingleNode("chartColors");

				nodeRoot.InsertBefore(nodeGraphInfo  , nodeChartColors);
				nodeRoot.InsertBefore(nodeColorLegend, nodeGraphInfo  );
				nodeRoot.InsertBefore(nodeXData      , nodeColorLegend);
				nodeRoot.InsertBefore(nodeYData      , nodeXData      );
				
				XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "defaultAltText", L10n.Term("Dashboard.LBL_ROLLOVER_DETAILS"));
				XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "min", "0");
				XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "max", "0");
				if ( nCHART_LENGTH < 4 )
					nCHART_LENGTH = 4;
				else if ( nCHART_LENGTH > 10 )
					nCHART_LENGTH = 10;
				XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "length", nCHART_LENGTH.ToString());
				System.Globalization.CultureInfo culture = System.Threading.Thread.CurrentThread.CurrentCulture;
				// 03/07/2008 Paul.  Use CurrencyPositivePattern to determine location of the CurrencySymbol. 
				switch ( culture.NumberFormat.CurrencyPositivePattern )
				{
					case 0:  // $n
						XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "prefix", culture.NumberFormat.CurrencySymbol);
						XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "suffix", "");
						break;
					case 1:  // n$
						XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "prefix", "");
						XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "suffix", culture.NumberFormat.CurrencySymbol);
						break;
					case 2:  // $ n
						XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "prefix", culture.NumberFormat.CurrencySymbol + " ");
						XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "suffix", "");
						break;
					case 3:  // n $
						XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "prefix", "");
						XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "suffix", " " + culture.NumberFormat.CurrencySymbol);
						break;
				}
				
				// 01/31/2008 Paul.  Add space after TO. 
				nodeGraphInfo.InnerText = L10n.Term("Dashboard.LBL_DATE_RANGE") + " " + Sql.ToDateString(T10n.FromServerTime(dtDATE_START)) + " " + L10n.Term("Dashboard.LBL_DATE_RANGE_TO") + " " + Sql.ToDateString(T10n.FromServerTime(dtDATE_END)) + "<BR/>"
				                        + L10n.Term("Dashboard.LBL_OPP_SIZE"  ) + " " + 1.ToString("c0") + L10n.Term("Dashboard.LBL_OPP_THOUSANDS");
				
				Hashtable hashUSER = new Hashtable();
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					// 09/19/2005 Paul.  Prepopulate the stage rows so that empty rows will appear.  The SQL query will not return empty rows. 
					if ( arrSALES_STAGE != null )
					{
						foreach(string sSALES_STAGE in arrSALES_STAGE)
						{
							XmlNode nodeRow = xml.CreateElement("dataRow");
							nodeYData.AppendChild(nodeRow);
							XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "title"   , Sql.ToString(L10n.Term(".sales_stage_dom.", sSALES_STAGE)));
							XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "endLabel", "0");
						}
					}
					// 09/19/2005 Paul.  Prepopulate the user key with all the users specified. 
					if ( arrASSIGNED_USER_ID != null )
					{
						sSQL = "select ID          " + ControlChars.CrLf
						     + "     , USER_NAME   " + ControlChars.CrLf
						     + "  from vwUSERS_List" + ControlChars.CrLf
						     + " where 1 = 1       " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AppendGuids(cmd, arrASSIGNED_USER_ID, "ID");
							cmd.CommandText += " order by USER_NAME" + ControlChars.CrLf;
							using ( IDataReader rdr = cmd.ExecuteReader() )
							{
								while ( rdr.Read() )
								{
									Guid   gUSER_ID   = Sql.ToGuid   (rdr["ID"       ]);
									string sUSER_NAME = Sql.ToString (rdr["USER_NAME"]);
									if ( !hashUSER.ContainsKey(gUSER_ID.ToString()) )
									{
										XmlNode nodeMapping = xml.CreateElement("mapping");
										nodeColorLegend.AppendChild(nodeMapping);
										XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "id"   , gUSER_ID.ToString());
										XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "name" , sUSER_NAME);
										XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "color", SplendidDefaults.generate_graphcolor(gUSER_ID.ToString(), hashUSER.Count));
										hashUSER.Add(gUSER_ID.ToString(), sUSER_NAME);
									}
								}
							}
						}
					}
					// 08/07/2015 Paul.  Revenue Line Items. 
					sSQL = "select SALES_STAGE                                   " + ControlChars.CrLf
					     + "     , ASSIGNED_USER_ID                              " + ControlChars.CrLf
					     + "     , USER_NAME                                     " + ControlChars.CrLf
					     + "     , LIST_ORDER                                    " + ControlChars.CrLf
					     + "     , sum(AMOUNT_USDOLLAR/1000) as TOTAL            " + ControlChars.CrLf
					     + "     , count(*)                  as OPPORTUNITY_COUNT" + ControlChars.CrLf
					     + "  from vw" + Crm.Config.OpportunitiesMode().ToUpper() + "_Pipeline" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Opportunities", "list");
						cmd.CommandText += "   and DATE_CLOSED >= @DATE_START" + ControlChars.CrLf;
						cmd.CommandText += "   and DATE_CLOSED <= @DATE_END  " + ControlChars.CrLf;
						// 09/14/2005 Paul.  Use add because <= and >= are not supported. 
						Sql.AddParameter   (cmd, "@DATE_START"      , dtDATE_START      );
						Sql.AddParameter   (cmd, "@DATE_END"        , dtDATE_END        );
						// 09/14/2005 Paul.  Use append because it supports arrays using the IN clause. 
						// 06/23/2018 Paul.  Need to allow multiple users to see the data they are assigned to. 
						if ( Crm.Config.enable_dynamic_assignment() )
							Sql.AppendLikeParameters(cmd, arrASSIGNED_USER_ID, "ASSIGNED_SET_LIST");
						else
							Sql.AppendGuids    (cmd, arrASSIGNED_USER_ID, "ASSIGNED_USER_ID");
						Sql.AppendParameter(cmd, arrSALES_STAGE     , "SALES_STAGE"     );
#if false
						if ( arrSALES_STAGE != null )
							nodeGraphInfo.InnerText = "SALES_STAGE = " + String.Join(", ", arrSALES_STAGE);
#endif
						
						cmd.CommandText += ""
						     + " group by SALES_STAGE                                " + ControlChars.CrLf
						     + "        , LIST_ORDER                                 " + ControlChars.CrLf
						     + "        , ASSIGNED_USER_ID                           " + ControlChars.CrLf
						     + "        , USER_NAME                                  " + ControlChars.CrLf
						     + " order by LIST_ORDER                                 " + ControlChars.CrLf
						     + "        , USER_NAME                                  " + ControlChars.CrLf;
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							double dMAX_TOTAL      = 0;
							double dPIPELINE_TOTAL = 0;
							while ( rdr.Read() )
							{
								string  sSALES_STAGE       = Sql.ToString (rdr["SALES_STAGE"      ]);
								double  dTOTAL             = Sql.ToDouble (rdr["TOTAL"            ]);
								int     nOPPORTUNITY_COUNT = Sql.ToInteger(rdr["OPPORTUNITY_COUNT"]);
								Guid    gASSIGNED_USER_ID  = Sql.ToGuid   (rdr["ASSIGNED_USER_ID" ]);
								string  sUSER_NAME         = Sql.ToString (rdr["USER_NAME"        ]);
								
								dPIPELINE_TOTAL += dTOTAL;
								if ( dTOTAL > dMAX_TOTAL )
									dMAX_TOTAL = dTOTAL;
								XmlNode nodeRow = nodeYData.SelectSingleNode("dataRow[@title=\'" + Sql.ToString(L10n.Term(".sales_stage_dom.", sSALES_STAGE)).Replace("'", "\'") +"\']");
								if ( nodeRow == null )
								{
									nodeRow = xml.CreateElement("dataRow");
									nodeYData.AppendChild(nodeRow);
									XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "title"   , Sql.ToString(L10n.Term(".sales_stage_dom.", sSALES_STAGE)));
									XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "endLabel", dTOTAL.ToString("0")   );
								}
								else
								{
									if ( nodeRow.Attributes.GetNamedItem("endLabel") != null )
									{
										double dEND_LABEL = Sql.ToDouble(nodeRow.Attributes.GetNamedItem("endLabel").Value);
										dEND_LABEL += dTOTAL;
										if ( dEND_LABEL > dMAX_TOTAL )
											dMAX_TOTAL = dEND_LABEL;
										XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "endLabel", dEND_LABEL.ToString("0")   );
									}
								}
								
								if ( !hashUSER.ContainsKey(gASSIGNED_USER_ID.ToString()) )
								{
									XmlNode nodeMapping = xml.CreateElement("mapping");
									nodeColorLegend.AppendChild(nodeMapping);
									XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "id"   , gASSIGNED_USER_ID.ToString());
									XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "name" , sUSER_NAME);
									XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "color", SplendidDefaults.generate_graphcolor(gASSIGNED_USER_ID.ToString(), hashUSER.Count));
									hashUSER.Add(gASSIGNED_USER_ID.ToString(), sUSER_NAME);
								}
								
								XmlNode nodeBar = xml.CreateElement("bar");
								nodeRow.AppendChild(nodeBar);
								XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "id"       , gASSIGNED_USER_ID.ToString());
								XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "totalSize", dTOTAL.ToString("0"));
								XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "altText"  , sUSER_NAME + ": " + nOPPORTUNITY_COUNT.ToString() + " " + L10n.Term("Dashboard.LBL_OPPS_WORTH") + " " + dTOTAL.ToString("0") + L10n.Term("Dashboard.LBL_OPP_THOUSANDS") + " " + L10n.Term("Dashboard.LBL_OPPS_IN_STAGE") + " " + Sql.ToString(L10n.Term(".sales_stage_dom.", sSALES_STAGE)) );
								XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "url"      , Sql.ToString(Application["rootURL"]) + "Opportunities/default.aspx?SALES_STAGE=" + Server.UrlEncode(sSALES_STAGE) + "&ASSIGNED_USER_ID=" + gASSIGNED_USER_ID.ToString() );
							}
							int    nNumLength   = Math.Floor(dMAX_TOTAL).ToString("0").Length - 1;
							double dWhole       = Math.Pow(10, nNumLength);
							double dDecimal     = 1 / dWhole;
							double dMAX_ROUNDED = Math.Ceiling(dMAX_TOTAL * dDecimal) * dWhole;
							
							XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "max", dMAX_ROUNDED.ToString("0"));
							// 11/23/2012 Paul.  Add space before value. 
							XmlUtil.SetSingleNodeAttribute(xml, nodeRoot , "title", L10n.Term("Dashboard.LBL_TOTAL_PIPELINE") + " " + dPIPELINE_TOTAL.ToString("c0") + L10n.Term("Dashboard.LBL_OPP_THOUSANDS"));
						}
					}
				}
				Response.ContentType = "text/xml";
				Response.Write(xml.OuterXml);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				Response.Write(ex.Message);
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

