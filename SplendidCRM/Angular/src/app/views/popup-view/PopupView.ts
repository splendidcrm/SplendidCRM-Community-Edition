import { Component, OnInit, Input, Output, ViewChild, EventEmitter, ViewChildren, ElementRef, QueryList } from '@angular/core'                         ;
import { Router, ActivatedRoute, ParamMap                          } from '@angular/router'                       ;
import { NgbModal, ModalDismissReasons                             } from '@ng-bootstrap/ng-bootstrap'            ;
import { faSpinner                                                 } from '@fortawesome/free-solid-svg-icons'     ;

import { ApplicationService                                        } from '../../scripts/Application'             ;
import { SplendidCacheService                                      } from '../../scripts/SplendidCache'           ;
import { CredentialsService                                        } from '../../scripts/Credentials'             ;
import { SecurityService                                           } from '../../scripts/Security'                ;
import { L10nService                                               } from '../../scripts/L10n'                    ;
import { CrmConfigService, CrmModulesService                       } from '../../scripts/Crm'                     ;
import { EditViewService                                           } from '../../scripts/EditView'                ;
import { ModuleUpdateService                                       } from '../../scripts/ModuleUpdate'            ;
import { ActiveModuleFromPath, EndsWith                            } from '../../scripts/utility'                 ;
import Sql                                                           from '../../scripts/Sql'                     ;

import EDITVIEWS_FIELD                                               from '../../types/EDITVIEWS_FIELD'           ;
import ACL_ACCESS                                                    from '../../types/ACL_ACCESS'                ;
import MODULE                                                        from '../../types/MODULE'                    ;

import { DynamicButtonsComponent                                   } from '../../components/DynamicButtons'                  ;
import { SplendidGridComponent                                     } from '../../components/SplendidGrid'                    ;
import { SearchViewComponent                                       } from '../../views/search-view/SearchView'               ;
import { DynamicMassUpdateComponent                                } from '../../views/dynamic-mass-update/DynamicMassUpdate';
import { EditViewComponent                                         } from '../edit-view/EditView'                            ;

@Component({
	selector: 'PopupView',
	templateUrl: './PopupView.html',
})
export class PopupViewComponent implements OnInit
{
	public    spinner               = faSpinner;
	private   bIsInitialized        : boolean = null;
	public    TITLE                 : string  = null;
	public    INLINE_EDIT_BUTTON    : string  = null;
	public    PROCESS_NOTES         : string  = null;
	public    selectedItems         : any     = null;
	public    ACLACCESS             : number  = null;
	public    showInlineCreate      : boolean = null;
	public    item                  : any     = null;
	public    error                 : any     = null;
	public    customView            : any     = null;
	public    open                  : boolean = false;
	public    EDIT_NAME             : string  = null;
	public    GRID_NAME             : string  = null;
	public    sMODULE_TITLE         : string  = null;
	public    sTheme                : string  = null;

