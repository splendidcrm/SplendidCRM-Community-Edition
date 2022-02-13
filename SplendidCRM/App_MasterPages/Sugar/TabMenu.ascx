<%@ Control Language="c#" AutoEventWireup="false" Codebehind="TabMenu.ascx.cs" Inherits="SplendidCRM.Themes.Sugar.TabMenu" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
<%@ Import Namespace="System.Data" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<script runat="server">
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
</script>
						<div id="divTabMenu">
							<table class="tabFrame" cellspacing="0" cellpadding="0">
								<tr>
									<td style="padding-left:14px;" class="otherTabRight">&nbsp;</td>
<%
string sActiveTab = Sql.ToString(Page.Items["ActiveTabMenu"]);
int nRow = 0;
int nDisplayedTabs = 0;
int nMaxTabs = Sql.ToInteger(Session["max_tabs"]);
// 09/24/2007 Paul.  Max tabs is a config variable and needs the CONFIG in front of the name. 
if ( nMaxTabs == 0 )
	nMaxTabs = Sql.ToInteger(Application["CONFIG.default_max_tabs"]);
if ( nMaxTabs == 0 )
	nMaxTabs = 12;
for ( ; nRow < dtMenu.Rows.Count; nRow++ )
{
	DataRow row = dtMenu.Rows[nRow];
	string sMODULE_NAME   = Sql.ToString(row["MODULE_NAME"  ]);
	string sRELATIVE_PATH = Sql.ToString(row["RELATIVE_PATH"]);
	string sDISPLAY_NAME  = L10n.Term(Sql.ToString(row["DISPLAY_NAME"]));
	string sTAB_CLASS     = (sMODULE_NAME == sActiveTab) ? "currentTab" : "otherTab";
	// 12/05/2006 Paul.  The TabMenu view does not filter the Calendar or activities tabs as they are virtual. 
	if ( SplendidCRM.Security.GetUserAccess(sMODULE_NAME, "access") >= 0 )
	{
		if ( nDisplayedTabs < nMaxTabs || hovMore == null )
		{
			nDisplayedTabs++;
				%>
									<td valign="bottom">
										<table class="tabFrame" cellspacing="0" cellpadding="0" height="25">
											<tr>
												<td class="<%= sTAB_CLASS %>Left"><asp:Image SkinID="blank" Width="5" Height="25" runat="server" /></td>
												<td class="<%= sTAB_CLASS %>" nowrap><a class="<%= sTAB_CLASS %>Link"  href="<%= sRELATIVE_PATH.Replace("~/", sApplicationPath) %>"><%= sDISPLAY_NAME %></a></td>
												<td class="<%= sTAB_CLASS %>Right"><asp:Image SkinID="blank" Width="5" Height="25" runat="server" /></td>
											</tr>
										</table>
									</td>
				<%
		}
		else
		{
			HyperLink lnk = new HyperLink();
			lnk.Text        = sDISPLAY_NAME;
			lnk.NavigateUrl = sRELATIVE_PATH.Replace("~/", sApplicationPath);
			lnk.CssClass    = "menuItem";
			pnlTabMenuMore.Controls.Add(lnk);
		}
	}
}
// 01/05/2017 Paul.  Adding Feeds to the tab menu is a configuration option. 
if ( Sql.ToBoolean(Application["CONFIG.add_feeds_to_menu"]) )
{
	DataTable dtFeeds = SplendidCache.TabFeeds();
	foreach ( DataRow row in dtFeeds.Rows )
	{
		string sTITLE = Sql.ToString(row["TITLE"]);
		string sURL   = Sql.ToString(row["URL"  ]);
		HyperLink lnk = new HyperLink();
		lnk.Text        = sTITLE;
		lnk.NavigateUrl = sURL;
		lnk.CssClass    = "menuItem";
		lnk.Target      = "_blank";
		pnlTabMenuMore.Controls.Add(lnk);
	}
}
%>
									<td valign="bottom" style="DISPLAY: <%= (pnlTabMenuMore.Controls.Count > 0) ? "inline" : "none" %>">
										<table class="tabFrame" cellspacing="0" cellpadding="0">
											<tr>
												<td class="otherTabLeft"><asp:Image SkinID="blank" Width="5" Height="25" runat="server" /></td>
												<td class="otherTab"><asp:Image ID="imgTabMenuMore" SkinID="more" runat="server" /></td>
												<td class="otherTabRight"><asp:Image SkinID="blank" Width="5" Height="25" runat="server" /></td>
											</tr>
										</table>
									</td>

									<td width="100%" class="tabRow"><asp:Image SkinID="blank" Width="1" Height="1" runat="server" /></td>
								</tr>
							</table>
							<table class="tabFrame" cellspacing="0" cellpadding="0" height="20">
								<tr>
									<td id="subtabs"><asp:Image SkinID="blank" Width="1" Height="1" runat="server" /></td>
								</tr>
							</table>
						</div>
<asp:PlaceHolder ID="phHover" runat="server" />
<asp:Panel ID="pnlTabMenuMore" CssClass="menu" runat="server" />

