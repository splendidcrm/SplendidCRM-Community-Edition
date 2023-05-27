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
import { RouteComponentProps, withRouter }    from 'react-router-dom'                  ;
// 2. Store and Types. 
import DETAILVIEWS_RELATIONSHIP               from '../types/DETAILVIEWS_RELATIONSHIP' ;
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'                    ;
import L10n                                   from '../scripts/L10n'                   ;
import Credentials                            from '../scripts/Credentials'            ;
import { Crm_Config }                         from '../scripts/Crm'                    ;
import { DetailViewRelationships_LoadLayout } from '../scripts/DetailViewRelationships';
import { AuthenticatedMethod, LoginRedirect } from '../scripts/Login'                  ;
// 4. Components and Views. 
import DumpSQL                                from '../components/DumpSQL'             ;
import ErrorComponent                         from '../components/ErrorComponent'      ;
import DynamicButtons                         from '../components/DynamicButtons'      ;
import Collapsable                            from '../components/Collapsable'         ;
import ModuleHeader                           from '../components/ModuleHeader'        ;
import UnifiedSearchView                      from './UnifiedSearchView'               ;

interface IUnifiedSearchProps extends RouteComponentProps<any>
{
	search     : string;
}

interface IUnifiedSearchState
{
	layout     : DETAILVIEWS_RELATIONSHIP[];
	items      : any[];
	activeIndex: any;
	error?     : any;
	search     : string;
}

class UnifiedSearch extends React.Component<IUnifiedSearchProps, IUnifiedSearchState>
{
	constructor(props: IUnifiedSearchProps)
	{
		super(props);
		Credentials.SetViewMode('UnifiedSearch');
		// 05/09/2022 Paul.  Must decode string, otherwise @ is kept encoded and matches nothing in database. 
		let search: string = null;
		let error : any    = null;
		if ( !Sql.IsEmptyString(props.search) )
		{
			search = decodeURIComponent(props.search);
			// 10/29/2022 Paul.  Customer may have too many records to allow anything. 
			if ( search.indexOf('*') < 0 && search.indexOf('=') < 0 )
			{
				if ( Crm_Config.ToString('UnifiedSearch.DefaultType') == 'startswith' )
					search = '=\"' + search + '*' + '\"';
				else if ( Crm_Config.ToString('UnifiedSearch.DefaultType') == 'exact' )
					search = '=\"' + search + '\"';
			}
		}
		else
		{
			// 10/29/2022 Paul.  Do not allow an empty search. 
			error = L10n.Term("Home.ERR_ONE_CHAR");
		}
		this.state =
		{
			layout     : [],
			items      : [],
			activeIndex: {},
			search     ,
			error      ,
		};
	}

	async componentDidMount()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount');
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if (status == 1)
			{
				let layout = await DetailViewRelationships_LoadLayout('Home.UnifiedSearch');
				let items  = this.LoadView(layout);

				this.setState({ layout, items });
			}
			else
			{
				LoginRedirect(this.props.history, this.constructor.name + '.componentDidMount');
			}
			document.title = L10n.Term('Home.LBL_SEARCH_RESULTS');
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	private LoadView = (layout) =>
	{
		const { search } = this.props;
		let items = [];
		if ( layout != null )
		{
			for (let iRelationship = 0; iRelationship < layout.length; iRelationship++)
			{
				let lay = layout[iRelationship];
				let sDETAIL_NAME       : string = Sql.ToString (lay.DETAIL_NAME       );
				let sMODULE_NAME       : string = Sql.ToString (lay.MODULE_NAME       );
				let sTITLE             : string = Sql.ToString (lay.TITLE             );
				let sCONTROL_NAME      : string = Sql.ToString (lay.CONTROL_NAME      );
				let nRELATIONSHIP_ORDER: number = Sql.ToInteger(lay.RELATIONSHIP_ORDER);
				let sTABLE_NAME        : string = Sql.ToString (lay.TABLE_NAME        );
				let sPRIMARY_FIELD     : string = Sql.ToString (lay.PRIMARY_FIELD     );
				let sSORT_FIELD        : string = Sql.ToString (lay.SORT_FIELD        );
				let sSORT_DIRECTION    : string = Sql.ToString (lay.SORT_DIRECTION    );

				if ( sCONTROL_NAME == 'Projects' )
				{
					sCONTROL_NAME = 'Project';
				}
				else if ( sCONTROL_NAME == 'ProjectTasks' )
				{
					sCONTROL_NAME = 'ProjectTask';
				}
				let row = { NAME: search };
				let ctl = this.loadItem(sMODULE_NAME, sTITLE, sCONTROL_NAME, row, this.Page_Command, iRelationship);
				items.push(ctl);
			}
		}
		return items;
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
	}

