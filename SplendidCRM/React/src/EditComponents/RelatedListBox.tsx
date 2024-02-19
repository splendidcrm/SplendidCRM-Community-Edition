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
import { isObservableArray }                  from 'mobx'                  ;
import { XMLParser, XMLBuilder }              from 'fast-xml-parser'       ;
// 2. Store and Types. 
import { IEditComponentProps, EditComponent } from '../types/EditComponent';
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'        ;
import L10n                                   from '../scripts/L10n'       ;
import { StartsWith }                         from '../scripts/utility'    ;
// 4. Components and Views. 

interface IRelatedListBoxState
{
	ID               : string;
	FIELD_INDEX      : number;
	DATA_FIELD       : string;
	DATA_VALUE       : any;
	BIT_VALUES       : boolean[];
	DATA_FORMAT      : string;
	LIST_NAME        : string;
	LIST_VALUES      : any[];
	PARENT_FIELD     : string;
	UI_REQUIRED      : boolean;
	FORMAT_TAB_INDEX : number;
	FORMAT_ROWS      : number;
	ONCLICK_SCRIPT   : string;
	VALUE_MISSING    : boolean;
	ENABLED          : boolean;
	CSS_CLASS?       : string;
}

export default class RelatedListBox extends EditComponent<IEditComponentProps, IRelatedListBoxState>
{
	public get data(): any
	{
		const { DATA_FIELD, DATA_VALUE, DATA_FORMAT } = this.state;
		let value: any = DATA_VALUE;
		// 08/17/2019 Paul.  Return as CSV if required. 
		if ( Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('csv') >= 0 )
		{
			if ( value != null && Array.isArray(value) )
			{
				value = value.join(',');
			}
		}
		return { key: DATA_FIELD, value };
	}

