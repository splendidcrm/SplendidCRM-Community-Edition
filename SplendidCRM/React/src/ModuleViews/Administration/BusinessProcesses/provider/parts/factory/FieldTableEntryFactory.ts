/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */
var cmdHelper  = require('bpmn-js-properties-panel/lib/helper/CmdHelper');
// 03/01/2022 Paul.  Updated packaging for min-dom. 
var minDom     = require('min-dom');
var domQuery   = minDom.query  ;
var domAttr    = minDom.attr   ;
var domClosest = minDom.closest;
var domify     = minDom.domify ;
var filter     = require('lodash/collection/filter');
var forEach    = require('lodash/collection/forEach');
var keys       = require('lodash/object/keys');

//var TABLE_ROW_DIV_SNIPPET = '<div class="bpp-field-wrapper bpp-table-row">';
//var DELETE_ROW_BUTTON_SNIPPET = '<button class="clear" data-action="deleteElement">' +
//                                  '<span>X</span>' +
//                                '</button>';

function createInputTemplate(template, properties, listValues, canRemove, value)
{
	var columns = properties.length;
	//forEach ( properties, function(prop)
	for ( var i = 0; i < columns; i++ )
	{
		//template += '<input class="bpp-table-row-columns-' + columns + ' ' + (canRemove ? 'bpp-table-row-removable' : '') + '" ' +
		//            'id="camunda-table-row-cell-input-value" ' + 'type="text" ' + 'name="' + prop + '" />';
		var prop = properties[i];
		var list = null;
		if ( listValues !== undefined )
		{
			if ( i < listValues.length )
				list = listValues[i];
		}
		if ( list != null && list !== undefined )
		{
			let input: any = document.createElement('select');
			template.appendChild(input);
			input.className = 'bpp-table-row-columns-' + columns + ' ' + (canRemove ? 'bpp-table-row-removable' : '');
			input.id        = 'camunda-table-row-cell-input-value';
			input.name      = prop;
			// 08/09/2016 Paul.  Add blank item to the top so that the user will be required to select a value and the change event will fire. 
			let opt: any = document.createElement('option');
			input.appendChild(opt);
			for ( var j = 0; j < list.length; j++ )
			{
				opt = document.createElement('option');
				input.appendChild(opt);
				opt.value = list[j].value;
				opt.appendChild(document.createTextNode(list[j].name));
				if ( value !== undefined && value.name == list[j].value )
					opt.setAttribute('selected', 'selected');
			}
		}
		else
		{
			let input: any = document.createElement('input');
			template.appendChild(input);
			input.className = 'bpp-table-row-columns-' + columns + ' ' + (canRemove ? 'bpp-table-row-removable' : '');
			input.id        = 'camunda-table-row-cell-input-value';
			input.type      = 'text';
			input.name      = prop;
		}
	} //);
	return template;
}

function createInputRowTemplate(properties, listValues, canRemove, value?)
{
	//var template = TABLE_ROW_DIV_SNIPPET;
	//template += createInputTemplate(properties, canRemove);
	//template += canRemove ? DELETE_ROW_BUTTON_SNIPPET : '';
	//template += '</div>';
	var template = document.createElement('div');
	template.className = 'bpp-field-wrapper bpp-table-row';
	createInputTemplate(template, properties, listValues, canRemove, value);
	if ( canRemove )
	{
		var btnDelete = document.createElement('button');
		template.appendChild(btnDelete);
		btnDelete.className = 'clear';
		var attDataAction = document.createAttribute('data-action');
		btnDelete.attributes.setNamedItem(attDataAction)
		attDataAction.value = 'deleteElement';
		var spnX = document.createElement('span');
		btnDelete.appendChild(spnX);
		spnX.appendChild(document.createTextNode('X'));
	}
	return template;
}

function createLabelTemplate(template, labels)
{
	var columns = labels.length;
	forEach(labels, function(label)
	{
		//template += '<label class="bpp-table-row-columns-' + columns + '">' + label + '</label>';
		let lbl: any = document.createElement('label');
		template.appendChild(lbl);
		lbl.className = 'bpp-table-row-columns-' + columns;
		lbl.appendChild(document.createTextNode(label));
	});
	return template;
}

