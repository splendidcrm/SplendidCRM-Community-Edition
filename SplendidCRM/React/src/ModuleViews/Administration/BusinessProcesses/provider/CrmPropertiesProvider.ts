/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
import Sql  from '../../../../scripts/Sql' ;
import L10n from '../../../../scripts/L10n';

var inherits = require('inherits');
var PropertiesActivator = require('bpmn-js-properties-panel/lib/PropertiesActivator');

// Require all properties you need from existing providers.
// In this case all available bpmn relevant properties without camunda extensions.
//var processProps       = require('bpmn-js-properties-panel/lib/provider/bpmn/parts/ProcessProps'      );
var eventProps         = require('bpmn-js-properties-panel/lib/provider/bpmn/parts/EventProps'          );
var linkProps          = require('bpmn-js-properties-panel/lib/provider/bpmn/parts/LinkProps'           );
var documentationProps = require('bpmn-js-properties-panel/lib/provider/bpmn/parts/DocumentationProps'  );
var idProps            = require('bpmn-js-properties-panel/lib/provider/bpmn/parts/IdProps'             );
var nameProps          = require('bpmn-js-properties-panel/lib/provider/bpmn/parts/NameProps'           );
//var sequenceFlowProps  = require('bpmn-js-properties-panel/lib/provider/camunda/parts/SequenceFlowProps');

// Require your custom property entries.
import crmProcessProps           from'./parts/CrmProcessProps'               ;
import crmProcessVariables       from'./parts/CrmProcessVariables'           ;
import crmStartEventProps        from'./parts/CrmStartEventProps'            ;
import crmTimerStartEventProps   from'./parts/CrmTimerStartEventProps'       ;
import crmModuleFilterProps      from'./parts/CrmModuleFilterProps'          ;
import crmMessageTemplateProps   from'./parts/CrmMessageTemplateProps'       ;
import crmMessageRecipientProps  from'./parts/CrmMessageRecipientProps'      ;
import crmMessageReportProps     from'./parts/CrmMessageReportProps'         ;
import crmTimerIntermediateProps from'./parts/CrmTimerIntermediateCatchEvent';
import crmEscalationEventProps   from'./parts/CrmEscalationEventProps'       ;
import crmEscalationFieldsProps  from'./parts/CrmEscalationFieldsProps'      ;
import crmTaskProps              from'./parts/CrmTaskProps'                  ;
import crmBusinessRuleTaskProps  from'./parts/CrmBusinessRuleTaskProps'      ;
import sequenceFlowProps         from'./parts/SequenceFlowProps'             ;
import crmUserTaskProps          from'./parts/CrmUserTaskProps'              ;
import crmUserTaskFieldsProps    from'./parts/CrmUserTaskFieldsProps'        ;

// C:\Web.net\SplendidCRM6\Administration\BusinessProcesses\node_modules\bpmn-js-properties-panel\lib\PropertiesPanel.js
// 09/08/2021 Paul.  Include the eventBus
function createGeneralTabGroups(element, bpmnFactory, elementRegistry, eventBus)
{
	var generalGroup =
	{
		id: 'general',
		label: L10n.Term('BusinessProcesses.LBL_BPMN_GENERAL_GROUP'),
		entries: []
	};
	nameProps(generalGroup, element);

	var detailsGroup =
	{
		id: 'details',
		label: L10n.Term('BusinessProcesses.LBL_BPMN_DETAILS_GROUP'),
		entries: []
	};

	var eventsGroup =
	{
		id: 'events',
		label: L10n.Term('BusinessProcesses.LBL_BPMN_EVENTS_GROUP'),
		entries: []
	};

	var modulesGroup =
	{
		id: 'modules',
		label: L10n.Term('BusinessProcesses.LBL_BPMN_MODULES_GROUP'),
		entries: []
	};

	var messageTemplateGroup =
	{
		id: 'messageTemplates',
		label: L10n.Term('BusinessProcesses.LBL_BPMN_MESSAGE_TEMPLATE_GROUP'),
		entries: []
	};

	var messageRecipientGroup =
	{
		id: 'messageRecipient',
		label: L10n.Term('BusinessProcesses.LBL_BPMN_MESSAGE_RECIPIENT_GROUP'),
		entries: []
	};

	var messageReportGroup =
	{
		id: 'messageReport',
		label: L10n.Term('BusinessProcesses.LBL_BPMN_MESSAGE_REPORT_GROUP'),
		entries: []
	};

	var variablesGroup = 
	{
		id: 'variables',
		label: L10n.Term('BusinessProcesses.LBL_BPMN_VARIABLES_GROUP'),
		entries: []
	};

	//linkProps                (detailsGroup, element);
	//eventProps               (detailsGroup, element, bpmnFactory, elementRegistry);
	sequenceFlowProps        (detailsGroup         , element, bpmnFactory);

	// 09/08/2021 Paul.  Include the eventBus
	crmProcessProps          (generalGroup         , element, bpmnFactory, elementRegistry, eventBus);
	crmProcessVariables      (variablesGroup       , element, bpmnFactory, elementRegistry, eventBus);
	
	crmStartEventProps       (eventsGroup          , element, bpmnFactory, elementRegistry, eventBus);
	crmTimerStartEventProps  (eventsGroup          , element, bpmnFactory, elementRegistry, eventBus);
	crmTimerIntermediateProps(eventsGroup          , element, bpmnFactory, elementRegistry, eventBus);
	crmEscalationEventProps  (eventsGroup          , element, bpmnFactory, elementRegistry, eventBus);

	crmModuleFilterProps     (modulesGroup         , element, bpmnFactory, elementRegistry, eventBus);
	crmTaskProps             (modulesGroup         , element, bpmnFactory, elementRegistry, eventBus);
	crmUserTaskProps         (modulesGroup         , element, bpmnFactory, elementRegistry, eventBus);
	crmBusinessRuleTaskProps (modulesGroup         , element, bpmnFactory, elementRegistry, eventBus);

	crmMessageTemplateProps  (messageTemplateGroup , element, bpmnFactory, elementRegistry, eventBus);
	crmMessageRecipientProps (messageRecipientGroup, element, bpmnFactory, elementRegistry, eventBus);

	crmMessageReportProps    (messageReportGroup   , element, bpmnFactory, elementRegistry, eventBus);

	// 06/25/2016 Paul.  Array begin cannot be on a new line, otherwise return will return NULL. 
	var arr = 
	[
		generalGroup,
		detailsGroup,
		eventsGroup,
		modulesGroup,
		messageTemplateGroup,
		messageRecipientGroup,
		messageReportGroup,
		variablesGroup
	];
	return arr;
}

