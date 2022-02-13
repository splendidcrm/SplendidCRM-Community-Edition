<%@ Control Language="c#" AutoEventWireup="false" Codebehind="FacebookButtons.ascx.cs" Inherits="SplendidCRM.Users.FacebookButtons" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
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
				FB.api('/me', function(response)
				{
					if ( response.id !== undefined )
					{
						var sID        = response.id;
						var sName      = (response.name       !== undefined) ? response.name       : '';
						var sFirstName = (response.first_name !== undefined) ? response.first_name : '';
						var sLastName  = (response.last_name  !== undefined) ? response.last_name  : '';
						var sLink      = (response.link       !== undefined) ? response.link       : '';
						var sBirthday  = (response.birthday   !== undefined) ? response.birthday   : '';
						var sGender    = (response.gender     !== undefined) ? response.gender     : '';
						var sEmail     = (response.email      !== undefined) ? response.email      : '';
						var sTimezone  = (response.timezone   !== undefined) ? response.timezone   : '';
						var sLocale    = (response.locale     !== undefined) ? response.locale     : '';
						var fldFACEBOOK_ID = document.getElementById('<%= sFACEBOOK_ID %>');
						if ( fldFACEBOOK_ID!= null )
						{
							fldFACEBOOK_ID.value = sID;
							fldFACEBOOK_ID.focus();
						}
					}
				});
			}
			, perms='email'
		);
	}
</script>
