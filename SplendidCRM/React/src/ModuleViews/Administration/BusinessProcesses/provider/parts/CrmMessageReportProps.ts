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

var getBusinessObject     = require('bpmn-js/lib/util/ModelUtil').getBusinessObject;
var getExtensionElements  = require('bpmn-js-properties-panel/lib/helper/ExtensionElementsHelper').getExtensionElements;
var extensionElements     = require('bpmn-js-properties-panel/lib/provider/camunda/parts/implementation/ExtensionElements');
var properties            = require('bpmn-js-properties-panel/lib/provider/camunda/parts//implementation/Properties');
var entryFactory          = require('bpmn-js-properties-panel/lib/factory/EntryFactory');
var elementHelper         = require('bpmn-js-properties-panel/lib/helper/ElementHelper');
var cmdHelper             = require('bpmn-js-properties-panel/lib/helper/CmdHelper');
//var formHelper            = require('bpmn-js-properties-panel/lib/helper/FormHelper');
var is                    = require('bpmn-js/lib/util/ModelUtil').is;
var find                  = require('lodash/collection/find');
import formHelper         from './factory/ReportHelper';
import popupEntryFactory  from './factory/ModulePopupEntryFactory';
import hiddenEntryFactory from './factory/HiddenInputEntryFactory';

function hasEventDefinition(element, eventDefinition)
{
	var bo = getBusinessObject(element);
	return !!find(bo.eventDefinitions || [], function(definition) { return is(definition, eventDefinition); });
}

function ensureFormKeyAndDataSupported(element)
{
	return (is(element, 'bpmn:IntermediateThrowEvent') || is(element, 'bpmn:EndEvent')) && hasEventDefinition(element, 'bpmn:MessageEventDefinition');
}

// 09/08/2021 Paul.  Include the eventBus
export default function(group, element, bpmnFactory, elementRegistry, eventBus)
{
	if ( !ensureFormKeyAndDataSupported(element) )
	{
		return;
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
		id           : 'report-fields',
		label        : ' ',
		modelProperty: 'id',
		prefix       : 'Report',
		setOptionLabelValue: function (element, node, option, property, value, idx)
		{
			var formFields = formHelper.getFormField(element, idx);
			// 07/16/2016 Paul.  Change the name in the listbox to the report name. 
			if ( formFields.REPORT_NAME !== undefined )
				node.text = formFields.REPORT_NAME;
			else
				node.text = value;
		},
		createExtensionElement: function(element, extensionElements, value)
		{
			var commands = [];
			var bo = getBusinessObject(element);
			var formData = null;
			var formDataExt = getExtensionElements(bo, 'crm:CrmMessageReports');
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
				formData = elementHelper.createElement('crm:CrmMessageReports', { fields: [] }, extensionElements, bpmnFactory);
				commands.push(cmdHelper.addAndRemoveElementsFromList(element, extensionElements, 'values', 'extensionElements', [ formData ], [] ));
			}
			
			var field = elementHelper.createElement('crm:CrmReport', { id: value }, formData, bpmnFactory);
			// 07/10/2016 paul.  Set default values here. 
			if ( field.RENDER_FORMAT === undefined )
			{
				field.RENDER_FORMAT  = 'PDF';
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
			var formData = getExtensionElements(getBusinessObject(element), 'crm:CrmMessageReports')[0];
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
		id           : 'report-field-id',
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
			return !getSelectedFormField(element, node);
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

	var report_render_format = L10n.GetList('report_render_format');
	var arrRenderFormat = new Array();
	for ( var i = 0; i < report_render_format.length; i++ )
	{
		let type: any = new Object();
		arrRenderFormat.push(type);
		type.value = report_render_format[i];
		type.name  = L10n.Term('.report_render_format.' + report_render_format[i]);
	}

	group.entries.push(entryFactory.selectBox(
	{
		id            : 'RENDER_FORMAT',
		label         : L10n.Term('BusinessProcesses.LBL_BPMN_RENDER_FORMAT'),
		modelProperty : 'RENDER_FORMAT',
		emptyParameter: false,
		selectOptions : arrRenderFormat,
		get: function(element, node)
		{
			var selectedFormField = getSelectedFormField(element, node);
			if ( selectedFormField )
			{
				return { RENDER_FORMAT: selectedFormField.RENDER_FORMAT };
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

	// 09/08/2021 Paul.  Include the eventBus
	group.entries.push(popupEntryFactory(
	{
		id            : 'REPORT_',
		//description   : L10n.Term('BusinessProcesses.LBL_BPMN_MESSAGE_REPORT_DESCRIPTION'),
		label         : L10n.Term('BusinessProcesses.LBL_BPMN_MESSAGE_REPORT'),
		modelProperty : 'REPORT_',
		module        : 'Reports',
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
			return /* formHelper.getFormType(element) !== 'form-data' || */ !getSelectedFormField(element, node);
		}
	}, element, bpmnFactory, eventBus));

	// [FormData] Properties label
	group.entries.push(entryFactory.label(
	{
		id: 'form-field-properties-header',
		labelText: L10n.Term('BusinessProcesses.LBL_BPMN_REPORT_PROPERTIES'),
		divider: true,
		showLabel: function(element, node)
		{
			return !!getSelectedFormField(element, node);
		}
	}));

	// [FormData] camunda:properties table
	group.entries.push(properties(element, bpmnFactory,
	{
		id: 'form-field-properties',
		modelProperties: [ 'name', 'value' ],
		labels:
		[	L10n.Term('BusinessProcesses.LBL_BPMN_PARAMETER_NAME'),
			L10n.Term('BusinessProcesses.LBL_BPMN_PARAMETER_VALUE')
		],
		getParent: function(element, node)
		{
			return getSelectedFormField(element, node);
		},
		show: function(element, node)
		{
			return !!getSelectedFormField(element, node);
		}
	}));
};

