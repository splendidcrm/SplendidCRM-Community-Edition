/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
import Sql            from '../../../../../scripts/Sql' ;
import L10n           from '../../../../../scripts/L10n';
import SplendidCache  from '../../../../../scripts/SplendidCache';
import { StartsWith } from '../../../../../scripts/utility';

var getBusinessObject     = require('bpmn-js/lib/util/ModelUtil').getBusinessObject;
var getExtensionElements  = require('bpmn-js-properties-panel/lib/helper/ExtensionElementsHelper').getExtensionElements;
var extensionElements     = require('bpmn-js-properties-panel/lib/provider/camunda/parts/implementation/ExtensionElements');
//var properties            = require('bpmn-js-properties-panel/lib/provider/camunda/parts//implementation/Properties');
var entryFactory          = require('bpmn-js-properties-panel/lib/factory/EntryFactory');
var elementHelper         = require('bpmn-js-properties-panel/lib/helper/ElementHelper');
var cmdHelper             = require('bpmn-js-properties-panel/lib/helper/CmdHelper');
var is                    = require('bpmn-js/lib/util/ModelUtil').is;
var find                  = require('lodash/collection/find');
var forEach               = require('lodash/collection/forEach');
var assign                = require('lodash/object/assign');
//import formHelper         from './factory/ModuleHelper';
//var properties            = require('bpmn-js-properties-panel/lib/provider/camunda/parts/PropertiesProps');
import properties         from './factory/ModuleProperties';
import popupEntryFactory  from './factory/ModulePopupEntryFactory';

function ensureNotNull(prop)
{
	if ( !prop )
	{
		throw new Error(prop + ' must be set.');
	}
	return prop;
}

var formHelper: any = {};
/**
 * Return all form fields existing in the business object, and an empty array if none exist.
 * @param  {djs.model.Base} element
 * @return {Array} a list of form field objects
 */
formHelper.getFormFields = function(element)
{
	var bo = getBusinessObject(element);
	var formData = getExtensionElements(bo, 'camunda:Properties');

	if (typeof formData !== 'undefined')
	{
		return formData[0].values;
	}
	else
	{
		return [];
	}
};

/**
 * Get a form field from the business object at given index
 * @param {djs.model.Base} element
 * @param {number} idx
 * @return {ModdleElement} the form field
 */
formHelper.getFormField = function(element, idx)
{
	var formFields = this.getFormFields(element);
	// 09/07/2016 Paul.  It is hard to catch these bugs, so throw to the debugger. 
	if ( formFields === undefined )
	{
		console.log('formHelper.getFormField: formFields is undefined');
		// 06/23/2017 Paul.  Should have disabled debugger before production build. 
		//debugger;
	}
	return formFields[idx];
};

