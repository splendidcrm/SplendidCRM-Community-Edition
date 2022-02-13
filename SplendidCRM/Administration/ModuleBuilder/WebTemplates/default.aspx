<%@ Page language="c#" MasterPageFile="~/ListView.Master" AutoEventWireup="false" Inherits="SplendidCRM.SplendidPage" %>
<asp:Content ID="cntSidebar" ContentPlaceHolderID="cntSidebar" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="Shortcuts" Src="~/_controls/Shortcuts.ascx" %>
	<SplendidCRM:Shortcuts ID="ctlShortcuts" SubMenu="$modulename$" Runat="Server" />
</asp:Content>

<asp:Content ID="cntBody" ContentPlaceHolderID="cntBody" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListView" Src="ListView.ascx" %>
	<SplendidCRM:ListView ID="ctlListView" Visible='<%# SplendidCRM.Security.GetUserAccess("$modulename$", "list") >= 0 %>' Runat="Server" />
	<asp:Label ID="lblAccessError" ForeColor="Red" EnableViewState="false" Text='<%# L10n.Term("ACL.LBL_NO_ACCESS") %>' Visible="<%# !ctlListView.Visible %>" Runat="server" />
</asp:Content>
