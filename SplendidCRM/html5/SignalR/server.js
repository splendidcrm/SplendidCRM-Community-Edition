/*!
 * ASP.NET SignalR JavaScript Library v1.1.3
 * http://signalr.net/
 *
 * Copyright Microsoft Open Technologies, Inc. All rights reserved.
 * Licensed under the Apache 2.0
 * https://github.com/SignalR/SignalR/blob/master/LICENSE.md
 *
 */

/// reference path="..\..\SignalR.Client.JS\Scripts\jquery-1.6.4.js" 
/// reference path="jquery.signalR.js" 
(function ($, window) {
    /// <param name="$" type="jQuery" />
    "use strict";

    if (typeof ($.signalR) !== "function") {
        throw new Error("SignalR: SignalR is not loaded. Please ensure jquery.signalR-x.js is referenced before ~/signalr/hubs.");
    }

    var signalR = $.signalR;

    function makeProxyCallback(hub, callback) {
        return function () {
            // Call the client hub method
            callback.apply(hub, $.makeArray(arguments));
        };
    }

    function registerHubProxies(instance, shouldSubscribe) {
        var key, hub, memberKey, memberValue, subscriptionMethod;

        for (key in instance) {
            if (instance.hasOwnProperty(key)) {
                hub = instance[key];

                if (!(hub.hubName)) {
                    // Not a client hub
                    continue;
                }

                if (shouldSubscribe) {
                    // We want to subscribe to the hub events
                    subscriptionMethod = hub.on;
                }
                else {
                    // We want to unsubscribe from the hub events
                    subscriptionMethod = hub.off;
                }

                // Loop through all members on the hub and find client hub functions to subscribe/unsubscribe
                for (memberKey in hub.client) {
                    if (hub.client.hasOwnProperty(memberKey)) {
                        memberValue = hub.client[memberKey];

                        if (!$.isFunction(memberValue)) {
                            // Not a client hub function
                            continue;
                        }

                        subscriptionMethod.call(hub, memberKey, makeProxyCallback(hub, memberValue));
                    }
                }
            }
        }
    }

    $.hubConnection.prototype.createHubProxies = function () {
        var proxies = {};
        this.starting(function () {
            // Register the hub proxies as subscribed
            // (instance, shouldSubscribe)
            registerHubProxies(proxies, true);

            this._registerSubscribedHubs();
        }).disconnected(function () {
            // Unsubscribe all hub proxies when we "disconnect".  This is to ensure that we do not re-add functional call backs.
            // (instance, shouldSubscribe)
            registerHubProxies(proxies, false);
        });

        proxies.AsteriskManagerHub = this.createHubProxy('AsteriskManagerHub'); 
        proxies.AsteriskManagerHub.client = { };
        proxies.AsteriskManagerHub.server = {
            createCall: function (sUniqueId) {
            /// <summary>Calls the CreateCall method on the server-side AsteriskManagerHub hub.&#10;Returns a jQuery.Deferred() promise.</summary>
            /// <param name=\"sUniqueId\" type=\"String\">Server side type is System.String</param>
                return proxies.AsteriskManagerHub.invoke.apply(proxies.AsteriskManagerHub, $.merge(["CreateCall"], $.makeArray(arguments)));
             },

            joinGroup: function (sConnectionId, sGroupName) {
            /// <summary>Calls the JoinGroup method on the server-side AsteriskManagerHub hub.&#10;Returns a jQuery.Deferred() promise.</summary>
            /// <param name=\"sConnectionId\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sGroupName\" type=\"String\">Server side type is System.String</param>
                return proxies.AsteriskManagerHub.invoke.apply(proxies.AsteriskManagerHub, $.merge(["JoinGroup"], $.makeArray(arguments)));
             },

            originateCall: function (sUSER_EXTENSION, sUSER_FULL_NAME, sUSER_PHONE_WORK, sPHONE, sPARENT_ID, sPARENT_TYPE) {
            /// <summary>Calls the OriginateCall method on the server-side AsteriskManagerHub hub.&#10;Returns a jQuery.Deferred() promise.</summary>
            /// <param name=\"sUSER_EXTENSION\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sUSER_FULL_NAME\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sUSER_PHONE_WORK\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sPHONE\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sPARENT_ID\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sPARENT_TYPE\" type=\"String\">Server side type is System.String</param>
                return proxies.AsteriskManagerHub.invoke.apply(proxies.AsteriskManagerHub, $.merge(["OriginateCall"], $.makeArray(arguments)));
             }
        };

        proxies.AvayaManagerHub = this.createHubProxy('AvayaManagerHub'); 
        proxies.AvayaManagerHub.client = { };
        proxies.AvayaManagerHub.server = {
            createCall: function (sUniqueId) {
            /// <summary>Calls the CreateCall method on the server-side AvayaManagerHub hub.&#10;Returns a jQuery.Deferred() promise.</summary>
            /// <param name=\"sUniqueId\" type=\"String\">Server side type is System.String</param>
                return proxies.AvayaManagerHub.invoke.apply(proxies.AvayaManagerHub, $.merge(["CreateCall"], $.makeArray(arguments)));
             },

            joinGroup: function (sConnectionId, sGroupName) {
            /// <summary>Calls the JoinGroup method on the server-side AvayaManagerHub hub.&#10;Returns a jQuery.Deferred() promise.</summary>
            /// <param name=\"sConnectionId\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sGroupName\" type=\"String\">Server side type is System.String</param>
                return proxies.AvayaManagerHub.invoke.apply(proxies.AvayaManagerHub, $.merge(["JoinGroup"], $.makeArray(arguments)));
             },

            originateCall: function (sUSER_EXTENSION, sUSER_FULL_NAME, sUSER_PHONE_WORK, sPHONE, sPARENT_ID, sPARENT_TYPE) {
            /// <summary>Calls the OriginateCall method on the server-side AvayaManagerHub hub.&#10;Returns a jQuery.Deferred() promise.</summary>
            /// <param name=\"sUSER_EXTENSION\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sUSER_FULL_NAME\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sUSER_PHONE_WORK\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sPHONE\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sPARENT_ID\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sPARENT_TYPE\" type=\"String\">Server side type is System.String</param>
                return proxies.AvayaManagerHub.invoke.apply(proxies.AvayaManagerHub, $.merge(["OriginateCall"], $.makeArray(arguments)));
             }
        };

        proxies.ChatManagerHub = this.createHubProxy('ChatManagerHub'); 
        proxies.ChatManagerHub.client = { };
        proxies.ChatManagerHub.server = {
            joinGroup: function (sConnectionId, sGroupName) {
            /// <summary>Calls the JoinGroup method on the server-side ChatManagerHub hub.&#10;Returns a jQuery.Deferred() promise.</summary>
            /// <param name=\"sConnectionId\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sGroupName\" type=\"String\">Server side type is System.String</param>
                return proxies.ChatManagerHub.invoke.apply(proxies.ChatManagerHub, $.merge(["JoinGroup"], $.makeArray(arguments)));
             }
        };

        proxies.TwilioManagerHub = this.createHubProxy('TwilioManagerHub'); 
        proxies.TwilioManagerHub.client = { };
        proxies.TwilioManagerHub.server = {
            createSmsMessage: function (sMESSAGE_SID, sFROM_NUMBER, sTO_NUMBER, sSUBJECT) {
            /// <summary>Calls the CreateSmsMessage method on the server-side TwilioManagerHub hub.&#10;Returns a jQuery.Deferred() promise.</summary>
            /// <param name=\"sMESSAGE_SID\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sFROM_NUMBER\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sTO_NUMBER\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sSUBJECT\" type=\"String\">Server side type is System.String</param>
                return proxies.TwilioManagerHub.invoke.apply(proxies.TwilioManagerHub, $.merge(["CreateSmsMessage"], $.makeArray(arguments)));
             },

            joinGroup: function (sConnectionId, sGroupName) {
            /// <summary>Calls the JoinGroup method on the server-side TwilioManagerHub hub.&#10;Returns a jQuery.Deferred() promise.</summary>
            /// <param name=\"sConnectionId\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sGroupName\" type=\"String\">Server side type is System.String</param>
                return proxies.TwilioManagerHub.invoke.apply(proxies.TwilioManagerHub, $.merge(["JoinGroup"], $.makeArray(arguments)));
             }
        };

        proxies.TwitterManagerHub = this.createHubProxy('TwitterManagerHub'); 
        proxies.TwitterManagerHub.client = { };
        proxies.TwitterManagerHub.server = {
            joinGroup: function (sConnectionId, sGroupName) {
            /// <summary>Calls the JoinGroup method on the server-side TwitterManagerHub hub.&#10;Returns a jQuery.Deferred() promise.</summary>
            /// <param name=\"sConnectionId\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sGroupName\" type=\"String\">Server side type is System.String</param>
                return proxies.TwitterManagerHub.invoke.apply(proxies.TwitterManagerHub, $.merge(["JoinGroup"], $.makeArray(arguments)));
             }
        };

        // 09/09/2020 Paul.  Add PhoneBurner SignalR support. 
        proxies.PhoneBurnerManagerHub = this.createHubProxy('PhoneBurnerManagerHub'); 
        proxies.PhoneBurnerManagerHub.client = { };
        proxies.PhoneBurnerManagerHub.server = {
            joinGroup: function (sConnectionId, sGroupName) {
            /// <summary>Calls the JoinGroup method on the server-side PhoneBurnerManagerHub hub.&#10;Returns a jQuery.Deferred() promise.</summary>
            /// <param name=\"sConnectionId\" type=\"String\">Server side type is System.String</param>
            /// <param name=\"sGroupName\" type=\"String\">Server side type is System.String</param>
                return proxies.PhoneBurnerManagerHub.invoke.apply(proxies.PhoneBurnerManagerHub, $.merge(["JoinGroup"], $.makeArray(arguments)));
             }
        };

        return proxies;
    };

	// 09/13/2020 Paul.  We need to correct the path to the signalr services. 
	var baseUrl = '/';
	if (document.getElementsByTagName('base')[0])
	{
		baseUrl = document.getElementsByTagName('base')[0].getAttribute('href');
		baseUrl = baseUrl.replace('/React', '');
	}
    signalR.hub = $.hubConnection(baseUrl + "signalr", { useDefaultPath: false });
    $.extend(signalR, signalR.hub.createHubProxies());

}(window.jQuery, window));
