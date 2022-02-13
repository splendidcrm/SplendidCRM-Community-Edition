<%@ Page language="c#" Codebehind="TwilioManagerHubJS.aspx.cs" AutoEventWireup="false" Inherits="SplendidCRM.JavaScript.TwilioManagerHubJS" %>
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
// 09/07/2013 Paul.  Put the labels in the javascript file because they will only change based on the language. 
// 11/06/2013 Paul.  Make sure to JavaScript escape the text as the various languages may introduce accents. 
</script>
<head visible="false" runat="server" />
var sLNK_VIEW                          = '<%# Sql.EscapeJavaScript(L10n.Term(".LNK_VIEW"                               )) %>';
var sLNK_EDIT                          = '<%# Sql.EscapeJavaScript(L10n.Term(".LNK_EDIT"                               )) %>';
var sLBL_CREATE_BUTTON_LABEL           = '<%# Sql.EscapeJavaScript(L10n.Term(".LBL_CREATE_BUTTON_LABEL"                )) %>';
var sLBL_TWILIO_CREATE_MESSAGE         = '<%# Sql.EscapeJavaScript(L10n.Term("Twilio.LBL_TWILIO_CREATE_MESSAGE"        )) %>';
var sLBL_TWILIO_INCOMING_MESSAGE       = '<%# Sql.EscapeJavaScript(L10n.Term("Twilio.LBL_TWILIO_INCOMING_MESSAGE"      )) %>';
var sLBL_NEW_INCOMING_MESSAGE_TEMPLATE = '<%# Sql.EscapeJavaScript(L10n.Term("Twilio.LBL_NEW_INCOMING_MESSAGE_TEMPLATE")) %>';

function TwilioStatusDialog(sTitle, sStatus)
{
	var divTwilioStatus = document.getElementById('divTwilioStatus');
	if ( divTwilioStatus == null )
	{
		var $dialog = $('<div id="divTwilioStatus"></div>');
		$dialog.dialog(
		{
			  modal    : false
			, resizable: false
			, width    : 300
			, height   : 100
			, position : { my: 'right bottom', at: 'right bottom', of: window }
			, title    : sTitle
			, create   : function(event, ui)
			{
				divTwilioStatus = document.getElementById('divTwilioStatus');
				divTwilioStatus.innerHTML = sStatus;
			}
			, close: function(event, ui)
			{
				$dialog.dialog('destroy');
				var divTwilioStatus = document.getElementById('divTwilioStatus');
				divTwilioStatus.parentNode.removeChild(divTwilioStatus);
			}
		});
	}
	else
	{
		divTwilioStatus.innerHTML = sStatus;
		$('#divTwilioStatus').dialog('option', 'title', sTitle);
	}
}

function TwilioCreateMessage(sMESSAGE_SID, sFROM_NUMBER, sTO_NUMBER, sSUBJECT)
{
	twilioManager.server.createSmsMessage(sMESSAGE_SID, sFROM_NUMBER, sTO_NUMBER, sSUBJECT).done(function(result)
	{
		window.location.href = sREMOTE_SERVER + 'SmsMessages/edit.aspx?ID=' + result;
	})
	.fail(function(e)
	{
		TwilioStatusDialog(sLBL_TWILIO_CREATE_MESSAGE, 'TwilioCreateMessage error: ' + e.message);
	});
}

function BuildMessageEditLinks(sSMS_MESSAGE_ID)
{
	var sMessageLinks = '';
	if ( sSMS_MESSAGE_ID != null && sSMS_MESSAGE_ID.length > 0 )
		sMessageLinks = ' &nbsp; <a href="' + sREMOTE_SERVER + 'SmsMessages/view.aspx?ID=' + sSMS_MESSAGE_ID + '">' + sLNK_VIEW + '</a> &nbsp; <a href="' + sREMOTE_SERVER + 'SmsMessages/edit.aspx?ID=' + sSMS_MESSAGE_ID + '">' + sLNK_EDIT + '</a>';
	return sMessageLinks;
}

function BuildMessageCreateLink(sMESSAGE_SID, sFROM_NUMBER, sTO_NUMBER, sSUBJECT)
{
	var sMessageLinks = '';
	sMessageLinks = ' &nbsp; <a href="#" onclick="TwilioCreateMessage(\'' + sMESSAGE_SID + '\', \'' + sFROM_NUMBER + '\', \'' + sTO_NUMBER + '\', \'' + escape(sSUBJECT) + '\'); return false;">' + sLBL_CREATE_BUTTON_LABEL + '</a>';
	return sMessageLinks;
}

var twilioManager = $.connection.TwilioManagerHub;

twilioManager.client.incomingMessage = function(sMESSAGE_SID, sFROM_NUMBER, sTO_NUMBER, sSUBJECT, sSMS_MESSAGE_ID)
{
	var sSUBJECT = sLBL_NEW_INCOMING_MESSAGE_TEMPLATE.replace('{0}', sFROM_NUMBER).replace('{1}', sSUBJECT);
	if ( sSMS_MESSAGE_ID != null && sSMS_MESSAGE_ID.length > 0 )
	{
		TwilioStatusDialog(sLBL_TWILIO_INCOMING_MESSAGE, sSUBJECT + BuildMessageEditLinks(sSMS_MESSAGE_ID));
	}
	else
	{
		TwilioStatusDialog(sLBL_TWILIO_INCOMING_MESSAGE, sSUBJECT + BuildMessageCreateLink(sMESSAGE_SID, sFROM_NUMBER, sTO_NUMBER, sSUBJECT));
	}
};

