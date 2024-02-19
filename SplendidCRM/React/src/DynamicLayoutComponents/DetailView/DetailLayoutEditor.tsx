/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 1. React and fabric. 
import * as React from 'react';
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'     ;
// 3. Scripts. 
import Sql                                          from '../../scripts/Sql'                ;
import L10n                                         from '../../scripts/L10n'               ;
import Security                                     from '../../scripts/Security'           ;
import Credentials                                  from '../../scripts/Credentials'        ;
import SplendidCache                                from '../../scripts/SplendidCache'      ;
import { StartsWith, uuidFast }                     from '../../scripts/utility'            ;
import { CreateSplendidRequest, GetSplendidResult } from '../../scripts/SplendidRequest'    ;
// 4. Components and Views. 
import PopupView                                    from '../../views/PopupView'            ;
import DetailPropertiesEditor                       from './DetailPropertiesEditor'         ;
import DraggableRow                                 from '../Shared/DraggableRow'           ;
import DraggableCell                                from '../Shared/DraggableCell'          ;
import DraggableItem                                from '../Shared/DraggableItem'          ;
import DraggableRemove                              from '../Shared/DraggableRemove'        ;
import SourceItem                                   from '../Shared/SouceItem'              ;
import SourceRow                                    from '../Shared/SourceRow'              ;
import SourceBlank                                  from '../Shared/SourceBlank'            ;
import SourceSeparator                              from '../Shared/SourceSeparator'        ;
import SourceHeader                                 from '../Shared/SourceHeader'           ;

interface IDetailLayoutEditorProps
{
	LayoutType      : string;
	ModuleName      : string;
	ViewName        : string;
	onEditComplete  : Function;
}

interface IDetailLayoutEditorState
{
	layoutName        : string;
	moduleFields      : Array<any>;
	rows              : Array<{ key: string, columns: Array<string[]> }>;
	activeFields      : Record<string, any>;
	layoutFields      : Array<any>;
	layoutProperties  : any;
	draggingId        : string;
	selectedId        : string;
	error?            : string;
	MODULE_TERMINOLOGY: string[];
	showName          : boolean;
	popupOpen         : boolean;
}

export default class DetailLayoutEditor extends React.Component<IDetailLayoutEditorProps, IDetailLayoutEditorState>
{
	private _isMounted = false;

