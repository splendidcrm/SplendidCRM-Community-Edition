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
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

namespace SplendidCRM.Themes.Sugar
{
	/// <summary>
	///		Summary description for GroupMenu.
	/// </summary>
	public class GroupMenu : SplendidControl
	{
		protected string sActiveGroup = String.Empty;

		private void Page_Load(object sender, System.EventArgs e)
		{
			string sApplicationPath = Request.ApplicationPath;
			if ( !sApplicationPath.EndsWith("/") )
				sApplicationPath += "/";
			DataTable dtMenu = SplendidCache.ModuleGroupsByUser();
			// 04/28/2006 Paul.  Hide the tab menu if there is no menu to display. 
			// This should only occur during login. 
			// 02/25/2010 Paul.  This control is not visible if group tabs is not enabled. 
			// 02/26/2010 Paul.  The SubPanel Tabs flag has been moved to the Session so that it would be per-user. 
			bool bGroupTabs = Sql.ToBoolean(Session["USER_SETTINGS/GROUP_TABS"]);
			if ( dtMenu.Rows.Count == 0 || !bGroupTabs )
			{
				this.Visible = false;
				Session["SplendidGroupMenuHtml"] = null;
				return;
			}

			bool      bActiveParentFound = false;
			string    sActiveTab     = Sql.ToString(Page.Items["ActiveTabMenu"]);
			string    sThemeURL      = Sql.ToString(Session["themeURL"]);
			
			DataTable dtTabGroups    = SplendidCache.TabGroups();
			DataView  vwModuleGroups = new DataView(dtMenu);
#if DEBUG
			// 02/26/2010 Paul.  Don't cache the HTML when in debug mode. 
			Session["SplendidGroupMenuHtml"] = null;
#endif
			if ( Session["SplendidGroupMenuHtml"] == null )
			{
				StringBuilder sb = new StringBuilder();
				sb.AppendLine("						<div id='divTabMenu'>");
				sb.AppendLine("							<table class='tabFrame' cellspacing='0' cellpadding='0'>");
				sb.AppendLine("								<tr>");
				sb.AppendLine("									<td style='padding-left:14px;' class='otherTabRight'>&nbsp;</td>");
				foreach ( DataRow rowTabs in dtTabGroups.Rows )
				{
					string sGROUP_NAME = Sql.ToString (rowTabs["NAME"      ]);
					string sTITLE      = Sql.ToString (rowTabs["TITLE"     ]);
					bool   bGROUP_MENU = Sql.ToBoolean(rowTabs["GROUP_MENU"]);
					if ( !bGROUP_MENU )
						continue;
					
					// 02/24/2010 Paul. Make this parent tab active if any module it contains is active. 
					vwModuleGroups.RowFilter = "GROUP_NAME = '" + sGROUP_NAME + "' and MODULE_NAME = '" + sActiveTab + "'";
					string sTAB_CLASS = String.Empty;
					// 02/24/2010 Paul.  A module can appear in multiple groups, so just highlight the first one found. 
					if ( vwModuleGroups.Count > 0 && !bActiveParentFound )
					{
						sActiveGroup = sGROUP_NAME;
					//	sTAB_CLASS = "currentTab";
						bActiveParentFound = true;
					}
					//else
					{
						sTAB_CLASS = "otherTab";
					}
					// 02/24/2010 Paul.  Search the Module Groups to see if the user has access to any modules in this group.
					// If the use does not have access, then the group tab will not be displayed. 
					vwModuleGroups.RowFilter = "GROUP_NAME = '" + sGROUP_NAME + "'";
					foreach ( DataRowView rowSubTab in vwModuleGroups )
					{
						string sMODULE_NAME = Sql.ToString(rowSubTab["MODULE_NAME"]);
						// 02/27/2010  Paul.  The Module Groups view should filter on the User / Module access rights, so we don't need to check here. 
						//if ( Security.GetUserAccess(sMODULE_NAME, "list") >= 0 )
						{
							string sTAB_NAME      = sGROUP_NAME;
							string sDISPLAY_NAME  = L10n.Term(sTITLE);
							string sRELATIVE_PATH = Sql.ToString(Application["Modules." + sMODULE_NAME + ".RelativePath" ]);
							//if ( sTAB_CLASS == "currentTab" )
							//{
							//	sb.AppendLine("					<script type='text/javascript'>sSplendidMenuActiveGroupName = '" + sTAB_NAME + "';</script>");
							//}
							sb.AppendLine("							<td valign='bottom'>");
							sb.AppendLine("								<table class='tabFrame' cellspacing='0' cellpadding='0' height='25'>");
							sb.AppendLine("									<tr>");
							sb.AppendLine("										<td id='GroupMenu" + sTAB_NAME + "Left'   class='" + sTAB_CLASS + "Left'    onmouseover='GroupMenuActivateTab(\"" + sTAB_NAME + "\");'><img src='" + sThemeURL + "images/blank.gif" + "' border='0' width='5' height='25' /></td>");
							sb.AppendLine("										<td id='GroupMenu" + sTAB_NAME + "Middle' class='" + sTAB_CLASS + "' nowrap onmouseover='GroupMenuActivateTab(\"" + sTAB_NAME + "\");'><a class='" + sTAB_CLASS + "Link'  href='" + sRELATIVE_PATH.Replace("~/", sApplicationPath) + "'>" + sDISPLAY_NAME + "</a></td>");
							sb.AppendLine("										<td id='GroupMenu" + sTAB_NAME + "Right'  class='" + sTAB_CLASS + "Right'   onmouseover='GroupMenuActivateTab(\"" + sTAB_NAME + "\");'><img src='" + sThemeURL + "images/blank.gif" + "' border='0' width='5' height='25' /></td>");
							sb.AppendLine("									</tr>");
							sb.AppendLine("								</table>");
							sb.AppendLine("							</td>");
							// 02/24/2010 Paul.  Once we find the first module that the user has access to, we can exit the module loop. 
							break;
						}
					}
				}

				sb.AppendLine("									<td width='100%' class='tabRow'><img src='" + sThemeURL + "images/blank.gif" + "' border='0' width='1' height='1' /></td>");
				sb.AppendLine("								</tr>");
				sb.AppendLine("							</table>");

				// 02/26/2010 Paul.  Firefox and Opera are not honoring the tabFrame request to have 100% width, so subtabs background is not being applied. 
				sb.AppendLine("							<div id='subtabs' style='border-bottom: none;'>");
				sb.AppendLine("								<table id='SubMenu' class='tabFrame' cellspacing='0' cellpadding='0' height='20'>");
				sb.AppendLine("									<tr>");
				sb.AppendLine("										<td id='subtabs'><img src='" + sThemeURL + "images/blank.gif" + "' border='0' width='1' height='1' /></td>");
				sb.AppendLine("									</tr>");
				sb.AppendLine("								</table>");

				foreach ( DataRow rowTabs in dtTabGroups.Rows )
				{
					string sGROUP_NAME = Sql.ToString (rowTabs["NAME"      ]);
					bool   bGROUP_MENU = Sql.ToBoolean(rowTabs["GROUP_MENU"]);
					if ( !bGROUP_MENU )
						continue;
					
					bool bShowSubMenu = (sGROUP_NAME == sActiveGroup);
					bShowSubMenu = false;
					sb.AppendLine("								<table id='SubMenu" + sGROUP_NAME + "' class='tabFrame' cellspacing='0' cellpadding='0' height='20' style='display: " + (bShowSubMenu ? "inline" : "none") + "'>");
					sb.AppendLine("									<tr>");
					sb.AppendLine("										<td id='subtabs'>");
					
					vwModuleGroups.RowFilter = "GROUP_NAME = '" + sGROUP_NAME + "'";
					foreach ( DataRowView rowSubTab in vwModuleGroups )
					{
						string sMODULE_NAME   = Sql.ToString(rowSubTab["MODULE_NAME"]);
						string sDISPLAY_NAME  = L10n.Term(Sql.ToString(rowSubTab["DISPLAY_NAME"]));
						string sRELATIVE_PATH = Sql.ToString(rowSubTab["RELATIVE_PATH"]);
						sb.AppendLine("					<a href='" + sRELATIVE_PATH.Replace("~/", sApplicationPath) + "' class='lastViewLink'>" + sDISPLAY_NAME + "</a>");
					}
					sb.AppendLine("										</td>");
					sb.AppendLine("									</tr>");
					sb.AppendLine("								</table>");
				}
				sb.AppendLine("							</div>");
				sb.AppendLine("						</div>");
				Session["SplendidGroupMenuHtml"] = sb.ToString();
			}
			else
			{
				// 02/25/2010 Paul.  Even if we have the HTML, we still need to determine the active group. 
				foreach ( DataRow rowTabs in dtTabGroups.Rows )
				{
					string sGROUP_NAME = Sql.ToString (rowTabs["NAME"      ]);
					bool   bGROUP_MENU = Sql.ToBoolean(rowTabs["GROUP_MENU"]);
					if ( !bGROUP_MENU )
						continue;
					
					vwModuleGroups.RowFilter = "GROUP_NAME = '" + sGROUP_NAME + "' and MODULE_NAME = '" + sActiveTab + "'";
					string sTAB_CLASS = String.Empty;
					if ( vwModuleGroups.Count > 0 && !bActiveParentFound )
					{
						sActiveGroup = sGROUP_NAME;
						break;
					}
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

