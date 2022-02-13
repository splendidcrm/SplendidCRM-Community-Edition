<%@ Page language="c#" MasterPageFile="~/DefaultView.Master" Codebehind="import.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.SplendidPage" %>
<asp:Content ID="cntSidebar" ContentPlaceHolderID="cntSidebar" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="Shortcuts" Src="~/_controls/Shortcuts.ascx" %>
	<SplendidCRM:Shortcuts ID="ctlShortcuts" SubMenu="$modulename$" Runat="Server" />
</asp:Content>

<asp:Content ID="cntBody" ContentPlaceHolderID="cntBody" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="ImportView" Src="~/Import/ImportView.ascx" %>
	<SplendidCRM:ImportView ID="ctlImportView" Module="$modulename$" Visible='<%# SplendidCRM.Security.GetUserAccess("$modulename$", "import") >= 0 %>' Runat="Server" />
	<asp:Label ID="lblAccessError" ForeColor="Red" EnableViewState="false" Text='<%# L10n.Term("ACL.LBL_NO_ACCESS") %>' Visible="<%# !ctlImportView.Visible %>" Runat="server" />
</asp:Content>

