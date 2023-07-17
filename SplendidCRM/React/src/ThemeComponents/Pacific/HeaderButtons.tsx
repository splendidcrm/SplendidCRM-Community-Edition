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
import { FontAwesomeIcon }                   from '@fortawesome/react-fontawesome' ;
// 2. Store and Types. 
import MODULE                                from '../../types/MODULE'             ;
// 3. Scripts. 
import L10n                                  from '../../scripts/L10n'             ;
import Sql                                   from '../../scripts/Sql'              ;
import Security                              from '../../scripts/Security'         ;
import Credentials                           from '../../scripts/Credentials'      ;
import SplendidCache                         from '../../scripts/SplendidCache'    ;
import { Crm_Config, Crm_Modules }           from '../../scripts/Crm'              ;
import { isMobileDevice, isMobileLandscape, screenWidth, screenHeight } from '../../scripts/utility'          ;
import { AddToFavorites, RemoveFromFavorites, AddSubscription, RemoveSubscription } from '../../scripts/ModuleUpdate';
// 4. Components and Views. 
import DynamicButtons                        from '../../components/DynamicButtons';
import ProcessButtons                        from '../../components/ProcessButtons';
import { IHeaderButtonsProps, HeaderButtons} from '../../types/HeaderButtons'      ;
import HelpView                              from '../../views/HelpView'           ;

export default class PacificHeaderButtons extends HeaderButtons
{
	private helpView = React.createRef<HelpView>();

	constructor(props: IHeaderButtonsProps)
	{
		super(props);
		let nACLACCESS_Help: number = SplendidCache.GetUserAccess("Help", 'edit');
		let helpText       : string = (nACLACCESS_Help >= 0 && Crm_Config.ToBoolean('enable_help_wiki') ? L10n.Term('.LNK_HELP_WIKI') : L10n.Term('.LNK_HELP') );
		let streamEnabled  : boolean = Crm_Modules.StreamEnabled(props.MODULE_NAME);
		let archiveView    : boolean = false;

		if ( props.location != undefined && props.location.pathname.indexOf('/ArchiveView') >= 0 )
		{
			archiveView = true;
		}
		this.state =
		{
			helpText     ,
			archiveView  ,
			streamEnabled,
			headerError  : null,
			localKey     : '',
			helpOpen     : false,
		};
	}

	private _onClickModule = (e) =>
	{
		const { MODULE_NAME, SUB_TITLE, ID } = this.props;
		// 12/05/2021 Paul.  User should be able to open a new table by right-click on item name.  Change from span to anchor. 
		e.preventDefault();
		let admin = '';
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onClickModule');
		// 09/04/2022 Paul.  Module may be disabled, so it will not exist. 
		if ( module && module.IS_ADMIN )
		{
			admin = '/Administration';
		}
		let sModuleUrl = `/Reset${admin}/${MODULE_NAME}/List`;
		this.props.history.push(sModuleUrl);
		return false;
	}

