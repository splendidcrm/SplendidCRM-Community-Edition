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
using System.Web;
using System.Net;
using System.Web.Script.Serialization;
using System.Text;

using Google.Apis.Contacts.v3.Data;

namespace SplendidCRM
{
	public class ExtensionDetails
	{
		public virtual string this[string sFieldName]
		{
			get { return null; }
			set { }
		}
	}

	public class AddressDetails : ExtensionDetails
	{
		public string NAME              ;
		public string FIRST_NAME        ;
		public string LAST_NAME         ;
		public string ADDRESS_STREET    ;
		public string ADDRESS_CITY      ;
		public string ADDRESS_COUNTY    ;
		public string ADDRESS_TOWN      ;
		public string ADDRESS_STATE     ;
		public string ADDRESS_POSTALCODE;
		public string ADDRESS_COUNTRY   ;
		public string EMAIL1            ;
		public string EMAIL2            ;
		public string PHONE1            ;
		public string PHONE2            ;
		public string WEBSITE           ;
		public string EDIT_VIEW         ;
		public string LocationStatus    ;
		public string SplendidCRM_URL   ;
		public string Accuracy          ;

		public AddressDetails()
		{
			NAME               = String.Empty;
			FIRST_NAME         = String.Empty;
			LAST_NAME          = String.Empty;
			ADDRESS_STREET     = String.Empty;
			ADDRESS_CITY       = String.Empty;
			ADDRESS_COUNTY     = String.Empty;
			ADDRESS_TOWN       = String.Empty;
			ADDRESS_STATE      = String.Empty;
			ADDRESS_POSTALCODE = String.Empty;
			ADDRESS_COUNTRY    = String.Empty;
			EMAIL1             = String.Empty;
			EMAIL2             = String.Empty;
			PHONE1             = String.Empty;
			PHONE2             = String.Empty;
			WEBSITE            = String.Empty;
			EDIT_VIEW          = String.Empty;
			LocationStatus     = String.Empty;
			SplendidCRM_URL    = String.Empty;
			Accuracy           = String.Empty;
		}

