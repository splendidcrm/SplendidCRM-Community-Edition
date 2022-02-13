/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
import Sql           from '../../../../../scripts/Sql' ;
import L10n          from '../../../../../scripts/L10n';
import SplendidCache from  '../../../../../scripts/SplendidCache';

var entryFactory          = require('bpmn-js-properties-panel/lib/factory/EntryFactory');
var cmdHelper             = require('bpmn-js-properties-panel/lib/helper/CmdHelper');
var getBusinessObject     = require('bpmn-js/lib/util/ModelUtil').getBusinessObject;
var is                    = require('bpmn-js/lib/util/ModelUtil').is;
import queryEntryFactory  from './factory/QueryEntryFactory';

function ensureNotNull(prop)
{
	if ( !prop )
	{
		throw new Error(prop + ' must be set.');
	}
	return prop;
}

// 09/08/2021 Paul.  Include the eventBus
export default function(group, element, bpmnFactory, elementRegistry, eventBus)
{
	if ( is(element, 'bpmn:StartEvent') )
	{
		let designerModules = SplendidCache.GetReportDesignerModules();
		var arrSelectOptions = new Array();
		arrSelectOptions.push( { name: '', value: '' } );
		for ( var i = 0; i < designerModules.arrReportDesignerModules.length; i++ )
		{
			let option: any = new Object();
			option.value = designerModules.arrReportDesignerModules[i].ModuleName;
			// 07/05/2016 Paul.  The display name is already translated by the Rest.svc call. 
			option.name  = designerModules.arrReportDesignerModules[i].DisplayName;
			arrSelectOptions.push(option);
		}
		group.entries.push(entryFactory.selectBox(
		{
			id            : 'BASE_MODULE',
			//description   : L10n.Term('BusinessProcesses.LBL_BPMN_BASE_MODULE_DESCRIPTION'),
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_BASE_MODULE'),
			modelProperty : 'BASE_MODULE',
			selectOptions : arrSelectOptions,
			get : function (element)
			{
				var businessObject = getBusinessObject(element);
				var res = {};
				var prop = ensureNotNull(this.id);
				res[prop] = businessObject.get(prop);
				//console.log('CrmModuleFilterProps get ' + prop + ' = ' + res[prop]);
				return res;
			},
			set : function (element, values)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
					var module = designerModules.FindModuleByName(res[prop]);
					if ( module != null )
					{
						var CrLf            = '\r\n';
						let txtCamundaJSON: any = document.getElementById('camunda-' + 'MODULE_FILTER_JSON');
						let txtCamundaSQL : any = document.getElementById('camunda-' + 'MODULE_FILTER_SQL' );
						if ( txtCamundaSQL != null )
						{
							txtCamundaSQL.innerHTML = 'select ' + module.TableName + '.ID' + CrLf + '  from vw' + module.TableName + ' ' + module.TableName;
						}
						if ( txtCamundaJSON != null )
						{
							txtCamundaJSON.value = '{ "GroupAndAggregate": false, "Tables": [ { "ModuleName": "' + module.ModuleName + '", "TableName": "' + module.TableName + '"} ], "SelectedFields": [ { "TableName": "' + module.TableName + '", "ColumnName": "ID", "FieldName": "' + module.TableName + '.ID' + '", "DisplayName": "' + module.ModuleName + ' ID' + '", "AggregateType": null, "DisplayWidth": null, "SortDirection": null } ] }';
							if ( document.createEvent )
							{
								var evt = document.createEvent('HTMLEvents');
								evt.initEvent('change', true, false);
								txtCamundaJSON.dispatchEvent(evt);
							}
							else if ( txtCamundaJSON.fireEvent )
							{
								txtCamundaJSON.fireEvent('onChange');
							}
						}
					}
				}
				else
				{
					res[prop] = undefined;
				}
				//console.log('CrmModuleFilterProps set ' + prop + ' = ' + res[prop]);
				return cmdHelper.updateProperties(element, res);
			},
			validate: function(element)
			{
				var value = this.get(element)[this.id];
				if ( Sql.ToString(value) == '' )
				{
					var err = new Object();
					err[this.id] = L10n.Term('.ERR_REQUIRED_FIELD');
					return err;
				}
			},
		}));
		
		// 09/08/2021 Paul.  Include the eventBus
		group.entries.push(queryEntryFactory(
		{
			id           : 'MODULE_FILTER',
			//description   : L10n.Term('BusinessProcesses.LBL_BPMN_MODULE_FILTER_DESCRIPTION'),
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_MODULE_FILTER'),
			modelProperty: 'MODULE_FILTER',
		}, element, bpmnFactory, eventBus));
	}
};
