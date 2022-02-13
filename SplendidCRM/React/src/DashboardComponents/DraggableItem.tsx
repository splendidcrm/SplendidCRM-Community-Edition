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
import { FontAwesomeIcon }                 from '@fortawesome/react-fontawesome';
import { DragSource, DropTarget, ConnectDropTarget, ConnectDragSource, DropTargetMonitor, DropTargetConnector, DragSourceConnector, DragSourceMonitor } from 'react-dnd';

const style: React.CSSProperties =
{
	border         : '1px solid grey',
	padding        : '0.5rem 1rem',
	backgroundColor: 'white',
	margin         : '0 .25em',
	transition     : 'flex-basis 0.2s ease, order 0.2s ease',
	display        : 'flex',
	alignItems     : 'center',
	justifyContent : 'space-between',
	borderRadius   : '.25em',
};

interface IDraggableItemProps
{
	id                : string;
	item              : any;
	onEditClick       : (id: string) => void;
	colIndex          : number;
	rowIndex          : number;
	isDragging?       : boolean;
	didDrop?          : boolean;
	rowTotal?         : number;
	setDragging       : (id: string) => void;
	draggingId        : string;
	connectDragSource?: ConnectDragSource;
	connectDropTarget?: ConnectDropTarget;
	moveDraggableItem : (dragColIndex: number, dragRowIndex: number, hoverCOlIndex: number, hoverRowIndex: number) => void;
	addSourceItem     : (id: string, hoverColIndex: number, hoverRowIndex: number) => void;
	remove            : (item, type) => void;
}

const source =
{
	beginDrag(props: IDraggableItemProps)
	{
		//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + '.beginDrag', props);
		return {
			id      : props.id,
			colIndex: props.colIndex,
			rowIndex: props.rowIndex,
			origId  : props.id,
		};
	},
	endDrag(props: IDraggableItemProps, monitor: DragSourceMonitor)
	{
		//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + '.endDrag', props, monitor);
		if ( !monitor.didDrop() )
		{
			props.remove(monitor.getItem(), monitor.getItemType());
		}
	}
};

const itemTarget =
{
	hover(props: IDraggableItemProps, monitor: DropTargetMonitor, component: DraggableItem)
	{
		const dragColIndex : number = monitor.getItem().colIndex;
		const dragRowIndex : number = monitor.getItem().rowIndex;
		const hoverColIndex: number = props.colIndex;
		const hoverRowIndex: number = props.rowIndex;
		//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + '.hover', props, monitor, component);

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
			const id: string = monitor.getItem().id;
			props.addSourceItem(id, hoverColIndex, hoverRowIndex)
		}

		// Time to actually perform the action

		// Note: we're mutating the monitor item here!
		// Generally it's better to avoid mutations,
		// but it's good here for the sake of performance
		// to avoid expensive index searches.
		monitor.getItem().id       = props.id;
		monitor.getItem().colIndex = hoverColIndex;
		monitor.getItem().rowIndex = hoverRowIndex;
	},
};

function collect(connect: DragSourceConnector, monitor: DragSourceMonitor)
{
	//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + '.collect', connect, monitor);
	return {
		connectDragSource: connect.dragSource(),
		isDragging       : monitor.isDragging(),
		didDrop          : monitor.didDrop(),
	};
}

function dropCollect(connect: DropTargetConnector)
{
	//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + '.dropCollect', connect);
	return {
		connectDropTarget: connect.dropTarget()
	};
}

class DraggableItem extends React.Component<IDraggableItemProps>
{
	constructor(props: IDraggableItemProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
	}

	shouldComponentUpdate(nextProps: IDraggableItemProps)
	{
		if ( this.props.draggingId !== nextProps.draggingId )
		{
			if ( nextProps.draggingId !== nextProps.id )
			{
				return false;
			}
		}
		return true;
	}

	componentWillUpdate(nextProps)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentWillUpdate', nextProps);
		if ( nextProps.isDragging )
		{
			nextProps.setDragging(nextProps.id);
		}
		if ( nextProps.didDrop )
		{
			nextProps.setDragging('');
		}
	}

	public render()
	{
		const { item, id, draggingId, rowTotal, connectDragSource, connectDropTarget, colIndex, onEditClick } = this.props;
		const opacity = id == draggingId ? 0 : 1;
		return (
			connectDragSource &&
			connectDropTarget &&
			connectDragSource(
				connectDropTarget(
					<div
						draggable
						className='grab'
						style={{ ...style, opacity, flexBasis: `${100 / rowTotal}%` }}>
						{ item.NAME }
						<span style={ {cursor: 'pointer'} } onClick={ () => onEditClick(id) }><FontAwesomeIcon icon="edit" size="lg" /></span>
					</div>
				)
			)
		);
	}
}

export default DropTarget('ITEM', itemTarget, dropCollect)(DragSource('ITEM', source, collect)(DraggableItem));
