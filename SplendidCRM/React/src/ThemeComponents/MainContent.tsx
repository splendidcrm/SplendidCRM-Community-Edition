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
import React                                  from 'react'                             ;
import { observer }                           from 'mobx-react'                        ;
import { RouteComponentProps }                from '../Router5'                        ;
// 2. Store and Types. 
// 3. Scripts. 
import Credentials                            from '../scripts/Credentials'            ;
import SplendidCache                          from '../scripts/SplendidCache'          ;
import { Crm_Config }                         from '../scripts/Crm'                    ;
// 4. Components and Views. 
import { TopNavFactory, SideBarFactory }      from '../ThemeComponents'                ;
import TeamTree                               from '../components/TeamTree'            ;

interface IMainContentProps extends RouteComponentProps<any>
{
	children?: React.ReactNode;
}

@observer
export default class MainContent extends React.Component<IMainContentProps>
{
	constructor(props: IMainContentProps)
	{
		super(props);
	}

	async componentDidMount()
	{
	}

	componentWillUnmount()
	{
	}

	public render()
	{
		const { children } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', props);

		SplendidCache.IsInitialized;
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
		return (<React.Fragment>
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
		</React.Fragment>);
	}
}