		public override string this[string sFieldName]
		{
			get
			{
				string sValue = String.Empty;
				switch ( sFieldName.ToUpper() )
				{
					case "NAME"                       :  sValue = this.NAME              ;  break;
					case "FIRST_NAME"                 :  sValue = this.FIRST_NAME        ;  break;
					case "LAST_NAME"                  :  sValue = this.LAST_NAME         ;  break;
					case "BILLING_ADDRESS_STREET"     :  sValue = this.ADDRESS_STREET    ;  break;
					case "BILLING_ADDRESS_CITY"       :  sValue = this.ADDRESS_CITY      ;  break;
					case "BILLING_ADDRESS_STATE"      :  sValue = this.ADDRESS_STATE     ;  break;
					case "BILLING_ADDRESS_POSTALCODE" :  sValue = this.ADDRESS_POSTALCODE;  break;
					case "BILLING_ADDRESS_COUNTRY"    :  sValue = this.ADDRESS_COUNTRY   ;  break;
					case "SHIPPING_ADDRESS_STREET"    :  sValue = this.ADDRESS_STREET    ;  break;
					case "SHIPPING_ADDRESS_CITY"      :  sValue = this.ADDRESS_CITY      ;  break;
					case "SHIPPING_ADDRESS_STATE"     :  sValue = this.ADDRESS_STATE     ;  break;
					case "SHIPPING_ADDRESS_POSTALCODE":  sValue = this.ADDRESS_POSTALCODE;  break;
					case "SHIPPING_ADDRESS_COUNTRY"   :  sValue = this.ADDRESS_COUNTRY   ;  break;
					case "PRIMARY_ADDRESS_STREET"     :  sValue = this.ADDRESS_STREET    ;  break;
					case "PRIMARY_ADDRESS_CITY"       :  sValue = this.ADDRESS_CITY      ;  break;
					case "PRIMARY_ADDRESS_STATE"      :  sValue = this.ADDRESS_STATE     ;  break;
					case "PRIMARY_ADDRESS_POSTALCODE" :  sValue = this.ADDRESS_POSTALCODE;  break;
					case "PRIMARY_ADDRESS_COUNTRY"    :  sValue = this.ADDRESS_COUNTRY   ;  break;
					case "ALT_ADDRESS_STREET"         :  sValue = this.ADDRESS_STREET    ;  break;
					case "ALT_ADDRESS_CITY"           :  sValue = this.ADDRESS_CITY      ;  break;
					case "ALT_ADDRESS_STATE"          :  sValue = this.ADDRESS_STATE     ;  break;
					case "ALT_ADDRESS_POSTALCODE"     :  sValue = this.ADDRESS_POSTALCODE;  break;
					case "ALT_ADDRESS_COUNTRY"        :  sValue = this.ADDRESS_COUNTRY   ;  break;
					case "EMAIL1"                     :  sValue = this.EMAIL1            ;  break;
					case "EMAIL2"                     :  sValue = this.EMAIL2            ;  break;
					case "PHONE_OFFICE"               :  sValue = this.PHONE1            ;  break;
					case "PHONE_WORK"                 :  sValue = this.PHONE1            ;  break;
					case "PHONE_FAX"                  :  sValue = this.PHONE2            ;  break;
					case "PHONE_MOBILE"               :  sValue = this.PHONE2            ;  break;
					case "WEBSITE"                    :  sValue = this.WEBSITE           ;  break;
				}
				return sValue;
			}
			set
			{
				switch ( sFieldName.ToUpper() )
				{
					case "NAME"                       :  this.NAME               = value;  break;
					case "FIRST_NAME"                 :  this.FIRST_NAME         = value;  break;
					case "LAST_NAME"                  :  this.LAST_NAME          = value;  break;
					case "BILLING_ADDRESS_STREET"     :  this.ADDRESS_STREET     = value;  break;
					case "BILLING_ADDRESS_CITY"       :  this.ADDRESS_CITY       = value;  break;
					case "BILLING_ADDRESS_STATE"      :  this.ADDRESS_STATE      = value;  break;
					case "BILLING_ADDRESS_POSTALCODE" :  this.ADDRESS_POSTALCODE = value;  break;
					case "BILLING_ADDRESS_COUNTRY"    :  this.ADDRESS_COUNTRY    = value;  break;
					case "SHIPPING_ADDRESS_STREET"    :  this.ADDRESS_STREET     = value;  break;
					case "SHIPPING_ADDRESS_CITY"      :  this.ADDRESS_CITY       = value;  break;
					case "SHIPPING_ADDRESS_STATE"     :  this.ADDRESS_STATE      = value;  break;
					case "SHIPPING_ADDRESS_POSTALCODE":  this.ADDRESS_POSTALCODE = value;  break;
					case "SHIPPING_ADDRESS_COUNTRY"   :  this.ADDRESS_COUNTRY    = value;  break;
					case "PRIMARY_ADDRESS_STREET"     :  this.ADDRESS_STREET     = value;  break;
					case "PRIMARY_ADDRESS_CITY"       :  this.ADDRESS_CITY       = value;  break;
					case "PRIMARY_ADDRESS_STATE"      :  this.ADDRESS_STATE      = value;  break;
					case "PRIMARY_ADDRESS_POSTALCODE" :  this.ADDRESS_POSTALCODE = value;  break;
					case "PRIMARY_ADDRESS_COUNTRY"    :  this.ADDRESS_COUNTRY    = value;  break;
					case "ALT_ADDRESS_STREET"         :  this.ADDRESS_STREET     = value;  break;
					case "ALT_ADDRESS_CITY"           :  this.ADDRESS_CITY       = value;  break;
					case "ALT_ADDRESS_STATE"          :  this.ADDRESS_STATE      = value;  break;
					case "ALT_ADDRESS_POSTALCODE"     :  this.ADDRESS_POSTALCODE = value;  break;
					case "ALT_ADDRESS_COUNTRY"        :  this.ADDRESS_COUNTRY    = value;  break;
					case "EMAIL1"                     :  this.EMAIL1             = value;  break;
					case "EMAIL2"                     :  this.EMAIL2             = value;  break;
					case "PHONE_OFFICE"               :  this.PHONE1             = value;  break;
					case "PHONE_WORK"                 :  this.PHONE1             = value;  break;
					case "PHONE_FAX"                  :  this.PHONE2             = value;  break;
					case "PHONE_MOBILE"               :  this.PHONE2             = value;  break;
					case "WEBSITE"                    :  this.WEBSITE            = value;  break;
				}
			}
		}
	}

