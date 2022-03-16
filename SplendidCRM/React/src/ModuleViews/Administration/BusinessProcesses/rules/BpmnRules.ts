var find                 = require('lodash/collection/find'                         );
var any                  = require('lodash/collection/any'                          );
var every                = require('lodash/collection/every'                        );
var filter               = require('lodash/collection/filter'                       );
var forEach              = require('lodash/collection/forEach'                      );
// 03/02/2022 Paul.  Must switch to from instead of require to support diagram-js >= 1.0. 
import inherits          from 'inherits';
//var inherits             = require('inherits'                                       );
var getParents           = require('bpmn-js/lib/features/modeling/util/ModelingUtil').getParents;
var is                   = require('bpmn-js/lib/util/ModelUtil'                     ).is;
var isAny                = require('bpmn-js/lib/features/modeling/util/ModelingUtil').isAny;
var getBusinessObject    = require('bpmn-js/lib/util/ModelUtil'                     ).getBusinessObject;
var isExpanded           = require('bpmn-js/lib/util/DiUtil'                        ).isExpanded;
var isEventSubProcess    = require('bpmn-js/lib/util/DiUtil'                        ).isEventSubProcess;
var isInterrupting       = require('bpmn-js/lib/util/DiUtil'                        ).isInterrupting;
// 03/02/2022 Paul.  Must switch to from instead of require to support diagram-js >= 1.0. 
import RuleProvider      from 'diagram-js/lib/features/rules/RuleProvider'     ;
//var RuleProvider         = require('diagram-js/lib/features/rules/RuleProvider'     );
var isBoundaryAttachment = require('bpmn-js/lib/features/snapping/BpmnSnappingUtil' ).getBoundaryAttachment;

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
function BpmnRules(eventBus)
{
	RuleProvider.call(this, eventBus);
}

inherits(BpmnRules, RuleProvider);

BpmnRules.$inject = [ 'eventBus' ];

export default BpmnRules;

BpmnRules.prototype.init = function()
{
	this.addRule('connection.create', function(context)
	{
		var source = context.source;
		var target = context.target;
		return canConnect(source, target);
	});

	this.addRule('connection.reconnectStart', function(context)
	{
		var connection = context.connection;
		var source     = context.hover || context.source;
		var target     = connection.target;
		return canConnect(source, target, connection);
	});

	this.addRule('connection.reconnectEnd', function(context)
	{
		var connection = context.connection;
		var source     = connection.source;
		var target     = context.hover || context.target;
		return canConnect(source, target, connection);
	});

	this.addRule('connection.updateWaypoints', function(context)
	{
		// OK! but visually ignore
		return null;
	});

	this.addRule('shape.resize', function(context)
	{
		var shape     = context.shape;
		var newBounds = context.newBounds;
		return canResize(shape, newBounds);
	});

	this.addRule('elements.move', function(context)
	{
		var target   = context.target;
		var shapes   = context.shapes;
		var position = context.position;
		return canAttach(shapes, target, null, position) || canReplace(shapes, target, position) || canMove(shapes, target, position);
	});

	this.addRule([ 'shape.create', 'shape.append' ], function(context)
	{
		var target   = context.target;
		var shape    = context.shape;
		var source   = context.source;
		var position = context.position;
		return canAttach([ shape ], target, source, position) || canCreate(shape, target, source, position);
	});

	this.addRule('element.copy', function(context)
	{
		var collection = context.collection;
		var element    = context.element;
		return canCopy(collection, element);
	});

	this.addRule('element.paste', function(context)
	{
		var parent   = context.parent;
		var element  = context.element;
		var position = context.position;
		var source   = context.source;
		var target   = context.target;
		if ( source || target )
		{
			return canConnect(source, target);
		}
		return canAttach([ element ], parent, null, position) || canCreate(element, parent, null, position);
	});

	this.addRule('elements.paste', function(context)
	{
		var tree   = context.tree;
		var target = context.target;
		return canPaste(tree, target);
	});

	this.addRule([ 'elements.delete' ], function(context)
	{
		// do not allow deletion of labels
		return filter(context.elements, function(e) {
			return !isLabel(e);
		});
	});
};

