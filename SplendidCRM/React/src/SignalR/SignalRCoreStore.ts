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
import { History }                                 from 'history'               ;
// 2. Store and Types. 
// 3. Scripts. 
import Credentials                                 from '../scripts/Credentials';
// 4. SignalR hubs.
import { AsteriskServerCore   , AsteriskCreateHub    } from './AsteriskCore'            ;
import { AvayaServerCore      , AvayaCreateHub       } from './AvayaCore'               ;
import { ChatServerCore       , ChatCreateHub        } from './ChatCore'                ;
import { TwilioServerCore     , TwilioCreateHub      } from './TwilioCore'              ;
import { TwitterServerCore    , TwitterCreateHub     } from './TwitterCore'             ;
import { PhoneBurnerServerCore, PhoneBurnerCreateHub } from './PhoneBurnerCore'         ;

function makeProxyCallback(hub, callback)
{
	return function ()
	{
		// Call the client hub method
		callback.apply(hub, $.makeArray(arguments));
	};
}

function registerHubProxies(instance, shouldSubscribe)
{
	var key, hub, memberKey, memberValue, subscriptionMethod;

	for ( key in instance )
	{
		if ( instance.hasOwnProperty(key) )
		{
			hub = instance[key];

			if ( !(hub.hubName) )
			{
				// Not a client hub
				continue;
			}

			if ( shouldSubscribe )
			{
				// We want to subscribe to the hub events
				subscriptionMethod = hub.on;
			}
			else
			{
				// We want to unsubscribe from the hub events
				subscriptionMethod = hub.off;
			}

			// Loop through all members on the hub and find client hub functions to subscribe/unsubscribe
			for ( memberKey in hub.client )
			{
				if ( hub.client.hasOwnProperty(memberKey) )
				{
					memberValue = hub.client[memberKey];

					if ( !$.isFunction(memberValue) )
					{
						// Not a client hub function
						continue;
					}

					subscriptionMethod.call(hub, memberKey, makeProxyCallback(hub, memberValue));
				}
			}
		}
	}
}

export class SignalRCoreStore
{
	public  asteriskManager   : AsteriskServerCore    = null;
	public  avayaManager      : AvayaServerCore       = null;
	public  chatManager       : ChatServerCore        = null;
	public  twilioManager     : TwilioServerCore      = null;
	public  twitterManager    : TwitterServerCore     = null;
	public  phoneBurnerManager: PhoneBurnerServerCore = null;
	private history           : History = null;

	// 06/19/2023 Paul.  Call from main App to provide access to history. 
	public SetHistory(history)
	{
		this.history = history;
	}

	public Startup()
	{
		console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Startup', this.history);
		
		let sRemoteServer                 : string = Credentials.RemoteServer                  ;
		let sUSER_ID                      : string = Credentials.sUSER_ID                      ;
		let sUSER_EXTENSION               : string = Credentials.sUSER_EXTENSION               ;
		let sUSER_SMS_OPT_IN              : string = Credentials.sUSER_SMS_OPT_IN              ;
		let sUSER_PHONE_MOBILE            : string = Credentials.sUSER_PHONE_MOBILE            ;
		let sUSER_TWITTER_TRACKS          : string = Credentials.sUSER_TWITTER_TRACKS          ;
		let sUSER_CHAT_CHANNELS           : string = Credentials.sUSER_CHAT_CHANNELS           ;
		let dtPHONEBURNER_TOKEN_EXPIRES_AT: Date   = Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT;

		if ( TwilioServerCore.enabled()      )
		{
			this.twilioManager      = TwilioCreateHub     (this.history, sUSER_PHONE_MOBILE, sUSER_SMS_OPT_IN);
		}
		if ( ChatServerCore.enabled()        )
		{
			this.chatManager        = ChatCreateHub       (this.history, sUSER_CHAT_CHANNELS);
		}
		if ( AsteriskServerCore.enabled()    )
		{
			this.asteriskManager    = AsteriskCreateHub   (this.history, sUSER_EXTENSION);
		}
		if ( AvayaServerCore.enabled()       )
		{
			this.avayaManager       = AvayaCreateHub      (this.history, sUSER_EXTENSION);
		}
		if ( TwitterServerCore.enabled()     )
		{
			this.twitterManager     = TwitterCreateHub    (this.history, sUSER_TWITTER_TRACKS);
		}
		if ( PhoneBurnerServerCore.enabled() )
		{
			// 09/09/2020 Paul.  Add PhoneBurner SignalR support. 
			this.phoneBurnerManager = PhoneBurnerCreateHub(this.history, sUSER_ID, dtPHONEBURNER_TOKEN_EXPIRES_AT);
		}
	}

	public Shutdown()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Shutdown');
		if ( this.asteriskManager    ) this.asteriskManager.shutdown()   ;
		if ( this.avayaManager       ) this.avayaManager.shutdown()      ;
		if ( this.chatManager        ) this.chatManager.shutdown()       ;
		if ( this.twilioManager      ) this.twilioManager.shutdown()     ;
		if ( this.twitterManager     ) this.twitterManager.shutdown()    ;
		if ( this.phoneBurnerManager ) this.phoneBurnerManager.shutdown();
	}
}

const signalrStore = new SignalRCoreStore();
export default signalrStore;