	#region Google Maps Response
	/*
	{
		"name": "1600 Amphitheatre Parkway, Mountain View, CA",
		"Status": 
		{
			"code": 200,
			"request": "geocode"
		},
		"Placemark": 
		[
			{
				"id": "p1",
				"address": "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",
				"AddressDetails": 
				{
					"Accuracy" : 8,
					"Country" : 
					{
						"AdministrativeArea" : 
						{
							"AdministrativeAreaName" : "CA",
							"SubAdministrativeArea" : 
							{
								"Locality" : 
								{
									"LocalityName" : "Mountain View",
									"PostalCode" : 
									{
										"PostalCodeNumber" : "94043"
									},
									"Thoroughfare" : 
									{
										"ThoroughfareName" : "1600 Amphitheatre Pkwy"
									}
								},
								"SubAdministrativeAreaName" : "Santa Clara"
							}
						},
						"CountryName" : "USA",
						"CountryNameCode" : "US"
					}
				},
				"ExtendedData": 
				{
					"LatLonBox": 
					{
						"north": 37.4247703,
						"south": 37.4184751,
						"east": -122.0808787,
						"west": -122.0871739
					}
				},
				"Point": 
				{
					"coordinates": [ -122.0840263, 37.4216227, 0 ]
				}
			}
		]
	}
	*/
	public class GoogleMapsResponseV2
	{
		public enum GGeoStatusCode
		{
			G_GEO_SUCCESS             = 200,  // No errors occurred; the address was successfully parsed and its geocode has been returned.  
			G_GEO_BAD_REQUEST         = 400,  // A directions request could not be successfully parsed.  
			G_GEO_SERVER_ERROR        = 500,  // A geocoding or directions request could not be successfully processed, yet the exact reason for the failure is not known.  
			G_GEO_MISSING_QUERY       = 601,  // The HTTP q parameter was either missing or had no value. For geocoding requests, this means that an empty address was specified as input. For directions requests, this means that no query was specified in the input.  
			G_GEO_UNKNOWN_ADDRESS     = 602,  // No corresponding geographic location could be found for the specified address. This may be due to the fact that the address is relatively new, or it may be incorrect.  
			G_GEO_UNAVAILABLE_ADDRESS = 603,  // The geocode for the given address or the route for the given directions query cannot be returned due to legal or contractual reasons.  
			G_GEO_UNKNOWN_DIRECTIONS  = 604,  // The GDirections object could not compute directions between the points mentioned in the query. This is usually because there is no route available between the two points, or because we do not have data for routing in that region.  
			G_GEO_BAD_KEY             = 610, 
		}

