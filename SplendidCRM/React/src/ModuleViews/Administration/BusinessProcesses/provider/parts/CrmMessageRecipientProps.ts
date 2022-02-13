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
var entryFactory          = require('bpmn-js-properties-panel/lib/factory/EntryFactory');
var elementHelper         = require('bpmn-js-properties-panel/lib/helper/ElementHelper');
var cmdHelper             = require('bpmn-js-properties-panel/lib/helper/CmdHelper');
//var formHelper            = require('bpmn-js-properties-panel/lib/helper/FormHelper');
var utils                 = require('bpmn-js-properties-panel/lib/Utils');
var is                    = require('bpmn-js/lib/util/ModelUtil').is;
var find                  = require('lodash/collection/find');
var forEach               = require('lodash/collection/forEach');
import formHelper         from './factory/RecipientHelper';
import popupEntryFactory  from './factory/ModulePopupEntryFactory';
import hiddenEntryFactory from './factory/HiddenInputEntryFactory';

function hasEventDefinition(element, eventDefinition)
{
	var bo = getBusinessObject(element);
	return !!find(bo.eventDefinitions || [], function(definition) { return is(definition, eventDefinition); });
}

/*
RECIPIENT_NAME
RECIPIENT_TYPE   -- team, role, record, record_custom, user (default)
SEND_TYPE        -- to, cc, bcc
RECIPIENT_TABLE
RECIPIENT_FIELD
*/

/**
 * Generate a form field specific textField using entryFactory.
 *
 * @param  {string} options.id
 * @param  {string} options.label
 * @param  {string} options.modelProperty
 * @param  {function} options.validate
 *
 * @return {Object} an entryFactory.textField object
 */
function formFieldTextField(options, getSelectedFormField)
{
	var id = options.id;
	var label = options.label;
	var modelProperty = options.modelProperty;
	var validate = options.validate;

	return entryFactory.textField(
	{
		id: id,
		label: label,
		modelProperty: modelProperty,
		get: function(element, node)
		{
			var selectedFormField = getSelectedFormField(element, node) || {};
			var values = {};
			values[modelProperty] = selectedFormField[modelProperty];
			return values;
		},
		set: function(element, values, node)
		{
			var commands = [];
			if ( typeof options.set === 'function' )
			{
				var cmd = options.set(element, values, node);
				if ( cmd )
				{
					commands.push(cmd);
				}
			}
			var formField = getSelectedFormField(element, node);
			var properties = {};
			properties[modelProperty] = values[modelProperty];
			commands.push(cmdHelper.updateBusinessObject(element, formField, properties));
			return commands;
		},
		disabled: function(element, node)
		{
			return /* formHelper.getFormType(element) === 'form-key' || */ !getSelectedFormField(element, node);
		},
		validate: validate
	});
}

function ensureFormKeyAndDataSupported(element)
{
	return (is(element, 'bpmn:IntermediateThrowEvent') || is(element, 'bpmn:EndEvent')) && hasEventDefinition(element, 'bpmn:MessageEventDefinition');
}

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

