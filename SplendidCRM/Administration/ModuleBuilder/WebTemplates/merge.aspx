<%@ Page language="c#" MasterPageFile="~/DefaultView.Master" AutoEventWireup="false" Inherits="SplendidCRM.SplendidPage" %>
<asp:Content ID="cntSidebar" ContentPlaceHolderID="cntSidebar" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="Shortcuts" Src="~/_controls/Shortcuts.ascx" %>
	<SplendidCRM:Shortcuts ID="ctlShortcuts" SubMenu="$modulename$" Runat="Server" />
</asp:Content>

<asp:Content ID="cntBody" ContentPlaceHolderID="cntBody" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="MergeView" Src="~/Import/MergeView.ascx" %>
	<SplendidCRM:MergeView ID="ctlMergeView" Module="$modulename$" Visible='<%# SplendidCRM.Security.GetUserAccess("$modulename$", "edit") >= 0 %>' Runat="Server" />
	<asp:Label ID="lblAccessError" ForeColor="Red" EnableViewState="false" Text='<%# L10n.Term("ACL.LBL_NO_ACCESS") %>' Visible="<%# !ctlMergeView.Visible %>" Runat="server" />
</asp:Content>
