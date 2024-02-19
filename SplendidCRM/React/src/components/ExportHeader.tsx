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
import React from 'react';
import qs from 'query-string';
import { RouteComponentProps, withRouter }          from '../Router5'              ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome';
// 2. Store and Types. 
// 3. Scripts. 
import Sql                                          from '../scripts/Sql'                ;
import L10n                                         from '../scripts/L10n'               ;
import Security                                     from '../scripts/Security'           ;
import Credentials                                  from '../scripts/Credentials'        ;
import SplendidCache                                from '../scripts/SplendidCache'      ;
import { FromJsonDate }                             from '../scripts/Formatting'         ;
import { Crm_Config, Crm_Modules }                  from '../scripts/Crm'                ;
import { CreateSplendidRequest, GetSplendidResult } from '../scripts/SplendidRequest'    ;
// 4. Components and Views. 

interface IExportHeaderProps extends RouteComponentProps<any>
{
	MODULE_NAME     : string;
	onExport        : (EXPORT_RANGE: string, EXPORT_FORMAT: string) => void;
	Page_Command?   : (sCommandName, sCommandArguments) => void;
	// 01/29/2021 Paul.  EditCustomFields does not require range or format. 
	hideRange?      : boolean;
	hideFormat?     : boolean;
	// 03/18/2021 Paul.  Lists without selection checkboxes should not allow Selected option. 
	disableSelected?: boolean;
}

interface IExportHeaderState
{
	EXPORT_RANGE                   : string;
	EXPORT_FORMAT                  : string;
	EXPORT_RANGE_LIST              : any[];
	EXPORT_FORMAT_LIST             : any[];
	bPhoneBurnerEnabled            : boolean;
	lblPhoneBurnerAuthorizedStatus : string;
	dtPhoneBurnerOAuthExpiresAt    : Date;
}

export default class ExportHeader extends React.Component<IExportHeaderProps, IExportHeaderState>
{
	public SetStatus(status: string)
	{
		this.setState({ lblPhoneBurnerAuthorizedStatus: status });
	}

	constructor(props: IExportHeaderProps)
	{
		super(props);
		let EXPORT_RANGE_LIST : any[] = [];
		let EXPORT_FORMAT_LIST: any[] = [];

		EXPORT_RANGE_LIST.push({ DISPLAY_NAME: L10n.Term('.LBL_LISTVIEW_OPTION_ENTIRE'  ), NAME: 'All'     });
		EXPORT_RANGE_LIST.push({ DISPLAY_NAME: L10n.Term('.LBL_LISTVIEW_OPTION_CURRENT' ), NAME: 'Page'    });
		// 03/18/2021 Paul.  Lists without selection checkboxes should not allow Selected option. 
		if ( !props.disableSelected )
			EXPORT_RANGE_LIST.push({ DISPLAY_NAME: L10n.Term('.LBL_LISTVIEW_OPTION_SELECTED'), NAME: 'Selected'});
		
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_XML_SPREADSHEET'  ), NAME: 'Excel'   });
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_XML'              ), NAME: 'xml'     });
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_CUSTOM_CSV'       ), NAME: 'csv'     });
		EXPORT_FORMAT_LIST.push({ DISPLAY_NAME: L10n.Term('Import.LBL_CUSTOM_TAB'       ), NAME: 'tab'     });
		
		let bPhoneBurnerEnabled: boolean = Crm_Config.ToBoolean('PhoneBurner.Enabled') && !Sql.IsEmptyString(Crm_Config.ToString('PhoneBurner.ClientID')) && (props.MODULE_NAME == Crm_Config.ToString('PhoneBurner.SyncModules'));
		this.state = 
		{
			EXPORT_RANGE                  : 'All'  ,
			EXPORT_FORMAT                 : 'Excel',
			EXPORT_RANGE_LIST             ,
			EXPORT_FORMAT_LIST            ,
			bPhoneBurnerEnabled           ,
			lblPhoneBurnerAuthorizedStatus: null,
			dtPhoneBurnerOAuthExpiresAt   : Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT,
		};
	}

