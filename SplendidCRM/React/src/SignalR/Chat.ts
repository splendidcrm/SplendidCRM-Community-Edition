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
// 2. Store and Types. 
import MODULE         from '../types/MODULE'         ;
// 3. Scripts. 
import Sql            from '../scripts/Sql'          ;
import SplendidCache  from '../scripts/SplendidCache';

const hubName = 'ChatManagerHub';

export class ChatServer
{
	chatManager: SignalR.Hub.Proxy;

	constructor(chatManager: SignalR.Hub.Proxy)
	{
		this.chatManager = chatManager;
	}

	public static enabled()
	{
		let module:MODULE = SplendidCache.Module('ChatDashboard', this.constructor.name + '.enabled');
		return true;
	}

	public shouldJoin(sUSER_CHAT_CHANNELS: string): boolean
	{
		if ( ChatServer.enabled() && !Sql.IsEmptyString(sUSER_CHAT_CHANNELS) )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldJoin', sUSER_CHAT_CHANNELS);
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
		return this.chatManager.invoke.apply(this.chatManager, $.merge(["JoinGroup"], $.makeArray(arguments)));
	}
}

// 01/15/2024 Paul.  Update History. 
export function ChatCreateHub(signalR: SignalR, history: H.History)
{
	let manager: any = signalR.hub.createHubProxy(hubName);
	manager.server = new ChatServer(manager);
	manager.Shutdown = function()
	{
		if ( manager.hasSubscriptions() )
		{
			manager.off('newMessage');
		}
	};
	/*
	manager.on('newMessage', (CHAT_CHANNEL_ID, ID, NAME, DESCRIPTION, DATE_ENTERED, PARENT_ID, PARENT_TYPE, PARENT_NAME, CREATED_BY_ID, CREATED_BY, CREATED_BY_PICTURE, NOTE_ATTACHMENT_ID, FILENAME, FILE_EXT, FILE_MIME_TYPE, FILE_SIZE, ATTACHMENT_READY) =>
	{
		let oCommandArguments: any = { CHAT_CHANNEL_ID, ID, NAME, DESCRIPTION, DATE_ENTERED, PARENT_ID, PARENT_TYPE, PARENT_NAME, CREATED_BY_ID, CREATED_BY, CREATED_BY_PICTURE, NOTE_ATTACHMENT_ID, FILENAME, FILE_EXT, FILE_MIME_TYPE, FILE_SIZE, ATTACHMENT_READY };
		console.log((new Date()).toISOString() + ' ' + hubName + '.newMessage', oCommandArguments);
		//if ( this.history != null )
		//{
		//	history.push('/Reset/ChatDashboard/' + CHAT_CHANNEL_ID);
		//}
	});
	*/
	return manager;
}

