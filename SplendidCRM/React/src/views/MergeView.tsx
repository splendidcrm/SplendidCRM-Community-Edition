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
import { observer }                                         from 'mobx-react'                             ;
// 2. Store and Types. 
import { EditComponent }                                    from '../types/EditComponent'                 ;
import { DetailComponent }                                  from '../types/DetailComponent'               ;
import ACL_FIELD_ACCESS                                     from '../types/ACL_FIELD_ACCESS'              ;
import EDITVIEWS_FIELD                                      from '../types/EDITVIEWS_FIELD'               ;
import DETAILVIEWS_FIELD                                    from '../types/DETAILVIEWS_FIELD'             ;
import { HeaderButtons }                                    from '../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                                  from '../scripts/Sql'                         ;
import L10n                                                 from '../scripts/L10n'                        ;
import Security                                             from '../scripts/Security'                    ;
import Credentials                                          from '../scripts/Credentials'                 ;
import SplendidCache                                        from '../scripts/SplendidCache'               ;
import SplendidDynamic_EditView                             from '../scripts/SplendidDynamic_EditView'    ;
import { Crm_Config, Crm_Modules, Crm_Users, Crm_Teams }    from '../scripts/Crm'                         ;
import { UpdateModule }                                     from '../scripts/ModuleUpdate'                ;
import { AuthenticatedMethod, LoginRedirect }               from '../scripts/Login'                       ;
import { EditView_LoadItem, EditView_LoadLayout, EditView_FindField }       from '../scripts/EditView'    ;
import { DetailView_LoadLayout, DetailView_FindField, ConvertToDetailView } from '../scripts/DetailView'  ;
// 4. Components and Views. 
import HeaderButtonsFactory                                 from '../ThemeComponents/HeaderButtonsFactory';
import ErrorComponent                                       from '../components/ErrorComponent'           ;
import DumpSQL                                              from '../components/DumpSQL'                  ;
// 5. EditView Components. 
import Edit_Blank                                           from '../EditComponents/Blank'                ;
import Edit_Header                                          from '../EditComponents/Header'               ;
import Edit_TextBox                                         from '../EditComponents/TextBox'              ;
import Edit_HtmlEditor                                      from '../EditComponents/HtmlEditor'           ;
import Edit_ZipCodePopup                                    from '../EditComponents/ZipCodePopup'         ;
import Edit_CheckBox                                        from '../EditComponents/CheckBox'             ;
import Edit_CheckBoxList                                    from '../EditComponents/CheckBoxList'         ;
import Edit_Label                                           from '../EditComponents/Label'                ;
import Edit_Hidden                                          from '../EditComponents/Hidden'               ;
import Edit_DatePicker                                      from '../EditComponents/DatePicker'           ;
import Edit_DateTimeEdit                                    from '../EditComponents/DateTimeEdit'         ;
import Edit_DateTimePicker                                  from '../EditComponents/DateTimePicker'       ;
import Edit_TimePicker                                      from '../EditComponents/TimePicker'           ;
import Edit_DateTimeNewRecord                               from '../EditComponents/DateTimeNewRecord'    ;
import Edit_DateRange                                       from '../EditComponents/DateRange'            ;
import Edit_ListBox                                         from '../EditComponents/ListBox'              ;
import Edit_ModuleAutoComplete                              from '../EditComponents/ModuleAutoComplete'   ;
import Edit_ModulePopup                                     from '../EditComponents/ModulePopup'          ;
import Edit_ChangeButton                                    from '../EditComponents/ChangeButton'         ;
import Edit_TeamSelect                                      from '../EditComponents/TeamSelect'           ;
import Edit_UserSelect                                      from '../EditComponents/UserSelect'           ;
import Edit_TagSelect                                       from '../EditComponents/TagSelect'            ;
import Edit_NAICSCodeSelect                                 from '../EditComponents/NAICSCodeSelect'      ;
import Edit_SplendidFile                                    from '../EditComponents/File'                 ;
import Edit_SplendidImage                                   from '../EditComponents/Image'                ;
import Edit_Picture                                         from '../EditComponents/Picture'              ;
import Edit_Password                                        from '../EditComponents/Password'             ;
import Edit_Radio                                           from '../EditComponents/Radio'                ;
import Edit_SplendidButton                                  from '../EditComponents/Button'               ;
import Edit_CRON                                            from '../EditComponents/CRON'                 ;
// 6. DetailtView Components. 
import Detail_Blank                                         from '../DetailComponents/Blank'              ;
import Detail_SplendidButton                                from '../DetailComponents/Button'             ;
import Detail_CheckBox                                      from '../DetailComponents/CheckBox'           ;
import Detail_SplendidFile                                  from '../DetailComponents/File'               ;
import Detail_Header                                        from '../DetailComponents/Header'             ;
import Detail_HyperLink                                     from '../DetailComponents/HyperLink'          ;
import Detail_IFrame                                        from '../DetailComponents/IFrame'             ;
import Detail_Image                                         from '../DetailComponents/Image'              ;
import Detail_JavaScript                                    from '../DetailComponents/JavaScript'         ;
import Detail_Line                                          from '../DetailComponents/Line'               ;
import Detail_ModuleLink                                    from '../DetailComponents/ModuleLink'         ;
import Detail_SplendidString                                from '../DetailComponents/String'             ;
import Detail_Tags                                          from '../DetailComponents/Tags'               ;
import Detail_TextBox                                       from '../DetailComponents/TextBox'            ;


interface IMergeViewProps extends RouteComponentProps<any>
{
	MODULE_NAME         : string;
	ID                  : string;
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IMergeViewState
{
	EDIT_NAME          : string;
	DETAIL_NAME        : string;
	arrID              : string[];
	PrimayID           : string;
	nRecordCount       : number;
	DifferentFields    : any;
	SimilarFields      : any;
	items              : any;
	editedItem         : any;
	dependents         : Record<string, Array<any>>;
	LAST_DATE_MODIFIED : Date;
	layoutEdit         : any;
	layoutDetail       : any;
	error              : any;
	__sql              : string;
}

@observer
class MergeView extends React.Component<IMergeViewProps, IMergeViewState>
{
	private _isMounted    : boolean = false;
	private themeURL      : string  = null;
	private legacyIcons   : boolean = false;
	private headerButtons = React.createRef<HeaderButtons>();
	private refMap        : Record<string, React.RefObject<EditComponent<any, any>>>;

