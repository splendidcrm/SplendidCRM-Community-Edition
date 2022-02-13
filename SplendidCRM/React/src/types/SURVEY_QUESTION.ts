/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

export default interface SURVEY_QUESTION
{
	ID                            : string ;  // uniqueidentifier
	NAME                          : string ;  // nvarchar
	DESCRIPTION                   : string ;  // nvarchar
	SURVEY_TARGET_MODULE          : string ;  // nvarchar
	TARGET_FIELD_NAME             : string ;  // nvarchar
	QUESTION_TYPE                 : string ;  // nvarchar
	DISPLAY_FORMAT                : string ;  // nvarchar
	ANSWER_CHOICES                : string ;  // nvarchar
	COLUMN_CHOICES                : string ;  // nvarchar
	FORCED_RANKING                : boolean;  // bit
	INVALID_DATE_MESSAGE          : string ;  // nvarchar
	INVALID_NUMBER_MESSAGE        : string ;  // nvarchar
	NA_ENABLED                    : boolean;  // bit
	NA_LABEL                      : string ;  // nvarchar
	OTHER_ENABLED                 : boolean;  // bit
	OTHER_LABEL                   : string ;  // nvarchar
	OTHER_HEIGHT                  : number ;  // int
	OTHER_WIDTH                   : number ;  // int
	OTHER_AS_CHOICE               : boolean;  // bit
	OTHER_ONE_PER_ROW             : boolean;  // bit
	OTHER_REQUIRED_MESSAGE        : string ;  // nvarchar
	OTHER_VALIDATION_TYPE         : string ;  // nvarchar
	OTHER_VALIDATION_MIN          : string ;  // nvarchar
	OTHER_VALIDATION_MAX          : string ;  // nvarchar
	OTHER_VALIDATION_MESSAGE      : string ;  // nvarchar
	REQUIRED                      : boolean;  // bit
	REQUIRED_TYPE                 : string ;  // nvarchar
	REQUIRED_RESPONSES_MIN        : number ;  // int
	REQUIRED_RESPONSES_MAX        : number ;  // int
	REQUIRED_MESSAGE              : string ;  // nvarchar
	VALIDATION_TYPE               : string ;  // nvarchar
	VALIDATION_MIN                : string ;  // nvarchar
	VALIDATION_MAX                : string ;  // nvarchar
	VALIDATION_MESSAGE            : string ;  // nvarchar
	VALIDATION_SUM_ENABLED        : boolean;  // bit
	VALIDATION_NUMERIC_SUM        : number ;  // int
	VALIDATION_SUM_MESSAGE        : string ;  // nvarchar
	RANDOMIZE_TYPE                : string ;  // nvarchar
	RANDOMIZE_NOT_LAST            : boolean;  // bit
	SIZE_WIDTH                    : string ;  // nvarchar
	SIZE_HEIGHT                   : string ;  // nvarchar
	BOX_WIDTH                     : string ;  // nvarchar
	BOX_HEIGHT                    : string ;  // nvarchar
	COLUMN_WIDTH                  : string ;  // nvarchar
	PLACEMENT                     : string ;  // nvarchar
	SPACING_LEFT                  : number ;  // int
	SPACING_TOP                   : number ;  // int
	SPACING_RIGHT                 : number ;  // int
	SPACING_BOTTOM                : number ;  // int
	IMAGE_URL                     : string ;  // nvarchar
	CATEGORIES                    : string ;  // nvarchar
	ASSIGNED_USER_ID              : string ;  // uniqueidentifier
	DATE_ENTERED                  : Date   ;  // datetime
	DATE_MODIFIED                 : Date   ;  // datetime
	DATE_MODIFIED_UTC             : Date   ;  // datetime
	TEAM_ID                       : string ;  // uniqueidentifier
	TEAM_NAME                     : string ;  // nvarchar
	ASSIGNED_TO                   : string ;  // nvarchar
	CREATED_BY                    : string ;  // nvarchar
	MODIFIED_BY                   : string ;  // nvarchar
	CREATED_BY_ID                 : string ;  // uniqueidentifier
	MODIFIED_USER_ID              : string ;  // uniqueidentifier
	TEAM_SET_ID                   : string ;  // uniqueidentifier
	TEAM_SET_NAME                 : string ;  // nvarchar
	TEAM_SET_LIST                 : string ;  // varchar
	ASSIGNED_TO_NAME              : string ;  // nvarchar
	CREATED_BY_NAME               : string ;  // nvarchar
	MODIFIED_BY_NAME              : string ;  // nvarchar
	ASSIGNED_SET_ID               : string ;  // uniqueidentifier
	ASSIGNED_SET_NAME             : string ;  // nvarchar
	ASSIGNED_SET_LIST             : string ;  // varchar
}

