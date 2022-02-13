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
// 2. Store and Types. 
import EDITVIEWS_FIELD                                      from '../types/EDITVIEWS_FIELD'      ;
// 3. Scripts. 
import Sql                                                  from '../scripts/Sql'                ;
import L10n                                                 from '../scripts/L10n'               ;
import SplendidCache                                        from '../scripts/SplendidCache'      ;
import { dumpObj }                                          from '../scripts/utility'            ;
import { ReportDesignerModules, ReportModule, ModuleField } from './ReportDesignerModules'       ;

let bDebug: boolean = false;

function pad(str: string, len: number, padChar?: string): string
{
	str = str.toString();
	if ( typeof padChar === "undefined")
	{
		padChar = ' ';
	}
	while ( str.length < len )
	{
		str = padChar + str;
	}
	return str;
}

export function ReportDesign_EditView_Layout(sModuleName: string, sColumnName: string): EDITVIEWS_FIELD
{
	sColumnName = sColumnName.toUpperCase();
	
	let sEDIT_NAME: string = sModuleName + '.EditView';
	let layout: EDITVIEWS_FIELD[] = SplendidCache.EditViewFields(sEDIT_NAME);
	for ( let nLayoutIndex in layout )
	{
		let lay: EDITVIEWS_FIELD = layout[nLayoutIndex];
		let sFIELD_TYPE: string = lay.FIELD_TYPE;
		let sDATA_FIELD: string = lay.DATA_FIELD;
		if ( sDATA_FIELD != null && sDATA_FIELD.toUpperCase() == sColumnName )
		{
			return lay;
		}
	}
	return null;
}

export class ReportField
{
	public Field            : ModuleField;
	public TableName        : string     ;
	public ColumnName       : string     ;
	public FieldName        : string     ;
	public AggregateType    : string     ;
	public DisplayName      : string     ;
	public DisplayWidth     : string     ;
	public SortDirection    : string     ;

	public constructor(field: ModuleField, bGroupAndAggregate?: boolean)
	{
		if ( bGroupAndAggregate === undefined )
			bGroupAndAggregate = false;
		this.Field         = field                  ;
		this.TableName     = field.TableName        ;
		this.ColumnName    = field.ColumnName       ;
		this.FieldName     = field.Module.TableName + '.' + field.ColumnName;
		this.AggregateType = (bGroupAndAggregate ? 'group by' : null);
		this.DisplayName   = field.Module.DisplayName + ' ' + field.DisplayName;
		this.DisplayWidth  = null;
		this.SortDirection = null;
	}
}

export class ReportTable
{
	public Module           : any   ;
	public ModuleName       : string;
	public DisplayName      : string;
	public TableName        : string;

	public constructor(module: any)
	{
		this.Module      = module            ;
		this.ModuleName  = module.ModuleName ;
		this.DisplayName = module.DisplayName;
		this.TableName   = module.TableName  ;
		if ( bDebug )
			this.DisplayName += ' (' + module.TableName + ')';
	}
}

export class ReportJoinField
{
	public LeftField        : ReportField;
	public OperatorType     : string     ;
	public RightField       : ReportField;

	public constructor(oJoinField?: ReportJoinField)
	{
		if ( oJoinField !== undefined )
		{
			this.LeftField    = oJoinField.LeftField   ;
			this.OperatorType = oJoinField.OperatorType;
			this.RightField   = oJoinField.RightField  ;
		}
		else
		{
			this.LeftField    = null;
			this.OperatorType = '=';
			this.RightField   = null;
		}
	}

	public SetLeftFieldName(oReportDesign: ReportDesign, nRelationshipIndex: number, sFieldName: string)
	{
		let arrFieldName       : string[]           = sFieldName.split('.');
		let oReportRelationship: ReportRelationship = oReportDesign.Relationships_GetAt(nRelationshipIndex);
		let arrModuleFields    : ModuleField[]      = oReportDesign.ModuleFields(oReportRelationship.LeftTable.TableName);
		for ( let i = 0; i < arrModuleFields.length; i++ )
		{
			if ( arrFieldName[1] == arrModuleFields[i].ColumnName )
			{
				this.LeftField = new ReportField(arrModuleFields[i]);
				break;
			}
		}
	}

	public SetRightFieldName(oReportDesign: ReportDesign, nRelationshipIndex: number, sFieldName: string)
	{
		let arrFieldName       : string[]           = sFieldName.split('.');
		let oReportRelationship: ReportRelationship = oReportDesign.Relationships_GetAt(nRelationshipIndex);
		let arrModuleFields    : ModuleField[]      = oReportDesign.ModuleFields(oReportRelationship.RightTable.TableName);
		for ( let i = 0; i < arrModuleFields.length; i++ )
		{
			if ( arrFieldName[1] == arrModuleFields[i].ColumnName )
			{
				this.RightField = new ReportField(arrModuleFields[i]);
				break;
			}
		}
	}

}

export class ReportRelationship
{
	public LeftTable        : ReportTable           ;
	public JoinType         : string                ;
	public RightTable       : ReportTable           ;
	public JoinFields       : Array<ReportJoinField>;

	public constructor()
	{
		this.LeftTable  = null;
		this.JoinType   = 'inner';
		this.RightTable = null;
		this.JoinFields = new Array();
	}
}

export class ReportFilter
{
	public Field    : ModuleField;
	public Operator : string     ;
	public Value    : any        ;
	public Parameter: boolean    ;

	public IsNumericField(): boolean
	{
		let b: boolean = false;
		if ( this.Field != null )
		{
			switch ( this.Field.DataType )
			{
				case 'ansistring':  b = false;  break;
				case 'bool'      :  b = false;  break;
				case 'byte[]'    :  b = false;  break;
				case 'DateTime'  :  b = false;  break;
				case 'decimal'   :  b = true ;  break;
				case 'float'     :  b = true ;  break;
				case 'Guid'      :  b = false;  break;
				case 'Int16'     :  b = true ;  break;
				case 'Int32'     :  b = true ;  break;
				case 'Int64'     :  b = true ;  break;
				case 'short'     :  b = true ;  break;
				case 'string'    :  b = false;  break;
			}
		}
		return b;
	}

	// 02/11/2018 Paul.  We need to determine if the string should be treated as a enum. 
	public IsEnum(): boolean
	{
		let b: boolean = false;
		if ( this.Field != null && this.Field.Module != null )
		{
			let lay: EDITVIEWS_FIELD = ReportDesign_EditView_Layout(this.Field.Module.ModuleName, this.Field.ColumnName);
			if ( lay != null )
			{
				if ( !Sql.IsEmptyString(lay.LIST_NAME) )
					b = true;
			}
		}
		return b;
	}

	public CsType(): string
	{
		let sCsType: string = this.Field.DataType.toLowerCase();
		if ( this.IsEnum() )
			sCsType = 'enum';
		return sCsType;
	}

	public IsDateField(): boolean
	{
		let b: boolean = false;
		if ( this.Field != null )
		{
			if ( this.Field.DataType == 'DateTime' )
				b = true;
		}
		return b;
	}

	public IsBooleanField(): boolean
	{
		let b: boolean = false;
		if ( this.Field != null )
		{
			if ( this.Field.DataType == 'bool' )
				b = true;
		}
		return b;
	}

	public EscapedValue(sValue): string
	{
		let sSQLValue: string = null;
		if ( this.IsNumericField() )
			sSQLValue = sValue;
		else
			sSQLValue = '\'' + Sql.EscapeSQL(sValue) + '\'';
		return sSQLValue;
	}

	public EscapedLikeValue(sValue): string
	{
		let sSQLValue: string = '\'' + Sql.EscapeSQLLike(sValue) + '\'';
		return sSQLValue;
	}

}

export class ReportDesign
{
	private designerModules: ReportDesignerModules;
	public GroupAndAggregate: boolean = false;
	public Tables           : Array<ReportTable       >;
	public SelectedFields   : Array<ReportField       >;
	public Relationships    : Array<ReportRelationship>;
	public AppliedFilters   : Array<ReportFilter      >;

	public constructor(designerModules: ReportDesignerModules)
	{
		this.designerModules = designerModules;
		this.Reset();
	}

	public Reset()
	{
		this.GroupAndAggregate = false;
		this.Tables            = new Array();
		this.SelectedFields    = new Array();
		this.Relationships     = new Array();
		this.AppliedFilters    = new Array();
	}

	public validate(): boolean
	{
		return this.Tables.length > 0;
	}

