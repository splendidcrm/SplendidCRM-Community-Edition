#region License

/*
 * Copyright (C) 2012 SplendidCRM Software, Inc. All Rights Reserved. 
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#endregion

using System;
using System.Collections.Generic;

namespace Spring.Social.Salesforce.Api
{
	/// <summary>
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class Field
	{
		public enum enumSoapType
		{
			tnsID,
			xsdbase64Binary,
			xsdboolean,
			xsddouble,
			xsdint,
			xsdstring,
			xsddate,
			xsddateTime,
			xsdtime,
			xsdanyType,
		}

		public enum enumFieldType
		{
			@string,
			picklist,
			multipicklist,
			combobox,
			reference,
			base64,
			boolean,
			currency,
			textarea,
			@int,
			@double,
			percent,
			phone,
			id,
			date,
			datetime,
			time,
			url,
			email,
			encryptedstring,
			datacategorygroupreference,
			anyType,
		}

		public bool   AutoNumber              { get; set; }
		public int    ByteLength              { get; set; }
		public bool   Calculated              { get; set; }
		public string CalculatedFormula       { get; set; }
		public bool   CaseSensitive           { get; set; }
		public string ControllerName          { get; set; }
		public bool   Createable              { get; set; }
		public bool   Custom                  { get; set; }
		public string DefaultValueFormula     { get; set; }
		public bool   DefaultedOnCreate       { get; set; }
		public bool   DependentPicklist       { get; set; }
		public bool   DeprecatedAndHidden     { get; set; }
		public int    Digits                  { get; set; }
		public bool   ExternalId              { get; set; }
		public bool   Filterable              { get; set; }
		public bool   Groupable               { get; set; }
		public bool   HtmlFormatted           { get; set; }
		public bool   IdLookup                { get; set; }
		public string InlineHelpText          { get; set; }
		public string Label                   { get; set; }
		public int    Length                  { get; set; }
		public string Name                    { get; set; }
		public bool   NamePointing            { get; set; }
		public bool   Nillable                { get; set; }
		public bool   Permissionable          { get; set; }
		public int    Precision               { get; set; }
		public string RelationshipName        { get; set; }
		public int    RelationshipOrder       { get; set; }
		public bool   RestrictedPicklist      { get; set; }
		public int    Scale                   { get; set; }
		public bool   Sortable                { get; set; }
		public bool   Unique                  { get; set; }
		public bool   Updateable              { get; set; }
		public bool   WriteRequiresMasterRead { get; set; }
		public List<string>        ReferenceTo    { get; set; }
		public List<PicklistEntry> PicklistValues { get; set; }
		public enumSoapType        SoapType       { get; set; }
		public enumFieldType       Type           { get; set; }
	}
}
