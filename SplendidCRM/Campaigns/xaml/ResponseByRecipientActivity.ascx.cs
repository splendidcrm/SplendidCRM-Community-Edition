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
using System.Collections;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Diagnostics;

namespace SplendidCRM.Campaigns.xaml
{
	/// <summary>
	///		Summary description for ResponseByRecipientActivity.
	/// </summary>
	public class ResponseByRecipientActivity : SplendidControl
	{
		protected XmlDocument xml = new XmlDocument();
		// 02/02/2008 Paul.  OppByLeadSource, OppByLeadSourceByOutcome, PipelineByMonthByOutcome, PipelineBySalesStage
		// in the dashboard have a chart length of 10. 
		protected int nCHART_LENGTH = 4;

		public int CHART_LENGTH
		{
			get { return nCHART_LENGTH; }
			set { nCHART_LENGTH = value; }
		}

		#region Properties used when rendering.
		protected int       nGridWidth  = 400;
		protected int       nGridHeight = 226;

		protected string    sGraphData_Title                 ;
		protected string    sGraphData_GraphInfo             ;
		protected Hashtable hashColorLegend                  ;

		protected string    sAxis_yData_defaultAltText       ;

		protected int       nAxis_xData_min                  ;
		protected int       nAxis_xData_max                  ;
		protected int       nAxis_xData_length               = 1;
		protected double    dAxis_xData_section              ;
		protected string    sAxis_xData_prefix               ;
		protected string    sAxis_xData_suffix               ;

		protected string    sChartColors_docBorder           ;
		protected string    sChartColors_docBg1              ;
		protected string    sChartColors_docBg2              ;
		protected string    sChartColors_xText               ;
		protected string    sChartColors_yText               ;
		protected string    sChartColors_title               ;
		protected string    sChartColors_misc                ;
		protected string    sChartColors_altBorder           ;
		protected string    sChartColors_altBg               ;
		protected string    sChartColors_altText             ;
		protected string    sChartColors_graphBorder         ;
		protected string    sChartColors_graphBg1            ;
		protected string    sChartColors_graphBg2            ;
		protected string    sChartColors_graphLines          ;
		protected string    sChartColors_graphText           ;
		protected string    sChartColors_graphTextShadow     ;
		protected string    sChartColors_barBorder           ;
		protected string    sChartColors_barBorderHilite     ;
		protected string    sChartColors_legendBorder        ;
		protected string    sChartColors_legendBg1           ;
		protected string    sChartColors_legendBg2           ;
		protected string    sChartColors_legendText          ;
		protected string    sChartColors_legendColorKeyBorder;
		protected string    sChartColors_scrollBar           ;
		protected string    sChartColors_scrollBarBorder     ;
		protected string    sChartColors_scrollBarTrack      ;
		protected string    sChartColors_scrollBarTrackBorder;

