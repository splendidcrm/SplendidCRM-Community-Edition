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
import { RouteComponentProps, withRouter } from 'react-router-dom'                 ;
import { library }                         from '@fortawesome/fontawesome-svg-core';
import { faSync, faCog, faSpinner, faAsterisk, faFile, faSave, faEdit, faTimes, faChevronDown, faChevronUp, faChevronLeft, faChevronRight, faAngleRight, faAngleLeft, faAngleDoubleRight, faAngleDoubleLeft, faSearch, faPlus, faMinus, faMinusCircle, faQuestion, faSortDown, faAngleDoubleUp, faAngleDoubleDown, faStar, faArrowAltCircleRight, faArrowCircleRight, faCaretDown, faArrowDown, faArrowRight, faInfo, faTrashAlt, faWindowClose, faSort, faExternalLinkAlt, faCheckSquare, faCheck, faFolder, faCaretSquareUp, faCaretSquareDown, faAngleUp, faAngleDown, faArrowUp } from '@fortawesome/free-solid-svg-icons';
import { faStar as faStarRegular, faArrowAltCircleRight as faArrowAltCircleRightRegular, faEye as faEyeRegular, faFile as faFileRegular, faFolder as faFolderRegular } from '@fortawesome/free-regular-svg-icons';
import { faCopy, faPaste, faUndo, faRedo, faAlignLeft, faAlignRight, faAlignCenter, faAlignJustify, faList, faHouse, faUser, faLessThan, faGreaterThan, faFilter, faXmark, faFileExport } from '@fortawesome/free-solid-svg-icons';
import { observer, inject }                from 'mobx-react'                       ;
import { DndProvider }                     from 'react-dnd'                        ;
import { TouchBackend }                    from 'react-dnd-touch-backend'          ;
import { HTML5Backend }                    from 'react-dnd-html5-backend'          ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                 from './scripts/Sql'                    ;
import { isTouchDevice }                   from './scripts/utility'                ;
import Credentials                         from './scripts/Credentials'            ;
import SplendidCache                       from './scripts/SplendidCache'          ;
import { Crm_Config }                      from './scripts/Crm'                    ;
import SignalRStore                        from './SignalR/SignalRStore'           ;
// 4. Components and Views. 
import { TopNavFactory, SideBarFactory }   from './ThemeComponents'                ;
import TeamTree                            from './components/TeamTree'            ;

const isMobile   = isTouchDevice();
// https://react-dnd.github.io/react-dnd/docs/tutorial
const DnDBackend = isMobile ? TouchBackend : HTML5Backend;

interface IAppProps extends RouteComponentProps<any>
{
}

interface IAppState
{
}

// https://github.com/react-dnd/react-dnd/issues/1424
//@DragDropContext(HTML5Backend)
@observer
class App extends React.Component<IAppProps, IAppState>
{
	constructor(props: IAppProps)
	{
		super(props);
		library.add(faSync, faCog, faSpinner, faAsterisk, faFile, faSave, faEdit, faTimes, faChevronDown, faChevronUp, faChevronLeft, faChevronRight, faAngleRight, faAngleLeft, faAngleDoubleRight, faAngleDoubleLeft, faSearch, faPlus, faMinus, faMinusCircle, faQuestion, faSortDown, faAngleDoubleUp, faAngleDoubleDown, faStar, faArrowAltCircleRight, faArrowCircleRight, faCaretDown, faArrowDown, faArrowRight, faInfo, faWindowClose, faSort, faExternalLinkAlt, faCheckSquare, faCheck, faFolder, faCaretSquareUp, faCaretSquareDown, faAngleUp, faAngleDown, faArrowUp);
		library.add(faStarRegular, faArrowAltCircleRightRegular, faEyeRegular, faTrashAlt, faFileRegular, faFolderRegular);
		library.add(faCopy, faPaste, faUndo, faRedo, faAlignLeft, faAlignRight, faAlignCenter, faAlignJustify, faList, faHouse, faUser, faLessThan, faGreaterThan, faFilter, faXmark, faFileExport);
		
		this.state = 
		{
		};
	}

	async componentDidMount()
	{
		SignalRStore.SetHistory(this.props.history);
	}

	public render()
	{
		const { children } = this.props;
		//console.log((new Date()).toISOString() + ' ' + 'App.render', children);
		// 05/26/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		// 07/10/2019 Paul.  We cannot condition the entire thing based on the IsInitialized flag as it will prevent app from loading entirely. 
		SplendidCache.IsInitialized;
		// 09/11/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
		Credentials.sUSER_THEME;
		let userTheme: string = SplendidCache.UserTheme;
		let bEnableTeamManagement: boolean = Crm_Config.enable_team_management();
		let bEnableTeamHierarchy : boolean = Crm_Config.enable_team_hierarchy();

		let topNav  = TopNavFactory (userTheme);
		let sideBar = SideBarFactory(userTheme);
		// 10/26/2021 Paul.  Cleanup interface when in in AdminWizard or UserWizard. 
		let showTopNav  : boolean = Credentials.viewMode != 'AdminWizard' && Credentials.viewMode != 'UserWizard';
		let showSideBar : boolean = sideBar && SplendidCache.IsInitialized && Credentials.viewMode != 'AdministrationView' && Credentials.viewMode != 'UnifiedSearch' && (Credentials.viewMode != 'DashboardView' || SplendidCache.UserTheme == 'Sugar2006') && Credentials.viewMode != 'DashboardEditView' && Credentials.viewMode != 'AdminWizard' && Credentials.viewMode != 'UserWizard';
		let showTeamTree: boolean = bEnableTeamManagement && bEnableTeamHierarchy && SplendidCache.IsInitialized && (Credentials.viewMode == 'ListView' || Credentials.viewMode == 'DashboardView' || Credentials.viewMode == 'UnifiedSearch');
		// 04/03/2022 Paul.  Remove background-color white for Pacific theme. 
		let style: any = {display: 'flex', flexDirection: 'row', flexWrap: 'nowrap', height: '100%', width: '100%'};
		if ( userTheme != 'Pacific' )
			style.backgroundColor = 'white';
		return (
			<DndProvider backend = {DnDBackend as any}>
				{ showTopNav && topNav
				? React.createElement(topNav, {})
				: null
				}
				<div style={ style }>
					{ userTheme == 'Sugar2006'
					? <React.Fragment>
						<div id='divSideBar'>
						{ showSideBar
						? React.createElement(sideBar, {})
						: null
						}
						{ showTeamTree
						? <TeamTree />
						: null
						}
						</div>
					</React.Fragment>
					: <React.Fragment>
						{ showSideBar
						? React.createElement(sideBar, {})
						: null
						}
						{ showTeamTree
						? <TeamTree />
						: null
						}
					</React.Fragment>
					}
					<div id='appMainContent'>
						{ children }
					</div>
				</div>
				<br />
			</DndProvider>
		);
	}
}
export default withRouter(App);
