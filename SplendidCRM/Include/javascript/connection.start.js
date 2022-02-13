// 09/20/2013 Paul.  Move EXTENSION to the main table. 
// http://www.asp.net/signalr/overview/hubs-api/hubs-api-guide-javascript-client

// 11/25/2014 Paul.  SignalR_Connection_Start() needs to be called outside of the ready event. 
function SignalR_Connection_Start()
{
	//console.log('SignalR_Connection_Start');
	// 09/09/2020 Paul.  Add PhoneBurner SignalR support. 
	if ( sUSER_PHONE_BURNER_GROUP.length > 0 || sUSER_EXTENSION.length > 0 || (sUSER_PHONE_MOBILE.length > 0 && sUSER_SMS_OPT_IN == 'yes') || sUSER_TWITTER_TRACKS.length > 0 || sUSER_CHAT_CHANNELS.length > 0 )
	{
		if ( sUSER_PHONE_BURNER_GROUP.length > 0 ) console.log('SignalR_Connection_Start sUSER_PHONE_BURNER_GROUP', sUSER_PHONE_BURNER_GROUP);
		if ( sUSER_EXTENSION.length          > 0 ) console.log('SignalR_Connection_Start sUSER_EXTENSION'         , sUSER_EXTENSION         );
		if ( sUSER_PHONE_MOBILE.length       > 0 ) console.log('SignalR_Connection_Start sUSER_PHONE_MOBILE'      , sUSER_PHONE_MOBILE      );
		if ( sUSER_TWITTER_TRACKS.length     > 0 ) console.log('SignalR_Connection_Start sUSER_TWITTER_TRACKS'    , sUSER_TWITTER_TRACKS    );
		if ( sUSER_CHAT_CHANNELS.length      > 0 ) console.log('SignalR_Connection_Start sUSER_CHAT_CHANNELS'     , sUSER_CHAT_CHANNELS     );
		// Start Connection
		// { transport: ['webSockets'] }
		// 09/17/2020 Paul.  Make sure to disable hub logging in the release build. 
		$.connection.hub.logging = true;
		$.connection.hub.start().done(function()
		{
			try
			{
				if ( sUSER_PHONE_MOBILE.length > 0 && sUSER_SMS_OPT_IN == 'yes' && twilioManager !== undefined )
				{
					twilioManager.server.joinGroup($.connection.hub.id, sUSER_PHONE_MOBILE).done(function(result)
					{
						//TwilioStatusDialog('Twilio Join', result);
					})
					.fail(function(e)
					{
					});
				}
			}
			catch(e)
			{
			}
			try
			{
				if ( sUSER_EXTENSION.length > 0 && asteriskManager !== undefined )
				{
					asteriskManager.server.joinGroup($.connection.hub.id, sUSER_EXTENSION).done(function(result)
					{
						//AsteriskStatusDialog('Asterisk Join', result);
					})
					.fail(function(e)
					{
					});
				}
			}
			catch(e)
			{
			}
			try
			{
				if ( sUSER_EXTENSION.length > 0 && avayaManager !== undefined )
				{
					avayaManager.server.joinGroup($.connection.hub.id, sUSER_EXTENSION).done(function(result)
					{
						//AvayaStatusDialog('Avaya Join', result);
					})
					.fail(function(e)
					{
					});
				}
			}
			catch(e)
			{
			}
			try
			{
				if ( sUSER_TWITTER_TRACKS.length > 0 && twitterManager !== undefined )
				{
					twitterManager.server.joinGroup($.connection.hub.id, sUSER_TWITTER_TRACKS).done(function(result)
					{
						//var divMyTwitterTracks = document.getElementById('divMyTwitterTracks');
						//divMyTwitterTracks.innerHTML = result;
					})
					.fail(function(e)
					{
					});
				}
			}
			catch(e)
			{
			}
			try
			{
				if ( sUSER_CHAT_CHANNELS.length > 0 && chatManager !== undefined )
				{
					chatManager.server.joinGroup($.connection.hub.id, sUSER_CHAT_CHANNELS).done(function(result)
					{
						//var divMyChatChannels = document.getElementById('divMyChatChannels');
						//divMyChatChannels.innerHTML = result;
					})
					.fail(function(e)
					{
					});
				}
			}
			catch(e)
			{
			}
			// 09/09/2020 Paul.  Add PhoneBurner SignalR support. 
			try
			{
				if ( sUSER_PHONE_BURNER_GROUP.length > 0 && phoneBurnerManager !== undefined )
				{
					phoneBurnerManager.server.joinGroup($.connection.hub.id, sUSER_PHONE_BURNER_GROUP).done(function(result)
					{
					})
					.fail(function(e)
					{
					});
				}
			}
			catch(e)
			{
			}
		});
	}
}

function SignalR_Connection_Stop()
{
	// 09/09/2020 Paul.  Add PhoneBurner SignalR support. 
	if ( sUSER_PHONE_BURNER_GROUP.length > 0 || sUSER_EXTENSION.length > 0 || (sUSER_PHONE_MOBILE.length > 0 && sUSER_SMS_OPT_IN == 'yes') || sUSER_TWITTER_TRACKS.length > 0 || sUSER_CHAT_CHANNELS.length > 0 )
	{
		$.connection.hub.stop();
	}
}

$(document).ready(function()
{
	SignalR_Connection_Start();
});

