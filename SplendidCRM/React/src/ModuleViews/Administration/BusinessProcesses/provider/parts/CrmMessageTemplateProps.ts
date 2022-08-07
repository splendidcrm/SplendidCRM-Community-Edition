/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
import Sql  from '../../../../../scripts/Sql' ;
import L10n from '../../../../../scripts/L10n';

var find                  = require('lodash/collection/find');
var entryFactory          = require('bpmn-js-properties-panel/lib/factory/EntryFactory');
var is                    = require('bpmn-js/lib/util/ModelUtil').is;
var getBusinessObject     = require('bpmn-js/lib/util/ModelUtil').getBusinessObject;
var cmdHelper             = require('bpmn-js-properties-panel/lib/helper/CmdHelper');
var eventDefinitionHelper = require('bpmn-js-properties-panel/lib/helper/EventDefinitionHelper');
import popupEntryFactory  from './factory/ModulePopupEntryFactory';

function ensureNotNull(prop)
{
	if ( !prop )
	{
		throw new Error(prop + ' must be set.');
	}
	return prop;
}

function hasEventDefinition(element, eventDefinition)
{
	var bo = getBusinessObject(element);
	return !!find(bo.eventDefinitions || [], function(definition) { return is(definition, eventDefinition); });
}

// 09/08/2021 Paul.  Include the eventBus
export default function(group, element, bpmnFactory, elementRegistry, eventBus)
{
	if ( (is(element, 'bpmn:IntermediateThrowEvent') || is(element, 'bpmn:EndEvent')) && hasEventDefinition(element, 'bpmn:MessageEventDefinition') )
	{
		var workflow_alert_type_dom = L10n.GetList('workflow_alert_type_dom');
		var arrAlertTypes = new Array();
		for ( var i = 0; i < workflow_alert_type_dom.length; i++ )
		{
			let type: any = new Object();
			arrAlertTypes.push(type);
			type.value = workflow_alert_type_dom[i];
			type.name  = L10n.Term('.workflow_alert_type_dom.' + workflow_alert_type_dom[i]);
		}

		group.entries.push(entryFactory.selectBox(
		{
			id            : 'ALERT_TYPE',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_ALERT_TYPE'),
			modelProperty : 'ALERT_TYPE',
			emptyParameter: false,
			selectOptions : arrAlertTypes,
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				var messageEventDefinition = eventDefinitionHelper.getMessageEventDefinition(element);
				res[prop] = messageEventDefinition.get(prop);
				return res;
			},
			set : function(element, values)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
				}
				else
				{
					res[prop] = undefined;
				}
				// Set to child Message element. 
				var messageEventDefinition = eventDefinitionHelper.getMessageEventDefinition(element);
				return cmdHelper.updateBusinessObject(element, messageEventDefinition, res);
			}
		}));

		// 09/08/2021 Paul.  Include the eventBus
		group.entries.push(popupEntryFactory(
		{
			id            : 'ASSIGNED_USER_',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_MESSAGE_ASSIGNED_TO'),
			modelProperty : 'ASSIGNED_USER_',
			module        : 'Users',
			show : function(element, node)
			{
				var prop = 'ALERT_TYPE';
				var messageEventDefinition = eventDefinitionHelper.getMessageEventDefinition(element);
				return messageEventDefinition && messageEventDefinition.get(prop) != 'Notification';
			},
			validate : function(element)
			{
				return [];
			}
		}, element, bpmnFactory, eventBus));

		// 09/08/2021 Paul.  Include the eventBus
		group.entries.push(popupEntryFactory(
		{
			id            : 'TEAM_',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_MESSAGE_TEAM'),
			modelProperty : 'TEAM_',
			module        : 'Teams',
			show : function(element, node)
			{
				var prop = 'ALERT_TYPE';
				var messageEventDefinition = eventDefinitionHelper.getMessageEventDefinition(element);
				return messageEventDefinition && messageEventDefinition.get(prop) != 'Notification';
			},
			validate : function(element)
			{
				return [];
			}
		}, element, bpmnFactory, eventBus));

		var workflow_source_type_dom = L10n.GetList('workflow_source_type_dom');
		var arrSourceType = new Array();
		for ( var i = 0; i < workflow_source_type_dom.length; i++ )
		{
			let type: any = new Object();
			arrSourceType.push(type);
			type.value = workflow_source_type_dom[i];
			type.name  = L10n.Term('.workflow_source_type_dom.' + workflow_source_type_dom[i]);
		}

		group.entries.push(entryFactory.selectBox(
		{
			id            : 'SOURCE_TYPE',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_SOURCE_TYPE'),
			modelProperty : 'SOURCE_TYPE',
			emptyParameter: false,
			selectOptions : arrSourceType,
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				var messageEventDefinition = eventDefinitionHelper.getMessageEventDefinition(element);
				res[prop] = messageEventDefinition.get(prop);
				return res;
			},
			set : function(element, values)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
				}
				else
				{
					res[prop] = undefined;
				}
				// Set to child Message element. 
				var commands = [];
				var messageEventDefinition = eventDefinitionHelper.getMessageEventDefinition(element);
				if ( messageEventDefinition )
				{
					var oldProp = messageEventDefinition.get(prop);
					if ( oldProp != values[prop] )
						commands.push(cmdHelper.updateBusinessObject(element, messageEventDefinition, { CUSTOM_TEMPLATE_ID: undefined, CUSTOM_TEMPLATE_NAME: undefined, ALERT_TEXT: undefined }));
				}
				commands.push(cmdHelper.updateBusinessObject(element, messageEventDefinition, res));
				return commands;
			}
		}));

		// 09/08/2021 Paul.  Include the eventBus
		group.entries.push(popupEntryFactory(
		{
			id            : 'CUSTOM_TEMPLATE_',
			//description   : L10n.Term('BusinessProcesses.LBL_BPMN_MESSAGE_TEMPLATE_DESCRIPTION'),
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_MESSAGE_TEMPLATE'),
			modelProperty : 'CUSTOM_TEMPLATE_',
			module        : 'WorkflowAlertTemplates',
			show : function(element, node)
			{
				var prop = 'SOURCE_TYPE';
				var messageEventDefinition = eventDefinitionHelper.getMessageEventDefinition(element);
				return messageEventDefinition && messageEventDefinition.get(prop) == 'custom template';
			}
		}, element, bpmnFactory, eventBus));

		// 05/10/2022 Paul.  textField is not following the show rules, so change to textBox. 
		group.entries.push(entryFactory.textBox(
		{
			id            : 'ALERT_SUBJECT',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_ALERT_SUBJECT'),
			modelProperty : 'ALERT_SUBJECT',
			show : function(element, node)
			{
				var prop = 'SOURCE_TYPE';
				var messageEventDefinition = eventDefinitionHelper.getMessageEventDefinition(element);
				return messageEventDefinition && messageEventDefinition.get(prop) != 'custom template';
			},
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				var messageEventDefinition = eventDefinitionHelper.getMessageEventDefinition(element);
				res[prop] = messageEventDefinition.get(prop);
				return res;
			},
			set : function(element, values)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
				}
				else
				{
					res[prop] = undefined;
				}
				// Set to child Message element. 
				var messageEventDefinition = eventDefinitionHelper.getMessageEventDefinition(element);
				return cmdHelper.updateBusinessObject(element, messageEventDefinition, res);
			},
			validate : function(element)
			{
				var value = this.get(element)[this.id];
				if ( Sql.ToString(value) == '' )
				{
					var err = new Object();
					err[this.id] = L10n.Term('.ERR_REQUIRED_FIELD');
					return err;
				}
			}
		}));

		// 05/10/2022 Paul.  Changed to textBox. 
		group.entries.push(entryFactory.textBox(
		{
			id            : 'ALERT_TEXT',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_ALERT_TEXT'),
			modelProperty : 'ALERT_TEXT',
			show : function(element, node)
			{
				var prop = 'SOURCE_TYPE';
				var messageEventDefinition = eventDefinitionHelper.getMessageEventDefinition(element);
				return messageEventDefinition && messageEventDefinition.get(prop) != 'custom template';
			},
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				var messageEventDefinition = eventDefinitionHelper.getMessageEventDefinition(element);
				res[prop] = messageEventDefinition.get(prop);
				return res;
			},
			set : function(element, values)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
				}
				else
				{
					res[prop] = undefined;
				}
				// Set to child Message element. 
				var messageEventDefinition = eventDefinitionHelper.getMessageEventDefinition(element);
				return cmdHelper.updateBusinessObject(element, messageEventDefinition, res);
			},
			validate : function(element)
			{
				var value = this.get(element)[this.id];
				if ( Sql.ToString(value) == '' )
				{
					var err = new Object();
					err[this.id] = L10n.Term('.ERR_REQUIRED_FIELD');
					return err;
				}
			}
		}));

	}
};
