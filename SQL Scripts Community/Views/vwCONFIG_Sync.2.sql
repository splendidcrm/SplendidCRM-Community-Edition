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
-- 12/26/2022 Paul.  Instead of returning secret values, return empty password **********. 
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
     , (case
        when VALUE is null then null
	else (case
              when NAME in   ('AmazonAWS.AccessKeyID', 'AmazonAWS.SecretAccessKey', 'AmazonAWS.X509Certificate', 'AmazonAWS.X509Password', 'AmazonAWS.X509PrivateKey') then '**********'
              when NAME in   ('AmazonS3.AccessKeyID', 'AmazonS3.SecretAccessKey') then '**********'
              when NAME in   ('CreditCardIV', 'CreditCardKey') then '**********'
              when NAME in   ('InboundEmailIV', 'InboundEmailKey') then '**********'
              when NAME in   ('PaymentGateway_Login', 'PaymentGateway_Password') then '**********'
              when NAME in   ('PayPal.APIPassword', 'PayPal.APIUsername', 'PayPal.ClientID', 'PayPal.ClientSecret', 'PayPal.X509Certificate', 'PayPal.X509PrivateKey') then '**********'
              when NAME in   ('smtpuser', 'smtppass', 'smtpcertificate') then '**********'
              when NAME in   ('Exchange.ClientSecret', 'Exchange.Password', 'Exchange.UserName') then '**********'
              when NAME in   ('facebook.AppID', 'facebook.AppSecret') then '**********'
              when NAME in   ('GoogleApps.ApiKey', 'GoogleApps.ClientSecret', 'GoogleMaps.Key') then '**********'
              when NAME in   ('Twitter.AccessToken', 'Twitter.AccessTokenSecret', 'Twitter.ConsumerKey', 'Twitter.ConsumerSecret') then '**********'
              when NAME in   ('LinkedIn.APIKey', 'LinkedIn.SecretKey') then '**********'
              when NAME in   ('Salesforce.ConsumerKey', 'Salesforce.ConsumerSecret') then '**********'
              when NAME in   ('QuickBooks.ConnectionString', 'QuickBooks.OAuthAccessToken', 'QuickBooks.OAuthAccessTokenSecret', 'QuickBooks.OAuthClientID', 'QuickBooks.OAuthClientSecret', 'QuickBooks.OAuthCompanyID', 'QuickBooks.OAuthCountryCode', 'QuickBooks.OAuthExpiresAt', 'QuickBooks.OAuthVerifier', 'QuickBooks.RemotePassword', 'QuickBooks.RemoteURL', 'QuickBooks.RemoteUser') then '**********'
              when NAME in   ('PayTrace.UserName', 'PayTrace.Password') then '**********'
              when NAME in   ('Asterisk.UserName', 'Asterisk.Password') then '**********'
              when NAME in   ('Twilio.AccountSID', 'Twilio.AuthToken') then '**********'
              when NAME in   ('Avaya.Certificate', 'Avaya.UserName', 'Avaya.Password') then '**********'
              when NAME in   ('MicrosoftTranslator.ClientID', 'MicrosoftTranslator.ClientSecret', 'MicrosoftTranslator.Key') then '**********'
              when NAME in   ('ZipTaxAPI.Key') then '**********'
              when NAME in   ('HubSpot.ClientID', 'HubSpot.ClientSecret', 'HubSpot.OAuthAccessToken', 'HubSpot.OAuthClientSecret', 'HubSpot.OAuthExpiresAt', 'HubSpot.OAuthRefreshToken', 'HubSpot.PortalID') then '**********'
              when NAME in   ('ConstantContact.ClientID', 'ConstantContact.ClientSecret', 'ConstantContact.OAuthAccessToken', 'ConstantContact.OAuthClientSecret', 'ConstantContact.OAuthExpiresAt', 'ConstantContact.OAuthRefreshToken') then '**********'
              when NAME in   ('iContact.ApiAppId', 'iContact.ApiPassword', 'iContact.ApiUsername') then '**********'
              when NAME in   ('Marketo.ClientID', 'Marketo.ClientSecret', 'Marketo.OAuthAccessToken', 'Marketo.OAuthClientSecret', 'Marketo.OAuthExpiresAt', 'Marketo.OAuthRefreshToken') then '**********'
              when NAME in   ('MailChimp.ClientID', 'MailChimp.ClientSecret', 'MailChimp.OAuthAccessToken', 'MailChimp.OAuthClientSecret') then '**********'
              when NAME in   ('CurrencyLayer.AccessKey') then '**********'
              when NAME in   ('AuthorizeNet.UserName', 'AuthorizeNet.Password', 'AuthorizeNet.TransactionKey') then '**********'
              when NAME in   ('Azure.AadClientId', 'Azure.AadTenantDomain', 'Azure.ServiceAccountPassword', 'Azure.ServiceAccountUserName', 'Azure.SqlAdminPassword', 'Azure.SqlAdminUserName', 'Azure.SubscriptionId', 'Azure.VmAdminPassword', 'Azure.VmAdminUserName') then '**********'
              when NAME in   ('Pardot.ApiUsername', 'Pardot.ApiUserKey', 'Pardot.ApiPassword', 'Pardot.ApiAppId', 'Pardot.PardotAccountId', 'Pardot.PardotClientFolderId') then '**********'
              when NAME in   ('GetResponse.SecretApiKey') then '**********'
              when NAME in   ('SalesFusion.UserName', 'SalesFusion.Password', 'SalesFusion.Domain') then '**********'
              when NAME in   ('Watson.ClientID', 'Watson.ClientSecret', 'Watson.OAuthAccessToken', 'Watson.OAuthRefreshToken', 'Watson.OAuthExpiresAt') then '**********'
              when NAME in   ('FreshBooks.ApiToken') then '**********'
              when NAME in   ('PhoneBurner.ClientSecret', 'PhoneBurner.OAuthAccessToken', 'PhoneBurner.OAuthClientSecret', 'PhoneBurner.OAuthExpiresAt', 'PhoneBurner.OAuthRefreshToken') then '**********'
              when NAME in   ('enable_reminder_popdowns', 'enable_email_reminders', 'default_password') then '**********'
              when NAME like '%Password'      then '**********'
              when NAME like '%.UserName'     then '**********'
              when NAME like '%.ClientSecret' then '**********'
              when NAME like '%.ApiKey'       then '**********'
              when NAME like '%.OAuth%'       then '**********'
              when NAME like 'ADFS%'          then '**********'
              else VALUE
              end)
        end) as VALUE
  from CONFIG
GO

Grant Select on dbo.vwCONFIG_Sync to public;
GO

