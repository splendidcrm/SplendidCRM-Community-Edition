<%@ Control CodeBehind="PopupView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.$modulename$.PopupView" %>
<div id="divPopupView">
	<%@ Register TagPrefix="SplendidCRM" Tagname="SearchView" Src="~/_controls/SearchView.ascx" %>
	<SplendidCRM:SearchView ID="ctlSearchView" Module="$modulename$" IsPopupSearch="true" ShowSearchTabs="false" Visible="<%# !PrintView %>" Runat="Server" />

	<script type="text/javascript">
	function Select$modulenamesingular$(sPARENT_ID, sPARENT_NAME)
	{
		if ( window.opener != null && window.opener.Change$modulenamesingular$ != null )
		{
			window.opener.Change$modulenamesingular$(sPARENT_ID, sPARENT_NAME);
			window.close();
		}
		else
		{
			alert('Original window has closed.  $modulenamesingular$ cannot be assigned.' + '\n' + sPARENT_ID + '\n' + sPARENT_NAME);
		}
	}
	function SelectChecked()
	{
		if ( window.opener != null && window.opener.Change$modulenamesingular$ != null )
		{
			var sSelectedItems = document.getElementById('<%= ctlCheckAll.SelectedItems.ClientID %>').value;
			window.opener.Change$modulenamesingular$(sSelectedItems, '');
			window.close();
		}
		else
		{
			alert('Original window has closed.  $modulenamesingular$ cannot be assigned.');
		}
	}
	function Clear()
	{
		if ( window.opener != null && window.opener.Change$modulenamesingular$ != null )
		{
			window.opener.Change$modulenamesingular$('', '');
			window.close();
		}
		else
		{
			alert('Original window has closed.  $modulenamesingular$ cannot be assigned.');
		}
	}
	function Cancel()
	{
		window.close();
	}
	</script>
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="$modulename$.LBL_LIST_FORM_TITLE" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlDynamicButtons" Runat="Server" />

	<asp:UpdatePanel UpdateMode="Conditional" Visible='<%# !Sql.ToBoolean(Application["CONFIG.disable_popupview_inline"]) %>' runat="server">
		<ContentTemplate>
			<asp:Button ID="btnCreateInline" CommandName="NewRecord.Show" OnCommand="Page_Command" Text='<%# L10n.Term(m_sMODULE + ".LNK_NEW_$tablenamesingular$") %>' CssClass="button" style="margin-bottom: 4px;" Visible="<%# !this.IsMobile %>" runat="server" />
			<asp:Panel ID="pnlNewRecordInline" Style="display:none" runat="server">
				<%@ Register TagPrefix="SplendidCRM" Tagname="NewRecord" Src="NewRecord.ascx" %>
				<SplendidCRM:NewRecord ID="ctlNewRecord" Width="100%" EditView="PopupView.Inline" ShowCancel="true" Runat="Server" />
			</asp:Panel>
		</ContentTemplate>
	</asp:UpdatePanel>

	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdPopupView" EnableViewState="true" runat="server">
		<Columns>
			<asp:TemplateColumn HeaderText="" ItemStyle-Width="2%">
				<ItemTemplate><%# grdMain.InputCheckbox(!PrintView && bMultiSelect, ctlCheckAll.FieldName, Sql.ToGuid(Eval("ID")), ctlCheckAll.SelectedItems) %></ItemTemplate>
			</asp:TemplateColumn>
		</Columns>
	</SplendidCRM:SplendidGrid>
	<%@ Register TagPrefix="SplendidCRM" Tagname="CheckAll" Src="~/_controls/CheckAll.ascx" %>
	<SplendidCRM:CheckAll ID="ctlCheckAll" Visible="<%# !PrintView && bMultiSelect %>" Runat="Server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="DumpSQL" Src="~/_controls/DumpSQL.ascx" %>
	<SplendidCRM:DumpSQL ID="ctlDumpSQL" Visible="<%# !PrintView %>" Runat="Server" />
</div>
