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
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Diagnostics;

namespace SplendidCRM.Opportunities.xaml2
{
	/// <summary>
	///		Summary description for OppByLeadSource.
	/// </summary>
	public class OppByLeadSource : SplendidControl
	{
		protected DataView    vwMain;

		#region Properties used when rendering.

		protected string    sGraphData_Title                 ;
		protected string    sGraphData_SubTitle              ;
		protected Hashtable hashColorLegend                  ;

		protected string    sPie_defaultAltText              ;

		protected string    sChartColors_docBorder           ;
		protected string    sChartColors_docBg1              ;
		protected string    sChartColors_docBg2              ;
		protected string    sChartColors_title               ;
		protected string    sChartColors_subtitle            ;
		protected string    sChartColors_misc                ;
		protected string    sChartColors_altBorder           ;
		protected string    sChartColors_altBg               ;
		protected string    sChartColors_altText             ;
		protected string    sChartColors_graphText           ;
		protected string    sChartColors_graphTextShadow     ;
		protected string    sChartColors_pieBorder           ;
		protected string    sChartColors_pieBorderHilite     ;
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
		protected XmlNode     nodePie   ;
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
				
				ListBox lstLEAD_SOURCE      = Parent.FindControl("lstLEAD_SOURCE"     ) as ListBox;
				ListBox lstASSIGNED_USER_ID = Parent.FindControl("lstASSIGNED_USER_ID") as ListBox;

				string[] arrASSIGNED_USER_ID = (lstASSIGNED_USER_ID != null) ? Sql.ToStringArray(lstASSIGNED_USER_ID) : new string[] { Security.USER_ID.ToString() };
				string[] arrLEAD_SOURCE      = (lstLEAD_SOURCE      != null) ? Sql.ToStringArray(lstLEAD_SOURCE     ) : null;

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
						cmd.CommandText += ""
						     + " group by LEAD_SOURCE                                " + ControlChars.CrLf
						     + "        , LIST_ORDER                                 " + ControlChars.CrLf
						     + " order by LIST_ORDER                                 " + ControlChars.CrLf;
						// 09/23/2009 Paul.  Use a simple data table instead of xml to render the embedded data. 
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								dt.Columns.Add("LABEL"        , Type.GetType("System.String"));
								dt.Columns.Add("VALUE"        , Type.GetType("System.Double"));
								dt.Columns.Add("DISPLAY_VALUE", Type.GetType("System.String"));
								dt.Columns.Add("DESCRIPTION"  , Type.GetType("System.String"));
								dt.Columns.Add("URL"          , Type.GetType("System.String"));
								vwMain = dt.DefaultView;

