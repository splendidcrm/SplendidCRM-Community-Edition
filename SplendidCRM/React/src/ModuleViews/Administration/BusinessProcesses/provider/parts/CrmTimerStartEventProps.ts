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
var textInputField        = require('bpmn-js-properties-panel/lib/factory/TextInputEntryFactory');
var selectBoxField        = require('bpmn-js-properties-panel/lib/factory/SelectEntryFactory');
var is                    = require('bpmn-js/lib/util/ModelUtil').is;
var getBusinessObject     = require('bpmn-js/lib/util/ModelUtil').getBusinessObject;
var cmdHelper             = require('bpmn-js-properties-panel/lib/helper/CmdHelper');
var eventDefinitionHelper = require('bpmn-js-properties-panel/lib/helper/EventDefinitionHelper');
import cronEntryFactory   from './factory/CronEntryFactory';

function hasEventDefinition(element, eventDefinition)
{
	var bo = getBusinessObject(element);
	return !!find(bo.eventDefinitions || [], function(definition) { return is(definition, eventDefinition); });
}

function ensureNotNull(prop)
{
	if ( !prop )
	{
		throw new Error(prop + ' must be set.');
	}
	return prop;
}

var setDefaultParameters = function ( options )
{
	// default method to fetch the current value of the input field
	var defaultGet = function (element)
	{
		var res = {};
		var prop = ensureNotNull(options.modelProperty);
		
		// Get from base element. 
		//var bo = getBusinessObject(element);
		//res[prop] = bo.get(prop);
		
		// Get from child Timer element. 
		var timerEventDefinition = eventDefinitionHelper.getTimerEventDefinition(element);
		res[prop] = timerEventDefinition.get(prop);
		return res;
	};

	// default method to set a new value to the input field
	var defaultSet = function (element, values)
	{
		var res = {};
		var prop = ensureNotNull(options.modelProperty);
		if ( values[prop] !== '' )
		{
			res[prop] = values[prop];
		}
		else
		{
			res[prop] = undefined;
		}
		// Set to base element. 
		//return cmdHelper.updateProperties(element, res);
		
		// Set to child Timer element. 
		var timerEventDefinition = eventDefinitionHelper.getTimerEventDefinition(element);
		return cmdHelper.updateBusinessObject(element, timerEventDefinition, res);
	};

	// default validation method
	var defaultValidate = function ()
	{
		return {};
	};

	return {
		id         : options.id,
		description: ( options.description || '' ),
		get        : ( options.get || defaultGet ),
		set        : ( options.set || defaultSet ),
		validate   : ( options.validate || defaultValidate ),
		html       : ''
	};
};

function timerTextField(options)
{
	return textInputField(options, setDefaultParameters(options));
}

function timerSelectBox(options)
{
	return selectBoxField(options, setDefaultParameters(options));
}

// 09/08/2021 Paul.  Include the eventBus
export default function(group, element, bpmnFactory, elementRegistry, eventBus)
{
	if ( is(element, 'bpmn:StartEvent') && hasEventDefinition(element, 'bpmn:TimerEventDefinition') )
	{
		// C:\Web.net\SplendidCRM6\Administration\BusinessProcesses\node_modules\bpmn-js-properties-panel\lib\factory\SelectEntryFactory.js
		group.entries.push(timerSelectBox(
		{
			// 04/19/2019 Paul.  Fields should be all uppercase. 
			id            : 'FREQUENCY_LIMIT_UNITS',
			//description   : L10n.Term('BusinessProcesses.LBL_BPMN_FREQUENCY_LIMIT_UNITS_DESCRIPTION'),
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_FREQUENCY_LIMIT_UNITS'),
			modelProperty : 'FREQUENCY_LIMIT_UNITS',
			selectOptions :
				[
					{ value: ''        , name: '' },
					{ value: 'day'     , name: L10n.Term('.workflow_freq_limit_dom.day'    ) },
					{ value: 'week'    , name: L10n.Term('.workflow_freq_limit_dom.week'   ) },
					{ value: 'month'   , name: L10n.Term('.workflow_freq_limit_dom.month'  ) },
					{ value: 'quarter' , name: L10n.Term('.workflow_freq_limit_dom.quarter') },
					{ value: 'year'    , name: L10n.Term('.workflow_freq_limit_dom.year'   ) },
					{ value: 'hours'   , name: L10n.Term('.workflow_freq_limit_dom.hours'  ) },
					{ value: 'minutes' , name: L10n.Term('.workflow_freq_limit_dom.minutes') },
					{ value: 'records' , name: L10n.Term('.workflow_freq_limit_dom.records') }
				],
		}));
		
		group.entries.push(timerTextField(
		{
			// 04/19/2019 Paul.  Fields should be all uppercase. 
			id            : 'FREQUENCY_LIMIT_VALUE',
			//description   : L10n.Term('BusinessProcesses.LBL_BPMN_FREQUENCY_LIMIT_VALUE_DESCRIPTION'),
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_FREQUENCY_LIMIT_VALUE'),
			modelProperty : 'FREQUENCY_LIMIT_VALUE',
			//validate: function(element)
			//{
			//	var units;
			//	for ( var i = 0; i < group.entries.length; i++ )
			//	{
			//		if ( group.entries[i].id == 'frequency_limit_units' )
			//		{
			//			units = group.entries[i].get(element).frequency_limit_units;
			//			break;
			//		}
			//	}
			//	var value = this.get(element).frequency_limit_value;
			//	//alert(dumpObj(group.entries[2]));
			//	//alert(dumpObj(group.entries[2].get(element)));
			//	if ( !(units === undefined || units === '') && (value === undefined || value === '') )
			//	{
			//		return { frequency_limit_value: 'Must provide a value' };
			//	}
			//},
			//disabled: function(element)
			//{
			//	var units;
			//	for ( var i = 0; i < group.entries.length; i++ )
			//	{
			//		if ( group.entries[i].id == 'frequency_limit_units' )
			//		{
			//			units = group.entries[i].get(element).frequency_limit_units;
			//			break;
			//		}
			//	}
			//	return units === undefined || units === '';
			//}
		}));
		
		group.entries.push(cronEntryFactory(
		{
			id            : 'JOB_INTERVAL',
			//description   : L10n.Term('BusinessProcesses.LBL_BPMN_JOB_INTERVAL_DESCRIPTION'),
			label         : L10n.Term('BusinessProcesses.LBL_BPMN_JOB_INTERVAL'),
			modelProperty : 'JOB_INTERVAL'
		}));
	}
};
