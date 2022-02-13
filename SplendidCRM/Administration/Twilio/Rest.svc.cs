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
using System.IO;
using System.Net;
using System.Web;
using System.Data;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.ServiceModel.Activation;
using System.Web.Script.Serialization;
using System.Diagnostics;

namespace SplendidCRM.Administration.Twilio
{
	[ServiceContract]
	[ServiceBehavior( IncludeExceptionDetailInFaults = true )]
	[AspNetCompatibilityRequirements( RequirementsMode = AspNetCompatibilityRequirementsMode.Required )]
	public class Rest
	{
		public const string MODULE_NAME = "Twilio";

		[OperationContract]
		public string Test(Stream input)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			string sResult = String.Empty;
			try
			{
				L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				// 03/09/2019 Paul.  Allow admin delegate to access admin api. 
				if ( !Security.IsAuthenticated() || SplendidCRM.Security.AdminUserAccess(MODULE_NAME, "edit") < 0 )
				{
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
				}
				SplendidSession.CreateSession(HttpContext.Current.Session);
				
				string sRequest = String.Empty;
				using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
				{
					sRequest = stmRequest.ReadToEnd();
				}
				JavaScriptSerializer json = new JavaScriptSerializer();
				json.MaxJsonLength = int.MaxValue;
				Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
				
				string sACCOUNT_SID = String.Empty;
				string sAUTH_TOKEN  = String.Empty;
				foreach ( string sKey in dict.Keys )
				{
					switch ( sKey )
					{
						case "Twilio.AccountSID":  sACCOUNT_SID = Sql.ToString (dict[sKey]);  break;
						case "Twilio.AuthToken" :  sAUTH_TOKEN  = Sql.ToString (dict[sKey]);  break;
					}
				}
				// 03/10/2021 Paul.  Sensitive fields will not be sent to React client, so check for empty string. 
				if ( Sql.IsEmptyString(sACCOUNT_SID) || sACCOUNT_SID == Sql.sEMPTY_PASSWORD )
				{
					sACCOUNT_SID = Sql.ToString(Application["CONFIG.Twilio.AccountSID"]);
				}
				if ( Sql.IsEmptyString(sAUTH_TOKEN) || sAUTH_TOKEN == Sql.sEMPTY_PASSWORD )
				{
					sAUTH_TOKEN = Sql.ToString(Application["CONFIG.Twilio.AuthToken"]);
				}
				sResult = TwilioManager.ValidateLogin(Application, sACCOUNT_SID, sAUTH_TOKEN);
				if ( Sql.IsEmptyString(sResult) )
				{
					sResult = L10n.Term("Twilio.LBL_TEST_SUCCESSFUL");
				}
			}
			catch(Exception ex)
			{
				// 03/20/2019 Paul.  Catch and log all failures, including insufficient access. 
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				sResult = ex.Message;
			}
			return sResult;
		}

	}
}