	private _onClickItem = (e) =>
	{
		const { MODULE_NAME, SUB_TITLE, ID } = this.props;
		// 12/05/2021 Paul.  User should be able to open a new table by right-click on item name.  Change from span to anchor. 
		e.preventDefault();
		let admin = '';
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '._onClickItem');
		// 09/04/2022 Paul.  Module may be disabled, so it will not exist. 
		if ( module && module.IS_ADMIN )
		{
			admin = '/Administration';
		}
		let sModuleUrl = `/Reset${admin}/${MODULE_NAME}/View/${ID}`;
		this.props.history.push(sModuleUrl);
		return false;
	}

	private _onClickHelp = async (e) =>
	{
		e.preventDefault();
		await this.helpView.current.loadData();
		this.setState({ helpOpen: true });
		return false;
	}

	private _onHelpClose = () =>
	{
		this.setState({ helpOpen: false });
	}

	private _onChangeFavorites = async (e) =>
	{
		const { MODULE_NAME, ID } = this.props;
		let { row } = this.props;
		e.preventDefault();
		try
	{
			if ( Sql.IsEmptyGuid(row['FAVORITE_RECORD_ID']) )
			{
				// Include/javascript/Utilities.asmx/AddToFavorites
				await AddToFavorites(MODULE_NAME, ID);
				row['FAVORITE_RECORD_ID'] = ID;
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.setState( {localKey: this.state.localKey + '*'} );
			}
			else
			{
				await RemoveFromFavorites(MODULE_NAME, ID);
				row['FAVORITE_RECORD_ID'] = null;
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.setState({ headerError: null, localKey: this.state.localKey + '*' });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChangeFavorites', error);
			this.setState({ headerError: error, localKey: this.state.localKey + '*' });
		}
		return false;
	}

	private _onChangeFollowing = async (e) =>
	{
		const { MODULE_NAME, ID } = this.props;
		let { row } = this.props;
		e.preventDefault();
		try
		{
			if ( Sql.IsEmptyGuid(row['SUBSCRIPTION_PARENT_ID']) )
			{
				// Include/javascript/Utilities.asmx/AddSubscription
				await AddSubscription(MODULE_NAME, ID);
				row['SUBSCRIPTION_PARENT_ID'] = ID;
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.setState( {localKey: this.state.localKey + '*'} );
			}
			else
			{
				await RemoveSubscription(MODULE_NAME, ID);
				row['SUBSCRIPTION_PARENT_ID'] = null;
				// 09/22/2019 Paul.  The tableKey is so that we can force the table to refresh after favorite or subscription change. 
				this.setState({ headerError: null, localKey: this.state.localKey + '*' });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChangeFollowing', error);
			this.setState({ headerError: error, localKey: this.state.localKey + '*' });
		}
		return false;
	}

	public render()
	{
		const { MODULE_NAME, MODULE_TITLE, SUB_TITLE, ID, showRequired, enableFavorites , enableHelp, helpName, error } = this.props;
		const { ButtonStyle, FrameStyle, ContentStyle, VIEW_NAME, LINK_NAME, row, Page_Command, onLayoutLoaded, onButtonLink, showButtons, showProcess, hideTitle } = this.props;
		const { helpText, archiveView, streamEnabled, localKey, headerError, helpOpen } = this.state;
		
		let sMODULE_TITLE: string = null;
		if ( MODULE_TITLE == '.moduleList.Home' )
		{
			sMODULE_TITLE = L10n.Term('.moduleList.' + MODULE_NAME);
		}
		else
		{
			sMODULE_TITLE = !Sql.IsEmptyString(MODULE_TITLE) ? L10n.Term(MODULE_TITLE) : L10n.Term('.moduleList.' + MODULE_NAME);
		}
		let sTheme       : string = SplendidCache.UserTheme;
		let themeURL     : string = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/';
		let sError       : string = null;
		if ( error !== undefined && error != null )
		{
			if ( error.message !== undefined )
			{
				sError = error.message;
			}
			else if ( typeof(error) == 'string' )
			{
				sError = error;
			}
			else if ( typeof(error) == 'object' )
			{
				sError = JSON.stringify(error);
			}
		}
		else if ( headerError !== undefined && headerError != null )
		{
			if ( headerError.message !== undefined )
			{
				sError = headerError.message;
			}
			else if ( typeof(headerError) == 'string' )
			{
				sError = headerError;
			}
			else if ( typeof(headerError) == 'object' )
			{
				sError = JSON.stringify(headerError);
			}
		}
		let bIsMobile: boolean = isMobileDevice();
		if ( isMobileLandscape() )
		{
			bIsMobile = false;
		}
		// 04/28/2019 Paul.  Can't use react-bootstrap Breadcrumb as it will reload the app is is therefore slow. 
		// 07/09/2019 Paul.  Use span instead of a tag to prevent navigation. 
		// 04/19/2021 Paul.  Manually calculate responsive features. 
		let bResponsive : boolean = false;
		let width : number = screenWidth();
		let height: number = screenHeight();
		if ( width < 992 )
			bResponsive = true;
		// 12/05/2021 Paul.  User should be able to open a new table by right-click on item name.  Change from span to anchor. 
		let admin = '';
		let module:MODULE = SplendidCache.Module(MODULE_NAME, this.constructor.name + '.render');
		// 09/04/2022 Paul.  Module may be disabled, so it will not exist. 
		if ( module && module.IS_ADMIN )
		{
			admin = 'Administration/';
		}
		// 07/01/2023 Paul.  ASP.NET Core will not have /React in the base. 
		let sModuleUrl = Credentials.RemoteServer + Credentials.ReactBase + `${admin}${MODULE_NAME}/List`;
		let sItemUrl   = Credentials.RemoteServer + Credentials.ReactBase + `${admin}${MODULE_NAME}/View/${ID}`;
		return (
			<React.Fragment>
				<HelpView
					isOpen={ helpOpen }
					callback={ this._onHelpClose }
					MODULE_NAME={ MODULE_NAME }
					helpName={ helpName }
					ref={ this.helpView }
				/>
				<div id={ 'divModuleHeader' + MODULE_NAME } className='moduleTitle' style={ {width: '100%', display: 'flex', flexDirection: 'row', flexWrap: 'nowrap'} }>
					<div id={ 'divModuleHeader' + MODULE_NAME + '_Title' } style={ {width: '50%'} }>
						<h2>
						{ !hideTitle
						? <a href={ sModuleUrl } onClick={ this._onClickModule }>{ sMODULE_TITLE }</a>
						: null
						}
						</h2>
						{ !Sql.IsEmptyString(ID)
						? <h2 className='ModuleHeaderTitle'>
							{ Security.IS_ADMIN() || MODULE_NAME != 'Users'
							? <a href={ sItemUrl } onClick={ this._onClickItem }>
								{ SUB_TITLE }
							</a>
							: <span>{ SUB_TITLE }</span>
							}
							{ !bIsMobile && enableFavorites && !archiveView && !Crm_Config.ToBoolean('disable_favorites')
							? Sql.IsEmptyGuid(row['FAVORITE_RECORD_ID'])
							? <a key={ localKey + '_Add' } href='#' className='utilsLink' onClick={ this._onChangeFavorites }>
								<FontAwesomeIcon icon={ { prefix: 'far', iconName: 'star' } } size='lg' title={ L10n.Term('.LBL_ADD_TO_FAVORITES') } />
							</a>
							: <a key={ localKey + '_Remove' } href='#' className='utilsLink' onClick={ this._onChangeFavorites }>
								<FontAwesomeIcon icon={ { prefix: 'fas', iconName: 'star' } } size='lg' title={ L10n.Term('.LBL_REMOVE_FROM_FAVORITES') } />
							</a>
							: null
							}
							{ !bIsMobile && streamEnabled && enableFavorites && !archiveView && !Crm_Config.ToBoolean('disable_following') && Crm_Config.ToBoolean('enable_activity_streams')
							? Sql.IsEmptyGuid(row['SUBSCRIPTION_PARENT_ID'])
							? <a key={ localKey + '_Follow' } href='#' className='utilsLink' onClick={ this._onChangeFollowing }>
								<FontAwesomeIcon icon={ { prefix: 'far', iconName: 'arrow-alt-circle-right' } } size='lg' title={ L10n.Term('.LBL_FOLLOW') } />
							</a>
							: <a key={ localKey + '_Following' } href='#' className='utilsLink' onClick={ this._onChangeFollowing }>
								<FontAwesomeIcon icon={ { prefix: 'fas', iconName: 'arrow-alt-circle-right' } } size='lg' title={ L10n.Term('.LBL_FOLLOWING') } />
							</a>
							: null
							}
						</h2>
						: null
						}
						{ !Sql.IsEmptyString(sError)
						? <div id={ 'divModuleHeader' + MODULE_NAME + '_Errors' } className='error'>{ sError }</div>
						: null
						}
					</div>
					<div id={ 'divModuleHeader' + MODULE_NAME + '_Buttons' } style={ {width: '50%', paddingTop: 3, paddingLeft: 5, display: 'flex', flexDirection: 'row', justifyContent: 'right'} }>
						<div style={ {display: 'flex', flexDirection: 'row', flexWrap: 'nowrap'} }>
							{ sTheme == 'Pacific' && VIEW_NAME != null && VIEW_NAME.indexOf('.ListView') >= 0
							? <div style={ {verticalAlign: 'bottom'} }>
								<button className='SearchFilterButton' onClick={ (e) => Page_Command('toggleSearchView', null) }>
									<FontAwesomeIcon icon='filter' size='lg' />
									<span>{ L10n.Term('.LNK_SEARCH_FILTER') }</span>
								</button>
							</div>
							: null
							}
							<div>
							{ showButtons && !!showProcess && row['PENDING_PROCESS_ID']
							? <ProcessButtons MODULE_NAME={ MODULE_NAME } ID={ ID } PENDING_PROCESS_ID={ row['PENDING_PROCESS_ID'] } />
							: showButtons
							? <DynamicButtons
								ButtonStyle={ ButtonStyle }
								FrameStyle={ FrameStyle }
								ContentStyle={ ContentStyle }
								VIEW_NAME={ VIEW_NAME }
								row={ row }
								Page_Command={ Page_Command }
								onLayoutLoaded={ onLayoutLoaded }
								onButtonLink={ onButtonLink }
								history={ this.props.history }
								location={ this.props.location }
								match={ this.props.match }
								ref={ this.dynamicButtons }
								/>
							: null
							}
							{ showButtons && !Sql.IsEmptyString(LINK_NAME)
							? <DynamicButtons
								ButtonStyle='EditHeader'
								FrameStyle={ FrameStyle }
								ContentStyle={ ContentStyle }
								VIEW_NAME={ LINK_NAME }
								row={ row }
								Page_Command={ Page_Command }
								history={ this.props.history }
								location={ this.props.location }
								match={ this.props.match }
								ref={ this.dynamicLinkButtons }
								/>
							: null
							}
							</div>
						</div>
					</div>
				</div>
			</React.Fragment>
		);
	}
}

// 12/05/2019 Paul.  We don't want to use withRouter() as it makes it difficult to get a reference. 

