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

export class TwilioServerCore
{
	// 01/15/2024 Paul.  Updated history package. 
	history            : H.History;
	hub                : signalR.HubConnection;
	started            : boolean;
	sUSER_PHONE_MOBILE : string;
	sUSER_SMS_OPT_IN   : string;

	constructor(history: H.History, hub: signalR.HubConnection, sUSER_PHONE_MOBILE: string, sUSER_SMS_OPT_IN: string)
	{
		this.history             = history            ;
		this.hub                 = hub                ;
		this.sUSER_PHONE_MOBILE  = sUSER_PHONE_MOBILE ;
		this.sUSER_SMS_OPT_IN    = sUSER_SMS_OPT_IN   ;
	}

	public static enabled()
	{
		let bTwilioEnabled: boolean = Crm_Config.ToBoolean('Twilio.LogInboundMessages');
		return bTwilioEnabled;
	}

	public shouldJoin(): boolean
	{
		if ( TwilioServerCore.enabled() && !Sql.IsEmptyString(this.sUSER_PHONE_MOBILE) && this.sUSER_SMS_OPT_IN == 'yes' )
		{
			//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.shouldJoin', sUSER_PHONE_MOBILE);
			return true;
		}
		return false;
	}

	public joinGroup()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.joinGroup', this.sUSER_PHONE_MOBILE);
		this.hub.invoke('JoinGroup', this.sUSER_PHONE_MOBILE).then( (data: string) =>
		{
			console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.joinGroup', data);
		});
	}

	public createSmsMessage(sMESSAGE_SID: string, sFROM_NUMBER: string, sTO_NUMBER: string, sSUBJECT: string)
	{
		return this.hub.invoke("CreateSmsMessage", sMESSAGE_SID, sFROM_NUMBER, sTO_NUMBER, sSUBJECT);
	}

	public shutdown()
	{
		if ( this.started )
		{
			this.hub.off('incomingMessage');
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
		this.hub.on('incomingMessage', (MESSAGE_SID, FROM_NUMBER, TO_NUMBER, SUBJECT, SMS_MESSAGE_ID) =>
		{
			let oCommandArguments: any = { MESSAGE_SID, FROM_NUMBER, TO_NUMBER, SUBJECT, SMS_MESSAGE_ID };
			console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.incomingMessage', oCommandArguments);
		});

		this.hub.start()
		.catch( (e) =>
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.start', e);
		})
		.then( () =>
		{
			this.started = false;
			console.log('TwilioHub connection started');
			this.joinGroup();
		});
	}
}

export function TwilioCreateHub(history: H.History, sUSER_PHONE_MOBILE: string, sUSER_SMS_OPT_IN: string): TwilioServerCore
{
	const hub: signalR.HubConnection = new signalR.HubConnectionBuilder()
		.withUrl("/signalr_twiliohub")
		//.configureLogging(signalR.LogLevel.Debug)  // https://learn.microsoft.com/en-us/aspnet/core/signalr/diagnostics?view=aspnetcore-5.0
		.withAutomaticReconnect()
		.build();
	let manager: TwilioServerCore = new TwilioServerCore(history, hub, sUSER_PHONE_MOBILE, sUSER_SMS_OPT_IN);
	if ( manager.shouldJoin() )
	{
		manager.startup();
	}
	return manager;
}

