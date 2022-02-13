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
using Spring.Social.OAuth1;
using Spring.Social.QuickBooks.Api;

namespace Spring.Social.QuickBooks.Connect
{
	public class QuickBooksServiceProvider : AbstractOAuth1ServiceProvider<IQuickBooks>
	{
		public QuickBooksServiceProvider(string consumerKey, string consumerSecret)
			: base(consumerKey, consumerSecret, new OAuth1Template(consumerKey, consumerSecret,
				"https://oauth.intuit.com/oauth/v1/get_request_token", 
				"https://workplace.intuit.com/Connect/Begin", 
				"https://appcenter.intuit.com/api/v1/authenticate", 
				"https://oauth.intuit.com/oauth/v1/get_access_token"))
		{
		}

		public override IQuickBooks GetApi(string accessToken, string secret)
		{
			throw(new Exception("GetApi requires a CompanyId"));
		}

		public IQuickBooks GetApi(string accessToken, string secret, string companyId)
		{
			throw(new Exception("Not implemented"));
		}
	}
}
