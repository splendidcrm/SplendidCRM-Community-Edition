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
import { isObservableArray }                  from 'mobx'                    ;
import * as XMLParser                         from 'fast-xml-parser'         ;
import Select                                 from 'react-select'            ;
// 2. Store and Types. 
import { IEditComponentProps, EditComponent } from '../types/EditComponent'  ;
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'          ;
import L10n                                   from '../scripts/L10n'         ;
import SplendidCache                          from '../scripts/SplendidCache';
import { StartsWith }                         from '../scripts/utility'      ;
import Credentials                            from '../scripts/Credentials'  ;
// 4. Components and Views. 

interface IListBoxState
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

export default class ListBox extends EditComponent<IEditComponentProps, IListBoxState>
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
				// 02/04/2025 Paul.  Switch condition. 
				bVALUE_MISSING = !(DATA_VALUE != null && DATA_VALUE.length > 0);
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
		const { layout, onChanged, onUpdate } = this.props;
		const { DATA_FIELD } = this.state;
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.setState({ DATA_VALUE });
		}
		else if ( PROPERTY_NAME == 'list' )
		{
			let LIST_NAME: string = DATA_VALUE;
			let objValue: any = this.getValues(layout, null, LIST_NAME);
			DATA_VALUE  = objValue.DATA_VALUE ;
			let BIT_VALUES       : boolean[] = objValue.BIT_VALUES ;
			let lstOptions       : any[]     = objValue.lstOptions ;
			let lstSelected      : any       = objValue.lstSelected;
			this.setState({ DATA_VALUE: lstSelected, BIT_VALUES, LIST_VALUES: lstOptions });
			onChanged(DATA_FIELD, lstSelected);
			onUpdate (DATA_FIELD, lstSelected);
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
		const { FORMAT_ROWS, ENABLED } = this.state;
		// 01/11/2020.  Apply Field Level Security. 
		if ( ENABLED )
		{
			// 10/05/2020 Paul.  Clear needs to set value to text unless it is an array. 
			if ( Math.abs(FORMAT_ROWS) > 0 )
			{
				let lstSelected = [];
				lstSelected.push('');
				this.setState(
				{
					DATA_VALUE: lstSelected
				});
			}
			else
			{
				this.setState(
				{
					DATA_VALUE: ''
				});
			}
		}
	}

	constructor(props: IEditComponentProps)
	{
		super(props);
		const { baseId, layout, row, onChanged } = this.props;
		let FIELD_INDEX      : number    = 0;
		let DATA_FIELD       : string    = '';
		let DATA_LABEL       : string    = '';
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
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX     );
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD      );
				DATA_LABEL        = Sql.ToString (layout.DATA_LABEL      );
				DATA_FORMAT       = Sql.ToString (layout.DATA_FORMAT     );
				LIST_NAME         = Sql.ToString (layout.LIST_NAME       );
				PARENT_FIELD      = Sql.ToString (layout.PARENT_FIELD    );
				UI_REQUIRED       = Sql.ToBoolean(layout.UI_REQUIRED     ) || Sql.ToBoolean(layout.DATA_REQUIRED);
				FORMAT_TAB_INDEX  = Sql.ToInteger(layout.FORMAT_TAB_INDEX);
				FORMAT_ROWS       = Sql.ToInteger(layout.FORMAT_ROWS     );
				ONCLICK_SCRIPT    = Sql.ToString (layout.ONCLICK_SCRIPT  );
				ID = baseId + '_' + DATA_FIELD;
				// 01/17/2018 Paul.  Add DATA_FORMAT to ListBox support force user selection. 
				if ( UI_REQUIRED || Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('force') >= 0 )
				{
					UI_REQUIRED = true;
				}

				// 12/13/2013 Paul.  Allow each product to have a default tax rate. 
				if ( DATA_FIELD == 'TAX_CLASS' )
				{
					// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
					// 07/22/2019 Paul.  Using Crm_Config.ToBoolean() was causing an import problem.  Just go direct. 
					let bEnableTaxLineItems: boolean = Sql.ToBoolean(SplendidCache.Config('Orders.TaxLineItems'));
					if ( bEnableTaxLineItems )
					{
						DATA_LABEL = "ProductTemplates.LBL_TAXRATE_ID";
						DATA_FIELD = "TAXRATE_ID";
						LIST_NAME  = "TaxRates";
					}
				}

				// 09/27/2012 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
				if ( !Sql.IsEmptyString(PARENT_FIELD) )
				{
					// 08/10/2019 Paul.  Establish the dependency, but then get the parent list if record is available. 
					props.createDependency(DATA_FIELD, PARENT_FIELD, 'list');
					if ( row && Sql.IsEmptyString(LIST_NAME) )
					{
						LIST_NAME = Sql.ToString(row[PARENT_FIELD]);
					}
				}
				if ( !Sql.IsEmptyString(LIST_NAME) )
				{
					let objValue: any = this.getValues(layout, row, LIST_NAME);
					DATA_VALUE  = objValue.DATA_VALUE ;
					BIT_VALUES  = objValue.BIT_VALUES ;
					lstOptions  = objValue.lstOptions ;
					lstSelected = objValue.lstSelected;
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, lstSelected, row);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + layout.EDIT_NAME + ' ' + DATA_FIELD, error);
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
	shouldComponentUpdate(nextProps: IEditComponentProps, nextState: IListBoxState)
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
			//console.log((new Date()).toISOString() + ' ' + 'TextBox.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if (nextState.DATA_VALUE != this.state.DATA_VALUE )
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

	private getValues = (layout: any, row: any, LIST_NAME: string): any =>
	{
		const { onChanged } = this.props;
		let DATA_VALUE       : any       = null;
		let BIT_VALUES       : boolean[] = [];
		let lstOptions       : any[]     = [];
		let lstSelected      : any       = null;

		let DATA_FIELD       : string  = Sql.ToString (layout.DATA_FIELD      );
		let DATA_FORMAT      : string  = Sql.ToString (layout.DATA_FORMAT     );
		let FORMAT_ROWS      : number  = Sql.ToInteger(layout.FORMAT_ROWS     );
		let UI_REQUIRED      : boolean = Sql.ToBoolean(layout.UI_REQUIRED     ) || Sql.ToBoolean(layout.DATA_REQUIRED);

		let arrLIST: string[] = L10n.GetList(LIST_NAME);
		if ( arrLIST != null )
		{
			if ( row )
			{
				// 06/14/2018 Paul.  Sql.ToString will not convert an array to a string, so it is safe to use Array.isArray() below. 
				DATA_VALUE = row[DATA_FIELD];
				// 03/27/2019 Paul.  Lets not use Sql.ToString in case the behavior changes in the future. 
				// 08/19/2019 Paul.  We don't want to initialize the data value as it will cause a blank item at the bottom of the list. 
				//if ( DATA_VALUE === undefined || DATA_VALUE == null )
				//{
				//	DATA_VALUE = '';
				//}
				// 06/14/2018 Paul.  Special case where dashboard search needs to allow none. 
				// 01/13/2018 Paul.  Terminology is now an ObservableArray. 
				// 06/14/2020 Paul.  0 was being treated as false, so explicitly test for undefined or null. 
				if ( !(DATA_VALUE === undefined || DATA_VALUE == null) )
				{
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
			}
			// 05/06/2022 Paul.  Set the default value for Currencies. 
			if ( LIST_NAME == 'Currencies' )
			{
				if ( !(row && row[DATA_FIELD] !== undefined) )
				{
					DATA_VALUE = Credentials.sUSER_CURRENCY_ID;
				}
			}
			for ( let i = 0; i < arrLIST.length; i++ )
			{
				BIT_VALUES.push(false);
			}
			// 04/23/2017 Paul.  We don't need a NONE record when using multi-selection. 
			// 01/17/2018 Paul.  Add DATA_FORMAT to ListBox support force user selection. 
			if ( (!UI_REQUIRED || Sql.ToString(DATA_FORMAT).toLowerCase().indexOf('force') >= 0) && FORMAT_ROWS <= 0 )
			{
				// 01/08/2018 Paul.  Some lists have the first entry as a blank. 
				if ( !(arrLIST.length > 0 && Sql.IsEmptyString(arrLIST[0])) )
				{
					let opt3 = { value: '', label: L10n.Term('.LBL_NONE') };
					lstOptions.push(opt3);
					BIT_VALUES.push(false);
					// 06/14/2020 Paul.  0 was being treated as false, so explicitly test for undefined or null. 
					if ( !(DATA_VALUE === undefined || DATA_VALUE == null) )
					{
						// 01/13/2018 Paul.  Terminology is now an ObservableArray. 
						if ( Array.isArray(DATA_VALUE) || isObservableArray(DATA_VALUE) )
						{
							if ( DATA_VALUE.length >= 1 )
							{
								// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
								if ( DATA_VALUE[0] === '' )
								{
									BIT_VALUES[0] = true;
									if ( Math.abs(FORMAT_ROWS) > 0 )
									{
										lstSelected = [];
										lstSelected.push('');
									}
									else
									{
										lstSelected = '';
									}
								}
							}
						}
						// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
						else if ( DATA_VALUE != null && DATA_VALUE === '' )
						{
							BIT_VALUES[0] = true;
							if ( Math.abs(FORMAT_ROWS) > 0 )
							{
								lstSelected = [];
								lstSelected.push('');
							}
							else
							{
								lstSelected = '';
							}
						}
					}
				}
			}
			for ( let i = 0; i < arrLIST.length; i++ )
			{
				let opt4 = { value: arrLIST[i], label: L10n.ListTerm(LIST_NAME, arrLIST[i]) };
				lstOptions.push(opt4);
			}
			// 01/06/2018 Paul.  Add DATA_FORMAT to ListBox support multi-select CSV. 
			if ( Math.abs(FORMAT_ROWS) > 0 )
			{
				lstSelected = [];
				// 06/14/2020 Paul.  0 was being treated as false, so explicitly test for undefined or null. 
				if ( !(DATA_VALUE === undefined || DATA_VALUE == null) )
				{
					// 01/13/2018 Paul.  Terminology is now an ObservableArray. 
					if ( Array.isArray(DATA_VALUE) || isObservableArray(DATA_VALUE) )
					{
						let DATA_VALUES = DATA_VALUE;
						for ( let i = 0; i < arrLIST.length; i++ )
						{
							for ( let j = 0; j < DATA_VALUES.length; j++ )
							{
								// 11/10/2020 Paul.  Just in case the value is a number, we need to treat as a string. 
								// This will prevent 1/0 of yes/no from causing 1 to be added to the list because 1 != '1'. 
								if ( DATA_VALUES[j] != null && Sql.ToString(DATA_VALUES[j]) == arrLIST[i] )
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
							// 11/11/2020 Paul.  Just in case the value is a number, we need to treat as a string. 
							if ( DATA_VALUES[j] != null && lstSelected.indexOf(Sql.ToString(DATA_VALUES[j])) < 0 )
							{
								let optMissing = { value: DATA_VALUES[j], label: DATA_VALUES[j] };
								lstOptions.push(optMissing);
								BIT_VALUES.push(true);
								lstSelected.push(DATA_VALUES[j]);
							}
						}
					}
					// 08/01/2013 Paul.  Expand XML values from CheckBoxList. 
					// 08/17/2019 Paul.  Process as XML before CSV just in case data in wrong format.  XML easy to detect. 
					else if ( StartsWith(DATA_VALUE, '<?xml') )
					{
						let xml = XMLParser.parse(DATA_VALUE);
						if ( xml.Values && xml.Values.Value && Array.isArray(xml.Values.Value) )
						{
							let DATA_VALUES: string[] = xml.Values.Value;
							for ( let i = 0; i < arrLIST.length; i++ )
							{
								for ( let j = 0; j < DATA_VALUES.length; j++ )
								{
									// 11/10/2020 Paul.  No need to convert to string here as we know xml is already string based. 
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
									let optMissing = { value: DATA_VALUES[j], label: DATA_VALUES[j] };
									lstOptions.push(optMissing);
									BIT_VALUES.push(true);
									lstSelected.push(DATA_VALUES[j]);
								}
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
								// 11/10/2020 Paul.  No need to convert to string here as we know csv is already string based. 
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
								let optMissing = { value: DATA_VALUES[j], label: DATA_VALUES[j] };
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
					else
					{
						// 11/10/2020 Paul.  Just in case the value is a number, we need to treat as a string. 
						// This will prevent 1/0 of yes/no from causing 1 to be added to the list because 1 != '1'. 
						if ( typeof(DATA_VALUE) == 'number' )
						{
							DATA_VALUE = Sql.ToString(DATA_VALUE);
						}
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
							let optMissing = { value: DATA_VALUE, label: DATA_VALUE };
							lstOptions.push(optMissing);
							BIT_VALUES.push(true);
							lstSelected.push(DATA_VALUE);
						}
					}
				}
			}
			else
			{
				lstSelected = null;
				// 06/14/2020 Paul.  0 was being treated as false, so explicitly test for undefined or null. 
				if ( !(DATA_VALUE === undefined || DATA_VALUE == null) )
				{
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
						let optMissing = { value: DATA_VALUE, label: DATA_VALUE };
						lstOptions.push(optMissing);
						BIT_VALUES.push(true);
						lstSelected = DATA_VALUE;
					}
				}
			}
			// 06/19/2018 Paul.  The first item needs to be selected by default, unless multi-select is used. 
			if ( row == null && lstSelected != null && lstSelected.length == 0 && lstOptions.length > 0 && Math.abs(FORMAT_ROWS) == 0 )
			{
				BIT_VALUES[0] = true;
				lstSelected.push(lstOptions[0]);
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
		else if ( Math.abs(FORMAT_ROWS) != 0 && !Array.isArray(lstSelected) )
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
			// 02/10/2020 Paul.  Some new records will have initial values, so row == null is not sufficient.  We need to check if field value is undefined. 
			// 10/12/2020 Paul.  List Value may be undefined or null. 
			if ( (row == null || row[DATA_FIELD] === undefined || row[DATA_FIELD] == null) && Math.abs(FORMAT_ROWS) == 0 && lstOptions != null && lstOptions.length > 0 )
			{
				lstSelected = lstOptions[0].value;
				// 04/21/2019 Paul.  We only need to initialize if there is a value. 
				// 01/26/2020 Paul.  The lstSelected value is used when initializing the list box. 
				if ( !Sql.IsEmptyString(lstSelected) )
				{
					onChanged(DATA_FIELD, lstSelected);
				}
				else
				{
					// 02/10/2020 Paul.  We perfer to return null if nothing selected, instead of empty string. 
					lstSelected = null
				}
			}
		}
		let objValue: any = { DATA_VALUE, BIT_VALUES, lstOptions, lstSelected};
		return objValue;
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
					for (let i = 0; i < NEW_BIT_VALUES.length; i++)
					{
						NEW_BIT_VALUES[i] = false;
					}
					let lstSelected: any = [];
					for (let i = 0; i < selectedOptions.length; i++)
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
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectChange', error);
		}
	}

	private _onMultiSelectChange = (selectedOption, action) =>
	{
		const { baseId, layout, row, onChanged, onUpdate } = this.props;
		const { DATA_FIELD, ENABLED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMultiSelectChange ' + DATA_FIELD, selectedOption, action);
		try
		{
			// 07/23/2019.  Apply Field Level Security. 
			if ( ENABLED )
			{
				// 09/09/2019 Paul.  We need to modify a copy so that the shouldUpdate will fire. 
				let lstSelected: any = [];
				if ( selectedOption != null )
				{
					for (let i = 0; i < selectedOption.length; i++)
					{
						lstSelected.push(selectedOption[i].value);
					}
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onMultiSelectChange ' + DATA_FIELD, lstSelected);
				this.setState({ DATA_VALUE: lstSelected }, this.validate);
				onChanged(DATA_FIELD, lstSelected);
				onUpdate (DATA_FIELD, lstSelected);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onMultiSelectChange', error);
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
				return (<span>DATA_FIELD is empty for ListBox FIELD_INDEX { FIELD_INDEX }</span>);
			}
			// 08/10/2019 Paul.  The LIST_NAME can be empty if there is a parent without a selected value. 
			else if ( Sql.IsEmptyString(LIST_NAME) && Sql.IsEmptyString(PARENT_FIELD) )
			{
				return (<div>LIST_NAME is empty for ListBox DATA_FIELD { DATA_FIELD }</div>);
			}
			else if ( onChanged == null )
			{
				return (<span>onChanged is null for ListBox DATA_FIELD { DATA_FIELD }</span>);
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
				// 02/25/2022 Paul.  Should be csv not cvs.  Support both for backward compatibility. 
				if ( Math.abs(FORMAT_ROWS) > 0 && (DATA_FORMAT == 'csv' || DATA_FORMAT == 'cvs') )
				{
					// 05/23/2019 Paul.  select value should not be null. 
					// 01/29/2020 Paul.  Use a better multi-select. 
					// https://github.com/JedWatson/react-select
					// https://react-select.com/home
					let DATA_VALUES: any = [];
					// 06/14/2020 Paul.  0 was being treated as false, so explicitly test for undefined or null. 
					if ( !(DATA_VALUE === undefined || DATA_VALUE == null) )
					{
						for ( let i = 0; i < DATA_VALUE.length; i++ )
						{
							DATA_VALUES.push({ value: DATA_VALUE[i], label: L10n.ListTerm(LIST_NAME, DATA_VALUE[i]) });
						}
					}
					// https://react-select.com/styles
					const customStyles =
					{
						control: (provided, state) => (
						{
							...provided,
							padding: 0,
							minHeight: 0,
							minWidth: 150,
							'&:hover': { borderColor: 'black'},
							'&:focus': { borderColor: 'black'},
							'&:active': { borderColor: 'black'},
						}),
						container: (provided, state) => (
						{
							...provided,
							padding: 0,
						}),
						valueContainer: (provided, state) => (
						{
							...provided,
							padding: 0,
						}),
						clearIndicator: (provided, state) => (
						{
							...provided,
							paddingLeft  : 4,
							paddingRight : 4,
							paddingTop   : 2,
							paddingBottom: 2,
						}),
						dropdownIndicator: (provided, state) => (
						{
							...provided,
							paddingLeft  : 4,
							paddingRight : 4,
							paddingTop   : 2,
							paddingBottom: 2,
						}),
					};
					return (
						<span style={ {marginRight: '4px'} }>
							<Select
								id={ ID }
								key={ ID }
								isMulti={ true }
								isSearchable={ false }
								closeMenuOnSelect={ false }
								aria-setsize={ Math.abs(FORMAT_ROWS) }
								tabIndex={ FORMAT_TAB_INDEX }
								onChange={ this._onMultiSelectChange }
								value={ DATA_VALUES }
								isDisabled={ !ENABLED }
								className={ CSS_CLASS }
								options={ LIST_VALUES }
								placeholder={ L10n.Term('.LBL_NONE') }
								styles={ customStyles }
							/>
							{ UI_REQUIRED ? <span id={ ID + '_REQUIRED' } key={ ID + '_REQUIRED' } className="required" style={ cssRequired }>{ L10n.Term('.ERR_REQUIRED_FIELD') }</span> : null }
						</span>
					);
				}
				// 01/30/2020 Paul.  SearchView still looks better with old-style multi-selection list box. 
				else if ( Math.abs(FORMAT_ROWS) > 0 )
				{
					// 05/23/2019 Paul.  select value should not be null. 
					return (
						<span style={ {marginRight: '4px'} }>
							<select
								id={ ID }
								key={ ID }
								multiple={ true }
								size={ Math.abs(FORMAT_ROWS) }
								tabIndex={ FORMAT_TAB_INDEX }
								onChange={ this._onSelectChange }
								value={ DATA_VALUE ? DATA_VALUE : [] }
								disabled={ !ENABLED }
								className={ CSS_CLASS }
						>
								{
									LIST_VALUES.map((item, index) => 
									{
										// 06/19/2018 Paul.  Don't need to manually select the option. 
										//if ( BIT_VALUES[index] )
										//	return (<option id={ ID + '_' + index.toString() } key={ ID + '_' + index.toString() } value={ item.value } selected={ true }>{ item.label }</option>);
										//else
										return (<option id={ ID + '_' + index.toString() } key={ ID + '_' + index.toString() } value={ item.value }>{ item.label }</option>);
									})
								}
							</select>
							{ UI_REQUIRED ? <span id={ID + '_REQUIRED'} key={ID + '_REQUIRED'} className="required" style={cssRequired} >{L10n.Term('.ERR_REQUIRED_FIELD')}</span> : null}
						</span>
					);
				}
				else
				{
					// 05/23/2019 Paul.  select value should not be null. 
					return (
						<span style={ {marginRight: '4px'} }>
							<select
								id={ ID }
								key={ ID }
								tabIndex={ FORMAT_TAB_INDEX }
								onChange={ this._onSelectChange }
								value={ DATA_VALUE ? DATA_VALUE : '' }
								disabled={ !ENABLED }
								className={ CSS_CLASS }
							>
								{
									LIST_VALUES.map((item, index) => 
									{
										// 06/19/2018 Paul.  Don't need to manually select the option. 
										//if ( item.value == DATA_VALUE )
										//	return (<option id={ ID + '_' + index.toString() } key={ ID + '_' + index.toString() } value={ item.value } selected={ true }>{ item.label }</option>);
										//else
										return (<option id={ ID + '_' + index.toString() } key={ ID + '_' + index.toString() } value={ item.value }>{ item.label }</option>);
									})
								}
							</select>
							{ UI_REQUIRED ? <span id={ ID + '_REQUIRED' } key={ ID + '_REQUIRED' } className="required" style={ cssRequired }>{ L10n.Term('.ERR_REQUIRED_FIELD') }</span> : null }
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

