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
import { RouteComponentProps, withRouter }        from 'react-router-dom'                         ;
import { observer }                               from 'mobx-react'                               ;
import { FontAwesomeIcon }                        from '@fortawesome/react-fontawesome'           ;
// 2. Store and Types. 
import { EditComponent }                          from '../../../types/EditComponent'             ;
// 3. Scripts. 
import Sql                                        from '../../../scripts/Sql'                     ;
import L10n                                       from '../../../scripts/L10n'                    ;
import Credentials                                from '../../../scripts/Credentials'             ;
import SplendidCache                              from '../../../scripts/SplendidCache'           ;
import SplendidDynamic_EditView                   from '../../../scripts/SplendidDynamic_EditView';
import { AuthenticatedMethod, LoginRedirect }     from '../../../scripts/Login'                   ;
import { EditView_LoadLayout, EditView_HideField } from '../../../scripts/EditView'                ;
// 4. Components and Views. 
import ErrorComponent                             from '../../../components/ErrorComponent'       ;
import DumpSQL                                    from '../../../components/DumpSQL'              ;
import DynamicButtons                             from '../../../components/DynamicButtons'       ;

interface IAdminEditViewProps extends RouteComponentProps<any>
{
	MODULE_NAME       : string;
	ID?               : string;
	LAYOUT_NAME?      : string;
	callback?         : any;
	rowDefaultSearch? : any;
	onLayoutLoaded?   : any;
	onSubmit?         : any;
}

interface IAdminEditViewState
{
	__total           : number;
	__sql             : string;
	item              : any;
	layout            : any;
	EDIT_NAME         : string;
	DUPLICATE         : boolean;
	LAST_DATE_MODIFIED: Date;
	SUB_TITLE         : any;
	editedItem        : any;
	dependents        : Record<string, Array<any>>;
	error?            : any;
	vwPICK_LIST_VALUES: string[];
}

@observer
export default class NewRecord extends React.Component<IAdminEditViewProps, IAdminEditViewState>
{
	private _isMounted   : boolean = false;
	private refMap       : Record<string, React.RefObject<EditComponent<any, any>>>;
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();

	public get data (): any
	{
		let row: any = {};
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
		if ( nInvalidFields == 0 )
		{
		}
		return row;
	}

	public validate(): boolean
	{
		let error: string = '';
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = SplendidDynamic_EditView.Validate(this.refMap);
		let row: any = {};
		SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
		if ( !Sql.IsEmptyString(row['NAME']) )
		{
			// https://www.regextester.com/103824
			let regex = /^[A-Za-z_]\w*$/;  // new Regex('') does not work here. 
			if ( !regex.test(row['NAME']) )
			{
				error = 'invalid field name';
				nInvalidFields++;
			}
		}
		this.setState({ error });
		return (nInvalidFields == 0);
	}

	public clear(): void
	{
		// 08/27/2019 Paul.  Move build code to shared object. 
		SplendidDynamic_EditView.Clear(this.refMap);
		if ( this._isMounted )
		{
			this.setState({ editedItem: {} });
		}
	}

	public setError(error: string): void
	{
		this.setState({ error });
	}

