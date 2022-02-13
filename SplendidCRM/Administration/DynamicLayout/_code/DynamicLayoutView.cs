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
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Xml;
using System.Diagnostics;
using SplendidCRM._controls;

namespace SplendidCRM.Administration.DynamicLayout
{
	/// <summary>
	/// Summary description for DynamicLayoutView.
	/// </summary>
	public class DynamicLayoutView : SplendidControl
	{
		protected ModuleHeader            ctlModuleHeader ;
		protected _controls.LayoutButtons ctlLayoutButtons;
		protected _controls.SearchBasic   ctlSearch       ;
		protected SplendidCRM._controls.ListHeader ctlListHeader;

		private   NewRecord               ctlNewRecord    ;
		protected HtmlTable               tblMain         ;
		// 11/30/2006 Paul.  Not sure why, but we are having a problem with loading the viewstate. 
		// Store the fields in a hidden variable so that it is accessible inside Page_Init. 
		protected HtmlInputHidden         txtFieldState   ;
		// 11/30/2006 Paul.  Make the dtFields member so that it only needs to be loaded once. 
		protected DataTable               dtFields = null;
		// 10/30/2010 Paul.  Add support for Business Rules Framework. 
		protected HtmlTable               tblViewEvents   ;
		// 05/18/2013 Paul.  Add drag handle. 
		protected HiddenField             hidDragStartIndex;
		protected HiddenField             hidDragEndIndex  ;

		protected void SaveFieldState()
		{
			using ( DataSet ds = new DataSet() )
			{
				ds.Tables.Add(dtFields);
				using ( MemoryStream mem = new MemoryStream() )
				{
					XmlTextWriter xw = new XmlTextWriter(mem, System.Text.Encoding.UTF8);
					ds.WriteXml(xw, System.Data.XmlWriteMode.WriteSchema);
					xw.Flush();
					txtFieldState.Value = Convert.ToBase64String(mem.ToArray());
				}
				ds.Tables.Remove(dtFields);
			}
		}

		protected void LoadFieldState()
		{
			dtFields = null;
			// 11/30/2006 Paul.  Pull the field state directly from the request so that this will work even before viewstate has been restored. 
			string sFieldState = Sql.ToString(Request.Form[txtFieldState.Name]);
			if ( !Sql.IsEmptyString(sFieldState) )
			{
				using ( DataSet ds = new DataSet() )
				{
					byte[] by = Convert.FromBase64String(sFieldState);
					using ( MemoryStream mem = new MemoryStream(by) )
					{
						XmlTextReader xr = new XmlTextReader(mem);
						ds.ReadXml(xr, System.Data.XmlReadMode.ReadSchema);
					}
					dtFields = ds.Tables[0];
					ds.Tables.Remove(dtFields);
				}
			}
		}

		// 01/09/2006 Paul.  Instead of creating an abstract class, just create virtual members.
		// VisualStudio 2003 gave errors when trying to load a class that was based on an abstract class. 
		#region Virtual Functions
		// 10/30/2010 Paul.  Add support for Business Rules Framework. 
		protected virtual string LayoutEventsTableName()
		{
			return String.Empty;
		}

		protected virtual string LayoutEventsEditViewName()
		{
			return String.Empty;
		}

		// 02/14/2013 Paul.  Allow a layout to be copied. 
		protected virtual void LayoutEventsSave(string sLayoutViewName, IDbTransaction trn)
		{
		}

		// 02/14/2013 Paul.  Allow a layout to be copied. 
		protected virtual void LayoutCopy(string sOldLayoutViewName, string sNewLayoutViewName, IDbTransaction trn)
		{
		}

		protected virtual string LayoutTableName()
		{
			return String.Empty;
		}

		// 01/20/2010 Paul.  We need to know the name field. 
		protected virtual string LayoutNameField()
		{
			return String.Empty;
		}

		protected virtual string LayoutIndexName()
		{
			return String.Empty;
		}

		protected virtual string LayoutTypeName()
		{
			return String.Empty;
		}

