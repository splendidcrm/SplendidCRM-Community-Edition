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
import { XMLParser, XMLBuilder }                      from 'fast-xml-parser'                           ;
import { RouteComponentProps, withRouter }            from '../Router5'                                ;
import { observer }                                   from 'mobx-react'                                ;
import { FontAwesomeIcon }                            from '@fortawesome/react-fontawesome'            ;
import Select, { components, OptionProps, SingleValueProps } from 'react-select'                       ;
// 2. Store and Types. 
import { EditComponent }                              from '../../types/EditComponent'                 ;
import { HeaderButtons }                              from '../../types/HeaderButtons'                 ;
// 3. Scripts. 
import Sql                                            from '../../scripts/Sql'                         ;
import L10n                                           from '../../scripts/L10n'                        ;
import Security                                       from '../../scripts/Security'                    ;
import Credentials                                    from '../../scripts/Credentials'                 ;
import SplendidCache                                  from '../../scripts/SplendidCache'               ;
import SplendidDynamic_EditView                       from '../../scripts/SplendidDynamic_EditView'    ;
import { Crm_Config, Crm_Modules }                    from '../../scripts/Crm'                         ;
import { formatDate }                                 from '../../scripts/Formatting'                  ;
import { AuthenticatedMethod, LoginRedirect }         from '../../scripts/Login'                       ;
import { sPLATFORM_LAYOUT }                           from '../../scripts/SplendidInitUI'              ;
import { StartsWith, Trim, dumpObj }                  from '../../scripts/utility'                     ;
import { LoadSurveyTheme }                            from '../../scripts/SurveyUtils'                 ;
import { EditView_LoadItem, EditView_LoadLayout, EditView_ConvertItem } from '../../scripts/EditView'  ;
import { UpdateModule }                               from '../../scripts/ModuleUpdate'                ;
import { CreateSplendidRequest, GetSplendidResult }   from '../../scripts/SplendidRequest'             ;
// 4. Components and Views. 
import ErrorComponent                                 from '../../components/ErrorComponent'           ;
import DumpSQL                                        from '../../components/DumpSQL'                  ;
import DynamicButtons                                 from '../../components/DynamicButtons'           ;
import HeaderButtonsFactory                           from '../../ThemeComponents/HeaderButtonsFactory';
import SurveyQuestionFactory                          from '../../SurveyComponents'                    ;

const bDebug: boolean = false;
const ControlChars = { CrLf: '\r\n', Cr: '\r', Lf: '\n', Tab: '\t' };

interface SelectOption
{
	id  : string;
	name: string;
}

// 02/15/2024 Paul.  react-select 5.8 requires functional components. 
const QuestionTypeSingleValue = ({children, ...props}: SingleValueProps) =>
{
	//console.log((new Date()).toISOString() + ' SurveyQuestionsEditView.QuestionTypeSingleValue', props, children);
	return (
	<components.SingleValue {...props}>
		<div style={ {fontSize: '1.3em'} }>{ children }</div>
	</components.SingleValue>
	);
}

// https://react-select.com/components#components
const QuestionTypeOption = (props: OptionProps<SelectOption>) =>
{
	let QUESTION_TYPE: string = props.data.id;
	//console.log((new Date()).toISOString() + ' SurveyQuestionsEditView.QuestionTypeOption', props, QUESTION_TYPE);
	let sampleItem   : any    = { QUESTION_TYPE };
	sampleItem.ID              = 'divQuestionEditViewOption' + QUESTION_TYPE;
	sampleItem.DESCRIPTION     = L10n.ListTerm('survey_question_type', QUESTION_TYPE);
	sampleItem.QUESTION_NUMBER = 1;
	let question: any = SurveyQuestionFactory(sampleItem);

	return (<React.Fragment>
		<components.Option {...props}>
			<div className='SurveyQuestionDesignFrame SurveyQuestionFrame' style={ {backgroundColor: 'white'} }>
				<div className='SurveyQuestionContent'>
					{ React.createElement(question, { row: sampleItem, displayMode: 'Sample' }) }
				</div>
			</div>
		</components.Option>
	</React.Fragment>
	);
}

// 09/22/2023 Paul.  React is saving line breaks just as LF, not CRLF.  The old JavaScript rendering engine requires CRLF. 
function NormalizeLineBreaks(s: string)
{
	s = s.replace(/\r\n/g, ControlChars.Lf  );
	s = s.replace(/\n/g  , ControlChars.CrLf);
	return s;
}

interface IEditViewProps extends RouteComponentProps<any>
{
	MODULE_NAME        : string;
	ID?                : string;
	LAYOUT_NAME        : string;
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
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IEditViewState
{
	__total                   : number;
	__sql                     : string;
	previewIndex              : number;
	item                      : any;
	layout                    : any;
	EDIT_NAME                 : string;
	DUPLICATE                 : boolean;
	LAST_DATE_MODIFIED        : Date;
	SUB_TITLE                 : any;
	editedItem                : any;
	dependents                : Record<string, Array<any>>;
	error                     : any;
	QUESTION_TYPE_LIST        : string[];
	ANSWER_CHOICES_LABEL      : string  ;
	DISPLAY_FORMAT_LABEL      : string  ;
	DISPLAY_FORMAT_LIST_NAME  : string  ;
	DISPLAY_FORMAT_LIST       : string[];
	SURVEY_TARGET_MODULE_LIST : string[];
	TARGET_FIELD_NAME_LIST    : any   [];
	lstRatingScale            : string[];
	lstNumberOfMenus          : string[];
	OTHER_HEIGHT_LIST         : string[];
	OTHER_WIDTH_LIST          : string[];
	OTHER_VALIDATION_TYPE_LIST: string[];
	REQUIRED_TYPE_LIST        : string[];
	VALIDATION_TYPE_LIST_NAME : string  ;
	VALIDATION_TYPE_LIST      : string[];
	RANDOMIZE_TYPE_LIST       : string[];
	SIZE_UNITS_LIST           : string[];
	SIZE_HEIGHT_LIST          : string[];
	SIZE_WIDTH_LIST_NAME      : string  ;
	SIZE_WIDTH_LIST           : string[];
	BOX_HEIGHT_LIST           : string[];
	BOX_WIDTH_LIST            : string[];
	COLUMN_WIDTH_LIST         : string[];
	PLACEMENT_LIST            : string[];
	dtRatings                 : any[];
	dtMenus                   : any[];
	dtDemographicNames        : any;
}

// 09/18/2019 Paul.  Give class a unique name so that it can be debugged.  Without the unique name, Chrome gets confused.
@observer
export default class SurveyQuestionsEditView extends React.Component<IEditViewProps, IEditViewState>
{
	private _isMounted           : boolean = false;
	private refMap               : Record<string, React.RefObject<EditComponent<any, any>>>;
	private headerButtons        = React.createRef<HeaderButtons>();
	private dynamicButtonsBottom = React.createRef<DynamicButtons>();
	private SURVEY_ID            : string = null;
	private SURVEY_PAGE_ID       : string = null;
	private lstDemographicNames  : string[] = null;

	public get data (): any
	{
		let row: any = {};
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
		// 08/26/2019 Paul.  There does not seem to be a need to save date in DATE_TIME field here as this is used for search views. 
		if ( nInvalidFields == 0 )
		{
		}
		return row;
	}

	public validate(): boolean
	{
		// 08/27/2019 Paul.  Move build code to shared object. 
		let nInvalidFields: number = SplendidDynamic_EditView.Validate(this.refMap);
		return (nInvalidFields == 0);
	}

	public clear(): void
	{
		// 08/27/2019 Paul.  Move build code to shared object. 
		SplendidDynamic_EditView.Clear(this.refMap);
		if ( this._isMounted )
		{
			this.setState({ editedItem: {} });
		}
	}

