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
import posed                                        from 'react-pose'                          ;
import { RouteComponentProps, withRouter }          from 'react-router-dom'                    ;
import { Modal }                                    from 'react-bootstrap'                     ;
import { observer }                                 from 'mobx-react'                          ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'      ;
import { Appear }                                   from 'react-lifecycle-appear'              ;
// 2. Store and Types. 
import DETAILVIEWS_RELATIONSHIP                     from '../../types/DETAILVIEWS_RELATIONSHIP';
import { SubPanelHeaderButtons }                    from '../../types/SubPanelHeaderButtons'   ;
// 3. Scripts. 
import Sql                                          from '../../scripts/Sql'                   ;
import L10n                                         from '../../scripts/L10n'                  ;
import Credentials                                  from '../../scripts/Credentials'           ;
import SplendidCache                                from '../../scripts/SplendidCache'         ;
import { DynamicLayout_Module }                     from '../../scripts/DynamicLayout'         ;
import { Crm_Config }                               from '../../scripts/Crm'                   ;
import { DetailView_LoadItem }                      from '../../scripts/DetailView'            ;
import { uuidFast, EndsWith }                       from '../../scripts/utility'               ;
import { LoadSurveyTheme }                          from '../../scripts/SurveyUtils'           ;
import { UpdateModule, DeleteModuleItem, ExecProcedure } from '../../scripts/ModuleUpdate'     ;
import { CreateSplendidRequest, GetSplendidResult } from '../../scripts/SplendidRequest'       ;
// 4. Components and Views. 
import ErrorComponent                               from '../../components/ErrorComponent'     ;
import DynamicButtons                               from '../../components/DynamicButtons'     ;
import PopupView                                    from '../../views/PopupView'               ;
import EditView                                     from '../../views/EditView'                ;
import SubPanelButtonsFactory                       from '../../ThemeComponents/SubPanelButtonsFactory';
import SurveyQuestionFactory                        from '../../SurveyComponents'              ;
import DraggableRow                                 from '../Administration/Dropdown/DraggableRow';

const Content = posed.div(
{
	open:
	{
		height: '100%'
	},
	closed:
	{
		height: 0
	}
});

interface ISurveyPagesProps extends RouteComponentProps<any>
{
	PARENT_TYPE         : string;
	row                 : any;
	layout              : DETAILVIEWS_RELATIONSHIP;
	CONTROL_VIEW_NAME   : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface ISurveyPagesState
{
	PARENT_ID        : string;
	RELATED_MODULE?  : string;
	GRID_NAME?       : string;
	vwMainPages      : any;
	showCancel       : boolean;
	showFullForm     : boolean;
	showTopButtons   : boolean;
	showBottomButtons: boolean;
	showSearch       : boolean;
	showInlineEdit   : boolean;
	multiSelect      : boolean;
	popupOpen        : boolean;
	archiveView      : boolean;
	item?            : any;
	dependents?      : Record<string, Array<any>>;
	error?           : any;
	open             : boolean;
	customView       : any;
	oldQuestion      : any;
	subPanelVisible  : boolean;
}

@observer
class SurveyPages extends React.Component<ISurveyPagesProps, ISurveyPagesState>
{
	private _isMounted   = false;
	private themeURL      : string = null;
	private dynamicButtonsTop    = React.createRef<DynamicButtons>();
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();
	private editView             = React.createRef<EditView>();
	private headerButtons        = React.createRef<SubPanelHeaderButtons>();
	// 11/28/2021 Paul.  Trying to only fire once during precompile. 
	private renderCount: number = 0;

