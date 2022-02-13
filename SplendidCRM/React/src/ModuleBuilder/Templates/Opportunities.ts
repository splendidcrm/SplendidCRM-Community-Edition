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
	DISPLAY_NAME  : 'Opportunities',
	MODULE_NAME   : 'Opportunities',
	TABLE_NAME    : 'OPPORTUNITIES',
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
			"FIELD_NAME":"NAME",
			"EDIT_LABEL":"Name:",
			"LIST_LABEL":"Name",
			"DATA_TYPE":"Text",
			"MAX_SIZE":150,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"OPPORTUNITY_TYPE",
			"EDIT_LABEL":"Opportunity Type:",
			"LIST_LABEL":"Opportunity Type",
			"DATA_TYPE":"Dropdown",
			"MAX_SIZE":255,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"LEAD_SOURCE",
			"EDIT_LABEL":"Lead Source:",
			"LIST_LABEL":"Lead Source",
			"DATA_TYPE":"Dropdown",
			"MAX_SIZE":50,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"AMOUNT",
			"EDIT_LABEL":"Amount:",
			"LIST_LABEL":"Amount",
			"DATA_TYPE":"Money",
			"MAX_SIZE":8,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"AMOUNT_BACKUP",
			"EDIT_LABEL":"Amount Backup:",
			"LIST_LABEL":"Amount Backup",
			"DATA_TYPE":"Text",
			"MAX_SIZE":25,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"AMOUNT_USDOLLAR",
			"EDIT_LABEL":"Amount US Dollar:",
			"LIST_LABEL":"Amount US Dollar",
			"DATA_TYPE":"Money",
			"MAX_SIZE":8,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"CURRENCY_ID",
			"EDIT_LABEL":"Currency ID:",
			"LIST_LABEL":"Currency ID",
			"DATA_TYPE":"Guid",
			"MAX_SIZE":16,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"DATE_CLOSED",
			"EDIT_LABEL":"Date Closed:",
			"LIST_LABEL":"Date Closed",
			"DATA_TYPE":"Date",
			"MAX_SIZE":8,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"NEXT_STEP",
			"EDIT_LABEL":"Next Step:",
			"LIST_LABEL":"Next Step",
			"DATA_TYPE":"Text",
			"MAX_SIZE":100,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"SALES_STAGE",
			"EDIT_LABEL":"Sales Stage:",
			"LIST_LABEL":"Sales Stage",
			"DATA_TYPE":"Dropdown",
			"MAX_SIZE":25,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"PROBABILITY",
			"EDIT_LABEL":"Probability(%):",
			"LIST_LABEL":"Probability(%)",
			"DATA_TYPE":"Decimal",
			"MAX_SIZE":8,
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
			"FIELD_NAME":"TEAM_SET_ID",
			"EDIT_LABEL":"Team Set ID:",
			"LIST_LABEL":"",
			"DATA_TYPE":"Guid",
			"MAX_SIZE":16,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"B2C_CONTACT_ID",
			"EDIT_LABEL":"Contact ID:",
			"LIST_LABEL":"Contact ID",
			"DATA_TYPE":"Guid",
			"MAX_SIZE":16,
			"REQUIRED":false
		},
		{
			"FIELD_NAME":"OPPORTUNITY_NUMBER",
			"EDIT_LABEL":"Opportunity Number:",
			"LIST_LABEL":"Opportunity Number",
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
		}
	]
}
