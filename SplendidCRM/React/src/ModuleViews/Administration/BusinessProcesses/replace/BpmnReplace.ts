var pick              = require( 'lodash/object/pick'        );
var assign            = require( 'lodash/object/assign'      );
var is                = require( 'bpmn-js/lib/util/ModelUtil').is;
var isExpanded        = require( 'bpmn-js/lib/util/DiUtil'   ).isExpanded;
var isEventSubProcess = require( 'bpmn-js/lib/util/DiUtil'   ).isEventSubProcess;

var CUSTOM_PROPERTIES =
[
	'cancelActivity',
	'instantiate',
	'eventGatewayType',
	'triggeredByEvent',
	'isInterrupting'
];

/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved."
 *********************************************************************************************************************/
function BpmnReplace( bpmnFactory, replace, selection, modeling )
{
	/**
	 * Prepares a new business object for the replacement element
	 * and triggers the replace operation.
	 *
	 * @param  {djs.model.Base} element
	 * @param  {Object} target
	 * @param  {Object} [hints]
	 *
	 * @return {djs.model.Base} the newly created element
	 */
	function replaceElement( element, target, hints )
	{
		hints = hints || {};

		var type = target.type;
		var oldBusinessObject = element.businessObject;
		var newBusinessObject = bpmnFactory.create( type );

		let newElement: any =
		{
			type: type,
			businessObject: newBusinessObject
		};

		// initialize custom BPMN extensions
		if ( target.eventDefinitionType )
		{
			newElement.eventDefinitionType = target.eventDefinitionType;
		}

		// initialize special properties defined in target definition
		assign( newBusinessObject, pick( target, CUSTOM_PROPERTIES ) );

		if ( is( oldBusinessObject, 'bpmn:SubProcess' ) )
		{

			newElement.isExpanded = isExpanded( oldBusinessObject );
		}

		// preserve adhoc state while switching collapsed/expanded subprocess
		if ( is( oldBusinessObject, 'bpmn:AdHocSubProcess' ) && target.isExpanded )
		{
			newElement.businessObject = bpmnFactory.create( 'bpmn:AdHocSubProcess' );
		}

		if ( is( oldBusinessObject, 'bpmn:Activity' ) )
		{
			// switch collapsed/expanded subprocesses
			if ( target.isExpanded === true )
			{
				newElement.isExpanded = true;
			}

			// TODO: need also to respect min/max Size
			// copy size, from an expanded subprocess to an expanded alternative subprocess
			// except bpmn:Task, because Task is always expanded
			if ( ( isExpanded( oldBusinessObject ) && !is( oldBusinessObject, 'bpmn:Task' ) ) && target.isExpanded )
			{
				newElement.width = element.width;
				newElement.height = element.height;
			}
		}

		// transform collapsed/expanded pools
		if ( is( oldBusinessObject, 'bpmn:Participant' ) )
		{
			// create expanded pool
			if ( target.isExpanded === true )
			{
				newBusinessObject.processRef = bpmnFactory.create( 'bpmn:Process' );
			} else
			{
				// remove children when transforming to collapsed pool
				hints.moveChildren = false;
			}

			// apply same size
			newElement.width = element.width;
			newElement.height = element.height;
		}

		newBusinessObject.name = oldBusinessObject.name;

		// retain loop characteristics if the target element is not an event sub process
		if ( !isEventSubProcess( newBusinessObject ) )
		{
			newBusinessObject.loopCharacteristics = oldBusinessObject.loopCharacteristics;
		}

		// retain default flow's reference between inclusive <-> exclusive gateways and activities
		if (  ( is( oldBusinessObject, 'bpmn:ExclusiveGateway' ) || is( oldBusinessObject, 'bpmn:InclusiveGateway' ) ||  is( oldBusinessObject, 'bpmn:Activity' ) )
		   && ( is( newBusinessObject, 'bpmn:ExclusiveGateway' ) || is( newBusinessObject, 'bpmn:InclusiveGateway' ) ||  is( newBusinessObject, 'bpmn:Activity' ) )
		   )
		{
			newBusinessObject.default = oldBusinessObject.default;
		}

		if ( oldBusinessObject.isForCompensation )
		{
			newBusinessObject.isForCompensation = true;
		}

		newElement = replace.replaceElement( element, newElement, hints );

		if ( hints.select !== false )
		{
			selection.select( newElement );
		}
		return newElement;
	}

	this.replaceElement = replaceElement;
}

BpmnReplace.$inject = ['bpmnFactory', 'replace', 'selection', 'modeling'];

export default BpmnReplace;
