/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

export default interface GRIDVIEWS_COLUMN
{
	ID                            : string;  // uniqueidentifier
	DELETED                       : boolean; // bit
	GRID_NAME                     : string;  // nvarchar
	COLUMN_INDEX                  : number;  // int
	COLUMN_TYPE                   : string;  // nvarchar
	DEFAULT_VIEW                  : boolean; // bit
	HEADER_TEXT                   : string;  // nvarchar
	SORT_EXPRESSION               : string;  // nvarchar
	ITEMSTYLE_WIDTH               : string;  // nvarchar
	ITEMSTYLE_CSSCLASS            : string;  // nvarchar
	ITEMSTYLE_HORIZONTAL_ALIGN    : string;  // nvarchar
	ITEMSTYLE_VERTICAL_ALIGN      : string;  // nvarchar
	ITEMSTYLE_WRAP                : boolean; // bit
	DATA_FIELD                    : string;  // nvarchar
	DATA_FORMAT                   : string;  // nvarchar
	URL_FIELD                     : string;  // nvarchar
	URL_FORMAT                    : string;  // nvarchar
	URL_TARGET                    : string;  // nvarchar
	LIST_NAME                     : string;  // nvarchar
	URL_MODULE                    : string;  // nvarchar
	URL_ASSIGNED_FIELD            : string;  // nvarchar
	VIEW_NAME                     : string;  // nvarchar
	MODULE_NAME                   : string;  // nvarchar
	MODULE_TYPE                   : string;  // nvarchar
	PARENT_FIELD                  : string;  // nvarchar
	SCRIPT                        : string;  // nvarchar

}

