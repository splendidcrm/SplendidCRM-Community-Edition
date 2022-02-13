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
import * as XMLParser                                 from 'fast-xml-parser'                      ;
import { RouteComponentProps, withRouter }            from 'react-router-dom'                     ;
// 2. Store and Types. 
import { DetailComponent }                            from '../types/DetailComponent'             ;
import ACL_ACCESS                                     from '../types/ACL_ACCESS'                  ;
// 3. Scripts. 
import Sql                                            from '../scripts/Sql'                       ;
import L10n                                           from '../scripts/L10n'                      ;
import Security                                       from '../scripts/Security'                  ;
import Credentials                                    from '../scripts/Credentials'               ;
import SplendidCache                                  from '../scripts/SplendidCache'             ;
import SplendidDynamic_DetailView                     from '../scripts/SplendidDynamic_DetailView';
import { Crm_Config, Crm_Modules }                    from '../scripts/Crm'                       ;
import { AuthenticatedMethod, LoginRedirect }         from '../scripts/Login'                     ;
import { sPLATFORM_LAYOUT }                           from '../scripts/SplendidInitUI'            ;
import { DetailView_LoadItem, DetailView_LoadLayout } from '../scripts/DetailView'                ;
import { DeleteModuleItem, ArchiveMoveData }          from '../scripts/ModuleUpdate'              ;
import { jsonReactState }                             from '../scripts/Application'               ;
// 4. Components and Views. 
import SplendidStream                                 from './SplendidStream'                     ;
import ErrorComponent                                 from '../components/ErrorComponent'         ;
import DumpSQL                                        from '../components/DumpSQL'                ;

interface IPreviewProps extends RouteComponentProps<any>
{
	MODULE_NAME: string;
	ID         : string;
	LAYOUT_NAME: string;
}

interface IPreviewState
{
	__total         : number;
	__sql           : string;
	item            : any;
	layout          : any;
	DETAIL_NAME     : string;
	SUB_TITLE       : any;
	itemKey         : number;
	streamEnabled   : boolean;
	error           : any;
}

class Preview extends React.Component<IPreviewProps, IPreviewState>
{
	private _isMounted     : boolean = false;
	private refMap         : Record<string, React.RefObject<DetailComponent<any, any>>>;
	private splendidStream = React.createRef<SplendidStream>();

	constructor(props: IPreviewProps)
	{
		super(props);
		let DETAIL_NAME: string = props.MODULE_NAME + '.' + props.LAYOUT_NAME;
		let streamEnabled: boolean = Crm_Config.ToBoolean('enable_activity_streams') && Crm_Modules.StreamEnabled(props.MODULE_NAME);
		this.state =
		{
			__total         : 0,
			__sql           : null,
			item            : null,
			layout          : null,
			DETAIL_NAME     ,
			SUB_TITLE       : null,
			itemKey         : 0,
			streamEnabled   ,
			error           : null,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		const { MODULE_NAME, ID } = this.props;
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
				await this.load(MODULE_NAME, ID);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	shouldComponentUpdate(nextProps: IPreviewProps, nextState: IPreviewState)
	{
		if ( nextProps.ID != this.props.ID )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate', nextProps);
			if ( !Sql.IsEmptyGuid(this.props.ID) )
			{
				this.LoadItem(nextProps.MODULE_NAME, nextProps.ID);
			}
			return true;
		}
		else if ( nextState.layout != this.state.layout )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate', nextState.layout);
			return true;
		}
		else if ( nextState.item != this.state.item )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate', nextState.item);
			return true;
		}
		return false;
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
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load ', error);
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
				let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
				this.setState({ item, SUB_TITLE, __sql: d.__sql, itemKey: this.state.itemKey + 1 });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem ', error);
			this.setState({ error });
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
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

	public render()
	{
		const { MODULE_NAME, ID } = this.props;
		const { item, layout, itemKey, streamEnabled } = this.state;
		this.refMap = {};
		return (
			<React.Fragment>
				<div key={ itemKey }>
					{ layout && item
					? SplendidDynamic_DetailView.AppendDetailViewFields(item, layout, this.refMap, 'tabPreviewView', null, this.Page_Command)
					: null
					}
					{ streamEnabled && layout && item
					? <div style={ {paddingTop: '6px'} }>
						<SplendidStream
							MODULE_NAME={ MODULE_NAME }
							GRID_NAME='ActivityStream.DetailView.Preview'
							ID={ ID }
							hyperLinkCallback={ this._onHyperLinkCallback }
							scrollable
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
							ref={ this.splendidStream }
						/>
					</div>
					: null
					}
				</div>
			</React.Fragment>
		);
	}
}

export default withRouter(Preview);