	constructor(props: IAdminEditViewProps)
	{
		super(props);
		let EDIT_NAME = props.MODULE_NAME + '.NewRecord';
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			EDIT_NAME = props.LAYOUT_NAME;
		}
		let vwPICK_LIST_VALUES: string[] = [];
		this.state =
		{
			__total           : 0,
			__sql             : null,
			item              : (props.rowDefaultSearch ? props.rowDefaultSearch : null),
			layout            : null,
			EDIT_NAME         ,
			DUPLICATE         : false,
			LAST_DATE_MODIFIED: null,
			SUB_TITLE         : null,
			editedItem        : null,
			dependents        : {},
			error             : null,
			vwPICK_LIST_VALUES,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		const { MODULE_NAME, rowDefaultSearch } = this.props;
		const { EDIT_NAME } = this.state;
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				const layout = EditView_LoadLayout(EDIT_NAME);
				EditView_HideField(layout, 'DROPDOWN_LIST', true);
				if ( this._isMounted )
				{
					this.setState(
					{
						layout: layout,
						item: (rowDefaultSearch ? rowDefaultSearch : null),
						editedItem: null
					}, () =>
					{
						if ( this.props.onLayoutLoaded )
						{
							this.props.onLayoutLoaded();
						}
					});
				}
			}
			else
			{
				LoginRedirect(this.props.history, this.constructor.name + '.componentDidMount');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	async componentDidUpdate(prevProps: IAdminEditViewProps)
	{
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			// 04/26/2019 Paul.  Bounce through ResetView so that layout gets completely reloaded. 
			// 11/20/2019 Paul.  Include search parameters. 
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}
	
	private _onChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE);
		let item = this.state.editedItem;
		if ( item == null )
			item = {};
		item[DATA_FIELD] = DATA_VALUE;
		if ( this._isMounted )
		{
			this.setState({ editedItem: item });
		}
	}

	private _createDependency = (DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string): void =>
	{
		let { dependents } = this.state;
		if ( dependents[PARENT_FIELD] )
		{
			dependents[PARENT_FIELD].push( {DATA_FIELD, PROPERTY_NAME} );
		}
		else
		{
			dependents[PARENT_FIELD] = [ {DATA_FIELD, PROPERTY_NAME} ]
		}
		if ( this._isMounted )
		{
			this.setState({ dependents: dependents });
		}
	}

	private _onUpdate = (PARENT_FIELD: string, DATA_VALUE: any, item?: any): void =>
	{
		let { layout } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate ' + PARENT_FIELD, DATA_VALUE);
		let { dependents } = this.state;
		if ( dependents[PARENT_FIELD] )
		{
			let dependentIds = dependents[PARENT_FIELD];
			for ( let i = 0; i < dependentIds.length; i++ )
			{
				let ref = this.refMap[dependentIds[i].DATA_FIELD];
				if ( ref )
				{
					ref.current.updateDependancy(PARENT_FIELD, DATA_VALUE, dependentIds[i].PROPERTY_NAME, item);
				}
			}
		}
		if ( PARENT_FIELD == 'DATA_TYPE' )
		{
			let item = this.state.editedItem;
			let hidden: boolean = (DATA_VALUE != 'enum');
			EditView_HideField(layout, 'DROPDOWN_LIST', hidden);
			let vwPICK_LIST_VALUES: string[] = [];
			if ( !hidden )
			{
				// 02/02/2021 Paul.  Must populate the list for the first item. 
				let arrPickLists: string[] = L10n.GetList('TerminologyPickLists');
				if ( arrPickLists != null && arrPickLists.length > 0 )
				{
					vwPICK_LIST_VALUES = L10n.GetList(arrPickLists[0]);
					item['DROPDOWN_LIST'] = arrPickLists[0];
				}
			}
			else
			{
				item['DROPDOWN_LIST'] = '';
			}
			this.setState({ layout, editedItem: item, vwPICK_LIST_VALUES });
		}
		else if ( PARENT_FIELD == 'DROPDOWN_LIST' )
		{
			let vwPICK_LIST_VALUES: string[] = L10n.GetList(DATA_VALUE);
			this.setState({ vwPICK_LIST_VALUES });
		}
	}

	// 06/15/2018 Paul.  The SearchView will register for the onSubmit event. 
	private _onSubmit = (): void =>
	{
		try
		{
			this.setState({ error: '' });
			if ( this.props.onSubmit )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit');
				this.props.onSubmit();
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit', error);
			this.setState({ error });
		}
	}

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { ID, MODULE_NAME, history, location } = this.props;
		const { LAST_DATE_MODIFIED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		if ( sCommandName == 'Save' )
		{
			if ( this.dynamicButtonsBottom.current != null )
			{
				this.dynamicButtonsBottom.current.Busy();
			}
			this.props.onSubmit();
			if ( this.dynamicButtonsBottom.current != null )
			{
				this.dynamicButtonsBottom.current.NotBusy();
			}
		}
	}

	private _onButtonLayoutLoaded = () =>
	{
		if ( this.dynamicButtonsBottom.current != null )
		{
			this.dynamicButtonsBottom.current.ShowButton('Cancel', false);
		}
	}

	public render()
	{
		const { MODULE_NAME, ID, callback } = this.props;
		const { item, editedItem, layout, EDIT_NAME, SUB_TITLE, error, vwPICK_LIST_VALUES } = this.state;
		const { __total, __sql } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render: ' + EDIT_NAME, layout, item);
		// 09/09/2019 Paul.  We need to wait until item is loaded, otherwise fields will not get populated. 
		if ( layout == null || (item == null && (!Sql.IsEmptyString(ID) )) )
		{
			if ( error )
			{
				return (<ErrorComponent error={error} />);
			}
			else
			{
				return null;
			}
		}
		this.refMap = {};
		let onSubmit = (this.props.onSubmit ? this._onSubmit : null);
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			return (
			<div>
				<ErrorComponent error={ error } />
				<div id={!!callback ? null : "content"}>
					{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, callback, this._createDependency, null, this._onChange, this._onUpdate, onSubmit, 'tabForm', this.Page_Command) }
					<br />
				</div>
				{ editedItem != null && editedItem['DATA_TYPE'] == 'enum'
				? <table cellSpacing={ 0 } cellPadding={ 3 } style={ {backgroundColor: 'white', width: '100%', borderCollapse: 'collapse', border: 'solid 2px black'} }>
					{
						vwPICK_LIST_VALUES.map((item, index) => 
						{
							return (<tr>
								<td style={ { border: 'solid 1px black' } }>{ item }</td>
								<td style={ { border: 'solid 1px black' } }>{ L10n.ListTerm(editedItem['DROPDOWN_LIST'], item) }</td>
							</tr>);
						})
					}
				</table>
				: null
				}
				<DynamicButtons
					ButtonStyle="EditHeader"
					VIEW_NAME={ MODULE_NAME + '.EditView' }
					row={ item }
					onLayoutLoaded={ this._onButtonLayoutLoaded }
					Page_Command={ this.Page_Command }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.dynamicButtonsBottom }
				/>
			</div>
			);
		}
		else if ( error )
		{
			return (<ErrorComponent error={error} />);
		}
		else
		{
			return (
			<div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
				<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
			</div>);
		}
	}
}

// 04/27/2020 Paul.  We don't want to use withRouter() as it makes it difficult to get a reference. 

