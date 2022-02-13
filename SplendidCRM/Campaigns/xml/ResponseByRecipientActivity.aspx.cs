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
	/// Summary description for ResponseByRecipientActivity.
	/// </summary>
	public class ResponseByRecipientActivity : SplendidPage
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

				XmlUtil.SetSingleNodeAttribute(xml, nodeYData, "defaultAltText", L10n.Term("Campaigns.LBL_ROLLOVER_VIEW"));
				XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "min"   , "0" );
				XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "max"   , "100");
				XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "length", "10");
				XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "prefix", ""  );
				XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "suffix", ""  );

				Hashtable hashTARGET = new Hashtable();
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					// 12/25/2007 Paul.  Prepopulate the activity type rows so that empty rows will appear.  The SQL query will not return empty rows. 
					DataTable dtActivityTypes = SplendidCache.List("campainglog_activity_type_dom").Copy();
					DataRow rowActivityTypeNone = dtActivityTypes.NewRow();
					dtActivityTypes.Rows.InsertAt(rowActivityTypeNone, 0);
					rowActivityTypeNone["NAME"        ] = "";
					rowActivityTypeNone["DISPLAY_NAME"] = L10n.Term("Campaigns.NTC_NO_LEGENDS");
					foreach ( DataRow row in dtActivityTypes.Rows )
					{
						XmlNode nodeRow = xml.CreateElement("dataRow");
						nodeYData.AppendChild(nodeRow);
						XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "title"   , Sql.ToString(row["DISPLAY_NAME"]));
						XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "endLabel", "0");
					}

					// 12/25/2007 Paul.  Prepopulate the targets. 
					DataTable dtLegend = SplendidCache.List("campainglog_target_type_dom");
					XmlUtil.SetSingleNodeAttribute(xml, nodeColorLegend, "status", "on");
					for ( int i = 0; i < dtLegend.Rows.Count; i++ )
					{
						DataRow row = dtLegend.Rows[i];
						string sTARGET = Sql.ToString(row["NAME"]);
						if ( !hashTARGET.ContainsKey(sTARGET) )
						{
							XmlNode nodeMapping = xml.CreateElement("mapping");
							nodeColorLegend.AppendChild(nodeMapping);
							XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "id"   , Sql.ToString(row["NAME"        ]));
							XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "name" , Sql.ToString(row["DISPLAY_NAME"]));
							XmlUtil.SetSingleNodeAttribute(xml, nodeMapping, "color", SplendidDefaults.generate_graphcolor(String.Empty, hashTARGET.Count));
							hashTARGET.Add(sTARGET, sTARGET);
						}
					}

					sSQL = "select ACTIVITY_TYPE                         " + ControlChars.CrLf
					     + "     , TARGET_TYPE                           " + ControlChars.CrLf
					     + "     , LIST_ORDER                            " + ControlChars.CrLf
					     + "     , count(*)                  as HIT_COUNT" + ControlChars.CrLf
					     + "  from vwCAMPAIGNS_Activity                  " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Campaigns", "view");
						Sql.AppendParameter(cmd, gID, "ID", false);
						cmd.CommandText += ""
						     + " group by ACTIVITY_TYPE                      " + ControlChars.CrLf
						     + "        , LIST_ORDER                         " + ControlChars.CrLf
						     + "        , TARGET_TYPE                        " + ControlChars.CrLf
						     + " order by LIST_ORDER                         " + ControlChars.CrLf
						     + "        , TARGET_TYPE                        " + ControlChars.CrLf;
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							int nMAX_COUNT = 0;
							while ( rdr.Read() )
							{
								string  sACTIVITY_TYPE = Sql.ToString (rdr["ACTIVITY_TYPE"]);
								string  sTARGET_TYPE   = Sql.ToString (rdr["TARGET_TYPE"  ]);
								int     nHIT_COUNT     = Sql.ToInteger(rdr["HIT_COUNT"    ]);
								
								if ( nHIT_COUNT > nMAX_COUNT )
									nMAX_COUNT = nHIT_COUNT;
								string sACTIVITY_TYPE_TERM = String.Empty;
								if ( sACTIVITY_TYPE == String.Empty )
									sACTIVITY_TYPE_TERM = L10n.Term("Campaigns.NTC_NO_LEGENDS");
								else
									sACTIVITY_TYPE_TERM = Sql.ToString(L10n.Term(".campainglog_activity_type_dom.", sACTIVITY_TYPE));
								
								int nEND_LABEL = nHIT_COUNT;
								
								XmlNode nodeRow = nodeYData.SelectSingleNode("dataRow[@title=\'" + sACTIVITY_TYPE_TERM.Replace("'", "\'") +"\']");
								if ( nodeRow == null )
								{
									nodeRow = xml.CreateElement("dataRow");
									nodeYData.AppendChild(nodeRow);
									XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "title"   , sACTIVITY_TYPE_TERM);
									XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "endLabel", nEND_LABEL.ToString());
								}
								else
								{
									if ( nodeRow.Attributes.GetNamedItem("endLabel") != null )
									{
										nEND_LABEL = Sql.ToInteger(nodeRow.Attributes.GetNamedItem("endLabel").Value);
										nEND_LABEL += nHIT_COUNT;
										if ( nEND_LABEL > nMAX_COUNT )
											nMAX_COUNT = nEND_LABEL;
										XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "endLabel", nEND_LABEL.ToString());
									}
								}
								XmlNode nodeBar = xml.CreateElement("bar");
								nodeRow.AppendChild(nodeBar);
								
								XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "id"       , sTARGET_TYPE);
								XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "totalSize", nHIT_COUNT.ToString());
								
								if ( sACTIVITY_TYPE == "targeted" )
									XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "altText"  , L10n.Term("Campaigns.LBL_TARGETED") + nHIT_COUNT.ToString() + ", " + L10n.Term("Campaigns.LBL_TOTAL_TARGETED") + " " + nEND_LABEL.ToString() + ".");
								else
									XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "altText"  , nHIT_COUNT.ToString() + " " + Sql.ToString(L10n.Term(".campainglog_target_type_dom.", sTARGET_TYPE)) );
								// 08/11/2014 Paul.  URL does not work.  Try using the RawUrl. 
								XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "url"      , Request.RawUrl + "#ACTIVITY_TYPE=" + Server.UrlEncode(sACTIVITY_TYPE) + "&TARGET_TYPE=" + Server.UrlEncode(sTARGET_TYPE) );
							}
							if ( nMAX_COUNT < 10 )
								nMAX_COUNT = 10;
							XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "max", nMAX_COUNT.ToString());
							XmlUtil.SetSingleNodeAttribute(xml, nodeRoot , "title", L10n.Term("Campaigns.LBL_CAMPAIGN_RESPONSE_BY_RECIPIENT_ACTIVITY"));
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

