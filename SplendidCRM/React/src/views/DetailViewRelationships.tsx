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
import { FontAwesomeIcon }                    from '@fortawesome/react-fontawesome'    ;
// 2. Store and Types. 
import DETAILVIEWS_RELATIONSHIP               from '../types/DETAILVIEWS_RELATIONSHIP' ;
// 3. Scripts. 
import Sql                                    from '../scripts/Sql'                    ;
import { DetailViewRelationships_LoadLayout } from '../scripts/DetailViewRelationships';
import { AuthenticatedMethod, LoginRedirect } from '../scripts/Login'                  ;
// 4. Components and Views. 
import ErrorComponent                         from '../components/ErrorComponent'      ;
import DynamicSubPanelView                    from '../views/DynamicSubPanelView'      ;

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
	layout     : DETAILVIEWS_RELATIONSHIP[];
	activeIndex: any;
	error?     : any;
}

class DetailViewRelationships extends React.Component<IDetailViewRelationshipsProps, IDetailViewRelationshipsState>
{
	private items: any[];

	constructor(props: IDetailViewRelationshipsProps)
	{
		super(props);
		this.state =
		{
			layout: [],
			activeIndex: {}
		};
	}

	async componentDidMount()
	{
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if (status == 1)
			{
				let layout = await DetailViewRelationships_LoadLayout(this.props.DETAIL_NAME);
				this.setState({ layout });
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
				if ( this.items != null )
				{
					if ( this.items.length == 0 )
					{
						this.props.onComponentComplete(PARENT_TYPE, null, DETAIL_NAME, this.items);
					}
					else
					{
						let nCompleted: number= 0;
						for ( let i: number = 0; i < this.items.length; i++ )
						{
							if ( this.items[i].precompileCompleted )
							{
								nCompleted++;
							}
						}
						if ( nCompleted == this.items.length )
						{
							this.props.onComponentComplete(PARENT_TYPE, null, DETAIL_NAME, this.items);
						}
					}
				}
			}
		}
	}

	private onComponentComplete = (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain): void =>
	{
		const { PARENT_TYPE, DETAIL_NAME } = this.props;
		if ( this.props.onComponentComplete )
		{
			let nCompleted: number= 0;
			for ( let i: number = 0; i < this.items.length; i++ )
			{
				if ( this.items[i].CONTROL_VIEW_NAME== LAYOUT_NAME )
				{
					this.items[i].precompileCompleted = true;
				}
				if ( this.items[i].precompileCompleted )
				{
					nCompleted++;
				}
			}
			if ( this.props.isPrecompile )
			{
				console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + LAYOUT_NAME + ' ' + nCompleted.toString() + ' of ' + this.items.length.toString());
			}
			if ( nCompleted == this.items.length )
			{
				this.props.onComponentComplete(PARENT_TYPE, null, DETAIL_NAME, this.items);
			}
		}
	}

	private LoadView = () =>
	{
		const { PARENT_TYPE, row } = this.props;
		const { layout } = this.state;
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
					let itemOpen =
					{
						key              : sCONTROL_NAME + sPRIMARY_ID + '.Open',
						row              : row,
						layout           : layoutOpen,
						initialOpen      : localStorage.getItem(sCONTROL_VIEW_NAME + '.Open') == 'true',
						CONTROL_VIEW_NAME: sCONTROL_VIEW_NAME + '.Open',
						PRIMARY_ID       : sPRIMARY_ID,
					};
					itemOpen.layout.TITLE        = 'Activities.LBL_OPEN_ACTIVITIES';
					itemOpen.layout.CONTROL_NAME = 'Activities.Open';
					itemOpen.layout.TABLE_NAME   = itemOpen.layout.TABLE_NAME + '_OPEN';
					items.push(itemOpen);
				
					let layoutHistory: DETAILVIEWS_RELATIONSHIP = { ...lay };
					let itemHistory =
					{
						key              : sCONTROL_NAME + sPRIMARY_ID + '.History',
						row              : row,
						layout           : layoutHistory,
						initialOpen      : localStorage.getItem(sCONTROL_VIEW_NAME + '.History') == 'true',
						CONTROL_VIEW_NAME: sCONTROL_VIEW_NAME + '.History',
						PRIMARY_ID       : sPRIMARY_ID,
					};
					itemHistory.layout.TITLE        = 'Activities.LBL_HISTORY';
					itemHistory.layout.CONTROL_NAME = 'Activities.History';
					itemHistory.layout.TABLE_NAME   = itemHistory.layout.TABLE_NAME + '_HISTORY';
					items.push(itemHistory);
				}
				else
				{
					let tempLayout: DETAILVIEWS_RELATIONSHIP = { ...lay };
					let item =
					{
						key              : sCONTROL_NAME + sPRIMARY_ID,
						row              : row,
						layout           : tempLayout,
						initialOpen      : localStorage.getItem(sCONTROL_VIEW_NAME) == 'true',
						CONTROL_VIEW_NAME: sCONTROL_VIEW_NAME,
						PRIMARY_ID       : sPRIMARY_ID,
					};
					if ( sCONTROL_NAME == 'ActivitiesOpen' )
					{
						item.layout.TITLE        = 'Activities.LBL_OPEN_ACTIVITIES';
						item.layout.CONTROL_NAME = 'Activities.Open';
					}
					else if ( sCONTROL_NAME == 'ActivitiesHistory' )
					{
						item.layout.TITLE        = 'Activities.LBL_HISTORY';
						item.layout.CONTROL_NAME = 'Activities.History';
					}
					else if ( sCONTROL_NAME == 'Projects' )
					{
						item.layout.CONTROL_NAME = 'Project';
					}
					else if ( sCONTROL_NAME == 'ProjectTasks' )
					{
						item.layout.CONTROL_NAME = 'ProjectTask';
					}
					items.push(item);
				}
			}
		}
		return items;
	}

	public render()
	{
		const { PARENT_TYPE } = this.props;
		const { error } = this.state;
		this.items = this.LoadView();
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', this.items);
		if ( error )
		{
			return <ErrorComponent error={error} />;
		}
		else if ( this.items != null )
		{
			return this.items.map(item => (
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
