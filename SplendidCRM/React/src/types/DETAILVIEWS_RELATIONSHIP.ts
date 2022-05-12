/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

export default interface DETAILVIEWS_RELATIONSHIP
{
	ID?                           : string;  // uniqueidentifier
	DETAIL_NAME?                  : string;  // nvarchar
	MODULE_NAME                   : string;  // nvarchar
	TITLE                         : string;  // nvarchar
	CONTROL_NAME                  : string;  // nvarchar
	RELATIONSHIP_ORDER?           : number;  // int
	TABLE_NAME                    : string;  // nvarchar
	PRIMARY_FIELD                 : string;  // nvarchar
	SORT_FIELD                    : string;  // nvarchar
	SORT_DIRECTION                : string;  // nvarchar
	// 03/31/2022 Paul.  Add Insight fields.
	INSIGHT_VIEW?                 : string;  // nvarchar
	INSIGHT_LABEL?                : string;  // nvarchar
	initialOpen?                  : boolean;
}