	private loadItem = (sMODULE_NAME, sTITLE, sCONTROL_NAME, row, Page_Command, index) =>
	{
		const sCONTROL_VIEW_NAME = sMODULE_NAME + '.Search';
		return {
			key              : sCONTROL_NAME,
			name             : L10n.Term(sTITLE),
			row              : row,
			initialOpen      : 'true',
			Page_Command     : Page_Command,
			MODULE_NAME      : sMODULE_NAME,
			CONTROL_VIEW_NAME: sCONTROL_VIEW_NAME,
			index            : parseInt(index),
			show             : true,
			__sql            : null,
		};
	}

	private onToggleCollapse = (open, item) =>
	{
		// 05/21/2019 Paul.  We will not save/restore the collapsed state in the unified search. 
		/*
		if ( open )
		{
			localStorage.setItem(item.sCONTROL_VIEW_NAME, 'true');
		}
		else
		{
			localStorage.removeItem(item.sCONTROL_VIEW_NAME);
		}
		*/
	}

	private HideModule = (MODULE_NAME: string, __sql: string): void =>
	{
		let { items } = this.state;
		if ( items != null )
		{
			for ( let i: number = 0; i < items.length; i++ )
			{
				if ( items[i].MODULE_NAME == MODULE_NAME )
				{
					items[i].show  = false;
					items[i].__sql = __sql;
				}
			}
			this.setState({ items });
		}
	}

	public render()
	{
		const { error, items, search } = this.state;
		if (error)
		{
			return <ErrorComponent error={error} />;
		}
		else
		{
			let nUnifiedSearchVisibleCount: number = 0;
			if ( items )
			{
				items.map((item, index) =>
				{
					if ( item.show )
					{
						nUnifiedSearchVisibleCount++;
					}
				});
			}
			return (
			<div key={ this.props.location.pathname }>
				<ModuleHeader MODULE_NAME='Home' MODULE_TITLE='Home.LBL_SEARCH_RESULTS' />
				{ nUnifiedSearchVisibleCount == 0
				? <div className='error' style={ {marginTop: '1em', marginBottom: '1em'} }>{ L10n.Term('.LBL_EMAIL_SEARCH_NO_RESULTS') }</div>
				: null
				}
				{ items && items.map((item, index) =>
					{
						if ( item.show )
						{
							return (
							<Collapsable name={ item.name } initialOpen={ item.initialOpen } onToggle={ (open) => this.onToggleCollapse(open, item) } key={ item.key }>
								<DynamicButtons
									ButtonStyle="ListHeader"
									VIEW_NAME={ item.CONTROL_VIEW_NAME }
									row={ item.row }
									Page_Command={ item.Page_Command }
									history={ this.props.history }
									location={ this.props.location }
									match={ this.props.match }
								/>
								<UnifiedSearchView
									MODULE_NAME={ item.MODULE_NAME }
									search= { search }
									cbHideModule={ this.HideModule }
								/>
							</Collapsable>
							);
						}
						else
						{
							return <DumpSQL SQL={ item.__sql } />;
						}
					})
				}
			</div>);
		}
	}
}

export default withRouter(UnifiedSearch);
