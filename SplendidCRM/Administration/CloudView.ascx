<%@ Control CodeBehind="CloudView.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Administration.CloudView" %>
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
<div id="divCloudView" visible='<%# 
(  SplendidCRM.Security.AdminUserAccess("Facebook"       , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Google"         , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("LinkedIn"       , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Twitter"        , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Salesforce"     , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("QuickBooks"     , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Twilio"         , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("OutboundSms"    , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("HubSpot"        , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("iContact"       , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("ConstantContact", "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("GetResponse"    , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Marketo"        , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("MailChimp"      , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("CurrencyLayer"  , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Pardot"         , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("Watson"         , "access") >= 0 
|| SplendidCRM.Security.AdminUserAccess("PhoneBurner"    , "access") >= 0 
) %>' runat="server">
	<%@ Register TagPrefix="SplendidCRM" Tagname="ListHeader" Src="~/_controls/ListHeader.ascx" %>
	<SplendidCRM:ListHeader Title="Administration.LBL_CLOUD_SERVICES_TITLE" Runat="Server" />
	<asp:Table Width="100%" CssClass="tabDetailView2" runat="server">
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Facebook", "edit") >= 0 %>'>
				<asp:Image SkinID="facebook" AlternateText='<%# L10n.Term("Facebook.LBL_MANAGE_FACEBOOK_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Facebook.LBL_MANAGE_FACEBOOK_TITLE") %>' NavigateUrl="~/Administration/Facebook/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Facebook", "edit") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Facebook.LBL_MANAGE_FACEBOOK") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Google", "edit") >= 0 %>'>
				<asp:Image ID="imgGOOGLE" SkinID="Google" AlternateText='<%# L10n.Term("Google.LBL_MANAGE_GOOGLE_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink ID="lnkGOOGLE" Text='<%# L10n.Term("Google.LBL_MANAGE_GOOGLE_TITLE") %>' NavigateUrl="~/Administration/Google/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Google", "edit") >= 0 %>'>
				<asp:Label ID="lblGOOGLE" Text='<%# L10n.Term("Google.LBL_MANAGE_GOOGLE") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("LinkedIn", "edit") >= 0 %>'>
				<asp:Image SkinID="LinkedIn" AlternateText='<%# L10n.Term("LinkedIn.LBL_MANAGE_LINKEDIN_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("LinkedIn.LBL_MANAGE_LINKEDIN_TITLE") %>' NavigateUrl="~/Administration/LinkedIn/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("LinkedIn", "edit") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("LinkedIn.LBL_MANAGE_LINKEDIN") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Twitter", "edit") >= 0 %>'>
				<asp:Image SkinID="Twitter" AlternateText='<%# L10n.Term("Twitter.LBL_MANAGE_TWITTER_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Twitter.LBL_MANAGE_TWITTER_TITLE") %>' NavigateUrl="~/Administration/Twitter/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Twitter", "edit") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Twitter.LBL_MANAGE_TWITTER") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Salesforce", "edit") >= 0 %>'>
				<asp:Image SkinID="Salesforce" AlternateText='<%# L10n.Term("Salesforce.LBL_MANAGE_SALESFORCE_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Salesforce.LBL_MANAGE_SALESFORCE_TITLE") %>' NavigateUrl="~/Administration/Salesforce/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Salesforce", "edit") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("Salesforce.LBL_MANAGE_SALESFORCE") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("QuickBooks", "edit") >= 0 %>'>
				<asp:Image ID="imgQuickBooks" SkinID="QuickBooks" AlternateText='<%# L10n.Term("QuickBooks.LBL_MANAGE_QUICKBOOKS_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink ID="lnkQuickBooks" Text='<%# L10n.Term("QuickBooks.LBL_MANAGE_QUICKBOOKS_TITLE") %>' NavigateUrl="~/Administration/QuickBooks/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("QuickBooks", "edit") >= 0 %>'>
				<asp:Label ID="lblQuickBooks" Text='<%# L10n.Term("QuickBooks.LBL_MANAGE_QUICKBOOKS") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Twilio", "edit") >= 0 %>'>
				<asp:Image ImageUrl='<%# Session["themeURL"] + "images/Twilio.gif" %>' AlternateText='<%# L10n.Term("Twilio.LBL_TWILIO_SETTINGS") %>' BorderWidth="0" Width="16" Height="16" ImageAlign="AbsMiddle" Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Twilio.LBL_TWILIO_SETTINGS") %>' NavigateUrl="~/Administration/Twilio/config.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Twilio", "edit") >= 0 %>'>
				<%= L10n.Term("Twilio.LBL_TWILIO_SETTINGS_DESC") %>
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Twilio", "edit") >= 0 %>'>
				<asp:Image ImageUrl='<%# Session["themeURL"] + "images/Twilio.gif" %>' AlternateText='<%# L10n.Term("Twilio.LBL_TWILIO_MESSAGES") %>' BorderWidth="0" Width="16" Height="16" ImageAlign="AbsMiddle" Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("Twilio.LBL_TWILIO_MESSAGES") %>' NavigateUrl="~/Administration/Twilio/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Twilio", "edit") >= 0 %>'>
				<%= L10n.Term("Twilio.LBL_TWILIO_MESSAGES_DESC") %>
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("OutboundSms", "edit") >= 0 %>'>
				<asp:Image SkinID="OutboundSms" AlternateText='<%# L10n.Term("OutboundSms.LBL_MANAGE_OUTBOUND_SMS") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink Text='<%# L10n.Term("OutboundSms.LBL_MANAGE_OUTBOUND_SMS") %>' NavigateUrl="~/Administration/OutboundSms/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("OutboundSms", "edit") >= 0 %>'>
				<asp:Label Text='<%# L10n.Term("OutboundSms.LBL_MANAGE_OUTBOUND_SMS_DESC") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("HubSpot", "edit") >= 0 %>'>
				<asp:Image ID="imgHubSpot" SkinID="HubSpot" AlternateText='<%# L10n.Term("HubSpot.LBL_MANAGE_HUBSPOT_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink ID="lnkHubSpot" Text='<%# L10n.Term("HubSpot.LBL_MANAGE_HUBSPOT_TITLE") %>' NavigateUrl="~/Administration/HubSpot/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("HubSpot", "edit") >= 0 %>'>
				<asp:Label ID="lblHubSpot" Text='<%# L10n.Term("HubSpot.LBL_MANAGE_HUBSPOT") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("iContact", "edit") >= 0 %>'>
				<asp:Image ID="imgiContact" SkinID="iContact" AlternateText='<%# L10n.Term("iContact.LBL_MANAGE_ICONTACT_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink ID="lnkiContact" Text='<%# L10n.Term("iContact.LBL_MANAGE_ICONTACT_TITLE") %>' NavigateUrl="~/Administration/iContact/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("iContact", "edit") >= 0 %>'>
				<asp:Label ID="lbliContact" Text='<%# L10n.Term("iContact.LBL_MANAGE_ICONTACT") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("ConstantContact", "edit") >= 0 %>'>
				<asp:Image ID="imgConstantContact" SkinID="ConstantContact" AlternateText='<%# L10n.Term("ConstantContact.LBL_MANAGE_CONSTANTCONTACT_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink ID="lnkConstantContact" Text='<%# L10n.Term("ConstantContact.LBL_MANAGE_CONSTANTCONTACT_TITLE") %>' NavigateUrl="~/Administration/ConstantContact/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("ConstantContact", "edit") >= 0 %>'>
				<asp:Label ID="lblConstantContact" Text='<%# L10n.Term("ConstantContact.LBL_MANAGE_CONSTANTCONTACT") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Marketo", "edit") >= 0 %>'>
				<asp:Image ID="imgMarketo" SkinID="Marketo" AlternateText='<%# L10n.Term("Marketo.LBL_MANAGE_MARKETO_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink ID="lnkMarketo" Text='<%# L10n.Term("Marketo.LBL_MANAGE_MARKETO_TITLE") %>' NavigateUrl="~/Administration/Marketo/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Marketo", "edit") >= 0 %>'>
				<asp:Label ID="lblMarketo" Text='<%# L10n.Term("Marketo.LBL_MANAGE_MARKETO") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("MailChimp", "edit") >= 0 %>'>
				<asp:Image ID="imgMailChimp" SkinID="MailChimp" AlternateText='<%# L10n.Term("MailChimp.LBL_MANAGE_MAILCHIMP_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink ID="lnkMailChimp" Text='<%# L10n.Term("MailChimp.LBL_MANAGE_MAILCHIMP_TITLE") %>' NavigateUrl="~/Administration/MailChimp/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("MailChimp", "edit") >= 0 %>'>
				<asp:Label ID="lblMailChimp" Text='<%# L10n.Term("MailChimp.LBL_MANAGE_MAILCHIMP") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("CurrencyLayer", "edit") >= 0 %>'>
				<asp:Image ID="imgCurrencyLayer" SkinID="CurrencyLayer" AlternateText='<%# L10n.Term("CurrencyLayer.LBL_MANAGE_CURRENCYLAYER_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink ID="lnkCurrencyLayer" Text='<%# L10n.Term("CurrencyLayer.LBL_MANAGE_CURRENCYLAYER_TITLE") %>' NavigateUrl="~/Administration/CurrencyLayer/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("CurrencyLayer", "edit") >= 0 %>'>
				<asp:Label ID="lblCurrencyLayer" Text='<%# L10n.Term("CurrencyLayer.LBL_MANAGE_CURRENCYLAYER") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("GetResponse", "edit") >= 0 %>'>
				<asp:Image ID="imgGetResponse" SkinID="GetResponse" AlternateText='<%# L10n.Term("GetResponse.LBL_MANAGE_GETRESPONSE_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink ID="lnkGetResponse" Text='<%# L10n.Term("GetResponse.LBL_MANAGE_GETRESPONSE_TITLE") %>' NavigateUrl="~/Administration/GetResponse/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("GetResponse", "edit") >= 0 %>'>
				<asp:Label ID="lblGetResponse" Text='<%# L10n.Term("GetResponse.LBL_MANAGE_GETRESPONSE") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Pardot", "edit") >= 0 %>'>
				<asp:Image ID="imgPardot" SkinID="Pardot" AlternateText='<%# L10n.Term("Pardot.LBL_MANAGE_PARDOT_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink ID="lnkPardot" Text='<%# L10n.Term("Pardot.LBL_MANAGE_PARDOT_TITLE") %>' NavigateUrl="~/Administration/Pardot/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Pardot", "edit") >= 0 %>'>
				<asp:Label ID="lblPardot" Text='<%# L10n.Term("Pardot.LBL_MANAGE_PARDOT") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Watson", "edit") >= 0 %>'>
				<asp:Image ID="imgWatson" SkinID="Watson" AlternateText='<%# L10n.Term("Watson.LBL_MANAGE_WATSON_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink ID="lnkWatson" Text='<%# L10n.Term("Watson.LBL_MANAGE_WATSON_TITLE") %>' NavigateUrl="~/Administration/Watson/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("Watson", "edit") >= 0 %>'>
				<asp:Label ID="lblWatson" Text='<%# L10n.Term("Watson.LBL_MANAGE_WATSON") %>' runat="server" />
			</asp:TableCell>
		</asp:TableRow>
		<asp:TableRow>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2" Visible='<%# SplendidCRM.Security.AdminUserAccess("PhoneBurner", "edit") >= 0 %>'>
				<asp:Image ID="imgPhoneBurner" SkinID="PhoneBurner" AlternateText='<%# L10n.Term("PhoneBurner.LBL_MANAGE_PHONEBURNER_TITLE") %>' Runat="server" />
				&nbsp;
				<asp:HyperLink ID="lnkPhoneBurner" Text='<%# L10n.Term("PhoneBurner.LBL_MANAGE_PHONEBURNER_TITLE") %>' NavigateUrl="~/Administration/PhoneBurner/default.aspx" CssClass="tabDetailViewDL2Link" Runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2" Visible='<%# SplendidCRM.Security.AdminUserAccess("PhoneBurner", "edit") >= 0 %>'>
				<asp:Label ID="lblPhoneBurner" Text='<%# L10n.Term("PhoneBurner.LBL_MANAGE_PHONEBURNER") %>' runat="server" />
			</asp:TableCell>
			<asp:TableCell Width="20%" CssClass="tabDetailViewDL2">
			</asp:TableCell>
			<asp:TableCell Width="30%" CssClass="tabDetailViewDF2">
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
</div>