		protected virtual string LayoutUpdateProcedure()
		{
			return String.Empty;
		}
		
		protected virtual string LayoutDeleteProcedure()
		{
			return String.Empty;
		}

		protected virtual void LayoutView_Bind(bool bInitialize)
		{
		}

		protected virtual void GetLayoutFields(string sNAME)
		{
		}

		protected virtual void GetModuleName(string sNAME, ref string sMODULE_NAME, ref string sVIEW_NAME)
		{
		}

		protected virtual void ClearCache(string sNAME)
		{
		}
		#endregion

		#region Dynamic Table Management
		public int DynamicTableNewFieldIndex()
		{
			int nFieldIndex = 0;
			DataView vwFields = new DataView(dtFields);
			vwFields.RowFilter = "DELETED = 0"     ;
			vwFields.Sort      = LayoutIndexName() + " desc";
			foreach(DataRowView row in vwFields)
			{
				// 01/08/2006 Paul.  Only count records that are not deleted. 
				if ( Sql.ToInteger(row["DELETED"]) == 0 )
				{
					nFieldIndex = Sql.ToInteger(row[LayoutIndexName()]) + 1;
				}
				break;
			}
			return nFieldIndex;
		}

		public void DynamicTableDelete(int nFieldIndex)
		{
			bool bDecrementIndex = false;
			foreach(DataRow row in dtFields.Rows)
			{
				// 01/08/2006 Paul.  Only modify records that are not deleted. 
				if ( Sql.ToInteger(row["DELETED"]) == 0 )
				{
					if ( Sql.ToInteger(row[LayoutIndexName()]) == nFieldIndex )
					{
						row["DELETED"] = 1;
						bDecrementIndex = true;
					}
					else if ( bDecrementIndex )
					{
						row[LayoutIndexName()] = Sql.ToInteger(row[LayoutIndexName()]) - 1;
					}
				}
			}
			// 06/04/2008 Paul.  Some customers have reported a problem with the indexes. 
			RenumberIndexes();
		}

		public void DynamicTableInsert(int nFieldIndex)
		{
			// 01/08/2006 Paul.  Insert just makes space by shifting the indexes up. 
			DataView vwFields = new DataView(dtFields);
			vwFields.RowFilter = "DELETED = 0"     ;
			vwFields.Sort      = LayoutIndexName() + " desc";
			foreach(DataRowView row in vwFields)
			{
				// 01/08/2006 Paul.  Only modify records that are not deleted. 
				if ( Sql.ToInteger(row[LayoutIndexName()]) >= nFieldIndex )
				{
					row[LayoutIndexName()] = Sql.ToInteger(row[LayoutIndexName()]) + 1;
				}
			}
		}

		public void DynamicTableMoveUp(int nFieldIndex, int nRowMinimum)
		{
			//01/07/2006 Paul.  Move up means to decrement. 
			if ( nFieldIndex > nRowMinimum )
			{
				// 01/08/2006 Paul.  Only modify records that are not deleted. 
				foreach(DataRow row in dtFields.Rows)
				{
					if ( Sql.ToInteger(row["DELETED"]) == 0 )
					{
						if ( Sql.ToInteger(row[LayoutIndexName()]) == nFieldIndex )
						{
							row[LayoutIndexName()] = nFieldIndex - 1;
						}
						else if ( Sql.ToInteger(row[LayoutIndexName()]) == nFieldIndex-1 )
						{
							row[LayoutIndexName()] = nFieldIndex;
						}
					}
				}
			}
		}

		public void DynamicTableMoveDown(int nFieldIndex)
		{
			//01/07/2006 Paul.  Move down means to increment. 
			if ( nFieldIndex < dtFields.Rows.Count )
			{
				// 01/08/2006 Paul.  Only modify records that are not deleted. 
				foreach(DataRow row in dtFields.Rows)
				{
					if ( Sql.ToInteger(row["DELETED"]) == 0 )
					{
						if ( Sql.ToInteger(row[LayoutIndexName()]) == nFieldIndex )
						{
							row[LayoutIndexName()] = nFieldIndex + 1;
						}
						else if ( Sql.ToInteger(row[LayoutIndexName()]) == nFieldIndex+1 )
						{
							row[LayoutIndexName()] = nFieldIndex;
						}
					}
				}
			}
		}

