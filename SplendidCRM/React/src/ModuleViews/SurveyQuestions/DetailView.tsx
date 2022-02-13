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
import { RouteComponentProps, withRouter }            from 'react-router-dom'                        ;
import { observer }                                   from 'mobx-react'                              ;
import { FontAwesomeIcon }                            from '@fortawesome/react-fontawesome'          ;
// 2. Store and Types. 
import { IDetailViewProps, DetailComponent }          from '../../types/DetailComponent'             ;
import ACL_ACCESS                                     from '../../types/ACL_ACCESS'                  ;
import { HeaderButtons }                              from '../../types/HeaderButtons'               ;
// 3. Scripts. 
import Sql                                            from '../../scripts/Sql'                       ;
import L10n                                           from '../../scripts/L10n'                      ;
import Security                                       from '../../scripts/Security'                  ;
import Credentials                                    from '../../scripts/Credentials'               ;
import SplendidCache                                  from '../../scripts/SplendidCache'             ;
import SplendidDynamic_DetailView                     from '../../scripts/SplendidDynamic_DetailView';
import { Crm_Config, Crm_Modules }                    from '../../scripts/Crm'                       ;
import { AuthenticatedMethod, LoginRedirect }         from '../../scripts/Login'                     ;
import { sPLATFORM_LAYOUT }                           from '../../scripts/SplendidInitUI'            ;
import { DetailView_LoadItem, DetailView_LoadLayout } from '../../scripts/DetailView'                ;
import { DeleteModuleItem, ArchiveMoveData }          from '../../scripts/ModuleUpdate'              ;
import SurveyQuestionFactory                          from '../../SurveyComponents'                  ;
import { LoadSurveyTheme }                            from '../../scripts/SurveyUtils'               ;
import { jsonReactState }                             from '../../scripts/Application'               ;
// 4. Components and Views. 
import ErrorComponent                                 from '../../components/ErrorComponent'         ;
import DumpSQL                                        from '../../components/DumpSQL'                ;
import DetailViewRelationships                        from '../../views/DetailViewRelationships'     ;
import AuditView                                      from '../../views/AuditView'                   ;
import ActivitiesPopupView                            from '../../views/ActivitiesPopupView'         ;
import ISurveyQuestionProps                           from '../../types/ISurveyQuestionProps'        ;
import SurveyQuestion                                 from '../../SurveyComponents/SurveyQuestion'   ;
import HeaderButtonsFactory                           from '../../ThemeComponents/HeaderButtonsFactory';

interface IDetailViewState
{
	__total       : number;
	__sql         : string;
	item          : any;
	layout        : any;
	MODULE_NAME   : string;  // 03/01/2019 Paul.  Parents module will be converted to actual module. 
	DETAIL_NAME   : string;
	auditOpen     : boolean;
	activitiesOpen: boolean;
	error         : any;
}

@observer
class SurveyQuestionsDetailView extends React.Component<IDetailViewProps, IDetailViewState>
{
	private _isMounted     : boolean = false;
	private refMap         : Record<string, React.RefObject<DetailComponent<any, any>>>;
	private auditView      = React.createRef<AuditView>();
	private activitiesView = React.createRef<ActivitiesPopupView>();
	private headerButtons  = React.createRef<HeaderButtons>();
	private surveyQuestion = React.createRef<SurveyQuestion<ISurveyQuestionProps, object>>();

	constructor(props: IDetailViewProps)
	{
		super(props);
		let DETAIL_NAME: string = props.MODULE_NAME + '.DetailView' + sPLATFORM_LAYOUT;
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			DETAIL_NAME = props.LAYOUT_NAME;
		}
		this.state =
		{
			__total       : 0,
			__sql         : null,
			item          : null,
			layout        : null,
			MODULE_NAME   : props.MODULE_NAME,
			DETAIL_NAME   ,
			auditOpen     : false,
			activitiesOpen: false,
			error         : null,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		const { ID } = this.props;
		const { MODULE_NAME } = this.state;
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				if ( jsonReactState == null )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount jsonReactState is null');
				}
				if ( Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(false);
				}
				await this.load(MODULE_NAME, ID);
				
