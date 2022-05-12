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
import { RouteComponentProps, withRouter }                  from 'react-router-dom'                       ;
import { FontAwesomeIcon }                                  from '@fortawesome/react-fontawesome'         ;
// 2. Store and Types. 
import ACL_FIELD_ACCESS                                     from '../types/ACL_FIELD_ACCESS'              ;
import { HeaderButtons }                                    from '../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                                  from '../scripts/Sql'                         ;
import L10n                                                 from '../scripts/L10n'                        ;
import Security                                             from '../scripts/Security'                    ;
import Credentials                                          from '../scripts/Credentials'                 ;
import SplendidCache                                        from '../scripts/SplendidCache'               ;
import SplendidDynamic                                      from '../scripts/SplendidDynamic'             ;
import { Crm_Config, Crm_Modules }                          from '../scripts/Crm'                         ;
import { Trim, EndsWith }                                   from '../scripts/utility'                     ;
import { ListView_LoadTablePaginated, ListView_LoadTable }  from '../scripts/ListView'                    ;
import { DetailViewRelationships_LoadLayout }               from '../scripts/DetailViewRelationships'     ;
import { AuthenticatedMethod, LoginRedirect }               from '../scripts/Login'                       ;
import { CreateSplendidRequest, GetSplendidResult }         from '../scripts/SplendidRequest'             ;
// 4. Components and Views. 
import PopupView                                            from '../views/PopupView'                     ;
import SplendidGrid                                         from '../components/SplendidGrid'             ;
import HeaderButtonsFactory                                 from '../ThemeComponents/HeaderButtonsFactory';

interface IListViewProps extends RouteComponentProps<any>
{
	MODULE_NAME           : string;
	ID                    : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IListViewState
{
	GRID_NAME             : string;
	PRIMARY_MODULE        : string;
	SECONDARY_MODULE      : string;
	DOCUMENT_TEMPLATE_ID  : string;
	lstPRIMARY_MODULES    : any[];
	lstDOCUMENT_TEMPLATES : any[];
	SECONDARY_DATA        : any;
	arrID                 : string[];
	error?                : any;
	primaryPopupOpen      : boolean;
	secondaryPopupOpen    : boolean;
	ACTIVE_PRIMARY_ID     : string;
	gridKey               : number;
}

class MailMergeView extends React.Component<IListViewProps, IListViewState>
{
	private _isMounted = false;
	private themeURL: string = null;
	private splendidGrid  = React.createRef<SplendidGrid>();
	private headerButtons = React.createRef<HeaderButtons>();
	private legacyIcons: boolean = false;
	private vwMain     : any[] = null;

	constructor(props: IListViewProps)
	{
		super(props);
		let GRID_NAME: string = 'MailMerge.ListView';
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');
		let arrID    : string[] = [];
		if ( !Sql.IsEmptyString(this.props.ID) )
		{
			arrID = decodeURIComponent(Sql.ToString(this.props.ID)).split(',');
		}
		this.state =
		{
			GRID_NAME            ,
			PRIMARY_MODULE       : this.props.MODULE_NAME,
			SECONDARY_MODULE     : null,
			DOCUMENT_TEMPLATE_ID : null,
			lstPRIMARY_MODULES   : [],
			lstDOCUMENT_TEMPLATES: [],
			SECONDARY_DATA       : {},
			arrID                ,
			error                : null,
			primaryPopupOpen     : false,
			secondaryPopupOpen   : false,
			ACTIVE_PRIMARY_ID    : null,
			gridKey              : 0,
		};
	}