	@Input()  MODULE_NAME           : string  = null;
	@Input()  rowDefaultSearch      : any     = null;
	@Input()  isOpen                : boolean = null;
	@Input()  showProcessNotes      : boolean = null;
	@Input()  multiSelect           : boolean = null;
	@Input()  ClearDisabled         : boolean = null;
	@Input()  isSearchView          : boolean = null;
	// 01/22/2021 Paul.  Pass the layout name to the popup so that we know the source. 
	@Input()  fromLayoutName        : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	@Input()  isPrecompile          : boolean;
	@Output() onComponentComplete   : EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}> = new EventEmitter<{MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, vwMain: any}>();
	@Output() callback              : EventEmitter<{Action: string, ID?: string, NAME?: string, PROCESS_NOTES?: string, selectedItems?: any}> = new EventEmitter<{Action: string, ID?: string, NAME?: string, PROCESS_NOTES?: string, selectedItems?: any}>();

	@ViewChild('searchView'          ) searchView           : SearchViewComponent       ;
	@ViewChild('splendidGrid'        ) splendidGrid         : SplendidGridComponent     ;
	@ViewChild('updatePanel'         ) updatePanel          : DynamicMassUpdateComponent;
	@ViewChild('dynamicButtonsTop'   ) dynamicButtonsTop    : DynamicButtonsComponent   ;
	@ViewChild('dynamicButtonsBottom') dynamicButtonsBottom : DynamicButtonsComponent   ;
	@ViewChild('editView'            ) editView             : EditViewComponent         ;

	public IsReady()
	{
		return this.bIsInitialized && this.isOpen;
	}

	public IsNotReady()
	{
		return !this.IsReady() && this.isOpen;
	}

	constructor(private modalService: NgbModal, private router: Router, private route: ActivatedRoute, public Application: ApplicationService, public SplendidCache: SplendidCacheService, protected Credentials: CredentialsService, public Security: SecurityService, public L10n: L10nService, public Crm_Config: CrmConfigService, private Crm_Modules: CrmModulesService, private EditView: EditViewService, private ModuleUpdate: ModuleUpdateService)
	{
		this.bIsInitialized     = this.SplendidCache.IsInitialized ;
	}

	async ngOnInit()
	{
		const { MODULE_NAME, SplendidCache, L10n, Credentials, Application, Crm_Config, Crm_Modules, EditView } = this;
		//console.log(this.constructor.name + '.ngOnInit');

		let TITLE             : string = '';
		let PROCESS_NOTES     : string = '';
		let INLINE_EDIT_BUTTON: string = '';
		let ACLACCESS         : number = -1;
		let item              : any    = null;
		let error             : any    = null;
		// 08/24/2019 Paul.  The module name will be null when handling the popup for the parent edit field. 
		if ( !Sql.IsEmptyString(MODULE_NAME) )
		{
			// 11/02/2020 Paul.  Admin modules use search, primary modules use List
			TITLE = L10n.Term(MODULE_NAME + '.LBL_SEARCH_FORM_TITLE');
			if ( TITLE == MODULE_NAME + '.LBL_SEARCH_FORM_TITLE' )
			{
				TITLE = MODULE_NAME + '.LBL_LIST_FORM_TITLE';
			}
			else
			{
				TITLE = MODULE_NAME + '.LBL_SEARCH_FORM_TITLE';
			}
			try
			{
				INLINE_EDIT_BUTTON = MODULE_NAME + ".LNK_NEW_" + Crm_Modules.SingularTableName(Crm_Modules.TableName(MODULE_NAME));
				ACLACCESS          = SplendidCache.GetUserAccess(MODULE_NAME, 'edit', this.constructor.name + '.constructor');
			}
			catch(e)
			{
				error = e;
			}
			if ( ACLACCESS >= 0 )
			{
				// 01/09/2020 Paul.  Disable creation if there is no layout. 
				// 02/02/2020 Paul.  Ignore missing during DynamicLayout. 
				const layout = EditView.LoadLayout(MODULE_NAME + '.PopupView.Inline', true);
				if ( layout == null )
				{
					ACLACCESS = -1;
				}
			}
		}
		// 04/11/2022 Paul.  Search is collapsed by default. 
		let rawOpen        : string  = localStorage.getItem(MODULE_NAME + '.SearchPopup');
		let open           : boolean = (rawOpen == 'true' || Sql.ToBoolean(this.isPrecompile));
		if ( rawOpen == null && Crm_Config.ToBoolean('default_subpanel_open') )
		{
			open = true;
		}
		//console.log(this.constructor.name + '.ngOnInit open', open);
		this.TITLE              = TITLE             ;
		this.INLINE_EDIT_BUTTON = INLINE_EDIT_BUTTON;
		this.PROCESS_NOTES      = PROCESS_NOTES     ;
		this.ACLACCESS          = ACLACCESS         ;
		this.showInlineCreate   = false             ;
		this.item               = item              ;
		this.customView         = null              ;
		this.error              = error             ;
		this.open               = open              ;

		this.EDIT_NAME      = MODULE_NAME + '.SearchPopup';
		this.GRID_NAME      = MODULE_NAME + '.PopupView'  ;
		this.sMODULE_TITLE  = L10n.Term('.moduleList.' + MODULE_NAME);
		this.sTheme         = SplendidCache.UserTheme;
		this.bIsInitialized = this.SplendidCache.IsInitialized;

		try
		{
			// 10/12/2019 Paul.  PopupView will not redirect if not authenticated. 
			let bAuthenticated: boolean = await Application.IsAuthenticated(this.constructor.name + '.componentDidMount');
			if ( bAuthenticated )
			{
				if ( Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(false);
				}
				/*
				// 01/08/2020 Paul.  First check for an Inline specific view, then fallback to a regular view. 
				// 01/08/2020 Paul.  Importing DynamicLayout causes DynamicLayout_Module() to fail. 
				// 04/24/2020 Paul.  Now that we have moved the babel compile to a separate file, we are able to import DynamicLayout. 
				let customView = await DynamicLayout_Module(MODULE_NAME, 'EditViews', 'PopupView.Inline');
				//let customView = SplendidCache.CompiledCustomViews(MODULE_NAME, 'EditViews', 'PopupView.Inline');
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount found custom ' + MODULE_NAME + '.PopupView.Inline');
				this.customView = customView;
				*/
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.error = error;
		}
	}

	ngDoCheck(): void
	{
	}

	// Called once after the first ngDoCheck().
	ngAfterContentInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterContentInit');
	}

	// Called after ngAfterContentInit() and every subsequent ngDoCheck().
	ngAfterContentChecked(): void
	{
		//console.log(this.constructor.name + '.ngAfterContentChecked');
	}

	// Called once after the first ngAfterContentChecked().
	ngAfterViewInit(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewInit');
	}

	// Called after the ngAfterViewInit() and every subsequent ngAfterContentChecked().
	ngAfterViewChecked(): void
	{
		//console.log(this.constructor.name + '.ngAfterViewChecked');
	}

	// Called immediately before Angular destroys the directive or component.
	ngOnDestroy(): void
	{
		//console.log(this.constructor.name + '.ngOnDestroy');
	}

	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	public _onComponentComplete = (obj: {MODULE_NAME: string, RELATED_MODULE: string, LAYOUT_NAME: string, data: any}) =>
	{
		const { MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data } = obj;
		const { error } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + LAYOUT_NAME, data);
		if ( this.onComponentComplete )
		{
			if ( error == null )
			{
				this.onComponentComplete.emit({MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain: data});
			}
		}
	}

	public Page_Command = async (obj: {sCommandName: string, sCommandArguments: string}) =>
	{
		const { sCommandName } = obj;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		try
		{
			switch (sCommandName)
			{
				case 'NewRecord':
				{
					await this.Save();
					break;
				}
				case 'NewRecord.Cancel':
				{
					this.showInlineCreate = false;
					break;
				}
				default:
				{
					this.error = obj.sCommandName + ' is not supported at this time';
					break;
				}
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.error = error;;
		}
	}

	private Save = async () =>
	{
		const { callback, MODULE_NAME } = this;
		const { SplendidCache, L10n, Crm_Modules, ModuleUpdate } = this;
		try
		{
			if ( this.editView != null && this.editView.validate() )
			{
				let row: any = this.editView.data;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Save ' + MODULE_NAME, row);
				try
				{
					if ( this.dynamicButtonsTop != null )
					{
						this.dynamicButtonsTop.EnableButton('NewRecord', false);
						// 06/03/2021 Paul.  Show and hide busy while saving new record. 
						this.dynamicButtonsTop.Busy();
					}
					if ( this.dynamicButtonsBottom != null )
					{
						this.dynamicButtonsBottom.EnableButton('NewRecord', false);
					}
					let ID = await ModuleUpdate.UpdateModule(MODULE_NAME, row, null);
					this.showInlineCreate = false;
					//if ( this.searchView != null )
					//{
					//	this.searchView.SubmitSearch();
					//}
					// 08/10/2019 Paul.  After creation, get the name and select the new record. 
					let NAME: string = await Crm_Modules.ItemName(MODULE_NAME, ID);
					this.callback.emit({ Action: 'SingleSelect', ID, NAME });
				}
				catch(error: any)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Save', error);
					if ( error.message.includes('.ERR_DUPLICATE_EXCEPTION') )
					{
						if ( this.dynamicButtonsTop != null )
						{
							this.dynamicButtonsTop.ShowButton('SaveDuplicate', true);
						}
						if ( this.dynamicButtonsBottom != null )
						{
							this.dynamicButtonsBottom.ShowButton('SaveDuplicate', true);
						}
						this.error = L10n.Term(error.message);;
					}
					else
					{
						this.error = error;;
					}
				}
				finally
				{
					if ( this.dynamicButtonsTop != null )
					{
						this.dynamicButtonsTop.EnableButton('NewRecord', true);
						// 06/03/2021 Paul.  Show and hide busy while saving new record. 
						this.dynamicButtonsTop.NotBusy();
					}
					if ( this.dynamicButtonsBottom != null )
					{
						this.dynamicButtonsBottom.EnableButton('NewRecord', true);
					}
				}
			}
		}
		catch(error: any)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Save', error);
			this.error = error;
		}
	}

	public editViewCallback = (obj: {key: string, newValue: string}) =>
	{
		const { key, newValue } = obj;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.editViewCallback ' + DATA_FIELD, DATA_VALUE);
		let item = this.item;
		if ( item == null )
			item = {};
		item[key] = newValue;
	}

	public _onClose = () =>
	{
		this.showInlineCreate = false;
		console.log(this.constructor.name + '._onClose');
		this.modalService.dismissAll();
		this.callback.emit({ Action: 'Close' });
	}

	public _onClear = () =>
	{
		const { callback } = this;
		this.showInlineCreate = false;
		this.callback.emit({ Action: 'SingleSelect', ID: '', NAME: '' });
	}

	public _onSelectionChanged = (value: any) =>
	{
		const { MODULE_NAME, callback, showProcessNotes, multiSelect } = this;
		const { PROCESS_NOTES } = this;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectionChanged: ' + MODULE_NAME, value);
		let DATA_FIELD = 'NAME';
		if ( MODULE_NAME == 'Users' )
		{
			DATA_FIELD = 'USER_NAME';
		}
		else if ( MODULE_NAME == 'Documents' )
		{
			DATA_FIELD = 'DOCUMENT_NAME';
		}
		let DATA_VALUE = value['ID'];
		let DISPLAY_VALUE = value[DATA_FIELD];
		/*if (value.NAME === undefined)
		{
			if (MODULE_NAME == 'Users')
				sNAME = value.USER_NAME;
		}*/
		if ( multiSelect )
		{
			this.selectedItems = value;
		}
		else
		{
			// 06/04/2018 Paul.  value will be the item record, so it will have an ID and a NAME. 
			if ( showProcessNotes )
			{
				this.callback.emit({ Action: 'SingleSelect', ID: DATA_VALUE, NAME: DISPLAY_VALUE, PROCESS_NOTES: PROCESS_NOTES });
			}
			else
			{
				this.callback.emit({ Action: 'SingleSelect', ID: DATA_VALUE, NAME: DISPLAY_VALUE });
			}
		}
	}

	// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink. 
	public _onHyperLinkCallback = (obj: {MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any}) =>
	{
		const { callback, showProcessNotes } = this;
		const { PROCESS_NOTES } = this;
		const { ID, NAME } = obj;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback', ID, NAME, URL);
		if ( showProcessNotes )
		{
			this.callback.emit({ Action: 'SingleSelect', ID, NAME, PROCESS_NOTES: PROCESS_NOTES });
		}
		else
		{
			this.callback.emit({ Action: 'SingleSelect', ID, NAME });
		}
	}

	public _onProcessNotesChange = (e: any): void =>
	{
		let value = e.target.value;
		this.PROCESS_NOTES = value;
	}

	// 09/26/2020 Paul.  The SearchView needs to be able to specify a sort criteria. 
	public _onSearchViewCallback = (obj: {sFILTER: string, row: any, oSORT?: any}) =>
	{
		const { sFILTER, row, oSORT } = obj;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback');
		// 07/13/2019 Paul.  Make Search public so that it can be called from a refrence. 
		if ( this.splendidGrid != null )
		{
			this.splendidGrid.Search(sFILTER, row, oSORT);
		}
	}

	public _onGridLayoutLoaded = () =>
	{
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGridLayoutLoaded ' + this.MODULE_NAME, this.searchView);
		// 05/08/2019 Paul.  Once we have the Search callback, we can tell the SearchView to submit and it will get to the GridView. 
		// 07/13/2019 Paul.  Call SubmitSearch directly. 
		if ( this.searchView != null )
		{
			this.searchView.SubmitSearch();
		}
	}

	public _onSelectMultiple = () =>
	{
		const { callback, showProcessNotes } = this;
		const { PROCESS_NOTES, selectedItems } = this;
		if ( showProcessNotes )
			this.callback.emit({ Action: 'MultipleSelect', selectedItems: selectedItems, PROCESS_NOTES: PROCESS_NOTES });
		else
			this.callback.emit({ Action: 'MultipleSelect', selectedItems: selectedItems });
	}

	public _onShowInlineEdit = () =>
	{
		let { showInlineCreate } = this;
		this.showInlineCreate = !showInlineCreate;
	}

	public _onToggleFilter = () =>
	{
		this.open = !this.open;
	}

}
