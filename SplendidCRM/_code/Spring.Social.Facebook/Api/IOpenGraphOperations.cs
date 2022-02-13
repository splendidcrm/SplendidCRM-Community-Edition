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
using System.IO;
using System.Collections.Generic;
using Spring.Rest.Client;
using Spring.Http;

namespace Spring.Social.Facebook.Api
{
	/// <summary>
	/// Defines operations for working with Facebook OpenGraph actions.
	/// </summary>
	/// <author>Craig Walls</author>
	/// <author>SplendidCRM (.NET)</author>
	public interface IOpenGraphOperations
	{
		/// <summary>
		/// Posts an action for an object specified by the given object URL.
		/// </summary>
		/// <param name="action">The application specific action to post, without the application's namespace. (eg, "drink")</param>
		/// <param name="objectType">The application specific object type, without the application's namespace. (eg, "beverage")</param>
		/// <param name="objectUrl">The URL of the object that is the target of the action.</param>
		/// <returns>the ID of the posted action.</returns>
		string PublishAction(string action, string objectType, string objectUrl);
	}
}
