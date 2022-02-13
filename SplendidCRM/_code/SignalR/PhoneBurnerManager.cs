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
using System.Data;
using System.Data.Common;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Web;
using System.Web.UI;
using System.Diagnostics;
using Microsoft.AspNet.SignalR;
using Microsoft.AspNet.SignalR.Hubs;
using Twilio;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for PhoneBurnerManager.
	/// </summary>
	public class PhoneBurnerManager
	{
		public static void RegisterScripts(HttpContext Context, ScriptManager mgrAjax)
		{
			if ( mgrAjax != null )
			{
				if ( Utils.CachedFileExists(Context, "~/Include/javascript/PhoneBurnerManagerHubJS.aspx") )
				{
					HttpApplicationState Application = Context.Application;
					if ( Sql.ToBoolean(Application["CONFIG.PhoneBurner.Enabled"]) )
					{
						string sClientID     = Sql.ToString(Application["CONFIG.PhoneBurner.ClientID"    ]);
						string sClientSecret = Sql.ToString(Application["CONFIG.PhoneBurner.ClientSecret"]);
						if ( !Sql.IsEmptyString(sClientID) && !Sql.IsEmptyString(sClientSecret) )
						{
							if ( !Sql.IsEmptyString(Application["CONFIG.PhoneBurner." + Security.USER_ID.ToString() + ".OAuthAccessToken"]) )
							{
								SignalRUtils.RegisterSignalR(mgrAjax);
								ScriptReference scrPhoneBurnerManagerHub = new ScriptReference("~/Include/javascript/PhoneBurnerManagerHubJS.aspx?" + Sql.ToString(Application["SplendidVersion"]) + "_" + Sql.ToString(Context.Session["USER_SETTINGS/CULTURE"]));
								if ( !mgrAjax.Scripts.Contains(scrPhoneBurnerManagerHub) )
									mgrAjax.Scripts.Add(scrPhoneBurnerManagerHub);
							}
						}
					}
				}
			}
		}
	}
}

