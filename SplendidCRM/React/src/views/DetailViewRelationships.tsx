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
import posed                                        from 'react-pose'                        ;
import { RouteComponentProps, withRouter }          from '../Router5'                  ;
import { observer }                                 from 'mobx-react'                        ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'    ;
import { Appear }                                   from 'react-lifecycle-appear'            ;
// 2. Store and Types. 
import DETAILVIEWS_RELATIONSHIP                     from '../types/DETAILVIEWS_RELATIONSHIP' ;
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'                    ;
import L10n                                         from '../scripts/L10n'                   ;
import Credentials                                  from '../scripts/Credentials'            ;
import SplendidCache                                from '../scripts/SplendidCache'          ;
import { Crm_Config }                               from '../scripts/Crm'                    ;
import { DetailViewRelationships_LoadLayout }       from '../scripts/DetailViewRelationships';
import { AuthenticatedMethod, LoginRedirect }       from '../scripts/Login'                  ;
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest'        ;
// 4. Components and Views. 
import ErrorComponent                               from '../components/ErrorComponent'      ;
import DumpSQL                                      from '../components/DumpSQL'             ;
import DynamicSubPanelView                          from '../views/DynamicSubPanelView'      ;
import SubPanelButtonsFactory                       from '../ThemeComponents/SubPanelButtonsFactory';

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

interface IDetailViewRelationshipsProps extends RouteComponentProps<any>
{
	PARENT_TYPE: string;
	DETAIL_NAME: string;
	row        : any;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IDetailViewRelationshipsState
{
	layout           : DETAILVIEWS_RELATIONSHIP[];
	activeIndex      : any;
	error?           : any;
	open             : boolean;
	subPanelVisible  : boolean;
	CONTROL_VIEW_NAME: string;
	items            : any[];
	__sql            : string;
	enableInsights   : boolean;
	insights         : any[];
}

class DetailViewRelationships extends React.Component<IDetailViewRelationshipsProps, IDetailViewRelationshipsState>
{
	private themeURL        : string = null;

	constructor(props: IDetailViewRelationshipsProps)
	{
		super(props);
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		let CONTROL_VIEW_NAME: string  = (props.DETAIL_NAME + '.Relationships');
		let rawOpen          : string  = localStorage.getItem(CONTROL_VIEW_NAME);
		let open             : boolean = (rawOpen == null || rawOpen == 'true' || this.props.isPrecompile);
		// 03/31/2022 Paul.  SubPanelHeaderButtons also uses localStorage to get the open state, so update if null. 
		if ( rawOpen == null )
		{
			localStorage.setItem(CONTROL_VIEW_NAME, (open ? 'true' : 'false'));
		}
		this.state =
		{
			layout           : [],
			activeIndex      : {},
			open             ,
			subPanelVisible  : Sql.ToBoolean(props.isPrecompile),
			CONTROL_VIEW_NAME,
			items            : null,
			__sql            : null,
			enableInsights   : false,
			insights         : null,
		};
	}

