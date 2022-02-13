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
import { Crm_Config }                               from '../../scripts/Crm'                   ;
import { AuthenticatedMethod }                      from '../../scripts/Login'                 ;
import { DetailView_LoadItem }                      from '../../scripts/DetailView'            ;
import { uuidFast, EndsWith }                       from '../../scripts/utility'               ;
import { LoadSurveyTheme }                          from '../../scripts/SurveyUtils'           ;
import { DeleteModuleItem, ExecProcedure }          from '../../scripts/ModuleUpdate'          ;
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

interface ISurveyQuestionsProps extends RouteComponentProps<any>
{
	PARENT_TYPE         : string;
	row                 : any;
	layout              : DETAILVIEWS_RELATIONSHIP;
	CONTROL_VIEW_NAME   : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface ISurveyQuestionsState
{
	PARENT_ID        : string;
	RELATED_MODULE?  : string;
	GRID_NAME?       : string;
	vwMainQuestions  : any;
	showSearch       : boolean;
	multiSelect      : boolean;
	popupOpen        : boolean;
	archiveView      : boolean;
	error?           : any;
	open             : boolean;
	oldQuestion      : any;
	subPanelVisible  : boolean;
}

@observer
class SurveyQuestions extends React.Component<ISurveyQuestionsProps, ISurveyQuestionsState>
{
	private _isMounted   = false;
	private themeURL      : string = null;
	private dynamicButtonsTop    = React.createRef<DynamicButtons>();
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();
	private editView             = React.createRef<EditView>();
	private headerButtons        = React.createRef<SubPanelHeaderButtons>();

	constructor(props: ISurveyQuestionsProps)
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
		// 11/05/2020 Paul.  A customer wants to be able to have subpanels default to open. 
		let rawOpen    : string  = localStorage.getItem(props.CONTROL_VIEW_NAME);
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		let open       : boolean = (rawOpen == 'true' || this.props.isPrecompile);
		if ( rawOpen == null && Crm_Config.ToBoolean('default_subpanel_open') )
		{
			open = true;
		}
		this.state =
		{
			PARENT_ID        : props.row.ID,
			RELATED_MODULE   : props.layout.MODULE_NAME,
			GRID_NAME        ,
			vwMainQuestions  : row.SURVEY_QUESTIONS,
			showSearch       : false,
			multiSelect      : true,
			popupOpen        : false,
			archiveView      ,
			error            : null,
			open             ,
			oldQuestion      : null,
			subPanelVisible  : Sql.ToBoolean(props.isPrecompile),  // 08/31/2021 Paul.  Must show sub panel during precompile to allow it to continue. 
		};
	}

