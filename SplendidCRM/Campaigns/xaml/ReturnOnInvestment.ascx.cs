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
	///		Summary description for ReturnOnInvestment.
	/// </summary>
	public class ReturnOnInvestment : SplendidControl
	{
		protected XmlDocument xml = new XmlDocument();
		// 02/02/2008 Paul.  OppByLeadSource, OppByLeadSourceByOutcome, PipelineByMonthByOutcome, PipelineBySalesStage
		// in the dashboard have a chart length of 10. 
		protected int nCHART_LENGTH = 10;

		public int CHART_LENGTH
		{
			get { return nCHART_LENGTH; }
			set { nCHART_LENGTH = value; }
		}

		#region Properties used when rendering.
		protected int       nGridWidth  = 500;
		protected int       nGridHeight = 220;

		protected string    sGraphData_Title                 ;
		protected string    sGraphData_GraphInfo             ;
		protected Hashtable hashColorLegend                  ;

		protected int       nAxis_xData_length               = 1;
		protected double    dAxis_xData_section              ;

		protected string    sAxis_yData_defaultAltText       ;
		protected int       nAxis_yData_min                  ;
		protected int       nAxis_yData_max                  ;
		protected int       nAxis_yData_length               = 1;
		protected double    dAxis_yData_section              ;
		protected string    sAxis_yData_prefix               ;
		protected string    sAxis_yData_suffix               ;

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
									XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "title"    , sDISPLAY_NAME);
									XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "endLabel" , sDISPLAY_NAME.Substring(0, 1));
									
									XmlNode nodeBar = xml.CreateElement("bar");
									nodeRow.AppendChild(nodeBar);
									double dTOTAL = Sql.ToDouble(hashTOTALS[sNAME]);
									XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "id"         , sNAME);
									XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "totalSize"  , dTOTAL.ToString("0"));
									XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "altText"    , dTOTAL.ToString("0"));
									// 08/11/2014 Paul.  URL does not work.  Try using the RawUrl. 
									XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "url"        , Request.RawUrl + "#" + sNAME);
									XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "startOffset", "0");

									// 04/04/2008 Paul.  We also need the size at the row level. 
									XmlUtil.SetSingleNodeAttribute(xml, nodeRow, "totalSize", dTOTAL.ToString("0"));
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
							XmlUtil.SetSingleNodeAttribute(xml, nodeRoot , "title", L10n.Term("Campaigns.LBL_CAMPAIGN_RETURN_ON_INVESTMENT"));
						}
					}
				}

				// 04/04/2008 Paul.  We need to switch the X & Y axis.
				nodeXData = xml.DocumentElement.SelectSingleNode("yData");
				nodeYData = xml.DocumentElement.SelectSingleNode("xData");
				nlDataRows = xml.DocumentElement.SelectNodes("yData/dataRow");
				
				sGraphData_Title     = XmlUtil.SelectAttribute (nodeRoot, "title");
				sGraphData_GraphInfo = XmlUtil.SelectSingleNode(nodeRoot, "graphInfo").Replace("<BR/>", " ");

				nAxis_xData_length         = Sql.ToInteger(XmlUtil.SelectAttribute(nodeXData, "length"));

				sAxis_yData_defaultAltText = XmlUtil.SelectAttribute(nodeYData, "defaultAltText");
				nAxis_yData_min            = Sql.ToInteger(XmlUtil.SelectAttribute(nodeYData, "min"   ));
				nAxis_yData_max            = Sql.ToInteger(XmlUtil.SelectAttribute(nodeYData, "max"   ));
				nAxis_yData_length         = Sql.ToInteger(XmlUtil.SelectAttribute(nodeYData, "length"));
				sAxis_yData_prefix         = XmlUtil.SelectAttribute(nodeYData, "prefix");
				sAxis_yData_suffix         = XmlUtil.SelectAttribute(nodeYData, "suffix");
				if ( nAxis_yData_length == 0 )
					nAxis_yData_length = 1;
				if ( nAxis_yData_max == 0 )
					nAxis_yData_max = nGridHeight;
				dAxis_yData_section        = Convert.ToDouble(nAxis_yData_max - nAxis_yData_min) / nAxis_yData_length;
				if ( nlDataRows.Count > 0 )
				{
					nAxis_xData_length  = nGridWidth / (nlDataRows.Count + nlDataRows.Count / 2);
					dAxis_xData_section = nAxis_xData_length  / 2;
				}

				

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
				ScriptReference scrSilverlight        = new ScriptReference ("~/Include/Silverlight/Silverlight.js"  );
				ScriptReference scrReturnOnInvestment = new ScriptReference ("~/Campaigns/xaml/ReturnOnInvestment.js");
				ScriptReference scrScroller           = new ScriptReference ("~/Include/Silverlight/scroller.js"     );
				mgrAjax.Scripts.Add(scrSilverlight       );
				mgrAjax.Scripts.Add(scrReturnOnInvestment);
				mgrAjax.Scripts.Add(scrScroller          );
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

