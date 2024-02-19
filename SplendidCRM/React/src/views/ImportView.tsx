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
import { RouteComponentProps, withRouter }            from '../Router5'                             ;
import { FontAwesomeIcon }                            from '@fortawesome/react-fontawesome'         ;
import { Modal, Tabs, Tab, NavDropdown }              from 'react-bootstrap'                        ;
import { observer }                                   from 'mobx-react'                             ;
import { XMLParser, XMLBuilder }                      from 'fast-xml-parser'                        ;
import qs                                             from 'query-string'                           ;
// 2. Store and Types. 
import ACL_FIELD_ACCESS                               from '../types/ACL_FIELD_ACCESS'              ;
import { EditComponent }                              from '../types/EditComponent'                 ;
import { HeaderButtons }                              from '../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                            from '../scripts/Sql'                         ;
import L10n                                           from '../scripts/L10n'                        ;
import Security                                       from '../scripts/Security'                    ;
import Credentials                                    from '../scripts/Credentials'                 ;
import SplendidCache                                  from '../scripts/SplendidCache'               ;
import SplendidDynamic                                from '../scripts/SplendidDynamic'             ;
import { Crm_Config, Crm_Modules }                    from '../scripts/Crm'                         ;
import { dumpObj, base64ArrayBuffer, uuidFast, Trim, StartsWith } from '../scripts/utility'         ;
import SplendidDynamic_EditView                       from '../scripts/SplendidDynamic_EditView'    ;
import { EditView_LoadLayout, EditView_FindField }    from '../scripts/EditView'                    ;
import { AuthenticatedMethod, LoginRedirect }         from '../scripts/Login'                       ;
import { CreateSplendidRequest, GetSplendidResult }   from '../scripts/SplendidRequest'             ;
// 4. Components and Views. 
import NavItem                                        from '../components/NavItem'                  ;
import ListHeader                                     from '../components/ListHeader'               ;
import SplendidGrid                                   from '../components/SplendidGrid'             ;
import HeaderButtonsFactory                           from '../ThemeComponents/HeaderButtonsFactory';
import RuleBuilder                                    from '../ModuleViews/RulesWizard/RuleBuilder' ;

// 05/07/2021 Paul.  Disable debug. 
let bDebug: boolean = false;

interface IImportViewProps extends RouteComponentProps<any>
{
	MODULE_NAME          : string;
}

interface IImportViewState
{
	activeTab            : string;
	isProcessing         : boolean;
	disableImportNumbers : boolean;

	PROSPECT_LIST_ID     : string;
	ID                   : string;
	ASSIGNED_USER_ID     : string;
	NAME                 : string;
	SOURCE               : string;
	CUSTOM_DELIMITER_VAL : string;
	HAS_HEADER           : boolean;
	IS_PUBLISHED         : boolean;
	CONTENT              : string;
	RULES_XML            : string;
	USE_TRANSACTION      : boolean;

	bLinkedIn            : boolean;
	bTwitter             : boolean;
	bFacebook            : boolean;
	bSalesforce          : boolean;
	bQuickBooks          : boolean;
	bQuickBooksOnline    : boolean;
	bHubSpot             : boolean;

	importColumns        : any[];
	displayColumns       : any[];
	importMap            : any;
	importMapJson        : string;

	NAME_REQUIRED        : boolean;
	item                 : any;
	layout               : any;
	editedItem           : any;
	dependents           : Record<string, Array<any>>;

	PATH_NAME            : string;
	FILENAME             : string;
	FILE_EXT             : string;
	FILE_MIME_TYPE       : string;
	FILE_DATA            : string;
	TempFileID?          : string;
	xmlSample?           : any;
	xmlSampleJson?       : string;
	TempSampleID?        : string;

	DUP_LEFT_SELECTED    : string[];
	DUP_LEFT_LIST        : string[];
	DUP_RIGHT_SELECTED   : string[];

	IMPORT_STATUS?       : string;
	IMPORT_SUCCESS?      : string;
	IMPORT_DUPLICATE?    : string;
	IMPORT_FAILED?       : string;
	IMPORT_FAILED_COUNT? : number;
	ProcessedFileID?     : string;
	layoutProcessedList? : any[];

	error?               : any;
}

@observer
class ImportView extends React.Component<IImportViewProps, IImportViewState>
{
	private _isMounted   : boolean = false;
	private themeURL     : string;
	private refMap       : Record<string, React.RefObject<EditComponent<any, any>>>;
	private headerButtons = React.createRef<HeaderButtons>();
	private splendidGrid = React.createRef<SplendidGrid>();
	private previewGrid  = React.createRef<SplendidGrid>();
	private ruleBuilder  = React.createRef<RuleBuilder>();

