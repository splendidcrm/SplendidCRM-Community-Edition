/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved."
 *********************************************************************************************************************/
using System;
using System.Web;
using System.Web.UI;
using System.Diagnostics;
using Microsoft.Owin;
using Owin;

[assembly: OwinStartup(typeof(SplendidCRM.SignalRUtils))]
namespace SplendidCRM
{
	/// <summary>
	/// Summary description for SignalRUtils.
	/// </summary>
	// 09/14/2020 Paul.  Convert to SignalR 2.4.1 
	// https://docs.microsoft.com/en-us/aspnet/signalr/overview/releases/upgrading-signalr-1x-projects-to-20
	public class SignalRUtils
	{
		public void Configuration(IAppBuilder app)
		{
			app.MapSignalR();
		}

		public static void InitApp()
		{
			//IDependencyResolver dependencyResolver = GlobalHost.DependencyResolver;
			//IHubPipeline hubPipeline = GlobalHost.HubPipeline;
			// Uncomment the following line to enable scale-out using SQL Server
			//dependencyResolver.UseSqlServer(System.Configuration.ConfigurationManager.ConnectionStrings["SignalRSamples"].ConnectionString);

			// Uncomment the following line to enable scale-out using Redis
			//var config = new RedisScaleoutConfiguration("127.0.0.1", 6379, "", "SignalRSamples");
			//config.RetryOnError = true;
			//dependencyResolver.UseRedis(config);
			//dependencyResolver.UseRedis("127.0.0.1", 6379, "", "SignalRSamples");

			// Uncomment the following line to enable scale-out using service bus
			//dependencyResolver.UseServiceBus("connection string", "Microsoft.AspNet.SignalR.Samples");

			//hubPipeline.AddModule(new SplendidPipelineModule());
			// Register the default hubs route /signalr
			
			//RouteTable.Routes.MapHubs("/signalr", new HubConfiguration() { EnableDetailedErrors = true } );
			try
			{
				// 12/02/2014 Paul.  Enable Cross Domain for the Mobile Client. 
				// 09/14/2020 Paul.  Convert to SignalR 2.4.1 
				//Microsoft.AspNet.SignalR.HubConfiguration config = new Microsoft.AspNet.SignalR.HubConfiguration();
				//config.EnableCrossDomain = true;
				//RouteTable.Routes.MapHubs(config);
			}
			catch(Exception ex)
			{
				Debug.WriteLine(ex.Message);
			}
		}

		public static void RegisterSignalR(ScriptManager mgrAjax)
		{
			if ( mgrAjax != null )
			{
				ScriptReference scrSignalR     = new ScriptReference("~/Include/javascript/jquery.signalR-2.4.1.min.js"  );
				ScriptReference scrSignalRHubs = new ScriptReference("~/signalr/hubs"                          );
				ScriptReference scrConnection  = new ScriptReference("~/Include/javascript/connection.start.js");
				if ( !mgrAjax.Scripts.Contains(scrSignalR    ) ) mgrAjax.Scripts.Add(scrSignalR    );
				if ( !mgrAjax.Scripts.Contains(scrSignalRHubs) ) mgrAjax.Scripts.Add(scrSignalRHubs);
				if ( !mgrAjax.Scripts.Contains(scrConnection ) ) mgrAjax.Scripts.Add(scrConnection );
			}
		}
	}
}

