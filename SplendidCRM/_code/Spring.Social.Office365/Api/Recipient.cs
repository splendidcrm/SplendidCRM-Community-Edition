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
	public class Recipient
	{
		public String         ODataType      { get; set; }
		public EmailAddress   EmailAddress   { get; set; }
		public AdditionalData AdditionalData { get; set; }

		public Recipient()
		{
			this.ODataType = "microsoft.graph.recipient";
		}

		public Recipient(string sName, string sAddress)
		{
			this.EmailAddress = new EmailAddress(sName, sAddress);
		}

		public override string ToString()
		{
			string s = String.Empty;
			if ( this.EmailAddress != null )
			{
				if ( Sql.IsEmptyString(this.EmailAddress.Address) )
					s = this.EmailAddress.Name;
				else if ( Sql.IsEmptyString(this.EmailAddress.Name) )
					s = this.EmailAddress.Address;
				else
				{
					// 06/26/2015 Paul.  We do not want to display the Exchange address. 
					if ( this.EmailAddress.Address.StartsWith("/") )
						s = this.EmailAddress.Name;
					else
					{
						// 06/26/2015 Paul.  We are going to encode in the UI. 
						s = String.Format("{0} <{1}>", this.EmailAddress.Name, this.EmailAddress.Address);
					}
				}
			}
			return String.Empty;
		}
	}
}
