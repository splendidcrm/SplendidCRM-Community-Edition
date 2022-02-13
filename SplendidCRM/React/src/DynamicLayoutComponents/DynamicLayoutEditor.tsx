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
import { RouteComponentProps, withRouter }          from 'react-router-dom'              ;
import { observer }                                 from 'mobx-react'                    ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome';
import TreeView                                     from 'react-treeview'                ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'                ;
import L10n                                         from '../scripts/L10n'               ;
import Credentials                                  from '../scripts/Credentials'        ;
import SplendidCache                                from '../scripts/SplendidCache'      ;
import { Admin_GetReactState }                      from '../scripts/Application'        ;
import { AuthenticatedMethod, LoginRedirect }       from '../scripts/Login'              ;
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest'    ;
// 4. Components and Views. 
import DetailLayoutEditor                           from './DetailView/DetailLayoutEditor'                        ;
import EditLayoutEditor                             from './EditView/EditLayoutEditor'                            ;
import ListLayoutEditor                             from './ListView/ListLayoutEditor'                            ;
import DetailRelationshipLayoutEditor               from './DetailRelationshipView/DetailRelationshipLayoutEditor';
import EditRelationshipLayoutEditor                 from './EditRelationshipView/EditRelationshipLayoutEditor'    ;
import TerminologyLayoutEditor                      from './Terminology/TerminologyLayoutEditor'                  ;
import TerminologyListLayoutEditor                  from './TerminologyList/TerminologyListLayoutEditor'          ;

interface IDynamicLayoutEditorProps extends RouteComponentProps<any>
{
}

interface IDynamicLayoutEditorState
{
	layout          : any;
	layoutNodes     : any[];
	error?          : any;
}

@observer
class DynamicLayoutEditor extends React.Component<IDynamicLayoutEditorProps, IDynamicLayoutEditorState>
{
	private _isMounted = false;

	constructor(props: IDynamicLayoutEditorProps)
	{
		super(props);
		Credentials.SetViewMode('AdministrationView');
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor');
		this.state =
		{
			layout          : null,
			layoutNodes     : [],
		};
	}

	async componentDidMount()
	{
		this._isMounted = true;
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', status);
			if ( status == 1 )
			{
				// 10/27/2019 Paul.  In case of single page refresh, we need to make sure that the AdminMenu has been loaded. 
				if ( SplendidCache.AdminMenu == null )
				{
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount Admin_GetReactState');
					await Admin_GetReactState(this.constructor.name + '.componentDidMount');
				}
				if ( !Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(true);
				}
				document.title = L10n.Term('Administration.LBL_STUDIO_TITLE');
				// 04/26/2020 Paul.  Reset scroll every time we set the title. 
				window.scroll(0, 0);
				await this.load();
			}
			else
			{
				LoginRedirect(this.props.history, this.constructor.name + '.componentDidMount');
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.AppendEditViewFields', error);
			this.setState({ error });
		}
	}

