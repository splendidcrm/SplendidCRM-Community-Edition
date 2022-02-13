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
import Sql           from '../scripts/Sql'          ;
import SplendidCache from '../scripts/SplendidCache';
import Credentials   from '../scripts/Credentials' ;

export default class Security
{
	static IS_ADMIN()
	{
		return Credentials.bIS_ADMIN || Credentials.bIS_ADMIN_DELEGATE;
	}
	
	static IS_ADMIN_DELEGATE()
	{
		return Credentials.bIS_ADMIN_DELEGATE;
	}
	
	static USER_ID()
	{
		return SplendidCache.UserID;
	}
	
	static USER_NAME()
	{
		return SplendidCache.UserName;
	}
	
	static FULL_NAME()
	{
		return SplendidCache.FullName;
	}
	
	// 11/25/2014 Paul.  sPICTURE is used by the ChatDashboard. 
	static PICTURE()
	{
		return SplendidCache.Picture;
	}
	
	static USER_LANG()
	{
		return SplendidCache.UserLang;
	}
	
	// 04/23/2013 Paul.  The HTML5 Offline Client now supports Atlantic theme. 
	static USER_THEME()
	{
		return SplendidCache.UserTheme;
	}
	
	static USER_DATE_FORMAT()
	{
		return SplendidCache.UserDateFormat;
	}
	
	static USER_TIME_FORMAT()
	{
		return SplendidCache.UserTimeFormat;
	}
	
	static TEAM_ID()
	{
		return SplendidCache.TeamID;
	}
	
	static TEAM_NAME()
	{
		return SplendidCache.TeamName;
	}
	
	// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
	static NumberFormatInfo()
	{
		// 10/29/2020 Paul.  Clone so that the decimal digits can be modified safely. 
		return Object.assign({}, SplendidCache.NumberFormatInfo);
	}

	static HasExchangeAlias()
	{
		return !Sql.IsEmptyString(Credentials.sEXCHANGE_ALIAS);
	}

	// 01/22/2021 Paul.  Customizations may be based on the PRIMARY_ROLE_ID and not the name. 
	static PRIMARY_ROLE_ID(): string
	{
		return Credentials.sPRIMARY_ROLE_ID;
	}
	
	static PRIMARY_ROLE_NAME(): string
	{
		return Credentials.sPRIMARY_ROLE_NAME;
	}
	
	// 01/22/2021 Paul.  Some customizations may be dependent on role name. 
	static GetACLRoleAccess(sNAME: string) : boolean
	{
		return SplendidCache.GetACLRoleAccess(sNAME);
	}

	// 03/29/2021 Paul.  Allow display of impersonation state. 
	static IsImpersonating(): boolean
	{
		return Credentials.USER_IMPERSONATION;
	}
}
