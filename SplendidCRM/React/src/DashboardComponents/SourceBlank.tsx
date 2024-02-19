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

interface ISourceBlankProps
{
	TITLE               : string;
	createItemFromSource: (item: any) => any;
}

// 12/31/2023 Paul.  react-dnd v15 requires use of hooks. 
const SourceBlank: FC<ISourceBlankProps> = memo(function SourceBlank(props: ISourceBlankProps)
{
	const{ TITLE, createItemFromSource } = props;
	//console.log((new Date()).toISOString() + ' ' + 'SourceBlank' + '.props', props);
	const [collect, connectDragSource, dragPreview] = useDrag
	(
		() => ({
			type: 'ITEM',
			item: (monitor: DragSourceMonitor) =>
			{
				//console.log((new Date()).toISOString() + ' ' + 'SouceBlank' + '.item/begin', props, monitor);
				return createItemFromSource(
					{
						id               : uuidFast(),
						index            : -1,
						NAME             : '(blank)',
						CATEGORY         : null,
						MODULE_NAME      : null,
						TITLE            : '(blank)',
						SETTINGS_EDITVIEW: null,
						IS_ADMIN         : false,
						APP_ENABLED      : true,
						SCRIPT_URL       : null,
						DEFAULT_SETTINGS : null,
				});
			},
			collect: (monitor: DragSourceMonitor) => (
			{
				isDragging: monitor.isDragging()
			}),
			end: (item: IDragItemState, monitor: DragSourceMonitor) =>
			{
				//console.log((new Date()).toISOString() + ' ' + 'SouceBlank' + '.end', item, props);
			},
			canDrag: (monitor: DragSourceMonitor) =>
			{
				return true;
			},
		}),
		[createItemFromSource],
	);
	//console.log((new Date()).toISOString() + ' ' + 'SourceBlank' + ' collected', collect, dropCollect);
	return (
			<div ref={ (node) => connectDragSource(node) }
				className="grab DashboardComponents-SourceBlank"
				style={ { ...style } }>
				{ TITLE }
			</div>
	);
});

export default SourceBlank;
