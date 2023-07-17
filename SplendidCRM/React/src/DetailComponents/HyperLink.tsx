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
import { RouteComponentProps, withRouter } from 'react-router-dom';
// 2. Store and Types. 
import { IDetailComponentProps, IDetailComponentState, DetailComponent } from '../types/DetailComponent';
// 3. Scripts. 
import Sql                                 from '../scripts/Sql'                ;
import L10n                                from '../scripts/L10n'               ;
import Credentials                         from '../scripts/Credentials'        ;
import { Crm_Modules }                     from '../scripts/Crm'                ;
import { StartsWith }                      from '../scripts/utility'            ;
// 4. Components and Views. 

interface IHyperLinkProps extends RouteComponentProps<any>
{
	baseId        : string;
	row           : any;
	layout        : any;
	ERASED_FIELDS : string[];
	Page_Command? : Function;
	fieldDidMount?: (DATA_FIELD: string, component: any) => void;
	// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
	bIsHidden?    : boolean;
}

interface IHyperLinkState
{
	ID           : string;
	FIELD_INDEX  : number;
	DATA_FIELD   : string;
	DATA_VALUE   : string;
	DATA_LABEL   : string;
	DATA_FORMAT  : string;
	URL_FORMAT   : string;
	URL_FIELD    : string;
	URL_VALUE    : string;
	MODULE_NAME  : string;
	// 11/29/2021 Paul.  When MODULE_TYPE is specified, then DISPLAY_NAME will be a lookup. 
	MODULE_TYPE  : string;
	URL          : string;
	DISPLAY_NAME : string;
	ERASED       : boolean;
	CSS_CLASS?   : string;
}

class HyperLink extends React.Component<IHyperLinkProps, IHyperLinkState>
{
	public updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void
	{
		if ( Sql.IsEmptyString(PROPERTY_NAME) || PROPERTY_NAME == 'value' )
		{
			this.setState({ DISPLAY_NAME: DATA_VALUE });
		}
		else if ( PROPERTY_NAME == 'URL' )
		{
			this.setState({ URL: DATA_VALUE });
		}
		else if ( PROPERTY_NAME == 'class' )
		{
			this.setState({ CSS_CLASS: DATA_VALUE });
		}
	}