	// 08/03/2014 Paul.  Simplfy the object module by returning just the raw fields, not deep object references. 
	public Stringify()
	{
		let oRAW: any = new Object();
		oRAW.GroupAndAggregate = false;
		oRAW.Tables            = new Array();
		oRAW.SelectedFields    = new Array();
		oRAW.Relationships     = new Array();
		oRAW.AppliedFilters    = new Array();
	
		oRAW.GroupAndAggregate = this.GroupAndAggregate;
		if ( this.Tables != null )
		{
			for ( let i = 0; i < this.Tables.length; i++ )
			{
				let table: any = new Object();
				table.ModuleName = this.Tables[i].ModuleName ;
				table.TableName  = this.Tables[i].TableName  ;
				oRAW.Tables.push(table);
			}
		}
		if ( this.SelectedFields != null )
		{
			for ( let i = 0; i < this.SelectedFields.length; i++ )
			{
				if ( this.SelectedFields[i].Field != null )
				{
					// 03/30/2020 Paul.  We don't use the same object so that we can convert an object reference to actual values. 
					let field: any = new Object();
					field.TableName     = this.SelectedFields[i].Field.TableName;
					field.ColumnName    = this.SelectedFields[i].ColumnName     ;
					field.FieldName     = this.SelectedFields[i].FieldName      ;
					field.AggregateType = this.SelectedFields[i].AggregateType  ;
					field.DisplayName   = this.SelectedFields[i].DisplayName    ;
					field.DisplayWidth  = this.SelectedFields[i].DisplayWidth   ;
					field.SortDirection = this.SelectedFields[i].SortDirection  ;
					oRAW.SelectedFields.push(field);
				}
			}
		}
		if ( this.Relationships != null )
		{
			for ( let i = 0; i < this.Relationships.length; i++ )
			{
				if ( this.Relationships[i].LeftTable != null && this.Relationships[i].RightTable != null )
				{
					// 03/30/2020 Paul.  We don't use the same object so that we can convert an object reference to actual values. 
					let relationship: any = new Object();
					relationship.LeftTableName  = this.Relationships[i].LeftTable.TableName ;
					relationship.JoinType       = this.Relationships[i].JoinType            ;
					relationship.RightTableName = this.Relationships[i].RightTable.TableName;
					relationship.JoinFields = new Array();
					let joins = this.Relationships[i].JoinFields;
					for ( let j = 0; j < joins.length; j++ )
					{
						if ( joins[j].LeftField != null && joins[j].RightField != null )
						{
							// 03/30/2020 Paul.  We don't use the same object so that we can convert an object reference to actual values. 
							let join: any = new Object();
							join.LeftTableName   = joins[j].LeftField.TableName  ;
							join.LeftColumnName  = joins[j].LeftField.ColumnName ;
							join.OperatorType    = joins[j].OperatorType         ;
							join.RightTableName  = joins[j].RightField.TableName ;
							join.RightColumnName = joins[j].RightField.ColumnName;
							relationship.JoinFields.push(join);
						}
					}
					oRAW.Relationships.push(relationship);
				}
			}
		}
		if ( this.AppliedFilters != null )
		{
			for ( let i = 0; i < this.AppliedFilters.length; i++ )
			{
				if ( this.AppliedFilters[i].Field != null )
				{
					// 03/30/2020 Paul.  We don't use the same object so that we can convert an object reference to actual values. 
					let filter: any = new Object();
					filter.TableName  = this.AppliedFilters[i].Field.TableName ;
					filter.ColumnName = this.AppliedFilters[i].Field.ColumnName;
					filter.Operator   = this.AppliedFilters[i].Operator        ;
					filter.Value      = this.AppliedFilters[i].Value           ;
					filter.Parameter  = this.AppliedFilters[i].Parameter       ;
					oRAW.AppliedFilters.push(filter);
				}
			}
		}
		return JSON.stringify(oRAW);
	}

	// 08/03/2014 Paul.  Simplfy the object module by returning just the raw fields, not deep object references. 
	public Parse(sReportJson: any)
	{
		this.Reset();
		if ( sReportJson !== undefined )
		{
			let oRAW: any = null;
			if ( typeof(sReportJson) == 'object' )
				oRAW = sReportJson;
			else if ( typeof(sReportJson) == 'string' )
				oRAW = JSON.parse(sReportJson);
			if ( oRAW.GroupAndAggregate !== undefined )
				this.GroupAndAggregate = oRAW.GroupAndAggregate;
			if ( oRAW.Tables !== undefined )
			{
				for ( let i: number = 0; i < oRAW.Tables.length; i++ )
				{
					let module: any         = this.designerModules.FindModuleByTable(oRAW.Tables[i].TableName);
					let table : ReportTable = new ReportTable(module);
					this.Tables.push(table);
				}
			}
			if ( oRAW.SelectedFields !== undefined )
			{
				for ( let i: number = 0; i < oRAW.SelectedFields.length; i++ )
				{
					if ( oRAW.SelectedFields[i].TableName !== undefined && oRAW.SelectedFields[i].ColumnName !== undefined )
					{
						let oBaseField = this.designerModules.FindFieldByTable(oRAW.SelectedFields[i].TableName, oRAW.SelectedFields[i].ColumnName);
						if ( oBaseField != null )
						{
							let field: ReportField = new ReportField(oBaseField, this.GroupAndAggregate);
							if ( oRAW.SelectedFields[i].AggregateType !== undefined ) field.AggregateType = oRAW.SelectedFields[i].AggregateType;
							if ( oRAW.SelectedFields[i].DisplayName   !== undefined ) field.DisplayName   = oRAW.SelectedFields[i].DisplayName  ;
							if ( oRAW.SelectedFields[i].DisplayWidth  !== undefined ) field.DisplayWidth  = oRAW.SelectedFields[i].DisplayWidth ;
							if ( oRAW.SelectedFields[i].SortDirection !== undefined ) field.SortDirection = oRAW.SelectedFields[i].SortDirection;
							this.SelectedFields.push(field);
						}
					}
				}
			}
			if ( oRAW.Relationships !== undefined )
			{
				for ( let i: number = 0; i < oRAW.Relationships.length; i++ )
				{
					let oLeftModule  = this.designerModules.FindModuleByTable(oRAW.Relationships[i].LeftTableName );
					let oRightModule = this.designerModules.FindModuleByTable(oRAW.Relationships[i].RightTableName);
					if ( oLeftModule != null && oRightModule != null )
					{
						let relationship: ReportRelationship = new ReportRelationship();
						relationship.LeftTable  = new ReportTable(oLeftModule );
						relationship.JoinType   = oRAW.Relationships[i].JoinType;
						relationship.RightTable = new ReportTable(oRightModule);
						relationship.JoinFields = new Array();
						let joins: any[] = oRAW.Relationships[i].JoinFields;
						for ( let j: number = 0; j < joins.length; j++ )
						{
							let oLeftField : ModuleField = this.designerModules.FindFieldByTable(joins[j].LeftTableName , joins[j].LeftColumnName );
							let oRightField: ModuleField = this.designerModules.FindFieldByTable(joins[j].RightTableName, joins[j].RightColumnName);
							if ( oLeftField != null && oRightField != null )
							{
								let join: ReportJoinField = new ReportJoinField();
								join.LeftField    = new ReportField(oLeftField );
								join.OperatorType = joins[j].OperatorType       ;
								join.RightField   = new ReportField(oRightField);
								relationship.JoinFields.push(join);
							}
						}
						this.Relationships.push(relationship);
					}
				}
			}
			if ( oRAW.AppliedFilters !== undefined )
			{
				for ( let i: number = 0; i < oRAW.AppliedFilters.length; i++ )
				{
					//if ( Sql.IsEmptyString(oRAW.AppliedFilters[i].TableName) )
					//	alert('Missing table name in filter ' + i.toString() + ', ' + oRAW.AppliedFilters[i].ColumnName);
					let oBaseField: ModuleField = this.designerModules.FindFieldByTable(oRAW.AppliedFilters[i].TableName, oRAW.AppliedFilters[i].ColumnName);
					if ( oBaseField != null )
					{
						let filter: ReportFilter = new ReportFilter();
						filter.Field     = oBaseField;
						filter.Operator  = oRAW.AppliedFilters[i].Operator ;
						filter.Value     = oRAW.AppliedFilters[i].Value    ;
						filter.Parameter = oRAW.AppliedFilters[i].Parameter;
						this.AppliedFilters.push(filter);
					
						//alert(dumpObj(filter.Field, 'Field'));
					}
				}
			}
		}
		/*
		for ( let i: number = 0; i < this.SelectedFields.length; i++ )
		{
			tSelectedFields_AddField(this.SelectedFields[i].Field, this.SelectedFields[i])
		}
		for ( let i: number = 0; i < this.Relationships.length; i++ )
		{
			tRelationships_AddRelationship(this.Relationships[i])
		}
		for ( let i: number = 0; i < this.AppliedFilters.length; i++ )
		{
			tAppliedFilters_AddFilter(this.AppliedFilters[i])
		}
		*/
	}

