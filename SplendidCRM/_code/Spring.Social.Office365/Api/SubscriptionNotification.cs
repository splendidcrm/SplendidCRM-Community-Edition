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
using System.Data;
using System.Text;
using System.Collections.Generic;
using System.Collections.Specialized;
using Spring.Json;

namespace Spring.Social.Office365.Api
{
	public class SubscriptionNotification
	{
		public string       RawContent                     { get; set; }
		public String       SubscriptionId                 { get; set; }
		public DateTime     SubscriptionExpirationDateTime { get; set; }
		public String       ChangeType                     { get; set; }
		public String       LifecycleEvent                 { get; set; }
		public String       Resource                       { get; set; }
		public String       ClientState                    { get; set; }
		public String       TenantId                       { get; set; }
		public ResourceData ResourceData                   { get; set; }

		public override string ToString()
		{
			StringBuilder sb = new StringBuilder();
			sb.AppendLine("SubscriptionNotification");
			sb.AppendLine("   subscriptionId: " + this.SubscriptionId);
			sb.AppendLine("   changeType    : " + this.ChangeType    );
			sb.AppendLine("   lifecycleEvent: " + this.LifecycleEvent);
			sb.AppendLine("   clientState   : " + this.ClientState   );
			sb.AppendLine("   resource      : " + this.Resource      );
			sb.AppendLine("   ODataType     : " + this.ResourceData.ODataType);
			return sb.ToString();
		}
	}

	public class SubscriptionNotificationBody
	{
		public IList<SubscriptionNotification> values      { get; set; }
	}
}