	async componentDidUpdate(prevProps: IDynamicLayoutEditorProps)
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
	}

	private BuildAdminLayoutModuleNodes = (message) =>
	{
		let zNodes : any[]        = new Array();
		let oGlobal: any          = new Object();
		oGlobal.name              = L10n.Term('DynamicLayout.LBL_GLOBAL');
		oGlobal.open              = false;
		oGlobal.global            = true;
		oGlobal.chkDisabled       = true;
		oGlobal.children          = new Array();
		zNodes.push(oGlobal);
		let oModules: any         = new Object();
		oModules.name             = L10n.Term('DynamicLayout.LBL_USER_MODULES');
		oModules.open             = true;
		oModules.global           = false;
		oModules.chkDisabled      = true;
		oModules.children         = new Array();
		zNodes.push(oModules);
		let oAdminModules: any    = new Object();
		oAdminModules.name        = L10n.Term('DynamicLayout.LBL_ADMIN_MODULES');
		oAdminModules.open        = false;
		oAdminModules.global      = false;
		oAdminModules.chkDisabled = true;
		oAdminModules.children    = new Array();
		zNodes.push(oAdminModules);
		if ( message instanceof Array )
		{
			// 07/05/2016 Paul.  arrModules is a local variable. 
			let arrModules = message;
			for ( let i = 0; i < arrModules.length; i++ )
			{
				let module = arrModules[i];
				let oModuleNode: any   = new Object();
				oModuleNode.name       = module.DisplayName;
				oModuleNode.open       = false;
				oModuleNode.ModuleName = module.ModuleName;
				if ( Sql.ToBoolean(module.IsAdmin) )
					oAdminModules.children.push(oModuleNode);
				else if ( Sql.IsEmptyString(module.ModuleName) )
					oModuleNode = oGlobal;
				else
					oModules.children.push(oModuleNode);
				if ( module.DetailViews !== undefined && module.DetailViews instanceof Array && module.DetailViews.length > 0 )
				{
					if ( oModuleNode.children == null )
						oModuleNode.children = new Array();
					let oDetailView: any = new Object();
					oDetailView.name     = L10n.Term('DynamicLayout.LBL_DETAIL_VIEWS');
					oDetailView.children = new Array();
					oModuleNode.children.push(oDetailView);
					for ( let j = 0; j < module.DetailViews.length; j++ )
					{
						let view     : any = module.DetailViews[j];
						let oViewNode: any = new Object();
						oViewNode.name       = view.DisplayName ;
						oViewNode.ModuleName = module.ModuleName;
						oViewNode.ViewName   = view.ViewName    ;
						oViewNode.LayoutType = view.LayoutType  ;
						oDetailView.children.push(oViewNode);
					}
				}
				if ( module.EditViews !== undefined && module.EditViews instanceof Array && module.EditViews.length > 0 )
				{
					if ( oModuleNode.children == null )
						oModuleNode.children = new Array();
					let oEditView: any = new Object();
					oEditView.name     = L10n.Term('DynamicLayout.LBL_EDIT_VIEWS');
					oEditView.children = new Array();
					oModuleNode.children.push(oEditView);
					for ( let j = 0; j < module.EditViews.length; j++ )
					{
						let view     : any = module.EditViews[j];
						let oViewNode: any = new Object();
						oViewNode.name       = view.DisplayName ;
						oViewNode.ModuleName = module.ModuleName;
						oViewNode.ViewName   = view.ViewName    ;
						oViewNode.LayoutType = view.LayoutType  ;
						oEditView.children.push(oViewNode);
					}
				}
				if ( module.Search !== undefined && module.Search instanceof Array && module.Search.length > 0 )
				{
					if ( oModuleNode.children == null )
						oModuleNode.children = new Array();
					let oEditView: any = new Object();
					oEditView.name     = L10n.Term('DynamicLayout.LBL_SEARCH_EDIT_VIEWS');
					oEditView.children = new Array();
					oModuleNode.children.push(oEditView);
					for ( let j = 0; j < module.Search.length; j++ )
					{
						let view     : any= module.Search[j];
						let oViewNode: any = new Object();
						oViewNode.name       = view.DisplayName ;
						oViewNode.ModuleName = module.ModuleName;
						oViewNode.ViewName   = view.ViewName    ;
						oViewNode.LayoutType = view.LayoutType  ;
						oEditView.children.push(oViewNode);
					}
				}
				if ( module.ListViews !== undefined && module.ListViews instanceof Array && module.ListViews.length > 0 )
				{
					if ( oModuleNode.children == null )
						oModuleNode.children = new Array();
					let oListView: any = new Object();
					oListView.name     = L10n.Term('DynamicLayout.LBL_GRID_VIEWS');
					oListView.children = new Array();
					oModuleNode.children.push(oListView);
					for ( let j = 0; j < module.ListViews.length; j++ )
					{
						let view     : any = module.ListViews[j];
						let oViewNode: any = new Object();
						oViewNode.name       = view.DisplayName ;
						oViewNode.ModuleName = module.ModuleName;
						oViewNode.ViewName   = view.ViewName    ;
						oViewNode.LayoutType = view.LayoutType  ;
						oListView.children.push(oViewNode);
					}
				}
				if ( module.SubPanels !== undefined && module.SubPanels instanceof Array && module.SubPanels.length > 0 )
				{
					if ( oModuleNode.children == null )
						oModuleNode.children = new Array();
					let oListView: any = new Object();
					oListView.name     = L10n.Term('DynamicLayout.LBL_SUBPANEL_GRID_VIEWS');
					oListView.children = new Array();
					oModuleNode.children.push(oListView);
					for ( let j = 0; j < module.SubPanels.length; j++ )
					{
						let view     : any = module.SubPanels[j];
						let oViewNode: any = new Object();
						oViewNode.name       = view.DisplayName ;
						oViewNode.ModuleName = module.ModuleName;
						oViewNode.ViewName   = view.ViewName    ;
						oViewNode.LayoutType = view.LayoutType  ;
						oListView.children.push(oViewNode);
					}
				}
				if ( module.Relationships !== undefined && module.Relationships instanceof Array && module.Relationships.length > 0 )
				{
					if ( oModuleNode.children == null )
						oModuleNode.children = new Array();
					let oRelationshipView: any = new Object();
					oRelationshipView.name     = L10n.Term('DynamicLayout.LBL_SUBPANEL_RELATIONSHIPS');
					oRelationshipView.children = new Array();
					oModuleNode.children.push(oRelationshipView);
					for ( let j = 0; j < module.Relationships.length; j++ )
					{
						let view     : any = module.Relationships[j];
						let oViewNode: any = new Object();
						oViewNode.name       = view.DisplayName ;
						oViewNode.ModuleName = module.ModuleName;
						oViewNode.ViewName   = view.ViewName    ;
						oViewNode.LayoutType = view.LayoutType  ;
						oRelationshipView.children.push(oViewNode);
					}
				}
				if ( module.Terminology !== undefined && module.Terminology instanceof Array && module.Terminology.length > 0 )
				{
					if ( oModuleNode.children == null )
						oModuleNode.children = new Array();
					let oTerminologyView: any = new Object();
					oTerminologyView.name        = L10n.Term('DynamicLayout.LBL_TERMINOLOGY');
					oTerminologyView.terminology = true;
					oTerminologyView.children = new Array();
					oModuleNode.children.push(oTerminologyView);
					for ( var j = 0; j < module.Terminology.length; j++ )
					{
						let view     : any = module.Terminology[j];
						let oViewNode: any = new Object();
						oViewNode.name       = view.DisplayName ;
						oViewNode.ModuleName = module.ModuleName;
						oViewNode.ViewName   = view.ViewName    ;
						oViewNode.LayoutType = view.LayoutType  ;
						oTerminologyView.children.push(oViewNode);
					}
				}
				if ( module.TerminologyLists !== undefined && module.TerminologyLists instanceof Array && module.TerminologyLists.length > 0 )
				{
					if ( oModuleNode.children == null )
						oModuleNode.children = new Array();
					let oTerminologyView: any = new Object();
					oTerminologyView.name     = L10n.Term('DynamicLayout.LBL_TERMINOLOGY_LIST');
					oTerminologyView.children = new Array();
					oModuleNode.children.push(oTerminologyView);
					for ( var j = 0; j < module.Terminology.length; j++ )
					{
						let view     : any = module.Terminology[j];
						let oListViewNode: any = new Object();
						oListViewNode.name       = view.DisplayName ;
						oListViewNode.children   = new Array();
						oTerminologyView.children.push(oListViewNode);
						for ( var k = 0; k < module.TerminologyLists.length; k++ )
						{
							let list     : any = module.TerminologyLists[k];
							let oViewNode: any = new Object();
							oViewNode.name       = list.DisplayName ;
							oViewNode.ModuleName = view.ViewName    ;  // Language. 
							oViewNode.ViewName   = list.ViewName    ;  // List Name. 
							oViewNode.LayoutType = list.LayoutType  ;
							oListViewNode.children.push(oViewNode);
						}
					}
				}
			}
		}
		return zNodes;
	}

	private load = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load');
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.load');
			if ( status == 1 )
			{
				let res  = await CreateSplendidRequest('Administration/Rest.svc/GetAdminLayoutModules', 'GET');
				let json = await GetSplendidResult(res);
				if ( this._isMounted )
				{
					let layoutNodes: any = this.BuildAdminLayoutModuleNodes(json.d);
					this.setState({ layoutNodes });
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private _onClickLayout = async (layout) =>
	{
		this.setState({ layout });
	}

	private _onEditComplete = () =>
	{
		this.setState({ layout: null });
	}

	private LayoutEditor = (layout) =>
	{
		if ( layout )
		{
			if ( layout.LayoutType == 'DetailView' )
			{
				return (<DetailLayoutEditor LayoutType={ layout.LayoutType } ModuleName={ layout.ModuleName } ViewName={ layout.ViewName } onEditComplete={ this._onEditComplete } />);
			}
			else if ( layout.LayoutType == 'EditView' )
			{
				return (<EditLayoutEditor LayoutType={ layout.LayoutType } ModuleName={ layout.ModuleName } ViewName={ layout.ViewName } onEditComplete={ this._onEditComplete } />);
			}
			else if ( layout.LayoutType == 'ListView' )
			{
				return (<ListLayoutEditor LayoutType={ layout.LayoutType } ModuleName={ layout.ModuleName } ViewName={ layout.ViewName } onEditComplete={ this._onEditComplete } />);
			}
			else if ( layout.LayoutType == 'DetailViewRelationship' )
			{
				return (<DetailRelationshipLayoutEditor LayoutType={ layout.LayoutType } ModuleName={ layout.ModuleName } ViewName={ layout.ViewName } onEditComplete={ this._onEditComplete } />);
			}
			else if ( layout.LayoutType == 'EditViewRelationship' )
			{
				return (<EditRelationshipLayoutEditor LayoutType={ layout.LayoutType } ModuleName={ layout.ModuleName } ViewName={ layout.ViewName } onEditComplete={ this._onEditComplete } />);
			}
			else if ( layout.LayoutType == 'Terminology' )
			{
				return (<TerminologyLayoutEditor LayoutType={ layout.LayoutType } ModuleName={ layout.ModuleName } ViewName={ layout.ViewName } onEditComplete={ this._onEditComplete } />);
			}
			else if ( layout.LayoutType == 'TerminologyList' )
			{
				return (<TerminologyListLayoutEditor LayoutType={ layout.LayoutType } ModuleName={ layout.ModuleName } ViewName={ layout.ViewName } onEditComplete={ this._onEditComplete } />);
			}
		}
		return (
		<React.Fragment>
			<div style={ {flex: '2 2 0', flexDirection: 'column', margin: '0 .5em', border: '1px solid grey', position: 'relative'} }>
				<div style={ {height: '100%', overflowY: 'scroll'} }>
					<h2 style={{ padding: '.25em' }}>{ L10n.Term('DynamicLayout.LBL_TOOLBOX') }</h2>
				</div>
			</div>
			<div style={{ flexDirection: 'column', flex: '8 8 0', margin: '0 .5em', border: '1px solid grey' }}>
				<div style={ {height: '100%', overflowY: 'scroll'} }>
					<h2 style={{ padding: '.25em' }}>{ L10n.Term('DynamicLayout.LBL_LAYOUT') }</h2>
				</div>
			</div>
			<div style={{ flex: '2 2 0', border: '1px solid grey', margin: '0 .5em' }}>
				<div style={ {height: '100%', overflowY: 'scroll'} }>
					<h2 style={{ padding: '.25em' }}>{ L10n.Term('DynamicLayout.LBL_PROPERTIES') }</h2>
				</div>
			</div>
		</React.Fragment>
		);
	}

	public render()
	{
		const { layout, layoutNodes, error } = this.state;
		if ( SplendidCache.IsInitialized )
		{
			// https://www.npmjs.com/package/react-treeview
			// https://github.com/chenglou/react-treeview
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', layout);
			let windowHeight = (window.innerHeight - 100).toString() + 'px';
			return (
			<div>
				<h2>{ L10n.Term('Administration.LBL_MANAGE_LAYOUT') }</h2>
				<div style={{ display: 'flex', height: windowHeight }}>
					<div style={{ flex: '2 0 180px', flexDirection: 'column', lineHeight: '16px', margin: '0 .5em', border: '1px solid grey', position: 'relative' }}>
						<div style={ {height: '100%', overflowY: 'scroll', overflowX: 'hidden'} }>
							{ layoutNodes.map((node, index) => (
								<TreeView nodeLabel={ node.name } defaultCollapsed={ !node.open } itemClassName=''>
									{ node.children.map((module, index) => (
										<TreeView nodeLabel={ module.name } defaultCollapsed={ !module.open } itemClassName=''>
											{ node.global && module.terminology
											? module.children.map((type, index) => (
												<div style={ {lineHeight: '16px', whiteSpace: 'nowrap'} }>
													<FontAwesomeIcon icon={ {prefix: 'far', iconName: 'file'} } />
													<a
														href='#'
														className=''
														style={ {textDecoration: 'none', paddingLeft: '2px'} }
														onClick={ (e) => { e.preventDefault(); this._onClickLayout(type); } }
													>
														{ type.name }
													</a>
												</div>
											))
											: module.children.map((type, index) => (
												<TreeView nodeLabel={ type.name } defaultCollapsed={ !type.open } itemClassName=''>
													{ type.children.map((layout, index) => (
														<div style={ {lineHeight: '16px', whiteSpace: 'nowrap'} }>
															<FontAwesomeIcon icon={ {prefix: 'far', iconName: 'file'} } />
															<a
																href='#'
																className=''
																style={ {textDecoration: 'none', paddingLeft: '2px'} }
																onClick={ (e) => { e.preventDefault(); this._onClickLayout(layout); } }
															>
																{ layout.name }
															</a>
														</div>
														))
													}
												</TreeView>
											))
											}
										</TreeView>
									))}
								</TreeView>
							))}
						</div>
					</div>
					{ this.LayoutEditor(layout) }
				</div >
			</div>
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

export default withRouter(DynamicLayoutEditor);
