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
import { RouteComponentProps, withRouter }    from '../Router5'              ;
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome';
import { observer }                           from 'mobx-react'                    ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'                ;
import Credentials                            from '../scripts/Credentials'        ;
import SplendidCache                          from '../scripts/SplendidCache'      ;
import { DynamicLayout_Module }               from '../scripts/DynamicLayout'      ;
import { AuthenticatedMethod, LoginRedirect } from '../scripts/Login'              ;
import { StartsWith }                         from '../scripts/utility'            ;
// 4. Components and Views. 
import ErrorComponent                         from '../components/ErrorComponent'  ;
import EditView                               from './EditView'                    ;

// 08/03/2019 Paul.  The LAYOUT_NAME field must be included because it is required in the EditView. 
interface IDynamicEditViewProps extends RouteComponentProps<any>
{
	MODULE_NAME        : string;
	ID?                : string;
	LAYOUT_NAME?       : string;
	// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times. 
	CONTROL_VIEW_NAME? : string;
	callback?          : any;
	rowDefaultSearch?  : any;
	onLayoutLoaded?    : any;
	onSubmit?          : any;
	isSearchView?      : boolean;
	isUpdatePanel?     : boolean;
	isQuickCreate?     : boolean;
	DuplicateID?       : string;
	ConvertModule?     : string;
	ConvertID?         : string;
	// 01/22/2021 Paul.  Pass the layout name to the popup so that we know the source. 
	fromLayoutName?    : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data) => void;
}

interface IDynamicEditViewState
{
	customView?      : any;
	error?           : any;
}

@observer
export class DynamicEditView extends React.Component<IDynamicEditViewProps, IDynamicEditViewState>
{
	private _isMounted = false;
	private editView   = React.createRef<EditView>();

	public get data (): any
	{
		return this.editView.current.data;
	}

	public validate(): boolean
	{
		return this.editView.current.validate();
	}

	public clear(): void
	{
		return this.editView.current.clear();
	}

	constructor(props: IDynamicEditViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', this.props);
		// 01/26/2021 Paul.  Now that the search view can be customized, we need to make sure it does not set the mode. 
		if ( !props.isSearchView && !props.isUpdatePanel && !props.isQuickCreate )
		{
			Credentials.SetViewMode('EditView');
		}
		this.state = {};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount ' + this.props.MODULE_NAME + ' ' + this.props.LAYOUT_NAME + ' ' + this.props.ID, this.props.location.pathname + this.props.location.search);
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				// 07/05/2020 Paul.  We need to make sure that the Users module is treated as an admin module. 
				let module = SplendidCache.Module(this.props.MODULE_NAME, 'DynamicEditView.componentDidMount');
				if ( module != null )
				{
					if ( module.IS_ADMIN )
					{
						// 01/23/2021 Paul.  Don't let dynamic search panel redirect. This is an issue now that we allow custom search panels. 
						// 02/08/2021 Paul.  LAYOUT_NAME is not always defined. 
						if ( !this.props.LAYOUT_NAME || this.props.LAYOUT_NAME.indexOf('.Search') < 0 )
						{
							// 01/23/2021 Paul.  Prevent /Administration/Administration. 
							if ( this.props.location.pathname.indexOf('/Administration') < 0 )
							{
								this.props.history.push('/Reload/Administration' + this.props.location.pathname + this.props.location.search);
								return;
							}
						}
					}
				}
				
				let sLAYOUT_NAME = this.props.LAYOUT_NAME;
				if ( Sql.IsEmptyString(sLAYOUT_NAME) )
				{
					sLAYOUT_NAME = 'EditView';
				}
				// 08/11/2020 Paul.  Quick Create will pass the full layout name, so we need to remove the module from the layout name. 
				// 01/22/2021 Paul.  Search views will start with the module name, such as Leads.SearchPopup. 
				else if ( StartsWith(sLAYOUT_NAME, this.props.MODULE_NAME + '.') )
				{
					sLAYOUT_NAME = sLAYOUT_NAME.substring(this.props.MODULE_NAME.length + 1);
				}
				let customView = await DynamicLayout_Module(this.props.MODULE_NAME, 'EditViews', sLAYOUT_NAME);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount ' + (customView ? 'custom' : 'default') + ' view ' + this.props.MODULE_NAME + '.' + sLAYOUT_NAME);
				// 05/26/2019 Paul.  The component may be unmounted by the time the custom view is generated. 
				if ( this._isMounted )
				{
					this.setState({ customView });
				}
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

	componentDidUpdate(prevProps: IDynamicEditViewProps)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate', this.props, prevProps);
		// 01/19/2021 Paul.  A user may click the browser back button from one detail view to another.  Detect and reset so that the correct custom view is loaded. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate pathname changed', this.props.location.pathname, prevProps.location.pathname);
			// 01/23/2021 Paul.  Don't let dynamic search panel redirect. This is an issue now that we allow custom search panels. 
			// 02/08/2021 Paul.  LAYOUT_NAME is not always defined. 
			if ( !this.props.LAYOUT_NAME || this.props.LAYOUT_NAME.indexOf('.Search') < 0 )
			{
				this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
			}
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	public render()
	{
		const { customView, error } = this.state;
		// 06/27/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		if ( error )
		{
			return <ErrorComponent error={error} />;
		}
		else if ( customView === undefined )
		{
			return (
			<div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
				<FontAwesomeIcon icon="spinner" spin={ true } size="5x" />
			</div>);
		}
		else if ( SplendidCache.IsInitialized && customView )
		{
			return React.createElement(customView, { ...this.props, ref: this.editView });
		}
		else if ( SplendidCache.IsInitialized && Credentials.bIsAuthenticated )
		{
			return <EditView {...this.props} ref={ this.editView } />;
		}
		else
		{
			return null;
		}
	}
}

// 08/11/2020 Paul.  We don't want to use withRouter() as it makes it difficult to get a reference. 
// 02/02/2024 Paul.  We have no choice.  We must use withRouter. 
export default withRouter(DynamicEditView);