// 09/08/2021 Paul.  Include the eventBus
function createMetadataTabGroups(element, bpmnFactory, elementRegistry, eventBus)
{
	var metaDataGroup =
	{
		id: 'metadataGroup',
		label: L10n.Term('BusinessProcesses.LBL_BPMN_METADATA_GROUP'),
		entries: []
	};

	//idProps(metaDataGroup, element, elementRegistry);
	// 06/25/2016 Paul.  We do not use the Executable flag for a process. 
	//processProps(metaDataGroup, element);

	var documentationGroup =
	{
		id: 'documentation',
		label: L10n.Term('BusinessProcesses.LBL_BPMN_DOCUMENTATION_GROUP'),
		entries: []
	};

	documentationProps(documentationGroup, element, bpmnFactory);

	// 06/25/2016 Paul.  Array begin cannot be on a new line, otherwise return will return NULL. 
	var arr =
	[
		metaDataGroup,
		documentationGroup
	];
	return arr;
}

// 09/08/2021 Paul.  Include the eventBus
function createFieldsTabGroups(element, bpmnFactory, elementRegistry, eventBus)
{
	var fieldsGroup =
	{
		id: 'fields',
		label: L10n.Term('BusinessProcesses.LBL_BPMN_FIELDS_GROUP'),
		entries: []
	};

	crmEscalationFieldsProps (fieldsGroup, element, bpmnFactory, elementRegistry, eventBus);
	crmUserTaskFieldsProps   (fieldsGroup, element, bpmnFactory, elementRegistry, eventBus);
	var arr =
	[
		fieldsGroup
	];
	return arr;
}

function CrmPropertiesProvider(eventBus, bpmnFactory, elementRegistry)
{
	PropertiesActivator.call(this, eventBus);
	this.getTabs = function(element)
	{
		// 09/08/2021 Paul.  Include the eventBus
		var generalTab =
		{
			id: 'general',
			label: L10n.Term('BusinessProcesses.LBL_BPMN_GENERAL_TAB'),
			groups: createGeneralTabGroups(element, bpmnFactory, elementRegistry, eventBus)
		};
		var metadataTab =
		{
			id: 'metadata',
			label: L10n.Term('BusinessProcesses.LBL_BPMN_METADATA_TAB'),
			groups: createMetadataTabGroups(element, bpmnFactory, elementRegistry, eventBus)
		};
		var fieldsTab =
		{
			id: 'fields',
			label: L10n.Term('BusinessProcesses.LBL_BPMN_FIELDS_TAB'),
			groups: createFieldsTabGroups(element, bpmnFactory, elementRegistry, eventBus)
		};
		// 06/25/2016 Paul.  Array begin cannot be on a new line, otherwise return will return NULL. 
		var arr =
		[
			generalTab,
			fieldsTab,
			metadataTab
		];
		return arr;
	};
}

inherits(CrmPropertiesProvider, PropertiesActivator);

export default CrmPropertiesProvider;
