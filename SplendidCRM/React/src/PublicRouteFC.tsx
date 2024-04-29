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
import React from 'react';
import { Outlet, useLocation }                from  'react-router-dom'                ;
// 2. Store and Types. 
// 3. Scripts. 
// 4. Components and Views. 
import MainContent                            from './ThemeComponents/MainContent'    ;

// https://codedamn.com/news/reactjs/handle-async-functions-with-ease
function PublicRouteFC()
{
	const location = useLocation();
	//console.log((new Date()).toISOString() + ' PublicRouteFC location', location);

	return (<MainContent>
		<Outlet />
	</MainContent>);
};

export default PublicRouteFC;