		public class MapsStatus
		{
			public GGeoStatusCode code   ;
			public string         request;
		}
		public class MapsPlacemark
		{
			public class MapsAddressDetails
			{
				public class MapsCountry
				{
					public class MapsAdministrativeArea
					{
						public class MapsSubAdministrativeArea
						{
							public class MapsLocality
							{
								public class MapsPostalCode
								{
									public string PostalCodeNumber;
								}
								public class MapsThoroughfare
								{
									public string ThoroughfareName;
								}
								public string           LocalityName;
								public MapsPostalCode   PostalCode  ;
								public MapsThoroughfare Thoroughfare;
							}
							public MapsLocality Locality                 ;
							public string       SubAdministrativeAreaName;
						}
						public string                    AdministrativeAreaName;
						public MapsSubAdministrativeArea SubAdministrativeArea ;
					}
					public MapsAdministrativeArea AdministrativeArea;
					public string                 CountryName       ;
					public string                 CountryNameCode   ;
				}
				public int         Accuracy;
				public MapsCountry Country ;
			}
			public class MapsExtendedData
			{
				public class MapsLatLonBox
				{
					public double north;
					public double south;
					public double east ;
					public double west ;
				}
				public MapsLatLonBox LatLonBox;
			}
			public class MapsPoint
			{
				public double[] coordinates;
			}
			public string             id            ;
			public string             address       ;
			public MapsAddressDetails AddressDetails;
			public MapsExtendedData   ExtendedData  ;
			public MapsPoint          Point         ;
		}
		public string          name     ;
		public MapsStatus      Status   ;
		public MapsPlacemark[] Placemark;
	}

	/*
	{
	   "results" : [
	      {
	         "address_components" : [
	            {
	               "long_name" : "400",
	               "short_name" : "400",
	               "types" : [ "subpremise" ]
	            },
	            {
	               "long_name" : "1000",
	               "short_name" : "1000",
	               "types" : [ "street_number" ]
	            },
	            {
	               "long_name" : "E Woodfield Rd",
	               "short_name" : "E Woodfield Rd",
	               "types" : [ "route" ]
	            },
	            {
	               "long_name" : "Schaumburg",
	               "short_name" : "Schaumburg",
	               "types" : [ "locality", "political" ]
	            },
	            {
	               "long_name" : "Schaumburg",
	               "short_name" : "Schaumburg",
	               "types" : [ "administrative_area_level_3", "political" ]
	            },
	            {
	               "long_name" : "Cook",
	               "short_name" : "Cook",
	               "types" : [ "administrative_area_level_2", "political" ]
	            },
	            {
	               "long_name" : "Illinois",
	               "short_name" : "IL",
	               "types" : [ "administrative_area_level_1", "political" ]
	            },
	            {
	               "long_name" : "United States",
	               "short_name" : "US",
	               "types" : [ "country", "political" ]
	            },
	            {
	               "long_name" : "60173",
	               "short_name" : "60173",
	               "types" : [ "postal_code" ]
	            }
	         ],
	         "formatted_address" : "1000 E Woodfield Rd #400, Schaumburg, IL 60173, USA",
	         "geometry" : {
	            "location" : {
	               "lat" : 42.04292710,
	               "lng" : -88.05768089999999
	            },
	            "location_type" : "APPROXIMATE",
	            "viewport" : {
	               "northeast" : {
	                  "lat" : 42.04427608029150,
	                  "lng" : -88.05633191970850
	               },
	               "southwest" : {
	                  "lat" : 42.04157811970850,
	                  "lng" : -88.05902988029150
	               }
	            }
	         },
	         "partial_match" : true,
	         "types" : [ "subpremise" ]
	      }
	   ],
	   "status" : "OK"
	}
	*/
	public class GoogleMapsResponseV3
	{
		public enum GGeoStatusCode
		{
			OK,               // "OK"               indicates that no errors occurred; the address was successfully parsed and at least one geocode was returned.
			ZERO_RESULTS,     // "ZERO_RESULTS"     indicates that the geocode was successful but returned no results. This may occur if the geocode was passed a non-existent address or a latlng in a remote location.
			OVER_QUERY_LIMIT, // "OVER_QUERY_LIMIT" indicates that you are over your quota.
			REQUEST_DENIED,   // "REQUEST_DENIED"   indicates that your request was denied, generally because of lack of a sensor parameter.
			INVALID_REQUEST   // "INVALID_REQUEST"  generally indicates that the query (address or latlng) is missing.
		}