								double dPIPELINE_TOTAL = 0;
								foreach ( DataRow row in dt.Rows )
								{
									string  sLEAD_SOURCE       = Sql.ToString (row["LEAD_SOURCE"      ]);
									double  dTOTAL             = Sql.ToDouble (row["TOTAL"            ]);
									int     nOPPORTUNITY_COUNT = Sql.ToInteger(row["OPPORTUNITY_COUNT"]);
									
									dPIPELINE_TOTAL += dTOTAL;
									// 05/27/2007 Paul.  LBL_NONE is --None--, so create a new term LBL_NONE_VALUE.
									string sLEAD_SOURCE_TERM = String.Empty;
									if ( sLEAD_SOURCE == String.Empty )
										sLEAD_SOURCE_TERM = L10n.Term(".LBL_NONE_VALUE");
									else
										sLEAD_SOURCE_TERM = Sql.ToString(L10n.Term(".lead_source_dom.", sLEAD_SOURCE));

									row["LABEL"        ] = sLEAD_SOURCE_TERM;
									row["VALUE"        ] = dTOTAL;
									row["DISPLAY_VALUE"] = dTOTAL.ToString("c0");
									row["DESCRIPTION"  ] = nOPPORTUNITY_COUNT.ToString() + " " + L10n.Term("Dashboard.LBL_OPPS_IN_LEAD_SOURCE") + " " + sLEAD_SOURCE_TERM;
									row["URL"          ] = Sql.ToString(Application["rootURL"]) + "Opportunities/default.aspx?LEAD_SOURCE=" + Server.UrlEncode(sLEAD_SOURCE);
								}
								//sPie_defaultAltText = L10n.Term("Dashboard.LBL_ROLLOVER_WEDGE_DETAILS");
								// 11/23/2012 Paul.  Add space before value. 
								sGraphData_Title    = L10n.Term("Dashboard.LBL_TOTAL_PIPELINE") + " " + dPIPELINE_TOTAL.ToString("c0") + L10n.Term("Dashboard.LBL_OPP_THOUSANDS");
								sGraphData_SubTitle = L10n.Term("Dashboard.LBL_OPP_SIZE"  ) + " " +1.ToString("c0") + L10n.Term("Dashboard.LBL_OPP_THOUSANDS");
							}
						}
					}
				}
				
				// 09/23/2009 Paul.  Temporarily stop using the SugarCRM color scheme and instead use the default Silverlight Charts color scheme. 
				/*
				XmlDocument xml = new XmlDocument();
				// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
				// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
				// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
				xml.XmlResolver = null;
				xml.LoadXml(SplendidCache.XmlFile(Server.MapPath(Session["themeURL"] + "PieChart.xml")));
				nodeRoot        = xml.SelectSingleNode("graphData");
				nodePie         = xml.CreateElement("pie"      );
				XmlNode nodeGraphInfo   = xml.CreateElement("graphInfo");
				XmlNode nodeChartColors = nodeRoot.SelectSingleNode("chartColors");

				nodeRoot.InsertBefore(nodeGraphInfo  , nodeChartColors);
				nodeRoot.InsertBefore(nodePie        , nodeGraphInfo  );

				hashColorLegend = new Hashtable();
				XmlNodeList nlColorLegend = xml.DocumentElement.SelectNodes("colorLegend/mapping");
				foreach ( XmlNode xMapping in nlColorLegend )
				{
					hashColorLegend.Add(XmlUtil.SelectAttribute(xMapping, "id"), XmlUtil.SelectAttribute(xMapping, "color"));
				}

				sChartColors_docBorder            = XmlUtil.SelectAttribute(nodeChartColors, "docBorder"           );
				sChartColors_docBg1               = XmlUtil.SelectAttribute(nodeChartColors, "docBg1"              );
				sChartColors_docBg2               = XmlUtil.SelectAttribute(nodeChartColors, "docBg2"              );
				sChartColors_title                = XmlUtil.SelectAttribute(nodeChartColors, "title"               );
				sChartColors_subtitle             = XmlUtil.SelectAttribute(nodeChartColors, "subtitle"            );
				sChartColors_misc                 = XmlUtil.SelectAttribute(nodeChartColors, "misc"                );
				sChartColors_altBorder            = XmlUtil.SelectAttribute(nodeChartColors, "altBorder"           );
				sChartColors_altBg                = XmlUtil.SelectAttribute(nodeChartColors, "altBg"               );
				sChartColors_altText              = XmlUtil.SelectAttribute(nodeChartColors, "altText"             );
				sChartColors_graphText            = XmlUtil.SelectAttribute(nodeChartColors, "graphText"           );
				sChartColors_graphTextShadow      = XmlUtil.SelectAttribute(nodeChartColors, "graphTextShadow"     );
				sChartColors_pieBorder            = XmlUtil.SelectAttribute(nodeChartColors, "pieBorder"           );
				sChartColors_pieBorderHilite      = XmlUtil.SelectAttribute(nodeChartColors, "pieBorderHilite"     );
				sChartColors_legendBorder         = XmlUtil.SelectAttribute(nodeChartColors, "legendBorder"        );
				sChartColors_legendBg1            = XmlUtil.SelectAttribute(nodeChartColors, "legendBg1"           );
				sChartColors_legendBg2            = XmlUtil.SelectAttribute(nodeChartColors, "legendBg2"           );
				sChartColors_legendText           = XmlUtil.SelectAttribute(nodeChartColors, "legendText"          );
				sChartColors_legendColorKeyBorder = XmlUtil.SelectAttribute(nodeChartColors, "legendColorKeyBorder");
				sChartColors_scrollBar            = XmlUtil.SelectAttribute(nodeChartColors, "scrollBar"           );
				sChartColors_scrollBarBorder      = XmlUtil.SelectAttribute(nodeChartColors, "scrollBarBorder"     );
				sChartColors_scrollBarTrack       = XmlUtil.SelectAttribute(nodeChartColors, "scrollBarTrack"      );
				sChartColors_scrollBarTrackBorder = XmlUtil.SelectAttribute(nodeChartColors, "scrollBarTrackBorder");
				*/

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
				ScriptReference scrSilverlight = new ScriptReference ("~/Include/Silverlight/Silverlight.js");
				mgrAjax.Scripts.Add(scrSilverlight);
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

