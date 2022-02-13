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
	public interface IChatHubServer
	{
		string JoinGroup(string sConnectionId, string sGroupName);
	}

	/// <summary>
	/// Summary description for ChatManagerHub.
	/// </summary>
	[HubName("ChatManagerHub")]
	public class ChatManagerHub : Hub<IChatHubServer>
	{
		private readonly ChatManager _ChatManager;

		public ChatManagerHub() : this(ChatManager.Instance)
		{
		}

		public ChatManagerHub(ChatManager ChatManager)
		{
			_ChatManager = ChatManager;
		}

		// 11/15/2014 Paul.  Hub method should require authorization. 
		// http://eworldproblems.mbaynton.com/2012/12/signalr-hub-authorization/
		[SplendidHubAuthorize]
		public string JoinGroup(string sConnectionId, string sGroupName)
		{
			if ( !Sql.IsEmptyString(sGroupName) )
			{
				// 10/26/2013 Paul.  Each track is a separate group. 
				// 10/27/2013 Paul.  The group string is already expected to be in lowercase so that we don't have to waste time doing it now. 
				string[] arrTracks = sGroupName.Split(',');
				foreach ( string sTrack in arrTracks )
					Groups.Add(sConnectionId, sTrack).Wait();
				return sConnectionId + " joined " + sGroupName;
			}
			return "Group not specified.";
		}
	}
}

