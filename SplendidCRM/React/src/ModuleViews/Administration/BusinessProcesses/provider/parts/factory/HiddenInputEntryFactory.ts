/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
var getBusinessObject     = require('bpmn-js/lib/util/ModelUtil').getBusinessObject;
var cmdHelper             = require('bpmn-js-properties-panel/lib/helper/CmdHelper');

function ensureNotNull(prop)
{
	if ( !prop )
	{
		throw new Error(prop + ' must be set.');
	}

	return prop;
}

var setDefaultParameters = function( options )
{
	// default method to fetch the current value of the input field
	var defaultGet = function(element)
	{
		var bo = getBusinessObject(element);
		var res = {};
		var prop = ensureNotNull(options.modelProperty);
		res[prop] = bo.get(prop);
		return res;
	};

	// default method to set a new value to the input field
	var defaultSet = function(element, values)
	{
		var res = {};
		var prop = ensureNotNull(options.modelProperty);
		if (values[prop] !== '')
		{
			res[prop] = values[prop];
		}
		else
		{
			res[prop] = undefined;
		}
		return cmdHelper.updateProperties(element, res);
	};

	// default validation method
	var defaultValidate = function()
	{
		return {};
	};

	return {
		id          : options.id,
		description : ( options.description || '' ),
		get         : ( options.get || defaultGet ),
		set         : ( options.set || defaultSet ),
		validate    : ( options.validate || defaultValidate ),
		html        : ''
	};
};

var textField = function(options, defaultParameters)
{
	var resource       = defaultParameters;
	var label          = options.label || resource.id;
	var dataValueLabel = options.dataValueLabel;
	var canBeDisabled  = !!options.disabled && typeof options.disabled === 'function';

	resource.html =
		'<div style="display: none;">' +
			'<label for="camunda-' + resource.id + '" ' + (canBeDisabled ? 'data-show="isDisabled" ' : '') + (dataValueLabel ? 'data-value="' + dataValueLabel + '"' : '') + '>'+ label +'</label>' +
			'<div class="bpp-field-wrapper" ' + (canBeDisabled ? 'data-show="isDisabled"' : '') + '>' +
				'<input id="camunda-' + resource.id + '" type="text" name="' + options.modelProperty+'" ' + ' />' +
			'</div>';
		'</div>';

	if ( canBeDisabled )
	{
		resource.isDisabled = function()
		{
			return !options.disabled.apply(resource, arguments);
		};
	}
	resource.cssClasses = ['bpp-textfield'];
	return resource;
};

export default function(options)
{
	return textField(options, setDefaultParameters(options));
};
