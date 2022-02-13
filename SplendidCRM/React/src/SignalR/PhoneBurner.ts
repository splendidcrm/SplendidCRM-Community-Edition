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

const hubName = 'PhoneBurnerManagerHub';

export class PhoneBurnerServer
{
	phoneBurnerManager: SignalR.Hub.Proxy;

	constructor(phoneBurnerManager: SignalR.Hub.Proxy)
	{
		this.phoneBurnerManager = phoneBurnerManager;
	}

	public static enabled()
	{
		let bPhoneBurnerEnabled: boolean = Crm_Config.ToBoolean('PhoneBurner.Enabled') && !Sql.IsEmptyString(Crm_Config.ToString('PhoneBurner.ClientID'));
		if ( Crm_Config.ToString('service_level') == 'Professional' || Crm_Config.ToString('service_level') == 'Community' )
		{
			bPhoneBurnerEnabled = false;
		}
		return bPhoneBurnerEnabled;
	}

	public shouldJoin(dtPHONEBURNER_TOKEN_EXPIRES_AT: Date): boolean
	{
		if ( PhoneBurnerServer.enabled() && dtPHONEBURNER_TOKEN_EXPIRES_AT != null )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldJoin', dtPHONEBURNER_TOKEN_EXPIRES_AT);
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
		return this.phoneBurnerManager.invoke.apply(this.phoneBurnerManager, $.merge(["JoinGroup"], $.makeArray(arguments)));
	}
}

export function PhoneBurnerCreateHub(signalR: SignalR, history: H.History<H.LocationState>)
{
	let manager: any = signalR.hub.createHubProxy(hubName);
	manager.server = new PhoneBurnerServer(manager);
	manager.Shutdown = function()
	{
		if ( manager.hasSubscriptions() )
		{
			manager.off('callBegin');
			manager.off('callDone');
		}
	};
	manager.on('callBegin', (PARENT_TYPE, PARENT_ID, PARENT_NAME, CALL_ID) =>
	{
		let oCommandArguments: any = { PARENT_TYPE, PARENT_ID, PARENT_NAME, CALL_ID };
		console.log((new Date()).toISOString() + ' ' + hubName + '.callBegin', oCommandArguments);
		if ( this.history != null )
		{
			history.push('/Reset/Calls/Edit/' + CALL_ID);
		}
	});
	manager.on('callDone', (PARENT_TYPE, PARENT_ID, PARENT_NAME, CALL_ID) =>
	{
		let oCommandArguments: any = { PARENT_TYPE, PARENT_ID, PARENT_NAME, CALL_ID };
		console.log((new Date()).toISOString() + ' ' + hubName + '.callDone', oCommandArguments);
	});
	return manager;
}
