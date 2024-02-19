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

const style: React.CSSProperties =
{
	border         : '1px dashed grey',
	backgroundColor: '#eeeeee',
	padding        : '2px',
	margin         : '2px',
	borderRadius   : '2px',
	width          : '200px',
};

interface ISourceTemplateColumnProps
{
	TITLE: string;
	removeRow: (index: number) => void;
	isDragging?: boolean;
}

// 12/31/2023 Paul.  react-dnd v15 requires use of hooks. 
const SourceTemplateColumn: FC<ISourceTemplateColumnProps> = memo(function SourceTemplateColumn(props: ISourceTemplateColumnProps)
{
	const { TITLE, removeRow } = props;
	//console.log((new Date()).toISOString() + ' ' + 'SourceTemplateColumn' + '.props', props);
	const [collect, connectDragSource, dragPreview] = useDrag
	(
		() => ({
			type: 'ROW',
			item: (monitor: DragSourceMonitor) =>
			{
				//console.log((new Date()).toISOString() + ' ' + 'SourceTemplateColumn' + '.item/begin', props, monitor);
				return {
					id         : uuidFast(),
					index      : -1,
					COLUMN_TYPE: 'NewTemplateColumn'
				};
			},
			collect: (monitor: DragSourceMonitor) => (
			{
				isDragging: monitor.isDragging()
			}),
			end: (item: IDragItemState, monitor: DragSourceMonitor) =>
			{
				//console.log((new Date()).toISOString() + ' ' + 'SourceTemplateColumn' + '.end', item, props);
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
	//console.log((new Date()).toISOString() + ' ' + 'SourceTemplateColumn' + ' collected', collect);
	return (
			<div ref={ (node) => connectDragSource(node) }
				style={ { ...style } }>
				{ TITLE }
			</div>
	);
});

export default SourceTemplateColumn;
