/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

import * as React from 'react';
import { RouteComponentProps } from 'react-router-dom';

export interface IDetailViewProps extends RouteComponentProps<any>
{
	MODULE_NAME  : string;
	ID           : string;
	LAYOUT_NAME? : string;
	// 04/10/2021 Paul.  Create framework to allow pre-compile of all modules. 
	isPrecompile?       : boolean;
	onComponentComplete?: (MODULE_NAME, RELATED_MODULE, LAYOUT_NAME, vwMain) => void;
}

export interface IDetailComponentProps
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

export interface IDetailComponentState
{
	ID          : string;
	FIELD_INDEX : number;
	DATA_FIELD? : string;
	DATA_VALUE? : string;
	DATA_FORMAT?: string;
	CSS_CLASS?  : string;
}

export abstract class DetailComponent<P extends IDetailComponentProps, S> extends React.Component<P, S>
{
	public abstract updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void;
}

