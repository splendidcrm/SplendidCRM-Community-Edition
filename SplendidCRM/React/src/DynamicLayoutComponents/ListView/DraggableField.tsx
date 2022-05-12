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
import * as React from 'react';
import { DragSource, DropTarget, ConnectDropTarget, ConnectDragSource, DropTargetMonitor, DropTargetConnector, DragSourceConnector, DragSourceMonitor } from 'react-dnd';
// 3. Scripts. 
import L10n                                         from '../../scripts/L10n'               ;


const style: React.CSSProperties =
{
	border         : '1px dashed grey',
	paddingTop     : '0.5em',
	paddingBottom  : '0.5em',
	paddingLeft    : '1em',
	paddingRight   : '1em',
	marginBottom   : '.5rem',
	backgroundColor: 'lightgrey',
	cursor         : 'move',
	display        : 'flex',
};

interface IDraggableFieldProps
{
	id                : string;
	item              : any;
	colIndex          : number;
	rowIndex          : number;
	isDragging?       : boolean;
	didDrop?          : boolean;
	rowTotal?         : number;
	setDragging       : (id: string) => void;
	draggingId        : string;
	connectDragSource?: ConnectDragSource;
	connectDropTarget?: ConnectDropTarget;
	moveDraggableItem : (dragColIndex: number, dragRowIndex: number, hoverCOlIndex: number, hoverRowIndex: number) => void;
}

const source =
{
	beginDrag(props: IDraggableFieldProps)
	{
		//console.log((new Date()).toISOString() + ' ' + 'DraggableField' + '.beginDrag', props);
		return {
			id      : props.id,
			colIndex: props.colIndex,
			rowIndex: props.rowIndex,
			origId  : props.id,
		};
	},
	endDrag(props: IDraggableFieldProps, monitor: DragSourceMonitor)
	{
		//console.log((new Date()).toISOString() + ' ' + 'DraggableField' + '.endDrag', props, monitor);
		if ( !monitor.didDrop() )
		{
			// 03/27/2022 Paul.  There is no remove. 
			//props.remove(monitor.getItem(), monitor.getItemType());
		}
	}
};

const itemTarget =
{
	hover(props: IDraggableFieldProps, monitor: DropTargetMonitor, component: DraggableField)
	{
		const dragColIndex : number = monitor.getItem().colIndex;
		const dragRowIndex : number = monitor.getItem().rowIndex;
		const hoverColIndex: number = props.colIndex;
		const hoverRowIndex: number = props.rowIndex;
		//console.log((new Date()).toISOString() + ' ' + 'DraggableField' + '.hover', props, monitor, component);

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
			props.moveDraggableItem(dragColIndex, dragRowIndex, hoverColIndex, hoverRowIndex);
		}
		else
		{
			// 03/27/2022 Paul.  There is no add. 
			//const id: string = monitor.getItem().id;
			//props.addSourceItem(id, hoverColIndex, hoverRowIndex)
		}

		// Time to actually perform the action

		// Note: we're mutating the monitor item here!
		// Generally it's better to avoid mutations,
		// but it's good here for the sake of performance
		// to avoid expensive index searches.
		monitor.getItem().id       = props.id;
		monitor.getItem().colIndex = hoverColIndex;
		monitor.getItem().rowIndex = hoverRowIndex;
	},
};

function collect(connect: DragSourceConnector, monitor: DragSourceMonitor)
{
	//console.log((new Date()).toISOString() + ' ' + 'DraggableField' + '.collect', connect, monitor);
	return {
		connectDragSource: connect.dragSource(),
		isDragging       : monitor.isDragging(),
		didDrop          : monitor.didDrop(),
	};
}

function dropCollect(connect: DropTargetConnector)
{
	//console.log((new Date()).toISOString() + ' ' + 'DraggableField' + '.dropCollect', connect);
	return {
		connectDropTarget: connect.dropTarget()
	};
}

class DraggableField extends React.Component<IDraggableFieldProps>
{
	constructor(props: IDraggableFieldProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
	}

	shouldComponentUpdate(nextProps: IDraggableFieldProps)
	{
		if ( this.props.draggingId !== nextProps.draggingId )
		{
			if ( nextProps.draggingId !== nextProps.id )
			{
				return false;
			}
		}
		return true;
	}

	componentWillUpdate(nextProps)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentWillUpdate', nextProps);
		// 03/27/2022 Paul.  We seem to be getting a second drag event.  Check dragginId before setting. 
		if ( nextProps.isDragging && nextProps.draggingId == '' )
		{
			nextProps.setDragging(nextProps.id);
		}
		if ( nextProps.didDrop && nextProps.draggingId != '' )
		{
			nextProps.setDragging('');
		}
	}

	public render()
	{
		const { item, id, draggingId, isDragging, rowTotal, connectDragSource, connectDropTarget, colIndex, children } = this.props;
		const opacity = isDragging ? 1 : 1;
		return (
			connectDragSource &&
			connectDropTarget &&
			connectDragSource(
				connectDropTarget(
					<div draggable className='grab' style={{ ...style, opacity, backgroundColor: (id == draggingId ? 'grey' : 'lightgrey'), flexBasis: `${100 / rowTotal}%` }}>
						<div>
							<h3 style={ {display: 'inline', color: 'black'} }>
							{ item.HEADER_TEXT
							? L10n.Term(item.HEADER_TEXT)
							: null
							}
							</h3>
							<br />
							{ item.DATA_FIELD }
							<br />
							{ item.COLUMN_TYPE } { item.DATA_FORMAT }
						</div>
					</div>
				)
			)
		);
	}
}

export default DropTarget('ITEM', itemTarget, dropCollect)(DragSource('ITEM', source, collect)(DraggableField));