		public class V3Results
		{
			public class AddressComponent
			{
				public string   long_name ;
				public string   short_name;
				public string[] types     ;
			}
			public class Geometry
			{
				public class Location
				{
					public double lat;
					public double lng;
				}
				public class Viewport
				{
					public Location southwest;
					public Location northeast;
				}
				public Location location     ;
				public string   location_type;
				public Viewport viewport     ;
			}
			
			public string[]           types             ;
			public string             formatted_address ;
			public AddressComponent[] address_components;
			public Geometry           geometry          ;
		}
		public string      status ;
		public V3Results[] results;
	}
	#endregion

	public class GoogleUtils
	{
		// 08/26/2011 Paul.  Geocoding API V2 has been deprecated.
		public static void ConvertAddressV2(string sGoogleMapsKey, string Address, ref AddressDetails info)
		{
			// 08/26/2011 Paul.  Geocoding API V2 has been deprecated.
			// http://code.google.com/apis/maps/documentation/geocoding/v2/index.html
			string sURL = "http://maps.google.com/maps/geo?q=" + HttpUtility.UrlEncode(Address) + "&output=json&oe=utf8&sensor=false&key=" + sGoogleMapsKey;
			HttpWebRequest objRequest = (HttpWebRequest) WebRequest.Create(sURL);
			objRequest.Headers.Add("cache-control", "no-cache");
			objRequest.KeepAlive         = false;
			objRequest.AllowAutoRedirect = false;
			objRequest.Timeout           = 15000;  //15 seconds
			objRequest.Method            = "GET";

			// 01/11/2011 Paul.  Make sure to dispose of the response object as soon as possible. 
			using ( HttpWebResponse objResponse = (HttpWebResponse) objRequest.GetResponse() )
			{
				if ( objResponse != null )
				{
					if ( objResponse.StatusCode == HttpStatusCode.OK || objResponse.StatusCode == HttpStatusCode.Found )
					{
						using ( StreamReader readStream = new StreamReader(objResponse.GetResponseStream(), System.Text.Encoding.UTF8) )
						{
							string sJsonResponse = readStream.ReadToEnd();
							JavaScriptSerializer json = new JavaScriptSerializer();
							GoogleMapsResponseV2 resp = json.Deserialize<GoogleMapsResponseV2>(sJsonResponse);
							if ( resp.Placemark != null && resp.Placemark.Length > 0 )
							{
								if ( resp.Placemark[0].AddressDetails != null && resp.Placemark[0].AddressDetails.Country != null )
								{
									// http://code.google.com/apis/maps/documentation/javascript/v2/reference.html#GGeoAddressAccuracy
									info.Accuracy = resp.Placemark[0].AddressDetails.Accuracy.ToString();
									info.ADDRESS_COUNTRY = resp.Placemark[0].AddressDetails.Country.CountryName;
									if ( resp.Placemark[0].AddressDetails.Country.AdministrativeArea != null )
									{
										info.ADDRESS_STATE = resp.Placemark[0].AddressDetails.Country.AdministrativeArea.AdministrativeAreaName;
										if ( resp.Placemark[0].AddressDetails.Country.AdministrativeArea.SubAdministrativeArea != null && resp.Placemark[0].AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.Locality != null )
										{
											info.ADDRESS_CITY = resp.Placemark[0].AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.Locality.LocalityName;
											if ( resp.Placemark[0].AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.Locality.Thoroughfare != null )
											{
												info.ADDRESS_STREET = resp.Placemark[0].AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.Locality.Thoroughfare.ThoroughfareName;
											}
											if ( resp.Placemark[0].AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.Locality.PostalCode != null )
												info.ADDRESS_POSTALCODE  = resp.Placemark[0].AddressDetails.Country.AdministrativeArea.SubAdministrativeArea.Locality.PostalCode.PostalCodeNumber;
										}
									}
								}
							}
							// http://code.google.com/apis/maps/documentation/mapplets/reference.html
							switch ( resp.Status.code )
							{
								case GoogleMapsResponseV2.GGeoStatusCode.G_GEO_SUCCESS            :  info.LocationStatus = "Success"            ;  break;
								case GoogleMapsResponseV2.GGeoStatusCode.G_GEO_BAD_REQUEST        :  info.LocationStatus = "Bad request"        ;  break;
								case GoogleMapsResponseV2.GGeoStatusCode.G_GEO_SERVER_ERROR       :  info.LocationStatus = "Server error"       ;  break;
								case GoogleMapsResponseV2.GGeoStatusCode.G_GEO_MISSING_QUERY      :  info.LocationStatus = "Missing query"      ;  break;
								case GoogleMapsResponseV2.GGeoStatusCode.G_GEO_UNKNOWN_ADDRESS    :  info.LocationStatus = "Unknown address"    ;  break;
								case GoogleMapsResponseV2.GGeoStatusCode.G_GEO_UNAVAILABLE_ADDRESS:  info.LocationStatus = "Unavailable address";  break;
								case GoogleMapsResponseV2.GGeoStatusCode.G_GEO_UNKNOWN_DIRECTIONS :  info.LocationStatus = "Unknown directions" ;  break;
								case GoogleMapsResponseV2.GGeoStatusCode.G_GEO_BAD_KEY            :  info.LocationStatus = "Bad key"            ;  break;
							}
						}
					}
					else
					{
						info.LocationStatus = objResponse.StatusCode.ToString();
					}
				}
			}
		}

