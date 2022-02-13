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
using System.Data.Common;
using System.Collections;
using System.Collections.Specialized;
using System.IO;
using System.Text;
using System.Net;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Diagnostics;

namespace SplendidCRM._devtools
{
	/// <summary>
	/// Summary description for Precompile.
	/// </summary>
	public class Precompile : System.Web.UI.Page
	{
		protected DataTable dtMain    ;
		protected Label     lblRoot   ;
		protected Label     lblCurrent;
		protected Label     lblStatus ;
		protected Label     lblErrors ;
		protected ListBox   lstFiles  ;
		protected Repeater  rptLinks  ;

		private bool GetHttp(string strPrecompileURL, out string strResult)
		{
			strResult = "" ;
			bool bGetHttp = false;
			try
			{
				HttpWebRequest objRequest = (HttpWebRequest) WebRequest.Create(strPrecompileURL + "?PrecompileOnly=1");
				objRequest.Headers.Add("accept-encoding", "gzip, deflate");
				objRequest.Headers.Add("cache-control", "no-cache");
				objRequest.KeepAlive = false;
				objRequest.AllowAutoRedirect = true;
				objRequest.Timeout = 120000;  //120 seconds
				//objRequest.Accept            = "*/*";
				//objRequest.ContentType       = "application/x-www-form-urlencoded";
				objRequest.Method = "GET";
				//objRequest.ContentLength     = 0;

				// 01/11/2011 Paul.  Make sure to dispose of the response object as soon as possible. 
				using ( HttpWebResponse objResponse = (HttpWebResponse) objRequest.GetResponse() )
				{
					if ( objResponse != null )
					{
						if ( objResponse.StatusCode != HttpStatusCode.OK && objResponse.StatusCode != HttpStatusCode.Redirect )
							strResult = objResponse.StatusCode + " " + objResponse.StatusDescription;
						StreamReader readStream = new StreamReader(objResponse.GetResponseStream(), System.Text.Encoding.UTF8);
						strResult += readStream.ReadToEnd();
						readStream.Close();
						if ( objResponse.StatusCode == HttpStatusCode.OK )
							bGetHttp = true;
					}
				}
			}
			catch(WebException ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				strResult = ex.Message;
				//bContinue = false;
			}
			return bGetHttp;
		}