	async componentDidMount()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', this.props.row);
		this._isMounted = true;
		try
		{
			this.loadData();
			
			let SURVEY_THEME_ID: string = Crm_Config.ToString('Surveys.DefaultTheme');
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

 	async componentDidUpdate(prevProps: ISurveyQuestionsProps)
	{
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
		}
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		else
		{
			if ( this.props.onComponentComplete )
			{
				const { RELATED_MODULE, vwMainQuestions, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate ' + GRID_NAME, layout, vwMain);
				// 04/12/2021 Paul.  layout may be null. 
				if ( error == null )
				{
					if ( vwMainQuestions != null )
					{
						this.props.onComponentComplete('SurveyPages', RELATED_MODULE, 'SurveyPages.SurveyQuestions', vwMainQuestions);
					}
				}
			}
		}
	}

	public loadData = async () =>
	{
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.loadData');
			if ( status == 1 )
			{
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.loadData', error);
			this.setState({ error });
		}
	}

	// https://github.com/react-bootstrap-table/react-bootstrap-table2/tree/master/docs#onTableChange
	private handleTableChange = (type, { sortField, sortOrder }) =>
	{
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { row, history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		try
		{
			if ( this._isMounted )
			{
				if ( sCommandName == 'Create' || EndsWith(sCommandName, '.Create') )
				{
					let MODULE_NAME   : string = 'SurveyQuestions';
					let SURVEY_ID     : string = row['SURVEY_ID'];
					let SURVEY_PAGE_ID: string = row['ID'       ];
					history.push(`/Reset/${MODULE_NAME}/Edit?SURVEY_ID=${SURVEY_ID}&SURVEY_PAGE_ID=${SURVEY_PAGE_ID}`);
				}
				else if ( sCommandName == 'Select' || EndsWith(sCommandName, '.Select') )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command show Select');
					this.setState({ popupOpen: true, error: '' });
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

	private LoadSurveyQuestions = async () =>
	{
		const { PARENT_ID, RELATED_MODULE } = this.state;
		try
		{
			const d = await DetailView_LoadItem('SurveyPages', PARENT_ID, false, false);
			let item: any = d.results;
			return item.SURVEY_QUESTIONS;
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadSurveyQuestions', error);
			throw(error);
		}
		return null;
	}

	private _onAddQuestions = async (value: { Action: string, ID: string, NAME: string, selectedItems: any }) =>
	{
		const { row } = this.props;
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
				obj.SURVEY_ID      = row.SURVEY_ID;
				obj.SURVEY_PAGE_ID = row.ID;
				obj.ID_LIST        = arrQUESTION_ID;
				let sBody: string = JSON.stringify(obj);
				let res = await CreateSplendidRequest('Surveys/Rest.svc/AddQuestions', 'POST', 'application/octet-stream', sBody);
				let json = await GetSplendidResult(res);
				if ( this._isMounted )
				{
					let vwMainQuestions: any[] = await this.LoadSurveyQuestions();
					this.setState({ vwMainQuestions, popupOpen: false });
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onAddQuestions', error);
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
			let vwMainQuestions: any[] = await this.LoadSurveyQuestions();
			this.setState({ vwMainQuestions });
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
		const { vwMainQuestions } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.dropComplete', sourceIndex, dropIndex);
		try
		{
			if ( sourceIndex != dropIndex )
			{
				let obj: any = {};
				obj.ID         = vwMainQuestions[sourceIndex].SURVEY_PAGE_ID;
				obj.OLD_NUMBER = vwMainQuestions[sourceIndex].QUESTION_NUMBER;
				obj.NEW_NUMBER = vwMainQuestions[dropIndex  ].QUESTION_NUMBER;
				await ExecProcedure('spSURVEY_PAGES_MoveQuestion', obj);
				if ( this._isMounted )
				{
					let vwMainQuestions: any[] = await this.LoadSurveyQuestions();
					this.setState({ vwMainQuestions });
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

	private _onViewQuestion = async (row) =>
	{
		const { history } = this.props;
		let MODULE_NAME   : string = 'SurveyQuestions';
		let ID            : string = row['ID'            ];
		let SURVEY_PAGE_ID: string = row['SURVEY_PAGE_ID'];
		history.push(`/Reset/${MODULE_NAME}/View/${ID}?SURVEY_PAGE_ID=${SURVEY_PAGE_ID}`);
	}

	private _onEditQuestion = async (row) =>
	{
		const { history } = this.props;
		let MODULE_NAME: string = 'SurveyQuestions';
		let ID         : string = row['ID'];
		history.push(`/Reset/${MODULE_NAME}/Edit/${ID}`);
	}

	private _onDeleteQuestion = async (row) =>
	{
		try
		{
			if ( window.confirm(L10n.Term('.NTC_DELETE_CONFIRMATION')) )
			{
				let MODULE_NAME: string = 'SurveyQuestions';
				let ID         : string = row['ID'];
				await DeleteModuleItem(MODULE_NAME, ID, true);
				if ( this._isMounted )
				{
					let vwMainQuestions: any[] = await this.LoadSurveyQuestions();
					this.setState({ vwMainQuestions });
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onDeleteWorkflow', error);
			this.setState({ error });
		}
	}

	public render()
	{
		const { row, layout, CONTROL_VIEW_NAME } = this.props;
		const { RELATED_MODULE, GRID_NAME, vwMainQuestions, error, showSearch, popupOpen, multiSelect, archiveView, open, oldQuestion, subPanelVisible } = this.state;
		if ( SplendidCache.IsInitialized && vwMainQuestions )
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
					<Appear onAppearOnce={ (ioe) => this.setState({ subPanelVisible: true }) }>
						{ headerButtons
						? React.createElement(headerButtons, { MODULE_NAME, ID: null, MODULE_TITLE, CONTROL_VIEW_NAME, error, ButtonStyle: 'ListHeader', VIEW_NAME: GRID_NAME, row, Page_Command: this.Page_Command, showButtons: true, onToggle: this.onToggleCollapse, isPrecompile: this.props.isPrecompile, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
						: null
						}
					</Appear>
					<Content pose={ open ? 'open' : 'closed' } style={ {overflow: (open ? 'visible' : 'hidden')} }>
						{ open && subPanelVisible
						? <React.Fragment>
							<ErrorComponent error={error} />
							<table className='listView' cellSpacing={ 1 } cellPadding={ 3 } style={ {width: '100%'} }>
								<thead>
									<tr>
										<td style={ {width: '20pt'} }></td>
										<td style={ {whiteSpace: 'nowrap'} }>{ L10n.Term('SurveyQuestions.LBL_LIST_QUESTION_NUMBER') }</td>
										<td style={ {whiteSpace: 'nowrap'} }>{ L10n.Term('SurveyQuestions.LBL_LIST_DESCRIPTION'    ) }</td>
										<td style={ {whiteSpace: 'nowrap'} }>{ L10n.Term('SurveyQuestions.LBL_LIST_NAME'           ) }</td>
										<td style={ {whiteSpace: 'nowrap'} }>{ L10n.Term('SurveyQuestions.LBL_LIST_QUESTION_TYPE'  ) }</td>
										<td></td>
										<td style={ {width:  '1%'} }></td>
									</tr>
								</thead>
								<tbody>
							{ vwMainQuestions
							? vwMainQuestions.map((item, index) => 
								{
									let nVIEW_ACLACCESS  : number = SplendidCache.GetRecordAccess(item, 'SurveyQuestions', "view"  , null);
									let nEDIT_ACLACCESS  : number = SplendidCache.GetRecordAccess(item, 'SurveyQuestions', "edit"  , null);
									let nDELETE_ACLACCESS: number = SplendidCache.GetRecordAccess(item, 'SurveyQuestions', "remove", null);
									let question: any = SurveyQuestionFactory(item);
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
										<td valign='top' className='listViewTdLinkS1'>
											{ nVIEW_ACLACCESS
											? <div style={ {whiteSpace: 'nowrap'} }>
												<img src={ this.themeURL + 'view_inline.gif' } style={ {borderWidth: '0px'} } />
												<span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onViewQuestion(item) } className='listViewTdToolsS1'>{ L10n.Term('.LNK_VIEW') }</span>
											</div>
											: null
											}
											{ nEDIT_ACLACCESS
											? <div style={ {whiteSpace: 'nowrap'} }>
												<img src={ this.themeURL + 'edit_inline.gif' } style={ {borderWidth: '0px'} } />
												<span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onEditQuestion(item) } className='listViewTdToolsS1'>{ L10n.Term('.LNK_EDIT') }</span>
											</div>
											: null
											}
											{ nDELETE_ACLACCESS
											? <div style={ {whiteSpace: 'nowrap'} }>
												<img src={ this.themeURL + 'delete_inline.gif' } style={ {borderWidth: '0px'} } />
												<span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onDeleteQuestion(item) } className='listViewTdToolsS1'>{ L10n.Term('.LNK_DELETE') }</span>
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

export default withRouter(SurveyQuestions);