		public static void ConvertAddressV3(string Address, bool bShortStateName, bool bShortCountryName, ref AddressDetails info)
		{
			// 08/26/2011 Paul.  Geocoding API V3.
			// http://code.google.com/apis/maps/documentation/geocoding/
			string sURL = "http://maps.googleapis.com/maps/api/geocode/json?address=" + HttpUtility.UrlEncode(Address) + "&sensor=false";
			HttpWebRequest objRequest = (HttpWebRequest) WebRequest.Create(sURL);
			objRequest.Headers.Add("cache-control", "no-cache");
			objRequest.KeepAlive         = false;
			objRequest.AllowAutoRedirect = false;
			objRequest.Timeout           = 15000;  //15 seconds
			objRequest.Method            = "GET";

			// 01/11/2011 Paul.  Make sure to dispose of the response object as soon as possible. 
			using ( HttpWebResponse objResponse = (HttpWebResponse) objRequest.GetResponse() )
			{
				if ( objResponse != null )
				{
					if ( objResponse.StatusCode == HttpStatusCode.OK || objResponse.StatusCode == HttpStatusCode.Found )
					{
						using ( StreamReader readStream = new StreamReader(objResponse.GetResponseStream(), System.Text.Encoding.UTF8) )
						{
							string sJsonResponse = readStream.ReadToEnd();
							JavaScriptSerializer json = new JavaScriptSerializer();
							GoogleMapsResponseV3 resp = json.Deserialize<GoogleMapsResponseV3>(sJsonResponse);
							if ( resp.status == "OK" )
							{
								if ( resp.results != null && resp.results.Length > 0 )
								{
									GoogleMapsResponseV3.V3Results result = resp.results[0];
									if ( result.address_components != null )
									{
										// 08/26/2011 Paul.  Subpremise is the suite number. 
										string sSubpremise   = String.Empty;
										string sStreetNumber = String.Empty;
										string sRoute        = String.Empty;
										foreach ( GoogleMapsResponseV3.V3Results.AddressComponent adr in result.address_components )
										{
											if ( adr.types != null && adr.types.Length > 0 )
											{
												foreach ( string type in adr.types )
												{
													// 08/26/2011 Paul.  If this set is a postal prefix, then skip the rest of the types. 
													if ( type == "postal_code_prefix" )
														break;
													switch ( type )
													{
														case "subpremise"                 :  sSubpremise             = adr.long_name;  break;
														case "street_number"              :  sStreetNumber           = adr.long_name;  break;
														case "route"                      :  sRoute                  = adr.long_name;  break;
														case "locality"                   :  info.ADDRESS_CITY       = adr.long_name;  break;
														case "administrative_area_level_1":  info.ADDRESS_STATE      = (bShortStateName && !Sql.IsEmptyString(adr.short_name)) ? adr.short_name : adr.long_name;  break;
														case "administrative_area_level_2":  info.ADDRESS_COUNTY     = adr.long_name;  break;
														case "administrative_area_level_3":  info.ADDRESS_TOWN       = adr.long_name;  break;
														case "country"                    :  info.ADDRESS_COUNTRY    = (bShortCountryName && !Sql.IsEmptyString(adr.short_name)) ? adr.short_name : adr.long_name;  break;
														case "postal_code"                :  info.ADDRESS_POSTALCODE = adr.long_name;  break;
													}
												}
											}
										}
										info.ADDRESS_STREET = (sStreetNumber + " " + sRoute).Trim();
										if ( !Sql.IsEmptyString(sSubpremise) )
											info.ADDRESS_STREET += " #" + sSubpremise;
										if ( result.geometry != null )
										{
											info.Accuracy = result.geometry.location_type;
										}
									}
								}
							}
							// http://code.google.com/apis/maps/documentation/geocoding/#StatusCodes
							switch ( resp.status )
							{
								case "OK"              :  info.LocationStatus = "Success"         ;  break;
								case "ZERO_RESULTS"    :  info.LocationStatus = "zero results"    ;  break;
								case "OVER_QUERY_LIMIT":  info.LocationStatus = "over query limit";  break;
								case "REQUEST_DENIED"  :  info.LocationStatus = "request denied"  ;  break;
								case "INVALID_REQUEST" :  info.LocationStatus = "invalid request" ;  break;
							}
						}
					}
					else
					{
						info.LocationStatus = objResponse.StatusCode.ToString();
					}
				}
			}
		}

