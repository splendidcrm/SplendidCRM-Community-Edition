/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 1. React and fabric. 
import * as H         from 'history'       ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql            from '../scripts/Sql';
import { Crm_Config } from '../scripts/Crm';

const hubName = 'TwitterManagerHub';

export class TwitterServer
{
	twitterManager: SignalR.Hub.Proxy;

	constructor(twitterManager: SignalR.Hub.Proxy)
	{
		this.twitterManager = twitterManager;
	}

	public static enabled()
	{
		let bTwitterEnabled: boolean = Crm_Config.ToBoolean('Twitter.EnableTracking') && !Sql.IsEmptyString(Crm_Config.ToString('Twitter.ConsumerKey'));
		return bTwitterEnabled;
	}

	public shouldJoin(sUSER_TWITTER_TRACKS: string): boolean
	{
		if ( TwitterServer.enabled() && !Sql.IsEmptyString(sUSER_TWITTER_TRACKS) )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldJoin', sUSER_TWITTER_TRACKS);
			return true;
		}
		return false;
	}

	public joinGroup(sConnectionId: string, sGroupName: string)
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.joinGroup', sGroupName);
		/// <summary>Calls the JoinGroup method on the server-side PhoneBurnerManagerHub hub.&#10;Returns a jQuery.Deferred() promise.</summary>
		/// <param name=\"sConnectionId\" type=\"String\">Server side type is System.String</param>
		/// <param name=\"sGroupName\" type=\"String\">Server side type is System.String</param>
		return this.twitterManager.invoke.apply(this.twitterManager, $.merge(["JoinGroup"], $.makeArray(arguments)));
	}
}

// 01/15/2024 Paul.  Update History. 
export function TwitterCreateHub(signalR: SignalR, history: H.History)
{
	let manager: any = signalR.hub.createHubProxy(hubName);
	manager.server = new TwitterServer(manager);
	manager.Shutdown = function()
	{
		if ( manager.hasSubscriptions() )
		{
			manager.off('newMessage');
		}
	};
	manager.on('newTweet', (TRACK, NAME, DESCRIPTION, DATE_START, TWITTER_ID, TWITTER_USER_ID, TWITTER_FULL_NAME, TWITTER_SCREEN_NAME, TWITTER_AVATAR, TWITTER_MESSAGE_ID) =>
	{
		let oCommandArguments: any = { TRACK, NAME, DESCRIPTION, DATE_START, TWITTER_ID, TWITTER_USER_ID, TWITTER_FULL_NAME, TWITTER_SCREEN_NAME, TWITTER_AVATAR, TWITTER_MESSAGE_ID };
		console.log((new Date()).toISOString() + ' ' + hubName +'.newTweet', oCommandArguments);
	});
	return manager;
}

