<%@ Control Language="c#" AutoEventWireup="false" Codebehind="DetailView.ascx.cs" Inherits="SplendidCRM.$modulename$.DetailView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<div id="divDetailView" runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" Module="$modulename$" EnablePrint="true" HelpName="DetailView" EnableHelp="true" EnableFavorites="true" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="DetailNavigation" Src="~/_controls/DetailNavigation.ascx" %>
	<SplendidCRM:DetailNavigation ID="ctlDetailNavigation" Module="$modulename$" Visible="<%# !PrintView %>" Runat="Server" />

	<asp:HiddenField ID="LAYOUT_DETAIL_VIEW" Runat="server" />
	<table ID="tblMain" class="tabDetailView" runat="server">
	</table>

	<div id="divDetailSubPanel">
		<asp:PlaceHolder ID="plcSubPanel" Runat="server" />
	</div>
</div>

<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
