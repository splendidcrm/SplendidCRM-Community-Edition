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
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                 from '../../scripts/Sql' ;
import L10n                                from '../../scripts/L10n';

const style: React.CSSProperties =
{
	border         : '1px solid grey',
	backgroundColor: '#eeeeee',
	padding        : '2px',
	margin         : '2px',
	borderRadius   : '2px',
	width          : '100%',
};

interface IDraggableItemProps
{
	id                : string;
	item              : any;
	onEditClick       : (id: string) => void;
	onChangeEnabled   : Function;
}

export default class DraggableItem extends React.Component<IDraggableItemProps>
{
	constructor(props: IDraggableItemProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
	}

	private _onRELATIONSHIP_ENABLED_Change = (id: string, checked: boolean) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRELATIONSHIP_ENABLED_Change ' + id, checked);
		this.props.onChangeEnabled(id, checked);
	}

	public render()
	{
		const { item, id, onEditClick } = this.props;
		return ( item &&
			<table cellPadding={ 4 } cellSpacing={ 0 } style={ style }>
				<tr>
					<td style={ {width: '60%'} }>
						{ item.MODULE_NAME != item.CONTROL_NAME ? item.MODULE_NAME : item.MODULE_NAME + ' (' + item.CONTROL_NAME + ')' }
					</td>
					<td style={ {width: '39%'} }>
						<input 
							id={  'chk' + item.MODULE_NAME + '_' + item.CONTROL_NAME + '_RELATIONSHIP_ENABLED' }
							key={ 'chk' + item.MODULE_NAME + '_' + item.CONTROL_NAME + '_RELATIONSHIP_ENABLED' }
							type='checkbox'
							checked={ item.RELATIONSHIP_ENABLED }
							onChange={ (e) => this._onRELATIONSHIP_ENABLED_Change(item.ID, e.target.checked) }
						/>
						<label style={ {marginLeft: '2px', marginRight: '2px'} }>
						{ item.RELATIONSHIP_ENABLED
						? L10n.Term('DynamicLayout.LBL_ENABLED')
						: L10n.Term('DynamicLayout.LBL_DISABLED')
						}
						</label>
					</td>
					<td rowSpan={ 2 }>
						<span style={ {cursor: 'pointer'} } onClick={ () => onEditClick(id) }>
						<FontAwesomeIcon icon="edit" size="lg" />
					</span>
					</td>
				</tr>
				<tr>
					<td style={ {width: '60%'} }>
						{ L10n.Term(item.TITLE) }
					</td>
					<td style={ {width: '39%'} }>
						{ Sql.ToString(item.SORT_FIELD) + ' ' + Sql.ToString(item.SORT_DIRECTION) }
					</td>
				</tr>
			</table>
		);
	}
}
