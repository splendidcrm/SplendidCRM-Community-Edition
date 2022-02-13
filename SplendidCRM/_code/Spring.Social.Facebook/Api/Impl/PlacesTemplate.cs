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
	class PlacesTemplate : AbstractFacebookOperations, IPlacesOperations
	{
		public PlacesTemplate(string applicationNamespace, RestTemplate restTemplate, bool isAuthorized)
			: base(applicationNamespace, restTemplate, isAuthorized)
		{
		}

		#region IPlacesOperations Members
		public List<Checkin> GetCheckins()
		{
			return GetCheckins("me", 0, 25);
		}

		public List<Checkin> GetCheckins(int offset, int limit)
		{
			return GetCheckins("me", offset, limit);
		}

		public List<Checkin> GetCheckins(string objectId)
		{
			return GetCheckins(objectId, 0, 25);
		}
	
		public List<Checkin> GetCheckins(string objectId, int offset, int limit)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("offset", offset.ToString());
			parameters.Add("limit" , limit .ToString());
			return this.FetchConnections<Checkin>(objectId, "checkins", parameters);
		}

		public Checkin GetCheckin(string checkinId)
		{
			requireAuthorization();
			return this.FetchObject<Checkin>(checkinId);
		}
	
		public string Checkin(string placeId, double latitude, double longitude)
		{
			return Checkin(placeId, latitude, longitude, null, null);
		}
	
		public string Checkin(string placeId, double latitude, double longitude, string message, string[] tags)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("place"      , placeId);
			parameters.Add("coordinates", "{\"latitude\":\"" + latitude.ToString() + "\",\"longitude\":\"" + longitude.ToString() + "\"}");
			if ( message != null )
			{
				parameters.Add("message", message);
			}
		
			if ( tags != null && tags.Length > 0 )
			{
				string tagsValue = tags[0];
				for ( int i = 1; i < tags.Length; i++ )
				{
					tagsValue += "," + tags[i];
				}
				parameters.Add("tags", tagsValue);
			}
			return this.Publish("me", "checkins", parameters);
		}
	
		public List<Page> Search(string query, double latitude, double longitude, long distance)
		{
			requireAuthorization();
			NameValueCollection parameters = new NameValueCollection();
			parameters.Add("q"       , query  );
			parameters.Add("type"    , "place");
			parameters.Add("center"  , latitude.ToString() + "," + longitude.ToString());
			parameters.Add("distance", distance.ToString());
			return this.FetchConnections<Page>("search", null, parameters);
		}
		#endregion
	}
}