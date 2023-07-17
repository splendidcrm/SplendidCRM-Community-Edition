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

export class AvayaServerCore
{
	history            : H.History<H.LocationState>;
	hub                : signalR.HubConnection;
	started            : boolean;
	sUSER_EXTENSION    : string;

	constructor(history: H.History<H.LocationState>, hub: signalR.HubConnection, sUSER_EXTENSION: string)
	{
		this.history             = history            ;
		this.hub                 = hub                ;
		this.sUSER_EXTENSION     = sUSER_EXTENSION    ;
	}

	public static enabled()
	{
		let bAvayaEnabled: boolean = !Sql.IsEmptyString(Crm_Config.ToString('Avaya.Host'));
		if ( Crm_Config.ToString('service_level') == 'Professional' || Crm_Config.ToString('service_level') == 'Community' )
		{
			bAvayaEnabled = false;
		}
		return bAvayaEnabled;
	}

	public shouldJoin(): boolean
	{
		if ( AvayaServerCore.enabled() && !Sql.IsEmptyString(this.sUSER_EXTENSION) )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldJoin', sUSER_EXTENSION);
			return true;
		}
		return false;
	}

	public joinGroup()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.joinGroup', this.sUSER_EXTENSION);
		this.hub.invoke('JoinGroup', this.sUSER_EXTENSION).then( (data: string) =>
		{
			console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.joinGroup', data);
		});
	}

	public createCall(sUniqueId: string)
	{
		return this.hub.invoke("CreateCall", sUniqueId);
	}

	public originateCall(sUSER_EXTENSION: string, sUSER_FULL_NAME: string, sUSER_PHONE_WORK: string, sPHONE: string, sPARENT_ID: string, sPARENT_TYPE: string)
	{
		return this.hub.invoke("OriginateCall", sUSER_EXTENSION, sUSER_FULL_NAME, sUSER_PHONE_WORK, sPHONE, sPARENT_ID, sPARENT_TYPE);
	}

	public shutdown()
	{
		if ( this.started )
		{
			this.hub.off('newState'          );
			this.hub.off('outgoingCall'      );
			this.hub.off('incomingCall'      );
			this.hub.off('outgoingComplete'  );
			this.hub.off('incomingComplete'  );
			this.hub.off('outgoingIncomplete');
			this.hub.off('incomingIncomplete');
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
		this.hub.on('newState', (Status) =>
		{
			let oCommandArguments: any = { Status };
			console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.newState', oCommandArguments);
		});
		this.hub.on('outgoingCall', (UniqueId, ConnectedLineName, CallerID, CALL_ID) =>
		{
			let oCommandArguments: any = { UniqueId, ConnectedLineName, CallerID, CALL_ID };
			console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.outgoingCall', oCommandArguments);
		});
		this.hub.on('incomingCall', (UniqueId, ConnectedLineName, CallerID, CALL_ID) =>
		{
			let oCommandArguments: any = { UniqueId, ConnectedLineName, CallerID, CALL_ID };
			console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.incomingCall', oCommandArguments);
		});
		this.hub.on('outgoingComplete', (UniqueId, ConnectedLineName, CallerID, CALL_ID, DURATION_HOURS, DURATION_MINUTES) =>
		{
			let oCommandArguments: any = { UniqueId, ConnectedLineName, CallerID, CALL_ID, DURATION_HOURS, DURATION_MINUTES };
			console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.outgoingComplete', oCommandArguments);
		});
		this.hub.on('incomingComplete', (UniqueId, ConnectedLineName, CallerID, CALL_ID, DURATION_HOURS, DURATION_MINUTES) =>
		{
			let oCommandArguments: any = { UniqueId, ConnectedLineName, CallerID, CALL_ID, DURATION_HOURS, DURATION_MINUTES };
			console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.incomingComplete', oCommandArguments);
		});
		this.hub.on('outgoingIncomplete', (UniqueId, ConnectedLineName, CallerID, CALL_ID, Error) =>
		{
			let oCommandArguments: any = { UniqueId, ConnectedLineName, CallerID, CALL_ID, Error };
			console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.outgoingIncomplete', oCommandArguments);
		});
		this.hub.on('incomingIncomplete', (UniqueId, ConnectedLineName, CallerID, CALL_ID) =>
		{
			let oCommandArguments: any = { UniqueId, ConnectedLineName, CallerID, CALL_ID };
			console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.incomingIncomplete', oCommandArguments);
		});

		this.hub.start()
		.catch( (e) =>
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.start', e);
		})
		.then( () =>
		{
			this.started = false;
			console.log('AvayaHub connection started');
			this.joinGroup();
		});
	}
}

export function AvayaCreateHub(history: H.History<H.LocationState>, sUSER_EXTENSION: string): AvayaServerCore
{
	const hub: signalR.HubConnection = new signalR.HubConnectionBuilder()
		.withUrl("/signalr_asteriskhub")
		//.configureLogging(signalR.LogLevel.Debug)  // https://learn.microsoft.com/en-us/aspnet/core/signalr/diagnostics?view=aspnetcore-5.0
		.withAutomaticReconnect()
		.build();
	let manager: AvayaServerCore = new AvayaServerCore(history, hub, sUSER_EXTENSION);
	if ( manager.shouldJoin() )
	{
		manager.startup();
	}
	return manager;
}

