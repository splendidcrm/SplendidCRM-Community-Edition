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
import posed from 'react-pose';
import { FontAwesomeIcon }                   from '@fortawesome/react-fontawesome' ;
// 2. Store and Types. 
// 3. Scripts. 
import L10n                                  from '../../scripts/L10n'             ;
import Sql                                   from '../../scripts/Sql'              ;
import Credentials                           from '../../scripts/Credentials'      ;
import SplendidCache                         from '../../scripts/SplendidCache'    ;
import { Crm_Config, Crm_Modules }           from '../../scripts/Crm'              ;
import { isMobileDevice, isMobileLandscape, screenWidth, screenHeight } from '../../scripts/utility'          ;
// 4. Components and Views. 
import DynamicButtons                        from '../../components/DynamicButtons';
import { ISubPanelHeaderButtonsProps, SubPanelHeaderButtons} from '../../types/SubPanelHeaderButtons';

const Toggle = posed.i(
{
	pressable: true,
	open:
	{
		rotate: '180deg',
	},
	closed:
	{
		rotate: '0deg'
	}
});

export default class ArcticSubPanelHeaderButtons extends SubPanelHeaderButtons
{
	private dynamicButtons = React.createRef<DynamicButtons>();

	constructor(props: ISubPanelHeaderButtonsProps)
	{
		super(props);
		let nACLACCESS_Help: number = SplendidCache.GetUserAccess("Help", 'edit');
		let helpText       : string = (nACLACCESS_Help >= 0 && Crm_Config.ToBoolean('enable_help_wiki') ? L10n.Term('.LNK_HELP_WIKI') : L10n.Term('.LNK_HELP') );
		let streamEnabled  : boolean = Crm_Modules.StreamEnabled(props.MODULE_NAME);
		let archiveView    : boolean = false;
		// 11/10/2020 Paul.  A customer wants to be able to have subpanels default to open. 
		let rawOpen        : string  = localStorage.getItem(props.CONTROL_VIEW_NAME);
		// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
		let open           : boolean = (rawOpen == 'true' || this.props.isPrecompile);
		if ( rawOpen == null && Crm_Config.ToBoolean('default_subpanel_open') )
		{
			open = true;
		}

		if ( props.location != undefined && props.location.pathname.indexOf('/ArchiveView') >= 0 )
		{
			archiveView = true;
		}
		this.state =
		{
			helpText     ,
			archiveView  ,
			streamEnabled,
			headerError  : null,
			localKey     : '',
			open         ,
		};
	}

	public Busy = (): void =>
	{
		if ( this.dynamicButtons.current != null )
		{
			this.dynamicButtons.current.Busy();
		}
	}

	public NotBusy = (): void =>
	{
		if ( this.dynamicButtons.current != null )
		{
			this.dynamicButtons.current.NotBusy();
		}
	}

	public DisableAll = (): void =>
	{
		if ( this.dynamicButtons.current != null )
		{
			this.dynamicButtons.current.DisableAll();
		}
	}

	public EnableAll = (): void =>
	{
		if ( this.dynamicButtons.current != null )
		{
			this.dynamicButtons.current.EnableAll();
		}
	}

	public HideAll = (): void =>
	{
		if ( this.dynamicButtons.current != null )
		{
			this.dynamicButtons.current.HideAll();
		}
	}

	public ShowAll = (): void =>
	{
		if ( this.dynamicButtons.current != null )
		{
			this.dynamicButtons.current.ShowAll();
		}
	}

	public EnableButton = (COMMAND_NAME: string, enabled: boolean): void =>
	{
		if ( this.dynamicButtons.current != null )
		{
			this.dynamicButtons.current.EnableButton(COMMAND_NAME, enabled);
		}
	}

	public ShowButton = (COMMAND_NAME: string, visible: boolean): void =>
	{
		if ( this.dynamicButtons.current != null )
		{
			this.dynamicButtons.current.ShowButton(COMMAND_NAME, visible);
		}
	}

	public ShowHyperLink = (URL: string, visible: boolean): void =>
	{
		if ( this.dynamicButtons.current != null )
		{
			this.dynamicButtons.current.ShowHyperLink(URL, visible);
		}
	}

	private toggle = () =>
	{
		this.setState({ open: !this.state.open }, () =>
		{
			if ( this.props.onToggle )
			{
				this.props.onToggle(this.state.open);
			}
		});
	}

