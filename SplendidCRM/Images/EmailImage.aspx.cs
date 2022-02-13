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
using System.Web;
using System.Drawing;
using System.Drawing.Imaging;
using System.Diagnostics;

namespace SplendidCRM.Images
{
	/// <summary>
	/// Summary description for EmailImage.
	/// </summary>
	public class EmailImage : SplendidPage
	{
		// 02/11/2009 Paul.  This page must be accessible without authentication. 
		override protected bool AuthenticationRequired()
		{
			return false;
		}

		// 10/20/2009 Paul.  Move blob logic to WriteStream. 
		public static void WriteStream(Guid gID, IDbConnection con, BinaryWriter writer)
		{
			// 09/06/2008 Paul.  PostgreSQL does not require that we stream the bytes, so lets explore doing this for all platforms. 
			if ( Sql.StreamBlobs(con) )
			{
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = "spEMAIL_IMAGE_ReadOffset";
					cmd.CommandType = CommandType.StoredProcedure;
					
					const int BUFFER_LENGTH = 4*1024;
					int idx  = 0;
					int size = 0;
					byte[] binData = new byte[BUFFER_LENGTH];  // 10/20/2005 Paul.  This allocation is only used to set the parameter size. 
					IDbDataParameter parID          = Sql.AddParameter(cmd, "@ID"         , gID    );
					IDbDataParameter parFILE_OFFSET = Sql.AddParameter(cmd, "@FILE_OFFSET", idx    );
					// 01/21/2006 Paul.  Field was renamed to READ_SIZE. 
					IDbDataParameter parREAD_SIZE   = Sql.AddParameter(cmd, "@READ_SIZE"  , size   );
					IDbDataParameter parBYTES       = Sql.AddParameter(cmd, "@BYTES"      , binData);
					parBYTES.Direction = ParameterDirection.InputOutput;
					do
					{
						parID         .Value = gID          ;
						parFILE_OFFSET.Value = idx          ;
						parREAD_SIZE  .Value = BUFFER_LENGTH;
						size = 0;
						// 08/14/2005 Paul.  Oracle returns the bytes in a field.
						// SQL Server can only return the bytes in a resultset. 
						// 10/20/2005 Paul.  MySQL works returning bytes in an output parameter. 
						// 02/05/2006 Paul.  DB2 returns bytse in a field. 
						if ( Sql.IsOracle(cmd) || Sql.IsDB2(cmd) ) // || Sql.IsMySQL(cmd) )
						{
							cmd.ExecuteNonQuery();
							binData = Sql.ToByteArray(parBYTES);
							if ( binData != null )
							{
								size = binData.Length;
								writer.Write(binData);
								idx += size;
							}
						}
						else
						{
							using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
							{
								if ( rdr.Read() )
								{
									// 10/20/2005 Paul.  MySQL works returning a record set, but it cannot be cast to a byte array. 
									// binData = (byte[]) rdr[0];
									binData = Sql.ToByteArray((System.Array) rdr[0]);
									if ( binData != null )
									{
										size = binData.Length;
										writer.Write(binData);
										idx += size;
									}
								}
							}
						}
					}
					while ( size == BUFFER_LENGTH );
				}
			}
			else
			{
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					string sSQL;
					sSQL = "select CONTENT               " + ControlChars.CrLf
					     + "  from vwEMAIL_IMAGES_CONTENT" + ControlChars.CrLf
					     + " where ID = @ID              " + ControlChars.CrLf;
					Sql.AddParameter(cmd, "@ID", gID);
					cmd.CommandText = sSQL;
					//object oBlob = cmd.ExecuteScalar();
					//byte[] binData = Sql.ToByteArray(oBlob);
					//writer.Write(binData);
					using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
					{
						if ( rdr.Read() )
						{
							// 10/20/2009 Paul.  Try to be more efficient by using a reader. 
							Sql.WriteStream(rdr, 0, writer);
						}
					}
				}
			}
		}

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
							sSQL = "select *             " + ControlChars.CrLf
							     + "  from vwEMAIL_IMAGES" + ControlChars.CrLf
							     + " where ID = @ID      " + ControlChars.CrLf;
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
									else
									{
										string sMessage = "Image not found.";
										// 04/30/2010 Paul.  Image not found is correct, unless we are an Offline Client. 
										if ( !Sql.IsEmptyString(Sql.ToString(Context.Session["SystemSync.Server"])) )
											sMessage = "Must be online to retrieve image.";
										byte[] byImage = Image.RenderAsImage(Response, 300, 100, "Error: " + sMessage, ImageFormat.Gif);
										Response.ContentType = "image/gif";
										Response.BinaryWrite(byImage);
									}
								}
							}
							using ( BinaryWriter writer = new BinaryWriter(Response.OutputStream) )
							{
								// 10/20/2009 Paul.  Move blob logic to WriteStream. 
								WriteStream(gID, con, writer);
							}
						}
					}
					else
					{
						byte[] byImage = Image.RenderAsImage(Response, 300, 100, "Error: ID not specified.", ImageFormat.Gif);
						Response.ContentType = "image/gif";
						Response.BinaryWrite(byImage);
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				//Response.Write(ex.Message);
				if ( ex.GetType() != Type.GetType("System.Threading.ThreadAbortException") )
				{
					byte[] byImage = Image.RenderAsImage(Response, 300, 100, ex.Message, ImageFormat.Gif);
					Response.ContentType = "image/gif";
					Response.BinaryWrite(byImage);
				}
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

