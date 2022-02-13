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
import { FontAwesomeIcon }                                  from '@fortawesome/react-fontawesome';
import TreeView                                             from 'react-treeview'                ;
import { Modal, ModalTitle }                                from 'react-bootstrap'               ;
// 2. Store and Types. 
import EDITVIEWS_FIELD                                      from '../types/EDITVIEWS_FIELD'      ;
// 3. Scripts. 
import Sql                                                  from '../scripts/Sql'                ;
import L10n                                                 from '../scripts/L10n'               ;
import Credentials                                          from '../scripts/Credentials'        ;
import SplendidCache                                        from '../scripts/SplendidCache'      ;
import { Crm_Config }                                       from '../scripts/Crm'                ;
import { ReportDesignerModules, ReportModule, ModuleField } from './ReportDesignerModules'       ;
import { ReportDesign, ReportTable, ReportField, ReportRelationship, ReportFilter, ReportJoinField, ReportDesign_EditView_Layout } from './ReportDesign';
// 4. Components and Views. 
import ModulePopup                                          from '../EditComponents/ModulePopup' ;

interface IQueryDesignerProps
{
	row                         : any         ;
	DATA_FIELD                  : string      ;
	onChanged                   : (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any) => void;
	bReportDesignerWorkflowMode?: boolean     ;
}

interface IQueryDesignerState
{
	oReportDesign              : ReportDesign;
	nSelectedField             : number      ;
	sSelectedFieldMode         : string      ;
	nSelectedRelationship      : number      ;
	sSelectedRelationshipMode  : string      ;
	nSelectedFilter            : number      ;
	sSelectedFilterMode        : string      ;
	sSelectedFilterValueType   : string      ;
	showJoinFields             : boolean     ;
	nSelectedJoin              : number      ;
	sSelectedJoinMode          : string      ;
	AGGREGATE_TYPE_LIST        : any[]       ;
	SORT_DIRECTION_LIST        : any[]       ;
	JOIN_TYPE_LIST             : any[]       ;
	OPERATOR_TYPE_LIST         : any[]       ;
	VALUE_LIST                 : any[]       ;
	VALUE_ADDED                : string      ;
	oPreviewSQL                : any         ;
	// 07/04/2016 Paul.  Special case when not showing selected fields. 
	error?                     : any         ;
}

export default class QueryDesigner extends React.Component<IQueryDesignerProps, IQueryDesignerState>
{
	private designerModules: ReportDesignerModules = null;
	private bDebug: boolean = false;

	public validate(): boolean
	{
		const { oReportDesign } = this.state;
		let bValid: boolean = true;
		let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
		if ( oReportDesign.SelectedFields.length == 0 )
		{
			bValid = false;
			this.setState({ error: L10n.Term('Reports.LBL_DISPLAY_COLUMNS_REQUIRED') });
		}
		else if ( oReportDesign.Tables.length == 0 )
		{
			bValid = false;
			this.setState({ error: L10n.Term('Reports.LBL_SELECT_TABLE') });
		}
		else if ( !Sql.IsEmptyString(oPreviewSQL.sErrors) )
		{
			bValid = false;
			this.setState({ error: oPreviewSQL.sErrors });
		}
		return bValid;
	}

	public error(): any
	{
		return this.state.error;
	}

