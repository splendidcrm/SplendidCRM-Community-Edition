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

using Spring.Json;
using Spring.Rest.Client;
using Spring.Social.OAuth2;
using Spring.Http.Converters;
using Spring.Http.Converters.Json;

using Spring.Social.Salesforce.Api.Impl.Json;

namespace Spring.Social.Salesforce.Api.Impl
{
	/// <summary>
	/// This is the central class for interacting with Salesforce.
	/// </summary>
	/// <remarks>
	/// <para>
	/// Most (not all) Salesforce operations require OAuth authentication. 
	/// To perform such operations, <see cref="SalesforceTemplate"/> must be constructed 
	/// with the minimal amount of information required to sign requests to Salesforce's API 
	/// with an OAuth <code>Authorization</code> header.
	/// </para>
	/// <para>
	/// There are some operations, such as searching, that do not require OAuth authentication. 
	/// In those cases, you may use a <see cref="SalesforceTemplate"/> that is created through 
	/// the default constructor and without any OAuth details.
	/// Attempts to perform secured operations through such an instance, however, 
	/// will result in <see cref="SalesforceApiException"/> being thrown.
	/// </para>
	/// </remarks>
	/// <author>SplendidCRM (.NET)</author>
	public class SalesforceTemplate : SalesforceOAuth2ApiBinding, ISalesforce 
	{
		private IVersionOperations   versionOperations ;
		private IMetadataOperations  metadataOperations;
		private ISObjectOperations   sobjectOperations ;
		private ISearchOperations    searchOperations  ;
		private IUserOperations      userOperations    ;

		/// <summary>
		/// Create a new instance of <see cref="SalesforceTemplate"/>.
		/// </summary>
		/// <param name="instanceURL"></param>
		/// <param name="accessToken">An access token acquired through OAuth authentication with Salesforce.</param>
		public SalesforceTemplate(string instanceURL, string accessToken) : base(instanceURL, accessToken)
		{
			this.InitSubApis();
		}

		#region ISalesforce Members
		public IVersionOperations  VersionOperations  { get { return this.versionOperations ; } }
		public IMetadataOperations MetadataOperations { get { return this.metadataOperations; } }
		public ISObjectOperations  SObjectOperations  { get { return this.sobjectOperations ; } }
		public ISearchOperations   SearchOperations   { get { return this.searchOperations  ; } }
		public IUserOperations     UserOperations     { get { return this.userOperations    ; } }

		/// <summary>
		/// Gets the underlying <see cref="IRestOperations"/> object allowing for consumption of Twitter endpoints 
		/// that may not be otherwise covered by the API binding. 
		/// </summary>
		/// <remarks>
		/// The <see cref="IRestOperations"/> object returned is configured to include an OAuth "Authorization" header on all requests.
		/// </remarks>
		public IRestOperations RestOperations
		{
			get { return this.RestTemplate; }
		}
		#endregion

		/// <summary>
		/// Enables customization of the <see cref="RestTemplate"/> used to consume provider API resources.
		/// </summary>
		/// <remarks>
		/// An example use case might be to configure a custom error handler. 
		/// Note that this method is called after the RestTemplate has been configured with the message converters returned from GetMessageConverters().
		/// </remarks>
		/// <param name="restTemplate">The RestTemplate to configure.</param>
		protected override void ConfigureRestTemplate(RestTemplate restTemplate)
		{
			restTemplate.ErrorHandler = new SalesforceErrorHandler();
		}

		protected override OAuth2Version GetOAuth2Version()
		{
			return OAuth2Version.Draft10;
		}

		/// <summary>
		/// Returns a list of <see cref="IHttpMessageConverter"/>s to be used by the internal <see cref="RestTemplate"/>.
		/// </summary>
		/// <remarks>
		/// This implementation adds <see cref="SpringJsonHttpMessageConverter"/> and <see cref="ByteArrayHttpMessageConverter"/> to the default list.
		/// </remarks>
		/// <returns>
		/// The list of <see cref="IHttpMessageConverter"/>s to be used by the internal <see cref="RestTemplate"/>.
		/// </returns>
		protected override IList<IHttpMessageConverter> GetMessageConverters()
		{
			IList<IHttpMessageConverter> converters = base.GetMessageConverters();
			converters.Add(new ByteArrayHttpMessageConverter());
			converters.Add(this.GetJsonMessageConverter());
			return converters;
		}

