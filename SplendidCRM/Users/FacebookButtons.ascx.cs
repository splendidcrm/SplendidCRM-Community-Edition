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
using System.Diagnostics;

namespace SplendidCRM.Users
{
	/// <summary>
	///		Summary description for FacebookButtons.
	/// </summary>
	// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
	public class FacebookButtons : SplendidControl
	{
		protected string sFACEBOOK_ID = String.Empty;

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 09/09/2015 Paul.  Allow this user control to be placed inside an UpdatePanel. 
			if ( this.Parent.FindControl("FACEBOOK_ID") != null )
			{
				sFACEBOOK_ID = this.Parent.FindControl("FACEBOOK_ID").ClientID;
			}
			if ( !IsPostBack )
			{
				// 09/04/2013 Paul.  ASP.NET 4.5 is enforcing a rule that the root be an HtmlElement and not an HtmlGenericControl. 
				HtmlContainerControl htmlRoot = this.Page.Master.FindControl("htmlRoot") as HtmlContainerControl;
				if ( htmlRoot != null )
				{
					htmlRoot.Attributes.Add("xmlns", "http://www.w3.org/1999/xhtml");
					htmlRoot.Attributes.Add("xmlns:fb", "http://www.facebook.com/2008/fbml");
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
		}
		#endregion
	}
}

