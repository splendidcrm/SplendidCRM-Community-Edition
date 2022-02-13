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
	/// Summary description for OppByLeadSource.
	/// </summary>
	public class OppByLeadSource : SplendidPage
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
				string[] arrASSIGNED_USER_ID = Request.QueryString.GetValues("ASSIGNED_USER_ID");
				// 09/15/2005 Paul.  Values will always be in the query string. 
				string[] arrLEAD_SOURCE = Request.QueryString.GetValues("LEAD_SOURCE");

				xml.LoadXml(SplendidCache.XmlFile(Server.MapPath(Session["themeURL"] + "PieChart.xml")));
				XmlNode nodeRoot        = xml.SelectSingleNode("graphData");
				XmlNode nodePie         = xml.CreateElement("pie"      );
				XmlNode nodeGraphInfo   = xml.CreateElement("graphInfo");
				XmlNode nodeChartColors = nodeRoot.SelectSingleNode("chartColors");

				nodeRoot.InsertBefore(nodeGraphInfo  , nodeChartColors);
				nodeRoot.InsertBefore(nodePie        , nodeGraphInfo  );
				
				XmlUtil.SetSingleNodeAttribute(xml, nodePie, "defaultAltText", L10n.Term("Dashboard.LBL_ROLLOVER_WEDGE_DETAILS"));
				
				Hashtable hashLEAD_SOURCE = new Hashtable();
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					// 08/07/2015 Paul.  Revenue Line Items. 
					sSQL = "select LEAD_SOURCE                                   " + ControlChars.CrLf
					     + "     , LIST_ORDER                                    " + ControlChars.CrLf
					     + "     , sum(AMOUNT_USDOLLAR/1000) as TOTAL            " + ControlChars.CrLf
					     + "     , count(*)                  as OPPORTUNITY_COUNT" + ControlChars.CrLf
					     + "  from vw" + Crm.Config.OpportunitiesMode().ToUpper() + "_ByLeadSource" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Opportunities", "list");
						// 09/14/2005 Paul.  Use append because it supports arrays using the IN clause. 
						// 06/23/2018 Paul.  Need to allow multiple users to see the data they are assigned to. 
						if ( Crm.Config.enable_dynamic_assignment() )
							Sql.AppendLikeParameters(cmd, arrASSIGNED_USER_ID, "ASSIGNED_SET_LIST");
						else
							Sql.AppendGuids    (cmd, arrASSIGNED_USER_ID, "ASSIGNED_USER_ID");
						Sql.AppendParameter(cmd, arrLEAD_SOURCE     , "LEAD_SOURCE"     );
#if false
						if ( arrLEAD_SOURCE != null )
							nodeGraphInfo.InnerText = "LEAD_SOURCE = " + String.Join(", ", arrLEAD_SOURCE);
#endif
						cmd.CommandText += ""
						     + " group by LEAD_SOURCE                                " + ControlChars.CrLf
						     + "        , LIST_ORDER                                 " + ControlChars.CrLf
						     + " order by LIST_ORDER                                 " + ControlChars.CrLf;
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							double dMAX_TOTAL      = 0;
							double dPIPELINE_TOTAL = 0;
							while ( rdr.Read() )
							{
								string  sLEAD_SOURCE       = Sql.ToString (rdr["LEAD_SOURCE"      ]);
								double  dTOTAL             = Sql.ToDouble (rdr["TOTAL"            ]);
								int     nOPPORTUNITY_COUNT = Sql.ToInteger(rdr["OPPORTUNITY_COUNT"]);
								
								dPIPELINE_TOTAL += dTOTAL;
								if ( dTOTAL > dMAX_TOTAL )
									dMAX_TOTAL = dTOTAL;
								// 05/27/2007 Paul.  LBL_NONE is --None--, so create a new term LBL_NONE_VALUE.
								string sLEAD_SOURCE_TERM = String.Empty;
								if ( sLEAD_SOURCE == String.Empty )
									sLEAD_SOURCE_TERM = L10n.Term(".LBL_NONE_VALUE");
								else
									sLEAD_SOURCE_TERM = Sql.ToString(L10n.Term(".lead_source_dom.", sLEAD_SOURCE));

								XmlNode nodeWedge = xml.CreateElement("bar");
								nodePie.AppendChild(nodeWedge);
								XmlUtil.SetSingleNodeAttribute(xml, nodeWedge, "title"    , sLEAD_SOURCE_TERM);
								XmlUtil.SetSingleNodeAttribute(xml, nodeWedge, "value"    , dTOTAL.ToString("0"));
								XmlUtil.SetSingleNodeAttribute(xml, nodeWedge, "color"    , SplendidDefaults.generate_graphcolor(sLEAD_SOURCE, hashLEAD_SOURCE.Count));
								XmlUtil.SetSingleNodeAttribute(xml, nodeWedge, "labelText", dTOTAL.ToString("c0"));
								XmlUtil.SetSingleNodeAttribute(xml, nodeWedge, "url"      , Sql.ToString(Application["rootURL"]) + "Opportunities/default.aspx?LEAD_SOURCE=" + Server.UrlEncode(sLEAD_SOURCE));
								XmlUtil.SetSingleNodeAttribute(xml, nodeWedge, "altText"  , nOPPORTUNITY_COUNT.ToString() + " " + L10n.Term("Dashboard.LBL_OPPS_IN_LEAD_SOURCE") + " " + sLEAD_SOURCE_TERM);
								hashLEAD_SOURCE.Add(sLEAD_SOURCE, sLEAD_SOURCE);
							}
							// 11/23/2012 Paul.  Add space before value. 
							XmlUtil.SetSingleNodeAttribute(xml, nodeRoot , "title"   , L10n.Term("Dashboard.LBL_TOTAL_PIPELINE") + " " + dPIPELINE_TOTAL.ToString("c0") + L10n.Term("Dashboard.LBL_OPP_THOUSANDS"));
							XmlUtil.SetSingleNodeAttribute(xml, nodeRoot , "subtitle", L10n.Term("Dashboard.LBL_OPP_SIZE"  ) + " " +1.ToString("c0") + L10n.Term("Dashboard.LBL_OPP_THOUSANDS"));
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

