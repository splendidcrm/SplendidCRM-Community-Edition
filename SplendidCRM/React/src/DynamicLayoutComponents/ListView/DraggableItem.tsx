/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

import * as React from 'react';
import { FontAwesomeIcon }                 from '@fortawesome/react-fontawesome';
import { DragSource, DropTarget, ConnectDropTarget, ConnectDragSource, DropTargetMonitor, DropTargetConnector, DragSourceConnector, DragSourceMonitor } from 'react-dnd';
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                 from '../../scripts/Sql';
import L10n                                from '../../scripts/L10n';

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
	connectDragSource?: ConnectDragSource;
	moveDraggableItem : (id: string, hoverColIndex: number, hoverRowIndex: number, didDrop: boolean) => void;
	remove            : (item, type) => void;
}

const source =
{
	beginDrag(props: IDraggableItemProps)
	{
		//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + '.beginDrag', props);
		return {
			id        : props.id        ,
			fieldIndex: props.fieldIndex,
			colIndex  : props.colIndex  ,
			rowIndex  : props.rowIndex  ,
			origId    : props.id        ,
		};
	},
	endDrag(props: IDraggableItemProps, monitor: DragSourceMonitor)
	{
		const { fieldIndex, colIndex, rowIndex } = props;
		//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + '.endDrag', props, monitor.getItem(), monitor);
		if ( monitor.didDrop() )
		{
			const id            : string = monitor.getItem().id        ;
			const hoverColIndex : number = monitor.getItem().colIndex  ;
			const hoverRowIndex : number = monitor.getItem().rowIndex  ;
			props.moveDraggableItem(id, hoverColIndex, hoverRowIndex, true);
		}
		else
		{
			props.remove(monitor.getItem(), monitor.getItemType());
		}
	}
};

function collect(connect: DragSourceConnector, monitor: DragSourceMonitor)
{
	//console.log((new Date()).toISOString() + ' ' + 'DraggableItem' + '.collect', connect, monitor);
	return {
		connectDragSource: connect.dragSource(),
		isDragging       : monitor.isDragging(),
		didDrop          : monitor.didDrop(),
	};
}

class DraggableItem extends React.Component<IDraggableItemProps>
{
	constructor(props: IDraggableItemProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
	}

	shouldComponentUpdate(nextProps: IDraggableItemProps)
	{
		if ( this.props.draggingId !== nextProps.draggingId && nextProps.draggingId == nextProps.id )
		{
			return true;
		}
		else if ( this.props.isDragging != nextProps.isDragging || this.props.didDrop != nextProps.didDrop )
		{
			return true;
		}
		else if ( this.props.fieldIndex != nextProps.fieldIndex || this.props.colIndex != nextProps.colIndex || this.props.rowIndex != nextProps.rowIndex )
		{
			return true;
		}
		else if ( this.props.id != nextProps.id || JSON.stringify(this.props.item) != JSON.stringify(nextProps.item) )
		{
			return true;
		}
		return false;
	}

	componentWillUpdate(nextProps)
	{
		if ( nextProps.isDragging )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentWillUpdate', nextProps);
			nextProps.setDragging(nextProps.id);
		}
		if ( nextProps.didDrop && nextProps.id == nextProps.draggingId )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentWillUpdate', nextProps);
			nextProps.setDragging('');
		}
	}

	public render()
	{
		const { item, id, draggingId, rowTotal, connectDragSource, colIndex, onEditClick } = this.props;
		const opacity = id == draggingId ? 0 : 1;
		if ( connectDragSource )
		{
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
				connectDragSource(
					<div
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
				)
			);
		}
		else
		{
			return null;
		}
	}
}

export default DragSource('ITEM', source, collect)(DraggableItem);