	public validate(): boolean
	{
		const { DATA_FIELD, DATA_VALUE, UI_REQUIRED, FORMAT_ROWS, VALUE_MISSING, ENABLED } = this.state;
		let bVALUE_MISSING: boolean = false;
		// 08/06/2020 Paul.  Hidden fields cannot be required. 
		if ( UI_REQUIRED && !this.props.bIsHidden )
		{
			if ( Math.abs(FORMAT_ROWS) > 0 )
			{
				bVALUE_MISSING = DATA_VALUE != null && DATA_VALUE.length > 0;
			}
			else
			{
				bVALUE_MISSING = Sql.IsEmptyString(DATA_VALUE);
			}
			if ( bVALUE_MISSING != VALUE_MISSING )
			{
				this.setState({VALUE_MISSING: bVALUE_MISSING});
			}
			if ( bVALUE_MISSING && UI_REQUIRED )
			{
				console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.validate ' + DATA_FIELD);
			}
		}
		return !bVALUE_MISSING;
	}

	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.setState({ DATA_VALUE });
		}
		else if ( PROPERTY_NAME == 'enabled' )
		{
			this.setState(
			{
				ENABLED: Sql.ToBoolean(DATA_VALUE)
			});
		}
		else if ( PROPERTY_NAME == 'class' )
		{
			this.setState({ CSS_CLASS: DATA_VALUE });
		}
	}

	public clear(): void
	{
		const { ENABLED } = this.state;
		// 01/11/2020.  Apply Field Level Security. 
		if ( ENABLED )
		{
			this.setState(
			{
				DATA_VALUE: null, 
				BIT_VALUES: []
			});
		}
	}

	constructor(props: IEditComponentProps)
	{
		super(props);
		let FIELD_INDEX      : number    = 0;
		let DATA_FIELD       : string    = '';
		let DATA_VALUE       : any       = null;
		let BIT_VALUES       : boolean[] = [];
		let DATA_FORMAT      : string    = '';
		let LIST_NAME        : string    = '';
		let PARENT_FIELD     : string    = '';
		let UI_REQUIRED      : boolean   = false;
		let FORMAT_TAB_INDEX : number    = 0;
		let FORMAT_ROWS      : number    = 0;
		let ONCLICK_SCRIPT   : string    = '';
		let lstOptions       : any[]     = [];
		let lstSelected      : any       = null;
		let ENABLED          : boolean   = props.bIsWriteable;

		let ID: string = null;
		try
		{
			const { baseId, layout, row, onChanged, onUpdate } = this.props;
			if (layout != null)
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX     );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD      );
				DATA_FORMAT       = Sql.ToString (layout.DATA_FORMAT     );
				LIST_NAME         = Sql.ToString (layout.LIST_NAME       );
				PARENT_FIELD      = Sql.ToString (layout.PARENT_FIELD    );
				UI_REQUIRED       = Sql.ToBoolean(layout.UI_REQUIRED     ) || Sql.ToBoolean(layout.DATA_REQUIRED);
				FORMAT_TAB_INDEX  = Sql.ToInteger(layout.FORMAT_TAB_INDEX);
				FORMAT_ROWS       = Sql.ToInteger(layout.FORMAT_ROWS     );
				ONCLICK_SCRIPT    = Sql.ToString (layout.ONCLICK_SCRIPT  );
				ID = baseId + '_' + DATA_FIELD;
				// 01/17/2018 Paul.  Add DATA_FORMAT to RelatedListBox support force user selection. 
				if ( UI_REQUIRED || Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('force') >= 0 )
				{
					UI_REQUIRED = true;
				}

				if ( !Sql.IsEmptyString(LIST_NAME) )
				{
					// 04/08/2017 Paul.  Use Bootstrap for responsive design.
					// 09/27/2012 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
					if ( !Sql.IsEmptyString(PARENT_FIELD) )
					{
						//lstProps.parentUpdates = parentUpdates[PARENT_FIELD];
						// 05/31/2018 Chase. Super Deferred.
						/*var lstPARENT_FIELD = document.getElementById('ctlEditView_' + PARENT_FIELD);
						if ( lstPARENT_FIELD != null )
						{
						
							// 05/16/2018 Paul.  Defer event. 
							LIST_NAME = lstPARENT_FIELD.options[lstPARENT_FIELD.options.selectedIndex].value;
							lstPARENT_FIELD.onchange = BindArguments(function(lst, lstPARENT_FIELD, UI_REQUIRED)
							{
								lst.options.length = 0;
								LIST_NAME = lstPARENT_FIELD.options[lstPARENT_FIELD.options.selectedIndex].value;
								let arrLIST = L10n.GetList(LIST_NAME);
								if ( arrLIST != null )
								{
									// 04/23/2017 Paul.  We don't need a NONE record when using multi-selection. 
									if ( !UI_REQUIRED && FORMAT_ROWS <= 0 )
									{
										var opt = React.createElement('option', {value: '', selected: null}, L10n.Term('.LBL_NONE'));
										lstChildren.push(opt);
										// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
										if ( DATA_VALUE != null && DATA_VALUE === '' )
											opt.props.selected ='selected';
									}
									for ( var i = 0; i < arrLIST.length; i++ )
									{
										var opt2 = React.createElement('option', {value: arrLIST[i], selected: null}, L10n.ListTerm(LIST_NAME, arrLIST[i]));
										lstChildren.push(opt2);
										// 10/27/2012 Paul.  It is normal for a list term to return an empty string. 
										if ( DATA_VALUE != null && DATA_VALUE == arrLIST[i] )
											opt2.props.selected ='selected';
									}
								}
							}, lst, lstPARENT_FIELD, UI_REQUIRED);
						}*/
					}
					if ( row )
					{
						// 06/14/2018 Paul.  Sql.ToString will not convert an array to a string, so it is safe to use Array.isArray() below. 
						DATA_VALUE = row[DATA_FIELD];
						// 03/27/2019 Paul.  Lets not use Sql.ToString in case the behavior changes in the future. 
						if ( DATA_VALUE === undefined || DATA_VALUE == null )
						{
							DATA_VALUE = '';
						}
						// 06/14/2018 Paul.  Special case where dashboard search needs to allow none. 
						// 01/13/2018 Paul.  Terminology is now an ObservableArray. 
						if ( Array.isArray(DATA_VALUE) || isObservableArray(DATA_VALUE) )
						{
							if ( DATA_VALUE.length >= 1 )
							{
								// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
								if ( DATA_VALUE[0] === '' )
								{
									DATA_FORMAT = 'force';
									FORMAT_ROWS = -1 * Math.abs(FORMAT_ROWS);
								}
							}
						}
					}
					let arrLIST = L10n.GetList(LIST_NAME);
					if ( arrLIST != null )
					{
						for ( let i = 0; i < arrLIST.length; i++ )
						{
							BIT_VALUES.push(false);
						}
						// 04/23/2017 Paul.  We don't need a NONE record when using multi-selection. 
						// 01/17/2018 Paul.  Add DATA_FORMAT to RelatedListBox support force user selection. 
						if ( (!UI_REQUIRED || Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('force') >= 0) && FORMAT_ROWS <= 0 )
						{
							// 01/08/2018 Paul.  Some lists have the first entry as a blank. 
							if ( !(arrLIST.length > 0 && Sql.IsEmptyString(arrLIST[0])) )
							{
								let opt3 = { key: '', text: L10n.Term('.LBL_NONE') };
								lstOptions.push(opt3);
								BIT_VALUES.push(false);
								// 01/13/2018 Paul.  Terminology is now an ObservableArray. 
								if ( Array.isArray(DATA_VALUE) || isObservableArray(DATA_VALUE) )
								{
									if ( DATA_VALUE.length >= 1 )
									{
										// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
										if ( DATA_VALUE[0] === '' )
										{
											BIT_VALUES[0] = true;
											lstSelected.push('');
										}
									}
								}
								// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
								else if ( DATA_VALUE != null && DATA_VALUE === '' )
								{
									BIT_VALUES[0] = true;
									if ( Math.abs(FORMAT_ROWS) > 0 )
									{
										lstSelected.push('');
									}
									else
									{
										lstSelected = '';
									}
								}
							}
						}
						for ( let i = 0; i < arrLIST.length; i++ )
						{
							let opt4 = { key: arrLIST[i], text: L10n.ListTerm(LIST_NAME, arrLIST[i]) };
							lstOptions.push(opt4);
						}
						// 01/06/2018 Paul.  Add DATA_FORMAT to RelatedListBox support multi-select CSV. 
						if ( Math.abs(FORMAT_ROWS) > 0 )
						{
							lstSelected = [];
							// 01/13/2018 Paul.  Terminology is now an ObservableArray. 
							if ( Array.isArray(DATA_VALUE) || isObservableArray(DATA_VALUE) )
							{
								let DATA_VALUES = DATA_VALUE;
								for ( let i = 0; i < arrLIST.length; i++ )
								{
									for ( let j = 0; j < DATA_VALUES.length; j++ )
									{
										if ( DATA_VALUES[j] != null && DATA_VALUES[j] == arrLIST[i] )
										{
											BIT_VALUES[j] = true;
											lstSelected.push(arrLIST[i])
											break;
										}
									}
								}
								// 03/27/2019 Paul.  If record has value and array does not contain a match, then add the value to the list. 
								for ( let j = 0; j < DATA_VALUES.length; j++ )
								{
									if ( DATA_VALUES[j] != null && lstSelected.indexOf(DATA_VALUES[j]) < 0 )
									{
										let optMissing = { key: DATA_VALUES[j], text: DATA_VALUES[j] };
										lstOptions.push(optMissing);
										BIT_VALUES.push(true);
										lstSelected.push(DATA_VALUES[j]);
									}
								}
							}
							else if ( Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('csv') >= 0 )
							{
								let DATA_VALUES: any[] = [];
								if ( DATA_VALUE != null )
								{
									DATA_VALUES = DATA_VALUE.split(',');
								}
								for ( let i = 0; i < arrLIST.length; i++ )
								{
									for ( let j = 0; j < DATA_VALUES.length; j++ )
									{
										if ( DATA_VALUES[j] != null && DATA_VALUES[j] == arrLIST[i] )
										{
											BIT_VALUES[j] = true;
											lstSelected.push(arrLIST[i])
											break;
										}
									}
								}
								// 03/27/2019 Paul.  If record has value and array does not contain a match, then add the value to the list. 
								for ( let j = 0; j < DATA_VALUES.length; j++ )
								{
									if ( DATA_VALUES[j] != null && lstSelected.indexOf(DATA_VALUES[j]) < 0 )
									{
										let optMissing = { key: DATA_VALUES[j], text: DATA_VALUES[j] };
										lstOptions.push(optMissing);
										BIT_VALUES.push(true);
										lstSelected.push(DATA_VALUES[j]);
									}
								}
								//var sALL_SELECTED = L10n.Term(".LBL_ALL_SELECTED");
								//var sCOUNT_SELECTED = L10n.Term(".LBL_COUNT_SELECTED");
								// 05/16/2018 Paul.  Defer multi select. 
								//$(lst).multipleSelect({selectAll: false, width: '100%', minimumCountSelected: 10, allSelected: sALL_SELECTED, countSelected: sCOUNT_SELECTED });
							}
							// 08/01/2013 Paul.  Expand XML values from CheckBoxList. 
							else if ( StartsWith(DATA_VALUE, '<?xml') )
							{
								// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
								const parser = new XMLParser();
								let xml = parser.parse(DATA_VALUE);
								if ( xml.Values && xml.Values.Value && Array.isArray(xml.Values.Value) )
								{
									let DATA_VALUES: string[] = xml.Values.Value;
									for ( let i = 0; i < arrLIST.length; i++ )
									{
										for ( let j = 0; j < DATA_VALUES.length; j++ )
										{
											if ( DATA_VALUES[j] != null && DATA_VALUES[j] == arrLIST[i] )
											{
												BIT_VALUES[j] = true;
												lstSelected.push(arrLIST[i])
												break;
											}
										}
									}
									// 03/27/2019 Paul.  If record has value and array does not contain a match, then add the value to the list. 
									for ( let j = 0; j < DATA_VALUES.length; j++ )
									{
										if ( DATA_VALUES[j] != null && lstSelected.indexOf(DATA_VALUES[j]) < 0 )
										{
											let optMissing = { key: DATA_VALUES[j], text: DATA_VALUES[j] };
											lstOptions.push(optMissing);
											BIT_VALUES.push(true);
											lstSelected.push(DATA_VALUES[j]);
										}
									}
								}
							}
							else
							{
								for ( let i = 0; i < arrLIST.length; i++ )
								{
									// 10/27/2012 Paul.  It is normal for a list term to return an empty string. 
									if ( DATA_VALUE != null && DATA_VALUE == arrLIST[i] )
									{
										BIT_VALUES[i] = true;
										lstSelected.push(arrLIST[i]);
									}
								}
								// 03/27/2019 Paul.  If record has value and array does not contain a match, then add the value to the list. 
								if ( DATA_VALUE != null && lstSelected.indexOf(DATA_VALUE) < 0 )
								{
									let optMissing = { key: DATA_VALUE, text: DATA_VALUE };
									lstOptions.push(optMissing);
									BIT_VALUES.push(true);
									lstSelected.push(DATA_VALUE);
								}
							}
						}
						else
						{
							lstSelected = null;
							for ( let i = 0; i < arrLIST.length; i++ )
							{
								// 10/27/2012 Paul.  It is normal for a list term to return an empty string. 
								if ( DATA_VALUE != null && DATA_VALUE == arrLIST[i] )
								{
									lstSelected = arrLIST[i];
								}
							}
							// 03/27/2019 Paul.  If record has value and array does not contain a match, then add the value to the list. 
							if ( DATA_VALUE != null && lstSelected == null )
							{
								let optMissing = { key: DATA_VALUE, text: DATA_VALUE };
								lstOptions.push(optMissing);
								BIT_VALUES.push(true);
								lstSelected = DATA_VALUE;
							}
						}
						// 06/19/2018 Paul.  The first item needs to be selected by default, unless multi-select is used. 
						if ( row == null && lstSelected != null && lstSelected.length == 0 && lstOptions.length > 0 && Math.abs(FORMAT_ROWS) == 0 )
						{
							BIT_VALUES[0] = true;
							lstSelected.push(lstOptions[0]);
						}
					}
				}
				// 06/19/2018 Paul.  DATA_VALUE must be a scalar if list is not multiple. 
				// 03/20/2019 Paul.  lstSelected may have been already been assigned a scalar. 
				if ( Math.abs(FORMAT_ROWS) == 0 && Array.isArray(lstSelected) )
				{
					if ( lstSelected != null && lstSelected.length > 0 )
					{
						lstSelected = lstSelected[0];
					}
					else
					{
						lstSelected = null;
					}
				}
				// 03/27/2019 Paul.  If list is multiselect, then make sure that selected is an array. 
				else if (Math.abs(FORMAT_ROWS) != 0 && !Array.isArray(lstSelected) )
				{
					if ( !Sql.IsEmptyString(lstSelected) )
					{
						let s = lstSelected;
						lstSelected = [];
						lstSelected.push(s);
					}
					else
					{
						lstSelected = [];
					}
				}
				// 03/30/2019 Paul.  `value` prop on `select` should not be null. Consider using an empty string to clear the component or `undefined` for uncontrolled components.
				if ( lstSelected == null )
				{
					lstSelected = undefined;
					// 03/30/2019 Paul.  If row is null and single selection, then this might be a SearchView that needs the default value set. 
					if ( row == null && Math.abs(FORMAT_ROWS) == 0 && lstOptions != null && lstOptions.length > 0 )
					{
						let value = lstOptions[0].key;
						onChanged(DATA_FIELD, value);
						onUpdate (DATA_FIELD, value);
					}
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, lstSelected, row);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		this.state =
		{
			ID               ,
			FIELD_INDEX      ,
			DATA_FIELD       ,
			DATA_VALUE       : lstSelected,
			BIT_VALUES       ,
			LIST_NAME        ,
			LIST_VALUES      : lstOptions,
			DATA_FORMAT      ,
			PARENT_FIELD     ,
			UI_REQUIRED      ,
			FORMAT_TAB_INDEX ,
			FORMAT_ROWS      ,
			ONCLICK_SCRIPT   ,
			VALUE_MISSING    : false,
			ENABLED          ,
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

	// shouldComponentUpdate is not used with a PureComponent
	shouldComponentUpdate(nextProps: IEditComponentProps, nextState: IRelatedListBoxState)
	{
		const { DATA_FIELD, DATA_VALUE, VALUE_MISSING, ENABLED } = this.state;
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
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		else if ( nextProps.bIsHidden != this.props.bIsHidden )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.DATA_VALUE != this.state.DATA_VALUE )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		// 11/03/2019 Paul.  Use stringify to compare arrays. 
		else if ( JSON.stringify(nextState.BIT_VALUES) != JSON.stringify(this.state.BIT_VALUES) )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.VALUE_MISSING != this.state.VALUE_MISSING || nextState.ENABLED != this.state.ENABLED )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, VALUE_MISSING, nextProps, nextState);
			return true;
		}
		else if ( nextState.CSS_CLASS != this.state.CSS_CLASS )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, CSS_CLASS, nextProps, nextState);
			return true;
		}
		return false;
	}

	componentDidCatch(error, info)
	{
		const { DATA_FIELD, DATA_VALUE } = this.state;
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch ' + DATA_FIELD, error, info);
	}

	private _onSelectChange = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD, BIT_VALUES, FORMAT_ROWS, ENABLED } = this.state;
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				if ( Math.abs(FORMAT_ROWS) > 0 )
				{
					// 09/09/2019 Paul.  We need to modify a copy so that the shouldUpdate will fire. 
					let NEW_BIT_VALUES = BIT_VALUES.slice();
					let index = event.target.selectedIndex;
					let DATA_VALUE = null;
					let selectedOptions = event.target.selectedOptions;
					for ( let i = 0; i < NEW_BIT_VALUES.length; i++ )
					{
						NEW_BIT_VALUES[i] = false;
					}
					let lstSelected: any = [];
					for ( let i = 0; i < selectedOptions.length; i++ )
					{
						NEW_BIT_VALUES[selectedOptions[i].index] = true;
						lstSelected.push(selectedOptions[i].value);
					}
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectChange ' + DATA_FIELD, lstSelected);
					this.setState({ DATA_VALUE: lstSelected, BIT_VALUES: NEW_BIT_VALUES }, this.validate);
					onChanged(DATA_FIELD, lstSelected);
					onUpdate (DATA_FIELD, lstSelected);
				}
				else
				{
					let value = event.target.value;
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, value);
					this.setState({ DATA_VALUE: value }, this.validate);
					onChanged(DATA_FIELD, value);
					onUpdate (DATA_FIELD, value);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	public render()
	{
		const { baseId, layout, row, onChanged } = this.props;
		const { ID, FIELD_INDEX, DATA_VALUE, DATA_FIELD, BIT_VALUES, LIST_NAME, LIST_VALUES, PARENT_FIELD, DATA_FORMAT, UI_REQUIRED, FORMAT_ROWS, FORMAT_TAB_INDEX, VALUE_MISSING, ENABLED, CSS_CLASS } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render ' + DATA_FIELD, DATA_VALUE);
		try
		{
			if ( layout == null )
			{
				return (<span>layout is null</span>);
			}
			else if ( Sql.IsEmptyString(DATA_FIELD) )
			{
				return (<span>DATA_FIELD is empty for RelatedListBox FIELD_INDEX { FIELD_INDEX }</span>);
			}
			else if ( Sql.IsEmptyString(LIST_NAME) )
			{
				return (<div>LIST_NAME is empty for RelatedListBox DATA_FIELD { DATA_FIELD }</div>);
			}
			else if ( onChanged == null )
			{
				return (<span>onChanged is null for RelatedListBox DATA_FIELD { DATA_FIELD }</span>);
			}
			// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
			else if ( layout.hidden )
			{
				return (<span></span>);
			}
			else
			{
				// 09/27/2012 Paul. Allow onchange code to be stored in the database.  
				//if (!Sql.IsEmptyString(ONCLICK_SCRIPT))
				//{
				//	// 05/16/2018 Paul.  Defer script.
				//	//lst.onchange = BindArguments(function(ONCLICK_SCRIPT)
				//	//{
				//	//	if ( StartsWith(ONCLICK_SCRIPT, 'return ') )
				//	//		ONCLICK_SCRIPT = ONCLICK_SCRIPT.substring(7);
				//	//	eval(ONCLICK_SCRIPT);
				//	//}, ONCLICK_SCRIPT);
				//}
				let cssRequired = { paddingLeft: '4px', display: (VALUE_MISSING ? 'inline' : 'none') };
				// 08/03/2017 Paul.  We need a way to insert NONE into the a ListBox while still allowing multiple rows. 
				// The trick will be to use a negative number.  Use an absolute value here to reduce the areas to fix. 
				if (Math.abs(FORMAT_ROWS) > 0)
				{
					return (
						<span>
							<select
								id={ ID }
								key={ ID }
								multiple={ true }
								size={ Math.abs(FORMAT_ROWS) }
								tabIndex={ FORMAT_TAB_INDEX }
								onChange={ this._onSelectChange }
								value={ DATA_VALUE }
								disabled={ !ENABLED }
								className={ CSS_CLASS }
							>
								{
									LIST_VALUES.map((item, index) => 
									{
										// 06/19/2018 Paul.  Don't need to manually select the option. 
										//if ( BIT_VALUES[index] )
										//	return (<option id={ ID + '_' + index.toString() } key={ ID + '_' + index.toString() } value={ item.key } selected={ true }>{ item.text }</option>);
										//else
										return (<option id={ID + '_' + index.toString()} key={ID + '_' + index.toString()} value={item.key}>{item.text}</option>);
									})
								}
							</select>
							{ UI_REQUIRED ? <span id={ID + '_REQUIRED'} key={ID + '_REQUIRED'} className="required" style={cssRequired} >{L10n.Term('.ERR_REQUIRED_FIELD')}</span> : null}
						</span>
					);
				}
				else
				{
					return (
						<span>
							<select
								id={ ID }
								key={ ID }
								tabIndex={ FORMAT_TAB_INDEX }
								onChange={ this._onSelectChange }
								value={ DATA_VALUE }
								disabled={ !ENABLED }
								className={ CSS_CLASS }
							>
								{
									LIST_VALUES.map((item, index) => 
									{
										// 06/19/2018 Paul.  Don't need to manually select the option. 
										//if ( item.key == DATA_VALUE )
										//	return (<option id={ ID + '_' + index.toString() } key={ ID + '_' + index.toString() } value={ item.key } selected={ true }>{ item.text }</option>);
										//else
										return (<option id={ID + '_' + index.toString()} key={ID + '_' + index.toString()} value={item.key}>{item.text}</option>);
									})
								}
							</select>
							{ UI_REQUIRED ? <span id={ID + '_REQUIRED'} key={ID + '_REQUIRED'} className="required" style={cssRequired} >{L10n.Term('.ERR_REQUIRED_FIELD')}</span> : null}
						</span>
					);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.render', error);
			return (<span>{ error.message }</span>);
		}
	}
}

