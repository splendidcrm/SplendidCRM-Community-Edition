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
import posed                                        from 'react-pose'                             ;
import { RouteComponentProps, withRouter }          from '../Router5'                       ;
import { observer }                                 from 'mobx-react'                             ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'         ;
import { Appear }                                   from 'react-lifecycle-appear'                 ;
// 2. Store and Types. 
import ACL_FIELD_ACCESS                             from '../../../types/ACL_FIELD_ACCESS'        ;
import { SubPanelHeaderButtons }                    from '../../../types/SubPanelHeaderButtons'   ;
// 3. Scripts. 
import Sql                                          from '../../../scripts/Sql'                   ;
import L10n                                         from '../../../scripts/L10n'                  ;
import Security                                     from '../../../scripts/Security'              ;
import Credentials                                  from '../../../scripts/Credentials'           ;
import SplendidCache                                from '../../../scripts/SplendidCache'         ;
import SplendidDynamic                              from '../../../scripts/SplendidDynamic'       ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'                 ;
import { Crm_Config, Crm_Modules }                  from '../../../scripts/Crm'                   ;
import { Trim, EndsWith }                           from '../../../scripts/utility'               ;
import { CreateSplendidRequest, GetSplendidResult } from '../../../scripts/SplendidRequest'       ;
// 4. Components and Views. 
import SplendidGrid                                 from '../../../components/SplendidGrid'       ;
import SubPanelButtonsFactory                       from '../../../ThemeComponents/SubPanelButtonsFactory';
import String                                       from '../../../GridComponents/String'         ;

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

interface ISubPanelViewProps extends RouteComponentProps<any>
{
	PARENT_TYPE      : string;
	row              : any;
	//layout           : DETAILVIEWS_RELATIONSHIP;
	CONTROL_VIEW_NAME: string;
	disableView?     : boolean;
	disableEdit?     : boolean;
	disableRemove?   : boolean;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, data) => void;
}

interface ISubPanelViewState
{
	PARENT_ID        : string;
	RELATED_MODULE?  : string;
	GRID_NAME?       : string;
	TABLE_NAME?      : string;
	SORT_FIELD?      : string;
	SORT_DIRECTION?  : string;
	PRIMARY_FIELD?   : string;
	PRIMARY_ID?      : string;
	JOIN_TABLE       : string;
	PARENT_ID_FIELD  : string;
	showCancel       : boolean;
	showFullForm     : boolean;
	showTopButtons   : boolean;
	showBottomButtons: boolean;
	showSearch       : boolean;
	showInlineEdit   : boolean;
	multiSelect      : boolean;
	popupOpen        : boolean;
	archiveView      : boolean;
	item?            : any;
	rowInitialValues : any;
	dependents?      : Record<string, Array<any>>;
	error?           : any;
	open             : boolean;
	customView       : any;
	vwMain           : any;
	gridKey          : number;
	subPanelVisible  : boolean;
}

@observer
class Mailbox extends React.Component<ISubPanelViewProps, ISubPanelViewState>
{
	private _isMounted = false;
	private splendidGrid         = React.createRef<SplendidGrid>();
	private headerButtons        = React.createRef<SubPanelHeaderButtons>();

	constructor(props: ISubPanelViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + props.PARENT_TYPE, props.layout);
		let archiveView: boolean = false;
		let GRID_NAME  : string = 'InboundEmail.Mailbox';
		let rowPARENT  : any = props.row;
		let rowInitialValues: any = {};
		let JOIN_TABLE        = null;
		let PARENT_TABLE      = Crm_Modules.TableName(props.PARENT_TYPE);
		let PARENT_ID_FIELD   = Crm_Modules.SingularTableName(PARENT_TABLE) + '_ID'  ;
		let PARENT_NAME_FIELD = Crm_Modules.SingularTableName(PARENT_TABLE) + '_NAME';
		rowInitialValues[PARENT_ID_FIELD  ] = rowPARENT.ID  ;
		rowInitialValues[PARENT_NAME_FIELD] = rowPARENT.NAME;
		
