/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
var getBusinessObject    = require('bpmn-js/lib/util/ModelUtil').getBusinessObject;
var getExtensionElements = require('bpmn-js-properties-panel/lib/helper/ExtensionElementsHelper').getExtensionElements;

let FormHelper: any = {};

export default FormHelper;

/**
 * Return all form fields existing in the business object, and
 * an empty array if none exist.
 *
 * @param  {djs.model.Base} element
 *
 * @return {Array} a list of form field objects
 */
FormHelper.getFormFields = function(element)
{
	var bo = getBusinessObject(element);
	var formData = getExtensionElements(bo, 'crm:CrmMessageRecipients');

	if (typeof formData !== 'undefined')
	{
		return formData[0].fields;
	}
	else
	{
		return [];
	}
};


/**
 * Get a form field from the business object at given index
 *
 * @param {djs.model.Base} element
 * @param {number} idx
 *
 * @return {ModdleElement} the form field
 */
FormHelper.getFormField = function(element, idx)
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


/**
 * Get all constraints for a specific form field from the business object
 *
 * @param  {ModdleElement} formField
 *
 * @return {Array<ModdleElement>} a list of constraint objects
 */
/*
FormHelper.getConstraints = function(formField)
{
	if (formField && formField.validation && formField.validation.constraints)
	{
		return formField.validation.constraints;
	}
	return [];
};
*/

/**
 * Get all camunda:value objects for a specific form field from the business object
 *
 * @param  {ModdleElement} formField
 *
 * @return {Array<ModdleElement>} a list of camunda:value objects
 */
/*
FormHelper.getEnumValues = function(formField)
{
	if (formField && formField.values)
	{
		return formField.values;
	}
	return [];
};
*/