function createLabelRowTemplate(labels)
{
	//var template = TABLE_ROW_DIV_SNIPPET;
	//template += createLabelTemplate(labels);
	//template += '</div>';
	var template = document.createElement('div');
	template.className = 'bpp-field-wrapper bpp-table-row';
	createLabelTemplate(template, labels);
	return template;
}

function pick(elements, properties)
{
	return (elements || []).map(function(elem)
	{
		var newElement = {};
		forEach(properties, function(prop)
		{
			newElement[prop] = elem[prop] || '';
		});
		return newElement;
	});
}

function diff(element, node, values, oldValues, editable)
{
	return filter(values, function(value, idx)
	{
		return !valueEqual(element, node, value, oldValues[idx], editable, idx);
	});
}

function valueEqual(element, node, value, oldValue, editable, idx)
{
	if ( value && !oldValue )
	{
		return false;
	}
	var allKeys = keys(value).concat(keys(oldValue));

	return allKeys.every(function(key)
	{
		var n = value[key] || undefined;
		var o = oldValue[key] || undefined;
		return !editable(element, node, key, idx) || n === o;
	});
}

function getEntryNode(node)
{
	return domClosest(node, '[data-entry]', true);
}

function getContainer(node)
{
	return domQuery('div[data-list-entry-container]', node);
}

/**
 * @param  {Object} options
 * @param  {string} options.id
 * @param  {Array<string>} options.modelProperties
 * @param  {Array<string>} options.labels
 * @param  {Function} options.getElements - this callback function must return a list of business object items
 * @param  {Function} options.removeElement
 * @param  {Function} options.addElement
 * @param  {Function} options.updateElement
 * @param  {Function} options.editable
 * @param  {Function} options.setControlValue
 * @param  {Function} options.show
 *
 * @return {Object}
 */
