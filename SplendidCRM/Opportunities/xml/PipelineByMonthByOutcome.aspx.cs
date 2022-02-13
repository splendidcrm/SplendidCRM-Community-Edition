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
	/// Summary description for PipelineByMonthByOutcome.
	/// </summary>
	public class PipelineByMonthByOutcome : SplendidPage
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
				int      nYEAR         = Sql.ToInteger (Request.QueryString["YEAR"]);
				nYEAR = Math.Max(1900, nYEAR);
				nYEAR = Math.Min(2100, nYEAR);
				DateTime dtDATE_START  = new DateTime(nYEAR,  1,  1);
				// 05/29/2017 Paul.  We were exlcuding the last day of the year. 
				DateTime dtDATE_END    = new DateTime(nYEAR, 12, 31, 23, 59, 59);
				// 09/15/2005 Paul.  Values will always be in the query string. 
				string[] arrASSIGNED_USER_ID = Request.QueryString.GetValues("ASSIGNED_USER_ID");

				xml.LoadXml(SplendidCache.XmlFile(Server.MapPath(Session["themeURL"] + "BarChart.xml")));
				XmlNode nodeRoot        = xml.SelectSingleNode("graphData");
				XmlNode nodeXData       = xml.CreateElement("xData"      );
				XmlNode nodeYData       = xml.CreateElement("yData"      );
				XmlNode nodeColorLegend = xml.CreateElement("colorLegend");
				XmlNode nodeGraphInfo   = xml.CreateElement("graphInfo"  );
				XmlNode nodeChartColors = nodeRoot.SelectSingleNode("chartColors");

				nodeRoot.InsertBefore(nodeGraphInfo  , nodeChartColors);
				nodeRoot.InsertBefore(nodeColorLegend, nodeGraphInfo  );
				nodeRoot.InsertBefore(nodeYData      , nodeColorLegend);
				nodeRoot.InsertBefore(nodeXData      , nodeYData      );

				XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "length", "20");
				XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "min", "0");
				XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "max", "0");
				if ( nCHART_LENGTH < 4 )
					nCHART_LENGTH = 4;
				else if ( nCHART_LENGTH > 10 )
					nCHART_LENGTH = 10;
				XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "length", nCHART_LENGTH.ToString());
				System.Globalization.CultureInfo culture = System.Threading.Thread.CurrentThread.CurrentCulture;
				// 03/07/2008 Paul.  Use CurrencyPositivePattern to determine location of the CurrencySymbol. 
				switch ( culture.NumberFormat.CurrencyPositivePattern )
				{
					case 0:  // $n
						XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "prefix", culture.NumberFormat.CurrencySymbol);
						XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "suffix", "");
						break;
					case 1:  // n$
						XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "prefix", "");
						XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "suffix", culture.NumberFormat.CurrencySymbol);
						break;
					case 2:  // $ n
						XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "prefix", culture.NumberFormat.CurrencySymbol + " ");
						XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "suffix", "");
						break;
					case 3:  // n $
						XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "prefix", "");
						XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "suffix", " " + culture.NumberFormat.CurrencySymbol);
						break;
				}
				XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "defaultAltText", L10n.Term("Dashboard.LBL_ROLLOVER_DETAILS"));
				
				// 01/31/2008 Paul.  Add space after TO. 
				nodeGraphInfo.InnerText = L10n.Term("Dashboard.LBL_DATE_RANGE") + " " + Sql.ToDateString(T10n.FromServerTime(dtDATE_START)) + " " + L10n.Term("Dashboard.LBL_DATE_RANGE_TO") + " " + Sql.ToDateString(T10n.FromServerTime(dtDATE_END)) + "<BR/>"
				                        + L10n.Term("Dashboard.LBL_OPP_SIZE"  ) + " " + 1.ToString("c0") + L10n.Term("Dashboard.LBL_OPP_THOUSANDS");
				
				Hashtable hashOUTCOME = new Hashtable();
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					// 09/19/2005 Paul.  Prepopulate the outcome. 
					string[] arrOUTCOME = new string[] { "Closed Lost", "Closed Won", "Other" };
					foreach(string sOUTCOME in arrOUTCOME)
					{
						if ( !hashOUTCOME.ContainsKey(sOUTCOME) )
						{
							XmlNode nodeMapping = xml.CreateElement("mapping");
							nodeColorLegend.AppendChild(nodeMapping);
							XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "id"   , sOUTCOME);
							if ( sOUTCOME == "Other" )
								XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "name" , L10n.Term("Dashboard.LBL_LEAD_SOURCE_OTHER"));
							else
								XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "name" , Sql.ToString(L10n.Term(".sales_stage_dom.", sOUTCOME)));
							XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "color", SplendidDefaults.generate_graphcolor(sOUTCOME, hashOUTCOME.Count));
							hashOUTCOME.Add(sOUTCOME, sOUTCOME);
						}
					}
					// 08/07/2015 Paul.  Revenue Line Items. 
					sSQL = "select SALES_STAGE                                   " + ControlChars.CrLf
					     + "     , MONTH_CLOSED                                  " + ControlChars.CrLf
					     + "     , sum(AMOUNT_USDOLLAR/1000) as TOTAL            " + ControlChars.CrLf
					     + "     , count(*)                  as OPPORTUNITY_COUNT" + ControlChars.CrLf
					     + "  from vw" + Crm.Config.OpportunitiesMode().ToUpper() + "_PipelineMonth" + ControlChars.CrLf;
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
						
						cmd.CommandText += ""
						     + " group by SALES_STAGE                                " + ControlChars.CrLf
						     + "        , MONTH_CLOSED                               " + ControlChars.CrLf
						     + " order by MONTH_CLOSED, SALES_STAGE desc             " + ControlChars.CrLf;
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							double dMAX_TOTAL      = 0;
							double dPIPELINE_TOTAL = 0;
							string sMONTHYEAR_FORMAT = m_sDATEFORMAT;
							// 09/21/2005 Paul.  Remove day from format. 
							sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.Replace("dd", "");
							sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.Replace("--", "-");
							sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.Replace("//", "/");
							sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.Replace("  ", " ");
							while ( rdr.Read() )
							{
								int      nMONTH_CLOSED      = Sql.ToInteger(rdr["MONTH_CLOSED"     ]);
								string   sSALES_STAGE       = Sql.ToString (rdr["SALES_STAGE"      ]);
								double   dTOTAL             = Sql.ToDouble (rdr["TOTAL"            ]);
								int      nOPPORTUNITY_COUNT = Sql.ToInteger(rdr["OPPORTUNITY_COUNT"]);
								DateTime dtMONTH_CLOSED     = new DateTime(nYEAR, nMONTH_CLOSED, 1);
								string   sMONTH_CLOSED      = dtMONTH_CLOSED.ToString(sMONTHYEAR_FORMAT);
								
								dPIPELINE_TOTAL += dTOTAL;
								if ( dTOTAL > dMAX_TOTAL )
									dMAX_TOTAL = dTOTAL;
								XmlNode nodeRow = nodeXData.SelectSingleNode("dataRow[@title=\'" + L10n.Term(sMONTH_CLOSED).Replace("'", "\'") +"\']");
								if ( nodeRow == null )
								{
									nodeRow = xml.CreateElement("dataRow");
									nodeXData.AppendChild(nodeRow);
									XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "title"   , sMONTH_CLOSED);
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
								
								XmlNode nodeBar = xml.CreateElement("bar");
								nodeRow.AppendChild(nodeBar);
								XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "id"       , sSALES_STAGE);
								XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "totalSize", dTOTAL.ToString("0"));
								XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "altText"  , sMONTH_CLOSED + ": " + nOPPORTUNITY_COUNT.ToString() + " " + L10n.Term("Dashboard.LBL_OPPS_WORTH") + " " + dTOTAL.ToString("0") + L10n.Term("Dashboard.LBL_OPP_THOUSANDS") + " " + L10n.Term("Dashboard.LBL_OPPS_OUTCOME") + " " + Sql.ToString(L10n.Term(".sales_stage_dom.", sSALES_STAGE)) );
								XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "url"      , Sql.ToString(Application["rootURL"]) + "Opportunities/default.aspx?DATE_CLOSED=" + Server.UrlEncode(Sql.ToDateString(T10n.FromServerTime(dtMONTH_CLOSED))) + "&SALES_STAGE=" + Server.UrlEncode(sSALES_STAGE) );
							}
							int    nNumLength   = Math.Floor(dMAX_TOTAL).ToString("0").Length - 1;
							double dWhole       = Math.Pow(10, nNumLength);
							double dDecimal     = 1 / dWhole;
							double dMAX_ROUNDED = Math.Ceiling(dMAX_TOTAL * dDecimal) * dWhole;
							
							XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "max", dMAX_ROUNDED.ToString("0"));
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