	constructor(props: IMergeViewProps)
	{
		super(props);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', props);
		this.themeURL    = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/images/';
		this.legacyIcons = Crm_Config.ToBoolean('enable_legacy_icons');
		let EDIT_NAME    : string = props.MODULE_NAME + '.EditView'  ;
		let DETAIL_NAME  : string = props.MODULE_NAME + '.DetailView';
		let arrID        : string[] = [];
		if ( !Sql.IsEmptyString(this.props.ID) )
		{
			arrID = decodeURIComponent(Sql.ToString(this.props.ID)).split(',');
		}
		this.state =
		{
			EDIT_NAME         ,
			DETAIL_NAME       ,
			arrID             ,
			items             : null,
			editedItem        : {},
			dependents        : {},
			LAST_DATE_MODIFIED: null,
			layoutEdit        : null,
			layoutDetail      : null,
			PrimayID          : null,
			nRecordCount      : 0,
			DifferentFields   : {},
			SimilarFields     : {},
			error             : null,
			__sql             : null,
		};
	}

	async componentDidMount()
	{
		const { MODULE_NAME } = this.props;
		const { arrID } = this.state;
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
				document.title = L10n.Term(MODULE_NAME + ".LBL_LIST_FORM_TITLE");
				window.scroll(0, 0);

				await this.load();
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

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidUpdate(prevProps: IMergeViewProps)
	{
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		else
		{
			if ( this.props.onComponentComplete )
			{
				const { MODULE_NAME, ID } = this.props;
				const { items, layoutEdit, EDIT_NAME, error } = this.state;
				if ( layoutEdit != null && error == null )
				{
					if ( ID == null || items != null )
					{
						this.props.onComponentComplete(MODULE_NAME, null, EDIT_NAME, items);
					}
				}
			}
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private load = async () =>
	{
		const { MODULE_NAME } = this.props;
		const { EDIT_NAME, DETAIL_NAME, arrID } = this.state;
		try
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', arrID);
			let layoutEdit        : EDITVIEWS_FIELD[]   = EditView_LoadLayout  (EDIT_NAME  );
			let layoutDetail      : DETAILVIEWS_FIELD[] = DetailView_LoadLayout(DETAIL_NAME);
			let items             : any    = {};
			let PrimayID          : string = null;
			let nRecordCount      : number = arrID.length;
			let DifferentFields   : any    = {};
			let SimilarFields     : any    = {};
			let editedItem        : any    = {};
			let LAST_DATE_MODIFIED: Date   = null;

			// 10/07/2022 Paul.  Apply Teams and Assigned user configuration to layout. 
			this.ApplyEditViewConfiguration  (layoutEdit  );
			this.ApplyDetailViewConfiguration(layoutDetail);

			for ( let i: number = 0; i < arrID.length; i++ )
			{
				let sID: string = arrID[i];
				const d = await EditView_LoadItem(MODULE_NAME, sID);
				let item: any = d.results;
				items[sID] = item;
				if ( PrimayID == null )
					PrimayID = sID;
				if ( i == 0 )
				{
					editedItem = Sql.DeepCopy(item);
					LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
				}
			}
			for ( let sColumnName in editedItem )
			{
				let oPrimary: any = null;
				for ( let nRecordIndex: number = 0; nRecordIndex < arrID.length; nRecordIndex++ )
				{
					let sID: string = arrID[nRecordIndex];
					let rdr: any = items[sID];
					if ( nRecordIndex == 0 )
					{
						oPrimary = rdr[sColumnName];
					}
					// 11/14/2009 Paul.  When comparing two columns, it is best to do so as a string. 
					else if ( Sql.ToString(oPrimary) != Sql.ToString(rdr[sColumnName]) && !DifferentFields[sColumnName] )
						DifferentFields[sColumnName] = true;
				}
			}
			for ( let sColumnName in editedItem )
			{
				if ( !DifferentFields[sColumnName] )
					SimilarFields[sColumnName] = true;
			}

			this.setState(
			{
				items             ,
				editedItem        ,
				layoutEdit        ,
				layoutDetail      ,
				PrimayID          ,
				LAST_DATE_MODIFIED,
				nRecordCount      ,
				DifferentFields   ,
				SimilarFields     ,
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private ApplyEditViewConfiguration = (layout: EDITVIEWS_FIELD[]) =>
	{
		const { MODULE_NAME } = this.props;
		const { EDIT_NAME } = this.state;
		if ( layout != null )
		{
			let bEnableTeamManagement   : boolean = Crm_Config.enable_team_management();
			let bRequireTeamManagement  : boolean = Crm_Config.require_team_management();
			let bEnableDynamicTeams     : boolean = Crm_Config.enable_dynamic_teams();
			let bEnableDynamicAssignment: boolean = Crm_Config.enable_dynamic_assignment();
			let bRequireUserAssignment  : boolean = Crm_Config.require_user_assignment();
			let bEnableTaxLineItems     : boolean = Crm_Config.ToBoolean('Orders.TaxLineItems');
			for ( let nLayoutIndex: number = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
			{
				let lay: EDITVIEWS_FIELD = layout[nLayoutIndex];

				lay.DATA_LABEL = L10n.BuildTermName(MODULE_NAME, lay.DATA_FIELD);
				if ( lay.DATA_FIELD == 'TEAM_ID' || lay.DATA_FIELD == 'TEAM_SET_NAME' )
					lay.DATA_LABEL = 'Teams.LBL_TEAM';
				else if ( lay.DATA_FIELD == 'ASSIGNED_USER_ID' )
					lay.DATA_LABEL = '.LBL_ASSIGNED_TO';

				if ( ( lay.DATA_FIELD == 'TEAM_ID' || lay.DATA_FIELD == 'TEAM_SET_NAME') )
				{
					if ( !bEnableTeamManagement )
					{
						lay.FIELD_TYPE = 'Blank';
						// 10/24/2012 Paul.  Clear the label to prevent a term lookup. 
						lay.DATA_LABEL  = null;
						lay.DATA_FIELD  = null;
						lay.UI_REQUIRED = false;
					}
					else
					{
						if ( bEnableDynamicTeams )
						{
							// 08/31/2009 Paul.  Don't convert to TeamSelect inside a Search view or Popup view. 
							// 10/20/2017 Paul.  Don't convert MyPipelineBySalesStage. 
							if ( EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('.My') < 0 )
							{
								lay.DATA_LABEL     = '.LBL_TEAM_SET_NAME';
								lay.DATA_FIELD     = 'TEAM_SET_NAME';
								lay.FIELD_TYPE     = 'TeamSelect';
								lay.ONCLICK_SCRIPT = '';
							}
						}
						else
						{
							// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
							if ( lay.FIELD_TYPE == 'TeamSelect' )
							{
								lay.DATA_LABEL     = 'Teams.LBL_TEAM';
								lay.DATA_FIELD     = 'TEAM_ID';
								lay.DISPLAY_FIELD  = 'TEAM_NAME';
								lay.FIELD_TYPE     = 'ModulePopup';
								lay.MODULE_TYPE    = 'Teams';
								lay.ONCLICK_SCRIPT = '';
							}
						}
						// 11/25/2006 Paul.  Override the required flag with the system value. 
						// 01/01/2008 Paul.  If Team Management is not required, then let the admin decide. 
						// 97/06/2017 Paul.  Don't show required flag in search or popup. 
						// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
						// 06/19/2021 Paul.  WorkflowAlertShells does not require Team or User. 
						if ( bRequireTeamManagement && EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.MassUpdate') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('WorkflowAlertShells') < 0 )
						{
							lay.UI_REQUIRED = true;
						}
					}
				}
				// 12/02/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( (lay.DATA_FIELD == 'ASSIGNED_USER_ID' || lay.DATA_FIELD == 'ASSIGNED_SET_NAME') )
				{
					// 01/06/2018 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
					if ( bEnableDynamicAssignment && lay.DATA_FORMAT != "1" )
					{
						if ( EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('.My') < 0 )
						{
							lay.DATA_LABEL     = '.LBL_ASSIGNED_SET_NAME';
							lay.DATA_FIELD     = 'ASSIGNED_SET_NAME'     ;
							lay.FIELD_TYPE     = 'UserSelect'            ;
							lay.ONCLICK_SCRIPT = ''                      ;
						}
					}
					else
					{
						if ( lay.FIELD_TYPE == 'UserSelect' )
						{
							lay.DATA_LABEL     = '.LBL_ASSIGNED_TO';
							lay.DATA_FIELD     = 'ASSIGNED_USER_ID';
							lay.DISPLAY_FIELD  = 'ASSIGNED_TO_NAME';
							lay.FIELD_TYPE     = 'ModulePopup'     ;
							lay.MODULE_TYPE    = 'Users'           ;
							lay.ONCLICK_SCRIPT = ''                ;
						}
					}
					// 06/19/2021 Paul.  bRequireUserAssignment is the correct flag here, not bRequireTeamManagement, but also, same rules for not in Search, MassUpdate or Popup. 
					// 06/19/2021 Paul.  WorkflowAlertShells does not require Team or User. 
					// 06/08/2022 Paul.  layout.EDIT_NAME was incorrect. 
					if ( bRequireUserAssignment && EDIT_NAME.indexOf('.Search') < 0 && EDIT_NAME.indexOf('.MassUpdate') < 0 && EDIT_NAME.indexOf('.Popup') < 0 && EDIT_NAME.indexOf('WorkflowAlertShells') < 0 )
					{
						lay.UI_REQUIRED = true;
					}
				}
				// 04/04/2010 Paul.  Hide the Exchange Folder field if disabled for this module or user. 
				else if ( lay.DATA_FIELD == 'EXCHANGE_FOLDER' )
				{
					// 01/09/2021 Paul.  We need to hide the EXCHANGE_FOLDER field if the user does not have Exchange enabled. 
					if ( !Crm_Modules.ExchangeFolders(MODULE_NAME) || !Security.HasExchangeAlias() )
					{
						lay.FIELD_TYPE = 'Blank';
						lay.DATA_LABEL = '';
					}
				}
				// 12/13/2013 Paul.  Allow each product to have a default tax rate. 
				else if ( lay.DATA_FIELD == 'TAX_CLASS' )
				{
					if ( bEnableTaxLineItems )
					{
						// 07/22/2019 Paul.  Also correct these values in the ListBox component as changing the cache here will make no difference. 
						lay.DATA_LABEL = "ProductTemplates.LBL_TAXRATE_ID";
						lay.DATA_FIELD = "TAXRATE_ID";
						//CACHE_NAME = "TaxRates";
					}
				}
			}
		}
	}

	private ApplyDetailViewConfiguration = (layout: DETAILVIEWS_FIELD[]) =>
	{
		const { MODULE_NAME } = this.props;
		const { EDIT_NAME } = this.state;
		if ( layout != null )
		{
			let bEnableTeamManagement   : boolean = Crm_Config.enable_team_management();
			let bRequireTeamManagement  : boolean = Crm_Config.require_team_management();
			let bEnableDynamicTeams     : boolean = Crm_Config.enable_dynamic_teams();
			let bEnableDynamicAssignment: boolean = Crm_Config.enable_dynamic_assignment();
			let bRequireUserAssignment  : boolean = Crm_Config.require_user_assignment();
			let bEnableTaxLineItems     : boolean = Crm_Config.ToBoolean('Orders.TaxLineItems');
			for ( let nLayoutIndex: number = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
			{
				let lay: DETAILVIEWS_FIELD = layout[nLayoutIndex];

				lay.DATA_LABEL = L10n.BuildTermName(MODULE_NAME, lay.DATA_FIELD);
				if ( lay.DATA_FIELD == 'TEAM_ID' || lay.DATA_FIELD == 'TEAM_SET_NAME' )
					lay.DATA_LABEL = 'Teams.LBL_TEAM';
				else if ( lay.DATA_FIELD == 'ASSIGNED_USER_ID' )
					lay.DATA_LABEL = '.LBL_ASSIGNED_TO';

				if ( (lay.DATA_FIELD == 'TEAM_NAME' || lay.DATA_FIELD == 'TEAM_SET_NAME') )
				{
					if ( !bEnableTeamManagement )
					{
						lay.FIELD_TYPE = 'Blank';
					}
					else if ( bEnableDynamicTeams )
					{
						lay.DATA_LABEL = '.LBL_TEAM_SET_NAME';
						lay.DATA_FIELD = 'TEAM_SET_NAME'     ;
					}
				}
				// 10/08/2022 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( lay.DATA_FIELD == 'ASSIGNED_TO' || lay.DATA_FIELD == 'ASSIGNED_TO_NAME' || lay.DATA_FIELD == 'ASSIGNED_SET_NAME' )
				{
					// 12/17/2017 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
					// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
					if ( bEnableDynamicAssignment && !(lay.DATA_FORMAT.toLowerCase().indexOf('single') >= 0) )
					{
						lay.DATA_LABEL = '.LBL_ASSIGNED_SET_NAME';
						lay.DATA_FIELD = 'ASSIGNED_SET_NAME';
					}
					else if ( lay.DATA_FIELD == 'ASSIGNED_SET_NAME' )
					{
						lay.DATA_LABEL = '.LBL_ASSIGNED_TO';
						lay.DATA_FIELD = 'ASSIGNED_TO_NAME';
					}
				}
				// 10/08/2022 Paul.  Allow each product to have a default tax rate. 
				else if ( lay.DATA_FIELD == 'TAX_CLASS' )
				{
					if ( bEnableTaxLineItems )
					{
						lay.DATA_LABEL = 'ProductTemplates.LBL_TAXRATE_ID';
						lay.DATA_FIELD = 'TAXRATE_ID';
						lay.LIST_NAME  = 'TaxRates';
					}
				}
				// 04/04/2010 Paul.  Hide the Exchange Folder field if disabled for this module or user. 
				else if ( lay.DATA_FIELD == 'EXCHANGE_FOLDER' )
				{
					// 01/09/2021 Paul.  We need to hide the EXCHANGE_FOLDER field if the user does not have Exchange enabled. 
					if ( !Crm_Modules.ExchangeFolders(MODULE_NAME) || !Security.HasExchangeAlias() )
					{
						lay.FIELD_TYPE = 'Blank';
					}
				}
			}
		}
	}

	private AppendEditViewFieldsEdit = (lay: EDITVIEWS_FIELD, row: any, sFIELD_WIDTH: string) =>
	{
		const { MODULE_NAME } = this.props;
		const { EDIT_NAME } = this.state;
		const { refMap, createDependency, _onChange, onSubmit, onUpdate, Page_Command } = this;

		let isSearchView            : boolean = false;
		let fieldDidMount           : any     = null;
		let tdFieldChildren         : any[]   = [];
		let baseId                  : string  = 'ctlMergeView_' + EDIT_NAME.replace(/\./g, '_');

		let FIELD_TYPE              : string  = lay.FIELD_TYPE;
		let DATA_FIELD              : string  = lay.DATA_FIELD;
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		let bIsHidden               : boolean = lay.hidden;
		let bIsReadable             : boolean = true;
		let bIsWriteable            : boolean = true;
		if ( SplendidCache.bEnableACLFieldSecurity )
		{
			let gASSIGNED_USER_ID: string = null;
			if ( row != null )
			{
				gASSIGNED_USER_ID = Sql.ToGuid(row.ASSIGNED_USER_ID);
			}
			let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
			bIsReadable  = acl.IsReadable();
			// 02/16/2011 Paul.  We should allow a Read-Only field to be searchable, so always allow writing if the name contains Search. 
			bIsWriteable = acl.IsWriteable() || EDIT_NAME.indexOf(".Search") >= 0;
		}
		if ( !bIsReadable )
		{
			FIELD_TYPE = 'Blank';
		}
		
		let key = baseId + '_FieldIndex_' + lay.FIELD_INDEX;
		if ( !Sql.IsEmptyString(DATA_FIELD) )
		{
			if ( refMap[DATA_FIELD] == null )
			{
				key = DATA_FIELD;
			}
			else
			{
				console.warn((new Date()).toISOString() + ' ' + 'SplendidDynamic_EditView ' + EDIT_NAME + '.' + DATA_FIELD + ' already exists in refMap.');
			}
		}
		let ref = React.createRef<EditComponent<any, any>>();
		refMap[key] = ref;
		try
		{
			if ( FIELD_TYPE == 'Blank' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_Blank, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'Hidden' )
			{
				// 02/28/2008 Paul.  When the hidden field is the first in the row, we end up with a blank row. 
				// Just ignore for now as IE does not have a problem with the blank row. 
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_Hidden, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'ModuleAutoComplete' )
			{
				// 11/21/2021 Paul.  Use Page_Command to send AutoComplete selection event. 
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden, Page_Command };
				let txt = React.createElement(Edit_ModuleAutoComplete, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'ModulePopup' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden, isSearchView };
				// 12/13/2021 Paul.  The line item editor allows custom products, so don't clear name field if not found. 
				if ( DATA_FIELD == 'PRODUCT_TEMPLATE_ID' )
				{
					txtProps.allowCustomName = true;
				}
				let txt = React.createElement(Edit_ModulePopup, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'ChangeButton' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_ChangeButton, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'TeamSelect' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_TeamSelect, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'UserSelect' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_UserSelect, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'TagSelect' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_TagSelect, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'NAICSCodeSelect' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_NAICSCodeSelect, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'TextBox' )
			{
				// 11/02/2019 Paul.  layout changes are not detected, so we need to send the hidden field as a separate property. 
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_TextBox, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'HtmlEditor' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_HtmlEditor, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'ZipCodePopup' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_ZipCodePopup, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'DateRange' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_DateRange, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'DatePicker' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_DatePicker, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'DateTimeEdit' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_DateTimeEdit, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'DateTimeNewRecord' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_DateTimeNewRecord, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'DateTimePicker' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_DateTimePicker, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'TimePicker' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, onSubmit, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let txt = React.createElement(Edit_TimePicker, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'ListBox' )
			{
				let lstProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let lst = React.createElement(Edit_ListBox, lstProps);
				tdFieldChildren.push(lst);
			}
			else if ( FIELD_TYPE == 'CheckBoxList' )
			{
				let lstProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let lst = React.createElement(Edit_CheckBoxList, lstProps);
				tdFieldChildren.push(lst);
			}
			else if ( FIELD_TYPE == 'Radio' )
			{
				let chkProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let chk = React.createElement(Edit_Radio, chkProps);
				tdFieldChildren.push(chk);
			}
			else if ( FIELD_TYPE == 'CheckBox' )
			{
				let chkProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let chk = React.createElement(Edit_CheckBox, chkProps);
				tdFieldChildren.push(chk);
			}
			else if ( FIELD_TYPE == 'Label' )
			{
				let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let lbl = React.createElement(Edit_Label, lblProps);
				tdFieldChildren.push(lbl);
			}
			else if ( FIELD_TYPE == 'File' )
			{
				let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let lbl = React.createElement(Edit_SplendidFile, lblProps);
				tdFieldChildren.push(lbl);
			}
			else if ( FIELD_TYPE == 'Button' )
			{
				let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden, Page_Command };
				let lbl = React.createElement(Edit_SplendidButton, lblProps );
				tdFieldChildren.push( lbl );
			}
			else if ( FIELD_TYPE == 'Image' )
			{
				let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let lbl = React.createElement(Edit_SplendidImage, lblProps);
				tdFieldChildren.push(lbl);
			}
			else if ( FIELD_TYPE == 'Picture' )
			{
				let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let lbl = React.createElement(Edit_Picture, lblProps);
				tdFieldChildren.push(lbl);
			}
			else if ( FIELD_TYPE == 'Password' )
			{
				let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let lbl = React.createElement(Edit_Password, lblProps);
				tdFieldChildren.push(lbl);
			}
			else if ( FIELD_TYPE == 'CRON' )
			{
				let lblProps: any = { baseId, key, row, layout: lay, onChanged: _onChange, ref, createDependency, fieldDidMount, onUpdate, bIsWriteable, bIsHidden };
				let lbl = React.createElement(Edit_CRON, lblProps);
				tdFieldChildren.push(lbl);
			}
			else
			{
				console.warn((new Date()).toISOString() + ' ' + this.constructor.name + '.AppendEditViewFields() Unknown field type: ' + FIELD_TYPE);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.AppendEditViewFields ' + FIELD_TYPE + ' ' + DATA_FIELD, error);
		}
		let td: JSX.Element = React.createElement('td', { className: 'dataField', style: {vAlign: 'top', width: sFIELD_WIDTH} }, tdFieldChildren);
		return td;
	}

	private AppendEditViewFieldsReadOnly = (lay: DETAILVIEWS_FIELD, row: any, sFIELD_WIDTH: string) =>
	{
		const { DETAIL_NAME } = this.state;
		const { Page_Command } = this;
		
		let fieldDidMount           : any     = null;
		let tdFieldChildren         : any[]   = [];
		let baseId                  : string = 'ctlDetailView_' + DETAIL_NAME.replace(/\./g, '_') + '_' + row.ID;
		// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
		let ERASED_FIELDS           : string[] = [];
		if ( Crm_Config.enable_data_privacy() )
		{
			if ( row['ERASED_FIELDS'] !== undefined )
			{
				ERASED_FIELDS = Sql.ToString(row['ERASED_FIELDS']).split(',');
			}
		}
		try
		{
			let FIELD_TYPE  : string = Sql.ToString (lay.FIELD_TYPE  );
			let DATA_FIELD  : string = Sql.ToString (lay.DATA_FIELD  );
			let MODULE_NAME : string = Sql.ToString (lay.MODULE_NAME );
			// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
			let bIsHidden   : boolean = lay.hidden;
			let bIsReadable : boolean = true;
			// 06/16/2010 Paul.  sDATA_FIELD may be empty. 
			if ( SplendidCache.bEnableACLFieldSecurity && !Sql.IsEmptyString(DATA_FIELD) )
			{
				let gASSIGNED_USER_ID = null;
				if ( row != null )
				{
					gASSIGNED_USER_ID = Sql.ToGuid(row.ASSIGNED_USER_ID);
				}
				let acl: ACL_FIELD_ACCESS = ACL_FIELD_ACCESS.GetUserFieldSecurity(MODULE_NAME, DATA_FIELD, gASSIGNED_USER_ID);
				bIsReadable  = acl.IsReadable();
			}
			if ( !bIsReadable )
			{
				FIELD_TYPE = 'Blank';
			}
			let key = baseId + '_FieldIndex_' + lay.FIELD_INDEX;
			// 10/08/0222 Paul.  The ref will be thrown away. 
			let ref = React.createRef<DetailComponent<any, any>>();
			//refMap[key] = ref;
			if ( FIELD_TYPE == 'HyperLink' )
			{
				let lnkProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
				let lnk = React.createElement(Detail_HyperLink, lnkProps);
				tdFieldChildren.push(lnk);
			}
			// 01/10/2023 Paul.  Correct the field type name, it is not ModueLink. 
			else if ( FIELD_TYPE == 'ModuleLink' )
			{
				let lnkProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
				let lnk = React.createElement(Detail_ModuleLink, lnkProps);
				tdFieldChildren.push(lnk);
			}
			else if ( FIELD_TYPE == 'String' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
				let txt = React.createElement(Detail_SplendidString, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'TextBox' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
				let txt = React.createElement(Detail_TextBox, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'Image' )
			{
				let imgProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
				let img = React.createElement(Detail_Image, imgProps);
				tdFieldChildren.push(img);
			}
			else if ( FIELD_TYPE == 'File' )
			{
				let imgProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
				let img = React.createElement(Detail_SplendidFile, imgProps);
				tdFieldChildren.push(img);
			}
			else if ( FIELD_TYPE == 'CheckBox' )
			{
				let chkProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
				let chk = React.createElement(Detail_CheckBox, chkProps);
				tdFieldChildren.push(chk);
			}
			else if ( FIELD_TYPE == 'Blank' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
				let txt = React.createElement(Detail_Blank, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'Tags' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden };
				let txt = React.createElement(Detail_Tags, txtProps);
				tdFieldChildren.push(txt);
			}
			else if ( FIELD_TYPE == 'Button' )
			{
				let txtProps: any = { baseId, key, row, layout: lay, ref, fieldDidMount, ERASED_FIELDS, bIsHidden, Page_Command };
				let txt = React.createElement(Detail_SplendidButton, txtProps);
				tdFieldChildren.push(txt);
			}
			else
			{
				tdFieldChildren.push('Unsupported field type: ' + FIELD_TYPE);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.AppendDetailViewFields', error);
		}
		let td: JSX.Element = React.createElement('td', { className: 'dataField', style: {vAlign: 'top', width: sFIELD_WIDTH} }, tdFieldChildren );
		return td;
	}

	private onSetPrimaryRecord = (e: any, sID: string) =>
	{
		const { items } = this.state;
		let { arrID } = this.state;
		e.preventDefault();
		arrID.splice(arrID.indexOf(sID), 1);
		arrID.unshift(sID);
		let editedItem: any = Sql.DeepCopy(items[sID]);
		let LAST_DATE_MODIFIED: Date = editedItem['DATE_MODIFIED'];
		this.setState({ arrID, PrimayID: sID, editedItem, LAST_DATE_MODIFIED });
	}

	private onRemoveRecord = (e: any, sID: string) =>
	{
		let { arrID } = this.state;
		e.preventDefault();
		arrID.splice(arrID.indexOf(sID), 1);
		this.setState({ arrID });
	}

	private onCopyField = (e: any, sID: string, DATA_FIELD: string) =>
	{
		const { items, layoutEdit } = this.state;
		let { editedItem } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.onCopyField ' + DATA_FIELD, sID);
		e.preventDefault();
		editedItem[DATA_FIELD] = items[sID][DATA_FIELD];

		let lay: EDITVIEWS_FIELD = EditView_FindField(layoutEdit, DATA_FIELD);
		let ref = this.refMap[DATA_FIELD];
		if ( ref )
		{
			if ( lay != null )
			{
				switch ( lay.FIELD_TYPE )
				{
					case 'NAICSCodeSelect':
					{
						let selected : Array<{ DATA_VALUE: string, DISPLAY_VALUE: string, primary?: boolean }> = [];
						let sNAICS_SET_NAME = editedItem['NAICS_SET_NAME'];
						if ( !Sql.IsEmptyString(sNAICS_SET_NAME) )
						{
							let arrNAICS_SET_NAME = sNAICS_SET_NAME.split(',');
							for ( let i = 0; i < arrNAICS_SET_NAME.length; i++ )
							{
								let sNAICS_CODE_NAME = arrNAICS_SET_NAME[i];
								selected.push(
								{
									DATA_VALUE: sNAICS_CODE_NAME,
									DISPLAY_VALUE: sNAICS_CODE_NAME,
								});
							}
						}
						ref.current.updateDependancy(null, selected, 'value', editedItem);
						break;
					}
					case 'TagSelect':
					{
						let selected : Array<{ DATA_VALUE: string, DISPLAY_VALUE: string, primary?: boolean }> = [];
						let sTAG_SET_NAME = editedItem['TAG_SET_NAME'];
						if ( !Sql.IsEmptyString(sTAG_SET_NAME) )
						{
							let arrTAG_SET_NAME = sTAG_SET_NAME.split(',');
							for ( let i = 0; i < arrTAG_SET_NAME.length; i++ )
							{
								let sTAG_NAME = arrTAG_SET_NAME[i];
								selected.push(
								{
									DATA_VALUE: sTAG_NAME,
									DISPLAY_VALUE: sTAG_NAME,
								});
							}
						}
						ref.current.updateDependancy(null, selected, 'value', editedItem);
						break;
					}
					case 'TeamSelect':
					{
						editedItem['TEAM_SET_LIST'] = items[sID]['TEAM_SET_LIST'];
						
						let selected : Array<{ DATA_VALUE: string, DISPLAY_VALUE: string, primary?: boolean }> = [];
						let sTEAM_SET_LIST = editedItem['TEAM_SET_LIST'];
						if ( !Sql.IsEmptyString(sTEAM_SET_LIST) )
						{
							let arrTEAM_SET_LIST = sTEAM_SET_LIST.split(',');
							for ( let i = 0; i < arrTEAM_SET_LIST.length; i++ )
							{
								let sTEAM_ID = arrTEAM_SET_LIST[i];
								selected.push(
								{
									DATA_VALUE: sTEAM_ID,
									DISPLAY_VALUE: Crm_Teams.Name(sTEAM_ID),
									primary: (i == 0)
								});
							}
						}
						ref.current.updateDependancy(null, selected, 'value', editedItem);
						break;
					}
					case 'UserSelect':
					{
						editedItem['ASSIGNED_SET_LIST'] = items[sID]['ASSIGNED_SET_LIST'];
						
						let selected : Array<{ DATA_VALUE: string, DISPLAY_VALUE: string, primary?: boolean }> = [];
						let sASSIGNED_SET_LIST = editedItem['ASSIGNED_SET_LIST'];
						if ( !Sql.IsEmptyString(sASSIGNED_SET_LIST) )
						{
							let arrASSIGNED_SET_LIST = sASSIGNED_SET_LIST.split(',');
							for ( let i = 0; i < arrASSIGNED_SET_LIST.length; i++ )
							{
								let sASSIGNED_USER_ID = arrASSIGNED_SET_LIST[i];
								selected.push(
								{
									DATA_VALUE: sASSIGNED_USER_ID,
									DISPLAY_VALUE: Crm_Users.Name(sASSIGNED_USER_ID),
									primary: (i == 0)
								});
							}
						}
						ref.current.updateDependancy(null, selected, 'value', editedItem);
						break;
					}
					case 'ModulePopup':
					{
						if ( !Sql.IsEmptyString(lay.DISPLAY_FIELD) )
						{
							editedItem[lay.DISPLAY_FIELD] = items[sID][lay.DISPLAY_FIELD];
							ref.current.updateDependancy(null, editedItem[DATA_FIELD       ], 'ID'  , editedItem);
							ref.current.updateDependancy(null, editedItem[lay.DISPLAY_FIELD], 'NAME', editedItem);
						}
						break;
					}
					// 10/08/2022 Paul.  RelatedSelect does not appear to be supported. 
					// case 'RelatedSelect':  break;
					default:
					{
						ref.current.updateDependancy(null, editedItem[DATA_FIELD], 'value', editedItem);
						break;
					}
				}
			}
			else
			{
				ref.current.updateDependancy(null, editedItem[DATA_FIELD], 'value', editedItem);
			}
		}
		this.setState({ editedItem });
	}

	private AppendEditViewFields = (obIncludeFields) =>
	{
		const { arrID, nRecordCount, items, layoutDetail } = this.state;
		const layout: EDITVIEWS_FIELD[] = this.state.layoutEdit;
		let nFIELD_WIDTH = (100 - nRecordCount) / (nRecordCount + 1);
		let sFIELD_WIDTH = Sql.ToString(Math.round(nFIELD_WIDTH)) + "%";

		let arrTD = [];
		for ( let nRecordIndex: number = 0; nRecordIndex < arrID.length; nRecordIndex++ )
		{
			let sID: string = arrID[nRecordIndex];
			let tdLabelChildren: any[] = [];
			let tdLabel        : JSX.Element = React.createElement('td', {className: 'dataLabel', vAlign: 'top', width: '1%'}, tdLabelChildren);
			arrTD.push(tdLabel);
			let tdFieldChildren: any[] = [];
			let tdField        : JSX.Element = React.createElement('td', {className: 'dataField', vAlign: 'top', width: sFIELD_WIDTH}, tdFieldChildren );
			arrTD.push(tdField);
			if ( nRecordIndex == 0 )
			{
				tdFieldChildren.push(sID);
			}
			else
			{
				let lnkSetAsPrimaryProps: any = {};
				lnkSetAsPrimaryProps.href    = '#';
				lnkSetAsPrimaryProps.onClick = (e) => this.onSetPrimaryRecord(e, sID);
				let aSetAsPrimary: JSX.Element = React.createElement('a', lnkSetAsPrimaryProps, L10n.Term('Merge.LBL_CHANGE_PARENT') );
				tdFieldChildren.push(aSetAsPrimary);

				let litSeparator: JSX.Element  = React.createElement('span', {}, ' | ');
				tdFieldChildren.push(litSeparator);

				let lnkRemoveFromMergeProps: any = {};
				lnkRemoveFromMergeProps.href    = '#';
				lnkRemoveFromMergeProps.onClick = (e) => this.onRemoveRecord(e, sID);
				let aRemoveFromMerge: JSX.Element = React.createElement('a', lnkRemoveFromMergeProps, L10n.Term('Merge.LBL_REMOVE_FROM_MERGE') );
				tdFieldChildren.push(aRemoveFromMerge);
			}
		}
		let arrTR = [];
		let tr: JSX.Element = React.createElement('tr', {}, arrTD);
		arrTR.push(tr);
		for ( let nLayoutIndex: number = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
		{
			let lay: EDITVIEWS_FIELD = layout[nLayoutIndex];
			if ( lay.DATA_FIELD && obIncludeFields[lay.DATA_FIELD] )
			{
				arrTD = [];
				for ( let nRecordIndex: number = 0; nRecordIndex < arrID.length; nRecordIndex++ )
				{
					let sID: string = arrID[nRecordIndex];
					let rdr: any = items[sID];
					if ( nRecordIndex == 0 )
					{
						let tdLabelChildren: any[] = [];
						let tdLabel        : JSX.Element = React.createElement('td', {className: 'dataLabel', vAlign: 'top', width: sFIELD_WIDTH}, tdLabelChildren);
						arrTD.push(tdLabel);
						if ( !Sql.IsEmptyString(lay.DATA_LABEL) )
							tdLabelChildren.push(L10n.Term(lay.DATA_LABEL));
						let td: any = this.AppendEditViewFieldsEdit(lay, rdr, sFIELD_WIDTH);
						arrTD.push(td);
					}
					else
					{
						let tdLabelChildren: any[] = [];
						let tdLabel        : JSX.Element = React.createElement('td', {className: 'dataField', vAlign: 'top', width: '1%'}, tdLabelChildren);
						arrTD.push(tdLabel);
						
						if ( lay.FIELD_TYPE != 'Label' && lay.FIELD_TYPE != 'Button' && lay.FIELD_TYPE != 'Header' && lay.FIELD_TYPE != 'Separator' && lay.FIELD_TYPE != 'Blank' && lay.FIELD_TYPE != 'Hidden' )
						{
							let bntCopyFieldProps: any  = {};
							bntCopyFieldProps.id        = lay.DATA_FIELD + '_COPY_' + nRecordIndex.toString();
							bntCopyFieldProps.className = 'button';
							bntCopyFieldProps.onClick   = (e) => this.onCopyField(e, sID, lay.DATA_FIELD);
							let bntCopyField: JSX.Element = React.createElement('button', bntCopyFieldProps, "<<");
							tdLabelChildren.push(bntCopyField);
						}

						let layDetail: DETAILVIEWS_FIELD = DetailView_FindField(layoutDetail, lay.DATA_FIELD);
						if ( layDetail == null )
							layDetail = ConvertToDetailView(lay);
						if ( layDetail != null )
						{
							let td: any = this.AppendEditViewFieldsReadOnly(layDetail, rdr, sFIELD_WIDTH);
							arrTD.push(td);
						}
						else
						{
							let td: JSX.Element = React.createElement('td', { className: 'dataField', style: {vAlign: 'top', width: sFIELD_WIDTH} }, 'missing ' + lay.DATA_FIELD );
							arrTD.push(td);
						}
					}
				}
				let tr: JSX.Element = React.createElement('tr', {}, arrTD);
				arrTR.push(tr);
			}
		}
		return arrTR;
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { MODULE_NAME, history, location } = this.props;
		const { LAST_DATE_MODIFIED, arrID, PrimayID } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		// This sets the local state, which is then passed to DynamicButtons
		try
		{
			let row;
			switch (sCommandName)
			{
				case 'Save':
				case 'SaveDuplicate':
				case 'SaveConcurrency':
				{
					let isDuplicate = location.pathname.includes('Duplicate');
					row = {
						ID: PrimayID
					};
					// 08/27/2019 Paul.  Move build code to shared object. 
					let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
					if ( nInvalidFields == 0 )
					{
						if ( LAST_DATE_MODIFIED != null )
						{
							row['LAST_DATE_MODIFIED'] = LAST_DATE_MODIFIED;
						}
						if ( sCommandName == 'SaveDuplicate' || sCommandName == 'SaveConcurrency' )
						{
							row[sCommandName] = true;
						}
						try
						{
							if ( this.headerButtons.current != null )
							{
								this.headerButtons.current.Busy();
							}
							row.MergeIDs = Sql.DeepCopy(arrID);
							row.MergeIDs.splice(row.MergeIDs.indexOf(PrimayID), 1);
							row.ID = await UpdateModule(MODULE_NAME, row, row.ID);
							history.push(`/Reset/${MODULE_NAME}/View/` + row.ID);
						}
						catch(error)
						{
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
							if ( this.headerButtons.current != null )
							{
								this.headerButtons.current.NotBusy();
							}
							if ( this._isMounted )
							{
								if ( error.message.includes('.ERR_DUPLICATE_EXCEPTION') )
								{
									if ( this.headerButtons.current != null )
									{
										this.headerButtons.current.ShowButton('SaveDuplicate', true);
									}
									this.setState( {error: L10n.Term(error.message) } );
								}
								else if ( error.message.includes('.ERR_CONCURRENCY_OVERRIDE') )
								{
									if ( this.headerButtons.current != null )
									{
										this.headerButtons.current.ShowButton('SaveConcurrency', true);
									}
									this.setState( {error: L10n.Term(error.message) } );
								}
								else
								{
									this.setState({ error });
								}
							}
						}
					}
					break;
				}
				case 'Cancel':
				{
					history.push(`/Reset/${MODULE_NAME}/List`);
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
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}

	private _onChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE);
		let item = this.state.editedItem;
		if ( item == null )
			item = {};
		item[DATA_FIELD] = DATA_VALUE;
		if ( this._isMounted )
		{
			this.setState({ editedItem: item });
		}
	}

	private createDependency = (DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string): void =>
	{
		let { dependents } = this.state;
		if ( dependents[PARENT_FIELD] )
		{
			dependents[PARENT_FIELD].push( {DATA_FIELD, PROPERTY_NAME} );
		}
		else
		{
			dependents[PARENT_FIELD] = [ {DATA_FIELD, PROPERTY_NAME} ]
		}
		if ( this._isMounted )
		{
			this.setState({ dependents: dependents });
		}
	}

	private onUpdate = (PARENT_FIELD: string, DATA_VALUE: any, item?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate ' + PARENT_FIELD, DATA_VALUE);
		let { dependents } = this.state;
		if ( dependents[PARENT_FIELD] )
		{
			let dependentIds = dependents[PARENT_FIELD];
			for ( let i = 0; i < dependentIds.length; i++ )
			{
				let ref = this.refMap[dependentIds[i].DATA_FIELD];
				if ( ref )
				{
					ref.current.updateDependancy(PARENT_FIELD, DATA_VALUE, dependentIds[i].PROPERTY_NAME, item);
				}
			}
		}
	}

	private onSubmit = (): void =>
	{
		try
		{
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit', error);
			this.setState({ error });
		}
	}

	public render()
	{
		const { MODULE_NAME } = this.props;
		const { EDIT_NAME, layoutEdit, DifferentFields, SimilarFields, editedItem, error } = this.state;
		this.refMap = {};
		if ( SplendidCache.IsInitialized  )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', this.state.editedItem);
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let MODULE_TITLE  : string = L10n.Term('Merge.LBL_MERGE_RECORDS_WITH') + ': ' + Sql.ToString(editedItem['NAME']);
			if ( layoutEdit )
			{
				return (<React.Fragment>
					<div style={ {width: '100%'} }>
						<div id='divListView' style={ {width: '100%'} }>
							{ headerButtons
							? React.createElement(headerButtons, { MODULE_NAME, MODULE_TITLE, error, enableHelp: true, helpName: 'index', ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, Page_Command: this.Page_Command, showButtons: true, showProcess: false, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
							: null
							}
						</div>
						<div className='tabForm'>
							<span style={ {fontWeight: 'bold'} }>{ L10n.Term('Merge.LBL_DIFF_COL_VALUES') }</span>
							<table width="100%" cellPadding={ 0 } cellSpacing={ 1 } className='tabEditView'>
								{ this.AppendEditViewFields(DifferentFields) }
							</table>
						</div>
						<div className='tabForm'>
							<span style={ {fontWeight: 'bold'} }>{ L10n.Term('Merge.LBL_SAME_COL_VALUES') }</span>
							<table width="100%" cellPadding={ 0 } cellSpacing={ 1 } className='tabEditView'>
								{ this.AppendEditViewFields(SimilarFields) }
							</table>
						</div>
					</div>
				</React.Fragment>);
			}
			else
			{
				return null;
			}
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

export default withRouter(MergeView);
