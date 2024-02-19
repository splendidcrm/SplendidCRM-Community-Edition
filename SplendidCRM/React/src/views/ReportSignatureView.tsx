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
import { RouteComponentProps, withRouter }            from '../Router5'                     ;
import { observer }                                   from 'mobx-react'                           ;
import { FontAwesomeIcon }                            from '@fortawesome/react-fontawesome'       ;
// https://www.npmjs.com/package/react-signature-canvas
import SignatureCanvas                                from 'react-signature-canvas'               ;
// 2. Store and Types. 
import { HeaderButtons }                              from '../types/HeaderButtons'               ;
// 3. Scripts. 
import Sql                                            from '../scripts/Sql'                       ;
import L10n                                           from '../scripts/L10n'                      ;
import Credentials                                    from '../scripts/Credentials'               ;
import SplendidCache                                  from '../scripts/SplendidCache'             ;
import { AuthenticatedMethod, LoginRedirect }         from '../scripts/Login'                     ;
import { DetailView_LoadItem }                        from '../scripts/DetailView'                ;
import { DeleteModuleItem }                           from '../scripts/ModuleUpdate'              ;
import { CreateSplendidRequest, GetSplendidResult }   from '../scripts/SplendidRequest'           ;
import { jsonReactState }                             from '../scripts/Application'               ;
import withScreenSizeHook                             from '../scripts/ScreenSizeHook'            ;
// 4. Components and Views. 
import ErrorComponent                                 from '../components/ErrorComponent'         ;
import DumpSQL                                        from '../components/DumpSQL'                ;
import HeaderButtonsFactory                           from '../ThemeComponents/HeaderButtonsFactory';

let MODULE_NAME: string = 'Reports';

interface IReportSignatureViewProps extends RouteComponentProps<any>
{
	ID?           : string;
	NAME?         : string;
	PARENT_NAME?  : string;
	PARENT_ID?    : string;
	ReportDesign? : any;
	screenSize    : any;
}

interface IReportSignatureViewState
{
	__sql           : string;
	item            : any;
	SUB_TITLE       : any;
	error           : any;
}

@observer
class ReportSignatureView extends React.Component<IReportSignatureViewProps, IReportSignatureViewState>
{
	private _isMounted     : boolean = false;
	private headerButtons  = React.createRef<HeaderButtons>();
	private sigCanvas      = React.createRef<SignatureCanvas>();

