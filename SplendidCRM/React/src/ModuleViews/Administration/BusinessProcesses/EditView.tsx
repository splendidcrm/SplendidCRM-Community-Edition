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
import { RouteComponentProps }                      from '../Router5'                                   ;
import { observer }                                 from 'mobx-react'                                   ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'               ;
import { XMLParser, XMLBuilder }                    from 'fast-xml-parser'                              ;
// 2. Store and Types. 
import { EditComponent }                            from '../../../types/EditComponent'                 ;
import { HeaderButtons }                            from '../../../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                          from '../../../scripts/Sql'                         ;
import L10n                                         from '../../../scripts/L10n'                        ;
import Security                                     from '../../../scripts/Security'                    ;
import Credentials                                  from '../../../scripts/Credentials'                 ;
import SplendidCache                                from '../../../scripts/SplendidCache'               ;
import SplendidDynamic_EditView                     from '../../../scripts/SplendidDynamic_EditView'    ;
import { EndsWith }                                 from '../../../scripts/utility'                     ;
import { Admin_GetReactState }                      from '../../../scripts/Application'                 ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'                       ;
import { EditView_LoadItem, EditView_LoadLayout }   from '../../../scripts/EditView'                    ;
import { CreateSplendidRequest, GetSplendidResult } from '../../../scripts/SplendidRequest'             ;
// 4. Components and Views. 
import ErrorComponent                               from '../../../components/ErrorComponent'           ;
import HeaderButtonsFactory                         from '../../../ThemeComponents/HeaderButtonsFactory';
import DynamicPopupView                             from '../../../views/DynamicPopupView'              ;
import ReportDesignerPopupView                      from '../../../ReportDesigner/PopupView'            ;
// 5. BPMN components
import BpmnModeler                                  from 'bpmn-js/lib/Modeler'                          ;
import propertiesPanelModule                        from 'bpmn-js-properties-panel'                     ;
//import propertiesProviderModule                     from 'bpmn-js-properties-panel/lib/provider/camunda';
const camundaModdleDescriptor                       = require('camunda-bpmn-moddle/resources/camunda.json');
const crmModdleDescriptor                           = require('./descriptors/crm.json');
import propertiesProviderModule                     from './provider'            ;
import paletteProvider                              from './palette'             ;
import replaceProvider                              from './replace'             ;
import popupmenuProvider                            from './popup-menu'          ;
import contextpadProvider                           from './context-pad'         ;
import bpmnRules                                    from './rules'               ;


import 'diagram-js/assets/diagram-js.css';
//import 'bpmn-js-properties-panel/dist/assets/bpmn-js-properties-panel.css';
import './vendor/bpmn-font/css/bpmn-embedded.css';
import './css/app.css';
import './css/properties.css';
import './css/groups.css';
import './css/tabs.css';
import './css/header.css';
import './css/listeners.css';

const newStartEvent = `<?xml version="1.0" encoding="UTF-8"?>
<bpmn2:definitions xmlns:crm="http://splendidcrm" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:bpmn2="http://www.omg.org/spec/BPMN/20100524/MODEL" xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI" xmlns:dc="http://www.omg.org/spec/DD/20100524/DC" xmlns:di="http://www.omg.org/spec/DD/20100524/DI" xsi:schemaLocation="http://www.omg.org/spec/BPMN/20100524/MODEL BPMN20.xsd" id="sample-diagram" targetNamespace="http://bpmn.io/schema/bpmn">
	<bpmn2:process id="Process_1" isExecutable="false" crm:PROCESS_STATUS="false">
		<bpmn2:startEvent id="StartEvent_1"/>
	</bpmn2:process>
	<bpmndi:BPMNDiagram id="BPMNDiagram_1">
		<bpmndi:BPMNPlane id="BPMNPlane_1" bpmnElement="Process_1">
			<bpmndi:BPMNShape id="_BPMNShape_StartEvent_2" bpmnElement="StartEvent_1">
				<dc:Bounds height="36.0" width="36.0" x="412.0" y="240.0"/>
			</bpmndi:BPMNShape>
		</bpmndi:BPMNPlane>
	</bpmndi:BPMNDiagram>
</bpmn2:definitions>`;

