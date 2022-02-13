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
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Drawing.Imaging;
using System.Linq;
using System.Xml;
using System.Xml.Linq;
using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Wordprocessing;
using System.Diagnostics;

namespace SplendidCRM.Documents
{
	/// <summary>
	/// Summary description for MailMerge.
	/// </summary>
	public class MailMerge : SplendidPage
	{
		// 10/20/2009 Paul.  Move blob logic to WriteStream. 
		public static void WriteStream(Guid gID, IDbConnection con, BinaryWriter writer)
		{
			// 09/06/2008 Paul.  PostgreSQL does not require that we stream the bytes, so lets explore doing this for all platforms. 
			if ( Sql.StreamBlobs(con) )
			{
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = "spDOCUMENTS_CONTENT_ReadOffset";
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
					sSQL = "select CONTENT                     " + ControlChars.CrLf
					     + "  from vwDOCUMENT_REVISIONS_CONTENT" + ControlChars.CrLf
					     + " where ID = @ID                    " + ControlChars.CrLf;
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
				Guid   gDOCUMENT_ID = Sql.ToGuid  (Request["DOCUMENT_ID"]);
				string sMODULE_NAME = Sql.ToString(Request["Module"     ]);
				string sIDs         = Sql.ToString(Request["ID"         ]);
				string sTABLE_NAME  = Crm.Modules.TableName(sMODULE_NAME);
				if ( !IsPostBack )
				{
					if ( !Sql.IsEmptyString(sMODULE_NAME) && !Sql.IsEmptyString(sTABLE_NAME) && !Sql.IsEmptyString(sIDs) && !Sql.IsEmptyGuid(gDOCUMENT_ID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							string sSQL ;
							Guid   gDOCUMENT_REVISION_ID = Guid.Empty;
							string sFILE_MIME_TYPE       = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
							string sFILENAME             = String.Empty;
							sSQL = "select DOCUMENT_REVISION_ID" + ControlChars.CrLf
							     + "     , FILE_MIME_TYPE      " + ControlChars.CrLf
							     + "     , FILENAME            " + ControlChars.CrLf
							     + "  from vwDOCUMENTS         " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Security.Filter(cmd, "Documents", "view");
								Sql.AppendParameter(cmd, gDOCUMENT_ID, "ID", false);
								cmd.CommandText += "   and IS_TEMPLATE = 1" + ControlChars.CrLf;
								cmd.CommandText += "   and (FILENAME like '%.docx' or FILE_MIME_TYPE = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document')" + ControlChars.CrLf;
								using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
								{
									if ( rdr.Read() )
									{
										gDOCUMENT_REVISION_ID = Sql.ToGuid  (rdr["DOCUMENT_REVISION_ID"]);
										sFILENAME             = Sql.ToString(rdr["FILENAME"            ]);
									}
								}
							}
							if ( !Sql.IsEmptyGuid(gDOCUMENT_REVISION_ID) )
							{
								byte[] byDocTemplate = null;
								using ( MemoryStream stm = new MemoryStream() )
								{
									using ( BinaryWriter writer = new BinaryWriter(stm) )
									{
										WriteStream(gDOCUMENT_REVISION_ID, con, writer);
										// 05/12/2011 Paul.  ToArray is easier than GetBuffer as it will return the correct size. 
										stm.Seek(0, SeekOrigin.Begin);
										byDocTemplate = stm.ToArray();
									}
								}
								List<byte[]> lstParts = new List<byte[]>();
								string[] arrID = sIDs.Split(',');
								foreach ( string sID in arrID )
								{
									Guid gID = Sql.ToGuid(sID.Trim());
									Dictionary<string, string> dictValues = new Dictionary<string, string>();
									sSQL = "select * " + ControlChars.CrLf
									     + "  from vw" + sTABLE_NAME + ControlChars.CrLf;
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.CommandText = sSQL;
										Security.Filter(cmd, sMODULE_NAME, "view");
										Sql.AppendParameter(cmd, gID, "ID", false);
										using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
										{
											if ( rdr.Read() )
											{
												for ( int nFieldIndex = 0; nFieldIndex < rdr.FieldCount; nFieldIndex++ )
												{
													string sNAME  = sMODULE_NAME + "_" + rdr.GetName(nFieldIndex).ToLower();
													string sVALUE = Sql.ToString(rdr.GetValue(nFieldIndex));
													dictValues.Add(sNAME, sVALUE);
												}
											}
										}
									}
									byte[] byMergedDoc = TRIS.FormFill.Lib.FormFiller.GetWordReport(byDocTemplate, null, dictValues);
									lstParts.Add(byMergedDoc);
								}
								if ( lstParts.Count == 1 )
								{
									Response.ContentType = sFILE_MIME_TYPE;
									Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(Request.Browser, sFILENAME));
									Response.BinaryWrite(lstParts[0]);
								}
								else
								{
									List<OpenXml.PowerTools.Source> sources = new List<OpenXml.PowerTools.Source>();
									foreach ( byte[] byMergedDoc in lstParts )
									{
										MemoryStream stream = new MemoryStream();
										stream.Write(byMergedDoc, 0, byMergedDoc.Length);
										WordprocessingDocument docx = WordprocessingDocument.Open(stream, true);
										sources.Add(new OpenXml.PowerTools.Source(docx, true));
									}
									// 05/12/2011 Paul.  Using DocumentBuilder has the advantage of adding section breaks between the merged documents. 
									using ( MemoryStream stm = new MemoryStream() )
									{
										using ( WordprocessingDocument docx = OpenXml.PowerTools.DocumentBuilder.BuildOpenDocument(sources, stm) )
										{
											docx.Close();
										}
										
										Response.ContentType = sFILE_MIME_TYPE;
										Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(Request.Browser, sFILENAME));
										// 05/12/2011 Paul.  We need to use stm.ToArray() as stm.GetBuffer() causes an error: "There was an error opening the file."
										stm.Seek(0, SeekOrigin.Begin);
										Response.BinaryWrite(stm.ToArray());
									}
									/*
									using ( MemoryStream stm = new MemoryStream() )
									{
										stm.Write(byDocTemplate, 0, byDocTemplate.Length);
										using ( WordprocessingDocument docx = WordprocessingDocument.Open(stm, true) )
										{
											docx.MainDocumentPart.Document.Body.RemoveAllChildren();
											for ( int i = 0; i < lstParts.Count; i++ )
											{
												byte[] byChunk = lstParts[i];
												// http://blogs.msdn.com/b/ericwhite/archive/2008/10/27/how-to-use-altchunk-for-document-assembly.aspx
												OpenXml.PowerTools.DocumentBuilder.AppendAltChunk(docx, i, byChunk);
											}
											OpenXml.PowerTools.DocumentBuilder.FlushParts(docx);
										}
										Response.ContentType = sFILE_MIME_TYPE;
										Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(Request.Browser, sFILENAME));
										// 05/12/2011 Paul.  We need to use stm.ToArray() as stm.GetBuffer() causes an error: "There was an error opening the file."
										stm.Seek(0, SeekOrigin.Begin);
										Response.BinaryWrite(stm.ToArray()
									}
									*/
								}
							}
							else
							{
								string sMessage = "Document Template not found.";
								if ( !Sql.IsEmptyString(Sql.ToString(Context.Session["SystemSync.Server"])) )
									sMessage = "Must be online to retrieve document.";
								Response.Write(sMessage);
							}
						}
					}
					else
					{
						string sMessage = "Missing parameters.";
						Response.Write(sMessage);
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

