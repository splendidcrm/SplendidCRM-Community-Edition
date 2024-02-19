/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

import React, { memo, FC, useState }                              from 'react';
import { useDrag, useDrop, DragSourceMonitor, DropTargetMonitor } from 'react-dnd';
// 2. Store and Types. 
import IDragItemState                                             from '../../types/IDragItemState'  ;
// 3. Scripts. 
// 4. Components and Views. 

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
	children          : React.ReactNode;
}

interface IDraggableCellState
{
	isOver            : boolean;
	isDragging?       : boolean;
}

// 12/31/2023 Paul.  react-dnd v15 requires use of hooks. 
const DraggableCell: FC<IDraggableCellProps> = memo(function DraggableCell(props: IDraggableCellProps)
{
	const { width, rowTotal, colIndex, rowIndex, moveDraggableItem, addSourceItem, children } = props;
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
				//console.log((new Date()).toISOString() + ' ' + 'DraggableCell' + '.hover', props, monitor);
				const id            : string = item.id        ;
				const dragFieldIndex: number = item.fieldIndex;
				const dragColIndex  : number = item.colIndex  ;
				const dragRowIndex  : number = item.rowIndex  ;
				const hoverColIndex : number = colIndex;
				const hoverRowIndex : number = rowIndex;
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
					moveDraggableItem(id, hoverColIndex, hoverRowIndex, false);
				}
				else
				{
					//console.log((new Date()).toISOString() + ' ' + 'DraggableCell' + '.hover', props, monitor);
					const id: string = item.id;
					addSourceItem(id, hoverColIndex, hoverRowIndex);
				}

				// Time to actually perform the action

				// Note: we're mutating the monitor item here!
				// Generally it's better to avoid mutations,
				// but it's good here for the sake of performance
				// to avoid expensive index searches.
				item.colIndex = hoverColIndex;
				item.rowIndex = hoverRowIndex;
			},
			canDrop(item: IDragItemState, monitor: DropTargetMonitor)
			{
				//console.log((new Date()).toISOString() + ' ' + 'DraggableCell' + '.canDrop ' + typeof(item), item);
				return true;
			},
		}),
		[colIndex, rowIndex, moveDraggableItem, addSourceItem],
	);
	//console.log((new Date()).toISOString() + ' ' + 'DraggableCell' + ' collected', collect, dropCollect);

	return (
			<td ref={ (node) => connectDropTarget(node) }
				style={{ width, border: '1px dashed grey' }}>
				{ children }
			</td>
	);
});

export default DraggableCell;
