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

var find              = require('lodash/collection/find');
var entryFactory      = require('bpmn-js-properties-panel/lib/factory/EntryFactory');
var is                = require('bpmn-js/lib/util/ModelUtil').is;
var getBusinessObject = require('bpmn-js/lib/util/ModelUtil').getBusinessObject;

function hasEventDefinition(element, eventDefinition)
{
	var bo = getBusinessObject(element);
	return !!find(bo.eventDefinitions || [], function(definition) { return is(definition, eventDefinition); });
}

// 09/08/2021 Paul.  Include the eventBus
export default function(group, element, bpmnFactory, elementRegistry, eventBus)
{
	if ( is(element, 'bpmn:StartEvent') && !hasEventDefinition(element, 'bpmn:TimerEventDefinition') )
	{
		// C:\Web.net\SplendidCRM6\Administration\BusinessProcesses\node_modules\bpmn-js-properties-panel\lib\factory\SelectEntryFactory.js
		group.entries.push(entryFactory.selectBox(
		{ 
			id            : 'RECORD_TYPE',
			//description   : L10n.Term('BusinessProcesses.LBL_BPMN_RECORD_TYPE_DESCRIPTION'),
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_RECORD_TYPE'),
			modelProperty : 'RECORD_TYPE',
			selectOptions :
			[
				{ value: 'all'   , name: L10n.Term('.workflow_record_type_dom.all'   ) },
				{ value: 'new'   , name: L10n.Term('.workflow_record_type_dom.new'   ) },
				{ value: 'update', name: L10n.Term('.workflow_record_type_dom.update') }
			]
		}));
	}
};
