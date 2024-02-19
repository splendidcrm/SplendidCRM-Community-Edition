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
import { useDrag, useDrop, DragSourceMonitor, DropTargetMonitor } from 'react-dnd';
// 2. Store and Types. 
import IDragItemState                                             from '../../types/IDragItemState'  ;
// 3. Scripts. 
import L10n                                                       from '../../scripts/L10n'               ;

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
};

interface IDraggableFieldProps
{
	id                : string;
	item              : any;
	colIndex          : number;
	rowIndex          : number;
	isDragging?       : boolean;
	didDrop?          : boolean;
	rowTotal?         : number;
	setDragging       : (id: string) => void;
	draggingId        : string;
	moveDraggableItem : (dragColIndex: number, dragRowIndex: number, hoverCOlIndex: number, hoverRowIndex: number) => void;
}

// 12/31/2023 Paul.  react-dnd v15 requires use of hooks. 
const DraggableField: FC<IDraggableFieldProps> = memo(function DraggableField(props: IDraggableFieldProps)
{
	const { item, id, draggingId, isDragging, rowTotal, colIndex, rowIndex, moveDraggableItem, setDragging } = props;
	//console.log((new Date()).toISOString() + ' ' + 'DraggableField' + '.props', props);
	const [collect, connectDragSource, dragPreview] = useDrag
	(
		() => ({
			type: 'ITEM',
			item: (monitor: DragSourceMonitor) =>
			{
				//console.log((new Date()).toISOString() + ' ' + 'DraggableField' + '.item/begin', props, monitor);
				return {
					id      : id,
					colIndex: colIndex,
					rowIndex: rowIndex,
					origId  : id,
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
					// 03/27/2022 Paul.  There is no remove. 
					//remove(item, monitor.getItemType());
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
		[id, colIndex, rowIndex, setDragging],
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
				//console.log((new Date()).toISOString() + ' ' + 'DraggableField' + '.hover', props, monitor);
				const dragColIndex : number = item.colIndex;
				const dragRowIndex : number = item.rowIndex;
				const hoverColIndex: number = colIndex;
				const hoverRowIndex: number = rowIndex;

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
					moveDraggableItem(dragColIndex, dragRowIndex, hoverColIndex, hoverRowIndex);
				}
				else
				{
					// 03/27/2022 Paul.  There is no add. 
					//const id: string = item.id;
					//addSourceItem(id, hoverColIndex, hoverRowIndex)
				}

				// Time to actually perform the action

				// Note: we're mutating the monitor item here!
				// Generally it's better to avoid mutations,
				// but it's good here for the sake of performance
				// to avoid expensive index searches.
				item.id       = id;
				item.colIndex = hoverColIndex;
				item.rowIndex = hoverRowIndex;
			},
			canDrop(item: IDragItemState, monitor: DropTargetMonitor)
			{
				//console.log((new Date()).toISOString() + ' ' + 'DraggableField' + '.canDrop ' + typeof(item), item);
				return true;
			},
		}),
		[id, colIndex, rowIndex, moveDraggableItem],
	);
	//console.log((new Date()).toISOString() + ' ' + 'DraggableField' + ' collected', collect, dropCollect);
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

	const opacity = isDragging ? 1 : 1;
	return (
			<div ref={ (node) => connectDragSource(connectDropTarget(node)) }
				draggable
				className='grab'
				style={{ ...style, opacity, backgroundColor: (id == draggingId ? 'grey' : 'lightgrey'), flexBasis: `${100 / rowTotal}%` }}>
				<div>
					<h3 style={ {display: 'inline', color: 'black'} }>
					{ item.HEADER_TEXT
					? L10n.Term(item.HEADER_TEXT)
					: null
					}
					</h3>
					<br />
					{ item.DATA_FIELD }
					<br />
					{ item.COLUMN_TYPE } { item.DATA_FORMAT }
				</div>
			</div>
	);
});

export default DraggableField;
