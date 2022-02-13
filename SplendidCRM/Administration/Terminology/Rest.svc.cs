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
using System.Xml;
using System.Net;
using System.Web;
using System.Data;
using System.Text;
using System.Web.Caching;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.ServiceModel.Activation;
using System.Web.Script.Serialization;
using ICSharpCode.SharpZipLib.Zip;
using System.Diagnostics;

namespace SplendidCRM.Administration.Terminology
{
	[ServiceContract]
	[ServiceBehavior( IncludeExceptionDetailInFaults = true )]
	[AspNetCompatibilityRequirements( RequirementsMode = AspNetCompatibilityRequirementsMode.Required )]
	public class Rest
	{
		public const string MODULE_NAME = "Terminology";

		private string HttpGetRequest(string sURL)
		{
			HttpWebRequest objRequest = (HttpWebRequest) WebRequest.Create(sURL);
			objRequest.Headers.Add("cache-control", "no-cache");
			objRequest.KeepAlive         = false;
			objRequest.AllowAutoRedirect = false;
			objRequest.Timeout           = 120000;  //120 seconds
			objRequest.Method            = "GET";

			string sResponse = String.Empty;
			// 01/11/2011 Paul.  Make sure to dispose of the response object as soon as possible. 
			using ( HttpWebResponse objResponse = (HttpWebResponse) objRequest.GetResponse() )
			{
				if ( objResponse != null )
				{
					if ( objResponse.StatusCode == HttpStatusCode.OK || objResponse.StatusCode == HttpStatusCode.Found )
					{
						using ( StreamReader readStream = new StreamReader(objResponse.GetResponseStream(), System.Text.Encoding.UTF8) )
						{
							sResponse = readStream.ReadToEnd();
						}
					}
				}
			}
			return sResponse;
		}

		[OperationContract]
		public Stream GetSugarLanguagePacks(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpServerUtility    Server      = HttpContext.Current.Server;
			Cache                Cache       = HttpRuntime.Cache;
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || SplendidCRM.Security.AdminUserAccess(MODULE_NAME, "edit") < 0 )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);

			Guid      gTIMEZONE   = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone  T10n        = TimeZone.CreateTimeZone(gTIMEZONE);
			DataTable dtPaginated = new DataTable();
			long      lTotalCount = 0;
			try
			{
				int    nSKIP     = Sql.ToInteger(Request["$skip"    ]);
				int    nTOP      = Sql.ToInteger(Request["$top"     ]);
				string sFILTER   = Sql.ToString (Request["$filter"  ]);
				string sORDER_BY = Sql.ToString (Request["$orderby" ]);
				// 06/17/2013 Paul.  Add support for GROUP BY. 
				string sGROUP_BY = Sql.ToString (Request["$groupby" ]);
				// 08/03/2011 Paul.  We need a way to filter the columns so that we can be efficient. 
				string sSELECT   = Sql.ToString (Request["$select"  ]);
				
				Dictionary<string, object> dictSearchValues = null;
				try
				{
					foreach ( string sName in dict.Keys )
					{
						switch ( sName )
						{
							case "$skip"           :  nSKIP            = Sql.ToInteger(dict[sName]);  break;
							case "$top"            :  nTOP             = Sql.ToInteger(dict[sName]);  break;
							case "$filter"         :  sFILTER          = Sql.ToString (dict[sName]);  break;
							case "$orderby"        :  sORDER_BY        = Sql.ToString (dict[sName]);  break;
							case "$groupby"        :  sGROUP_BY        = Sql.ToString (dict[sName]);  break;
							case "$select"         :  sSELECT          = Sql.ToString (dict[sName]);  break;
							case "$searchvalues"   :  dictSearchValues = dict[sName] as Dictionary<string, object>;  break;
						}
					}
					if ( dictSearchValues != null )
					{
					}
				}
				catch(Exception ex)
				{
					Debug.WriteLine(ex.Message);
					throw;
				}
				
				DataTable dt = Cache.Get("PublicSugarCRMLanguagePacks.xml") as DataTable;
				if ( dt == null )
				{
					XmlDocument xml = new XmlDocument();
					// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
					// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
					// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
					xml.XmlResolver = null;
					// 12/24/2008 Paul.  The data needs to be loaded every time. 
					try
					{
#if DEBUG
						xml.Load(Server.MapPath("Import\\PublicSugarCRMLanguagePacks.xml"));
#else
						xml.Load("http://demo.splendidcrm.com/Administration/Terminology/Import/PublicSugarCRMLanguagePacks.xml");
#endif
					}
					catch
					{
						xml.Load(Server.MapPath("Import\\PublicSugarCRMLanguagePacks.xml"));
					}
					dt = XmlUtil.CreateDataTable(xml.DocumentElement, "LanguagePack", new string[] {"Name", "Date", "Description", "URL"});
					Cache.Insert("PublicSugarCRMLanguagePacks.xml", dt, null, DateTime.Now.AddHours(1), System.Web.Caching.Cache.NoSlidingExpiration);
				}
				if ( Sql.IsEmptyString(sORDER_BY) )
					sORDER_BY = "Name asc";
				DataView vw = new DataView(dt);
				vw.Sort = sORDER_BY;

				dtPaginated = dt.Clone();
				for ( int i = nSKIP; i < vw.Count; i++ )
				{
					DataRow row = dtPaginated.NewRow();
					foreach ( DataColumn col in dtPaginated.Columns )
					{
						row[col.ColumnName] = vw[i].Row[col.ColumnName];
					}
					dtPaginated.Rows.Add(row);
					if ( dtPaginated.Rows.Count >= nTOP )
						break;
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
			
			string sBaseURI = Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath;
			// 04/01/2020 Paul.  Move json utils to RestUtil. 
			Dictionary<string, object> dictResponse = RestUtil.ToJson(sBaseURI, String.Empty, dtPaginated, T10n);
			dictResponse.Add("__total", lTotalCount);
			string sResponse = json.Serialize(dictResponse);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}

		[OperationContract]
		public Stream GetSplendidLanguagePacks(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpServerUtility    Server      = HttpContext.Current.Server;
			Cache                Cache       = HttpRuntime.Cache;
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || SplendidCRM.Security.AdminUserAccess(MODULE_NAME, "edit") < 0 )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			string sRequest = String.Empty;
			using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
			{
				sRequest = stmRequest.ReadToEnd();
			}
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = int.MaxValue;
			Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);

