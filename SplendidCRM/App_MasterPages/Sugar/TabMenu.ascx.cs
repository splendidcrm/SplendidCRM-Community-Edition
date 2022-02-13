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
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

namespace SplendidCRM.Themes.Sugar
{
	/// <summary>
	///		Summary description for TabMenu.
	/// </summary>
	public class TabMenu : SplendidControl
	{
		// 10/20/2010 Paul.  Restore sActiveTab in order to avoid the old Version 2.1 Sugar2006 them from crashing. 
		protected string sActiveTab      ;
		protected string sApplicationPath;
		protected DataTable   dtMenu;
		protected PlaceHolder phHover;
		protected AjaxControlToolkit.HoverMenuExtender hovMore;

		private void Page_Load(object sender, System.EventArgs e)
		{
			sApplicationPath = Request.ApplicationPath;
			if ( !sApplicationPath.EndsWith("/") )
				sApplicationPath += "/";
			// 09/12/2010 Paul.  Need to use the Portal menu. 
			// 10/20/2015 Paul.  Share code with Portal. 
			dtMenu = PortalCache.IsPortal() ? PortalCache.TabMenu() : SplendidCache.TabMenu();
			// 04/28/2006 Paul.  Hide the tab menu if there is no menu to display. 
			// This should only occur during login. 
			// 02/25/2010 Paul.  This control is not visible if group tabs is enabled. 
			// 02/26/2010 Paul.  The SubPanel Tabs flag has been moved to the Session so that it would be per-user. 
			bool bGroupTabs = Sql.ToBoolean(Session["USER_SETTINGS/GROUP_TABS"]);
			if ( dtMenu.Rows.Count == 0 || bGroupTabs )
				this.Visible = false;
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
			
			ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
			// 11/23/2009 Paul.  SplendidCRM 4.0 is very slow on Blackberry devices.  Lets try and turn off AJAX AutoComplete. 
			bool bAjaxAutoComplete = (mgrAjax != null);
			if ( this.IsMobile )
			{
				// 11/24/2010 Paul.  .NET 4 has broken the compatibility of the browser file system. 
				// We are going to minimize our reliance on browser files in order to reduce deployment issues. 
				bAjaxAutoComplete = Utils.AllowAutoComplete && (mgrAjax != null);
			}
			if ( bAjaxAutoComplete && mgrAjax != null )
			{
				// 10/20/2010 Paul.  phHover will not exist on the old Sugar2006 theme. 
				if ( phHover != null )
				{
					// <ajaxToolkit:HoverMenuExtender TargetControlID="imgTabMenuMore" PopupControlID="pnlTabMenuMore" PopupPosition="Bottom" PopDelay="50" OffsetX="-12" OffsetY="-3" runat="server" />
					hovMore = new AjaxControlToolkit.HoverMenuExtender();
					hovMore.TargetControlID = "imgTabMenuMore";
					hovMore.PopupControlID  = "pnlTabMenuMore";
					hovMore.PopupPosition   = AjaxControlToolkit.HoverMenuPopupPosition.Bottom;
					hovMore.PopDelay        =  50;
					hovMore.OffsetX         = -12;
					hovMore.OffsetY         =  -3;
					phHover.Controls.Add(hovMore);
				}
			}
		}
		#endregion
	}
}

