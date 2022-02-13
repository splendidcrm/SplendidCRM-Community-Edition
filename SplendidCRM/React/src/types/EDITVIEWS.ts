/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 1. React and fabric. 
// 2. Store and Types. 
// 3. Scripts. 

export default interface EDITVIEWS
{
	ID                            : string ;  // uniqueidentifier
	NAME                          : string ;  // nvarchar
	MODULE_NAME                   : string ;  // nvarchar
	VIEW_NAME                     : string ;  // nvarchar
	LABEL_WIDTH                   : string ;  // nvarchar
	FIELD_WIDTH                   : string ;  // nvarchar
	SCRIPT                        : string ;  // nvarchar
	DATA_COLUMNS                  : number ;  // int
	NEW_EVENT_ID                  : string ;  // uniqueidentifier
	NEW_EVENT_NAME                : string ;  // nvarchar
	PRE_LOAD_EVENT_ID             : string ;  // uniqueidentifier
	PRE_LOAD_EVENT_NAME           : string ;  // nvarchar
	POST_LOAD_EVENT_ID            : string ;  // uniqueidentifier
	POST_LOAD_EVENT_NAME          : string ;  // nvarchar
	VALIDATION_EVENT_ID           : string ;  // uniqueidentifier
	VALIDATION_EVENT_NAME         : string ;  // nvarchar
	PRE_SAVE_EVENT_ID             : string ;  // uniqueidentifier
	PRE_SAVE_EVENT_NAME           : string ;  // nvarchar
	POST_SAVE_EVENT_ID            : string ;  // uniqueidentifier
	POST_SAVE_EVENT_NAME          : string ;  // nvarchar
}

