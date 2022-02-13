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
using System.Web;
using Microsoft.AspNet.SignalR;
using Microsoft.AspNet.SignalR.Hubs;
using System.Diagnostics;

namespace SplendidCRM
{
	public interface ITwilioServer
	{
		string JoinGroup(string sConnectionId, string sGroupName);
		Guid CreateSmsMessage(string sMESSAGE_SID, string sFROM_NUMBER, string sTO_NUMBER, string sSUBJECT);
	}

	/// <summary>
	/// Summary description for TwilioManagerHub.
	/// </summary>
	[HubName("TwilioManagerHub")]
	public class TwilioManagerHub : Hub<ITwilioServer>
	{
		private readonly TwilioManager _twilioManager;

		public TwilioManagerHub() : this(TwilioManager.Instance)
		{
		}

		public TwilioManagerHub(TwilioManager TwilioManager)
		{
			_twilioManager = TwilioManager;
		}

		// 11/15/2014 Paul.  Hub method should require authorization. 
		// http://eworldproblems.mbaynton.com/2012/12/signalr-hub-authorization/
		[SplendidHubAuthorize]
		public string JoinGroup(string sConnectionId, string sGroupName)
		{
			// 09/02/2013 Paul.  The the.Context.User.Identity value is not the same as HttpContext.Current.User, so we don't know who this is. 
			//if ( this.Context.User != null && this.Context.User.Identity != null )
			//	Debug.WriteLine(this.Context.User.Identity.Name);
			if ( !Sql.IsEmptyString(sGroupName) )
			{
				sGroupName = Utils.NormalizePhone(TwilioManager.RemoveCountryCode(sGroupName));
				Groups.Add(sConnectionId, sGroupName).Wait();
				return sConnectionId + " joined " + sGroupName;
			}
			return "Group not specified.";
		}

		// 11/15/2014 Paul.  Hub method should require authorization. 
		// http://eworldproblems.mbaynton.com/2012/12/signalr-hub-authorization/
		[SplendidHubAuthorize]
		public Guid CreateSmsMessage(string sMESSAGE_SID, string sFROM_NUMBER, string sTO_NUMBER, string sSUBJECT)
		{
			return _twilioManager.CreateSmsMessage(sMESSAGE_SID, sFROM_NUMBER, sTO_NUMBER, sSUBJECT, String.Empty, String.Empty);
		}
	}
}