BpmnRules.prototype.canConnectMessageFlow     = canConnectMessageFlow;
BpmnRules.prototype.canConnectSequenceFlow    = canConnectSequenceFlow;
BpmnRules.prototype.canConnectDataAssociation = canConnectDataAssociation;
BpmnRules.prototype.canConnectAssociation     = canConnectAssociation;
BpmnRules.prototype.canMove                   = canMove;
BpmnRules.prototype.canAttach                 = canAttach;
BpmnRules.prototype.canReplace                = canReplace;
BpmnRules.prototype.canDrop                   = canDrop;
BpmnRules.prototype.canInsert                 = canInsert;
BpmnRules.prototype.canCreate                 = canCreate;
BpmnRules.prototype.canConnect                = canConnect;
BpmnRules.prototype.canResize                 = canResize;
BpmnRules.prototype.canCopy                   = canCopy;

/**
 * Utility functions for rule checking
 */

function nonExistantOrLabel(element)
{
	return !element || isLabel(element);
}

function isSame(a, b)
{
	return a === b;
}

function getOrganizationalParent(element)
{
	var bo = getBusinessObject(element);

	while ( bo && !is(bo, 'bpmn:Process') )
	{
		if (is(bo, 'bpmn:Participant'))
		{
			return bo.processRef || bo;
		}
		bo = bo.$parent;
	}
	return bo;
}

function isTextAnnotation(element)
{
	return is(element, 'bpmn:TextAnnotation');
}

function isCompensationBoundary(element)
{
	return is(element, 'bpmn:BoundaryEvent') && hasEventDefinition(element, 'bpmn:CompensateEventDefinition');
}

function isForCompensation(e)
{
	return getBusinessObject(e).isForCompensation;
}

function isSameOrganization(a, b)
{
	var parentA = getOrganizationalParent(a);
	var parentB = getOrganizationalParent(b);
	return parentA === parentB;
}

function isMessageFlowSource(element)
{
	return is(element, 'bpmn:InteractionNode') && !isForCompensation(element) && (!is(element, 'bpmn:Event') || (is(element, 'bpmn:ThrowEvent') && hasEventDefinitionOrNone(element, 'bpmn:MessageEventDefinition')));
}

function isMessageFlowTarget(element)
{
	return is(element, 'bpmn:InteractionNode') && !isForCompensation(element) && (!is(element, 'bpmn:Event') || (is(element, 'bpmn:CatchEvent') && hasEventDefinitionOrNone(element, 'bpmn:MessageEventDefinition')));
}

function getScopeParent(element)
{
	var bo = getBusinessObject(element);
	if ( is(bo, 'bpmn:Participant') )
	{
		return null;
	}
	while ( bo )
	{
		bo = bo.$parent;
		if ( is(bo, 'bpmn:FlowElementsContainer') )
		{
			return bo;
		}
	}
	return bo;
}

function isSameScope(a, b)
{
	var scopeParentA = getScopeParent(a);
	var scopeParentB = getScopeParent(b);
	return scopeParentA && (scopeParentA === scopeParentB);
}

function hasEventDefinition(element, eventDefinition)
{
	var bo = getBusinessObject(element);
	return !!find(bo.eventDefinitions || [], function(definition) {
		return is(definition, eventDefinition);
	});
}

function hasEventDefinitionOrNone(element, eventDefinition)
{
	var bo = getBusinessObject(element);
	return (bo.eventDefinitions || []).every(function(definition) {
		return is(definition, eventDefinition);
	});
}

function isSequenceFlowSource(element)
{
	return is(element, 'bpmn:FlowNode') && !is(element, 'bpmn:EndEvent') && !isEventSubProcess(element) && !(is(element, 'bpmn:IntermediateThrowEvent') && hasEventDefinition(element, 'bpmn:LinkEventDefinition')) && !isCompensationBoundary(element) && !isForCompensation(element);
}

