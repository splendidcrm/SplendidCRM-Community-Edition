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
import SURVEY_PAGE_QUESTION  from '../types/SURVEY_PAGE_QUESTION';

export default interface ISurveyQuestionProps
{
	row                 : SURVEY_PAGE_QUESTION;
	displayMode         : string;
	rowQUESTION_RESULTS?: any;
	onChanged?          : (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any) => void;
	onSubmit?           : () => void;
	onUpdate?           : (PARENT_FIELD: string, DATA_VALUE: any, item?: any) => void;
	createDependency?   : (DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string) => void;
	onFocusNextQuestion?: (ID: string) => void;
	isPageFocused?      : () => boolean;
}

