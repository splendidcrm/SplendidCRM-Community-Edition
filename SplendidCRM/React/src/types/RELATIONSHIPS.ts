/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

export default interface RELATIONSHIPS
{
	ID                            : string  ; // uniqueidentifier
	RELATIONSHIP_NAME             : string  ; // nvarchar
	LHS_MODULE                    : string  ; // nvarchar
	LHS_TABLE                     : string  ; // nvarchar
	LHS_KEY                       : string  ; // nvarchar
	RHS_MODULE                    : string  ; // nvarchar
	RHS_TABLE                     : string  ; // nvarchar
	RHS_KEY                       : string  ; // nvarchar
	JOIN_TABLE                    : string  ; // nvarchar
	JOIN_KEY_LHS                  : string  ; // nvarchar
	JOIN_KEY_RHS                  : string  ; // nvarchar
	RELATIONSHIP_TYPE             : string  ; // nvarchar
	RELATIONSHIP_ROLE_COLUMN      : string  ; // nvarchar
	RELATIONSHIP_ROLE_COLUMN_VALUE: string  ; // nvarchar
	REVERSE                       : boolean ; // bit
}

