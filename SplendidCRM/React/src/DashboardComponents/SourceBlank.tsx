/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

import * as React from 'react';
import { DragSource, DropTarget, ConnectDropTarget, ConnectDragSource, DropTargetMonitor, DropTargetConnector, DragSourceConnector, DragSourceMonitor } from 'react-dnd';
import { uuidFast }                           from '../scripts/utility'            ;

const style: React.CSSProperties =
{
	border         : '1px dashed grey',
	padding        : '0.5rem 1rem',
	backgroundColor: 'white',
	margin         : '0 .25em',
};

interface ISourceBlankProps
{
	TITLE               : string;
	createItemFromSource: (item: any) => any;
	connectDragSource?  : ConnectDragSource;
}

const source =
{
	beginDrag(props: ISourceBlankProps)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SourceBlank' + '.beginDrag', props);
		return props.createItemFromSource(
		{
			id               : uuidFast(),
			index            : -1,
			NAME             : '(blank)',
			CATEGORY         : null,
			MODULE_NAME      : null,
			TITLE            : '(blank)',
			SETTINGS_EDITVIEW: null,
			IS_ADMIN         : false,
			APP_ENABLED      : true,
			SCRIPT_URL       : null,
			DEFAULT_SETTINGS : null,
		});
	},
	endDrag(props: ISourceBlankProps, monitor: DragSourceMonitor)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SourceBlank' + '.endDrag', props, monitor);
	}
};

function collect(connect: DragSourceConnector, monitor: DragSourceMonitor)
{
	//console.log((new Date()).toISOString() + ' ' + 'SourceBlank' + '.collect', connect, monitor);
	return {
		connectDragSource: connect.dragSource()
	};
}

class SourceBlank extends React.Component<ISourceBlankProps>
{
	constructor(props: ISourceBlankProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
	}

	public render()
	{
		const{ TITLE, connectDragSource } = this.props;
		return (
			connectDragSource &&
			connectDragSource(
				<div style={ { ...style } } className="grab">
					{ TITLE }
				</div>
			)
		);
	}
}

export default DragSource('ITEM', source, collect)(SourceBlank);