	public render()
	{
		const { MODULE_NAME, MODULE_TITLE, SUB_TITLE, ID, error } = this.props;
		const { ButtonStyle, FrameStyle, ContentStyle, VIEW_NAME, LINK_NAME, row, Page_Command, onLayoutLoaded, showButtons } = this.props;
		const { helpText, archiveView, streamEnabled, localKey, headerError, open } = this.state;
		
		let sMODULE_TITLE: string = !Sql.IsEmptyString(MODULE_TITLE) ? L10n.Term(MODULE_TITLE) : L10n.Term('.moduleList.' + MODULE_NAME);
		let themeURL     : string = Credentials.RemoteServer + 'App_Themes/' + SplendidCache.UserTheme + '/';
		let sError       : string = null;
		if ( error !== undefined && error != null )
		{
			if ( error.message !== undefined )
			{
				sError = error.message;
			}
			else if ( typeof(error) == 'string' )
			{
				sError = error;
			}
			else if ( typeof(error) == 'object' )
			{
				sError = JSON.stringify(error);
			}
		}
		else if ( headerError !== undefined && headerError != null )
		{
			if ( headerError.message !== undefined )
			{
				sError = headerError.message;
			}
			else if ( typeof(headerError) == 'string' )
			{
				sError = headerError;
			}
			else if ( typeof(headerError) == 'object' )
			{
				sError = JSON.stringify(headerError);
			}
		}
		// 04/28/2019 Paul.  Can't use react-bootstrap Breadcrumb as it will reload the app is is therefore slow. 
		// 07/09/2019 Paul.  Use span instead of a tag to prevent navigation. 
		// 04/19/2021 Paul.  Manually calculate responsive features. 
		let bResponsive : boolean = false;
		let width : number = screenWidth();
		let height: number = screenHeight();
		if ( width < 992 )
			bResponsive = true;
		return (
			<React.Fragment>
				<div id={ 'divModuleHeader' + MODULE_NAME }>
					<table className={ !open ? 'h3Row h3RowDisabled' : 'h3Row' } cellPadding={ 0 } cellSpacing={ 1 } style={ {width: '100%'} }>
						<tr>
							<td style={ {width: '99%'} }>
								<h3><span style={ {paddingLeft: '10px'} }>{ sMODULE_TITLE }</span></h3>
							</td>
							<td style={ {verticalAlign: 'center', textAlign: 'left', paddingTop: 3, paddingLeft: 5, paddingRight: 15, width: '30px'} }>
								<Toggle onClick={ this.toggle } pose={ open ? 'open' : 'closed' } style={ {marginRight: '0.5em', cursor: 'pointer'} }>
									<FontAwesomeIcon icon={ open ? 'minus' : 'plus' } size='lg' color='white' />
								</Toggle>
							</td>
						</tr>
					</table>
					{ open && bResponsive
					? <React.Fragment>
						{ showButtons 
						? <DynamicButtons
							ButtonStyle={ ButtonStyle }
							FrameStyle={ FrameStyle }
							ContentStyle={ ContentStyle }
							VIEW_NAME={ VIEW_NAME }
							row={ row }
							Page_Command={ Page_Command }
							onLayoutLoaded={ onLayoutLoaded }
							history={ this.props.history }
							location={ this.props.location }
							match={ this.props.match }
							ref={ this.dynamicButtons }
							/>
						: null
						}
						{ !Sql.IsEmptyString(sError)
						? <div className='error'>{ sError }</div>
						: null
						}
					</React.Fragment>
					: null
					}
					{ open && !bResponsive
					? <table cellPadding={ 0 } cellSpacing={ 1 } style={ {width: '100%', paddingBottom: 2} }>
						<tr>
							<td style={ {width: '10%', whiteSpace: 'nowrap'} }>
								{ showButtons 
								? <DynamicButtons
									ButtonStyle={ ButtonStyle }
									FrameStyle={ FrameStyle }
									ContentStyle={ ContentStyle }
									VIEW_NAME={ VIEW_NAME }
									row={ row }
									Page_Command={ Page_Command }
									onLayoutLoaded={ onLayoutLoaded }
									history={ this.props.history }
									location={ this.props.location }
									match={ this.props.match }
									ref={ this.dynamicButtons }
									/>
								: null
								}
							</td>
							<td style={ {width: '90%'} }>
								{ !Sql.IsEmptyString(sError)
								? <span className='error'>{ sError }</span>
								: null
								}
							</td>
						</tr>
					</table>
					: null
					}
				</div>
			</React.Fragment>
		);
	}
}

// 12/05/2019 Paul.  We don't want to use withRouter() as it makes it difficult to get a reference. 

