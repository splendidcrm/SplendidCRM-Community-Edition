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
using System.IO;
using System.Data;
using System.Data.Common;
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Xml;
using System.Diagnostics;
using System.Globalization;

namespace SplendidCRM.Administration.EmailMan
{
	/// <summary>
	///		Summary description for EditView.
	/// </summary>
	public class EditView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		// 01/13/2010 Paul.  Add footer buttons. 
		protected _controls.DynamicButtons ctlFooterButtons ;

		protected TextBox     EMAILS_PER_RUN       ;
		protected RadioButton SITE_LOCATION_DEFAULT;
		protected RadioButton SITE_LOCATION_CUSTOM ;
		protected TextBox     SITE_LOCATION        ;

		protected RequiredFieldValidator reqEMAILS_PER_RUN;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Save" )
			{
				reqEMAILS_PER_RUN.Enabled = true;
				reqEMAILS_PER_RUN.Validate();
				if ( Page.IsValid )
				{
					try
					{
						int nEMAILS_PER_RUN = Sql.ToInteger(EMAILS_PER_RUN.Text);
						Application["CONFIG.massemailer_campaign_emails_per_run"        ] = (nEMAILS_PER_RUN > 0)        ? nEMAILS_PER_RUN.ToString() : String.Empty;
						Application["CONFIG.massemailer_tracking_entities_location_type"] = SITE_LOCATION_CUSTOM.Checked ? "2"                        : String.Empty;
						Application["CONFIG.massemailer_tracking_entities_location"     ] = SITE_LOCATION_CUSTOM.Checked ? SITE_LOCATION.Text         : String.Empty;
						SqlProcs.spCONFIG_Update("mail", "massemailer_campaign_emails_per_run"        , Sql.ToString(Application["CONFIG.massemailer_campaign_emails_per_run"        ]));
						SqlProcs.spCONFIG_Update("mail", "massemailer_tracking_entities_location_type", Sql.ToString(Application["CONFIG.massemailer_tracking_entities_location_type"]));
						SqlProcs.spCONFIG_Update("mail", "massemailer_tracking_entities_location"     , Sql.ToString(Application["CONFIG.massemailer_tracking_entities_location"     ]));
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						ctlDynamicButtons.ErrorText = ex.Message;
						return;
					}
					Response.Redirect("../default.aspx");
				}
			}
			else if ( e.CommandName == "Cancel" )
			{
				Response.Redirect("../default.aspx");
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term("EmailMan.LBL_CAMPAIGN_EMAIL_SETTINGS"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			try
			{
				// 10/18/2010 Paul.  The required fields need to be bound manually. 
				reqEMAILS_PER_RUN.DataBind();
				if ( !IsPostBack )
				{
					// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
					ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
					ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);

					EMAILS_PER_RUN.Text = Sql.ToString(Application["CONFIG.massemailer_campaign_emails_per_run"]);
					if ( Sql.ToString(Application["CONFIG.massemailer_tracking_entities_location_type"]) == "2" )
					{
						SITE_LOCATION_DEFAULT.Checked = false;
						SITE_LOCATION_CUSTOM .Checked = true ;
						SITE_LOCATION.Text = Sql.ToString(Application["CONFIG.massemailer_tracking_entities_location"]);
					}
					else
					{
						SITE_LOCATION_DEFAULT.Checked = true ;
						SITE_LOCATION_CUSTOM .Checked = false;
					}
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
			// 05/20/2007 Paul.  The m_sMODULE field must be set in order to allow default export handling. 
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			ctlFooterButtons .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "EmailMan";
			// 05/06/2010 Paul.  The menu will show the admin Module Name in the Six theme. 
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
			}
		}
		#endregion
	}
}

