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

namespace SplendidCRM.Campaigns.xml
{
	/// <summary>
	/// Summary description for ReturnOnInvestment.
	/// </summary>
	public class ReturnOnInvestment : SplendidPage
	{
		private void Page_Load(object sender, System.EventArgs e)
		{
			XmlDocument xml = new XmlDocument();
			// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
			// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
			// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
			xml.XmlResolver = null;
			try
			{
				Guid gID = Sql.ToGuid(Request["ID"]);
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

				XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "min"   , "0" );
				XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "max"   , "80");
				XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "length", "10");
				XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "prefix", ""  );
				XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "suffix", ""  );

				XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "min"   , "0" );
				XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "max"   , "10");
				XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "length", "10");
				XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "defaultAltText", L10n.Term("Campaigns.LBL_ROLLOVER_VIEW"));
				
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					DataTable dtLegend = SplendidCache.List("roi_type_dom");
					XmlUtil.SetSingleNodeAttribute(xml, nodeColorLegend, "status", "on");
					for ( int i = 0; i < dtLegend.Rows.Count; i++ )
					{
						DataRow row = dtLegend.Rows[i];
						XmlNode nodeMapping = xml.CreateElement("mapping");
						nodeColorLegend.AppendChild(nodeMapping);
						XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "id"   , Sql.ToString(row["NAME"        ]));
						XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "name" , Sql.ToString(row["DISPLAY_NAME"]));
						XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "color", SplendidDefaults.generate_graphcolor(String.Empty, i));
					}
					
					sSQL = "select *              " + ControlChars.CrLf
					     + "  from vwCAMPAIGNS_Roi" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Campaigns", "view");
						Sql.AppendParameter(cmd, gID, "ID", false);
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							if ( rdr.Read() )
							{
								double dBUDGET           = 0.0;
								double dEXPECTED_REVENUE = 0.0;
								double dINVESTMENT       = 0.0;
								double dREVENUE          = 0.0;
								Hashtable hashTOTALS = new Hashtable();
								try
								{
									dBUDGET           = Sql.ToDouble(rdr["BUDGET"          ]);
									dEXPECTED_REVENUE = Sql.ToDouble(rdr["EXPECTED_REVENUE"]);
									dINVESTMENT       = Sql.ToDouble(rdr["ACTUAL_COST"     ]);
									dREVENUE          = Sql.ToDouble(rdr["REVENUE"         ]);
									hashTOTALS.Add("Budget"          , dBUDGET          );
									hashTOTALS.Add("Expected_Revenue", dEXPECTED_REVENUE);
									hashTOTALS.Add("Investment"      , dINVESTMENT      );
									hashTOTALS.Add("Revenue"         , dREVENUE         );
								}
								catch(Exception ex)
								{
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
								}
								foreach ( DataRow row in dtLegend.Rows )
								{
									string sNAME         = Sql.ToString(row["NAME"        ]);
									string sDISPLAY_NAME = Sql.ToString(row["DISPLAY_NAME"]);
									XmlNode nodeRow = xml.CreateElement("dataRow");
									nodeYData.AppendChild(nodeRow);
									XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "title"   , sDISPLAY_NAME);
									XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "endLabel", sDISPLAY_NAME.Substring(0, 1));
									
									XmlNode nodeBar = xml.CreateElement("bar");
									nodeRow.AppendChild(nodeBar);
									double dTOTAL = Sql.ToDouble(hashTOTALS[sNAME]);
									XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "id"       , sNAME);
									XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "totalSize", dTOTAL.ToString("0"));
									XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "altText"  , dTOTAL.ToString("0"));
									// 08/11/2014 Paul.  URL does not work.  Try using the RawUrl. 
									XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "url"      , Request.RawUrl + "#" + sNAME);
								}
								
								double dMAX = 0.0;
								dMAX = Math.Max(dMAX, dREVENUE         );
								dMAX = Math.Max(dMAX, dINVESTMENT      );
								dMAX = Math.Max(dMAX, dBUDGET          );
								dMAX = Math.Max(dMAX, dEXPECTED_REVENUE);
								dMAX = dMAX * 1.2;  // Increase by 20%. 
								if ( dMAX <= 0.0 )
									dMAX = 80.0;
								double dMAX_ROUNDED = Math.Ceiling(dMAX);
								XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "max", dMAX_ROUNDED.ToString("0"));
							}
							XmlUtil.SetSingleNodeAttribute(xml, nodeRoot , "title", L10n.Term("Campaigns.LBL_CAMPAIGN_RETURN_ON_INVESTMENT") + "                                                                                                            ");
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

