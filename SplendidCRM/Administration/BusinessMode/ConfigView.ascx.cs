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
using System.Data;
using System.Data.Common;
using System.Net;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Administration.BusinessMode
{
	/// <summary>
	///		Summary description for ConfigView.
	/// </summary>
	public class ConfigView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		protected _controls.DynamicButtons ctlFooterButtons ;

		protected RadioButton  radBUSINESS_MODE_B2B;
		protected RadioButton  radBUSINESS_MODE_B2C;
		// 08/07/2015 Paul.  Revenue Line Items. 
		protected RadioButton  radOPPORTUNITIES_MODE_OPPORTUNITIES;
		protected RadioButton  radOPPORTUNITIES_MODE_REVENUE      ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Save" )
			{
				try
				{
					if ( Page.IsValid )
					{
						string sBusinessMode = Sql.ToString(Application["CONFIG.BusinessMode"]);
						if ( radBUSINESS_MODE_B2C.Checked )
						{
							if ( sBusinessMode != "B2C" )
							{
								SqlProcs.spCONFIG_BusinessMode("B2C");
								Application["CONFIG.BusinessMode"] = "B2C";
								SplendidInit.InitApp(HttpContext.Current);
								SplendidInit.LoadUserPreferences(Security.USER_ID, Sql.ToString(Session["USER_SETTINGS/THEME"]), Sql.ToString(Session["USER_SETTINGS/CULTURE"]));
							}
						}
						else
						{
							if ( sBusinessMode != "B2B" && sBusinessMode != String.Empty )
							{
								SqlProcs.spCONFIG_BusinessMode("B2B");
								Application["CONFIG.BusinessMode"] = "B2B";
								SplendidInit.InitApp(HttpContext.Current);
								SplendidInit.LoadUserPreferences(Security.USER_ID, Sql.ToString(Session["USER_SETTINGS/THEME"]), Sql.ToString(Session["USER_SETTINGS/CULTURE"]));
							}
						}
						// 08/07/2015 Paul.  Revenue Line Items. 
						string sOpportunitiesMode = Sql.ToString(Application["CONFIG.OpportunitiesMode"]);
						if ( radOPPORTUNITIES_MODE_REVENUE.Checked )
						{
							if ( sOpportunitiesMode != "Revenue" )
							{
								sOpportunitiesMode = "Revenue";
								SqlProcs.spCONFIG_OpportunitiesMode(sOpportunitiesMode);
								Application["CONFIG.OpportunitiesMode"] = sOpportunitiesMode;
							}
						}
						else
						{
							if ( sOpportunitiesMode != "Opportunities" && sOpportunitiesMode != String.Empty )
							{
								sOpportunitiesMode = "Opportunities";
								SqlProcs.spCONFIG_OpportunitiesMode(sOpportunitiesMode);
								Application["CONFIG.OpportunitiesMode"] = sOpportunitiesMode;
							}
					}
						Response.Redirect("../default.aspx");
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					ctlDynamicButtons.ErrorText = ex.Message;
					return;
				}
			}
			else if ( e.CommandName == "Cancel" )
			{
				Response.Redirect("../default.aspx");
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term("Administration.LBL_BUSINESS_MODE_TITLE"));
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
			{
				Parent.DataBind();
				return;
			}

			try
			{
				if ( !IsPostBack )
				{
					ctlDynamicButtons.AppendButtons("BusinessMode.EditView", Guid.Empty, null);
					ctlFooterButtons .AppendButtons("BusinessMode.EditView", Guid.Empty, null);

					radBUSINESS_MODE_B2C.Checked = Sql.ToString(Application["CONFIG.BusinessMode"]) == "B2C";
					radBUSINESS_MODE_B2B.Checked = !radBUSINESS_MODE_B2C.Checked;
					// 08/07/2015 Paul.  Revenue Line Items. 
					radOPPORTUNITIES_MODE_OPPORTUNITIES.Checked = Crm.Config.OpportunitiesMode() != "Revenue";
					radOPPORTUNITIES_MODE_REVENUE      .Checked = Crm.Config.OpportunitiesMode() == "Revenue";
					radOPPORTUNITIES_MODE_REVENUE.Enabled = System.IO.File.Exists(Request.MapPath("~/RevenueLineItems/edit.aspx"));
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
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
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			ctlFooterButtons .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Administration";
			// 07/24/2010 Paul.  We need an admin flag for the areas that don't have a record in the Modules table. 
			SetAdminMenu(m_sMODULE);
			if ( IsPostBack )
			{
				ctlDynamicButtons.AppendButtons("BusinessMode.EditView", Guid.Empty, null);
				ctlFooterButtons .AppendButtons("BusinessMode.EditView", Guid.Empty, null);
			}
		}
		#endregion
	}
}
