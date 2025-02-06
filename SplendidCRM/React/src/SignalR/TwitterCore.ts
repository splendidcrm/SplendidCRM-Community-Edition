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
import * as H         from 'history'                 ;
import * as signalR   from "@microsoft/signalr"      ;
// 2. Store and Types. 
// 3. Scripts. 
import Sql            from '../scripts/Sql'          ;
import { Crm_Config } from '../scripts/Crm'          ;

export class TwitterServerCore
{
	// 01/15/2024 Paul.  Updated history package. 
	history             : H.History;
	hub                 : signalR.HubConnection;
	started             : boolean;
	sUSER_TWITTER_TRACKS: string;

	constructor(history: H.History, hub: signalR.HubConnection, sUSER_TWITTER_TRACKS: string)
	{
		this.history              = history             ;
		this.hub                  = hub                 ;
		this.sUSER_TWITTER_TRACKS = sUSER_TWITTER_TRACKS;
	}

	public static enabled()
	{
		let bTwitterEnabled: boolean = Crm_Config.ToBoolean('Twitter.EnableTracking') && !Sql.IsEmptyString(Crm_Config.ToString('Twitter.ConsumerKey'));
		return bTwitterEnabled;
	}

	public shouldJoin(): boolean
	{
		if ( TwitterServerCore.enabled() && !Sql.IsEmptyString(this.sUSER_TWITTER_TRACKS) )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldJoin', sUSER_TWITTER_TRACKS);
			return true;
		}
		return false;
	}

	public joinGroup()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.joinGroup', this.sUSER_CHAT_CHANNELS);
		this.hub.invoke('JoinGroup', this.sUSER_TWITTER_TRACKS).then( (data: string) =>
		{
			console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.joinGroup', data);
		});
	}

	public shutdown()
	{
		if ( this.started )
		{
			this.hub.off('newTweet');
			try
			{
				this.hub.stop();
			}
			catch(e)
			{
				console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.shutdown', e);
			}
			this.started = false;
		}
	}

	public startup()
	{
		this.hub.on('newTweet', (TRACK, NAME, DESCRIPTION, DATE_START, TWITTER_ID, TWITTER_USER_ID, TWITTER_FULL_NAME, TWITTER_SCREEN_NAME, TWITTER_AVATAR, TWITTER_MESSAGE_ID) =>
		{
			let oCommandArguments: any = { TRACK, NAME, DESCRIPTION, DATE_START, TWITTER_ID, TWITTER_USER_ID, TWITTER_FULL_NAME, TWITTER_SCREEN_NAME, TWITTER_AVATAR, TWITTER_MESSAGE_ID };
			console.log((new Date()).toISOString() + ' ' + this.constructor.name +'.newTweet', oCommandArguments);
		});

		this.hub.start()
		.catch( (e) =>
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.start', e);
		})
		.then( () =>
		{
			// 12/01/2024 Paul.  Set started flag. 
			this.started = true;
			console.log('Twitter connection started');
			this.joinGroup();
		});
	}
}

export function TwitterCreateHub(history: H.History, sUSER_TWITTER_TRACKS: string): TwitterServerCore
{
	const hub: signalR.HubConnection = new signalR.HubConnectionBuilder()
		.withUrl("/signalr_twitterhub")
		//.configureLogging(signalR.LogLevel.Debug)  // https://learn.microsoft.com/en-us/aspnet/core/signalr/diagnostics?view=aspnetcore-5.0
		.withAutomaticReconnect()
		.build();
	let manager: TwitterServerCore = new TwitterServerCore(history, hub, sUSER_TWITTER_TRACKS);
	if ( manager.shouldJoin() )
	{
		manager.startup();
	}
	return manager;
}

