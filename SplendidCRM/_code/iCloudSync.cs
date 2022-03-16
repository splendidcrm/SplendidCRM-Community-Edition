/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved."
 *********************************************************************************************************************/
using System;
using System.Text;
using System.Web;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;

namespace SplendidCRM
{
	[DataContract]
	public class AppleAccessToken
	{
		[DataMember] public string token_type    { get; set; }
		[DataMember] public string expires_in    { get; set; }
		[DataMember] public string access_token  { get; set; }
		[DataMember] public string refresh_token { get; set; }
		[DataMember] public string id_token      { get; set; }

		public string AccessToken
		{
			get { return access_token;  }
			set { access_token = value; }
		}
		public string RefreshToken
		{
			get { return refresh_token;  }
			set { refresh_token = value; }
		}
		public Int64 ExpiresInSeconds
		{
			get { return Sql.ToInt64(expires_in);  }
			set { expires_in = Sql.ToString(value); }
		}
		public string TokenType
		{
			get { return token_type;  }
			set { token_type = value; }
		}
	}

	public class iCloudSync
	{
		public static bool Validate_iCloud(HttpApplicationState Application, string sICLOUD_USERNAME, string sICLOUD_PASSWORD, StringBuilder sbErrors)
		{
			return false;
		}

		public static void AcquireAccessToken(HttpContext Context, Guid gUSER_ID, string sCode, string sIdToken, StringBuilder sbErrors)
		{
		}

		public static AppleAccessToken RefreshAccessToken(HttpContext Context, Guid gUSER_ID, bool bForceRefresh)
		{
			return null;
		}

		public class UserSync
		{
			public void Start()
			{
			}

			public static UserSync Create(HttpContext Context, Guid gUSER_ID, bool bSyncAll)
			{
				iCloudSync.UserSync User = null;
				return User;
			}
		}
	}
}
