<%@ Control Language="c#" AutoEventWireup="false" Codebehind="EditView.ascx.cs" Inherits="SplendidCRM.EmailTemplates.EditView" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<div id="divEditView" runat="server">
<script type="text/javascript">
// 08/08/2006 Paul.  Fixed access to selected index.  The line was missing the closing square bracket.
function ShowVariable()
{
	document.getElementById('<%= txtVariableText.ClientID %>').value = '$' + document.getElementById('<%= lstVariableName.ClientID %>').options[document.getElementById('<%= lstVariableName.ClientID %>').selectedIndex].value;
}
function ShowTracker()
{
	document.getElementById('<%= txtTrackerText.ClientID %>').value = '{' + document.getElementById('<%= lstTrackerName.ClientID %>').options[document.getElementById('<%= lstTrackerName.ClientID %>').selectedIndex].value + '}';
}
function InsertVariable()
{
	try
	{
		var sVariable = document.getElementById('<%= txtVariableText.ClientID %>').value;
		
		// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
		var oEditor = CKEDITOR.instances['<%= txtBODY.ClientID %>'];
		// 10/27/2011 Paul.  Fix for CKEDITOR. 
		if ( oEditor != null && oEditor.mode == 'wysiwyg' )
		{
			oEditor.insertHtml(sVariable);
		}
		else
		{
			//var txtBODY = document.getElementsByClassName('cke_source cke_enable_context_menu')[0];
			var txtBODY = document.getElementById('cke_contents_<%= txtBODY.ClientID %>').childNodes[0];
			if ( txtBODY.selectionStart !== undefined )
			{
				var start = txtBODY.selectionStart;
				var end   = txtBODY.selectionEnd  ;
				txtBODY.value = txtBODY.value.substr(0, start) + sVariable + txtBODY.value.substr(end);
				
				var pos = start + sVariable.length;
				txtBODY.selectionStart = pos;
				txtBODY.selectionEnd   = pos;
			}
		}
	}
	catch(e)
	{
		alert(e.message);
	}
	return false;
}
function InsertTracker()
{
	try
	{
		var sURL = document.getElementById('<%= txtTrackerText.ClientID %>').value;
		var sTrackerURL = '<a href="' + sURL + '"><%= L10n.Term("EmailTemplates.LBL_DEFAULT_LINK_TEXT") %></a>';
		
		// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
		// http://docs.cksource.com/ckeditor_api/symbols/CKEDITOR.editor.html
		var oEditor = CKEDITOR.instances['<%= txtBODY.ClientID %>'];
		// 10/27/2011 Paul.  Fix for CKEDITOR. 
		if ( oEditor != null && oEditor.mode == 'wysiwyg' )
		{
			oEditor.insertHtml(sTrackerURL);
		}
		else
		{
			//var txtBODY = document.getElementsByClassName('cke_source cke_enable_context_menu')[0];
			var txtBODY = document.getElementById('cke_contents_<%= txtBODY.ClientID %>').childNodes[0];
			if ( txtBODY.selectionStart !== undefined )
			{
				var start = txtBODY.selectionStart;
				var end   = txtBODY.selectionEnd  ;
				txtBODY.value = txtBODY.value.substr(0, start) + sTrackerURL + txtBODY.value.substr(end);
				
				var pos = start + sTrackerURL.length;
				txtBODY.selectionStart = pos;
				txtBODY.selectionEnd   = pos;
			}
		}
	}
	catch(e)
	{
		alert(e.message);
	}
	return false;
}

