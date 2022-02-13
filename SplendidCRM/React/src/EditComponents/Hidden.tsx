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
// 2. Store and Types. 
import { IEditComponentProps, EditComponent } from '../types/EditComponent';
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'        ;
import Security                               from '../scripts/Security'   ;
import { Crm_Config }                         from '../scripts/Crm'        ;
// 4. Components and Views. 

interface IHiddenState
{
	ID               : string;
	FIELD_INDEX      : number;
	DATA_FIELD       : string;
	DATA_VALUE       : string;
}

export default class Hidden extends EditComponent<IEditComponentProps, IHiddenState>
{
	public get data(): any
	{
		const { DATA_FIELD, DATA_VALUE } = this.state;
		return { key: DATA_FIELD, value: DATA_VALUE };
	}

	public validate(): boolean
	{
		return true;
	}

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.setState({ DATA_VALUE });
		}
	}

	public clear(): void
	{
	}

	constructor(props: IEditComponentProps)
	{
		super(props);
		let FIELD_INDEX      : number = 0;
		let DATA_FIELD       : string = '';
		let DATA_VALUE       : string = '';

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged } = this.props;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD );
				ID = baseId + '_' + DATA_FIELD;

				if ( row != null )
				{
					if ( !Sql.IsEmptyString(DATA_FIELD) && row[DATA_FIELD] != null )
					{
						DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
					}
					// 04/14/2016 Paul.  New spPARENT_GetWithTeam procedure so that we can inherit Assigned To and Team values. 
					// 04/14/2016 Paul.  We need a way to detect that we are loading EditView from a relationship create. 
					if ( Sql.ToBoolean(row['DetailViewRelationshipCreate']) )
					{
						if ( DATA_FIELD == 'TEAM_ID' )
						{
							if ( Crm_Config.ToBoolean('inherit_team') && !Sql.IsEmptyString(row[DATA_FIELD]) )
							{
								DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
							}
							else
							{
								DATA_VALUE = Security.TEAM_ID();
							}
						}
						else if ( DATA_FIELD == 'ASSIGNED_USER_ID' )
						{
							if ( Crm_Config.ToBoolean('inherit_assigned_user') && !Sql.IsEmptyString(row[DATA_FIELD]) )
							{
								DATA_VALUE = Sql.ToString(row[DATA_FIELD]);
							}
							else
							{
								DATA_VALUE = Security.USER_ID();
							}
						}
					}
				}
				else if ( DATA_FIELD == 'TEAM_ID' )
				{
					DATA_VALUE = Security.TEAM_ID();
				}
				else if ( DATA_FIELD == 'ASSIGNED_USER_ID' )
				{
					DATA_VALUE = Security.USER_ID();
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, DATA_VALUE, row);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		this.state =
		{
			ID         ,
			FIELD_INDEX,
			DATA_FIELD ,
			DATA_VALUE ,
		};
		//document.components[sID] = this;
	}

	async componentDidMount()
	{
		const { DATA_FIELD } = this.state;
		if ( this.props.fieldDidMount )
		{
			this.props.fieldDidMount(DATA_FIELD, this);
		}
	}

	shouldComponentUpdate(nextProps: IEditComponentProps, nextState: IHiddenState)
	{
		const { DATA_FIELD, DATA_VALUE } = this.state;
		if ( nextProps.row != this.props.row )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextProps.layout != this.props.layout )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.DATA_VALUE != this.state.DATA_VALUE )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		return false;
	}

	private _onChange = (e: React.ChangeEvent<HTMLInputElement>) =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD } = this.state;
		let DATA_VALUE = e.target.value;
		this.setState({ DATA_VALUE });
		onChanged(DATA_FIELD, DATA_VALUE);
		onUpdate (DATA_FIELD, DATA_VALUE);
	}

	public render()
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { ID, FIELD_INDEX, DATA_FIELD, DATA_VALUE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD, DATA_VALUE, row);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<div>DATA_FIELD is empty for Hidden FIELD_INDEX { FIELD_INDEX }</div>);
			}
			else if ( onChanged == null )
			{
				return (<div>onChanged is null for Hidden DATA_FIELD { DATA_FIELD }</div>);
			}
			// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
			else if ( layout.hidden )
			{
				return (<span></span>);
			}
			else
			{
				let styHidden = { display: 'none' };
				return (
					<span style={ styHidden }>
						<input
							id={ ID }
							key={ ID }
							value={ DATA_VALUE }
							type="hidden"
							onChange={ this._onChange }
						/>
					</span>
				);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.render', error);
			return (<span>{ error.message }</span>);
		}
	}
}

