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

const style: React.CSSProperties =
{
	border         : '1px dashed grey',
	paddingTop     : '0.5em',
	paddingBottom  : '0.5em',
	paddingLeft    : '1em',
	paddingRight   : '1em',
	marginBottom   : '.5rem',
	backgroundColor: 'lightgrey',
	cursor         : 'move',
	display        : 'flex',
	minHeight      : '64px',
};

interface IDraggableRowProps
{
	id                : any;
	index             : number;
	isDragging?       : boolean;
	connectDragSource?: ConnectDragSource;
	connectDropTarget?: ConnectDropTarget;
	length            : number;
	moveDraggableRow  : (dragIndex: number, hoverIndex: number) => void;
	moveDraggableItem : (dragColIndex: number, dragRowIndex: number, hoverCOlIndex: number, hoverRowIndex: number) => void;
	addSourceItem     : (id: string, hoverColIndex: number, hoverRowIndex: number) => void;
	addSourceRow      : (id: string, hoverIndex: number) => void;
	removeRow         : (index: number) => void;
}

const source =
{
	beginDrag(props: IDraggableRowProps)
	{
		//console.log((new Date()).toISOString() + ' ' + 'DraggableRow' + '.beginDrag', props);
		return {
			id   : props.id,
			index: props.index,
		};
	},
	endDrag(props: IDraggableRowProps, monitor: DragSourceMonitor)
	{
		//console.log((new Date()).toISOString() + ' ' + 'DraggableRow' + '.endDrag', props, monitor);
		if ( !monitor.didDrop() )
		{
			props.removeRow(monitor.getItem().index);
		}
	}
};

function collect(connect: DragSourceConnector, monitor: DragSourceMonitor)
{
	//console.log((new Date()).toISOString() + ' ' + 'DraggableRow' + '.collect', connect, monitor);
	return {
		connectDragSource: connect.dragSource(),
		isDragging       : monitor.isDragging(),
	};
}

const rowTarget =
{
	hover(props: IDraggableRowProps, monitor: DropTargetMonitor, component: DraggableRow)
	{
		//console.log((new Date()).toISOString() + ' ' + 'DraggableRow' + '.hover', props, monitor);
		if ( monitor.getItemType() == 'ROW' )
		{
			const dragIndex = monitor.getItem().index;
			const hoverIndex = props.index;

			// Don't replace rows with themselves
			if ( dragIndex === hoverIndex )
			{
				return;
			}
			if ( dragIndex != -1 )
			{
				props.moveDraggableRow(dragIndex, hoverIndex);
			}
			else
			{
				const id = monitor.getItem().id;
				props.addSourceRow(id, hoverIndex);
			}
			// Time to actually perform the action

			// Note: we're mutating the monitor row here!
			// Generally it's better to avoid mutations,
			// but it's good here for the sake of performance
			// to avoid expensive index searches.
			monitor.getItem().id = props.id;
			monitor.getItem().index = hoverIndex;
		}
		else
		{
			if ( props.length != 0 )
			{
				return;
			}
			const dragColIndex = monitor.getItem().colIndex;
			const dragRowIndex = monitor.getItem().rowIndex;
			const hoverColIndex = 0;
			const hoverRowIndex = props.index;
			// Don't replace items with themselves
			if ( dragColIndex === hoverColIndex && dragRowIndex === hoverRowIndex )
			{
				return;
			}
			if ( dragColIndex != -1 && dragRowIndex != -1 )
			{
				if ( Math.abs(dragRowIndex - hoverRowIndex) > 1 )
				{
					return;
				}
				props.moveDraggableItem(dragColIndex, dragRowIndex, hoverColIndex, hoverRowIndex);
			}
			else
			{
				const id = monitor.getItem().id;
				props.addSourceItem(id, hoverColIndex, hoverRowIndex);
			}

			// Time to actually perform the action

			// Note: we're mutating the monitor item here!
			// Generally it's better to avoid mutations,
			// but it's good here for the sake of performance
			// to avoid expensive index searches.
			//monitor.getItem().id = props.id;
			monitor.getItem().colIndex = hoverColIndex;
			monitor.getItem().rowIndex = hoverRowIndex;
		}
	}
};

function dropCollect(connect: DropTargetConnector)
{
	//console.log((new Date()).toISOString() + ' ' + 'DraggableRow' + '.dropCollect', connect);
	return {
		connectDropTarget: connect.dropTarget()
	};
}

class DraggableRow extends React.Component<IDraggableRowProps>
{
	constructor(props: IDraggableRowProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
	}

	public render()
	{
		const { index, isDragging, connectDragSource, connectDropTarget, length, children } = this.props;
		const opacity = isDragging ? 0 : 1;
		return (
			connectDragSource &&
			connectDropTarget &&
			connectDragSource(
				connectDropTarget(
					<div
						style={ { ...style, opacity } }>
						{ children }
					</div>
				)
			)
		);
	}
}

export default DropTarget(['ROW', 'ITEM'], rowTarget, dropCollect)(DragSource('ROW', source, collect)(DraggableRow));