		// 05/18/2013 Paul.  Add drag handle. 
		public void DynamicTableDragItem(int nStartIndex, int nEndIndex)
		{
			if ( nStartIndex > nEndIndex )
			{
				foreach(DataRow row in dtFields.Rows)
				{
					if ( Sql.ToInteger(row["DELETED"]) == 0 )
					{
						int nCurrentIndex = Sql.ToInteger(row[LayoutIndexName()]);
						if ( nCurrentIndex  == nStartIndex )
						{
							row[LayoutIndexName()] = nEndIndex;
						}
						else if ( nCurrentIndex >= nEndIndex && nCurrentIndex < nStartIndex )
						{
							row[LayoutIndexName()] = nCurrentIndex + 1;
						}
					}
				}
			}
			else if ( nStartIndex < nEndIndex )
			{
				foreach(DataRow row in dtFields.Rows)
				{
					if ( Sql.ToInteger(row["DELETED"]) == 0 )
					{
						int nCurrentIndex = Sql.ToInteger(row[LayoutIndexName()]);
						if ( nCurrentIndex  == nStartIndex )
						{
							row[LayoutIndexName()] = nEndIndex;
						}
						else if ( nCurrentIndex > nStartIndex && nCurrentIndex <= nEndIndex )
						{
							row[LayoutIndexName()] = nCurrentIndex - 1;
						}
					}
				}
			}
		}

		// 06/04/2008 Paul.  We need a way to fix indexes.
		public void RenumberIndexes()
		{
			int nFieldIndex = 0;
			// 06/10/2009 Paul.  For the GridViews, be careful not to change the order of the first item as it typically will skip the checkbox. 
			if (  LayoutTableName() == "GRIDVIEWS_FIELDS" )
			{
				nFieldIndex = dtFields.Rows.Count;
				foreach(DataRow row in dtFields.Rows)
				{
					if ( Sql.ToInteger(row["DELETED"]) == 0 )
					{
						nFieldIndex = Math.Min(nFieldIndex, Sql.ToInteger(row[LayoutIndexName()]));
					}
				}
			}
			foreach(DataRow row in dtFields.Rows)
			{
				if ( Sql.ToInteger(row["DELETED"]) == 0 )
				{
					row[LayoutIndexName()] = nFieldIndex;
					nFieldIndex++;
				}
			}
		}
		#endregion