			Guid      gTIMEZONE   = Sql.ToGuid  (HttpContext.Current.Session["USER_SETTINGS/TIMEZONE"]);
			TimeZone  T10n        = TimeZone.CreateTimeZone(gTIMEZONE);
			DataTable dtPaginated = new DataTable();
			long      lTotalCount = 0;
			try
			{
				int    nSKIP     = Sql.ToInteger(Request["$skip"    ]);
				int    nTOP      = Sql.ToInteger(Request["$top"     ]);
				string sFILTER   = Sql.ToString (Request["$filter"  ]);
				string sORDER_BY = Sql.ToString (Request["$orderby" ]);
				// 06/17/2013 Paul.  Add support for GROUP BY. 
				string sGROUP_BY = Sql.ToString (Request["$groupby" ]);
				// 08/03/2011 Paul.  We need a way to filter the columns so that we can be efficient. 
				string sSELECT   = Sql.ToString (Request["$select"  ]);
				
				Dictionary<string, object> dictSearchValues = null;
				try
				{
					foreach ( string sName in dict.Keys )
					{
						switch ( sName )
						{
							case "$skip"           :  nSKIP            = Sql.ToInteger(dict[sName]);  break;
							case "$top"            :  nTOP             = Sql.ToInteger(dict[sName]);  break;
							case "$filter"         :  sFILTER          = Sql.ToString (dict[sName]);  break;
							case "$orderby"        :  sORDER_BY        = Sql.ToString (dict[sName]);  break;
							case "$groupby"        :  sGROUP_BY        = Sql.ToString (dict[sName]);  break;
							case "$select"         :  sSELECT          = Sql.ToString (dict[sName]);  break;
							case "$searchvalues"   :  dictSearchValues = dict[sName] as Dictionary<string, object>;  break;
						}
					}
					if ( dictSearchValues != null )
					{
					}
				}
				catch(Exception ex)
				{
					Debug.WriteLine(ex.Message);
					throw;
				}
				
				DataTable dt = Cache.Get("SplendidLanguagePacks.xml") as DataTable;
				if ( dt == null )
				{
					XmlDocument xml = new XmlDocument();
					// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
					// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
					// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
					xml.XmlResolver = null;
					// 12/24/2008 Paul.  The data needs to be loaded every time. 
					try
					{
						// 10/05/2009 Paul.  We need to be able to debug the production language packs. 
#if FALSE
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							string sSQL;
							string sLanguagePackURL = Request.Url.AbsoluteUri.Substring(0, Request.Url.AbsoluteUri.Length - Request.Url.Segments[Request.Url.Segments.Length-1].Length - Request.Url.Segments[Request.Url.Segments.Length-2].Length) + "Export/Terminology.aspx?LANG=";
							sSQL = "select DISPLAY_NAME     as Name       " + ControlChars.CrLf
								    + "     , ''               as Date       " + ControlChars.CrLf
								    + "     , NATIVE_NAME      as Description" + ControlChars.CrLf
								    + "     , @PACK_URL + NAME as URL        " + ControlChars.CrLf
								    + "  from vwLANGUAGES                    " + ControlChars.CrLf
								    + " order by Name                        " + ControlChars.CrLf
								    + "  for xml raw('LanguagePack'), elements" + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@PACK_URL", sLanguagePackURL);
								using ( IDataReader rdr = cmd.ExecuteReader() )
								{
									StringBuilder sbXML = new StringBuilder();
									sbXML.AppendLine("<?xml version=\"1.0\" encoding=\"utf-8\" ?>");
									sbXML.AppendLine("<xml>");
									while ( rdr.Read() )
										sbXML.Append(Sql.ToString(rdr[0]));
									sbXML.AppendLine("</xml>");
										
									xml.LoadXml(sbXML.ToString());
								}
							}
						}
#else
						// 11/30/2008 Paul.  Change name of service level to Community. 
						// 07/11/2011 Paul.  xml.Load() is not working. 
						// Data at the root level is invalid. Line 1, position 1. 
						// 07/11/2011 Paul.  We are getting an unexplained "Object reference not set to an instance of an object", so make sure to clear the buffer. 
						// 07/11/2011 Paul.  The problem was a NULL UserAgent in SplendidInit.InitSession().  Keep these changes just in case there is a problem in the future. 
						string sServiceLevel = Sql.ToString(Application["CONFIG.service_level"]);
						if ( String.Compare(sServiceLevel, "Basic", true) == 0 || String.Compare(sServiceLevel, "Community", true) == 0 )
						{
							string sResponse = HttpGetRequest("http://community.splendidcrm.com/Administration/Terminology/Export/Languages.aspx");
							if ( !sResponse.StartsWith("<?xml") && sResponse.Contains("<?xml") )
								sResponse = sResponse.Substring(sResponse.IndexOf("<?xml"));
							xml.LoadXml(sResponse);
						}
						else if ( String.Compare(sServiceLevel, "Enterprise", true) == 0 )
						{
							string sResponse = HttpGetRequest("http://enterprise.splendidcrm.com/Administration/Terminology/Export/Languages.aspx");
							if ( !sResponse.StartsWith("<?xml") && sResponse.Contains("<?xml") )
								sResponse = sResponse.Substring(sResponse.IndexOf("<?xml"));
							xml.LoadXml(sResponse);
						}
						// 11/06/2015 Paul.  Add support for the Ultimate edition. 
						else if ( String.Compare(sServiceLevel, "Ultimate", true) == 0 )
						{
							string sResponse = HttpGetRequest("http://ultimate.splendidcrm.com/Administration/Terminology/Export/Languages.aspx");
							if ( !sResponse.StartsWith("<?xml") && sResponse.Contains("<?xml") )
								sResponse = sResponse.Substring(sResponse.IndexOf("<?xml"));
							xml.LoadXml(sResponse);
						}
						else // if ( String.Compare(sServiceLevel, "Professional", true) == 0 )
						{
							string sResponse = HttpGetRequest("http://professional.splendidcrm.com/Administration/Terminology/Export/Languages.aspx");
							if ( !sResponse.StartsWith("<?xml") && sResponse.Contains("<?xml") )
								sResponse = sResponse.Substring(sResponse.IndexOf("<?xml"));
							xml.LoadXml(sResponse);
						}
#endif
					}
					catch //(Exception ex)
					{
						// 10/21/2009 Paul.  We are getting regular errors on the first attempt, so lets always retry. 
						// The remote server returned an error: (500) Internal Server Error. 
						// 11/30/2008 Paul.  Change name of service level to Community. 
						string sServiceLevel = Sql.ToString(Application["CONFIG.service_level"]);
						if ( String.Compare(sServiceLevel, "Basic", true) == 0 || String.Compare(sServiceLevel, "Community", true) == 0 )
						{
							string sResponse = HttpGetRequest("http://community.splendidcrm.com/Administration/Terminology/Export/Languages.aspx");
							if ( !sResponse.StartsWith("<?xml") && sResponse.Contains("<?xml") )
								sResponse = sResponse.Substring(sResponse.IndexOf("<?xml"));
							xml.LoadXml(sResponse);
						}
						else if ( String.Compare(sServiceLevel, "Enterprise", true) == 0 )
						{
							string sResponse = HttpGetRequest("http://enterprise.splendidcrm.com/Administration/Terminology/Export/Languages.aspx");
							if ( !sResponse.StartsWith("<?xml") && sResponse.Contains("<?xml") )
								sResponse = sResponse.Substring(sResponse.IndexOf("<?xml"));
							xml.LoadXml(sResponse);
						}
						// 11/06/2015 Paul.  Add support for the Ultimate edition. 
						else if ( String.Compare(sServiceLevel, "Ultimate", true) == 0 )
						{
							string sResponse = HttpGetRequest("http://ultimate.splendidcrm.com/Administration/Terminology/Export/Languages.aspx");
							if ( !sResponse.StartsWith("<?xml") && sResponse.Contains("<?xml") )
								sResponse = sResponse.Substring(sResponse.IndexOf("<?xml"));
							xml.LoadXml(sResponse);
						}
						else // if ( String.Compare(sServiceLevel, "Professional", true) == 0 )
						{
							string sResponse = HttpGetRequest("http://professional.splendidcrm.com/Administration/Terminology/Export/Languages.aspx");
							if ( !sResponse.StartsWith("<?xml") && sResponse.Contains("<?xml") )
								sResponse = sResponse.Substring(sResponse.IndexOf("<?xml"));
							xml.LoadXml(sResponse);
						}
					}
					// 07/20/2010 Paul.  If we fail to get the document, then don't attempt to load it. 
					if ( xml.DocumentElement != null )
						dt = XmlUtil.CreateDataTable(xml.DocumentElement, "LanguagePack", new string[] {"Name", "Date", "Description", "URL"});
				}
				if ( Sql.IsEmptyString(sORDER_BY) )
					sORDER_BY = "Name asc";
				DataView vw = new DataView(dt);
				vw.Sort = sORDER_BY;

				dtPaginated = dt.Clone();
				for ( int i = nSKIP; i < vw.Count; i++ )
				{
					DataRow row = dtPaginated.NewRow();
					foreach ( DataColumn col in dtPaginated.Columns )
					{
						row[col.ColumnName] = vw[i].Row[col.ColumnName];
					}
					dtPaginated.Rows.Add(row);
					if ( dtPaginated.Rows.Count >= nTOP )
						break;
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
			
			string sBaseURI = Request.Url.Scheme + "://" + Request.Url.Host + Request.Url.AbsolutePath;
			// 04/01/2020 Paul.  Move json utils to RestUtil. 
			Dictionary<string, object> dictResponse = RestUtil.ToJson(sBaseURI, String.Empty, dtPaginated, T10n);
			dictResponse.Add("__total", lTotalCount);
			string sJsonResponse = json.Serialize(dictResponse);
			byte[] byResponse = Encoding.UTF8.GetBytes(sJsonResponse);
			return new MemoryStream(byResponse);
		}

		private void ImportFromStream(Stream stm, bool bTruncate, bool bForceUTF8)
		{
			// http://msdn.microsoft.com/msdnmag/issues/03/06/ZipCompression/default.aspx
			// http://community.sharpdevelop.net/forums/738/ShowPost.aspx
			// The #ZipLib is licensed under a modified GPL. This modification grants you the right to use the compiled  .DLL in closed source applications. 
			// Modifcations to the library however fall under the provisions of the GPL.
			// 01/30/2008 Paul.  Capture errors. 
			StringBuilder sbErrors = new StringBuilder();
			Hashtable hashLanguages = new Hashtable();
			using ( ZipInputStream stmZip = new ZipInputStream(stm) )
			{
				ZipEntry theEntry = null;
				while ( (theEntry = stmZip.GetNextEntry()) != null )
				{
					string sFileName = Path.GetFileName(theEntry.Name);
					if ( sFileName != String.Empty )
					{
						if ( theEntry.Name.EndsWith(".lang.php") )
						{
							string sLang = LanguagePackImport.GetLanguage(theEntry.Name);
							// 11/13/2006 Paul.  SugarCRM still has not fixed their German language pack. Convert ge-GE to de-DE.
							if ( String.Compare(sLang, "ge-GE", true) == 0 )
								sLang = "de-DE";
							// 12/23/2008 Paul.  Vietnamese needs to fix the SugarCRM international code. 
							else if ( String.Compare(sLang, "vn-VN", true) == 0 )
								sLang = "vi-VN";
							// 08/22/2007 Paul.  Only insert the language record once. 
							if ( !hashLanguages.ContainsKey(sLang) )
							{
								CultureInfo culture = new CultureInfo(sLang);
								if ( culture == null )
									throw(new Exception("Unknown language: " + sLang));
								SqlProcs.spLANGUAGES_InsertOnly(sLang, culture.LCID, true, culture.NativeName, culture.DisplayName);
								// 12/22/2008 Paul.  Enable after inserting, just in case the language already exists and is currently disabled. 
								SqlProcs.spLANGUAGES_Enable(sLang);
								if ( bTruncate )
								{
									SqlProcs.spTERMINOLOGY_DeleteAll(sLang);
									hashLanguages.Add(sLang, String.Empty);
								}
							}
							try
							{
								LanguagePackImport.InsertTerms(theEntry.Name, stmZip, bForceUTF8);
							}
							catch(Exception ex)
							{
								// 01/30/2008 Paul.  Accumulate the errors. 
								sbErrors.AppendLine(theEntry.Name + ": " + ex.Message);
							}
						}
					}
				}
				// 01/12/2006 Paul.  Update internal cache. 
				// 10/26/2008 Paul.  IIS7 Integrated Pipeline does not allow HttpContext access inside Application_Start. 
				SplendidInit.InitTerminology(HttpContext.Current);
				// 01/13/2006 Paul.  Clear the language cache. 
				SplendidCache.ClearLanguages();
				if ( sbErrors.Length > 0 )
				{
					throw(new Exception(sbErrors.ToString()));
				}
			}
		}

		private void ImportFromXml(Stream stm, bool bTruncate)
		{
			StringBuilder sbErrors = new StringBuilder();
			XmlDocument xml = new XmlDocument();
			// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
			// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
			// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
			xml.XmlResolver = null;
			xml.Load(stm);
			
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				using ( IDbCommand cmdLANGUAGES_InsertOnly = SqlProcs.cmdLANGUAGES_InsertOnly(con) )
				{
					XmlNodeList nlLANGUAGES = xml.DocumentElement.SelectNodes("LANGUAGES");
					foreach ( XmlNode xTerm in nlLANGUAGES )
					{
						foreach(IDbDataParameter par in cmdLANGUAGES_InsertOnly.Parameters)
						{
							par.Value = DBNull.Value;
						}
						string sNAME = String.Empty;
						foreach ( XmlNode node in xTerm.ChildNodes )
						{
							// 01/24/2014 Paul.  The tag name is NAME not LANG. Also fix value. 
							if ( node.Name == "NAME" )
								sNAME = node.InnerText;
							// 10/05/2009 Paul.  The correct field is InnerText.  This is because the nodes are elements not attributes. 
							Sql.SetParameter(cmdLANGUAGES_InsertOnly, node.Name, Sql.ToString(node.InnerText));
						}
						try
						{
							cmdLANGUAGES_InsertOnly.ExecuteNonQuery();
							// 12/22/2008 Paul.  Enable after inserting, just in case the language already exists and is currently disabled. 
							SqlProcs.spLANGUAGES_Enable(sNAME);
							if ( bTruncate )
							{
								SqlProcs.spTERMINOLOGY_DeleteAll(sNAME);
							}
						}
						catch(Exception ex)
						{
							sbErrors.AppendLine(sNAME + ": " + ex.Message);
						}
					}
				}
				using ( IDbCommand cmdTERMINOLOGY_InsertOnly = SqlProcs.cmdTERMINOLOGY_InsertOnly(con) )
				{
					XmlNodeList nlTERMINOLOGY = xml.DocumentElement.SelectNodes("TERMINOLOGY");
					foreach ( XmlNode xTerm in nlTERMINOLOGY )
					{
						foreach(IDbDataParameter par in cmdTERMINOLOGY_InsertOnly.Parameters)
						{
							par.Value = DBNull.Value;
						}
						string sNAME        = String.Empty;
						string sMODULE_NAME = String.Empty;
						foreach ( XmlNode node in xTerm.ChildNodes )
						{
							// 10/05/2009 Paul.  The correct field is InnerText.  This is because the nodes are elements not attributes. 
							if ( node.Name == "NAME" )
								sNAME = Sql.ToString(node.InnerText);
							else if ( node.Name == "MODULE_NAME" )
								sMODULE_NAME = Sql.ToString(node.InnerText);
							Sql.SetParameter(cmdTERMINOLOGY_InsertOnly, node.Name, Sql.ToString(node.InnerText));
						}
						try
						{
							cmdTERMINOLOGY_InsertOnly.ExecuteNonQuery();
						}
						catch(Exception ex)
						{
							sbErrors.AppendLine(sMODULE_NAME + "." + sNAME + ": " + ex.Message);
						}
					}
				}
			}

			// 01/12/2006 Paul.  Update internal cache. 
			// 10/26/2008 Paul.  IIS7 Integrated Pipeline does not allow HttpContext access inside Application_Start. 
			SplendidInit.InitTerminology(HttpContext.Current);
			// 01/13/2006 Paul.  Clear the language cache. 
			SplendidCache.ClearLanguages();
			if ( sbErrors.Length > 0 )
			{
				throw(new Exception(sbErrors.ToString()));
			}
		}

		[OperationContract]
		[WebInvoke(Method="POST", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public void ImportLanguagePackFile(bool Truncate, bool ForceUTF8, string FILE_MIME_TYPE, string FILE_DATA)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			Cache                Cache       = HttpRuntime.Cache;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || SplendidCRM.Security.AdminUserAccess(MODULE_NAME, "edit") < 0 )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			if ( Sql.IsEmptyString(FILE_DATA) )
			{
				throw(new Exception("Missing FILE_DATA"));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			byte[] byFILE_DATA = new byte[] {};
			if ( !Sql.IsEmptyString(FILE_DATA) )
				byFILE_DATA = Convert.FromBase64String(FILE_DATA);
			using ( MemoryStream stm = new MemoryStream(byFILE_DATA) )
			{
				if ( FILE_MIME_TYPE == "application/x-zip-compressed" )
				{
					ImportFromStream(stm, Truncate, ForceUTF8);
				}
				// 10/05/2009 Paul.  Allow direct import of XML file. 
				else if ( FILE_MIME_TYPE == "text/xml" )
				{
					ImportFromXml(stm, Truncate);
				}
				else
				{
					throw(new Exception("ZIP and XML are the only supported format at this time.  " + FILE_MIME_TYPE));
				}
			}
		}


		[OperationContract]
		[WebInvoke(Method="POST", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public void ImportLanguagePackURL(bool Truncate, bool ForceUTF8, string URL)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			Cache                Cache       = HttpRuntime.Cache;
			
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || SplendidCRM.Security.AdminUserAccess(MODULE_NAME, "edit") < 0 )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			if ( Sql.IsEmptyString(URL) )
			{
				throw(new Exception("Missing URL"));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			HttpWebRequest objRequest = (HttpWebRequest) WebRequest.Create(URL);
			objRequest.Headers.Add("cache-control", "no-cache");
			objRequest.KeepAlive         = false;
			objRequest.AllowAutoRedirect = true;
			objRequest.Timeout           = 120000;  //120 seconds
			objRequest.Method            = "GET";

			// 01/11/2011 Paul.  Make sure to dispose of the response object as soon as possible. 
			using ( HttpWebResponse objResponse = (HttpWebResponse) objRequest.GetResponse() )
			{
				if ( objResponse != null )
				{
					if ( objResponse.StatusCode != HttpStatusCode.OK && objResponse.StatusCode != HttpStatusCode.Found )
					{
						throw(new Exception(objResponse.StatusCode + " " + objResponse.StatusDescription));
					}
					else
					{
						string sFILE_MIME_TYPE = objResponse.ContentType;
						if ( sFILE_MIME_TYPE.StartsWith("application/x-zip-compressed") )
						{
							ImportFromStream(objResponse.GetResponseStream(), Truncate, ForceUTF8);
						}
						// 10/05/2009 Paul.  Allow direct import of XML file. 
						else if ( sFILE_MIME_TYPE.StartsWith("text/xml") )
						{
							ImportFromXml(objResponse.GetResponseStream(), Truncate);
						}
						else
						{
							throw(new Exception("ZIP and XML are the only supported format at this time.  " + sFILE_MIME_TYPE));
						}
					}
				}
			}
		}
	}
}
