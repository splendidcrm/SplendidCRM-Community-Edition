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
import { RouteComponentProps, withRouter } from 'react-router-dom'                  ;
import TreeView                            from 'react-treeview'                    ;
// 2. Store and Types. 
// 3. Scripts. 
import L10n                                from '../scripts/L10n'                   ;
import Credentials                         from '../scripts/Credentials'            ;
import SplendidCache                       from '../scripts/SplendidCache'          ;
// 4. Components and Views. 

interface ITeamTreeProps extends RouteComponentProps<any>
{
}

interface ITeamTreeState
{
	showTeamTree         : boolean;
	currentTeamID        : string;
	currentTeamName      : string;
	nTeamHierarchyCounter: number;
}

class TeamTree extends React.Component<ITeamTreeProps, ITeamTreeState>
{
	constructor(props: ITeamTreeProps)
	{
		super(props);
		let currentTeamID  : string = null;
		let currentTeamName: string = L10n.Term('Teams.LBL_TEAM_TREE_ROOT');
		let team = SplendidCache.GetSelectedTeamHierarchy();
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', Credentials.TEAM_TREE);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', team);
		if ( team != null && typeof(team) == 'object' )
		{
			currentTeamID   = team.ID  ;
			currentTeamName = team.NAME;
		}
		this.state =
		{
			showTeamTree         : Credentials.showTeamTree,
			currentTeamID        ,
			currentTeamName      ,
			nTeamHierarchyCounter: SplendidCache.nTeamHierarchyCounter
		};
	}

	shouldComponentUpdate(nextProps: ITeamTreeProps, nextState: ITeamTreeState)
	{
		if ( nextState.showTeamTree != this.state.showTeamTree )
		{
			return true;
		}
		else if ( nextState.currentTeamID != this.state.currentTeamID || nextState.currentTeamName != this.state.currentTeamName )
		{
			return true;
		}
		else if ( nextState.nTeamHierarchyCounter != SplendidCache.nTeamHierarchyCounter )
		{
			let currentTeamID  : string = null;
			let currentTeamName: string = L10n.Term('Teams.LBL_TEAM_TREE_ROOT');
			let team = SplendidCache.GetSelectedTeamHierarchy();
			if ( team != null && typeof(team) == 'object' )
			{
				currentTeamID   = team.ID  ;
				currentTeamName = team.NAME;
			}
			this.setState(
			{
				currentTeamID        ,
				currentTeamName      ,
				nTeamHierarchyCounter: SplendidCache.nTeamHierarchyCounter
			});
			// 01/18/2020 Paul.  Instead of returning true, return false to prevent two render events. 
			return false;
		}
		return false;
	}

	private _onClickTeam = async (team) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onClickTeam', TEAMS);
		await SplendidCache.UpdateTeamHierarchy(team);
		let currentTeamID  : string = null;
		let currentTeamName: string = L10n.Term('Teams.LBL_TEAM_TREE_ROOT');
		if ( team != null )
		{
			currentTeamID   = team.ID  ;
			currentTeamName = team.NAME;
		}
		this.setState(
		{
			currentTeamID  ,
			currentTeamName,
		});
		this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
	}

	private toggleTeamTree = (e) =>
	{
		Credentials.showTeamTree = !Credentials.showTeamTree;
		// 01/12/2020 Paul.  Save the state. 
		localStorage.setItem('showTeamTree', Credentials.showTeamTree.toString());
		this.setState({ showTeamTree: Credentials.showTeamTree });
	}

	private renderTeamTree = (TEAMS) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.renderTeamTree', TEAMS);
		return TEAMS && TEAMS.map(team =>
		{
			const label = <a href='#' className='teamTreeItem lastViewLink' onClick={ (e) => { e.preventDefault(); this._onClickTeam(team); } }>{ team.NAME }</a>;
			if ( team.TEAMS == null )
			{
				return (
				<div className='tree-view_item teamTreeItem lastViewLink' style={ {paddingLeft: '22px', whiteSpace: 'nowrap'} }>
					{ label }
				</div>);
			}
			else
			{
				return (<TreeView nodeLabel={ label } key={ team.ID } defaultCollapsed={ false } itemClassName='teamTreeItem lastViewLink'>
					{ team.TEAMS
					? this.renderTeamTree(team.TEAMS)
					: null
					}
				</TreeView>);
			}
		});
	}
	
	public render()
	{
		const { currentTeamName } = this.state;
		// https://www.npmjs.com/package/react-treeview
		// https://github.com/chenglou/react-treeview
		let showTeamTree: boolean = Credentials.showTeamTree;
		let userTheme   : string  = SplendidCache.UserTheme;
		let themeURL    : string = Credentials.RemoteServer + 'App_Themes/' + userTheme + '/';
		let toggleWidth : string = '8px';
		// 04/24/2022 Paul.  Smae for Pacific theme. 
		if ( userTheme == 'Arctic' || userTheme == 'Pacific' )
		{
			toggleWidth = '24px';
		}
		SplendidCache.nTeamHierarchyCounter;
		// 08/08/2021 Paul.  height 100% is not working, but 100vh does work. 
		const rootTeam = <a href='#' className='teamTreeItem lastViewLink' onClick={ (e) => { e.preventDefault(); this._onClickTeam({ ID: '00000000-0000-0000-0000-000000000000', NAME: L10n.Term('Teams.LBL_TEAM_TREE_ROOT') }); } }>{ L10n.Term('Teams.LBL_TEAM_TREE_ROOT') }</a>;
		return (
			<table cellPadding='0' cellSpacing='0' style={ {height: '100vh', paddingTop: '10px', paddingLeft: '10px'} }>
				<tr>
					{ userTheme == 'Sugar2006'
					? <td style={ {width: toggleWidth, paddingTop: '6px', verticalAlign: 'top'} }>
						<img onClick={ this.toggleTeamTree} style={ {cursor: 'pointer', width: toggleWidth, height: '24px'} } src={ themeURL + 'images/' + (showTeamTree ? 'hide.gif' : 'show.gif') } />
					</td>
					: null
					}
					{ showTeamTree && Credentials.TEAM_TREE
					? <td className='lastViewPanel' style={ {paddingTop: '6px', verticalAlign: 'top'} }>
						<div>
							<span className='teamTreeItem lastViewLink'>{ L10n.Term('Teams.LBL_CURRENT') }</span>&nbsp;
							<span className='teamTreeItem lastViewLink' style={ {fontWeight: 'bold', whiteSpace: 'nowrap'} }>{ currentTeamName }</span>
						</div>
						<TreeView nodeLabel={ rootTeam } defaultCollapsed={ false } itemClassName='teamTreeItem lastViewLink'>
						{ Credentials.TEAM_TREE.map(team =>
							{
								const label = <a href='#' className='teamTreeItem lastViewLink' onClick={ (e) => { e.preventDefault(); this._onClickTeam(team); } }>{ team.NAME }</a>;
								return (<TreeView nodeLabel={ label } key={ team.ID } defaultCollapsed={ false } itemClassName='teamTreeItem lastViewLink'>
									{ team.TEAMS
									? this.renderTeamTree(team.TEAMS)
									: null
									}
								</TreeView>);
							})
						}
						</TreeView>
					</td>
					: null
					}
					{ userTheme != 'Sugar2006'
					? <td style={ {width: toggleWidth, paddingTop: '6px', verticalAlign: 'top'} }>
						<img onClick={ this.toggleTeamTree} style={ {cursor: 'pointer', width: toggleWidth, height: '24px'} } src={ themeURL + 'images/' + (showTeamTree ? 'hide.gif' : 'show.gif') } />
					</td>
					: null
					}
				</tr>
			</table>
		);
	}
}

export default withRouter(TeamTree);
