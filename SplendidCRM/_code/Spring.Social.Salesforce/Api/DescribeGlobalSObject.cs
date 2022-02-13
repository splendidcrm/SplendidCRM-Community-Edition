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

namespace Spring.Social.Salesforce.Api
{
	/// <summary>
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class DescribeGlobalSObject
	{
		public string Name                { get; set; }
		public string Label               { get; set; }
		public bool   Updateable          { get; set; }
		public string KeyPrefix           { get; set; }
		public bool   Custom              { get; set; }
		public bool   Searchable          { get; set; }
		public string LabelPlural         { get; set; }
		public bool   Layoutable          { get; set; }
		public bool   Activateable        { get; set; }
		public bool   Createable          { get; set; }
		public bool   DeprecatedAndHidden { get; set; }
		public bool   Deletable           { get; set; }
		public bool   CustomSetting       { get; set; }
		public bool   FeedEnabled         { get; set; }
		public bool   Mergeable           { get; set; }
		public bool   Queryable           { get; set; }
		public bool   Retrieveable        { get; set; }
		public bool   Replicateable       { get; set; }
		public bool   Undeletable         { get; set; }
		public bool   Triggerable         { get; set; }
		public string UrlSObject          { get; set; }
		public string UrlDescribe         { get; set; }
		public string UrlRowTemplate      { get; set; }
	}
}
