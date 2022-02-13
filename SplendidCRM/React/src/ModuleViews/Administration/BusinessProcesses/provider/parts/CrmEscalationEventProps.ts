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
	if ( is(element, 'bpmn:IntermediateThrowEvent') && hasEventDefinition(element, 'bpmn:EscalationEventDefinition') )
	{
		group.entries.push(entryFactory.textField(
		{
			id            : 'APPROVAL_VARIABLE_NAME',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_APPROVAL_VARIABLE_NAME'),
			modelProperty : 'APPROVAL_VARIABLE_NAME',
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				res[prop] = escalationEventDefinition.get(prop);
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
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return cmdHelper.updateBusinessObject(element, escalationEventDefinition, res);
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

		// Approve/Reject, Route
		var bpmn_escalation_type = L10n.GetList('bpmn_escalation_type');
		var arrEscalationType = new Array();
		for ( var i = 0; i < bpmn_escalation_type.length; i++ )
		{
			let type: any = new Object();
			arrEscalationType.push(type);
			type.value = bpmn_escalation_type[i];
			type.name  = L10n.Term('.bpmn_escalation_type.' + bpmn_escalation_type[i]);
		}

		group.entries.push(entryFactory.selectBox(
		{
			id            : 'ESCALATION_TYPE',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_ESCALATION_TYPE'),
			modelProperty : 'ESCALATION_TYPE',
			emptyParameter: false,
			selectOptions : arrEscalationType,
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				res[prop] = escalationEventDefinition.get(prop);
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
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return cmdHelper.updateBusinessObject(element, escalationEventDefinition, res);
			}
		}));

		group.entries.push(entryFactory.checkbox(
		{
			id            : 'CHANGE_ASSIGNED_USER',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_CHANGE_ASSIGNED_USER'),
			modelProperty : 'CHANGE_ASSIGNED_USER',
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				res[prop] = escalationEventDefinition.get(prop);
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
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return cmdHelper.updateBusinessObject(element, escalationEventDefinition, res);
			}
		}));

		// 09/08/2021 Paul.  Include the eventBus
		group.entries.push(popupEntryFactory(
		{
			id            : 'CHANGE_ASSIGNED_TEAM_',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_CHANGE_ASSIGNED_TEAM'),
			modelProperty : 'CHANGE_ASSIGNED_TEAM_',
			module        : 'Teams',
			show : function(element, node)
			{
				var prop = 'CHANGE_ASSIGNED_USER';
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return escalationEventDefinition && escalationEventDefinition.get(prop) == true;
			},
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.modelProperty + 'ID');
		
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				res[prop] = escalationEventDefinition.get(prop);

				prop = ensureNotNull(this.modelProperty + 'NAME');
				res[prop] = escalationEventDefinition.get(prop);
				return res;
			},
			set : function(element, values)
			{
				var res = {};
				var prop = ensureNotNull(this.modelProperty + 'ID');
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
				}
				else
				{
					res[prop] = undefined;
				}
				prop = ensureNotNull(this.modelProperty + 'NAME');
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
				}
				else
				{
					res[prop] = undefined;
				}
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return cmdHelper.updateBusinessObject(element, escalationEventDefinition, res);
			},
			validate : function(element)
			{
				var value = this.get(element)[this.id + 'ID'];
				if ( Sql.ToString(value) == '' )
				{
					var err = new Object();
					err[this.id + 'ID'  ] = L10n.Term('.ERR_REQUIRED_FIELD');
					err[this.id + 'NAME'] = L10n.Term('.ERR_REQUIRED_FIELD');
					return err;
				}
			}
		}, element, bpmnFactory, eventBus));

		group.entries.push(entryFactory.checkbox(
		{
			id            : 'CHANGE_PROCESS_USER',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_CHANGE_PROCESS_USER'),
			modelProperty : 'CHANGE_PROCESS_USER',
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				res[prop] = escalationEventDefinition.get(prop);
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
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return cmdHelper.updateBusinessObject(element, escalationEventDefinition, res);
			}
		}));

		// 09/08/2021 Paul.  Include the eventBus
		group.entries.push(popupEntryFactory(
		{
			id            : 'CHANGE_PROCESS_TEAM_',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_CHANGE_PROCESS_TEAM'),
			modelProperty : 'CHANGE_PROCESS_TEAM_',
			module        : 'Teams',
			show : function(element, node)
			{
				var prop = 'CHANGE_PROCESS_USER';
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return escalationEventDefinition && escalationEventDefinition.get(prop) == true;
			},
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.modelProperty + 'ID');
		
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				res[prop] = escalationEventDefinition.get(prop);

				prop = ensureNotNull(this.modelProperty + 'NAME');
				res[prop] = escalationEventDefinition.get(prop);
				return res;
			},
			set : function(element, values)
			{
				var res = {};
				var prop = ensureNotNull(this.modelProperty + 'ID');
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
				}
				else
				{
					res[prop] = undefined;
				}
				prop = ensureNotNull(this.modelProperty + 'NAME');
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
				}
				else
				{
					res[prop] = undefined;
				}
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return cmdHelper.updateBusinessObject(element, escalationEventDefinition, res);
			},
			validate : function(element)
			{
				var value = this.get(element)[this.id + 'ID'];
				if ( Sql.ToString(value) == '' )
				{
					var err = new Object();
					err[this.id + 'ID'  ] = L10n.Term('.ERR_REQUIRED_FIELD');
					err[this.id + 'NAME'] = L10n.Term('.ERR_REQUIRED_FIELD');
					return err;
				}
			}
		}, element, bpmnFactory, eventBus));

		// Current Process User, Record Owner, Supervisor, Static User, Round Robin Team, Round Robin Role, Self-Service Team, Self-Service Role
		var bpmn_user_assignment_method = L10n.GetList('bpmn_user_assignment_method');
		var arrUserAssignmentMethod = new Array();
		for ( var i = 0; i < bpmn_user_assignment_method.length; i++ )
		{
			let type: any = new Object();
			arrUserAssignmentMethod.push(type);
			type.value = bpmn_user_assignment_method[i];
			type.name  = L10n.Term('.bpmn_user_assignment_method.' + bpmn_user_assignment_method[i]);
		}

		group.entries.push(entryFactory.selectBox(
		{
			id            : 'USER_ASSIGNMENT_METHOD',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_USER_ASSIGNMENT_METHOD'),
			modelProperty : 'USER_ASSIGNMENT_METHOD',
			emptyParameter: false,
			selectOptions : arrUserAssignmentMethod,
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				res[prop] = escalationEventDefinition.get(prop);
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
				var commands = [];
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				if ( escalationEventDefinition )
				{
					var oldProp = escalationEventDefinition.get(prop);
					if ( oldProp != values[prop] )
						commands.push(cmdHelper.updateBusinessObject(element, escalationEventDefinition, { CUSTOM_TEMPLATE_ID: undefined, CUSTOM_TEMPLATE_NAME: undefined, ALERT_TEXT: undefined }));
				}
				commands.push(cmdHelper.updateBusinessObject(element, escalationEventDefinition, res));
				return commands;
			}
		}));

		// 09/08/2021 Paul.  Include the eventBus
		group.entries.push(popupEntryFactory(
		{
			id            : 'STATIC_ASSIGNED_USER_',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_STATIC_ASSIGNED_USER'),
			modelProperty : 'STATIC_ASSIGNED_USER_',
			module        : 'Teams',
			show : function(element, node)
			{
				var prop = 'USER_ASSIGNMENT_METHOD';
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return escalationEventDefinition && escalationEventDefinition.get(prop) == 'Static User';
			},
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.modelProperty + 'ID');
		
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				res[prop] = escalationEventDefinition.get(prop);

				prop = ensureNotNull(this.modelProperty + 'NAME');
				res[prop] = escalationEventDefinition.get(prop);
				return res;
			},
			set : function(element, values)
			{
				var res = {};
				var prop = ensureNotNull(this.modelProperty + 'ID');
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
				}
				else
				{
					res[prop] = undefined;
				}
				prop = ensureNotNull(this.modelProperty + 'NAME');
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
				}
				else
				{
					res[prop] = undefined;
				}
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return cmdHelper.updateBusinessObject(element, escalationEventDefinition, res);
			},
			validate : function(element)
			{
				var value = this.get(element)[this.id + 'ID'];
				if ( Sql.ToString(value) == '' )
				{
					var err = new Object();
					err[this.id + 'ID'  ] = L10n.Term('.ERR_REQUIRED_FIELD');
					err[this.id + 'NAME'] = L10n.Term('.ERR_REQUIRED_FIELD');
					return err;
				}
			}
		}, element, bpmnFactory, eventBus));

		// 09/08/2021 Paul.  Include the eventBus
		group.entries.push(popupEntryFactory(
		{
			id            : 'DYNAMIC_PROCESS_TEAM_',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_DYNAMIC_PROCESS_TEAM'),
			modelProperty : 'DYNAMIC_PROCESS_TEAM_',
			module        : 'Teams',
			show : function(element, node)
			{
				var prop = 'USER_ASSIGNMENT_METHOD';
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return escalationEventDefinition && (escalationEventDefinition.get(prop) == 'Round Robin Team' || escalationEventDefinition.get(prop) == 'Self-Service Team');
			},
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.modelProperty + 'ID');
		
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				res[prop] = escalationEventDefinition.get(prop);

				prop = ensureNotNull(this.modelProperty + 'NAME');
				res[prop] = escalationEventDefinition.get(prop);
				return res;
			},
			set : function(element, values)
			{
				var res = {};
				var prop = ensureNotNull(this.modelProperty + 'ID');
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
				}
				else
				{
					res[prop] = undefined;
				}
				prop = ensureNotNull(this.modelProperty + 'NAME');
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
				}
				else
				{
					res[prop] = undefined;
				}
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return cmdHelper.updateBusinessObject(element, escalationEventDefinition, res);
			},
			validate : function(element)
			{
				var value = this.get(element)[this.id + 'ID'];
				if ( Sql.ToString(value) == '' )
				{
					var err = new Object();
					err[this.id + 'ID'  ] = L10n.Term('.ERR_REQUIRED_FIELD');
					err[this.id + 'NAME'] = L10n.Term('.ERR_REQUIRED_FIELD');
					return err;
				}
			}
		}, element, bpmnFactory, eventBus));

		// 09/08/2021 Paul.  Include the eventBus
		group.entries.push(popupEntryFactory(
		{
			id            : 'DYNAMIC_PROCESS_ROLE_',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_DYNAMIC_PROCESS_ROLE'),
			modelProperty : 'DYNAMIC_PROCESS_ROLE_',
			module        : 'ACLRoles',
			show : function(element, node)
			{
				var prop = 'USER_ASSIGNMENT_METHOD';
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return escalationEventDefinition && (escalationEventDefinition.get(prop) == 'Round Robin Role' || escalationEventDefinition.get(prop) == 'Self-Service Role');
			},
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.modelProperty + 'ID');
		
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				res[prop] = escalationEventDefinition.get(prop);

				prop = ensureNotNull(this.modelProperty + 'NAME');
				res[prop] = escalationEventDefinition.get(prop);
				return res;
			},
			set : function(element, values)
			{
				var res = {};
				var prop = ensureNotNull(this.modelProperty + 'ID');
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
				}
				else
				{
					res[prop] = undefined;
				}
				prop = ensureNotNull(this.modelProperty + 'NAME');
				if ( values[prop] !== '' )
				{
					res[prop] = values[prop];
				}
				else
				{
					res[prop] = undefined;
				}
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return cmdHelper.updateBusinessObject(element, escalationEventDefinition, res);
			},
			validate : function(element)
			{
				var value = this.get(element)[this.id + 'ID'];
				if ( Sql.ToString(value) == '' )
				{
					var err = new Object();
					err[this.id + 'ID'  ] = L10n.Term('.ERR_REQUIRED_FIELD');
					err[this.id + 'NAME'] = L10n.Term('.ERR_REQUIRED_FIELD');
					return err;
				}
			}
		}, element, bpmnFactory, eventBus));

		var bpmn_duration_units = L10n.GetList('bpmn_duration_units');
		var arrDurationUnits = new Array();
		for ( var i = 0; i < bpmn_duration_units.length; i++ )
		{
			let type: any = new Object();
			arrDurationUnits.push(type);
			type.value = bpmn_duration_units[i];
			type.name  = L10n.Term('.bpmn_duration_units.' + bpmn_duration_units[i]);
		}

		group.entries.push(entryFactory.selectBox(
		{
			id            : 'DURATION_UNITS',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_DURATION_UNITS'),
			modelProperty : 'DURATION_UNITS',
			emptyParameter: false,
			selectOptions : arrDurationUnits,
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				res[prop] = escalationEventDefinition.get(prop);
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
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return cmdHelper.updateBusinessObject(element, escalationEventDefinition, res);
			}
		}));

		group.entries.push(entryFactory.textField(
		{
			id            : 'DURATION_VALUE',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_DURATION_VALUE'),
			modelProperty : 'DURATION_VALUE',
			disabled : function(element, node)
			{
				var prop = 'DURATION_UNITS';
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return (escalationEventDefinition && Sql.ToString(escalationEventDefinition.get(prop)) == '');
			},
			get : function(element)
			{
				var res = {};
				var prop = ensureNotNull(this.id);
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				res[prop] = escalationEventDefinition.get(prop);
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
				var escalationEventDefinition = eventDefinitionHelper.getEscalationEventDefinition(element);
				return cmdHelper.updateBusinessObject(element, escalationEventDefinition, res);
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
