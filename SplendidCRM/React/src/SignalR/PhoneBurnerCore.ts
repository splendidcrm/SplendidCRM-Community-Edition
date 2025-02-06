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

export class PhoneBurnerServerCore
{
	// 01/15/2024 Paul.  Updated history package. 
	history                       : H.History;
	hub                           : signalR.HubConnection;
	started                       : boolean;
	sUSER_ID                      : string;
	dtPHONEBURNER_TOKEN_EXPIRES_AT: Date;

	constructor(history: H.History, hub: signalR.HubConnection, sUSER_ID: string, dtPHONEBURNER_TOKEN_EXPIRES_AT: Date)
	{
		this.history                        = history                       ;
		this.hub                            = hub                           ;
		this.sUSER_ID                       = sUSER_ID                      ;
		this.dtPHONEBURNER_TOKEN_EXPIRES_AT = dtPHONEBURNER_TOKEN_EXPIRES_AT;
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

	public shouldJoin(): boolean
	{
		if ( PhoneBurnerServerCore.enabled() && this.dtPHONEBURNER_TOKEN_EXPIRES_AT != null )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldJoin', this.dtPHONEBURNER_TOKEN_EXPIRES_AT);
			return true;
		}
		return false;
	}

	public joinGroup()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.joinGroup', this.sUSER_ID);
		this.hub.invoke('JoinGroup', this.sUSER_ID).then( (data: string) =>
		{
			console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.joinGroup', data);
		});
	}

	public shutdown()
	{
		if ( this.started )
		{
			this.hub.off('callBegin');
			this.hub.off('callDone');
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
		this.hub.on('callBegin', (PARENT_TYPE, PARENT_ID, PARENT_NAME, CALL_ID) =>
		{
			let oCommandArguments: any = { PARENT_TYPE, PARENT_ID, PARENT_NAME, CALL_ID };
			console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.callBegin', oCommandArguments);
			if ( this.history != null )
			{
				this.history.push('/Reset/Calls/Edit/' + CALL_ID);
			}
		});
		this.hub.on('callDone', (PARENT_TYPE, PARENT_ID, PARENT_NAME, CALL_ID) =>
		{
			let oCommandArguments: any = { PARENT_TYPE, PARENT_ID, PARENT_NAME, CALL_ID };
			console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.callDone', oCommandArguments);
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
			console.log('TwilioHub connection started');
			this.joinGroup();
		});
	}
}

export function PhoneBurnerCreateHub(history: H.History, sUSER_ID: string, dtPHONEBURNER_TOKEN_EXPIRES_AT: Date): PhoneBurnerServerCore
{
	const hub: signalR.HubConnection = new signalR.HubConnectionBuilder()
		.withUrl("/signalr_phoneburnerhub")
		//.configureLogging(signalR.LogLevel.Debug)  // https://learn.microsoft.com/en-us/aspnet/core/signalr/diagnostics?view=aspnetcore-5.0
		.withAutomaticReconnect()
		.build();
	let manager: PhoneBurnerServerCore = new PhoneBurnerServerCore(history, hub, sUSER_ID, dtPHONEBURNER_TOKEN_EXPIRES_AT);
	if ( manager.shouldJoin() )
	{
		manager.startup();
	}
	return manager;
}