function isSequenceFlowTarget(element)
{
	return is(element, 'bpmn:FlowNode') && !is(element, 'bpmn:StartEvent') && !is(element, 'bpmn:BoundaryEvent') && !isEventSubProcess(element) && !(is(element, 'bpmn:IntermediateCatchEvent') && hasEventDefinition(element, 'bpmn:LinkEventDefinition')) && !isForCompensation(element);
}

function isEventBasedTarget(element)
{
	// 08/23/2016 Paul.  Add Task (Task, UserTask, BusinessRuleTask) and ExclusiveGateway. 
	return is(element, 'bpmn:ReceiveTask') || is(element, 'bpmn:Task') || is(element, 'bpmn:ExclusiveGateway') || (is(element, 'bpmn:IntermediateCatchEvent') && (hasEventDefinition(element, 'bpmn:MessageEventDefinition') || hasEventDefinition(element, 'bpmn:TimerEventDefinition') || hasEventDefinition(element, 'bpmn:ConditionalEventDefinition') || hasEventDefinition(element, 'bpmn:SignalEventDefinition')));
}

function isLabel(element)
{
	return element.labelTarget;
}

function isConnection(element)
{
	return element.waypoints;
}

function isParent(possibleParent, element)
{
	var allParents = getParents(element);
	return allParents.indexOf(possibleParent) !== -1;
}

function canConnect(source, target, connection?)
{
	if ( nonExistantOrLabel(source) || nonExistantOrLabel(target) )
	{
		return null;
	}

	// See https://github.com/bpmn-io/bpmn-js/issues/178
	// as a workround we disallow connections with same
	// target and source element.
	// This rule must be removed if a auto layout for this
	// connections is implemented.
	if ( isSame(source, target) )
	{
		return false;
	}

	if ( !is(connection, 'bpmn:DataAssociation') )
	{
		if ( canConnectMessageFlow(source, target) )
		{
			return { type: 'bpmn:MessageFlow' };
		}
		if ( canConnectSequenceFlow(source, target) )
		{
			return { type: 'bpmn:SequenceFlow' };
		}
	}

	var connectDataAssociation = canConnectDataAssociation(source, target);

	if ( connectDataAssociation )
	{
		return connectDataAssociation;
	}
	if ( isCompensationBoundary(source) && isForCompensation(target) )
	{
		return { type: 'bpmn:Association', associationDirection: 'One' };
	}
	if ( is(connection, 'bpmn:Association') && canConnectAssociation(source, target) )
	{
		return { type: 'bpmn:Association' };
	}
	if ( isTextAnnotation(source) || isTextAnnotation(target) )
	{
		return { type: 'bpmn:Association' };
	}
	return false;
}

/**
 * Can an element be dropped into the target element
 *
 * @return {Boolean}
 */
function canDrop(element, target, position)
{
	// can move labels everywhere
	if ( isLabel(element) && !isConnection(target) )
	{
		return true;
	}
	// disallow to create elements on collapsed pools
	if ( is(target, 'bpmn:Participant') && !isExpanded(target) )
	{
		return false;
	}
	// allow to create new participants on
	// on existing collaboration and process diagrams
	if ( is(element, 'bpmn:Participant') )
	{
		return is(target, 'bpmn:Process') || is(target, 'bpmn:Collaboration');
	}
	// allow creating lanes on participants and other lanes only
	if ( is(element, 'bpmn:Lane') )
	{
		return is(target, 'bpmn:Participant') || is(target, 'bpmn:Lane');
	}
	if ( is(element, 'bpmn:BoundaryEvent') )
	{
		return false;
	}
	// drop flow elements onto flow element containers
	// and participants
	if ( is(element, 'bpmn:FlowElement') || is(element, 'bpmn:DataAssociation') )
	{
		if ( is(target, 'bpmn:FlowElementsContainer') )
		{
			return isExpanded(target);
		}
		return isAny(target, [ 'bpmn:Participant', 'bpmn:Lane' ]);
	}
	if ( is(element, 'bpmn:Artifact') )
	{
		return isAny(target, [
			'bpmn:Collaboration',
			'bpmn:Lane',
			'bpmn:Participant',
			'bpmn:Process',
			'bpmn:SubProcess'
		]);
	}
	if (is(element, 'bpmn:MessageFlow'))
	{
		return is(target, 'bpmn:Collaboration');
	}
	return false;
}

