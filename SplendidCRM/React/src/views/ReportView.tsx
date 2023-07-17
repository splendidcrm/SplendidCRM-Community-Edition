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
import { RouteComponentProps, withRouter }            from 'react-router-dom'                     ;
import { observer }                                   from 'mobx-react'                           ;
import { FontAwesomeIcon }                            from '@fortawesome/react-fontawesome'       ;
// 2. Store and Types. 
import { HeaderButtons }                              from '../types/HeaderButtons'               ;
import { EditComponent }                              from '../types/EditComponent'               ;
import EDITVIEWS_FIELD                                from '../types/EDITVIEWS_FIELD'             ;
import REPORT_PARAMETER_RECORD                        from '../types/REPORT_PARAMETER_RECORD'     ;
// 3. Scripts. 
import Sql                                            from '../scripts/Sql'                       ;
import L10n                                           from '../scripts/L10n'                      ;
import Credentials                                    from '../scripts/Credentials'               ;
import SplendidCache                                  from '../scripts/SplendidCache'             ;
import SplendidDynamic_EditView                       from '../scripts/SplendidDynamic_EditView'  ;
import { AuthenticatedMethod, LoginRedirect }         from '../scripts/Login'                     ;
import { DetailView_LoadItem }                        from '../scripts/DetailView'                ;
import { DeleteModuleItem }                           from '../scripts/ModuleUpdate'              ;
import { CreateSplendidRequest, GetSplendidResult }   from '../scripts/SplendidRequest'           ;
import { FromJsonDate, ToJsonDate, formatDate }       from '../scripts/Formatting'                ;
import { jsonReactState }                             from '../scripts/Application'               ;
import withScreenSizeHook                             from '../scripts/ScreenSizeHook'            ;
// 4. Components and Views. 
import ErrorComponent                                 from '../components/ErrorComponent'         ;
import DumpSQL                                        from '../components/DumpSQL'                ;
import HeaderButtonsFactory                           from '../ThemeComponents/HeaderButtonsFactory';

let MODULE_NAME: string = 'Reports';

interface IReportViewProps extends RouteComponentProps<any>
{
	ID?          : string;
	NAME?        : string;
	ReportDesign?: any;
	screenSize   : any;
}

interface IReportViewState
{
	__sql           : string;
	report          : any;
	item            : any;
	SUB_TITLE       : any;
	error           : any;
	layout          : EDITVIEWS_FIELD[];
	parameters      : REPORT_PARAMETER_RECORD[];
	editedItem      : any;
	dependents      : Record<string, Array<any>>;
	bRequireSubmit  : boolean;
	bSubmit         : boolean;
}

@observer
class ReportView extends React.Component<IReportViewProps, IReportViewState>
{
	private _isMounted     : boolean = false;
	private headerButtons  = React.createRef<HeaderButtons>();
	private refMap         : Record<string, React.RefObject<EditComponent<any, any>>>;
	private submitButton   = React.createRef<HTMLInputElement>();
	private renderCount    : number = 0;

