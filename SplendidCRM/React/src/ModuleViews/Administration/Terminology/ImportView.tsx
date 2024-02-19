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
import { RouteComponentProps, withRouter }          from '../Router5'                         ;
import { observer }                                 from 'mobx-react'                               ;
import { FontAwesomeIcon }                          from '@fortawesome/react-fontawesome'           ;
// 2. Store and Types. 
import { EditComponent }                            from '../../../types/EditComponent'             ;
import { HeaderButtons }                            from '../../../types/HeaderButtons'             ;
// 3. Scripts. 
import L10n                                         from '../../../scripts/L10n'                    ;
import Sql                                          from '../../../scripts/Sql'                     ;
import Security                                     from '../../../scripts/Security'                ;
import Credentials                                  from '../../../scripts/Credentials'             ;
import SplendidCache                                from '../../../scripts/SplendidCache'           ;
import { Admin_GetReactState }                      from '../../../scripts/Application'             ;
import { AuthenticatedMethod, LoginRedirect }       from '../../../scripts/Login'                   ;
import { base64ArrayBuffer }                        from '../../../scripts/utility'                 ;
import { CreateSplendidRequest, GetSplendidResult } from '../../../scripts/SplendidRequest'          ;
// 4. Components and Views. 
import ListHeader                                   from '../../../components/ListHeader'               ;
import DetailViewRelationships                      from '../../../views/DetailViewRelationships'       ;
import HeaderButtonsFactory                         from '../../../ThemeComponents/HeaderButtonsFactory';

interface IAdminConfigViewProps extends RouteComponentProps<any>
{
	MODULE_NAME         : string;
	ID?                 : string;
	LAYOUT_NAME?        : string;
	MODULE_TITLE?       : string;
	callback?           : Function;
	rowDefaultSearch?   : any;
	onLayoutLoaded?     : Function;
	onSubmit?           : Function;
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

interface IAdminConfigViewState
{
	layout            : any;
	FILE_DATA         : string;
	FILE_MIME_TYPE    : string;
	bTruncate         : boolean;
	bForceUTF8        : boolean;
	MODULE_NAME       : string;
	BUTTON_NAME       : string;
	DETAIL_NAME       : string;
	MODULE_TITLE      : string;
	DUPLICATE         : boolean;
	LAST_DATE_MODIFIED: Date;
	dependents        : Record<string, Array<any>>;
	error?            : any;
}

@observer
export default class TerminologyImportView extends React.Component<IAdminConfigViewProps, IAdminConfigViewState>
{
	private _isMounted = false;
	private headerButtons = React.createRef<HeaderButtons>();
	private fileUpload    = React.createRef<HTMLInputElement>();

	constructor(props: IAdminConfigViewProps)
	{
		super(props);
		let MODULE_NAME: string = props.MODULE_NAME;
		if ( Sql.IsEmptyString(MODULE_NAME) )
		{
			let arrPathname: string[] = props.location.pathname.split('/');
			for ( let i: number = 0; i < arrPathname.length; i++ )
			{
				if ( i > 0 && arrPathname[i - 1].toLowerCase() == 'administration' )
				{
					MODULE_NAME = arrPathname[i];
					break;
				}
			}
			if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
			{
				for ( let i: number = arrPathname.length - 1; i >= 0; i-- )
				{
					if ( !Sql.IsEmptyString(arrPathname[i]) )
					{
						let MODULE = SplendidCache.Module(arrPathname[i], this.constructor.name + '.constructor');
						if ( MODULE != null )
						{
							MODULE_NAME = arrPathname[i];
							break;
						}
					}
				}
			}
		}

		let BUTTON_NAME: string = null;
		let MODULE_TITLE: string = L10n.Term('.LBL_IMPORT');
		Credentials.SetViewMode('AdminConfigView');
		this.state =
		{
			layout            : null,
			FILE_DATA         : null,
			FILE_MIME_TYPE    : null,
			bTruncate         : false,
			bForceUTF8        : true,
			MODULE_NAME       ,
			BUTTON_NAME       ,
			DETAIL_NAME       : 'Terminology.ImportView',
			MODULE_TITLE      ,
			DUPLICATE         : false,
			LAST_DATE_MODIFIED: null,
			dependents        : {},
			error             : null,
		};
	}

	componentDidCatch(error, info)
	{
		console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidCatch', error, info);
	}

