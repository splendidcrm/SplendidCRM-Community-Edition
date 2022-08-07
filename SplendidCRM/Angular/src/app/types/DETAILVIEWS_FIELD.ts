/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

export default interface DETAILVIEWS_FIELD
{
	ID                            : string;  // uniqueidentifier
	DELETED                       : boolean; // bit
	DETAIL_NAME                   : string;  // nvarchar
	FIELD_INDEX                   : number;  // int
	FIELD_TYPE                    : string;  // nvarchar
	DEFAULT_VIEW                  : boolean; // bit
	DATA_LABEL                    : string;  // nvarchar
	DATA_FIELD                    : string;  // nvarchar
	DATA_FORMAT                   : string;  // nvarchar
	URL_FIELD                     : string;  // nvarchar
	URL_FORMAT                    : string;  // nvarchar
	URL_TARGET                    : string;  // nvarchar
	LIST_NAME                     : string;  // nvarchar
	COLSPAN                       : number;  // int
	LABEL_WIDTH                   : string;  // nvarchar
	FIELD_WIDTH                   : string;  // nvarchar
	DATA_COLUMNS                  : number;  // int
	VIEW_NAME                     : string;  // nvarchar
	MODULE_NAME                   : string;  // nvarchar
	TOOL_TIP                      : string;  // nvarchar
	MODULE_TYPE                   : string;  // nvarchar
	PARENT_FIELD                  : string;  // nvarchar
	SCRIPT                        : string;  // nvarchar
	hidden                        : boolean;
	ActiveTab                     : boolean;
}

