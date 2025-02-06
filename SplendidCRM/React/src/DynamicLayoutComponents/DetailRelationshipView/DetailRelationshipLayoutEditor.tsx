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
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'      ;
// 3. Scripts. 
import Sql                                          from '../../scripts/Sql'                   ;
import L10n                                         from '../../scripts/L10n'                  ;
import Credentials                                  from '../../scripts/Credentials'        ;
import { CreateSplendidRequest, GetSplendidResult } from '../../scripts/SplendidRequest'       ;
// 4. Components and Views. 
import DetailRelationshipPropertiesEditor           from './DetailRelationshipPropertiesEditor';
import DraggableItem                                from './DraggableItem'                     ;
import DraggableRow                                 from '../Shared/DraggableRow'              ;

interface IDetailRelationshipLayoutEditorProps
{
	LayoutType      : string;
	ModuleName      : string;
	ViewName        : string;
	onEditComplete  : Function;
}

interface IDetailRelationshipLayoutEditorState
{
	layoutName        : string;
	moduleFields      : Array<any>;
	rows              : string[];
	activeFields      : Record<string, any>;
	layoutFields      : Array<any>;
	selectedId        : string;
	error?            : string;
}

export default class DetailRelationshipLayoutEditor extends React.Component<IDetailRelationshipLayoutEditorProps, IDetailRelationshipLayoutEditorState>
{
	private _isMounted = false;