	constructor(props: IReportViewProps)
	{
		super(props);
		this.state =
		{
			__sql           : null,
			report          : null,
			item            : null,
			SUB_TITLE       : null,
			error           : null,
			layout          : null,
			parameters      : null,
			editedItem      : null,
			dependents      : {},
			bRequireSubmit  : false,
			bSubmit         : false,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		const { ID } = this.props;
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
				if ( Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(false);
				}
				if ( !Sql.IsEmptyGuid(ID) )
				{
					await this.load();
				}
				else
				{
					this.setState({ SUB_TITLE: this.props.NAME });
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

	async componentDidUpdate(prevProps: IReportViewProps)
	{
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			// 04/26/2019 Paul.  Bounce through ResetView so that layout gets completely reloaded. 
			// 11/20/2019 Paul.  Include search parameters. 
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
	}

	componentWillUnmount()
	{
		this._isMounted = false;
	}

	private load = async () =>
	{
		const { ID } = this.props;
		try
		{
			// 11/19/2019 Paul.  Change to allow return of SQL. 
			const d = await DetailView_LoadItem(MODULE_NAME, ID, false, false);
			if ( this._isMounted )
			{
				let report: any = d.results;
				// 11/23/2020 Paul.  Update document title. 
				Sql.SetPageTitle(MODULE_NAME, report, 'NAME');
				let SUB_TITLE: any = Sql.DataPrivacyErasedField(report, 'NAME');
				// 04/29/2019 Paul.  Manually add to the list so that we do not need to request an update. 
				if ( report != null )
				{
					let sNAME = Sql.ToString(report['NAME']);
					if ( !Sql.IsEmptyString(sNAME) )
					{
						SplendidCache.AddLastViewed(MODULE_NAME, ID, sNAME);
					}
				}
				let res  = await CreateSplendidRequest('Reports/Rest.svc/GetReportParameters?ID=' + ID, 'GET');
				let json = await GetSplendidResult(res);
				let obj: any = json.d;
				let bRequireSubmit: boolean = false;
				let layout        : EDITVIEWS_FIELD[] = null;
				let parameters    : REPORT_PARAMETER_RECORD[] = null;
				let item          : any = null;
				if ( obj != null )
				{
					parameters = obj.Parameters;
					layout     = obj.Layout;
					if ( layout )
					{
						item = {};
						for ( let i in parameters )
						{
							let rowParameter: any = parameters[i];
							let sDATA_FIELD   : string = Sql.ToString(rowParameter["NAME"         ]);
							let sDEFAULT_VALUE: string = Sql.ToString(rowParameter["DEFAULT_VALUE"]);
							// 02/12/2021 Paul.  Provide a way to require submit before running report. 
							if ( sDATA_FIELD == "RequireSubmit" )
							{
								bRequireSubmit = Sql.ToBoolean(sDEFAULT_VALUE);
							}
							//if ( sDEFAULT_VALUE.substr(0, 7) === '\\/Date(' )
							item[sDATA_FIELD] = sDEFAULT_VALUE;
						}
					}
				}
				this.setState({ item, report, SUB_TITLE, __sql: d.__sql, layout, parameters, bRequireSubmit });
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
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
			if ( DATA_FIELD == 'MODULE_NAME' )
			{
				this.setState({ editedItem: item });
			}
			else
			{
				this.setState({ editedItem: item });
			}
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

	// 06/15/2018 Paul.  The SearchView will register for the onSubmit event. 
	private _onSubmit = (): void =>
	{
		this.Page_Command('Submit', null);
	}

	// 05/14/2018 Chase. This function will be passed to DynamicButtons to be called as Page_Command
	// Add additional params if you need access to the onClick event params.
	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { ID, history } = this.props;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments);
		switch ( sCommandName )
		{
			case 'Attachment'      :
			case 'Attachment-PDF'  :
			case 'Attachment-Excel':
			case 'Attachment-Word' :
			case 'Attachment-Image':
			{
				try
				{
					let sUrl : string = 'ReportDesigner/Rest.svc/CreateAttachment';
					let res = await CreateSplendidRequest(sUrl + '?ID=' + this.props.ID + '&AttachmentType=' + sCommandName, 'GET');
					let json = await GetSplendidResult(res);
					let sNOTE_ID = json.d;
					//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, sCommandArguments, sNOTE_ID);
					history.push(`/Reset/Emails/Edit?NOTE_ID=` + sNOTE_ID);
				}
				catch(error)
				{
					this.setState({ error });
				}
				break;
			}
			case 'Submit':
			{
				if ( this.submitButton.current )
				{
					//this.submitButton.current.click();
					let reportForm: HTMLFormElement = this.submitButton.current.parentElement as HTMLFormElement;
					reportForm.submit();
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

	private _onButtonsLoaded = async () =>
	{
		const { layout } = this.state;
		if ( this.headerButtons.current != null )
		{
			let bShowSubmit: boolean = (layout !== null && layout.length > 0);
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onButtonsLoaded', bShowSubmit);
			this.headerButtons.current.ShowButton('Submit', bShowSubmit );
		}
	}

	private UrlParams = () =>
	{
		const { item, editedItem, parameters } = this.state;
		const currentItem: any = Object.assign({}, item, editedItem);
		let params: string = '';
		if ( this.refMap != null )
		{
			params = '&DisableContentDisposition=true';
			for ( let j in parameters )
			{
				let rowParameter: REPORT_PARAMETER_RECORD = parameters[j];
				let NAME : string = rowParameter['NAME'];
				let VALUE: any = currentItem[NAME];
				if ( VALUE )
				{
					// http://momentjs.com/docs/#/displaying/as-javascript-date/
					if ( typeof (VALUE) == 'object' && (VALUE instanceof Date || VALUE._isAMomentObject) )
					{
						VALUE = ToJsonDate(VALUE);
					}
					if ( Array.isArray(VALUE) )
					{
						for ( let i = 0; i < VALUE.length; i++ )
						{
							params += '&' + NAME + '=' + encodeURIComponent(VALUE[i]);
						}
					}
					else
					{
						params += '&' + NAME + '=' + encodeURIComponent(Sql.ToString(VALUE));
					}

					}
			}
		}
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.UrlParams', this.refMap, params);
		return params;
	}

	private PostParams = () =>
	{
		const { item, editedItem, parameters } = this.state;
		const currentItem: any = Object.assign({}, item, editedItem);
		let params: any[] = [];
		if ( this.refMap != null )
		{
			params.push(<input type="hidden" name="DisableContentDisposition" value="true" />);
			for ( let j in parameters )
			{
				let rowParameter: REPORT_PARAMETER_RECORD = parameters[j];
				let NAME : string = rowParameter['NAME'];
				let VALUE: any = currentItem[NAME];
				if ( VALUE )
				{
					// http://momentjs.com/docs/#/displaying/as-javascript-date/
					if ( typeof (VALUE) == 'object' && (VALUE instanceof Date || VALUE._isAMomentObject) )
					{
						VALUE = ToJsonDate(VALUE);
					}
					if ( Array.isArray(VALUE) )
					{
						for ( let i = 0; i < VALUE.length; i++ )
						{
							params.push(<input type="hidden" name={ NAME } value={ VALUE[i] } />);
						}
					}
					else
					{
						params.push(<input type="hidden" name={ NAME } value={ VALUE } />);
					}
				}
			}
		}
		return params;
	}

	private formRef = (element: HTMLFormElement) =>
	{
		const { bRequireSubmit } = this.state;
		console.log(this.constructor.name + '.formRef', element);
		try
		{
			if ( element != null )
			{
				if ( !bRequireSubmit )
				{
					if ( this.renderCount == 0 )
					{
						this.renderCount++;
						element.submit();
					}
				}
			}
		}
		catch(ex)
		{
			console.error(this.constructor.name + '.formRef', ex);
		}
	}

	public render()
	{
		const { ID, ReportDesign, screenSize } = this.props;
		const { report, item, SUB_TITLE, error, layout, bRequireSubmit, bSubmit } = this.state;
		const { __sql } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', layout, item);
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render screenSize', screenSize);
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		// 05/15/2018 Paul.  Defer process button logic. 
		// 06/26/2019 Paul.  Specify a key so that SplendidGrid will get componentDidMount when changing views. 
		if ( SplendidCache.IsInitialized && (report || ReportDesign)  )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let height     : number = screenSize.height - 180;
			let VIEW_NAME  : string = null;
			let sSCRIPT_URL: string = Credentials.RemoteServer + 'Reports/render.aspx';
			if ( !Sql.IsEmptyGuid(ID) )
			{
				VIEW_NAME = 'Reports.DetailView';
				sSCRIPT_URL += '?ID=' + ID;
			}
			else
			{
				height = screenSize.height - 220;
			}
			this.refMap = {};
			return (
			<React.Fragment>
				{ headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, hideTitle: Sql.IsEmptyGuid(ID), enableFavorites: !Sql.IsEmptyGuid(ID), error, enableHelp: !Sql.IsEmptyGuid(ID), helpName: 'DetailView', ButtonStyle: 'EditHeader', VIEW_NAME, row: report, Page_Command: this.Page_Command, showButtons: !Sql.IsEmptyGuid(ID), showProcess: false, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<DumpSQL SQL={ __sql } />
				{ SplendidDynamic_EditView.AppendEditViewFields(item, layout, this.refMap, null, this._createDependency, null, this._onChange, this._onUpdate, this._onSubmit, 'tabForm', this.Page_Command) }
				{ bRequireSubmit
				? L10n.Term('Reports.LBL_PRESS_SUBMIT_TO_RUN')
				: null
				}
				<div style={ {display: 'flex', flexGrow: 1} }>
					{ !bRequireSubmit || bSubmit 
					? <iframe name={ 'ReportView_' + ID } src="" className="embed-responsive-item" width="100%" height={ height.toString() + 'px'}></iframe>
					: null
					}
				</div>
				<form action={ sSCRIPT_URL } method="POST" target={ 'ReportView_' + ID } ref={ (element) => this.formRef(element) }>
					{ this.PostParams() }
					<input type="submit" ref={ this.submitButton } />
					{ Sql.IsEmptyGuid(ID)
					? <input type="hidden" name="ReportDesign" value={ ReportDesign } />
					: null
					}
				</form>
			</React.Fragment>
			);
		}
		else if ( error )
		{
			return (<ErrorComponent error={error} />);
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

export default withRouter(withScreenSizeHook(ReportView));
