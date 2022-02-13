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
using System.Data;
using System.Data.Common;
using System.Data.Odbc;
using System.Data.OleDb;
using System.Text;
using System.Xml;
using System.Web;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for SocialImport.
	/// </summary>
	public class SocialImport
	{
		// 04/10/2012 Paul.  LinkedIn import. 
		public static DataTable CreateTable(Spring.Social.LinkedIn.Api.LinkedInFullProfiles connections, bool bShortStateName, bool bShortCountryName)
		{
			DataTable dt = new DataTable();
			dt.Columns.Add("SOCIAL_ID"                 , Type.GetType("System.String"));
			dt.Columns.Add("FIRST_NAME"                , Type.GetType("System.String"));
			dt.Columns.Add("LAST_NAME"                 , Type.GetType("System.String"));
			dt.Columns.Add("TITLE"                     , Type.GetType("System.String"));
			dt.Columns.Add("ACCOUNT_NAME"              , Type.GetType("System.String"));
			dt.Columns.Add("INDUSTRY"                  , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_STREET"    , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_CITY"      , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_STATE"     , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_POSTALCODE", Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_COUNTRY"   , Type.GetType("System.String"));
			dt.Columns.Add("PHONE_WORK"                , Type.GetType("System.String"));
			dt.Columns.Add("PHONE_MOBILE"              , Type.GetType("System.String"));
			dt.Columns.Add("PHONE_HOME"                , Type.GetType("System.String"));
			dt.Columns.Add("DESCRIPTION"               , Type.GetType("System.String"));
			dt.Columns.Add("WEBSITE"                   , Type.GetType("System.String"));

			foreach ( Spring.Social.LinkedIn.Api.LinkedInFullProfile connection in connections.Profiles )
			{
				string sSOCIAL_ID                  = connection.ID         ;
				string sFIRST_NAME                 = connection.FirstName  ;
				string sLAST_NAME                  = connection.LastName   ;
				string sTITLE                      = String.Empty;
				string sACCOUNT_NAME               = String.Empty;
				string sINDUSTRY                   = connection.Industry   ;
				string sMAIN_ADDRESS               = connection.MainAddress;
				string sPRIMARY_ADDRESS_STREET     = String.Empty;
				string sPRIMARY_ADDRESS_CITY       = String.Empty;
				string sPRIMARY_ADDRESS_STATE      = String.Empty;
				string sPRIMARY_ADDRESS_POSTALCODE = String.Empty;
				string sPRIMARY_ADDRESS_COUNTRY    = connection.CountryCode;
				string sPHONE_WORK                 = String.Empty;
				string sPHONE_MOBILE               = String.Empty;
				string sPHONE_HOME                 = String.Empty;
				string sDESCRIPTION                = String.Empty;
				string sWEBSITE                    = String.Empty;
				
				if ( !Sql.IsEmptyString(sMAIN_ADDRESS) )
				{
					sMAIN_ADDRESS += ControlChars.CrLf + sPRIMARY_ADDRESS_COUNTRY;
					AddressDetails info = new AddressDetails();
					GoogleUtils.ConvertAddressV3(sMAIN_ADDRESS, bShortStateName, bShortCountryName, ref info);
					sPRIMARY_ADDRESS_STREET     = info.ADDRESS_STREET    ;
					sPRIMARY_ADDRESS_CITY       = info.ADDRESS_CITY      ;
					sPRIMARY_ADDRESS_STATE      = info.ADDRESS_STATE     ;
					sPRIMARY_ADDRESS_POSTALCODE = info.ADDRESS_POSTALCODE;
					sPRIMARY_ADDRESS_COUNTRY    = info.ADDRESS_COUNTRY   ;
				}
				
				if ( connection.PhoneNumbers != null )
				{
					foreach ( Spring.Social.LinkedIn.Api.PhoneNumber phone in connection.PhoneNumbers )
					{
						string sPHONE_TYPE   = phone.Type  ;
						string sPHONE_NUMBER = phone.Number;
						switch ( sPHONE_TYPE )
						{
							case "home"  :  sPHONE_HOME   = sPHONE_NUMBER;  break;
							case "work"  :  sPHONE_WORK   = sPHONE_NUMBER;  break;
							case "mobile":  sPHONE_MOBILE = sPHONE_NUMBER;  break;
						}
					}
				}
				if ( connection.Positions != null )
				{
					// 04/08/2012 Paul.  Assume that the first current position is the main company. 
					foreach ( Spring.Social.LinkedIn.Api.Position position in connection.Positions )
					{
						if ( position.IsCurrent )
						{
							sTITLE        = position.Title  ;
							sDESCRIPTION  = position.Summary;
							sACCOUNT_NAME = (position.Company != null ? position.Company.Name : String.Empty);
							break;
						}
					}
				}
				
				DataRow row = dt.NewRow();
				row["SOCIAL_ID"                 ] = Sql.ToDBString(sSOCIAL_ID                 );
				row["FIRST_NAME"                ] = Sql.ToDBString(sFIRST_NAME                );
				row["LAST_NAME"                 ] = Sql.ToDBString(sLAST_NAME                 );
				row["TITLE"                     ] = Sql.ToDBString(sTITLE                     );
				row["ACCOUNT_NAME"              ] = Sql.ToDBString(sACCOUNT_NAME              );
				row["INDUSTRY"                  ] = Sql.ToDBString(sINDUSTRY                  );
				row["PRIMARY_ADDRESS_STREET"    ] = Sql.ToDBString(sPRIMARY_ADDRESS_STREET    );
				row["PRIMARY_ADDRESS_CITY"      ] = Sql.ToDBString(sPRIMARY_ADDRESS_CITY      );
				row["PRIMARY_ADDRESS_STATE"     ] = Sql.ToDBString(sPRIMARY_ADDRESS_STATE     );
				row["PRIMARY_ADDRESS_POSTALCODE"] = Sql.ToDBString(sPRIMARY_ADDRESS_POSTALCODE);
				row["PRIMARY_ADDRESS_COUNTRY"   ] = Sql.ToDBString(sPRIMARY_ADDRESS_COUNTRY   );
				row["PHONE_WORK"                ] = Sql.ToDBString(sPHONE_WORK                );
				row["PHONE_MOBILE"              ] = Sql.ToDBString(sPHONE_MOBILE              );
				row["PHONE_HOME"                ] = Sql.ToDBString(sPHONE_HOME                );
				row["DESCRIPTION"               ] = Sql.ToDBString(sDESCRIPTION               );
				row["WEBSITE"                   ] = Sql.ToDBString(sWEBSITE                   );
				dt.Rows.Add(row);
			}
			return dt;
		}

		public static DataTable ConvertXmlToTable(string sXML, bool bShortStateName, bool bShortCountryName)
		{
			DataTable dt = new DataTable();
			dt.Columns.Add("SOCIAL_ID"                 , Type.GetType("System.String"));
			dt.Columns.Add("FIRST_NAME"                , Type.GetType("System.String"));
			dt.Columns.Add("LAST_NAME"                 , Type.GetType("System.String"));
			dt.Columns.Add("TITLE"                     , Type.GetType("System.String"));
			dt.Columns.Add("ACCOUNT_NAME"              , Type.GetType("System.String"));
			dt.Columns.Add("INDUSTRY"                  , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_STREET"    , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_CITY"      , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_STATE"     , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_POSTALCODE", Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_COUNTRY"   , Type.GetType("System.String"));
			dt.Columns.Add("PHONE_WORK"                , Type.GetType("System.String"));
			dt.Columns.Add("PHONE_MOBILE"              , Type.GetType("System.String"));
			dt.Columns.Add("PHONE_HOME"                , Type.GetType("System.String"));
			dt.Columns.Add("DESCRIPTION"               , Type.GetType("System.String"));
			dt.Columns.Add("WEBSITE"                   , Type.GetType("System.String"));

			XmlDocument xml = new XmlDocument();
			// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
			// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
			// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
			xml.XmlResolver = null;
			xml.LoadXml(sXML);
			XmlNodeList nlPersons = xml.DocumentElement.SelectNodes("person");
			foreach ( XmlNode xPerson in nlPersons )
			{
				string sSOCIAL_ID                  = XmlUtil.SelectSingleNode(xPerson, "id"          );
				string sFIRST_NAME                 = XmlUtil.SelectSingleNode(xPerson, "first-name"  );
				string sLAST_NAME                  = XmlUtil.SelectSingleNode(xPerson, "last-name"   );
				string sTITLE                      = String.Empty;
				string sACCOUNT_NAME               = String.Empty;
				string sINDUSTRY                   = XmlUtil.SelectSingleNode(xPerson, "industry"    );
				string sMAIN_ADDRESS               = XmlUtil.SelectSingleNode(xPerson, "main-address");
				string sPRIMARY_ADDRESS_STREET     = String.Empty;
				string sPRIMARY_ADDRESS_CITY       = String.Empty;
				string sPRIMARY_ADDRESS_STATE      = String.Empty;
				string sPRIMARY_ADDRESS_POSTALCODE = String.Empty;
				string sPRIMARY_ADDRESS_COUNTRY    = XmlUtil.SelectSingleNode(xPerson, "location/country/code");
				string sPHONE_WORK                 = String.Empty;
				string sPHONE_MOBILE               = String.Empty;
				string sPHONE_HOME                 = String.Empty;
				string sDESCRIPTION                = String.Empty;
				string sWEBSITE                    = String.Empty;
				
				if ( !Sql.IsEmptyString(sMAIN_ADDRESS) )
				{
					sMAIN_ADDRESS += ControlChars.CrLf + sPRIMARY_ADDRESS_COUNTRY;
					AddressDetails info = new AddressDetails();
					GoogleUtils.ConvertAddressV3(sMAIN_ADDRESS, bShortStateName, bShortCountryName, ref info);
					sPRIMARY_ADDRESS_STREET     = info.ADDRESS_STREET    ;
					sPRIMARY_ADDRESS_CITY       = info.ADDRESS_CITY      ;
					sPRIMARY_ADDRESS_STATE      = info.ADDRESS_STATE     ;
					sPRIMARY_ADDRESS_POSTALCODE = info.ADDRESS_POSTALCODE;
					sPRIMARY_ADDRESS_COUNTRY    = info.ADDRESS_COUNTRY   ;
				}
				
				XmlNodeList nlPhoneNumbers = xPerson.SelectNodes("phone-numbers/phone-number");
				foreach ( XmlNode xPhoneNumber in nlPhoneNumbers )
				{
					string sPHONE_TYPE   = XmlUtil.SelectSingleNode(xPhoneNumber, "phone-type"  );
					string sPHONE_NUMBER = XmlUtil.SelectSingleNode(xPhoneNumber, "phone-number");
					switch ( sPHONE_TYPE )
					{
						case "home"  :  sPHONE_HOME   = sPHONE_NUMBER;  break;
						case "work"  :  sPHONE_WORK   = sPHONE_NUMBER;  break;
						case "mobile":  sPHONE_MOBILE = sPHONE_NUMBER;  break;
					}
				}
				// 04/08/2012 Paul.  Assume that the first current position is the main company. 
				XmlNodeList nlPositions = xPerson.SelectNodes("positions/position");
				foreach ( XmlNode xPosition in nlPositions )
				{
					if ( Sql.ToBoolean(XmlUtil.SelectSingleNode(xPosition, "is-current")) )
					{
						sTITLE        = XmlUtil.SelectSingleNode(xPosition, "title"       );
						sDESCRIPTION  = XmlUtil.SelectSingleNode(xPosition, "summary"     );
						sACCOUNT_NAME = XmlUtil.SelectSingleNode(xPosition, "company/name");
						break;
					}
				}
				
				DataRow row = dt.NewRow();
				row["SOCIAL_ID"                 ] = Sql.ToDBString(sSOCIAL_ID                 );
				row["FIRST_NAME"                ] = Sql.ToDBString(sFIRST_NAME                );
				row["LAST_NAME"                 ] = Sql.ToDBString(sLAST_NAME                 );
				row["TITLE"                     ] = Sql.ToDBString(sTITLE                     );
				row["ACCOUNT_NAME"              ] = Sql.ToDBString(sACCOUNT_NAME              );
				row["INDUSTRY"                  ] = Sql.ToDBString(sINDUSTRY                  );
				row["PRIMARY_ADDRESS_STREET"    ] = Sql.ToDBString(sPRIMARY_ADDRESS_STREET    );
				row["PRIMARY_ADDRESS_CITY"      ] = Sql.ToDBString(sPRIMARY_ADDRESS_CITY      );
				row["PRIMARY_ADDRESS_STATE"     ] = Sql.ToDBString(sPRIMARY_ADDRESS_STATE     );
				row["PRIMARY_ADDRESS_POSTALCODE"] = Sql.ToDBString(sPRIMARY_ADDRESS_POSTALCODE);
				row["PRIMARY_ADDRESS_COUNTRY"   ] = Sql.ToDBString(sPRIMARY_ADDRESS_COUNTRY   );
				row["PHONE_WORK"                ] = Sql.ToDBString(sPHONE_WORK                );
				row["PHONE_MOBILE"              ] = Sql.ToDBString(sPHONE_MOBILE              );
				row["PHONE_HOME"                ] = Sql.ToDBString(sPHONE_HOME                );
				row["DESCRIPTION"               ] = Sql.ToDBString(sDESCRIPTION               );
				row["WEBSITE"                   ] = Sql.ToDBString(sWEBSITE                   );
				dt.Rows.Add(row);
			}
			return dt;
		}

		// 04/12/2012 Paul.  Twitter import. 
		public static DataTable CreateTable(Spring.Social.Twitter.Api.CursoredList<Spring.Social.Twitter.Api.TwitterProfile> followers, bool bShortStateName, bool bShortCountryName)
		{
			DataTable dt = new DataTable();
			dt.Columns.Add("SOCIAL_ID"                 , Type.GetType("System.String"));
			dt.Columns.Add("FIRST_NAME"                , Type.GetType("System.String"));
			dt.Columns.Add("LAST_NAME"                 , Type.GetType("System.String"));
			dt.Columns.Add("SCREEN_NAME"               , Type.GetType("System.String"));
			dt.Columns.Add("WEBSITE"                   , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_STREET"    , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_CITY"      , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_STATE"     , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_POSTALCODE", Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_COUNTRY"   , Type.GetType("System.String"));
			dt.Columns.Add("DESCRIPTION"               , Type.GetType("System.String"));

			foreach ( Spring.Social.Twitter.Api.TwitterProfile follower in followers )
			{
				string sSOCIAL_ID                  = follower.ID.ToString();
				string sFIRST_NAME                 = String.Empty;
				string sLAST_NAME                  = follower.Name;
				string sSCREEN_NAME                = follower.ScreenName;
				string sWEBSITE                    = follower.Url;
				string sMAIN_ADDRESS               = follower.Location;
				string sPRIMARY_ADDRESS_STREET     = String.Empty;
				string sPRIMARY_ADDRESS_CITY       = String.Empty;
				string sPRIMARY_ADDRESS_STATE      = String.Empty;
				string sPRIMARY_ADDRESS_POSTALCODE = String.Empty;
				string sPRIMARY_ADDRESS_COUNTRY    = String.Empty;
				string sDESCRIPTION                = follower.Description;
				if ( sLAST_NAME.LastIndexOf(' ') > 0 )
				{
					int nLastName = sLAST_NAME.LastIndexOf(' ');
					sFIRST_NAME = sLAST_NAME.Substring(0, nLastName);
					sLAST_NAME  = sLAST_NAME.Substring(nLastName+1);
				}
				
				if ( !Sql.IsEmptyString(sMAIN_ADDRESS) )
				{
					AddressDetails info = new AddressDetails();
					GoogleUtils.ConvertAddressV3(sMAIN_ADDRESS, bShortStateName, bShortCountryName, ref info);
					sPRIMARY_ADDRESS_STREET     = info.ADDRESS_STREET    ;
					sPRIMARY_ADDRESS_CITY       = info.ADDRESS_CITY      ;
					sPRIMARY_ADDRESS_STATE      = info.ADDRESS_STATE     ;
					sPRIMARY_ADDRESS_POSTALCODE = info.ADDRESS_POSTALCODE;
					sPRIMARY_ADDRESS_COUNTRY    = info.ADDRESS_COUNTRY   ;
				}
				
				DataRow row = dt.NewRow();
				row["SOCIAL_ID"                 ] = Sql.ToDBString(sSOCIAL_ID                 );
				row["FIRST_NAME"                ] = Sql.ToDBString(sFIRST_NAME                );
				row["LAST_NAME"                 ] = Sql.ToDBString(sLAST_NAME                 );
				row["SCREEN_NAME"               ] = Sql.ToDBString(sSCREEN_NAME               );
				row["WEBSITE"                   ] = Sql.ToDBString(sWEBSITE                   );
				row["PRIMARY_ADDRESS_STREET"    ] = Sql.ToDBString(sPRIMARY_ADDRESS_STREET    );
				row["PRIMARY_ADDRESS_CITY"      ] = Sql.ToDBString(sPRIMARY_ADDRESS_CITY      );
				row["PRIMARY_ADDRESS_STATE"     ] = Sql.ToDBString(sPRIMARY_ADDRESS_STATE     );
				row["PRIMARY_ADDRESS_POSTALCODE"] = Sql.ToDBString(sPRIMARY_ADDRESS_POSTALCODE);
				row["PRIMARY_ADDRESS_COUNTRY"   ] = Sql.ToDBString(sPRIMARY_ADDRESS_COUNTRY   );
				row["DESCRIPTION"               ] = Sql.ToDBString(sDESCRIPTION               );
				dt.Rows.Add(row);
			}
			return dt;
		}

		// 04/12/2012 Paul.  Facebook import. 
		public static DataTable CreateTable(List<Spring.Social.Facebook.Api.FacebookProfile> followers, bool bShortStateName, bool bShortCountryName)
		{
			DataTable dt = new DataTable();
			dt.Columns.Add("SOCIAL_ID"                 , Type.GetType("System.String"  ));
			dt.Columns.Add("FIRST_NAME"                , Type.GetType("System.String"  ));
			dt.Columns.Add("LAST_NAME"                 , Type.GetType("System.String"  ));
			dt.Columns.Add("USER_NAME"                 , Type.GetType("System.String"  ));
			dt.Columns.Add("EMAIL1"                    , Type.GetType("System.String"  ));
			dt.Columns.Add("BIRTHDATE"                 , Type.GetType("System.DateTime"));
			dt.Columns.Add("WEBSITE"                   , Type.GetType("System.String"  ));
			dt.Columns.Add("PRIMARY_ADDRESS_STREET"    , Type.GetType("System.String"  ));
			dt.Columns.Add("PRIMARY_ADDRESS_CITY"      , Type.GetType("System.String"  ));
			dt.Columns.Add("PRIMARY_ADDRESS_STATE"     , Type.GetType("System.String"  ));
			dt.Columns.Add("PRIMARY_ADDRESS_POSTALCODE", Type.GetType("System.String"  ));
			dt.Columns.Add("PRIMARY_ADDRESS_COUNTRY"   , Type.GetType("System.String"  ));
			dt.Columns.Add("DESCRIPTION"               , Type.GetType("System.String"  ));

			foreach ( Spring.Social.Facebook.Api.FacebookProfile follower in followers )
			{
				string   sSOCIAL_ID                  = follower.ID.ToString();
				string   sFIRST_NAME                 = follower.FirstName;
				string   sLAST_NAME                  = follower.LastName ;
				string   sUSER_NAME                  = follower.Username ;
				string   sEMAIL1                     = follower.Email    ;
				string   sWEBSITE                    = follower.Website  ;
				string   sLOCATION                   = (follower.Location != null) ? follower.Location.Name : String.Empty;
				DateTime dtBIRTHDATE                 = follower.Birthday.HasValue ? follower.Birthday.Value : DateTime.MinValue;
				string   sPRIMARY_ADDRESS_STREET     = String.Empty;
				string   sPRIMARY_ADDRESS_CITY       = (follower.Hometown != null) ? follower.Hometown.Name : String.Empty;
				string   sPRIMARY_ADDRESS_STATE      = String.Empty;
				string   sPRIMARY_ADDRESS_POSTALCODE = String.Empty;
				string   sPRIMARY_ADDRESS_COUNTRY    = String.Empty;
				string   sDESCRIPTION                = follower.Bio;
				
				if ( !Sql.IsEmptyString(sLOCATION) )
				{
					AddressDetails info = new AddressDetails();
					GoogleUtils.ConvertAddressV3(sLOCATION, bShortStateName, bShortCountryName, ref info);
					sPRIMARY_ADDRESS_STREET     = info.ADDRESS_STREET    ;
					sPRIMARY_ADDRESS_CITY       = info.ADDRESS_CITY      ;
					sPRIMARY_ADDRESS_STATE      = info.ADDRESS_STATE     ;
					sPRIMARY_ADDRESS_POSTALCODE = info.ADDRESS_POSTALCODE;
					sPRIMARY_ADDRESS_COUNTRY    = info.ADDRESS_COUNTRY   ;
				}
				
				DataRow row = dt.NewRow();
				row["SOCIAL_ID"                 ] = Sql.ToDBString  (sSOCIAL_ID                 );
				row["FIRST_NAME"                ] = Sql.ToDBString  (sFIRST_NAME                );
				row["LAST_NAME"                 ] = Sql.ToDBString  (sLAST_NAME                 );
				row["USER_NAME"                 ] = Sql.ToDBString  (sUSER_NAME                 );
				row["BIRTHDATE"                 ] = Sql.ToDBDateTime(dtBIRTHDATE                );
				row["EMAIL1"                    ] = Sql.ToDBString  (sEMAIL1                    );
				row["WEBSITE"                   ] = Sql.ToDBString  (sWEBSITE                   );
				row["PRIMARY_ADDRESS_STREET"    ] = Sql.ToDBString  (sPRIMARY_ADDRESS_STREET    );
				row["PRIMARY_ADDRESS_CITY"      ] = Sql.ToDBString  (sPRIMARY_ADDRESS_CITY      );
				row["PRIMARY_ADDRESS_STATE"     ] = Sql.ToDBString  (sPRIMARY_ADDRESS_STATE     );
				row["PRIMARY_ADDRESS_POSTALCODE"] = Sql.ToDBString  (sPRIMARY_ADDRESS_POSTALCODE);
				row["PRIMARY_ADDRESS_COUNTRY"   ] = Sql.ToDBString  (sPRIMARY_ADDRESS_COUNTRY   );
				row["DESCRIPTION"               ] = Sql.ToDBString  (sDESCRIPTION               );
				dt.Rows.Add(row);
			}
			return dt;
		}

		public static DataTable CreateTable(Spring.Social.Salesforce.Api.DescribeSObject metadata, Spring.Social.Salesforce.Api.QueryResult result)
		{
			DataTable dt = new DataTable();
			// 04/22/2012 Paul.  First use the metadata to define the field columns. 
			Dictionary<string, Spring.Social.Salesforce.Api.Field.enumSoapType> dictSoapTypes   = new Dictionary<string, Spring.Social.Salesforce.Api.Field.enumSoapType> ();
			Dictionary<string, Spring.Social.Salesforce.Api.Field.enumFieldType> dictFieldTypes = new Dictionary<string, Spring.Social.Salesforce.Api.Field.enumFieldType>();
			foreach ( Spring.Social.Salesforce.Api.Field field in metadata.Fields )
			{
				// 04/22/2012 Paul.  Treat the Id field separately as we do not want it to auto-map to the SplendidCRM ID field. 
				if ( field.Name == "Id" )
				{
					dt.Columns.Add("SalesforceId", Type.GetType("System.String"  ));
					continue;
				}
				dictSoapTypes .Add(field.Name, field.SoapType );
				dictFieldTypes.Add(field.Name, field.Type     );
				switch ( field.SoapType )
				{
					case Spring.Social.Salesforce.Api.Field.enumSoapType.tnsID          :  dt.Columns.Add(field.Name, Type.GetType("System.String"  ));  break;
					case Spring.Social.Salesforce.Api.Field.enumSoapType.xsdbase64Binary:  dt.Columns.Add(field.Name, Type.GetType("System.String"  ));  break;
					case Spring.Social.Salesforce.Api.Field.enumSoapType.xsdboolean     :  dt.Columns.Add(field.Name, Type.GetType("System.Boolean" ));  break;
					case Spring.Social.Salesforce.Api.Field.enumSoapType.xsddouble      :
						if ( field.Type == Spring.Social.Salesforce.Api.Field.enumFieldType.currency )
							dt.Columns.Add(field.Name, Type.GetType("System.Decimal"));
						else
							dt.Columns.Add(field.Name, Type.GetType("System.Double" ));
						break;
					case Spring.Social.Salesforce.Api.Field.enumSoapType.xsdint         :  dt.Columns.Add(field.Name, Type.GetType("System.Int32"   ));  break;
					case Spring.Social.Salesforce.Api.Field.enumSoapType.xsdstring      :  dt.Columns.Add(field.Name, Type.GetType("System.String"  ));  break;
					case Spring.Social.Salesforce.Api.Field.enumSoapType.xsddate        :  dt.Columns.Add(field.Name, Type.GetType("System.DateTime"));  break;
					case Spring.Social.Salesforce.Api.Field.enumSoapType.xsddateTime    :  dt.Columns.Add(field.Name, Type.GetType("System.DateTime"));  break;
					case Spring.Social.Salesforce.Api.Field.enumSoapType.xsdtime        :  dt.Columns.Add(field.Name, Type.GetType("System.String"  ));  break;
					case Spring.Social.Salesforce.Api.Field.enumSoapType.xsdanyType     :  dt.Columns.Add(field.Name, Type.GetType("System.String"  ));  break;
				}
			}
			foreach ( Spring.Social.Salesforce.Api.SObject record in result.Records )
			{
				DataRow row = dt.NewRow();
				foreach ( string key in record.Fields.Keys )
				{
					// 04/22/2012 Paul.  Treat the Id field separately as we do not want it to auto-map to the SplendidCRM ID field. 
					if ( key == "Id" )
					{
						row["SalesforceId"] = Sql.ToDBString  (record.Fields[key]);
						continue;
					}
					Spring.Social.Salesforce.Api.Field.enumSoapType  soapType  = dictSoapTypes [key];
					Spring.Social.Salesforce.Api.Field.enumFieldType fieldType = dictFieldTypes[key];
					switch ( soapType )
					{
						case Spring.Social.Salesforce.Api.Field.enumSoapType.tnsID          :  row[key] = Sql.ToDBString  (record.Fields[key]);  break;
						case Spring.Social.Salesforce.Api.Field.enumSoapType.xsdbase64Binary:  row[key] = Sql.ToDBString  (record.Fields[key]);  break;
						case Spring.Social.Salesforce.Api.Field.enumSoapType.xsdboolean     :  row[key] = Sql.ToDBBoolean (record.Fields[key]);  break;
						case Spring.Social.Salesforce.Api.Field.enumSoapType.xsddouble      :
							if ( fieldType == Spring.Social.Salesforce.Api.Field.enumFieldType.currency )
								row[key] = Sql.ToDecimal(record.Fields[key]);
							else
								row[key] = Sql.ToFloat(record.Fields[key]);
							break;
						case Spring.Social.Salesforce.Api.Field.enumSoapType.xsdint         :  row[key] = Sql.ToDBInteger (record.Fields[key]);  break;
						case Spring.Social.Salesforce.Api.Field.enumSoapType.xsdstring      :  row[key] = Sql.ToDBString  (record.Fields[key]);  break;
						case Spring.Social.Salesforce.Api.Field.enumSoapType.xsddate        :  row[key] = Sql.ToDBDateTime(record.Fields[key]);  break;
						case Spring.Social.Salesforce.Api.Field.enumSoapType.xsddateTime    :  row[key] = Sql.ToDBDateTime(record.Fields[key]);  break;
						case Spring.Social.Salesforce.Api.Field.enumSoapType.xsdtime        :  row[key] = Sql.ToDBString  (record.Fields[key]);  break;
						case Spring.Social.Salesforce.Api.Field.enumSoapType.xsdanyType     :  row[key] = Sql.ToDBString  (record.Fields[key]);  break;
					}
					
				}
				dt.Rows.Add(row);
			}
			return dt;
		}

		public static string FormatTweet(Spring.Social.Twitter.Api.Tweet tweet)
		{
			string sText = Sql.ToString(tweet.Text);
			if ( tweet.Entities != null )
			{
				if ( tweet.Entities.Hashtags != null )
				{
					foreach ( Spring.Social.Twitter.Api.HashtagEntity hash in tweet.Entities.Hashtags )
					{
						sText = sText.Replace("#" + hash.Text, "<a href=\"https://twitter.com/search?q=" + HttpUtility.UrlEncode(hash.Text) + "&src=hash\" target=\"TwitterUrl\">#" + hash.Text + "</a>");
					}
				}
				if ( tweet.Entities.UserMentions != null )
				{
					foreach ( Spring.Social.Twitter.Api.UserMentionEntity user in tweet.Entities.UserMentions )
					{
						sText = sText.Replace("@" + user.ScreenName, "<a href=\"https://twitter.com/" + user.ScreenName + "\" target=\"TwitterUrl\">@" + user.ScreenName + "</a>");
					}
				}
				if ( tweet.Entities.Urls != null )
				{
					foreach ( Spring.Social.Twitter.Api.UrlEntity url in tweet.Entities.Urls )
					{
						sText = sText.Replace(url.Url, "<a href=\"" + url.Url + "\" target=\"TwitterUrl\">" + url.Url + "</a>");
					}
				}
			}
			return sText;
		}

		public static string FormatTweet(TweetinCore.Interfaces.ITweet tweet)
		{
			string sText = Sql.ToString(tweet.Text);
			if ( tweet.Entities != null )
			{
				if ( tweet.Entities.Hashtags != null )
				{
					foreach ( TweetinCore.Interfaces.IHashTagEntity hash in tweet.Entities.Hashtags )
					{
						sText = sText.Replace("#" + hash.Text, "<a href=\"https://twitter.com/search?q=" + HttpUtility.UrlEncode(hash.Text) + "&src=hash\" target=\"TwitterUrl\">#" + hash.Text + "</a>");
					}
				}
				if ( tweet.Entities.UserMentions != null )
				{
					foreach ( TweetinCore.Interfaces.IUserMentionEntity user in tweet.Entities.UserMentions )
					{
						sText = sText.Replace("@" + user.ScreenName, "<a href=\"https://twitter.com/" + user.ScreenName + "\" target=\"TwitterUrl\">@" + user.ScreenName + "</a>");
					}
				}
				if ( tweet.Entities.Urls != null )
				{
					foreach ( TweetinCore.Interfaces.IUrlEntity url in tweet.Entities.Urls )
					{
						sText = sText.Replace(url.Url, "<a href=\"" + url.Url + "\" target=\"TwitterUrl\">" + url.Url + "</a>");
					}
				}
			}
			return sText;
		}

		public static void TwitterParent(IDbConnection con, string sSCREEN_NAME, ref string sPARENT_TYPE, ref Guid gPARENT_ID, ref string sPARENT_NAME)
		{
			using ( IDbCommand cmd = con.CreateCommand() )
			{
				string sSQL;
				sSQL = "select 1                                          " + ControlChars.CrLf
				     + "     , 'Contacts' as MODULE_NAME                  " + ControlChars.CrLf
				     + "     , ID                                         " + ControlChars.CrLf
				     + "     , NAME                                       " + ControlChars.CrLf
				     + "  from vwCONTACTS                                 " + ControlChars.CrLf
				     + " where TWITTER_SCREEN_NAME = @TWITTER_SCREEN_NAME1" + ControlChars.CrLf
				     + " union all                                        " + ControlChars.CrLf
				     + "select 2                                          " + ControlChars.CrLf
				     + "     , 'Leads' as MODULE_NAME                     " + ControlChars.CrLf
				     + "     , ID                                         " + ControlChars.CrLf
				     + "     , NAME                                       " + ControlChars.CrLf
				     + "  from vwLEADS                                    " + ControlChars.CrLf
				     + " where TWITTER_SCREEN_NAME = @TWITTER_SCREEN_NAME2" + ControlChars.CrLf
				     + " union all                                        " + ControlChars.CrLf
				     + "select 3                                          " + ControlChars.CrLf
				     + "     , 'Prospects' as MODULE_NAME                 " + ControlChars.CrLf
				     + "     , ID                                         " + ControlChars.CrLf
				     + "     , NAME                                       " + ControlChars.CrLf
				     + "  from vwPROSPECTS                                " + ControlChars.CrLf
				     + " where TWITTER_SCREEN_NAME = @TWITTER_SCREEN_NAME3" + ControlChars.CrLf
				     + " order by 1                                       " + ControlChars.CrLf;
				cmd.CommandText = sSQL;
				Sql.AddParameter(cmd, "@TWITTER_SCREEN_NAME1", sSCREEN_NAME);
				Sql.AddParameter(cmd, "@TWITTER_SCREEN_NAME2", sSCREEN_NAME);
				Sql.AddParameter(cmd, "@TWITTER_SCREEN_NAME3", sSCREEN_NAME);
				using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
				{
					if ( rdr.Read() )
					{
						sPARENT_TYPE = Sql.ToString(rdr["MODULE_NAME"]);
						gPARENT_ID   = Sql.ToGuid  (rdr["ID"         ]);
						sPARENT_NAME = Sql.ToString(rdr["NAME"       ]);
					}
				}
			}
		}

		public static DataTable CreateTable(Spring.Social.Twitter.Api.SearchResults result)
		{
			DataTable dt = new DataTable();
			dt.Columns.Add("TWITTER_ID"             , typeof(System.Int64   ));
			dt.Columns.Add("NAME"                   , typeof(System.String  ));
			dt.Columns.Add("DESCRIPTION"            , typeof(System.String  ));
			dt.Columns.Add("DATE_START"             , typeof(System.DateTime));
			dt.Columns.Add("TWITTER_USER_ID"        , typeof(System.Int64   ));
			dt.Columns.Add("TWITTER_FULL_NAME"      , typeof(System.String  ));
			dt.Columns.Add("TWITTER_SCREEN_NAME"    , typeof(System.String  ));
			dt.Columns.Add("PARENT_TYPE"            , typeof(System.String  ));
			dt.Columns.Add("PARENT_ID"              , typeof(System.Guid    ));
			dt.Columns.Add("PARENT_NAME"            , typeof(System.String  ));
			dt.Columns.Add("IS_RETWEET"             , typeof(System.Boolean ));
			dt.Columns.Add("ORIGINAL_ID"            , typeof(System.Int64   ));
			dt.Columns.Add("ORIGINAL_USER_ID"       , typeof(System.Int64   ));
			dt.Columns.Add("ORIGINAL_FULL_NAME"     , typeof(System.String  ));
			dt.Columns.Add("ORIGINAL_SCREEN_NAME"   , typeof(System.String  ));

			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				foreach ( Spring.Social.Twitter.Api.Tweet tweet in result.Tweets )
				{
					DataRow row = dt.NewRow();
					dt.Rows.Add(row);
					row["TWITTER_ID"          ] = Sql.ToInt64 (tweet.ID  );
					row["NAME"                ] = Sql.ToString(tweet.Text);
					row["DESCRIPTION"         ] = FormatTweet(tweet);
					row["DATE_START"          ] = tweet.CreatedAt.Value;
					string sSCREEN_NAME = String.Empty;
					if ( tweet.User != null )
					{
						row["TWITTER_USER_ID"     ] = tweet.User.ID        ;
						row["TWITTER_FULL_NAME"   ] = Sql.ToString(tweet.User.Name          );
						row["TWITTER_SCREEN_NAME" ] = Sql.ToString(tweet.User.ScreenName    );
						sSCREEN_NAME = tweet.User.ScreenName;
					}
					row["IS_RETWEET"] = (tweet.RetweetedStatus != null);
					if ( tweet.RetweetedStatus != null )
					{
						row["ORIGINAL_ID"     ] = Sql.ToInt64 (tweet.RetweetedStatus.ID);
						if ( tweet.RetweetedStatus.User != null )
						{
							row["ORIGINAL_USER_ID"     ] = tweet.RetweetedStatus.User.ID        ;
							row["ORIGINAL_FULL_NAME"   ] = Sql.ToString(tweet.RetweetedStatus.User.Name          );
							row["ORIGINAL_SCREEN_NAME" ] = Sql.ToString(tweet.RetweetedStatus.User.ScreenName    );
						}
					}
					if ( !Sql.IsEmptyString(sSCREEN_NAME) )
					{
						Guid   gPARENT_ID   = Guid.Empty;
						string sPARENT_TYPE = String.Empty;
						string sPARENT_NAME = String.Empty;
						TwitterParent(con, sSCREEN_NAME, ref sPARENT_TYPE, ref gPARENT_ID, ref sPARENT_NAME);
						if ( !Sql.IsEmptyGuid(gPARENT_ID) )
						{
							row["PARENT_ID"  ] = gPARENT_ID  ;
							row["PARENT_TYPE"] = sPARENT_TYPE;
							row["PARENT_NAME"] = sPARENT_NAME;
						}
					}
				}
			}
			return dt;
		}

		public static DataTable CreateTable(IList<Spring.Social.HubSpot.Api.Contact> contacts)
		{
			DataTable dt = new DataTable();
			dt.Columns.Add("SOCIAL_ID"                 , Type.GetType("System.String"));
			dt.Columns.Add("SALUTATION"                , Type.GetType("System.String"));
			dt.Columns.Add("FIRST_NAME"                , Type.GetType("System.String"));
			dt.Columns.Add("LAST_NAME"                 , Type.GetType("System.String"));
			dt.Columns.Add("EMAIL1"                    , Type.GetType("System.String"));
			dt.Columns.Add("TITLE"                     , Type.GetType("System.String"));
			dt.Columns.Add("ACCOUNT_NAME"              , Type.GetType("System.String"));
			dt.Columns.Add("INDUSTRY"                  , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_STREET"    , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_CITY"      , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_STATE"     , Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_POSTALCODE", Type.GetType("System.String"));
			dt.Columns.Add("PRIMARY_ADDRESS_COUNTRY"   , Type.GetType("System.String"));
			dt.Columns.Add("PHONE_WORK"                , Type.GetType("System.String"));
			dt.Columns.Add("PHONE_MOBILE"              , Type.GetType("System.String"));
			dt.Columns.Add("PHONE_HOME"                , Type.GetType("System.String"));
			dt.Columns.Add("PHONE_FAX"                 , Type.GetType("System.String"));
			dt.Columns.Add("DESCRIPTION"               , Type.GetType("System.String"));
			dt.Columns.Add("WEBSITE"                   , Type.GetType("System.String"));
			dt.Columns.Add("TWITTER_SCREEN_NAME"       , Type.GetType("System.String"));

			foreach ( Spring.Social.HubSpot.Api.Contact contact in contacts )
			{
				string sSOCIAL_ID                  = contact.id.Value.ToString();
				string sSALUTATION                 = contact.salutation ;
				string sFIRST_NAME                 = contact.firstname  ;
				string sLAST_NAME                  = contact.lastname   ;
				string sEMAIL1                     = contact.email      ;
				string sTITLE                      = contact.jobtitle   ;
				string sACCOUNT_NAME               = contact.company    ;
				string sINDUSTRY                   = contact.industry   ;
				string sPRIMARY_ADDRESS_STREET     = contact.address    ;
				string sPRIMARY_ADDRESS_CITY       = contact.city       ;
				string sPRIMARY_ADDRESS_STATE      = contact.state      ;
				string sPRIMARY_ADDRESS_POSTALCODE = contact.zip        ;
				string sPRIMARY_ADDRESS_COUNTRY    = contact.country    ;
				string sPHONE_WORK                 = contact.phone      ;
				string sPHONE_MOBILE               = contact.mobilephone;
				string sPHONE_FAX                  = contact.fax        ;
				string sPHONE_HOME                 = String.Empty       ;
				string sDESCRIPTION                = contact.message    ;
				string sWEBSITE                    = contact.website    ;
				string sTWITTER_SCREEN_NAME        = contact.twitterhandle;
				
				DataRow row = dt.NewRow();
				row["SOCIAL_ID"                 ] = Sql.ToDBString(sSOCIAL_ID                 );
				row["SALUTATION"                ] = Sql.ToDBString(sSALUTATION                );
				row["FIRST_NAME"                ] = Sql.ToDBString(sFIRST_NAME                );
				row["LAST_NAME"                 ] = Sql.ToDBString(sLAST_NAME                 );
				row["EMAIL1"                    ] = Sql.ToDBString(sEMAIL1                    );
				row["TITLE"                     ] = Sql.ToDBString(sTITLE                     );
				row["ACCOUNT_NAME"              ] = Sql.ToDBString(sACCOUNT_NAME              );
				row["INDUSTRY"                  ] = Sql.ToDBString(sINDUSTRY                  );
				row["PRIMARY_ADDRESS_STREET"    ] = Sql.ToDBString(sPRIMARY_ADDRESS_STREET    );
				row["PRIMARY_ADDRESS_CITY"      ] = Sql.ToDBString(sPRIMARY_ADDRESS_CITY      );
				row["PRIMARY_ADDRESS_STATE"     ] = Sql.ToDBString(sPRIMARY_ADDRESS_STATE     );
				row["PRIMARY_ADDRESS_POSTALCODE"] = Sql.ToDBString(sPRIMARY_ADDRESS_POSTALCODE);
				row["PRIMARY_ADDRESS_COUNTRY"   ] = Sql.ToDBString(sPRIMARY_ADDRESS_COUNTRY   );
				row["PHONE_WORK"                ] = Sql.ToDBString(sPHONE_WORK                );
				row["PHONE_MOBILE"              ] = Sql.ToDBString(sPHONE_MOBILE              );
				row["PHONE_HOME"                ] = Sql.ToDBString(sPHONE_HOME                );
				row["PHONE_FAX"                 ] = Sql.ToDBString(sPHONE_FAX                 );
				row["DESCRIPTION"               ] = Sql.ToDBString(sDESCRIPTION               );
				row["WEBSITE"                   ] = Sql.ToDBString(sWEBSITE                   );
				row["TWITTER_SCREEN_NAME"       ] = Sql.ToDBString(sTWITTER_SCREEN_NAME       );
				dt.Rows.Add(row);
			}
			return dt;
		}
	}
}