		private void PrecompileDirectoryTree(string strDirectory, string strRootURL, IDbConnection con)
		{
			FileInfo objInfo ;

			string[] arrFiles = Directory.GetFiles(strDirectory);
			for ( int i = 0 ; i < arrFiles.Length ; i++ )
			{
				objInfo = new FileInfo(arrFiles[i]);
				// 09/14/2011 Paul.  Lets include the SVC files so that we can catch problems that would require ServiceModelReg.exe. 
				if ( (String.Compare(objInfo.Name, "Precompile.aspx", true) != 0 ) && (String.Compare(objInfo.Extension, ".aspx", true) == 0 || String.Compare(objInfo.Extension, ".svc", true) == 0) && Response.IsClientConnected )
				{
					// 05/09/2008 Paul.  We cannot precompile the Logout page because it will stop the precompile. 
					if ( !Security.IsWindowsAuthentication() && (String.Compare(objInfo.Name, "Logout.aspx", true) == 0) )
						continue;
					// 05/09/2008 Paul.  Not sure why, but the precompile stops on Image.aspx. 
					// 04/28/2012 Paul.  Also exclude EmailImage.aspx and Login.aspx. 
					// 12/26/2012 Paul.  Exclude new AcceptDecline as it will generate an error when no parameters are provided. 
					// 12/22/2017 Paul.  Exclude new Import errors file. 
					if ( String.Compare(objInfo.Name, "AcceptDecline.aspx", true) == 0 || String.Compare(objInfo.Name, "Image.aspx", true) == 0 || String.Compare(objInfo.Name, "EmailImage.aspx", true) == 0 || String.Compare(objInfo.Name, "Login.aspx", true) == 0 || String.Compare(objInfo.Name, "errors.aspx", true) == 0 )
						continue;
					// 02/20/2010 Paul.  Not sure why, but the precompile stops on Home/default.aspx. 
					if ( (String.Compare(objInfo.Name, "default.aspx", true) == 0) && strRootURL.EndsWith("Home/") )
						continue;
					// 05/21/2014 Paul.  Exclude web capture pages as they can create empty records. 
					if ( String.Compare(objInfo.Name, "WebToLeadCapture.aspx", true) == 0 || String.Compare(objInfo.Name, "WebToContactCapture.aspx", true) == 0 )
						continue;
					DataRow row = dtMain.NewRow();
					row["NAME"    ] = strRootURL + objInfo.Name;
					row["IS_ADMIN"] = strRootURL.Contains("Administration");
					dtMain.Rows.Add(row);
					// 11/27/2013 Paul.  Add first record of module to catch relationship errors. 
					if ( String.Compare(objInfo.Name, "edit.aspx", true) == 0 || String.Compare(objInfo.Name, "view.aspx", true) == 0 )
					{
						string[] arrPath = strDirectory.Split('\\');
						string sMODULE = arrPath[arrPath.Length - 1];
						if ( Sql.ToBoolean(Application["Modules." + sMODULE + ".Valid"]) )
						{
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								string sTABLE_NAME = Sql.ToString(Application["Modules." + sMODULE + ".TableName"]);
								// 11/27/2013 Paul.  vwSHORTCUTS and vwWORKFLOW do not return ID. 
								if ( !Sql.IsEmptyString(sTABLE_NAME) && sTABLE_NAME != "SHORTCUTS" && sTABLE_NAME != "WORKFLOW" && sTABLE_NAME != "PRODUCTS" )
								{
									cmd.CommandText = "  from vw" + sTABLE_NAME + ControlChars.CrLf;
									Security.Filter(cmd, sMODULE, "list");
									{
										cmd.CommandText = "select ID" + cmd.CommandText + " order by ID";
										Sql.LimitResults(cmd, 1);
										try
										{
											using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
											{
												if ( rdr.Read() )
												{
													Guid gID = Sql.ToGuid(rdr["ID"]);
													row = dtMain.NewRow();
													row["NAME"    ] = strRootURL + objInfo.Name + "?ID=" + gID.ToString();
													row["IS_ADMIN"] = strRootURL.Contains("Administration");
													dtMain.Rows.Add(row);
												}
											}
										}
										catch(Exception ex)
										{
											Debug.WriteLine(sTABLE_NAME + ": " + ex.Message);
										}
									}
								}
							}
						}
					}
				}
			}

			string[] arrDirectories = Directory.GetDirectories(strDirectory);
			for ( int i = 0 ; i < arrDirectories.Length ; i++ )
			{
				objInfo = new FileInfo(arrDirectories[i]);
				// 08/29/2005 Paul.  Nothing in the _code folder should be PreCompiled. 
				// 01/18/2008 Paul.  _devtools should not be precompiled. 
				// 05/09/2008 Paul.  FCKeditor should not be precompiled. 
				// 09/13/2009 Paul.  Make sure not to precompile the WebTemplate files. 
				// 03/16/2010 Paul.  Exclude WebTemplatesLive files. 
				// 07/20/2010 Paul.  The Amazon FlexiblePayments files are no longer included in the project, but are still distributed, so manually exclude. 
				// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
				// 06/30/2017 Paul.  Exclude node_modules in BusinessProcess module. 
				// 11/17/2017 Paul.  Exclude packages. 
				// 02/11/2022 Paul.  Exclude Blazor. 
				if (   (String.Compare(objInfo.Name, "_devtools"       , true) != 0) 
					&& (String.Compare(objInfo.Name, "_code"           , true) != 0) 
					&& (String.Compare(objInfo.Name, "_vti_cnf"        , true) != 0) 
					&& (String.Compare(objInfo.Name, "_sgbak"          , true) != 0) 
					&& (String.Compare(objInfo.Name, ".vs"             , true) != 0) 
					&& (String.Compare(objInfo.Name, "packages"        , true) != 0) 
					&& (String.Compare(objInfo.Name, "node_modules"    , true) != 0) 
					&& (String.Compare(objInfo.Name, "ckeditor"        , true) != 0) 
					&& (String.Compare(objInfo.Name, "FCKeditor"       , true) != 0) 
					&& (String.Compare(objInfo.Name, "WebTemplates"    , true) != 0) 
					&& (String.Compare(objInfo.Name, "WebTemplatesLive", true) != 0) 
					&& (String.Compare(objInfo.Name, "FlexiblePayments", true) != 0) 
					&& (String.Compare(objInfo.Name, "FlexiblePaymentsTokens", true) != 0) 
					&& (String.Compare(objInfo.Name, "Blazor"          , true) != 0) 
					)
					PrecompileDirectoryTree(objInfo.FullName, strRootURL + objInfo.Name + "/", con);
			}
		}

