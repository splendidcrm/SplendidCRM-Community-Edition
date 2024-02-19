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
import React, { memo, FC }                                        from 'react';
import { useDrag, useDrop, DragSourceMonitor, DropTargetMonitor } from 'react-dnd';
// 2. Store and Types. 
import IDragItemState                                             from '../types/IDragItemState'  ;
// 3. Scripts. 
// 4. Components and Views. 

const style: React.CSSProperties =
{
	border         : '1px solid grey',
	padding        : '0.5rem 1rem',
	backgroundColor: 'white',
	margin         : '.125em .25em',
	borderRadius   : '.25em',
};

interface ISouceItemProps
{
	item                : any;
	isAppInUse          : boolean;
	createItemFromSource: (item: any) => any;
	moveDraggableItem   : (dragColIndex: number, dragRowIndex: number, hoverCOlIndex: number, hoverRowIndex: number) => void;
	remove              : (item, type) => void;
}

// 12/31/2023 Paul.  react-dnd v15 requires use of hooks. 
const SouceItem: FC<ISouceItemProps> = memo(function SouceItem(props: ISouceItemProps)
{
	const{ item, isAppInUse, createItemFromSource, moveDraggableItem, remove } = props;
	//console.log((new Date()).toISOString() + ' ' + 'SouceItem' + '.props', props);
	const [collect, connectDragSource, dragPreview] = useDrag
	(
		() => ({
			type: 'ITEM',
			item: (monitor: DragSourceMonitor) =>
			{
				//console.log((new Date()).toISOString() + ' ' + 'SouceItem' + '.item/begin', item, props, monitor);
				return createItemFromSource(props.item);
			},
			collect: (monitor: DragSourceMonitor) => (
			{
				isDragging: monitor.isDragging()
			}),
			end: (item: IDragItemState, monitor: DragSourceMonitor) =>
			{
				//console.log((new Date()).toISOString() + ' ' + 'SouceItem' + '.end', item, props);
				if ( !monitor.didDrop() )
				{
					//const id           : string = item.id        ;
					//const hoverColIndex: number = item.colIndex  ;
					//const hoverRowIndex: number = item.rowIndex  ;
					//props.moveDraggableItem(id, hoverColIndex, hoverRowIndex);
				}
				else
				{
					// 03/14/2020 Paul.  We need to remove the ghost item created above. 
					//remove( item, monitor.getItemType());
				}
			},
			canDrag: (monitor: DragSourceMonitor) =>
			{
				return true;
			},
		}),
		[createItemFromSource, moveDraggableItem, remove],
	);
	//console.log((new Date()).toISOString() + ' ' + 'SouceItem' + ' collected', collect, dropCollect);
	return (
			<div ref={ (node) => connectDragSource(node) }
				className='grab DashboardComponents-SourceItem'
				style={ { ...style, display: (isAppInUse ? 'none' : null) } }>
				{ item.NAME }
				<br />
				<small>{ item.MODULE_NAME }</small>
			</div>
	);
});

export default SouceItem;
