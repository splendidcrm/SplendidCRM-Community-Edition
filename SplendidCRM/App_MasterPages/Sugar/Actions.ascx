<%@ Control Language="c#" AutoEventWireup="false" Codebehind="Actions.ascx.cs" Inherits="SplendidCRM.Themes.Sugar.Shortcuts" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
	private void Page_Load(object sender, System.EventArgs e)
	{
		// 12/04/2010 Paul.  A customer reported an exception with sSubMenu being empty. Rebind just in case. 
		divShortcuts.DataBind();
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
</script>
<div id="divShortcuts" width="100%" class="lastView" visible='<%# SplendidCRM.Security.IsAuthenticated() && ((!Sql.IsEmptyString(sSubMenu) && SplendidCRM.Security.AdminUserAccess(sSubMenu, "access") >= 0) || !AdminShortcuts || Sql.IsEmptyString(sSubMenu)) %>' runat="server">
	<b><%= L10n.Term(".LBL_ACTIONS") %>:&nbsp;&nbsp;</b>
	<asp:Repeater id="ctlRepeater" DataSource='<%# SplendidCache.Shortcuts(Sql.ToString(Page.Items["ActiveTabMenu"])) %>' runat="server">
		<ItemTemplate>
			<%-- 09/26/2017 Paul.  Add Archive access right.  --%>
			<nobr Visible='<%# Sql.ToString(Eval("SHORTCUT_ACLTYPE")) != "archive" || Sql.ToBoolean(Application["Modules." + Sql.ToString(Eval("MODULE_NAME")) + ".ArchiveEnabled"]) %>' runat="server">
				<asp:HyperLink NavigateUrl='<%# Eval("RELATIVE_PATH") %>' 
					ToolTip='<%# L10n.Term(Sql.ToString(Eval("DISPLAY_NAME"))) %>' CssClass="lastViewLink" Runat="server">
					<img src="<%# Sql.ToString(Session["themeURL"]) + "images/" + Sql.ToString(Eval("IMAGE_NAME")) %>" border="0" width="16" height="16" align="absmiddle">
					&nbsp;<%# L10n.Term(Sql.ToString(Eval("DISPLAY_NAME"))) %></asp:HyperLink>&nbsp;
			</nobr>
		</ItemTemplate>
	</asp:Repeater>
</div>

