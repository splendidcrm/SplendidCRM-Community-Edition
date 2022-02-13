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
import { uuidFast }                           from '../../scripts/utility'            ;

const style: React.CSSProperties =
{
	border         : '1px dashed grey',
	backgroundColor: '#eeeeee',
	padding        : '2px',
	margin         : '2px',
	borderRadius   : '2px',
	width          : '200px',
};

interface ISourceRowProps
{
	TITLE: string;
	removeRow: (index: number) => void;
	isDragging?: boolean;
	connectDragSource?: Function;  // ConnectDragSource;
}

const source =
{
	beginDrag(props: ISourceRowProps)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SourceRow' + '.beginDrag', props);
		return {
			id   : uuidFast(),
			index: -1
		};
	},
	endDrag(props: ISourceRowProps, monitor: DragSourceMonitor)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SourceRow' + '.endDrag', props, monitor);
		if ( !monitor.didDrop() )
		{
			props.removeRow(monitor.getItem().index);
		}
	}
}

function collect(connect: DragSourceConnector, monitor: DragSourceMonitor)
{
	//console.log((new Date()).toISOString() + ' ' + 'SourceRow' + '.collect', connect, monitor);
	return {
		connectDragSource: connect.dragSource()
	};
}

class SourceRow extends React.Component<ISourceRowProps>
{
	constructor(props: ISourceRowProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor');
	}

	public render()
	{
		const { TITLE } = this.props;
		return (
			this.props.connectDragSource &&
			this.props.connectDragSource(
				<div
					style={ { ...style } }>
					{ TITLE }
				</div>
			)
		);
	}
}

export default DragSource('ROW', source, collect)(SourceRow);
