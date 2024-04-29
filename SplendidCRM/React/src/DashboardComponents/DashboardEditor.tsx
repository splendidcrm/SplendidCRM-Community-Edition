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
import { RouteComponentProps, withRouter }    from '../Router5'              ;
import { observer }                           from 'mobx-react'                    ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome';
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'                ;
import L10n                                   from '../scripts/L10n'               ;
import Security                               from '../scripts/Security'           ;
import Credentials                            from '../scripts/Credentials'        ;
import SplendidCache                          from '../scripts/SplendidCache'      ;
import { AuthenticatedMethod, LoginRedirect } from '../scripts/Login'              ;
import { DashboardApps_LoadAll, Dashboards, Dashboards_LoadPanels, Dashboards_LoadItem } from '../scripts/Dashboard';
import { DeleteModuleItem, UpdateModule }     from '../scripts/ModuleUpdate'       ;
import { uuidFast, screenHeight }             from '../scripts/utility'            ;
// 4. Components and Views. 
import DraggableRow                           from './DraggableRow'                ;
import DraggableItem                          from './DraggableItem'               ;
import DraggableRemove                        from './DraggableRemove'             ;
import SourceItem                             from './SouceItem'                   ;
import SourceRow                              from './SourceRow'                   ;
import SourceBlank                            from './SourceBlank'                 ;

interface IDashboardEditorProps extends RouteComponentProps<any>
{
	CATEGORY        : string;
	ID              : string;
}

interface IDashboardEditorState
{
	ID              : string;
	item            : object;
	DASHBOARD_NAME  : string;
	ASSIGNED_USER_ID: string;
	rows            : Array<{ key: string, columns: Array<string> }>;
	panels          : Record<string, any>;
	apps            : Array<any>;
	draggingId      : string;
	selected        : any;
	error?          : any;
	clientHeight    : number;
}

@observer
class DashboardEditor extends React.Component<IDashboardEditorProps, IDashboardEditorState>
{
	private _isMounted = false;
	private lstDashlets: HTMLDivElement = null;

	constructor(props: IDashboardEditorProps)
	{
		super(props);
		Credentials.SetViewMode('DashboardEditView');
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		this.state =
		{
			ID              : props.ID,
			item            : null,
			DASHBOARD_NAME  : '',
			ASSIGNED_USER_ID: '',
			rows            :
			[
				{
					key    : uuidFast(),
					columns: []
				}
			],
			panels          : {},
			apps            : [],
			draggingId      : '',
			selected        : null,
			clientHeight    : screenHeight() - 100,
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
		await this.load();
		// 06/08/2021 Paul.  Adjust the client height as it changes. 
		window.addEventListener("resize", this.updateDimensions);
	}

	async componentDidUpdate(prevProps: IDashboardEditorProps)
	{
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			// 04/26/2019 Paul.  Bounce through ResetView so that layout gets completely reloaded. 
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate Reset', this.props.location,  prevProps.location);
			// 11/20/2019 Paul.  Include search parameters. 
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
		window.removeEventListener("resize", this.updateDimensions);
	}

	// 06/08/2021 Paul.  Adjust the client height as it changes. 
	private updateDimensions = () =>
	{
		if ( this.lstDashlets != null )
		{
			let rect = this.lstDashlets.getBoundingClientRect();
			let clientHeight: number = Math.floor(screenHeight() - rect.top - 10);
			if ( this.state.clientHeight != clientHeight )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.updateDimensions', clientHeight);
				this.setState({ clientHeight });
			}
		}
	}

