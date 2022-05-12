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
import posed from 'react-pose';
import { RouteComponentProps, withRouter }    from 'react-router-dom'                 ;
import { observer }                           from 'mobx-react'                       ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome'   ;
import { Appear }                             from 'react-lifecycle-appear'           ;
// 2. Store and Types. 
import { SubPanelHeaderButtons }              from '../types/SubPanelHeaderButtons'   ;
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'                   ;
import L10n                                   from '../scripts/L10n'                  ;
import Credentials                            from '../scripts/Credentials'           ;
import SplendidCache                          from '../scripts/SplendidCache'         ;
import { EndsWith }                           from '../scripts/utility'               ;
import { jsonReactState }                     from '../scripts/Application'           ;
import { InsertModuleStreamPost }             from '../scripts/ModuleUpdate'          ;
import { Crm_Config, Crm_Modules }            from '../scripts/Crm'                   ;
import { AuthenticatedMethod, LoginRedirect } from '../scripts/Login'                 ;
// 4. Components and Views. 
import ErrorComponent                         from '../components/ErrorComponent'     ;
import SplendidStream                         from '../components/SplendidStream'     ;
import DynamicButtons                         from '../components/DynamicButtons'     ;
import SearchView                             from '../views/SearchView'              ;
import EditView                               from '../views/EditView'                ;
import SubPanelButtonsFactory                 from '../ThemeComponents/SubPanelButtonsFactory';

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

interface ISubPanelStreamViewProps extends RouteComponentProps<any>
{
	MODULE_NAME           : string;
	ID                    : string;
	row                   : any;
	CONTROL_VIEW_NAME     : string;
	callback?             : Function;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data) => void;
	// 03/30/2022 Paul.  Pacific theme needs collapse notification. 
	onComponentCollapse?: (CONTROL_VIEW_NAME: string, open: boolean) => void;
}

interface ISubPanelStreamViewState
{
	showCancel            : boolean;
	showTopButtons        : boolean;
	showBottomButtons     : boolean;
	showSearch            : boolean;
	showInlineEdit        : boolean;
	item?                 : any;
	dependents?           : Record<string, Array<any>>;
	error?                : any;
	open                  : boolean;
	subPanelVisible       : boolean;
}

@observer
class SubPanelStreamView extends React.Component<ISubPanelStreamViewProps, ISubPanelStreamViewState>
{
	private _isMounted = false;

	private searchView           = React.createRef<SearchView>();
	private splendidStream       = React.createRef<SplendidStream>();
	private dynamicButtonsTop    = React.createRef<DynamicButtons>();
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();
	private editView             = React.createRef<EditView>();
	private headerButtons        = React.createRef<SubPanelHeaderButtons>();

