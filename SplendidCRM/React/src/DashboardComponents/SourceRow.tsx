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
import { uuidFast }                                               from '../scripts/utility'       ;
// 4. Components and Views. 

const style: React.CSSProperties =
{
	border         : '1px dashed grey',
	padding        : '0.5rem 1rem',
	backgroundColor: 'white',
	margin         : '0 .25em',
};

interface ISourceRowProps
{
	TITLE: string;
	removeRow: (index: number) => void;
	isDragging?: boolean;
}

// 12/31/2023 Paul.  react-dnd v15 requires use of hooks. 
const SourceRow: FC<ISourceRowProps> = memo(function SourceRow(props: ISourceRowProps)
{
	const { TITLE, removeRow } = props;
	//console.log((new Date()).toISOString() + ' ' + 'SourceRow' + '.props', props);
	const [collect, connectDragSource, dragPreview] = useDrag
	(
		() => ({
			type: 'ROW',
			item: (monitor: DragSourceMonitor) =>
			{
				//console.log((new Date()).toISOString() + ' ' + 'SourceRow' + '.item/begin', props, monitor);
				return {
					id: uuidFast(),
					index: -1
				};
			},
			collect: (monitor: DragSourceMonitor) => (
			{
				isDragging: monitor.isDragging()
			}),
			end: (item: IDragItemState, monitor: DragSourceMonitor) =>
			{
				//console.log((new Date()).toISOString() + ' ' + 'SourceRow' + '.end', item, props);
				if ( !monitor.didDrop() )
				{
					removeRow(item.index);
				}
			},
			canDrag: (monitor: DragSourceMonitor) =>
			{
				return true;
			},
		}),
		[removeRow],
	);
	//console.log((new Date()).toISOString() + ' ' + 'SourceRow' + ' collected', collect);
	return (
			<div ref={ (node) => connectDragSource(node) }
				style={ { ...style } }>
				{ TITLE }
			</div>
	);
});

export default SourceRow;
