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
// 2. Store and Types. 
// 3. Scripts. 

interface IDraggableCellProps
{
	width             : string;
	colIndex          : number;
	rowIndex          : number;
	didDrop?          : boolean;
	rowTotal?         : number;
	connectDropTarget?: Function;  // ConnectDropTarget;
	moveDraggableItem : (id: string, hoverColIndex: number, hoverRowIndex: number, didDrop: boolean) => void;
	addSourceItem     : (id: string, hoverColIndex: number, hoverRowIndex: number) => void;
}

interface IDraggableCellState
{
	isOver            : boolean;
	isDragging?       : boolean;
}

const itemTarget =
{
	hover(props: IDraggableCellProps, monitor: DropTargetMonitor, component: DraggableCell)
	{
		const id            : string = monitor.getItem().id        ;
		const dragFieldIndex: number = monitor.getItem().fieldIndex;
		const dragColIndex  : number = monitor.getItem().colIndex  ;
		const dragRowIndex  : number = monitor.getItem().rowIndex  ;
		const hoverColIndex : number = props.colIndex;
		const hoverRowIndex : number = props.rowIndex;
		//console.log((new Date()).toISOString() + ' ' + 'DraggableCell' + '.hover', props, monitor, component);

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
			// 03/08/2020 Paul.  When moving items around, we do not need to move existing item. 
			//console.log((new Date()).toISOString() + ' ' + 'DraggableCell' + '.hover', props, monitor);
			props.moveDraggableItem(id, hoverColIndex, hoverRowIndex, false);
		}
		else
		{
			//console.log((new Date()).toISOString() + ' ' + 'DraggableCell' + '.hover', props, monitor);
			const id: string = monitor.getItem().id;
			props.addSourceItem(id, hoverColIndex, hoverRowIndex);
		}

		// Time to actually perform the action

		// Note: we're mutating the monitor item here!
		// Generally it's better to avoid mutations,
		// but it's good here for the sake of performance
		// to avoid expensive index searches.
		monitor.getItem().colIndex = hoverColIndex;
		monitor.getItem().rowIndex = hoverRowIndex;
	},
};

function dropCollect(connect: DropTargetConnector)
{
	//console.log((new Date()).toISOString() + ' ' + 'DraggableCell' + '.dropCollect', connect);
	return {
		connectDropTarget: connect.dropTarget()
	};
}

class DraggableCell extends React.Component<IDraggableCellProps, IDraggableCellState>
{
	constructor(props: IDraggableCellProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		this.state =
		{
			isOver    : false,
			isDragging: false,
		};
	}

	componentWillUpdate(nextProps)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentWillUpdate', nextProps);
		if ( nextProps.isDragging )
		{
			nextProps.setDragging(nextProps.id);
		}
	}

	public render()
	{
		const { width, rowTotal, children } = this.props;
		const { isOver } = this.state;
		return (
			this.props.connectDropTarget &&
			this.props.connectDropTarget(
				<td style={{ width, border: '1px dashed grey' }}>
					{ children }
				</td>
			)
		);
	}
}

export default DropTarget('ITEM', itemTarget, dropCollect)(DraggableCell);