		let multiSelect: boolean = false;
		// 11/05/2020 Paul.  A customer wants to be able to have subpanels default to open. 
		let rawOpen    : string  = localStorage.getItem(props.CONTROL_VIEW_NAME);
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		let open       : boolean = (rawOpen == 'true' || this.props.isPrecompile);
		if ( rawOpen == null && Crm_Config.ToBoolean('default_subpanel_open') )
		{
			open = true;
		}
		// 11/05/2020 Paul.  Copy initial values so that we can reuse. 
		let item: any = Object.assign({}, rowInitialValues);
		this.state =
		{
			PARENT_ID        : props.row.ID,
			RELATED_MODULE   : 'Mailbox',
			GRID_NAME        ,
			TABLE_NAME       : 'vwINBOUND_EMAILS_MAILBOXES',
			SORT_FIELD       : 'DeliveryDate',
			SORT_DIRECTION   : 'desc',
			PRIMARY_FIELD    : 'ID',
			PRIMARY_ID       : props.row.ID,
			JOIN_TABLE       ,
			PARENT_ID_FIELD  ,
			showCancel       : true,
			showFullForm     : true,
			showTopButtons   : true,
			showBottomButtons: true,
			showSearch       : false,
			showInlineEdit   : false,
			multiSelect      ,
			popupOpen        : false,
			archiveView      ,
			item             ,
			rowInitialValues ,
			dependents       : {},
			error            : null,
			open             ,
			customView       : null,
			vwMain           : {},
			gridKey          : 0,
			subPanelVisible  : Sql.ToBoolean(props.isPrecompile),  // 08/31/2021 Paul.  Must show sub panel during precompile to allow it to continue. 
		};
	}

	async componentDidMount()
	{
		const { RELATED_MODULE } = this.state;
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				if ( Credentials.ADMIN_MODE )
				{
					// 03/27/2021 Paul.  A subpanel should not disable admin mode. 
					//Credentials.SetADMIN_MODE(false);
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

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { PARENT_ID } = this.state;
		let { gridKey } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		try
		{
			if ( this._isMounted )
			{
				if ( sCommandName == 'Mailbox.CheckMail' )
				{
					this.setState(
					{
						error: L10n.Term('InboundEmail.LBL_CHECKING_MAIL'),
					});
					let res = await CreateSplendidRequest('Administration/InboundEmail/Rest.svc/GetMail?ID=' + PARENT_ID, 'POST', 'application/octet-stream', null);
					let json = await GetSplendidResult(res);
					json.d.__total = json.__total;
					json.d.__sql = json.__sql;
					let d: any = json.d;
					for ( let i: number = 0; i < d.results.length; i++ )
					{
						let row: any = d.results[i];
						let sSubject: string = Sql.ToString(row['Subject']);
						let sFrom   : string = Sql.ToString(row['From'   ]);
						let sSender : string = Sql.ToString(row['Sender' ]);
						let sTo     : string = Sql.ToString(row['To'     ]);
						let sCC     : string = Sql.ToString(row['CC'     ]);
						if ( sFrom != sSender && !Sql.IsEmptyString(sSender) )
						{
							row['From'] = sFrom + '<br />' + sSender;
						}
					}
					gridKey = gridKey + 1;
					this.setState(
					{
						vwMain : json.d,
						gridKey,
						error  : '',
					});
				}
				else if ( sCommandName == 'Mailbox.CheckBounce' )
				{
					this.setState(
					{
						error: L10n.Term('InboundEmail.LBL_CHECKING_MAIL'),
					});
					let res = await CreateSplendidRequest('Administration/InboundEmail/Rest.svc/CheckBounce?ID=' + PARENT_ID, 'POST', 'application/octet-stream', null);
					let json = await GetSplendidResult(res);
					this.setState(
					{
						error: L10n.Term('InboundEmail.LBL_OPERATION_COMPLETE'),
					});
				}
				else if ( sCommandName == 'Mailbox.CheckInbound' )
				{
					this.setState(
					{
						error: L10n.Term('InboundEmail.LBL_CHECKING_MAIL'),
					});
					let res = await CreateSplendidRequest('Administration/InboundEmail/Rest.svc/CheckInbound?ID=' + PARENT_ID, 'POST', 'application/octet-stream', null);
					let json = await GetSplendidResult(res);
					this.setState(
					{
						error: L10n.Term('InboundEmail.LBL_OPERATION_COMPLETE'),
					});
				}
				else
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command: Unknown command ' + sCommandName);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}

	private onToggleCollapse = (open) =>
	{
		const { CONTROL_VIEW_NAME } = this.props;
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
		});
	}

	private Load = async (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) =>
	{
		const { vwMain } = this.state;
		let d: any = {};
		if ( vwMain.results )
		{
			d.__total = vwMain.__total;
			d.results = vwMain.results.slice(nSKIP, nSKIP + nTOP);
		}
		return d;
	}

	public boundColumnFormatter = (cell, row, rowIndex, formatExtraData) =>
	{
		// 05/27/2018 Paul.  We will need all the layout fields in the render function. 
		let lay = formatExtraData.data.layout;
		// 03/27/2021 Paul.  Treat string as html. 
		return React.createElement(String, { layout: lay, row: row, multiLine: false, html: true });
	}

	private BootstrapColumns = (sLIST_MODULE_NAME, layout, sPRIMARY_MODULE, sPRIMARY_ID) =>
	{
		// 04/20/2017 Paul.  Build DataTables columns. 
		let arrDataTableColumns = [];
		let objDataColumn: any = {};
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

				let bIsReadable: boolean = true;
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
						formatter      : (this.splendidGrid.current != null ? this.boundColumnFormatter : null),
						sort           : (SORT_EXPRESSION != null),
						isDummyField   : false,
						formatExtraData: {
							data: {
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
		return arrDataTableColumns;
	}

	public render()
	{
		const { PARENT_TYPE, CONTROL_VIEW_NAME } = this.props;
		const { RELATED_MODULE, GRID_NAME, TABLE_NAME, SORT_FIELD, SORT_DIRECTION, PRIMARY_FIELD, PRIMARY_ID, error, showCancel, showFullForm, showTopButtons, showBottomButtons, showSearch, showInlineEdit, item, popupOpen, multiSelect, archiveView, open, customView, gridKey, subPanelVisible } = this.state;
		if ( SplendidCache.IsInitialized  )
		{
			Credentials.sUSER_THEME;
			let headerButtons = SubPanelButtonsFactory(SplendidCache.UserTheme);
			let MODULE_NAME      : string = RELATED_MODULE;
			let MODULE_TITLE     : string = 'InboundEmail.LBL_MAILBOX_DEFAULT';
			// 07/30/2021 Paul.  Load when the panel appears. 
			return (
				<React.Fragment>
					<Appear onAppearOnce={ (ioe) => this.setState({ subPanelVisible: true }) }>
						{ headerButtons
						? React.createElement(headerButtons, { MODULE_NAME, ID: null, MODULE_TITLE, CONTROL_VIEW_NAME, error, ButtonStyle: 'ListHeader', VIEW_NAME: GRID_NAME, row: item, Page_Command: this.Page_Command, showButtons: !showInlineEdit, onToggle: this.onToggleCollapse, isPrecompile: this.props.isPrecompile, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
						: null
						}
					</Appear>
					<Content pose={ open ? 'open' : 'closed' } style={ {overflow: (open ? 'visible' : 'hidden')} }>
						{ open && subPanelVisible
						? <div key={ 'Mailbox_' + gridKey.toString() }>
							<SplendidGrid
								MODULE_NAME={ PARENT_TYPE }
								RELATED_MODULE={ RELATED_MODULE }
								GRID_NAME={ GRID_NAME }
								TABLE_NAME={ TABLE_NAME }
								SORT_FIELD={ SORT_FIELD }
								SORT_DIRECTION={ SORT_DIRECTION }
								PRIMARY_FIELD={ PRIMARY_FIELD }
								PRIMARY_ID={ PRIMARY_ID }
								ADMIN_MODE={ false }
								cbCustomLoad={ this.Load }
								cbCustomColumns={ this.BootstrapColumns }
								deleteRelated={ false }
								archiveView={ archiveView }
								deferLoad={ false }
								disableView={ true }
								disableEdit={ true }
								disableRemove={ true }
								scrollable
								history={ this.props.history }
								location={ this.props.location }
								match={ this.props.match }
								ref={ this.splendidGrid }
							/>
						</div>
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

export default withRouter(Mailbox);