	constructor(props: ISubPanelStreamViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props.MODULE_NAME);
		// 11/10/2020 Paul.  A customer wants to be able to have subpanels default to open. 
		let rawOpen        : string  = localStorage.getItem(props.CONTROL_VIEW_NAME);
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		let open           : boolean = (rawOpen == 'true' || this.props.isPrecompile);
		if ( rawOpen == null && Crm_Config.ToBoolean('default_subpanel_open') )
		{
			open = true;
		}
		this.state =
		{
			showCancel       : true,
			showTopButtons   : true,
			showBottomButtons: true,
			showSearch       : false,
			showInlineEdit   : false,
			item             : {},
			dependents       : {},
			error            : null,
			open             ,
			subPanelVisible  : Sql.ToBoolean(props.isPrecompile),  // 08/31/2021 Paul.  Must show sub panel during precompile to allow it to continue. 
		};
	}

	async componentDidMount()
	{
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
				// 08/22/2019 Paul.  This setState call seems to be critical to the loading of the grid. 
				this.setState({ error: null });
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

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	private _onComponentComplete = (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data): void => 
	{
		const { CONTROL_VIEW_NAME } = this.props;
		const { error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + LAYOUT_NAME, data);
		if ( this.props.onComponentComplete )
		{
			if ( error == null )
			{
				this.props.onComponentComplete(MODULE_NAME, RELATED_MODULE, CONTROL_VIEW_NAME, data);
			}
		}
	}

	// 09/26/2020 Paul.  The SearchView needs to be able to specify a sort criteria. 
	private _onSearchViewCallback = (sFILTER: string, row: any, oSORT?: any) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSearchViewCallback');
		// 07/13/2019 Paul.  Make Search public so that it can be called from a refrence. 
		if ( this.splendidStream.current != null )
		{
			this.splendidStream.current.Search(sFILTER, row);
		}
	}

	private _onGridLayoutLoaded = () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGridLayoutLoaded');
		// 05/08/2019 Paul.  Once we have the Search callback, we can tell the SearchView to submit and it will get to the GridView. 
		// 07/13/2019 Paul.  Call SubmitSearch directly. 
		if ( this.searchView.current != null )
		{
			this.searchView.current.SubmitSearch();
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { showSearch } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		try
		{
			if ( this._isMounted )
			{
				if ( sCommandName == 'Create' || EndsWith(sCommandName, '.Create') )
				{
					this.setState({ showSearch: false, showInlineEdit: true });
				}
				else if ( sCommandName == 'Search' || EndsWith(sCommandName, '.Search') )
				{
					this.setState({ showSearch: !showSearch, showInlineEdit: false });
				}
				else if ( sCommandName == 'NewRecord' )
				{
					await this.Save();
				}
				else if ( sCommandName == 'NewRecord.Cancel' )
				{
					this.setState({ showInlineEdit: false });
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}

	private Save = async () =>
	{
		const { MODULE_NAME, ID } = this.props;
		try
		{
			if ( this.editView.current != null && this.editView.current.validate() )
			{
				let row: any = this.editView.current.data;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Save ' + MODULE_NAME + ' ' + ID);
				try
				{
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
					// 03/17/2020 Paul.  React Client needs the ability to create a Stream Post. 
					await InsertModuleStreamPost(MODULE_NAME, row, ID);
					if ( this._isMounted )
					{
						// 07/18/2019 Paul.  We also need to clear the input fields. 
						if ( this.editView.current != null )
						{
							this.editView.current.clear();
						}
						if ( this.splendidStream.current != null )
						{
							this.splendidStream.current.Search(null, null);
						}
						// 03/17/2020 Paul.  Set the state after clearing the form, otherwise this.editView.current will be null. 
						// 03/17/2020 Paul.  Clear the local item as well. 
						this.setState({ showInlineEdit: false, item: {} });
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

	// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink. 
	private _onHyperLinkCallback = (MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any) =>
	{
		const { history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback: ' + MODULE_NAME, ID, URL);
		if ( !Sql.IsEmptyString(URL) )
		{
			history.push(URL);
		}
		else
		{
			history.push(`/Reset/${MODULE_NAME}/View/${ID}`);
		}
	}

	private onToggleCollapse = (open) =>
	{
		const { CONTROL_VIEW_NAME, onComponentCollapse } = this.props;
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
			// 03/30/2022 Paul.  Pacific theme needs collapse notification. 
			if ( onComponentCollapse )
			{
				onComponentCollapse(CONTROL_VIEW_NAME, open);
			}
		});
	}

	public render()
	{
		const { MODULE_NAME, ID, row, CONTROL_VIEW_NAME } = this.props;
		const { showCancel, showTopButtons, showBottomButtons, showSearch, showInlineEdit, item, error, open, subPanelVisible } = this.state;
		let sNewRecordButtons: string = "NewRecord." + (showCancel ? "WithCancel" : "SaveOnly");
		let cssSearch = { display: (showSearch ? 'inline' : 'none') };
		if ( SplendidCache.IsInitialized  )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = SubPanelButtonsFactory(SplendidCache.UserTheme);
			let MODULE_TITLE     : string = L10n.Term('.LBL_ACTIVITY_STREAM');
			// 07/30/2021 Paul.  Load when the panel appears. 
			return (
				<React.Fragment>
					<Appear onAppearOnce={ (ioe) => this.setState({ subPanelVisible: true }) }>
						{ headerButtons
						? React.createElement(headerButtons, { MODULE_NAME: 'ActivityStream', ID: null, MODULE_TITLE, CONTROL_VIEW_NAME, error, ButtonStyle: 'ListHeader', VIEW_NAME: 'ActivityStream.Subpanel', row: item, Page_Command: this.Page_Command, showButtons: !showInlineEdit, onToggle: this.onToggleCollapse, isPrecompile: this.props.isPrecompile, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
						: null
						}
					</Appear>
					<Content pose={ open ? 'open' : 'closed' } style={ {overflow: (open ? 'visible' : 'hidden')} }>
						{ open && subPanelVisible
						? <React.Fragment>
							<div style={ cssSearch }>
								<div className="card" style={{marginBottom: '0.5rem'}}>
									<div className="card-body">
										<SearchView
											key={ 'ActivityStream.SearchBasic' }
											EDIT_NAME={ 'ActivityStream.SearchBasic' }
											AutoSaveSearch={ false }
											ShowSearchViews={ false }
											cbSearch={ this._onSearchViewCallback }
											history={ this.props.history }
											location={ this.props.location }
											match={ this.props.match }
											ref={ this.searchView }
										/>
									</div>
								</div> 
							</div>
							{ showInlineEdit
							? <div>
								{ showTopButtons
								? <div>
									<DynamicButtons
										ButtonStyle="EditHeader"
										VIEW_NAME={ sNewRecordButtons }
										row={ row }
										Page_Command={ this.Page_Command }
										history={ this.props.history }
										location={ this.props.location }
										match={ this.props.match }
										ref={ this.dynamicButtonsTop }
									/>
									<ErrorComponent error={error} />
								</div>
								: null
								}
								<EditView
									key={ 'ActivityStream.NewRecord' }
									MODULE_NAME="ActivityStream"
									LAYOUT_NAME={ 'ActivityStream.NewRecord' }
									rowDefaultSearch={ item }
									callback={ this.editViewCallback }
									history={ this.props.history }
									location={ this.props.location }
									match={ this.props.match }
									ref={ this.editView }
								/>
								{ showBottomButtons
								? <DynamicButtons
									ButtonStyle="EditHeader"
									VIEW_NAME={ sNewRecordButtons }
									row={ row }
									Page_Command={ this.Page_Command }
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
							<SplendidStream
								onLayoutLoaded={ this._onGridLayoutLoaded }
								MODULE_NAME={ MODULE_NAME }
								ID={ ID }
								hyperLinkCallback={ this._onHyperLinkCallback }
								isPrecompile={ this.props.isPrecompile }
								onComponentComplete={ this._onComponentComplete } 
								scrollable
								history={ this.props.history }
								location={ this.props.location }
								match={ this.props.match }
								ref={ this.splendidStream }
							/>
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

export default withRouter(SubPanelStreamView);
