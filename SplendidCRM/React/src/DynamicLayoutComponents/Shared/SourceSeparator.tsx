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
import IDragItemState                                             from '../../types/IDragItemState'  ;
// 3. Scripts. 
import { uuidFast }                                               from '../../scripts/utility'       ;
// 4. Components and Views. 

const style: React.CSSProperties =
{
	border         : '1px dashed grey',
	backgroundColor: '#eeeeee',
	padding        : '2px',
	margin         : '2px',
	borderRadius   : '2px',
	width          : '200px',
};

interface ISourceSeparatorProps
{
	TITLE               : string;
	createItemFromSource: (item: any) => any;
	moveDraggableItem   : (id: string, hoverColIndex: number, hoverRowIndex: number, didDrop: boolean) => void;
	remove              : (item, type) => void;
}

// 12/31/2023 Paul.  react-dnd v15 requires use of hooks. 
const SourceSeparator: FC<ISourceSeparatorProps> = memo(function SourceSeparator(props: ISourceSeparatorProps)
{
	const{ TITLE, createItemFromSource, moveDraggableItem, remove } = props;
	//console.log((new Date()).toISOString() + ' ' + 'SourceHeader' + '.props', props);
	const [collect, connectDragSource, dragPreview] = useDrag
	(
		() => ({
			type: 'ITEM',
			item: (monitor: DragSourceMonitor) =>
			{
				//console.log((new Date()).toISOString() + ' ' + 'SouceBlank' + '.item/begin', props, monitor);
				return createItemFromSource(
					{
						id          : uuidFast() ,
						index       : -1         ,
						ID          : null       ,
						FIELD_TYPE  : 'Separator',
						DATA_LABEL  : null       ,
						DATA_FIELD  : null       ,
						DATA_FORMAT : null       ,
						URL_FIELD   : null       ,
						URL_FORMAT  : null       ,
						URL_TARGET  : null       ,
						MODULE_TYPE : null       ,
						LIST_NAME   : null       ,
						COLSPAN     : null       ,
						TOOL_TIP    : null       ,
						PARENT_FIELD: null       ,
					});
			},
			collect: (monitor: DragSourceMonitor) => (
			{
				isDragging: monitor.isDragging()
			}),
			end: (item: IDragItemState, monitor: DragSourceMonitor) =>
			{
				//console.log((new Date()).toISOString() + ' ' + 'SouceItem' + '.end', item, props);
				if ( monitor.didDrop() )
				{
					// 12/31/2023 Paul.  Upgrade DnD. 
					const id           : string = item.id        ;
					const hoverColIndex: number = item.colIndex  ;
					const hoverRowIndex: number = item.rowIndex  ;
					moveDraggableItem(id, hoverColIndex, hoverRowIndex, true);
				}
				else
				{
					// 03/14/2020 Paul.  We need to remove the ghost item created above. 
					remove(item, 'ITEM');
				}
			},
			canDrag: (monitor: DragSourceMonitor) =>
			{
				return true;
			},
		}),
		[createItemFromSource, moveDraggableItem, remove],
	);
	//console.log((new Date()).toISOString() + ' ' + 'SourceHeader' + ' collected', collect, dropCollect);
	return (
			<div ref={ (node) => connectDragSource(node) }
				className='grab DynamicLayoutComponents-Shared-SourceSeparator'
				style={ { ...style } }>
				{ TITLE }
			</div>
	);
});

export default SourceSeparator;