function canPaste(tree, target)
{
	var topLevel = tree[0];
	var participants;

	if (is(target, 'bpmn:Collaboration'))
	{
		return every(topLevel, function(e) {
			return e.type === 'bpmn:Participant';
		});
	}
	if ( is(target, 'bpmn:Process') )
	{
		participants = any(topLevel, function(e)
		{
			return e.type === 'bpmn:Participant';
		});
		return !(participants && target.children.length > 0);
	}
	// disallow to create elements on collapsed pools
	if ( is(target, 'bpmn:Participant') && !isExpanded(target) )
	{
		return false;
	}
	if ( is(target, 'bpmn:FlowElementsContainer') )
	{
		return isExpanded(target);
	}
	return isAny(target, [
		'bpmn:Collaboration',
		'bpmn:Lane',
		'bpmn:Participant',
		'bpmn:Process',
		'bpmn:SubProcess'
	]);
}

function isBoundaryEvent(element)
{
	return !isLabel(element) && is(element, 'bpmn:BoundaryEvent');
}

function isLane(element)
{
	return is(element, 'bpmn:Lane');
}

/**
 * We treat IntermediateThrowEvents as boundary events during create,
 * this must be reflected in the rules.
 */
function isBoundaryCandidate(element)
{
	return isBoundaryEvent(element) || (is(element, 'bpmn:IntermediateThrowEvent') && !element.parent);
}


function canAttach(elements, target, source, position)
{
	if ( !Array.isArray(elements) )
	{
		elements = [ elements ];
	}
	// disallow appending as boundary event
	if ( source )
	{
		return false;
	}
	// only (re-)attach one element at a time
	if ( elements.length !== 1 )
	{
		return false;
	}

	var element = elements[0];

	// do not attach labels
	if ( isLabel(element) )
	{
		return false;
	}
	// only handle boundary events
	if ( !isBoundaryCandidate(element) )
	{
		return false;
	}
	// allow default move operation
	if ( !target )
	{
		return true;
	}
	// disallow drop on event sub processes
	if ( isEventSubProcess(target) ) 
	{
		return false;
	}
	// only allow drop on non compensation activities
	if ( !is(target, 'bpmn:Activity') || isForCompensation(target) )
	{
		return false;
	}
	// only attach to subprocess border
	if ( position && !isBoundaryAttachment(position, target) )
	{
		return false;
	}
	return 'attach';
}


/**
 * Defines how to replace elements for a given target.
 *
 * Returns an array containing all elements which will be replaced.
 *
 * @example
 *
 *  [{ id: 'IntermediateEvent_2',
 *     type: 'bpmn:StartEvent'
 *   },
 *   { id: 'IntermediateEvent_5',
 *     type: 'bpmn:EndEvent'
 *   }]
 *
 * @param  {Array} elements
 * @param  {Object} target
 *
 * @return {Object} an object containing all elements which have to be replaced
 */
function canReplace(elements, target, position)
{
	if ( !target )
	{
		return false;
	}

	var canExecute =
	{
		replacements: []
	};

	forEach(elements, function(element)
	{
		// replace a non-interrupting start event by a blank interrupting start event
		// when the target is not an event sub process
		if ( !isEventSubProcess(target) )
		{
			if ( is(element, 'bpmn:StartEvent') && !isInterrupting(element) && element.type !== 'label' && canDrop(element, target, position) )
			{
				canExecute.replacements.push({ oldElementId: element.id, newElementType: 'bpmn:StartEvent' });
			}
		}
		if ( !is(target, 'bpmn:Transaction') )
		{
			if ( hasEventDefinition(element, 'bpmn:CancelEventDefinition') && element.type !== 'label' )
			{
				if (is(element, 'bpmn:EndEvent') && canDrop(element, target, position))
				{
					canExecute.replacements.push({ oldElementId: element.id, newElementType: 'bpmn:EndEvent' });
				}
				if (is(element, 'bpmn:BoundaryEvent') && canAttach(element, target, null, position))
				{
					canExecute.replacements.push({ oldElementId: element.id, newElementType: 'bpmn:BoundaryEvent' });
				}
			}
		}
	});
	return canExecute.replacements.length ? canExecute : false;
}