// 09/08/2021 Paul.  Include the eventBus
export default function(group, element, bpmnFactory, elementRegistry, eventBus)
{
	// 09/28/2016 Paul.  Move to top of function. 
	// SCRIPT1047: In strict mode, function declarations cannot be nested inside a statement or block. They may only appear at the top level or directly inside a function body. 
	function getSelectedFormField(element, node)
	{
		var selected = formFieldsEntry.getSelected(element, node.parentNode);
		if ( selected.idx === -1 || selected.idx === undefined )
		{
			return;
		}
		return formHelper.getFormField(element, selected.idx);
	}

	if ( is(element, 'bpmn:Task') && !is(element, 'bpmn:UserTask') && !is(element, 'bpmn:BusinessRuleTask') && !is(element, 'bpmn:ReceiveTask') )
	{
		group.entries.push(entryFactory.selectBox(
		{ 
			id            : 'OPERATION',
			//description   : L10n.Term('BusinessProcesses.LBL_BPMN_OPERATION_DESCRIPTION'),
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_OPERATION'),
			modelProperty : 'OPERATION',
			selectOptions :
			[
				{ value: 'load_module'  , name: L10n.Term('.bpmn_task_operation.load_module'  ) },
				{ value: 'save_module'  , name: L10n.Term('.bpmn_task_operation.save_module'  ) },
				{ value: 'assign_module', name: L10n.Term('.bpmn_task_operation.assign_module') },
			]
		}));
		
		let designerModules = SplendidCache.GetReportDesignerModules();
		var arrModules = new Array();
		arrModules.push( { name: '', value: '' } );
		for ( var i = 0; i < designerModules.arrReportDesignerModules.length; i++ )
		{
			let option: any = new Object();
			option.value = designerModules.arrReportDesignerModules[i].ModuleName;
			// 07/05/2016 Paul.  The display name is already translated by the Rest.svc call. 
			option.name  = designerModules.arrReportDesignerModules[i].DisplayName;
			arrModules.push(option);
		}
		
		// 08/09/2016 Paul.  Make sure to initialize with current value. 
		var bo = getBusinessObject(element);
		var oldMODULE_NAME = bo.get('MODULE_NAME');
		if ( oldMODULE_NAME === undefined || oldMODULE_NAME == '' )
			oldMODULE_NAME = designerModules.arrReportDesignerModules[0].ModuleName;
		
		var arrFields = new Array();
		var module = designerModules.FindModuleByName(oldMODULE_NAME);
		if ( module != null )
		{
			var arrModuleFields = module.Fields;
			for ( var j = 0; j < arrModuleFields.length; j++ )
			{
				let field: any = new Object();
				field.value = arrModuleFields[j].ColumnName ;
				field.name  = arrModuleFields[j].DisplayName + ' [' + field.value + ']';
				arrFields.push(field);
			}
		}
		
		// C:\Web.net\SplendidCRM6\Administration\BusinessProcesses\node_modules\bpmn-js-properties-panel\lib\factory\SelectEntryFactory.js
		group.entries.push(entryFactory.selectBox(
		{
			id            : 'MODULE_NAME',
			//description   : L10n.Term('BusinessProcesses.LBL_BPMN_MODULE_NAME_DESCRIPTION'),
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_MODULE_NAME'),
			modelProperty : 'MODULE_NAME',
			selectOptions : arrModules,
			get : function(element)
			{
				var bo = getBusinessObject(element);
				var res = {};
				var prop = ensureNotNull(this.id);
				res[prop] = bo.get(prop);
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
				var bo = getBusinessObject(element);
				var oldMODULE_NAME = bo.get(this.id);
				if ( oldMODULE_NAME != values[prop] )
				{
					while ( arrFields.length > 0 )
					{
						arrFields.pop();
					}
					var module = designerModules.FindModuleByName(values[prop]);
					if ( module != null )
					{
						var arrModuleFields = module.Fields;
						for ( var j = 0; j < arrModuleFields.length; j++ )
						{
							let field: any = new Object();
							field.value = arrModuleFields[j].ColumnName ;
							field.name  = arrModuleFields[j].DisplayName;
							arrFields.push(field);
						}
					}
					let module_field_name: any = document.getElementById('camunda-module-field-name-select');
					if ( module_field_name != null )
					{
						while ( module_field_name.childNodes.length > 0 )
						{
							module_field_name.removeChild(module_field_name.firstChild);
						}
						for ( var j = 0; j < arrFields.length; j++ )
						{
							let opt: any = document.createElement('option');
							module_field_name.appendChild(opt);
							opt.setAttribute('value', arrFields[j].value);
							opt.innerHTML = arrFields[j].name;
						}
					}
					// 08/10/2016 Paul.  Also need to remove existing properties. 
					var extensionElements = bo.get('extensionElements');
					if ( extensionElements != null )
					{
						var objectsToRemove = [];
						forEach(extensionElements.get('values'), function(extensionElement)
						{
							if ( is(extensionElement, 'camunda:Properties') )
							{
								objectsToRemove.push(extensionElement);
							}
						});
						var objectsToAdd = [];
						commands.push(cmdHelper.addAndRemoveElementsFromList(element, extensionElements, 'values', 'extensionElements', objectsToAdd, objectsToRemove));
					}
				}
				commands.push(cmdHelper.updateProperties(element, res));
				return commands;
			},
			validate : function()
			{
				return {};
			},
			disabled: function(element, node)
			{
				var bo = getBusinessObject(element);
				var OPERATION = bo.get('OPERATION');
				if ( Sql.IsEmptyString(OPERATION) )
					OPERATION = 'load_module';
				return (OPERATION != 'load_module' && OPERATION != 'save_module' && OPERATION != 'assign_module');
			}
		}));

		group.entries.push(entryFactory.textField(
		{
			id            : 'FIELD_PREFIX',
			//description   : L10n.Term('BusinessProcesses.LBL_BPMN_FIELD_PREFIX_DESCRIPTION'),
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_FIELD_PREFIX'),
			modelProperty : 'FIELD_PREFIX',
			disabled: function(element, node)
			{
				var bo = getBusinessObject(element);
				var OPERATION = bo.get('OPERATION');
				if ( Sql.IsEmptyString(OPERATION) )
					OPERATION = 'load_module';
				return OPERATION != 'load_module';
			}
		}));

		group.entries.push(entryFactory.textField(
		{
			id            : 'SOURCE_ID',
			//description   : L10n.Term('BusinessProcesses.LBL_BPMN_SOURCE_ID_DESCRIPTION'),
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_SOURCE_ID'),
			modelProperty : 'SOURCE_ID',
			disabled: function(element, node)
			{
				var bo = getBusinessObject(element);
				var OPERATION = bo.get('OPERATION');
				if ( Sql.IsEmptyString(OPERATION) )
					OPERATION = 'load_module';
				return (OPERATION != 'load_module' && OPERATION != 'save_module' && OPERATION != 'assign_module');
			},
			validate: function(element)
			{
				var bo = getBusinessObject(element);
				var OPERATION = bo.get('OPERATION');
				if ( Sql.IsEmptyString(OPERATION) )
					OPERATION = 'load_module';
				if ( OPERATION == 'load_module' )
				{
					var value = bo.get(this.id);
					if ( Sql.ToString(value) == '' )
					{
						var err = new Object();
						err[this.id] = L10n.Term('.ERR_REQUIRED_FIELD');
						return err;
					}
				}
			}
		}));

		group.entries.push(entryFactory.label(
		{
			id: 'module-fields-load-header',
			labelText: L10n.Term('BusinessProcesses.LBL_LOAD_MODULE_FIELDS'),
			divider: true,
			showLabel: function(element, node)
			{
				var bo = getBusinessObject(element);
				var OPERATION = bo.get('OPERATION');
				if ( Sql.IsEmptyString(OPERATION) )
					OPERATION = 'load_module';
				return OPERATION == 'load_module';
			}
		}));

		group.entries.push(entryFactory.label(
		{
			id: 'module-fields-save-header',
			labelText: L10n.Term('BusinessProcesses.LBL_SAVE_MODULE_FIELDS'),
			divider: true,
			showLabel: function(element, node)
			{
				var bo = getBusinessObject(element);
				var OPERATION = bo.get('OPERATION');
				return OPERATION == 'save_module';
			}
		}));

		var formFieldsEntry = extensionElements(element, bpmnFactory, 
		{
			id           : 'module-fields',
			label        : L10n.Term('BusinessProcesses.LBL_BPMN_MODULE_ADD_FIELD'),
			modelProperty: 'id',
			prefix       : 'Field',
			setOptionLabelValue: function (element, node, option, property, value, idx)
			{
				var formFields = formHelper.getFormField(element, idx);
				// 07/16/2016 Paul.  Change the name in the listbox to the field name. 
				if ( formFields.name !== undefined )
				{
					var bo = getBusinessObject(element);
					var OPERATION = bo.get('OPERATION');
					if ( OPERATION == 'save_module' )
					{
						if ( StartsWith(formFields.value, '=') )
							node.text = formFields.name + ' ' + formFields.value;
						else
							node.text = formFields.name + ' = "' + formFields.value + '"';
					}
					else
						node.text = formFields.name;
				}
				else
					node.text = value;
			},
			createExtensionElement: function(element, extensionElements, value)
			{
				var commands = [];
				var bo = getBusinessObject(element);
				var formData = null;
				var formDataExt = getExtensionElements(bo, 'camunda:Properties');
				if ( formDataExt != null )
				{
					formData = formDataExt[0];
				}
				else
				{
					var extensionElements = bo.get('extensionElements');
					if ( !extensionElements )
					{
						extensionElements = elementHelper.createElement('bpmn:ExtensionElements', { values: [] }, bo, bpmnFactory);
						commands.push(cmdHelper.updateProperties(element, { extensionElements: extensionElements }));
					}
					formData = elementHelper.createElement('camunda:Properties', { values: [] }, extensionElements, bpmnFactory);
					commands.push(cmdHelper.addAndRemoveElementsFromList(element, extensionElements, 'values', 'extensionElements', [ formData ], [] ));
				}
			
				var field = elementHelper.createElement('camunda:Property', { name: 'ID' }, formData, bpmnFactory);
				// 07/10/2016 paul.  Set default values here. 
				if ( field.name === undefined )
				{
					field.name  = 'ID';
				}
				if ( typeof formData.values !== 'undefined' )
				{
					commands.push(cmdHelper.addElementsTolist(element, formData, 'values', [ field ]));
				}
				else
				{
					commands.push(cmdHelper.updateBusinessObject(element, formData, { values: [ field ] }));
				}
				return commands;
			},
			removeExtensionElement: function(element, extensionElements, value, idx)
			{
				var formData = getExtensionElements(getBusinessObject(element), 'camunda:Properties')[0];
				var entry = formData.values[idx];
				return cmdHelper.removeElementsFromList(element, formData, 'values', null, [ entry ]);
			},
			getExtensionElements: function(element)
			{
				return formHelper.getFormFields(element);
			},
			hideExtensionElements: function(element, node)
			{
				var bo = getBusinessObject(element);
				var OPERATION = Sql.ToString(bo.get('OPERATION'));
				if ( Sql.IsEmptyString(OPERATION) )
					OPERATION = 'load_module';
				return !(OPERATION == 'save_module' || OPERATION == 'load_module');
			}
		});
		group.entries.push(formFieldsEntry);

		group.entries.push(entryFactory.selectBox(
		{
			id            : 'module-field-name',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_MODULE_FIELD'),
			modelProperty : 'name',
			emptyParameter: false,
			selectOptions : arrFields,
			get: function(element, node)
			{
				var selectedFormField = getSelectedFormField(element, node);
				if ( selectedFormField )
				{
					return { name: selectedFormField.name };
				}
				else
				{
					return {};
				}
			},
			set: function(element, values, node)
			{
				var selectedFormField = getSelectedFormField(element, node);
				var commands = [];
				commands.push(cmdHelper.updateBusinessObject(element, selectedFormField, values));
				return commands;
			},
			disabled: function(element, node)
			{
				var bo = getBusinessObject(element);
				var OPERATION = bo.get('OPERATION');
				if ( Sql.IsEmptyString(OPERATION) )
					OPERATION = 'load_module';
				return !((OPERATION == 'save_module' || OPERATION == 'load_module') && getSelectedFormField(element, node));
			}
		}));

		// 05/10/2022 Paul.  Changed to textBox. 
		group.entries.push(entryFactory.textBox(
		{
			id            : 'module-field-expression',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_EXPRESSION'),
			modelProperty : 'value',
			minRows       : 8,
			expandable    : true,
			get: function(element, node)
			{
				var selectedFormField = getSelectedFormField(element, node);
				if ( selectedFormField )
				{
					return { value: selectedFormField.value };
				}
				else
				{
					return {};
				}
			},
			set: function(element, values, node)
			{
				var selectedFormField = getSelectedFormField(element, node);
				var commands = [];
				commands.push(cmdHelper.updateBusinessObject(element, selectedFormField, values));
				return commands;
			},
			show: function(element, node)
			{
				var bo = getBusinessObject(element);
				var OPERATION = bo.get('OPERATION');
				return OPERATION == 'save_module' && getSelectedFormField(element, node);
			}
		}));

		// Round Robin Team, Round Robin Role, Supervisor, Static User
		var bpmn_record_assignment_method = L10n.GetList('bpmn_record_assignment_method');
		var arrUserAssignmentMethod = new Array();
		for ( var i = 0; i < bpmn_record_assignment_method.length; i++ )
		{
			let type: any = new Object();
			arrUserAssignmentMethod.push(type);
			type.value = bpmn_record_assignment_method[i];
			type.name  = L10n.Term('.bpmn_record_assignment_method.' + bpmn_record_assignment_method[i]);
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
				var bo = getBusinessObject(element);
				var prop = ensureNotNull(this.id);
				res[prop] = bo.get(prop);
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
				return cmdHelper.updateProperties(element, res);
			},
			disabled: function(element, node)
			{
				var bo = getBusinessObject(element);
				var OPERATION = bo.get('OPERATION');
				if ( Sql.IsEmptyString(OPERATION) )
					OPERATION = 'load_module';
				return !(OPERATION == 'assign_module');
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
				var bo = getBusinessObject(element);
				var OPERATION = bo.get('OPERATION');
				if ( Sql.IsEmptyString(OPERATION) )
					OPERATION = 'load_module';
				var USER_ASSIGNMENT_METHOD = bo.get('USER_ASSIGNMENT_METHOD');
				if ( Sql.IsEmptyString(USER_ASSIGNMENT_METHOD) )
					USER_ASSIGNMENT_METHOD = 'Round Robin Team';
				return (OPERATION == 'assign_module' && USER_ASSIGNMENT_METHOD == 'Static User');
			},
			get : function(element)
			{
				var res = {};
				var bo = getBusinessObject(element);
				var prop = this.modelProperty + 'ID'  ;
				res[prop] = bo.get(prop);
				var prop = this.modelProperty + 'NAME';
				res[prop] = bo.get(prop);
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
				return cmdHelper.updateProperties(element, res);
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
			id            : 'STATIC_ASSIGNED_TEAM_',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_STATIC_ASSIGNED_TEAM'),
			modelProperty : 'STATIC_ASSIGNED_TEAM_',
			module        : 'Teams',
			show : function(element, node)
			{
				var bo = getBusinessObject(element);
				var OPERATION = bo.get('OPERATION');
				if ( Sql.IsEmptyString(OPERATION) )
					OPERATION = 'load_module';
				var USER_ASSIGNMENT_METHOD = bo.get('USER_ASSIGNMENT_METHOD');
				if ( Sql.IsEmptyString(USER_ASSIGNMENT_METHOD) )
					USER_ASSIGNMENT_METHOD = 'Round Robin Team';
				return (OPERATION == 'assign_module' && USER_ASSIGNMENT_METHOD == 'Static Team');
			},
			get : function(element)
			{
				var res = {};
				var bo = getBusinessObject(element);
				var prop = this.modelProperty + 'ID'  ;
				res[prop] = bo.get(prop);
				var prop = this.modelProperty + 'NAME';
				res[prop] = bo.get(prop);
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
				return cmdHelper.updateProperties(element, res);
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
				var bo = getBusinessObject(element);
				var OPERATION = bo.get('OPERATION');
				if ( Sql.IsEmptyString(OPERATION) )
					OPERATION = 'load_module';
				var USER_ASSIGNMENT_METHOD = bo.get('USER_ASSIGNMENT_METHOD');
				if ( Sql.IsEmptyString(USER_ASSIGNMENT_METHOD) )
					USER_ASSIGNMENT_METHOD = 'Round Robin Team';
				return (OPERATION == 'assign_module' && USER_ASSIGNMENT_METHOD == 'Round Robin Team');
			},
			get : function(element)
			{
				var res = {};
				var bo = getBusinessObject(element);
				var prop = this.modelProperty + 'ID'  ;
				res[prop] = bo.get(prop);
				var prop = this.modelProperty + 'NAME';
				res[prop] = bo.get(prop);
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
				return cmdHelper.updateProperties(element, res);
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
				var bo = getBusinessObject(element);
				var OPERATION = bo.get('OPERATION');
				if ( Sql.IsEmptyString(OPERATION) )
					OPERATION = 'load_module';
				var USER_ASSIGNMENT_METHOD = bo.get('USER_ASSIGNMENT_METHOD');
				if ( Sql.IsEmptyString(USER_ASSIGNMENT_METHOD) )
					USER_ASSIGNMENT_METHOD = 'Round Robin Team';
				return (OPERATION == 'assign_module' && USER_ASSIGNMENT_METHOD == 'Round Robin Role');
			},
			get : function(element)
			{
				var res = {};
				var bo = getBusinessObject(element);
				var prop = this.modelProperty + 'ID'  ;
				res[prop] = bo.get(prop);
				var prop = this.modelProperty + 'NAME';
				res[prop] = bo.get(prop);
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
				return cmdHelper.updateProperties(element, res);
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
	}
};
