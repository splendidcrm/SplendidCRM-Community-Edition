/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

import React from 'react';
import { FontAwesomeIcon }                       from '@fortawesome/react-fontawesome';
import { DropTarget, DropTargetConnector, DropTargetMonitor, ConnectDropTarget } from 'react-dnd';

interface IDraggableRemoveProps
{
	isOver?           : boolean
	connectDropTarget?: Function;  // ConnectDropTarget;
	remove            : (item, type) => void;
}

interface IDraggableRemoveState
{
	isOver            : boolean;
}

const boxTarget =
{
	drop(props: IDraggableRemoveProps, monitor: DropTargetMonitor)
	{
		//console.log((new Date()).toISOString() + ' ' + 'DraggableRemove' + '.drop', props);
		props.remove(monitor.getItem(), monitor.getItemType());
	}
};

function collect(connect: DropTargetConnector, monitor: DropTargetMonitor)
{
	//console.log((new Date()).toISOString() + ' ' + 'DraggableRemove' + '.collect', connect, monitor);
	return {
		connectDropTarget: connect.dropTarget(),
		isOver           : monitor.isOver(),
	};
}

class DraggableRemove extends React.Component<IDraggableRemoveProps, IDraggableRemoveState>
{
	constructor(props: IDraggableRemoveProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		this.state =
		{
			isOver: false
		};
	}

	public render()
	{
		const { isOver } = this.state;
		return (
			this.props.connectDropTarget &&
			this.props.connectDropTarget(
				<div
					style={{ padding: '1em 0', display: 'inline-block' }}>
					<FontAwesomeIcon icon='trash-alt' size='4x' />
				</div>
			)
		);
	}
}

export default DropTarget(['ITEM', 'ROW'], boxTarget, collect)(DraggableRemove);
