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
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace Spring.Social.Salesforce.Api
{
	/// <summary>
	/// The exception that is thrown when a error occurs while consuming Salesforce REST API.
	/// </summary>
	/// <author>Bruno Baia</author>
	/// <author>SplendidCRM (.NET)</author>
#if !SILVERLIGHT
	[Serializable]
#endif
	public class SalesforceApiException : SocialException
	{
		private SalesforceApiError error;

		/// <summary>
		/// Gets the Salesforce error.
		/// </summary>
		public SalesforceApiError Error
		{
			get { return this.error; }
		}

		/// <summary>
		/// Creates a new instance of the <see cref="SalesforceApiException"/> class.
		/// </summary>
		/// <param name="message">A message about the exception.</param>
		/// <param name="error">The Salesforce error.</param>
		public SalesforceApiException(string message, SalesforceApiError error) : base(message)
		{
			this.error = error;
		}

		/// <summary>
		/// Creates a new instance of the <see cref="SalesforceApiException"/> class.
		/// </summary>
		/// <param name="message">A message about the exception.</param>
		/// <param name="innerException">The inner exception that is the cause of the current exception.</param>
		public SalesforceApiException(string message, Exception innerException) : base(message, innerException)
		{
			this.error = SalesforceApiError.Unknown;
		}

#if !SILVERLIGHT
		/// <summary>
		/// Creates a new instance of the <see cref="SalesforceApiException"/> class.
		/// </summary>
		/// <param name="info">
		/// The <see cref="System.Runtime.Serialization.SerializationInfo"/>
		/// that holds the serialized object data about the exception being thrown.
		/// </param>
		/// <param name="context">
		/// The <see cref="System.Runtime.Serialization.StreamingContext"/>
		/// that contains contextual information about the source or destination.
		/// </param>
		protected SalesforceApiException(SerializationInfo info, StreamingContext context) : base(info, context)
		{
			if (info != null)
			{
				this.error = (SalesforceApiError)info.GetValue("Error", typeof(SalesforceApiError));
			}
		}

		/// <summary>
		/// Populates the <see cref="System.Runtime.Serialization.SerializationInfo"/> with 
		/// information about the exception.
		/// </summary>
		/// <param name="info">
		/// The <see cref="System.Runtime.Serialization.SerializationInfo"/> that holds 
		/// the serialized object data about the exception being thrown.
		/// </param>
		/// <param name="context">
		/// The <see cref="System.Runtime.Serialization.StreamingContext"/> that contains contextual 
		/// information about the source or destination.
		/// </param>
		[SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
		public override void GetObjectData(SerializationInfo info, StreamingContext context)
		{
			base.GetObjectData(info, context);
			if (info != null)
			{
				info.AddValue("Error", this.error);
			}
		}
#endif
	}
}