	constructor(props: IQueryDesignerProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		this.bDebug          = Crm_Config.ToBoolean('show_sql');
		this.designerModules = new ReportDesignerModules();
		let error        : any          = 'Loading modules.';
		let oReportDesign: ReportDesign = new ReportDesign(this.designerModules);
		let AGGREGATE_TYPE_LIST: any[] = [];
		let SORT_DIRECTION_LIST: any[] = [];
		let JOIN_TYPE_LIST     : any[] = [];
		let OPERATOR_TYPE_LIST : any[] = [];
		let arrAGGREGATE_TYPE: string[] = L10n.GetList('report_aggregate_type_dom')
		for ( let i: number = 0; i < arrAGGREGATE_TYPE.length; i++ )
		{
			AGGREGATE_TYPE_LIST.push({ DISPLAY_NAME: L10n.ListTerm('report_aggregate_type_dom', arrAGGREGATE_TYPE[i]), NAME: arrAGGREGATE_TYPE[i] });
		}
		let arrSORT_DIRECTION: string[] = L10n.GetList('report_sort_direction_dom')
		for ( let i: number = 0; i < arrSORT_DIRECTION.length; i++ )
		{
			SORT_DIRECTION_LIST.push({ DISPLAY_NAME: L10n.ListTerm('report_sort_direction_dom', arrSORT_DIRECTION[i]), NAME: arrSORT_DIRECTION[i] });
		}
		let arrJOIN_TYPE_LIST: string[] = L10n.GetList('report_join_type_dom');
		for ( let i: number = 0; i < arrJOIN_TYPE_LIST.length; i++ )
		{
			JOIN_TYPE_LIST.push({ DISPLAY_NAME: L10n.ListTerm('report_join_type_dom', arrJOIN_TYPE_LIST[i]), NAME: arrJOIN_TYPE_LIST[i] });
		}
		OPERATOR_TYPE_LIST.push({ DISPLAY_NAME: '=', NAME: '=' });
		this.state =
		{
			oReportDesign              ,
			nSelectedField             : -1,
			sSelectedFieldMode         : null,
			nSelectedRelationship      : -1,
			sSelectedRelationshipMode  : null,
			nSelectedFilter            : -1,
			sSelectedFilterMode        : null,
			sSelectedFilterValueType   : null,
			showJoinFields             : false,
			nSelectedJoin              : -1,
			sSelectedJoinMode          : null,
			AGGREGATE_TYPE_LIST        ,
			SORT_DIRECTION_LIST        ,
			JOIN_TYPE_LIST             ,
			OPERATOR_TYPE_LIST         ,
			VALUE_LIST                 : [],
			VALUE_ADDED                : '',
			oPreviewSQL                : null,
			error                      ,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	// As soon as the render method has been executed the componentDidMount function is called. 
	async componentDidMount()
	{
		let { oReportDesign } = this.state;
		try
		{
			let oPreviewSQL: any = null;
			await this.designerModules.load();
			if ( this.props.row[this.props.DATA_FIELD] )
			{
				oReportDesign.Parse(this.props.row[this.props.DATA_FIELD]);
				oPreviewSQL = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount ' + this.props.DATA_FIELD, oPreviewSQL);
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', this.designerModules);
			this.setState({ oReportDesign, oPreviewSQL, error: null });
			if ( oPreviewSQL && !Sql.IsEmptyString(oPreviewSQL.sJSON) )
			{
				this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	private tSelectedFields_SelectedDelete = (e): void =>
	{
		let { oReportDesign, nSelectedField } = this.state;
		e.preventDefault();
		if ( nSelectedField >= 0 )
		{
			oReportDesign.SelectedField_Delete(nSelectedField);
			nSelectedField--;
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, nSelectedField, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private tSelectedFields_SelectedMoveUp = (e): void =>
	{
		let { oReportDesign, nSelectedField } = this.state;
		e.preventDefault();
		if ( nSelectedField > 0 )
		{
			oReportDesign.SelectedField_MoveUp(nSelectedField);
			nSelectedField--;
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, nSelectedField, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private tSelectedFields_SelectedMoveDown = (e): void =>
	{
		let { oReportDesign, nSelectedField } = this.state;
		e.preventDefault();
		if ( nSelectedField >= 0 && nSelectedField < oReportDesign.SelectedFields.length - 1)
		{
			oReportDesign.SelectedField_MoveDown(nSelectedField);
			nSelectedField++;
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, nSelectedField, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private tRelationships_AddRelationship = (e): void =>
	{
		let { oReportDesign } = this.state;
		e.preventDefault();
		oReportDesign.Relationships_AddRelationship();
		let nSelectedRelationship: number = oReportDesign.Relationships.length - 1;
		let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
		this.setState({ oReportDesign, nSelectedRelationship, oPreviewSQL });
		this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
	}

	private tRelationships_SelectedDelete = (e): void =>
	{
		let { oReportDesign, nSelectedRelationship } = this.state;
		e.preventDefault();
		if ( nSelectedRelationship >= 0 )
		{
			oReportDesign.Relationships_Delete(nSelectedRelationship);
			nSelectedRelationship--;
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, nSelectedRelationship, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private tRelationships_SelectedMoveUp = (e): void =>
	{
		let { oReportDesign, nSelectedRelationship } = this.state;
		e.preventDefault();
		if ( nSelectedRelationship > 0 )
		{
			oReportDesign.Relationships_MoveUp(nSelectedRelationship);
			nSelectedRelationship--;
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, nSelectedRelationship, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private tRelationships_SelectedMoveDown = (e): void =>
	{
		let { oReportDesign, nSelectedRelationship } = this.state;
		e.preventDefault();
		if ( nSelectedRelationship >= 0 && nSelectedRelationship < oReportDesign.Relationships.length - 1)
		{
			oReportDesign.Relationships_MoveDown(nSelectedRelationship);
			nSelectedRelationship++;
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, nSelectedRelationship, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private tJoinFields_AddJoinField = (e): void =>
	{
		let { oReportDesign, nSelectedRelationship } = this.state;
		e.preventDefault();
		oReportDesign.Relationships_JoinField_AddJoinField(nSelectedRelationship);
		let nSelectedJoin: number = oReportDesign.Relationships[nSelectedRelationship].JoinFields.length - 1;
		let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
		this.setState({ oReportDesign, nSelectedJoin, oPreviewSQL });
		this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
	}

	private tJoinFields_SelectedDelete = (e): void =>
	{
		let { oReportDesign, nSelectedRelationship, nSelectedJoin } = this.state;
		e.preventDefault();
		if ( nSelectedJoin >= 0 )
		{
			oReportDesign.Relationships_JoinField_Delete(nSelectedRelationship, nSelectedJoin);
			nSelectedJoin--;
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, nSelectedJoin, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private tJoinFields_SelectedMoveUp = (e): void =>
	{
		let { oReportDesign, nSelectedRelationship, nSelectedJoin } = this.state;
		e.preventDefault();
		if ( nSelectedJoin > 0 )
		{
			oReportDesign.Relationships_JoinField_MoveUp(nSelectedRelationship, nSelectedJoin);
			nSelectedJoin--;
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, nSelectedJoin, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private tJoinFields_SelectedMoveDown = (e): void =>
	{
		let { oReportDesign, nSelectedRelationship, nSelectedJoin } = this.state;
		e.preventDefault();
		if ( nSelectedJoin >= 0 && nSelectedJoin < oReportDesign.AppliedFilters.length - 1 )
		{
			oReportDesign.Relationships_JoinField_MoveDown(nSelectedRelationship, nSelectedJoin);
			nSelectedJoin++;
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, nSelectedJoin, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private tAppliedFilters_AddFilter = (e): void =>
	{
		let { oReportDesign } = this.state;
		e.preventDefault();
		oReportDesign.AppliedFilters_AddFilter();
		let nSelectedFilter: number = oReportDesign.AppliedFilters.length - 1;
		let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
		this.setState({ oReportDesign, nSelectedFilter, oPreviewSQL });
		this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
	}

	private tAppliedFilters_SelectedDelete = (e): void =>
	{
		let { oReportDesign, nSelectedFilter } = this.state;
		e.preventDefault();
		if ( nSelectedFilter >= 0 )
		{
			oReportDesign.AppliedFilters_Delete(nSelectedFilter);
			nSelectedFilter--;
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, nSelectedFilter, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private tAppliedFilters_SelectedMoveUp = (e): void =>
	{
		let { oReportDesign, nSelectedFilter } = this.state;
		e.preventDefault();
		if ( nSelectedFilter > 0 )
		{
			oReportDesign.AppliedFilters_MoveUp(nSelectedFilter);
			nSelectedFilter--;
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, nSelectedFilter, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private tAppliedFilters_SelectedMoveDown = (e): void =>
	{
		let { oReportDesign, nSelectedFilter } = this.state;
		e.preventDefault();
		if ( nSelectedFilter >= 0 && nSelectedFilter < oReportDesign.AppliedFilters.length - 1 )
		{
			oReportDesign.AppliedFilters_MoveDown(nSelectedFilter);
			nSelectedFilter++;
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, nSelectedFilter, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private tAppliedFilters_ChangeFilterParameter = (filter: ReportFilter, checked: boolean): void =>
	{
		let { oReportDesign } = this.state;
		filter.Parameter = checked;
		let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
		this.setState({ oReportDesign, oPreviewSQL });
		this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
	}

	private _onClickTable = async (module: ReportModule, add: boolean) =>
	{
		const { bReportDesignerWorkflowMode } = this.props;
		let { oReportDesign } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onClickTable', module);
		if ( add )
		{
			oReportDesign.Tables_AddTable(module);
			// 09/09/2021 Paul.  Add all fields. 
			if ( Sql.ToBoolean(bReportDesignerWorkflowMode) )
			{
				for ( let i: number = 0; i < module.Fields.length; i++ )
				{
					let field: ModuleField = module.Fields[i];
					if ( field.ColumnName == 'ID' )
					{
						oReportDesign.SelectedField_AddField(field);
						break;
					}
				}
			}
			else
			{
				for ( let i: number = 0; i < module.Fields.length; i++ )
				{
					let field: ModuleField = module.Fields[i];
					oReportDesign.SelectedField_AddField(field);
				}
			}
		}
		else
		{
			oReportDesign.Tables_RemoveTable(module.TableName);
			// 09/09/2021 Paul.  Add remove fields. 
			if ( !Sql.ToBoolean(bReportDesignerWorkflowMode) )
			{
				for ( let i: number = 0; i < module.Fields.length; i++ )
				{
					let field: ModuleField = module.Fields[i];
					oReportDesign.SelectedField_RemoveField(field.TableName + '.' + field.ColumnName);
				}
			}
		}
		let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
		this.setState({ oReportDesign, oPreviewSQL });
		this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
	}

	private _onClickField = async (field: ModuleField, add: boolean) =>
	{
		let { oReportDesign } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onClickField', field);
		if ( add )
			oReportDesign.SelectedField_AddField(field);
		else
			oReportDesign.SelectedField_RemoveField(field.TableName + '.' + field.ColumnName);
		let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
		this.setState({ oReportDesign, oPreviewSQL });
		this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
	}

	private isTableChecked = (table: ReportModule): boolean =>
	{
		const { bReportDesignerWorkflowMode } = this.props;
		let { oReportDesign } = this.state;
		if ( Sql.ToBoolean(bReportDesignerWorkflowMode) )
		{
			if ( oReportDesign && oReportDesign.Tables )
			{
				for ( let i: number = 0; i < oReportDesign.Tables.length; i++ )
				{
					if ( oReportDesign.Tables[i].ModuleName == table.ModuleName )
					{
						return true;
					}
				}
			}
			return false;
		}
		else
		{
			let nTableFieldsSelected: number = 0;
			if ( oReportDesign && oReportDesign.SelectedFields )
			{
				for ( let i: number = 0; i < oReportDesign.SelectedFields.length; i++ )
				{
					let selectedField: ReportField = oReportDesign.SelectedFields[i];
					if ( table.TableName == selectedField.TableName )
					{
						nTableFieldsSelected++;
					}
				}
			}
			return nTableFieldsSelected > 0 && nTableFieldsSelected == table.Fields.length;
		}
	}
	
	private isFieldChecked = (field: ModuleField): boolean =>
	{
		let { oReportDesign } = this.state;
		if ( oReportDesign && oReportDesign.SelectedFields )
		{
			for ( let i: number = 0; i < oReportDesign.SelectedFields.length; i++ )
			{
				let selectedField: ReportField = oReportDesign.SelectedFields[i];
				if ( field.TableName == selectedField.TableName && field.ColumnName == selectedField.ColumnName )
				{
					return true;
				}
			}
		}
		return false;
	}
	
	private renderTableFields = (table) =>
	{
		const { bReportDesignerWorkflowMode } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.renderTableFields', table);
		// 10/21/2020 Paul.  Some themes look too tightly packed with the scaling. 
		let styCheckbox = { transform: 'scale(1.5)', display: 'inline', marginTop: '2px', marginBottom: '6px' };
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		if ( Crm_Config.ToBoolean('enable_legacy_icons') )
		{
			styCheckbox.transform = 'scale(1.0)';
			styCheckbox.marginBottom = '2px';
		}
		return !Sql.ToBoolean(bReportDesignerWorkflowMode) && table.Fields && table.Fields.map(field =>
		{
			let isFieldChecked: boolean = this.isFieldChecked(field);
			return (
			<div className='tree-view_item' style={ {paddingLeft: '22px', whiteSpace: 'nowrap'} }>
				<span className='reportTreeItem'>
					<input type='checkbox' className='checkbox' style={ styCheckbox } checked={ isFieldChecked } onChange={ (e) => this._onClickField(field, e.target.checked) } />
					<span style={ {cursor: 'pointer'} } onClick={ (e) => this._onClickField(field, !isFieldChecked) }>
						<FontAwesomeIcon icon={ {prefix: 'fas', iconName: 'file'} } style={ {fontSize: '18px', padding: '2px'} } color='#C3E1FF' />
						{ field.DisplayName + (this.bDebug ? ' (' + field.TableName + '.' + field.ColumnName + ')' : '') }
					</span>
				</span>
			</div>);
		});
	}

	private JoinFieldsDisplayText = (relationship: ReportRelationship) =>
	{
		let arr = [];
		if ( relationship.JoinFields != null && relationship.JoinFields.length > 0 )
		{
			for ( let i: number = 0; i < relationship.JoinFields.length; i++ )
			{
				let oJoinField = relationship.JoinFields[i];
				if ( arr.length > 0 )
				{
					arr.push('<br />');
					arr.push('&nbsp;');
					arr.push('and'   );
					arr.push('&nbsp;');
				}
				let sJoinFields: string = '';
				if ( oJoinField.LeftField == null || oJoinField.RightField == null )
				{
					sJoinFields = L10n.Term('ReportDesigner.LBL_MISSING_JOIN_FIELD');
					sJoinFields += ' ' + L10n.Term('ReportDesigner.LBL_EDIT_INSTRUCTIONS');
				}
				else if ( this.bDebug )
				{
					if ( oJoinField.LeftField != null )
						sJoinFields += oJoinField.LeftField.DisplayName + ' (' + oJoinField.LeftField.FieldName + ')';
					sJoinFields += ' ' + oJoinField.OperatorType + ' ';
					if ( oJoinField.RightField != null )
						sJoinFields += oJoinField.RightField.DisplayName + ' (' + oJoinField.RightField.FieldName + ')';
				}
				else
				{
					if ( oJoinField.LeftField != null )
						sJoinFields += oJoinField.LeftField.DisplayName;
					sJoinFields += ' ' + oJoinField.OperatorType + ' ';
					if ( oJoinField.RightField != null )
						sJoinFields += oJoinField.RightField.DisplayName;
				}
				arr.push(<span onClick={ this._onShowJoinFields } style={ {cursor: 'pointer'} }>{ sJoinFields }</span>);
			}
		}
		else
		{
			if ( Sql.IsEmptyString(relationship.LeftTable) || Sql.IsEmptyString(relationship.RightTable) )
			{
				arr.push(L10n.Term('ReportDesigner.LBL_MISSING_JOIN_TABLE'));
			}
			else
			{
				let sJoinFields: string = L10n.Term('ReportDesigner.LBL_EDIT_INSTRUCTIONS');
				arr.push(<span onClick={ this._onShowJoinFields } style={ {cursor: 'pointer'} }>{ sJoinFields }</span>);
			}
		}
		return arr;
	}

	private _onShowJoinFields = (e) =>
	{
		const { oReportDesign, nSelectedRelationship } = this.state;
		e.stopPropagation();
		let relationship: ReportRelationship = oReportDesign.Relationships_GetAt(nSelectedRelationship);
		if ( relationship != null )
		{
			if ( relationship.JoinFields.length == 0 )
			{
				oReportDesign.Relationships_JoinField_AddJoinField(nSelectedRelationship);
			}
		}
		this.setState({ oReportDesign, sSelectedRelationshipMode: 'JoinFields', showJoinFields: true, nSelectedJoin: -1, sSelectedJoinMode: null });
	}

	private _onCloseJoinFields = () =>
	{
		let { oReportDesign } = this.state;
		let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
		this.setState({ oReportDesign, showJoinFields: false, nSelectedJoin: -1, sSelectedJoinMode: null, oPreviewSQL });
		this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
	}

	private chkGroupAndAggregate_Clicked = (e): void =>
	{
		let { oReportDesign } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.chkGroupAndAggregate_Clicked');
		oReportDesign.GroupAndAggregate = e.target.checked;
		for ( let i: number = 0; i < oReportDesign.SelectedFields.length; i++ )
		{
			let field: ReportField = oReportDesign.SelectedFields[i];
			field.AggregateType = (oReportDesign.GroupAndAggregate ? 'group by' : null);
		}
		let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
		this.setState({ oReportDesign, oPreviewSQL });
		this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
	}

	private _onAGGREGATE_TYPE_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let { oReportDesign, nSelectedField } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSORT_DIRECTION_Change', event.target.value);
		let field: ReportField = oReportDesign.SelectedField_GetAt(nSelectedField);
		if ( field != null )
		{
			field.AggregateType = event.target.value; 
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, sSelectedFieldMode: null, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private _onSORT_DIRECTION_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let { oReportDesign, nSelectedField } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSORT_DIRECTION_Change', event.target.value);
		let field: ReportField = oReportDesign.SelectedField_GetAt(nSelectedField);
		if ( field != null )
		{
			field.SortDirection = event.target.value; 
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, sSelectedFieldMode: null, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private _onDISPLAY_NAME_Change = (e) =>
	{
		let { oReportDesign, nSelectedField } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDISPLAY_NAME_Change', event.target.value);
		let field: ReportField = oReportDesign.SelectedField_GetAt(nSelectedField);
		if ( field != null )
		{
			field.DisplayName = e.target.value; 
			//let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign });
			//this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private _onDISPLAY_WIDTH_Change = (e) =>
	{
		let { oReportDesign, nSelectedField } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDISPLAY_NAME_Change', event.target.value);
		let field: ReportField = oReportDesign.SelectedField_GetAt(nSelectedField);
		if ( field != null )
		{
			field.DisplayWidth = e.target.value; 
			//let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign });
			//this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private _onJOIN_TYPE_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let { oReportDesign, nSelectedRelationship } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onJOIN_TYPE_Change', event.target.value);
		let relationship: ReportRelationship = oReportDesign.Relationships_GetAt(nSelectedRelationship);
		if ( relationship != null )
		{
			relationship.JoinType = event.target.value; 
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, sSelectedRelationshipMode: null, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private _onOPERATOR_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let { oReportDesign, nSelectedFilter } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onOPERATOR_Change', event.target.value);
		let filter: ReportFilter = oReportDesign.AppliedFilters_GetAt(nSelectedFilter);
		if ( filter != null )
		{
			if ( filter.Operator != event.target.value )
				filter.Value = null;
			filter.Operator = event.target.value;
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, sSelectedFilterMode: null, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private _onSelectedField_Edit = (index: number, mode: string) =>
	{
		const { oReportDesign, nSelectedField, sSelectedFieldMode } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectedField_Edit', mode);
		if ( oReportDesign.GroupAndAggregate || mode != 'AggregateType' )
		{
			if ( index != nSelectedField || sSelectedFieldMode != mode )
			{
				this.setState({ nSelectedField: index, sSelectedFieldMode: mode });
			}
			// 03/31/2020 Paul.  Turn off editing if currently editing. 
			else if ( index == nSelectedField && sSelectedFieldMode == mode )
			{
				this.setState({ sSelectedFieldMode: null });
			}
		}
	}

	private _onSelectedRelationship_Edit = (index: number, mode: string) =>
	{
		const { oReportDesign, nSelectedRelationship, sSelectedRelationshipMode } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectedRelationship_Edit', mode);
		if ( index != nSelectedRelationship || sSelectedRelationshipMode != mode )
		{
			this.setState({ nSelectedRelationship: index, sSelectedRelationshipMode: mode });
		}
		// 03/31/2020 Paul.  Turn off editing if currently editing. 
		else if ( index == nSelectedRelationship && sSelectedRelationshipMode == mode )
		{
			this.setState({ sSelectedRelationshipMode: null });
		}
	}

	private _onSelectedFilter_Edit = (index: number, mode: string) =>
	{
		const { oReportDesign, nSelectedFilter, sSelectedFilterMode } = this.state;
		let filter: ReportFilter = oReportDesign.AppliedFilters_GetAt(index);
		if ( mode == 'Operator' )
		{
			// 04/08/2020 Paul.  If the list value is empty, set to the top item. 
			if ( Sql.IsEmptyString(filter.Operator) )
			{
				let sListName: string = this.getOperatorListName(filter);
				let arrOPERATOR_LIST: string[] = L10n.GetList(sListName);
				oReportDesign.AppliedFilters[index].Operator = arrOPERATOR_LIST[0];
			}
		}
		if ( index != nSelectedFilter || sSelectedFilterMode != mode )
		{
			let VALUE_LIST : any[] = [];
			let VALUE_ADDED: string = '';
			let sSelectedFilterValueType: string = (mode == 'Value' ? this.filterValueType(oReportDesign.AppliedFilters[index]) : null);
			if ( sSelectedFilterValueType == 'ListBox' )
			{
				let lay: EDITVIEWS_FIELD = ReportDesign_EditView_Layout(filter.Field.Module.ModuleName, filter.Field.ColumnName);
				if ( lay != null )
				{
					let sListName: string = lay.LIST_NAME;
					if ( !Sql.IsEmptyString(sListName) )
					{
						let arrVALUE_LIST: string[] = L10n.GetList(sListName)
						for ( let i: number = 0; i < arrVALUE_LIST.length; i++ )
						{
							VALUE_LIST.push({ DISPLAY_NAME: L10n.ListTerm(sListName, arrVALUE_LIST[i]), NAME: arrVALUE_LIST[i] });
						}
					}
					else
					{
						sSelectedFilterValueType = 'ListCreate';
					}
				}
				else
				{
					sSelectedFilterValueType = 'ListCreate';
				}
				if ( sSelectedFilterValueType == 'ListCreate' )
				{
					if ( Array.isArray(filter.Value) )
					{
						for ( let i: number = 0; i < filter.Value.length; i++ )
						{
							VALUE_LIST.push({ DISPLAY_NAME: filter.Value[i], NAME: filter.Value[i] });
						}
					}
				}
			}
			this.setState({ nSelectedFilter: index, sSelectedFilterMode: mode, sSelectedFilterValueType, VALUE_LIST, VALUE_ADDED });
		}
		// 03/31/2020 Paul.  Turn off editing if currently editing. 
		else if ( index == nSelectedFilter && sSelectedFilterMode == mode )
		{
			this.setState({ sSelectedFilterMode: null });
		}
	}

	private _onSelectedJoinField_Edit = (index: number, mode: string) =>
	{
		const { oReportDesign, nSelectedRelationship, nSelectedJoin, sSelectedJoinMode } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectedJoinField_Edit', mode);
		if ( index != nSelectedJoin || sSelectedJoinMode != mode )
		{
			if ( mode == 'LeftField' )
			{
				// 04/08/2020 Paul.  If the list value is empty, set to the top item. 
				if ( oReportDesign.Relationships[nSelectedRelationship].JoinFields[index].LeftField == null )
				{
					let arrFields: ModuleField[] = this.designerModules.FindModuleByTable(oReportDesign.Relationships[nSelectedRelationship].LeftTable.TableName).Fields;
					oReportDesign.Relationships[nSelectedRelationship].JoinFields[index].LeftField= new ReportField(arrFields[0]);
				}
			}
			else if ( mode == 'RightField' )
			{
				// 04/08/2020 Paul.  If the list value is empty, set to the top item. 
				if ( oReportDesign.Relationships[nSelectedRelationship].JoinFields[index].RightField == null )
				{
					let arrFields: ModuleField[] = this.designerModules.FindModuleByTable(oReportDesign.Relationships[nSelectedRelationship].RightTable.TableName).Fields;
					oReportDesign.Relationships[nSelectedRelationship].JoinFields[index].RightField= new ReportField(arrFields[0]);
				}
			}
			this.setState({ oReportDesign, nSelectedJoin: index, sSelectedJoinMode: mode });
		}
		// 03/31/2020 Paul.  Turn off editing if currently editing. 
		else if ( index == nSelectedJoin && sSelectedJoinMode == mode )
		{
			this.setState({ sSelectedJoinMode: null });
		}
	}

	private _onInputClick = (e) =>
	{
		// 03/31/2020 Paul.  We want to prevent _onSelectedField_Edit from disabling edit. 
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onInputClick', e);
		e.stopPropagation();
	}

	private _onKeyDown = (event) =>
	{
		const { oReportDesign } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onKeyDown', event, event.key);
		if ( event.key == 'Enter' || event.key == 'Escape' )
		{
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, sSelectedFieldMode: null, sSelectedFilterMode: null, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private getOperatorListName = (filter: ReportFilter) =>
	{
		let sListName: string = 'report_filter_operator_dom';
		if ( this.props.bReportDesignerWorkflowMode )
		{
			if ( filter.Field != null && filter.Field.DataType != null )
			{
				sListName = filter.CsType() + '_operator_dom';
			}
		}
		return sListName;
	}

	private getOperatorList = (filter: ReportFilter) =>
	{
		let OPERATOR_LIST: any[] = [];
		let sListName: string = this.getOperatorListName(filter);
		// 04/08/2020 Paul.  We are blocking the selection of the first item, so make the first item blank. 
		let arrOPERATOR_LIST: string[] = L10n.GetList(sListName);
		for ( let index: number = 0; index < arrOPERATOR_LIST.length; index++ )
		{
			let item: string = arrOPERATOR_LIST[index];
			OPERATOR_LIST.push(<option key={ 'ctlReportDesigner_OPERATOR_' + index.toString() } id={ 'ctlReportDesigner_OPERATOR_' + index.toString() } value={ item }>{ L10n.ListTerm(sListName, item) }</option>);
		}
		return OPERATOR_LIST;
	}

	private selectRelationshipTable = (table: ReportTable) =>
	{
		let { oReportDesign, nSelectedRelationship, sSelectedRelationshipMode } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.selectRelationshipTable', table);
		let relationship: ReportRelationship = oReportDesign.Relationships_GetAt(nSelectedRelationship);
		if ( relationship != null )
		{
			if ( sSelectedRelationshipMode == 'LeftTable' )
				relationship.LeftTable = table;
			else
				relationship.RightTable = table;
			oReportDesign.Tables_UpdateAll();
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, sSelectedRelationshipMode: null, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private relationshipTableSelection = (relationship: ReportRelationship) =>
	{
		const { oReportDesign, sSelectedRelationshipMode } = this.state;
		let reportTable: ReportTable = (sSelectedRelationshipMode == 'LeftTable' ? relationship.LeftTable : relationship.RightTable);
		let sTableName : string      = (reportTable ? reportTable.TableName : null);
		// 04/09/2020 Paul.  Stop Propagation to prevent from closing. 
		return (<div style={ {padding: '6px', backgroundColor: 'white', color: 'black', whiteSpace: 'nowrap'} } onClick={ (e) => e.stopPropagation() }>
			<TreeView nodeLabel={ L10n.Term('ReportDesigner.LBL_TABLES_IN_QUERY') } defaultCollapsed={ false } itemClassName='reportTreeItem'>
				{ oReportDesign.Tables.map((table, index) =>
					{
						let sNAME: string = table.DisplayName + (this.bDebug ? ' (' + table.TableName + ')' : '');
						return (<div
							className={ sTableName == table.TableName ? 'ReportDesignerTable ReportDesignerTableSelected' : 'ReportDesignerTable' }
							style={ {fontSize: '12px', lineHeight: '16px', fontFamily: 'Verdana, Arial, Helvetica, AppleGothic, sans-serif', cursor: 'pointer'} }
							onClick={ (e) => this.selectRelationshipTable(table) }
							>
							<FontAwesomeIcon icon={ {prefix: 'fas', iconName: 'file'} } style={ {fontSize: '18px', padding: '2px'} } color='#C3E1FF' />
							{ sNAME }
						</div>);
					})
				}
			</TreeView>
			<TreeView nodeLabel={ L10n.Term('ReportDesigner.LBL_TABLES') } defaultCollapsed={ true } itemClassName='reportTreeItem'>
				{ this.designerModules.arrReportDesignerModules.map((table, index) =>
					{
						let sNAME: string = table.DisplayName + (this.bDebug ? ' (' + table.TableName + ')' : '');
						return (<div
							className='ReportDesignerTable'
							onClick={ (e) => this.selectRelationshipTable(new ReportTable(table)) }
							>
							<FontAwesomeIcon icon={ {prefix: 'fas', iconName: 'file'} } style={ {fontSize: '18px', padding: '2px'} } color='#C3E1FF' />
							{ sNAME }
						</div>);
					})
				}
			</TreeView>
		</div>);
	}

	private _onOPERATOR_TYPE_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let { oReportDesign, nSelectedRelationship, nSelectedJoin } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onOPERATOR_TYPE_Change', event.target.value);
		let join: ReportJoinField = oReportDesign.Relationships_JoinField_GetAt(nSelectedRelationship, nSelectedJoin);
		if ( join != null )
		{
			join.OperatorType = event.target.value; 
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, sSelectedJoinMode: null, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private _onLEFT_JOIN_FIELD_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let { oReportDesign, nSelectedRelationship, nSelectedJoin } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onLEFT_JOIN_FIELD_Change', event.target.value);
		let join: ReportJoinField = oReportDesign.Relationships_JoinField_GetAt(nSelectedRelationship, nSelectedJoin);
		if ( join != null )
		{
			let field: ModuleField = this.designerModules.FindFieldByTable(oReportDesign.Relationships[nSelectedRelationship].LeftTable.TableName, event.target.value)
			if ( field )
			{
				join.LeftField = new ReportField(field);
				let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
				this.setState({ oReportDesign, sSelectedJoinMode: null, oPreviewSQL });
				this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
			}
		}
	}

	private _onRIGHT_JOIN_FIELD_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let { oReportDesign, nSelectedRelationship, nSelectedJoin } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRIGHT_JOIN_FIELD_Change', event.target.value);
		let join: ReportJoinField = oReportDesign.Relationships_JoinField_GetAt(nSelectedRelationship, nSelectedJoin);
		if ( join != null )
		{
			let field: ModuleField = this.designerModules.FindFieldByTable(oReportDesign.Relationships[nSelectedRelationship].RightTable.TableName, event.target.value)
			if ( field )
			{
				join.RightField = new ReportField(field);
				let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
				this.setState({ oReportDesign, sSelectedJoinMode: null, oPreviewSQL });
				this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
			}
		}
	}

	private selectFilterField = (field: ModuleField) =>
	{
		let { oReportDesign, nSelectedFilter } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.selectFilterField', field);
		let filter: ReportFilter = oReportDesign.AppliedFilters_GetAt(nSelectedFilter);
		if ( filter != null )
		{
			filter.Field = field;
			let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign, sSelectedFilterMode: null, oPreviewSQL });
			this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private filterFieldSelection = (filter: ReportFilter) =>
	{
		const { oReportDesign } = this.state;
		// 04/09/2020 Paul.  Stop Propagation to prevent from closing. 
		return (<div style={ {padding: '6px', backgroundColor: 'white', color: 'black', whiteSpace: 'nowrap'} } onClick={ (e) => e.stopPropagation() }>
			<TreeView nodeLabel={ L10n.Term('ReportDesigner.LBL_TABLES_IN_QUERY') } defaultCollapsed={ false } itemClassName='reportTreeItem'>
				{ oReportDesign.Tables.map((table, index) =>
					{
						let sNAME: string = table.DisplayName + (this.bDebug ? ' (' + table.TableName + ')' : '');
						const label = 
						<span className='reportTreeItem'>
							<FontAwesomeIcon icon={ {prefix: 'fas', iconName: 'folder'} } style={ {fontSize: '18px', padding: '2px'} } color='#F2DF7D' />
							{ sNAME }
						</span>;
						let module: ReportModule = this.designerModules.FindModuleByName(table.ModuleName);
						return (module && <TreeView nodeLabel={ label } key={ module.TableName } defaultCollapsed={ !((index == 0 && filter.Field == null) || (filter.Field && filter.Field.TableName == module.TableName)) } itemClassName='reportTreeItem'>
							{ module.Fields
							? module.Fields.map(field =>
							{
								return (
								<div className='tree-view_item' style={ {paddingLeft: '22px', whiteSpace: 'nowrap'} }>
									<span
										className={ filter.Field && filter.Field.TableName == module.TableName && filter.Field.ColumnName == field.ColumnName ? 'ReportDesignerTable ReportDesignerTableSelected' : 'ReportDesignerTable' }
										style={ {fontSize: '12px', lineHeight: '16px', fontFamily: 'Verdana, Arial, Helvetica, AppleGothic, sans-serif', cursor: 'pointer'} }
										onClick={ (e) => this.selectFilterField(field) }
										>
										<FontAwesomeIcon icon={ {prefix: 'fas', iconName: 'file'} } style={ {fontSize: '18px', padding: '2px'} } color='#C3E1FF' />
										{ field.DisplayName + (this.bDebug ? ' (' + field.TableName + '.' + field.ColumnName + ')' : '') }
									</span>
								</div>);
							})
							: null
							}
						</TreeView>);
					})
				}
			</TreeView>
		</div>);
	}

	private filterValueDisplay = (filter: ReportFilter) =>
	{
		const { oReportDesign } = this.state;
		return (filter.Value ? (Array.isArray(filter.Value) ? filter.Value.join() : filter.Value) : null)
	}

	private filterValueType = (oReportFilter: ReportFilter) =>
	{
		let sValueType: string = null;
		if ( oReportFilter != null )
		{
			let bPopup  : boolean = false;
			let bTextBox: boolean = false;
			let bListBox: boolean = false;
			// 02/11/2018 Paul.  Workflow mode uses older style of operators. 
			if ( this.props.bReportDesignerWorkflowMode )
			{
				let sCOMMON_DATA_TYPE = (oReportFilter.Field ? oReportFilter.Field.DataType.toLowerCase() : null);
				if ( sCOMMON_DATA_TYPE == "ansistring" )
					sCOMMON_DATA_TYPE = "string";
				// 02/11/2018 Paul.  We need to determine if the string should be treated as a enum. 
				if ( oReportFilter.IsEnum() )
				{
					sCOMMON_DATA_TYPE = "enum";
				}
				switch ( sCOMMON_DATA_TYPE )
				{
					case "string":
					{
						switch ( oReportFilter.Operator )
						{
							case "equals"        :  bTextBox = true ;  break;
							case "contains"      :  bTextBox = true ;  break;
							case "starts_with"   :  bTextBox = true ;  break;
							case "ends_with"     :  bTextBox = true ;  break;
							case "not_equals_str":  bTextBox = true ;  break;
							case "empty"         :  break;
							case "not_empty"     :  break;
							case "changed"       :  break;
							case "unchanged"     :  break;
							case "increased"     :  break;
							case "decreased"     :  break;
							// 08/25/2011 Paul.  A customer wants more use of NOT in string filters. 
							case "not_contains"   :  bTextBox = true ;  break;
							case "not_starts_with":  bTextBox = true ;  break;
							case "not_ends_with"  :  bTextBox = true ;  break;
							// 02/14/2013 Paul.  A customer wants to use like in string filters. 
							case "like"           :  bTextBox = true ;  break;
							case "not_like"       :  bTextBox = true ;  break;
							// 07/23/2013 Paul.  Add greater and less than conditions. 
							case "less"          :  bTextBox = true ;  break;
							case "less_equal"    :  bTextBox = true ;  break;
							case "greater"       :  bTextBox = true ;  break;
							case "greater_equal" :  bTextBox = true ;  break;
						}
						break;
					}
					case "datetime":
					{
						switch ( oReportFilter.Operator )
						{
							case "on"               :  bTextBox = true;  break;
							case "before"           :  bTextBox = true;  break;
							case "after"            :  bTextBox = true;  break;
							case "between_dates"    :  bTextBox = true;  break;
							case "not_equals_str"   :  bTextBox = true;  break;
							case "empty"            :  break;
							case "not_empty"        :  break;
							case "is_before"        :  break;
							case "is_after"         :  break;
							case "tp_yesterday"     :  break;
							case "tp_today"         :  break;
							case "tp_tomorrow"      :  break;
							case "tp_last_7_days"   :  break;
							case "tp_next_7_days"   :  break;
							case "tp_last_month"    :  break;
							case "tp_this_month"    :  break;
							case "tp_next_month"    :  break;
							case "tp_last_30_days"  :  break;
							case "tp_next_30_days"  :  break;
							case "tp_last_year"     :  break;
							case "tp_this_year"     :  break;
							case "tp_next_year"     :  break;
							case "changed"          :  break;
							case "unchanged"        :  break;
							case "increased"        :  break;
							case "decreased"        :  break;
							case "tp_minutes_after" :  bTextBox = true ;  break;
							case "tp_hours_after"   :  bTextBox = true ;  break;
							case "tp_days_after"    :  bTextBox = true ;  break;
							case "tp_weeks_after"   :  bTextBox = true ;  break;
							case "tp_months_after"  :  bTextBox = true ;  break;
							case "tp_years_after"   :  bTextBox = true ;  break;
							case "tp_minutes_before":  bTextBox = true ;  break;
							case "tp_hours_before"  :  bTextBox = true ;  break;
							case "tp_days_before"   :  bTextBox = true ;  break;
							case "tp_weeks_before"  :  bTextBox = true ;  break;
							case "tp_months_before" :  bTextBox = true ;  break;
							case "tp_years_before"  :  bTextBox = true ;  break;
							// 12/04/2008 Paul.  We need to be able to do an an equals. 
							case "tp_days_old"      :  bTextBox = true ;  break;
							case "tp_weeks_old"     :  bTextBox = true ;  break;
							case "tp_months_old"    :  bTextBox = true ;  break;
							case "tp_years_old"     :  bTextBox = true ;  break;
						}
						break;
					}
					case "int32":
					{
						switch ( oReportFilter.Operator )
						{
							case "equals"        :  bTextBox = true ;  break;
							case "less"          :  bTextBox = true ;  break;
							case "greater"       :  bTextBox = true ;  break;
							case "between"       :  bTextBox = true ;  break;
							case "not_equals"    :  bTextBox = true ;  break;
							case "empty"         :  break;
							case "not_empty"     :  break;
							case "changed"       :  break;
							case "unchanged"     :  break;
							case "increased"     :  break;
							case "decreased"     :  break;
							// 07/23/2013 Paul.  Add greater and less than conditions. 
							case "less_equal"    :  bTextBox = true ;  break;
							case "greater_equal" :  bTextBox = true ;  break;
						}
						break;
					}
					case "decimal":
					{
						switch ( oReportFilter.Operator )
						{
							case "equals"        :  bTextBox = true ;  break;
							case "less"          :  bTextBox = true ;  break;
							case "greater"       :  bTextBox = true ;  break;
							case "between"       :  bTextBox = true ;  break;
							case "not_equals"    :  bTextBox = true ;  break;
							case "empty"         :  break;
							case "not_empty"     :  break;
							case "changed"       :  break;
							case "unchanged"     :  break;
							case "increased"     :  break;
							case "decreased"     :  break;
							// 07/23/2013 Paul.  Add greater and less than conditions. 
							case "less_equal"    :  bTextBox = true ;  break;
							case "greater_equal" :  bTextBox = true ;  break;
						}
						break;
					}
					case "float":
					{
						switch ( oReportFilter.Operator )
						{
							case "equals"        :  bTextBox = true ;  break;
							case "less"          :  bTextBox = true ;  break;
							case "greater"       :  bTextBox = true ;  break;
							case "between"       :  bTextBox = true ;  break;
							case "not_equals"    :  bTextBox = true ;  break;
							case "empty"         :  break;
							case "not_empty"     :  break;
							case "changed"       :  break;
							case "unchanged"     :  break;
							case "increased"     :  break;
							case "decreased"     :  break;
							// 07/23/2013 Paul.  Add greater and less than conditions. 
							case "less_equal"    :  bTextBox = true ;  break;
							case "greater_equal" :  bTextBox = true ;  break;
						}
						break;
					}
					case "bool":
					{
						switch ( oReportFilter.Operator )
						{
							case "equals"    :  bTextBox = true ;  break;
							case "empty"     :  break;
							case "not_empty" :  break;
							case "changed"   :  break;
							case "unchanged" :  break;
							case "increased" :  break;
							case "decreased" :  break;
						}
						break;
					}
					case "guid":
					{
						switch ( oReportFilter.Operator )
						{
							// 05/05/2010 Paul.  The Select button was not being made visible. 
							case "is"            :  break;
							case "equals"        :  bTextBox = true ;  break;
							case "contains"      :  bTextBox = true ;  break;
							case "starts_with"   :  bTextBox = true ;  break;
							case "ends_with"     :  bTextBox = true ;  break;
							case "not_equals_str":  bTextBox = true ;  break;
							case "empty"         :  break;
							case "not_empty"     :  break;
							case "changed"       :  break;
							case "unchanged"     :  break;
							case "increased"     :  break;
							case "decreased"     :  break;
							case "one_of"        :  bListBox = true;  break;
						}
						break;
					}
					case "enum":
					{
						switch ( oReportFilter.Operator )
						{
							case "is"            :  bListBox = true;  break;
							case "one_of"        :  bListBox = true;  break;
							case "empty"         :  break;
							case "not_empty"     :  break;
							case "changed"       :  break;
							case "unchanged"     :  break;
							case "increased"     :  break;
							case "decreased"     :  break;
						}
						break;
					}
				}
			}
			else
			{
				switch ( oReportFilter.Operator )
				{
					case 'in'         :  bListBox = true ;  break;
					case 'not in'     :  bListBox = true ;  break;
					case 'is null'    :  bTextBox = false;  break;
					case 'is not null':  bTextBox = false;  break;
					// 07/17/2016 Paul.  Add support for changed to support workflow. 
					case 'changed'    :  bTextBox = false;  break;
					default           :  bTextBox = true ;  break;
				}
			}
			if ( bPopup )
				sValueType = 'Popup';
			else if ( bTextBox )
				sValueType = 'TextBox';
			else if ( bListBox )
				sValueType = 'ListBox';
		}
		// null, Popup, TextBox, ListBox are all valid types. 
		return sValueType;
	}

	private _onVALUE_TextChange = (e) =>
	{
		let { oReportDesign, nSelectedFilter } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onVALUE_TextChange', e.target.value);
		let filter: ReportFilter = oReportDesign.AppliedFilters_GetAt(nSelectedFilter);
		if ( filter != null )
		{
			filter.Value = e.target.value; 
			//let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign });
			//this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private _onVALUE_BetweenChange = (e: React.ChangeEvent<HTMLInputElement>, index: number) =>
	{
		let { oReportDesign, nSelectedFilter } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onVALUE_BetweenChange', e.target.value);
		let filter: ReportFilter = oReportDesign.AppliedFilters_GetAt(nSelectedFilter);
		if ( filter != null )
		{
			if ( filter.Value == null || !Array.isArray(filter.Value) )
				filter.Value = [];
			while ( filter.Value.length < 2 )
				filter.Value.push('');
			filter.Value[index] = e.target.value; 
			//let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign });
			//this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private _onVALUE_ModuleChange = (DATA_FIELD: string, DATA_VALUE: string, DISPLAY_FIELD: string, DISPLAY_VALUE: string, primary?: boolean ) =>
	{
		let { oReportDesign, nSelectedFilter } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onVALUE_ModuleChange', DATA_VALUE);
		let filter: ReportFilter = oReportDesign.AppliedFilters_GetAt(nSelectedFilter);
		if ( filter != null )
		{
			filter.Value = DATA_VALUE;
			//let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign });
			//this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private _onVALUE_ListChange = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let { oReportDesign, nSelectedFilter } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onVALUE_ListChange', event.target.selectedOptions);
		let filter: ReportFilter = oReportDesign.AppliedFilters_GetAt(nSelectedFilter);
		if ( filter != null )
		{
			filter.Value = [];
			let selectedOptions = event.target.selectedOptions;
			for (let i = 0; i < selectedOptions.length; i++)
			{
				filter.Value.push(selectedOptions[i].value);
			}
			//let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
			this.setState({ oReportDesign });
			//this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
		}
	}

	private _onFilterAddChanged = (e) =>
	{
		this.setState({ VALUE_ADDED: e.target.value });
	}

	private _onFilterAddValue = (e) =>
	{
		let { VALUE_LIST, VALUE_ADDED } = this.state;
		e.stopPropagation();
		VALUE_LIST.push({ DISPLAY_NAME: VALUE_ADDED, NAME: VALUE_ADDED });
		this.setState({ VALUE_LIST, VALUE_ADDED: '' });
	}

	private _onFilterValueDone = (e) =>
	{
		let { oReportDesign } = this.state;
		e.stopPropagation();
		let oPreviewSQL: any = oReportDesign.PreviewSQL(this.props.bReportDesignerWorkflowMode);
		this.setState({ oReportDesign, oPreviewSQL, sSelectedFilterMode: null });
		this.props.onChanged(this.props.DATA_FIELD, oPreviewSQL.sJSON, 'SQL', oPreviewSQL.sSQL);
	}

	private filterValueSelection = (oReportFilter: ReportFilter) =>
	{
		const { nSelectedFilter, sSelectedFilterValueType, VALUE_LIST, VALUE_ADDED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.filterValueSelection', sSelectedFilterValueType);
		if ( (oReportFilter.Operator == '=' || oReportFilter.Operator == 'is') && oReportFilter.Field != null && oReportFilter.Field.DataType == 'Guid' )
		{
			let lay: EDITVIEWS_FIELD = ReportDesign_EditView_Layout(oReportFilter.Field.Module.ModuleName, oReportFilter.Field.ColumnName);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.filterValueSelection', lay);
			if ( lay != null && (lay.FIELD_TYPE == 'ModulePopup' || lay.FIELD_TYPE == 'ChangeButton') && !Sql.IsEmptyString(lay.MODULE_TYPE) )
			{
				let row: any = {};
				row[lay.DATA_FIELD] = oReportFilter.Value;
				return (<div style={ {backgroundColor: 'white'} }  onClick={ (e) => e.stopPropagation() }>
					<ModulePopup
						baseId='tAppliedFilters_Value'
						layout={ lay }
						row={ row }
						bIsWriteable={ true }
						onChanged={ this._onVALUE_ModuleChange }
					/>
					<br />
					<input
						key={ 'tAppliedFilters_Value_DoneButton' }
						id={ 'tAppliedFilters_Value_DoneButton' }
						type='button'
						className='button'
						style={ {margin: 2} }
						value={ L10n.Term('.LBL_DONE_BUTTON_LABEL') }
						onClick={ this._onFilterValueDone }
					/>
				</div>);
			}
			else
			{
				// 04/10/2020 Paul.  Fallback to treating as text. 
				return (<table cellPadding={ 2 } cellSpacing={ 0 } style={ {border: 'none', backgroundColor: 'white'} }  onClick={ (e) => e.stopPropagation() }>
					<tr>
						<td style={ {width: '80%'} }>
							<input
								key={ 'tAppliedFilters_Value' + nSelectedFilter.toString() }
								id={ 'tAppliedFilters_Value' + nSelectedFilter.toString() }
								onChange={ this._onVALUE_TextChange }
								onClick={ this._onInputClick }
								onKeyDown={ this._onKeyDown }
								onBlur={ this._onFilterValueDone }
								type='text'
								style={ {width: '100%', margin: 2} }
								value={ oReportFilter.Value }
								autoFocus
							/>
						</td>
						<td style={ {width: '20%', verticalAlign: 'top'} }>
							<input
								key={ 'tAppliedFilters_Value_DoneButton' }
								id={ 'tAppliedFilters_Value_DoneButton' }
								type='button'
								className='button'
								style={ {margin: 2} }
								value={ L10n.Term('.LBL_DONE_BUTTON_LABEL') }
								onClick={ this._onFilterValueDone }
							/>
						</td>
					</tr>
				</table>);
			}
		}
		// 02/24/2015 Paul.  Add support for between filter clause. 
		else if ( oReportFilter.Operator == 'between' || oReportFilter.Operator == 'between_dates' )
		{
			let sLeftValue : string = '';
			let sRightValue: string = '';
			if ( oReportFilter.Value && Array.isArray(oReportFilter.Value) )
			{
				if ( oReportFilter.Value.length > 0 )
					sLeftValue = oReportFilter.Value[0];
				if ( oReportFilter.Value.length > 1 )
					sRightValue = oReportFilter.Value[1];
			}
			return (<div style={ {backgroundColor: 'white'} }  onClick={ (e) => e.stopPropagation() }>
				<input
					key={ 'tAppliedFilters_LeftValue' + nSelectedFilter.toString() }
					id={ 'tAppliedFilters_LeftValue' + nSelectedFilter.toString() }
					onChange={ (e) => this._onVALUE_BetweenChange(e, 0) }
					onClick={ this._onInputClick }
					type='text'
					style={ {width: '48%', margin: 2} }
					value={ sLeftValue }
					autoFocus
				/>
				<input
					key={ 'tAppliedFilters_RightValue' + nSelectedFilter.toString() }
					id={ 'tAppliedFilters_RightValue' + nSelectedFilter.toString() }
					onChange={ (e) => this._onVALUE_BetweenChange(e, 1) }
					onClick={ this._onInputClick }
					type='text'
					style={ {width: '48%', margin: 2} }
					value={ sRightValue }
				/>
				<br />
				<input
					key={ 'tAppliedFilters_Value_DoneButton' }
					id={ 'tAppliedFilters_Value_DoneButton' }
					type='button'
					className='button'
					style={ {margin: 2} }
					value={ L10n.Term('.LBL_DONE_BUTTON_LABEL') }
					onClick={ this._onFilterValueDone }
				/>
			</div>);
		}
		else if ( sSelectedFilterValueType == 'TextBox' )
		{
			return (<table cellPadding={ 2 } cellSpacing={ 0 } style={ {border: 'none', backgroundColor: 'white'} }  onClick={ (e) => e.stopPropagation() }>
				<tr>
					<td style={ {width: '80%'} }>
						<input
							key={ 'tAppliedFilters_Value' + nSelectedFilter.toString() }
							id={ 'tAppliedFilters_Value' + nSelectedFilter.toString() }
							onChange={ this._onVALUE_TextChange }
							onClick={ this._onInputClick }
							onKeyDown={ this._onKeyDown }
							onBlur={ this._onFilterValueDone }
							type='text'
							style={ {width: '100%', margin: 2} }
							value={ oReportFilter.Value }
							autoFocus
						/>
					</td>
					<td style={ {width: '20%', verticalAlign: 'top'} }>
						<input
							key={ 'tAppliedFilters_Value_DoneButton' }
							id={ 'tAppliedFilters_Value_DoneButton' }
							type='button'
							className='button'
							style={ {margin: 2} }
							value={ L10n.Term('.LBL_DONE_BUTTON_LABEL') }
							onClick={ this._onFilterValueDone }
						/>
					</td>
				</tr>
			</table>);
		}
		else if ( sSelectedFilterValueType == 'ListBox' )
		{
			return (<table cellPadding={ 2 } cellSpacing={ 0 } style={ {border: 'none', backgroundColor: 'white'} }  onClick={ (e) => e.stopPropagation() }>
				<tr>
					<td style={ {width: '80%'} }>
						<select
							key={ 'tAppliedFilters_Value' + nSelectedFilter.toString() }
							id={ 'tAppliedFilters_Value' + nSelectedFilter.toString() }
							onChange={ this._onVALUE_ListChange }
							onClick={ this._onInputClick }
							value={ oReportFilter.Value ? (Array.isArray(oReportFilter.Value) ? oReportFilter.Value : [oReportFilter.Value]) : null }
							style={ {width: '100%', margin: 2} }
							size={ 6 }
							multiple
							autoFocus
							>
							{
								VALUE_LIST.map((item, index) => 
								{
									return (<option key={ 'ctlReportDesigner_VALUE_LIST_' + index.toString() } id={ 'ctlReportDesigner_VALUE_LIST_' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
								})
							}
						</select>
					</td>
					<td style={ {width: '20%', verticalAlign: 'top'} }>
						<input
							key={ 'tAppliedFilters_Value_DoneButton' }
							id={ 'tAppliedFilters_Value_DoneButton' }
							type='button'
							className='button'
							style={ {margin: 2} }
							value={ L10n.Term('.LBL_DONE_BUTTON_LABEL') }
							onClick={ this._onFilterValueDone }
						/>
					</td>
				</tr>
			</table>);
		}
		else if ( sSelectedFilterValueType == 'ListCreate' )
		{
			return (<table cellPadding={ 2 } cellSpacing={ 0 } style={ {border: 'none', backgroundColor: 'white'} }  onClick={ (e) => e.stopPropagation() }>
				<tr>
					<td style={ {width: '80%'} }>
						<input
							key={ 'tAppliedFilters_Value_AddText' }
							id={ 'tAppliedFilters_Value_AddText' }
							type='text'
							style={ {width: '100%'} }
							value={ VALUE_ADDED }
							onChange={ this._onFilterAddChanged }
							onClick={ this._onInputClick }
						/>
					</td>
					<td style={ {width: '20%'} }>
						<input
							key={ 'tAppliedFilters_Value_AddButton' }
							id={ 'tAppliedFilters_Value_AddButton' }
							type='button'
							className='button'
							value={ L10n.Term('.LBL_ADD_BUTTON_LABEL') }
							onClick={ this._onFilterAddValue }
						/>
					</td>
				</tr>
				<tr>
					<td>
						<select
							key={ 'tAppliedFilters_Value' + nSelectedFilter.toString() }
							id={ 'tAppliedFilters_Value' + nSelectedFilter.toString() }
							onChange={ this._onVALUE_ListChange }
							onClick={ this._onInputClick }
							value={ oReportFilter.Value ? (Array.isArray(oReportFilter.Value) ? oReportFilter.Value : [oReportFilter.Value]) : null }
							style={ {width: '100%', margin: 2} }
							size={ 6 }
							multiple
							autoFocus
							>
							{
								VALUE_LIST.map((item, index) => 
								{
									return (<option key={ 'ctlReportDesigner_VALUE_LIST_' + index.toString() } id={ 'ctlReportDesigner_VALUE_LIST_' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
								})
							}
						</select>
					</td>
					<td style={ {verticalAlign: 'top'} }>
						<input
							key={ 'tAppliedFilters_Value_DoneButton' }
							id={ 'tAppliedFilters_Value_DoneButton' }
							type='button'
							className='button'
							style={ {margin: 2} }
							value={ L10n.Term('.LBL_DONE_BUTTON_LABEL') }
							onClick={ this._onFilterValueDone }
						/>
					</td>
				</tr>
			</table>);
		}
		return null;
	}

	public render()
	{
		const { bReportDesignerWorkflowMode } = this.props;
		const { oReportDesign, nSelectedField, sSelectedFieldMode, nSelectedRelationship, sSelectedRelationshipMode, nSelectedFilter, sSelectedFilterMode, showJoinFields, nSelectedJoin, sSelectedJoinMode, oPreviewSQL } = this.state;
		const { AGGREGATE_TYPE_LIST, SORT_DIRECTION_LIST, JOIN_TYPE_LIST, OPERATOR_TYPE_LIST, error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', oReportDesign);
		try
		{
			let themeURL: string = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/';
			// 10/21/2020 Paul.  Some themes look too tightly packed with the scaling. 
			let styCheckbox = { transform: 'scale(1.5)', display: 'inline', marginTop: '2px', marginBottom: '6px' };
			// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
			if ( Crm_Config.ToBoolean('enable_legacy_icons') )
			{
				styCheckbox.transform = 'scale(1.0)';
				styCheckbox.marginBottom = '2px';
			}
			return (
<div id='divQueryDesigner'>
	{ error
	? <div className='error'>{ typeof(error) == 'string' ? error : JSON.stringify(error) }</div>
	: null
	}
	<table cellSpacing={ 0 } cellPadding={ 0 } style={ {width: '100%', borderLeft: '1px solid #cccccc', borderRight: '1px solid #cccccc', borderBottom: '1px solid #cccccc'} }>
		<tr>
			<td rowSpan={ 3 } style={ {width: '300px', border: '1px solid #cccccc', verticalAlign: 'top'} }>
				<table cellSpacing={ 0 } cellPadding={ 4 } style={ {width: '100%'} }>
					<tr className='listViewThS1'>
						<td>{ L10n.Term('ReportDesigner.LBL_MODULES') }</td>
					</tr>
				</table>
				<div style={ {height: '640px', overflowY: 'auto', width: '300px'} }>
					<TreeView nodeLabel={ L10n.Term('ReportDesigner.LBL_TABLES') } defaultCollapsed={ false } itemClassName='reportTreeItem'>
					{ this.designerModules.arrReportDesignerModules.map((table, index) =>
						{
							if ( !table.Relationship && !table.CustomReportView )
							{
								let isTableChecked: boolean = this.isTableChecked(table);
								if ( Sql.ToBoolean(bReportDesignerWorkflowMode) )
								{
									return (
									<div className='tree-view_item' style={ {whiteSpace: 'nowrap'} }>
										<span className='reportTreeItem'>
											<input type='checkbox' className='checkbox' style={ styCheckbox } checked={ isTableChecked } onChange={ (e) => this._onClickTable(table, e.target.checked) } />
											<span style={ {cursor: 'pointer'} } onClick={ (e) => this._onClickTable(table, !isTableChecked) }>
												<FontAwesomeIcon icon={ {prefix: 'fas', iconName: 'file'} } style={ {fontSize: '18px', padding: '2px'} } color='#C3E1FF' />
												{ table.DisplayName + (this.bDebug ? ' (' + table.TableName + ')' : '') }
											</span>
										</span>
									</div>);
								}
								else
								{
									let sNAME: string = table.DisplayName + (this.bDebug ? ' (' + table.TableName + ')' : '');
									const label = 
									<span className='reportTreeItem'>
										<input type='checkbox' className='checkbox' style={ styCheckbox } checked={ isTableChecked } onChange={ (e) => this._onClickTable(table, e.target.checked) } />
										<span style={ {cursor: 'pointer'} } onClick={ (e) => this._onClickTable(table, !isTableChecked) }>
											<FontAwesomeIcon icon={ {prefix: 'fas', iconName: 'folder'} } style={ {fontSize: '18px', padding: '2px'} } color='#F2DF7D' />
											{ sNAME }
										</span>
									</span>;
									return (<TreeView nodeLabel={ label } key={ table.TableName } defaultCollapsed={ true } itemClassName='reportTreeItem'>
										{ table.Fields
										? this.renderTableFields(table)
										: null
										}
									</TreeView>);
								}
							}
							return null;
						})
					}
					</TreeView>
					{ !Sql.ToBoolean(bReportDesignerWorkflowMode)
					? <TreeView nodeLabel={ L10n.Term('ReportDesigner.LBL_RELATIONSHIP_TABLES') } defaultCollapsed={ true } itemClassName='reportTreeItem'>
						{ this.designerModules.arrReportDesignerModules.map((table, index) =>
							{
								if ( table.Relationship && !table.CustomReportView )
								{
									let sNAME: string = table.DisplayName + (this.bDebug ? ' (' + table.TableName + ')' : '');
									const label = <span className='reportTreeItem'>
										<input type='checkbox' className='checkbox' style={ styCheckbox } checked={ this.isTableChecked(table) } onChange={ (e) => this._onClickTable(table, e.target.checked) } />
										<FontAwesomeIcon icon={ {prefix: 'fas', iconName: 'folder'} } style={ {fontSize: '18px', padding: '2px'} } color='#F2DF7D' />
										{ sNAME }
									</span>;
									return (<TreeView nodeLabel={ label } key={ table.TableName } defaultCollapsed={ false } itemClassName='reportTreeItem'>
										{ table.Fields
										? this.renderTableFields(table)
										: null
										}
									</TreeView>);
								}
								return null;
							})
						}
					</TreeView>
					: null
					}
					{ !Sql.ToBoolean(bReportDesignerWorkflowMode)
					? <TreeView nodeLabel={ L10n.Term('ReportDesigner.LBL_CUSTOM_REPORT_VIEWS') } defaultCollapsed={ true } itemClassName='reportTreeItem'>
						{ this.designerModules.arrReportDesignerModules.map((table, index) =>
							{
								if ( !table.Relationship && table.CustomReportView )
								{
									let sNAME: string = table.DisplayName + (this.bDebug ? ' (' + table.TableName + ')' : '');
									const label = <span className='reportTreeItem'>
										<input type='checkbox' className='checkbox' style={ styCheckbox } checked={ this.isTableChecked(table) } onChange={ (e) => this._onClickTable(table, e.target.checked) } />
										<FontAwesomeIcon icon={ {prefix: 'fas', iconName: 'folder'} } style={ {fontSize: '18px', padding: '2px'} } color='#F2DF7D' />
										{ sNAME }
									</span>;
									return (<TreeView nodeLabel={ label } key={ table.TableName } defaultCollapsed={ false } itemClassName='reportTreeItem'>
										{ table.Fields
										? this.renderTableFields(table)
										: null
										}
									</TreeView>);
								}
								return null;
							})
						}
					</TreeView>
					: null
					}
				</div>
			</td>
			{ !Sql.ToBoolean(bReportDesignerWorkflowMode)
			? <td style={ {height: '240px', border: '1px solid #cccccc', verticalAlign: 'top'} }>
				<table cellSpacing={ 0 } cellPadding={ 4 } style={ {width: '100%'} }>
					<tr className='listViewThS1'>
						<td style={ {width: '20%'} }>{ L10n.Term('ReportDesigner.LBL_SELECTED_FIELDS') }</td>
						<td style={ {width: '80%'} } align='right'>
							<input id='chkGroupAndAggregate' type='checkbox' className='checkbox' style={ styCheckbox } onChange={ this.chkGroupAndAggregate_Clicked } checked={ oReportDesign.GroupAndAggregate } />
							&nbsp;&nbsp;
							<label htmlFor='chkGroupAndAggregate'>{ L10n.Term('ReportDesigner.LBL_GROUP_AND_AGGREGATE') }</label>
							&nbsp; &nbsp;
							<a href='#' onClick={ this.tSelectedFields_SelectedDelete   }><img style={ {width: '18px', height: '18px', border: 'none'} } src={ themeURL + 'images/ReportDesignerItemDelete.gif'  } /></a>
							<a href='#' onClick={ this.tSelectedFields_SelectedMoveUp   }><img style={ {width: '18px', height: '18px', border: 'none'} } src={ themeURL + 'images/ReportDesignerItemMoveUp.gif'  } /></a>
							<a href='#' onClick={ this.tSelectedFields_SelectedMoveDown }><img style={ {width: '18px', height: '18px', border: 'none'} } src={ themeURL + 'images/ReportDesignerItemMoveDown.gif'} /></a>
						</td>
					</tr>
				</table>
				<div style={ {height: '240px', overflowY: 'auto'} }>
					<table cellSpacing={ 0 } cellPadding={ 4 } style={ {width: '100%'} }>
						<tr className='listViewThS1'>
							<td style={ {width: '25%'} }>{ L10n.Term('ReportDesigner.LBL_FIELD'         ) }</td>
							<td style={ {width: '30%'} }>{ L10n.Term('ReportDesigner.LBL_DISPLAY_NAME'  ) }</td>
							<td style={ {width: '15%'} }>{ L10n.Term('ReportDesigner.LBL_DISPLAY_WIDTH' ) }</td>
							<td style={ {width: '15%'} }>{ L10n.Term('ReportDesigner.LBL_AGGREGATE'     ) }</td>
							<td style={ {width: '15%'} }>{ L10n.Term('ReportDesigner.LBL_SORT_DIRECTION') }</td>
						</tr>
					{ oReportDesign.SelectedFields.map((field, index) =>
						{
							return (
						<tr style={ {border: (index == nSelectedField ? '1px solid black' : null) } }>
							<td className='QueryDesigner'>
								{ field.FieldName }
							</td>
							<td className={ 'QueryDesigner' + (index == nSelectedField && sSelectedFieldMode == 'DisplayName' ? '_Selected' : '') } onClick={ (e) => this._onSelectedField_Edit(index, 'DisplayName') }>
							{ index == nSelectedField && sSelectedFieldMode == 'DisplayName'
							? <input
								id='ctlReportDesigner_DISPLAY_NAME'
								onChange={ this._onDISPLAY_NAME_Change }
								onClick={ this._onInputClick }
								onKeyDown={ this._onKeyDown }
								type='text'
								style={ {width: '95%', margin: 2} }
								value={ field.DisplayName }
								autoFocus
							/>
							: field.DisplayName
							}
							</td>
							<td className={ 'QueryDesigner' + (index == nSelectedField && sSelectedFieldMode == 'DisplayWidth' ? '_Selected' : '') } onClick={ (e) => this._onSelectedField_Edit(index, 'DisplayWidth') }>
							{ index == nSelectedField && sSelectedFieldMode == 'DisplayWidth'
							? <input
								id='ctlReportDesigner_DISLPAY_WIDTH'
								onChange={ this._onDISPLAY_WIDTH_Change }
								onClick={ this._onInputClick }
								onKeyDown={ this._onKeyDown }
								type='text'
								style={ {width: '95%', margin: 2} }
								value={ field.DisplayWidth }
								autoFocus
							/>
							: field.DisplayWidth
							}
							</td>
							<td className={ 'QueryDesigner' + (index == nSelectedField && sSelectedFieldMode == 'AggregateType' ? '_Selected' : '') } onClick={ (e) => this._onSelectedField_Edit(index, 'AggregateType') }>
							{ index == nSelectedField && sSelectedFieldMode == 'AggregateType'
							? <select
								id='ctlReportDesigner_AGGREGATE_TYPE_LIST'
								onChange={ this._onAGGREGATE_TYPE_Change }
								onClick={ this._onInputClick }
								value={ field.AggregateType }
								style={ {width: 'auto', margin: 2} }
								autoFocus
								>
								{
									AGGREGATE_TYPE_LIST.map((item, index) => 
									{
										return (<option key={ 'ctlReportDesigner__AGGREGATE_TYPE_LIST_' + index.toString() } id={ 'ctlReportDesigner_TYPE_LIST_' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
									})
								}
							</select>
							: ( field.AggregateType
							  ? L10n.ListTerm('report_aggregate_type_dom', field.AggregateType)
							  : L10n.Term('ReportDesigner.LBL_NONE')
							  )
							}
							</td>
							<td className={ 'QueryDesigner' + (index == nSelectedField && sSelectedFieldMode == 'SortDirection' ? '_Selected' : '') } onClick={ (e) => this._onSelectedField_Edit(index, 'SortDirection') }>
							{ index == nSelectedField && sSelectedFieldMode == 'SortDirection'
							? <select
								id='ctlReportDesigner_SORT_DIRECTION_LIST'
								onChange={ this._onSORT_DIRECTION_Change }
								onClick={ this._onInputClick }
								value={ field.SortDirection }
								style={ {width: 'auto', margin: 2} }
								autoFocus
								>
								{
									SORT_DIRECTION_LIST.map((item, index) => 
									{
										return (<option key={ 'ctlReportDesigner_SORT_DIRECTION_LIST_' + index.toString() } id={ 'ctlReportDesigner_SORT_DIRECTION_LIST_' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
									})
								}
							</select>
							: (  field.SortDirection
							   ? L10n.ListTerm('report_sort_direction_dom', field.SortDirection)
							   : L10n.Term('ReportDesigner.LBL_NONE')
							  )
							}
							</td>
						</tr>
							);
						})
					}
					</table>
				</div>
			</td>
			: <td style={ {height: '0px', padding: '0px', margin: '0px'} }></td>
			}
		</tr>
		<tr>
			<td style={ {height: '200px', border: '1px solid #cccccc', verticalAlign: 'top'} }>
				<table cellSpacing={ 0 } cellPadding={ 4 } style={ {width: '100%'} }>
					<tr className='listViewThS1'>
						<td style={ {width: '20%'} }>{ L10n.Term('ReportDesigner.LBL_RELATIONSHIPS') }</td>
						<td style={ {width: '80%'} } align='right'>
							<a href='#' onClick={ this.tRelationships_AddRelationship  }><img style={ {width: '18px', height: '18px', border: 'none'} } src={ themeURL + 'images/ReportDesignerRelationshipCreate.gif'} /></a>
							<a href='#' onClick={ this.tRelationships_SelectedDelete   }><img style={ {width: '18px', height: '18px', border: 'none'} } src={ themeURL + 'images/ReportDesignerItemDelete.gif'        } /></a>
							<a href='#' onClick={ this.tRelationships_SelectedMoveUp   }><img style={ {width: '18px', height: '18px', border: 'none'} } src={ themeURL + 'images/ReportDesignerItemMoveUp.gif'        } /></a>
							<a href='#' onClick={ this.tRelationships_SelectedMoveDown }><img style={ {width: '18px', height: '18px', border: 'none'} } src={ themeURL + 'images/ReportDesignerItemMoveDown.gif'      } /></a>
						</td>
					</tr>
				</table>
				<table cellSpacing={ 0 } cellPadding={ 4 } style={ {width: '100%'} }>
					<tr className='listViewThS1'>
						<td style={ {width: '30%'} }>{ L10n.Term('ReportDesigner.LBL_LEFT_TABLE' ) }</td>
						<td style={ {width: '10%'} }>{ L10n.Term('ReportDesigner.LBL_JOIN_TYPE'  ) }</td>
						<td style={ {width: '30%'} }>{ L10n.Term('ReportDesigner.LBL_RIGHT_TABLE') }</td>
						<td style={ {width: '30%'} }>{ L10n.Term('ReportDesigner.LBL_JOIN_FIELDS') }</td>
					</tr>
					{ oReportDesign.Relationships.map((relationship, index) =>
						{
							return (
						<tr style={ {border: (index == nSelectedRelationship ? '1px solid black' : null) } }>
							<td className={ 'QueryDesigner' + (index == nSelectedRelationship && sSelectedRelationshipMode == 'LeftTable' ? '_Selected' : '') } onClick={ (e) => this._onSelectedRelationship_Edit(index, 'LeftTable') }>
							{ index == nSelectedRelationship && sSelectedRelationshipMode == 'LeftTable'
							? this.relationshipTableSelection(relationship)
							: ( relationship.LeftTable
							  ? relationship.LeftTable.DisplayName
							  : L10n.Term('ReportDesigner.LBL_SELECT_TABLE')
							  )
							}
							</td>
							<td className={ 'QueryDesigner' + (index == nSelectedRelationship && sSelectedRelationshipMode == 'JoinType' ? '_Selected' : '') } onClick={ (e) => this._onSelectedRelationship_Edit(index, 'JoinType') }>
							{ index == nSelectedRelationship && sSelectedRelationshipMode == 'JoinType'
							? <select
								id='ctlReportDesigner_JOIN_TYPE'
								onChange={ this._onJOIN_TYPE_Change }
								onClick={ this._onInputClick }
								value={ relationship.JoinType }
								style={ {width: 'auto', margin: 2} }
								autoFocus
								>
								{
									JOIN_TYPE_LIST.map((item, index) => 
									{
										return (<option key={ 'ctlReportDesigner_JOIN_TYPE_LIST_' + index.toString() } id={ 'ctlReportDesigner_JOIN_TYPE_LIST_' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
									})
								}
							</select>
							: (  relationship.JoinType
							  ? L10n.ListTerm('report_join_type_dom', relationship.JoinType)
							  : L10n.Term('ReportDesigner.LBL_NONE')
							  )
							}
							</td>
							<td className={ 'QueryDesigner' + (index == nSelectedRelationship && sSelectedRelationshipMode == 'RightTable' ? '_Selected' : '') } onClick={ (e) => this._onSelectedRelationship_Edit(index, 'RightTable') }>
							{ index == nSelectedRelationship && sSelectedRelationshipMode == 'RightTable'
							? this.relationshipTableSelection(relationship)
							: ( relationship.RightTable
							  ? relationship.RightTable.DisplayName
							  : L10n.Term('ReportDesigner.LBL_SELECT_TABLE')
							  )
							}</td>
							<td className={ 'QueryDesigner' + (index == nSelectedRelationship && sSelectedRelationshipMode == 'JoinFields' ? '_Selected' : '') } onClick={ (e) => this._onSelectedRelationship_Edit(index, 'JoinFields') }>
							{
								this.JoinFieldsDisplayText(relationship)
							}
							</td>
						</tr>
							);
						})
					}
				</table>
			</td>
		</tr>
		<tr>
			<td style={ {height: '200px', border: '1px solid #cccccc', verticalAlign: 'top'} }>
				<table cellSpacing={ 0 } cellPadding={ 4 } style={ {width: '100%'} }>
					<tr className='listViewThS1'>
						<td style={ {width: '20%'} }>{ L10n.Term('ReportDesigner.LBL_APPLIED_FILTERS') }</td>
						<td style={ {width: '80%'} } align='right'>
							<a href='#' onClick={ this.tAppliedFilters_AddFilter        }><img style={ {width: '18px', height: '18px', border: 'none'} } src={ themeURL + 'images/ReportDesignerFilterCreate.gif'} /></a>
							<a href='#' onClick={ this.tAppliedFilters_SelectedDelete   }><img style={ {width: '18px', height: '18px', border: 'none'} } src={ themeURL + 'images/ReportDesignerItemDelete.gif'  } /></a>
							<a href='#' onClick={ this.tAppliedFilters_SelectedMoveUp   }><img style={ {width: '18px', height: '18px', border: 'none'} } src={ themeURL + 'images/ReportDesignerItemMoveUp.gif'  } /></a>
							<a href='#' onClick={ this.tAppliedFilters_SelectedMoveDown }><img style={ {width: '18px', height: '18px', border: 'none'} } src={ themeURL + 'images/ReportDesignerItemMoveDown.gif'} /></a>
						</td>
					</tr>
				</table>
				<table cellSpacing={ 0 } cellPadding={ 4 } style={ {width: '100%'} }>
					<tr className='listViewThS1'>
						<td style={ {width: '40%'} }>{ L10n.Term('ReportDesigner.LBL_FIELD_NAME') }</td>
						<td style={ {width: '10%'} }>{ L10n.Term('ReportDesigner.LBL_OPERATOR'  ) }</td>
						<td style={ {width: '40%'} }>{ L10n.Term('ReportDesigner.LBL_VALUE'     ) }</td>
						<td style={ {width: '10%'} }>{ L10n.Term('ReportDesigner.LBL_PARAMETER' ) }</td>
					</tr>
					{ oReportDesign.AppliedFilters.map((filter, index) =>
						{
							let field: ModuleField = filter.Field;
							return (
						<tr style={ {border: (index == nSelectedFilter ? '1px solid black' : null) } }>
							<td className={ 'QueryDesigner' + (index == nSelectedFilter && sSelectedFilterMode == 'Field' ? '_Selected' : '') } onClick={ (e) => this._onSelectedFilter_Edit(index, 'Field') }>
							{ index == nSelectedFilter && sSelectedFilterMode == 'Field'
							? this.filterFieldSelection(filter)
							: field
							? <span>
							{
								field.DisplayName
								+ (this.bDebug ? ' (' + field.TableName + '.' + field.ColumnName + ')' : '')
							}</span>
							  : L10n.Term('ReportDesigner.LBL_SELECT_FIELD')
							}</td>
							<td className={ 'QueryDesigner' + (index == nSelectedFilter && sSelectedFilterMode == 'Operator' ? '_Selected' : '') } onClick={ (e) => this._onSelectedFilter_Edit(index, 'Operator') }>
							{ index == nSelectedFilter && sSelectedFilterMode == 'Operator'
							? <select
								id='ctlReportDesigner_OPERATOR'
								onChange={ this._onOPERATOR_Change }
								onClick={ this._onInputClick }
								value={ filter.Operator }
								style={ {width: 'auto', margin: 2} }
								autoFocus
								>
								{
									this.getOperatorList(filter)
								}
							</select>
							: (  !Sql.IsEmptyString(filter.Operator)
							   ? L10n.ListTerm(this.getOperatorListName(filter), filter.Operator)
							  : L10n.Term('ReportDesigner.LBL_SELECT_OPERATOR')
							  )
							}
							</td>
							<td className={ 'QueryDesigner' + (index == nSelectedFilter && sSelectedFilterMode == 'Value' ? '_Selected' : '') } onClick={ (e) => this._onSelectedFilter_Edit(index, 'Value') }>
							{ index == nSelectedFilter && sSelectedFilterMode == 'Value'
							? this.filterValueSelection(filter)
							: this.filterValueDisplay(filter)
							}
							</td>
							<td className={ 'QueryDesigner' + (index == nSelectedFilter && sSelectedFilterMode == 'Parameter' ? '_Selected' : '') } onClick={ (e) => this._onSelectedFilter_Edit(index, 'Parameter') }>
								<input type='checkbox' className='checkbox' style={ styCheckbox } checked={ filter.Parameter } onChange={ (e) => this.tAppliedFilters_ChangeFilterParameter(filter, e.target.checked) } />
							</td>
						</tr>
							);
						})
					}
				</table>
			</td>
		</tr>
	</table>
	<br />
	{ this.props.row['SHOW_QUERY'] && oPreviewSQL
	? <div id='divReportDesignerSQLError' className='error'>{ oPreviewSQL.sError }</div>
	: null
	}
	{ this.props.row['SHOW_QUERY'] && oPreviewSQL
	? <table id="tblReportDesignerSQL" cellSpacing={ 0 } cellPadding={ 3 } style={ {width: '100%', backgroundColor: 'lightgrey', border: '1px solid black'} }>
		<tr>
			<td>
				<pre id="divReportDesignerSQL">{ oPreviewSQL.sSQL }</pre>
			</td>
		</tr>
	</table>
	: null
	}
	{ this.bDebug && this.props.row['SHOW_QUERY'] && oPreviewSQL
	? <div id='divReportDesignerJSONDump' dangerouslySetInnerHTML={ {__html: oPreviewSQL.sJsonDump} }></div>
	: null
	}
	<br />
	<Modal show={ showJoinFields } onHide={ this._onCloseJoinFields }>
		<ModalTitle>
			<div className='h3Row' style={ {width: '100%'} }>
				<h3 style={ {paddingLeft: '10px'} }>{ L10n.Term('ReportDesigner.LBL_EDIT_RELATED_FIELDS') }</h3>
			</div>
		</ModalTitle>
		<Modal.Body style={{ minHeight: '80vh', minWidth: '80vw' }}>
	{ showJoinFields && nSelectedRelationship >= 0 && sSelectedRelationshipMode == 'JoinFields'
	? <table cellSpacing={ 0 } cellPadding={ 0 } style={ {width: '100%', borderLeft: '1px solid #cccccc', borderRight: '1px solid #cccccc', borderBottom: '1px solid #cccccc'} }>
		<tr>
			<td style={ {height: '200px', border: '1px solid #cccccc', verticalAlign: 'top'} }>
				<table cellSpacing={ 0 } cellPadding={ 4 } style={ {width: '100%'} }>
					<tr className='listViewThS1'>
						<td style={ {width: '20%'} }>{ L10n.Term('ReportDesigner.LBL_RELATIONSHIPS') }</td>
						<td style={ {width: '80%'} } align='right'>
							<a href='#' onClick={ this.tJoinFields_AddJoinField     }><img style={ {width: '18px', height: '18px', border: 'none'} } src={ themeURL + 'images/ReportDesignerRelationshipCreate.gif'} /></a>
							<a href='#' onClick={ this.tJoinFields_SelectedDelete   }><img style={ {width: '18px', height: '18px', border: 'none'} } src={ themeURL + 'images/ReportDesignerItemDelete.gif'        } /></a>
							<a href='#' onClick={ this.tJoinFields_SelectedMoveUp   }><img style={ {width: '18px', height: '18px', border: 'none'} } src={ themeURL + 'images/ReportDesignerItemMoveUp.gif'        } /></a>
							<a href='#' onClick={ this.tJoinFields_SelectedMoveDown }><img style={ {width: '18px', height: '18px', border: 'none'} } src={ themeURL + 'images/ReportDesignerItemMoveDown.gif'      } /></a>
						</td>
					</tr>
				</table>
				<table cellSpacing={ 0 } cellPadding={ 4 } style={ {width: '100%'} }>
					<tr className='listViewThS1'>
						<td style={ {width: '45%'} }>{ L10n.Term('ReportDesigner.LBL_LEFT_JOIN_FIELD' ) }</td>
						<td style={ {width: '10%'} }>{ L10n.Term('ReportDesigner.LBL_OPERATOR'        ) }</td>
						<td style={ {width: '45%'} }>{ L10n.Term('ReportDesigner.LBL_RIGHT_JOIN_FIELD') }</td>
					</tr>
					{ oReportDesign.Relationships[nSelectedRelationship].JoinFields.map((join, index) =>
						{
							return (
						<tr style={ {border: (index == nSelectedJoin ? '1px solid black' : null) } }>
							<td className={ 'QueryDesigner' + (index == nSelectedJoin && sSelectedJoinMode == 'LeftField' ? '_Selected' : '') } onClick={ (e) => this._onSelectedJoinField_Edit(index, 'LeftField') }>
							{ index == nSelectedJoin && sSelectedJoinMode == 'LeftField'
							? <select
								id='ctlReportDesigner_LEFT_JOIN_FIELD'
								onChange={ this._onLEFT_JOIN_FIELD_Change }
								onClick={ this._onInputClick }
								value={ join.LeftField ? join.LeftField.ColumnName : null }
								style={ {width: 'auto', margin: 2} }
								autoFocus
								>
								{
									this.designerModules.FindModuleByTable(oReportDesign.Relationships[nSelectedRelationship].LeftTable.TableName).Fields.map((field, index) => 
									{
										let sNAME: string = field.DisplayName + (this.bDebug ? ' (' + field.TableName + '.' + field.ColumnName + ')' : '');
										return (<option key={ 'ctlReportDesigner_LEFT_JOIN_FIELD_' + index.toString() } id={ 'ctlReportDesigner_LEFT_JOIN_FIELD_' + index.toString() } value={ field.ColumnName }>{ sNAME }</option>);
									})
								}
							</select>
							: ( join.LeftField
							  ? join.LeftField.DisplayName
							  : L10n.Term('ReportDesigner.LBL_SELECT_FIELD')
							  )
							}
							</td>
							<td className={ 'QueryDesigner' + (index == nSelectedJoin && sSelectedJoinMode == 'OperatorType' ? '_Selected' : '') } onClick={ (e) => this._onSelectedJoinField_Edit(index, 'OperatorType') }>
							{ index == nSelectedJoin && sSelectedJoinMode == 'OperatorType'
							? <select
								id='ctlReportDesigner_OPERATOR_TYPE'
								onChange={ this._onOPERATOR_TYPE_Change }
								onClick={ this._onInputClick }
								value={ join.OperatorType }
								style={ {width: 'auto', margin: 2} }
								autoFocus
								>
								{
									OPERATOR_TYPE_LIST.map((item, index) => 
									{
										return (<option key={ 'ctlReportDesigner_OPERATOR_TYPE_LIST_' + index.toString() } id={ 'ctlReportDesigner_OPERATOR_TYPE_LIST_' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
									})
								}
							</select>
							: ( join.OperatorType
							  ? join.OperatorType
							  : L10n.Term('ReportDesigner.LBL_NONE')
							  )
							}
							</td>
							<td className={ 'QueryDesigner' + (index == nSelectedJoin && sSelectedJoinMode == 'RightField' ? '_Selected' : '') } onClick={ (e) => this._onSelectedJoinField_Edit(index, 'RightField') }>
							{ index == nSelectedJoin && sSelectedJoinMode == 'RightField'
							? <select
								id='ctlReportDesigner_RIGHT_JOIN_FIELD'
								onChange={ this._onRIGHT_JOIN_FIELD_Change }
								onClick={ this._onInputClick }
								value={ join.RightField ? join.RightField.ColumnName : null }
								style={ {width: 'auto', margin: 2} }
								autoFocus
								>
								{
									this.designerModules.FindModuleByTable(oReportDesign.Relationships[nSelectedRelationship].RightTable.TableName).Fields.map((field, index) => 
									{
										let sNAME: string = field.DisplayName + (this.bDebug ? ' (' + field.TableName + '.' + field.ColumnName + ')' : '');
										return (<option key={ 'ctlReportDesigner_RIGHT_JOIN_FIELD_' + index.toString() } id={ 'ctlReportDesigner_RIGHT_JOIN_FIELD_' + index.toString() } value={ field.ColumnName }>{ sNAME }</option>);
									})
								}
							</select>
							: ( join.RightField
							  ? join.RightField.DisplayName
							  : L10n.Term('ReportDesigner.LBL_SELECT_FIELD')
							  )
							}</td>
						</tr>
							);
						})
					}
				</table>
			</td>
		</tr>
	</table>
	: <div>{ nSelectedRelationship.toString() + ' ' + sSelectedRelationshipMode }</div>
	}
			<button className='button' onClick={ this._onCloseJoinFields }>{ L10n.Term('ReportDesigner.LBL_OK') }</button>
		</Modal.Body>
		<Modal.Footer>
			<button className='button' onClick={ this._onCloseJoinFields }>{ L10n.Term('.LBL_CLOSE_BUTTON_LABEL') }</button>
		</Modal.Footer>
	</Modal>
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

