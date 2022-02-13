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
using System.Net.Mail;

namespace SplendidCRM
{
	// 01/17/2017 Paul.  New SplendidMailClient object to encapsulate SMTP, Exchange and Google mail. 
	abstract public class SplendidMailClient
	{
		abstract public void Send(MailMessage mail);

		// 01/18/2017 Paul.  This method will return the appropriate Campaign Manager client, based on configuration. This is the global email sending account. 
		public static SplendidMailClient CreateMailClient(HttpApplicationState Application)
		{
			string sMAIL_SENDTYPE = Sql.ToString(Application["CONFIG.mail_sendtype"]);
			SplendidMailClient client = null;
			if ( String.Compare(sMAIL_SENDTYPE, "Office365", true) == 0 )
			{
				client = new SplendidMailOffice365(Application, ExchangeUtils.EXCHANGE_ID);
			}
			// 01/31/2017 Paul.  Add support for Exchange using Username/Password. 
			else if ( String.Compare(sMAIL_SENDTYPE, "Exchange-Password", true) == 0 )
			{
				client = new SplendidMailExchangePassword(Application);
			}
			else if ( String.Compare(sMAIL_SENDTYPE, "GoogleApps", true) == 0 )
			{
				client = new SplendidMailGmail(Application, EmailUtils.CAMPAIGN_MANAGER_ID);
			}
			else
			{
				client = new SplendidMailSmtp(Application);
			}
			return client;
		}
	}
}
