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
import * as XMLParser                                 from 'fast-xml-parser'                  ;
import { NavDropdown }                                from 'react-bootstrap'                  ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                            from '../../scripts/Sql'                ;
import L10n                                           from '../../scripts/L10n'               ;
import Security                                       from '../../scripts/Security'           ;
import Credentials                                    from '../../scripts/Credentials'        ;
import SplendidCache                                  from '../../scripts/SplendidCache'      ;
import { Crm_Config, Crm_Modules }                    from '../../scripts/Crm'                ;
import { dumpObj, uuidFast }                          from '../../scripts/utility'            ;
import { CreateSplendidRequest, GetSplendidResult }   from '../../scripts/SplendidRequest'    ;
// 4. Components and Views. 
import NavItem                                        from '../../components/NavItem'         ;
import ErrorComponent                                 from '../../components/ErrorComponent'  ;

let bDebug: boolean = false;

interface IRuleBuilderProps
{
	RULE_TYPE                   : string      ;
	row                         : any         ;
	onChanged                   : (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any) => void;
}

interface IRuleBuilderState
{
	ruleColumns          : any[];
	rulesXml             : any;
	rulesXmlJson         : string;

	RULE_PRIORITY        : number;
	RULE_REEVALUATION    : string;
	RULE_ACTIVE          : boolean;
	RULE_CONDITION       : string;
	RULE_CONDITION_REQ   : boolean;
	RULE_THEN_ACTIONS    : string;
	RULE_THEN_ACTIONS_REQ: boolean;
	RULE_ELSE_ACTIONS    : string;
	rulesXmlEditIndex    : number;

	error?               : any;
}

export default class RuleBuilder extends React.Component<IRuleBuilderProps, IRuleBuilderState>
{
	private _isMounted    : boolean = false;
	private themeURL      : string;

	public get data(): any
	{
		const { rulesXml } = this.state;
		let row: any = { rulesXml };
		return row;
	}

	public validate(): boolean
	{
		let bValid: boolean = true;
		return bValid;
	}

	public error(): any
	{
		return this.state.error;
	}

