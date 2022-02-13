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

export interface IEditComponentProps
{
	baseId                        : string;
	key?                          : string;
	row                           : any;
	layout                        : any;
	onChanged?                    : (DATA_FIELD: string, DATA_VALUE: any, DISPLAY_FIELD?: string, DISPLAY_VALUE?: any) => void;
	onSubmit?                     : () => void;
	onUpdate?                     : (PARENT_FIELD: string, DATA_VALUE: any, item?: any) => void;
	createDependency?             : (DATA_FIELD: string, PARENT_FIELD: string, PROPERTY_NAME?: string) => void;
	fieldDidMount?                : (DATA_FIELD: string, component: any) => void;
	bIsWriteable?                 : boolean;
	// 11/02/2019 Paul.  Hidden property is used to dynamically hide and show layout fields. 
	bIsHidden?                    : boolean;
	// 11/04/2019 Paul.  Some layouts have a test button next to a URL. 
	Page_Command?                 : Function;
	// 09/27/2020 Paul.  We need to be able to disable the default grow on TextBox. 
	bDisableFlexGrow?             : boolean;
}

export abstract class EditComponent<P extends IEditComponentProps, S> extends React.Component<P, S>
{
	public abstract get data(): any;
	public abstract validate(): boolean;
	public abstract updateDependancy(PARENT_FIELD: string, DATA_VALUE: any, PROPERTY_NAME?: string, item?: any): void;
	public abstract clear(): void;
}

