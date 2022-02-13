/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 05/01/2019 Paul.  We need a flag so that the React client can determine if the module is Process enabled. 
// 07/31/2019 Paul.  DEFAULT_SORT is a new field for the React Client. 
// 08/12/2019 Paul.  ARCHIVED_ENBLED is needed for the dynamic buttons. 
// 12/03/2019 Paul.  Separate Archive View exists flag so that we can display information on DetailView. 
// 06/26/2021 Paul.  IS_ASSIGNED is available in vwMODULES_AppVars. 
export default interface MODULE
{
	ID                            : string ;  // uniqueidentifier
	NAME                          : string ;  // nvarchar
	MODULE_NAME                   : string ;  // nvarchar
	DISPLAY_NAME                  : string ;  // nvarchar
	RELATIVE_PATH                 : string ;  // nvarchar
	MODULE_ENABLED                : boolean;  // bit
	TAB_ENABLED                   : boolean;  // bit
	TAB_ORDER                     : number;   // int
	PORTAL_ENABLED                : boolean;  // bit
	CUSTOM_ENABLED                : boolean;  // bit
	IS_ADMIN                      : boolean;  // bit
	TABLE_NAME                    : string ;  // nvarchar
	REPORT_ENABLED                : boolean;  // bit
	IMPORT_ENABLED                : boolean;  // bit
	SYNC_ENABLED                  : boolean;  // bit
	MOBILE_ENABLED                : boolean;  // bit
	CUSTOM_PAGING                 : boolean;  // bit
	DATE_MODIFIED                 : Date   ;  // datetime
	DATE_MODIFIED_UTC             : Date   ;  // datetime
	MASS_UPDATE_ENABLED           : boolean;  // bit
	DEFAULT_SEARCH_ENABLED        : boolean;  // bit
	EXCHANGE_SYNC                 : boolean;  // bit
	EXCHANGE_FOLDERS              : boolean;  // bit
	EXCHANGE_CREATE_PARENT        : boolean;  // bit
	REST_ENABLED                  : boolean;  // bit
	DUPLICATE_CHECHING_ENABLED    : boolean;  // bit
	RECORD_LEVEL_SECURITY_ENABLED : boolean;  // bit
	PROCESS_ENABLED               : boolean;  // bit
	DEFAULT_SORT                  : string ;  // nvarchar
	ARCHIVED_ENBLED               : boolean;  // bit
	ARCHIVED_VIEW_EXISTS          : boolean;  // bit
	STREAM_ENBLED                 : boolean;  // bit
	IS_ASSIGNED                   : boolean;  // bit
}

