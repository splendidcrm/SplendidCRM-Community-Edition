<%@ Page language="c#" MasterPageFile="~/ListView.Master" Codebehind="stream.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.$modulename$.StreamDefault" %>
<asp:Content ID="cntSidebar" ContentPlaceHolderID="cntSidebar" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="Shortcuts" Src="~/_controls/Shortcuts.ascx" %>
	<SplendidCRM:Shortcuts ID="ctlShortcuts" SubMenu="$modulename$" Runat="Server" />
</asp:Content>

<asp:Content ID="cntBody" ContentPlaceHolderID="cntBody" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="StreamView" Src="~/ActivityStream/StreamView.ascx" %>
	<SplendidCRM:StreamView ID="ctlStreamView" Module="$modulename$" Visible='<%# SplendidCRM.Security.GetUserAccess("$modulename$", "list") >= 0 %>' Runat="Server" />
	<asp:Label ID="lblAccessError" ForeColor="Red" EnableViewState="false" Text='<%# L10n.Term("ACL.LBL_NO_ACCESS") %>' Visible="<%# !ctlStreamView.Visible %>" Runat="server" />
</asp:Content>