	constructor(props: IHyperLinkProps)
	{
		super(props);
		let FIELD_INDEX      : number  = 0;
		let DATA_FIELD       : string  = '';
		let DATA_VALUE       : string  = '';
		let DATA_LABEL       : string  = '';
		let DATA_FORMAT      : string  = '';
		let URL_FORMAT       : string  = '';
		let URL_FIELD        : string  = '';
		let URL_VALUE        : string  = '';
		let MODULE_NAME      : string  = '';
		let MODULE_TYPE      : string  = '';
		let URL              : string  = '#';
		let DISPLAY_NAME     : string  = '';
		let ERASED           : boolean = false;
		let CSS_CLASS        : string  = 'tabDetailViewDFLink';

		let ID: string = null;
		try
		{
			const { baseId, layout, row } = this.props;
			if ( layout != null )
			{
				FIELD_INDEX       = Sql.ToInteger(layout.FIELD_INDEX);
				DATA_FIELD        = Sql.ToString (layout.DATA_FIELD );
				DATA_LABEL        = Sql.ToString (layout.DATA_LABEL );
				DATA_FORMAT       = Sql.ToString (layout.DATA_FORMAT);
				URL_FORMAT        = Sql.ToString (layout.URL_FORMAT );
				URL_FIELD         = Sql.ToString (layout.URL_FIELD  );
				MODULE_NAME       = Sql.ToString (layout.MODULE_NAME);
				MODULE_TYPE       = Sql.ToString (layout.MODULE_TYPE);
				// 12/24/2012 Paul.  Use regex global replace flag. 
				ID = baseId + '_' + DATA_FIELD.replace(/\s/g, '_');
				
				if ( row != null )
				{
					// 06/18/2018 Paul.  Don't convert to string here as the old code is using undefined in its checks. 
					DATA_VALUE = row[DATA_FIELD];
					URL_VALUE  = Sql.ToString(row[URL_FIELD]);
					if ( StartsWith(URL_FORMAT, 'mailto:') && !Sql.IsEmptyString(URL_VALUE) )
					{
						URL = URL_FORMAT.replace('{0}', URL_VALUE);
					}
					// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
					if ( DATA_VALUE == null && props.ERASED_FIELDS.indexOf(DATA_FIELD) >= 0 )
					{
						ERASED = true;
					}
					// 09/27/2020 Paul.  Processes.DetailView exception. 
					if ( DATA_FIELD == 'PARENT_NAME' && URL_FIELD == 'PARENT_TYPE PARENT_ID' && URL_FORMAT == '~/{0}/view.aspx?ID={1}' )
					{
						DISPLAY_NAME = Sql.ToString(row['PARENT_NAME']);
						MODULE_NAME  = Sql.ToString(row['PARENT_TYPE']);
						URL_VALUE    = Sql.ToString(row['PARENT_ID'  ]);
						URL = '/Reset/' + MODULE_NAME + '/View/' + URL_VALUE;
					}
					// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
					// 03/03/2021 Paul.  URL_FORMAT and DATA_FORMAT will not be null because of Sql.ToString() use above. 
					else if ( !ERASED && (DATA_VALUE != null || DATA_VALUE === undefined) && !Sql.IsEmptyString(URL_FORMAT) && !Sql.IsEmptyString(DATA_FORMAT) )
					{
						let a = null;
						if ( URL_FORMAT.substr(0, 2) == '~/' )
						{
							let arrURL_FORMAT   = URL_FORMAT.split('/');
							let URL_MODULE_NAME = MODULE_NAME;
							if ( arrURL_FORMAT.length > 1 )
							{
								URL_MODULE_NAME = arrURL_FORMAT[1];
								// 11/11/2020 Paul.  Correct for admin links. 
								if ( URL_MODULE_NAME == 'Administration' && arrURL_FORMAT.length > 2 )
									URL_MODULE_NAME = arrURL_FORMAT[2];
							}
							if ( URL_MODULE_NAME == 'Parents' )
							{
								URL_MODULE_NAME = row[DATA_LABEL];
							}
							MODULE_NAME     = URL_MODULE_NAME;
							// 01/30/2013 Paul.  We need to be able to execute code after loading a DetailView. 
							//oDetailViewUI.Load(sLayoutPanel, sActionsPanel, sMODULE_NAME, ID, function(status, message)
							// 04/20/2020 Paul.  Link may be to a file download. 
							// 09/27/2020 Paul.  Parents link should not be treated as a download. 
							if ( URL_MODULE_NAME == 'Parents' )
							{
								URL = '/Reset/' + URL_MODULE_NAME + '/View/' + URL_VALUE;
							}
							// 09/27/2020 Paul.  There are a number of module links that need to be converted to a React route. 
							else if ( URL_FORMAT.indexOf('/view.aspx?ID={0}') > 0 )
							{
								if ( URL_FORMAT.indexOf('ArchiveView=1') > 0 )
								{
									URL = URL_FORMAT.replace('/view.aspx?ID={0}', '/ArchiveView/' + URL_VALUE);
								}
								else
								{
									URL = URL_FORMAT.replace('/view.aspx?ID={0}', '/View/' + URL_VALUE);
								}
								// 09/28/2022 Paul.  If target is provided, then we must use anchor tag. 
								if ( !Sql.IsEmptyString(layout.URL_TARGET) )
								{
									// 07/08/2023 Paul.  ASP.NET Core will not have /React in the base. 
									URL = URL.replace('~/', Credentials.RemoteServer + Credentials.ReactBase);
								}
								else if ( URL_FORMAT.indexOf('~/Administration/') >= 0 )
								{
									URL = URL.replace('~/Administration', '/Reset/Administration');
								}
								else
								{
									URL = URL.replace('~/', '/Reset/');
								}
							}
							// 09/27/2020 Paul.  QuickBooks links. 
							else if ( URL_FORMAT.indexOf('/view.aspx?QID={0}') > 0 )
							{
								URL = URL_FORMAT.replace('/view.aspx?ID={0}', '/View/' + URL_VALUE);
							}
							else if ( URL_FORMAT.indexOf('/edit.aspx?PARENT_ID={0}') > 0 )
							{
								URL = '/Reset/' + URL_MODULE_NAME + '/Edit/?PARENT_ID=' + URL_VALUE;
							}
							else if ( URL_FORMAT.indexOf('.aspx') > 0 )
							{
								URL = URL_FORMAT.replace('~/', Credentials.RemoteServer);
								URL = URL.replace('{0}', URL_VALUE);
							}
							else
							{
								URL = '/Reset/' + URL_MODULE_NAME + '/View/' + URL_VALUE;
							}
						}
						else if ( URL_FORMAT.indexOf('view.aspx?ID={0}') > 0 )
						{
							URL = '/Reset/' + MODULE_NAME + '/View/' + URL_VALUE;
						}
						else
						{
							URL = URL_FORMAT.replace('{0}', URL_VALUE);
						}
						// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
						if ( DATA_VALUE !== undefined )
						{
							DISPLAY_NAME = DATA_FORMAT.replace('{0}', DATA_VALUE);
						}
					}
				}
			}
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor ' + DATA_FIELD, URL);
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.constructor', error);
		}
		this.state =
		{
			ID          ,
			FIELD_INDEX ,
			DATA_FIELD  ,
			DATA_VALUE  ,
			DATA_LABEL  ,
			DATA_FORMAT ,
			URL_FORMAT  ,
			URL_FIELD   ,
			URL_VALUE   ,
			MODULE_NAME ,
			MODULE_TYPE ,
			URL         ,
			DISPLAY_NAME,
			ERASED      ,
			CSS_CLASS   ,
		};
	}