	public Tables_AddTable(module: ReportModule)
	{
		let bFound: boolean = false;
		for ( let i: number = 0; i < this.Tables.length; i++ )
		{
			if ( this.Tables[i].TableName == module.TableName )
			{
				bFound = true;
				break;
			}
		}
		if ( !bFound )
		{
			let table: ReportTable = new ReportTable(module);
			this.Tables.push(table);
		}
	}

	public Tables_RemoveTable(sTableName: string)
	{
		for ( let i: number = 0; i < this.Tables.length; i++ )
		{
			if ( this.Tables[i].TableName == sTableName )
			{
				this.Tables.splice(i, 1);
				break;
			}
		}
	}

	public SelectedField_AddField(field: ModuleField): ReportField
	{
		let sFieldName: string = field.TableName + '.' + field.ColumnName;
	
		let oReportField: ReportField = null;
		let bFound: boolean = false;
		for ( let i: number = 0; i < this.SelectedFields.length; i++ )
		{
			oReportField = this.SelectedFields[i];
			if ( oReportField.FieldName == sFieldName )
			{
				bFound = true;
				break;
			}
		}
		if ( !bFound )
		{
			oReportField = new ReportField(field, this.GroupAndAggregate);
			this.SelectedFields.push(oReportField);
			this.Tables_AddTable(field.Module);
		}
		return oReportField;
	}

	public Tables_UpdateAll()
	{
		this.Tables = new Array();
		for ( let i: number = 0; i < this.SelectedFields.length; i++ )
		{
			let field: ModuleField = this.SelectedFields[i].Field;
			this.Tables_AddTable(field.Module);
		}
		for ( let i: number = 0; i < this.Relationships.length; i++ )
		{
			let relationship: ReportRelationship = this.Relationships[i];
			if ( relationship.LeftTable != null )
				this.Tables_AddTable(relationship.LeftTable.Module );
			if ( relationship.RightTable != null )
				this.Tables_AddTable(relationship.RightTable.Module);
		}
	}

	public SelectedField_RemoveField(sFieldName: string)
	{
		for ( let i: number = 0; i < this.SelectedFields.length; i++ )
		{
			let oReportField: ReportField = this.SelectedFields[i];
			if ( oReportField.FieldName == sFieldName )
			{
				this.SelectedFields.splice(i, 1);
				break;
			}
		}
		this.Tables_UpdateAll();
	}

	public SelectedField_GetAt(nSelectedIndex: number): ReportField
	{
		return this.SelectedFields[nSelectedIndex];
	}

	public SelectedField_Delete(nSelectedIndex: number)
	{
		this.SelectedFields.splice(nSelectedIndex, 1);
	}

	public SelectedField_MoveUp(nSelectedIndex: number)
	{
		let oReportField: ReportField = this.SelectedFields[nSelectedIndex];
		this.SelectedFields.splice(nSelectedIndex, 1);
		this.SelectedFields.splice(nSelectedIndex - 1, 0, oReportField);
	}

	public SelectedField_MoveDown(nSelectedIndex: number)
	{
		let oReportField: ReportField = this.SelectedFields[nSelectedIndex];
		this.SelectedFields.splice(nSelectedIndex, 1);
		this.SelectedFields.splice(nSelectedIndex + 1, 0, oReportField);
	}

	public Relationships_AddRelationship(): ReportRelationship
	{
		let oRelationship: ReportRelationship = new ReportRelationship();
		this.Relationships.push(oRelationship);
		return oRelationship;
	}

	public Relationships_GetAt(nSelectedIndex: number): ReportRelationship
	{
		return this.Relationships[nSelectedIndex];
	}

	public Relationships_Delete(nSelectedIndex: number)
	{
		this.Relationships.splice(nSelectedIndex, 1);
	}

	public Relationships_MoveUp(nSelectedIndex: number)
	{
		let oRelationship: ReportRelationship = this.Relationships[nSelectedIndex];
		this.Relationships.splice(nSelectedIndex, 1);
		this.Relationships.splice(nSelectedIndex - 1, 0, oRelationship);
	}

	public Relationships_MoveDown(nSelectedIndex: number)
	{
		let oRelationship: ReportRelationship = this.Relationships[nSelectedIndex];
		this.Relationships.splice(nSelectedIndex, 1);
		this.Relationships.splice(nSelectedIndex + 1, 0, oRelationship);
	}

	public Relationships_JoinField_AddJoinField(nRelationshipIndex: number): ReportJoinField
	{
		let oRelationships: ReportRelationship = this.Relationships[nRelationshipIndex];
		let oJoinField: ReportJoinField = new ReportJoinField();
		oRelationships.JoinFields.push(oJoinField);
		return oJoinField;
	}

	public Relationships_JoinField_GetAt(nRelationshipIndex: number, nSelectedIndex: number): ReportJoinField
	{
		let oRelationships: ReportRelationship = this.Relationships[nRelationshipIndex];
		return oRelationships.JoinFields[nSelectedIndex];
	}

	public Relationships_JoinField_Delete(nRelationshipIndex: number, nSelectedIndex: number)
	{
		let oRelationships: ReportRelationship = this.Relationships[nRelationshipIndex];
		oRelationships.JoinFields.splice(nSelectedIndex, 1);
	}

	public Relationships_JoinField_MoveUp(nRelationshipIndex: number, nSelectedIndex: number)
	{
		let oRelationships: ReportRelationship = this.Relationships[nRelationshipIndex];
		let oJoinField: ReportJoinField = oRelationships.JoinFields[nSelectedIndex];
		oRelationships.JoinFields.splice(nSelectedIndex, 1);
		oRelationships.JoinFields.splice(nSelectedIndex - 1, 0, oJoinField);
	}

	public Relationships_JoinField_MoveDown(nRelationshipIndex: number, nSelectedIndex: number)
	{
		let oRelationships: ReportRelationship = this.Relationships[nRelationshipIndex];
		let oJoinField: ReportJoinField = oRelationships.JoinFields[nSelectedIndex];
		oRelationships.JoinFields.splice(nSelectedIndex, 1);
		oRelationships.JoinFields.splice(nSelectedIndex + 1, 0, oJoinField);
	}

	public ModuleFields(sTableName: string)
	{
		let arrFields: any[] = null;
		let module: ReportModule = this.designerModules.FindModuleByTable(sTableName);
		if ( module != null )
		{
			arrFields = module.Fields;
		}
		return arrFields;
	}

	public AppliedFilters_AddFilter()
	{
		let oFilter: ReportFilter = new ReportFilter();
		this.AppliedFilters.push(oFilter);
		return oFilter;
	}

	public AppliedFilters_GetAt(nSelectedIndex: number): ReportFilter
	{
		return this.AppliedFilters[nSelectedIndex];
	}

	public AppliedFilters_Delete(nSelectedIndex: number)
	{
		this.AppliedFilters.splice(nSelectedIndex, 1);
	}

	public AppliedFilters_MoveUp(nSelectedIndex: number)
	{
		let oFilter: ReportFilter = this.AppliedFilters[nSelectedIndex];
		this.AppliedFilters.splice(nSelectedIndex, 1);
		this.AppliedFilters.splice(nSelectedIndex - 1, 0, oFilter);
	}

	public AppliedFilters_MoveDown(nSelectedIndex: number)
	{
		let oFilter: ReportFilter = this.AppliedFilters[nSelectedIndex];
		this.AppliedFilters.splice(nSelectedIndex, 1);
		this.AppliedFilters.splice(nSelectedIndex + 1, 0, oFilter);
	}

