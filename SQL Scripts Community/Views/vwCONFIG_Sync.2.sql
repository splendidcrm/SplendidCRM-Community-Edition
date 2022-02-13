if exists (select * from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwCONFIG_Sync')
	Drop View dbo.vwCONFIG_Sync;
GO


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
 *********************************************************************************************************************/
-- 11/21/2009 Paul.  We need to exclude sensitive data from the offline client. 
-- 03/23/2010 Paul.  Exchange settings will not be synchronized. 
-- 03/19/2011 Paul.  facebook settings will not be synchronized. 
-- 06/05/2011 Paul.  Google settings will not be synchronized. 
-- 10/24/2011 Paul.  Exclude more. 
-- 04/15/2012 Paul.  Excluded Twitter and LinkedIn. 
-- 04/22/2012 Paul.  Excluded Salesforce. 
-- 05/28/2012 Paul.  Excluded QuickBooks. 
-- 12/25/2012 Paul.  Exclude reminder flags. 
-- 09/20/2013 Paul.  Exclude PayTrace, Asterisk and Twilio. 
-- 08/24/2014 Paul.  Exclude Avaya, MicrosoftTranslator, Password, ZipTaxAPI. 
-- 09/05/2015 Paul.  Exclude HubSpot, ConstantContact, iContact, Marketo, GetResource, GoogleApps
-- 05/01/2016 Paul.  Exclude MailChimp, CurrencyLayer, AuthorizeNet. 
-- 01/14/2017 Paul.  Exclude Azure and ADFS. 
-- 08/05/2017 Paul.  Exclude Pardot. 
-- 05/17/2019 Paul.  Exclude GetResponse, SalesFusion, Watson. 
-- 05/26/2020 Paul.  Exclude specific keys so that we can see the Enable flags. 
-- 07/13/2020 Paul.  Exchange.ClientID and GoogleApps.ClientID are needed by the user profile editor. 
-- 09/05/2020 Paul.  Exclude PhoneBurner. 
-- 09/12/2020 Paul.  PhoneBurner.ClientID is needed in the React Client to authorize. 
-- 09/20/2020 Paul.  Allow Avaya.Host so that we can check if enabled in React Client. 
-- 09/25/2020 Paul.  Allow Twitter.ConsumerKey so that we can check if enabled in React Client. 
-- 03/14/2021 Paul.  smtpserver and smtpport are needed by the React Client. 
-- 03/17/2021 Paul.  PaymentGateway_ID is not confidencial as it is our own ID and it is needed by React Client. 
Create View dbo.vwCONFIG_Sync
as
select ID
     , DELETED
     , CREATED_BY
     , DATE_ENTERED
     , MODIFIED_USER_ID
     , DATE_MODIFIED
     , DATE_MODIFIED_UTC
     , CATEGORY
     , NAME
     , VALUE
  from CONFIG
 where NAME not in   ('AmazonAWS.AccessKeyID', 'AmazonAWS.SecretAccessKey', 'AmazonAWS.X509Certificate', 'AmazonAWS.X509Password', 'AmazonAWS.X509PrivateKey')
   and NAME not in   ('AmazonS3.AccessKeyID', 'AmazonS3.SecretAccessKey')
   and NAME not in   ('CreditCardIV', 'CreditCardKey')
   and NAME not in   ('InboundEmailIV', 'InboundEmailKey')
   and NAME not in   ('PaymentGateway_Login', 'PaymentGateway_Password')
   and NAME not in   ('PayPal.APIPassword', 'PayPal.APIUsername', 'PayPal.ClientID', 'PayPal.ClientSecret', 'PayPal.X509Certificate', 'PayPal.X509PrivateKey')
   and NAME not in   ('smtpuser', 'smtppass', 'smtpcertificate')
   and NAME not in   ('Exchange.ClientSecret', 'Exchange.Password', 'Exchange.UserName')
   and NAME not in   ('facebook.AppID', 'facebook.AppSecret')
   and NAME not in   ('GoogleApps.ApiKey', 'GoogleApps.ClientSecret', 'GoogleMaps.Key')
   and NAME not in   ('Twitter.AccessToken', 'Twitter.AccessTokenSecret', 'Twitter.ConsumerKey', 'Twitter.ConsumerSecret')
   and NAME not in   ('LinkedIn.APIKey', 'LinkedIn.SecretKey')
   and NAME not in   ('Salesforce.ConsumerKey', 'Salesforce.ConsumerSecret')
   and NAME not in   ('QuickBooks.ConnectionString', 'QuickBooks.OAuthAccessToken', 'QuickBooks.OAuthAccessTokenSecret', 'QuickBooks.OAuthClientID', 'QuickBooks.OAuthClientSecret', 'QuickBooks.OAuthCompanyID', 'QuickBooks.OAuthCountryCode', 'QuickBooks.OAuthExpiresAt', 'QuickBooks.OAuthVerifier', 'QuickBooks.RemotePassword', 'QuickBooks.RemoteURL', 'QuickBooks.RemoteUser')
   and NAME not in   ('PayTrace.UserName', 'PayTrace.Password')
   and NAME not in   ('Asterisk.UserName', 'Asterisk.Password')
   and NAME not in   ('Twilio.AccountSID', 'Twilio.AuthToken')
   and NAME not in   ('Avaya.Certificate', 'Avaya.UserName', 'Avaya.Password')
   and NAME not in   ('MicrosoftTranslator.ClientID', 'MicrosoftTranslator.ClientSecret', 'MicrosoftTranslator.Key')
   and NAME not in   ('ZipTaxAPI.Key')
   and NAME not in   ('HubSpot.ClientID', 'HubSpot.ClientSecret', 'HubSpot.OAuthAccessToken', 'HubSpot.OAuthClientSecret', 'HubSpot.OAuthExpiresAt', 'HubSpot.OAuthRefreshToken', 'HubSpot.PortalID')
   and NAME not in   ('ConstantContact.ClientID', 'ConstantContact.ClientSecret', 'ConstantContact.OAuthAccessToken', 'ConstantContact.OAuthClientSecret', 'ConstantContact.OAuthExpiresAt', 'ConstantContact.OAuthRefreshToken')
   and NAME not in   ('iContact.ApiAppId', 'iContact.ApiPassword', 'iContact.ApiUsername')
   and NAME not in   ('Marketo.ClientID', 'Marketo.ClientSecret', 'Marketo.OAuthAccessToken', 'Marketo.OAuthClientSecret', 'Marketo.OAuthExpiresAt', 'Marketo.OAuthRefreshToken')
   and NAME not in   ('MailChimp.ClientID', 'MailChimp.ClientSecret', 'MailChimp.OAuthAccessToken', 'MailChimp.OAuthClientSecret')
   and NAME not in   ('CurrencyLayer.AccessKey')
   and NAME not in   ('AuthorizeNet.UserName', 'AuthorizeNet.Password', 'AuthorizeNet.TransactionKey')
   and NAME not in   ('Azure.AadClientId', 'Azure.AadTenantDomain', 'Azure.ServiceAccountPassword', 'Azure.ServiceAccountUserName', 'Azure.SqlAdminPassword', 'Azure.SqlAdminUserName', 'Azure.SubscriptionId', 'Azure.VmAdminPassword', 'Azure.VmAdminUserName')
   and NAME not in   ('Pardot.ApiUsername', 'Pardot.ApiUserKey', 'Pardot.ApiPassword', 'Pardot.ApiAppId', 'Pardot.PardotAccountId', 'Pardot.PardotClientFolderId')
   and NAME not in   ('GetResponse.SecretApiKey')
   and NAME not in   ('SalesFusion.UserName', 'SalesFusion.Password', 'SalesFusion.Domain')
   and NAME not in   ('Watson.ClientID', 'Watson.ClientSecret', 'Watson.OAuthAccessToken', 'Watson.OAuthRefreshToken', 'Watson.OAuthExpiresAt')
   and NAME not in   ('FreshBooks.ApiToken')
   and NAME not in   ('PhoneBurner.ClientSecret', 'PhoneBurner.OAuthAccessToken', 'PhoneBurner.OAuthClientSecret', 'PhoneBurner.OAuthExpiresAt', 'PhoneBurner.OAuthRefreshToken')
   and NAME not in   ('enable_reminder_popdowns', 'enable_email_reminders', 'default_password')
   and NAME not like '%Password'
   and NAME not like '%.UserName'
   and NAME not like '%.ClientSecret'
   and NAME not like '%.ApiKey'
   and NAME not like '%.OAuth%'
   and NAME not like 'ADFS%'
GO

Grant Select on dbo.vwCONFIG_Sync to public;
GO