	constructor(props: IRuleBuilderProps)
	{
		super(props);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/';
		this.state =
		{
			ruleColumns            : []     ,
			rulesXml               : {}     ,
			rulesXmlJson           : null   ,

			RULE_PRIORITY          : 0      ,
			RULE_REEVALUATION      : 'never',
			RULE_ACTIVE            : true   ,
			RULE_CONDITION         : null   ,
			RULE_CONDITION_REQ     : false  ,
			RULE_THEN_ACTIONS      : null   ,
			RULE_THEN_ACTIONS_REQ  : false  ,
			RULE_ELSE_ACTIONS      : null   ,
			rulesXmlEditIndex      : -1     ,

			error                  : null   ,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	// As soon as the render method has been executed the componentDidMount function is called. 
	async componentDidMount()
	{
		const { row } = this.props;
		this._isMounted = true;
		try
		{
			let options: any = 
			{
				attributeNamePrefix: ''     ,
				textNodeName       : 'Value',
				ignoreAttributes   : false  ,
				ignoreNameSpace    : true   ,
				parseAttributeValue: true   ,
				trimValues         : false  ,
			};

			let rulesXml    : any     = null;
			let rulesXmlJson: string  = null;
			if ( !Sql.IsEmptyString(row['RULES_XML']) )
			{
				// 08/12/2023 Paul.  XMLParser 3.21.1 is not parsing &amp;, and 4.2.7 crashes the build, so manually parse. 
				const RULES_XML = row['RULES_XML'].replace(/&amp;/g, '&');
				rulesXml     = XMLParser.parse(RULES_XML, options);
				// 05/20/2020 Paul.  A single record will not come in as an array, so convert to an array. 
				if ( rulesXml.NewDataSet && rulesXml.NewDataSet.Table1 && !Array.isArray(rulesXml.NewDataSet.Table1) )
				{
					let table1: any = rulesXml.NewDataSet.Table1;
					rulesXml.NewDataSet.Table1 = [];
					rulesXml.NewDataSet.Table1.push(table1);
				}
				rulesXmlJson = dumpObj(rulesXml, 'rulesXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
			}

			let ruleColumns: any[] = await this.LoadModuleFields(row['MODULE_NAME']);
			this.setState(
			{
				ruleColumns       ,
				rulesXml          ,
				rulesXmlJson      ,
				error             : null,
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	shouldComponentUpdate(nextProps: IRuleBuilderProps, nextState: IRuleBuilderState)
	{
		if ( this.props.row != null && nextProps.row != null )
		{
			if ( this.props.row['MODULE_NAME'] != nextProps.row['MODULE_NAME'] )
			{
				let MODULE: string = nextProps.row['MODULE_NAME'];
				this.moduleChanged(MODULE, true);
			}
			else if ( this.props.row['RULES_XML'] != nextProps.row['RULES_XML'] )
			{
				let options: any = 
				{
					attributeNamePrefix: ''     ,
					textNodeName       : 'Value',
					ignoreAttributes   : false  ,
					ignoreNameSpace    : true   ,
					parseAttributeValue: true   ,
					trimValues         : false  ,
				};

				let rulesXml    : any     = null;
				let rulesXmlJson: string  = null;
				if ( !Sql.IsEmptyString(nextProps.row['RULES_XML']) )
				{
					// 08/12/2023 Paul.  XMLParser 3.21.1 is not parsing &amp;, and 4.2.7 crashes the build, so manually parse. 
					const RULES_XML = nextProps.row['RULES_XML'].replace(/&amp;/g, '&');
					rulesXml     = XMLParser.parse(RULES_XML, options);
					// 05/20/2020 Paul.  A single record will not come in as an array, so convert to an array. 
					if ( rulesXml.NewDataSet && rulesXml.NewDataSet.Table1 && !Array.isArray(rulesXml.NewDataSet.Table1) )
					{
						let table1: any = rulesXml.NewDataSet.Table1;
						rulesXml.NewDataSet.Table1 = [];
						rulesXml.NewDataSet.Table1.push(table1);
					}
					rulesXmlJson = dumpObj(rulesXml, 'rulesXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
				}
				this.setState(
				{
					rulesXml          ,
					rulesXmlJson      ,
					error             : null,
				});
			}
		}
		return true;
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private moduleChanged = async (MODULE: string, bClearRules: boolean) =>
	{
		let { rulesXml, rulesXmlJson, rulesXmlEditIndex } = this.state;
		if ( bClearRules )
		{
			rulesXml          = null;
			rulesXmlJson      = '';
			rulesXmlEditIndex = -1;
		}
		let ruleColumns: any[] = await this.LoadModuleFields(MODULE);
		this.setState(
		{
			ruleColumns       ,
			rulesXml          ,
			rulesXmlJson      ,
			error             : null,
		});
	}

	private LoadModuleFields = async (MODULE_NAME: string) =>
	{
		let ruleColumns: any[] = [];
		try
		{
			let res  = await CreateSplendidRequest('Reports/Rest.svc/GetModuleColumns?MODULE_NAME=' + MODULE_NAME, 'GET');
			let json = await GetSplendidResult(res);
			let obj: any = json.d;
			ruleColumns = obj.results;
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadModuleFields', ruleColumns);
		}
		catch(error)
		{
			this.setState({ error });
		}
		return ruleColumns;
	}

	private _onRulesEdit = (index: number) =>
	{
		let { rulesXml } = this.state;
		let RULE_PRIORITY       : number  = 0;
		let RULE_ACTIVE         : boolean = true;
		let RULE_CONDITION      : string  = '';
		let RULE_THEN_ACTIONS   : string  = '';
		let RULE_ELSE_ACTIONS   : string  = '';
		if ( rulesXml && rulesXml.NewDataSet && rulesXml.NewDataSet.Table1 && index < rulesXml.NewDataSet.Table1.length )
		{
			RULE_PRIORITY     = Sql.ToInteger(rulesXml.NewDataSet.Table1[index]['PRIORITY'    ]);
			RULE_ACTIVE       = Sql.ToBoolean(rulesXml.NewDataSet.Table1[index]['ACTIVE'      ]);
			RULE_CONDITION    = Sql.ToString (rulesXml.NewDataSet.Table1[index]['CONDITION'   ]);
			RULE_THEN_ACTIONS = Sql.ToString (rulesXml.NewDataSet.Table1[index]['THEN_ACTIONS']);
			RULE_ELSE_ACTIONS = Sql.ToString (rulesXml.NewDataSet.Table1[index]['ELSE_ACTIONS']);
		}
		this.setState(
		{
			RULE_PRIORITY        ,
			RULE_ACTIVE          ,
			RULE_CONDITION       ,
			RULE_CONDITION_REQ   : false,
			RULE_THEN_ACTIONS    ,
			RULE_THEN_ACTIONS_REQ: false,
			RULE_ELSE_ACTIONS    ,
			rulesXmlEditIndex    : index,
		});
	}

	private _onRulesRemove = (index: number) =>
	{
		let { rulesXml } = this.state;
		if ( rulesXml && rulesXml.NewDataSet && rulesXml.NewDataSet.Table1 && index < rulesXml.NewDataSet.Table1.length )
		{
			rulesXml.NewDataSet.Table1.splice(index, 1);
			let rulesXmlJson = dumpObj(rulesXml, 'rulesXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
			this.setState(
			{
				rulesXml             ,
				rulesXmlJson         ,
				RULE_PRIORITY        : 0,
				RULE_ACTIVE          : true,
				RULE_CONDITION       : '',
				RULE_CONDITION_REQ   : false,
				RULE_THEN_ACTIONS    : '',
				RULE_THEN_ACTIONS_REQ: false,
				RULE_ELSE_ACTIONS    : '',
				rulesXmlEditIndex    : -1,
			});
		}
	}

	private _onRulesUpdate = async (e) =>
	{
		const { RULE_TYPE } = this.props;
		const { RULE_PRIORITY, RULE_REEVALUATION, RULE_ACTIVE, RULE_CONDITION, RULE_THEN_ACTIONS, RULE_ELSE_ACTIONS } = this.state;
		let { rulesXml, rulesXmlEditIndex } = this.state;

		if ( Sql.IsEmptyString(RULE_CONDITION) || Sql.IsEmptyString(RULE_THEN_ACTIONS) )
		{
			this.setState(
			{
				RULE_CONDITION_REQ   : Sql.IsEmptyString(RULE_CONDITION   ),
				RULE_THEN_ACTIONS_REQ: Sql.IsEmptyString(RULE_THEN_ACTIONS),
			});
			return;
		}
		try
		{
			let row: any = {};
			row.RULE_TYPE    = RULE_TYPE        ;
			row.PRIORITY     = RULE_PRIORITY    ;
			row.REEVALUATION = RULE_REEVALUATION;
			row.ACTIVE       = RULE_ACTIVE      ;
			row.CONDITION    = RULE_CONDITION   ;
			row.THEN_ACTIONS = RULE_THEN_ACTIONS;
			row.ELSE_ACTIONS = RULE_ELSE_ACTIONS;
			
			let sBody = JSON.stringify(row);
			// 06/06/2021 Paul.  ValidateRule was moved to ~/RulesWizard/Rest.svc. 
			let res  = await CreateSplendidRequest('RulesWizard/Rest.svc/ValidateRule', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);

			if ( !rulesXml )
			{
				rulesXml = {};
			}
			if ( !rulesXml.NewDataSet )
			{
				rulesXml.NewDataSet = {};
			}
			if ( !rulesXml.NewDataSet.Table1 || !Array.isArray(rulesXml.NewDataSet.Table1) )
			{
				rulesXml.NewDataSet.Table1 = [];
			}
			if ( rulesXmlEditIndex == -1 )
			{
				rulesXmlEditIndex = rulesXml.NewDataSet.Table1.length;
				rulesXml.NewDataSet.Table1.push({});
			}
			if ( rulesXml.NewDataSet.Table1[rulesXmlEditIndex] )
			{
				rulesXml.NewDataSet.Table1[rulesXmlEditIndex]['PRIORITY'    ] = Sql.ToInteger(RULE_PRIORITY    );
				rulesXml.NewDataSet.Table1[rulesXmlEditIndex]['REEVALUATION'] = Sql.ToString (RULE_REEVALUATION);
				rulesXml.NewDataSet.Table1[rulesXmlEditIndex]['ACTIVE'      ] = Sql.ToBoolean(RULE_ACTIVE      );
				rulesXml.NewDataSet.Table1[rulesXmlEditIndex]['CONDITION'   ] = Sql.ToString (RULE_CONDITION   );
				rulesXml.NewDataSet.Table1[rulesXmlEditIndex]['THEN_ACTIONS'] = Sql.ToString (RULE_THEN_ACTIONS);
				rulesXml.NewDataSet.Table1[rulesXmlEditIndex]['ELSE_ACTIONS'] = Sql.ToString (RULE_ELSE_ACTIONS);
				if ( Sql.IsEmptyString(rulesXml.NewDataSet.Table1[rulesXmlEditIndex]['ID']) )
				{
					rulesXml.NewDataSet.Table1[rulesXmlEditIndex]['ID'] = uuidFast();
				}
				if ( Sql.IsEmptyString(rulesXml.NewDataSet.Table1[rulesXmlEditIndex]['RULE_NAME']) )
				{
					rulesXml.NewDataSet.Table1[rulesXmlEditIndex]['RULE_NAME'] = uuidFast();
				}
		
				let rulesXmlJson = dumpObj(rulesXml, 'rulesXml').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
				this.setState(
				{
					rulesXml             ,
					rulesXmlJson         ,
					RULE_PRIORITY        : 0,
					RULE_ACTIVE          : true,
					RULE_CONDITION       : '',
					RULE_CONDITION_REQ   : false,
					RULE_THEN_ACTIONS    : '',
					RULE_THEN_ACTIONS_REQ: false,
					RULE_ELSE_ACTIONS    : '',
					rulesXmlEditIndex    : -1,
					error                : null
				});
			}
			else
			{
				this.setState({ error: 'invalid rulesXmlEditIndex' });
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onRulesUpdate invalid rulesXmlEditIndex', rulesXmlEditIndex);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onRulesUpdate', error);
			this.setState({ error });
		}
	}

	private _onRulesCancel = (e) =>
	{
		this.setState(
		{
			RULE_PRIORITY        : 0    ,
			RULE_ACTIVE          : true ,
			RULE_CONDITION       : ''   ,
			RULE_CONDITION_REQ   : false,
			RULE_THEN_ACTIONS    : ''   ,
			RULE_THEN_ACTIONS_REQ: false,
			RULE_ELSE_ACTIONS    : ''   ,
			rulesXmlEditIndex    : -1   ,
			error                : null ,
		});
	}

	private _onRulesInsertConditionVariable = (column: any) =>
	{
		let { RULE_CONDITION } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRulesInsertConditionVariable', column);
		switch ( column.CsType )
		{
			case 'Guid'      :  RULE_CONDITION = Sql.ToString(RULE_CONDITION) + 'this.ToGuid(this[\"'     + column.ColumnName + '\"]) ';  break;
			case 'short'     :  RULE_CONDITION = Sql.ToString(RULE_CONDITION) + 'this.ToShort(this[\"'    + column.ColumnName + '\"]) ';  break;
			case 'Int32'     :  RULE_CONDITION = Sql.ToString(RULE_CONDITION) + 'this.ToInteger(this[\"'  + column.ColumnName + '\"]) ';  break;
			case 'Int16'     :  RULE_CONDITION = Sql.ToString(RULE_CONDITION) + 'this.ToInteger(this[\"'  + column.ColumnName + '\"]) ';  break;
			case 'Int64'     :  RULE_CONDITION = Sql.ToString(RULE_CONDITION) + 'this.ToLong(this[\"'     + column.ColumnName + '\"]) ';  break;
			case 'float'     :  RULE_CONDITION = Sql.ToString(RULE_CONDITION) + 'this.ToFloat(this[\"'    + column.ColumnName + '\"]) ';  break;
			case 'decimal'   :  RULE_CONDITION = Sql.ToString(RULE_CONDITION) + 'this.ToDecimal(this[\"'  + column.ColumnName + '\"]) ';  break;
			case 'bool'      :  RULE_CONDITION = Sql.ToString(RULE_CONDITION) + 'this.ToBoolean(this[\"'  + column.ColumnName + '\"]) ';  break;
			case 'ansistring':  RULE_CONDITION = Sql.ToString(RULE_CONDITION) + 'this.ToString(this[\"'   + column.ColumnName + '\"]) ';  break;
			case 'string'    :  RULE_CONDITION = Sql.ToString(RULE_CONDITION) + 'this.ToString(this[\"'   + column.ColumnName + '\"]) ';  break;
			case 'DateTime'  :  RULE_CONDITION = Sql.ToString(RULE_CONDITION) + 'this.ToDateTime(this[\"' + column.ColumnName + '\"]) ';  break;
			case 'byte[]'    :  RULE_CONDITION = Sql.ToString(RULE_CONDITION) + 'this.ToBinary(this[\"'   + column.ColumnName + '\"]) ';  break;
			default          :  RULE_CONDITION = Sql.ToString(RULE_CONDITION) + 'this.ToString(this[\"'   + column.ColumnName + '\"]) ';  break;
		}
		this.setState({ RULE_CONDITION });
	}

	private _onRulesInsertThenVariable = (column: any) =>
	{
		let { RULE_THEN_ACTIONS } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRulesInsertThenVariable', column);
		RULE_THEN_ACTIONS = Sql.ToString(RULE_THEN_ACTIONS) + 'this[\"' + column.ColumnName + '\"]';
		this.setState({ RULE_THEN_ACTIONS });
	}

	private _onRulesInsertElseVariable = (column: any) =>
	{
		let { RULE_ELSE_ACTIONS } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRulesInsertElseVariable', column);
		RULE_ELSE_ACTIONS = Sql.ToString(RULE_ELSE_ACTIONS) + 'this[\"' + column.ColumnName + '\"]';
		this.setState({ RULE_ELSE_ACTIONS });
	}

	private _onRULE_PRIORITY_Change = (e) =>
	{
		this.setState({ RULE_PRIORITY: e.target.value });
	}

	private _onRULE_ACTIVE_Change = (e) =>
	{
		this.setState({ RULE_ACTIVE: e.target.checked });
	}

	private _onRULE_CONDITION_Change = (e) =>
	{
		this.setState({ RULE_CONDITION: e.target.value });
	}

	private _onRULE_THEN_ACTIONS_Change = (e) =>
	{
		this.setState({ RULE_THEN_ACTIONS: e.target.value });
	}

	private _onRULE_ELSE_ACTIONS_Change = (e) =>
	{
		this.setState({ RULE_ELSE_ACTIONS: e.target.value });
	}

	public render()
	{
		const { error } = this.state;
		const { RULE_PRIORITY, RULE_ACTIVE, RULE_CONDITION, RULE_CONDITION_REQ, RULE_THEN_ACTIONS, RULE_THEN_ACTIONS_REQ, RULE_ELSE_ACTIONS } = this.state;
		const { ruleColumns, rulesXml, rulesXmlJson } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', oReportDesign);
		try
		{
			let MODULE_NAME: string = this.props.row['MODULE_NAME'];
			let imgSchema = <img src={ this.themeURL + 'images/Schema.gif' } style={ {borderWidth: '0px', height: '16px', width: '16px', margin: 0, padding: 0} } />;
			// 10/21/2020 Paul.  Some themes look too tightly packed with the scaling. 
			let styCheckbox = { transform: 'scale(1.5)', display: 'inline', marginTop: '2px', marginBottom: '6px', marginRight: '6px' };
			// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
			if ( Crm_Config.ToBoolean('enable_legacy_icons') )
			{
				styCheckbox.transform = 'scale(1.0)';
				styCheckbox.marginBottom = '2px';
			}
			// 08/12/2023 Paul.  Use ErrorComponent as JSON.stringify is returning empty object. 
			return (
<div id='divRuleBuilder'>
	<ErrorComponent error={error} />
		<table id='dgRules' cellSpacing={ 0 } cellPadding={ 3 } style={ {borderCollapse: 'collapse', border: '1px solid black', width: '100%'} }>
			<tr>
				<td style={ {border: '1px solid black'} }>{ L10n.Term('Rules.LBL_LIST_PRIORITY'    ) }</td>
				<td style={ {border: '1px solid black'} }>{ L10n.Term('Rules.LBL_LIST_ACTIVE'      ) }</td>
				<td style={ {border: '1px solid black'} }>{ L10n.Term('Rules.LBL_LIST_CONDITION'   ) }</td>
				<td style={ {border: '1px solid black'} }>{ L10n.Term('Rules.LBL_LIST_THEN_ACTIONS') }</td>
				<td style={ {border: '1px solid black'} }>{ L10n.Term('Rules.LBL_LIST_ELSE_ACTIONS') }</td>
				<td style={ {border: '1px solid black'} }>&nbsp;</td>
			</tr>
			{ rulesXml && rulesXml.NewDataSet && rulesXml.NewDataSet.Table1 && Array.isArray(rulesXml.NewDataSet.Table1)
			? rulesXml.NewDataSet.Table1.map((item, index) => 
			{ return (
				<tr>
					<td style={ {border: '1px solid black'} }>{ Sql.ToString(item['PRIORITY'    ]) }</td>
					<td style={ {border: '1px solid black'} }>{ Sql.ToString(item['ACTIVE'      ]) }</td>
					<td style={ {border: '1px solid black'} }>{ Sql.ToString(item['CONDITION'   ]) }</td>
					<td style={ {border: '1px solid black'} }>{ Sql.ToString(item['THEN_ACTIONS']) }</td>
					<td style={ {border: '1px solid black'} }>{ Sql.ToString(item['ELSE_ACTIONS']) }</td>
					<td style={ {border: '1px solid black', width: '1%', whiteSpace: 'nowrap'} } align='left'>
						<input type='submit' className='button' value={ L10n.Term('.LBL_EDIT_BUTTON_LABEL'       ) } title={ L10n.Term('.LBL_EDIT_BUTTON_LABEL'       ) } onClick={ (e) => this._onRulesEdit(index) } />
						&nbsp;
						<input type='submit' className='button' value={ L10n.Term('Rules.LBL_REMOVE_BUTTON_LABEL') } title={ L10n.Term('Rules.LBL_REMOVE_BUTTON_LABEL') } onClick={ (e) => this._onRulesRemove(index) } />
					</td>
				</tr>);
			})
			: null
			}
		</table>
		<table className='tabForm' cellSpacing={ 1 } cellPadding={ 0 } style={ {width: '100%'} }>
			<tr>
				<td>
					<table className='tabEditView' style={ {width: '100%'} }>
						<tr>
							<td style={ {verticalAlign: 'top'} }>
								<span className='dataLabel'>{ L10n.Term('Rules.LBL_PRIORITY') }</span><br />
								<input type='text' size={ 10 } tabIndex={ 11 } value={ RULE_PRIORITY } onChange={ this._onRULE_PRIORITY_Change } />
							</td>
							<td style={ {verticalAlign: 'top'} }>
								<span className='dataLabel'>{ L10n.Term('Rules.LBL_ACTIVE') }</span><br />
								<span className='checkbox' style={ styCheckbox }>
									<input type='checkbox' checked={ RULE_ACTIVE } tabIndex={ 13 } onChange={ this._onRULE_ACTIVE_Change } />
								</span>
							</td>
							<td style={ {verticalAlign: 'top'} }>
								<br />
								<input type='submit' value={ L10n.Term('.LBL_UPDATE_BUTTON_LABEL') } title={ L10n.Term('.LBL_UPDATE_BUTTON_TITLE') } className='button' onClick={ this._onRulesUpdate } />
							</td>
							<td style={ {verticalAlign: 'top'} }>
								<br />
								<input type='submit' value={ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') } title={ L10n.Term('.LBL_CANCEL_BUTTON_TITLE') } className='button' onClick={ this._onRulesCancel } />
							</td>
							<td style={ {verticalAlign: 'top', width: '16px'} }></td>
							<td style={ {width: '20%'} }></td>
						</tr>
						<tr>
							<td style={ {verticalAlign: 'top'} } colSpan={ 4 }>
								<span className='dataLabel'>{ L10n.Term('Rules.LBL_CONDITION') }</span><span className='required'>*</span><br />
								<textarea rows={ 2 } cols={ 140 } tabIndex={ 14 } value={ RULE_CONDITION } onChange={ this._onRULE_CONDITION_Change } />
							</td>
							<td style={ {verticalAlign: 'top', width: '16px'} }>
								<span className='dataLabel'></span><br />
								<NavItem title={ imgSchema } id='ThenSchemaDropdown'>
									<div style={ {overflow: 'auto scroll', height: '350px', border: '1px solid black', backgroundColor: 'white', color: 'black', margin: 0, padding: 0} }>
										{
											ruleColumns.map((item) => 
											(
												<NavDropdown.Item key={ 'else_action_' + item.ColumnName } className='listViewCheckLink' onClick={ (e) => this._onRulesInsertConditionVariable(item) }>{ L10n.TableColumnName(MODULE_NAME, item.ColumnName) }</NavDropdown.Item>
											))
										}
									</div>
								</NavItem>
								<span className='required' style={ {paddingLeft: '4px', display: (RULE_CONDITION_REQ ? 'inline' : 'none')} } >{ L10n.Term('.ERR_REQUIRED_FIELD') }</span>
							</td>
							<td></td>
						</tr>
						<tr>
							<td style={ {verticalAlign: 'top'} } colSpan={ 4 }>
								<span className='dataLabel'>{ L10n.Term('Rules.LBL_THEN_ACTIONS') }</span><span className='required'>*</span><br />
								<textarea rows={ 3 } cols={ 140 } tabIndex={ 15 } value={ RULE_THEN_ACTIONS } onChange={ this._onRULE_THEN_ACTIONS_Change } />
							</td>
							<td style={ {verticalAlign: 'top', width: '16px'} }>
								<span className='dataLabel'></span><br />
								<NavItem title={ imgSchema } id='ThenSchemaDropdown'>
									<div style={ {overflow: 'auto scroll', height: '350px', border: '1px solid black', backgroundColor: 'white', color: 'black', margin: 0, padding: 0} }>
										{
											ruleColumns.map((item) => 
											(
												<NavDropdown.Item key={ 'else_action_' + item.ColumnName } className='listViewCheckLink' onClick={ (e) => this._onRulesInsertThenVariable(item) }>{ L10n.TableColumnName(MODULE_NAME, item.ColumnName) }</NavDropdown.Item>
											))
										}
									</div>
								</NavItem>
								<span className='required' style={ {paddingLeft: '4px', display: (RULE_THEN_ACTIONS_REQ ? 'inline' : 'none')} } >{ L10n.Term('.ERR_REQUIRED_FIELD') }</span>
							</td>
						<td></td>
						</tr>
						<tr>
							<td style={ {verticalAlign: 'top'} } colSpan={ 4 }>
								<span className='dataLabel'>{ L10n.Term('Rules.LBL_ELSE_ACTIONS') }</span><br />
								<textarea rows={ 3 } cols={ 140 } tabIndex={ 16 } value={ RULE_ELSE_ACTIONS } onChange={ this._onRULE_ELSE_ACTIONS_Change } />
							</td>
							<td style={ {verticalAlign: 'top', width: '16px'} }>
								<span className='dataLabel'></span><br />
								<NavItem title={ imgSchema } id='ThenSchemaDropdown'>
									<div style={ {overflow: 'auto scroll', height: '350px', border: '1px solid black', backgroundColor: 'white', color: 'black', margin: 0, padding: 0} }>
										{
											ruleColumns.map((item) => 
											(
												<NavDropdown.Item key={ 'else_action_' + item.ColumnName } className='listViewCheckLink' onClick={ (e) => this._onRulesInsertElseVariable(item) }>{ L10n.TableColumnName(MODULE_NAME, item.ColumnName) }</NavDropdown.Item>
											))
										}
									</div>
								</NavItem>
							</td>
							<td></td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
		{ bDebug 
		? <div>
			<div id='divRulesXmlDump'  dangerouslySetInnerHTML={ {__html: rulesXmlJson  } } style={ {marginTop: '20px', border: '1px solid black'} }></div>
		</div>
		: null
		}
</div>
			);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.render', error);
			return (<span>{ error.message }</span>);
		}
	}
}

