/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

export default interface DASHBOARDS_PANELS
{
	ID                            : string  ; // uniqueidentifier
	PANEL_ORDER                   : number  ; // int
	ROW_INDEX                     : number  ; // int
	COLUMN_WIDTH                  : number  ; // int
	DASHBOARD_ID                  : string  ; // uniqueidentifier
	DASHBOARD_APP_ID              : string  ; // uniqueidentifier
	NAME                          : string  ; // nvarchar
	CATEGORY                      : string  ; // nvarchar
	MODULE_NAME                   : string  ; // nvarchar
	TITLE                         : string  ; // nvarchar
	SETTINGS_EDITVIEW             : string  ; // nvarchar
	IS_ADMIN                      : boolean ; // bit
	APP_ENABLED                   : boolean ; // bit
	SCRIPT_URL                    : string  ; // nvarchar
	DEFAULT_SETTINGS              : string  ; // nvarchar
	PANEL_TYPE?                   : string  ; // nvarchar
}