		protected virtual void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				//ctlLayoutButtons.ErrorText = e.CommandName + ": " + e.CommandArgument.ToString();
				// 05/18/2013 Paul.  Add drag handle. 
				if ( e.CommandName == "Layout.DragIndex" && hidDragStartIndex != null && hidDragEndIndex != null )
				{
					int nStartIndex = Sql.ToInteger(hidDragStartIndex.Value);
					int nEndIndex   = Sql.ToInteger(hidDragEndIndex  .Value);
					if ( nStartIndex != nEndIndex )
					{
						DynamicTableDragItem(nStartIndex, nEndIndex);
						SaveFieldState();
						LayoutView_Bind(false);
						if ( ctlNewRecord != null )
						{
							ctlNewRecord.Clear();
							ctlNewRecord.Visible = false;
						}
					}
				}
				else if ( e.CommandName == "Layout.Delete" )
				{
					int nFieldIndex = Sql.ToInteger(e.CommandArgument);
					DynamicTableDelete(nFieldIndex);
					SaveFieldState();
					LayoutView_Bind(false);
					if ( ctlNewRecord != null )
					{
						ctlNewRecord.Clear();
						ctlNewRecord.Visible = false;
					}
				}
				else if ( e.CommandName == "Layout.MoveUp" )
				{
					int nFieldIndex = Sql.ToInteger(e.CommandArgument);
					int nRowMinimum = Sql.ToInteger(ViewState["ROW_MINIMUM"]);
					DynamicTableMoveUp(nFieldIndex, nRowMinimum);
					SaveFieldState();
					LayoutView_Bind(false);
					if ( ctlNewRecord != null )
					{
						ctlNewRecord.Clear();
						ctlNewRecord.Visible = false;
					}
				}
				else if ( e.CommandName == "Layout.MoveDown" )
				{
					int nFieldIndex = Sql.ToInteger(e.CommandArgument);
					DynamicTableMoveDown(nFieldIndex);
					SaveFieldState();
					LayoutView_Bind(false);
					if ( ctlNewRecord != null )
					{
						ctlNewRecord.Clear();
						ctlNewRecord.Visible = false;
					}
				}
				else if ( e.CommandName == "Layout.Edit" )
				{
				}
				else if ( e.CommandName == "NewRecord.Save" )
				{
				}
				else if ( e.CommandName == "NewRecord.Cancel" )
				{
					if ( ctlNewRecord != null )
					{
						ctlNewRecord.Clear();
						ctlNewRecord.Visible = false;
					}
				}
				else if ( e.CommandName == "Layout.Insert" )
				{
					if ( ctlNewRecord != null )
					{
						ctlNewRecord.Clear();
						int nFieldIndex = Sql.ToInteger(e.CommandArgument);
						ctlNewRecord.FIELD_ID    = Guid.NewGuid();
						ctlNewRecord.FIELD_INDEX = nFieldIndex;
						ctlNewRecord.Visible = true;
					}
				}
				else if ( e.CommandName == "New" )
				{
					if ( ctlNewRecord != null )
					{
						ctlNewRecord.Clear();
						int nFieldIndex = Sql.ToInteger(e.CommandArgument);
						ctlNewRecord.FIELD_ID    = Guid.NewGuid();
						ctlNewRecord.Visible = true;
					}
				}
				else if ( e.CommandName == "Defaults" )
				{
				}
				else if ( e.CommandName == "Save" )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
						using ( IDbTransaction trn = Sql.BeginTransaction(con) )
						{
							try
							{
								IDbCommand cmdUpdate = SqlProcs.Factory(con, LayoutUpdateProcedure());
								cmdUpdate.Transaction = trn;
								// 10/10/2006 Paul.  Use IDbDataParameter to be consistent. 
								foreach(IDbDataParameter par in cmdUpdate.Parameters)
								{
									par.Value = DBNull.Value;
								}
								IDbDataParameter parMODIFIED_USER_ID = Sql.FindParameter(cmdUpdate, "@MODIFIED_USER_ID");
								if ( parMODIFIED_USER_ID != null )
									parMODIFIED_USER_ID.Value = Security.USER_ID;
								
								string sVIEW_NAME = Sql.ToString(ViewState["LAYOUT_VIEW_NAME"]);
								// 01/20/2010 Paul.  We cannot validate the GRIDVIEW as duplicate fields are allowed. 
								string sLAYOUT_NAME_FIELD = LayoutNameField();
								if ( ctlLayoutButtons.CopyLayout.Visible )
								{
									ctlLayoutButtons.CopyLayout.Text = ctlLayoutButtons.CopyLayout.Text.Trim();
									if ( Sql.IsEmptyString(ctlLayoutButtons.CopyLayout.Text) || ctlLayoutButtons.CopyLayout.Text == sVIEW_NAME )
										throw(new Exception("Please specify a new layout name."));
									LayoutCopy(sVIEW_NAME, ctlLayoutButtons.CopyLayout.Text, trn);
									sVIEW_NAME = ctlLayoutButtons.CopyLayout.Text;
								}
								
								DataView vwFields = new DataView(dtFields);
								vwFields.RowFilter = "DELETED = 0";
								foreach(DataRowView row in vwFields)
								{
									if ( row.Row.RowState == DataRowState.Modified || row.Row.RowState == DataRowState.Added )
									{
										// 10/10/2006 Paul.  Use IDbDataParameter to be consistent. 
										foreach(IDbDataParameter par in cmdUpdate.Parameters)
										{
											string sFieldName = Sql.ExtractDbName(cmdUpdate, par.ParameterName);
											// 02/14/2013 Paul.  When copying a field, we need to skip the ID so that a new record will be created. 
											if ( ctlLayoutButtons.CopyLayout.Visible && sFieldName == "ID" )
											{
												par.Value = DBNull.Value;
											}
											else if ( ctlLayoutButtons.CopyLayout.Visible && sFieldName == sLAYOUT_NAME_FIELD )
											{
												par.Value = sVIEW_NAME;
											}
											else if ( dtFields.Columns.Contains(sFieldName) && (sFieldName != "MODIFIED_USER_ID") )
											{
												// 01/09/2006 Paul.  Make sure to use ToDBString to convert empty stings to NULL. 
												switch ( par.DbType )
												{
													// 01/20/2011 Paul.  Should be using ToDBGuid(). 
													case DbType.Guid    :  par.Value = Sql.ToDBGuid    (row[sFieldName]);  break;
													case DbType.Int16   :  par.Value = Sql.ToDBInteger (row[sFieldName]);  break;
													case DbType.Int32   :  par.Value = Sql.ToDBInteger (row[sFieldName]);  break;
													case DbType.Int64   :  par.Value = Sql.ToDBInteger (row[sFieldName]);  break;
													case DbType.Double  :  par.Value = Sql.ToDBFloat   (row[sFieldName]);  break;
													case DbType.Decimal :  par.Value = Sql.ToDBDecimal (row[sFieldName]);  break;
													case DbType.Byte    :  par.Value = Sql.ToDBBoolean (row[sFieldName]);  break;
													case DbType.DateTime:  par.Value = Sql.ToDBDateTime(row[sFieldName]);  break;
													default             :  par.Value = Sql.ToDBString  (row[sFieldName]);  break;
												}
											}
										}
										cmdUpdate.ExecuteNonQuery();
									}
								}
								
								// 02/14/2013 Paul.  No need to delete records when copying a layout. 
								if ( !ctlLayoutButtons.CopyLayout.Visible )
								{
									IDbCommand cmdDelete = SqlProcs.Factory(con, LayoutDeleteProcedure());
									cmdDelete.Transaction = trn;
									IDbDataParameter parID = Sql.FindParameter(cmdDelete, "@ID");
									parMODIFIED_USER_ID = Sql.FindParameter(cmdDelete, "@MODIFIED_USER_ID");
									if ( parMODIFIED_USER_ID != null )
										parMODIFIED_USER_ID.Value = Security.USER_ID;
									
									vwFields.RowFilter = "DELETED = 1";
									foreach(DataRowView row in vwFields)
									{
										parID.Value = Sql.ToDBGuid(row["ID"]);
										cmdDelete.ExecuteNonQuery();
									}
									if ( !Sql.IsEmptyString(sLAYOUT_NAME_FIELD) )
									{
										string sSQL = String.Empty;
										// 08/02/2010 Paul.  Exclude the JavaScript field in the count. 
										// We want the ability of a javascript type to match the Name field. 
										sSQL = "select DATA_FIELD                  " + ControlChars.CrLf
										     + "  from vw" + LayoutTableName()       + ControlChars.CrLf
										     + " where DATA_FIELD is not null      " + ControlChars.CrLf
										     + "   and " + sLAYOUT_NAME_FIELD + " = @" + sLAYOUT_NAME_FIELD + ControlChars.CrLf
										     + "   and " + LayoutTypeName()   + " <> 'JavaScript'" + ControlChars.CrLf
										     + "   and DEFAULT_VIEW = 0            " + ControlChars.CrLf
										     + " group by " + sLAYOUT_NAME_FIELD + ", DATA_FIELD" + ControlChars.CrLf
										     + " having count(*) > 1               " + ControlChars.CrLf;
										using ( IDbCommand cmd = con.CreateCommand() )
										{
											cmd.CommandText = sSQL;
											cmd.Transaction = trn;
											Sql.AddParameter(cmd, "@" + sLAYOUT_NAME_FIELD, sVIEW_NAME);
											using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
											{
												StringBuilder sbDuplicateFields = new StringBuilder();
												while ( rdr.Read() )
												{
													if ( sbDuplicateFields.Length > 0 )
														sbDuplicateFields.Append(", ");
													sbDuplicateFields.Append(Sql.ToString(rdr["DATA_FIELD"]));
												}
												if ( sbDuplicateFields.Length > 0 )
												{
													throw(new Exception("Duplicate fields: " + sbDuplicateFields.ToString()));
												}
											}
										}
									}
								}
								// 10/30/2010 Paul.  Add support for Business Rules Framework. 
								// 02/14/2013 Paul.  Allow a layout to be copied. 
								LayoutEventsSave(sVIEW_NAME, trn);
								trn.Commit();
								// 01/09/2006 Paul.  Make sure to clear the cache so that the changes will take effect immediately. 
								ClearCache(sVIEW_NAME);
								// 02/14/2013 Paul.  Allow the layout tree to be rebuilt. 
								if ( ctlLayoutButtons.CopyLayout.Visible )
									ctlSearch.Bind();
							}
							catch(Exception ex)
							{
								trn.Rollback();
								throw(new Exception("Failed to update, transaction aborted; " + ex.Message, ex));
							}
							// 01/04/2009 Paul.  Move the redirect out of the try/catch so that the thread-abort does not generate a false error. 
							Response.Redirect("default.aspx");
						}
					}
				}
				else if ( e.CommandName == "Cancel" )
				{
					Response.Redirect("default.aspx");
				}
				// 02/13/2013 Paul.  Provide a way to copy the list. 
				else if ( e.CommandName == "Layout.Copy" )
				{
					ctlLayoutButtons.CopyLayout.Visible = !ctlLayoutButtons.CopyLayout.Visible;
					if ( ctlLayoutButtons.CopyLayout.Visible )
					{
						ctlLayoutButtons.CopyLayout.Text = Sql.ToString(ViewState["LAYOUT_VIEW_NAME"]) + ".Copy";
					}
					else
					{
						ctlLayoutButtons.CopyLayout.Text = String.Empty;
					}
					ctlLayoutButtons.ShowExport(!ctlLayoutButtons.CopyLayout.Visible);
					ctlLayoutButtons.ShowDefaults(!ctlLayoutButtons.CopyLayout.Visible);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlLayoutButtons.ErrorText = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				// 01/08/2006 Paul.  The viewstate is no longer disabled, so we can go back to using ctlSearch.NAME.
				string sNAME = ctlSearch.NAME;  //Sql.ToString(Request[ctlSearch.ListUniqueID]);
				// 07/27/2010 Paul.  Keep the Search visible, especially now that we are showing a TreeView. 
				//ctlSearch     .Visible = Sql.IsEmptyString(sNAME);
				ctlLayoutButtons.Visible = !Sql.IsEmptyString(sNAME);
				// 05/22/2009 Paul.  We need to pass the view name to the Export popup. 
				ctlLayoutButtons.VIEW_NAME = sNAME;
				// 09/08/2007 Paul.  Add a list header so we will know what list we are working on. 
				if ( ctlListHeader != null )
				{
					ctlListHeader.Visible = !Sql.IsEmptyString(sNAME);
					ctlListHeader.Title   = sNAME;
					ctlListHeader.DataBind();
				}

				// 02/08/2007 Paul.  The NewRecord control is now in the MasterPage. 
				ContentPlaceHolder plcSidebar = Page.Master.FindControl("cntSidebar") as ContentPlaceHolder;
				if ( plcSidebar != null )
				{
					if ( plcSidebar.FindControl("ctlNewRecord") != null )
						ctlNewRecord = plcSidebar.FindControl("ctlNewRecord") as NewRecord;
				}
				// 05/17/2010 Paul.  Move the NewRecord control to the bottom of the ListView so that it will be visible with the Six theme. 
				if ( ctlNewRecord == null )
				{
					// 07/27/2010 Paul.  The NewRecord was moved from the parent to this control, so we don't need to find it. 
					ctlNewRecord = FindControl("ctlNewRecord") as NewRecord;
				}
				if ( !Sql.IsEmptyString(sNAME) && sNAME != Sql.ToString(ViewState["LAYOUT_VIEW_NAME"]) )
				{
					// 01/08/2006 Paul.  We are having a problem with the ViewState not loading properly.
					// This problem only seems to occur when the NewRecord is visible and we try and load a different view.
					// The solution seems to be to hide the Search dialog so that the user must Cancel out of editing the current view.
					// This works very well to clear the ViewState because we GET the next page instead of POST to it. 
					
					SetPageTitle(sNAME);
					// 07/27/2010 Paul.  Binding the page at this time is causing a TreeView exception. 
					//Page.DataBind();
					tblMain.EnableViewState = false;
					// 05/04/2016 Paul.  If the copy field is visible, then hide. 
					if ( ctlLayoutButtons.CopyLayout.Visible )
					{
						ctlLayoutButtons.CopyLayout.Visible = false;
						ctlLayoutButtons.CopyLayout.Text = String.Empty;
						ctlLayoutButtons.ShowExport  (!ctlLayoutButtons.CopyLayout.Visible);
						ctlLayoutButtons.ShowDefaults(!ctlLayoutButtons.CopyLayout.Visible);
					}

					string sMODULE_NAME = String.Empty;
					string sVIEW_NAME   = String.Empty;
					GetModuleName(sNAME, ref sMODULE_NAME, ref sVIEW_NAME);
					GetLayoutFields(sNAME);
					LayoutView_Bind(false);
					// 07/27/2010 Paul.  When a layout changes, we need to clear the NewRecord panel. 
					if ( ctlNewRecord != null )
						ctlNewRecord.Clear();

					ViewState["MODULE_NAME"     ] = sMODULE_NAME;
					ViewState["VIEW_NAME"       ] = sVIEW_NAME  ;
					ViewState["LAYOUT_VIEW_NAME"] = sNAME       ;
					SaveFieldState();
					if ( dtFields.Rows.Count > 0 )
					{
						ViewState["ROW_MINIMUM"] = dtFields.Rows[0][LayoutIndexName()];
					}
					else
					{
						ViewState["ROW_MINIMUM"] = 0;
					}
					// 10/30/2010 Paul.  Add support for Business Rules Framework. 
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sSQL ;
						sSQL = "select *           " + ControlChars.CrLf
						     + "  from vw" + LayoutEventsTableName() + ControlChars.CrLf
						     + " where NAME = @NAME" + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@NAME", sNAME);
							// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dtCurrent = new DataTable() )
								{
									da.Fill(dtCurrent);
									if ( dtCurrent.Rows.Count > 0 )
									{
										DataRow rdr = dtCurrent.Rows[0];
										tblViewEvents.Rows.Clear();
										this.NotPostBack = true;
										this.AppendEditViewFields("BusinessRules." + LayoutEventsEditViewName(), tblViewEvents, rdr);
									}
								}
							}
						}
					}
				}
				else if ( Sql.IsEmptyString(sNAME) )
				{
					GetLayoutFields(sNAME);
					LayoutView_Bind(false);
				}
				if ( ctlNewRecord != null )
				{
					if ( Sql.IsEmptyString(sNAME) )
					{
						ctlNewRecord.Clear();
					}
					else
					{
						ctlNewRecord.MODULE_NAME = Sql.ToString(ViewState["MODULE_NAME"]);
						ctlNewRecord.VIEW_NAME   = Sql.ToString(ViewState["VIEW_NAME"  ]);
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlLayoutButtons.ErrorText = ex.Message;
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
			if ( IsPostBack )
			{
				// 11/30/2006 Paul.  We were having a problem with viewstate. Make sure to load the fields inside Page_Init. 
				LoadFieldState();
				LayoutView_Bind(true);
				// 10/30/2010 Paul.  Add support for Business Rules Framework. 
				this.AppendEditViewFields("BusinessRules." + LayoutEventsEditViewName(), tblViewEvents, null);
			}
		}
		#endregion
	}
}

