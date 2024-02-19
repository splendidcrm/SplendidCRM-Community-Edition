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
import L10n                                                       from '../../scripts/L10n'          ;

const style: React.CSSProperties =
{
	border         : '1px solid grey',
	backgroundColor: '#eeeeee',
	padding        : '2px',
	margin         : '2px',
	borderRadius   : '2px',
	width          : '200px',
	overflowX      : 'hidden',
};

interface ISouceItemProps
{
	ModuleName          : string;
	item                : any;
	isFieldInUse        : boolean;
	createItemFromSource: (item: any) => any;
	moveDraggableItem   : (id: string, hoverColIndex: number, hoverRowIndex: number, didDrop: boolean) => void;
	remove              : (item, type) => void;
}

// 12/31/2023 Paul.  react-dnd v15 requires use of hooks. 
const SouceItem: FC<ISouceItemProps> = memo(function SouceItem(props: ISouceItemProps)
{
	const{ ModuleName, item, isFieldInUse, createItemFromSource, moveDraggableItem, remove } = props;
	//console.log((new Date()).toISOString() + ' ' + 'SouceItem' + '.props', props);
	const [collect, connectDragSource, dragPreview] = useDrag
	(
		() => ({
			type: 'ITEM',
			item: (monitor: DragSourceMonitor) =>
			{
				//console.log((new Date()).toISOString() + ' ' + 'SouceItem' + '.item/begin', item, props, monitor);
				return createItemFromSource(Object.assign(props.item, { id: item.DATA_FIELD} ));
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
		[item, createItemFromSource, moveDraggableItem, remove],
	);
	//console.log((new Date()).toISOString() + ' ' + 'SouceItem' + ' collected', collect, dropCollect);
	// 03/14/2020 Paul.  When field is in use, we must hide it instead of not creating it as failure to create would prevent endDrag from firing. 
	return (
			<div ref={ (node) => connectDragSource(node) }
				className='grab DynamicLayoutComponents-Shared-SourceItem'
				style={ { ...style, display: (isFieldInUse ? 'none' : null) } }
				>
				{ item.ColumnName }
				<br />
				{ L10n.TableColumnName(ModuleName, item.ColumnName) }
			</div>
	);
});

export default SouceItem;
