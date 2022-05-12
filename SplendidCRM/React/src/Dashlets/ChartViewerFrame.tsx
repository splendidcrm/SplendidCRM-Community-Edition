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
import { RouteComponentProps, withRouter } from 'react-router-dom'              ;
import { FontAwesomeIcon }                 from '@fortawesome/react-fontawesome';
import { Appear }                          from 'react-lifecycle-appear'        ;
import { observer }                        from 'mobx-react'                    ;
// 2. Store and Types. 
import IDashletProps                       from '../types/IDashletProps'        ;
// 3. Scripts. 
import Sql                                 from '../scripts/Sql'                ;
import L10n                                from '../scripts/L10n'               ;
import Credentials                         from '../scripts/Credentials'        ;
import SplendidCache                       from '../scripts/SplendidCache'      ;
import { Crm_Config }                      from '../scripts/Crm'                ;
// 4. Components and Views. 

interface IChartViewerFrameState
{
	DEFAULT_SETTINGS : any;
	REPORT_ID        : string;
	REFRESH_KEY      : number;
	dashletVisible   : boolean;
}

@observer
export default class ChartViewerFrame extends React.Component<IDashletProps, IChartViewerFrameState>
{
	private _isMounted = false;
	// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
	private themeURL   : string  = null;
	private legacyIcons: boolean = false;

	constructor(props: IDashletProps)
	{
		super(props);
		// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
		this.themeURL    = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');
		let objDEFAULT_SETTINGS: any = (!Sql.IsEmptyString(props.DEFAULT_SETTINGS) ? Sql.ParseFormData(props.DEFAULT_SETTINGS) : null);
		let sREPORT_ID = null;
		if ( objDEFAULT_SETTINGS != null )
		sREPORT_ID = objDEFAULT_SETTINGS.REPORT_ID;
		this.state =
		{
			DEFAULT_SETTINGS: objDEFAULT_SETTINGS,
			REPORT_ID       : sREPORT_ID,
			REFRESH_KEY     : 1,
			dashletVisible  : false,
		};
	}

	componentDidMount()
	{
		this._isMounted = true;
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}
	
	private _onRefresh = async (e) =>
	{
		const { REFRESH_KEY } = this.state;
		if ( this._isMounted )
		{
			this.setState({ REFRESH_KEY: REFRESH_KEY + 1 });
		}
	}

	public render()
	{
		const { ID, TITLE, SETTINGS_EDITVIEW } = this.props;
		const { REPORT_ID, DEFAULT_SETTINGS, REFRESH_KEY, dashletVisible } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', DEFAULT_SETTINGS, data);
		let sLayoutPanel = 'ChartViewerFrame_' + ID;
		let sSCRIPT_URL = Credentials.RemoteServer + 'Reports/view_embedded.aspx?ID=' + REPORT_ID + '&ParentFrame=' + sLayoutPanel + '_divDashletHTML5_frame';
		// 07/09/2019 Paul.  Use i instead of a tag to prevent navigation. 
		// 07/30/2021 Paul.  Load when the panel appears. 
		return (
		<div style={ {display: 'flex', flexGrow: 1} }>
			<div className="card" style={ {flexGrow: 1, margin: '.5em', overflowX: 'auto'} }>
				<Appear onAppearOnce={ (ioe) => this.setState({ dashletVisible: true }) }>
					<div className="card-body DashletHeader">
						<h3 style={ {float: 'left'} }>{ L10n.Term(TITLE) }</h3>
						<span
							style={ {cursor: 'pointer', float: 'right', textDecoration: 'none', marginLeft: '.5em'} }
							onClick={ (e) => this._onRefresh(e) }
						>
							{ this.legacyIcons
							? <img src={ this.themeURL + 'refresh.gif'} style={ {borderWidth: '0px'} } />
							: <FontAwesomeIcon icon="sync" size="lg" />
							}
						</span>
					</div>
				</Appear>
				{ dashletVisible
				? <div style={{ clear: 'both' }}>
					<hr />
					<div id={ sLayoutPanel + '_divDashletHTML5_frame' } className="embed-responsive" style={ {height: '600px'} }>
						<iframe key={ sLayoutPanel + '_iframe' + REFRESH_KEY.toString() } src={ sSCRIPT_URL } className="embed-responsive-item" width="100%" height="100%"></iframe>
					</div>
				</div>
				: null
				}
			</div>
		</div>);
	}
}