	async componentDidMount()
	{
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if (status == 1)
			{
				let enableInsights: boolean = false;
				let layout = await DetailViewRelationships_LoadLayout(this.props.DETAIL_NAME);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount layout', layout);
				let items: any[] = this.LoadView(layout);
				if ( layout != null )
				{
					// 03/31/2022 Paul.  Insights only enabled if there is at least one label defined. 
					// 04/11/2022 Paul.  If there are no layout relationships, then insights should be disabled. 
					if ( Crm_Config.ToBoolean('enable_insights') )
					{
						for ( let iRelationship = 0; iRelationship < layout.length; iRelationship++ )
						{
							let lay: DETAILVIEWS_RELATIONSHIP = layout[iRelationship];
							if ( !Sql.IsEmptyString(lay.INSIGHT_LABEL) )
							{
								enableInsights = true;
								break;
							}
						}
					}
				}
				this.setState({ layout, items, enableInsights }, async () =>
				{
					if ( enableInsights )
					{
						this.getInsights();
					}
				});
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

	async componentDidUpdate(prevProps: IDetailViewRelationshipsProps)
	{
		const { items } = this.state;
		if ( this.props.onComponentComplete )
		{
			const { PARENT_TYPE, DETAIL_NAME } = this.props;
			const { error } = this.state;
			if ( this.props.isPrecompile )
			{
				console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate ' + DETAIL_NAME);
			}
			// 04/12/2021 Paul.  Layout may be null if it does not exist. 
			if ( error == null )
			{
				if ( items != null )
				{
					if ( items.length == 0 )
					{
						this.props.onComponentComplete(PARENT_TYPE, null, DETAIL_NAME, items);
					}
					else
					{
						let nCompleted: number= 0;
						for ( let i: number = 0; i < items.length; i++ )
						{
							if ( items[i].precompileCompleted )
							{
								nCompleted++;
							}
						}
						if ( nCompleted == items.length )
						{
							this.props.onComponentComplete(PARENT_TYPE, null, DETAIL_NAME, items);
						}
					}
				}
			}
		}
	}

	private onComponentComplete = (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain): void =>
	{
		const { PARENT_TYPE, DETAIL_NAME } = this.props;
		const { items } = this.state;
		if ( this.props.onComponentComplete )
		{
			let nCompleted: number= 0;
			for ( let i: number = 0; i < items.length; i++ )
			{
				if ( items[i].CONTROL_VIEW_NAME== LAYOUT_NAME )
				{
					items[i].precompileCompleted = true;
				}
				if ( items[i].precompileCompleted )
				{
					nCompleted++;
				}
			}
			if ( this.props.isPrecompile )
			{
				console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + LAYOUT_NAME + ' ' + nCompleted.toString() + ' of ' + items.length.toString());
			}
			if ( nCompleted == items.length )
			{
				this.props.onComponentComplete(PARENT_TYPE, null, DETAIL_NAME, items);
			}
		}
	}

	private LoadView = (layout) =>
	{
		const { PARENT_TYPE, row } = this.props;
		let items = [];
		if ( layout != null )
		{
			for ( let iRelationship = 0; iRelationship < layout.length; iRelationship++ )
			{
				let lay: DETAILVIEWS_RELATIONSHIP = layout[iRelationship];
				let sCONTROL_NAME = Sql.ToString(lay.CONTROL_NAME);

				// 11/30/2012 Paul.  Special control names need to be converted to proper name. 
				let sCONTROL_VIEW_NAME = PARENT_TYPE + '.' + sCONTROL_NAME;
				let sPRIMARY_ID        = Sql.ToGuid(row['ID']);
				if ( sCONTROL_NAME == 'Activities' )
				{
					let layoutOpen: DETAILVIEWS_RELATIONSHIP = { ...lay };
					let itemOpen: any =
					{
						key              : sCONTROL_NAME + sPRIMARY_ID + '.Open',
						row              : row,
						layout           : layoutOpen,
						initialOpen      : localStorage.getItem(sCONTROL_VIEW_NAME + '.Open') == 'true',
						// 03/31/2022 Paul.  Keep original control name. 
						CONTROL_NAME     : sCONTROL_NAME,
						CONTROL_VIEW_NAME: sCONTROL_VIEW_NAME + '.Open',
						PRIMARY_ID       : sPRIMARY_ID,
						RELATED_TYPE     : sCONTROL_NAME,
					};
					itemOpen.layout.TITLE        = 'Activities.LBL_OPEN_ACTIVITIES';
					itemOpen.layout.CONTROL_NAME = 'Activities.Open';
					itemOpen.layout.TABLE_NAME   = itemOpen.layout.TABLE_NAME + '_OPEN';
					itemOpen.IS_PANEL_OPEN       = this.isSubPanelOpen(itemOpen);
					items.push(itemOpen);
				
					let layoutHistory: DETAILVIEWS_RELATIONSHIP = { ...lay };
					let itemHistory: any =
					{
						key              : sCONTROL_NAME + sPRIMARY_ID + '.History',
						row              : row,
						layout           : layoutHistory,
						initialOpen      : localStorage.getItem(sCONTROL_VIEW_NAME + '.History') == 'true',
						// 03/31/2022 Paul.  Keep original control name. 
						CONTROL_NAME     : sCONTROL_NAME,
						CONTROL_VIEW_NAME: sCONTROL_VIEW_NAME + '.History',
						PRIMARY_ID       : sPRIMARY_ID,
						RELATED_TYPE     : sCONTROL_NAME,
					};
					itemHistory.layout.TITLE        = 'Activities.LBL_HISTORY';
					itemHistory.layout.CONTROL_NAME = 'Activities.History';
					itemHistory.layout.TABLE_NAME   = itemHistory.layout.TABLE_NAME + '_HISTORY';
					itemHistory.IS_PANEL_OPEN       = this.isSubPanelOpen(itemHistory);
					items.push(itemHistory);
				}
				else
				{
					let tempLayout: DETAILVIEWS_RELATIONSHIP = { ...lay };
					let item: any =
					{
						key              : sCONTROL_NAME + sPRIMARY_ID,
						row              : row,
						layout           : tempLayout,
						initialOpen      : localStorage.getItem(sCONTROL_VIEW_NAME) == 'true',
						// 03/31/2022 Paul.  Keep original control name. 
						CONTROL_NAME     : sCONTROL_NAME,CONTROL_VIEW_NAME: sCONTROL_VIEW_NAME,
						PRIMARY_ID       : sPRIMARY_ID,
						RELATED_TYPE     : sCONTROL_NAME,
					};
					if ( sCONTROL_NAME == 'ActivitiesOpen' )
					{
						item.layout.TITLE        = 'Activities.LBL_OPEN_ACTIVITIES';
						item.layout.CONTROL_NAME = 'Activities.Open';
						item.RELATED_TYPE        = 'Activities';
					}
					else if ( sCONTROL_NAME == 'ActivitiesHistory' )
					{
						item.layout.TITLE        = 'Activities.LBL_HISTORY';
						item.layout.CONTROL_NAME = 'Activities.History';
						item.RELATED_TYPE        = 'Activities';
					}
					else if ( sCONTROL_NAME == 'Projects' )
					{
						item.layout.CONTROL_NAME = 'Project';
						item.RELATED_TYPE        = 'Project';
					}
					else if ( sCONTROL_NAME == 'ProjectTasks' )
					{
						item.layout.CONTROL_NAME = 'ProjectTask';
						item.RELATED_TYPE        = 'ProjectTask';
					}
					else if ( sCONTROL_NAME == 'MemberOrganizations' )
					{
						item.RELATED_TYPE        = 'Accounts';
					}
					else if ( sCONTROL_NAME == 'Balance' )
					{
						item.RELATED_TYPE        = 'Accounts';
					}
					item.IS_PANEL_OPEN = this.isSubPanelOpen(item);
					items.push(item);
				}
			}
		}
		return items;
	}

	private getInsights = async () =>
	{
		const { open, enableInsights } = this.state;
		let { items, insights } = this.state;
		try
		{
			if ( open && enableInsights && insights == null )
			{
				let res = await CreateSplendidRequest('Rest.svc/GetRelationshipInsights?ModuleName=' + this.props.PARENT_TYPE + '&ID=' + this.props.row.ID, 'GET');
				let json = await GetSplendidResult(res);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getInsights insights', json);
				insights = json.d;
				for ( let i = 0; i < items.length; i++ )
				{
					let item: any = items[i];
					// 03/31/2022 Paul.  Use original control name, not one processed by LoadView(). 
					if ( insights[item.CONTROL_NAME] )
					{
						let insight: any = insights[item.CONTROL_NAME];
						if ( Sql.IsEmptyString(insight.INSIGHT_LABEL) )
							insight.INSIGHT_LABEL = '.LBL_INSIGHT_TOTAL';
						item.INSIGHT_LABEL = L10n.Term(insight.INSIGHT_LABEL);
						item.INSIGHT_VALUE = insight.INSIGHT_VALUE;
					}
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.getInsights items', items);
				this.setState({ __sql: json.__sql, items, insights });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.getInsights', error);
			this.setState({ error });
		}
	}

	private onToggleCollapse = (open) =>
	{
		const { CONTROL_VIEW_NAME } = this.state;
		this.setState({ open }, () =>
		{
			if ( open )
			{
				localStorage.setItem(CONTROL_VIEW_NAME, 'true');
				this.getInsights();
			}
			else
			{
				// 11/10/2020 Paul.  Save false instead of remove so that config value default_subpanel_open will work properly. 
				//localStorage.removeItem(CONTROL_VIEW_NAME);
				localStorage.setItem(CONTROL_VIEW_NAME, 'false');
			}
		});
	}

	private onComponentCollapse = (CONTROL_VIEW_NAME: string, open: boolean) =>
	{
		let { items } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.onComponentCollapse ' + CONTROL_VIEW_NAME, open);
		for ( let i: number = 0; i < items.length; i++ )
		{
			if ( items[i].CONTROL_VIEW_NAME== CONTROL_VIEW_NAME )
			{
				items[i].IS_PANEL_OPEN = open;
				break;
			}
		}
		this.setState({ items });
	}

	private onSubPanelCollapse = (CONTROL_VIEW_NAME: string, open: boolean) =>
	{
		let { items } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.onSubPanelCollapse ' + CONTROL_VIEW_NAME, open);
		for ( let i: number = 0; i < items.length; i++ )
		{
			if ( items[i].CONTROL_VIEW_NAME== CONTROL_VIEW_NAME )
			{
				items[i].IS_PANEL_OPEN = open;
				localStorage.setItem(CONTROL_VIEW_NAME, (open ? 'true' : 'false'));
				break;
			}
		}
		this.setState({ items });
	}

	private isSubPanelOpen = (item) =>
	{
		let rawOpen    : string  = localStorage.getItem(item.CONTROL_VIEW_NAME);
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		let open       : boolean = (rawOpen == 'true' || this.props.isPrecompile);
		if ( rawOpen == null && Crm_Config.ToBoolean('default_subpanel_open') )
		{
			open = true;
		}
		return open;
	}

	public render()
	{
		const { PARENT_TYPE, DETAIL_NAME } = this.props;
		const { error, open, subPanelVisible, CONTROL_VIEW_NAME, items, __sql, enableInsights } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', open);
		if ( error )
		{
			return <ErrorComponent error={error} />;
		}
		else if ( items != null )
		{
			let headerButtons = SubPanelButtonsFactory(SplendidCache.UserTheme);
			let MODULE_NAME      : string = PARENT_TYPE;
			let MODULE_TITLE     : string = L10n.Term('.LBL_SELECT_SUBPANELS');
			// boxShadow: '0 .25rem .5rem rgba(0,0,0,.15)'
			if ( enableInsights )
			{
				return (
					<React.Fragment>
						<Appear onAppearOnce={ (ioe) => this.setState({ subPanelVisible: true }) }>
							{ headerButtons
							? React.createElement(headerButtons, { MODULE_NAME, ID: null, MODULE_TITLE, CONTROL_VIEW_NAME, error, ButtonStyle: 'ListHeader', VIEW_NAME: CONTROL_VIEW_NAME, row: null, showButtons: false, onToggle: this.onToggleCollapse, isPrecompile: this.props.isPrecompile, history: this.props.history, location: this.props.location, match: this.props.match })
							: null
							}
						</Appear>
						<Content pose={ open ? 'open' : 'closed' } style={ {overflow: (open ? 'visible' : 'hidden')} }>
						{ open
						? <React.Fragment>
							<div style={ {margin: '0', padding: '1em'} }>
							{
								items.map(item =>
								(<div className='col-xs-6 col-sm-3 col-md-2' style={ {margin: '0', padding: '0'} }>
									<div style={ {margin: '4px', padding: '0', borderRadius: '4px', border: '.15em solid #ced4da', borderTop: '3px solid #534d64', backgroundColor: (item.IS_PANEL_OPEN ? '#554d661f' : 'inherit'), cursor: 'pointer'} } onClick={ () => this.onSubPanelCollapse(item.CONTROL_VIEW_NAME, !item.IS_PANEL_OPEN) }>
										<div style={ {padding: '0 .5em', marginTop: '.5em', textAlign: 'right'} }>
											<img src={ this.themeURL + item.RELATED_TYPE + '.gif' } style={ {borderWidth: '0px', height: '24px', width: '24px'} } />
										</div>
										<div style={ {padding: '0 .5em', color: '#ef8877', fontSize: '1.25em', fontWeight: 'bold'} }>
											{ item.INSIGHT_VALUE }
										</div>
										<div style={ {borderBottom: '2px solid #ced4dd', fontSize: '1em', lineHeight: '1em', padding: '.5em 0', margin: '0 .5em'} }>
											{ item.INSIGHT_LABEL }
										</div>
										<div style={ {textTransform: 'uppercase', fontSize: '.8em', fontWeight: 'bold', padding: '.5em', color: '#554d66'} }>
											{ L10n.Term(item.layout.TITLE) }
										</div>
									</div>
								</div>))
							}
							</div>
							<div className="clearfix"></div>
							<DumpSQL SQL={ __sql } />
							{
								items.map(item =>
								( item.IS_PANEL_OPEN
								? <DynamicSubPanelView
									PARENT_TYPE={ PARENT_TYPE }
									row={ item.row }
									layout={ item.layout }
									CONTROL_VIEW_NAME={ item.CONTROL_VIEW_NAME }
									isPrecompile={ this.props.isPrecompile }
									onComponentComplete={ this.onComponentComplete } 
									onComponentCollapse={ this.onComponentCollapse }
									/>
								: null
								))
							}
						</React.Fragment>
						: null
						}
						</Content>
					</React.Fragment>
				);
			}
			else
			{
				return items.map(item =>
				(
					<DynamicSubPanelView
						PARENT_TYPE={ PARENT_TYPE }
						row={ item.row }
						layout={ item.layout }
						CONTROL_VIEW_NAME={ item.CONTROL_VIEW_NAME }
						isPrecompile={ this.props.isPrecompile }
						onComponentComplete={ this.onComponentComplete } 
					/>
				));
			}
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

export default withRouter(DetailViewRelationships);
