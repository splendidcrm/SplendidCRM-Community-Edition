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
import * as H                                      from 'history'               ;
import $                                           from 'jquery'                ;
window.$ = $;
window.jQuery = $;
import 'signalr';
// 2. Store and Types. 
// 3. Scripts. 
import Credentials                                 from '../scripts/Credentials';
// 4. SignalR hubs.
import { AsteriskServer   , AsteriskCreateHub    } from './Asterisk'            ;
import { AvayaServer      , AvayaCreateHub       } from './Avaya'               ;
import { ChatServer       , ChatCreateHub        } from './Chat'                ;
import { TwilioServer     , TwilioCreateHub      } from './Twilio'              ;
import { TwitterServer    , TwitterCreateHub     } from './Twitter'             ;
import { PhoneBurnerServer, PhoneBurnerCreateHub } from './PhoneBurner'         ;

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

export class SignalRStore
{
	private bSignalRStarted   : boolean = false;
	public  asteriskManager   : any = null;
	public  avayaManager      : any = null;
	public  chatManager       : any = null;
	public  twilioManager     : any = null;
	public  twitterManager    : any = null;
	public  phoneBurnerManager: any = null;
	private history           : H.History<H.LocationState> = null;
	private SignalR_Command   : (sHubName: string, sCommandName: string, oCommandArguments: any) => void = null;

	public SetHistory(history)
	{
		this.history = history;
	}

	public Startup()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Startup', this.history);
		
		let sRemoteServer                 : string = Credentials.RemoteServer                  ;
		let sUSER_ID                      : string = Credentials.sUSER_ID                      ;
		let sUSER_EXTENSION               : string = Credentials.sUSER_EXTENSION               ;
		let sUSER_SMS_OPT_IN              : string = Credentials.sUSER_SMS_OPT_IN              ;
		let sUSER_PHONE_MOBILE            : string = Credentials.sUSER_PHONE_MOBILE            ;
		let sUSER_TWITTER_TRACKS          : string = Credentials.sUSER_TWITTER_TRACKS          ;
		let sUSER_CHAT_CHANNELS           : string = Credentials.sUSER_CHAT_CHANNELS           ;
		let dtPHONEBURNER_TOKEN_EXPIRES_AT: Date   = Credentials.dtPHONEBURNER_TOKEN_EXPIRES_AT;

		let signalR: SignalR = $.signalR;
		let proxies: any = {};
		signalR.hub = $.hubConnection(sRemoteServer + "signalr", { useDefaultPath: false, logging: true });
		signalR.hub.logging = true;
		signalR.hub.starting(function()
		{
			//console.log((new Date()).toISOString() + ' SignalRStore.Startup signalR.hub.starting');
			// Register the hub proxies as subscribed (instance, shouldSubscribe)
			registerHubProxies(proxies, true);

			this._registerSubscribedHubs();
		}).disconnected(function()
		{
			//console.log((new Date()).toISOString() + ' SignalRStore.Startup signalR.hub.disconnected');
			// Unsubscribe all hub proxies when we "disconnect".  This is to ensure that we do not re-add functional call backs. (instance, shouldSubscribe)
			registerHubProxies(proxies, false);
		});
		if ( AsteriskServer.enabled()    ) proxies.AsteriskManagerHub    = AsteriskCreateHub   (signalR, this.history);
		if ( AvayaServer.enabled()       ) proxies.AvayaManagerHub       = AvayaCreateHub      (signalR, this.history);
		if ( ChatServer.enabled()        ) proxies.ChatManagerHub        = ChatCreateHub       (signalR, this.history);
		if ( TwilioServer.enabled()      ) proxies.TwilioManagerHub      = TwilioCreateHub     (signalR, this.history);
		if ( TwitterServer.enabled()     ) proxies.TwitterManagerHub     = TwitterCreateHub    (signalR, this.history);
		if ( PhoneBurnerServer.enabled() ) proxies.PhoneBurnerManagerHub = PhoneBurnerCreateHub(signalR, this.history);
		$.extend(signalR, proxies);

		this.asteriskManager    = proxies.AsteriskManagerHub   ;
		this.avayaManager       = proxies.AvayaManagerHub      ;
		this.chatManager        = proxies.ChatManagerHub       ;
		this.twilioManager      = proxies.TwilioManagerHub     ;
		this.twitterManager     = proxies.TwitterManagerHub    ;
		this.phoneBurnerManager = proxies.PhoneBurnerManagerHub;

