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
using System.Runtime.InteropServices;
using System.Diagnostics;

namespace SplendidCRM.Import
{
	/// <summary>
	/// Summary description for ExportFile.
	/// </summary>
	public class ExportFile : SplendidPage
	{
		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				string sTempPath           = Path.GetTempPath();
				sTempPath = Path.Combine(sTempPath, "Splendid");
				string sExportFileID   = Sql.ToString(Request["FileID"]);
				string sExportPathName = Sql.ToString(Session["TempFile." + sExportFileID]);
				if ( !Sql.IsEmptyString(sExportPathName) )
				{
					if ( File.Exists(sExportPathName) )
					{
						Response.ContentType = System.Web.MimeMapping.GetMimeMapping(sExportPathName);
						Response.AddHeader("Content-Disposition", "attachment;filename=" + sExportFileID);
						const int nBLOCK_SIZE = 1024*1024;
						byte[] byData = new byte[nBLOCK_SIZE];
						using ( FileStream stm = File.OpenRead(sExportPathName) )
						{
							using ( BinaryWriter writer = new BinaryWriter(Response.OutputStream) )
							{
								int nOffset = 0;
								while ( nOffset < stm.Length )
								{
									int nReadSize = Math.Min(Convert.ToInt32(stm.Length) - nOffset, nBLOCK_SIZE);
									stm.Read(byData, 0, nReadSize);
									writer.Write(byData, 0, nReadSize);
									nOffset += nReadSize;
								}
							}
						}
					}
					else
					{
						throw(new Exception("File not found: " + sExportFileID));
					}
				}
				else
				{
					throw(new Exception("File not available in this session: " + sExportFileID));
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				Response.ContentType = "text/plain";
				Response.Write(ex.Message);
			}
			Response.End();
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