	constructor(props: IReportSignatureViewProps)
	{
		super(props);
		this.state =
		{
			__sql           : null,
			item            : null,
			SUB_TITLE       : null,
			error           : null,
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

	async componentDidUpdate(prevProps: IReportSignatureViewProps)
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
				let item: any = d.results;
				// 11/23/2020 Paul.  Update document title. 
				Sql.SetPageTitle(MODULE_NAME, item, 'NAME');
				let SUB_TITLE: any = Sql.DataPrivacyErasedField(item, 'NAME');
				this.setState({ item, SUB_TITLE, __sql: d.__sql });
				// 04/29/2019 Paul.  Manually add to the list so that we do not need to request an update. 
				if ( item != null )
				{
					let sNAME = Sql.ToString(item['NAME']);
					if ( !Sql.IsEmptyString(sNAME) )
					{
						SplendidCache.AddLastViewed(MODULE_NAME, ID, sNAME);
					}
				}
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.load', error);
			this.setState({ error });
		}
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
				if ( this.sigCanvas.current != null )
				{
					if ( this.sigCanvas.current.isEmpty() )
					{
						this.setState({ error: L10n.Term('Orders.ERR_SIGNATURE_NOT_PROVIDED') } );
						return;
					}
					else
					{
						try
						{
							this.setState({ error: '' });
							// https://www.npmjs.com/package/react-signature-canvas
							//let canvas: any = this.sigCanvas.current.getCanvas();
							let canvas: any = this.sigCanvas.current.getTrimmedCanvas();
							let data: any = this.sigCanvas.current.toData();
							let obj: any =
							{
								lines        : [], 
								width        : canvas.width,
								height       : canvas.height,
								REPORT_ID    : this.props.ID,
								PARENT_NAME  : this.props.PARENT_NAME,
								PARENT_ID    : this.props.PARENT_ID,
							};
							let minX: number = 100;
							let minY: number = 100;
							let maxX: number = 100;
							let maxY: number = 100;
							for ( let i: number = 0; i < data.length; i++ )
							{
								let oldSegment: any = data[i];
								let newSegment: any = [];
								for ( let j: number = 0; j < oldSegment.length; j++ )
								{
									let newLine: any = [];
									newLine.push(oldSegment[j].x);
									newLine.push(oldSegment[j].y);
									minX = Math.min(minX, oldSegment[j].x);
									minY = Math.min(minY, oldSegment[j].y);
									maxX = Math.max(maxX, oldSegment[j].x);
									maxY = Math.max(maxY, oldSegment[j].y);
									newSegment.push(newLine);
								}
								obj.lines.push(newSegment);
							}
							obj.width  = maxX + minX;
							obj.height = maxY + minY;

							let sBody: string = JSON.stringify(obj);
							let sUrl : string = 'ReportDesigner/Rest.svc/SubmitSignature';
							let res = await CreateSplendidRequest(sUrl, 'POST', 'application/octet-stream', sBody);
							let json = await GetSplendidResult(res);
							
							//history.back();
							//this.setState({ error: 'Saved' });
							history.push('/Reset/' + this.props.PARENT_NAME + '/View/' + this.props.PARENT_ID);
						}
						catch(error)
						{
							this.setState({ error });
						}
					}
				}
				else
				{
					this.setState({ error: 'Canvas is not mounted' });
				}
				break;
			}
			case 'Clear':
			{
				if ( this.sigCanvas.current != null )
				{
					this.sigCanvas.current.clear();
				}
				break;
			}
			case 'Cancel':
			{
				// 01/15/2024 Paul.  Updated history package. 
				history.back();
				break;
			}
			default:
			{
				if ( this._isMounted )
				{
					this.setState({ error: sCommandName + ' is not supported at this time' });
				}
				break;
			}
		}
	}

	private _onButtonsLoaded = async () =>
	{
	}

	public render()
	{
		const { ID, ReportDesign, screenSize } = this.props;
		const { item, SUB_TITLE, error } = this.state;
		const { __sql } = this.state;
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render screenSize', screenSize);
		// 05/04/2019 Paul.  Reference obserable IsInitialized so that terminology update will cause refresh. 
		// 05/15/2018 Paul.  Defer process button logic. 
		// 06/26/2019 Paul.  Specify a key so that SplendidGrid will get componentDidMount when changing views. 
		if ( SplendidCache.IsInitialized && (item || ReportDesign) )
		{
			// 12/04/2019 Paul.  After authentication, we need to make sure that the app gets updated. 
			Credentials.sUSER_THEME;
			let headerButtons = HeaderButtonsFactory(SplendidCache.UserTheme);
			let height     : number = screenSize.height - 280;
			let panelWidth : number = screenSize.width  - 300;
			let VIEW_NAME  : string = null;
			let sSCRIPT_URL: string = Credentials.RemoteServer + 'Reports/view_embedded.aspx';
			if ( !Sql.IsEmptyGuid(ID) )
			{
				VIEW_NAME = 'Reports.SignatureView';
				sSCRIPT_URL += '?ID=' + ID;
				if ( !Sql.IsEmptyString(this.props.location.search) )
				{
					sSCRIPT_URL += '&' + this.props.location.search.substr(1);
				}
			}
			else
			{
				height = screenSize.height - 220;
				sSCRIPT_URL += '?ReportDesign=' + encodeURIComponent(ReportDesign);
			}
			return (
			<React.Fragment>
				{ headerButtons
				? React.createElement(headerButtons, { MODULE_NAME, ID, SUB_TITLE, hideTitle: Sql.IsEmptyGuid(ID), enableFavorites: !Sql.IsEmptyGuid(ID), error, enableHelp: !Sql.IsEmptyGuid(ID), helpName: 'DetailView', ButtonStyle: 'ModuleHeader', VIEW_NAME, row: item, Page_Command: this.Page_Command, showButtons: !Sql.IsEmptyGuid(ID), showProcess: false, onLayoutLoaded: this._onButtonsLoaded, history: this.props.history, location: this.props.location, match: this.props.match, ref: this.headerButtons })
				: null
				}
				<div style={ {border: '1px solid black'} }>
					<SignatureCanvas
						id='divSignaturePanel'
						canvasProps={ {width: panelWidth, height: '100'} }
						clearOnResize={ false }
						ref={ this.sigCanvas }
					/>
				</div>
				<DumpSQL SQL={ __sql } />
				<div style={ {display: 'flex', flexGrow: 1} }>
					<iframe src={ sSCRIPT_URL } className="embed-responsive-item" width="100%" height={ height.toString() + 'px'}></iframe>
				</div>
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

// 02/04/2024 Paul.  Prepare for v18 by swapping order. 
export default withScreenSizeHook(withRouter(ReportSignatureView));