// 08/02/2013 Paul.  Allow a survey to be added to an email template. 
function SurveyPopup()
{
	ModulePopup('Surveys', 'SelectSurvey', null, 'ClearDisabled=1', true, null);
	// 08/02/2013 Paul.  Override the default change behavior with our own. 
	ChangeSurvey = InsertSurvey;
	return;
}
function InsertSurvey(sPARENT_ID, sPARENT_NAME)
{
	try
	{
		var chkSURVEY_CONTACT = document.getElementById('<%= chkSURVEY_CONTACT.ClientID %>');
		var sURL = '<%= GetSurveySiteURL() %>run.aspx?ID=' + sPARENT_ID;
		if ( chkSURVEY_CONTACT.checked )
			sURL += '&PARENT_ID=$contact_id';
		var sSurveyURL = '<a href="' + sURL + '">' + sPARENT_NAME + '</a>';
		
		var oEditor = CKEDITOR.instances['<%= txtBODY.ClientID %>'];
		if ( oEditor != null && oEditor.mode == 'wysiwyg' )
		{
			oEditor.insertHtml(sSurveyURL);
		}
		else
		{
			var txtBODY = document.getElementById('cke_contents_<%= txtBODY.ClientID %>').childNodes[0];
			if ( txtBODY.selectionStart !== undefined )
			{
				var start = txtBODY.selectionStart;
				var end   = txtBODY.selectionEnd  ;
				txtBODY.value = txtBODY.value.substr(0, start) + sTrackerURL + txtBODY.value.substr(end);
				
				var pos = start + sTrackerURL.length;
				txtBODY.selectionStart = pos;
				txtBODY.selectionEnd   = pos;
			}
		}
	}
	catch(e)
	{
		alert(e.message);
	}
	return false;
}
</script>

	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="EmailTemplates" EnablePrint="false" HelpName="EditView" EnableHelp="true" Runat="Server" />

	<asp:HiddenField ID="hidREMOVE_LABEL"     Value='<%# L10n.Term(".LBL_REMOVE") %>' runat="server" />
	<asp:HiddenField ID="hidATTACHMENT_COUNT" Value="0" runat="server" />

	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<asp:Table SkinID="tabEditView" runat="server">
					<asp:TableRow>
						<asp:TableCell Width="15%" CssClass="dataLabel" VerticalAlign="Top"><%= L10n.Term("EmailTemplates.LBL_NAME") %> <asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /></asp:TableCell>
						<asp:TableCell Width="30%" CssClass="dataField" VerticalAlign="Top"><asp:TextBox ID="txtNAME" TabIndex="1" MaxLength="255" size="30" Runat="server" /></asp:TableCell>
						<asp:TableCell Width="15%" CssClass="dataLabel" VerticalAlign="Top"><%= L10n.Term("EmailTemplates.LBL_READ_ONLY") %> <asp:CheckBox ID="chkREAD_ONLY" TabIndex="1" CssClass="checkbox" Runat="server" /></asp:TableCell>
						<asp:TableCell Width="30%" CssClass="dataLabel" VerticalAlign="Top" RowSpan="3">
							<asp:Table Visible="<%# SplendidCRM.Crm.Config.enable_team_management() %>" runat="server">
								<asp:TableRow>
									<asp:TableCell VerticalAlign="Top" CssClass="dataLabel"><%= L10n.Term("Teams.LBL_TEAM") %></asp:TableCell>
									<asp:TableCell VerticalAlign="Top">
										<asp:Panel Visible="<%# SplendidCRM.Crm.Config.enable_team_management() && !SplendidCRM.Crm.Config.enable_dynamic_teams() %>" runat="server">
											<asp:TextBox     ID="TEAM_NAME"     ReadOnly="True" Runat="server" />
											<asp:HiddenField ID="TEAM_ID"       runat="server" />&nbsp;
											<asp:Button      ID="btnChangeTeam" UseSubmitBehavior="false" OnClientClick=<%# "return ModulePopup('Teams', '" + TEAM_ID.ClientID + "', '" + TEAM_NAME.ClientID + "', null, false, null);" %> Text='<%# L10n.Term(".LBL_CHANGE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_CHANGE_BUTTON_TITLE") %>' CssClass="button" runat="server" />
										</asp:Panel>
										<%@ Register TagPrefix="SplendidCRM" Tagname="TeamSelect" Src="~/_controls/TeamSelect.ascx" %>
										<SplendidCRM:TeamSelect ID="ctlTeamSelect" Visible="<%# SplendidCRM.Crm.Config.enable_team_management() && SplendidCRM.Crm.Config.enable_dynamic_teams() %>" Runat="Server" />
									</asp:TableCell>
								</asp:TableRow>
							</asp:Table>
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term(".LBL_ASSIGNED_TO") %></asp:TableCell>
						<asp:TableCell CssClass="dataField">
							<asp:Panel Visible="<%# !SplendidCRM.Crm.Config.enable_dynamic_assignment() %>" runat="server">
								<asp:TextBox ID="ASSIGNED_TO" ReadOnly="True" Runat="server" />
								<asp:HiddenField ID="ASSIGNED_USER_ID" runat="server" />&nbsp;
								<asp:Button      ID="btnChangeAssigned" UseSubmitBehavior="false" OnClientClick=<%# "return ModulePopup('Users', '" + ASSIGNED_USER_ID.ClientID + "', '" + ASSIGNED_TO.ClientID + "', null, false, null);" %> Text='<%# L10n.Term(".LBL_CHANGE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_CHANGE_BUTTON_TITLE") %>' CssClass="button" Runat="server" />
							</asp:Panel>
							<%@ Register TagPrefix="SplendidCRM" Tagname="UserSelect" Src="~/_controls/UserSelect.ascx" %>
							<SplendidCRM:UserSelect ID="ctlUserSelect" Visible="<%# SplendidCRM.Crm.Config.enable_dynamic_assignment() %>" Runat="Server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("EmailTemplates.LBL_DESCRIPTION") %></asp:TableCell>
						<asp:TableCell CssClass="dataField" ColumnSpan="2"><asp:TextBox ID="txtDESCRIPTION" TabIndex="1" TextMode="MultiLine" Columns="65" Rows="1" style="overflow-y:auto;" Runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell ColumnSpan="4">&nbsp;</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("EmailTemplates.LBL_INSERT_VARIABLE") %></asp:TableCell>
						<asp:TableCell CssClass="dataField" ColumnSpan="3">
							<asp:DropDownList ID="lstVariableModule" TabIndex="1" OnSelectedIndexChanged="lstVariableModule_Changed" AutoPostBack="true" Runat="server" />
							<asp:DropDownList ID="lstVariableName"   TabIndex="1" onchange="ShowVariable()" Runat="server" />
							<span class="dataLabel">:</span>
							<asp:TextBox ID="txtVariableText"   size="30" Runat="server" />
							<asp:Button  ID="btnVariableInsert" UseSubmitBehavior="false" OnClientClick="InsertVariable(); return false;" CssClass="button" Text='<%# L10n.Term("EmailTemplates.LBL_INSERT") %>' runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow Visible='<%# !Sql.IsEmptyGuid(Request["CAMPAIGN_ID"]) %>'>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("EmailTemplates.LBL_INSERT_TRACKER_URL") %></asp:TableCell>
						<asp:TableCell CssClass="dataField" ColumnSpan="3">
							<asp:DropDownList ID="lstTrackerName" TabIndex="1" onchange="ShowTracker()" Runat="server" />
							<span class="dataLabel">:</span>
							<asp:TextBox ID="txtTrackerText"   size="30" Runat="server" />
							<asp:Button  ID="btnTrackerInsert" UseSubmitBehavior="false" OnClientClick="InsertTracker(); return false;" CssClass="button" Text='<%# L10n.Term("EmailTemplates.LBL_INSERT_URL_REF") %>' runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow ID="trINSERT_SURVEY" Visible="false">
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("EmailTemplates.LBL_INSERT_SURVEY") %></asp:TableCell>
						<asp:TableCell CssClass="dataField" ColumnSpan="3">
							<asp:Button UseSubmitBehavior="false" OnClientClick="return SurveyPopup();" CssClass="button" Text='<%# L10n.Term("EmailTemplates.LBL_SELECT_SURVEY") %>' ToolTip='<%# L10n.Term("EmailTemplates.LBL_SELECT_SURVEY") %>' runat="server" />
							&nbsp;
							<asp:CheckBox ID="chkSURVEY_CONTACT" Text='<%# L10n.Term("EmailTemplates.LBL_INCLUDE_CONTACT") %>' CssClass="checkbox" runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("EmailTemplates.LBL_SUBJECT") %></asp:TableCell>
						<asp:TableCell CssClass="dataField" ColumnSpan="3"><asp:TextBox ID="txtSUBJECT" TabIndex="1" TextMode="MultiLine" Columns="90" Rows="1" style="overflow-y:auto;" Runat="server" /></asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("EmailTemplates.LBL_BODY") %></asp:TableCell>
						<asp:TableCell CssClass="dataField" ColumnSpan="3">
							<%@ Register TagPrefix="CKEditor" Namespace="CKEditor.NET" Assembly="CKEditor.NET" %>
							<CKEditor:CKEditorControl id="txtBODY" Toolbar="SplendidCRM" Language='<%# Session["USER_SETTINGS/CULTURE"] %>' BasePath="~/ckeditor/" FilebrowserUploadUrl="../ckeditor/upload.aspx" FilebrowserBrowseUrl="../Images/Popup.aspx" FilebrowserWindowWidth="640" FilebrowserWindowHeight="480" runat="server" />
						</asp:TableCell>
					</asp:TableRow>
					<asp:TableRow>
						<asp:TableCell CssClass="dataLabel"><%= L10n.Term("Emails.LBL_ATTACHMENTS") %></asp:TableCell>
						<asp:TableCell CssClass="dataField" ColumnSpan="3">
							<asp:Repeater id="ctlAttachments" runat="server">
								<HeaderTemplate />
								<ItemTemplate>
										<asp:HyperLink Text='<%# DataBinder.Eval(Container.DataItem, "FILENAME") %>' NavigateUrl='<%# "~/Notes/Attachment.aspx?ID=" + Eval("NOTE_ATTACHMENT_ID") %>' Target="_blank" Runat="server" />
										&nbsp;<asp:ImageButton OnCommand="Page_Command" CommandName="Attachments.Delete" CommandArgument='<%# Eval("NOTE_ATTACHMENT_ID") %>' ImageUrl='<%# Session["themeURL"] + "images/delete_inline.gif"  %>' ImageAlign="Middle" runat="server" /><br />
								</ItemTemplate>
								<FooterTemplate />
							</asp:Repeater>
							<div id="<%= this.ClientID %>_attachments_div"></div>
							<div style="display: none">
								<input id="dummy_email_attachment" type="file" tabindex="0" size="40" runat="server" />
							</div>
							<asp:Button UseSubmitBehavior="false" OnClientClick=<%# "AddFile(\'" + this.ClientID + "\', \'" + hidREMOVE_LABEL.ClientID + "\', \'" + hidATTACHMENT_COUNT.ClientID + "\'); return false;" %> Text='<%# L10n.Term("Emails.LBL_ADD_FILE") %>' CssClass="button" runat="server" />
						</asp:TableCell>
					</asp:TableRow>
				</asp:Table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>

	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlFooterButtons" Visible="<%# !SplendidDynamic.StackedLayout(this.Page.Theme) && !PrintView %>" ShowRequired="false" Runat="Server" />
</div>