interface IAdminEditViewProps extends RouteComponentProps<any>
{
	MODULE_NAME       : string;
	ID                : string;
	LAYOUT_NAME?      : string;
	callback?         : any;
	rowDefaultSearch? : any;
	onLayoutLoaded?   : any;
	onSubmit?         : any;
	DuplicateID?      : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IAdminEditViewState
{
	__total           : number;
	__sql             : string;
	item              : any;
	layout            : any;
	EDIT_NAME         : string;
	DUPLICATE         : boolean;
	LAST_DATE_MODIFIED: Date;
	SUB_TITLE         : any;
	editedItem        : any;
	dependents        : Record<string, Array<any>>;
	error?            : any;
	popupOpen         : boolean;
	reportOpen        : boolean;
	POPUP_MODULE_NAME : string;
	REPORT_JSON       : string;
}

@observer
export default class BusinessProcessesEditView extends React.Component<IAdminEditViewProps, IAdminEditViewState>
{
	private _isMounted           : boolean = false;
	private refMap               : Record<string, React.RefObject<EditComponent<any, any>>>;
	private headerButtons        = React.createRef<HeaderButtons>();
	private bpmnModeler          = null;
	private _hidBPMN             : string = null;
	private _hidSVG              : string = null;
	private fileIMPORT           = React.createRef<HTMLInputElement>();
	private modulePopupCallback    = null;
	private reportDesignerCallback = null;

	public get data (): any
	{
		let row: any = {};
		// 08/27/2019 Paul.  Move build code to shared object. 
		SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
		const currentItem = Object.assign({}, this.state.item, this.state.editedItem, row);
		return currentItem;
	}

	public validate(): boolean
	{
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = SplendidDynamic_EditView.Validate(this.refMap);
		return (nInvalidFields == 0);
	}

	public clear(): void
	{
		// 08/27/2019 Paul.  Move build code to shared object. 
		SplendidDynamic_EditView.Clear(this.refMap);
		if ( this._isMounted )
		{
			this.setState({ editedItem: {} });
		}
	}

