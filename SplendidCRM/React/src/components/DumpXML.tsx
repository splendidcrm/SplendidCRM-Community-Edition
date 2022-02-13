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
// 2. Store and Types. 
// 3. Scripts. 
import Sql        from '../scripts/Sql';
// 4. Components and Views. 

interface IDumpXMLProps
{
	XML       : string;
	default_xml: boolean;
}

interface IDumpXMLState
{
	expand_xml: boolean;
}

export default class DumpXML extends React.Component<IDumpXMLProps, IDumpXMLState>
{
	constructor(props: IDumpXMLProps)
	{
		super(props);
		this.state =
		{
			expand_xml: props.default_xml,
		};
	}

	private onToggleXml = () =>
	{
		this.setState({ expand_xml: !this.state.expand_xml });
	}

	private HtmlEncode = (s) =>
	{
		return s.replace(/&/g, '&amp;')
		.replace(/</g, '&lt;')
		.replace(/>/g, '&gt;')
		.replace(/'/g, '&#39;')
		.replace(/"/g, '&#34;');
	}

	public render()
	{
		const { expand_xml } = this.state;
		let sXML: string = Sql.ToString(this.props.XML);
		sXML = this.HtmlEncode(sXML);
		sXML = sXML.replace(/\n/g, '<br />\n');
		sXML = sXML.replace(/\t/g, '&nbsp;&nbsp;&nbsp;');
		let cssSql: any = { height: '2em', cursor: 'pointer', marginBottom: 0, overflowX: 'hidden', width: '100%', border: '1px solid black', fontFamily: 'courier new', padding: '1px' };
		if ( expand_xml )
		{
			cssSql = { cursor: 'pointer', marginBottom: 0, width: '100%', border: '1px solid black', fontFamily: 'courier new', padding: '1px' };
		}
		return (<div style={ cssSql } onClick={ this.onToggleXml } >
			<div dangerouslySetInnerHTML={ { __html: sXML } }></div>
		</div>);
	}
}

