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
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Web.Optimization;
using System.Diagnostics;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for SurveyUtil.
	/// </summary>
	public class ChartUtil
	{
		public static void RegisterScripts(Page Page)
		{
			try
			{
				AjaxControlToolkit.ToolkitScriptManager mgrAjax = ScriptManager.GetCurrent(Page) as AjaxControlToolkit.ToolkitScriptManager;

				// 07/01/2017 Paul.  Use Microsoft ASP.NET Web Optimization 1.1.3 to combine stylesheets and javascript. 
				// 01/24/2018 Paul.  Include version in url to ensure updates of combined files. 
				string sBundleName = "~/Charts/ChartScriptsCombined" + "_" + Sql.ToString(HttpContext.Current.Application["SplendidVersion"]);
				Bundle bndChartScripts = new Bundle(sBundleName);
				// 07/01/2017 Paul.  We are not going to support old browsers anymore. 
				//HttpRequest Request = HttpContext.Current.Request;
				//if ( (Request.UserAgent.IndexOf("MSIE 6.0") > 0) || (Request.UserAgent.IndexOf("MSIE 7.0") > 0) || (Request.UserAgent.IndexOf("MSIE 8.0") > 0) )
				//	bndChartScripts.Include("~/Include/jqPlot/excanvas.min.js");
				// 08/25/2013 Paul.  jQuery now registered in the master pages. 
				bndChartScripts.Include("~/Include/jqPlot/jquery.jqplot.min.js"                         );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.barRenderer.min.js"            );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.BezierCurveRenderer.min.js"    );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.blockRenderer.min.js"          );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.bubbleRenderer.min.js"         );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.canvasAxisLabelRenderer.min.js");
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.canvasAxisTickRenderer.min.js" );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.canvasOverlay.min.js"          );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.canvasTextRenderer.min.js"     );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.categoryAxisRenderer.min.js"   );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.ciParser.min.js"               );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.cursor.min.js"                 );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.dateAxisRenderer.min.js"       );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.donutRenderer.min.js"          );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.dragable.min.js"               );
				// 06/21/2013 Paul.  Reverse is not a property. 
				// 01/22/2015 Paul.  Missing min from enhancedLegendRenderer. 
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.enhancedLegendRenderer.min.js" );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.funnelRenderer.min.js"         );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.highlighter.min.js"            );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.json2.min.js"                  );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.logAxisRenderer.min.js"        );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.mekkoAxisRenderer.min.js"      );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.mekkoRenderer.min.js"          );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.meterGaugeRenderer.min.js"     );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.ohlcRenderer.min.js"           );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.pieRenderer.min.js"            );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.pointLabels.min.js"            );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.pyramidAxisRenderer.min.js"    );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.pyramidGridRenderer.min.js"    );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.pyramidRenderer.min.js"        );
				bndChartScripts.Include("~/Include/jqPlot/plugins/jqplot.trendline.min.js"              );
				BundleTable.Bundles.Add(bndChartScripts);
				Sql.AddScriptReference(mgrAjax, sBundleName);
				
				Sql.AddStyleSheet(Page, "~/Include/jqPlot/jquery.jqplot.min.css");
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
			}
		}
	}
}

