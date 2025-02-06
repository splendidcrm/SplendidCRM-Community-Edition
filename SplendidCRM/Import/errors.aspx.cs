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
	/// Summary description for Errors.
	/// </summary>
	public class Errors : SplendidPage
	{
		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				string sSourceType        = Sql.ToString(Request["SourceType"     ]);
				string sProcessedFileID   = Sql.ToString(Request["ProcessedFileID"]);
				string sProcessedFileName = Sql.ToString(Session["TempFile." + sProcessedFileID]);
				string sProcessedPathName = Path.Combine(Path.GetTempPath(), sProcessedFileName);
				if ( File.Exists(sProcessedPathName) )
				{
					DataSet dsProcessed = new DataSet();
					dsProcessed.ReadXml(sProcessedPathName);
					if ( dsProcessed.Tables.Count == 1 )
					{
						DataTable dt = dsProcessed.Tables[0];
						if ( dt.Rows.Count > 0 )
						{
							for ( int i = dt.Rows.Count - 1; i >= 0; i-- )
							{
								DataRow row = dt.Rows[i];
								if ( Sql.ToBoolean(row["IMPORT_ROW_STATUS"]) )
									row.Delete();
							}
							dt.AcceptChanges();
							
							if ( sSourceType == "other" || sSourceType == "custom_delimited" )
							{
								Response.ContentType = "text/csv";
								Response.AddHeader("Content-Disposition", "attachment;filename=import_errors.csv");
								SplendidExport.ExportDelimited(Response.OutputStream, new DataView(dt), "", 0, dt.Rows.Count, ',' );
							}
							else if ( sSourceType == "other_tab" )
							{
								// 08/17/2024 Paul.  The correct MIME type is text/plain. 
								Response.ContentType = "text/plain";
								Response.AddHeader("Content-Disposition", "attachment;filename=import_errors.txt");
								SplendidExport.ExportDelimited(Response.OutputStream, new DataView(dt), "", 0, dt.Rows.Count, '\t' );
							}
							else  // excel
							{
								Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";  //"application/vnd.ms-excel";
								Response.AddHeader("Content-Disposition", "attachment;filename=import_errors.xlsx");
								SplendidExport.ExportExcelOpenXML(Response.OutputStream, new DataView(dt), "", 0, dt.Rows.Count);
							}
						}
						else
						{
							throw(new Exception(L10n.Term("Import.ERR_NO_ERRORS")));
						}
					}
					else
					{
						throw(new Exception(L10n.Term("Import.ERR_NO_PROCESSED_TABLE")));
					}
				}
				else
				{
					throw(new Exception(L10n.Term("Import.ERR_NO_PROCESSED_FILE") + " " + sProcessedFileID));
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				Response.ContentType = "text/plain";
				Response.AddHeader("Content-Disposition", "attachment;filename=export_errors.txt");
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
