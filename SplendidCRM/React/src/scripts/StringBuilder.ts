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
// 2. Store and Types. 
// 3. Scripts. 

const ControlChars = { CrLf: '\r\n', Cr: '\r', Lf: '\n', Tab: '\t' };

export default class StringBuilder
{
	private value : string;
	public  length: number;

	constructor()
	{
		this.value  = '';
		this.length = this.value.length;
	}

	public Append(s: string)
	{
		this.value  = this.value + s;
		this.length = this.value.length;
	}

	public AppendLine(s?: string)
	{
		if ( s === undefined )
		{
			this.value  = this.value + ControlChars;
			this.length = this.value.length;
		}
		else
		{
			this.value  = this.value + s;
			this.length = this.value.length;
		}
	}

	public toString()
	{
		return this.value;
	}
}

