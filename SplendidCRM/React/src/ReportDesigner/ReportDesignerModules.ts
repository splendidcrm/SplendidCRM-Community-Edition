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
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'                ;
import L10n                                         from '../scripts/L10n'               ;
import Credentials                                  from '../scripts/Credentials'        ;
import SplendidCache                                from '../scripts/SplendidCache'      ;
import { AuthenticatedMethod, LoginRedirect }       from '../scripts/Login'              ;
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest'    ;

let bDebug: boolean = false;

export class ModuleField
{
	public ColumnName       : string ;
	public ColumnType       : string ;
	public DataType         : string ;
	public DataLength       : number ;
	public Precision        : number ;
	public MaxLength        : number ;
	public DisplayName      : string ;
	public TableName        : string ;
	// 01/05/2014 Paul.  Linking back to the original module causes an Out of stack space error.
	public Module           : ReportModule;
}

export class ReportModule
{
	public ModuleName       : string ;
	public DisplayName      : string ;
	public TableName        : string ;
	public PrimaryField     : string ;
	public Relationship     : boolean;
	public CustomReportView : boolean;
	public Fields           : Array<ModuleField>;
}

export class ReportDesignerModules
{
	public arrReportDesignerModules: Array<ReportModule>;

	public constructor()
	{
		this.arrReportDesignerModules = [];
	}

	public load = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load');
		try
		{
			let res  = await CreateSplendidRequest('ReportDesigner/Rest.svc/GetModules', 'GET');
			let json = await GetSplendidResult(res);
			for ( let i: number = 0; i < json.d.results.length; i++ )
			{
				let module: ReportModule = json.d.results[i];
				for ( let j: number = 0; j < module.Fields.length; j++ )
				{
					let field: ModuleField = module.Fields[j];
					// 01/05/2014 Paul.  Linking back to the original module causes an Out of stack space error.
					field.Module = new ReportModule();
					field.Module.ModuleName  = module.ModuleName ;
					field.Module.DisplayName = module.DisplayName;
					field.Module.TableName   = module.TableName  ;
					/*
					// 07/04/2016 Paul.  Special case when not showing selected fields. 
					if ( !bReportDesignerWorkflowMode )
					{
						var oFieldNode = new Object();
						oFieldNode.Field = field;
						oFieldNode.name  = field.DisplayName;
						// 08/03/2014 Paul.  The full name will be used when selecting nodes during the load operation. 
						oFieldNode.FieldName = field.TableName + '.' + field.ColumnName;
						if ( bDebug )
							oFieldNode.name += ' (' + field.TableName + '.' + field.ColumnName + ')';
						oModuleNode.children.push(oFieldNode);
					}
					*/
				}
				this.arrReportDesignerModules.push(module);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			throw(error);
		}
	}


	public FindModuleByTable(sTableName: string): ReportModule
	{
		if ( this.arrReportDesignerModules != null )
		{
			for ( let i: number = 0; i < this.arrReportDesignerModules.length; i++ )
			{
				if ( sTableName == this.arrReportDesignerModules[i].TableName )
				{
					return this.arrReportDesignerModules[i];
				}
			}
		}
		return null;
	}

	public FindModuleByName(sModuleName: string): ReportModule
	{
		if ( this.arrReportDesignerModules != null )
		{
			for ( let i: number = 0; i < this.arrReportDesignerModules.length; i++ )
			{
				if ( sModuleName == this.arrReportDesignerModules[i].ModuleName )
				{
					return this.arrReportDesignerModules[i];
				}
			}
		}
		return null;
	}

	// 07/11/2016 Paul.  Find field by table or module. 
	public FindFieldByTable(sTableName: string, sColumnName: string): ModuleField
	{
		if ( this.arrReportDesignerModules != null )
		{
			let module: ReportModule = this.FindModuleByTable(sTableName);
			if ( module != null )
			{
				let arrFields: Array<ModuleField> = module.Fields;
				for ( let j: number = 0; j < arrFields.length; j++ )
				{
					if ( sColumnName == arrFields[j].ColumnName )
					{
						return arrFields[j];
					}
				}
			}
		}
		return null;
	}

	public FindFieldByModule(sModuleName: string, sColumnName: string): ModuleField
	{
		if ( this.arrReportDesignerModules != null )
		{
			let module: ReportModule = this.FindModuleByName(sModuleName);
			if ( module != null )
			{
				let arrFields: Array<ModuleField> = module.Fields;
				for ( let j: number = 0; j < arrFields.length; j++ )
				{
					if ( sColumnName == arrFields[j].ColumnName )
					{
						return arrFields[j];
					}
				}
			}
		}
		return null;
	}

}