	constructor(props: IDetailLayoutEditorProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		let MODULE_TERMINOLOGY: string[] = SplendidCache.BuildModuleTerminology(props.ModuleName);
		this.state =
		{
			layoutName        : props.ViewName,
			moduleFields      : [],
			rows              :
			[
				{
					key    : uuidFast(),
					columns: []
				}
			],
			activeFields      : {},
			layoutFields      : [],
			layoutProperties  : null,
			draggingId        : '',
			selectedId        : null,
			MODULE_TERMINOLOGY,
			showName          : false,
			popupOpen         : false,
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
		try
		{
			await this.loadLayout(false);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error: error.message });
		}
	}

	async componentDidUpdate(prevProps: IDetailLayoutEditorProps)
	{
		if ( prevProps.ViewName != this.props.ViewName )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate', nextProps.ViewName);
			
			let MODULE_TERMINOLOGY: string[] = SplendidCache.BuildModuleTerminology(this.props.ModuleName);
			this.setState(
			{
				layoutName        : this.props.ViewName,
				moduleFields      : [],
				rows              :
				[
					{
						key    : uuidFast(),
						columns: []
					}
				],
				activeFields      : {},
				layoutFields      : [],
				layoutProperties  : null,
				draggingId        : '',
				selectedId        : null,
				MODULE_TERMINOLOGY,
				showName          : false,
				popupOpen         : false,
				error             : null,
			}, () =>
			{
				this.loadLayout(false).then(() =>
				{
				})
				.catch((error) =>
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate', error);
				});
			});
		}
	}

	private createItemFromSource = (item) =>
	{
		const { ModuleName } = this.props;
		let { activeFields } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.createItemFromSource', item);

		let id : string  = item.id          ;
		let obj: any     = {};
		obj.ID           = null             ;
		obj.FIELD_TYPE   = item.FIELD_TYPE  ;
		obj.DATA_LABEL   = item.DATA_LABEL  ;
		obj.DATA_FIELD   = item.DATA_FIELD  ;
		obj.DATA_FORMAT  = item.DATA_FORMAT ;
		obj.URL_FIELD    = item.URL_FIELD   ;
		obj.URL_FORMAT   = item.URL_FORMAT  ;
		obj.URL_TARGET   = item.URL_TARGET  ;
		obj.MODULE_TYPE  = item.MODULE_TYPE ;
		obj.LIST_NAME    = item.LIST_NAME   ;
		obj.COLSPAN      = item.COLSPAN     ;
		obj.TOOL_TIP     = item.TOOL_TIP    ;
		obj.PARENT_FIELD = item.PARENT_FIELD;

		activeFields[id] = obj;
		if ( this._isMounted )
		{
			// 01/13/2024 Paul.  createItemFromSource is called during initial layout for all items, so we cannot start dragging. 
			this.setState({ activeFields, error: null });
		}
		return {
			id        : id,
			fieldIndex: -1,
			colIndex  : -1,
			rowIndex  : -1,
			origId    : id
		};
	}

	private handleEditClick = (id) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.handleEditClick', id, this.state.activeFields[id]);
		if ( this._isMounted )
		{
			this.setState({ selectedId: id, error: null })
		}
	}

	private remove = (item: any, type: 'ITEM' | 'ROW') =>
	{
		let { rows, activeFields } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.remove ' + type, item);
		if ( type == 'ITEM' )
		{
			const { id, origId, colIndex, rowIndex } = item;
			let fields: string[] = rows[rowIndex].columns[colIndex];
			let i = fields.indexOf(id);
			if ( i >= 0 )
			{
				fields.splice(i, 1);
			}
			delete activeFields[id];
		}
		else if ( type == 'ROW' )
		{
			const { id, index } = item;
			for ( let colIndex = 0; colIndex < rows[index].columns.length; colIndex++ )
			{
				let fields: string[] = rows[index].columns[colIndex];
				for ( let i = 0; i < fields.length; i++ )
				{
					delete activeFields[fields[i]];
				}
			}
			rows.splice(index, 1);
		}
		else
		{
			return;
		}
		if ( this._isMounted )
		{
			// 01/11/2024 Paul.  Clear dragging. 
			this.setState({ rows, activeFields, draggingId: '', error: null });
		}
	}

	private setDragging = (id: string) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.setDragging', id);
		if ( this._isMounted )
		{
			if ( this.state.draggingId != id )
			{
				this.setState({ draggingId: id, error: null });
			}
		}
	}

	private removeRow = (index: number) =>
	{
		let { rows, activeFields } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.removeRow', index);
		if ( index != -1 )
		{
			// 03/07/2020 Paul.  We need to remove the actiFields within the row being removed. 
			for ( let colIndex = 0; colIndex < rows[index].columns.length; colIndex++ )
			{
				let fields: string[] = rows[index].columns[colIndex];
				for ( let i = 0; i < fields.length; i++ )
				{
					delete activeFields[fields[i]];
				}
			}
			rows.splice(index, 1);
		}
		if ( this._isMounted )
		{
			this.setState({ rows, activeFields, error: null });
		}
	}

	private moveDraggableRow = (dragIndex: number, hoverIndex: number) =>
	{
		let { rows } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moveDraggableRow', dragIndex, hoverIndex);
		const row = rows.splice(dragIndex, 1)[0];
		rows.splice(hoverIndex, 0, row);
		if ( this._isMounted )
		{
			this.setState({ rows, error: null });
		}
	}

	private findField = (id: string) =>
	{
		const { rows } = this.state
		for ( let rowIndex = 0; rowIndex < rows.length; rowIndex++ )
		{
			let row: any = rows[rowIndex];
			for ( let colIndex = 0; colIndex < row.columns.length; colIndex++ )
			{
				let col: string[] = row.columns[colIndex];
				if ( col != null )
				{
					for ( let fieldIndex = 0; fieldIndex < col.length; fieldIndex++ )
					{
						if ( col[fieldIndex] == id )
						{
							return { id, rowIndex, colIndex, fieldIndex };
						}
					}
				}
			}
		}
		return null;
	}

	private moveDraggableItem = (id: string, hoverColIndex: number, hoverRowIndex: number, didDrop: boolean) =>
	{
		const { activeFields } = this.state;
		let { rows } = this.state;
		let item: any = this.findField(id);
		if ( item )
		{
			let dragFieldIndex: number = item.fieldIndex;
			let dragColIndex  : number = item.colIndex  ;
			let dragRowIndex  : number = item.rowIndex  ;
			let fields: string[] = rows[dragRowIndex].columns[dragColIndex];
			//const id: string = fields[dragFieldIndex];
			fields.splice(dragFieldIndex, 1);
		
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moveDraggableItem ' + id, dragFieldIndex, dragColIndex, dragRowIndex, hoverColIndex, hoverRowIndex);
			if ( rows[hoverRowIndex].columns.length == 0 )
			{
				let maxColumns: number = this.LayoutColumns();
				for ( let i = 0; i < maxColumns; i++ )
				{
					rows[hoverRowIndex].columns.push([]);
				}
			}
			fields = rows[hoverRowIndex].columns[hoverColIndex];
			if ( fields.length == 1 )
			{
				if ( activeFields[fields[0]] )
				{
					if ( activeFields[fields[0]].FIELD_TYPE == 'Blank' )
					{
						fields.pop();
					}
				}
			}
			fields.push(id);
			if ( this._isMounted )
			{
				this.setState({ rows, error: null });
			}
		}
		else
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.moveDraggableItem not found ' + id);
		}
	}

	private addSourceItem = (id: string, hoverColIndex: number, hoverRowIndex: number) =>
	{
		const { activeFields } = this.state;
		let { rows } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.addSourceItem', id, hoverColIndex, hoverRowIndex);
		if ( rows[hoverRowIndex].columns.length == 0 )
		{
			let maxColumns: number = this.LayoutColumns();
			for ( let i = 0; i < maxColumns; i++ )
			{
				rows[hoverRowIndex].columns.push([]);
			}
		}
		let fields: string[] = rows[hoverRowIndex].columns[hoverColIndex];
		if ( fields.length == 1 )
		{
			if ( activeFields[fields[0]] )
			{
				if ( activeFields[fields[0]].FIELD_TYPE == 'Blank' )
				{
					fields.pop();
				}
			}
		}
		fields.push(id);
		if ( this._isMounted )
		{
			this.setState({ rows, error: null });
		}
	}

	private addSourceRow = (id: string, hoverIndex: number) =>
	{
		let { rows } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.addSourceRow', id, hoverIndex);
		const row =
		{
			key    : id,
			columns: []
		};
		rows.splice(hoverIndex, 0, row);
		if ( this._isMounted )
		{
			this.setState({ rows, error: null });
		}
	}

	private _onNameChange = (e) =>
	{
		let value = e.target.value;
		if ( this._isMounted )
		{
			this.setState({ layoutName: value, error: null });
		}
	}

	private loadLayout = async (DEFAULT_VIEW) =>
	{
		const { LayoutType, ModuleName, ViewName } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.loadLayout');
		try
		{
			if ( this._isMounted )
			{
				let res  = await CreateSplendidRequest('Administration/Rest.svc/GetAdminLayoutModuleFields?ModuleName=' + ModuleName + '&LayoutType=' + LayoutType + '&LayoutName=' + ViewName, 'GET');
				let json = await GetSplendidResult(res);
				if ( this._isMounted )
				{
					let moduleFields: Array<any> = json.d;
					let TableName   : string = 'DETAILVIEWS_FIELDS';
					let filter      : string = 'DETAIL_NAME eq \'' + ViewName + '\' and DEFAULT_VIEW eq \'' + DEFAULT_VIEW + '\'';
					res  = await CreateSplendidRequest('Administration/Rest.svc/GetAdminTable?TableName=' + TableName + '&$filter=' + encodeURIComponent(filter) , 'GET');
					json = await GetSplendidResult(res);
					if ( this._isMounted )
					{
						let layoutFields: any = json.d.results;
						TableName = 'DETAILVIEWS';
						filter    = 'NAME eq \'' + ViewName + '\'';
						res  = await CreateSplendidRequest('Administration/Rest.svc/GetAdminTable?TableName=' + TableName + '&$filter=' + encodeURIComponent(filter) , 'GET');
						json = await GetSplendidResult(res);
						if ( this._isMounted )
						{
							let layoutProperties: any = null;
							let maxColumns      : number = 2;
							if ( json.d.results != null && json.d.results.length > 0 )
							{
								layoutProperties = json.d.results[0];
								maxColumns = Sql.ToInteger(layoutProperties.DATA_COLUMNS);
								if ( maxColumns == 0 )
								{
									maxColumns = 2;
								}
							}
							let rows        : any[]  = [];
							let activeFields: any    = {};
							let colIndex    : number = 0;
							let row         : any    = null;
							for ( let i = 0; i < layoutFields.length; i++ )
							{
								let field = layoutFields[i];
								let id = field.DATA_FIELD;
								if ( Sql.IsEmptyString(id) )
								{
									id = field.ID;
								}
								let bNewRow: boolean = (row == null || (colIndex >= maxColumns && field.COLSPAN != -1));
								if ( field.FIELD_TYPE == 'Separator' && row && (row.columns.length > 1 || (row.columns.length > 0 && row.columns[0].length > 0)) )
								{
									bNewRow = true;
								}
								if ( bNewRow )
								{
									row = 
									{
										key    : uuidFast(),
										columns: []
									};
									rows.push(row);
									colIndex = 0;
								}
								// 03/07/2020 Paul.  If adding a second item in the same column, we need to convert the column to an array. 
								if ( row.columns.length == 0 || field.COLSPAN != -1 )
								{
									row.columns.push([]);
								}
								row.columns[row.columns.length-1].push(id);
								activeFields[id] = field;
								colIndex++;
								if ( field.COLSPAN == 3 || field.FIELD_TYPE == 'Separator' )
								{
									row = null;
								}
							}
							this.setState(
							{
								layoutName      : ViewName,
								rows            ,
								activeFields    ,
								moduleFields    ,
								layoutFields    ,
								layoutProperties,
							});
						}
					}
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.loadLayout', error);
			this.setState({ error: error.message });
		}
	}

	private isFieldInUse(field: any)
	{
		const { rows, activeFields } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.isAppInUse', app);
		for ( let rowIndex = 0; rowIndex < rows.length; rowIndex++ )
		{
			for ( let colIndex = 0; colIndex < rows[rowIndex].columns.length; colIndex++ )
			{
				let fields: string[] = rows[rowIndex].columns[colIndex];
				for ( let i = 0; i < fields.length; i++ )
				{
					if ( activeFields[fields[i]] && activeFields[fields[i]].DATA_FIELD == field.DATA_FIELD )
					{
						return true;
					}
				}
			}
		}
		return false;
	}

	private LayoutColumns = () =>
	{
		const { layoutProperties } = this.state;
		let maxColumns: number = 2;
		if ( layoutProperties )
		{
			maxColumns = Sql.ToInteger(layoutProperties.DATA_COLUMNS);
			if ( maxColumns <= 0 )
			{
				maxColumns = 2;
			}
		}
		return maxColumns;
	}

	private _onSave = async (e) =>
	{
		const { layoutName, rows, activeFields, layoutProperties } = this.state;
		try
		{
			if ( this._isMounted )
			{
				let maxColumns: number = this.LayoutColumns();

				let obj: any = new Object();
				obj.DETAILVIEWS                     = new Object();
				// 05/04/2016 Paul.  EDITVIEWS fields to allow for layout copy. 
				obj.DETAILVIEWS.MODULE_NAME         = layoutProperties.MODULE_NAME       ;
				obj.DETAILVIEWS.VIEW_NAME           = layoutProperties.VIEW_NAME         ;
				obj.DETAILVIEWS.LABEL_WIDTH         = layoutProperties.LABEL_WIDTH       ;
				obj.DETAILVIEWS.FIELD_WIDTH         = layoutProperties.FIELD_WIDTH       ;
				obj.DETAILVIEWS.DATA_COLUMNS        = layoutProperties.DATA_COLUMNS      ;
				obj.DETAILVIEWS.PRE_LOAD_EVENT_ID   = layoutProperties.PRE_LOAD_EVENT_ID ;
				obj.DETAILVIEWS.POST_LOAD_EVENT_ID  = layoutProperties.POST_LOAD_EVENT_ID;
				obj.DETAILVIEWS.SCRIPT              = layoutProperties.SCRIPT            ;
				obj.DETAILVIEWS_FIELDS = new Array();
				let nFieldIndex: number = 0;
				for ( let i = 0; i < rows.length; i++ )
				{
					let row: any = rows[i];
					for ( let j = 0; j < row.columns.length; j++ )
					{
						let fields: string[] = row.columns[j];
						let layoutField: any = new Object();
						for ( let k = 0; k < fields.length; k++ )
						{
							layoutField.FIELD_INDEX  = nFieldIndex;
							layoutField.ID           = activeFields[fields[k]].ID          ;
							layoutField.FIELD_TYPE   = activeFields[fields[k]].FIELD_TYPE  ;
							layoutField.DATA_LABEL   = activeFields[fields[k]].DATA_LABEL  ;
							layoutField.DATA_FIELD   = activeFields[fields[k]].DATA_FIELD  ;
							layoutField.DATA_FORMAT  = activeFields[fields[k]].DATA_FORMAT ;
							layoutField.URL_FIELD    = activeFields[fields[k]].URL_FIELD   ;
							layoutField.URL_FORMAT   = activeFields[fields[k]].URL_FORMAT  ;
							layoutField.URL_TARGET   = activeFields[fields[k]].URL_TARGET  ;
							layoutField.MODULE_TYPE  = activeFields[fields[k]].MODULE_TYPE ;
							layoutField.LIST_NAME    = activeFields[fields[k]].LIST_NAME   ;
							layoutField.COLSPAN      = activeFields[fields[k]].COLSPAN     ;
							layoutField.TOOL_TIP     = activeFields[fields[k]].TOOL_TIP    ;
							layoutField.PARENT_FIELD = activeFields[fields[k]].PARENT_FIELD;
							if ( k > 0 )
								layoutField.COLSPAN = -1;
							nFieldIndex++;
							obj.DETAILVIEWS_FIELDS.push(layoutField);
						}
					}
				}
				let sBody: string = JSON.stringify(obj);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave', obj);
				let res  = await CreateSplendidRequest('Administration/Rest.svc/UpdateAdminLayout?TableName=DETAILVIEWS_FIELDS&ViewName=' + layoutName, 'POST', 'application/octet-stream', sBody);
				let json = await GetSplendidResult(res);
				//this.props.onEditComplete();
				if( this._isMounted )
				{
					this.setState({ error: L10n.Term('DynamicLayout.LBL_SAVE_COMPLETE') });
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave', error);
			this.setState({ error: error.message });
		}
	}

	private _onCancel = (e) =>
	{
		if ( this._isMounted )
		{
			this.props.onEditComplete();
		}
	}

	private _onShowRolePopup = (e) =>
	{
		if ( this._isMounted )
		{
			this.setState({ popupOpen: true });
		}
	}

	private _onSelectRole = (value: { Action: string, ID: string, NAME: string, PROCESS_NOTES: string }) =>
	{
		if ( value.Action == 'SingleSelect' )
		{
			if ( this._isMounted )
			{
				let layoutName: string = this.props.ViewName + '.' + value.NAME;
				this.setState({ layoutName, popupOpen: false });
			}
		}
		else if ( value.Action == 'Close' )
		{
			this.setState({ popupOpen: false });
		}
	}

	private _onCopy = (e) =>
	{
		const { layoutName } = this.state;
		if ( this._isMounted )
		{
			// 06/15/2019 Paul.  Copy is the same as Save, but without the ID. 
			this.setState({ layoutName: layoutName + '.Copy', showName: true });
		}
	}

	private _onRestoreDefaults = async (e) =>
	{
		if ( this._isMounted )
		{
			await this.loadLayout(true);
		}
	}

	private _onExport = (e) =>
	{
		const { layoutName } = this.state;
		window.location.href = Credentials.RemoteServer + 'Administration/DynamicLayout/DetailViews/export.aspx?NAME=' + layoutName;
	}

	private _onEditPropertiesComplete = (layoutField) =>
	{
		const { activeFields, selectedId } = this.state;
		if ( this._isMounted )
		{
			if ( layoutField && selectedId )
			{
				activeFields[selectedId] = layoutField;
				this.setState({ activeFields, selectedId: null, error: null });
			}
			else
			{
				this.setState({ selectedId: null, error: null });
			}
		}
	}

	private getCellWidth = (fields, colIndex, maxColumns) =>
	{
		const { activeFields } = this.state;
		let nCOLUMN_WIDTH: number = null;
		nCOLUMN_WIDTH = 90/maxColumns;
		if ( fields && fields.length > 0 )
		{
			let fieldId: string = fields[0];
			let field: any = activeFields[fieldId];
			if ( field && Sql.ToInteger(field.COLSPAN) > 0 )
			{
				nCOLUMN_WIDTH  = (Sql.ToInteger(field.COLSPAN) + 1) * 90 / (maxColumns * 2);
			}
		}
		return nCOLUMN_WIDTH.toString() + '%';
	}

	public render()
	{
		const { LayoutType, ModuleName } = this.props;
		const { layoutName, moduleFields, rows, activeFields, draggingId, selectedId, layoutProperties, error, MODULE_TERMINOLOGY, showName, popupOpen } = this.state;
		let maxColumns: number = 2;
		if ( layoutProperties != null )
		{
			maxColumns = Sql.ToInteger(layoutProperties.DATA_COLUMNS);
			if ( maxColumns == 0 )
			{
				maxColumns = 2;
			}
		}
		return (
		<React.Fragment>
			<div style={ {flex: '2 2 0', flexDirection: 'column', margin: '0 .5em', border: '1px solid grey', position: 'relative'} }>
				<div style={ {height: '100%', overflowY: 'scroll'} }>
					<h2 style={{ padding: '.25em' }}>{ L10n.Term('DynamicLayout.LBL_TOOLBOX') }</h2>
					<div style={{ padding: '.5em' }}>
						<DraggableRemove remove={ this.remove } />
						<SourceRow       TITLE={ L10n.Term('DynamicLayout.LBL_NEW_ROW'      ) } removeRow={ this.removeRow } />
						<SourceSeparator TITLE={ L10n.Term('DynamicLayout.LBL_NEW_SEPARATOR') } createItemFromSource={ this.createItemFromSource } moveDraggableItem={ this.moveDraggableItem } remove={ this.remove } />
						<SourceHeader    TITLE={ L10n.Term('DynamicLayout.LBL_NEW_HEADER'   ) } createItemFromSource={ this.createItemFromSource } moveDraggableItem={ this.moveDraggableItem } remove={ this.remove } />
						<SourceBlank     TITLE={ L10n.Term('DynamicLayout.LBL_NEW_BLANK'    ) } createItemFromSource={ this.createItemFromSource } moveDraggableItem={ this.moveDraggableItem } remove={ this.remove } />
						<br />
					</div>
					<div style={{ padding: '.5em' }}>
						{ moduleFields.map((field, index) => (
							<SourceItem
								ModuleName={ ModuleName }
								item={ field }
								key={ 'moduleField.' + field.ColumnName }
								isFieldInUse={ this.isFieldInUse(field) }
								createItemFromSource={ this.createItemFromSource }
								moveDraggableItem={ this.moveDraggableItem }
								remove={ this.remove }
							/>
						))
						}
					</div>
				</div>
			</div>
			<div style={{ flexDirection: 'column', flex: '8 8 0', margin: '0 .5em', border: '1px solid grey' }}>
				<div style={ {height: '100%', overflowY: 'scroll'} }>
					<h2 style={{ padding: '.25em' }}>{ L10n.Term('DynamicLayout.LBL_LAYOUT') + ' - ' + layoutName }</h2>
					<div style={{ padding: '.5em', whiteSpace: 'nowrap' }}>
						<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onSave           }>{ L10n.Term('.LBL_SAVE_BUTTON_LABEL'             ) }</button>
						<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onCancel         }>{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL'           ) }</button>
						<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onCopy           }>{ L10n.Term('DynamicLayout.LBL_COPY_BUTTON_TITLE') }</button>
						<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onRestoreDefaults}>{ L10n.Term('.LBL_DEFAULTS_BUTTON_LABEL'         ) }</button>
						<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onExport         }>{ L10n.Term('.LBL_EXPORT_BUTTON_LABEL'           ) }</button>
					</div>
					{ showName
					? <div style={{ display: 'flex', marginBottom: '.2em', padding: '.5em' }}>
						<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onShowRolePopup }>{ L10n.Term('DynamicLayout.LBL_SELECT_ROLE'        ) }</button>
						<input
							value={ layoutName }
							onChange={ this._onNameChange }
							style={ {flexGrow: 2} }
						/>
						<PopupView
							isOpen={ popupOpen }
							callback={ this._onSelectRole }
							MODULE_NAME='ACLRoles'
							showProcessNotes={ true }
						/>
					</div>
					: null
					}
					<div className='error' style={ {paddingLeft: '10px'} }>{ error }</div>
					{ layoutProperties
					? <div style={{ padding: '.5em' }}>
						<table style={ {width: '100%', border: '1px solid black'} }>
						{ rows.map((row, rowIndex) => (
							<DraggableRow
								index={ rowIndex }
								id={ row.key }
								key={ row.key }
								moveDraggableRow={ this.moveDraggableRow }
								moveDraggableItem={ this.moveDraggableItem }
								addSourceItem={ this.addSourceItem }
								addSourceRow={ this.addSourceRow }
								removeRow={ this.removeRow } 
								length={ row.columns.length }>
								{ row.columns.map((fields, colIndex) =>
								( <DraggableCell
									width={ this.getCellWidth(fields, colIndex, maxColumns) }
									colIndex={ colIndex }
									rowIndex={ rowIndex }
									moveDraggableItem={ this.moveDraggableItem }
									addSourceItem={ this.addSourceItem }
									>
										{ fields.map((fieldId, fieldIndex) =>
										(
											<DraggableItem
												item={ activeFields[fieldId] }
												id={ fieldId }
												key={ fieldId }
												fieldIndex={ fieldIndex }
												colIndex={ colIndex }
												rowIndex={ rowIndex }
												moveDraggableItem={ this.moveDraggableItem }
												remove={ this.remove }
												setDragging={ this.setDragging }
												draggingId={ draggingId }
												rowTotal={ row.columns.length}
												onEditClick={ this.handleEditClick }
											/>
										))}
								</DraggableCell>
								))}
							</DraggableRow>
						))}
						</table>
					</div>
					: <div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
						<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
					</div>
					}
				</div>
			</div>
			<div style={{ flex: '2 2 0', border: '1px solid grey', margin: '0 .5em' }}>
				<div style={ {height: '100%', overflowY: 'scroll'} }>
					<h2 style={{ padding: '.25em' }}>{ L10n.Term('DynamicLayout.LBL_PROPERTIES') }</h2>
					{ !Sql.IsEmptyString(selectedId)
					? <DetailPropertiesEditor layoutField={ activeFields[selectedId] } moduleFields={ moduleFields } DATA_COLUMNS={ layoutProperties.DATA_COLUMNS } onEditComplete={ this._onEditPropertiesComplete } MODULE_TERMINOLOGY={ MODULE_TERMINOLOGY } />
					: null
					}
				</div>
			</div>
		</React.Fragment>
		);
	}
}