	async componentDidMount()
	{
		const { MODULE_NAME } = this.props;
		const { bPhoneBurnerEnabled } = this.state;
		try
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT);
			if ( bPhoneBurnerEnabled )
			{
				let dtPhoneBurnerOAuthExpiresAt = Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT;
				let queryParams: any = qs.parse(location.search);
				if ( !Sql.IsEmptyString(queryParams['error']) )
				{
					this.setState({ lblPhoneBurnerAuthorizedStatus: queryParams['error'] });
				}
				else if ( !Sql.IsEmptyString(queryParams['code']) )
				{
					let code: string = queryParams['code'];
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem code', AUTHORIZATION_CODE);
					// 09/12/2020 Paul.  React does not have a good way to expose a method, so just redirect with the code in the url. 
					let sREDIRECT_URL   : string = Credentials.sREMOTE_SERVER + 'Administration/PhoneBurner/ConfigView'
					let obj: any =
					{
						code        ,
						redirect_url: sREDIRECT_URL, // (window.location.origin + window.location.pathname)
					};
					// 11/09/2019 Paul.  We cannot use ADAL because we are using the response_type=code style of authentication (confidential) that ADAL does not support. 
					let sBody: string = JSON.stringify(obj);
					let res  = await CreateSplendidRequest('Administration/PhoneBurner/Rest.svc/GetAccessToken', 'POST', 'application/octet-stream', sBody);
					let json = await GetSplendidResult(res);
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount token', json);
					dtPhoneBurnerOAuthExpiresAt = FromJsonDate(json.d.expires_at);
					Credentials.SetPHONEBURNER_TOKEN_EXPIRES_AT(dtPhoneBurnerOAuthExpiresAt);
					this.setState({ dtPhoneBurnerOAuthExpiresAt, lblPhoneBurnerAuthorizedStatus: '' });
					this.props.history.replace('/' + MODULE_NAME);
				}
				// 09/17/2020 Paul.  We should find a way to avoid making this query every time. 
				// Wasted cycles if PhoneBurner is enabled but this user is not a member. 
				else if ( Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT == null || Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT < (new Date()) )
				{
					let res  = await CreateSplendidRequest('Administration/PhoneBurner/Rest.svc/IsAuthenticated', 'POST', 'application/json; charset=utf-8', null);
					let json = await GetSplendidResult(res);
					if ( !Sql.IsEmptyString(json.d) )
					{
						dtPhoneBurnerOAuthExpiresAt = FromJsonDate(json.d);
						Credentials.SetPHONEBURNER_TOKEN_EXPIRES_AT(dtPhoneBurnerOAuthExpiresAt);
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', dtPhoneBurnerOAuthExpiresAt);
						this.setState({ dtPhoneBurnerOAuthExpiresAt });
					}
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ lblPhoneBurnerAuthorizedStatus: error.message });
		}
	}

	private _onEXPORT_RANGE_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let EXPORT_RANGE: string = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onEXPORT_RANGE_Change', EXPORT_RANGE);
		this.setState({ EXPORT_RANGE });
	}

	private _onEXPORT_FORMAT_Change = (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let EXPORT_FORMAT: string = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onEXPORT_FORMAT_Change', EXPORT_FORMAT);
		this.setState({ EXPORT_FORMAT });
	}

	private _onExport = async (e) =>
	{
		const { EXPORT_RANGE, EXPORT_FORMAT } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onExport', EXPORT_RANGE, EXPORT_FORMAT);
		if ( this.props.onExport )
		{
			this.props.onExport(EXPORT_RANGE, EXPORT_FORMAT);
		}
	}

	private _onAuthorize = async (e) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onAuthorize');
		try
		{
			let OAUTH_CLIENT_ID : string = Crm_Config.ToString('PhoneBurner.ClientID');
			// 09/12/2020 Paul.  React does not have a good way to expose a method, so just redirect with the code in the url. 
			let sREDIRECT_URL   : string = Credentials.sREMOTE_SERVER + 'Administration/PhoneBurner/ConfigView'
			let authenticateUrl : string = 'https://www.phoneburner.com/oauth/index?client_id=' + OAUTH_CLIENT_ID + '&redirect_uri=' + sREDIRECT_URL + '&response_type=code';
			window.open(authenticateUrl, 'PhoneBurnerPopup', 'width=830,height=830,status=1,toolbar=0,location=0,resizable=1');
		}
		catch(error)
		{
			this.setState({ lblPhoneBurnerAuthorizedStatus: error.message });
		}
	}

	private _onBeginDial = async (e) =>
	{
		const { MODULE_NAME } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onBeginDial');
		let dtPhoneBurnerOAuthExpiresAt = Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT;
		try
		{
			if ( Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT == null || Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT < (new Date()) )
			{
				let res  = await CreateSplendidRequest('Administration/PhoneBurner/Rest.svc/IsAuthenticated', 'POST', 'application/json; charset=utf-8', null);
				let json = await GetSplendidResult(res);
				if ( !Sql.IsEmptyString(json.d) )
				{
					dtPhoneBurnerOAuthExpiresAt = FromJsonDate(json.d);
					Credentials.SetPHONEBURNER_TOKEN_EXPIRES_AT(dtPhoneBurnerOAuthExpiresAt);
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', dtPhoneBurnerOAuthExpiresAt);
					this.setState({ dtPhoneBurnerOAuthExpiresAt });
				}
			}
		}
		catch(error)
		{
			this.setState({ lblPhoneBurnerAuthorizedStatus: error.message });
		}
		if ( !(Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT == null || Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT < (new Date())) )
		{
			if ( this.props.Page_Command )
			{
				this.props.Page_Command('PhoneBurner.BeginDial', null);
			}
		}
	}

	public render()
	{
		// 01/29/2021 Paul.  EditCustomFields does not require range or format. 
		const { MODULE_NAME, hideRange, hideFormat } = this.props;
		const { EXPORT_RANGE, EXPORT_FORMAT, EXPORT_RANGE_LIST, EXPORT_FORMAT_LIST, bPhoneBurnerEnabled, lblPhoneBurnerAuthorizedStatus, dtPhoneBurnerOAuthExpiresAt } = this.state;

		let sMODULE_TITLE = L10n.Term(MODULE_NAME + '.LBL_LIST_FORM_TITLE');
		let now = new Date();
		// 04/10/2022 Paul.  Move Pacific Export to pagination header. 
		// 04/10/2022 Paul.  Nobody is using the PhoneBurner module so it does not make sense to move it to the SplendidGrid. 
		if ( !(bPhoneBurnerEnabled || SplendidCache.UserTheme != 'Pacific') )
			return null;
		return (
			<table className='h3Row' cellPadding={ 0 } cellSpacing={ 1 } style={ {width: '100%'} }>
				<tr>
					<td style={ {whiteSpace: 'nowrap'} }>
						<h3 className='h3ExportHeader'>
							<FontAwesomeIcon icon='arrow-right' size='lg' style={ {marginRight: '.5em'} } transform={ {rotate: 45} } />
							&nbsp;<span>{ sMODULE_TITLE }</span>
						</h3>
					</td>
					<td style={ {textAlign: 'right'} }>
						{ SplendidCache.GetUserAccess(MODULE_NAME, 'export', this.constructor.name + '.render') >= 0
						? <div id='divExport'>
								<label id='lblPhoneBurnerAuthorizedStatus' className='error' style={ {paddingRight: '5px'} }>{ lblPhoneBurnerAuthorizedStatus }</label>
								{ bPhoneBurnerEnabled && !(dtPhoneBurnerOAuthExpiresAt == null || dtPhoneBurnerOAuthExpiresAt < now)
								? <button id='btnPhoneBurnerDialSession' onClick={ this._onBeginDial } className='button'>{ L10n.Term('PhoneBurner.LBL_BEGIN_DIAL_SESSION'    ) }</button>
								: null
								}
								{ bPhoneBurnerEnabled &&  (dtPhoneBurnerOAuthExpiresAt == null || dtPhoneBurnerOAuthExpiresAt < now)
								? <button id='btnPhoneBurnerAuthorize'   onClick={ this._onAuthorize } className='button'>{ L10n.Term('PhoneBurner.LBL_AUTHORIZE_BUTTON_LABEL') }</button>
								: null
								}
								{ SplendidCache.UserTheme != 'Pacific'
								? <React.Fragment>
									{ !hideRange
									? <select
										id='lstEXPORT_RANGE'
										onChange={ this._onEXPORT_RANGE_Change }
										value={ EXPORT_RANGE }
										style={ {width: 'auto', margin: 2} }
										>
										{
											EXPORT_RANGE_LIST.map((item, index) => 
											{
												return (<option key={ '_ctlEditView_EXPORT_RANGE_' + index.toString() } id={ '_ctlEditView_EXPORT_RANGE' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
											})
										}
									</select>
									: null
									}
									{ !hideFormat
									? <select
										id='lstEXPORT_FORMAT'
										onChange={ this._onEXPORT_FORMAT_Change }
										value={ EXPORT_FORMAT }
										style={ {width: 'auto', margin: 2} }
										>
										{
											EXPORT_FORMAT_LIST.map((item, index) => 
											{
												return (<option key={ '_ctlEditView_EXPORT_FORMAT_' + index.toString() } id={ '_ctlEditViewEXPORT_FORMAT' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
											})
										}
									</select>
									: null
									}
									<input type='submit' className='button' onClick={ this._onExport } value={ L10n.Term('.LBL_EXPORT_BUTTON_LABEL') } style={ {margin: 2} } />
								</React.Fragment>
								: null
								}
						</div>
						: null
						}
					</td>
				</tr>
			</table>
		);
	}
}

// 09/17/2020 Paul.  We don't want to use withRouter() as it makes it difficult to get a reference. 

