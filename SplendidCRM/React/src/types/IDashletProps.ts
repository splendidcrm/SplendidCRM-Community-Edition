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
import { RouteComponentProps } from 'react-router-dom';
// 2. Store and Types. 

export default interface IDashletProps extends RouteComponentProps<any>
{
	ID               : string;
	TITLE            : string;
	SETTINGS_EDITVIEW: any;
	DEFAULT_SETTINGS : any;
	COLUMN_WIDTH     : number  ; // bootstrap 1 to 12. 
}