	constructor(props: IEditViewProps)
	{
		super(props);
		let item = (props.rowDefaultSearch ? props.rowDefaultSearch : null);
		let EDIT_NAME = props.MODULE_NAME + '.EditView' + sPLATFORM_LAYOUT;
		if ( !Sql.IsEmptyString(props.LAYOUT_NAME) )
		{
			EDIT_NAME = props.LAYOUT_NAME;
		}
		let QUESTION_TYPE_LIST        : string[] = L10n.GetList('survey_question_type'         );
		let ANSWER_CHOICES_LABEL      : string   = L10n.Term('SurveyQuestions.LBL_ANSWER_CHOICES');
		let DISPLAY_FORMAT_LABEL      : string   = L10n.Term('SurveyQuestions.LBL_DISPLAY_FORMAT');
		let DISPLAY_FORMAT_LIST_NAME  : string   = 'survey_question_format'                     ;  // survey_question_date_format, survey_question_range_format
		let DISPLAY_FORMAT_LIST       : string[] = L10n.GetList(DISPLAY_FORMAT_LIST_NAME       );
		let SURVEY_TARGET_MODULE_LIST : string[] = L10n.GetList('survey_target_module_dom'     );
		let TARGET_FIELD_NAME_LIST    : string[] = []; // SplendidCache.ImportColumns(sSURVEY_TARGET_MODULE)
		let lstRatingScale            : string[] = L10n.GetList('survey_question_ratings_scale');
		let lstNumberOfMenus          : string[] = L10n.GetList('survey_question_menu_choices' );
		let OTHER_HEIGHT_LIST         : string[] = L10n.GetList('survey_question_field_lines'  );
		let OTHER_WIDTH_LIST          : string[] = L10n.GetList('survey_question_field_chars'  );
		let OTHER_VALIDATION_TYPE_LIST: string[] = L10n.GetList('survey_question_validation'   );
		let REQUIRED_TYPE_LIST        : string[] = L10n.GetList('survey_question_required_rows');
		let VALIDATION_TYPE_LIST_NAME : string   = 'survey_question_validation'                 ;  // survey_question_validation_numerical
		let VALIDATION_TYPE_LIST      : string[] = L10n.GetList(VALIDATION_TYPE_LIST_NAME      );
		let RANDOMIZE_TYPE_LIST       : string[] = L10n.GetList('survey_answer_randomization'  );
		let SIZE_UNITS_LIST           : string[] = L10n.GetList('survey_question_width_units'  );
		let SIZE_HEIGHT_LIST          : string[] = L10n.GetList('survey_question_field_lines'  );
		let SIZE_WIDTH_LIST_NAME      : string   = 'survey_question_width_percent'                // or survey_question_width_fixed, based on SIZE_UNITS. ;
		let SIZE_WIDTH_LIST           : string[] = L10n.GetList(SIZE_WIDTH_LIST_NAME)           ;
		let BOX_HEIGHT_LIST           : string[] = L10n.GetList('survey_question_field_lines'  );
		let BOX_WIDTH_LIST            : string[] = L10n.GetList('survey_question_field_chars'  );
		let COLUMN_WIDTH_LIST         : string[] = L10n.GetList('survey_question_columns_width');
		let PLACEMENT_LIST            : string[] = L10n.GetList('survey_question_placement'    );
		this.lstDemographicNames                 = L10n.GetList('survey_question_demographic_fields');
		// 07/11/2021 Paul. The question type list cannot be empty. 
		if ( QUESTION_TYPE_LIST == null || QUESTION_TYPE_LIST.length == 0 )
		{
			QUESTION_TYPE_LIST = 
			[ 'Radio'
			, 'Checkbox'
			, 'Dropdown'
			, 'Ranking'
			, 'Rating Scale'
			, 'Radio Matrix'
			, 'Checkbox Matrix'
			, 'Dropdown Matrix'
			, 'Text Area'
			, 'Textbox'
			, 'Textbox Multiple'
			, 'Textbox Numerical'
			, 'Plain Text'
			, 'Image'
			, 'Date'
			, 'Demographic'
			, 'Range'
			, 'Single Numerical'
			, 'Single Date'
			, 'Single Checkbox'
			, 'Hidden'
			];
		}
		// 03/07/2022 Paul.  Initialize demo if new question. 
		let dtDemographicNames: any = {};
		if ( Sql.IsEmptyGuid(props.ID) )
		{
			for ( let n: number = 0; n < this.lstDemographicNames.length; n++ )
			{
				let sNAME : string = this.lstDemographicNames[n];
				let field : any = {};
				field.VISIBLE  = true ;
				field.REQUIRED = false;
				field.NAME     = L10n.ListTerm('survey_question_demographic_fields', sNAME);
				dtDemographicNames[sNAME] = field;
			}
			}

		this.state =
		{
			__total                   : 0,
			__sql                     : null,
			previewIndex              : 0,
			item                      ,
			layout                    : null,
			EDIT_NAME                 ,
			DUPLICATE                 : false,
			LAST_DATE_MODIFIED        : null,
			SUB_TITLE                 : null,
			editedItem                : null,
			dependents                : {},
			error                     : null,
			QUESTION_TYPE_LIST        ,
			ANSWER_CHOICES_LABEL      ,
			DISPLAY_FORMAT_LABEL      ,
			DISPLAY_FORMAT_LIST_NAME  ,
			DISPLAY_FORMAT_LIST       ,
			SURVEY_TARGET_MODULE_LIST ,
			TARGET_FIELD_NAME_LIST    ,
			lstRatingScale            ,
			lstNumberOfMenus          ,
			OTHER_HEIGHT_LIST         ,
			OTHER_WIDTH_LIST          ,
			OTHER_VALIDATION_TYPE_LIST,
			REQUIRED_TYPE_LIST        ,
			VALIDATION_TYPE_LIST_NAME ,
			VALIDATION_TYPE_LIST      ,
			RANDOMIZE_TYPE_LIST       ,
			SIZE_UNITS_LIST           ,
			SIZE_HEIGHT_LIST          ,
			SIZE_WIDTH_LIST_NAME      ,
			SIZE_WIDTH_LIST           ,
			BOX_HEIGHT_LIST           ,
			BOX_WIDTH_LIST            ,
			COLUMN_WIDTH_LIST         ,
			PLACEMENT_LIST            ,
			dtRatings                 : [],
			dtMenus                   : [],
			dtDemographicNames        : dtDemographicNames,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		const { isSearchView } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount ' + this.props.MODULE_NAME + ' ' + this.props.ID, this.props.location.pathname + this.props.location.search);
		this._isMounted = true;
		try
		{
			// 05/29/2019 Paul.  In search mode, EditView will not redirect to login. 
			if ( Sql.ToBoolean(isSearchView) )
			{
				if ( Credentials.bIsAuthenticated )
				{
					await this.load();
				}
			}
			else
			{
				let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
				if ( status == 1 )
				{
					if ( Credentials.ADMIN_MODE )
					{
						Credentials.SetADMIN_MODE(false);
					}
					await this.load();
				}
				else
				{
					LoginRedirect(this.props.history, this.constructor.name + '.componentDidMount');
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
			this.setState({ error });
		}
	}

	async componentDidUpdate(prevProps: IEditViewProps)
	{
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			// 04/26/2019 Paul.  Bounce through ResetView so that layout gets completely reloaded. 
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidUpdate Reset ' + this.state.EDIT_NAME, this.props.location,  prevProps.location);
			// 11/20/2019 Paul.  Include search parameters. 
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		else
		{
			if ( this.props.onComponentComplete )
			{
				const { MODULE_NAME, ID } = this.props;
				const { item, layout, EDIT_NAME, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + EDIT_NAME, item);
				if ( layout != null && error == null )
				{
					if ( ID == null || item != null )
					{
						this.props.onComponentComplete(MODULE_NAME, null, EDIT_NAME, item);
					}
				}
			}
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private GetImportColumns = async (MODULE_NAME: string, bUpdateState: boolean) =>
	{
		let TARGET_FIELD_NAME_LIST: any[]   = [];
		if ( !Sql.IsEmptyString(MODULE_NAME) )
		{
			let res  = await CreateSplendidRequest('Import/Rest.svc/GetImportSettings?ImportModule=' + MODULE_NAME, 'GET');
			let json = await GetSplendidResult(res);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.GetImportSettings', json);
			// SURVEY_TARGET_MODULE_SelectedIndexChanged
			for ( let i: number = 0; i < json.d.importColumns.length; i++ )
			{
				let row : any    = json.d.importColumns[i];
				let NAME: string = row['NAME'];
				if ( NAME == 'DATE_ENTERED'
				  || NAME == 'DATE_MODIFIED'
				  || NAME == 'EXCHANGE_FOLDER'
				  || NAME == 'INVALID_EMAIL'
				  || NAME == 'LEAD_NUMBER'
				  || NAME == 'PROSPECT_NUMBER'
				  || NAME == 'CONTACT_NUMBER'
				  || NAME == 'ACCOUNT_NUMBER'
				  || NAME == 'PICTURE'
				  || NAME == 'ASSIGNED_SET_LIST'
				  || NAME == 'TEAM_SET_LIST'
				   )
				{
					continue;
				}
				TARGET_FIELD_NAME_LIST.push(row);
			}
			TARGET_FIELD_NAME_LIST.sort(function (a, b)
			{
				let al = a.DISPLAY_NAME.toLowerCase();
				let bl = b.DISPLAY_NAME.toLowerCase();
				return al == bl ? (a == b ? 0 : (a < b ? -1 : 1)) : (al < bl ? -1 : 1);
			});
			if ( bUpdateState )
			{
				this.setState({ TARGET_FIELD_NAME_LIST });
			}
		}
		return TARGET_FIELD_NAME_LIST;
	}

	private load = async () =>
	{
		const { MODULE_NAME, ID, DuplicateID, ConvertModule, ConvertID } = this.props;
		const { EDIT_NAME } = this.state;
		try
		{
			let SURVEY_THEME_ID: string = Crm_Config.ToString('Surveys.DefaultTheme');
			LoadSurveyTheme(SURVEY_THEME_ID);
			// 10/12/2019 Paul.  Add support for parent assignment during creation. 
			let rowDefaultSearch: any = this.props.rowDefaultSearch;
			let queryParams: any = qs.parse(location.search);
			if ( !Sql.IsEmptyGuid(queryParams['SURVEY_ID']) )
			{
				this.SURVEY_ID      = queryParams['SURVEY_ID'];
			}
			if ( !Sql.IsEmptyGuid(queryParams['SURVEY_PAGE_ID']) )
			{
				this.SURVEY_PAGE_ID = queryParams['SURVEY_PAGE_ID'];
			}
			// 05/28/2020 Paul.  Ignore missing SearchSubpanel. 
			const layout = EditView_LoadLayout(EDIT_NAME, this.props.isSearchView);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load', layout);
			// 06/19/2018 Paul.  Always clear the item when setting the layout. 
			if ( this._isMounted )
			{
				this.setState(
				{
					layout: layout,
					item: (rowDefaultSearch ? rowDefaultSearch : null),
					editedItem: null
				}, () =>
				{
					if ( this.props.onLayoutLoaded )
					{
						//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.load onLayoutLoaded');
						this.props.onLayoutLoaded();
					}
				});
				if ( !Sql.IsEmptyString(DuplicateID) )
				{
					await this.LoadItem(MODULE_NAME, DuplicateID);
				}
				else if ( !Sql.IsEmptyString(ConvertID) )
				{
					await this.ConvertItem(MODULE_NAME, ConvertModule, ConvertID);
				}
				else
				{
					await this.LoadItem(MODULE_NAME, ID);
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private LoadItem = async (sMODULE_NAME: string, sID: string) =>
	{
		const { callback, isSearchView, isUpdatePanel } = this.props;
		if ( !Sql.IsEmptyString(sID) )
		{
			try
			{
				let TARGET_FIELD_NAME_LIST: any[] = [];
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView_LoadItem(sMODULE_NAME, sID);
				let item: any = d.results;
				let LAST_DATE_MODIFIED: Date = null;
				// 03/16/2014 Paul.  LAST_DATE_MODIFIED is needed for concurrency test. 
				if ( item != null && item['DATE_MODIFIED'] !== undefined )
				{
					LAST_DATE_MODIFIED = item['DATE_MODIFIED'];
				}
				let dtRatings         : any[] = [];
				let dtMenus           : any[] = [];
				let dtDemographicNames: any = {};
				if ( item != null )
				{
					let sQUESTION_TYPE: string = item['QUESTION_TYPE'];
					if ( sQUESTION_TYPE == "Date" )
					{
						let nREQUIRED_RESPONSES_MIN: number = Sql.ToInteger(item["REQUIRED_RESPONSES_MIN"     ]);
						let nREQUIRED_RESPONSES_MAX: number = Sql.ToInteger(item["REQUIRED_RESPONSES_MAX"     ]);
						if ( nREQUIRED_RESPONSES_MIN > 0 )
						{
							let dtREQUIRED_RESPONSES_MIN: Date = new Date((new Date(1970, 1, 1)).getTime() + nREQUIRED_RESPONSES_MIN * 1000);
							item['REQUIRED_RESPONSES_MIN'] = formatDate(dtREQUIRED_RESPONSES_MIN, Security.USER_DATE_FORMAT() );
						}
						if ( nREQUIRED_RESPONSES_MAX > 0 )
						{
							let dtREQUIRED_RESPONSES_MAX: Date = new Date((new Date(1970, 1, 1)).getTime() + nREQUIRED_RESPONSES_MAX * 1000);
							item['REQUIRED_RESPONSES_MAX'] = formatDate(dtREQUIRED_RESPONSES_MAX, Security.USER_DATE_FORMAT() );
						}
					}
					let sSIZE_WIDTH: string = Sql.ToString (item["SIZE_WIDTH"]);
					if ( sSIZE_WIDTH.indexOf("%") >= 0 )
					{
						item['SIZE_UNITS'] = "Percent";
					}
					else
					{
						item['SIZE_UNITS'] = "Fixed";
					}
					if ( !Sql.IsEmptyString(item['IMAGE_URL']) )
						item['radIMAGE_URL'] = true;

					try
					{
						// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
						let sANSWER_CHOICES: string = Sql.ToString (item["ANSWER_CHOICES"]);
						let sCOLUMN_CHOICES: string = Sql.ToString (item["COLUMN_CHOICES"]);
						if ( sQUESTION_TYPE == "Rating Scale" )
						{
							item['COLUMN_CHOICES'] = null;
							// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
							let options: any = 
							{
								attributeNamePrefix: '',
								// 02/16/2024 Paul.  parser v4 creates object for Label.  
								// 02/16/2024 Paul.  Label and Weight at same level causes confusion. 
								// <Ratings>
								//	<Rating>
								//		<Label>11</Label>
								//		<Weight>1</Weight>
								//	</Rating>
								// </Ratings>
								//textNodeName       : 'Label',
								ignoreAttributes   : false,
								ignoreNameSpace    : true,
								parseAttributeValue: true,
								trimValues         : false,
							};
							const parser = new XMLParser(options);
							let xml = parser.parse(sCOLUMN_CHOICES);
							if ( xml.Ratings && xml.Ratings.Rating && Array.isArray(xml.Ratings.Rating) )
							{
								let nl: any[] = xml.Ratings.Rating;
								let nRATINGS_SCALE: number = nl.length;
								item['lstRatingScale'] = nRATINGS_SCALE.toString();
								for ( let n: number = 1; n <= nRATINGS_SCALE; n++ )
								{
									let xRating: any = nl[n - 1];
									let rating: any = {};
									rating.Label  = xRating.Label ;
									rating.Weight = xRating.Weight;
									dtRatings.push(rating);
								}
							}
						}
						else if ( sQUESTION_TYPE == "Dropdown Matrix" )
						{
							item['COLUMN_CHOICES'] = null;
							// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
							let options: any = 
							{
								attributeNamePrefix: '',
								// 02/16/2024 Paul.  parser v4 creates object for Value. 
								// 02/16/2024 Paul.  Heading and Options at same level causes confusion. 
								//textNodeName       : 'Value',
								// <Menus>
								// 	<Menu>
								// 		<Heading>Size</Heading>
								// 		<Options>Small  Medium  Large</Options>
								// 	</Menu>
								// 	<Menu>
								// 		<Heading>Color</Heading>
								// 		<Options>Red  Green  Blue</Options>
								// 	</Menu>
								// </Menus>
								ignoreAttributes   : false,
								ignoreNameSpace    : true,
								parseAttributeValue: true,
								trimValues         : false,
							};
							const parser = new XMLParser(options);
							let xml = parser.parse(sCOLUMN_CHOICES);
							if ( xml.Menus && xml.Menus.Menu && Array.isArray(xml.Menus.Menu) )
							{
								let nl: any[] = xml.Menus.Menu;
								let nMENU_ITEMS: number = nl.length;
								item['lstNumberOfMenus'] = nMENU_ITEMS.toString();
								for ( let n: number = 1; n <= nMENU_ITEMS; n++ )
								{
									let xMenu: any = nl[n - 1];
									let menu: any = {};
									menu.Heading = xMenu.Heading;
									menu.Options = xMenu.Options;
									dtMenus.push(menu);
								}
							}
						}
						else if ( sQUESTION_TYPE == "Demographic" )
						{
							item['COLUMN_CHOICES'] = null;
							// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
							let options: any = 
							{
								attributeNamePrefix: '',
								// 02/16/2024 Paul.  parser v4 does not have an issue with node name as there are no two tags in same cell. 
								// <Demographic>
								// 	<Field Name="NAME" Visible="True" Required="False" TargetField="FIRST_NAME">First Name:</Field>
								// 	<Field Name="COMPANY" Visible="True" Required="True" TargetField="LAST_NAME">Last Name:</Field>
								// </Demographic>
								textNodeName       : 'Value',
								ignoreAttributes   : false,
								ignoreNameSpace    : true,
								parseAttributeValue: true,
								trimValues         : false,
							};
							const parser = new XMLParser(options);
							let xml = parser.parse(sCOLUMN_CHOICES);
							if ( xml.Demographic && xml.Demographic.Field && Array.isArray(xml.Demographic.Field) )
							{
								let nl: any[] = xml.Demographic.Field;
								// 02/17/2024 Paul.  Not sure why started at 1 and not 0. 
								for ( let n: number = 0; n <= nl.length; n++ )
								{
									let xField: any = nl[n];
									let sNAME: string = xField.Name;
									let field : any = {};

									field['VISIBLE' ] = Sql.ToBoolean(xField.Visible );
									field['REQUIRED'] = Sql.ToBoolean(xField.Required);
									field['NAME'    ] = Sql.ToString (xField.Value   );
									// 09/30/2018 Paul.  Add survey record creation to survey. 
									if ( !Sql.IsEmptyString(item['SURVEY_TARGET_MODULE']) )
									{
										field['TARGET_FIELD_NAME'] = Sql.ToString(xField.TargetField);
									}
									dtDemographicNames[sNAME] = field;
								}
							}
						}
						// 10/08/2014 Paul.  Add Range question type. 
						else if ( sQUESTION_TYPE == "Range" )
						{
							// 09/22/2023 Paul.  React is saving line breaks just as LF, not CRLF.  The old JavaScript rendering engine requires CRLF. 
							let arrANSWER_CHOICES: string[] = NormalizeLineBreaks(sANSWER_CHOICES).split(ControlChars.CrLf);
							item['RANGE_MIN'] = arrANSWER_CHOICES[0];
							if ( arrANSWER_CHOICES.length > 0 )
								item['RANGE_MAX'] = arrANSWER_CHOICES[1];
							if ( arrANSWER_CHOICES.length > 1 )
								item['RANGE_STEP'] = arrANSWER_CHOICES[2];
						}
					}
					catch
					{
					}
					//if ( tblRankingNA.Visible && item['NA_LABEL'] != L10n.Term("SurveyQuestions.LBL_NA_LABEL_DEFAULT") )
					//	NA_LABEL.Visible = true;
					// 08/19/2023 Paul.  Update import columns. 
					if ( item['SURVEY_TARGET_MODULE'] )
					{
						TARGET_FIELD_NAME_LIST = await this.GetImportColumns(item['SURVEY_TARGET_MODULE'], false);

					}
				}
				if ( this._isMounted )
				{
					Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
					this.setState(
					{
						item              ,
						SUB_TITLE         ,
						__sql             : d.__sql,
						previewIndex      : this.state.previewIndex + 1,
						LAST_DATE_MODIFIED,
						dtRatings         ,
						dtMenus           ,
						dtDemographicNames,
						TARGET_FIELD_NAME_LIST,  // 08/19/2023 Paul.  Update import columns. 
					});
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
				this.setState({ error });
			}
		}
		else if ( !callback && !isSearchView && !isUpdatePanel )
		{
			Sql.SetPageTitle(sMODULE_NAME, null, null);
		}
	}

	private ConvertItem = async (sMODULE_NAME: string, sSOURCE_MODULE_NAME: string, sSOURCE_ID: string) =>
	{
		if ( !Sql.IsEmptyString(sSOURCE_ID) )
		{
			try
			{
				// 11/19/2019 Paul.  Change to allow return of SQL. 
				const d = await EditView_ConvertItem(sMODULE_NAME, sSOURCE_MODULE_NAME, sSOURCE_ID);
				let LAST_DATE_MODIFIED: Date = null;
				if ( this._isMounted )
				{
					let item: any = d.results;
					Sql.SetPageTitle(sMODULE_NAME, item, 'NAME');
					let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
					this.setState({ item, SUB_TITLE, __sql: d.__sql, LAST_DATE_MODIFIED });
				}
			}
			catch(error)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.LoadItem', error);
				this.setState({ error });
			}
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
			this.setState({ editedItem: item, previewIndex: this.state.previewIndex + 1 }, () =>
			{
				this._onUpdate(DATA_FIELD, DATA_VALUE);
			});
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
		const { QUESTION_TYPE_LIST, lstRatingScale, lstNumberOfMenus } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onUpdate ' + PARENT_FIELD, DATA_VALUE);
		let { dependents, dtRatings, dtMenus, dtDemographicNames } = this.state;
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
		item = Object.assign({}, this.state.item, this.state.editedItem);
		// QUESTION_TYPE_SelectedIndexChanged
		if ( PARENT_FIELD == 'QUESTION_TYPE' )
		{
			let DISPLAY_FORMAT_LABEL      = this.state.DISPLAY_FORMAT_LABEL     ;
			let DISPLAY_FORMAT_LIST_NAME  = this.state.DISPLAY_FORMAT_LIST_NAME ;
			let DISPLAY_FORMAT_LIST       = this.state.DISPLAY_FORMAT_LIST      ;
			let ANSWER_CHOICES_LABEL      = this.state.ANSWER_CHOICES_LABEL     ;
			let VALIDATION_TYPE_LIST_NAME = this.state.VALIDATION_TYPE_LIST_NAME;
			let VALIDATION_TYPE_LIST      = this.state.VALIDATION_TYPE_LIST     ;
			ANSWER_CHOICES_LABEL = L10n.Term('SurveyQuestions.LBL_ANSWER_CHOICES');
			switch ( item[PARENT_FIELD] )
			{
				case 'Radio'            :
					DISPLAY_FORMAT_LABEL     = L10n.Term('SurveyQuestions.LBL_DISPLAY_FORMAT');
					DISPLAY_FORMAT_LIST_NAME = 'survey_question_format';
					DISPLAY_FORMAT_LIST      = L10n.GetList(DISPLAY_FORMAT_LIST_NAME);
					break;
				case 'Checkbox'         :
					DISPLAY_FORMAT_LABEL     = L10n.Term('SurveyQuestions.LBL_DISPLAY_FORMAT');
					DISPLAY_FORMAT_LIST_NAME = 'survey_question_format';
					DISPLAY_FORMAT_LIST      = L10n.GetList(DISPLAY_FORMAT_LIST_NAME);
					break;
				// 11/10/2018 Paul.  Provide a way to get a single checkbox for lead population. 
				case 'Single Checkbox':
					item['BOX_WIDTH'] = '50';
					break;
				case 'Dropdown'         :
					break;
				case 'Ranking'          :
					break;
				case 'Rating Scale'     :
				{
					dtRatings = [];
					let nRATINGS_SCALE: number = 0;
					if ( lstRatingScale.length > 0 )
					{
						nRATINGS_SCALE = Sql.ToInteger(lstRatingScale[0]);
					}
					item['lstRatingScale'] = nRATINGS_SCALE;
					for ( let i: number = dtRatings.length; i < nRATINGS_SCALE; i++ )
					{
						dtRatings.push({ Label: null, Weight: (i + 1) });
					}
					break;
				}
				case 'Radio Matrix'     :
					break;
				case 'Checkbox Matrix'  :
					break;
				case 'Dropdown Matrix'  :
				{
					dtMenus = [];
					let nMENU_ITEMS: number = 0;
					if ( lstNumberOfMenus.length > 0 )
						nMENU_ITEMS = Sql.ToInteger(lstNumberOfMenus[0]);
					item['lstNumberOfMenus'] = nMENU_ITEMS;
					for ( let i: number = dtMenus.length; i < nMENU_ITEMS; i++ )
					{
						dtMenus.push({});
					}
					break;
				}
				case 'Text Area'        :
					item['BOX_WIDTH' ] = '50';
					item['BOX_HEIGHT'] = '3' ;
					break;
				case 'Textbox'          :
					item['BOX_WIDTH'] = '50';
					VALIDATION_TYPE_LIST_NAME = 'survey_question_validation';
					VALIDATION_TYPE_LIST      = L10n.GetList(VALIDATION_TYPE_LIST_NAME);
					break;
				case 'Textbox Multiple' :
					item['BOX_WIDTH'] = '50';
					// 11/07/2018 Paul.  The validation type can change its options. 
					VALIDATION_TYPE_LIST_NAME = 'survey_question_validation';
					VALIDATION_TYPE_LIST      = L10n.GetList(VALIDATION_TYPE_LIST_NAME);
					break;
				case 'Textbox Numerical':
					item['BOX_WIDTH'] = '50';
					if ( Sql.IsEmptyString(item['INVALID_DATE_MESSAGE']) )
						item['INVALID_DATE_MESSAGE'] = L10n.Term('SurveyQuestions.LBL_INVALID_NUMBER_MESSAGE_DEFAULT');
					break;
				case 'Single Numerical':
					item['BOX_WIDTH'] = '50';
					if ( Sql.IsEmptyString(item['INVALID_DATE_MESSAGE']) )
						item['INVALID_DATE_MESSAGE'] = L10n.Term('SurveyQuestions.LBL_INVALID_NUMBER_MESSAGE_DEFAULT');
					VALIDATION_TYPE_LIST_NAME = 'survey_question_validation_numerical';
					VALIDATION_TYPE_LIST      = L10n.GetList(VALIDATION_TYPE_LIST_NAME);
					break;
				case 'Plain Text'       :
					break;
				// 11/10/2018 Paul.  Provide a way to get a hidden value for lead population.
				case 'Hidden'       :
					break;
				case 'Image'            :
					ANSWER_CHOICES_LABEL = L10n.Term('SurveyQuestions.LBL_IMAGE_CAPTION');
					break;
				case 'Date'             :
					DISPLAY_FORMAT_LABEL     = L10n.Term('SurveyQuestions.LBL_DATE_FORMAT');
					DISPLAY_FORMAT_LIST_NAME = 'survey_question_date_format';
					DISPLAY_FORMAT_LIST      = L10n.GetList(DISPLAY_FORMAT_LIST_NAME);
					if ( Sql.IsEmptyString(item['INVALID_DATE_MESSAGE']) )
						item['INVALID_DATE_MESSAGE'] = L10n.Term('SurveyQuestions.LBL_INVALID_DATE_MESSAGE_DEFAULT');
					break;
				// 11/07/2018 Paul.  Provide a way to get a single numerical value for lead population.  Just like textbox but with numeric validation. 
				case 'Single Date':
					DISPLAY_FORMAT_LABEL     = L10n.Term('SurveyQuestions.LBL_DATE_FORMAT');
					DISPLAY_FORMAT_LIST_NAME = 'survey_question_date_format';
					DISPLAY_FORMAT_LIST      = L10n.GetList(DISPLAY_FORMAT_LIST_NAME);
					if ( Sql.IsEmptyString(item['INVALID_DATE_MESSAGE']) )
						item['INVALID_DATE_MESSAGE'] = L10n.Term('SurveyQuestions.LBL_INVALID_DATE_MESSAGE_DEFAULT');
					VALIDATION_TYPE_LIST_NAME = 'survey_question_validation_date';
					VALIDATION_TYPE_LIST      = L10n.GetList(VALIDATION_TYPE_LIST_NAME);
					break;
				case 'Demographic'      :
					item['BOX_WIDTH'] = '50';
					break;
				// 10/08/2014 Paul.  Add Range question type. 
				case 'Range'            :
					DISPLAY_FORMAT_LABEL     = L10n.Term('SurveyQuestions.LBL_DISPLAY_FORMAT');
					DISPLAY_FORMAT_LIST_NAME = 'survey_question_range_format';
					DISPLAY_FORMAT_LIST      = L10n.GetList(DISPLAY_FORMAT_LIST_NAME);
					item['RANGE_MIN' ] = '0'  ;
					item['RANGE_MAX' ] = '100';
					item['RANGE_STEP'] = '1'  ;
					break;
			}
			this.setState(
			{
				previewIndex             : this.state.previewIndex + 1,
				editedItem               : item,
				DISPLAY_FORMAT_LABEL     ,
				DISPLAY_FORMAT_LIST_NAME ,
				DISPLAY_FORMAT_LIST      ,
				ANSWER_CHOICES_LABEL     ,
				VALIDATION_TYPE_LIST_NAME,
				VALIDATION_TYPE_LIST     ,
				dtRatings                ,
				dtMenus                  ,
				dtDemographicNames       ,
			});
		}
		// REQUIRED_TYPE_SelectedIndexChanged
		else if ( PARENT_FIELD == 'REQUIRED_TYPE' )
		{
			let REQUIRED_MESSAGE: string = item['REQUIRED_MESSAGE'];
			switch ( item[PARENT_FIELD] )
			{
				case 'All'     :
					break;
				case 'At Least':
					REQUIRED_MESSAGE = L10n.Term('SurveyQuestions.LBL_REQUIRED_MESSAGE_DEFAULT1');
					break;
				case 'At Most' :
					REQUIRED_MESSAGE = L10n.Term('SurveyQuestions.LBL_REQUIRED_MESSAGE_DEFAULT1');
					break;
				case 'Exactly' :
					REQUIRED_MESSAGE = L10n.Term('SurveyQuestions.LBL_REQUIRED_MESSAGE_DEFAULT1');
					break;
				case 'Range'   :
					REQUIRED_MESSAGE = L10n.Term('SurveyQuestions.LBL_REQUIRED_MESSAGE_DEFAULT2');
					break;
			}
			item['REQUIRED_MESSAGE'] = REQUIRED_MESSAGE;
			this.setState({ editedItem: item, previewIndex: this.state.previewIndex + 1 });
		}
		// lstNumberOfMenus_SelectedIndexChanged
		// lstRatingScale_SelectedIndexChanged
		// OTHER_VALIDATION_TYPE_SelectedIndexChanged
		else if ( PARENT_FIELD == 'OTHER_VALIDATION_TYPE' )
		{
			let OTHER_VALIDATION_MIN    : string = item['OTHER_VALIDATION_MIN'    ];
			let OTHER_VALIDATION_MAX    : string = item['OTHER_VALIDATION_MAX'    ];
			let OTHER_VALIDATION_MESSAGE: string = item['OTHER_VALIDATION_MESSAGE'];
			switch ( item[PARENT_FIELD] )
			{
				case ''               :
					break;
				case 'Specific Length':
					OTHER_VALIDATION_MIN     = '0';
					OTHER_VALIDATION_MAX     = '5000';
					OTHER_VALIDATION_MESSAGE = L10n.Term('SurveyQuestions.LBL_OTHER_VALIDATION_MESSAGE_DEFAULT2');
					break;
				case 'Integer'        :
					OTHER_VALIDATION_MIN     = '0';
					OTHER_VALIDATION_MAX     = '100';
					OTHER_VALIDATION_MESSAGE = L10n.Term('SurveyQuestions.LBL_OTHER_VALIDATION_MESSAGE_DEFAULT2');
					break;
				case 'Decimal'        :
					OTHER_VALIDATION_MIN     = '0.0';
					OTHER_VALIDATION_MAX     = '100.0';
					OTHER_VALIDATION_MESSAGE = L10n.Term('SurveyQuestions.LBL_OTHER_VALIDATION_MESSAGE_DEFAULT2');
					break;
				case 'Date'           :
				{
					let now: Date = new Date();
					let nextYear: Date = new Date(now.getFullYear() + 1, now.getMonth(), now.getDate());
					OTHER_VALIDATION_MIN     = formatDate(now     , Security.USER_DATE_FORMAT());
					OTHER_VALIDATION_MAX     = formatDate(nextYear, Security.USER_DATE_FORMAT());
					OTHER_VALIDATION_MESSAGE = L10n.Term('SurveyQuestions.LBL_OTHER_VALIDATION_MESSAGE_DEFAULT2');
					break;
				}
				case 'Email'          :
					OTHER_VALIDATION_MESSAGE = L10n.Term('SurveyQuestions.LBL_OTHER_VALIDATION_MESSAGE_DEFAULT');
					break;
			}
			item['OTHER_VALIDATION_MIN'    ] = OTHER_VALIDATION_MIN    ;
			item['OTHER_VALIDATION_MAX'    ] = OTHER_VALIDATION_MAX    ;
			item['OTHER_VALIDATION_MESSAGE'] = OTHER_VALIDATION_MESSAGE;
			this.setState({ editedItem: item, previewIndex: this.state.previewIndex + 1 });
		}
		// VALIDATION_TYPE_SelectedIndexChanged
		else if ( PARENT_FIELD == 'VALIDATION_TYPE' )
		{
			let VALIDATION_MIN    : string = item['VALIDATION_MIN'    ];
			let VALIDATION_MAX    : string = item['VALIDATION_MAX'    ];
			let VALIDATION_MESSAGE: string = item['VALIDATION_MESSAGE'];
			switch ( item[PARENT_FIELD] )
			{
				case ''               :
					break;
				case 'Specific Length':
					VALIDATION_MIN     = '0';
					VALIDATION_MAX     = '5000';
					VALIDATION_MESSAGE = L10n.Term('SurveyQuestions.LBL_VALIDATION_MESSAGE_DEFAULT2');
					break;
				case 'Integer'        :
					VALIDATION_MIN     = '0';
					VALIDATION_MAX     = '100';
					VALIDATION_MESSAGE = L10n.Term('SurveyQuestions.LBL_VALIDATION_MESSAGE_DEFAULT2');
					break;
				case 'Decimal'        :
					VALIDATION_MIN     = '0.0';
					VALIDATION_MAX     = '100.0';
					VALIDATION_MESSAGE = L10n.Term('SurveyQuestions.LBL_VALIDATION_MESSAGE_DEFAULT2');
					break;
				case 'Date'           :
				{
					let now: Date = new Date();
					let nextYear: Date = new Date(now.getFullYear() + 1, now.getMonth(), now.getDate());
					VALIDATION_MIN     = formatDate(now     , Security.USER_DATE_FORMAT());
					VALIDATION_MAX     = formatDate(nextYear, Security.USER_DATE_FORMAT());
					VALIDATION_MESSAGE = L10n.Term('SurveyQuestions.LBL_VALIDATION_MESSAGE_DEFAULT2');
					break;
				}
				case 'Email'          :
					VALIDATION_MESSAGE = L10n.Term('SurveyQuestions.LBL_VALIDATION_MESSAGE_DEFAULT');
					break;
			}
			item['VALIDATION_MIN'    ] = VALIDATION_MIN    ;
			item['VALIDATION_MAX'    ] = VALIDATION_MAX    ;
			item['VALIDATION_MESSAGE'] = VALIDATION_MESSAGE;
			this.setState({ editedItem: item, previewIndex: this.state.previewIndex + 1 });
		}
		// SIZE_UNITS_SelectedIndexChanged
		else if ( PARENT_FIELD == 'SIZE_UNITS' )
		{
			let SIZE_WIDTH_LIST_NAME: string   = item['SIZE_WIDTH_LIST_NAME'];
			let SIZE_WIDTH_LIST     : string[] = item['SIZE_WIDTH_LIST'     ];
			switch ( item[PARENT_FIELD] )
			{
				case 'Percent':
					SIZE_WIDTH_LIST_NAME = 'survey_question_width_percent';
					SIZE_WIDTH_LIST      = L10n.GetList(SIZE_WIDTH_LIST_NAME);
					break;
				case 'Fixed'  :
					SIZE_WIDTH_LIST_NAME = 'survey_question_width_fixed';
					SIZE_WIDTH_LIST      = L10n.GetList(SIZE_WIDTH_LIST_NAME);
					break;
			}
			item['SIZE_WIDTH_LIST_NAME'] = SIZE_WIDTH_LIST_NAME;
			item['SIZE_WIDTH_LIST'     ] = SIZE_WIDTH_LIST     ;
			this.setState({ editedItem: item, previewIndex: this.state.previewIndex + 1 });
		}
		// NA_ENABLED_CheckedChanged
		else if ( PARENT_FIELD == 'NA_ENABLED' )
		{
			if ( Sql.ToBoolean(item[PARENT_FIELD]) )
			{
				item['NA_LABEL'] = L10n.Term('SurveyQuestions.LBL_NA_LABEL_DEFAULT');
				this.setState({ editedItem: item, previewIndex: this.state.previewIndex + 1 });
			}
		}
		// REQUIRED_CheckedChanged
		else if ( PARENT_FIELD == 'REQUIRED' )
		{
			if ( Sql.ToBoolean(item[PARENT_FIELD]) )
			{
				item['REQUIRED_MESSAGE'] = L10n.Term('SurveyQuestions.LBL_REQUIRED_MESSAGE_DEFAULT');
				this.setState({ editedItem: item, previewIndex: this.state.previewIndex + 1 });
			}
		}
		// VALIDATION_SUM_ENABLED_CheckedChanged
		else if ( PARENT_FIELD == 'VALIDATION_SUM_ENABLED' )
		{
			if ( Sql.ToBoolean(item[PARENT_FIELD]) )
			{
				item['VALIDATION_SUM_MESSAGE'] = L10n.Term('SurveyQuestions.LBL_VALIDATION_SUM_MESSAGE_DEFAULT');
				this.setState({ editedItem: item, previewIndex: this.state.previewIndex + 1 });
			}
		}
		// OTHER_ENABLED_CheckedChanged
		else if ( PARENT_FIELD == 'OTHER_ENABLED' )
		{
			if ( Sql.ToBoolean(item[PARENT_FIELD]) )
			{
				item['OTHER_LABEL'] = L10n.Term('SurveyQuestions.LBL_OTHER_LABEL_DEFAULT');
				this.setState({ editedItem: item, previewIndex: this.state.previewIndex + 1 });
			}
		}
		// OTHER_AS_CHOICE_CheckedChanged
		else if ( PARENT_FIELD == 'OTHER_AS_CHOICE' )
		{
			if ( Sql.ToBoolean(item[PARENT_FIELD]) )
			{
				item['OTHER_REQUIRED_MESSAGE'] = L10n.Term('SurveyQuestions.LBL_OTHER_REQUIRED_MESSAGE_DEFAULT');
				this.setState({ editedItem: item, previewIndex: this.state.previewIndex + 1 });
			}
		}
		// SURVEY_TARGET_MODULE_SelectedIndexChanged
		else if ( PARENT_FIELD == 'SURVEY_TARGET_MODULE' )
		{
			if ( !Sql.IsEmptyString(item[PARENT_FIELD]) )
			{
				this.GetImportColumns(item[PARENT_FIELD], true);
			}
		}
		else if ( PARENT_FIELD == 'lstRatingScale' )
		{
			let nRATINGS_SCALE: number = Sql.ToInteger(DATA_VALUE);
			if ( nRATINGS_SCALE > dtRatings.length )
			{
				for ( let i: number = dtRatings.length; i < nRATINGS_SCALE; i++ )
				{
					dtRatings.push({ Label: null, Weight: (i + 1) });
				}
			}
			else if ( nRATINGS_SCALE < dtRatings.length )
			{
				dtRatings = dtRatings.slice(0, nRATINGS_SCALE);
			}
			this.setState({ dtRatings, previewIndex: this.state.previewIndex + 1 });
		}
		else if ( PARENT_FIELD == 'lstNumberOfMenus' )
		{
			let nMENU_ITEMS: number = Sql.ToInteger(DATA_VALUE);
			if ( nMENU_ITEMS > dtMenus.length )
			{
				for ( let i: number = dtMenus.length; i < nMENU_ITEMS; i++ )
				{
					dtMenus.push({});
				}
			}
			else if ( nMENU_ITEMS < dtMenus.length )
			{
				dtMenus = dtMenus.slice(0, nMENU_ITEMS);
			}
			this.setState({ dtMenus, previewIndex: this.state.previewIndex + 1 });
		}
		else if ( PARENT_FIELD == 'IMAGE_URL' )
		{
			item['radIMAGE_URL'] = true;
			this.setState({ editedItem: item, previewIndex: this.state.previewIndex + 1 });
		}
	}

	// QUESTION_TYPE_SelectedIndexChanged
	private fieldVisibility = (fieldName: string): boolean =>
	{
		const { QUESTION_TYPE_LIST } = this.state;
		const currentItem = Object.assign({ QUESTION_TYPE: QUESTION_TYPE_LIST[0] }, this.state.item, this.state.editedItem);
		let QUESTION_TYPE: string = currentItem['QUESTION_TYPE'];
		let visible: any = {};
		visible['labDisplayFormat'    ] = false;
		visible['DISPLAY_FORMAT'      ] = false;
		visible['pnlAnswer'           ] = false;
		// 11/07/2018 Paul.  Provide a way to get a single numerical value for lead population.  Just like textbox but with numeric validation. 
		visible['tblAnswerChoices'    ] = true;
		// 11/10/2018 Paul.  QuestionSize is visible to all but Hidden. 
		visible['divQuestionSize'     ] = true;
		// 10/08/2014 Paul.  Add Range question type. 
		visible['pnlRange'            ] = false;
		visible['tblInvalidDate'      ] = false;
		visible['tblInvalidNumber'    ] = false;
		visible['tblRankingNA'        ] = false;
		visible['pnlRatingScale'      ] = false;
		visible['tblColumnChoices'    ] = false;
		visible['tblForcedRanking'    ] = false;
		visible['pnlMenuChoices'      ] = false;
		visible['pnlDemographic'      ] = false;
		visible['pnlRequired'         ] = false;
		visible['REQUIRED'            ] = true;
		visible['tblRequiredType'     ] = false;
		visible['pnlValidationEnabled'] = false;
		visible['pnlValidationSum'    ] = false;
		visible['pnlOther'            ] = false;
		visible['pnlRandomize'        ] = false;
		// 03/10/2019 Paul.  The Name field will be visible to all. 
		visible['pnlName'             ] = true;
		visible['pnlImage'            ] = false;
		visible['OTHER_AS_CHOICE'     ] = false;
		visible['OTHER_ONE_PER_ROW'   ] = false;
		visible['trOtherAsChoice'     ] = false;
		visible['tblSize'             ] = false;
		visible['SIZE_UNITS'          ] = false;
		visible['SIZE_HEIGHT'         ] = false;
		visible['SIZE_WIDTH'          ] = false;
		visible['tblColumnWidth'      ] = false;
		visible['RANDOMIZE_NOT_LAST'  ] = false;
		visible['tblBoxSize'          ] = false;
		visible['BOX_WIDTH'           ] = false;
		visible['BOX_HEIGHT'          ] = false;
		// 09/30/2018 Paul.  Add survey record creation to survey. 
		visible['SURVEY_TARGET_LABEL' ] = false;
		visible['SURVEY_TARGET_MODULE'] = false;
		visible['TARGET_FIELD_LABEL'  ] = false;
		visible['TARGET_FIELD_NAME'   ] = false;
		switch ( QUESTION_TYPE )
		{
			case 'Radio'            :
				visible['pnlAnswer'           ] = true;
				visible['pnlOther'            ] = true;
				visible['OTHER_AS_CHOICE'     ] = true;
				visible['trOtherAsChoice'     ] = true;
				visible['pnlRequired'         ] = true;
				visible['pnlRandomize'        ] = true;
				visible['RANDOMIZE_NOT_LAST'  ] = true;
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				visible['labDisplayFormat'    ] = true;
				visible['DISPLAY_FORMAT'      ] = true;
				// 09/30/2018 Paul.  Add survey record creation to survey. 
				visible['SURVEY_TARGET_LABEL' ] = true;
				visible['SURVEY_TARGET_MODULE'] = true;
				visible['TARGET_FIELD_LABEL'  ] = true;
				visible['TARGET_FIELD_NAME'   ] = true;
				break;
			case 'Checkbox'         :
				visible['pnlAnswer'           ] = true;
				visible['pnlOther'            ] = true;
				visible['OTHER_AS_CHOICE'     ] = true;
				visible['trOtherAsChoice'     ] = true;
				visible['pnlRequired'         ] = true;
				visible['tblRequiredType'     ] = true;
				visible['pnlRandomize'        ] = true;
				visible['RANDOMIZE_NOT_LAST'  ] = true;
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				visible['labDisplayFormat'    ] = true;
				visible['DISPLAY_FORMAT'      ] = true;
				break;
			// 11/10/2018 Paul.  Provide a way to get a single checkbox for lead population. 
			case 'Single Checkbox':
				visible['tblInvalidNumber'    ] = false;
				visible['pnlAnswer'           ] = true;
				visible['tblAnswerChoices'    ] = true;
				visible['pnlRequired'         ] = true;
				visible['tblRequiredType'     ] = false;
				visible['pnlValidationEnabled'] = false;
				visible['pnlValidationSum'    ] = false;
				// 11/12/2018 Paul.  Enable size fields. 
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				visible['tblBoxSize'          ] = true;
				visible['BOX_WIDTH'           ] = true;
				visible['SURVEY_TARGET_LABEL' ] = true;
				visible['SURVEY_TARGET_MODULE'] = true;
				visible['TARGET_FIELD_LABEL'  ] = true;
				visible['TARGET_FIELD_NAME'   ] = true;
				break;
			case 'Dropdown'         :
				visible['pnlAnswer'           ] = true;
				visible['pnlOther'            ] = true;
				visible['OTHER_AS_CHOICE'     ] = true;
				visible['trOtherAsChoice'     ] = true;
				visible['pnlRequired'         ] = true;
				visible['pnlRandomize'        ] = true;
				visible['RANDOMIZE_NOT_LAST'  ] = true;
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				// 09/30/2018 Paul.  Add survey record creation to survey. 
				visible['SURVEY_TARGET_LABEL' ] = true;
				visible['SURVEY_TARGET_MODULE'] = true;
				visible['TARGET_FIELD_LABEL'  ] = true;
				visible['TARGET_FIELD_NAME'   ] = true;
				break;
			case 'Ranking'          :
				visible['pnlAnswer'           ] = true;
				visible['tblRankingNA'        ] = true;
				visible['pnlRequired'         ] = true;
				visible['pnlRandomize'        ] = true;
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				break;
			case 'Rating Scale'     :
				visible['pnlAnswer'           ] = true;
				visible['tblRankingNA'        ] = true;
				visible['pnlOther'            ] = true;
				visible['pnlRequired'         ] = true;
				visible['tblRequiredType'     ] = true;
				visible['pnlRandomize'        ] = true;
				visible['RANDOMIZE_NOT_LAST'  ] = true;
				visible['pnlRatingScale'      ] = true;
				visible['tblForcedRanking'    ] = true;
				visible['tblColumnWidth'      ] = true;
				visible['OTHER_ONE_PER_ROW'   ] = true;
				visible['trOtherAsChoice'     ] = true;
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				break;
			case 'Radio Matrix'     :
				visible['pnlAnswer'           ] = true;
				visible['tblColumnChoices'    ] = true;
				visible['pnlOther'            ] = true;
				visible['pnlRequired'         ] = true;
				visible['tblRequiredType'     ] = true;
				visible['pnlRandomize'        ] = true;
				visible['tblForcedRanking'    ] = true;
				visible['tblColumnWidth'      ] = true;
				visible['RANDOMIZE_NOT_LAST'  ] = true;
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				break;
			case 'Checkbox Matrix'  :
				visible['pnlAnswer'           ] = true;
				visible['tblColumnChoices'    ] = true;
				visible['pnlOther'            ] = true;
				visible['pnlRequired'         ] = true;
				visible['tblRequiredType'     ] = true;
				visible['pnlRandomize'        ] = true;
				visible['RANDOMIZE_NOT_LAST'  ] = true;
				visible['tblColumnWidth'      ] = true;
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				break;
			case 'Dropdown Matrix'  :
				visible['pnlAnswer'           ] = true;
				visible['pnlMenuChoices'      ] = true;
				visible['pnlOther'            ] = true;
				visible['pnlRequired'         ] = true;
				visible['tblRequiredType'     ] = true;
				visible['pnlRandomize'        ] = true;
				visible['RANDOMIZE_NOT_LAST'  ] = true;
				visible['tblColumnWidth'      ] = true;
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				break;
			case 'Text Area'        :
				visible['pnlRequired'         ] = true;
				// 11/12/2018 Paul.  Enable size fields. 
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				visible['tblBoxSize'          ] = true;
				visible['BOX_WIDTH'           ] = true;
				visible['BOX_HEIGHT'          ] = true;
				// 09/30/2018 Paul.  Add survey record creation to survey. 
				visible['SURVEY_TARGET_LABEL' ] = true;
				visible['SURVEY_TARGET_MODULE'] = true;
				visible['TARGET_FIELD_LABEL'  ] = true;
				visible['TARGET_FIELD_NAME'   ] = true;
				break;
			case 'Textbox'          :
				visible['pnlRequired'         ] = true;
				visible['pnlValidationEnabled'] = true;
				// 11/12/2018 Paul.  Enable size fields. 
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				visible['tblBoxSize'          ] = true;
				visible['BOX_WIDTH'           ] = true;
				// 09/30/2018 Paul.  Add survey record creation to survey. 
				visible['SURVEY_TARGET_LABEL' ] = true;
				visible['SURVEY_TARGET_MODULE'] = true;
				visible['TARGET_FIELD_LABEL'  ] = true;
				visible['TARGET_FIELD_NAME'   ] = true;
				break;
			case 'Textbox Multiple' :
				visible['pnlAnswer'           ] = true;
				visible['pnlRequired'         ] = true;
				visible['tblRequiredType'     ] = true;
				visible['pnlRandomize'        ] = true;
				visible['RANDOMIZE_NOT_LAST'  ] = true;
				visible['pnlValidationEnabled'] = true;
				visible['tblColumnWidth'      ] = true;
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				visible['tblBoxSize'          ] = true;
				visible['BOX_WIDTH'           ] = true;
				break;
			case 'Textbox Numerical':
				visible['tblInvalidNumber'    ] = true;
				visible['pnlAnswer'           ] = true;
				visible['pnlRequired'         ] = true;
				visible['tblRequiredType'     ] = true;
				visible['pnlRandomize'        ] = true;
				visible['RANDOMIZE_NOT_LAST'  ] = true;
				visible['pnlValidationSum'    ] = true;
				visible['tblColumnWidth'      ] = true;
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				visible['tblBoxSize'          ] = true;
				visible['BOX_WIDTH'           ] = true;
				break;
			// 11/07/2018 Paul.  Provide a way to get a single numerical value for lead population.  Just like textbox but with numeric validation. 
			case 'Single Numerical':
				visible['tblInvalidNumber'    ] = true;
				visible['pnlAnswer'           ] = true;
				visible['tblAnswerChoices'    ] = false;
				visible['pnlRequired'         ] = true;
				visible['tblRequiredType'     ] = false;
				visible['pnlValidationEnabled'] = true;
				visible['pnlValidationSum'    ] = false;
				// 11/12/2018 Paul.  Enable size fields. 
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				visible['tblBoxSize'          ] = true;
				visible['BOX_WIDTH'           ] = true;
				visible['SURVEY_TARGET_LABEL' ] = true;
				visible['SURVEY_TARGET_MODULE'] = true;
				visible['TARGET_FIELD_LABEL'  ] = true;
				visible['TARGET_FIELD_NAME'   ] = true;
				break;
			case 'Plain Text'       :
				visible['pnlName'             ] = true;
				// 11/12/2018 Paul.  Enable size fields. 
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				break;
			// 11/10/2018 Paul.  Provide a way to get a hidden value for lead population.
			case 'Hidden'       :
				visible['pnlAnswer'           ] = true;
				visible['SURVEY_TARGET_LABEL' ] = true;
				visible['SURVEY_TARGET_MODULE'] = true;
				visible['TARGET_FIELD_LABEL'  ] = true;
				visible['TARGET_FIELD_NAME'   ] = true;
				visible['divQuestionSize'     ] = false;
				break;
			case 'Image'            :
				visible['pnlName'             ] = true;
				visible['pnlImage'            ] = true;
				// 11/24/2018 Paul.  Place image caption in ANSWER_CHOICES. 
				visible['pnlAnswer'           ] = true;
				visible['tblAnswerChoices'    ] = true;
				// 11/12/2018 Paul.  Enable size fields. 
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				break;
			case 'Date'             :
				visible['pnlAnswer'           ] = true;
				visible['tblInvalidDate'      ] = true;
				visible['pnlRequired'         ] = true;
				visible['tblRequiredType'     ] = true;
				visible['pnlRandomize'        ] = true;
				visible['tblColumnWidth'      ] = true;
				visible['RANDOMIZE_NOT_LAST'  ] = true;
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				visible['labDisplayFormat'    ] = true;
				visible['DISPLAY_FORMAT'      ] = true;
				break;
			// 11/07/2018 Paul.  Provide a way to get a single numerical value for lead population.  Just like textbox but with numeric validation. 
			case 'Single Date':
				visible['pnlAnswer'           ] = true;
				visible['tblAnswerChoices'    ] = false;
				visible['tblInvalidDate'      ] = true;
				visible['pnlRequired'         ] = true;
				visible['tblRequiredType'     ] = false;
				visible['pnlValidationEnabled'] = true;
				// 11/12/2018 Paul.  Enable size fields. 
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				visible['tblBoxSize'          ] = true;
				visible['BOX_WIDTH'           ] = true;
				visible['labDisplayFormat'    ] = true;
				visible['DISPLAY_FORMAT'      ] = true;
				visible['SURVEY_TARGET_LABEL' ] = true;
				visible['SURVEY_TARGET_MODULE'] = true;
				visible['TARGET_FIELD_LABEL'  ] = true;
				visible['TARGET_FIELD_NAME'   ] = true;
				break;
			case 'Demographic'      :
				visible['REQUIRED'            ] = false;
				visible['pnlDemographic'      ] = true;
				visible['pnlRequired'         ] = true;
				visible['tblColumnWidth'      ] = true;
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				visible['tblBoxSize'          ] = true;
				visible['BOX_WIDTH'           ] = true;
				// 09/30/2018 Paul.  Add survey record creation to survey. 
				visible['SURVEY_TARGET_LABEL' ] = true;
				visible['SURVEY_TARGET_MODULE'] = true;
				visible['TARGET_FIELD_LABEL'  ] = false;
				visible['TARGET_FIELD_NAME'   ] = false;
				break;
			// 10/08/2014 Paul.  Add Range question type. 
			case 'Range'            :
				visible['pnlRange'            ] = true;
				// 11/12/2018 Paul.  Enable size fields. 
				visible['tblSize'             ] = true;
				visible['SIZE_UNITS'          ] = true;
				visible['SIZE_WIDTH'          ] = true;
				visible['labDisplayFormat'    ] = true;
				visible['DISPLAY_FORMAT'      ] = true;
				visible['pnlRequired'         ] = true;
				visible['SURVEY_TARGET_LABEL' ] = true;
				visible['SURVEY_TARGET_MODULE'] = true;
				visible['TARGET_FIELD_LABEL'  ] = true;
				visible['TARGET_FIELD_NAME'   ] = true;
				break;
		}
		if ( Sql.IsEmptyString(currentItem['SURVEY_TARGET_MODULE']) )
		{
			visible['TARGET_FIELD_LABEL'  ] = false;
			visible['TARGET_FIELD_NAME'   ] = false;
		}
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.fieldVisibility ' + QUESTION_TYPE + ' ' + fieldName, visible[fieldName]);
		return visible[fieldName];
	}

	// 06/15/2018 Paul.  The SearchView will register for the onSubmit event. 
	private _onSubmit = (): void =>
	{
		try
		{
			if ( this.props.onSubmit )
			{
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit');
				this.props.onSubmit();
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onSubmit', error);
			this.setState({ error });
		}
	}

	private buildRatingScale = (row: any, dtRatings: any[]) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.buildRatingScale', dtRatings);
		// https://www.npmjs.com/package/fast-xml-parser
		let options: any = 
		{
			attributeNamePrefix: '@',
			// 02/16/2024 Paul.  parser v4 creates object for Label.  
			// 02/16/2024 Paul.  Label and Weight at same level causes confusion. 
			// <Ratings>
			//	<Rating>
			//		<Label>11</Label>
			//		<Weight>1</Weight>
			//	</Rating>
			// </Ratings>
			//textNodeName       : 'Label',
			ignoreAttributes   : false,
			ignoreNameSpace    : true,
			parseAttributeValue: true,
			trimValues         : false,
			format             : true,
			// 02/17/2024 Paul.  parser v4 requires suppressBooleanAttributes, otherwise Visible does not include ="true"
			allowBooleanAttributes: true,
			suppressBooleanAttributes: false,
		};
		// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
		const builder = new XMLBuilder(options);

		let xml: any = {};
		xml.Ratings = {};
		xml.Ratings.Rating = [];
		let nRATINGS_SCALE: number = Sql.ToInteger(row['lstRatingScale']);
		for ( let n: number = 0; n <= nRATINGS_SCALE; n++ )
		{
			let xRating: any = {};
			if ( dtRatings[n] )
			{
				xml.Ratings.Rating.push(xRating);
				xRating.Label  = Sql.ToString (dtRatings[n].Label );
				xRating.Weight = Sql.ToInteger(dtRatings[n].Weight);
			}
		}
		let sCOLUMN_CHOICES: string = '<?xml version="1.0" encoding="UTF-8"?>' + builder.build(xml);
		return sCOLUMN_CHOICES;
	}

	private buildDropdownMatrix = (row: any, dtMenus: any[]) =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.buildDropdownMatrix', dtMenus);
		// https://www.npmjs.com/package/fast-xml-parser
		let options: any = 
		{
			attributeNamePrefix: '@',
			// 02/16/2024 Paul.  parser v4 creates object for Value. 
			// 02/16/2024 Paul.  Heading and Options at same level causes confusion. 
			//textNodeName       : 'Value',
			// <Menus>
			// 	<Menu>
			// 		<Heading>Size</Heading>
			// 		<Options>Small  Medium  Large</Options>
			// 	</Menu>
			// 	<Menu>
			// 		<Heading>Color</Heading>
			// 		<Options>Red  Green  Blue</Options>
			// 	</Menu>
			// </Menus>
			ignoreAttributes   : false,
			ignoreNameSpace    : true,
			parseAttributeValue: true,
			trimValues         : false,
			format             : true,
			// 02/17/2024 Paul.  parser v4 requires suppressBooleanAttributes, otherwise Visible does not include ="true"
			allowBooleanAttributes: true,
			suppressBooleanAttributes: false,
		};
		// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
		const builder = new XMLBuilder(options);

		let xml: any = {};
		xml.Menus = {};
		xml.Menus.Menu = [];
		let nMENU_ITEMS: number = Sql.ToInteger(row['lstNumberOfMenus']);
		for ( let n: number = 0; n <= nMENU_ITEMS; n++ )
		{
			let xMenu: any = {};
			if ( dtMenus[n] )
			{
				xml.Menus.Menu.push(xMenu);
				xMenu.Heading = Sql.ToString(dtMenus[n].Heading).replace(/\s\s*$/, '');  // TrimEnd();
				xMenu.Options = Sql.ToString(dtMenus[n].Options).replace(/\s\s*$/, '');  // TrimEnd();
			}
		}
		let sCOLUMN_CHOICES: string = '<?xml version="1.0" encoding="UTF-8"?>' + builder.build(xml);
		return sCOLUMN_CHOICES;
	}

	private buildDemographic = (row: any, dtDemographicNames: any) =>
	{
		// https://www.npmjs.com/package/fast-xml-parser
		let options: any = 
		{
			attributeNamePrefix: '@',
			// 02/16/2024 Paul.  parser v4 does not have an issue with node name as there are no two tags in same cell. 
			// <Demographic>
			// 	<Field Name="NAME" Visible="True" Required="False" TargetField="FIRST_NAME">First Name:</Field>
			// 	<Field Name="COMPANY" Visible="True" Required="True" TargetField="LAST_NAME">Last Name:</Field>
			// </Demographic>
			textNodeName       : 'Value',
			ignoreAttributes   : false,
			ignoreNameSpace    : true,
			parseAttributeValue: true,
			trimValues         : false,
			format             : true,
			// 02/17/2024 Paul.  parser v4 requires suppressBooleanAttributes, otherwise Visible does not include ="true"
			allowBooleanAttributes: true,
			suppressBooleanAttributes: false,
		};
		// 02/16/2024 Paul.  Upgrade to fast-xml-parser v4. 
		const builder = new XMLBuilder(options);

		let xml: any = {};
		xml.Demographic = {};
		xml.Demographic.Field = [];
		for ( let n: number = 0; n < this.lstDemographicNames.length; n++ )
		{
			let sNAME : string = this.lstDemographicNames[n];
			let field : any = dtDemographicNames[sNAME];
			let xField: any = {};
			xml.Demographic.Field.push(xField);
			xField["@Name"    ] = sNAME;
			xField["@Visible" ] = (field ? field['VISIBLE' ] : false);
			xField["@Required"] = (field ? field['REQUIRED'] : false);
			// 03/07/2022 Paul.  Value should be cap first. 
			xField.Value        = (field ? field['NAME'    ] : null );
			if ( Sql.ToBoolean(row["DEMOGRAPHIC_" + sNAME + "_REQUIRED"]) )
				row['REQUIRED'] = true;
			// 09/30/2018 Paul.  Add survey record creation to survey. 
			if ( !Sql.IsEmptyString(row['SURVEY_TARGET_MODULE']) )
			{
				xField["@TargetField"] = (field ? field['TARGET_FIELD_NAME'] : null);
			}
		}
		let sCOLUMN_CHOICES: string = '<?xml version="1.0" encoding="UTF-8"?>' + builder.build(xml);
		return sCOLUMN_CHOICES;
	}

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { ID, MODULE_NAME, history, location } = this.props;
		const { LAST_DATE_MODIFIED, dtRatings, dtMenus, dtDemographicNames, QUESTION_TYPE_LIST } = this.state;

		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, this.refMap)
		// This sets the local state, which is then passed to DynamicButtons
		try
		{
			let row;
			switch (sCommandName)
			{
				case 'Save':
				case 'SaveNew':
				case 'SaveDuplicate':
				case 'SaveConcurrency':
				{
					let isDuplicate = location.pathname.includes('Duplicate');
					// 08/19/2023 Paul.  Data not being initialized properly.  BuildDataRow does not include question data. 
					row = Object.assign({ ID: (isDuplicate ? null : ID), QUESTION_TYPE: QUESTION_TYPE_LIST[0] }, this.state.item, this.state.editedItem);
					// 08/27/2019 Paul.  Move build code to shared object. 
					let nInvalidFields: number = SplendidDynamic_EditView.BuildDataRow(row, this.refMap);
					if ( nInvalidFields == 0 )
					{
						let sQUESTION_TYPE : string = Sql.ToString(row['QUESTION_TYPE' ]);
						let sANSWER_CHOICES: string = Sql.ToString(row['ANSWER_CHOICES']).replace(/\s\s*$/, '');  // TrimEnd();
						let sCOLUMN_CHOICES: string = Sql.ToString(row['COLUMN_CHOICES']).replace(/\s\s*$/, '');  // TrimEnd();
						// 09/22/2023 Paul.  React is saving line breaks just as LF, not CRLF.  The old JavaScript rendering engine requires CRLF. 
						sANSWER_CHOICES= NormalizeLineBreaks(sANSWER_CHOICES);
						sCOLUMN_CHOICES= NormalizeLineBreaks(sCOLUMN_CHOICES);
						if ( sQUESTION_TYPE == "Rating Scale" )
						{
							sCOLUMN_CHOICES = this.buildRatingScale(row, dtRatings);
						}
						else if ( sQUESTION_TYPE == "Dropdown Matrix" )
						{
							sCOLUMN_CHOICES = this.buildDropdownMatrix(row, dtMenus);
						}
						else if ( sQUESTION_TYPE == "Demographic" )
						{
							row['REQUIRED'] = false;
							sCOLUMN_CHOICES = this.buildDemographic(row, dtDemographicNames);
						}
						// 10/08/2014 Paul.  Add Range question type. 
						else if ( sQUESTION_TYPE == "Range" )
						{
							// 09/26/2023 Paul.  Need to use JavaScript toString() instead of C# ToString(). 
							sANSWER_CHOICES = Sql.ToInteger(row['RANGE_MIN']).toString() + ControlChars.CrLf + Sql.ToInteger(row['RANGE_MAX']).toString() + ControlChars.CrLf + Sql.ToInteger(row['RANGE_STEP']).toString();
						}
						// 06/02/2013 Paul.  Clear any unused fields. 
						// 11/07/2018 Paul.  Provide a way to get a single numerical or date value for lead population.
						// 11/10/2018 Paul.  Provide a way to get a hidden value for lead population. 
						// 11/24/2018 Paul.  Place image caption in ANSWER_CHOICES. 
						// 04/18/2019 Paul.  Hidden value does save ANSWER_CHOICES. 
						if ( sQUESTION_TYPE == "Text Area" || sQUESTION_TYPE == "Textbox" || sQUESTION_TYPE == "Plain Text" || sQUESTION_TYPE == "Demographic" || sQUESTION_TYPE == "Single Numerical" || sQUESTION_TYPE == "Single Date" )
							sANSWER_CHOICES = null;
						// 07/16/2021 Paul.  Range condition is not necessary as it is not any of the others. 
						if ( sQUESTION_TYPE != "Radio Matrix" && sQUESTION_TYPE != "Checkbox Matrix" && sQUESTION_TYPE != "Dropdown Matrix" && sQUESTION_TYPE != "Rating Scale" && sQUESTION_TYPE != "Demographic" ) // || sQUESTION_TYPE == "Range" )
							sCOLUMN_CHOICES = null;
						// 11/07/2018 Paul.  Provide a way to get a single numerical or date value for lead population.
						// 11/10/2018 Paul.  Provide a way to get a single checkbox for lead population. 
						// 11/10/2018 Paul.  Provide a way to get a hidden value for lead population. 
						if ( sQUESTION_TYPE == "Text Area" || sQUESTION_TYPE == "Ranking" || StartsWith(sQUESTION_TYPE, "Textbox") || sQUESTION_TYPE == "Plain Text" || sQUESTION_TYPE == "Image" || sQUESTION_TYPE == "Date" || sQUESTION_TYPE == "Demographic" || sQUESTION_TYPE == "Range" || sQUESTION_TYPE == "Single Numerical" || sQUESTION_TYPE == "Single Date" || sQUESTION_TYPE == "Single Checkbox" || sQUESTION_TYPE == "Hidden" )
						{
							row['OTHER_AS_CHOICE'         ] = false;
							row['OTHER_ONE_PER_ROW'       ] = false;
							row['OTHER_REQUIRED_MESSAGE'  ] = null;
							row['OTHER_VALIDATION_TYPE'   ] = null;
							row['OTHER_VALIDATION_MIN'    ] = null;
							row['OTHER_VALIDATION_MAX'    ] = null;
							row['OTHER_VALIDATION_MESSAGE'] = null;
						}
						// 11/10/2018 Paul.  Provide a way to get a hidden value for lead population. 
						if ( sQUESTION_TYPE == "Plain Text" || sQUESTION_TYPE == "Image" || sQUESTION_TYPE == "Hidden" )
							row['REQUIRED_MESSAGE'] = '';
						let sREQUIRED_TYPE: string = (this.fieldVisibility('tblRequiredType') ? Sql.ToString(row['REQUIRED_TYPE']) : null);
						// 08/14/2013 Paul.  Don't clear validation for a Textbox. 
						// 11/10/2018 Paul.  Provide a way to get a hidden value for lead population. 
						if ( sQUESTION_TYPE == "Text Area" || sQUESTION_TYPE == "Ranking" || sQUESTION_TYPE == "Plain Text" || sQUESTION_TYPE == "Image" || sQUESTION_TYPE == "Demographic" || sQUESTION_TYPE == "Range" || sQUESTION_TYPE == "Hidden" )
						{
							row['VALIDATION_TYPE'   ] = null;
							row['VALIDATION_MIN'    ] = null;
							row['VALIDATION_MAX'    ] = null;
							row['VALIDATION_MESSAGE'] = null;
						}
						// 11/10/2018 Paul.  Provide a way to get a hidden value for lead population. 
						// 03/10/2019 Paul.  The Name field will be visible to all. 
						//if ( sQUESTION_TYPE != "Plain Text" && sQUESTION_TYPE != "Image" && sQUESTION_TYPE != "Hidden" )
						//	NAME.Text = '';
						if ( sQUESTION_TYPE != "Textbox Numerical" )
						{
							row['VALIDATION_NUMERIC_SUM'] = null;
							row['VALIDATION_SUM_MESSAGE'] = null;
						}
						// 11/07/2018 Paul.  Provide a way to get a single numerical or date value for lead population.
						// 11/10/2018 Paul.  Provide a way to get a single checkbox for lead population. 
						// 11/10/2018 Paul.  Provide a way to get a hidden value for lead population. 
						if ( sQUESTION_TYPE == "Text Area" || sQUESTION_TYPE == "Textbox" || sQUESTION_TYPE == "Plain Text" || sQUESTION_TYPE == "Image" || sQUESTION_TYPE == "Demographic" || sQUESTION_TYPE == "Range" || sQUESTION_TYPE == "Single Numerical" || sQUESTION_TYPE == "Single Date" || sQUESTION_TYPE == "Single Checkbox" || sQUESTION_TYPE == "Hidden" )
							row['RANDOMIZE_TYPE'] = null;
						if ( sQUESTION_TYPE != "Image" )
							row['IMAGE_URL'] = null;
						let sSIZE_WIDTH  : string = null;
						let sSIZE_HEIGHT : string = null;
						let sBOX_WIDTH   : string = null;
						let sBOX_HEIGHT  : string = null;
						let sCOLUMN_WIDTH: string = null;
						// 11/07/2018 Paul.  Provide a way to get a single numerical or date value for lead population.
						// 11/10/2018 Paul.  Provide a way to get a single checkbox for lead population. 
						// 11/12/2018 Paul.  Enable size fields. 
						//if ( sQUESTION_TYPE != "Text Area" && sQUESTION_TYPE != "Textbox" && sQUESTION_TYPE != "Image" && sQUESTION_TYPE != "Single Numerical" && sQUESTION_TYPE != "Single Date" && sQUESTION_TYPE != "Single Checkbox" )
							sSIZE_WIDTH   = Sql.ToString(row['SIZE_WIDTH']);
						// 11/12/2018 Paul.  This comment is just to confirm that sSIZE_HEIGHT is not used. 
						if ( sQUESTION_TYPE == "" )
							sSIZE_HEIGHT  = Sql.ToString(row['SIZE_HEIGHT']);
						// 11/07/2018 Paul.  Provide a way to get a single numerical or date value for lead population.
						// 11/10/2018 Paul.  Provide a way to get a single checkbox for lead population. 
						if ( sQUESTION_TYPE == "Text Area" || sQUESTION_TYPE == "Textbox" || sQUESTION_TYPE == "Textbox Multiple" || sQUESTION_TYPE == "Textbox Numerical" || sQUESTION_TYPE == "Demographic" || sQUESTION_TYPE == "Single Numerical" || sQUESTION_TYPE == "Single Date" || sQUESTION_TYPE == "Single Checkbox" )
							sBOX_WIDTH    = Sql.ToString(row['BOX_WIDTH']);
						if ( sQUESTION_TYPE == "Text Area" )
							sBOX_HEIGHT   = Sql.ToString(row['BOX_HEIGHT']);
						if ( sQUESTION_TYPE == "Rating Scale" || sQUESTION_TYPE == "Radio Matrix" || sQUESTION_TYPE == "Checkbox Matrix" || sQUESTION_TYPE == "Dropdown Matrix" || sQUESTION_TYPE == "Textbox Multiple" || sQUESTION_TYPE == "Textbox Numerical" || sQUESTION_TYPE == "Date" || sQUESTION_TYPE == "Demographic" || sQUESTION_TYPE == "Range" )
							sCOLUMN_WIDTH = Sql.ToString(row['COLUMN_WIDTH']);
						let sDISPLAY_FORMAT: string = '';
						// 10/08/2014 Paul.  Add Range question type. 
						// 03/09/2019 Paul.  Single Date also uses DISPLAY_FORMAT. 
						if ( sQUESTION_TYPE == "Radio" || sQUESTION_TYPE == "Checkbox" || sQUESTION_TYPE == "Date" || sQUESTION_TYPE == "Single Date" || sQUESTION_TYPE == "Range" )
							sDISPLAY_FORMAT = Sql.ToString(row['DISPLAY_FORMAT']);
						// 08/17/2018 Paul.  For date validation, we need to store time in seconds as the database field is an integer.  Convert to seconds since 1970. 
						let nREQUIRED_RESPONSES_MIN: number = 0;
						let nREQUIRED_RESPONSES_MAX: number = 0;
						if ( sQUESTION_TYPE == "Date" )
						{
							let dtREQUIRED_RESPONSES_MIN: Date = Sql.ToDateTime(row['REQUIRED_RESPONSES_MIN']);
							let dtREQUIRED_RESPONSES_MAX: Date = Sql.ToDateTime(row['REQUIRED_RESPONSES_MAX']);
							if ( dtREQUIRED_RESPONSES_MIN != new Date(1970, 1, 1) )
								nREQUIRED_RESPONSES_MIN = (dtREQUIRED_RESPONSES_MIN.getTime() - (new Date(1970, 1, 1)).getTime()) / 1000;  // Save in seconds. 
							if ( dtREQUIRED_RESPONSES_MAX != new Date(1970, 1, 1) )
								nREQUIRED_RESPONSES_MAX = (dtREQUIRED_RESPONSES_MAX.getTime() - (new Date(1970, 1, 1)).getTime()) / 1000;  // Save in seconds. 
						}
						else
						{
							nREQUIRED_RESPONSES_MIN = Sql.ToInteger(row['REQUIRED_RESPONSES_MIN']);
							nREQUIRED_RESPONSES_MAX = Sql.ToInteger(row['REQUIRED_RESPONSES_MAX']);
						}
						row['DISPLAY_FORMAT'        ] = sDISPLAY_FORMAT        ;
						row['ANSWER_CHOICES'        ] = sANSWER_CHOICES        ;
						row['COLUMN_CHOICES'        ] = sCOLUMN_CHOICES        ;
						row['REQUIRED_RESPONSES_MIN'] = nREQUIRED_RESPONSES_MIN;
						row['REQUIRED_RESPONSES_MAX'] = nREQUIRED_RESPONSES_MAX;
						row['REQUIRED_TYPE'         ] = sREQUIRED_TYPE         ;
						row['SIZE_WIDTH'            ] = sSIZE_WIDTH            ;
						row['SIZE_HEIGHT'           ] = sSIZE_HEIGHT           ;
						row['BOX_WIDTH'             ] = sBOX_WIDTH             ;
						row['BOX_HEIGHT'            ] = sBOX_HEIGHT            ;
						row['COLUMN_WIDTH'          ] = sCOLUMN_WIDTH          ;
						// 08/19/2023 Paul.  Trim() does not check for nulls. 
						row['CATEGORIES'            ] = (row['CATEGORIES'] ? Trim(row['CATEGORIES']) : null);

						if ( sQUESTION_TYPE != "Date"              ) row['INVALID_DATE_MESSAGE'  ] = null;
						if ( sQUESTION_TYPE != "Textbox Numerical" ) row['INVALID_NUMBER_MESSAGE'] = null;
						if ( !Sql.ToBoolean(row['NA_ENABLED'   ])  ) row['NA_LABEL'              ] = null;
						if ( !Sql.ToBoolean(row['OTHER_ENABLED'])  ) row['OTHER_LABEL'           ] = null;

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
							row.ID = await UpdateModule(MODULE_NAME, row, isDuplicate ? null : ID);
							// 07/31/2013 Paul.  Add SaveNew button to SurveyQuestion. 
							if ( sCommandName == 'SaveNew' )
							{
								let sSaveNewParams: string = '';
								if ( !Sql.IsEmptyGuid(this.SURVEY_ID) )
								{
									sSaveNewParams += Sql.IsEmptyString(sSaveNewParams) ? "?" : "&";
									sSaveNewParams += "SURVEY_ID=" + this.SURVEY_ID;
								}
								if ( !Sql.IsEmptyGuid(this.SURVEY_PAGE_ID) )
								{
									sSaveNewParams += Sql.IsEmptyString(sSaveNewParams) ? "?" : "&";
									sSaveNewParams += "SURVEY_PAGE_ID=" + this.SURVEY_PAGE_ID;
								}
								history.push(`/Reset/${MODULE_NAME}/Edit/` + sSaveNewParams);
							}
							else
							{
								history.push(`/Reset/${MODULE_NAME}/View/` + row.ID);
							}
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
					if ( !Sql.IsEmptyGuid(this.SURVEY_ID) )
					{
						history.push(`/Reset/Surveys/View/${this.SURVEY_ID}`);
					}
					else if ( !Sql.IsEmptyGuid(this.SURVEY_PAGE_ID) )
					{
						history.push(`/Reset/SurveyPages/View/${this.SURVEY_PAGE_ID}`);
					}
					else if ( Sql.IsEmptyString(ID) )
					{
						history.push(`/Reset/${MODULE_NAME}/List`);
					}
					else
					{
						history.push(`/Reset/${MODULE_NAME}/View/${ID}`);
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
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
			this.setState({ error });
		}
	}

	private _onTEXT_Change = (e, DATA_FIELD: string): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onTEXT_Change: ' + DATA_FIELD, e);
		const data: SelectOption = e.target.value;
		this._onChange(DATA_FIELD, data['id']);
	}

	private _onCHECKBOX_Change = (e, DATA_FIELD: string): void =>
	{
		this._onChange(DATA_FIELD, e.target.checked);
	}

	private _onRATING_TEXT_Change = (e, n: number, DATA_FIELD: string): void =>
	{
		let item = this.state.dtRatings;
		if ( item == null )
			item = [];
		if ( item.length < n + 1 )
			item.push({});
		item[n][DATA_FIELD] = e.target.value;
		if ( this._isMounted )
		{
			this.setState({ dtRatings: item, previewIndex: this.state.previewIndex + 1 });
		}
	}

	private _onMENU_TEXT_Change = (e, n: number, DATA_FIELD: string): void =>
	{
		let item = this.state.dtMenus;
		if ( item == null )
			item = [];
		if ( item.length < n + 1 )
			item.push({});
		item[n][DATA_FIELD] = e.target.value;
		if ( this._isMounted )
		{
			this.setState({ dtMenus: item, previewIndex: this.state.previewIndex + 1 });
		}
	}

	private _onDEMOGRAPHIC_TEXT_Change = (e, DEMOGRAPHIC_NAME: string, DATA_FIELD: string): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDEMOGRAPHIC_TEXT_Change', DEMOGRAPHIC_NAME, DATA_FIELD, e.target.value);
		let item = this.state.dtDemographicNames;
		if ( item == null )
			item = {};
		if ( !item[DEMOGRAPHIC_NAME] )
			item[DEMOGRAPHIC_NAME] = {};
		item[DEMOGRAPHIC_NAME][DATA_FIELD] = e.target.value;
		if ( this._isMounted )
		{
			this.setState({ dtDemographicNames: item, previewIndex: this.state.previewIndex + 1 });
		}
	}

	private _onDEMOGRAPHIC_CHECKBOX_Change = (e, DEMOGRAPHIC_NAME: string, DATA_FIELD: string): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onDEMOGRAPHIC_CHECKBOX_Change', DEMOGRAPHIC_NAME, DATA_FIELD, e.target.value);
		let item = this.state.dtDemographicNames;
		if ( item == null )
			item = {};
		if ( !item[DEMOGRAPHIC_NAME] )
			item[DEMOGRAPHIC_NAME] = {};
		item[DEMOGRAPHIC_NAME][DATA_FIELD] = e.target.checked;
		if ( this._isMounted )
		{
			this.setState({ dtDemographicNames: item, previewIndex: this.state.previewIndex + 1 });
		}
	}

	private BuildMenuChoices = (row) =>
	{
		const { dtMenus } = this.state;
		let tblMENUChildren: any[] = [];
		let tblMENU: any = React.createElement('table', {id: 'tblMENU', className: 'tabEditView', style: {border: 'none'} }, tblMENUChildren);
		let tr: any[] = [];
		let nMENU_ITEMS: number = Sql.ToInteger(row['lstNumberOfMenus']);
		for ( let i: number = 0; i < nMENU_ITEMS; i += 3 )
		{
			let trChildren: any[] = [];
			let tr        : any   = React.createElement('tr', {}, trChildren);
			tblMENUChildren.push(tr);
			for ( let j: number = 0; j < 3; j++ )
			{
				let menu: any = null;
				if ( dtMenus.length > i + j )
				{
					menu = dtMenus[i + j];
				}
				let tdChildren         = [];
				let td                 = React.createElement('td', {style: {width: '33%'}}, tdChildren);
				trChildren.push(td);
				let divPanelChildren   = [];
				let divPanel           = React.createElement('div', {}, divPanelChildren);
				tdChildren.push(divPanel);
				
				if ( menu != null )
				{
					let sHeading: string = Sql.ToString(L10n.Term("SurveyQuestions.LBL_MENU_HEADING")).replace('{0}', (i + j + 1).toString());
					let divHeading1        = React.createElement('div', { style: {marginTop: '2px', marginBottom: '2px'} }, sHeading);
					divPanelChildren.push(divHeading1);
					let inputHeading       = React.createElement('input', { type: 'text', style: {width: '95%'}, value: (menu ? menu.Heading : null), onChange: (e) => this._onMENU_TEXT_Change(e, i + j, 'Heading') } );
					divPanelChildren.push(inputHeading);
					
					let sOptions: string = Sql.ToString(L10n.Term("SurveyQuestions.LBL_MENU_OPTIONS")).replace('{0}', (i + j + 1).toString());
					let divHeading2        = React.createElement('div', { style: {marginTop: '2px', marginBottom: '2px'} }, sOptions);
					divPanelChildren.push(divHeading2);
					let textarea           = React.createElement('textarea', { rows: 3, cols: 20, style: {width: '95%'}, value: (menu ? menu.Options : null), onChange: (e) => this._onMENU_TEXT_Change(e, i + j, 'Options') });
					divPanelChildren.push(textarea);
				}
			}
		}
		return tblMENU;
	}

	public render()
	{
		// 04/04/2021 Paul.  Use CONTROL_VIEW_NAME to create unique keys so that same module/subpanel search multiple times. 
		const { MODULE_NAME, ID, LAYOUT_NAME, CONTROL_VIEW_NAME, DuplicateID, ConvertID, isSearchView, isUpdatePanel, isQuickCreate, callback } = this.props;
		const { item, layout, EDIT_NAME, SUB_TITLE, error } = this.state;
		const { QUESTION_TYPE_LIST, ANSWER_CHOICES_LABEL, DISPLAY_FORMAT_LABEL, DISPLAY_FORMAT_LIST_NAME, DISPLAY_FORMAT_LIST, SURVEY_TARGET_MODULE_LIST, TARGET_FIELD_NAME_LIST, lstRatingScale, lstNumberOfMenus, OTHER_HEIGHT_LIST, OTHER_WIDTH_LIST, OTHER_VALIDATION_TYPE_LIST, REQUIRED_TYPE_LIST, VALIDATION_TYPE_LIST_NAME, VALIDATION_TYPE_LIST, RANDOMIZE_TYPE_LIST, SIZE_UNITS_LIST, SIZE_HEIGHT_LIST, SIZE_WIDTH_LIST_NAME, SIZE_WIDTH_LIST, BOX_HEIGHT_LIST, BOX_WIDTH_LIST, COLUMN_WIDTH_LIST, PLACEMENT_LIST } = this.state;
		const { dtRatings, dtMenus, dtDemographicNames } = this.state;
		const { __total, __sql, previewIndex } = this.state;
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render: ' + EDIT_NAME, layout, item);
		// 09/09/2019 Paul.  We need to wait until item is loaded, otherwise fields will not get populated. 
		// 09/18/2019 Paul.  Include ConvertID. 
		if ( layout == null || (item == null && (!Sql.IsEmptyString(ID) || !Sql.IsEmptyString(DuplicateID) || !Sql.IsEmptyString(ConvertID))) )
		{
			if ( error )
			{
				return (<ErrorComponent error={error} />);
			}
			else
			{
				return null;
			}
		}
		this.refMap = {};
		let onSubmit = (this.props.onSubmit ? this._onSubmit : null);
		if ( SplendidCache.IsInitialized )
		{
			let currentItem = Object.assign({ QUESTION_TYPE: QUESTION_TYPE_LIST[0] }, this.state.item, this.state.editedItem);
			let sampleItem  = Object.assign({ QUESTION_TYPE: QUESTION_TYPE_LIST[0] }, this.state.item, this.state.editedItem);
			sampleItem.ID              = 'divQuestionEditViewSample' + Sql.ToString(currentItem['QUESTION_TYPE']);
			sampleItem.DESCRIPTION     = Sql.ToString(currentItem['DESCRIPTION']);
			sampleItem.QUESTION_NUMBER = 1;
			if ( sampleItem['QUESTION_TYPE'] == 'Rating Scale' )
			{
				sampleItem['COLUMN_CHOICES'] = this.buildRatingScale(sampleItem, dtRatings);
			}
			else if ( sampleItem['QUESTION_TYPE'] == 'Dropdown Matrix' )
			{
				sampleItem['COLUMN_CHOICES'] = this.buildDropdownMatrix(sampleItem, dtMenus);
			}
			else if ( sampleItem['QUESTION_TYPE'] == 'Demographic' )
			{
				sampleItem['COLUMN_CHOICES'] = this.buildDemographic(sampleItem, dtDemographicNames);
			}
			else if ( sampleItem['QUESTION_TYPE'] == 'Range' )
			{
				sampleItem['ANSWER_CHOICES'] = Sql.ToInteger(sampleItem['RANGE_MIN']) + '\n' + Sql.ToInteger(sampleItem['RANGE_MAX']) + '\n' + Sql.ToInteger(sampleItem['RANGE_STEP']);
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', currentItem);
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let question: any = SurveyQuestionFactory(sampleItem);
			// 02/15/2024 Paul. react-select 5.8 requires array of objects, not array of strings. 
			const QUESTION_TYPE_LIST_obj: any[] = [];
			QUESTION_TYPE_LIST.map((item, index) => 
			{
				const data: SelectOption = {id: item, name: item};
				QUESTION_TYPE_LIST_obj.push(data);
			});

			return (
			<React.Fragment>
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, error, showRequired: true, enableHelp: true, helpName: 'EditView', ButtonStyle: 'EditHeader', VIEW_NAME: EDIT_NAME, row: item, Page_Command: this.Page_Command, showButtons: !isSearchView && !isUpdatePanel, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				{ LAYOUT_NAME && LAYOUT_NAME.indexOf('.MassUpdate') < 0
				? <DumpSQL SQL={ __sql } />
				: null
				}
	<h3>{ L10n.Term('SurveyQuestions.LBL_QUESTION') }</h3>
	<table className='tabForm' cellPadding={ 0 } cellSpacing={ 1 } style={ {width: '100%'} }>
		<tr>
			<td valign='top' style={ {width: '50%'} }>
				<table className='tabEditView'>
					<tr>
						<td className='dataLabel' colSpan={ 2 }>
							{ L10n.Term('SurveyQuestions.LBL_DESCRIPTION') } &nbsp;<span className='required'>{ L10n.Term('.LBL_REQUIRED_SYMBOL') }</span>
						</td>
					</tr>
					<tr>
						<td colSpan={ 2 }>
							<textarea id='DESCRIPTION'
								value={ currentItem['DESCRIPTION'] }
								style={ {width: '100%'} }
								rows={ 4 }
								onChange={ (e) => this._onTEXT_Change(e, 'DESCRIPTION') }
							/>
						</td>
					</tr>
					<tr>
						<td className='dataLabel'>
							{ L10n.Term('SurveyQuestions.LBL_QUESTION_TYPE') }&nbsp;<span className='required'>{ L10n.Term('.LBL_REQUIRED_SYMBOL') }</span>
						</td>
						<td className='dataLabel' style={ {paddingLeft: '20px'} }>
							{ this.fieldVisibility('labDisplayFormat')
							? DISPLAY_FORMAT_LABEL
							: null
							}
						</td>
					</tr>
					<tr>
						<td>
							<Select
								id='QUESTION_TYPE'
								isMulti={ false }
								isSearchable={ false }
								closeMenuOnSelect={ true }
								controlShouldRenderValue={ true }
								value={ [currentItem['QUESTION_TYPE']] }
								onChange={ (e) => this._onTEXT_Change({target: {value: e}}, 'QUESTION_TYPE') }
								options={ QUESTION_TYPE_LIST_obj }
								getOptionLabel={ (option) => L10n.ListTerm('survey_question_type', option) }
								getOptionValue={ (option) => option }
								components={ { SingleValue: QuestionTypeSingleValue, Option: QuestionTypeOption } }
							>
							</Select>
						</td>
						<td style={ {paddingLeft: '20px'} }>
							{ this.fieldVisibility('DISPLAY_FORMAT')
							? <select id='DISPLAY_FORMAT'
								value={ currentItem['DISPLAY_FORMAT'] }
								onChange={ (e) => this._onTEXT_Change(e, 'DISPLAY_FORMAT') } 
							>
							{
								DISPLAY_FORMAT_LIST.map((item, index) => 
								{
									return (<option id={ 'DISPLAY_FORMAT' + ' _' + index.toString() } key={ 'DISPLAY_FORMAT' + '_' + index.toString() } value={ item }>{ L10n.ListTerm(DISPLAY_FORMAT_LIST_NAME, item) }</option>);
								})
							}
							</select>
							: null
							}
						</td>
					</tr>
					<tr>
						<td colSpan={ 2 }>
							<h3 style={ {marginTop: '20px'} }>{ L10n.Term('SurveyQuestions.LBL_SAMPLE') }</h3>
							<div id='divQuestionEditViewSample' style={ {marginTop: '10px'} }>
							{ question
							? <div className='SurveyQuestionDesignFrame SurveyQuestionFrame' style={ {backgroundColor: 'white'} }>
								<div className='SurveyQuestionContent'>
									{ React.createElement(question, { key: 'Preview' + previewIndex.toString(), row: sampleItem, displayMode: 'Preview' }) }
								</div>
							</div>
							: null
							}
							</div>
						</td>
					</tr>
				</table>
			</td>
			<td valign='top' style={ {width: '50%', paddingLeft: '10px'} }>
				{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, callback, this._createDependency, null, this._onChange, this._onUpdate, onSubmit, (isSearchView || isQuickCreate ? null : 'tabForm'), this.Page_Command, isSearchView, CONTROL_VIEW_NAME) }
				<table className='tabEditView'>
					<tr>
						<td className='dataLabel' style={ {width: '30%'} }>
							{ L10n.Term('SurveyQuestions.LBL_CATEGORIES') }
						</td>
						<td>
							<textarea id='CATEGORIES'
								value={ currentItem['CATEGORIES'] }
								style={ {width: '100%'} }
								rows={ 3 }
								onChange={ (e) => this._onTEXT_Change(e, 'CATEGORIES') }
							/>
						</td>
					</tr>
				</table>
				<table className='tabEditView'>
					<tr>
						<td className='dataLabel' style={ {width: '35%'} }>
							{ this.fieldVisibility('SURVEY_TARGET_LABEL')
							? L10n.Term('SurveyQuestions.LBL_SURVEY_TARGET_MODULE')
							: null
							}
						</td>
						<td>
							{ this.fieldVisibility('SURVEY_TARGET_MODULE')
							? <select id='SURVEY_TARGET_MODULE'
								className='dataField'
								value={ currentItem['SURVEY_TARGET_MODULE'] }
								onChange={ (e) => this._onTEXT_Change(e, 'SURVEY_TARGET_MODULE') } 
							>
								<option id={ 'SURVEY_TARGET_MODULE' + ' _none' } key={ 'SURVEY_TARGET_MODULE' + ' _none' } value=''>{ L10n.Term('.LBL_NONE') }</option>
								{
									SURVEY_TARGET_MODULE_LIST.map((item, index) => 
									{
										return (<option id={ 'SURVEY_TARGET_MODULE' + ' _' + index.toString() } key={ 'SURVEY_TARGET_MODULE' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('survey_target_module_dom', item) }</option>);
									})
								}
							</select>
							: null
							}
						</td>
					</tr>
					<tr>
						<td className='dataLabel'>
							{ this.fieldVisibility('TARGET_FIELD_LABEL')
							? L10n.Term('SurveyQuestions.LBL_TARGET_FIELD_NAME')
							: null
							}
						</td>
						<td>
							{ this.fieldVisibility('TARGET_FIELD_NAME')
							? <select id='TARGET_FIELD_NAME'
								className='dataField'
								value={ currentItem['TARGET_FIELD_NAME'] }
								onChange={ (e) => this._onTEXT_Change(e, 'TARGET_FIELD_NAME') } 
							>
								<option id={ 'TARGET_FIELD_NAME' + ' _none' } key={ 'TARGET_FIELD_NAME' + ' _none' } value=''>{ L10n.Term('.LBL_NONE') }</option>
								{
									TARGET_FIELD_NAME_LIST.map((item, index) => 
									{
										return (<option id={ 'TARGET_FIELD_NAME' + ' _' + index.toString() } key={ 'TARGET_FIELD_NAME' + '_' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
									})
								}
							</select>
							: null
							}
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>

	{ this.fieldVisibility('pnlAnswer')
	? <div id='pnlAnswer'>
		<h3>{ L10n.Term('SurveyQuestions.LBL_ANSWER_OPTIONS') }</h3>
		<table className='tabForm' cellPadding={ 0 } cellSpacing={ 1 } style={ {width: '100%'} }>
			<tr>
				<td>
					{ this.fieldVisibility('tblAnswerChoices')
					? <table id='tblAnswerChoices' className='tabEditView'>
						<tr>
							<td className='dataLabel'>
								{ ANSWER_CHOICES_LABEL }
							</td>
						</tr>
						<tr>
							<td className='dataField' style={ {paddingRight: '10px'} }>
								<textarea id='ANSWER_CHOICES'
									value={ currentItem['ANSWER_CHOICES'] }
									style={ {width: '100%'} }
									rows={ 4 }
									onChange={ (e) => this._onTEXT_Change(e, 'ANSWER_CHOICES') }
								/>
							</td>
						</tr>
					</table>
					: null
					}
					
					{ this.fieldVisibility('tblInvalidDate')
					? <table id='tblInvalidDate' className='tabEditView'>
						<tr>
							<td className='dataLabel'>
								{ L10n.Term('SurveyQuestions.LBL_INVALID_DATE_MESSAGE') }
							</td>
						</tr>
						<tr>
							<td className='dataField' style={ {paddingRight: '10px'} }>
								<input type='text'
									id='INVALID_DATE_MESSAGE'
									value={ currentItem['INVALID_DATE_MESSAGE'] }
									style={ {width: '100%'} }
									onChange={ (e) => this._onTEXT_Change(e, 'INVALID_DATE_MESSAGE') }
								/>
							</td>
						</tr>
					</table>
					: null
					}
					
					{ this.fieldVisibility('tblInvalidNumber')
					? <table id='tblInvalidNumber' className='tabEditView'>
						<tr>
							<td className='dataLabel'>
								{ L10n.Term('SurveyQuestions.LBL_INVALID_NUMBER_MESSAGE') }
							</td>
						</tr>
						<tr>
							<td className='dataField' style={ {paddingRight: '10px'} }>
								<input type='text'
									id='INVALID_NUMBER_MESSAGE'
									value={ currentItem['INVALID_NUMBER_MESSAGE'] }
									style={ {width: '100%'} }
									onChange={ (e) => this._onTEXT_Change(e, 'INVALID_NUMBER_MESSAGE') }
								/>
							</td>
						</tr>
					</table>
					: null
					}
					
					{ this.fieldVisibility('tblRankingNA')
					? <table id='tblRankingNA' className='tabEditView'>
						<tr>
							<td className='dataLabel' style={ {width: '15%'} }>
								<input type='checkbox'
									id='NA_ENABLED'
									checked={ Sql.ToBoolean(currentItem['NA_ENABLED']) }
									className='checkbox'
									style={ {verticalAlign: 'baseline'} }
									onChange={ (e) => this._onCHECKBOX_Change(e, 'NA_ENABLED') }
								/>
								<label htmlFor='NA_ENABLED' style={ {paddingLeft: '4px'} }>{ L10n.Term('SurveyQuestions.LBL_NA_ENABLED') }</label>
							</td>
							<td className='dataField' style={ {width: '85%'} }>
								<input type='text'
									id='NA_LABEL'
									value={ currentItem['NA_LABEL'] }
									size={ 40 }
									style={ {marginLeft: '10px'} }
									onChange={ (e) => this._onTEXT_Change(e, 'NA_LABEL') }
								/>
							</td>
						</tr>
					</table>
					: null
					}
					
					{ this.fieldVisibility('pnlRatingScale')
					? <div id='pnlRatingScale' style={ {width: '100%'} }>
						<table className='tabEditView' cellPadding={ 3 }>
							<tr>
								<td className='dataField' valign='top' style={ {width: '15%'} }>
									{ L10n.Term('SurveyQuestions.LBL_RATING_SCALE') }<br />
									<select id='lstRatingScale'
										style={ {marginLeft: '4px'} }
										value={ currentItem['lstRatingScale'] }
										onChange={ (e) => this._onTEXT_Change(e, 'lstRatingScale') } 
									>
									{
										lstRatingScale.map((item, index) => 
										{
											return (<option id={ 'lstRatingScale' + ' _' + index.toString() } key={ 'lstRatingScale' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('survey_question_ratings_scale', item) }</option>);
										})
									}
									</select>
								</td>
								<td className='dataField' valign='top' style={ {width: '50%'} }>
									{ L10n.Term('SurveyQuestions.LBL_RATING_SCALE_CHOICES') }
									<table id='tblRATING' className='tabEditView' style={ {marginLeft: '4px'} }>
									{
										dtRatings.map((item, index) => 
										{
											let rating: any = dtRatings[index];
											return (<tr>
												<td className="dataLabel">
													{ L10n.Term('SurveyQuestions.LBL_RATING_SCALE_LABEL') }
												</td>
												<td className="dataField">
													<input type="text" value={ rating ? Sql.ToString(rating.Label) : '' } style={ {width: '200px'} } onChange={ (e) => this._onRATING_TEXT_Change(e, index, 'Label') }/>
												</td>
												<td className="dataLabel">
													{ L10n.Term('SurveyQuestions.LBL_RATING_SCALE_WEIGHT') }
												</td>
												<td className="dataField">
													<input type="text" value={ rating ? Sql.ToString(rating.Weight) : '' } style={ {width: '40px'} } onChange={ (e) => this._onRATING_TEXT_Change(e, index, 'Weight') }/>
												</td>
											</tr>
											);
										})
									}
									</table>
								</td>
								<td className='dataField' valign='top' style={ {width: '35%'} }>
								</td>
							</tr>
						</table>
						{ bDebug 
						? <div id='dtRatingsDump' dangerouslySetInnerHTML={ {__html: dumpObj(dtRatings, 'dtRatings').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;') } } style={ {marginTop: '20px', border: '1px solid black'} }></div>
						: null
						}
					</div>
					: null
					}
					
					{ this.fieldVisibility('tblColumnChoices')
					? <table id='tblColumnChoices' className='tabEditView'>
						<tr>
							<td className='dataLabel'>
								{ L10n.Term('SurveyQuestions.LBL_COLUMN_CHOICES') }
							</td>
						</tr>
						<tr>
							<td className='dataField' style={ {paddingRight: '10px'} }>
								<textarea id='COLUMN_CHOICES'
									value={ currentItem['COLUMN_CHOICES'] }
									style={ {width: '100%'} }
									rows={ 4 }
									onChange={ (e) => this._onTEXT_Change(e, 'COLUMN_CHOICES') }
								/>
							</td>
						</tr>
					</table>
					: null
					}
					
					{ this.fieldVisibility('tblForcedRanking')
					? <table id='tblForcedRanking' className='tabEditView'>
						<tr>
							<td className='dataLabel'>
								<input type='checkbox'
									id='FORCED_RANKING'
									checked={ Sql.ToBoolean(currentItem['FORCED_RANKING']) }
									className='checkbox'
									style={ {verticalAlign: 'baseline'} }
									onChange={ (e) => this._onCHECKBOX_Change(e, 'FORCED_RANKING') }
									/>
								<label htmlFor='FORCED_RANKING' style={ {paddingLeft: '4px'} }>{ L10n.Term('SurveyQuestions.LBL_FORCED_RANKING') }</label>
							</td>
						</tr>
					</table>
					: null
					}
					
					{ this.fieldVisibility('pnlMenuChoices')
					? <div id='pnlMenuChoices'>
						<table className='tabEditView'>
							<tr>
								<td className='dataLabel' valign='top' style={ {width: '15%'} }>
									{ L10n.Term('SurveyQuestions.LBL_MENU_CHOICES') }
								</td>
								<td className='dataField' valign='top' style={ {width: '85%'} }>
									{ L10n.Term('SurveyQuestions.LBL_NUMBER_OF_MENUS') }
									<select id='lstNumberOfMenus'
										style={ {marginLeft: '4px'} }
										value={ currentItem['lstNumberOfMenus'] }
										onChange={ (e) => this._onTEXT_Change(e, 'lstNumberOfMenus') } 
									>
									{
										lstNumberOfMenus.map((item, index) => 
										{
											return (<option id={ 'lstNumberOfMenus' + ' _' + index.toString() } key={ 'lstNumberOfMenus' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('survey_question_menu_choices', item) }</option>);
										})
									}
									</select>
								</td>
							</tr>
						</table>
						{ this.BuildMenuChoices(currentItem) }
						{ bDebug 
						? <div id='dtMenusDump' dangerouslySetInnerHTML={ {__html: dumpObj(dtMenus, 'dtMenus').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;') } } style={ {marginTop: '20px', border: '1px solid black'} }></div>
						: null
						}
					</div>
					: null
					}
					
					{ this.fieldVisibility('pnlOther')
					? <div id='pnlOther' className='dataLabel'>
						<table className='tabEditView'>
							<tr>
								<td className='dataLabel' valign='top' style={ {width: '15%'} }>
									<input type='checkbox'
										id='OTHER_ENABLED'
										checked={ Sql.ToBoolean(currentItem['OTHER_ENABLED']) }
										className='checkbox'
										style={ {verticalAlign: 'baseline'} }
										onChange={ (e) => this._onCHECKBOX_Change(e, 'OTHER_ENABLED') }
										/>
									<label htmlFor='OTHER_ENABLED' style={ {paddingLeft: '4px'} }>{ L10n.Term('SurveyQuestions.LBL_OTHER_ENABLED') }</label>
								</td>
								<td className='dataField' valign='top' style={ {width: '85%'} }>
									<div id='divAnswerOther'>
										<table className='tabEditView'>
											<tr>
												<td style={ {width: '15%'} } className='dataLabel'>{ L10n.Term('SurveyQuestions.LBL_OTHER_LABEL') }</td>
												<td style={ {width: '85%'} } className='dataField'>
													<input type='text'
														id='OTHER_LABEL'
														value={ currentItem['OTHER_LABEL'] }
														size={ 40 }
														maxLength={ 200 }
														onChange={ (e) => this._onTEXT_Change(e, 'OTHER_LABEL') }
													/>
												</td>
											</tr>
											<tr>
												<td style={ {width: '15%'} } className='dataLabel'>{ L10n.Term('SurveyQuestions.LBL_OTHER_SIZE') }</td>
												<td style={ {width: '85%'} } className='dataField'>
													<select id='OTHER_HEIGHT'
														style={ {marginRight: '10px'} }
														value={ currentItem['OTHER_HEIGHT'] }
														onChange={ (e) => this._onTEXT_Change(e, 'OTHER_HEIGHT') } 
													>
													{
														OTHER_HEIGHT_LIST.map((item, index) => 
														{
															return (<option id={ 'OTHER_HEIGHT' + ' _' + index.toString() } key={ 'OTHER_HEIGHT' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('survey_question_field_lines', item) }</option>);
														})
													}
													</select>
													<select id='OTHER_WIDTH'
														style={ {marginRight: '10px'} }
														value={ currentItem['OTHER_WIDTH'] }
														onChange={ (e) => this._onTEXT_Change(e, 'OTHER_WIDTH') } 
													>
													{
														OTHER_WIDTH_LIST.map((item, index) => 
														{
															return (<option id={ 'OTHER_WIDTH' + ' _' + index.toString() } key={ 'OTHER_WIDTH' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('survey_question_field_chars', item) }</option>);
														})
													}
													</select>
												</td>
											</tr>
											<tr>
												<td style={ {width: '15%'} } className='dataLabel'>{ L10n.Term('SurveyQuestions.LBL_OTHER_VALIDATION_TYPE') }</td>
												<td style={ {width: '85%'} } className='dataField'>
													<select id='OTHER_VALIDATION_TYPE'
														style={ {marginRight: '10px'} }
														value={ currentItem['OTHER_VALIDATION_TYPE'] }
														onChange={ (e) => this._onTEXT_Change(e, 'OTHER_VALIDATION_TYPE') } 
													>
													{
														OTHER_VALIDATION_TYPE_LIST.map((item, index) => 
														{
															if ( Sql.IsEmptyString(item) )
																return (<option id={ 'OTHER_VALIDATION_TYPE' + ' _' + index.toString() } key={ 'OTHER_VALIDATION_TYPE' + '_' + index.toString() } value={ item }>{ L10n.Term('.survey_question_validation.') }</option>);
															else
																return (<option id={ 'OTHER_VALIDATION_TYPE' + ' _' + index.toString() } key={ 'OTHER_VALIDATION_TYPE' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('survey_question_validation', item) }</option>);
														})
													}
													</select>
													{ !Sql.IsEmptyString(currentItem['OTHER_VALIDATION_TYPE']) && currentItem['OTHER_VALIDATION_TYPE'] != 'Email'
													? <span id='spnOtherValidation'>
														{ L10n.Term('SurveyQuestions.LBL_VALIDATION_BETWEEN') }
														<input type='text'
															id='OTHER_VALIDATION_MIN'
															value={ currentItem['OTHER_VALIDATION_MIN'] }
															style={ {width: '100px', marginLeft: '4px', marginRight: '10px'} }
															onChange={ (e) => this._onTEXT_Change(e, 'OTHER_VALIDATION_MIN') }
														/>
														{ L10n.Term('SurveyQuestions.LBL_VALIDATION_AND'    ) }
														<input type='text'
															id='OTHER_VALIDATION_MAX'
															value={ currentItem['OTHER_VALIDATION_MAX'] }
															style={ {width: '100px', marginLeft: '4px', marginRight: '10px'} }
															onChange={ (e) => this._onTEXT_Change(e, 'OTHER_VALIDATION_MAX') }
														/>
													</span>
													: null
													}
												</td>
											</tr>
											{ !Sql.IsEmptyString(currentItem['OTHER_VALIDATION_TYPE'])
											? <tr id='trOtherValidationMessage'>
												<td className='dataLabel' />
												<td className='dataField' style={ {paddingRight: '10px'} }>
													<textarea id='OTHER_VALIDATION_MESSAGE'
														value={ currentItem['OTHER_VALIDATION_MESSAGE'] }
														style={ {width: '100%'} }
														rows={ 2 }
														onChange={ (e) => this._onTEXT_Change(e, 'OTHER_VALIDATION_MESSAGE') }
													/>
												</td>
											</tr>
											: null
											}
											{ this.fieldVisibility('trOtherAsChoice')
											? <tr id='trOtherAsChoice'>
												<td className='dataLabel' />
												<td className='dataField'>
													{ this.fieldVisibility('OTHER_AS_CHOICE')
													? <React.Fragment>
														<input type='checkbox'
															id='OTHER_AS_CHOICE'
															checked={ Sql.ToBoolean(currentItem['OTHER_AS_CHOICE'  ]) }
															className='checkbox'
															style={ {verticalAlign: 'baseline'} }
															onChange={ (e) => this._onCHECKBOX_Change(e, 'OTHER_AS_CHOICE'  ) }
															/>
														<label htmlFor='OTHER_AS_CHOICE' style={ {paddingLeft: '4px'} }>{ L10n.Term('SurveyQuestions.LBL_OTHER_AS_CHOICE'  ) }</label>
													</React.Fragment>
													: null
													}
													{ this.fieldVisibility('OTHER_ONE_PER_ROW')
													? <React.Fragment>
														<input type='checkbox'
															id='OTHER_ONE_PER_ROW'
															checked={ Sql.ToBoolean(currentItem['OTHER_ONE_PER_ROW']) }
															className='checkbox'
															style={ {verticalAlign: 'baseline'} }
															onChange={ (e) => this._onCHECKBOX_Change(e, 'OTHER_ONE_PER_ROW') }
															/>
														<label htmlFor='OTHER_ONE_PER_ROW' style={ {paddingLeft: '4px'} }>{ L10n.Term('SurveyQuestions.LBL_OTHER_ONE_PER_ROW') }</label>
													</React.Fragment>
													: null
													}
												</td>
											</tr>
											: null
											}
											{ Sql.ToBoolean(currentItem['OTHER_AS_CHOICE'])
											? <tr id='trOtherRequiredMessage'>
												<td className='dataLabel' />
												<td className='dataField' style={ {paddingRight: '10px'} }>
													<textarea id='OTHER_REQUIRED_MESSAGE'
														value={ currentItem['OTHER_REQUIRED_MESSAGE'] }
														style={ {width: '100%'} }
														rows={ 2 }
														onChange={ (e) => this._onTEXT_Change(e, 'OTHER_REQUIRED_MESSAGE') }
													/>
												</td>
											</tr>
											: null
											}
										</table>
									</div>
								</td>
							</tr>
						</table>
					</div>
					: null
					}
				</td>
			</tr>
		</table>
	</div>
	: null
	}

	{ this.fieldVisibility('pnlRange')
	? <div id='pnlRange'>
		<h3>{ L10n.Term('SurveyQuestions.LBL_RANGE_OPTIONS') }</h3>
		<table className='tabForm' cellPadding={ 0 } cellSpacing={ 1 } style={ {width: '100%'} }>
			<tr>
				<td>
					<table className='tabEditView'>
						<tr>
							<td className='dataLabel' style={ {width: '15%'} }>
								{ L10n.Term('SurveyQuestions.LBL_RANGE_VALUES') } &nbsp;<span className='required'>{ L10n.Term('.LBL_REQUIRED_SYMBOL') }</span>
							</td>
							<td className='dataField' style={ {width: '85%', paddingRight: '10px'} }>
								{ L10n.Term('SurveyQuestions.LBL_RANGE_BETWEEN') }
								<input type='text'
									id='RANGE_MIN'
									value={ currentItem['RANGE_MIN'] }
									style={ {width: '100px', marginLeft: '4px', marginRight: '10px'} }
									onChange={ (e) => this._onTEXT_Change(e, 'RANGE_MIN') }
								/>
								{ L10n.Term('SurveyQuestions.LBL_RANGE_AND'    ) }
								<input type='text'
									id='RANGE_MAX'
									value={ currentItem['RANGE_MAX'] }
									style={ {width: '100px', marginLeft: '4px', marginRight: '10px'} }
									onChange={ (e) => this._onTEXT_Change(e, 'RANGE_MAX') }
								/>
							</td>
						</tr>
						<tr>
							<td className='dataLabel' style={ {width: '15%'} }>
								{ L10n.Term('SurveyQuestions.LBL_RANGE_STEP') }
							</td>
							<td className='dataField' style={ {width: '85%', paddingRight: '10px'} }>
								<input type='text'
									id='RANGE_STEP'
									value={ currentItem['RANGE_STEP'] }
									style={ {width: '100px', marginLeft: '4px', marginRight: '10px'} }
									onChange={ (e) => this._onTEXT_Change(e, 'RANGE_STEP') }
								/>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	: null
	}

	{ this.fieldVisibility('pnlDemographic')
	? <div id='pnlDemographic'>
		<h3>{ L10n.Term('SurveyQuestions.LBL_DEMOGRAPHIC_INFORMATION') }</h3>
		<table id='tblDEMOGRAPHIC' className='tabForm' cellPadding={ 0 } cellSpacing={ 1 } style={ {width: '100%'} }>
		{
			this.lstDemographicNames.map((item, index) => 
			{
				let field: any = dtDemographicNames[item];
				return (<tr>
					<td className="dataLabel" style={ {width: '15%', whiteSpace: 'nowrap'} }>
						{ L10n.ListTerm('survey_question_demographic_fields', item) }
					</td>
					<td className="dataField" style={ {width: '25%', whiteSpace: 'nowrap'} }>
						<input type="text" value={ field ? Sql.ToString(field['NAME']) : '' } onChange={ (e) => this._onDEMOGRAPHIC_TEXT_Change(e, item, 'NAME') }/>
					</td>
					<td className="dataField" style={ {width: '10%', whiteSpace: 'nowrap'} }>
						<span className="checkbox">
							<input id={ "DEMOGRAPHIC_NAME_VISIBLE" + item } type="checkbox" checked={ field ? Sql.ToBoolean(field['VISIBLE']) : false } onChange={ (e) => this._onDEMOGRAPHIC_CHECKBOX_Change(e, item, 'VISIBLE') } />
							<label htmlFor={ "DEMOGRAPHIC_NAME_VISIBLE" + item }>{ L10n.Term("SurveyQuestions.LBL_DEMOGRAPHIC_VISIBLE" ) }</label>
						</span>
					</td>
					<td className="dataField" style={ {width: '10%', whiteSpace: 'nowrap'} }>
						<span className="checkbox">
							<input id={ "DEMOGRAPHIC_NAME_REQUIRED_" + item } type="checkbox" checked={ field ? Sql.ToBoolean(field['REQUIRED']) : false } onChange={ (e) => this._onDEMOGRAPHIC_CHECKBOX_Change(e, item, 'REQUIRED') } />
							<label htmlFor={ "DEMOGRAPHIC_NAME_REQUIRED_" + item }>{ L10n.Term("SurveyQuestions.LBL_DEMOGRAPHIC_REQUIRED") }</label>
						</span>
					</td>
					<td className="dataField" style={ {width: '30%', whiteSpace: 'nowrap'} }>
						{ !Sql.IsEmptyString(currentItem['SURVEY_TARGET_MODULE'])
						? <select 
							className='dataField'
							value={ field ? Sql.ToString(field['TARGET_FIELD_NAME']) : '' }
							onChange={ (e) => this._onDEMOGRAPHIC_TEXT_Change(e, item, 'TARGET_FIELD_NAME') }
						>
							<option id={ 'TARGET_FIELD_NAME' + ' _none' } key={ 'TARGET_FIELD_NAME' + ' _none' } value=''>{ L10n.Term('.LBL_NONE') }</option>
							{
								TARGET_FIELD_NAME_LIST.map((item, index) => 
								{
									return (<option id={ 'TARGET_FIELD_NAME' + ' _' + index.toString() } key={ 'TARGET_FIELD_NAME' + '_' + index.toString() } value={ item.NAME }>{ item.DISPLAY_NAME }</option>);
								})
							}
						</select>
						: null
						}
					</td>
					<td className="dataField" style={ {width: '10%'} }>
					</td>
				</tr>
				);
			})
		}
		</table>
		{ bDebug 
		? <div id='dtDemographicNamesDump' dangerouslySetInnerHTML={ {__html: dumpObj(dtDemographicNames, 'dtDemographicNames').replace(/\n/g, '<br />\n').replace(/\t/g, '&nbsp;&nbsp;&nbsp;') } } style={ {marginTop: '20px', border: '1px solid black'} }></div>
		: null
		}
	</div>
	: null
	}

	{ this.fieldVisibility('pnlRequired')
	? <div id='pnlRequired'>
		<h3>{ L10n.Term('SurveyQuestions.LBL_REQUIRED_OPTIONS') }</h3>
		<div id='divRequired'>
			<table className='tabForm' cellPadding={ 0 } cellSpacing={ 1 } style={ {width: '100%'} }>
				<tr>
					<td>
						<table className='tabEditView'>
							<tr>
								<td className='dataLabel' valign='top' style={ {width: '15%'} }>
									{ this.fieldVisibility('REQUIRED')
									? <React.Fragment>
										<input type='checkbox'
											id='REQUIRED'
											checked={ Sql.ToBoolean(currentItem['REQUIRED']) }
											className='checkbox'
											style={ {verticalAlign: 'baseline'} }
											onChange={ (e) => this._onCHECKBOX_Change(e, 'REQUIRED') }
											/>
										<label htmlFor='REQUIRED' style={ {paddingLeft: '4px'} }>{ L10n.Term('SurveyQuestions.LBL_REQUIRED') }</label>
									</React.Fragment>
									: null
									}
								</td>
								<td className='dataField' valign='top' style={ {width: '85%', paddingRight: '10px'} }>
									{ L10n.Term('SurveyQuestions.LBL_REQUIRED_MESSAGE') }<br />
									<textarea id='REQUIRED_MESSAGE'
										value={ currentItem['REQUIRED_MESSAGE'] }
										style={ {width: '100%'} }
										rows={ 2 }
										onChange={ (e) => this._onTEXT_Change(e, 'REQUIRED_MESSAGE') }
									/>
									{ this.fieldVisibility('tblRequiredType')
									? <table id='tblRequiredType' className='tabEditView'>
										<tr>
											<td style={ {width: '20%'} } className='dataLabel'>{ L10n.Term('SurveyQuestions.LBL_REQUIRED_TYPE') }</td>
											<td style={ {width: '80%'} } className='dataField'>
												<select id='REQUIRED_TYPE'
													value={ currentItem['REQUIRED_TYPE'] }
													onChange={ (e) => this._onTEXT_Change(e, 'REQUIRED_TYPE') } 
												>
												{
													REQUIRED_TYPE_LIST.map((item, index) => 
													{
														return (<option id={ 'REQUIRED_TYPE' + ' _' + index.toString() } key={ 'REQUIRED_TYPE' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('survey_question_required_rows', item) }</option>);
													})
												}
												</select>
												<input type='text'
													id='REQUIRED_RESPONSES_MIN'
													value={ currentItem['REQUIRED_RESPONSES_MIN'] }
													style={ {width: '100px', marginLeft: '4px', marginRight: '10px'} }
													onChange={ (e) => this._onTEXT_Change(e, 'REQUIRED_RESPONSES_MIN') }
												/>
												<span id='REQUIRED_RESPONSES_RANGE'>{ L10n.Term('SurveyQuestions.LBL_REQUIRED_RESPONSES_RANGE') }</span>
												<input type='text'
													id='REQUIRED_RESPONSES_MAX'
													value={ currentItem['REQUIRED_RESPONSES_MAX'] }
													style={ {width: '100px', marginLeft: '10px', marginRight: '10px'} }
													onChange={ (e) => this._onTEXT_Change(e, 'REQUIRED_RESPONSES_MAX') }
												/>
											</td>
										</tr>
									</table>
									: null
									}
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</div>
	</div>
	: null
	}

	{ this.fieldVisibility('pnlRandomize')
	? <div id='pnlRandomize'>
		<h3>{ L10n.Term('SurveyQuestions.LBL_RANDOMIZE') }</h3>
		<div id='divRandomize'>
			<table className='tabForm' cellPadding={ 0 } cellSpacing={ 1 } style={ {width: '100%'} }>
				<tr>
					<td>
						<table>
							<tr>
								<td className='dataLabel'>
									{ L10n.Term('SurveyQuestions.LBL_RANDOMIZE_TYPE') }
								</td>
								<td className='dataField'>
									<div id='RANDOMIZE_TYPE'>
										<input type='radio'
											checked={ Sql.IsEmptyString(currentItem['RANDOMIZE_TYPE']) }
											id={ 'RANDOMIZE_TYPE' + ' _none' }
											key={ 'RANDOMIZE_TYPE' + '_none' }
											value=''
											className='radio'
											onChange={ (e) => this._onTEXT_Change(e, 'RANDOMIZE_TYPE') } 
											/>
										<label htmlFor={ 'RANDOMIZE_TYPE' + ' _none' } >{ L10n.Term('Surveys.LBL_NOT_RANDOMIZED') }</label>
									{
										RANDOMIZE_TYPE_LIST.map((item, index) => 
										{
											return (<React.Fragment>
												<input type='radio'
													checked={ currentItem['RANDOMIZE_TYPE'] == item }
													id={ 'RANDOMIZE_TYPE' + ' _' + item }
													key={ 'RANDOMIZE_TYPE' + '_' + item }
													value={ item }
													className='radio'
													onChange={ (e) => this._onTEXT_Change(e, 'RANDOMIZE_TYPE') } 
													/>
												<label htmlFor={ 'RANDOMIZE_TYPE' + ' _' + index.toString() } >{ L10n.ListTerm('survey_answer_randomization', item) }</label>
											</React.Fragment>);
										})
									}
									</div>
								</td>
								<td className='dataField' style={ {paddingLeft: '20px'} }>
									{ this.fieldVisibility('pnlRandomize')
									? <React.Fragment>
										<input type='checkbox'
											id='RANDOMIZE_NOT_LAST'
											checked={ Sql.ToBoolean(currentItem['RANDOMIZE_NOT_LAST']) }
											className='checkbox'
											style={ {verticalAlign: 'baseline'} }
											onChange={ (e) => this._onCHECKBOX_Change(e, 'RANDOMIZE_NOT_LAST') }
											/>
										<label htmlFor='RANDOMIZE_NOT_LAST' style={ {paddingLeft: '4px'} }>{ L10n.Term('SurveyQuestions.LBL_RANDOMIZE_NOT_LAST') }</label>
									</React.Fragment>
									: null
									}
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</div>
	</div>
	: null
	}

	{ this.fieldVisibility('pnlValidationEnabled')
	? <div id='pnlValidationEnabled'>
		<h3>{ L10n.Term('SurveyQuestions.LBL_VALIDATION_ENABLED') }</h3>
		<div id='divValidationEnabled'>
			<table className='tabForm' cellPadding={ 0 } cellSpacing={ 1 } style={ {width: '100%'} }>
				<tr>
					<td style={ {width: '15%'} } className='dataLabel'>{ L10n.Term('SurveyQuestions.LBL_VALIDATION_TYPE') }</td>
					<td style={ {width: '85%'} } className='dataField'>
						<select id='VALIDATION_TYPE'
							style={ {marginRight: '10px'} }
							value={ currentItem['VALIDATION_TYPE'] }
							onChange={ (e) => this._onTEXT_Change(e, 'VALIDATION_TYPE') } 
						>
						{
							VALIDATION_TYPE_LIST.map((item, index) => 
							{
								if ( Sql.IsEmptyString(item) )
									return (<option id={ 'VALIDATION_TYPE' + ' _' + index.toString() } key={ 'VALIDATION_TYPE' + '_' + index.toString() } value={ item }>{ L10n.Term('.' + VALIDATION_TYPE_LIST_NAME + '.') }</option>);
								else
									return (<option id={ 'VALIDATION_TYPE' + ' _' + index.toString() } key={ 'VALIDATION_TYPE' + '_' + index.toString() } value={ item }>{ L10n.ListTerm(VALIDATION_TYPE_LIST_NAME, item) }</option>);
							})
						}
						</select>
						{ !Sql.IsEmptyString(currentItem['VALIDATION_TYPE']) && currentItem['VALIDATION_TYPE'] != 'Email'
						? <span id='spnValidation'>
							{ L10n.Term('SurveyQuestions.LBL_VALIDATION_BETWEEN') }
							<input type='text'
								id='VALIDATION_MIN'
								value={ currentItem['VALIDATION_MIN'] }
								style={ {width: '100px', marginLeft: '4px', marginRight: '10px'} }
								onChange={ (e) => this._onTEXT_Change(e, 'VALIDATION_MIN') }
							/>
							{ L10n.Term('SurveyQuestions.LBL_VALIDATION_AND'    ) }
							<input type='text'
								id='VALIDATION_MAX'
								value={ currentItem['VALIDATION_MAX'] }
								style={ {width: '100px', marginLeft: '4px', marginRight: '10px'} }
								onChange={ (e) => this._onTEXT_Change(e, 'VALIDATION_MAX') }
							/>
						</span>
						: null
						}
					</td>
				</tr>
				<tr>
					<td className='dataField' colSpan={ 2 } style={ {paddingRight: '10px'} }>
						{ !Sql.IsEmptyString(currentItem['VALIDATION_TYPE'])
						? <textarea id='VALIDATION_MESSAGE'
							value={ currentItem['VALIDATION_MESSAGE'] }
							style={ {width: '100%'} }
							rows={ 2 }
							onChange={ (e) => this._onTEXT_Change(e, 'VALIDATION_MESSAGE') }
						/>
						: null
						}
					</td>
				</tr>
			</table>
		</div>
	</div>
	: null
	}

	{ this.fieldVisibility('pnlValidationSum')
	? <div id='pnlValidationSum'>
		<h3></h3>
		<div id='divValidationSum'>
			<table className='tabForm' cellPadding={ 0 } cellSpacing={ 1 } style={ {width: '100%'} }>
				<tr>
					<td style={ {width: '15%'} } className='dataField' valign='top'>
						<input type='checkbox'
							id='VALIDATION_SUM_ENABLED'
							checked={ Sql.ToBoolean(currentItem['VALIDATION_SUM_ENABLED']) }
							className='checkbox'
							style={ {verticalAlign: 'baseline'} }
							onChange={ (e) => this._onCHECKBOX_Change(e, 'VALIDATION_SUM_ENABLED') }
							/>
						<label htmlFor='VALIDATION_SUM_ENABLED' style={ {paddingLeft: '4px'} }>{ L10n.Term('SurveyQuestions.LBL_VALIDATION_SUM_ENABLED') }</label>
					</td>
					<td style={ {width: '15%'} } className='dataLabel' valign='top'>{ L10n.Term('SurveyQuestions.LBL_VALIDATION_SUM') }</td>
					<td style={ {width: '70%'} } className='dataField' valign='top'>
						<input type='text'
							id='VALIDATION_NUMERIC_SUM'
							value={ currentItem['VALIDATION_NUMERIC_SUM'] }
							style={ {width: '100px', marginLeft: '4px', marginRight: '10px'} }
							onChange={ (e) => this._onTEXT_Change(e, 'VALIDATION_NUMERIC_SUM') }
						/>
					</td>
				</tr>
				<tr>
					<td className='dataField' colSpan={ 4 } style={ {paddingRight: '10px'} }>
						<textarea id='VALIDATION_SUM_MESSAGE'
							value={ currentItem['VALIDATION_SUM_MESSAGE'] }
							style={ {width: '100%'} }
							rows={ 2 }
							onChange={ (e) => this._onTEXT_Change(e, 'VALIDATION_SUM_MESSAGE') }
						/>
					</td>
				</tr>
			</table>
		</div>
	</div>
	: null
	}

	{ this.fieldVisibility('pnlName')
	? <div id='pnlName'>
		<h3></h3>
		<table className='tabForm' cellPadding={ 0 } cellSpacing={ 1 } style={ {width: '100%'} }>
			<tr>
				<td>
					<table className='tabEditView'>
						<tr>
							<td className='dataLabel'>
								{ L10n.Term('SurveyQuestions.LBL_NAME') }
							</td>
						</tr>
						<tr>
							<td className='dataField' colSpan={ 2 }>
								<input type='text'
									id='NAME'
									value={ currentItem['NAME'] }
									size={ 80 } maxLength={ 150 }
									onChange={ (e) => this._onTEXT_Change(e, 'NAME') }
								/>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	: null
	}

	{ this.fieldVisibility('pnlImage')
	? <div id='pnlImage'>
		<table className='tabForm' cellPadding={ 0 } cellSpacing={ 1 } style={ {width: '100%'} }>
			<tr>
				<td>
					<table className='tabEditView'>
						<tr>
							<td className='dataLabel' style={ {width: '15%', whiteSpace: 'nowrap'} }>
								<input type='radio'
									id='radIMAGE_UPLOAD'
									radioGroup='IMAGE'
									checked={ !Sql.ToBoolean(currentItem['radIMAGE_URL']) }
									className='radio'
									value='false'
									onChange={ (e) => this._onChange('radIMAGE_URL', !e.target.checked) }
								/>
								<label htmlFor='radIMAGE_UPLOAD'>{ L10n.Term('SurveyQuestions.LBL_IMAGE_UPLOAD') }</label>
							</td>
							<td className='dataField' style={ {width: '85%'} }>
								<input type='file' id='UPLOAD_IMAGE' size={ 30 } />
							</td>
						</tr>
						<tr>
							<td className='dataLabel' style={ {whiteSpace: 'nowrap'} }>
								<input type='radio'
									id='radIMAGE_URL'
									radioGroup='IMAGE'
									checked={ Sql.ToBoolean(currentItem['radIMAGE_URL']) }
									className='radio'
									value='true'
									onChange={ (e) => this._onCHECKBOX_Change(e, 'radIMAGE_URL') }
								/>
								<label htmlFor='radIMAGE_URL'>{ L10n.Term('SurveyQuestions.LBL_IMAGE_URL') }</label>
							</td>
							<td className='dataField'>
								<input type='text'
									id='IMAGE_URL'
									value={ currentItem['IMAGE_URL'] }
									style={ {width: '100%'} }
									onChange={ (e) => this._onTEXT_Change(e, 'IMAGE_URL') }
								/>
							</td>
						</tr>
						<tr>
							<td className='dataLabel'>
								{ L10n.Term('SurveyQuestions.LBL_EXISTING_IMAGE') }
							</td>
							<td className='dataField'>
								<img id='imgIMAGE' />
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	: null
	}

	<h3>{ L10n.Term('SurveyQuestions.LBL_QUESTION_SIZE') }</h3>
	{ this.fieldVisibility('divQuestionSize')
	? <div id='divQuestionSize'>
		<table className='tabForm' cellPadding={ 0 } cellSpacing={ 1 } style={ {width: '100%'} }>
			<tr>
				<td>
					{ this.fieldVisibility('tblSize')
					? <table id='tblSize' className='tabEditView'>
						<tr>
							<td style={ {width: '15%'} } className='dataLabel'>
								{ L10n.Term('SurveyQuestions.LBL_SIZE') }
							</td>
							<td style={ {width: '85%'} } className='dataField'>
								{ this.fieldVisibility('SIZE_UNITS')
								? <select id='SIZE_UNITS'
									style={ {marginRight: '10px'} }
									value={ currentItem['SIZE_UNITS'] }
									onChange={ (e) => this._onTEXT_Change(e, 'SIZE_UNITS') } 
								>
								{
									SIZE_UNITS_LIST.map((item, index) => 
									{
										return (<option id={ 'SIZE_UNITS' + ' _' + index.toString() } key={ 'SIZE_UNITS' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('survey_question_width_units', item) }</option>);
									})
								}
								</select>
								: null
								}
								{ this.fieldVisibility('SIZE_HEIGHT')
								? <select id='SIZE_HEIGHT'
									style={ {marginRight: '10px'} }
									value={ currentItem['SIZE_HEIGHT'] }
									onChange={ (e) => this._onTEXT_Change(e, 'SIZE_HEIGHT') } 
								>
								{
									SIZE_HEIGHT_LIST.map((item, index) => 
									{
										return (<option id={ 'SIZE_HEIGHT' + ' _' + index.toString() } key={ 'SIZE_HEIGHT' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('survey_question_field_lines', item) }</option>);
									})
								}
								</select>
								: null
								}
								{ this.fieldVisibility('SIZE_WIDTH')
								? <select id='SIZE_WIDTH'
									style={ {marginRight: '10px'} }
									value={ currentItem['SIZE_WIDTH'] }
									onChange={ (e) => this._onTEXT_Change(e, 'SIZE_WIDTH') } 
								>
								{
									SIZE_WIDTH_LIST.map((item, index) => 
									{
										return (<option id={ 'SIZE_WIDTH' + ' _' + index.toString() } key={ 'SIZE_WIDTH' + '_' + index.toString() } value={ item }>{ L10n.ListTerm(SIZE_WIDTH_LIST_NAME, item) }</option>);
									})
								}
								</select>
								: null
								}
							</td>
						</tr>
					</table>
					: null
					}
					{ this.fieldVisibility('tblBoxSize')
					? <table id='tblBoxSize' className='tabEditView'>
						<tr>
							<td style={ {width: '15%'} } className='dataLabel'>
								{ L10n.Term('SurveyQuestions.LBL_BOX_SIZE') }
							</td>
							<td style={ {width: '85%'} } className='dataField'>
								{ this.fieldVisibility('BOX_HEIGHT')
								? <select id='BOX_HEIGHT'
									style={ {marginRight: '10px'} }
									value={ currentItem['BOX_HEIGHT'] }
									onChange={ (e) => this._onTEXT_Change(e, 'BOX_HEIGHT') } 
								>
								{
									BOX_HEIGHT_LIST.map((item, index) => 
									{
										return (<option id={ 'BOX_HEIGHT' + ' _' + index.toString() } key={ 'BOX_HEIGHT' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('survey_question_field_lines', item) }</option>);
									})
								}
								</select>
								: null
								}
								{ this.fieldVisibility('BOX_WIDTH')
								? <select id='BOX_WIDTH'  style={ {marginRight: '10px'} }
									value={ currentItem['BOX_WIDTH'] }
									onChange={ (e) => this._onTEXT_Change(e, 'BOX_WIDTH') } 
								>
								{
									BOX_WIDTH_LIST.map((item, index) => 
									{
										return (<option id={ 'BOX_WIDTH' + ' _' + index.toString() } key={ 'BOX_WIDTH' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('survey_question_field_chars', item) }</option>);
									})
								}
								</select>
								: null
								}
							</td>
						</tr>
					</table>
					: null
					}
					{ this.fieldVisibility('tblColumnWidth')
					? <table id='tblColumnWidth' className='tabEditView'>
						<tr>
							<td style={ {width: '15%'} } className='dataLabel'>
								{ L10n.Term('SurveyQuestions.LBL_COLUMN_WIDTH') }
							</td>
							<td style={ {width: '85%'} } className='dataField'>
								<select id='COLUMN_WIDTH'
									value={ currentItem['COLUMN_WIDTH'] }
									onChange={ (e) => this._onTEXT_Change(e, 'COLUMN_WIDTH') } 
								>
								{
									COLUMN_WIDTH_LIST.map((item, index) => 
									{
										return (<option id={ 'COLUMN_WIDTH' + ' _' + index.toString() } key={ 'COLUMN_WIDTH' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('survey_question_columns_width', item) }</option>);
									})
								}
								</select>
							</td>
						</tr>
					</table>
					: null
					}
					<table className='tabEditView'>
						<tr>
							<td style={ {width: '15%'} } className='dataLabel'>
								{ L10n.Term('SurveyQuestions.LBL_PLACEMENT') }
							</td>
							<td style={ {width: '85%'} } className='dataField'>
								<select id='PLACEMENT'
									value={ currentItem['PLACEMENT'] }
									onChange={ (e) => this._onTEXT_Change(e, 'PLACEMENT') } 
								>
								{
									PLACEMENT_LIST.map((item, index) => 
									{
										return (<option id={ 'PLACEMENT' + ' _' + index.toString() } key={ 'PLACEMENT' + '_' + index.toString() } value={ item }>{ L10n.ListTerm('survey_question_placement', item) }</option>);
									})
								}
								</select>
							</td>
						</tr>
					</table>
					<table className='tabEditView'>
						<tr>
							<td style={ {width: '15%'} } className='dataLabel'>
								{ L10n.Term('SurveyQuestions.LBL_SPACING') }
							</td>
							<td style={ {width: '85%'} } className='dataField'>
								{ L10n.Term('SurveyQuestions.LBL_SPACING_LEFT'  ) }
								<input type='text'
									id='SPACING_LEFT'
									value={ currentItem['SPACING_LEFT'  ] }
									style={ {width: '100px', marginLeft: '4px', marginRight: '10px'} }
									onChange={ (e) => this._onTEXT_Change(e, 'SPACING_LEFT'  ) }
								/>
								{ L10n.Term('SurveyQuestions.LBL_SPACING_TOP'   ) }
								<input type='text'
									id='SPACING_TOP'
									value={ currentItem['SPACING_TOP'   ] }
									style={ {width: '100px', marginLeft: '4px', marginRight: '10px'} }
									onChange={ (e) => this._onTEXT_Change(e, 'SPACING_TOP'   ) }
								/>
								{ L10n.Term('SurveyQuestions.LBL_SPACING_RIGHT' ) }
								<input type='text'
									id='SPACING_RIGHT'
									value={ currentItem['SPACING_RIGHT' ] }
									style={ {width: '100px', marginLeft: '4px', marginRight: '10px'} }
									onChange={ (e) => this._onTEXT_Change(e, 'SPACING_RIGHT' ) }
								/>
								{ L10n.Term('SurveyQuestions.LBL_SPACING_BOTTOM') }
								<input type='text'
									id='SPACING_BOTTOM'
									value={ currentItem['SPACING_BOTTOM'] }
									style={ {width: '100px', marginLeft: '4px', marginRight: '10px'} }
									onChange={ (e) => this._onTEXT_Change(e, 'SPACING_BOTTOM') }
								/>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	</div>
	: null
	}

				{ !callback && headerButtons
				? <DynamicButtons
					ButtonStyle="EditHeader"
					VIEW_NAME={ EDIT_NAME }
					row={ item }
					Page_Command={ this.Page_Command }
					history={ this.props.history }
					location={ this.props.location }
					match={ this.props.match }
					ref={ this.dynamicButtonsBottom }
				/>
				: null
				}
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

// 07/18/2019 Paul.  We don't want to use withRouter() as it makes it difficult to get a reference. 

