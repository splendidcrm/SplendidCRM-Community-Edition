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
import SURVEY_PAGE_QUESTION from './SURVEY_PAGE_QUESTION';

export default interface SURVEY_PAGE
{ ID                            : string  // uniqueidentifier
, NAME                          : string  // nvarchar
, PAGE_NUMBER                   : number  // int
, QUESTION_RANDOMIZATION        : string  // nvarchar
, DESCRIPTION                   : string  // nvarchar
, SURVEY_ID                     : string  // uniqueidentifier
, RANDOMIZE_COUNT               : number  // int
, RANDOMIZE_APPLIED             : boolean  // 07/16/2018 Paul.  computed
, RENUMBER_QUESTIONS            : boolean  // 07/16/2018 Paul.  computed
, QUESTION_OFFSET               : number  // 07/16/2018 Paul.  computed
, MOBILE_ID                     : string  // 07/16/2018 Paul.  computed
, SURVEY_QUESTIONS              : SURVEY_PAGE_QUESTION[]
}

