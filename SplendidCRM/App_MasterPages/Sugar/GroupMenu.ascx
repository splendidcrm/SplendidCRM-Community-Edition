<%@ Control Language="c#" AutoEventWireup="false" Codebehind="GroupMenu.ascx.cs" Inherits="SplendidCRM.Themes.Sugar.GroupMenu" TargetSchema="http://schemas.microsoft.com/intellisense/ie5"%>
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
<script type="text/javascript">
var sSplendidMenuActiveGroupName = '';
function GroupMenuActivateTab(sNewGroupName)
{
	if ( sSplendidMenuActiveGroupName != sNewGroupName )
	{
		if ( sSplendidMenuActiveGroupName != '' )
		{
			var tdOldTabLeft   = document.getElementById('GroupMenu' + sSplendidMenuActiveGroupName + 'Left'  );
			var tdOldTabMiddle = document.getElementById('GroupMenu' + sSplendidMenuActiveGroupName + 'Middle');
			var tdOldTabRight  = document.getElementById('GroupMenu' + sSplendidMenuActiveGroupName + 'Right' );
			tdOldTabLeft.className   = 'otherTabLeft'   ;
			tdOldTabMiddle.className = 'otherTab'       ;
			tdOldTabRight.className  = 'otherTabRight'  ;
		}
		// 02/25/2010 Paul.  There is a blank SubMenu, so we will always hide something. 
		var tblOldSubMenu  = document.getElementById('SubMenu'   + sSplendidMenuActiveGroupName);
		tblOldSubMenu.style.display = 'none'  ;
		
		var tdNewTabLeft   = document.getElementById('GroupMenu' + sNewGroupName + 'Left'  );
		var tdNewTabMiddle = document.getElementById('GroupMenu' + sNewGroupName + 'Middle');
		var tdNewTabRight  = document.getElementById('GroupMenu' + sNewGroupName + 'Right' );
		var tblNewSubMenu  = document.getElementById('SubMenu'   + sNewGroupName);

		tdNewTabLeft.className   = 'currentTabLeft' ;
		tdNewTabMiddle.className = 'currentTab'     ;
		tdNewTabRight.className  = 'currentTabRight';
		tblNewSubMenu.style.display = 'inline';
		sSplendidMenuActiveGroupName = sNewGroupName;
	}
}
</script>
<%= Session["SplendidGroupMenuHtml"] %>
<script type='text/javascript'>GroupMenuActivateTab('<%= sActiveGroup %>');</script>

