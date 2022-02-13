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
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Dashboard
{
	/// <summary>
	///		Summary description for PipelineBySalesStage.
	/// </summary>
	public class PipelineBySalesStage : SplendidControl
	{
		protected _controls.ChartDatePicker ctlDATE_START ;
		protected _controls.ChartDatePicker ctlDATE_END   ;
		protected ListBox                   lstSALES_STAGE;
		protected ListBox                   lstASSIGNED_USER_ID;
		protected bool                      bShowEditDialog = false;
		protected HyperLink                 lnkXML        ;

		protected string PipelineQueryString()
		{
			StringBuilder sb = new StringBuilder();
			sb.Append("CHART_LENGTH=10");
			sb.Append("&DATE_START=");
			// 07/09/2006 Paul.  The date is passed as TimeZone time, which is what the control value returns, so no conversion is necessary. 
			sb.Append(Server.UrlEncode(Sql.ToDateString(ctlDATE_START.Value)));
			sb.Append("&DATE_END=");
			sb.Append(Server.UrlEncode(Sql.ToDateString(ctlDATE_END.Value)));
			foreach(ListItem item in lstASSIGNED_USER_ID.Items)
			{
				if ( item.Selected )
				{
					sb.Append("&ASSIGNED_USER_ID=");
					sb.Append(Server.UrlEncode(item.Value));
				}
			}
			foreach(ListItem item in lstSALES_STAGE.Items)
			{
				if ( item.Selected )
				{
					sb.Append("&SALES_STAGE=");
					sb.Append(Server.UrlEncode(item.Value));
				}
			}
			// 09/15/2005 Paul.  The hBarS flash will append a "?0.12341234" timestamp to the URL. 
			// Use a bogus parameter to separate the timestamp from the last sales stage. 
			sb.Append("&TIME_STAMP=");
			return sb.ToString();
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Submit" )
			{
				ctlDATE_START.Validate();
				ctlDATE_END  .Validate();
				if ( Page.IsValid )
				{
					ViewState["PipelineBySalesStageQueryString"] = PipelineQueryString();
				}
				// 01/19/2007 Paul.  Keep the edit dialog visible.
				bShowEditDialog = true;
				// 03/29/2008 Paul.  Update the data binding of just the XML link. 
				lnkXML.DataBind();
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( !IsPostBack )
			{
				lstSALES_STAGE.DataSource = SplendidCache.List("sales_stage_dom");
				lstSALES_STAGE.DataBind();
				// 05/29/2017 Paul.  We should be using AssignedUser() and not ActiveUsers(). 
				lstASSIGNED_USER_ID.DataSource = SplendidCache.AssignedUser();
				lstASSIGNED_USER_ID.DataBind();
				// 09/14/2005 Paul.  Default to today, and all sales stages. 
				foreach(ListItem item in lstSALES_STAGE.Items)
				{
					item.Selected = true;
				}
				foreach(ListItem item in lstASSIGNED_USER_ID.Items)
				{
					item.Selected = true;
				}
				// 07/09/2006 Paul.  The date is passed as TimeZone time, so convert from server time. 
				ctlDATE_START.Value = T10n.FromServerTime(DateTime.Today);
				// 07/06/2016 Paul.  Use +5 years instead of 2100 to reduce truncation when displaying year as yy. 
				ctlDATE_END  .Value = T10n.FromServerTime(new DateTime(DateTime.Today.Year + 5, 1, 1));
				// 09/15/2005 Paul.  Maintain the pipeline query string separately so that we can respond to specific submit requests 
				// and ignore all other control events on the page. 
				ViewState["PipelineBySalesStageQueryString"] = PipelineQueryString();
				// 03/29/2008 Paul.  Update the data binding of just the XML link. 
				lnkXML.DataBind();
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
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
		}
		#endregion
	}
}

