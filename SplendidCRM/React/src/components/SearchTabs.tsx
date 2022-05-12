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
import * as React          from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
// 2. Store and Types. 
// 3. Scripts. 
import L10n                from '../scripts/L10n'                ;
import SplendidCache       from '../scripts/SplendidCache'       ;
// 4. Components and Views. 

interface ISearchTabsProps
{
	searchMode            : string;
	duplicateSearchEnabled: boolean;
	onTabChange           : Function;
}

export default class SearchTabs extends React.Component<ISearchTabsProps>
{
	constructor(props: ISearchTabsProps)
	{
		super(props);
	}

	private _onSearchTabChange = (key) =>
	{
		const { onTabChange } = this.props;
		if ( onTabChange != null )
		{
			onTabChange(key);
		}
		return false;
	}

	public render()
	{
		const { searchMode, duplicateSearchEnabled } = this.props;
		// 04/09/2022 Paul.  Hide/show SearchView. 
		if ( SplendidCache.UserTheme == 'Pacific' )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.render', searchMode);
			return (
			<div style={{ display: 'flex', flexDirection: 'row', marginBottom: '4px' }}>
				<div className={ 'SearchTabButton' }>
					<button onClick={ (e) => this._onSearchTabChange('Hide') }>
						<FontAwesomeIcon icon='xmark' size='lg' />
					</button>
				</div>
				<div className={ 'SearchTabButton' + (searchMode == 'Basic' ? ' SearchTabButtonActive' : '') }>
					<button onClick={ (e) => this._onSearchTabChange('Basic') }>{ L10n.Term('.LNK_BASIC_SEARCH') }</button>
				</div>
				<div className={ 'SearchTabButton' + (searchMode == 'Advanced' ? ' SearchTabButtonActive' : '') }>
					<button onClick={ (e) => this._onSearchTabChange('Advanced') }>{ L10n.Term('.LNK_ADVANCED_SEARCH') }</button>
				</div>
				{ duplicateSearchEnabled
					? <div className={ 'SearchTabButton' + (searchMode == 'Duplicates' ? ' SearchTabButtonActive' : '') }>
					<button onClick={ (e) => this._onSearchTabChange('Duplicates') }>{ L10n.Term('.LNK_DUPLICATE_SEARCH') }</button>
				</div>
				: null
				}
			</div>);
		}
		else
		{
			return (
				<ul id='pnlSearchTabs' className='tablist' onSelect={ this._onSearchTabChange }>
					<li>
						<a id='lnkBasicSearch' onClick={ (e) => { e.preventDefault(); return this._onSearchTabChange('Basic'); } } href='#' className={ searchMode == 'Basic' ? 'current' : null }>{ L10n.Term('.LNK_BASIC_SEARCH') }</a>
					</li>
					<li>
						<a id='lnkAdvancedSearch' onClick={ (e) => { e.preventDefault(); return this._onSearchTabChange('Advanced'); } } href='#' className={ searchMode == 'Advanced' ? 'current' : null }>{ L10n.Term('.LNK_ADVANCED_SEARCH') }</a>
					</li>
					{ duplicateSearchEnabled
					? <li>
						<a id='lnkDuplicateSearch' onClick={ (e) => { e.preventDefault(); return this._onSearchTabChange('Duplicates'); } } href='#' className={ searchMode == 'Duplicates' ? 'current' : null }>{ L10n.Term('.LNK_DUPLICATE_SEARCH') }</a>
					</li>
					: null
					}
				</ul>
			);
		}
	}
}

