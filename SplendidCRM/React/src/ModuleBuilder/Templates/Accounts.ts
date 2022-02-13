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
	DISPLAY_NAME  : 'Accounts',
	MODULE_NAME   : 'Accounts',
	TABLE_NAME    : 'ACCOUNTS',
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
		'Contacts',
		'Opportunities',
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
			"FIELD_NAME":"NAME",
			"EDIT_LABEL":"Name:",
			"LIST_LABEL":"Name",
			"DATA_TYPE":"Text",
			"MAX_SIZE":150,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"ACCOUNT_TYPE",
			"EDIT_LABEL":"Account Type: ",
			"LIST_LABEL":"Account Type",
			"DATA_TYPE":"Dropdown",
			"MAX_SIZE":25,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PARENT_ID",
			"EDIT_LABEL":"Parent ID:",
			"LIST_LABEL":"Parent ID",
			"DATA_TYPE":"Guid",
			"MAX_SIZE":16,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"INDUSTRY",
			"EDIT_LABEL":"Industry:",
			"LIST_LABEL":"Industry",
			"DATA_TYPE":"Dropdown",
			"MAX_SIZE":25,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"ANNUAL_REVENUE",
			"EDIT_LABEL":"Annual Revenue:",
			"LIST_LABEL":"Annual Revenue",
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
			"FIELD_NAME":"BILLING_ADDRESS_STREET",
			"EDIT_LABEL":"Billing Street:",
			"LIST_LABEL":"Billing Street",
			"DATA_TYPE":"Text",
			"MAX_SIZE":150,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"BILLING_ADDRESS_CITY",
			"EDIT_LABEL":"Billing City:",
			"LIST_LABEL":"Billing City",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"BILLING_ADDRESS_STATE",
			"EDIT_LABEL":"Billing State:",
			"LIST_LABEL":"Billing State",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"BILLING_ADDRESS_POSTALCODE",
			"EDIT_LABEL":"Billing Postal Code:",
			"LIST_LABEL":"Billing Postal Code",
			"DATA_TYPE":"Text",
			"MAX_SIZE":20,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"BILLING_ADDRESS_COUNTRY",
			"EDIT_LABEL":"Billing Country:",
			"LIST_LABEL":"Billing Country",
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
			"FIELD_NAME":"RATING",
			"EDIT_LABEL":"Rating:",
			"LIST_LABEL":"Rating",
			"DATA_TYPE":"Text",
			"MAX_SIZE":25,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PHONE_OFFICE",
			"EDIT_LABEL":"Phone Office:",
			"LIST_LABEL":"Phone Office",
			"DATA_TYPE":"Text",
			"MAX_SIZE":25,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PHONE_ALTERNATE",
			"EDIT_LABEL":"Phone Alternate:",
			"LIST_LABEL":"Phone Alternate",
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
			"FIELD_NAME":"WEBSITE",
			"EDIT_LABEL":"Website:",
			"LIST_LABEL":"Website",
			"DATA_TYPE":"Text",
			"MAX_SIZE":255,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"OWNERSHIP",
			"EDIT_LABEL":"Ownership:",
			"LIST_LABEL":"Ownership",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"EMPLOYEES",
			"EDIT_LABEL":"Employees:",
			"LIST_LABEL":"Employees",
			"DATA_TYPE":"Text",
			"MAX_SIZE":10,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"SIC_CODE",
			"EDIT_LABEL":"Sic Code:",
			"LIST_LABEL":"Sic Code",
			"DATA_TYPE":"Text",
			"MAX_SIZE":10,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"TICKER_SYMBOL",
			"EDIT_LABEL":"Ticker Symbol:",
			"LIST_LABEL":"Ticker Symbol",
			"DATA_TYPE":"Text",
			"MAX_SIZE":10,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"SHIPPING_ADDRESS_STREET",
			"EDIT_LABEL":"Shipping Street:",
			"LIST_LABEL":"Shipping Street",
			"DATA_TYPE":"Text",
			"MAX_SIZE":150,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"SHIPPING_ADDRESS_CITY",
			"EDIT_LABEL":"Shipping City:",
			"LIST_LABEL":"Shipping City",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"SHIPPING_ADDRESS_STATE",
			"EDIT_LABEL":"Shipping State:",
			"LIST_LABEL":"Shipping State",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"SHIPPING_ADDRESS_POSTALCODE",
			"EDIT_LABEL":"Shipping Postal Code:",
			"LIST_LABEL":"Shipping Postal Code",
			"DATA_TYPE":"Text",
			"MAX_SIZE":20,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"SHIPPING_ADDRESS_COUNTRY",
			"EDIT_LABEL":"Shipping Country:",
			"LIST_LABEL":"Shipping Country",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
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
			"FIELD_NAME":"DATE_MODIFIED_UTC",
			"EDIT_LABEL":"",
			"LIST_LABEL":"",
			"DATA_TYPE":"Date",
			"MAX_SIZE":8,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"ACCOUNT_NUMBER",
			"EDIT_LABEL":"Account Number:",
			"LIST_LABEL":"Account Number",
			"DATA_TYPE":"Text",
			"MAX_SIZE":30,
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
			"FIELD_NAME":"PICTURE",
			"EDIT_LABEL":"Picture:",
			"LIST_LABEL":"Picture",
			"DATA_TYPE":"Text Area",
			"MAX_SIZE":1073741823,
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
			"FIELD_NAME":"EMAIL_OPT_OUT",
			"EDIT_LABEL":"Email Opt Out:",
			"LIST_LABEL":"Email Opt Out",
			"DATA_TYPE":"Checkbox",
			"MAX_SIZE":1,
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
			"FIELD_NAME":"ASSIGNED_SET_ID",
			"EDIT_LABEL":"Assigned Set ID:",
			"LIST_LABEL":"",
			"DATA_TYPE":"Guid",
			"MAX_SIZE":16,
			"REQUIRED":false
		}
	]
}
