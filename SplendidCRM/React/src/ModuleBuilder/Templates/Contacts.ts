/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

export default 
{
	DISPLAY_NAME  : 'Contacts',
	MODULE_NAME   : 'Contacts',
	TABLE_NAME    : 'CONTACTS',
	TAB_ENABLED   : true,
	MOBILE_ENABLED: true,
	CUSTOM_ENABLED: true,
	REPORT_ENABLED: true,
	IMPORT_ENABLED: true,
	REST_ENABLED  : true,
	IS_ADMIN      : false,
	IS_ASSIGNED   : true,
	"Relationships":
	[
		'Accounts'
	],
	"Fields":
	[
		{
			"FIELD_NAME":"ID",
			"EDIT_LABEL":"ID:",
			"LIST_LABEL":"ID",
			"DATA_TYPE":"Guid",
			"MAX_SIZE":16,
			"REQUIRED":true
		},
		{
			"FIELD_NAME":"DELETED",
			"EDIT_LABEL":"Deleted:",
			"LIST_LABEL":"Deleted",
			"DATA_TYPE":"Checkbox",
			"MAX_SIZE":1,
			"REQUIRED":true
		},
		{
			"FIELD_NAME":"CREATED_BY",
			"EDIT_LABEL":"Created By:",
			"LIST_LABEL":"Created By",
			"DATA_TYPE":"Guid",
			"MAX_SIZE":16,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"DATE_ENTERED",
			"EDIT_LABEL":"Date Entered:",
			"LIST_LABEL":"Date Entered",
			"DATA_TYPE":"Date",
			"MAX_SIZE":8,
			"REQUIRED":true
		},
		{
			"FIELD_NAME":"MODIFIED_USER_ID",
			"EDIT_LABEL":"Modified User ID:",
			"LIST_LABEL":"Modified User ID",
			"DATA_TYPE":"Guid",
			"MAX_SIZE":16,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"DATE_MODIFIED",
			"EDIT_LABEL":"Date Modified:",
			"LIST_LABEL":"Date Modified",
			"DATA_TYPE":"Date",
			"MAX_SIZE":8,
			"REQUIRED":true
		},
		{
			"FIELD_NAME":"ASSIGNED_USER_ID",
			"EDIT_LABEL":"Assigned User ID:",
			"LIST_LABEL":"Assigned User ID",
			"DATA_TYPE":"Guid",
			"MAX_SIZE":16,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"SALUTATION",
			"EDIT_LABEL":"Salutation:",
			"LIST_LABEL":"Salutation",
			"DATA_TYPE":"Dropdown",
			"MAX_SIZE":25,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"FIRST_NAME",
			"EDIT_LABEL":"First Name:",
			"LIST_LABEL":"First Name",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"LAST_NAME",
			"EDIT_LABEL":"Last Name:",
			"LIST_LABEL":"Last Name",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"LEAD_SOURCE",
			"EDIT_LABEL":"Lead Source:",
			"LIST_LABEL":"Lead Source",
			"DATA_TYPE":"Dropdown",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"TITLE",
			"EDIT_LABEL":"Title:",
			"LIST_LABEL":"Title",
			"DATA_TYPE":"Text",
			"MAX_SIZE":50,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"DEPARTMENT",
			"EDIT_LABEL":"Department:",
			"LIST_LABEL":"Department",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"REPORTS_TO_ID",
			"EDIT_LABEL":"Reports To ID:",
			"LIST_LABEL":"Reports To ID",
			"DATA_TYPE":"Guid",
			"MAX_SIZE":16,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"BIRTHDATE",
			"EDIT_LABEL":"Birthdate:",
			"LIST_LABEL":"Birthdate",
			"DATA_TYPE":"Date",
			"MAX_SIZE":8,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"DO_NOT_CALL",
			"EDIT_LABEL":"Do Not Call:",
			"LIST_LABEL":"Do Not Call",
			"DATA_TYPE":"Checkbox",
			"MAX_SIZE":1,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PHONE_HOME",
			"EDIT_LABEL":"Phone Home:",
			"LIST_LABEL":"Phone Home",
			"DATA_TYPE":"Text",
			"MAX_SIZE":25,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PHONE_MOBILE",
			"EDIT_LABEL":"Phone Mobile:",
			"LIST_LABEL":"Phone Mobile",
			"DATA_TYPE":"Text",
			"MAX_SIZE":25,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PHONE_WORK",
			"EDIT_LABEL":"Phone Work:",
			"LIST_LABEL":"Phone Work",
			"DATA_TYPE":"Text",
			"MAX_SIZE":25,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PHONE_OTHER",
			"EDIT_LABEL":"Phone Other:",
			"LIST_LABEL":"Phone Other",
			"DATA_TYPE":"Text",
			"MAX_SIZE":25,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PHONE_FAX",
			"EDIT_LABEL":"Phone Fax:",
			"LIST_LABEL":"Phone Fax",
			"DATA_TYPE":"Text",
			"MAX_SIZE":25,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"EMAIL1",
			"EDIT_LABEL":"Email:",
			"LIST_LABEL":"Email",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"EMAIL2",
			"EDIT_LABEL":"Other Email:",
			"LIST_LABEL":"Other Email",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"ASSISTANT",
			"EDIT_LABEL":"Assistant:",
			"LIST_LABEL":"Assistant",
			"DATA_TYPE":"Text",
			"MAX_SIZE":75,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"ASSISTANT_PHONE",
			"EDIT_LABEL":"Assistant Phone:",
			"LIST_LABEL":"Assistant Phone",
			"DATA_TYPE":"Text",
			"MAX_SIZE":25,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"EMAIL_OPT_OUT",
			"EDIT_LABEL":"Email Opt Out:",
			"LIST_LABEL":"Email Opt Out",
			"DATA_TYPE":"Checkbox",
			"MAX_SIZE":1,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PRIMARY_ADDRESS_STREET",
			"EDIT_LABEL":"Primary Street:",
			"LIST_LABEL":"Primary Street",
			"DATA_TYPE":"Text",
			"MAX_SIZE":150,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PRIMARY_ADDRESS_CITY",
			"EDIT_LABEL":"Primary City:",
			"LIST_LABEL":"Primary City",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PRIMARY_ADDRESS_STATE",
			"EDIT_LABEL":"Primary State:",
			"LIST_LABEL":"Primary State",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PRIMARY_ADDRESS_POSTALCODE",
			"EDIT_LABEL":"Primary Postal Code:",
			"LIST_LABEL":"Primary Postal Code",
			"DATA_TYPE":"Text",
			"MAX_SIZE":20,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PRIMARY_ADDRESS_COUNTRY",
			"EDIT_LABEL":"Primary Country:",
			"LIST_LABEL":"Primary Country",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"ALT_ADDRESS_STREET",
			"EDIT_LABEL":"Alternate Street:",
			"LIST_LABEL":"Alternate Street",
			"DATA_TYPE":"Text",
			"MAX_SIZE":150,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"ALT_ADDRESS_CITY",
			"EDIT_LABEL":"Alternate City:",
			"LIST_LABEL":"Alternate City",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"ALT_ADDRESS_STATE",
			"EDIT_LABEL":"Alternate State:",
			"LIST_LABEL":"Alternate State",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"ALT_ADDRESS_POSTALCODE",
			"EDIT_LABEL":"Alternate Postal Code:",
			"LIST_LABEL":"Alternate Postal Code",
			"DATA_TYPE":"Text",
			"MAX_SIZE":20,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"ALT_ADDRESS_COUNTRY",
			"EDIT_LABEL":"Alternate Country:",
			"LIST_LABEL":"Alternate Country",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"DESCRIPTION",
			"EDIT_LABEL":"Description:",
			"LIST_LABEL":"Description",
			"DATA_TYPE":"Text Area",
			"MAX_SIZE":1073741823,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PORTAL_NAME",
			"EDIT_LABEL":"Portal Name:",
			"LIST_LABEL":"Portal Name",
			"DATA_TYPE":"Text",
			"MAX_SIZE":255,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PORTAL_ACTIVE",
			"EDIT_LABEL":"Portal Active:",
			"LIST_LABEL":"Portal Active",
			"DATA_TYPE":"Checkbox",
			"MAX_SIZE":1,
			"REQUIRED":true
		},
		{
			"FIELD_NAME":"PORTAL_APP",
			"EDIT_LABEL":"Portal App:",
			"LIST_LABEL":"Portal App",
			"DATA_TYPE":"Text",
			"MAX_SIZE":255,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"INVALID_EMAIL",
			"EDIT_LABEL":"Invalid Email:",
			"LIST_LABEL":"Invalid Email",
			"DATA_TYPE":"Checkbox",
			"MAX_SIZE":1,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"TEAM_ID",
			"EDIT_LABEL":"Team ID",
			"LIST_LABEL":"Team ID",
			"DATA_TYPE":"Guid",
			"MAX_SIZE":16,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"CAMPAIGN_ID",
			"EDIT_LABEL":"Campaign ID:",
			"LIST_LABEL":"Campaign ID",
			"DATA_TYPE":"Guid",
			"MAX_SIZE":16,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PORTAL_PASSWORD",
			"EDIT_LABEL":"Portal Password:",
			"LIST_LABEL":"Portal Password",
			"DATA_TYPE":"Text",
			"MAX_SIZE":32,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"DATE_MODIFIED_UTC",
			"EDIT_LABEL":"",
			"LIST_LABEL":"",
			"DATA_TYPE":"Date",
			"MAX_SIZE":8,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"TEAM_SET_ID",
			"EDIT_LABEL":"Team Set ID:",
			"LIST_LABEL":"",
			"DATA_TYPE":"Guid",
			"MAX_SIZE":16,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"SMS_OPT_IN",
			"EDIT_LABEL":"SMS Opt In:",
			"LIST_LABEL":"SMS Opt In",
			"DATA_TYPE":"Dropdown",
			"MAX_SIZE":25,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"TWITTER_SCREEN_NAME",
			"EDIT_LABEL":"Twitter Screen Name:",
			"LIST_LABEL":"Twitter",
			"DATA_TYPE":"Text",
			"MAX_SIZE":20,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PICTURE",
			"EDIT_LABEL":"Picture:",
			"LIST_LABEL":"Picture",
			"DATA_TYPE":"Text Area",
			"MAX_SIZE":1073741823,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"CONTACT_NUMBER",
			"EDIT_LABEL":"Contact Number:",
			"LIST_LABEL":"Contact Number",
			"DATA_TYPE":"Text",
			"MAX_SIZE":30,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"ASSIGNED_SET_ID",
			"EDIT_LABEL":"Assigned Set ID:",
			"LIST_LABEL":"",
			"DATA_TYPE":"Guid",
			"MAX_SIZE":16,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"DP_BUSINESS_PURPOSE",
			"EDIT_LABEL":"Business Purpose:",
			"LIST_LABEL":"Business Purpose",
			"DATA_TYPE":"Text Area",
			"MAX_SIZE":1073741823,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"DP_CONSENT_LAST_UPDATED",
			"EDIT_LABEL":"Concent Last Updated:",
			"LIST_LABEL":"Consent Updated",
			"DATA_TYPE":"Date",
			"MAX_SIZE":8,
			"REQUIRED":false
		}
	]
}