	constructor(props: IImportViewProps)
	{
		super(props);
		Credentials.SetViewMode('ImportView');
		this.themeURL = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/';

		let PROSPECT_LIST_ID: string = null;
		let queryParams: any = qs.parse(location.search);
		if ( !Sql.IsEmptyGuid(queryParams['PROSPECT_LIST_ID']) )
		{
			PROSPECT_LIST_ID = queryParams['PROSPECT_LIST_ID'];
		}
		// 10/29/2020 Paul.  A customer wants to be able to hide the numbers on the tabs. 
		let disableImportNumbers: boolean = Crm_Config.ToBoolean('disable_import_numbers');

		this.state =
		{
			activeTab              : 'SelectSource',
			isProcessing           : false         ,
			disableImportNumbers   ,

			PROSPECT_LIST_ID       ,
			ID                     : null          ,
			ASSIGNED_USER_ID       : Security.USER_ID(),
			NAME                   : null          ,
			SOURCE                 : 'excel'       ,
			CUSTOM_DELIMITER_VAL   : null          ,
			HAS_HEADER             : true          ,
			IS_PUBLISHED           : null          ,
			CONTENT                : null          ,
			RULES_XML              : null          ,
			USE_TRANSACTION        : true          ,

			bLinkedIn              : false         ,
			bTwitter               : false         ,
			bFacebook              : false         ,
			bSalesforce            : false         ,
			bQuickBooks            : false         ,
			bQuickBooksOnline      : false         ,
			bHubSpot               : false         ,

			importColumns          : []            ,
			displayColumns         : []            ,
			importMap              : {}            ,
			importMapJson          : null          ,

			NAME_REQUIRED          : false         ,
			item                   : null          ,
			layout                 : null          ,
			editedItem             : null          ,
			dependents             : {}            ,

			PATH_NAME              : null          ,
			FILENAME               : null          ,
			FILE_EXT               : null          ,
			FILE_MIME_TYPE         : null          ,
			FILE_DATA              : null          ,

			DUP_LEFT_SELECTED      : []            ,
			DUP_LEFT_LIST          : []            ,
			DUP_RIGHT_SELECTED     : []            ,

			error                  : null          ,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		const { MODULE_NAME } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount');
		this._isMounted = true;
		try
		{
			// 07/05/2020 Paul.  We need to make sure that the Users module is treated as an admin module. 
			let module = SplendidCache.Module(this.props.MODULE_NAME, 'ImportView.componentDidMount');
			if ( module != null )
			{
				if ( module.IS_ADMIN )
				{
					// 11/11/2020 Paul.  We have added a route for Admin modules, so force only if necessary. 
					if ( this.props.location.pathname.indexOf('/Administration') < 0 )
					{
						this.props.history.push('/Reload/Administration' + this.props.location.pathname + this.props.location.search);
						return;
					}
				}
			}
			
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				document.title = L10n.Term(MODULE_NAME + '.LBL_LIST_FORM_TITLE');
				window.scroll(0, 0);
				let d = await this.GetImportSettings();
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', d);
				let bLinkedIn        : boolean = d.LinkedIn        ;
				let bTwitter         : boolean = d.Twitter         ;
				let bFacebook        : boolean = d.Facebook        ;
				let bSalesforce      : boolean = d.Salesforce      ;
				let bQuickBooks      : boolean = d.QuickBooks      ;
				let bQuickBooksOnline: boolean = d.QuickBooksOnline;
				let bHubSpot         : boolean = d.HubSpot         ;
				let importColumns    : any[]   = d.importColumns   ;
				let displayColumns   : any[]   = d.displayColumns  ;
				// 08/13/2020 Paul.  Allow a separate import layout. 
				let layout           : any[]   = EditView_LoadLayout(MODULE_NAME + '.EditView.Import', true);
				if ( layout == null )
				{
					layout = EditView_LoadLayout(MODULE_NAME + '.EditView');
				}

				let importMap        : any     = this.InitMapping(d.importColumns, layout);
				let importMapJson    : string  = dumpObj(importMap, 'importMap').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
				this.setState(
				{
					bLinkedIn        ,
					bTwitter         ,
					bFacebook        ,
					bSalesforce      ,
					bQuickBooks      ,
					bQuickBooksOnline,
					bHubSpot         ,
					importColumns    ,
					displayColumns   ,
					importMap        ,
					importMapJson    ,
					layout           ,
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

	async componentDidUpdate(prevProps: IImportViewProps)
	{
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private InitMapping = (importColumns: any[], layout: any[]) =>
	{
		let importMap: any = {};
		importMap.Import              = {};
		importMap.Import.Module       = this.props.MODULE_NAME;
		importMap.Import.SourceType   = this.state.SOURCE;
		importMap.Import.HasHeader    = true;
		importMap.Import.Fields       = {};
		importMap.Import.Fields.Field = [];

		let bEnableTeamManagement   : boolean = Crm_Config.enable_team_management();
		let bEnableDynamicTeams     : boolean = Crm_Config.enable_dynamic_teams();
		let bEnableDynamicAssignment: boolean = Crm_Config.enable_dynamic_assignment();
		if ( importColumns && importColumns.length > 0 )
		{
			for ( let i: number = 0; i < importColumns.length; i++ )
			{
				let field: any = {};
				field.Name            = importColumns[i].NAME      ;
				field.Type            = importColumns[i].ColumnType;
				field.Length          = importColumns[i].Size      ;
				field.Default         = null                 ;
				field.Mapping         = null                 ;
				field.DuplicateFilter = false                ;
				// 01/09/2021 Paul.  Only initialize field that is used in the default layout. 
				// 01/09/2021 Paul.  Set boolean values so that the import fields match ASP.Net import fields. 
				// 01/09/2021 Paul.  Only initialize field that is used in the default layout. 
				// 06/21/2021 Paul.  Boolean type can be bool.  Custom fields seem to use bool, but primary fields use Boolean. 
				if ( (field.Type == 'Boolean' || field.Type == 'bool') && EditView_FindField(layout, field.Name) != null )
				{
					// 01/09/2021 Paul.  We need to hide the EXCHANGE_FOLDER field if the user does not have Exchange enabled. 
					if ( field.Name == 'EXCHANGE_FOLDER' )
					{
						if ( Crm_Modules.ExchangeFolders(this.props.MODULE_NAME) && Security.HasExchangeAlias() )
						{
							field.Default = false;
						}
					}
					else
					{
						field.Default = false;
					}
				}
				// 01/09/2021 Paul.  Only initialize field that is used in the default layout. 
				switch ( field.Name )
				{
					case 'ASSIGNED_USER_ID' :
						if ( EditView_FindField(layout, 'ASSIGNED_USER_ID') != null || EditView_FindField(layout, 'ASSIGNED_SET_ID') != null )
							field.Default = Security.USER_ID()  ;
						break;
					case 'ASSIGNED_TO'      :
						if ( EditView_FindField(layout, field.Name) != null || EditView_FindField(layout, 'ASSIGNED_USER_ID') != null || EditView_FindField(layout, 'ASSIGNED_SET_ID') != null )
							field.Default = Security.USER_NAME();
						break;
					case 'ASSIGNED_TO_NAME' :
						if ( EditView_FindField(layout, field.Name) != null )
							field.Default = Security.FULL_NAME();
						break;
					case 'ASSIGNED_SET_LIST':
						// 01/09/2021 Paul.  Don't set the dynamic value unless used to match the ASP.Net import fields. 
						if ( bEnableDynamicAssignment && (EditView_FindField(layout, 'ASSIGNED_USER_ID') != null || EditView_FindField(layout, 'ASSIGNED_SET_ID') != null) )
							field.Default = Security.USER_ID()  ;
						break;
					case 'TEAM_ID'          :
						if ( bEnableTeamManagement && (EditView_FindField(layout, 'TEAM_ID') != null || EditView_FindField(layout, 'TEAM_SET_ID') != null) )
							field.Default = Security.TEAM_ID()  ;
						break;
					case 'TEAM_NAME'        :
						if ( bEnableTeamManagement && (EditView_FindField(layout, field.Name) != null || EditView_FindField(layout, 'TEAM_ID') != null || EditView_FindField(layout, 'TEAM_SET_ID') != null) )
							field.Default = Security.TEAM_NAME();
						break;
					case 'TEAM_SET_LIST'    :
						// 01/09/2021 Paul.  Don't set the dynamic value unless used to match the ASP.Net import fields. 
						if ( bEnableTeamManagement && bEnableDynamicTeams && (EditView_FindField(layout, 'TEAM_ID') != null || EditView_FindField(layout, 'TEAM_SET_ID') != null) )
							field.Default = Security.TEAM_ID()  ;
						break;
				}
				importMap.Import.Fields.Field.push(field);
			}
		}
		return importMap;
	}

	private LoadItem = async (ID: string) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', ID);
		try
		{
			this.setState({ isProcessing: true });
			
			let res  = await CreateSplendidRequest('Import/Rest.svc/GetImportItem?ImportModule=' + this.props.MODULE_NAME + '&ID=' + ID, 'GET');
			let json = await GetSplendidResult(res);
			let options: any = 
			{
				attributeNamePrefix: ''     ,
				// 02/18/2024 Paul.  parser v4 does not have an issue with node name as there is no value tag. 
				//<Import Name="Contacts Import 4">
				//	<Module>Leads</Module>
				//	<SourceType>excel</SourceType>
				//	<HasHeader>True</HasHeader>
				//	<Fields>
				//		<Field Name="ID">
				//			<Type>Guid</Type>
				//			<Length>0</Length>
				//			<Default>
				//			</Default>
				//			<Mapping>ImportField000</Mapping>
				//			<DuplicateFilter>False</DuplicateFilter>
				//		</Field>
				//	</Fields>
				//</Import>
				textNodeName       : 'Value',
				ignoreAttributes   : false  ,
				ignoreNameSpace    : true   ,
				parseAttributeValue: true   ,
				trimValues         : false  ,
			};
			// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
			const parser = new XMLParser(options);

			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback', json.d.results);
			let ASSIGNED_USER_ID    : string  = Sql.ToString (json.d.results.ASSIGNED_USER_ID    );
			let NAME                : string  = Sql.ToString (json.d.results.NAME                );
			let SOURCE              : string  = Sql.ToString (json.d.results.SOURCE              );
			let CUSTOM_DELIMITER_VAL: string  = Sql.ToString (json.d.results.CUSTOM_DELIMITER_VAL);
			let HAS_HEADER          : boolean = Sql.ToBoolean(json.d.results.HAS_HEADER          );
			let IS_PUBLISHED        : boolean = Sql.ToBoolean(json.d.results.IS_PUBLISHED        );
			let CONTENT             : string  = Sql.ToString (json.d.results.CONTENT             );
			let RULES_XML           : string  = Sql.ToString (json.d.results.RULES_XML           );
			let TempSampleID        : string  = Sql.ToString (json.d.results.TempSampleID        );

			let DUP_LEFT_LIST       : string[] = [];
			let item                : any     = {};
			let importMap           : any     = null;
			let importMapJson       : string  = null;
			let xmlSample           : any     = null;
			let xmlSampleJson       : string  = null;
			if ( !Sql.IsEmptyString(json.d.results.CONTENT) )
			{
				// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
				importMap     = parser.parse(json.d.results.CONTENT)
				// 05/20/2020 Paul.  A single record will not come in as an array, so convert to an array. 
				if ( importMap.Import && importMap.Import.Fields && !Array.isArray(importMap.Import.Fields.Field) )
				{
					let field: any = importMap.Import.Fields.Field;
					importMap.Import.Fields.Field = [];
					importMap.Import.Fields.Field.push(field);
				}
				if ( importMap.Import && importMap.Import.xmlSample )
				{
					xmlSample = importMap.Import.xmlSample;
					if ( xmlSample != null )
					{
						xmlSampleJson = dumpObj(xmlSample, 'xmlSample').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
					}
				}
				
				importMapJson = dumpObj(importMap, 'importMap').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
				if ( importMap.Import && importMap.Import.Fields && Array.isArray(importMap.Import.Fields.Field) )
				{
					let arrFields: any[] = importMap.Import.Fields.Field;
					for ( let i: number = 0; i < arrFields.length; i++ )
					{
						if ( arrFields[i].Name )
						{
							if ( !Sql.IsEmptyString(arrFields[i].Default) )
							{
								item[arrFields[i].Name] = arrFields[i].Default;
							}
							if ( Sql.ToBoolean(arrFields[i].DuplicateFilter) )
							{
								DUP_LEFT_LIST.push(arrFields[i].Name);
							}
						}
					}
				}
			}
			// 11/11/2020 Paul.  After selecting a mapping, move to UploadFile tab. 
			this.setState(
			{
				activeTab              : 'UploadFile',
				isProcessing           : false,

				ID                     ,
				ASSIGNED_USER_ID       ,
				NAME                   ,
				SOURCE                 ,
				CUSTOM_DELIMITER_VAL   ,
				HAS_HEADER             ,
				IS_PUBLISHED           ,
				CONTENT                ,
				RULES_XML              ,
				USE_TRANSACTION        : true,

				importMap              ,
				importMapJson          ,
				item                   ,

				PATH_NAME              : '',
				FILENAME               : '',
				FILE_EXT               : '',
				FILE_MIME_TYPE         : '',
				FILE_DATA              : '',
				TempFileID             : '',
				xmlSample              ,
				xmlSampleJson          ,
				TempSampleID           ,

				DUP_LEFT_SELECTED      : []   ,
				DUP_LEFT_LIST          ,
				DUP_RIGHT_SELECTED     : []   ,
			});
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
			this.setState({ error, isProcessing: false });
		};
	}

	private GetImportSettings = async () =>
	{
		const { MODULE_NAME } = this.props;
		let res  = await CreateSplendidRequest('Import/Rest.svc/GetImportSettings?ImportModule=' + MODULE_NAME, 'GET');
		let json = await GetSplendidResult(res);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.GetImportSettings', json);
		return json.d;
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { MODULE_NAME, history } = this.props;
		const { PROSPECT_LIST_ID, ASSIGNED_USER_ID, NAME, SOURCE, CUSTOM_DELIMITER_VAL, HAS_HEADER, IS_PUBLISHED, USE_TRANSACTION, importMap, importColumns, TempFileID, TempSampleID } = this.state;
		let { ID } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		try
		{
			if ( sCommandName == 'Import.Save' )
			{
				if ( !Credentials.ValidateCredentials )
				{
					throw new Error('Invalid connection information.');
				}
				else if ( Sql.IsEmptyString(NAME) )
				{
					this.setState({ NAME_REQUIRED: true });
				}
				else
				{
					let row: any = this.ruleBuilder.current.data;
					row.ImportModule         = Sql.ToString (MODULE_NAME         );
					row.ID                   = Sql.ToString (ID                  );
					row.ASSIGNED_USER_ID     = Sql.ToString (ASSIGNED_USER_ID    );
					row.NAME                 = Sql.ToString (NAME                );
					row.SOURCE               = Sql.ToString (SOURCE              );
					row.CUSTOM_DELIMITER_VAL = Sql.ToString (CUSTOM_DELIMITER_VAL);
					row.HAS_HEADER           = Sql.ToBoolean(HAS_HEADER          );
					row.IS_PUBLISHED         = Sql.ToBoolean(IS_PUBLISHED        );
					row.importMap            =               importMap            ;
					row.TempSampleID         = Sql.ToString (TempSampleID        );
					
					// 05/19/2020 Paul.  We are going to set the default value inside _onChange so that Json gets updated. 
					/* 
					let currentItem: any = {};
					SplendidDynamic_EditView.BuildDataRow(currentItem, this.refMap);
					if ( row.importMap.Import && row.importMap.Import.Fields && row.importMap.Import.Fields.Field )
					{
						for ( let i: number = 0; i < row.importMap.Import.Fields.Field.length; i++ )
						{
							let field: any = row.importMap.Import.Fields.Field[i];
							field.Default = (currentItem[field.Name] ? currentItem[field.Name] : null);
						}
					}
					this.UpdateDuplicateFilter(row.importMap, this.state.DUP_LEFT_LIST);
					*/
					
					let sBody = JSON.stringify(row);
					let res  = await CreateSplendidRequest('Import/Rest.svc/UpdateImportMap', 'POST', 'application/octet-stream', sBody);
					let json = await GetSplendidResult(res);
					ID = json.d;
					this.setState({ ID, NAME_REQUIRED: false, error: null });
					// 12/16/2020 Paul.  Update list after save. 
					if ( this.splendidGrid.current != null )
					{
						this.splendidGrid.current.Search(null, null);
					}
				}
			}
			else if ( sCommandName == "Import.Run" || sCommandName == "Import.Preview" )
			{
				if ( !Credentials.ValidateCredentials )
				{
					throw new Error('Invalid connection information.');
				}
				else if ( Sql.IsEmptyString(TempFileID) )
				{
					this.setState({ activeTab: 'UploadFile', error: L10n.Term('Import.LBL_NOTHING') });
				}
				else
				{
					let sMissing: string = this.ValidateMappings();
					if ( !Sql.IsEmptyString(sMissing) )
					{
						this.setState({ activeTab: 'MapFields', error:sMissing });
					}
					else
					{
						this.setState({ ProcessedFileID: null, isProcessing: true, error: null });
				
						let row: any = this.ruleBuilder.current.data;
						row.ImportModule         = Sql.ToString (MODULE_NAME         );
						row.PROSPECT_LIST_ID     =               PROSPECT_LIST_ID     ;
						row.ID                   = Sql.ToString (ID                  );
						row.ASSIGNED_USER_ID     = Sql.ToString (ASSIGNED_USER_ID    );
						row.NAME                 = Sql.ToString (NAME                );
						row.SOURCE               = Sql.ToString (SOURCE              );
						row.CUSTOM_DELIMITER_VAL = Sql.ToString (CUSTOM_DELIMITER_VAL);
						row.HAS_HEADER           = Sql.ToBoolean(HAS_HEADER          );
						row.USE_TRANSACTION      = Sql.ToBoolean(USE_TRANSACTION     );
						row.importMap            =               importMap            ;
						row.TempFileID           = Sql.ToString (TempFileID          );
						row.Preview              = (sCommandName == "Import.Preview" );
						
						let sBody = JSON.stringify(row);
						let res  = await CreateSplendidRequest('Import/Rest.svc/RunImport', 'POST', 'application/octet-stream', sBody);
						let json = await GetSplendidResult(res);
						// 05/24/2020 Paul.  The response has leading spaces as a means to keep the connection open, so we get the responseText back and we need to trim it. 
						if ( typeof(json) == 'string' )
						{
							let responseText: string = Trim(json);
							if ( StartsWith(responseText, '{') )
							{
								json = JSON.parse(responseText);
								if ( json !== undefined && json != null )
								{
									if ( json.ExceptionDetail !== undefined )
									{
										console.error(json.ExceptionDetail.Message);
										throw new Error(json.ExceptionDetail.Message);
									}
								}
							}
						}
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command', json);
						if ( !json.d )
						{
							console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command', json);
							throw new Error('Response did not include json.d');
						}
						
						let error              : string   = json.d.Errors;
						let IMPORT_STATUS      : string   = json.d.Status;
						let IMPORT_SUCCESS     : string   = json.d.Imported   + ' ' + L10n.Term('Import.LBL_SUCCESSFULLY'      );
						let IMPORT_DUPLICATE   : string   = json.d.Duplicates + ' ' + L10n.Term('Import.LBL_DUPLICATES_IGNORED');
						let IMPORT_FAILED      : string   = json.d.Failed     + ' ' + L10n.Term('Import.LBL_FAILED_IMPORT'     );
						let IMPORT_FAILED_COUNT: number   = json.d.Failed;
						let ProcessedFileID    : string   = json.d.ProcessedFileID;
						let processedColumns   : string[] = json.d.processedColumns;
						let layoutProcessedList: any[]  = [];
						if ( importColumns )
						{
							// 03/17/2021 Paul.  Attempt to order the columns based on input file. 
							let dictAddedColumns = {};
							// 03/16/2021 Paul.  first two columns are import status.
							for ( let i: number = 0; i < processedColumns.length && i < 2; i++ )
							{
								let column: any = processedColumns[i];
								if ( !dictAddedColumns[column.NAME] )
								{
									let lay: any = {};
									lay.COLUMN_INDEX               = i                  ;
									lay.COLUMN_TYPE                = 'BoundColumn'      ;
									lay.DATA_FORMAT                = null               ;
									lay.ITEMSTYLE_WIDTH            = null               ;
									lay.ITEMSTYLE_HORIZONTAL_ALIGN = null               ;
									lay.ITEMSTYLE_VERTICAL_ALIGN   = null               ;
									lay.ITEMSTYLE_WRAP             = true               ;
									lay.HEADER_TEXT                = column.DISPLAY_NAME;
									lay.DATA_FIELD                 = column.NAME        ;
									lay.SORT_EXPRESSION            = column.NAME        ;
									layoutProcessedList.push(lay);
									if ( column.ColumnType == 'DateTime' )
									{
										lay.DATA_FORMAT = column.ColumnType;
									}
									// 11/10/2020 Paul.  Make sure to format as an integer instead of decimal. 
									if ( column.NAME == 'IMPORT_ROW_NUMBER' )
									{
										lay.DATA_FORMAT = '{0:N0}';
									}
									dictAddedColumns[column.NAME] = true;
								}
							}
							if ( importMap.Import && importMap.Import.Fields && importMap.Import.Fields.Field )
							{
								// 03/16/2021 Paul.  First build an array of import fields matching the order in the import file. 
								let importFields = Array(importMap.Import.Fields.Field.length).fill(null);
								for ( let j: number = 0; j < importMap.Import.Fields.Field.length; j++ )
								{
									let field: any = importMap.Import.Fields.Field[j];
									if ( !Sql.IsEmptyString(field.Mapping) )
									{
										let k: number = Sql.ToInteger(field.Mapping.substring(11));
										importFields[k] = field.Name;
									}
								}
								// 03/16/2021 Paul.  Then add based in imoprt field order. 
								for ( let j: number = 0; j < importFields.length; j++ )
								{
									if ( !Sql.IsEmptyString(importFields[j]) && !dictAddedColumns[importFields[j]] )
									{
										for ( let i: number = 0; i < processedColumns.length; i++ )
										{
											let column: any = processedColumns[i];
											if ( column.NAME == importFields[j])
											{
												let lay: any = {};
												lay.COLUMN_INDEX               = i                  ;
												lay.COLUMN_TYPE                = 'BoundColumn'      ;
												lay.DATA_FORMAT                = null               ;
												lay.ITEMSTYLE_WIDTH            = null               ;
												lay.ITEMSTYLE_HORIZONTAL_ALIGN = null               ;
												lay.ITEMSTYLE_VERTICAL_ALIGN   = null               ;
												lay.ITEMSTYLE_WRAP             = true               ;
												lay.HEADER_TEXT                = column.DISPLAY_NAME;
												lay.DATA_FIELD                 = column.NAME        ;
												lay.SORT_EXPRESSION            = column.NAME        ;
												layoutProcessedList.push(lay);
												if ( column.ColumnType == 'DateTime' )
												{
													lay.DATA_FORMAT = column.ColumnType;
												}
												// 11/10/2020 Paul.  Make sure to format as an integer instead of decimal. 
												if ( column.NAME == 'IMPORT_ROW_NUMBER' )
												{
													lay.DATA_FORMAT = '{0:N0}';
												}
												dictAddedColumns[column.NAME] = true;
											}
										}
									}
								}
							}

							//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command', processedColumns);
							for ( let i: number = 0; i < processedColumns.length; i++ )
							{
								let column: any = processedColumns[i];
								if ( !dictAddedColumns[column.NAME] )
								{
									let lay: any = {};
									lay.COLUMN_INDEX               = i                  ;
									lay.COLUMN_TYPE                = 'BoundColumn'      ;
									lay.DATA_FORMAT                = null               ;
									lay.ITEMSTYLE_WIDTH            = null               ;
									lay.ITEMSTYLE_HORIZONTAL_ALIGN = null               ;
									lay.ITEMSTYLE_VERTICAL_ALIGN   = null               ;
									lay.ITEMSTYLE_WRAP             = true               ;
									lay.HEADER_TEXT                = column.DISPLAY_NAME;
									lay.DATA_FIELD                 = column.NAME        ;
									lay.SORT_EXPRESSION            = column.NAME        ;
									layoutProcessedList.push(lay);
									if ( column.ColumnType == 'DateTime' )
									{
										lay.DATA_FORMAT = column.ColumnType;
									}
									// 11/10/2020 Paul.  Make sure to format as an integer instead of decimal. 
									if ( column.NAME == 'IMPORT_ROW_NUMBER' )
									{
										lay.DATA_FORMAT = '{0:N0}';
									}
									dictAddedColumns[column.NAME] = true;
								}
							}
						}
						this.setState(
						{
							activeTab          : 'Results',
							isProcessing       : false,
							IMPORT_STATUS      ,
							IMPORT_SUCCESS     ,
							IMPORT_DUPLICATE   ,
							IMPORT_FAILED      ,
							IMPORT_FAILED_COUNT,
							ProcessedFileID    ,
							layoutProcessedList,
							error              ,
						});
					}
				}
			}
			// 10/29/2020 Paul.  Import cancel needs to go back to the ImportView so that it can redirect to the base module. 
			else if ( sCommandName == 'Cancel' )
			{
				history.push(`/Reset/${MODULE_NAME}/List`);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error, isProcessing: false });
		}
	}

	private ValidateMappings = () =>
	{
		const { MODULE_NAME } = this.props;
		const { layout } = this.state;
		let sMissing: string = '';
		for ( let nLayoutIndex = 0; nLayoutIndex < layout.length; nLayoutIndex++ )
		{
			let lay = layout[nLayoutIndex];
			let DATA_FIELD  = lay.DATA_FIELD;
			let UI_REQUIRED = Sql.ToBoolean(lay.UI_REQUIRED) || Sql.ToBoolean(lay.DATA_REQUIRED);
			if ( UI_REQUIRED )
			{
				let field: any = this.FindFieldByName(DATA_FIELD);
				let sMapping: string = field.Mapping;
				// 08/09/2017 Paul.  Default value is if mapping not provided. 
				let sDefault: string = field.Default;
				// 02/07/2018 Paul.  Label should not be LBL_LIST_.  Just use base label. 
				// 09/26/2018 Paul.  Remove colon from term. 
				if ( Sql.IsEmptyString(sMapping) && Sql.IsEmptyString(sDefault) )
				{
					sMissing += (L10n.Term('.ERR_MISSING_REQUIRED_FIELDS') + ' ' + L10n.Term(MODULE_NAME + '.LBL_' + DATA_FIELD)).replace(':', '') + '\r\n';
				}
			}
		}
		return sMissing;
	}

	private _onTabChange = (key) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTabChange', key);
		this.setState({ activeTab: key });
	}

	private SOURCE_TYPE_CheckedChanged = (e) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.SOURCE_TYPE_CheckedChanged', e.target.value);
		this.setState({ SOURCE: e.target.value });
	}

	// 12/16/2020 Paul.  Must save NAME changes in order to allow import settings to be saved. 
	private _onNAME_Change = (e) =>
	{
		this.setState({ NAME: e.target.value, NAME_REQUIRED: false });
	}

	// 11/18/2020 Paul.  We need to pass the row info in case more data is need to build the hyperlink. 
	private _onHyperLinkCallback = (MODULE_NAME: string, ID: string, NAME: string, URL: string, row?: any) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback', ID, NAME, URL);
		this.LoadItem(ID).then(() =>
		{
		})
		.catch((error) =>
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onHyperLinkCallback', error);
			this.setState({ error });
		});
	}

