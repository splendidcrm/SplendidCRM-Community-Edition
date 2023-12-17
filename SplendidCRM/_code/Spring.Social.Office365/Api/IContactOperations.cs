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
using System.IO;
using System.Collections.Generic;
using Spring.Rest.Client;
using Spring.Http;

namespace Spring.Social.Office365.Api
{
	public interface IContactOperations
	{
		ContactPagination GetContactsDelta(string   category, string stateToken, int nPageSize);
		IList<Contact>    GetModified     (string   category, DateTime startModifiedDate, int nPageSize);
		IList<Contact>    GetAll          (string   filter);
		int               GetCount        ();
		ContactPagination GetPage         (string   filter, string sort, int nPageOffset, int nPageSize);
		Contact           GetById         (string   id    );
		Contact           Insert          (Contact  obj   );
		Contact           Update          (Contact  obj   );
		void              Delete          (string   id    );
		// 11/22/2023 Paul.  When unsyncing, we need to immediately clear the remote flag. 
		void              Unsync          (string   id    , string sCONTACTS_CATEGORY);
	}
}
