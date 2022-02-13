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

interface ISourceTemplateColumnProps
{
	TITLE: string;
	removeRow: (index: number) => void;
	isDragging?: boolean;
	connectDragSource?: ConnectDragSource;
}

const source =
{
	beginDrag(props: ISourceTemplateColumnProps)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SourceTemplateColumn' + '.beginDrag', props);
		return {
			id         : uuidFast(),
			index      : -1,
			COLUMN_TYPE: 'NewTemplateColumn'
		};
	},
	endDrag(props: ISourceTemplateColumnProps, monitor: DragSourceMonitor)
	{
		//console.log((new Date()).toISOString() + ' ' + 'SourceTemplateColumn' + '.endDrag', props, monitor);
		if ( !monitor.didDrop() )
		{
			props.removeRow(monitor.getItem().index);
		}
	}
}

function collect(connect: DragSourceConnector, monitor: DragSourceMonitor)
{
	//console.log((new Date()).toISOString() + ' ' + 'SourceTemplateColumn' + '.collect', connect, monitor);
	return {
		connectDragSource: connect.dragSource()
	};
}

class SourceTemplateColumn extends React.Component<ISourceTemplateColumnProps>
{
	constructor(props: ISourceTemplateColumnProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor');
	}

	public render()
	{
		const { TITLE, connectDragSource } = this.props;
		return (
			connectDragSource &&
			connectDragSource(
				<div
					style={ { ...style } }>
					{ TITLE }
				</div>
			)
		);
	}
}

export default DragSource('ROW', source, collect)(SourceTemplateColumn);
