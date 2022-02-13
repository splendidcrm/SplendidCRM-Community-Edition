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

var getBusinessObject     = require('bpmn-js/lib/util/ModelUtil').getBusinessObject;
var getExtensionElements  = require('bpmn-js-properties-panel/lib/helper/ExtensionElementsHelper').getExtensionElements;
var extensionElements     = require('bpmn-js-properties-panel/lib/provider/camunda/parts/implementation/ExtensionElements');
var properties            = require('bpmn-js-properties-panel/lib/provider/camunda/parts//implementation/Properties');
var elementHelper         = require('bpmn-js-properties-panel/lib/helper/ElementHelper');
var cmdHelper             = require('bpmn-js-properties-panel/lib/helper/CmdHelper');
var is                    = require('bpmn-js/lib/util/ModelUtil').is;
var find                  = require('lodash/collection/find');
import readOnlyFields     from './factory/ReadOnlyFields';
import requiredFields     from './factory/RequiredFields';

function findProcess(element)
{
	while ( element.parent )
	{
		if ( is(element.parent, 'bpmn:Process') )
		{
			return element.parent;
		}
		element = element.parent;
	}
	return null;
}

function findStartEvent(process)
{
	var startEvent = null;
	for ( var i = 0; i < process.children.length; i++ )
	{
		var element = process.children[i];
		if ( is(element, 'bpmn:StartEvent') )
		{
			startEvent = element;
			break;
		}
	}
	return startEvent;
}

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
	if ( is(element, 'bpmn:UserTask') )
	{
		var sBaseModule = null;
		var process = findProcess(element);
		if ( process )
		{
			var startEvent = findStartEvent(process);
			if ( startEvent != null )
			{
				var businessObject = getBusinessObject(startEvent);
				sBaseModule = businessObject.get('BASE_MODULE');
			}
		}

		let designerModules = SplendidCache.GetReportDesignerModules();
		var module_fields = new Array();
		var module = designerModules.FindModuleByName(sBaseModule);
		if ( module != null )
		{
			var arrFields = module.Fields;
			for ( var j = 0; j < arrFields.length; j++ )
			{
				let field: any = new Object();
				field.value = arrFields[j].ColumnName ;
				field.name  = arrFields[j].DisplayName;
				module_fields.push(field);
			}
		}

		group.entries.push(readOnlyFields(element, bpmnFactory,
		{
			id              : 'READ_ONLY_FIELDS',
			modelProperties : [ 'name' ],
			labels          : [  L10n.Term('BusinessProcesses.LBL_BPMN_MODULE_FIELD') ],
			listValues      : [ module_fields ],
			getParent: function(element, node)
			{
				var bo = getBusinessObject(element);
				return bo.extensionElements;
			},
			createParent: function(element)
			{
				var bo = getBusinessObject(element);
				var parent = elementHelper.createElement('bpmn:ExtensionElements', { values: [] }, bo, bpmnFactory);
				var cmd = cmdHelper.updateProperties(element, { extensionElements: parent });
				return { cmd: cmd, parent: parent };
			},
		}));

		group.entries.push(requiredFields(element, bpmnFactory,
		{
			id              : 'REQUIRED_FIELDS',
			modelProperties : [ 'name' ],
			labels          : [  L10n.Term('BusinessProcesses.LBL_BPMN_MODULE_FIELD') ],
			listValues      : [ module_fields ],
			getParent: function(element, node)
			{
				var bo = getBusinessObject(element);
				return bo.extensionElements;
			},
			createParent: function(element)
			{
				var bo = getBusinessObject(element);
				var parent = elementHelper.createElement('bpmn:ExtensionElements', { values: [] }, bo, bpmnFactory);
				var cmd = cmdHelper.updateProperties(element, { extensionElements: parent });
				return { cmd: cmd, parent: parent };
			},
		}));
	}
};
