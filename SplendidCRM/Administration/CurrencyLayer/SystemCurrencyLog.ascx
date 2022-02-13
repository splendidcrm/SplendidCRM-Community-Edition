<%@ Control CodeBehind="SystemCurrencyLog.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.CurrencyLayer.SystemCurrencyLog" %>
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
<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
<SplendidCRM:ListHeader SubPanel="divCurrencyLayerSystemCurrencyLog" Title="CurrencyLayer.LBL_SYSTEM_CURRENCY_LOG" Runat="Server" />

<div id="divCurrencyLayerSystemCurrencyLog" style='<%= "display:" + (CookieValue("divCurrencyLayerSystemCurrencyLog") != "1" ? "inline" : "none") %>'>
	<%@ Register TagPrefix="SplendidCRM" Tagname="DynamicButtons" Src="~/_controls/DynamicButtons.ascx" %>
	<SplendidCRM:DynamicButtons ID="ctlDynamicButtons" Runat="Server" />

	<SplendidCRM:SplendidGrid id="grdMain" SkinID="grdListView" AllowPaging="<%# !PrintView %>" EnableViewState="true" runat="server">
		<Columns>
			<asp:BoundColumn     HeaderText=".LBL_LIST_DATE_ENTERED"                     DataField="DATE_ENTERED"        SortExpression="DATE_ENTERED"        DataFormatString="{0:G}" />
			<asp:BoundColumn     HeaderText=".LBL_LIST_CREATED_BY"                       DataField="CREATED_BY"          SortExpression="CREATED_BY"          />
			<asp:BoundColumn     HeaderText="CurrencyLayer.LBL_LIST_SOURCE_ISO4217"      DataField="SOURCE_ISO4217"      SortExpression="SOURCE_ISO4217"      />
			<asp:BoundColumn     HeaderText="CurrencyLayer.LBL_LIST_DESTINATION_ISO4217" DataField="DESTINATION_ISO4217" SortExpression="DESTINATION_ISO4217" />
			<asp:BoundColumn     HeaderText="CurrencyLayer.LBL_LIST_CONVERSION_RATE"     DataField="CONVERSION_RATE"     SortExpression="CONVERSION_RATE"     DataFormatString="{0:F3}" />
		</Columns>
	</SplendidCRM:SplendidGrid>
</div>