export default function(options)
{
	var id              = options.id;
	var modelProperties = options.modelProperties;
	var labels          = options.labels;
	var labelRow        = createLabelRowTemplate(labels);
	var getElements     = options.getElements;
	var removeElement   = options.removeElement;
	var canRemove       = typeof removeElement === 'function';
	var addElement      = options.addElement;
	var canAdd          = typeof addElement === 'function';
	var addLabel        = options.addLabel || 'Add Value';
	var updateElement   = options.updateElement;
	var canUpdate       = typeof updateElement === 'function';
	var editable        = options.editable || function() { return true; };
	var setControlValue = options.setControlValue;
	var show            = options.show;
	var canBeShown      = typeof show === 'function';
	var listValues      = options.listValues;

	var elements = function(element, node, invalidValues?)
	{
		return pick(getElements(element, node), modelProperties);
	};

	//var objHtml = ( canAdd ? '<div class="bpp-table-add-row" ' + (canBeShown ? 'data-show="show"' : '') + '>' + '<label>' + addLabel + '</label>' + '<button class="add" data-action="addElement"><span>+</span></button>' + '</div>' : '') +
	//      '<div class="bpp-table" data-show="showTable">' +
	//        '<div class="bpp-field-wrapper bpp-table-row">' + labelRow + '</div>' +
	//        '<div data-list-entry-container></div>' +
	//      '</div>';

	var objHtml = document.createElement('div');
	if ( canAdd )
	{
		var divAddRow = document.createElement('div');
		objHtml.appendChild(divAddRow);
		divAddRow.className = 'bpp-table-add-row';
		if ( canBeShown )
		{
			var attDataShow = document.createAttribute('data-show');
			divAddRow.attributes.setNamedItem(attDataShow);
			attDataShow.value = 'show';
		}
		let lbl: any = document.createElement('label');
		divAddRow.appendChild(lbl);
		lbl.appendChild(document.createTextNode(addLabel));
		var btnAddElement = document.createElement('button');
		divAddRow.appendChild(btnAddElement);
		btnAddElement.className = 'add';
		var attDataAction = document.createAttribute('data-action');
		btnAddElement.attributes.setNamedItem(attDataAction);
		attDataAction.value = 'addElement';
		var spnPlus = document.createElement('span');
		btnAddElement.appendChild(spnPlus);
		spnPlus.appendChild(document.createTextNode('+'));
	}
	var divTable = document.createElement('div');
	objHtml.appendChild(divTable);
	divTable.className = 'bpp-table';
	var attDataShow = document.createAttribute('data-show');
	divTable.attributes.setNamedItem(attDataShow);
	attDataShow.value = 'showTable';
	//var divLabelRow = document.createElement('div');
	//divTable.appendChild(divLabelRow);
	//divLabelRow.className = 'bpp-field-wrapper bpp-table-row';
	//divLabelRow.appendChild(labelRow);
	divTable.appendChild(labelRow);
	var divContainer = domify('<div data-list-entry-container></div>');
	divTable.appendChild(divContainer);
	
	var sHtml = objHtml.outerHTML;

	let factory: any =
	{
		id: id,
		html: sHtml,
		get: function(element, node)
		{
			var boElements = elements(element, node, this.__invalidValues);
			var invalidValues = this.__invalidValues;
			delete this.__invalidValues;

			forEach ( invalidValues, function(value, idx)
			{
				var element = boElements[idx];
				forEach ( modelProperties, function(prop)
				{
					element[prop] = value[prop];
				});
			});
			return boElements;
		},
		set: function(element, values, node)
		{
			var action = this.__action || {};
			delete this.__action;

			if ( action.id === 'delete-element' )
			{
				return removeElement(element, node, action.idx);
			}
			else if ( action.id === 'add-element' )
			{
				return addElement(element, node);
			}
			else if ( canUpdate )
			{
				var commands = [];
				var valuesToValidate = values;

				if (typeof options.validate !== 'function')
				{
					valuesToValidate = diff(element, node, values, elements(element, node), editable);
				}

				var self = this;
				forEach ( valuesToValidate, function(value)
				{
					var validationError;
					var idx = values.indexOf(value);
					if ( typeof options.validate === 'function' )
					{
						validationError = options.validate(element, value, node, idx);
					}
					if ( !validationError )
					{
						var cmd = updateElement(element, value, node, idx);
						if ( cmd )
						{
							commands.push(cmd);
						}
					}
					else
					{
						// cache invalid value in an object by index as key
						self.__invalidValues = self.__invalidValues || {};
						self.__invalidValues[idx] = value;
						// execute a command, which does not do anything
						commands.push(cmdHelper.updateProperties(element, {}));
					}
				});
				return commands;
			}
		},
		// 08/09/2016 Paul.  createListEntryTemplate() is called when populating existing values to the talbe. 
		createListEntryTemplate: function(value, index, selectBox)
		{
			var template = createInputRowTemplate(modelProperties, listValues, canRemove, value);
			return template.outerHTML;
		},
		addElement: function(element, node, event, scopeNode)
		{
			var template = createInputRowTemplate(modelProperties, listValues, canRemove);  // domify(createInputRowTemplate(modelProperties, canRemove));
			var container = getContainer(node);
			container.appendChild(template);
			this.__action = { id: 'add-element' };
			return true;
		},
		deleteElement: function(element, node, event, scopeNode)
		{
			var container = getContainer(node);
			var rowToDelete = event.delegateTarget.parentNode;
			var idx = parseInt(domAttr(rowToDelete, 'data-index'), 10);

			container.removeChild(rowToDelete);
			this.__action = { id: 'delete-element', idx: idx };
			return true;
		},
		editable: function(element, rowNode, input, prop, value, idx)
		{
			var entryNode = domClosest(rowNode, '[data-entry]');
			return editable(element, entryNode, prop, idx);
		},
		show: function(element, entryNode, node, scopeNode)
		{
			entryNode = getEntryNode(entryNode);
			return show(element, entryNode, node, scopeNode);
		},
		showTable: function(element, entryNode, node, scopeNode)
		{
			entryNode = getEntryNode(entryNode);
			var elems = elements(element, entryNode);
			return elems && elems.length && (!canBeShown || show(element, entryNode, node, scopeNode));
		},
		validateListItem: function(element, value, node, idx)
		{
			if ( typeof options.validate === 'function' )
			{
				return options.validate(element, value, node, idx);
			}
		}
	};

	if ( setControlValue )
	{
		factory.setControlValue = function(element, rowNode, input, prop, value, idx)
		{
			var entryNode = getEntryNode(rowNode);
			setControlValue(element, entryNode, input, prop, value, idx);
		};
	}
	return factory;
};