		protected XmlNodeList nlDataRows;
		protected XmlNode     nodeRoot  ;
		protected XmlNode     nodeYData ;
		protected XmlNode     nodeXData ;
		protected XmlNodeList nlColorLegend;
		#endregion

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 09/21/2008 Paul.  Mono does not support Silverlight inline XAML at this time. 
			// 09/22/2008 Paul.  The Mono exception code was moved to enable_silverlight(). 
			if ( !Crm.Config.enable_silverlight() )
			{
				this.Visible = false;
				return;
			}
			// 09/11/2008 Paul.  Silverlight requires that all numeric values need to be in US format. 
			// Reset the culture before binding/rendering so that all the numeric conversions will be automatic. 
			// All currencies should already be converted to text, so there should not be an impact. 
			// 01/11/2009 Paul.  We need to save and restore the previous culture as there are other controls on the page. 
			// 10/13/2010 Paul.  Move the culture fix higher up so that all numeric ToString() operations are in English. 
			System.Globalization.CultureInfo ciCurrent = System.Threading.Thread.CurrentThread.CurrentCulture;
			try
			{
				System.Globalization.CultureInfo ciEnglish = System.Globalization.CultureInfo.CreateSpecificCulture("en-US");
				ciEnglish.DateTimeFormat.ShortDatePattern = ciCurrent.DateTimeFormat.ShortDatePattern;
				ciEnglish.DateTimeFormat.ShortTimePattern = ciCurrent.DateTimeFormat.ShortTimePattern;
				ciEnglish.NumberFormat.CurrencySymbol     = ciCurrent.NumberFormat.CurrencySymbol;
				System.Threading.Thread.CurrentThread.CurrentCulture   = ciEnglish;
				System.Threading.Thread.CurrentThread.CurrentUICulture = ciEnglish;
				
				Guid gID = Sql.ToGuid(Request["ID"]);
				// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
				// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
				// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
				xml.XmlResolver = null;
				xml.LoadXml(SplendidCache.XmlFile(Server.MapPath(Session["themeURL"] + "BarChart.xml")));
				nodeRoot        = xml.SelectSingleNode("graphData");
				nodeXData       = xml.CreateElement("xData"      );
				nodeYData       = xml.CreateElement("yData"      );
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
								int     nSTART_OFFSET  = 0;
								
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
										nSTART_OFFSET = nEND_LABEL;
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
								XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "startOffset", nSTART_OFFSET.ToString("0"));
							}
							if ( nMAX_COUNT < 10 )
								nMAX_COUNT = 10;
							XmlUtil.SetSingleNodeAttribute(xml, nodeXData, "max", nMAX_COUNT.ToString());
							XmlUtil.SetSingleNodeAttribute(xml, nodeRoot , "title", L10n.Term("Campaigns.LBL_CAMPAIGN_RESPONSE_BY_RECIPIENT_ACTIVITY"));
						}
					}
				}

				nlDataRows = xml.DocumentElement.SelectNodes("yData/dataRow");
				nGridHeight = nlDataRows.Count == 0 ? 226 : 6 + nlDataRows.Count * 20;
				
				sGraphData_Title     = XmlUtil.SelectAttribute (nodeRoot, "title");
				sGraphData_GraphInfo = XmlUtil.SelectSingleNode(nodeRoot, "graphInfo").Replace("<BR/>", " ");

				sAxis_yData_defaultAltText = XmlUtil.SelectAttribute(nodeYData, "defaultAltText");

				nAxis_xData_min            = Sql.ToInteger(XmlUtil.SelectAttribute(nodeXData, "min"   ));
				nAxis_xData_max            = Sql.ToInteger(XmlUtil.SelectAttribute(nodeXData, "max"   ));
				nAxis_xData_length         = Sql.ToInteger(XmlUtil.SelectAttribute(nodeXData, "length"));
				sAxis_xData_prefix         = XmlUtil.SelectAttribute(nodeXData, "prefix");
				sAxis_xData_suffix         = XmlUtil.SelectAttribute(nodeXData, "suffix");
				if ( nAxis_xData_length == 0 )
					nAxis_xData_length = 1;
				if ( nAxis_xData_max == 0 )
					nAxis_xData_max = nGridWidth;
				dAxis_xData_section        = Convert.ToDouble(nAxis_xData_max - nAxis_xData_min) / nAxis_xData_length;

				hashColorLegend = new Hashtable();
				nlColorLegend = xml.DocumentElement.SelectNodes("colorLegend/mapping");
				foreach ( XmlNode xMapping in nlColorLegend )
				{
					hashColorLegend.Add(XmlUtil.SelectAttribute(xMapping, "id"), XmlUtil.SelectAttribute(xMapping, "color"));
				}

				sChartColors_docBorder            = XmlUtil.SelectAttribute(nodeChartColors, "docBorder"           );
				sChartColors_docBg1               = XmlUtil.SelectAttribute(nodeChartColors, "docBg1"              );
				sChartColors_docBg2               = XmlUtil.SelectAttribute(nodeChartColors, "docBg2"              );
				sChartColors_xText                = XmlUtil.SelectAttribute(nodeChartColors, "xText"               );
				sChartColors_yText                = XmlUtil.SelectAttribute(nodeChartColors, "yText"               );
				sChartColors_title                = XmlUtil.SelectAttribute(nodeChartColors, "title"               );
				sChartColors_misc                 = XmlUtil.SelectAttribute(nodeChartColors, "misc"                );
				sChartColors_altBorder            = XmlUtil.SelectAttribute(nodeChartColors, "altBorder"           );
				sChartColors_altBg                = XmlUtil.SelectAttribute(nodeChartColors, "altBg"               );
				sChartColors_altText              = XmlUtil.SelectAttribute(nodeChartColors, "altText"             );
				sChartColors_graphBorder          = XmlUtil.SelectAttribute(nodeChartColors, "graphBorder"         );
				sChartColors_graphBg1             = XmlUtil.SelectAttribute(nodeChartColors, "graphBg1"            );
				sChartColors_graphBg2             = XmlUtil.SelectAttribute(nodeChartColors, "graphBg2"            );
				sChartColors_graphLines           = XmlUtil.SelectAttribute(nodeChartColors, "graphLines"          );
				sChartColors_graphText            = XmlUtil.SelectAttribute(nodeChartColors, "graphText"           );
				sChartColors_graphTextShadow      = XmlUtil.SelectAttribute(nodeChartColors, "graphTextShadow"     );
				sChartColors_barBorder            = XmlUtil.SelectAttribute(nodeChartColors, "barBorder"           );
				sChartColors_barBorderHilite      = XmlUtil.SelectAttribute(nodeChartColors, "barBorderHilite"     );
				sChartColors_legendBorder         = XmlUtil.SelectAttribute(nodeChartColors, "legendBorder"        );
				sChartColors_legendBg1            = XmlUtil.SelectAttribute(nodeChartColors, "legendBg1"           );
				sChartColors_legendBg2            = XmlUtil.SelectAttribute(nodeChartColors, "legendBg2"           );
				sChartColors_legendText           = XmlUtil.SelectAttribute(nodeChartColors, "legendText"          );
				sChartColors_legendColorKeyBorder = XmlUtil.SelectAttribute(nodeChartColors, "legendColorKeyBorder");
				sChartColors_scrollBar            = XmlUtil.SelectAttribute(nodeChartColors, "scrollBar"           );
				sChartColors_scrollBarBorder      = XmlUtil.SelectAttribute(nodeChartColors, "scrollBarBorder"     );
				sChartColors_scrollBarTrack       = XmlUtil.SelectAttribute(nodeChartColors, "scrollBarTrack"      );
				sChartColors_scrollBarTrackBorder = XmlUtil.SelectAttribute(nodeChartColors, "scrollBarTrackBorder");

				this.DataBind();
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				Response.Write(ex.Message);
			}
			finally
			{
				System.Threading.Thread.CurrentThread.CurrentCulture   = ciCurrent;
				System.Threading.Thread.CurrentThread.CurrentUICulture = ciCurrent;
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
			// 02/11/2008 Paul.  GetCurrent is a better way to get the Ajax manager. 
			ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
			if ( mgrAjax != null && Crm.Config.enable_silverlight() )
			{
				ScriptReference scrSilverlight                 = new ScriptReference ("~/Include/Silverlight/Silverlight.js"           );
				ScriptReference scrResponseByRecipientActivity = new ScriptReference ("~/Campaigns/xaml/ResponseByRecipientActivity.js");
				ScriptReference scrScroller                    = new ScriptReference ("~/Include/Silverlight/scroller.js"              );
				mgrAjax.Scripts.Add(scrSilverlight                );
				mgrAjax.Scripts.Add(scrResponseByRecipientActivity);
				mgrAjax.Scripts.Add(scrScroller                   );
			}
		}
		
		/// <summary>
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
			m_sMODULE = "Opportunities";
		}
		#endregion
	}
}

