/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
// 03/02/2022 Paul.  Remvoe unused imports. 
//var domQuery              = require('min-dom/lib/query');
//var getBusinessObject     = require('bpmn-js/lib/util/ModelUtil'            ).getBusinessObject;
var cmdHelper             = require('bpmn-js-properties-panel/lib/helper/CmdHelper');
var eventDefinitionHelper = require('bpmn-js-properties-panel/lib/helper/EventDefinitionHelper');
import duration           from './duration';

function ensureNotNull(prop)
{
	if ( !prop )
	{
		throw new Error(prop + ' must be set.');
	}
	return prop;
}

var durationControl = function(options)
{
	var resource   = new duration(options);
	var label      = options.label || resource.id;
	var canBeShown = !!options.show && typeof options.show === 'function';

	var resourceHtml = document.createElement('div');
	let lbl: any = document.createElement('label');
	resourceHtml.appendChild(lbl);
	lbl.for = 'camunda-' + resource.id;
	if ( canBeShown )
		lbl.setAttribute('data-show', 'isShown');
	lbl.appendChild(document.createTextNode(label));

	var pp = document.createElement('div');
	resourceHtml.appendChild(pp);
	pp.className = 'pp-field-wrapper';
	if ( canBeShown )
		pp.setAttribute('data-show', 'isShown');

	resource.Render(pp);
	resource.html = resourceHtml;

	if ( canBeShown )
	{
		resource.isShown = function()
		{
			return options.show.apply(resource, arguments);
		};
	}

	resource.cssClasses = ['pp-textarea'];

	// 06/28/2016 Paul.  The get operation gets from the element, not from the properties control. 
	resource.get = function(element)
	{
		var res = {};
		var prop = ensureNotNull(this.modelProperty);
		
		// Property on TimerEventDefinition element. 
		var timerEventDefinition = eventDefinitionHelper.getTimerEventDefinition(element);
		res[prop] = timerEventDefinition.get(prop);
		if ( res[prop] === undefined )
			res[prop] = '00:00:00:00';
	
		//console.log('DurationEntryFactory get ' + this.modelProperty + ' = ' + res[prop]);
		if ( this.duration == null )
		{
			this.SetDuration(res[prop]);
			let txtCamunda: any = document.getElementById('camunda-' + resource.id);
			// 07/04/2016 Paul.  jQuery change/trigger is not working. 
			if ( document.createEvent )
			{
				var evt = document.createEvent('HTMLEvents');
				evt.initEvent('change', true, false);
				txtCamunda.dispatchEvent(evt);
			}
			else if ( txtCamunda.fireEvent )
			{
				txtCamunda.fireEvent('onChange');
			}
		}
		return res;
	}

	// 06/28/2016 Paul.  The set operation sets to the element, not from the properties control. 
	resource.set = function(element, values)
	{
		var res = {};
		var prop = ensureNotNull(this.modelProperty);
		if ( values[prop] !== '' )
		{
			res[prop] = values[prop];
		}
		else
		{
			res[prop] = undefined;
		}
		//console.log('DurationEntryFactory set ' + prop + ' = ' + res[prop]);
		
		// Property on TimerEventDefinition element. 
		var timerEventDefinition = eventDefinitionHelper.getTimerEventDefinition(element);
		return cmdHelper.updateBusinessObject(element, timerEventDefinition, res);
	}
	return resource;
};

export default durationControl;