		/// <summary>
		/// Returns a <see cref="SpringJsonHttpMessageConverter"/> to be used by the internal <see cref="RestTemplate"/>.
		/// <para/>
		/// Override to customize the message converter (for example, to set a custom object mapper or supported media types).
		/// </summary>
		/// <returns>The configured <see cref="SpringJsonHttpMessageConverter"/>.</returns>
		protected virtual SpringJsonHttpMessageConverter GetJsonMessageConverter()
		{
			JsonMapper jsonMapper = new JsonMapper();
			jsonMapper.RegisterDeserializer(typeof(SalesforceVersion          ), new SalesforceVersionDeserializer          ());
			jsonMapper.RegisterDeserializer(typeof(List<SalesforceVersion>    ), new ListDeserializer<SalesforceVersion>    ());
			jsonMapper.RegisterDeserializer(typeof(SalesforceResources        ), new SalesforceResourcesDeserializer        ());
			jsonMapper.RegisterDeserializer(typeof(DescribeGlobal             ), new DescribeGlobalDeserializer             ());
			jsonMapper.RegisterDeserializer(typeof(DescribeGlobalSObject      ), new DescribeGlobalSObjectDeserializer      ());
			jsonMapper.RegisterDeserializer(typeof(List<DescribeGlobalSObject>), new ListDeserializer<DescribeGlobalSObject>());
			jsonMapper.RegisterDeserializer(typeof(DescribeSObject            ), new DescribeSObjectDeserializer            ());
			jsonMapper.RegisterDeserializer(typeof(Field                      ), new FieldDeserializer                      ());
			jsonMapper.RegisterDeserializer(typeof(List<Field>                ), new ListDeserializer<Field>                ());
			jsonMapper.RegisterDeserializer(typeof(RecordTypeInfo             ), new RecordTypeInfoDeserializer             ());
			jsonMapper.RegisterDeserializer(typeof(List<RecordTypeInfo>       ), new ListDeserializer<RecordTypeInfo>       ());
			jsonMapper.RegisterDeserializer(typeof(ChildRelationship          ), new ChildRelationshipDeserializer          ());
			jsonMapper.RegisterDeserializer(typeof(List<ChildRelationship>    ), new ListDeserializer<ChildRelationship>    ());
			jsonMapper.RegisterDeserializer(typeof(PicklistEntry              ), new PicklistEntryDeserializer              ());
			jsonMapper.RegisterDeserializer(typeof(List<PicklistEntry>        ), new ListDeserializer<PicklistEntry>        ());
			jsonMapper.RegisterDeserializer(typeof(String                     ), new StringDeserializer                     ());
			jsonMapper.RegisterDeserializer(typeof(List<String>               ), new ListDeserializer<String>               ());
			jsonMapper.RegisterDeserializer(typeof(byte[]                     ), new ByteArrayDeserializer                  ());
			jsonMapper.RegisterDeserializer(typeof(BasicSObject               ), new BasicSObjectDeserializer               ());
			jsonMapper.RegisterDeserializer(typeof(List<BasicSObject>         ), new ListDeserializer<BasicSObject>         ());
			jsonMapper.RegisterDeserializer(typeof(RecentItem                 ), new RecentItemDeserializer                 ());
			jsonMapper.RegisterDeserializer(typeof(List<RecentItem>           ), new ListDeserializer<RecentItem>           ());
			jsonMapper.RegisterDeserializer(typeof(SObject                    ), new SObjectDeserializer                    ());
			jsonMapper.RegisterDeserializer(typeof(List<SObject>              ), new ListDeserializer<SObject>              ());
			jsonMapper.RegisterDeserializer(typeof(Attributes                 ), new AttributesDeserializer                 ());
			jsonMapper.RegisterDeserializer(typeof(QueryResult                ), new QueryResultDeserializer                ());
			return new SpringJsonHttpMessageConverter(jsonMapper);
		}

		private void InitSubApis()
		{
			this.versionOperations  = new VersionTemplate (this.RestTemplate, this.IsAuthorized);
			this.metadataOperations = new MetadataTemplate(this.RestTemplate, this.IsAuthorized);
			this.sobjectOperations  = new SObjectTemplate (this.RestTemplate, this.IsAuthorized);
			this.searchOperations   = new SearchTemplate  (this.RestTemplate, this.IsAuthorized);
			this.userOperations     = new UserTemplate    (this.RestTemplate, this.IsAuthorized);
		}
	}
}