	constructor(props: IAdminEditViewProps)
	{
		super(props);
		let EDIT_NAME = props.MODULE_NAME + '.EditView';
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			EDIT_NAME = props.LAYOUT_NAME;
		}
		this.state =
		{
			__total           : 0,
			__sql             : null,
			item              : (props.rowDefaultSearch ? props.rowDefaultSearch : null),
			layout            : null,
			EDIT_NAME         ,
			DUPLICATE         : false,
			LAST_DATE_MODIFIED: null,
			SUB_TITLE         : null,
			editedItem        : null,
			dependents        : {},
			error             : null,
			popupOpen         : false,
			reportOpen        : false,
			POPUP_MODULE_NAME : null,
			REPORT_JSON       : null,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		const { MODULE_NAME } = this.props;
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				// 07/06/2020 Paul.  Admin_GetReactState will also generate an exception, but catch anyway. 
				if ( !(Security.IS_ADMIN() || SplendidCache.AdminUserAccess(MODULE_NAME, 'edit') >= 0) )
				{
					throw(L10n.Term('.LBL_INSUFFICIENT_ACCESS'));
				}
				// 10/27/2019 Paul.  In case of single page refresh, we need to make sure that the AdminMenu has been loaded. 
				if ( SplendidCache.AdminMenu == null )
				{
					await Admin_GetReactState(this.constructor.name + '.componentDidMount');
				}
				if ( !Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(true);
				}
				let designerModules = SplendidCache.GetReportDesignerModules();
				await designerModules.load();
				await this.load();
				window.addEventListener('dragover', this.handleDragOver  );
				window.addEventListener('drop'    , this.handleFileSelect);
			}
			else
			{
				LoginRedirect(this.props.history, this.constructor.name + '.componentDidMount');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	async componentDidUpdate(prevProps: IAdminEditViewProps)
	{
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			// 04/26/2019 Paul.  Bounce through ResetView so that layout gets completely reloaded. 
			// 11/20/2019 Paul.  Include search parameters. 
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		else
		{
			if ( this.props.onComponentComplete )
			{
				const { MODULE_NAME, ID } = this.props;
				const { item, layout, EDIT_NAME, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + EDIT_NAME, item);
				if ( layout != null && error == null )
				{
					if ( ID == null || item != null )
					{
						this.props.onComponentComplete(MODULE_NAME, null, EDIT_NAME, item);
					}
				}
			}
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
		window.removeEventListener('dragover', this.handleDragOver  );
		window.removeEventListener('drop'    , this.handleFileSelect);
	}
	
	private load = async () =>
	{
		const { MODULE_NAME, ID, DuplicateID } = this.props;
		const { EDIT_NAME } = this.state;
		try
		{
			const layout = EditView_LoadLayout(EDIT_NAME);
			let rowDefaultSearch: any = this.props.rowDefaultSearch;
			// 07/01/2021 Paul.  Don't initialize item if duplicate provided. 
			if ( Sql.IsEmptyGuid(ID) && Sql.IsEmptyGuid(DuplicateID) )
			{
				// 06/06/2021 Paul.  Only initialize if new record, otherwise the EditView will not update with value from LoadItem. 
				rowDefaultSearch = {};
			}
			if ( this._isMounted )
			{
				this.setState(
				{
					layout      ,
					item        : (rowDefaultSearch ? rowDefaultSearch : null),
					editedItem  : null,
				}, () =>
				{
					if ( this.props.onLayoutLoaded )
					{
						this.props.onLayoutLoaded();
					}
				});
				if ( !Sql.IsEmptyString(DuplicateID) )
				{
					// 02/06/2024 Paul.  layout may not be available from state, so pass as parameter. 
					await this.LoadItem(MODULE_NAME, DuplicateID, layout);
				}
				else
				{
					// 02/06/2024 Paul.  layout may not be available from state, so pass as parameter. 
					await this.LoadItem(MODULE_NAME, ID, layout);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	// 02/06/2024 Paul.  layout may not be available from state, so pass as parameter. 
	private LoadItem = async (sMODULE_NAME: string, sID: string, layout: any[]) =>
	{
		if ( !Sql.IsEmptyString(sID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView_LoadItem(sMODULE_NAME, sID, true);
				let item: any = d.results;
				let LAST_DATE_MODIFIED: Date = null;
				// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
				if ( item != null && item['DATE_MODIFIED'] !== undefined )
				{
					LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem ', item);
				if ( this._isMounted )
				{
					Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
					this.setState({ layout, item, SUB_TITLE, __sql: d.__sql, LAST_DATE_MODIFIED });
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
				this.setState({ error });
			}
		}
	}

	private _onChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE);
		let item = this.state.editedItem;
		if ( item == null )
			item = {};
		item[DATA_FIELD] = DATA_VALUE;
		if ( this._isMounted )
		{
			this.setState({ editedItem: item });
		}
	}

	private _createDependency = (DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string): void =>
	{
		let { dependents } = this.state;
		if ( dependents[PARENT_FIELD] )
		{
			dependents[PARENT_FIELD].push( {DATA_FIELD, PROPERTY_NAME} );
		}
		else
		{
			dependents[PARENT_FIELD] = [ {DATA_FIELD, PROPERTY_NAME} ]
		}
		if ( this._isMounted )
		{
			this.setState({ dependents: dependents });
		}
	}

	private _onUpdate = (PARENT_FIELD: string, DATA_VALUE: any, item?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate ' + PARENT_FIELD, DATA_VALUE);
		let { dependents, layout } = this.state;
		if ( dependents[PARENT_FIELD] )
		{
			let dependentIds = dependents[PARENT_FIELD];
			for ( let i = 0; i < dependentIds.length; i++ )
			{
				let ref = this.refMap[dependentIds[i].DATA_FIELD];
				if ( ref )
				{
					ref.current.updateDependancy(PARENT_FIELD, DATA_VALUE, dependentIds[i].PROPERTY_NAME, item);
				}
			}
		}
	}

	// 06/15/2018 Paul.  The SearchView will register for the onSubmit event. 
	private _onSubmit = (): void =>
	{
		try
		{
			if ( this.props.onSubmit )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit');
				this.props.onSubmit();
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit', error);
			this.setState({ error });
		}
	}

	private UpdateModule = async (row: any, sID: string) =>
	{
		if ( !Credentials.ValidateCredentials )
		{
			throw new Error('Invalid connection information.');
		}
		else if ( row == null )
		{
			throw new Error(this.constructor.name + '.UpdateModule: row is invalid.');
		}
		else
		{
			let sBody: string = JSON.stringify(row);
			let res = await CreateSplendidRequest('Administration/BusinessProcesses/Rest.svc/UpdateModule', 'POST', 'application/octet-stream', sBody);
			let json = await GetSplendidResult(res);
			sID = json.d;
		}
		return sID;
	}

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { ID, MODULE_NAME, history, location } = this.props;
		const { LAST_DATE_MODIFIED } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		// This sets the local state, which is then passed to DynamicButtons
		try
		{
			let row;
			switch (sCommandName)
			{
				case 'Save':
				case 'SaveNew':
				case 'SaveDuplicate':
				case 'SaveConcurrency':
				{
					this.bpmnModeler.saveXML({ format: true }, (err, xml) =>
					{
						if ( xml !== undefined )
						{
							this._hidBPMN = xml;
							this.bpmnModeler.saveSVG((err, svg) =>
							{
								if ( svg !== undefined )
								{
									this._hidSVG = svg;
									row = { BPMN: xml, SVG: svg };
									
									let isDuplicate = location.pathname.includes('Duplicate');
									row.ID = (isDuplicate ? null : ID);
									if ( LAST_DATE_MODIFIED != null )
									{
										row['LAST_DATE_MODIFIED'] = LAST_DATE_MODIFIED;
									}
									if ( sCommandName == 'SaveDuplicate' || sCommandName == 'SaveConcurrency' )
									{
										row[sCommandName] = true;
									}
									
									if ( this.headerButtons.current != null )
									{
										this.headerButtons.current.Busy();
									}
									this.UpdateModule(row, isDuplicate ? null : ID).then((ID) =>
									{
										row.ID = ID;
										// 02/22/2021 Paul.  A number of admin modules support SaveNew.
										if ( sCommandName == 'SaveNew' )
										{
											history.push(`/Reset/Administration/${MODULE_NAME}/Edit/`);
										}
										else
										{
											history.push(`/Reset/Administration/${MODULE_NAME}/View/` + row.ID);
										}
									})
									.catch((error) =>
									{
										console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
										if ( this.headerButtons.current != null )
										{
											this.headerButtons.current.NotBusy();
										}
										if ( this._isMounted )
										{
											if ( error.message.includes('.ERR_DUPLICATE_EXCEPTION') )
											{
												if ( this.headerButtons.current != null )
												{
													this.headerButtons.current.ShowButton('SaveDuplicate', true);
												}
												this.setState( {error: L10n.Term(error.message) } );
											}
											else if ( error.message.includes('.ERR_CONCURRENCY_OVERRIDE') )
											{
												if ( this.headerButtons.current != null )
												{
													this.headerButtons.current.ShowButton('SaveConcurrency', true);
												}
												this.setState( {error: L10n.Term(error.message) } );
											}
											else
											{
												this.setState({ error });
											}
										}
									});
								}
								else
								{
									this.setState({ error: err.message });
								}
							});
						}
						else
						{
							this.setState({ error: err.message });
						}
					});
					break;
				}
				case 'Cancel':
				{
					if ( Sql.IsEmptyString(ID) )
						history.push(`/Reset/Administration/${MODULE_NAME}/List`);
					else
						history.push(`/Reset/Administration/${MODULE_NAME}/View/${ID}`);
					break;
				}
				case 'Import':
				{
					if ( this.fileIMPORT.current )
					{
						this.fileIMPORT.current.click();
					}
					break;
				}
				default:
				{
					if ( this._isMounted )
					{
						this.setState( {error: sCommandName + ' is not supported at this time'} );
					}
					break;
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}

	private _onEditorCopy = (e) =>
	{
		let editorActions: any = this.bpmnModeler.get('editorActions')._actions;
		editorActions.copy();
	}

	private _onEditorPaste = (e) =>
	{
		let editorActions: any = this.bpmnModeler.get('editorActions')._actions;
		editorActions.paste();
	}

	private _onEditorUndo = (e) =>
	{
		let editorActions: any = this.bpmnModeler.get('editorActions')._actions;
		editorActions.undo();
	}

	private _onEditorRedo = (e) =>
	{
		let editorActions: any = this.bpmnModeler.get('editorActions')._actions;
		editorActions.redo();
	}

	private _onEditorAlignBottom = (e) =>
	{
		let editorActions: any = this.bpmnModeler.get('editorActions')._actions;
		editorActions.alignElements     ({ type: 'bottom'     });
	}

	private _onEditorAlignLeft = (e) =>
	{
		let editorActions: any = this.bpmnModeler.get('editorActions')._actions;
		editorActions.alignElements     ({ type: 'left'       });
	}

	private _onEditorAlignHorzCenter = (e) =>
	{
		let editorActions: any = this.bpmnModeler.get('editorActions')._actions;
		editorActions.alignElements     ({ type: 'center'     });
	}

	private _onEditorAlignRight = (e) =>
	{
		let editorActions: any = this.bpmnModeler.get('editorActions')._actions;
		editorActions.alignElements     ({ type: 'right'      });
	}

	private _onEditorAlignTop = (e) =>
	{
		let editorActions: any = this.bpmnModeler.get('editorActions')._actions;
		editorActions.alignElements     ({ type: 'top'        });
	}

	private _onEditorAlignVertCenter = (e) =>
	{
		let editorActions: any = this.bpmnModeler.get('editorActions')._actions;
		editorActions.alignElements     ({ type: 'middle'     });
	}

	private _onEditorDistributeHorz = (e) =>
	{
		let editorActions: any = this.bpmnModeler.get('editorActions')._actions;
		editorActions.distributeElements({ type: 'horizontal' });
	}

	private _onEditorDistributeVert = (e) =>
	{
		let editorActions: any = this.bpmnModeler.get('editorActions')._actions;
		editorActions.distributeElements({ type: 'vertical'   });
	}

	private _onFileUploadEvent = (e) =>
	{
		let files = e.target.files;
		if ( files.length > 0 )
		{
			var file = files[0];
			// http://www.javascripture.com/FileReader
			var reader = new FileReader();
			reader.onload = () =>
			{
				var xml = reader.result;
				this.bpmnModeler.importXML(xml, (err) =>
				{
					if ( err )
					{
						this.setState({ error: err });
						console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onFileUploadEvent', err);
					}
					else
					{
						this.setState({ error: '' });
					}
				});
			};
			reader.readAsText(file);
		}
	}

	private handleFileSelect = (e) =>
	{
		e.stopPropagation();
		e.preventDefault();
		let files = e.dataTransfer.files;
		let file = files[0];
		let reader = new FileReader();
		reader.onload = (e) =>
		{
			var xml          = reader.result;
			let NAME: string = file.name.toLowerCase();
			let TYPE: string = file.type;
			if ( EndsWith(NAME, '.bpmn') )
			{
				this.bpmnModeler.importXML(xml, (err) =>
				{
					if ( err )
					{
						this.setState({ error: err });
						console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.handleFileSelect', err);
					}
					else
					{
						this.setState({ error: '' });
					}
				});
			}
			else
			{
				this.setState({ error: 'File type must be BPMN.' });
			}
		};
		reader.readAsText(file);
	}

	private handleDragOver = (e) =>
	{
		e.stopPropagation();
		e.preventDefault();
		e.dataTransfer.dropEffect = 'copy'; // Explicitly show this is a copy.
	}

	private _onBindCanvas = (canvas) =>
	{
		const { item } = this.state;
		if ( this.bpmnModeler == null && canvas != null )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onBindCanvas', camundaModdleDescriptor);
			this.bpmnModeler = new BpmnModeler(
			{
				container: canvas,
				propertiesPanel:
				{
					parent: '#js-properties-panel'
				},
				additionalModules:
				[
					propertiesPanelModule,
					propertiesProviderModule,
					paletteProvider,
					replaceProvider,
					popupmenuProvider,
					contextpadProvider,
					bpmnRules,
				],
				moddleExtensions:
				{
					camunda: camundaModdleDescriptor,
					crm: crmModdleDescriptor
				},
				keyboard:
				{
					bindTo: document
				}
			});
			if ( item && !Sql.IsEmptyString(item['BPMN']) )
			{
				try
				{
					this.bpmnModeler.importXML(item['BPMN'], (err) =>
					{
						if ( err )
						{
							this.setState({ error: err });
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onBindCanvas', err);
						}
						else
						{
							this.setState({ error: '' });
						}
					});
				}
				catch(error)
				{
					this.setState({ error });
				}
			}
			else
			{
				this.bpmnModeler.importXML(newStartEvent);
			}
			try
			{
				this.bpmnModeler.on('Splendid.ModulePopup', (type, data) =>
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onBindCanvas Splendid.ModulePopup', data);
					this.modulePopupCallback = data.callback;
					this.setState({ popupOpen: true, reportOpen: false, POPUP_MODULE_NAME: data.MODULE_NAME });
				});
				this.bpmnModeler.on('Splendid.ReportDesignerPopup', (type, data) =>
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onBindCanvas Splendid.ReportDesignerPopup', data);
					this.reportDesignerCallback = data.callback;
					this.setState({ popupOpen: false, reportOpen: true, REPORT_JSON: data.JSON });
				});
			}
			catch(error)
			{
				this.setState({ error });
			}
		}
	}

	private _onSelect = (value: { Action: string, ID: string, NAME: string }) =>
	{
		try
		{
			if ( value.Action == 'SingleSelect' )
			{
				if ( this.modulePopupCallback )
				{
					this.modulePopupCallback(1, value);
					this.setState({ popupOpen: false });
				}
			}
			else if ( value.Action == 'Close' )
			{
				this.setState({ popupOpen: false });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect', error);
		}
	}

	private _onReportChanged = (value: { Action: string, JSON: string, SQL: string }) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onReportChanged', value);
		try
		{
			if ( value.Action == 'Save' )
			{
				if ( this.reportDesignerCallback )
				{
					this.reportDesignerCallback(1, value);
					this.setState({ reportOpen: false });
				}
			}
			else if ( value.Action == 'Close' )
			{
				this.setState({ reportOpen: false });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onReportChanged', error);
		}
	}

	public render()
	{
		const { MODULE_NAME, ID, DuplicateID, callback } = this.props;
		const { item, layout, EDIT_NAME, SUB_TITLE, error, popupOpen, reportOpen, POPUP_MODULE_NAME, REPORT_JSON } = this.state;
		if ( layout == null || (item == null && (!Sql.IsEmptyString(ID) || !Sql.IsEmptyString(DuplicateID))) )
		{
			if ( error )
			{
				return (<ErrorComponent error={error} />);
			}
			else
			{
				return null;
			}
		}
		this.refMap = {};
		let onSubmit = (this.props.onSubmit ? this._onSubmit : null);
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			Credentials.sUSER_THEME;
			const currentItem = Object.assign({}, this.state.item, this.state.editedItem);
			currentItem['MODULE_NAME'] = currentItem['BASE_MODULE'];
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			// 02/11/2024 Paul.  DynamicPopupView is not rerendering when module changes, so change the key. 
			// 02/11/2024 Paul.  use of ...params in withRouter() is causing router params to overwrite existing properties of sub-components. 
			// The solution could be to insert params first, then let properties override. 
			return (
			<div>
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, error, ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, row: item, Page_Command: this.Page_Command, showButtons: true, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<input id='fileIMPORT'
					type='file'
					style={ {display: 'none'} }
					ref={ this.fileIMPORT }
					onChange={ (e) => this._onFileUploadEvent(e) }
				/>
				<DynamicPopupView
					key={ POPUP_MODULE_NAME }
					isOpen={ popupOpen }
					isSearchView={ false }
					fromLayoutName={ EDIT_NAME }
					callback={ this._onSelect }
					MODULE_NAME={ POPUP_MODULE_NAME }
					rowDefaultSearch={ null }
				/>
				<ReportDesignerPopupView
					JSON={ REPORT_JSON }
					isOpen={ reportOpen }
					bReportDesignerWorkflowMode={ true }
					callback={ this._onReportChanged }
				/>
				<div style={ {textAlign: 'center', paddingBottom: '2px'} }>
					<span id="bpmn-toolbar-copy"                    title={ L10n.Term("BusinessProcesses.LBL_BPMN_COPY"                   ) } onClick={ this._onEditorCopy            } style={ {cursor: 'pointer', margin: '4px', display: 'none'} }><FontAwesomeIcon icon="copy"  size="lg" /></span>
					<span id="bpmn-toolbar-paste"                   title={ L10n.Term("BusinessProcesses.LBL_BPMN_PASTE"                  ) } onClick={ this._onEditorPaste           } style={ {cursor: 'pointer', margin: '4px', display: 'none'} }><FontAwesomeIcon icon="paste" size="lg" /></span>
					<span id="bpmn-toolbar-undo"                    title={ L10n.Term("BusinessProcesses.LBL_BPMN_UNDO"                   ) } onClick={ this._onEditorUndo            } style={ {cursor: 'pointer', margin: '4px'                 } }><FontAwesomeIcon icon="undo"  size="lg" /></span>
					<span id="bpmn-toolbar-redo"                    title={ L10n.Term("BusinessProcesses.LBL_BPMN_REDO"                   ) } onClick={ this._onEditorRedo            } style={ {cursor: 'pointer', margin: '4px'                 } }><FontAwesomeIcon icon="redo"  size="lg" /></span>
					<span className='bpmn-toolbar-separator'></span>
					<span id="bpmn-toolbar-align-left"              title={ L10n.Term("BusinessProcesses.LBL_BPMN_ALIGN_LEFT"             ) } onClick={ this._onEditorAlignLeft       } style={ {cursor: 'pointer', margin: '4px'} }><FontAwesomeIcon icon="align-left"    size="lg" /></span>
					<span id="bpmn-toolbar-align-horz-center"       title={ L10n.Term("BusinessProcesses.LBL_BPMN_ALIGN_HORIZONTAL_CENTER") } onClick={ this._onEditorAlignHorzCenter } style={ {cursor: 'pointer', margin: '4px'} }><FontAwesomeIcon icon="align-center"  size="lg" /></span>
					<span id="bpmn-toolbar-align-right"             title={ L10n.Term("BusinessProcesses.LBL_BPMN_ALIGN_RIGHT"            ) } onClick={ this._onEditorAlignRight      } style={ {cursor: 'pointer', margin: '4px'} }><FontAwesomeIcon icon="align-right"   size="lg" /></span>
					<span id="bpmn-toolbar-align-bottom"            title={ L10n.Term("BusinessProcesses.LBL_BPMN_ALIGN_BOTTOM"           ) } onClick={ this._onEditorAlignBottom     } style={ {cursor: 'pointer', margin: '4px'} }><FontAwesomeIcon icon="align-left"    size="lg" transform={ {rotate: 270} } /></span>
					<span id="bpmn-toolbar-align-vert-center"       title={ L10n.Term("BusinessProcesses.LBL_BPMN_ALIGN_VERTICAL_CENTER"  ) } onClick={ this._onEditorAlignVertCenter } style={ {cursor: 'pointer', margin: '4px'} }><FontAwesomeIcon icon="align-center"  size="lg" transform={ {rotate:  90} } /></span>
					<span id="bpmn-toolbar-align-top"               title={ L10n.Term("BusinessProcesses.LBL_BPMN_ALIGN_TOP"              ) } onClick={ this._onEditorAlignTop        } style={ {cursor: 'pointer', margin: '4px'} }><FontAwesomeIcon icon="align-right"   size="lg" transform={ {rotate: 270} } /></span>
					<span id="bpmn-toolbar-distribute-horizontally" title={ L10n.Term("BusinessProcesses.LBL_BPMN_DISTRIBUTE_HORIZONTALLY") } onClick={ this._onEditorDistributeHorz  } style={ {cursor: 'pointer', margin: '4px'} }><FontAwesomeIcon icon="align-justify" size="lg" transform={ {rotate:  90} } /></span>
					<span id="bpmn-toolbar-distribute-vertically"   title={ L10n.Term("BusinessProcesses.LBL_BPMN_DISTRIBUTE_VERTICALLY"  ) } onClick={ this._onEditorDistributeVert  } style={ {cursor: 'pointer', margin: '4px'} }><FontAwesomeIcon icon="align-justify" size="lg" /></span>
				</div>
				<div className="content" id="js-drop-zone" style={ {height: '85vh', border: 'solid 1px black'} }>
					<div className="canvas" id="js-canvas" style={ {height: '85vh'} } ref={ (element) => this._onBindCanvas(element) }></div>
					<div id="js-properties-panel" style={ {position: 'absolute', top: '0px', bottom: '0px', right: '0px', width: '260px', zIndex: 10, borderLeft: '1px solid #ccc', overflow: 'auto'} }></div>
				</div>
			</div>
			);
		}
		else if ( error )
		{
			return (<ErrorComponent error={error} />);
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