		void Page_Load(object sender, System.EventArgs e)
		{
			// 01/11/2006 Paul.  Only a developer/administrator should see this. 
			if ( !(SplendidCRM.Security.AdminUserAccess("Administration", "access") >= 0) )
				return;

			dtMain = new DataTable();
			dtMain.Columns.Add("NAME"    , typeof(System.String ));
			dtMain.Columns.Add("IS_ADMIN", typeof(System.Boolean));

			string sApplicationPath = Request.ApplicationPath;
			if ( !sApplicationPath.EndsWith("/") )
				sApplicationPath += "/";
			
			// 11/27/2013 Paul.  Open the connection string only once. 
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string[] arrFolders = Request.QueryString.GetValues("folder");
				if ( arrFolders == null || arrFolders.Length == 0 )
					PrecompileDirectoryTree(Server.MapPath(".."), "", con);
				else
				{
					for ( int i = 0 ; i < arrFolders.Length ; i++ )
					{
						PrecompileDirectoryTree(Server.MapPath("../" + arrFolders[i]), arrFolders[i] + "/", con);
					}
				}
			}
			// 06/30/2017 Paul.  Add important REST queries. 
			DataRow row = dtMain.NewRow();
			row["NAME"    ] = "Rest.svc/GetModuleTable?TableName=MODULES&$orderby=MODULE_NAME";
			row["IS_ADMIN"] = false;
			dtMain.Rows.Add(row);
			row = dtMain.NewRow();
			row["NAME"    ] = "Rest.svc/GetAllLayouts";
			row["IS_ADMIN"] = false;
			dtMain.Rows.Add(row);

			// 06/04/2012 Paul.  Include the port number if it is not a standard port. 
			if ( Request.Url.Port != 80 && Request.Url.Port != 443 )
				lblRoot.Text = Request.Url.Scheme + "://" + Request.Url.Host + ":" + Request.Url.Port.ToString() + sApplicationPath;
			else
				lblRoot.Text = Request.Url.Scheme + "://" + Request.Url.Host + sApplicationPath;

			// 10/27/2008 Paul.  Move admin pages to the bottom. 
			DataView vwMain = new DataView(dtMain);
			vwMain.Sort = "IS_ADMIN asc, NAME asc";
			lstFiles.DataSource = vwMain;
			lstFiles.DataBind();

			// 06/04/2015 Paul.  Provide a way to manually navigate. 
			if ( Sql.ToBoolean(Request["links"]) )
			{
				DataView vwLinks = new DataView(dtMain);
				vwLinks.Sort = "IS_ADMIN asc, NAME asc";
				if ( Sql.ToBoolean(Request["view"]) )
					vwLinks.RowFilter = "NAME like '%/view.aspx?ID=%'";
				else if ( Sql.ToBoolean(Request["edit"]) )
					vwLinks.RowFilter = "NAME like '%/edit.aspx?ID=%'";
				else if ( Sql.ToBoolean(Request["create"]) )
					vwLinks.RowFilter = "NAME like '%/edit.aspx'";
				else if ( Sql.ToBoolean(Request["list"]) )
					vwLinks.RowFilter = "NAME like '%/default.aspx'";
				else if ( Sql.ToBoolean(Request["import"]) )
					vwLinks.RowFilter = "NAME like '%/import.aspx'";
				else if ( Sql.ToBoolean(Request["popup"]) )
					vwLinks.RowFilter = "NAME like '%/Popup%.aspx'";
				rptLinks.Visible    = true;
				rptLinks.DataSource = vwLinks;
				rptLinks.DataBind();
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
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);
		}
		#endregion
	}
}