	public PreviewSQL(bReportDesignerWorkflowMode: boolean): any
	{
		let sSQL   : string = '';
		let CrLf   : string = '\r\n';
		let sErrors: string = '';
		// 07/17/2016 Paul.  Allow the filter operator to be changed to a workflow version. 
		let report_filter_operator_dom: string = 'report_filter_operator_dom';
		if ( bReportDesignerWorkflowMode )
			report_filter_operator_dom = 'workflow_filter_operator_dom';
		if ( this.Tables.length > 0 )
		{
			let oUsedTables = new Object();
			for ( let i: number = 0; i < this.Tables.length; i++ )
			{
				oUsedTables[this.Tables[i].TableName] = 0;
			}
			// 07/04/2016 Paul.  Special case when not showing selected fields. 
			if ( bReportDesignerWorkflowMode )
			{
				if ( this.SelectedFields.length == 0 )
				{
					for ( let i: number = 0; i < this.Tables.length; i++ )
					{
						sSQL = 'select ' + this.Tables[i].TableName + '.ID' + CrLf;
						break;
					}
				}
				else
				{
					for ( let i: number = 0; i < this.SelectedFields.length; i++ )
					{
						let oReportField: ReportField = this.SelectedFields[i];
						sSQL = 'select ' + oReportField.FieldName + CrLf;
						break;
					}
				}
			}
			else if ( this.SelectedFields.length == 0 )
			{
				sSQL += 'select *' + CrLf;
			}
			else
			{
				let nMaxLen: number = 0;
				for ( let i: number = 0; i < this.SelectedFields.length; i++ )
				{
					let oReportField: ReportField = this.SelectedFields[i];
					nMaxLen = Math.max(nMaxLen, oReportField.FieldName.length);
				}
				for ( let i: number = 0; i < this.SelectedFields.length; i++ )
				{
					let oReportField: ReportField = this.SelectedFields[i];
					sSQL += (i == 0 ? 'select ' : '     , ');
					if ( !Sql.IsEmptyString(oReportField.AggregateType) )
					{
						switch ( oReportField.AggregateType )
						{
							case 'group by'        :  sSQL += oReportField.FieldName + pad('', nMaxLen - oReportField.FieldName.length, ' ');  break;
							case 'avg'             :  sSQL += 'avg'    + '('          + oReportField.FieldName + ')';  break;
							case 'count'           :  sSQL += 'count'  + '('          + oReportField.FieldName + ')';  break;
							case 'min'             :  sSQL += 'min'    + '('          + oReportField.FieldName + ')';  break;
							case 'max'             :  sSQL += 'max'    + '('          + oReportField.FieldName + ')';  break;
							case 'stdev'           :  sSQL += 'stdev'  + '('          + oReportField.FieldName + ')';  break;
							case 'stdevp'          :  sSQL += 'stdevp' + '('          + oReportField.FieldName + ')';  break;
							case 'sum'             :  sSQL += 'sum'    + '('          + oReportField.FieldName + ')';  break;
							case 'var'             :  sSQL += 'var'    + '('          + oReportField.FieldName + ')';  break;
							case 'varp'            :  sSQL += 'varp'   + '('          + oReportField.FieldName + ')';  break;
							case 'avg distinct'    :  sSQL += 'avg'    + '(distinct ' + oReportField.FieldName + ')';  break;
							case 'count distinct'  :  sSQL += 'count'  + '(distinct ' + oReportField.FieldName + ')';  break;
							case 'stdev distinct'  :  sSQL += 'stdev'  + '(distinct ' + oReportField.FieldName + ')';  break;
							case 'stdevp distinct' :  sSQL += 'stdevp' + '(distinct ' + oReportField.FieldName + ')';  break;
							case 'sum distinct'    :  sSQL += 'sum'    + '(distinct ' + oReportField.FieldName + ')';  break;
							case 'var distinct'    :  sSQL += 'var'    + '(distinct ' + oReportField.FieldName + ')';  break;
							case 'varp distinct'   :  sSQL += 'varp'   + '(distinct ' + oReportField.FieldName + ')';  break;
							default                :  sSQL += '\'Unknown AggregateType\'';  break;
						}
					}
					else
					{
						sSQL += oReportField.FieldName + pad('', nMaxLen - oReportField.FieldName.length, ' ');
					}
					sSQL += ' as \"' + oReportField.FieldName + '\"';
					sSQL += CrLf;
				}
			}
			if ( this.Relationships.length == 0 )
			{
				sSQL += '  from vw' + this.Tables[0].TableName + ' ' + this.Tables[0].TableName + CrLf;
				oUsedTables[this.Tables[0].TableName] += 1;
			}
			else
			{
				for ( let i: number = 0; i < this.Relationships.length; i++ )
				{
					let sJoinType      : string = '';
					let sJoinTypeSpacer: string = '';
					let oReportRelationship: ReportRelationship = this.Relationships[i];
					switch ( oReportRelationship.JoinType )
					{
						case 'inner'      :  sJoinType = ' inner join '      ;  sJoinTypeSpacer = '        '      ;  break;
						case 'left outer' :  sJoinType = '  left outer join ';  sJoinTypeSpacer = '              ';  break;
						case 'right outer':  sJoinType = ' right outer join ';  sJoinTypeSpacer = '              ';  break;
						case 'full outer' :  sJoinType = '  full outer join ';  sJoinTypeSpacer = '              ';  break;
					}
					// 04/08/2020 Paul.  PreviewSQL may be called before the join tables have been specified. 
					if ( oReportRelationship.LeftTable == null || oReportRelationship.RightTable == null )
					{
						sErrors += L10n.Term('ReportDesigner.LBL_MISSING_JOIN_TABLE');
						if ( i == 0 )
						{
							sSQL += '  from vw' + this.Tables[0].TableName + ' ' + this.Tables[0].TableName + CrLf;
							oUsedTables[this.Tables[0].TableName] += 1;
						}
						continue;
					}
					if ( i == 0 )
					{
						if ( oReportRelationship.LeftTable != null && oReportRelationship.RightTable != null )
						{
							sSQL += '  from vw' + oReportRelationship.LeftTable.TableName + ' ' + oReportRelationship.LeftTable.TableName + CrLf;
							// 02/24/2015 Paul.  Need to prime the object list before incrementing. 
							if ( oUsedTables[oReportRelationship.LeftTable.TableName] === undefined )
								oUsedTables[oReportRelationship.LeftTable.TableName] = 0;
							oUsedTables[oReportRelationship.LeftTable.TableName] += 1;
							sSQL += sJoinType + 'vw' + oReportRelationship.RightTable.TableName + ' ' + oReportRelationship.RightTable.TableName + CrLf;
							// 02/24/2015 Paul.  Need to prime the object list before incrementing. 
							if ( oUsedTables[oReportRelationship.RightTable.TableName] === undefined )
								oUsedTables[oReportRelationship.RightTable.TableName] = 0;
							oUsedTables[oReportRelationship.RightTable.TableName] += 1;
							if ( oReportRelationship.JoinFields == null || oReportRelationship.JoinFields.length == 0 )
							{
								sErrors += L10n.Term('ReportDesigner.LBL_MISSING_JOIN_FIELDS').replace('{0}', oReportRelationship.LeftTable.TableName).replace('{1}', oReportRelationship.RightTable.TableName) + '<br />' + CrLf;
							}
							else
							{
								for ( let j: number = 0; j < oReportRelationship.JoinFields.length; j++ )
								{
									let oJoinField: ReportJoinField = oReportRelationship.JoinFields[j];
									if ( oJoinField.RightField != null && oJoinField.LeftField != null )
									{
										sSQL += sJoinTypeSpacer + (j == 0 ? ' on ' : 'and ') + oJoinField.RightField.FieldName + ' ' + oJoinField.OperatorType + ' ' + oJoinField.LeftField.FieldName + CrLf;
									}
								}
							}
						}
					}
					else if ( oUsedTables[oReportRelationship.LeftTable.TableName] > 0 && oUsedTables[oReportRelationship.RightTable.TableName] > 0 )
					{
						sErrors += L10n.Term('ReportDesigner.LBL_COMBINE_RELATIONSHIPS').replace('{0}', oReportRelationship.LeftTable.TableName).replace('{1}', oReportRelationship.RightTable.TableName) + '<br />' + CrLf;
					}
					else if ( oUsedTables[oReportRelationship.LeftTable.TableName] > 0 )
					{
						sSQL += sJoinType + 'vw' + oReportRelationship.RightTable.TableName + " " + oReportRelationship.RightTable.TableName + CrLf;
						// 02/24/2015 Paul.  Need to prime the object list before incrementing. 
						if ( oUsedTables[oReportRelationship.RightTable.TableName] === undefined )
							oUsedTables[oReportRelationship.RightTable.TableName] = 0;
						oUsedTables[oReportRelationship.RightTable.TableName] += 1;
						if ( oReportRelationship.JoinFields == null || oReportRelationship.JoinFields.length == 0 )
						{
							sErrors += L10n.Term('ReportDesigner.LBL_MISSING_JOIN_FIELDS').replace('{0}', oReportRelationship.LeftTable.TableName).replace('{1}', oReportRelationship.RightTable.TableName) + '<br />' + CrLf;
						}
						else
						{
							for ( let j: number = 0; j < oReportRelationship.JoinFields.length; j++ )
							{
								let oJoinField: ReportJoinField = oReportRelationship.JoinFields[j];
								if ( oJoinField.RightField != null && oJoinField.LeftField != null )
								{
									sSQL += sJoinTypeSpacer + (j == 0 ? ' on ' : 'and ') + oJoinField.RightField.FieldName + ' ' + oJoinField.OperatorType + ' ' + oJoinField.LeftField.FieldName + CrLf;
								}
							}
						}
					}
					else if ( oUsedTables[oReportRelationship.RightTable.TableName] > 0 )
					{
						// 01/06/2014 Paul.  If left table does not exist in query, then switch the join type. 
						switch ( oReportRelationship.JoinType )
						{
							case 'left outer' :  sJoinType = ' right outer join ';  break;
							case 'right outer':  sJoinType = '  left outer join ';  break;
						}
						sSQL += sJoinType + 'vw' + oReportRelationship.LeftTable.TableName + ' ' + oReportRelationship.LeftTable.TableName + CrLf;
						// 02/24/2015 Paul.  Need to prime the object list before incrementing. 
						if ( oUsedTables[oReportRelationship.LeftTable.TableName] === undefined )
							oUsedTables[oReportRelationship.LeftTable.TableName] = 0;
						oUsedTables[oReportRelationship.LeftTable.TableName] += 1;
						if ( oReportRelationship.JoinFields == null || oReportRelationship.JoinFields.length == 0 )
						{
							sErrors += L10n.Term('ReportDesigner.LBL_MISSING_JOIN_FIELDS').replace('{0}', oReportRelationship.LeftTable.TableName).replace('{1}', oReportRelationship.RightTable.TableName) + '<br />' + CrLf;
						}
						else
						{
							for ( let j: number = 0; j < oReportRelationship.JoinFields.length; j++ )
							{
								let oJoinField: ReportJoinField = oReportRelationship.JoinFields[j];
								if ( oJoinField.RightField != null && oJoinField.LeftField != null )
								{
									sSQL += sJoinTypeSpacer + (j == 0 ? ' on ' : 'and ') + oJoinField.RightField.FieldName + ' ' + oJoinField.OperatorType + ' ' + oJoinField.LeftField.FieldName + CrLf;
								}
							}
						}
					}
					else
					{
						alert(dumpObj(oUsedTables, null));
						alert('Missing case RightTable: ' + oReportRelationship.RightTable.TableName + ', LeftTable: ' + oReportRelationship.LeftTable.TableName);
					}
				}
			}
			if ( this.AppliedFilters.length > 0 )
			{
				// 07/17/2016 Paul.  Add support for changed to support workflow. 
				// Look for the first occurence of a changed field, then add the audit join. 
				for ( let i: number = 0; i < this.AppliedFilters.length; i++ )
				{
					let oReportFilter: ReportFilter = this.AppliedFilters[i];
					let field        : ModuleField  = oReportFilter.Field;
					// 07/17/2016 Paul.  Change event only applies to first table. 
					if ( oReportFilter.Operator == 'changed' && field.TableName == this.Tables[0].TableName )
					{
						//  left outer join vwACCOUNTS_AUDIT      ACCOUNTS_AUDIT_OLD
						//               on ACCOUNTS_AUDIT_OLD.ID = ACCOUNTS.ID
						//              and ACCOUNTS_AUDIT_OLD.AUDIT_VERSION = (select max(vwACCOUNTS_AUDIT.AUDIT_VERSION)
						//                                                  from vwACCOUNTS_AUDIT
						//                                                 where vwACCOUNTS_AUDIT.ID            =  ACCOUNTS.ID
						//                                                   and vwACCOUNTS_AUDIT.AUDIT_VERSION <  ACCOUNTS.AUDIT_VERSION
						//                                                   and vwACCOUNTS_AUDIT.AUDIT_TOKEN   <> ACCOUNTS.AUDIT_TOKEN
						//                                               )
						sSQL += '  left outer join vw' + field.TableName + '_AUDIT        '   + field.TableName + '_AUDIT_OLD' + CrLf;
						sSQL += '               on '   + field.TableName + '_AUDIT_OLD.ID = ' + field.TableName + '.ID' + CrLf;
						sSQL += '              and '   + field.TableName + '_AUDIT_OLD.AUDIT_VERSION = (select max(vw' + field.TableName + '_AUDIT.AUDIT_VERSION)' + CrLf;
						sSQL += '                                                  from vw' + field.TableName + '_AUDIT' + CrLf;
						sSQL += '                                                 where vw' + field.TableName + '_AUDIT.ID            =  ' + field.TableName + '.ID' + CrLf;
						sSQL += '                                                   and vw' + field.TableName + '_AUDIT.AUDIT_VERSION <  ' + field.TableName + '.AUDIT_VERSION' + CrLf;
						sSQL += '                                                   and vw' + field.TableName + '_AUDIT.AUDIT_TOKEN   <> ' + field.TableName + '.AUDIT_TOKEN' + CrLf;
						sSQL += '                                               )' + CrLf;
						break;
					}
				}
				for ( let i: number = 0; i < this.AppliedFilters.length; i++ )
				{
					let oReportFilter: ReportFilter = this.AppliedFilters[i];
					let field        : ModuleField  = oReportFilter.Field;
					if ( field == null )
					{
						sErrors += L10n.Term('ReportDesigner.LBL_MISSING_FILTER_FIELD').replace('{0}', i.toString()) + '<br />' + CrLf;
					}
					else if ( oReportFilter.Operator == null || oReportFilter.Operator == '' )
					{
						sErrors += L10n.Term('ReportDesigner.LBL_MISSING_FILTER_OPERATOR').replace('{0}', field.TableName + '.' + field.ColumnName) + '<br />' + CrLf;
					}
					// 07/17/2016 Paul.  Add support for changed to support workflow. 
					// 08/17/2018 Paul.  Need to include empty and not_empty for workflow mode. 
					else if ( oReportFilter.Value == null && (oReportFilter.Operator != 'empty' && oReportFilter.Operator != 'not_empty' && oReportFilter.Operator != 'is null' && oReportFilter.Operator != 'is not null' && oReportFilter.Operator != 'changed') && !oReportFilter.Parameter )
					{
						sErrors += L10n.Term('ReportDesigner.LBL_MISSING_FILTER_VALUE').replace('{0}', field.TableName + '.' + field.ColumnName) + '<br />' + CrLf;
					}
						// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
					else if ( (oReportFilter.Value == null || oReportFilter.Value === '') && (oReportFilter.IsNumericField() || oReportFilter.IsDateField() || oReportFilter.IsBooleanField()) && !oReportFilter.Parameter )
					{
						sErrors += L10n.Term('ReportDesigner.LBL_MISSING_FILTER_VALUE').replace('{0}', field.TableName + '.' + field.ColumnName) + '<br />' + CrLf;
					}
					else
					{
						if ( i == 0 )
							sSQL += ' where ';
						else
							sSQL += '   and ';
						// 07/17/2016 Paul.  Add support for changed to support workflow. 
						if ( oReportFilter.Operator == 'changed' )
						{
							// 07/17/2016 Paul.  Change event only applies to first table. 
							if ( field.TableName == this.Tables[0].TableName )
							{
								//   and (ACCOUNTS_AUDIT_OLD.AUDIT_ID is null or (not(ACCOUNTS.ASSIGNED_USER_ID is null and ACCOUNTS_AUDIT_OLD.ASSIGNED_USER_ID is null) and (ACCOUNTS.ASSIGNED_USER_ID <> ACCOUNTS_AUDIT_OLD.ASSIGNED_USER_ID or ACCOUNTS.ASSIGNED_USER_ID is null or ACCOUNTS_AUDIT_OLD.ASSIGNED_USER_ID is null)))
								sSQL += '(' + field.TableName + '_AUDIT_OLD.AUDIT_ID is null or (not(' + field.TableName + '.' + field.ColumnName + ' is null and ' + field.TableName + '_AUDIT_OLD.' + field.ColumnName + ' is null    ) and (' + field.TableName + '.' + field.ColumnName + ' <> ' + field.TableName + '_AUDIT_OLD.' + field.ColumnName + ' or ' + field.TableName + '.' + field.ColumnName + ' is null or ' + field.TableName + '_AUDIT_OLD.' + field.ColumnName + ' is null)))' + CrLf;
							}
						}
						// 02/11/2018 Paul.  Workflow mode uses older style of operators. 
						else if ( bReportDesignerWorkflowMode )
						{
							let bIsOracle        : boolean = false;
							let bIsDB2           : boolean = false;
							let bIsMySQL         : boolean = false;
							let bIsPostgreSQL    : boolean = false;
							let sCAT_SEP         : string  = (bIsOracle ? " || " : " + ");
							let sOPERATOR        : string  = oReportFilter.Operator;
							let sCOMMON_DATA_TYPE: string  = oReportFilter.Field.DataType.toLowerCase();
							if ( sCOMMON_DATA_TYPE == "ansistring" )
								sCOMMON_DATA_TYPE = "string";
							// 02/11/2018 Paul.  We need to determine if the string should be treated as a enum. 
							if ( oReportFilter.IsEnum() )
								sCOMMON_DATA_TYPE = "enum";
							let sSEARCH_TEXT1: string = '@' + field.ColumnName;
							switch ( sCOMMON_DATA_TYPE )
							{
								case "string":
								{
									switch ( sOPERATOR )
									{
										case "equals"         :  sSQL += field.TableName + '.' + field.ColumnName + " = "    + sSEARCH_TEXT1;  break;
										case "less"           :  sSQL += field.TableName + '.' + field.ColumnName + " < "    + sSEARCH_TEXT1;  break;
										case "less_equal"     :  sSQL += field.TableName + '.' + field.ColumnName + " <= "   + sSEARCH_TEXT1;  break;
										case "greater"        :  sSQL += field.TableName + '.' + field.ColumnName + " > "    + sSEARCH_TEXT1;  break;
										case "greater_equal"  :  sSQL += field.TableName + '.' + field.ColumnName + " >= "   + sSEARCH_TEXT1;  break;
										case "contains"       :  sSQL += field.TableName + '.' + field.ColumnName + " like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1 + sCAT_SEP + "N'%'";  break;
										case "starts_with"    :  sSQL += field.TableName + '.' + field.ColumnName + " like " +                     sSEARCH_TEXT1 + sCAT_SEP + "N'%'";  break;
										case "ends_with"      :  sSQL += field.TableName + '.' + field.ColumnName + " like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1;  break;
										case "like"           :  sSQL += field.TableName + '.' + field.ColumnName + " like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1 + sCAT_SEP + "N'%'";  break;
										case "empty"          :  sSQL += field.TableName + '.' + field.ColumnName + " is null"    ;  break;
										case "not_empty"      :  sSQL += field.TableName + '.' + field.ColumnName + " is not null";  break;
										// 10/25/2014 Paul.  Filters that use NOT should protect against NULL values. 
										case "not_equals_str" :  sSQL += 'coalesce(' + field.TableName + '.' + field.ColumnName + ", N'')" + " <> "   + sSEARCH_TEXT1;  break;
										case "not_contains"   :  sSQL += 'coalesce(' + field.TableName + '.' + field.ColumnName + ", N'')" + " not like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1 + sCAT_SEP + "N'%'";  break;
										case "not_starts_with":  sSQL += 'coalesce(' + field.TableName + '.' + field.ColumnName + ", N'')" + " not like " +                     sSEARCH_TEXT1 + sCAT_SEP + "N'%'";  break;
										case "not_ends_with"  :  sSQL += 'coalesce(' + field.TableName + '.' + field.ColumnName + ", N'')" + " not like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1;  break;
										case "not_like"       :  sSQL += 'coalesce(' + field.TableName + '.' + field.ColumnName + ", N'')" + " not like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1 + sCAT_SEP + "N'%'";  break;
									}
									break;
								}
								case "datetime":
								{
									let fnPrefix: string = "dbo.";
									if ( bIsOracle || bIsDB2 || bIsMySQL || bIsPostgreSQL )
									{
										fnPrefix = "";
									}
									switch ( sOPERATOR )
									{
										case "on"               :  sSQL += fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + ") = "  + sSEARCH_TEXT1;  break;
										case "before"           :  sSQL += fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + ") < "  + sSEARCH_TEXT1;  break;
										case "after"            :  sSQL += fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + ") > "  + sSEARCH_TEXT1;  break;
										case "not_equals_str"   :  sSQL += fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + ") <> " + sSEARCH_TEXT1;  break;
										case "between_dates"    :  sSQL += fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + ") between " + ' @' + field.ColumnName + '_AFTER' + " and " + '@' + field.ColumnName + '_BEFORE';  break;
										case "tp_days_after"    :  sSQL += "TODAY()"   + " > "       + fnPrefix + "fnDateAdd('day', "    +       sSEARCH_TEXT1        + ", " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + "))";  break;
										case "tp_weeks_after"   :  sSQL += "TODAY()"   + " > "       + fnPrefix + "fnDateAdd('week', "   +       sSEARCH_TEXT1        + ", " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + "))";  break;
										case "tp_months_after"  :  sSQL += "TODAY()"   + " > "       + fnPrefix + "fnDateAdd('month', "  +       sSEARCH_TEXT1        + ", " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + "))";  break;
										case "tp_years_after"   :  sSQL += "TODAY()"   + " > "       + fnPrefix + "fnDateAdd('year', "   +       sSEARCH_TEXT1        + ", " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + "))";  break;
										case "tp_days_before"   :  sSQL += "TODAY()"   + " between " + fnPrefix + "fnDateAdd('day', "    + "-" + sSEARCH_TEXT1        + ", " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + ")) and " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + ")";  break;
										case "tp_weeks_before"  :  sSQL += "TODAY()"   + " between " + fnPrefix + "fnDateAdd('week', "   + "-" + sSEARCH_TEXT1        + ", " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + ")) and " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + ")";  break;
										case "tp_months_before" :  sSQL += "TODAY()"   + " between " + fnPrefix + "fnDateAdd('month', "  + "-" + sSEARCH_TEXT1        + ", " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + ")) and " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + ")";  break;
										case "tp_years_before"  :  sSQL += "TODAY()"   + " between " + fnPrefix + "fnDateAdd('year', "   + "-" + sSEARCH_TEXT1        + ", " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + ")) and " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + ")";  break;
										case "tp_minutes_after" :  sSQL += "GETDATE()" + " between " + fnPrefix + "fnDateAdd('minute', " +       sSEARCH_TEXT1        + ", " + field.TableName + '.' + field.ColumnName                             + ") and " + fnPrefix + "fnDateAdd('minute', " + "1+" + sSEARCH_TEXT1 + ", " + field.TableName + '.' + field.ColumnName + ")";  break;
										case "tp_hours_after"   :  sSQL += "GETDATE()" + " between " + fnPrefix + "fnDateAdd('hour', "   +       sSEARCH_TEXT1        + ", " + field.TableName + '.' + field.ColumnName                             + ") and " + fnPrefix + "fnDateAdd('hour', "   + "1+" + sSEARCH_TEXT1 + ", " + field.TableName + '.' + field.ColumnName + ")";  break;
										case "tp_minutes_before":  sSQL += "GETDATE()" + " between " + fnPrefix + "fnDateAdd('minute', " + "-" + sSEARCH_TEXT1 + "-1" + ", " + field.TableName + '.' + field.ColumnName                             + ") and " + fnPrefix + "fnDateAdd('minute', " + "-"  + sSEARCH_TEXT1 + ", " + field.TableName + '.' + field.ColumnName + ")";  break;
										case "tp_hours_before"  :  sSQL += "GETDATE()" + " between " + fnPrefix + "fnDateAdd('hour', "   + "-" + sSEARCH_TEXT1 + "-1" + ", " + field.TableName + '.' + field.ColumnName                             + ") and " + fnPrefix + "fnDateAdd('hour', "   + "-"  + sSEARCH_TEXT1 + ", " + field.TableName + '.' + field.ColumnName + ")";  break;
										case "tp_days_old"      :  sSQL += "TODAY()"   + " = "       + fnPrefix + "fnDateAdd('day', "    +       sSEARCH_TEXT1        + ", " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + "))";  break;
										case "tp_weeks_old"     :  sSQL += "TODAY()"   + " = "       + fnPrefix + "fnDateAdd('week', "   +       sSEARCH_TEXT1        + ", " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + "))";  break;
										case "tp_months_old"    :  sSQL += "TODAY()"   + " = "       + fnPrefix + "fnDateAdd('month', "  +       sSEARCH_TEXT1        + ", " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + "))";  break;
										case "tp_years_old"     :  sSQL += "TODAY()"   + " = "       + fnPrefix + "fnDateAdd('year', "   +       sSEARCH_TEXT1        + ", " + fnPrefix + 'fnDateOnly(' + field.TableName + '.' + field.ColumnName + "))";  break;
									}
									break;
								}
								case "int32":
								{
									switch ( sOPERATOR )
									{
										case "equals"       :  sSQL += field.TableName + '.' + field.ColumnName + " = "    + sSEARCH_TEXT1;  break;
										case "less"         :  sSQL += field.TableName + '.' + field.ColumnName + " < "    + sSEARCH_TEXT1;  break;
										case "greater"      :  sSQL += field.TableName + '.' + field.ColumnName + " > "    + sSEARCH_TEXT1;  break;
										case "not_equals"   :  sSQL += field.TableName + '.' + field.ColumnName + " <> "   + sSEARCH_TEXT1;  break;
										case "between"      :  sSQL += field.TableName + '.' + field.ColumnName + " between "   + ' @' + field.ColumnName + '_AFTER' + " and " + '@' + field.ColumnName + '_BEFORE';  break;
										case "empty"        :  sSQL += field.TableName + '.' + field.ColumnName + " is null"    ;  break;
										case "not_empty"    :  sSQL += field.TableName + '.' + field.ColumnName + " is not null";  break;
										case "less_equal"   :  sSQL += field.TableName + '.' + field.ColumnName + " <= "    + sSEARCH_TEXT1;  break;
										case "greater_equal":  sSQL += field.TableName + '.' + field.ColumnName + " >= "    + sSEARCH_TEXT1;  break;
									}
									break;
								}
								case "decimal":
								{
									switch ( sOPERATOR )
									{
										case "equals"       :  sSQL += field.TableName + '.' + field.ColumnName + " = "    + sSEARCH_TEXT1;  break;
										case "less"         :  sSQL += field.TableName + '.' + field.ColumnName + " < "    + sSEARCH_TEXT1;  break;
										case "greater"      :  sSQL += field.TableName + '.' + field.ColumnName + " > "    + sSEARCH_TEXT1;  break;
										case "not_equals"   :  sSQL += field.TableName + '.' + field.ColumnName + " <> "   + sSEARCH_TEXT1;  break;
										case "between"      :  sSQL += field.TableName + '.' + field.ColumnName + " between "   + ' @' + field.ColumnName + '_AFTER' + " and " + '@' + field.ColumnName + '_BEFORE';  break;
										case "empty"        :  sSQL += field.TableName + '.' + field.ColumnName + " is null"    ;  break;
										case "not_empty"    :  sSQL += field.TableName + '.' + field.ColumnName + " is not null";  break;
										case "less_equal"   :  sSQL += field.TableName + '.' + field.ColumnName + " <= "    + sSEARCH_TEXT1;  break;
										case "greater_equal":  sSQL += field.TableName + '.' + field.ColumnName + " >= "    + sSEARCH_TEXT1;  break;
									}
									break;
								}
								case "float":
								{
									switch ( sOPERATOR )
									{
										case "equals"       :  sSQL += field.TableName + '.' + field.ColumnName + " = "    + sSEARCH_TEXT1;  break;
										case "less"         :  sSQL += field.TableName + '.' + field.ColumnName + " < "    + sSEARCH_TEXT1;  break;
										case "greater"      :  sSQL += field.TableName + '.' + field.ColumnName + " > "    + sSEARCH_TEXT1;  break;
										case "not_equals"   :  sSQL += field.TableName + '.' + field.ColumnName + " <> "   + sSEARCH_TEXT1;  break;
										case "between"      :  sSQL += field.TableName + '.' + field.ColumnName + " between "   + ' @' + field.ColumnName + '_AFTER' + " and " + '@' + field.ColumnName + '_BEFORE';  break;
										case "empty"        :  sSQL += field.TableName + '.' + field.ColumnName + " is null"    ;  break;
										case "not_empty"    :  sSQL += field.TableName + '.' + field.ColumnName + " is not null";  break;
										case "less_equal"   :  sSQL += field.TableName + '.' + field.ColumnName + " <= "    + sSEARCH_TEXT1;  break;
										case "greater_equal":  sSQL += field.TableName + '.' + field.ColumnName + " >= "    + sSEARCH_TEXT1;  break;
									}
									break;
								}
								case "bool":
								{
									switch ( sOPERATOR )
									{
										case "equals"    :  sSQL += field.TableName + '.' + field.ColumnName + " = "    + sSEARCH_TEXT1;  break;
										case "empty"     :  sSQL += field.TableName + '.' + field.ColumnName + " is null"    ;  break;
										case "not_empty" :  sSQL += field.TableName + '.' + field.ColumnName + " is not null";  break;
									}
									break;
								}
								case "guid":
								{
									switch ( sOPERATOR )
									{
										case "is"             :  sSQL += field.TableName + '.' + field.ColumnName + " = "    + sSEARCH_TEXT1;  break;
										case "equals"         :  sSQL += field.TableName + '.' + field.ColumnName + " = "    + sSEARCH_TEXT1;  break;
										case "contains"       :  sSQL += field.TableName + '.' + field.ColumnName + " like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1 + sCAT_SEP + "N'%'";  break;
										case "starts_with"    :  sSQL += field.TableName + '.' + field.ColumnName + " like " +                     sSEARCH_TEXT1 + sCAT_SEP + "N'%'";  break;
										case "ends_with"      :  sSQL += field.TableName + '.' + field.ColumnName + " like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1;  break;
										case "not_equals_str" :  sSQL += field.TableName + '.' + field.ColumnName + " <> "   + sSEARCH_TEXT1;  break;
										case "empty"          :  sSQL += field.TableName + '.' + field.ColumnName + " is null"    ;  break;
										case "not_empty"      :  sSQL += field.TableName + '.' + field.ColumnName + " is not null";  break;
										case "one_of"         :  sSQL += field.TableName + '.' + field.ColumnName + ' in (@' + field.ColumnName + ')';  break;
									}
									break;
								}
								case "enum":
								{
									switch ( sOPERATOR )
									{
										// 02/09/2007 Paul.  enum uses is instead of equals operator. 
										case "is"             :  sSQL += field.TableName + '.' + field.ColumnName + " = "   + sSEARCH_TEXT1;  break;
										case "one_of"         :  sSQL += field.TableName + '.' + field.ColumnName + ' in (@' + field.ColumnName + ')';  break;
										case "empty"          :  sSQL += field.TableName + '.' + field.ColumnName + " is null"    ;  break;
										case "not_empty"      :  sSQL += field.TableName + '.' + field.ColumnName + " is not null";  break;
									}
									break;
								}
							}
						}
						else if ( oReportFilter.Operator == 'is null' || oReportFilter.Operator == 'is not null' )
						{
							sSQL += field.TableName + '.' + field.ColumnName + ' ';
							sSQL += oReportFilter.Operator;
						}
						else if ( oReportFilter.Parameter )
						{
							if ( oReportFilter.Operator == 'in' )
							{
								sSQL += field.TableName + '.' + field.ColumnName + ' ';
								sSQL += oReportFilter.Operator;
								sSQL += ' (@' + field.ColumnName + ')';
							}
							else if ( oReportFilter.Operator == 'not in' )
							{
								// 10/25/2014 Paul.  Filters that use NOT should protect against NULL values. 
								sSQL += 'coalesce(' + field.TableName + '.' + field.ColumnName + ', N\'\') ';
								sSQL += oReportFilter.Operator;
								sSQL += ' (@' + field.ColumnName + ')';
							}
							else if ( oReportFilter.Operator == '<>' )
							{
								// 10/25/2014 Paul.  Filters that use NOT should protect against NULL values. 
								sSQL += 'coalesce(' + field.TableName + '.' + field.ColumnName + ', N\'\') ';
								sSQL += oReportFilter.Operator;
								sSQL += ' @' + field.ColumnName;
							}
							// 04/11/2016 Paul.  Special support for between clause as a parameter. Needed to be separated into 2 report parameters. 
							else if ( oReportFilter.Operator == 'between' )
							{
								sSQL += field.TableName + '.' + field.ColumnName + ' ';
								sSQL += oReportFilter.Operator;
								sSQL += ' @' + field.ColumnName + '_AFTER' + ' and ' + '@' + field.ColumnName + '_BEFORE';
							}
							else
							{
								sSQL += field.TableName + '.' + field.ColumnName + ' ';
								sSQL += oReportFilter.Operator;
								sSQL += ' @' + field.ColumnName;
							}
						}
						else if ( oReportFilter.Operator == 'in' )
						{
							if ( oReportFilter.Value != null && Array.isArray(oReportFilter.Value) )
							{
								sSQL += field.TableName + '.' + field.ColumnName + ' ';
								sSQL += oReportFilter.Operator + ' (';
								for ( let j: number = 0; j < oReportFilter.Value.length; j++ )
								{
									if ( j > 0 )
										sSQL += ', ';
									sSQL += oReportFilter.EscapedValue(oReportFilter.Value[j]);
								}
								sSQL += ')';
							}
							else
							{
								// 07/17/2016 Paul.  Allow the filter operator to be changed to a workflow version. 
								sErrors += L10n.Term('ReportDesigner.LBL_INVALID_ARRAY_VALUE').replace('{0}', field.TableName + '.' + field.ColumnName).replace('{1}', L10n.ListTerm(report_filter_operator_dom, oReportFilter.Operator)) + '<br />' + CrLf;
							}
						}
						else if ( oReportFilter.Operator == 'not in' )
						{
							if ( oReportFilter.Value != null && Array.isArray(oReportFilter.Value) )
							{
								// 10/25/2014 Paul.  Filters that use NOT should protect against NULL values. 
								sSQL += 'coalesce(' + field.TableName + '.' + field.ColumnName + ', N\'\') ';
								sSQL += oReportFilter.Operator + ' (';
								for ( let j: number = 0; j < oReportFilter.Value.length; j++ )
								{
									if ( j > 0 )
										sSQL += ', ';
									sSQL += oReportFilter.EscapedValue(oReportFilter.Value[j]);
								}
								sSQL += ')';
							}
							else
							{
								// 07/17/2016 Paul.  Allow the filter operator to be changed to a workflow version. 
								sErrors += L10n.Term('ReportDesigner.LBL_INVALID_ARRAY_VALUE').replace('{0}', field.TableName + '.' + field.ColumnName).replace('{1}', L10n.ListTerm(report_filter_operator_dom, oReportFilter.Operator)) + '<br />' + CrLf;
							}
						}
						// 02/24/2015 Paul.  Add support for between filter clause. 
						else if ( oReportFilter.Operator == 'between' )
						{
							if ( oReportFilter.Value != null && Array.isArray(oReportFilter.Value) && oReportFilter.Value.length >= 2 )
							{
								sSQL += field.TableName + '.' + field.ColumnName + ' ';
								sSQL += oReportFilter.Operator + ' ';
								sSQL += oReportFilter.EscapedValue(oReportFilter.Value[0]);
								sSQL += ' and ';
								sSQL += oReportFilter.EscapedValue(oReportFilter.Value[1]);
							}
							else
							{
								// 07/17/2016 Paul.  Allow the filter operator to be changed to a workflow version. 
								sErrors += L10n.Term('ReportDesigner.LBL_INVALID_ARRAY_VALUE').replace('{0}', field.TableName + '.' + field.ColumnName).replace('{1}', L10n.ListTerm(report_filter_operator_dom, oReportFilter.Operator)) + '<br />' + CrLf;
							}
						}
						else if ( oReportFilter.Value == null )
						{
							sErrors += L10n.Term('ReportDesigner.LBL_MISSING_FILTER_VALUE').replace('{0}', field.TableName + '.' + field.ColumnName) + '<br />' + CrLf;
						}
						else if ( oReportFilter.Operator == 'like' )
						{
							sSQL += field.TableName + '.' + field.ColumnName + ' ';
							sSQL += oReportFilter.Operator;
							sSQL += ' ';
							sSQL += oReportFilter.EscapedLikeValue(oReportFilter.Value);
						}
						else if ( oReportFilter.Operator == 'not like' )
						{
							// 10/25/2014 Paul.  Filters that use NOT should protect against NULL values. 
							sSQL += 'coalesce(' + field.TableName + '.' + field.ColumnName + ', N\'\') ';
							sSQL += oReportFilter.Operator;
							sSQL += ' ';
							sSQL += oReportFilter.EscapedLikeValue(oReportFilter.Value);
						}
						else if ( oReportFilter.Operator == '<>' )
						{
							// 10/25/2014 Paul.  Filters that use NOT should protect against NULL values. 
							sSQL += 'coalesce(' + field.TableName + '.' + field.ColumnName + ', N\'\') ';
							sSQL += oReportFilter.Operator;
							sSQL += ' ';
							sSQL += oReportFilter.EscapedValue(oReportFilter.Value);
						}
						else
						{
							sSQL += field.TableName + '.' + field.ColumnName + ' ';
							sSQL += oReportFilter.Operator;
							sSQL += ' ';
							sSQL += oReportFilter.EscapedValue(oReportFilter.Value);
						}
						sSQL += CrLf;
					}
				}
			}
			let nGroupBy: number = 0;
			for ( let i: number = 0; i < this.SelectedFields.length; i++ )
			{
				let oReportField: ReportField = this.SelectedFields[i];
				if ( !Sql.IsEmptyString(oReportField.AggregateType) )
				{
					if ( oReportField.AggregateType == 'group by' )
					{
						sSQL += (nGroupBy == 0 ? ' group by ' : ', ');
						sSQL += oReportField.FieldName;
						nGroupBy++;
					}
				}
			}
			if ( nGroupBy > 0 )
				sSQL += CrLf;
		
			let nOrderBy: number = 0;
			for ( let i: number = 0; i < this.SelectedFields.length; i++ )
			{
				let oReportField: ReportField = this.SelectedFields[i];
				if ( !Sql.IsEmptyString(oReportField.SortDirection) )
				{
					sSQL += (nOrderBy == 0 ? ' order by ' : ', ');
					if ( !Sql.IsEmptyString(oReportField.AggregateType) )
					{
						switch ( oReportField.AggregateType )
						{
							case 'group by'        :  sSQL +=                           oReportField.FieldName       + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'avg'             :  sSQL += 'avg'    + '('          + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'count'           :  sSQL += 'count'  + '('          + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'min'             :  sSQL += 'min'    + '('          + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'max'             :  sSQL += 'max'    + '('          + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'stdev'           :  sSQL += 'stdev'  + '('          + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'stdevp'          :  sSQL += 'stdevp' + '('          + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'sum'             :  sSQL += 'sum'    + '('          + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'var'             :  sSQL += 'var'    + '('          + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'varp'            :  sSQL += 'varp'   + '('          + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'avg distinct'    :  sSQL += 'avg'    + '(distinct ' + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'count distinct'  :  sSQL += 'count'  + '(distinct ' + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'stdev distinct'  :  sSQL += 'stdev'  + '(distinct ' + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'stdevp distinct' :  sSQL += 'stdevp' + '(distinct ' + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'sum distinct'    :  sSQL += 'sum'    + '(distinct ' + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'var distinct'    :  sSQL += 'var'    + '(distinct ' + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
							case 'varp distinct'   :  sSQL += 'varp'   + '(distinct ' + oReportField.FieldName + ')' + ' ' + oReportField.SortDirection;  nOrderBy++;  break;
						}
					}
					else
					{
						sSQL += oReportField.FieldName + ' ' + oReportField.SortDirection;
						nOrderBy++;
					}
				}
			}
			if ( nOrderBy > 0 )
				sSQL += CrLf;
		
			let sUnusedTables: string = '';
			for ( let sTableName in oUsedTables )
			{
				if ( oUsedTables[sTableName] == 0 )
				{
					if ( sUnusedTables.length > 0 )
						sUnusedTables += ', ';
					sUnusedTables += sTableName;
				}
			}
			if ( sUnusedTables.length > 0 )
			{
				sErrors += L10n.Term('ReportDesigner.LBL_UNRELATED_ERROR').replace('{0}', sUnusedTables);
			}
		}
		let sJSON: string = this.Stringify();
		// 05/18/2020 Paul.  Although it seems strange to stringify and the JSON.parse, the purpose is to exclude functions. 
		let sJsonDump: string = dumpObj(JSON.parse(sJSON), '').replace(/\n/g, '<br>\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
		return { sSQL, sJSON, sJsonDump, sErrors };
	}

}