		//console.log('SignalR_Connection_Start');
		// 09/09/2020 Paul.  Add PhoneBurner SignalR support. 
		if ( (this.chatManager         && this.chatManager.server.shouldJoin       (sUSER_CHAT_CHANNELS                 ))
		  || (this.phoneBurnerManager  && this.phoneBurnerManager.server.shouldJoin(dtPHONEBURNER_TOKEN_EXPIRES_AT      ))
		  || (this.twitterManager      && this.twitterManager.server.shouldJoin    (sUSER_TWITTER_TRACKS                ))
		  || (this.asteriskManager     && this.asteriskManager.server.shouldJoin   (sUSER_EXTENSION                     ))
		  || (this.avayaManager        && this.avayaManager.server.shouldJoin      (sUSER_EXTENSION                     ))
		  || (this.twilioManager       && this.twilioManager.server.shouldJoin     (sUSER_PHONE_MOBILE, sUSER_SMS_OPT_IN))
		  )
		{
			let _this = this;
			// Start Connection
			// { transport: ['webSockets'] }
			// 09/17/2020 Paul.  Make sure to disable hub logging in the release build. 
			$.connection.hub.logging = true;
			$.connection.hub.start().done(function()
			{
				_this.bSignalRStarted = true;
				try
				{
					if ( _this.chatManager.server.shouldJoin(sUSER_CHAT_CHANNELS) )
					{
						console.log((new Date()).toISOString() + ' ' + 'SignalRStore.Startup ChatManager join', sUSER_CHAT_CHANNELS);
						_this.chatManager.server.joinGroup($.connection.hub.id, sUSER_CHAT_CHANNELS).done(function(result)
						{
						})
						.fail(function(e)
						{
							console.error((new Date()).toISOString() + ' SignalRStore.Startup chatManager.server.joinGroup', e);
						});
					}
					// 09/09/2020 Paul.  Add PhoneBurner SignalR support. 
					if ( _this.phoneBurnerManager && _this.phoneBurnerManager.server.shouldJoin(dtPHONEBURNER_TOKEN_EXPIRES_AT) )
					{
						console.log((new Date()).toISOString() + ' ' + 'SignalRStore.Startup PhoneBurner join', dtPHONEBURNER_TOKEN_EXPIRES_AT);
						_this.phoneBurnerManager.server.joinGroup($.connection.hub.id, sUSER_ID).done(function(result)
						{
						})
						.fail(function(e)
						{
							console.error((new Date()).toISOString() + ' SignalRStore.Startup phoneBurnerManager.server.joinGroup', e);
						});
					}
					if ( _this.twitterManager && _this.twitterManager.server.shouldJoin(sUSER_TWITTER_TRACKS) )
					{
						console.log((new Date()).toISOString() + ' ' + 'SignalRStore.Startup TwitterManager join', sUSER_TWITTER_TRACKS);
						_this.twitterManager.server.joinGroup($.connection.hub.id, sUSER_TWITTER_TRACKS).done(function(result)
						{
						})
						.fail(function(e)
						{
							console.error((new Date()).toISOString() + ' SignalRStore.Startup twitterManager.server.joinGroup', e);
						});
					}
					if ( _this.asteriskManager && _this.asteriskManager.server.shouldJoin(sUSER_EXTENSION) )
					{
						console.log((new Date()).toISOString() + ' ' + 'SignalRStore.Startup AsteriskManager join', sUSER_EXTENSION);
						_this.asteriskManager.server.joinGroup($.connection.hub.id, sUSER_EXTENSION).done(function(result)
						{
						})
						.fail(function(e)
						{
							console.error((new Date()).toISOString() + ' SignalRStore.Startup asteriskManager.server.joinGroup', e);
						});
					}
					if ( _this.avayaManager && _this.avayaManager.server.shouldJoin(sUSER_EXTENSION) )
					{
						console.log((new Date()).toISOString() + ' ' + 'SignalRStore.Startup AvayaManager join', sUSER_EXTENSION);
						_this.avayaManager.server.joinGroup($.connection.hub.id, sUSER_EXTENSION).done(function(result)
						{
						})
						.fail(function(e)
						{
							console.error((new Date()).toISOString() + ' SignalRStore.Startup avayaManager.server.joinGroup', e);
						});
					}
					if ( _this.twilioManager && _this.twilioManager.server.shouldJoin(sUSER_PHONE_MOBILE, sUSER_SMS_OPT_IN) )
					{
						console.log((new Date()).toISOString() + ' ' + 'SignalRStore.Startup TwilioManager join', sUSER_PHONE_MOBILE, sUSER_SMS_OPT_IN);
						_this.twilioManager.server.joinGroup($.connection.hub.id, sUSER_PHONE_MOBILE).done(function(result)
						{
						})
						.fail(function(e)
						{
							console.error((new Date()).toISOString() + ' SignalRStore.Startup twilioManager.server.joinGroup', e);
						});
					}
				}
				catch(e)
				{
					console.error((new Date()).toISOString() + ' SignalRStore.Startup', e);
				}
			});
		}
	}

	public Shutdown()
	{
		//console.log((new Date()).toISOString() + ' ' + this.constructor.name + '.Shutdown');
		if ( this.bSignalRStarted )
		{
			if ( this.asteriskManager    ) this.asteriskManager.Shutdown()   ;
			if ( this.avayaManager       ) this.avayaManager.Shutdown()      ;
			if ( this.chatManager        ) this.chatManager.Shutdown()       ;
			if ( this.twilioManager      ) this.twilioManager.Shutdown()     ;
			if ( this.twitterManager     ) this.twitterManager.Shutdown()    ;
			if ( this.phoneBurnerManager ) this.phoneBurnerManager.Shutdown();
			try
			{
				$.connection.hub.stop();
			}
			catch(e)
			{
				console.error((new Date()).toISOString() + ' SignalRStore.Shutdown', e);
			}
		}
	}
}

const signalrStore = new SignalRStore();
export default signalrStore;

