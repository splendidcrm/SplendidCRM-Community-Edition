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
import React, { memo, FC, useState }                              from 'react';
import { FontAwesomeIcon }                                        from '@fortawesome/react-fontawesome';
import { useDrag, useDrop, DragSourceMonitor, DropTargetMonitor } from 'react-dnd';
// 2. Store and Types. 
import IDragItemState                                             from '../types/IDragItemState'  ;
// 3. Scripts. 

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
	moveDraggableItem : (dragColIndex: number, dragRowIndex: number, hoverCOlIndex: number, hoverRowIndex: number) => void;
	addSourceItem     : (id: string, hoverColIndex: number, hoverRowIndex: number) => void;
	remove            : (item, type) => void;
}

// 12/31/2023 Paul.  react-dnd v15 requires use of hooks. 
const DraggableItem: FC<IDraggableItemProps> = memo(function DraggableItem(props: IDraggableItemProps)
{
	const { item, id, draggingId, rowTotal, colIndex, rowIndex, onEditClick, moveDraggableItem, addSourceItem, remove, setDragging } = props;
	//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + '.props', props);
	const [collect, connectDragSource, dragPreview] = useDrag
	(
		() => ({
			type: 'ITEM',
			item: (monitor: DragSourceMonitor) =>
			{
				//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + '.item/begin', props, monitor);
				return {
					id,
					colIndex,
					rowIndex,
					origId: id
				};
			},
			collect: (monitor: DragSourceMonitor) => (
			{
				isDragging: monitor.isDragging(),
				didDrop   : monitor.didDrop(),
			}),
			end: (item: IDragItemState, monitor: DragSourceMonitor) =>
			{
				//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + '.end', item, props);
				if ( !monitor.didDrop() )
				{
					remove(item, monitor.getItemType());
				}
				else
				{
					setDragging('');
				}
			},
			canDrag: (monitor: DragSourceMonitor) =>
			{
				return true;
			},
		}),
		[id, colIndex, rowIndex, remove, setDragging],
	);
	const [dropCollect, connectDropTarget] = useDrop
	(
		() => ({
			accept: ['ITEM'],
			collect: (monitor: DropTargetMonitor) => (
			{
				isOver : monitor.isOver(),
				didDrop: monitor.didDrop(),
			}),
			hover(item: IDragItemState, monitor: DropTargetMonitor)
			{
				const dragColIndex : number = item.colIndex;
				const dragRowIndex : number = item.rowIndex;
				const hoverColIndex: number = colIndex;
				const hoverRowIndex: number = rowIndex;

				// Don't replace items with themselves
				if ( id === item.id || (dragColIndex === hoverColIndex && dragRowIndex === hoverRowIndex) )
				{
					return;
				}
				//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + '.hover', {id: item.id, hoverId: id, dragColIndex, dragRowIndex, hoverColIndex, hoverRowIndex});
				if ( dragColIndex != -1 && dragRowIndex != -1 )
				{
					if ( Math.abs(dragRowIndex - hoverRowIndex) > 1 )
					{
						return;
					}
					moveDraggableItem(dragColIndex, dragRowIndex, hoverColIndex, hoverRowIndex);
				}
				else
				{
					addSourceItem(item.id, hoverColIndex, hoverRowIndex)
				}

				// Time to actually perform the action

				// Note: we're mutating the monitor item here!
				// Generally it's better to avoid mutations,
				// but it's good here for the sake of performance
				// to avoid expensive index searches.
				item.id       = props.id;
				item.colIndex = hoverColIndex;
				item.rowIndex = hoverRowIndex;
			},
			canDrop(item: IDragItemState, monitor: DropTargetMonitor)
			{
				//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + '.canDrop ' + typeof(item), item);
				return true;
			},
		}),
		[id, colIndex, rowIndex, moveDraggableItem, addSourceItem],
	);
	//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + ' collected', collect, dropCollect);
	const [dragging, setLocalDragging] = useState(false);
	if ( dragging != collect.isDragging )
	{
		//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + ' dragging changed', collect.isDragging);
		if ( collect.isDragging )
		{
			props.setDragging(props.id);
		}
		if ( collect.didDrop )
		{
			props.setDragging('');
		}
		setLocalDragging(collect.isDragging);
	}

	const opacity = id == draggingId ? 0 : 1;
	return (
			<div ref={ (node) => connectDragSource(connectDropTarget(node)) }
				draggable
				className='grab'
				style={{ ...style, opacity, flexBasis: `${100 / rowTotal}%` }}>
				{ item ? item.NAME : 'undefined item' }
				<span style={ {cursor: 'pointer'} } onClick={ () => onEditClick(id) }><FontAwesomeIcon icon="edit" size="lg" /></span>
			</div>
	);
});

export default DraggableItem;