	constructor(props: ISurveyPagesProps)
	{
		super(props);
		const { row } = props;
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		let archiveView: boolean = false;
		let GRID_NAME  : string = props.PARENT_TYPE + '.' + props.layout.CONTROL_NAME;
		if ( props.location.pathname.indexOf('/ArchiveView') >= 0 )
		{
			archiveView = true;
			// 01/27/2020 Paul.  Contacts.Activities.History.ArchiveView is not correct.  We simplified to Contacts.Activities.ArchiveView. 
			if ( props.layout.CONTROL_NAME == 'Activities.History' )
			{
				GRID_NAME = props.PARENT_TYPE + '.Activities.ArchiveView';
			}
			else
			{
				GRID_NAME  += '.ArchiveView';
			}
		}
		// 11/08/2018 Paul.  If no pages exist, then create a page. 
		if ( row.SURVEY_PAGES == null || row.SURVEY_PAGES.length == 0 )
		{
			row.SURVEY_PAGES = [];
			let page: any = {};
			page['SURVEY_PAGE_ID'        ] = uuidFast();
			page['SURVEY_ID'             ] = row['ID'];
			page['NAME'                  ] = null;
			page['PAGE_NUMBER'           ] = 1;
			page['QUESTION_RANDOMIZATION'] = null;
			page['DESCRIPTION'           ] = null;
			row.SURVEY_PAGES.push();
		}
		this.createKeys(row.SURVEY_PAGES);
		// 11/05/2020 Paul.  A customer wants to be able to have subpanels default to open. 
		let rawOpen    : string  = localStorage.getItem(props.CONTROL_VIEW_NAME);
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		let open       : boolean = (rawOpen == 'true' || this.props.isPrecompile);
		if ( rawOpen == null && Crm_Config.ToBoolean('default_subpanel_open') )
		{
			open = true;
		}
		let item: any = {};
		this.state =
		{
			PARENT_ID        : props.row.ID,
			RELATED_MODULE   : props.layout.MODULE_NAME,
			GRID_NAME        ,
			vwMainPages      : row.SURVEY_PAGES,
			showCancel       : true,
			showFullForm     : true,
			showTopButtons   : true,
			showBottomButtons: true,
			showSearch       : false,
			showInlineEdit   : false,
			multiSelect      : true,
			popupOpen        : false,
			archiveView      ,
			item             ,
			dependents       : {},
			error            : null,
			open             ,
			customView       : null,
			oldQuestion      : null,
			subPanelVisible  : Sql.ToBoolean(props.isPrecompile),  // 08/31/2021 Paul.  Must show sub panel during precompile to allow it to continue. 
		};
	}

