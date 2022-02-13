<%@ Control CodeBehind="StudioView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.StudioView" %>
<%@ Import Namespace="SplendidCRM.Crm" %>
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
<div id="divStudioView" visible='<%# 
(  SplendidCRM.Security.AdminUserAccess("DynamicLayout"    , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Dropdown"         , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("EditCustomFields" , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Modules"          , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("iFrames"          , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Terminology"      , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Shortcuts"        , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Languages"        , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("DynamicButtons"   , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("FieldValidators"  , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("ModuleBuilder"    , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Tags"             , "access") >= 0 
) %>' runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="Administration.LBL_STUDIO_TITLE" Runat="Server" />
	<asp:Label ID="lblError" CssClass="error" EnableViewState="false" Runat="server" />

	<%@ Register TagPrefix="SplendidCRM" Tagname="RestUtils" Src="~/_controls/RestUtils.ascx" %>
	<SplendidCRM:RestUtils Runat="Server" />

	<SplendidCRM:InlineScript runat="server">
		<script type="text/javascript">
function SplendidUI_ProgressBar(sActionsPanel)
{
	if ( !Sql.IsEmptyString(sActionsPanel) )
	{
		var divActionsPanel = document.getElementById(sActionsPanel);
		if ( divActionsPanel != null )
		{
			if ( divActionsPanel.childNodes != null )
			{
				while ( divActionsPanel.childNodes.length > 0 )
				{
					divActionsPanel.removeChild(divActionsPanel.firstChild);
				}
			}
			var divProgressBarFrame = document.createElement('div');
			divProgressBarFrame.id                    = 'divSplendidUI_ProgressBarFrame';
			divProgressBarFrame.style.margin          = '4px';
			divProgressBarFrame.style.padding         = '2px';
			divProgressBarFrame.style.border          = '1px solid #cccccc';
			//divProgressBarFrame.style.width           = '100%';
			divProgressBarFrame.style.backgroundColor = '#ffffff';
			divActionsPanel.appendChild(divProgressBarFrame);
			var divProgressStatusText = document.createElement('div');
			divProgressStatusText.id = 'divSplendidUI_ProgressStatusText';
			divProgressBarFrame.appendChild(divProgressStatusText);
			// 12/31/2014 Paul.  Firefox does not like innerText. Use createTextNode. 
			divProgressStatusText.innerHTML = '';
			var tblProgressBar = document.createElement('table');
			tblProgressBar.id                    = 'tblSplendidUI_ProgressBar';
			tblProgressBar.cellSpacing           = 0;
			tblProgressBar.style.width           = '100%';
			tblProgressBar.style.backgroundColor = '#000000';
			divProgressBarFrame.appendChild(tblProgressBar);
			var tbodyProgressBar = document.createElement('tbody');
			tbodyProgressBar.className = 'SplendidProgressBar';
			tblProgressBar.appendChild(tbodyProgressBar);
			var trProgressBar = document.createElement('tr');
			tbodyProgressBar.appendChild(trProgressBar);
			var tdProgressBar = document.createElement('td');
			tdProgressBar.align                = 'center';
			tdProgressBar.style.padding        = '2px';
			tdProgressBar.style.color          = '#ffffff';
			tdProgressBar.style.fontSize       = '12px';
			tdProgressBar.style.fontStyle      = 'normal';
			tdProgressBar.style.fontWeight     = 'normal';
			tdProgressBar.style.textDecoration = 'none';
			trProgressBar.appendChild(tdProgressBar);
			var divProgressBarText = document.createElement('div');
			divProgressBarText.id = 'divSplendidUI_ProgressBarText';
			tdProgressBar.appendChild(divProgressBarText);
			divProgressBarText.innerHTML = '0%';
		}
	}
}

function SplendidUI_UpdateProgressBar(nProgress, nTotal, sStatusText)
{
	if ( nTotal > 1 )
	{
		var nProgress = Math.round(100 * nProgress / nTotal);
		if ( nProgress >= 100 )
			nProgress = 99;
		
		var sProgress = nProgress.toString() + '%';
		var tblProgressBar        = document.getElementById('tblSplendidUI_ProgressBar'       );
		var divProgressBarText    = document.getElementById('divSplendidUI_ProgressBarText'   );
		var divProgressStatusText = document.getElementById('divSplendidUI_ProgressStatusText');
		divProgressBarText.innerHTML    = sProgress;
		tblProgressBar.style.width      = sProgress;
		divProgressStatusText.innerHTML = sStatusText;
	}
}

function UpdateStatus()
{
	var xhr = CreateSplendidRequest('Administration/Rest.svc/GetRecompileStatus', 'GET');
	xhr.onreadystatechange = function()
	{
		if ( xhr.readyState == 4 )
		{
			GetSplendidResult(xhr, function(result)
			{
				try
				{
					if ( result.status == 200 )
					{
						//console.log(dumpObj(result.d, ''));
						var oStatus = result.d;
						if ( oStatus != null )
						{
							var divProgressPanel = document.getElementById('divProgressPanel');
							divProgressPanel.style.display = '';
							var nMaximum = Sql.ToInteger(oStatus.TotalPasses) * Sql.ToInteger(oStatus.TotalViews);
							var nCurrent = Sql.ToInteger(oStatus.CurrentPass) * Sql.ToInteger(oStatus.TotalViews) + Sql.ToInteger(oStatus.CurrentView);
							var sStatus  = oStatus.StartDate + ', Pass ' + oStatus.CurrentPass + ' of ' + oStatus.TotalPasses + ', ' + oStatus.RemainingSeconds + ' seconds remaining, ' + oStatus.CurrentViewName + '. ';
							SplendidUI_UpdateProgressBar(nCurrent, nMaximum, sStatus);
							setTimeout(function()
							{
								UpdateStatus();
							}, 1000);
						}
						else
						{
							var divProgressBarFrame = document.getElementById('divSplendidUI_ProgressBarFrame');
							if ( divProgressBarFrame != null )
							{
								divProgressBarFrame.parentNode.removeChild(divProgressBarFrame);
							}
						}
					}
					else
					{
						if ( result.ExceptionDetail !== undefined )
							SplendidError.SystemMessage(result.ExceptionDetail.Message);
						else
							SplendidError.SystemMessage(xhr.responseText);
					}
				}
				catch(e)
				{
					SplendidError.SystemMessage(SplendidError.FormatError(e, 'CalendarView_GetCalendar'));
				}
			});
		}
	}
	try
	{
		xhr.send();
	}
	catch(e)
	{
		if ( e.number != -2146697208 )
			SplendidError.SystemMessage(SplendidError.FormatError(e, 'CalendarView_GetCalendar'));
	}
}

$(document).ready(function()
{
	SplendidUI_ProgressBar('divProgressPanel');
	SplendidUI_UpdateProgressBar(0, 100, 'Getting status');
	UpdateStatus();
});
		</script>
	</SplendidCRM:InlineScript>

	<div id="divProgressPanel" style="display: none;"></div>

	<asp:Table Width="100%" CssClass="tabDetailView2" runat="server">
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Wrap="false" Visible='<%# SplendidCRM.Security.AdminUserAccess("DynamicLayout", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/DynamicLayout/html5/default.aspx") %>'>
				<asp:Image SkinID="Layout" AlternateText='<%# L10n.Term("Administration.LBL_MANAGE_LAYOUT") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MANAGE_LAYOUT") %>' NavigateUrl="~/Administration/DynamicLayout/html5/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("DynamicLayout", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/DynamicLayout/html5/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_LAYOUT") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Dropdown", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/Dropdown/default.aspx") %>'>
				<asp:Image SkinID="Dropdown" AlternateText='<%# L10n.Term("Administration.LBL_DROPDOWN_EDITOR") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_DROPDOWN_EDITOR") %>' NavigateUrl="~/Administration/Dropdown/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Dropdown", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/Dropdown/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.DESC_DROPDOWN_EDITOR") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("EditCustomFields", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/EditCustomFields/default.aspx") %>'>
				<asp:Image SkinID="FieldLabels" AlternateText='<%# L10n.Term("Administration.LBL_EDIT_CUSTOM_FIELDS") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_EDIT_CUSTOM_FIELDS") %>' NavigateUrl="~/Administration/EditCustomFields/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
				<br />
				<div align="center">
				(
				<asp:LinkButton Text="Recompile"     CommandName="System.RecompileViews" OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Runat="server" />
				&nbsp;
				<asp:LinkButton Text="Rebuild Audit" CommandName="System.RebuildAudit"   OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Runat="server" />
				&nbsp;
				<asp:LinkButton ID="lnkUpdateModel" Text="UpdateModel" CommandName="System.UpdateModel" OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Visible="false" Runat="server" />
				)
				</div>
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("EditCustomFields", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/EditCustomFields/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.DESC_EDIT_CUSTOM_FIELDS") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Modules", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/ConfigureTabs/default.aspx") %>'>
				<asp:Image SkinID="ConfigureTabs" AlternateText='<%# L10n.Term("Administration.LBL_CONFIGURE_TABS") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_CONFIGURE_TABS") %>' NavigateUrl="~/Administration/ConfigureTabs/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Modules", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/ConfigureTabs/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_CHOOSE_WHICH") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Modules", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/RenameTabs/default.aspx") %>'>
				<asp:Image SkinID="RenameTabs" AlternateText='<%# L10n.Term("Administration.LBL_RENAME_TABS") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_RENAME_TABS") %>' NavigateUrl="~/Administration/RenameTabs/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Modules", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/RenameTabs/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_CHANGE_NAME_TABS") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("iFrames", "access") >= 0 && Utils.CachedFileExists(Context, "~/iFrames/default.aspx") %>'>
				<asp:Image SkinID="iFrames" AlternateText='<%# L10n.Term("Administration.DESC_IFRAME") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_IFRAME") %>' NavigateUrl="~/iFrames/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("iFrames", "access") >= 0 && Utils.CachedFileExists(Context, "~/iFrames/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.DESC_IFRAME") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Terminology", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/Terminology/default.aspx") %>'>
				<asp:Image SkinID="Terminology" AlternateText='<%# L10n.Term("Administration.LBL_MANAGE_TERMINOLOGY_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MANAGE_TERMINOLOGY_TITLE") %>' NavigateUrl="~/Administration/Terminology/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Terminology", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/Terminology/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_MANAGE_TERMINOLOGY") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Modules", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/Modules/default.aspx") %>'>
				<asp:Image SkinID="Modules" AlternateText='<%# L10n.Term("Administration.LBL_MODULES_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MODULES_TITLE") %>' NavigateUrl="~/Administration/Modules/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
				<br />
				<div align="center">
				(
					<asp:LinkButton ID="btnPagingEnable"  Visible='<%# !Config.allow_custom_paging() && (SplendidCRM.Security.AdminUserAccess("Modules", "edit") >= 0) %>' Text='<%# L10n.Term("Modules.LBL_ENABLE" ) %>' CommandName="CustomPaging.Enable"  OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Runat="server" />
					&nbsp;
					<asp:LinkButton ID="btnPagingDisable" Visible='<%#  Config.allow_custom_paging() && (SplendidCRM.Security.AdminUserAccess("Modules", "edit") >= 0) %>' Text='<%# L10n.Term("Modules.LBL_DISABLE") %>' CommandName="CustomPaging.Disable" OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Runat="server" />
					&nbsp;
					<asp:LinkButton ID="btnReactEnable"  Visible='<%# Sql.ToString(Application["Modules.Home.RelativePath"]).ToLower() != "~/react/home" && (SplendidCRM.Security.AdminUserAccess("Modules", "edit") >= 0) %>' Text='<%# L10n.Term("Modules.LBL_REACT_CLIENT_ENABLE" ) %>' CommandName="ReactClient.Enable"  OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Runat="server" />
					&nbsp;
					<asp:LinkButton ID="btnReactDisable" Visible='<%# Sql.ToString(Application["Modules.Home.RelativePath"]).ToLower() == "~/react/home" && (SplendidCRM.Security.AdminUserAccess("Modules", "edit") >= 0) %>' Text='<%# L10n.Term("Modules.LBL_REACT_CLIENT_DISABLE") %>' CommandName="ReactClient.Disable" OnCommand="Page_Command" CssClass="tabDetailViewDL2Link" Runat="server" />
				)
				</div>
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Modules", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/Modules/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_MODULES") %>' runat="server" /><br />
				<%# Config.allow_custom_paging() ? L10n.Term("Modules.LBL_CUSTOM_PAGING_ENABLED") : L10n.Term("Modules.LBL_CUSTOM_PAGING_DISABLED") %><br />
				<%# Sql.ToString(Application["Modules.Home.RelativePath"]).ToLower() == "~/react/home" ? L10n.Term("Modules.LBL_REACT_CLIENT_IS_ENABLED") : L10n.Term("Modules.LBL_REACT_CLIENT_IS_DISABLED") %><br />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Shortcuts", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/Shortcuts/default.aspx") %>'>
				<asp:Image SkinID="Shortcuts" AlternateText='<%# L10n.Term("Administration.LBL_MANAGE_SHORTCUTS_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MANAGE_SHORTCUTS_TITLE") %>' NavigateUrl="~/Administration/Shortcuts/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Shortcuts", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/Shortcuts/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_MANAGE_SHORTCUTS") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Languages", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/Languages/default.aspx") %>'>
				<asp:Image SkinID="LanguagePacks" AlternateText='<%# L10n.Term("Administration.LBL_MANAGE_LANGUAGES") %>' runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MANAGE_LANGUAGES") %>' NavigateUrl="~/Administration/Languages/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Languages", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/Languages/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_MANAGE_LANGUAGES") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("DynamicButtons", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/DynamicButtons/default.aspx") %>'>
				<asp:Image SkinID="DynamicButtons" AlternateText='<%# L10n.Term("Administration.LBL_MANAGE_DYNAMIC_BUTTONS_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MANAGE_DYNAMIC_BUTTONS_TITLE") %>' NavigateUrl="~/Administration/DynamicButtons/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("DynamicButtons", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/DynamicButtons/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_MANAGE_DYNAMIC_BUTTONS") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Terminology", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/Terminology/default.aspx") %>'>
				<asp:Image SkinID="Terminology" AlternateText='<%# L10n.Term("Administration.LBL_IMPORT_TERMINOLOGY_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_IMPORT_TERMINOLOGY_TITLE") %>' NavigateUrl="~/Administration/Terminology/Import/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Terminology", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/Terminology/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_IMPORT_TERMINOLOGY") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("FieldValidators", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/FieldValidators/default.aspx") %>'>
				<asp:Image SkinID="FieldValidators" AlternateText='<%# L10n.Term("Administration.LBL_MANAGE_FIELD_VALIDATORS_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MANAGE_FIELD_VALIDATORS_TITLE") %>' NavigateUrl="~/Administration/FieldValidators/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("FieldValidators", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/FieldValidators/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_MANAGE_FIELD_VALIDATORS") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Tags", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/Tags/default.aspx") %>'>
				<asp:Image SkinID="Tags" AlternateText='<%# L10n.Term("Administration.LBL_MANAGE_TAGS_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Administration.LBL_MANAGE_TAGS_TITLE") %>' NavigateUrl="~/Administration/Tags/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Tags", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/Tags/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("Administration.LBL_MANAGE_TAGS") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("FullTextSearch", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/FullTextSearch/default.aspx") %>'>
				<asp:Image SkinID="FullTextSearch" AlternateText='<%# L10n.Term("FullTextSearch.LBL_MANAGE_FULLTEXT_SEARCH_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("FullTextSearch.LBL_MANAGE_FULLTEXT_SEARCH_TITLE") %>' NavigateUrl="~/Administration/FullTextSearch/config.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("FullTextSearch", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/FullTextSearch/default.aspx") %>'>
				<asp:Label Text='<%# L10n.Term("FullTextSearch.LBL_MANAGE_FULLTEXT_SEARCH") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("ModuleBuilder", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/ModuleBuilder/default.aspx") %>'>
				<asp:Image ID="imgMODULE_BUILDER" SkinID="Modules" AlternateText='<%# L10n.Term("Administration.LBL_MODULE_BUILDER_TITLE") %>' Visible="false" Runat="server" />
				&nbsp;
				<asp:HyperLink ID="lnkMODULE_BUILDER" Text='<%# L10n.Term("Administration.LBL_MODULE_BUILDER_TITLE") %>' NavigateUrl="~/Administration/ModuleBuilder/default.aspx" CssClass="tabDetailViewDL2Link" Visible="false" Runat="server" />
			</asp:TableCell>
			<asp:TableCell CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("ModuleBuilder", "access") >= 0 && Utils.CachedFileExists(Context, "~/Administration/ModuleBuilder/default.aspx") %>'>
				<asp:Label ID="lblMODULE_BUILDER" Text='<%# L10n.Term("Administration.LBL_MODULE_BUILDER") %>' Visible="false" runat="server" />
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

