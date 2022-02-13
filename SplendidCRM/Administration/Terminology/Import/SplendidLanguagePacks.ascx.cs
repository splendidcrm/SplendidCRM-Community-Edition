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
using System.Net;
using System.Text;
using System.Data;
using System.Data.Common;
using System.Xml;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Administration.Terminology.Import
{
	/// <summary>
	///		Summary description for SplendidLanguagePacks.
	/// </summary>
	public class SplendidLanguagePacks : SplendidControl
	{
		protected DataView        vwMain         ;
		protected SplendidGrid    grdMain        ;
		protected Label           lblError       ;

		public CommandEventHandler Command ;

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

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			if ( Command != null )
				Command(this, e) ;
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "import") >= 0);
			if ( !this.Visible )
				return;
			try
			{
				// 10/27/2008 Paul.  Skip during precompile. 
				if ( !Sql.ToBoolean(Request["PrecompileOnly"]) )
				{
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
							try
							{
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
							catch(Exception ex1)
							{
								lblError.Text = ex1.Message;
							}
						}
						// 07/20/2010 Paul.  If we fail to get the document, then don't attempt to load it. 
						if ( xml.DocumentElement != null )
							dt = XmlUtil.CreateDataTable(xml.DocumentElement, "LanguagePack", new string[] {"Name", "Date", "Description", "URL"});
#if !DEBUG
						// 12/13/2008 Paul.  Don't cache if there is no data. 
						if ( xml.DocumentElement != null && dt.Rows.Count > 0 )
							Cache.Insert("SplendidLanguagePacks.xml", dt, null, DateTime.Now.AddMinutes(5), System.Web.Caching.Cache.NoSlidingExpiration);
#endif
					}
					// 07/20/2010 Paul.  If we fail to get the document, then don't attempt to load it. 
					if ( dt != null )
					{
						vwMain = new DataView(dt);
						vwMain.RowFilter = "URL > ''";
						vwMain.Sort      = "Name";
						grdMain.DataSource = vwMain ;
						// 12/24/2008 Paul.  We need to rebind every time.  Pagination will still work. 
						//if ( !IsPostBack )
						{
							grdMain.DataBind();
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		#region Web Form Designer generated code
		override protected void OnInit(EventArgs e)
		{
			//
			// CODEGEN: This call is required by the ASP.NET Web Form Designer.
			//
			InitializeComponent();
			base.OnInit(e);
		}
		
		/// <summary>
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
			m_sMODULE = "Terminology";
		}
		#endregion
	}
}

