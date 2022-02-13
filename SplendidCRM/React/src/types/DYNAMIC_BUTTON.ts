/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

export default interface DYNAMIC_BUTTON
{
	ID                            : string;  // uniqueidentifier
	VIEW_NAME                     : string;  // nvarchar
	CONTROL_INDEX                 : number;  // int
	CONTROL_TYPE                  : string;  // nvarchar
	DEFAULT_VIEW                  : boolean; // bit
	MODULE_NAME                   : string;  // nvarchar
	MODULE_ACCESS_TYPE            : string;  // nvarchar
	TARGET_NAME                   : string;  // nvarchar
	TARGET_ACCESS_TYPE            : string;  // nvarchar
	MOBILE_ONLY                   : boolean; // bit
	ADMIN_ONLY                    : boolean; // bit
	EXCLUDE_MOBILE                : boolean; // bit
	CONTROL_TEXT                  : string;  // nvarchar
	CONTROL_TOOLTIP               : string;  // nvarchar
	CONTROL_ACCESSKEY             : string;  // nvarchar
	CONTROL_CSSCLASS              : string;  // nvarchar
	TEXT_FIELD                    : string;  // nvarchar
	ARGUMENT_FIELD                : string;  // nvarchar
	COMMAND_NAME                  : string;  // nvarchar
	URL_FORMAT                    : string;  // nvarchar
	URL_TARGET                    : string;  // nvarchar
	ONCLICK_SCRIPT                : string;  // nvarchar
	HIDDEN                        : boolean; // bit
	BUSINESS_RULE                 : string;  // nvarchar
	BUSINESS_SCRIPT               : string;  // nvarchar
	MODULE_ACLACCESS              : string;
	TARGET_ACLACCESS              : string;
}

