/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

export default interface USER_PROFILE
{
	USER_ID                       : string;
	// 07/15/2021 Paul.  React Client needs to access the ASP.NET_SessionId. 
	USER_SESSION                  : string;
	USER_NAME                     : string;
	FULL_NAME                     : string;
	TEAM_ID                       : string;
	TEAM_NAME                     : string;
	USER_LANG                     : string;
	USER_DATE_FORMAT              : string;
	USER_TIME_FORMAT              : string;
	USER_THEME                    : string;
	USER_CURRENCY_ID              : string;
	USER_TIMEZONE_ID              : string;
	// 10/28/2021 Paul.  This is our indicator to redirect to User Wizard. 
	ORIGINAL_TIMEZONE_ID          : string;
	PICTURE                       : string;
	USER_EXTENSION                : string;
	USER_FULL_NAME                : string;
	USER_PHONE_WORK               : string;
	USER_SMS_OPT_IN               : string;
	USER_PHONE_MOBILE             : string;
	USER_TWITTER_TRACKS           : string;
	USER_CHAT_CHANNELS            : string;
	USER_CurrencyDecimalDigits    : string;
	USER_CurrencyDecimalSeparator : string;
	USER_CurrencyGroupSeparator   : string;
	USER_CurrencyGroupSizes       : string;
	USER_CurrencyNegativePattern  : string;
	USER_CurrencyPositivePattern  : string;
	USER_CurrencySymbol           : string;
	// 01/22/2021 Paul.  Exchange Email is used to control some access. 
	EXCHANGE_ALIAS                : string;
	EXCHANGE_EMAIL                : string;
	// 01/22/2021 Paul.  Customizations may be based on the PRIMARY_ROLE_ID and not the name. 
	PRIMARY_ROLE_ID               : string;
	// 03/29/2021 Paul.  Allow display of impersonation state. 
	PRIMARY_ROLE_NAME             : string;
	// 03/02/2019 Paul.  We need to know if they are an admin or admin delegate. 
	IS_ADMIN                      : boolean;
	IS_ADMIN_DELEGATE             : boolean;
	// 05/07/2019 Paul.  Maintain SearchView state. 
	SAVE_QUERY                    : boolean;
	// 03/29/2021 Paul.  Allow display of impersonation state. 
	USER_IMPERSONATION            : boolean;
}

