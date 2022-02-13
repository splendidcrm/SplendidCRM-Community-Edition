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

namespace SplendidCRM.Dashboard.SilverlightCharts
{
	/// <summary>
	///		Summary description for OppByLeadSourceByOutcome.
	/// </summary>
	public class OppByLeadSourceByOutcome : DashletControl
	{
		protected _controls.DashletHeader  ctlDashletHeader ;

		protected ListBox                   lstLEAD_SOURCE;
		protected ListBox                   lstASSIGNED_USER_ID;
		protected bool                      bShowEditDialog = false;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Submit" )
				{
					// 01/19/2007 Paul.  Keep the edit dialog visible.
					bShowEditDialog = true;
				}
				// 09/26/2009 Paul.  Allow the dashlet to be removed. 
				else if ( e.CommandName == "Remove" )
				{
					if ( !Sql.IsEmptyString(sDetailView) )
					{
						SqlProcs.spDASHLETS_USERS_InitDisable(Security.USER_ID, sDetailView, m_sMODULE, this.AppRelativeVirtualPath.Substring(0, this.AppRelativeVirtualPath.Length-5));
						SplendidCache.ClearUserDashlets(sDetailView);
						Response.Redirect(Page.AppRelativeVirtualPath + Request.Url.Query);
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				//lblError.Text = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( !IsPostBack )
			{
				lstLEAD_SOURCE.DataSource = SplendidCache.List("lead_source_dom");
				lstLEAD_SOURCE.DataBind();
				lstLEAD_SOURCE.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
				// 05/29/2017 Paul.  We should be using AssignedUser() and not ActiveUsers(). 
				lstASSIGNED_USER_ID.DataSource = SplendidCache.AssignedUser();
				lstASSIGNED_USER_ID.DataBind();
				// 09/14/2005 Paul.  Default to today, and all leads. 
				foreach(ListItem item in lstLEAD_SOURCE.Items)
				{
					item.Selected = true;
				}
				foreach(ListItem item in lstASSIGNED_USER_ID.Items)
				{
					item.Selected = true;
				}
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
			ctlDashletHeader.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Opportunities";
		}
		#endregion
	}
}

