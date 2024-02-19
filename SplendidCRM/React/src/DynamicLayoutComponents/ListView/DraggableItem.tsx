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
import IDragItemState                                             from '../../types/IDragItemState'    ;
// 3. Scripts. 
import Sql                                                        from '../../scripts/Sql'             ;
import L10n                                                       from '../../scripts/L10n'            ;

const style: React.CSSProperties =
{
	border         : '1px solid grey',
	backgroundColor: '#eeeeee',
	padding        : '2px',
	margin         : '2px',
	borderRadius   : '2px',
	width          : '90%',
	overflowX      : 'hidden',
	transition     : 'flex-basis 0.2s ease, order 0.2s ease',
	display        : 'flex',
	alignItems     : 'center',
	justifyContent : 'space-between',
};

interface IDraggableItemProps
{
	id                : string;
	item              : any;
	onEditClick       : (id: string) => void;
	fieldIndex        : number;
	colIndex          : number;
	rowIndex          : number;
	isDragging?       : boolean;
	didDrop?          : boolean;
	rowTotal?         : number;
	setDragging       : (id: string) => void;
	draggingId        : string;
	moveDraggableItem : (id: string, hoverColIndex: number, hoverRowIndex: number, didDrop: boolean) => void;
	remove            : (item, type) => void;
}

// 12/31/2023 Paul.  react-dnd v15 requires use of hooks. 
const DraggableItem: FC<IDraggableItemProps> = memo(function DraggableItem(props: IDraggableItemProps)
{
	const { item, id, draggingId, rowTotal, fieldIndex, colIndex, rowIndex, onEditClick, moveDraggableItem, remove, setDragging } = props;
	//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + '.props', props);
	const [collect, connectDragSource, dragPreview] = useDrag
	(
		() => ({
			type: 'ITEM',
			item: (monitor: DragSourceMonitor) =>
			{
				//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + '.item/begin', props, monitor);
				return {
					id        : id        ,
					fieldIndex: fieldIndex,
					colIndex  : colIndex  ,
					rowIndex  : rowIndex  ,
					origId    : id        ,
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
				if ( monitor.didDrop() )
				{
					// 12/31/2023 Paul.  Upgrade DnD. 
					const id            : string = item.id        ;
					const hoverColIndex : number = item.colIndex  ;
					const hoverRowIndex : number = item.rowIndex  ;
					moveDraggableItem(id, hoverColIndex, hoverRowIndex, true);
				}
				else
				{
					remove(item, monitor.getItemType());
				}
				setDragging('');
			},
			canDrag: (monitor: DragSourceMonitor) =>
			{
				return true;
			},
		}),
		[id, fieldIndex, colIndex, rowIndex, moveDraggableItem, remove, setDragging],
	);
	//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + ' collected', collect);
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
	let DATA_FIELD : string = null;
	let HEADER_TEXT: string = null;
	if ( item )
	{
		DATA_FIELD  = item.DATA_FIELD;
		if ( !Sql.IsEmptyString(item.HEADER_TEXT) )
		{
			HEADER_TEXT = L10n.Term(item.HEADER_TEXT)
		}
		if ( item.COLUMN_TYPE == 'TemplateColumn' )
		{
			if ( item.DATA_FORMAT == 'Hover' )
			{
				DATA_FIELD  = L10n.Term('DynamicLayout.LBL_HOVER_TYPE');
				HEADER_TEXT = item.URL_FIELD;
			}
			else if ( item.DATA_FORMAT == 'ImageButton' )
			{
				DATA_FIELD  = L10n.Term('DynamicLayout.LBL_IMAGE_BUTTON_TYPE');
				HEADER_TEXT = item.URL_FIELD;
			}
			else if ( item.DATA_FORMAT == 'JavaScript' )
			{
				DATA_FIELD = L10n.Term('DynamicLayout.LBL_JAVASCRIPT_TYPE');
			}
		}
	}
	return (
			<div ref={ (node) => connectDragSource(node) }
				draggable
				className='grab'
				style={{ ...style, opacity, flexBasis: `${100 / rowTotal}%` }}
				id={ 'ctlDynamicLayout_' + id }
			>
				{ item
				? DATA_FIELD
				: null
				}
				<br />
				{ item
				? HEADER_TEXT
				: null
				}
				{ item && (item.FIELD_TYPE != 'Blank' && item.FIELD_TYPE != 'Separator')
				? <span style={ {cursor: 'pointer'} } onClick={ () => onEditClick(id) }>
					<FontAwesomeIcon icon="edit" size="lg" />
				</span>
				: null
				}
			</div>
	);
});

export default DraggableItem;
