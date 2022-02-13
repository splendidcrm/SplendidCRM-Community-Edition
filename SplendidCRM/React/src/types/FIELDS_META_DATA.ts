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

export default interface FIELDS_META_DATA
{
	ID                            : string ;  // uniqueidentifier
	NAME                          : string ;  // nvarchar
	LABEL                         : string ;  // nvarchar
	CUSTOM_MODULE                 : string ;  // nvarchar
	DATA_TYPE                     : string ;  // nvarchar
	MAX_SIZE                      : number ;  // int
	REQUIRED_OPTION               : string ;  // nvarchar
	AUDITED                       : boolean;  // bit
	DEFAULT_VALUE                 : string ;  // nvarchar
	EXT1                          : string ;  // nvarchar
	EXT2                          : string ;  // nvarchar
	EXT3                          : string ;  // nvarchar
	MASS_UPDATE                   : boolean;  // bit
}