	private refDashlets = (element) =>
	{
		if ( element != null )
		{
			this.lstDashlets = element;
			let rect = this.lstDashlets.getBoundingClientRect();
			let clientHeight: number = Math.floor(screenHeight() - rect.top - 10);
			if ( this.state.clientHeight != clientHeight )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.lstDashlets', clientHeight);
				this.setState({ clientHeight });
			}
		}
	}

	private createItemFromSource = (item) =>
	{
		let { panels } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.createItemFromSource', item);

		let id : string = uuidFast();
		let obj: any    = {};
		obj.ID                = null;
		obj.PANEL_TYPE        = Sql.ToString (item.PANEL_TYPE       );
		obj.DASHBOARD_APP_ID  = Sql.ToGuid   (item.ID               );
		obj.NAME              = Sql.ToString (item.NAME             );
		obj.CATEGORY          = Sql.ToString (item.CATEGORY         );
		obj.MODULE_NAME       = Sql.ToString (item.MODULE_NAME      );
		obj.TITLE             = Sql.ToString (item.TITLE            );
		obj.SETTINGS_EDITVIEW = Sql.ToString (item.SETTINGS_EDITVIEW);
		obj.IS_ADMIN          = Sql.ToBoolean(item.IS_ADMIN         );
		obj.APP_ENABLED       = Sql.ToBoolean(item.APP_ENABLED      );
		obj.SCRIPT_URL        = Sql.ToString (item.SCRIPT_URL       );
		obj.DEFAULT_SETTINGS  = Sql.ToString (item.DEFAULT_SETTINGS );
		panels[id] = obj;
		if ( this._isMounted )
		{
			// 01/13/2024 Paul.  createItemFromSource is called during initial layout for all items, so we cannot start dragging. 
			this.setState({ panels, error: null });
		}
		return {
			id      : id,
			colIndex: -1,
			rowIndex: -1,
			origId  : id
		};
	}

	private handleEditClick = (id) =>
	{
		if ( this._isMounted )
		{
			this.setState({ selected: this.state.panels[id], error: null })
		}
	}

	private remove = (item: any, type: 'ITEM' | 'ROW') =>
	{
		let { rows, panels } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.remove', item);
		if ( type == 'ITEM' )
		{
			const { origId, colIndex, rowIndex } = item;
			delete panels[rows[rowIndex].columns[colIndex]];
			rows[rowIndex].columns.splice(colIndex, 1);
		}
		else if ( type == 'ROW' )
		{
			const { id, index } = item;
			for ( let colIndex = 0; colIndex < rows[index].columns.length; colIndex++ )
			{
				delete panels[rows[index].columns[colIndex]];
			}
			rows.splice(index, 1);
			// 06/08/2021 Paul.  There must always be 1 row. 
			if ( rows.length == 0 )
			{
				rows.push(
				{
					key    : uuidFast(),
					columns: []
				});

			}
		}
		else
		{
			return;
		}
		if ( this._isMounted )
		{
			// 01/11/2024 Paul.  Clear dragging. 
			this.setState({ rows, panels, draggingId: '', error: null });
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
		let { rows } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.removeRow', index);
		if (index != -1)
		{
			rows.splice(index, 1);
		}
		if ( this._isMounted )
		{
			this.setState({ rows, error: null });
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

	private moveDraggableItem = (dragColIndex: number, dragRowIndex: number, hoverColIndex: number, hoverRowIndex: number) =>
	{
		let { rows } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moveDraggableItem', dragColIndex, dragRowIndex, hoverColIndex, hoverRowIndex);
		const item = rows[dragRowIndex].columns.splice(dragColIndex, 1)[0];
		rows[hoverRowIndex].columns.splice(hoverColIndex, 0, item);
		if ( this._isMounted )
		{
			this.setState({ rows, error: null });
		}
	}

	private addSourceItem = (id: string, hoverColIndex: number, hoverRowIndex: number) =>
	{
		let { rows } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.addSourceItem', id, hoverColIndex, hoverRowIndex);
		rows[hoverRowIndex].columns.splice(hoverColIndex, 0, id);
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

	private load = async () =>
	{
		const { ID } = this.state;
		let { panels } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', ID);
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.load');
			if ( status == 1 )
			{
				let d = await DashboardApps_LoadAll();
				let apps = d.results;
				if ( this._isMounted )
				{
					this.setState({ apps });
				}
				if ( !Sql.IsEmptyString(ID) )
				{
					let results = await Dashboards_LoadPanels(ID);
					let rows = [];
					// 01/09/2024 Paul.  Make sure to use existing panels object as it has toolbox items. 
					//let panels: any = {};
					for ( let i = 0; i < results.length; i++ )
					{
						let panel = results[i];
						let { ID, ROW_INDEX, PANEL_ORDER } = panel;
						if ( !rows[ROW_INDEX] )
						{
							rows.push(
							{
								key    : uuidFast(),
								columns: []
							});
						}
						rows[ROW_INDEX].columns.push(ID)
						panels[ID] = panel;
					}
					if ( this._isMounted )
					{
						this.setState({ rows, panels });
					}
					let item = await Dashboards_LoadItem(ID);
					if ( item != null && this._isMounted )
					{
						this.setState({ item: item, DASHBOARD_NAME: item.NAME, ASSIGNED_USER_ID: item.ASSIGNED_USER_ID });
					}
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			// 06/08/2021 Paul.  We only save error as a string as it is rendered in a span. 
			if ( error.message === undefined )
				this.setState({ error: error });
			else
				this.setState({ error: error.message });
		}
	}

	private _onNameChange = (e) =>
	{
		let value = e.target.value;
		if ( this._isMounted )
		{
			this.setState({ DASHBOARD_NAME: value, error: null });
		}
	}

	private GetColumnWidths = (items) =>
	{
		let nCOLUMN_WIDTH: number = 12;
		if      ( items <= 1 ) nCOLUMN_WIDTH = 12;
		else if ( items <= 2 ) nCOLUMN_WIDTH =  6;
		else if ( items <= 3 ) nCOLUMN_WIDTH =  4;
		else if ( items <= 4 ) nCOLUMN_WIDTH =  3;
		else if ( items <= 6 ) nCOLUMN_WIDTH =  2;
		else                   nCOLUMN_WIDTH =  1;
		return nCOLUMN_WIDTH;
	}
	
	private _onSave = async (e) =>
	{
		const { CATEGORY } = this.props;
		const { ID, DASHBOARD_NAME, ASSIGNED_USER_ID, rows, panels } = this.state;
		try
		{
			if ( this._isMounted )
			{
				let sID = Sql.ToGuid(ID);
				let nPANEL_ORDER = 0;
				let row: any = {};
				row.ID               = sID;
				row.CATEGORY         = CATEGORY;
				row.ASSIGNED_USER_ID = Security.USER_ID();
				row.TEAM_ID          = Security.TEAM_ID();
				row.NAME             = DASHBOARD_NAME;
				row.DashboardPanels = new Array();
				if ( Sql.IsEmptyString(row.NAME) )
				{
					throw(L10n.Term('Dashboard.LBL_NAME_REQUIRED'));
				}
				for ( let nRowIndex = 0; nRowIndex < rows.length; nRowIndex++ )
				{
					for ( let nColIndex = 0; nColIndex < rows[nRowIndex].columns.length; nColIndex++ )
					{
						let sColumnID: string = rows[nRowIndex].columns[nColIndex];
						let src: any = panels[sColumnID];
						let obj: any = {};
						obj.ID                = Sql.ToGuid   (src.ID               );
						obj.PANEL_TYPE        = Sql.ToString (src.PANEL_TYPE       );
						obj.DASHBOARD_APP_ID  = Sql.ToGuid   (src.DASHBOARD_APP_ID );
						obj.NAME              = Sql.ToString (src.NAME             );
						obj.CATEGORY          = Sql.ToString (src.CATEGORY         );
						obj.MODULE_NAME       = Sql.ToString (src.MODULE_NAME      );
						obj.TITLE             = Sql.ToString (src.TITLE            );
						obj.SETTINGS_EDITVIEW = Sql.ToString (src.SETTINGS_EDITVIEW);
						obj.IS_ADMIN          = Sql.ToBoolean(src.IS_ADMIN         );
						obj.APP_ENABLED       = Sql.ToBoolean(src.APP_ENABLED      );
						obj.SCRIPT_URL        = Sql.ToString (src.SCRIPT_URL       );
						obj.DEFAULT_SETTINGS  = Sql.ToString (src.DEFAULT_SETTINGS );
						
						obj.PANEL_ORDER  = nPANEL_ORDER   ;
						obj.ROW_INDEX    = nRowIndex      ;
						// 05/23/2017 Paul.  The column width is stored with the TD record. 
						obj.COLUMN_WIDTH = this.GetColumnWidths(rows[nRowIndex].columns.length);
						row.DashboardPanels.push(obj);
						nPANEL_ORDER++;
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave', obj.NAME);
					}
				}
				if ( nPANEL_ORDER == 0 )
				{
					throw(L10n.Term('Dashboard.LBL_PANELS_EMPTY'));
				}
				// 06/01/2017 Paul.  If this is a global dashboard (i.e. ASSIGNED_USER_ID is null), then save action will create a new dashboard. 
				if ( Sql.IsEmptyGuid(ASSIGNED_USER_ID) )
					row.ID = null;

				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave', row);
				sID = await UpdateModule('Dashboard', row, sID);
				localStorage.setItem('ReactLast' + CATEGORY, sID);
				// 06/16/2019 Paul.  Force the updates. 
				await Dashboards(CATEGORY, true);
				await Dashboards_LoadPanels(sID, true);
				this.props.history.push('/Reset/' + CATEGORY + '/' + sID);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSave', error);
			// 06/08/2021 Paul.  We only save error as a string as it is rendered in a span. 
			if ( error.message === undefined )
				this.setState({ error: error });
			else
				this.setState({ error: error.message });
		}
	}

	private _onCancel = (e) =>
	{
		const { CATEGORY } = this.props;
		const { ID } = this.state;
		if ( this._isMounted )
		{
			if ( !Sql.IsEmptyGuid(ID) )
			{
				this.props.history.push('/Reset/' + CATEGORY + '/' + ID);
			}
			else
			{
				this.props.history.push('/Reset/' + CATEGORY + '/');
			}
		}
	}

	private _onCopy = (e) =>
	{
		if ( this._isMounted )
		{
			// 06/15/2019 Paul.  Copy is the same as Save, but without the ID. 
			this.setState( {ID: null}, async () =>
			{
				await this._onSave(e);
			});
		}
	}

	private _onDelete = async (e) =>
	{
		const { CATEGORY } = this.props;
		const { ID } = this.state;
		try
		{
			if ( this._isMounted && !Sql.IsEmptyGuid(ID) )
			{
				let sID = Sql.ToGuid(localStorage.getItem('ReactLast' + CATEGORY));
				if ( sID == ID )
				{
					localStorage.removeItem('ReactLast' + CATEGORY);
				}
				// 06/08/2021 Paul.  If no dashboards exist, it could be because they were deleted for this category, so remove from list. 
				SplendidCache.DeleteDashboard(CATEGORY, ID);

				await DeleteModuleItem('Dashboard', ID);
				// 06/16/2019 Paul.  Force the updates. 
				await Dashboards(CATEGORY, true);
				this.props.history.push('/Reset/' + CATEGORY);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onDelete', error);
			// 06/08/2021 Paul.  We only save error as a string as it is rendered in a span. 
			if ( error.message === undefined )
				this.setState({ error: error });
			else
				this.setState({ error: error.message });
		}
	}

	private _onCancelProperties = (e) =>
	{
		if ( this._isMounted )
		{
			this.setState({ selected: null, error: null });
		}
	}

	private isAppInUse(app: any)
	{
		const { rows, panels } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.isAppInUse', app);
		for ( let rowIndex = 0; rowIndex < rows.length; rowIndex++ )
		{
			for ( let colIndex = 0; colIndex < rows[rowIndex].columns.length; colIndex++ )
			{
				let id = rows[rowIndex].columns[colIndex];
				if ( panels[id].DASHBOARD_APP_ID == app.ID )
				{
					return true;
				}
			}
		}
		return false;
	}

	public render()
	{
		const { DASHBOARD_NAME, rows, panels, apps, draggingId, item, selected, error, clientHeight } = this.state;
		if ( SplendidCache.IsInitialized )
		{
			// 06/08/2021 Paul.  Adjust the client height as it changes. 
			let windowHeight: string = clientHeight.toString() + 'px';
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', panels, apps);
			return (
			<div style={{ display: 'flex', height: '100%' }}>
				<div style={{ flex: '2 2 0', flexDirection: 'column', margin: '0 .5em', border: '1px solid grey', position: 'relative' }}>
					<div
						id='lstDashlets'
						style={ {height: windowHeight, overflowY: 'scroll'} }
						ref={ (element) => this.refDashlets(element) }
					>
						<div style={{ padding: '.5em', position: 'sticky' }}>
							<DraggableRemove remove={ this.remove } />
							<SourceRow       TITLE={ L10n.Term('DynamicLayout.LBL_NEW_ROW'  ) } removeRow={ this.removeRow } />
							<SourceBlank     TITLE={ L10n.Term('DynamicLayout.LBL_NEW_BLANK') } createItemFromSource={ this.createItemFromSource } />
							<br />
						</div>
						<div style={ { padding: '.5em'} }>
							{ apps.map((app, index) => (
								<SourceItem
									item={ app }
									key={ 'app' + app.ID }
									isAppInUse={ this.isAppInUse(app) }
									createItemFromSource={ this.createItemFromSource }
									moveDraggableItem={ this.moveDraggableItem }
									remove={ this.remove }
								/>
							))}
						</div>
					</div>
				</div>
				<div style={{ flexDirection: 'column', flex: '8 8 0', margin: '0 .5em', border: '1px solid grey' }}>
					<div style={{ padding: '.5em' }}>
						<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onSave   }>{ L10n.Term('.LBL_SAVE_BUTTON_LABEL'           ) }</button>
						<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onCancel }>{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL'         ) }</button>
						<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onCopy   }>{ L10n.Term('Dashboard.LBL_COPY_BUTTON_TITLE'  ) }</button>
						<button type="button" className='button' style={ {marginRight: '2px'} } onClick={ this._onDelete }>{ L10n.Term('Dashboard.LBL_DELETE_BUTTON_TITLE') }</button>
					</div>
					<div style={{ display: 'flex', borderBottom: '1px solid grey', marginBottom: '.2em', padding: '.5em' }}>
						<label style={{ margin: '0 1em' }}>{L10n.Term('Dashboard.LBL_NAME')}</label>
						<div style={{ flexGrow: 1 }}>
							<textarea
								rows={ 3 }
								value={ DASHBOARD_NAME }
								onChange={ this._onNameChange }
								style={ {width: '350px'} }
							/>
							<span className='error' style={ {paddingLeft: '10px'} }>{ error }</span>
						</div>
					</div>
					<div style={{ padding: '.5em' }}>
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
								{ row.columns.map((columnId, colIndex) => (
									<DraggableItem
										item={ panels[columnId] }
										id={ columnId }
										key={ columnId }
										colIndex={ colIndex }
										rowIndex={ rowIndex }
										moveDraggableItem={ this.moveDraggableItem }
										addSourceItem={ this.addSourceItem }
										remove={ this.remove }
										setDragging={ this.setDragging }
										draggingId={ draggingId }
										rowTotal={ row.columns.length}
										onEditClick={ this.handleEditClick }
									/>
								))}
							</DraggableRow>
						))}
					</div>
				</div>
				<div style={{ flex: '2 2 0', border: '1px solid grey', margin: '0 .5em' }}>
					{ selected
						? <div style={ {padding: '.5em'} }>
							<button type="button" className='button' onClick={ this._onCancelProperties }>{ L10n.Term('.LBL_CANCEL_BUTTON_LABEL') }</button>
							<div style={{ display: 'flex', flexDirection: 'column' }}>
								<div style={{ display: 'flex', flex: 1 }}>
									<label style={{ flex: 1 }}>{L10n.TableColumnName('Dashboard', 'ID')}</label>
									<div style={{ flex: 2 }}>{ Sql.ToGuid(selected.ID) }</div>
								</div>
								<div style={{ display: 'flex', flex: 1 }}>
									<label style={{ flex: 1 }}>{L10n.TableColumnName('Dashboard', 'PANEL_TYPE')}</label>
									<div style={{ flex: 2 }}>{ Sql.ToString(selected.PANEL_TYPE) }</div>
								</div>
								<div style={{ display: 'flex', flex: 1 }}>
									<label style={{ flex: 1 }}>{L10n.TableColumnName('Dashboard', 'DASHBOARD_APP_ID')}</label>
									<div style={{ flex: 2 }}>{ Sql.ToGuid(selected.DASHBOARD_APP_ID) }</div>
								</div>
								<div style={{ display: 'flex', flex: 1 }}>
									<label style={{ flex: 1 }}>{L10n.TableColumnName('Dashboard', 'NAME')}</label>
									<div style={{ flex: 2 }}>{ Sql.ToString(selected.NAME) }</div>
								</div>
								<div style={{ display: 'flex', flex: 1 }}>
									<label style={{ flex: 1 }}>{L10n.TableColumnName('Dashboard', 'CATEGORY')}</label>
									<div style={{ flex: 2 }}>{ Sql.ToString(selected.CATEGORY) }</div>
								</div>
								<div style={{ display: 'flex', flex: 1 }}>
									<label style={{ flex: 1 }}>{L10n.TableColumnName('Dashboard', 'MODULE_NAME')}</label>
									<div style={{ flex: 2 }}>{ Sql.ToString(selected.MODULE_NAME) }</div>
								</div>
								<div style={{ display: 'flex', flex: 1 }}>
									<label style={{ flex: 1 }}>{L10n.TableColumnName('Dashboard', 'TITLE')}</label>
									<div style={{ flex: 2 }}>{ Sql.ToString(selected.TITLE) }</div>
								</div>
								<div style={{ display: 'flex', flex: 1 }}>
									<label style={{ flex: 1 }}>{L10n.TableColumnName('Dashboard', 'SETTINGS_EDITVIEW')}</label>
									<div style={{ flex: 2 }}>{ Sql.ToString(selected.SETTINGS_EDITVIEW) }</div>
								</div>
								<div style={{ display: 'flex', flex: 1 }}>
									<label style={{ flex: 1 }}>{L10n.TableColumnName('Dashboard', 'IS_ADMIN')}</label>
									<div style={{ flex: 2 }}>{ Sql.ToBoolean(selected.IS_ADMIN) }</div>
								</div>
								<div style={{ display: 'flex', flex: 1 }}>
									<label style={{ flex: 1 }}>{L10n.TableColumnName('Dashboard', 'APP_ENABLED')}</label>
									<div style={{ flex: 2 }}>{ Sql.ToBoolean(selected.APP_ENABLED) }</div>
								</div>
								<div style={{ display: 'flex', flex: 1 }}>
									<label style={{ flex: 1 }}>{L10n.TableColumnName('Dashboard', 'SCRIPT_URL')}</label>
									<div style={{ flex: 2 }}>{ Sql.ToString(selected.SCRIPT_URL) }</div>
								</div>
								<div style={{ display: 'flex', flex: 1 }}>
									<label style={{ flex: 1 }}>{L10n.TableColumnName('Dashboard', 'DEFAULT_SETTINGS')}</label>
									<div style={{ flex: 2 }}>{ Sql.ToString(selected.DEFAULT_SETTINGS) }</div>
								</div>
							</div>
						</div>
						: null
					}
				</div>
			</div >
			);
		}
		else
		{
			return (
			<div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
				<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
			</div>);
		}
	}
}

export default withRouter(DashboardEditor);