	async componentDidMount()
	{
		const { row } = this.props;
		this._isMounted = true;
		try
		{
			let SURVEY_THEME_ID: string = row['SURVEY_THEME_ID'];
			if ( Sql.IsEmptyGuid(SURVEY_THEME_ID) )
				SURVEY_THEME_ID = Crm_Config.ToString('Surveys.DefaultTheme');
			LoadSurveyTheme(SURVEY_THEME_ID);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

 	async componentDidUpdate(prevProps: ISurveyPagesProps)
	{
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
		}
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		else
		{
			if ( this.props.onComponentComplete )
			{
				const { RELATED_MODULE, vwMainPages, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate ' + GRID_NAME, layout, vwMain);
				// 04/12/2021 Paul.  layout may be null. 
				if ( error == null )
				{
					if ( vwMainPages != null )
					{
						this.props.onComponentComplete('Surveys', RELATED_MODULE, 'Surveys.SurveyPages', vwMainPages);
					}
				}
			}
		}
	}

	private createKeys = (results: Array<any>) =>
	{
		if ( results != null )
		{
			for ( let i = 0; i < results.length; i++ )
			{
				let row = results[i];
				row.ID_key = row['SURVEY_PAGE_ID'] + '_' + i.toString();
			}
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { showSearch, showInlineEdit } = this.state;
		const { PARENT_ID, RELATED_MODULE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		try
		{
			if ( this._isMounted )
			{
				if ( sCommandName == 'Create' || EndsWith(sCommandName, '.Create') )
				{
					let RELATED_MODULE: string = null;
					if ( sCommandName.indexOf('.') >= 0 )
					{
						RELATED_MODULE = sCommandName.split('.')[0];
					}
					let customView = await DynamicLayout_Module(RELATED_MODULE, 'EditViews', 'EditView.Inline');
					if ( customView )
					{
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command found ' + RELATED_MODULE + '.EditView.Inline');
					}
					// 11/05/2020 Paul.  Also clear any error. 
					this.setState({ showSearch: false, showInlineEdit: true, RELATED_MODULE, customView, error: '' });
				}
				else if ( sCommandName == 'Select' || EndsWith(sCommandName, '.Select') )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command show Select');
					this.setState({ popupOpen: true, error: '' });
				}
				// 10/15/2020 Paul.  There are currently 5 multi-selects, Regions, Roles, Teams, Users and ZipCodes. 
				else if ( sCommandName == 'MultiSelect' || EndsWith(sCommandName, 'MultiSelect();') )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command show Select');
					this.setState({ popupOpen: true, multiSelect: true, error: '' });
				}
				// 04/20/2020 Paul.  SearchOpen and SearchHistory are on the Activities panels. 
				else if ( sCommandName == 'Search' || EndsWith(sCommandName, '.Search') || EndsWith(sCommandName, '.SearchOpen') || EndsWith(sCommandName, '.SearchHistory') )
				{
					this.setState({ showSearch: !showSearch, showInlineEdit: false, error: '' });
				}
				else if ( sCommandName == 'NewRecord' )
				{
					await this.Save();
				}
				else if ( sCommandName == 'NewRecord.Cancel' )
				{
					this.setState({ showInlineEdit: false, customView: null, error: '' });
				}
				else if ( sCommandName == 'NewRecord.FullForm' )
				{
					// 06/28/2019 Paul.  Reset to new edit view with parent ID. 
					// 10/12/2019 Paul.  Support Full Form. 
					this.props.history.push(`/Reset/${RELATED_MODULE}/Edit?SURVEY_ID=${PARENT_ID}`);
				}
				// 11/02/2020 Paul.  Emails.Compose is not a standard command. 
				else if ( sCommandName == 'Emails.Compose' )
				{
					this.props.history.push(`/Reset/Emails/Edit?PARENT_ID=${PARENT_ID}`);
				}
				else
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command: Unknown command ' + sCommandName);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}

	private LoadSurveyPages = async () =>
	{
		const { PARENT_ID, RELATED_MODULE } = this.state;
		try
		{
			const d = await DetailView_LoadItem('Surveys', PARENT_ID, false, false);
			let item: any = d.results;
			return item.SURVEY_PAGES;
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadSurveyPages', error);
			throw(error);
		}
		return null;
	}

	private Save = async () =>
	{
		const { PARENT_TYPE } = this.props;
		const { PARENT_ID, RELATED_MODULE } = this.state;
		try
		{
			if ( this.editView.current != null && this.editView.current.validate() )
			{
				let row: any = this.editView.current.data;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Save ' + PARENT_TYPE, row);
				try
				{
					// 01/08/2020 Paul.  Disable buttons before update. 
					if ( this.dynamicButtonsTop.current != null )
					{
						this.dynamicButtonsTop.current.EnableButton('NewRecord', false);
						// 06/03/2021 Paul.  Show and hide busy while saving new record. 
						this.dynamicButtonsTop.current.Busy();
					}
					if ( this.dynamicButtonsBottom.current != null )
					{
						this.dynamicButtonsBottom.current.EnableButton('NewRecord', false);
					}
					row['SURVEY_ID'] = PARENT_ID;
					let sID = await UpdateModule(RELATED_MODULE, row, null);
					if ( this._isMounted )
					{
						// 07/18/2019 Paul.  We also need to clear the input fields. 
						if ( this.editView.current != null )
						{
							this.editView.current.clear();
						}
						let vwMainPages: any[] = await this.LoadSurveyPages();
						// 03/17/2020 Paul.  Set the state after clearing the form, otherwise this.editView.current will be null. 
						// 03/17/2020 Paul.  Clear the local item as well. 
						let item: any = {};
						this.setState({ showInlineEdit: false, item, vwMainPages });
						// 11/05/2020 Paul.  If an activity is created, but also completed, then we need to refresh the entire page so that the history list gets updated.
						if ( RELATED_MODULE == 'Calls' || RELATED_MODULE == 'Meetings' )
						{
							if ( row['STATUS'] != 'Planned' )
							{
								this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
							}
						}
						else if ( RELATED_MODULE == 'Tasks' )
						{
							if ( row['STATUS'] != 'Not Started' && row['STATUS'] != 'In Progress' && row['STATUS'] != 'Pending Input' )
							{
								this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
							}
						}
					}
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Save', error);
					if ( error.message.includes('.ERR_DUPLICATE_EXCEPTION') )
					{
						if ( this.dynamicButtonsTop.current != null )
						{
							this.dynamicButtonsTop.current.ShowButton('SaveDuplicate', true);
						}
						if ( this.dynamicButtonsBottom.current != null )
						{
							this.dynamicButtonsBottom.current.ShowButton('SaveDuplicate', true);
						}
						this.setState( {error: L10n.Term(error.message) } );
					}
					else
					{
						this.setState({ error });
					}
				}
				finally
				{
					if ( this.dynamicButtonsTop.current != null )
					{
						this.dynamicButtonsTop.current.EnableButton('NewRecord', true);
						// 06/03/2021 Paul.  Show and hide busy while saving new record. 
						this.dynamicButtonsTop.current.NotBusy();
					}
					if ( this.dynamicButtonsBottom.current != null )
					{
						this.dynamicButtonsBottom.current.EnableButton('NewRecord', true);
					}
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Save', error);
			this.setState({ error });
		}
	}

	private editViewCallback = (key, newValue) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.editViewCallback ' + DATA_FIELD, DATA_VALUE);
		let item = this.state.item;
		if ( item == null )
			item = {};
		item[key] = newValue;
		if ( this._isMounted )
		{
			this.setState({ item });
		}
	}

	private _onAddQuestions = async (value: { Action: string, ID: string, NAME: string, selectedItems: any }) =>
	{
		const { PARENT_TYPE } = this.props;
		const { PARENT_ID, RELATED_MODULE } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onAddQuestions', value);
		if ( value.Action == 'SingleSelect' || value.Action == 'MultipleSelect' )
		{
			try
			{
				let arrQUESTION_ID: string[] = [];
				if ( value.Action == 'SingleSelect' )
				{
					arrQUESTION_ID.push(value.ID)
				}
				else if ( value.Action == 'MultipleSelect' )
				{
					for ( let sQUESTION_ID in value.selectedItems )
					{
						arrQUESTION_ID.push(sQUESTION_ID);
					}
				}
				let obj: any = {};
				obj.SURVEY_ID      = PARENT_ID;
				obj.SURVEY_PAGE_ID = null;
				obj.ID_LIST        = arrQUESTION_ID;
				let sBody: string = JSON.stringify(obj);
				let res = await CreateSplendidRequest('Surveys/Rest.svc/AddQuestions', 'POST', 'application/octet-stream', sBody);
				let json = await GetSplendidResult(res);
				if ( this._isMounted )
				{
					let vwMainPages: any[] = await this.LoadSurveyPages();
					this.setState({ vwMainPages, popupOpen: false });
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelect', error);
				// 07/07/2020 Paul.  Make sure to close the popup on error. 
				this.setState({ error, popupOpen: false });
			}
		}
		else if ( value.Action == 'Close' )
		{
			this.setState({ popupOpen: false });
		}
	}

	private onToggleCollapse = (open) =>
	{
		const { CONTROL_VIEW_NAME } = this.props;
		this.setState({ open }, () =>
		{
			if ( open )
			{
				localStorage.setItem(CONTROL_VIEW_NAME, 'true');
			}
			else
			{
				// 11/10/2020 Paul.  Save false instead of remove so that config value default_subpanel_open will work properly. 
				//localStorage.removeItem(CONTROL_VIEW_NAME);
				localStorage.setItem(CONTROL_VIEW_NAME, 'false');
			}
		});
	}

	private _onButtonsLoaded = async () =>
	{
		if ( this.dynamicButtonsTop.current != null )
		{
		}
		if ( this.dynamicButtonsBottom.current != null )
		{
		}
	}

	private moveDraggableRow = (dragIndex: number, hoverIndex: number) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.moveDraggableRow', dragIndex, hoverIndex);
		/*
		const row = vwMain.splice(dragIndex, 1)[0];
		vwMain.splice(hoverIndex, 0, row);
		if ( this._isMounted )
		{
			this.setState({ vwMain, error: null });
		}
		*/
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

	private removeRow = async (index: number) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.removeRow', index);
		try
		{
			let vwMainPages: any[] = await this.LoadSurveyPages();
			this.setState({ vwMainPages });
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.removeRow', error);
			if ( this._isMounted )
			{
				this.setState({ error });
			}
		}
	}

	private dropComplete = async (sourceIndex: number, dropIndex: number) =>
	{
		const { vwMainPages } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.dropComplete', sourceIndex, dropIndex);
		try
		{
			if ( sourceIndex != dropIndex )
			{
				let obj: any = {};
				obj.ID         = vwMainPages[sourceIndex].SURVEY_ID;
				obj.OLD_NUMBER = vwMainPages[sourceIndex].PAGE_NUMBER;
				obj.NEW_NUMBER = vwMainPages[dropIndex  ].PAGE_NUMBER;
				await ExecProcedure('spSURVEYS_MovePage', obj);
				if ( this._isMounted )
				{
					let vwMainPages: any[] = await this.LoadSurveyPages();
					this.setState({ vwMainPages });
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.dropComplete', error);
			if ( this._isMounted )
			{
				this.setState({ error });
			}
		}
	}

	private _onViewSurveyPage = async (row) =>
	{
		const { history } = this.props;
		let MODULE_NAME: string = 'SurveyPages';
		let ID         : string = row['ID'];
		history.push(`/Reset/${MODULE_NAME}/View/${ID}`);
	}

	private _onViewQuestion = async (row) =>
	{
		const { history } = this.props;
		let MODULE_NAME   : string = 'SurveyQuestions';
		let ID            : string = row['ID'            ];
		let SURVEY_PAGE_ID: string = row['SURVEY_PAGE_ID'];
		history.push(`/Reset/${MODULE_NAME}/View/${ID}?SURVEY_PAGE_ID=${SURVEY_PAGE_ID}`);
	}

	private _onEditSurveyPage = async (row) =>
	{
		const { history } = this.props;
		let MODULE_NAME: string = 'SurveyPages';
		let ID         : string = row['ID'];
		history.push(`/Reset/${MODULE_NAME}/Edit/${ID}`);
	}

	private _onDeleteSurveyPage = async (row) =>
	{
		try
		{
			if ( window.confirm(L10n.Term('.NTC_DELETE_CONFIRMATION')) )
			{
				let MODULE_NAME: string = 'SurveyPages';
				let ID         : string = row['ID'];
				await DeleteModuleItem(MODULE_NAME, ID, true);
				if ( this._isMounted )
				{
					let vwMainPages: any[] = await this.LoadSurveyPages();
					this.setState({ vwMainPages });
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onDeleteWorkflow', error);
			this.setState({ error });
		}
	}

	private _onChangePage = (row) =>
	{
		this.setState({ oldQuestion: row })
	}

	private _onClosePageChange = () =>
	{
		this.setState({ oldQuestion: null })
	}

	private _onSelectPage = async (row) =>
	{
		const { oldQuestion } = this.state;
		try
		{
			this.setState({ oldQuestion: null }, async () =>
			{
				let obj: any = {};
				obj.SURVEY_QUESTION_ID = oldQuestion['SURVEY_QUESTION_ID'];
				obj.OLD_PAGE_ID        = oldQuestion['SURVEY_PAGE_ID'    ];
				obj.NEW_PAGE_ID        = row['SURVEY_PAGE_ID'];
				await ExecProcedure('spSURVEY_PAGES_QUESTIONS_Page', obj);
				if ( this._isMounted )
				{
					let vwMainPages: any[] = await this.LoadSurveyPages();
					this.setState({ vwMainPages });
				}
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectPage', error);
			this.setState({ error, oldQuestion: null });
		}
	}

	public render()
	{
		const { row, layout, CONTROL_VIEW_NAME } = this.props;
		const { RELATED_MODULE, GRID_NAME, vwMainPages, error, showCancel, showFullForm, showTopButtons, showBottomButtons, showSearch, showInlineEdit, item, popupOpen, multiSelect, archiveView, open, customView, oldQuestion, subPanelVisible } = this.state;
		let sNewRecordButtons: string = "NewRecord." + (showFullForm ? "FullForm" : (showCancel ? "WithCancel" : "SaveOnly"));
		if ( SplendidCache.IsInitialized && vwMainPages )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = SubPanelButtonsFactory(SplendidCache.UserTheme);
			let MODULE_NAME      : string = RELATED_MODULE;
			let MODULE_TITLE     : string = L10n.Term(layout.TITLE);
			// 07/30/2021 Paul.  Load when the panel appears. 
			return (
				<React.Fragment>
					<PopupView
						isOpen={ popupOpen }
						callback={ this._onAddQuestions }
						MODULE_NAME='SurveyQuestions'
						multiSelect={ true }
						ClearDisabled={ true }
					/>
					<Modal show={ oldQuestion != null } onHide={ this._onClosePageChange } style={{ marginLeft: '30%', marginTop: '20%', height: '50%', width: '40%' }} centered>
						<Modal.Body>
							<table className='table-hover listView' cellSpacing={ 1 } cellPadding={ 3 } style={ {width: '100%'} }>
								<thead>
									<tr className='listViewThS1'>
										<td style={ {width: '25%', whiteSpace: 'nowrap'} }>{ L10n.Term('SurveyPages.LBL_LIST_PAGE_NUMBER') }</td>
										<td style={ {width: '75%', whiteSpace: 'nowrap'} }>{ L10n.Term('SurveyPages.LBL_LIST_NAME'       ) }</td>
										<td></td>
									</tr>
								</thead>
								<tbody>
							{ vwMainPages
							? vwMainPages.map((item, index) => 
								{
									return (
									<tr>
										<td valign='top' className='listViewTdLinkS1'>
											<a href='#' onClick={ (e) => { e.preventDefault(); this._onSelectPage(item); } } className='listViewTdLinkS1'>{ item['PAGE_NUMBER']  }</a>
										</td>
										<td valign='top' className='listViewTdLinkS1'>
											<a href='#' onClick={ (e) => { e.preventDefault(); this._onSelectPage(item); } } className='listViewTdLinkS1'>{ item['NAME'       ]  }</a>
										</td>
									</tr>
									);
								})
							: null
							}
								</tbody>
							</table>
						</Modal.Body>
						<Modal.Footer>
							<button className='button' onClick={ this._onClosePageChange }>{ L10n.Term('.LBL_CLOSE_BUTTON_LABEL') }</button>
						</Modal.Footer>
					</Modal>
					<Appear onAppearOnce={ (ioe) => this.setState({ subPanelVisible: true }) }>
						{ headerButtons
						? React.createElement(headerButtons, { MODULE_NAME, ID: null, MODULE_TITLE, CONTROL_VIEW_NAME, error, ButtonStyle: 'ListHeader', VIEW_NAME: GRID_NAME, row: item, Page_Command: this.Page_Command, showButtons: !showInlineEdit, onToggle: this.onToggleCollapse, isPrecompile: this.props.isPrecompile, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
						: null
						}
					</Appear>
					<Content pose={ open ? 'open' : 'closed' } style={ {overflow: (open ? 'visible' : 'hidden')} }>
						{ open && subPanelVisible
						? <React.Fragment>
							{ showInlineEdit
							? <div>
								{ showTopButtons
								? <div>
									<DynamicButtons
										ButtonStyle="EditHeader"
										VIEW_NAME={ sNewRecordButtons }
										row={ row }
										Page_Command={ this.Page_Command }
										onLayoutLoaded={ this._onButtonsLoaded }
										history={ this.props.history }
										location={ this.props.location }
										match={ this.props.match }
										ref={ this.dynamicButtonsTop }
									/>
									<ErrorComponent error={error} />
								</div>
								: null
								}
								{ customView
								? React.createElement(customView, 
									{
										key             : MODULE_NAME + '.EditView.Inline', 
										MODULE_NAME     , 
										LAYOUT_NAME     : MODULE_NAME + '.EditView.Inline', 
										rowDefaultSearch: item, 
										callback        : this.editViewCallback, 
										history         : this.props.history, 
										location        : this.props.location, 
										match           : this.props.match, 
										ref             : this.editView
									})
								: <EditView
									key={ MODULE_NAME + '.EditView.Inline' }
									MODULE_NAME={ MODULE_NAME }
									LAYOUT_NAME={ MODULE_NAME + '.EditView.Inline' }
									rowDefaultSearch={ item }
									callback={ this.editViewCallback }
									history={ this.props.history }
									location={ this.props.location }
									match={ this.props.match }
									ref={ this.editView }
								/>
								}
								{ showBottomButtons
								? <DynamicButtons
									ButtonStyle="EditHeader"
									VIEW_NAME={ sNewRecordButtons }
									row={ row }
									Page_Command={ this.Page_Command }
									onLayoutLoaded={ this._onButtonsLoaded }
									history={ this.props.history }
									location={ this.props.location }
									match={ this.props.match }
									ref={ this.dynamicButtonsBottom }
								/>
								: null
								}
							</div>
							: null
							}
							<table className='table-hover listView' cellSpacing={ 1 } cellPadding={ 3 } style={ {width: '100%'} }>
								<thead>
									<tr className='listViewThS1'>
										<td style={ {width: '20pt'} }></td>
										<td style={ {width: '10%', whiteSpace: 'nowrap'} }>{ L10n.Term('SurveyPages.LBL_LIST_PAGE_NUMBER') }</td>
										<td style={ {width: '10%', whiteSpace: 'nowrap'} }>{ L10n.Term('SurveyPages.LBL_LIST_NAME'       ) }</td>
										<td style={ {width: '70%', whiteSpace: 'nowrap'} }></td>
										<td></td>
									</tr>
								</thead>
								<tbody>
							{ vwMainPages
							? vwMainPages.map((item, index) => 
								{
									let nVIEW_ACLACCESS  : number = SplendidCache.GetRecordAccess(item, 'SurveyPages', "view"  , null);
									let nEDIT_ACLACCESS  : number = SplendidCache.GetRecordAccess(item, 'SurveyPages', "edit"  , null);
									let nDELETE_ACLACCESS: number = SplendidCache.GetRecordAccess(item, 'SurveyPages', "remove", null);
									return (
								<DraggableRow
									index={ index }
									id={ index + '_row' }
									key={ index + '_row' }
									className={ index % 2 ? 'evenListRowS1' : 'oddListRowS1' }
									moveDraggableRow={ this.moveDraggableRow }
									moveDraggableItem={ this.moveDraggableItem }
									addSourceItem={ this.addSourceItem }
									addSourceRow={ this.addSourceRow }
									removeRow={ this.removeRow } 
									dropComplete={ this.dropComplete }
									length={ 1 }>
									<React.Fragment>
										<td valign='top' className='listViewTdLinkS1'>
											<a href='#' onClick={ (e) => { e.preventDefault(); this._onViewSurveyPage(item); } } className='listViewTdLinkS1'>{ item['PAGE_NUMBER']  }</a>
										</td>
										<td valign='top' className='listViewTdLinkS1'>
											<a href='#' onClick={ (e) => { e.preventDefault(); this._onViewSurveyPage(item); } } className='listViewTdLinkS1'>{ item['NAME'       ]  }</a>
										</td>
										<td valign='top' className='listViewTdLinkS1'>
											<table className='listView' cellSpacing={ 1 } cellPadding={ 3 } style={ {width: '100%'} }>
												<thead>
													<tr>
														<td style={ {whiteSpace: 'nowrap'} }>{ L10n.Term('SurveyQuestions.LBL_LIST_QUESTION_NUMBER') }</td>
														<td style={ {whiteSpace: 'nowrap'} }>{ L10n.Term('SurveyQuestions.LBL_LIST_DESCRIPTION'    ) }</td>
														<td style={ {whiteSpace: 'nowrap'} }>{ L10n.Term('SurveyQuestions.LBL_LIST_NAME'           ) }</td>
														<td style={ {whiteSpace: 'nowrap'} }>{ L10n.Term('SurveyQuestions.LBL_LIST_QUESTION_TYPE'  ) }</td>
														<td></td>
														<td style={ {width:  '1%'} }></td>
													</tr>
												</thead>
												<tbody>
											{ item.SURVEY_QUESTIONS
											? item.SURVEY_QUESTIONS.map((item, index) => 
												{
													let question: any = SurveyQuestionFactory(item);
													return (
													<tr>
														<td valign='top' style={ {width:  '5%'} }>
															<a href='#' onClick={ (e) => { e.preventDefault(); this._onViewQuestion(item); } } className='listViewTdLinkS1'>{ item['QUESTION_NUMBER']  }</a>
														</td>
														<td valign='top' style={ {width: '20%'} }>
															<a href='#' onClick={ (e) => { e.preventDefault(); this._onViewQuestion(item); } } className='listViewTdLinkS1' dangerouslySetInnerHTML={ {__html: item['DESCRIPTION']} } /><br />
															<img src={ this.themeURL + 'blank.gif' } width={ 200 } height={ 1 } /><br />
														</td>
														<td valign='top' style={ {width: '20%'} }>
															{ item['NAME'] }<br />
															<img src={ this.themeURL + 'blank.gif' } width={ 100 } height={ 1 } /><br />
														</td>
														<td valign='top' style={ {width: '25%'} }>
															{ L10n.ListTerm('survey_question_type', item['QUESTION_TYPE']) }<br />
															<img src={ this.themeURL + 'blank.gif' } width={ 100 } height={ 1 } /><br />
														</td>
														<td valign='top' style={ {width: '29%'} }>
															{ question
															? <div className='SurveyQuestionDesignFrame SurveyQuestionFrame' style={ {backgroundColor: 'white'} }>
																{ React.createElement(question, { row: item, displayMode: 'Report' }) }
																</div>
															: null
															}
														</td>
														<td valign='top' style={ {width:  '1%', whiteSpace: 'nowrap'} }>
															<a href='#' onClick={ (e) => { e.preventDefault(); this._onChangePage(item); } } className='listViewTdLinkS1'>{ L10n.Term('SurveyQuestions.LBL_CHANGE_PAGE') }</a>
														</td>
													</tr>
													);
												})
											: null
											}
												</tbody>
											</table>
										</td>
										<td valign='top' className='listViewTdLinkS1'>
											{ nVIEW_ACLACCESS
											? <div style={ {whiteSpace: 'nowrap'} }>
												<img src={ this.themeURL + 'view_inline.gif' } style={ {borderWidth: '0px'} } />
												<span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onViewSurveyPage(item) } className='listViewTdToolsS1'>{ L10n.Term('.LNK_VIEW') }</span>
											</div>
											: null
											}
											{ nEDIT_ACLACCESS
											? <div style={ {whiteSpace: 'nowrap'} }>
												<img src={ this.themeURL + 'edit_inline.gif' } style={ {borderWidth: '0px'} } />
												<span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onEditSurveyPage(item) } className='listViewTdToolsS1'>{ L10n.Term('.LNK_EDIT') }</span>
											</div>
											: null
											}
											{ nDELETE_ACLACCESS
											? <div style={ {whiteSpace: 'nowrap'} }>
												<img src={ this.themeURL + 'delete_inline.gif' } style={ {borderWidth: '0px'} } />
												<span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onDeleteSurveyPage(item) } className='listViewTdToolsS1'>{ L10n.Term('.LNK_DELETE') }</span>
											</div>
											: null
											}
										</td>
									</React.Fragment>
								</DraggableRow>
								);
								})
							: null
							}
								</tbody>
							</table>
							<div ref={ (element) => { if ( this.props.isPrecompile && this.renderCount == 0 ) { this.setState({ subPanelVisible: true }); this.renderCount++; } } }></div>
						</React.Fragment>
						: null
						}
					</Content>
				</React.Fragment>
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

export default withRouter(SurveyPages);