function canMove(elements, target, position?)
{
	// do not move selection containing boundary events
	if ( any(elements, isBoundaryEvent) )
	{
		return false;
	}
	// do not move selection containing lanes
	if ( any(elements, isLane) )
	{
		return false;
	}
	// allow default move check to start move operation
	if ( !target )
	{
		return true;
	}
	return elements.every(function(element) {
		return canDrop(element, target, position);
	});
}

function canCreate(shape, target, source, position)
{
	if ( !target )
	{
		return false;
	}
	if ( isLabel(target) )
	{
		return null;
	}
	if ( isSame(source, target) )
	{
		return false;
	}
	// ensure we do not drop the element
	// into source
	if ( source && isParent(source, target) )
	{
		return false;
	}
	return canDrop(shape, target, position) || canInsert(shape, target, position);
}

function canResize(shape, newBounds)
{
	if ( is(shape, 'bpmn:SubProcess') )
	{
		return (!!isExpanded(shape)) && ( !newBounds || (newBounds.width >= 100 && newBounds.height >= 80) );
	}
	if ( is(shape, 'bpmn:Lane') )
	{
		return !newBounds || (newBounds.width >= 130 && newBounds.height >= 60);
	}
	if ( is(shape, 'bpmn:Participant') )
	{
		return !newBounds || (newBounds.width >= 250 && newBounds.height >= 50);
	}
	if ( isTextAnnotation(shape) )
	{
		return true;
	}
	return false;
}

function canConnectAssociation(source, target)
{
	// do not connect connections
	if (isConnection(source) || isConnection(target))
	{
		return false;
	}

	// connect if different parent
	return !isParent(target, source) && !isParent(source, target);
}

function canConnectMessageFlow(source, target)
{
	return isMessageFlowSource(source) && isMessageFlowTarget(target) && !isSameOrganization(source, target);
}

function canConnectSequenceFlow(source, target)
{
	return isSequenceFlowSource(source) && isSequenceFlowTarget(target) && isSameScope(source, target) && !(is(source, 'bpmn:EventBasedGateway') && !isEventBasedTarget(target));
}


function canConnectDataAssociation(source, target)
{
	if ( isAny(source, [ 'bpmn:DataObjectReference', 'bpmn:DataStoreReference' ]) && isAny(target, [ 'bpmn:Activity', 'bpmn:ThrowEvent' ]) )
	{
		return { type: 'bpmn:DataInputAssociation' };
	}
	if ( isAny(target, [ 'bpmn:DataObjectReference', 'bpmn:DataStoreReference' ]) && isAny(source, [ 'bpmn:Activity', 'bpmn:CatchEvent' ]) )
	{
		return { type: 'bpmn:DataOutputAssociation' };
	}
	return false;
}

function canInsert(shape, flow, position)
{
	// return true if we can drop on the
	// underlying flow parent
	//
	// at this point we are not really able to talk
	// about connection rules (yet)
	return ( isAny(flow, [ 'bpmn:SequenceFlow', 'bpmn:MessageFlow' ]) && is(shape, 'bpmn:FlowNode') && !is(shape, 'bpmn:BoundaryEvent') && canDrop(shape, flow.parent, position));
}

function contains(collection, element)
{
	return (collection && element) && collection.indexOf(element) !== -1;
}

function canCopy(collection, element)
{
	if ( is(element, 'bpmn:Lane') && !contains(collection, element.parent) )
	{
		return false;
	}
	if ( is(element, 'bpmn:BoundaryEvent') && !contains(collection, element.host) )
	{
		return false;
	}
	return true;
}
