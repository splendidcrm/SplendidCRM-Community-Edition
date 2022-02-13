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
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Web;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for FacebookUtils.
	/// </summary>
	public class FacebookUtils
	{
		protected string   sAppID            ;
		protected string   sAppSecret        ;
		protected string   sAccessToken      ;
		protected string   sBaseDomain       ;
		protected DateTime dtExpires         ;
		protected string   sSecret           ;
		protected string   sSessionKey       ;
		protected string   sSig              ;
		protected string   sUID              ;
		protected string   sComputedSignature;
		protected NameValueCollection arrValues;

		public string UID
		{
			get { return sUID; }
		}

		public DateTime Expires
		{
			get { return dtExpires; }
		}

		public bool FacebookValuesExist
		{
			get { return !Sql.IsEmptyString(sAppID) && (arrValues != null); }
		}

		public FacebookUtils(string sAppID, string sAppSecret, HttpCookieCollection cookies)
		{
			this.sAppID     = sAppID    ;
			this.sAppSecret = sAppSecret;
			
			HttpCookie cFacebook = cookies["fbs_" + sAppID];
			if ( cFacebook != null )
			{
				arrValues = HttpUtility.ParseQueryString(cFacebook.Value.Replace("\"", string.Empty));
			}
		}

		public bool ParseCookie()
		{
			// 03/19/2011 Paul.  We need to reparse the cookie so that the values are properly unescaped. 
			if ( arrValues != null )
			{
				StringBuilder sbPayload = new StringBuilder();
				foreach ( string sKey in arrValues )
				{
					if ( sKey != "sig" )
						sbPayload.AppendFormat("{0}={1}", sKey, arrValues[sKey]);
				}
				sbPayload.Append(sAppSecret);
				// 03/19/2011 Paul.  facebook uses the same MD5 hash that we use for SplendidCRM passwords. 
				sComputedSignature = Security.HashPassword(sbPayload.ToString());
				
				long lExpires;
				DateTime dtUnixEpoch = new DateTime(1970, 1, 1);
				sAccessToken = arrValues["access_token"];
				sBaseDomain  = arrValues["base_domain" ];
				long.TryParse(arrValues["expires"], out lExpires);  // Unix timestamp. 
				dtExpires    = dtUnixEpoch.AddSeconds(lExpires);
				sSecret      = arrValues["secret"      ];
				sSessionKey  = arrValues["session_key" ];
				sSig         = arrValues["sig"         ];
				sUID         = arrValues["uid"         ];  // This is the facebook User ID. 
			}
			return IsValidSignature();
		}

		public bool IsValidSignature()
		{
			return (sSig == sComputedSignature);
		}
	}
}
