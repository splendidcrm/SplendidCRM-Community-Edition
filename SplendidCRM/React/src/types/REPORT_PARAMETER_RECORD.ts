/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

export default interface REPORT_PARAMETER_RECORD
{
	NAME         : string;
	MODULE_NAME  : string;
	DATA_TYPE    : string;  // String, Boolean, DateTime, Integer, Float
	NULLABLE     : boolean;
	ALLOW_BLANK  : boolean;
	MULTI_VALUE  : boolean;
	HIDDEN       : boolean;
	PROMPT       : string;
	DEFAULT_VALUE: string;
	DATA_SET_NAME: string;
}

