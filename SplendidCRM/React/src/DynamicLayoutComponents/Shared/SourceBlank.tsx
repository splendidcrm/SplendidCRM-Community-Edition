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
import { DragSource, DropTarget, ConnectDropTarget, ConnectDragSource, DropTargetMonitor, DropTargetConnector, DragSourceConnector, DragSourceMonitor } from 'react-dnd';
import { uuidFast }                           from '../../scripts/utility'            ;

const style: React.CSSProperties =
{
	border         : '1px dashed grey',
	backgroundColor: '#eeeeee',
	padding        : '2px',
	margin         : '2px',
	borderRadius   : '2px',
	width          : '200px',
};

interface ISourceBlankProps
{
	TITLE               : string;
	createItemFromSource: (item: any) => any;
	connectDragSource?  : Function;  // ConnectDragSource;
	moveDraggableItem   : (id: string, hoverColIndex: number, hoverRowIndex: number, didDrop: boolean) => void;
	remove              : (item, type) => void;
}

const source =
{
	beginDrag(props: ISourceBlankProps)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SourceBlank' + '.beginDrag', props);
		let obj: any     = {};
		obj.id           = uuidFast() ;
		obj.index        = -1         ;
		obj.ID           = null       ;
		obj.FIELD_TYPE   = 'Blank'    ;
		obj.DATA_LABEL   = null       ;
		obj.DATA_FIELD   = null       ;
		obj.DATA_FORMAT  = null       ;
		obj.URL_FIELD    = null       ;
		obj.URL_FORMAT   = null       ;
		obj.URL_TARGET   = null       ;
		obj.MODULE_TYPE  = null       ;
		obj.LIST_NAME    = null       ;
		obj.COLSPAN      = null       ;
		obj.TOOL_TIP     = null       ;
		obj.PARENT_FIELD = null       ;
		return props.createItemFromSource(obj);
	},
	endDrag(props: ISourceBlankProps, monitor: DragSourceMonitor)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SourceBlank' + '.endDrag', props, monitor.getItem());
		if ( monitor.didDrop() )
		{
			const id           : string = monitor.getItem().id        ;
			const hoverColIndex: number = monitor.getItem().colIndex  ;
			const hoverRowIndex: number = monitor.getItem().rowIndex  ;
			props.moveDraggableItem(id, hoverColIndex, hoverRowIndex, true);
		}
		else
		{
			// 03/14/2020 Paul.  We need to remove the ghost item created above. 
			props.remove(monitor.getItem(), 'ITEM');
		}
	}
};

function collect(connect: DragSourceConnector, monitor: DragSourceMonitor)
{
	//console.log((new Date()).toISOString() + ' ' + 'SourceBlank' + '.collect', connect, monitor);
	return {
		connectDragSource: connect.dragSource()
	};
}

class SourceBlank extends React.Component<ISourceBlankProps>
{
	constructor(props: ISourceBlankProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
	}

	public render()
	{
		const{ TITLE } = this.props;
		return (
			this.props.connectDragSource &&
			this.props.connectDragSource(
				<div style={ { ...style } } className='grab'>
					{ TITLE }
				</div>
			)
		);
	}
}

export default DragSource('ITEM', source, collect)(SourceBlank);
