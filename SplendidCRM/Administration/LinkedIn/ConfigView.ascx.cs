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

namespace SplendidCRM.Administration.LinkedIn
{
	/// <summary>
	///		Summary description for ConfigView.
	/// </summary>
	public class ConfigView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		protected _controls.DynamicButtons ctlFooterButtons ;

		protected TextBox      LINKEDIN_API_KEY   ;
		protected TextBox      LINKEDIN_SECRET_KEY;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Save" )
			{
				try
				{
					if ( Page.IsValid )
					{
						// 06/06/2011 Paul.  Remove trailing space from key. 
						Application["CONFIG.LinkedIn.APIKey"   ] = LINKEDIN_API_KEY   .Text;
						Application["CONFIG.LinkedIn.SecretKey"] = LINKEDIN_SECRET_KEY.Text;
						
						SqlProcs.spCONFIG_Update("system", "LinkedIn.APIKey"   , Sql.ToString(Application["CONFIG.LinkedIn.APIKey"   ]));
						SqlProcs.spCONFIG_Update("system", "LinkedIn.SecretKey", Sql.ToString(Application["CONFIG.LinkedIn.SecretKey"]));
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
			SetPageTitle(L10n.Term("LinkedIn.LBL_MANAGE_LINKEDIN_TITLE"));
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
					ctlDynamicButtons.AppendButtons(m_sMODULE + ".EditView", Guid.Empty, null);
					ctlFooterButtons .AppendButtons(m_sMODULE + ".EditView", Guid.Empty, null);

					LINKEDIN_API_KEY   .Text = Sql.ToString (Application["CONFIG.LinkedIn.APIKey"   ]);
					LINKEDIN_SECRET_KEY.Text = Sql.ToString (Application["CONFIG.LinkedIn.SecretKey"]);
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
			m_sMODULE = "LinkedIn";
			// 07/24/2010 Paul.  We need an admin flag for the areas that don't have a record in the Modules table. 
			SetAdminMenu(m_sMODULE);
			if ( IsPostBack )
			{
				ctlDynamicButtons.AppendButtons(m_sMODULE + ".EditView", Guid.Empty, null);
				ctlFooterButtons .AppendButtons(m_sMODULE + ".EditView", Guid.Empty, null);
			}
		}
		#endregion
	}
}