	async componentDidMount()
	{
		const { MODULE_NAME } = this.state;
		this._isMounted = true;
		try
		{
			let status = await AuthenticatedMethod(this.props, this.constructor.name + '.componentDidMount');
			if ( status == 1 )
			{
				if ( !Security.IS_ADMIN() )
				{
					throw(L10n.Term('.LBL_INSUFFICIENT_ACCESS'));
				}
				if ( SplendidCache.AdminMenu == null )
				{
					await Admin_GetReactState(this.constructor.name + '.componentDidMount');
				}
				if ( !Credentials.ADMIN_MODE )
				{
					Credentials.SetADMIN_MODE(true);
				}
				document.title = L10n.ListTerm('moduleList', 'Administration');
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

	async componentDidUpdate(prevProps: IAdminConfigViewProps)
	{
		// 04/28/2019 Paul.  Include pathname in filter to prevent double-bounce when state changes. 
		if ( this.props.location.pathname != prevProps.location.pathname )
		{
			// 04/26/2019 Paul.  Bounce through ResetView so that layout gets completely reloaded. 
			// 11/20/2019 Paul.  Include search parameters. 
			this.props.history.push('/Reset' + this.props.location.pathname + this.props.location.search);
		}
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		else
		{
			if ( this.props.onComponentComplete )
			{
				const { MODULE_NAME, ID } = this.props;
				const { layout, DETAIL_NAME, error } = this.state;
				//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '._onComponentComplete ' + DETAIL_NAME, item);
				if ( layout != null && error == null )
				{
					if ( this._areRelationshipsComplete )
					{
						this.props.onComponentComplete(MODULE_NAME, null, DETAIL_NAME, null);
					}
				}
			}
		}
	}

	private _areRelationshipsComplete: boolean = false;

	private onRelationshipsComplete = (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain): void =>
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.onRelationshipsComplete ' + LAYOUT_NAME, vwMain);
		this._areRelationshipsComplete = true;
		if ( this.props.onComponentComplete )
		{
			const { MODULE_NAME, ID } = this.props;
			const { layout, DETAIL_NAME, error } = this.state;
			if ( layout != null && error == null )
			{
				if ( this._areRelationshipsComplete )
				{
					this.props.onComponentComplete(MODULE_NAME, null, DETAIL_NAME, null);
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
		try
		{
			if ( this._isMounted )
			{
				this.setState(
				{
					layout: {},
				}, () =>
				{
					if ( this.props.onLayoutLoaded )
					{
						this.props.onLayoutLoaded();
					}
				});
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
	}

	private Page_Command = async (sCommandName, sCommandArguments) =>
	{
		const { history } = this.props;
		const { bTruncate, bForceUTF8, FILE_DATA, FILE_MIME_TYPE } = this.state;
		switch (sCommandName)
		{
			case 'Save':
			case 'Next':
			{
				try
				{
					if ( this.headerButtons.current != null )
					{
						this.headerButtons.current.Busy();
					}
					let obj: any = {};
					obj['Truncate'      ] = bTruncate     ;
					obj['ForceUTF8'     ] = bForceUTF8    ;
					obj['FILE_MIME_TYPE'] = FILE_MIME_TYPE;
					obj['FILE_DATA'     ] = FILE_DATA     ;
					let sBody: string = JSON.stringify(obj);
					let res = await CreateSplendidRequest('Administration/Terminology/Rest.svc/ImportLanguagePackFile', 'POST', 'application/json; charset=utf-8', sBody);
					let json = await GetSplendidResult(res);
					if ( this._isMounted )
					{
						this.fileUpload.current.value = '';
						this.setState( {error: 'Import Complete' });
					}
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.Page_Command ' + sCommandName, error);
					this.setState({ error });
				}
				finally
				{
					if ( this.headerButtons.current != null )
					{
						this.headerButtons.current.NotBusy();
					}
				}
				break;
			}
			case 'Cancel':
			case 'Back':
			{
				history.push(`/Reset/Administration`);
				break;
			}
			default:
			{
				this.setState( {error: 'Unknown command: ' + sCommandName} );
				break;
			}
		}
	}

	private _onButtonsLoaded = async () =>
	{
		if ( this.headerButtons.current != null )
		{
		}
	}

	private _onFILE_Upload = (e) =>
	{
		try
		{
			let FILE_NAME: string = e.target.value;
			let files = e.target.files;
			if ( files.length > 0 )
			{
				let file = files[0];
				// http://www.javascripture.com/FileReader
				let reader = new FileReader();
				reader.onload = async () =>
				{
					let arrayBuffer = reader.result;
					let hidUploadNAME: string = file.name;
					let hidUploadTYPE: string = file.type;
					let hidUploadDATA: string = base64ArrayBuffer(arrayBuffer);
					this.setState({ FILE_DATA: hidUploadDATA, FILE_MIME_TYPE: hidUploadTYPE });
				};
				reader.readAsArrayBuffer(file);
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '._onFILE_Upload', error);
			this.setState({ error });
		}
	}

	public render()
	{
		const { callback } = this.props;
		const { bTruncate, bForceUTF8, MODULE_NAME, BUTTON_NAME, DETAIL_NAME, MODULE_TITLE, error } = this.state;
		if ( SplendidCache.IsInitialized && SplendidCache.AdminMenu )
		{
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			return (
			<div>
				{ !callback && headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, MODULE_TITLE, error, showRequired: true, enableHelp: true, helpName: 'EditView', ButtonStyle: 'EditHeader', VIEW_NAME: BUTTON_NAME, row: {}, Page_Command: this.Page_Command, showButtons: true, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<div id={!!callback ? null : "content"}>
					<ListHeader TITLE='Administration.LBL_IMPORT_TERMINOLOGY_TITLE' />
					<div>
						{ L10n.Term("Terminology.LBL_IMPORT_TERMINOLOGY_INSTRUCTIONS") }
					</div>
					<table className="tabForm" cellSpacing={ 1 } cellPadding={ 0 } style={ {width: '100%', border: 'none'} }>
						<tr>
							<td>
								<table style={ {width: '100%', border: 'none'} }>
									<tr>
										<td className="dataLabel">{ L10n.Term("Import.LBL_SELECT_FILE") }<span className="required">*</span></td>
										<td className="dataField">
											<input type="file" id="fileIMPORT" size={ 60 } maxLength={ 255 } tabIndex={ 2 } onChange={ (e) => this._onFILE_Upload(e) } ref={ this.fileUpload } />
										</td>
										<td className="dataLabel">&nbsp;</td>
										<td className="dataField">&nbsp;</td>
									</tr>
									<tr>
										<td className="dataLabel">{ L10n.Term("Administration.LBL_IMPORT_LANGUAGE_TRUNCATE") }</td>
										<td className="dataField">
											<span className="checkbox">
												<input id="chkTruncate" type="checkbox" checked={ bTruncate } />
											</span>
										</td>
										<td className="dataLabel">&nbsp;</td>
										<td className="dataField">&nbsp;</td>
									</tr>
									<tr>
										<td className="dataLabel">{ L10n.Term("Administration.LBL_IMPORT_FORCE_UTF8") }</td>
										<td className="dataField">
											<span className="checkbox">
												<input id="chkForceUTF8" type="checkbox" checked={ bForceUTF8 } />
											</span>
										</td>
										<td className="dataLabel">&nbsp;</td>
										<td className="dataField">&nbsp;</td>
								</tr>
								</table>
							</td>
						</tr>
					</table>
					<table cellSpacing={ 0 } cellPadding={ 0 } style={ {width: '100%', border: 'none'} }>
						<tr>
							<td align="left" >
								<input type="submit" value={ "  " + L10n.Term(".LBL_BACK_BUTTON_LABEL") + "  " } id="btnBack" title="Back" className="button" onClick={ (e) => this.Page_Command('Back', null) } />
								&nbsp;&nbsp;
								<input type="submit" value={ "  " + L10n.Term(".LBL_NEXT_BUTTON_LABEL") + "  " } id="btnNext" title="Next" className="button" onClick={ (e) => this.Page_Command('Next', null) } />
							</td>
						</tr>
					</table>
					<DetailViewRelationships key={ MODULE_NAME + '_DetailViewRelationships' } PARENT_TYPE={ MODULE_NAME } DETAIL_NAME={ DETAIL_NAME } row={ {bTruncate, bForceUTF8 } } isPrecompile={ this.props.isPrecompile } onComponentComplete={ this.onRelationshipsComplete } />
				</div>
			</div>
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

