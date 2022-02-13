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
import SURVEY_PAGE from './SURVEY_PAGE';

export default interface SURVEY
{ ID                            : string  // uniqueidentifier
, DATE_MODIFIED_UTC             : Date
, NAME                          : string  // nvarchar
, STATUS                        : string  // nvarchar
// 10/01/2018 Paul.  Include SURVEY_TARGET_MODULE. 
, SURVEY_TARGET_MODULE          : string  // nvarchar
, SURVEY_STYLE                  : string  // nvarchar
, PAGE_RANDOMIZATION            : string  // nvarchar
, DESCRIPTION                   : string  // nvarchar
, SURVEY_THEME_ID               : string  // uniqueidentifier
, RANDOMIZE_COUNT               : number  // int
, RANDOMIZE_APPLIED             : boolean // 07/16/2018 Paul.  computed
, RENUMBER_PAGES                : boolean // 07/16/2018 Paul.  computed
, SURVEY_PAGES                  : SURVEY_PAGE[]
, LOOP_SURVEY                   : boolean // bit
, TIMEOUT                       : number  // seconds
, RESULTS_COUNT                 : number  // return with cached list. 
, SURVEY_THEME                  : any     // the entire theme is included with the survey. 
}