	constructor(props: IDetailRelationshipLayoutEditorProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		this.state =
		{
			layoutName        : props.ViewName,
			moduleFields      : [],
			rows              : [],
			activeFields      : {},
			layoutFields      : [],
			selectedId        : null,
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

	componentWillUnmount()
	{
		this._isMounted = false;
	}
	
	async componentDidUpdate(prevProps: IDetailRelationshipLayoutEditorProps)
	{
		if ( prevProps.ViewName != this.props.ViewName )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate', nextProps.ViewName);
			
			this.setState(
			{
				layoutName        : this.props.ViewName,
				moduleFields      : [],
				rows              : [],
				activeFields      : {},
				layoutFields      : [],
				selectedId        : null,
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

	private handleEditClick = (id) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.handleEditClick', id, this.state.activeFields[id]);
		if ( this._isMounted )
		{
			this.setState({ selectedId: id, error: null })
		}
	}

	private removeRow = (index: number) =>
	{
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

	private moveDraggableItem = (id: string, hoverColIndex: number, hoverRowIndex: number, didDrop: boolean) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moveDraggableItem ' + id, hoverColIndex, hoverRowIndex);
	}

	private addSourceItem = (id: string, hoverColIndex: number, hoverRowIndex: number) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.addSourceItem', id, hoverColIndex, hoverRowIndex);
	}

	private addSourceRow = (id: string, hoverIndex: number) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.addSourceRow', id, hoverIndex);
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
					let TableName   : string = 'DETAILVIEWS_RELATIONSHIPS';
					let filter      : string = 'DETAIL_NAME eq \'' + ViewName + '\'';
					res  = await CreateSplendidRequest('Administration/Rest.svc/GetAdminTable?TableName=' + TableName + '&$filter=' + encodeURIComponent(filter) , 'GET');
					json = await GetSplendidResult(res);
					if ( this._isMounted )
					{
						let layoutFields: any = json.d.results;
						let rows        : string[] = [];
						let activeFields: any     = {};
						for ( let i = 0; i < layoutFields.length; i++ )
						{
							let field = layoutFields[i];
							rows.push(field.ID);
							activeFields[field.ID] = field;
						}
						this.setState(
						{
							layoutName      : ViewName,
							moduleFields    ,
							rows            ,
							activeFields    ,
							layoutFields    ,
						});
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

	private _onSave = async (e) =>
	{
		const { layoutName, rows, activeFields } = this.state;
		try
		{
			if ( this._isMounted )
			{
				let obj: any = new Object();
				obj.DETAILVIEWS_RELATIONSHIPS = new Array();
				let nFieldIndex: number = 0;
				for ( let i = 0; i < rows.length; i++ )
				{
					let fieldId    : string = rows[i];
					let layoutField: any = new Object();
					layoutField.RELATIONSHIP_ORDER   = nFieldIndex;
					layoutField.ID                   = activeFields[fieldId].ID                  ;
					layoutField.DETAIL_NAME          = activeFields[fieldId].DETAIL_NAME         ;
					layoutField.MODULE_NAME          = activeFields[fieldId].MODULE_NAME         ;
					layoutField.CONTROL_NAME         = activeFields[fieldId].CONTROL_NAME        ;
					layoutField.RELATIONSHIP_ENABLED = activeFields[fieldId].RELATIONSHIP_ENABLED;
					layoutField.TITLE                = activeFields[fieldId].TITLE               ;
					layoutField.TABLE_NAME           = activeFields[fieldId].TABLE_NAME          ;
					layoutField.PRIMARY_FIELD        = activeFields[fieldId].PRIMARY_FIELD       ;
					layoutField.SORT_FIELD           = activeFields[fieldId].SORT_FIELD          ;
					layoutField.SORT_DIRECTION       = activeFields[fieldId].SORT_DIRECTION      ;
					nFieldIndex++;
					obj.DETAILVIEWS_RELATIONSHIPS.push(layoutField);
				}
				let sBody: string = JSON.stringify(obj);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave', obj);
				let res  = await CreateSplendidRequest('Administration/Rest.svc/UpdateAdminLayout?TableName=DETAILVIEWS_RELATIONSHIPS&ViewName=' + layoutName, 'POST', 'application/octet-stream', sBody);
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

	// 08/17/2024 Paul.  Add support for DetailView Relationships export. 
	private _onExport = (e) =>
	{
		const { layoutName } = this.state;
		window.location.href = Credentials.RemoteServer + 'Administration/DynamicLayout/Relationships/export.aspx?NAME=' + layoutName;
	}

	private _onEditPropertiesComplete = (layoutField) =>
	{
		let { activeFields, selectedId } = this.state;
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

	private _onChangeEnabled = (id, checked) =>
	{
		let { activeFields } = this.state;
		activeFields[id].RELATIONSHIP_ENABLED = checked;
		this.setState({ activeFields, selectedId: null, error: null });
	}

	public render()
	{
		const { layoutName, moduleFields, rows, activeFields, selectedId, error } = this.state;
		return (
		<React.Fragment>
			<div style={{ flexDirection: 'column', flex: '8 8 0', margin: '0 .5em', border: '1px solid grey' }}>
				<div style={ {height: '100%', overflowY: 'scroll'} }>
					<h2 style={{ padding: '.25em' }}>{ L10n.Term('DynamicLayout.LBL_LAYOUT') + ' - ' + layoutName }</h2>
					<div style={{ padding: '.5em', whiteSpace: 'nowrap' }}>
						<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onSave  }>{ L10n.Term('.LBL_SAVE_BUTTON_LABEL'  ) }</button>
						<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onCancel}>{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }</button>
						<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onExport         }>{ L10n.Term('.LBL_EXPORT_BUTTON_LABEL'           ) }</button>
					</div>
					<div className='error' style={ {paddingLeft: '10px'} }>{ error }</div>
					{ moduleFields && moduleFields.length > 0
					? <div style={{ padding: '.5em' }}>
						<table style={ {width: '100%', border: '1px solid black'} }>
						{ rows.map((fieldId, rowIndex) => (
							<DraggableRow
								index={ rowIndex }
								id={ fieldId + '_row' }
								key={ fieldId + '_row' }
								moveDraggableRow={ this.moveDraggableRow }
								moveDraggableItem={ this.moveDraggableItem }
								addSourceItem={ this.addSourceItem }
								addSourceRow={ this.addSourceRow }
								removeRow={ this.removeRow } 
								length={ 1 }>
								<DraggableItem
									item={ activeFields[fieldId] }
									id={ fieldId }
									key={ fieldId }
									onEditClick={ this.handleEditClick }
									onChangeEnabled={ this._onChangeEnabled } 
								/>
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
			<div style={{ flex: '4 4 0', border: '1px solid grey', margin: '0 .5em' }}>
				<div style={ {height: '100%', overflowY: 'scroll'} }>
					<h2 style={{ padding: '.25em' }}>{ L10n.Term('DynamicLayout.LBL_PROPERTIES') }</h2>
					{ !Sql.IsEmptyString(selectedId)
					? <DetailRelationshipPropertiesEditor layoutField={ activeFields[selectedId] } moduleFields={ moduleFields } onEditComplete={ this._onEditPropertiesComplete }  />
					: null
					}
				</div>
			</div>
		</React.Fragment>
		);
	}
}


