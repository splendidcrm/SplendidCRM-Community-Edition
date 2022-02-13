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
import * as React from 'react';

// https://infinum.com/the-capsized-eight/how-to-use-react-hooks-in-class-components
function useScreenSize(): any
{
	const [width , setWidth ] = React.useState(window.innerWidth );
	const [height, setHeight] = React.useState(window.innerHeight);

	React.useEffect(() =>
	{
		const handler = (event: any) =>
		{
			setWidth (event.target.innerWidth );
			setHeight(event.target.innerHeight);
		};
		window.addEventListener('resize', handler);
		return () =>
		{
			window.removeEventListener('resize', handler);
		};
	}, []);

	return {width, height};
}

const withScreenSizeHook = (Component: any) =>
{
	return (props: any) =>
	{
		const screenSize = useScreenSize();
		return <Component screenSize={ screenSize } {...props} />;
	};
};

export default withScreenSizeHook;
