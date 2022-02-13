<%@ Control Language="c#" AutoEventWireup="false" Codebehind="MassUpdate.ascx.cs" Inherits="SplendidCRM.$modulename$.MassUpdate" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<%@ Register TagPrefix="SplendidCRM" Tagname="MassUpdateButtons" Src="~/_controls/MassUpdateButtons.ascx" %>
<SplendidCRM:MassUpdateButtons ID="ctlDynamicButtons" SubPanel="div$modulename$MassUpdate" Title=".LBL_MASS_UPDATE_TITLE" Runat="Server" />

<div id="div$modulename$MassUpdate" style='<%= "display:" + (CookieValue("div$modulename$MassUpdate") != "1" ? "inline" : "none") %>'>
	<asp:Table Width="100%" CellPadding="0" CellSpacing="0" CssClass="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<%@ Register TagPrefix="SplendidCRM" Tagname="TeamAssignedMassUpdate" Src="~/_controls/TeamAssignedMassUpdate.ascx" %>
				<SplendidCRM:TeamAssignedMassUpdate ID="ctlTeamAssignedMassUpdate" Runat="Server" />
				<asp:Table Width="100%" CellPadding="0" CellSpacing="0" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="15%" CssClass="dataLabel"><asp:Label Text='<%# L10n.Term(".LBL_TAG_SET_NAME") %>' runat="server" /></asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField">
							<%@ Register TagPrefix="SplendidCRM" Tagname="TagMassUpdate" Src="~/_controls/TagMassUpdate.ascx" %>
							<SplendidCRM:TagMassUpdate ID="ctlTagMassUpdate" Runat="Server" />
						</asp:TableCell>
						<asp:TableCell Width="15%" CssClass="dataLabel"></asp:TableCell>
						<asp:TableCell Width="35%" CssClass="dataField"></asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>
