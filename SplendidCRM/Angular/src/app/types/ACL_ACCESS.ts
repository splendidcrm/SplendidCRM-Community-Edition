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

export default class ACL_ACCESS
{
	// 09/26/2017 Paul.  Add Archive access right. 
	public static FULL_ACCESS: number = 100;
	public static ARCHIVE    : number = 91;
	public static VIEW       : number = 90;
	public static ALL        : number = 90;
	public static ENABLED    : number =  89;
	public static OWNER      : number =  75;
	public static DISABLED   : number = -98;
	public static NONE       : number = -99;

	public static GetName(access: string, value: number)
	{
		let name: string = 'NONE';
		switch ( value )
		{
			case ACL_ACCESS.FULL_ACCESS:  name = 'FULL_ACCESS';  break;
			case ACL_ACCESS.ARCHIVE    :  name = 'ARCHIVE'    ;  break;
			case ACL_ACCESS.VIEW       :  (access == 'archive' ? name = 'VIEW' : name = 'ALL');  break;
			case ACL_ACCESS.ENABLED    :  name = 'ENABLED'    ;  break;
			case ACL_ACCESS.OWNER      :  name = 'OWNER'      ;  break;
			case ACL_ACCESS.DISABLED   :  name = 'DISABLED'   ;  break;
			case ACL_ACCESS.NONE       :  name = 'NONE'       ;  break;
		}
		return name;
	}
}

