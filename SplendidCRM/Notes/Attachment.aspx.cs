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
using System.Drawing.Imaging;
using System.Diagnostics;

namespace SplendidCRM.Notes
{
	/// <summary>
	/// Summary description for Attachment.
	/// </summary>
	public class Attachment : SplendidPage
	{
		// 10/20/2009 Paul.  Move blob logic to WriteStream. 
		// 10/30/2021 Paul.  Move WriteStream to ModuleUtils. 

		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				Guid gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					if ( !Sql.IsEmptyGuid(gID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							string sSQL ;
							sSQL = "select *                 " + ControlChars.CrLf
							     + "  from vwNOTE_ATTACHMENTS" + ControlChars.CrLf
							     + " where ID = @ID          " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@ID", gID);
								using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
								{
									if ( rdr.Read() )
									{
										Response.ContentType = Sql.ToString(rdr["FILE_MIME_TYPE"]);
										// 01/27/2011 Paul.  Don't use GetFileName as the name may contain reserved directory characters, but expect them to be removed in Utils.ContentDispositionEncode. 
										string sFileName = Sql.ToString(rdr["FILENAME"]);
										// 08/06/2008 yxy21969.  Make sure to encode all URLs.
										// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
										Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(Request.Browser, sFileName));
									}
								}
							}
							try
							{
								using ( BinaryWriter writer = new BinaryWriter(Response.OutputStream) )
								{
									// 10/20/2009 Paul.  Move blob logic to WriteStream. 
									// 10/30/2021 Paul.  Move WriteStream to ModuleUtils. 
									ModuleUtils.Notes.Attachment.WriteStream(gID, con, writer);
								}
							}
							catch(Exception ex)
							{
								// 08/29/2010 Paul.  Convert the error message to an image. 
								byte[] byImage = SplendidCRM.Images.Image.RenderAsImage(Response, 600, 300, "Error: " + ex.Message, ImageFormat.Gif);
								Response.ContentType = "image/gif";
								Response.BinaryWrite(byImage);
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				Response.Write(ex.Message);
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