	async componentDidMount()
	{
		let { PRIMARY_MODULE } = this.state;
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				if ( Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(false);
				}
				document.title = L10n.Term('MailMerge.LBL_LIST_FORM_TITLE');
				window.scroll(0, 0);
				
				let arrDetailViewRelationship = await DetailViewRelationships_LoadLayout('Modules.MailMerge');
				let lstPRIMARY_MODULES: any[] = [];
				for ( let i: number = 0; i < arrDetailViewRelationship.length; i++ )
				{
					let obj: any = {};
					obj.MODULE_NAME = arrDetailViewRelationship[i].MODULE_NAME;
					obj.TITLE       = L10n.ListTerm('moduleList', obj.MODULE_NAME);
					// 04/28/2021 Paul.  Make sure module is avilable. 
					if ( SplendidCache.Module(obj.MODULE_NAME) != null )
					{
						lstPRIMARY_MODULES.push(obj);
					}
				}
				if ( SplendidCache.Module('Campaigns') != null )
				{
					let obj    : any =
					{
						MODULE_NAME: 'Campaigns',
						TITLE      : L10n.ListTerm('moduleList', 'Campaigns')
					};
					lstPRIMARY_MODULES.push(obj);
				}
				if ( SplendidCache.Module('ProspectLists') != null )
				{
					let obj: any =
					{
						MODULE_NAME: 'ProspectLists',
						TITLE      : L10n.ListTerm('moduleList', 'ProspectLists')
					};
					lstPRIMARY_MODULES.push(obj);
				}
				if ( Sql.IsEmptyString(PRIMARY_MODULE) && lstPRIMARY_MODULES.length > 0 )
				{
					PRIMARY_MODULE = lstPRIMARY_MODULES[0].MODULE_NAME;
				}
				this.setState({ PRIMARY_MODULE, lstPRIMARY_MODULES }, async () =>
				{
					this.LoadTemplates(PRIMARY_MODULE);
				});
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
		const { error } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + LAYOUT_NAME, data);
		if ( this.props.onComponentComplete )
		{
			if ( error == null )
			{
				let vwMain = null;
				this.props.onComponentComplete(MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data);
			}
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { PRIMARY_MODULE, SECONDARY_MODULE, DOCUMENT_TEMPLATE_ID } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		switch ( sCommandName )
		{
			case 'Generate':
			{
				try
				{
					let data: any[] = [];
					for ( let i: number = 0; i < this.vwMain.length; i++ )
					{
						let row: any = {};
						row.ID             = this.vwMain[i].ID            ;
						row.NAME           = this.vwMain[i].NAME          ;
						row.MODULE_NAME    = this.vwMain[i].MODULE_NAME   ;
						row.SECONDARY_ID   = this.vwMain[i].SECONDARY_ID  ;
						row.SECONDARY_NAME = this.vwMain[i].SECONDARY_NAME;
						data.push(row);
					}
					let obj: any =
					{
						PRIMARY_MODULE      ,
						SECONDARY_MODULE    ,
						DOCUMENT_TEMPLATE_ID,
						data                ,
					};
					let sBody: string = JSON.stringify(obj);
					let res: Response = await CreateSplendidRequest('MailMerge/Rest.svc/Generate', 'POST', 'application/octet-stream', sBody);

					// https://stackoverflow.com/questions/16086162/handle-file-download-from-ajax-post
					let filename   : string = '';
					let type       : string = res.headers.get('Content-Type');
					let disposition: string = res.headers.get('Content-Disposition');

					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, res.headers);
					if ( disposition && disposition.indexOf('attachment') !== -1 )
					{
						var filenameRegex = /filename[^;=\n]*=((['"]).*?\2|[^;\n]*)/;
						var matches = filenameRegex.exec(disposition);
						if ( matches != null && matches[1] )
						{
							filename = matches[1].replace(/['"]/g, '');
						}
						let blob        = await res.blob();
						let downloadUrl = window.URL.createObjectURL(blob);
						let a           = document.createElement("a");
						a.href          = downloadUrl;
						a.download      = filename;
						document.body.appendChild(a);
						a.click();
						setTimeout(function () { window.URL.revokeObjectURL(downloadUrl); }, 100); // cleanup
					}
					else
					{
						let json = await GetSplendidResult(res);
						throw(json);
					}
				}
				catch(error)
				{
					this.setState({ error });
				}
				break;
			}
			default:
			{
				if ( this._isMounted )
				{
					this.setState( {error: sCommandName + ' is not supported at this time'} );
				}
				break;
			}
		}
	}

	private _onGridLayoutLoaded = async () =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onGridLayoutLoaded');
		if ( this.splendidGrid.current != null )
		{
			this.splendidGrid.current.Search(null, null);
		}
	}

	private LoadTemplates = async (PRIMARY_MODULE: string) =>
	{
		try
		{
			let sFILTER: string = 'PRIMARY_MODULE eq \'' + PRIMARY_MODULE + '\'';
			if ( PRIMARY_MODULE == 'Campaigns' || PRIMARY_MODULE == 'ProspectLists' )
			{
				sFILTER = 'PRIMARY_MODULE in (\'Contacts\', \'Leads\', \'Prospects\')';
			}
			let d = await ListView_LoadTable('vwDOCUMENTS_MailMergeTemplates', 'NAME', 'asc', 'ID,NAME', sFILTER, null, false);
			if ( d != null && d.results != null && d.results.length > 0 )
			{
				let DOCUMENT_TEMPLATE_ID: string = null;
				if ( d.results.length > 0 )
				{
					DOCUMENT_TEMPLATE_ID = d.results[0].ID;
				}
				this.setState(
				{
					DOCUMENT_TEMPLATE_ID ,
					lstDOCUMENT_TEMPLATES: d.results,
					gridKey              : this.state.gridKey + 1
				}, async () =>
				{
					if ( !Sql.IsEmptyString(DOCUMENT_TEMPLATE_ID) )
					{
						await this.UpdateDocumentTemplate(DOCUMENT_TEMPLATE_ID);
					}
				});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadTemplates', error);
			this.setState({ error });
		}
	}

	private Load = async (sMODULE_NAME: string, sSORT_FIELD: string, sSORT_DIRECTION: string, sSELECT: string, sFILTER: string, rowSEARCH_VALUES: any, nTOP: number, nSKIP: number, bADMIN_MODE: boolean, archiveView: boolean) =>
	{
		const { PRIMARY_MODULE, arrID, SECONDARY_DATA } = this.state;
		let sTABLE_NAME: string = Crm_Modules.TableName(PRIMARY_MODULE);
		let arrSELECT: string[] = sSELECT.split(',');
		if ( arrSELECT.indexOf('ID') < 0 )
		{
			arrSELECT.push('ID');
		}
		// 04/30/2021 Paul.  Campaigns and ProspectLists both provide a MODULE_NAME per record. 
		if ( PRIMARY_MODULE == 'ProspectLists' || PRIMARY_MODULE == 'Campaigns' )
		{
			if ( arrSELECT.indexOf('MODULE_NAME') < 0 )
			{
				arrSELECT.push('MODULE_NAME');
			}
		}
		else
		{
			if ( arrSELECT.indexOf('MODULE_NAME') >= 0 )
			{
				if ( arrSELECT.indexOf('MODULE_NAME') >= 0 )
					arrSELECT.splice(arrSELECT.indexOf('MODULE_NAME'), 1);
			}
		}
		sSELECT = arrSELECT.join(',');
		if ( PRIMARY_MODULE == 'ProspectLists' )
		{
			sFILTER     = 'PROSPECT_LIST_ID in (\'' + arrID.join('\',\'') + '\')';
			sTABLE_NAME = 'vwPROSPECT_LISTS_MailMerge';
		}
		else if ( PRIMARY_MODULE == 'Campaigns' )
		{
			sFILTER     = 'CAMPAIGN_ID in (\'' + arrID.join('\',\'') + '\')';
			sTABLE_NAME = 'vwCAMPAIGNS_MailMerge';
		}
		else
		{
			sFILTER = 'ID in (\'' + arrID.join('\',\'') + '\')';
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Load', sFILTER);
		let d = { results: [], __total: 0, __sql: null };
		if ( arrID != null && arrID.length > 0 )
		{
			d = await ListView_LoadTablePaginated(sTABLE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE, archiveView);
			if ( d != null && d.results != null && d.results.length > 0 )
			{
				for ( let i: number = 0; i < d.results.length; i++ )
				{
					let row: any = d.results[i];
					// 04/30/2021 Paul.  Campaigns and ProspectLists both provide a MODULE_NAME per record. 
					if ( !(PRIMARY_MODULE == 'ProspectLists' || PRIMARY_MODULE == 'Campaigns') )
					{
						row['MODULE_NAME'] = PRIMARY_MODULE;
					}
					let ID = row['ID'];
					if ( SECONDARY_DATA[ID] )
					{
						row['SECONDARY_ID'  ] = SECONDARY_DATA[ID].ID  ;
						row['SECONDARY_NAME'] = SECONDARY_DATA[ID].NAME;
					}
				}
			}
			this.vwMain = d.results;
		}
		return d;
	}

	private _onPRIMARY_MODULE_Change = async (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let PRIMARY_MODULE: string = event.target.value;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onPRIMARY_MODULE_Change', PRIMARY_MODULE);
		this.setState(
		{
			PRIMARY_MODULE,
			gridKey       : this.state.gridKey + 1
			});
		await this.LoadTemplates(PRIMARY_MODULE);
	}

	private UpdateDocumentTemplate = async(DOCUMENT_TEMPLATE_ID) =>
	{
		let { SECONDARY_DATA } = this.state;
		try
		{
			let res  = await CreateSplendidRequest('MailMerge/Rest.svc/GetTemplateProperties?DOCUMENT_ID=' + DOCUMENT_TEMPLATE_ID, 'GET');
			let json = await GetSplendidResult(res);
			let obj: any = json.d;
			let SECONDARY_MODULE: string = Sql.ToString(obj.SECONDARY_MODULE);
			if ( Sql.IsEmptyString(SECONDARY_MODULE) )
			{
				SECONDARY_DATA = {};
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDOCUMENT_TEMPLATE_Change', DOCUMENT_TEMPLATE_ID);
			this.setState(
			{
				SECONDARY_MODULE,
				SECONDARY_DATA  ,
				gridKey         : this.state.gridKey + 1,
			});
		}
		catch(error)
		{
			this.setState({ error });
		}
	}

	private _onDOCUMENT_TEMPLATE_Change = async (event: React.ChangeEvent<HTMLSelectElement>) =>
	{
		let DOCUMENT_TEMPLATE_ID: string = event.target.value;
		this.setState({ DOCUMENT_TEMPLATE_ID });
		await this.UpdateDocumentTemplate(DOCUMENT_TEMPLATE_ID);
	}

	private _onClickAddRecord = () =>
	{
		this.setState({ primaryPopupOpen: true });
	}

	private _onSelectAddRecord = async (value: { Action: string, ID: string, NAME: string, selectedItems: any }) =>
	{
		let { arrID } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectAddRecord', value);
		if ( value.Action == 'SingleSelect' )
		{
			if ( arrID.indexOf(value.ID) < 0 )  // if ( !arrID.includes(ID) )
			{
				arrID.push(value.ID);
			}
			this.setState({ primaryPopupOpen: false, arrID }, async () =>
			{
				this.splendidGrid.current.Search(null, null);
			});
		}
		else if ( value.Action == 'MultipleSelect' )
		{
			for ( let ID in value.selectedItems )
			{
				if ( arrID.indexOf(ID) < 0 )  // if ( !arrID.includes(ID) )
				{
					arrID.push(ID);
				}
			}
			this.setState({ primaryPopupOpen: false, arrID }, async () =>
			{
				this.splendidGrid.current.Search(null, null);
			});
		}
		else if ( value.Action == 'Close' )
		{
			this.setState({ primaryPopupOpen: false });
		}
	}

	private _onSelectSecondary = async (value: { Action: string, ID: string, NAME: string, selectedItems: any }) =>
	{
		let { SECONDARY_DATA, ACTIVE_PRIMARY_ID } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSelectSecondary', value);
		if ( !Sql.IsEmptyString(ACTIVE_PRIMARY_ID) && value.Action == 'SingleSelect' )
		{
			SECONDARY_DATA[ACTIVE_PRIMARY_ID] = {};
			SECONDARY_DATA[ACTIVE_PRIMARY_ID].ID   = value.ID  ;
			SECONDARY_DATA[ACTIVE_PRIMARY_ID].NAME = value.NAME;
			ACTIVE_PRIMARY_ID = null;
			this.setState({ secondaryPopupOpen: false, SECONDARY_DATA, ACTIVE_PRIMARY_ID }, async () =>
			{
				this.splendidGrid.current.Search(null, null);
			});
		}
		else if ( value.Action == 'Close' )
		{
			this.setState({ secondaryPopupOpen: false });
		}
	}

	private _onRemovePrimary = (row) =>
	{
		let { arrID } = this.state;
		let ID: string = row['ID'];
		if ( arrID.indexOf(ID) >= 0 )
			arrID.splice(arrID.indexOf(ID), 1);
		this.setState({ arrID }, async () =>
		{
			this.splendidGrid.current.Search(null, null);
		});
	}

	private _onEditSecondary = (row) =>
	{
		let ACTIVE_PRIMARY_ID = row['ID'];
		this.setState({ secondaryPopupOpen: true, ACTIVE_PRIMARY_ID });
	}

	private _onRemoveSecondary = (row) =>
	{
		let { SECONDARY_DATA } = this.state;
		let ACTIVE_PRIMARY_ID = row['ID'];
		delete SECONDARY_DATA[ACTIVE_PRIMARY_ID];
		this.setState({ SECONDARY_DATA }, async () =>
		{
			this.splendidGrid.current.Search(null, null);
		});
	}

	private removeFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		let sRemoveTitle = L10n.Term('.LNK_DELETE');
		return (
			<span style={ {whiteSpace: 'nowrap'} }>
				<span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={() => this._onRemovePrimary(row) } title={ sRemoveTitle }>
					{ sRemoveTitle }
					&nbsp;
					{ this.legacyIcons
					? <img src={ this.themeURL + 'delete_inline.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon='minus' size='lg' />
					}
				</span>
			</span>
		);
	}

	private editSecondaryFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		let sEditTitle  : string = L10n.Term('.LNK_EDIT'  );
		let sRemoveTitle: string = L10n.Term('.LNK_DELETE');
		return (
			<span style={ {whiteSpace: 'nowrap', textAlign: 'right'} }>
				<span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={ () => this._onEditSecondary(row) } title={ sEditTitle}>
					{ sEditTitle }
					&nbsp;
					{ this.legacyIcons
					? <img src={ this.themeURL + 'edit_inline.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon='edit' size='lg' />
					}
				</span>
				<span style={ {cursor: 'pointer', padding: '3px', textDecoration: 'none'} } onClick={() => this._onRemoveSecondary(row) } title={ sRemoveTitle }>
					{ sRemoveTitle }
					&nbsp;
					{ this.legacyIcons
					? <img src={ this.themeURL + 'delete_inline.gif'} style={ {borderWidth: '0px'} } />
					: <FontAwesomeIcon icon='minus' size='lg' />
					}
				</span>
			</span>
		);
	}

	private BootstrapColumns = (sLIST_MODULE_NAME, layout, sPRIMARY_MODULE, sPRIMARY_ID) =>
	{
		const { SECONDARY_MODULE } = this.state;
		// 04/20/2017 Paul.  Build DataTables columns. 
		let arrDataTableColumns = [];
		let objDataColumn: any = {};
		objDataColumn =
		{
			key            : 'editview',
			text           : null,
			dataField      : 'empty1',
			formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.editviewColumnFormatter : null),
			headerClasses  : 'listViewThS2',
			headerStyle    : {padding: 0, margin: 0},
			headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader : null),
			sort           : false,
			isDummyField   : true,
			formatExtraData:
			{
				data:
				{
					GRID_NAME : sLIST_MODULE_NAME,
					DATA_FIELD: null,
					layout    : layout
				}
			}
		};
		// 01/07/2018 Paul.  Force first column to be displayed. 
		arrDataTableColumns.push(objDataColumn);

		let bEnableTeamManagement = Crm_Config.enable_team_management();
		let bEnableDynamicTeams = Crm_Config.enable_dynamic_teams();
		// 02/26/2016 Paul.  Use values from C# NumberFormatInfo. 
		let oNumberFormat = Security.NumberFormatInfo();
		if ( Crm_Config.ToString('currency_format') == 'c0' )
		{
			oNumberFormat.CurrencyDecimalDigits = 0;
		}
		if ( layout != null )
		{
			for ( let nLayoutIndex = 0; layout != null && nLayoutIndex < layout.length; nLayoutIndex++ )
			{
				let lay = layout[nLayoutIndex];
				let COLUMN_TYPE                = lay.COLUMN_TYPE               ;
				let COLUMN_INDEX               = lay.COLUMN_INDEX              ;
				let HEADER_TEXT                = lay.HEADER_TEXT               ;
				let SORT_EXPRESSION            = lay.SORT_EXPRESSION           ;
				let ITEMSTYLE_WIDTH            = lay.ITEMSTYLE_WIDTH           ;
				let ITEMSTYLE_CSSCLASS         = lay.ITEMSTYLE_CSSCLASS        ;
				let ITEMSTYLE_HORIZONTAL_ALIGN = lay.ITEMSTYLE_HORIZONTAL_ALIGN;
				let ITEMSTYLE_VERTICAL_ALIGN   = lay.ITEMSTYLE_VERTICAL_ALIGN  ;
				// 10/30/2020 Paul.  ITEMSTYLE_WRAP defaults to true. 
				let ITEMSTYLE_WRAP             = (lay.ITEMSTYLE_WRAP == null ? true : lay.ITEMSTYLE_WRAP);
				let DATA_FIELD                 = lay.DATA_FIELD                ;
				let DATA_FORMAT                = lay.DATA_FORMAT               ;
				let URL_FIELD                  = lay.URL_FIELD                 ;
				let URL_FORMAT                 = lay.URL_FORMAT                ;
				let URL_TARGET                 = lay.URL_TARGET                ;
				let LIST_NAME                  = lay.LIST_NAME                 ;
				let URL_MODULE                 = lay.URL_MODULE                ;
				let URL_ASSIGNED_FIELD         = lay.URL_ASSIGNED_FIELD        ;
				let VIEW_NAME                  = lay.VIEW_NAME                 ;
				let MODULE_NAME                = lay.MODULE_NAME               ;
				let MODULE_TYPE                = lay.MODULE_TYPE               ;
				let PARENT_FIELD               = lay.PARENT_FIELD              ;

				if ( (DATA_FIELD == 'TEAM_NAME' || DATA_FIELD == 'TEAM_SET_NAME') )
				{
					if ( bEnableTeamManagement && bEnableDynamicTeams )
					{
						HEADER_TEXT = '.LBL_LIST_TEAM_SET_NAME';
						DATA_FIELD  = 'TEAM_SET_NAME';
					}
					else if ( !bEnableTeamManagement )
					{
						// 10/24/2012 Paul.  Clear the sort so that there would be no term lookup. 
						HEADER_TEXT     = null;
						SORT_EXPRESSION = null;
						COLUMN_TYPE     = 'Hidden';
					}
				}
				// 01/18/2010 Paul.  A field is either visible or not.  At this time, we will not only show a field to its owner. 
				let bIsReadable: boolean = true;
				// 08/02/2010 Paul.  The JavaScript and Hover fields will not have a data field. 
				if ( SplendidCache.bEnableACLFieldSecurity && !Sql.IsEmptyString(DATA_FIELD) )
				{
					let gASSIGNED_USER_ID: string = null;
					let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
				}

				if (   COLUMN_TYPE == 'BoundColumn'
				  && ( DATA_FORMAT == 'Date'
					|| DATA_FORMAT == 'DateTime'
					|| DATA_FORMAT == 'Currency'
					|| DATA_FORMAT == 'Image'
					|| DATA_FORMAT == 'MultiLine'
					// 08/26/2014 Paul.  Ignore ImageButton. 
					|| DATA_FORMAT == 'ImageButton'
				   )
				)
				{
					COLUMN_TYPE = 'TemplateColumn';
				}
				if ( DATA_FORMAT == 'ImageButton' && URL_FORMAT == 'Preview' )
				{
					bIsReadable = bIsReadable && SplendidDynamic.StackedLayout(SplendidCache.UserTheme);
				}
				// 08/20/2016 Paul.  The hidden field is a DATA_FORMAT, not a COLUMN_TYPE, but keep COLUMN_TYPE just in case anyone used it. 
				// 07/22/2019 Paul.  Apply ACL Field Security. 
				if ( !bIsReadable || COLUMN_TYPE == 'Hidden' || DATA_FORMAT == 'Hidden' )
				{
					continue;  // 04/23/2017 Paul.  Return instead of continue as we are in a binding function. 
				}
				if ( COLUMN_TYPE == 'TemplateColumn' )
				{
					// 04/20/2017 Paul.  Build DataTables columns. 
					// 01/22/2020 Paul.  Apply wrap flag. 
					objDataColumn =
					{
						key            : 'column' + nLayoutIndex,
						text           : (Sql.IsEmptyString(HEADER_TEXT) ? '' : L10n.Term(HEADER_TEXT)),
						dataField      : DATA_FIELD,
						classes        : '',
						style          : (Sql.ToBoolean(ITEMSTYLE_WRAP) ? null : {whiteSpace: 'nowrap'}),
						headerClasses  : 'listViewThS2',
						headerStyle    : {whiteSpace: 'nowrap'},
						headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader            : null),
						formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.templateColumnFormatter : null),
						sort           : (SORT_EXPRESSION != null),
						isDummyField   : false,
						formatExtraData:
						{
							data:
							{
								GRID_NAME   : sLIST_MODULE_NAME,
								DATA_FIELD  : DATA_FIELD,
								COLUMN_INDEX: COLUMN_INDEX,
								layout      : lay
							}
						}
					};
					// 02/16/2021 Paul.  Need to manually override the bootstrap header style. 
					// 04/24/2022 Paul.  Move Arctic style override to style.css. 
					if ( ITEMSTYLE_HORIZONTAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_HORIZONTAL_ALIGN;
					}
					if ( ITEMSTYLE_VERTICAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_VERTICAL_ALIGN;
					}
					if ( ITEMSTYLE_WIDTH != null )
					{
						objDataColumn.attrs = { width: ITEMSTYLE_WIDTH };
					}
					// 07/25/2017 Paul.  Try and force the NAME column to always be displayed on mobile portrait mode. 
					// https://datatables.net/extensions/responsive/classes
					if ( DATA_FIELD == "NAME" )
					{
						objDataColumn.classes = ' all';
					}
					objDataColumn.classes = Trim(objDataColumn.classes);

					arrDataTableColumns.push(objDataColumn);
				}
				else if ( COLUMN_TYPE == 'BoundColumn' )
				{
					// 04/20/2017 Paul.  Build DataTables columns. 
					// 01/22/2020 Paul.  Apply wrap flag. 
					objDataColumn =
					{
						key            : 'column' + nLayoutIndex,
						text           : (Sql.IsEmptyString(HEADER_TEXT) ? '' : L10n.Term(HEADER_TEXT)),
						dataField      : DATA_FIELD,
						classes        : '',
						style          : (Sql.ToBoolean(ITEMSTYLE_WRAP) ? null : {whiteSpace: 'nowrap'}),
						headerClasses  : 'listViewThS2',
						headerStyle    : {whiteSpace: 'nowrap'},
						headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader         : null),
						formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.boundColumnFormatter : null),
						sort           : (SORT_EXPRESSION != null),
						isDummyField   : false,
						formatExtraData:
						{
							data:
							{
								GRID_NAME   : sLIST_MODULE_NAME,
								DATA_FIELD  : DATA_FIELD,
								COLUMN_INDEX: COLUMN_INDEX,
								layout      : lay
							}
						}
					};
					// 02/16/2021 Paul.  Need to manually override the bootstrap header style. 
					// 04/24/2022 Paul.  Move Arctic style override to style.css. 
					if ( ITEMSTYLE_HORIZONTAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_HORIZONTAL_ALIGN;
					}
					if ( ITEMSTYLE_VERTICAL_ALIGN != null )
					{
						objDataColumn.classes += ' gridView' + ITEMSTYLE_VERTICAL_ALIGN;
					}
					if ( ITEMSTYLE_WIDTH != null )
					{
						objDataColumn.attrs = { width: ITEMSTYLE_WIDTH };
					}
					objDataColumn.classes = Trim(objDataColumn.classes);
					arrDataTableColumns.push(objDataColumn);
				}
			}
			// 05/17/2018 Paul.  Defer finalize. 
			//if ( this.BootstrapColumnsFinalize != null )
			//	arrDataTableColumns = this.BootstrapColumnsFinalize(sLIST_MODULE_NAME, arrDataTableColumns);
		}
		objDataColumn =
		{
			key            : 'editview',
			text           : null,
			dataField      : 'empty2',
			formatter      : this.removeFormatter,
			headerClasses  : 'listViewThS2',
			headerStyle    : {padding: 0, margin: 0},
			headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader         : null),
			sort           : false,
			isDummyField   : true,
			attrs          : { width: '5%' },
			formatExtraData:
			{
				data:
				{
					GRID_NAME : sLIST_MODULE_NAME,
					DATA_FIELD: null,
					layout    : layout
				}
			}
		};
		arrDataTableColumns.push(objDataColumn);
		if ( !Sql.IsEmptyString(SECONDARY_MODULE) )
		{
			let HEADER_TEXT    : string  = 'MailMerge.LBL_LIST_SECONDARY_NAME';
			let ITEMSTYLE_WRAP : boolean = false;
			let SORT_EXPRESSION: string  = null;
			let DATA_FIELD     : string  = 'SECONDARY_NAME';
			let ITEMSTYLE_WIDTH: string  = '40%';
			let COLUMN_INDEX   : number  = layout.length;

			let lay: any = {};
			lay.COLUMN_TYPE                = 'BoundColumn';
			lay.COLUMN_INDEX               = COLUMN_INDEX;
			lay.HEADER_TEXT                = HEADER_TEXT;
			lay.SORT_EXPRESSION            = SORT_EXPRESSION;
			lay.ITEMSTYLE_WIDTH            = ITEMSTYLE_WIDTH;
			lay.ITEMSTYLE_CSSCLASS         = null;
			lay.ITEMSTYLE_HORIZONTAL_ALIGN = null;
			lay.ITEMSTYLE_VERTICAL_ALIGN   = null;
			lay.ITEMSTYLE_WRAP             = ITEMSTYLE_WRAP;
			lay.DATA_FIELD                 = DATA_FIELD;
			lay.DATA_FORMAT                = null;
			lay.URL_FIELD                  = null;
			lay.URL_FORMAT                 = null;
			lay.URL_TARGET                 = null;
			lay.LIST_NAME                  = null;
			lay.URL_MODULE                 = null;
			lay.URL_ASSIGNED_FIELD         = null;
			lay.VIEW_NAME                  = null;
			lay.MODULE_NAME                = null;
			lay.MODULE_TYPE                = null;
			lay.PARENT_FIELD               = null;

			objDataColumn =
			{
				key            : 'column' + COLUMN_INDEX,
				text           : (Sql.IsEmptyString(HEADER_TEXT) ? '' : L10n.Term(HEADER_TEXT)),
				dataField      : DATA_FIELD,
				classes        : '',
				style          : (Sql.ToBoolean(ITEMSTYLE_WRAP) ? null : {whiteSpace: 'nowrap'}),
				headerClasses  : 'listViewThS2',
				headerStyle    : {whiteSpace: 'nowrap'},
				headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader         : null),
				formatter      : (this.splendidGrid.current != null ? this.splendidGrid.current.boundColumnFormatter : null),
				sort           : (SORT_EXPRESSION != null),
				isDummyField   : false,
				formatExtraData:
				{
					data:
					{
						GRID_NAME   : sLIST_MODULE_NAME,
						DATA_FIELD  : DATA_FIELD,
						COLUMN_INDEX: COLUMN_INDEX,
						layout      : lay
					}
				}
			};
			// 02/16/2021 Paul.  Need to manually override the bootstrap header style. 
			// 04/24/2022 Paul.  Move Arctic style override to style.css. 
			objDataColumn.attrs = { width: ITEMSTYLE_WIDTH };
			objDataColumn.classes = Trim(objDataColumn.classes);
			arrDataTableColumns.push(objDataColumn);
			