// 09/08/2021 Paul.  Include the eventBus
export default function(group, element, bpmnFactory, elementRegistry, eventBus)
{
	if ( !ensureFormKeyAndDataSupported(element) )
	{
		return;
	}

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

	function getSelectedFormField(element, node)
	{
		var selected = formFieldsEntry.getSelected(element, node.parentNode);
		if ( selected.idx === -1 || selected.idx === undefined )
		{
			return;
		}
		return formHelper.getFormField(element, selected.idx);
	}

	var formFieldsEntry = extensionElements(element, bpmnFactory, 
	{
		id           : 'recipient-fields',
		label        : ' ',
		modelProperty: 'id',
		prefix       : 'Recipient',
		setOptionLabelValue: function (element, node, option, property, value, idx)
		{
			var formFields = formHelper.getFormField(element, idx);
			if ( formFields.RECIPIENT_TYPE == 'Teams' || formFields.RECIPIENT_TYPE == 'Roles' || formFields.RECIPIENT_TYPE == 'Users' )
			{
				if ( formFields.RECIPIENT_NAME !== undefined )
					node.text = formFields.RECIPIENT_NAME;
				else
					node.text = value;
			}
			else
			{
				if ( formFields.RECIPIENT_TYPE !== undefined && formFields.RECIPIENT_FIELD !== undefined )
				{
					let designerModules = SplendidCache.GetReportDesignerModules();
					var field = designerModules.FindFieldByModule(formFields.RECIPIENT_TYPE, formFields.RECIPIENT_FIELD)
					if ( field != null )
						node.text = formFields.RECIPIENT_TYPE + ' ' + field.DisplayName;
					else
						node.text = value;
				}
				else
					node.text = value;
			}
		},
		createExtensionElement: function(element, extensionElements, value)
		{
			var commands = [];
			var bo = getBusinessObject(element);
			var formData = null;
			var formDataExt = getExtensionElements(bo, 'crm:CrmMessageRecipients');
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
				formData = elementHelper.createElement('crm:CrmMessageRecipients', { fields: [] }, extensionElements, bpmnFactory);
				commands.push(cmdHelper.addAndRemoveElementsFromList(element, extensionElements, 'values', 'extensionElements', [ formData ], [] ));
			}
			
			var field = elementHelper.createElement('crm:CrmRecipient', { id: value }, formData, bpmnFactory);
			// 07/10/2016 paul.  Set default values here. 
			if ( field.SEND_TYPE === undefined )
				field.SEND_TYPE = 'to';
			if ( field.RECIPIENT_TYPE === undefined )
			{
				field.RECIPIENT_TYPE  = sBaseModule;
				field.RECIPIENT_FIELD = 'ID';
			}
			if ( typeof formData.fields !== 'undefined' )
			{
				commands.push(cmdHelper.addElementsTolist(element, formData, 'fields', [ field ]));
			}
			else
			{
				commands.push(cmdHelper.updateBusinessObject(element, formData, { fields: [ field ] }));
			}
			return commands;
		},
		removeExtensionElement: function(element, extensionElements, value, idx)
		{
			var formData = getExtensionElements(getBusinessObject(element), 'crm:CrmMessageRecipients')[0];
			var entry = formData.fields[idx];
			return cmdHelper.removeElementsFromList(element, formData, 'fields', null, [ entry ]);
		},
		getExtensionElements: function(element)
		{
			return formHelper.getFormFields(element);
		},
		hideExtensionElements: function(element, node)
		{
			return false /* formHelper.getFormType(element) === 'form-key' */;
		}
	});

	group.entries.push(formFieldsEntry);

	// 07/11/2016 Paul.  Field ID is not important to the user, so hide. 
	group.entries.push(hiddenEntryFactory(
	{
		id           : 'recipient-field-id',
		label        : 'ID',
		modelProperty: 'id',
		getProperty: function(element, node)
		{
			var selectedFormField = getSelectedFormField(element, node) || {};
			return selectedFormField.id;
		},
		setProperty: function(element, properties, node)
		{
			var formField = getSelectedFormField(element, node);
			return cmdHelper.updateBusinessObject(element, formField, properties);
		},
		disabled: function(element, node)
		{
			return /* formHelper.getFormType(element) === 'form-key' || */ !getSelectedFormField(element, node);
		},
		validate: function(element, values, node)
		{
			var formField = getSelectedFormField(element, node);
			if ( formField )
			{
				var idValue = values.id;
				if ( !idValue || idValue.trim() === '' )
				{
					return { id: 'Form field id must not be empty' };
				}
				var formFields = formHelper.getFormFields(element);
				var existingFormField = find(formFields, function(f)
				{
					return f !== formField && f.id === idValue;
				});

				if (existingFormField)
				{
					return { id: 'Form field id already used in form data.' };
				}
			}
		}
	}));

	var workflow_alert_operator_dom = L10n.GetList('workflow_alert_operator_dom');
	var arrSendTypes = new Array();
	for ( var i = 0; i < workflow_alert_operator_dom.length; i++ )
	{
		let type: any = new Object();
		arrSendTypes.push(type);
		type.value = workflow_alert_operator_dom[i];
		type.name  = L10n.Term('.workflow_alert_operator_dom.' + workflow_alert_operator_dom[i]);
	}

	group.entries.push(entryFactory.selectBox(
	{
		id            : 'SEND_TYPE',
		label         : L10n.Term('BusinessProcesses.LBL_BPMN_SEND_TYPE'),
		modelProperty : 'SEND_TYPE',
		emptyParameter: false,
		selectOptions : arrSendTypes,
		get: function(element, node)
		{
			var selectedFormField = getSelectedFormField(element, node);
			if ( selectedFormField )
			{
				return { SEND_TYPE: selectedFormField.SEND_TYPE };
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
			return /* formHelper.getFormType(element) !== 'form-data' || */ !getSelectedFormField(element, node);
		}
	}));

	group.entries.push(entryFactory.selectBox(
	{
		id            : 'RECIPIENT_TYPE',
		label         : L10n.Term('BusinessProcesses.LBL_BPMN_RECIPIENT_TYPE'),
		modelProperty : 'RECIPIENT_TYPE',
		emptyParameter: false,
		selectOptions: 
			[
				{ value: sBaseModule           , name: L10n.Term('.moduleList.' + sBaseModule)                  },
				{ value: sBaseModule + '_AUDIT', name: L10n.Term('.moduleList.' + sBaseModule) + ' Audit'       },
				{ value: 'Users'               , name: L10n.Term('BusinessProcesses.LBL_BPMN_RECIPIENT_USERS' ) },
				{ value: 'Teams'               , name: L10n.Term('BusinessProcesses.LBL_BPMN_RECIPIENT_TEAMS' ) },
				{ value: 'Roles'               , name: L10n.Term('BusinessProcesses.LBL_BPMN_RECIPIENT_ROLES' ) },
			],
		get: function(element, node)
		{
			var selectedFormField = getSelectedFormField(element, node);
			if ( selectedFormField )
			{
				return { RECIPIENT_TYPE: selectedFormField.RECIPIENT_TYPE };
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
			if ( selectedFormField.RECIPIENT_TYPE != values.RECIPIENT_TYPE )
			{
				values.RECIPIENT_ID    = undefined;
				values.RECIPIENT_NAME  = undefined;
			}
			var bSelectedByPopup = (selectedFormField.RECIPIENT_TYPE == 'Users' || selectedFormField.RECIPIENT_TYPE == 'Teams' || selectedFormField.RECIPIENT_TYPE == 'Roles');
			var bValueByPopup    = (values.RECIPIENT_TYPE            == 'Users' || values.RECIPIENT_TYPE            == 'Teams' || values.RECIPIENT_TYPE            == 'Roles');
			if ( bSelectedByPopup != bValueByPopup )
			{
				// delete camunda:value objects from formField.values when switching from type enum
				//commands.push(cmdHelper.updateBusinessObject(element, selectedFormField, { values: undefined }));
				if ( bValueByPopup )
				{
					values.RECIPIENT_FIELD = undefined;
				}
				else
				{
					values.RECIPIENT_FIELD = 'ID';
					values.RECIPIENT_ID    = undefined;
					values.RECIPIENT_NAME  = undefined;
				}
			}
			commands.push(cmdHelper.updateBusinessObject(element, selectedFormField, values));
			return commands;
		},
		disabled: function(element, node)
		{
			return /* formHelper.getFormType(element) !== 'form-data' || */ !getSelectedFormField(element, node);
		}
	}));

	let designerModules = SplendidCache.GetReportDesignerModules();
	var recipient_fields = new Array();
	var module = designerModules.FindModuleByName(sBaseModule);
	if ( module != null )
	{
		var arrFields = module.Fields;
		for ( var j = 0; j < arrFields.length; j++ )
		{
			switch ( arrFields[j].ColumnName )
			{
				case 'ID'              :
				case 'CREATED_BY_ID'   :
				case 'MODIFIED_USER_ID':
				case 'ASSIGNED_USER_ID':
				case 'TEAM_ID'         :
				// 12/26/2017 Paul.  Add ASSIGNED_SET_ID and TEAM_SET_ID. 
				case 'ASSIGNED_SET_ID' :
				case 'TEAM_SET_ID'     :
				case 'PARENT_ID'       :
				case 'ACCOUNT_ID'      :
				case 'CONTACT_ID'      :
				// 06/08/2017 Paul.  Add BPMN support for Quotes, Orders and Invoices. 
				case 'BILLING_ACCOUNT_ID' :
				case 'BILLING_CONTACT_ID' :
				case 'SHIPPING_ACCOUNT_ID':
				case 'SHIPPING_CONTACT_ID':
				case 'EMAIL1'          :
				case 'EMAIL2'          :
					let field: any = new Object();
					field.value = arrFields[j].ColumnName ;
					field.name  = arrFields[j].DisplayName;
					recipient_fields.push(field);
					break;
			}
		}
	}

	group.entries.push(entryFactory.selectBox(
	{
		id            : 'RECIPIENT_FIELD',
		label         : L10n.Term('BusinessProcesses.LBL_BPMN_RECIPIENT_FIELD'),
		modelProperty : 'RECIPIENT_FIELD',
		emptyParameter: false,
		selectOptions : recipient_fields,
		get: function(element, node)
		{
			var selectedFormField = getSelectedFormField(element, node);
			if ( selectedFormField )
			{
				return { RECIPIENT_FIELD: selectedFormField.RECIPIENT_FIELD };
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
			var selectedFormField = getSelectedFormField(element, node);
			return !selectedFormField || (selectedFormField.RECIPIENT_TYPE === 'Users' || selectedFormField.RECIPIENT_TYPE === 'Teams' || selectedFormField.RECIPIENT_TYPE === 'Roles');
		}
	}));

	// 09/08/2021 Paul.  Include the eventBus
	group.entries.push(popupEntryFactory(
	{
		id            : 'RECIPIENT_',
		//description   : L10n.Term('BusinessProcesses.LBL_BPMN_RECIPIENT_DESCRIPTION'),
		label         : L10n.Term('BusinessProcesses.LBL_BPMN_RECIPIENT'),
		modelProperty : 'RECIPIENT_',
		module        : function()
		{
			let RECIPIENT_TYPE: string = Sql.ToString($('#camunda-RECIPIENT_TYPE-select').val());
			RECIPIENT_TYPE = RECIPIENT_TYPE.replace('_AUDIT', '');
			return RECIPIENT_TYPE;
		},
		get: function(element, node)
		{
			var values = {};
			if ( node !== undefined )
			{
				var selectedFormField = getSelectedFormField(element, node) || {};
				values[this.modelProperty + 'ID'  ] = selectedFormField[this.modelProperty + 'ID'  ];
				values[this.modelProperty + 'NAME'] = selectedFormField[this.modelProperty + 'NAME'];
			}
			return values;
		},
		set: function(element, values, node)
		{
			var commands = [];
			if ( node !== undefined )
			{
				var formField = getSelectedFormField(element, node);
				var properties = {};
				properties[this.modelProperty + 'ID'  ] = values[this.modelProperty + 'ID'  ];
				properties[this.modelProperty + 'NAME'] = values[this.modelProperty + 'NAME'];
				commands.push(cmdHelper.updateBusinessObject(element, formField, properties));
			}
			return commands;
		},
		validate: function(element, node)
		{
			if ( node !== undefined )
			{
				var value = node[this.id + 'ID'];
				if ( Sql.ToString(value) == '' )
				{
					var err = new Object();
					err[this.id + 'ID'  ] = L10n.Term('.ERR_REQUIRED_FIELD');
					err[this.id + 'NAME'] = L10n.Term('.ERR_REQUIRED_FIELD');
					return err;
				}
			}
		},
		disabled: function(element, node)
		{
			var selectedFormField = getSelectedFormField(element, node);
			return !selectedFormField || !(selectedFormField.RECIPIENT_TYPE === 'Users' || selectedFormField.RECIPIENT_TYPE === 'Teams' || selectedFormField.RECIPIENT_TYPE === 'Roles');
		}
	}, element, bpmnFactory, eventBus));
};