		public static string BuildFormattedAddress(StructuredPostalAddress adr)
		{
			StringBuilder sb = new StringBuilder();
			if ( !Sql.IsEmptyString(adr.Street) )
			{
				if( adr.Street.EndsWith("\n") )
					sb.Append(adr.Street);
				else
					sb.AppendLine(adr.Street);
			}
			if ( !Sql.IsEmptyString(adr.City) || !Sql.IsEmptyString(adr.State) || !Sql.IsEmptyString(adr.PostalCode) )
			{
				sb.Append(adr.City);
				if ( !Sql.IsEmptyString(adr.City) && (!Sql.IsEmptyString(adr.State) || !Sql.IsEmptyString(adr.PostalCode)) )
					sb.Append(", ");
				sb.Append(adr.State);
				if ( !Sql.IsEmptyString(adr.PostalCode) && (!Sql.IsEmptyString(adr.City) || !Sql.IsEmptyString(adr.State)) )
					sb.Append(" ");
				sb.Append(adr.PostalCode);
				sb.AppendLine();
			}
			if ( !Sql.IsEmptyString(adr.Country) )
			{
				sb.AppendLine(adr.Country);
			}
			return sb.ToString();
		}

		/*
		private static void FixAppointmentTimes(HttpContext Context, Event appointment)
		{
			// 03/25/2013 Paul.  For a recurring appointment, the times array is empty. 
			// We will fix this immediately after the appointment is retrieved. 
			if ( appointment.Times.Count == 0 )
			{
				if ( appointment.Recurrence != null )
				{
					// DTSTART;TZID=America/New_York:20130325T050000
					// DTEND;TZID=America/New_York:20130325T060000
					// RRULE:FREQ=DAILY;COUNT=5
					// BEGIN:VTIMEZONE
					// TZID:America/New_York
					// X-LIC-LOCATION:America/New_York
					// BEGIN:DAYLIGHT
					// TZOFFSETFROM:-0500
					// TZOFFSETTO:-0400
					// TZNAME:EDT
					// DTSTART:19700308T020000
					// RRULE:FREQ=YEARLY;BYMONTH=3;BYDAY=2SU
					// END:DAYLIGHT
					// BEGIN:STANDARD
					// TZOFFSETFROM:-0400
					// TZOFFSETTO:-0500
					// TZNAME:EST
					// DTSTART:19701101T020000
					// RRULE:FREQ=YEARLY;BYMONTH=11;BYDAY=1SU
					// END:STANDARD
					// END:VTIMEZONE
					When eventTime = new When();
					string sRRULE = appointment.Recurrence.Value;
					using ( MemoryStream stm = new MemoryStream(System.Text.UTF8Encoding.UTF8.GetBytes(sRRULE)) )
					{
						using ( StreamReader rdr = new StreamReader(stm) )
						{
							string sLine = null;
							while ( (sLine = rdr.ReadLine()) != null )
							{
								// 03/25/2013 Paul.  Stop when timezone starts to prevent DTSTART from getting over-written. 
								if ( sLine.Contains("BEGIN:VTIMEZONE") )
									break;
								if ( sLine.Contains(":") )
								{
									string[] arrLine = new string[2];
									int nSeparator = sLine.IndexOf(':');
									arrLine[0] = sLine.Substring(0, nSeparator);
									arrLine[1] = sLine.Substring(nSeparator + 1);
									if ( arrLine[0].StartsWith("DTSTART") )
									{
										try
										{
											string sTZID = String.Empty;
											// DTSTART;TZID=America/New_York:20111213T123000
											int nTZID = arrLine[0].IndexOf("TZID=");
											if ( nTZID >= 0 )
												sTZID = arrLine[0].Substring(nTZID + 5);
											else
												sTZID = String.Empty;
											// 02/12/2012 Paul.  An All-Day event does not include the time in the date strings. 
											if ( arrLine[1].Length == 8 )
											{
												eventTime.StartTime = SplendidCRM.Utils.CalDAV_ParseDate(arrLine[1]);
												eventTime.AllDay    = true;
											}
											else if ( arrLine[1].EndsWith("Z") )
											{
												eventTime.StartTime = SplendidCRM.Utils.CalDAV_ParseDate(arrLine[1]);
											}
											else
											{
												eventTime.StartTime = SplendidCRM.Utils.CalDAV_ParseDate(arrLine[1]);
												SplendidCRM.TimeZone oTimeZone = Context.Application["TIMEZONE.TZID." + sTZID] as SplendidCRM.TimeZone;
												if ( oTimeZone != null )
												{
													eventTime.StartTime = oTimeZone.ToServerTime(eventTime.StartTime);
												}
											}
										}
										catch
										{
										}
									}
									else if ( arrLine[0].StartsWith("DTEND") )
									{
										try
										{
											string sTZID = String.Empty;
											// DTEND;TZID=America/New_York:20111213T133000
											int nTZID = arrLine[0].IndexOf("TZID=");
											if ( nTZID >= 0 )
												sTZID = arrLine[0].Substring(nTZID + 5);
											else
												sTZID = String.Empty;
											// 02/12/2012 Paul.  An All-Day event does not include the time in the date strings. 
											if ( arrLine[1].Length == 8 )
											{
												eventTime.EndTime = SplendidCRM.Utils.CalDAV_ParseDate(arrLine[1]);
												eventTime.AllDay  = true;
											}
											else if ( arrLine[1].EndsWith("Z") )
											{
												eventTime.EndTime = SplendidCRM.Utils.CalDAV_ParseDate(arrLine[1]);
											}
											else
											{
												eventTime.EndTime = SplendidCRM.Utils.CalDAV_ParseDate(arrLine[1]);
												SplendidCRM.TimeZone oTimeZone = Context.Application["TIMEZONE.TZID." + sTZID] as SplendidCRM.TimeZone;
												if ( oTimeZone != null )
												{
													eventTime.EndTime = oTimeZone.ToServerTime(eventTime.EndTime);
												}
											}
										}
										catch
										{
										}
									}
								}
							}
						}
					}
					appointment.Times.Add(eventTime);
				}
			}
		}
		*/

	}
}