	private _onRemove = async (row) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onRemove', row);
		try
		{
			let sBody: string = JSON.stringify({ ID: row.ID });
			let res = await CreateSplendidRequest('Import/Rest.svc/DeleteImportMap', 'POST', 'application/json; charset=utf-8', sBody);
			let json = await GetSplendidResult(res);
			if ( this._isMounted )
			{
				if ( this.splendidGrid.current != null )
				{
					this.splendidGrid.current.Search(null, null);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onRemove', error);
			this.setState({ error });
		}
	}

	private _onGridLayoutLoaded = async () =>
	{
		if ( this.splendidGrid.current != null )
		{
			this.splendidGrid.current.Search(null, null);
		}
	}

	private Load = async (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) =>
	{
		const { MODULE_NAME } = this.props;
		let res  = await CreateSplendidRequest('Import/Rest.svc/GetImportMaps?ImportModule=' + MODULE_NAME, 'GET');
		let json = await GetSplendidResult(res);
		json.d.__total = json.__total;
		json.d.__sql   = json.__sql  ;
		return json.d;
	}

	private _onChange = (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange ' + DATA_FIELD, DATA_VALUE);
		let item = this.state.editedItem;
		if ( item == null )
			item = {};
		item[DATA_FIELD] = DATA_VALUE;
		
		let importMap: any = this.state.importMap;
		if ( importMap.Import && importMap.Import.Fields && importMap.Import.Fields.Field )
		{
			for ( let i: number = 0; i < importMap.Import.Fields.Field.length; i++ )
			{
				let field: any = importMap.Import.Fields.Field[i];
				if ( field.Name == DATA_FIELD )
				{
					field.Default = DATA_VALUE;
					break;
				}
			}
		}
		let importMapJson: string = dumpObj(importMap, 'importMap').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
		
		if ( this._isMounted )
		{
			this.setState({ editedItem: item, importMap, importMapJson });
		}
	}

	private _createDependency = (DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string): void =>
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

	private _onUpdate = (PARENT_FIELD: string, DATA_VALUE: any, item?: any): void =>
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

	private _onHAS_HEADER = (e) =>
	{
		let importMap: any = this.state.importMap;
		if ( importMap.Import  )
		{
			importMap.Import.HasHeader = e.target.checked;
		}
		let importMapJson: string = dumpObj(importMap, 'importMap').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
		
		this.setState({ HAS_HEADER: e.target.checked, importMap, importMapJson });
	}

	private _onUSE_TRANSACTION = (e) =>
	{
		this.setState({ USE_TRANSACTION: e.target.checked });
	}

	private _onFileChange = (e) =>
	{
		let { SOURCE, CUSTOM_DELIMITER_VAL } = this.state;
		try
		{
			let PATH_NAME: string = e.target.value;
			let files = e.target.files;
			if ( files.length > 0 )
			{
				let file = files[0];
				let nMaxSize: number = Crm_Config.ToInteger('upload_maxsize');
				if ( file.size > nMaxSize )
				{
					let error = 'uploaded file was too big: max filesize: ' + nMaxSize;
					this.setState({ error });
				}
				else
				{
					// http://www.javascripture.com/FileReader
					let reader = new FileReader();
					reader.onload = () =>
					{
						let arrayBuffer = reader.result;
						let FILENAME      : string   = file.name;
						let FILE_MIME_TYPE: string   = file.type;
						let FILE_DATA     : string   = base64ArrayBuffer(arrayBuffer);
						let arrFileParts  : string[] = FILENAME.split('.');
						// 05/22/2020 Paul.  Make sure to include the . in the file extension as the legacy upload code requires it. 
						let FILE_EXT      : string   = '.' + arrFileParts[arrFileParts.length - 1].toLowerCase();
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onFileChange', FILENAME + ' ' + FILE_MIME_TYPE, PATH_NAME);
						
						// 04/27/2018 Paul.  Correct the source type based on the file type. 
						if ( FILE_EXT == '.xlsx' || FILE_EXT == '.xls' )
							SOURCE = 'excel';
						else if ( FILE_EXT == '.csv' )
							SOURCE = 'other';
						// 05/20/2020 Paul.  txt can be for csv or custom delimited. 
						else if ( FILE_EXT == '.txt' )
						{
							if ( !Sql.IsEmptyString(CUSTOM_DELIMITER_VAL) )
								SOURCE = 'custom_delimited';
							else
								SOURCE = 'other';
						}
						else if ( FILE_EXT == '.tab' )
							SOURCE = 'other_tab';
						else if ( FILE_EXT == '.xml' )
							SOURCE = 'xml';
						this.setState({ SOURCE, PATH_NAME, FILENAME, FILE_EXT, FILE_MIME_TYPE, FILE_DATA });
					};
					reader.readAsArrayBuffer(file);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChange', error);
		}
	}

	private _onFileUpload = async (e) =>
	{
		const { MODULE_NAME } = this.props;
		const { ID, SOURCE, CUSTOM_DELIMITER_VAL, FILENAME, FILE_EXT, FILE_MIME_TYPE, FILE_DATA } = this.state;
		let { importMap, importMapJson } = this.state;
		try
		{
			if ( !Sql.IsEmptyString(FILE_DATA) )
			{
				let row: any = {};
				row.ImportModule         = MODULE_NAME         ;
				row.SOURCE               = SOURCE              ;
				row.CUSTOM_DELIMITER_VAL = CUSTOM_DELIMITER_VAL;
				row.FILENAME             = FILENAME            ;
				row.FILE_EXT             = FILE_EXT            ;
				row.FILE_MIME_TYPE       = FILE_MIME_TYPE      ;
				row.FILE_DATA            = FILE_DATA           ;
				
				this.setState({ isProcessing: true, TempFileID: null, xmlSample: null, xmlSampleJson: null, TempSampleID: null });
			
				let sBody = JSON.stringify(row);
				let res  = await CreateSplendidRequest('Import/Rest.svc/UploadFile', 'POST', 'application/octet-stream', sBody);
				let json = await GetSplendidResult(res);
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onFileUpload', json);
			
				let TempFileID    : string = json.d.TempFileID;
				let xmlSample     : any    = null;
				let xmlSampleJson : string = null;
				let TempSampleID  : string  = null;
				if ( json.d.xmlSample )
				{
					let options: any = 
					{
						attributeNamePrefix: ''     ,
						textNodeName       : 'Value',
						ignoreAttributes   : false  ,
						ignoreNameSpace    : true   ,
						parseAttributeValue: true   ,
						trimValues         : false  ,
					};
					// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
					const parser = new XMLParser(options);
					xmlSample = parser.parse(json.d.xmlSample);
					// 05/21/2020 Paul.  If there is only one record, the list will need to be converted to an array. 
					if ( xmlSample.xml )
					{
						TempSampleID = json.d.TempSampleID;
						let nl = xmlSample.xml[MODULE_NAME.toLowerCase()];
						if ( nl && !Array.isArray(nl) )
						{
							xmlSample.xml[MODULE_NAME.toLowerCase()] = [];
							xmlSample.xml[MODULE_NAME.toLowerCase()].push(nl);
						}
						else
						{
							// 05/23/2020 Paul.  Try non-lower case. 
							nl = xmlSample.xml[MODULE_NAME];
							if ( nl && !Array.isArray(nl) )
							{
								xmlSample.xml[MODULE_NAME] = [];
								xmlSample.xml[MODULE_NAME].push(nl);
							}
						}
					}
					xmlSampleJson = dumpObj(xmlSample, 'xmlSample').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
					
					let bUpdateMapping: boolean = (ID == null);
					this.UpdateImportMappings(xmlSample.xml, importMap, bUpdateMapping, bUpdateMapping);
					importMapJson = dumpObj(importMap, 'importMap').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
				}
				this.setState(
				{
					activeTab    : 'MapFields',
					isProcessing : false,
					importMap    ,
					importMapJson,
					TempFileID   ,
					xmlSample    ,
					xmlSampleJson,
					TempSampleID ,
					error        : null
				});
			}
			else
			{
				this.setState({ error: L10n.Term('Import.LBL_NOTHING') });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onFileUpload', error);
			this.setState({ error, isProcessing: false });
		}
	}

	private _onDUP_LEFT_Change = (e) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDUP_LEFT_Change', e.target);
		let DUP_LEFT_SELECTED: string[] = [];
		let selectedOptions: any[] = e.target.selectedOptions;
		for ( let i: number = 0; i < selectedOptions.length; i++ )
		{
			let option: any = selectedOptions[i];
			DUP_LEFT_SELECTED.push(option.value);
		}
		this.setState({ DUP_LEFT_SELECTED });
	}

	private _onDUP_LEFT_DoubleClick = (e) =>
	{
		let { importMap, DUP_LEFT_LIST, DUP_LEFT_SELECTED, DUP_RIGHT_SELECTED } = this.state;
		DUP_LEFT_SELECTED  = [];
		DUP_RIGHT_SELECTED = [];
		if ( DUP_LEFT_LIST.indexOf(e.target.value) >= 0 )
		{
			DUP_LEFT_LIST.splice(DUP_LEFT_LIST.indexOf(e.target.value), 1);
		}
		DUP_RIGHT_SELECTED.push(e.target.value);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDUP_LEFT_DoubleClick', DUP_LEFT_LIST, DUP_LEFT_SELECTED);

		this.UpdateDuplicateFilter(importMap, DUP_LEFT_LIST);
		let importMapJson: string = dumpObj(importMap, 'importMap').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
		this.setState({ importMap, importMapJson, DUP_LEFT_LIST, DUP_LEFT_SELECTED, DUP_RIGHT_SELECTED });
	}

	private _onDUP_LEFT_Move = (e) =>
	{
		let { importMap, DUP_LEFT_LIST, DUP_LEFT_SELECTED, DUP_RIGHT_SELECTED } = this.state;
		for ( let i: number = 0; i < DUP_RIGHT_SELECTED.length; i++ )
		{
			DUP_LEFT_LIST.push(DUP_RIGHT_SELECTED[i]);
		}
		DUP_LEFT_SELECTED  = DUP_RIGHT_SELECTED;
		DUP_RIGHT_SELECTED = [];

		this.UpdateDuplicateFilter(importMap, DUP_LEFT_LIST);
		let importMapJson: string = dumpObj(importMap, 'importMap').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
		this.setState({ importMap, importMapJson, DUP_LEFT_LIST, DUP_LEFT_SELECTED, DUP_RIGHT_SELECTED });
	}

	private _onDUP_RIGHT_Change = (e) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDUP_RIGHT_Change', e.target);
		let DUP_RIGHT_SELECTED: string[] = [];
		let selectedOptions: any[] = e.target.selectedOptions;
		for ( let i: number = 0; i < selectedOptions.length; i++ )
		{
			let option: any = selectedOptions[i];
			DUP_RIGHT_SELECTED.push(option.value);
		}
		this.setState({ DUP_RIGHT_SELECTED });
	}

	private _onDUP_RIGHT_DoubleClick = (e) =>
	{
		let { importMap, DUP_LEFT_LIST, DUP_LEFT_SELECTED, DUP_RIGHT_SELECTED } = this.state;
		DUP_LEFT_SELECTED  = [];
		DUP_RIGHT_SELECTED = [];
		DUP_LEFT_LIST.push(e.target.value);
		DUP_LEFT_SELECTED.push(e.target.value);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDUP_RIGHT_DoubleClick', DUP_LEFT_LIST, DUP_LEFT_SELECTED);

		this.UpdateDuplicateFilter(importMap, DUP_LEFT_LIST);
		let importMapJson: string = dumpObj(importMap, 'importMap').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
		this.setState({ importMap, importMapJson, DUP_LEFT_LIST, DUP_LEFT_SELECTED, DUP_RIGHT_SELECTED });
	}

	private _onDUP_RIGHT_Move = (e) =>
	{
		let { importMap, DUP_LEFT_LIST, DUP_LEFT_SELECTED, DUP_RIGHT_SELECTED } = this.state;
		for ( let i: number = 0; i < DUP_LEFT_SELECTED.length; i++ )
		{
			DUP_LEFT_LIST.splice(DUP_LEFT_LIST.indexOf(DUP_LEFT_SELECTED[i]), 1);
		}
		DUP_RIGHT_SELECTED = DUP_LEFT_SELECTED;
		DUP_LEFT_SELECTED = [];

		this.UpdateDuplicateFilter(importMap, DUP_LEFT_LIST);
		let importMapJson: string = dumpObj(importMap, 'importMap').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
		this.setState({ importMap, importMapJson, DUP_LEFT_LIST, DUP_LEFT_SELECTED, DUP_RIGHT_SELECTED });
	}

	private UpdateDuplicateFilter = (importMap: any, DUP_LEFT_LIST: string[]) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateDuplicateFilter', DUP_LEFT_LIST);
		if ( importMap.Import && importMap.Import.Fields && importMap.Import.Fields.Field )
		{
			for ( let i: number = 0; i < importMap.Import.Fields.Field.length; i++ )
			{
				let field: any = importMap.Import.Fields.Field[i];
				field.DuplicateFilter = (DUP_LEFT_LIST.indexOf(field.Name) >= 0);
			}
		}
	}

	private GetInstructions = () =>
	{
		const { SOURCE } = this.state;
		let sInstructions: string = null;
		switch ( SOURCE )
		{
			case 'excel'           :  sInstructions = L10n.Term('Import.LBL_IMPORT_EXCEL_TITLE'          );  break;
			case 'xmlspreadsheet'  :  sInstructions = L10n.Term('Import.LBL_IMPORT_XML_SPREADSHEET_TITLE');  break;
			case 'xml'             :  sInstructions = L10n.Term('Import.LBL_IMPORT_XML_TITLE'            );  break;
			case 'act'             :  sInstructions = L10n.Term('Import.LBL_IMPORT_ACT_TITLE'            );  break;
			case 'dbase'           :  sInstructions = L10n.Term('Import.LBL_IMPORT_DBASE_TITLE'          );  break;
			case 'other'           :  sInstructions = L10n.Term('Import.LBL_IMPORT_CUSTOM_TITLE'         );  break;
			case 'other_tab'       :  sInstructions = L10n.Term('Import.LBL_IMPORT_TAB_TITLE'            );  break;
			case 'custom_delimited':  sInstructions = L10n.Term('Import.LBL_IMPORT_CUSTOM_TITLE'         );  break;
			case 'LinkedIn'        :  sInstructions = L10n.Term('Import.LBL_IMPORT_LINKEDIN_TITLE'       );  break;
			case 'Twitter'         :  sInstructions = L10n.Term('Import.LBL_IMPORT_TWITTER_TITLE'        );  break;
			case 'Facebook'        :  sInstructions = L10n.Term('Import.LBL_IMPORT_FACEBOOK_TITLE'       );  break;
			case 'salesforce'      :  sInstructions = L10n.Term('Import.LBL_IMPORT_SF_TITLE'             );  break;
			case 'QuickBooks'      :  sInstructions = L10n.Term('Import.LBL_IMPORT_QUICKBOOKS_TITLE'     );  break;
			case 'QuickBooksOnline':  sInstructions = L10n.Term('Import.LBL_IMPORT_QUICKBOOKS_ONLINE'    );  break;
			case 'HubSpot'         :  sInstructions = L10n.Term('Import.LBL_IMPORT_HUBSPOT_TITLE'        );  break;
		}
		return sInstructions;
	}

	private UpdateImportMappings = (xml: any, importMap: any, bInitialize: boolean, bUpdateMappings: boolean) =>
	{
		const { MODULE_NAME } = this.props;
		const { SOURCE, HAS_HEADER, importColumns } = this.state;
		if ( xml )
		{
			let nl: any = xml[MODULE_NAME.toLowerCase()];
			// 05/23/2020 Paul.  Try non-lower case. 
			if ( !nl )
				nl = xml[MODULE_NAME];
			if ( nl && Array.isArray(nl) && nl.length > 0 )
			{
				let nodeH: any = nl[0];
				let node1: any = nl[0];
				let node2: any = null;
				// 08/22/2006 Paul.  An XML Spreadsheet will have a header record, 
				// so don't assume that an XML file will use the tag names as the header. 
				if ( HAS_HEADER )
				{
					if ( nl.length > 1 )
						node1 = nl[1];
					if ( nl.length > 2 )
						node2 = nl[2];
				}
				else
				{
					if ( nl.length > 1 )
						node2 = nl[1];
				}
				let hashSelectedFields: any = {};
				let iField: number = 0;
				for ( let sFieldID in nodeH )
				{
					if ( bInitialize || bUpdateMappings )
					{
						let bFound: boolean = false;
						if ( HAS_HEADER )
						{
							// 05/23/2020 Paul.  Convert to string, just in case it is treated as a number or a boolean. 
							// 01/09/2021 Paul.  An export header may contain a colon if the wrong label is used. 
							let sFieldName: string = Sql.ToString(nodeH[sFieldID]).toLowerCase().replace(':', '');
							for ( let i: number = 0; i < importColumns.length; i++ )
							{
								let column: any = importColumns[i];
								if ( sFieldName == column.NAME.toLowerCase() || sFieldName == column.NAME_NOUNDERSCORE.toLowerCase() || sFieldName == column.DISPLAY_NAME.toLowerCase() || sFieldName == column.DISPLAY_NAME_NOSPACE.toLowerCase() || sFieldName.replace(/\s/g, '_') + '_c' == column.NAME.toLowerCase() )
								{
									let field: any = this.FindFieldByName(column.NAME);
									if ( field )
									{
										sFieldName = iField.toString();
										if ( sFieldName.length < 3 )
											sFieldName = '0' + sFieldName;
										if ( sFieldName.length < 3 )
											sFieldName = '0' + sFieldName;
										sFieldName = 'ImportField' + sFieldName;
										field.Mapping = sFieldName;
										hashSelectedFields[iField] = field;
										bFound = true;
									}
								}
							}
						}
						// 05/23/2020 Paul.  If has header flag set, we still may not find the field, so re-check if source is xml. 
						if ( !bFound && SOURCE == 'xml' )
						{
							let sFieldName: string = sFieldID.toLowerCase();
							for ( let i: number = 0; i < importColumns.length; i++ )
							{
								let column: any = importColumns[i];
								if ( sFieldName == column.NAME.toLowerCase() || sFieldName == column.NAME_NOUNDERSCORE.toLowerCase() || sFieldName == column.DISPLAY_NAME.toLowerCase() || sFieldName == column.DISPLAY_NAME_NOSPACE.toLowerCase() || sFieldName.replace(/\s/g, '_') + '_c' == column.NAME.toLowerCase() )
								{
									let field: any = this.FindFieldByName(column.NAME);
									if ( field )
									{
										field.Mapping = sFieldID;
										hashSelectedFields[iField] = field;
										bFound = true;
									}
								}
							}
						}
					}
					iField++;
				}
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.UpdateImportMappings', hashSelectedFields);
			}
		}
	}

	private FindFieldByMapping = (sFieldID: string) =>
	{
		const { importMap } = this.state;
		let found: any = null;
		if ( importMap && importMap.Import && importMap.Import.Fields && importMap.Import.Fields.Field && Array.isArray(importMap.Import.Fields.Field) )
		{
			for ( let i: number = 0; i < importMap.Import.Fields.Field.length; i++ )
			{
				let field: any = importMap.Import.Fields.Field[i];
				if ( field.Mapping == sFieldID )
				{
					found = field;
					break;
				}
			}
		}
		return found;
	}

	private FindFieldByName = (sFieldName: string) =>
	{
		const { importMap } = this.state;
		let found: any = null;
		if ( importMap && importMap.Import && importMap.Import.Fields && importMap.Import.Fields.Field && Array.isArray(importMap.Import.Fields.Field) )
		{
			for ( let i: number = 0; i < importMap.Import.Fields.Field.length; i++ )
			{
				let field: any = importMap.Import.Fields.Field[i];
				if ( field.Name == sFieldName )
				{
					found = field;
					break;
				}
			}
		}
		return found;
	}

	private _onChangeFieldMapping = (e: React.ChangeEvent<HTMLSelectElement>, sFieldID: string, iField: number) =>
	{
		let { importMap } = this.state;
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onChangeFieldMapping', e, sFieldID, iField);

		let NAME: string = e.target.value;
		let field: any = this.FindFieldByName(NAME);
		if ( field )
		{
			// 05/22/2020 Paul.  Prior to setting, clear any previous mapping to prevent duplicates. 
			for ( let i: number = 0; i < importMap.Import.Fields.Field.length; i++ )
			{
				let field: any = importMap.Import.Fields.Field[i];
				if ( field.Mapping == sFieldID )
				{
					field.Mapping = null;
				}
			}
			field.Mapping = sFieldID;
			let importMapJson: string  = dumpObj(importMap, 'importMap').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
			this.setState({ importMap, importMapJson });
		}
	}

	private _onPreviewGridLayoutLoaded = async () =>
	{
		if ( this.previewGrid.current != null )
		{
			this.previewGrid.current.Search(null, null);
		}
	}

	private LoadPreview = async (sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT, sFILTER, rowSEARCH_VALUES, nTOP, nSKIP, bADMIN_MODE?, archiveView?) =>
	{
		const { ProcessedFileID } = this.state;
		let res = await CreateSplendidRequest('Import/Rest.svc/GetPreviewList?ImportModule=' + sMODULE_NAME + '&ProcessedFileID=' + ProcessedFileID + '&$top=' + nTOP + '&$skip=' + nSKIP + '&$orderby=' + encodeURIComponent(sSORT_FIELD + ' ' + sSORT_DIRECTION), 'GET');
	
		let json = await GetSplendidResult(res);
		json.d.__total = json.__total;
		json.d.__sql   = '';
		return (json.d);
	}

	private _onExportErrors = (e) =>
	{
		const { SOURCE, ProcessedFileID } = this.state;
		e.preventDefault();
		window.location.href = Credentials.RemoteServer + 'Import/errors.aspx?ProcessedFileID=' + ProcessedFileID + '&SourceType=' + SOURCE;
	}

	private BootstrapColumns = (sLIST_MODULE_NAME, layout, sPRIMARY_MODULE, sPRIMARY_ID) =>
	{
		// 04/20/2017 Paul.  Build DataTables columns. 
		let arrDataTableColumns = [];
		let objDataColumn: any = {};
		// 05/24/2020 Paul.  We don't need the edit column for the view-only import data. 
		// 05/24/2020 Paul.  Override the default layout and use a simplified, manually constructed, layout. 
		layout = this.state.layoutProcessedList;

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
					// 05/07/2021 Paul.  Reference this.previewGrid. 
					objDataColumn =
					{
						key            : 'column' + nLayoutIndex,
						text           : (Sql.IsEmptyString(HEADER_TEXT) ? '' : L10n.Term(HEADER_TEXT)),
						dataField      : DATA_FIELD,
						classes        : '',
						style          : (Sql.ToBoolean(ITEMSTYLE_WRAP) ? null : {whiteSpace: 'nowrap'}),
						headerClasses  : 'listViewThS2',
						headerStyle    : {whiteSpace: 'nowrap'},
						headerFormatter: (this.previewGrid.current != null ? this.previewGrid.current.renderHeader            : null),
						formatter      : (this.previewGrid.current != null ? this.previewGrid.current.templateColumnFormatter : null),
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
					// 05/07/2021 Paul.  Reference this.previewGrid. 
					objDataColumn =
					{
						key            : 'column' + nLayoutIndex,
						text           : (Sql.IsEmptyString(HEADER_TEXT) ? '' : L10n.Term(HEADER_TEXT)),
						dataField      : DATA_FIELD,
						classes        : '',
						style          : (Sql.ToBoolean(ITEMSTYLE_WRAP) ? null : {whiteSpace: 'nowrap'}),
						headerClasses  : 'listViewThS2',
						headerStyle    : {whiteSpace: 'nowrap'},
						headerFormatter: (this.previewGrid.current != null ? this.previewGrid.current.renderHeader         : null),
						formatter      : (this.previewGrid.current != null ? this.previewGrid.current.boundColumnFormatter : null),
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
		const { MODULE_NAME } = this.props;
		const { activeTab, isProcessing, disableImportNumbers, NAME, SOURCE, CUSTOM_DELIMITER_VAL, HAS_HEADER, RULES_XML, USE_TRANSACTION, importMapJson, xmlSample, xmlSampleJson, displayColumns, error } = this.state;
		const { bLinkedIn, bTwitter, bFacebook, bSalesforce, bQuickBooks, bQuickBooksOnline, bHubSpot } = this.state;
		const { ID, item, layout, NAME_REQUIRED, PATH_NAME, importColumns, DUP_LEFT_SELECTED, DUP_LEFT_LIST, DUP_RIGHT_SELECTED } = this.state;
		const { IMPORT_STATUS, IMPORT_SUCCESS, IMPORT_DUPLICATE, IMPORT_FAILED, IMPORT_FAILED_COUNT, ProcessedFileID } = this.state;

		this.refMap = {};
		if ( SplendidCache.IsInitialized )
		{
			let bConnect: boolean = 
			(  (bLinkedIn         && SOURCE == 'LinkedIn'         )
			|| (bTwitter          && SOURCE == 'Twitter'          )
			|| (bFacebook         && SOURCE == 'Facebook'         )
			|| (bSalesforce       && SOURCE == 'salesforce'       )
			|| (bQuickBooks       && SOURCE == 'QuickBooks'       )
			|| (bQuickBooksOnline && SOURCE == 'QuickBooksOnline')
			|| (bHubSpot          && SOURCE == 'HubSpot'          )
			);
			// 05/18/2017 Paul.  The LinkedIn Connections API has been discontinued. https://developer.linkedin.com/support/developer-program-transition
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			// 10/21/2020 Paul.  Some themes look too tightly packed with the scaling. 
			let styCheckbox = { transform: 'scale(1.5)', display: 'inline', marginTop: '2px', marginBottom: '6px', marginRight: '6px' };
			// 10/28/2020 Paul.  A customer preferred the old icons instead of the new fontawesome icons. 
			if ( Crm_Config.ToBoolean('enable_legacy_icons') )
			{
				styCheckbox.transform = 'scale(1.0)';
				styCheckbox.marginBottom = '2px';
			}

			let rules: any = { MODULE_NAME, RULES_XML };
			let nl: any = null;
			let nodeH: any = null;
			let node1: any = null;
			let node2: any = null;
			if ( xmlSample && xmlSample.xml )
			{
				nl = xmlSample.xml[MODULE_NAME.toLowerCase()];
				// 05/23/2020 Paul.  Try non-lower case. 
				if ( !nl )
					nl = xmlSample.xml[MODULE_NAME];
				if ( nl && Array.isArray(nl) && nl.length > 0 )
				{
					nodeH = nl[0];
					node1 = nl[0];
					node2 = null;
					// 08/22/2006 Paul.  An XML Spreadsheet will have a header record, 
					// so don't assume that an XML file will use the tag names as the header. 
					if ( HAS_HEADER )
					{
						if ( nl.length > 1 )
							node1 = nl[1];
						if ( nl.length > 2 )
							node2 = nl[2];
					}
					else
					{
						if ( nl.length > 1 )
							node2 = nl[1];
					}
				}
			}
			let arrFieldRows: any[]  = [];
			let iField      : number = 0;
			for ( let sFieldID in nodeH )
			{
				let found: any = null;
				if ( SOURCE == 'xml' )
				{
					found = this.FindFieldByMapping(sFieldID);
				}
				else
				{
					let sFieldName: string = iField.toString();
					if ( sFieldName.length < 3 )
						sFieldName = '0' + sFieldName;
					if ( sFieldName.length < 3 )
						sFieldName = '0' + sFieldName;
					sFieldName = 'ImportField' + sFieldName;
					found = this.FindFieldByMapping(sFieldName);
				}

				let trChildren = [];
				let tr         = React.createElement('tr', null, trChildren);
				arrFieldRows.push(tr);
				let cellFieldChildren  = [];
				let cellField          = React.createElement('td', {className: 'tabDetailViewDF'}, cellFieldChildren );
				let cellRowHdrChildren = [];
				let cellRowHdr         = React.createElement('td', {className: 'tabDetailViewDF'}, cellRowHdrChildren);
				let cellRow1Children   = [];
				let cellRow1           = React.createElement('td', {className: 'tabDetailViewDF'}, cellRow1Children  );
				let cellRow2Children   = [];
				let cellRow2           = React.createElement('td', {className: 'tabDetailViewDF'}, cellRow2Children  );
				trChildren.push(cellField);
				if ( HAS_HEADER || SOURCE == 'xml' )
				{
					trChildren.push(cellRowHdr);
					cellRowHdrChildren.push(nodeH[sFieldID]);
				}
				trChildren.push(cellRow1);
				if ( node1 )
				{
					cellRow1Children.push(node1[sFieldID]);
				}
				trChildren.push(cellRow2);
				if ( node2 )
				{
					cellRow2Children.push(node2[sFieldID]);
				}
				
				let lstFieldChildren = [];
				let lstField         = <select id={ sFieldID } value={ (found ? found.Name : '') } onChange={ (e) => this._onChangeFieldMapping(e, sFieldID, iField) }>{ lstFieldChildren }</select>;
				cellFieldChildren.push(lstField);
				lstFieldChildren.push(<option value=''>{ L10n.Term('Import.LBL_DONT_MAP') }</option>);
				// 01/09/2021 Paul.  Sort in the app instead of with importColumns to match the ASP.Net processing lists. 
				for ( let j: number = 0; j < displayColumns.length; j++ )
				{
					let column: any = displayColumns[j];
					lstFieldChildren.push(<option key={ sFieldID + '_' + j.toString() } value={ column.NAME }>{ column.DISPLAY_NAME }</option>);
				}
				iField++;
			}
			return (
				<React.Fragment>
					{ React.createElement(headerButtons, { MODULE_NAME: 'Import', error, showRequired: true, enableHelp: true, helpName: 'ImportView', ButtonStyle: 'EditHeader', VIEW_NAME: 'Import.ImportView', row: null, Page_Command: this.Page_Command, showButtons: true, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons }) }
					<Tabs key='pnlImportTabs' id='pnlImportTabs' activeKey={ activeTab } onSelect={ this._onTabChange }>
						<Tab key={ 'SelectSource'    } eventKey={ 'SelectSource'    } tabClassName='ImportViewTab' title={ (disableImportNumbers ? '' : '1. ') + L10n.Term('Import.LBL_IMPORT_STEP_SELECT_SOURCE'   ) }></Tab>
						<Tab key={ 'SpecifyDefaults' } eventKey={ 'SpecifyDefaults' } tabClassName='ImportViewTab' title={ (disableImportNumbers ? '' : '2. ') + L10n.Term('Import.LBL_IMPORT_STEP_SPECIFY_DEFAULTS') }></Tab>
						{ bConnect
						? <Tab key={ 'Connect'       } eventKey={ 'Connect'         } tabClassName='ImportViewTab' title={ (disableImportNumbers ? '' : '3. ') + L10n.Term('Import.LBL_IMPORT_STEP_CONNECT'         ) }></Tab>
						: <Tab key={ 'UploadFile'    } eventKey={ 'UploadFile'      } tabClassName='ImportViewTab' title={ (disableImportNumbers ? '' : '3. ') + L10n.Term('Import.LBL_IMPORT_STEP_UPLOAD_FILE'     ) }></Tab>
						}
						<Tab key={ 'MapFields'       } eventKey={ 'MapFields'       } tabClassName='ImportViewTab' title={ (disableImportNumbers ? '' : '4. ') + L10n.Term('Import.LBL_IMPORT_STEP_MAP_FIELDS'      ) }></Tab>
						<Tab key={ 'DupicateFilter'  } eventKey={ 'DupicateFilter'  } tabClassName='ImportViewTab' title={ (disableImportNumbers ? '' : '5. ') + L10n.Term('Import.LBL_IMPORT_STEP_DUPLICATE_FILTER') }></Tab>
						<Tab key={ 'BusinessRules'   } eventKey={ 'BusinessRules'   } tabClassName='ImportViewTab' title={ (disableImportNumbers ? '' : '6. ') + L10n.Term('Import.LBL_IMPORT_STEP_BUSINESS_RULES'  ) }></Tab>
						<Tab key={ 'Results'         } eventKey={ 'Results'         } tabClassName='ImportViewTab' title={ (disableImportNumbers ? '' : '7. ') + L10n.Term('Import.LBL_IMPORT_STEP_RESULTS'         ) }></Tab>
					</Tabs>
					<div style={ {paddingTop: '10px', paddingLeft: '20px'} }>
						<div className='tabForm' style={ {display: (activeTab == 'SelectSource' ? 'flex' : 'none'), flexFlow: 'row wrap', flex: '1 0 100%'} }>
							<div className='dataField' style={ {width: '35%'} }>
								<h4>{ L10n.Term('Import.LBL_WHAT_IS') }</h4>
								<div><input id='radEXCEL'            type='radio' className='radio' style={ styCheckbox } radioGroup='SOURCE' value='excel'            checked={ SOURCE == 'excel'               } onClick={ this.SOURCE_TYPE_CheckedChanged } /><label style={ {marginBottom: '6px'} } htmlFor='radEXCEL'           >{ L10n.Term('Import.LBL_EXCEL'           ) }</label></div>
								<div><input id='radXML_SPREADSHEET'  type='radio' className='radio' style={ styCheckbox } radioGroup='SOURCE' value='xmlspreadsheet'   checked={ SOURCE == 'xmlspreadsheet'      } onClick={ this.SOURCE_TYPE_CheckedChanged } /><label style={ {marginBottom: '6px'} } htmlFor='radXML_SPREADSHEET' >{ L10n.Term('Import.LBL_XML_SPREADSHEET' ) }</label></div>
								<div><input id='radXML'              type='radio' className='radio' style={ styCheckbox } radioGroup='SOURCE' value='xml'              checked={ SOURCE == 'xml'                 } onClick={ this.SOURCE_TYPE_CheckedChanged } /><label style={ {marginBottom: '6px'} } htmlFor='radXML'             >{ L10n.Term('Import.LBL_XML'             ) }</label></div>
								<div><input id='radACT_2005'         type='radio' className='radio' style={ styCheckbox } radioGroup='SOURCE' value='act'              checked={ SOURCE == 'act'                 } onClick={ this.SOURCE_TYPE_CheckedChanged } /><label style={ {marginBottom: '6px'} } htmlFor='radACT_2005'        >{ L10n.Term('Import.LBL_ACT_2005'        ) }</label></div>
								<div><input id='radDBASE'            type='radio' className='radio' style={ styCheckbox } radioGroup='SOURCE' value='dbase'            checked={ SOURCE == 'dbase'               } onClick={ this.SOURCE_TYPE_CheckedChanged } /><label style={ {marginBottom: '6px'} } htmlFor='radDBASE'           >{ L10n.Term('Import.LBL_DBASE'           ) }</label></div>
								<div><input id='radCUSTOM_CSV'       type='radio' className='radio' style={ styCheckbox } radioGroup='SOURCE' value='other'            checked={ SOURCE == 'other'               } onClick={ this.SOURCE_TYPE_CheckedChanged } /><label style={ {marginBottom: '6px'} } htmlFor='radCUSTOM_CSV'      >{ L10n.Term('Import.LBL_CUSTOM_CSV'      ) }</label></div>
								<div><input id='radCUSTOM_TAB'       type='radio' className='radio' style={ styCheckbox } radioGroup='SOURCE' value='other_tab'        checked={ SOURCE == 'other_tab'           } onClick={ this.SOURCE_TYPE_CheckedChanged } /><label style={ {marginBottom: '6px'} } htmlFor='radCUSTOM_TAB'      >{ L10n.Term('Import.LBL_CUSTOM_TAB'      ) }</label></div>
								<div><input id='radCUSTOM_DELIMITED' type='radio' className='radio' style={ styCheckbox } radioGroup='SOURCE' value='custom_delimited' checked={ SOURCE == 'custom_delimited'    } onClick={ this.SOURCE_TYPE_CheckedChanged } /><label style={ {marginBottom: '6px'} } htmlFor='radCUSTOM_DELIMITED'>{ L10n.Term('Import.LBL_CUSTOM_DELIMETED') }</label></div>
								{ SOURCE == 'custom_delimited'
								? <div id='divCUSTOM_DELIMITER_VAL'>
									&nbsp;&nbsp; { L10n.Term('Import.LBL_CUSTOM_DELIMETER') } <input id='CUSTOM_DELIMITER_VAL' type='text' maxLength={ 1 } size={ 3 } value={ CUSTOM_DELIMITER_VAL } />
								</div>
								: null
								}
								<hr />
								{ bLinkedIn   ? <div><input id='radLINKEDIN'          type='radio' className='radio' style={ styCheckbox } radioGroup='SOURCE' value='LinkedIn'          checked={ SOURCE == 'LinkedIn'          } onClick={ this.SOURCE_TYPE_CheckedChanged } /><label style={ {marginBottom: '6px'} } htmlFor='radLINKEDIN'         >{ L10n.Term('Import.LBL_LINKEDIN'         ).replace('&reg;', '') } &reg;</label></div> : null }
								{ bTwitter    ? <div><input id='radTWITTER'           type='radio' className='radio' style={ styCheckbox } radioGroup='SOURCE' value='Twitter'           checked={ SOURCE == 'Twitter'           } onClick={ this.SOURCE_TYPE_CheckedChanged } /><label style={ {marginBottom: '6px'} } htmlFor='radTWITTER'          >{ L10n.Term('Import.LBL_TWITTER'          ).replace('&reg;', '') } &reg;</label></div> : null }
								{ bFacebook   ? <div><input id='radFACEBOOK'          type='radio' className='radio' style={ styCheckbox } radioGroup='SOURCE' value='Facebook'          checked={ SOURCE == 'Facebook'          } onClick={ this.SOURCE_TYPE_CheckedChanged } /><label style={ {marginBottom: '6px'} } htmlFor='radFACEBOOK'         >{ L10n.Term('Import.LBL_FACEBOOK'         ).replace('&reg;', '') } &reg;</label></div> : null }
								{ bSalesforce ? <div><input id='radSALESFORCE'        type='radio' className='radio' style={ styCheckbox } radioGroup='SOURCE' value='salesforce'        checked={ SOURCE == 'salesforce'        } onClick={ this.SOURCE_TYPE_CheckedChanged } /><label style={ {marginBottom: '6px'} } htmlFor='radSALESFORCE'       >{ L10n.Term('Import.LBL_SALESFORCE'       ).replace('&reg;', '') } &reg;</label></div> : null }
								{ bQuickBooks && (MODULE_NAME == 'Accounts' || MODULE_NAME == 'Contacts' || MODULE_NAME == 'ProductTemplates' || MODULE_NAME == 'Items' || MODULE_NAME == 'ShippingMethod' || MODULE_NAME == 'Estimates' || MODULE_NAME == 'SalesOrder' || MODULE_NAME == 'Invoice')
								? <div><input id='radQUICKBOOKS'        type='radio' className='radio' style={ styCheckbox } radioGroup='SOURCE' value='QuickBooksOnline'        checked={ SOURCE == 'QuickBooksOnline'        } onClick={ this.SOURCE_TYPE_CheckedChanged } /><label style={ {marginBottom: '6px'} } htmlFor='radQUICKBOOKS'       >{ L10n.Term('Import.LBL_QUICKBOOKS'       ).replace('&reg;', '') } &reg;</label></div>
								: null
								}
								{ bQuickBooksOnline && (MODULE_NAME == 'Accounts' || MODULE_NAME == 'Contacts' || MODULE_NAME == 'ProductTemplates' || MODULE_NAME == 'Items' || MODULE_NAME == 'ShippingMethod' || MODULE_NAME == 'Invoice')
								? <div><input id='radQUICKBOOKS_ONLINE' type='radio' className='radio' style={ styCheckbox } radioGroup='SOURCE' value='QuickBooks' checked={ SOURCE == 'QuickBooks' } onClick={ this.SOURCE_TYPE_CheckedChanged } /><label style={ {marginBottom: '6px'} } htmlFor='radQUICKBOOKS_ONLINE'>{ L10n.Term('Import.LBL_QUICKBOOKS_ONLINE').replace('&reg;', '') } &reg;</label></div>
								: null
								}
								{ bHubSpot    ? <div><input id='radHUBSPOT'           type='radio' className='radio' style={ styCheckbox } radioGroup='SOURCE' value='HubSpot'           checked={ SOURCE == 'HubSpot'           } onClick={ this.SOURCE_TYPE_CheckedChanged } /><label style={ {marginBottom: '6px'} } htmlFor='radHUBSPOT'          >{ L10n.Term('Import.LBL_HUBSPOT'          ).replace('&reg;', '') } &reg;</label></div> : null }
							</div>
							<div style={ {width: '65%'} }>
								<div className='dataLabel' style={ {width: '30%'} }>
									{ L10n.Term('Import.LBL_NAME') }
								</div>
								<div className='dataField' style={ {width: '70%'} }>
									<input type='text' tabIndex={ 2 } size={ 35 } maxLength={ 150 } value={ NAME } onChange={ this._onNAME_Change } />
									&nbsp;
									{ NAME_REQUIRED ? <span className='required'>{L10n.Term('.ERR_REQUIRED_FIELD')}</span> : null }
									&nbsp;
									<button className='button' title={ L10n.Term('.LBL_SAVE_BUTTON_TITLE') } onClick={ (e) => this.Page_Command('Import.Save', null) }>{ L10n.Term('.LBL_SAVE_BUTTON_LABEL') }</button>
								</div>
							</div>
							<br />
							<ListHeader TITLE={ L10n.Term('Import.LBL_MY_SAVED') } />
							<div style={ {width: '100%'} }>
								<SplendidGrid
									onLayoutLoaded={ this._onGridLayoutLoaded }
									MODULE_NAME='Import'
									RELATED_MODULE='Import'
									GRID_NAME='Import.SavedView'
									ADMIN_MODE={ false }
									hyperLinkCallback={ this._onHyperLinkCallback }
									deferLoad={ true }
									disableEdit={ true }
									disableView={ true }
									enableSelection={ false }
									scrollable
									cbCustomLoad={ this.Load }
									cbRemove={ this._onRemove }
									history={ this.props.history }
									location={ this.props.location }
									match={ this.props.match }
									ref={ this.splendidGrid }
								/>
							</div>
						</div>
						<div style={ {display: (activeTab == 'SpecifyDefaults' ? 'block' : 'none')} }>
							<div key={ ID }>
								{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, null, this._createDependency, null, this._onChange, this._onUpdate, null, 'tabForm', this.Page_Command) }
							</div>
						</div>
						<div className='tabForm' style={ {display: (activeTab == 'Connect' || activeTab == 'UploadFile' ? 'block' : 'none')} }>
							<div style={ {padding: '20px', fontSize: 'notset' } }>
								<div dangerouslySetInnerHTML={ {__html: this.GetInstructions() } }></div>
								{ SOURCE == 'xml'
								? <pre>
									<div style={ {paddingLeft: '50px', paddingTop: '10px'} }>
									&lt;xml&gt;
										<div style={ {paddingLeft: '20px'} }>
										&lt;{ MODULE_NAME.toLowerCase() }&gt;
											<div style={ {paddingLeft: '20px'} }>&lt;id&gt;&lt;/id&gt;</div>
											<div style={ {paddingLeft: '20px'} }>&lt;name&gt;&lt;/name&gt;</div>
										&lt;/{ MODULE_NAME.toLowerCase() }&gt;
										</div>
									&lt;/xml&gt;
									</div>
								</pre>
								: null
								}
							</div>
							{ activeTab == 'UploadFile'
							? <div>
								<input type='file'
									onChange={ this._onFileChange }
									style={ {width: '25%', overflowX: 'hidden'} }
								/>
								&nbsp;
								<input type='submit' className='button' value={ L10n.Term('Import.LBL_UPLOAD_BUTTON_LABEL') } title={ L10n.Term('Import.LBL_UPLOAD_BUTTON_TITLE') } onClick={ this._onFileUpload } />
								&nbsp;{ PATH_NAME }
							</div>
							: null
							}
							<div>
								<br />
								{ L10n.Term('Import.LBL_HAS_HEADER') }
								<input type='checkbox' className='checkbox' style={ styCheckbox } checked={ HAS_HEADER } onClick={ this._onHAS_HEADER } />
							</div>
						</div>
						<div className='tabForm' style={ {display: (activeTab == 'MapFields' ? 'block' : 'none')} }>
							<div>
								<div style={ {textAlign: 'right'} }><span className='required'>{ L10n.Term('.LBL_REQUIRED_SYMBOL') }</span>{ L10n.Term('.NTC_REQUIRED') }</div>
								<div>{ L10n.Term('Import.LBL_SELECT_FIELDS_TO_MAP') }</div>
								{ MODULE_NAME == 'Accounts'
								? <div>
									<br />
									<b>{ L10n.Term('Import.LBL_NOTES') }</b>
									<ul>
										<li>{ L10n.Term('Import.LBL_ACCOUNTS_NOTE_1') }</li>
									</ul>
								</div>
								: null
								}
								{ MODULE_NAME == 'Contacts'
								? <div>
									<br />
									<b>{ L10n.Term('Import.LBL_NOTES') }</b>
									<ul>
										<li>{ L10n.Term('Import.LBL_CONTACTS_NOTE_1') }</li>
									</ul>
								</div>
								: null
								}
								{ MODULE_NAME == 'Opportunities'
								? <div>
									<br />
									<b>{ L10n.Term('Import.LBL_NOTES') }</b>
									<ul>
										<li>{ L10n.Term('Import.LBL_OPPORTUNITIES_NOTE_1') }</li>
									</ul>
								</div>
								: null
								}
							</div>
							<table className='tabDetailView' style={ {width: '100%'} }>
								<tr>
									<td className='tabDetailViewDL' style={ {textAlign: 'left', width: '10%', fontWeight: 'bold'} }>{ L10n.Term('Import.LBL_DATABASE_FIELD') } </td>
									{ HAS_HEADER || SOURCE == 'xml'
									? <td className='tabDetailViewDL' style={ {textAlign: 'left', width: '10%', fontWeight: 'bold'} }>{ L10n.Term('Import.LBL_HEADER_ROW'    ) } </td>
									: null
									}
									<td className='tabDetailViewDL' style={ {textAlign: 'left', width: '40%', fontWeight: 'bold'} }>{ L10n.Term('Import.LBL_ROW' ) + '1'     } </td>
									<td className='tabDetailViewDL' style={ {textAlign: 'left', width: '40%', fontWeight: 'bold'} }>{ L10n.Term('Import.LBL_ROW' ) + '2'     } </td>
								</tr>
								{ arrFieldRows }
							</table>
						</div>
						<div style={ {display: (activeTab == 'DupicateFilter' ? 'block' : 'none')} }>
							<h4>{ L10n.Term('Import.LBL_DUPLICATE_FILTER') }</h4>
							<div style={ {display: 'flex', flexFlow: 'row wrap', flex: '1 0 100%'} }>
								<div className='dataField' style={ {width: '15%'} }>
									<b>{ L10n.Term('Import.LBL_FILTER_COLUMNS') }</b><br />
									<select
										id='lstDUP_LEFT'
										multiple={ true }
										size={ 10 }
										onChange={ this._onDUP_LEFT_Change }
										onDoubleClick={ this._onDUP_LEFT_DoubleClick }
										value={ DUP_LEFT_SELECTED }
										style={ {width: 'auto', margin: 2} }
										>
										{
											importColumns.map((item, index) => 
											{
												if ( DUP_LEFT_LIST && DUP_LEFT_LIST.indexOf(item.NAME) >= 0 )
												{
													return (<option key={ '_ctlEditView_DUP_LEFT_' + index.toString() } id={ '_ctlEditView_DUP_LEFT' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
												}
												else
												{
													return null;
												}
											})
										}
									</select>
								</div>
								<div className='dataField' style={ {width: '5%'} }>
									<br />
									<img src={ this.themeURL + 'images/leftarrow_big.gif' } style={ {cursor: 'pointer'} } onClick={ this._onDUP_LEFT_Move } />
									&nbsp;&nbsp;
									<img src={ this.themeURL + 'images/rightarrow_big.gif' } style={ {cursor: 'pointer'} } onClick={ this._onDUP_RIGHT_Move }  />
								</div>
								<div className='dataField' style={ {width: '15%'} }>
									<b>{ L10n.Term('Import.LBL_AVAILABLE_COLUMNS') }</b><br />
									<select
										id='lstDUP_RIGHT'
										multiple={ true }
										size={ 10 }
										onChange={ this._onDUP_RIGHT_Change }
										onDoubleClick={ this._onDUP_RIGHT_DoubleClick }
										value={ DUP_RIGHT_SELECTED }
										style={ {width: 'auto', margin: 2} }
										>
										{
											importColumns.map((item, index) => 
											{
												if ( item.NAME == 'ID' || item.NAME == 'MODIFIED_USER_ID' || item.NAME == 'ASSIGNED_USER_ID' || item.NAME == 'TEAM_ID' || (DUP_LEFT_LIST && DUP_LEFT_LIST.indexOf(item.NAME) >= 0) )
												{
													return null;
												}
												else
												{
													return (<option key={ '_ctlEditView_DUP_RIGHT_' + index.toString() } id={ '_ctlEditView_DUP_RIGHT' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
												}
											})
										}
									</select>
								</div>
							</div>
						</div>
						<div className='tabForm' style={ {display: (activeTab == 'BusinessRules' ? 'block' : 'none')} }>
							<RuleBuilder RULE_TYPE='Import' row={ rules } onChanged={ this._onChange } ref={ this.ruleBuilder} />
						</div>
						<div className='tabForm' style={ {display: (activeTab == 'Results' ? 'block' : 'none')} }>
								<div id='lblStatus'         >{ IMPORT_STATUS    }</div>
								<div id='lblSuccessCount'   >{ IMPORT_SUCCESS   }</div>
								<div id='lblDuplicateCount' >{ IMPORT_DUPLICATE }</div>
								<div id='lblFailedCount'    >
									{ IMPORT_FAILED    }
									&nbsp;
									{ Sql.ToInteger(IMPORT_FAILED_COUNT) > 0
									? <a href='#' onClick={ this._onExportErrors }>{ L10n.Term('Import.LNK_EXPORT_ERRORS') }</a>
									: null
									}
								</div>
								<br />
								<div>
									{ L10n.Term('Import.LBL_USE_TRANSACTION') }
									<input type='checkbox' className='checkbox' style={ styCheckbox } checked={ USE_TRANSACTION } onClick={ this._onUSE_TRANSACTION } />
								</div>
								{ !Sql.IsEmptyString(ProcessedFileID)
								? <div style={ {width: '100%'} }>
									<ListHeader TITLE={ L10n.Term('Import.LBL_LAST_IMPORTED') } />
									<SplendidGrid
										onLayoutLoaded={ this._onPreviewGridLayoutLoaded }
										MODULE_NAME={ MODULE_NAME }
										GRID_NAME={ MODULE_NAME + '.ListView' }
										SORT_FIELD='IMPORT_ROW_STATUS,IMPORT_ROW_NUMBER'
										SORT_DIRECTION='asc'
										hyperLinkCallback={ this._onHyperLinkCallback }
										deferLoad={ true }
										disableEdit={ true }
										disableView={ true }
										enableSelection={ false }
										scrollable
										cbCustomLoad={ this.LoadPreview }
										cbCustomColumns={ this.BootstrapColumns }
										cbRemove={ this._onRemove }
										history={ this.props.history }
										location={ this.props.location }
										match={ this.props.match }
										ref={ this.previewGrid }
									/>
								</div>
								: null
								}
						</div>
						{ bDebug 
						? <div>
							<div id='divImportMapDump' dangerouslySetInnerHTML={ {__html: importMapJson } } style={ {marginTop: '20px', border: '1px solid black'} }></div>
							<div id='divXmlSampleDump' dangerouslySetInnerHTML={ {__html: xmlSampleJson } } style={ {marginTop: '20px', border: '1px solid black'} }></div>
						</div>
						: null
						}
					</div>

					<Modal show={ isProcessing }>
						<Modal.Body style={{ minHeight: '25vh', minWidth: '25vw' }}>
							<div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
								<FontAwesomeIcon icon='spinner' spin={ true } size='5x' />
							</div>
						</Modal.Body>
					</Modal>
				</React.Fragment>
			);
		}
		else
		{
			return (
			<div id={ this.constructor.name + '_spinner' } style={ {textAlign: 'center'} }>
				<FontAwesomeIcon icon='spinner' spin={ true } size='5x' />
			</div>);
		}
	}
}

export default withRouter(ImportView);
