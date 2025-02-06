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

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for AuthorizeNetUtils.
	/// </summary>
	public class AuthorizeNetUtils
	{
		public static void UpdateCustomerProfile(HttpApplicationState Application, ref string sCARD_TOKEN, string sNAME, string sCREDIT_CARD_NUMBER, string sSECURITY_CODE, string sBANK_NAME, string sBANK_ROUTING_NUMBER, DateTime dtEXPIRATION_DATE, string sADDRESS_STREET, string sADDRESS_CITY, string sADDRESS_STATE, string sADDRESS_POSTALCODE, string sADDRESS_COUNTRY, string sEMAIL, string sPHONE)
		{
			throw(new Exception("Not Implemented"));
		}
	}
}