				let SURVEY_THEME_ID: string = Crm_Config.ToString('Surveys.DefaultTheme');
				LoadSurveyTheme(SURVEY_THEME_ID);
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

	async componentDidUpdate(prevProps: IDetailViewProps)
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
				const { item, layout, DETAIL_NAME, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + DETAIL_NAME, item);
				if ( layout != null && error == null )
				{
					if ( item != null && this._areRelationshipsComplete )
					{
						this.props.onComponentComplete(MODULE_NAME, null, DETAIL_NAME, item);
					}
				}
			}
		}
	}

	private _areRelationshipsComplete: boolean = false;

	private onRelationshipsComplete = (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.onRelationshipsComplete ' + LAYOUT_NAME, vwMain);
		this._areRelationshipsComplete = true;
		if ( this.props.onComponentComplete )
		{
			const { MODULE_NAME, ID } = this.props;
			const { item, layout, DETAIL_NAME, error } = this.state;
			if ( layout != null && error == null )
			{
				if ( item != null && this._areRelationshipsComplete )
				{
					this.props.onComponentComplete(MODULE_NAME, null, DETAIL_NAME, item);
				}
			}
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private load = async (sMODULE_NAME: string, sID: string) =>
	{
		const { DETAIL_NAME } = this.state;
		try
		{
			const layout = DetailView_LoadLayout(DETAIL_NAME);
			// 06/19/2018 Paul.  Always clear the item when setting the layout. 
			if ( this._isMounted )
			{
				this.setState({ layout: layout, item: null });
				await this.LoadItem(sMODULE_NAME, sID);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private LoadItem = async (sMODULE_NAME: string, sID: string) =>
	{
		try
		{
			// 11/19/2019 Paul.  Change to allow return of SQL. 
			const d = await DetailView_LoadItem(sMODULE_NAME, sID, false, false);
			if ( this._isMounted )
			{
				let item: any = d.results;
				// 11/23/2020 Paul.  Update document title. 
				Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
				this.setState({ item, __sql: d.__sql });
				// 04/29/2019 Paul.  Manually add to the list so that we do not need to request an update. 
				if ( item != null )
				{
					let sNAME = Sql.ToString(item['NAME']);
					if ( !Sql.IsEmptyString(sNAME) )
					{
						SplendidCache.AddLastViewed(sMODULE_NAME, sID, sNAME);
					}
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
			this.setState({ error });
		}
	}

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { ID, history } = this.props;
		const { MODULE_NAME } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		switch ( sCommandName )
		{
			case 'Edit':
			{
				history.push(`/Reset/${MODULE_NAME}/Edit/${ID}`);
				break;
			}
			case 'Duplicate':
			{
				history.push(`/Reset/${MODULE_NAME}/Duplicate/${ID}`);
				break;
			}
			case 'Convert':
			{
				let sNewModule: string = sCommandArguments;
				if ( !Sql.IsEmptyString(sNewModule) )
				{
					history.push(`/Reset/${sNewModule}/Convert/${MODULE_NAME}/${ID}`);
				}
				else
				{
					this.setState( {error: 'NewModule is null'} );
				}
				break;
			}
			case 'Cancel':
			{
				history.push(`/Reset/${MODULE_NAME}/List`);
				break;
			}
			case 'Delete':
			{
				try
				{
					await DeleteModuleItem(MODULE_NAME, ID);
					history.push(`/Reset/${MODULE_NAME}/List`);
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
					this.setState({ error });
				}
				break;
			}
			case 'ViewLog':
			{
				if ( this.auditView.current != null )
				{
					await this.auditView.current.loadData();
					this.setState({ auditOpen: true });
				}
				break;
			}
			case 'ViewRelatedActivities':
			{
				if ( this.activitiesView.current != null )
				{
					let bIncludeRelationships: boolean = Sql.ToString(sCommandArguments).indexOf('IncludeRelationships=1') >= 0;
					await this.activitiesView.current.loadData(bIncludeRelationships);
					this.setState({ activitiesOpen: true });
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

	private _onButtonsLoaded = async () =>
	{
	}

	private _onAuditClose = () =>
	{
		this.setState({ auditOpen: false });
	}

	private _onActivitiesClose = () =>
	{
		this.setState({ activitiesOpen: false });
	}

	private _onTestValidation = () =>
	{
		if ( this.surveyQuestion.current != null )
		{
			try
			{
				if ( this.surveyQuestion.current.validate() )
				{
					let arrValue: string[] = this.surveyQuestion.current.data;
					this.setState({ error: L10n.Term('SurveyQuestions.LBL_SUCCESS') + ' ' + arrValue });
				}
				else
				{
					this.setState({ error: L10n.Term('SurveyQuestions.LBL_FAILURE') });
				}
			}
			catch(error)
			{
				this.setState({ error });
			}
		}
	}

	public render()
	{
		const { ID } = this.props;
		const { item, layout, MODULE_NAME, DETAIL_NAME, auditOpen, activitiesOpen, error } = this.state;
		const { __total, __sql } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		// 05/15/2018 Paul.  Defer process button logic. 
		// 06/26/2019 Paul.  Specify a key so that SplendidGrid will get componentDidMount when changing views. 
		this.refMap = {};
		if ( SplendidCache.IsInitialized && item )
		{
			let question: any = SurveyQuestionFactory(item);
			let sNAME: string = item.NAME;
			if ( Sql.IsEmptyString(sNAME) )
			{
				sNAME = item.DESCRIPTION;
			}
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<React.Fragment>
				<AuditView
					isOpen={ auditOpen }
					callback={ this._onAuditClose }
					MODULE_NAME={ MODULE_NAME }
					NAME={ item.NAME }
					ID={ ID }
					ref={ this.auditView }
				/>
				<ActivitiesPopupView
					isOpen={ activitiesOpen }
					callback={ this._onActivitiesClose }
					PARENT_TYPE={ MODULE_NAME }
					PARENT_ID={ ID }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.activitiesView }
				/>
				{ headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE: sNAME, enableFavorites: true, error, enableHelp: true, helpName: 'DetailView', ButtonStyle: 'ModuleHeader', VIEW_NAME: DETAIL_NAME, row: item, Page_Command: this.Page_Command, showButtons: true, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons, showProcess: false })
				: null
				}
				<DumpSQL SQL={ __sql } />
				<div id="content">
					{ layout
					? SplendidDynamic_DetailView.AppendDetailViewFields(item, layout, this.refMap, 'tabDetailView', null, this.Page_Command)
					: null
					}
					{ question
					? <div>
						<div id='divQuestionDetailView' className='SurveyQuestionDesignFrame SurveyQuestionFrame'>
							{ React.createElement(question, { row: item, displayMode: null, ref: this.surveyQuestion }) }
						</div>
						<div style={ {textAlign: 'center'} }>
							<button onClick={ this._onTestValidation } className='button' style={ {marginTop: '6px'} }>{ L10n.Term('SurveyQuestions.LBL_TEST_VALIDATION') }</button>
						</div>
					</div>
					: null
					}
					<br />
					<DetailViewRelationships key={ this.props.MODULE_NAME + '_DetailViewRelationships' } PARENT_TYPE={ this.props.MODULE_NAME } DETAIL_NAME={ DETAIL_NAME } row={ item } isPrecompile={ this.props.isPrecompile } onComponentComplete={ this.onRelationshipsComplete } />
				</div>
			</React.Fragment>
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

export default withRouter(SurveyQuestionsDetailView);
