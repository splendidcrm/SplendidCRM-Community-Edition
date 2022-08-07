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

var is                = require('bpmn-js/lib/util/ModelUtil').is;
var getBusinessObject = require('bpmn-js/lib/util/ModelUtil').getBusinessObject;
var isAny             = require('bpmn-js/lib/features/modeling/util/ModelingUtil').isAny;
var cmdHelper         = require('bpmn-js-properties-panel/lib/helper/CmdHelper');
var elementHelper     = require('bpmn-js-properties-panel/lib/helper/ElementHelper');
var entryFactory      = require('bpmn-js-properties-panel/lib/factory/EntryFactory');

var CONDITIONAL_SOURCES =
[
	'bpmn:Activity',
	'bpmn:ExclusiveGateway',
	'bpmn:InclusiveGateway',
	'bpmn:ComplexGateway'
];

function isConditionalSource(element)
{
	return isAny(element, CONDITIONAL_SOURCES);
}

export default function(group, element, bpmnFactory)
{
	if ( is(element, 'bpmn:SequenceFlow') && isConditionalSource(element.source) )
	{
		//console.log('bpmn:SequenceFlow');
		// 05/10/2022 Paul.  Changed to textBox. 
		group.entries.push(entryFactory.textBox(
		{
			id            : 'condition',
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_EXPRESSION'),
			modelProperty : 'condition',
			minRows       : 8,
			expandable    : true,
			get : function(element)
			{
				var bo = getBusinessObject(element);
				var conditionExpression = bo.conditionExpression;
				let values: any = {};
				if ( conditionExpression )
				{
					values.condition = conditionExpression.get('body');
				}
				return values;
			},
			set : function(element, values)
			{
				var commands = [];
				var conditionProps =
				{
					body: undefined
				};

				var condition = values.condition;
				conditionProps.body = condition;
				var update =
				{
					'conditionExpression': undefined
				};
				var bo = getBusinessObject(element);
				update.conditionExpression = elementHelper.createElement('bpmn:FormalExpression', conditionProps, bo, bpmnFactory );
				var source = element.source;
				// if default-flow, remove default-property from source
				if ( source.businessObject.default === bo )
				{
					commands.push(cmdHelper.updateProperties(source, { 'default': undefined }));
				}
				commands.push(cmdHelper.updateBusinessObject(element, bo, update));
				return commands;
			},
			validate : function(element, values)
			{
				let validationResult: any = {};
				if ( !values.condition )
				{
					validationResult.condition = 'Must provide a value';
				}
				return validationResult;
			}
		}));
	}
};

