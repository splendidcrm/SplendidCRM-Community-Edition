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
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { DragSource, DropTarget, ConnectDropTarget, ConnectDragSource, DropTargetMonitor, DropTargetConnector, DragSourceConnector, DragSourceMonitor } from 'react-dnd';
// 2. Store and Types. 
// 3. Scripts. 
import Credentials   from '../../../scripts/Credentials'         ;
import SplendidCache from '../../../scripts/SplendidCache'       ;
// 4. Components and Views. 

const style: React.CSSProperties =
{
	margin         : '0',
	padding        : '0',
	cursor         : 'move',
	verticalAlign  : 'middle',
};

interface IDraggableRowProps
{
	className         : string;
	id                : any;
	index             : number;
	isDragging?       : boolean;
	connectDragSource?: Function; // ConnectDragSource;
	connectDropTarget?: Function; // ConnectDropTarget;
	length            : number;
	moveDraggableRow  : (dragIndex: number, hoverIndex: number) => void;
	moveDraggableItem : (id: string, hoverColIndex: number, hoverRowIndex: number, didDrop: boolean) => void;
	addSourceItem     : (id: string, hoverColIndex: number, hoverRowIndex: number) => void;
	addSourceRow      : (id: string, hoverIndex: number) => void;
	removeRow         : (index: number) => void;
	dropComplete      : (sourceIndex: number, dropIndex: number) => void;
}

interface IDraggableRowState
{
	isOver            : boolean;
	isDragging        : boolean;
}

const source =
{
	beginDrag(props: IDraggableRowProps)
	{
		//console.log((new Date()).toISOString() + ' ' + 'DraggableRow' + '.beginDrag', props);
		return {
			id   : props.id,
			index: props.index,
		};
	},
	endDrag(props: IDraggableRowProps, monitor: DragSourceMonitor)
	{
		//console.log((new Date()).toISOString() + ' ' + 'DraggableRow' + '.endDrag', props, monitor);
		if ( !monitor.didDrop() )
		{
			props.removeRow(monitor.getItem().index);
		}
		else
		{
			if ( props.dropComplete )
				props.dropComplete(props.index, monitor.getItem().index);
		}
	}
};

function collect(connect: DragSourceConnector, monitor: DragSourceMonitor)
{
	//console.log((new Date()).toISOString() + ' ' + 'DraggableRow' + '.collect', connect, monitor);
	return {
		connectDragSource: connect.dragSource(),
		isDragging       : monitor.isDragging(),
	};
}

const rowTarget =
{
	hover(props: IDraggableRowProps, monitor: DropTargetMonitor, component: DraggableRow)
	{
		//console.log((new Date()).toISOString() + ' ' + 'DraggableRow' + '.hover', props, monitor);
		if ( monitor.getItemType() == 'ROW' )
		{
			const dragIndex = monitor.getItem().index;
			const hoverIndex = props.index;

			// Don't replace rows with themselves
			if ( dragIndex === hoverIndex )
			{
				return;
			}
			if ( dragIndex != -1 )
			{
				props.moveDraggableRow(dragIndex, hoverIndex);
			}
			else
			{
				const id = monitor.getItem().id;
				props.addSourceRow(id, hoverIndex);
			}
			// Time to actually perform the action
			// Note: we're mutating the monitor row here!
			// Generally it's better to avoid mutations,
			// but it's good here for the sake of performance
			// to avoid expensive index searches.
			monitor.getItem().id = props.id;
			monitor.getItem().index = hoverIndex;
		}
		else
		{
			if ( props.length != 0 )
			{
				return;
			}
			const id            : string = monitor.getItem().id        ;
			const dragFieldIndex: number = monitor.getItem().fieldIndex;
			const dragColIndex  : number = monitor.getItem().colIndex  ;
			const dragRowIndex  : number = monitor.getItem().rowIndex  ;
			const hoverColIndex : number = 0;
			const hoverRowIndex : number = props.index;
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
				//console.log((new Date()).toISOString() + ' ' + 'DraggableRow' + '.hover', props, monitor);
				props.moveDraggableItem(id, hoverColIndex, hoverRowIndex, false);
			}
			else
			{
				//console.log((new Date()).toISOString() + ' ' + 'DraggableRow' + '.hover', props, monitor);
				const id = monitor.getItem().id;
				props.addSourceItem(id, hoverColIndex, hoverRowIndex);
			}
			// Time to actually perform the action
			// Note: we're mutating the monitor item here!
			// Generally it's better to avoid mutations,
			// but it's good here for the sake of performance
			// to avoid expensive index searches.
			//monitor.getItem().id = props.id;
			monitor.getItem().colIndex   = hoverColIndex  ;
			monitor.getItem().rowIndex   = hoverRowIndex  ;
		}
	}
};

function dropCollect(connect: DropTargetConnector)
{
	//console.log((new Date()).toISOString() + ' ' + 'DraggableRow' + '.dropCollect', connect);
	return {
		connectDropTarget: connect.dropTarget()
	};
}

class DraggableRow extends React.Component<IDraggableRowProps, IDraggableRowState>
{
	private themeURL      : string = null;

	constructor(props: IDraggableRowProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.state =
		{
			isOver    : false,
			isDragging: false,
		};
	}

	public render()
	{
		const { className, index, length, children } = this.props;
		const { isOver, isDragging } = this.state;
		const opacity = isDragging ? 0 : 1;
		return (
			this.props.connectDragSource &&
			this.props.connectDropTarget &&
			this.props.connectDragSource(
				this.props.connectDropTarget(
					<tr className={ 'hiddenHoverContainer ' + className }
						style={ { height: '28px', opacity } }>
						<td style={ {...style} }>
							<img src={ this.themeURL + 'blank.gif' } width={ 20 } height={ 1 } /><br />
							<FontAwesomeIcon className='hiddenHoverItem' icon='sort' size='2x' color='#5A94CE' style={ {paddingLeft: '4px'} } />
						</td>
						{ children }
						<td>
							<img src={ this.themeURL + 'blank.gif' } width={ 1 } height={ 28 } /><br />
						</td>
					</tr>
				)
			)
		);
	}
}

export default DropTarget(['ROW', 'ITEM'], rowTarget, dropCollect)(DragSource('ROW', source, collect)(DraggableRow));
