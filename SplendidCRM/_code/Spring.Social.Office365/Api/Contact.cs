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
	[Serializable]
	public class Contact : OutlookItem
	{
		#region Properties
		public String              AssistantName    { get; set; }
		public DateTimeOffset?     Birthday         { get; set; }
		public PhysicalAddress     BusinessAddress  { get; set; }
		public String              BusinessHomePage { get; set; }
		public IList<String>       BusinessPhones   { get; set; }
		public IList<String>       Children         { get; set; }
		public String              CompanyName      { get; set; }
		public String              Department       { get; set; }
		public String              DisplayName      { get; set; }
		public IList<EmailAddress> EmailAddresses   { get; set; }
		public String              FileAs           { get; set; }
		public String              Generation       { get; set; }
		public String              GivenName        { get; set; }
		public PhysicalAddress     HomeAddress      { get; set; }
		public IList<String>       HomePhones       { get; set; }
		public IList<String>       ImAddresses      { get; set; }
		public String              Initials         { get; set; }
		public String              JobTitle         { get; set; }
		public String              Manager          { get; set; }
		public String              MiddleName       { get; set; }
		public String              MobilePhone      { get; set; }
		public String              NickName         { get; set; }
		public String              OfficeLocation   { get; set; }
		public PhysicalAddress     OtherAddress     { get; set; }
		public String              ParentFolderId   { get; set; }
		public String              PersonalNotes    { get; set; }
		public String              Profession       { get; set; }
		public String              SpouseName       { get; set; }
		public String              Surname          { get; set; }
		public String              Title            { get; set; }
		public String              YomiCompanyName  { get; set; }
		public String              YomiGivenName    { get; set; }
		public String              YomiSurname      { get; set; }
		public ProfilePhoto        Photo            { get; set; }
		//public IContactExtensionsCollectionPage Extensions { get; set; }
		//public IContactMultiValueExtendedPropertiesCollectionPage MultiValueExtendedProperties { get; set; }
		//public IContactSingleValueExtendedPropertiesCollectionPage SingleValueExtendedProperties { get; set; }
		#endregion

		public Contact()
		{
			this.ODataType = "microsoft.graph.contact";
		}

		public static DataTable CreateTable()
		{
			DataTable dt = new DataTable();
			dt.Columns.Add("id"                      , Type.GetType("System.String"  ));
			return dt;
		}

		public void SetRow(DataRow row)
		{
			for ( int i = 0; i < row.Table.Columns.Count; i++ )
			{
				row[i] = DBNull.Value;
			}
			row["id"  ] = this.Id;
		}

		public static DataRow ConvertToRow(Contact obj)
		{
			DataTable dt = Contact.CreateTable();
			DataRow row = dt.NewRow();
			obj.SetRow(row);
			return row;
		}

		public static DataTable ConvertToTable(IList<Contact> contacts)
		{
			DataTable dt = Contact.CreateTable();
			if ( contacts != null )
			{
				foreach ( Contact contact in contacts )
				{
					DataRow row = dt.NewRow();
					dt.Rows.Add(row);
					contact.SetRow(row);
				}
			}
			return dt;
		}
	}

	public class ContactPagination
	{
		public IList<Contact> contacts       { get; set; }
		public int            count          { get; set; }
		public String         nextLink       { get; set; }
		public String         deltaLink      { get; set; }
	}
}
