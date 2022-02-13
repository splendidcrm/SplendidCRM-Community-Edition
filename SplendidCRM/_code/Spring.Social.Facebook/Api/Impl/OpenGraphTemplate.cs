#region License

/*
 * Copyright 2011-2012 the original author or authors.
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
using System.Net;
using System.Collections.Generic;
using System.Collections.Specialized;

using Spring.Http;
using Spring.Rest.Client;

namespace Spring.Social.Facebook.Api.Impl
{
	/// <summary>
	/// </summary>
	/// <author>SplendidCRM (.NET)</author>
	class OpenGraphTemplate : AbstractFacebookOperations, IOpenGraphOperations
	{
		public OpenGraphTemplate(string applicationNamespace, RestTemplate restTemplate, bool isAuthorized)
			: base(applicationNamespace, restTemplate, isAuthorized)
		{
		}

		#region IOpenGraphOperations Members
		public string PublishAction(string action, string objectType, string objectUrl)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Set(objectType, objectUrl);
			return this.Publish("me", this.applicationNamespace + ":" + action, parameters);
		}

		private void requireApplicationNamespace()
		{
			if ( applicationNamespace == null || String.IsNullOrEmpty(applicationNamespace) )
			{
				throw new Exception("MissingNamespaceException");  // MissingNamespaceException();
			}
		}
		#endregion
	}
}