			objDataColumn =
			{
				key            : 'editview',
				text           : null,
				dataField      : 'empty3',
				headerClasses  : 'listViewThS2',
				headerStyle    : {padding: 0, margin: 0},
				headerFormatter: (this.splendidGrid.current != null ? this.splendidGrid.current.renderHeader         : null),
				formatter      : this.editSecondaryFormatter,
				sort           : false,
				isDummyField   : true,
				attrs          : { width: '5%' },
				formatExtraData:
				{
					data:
					{
						GRID_NAME   : sLIST_MODULE_NAME,
						DATA_FIELD  : DATA_FIELD,
						COLUMN_INDEX: COLUMN_INDEX,
						layout      : lay
					}
				}
			};
			arrDataTableColumns.push(objDataColumn);
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.BootstrapColumns', arrDataTableColumns);
		return arrDataTableColumns;
	}

	public render()
	{
		const { GRID_NAME, PRIMARY_MODULE, SECONDARY_MODULE, DOCUMENT_TEMPLATE_ID, lstPRIMARY_MODULES, lstDOCUMENT_TEMPLATES, error, primaryPopupOpen, secondaryPopupOpen, gridKey } = this.state;
		if ( SplendidCache.IsInitialized )
		{
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let MODULE_TITLE  : string = '.moduleList.Home';
			let HEADER_BUTTONS: string = 'MailMerge.ListView';
			return (<React.Fragment>
			<PopupView
				isOpen={ primaryPopupOpen }
				callback={ this._onSelectAddRecord }
				MODULE_NAME={ PRIMARY_MODULE}
				multiSelect={ true }
			/>
			<PopupView
				isOpen={ secondaryPopupOpen }
				callback={ this._onSelectSecondary }
				MODULE_NAME={ SECONDARY_MODULE}
				multiSelect={ false }
			/>
			<div style={ {display: 'flex', flexDirection: 'row', flexWrap: 'nowrap', width: '100%'} }>
				<div id='divListView' style={ {width: '100%'} }>
					{ headerButtons
					? React.createElement(headerButtons, { MODULE_NAME: PRIMARY_MODULE, MODULE_TITLE, error, enableHelp: true, helpName: 'index', ButtonStyle: 'ModuleHeader', VIEW_NAME: HEADER_BUTTONS, Page_Command: this.Page_Command, showButtons: true, showProcess: false, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
					: null
					}
					<table className="tabForm" cellSpacing={ 1 } cellPadding={ 0 } style={ {borderWidth: '0px', width: '100%'} }>
						<tr>
							<td>
								<table className="tabEditView" style={ {borderWidth: '0px'} }>
									<tr>
										<th colSpan={ 4 }>
											<h4>{ L10n.Term('MailMerge.LBL_INSTRUCTIONS') }</h4>
										</th>
									</tr>
									<tr>
										<td className="dataLabel" style={ {width: '15%', verticalAlign: 'top'} }>
											{ L10n.Term('MailMerge.LBL_SELECT_TEMPLATE') }
										</td>
										<td className="dataField" style={ {width: '35%', verticalAlign: 'top'} }>
											<select
												id="lstDOCUMENT_TEMPLATE"
												value={ DOCUMENT_TEMPLATE_ID }
												onChange={ this._onDOCUMENT_TEMPLATE_Change }
											>
											{
												lstDOCUMENT_TEMPLATES.map((item, index) => 
												{
													return (<option key={ 'lstDOCUMENT_TEMPLATE_' + index.toString() } id={ 'lstDOCUMENT_TEMPLATE_' + index.toString() } value={ item.ID }>{ item.NAME }</option>);
												})
											}
											</select>
										</td>
										<td className="dataLabel" style={ {width: '50%', verticalAlign: 'top'} }></td>
									</tr>
									<tr>
										<td className="dataLabel" style={ {width: '15%', verticalAlign: 'top'} }>
											{ L10n.Term('MailMerge.LBL_SELECTED_MODULE') }
										</td>
										<td className="dataField" style={ {width: '15%', verticalAlign: 'top'} }>
											<select
												id="lstPRIMARY_MODULE"
												value={ PRIMARY_MODULE }
												onChange={ this._onPRIMARY_MODULE_Change }
												disabled={ !Sql.IsEmptyString(this.props.MODULE_NAME) }
											>
											{
												lstPRIMARY_MODULES.map((item, index) => 
												{
													return (<option key={ 'lstPRIMARY_MODULE_' + index.toString() } id={ 'lstPRIMARY_MODULE_' + index.toString() } value={ item.MODULE_NAME }>{ item.TITLE }</option>);
												})
											}
											</select>
										</td>
										<td className="dataLabel" style={ {width: '50%', verticalAlign: 'top'} }></td>
									</tr>
									<tr>
										<td className="dataLabel" style={ {width: '15%', verticalAlign: 'top'} }>
											<span>{ L10n.Term('MailMerge.LBL_SECONDARY_MODULE') }</span>
										</td>
										<td className="dataLabel" style={ {width: '35%', verticalAlign: 'top'} }>
										{ !Sql.IsEmptyString(SECONDARY_MODULE)
										? L10n.ListTerm('moduleList', SECONDARY_MODULE)
										: null
										}
										</td>
										<td className="dataLabel" style={ {width: '50%', verticalAlign: 'top'} }></td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td>
								<input type="button"
									id="btnAddRecord"
									value={ L10n.Term('.LBL_ADD_BUTTON_LABEL') }
									title={ L10n.Term('.LBL_ADD_BUTTON_TITLE') }
									className="button"
									onClick={ this._onClickAddRecord }
								/>
							</td>
						</tr>
					</table>
					<SplendidGrid
						key={ 'SplendidGrid_' + gridKey }
						onLayoutLoaded={ this._onGridLayoutLoaded }
						MODULE_NAME={ PRIMARY_MODULE }
						GRID_NAME={ GRID_NAME }
						SORT_FIELD='NAME'
						SORT_DIRECTION='asc'
						ADMIN_MODE={ false }
						AutoSaveSearch={ false }
						archiveView={ false }
						deferLoad={ true }
						disableView={ true }
						disableEdit={ true }
						enableSelection={ false }
						enableFavorites={ false }
						enableFollowing={ false }
						enableMassUpdate={ false }
						cbCustomLoad={ this.Load }
						cbRemove={ this._onRemovePrimary }
						cbCustomColumns={ this.BootstrapColumns }
						onComponentComplete={ this._onComponentComplete }
						scrollable
						history={ this.props.history }
						location={ this.props.location }
						match={ this.props.match }
						ref={ this.splendidGrid }
					/>
				</div>
			</div>
		</React.Fragment>);
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

export default withRouter(MailMergeView);
