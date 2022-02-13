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
using System.Xml;
using System.Data;
using System.Data.Common;
using System.Web;
using System.Diagnostics;

namespace SplendidCRM.FileBrowser
{
	public class Uploader : SplendidPage
	{
		// 02/11/2009 Paul.  This page must be accessible without authentication. 
		override protected bool AuthenticationRequired()
		{
			return false;
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			Response.CacheControl    = "no-cache";

			string sCustomMsg = String.Empty;
			string sFileURL   = String.Empty;
			try
			{
				if ( !Security.IsAuthenticated() )
				{
					sCustomMsg = "Authentication is required.";
				}
				else
				{
					Guid   gImageID  = Guid.Empty;
					
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
						using ( IDbTransaction trn = Sql.BeginTransaction(con) )
						{
							try
							{
								string sFileName = String.Empty;
								FileWorkerUtils.LoadImage(ref gImageID, ref sFileName, trn);
								if ( Sql.IsEmptyGuid(gImageID) )
								{
									sCustomMsg = "Failed to upload message.";
								}
								else
								{
									sFileURL = Utils.MassEmailerSiteURL(Context.Application) + "Images/EmailImage.aspx?ID=" + gImageID.ToString();
								}
								trn.Commit();
							}
							catch
							{
								trn.Rollback();
								throw;
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				sCustomMsg = ex.Message;
			}
			// 04/26/2012 Paul.  CKEditor 3.6.2 has a new technique for returning the uploaded image. 
			// http://stackoverflow.com/questions/9720734/image-upload-on-ckeditor-asp-net-4-response-to-upload-iframe-error
			Response.Write("<script type=\"text/javascript\">\n");
			Response.Write("window.parent.CKEDITOR.tools.callFunction(" + Request["CKEditorFuncNum"] + ",'" + Sql.EscapeJavaScript(sFileURL) + "','" + Sql.EscapeJavaScript(sCustomMsg) + "');\n");
			Response.Write("</script>\n");
			return;
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

