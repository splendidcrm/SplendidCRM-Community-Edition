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

const hubName = 'TwilioManagerHub';

export class TwilioServer
{
	twilioManager: SignalR.Hub.Proxy;

	constructor(twilioManager: SignalR.Hub.Proxy)
	{
		this.twilioManager = twilioManager;
	}

	public static enabled()
	{
		let bTwilioEnabled: boolean = Crm_Config.ToBoolean('Twilio.LogInboundMessages');
		return bTwilioEnabled;
	}

	public shouldJoin(sUSER_PHONE_MOBILE: string, sUSER_SMS_OPT_IN: string): boolean
	{
		if ( TwilioServer.enabled() && !Sql.IsEmptyString(sUSER_PHONE_MOBILE) && sUSER_SMS_OPT_IN == 'yes' )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldJoin', sUSER_PHONE_MOBILE);
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
		return this.twilioManager.invoke.apply(this.twilioManager, $.merge(["JoinGroup"], $.makeArray(arguments)));
	}

	public createSmsMessage(sMESSAGE_SID: string, sFROM_NUMBER: string, sTO_NUMBER: string, sSUBJECT: string)
	{
		/// <summary>Calls the CreateSmsMessage method on the server-side TwilioManagerHub hub.&#10;Returns a jQuery.Deferred() promise.</summary>
		/// <param name=\"sMESSAGE_SID\" type=\"String\">Server side type is System.String</param>
		/// <param name=\"sFROM_NUMBER\" type=\"String\">Server side type is System.String</param>
		/// <param name=\"sTO_NUMBER\" type=\"String\">Server side type is System.String</param>
		/// <param name=\"sSUBJECT\" type=\"String\">Server side type is System.String</param>
		return this.twilioManager.invoke.apply(this.twilioManager, $.merge(["CreateSmsMessage"], $.makeArray(arguments)));
	}
}

export function TwilioCreateHub(signalR: SignalR, history: H.History<H.LocationState>)
{
	let manager: any = signalR.hub.createHubProxy(hubName);
	manager.server = new TwilioServer(manager);
	manager.Shutdown = function()
	{
		if ( manager.hasSubscriptions() )
		{
			manager.off('incomingMessage');
		}
	};
	manager.on('incomingMessage', (MESSAGE_SID, FROM_NUMBER, TO_NUMBER, SUBJECT, SMS_MESSAGE_ID) =>
	{
		let oCommandArguments: any = { MESSAGE_SID, FROM_NUMBER, TO_NUMBER, SUBJECT, SMS_MESSAGE_ID };
		console.log((new Date()).toISOString() + ' ' + hubName + '.incomingMessage', oCommandArguments);
	});
	return manager;
}

