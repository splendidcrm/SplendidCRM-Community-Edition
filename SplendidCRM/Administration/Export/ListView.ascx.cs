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
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.IO;
using System.Xml;
using System.Text;

namespace SplendidCRM.Administration.Export
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected Label         lblError       ;
		protected SearchControl ctlSearch      ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Clear" )
				{
					ctlSearch.ClearForm();
					Server.Transfer("default.aspx");
				}
				else if ( e.CommandName == "Search" )
				{
					// 10/13/2005 Paul.  Make sure to clear the page index prior to applying search. 
					grdMain.CurrentPageIndex = 0;
					grdMain.ApplySort();
					grdMain.DataBind();
				}
				else if ( e.CommandName == "Export" )
				{
					string[] arrTABLES = Request.Form.GetValues("chkMain");
					if ( arrTABLES != null )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							
							int nErrors = 0 ;
							MemoryStream stm = new MemoryStream();
							XmlTextWriter xw = new XmlTextWriter(stm, Encoding.UTF8);
							xw.Formatting  = Formatting.Indented;
							xw.IndentChar  = ControlChars.Tab;
							xw.Indentation = 1;
							xw.WriteStartDocument();
							xw.WriteStartElement("splendidcrm");
							foreach ( string sTABLE_NAME in arrTABLES )
							{
								vwMain.RowFilter = "TABLE_NAME = '" + sTABLE_NAME + "'";
								if ( vwMain.Count > 0 )
								{
									try
									{
										using ( IDbCommand cmd = con.CreateCommand() )
										{
											// 05/04/2008 Paul.  Protect against SQL Injection. A table name will never have a space character.
											cmd.CommandText = "select * from " + sTABLE_NAME.Replace(" ", "");
											using ( IDataReader rdr = cmd.ExecuteReader() )
											{
												int nRecordCount = 0;
												while ( rdr.Read() )
												{
													nRecordCount++;
													xw.WriteStartElement(sTABLE_NAME.ToLower());
													for ( int nColumn = 0; nColumn < rdr.FieldCount; nColumn++ )
													{
														xw.WriteStartElement(rdr.GetName(nColumn).ToLower());
														if ( !rdr.IsDBNull(nColumn) )
														{
															switch ( rdr.GetFieldType(nColumn).FullName )
															{
																case "System.Boolean" :  xw.WriteString(rdr.GetBoolean (nColumn) ? "1" : "0");  break;
																case "System.Single"  :  xw.WriteString(rdr.GetDouble  (nColumn).ToString() );  break;
																case "System.Double"  :  xw.WriteString(rdr.GetDouble  (nColumn).ToString() );  break;
																case "System.Int16"   :  xw.WriteString(rdr.GetInt16   (nColumn).ToString() );  break;
																case "System.Int32"   :  xw.WriteString(rdr.GetInt32   (nColumn).ToString() );  break;
																case "System.Int64"   :  xw.WriteString(rdr.GetInt64   (nColumn).ToString() );  break;
																case "System.Decimal" :  xw.WriteString(rdr.GetDecimal (nColumn).ToString() );  break;
																case "System.DateTime":  xw.WriteString(rdr.GetDateTime(nColumn).ToUniversalTime().ToString(CalendarControl.SqlDateTimeFormat));  break;
																case "System.Guid"    :  xw.WriteString(rdr.GetGuid    (nColumn).ToString().ToUpper());  break;
																case "System.String"  :  xw.WriteString(rdr.GetString  (nColumn));  break;
																case "System.Byte[]"  :
																{
																	Byte[] buffer = rdr.GetValue(nColumn) as Byte[];
																	xw.WriteBase64(buffer, 0, buffer.Length);
																	break;
																}
																default:
																	throw(new Exception("Unsupported field type: " + rdr.GetFieldType(nColumn).FullName));
															}
														}
														xw.WriteEndElement();
													}
													xw.WriteEndElement();
												}
												vwMain[0]["TABLE_STATUS"] = String.Format(L10n.Term("Export.LBL_RECORDS"), nRecordCount);
											}
										}
									}
									catch(Exception ex)
									{
										nErrors++;
										vwMain[0]["TABLE_STATUS"] = ex.Message;
									}
								}
							}
							xw.WriteEndElement();
							xw.WriteEndDocument();
							xw.Flush();
							if ( nErrors == 0 )
							{
								Response.ContentType = "text/xml";
								// 08/06/2008 yxy21969.  Make sure to encode all URLs.
								// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
								Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(Request.Browser, "Export.xml"));
								stm.WriteTo(Response.OutputStream);
								Response.End();
							}
							vwMain.RowFilter = null;
							grdMain.DataBind();
						}
					}
				}
				else if ( e.CommandName == "Cancel" )
				{
					Response.Redirect("~/Administration/default.aspx");
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = Server.HtmlEncode(ex.Message);
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			Response.BufferOutput = true;
			SetPageTitle(L10n.Term(".LBL_EXPORT_DATABASE"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "export") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					sSQL = "select TABLE_NAME         " + ControlChars.CrLf
					     + "     , ' ' as TABLE_STATUS" + ControlChars.CrLf
					     + "  from vwSqlTables        " + ControlChars.CrLf
					     + " where 1 = 1              " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						ctlSearch.SqlSearchClause(cmd);

						if ( bDebug )
							RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								if ( !IsPostBack )
								{
									// 12/14/2007 Paul.  Only set the default sort if it is not already set.  It may have been set by SearchView. 
									if ( String.IsNullOrEmpty(grdMain.SortColumn) )
									{
										grdMain.SortColumn = "TABLE_NAME";
										grdMain.SortOrder  = "asc" ;
									}
									grdMain.ApplySort();
									grdMain.DataBind();
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
			ctlSearch.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Import";
			// 05/06/2010 Paul.  The menu will show the admin Module Name in the Six theme. 
			SetMenu(m_sMODULE);
		}
		#endregion
	}
}

