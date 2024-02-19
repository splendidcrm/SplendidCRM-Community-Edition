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
import { FontAwesomeIcon }                                        from '@fortawesome/react-fontawesome';
import { useDrag, useDrop, DragSourceMonitor, DropTargetMonitor } from 'react-dnd';
// 2. Store and Types. 
import IDragItemState                                             from '../types/IDragItemState'  ;
// 3. Scripts. 
// 4. Components and Views. 

interface IDraggableRemoveProps
{
	isOver?           : boolean
	remove            : (item, type) => void;
}

// 12/31/2023 Paul.  react-dnd v15 requires use of hooks. 
const DraggableRemove: FC<IDraggableRemoveProps> = memo(function DraggableRemove(props: IDraggableRemoveProps)
{
	const { remove } = props;
	//console.log((new Date()).toISOString() + ' ' + 'DraggableRemove' + '.props', props);
	const [dropCollect, connectDropTarget] = useDrop
	(
		() => ({
			accept: ['ITEM', 'ROW'],
			collect: (monitor: DropTargetMonitor) => (
			{
				isOver: monitor.isOver()
			}),
			drop(item: IDragItemState, monitor: DropTargetMonitor)
			{
				//console.log((new Date()).toISOString() + ' ' + 'DraggableRemove' + '.drop', props);
				remove(item, monitor.getItemType());
			},
			canDrop(item: IDragItemState, monitor: DropTargetMonitor)
			{
				//console.log((new Date()).toISOString() + ' ' + 'DraggableRemove' + '.canDrop ' + typeof(item), item);
				return true;
			},
		}),
		[remove],
	);
	//console.log((new Date()).toISOString() + ' ' + 'DraggableRemove' + ' collected', collect, dropCollect);
	return (
			<div ref={ (node) => connectDropTarget(node) }
				style={{ padding: '1em 0', display: 'inline-block' }}>
				<FontAwesomeIcon icon='trash-alt' size='4x' />
			</div>
	);
});

export default DraggableRemove;
