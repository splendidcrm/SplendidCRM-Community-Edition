<%@ Page language="c#" MasterPageFile="~/PopupView.Master" Codebehind="OAuthLanding.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.Import.OAuthLanding" %>
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
<asp:Content ID="cntBody" ContentPlaceHolderID="cntBody" runat="server">
<script type="text/javascript">
function getQuerystring(key, default_)
{
	if ( default_ == null || typeof(default_) == 'undefined' )
		default_ = '';
	key = key.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
	// 04/13/2012 Paul.  For some odd reason, facebook is using # and not ? as the separator. 
	var regex = new RegExp("[\\?&#]"+key+"=([^&#]*)");
	var qs = regex.exec(window.location.href);
	if ( qs == null )
		return default_;
	else
		return qs[1];
}


window.onload = function()
{
	var divDebug = document.getElementById('divDebug');
	divDebug.innerHTML = window.location.href;
	try
	{
		var oauth_token    = getQuerystring('oauth_token'   );
		var oauth_verifier = getQuerystring('oauth_verifier');
		var access_token   = getQuerystring('access_token'  );
		var instance_url   = getQuerystring('instance_url'  );
		if ( access_token != '' )
			oauth_token = decodeURIComponent(access_token);
		if ( instance_url != '' )
			oauth_verifier = decodeURIComponent(instance_url);
		// 06/03/2014 Paul.  Extract the QuickBooks realmId (same as Company ID). 
		var realmId   = getQuerystring('realmId');
		// 04/23/2015 Paul.  HubSpot has more data. 
		var refresh_token  = getQuerystring('refresh_token' );
		var expires_in     = getQuerystring('expires_in'    );
		if ( refresh_token != '' )
			refresh_token = decodeURIComponent(refresh_token);

		window.opener.OAuthTokenUpdate(oauth_token, oauth_verifier, realmId, refresh_token, expires_in);
		window.close();
	}
	catch(e)
	{
		divDebug.innerHTML += '<p>' + e.message;
	}
}
</script>
<div id="divDebug"></div>
</asp:Content>