	async componentDidMount()
	{
		const { row } = this.props;
		const { DATA_FIELD, DATA_VALUE, DATA_FORMAT, URL_FORMAT, URL_VALUE, MODULE_NAME, MODULE_TYPE, ERASED } = this.state;
		// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
		// 07/01/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
		if ( !ERASED && (DATA_VALUE != null || DATA_VALUE === undefined) && !Sql.IsEmptyString(URL_FORMAT) && !Sql.IsEmptyString(DATA_FORMAT) )
		{
			// 10/25/2012 Paul.  On the Surface, there are fields that we need to lookup, like ACCOUNT_NAME. 
			if ( DATA_VALUE === undefined && !Sql.IsEmptyString(URL_VALUE) )
			{
				try
				{
					let value = await Crm_Modules.ItemName(MODULE_NAME, URL_VALUE);
					let sDISPLAY_NAME: string = '';
					if ( Sql.IsEmptyString(DATA_FORMAT) )
					{
						sDISPLAY_NAME = value;
					}
					else
					{
						sDISPLAY_NAME = DATA_FORMAT.replace('{0}', value);
					}
					this.setState({ DISPLAY_NAME: sDISPLAY_NAME });
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
					// 05/20/2018 Paul.  When an error is encountered, we display the error in the name. 
					// 11/17/2021 Paul.  Must use message text and not error object. 
					this.setState({ DISPLAY_NAME: error.message });
				}
			}
			// 11/29/2021 Paul.  When MODULE_TYPE is specified, then DISPLAY_NAME will be a lookup. 
			else if ( !Sql.IsEmptyString(MODULE_TYPE) && !Sql.IsEmptyString(row[DATA_FIELD]) )
			{
				try
				{
					let value = await Crm_Modules.ItemName(MODULE_TYPE, row[DATA_FIELD]);
					let sDISPLAY_NAME: string = '';
					if ( Sql.IsEmptyString(DATA_FORMAT) )
					{
						sDISPLAY_NAME = value;
					}
					else
					{
						sDISPLAY_NAME = DATA_FORMAT.replace('{0}', value);
					}
					this.setState({ DISPLAY_NAME: sDISPLAY_NAME });
				}
				catch(error)
				{
					console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.componentDidMount', error);
					// 05/20/2018 Paul.  When an error is encountered, we display the error in the name. 
					// 11/17/2021 Paul.  Must use message text and not error object. 
					this.setState({ DISPLAY_NAME: error.message });
				}
			}
			if ( this.props.fieldDidMount )
			{
				this.props.fieldDidMount(DATA_FIELD, this);
			}
		}
	}

	shouldComponentUpdate(nextProps: IHyperLinkProps, nextState: IHyperLinkState)
	{
		const { DATA_FIELD, DATA_VALUE, DISPLAY_NAME } = this.state;
		if ( nextProps.row != this.props.row )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextProps.layout != this.props.layout )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		else if ( nextProps.bIsHidden != this.props.bIsHidden )
		{
			//console.log((new Date()).toISOString() + ' ' + 'TextBox.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.DATA_VALUE != this.state.DATA_VALUE)
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DATA_VALUE, nextProps, nextState);
			return true;
		}
		else if ( nextState.DISPLAY_NAME != this.state.DISPLAY_NAME)
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, DISPLAY_NAME, nextProps, nextState);
			return true;
		}
		else if ( nextState.CSS_CLASS != this.state.CSS_CLASS)
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldComponentUpdate ' + DATA_FIELD, CSS_CLASS, nextProps, nextState);
			return true;
		}
		return false;
	}

	private _onClick = (e) =>
	{
		const { layout, row } = this.props;
		const { URL } = this.state;
		//console.log((new Date()).toISOString() + ' ' + 'GridComponents.HyperLink ' + layout.DATA_FIELD, URL);
		//e.preventDefault();
		this.props.history.push(URL);
		return false;
	}

	public render()
	{
		const { baseId, layout, row } = this.props;
		const { ID, FIELD_INDEX, DATA_FIELD, URL, DISPLAY_NAME, ERASED, CSS_CLASS } = this.state;
		
		if ( layout == null )
		{
			return (<span>layout prop is null</span>);
		}
		else if ( Sql.IsEmptyString(DATA_FIELD) )
		{
			return (<span>DATA_FIELD is empty for HyperLink FIELD_INDEX { FIELD_INDEX }</span>);
		}
		else if ( row == null )
		{
			return (<span>row is null for HyperLink DATA_FIELD { DATA_FIELD }</span>);
		}
		// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
		else if ( layout.hidden )
		{
			return (<span></span>);
		}
		else if ( ERASED )
		{
			return (<span className="Erased">{ L10n.Term('DataPrivacy.LBL_ERASED_VALUE') }</span>);
		}
		else if ( !StartsWith(URL, '/') )
		{
			return (
				<span>
					<a id={ ID } key={ ID } href={ URL } target={ layout.URL_TARGET }>{ DISPLAY_NAME }</a>
				</span>
			);
		}
		else
		{
			// 07/09/2019 Paul.  Use span instead of a tag to prevent navigation. 
			return (
				<span id={ ID } key={ ID } onClick={ this._onClick } className={ CSS_CLASS } style={ {cursor: 'pointer'} }>{ DISPLAY_NAME }</span>
			);
		}
	}
}

export default withRouter(HyperLink);
