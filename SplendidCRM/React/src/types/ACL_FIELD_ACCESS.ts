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
import Security from '../scripts/Security';
import SplendidCache from '../scripts/SplendidCache';

export default class ACL_FIELD_ACCESS
{
	public static FULL_ACCESS           : number = 100;
	public static READ_WRITE            : number =  99;
	public static READ_OWNER_WRITE      : number =  60;
	public static READ_ONLY             : number =  50;
	public static OWNER_READ_OWNER_WRITE: number =  40;
	public static OWNER_READ_ONLY       : number =  30;
	public static NOT_SET               : number =   0;
	public static NONE                  : number = -99;

	protected nACLACCESS: number ;
	protected bIsNew    : boolean;
	protected bIsOwner  : boolean;

	public static GetName(access: string, value: number)
	{
		let name: string = 'NONE';
		switch ( value )
		{
			case ACL_FIELD_ACCESS.FULL_ACCESS           :  name = 'FULL_ACCESS'           ;  break;
			case ACL_FIELD_ACCESS.READ_WRITE            :  name = 'READ_WRITE'            ;  break;
			case ACL_FIELD_ACCESS.READ_OWNER_WRITE      :  name = 'READ_OWNER_WRITE'      ;  break;
			case ACL_FIELD_ACCESS.READ_ONLY             :  name = 'READ_ONLY'             ;  break;
			case ACL_FIELD_ACCESS.OWNER_READ_OWNER_WRITE:  name = 'OWNER_READ_OWNER_WRITE';  break;
			case ACL_FIELD_ACCESS.OWNER_READ_ONLY       :  name = 'OWNER_READ_ONLY'       ;  break;
			case ACL_FIELD_ACCESS.NOT_SET               :  name = 'NOT_SET'               ;  break;
			case ACL_FIELD_ACCESS.NONE                  :  name = 'NONE'                  ;  break;
		}
		return name;
	}

	public get ACLACCESS(): number
	{
		return this.nACLACCESS;
	}

	public get IsNew(): boolean
	{
		return this.bIsNew;
	}

	public get IsOwner(): boolean
	{
		return this.bIsOwner;
	}

	public IsReadable(): boolean
	{
		if ( this.nACLACCESS == ACL_FIELD_ACCESS.FULL_ACCESS )
		{
			return true;
		}
		else if ( this.nACLACCESS < ACL_FIELD_ACCESS.NOT_SET )
		{
			return false;
		}
		if (  this.bIsNew
		   || this.bIsOwner
		   || this.nACLACCESS > ACL_FIELD_ACCESS.OWNER_READ_ONLY
		   )
		{
			return true;
		}
		return false;
	}

	public IsWriteable(): boolean
	{
		if ( this.nACLACCESS == ACL_FIELD_ACCESS.FULL_ACCESS )
		{
			return true;
		}
		else if ( this.nACLACCESS < ACL_FIELD_ACCESS.NOT_SET )
		{
			return false;
		}
		// 01/22/2010 Paul.  Just be cause the record is new, does not mean that the user can specify it. 
		if (  (this.bIsOwner && this.nACLACCESS == ACL_FIELD_ACCESS.OWNER_READ_OWNER_WRITE)
		   || (this.bIsOwner && this.nACLACCESS == ACL_FIELD_ACCESS.READ_OWNER_WRITE      )
		   || (                 this.nACLACCESS >  ACL_FIELD_ACCESS.READ_OWNER_WRITE      )
		   )
		{
			return true;
		}
		return false;
	}

	constructor(nACLACCESS: number, gOWNER_ID: string)
	{
		this.nACLACCESS = nACLACCESS;
		this.bIsNew     = (gOWNER_ID == null || gOWNER_ID == '00000000-0000-0000-0000-000000000000');
		this.bIsOwner   = (Security.USER_ID() == gOWNER_ID) || this.bIsNew;
	}

	public static GetUserFieldSecurity(sMODULE_NAME: string, sDATA_FIELD: string, gOWNER_ID: string): ACL_FIELD_ACCESS
	{
		let nACLACCESS: number = SplendidCache.GetUserFieldSecurity(sMODULE_NAME, sDATA_FIELD);
		let acl       : ACL_FIELD_ACCESS = new ACL_FIELD_ACCESS(nACLACCESS, gOWNER_ID);
		return acl;
	}
}

