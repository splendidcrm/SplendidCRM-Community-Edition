<%@ Control Language="c#" AutoEventWireup="false" Codebehind="FacebookLogin.ascx.cs" Inherits="SplendidCRM.Users.FacebookLogin" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
<div id="fb-root"></div>
<script type="text/javascript">
	window.fbAsyncInit = function()
	{
		FB.init(
		{
			appId: '<%= Application["CONFIG.facebook.AppID"] %>',
			status: true,
			cookie: true,
			xfbml: true
		});
	};
	
	(function()
	{
		var e = document.createElement('script');
		e.type = 'text/javascript';
		e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
		e.async = true;
		document.getElementById('fb-root').appendChild(e);
	}());
	
	function FBlogin()
	{
		// http://developers.facebook.com/docs/authentication/permissions/
		FB.login
		(
			function(response)
			{
				var fldFacebookLogin = document.getElementById('<%= btnFacebookLogin.ClientID %>');
				if ( fldFacebookLogin != null )
					fldFacebookLogin.click();
			}
			, perms='email'
		);
	}
</script>

<a class="fb_button fb_button_medium" onclick="FBlogin();"><span class="fb_button_text"><%= L10n.Term("Users.LBL_LOGIN_BUTTON_LABEL") %></span></a>
<asp:Button ID="btnFacebookLogin" CommandName="Login.Facebook" OnCommand="Page_Command" style="display: none;" runat="server" />
