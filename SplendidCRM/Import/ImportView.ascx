<%@ Control CodeBehind="ImportView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Import.ImportView" %>
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
<div id="divImportView">
	<%-- 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. --%>
	<%@ Register TagPrefix="SplendidCRM" Tagname="HeaderButtons" Src="~/_controls/HeaderButtons.ascx" %>
	<SplendidCRM:HeaderButtons ID="ctlDynamicButtons" ShowRequired="true" EditView="true" Module="Import" Title="Import.LBL_MODULE_NAME" EnableModuleLabel="false" EnablePrint="false" HelpName="ImportView" EnableHelp="true" Runat="Server" />

	<script type="text/javascript">
	function OAuthTokenUpdate(oauth_token, oauth_verifier, realmId, refresh_token, expires_in)
	{
		document.getElementById('<%= txtOAUTH_TOKEN   .ClientID %>').value = oauth_token   ;
		document.getElementById('<%= txtOAUTH_VERIFIER.ClientID %>').value = oauth_verifier;
		// 06/03/2014 Paul.  Extract the QuickBooks realmId (same as Company ID). 
		document.getElementById('<%= txtOAUTH_REALMID .ClientID %>').value = realmId       ;
		// 04/23/2015 Paul.  HubSpot has more data. 
		document.getElementById('<%= txtOAUTH_REFRESH_TOKEN.ClientID %>').value = refresh_token ;
		document.getElementById('<%= txtOAUTH_EXPIRES_IN   .ClientID %>').value = expires_in    ;
		document.getElementById('<%= btnOAuthChanged.ClientID   %>').click();
	}

	function SelectWizardTab(key)
	{
		for ( var i = 1; i <= 7; i++ )
		{
			var sListClass = '';
			var sLinkClass = '';
			var sListStyle = 'none';

			if ( key == i )
			{
				sListClass = 'active' ;
				sLinkClass = 'current';
				sListStyle = 'block'  ;
			}
			document.getElementById('liImportStep'   + i).className     = sListClass;
			document.getElementById('linkImportStep' + i).className     = sLinkClass;
			document.getElementById('divImportStep'  + i).style.display = sListStyle;
		}
		document.getElementById('<%= txtACTIVE_TAB.ClientID %>').value = key;
	}


	function SelectSourceFormat()
	{
		var radEXCEL             = document.getElementById('<%= radEXCEL            .ClientID %>');
		var radXML_SPREADSHEET   = document.getElementById('<%= radXML_SPREADSHEET  .ClientID %>');
		var radXML               = document.getElementById('<%= radXML              .ClientID %>');
		var radACT_2005          = document.getElementById('<%= radACT_2005         .ClientID %>');
		var radDBASE             = document.getElementById('<%= radDBASE            .ClientID %>');
		var radCUSTOM_CSV        = document.getElementById('<%= radCUSTOM_CSV       .ClientID %>');
		var radCUSTOM_TAB        = document.getElementById('<%= radCUSTOM_TAB       .ClientID %>');
		var radCUSTOM_DELIMITED  = document.getElementById('<%= radCUSTOM_DELIMITED .ClientID %>');
		var radLINKEDIN          = document.getElementById('<%= radLINKEDIN         .ClientID %>');
		var radTWITTER           = document.getElementById('<%= radTWITTER          .ClientID %>');
		var radFACEBOOK          = document.getElementById('<%= radFACEBOOK         .ClientID %>');
		var radSALESFORCE        = document.getElementById('<%= radSALESFORCE       .ClientID %>');
		var radQUICKBOOKS        = document.getElementById('<%= radQUICKBOOKS       .ClientID %>');
		// 06/03/2014 Paul.  QuickBooks Online is going to use a different API than standard QuickBooks. 
		var radQUICKBOOKS_ONLINE = document.getElementById('<%= radQUICKBOOKS_ONLINE.ClientID %>');
		// 04/23/2015 Paul.  HubSpot uses OAuth2, similar to Facebook. 
		var radHUBSPOT           = document.getElementById('<%= radHUBSPOT          .ClientID %>');
		var bLinkedIn         = false;
		var bTwitter          = false;
		var bFacebook         = false;
		var bSalesforce       = false;
		var bQuickBooks       = false;
		var bQuickBooksOnline = false;
		var bHubSpot          = false;
		if ( radLINKEDIN          != null ) bLinkedIn         = radLINKEDIN         .checked;
		if ( radTWITTER           != null ) bTwitter          = radTWITTER          .checked;
		if ( radFACEBOOK          != null ) bFacebook         = radFACEBOOK         .checked;
		if ( radSALESFORCE        != null ) bSalesforce       = radSALESFORCE       .checked;
		if ( radQUICKBOOKS        != null ) bQuickBooks       = radQUICKBOOKS       .checked;
		if ( radQUICKBOOKS_ONLINE != null ) bQuickBooksOnline = radQUICKBOOKS_ONLINE.checked;
		// 04/23/2015 Paul.  HubSpot uses OAuth2, similar to Facebook. 
		if ( radHUBSPOT           != null ) bHubSpot          = radHUBSPOT          .checked;
		
		document.getElementById('tblInstructionsExcel'           ).style.display = radEXCEL           .checked ? 'inline' : 'none';
		document.getElementById('tblInstructionsXmlSpreadsheet'  ).style.display = radXML_SPREADSHEET .checked ? 'inline' : 'none';
		document.getElementById('tblInstructionsXML'             ).style.display = radXML             .checked ? 'inline' : 'none';
		document.getElementById('tblInstructionsAct'             ).style.display = radACT_2005        .checked ? 'inline' : 'none';
		document.getElementById('tblInstructionsDbase'           ).style.display = radDBASE           .checked ? 'inline' : 'none';
		document.getElementById('tblInstructionsCommaDelimited'  ).style.display = radCUSTOM_CSV      .checked ? 'inline' : 'none';
		document.getElementById('tblInstructionsTabDelimited'    ).style.display = radCUSTOM_TAB      .checked ? 'inline' : 'none';
		document.getElementById('tblInstructionsCommaDelimited'  ).style.display = radCUSTOM_DELIMITED.checked ? 'inline' : 'none';
		document.getElementById('divCUSTOM_DELIMITER_VAL'        ).style.display = radCUSTOM_DELIMITED.checked ? 'inline' : 'none';
		document.getElementById('tblInstructionsLinkedIn'        ).style.display = bLinkedIn                   ? 'inline' : 'none';
		document.getElementById('tblInstructionsTwitter'         ).style.display = bTwitter                    ? 'inline' : 'none';
		document.getElementById('tblInstructionsFacebook'        ).style.display = bFacebook                   ? 'inline' : 'none';
		document.getElementById('tblInstructionsSalesForce'      ).style.display = bSalesforce                 ? 'inline' : 'none';
		document.getElementById('tblInstructionsQuickBooks'      ).style.display = bQuickBooks                 ? 'inline' : 'none';
		document.getElementById('tblInstructionsQuickBooksOnline').style.display = bQuickBooksOnline           ? 'inline' : 'none';
		// 04/23/2015 Paul.  HubSpot uses OAuth2, similar to Facebook. 
		document.getElementById('tblInstructionsHubSpot'         ).style.display = bHubSpot                    ? 'inline' : 'none';
		
		// 06/03/2014 Paul.  QuickBooks Online is going to use a different API than standard QuickBooks. 
		// 04/23/2015 Paul.  HubSpot uses OAuth2, similar to Facebook. 
		document.getElementById('spnStep3Upload'  ).style.display = (!(bLinkedIn || bTwitter || bFacebook || bSalesforce || bQuickBooks || bQuickBooksOnline || bHubSpot) ? 'inline' : 'none');
		document.getElementById('spnStep3Connect' ).style.display = ( (bLinkedIn || bTwitter || bFacebook || bSalesforce || bQuickBooks || bQuickBooksOnline || bHubSpot) ? 'inline' : 'none');
		document.getElementById('tblUploadFile'   ).style.display = (!(bLinkedIn || bTwitter || bFacebook || bSalesforce || bQuickBooks || bQuickBooksOnline || bHubSpot) ? 'inline' : 'none');
		document.getElementById('tblUploadConnect').style.display = ( (bLinkedIn || bTwitter || bFacebook || bSalesforce || bQuickBooks || bQuickBooksOnline || bHubSpot) ? 'inline' : 'none');
		
		var sImportModule = '<%= sImportModule %>';
		document.getElementById('tblNotesAccounts'     ).style.display = (sImportModule == 'Accounts'     ) ? 'inline' : 'none';
		document.getElementById('tblNotesContacts'     ).style.display = (sImportModule == 'Contacts'     ) ? 'inline' : 'none';
		document.getElementById('tblNotesOpportunities').style.display = (sImportModule == 'Opportunities') ? 'inline' : 'none';
	}

	function MoveLeftToRight(sLeftID, sRightID, bReverse)
	{
		var lstLeft  = document.getElementById(sLeftID );
		var lstRight = document.getElementById(sRightID);
		var sModuleName = '<%= sImportModule %>';
		for ( i=0; i < lstLeft.options.length ; i++ )
		{
			if ( lstLeft.options[i].selected == true )
			{
				var oOption = document.createElement("OPTION");
				if ( bReverse == 1 )
					oOption.text  = sModuleName + ': ' + lstLeft.options[i].text;
				else if ( lstLeft.options[i].text.indexOf(': ') >= 0 )
					oOption.text  = lstLeft.options[i].text.substring(lstLeft.options[i].text.indexOf(': ')+2);
				else
					oOption.text  = lstLeft.options[i].text;
				oOption.value = lstLeft.options[i].value;
				lstRight.options.add(oOption);
			}
		}
		for ( i=lstLeft.options.length-1; i >= 0  ; i-- )
		{
			if ( lstLeft.options[i].selected == true )
			{
				// 10/11/2006 Paul.  Firefox does not support options.remove(), so just set the option to null. 
				lstLeft.options[i] = null;
			}
		}
		// 08/05/2005 Paul. Don't use the sLeftID & sRightID values as they can be reversed. 
		CopyToHidden('<%= ctlDuplicateFilterChooser.lstLeft.ClientID  %>', '<%= ctlDuplicateFilterChooser.txtLeft.ClientID  %>');
		CopyToHidden('<%= ctlDuplicateFilterChooser.lstRight.ClientID %>', '<%= ctlDuplicateFilterChooser.txtRight.ClientID %>');
	}

	function AppendConditionVariable(sID, sValue, sCsType)
	{
		var fld = document.getElementById(sID);
		if ( fld != undefined )
		{
			switch ( sCsType )
			{
				case 'Guid'      :  fld.value += 'this.ToGuid(this["'     + sValue + '"]) ';  break;
				case 'short'     :  fld.value += 'this.ToShort(this["'    + sValue + '"]) ';  break;
				case 'Int32'     :  fld.value += 'this.ToInteger(this["'  + sValue + '"]) ';  break;
				case 'Int16'     :  fld.value += 'this.ToInteger(this["'  + sValue + '"]) ';  break;
				case 'Int64'     :  fld.value += 'this.ToLong(this["'     + sValue + '"]) ';  break;
				case 'float'     :  fld.value += 'this.ToFloat(this["'    + sValue + '"]) ';  break;
				case 'decimal'   :  fld.value += 'this.ToDecimal(this["'  + sValue + '"]) ';  break;
				case 'bool'      :  fld.value += 'this.ToBoolean(this["'  + sValue + '"]) ';  break;
				case 'ansistring':  fld.value += 'this.ToString(this["'   + sValue + '"]) ';  break;
				case 'string'    :  fld.value += 'this.ToString(this["'   + sValue + '"]) ';  break;
				case 'DateTime'  :  fld.value += 'this.ToDateTime(this["' + sValue + '"]) ';  break;
				case 'byte[]'    :  fld.value += 'this.ToBinary(this["'   + sValue + '"]) ';  break;
				default          :  fld.value += 'this.ToString(this["'   + sValue + '"]) ';  break;
			}
		}
	}
	function AppendRuleVariable(sID, sValue)
	{
		var fld = document.getElementById(sID);
		if ( fld != undefined )
		{
			fld.value += 'this["' + sValue + '"] ';
		}
	}
	</script>

	<asp:HiddenField ID="txtACTIVE_TAB"          runat="server" />
	<asp:HiddenField ID="txtOAUTH_TOKEN"         runat="server" />
	<asp:HiddenField ID="txtOAUTH_SECRET"        runat="server" />
	<asp:HiddenField ID="txtOAUTH_VERIFIER"      runat="server" />
	<asp:HiddenField ID="txtOAUTH_ACCESS_TOKEN"  runat="server" />
	<asp:HiddenField ID="txtOAUTH_ACCESS_SECRET" runat="server" />
	<asp:HiddenField ID="txtOAUTH_REALMID"       runat="server" />
	<asp:HiddenField ID="txtOAUTH_REFRESH_TOKEN" runat="server" />
	<asp:HiddenField ID="txtOAUTH_EXPIRES_IN"    runat="server" />
	<asp:Button ID="btnOAuthChanged" CommandName="Import.OAuthToken" OnCommand="Page_Command" style="display: none" Runat="server" />
	
	<ul class="tablist">
		<li id="liImportStep1" class="active"><a id="linkImportStep1" href="javascript:SelectWizardTab(1);" class="current"><%= "1. " + L10n.Term("Import.LBL_IMPORT_STEP_SELECT_SOURCE"   ) %></a></li>
		<li id="liImportStep2" class=""      ><a id="linkImportStep2" href="javascript:SelectWizardTab(2);" class=""       ><%= "2. " + L10n.Term("Import.LBL_IMPORT_STEP_SPECIFY_DEFAULTS") %></a></li>
		<li id="liImportStep3" class=""      >
			<a id="linkImportStep3" href="javascript:SelectWizardTab(3);" class=""       >
				<span id="spnStep3Upload"  style="DISPLAY: inline"><%= "3. " + L10n.Term("Import.LBL_IMPORT_STEP_UPLOAD_FILE") %></span>
				<span id="spnStep3Connect" style="DISPLAY: none"><%= "3. " + L10n.Term("Import.LBL_IMPORT_STEP_CONNECT"    ) %></span>
			</a>
		</li>
		<li id="liImportStep4" class=""      ><a id="linkImportStep4" href="javascript:SelectWizardTab(4);" class=""       ><%= "4. " + L10n.Term("Import.LBL_IMPORT_STEP_MAP_FIELDS"      ) %></a></li>
		<li id="liImportStep5" class=""      ><a id="linkImportStep5" href="javascript:SelectWizardTab(5);" class=""       ><%= "5. " + L10n.Term("Import.LBL_IMPORT_STEP_DUPLICATE_FILTER") %></a></li>
		<li id="liImportStep6" class=""      ><a id="linkImportStep6" href="javascript:SelectWizardTab(6);" class=""       ><%= "6. " + L10n.Term("Import.LBL_IMPORT_STEP_BUSINESS_RULES"  ) %></a></li>
		<li id="liImportStep7" class=""      ><a id="linkImportStep7" href="javascript:SelectWizardTab(7);" class=""       ><%= "7. " + L10n.Term("Import.LBL_IMPORT_STEP_RESULTS"         ) %></a></li>
	</ul>
	<div id="divImportStep1" style="DISPLAY: none">
		<asp:Table SkinID="tabForm" runat="server">
			<asp:TableRow>
				<asp:TableCell>
					<table class="tabEditView">
						<tr>
							<td class="dataField" colspan="2"><h4><asp:Label Text='<%# L10n.Term("Import.LBL_WHAT_IS") %>' runat="server" /></h4></td>
						</tr>
						<tr>
							<td width="35%" class="dataField">
								<nobr>
									<asp:RadioButton ID="radEXCEL"            GroupName="radSOURCE" Text='<%# L10n.Term("Import.LBL_EXCEL"           ) %>' CssClass="checkbox" OnCheckedChanged="SOURCE_TYPE_CheckedChanged" AutoPostBack="true" runat="server" /><br />
									<asp:RadioButton ID="radXML_SPREADSHEET"  GroupName="radSOURCE" Text='<%# L10n.Term("Import.LBL_XML_SPREADSHEET" ) %>' CssClass="checkbox" OnCheckedChanged="SOURCE_TYPE_CheckedChanged" AutoPostBack="true" runat="server" /><br />
									<asp:RadioButton ID="radXML"              GroupName="radSOURCE" Text='<%# L10n.Term("Import.LBL_XML"             ) %>' CssClass="checkbox" OnCheckedChanged="SOURCE_TYPE_CheckedChanged" AutoPostBack="true" runat="server" /><br />
									<asp:RadioButton ID="radACT_2005"         GroupName="radSOURCE" Text='<%# L10n.Term("Import.LBL_ACT_2005"        ) %>' CssClass="checkbox" OnCheckedChanged="SOURCE_TYPE_CheckedChanged" AutoPostBack="true" runat="server" /><br />
									<asp:RadioButton ID="radDBASE"            GroupName="radSOURCE" Text='<%# L10n.Term("Import.LBL_DBASE"           ) %>' CssClass="checkbox" OnCheckedChanged="SOURCE_TYPE_CheckedChanged" AutoPostBack="true" runat="server" /><br />
									<asp:RadioButton ID="radCUSTOM_CSV"       GroupName="radSOURCE" Text='<%# L10n.Term("Import.LBL_CUSTOM_CSV"      ) %>' CssClass="checkbox" OnCheckedChanged="SOURCE_TYPE_CheckedChanged" AutoPostBack="true" runat="server" /><br />
									<asp:RadioButton ID="radCUSTOM_TAB"       GroupName="radSOURCE" Text='<%# L10n.Term("Import.LBL_CUSTOM_TAB"      ) %>' CssClass="checkbox" OnCheckedChanged="SOURCE_TYPE_CheckedChanged" AutoPostBack="true" runat="server" /><br />
									<asp:RadioButton ID="radCUSTOM_DELIMITED" GroupName="radSOURCE" Text='<%# L10n.Term("Import.LBL_CUSTOM_DELIMETED") %>' CssClass="checkbox" OnCheckedChanged="SOURCE_TYPE_CheckedChanged" AutoPostBack="true" runat="server" /><br />
									<div id="divCUSTOM_DELIMITER_VAL" style="DISPLAY: none">
										&nbsp; &nbsp; <%= L10n.Term("Import.LBL_CUSTOM_DELIMETER") %> <asp:TextBox ID="txtCUSTOM_DELIMITER_VAL" MaxLength="1" size="3" runat="server" />
									</div>
									<hr />
									<!-- 05/18/2017 Paul.  The LinkedIn Connections API has been discontinued. https://developer.linkedin.com/support/developer-program-transition -->
									<asp:RadioButton ID="radLINKEDIN"          GroupName="radSOURCE" Text='<%# L10n.Term("Import.LBL_LINKEDIN"         ) %>' CssClass="checkbox" OnCheckedChanged="SOURCE_TYPE_CheckedChanged" AutoPostBack="true" Enabled='<%# !Sql.IsEmptyString(Application["CONFIG.LinkedIn.APIKey"            ]) %>' Visible="false" runat="server" /><br />
									<asp:RadioButton ID="radTWITTER"           GroupName="radSOURCE" Text='<%# L10n.Term("Import.LBL_TWITTER"          ) %>' CssClass="checkbox" OnCheckedChanged="SOURCE_TYPE_CheckedChanged" AutoPostBack="true" Enabled='<%# !Sql.IsEmptyString(Application["CONFIG.Twitter.ConsumerKey"        ]) %>' runat="server" /><br />
									<asp:RadioButton ID="radFACEBOOK"          GroupName="radSOURCE" Text='<%# L10n.Term("Import.LBL_FACEBOOK"         ) %>' CssClass="checkbox" OnCheckedChanged="SOURCE_TYPE_CheckedChanged" AutoPostBack="true" Enabled='<%# !Sql.IsEmptyString(Application["CONFIG.facebook.AppID"             ]) %>' runat="server" /><br />
									<asp:RadioButton ID="radSALESFORCE"        GroupName="radSOURCE" Text='<%# L10n.Term("Import.LBL_SALESFORCE"       ) %>' CssClass="checkbox" OnCheckedChanged="SOURCE_TYPE_CheckedChanged" AutoPostBack="true" Enabled='<%# !Sql.IsEmptyString(Application["CONFIG.Salesforce.ConsumerKey"     ]) %>' runat="server" /><br />
									<asp:RadioButton ID="radQUICKBOOKS"        GroupName="radSOURCE" Text='<%# L10n.Term("Import.LBL_QUICKBOOKS"       ) %>' CssClass="checkbox" OnCheckedChanged="SOURCE_TYPE_CheckedChanged" AutoPostBack="true" Enabled='<%# !Sql.IsEmptyString(Application["CONFIG.QuickBooks.ConnectionString"]) %>' Visible='<%# sImportModule == "Accounts" || sImportModule == "Contacts" || sImportModule == "ProductTemplates" || sImportModule == "Items" || sImportModule == "ShippingMethod" || sImportModule == "Estimates" || sImportModule == "SalesOrder" || sImportModule == "Invoice" %>' runat="server" /><br />
									<asp:RadioButton ID="radQUICKBOOKS_ONLINE" GroupName="radSOURCE" Text='<%# L10n.Term("Import.LBL_QUICKBOOKS_ONLINE") %>' CssClass="checkbox" OnCheckedChanged="SOURCE_TYPE_CheckedChanged" AutoPostBack="true" Enabled='<%# !Sql.IsEmptyString(Application["CONFIG.QuickBooks.OAuthClientID"   ]) %>' Visible='<%# sImportModule == "Accounts" || sImportModule == "Contacts" || sImportModule == "ProductTemplates" || sImportModule == "Items" || sImportModule == "ShippingMethod" || sImportModule == "Invoice" %>' runat="server" /><br />
									<asp:RadioButton ID="radHUBSPOT"           GroupName="radSOURCE" Text='<%# L10n.Term("Import.LBL_HUBSPOT"          ) %>' CssClass="checkbox" OnCheckedChanged="SOURCE_TYPE_CheckedChanged" AutoPostBack="true" Enabled='<%# !Sql.IsEmptyString(Application["CONFIG.HubSpot.PortalID"           ]) %>' runat="server" /><br />
								</nobr>
							</td>
							<td valign="top">
								<table border="0" cellspacing="0" cellpadding="0">
									<tr>
										<td class="dataLabel"><h4><asp:Label Text='<%# L10n.Term("Import.LBL_NAME") %>' runat="server" /></h4></td>
										<td class="dataField">
											<asp:TextBox ID="txtNAME" TabIndex="2" size="35" MaxLength="150" Runat="server" />
											<asp:Button ID="btnSave" CommandName="Import.Save" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Import.LBL_SAVE_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term("Import.LBL_SAVE_BUTTON_TITLE") %>' Runat="server" />
											<asp:RequiredFieldValidator ID="reqNAME" ControlToValidate="txtNAME" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" Enabled="false" EnableClientScript="false" EnableViewState="false" Display="Dynamic" Runat="server" />
										</td>
									</tr>
								</table>
							</td>
						</tr>
					</table>
					<br />
					<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
					<SplendidCRM:ListHeader Visible="<%# !PrintView %>" Title="Import.LBL_MY_SAVED" Runat="Server" />
					<SplendidCRM:SplendidGrid id="grdMySaved" AllowPaging="false" AllowSorting="false" EnableViewState="true" runat="server">
						<Columns>
							<asp:TemplateColumn HeaderText="Import.LBL_LIST_NAME"  SortExpression="NAME" ItemStyle-Width="85%" ItemStyle-CssClass="listViewTdLinkS1">
								<ItemTemplate>
									<asp:HyperLink NavigateUrl='<%# Request.Path + "?ID=" + Sql.ToString(Eval("ID")) %>' CssClass="listViewTdToolsS1" Text='<%# DataBinder.Eval(Container.DataItem, "NAME") %>' runat="server" />
								</ItemTemplate>
							</asp:TemplateColumn>
							<asp:TemplateColumn HeaderText="" ItemStyle-HorizontalAlign="Right" ItemStyle-Wrap="false">
								<ItemTemplate>
									<span onclick="return confirm('<%= L10n.TermJavaScript(".NTC_DELETE_CONFIRMATION") %>')">
										<%-- 03/28/2018 Paul.  Only admin can delete global. --%>
										<asp:ImageButton Visible='<%# Security.IS_ADMIN || !Sql.IsEmptyGuid(Eval("ASSIGNED_USER_ID")) %>' CommandName="Import.Delete" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" AlternateText='<%# L10n.Term(".LNK_DELETE") %>' SkinID="delete_inline" Runat="server" />
										<asp:LinkButton  Visible='<%# Security.IS_ADMIN || !Sql.IsEmptyGuid(Eval("ASSIGNED_USER_ID")) %>' CommandName="Import.Delete" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="listViewTdToolsS1" Text='<%# L10n.Term(".LNK_DELETE") %>' Runat="server" />
									</span>
								</ItemTemplate>
							</asp:TemplateColumn>
						</Columns>
					</SplendidCRM:SplendidGrid>

				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</div>
	<div id="divImportStep2" style="DISPLAY: none">
		<asp:PlaceHolder ID="phDefaultsView" Runat="server" />
	</div>
	<div id="divImportStep3" style="DISPLAY: none">
		<asp:Table SkinID="tabForm" runat="server">
			<asp:TableRow>
				<asp:TableCell>
					<table width="100%" cellpadding="0" cellspacing="0" border="0">
						<tr>
							<td>
								<div id="tblInstructionsExcel"            style="DISPLAY: none"><%= L10n.Term("Import.LBL_IMPORT_EXCEL_TITLE"          ) %></div>
								<div id="tblInstructionsXmlSpreadsheet"   style="DISPLAY: none"><%= L10n.Term("Import.LBL_IMPORT_XML_SPREADSHEET_TITLE") %></div>
								<div id="tblInstructionsSalesForce"       style="DISPLAY: none"><%= L10n.Term("Import.LBL_IMPORT_SF_TITLE"             ) %></div>
								<div id="tblInstructionsAct"              style="DISPLAY: none"><%= L10n.Term("Import.LBL_IMPORT_ACT_TITLE"            ) %></div>
								<div id="tblInstructionsDbase"            style="DISPLAY: none"><%= L10n.Term("Import.LBL_IMPORT_DBASE_TITLE"          ) %><br /><%= L10n.Term("Import.LBL_IMPORT_DBASE") %></div>
								<div id="tblInstructionsCommaDelimited"   style="DISPLAY: none"><%= L10n.Term("Import.LBL_IMPORT_CUSTOM_TITLE"         ) %></div>
								<div id="tblInstructionsTabDelimited"     style="DISPLAY: none"><%= L10n.Term("Import.LBL_IMPORT_TAB_TITLE"            ) %></div>
								<div id="tblInstructionsLinkedIn"         style="DISPLAY: none"><%= L10n.Term("Import.LBL_IMPORT_LINKEDIN_TITLE"       ) %></div>
								<div id="tblInstructionsTwitter"          style="DISPLAY: none"><%= L10n.Term("Import.LBL_IMPORT_TWITTER_TITLE"        ) %></div>
								<div id="tblInstructionsFacebook"         style="DISPLAY: none"><%= L10n.Term("Import.LBL_IMPORT_FACEBOOK_TITLE"       ) %></div>
								<div id="tblInstructionsQuickBooks"       style="DISPLAY: none"><%= L10n.Term("Import.LBL_IMPORT_QUICKBOOKS_TITLE"     ) %></div>
								<div id="tblInstructionsQuickBooksOnline" style="DISPLAY: none"><%= L10n.Term("Import.LBL_IMPORT_QUICKBOOKS_ONLINE"    ) %></div>
								<div id="tblInstructionsHubSpot"          style="DISPLAY: none"><%= L10n.Term("Import.LBL_IMPORT_HUBSPOT_TITLE"        ) %></div>
								<div id="tblInstructionsXML"              style="DISPLAY: none"><%= L10n.Term("Import.LBL_IMPORT_XML_TITLE"            ) %>
								<pre>
			&lt;xml&gt;
			   &lt;<%= sImportModule.ToLower() %>&gt;
				  &lt;id&gt;&lt;/id&gt;
				  &lt;name&gt;&lt;/name&gt;
			   &lt;/<%= sImportModule.ToLower() %>&gt;
			&lt;/xml&gt;</pre></div>
							</td>
						</tr>
					</table>
					<br />
					<table id="tblUploadFile" border="0" cellspacing="0" cellpadding="0" width="100%">
						<tr>
							<td align="left" class="dataLabel" colspan="4">
								<%= L10n.Term("Import.LBL_SELECT_FILE") %>&nbsp;<asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" />
								<asp:RequiredFieldValidator ID="reqFILENAME" ControlToValidate="fileIMPORT" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" Enabled="false" EnableClientScript="false" EnableViewState="false" Runat="server" />
							</td>
						</tr>
						<tr>
							<td class="dataLabel">
								<input id="fileIMPORT" type="file" size="60" MaxLength="255" runat="server" />
								<asp:Button ID="btnUpload" CommandName="Import.Upload" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Import.LBL_UPLOAD_BUTTON_LABEL" ) + "  " %>' ToolTip='<%# L10n.Term("Import.LBL_UPLOAD_BUTTON_TITLE" ) %>' Runat="server" />
							</td>
						</tr>
						<tr>
							<td class="dataField">
								<%= L10n.Term("Import.LBL_HAS_HEADER") %>&nbsp;
								<asp:CheckBox ID="chkHasHeader" CssClass="checkbox" Runat="server" />
							</td>
						</tr>
					</table>
					<table id="tblUploadConnect" border="0" cellspacing="0" cellpadding="0" width="100%" style="DISPLAY: none">
						<tr>
							<td align="left" class="dataLabel">
								<asp:Button ID="btnSignIn"                                                        CssClass="button" Text='<%# "  " + L10n.Term("Import.LBL_SIGNIN_BUTTON_LABEL" ) + "  " %>' ToolTip='<%# L10n.Term("Import.LBL_SIGNIN_BUTTON_TITLE" ) %>' Runat="server" />&nbsp;
								<asp:Button ID="btnConnect" CommandName="Import.Connect" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Import.LBL_CONNECT_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term("Import.LBL_CONNECT_BUTTON_TITLE") %>' Runat="server" />&nbsp;
								<asp:Button ID="btnSignOut" CommandName="Import.SignOut" OnCommand="Page_Command" CssClass="button" Text='<%# "  " + L10n.Term("Import.LBL_SIGNOUT_BUTTON_LABEL") + "  " %>' ToolTip='<%# L10n.Term("Import.LBL_SIGNOUT_BUTTON_TITLE") %>' Runat="server" />&nbsp;
							</td>
						</tr>
					</table>
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</div>
	<div id="divImportStep4" style="DISPLAY: none">
		<asp:Table SkinID="tabForm" runat="server">
			<asp:TableRow>
				<asp:TableCell>
					<table width="100%" cellpadding="0" cellspacing="0" border="0" visible="true">
						<tr>
							<td align="right" nowrap>
								<asp:Label CssClass="required" Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' Runat="server" /> <%= L10n.Term(".NTC_REQUIRED") %>
							</td>
						</tr>
						<tr>
							<td>
								<%= L10n.Term("Import.LBL_SELECT_FIELDS_TO_MAP") %>
							</td>
						</tr>
					</table>

					<table id="tblNotesAccounts" width="100%" cellpadding="0" cellspacing="0" border="0" style="DISPLAY: none">
						<tr>
							<td>
								<br />
								<b><%= L10n.Term("Import.LBL_NOTES") %></b>
								<ul>
									<li><%= L10n.Term("Import.LBL_ACCOUNTS_NOTE_1") %></li>
									<!--
									<li><%= L10n.Term("Import.LBL_ACCOUNTS_NOTE_2") %></li>
									-->
								</ul>
							</td>
						</tr>
					</table>
					<table id="tblNotesContacts" width="100%" cellpadding="0" cellspacing="0" border="0" style="DISPLAY: none">
						<tr>
							<td>
								<br />
								<b><%= L10n.Term("Import.LBL_NOTES") %></b>
								<ul>
									<li><%= L10n.Term("Import.LBL_CONTACTS_NOTE_1") %></li>
									<!--
									<li><%= L10n.Term("Import.LBL_CONTACTS_NOTE_2") %></li>
									<li><%= L10n.Term("Import.LBL_CONTACTS_NOTE_3") %></li>
									<li><%= L10n.Term("Import.LBL_CONTACTS_NOTE_4") %></li>
									-->
								</ul>
							</td>
						</tr>
					</table>
					<table id="tblNotesOpportunities" width="100%" cellpadding="0" cellspacing="0" border="0" style="DISPLAY: none">
						<tr>
							<td>
								<br />
								<b><%= L10n.Term("Import.LBL_NOTES") %></b>
								<ul>
									<li><%= L10n.Term("Import.LBL_OPPORTUNITIES_NOTE_1") %></li>
								</ul>
							</td>
						</tr>
					</table>

					<table id="tblImportMappings" class="tabDetailView" runat="server" />
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</div>
	<div id="divImportStep5" style="DISPLAY: none">
		<asp:Table SkinID="tabForm" runat="server">
			<asp:TableRow>
				<asp:TableCell>
					<%@ Register TagPrefix="SplendidCRM" Tagname="Chooser" Src="~/_controls/Chooser.ascx" %>
					<SplendidCRM:Chooser ID="ctlDuplicateFilterChooser" ChooserTitle="Import.LBL_DUPLICATE_FILTER" LeftTitle="Import.LBL_FILTER_COLUMNS" RightTitle="Import.LBL_AVAILABLE_COLUMNS" Enabled="true" Runat="Server" />
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</div>
	<div id="divImportStep6" style="DISPLAY: none">
		<asp:Table SkinID="tabForm" runat="server">
			<asp:TableRow>
				<asp:TableCell style="padding-top: 5px; padding-bottom: 5px;">
					<asp:DataGrid ID="dgRules" AutoGenerateColumns="false" CellPadding="3" CellSpacing="0" 
						AllowPaging="false" AllowSorting="false" ShowHeader="true" EnableViewState="true" runat="server">
						<Columns>
							<asp:BoundColumn HeaderText="Rules.LBL_LIST_ID"           DataField="ID"           Visible="false" />
							<asp:BoundColumn HeaderText="Rules.LBL_LIST_RULE_NAME"    DataField="RULE_NAME"    Visible="false" />
							<asp:BoundColumn HeaderText="Rules.LBL_LIST_PRIORITY"     DataField="PRIORITY"     />
							<asp:BoundColumn HeaderText="Rules.LBL_LIST_REEVALUATION" DataField="REEVALUATION" Visible="false" />
							<asp:BoundColumn HeaderText="Rules.LBL_LIST_ACTIVE"       DataField="ACTIVE"       />
							<asp:BoundColumn HeaderText="Rules.LBL_LIST_CONDITION"    DataField="CONDITION"    />
							<asp:BoundColumn HeaderText="Rules.LBL_LIST_THEN_ACTIONS" DataField="THEN_ACTIONS" />
							<asp:BoundColumn HeaderText="Rules.LBL_LIST_ELSE_ACTIONS" DataField="ELSE_ACTIONS" />
							<asp:TemplateColumn HeaderText="" ItemStyle-Width="1%" ItemStyle-HorizontalAlign="Left" ItemStyle-Wrap="false">
								<ItemTemplate>
									<asp:Button ID="btnEditFilter" CommandName="Rules.Edit" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_EDIT_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_EDIT_BUTTON_TITLE") %>' Runat="server" />
									&nbsp;
									<asp:Button ID="btnDeleteFilter" CommandName="Rules.Delete" CommandArgument='<%# DataBinder.Eval(Container.DataItem, "ID") %>' OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term("Rules.LBL_REMOVE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term("Rules.LBL_REMOVE_BUTTON_TITLE") %>' Runat="server" />
								</ItemTemplate>
							</asp:TemplateColumn>
						</Columns>
					</asp:DataGrid>
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
		<asp:Table SkinID="tabForm" runat="server">
			<asp:TableRow>
				<asp:TableCell>
					<asp:HiddenField ID="txtRULE_ID" runat="server" />
					<asp:Table SkinID="tabEditView" runat="server">
						<asp:TableRow>
							<asp:TableCell VerticalAlign="top" Visible="false">
								<asp:Label Text='<%# L10n.Term("Rules.LBL_RULE_NAME") %>' CssClass="dataLabel" runat="server" /> <asp:Label Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' CssClass="required" runat="server" /><br />
								<asp:TextBox      ID="txtRULE_NAME"    TabIndex="10" Columns="40" Runat="server" />
								&nbsp;<asp:RequiredFieldValidator ID="reqRULE_NAME" ControlToValidate="txtRULE_NAME" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Enabled="false" Display="dynamic" Runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="top">
								<asp:Label Text='<%# L10n.Term("Rules.LBL_PRIORITY") %>' CssClass="dataLabel" runat="server" /><br />
								<asp:TextBox      ID="txtPRIORITY"     TabIndex="11" Columns="10" Runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="top" Visible="false">
								<asp:Label Text='<%# L10n.Term("Rules.LBL_REEVALUATION") %>' CssClass="dataLabel" runat="server" /><br />
								<script runat="server">
									// 10/25/2010 Paul.  You have to be careful with Reevaluation Always as it will re-evaluate 
									// after the Then or Else actions to see if it needs to be run again. This can cause an endless loop. 
								</script>
								<asp:DropDownList ID="lstREEVALUATION" TabIndex="12" DataValueField="NAME" DataTextField="DISPLAY_NAME" Enabled="false" Runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="top">
								<asp:Label Text='<%# L10n.Term("Rules.LBL_ACTIVE") %>' CssClass="dataLabel" runat="server" /><br />
								<asp:CheckBox     ID="chkACTIVE"       TabIndex="13" CssClass="checkbox" Checked="true" Runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="top">
								<br />
								<asp:Button CommandName="Rules.Update" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_UPDATE_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_UPDATE_BUTTON_TITLE") %>' Runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="top">
								<br />
								<asp:Button CommandName="Rules.Cancel" OnCommand="Page_Command" CssClass="button" Text='<%# L10n.Term(".LBL_CANCEL_BUTTON_LABEL") %>' ToolTip='<%# L10n.Term(".LBL_CANCEL_BUTTON_TITLE") %>' Runat="server" />
							</asp:TableCell>
							<asp:TableCell Width="80%"></asp:TableCell>
						</asp:TableRow>
						<asp:TableRow>
							<asp:TableCell VerticalAlign="top" ColumnSpan="4">
								<asp:Label Text='<%# L10n.Term("Rules.LBL_CONDITION") %>' CssClass="dataLabel" runat="server" /> <asp:Label Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' CssClass="required" runat="server" /><br />
								<asp:TextBox      ID="txtCONDITION"    TabIndex="14" TextMode="MultiLine" Rows="2" Columns="140" Runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="top" ColumnSpan="2">
								<br /><asp:Image ID="imgConditionSchema" SkinID="Schema" runat="server" />
								<asp:Panel ID="pnlConditionHover" style="display:none; overflow-x: auto; overflow-y: scroll; height: 350px; border: solid 1px black; background-color: White; color: Black;" runat="server">
									<asp:Repeater id="ctlConditionSchemaRepeater" runat="server">
										<ItemTemplate>
											<nobr><asp:HyperLink NavigateUrl='<%# "javascript:AppendConditionVariable(\"" + txtCONDITION.ClientID +  "\", \"" + Sql.ToString(Eval("ColumnName")) + "\", \"" + Sql.ToString(Eval("CsType")) + "\");" %>' Text='<%# Utils.TableColumnName(L10n, sImportModule, Sql.ToString(Eval("ColumnName"))) %>' CssClass="listViewCheckLink" Runat="server" /></nobr><br />
										</ItemTemplate>
									</asp:Repeater>
								</asp:Panel>
								<ajaxToolkit:HoverMenuExtender ID="hovCondition" TargetControlID="imgConditionSchema" PopupControlID="pnlConditionHover" PopupPosition="Bottom" PopDelay="50" runat="server" />
								<br />&nbsp;<asp:RequiredFieldValidator ID="reqCONDITION" ControlToValidate="txtCONDITION" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Enabled="false" Display="dynamic" Runat="server" />
							</asp:TableCell>
						</asp:TableRow>
						<asp:TableRow>
							<asp:TableCell VerticalAlign="top" ColumnSpan="4">
								<asp:Label Text='<%# L10n.Term("Rules.LBL_THEN_ACTIONS") %>' CssClass="dataLabel" runat="server" /> <asp:Label Text='<%# L10n.Term(".LBL_REQUIRED_SYMBOL") %>' CssClass="required" runat="server" /><br />
								<asp:TextBox      ID="txtTHEN_ACTIONS" TabIndex="15" TextMode="MultiLine" Rows="3" Columns="140" Runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="top" ColumnSpan="2">
								<br /><asp:Image ID="imgThenSchema" SkinID="Schema" runat="server" />
								<asp:Panel ID="pnlThenHover" style="display:none; overflow-x: auto; overflow-y: scroll; height: 350px; border: solid 1px black; background-color: White; color: Black;" runat="server">
									<asp:Repeater id="ctlThenSchemaRepeater" runat="server">
										<ItemTemplate>
											<nobr><asp:HyperLink NavigateUrl='<%# "javascript:AppendRuleVariable(\"" + txtTHEN_ACTIONS.ClientID +  "\", \"" + Sql.ToString(Eval("ColumnName")) + "\");" %>' Text='<%# Utils.TableColumnName(L10n, sImportModule, Sql.ToString(Eval("ColumnName"))) %>' CssClass="listViewCheckLink" Runat="server" /></nobr><br />
										</ItemTemplate>
									</asp:Repeater>
								</asp:Panel>
								<ajaxToolkit:HoverMenuExtender TargetControlID="imgThenSchema" PopupControlID="pnlThenHover" PopupPosition="Bottom" PopDelay="50" runat="server" />
								<br />&nbsp;<asp:RequiredFieldValidator ID="reqTHEN_ACTIONS" ControlToValidate="txtTHEN_ACTIONS" ErrorMessage='<%# L10n.Term(".ERR_REQUIRED_FIELD") %>' CssClass="required" EnableClientScript="false" EnableViewState="false" Enabled="false" Display="dynamic" Runat="server" />
							</asp:TableCell>
						</asp:TableRow>
						<asp:TableRow>
							<asp:TableCell VerticalAlign="top" ColumnSpan="4">
								<asp:Label Text='<%# L10n.Term("Rules.LBL_ELSE_ACTIONS") %>' CssClass="dataLabel" runat="server" /><br />
								<asp:TextBox      ID="txtELSE_ACTIONS" TabIndex="16" TextMode="MultiLine" Rows="3" Columns="140" Runat="server" />
							</asp:TableCell>
							<asp:TableCell VerticalAlign="top" ColumnSpan="2">
								<br /><asp:Image ID="imgElseSchema" SkinID="Schema" runat="server" />
								<asp:Panel ID="pnlElseHover" style="display:none; overflow-x: auto; overflow-y: scroll; height: 350px; border: solid 1px black; background-color: White; color: Black;" runat="server">
									<asp:Repeater id="ctlElseSchemaRepeater" runat="server">
										<ItemTemplate>
											<nobr><asp:HyperLink NavigateUrl='<%# "javascript:AppendRuleVariable(\"" + txtELSE_ACTIONS.ClientID +  "\", \"" + Sql.ToString(Eval("ColumnName")) + "\");" %>' Text='<%# Utils.TableColumnName(L10n, sImportModule, Sql.ToString(Eval("ColumnName"))) %>' CssClass="listViewCheckLink" Runat="server" /></nobr><br />
										</ItemTemplate>
									</asp:Repeater>
								</asp:Panel>
								<ajaxToolkit:HoverMenuExtender TargetControlID="imgElseSchema" PopupControlID="pnlElseHover" PopupPosition="Bottom" PopDelay="50" runat="server" />
								<br />
							</asp:TableCell>
						</asp:TableRow>
					</asp:Table>
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</div>
	<div id="divImportStep7" style="DISPLAY: none">
		<asp:Table SkinID="tabForm" runat="server">
			<asp:TableRow>
				<asp:TableCell>
					<asp:Label ID="lblStatus"         Font-Bold="true" runat="server" /><br />
					<asp:Label ID="lblSuccessCount"   runat="server" /><br />
					<asp:Label ID="lblDuplicateCount" runat="server" /><br />
					<asp:Label ID="lblFailedCount"    runat="server" /> &nbsp; <asp:HyperLink ID="lnkExportErrors" Visible="false" runat="server" /><br />
					<br />
					<%= L10n.Term("Import.LBL_USE_TRANSACTION") %><asp:CheckBox ID="chkUseTransaction" Checked="True" CssClass="checkbox" runat="server" />
					<br />
					<SplendidCRM:ListHeader ID="ctlListHeader" Visible="<%# !PrintView %>" Title="Import.LBL_LAST_IMPORTED" Runat="Server" />
					<SplendidCRM:SplendidGrid id="grdMain" AllowPaging="<%# !PrintView %>" AllowSorting="true" EnableViewState="true" runat="server">
					</SplendidCRM:SplendidGrid>
				</asp:TableCell>
			</asp:TableRow>
		</asp:Table>
	</div>
	<br />
	<script type="text/javascript">
		SelectWizardTab(<%= txtACTIVE_TAB.Value %>);
		SelectSourceFormat();
	</script>
<%
if ( bDebug )
{
	Response.Write("<div style=\"width: 1200; border: 1px solid black; overflow: hidden; \">");
	XmlUtil.Dump(xmlMapping);
	Response.Write("</div>");
	Response.Write("<br />");

	/*
	Response.Write("<div style=\"width: 1200; border: 1px solid black; overflow: hidden; \">");
	XmlUtil.Dump(xml);
	Response.Write("</div>");
	Response.Write("<br />");
	*/

	Response.Write("<div style=\"width: 1200; border: 1px solid black; overflow: hidden; \">");
	Response.Write("<pre>");
	Response.Write(sbImport.ToString());
	Response.Write("</pre>");
	Response.Write("</div>");
}
%>
</div>

