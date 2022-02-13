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
using System.Text;
using System.Data;
using System.Data.Common;
using System.Collections;
using System.Globalization;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Xml;
using System.Net;
using ICSharpCode.SharpZipLib.Zip;
//using ICSharpCode.SharpZipLib.BZip2;
//using ICSharpCode.SharpZipLib.Zip.Compression;
//using ICSharpCode.SharpZipLib.Zip.Compression.Streams;
//using ICSharpCode.SharpZipLib.GZip;


namespace SplendidCRM.Administration.Terminology.Import
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		protected Label         lblError       ;
		protected HtmlInputFile fileIMPORT     ;
		protected CheckBox      chkTruncate    ;
		protected CheckBox      chkForceUTF8   ;
		protected Literal       lblImportErrors;
		protected LanguagePacks ctlLanguagePacks;
		// 10/05/2009 Paul.  We need to add the command handler to the language pack. 
		protected SplendidLanguagePacks ctlSplendidLanguagePacks;

		protected RequiredFieldValidator reqFILENAME    ;

		private bool bContinue = true;

		void ProcessDirectory(string strDirectory)
		{
			FileInfo objInfo ;
			if ( !bContinue )
				return;

			string[] arrFiles = Directory.GetFiles(strDirectory);
			for ( int i = 0 ; i < arrFiles.Length ; i++ )
			{
				objInfo = new FileInfo(arrFiles[i]);
				Response.Write(objInfo.FullName + "<br>" + ControlChars.CrLf);
			}
			
			string[] arrDirectories = Directory.GetDirectories(strDirectory);
			for ( int i = 0 ; i < arrDirectories.Length ; i++ )
			{
				objInfo = new FileInfo(arrDirectories[i]);
				ProcessDirectory(objInfo.FullName);
			}
		}

		protected void ImportFromStream(Stream stm)
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
						Response.Write(theEntry.Name + "<br>" + ControlChars.CrLf);
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
								if ( chkTruncate.Checked )
								{
									SqlProcs.spTERMINOLOGY_DeleteAll(sLang);
									hashLanguages.Add(sLang, String.Empty);
								}
							}
							try
							{
								LanguagePackImport.InsertTerms(theEntry.Name, stmZip, chkForceUTF8.Checked);
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

		protected void ImportFromXml(Stream stm)
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
							if ( chkTruncate.Checked )
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

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Next" )
			{
				reqFILENAME.Enabled = true;
				reqFILENAME.Validate();
				if ( Page.IsValid )
				{
					Response.Write("<div id=\"divImportList\">" + ControlChars.CrLf);
					try
					{
						// 07/03/2007 Paul.  Increase timeout to support slower machines. 
						Server.ScriptTimeout = 600;
						HttpPostedFile pstIMPORT = fileIMPORT.PostedFile;
						if ( pstIMPORT != null )
						{
							if ( pstIMPORT.FileName.Length > 0 )
							{
								string sFILENAME       = Path.GetFileName (pstIMPORT.FileName);
								string sFILE_EXT       = Path.GetExtension(sFILENAME);
								string sFILE_MIME_TYPE = pstIMPORT.ContentType;
								//string sLocalFile = Path.Combine(Path.GetTempPath(), sFILENAME);
								//pstIMPORT.SaveAs(sLocalFile);
								//ProcessDirectory(sLocalFile + "\\SugarRus\\manifest.php");
								if ( sFILE_MIME_TYPE == "application/x-zip-compressed" )
								{
									ImportFromStream(pstIMPORT.InputStream);
									lblError.Text = "Import Complete";
								}
								// 10/05/2009 Paul.  Allow direct import of XML file. 
								else if ( sFILE_MIME_TYPE == "text/xml" )
								{
									ImportFromXml(pstIMPORT.InputStream);
									lblError.Text = "Import Complete";
								}
								else
								{
									throw(new Exception("ZIP and XML are the only supported format at this time.  " + sFILE_MIME_TYPE));
								}
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						lblError.Text = ex.Message;
					}
					finally
					{
						Response.Write("</div>" + ControlChars.CrLf);
						RegisterClientScriptBlock("HideImportList", "<script type=\"text/javascript\">document.getElementById('divImportList').style.display='none';</script>");
					}
				}
			}
			else if ( e.CommandName == "LanguagePack.Import" )
			{
				Response.Write("<div id=\"divImportList\">" + ControlChars.CrLf);
				try
				{
					// 07/03/2007 Paul.  Increase timeout to support slower machines. 
					Server.ScriptTimeout = 600;
					string sURL = e.CommandArgument.ToString();
					if ( sURL.Length > 0 )
					{
						HttpWebRequest objRequest = (HttpWebRequest) WebRequest.Create(sURL);
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
									lblError.Text = objResponse.StatusCode + " " + objResponse.StatusDescription;
								}
								else
								{
									string sFILE_MIME_TYPE = objResponse.ContentType;
									if ( sFILE_MIME_TYPE.StartsWith("application/zip") )
									{
										ImportFromStream(objResponse.GetResponseStream());
										lblError.Text = "Import Complete";
									}
									// 10/05/2009 Paul.  The production servers return "text/xml; charset=utf-8". 
									else if ( sFILE_MIME_TYPE.StartsWith("text/xml") )
									{
										ImportFromXml(objResponse.GetResponseStream());
										lblError.Text = "Import Complete";
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
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					lblError.Text = ex.Message;
				}
				finally
				{
					Response.Write("</div>" + ControlChars.CrLf);
					RegisterClientScriptBlock("HideImportList", "<script type=\"text/javascript\">document.getElementById('divImportList').style.display='none';</script>");
				}
			}
			else if ( e.CommandName == "Back" )
			{
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term("Administration.LBL_MODULE_NAME"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "import") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			// 10/18/2010 Paul.  The required fields need to be bound manually. 
			reqFILENAME.DataBind();
			// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
			//this.DataBind();
			// 12/17/2005 Paul.  Don't buffer so that the connection can be kept alive. 
			Response.BufferOutput = false;
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
			ctlLanguagePacks.Command += new CommandEventHandler(Page_Command);
			// 10/05/2009 Paul.  We need to add the command handler to the language pack. 
			ctlSplendidLanguagePacks.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Terminology";
			// 05/06/2010 Paul.  The menu will show the admin Module Name in the Six theme. 
			SetMenu(m_sMODULE);
		}
		#endregion
	}
}

