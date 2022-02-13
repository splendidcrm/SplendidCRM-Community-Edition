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
using SplendidCRM._controls;

namespace SplendidCRM.Administration.DynamicLayout.GridViews
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : DynamicLayoutView
	{
		protected NewRecord   ctlNewRecord      ;
		protected Table       tblViewEventsPanel;

		// 10/30/2010 Paul.  Add support for Business Rules Framework. 
		protected override string LayoutEventsTableName()
		{
			return "GRIDVIEWS";
		}

		protected override string LayoutEventsEditViewName()
		{
			return "EventsGridView";
		}

		// 02/14/2013 Paul.  Allow a layout to be copied. 
		protected override void LayoutEventsSave(string sLayoutViewName, IDbTransaction trn)
		{
			// 11/22/2010 Paul.  Apply Business Rules. 
			// 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
			SqlProcs.spGRIDVIEWS_UpdateEvents
				( sLayoutViewName
				, new DynamicControl(this, "PRE_LOAD_EVENT_ID"  ).ID
				, new DynamicControl(this, "POST_LOAD_EVENT_ID" ).ID
				, new DynamicControl(this, "SCRIPT"             ).Text
				, trn
				);
		}

		// 02/14/2013 Paul.  Allow a layout to be copied. 
		protected override void LayoutCopy(string sOldLayoutViewName, string sNewLayoutViewName, IDbTransaction trn)
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			string sSQL;
			sSQL = "select *            " + ControlChars.CrLf
			     + "  from vwGRIDVIEWS  " + ControlChars.CrLf
			     + " where NAME = @NAME " + ControlChars.CrLf;
			IDbConnection con = trn.Connection;
			using ( IDbCommand cmd = con.CreateCommand() )
			{
				cmd.CommandText = sSQL;
				cmd.Transaction = trn;
				Sql.AddParameter(cmd, "@NAME", sOldLayoutViewName);
				using ( DbDataAdapter da = dbf.CreateDataAdapter() )
				{
					((IDbDataAdapter)da).SelectCommand = cmd;
					using ( DataTable dt = new DataTable() )
					{
						da.Fill(dt);
						if ( dt.Rows.Count > 0 )
						{
							DataRow row = dt.Rows[0];
							string sMODULE_NAME  = Sql.ToString (row["MODULE_NAME" ]);
							string sVIEW_NAME    = Sql.ToString (row["VIEW_NAME"   ]);
							// 02/22/2021 Paul.  The React client needs a way to determine the default sort, besides NAME asc. 
							string sSORT_FIELD     = Sql.ToString (row["SORT_FIELD"    ]);
							string sSORT_DIRECTION = Sql.ToString (row["SORT_DIRECTION"]);
							SqlProcs.spGRIDVIEWS_InsertOnly
								( sNewLayoutViewName
								, sMODULE_NAME
								, sVIEW_NAME
								, sSORT_FIELD
								, sSORT_DIRECTION
								, trn
								);
						}
					}
				}
			}
			
			// 02/14/2013 Paul.  Just in case the user tries to copy over to a layout that already exists, we need to delete that layout first. 
			sSQL = "select ID                    " + ControlChars.CrLf
			     + "  from vwGRIDVIEWS_COLUMNS   " + ControlChars.CrLf
			     + " where GRID_NAME = @GRID_NAME" + ControlChars.CrLf;
			using ( IDbCommand cmd = con.CreateCommand() )
			{
				cmd.CommandText = sSQL;
				cmd.Transaction = trn;
				Sql.AddParameter(cmd, "@GRID_NAME", sNewLayoutViewName);
				using ( DbDataAdapter da = dbf.CreateDataAdapter() )
				{
					((IDbDataAdapter)da).SelectCommand = cmd;
					using ( DataTable dt = new DataTable() )
					{
						da.Fill(dt);
						foreach ( DataRow row in dt.Rows )
						{
							Guid gID = Sql.ToGuid(row["ID"]);
							SqlProcs.spGRIDVIEWS_COLUMNS_Delete(gID, trn);
						}
					}
				}
			}
			
		}

		protected override string LayoutTableName()
		{
			return "GRIDVIEWS_FIELDS";
		}

		// 01/20/2010 Paul.  We need to know the name field. 
		protected override string LayoutNameField()
		{
			//return "GRID_NAME";
			// 01/20/2010 Paul.  We cannot validate the GRIDVIEW as duplicate fields are allowed. 
			return String.Empty;
		}

		protected override string LayoutIndexName()
		{
			return "COLUMN_INDEX";
		}

		protected override string LayoutTypeName()
		{
			return "COLUMN_TYPE";
		}

		protected override string LayoutUpdateProcedure()
		{
			return "spGRIDVIEWS_COLUMNS_Update";
		}

		protected override string LayoutDeleteProcedure()
		{
			return "spGRIDVIEWS_COLUMNS_Delete";
		}

		protected override void GetLayoutFields(string sNAME)
		{
			dtFields = null;
			if ( !Sql.IsEmptyString(sNAME) )
			{
				dtFields = SplendidCache.GridViewColumns(sNAME).Copy();
				// 06/04/2008 Paul.  Some customers have reported a problem with the indexes. 
				RenumberIndexes();
			}
		}

		protected override void GetModuleName(string sNAME, ref string sMODULE_NAME, ref string sVIEW_NAME)
		{
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select MODULE_NAME  " + ControlChars.CrLf
					     + "     , VIEW_NAME    " + ControlChars.CrLf
					     + "  from vwGRIDVIEWS  " + ControlChars.CrLf
					     + " where NAME = @NAME " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@NAME", sNAME);
						using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
						{
							if ( rdr.Read() )
							{
								sMODULE_NAME = Sql.ToString(rdr["MODULE_NAME"]);
								sVIEW_NAME   = Sql.ToString(rdr["VIEW_NAME"  ]);
								// 07/27/2010 Paul.  We seem to have a bug in our data when dealing with subpanels. 
								// Lets compensate by returning the subpanel module if the second part is a valid module name. 
								if ( sNAME.StartsWith(sMODULE_NAME) )
								{
									string[] arrNAME = sNAME.Split('.');
									if ( arrNAME.Length > 1 && Sql.ToBoolean(Application["Modules." + arrNAME[1] + ".Valid"]) )
									{
										sMODULE_NAME = arrNAME[1];
									}
								}
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlLayoutButtons.ErrorText = ex.Message;
			}
		}

		protected override void ClearCache(string sNAME)
		{
			SplendidCache.ClearGridView(sNAME);
		}

		protected override void LayoutView_Bind(bool bInitialize)
		{
			if ( dtFields != null )
			{
				tblMain.Rows.Clear();
				// 09/12/2009 Paul.  A previous pass may have hidden the table, so we need to reset the visibility state. 
				tblMain.Visible = true;
				DataView dv = dtFields.DefaultView;
				dv.RowFilter = "DELETED = 0";
				dv.Sort      = LayoutIndexName();
				// 04/11/2011 Paul.  Allow the layout mode to be turned off to preview the result. 
				SplendidDynamic.AppendGridColumns(dv, tblMain, null, GetL10n(), GetT10n(), new CommandEventHandler(Page_Command), !ctlLayoutButtons.Preview(bInitialize));
				// 07/27/2010 Paul.  Hide the border when nothing is displayed. 
				tblMain.Attributes["class"] = "listView";
			}
			else
			{
				tblMain.Rows.Clear();
				tblMain.Attributes["class"] = "";
			}
		}

		protected override void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Layout.Edit" )
				{
					if ( ctlNewRecord != null )
					{
						ctlNewRecord.Clear();
						int nFieldIndex = Sql.ToInteger(e.CommandArgument);
						DataView vwFields = new DataView(dtFields);
						vwFields.RowFilter = "DELETED = 0 and " + LayoutIndexName() + " = " + nFieldIndex.ToString();
						if ( vwFields.Count == 1 )
						{
							foreach(DataRowView row in vwFields)
							{
								ctlNewRecord.FIELD_ID                   = Sql.ToGuid   (row["ID"                        ]);
								ctlNewRecord.FIELD_INDEX                = Sql.ToInteger(row[LayoutIndexName()           ]);
								ctlNewRecord.FIELD_TYPE                 = Sql.ToString (row[LayoutTypeName()            ]);
								ctlNewRecord.DATA_FORMAT                = Sql.ToString (row["DATA_FORMAT"               ]);
								ctlNewRecord.DATA_LABEL                 = Sql.ToString (row["HEADER_TEXT"               ]);
								ctlNewRecord.DATA_FIELD                 = Sql.ToString (row["DATA_FIELD"                ]);
								ctlNewRecord.SORT_EXPRESSION            = Sql.ToString (row["SORT_EXPRESSION"           ]);
								ctlNewRecord.ITEMSTYLE_WIDTH            = Sql.ToString (row["ITEMSTYLE_WIDTH"           ]);
								ctlNewRecord.ITEMSTYLE_CSSCLASS         = Sql.ToString (row["ITEMSTYLE_CSSCLASS"        ]);
								ctlNewRecord.ITEMSTYLE_HORIZONTAL_ALIGN = Sql.ToString (row["ITEMSTYLE_HORIZONTAL_ALIGN"]);
								ctlNewRecord.ITEMSTYLE_VERTICAL_ALIGN   = Sql.ToString (row["ITEMSTYLE_VERTICAL_ALIGN"  ]);
								ctlNewRecord.ITEMSTYLE_WRAP             = Sql.ToBoolean(row["ITEMSTYLE_WRAP"            ]);
								ctlNewRecord.URL_FIELD                  = Sql.ToString (row["URL_FIELD"                 ]);
								ctlNewRecord.URL_FORMAT                 = Sql.ToString (row["URL_FORMAT"                ]);
								ctlNewRecord.URL_TARGET                 = Sql.ToString (row["URL_TARGET"                ]);
								ctlNewRecord.URL_MODULE                 = Sql.ToString (row["URL_MODULE"                ]);
								ctlNewRecord.URL_ASSIGNED_FIELD         = Sql.ToString (row["URL_ASSIGNED_FIELD"        ]);
								ctlNewRecord.LIST_NAME                  = Sql.ToString (row["LIST_NAME"                 ]);
								// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
								ctlNewRecord.MODULE_TYPE                = Sql.ToString (row["MODULE_TYPE"               ]);
								// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
								ctlNewRecord.PARENT_FIELD               = Sql.ToString (row["PARENT_FIELD"              ]);
								ctlNewRecord.Visible = true;
								ctlNewRecord.lstFIELD_TYPE_Changed(null, null);
								break;
							}
						}
					}
				}
				else if ( e.CommandName == "NewRecord.Save" )
				{
					if ( ctlNewRecord != null )
					{
						DataView vwFields = new DataView(dtFields);
						vwFields.RowFilter = "DELETED = 0 and ID = '" + ctlNewRecord.FIELD_ID + "'";
						if ( vwFields.Count == 1 )
						{
							// 01/09/2006 Paul.  Make sure to use ToDBString to convert empty stings to NULL. 
							foreach(DataRowView row in vwFields)
							{
								row[LayoutTypeName()            ] = Sql.ToDBString (ctlNewRecord.FIELD_TYPE                );
								row["DATA_FORMAT"               ] = Sql.ToDBString (ctlNewRecord.DATA_FORMAT               );
								row["HEADER_TEXT"               ] = Sql.ToDBString (ctlNewRecord.DATA_LABEL                );
								row["DATA_FIELD"                ] = Sql.ToDBString (ctlNewRecord.DATA_FIELD                );
								row["SORT_EXPRESSION"           ] = Sql.ToDBString (ctlNewRecord.SORT_EXPRESSION           );
								row["ITEMSTYLE_WIDTH"           ] = Sql.ToDBString (ctlNewRecord.ITEMSTYLE_WIDTH           );
								row["ITEMSTYLE_CSSCLASS"        ] = Sql.ToDBString (ctlNewRecord.ITEMSTYLE_CSSCLASS        );
								row["ITEMSTYLE_HORIZONTAL_ALIGN"] = Sql.ToDBString (ctlNewRecord.ITEMSTYLE_HORIZONTAL_ALIGN);
								row["ITEMSTYLE_VERTICAL_ALIGN"  ] = Sql.ToDBString (ctlNewRecord.ITEMSTYLE_VERTICAL_ALIGN  );
								row["ITEMSTYLE_WRAP"            ] = Sql.ToDBBoolean(ctlNewRecord.ITEMSTYLE_WRAP            );
								row["URL_FIELD"                 ] = Sql.ToDBString (ctlNewRecord.URL_FIELD                 );
								row["URL_FORMAT"                ] = Sql.ToDBString (ctlNewRecord.URL_FORMAT                );
								row["URL_TARGET"                ] = Sql.ToDBString (ctlNewRecord.URL_TARGET                );
								row["URL_MODULE"                ] = Sql.ToDBString (ctlNewRecord.URL_MODULE                );
								row["URL_ASSIGNED_FIELD"        ] = Sql.ToDBString (ctlNewRecord.URL_ASSIGNED_FIELD        );
								row["LIST_NAME"                 ] = Sql.ToDBString (ctlNewRecord.LIST_NAME                 );
								// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
								row["MODULE_TYPE"               ] = Sql.ToDBString (ctlNewRecord.MODULE_TYPE               );
								// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
								row["PARENT_FIELD"              ] = Sql.ToDBString (ctlNewRecord.PARENT_FIELD              );
								break;
							}
						}
						else
						{
							// 01/08/2006 Paul.  If not found, then insert a new field. 
							if ( ctlNewRecord.FIELD_INDEX == -1 )
							{
								ctlNewRecord.FIELD_INDEX = DynamicTableNewFieldIndex();
							}
							else
							{
								// Make room for the new record. 
								DynamicTableInsert(ctlNewRecord.FIELD_INDEX);
							}
							// 01/09/2006 Paul.  Make sure to use ToDBString to convert empty stings to NULL. 
							DataRow row = dtFields.NewRow();
							dtFields.Rows.Add(row);
							row["ID"                        ] = Guid.NewGuid();
							row["DELETED"                   ] = 0;
							row["GRID_NAME"                 ] = Sql.ToDBString (ViewState["LAYOUT_VIEW_NAME"]);
							row[LayoutIndexName()           ] = Sql.ToDBInteger(ctlNewRecord.FIELD_INDEX               );
							row[LayoutTypeName()            ] = Sql.ToDBString (ctlNewRecord.FIELD_TYPE                );
							row["DATA_FORMAT"               ] = Sql.ToDBString (ctlNewRecord.DATA_FORMAT               );
							row["HEADER_TEXT"               ] = Sql.ToDBString (ctlNewRecord.DATA_LABEL                );
							row["DATA_FIELD"                ] = Sql.ToDBString (ctlNewRecord.DATA_FIELD                );
							row["SORT_EXPRESSION"           ] = Sql.ToDBString (ctlNewRecord.SORT_EXPRESSION           );
							row["ITEMSTYLE_WIDTH"           ] = Sql.ToDBString (ctlNewRecord.ITEMSTYLE_WIDTH           );
							row["ITEMSTYLE_CSSCLASS"        ] = Sql.ToDBString (ctlNewRecord.ITEMSTYLE_CSSCLASS        );
							row["ITEMSTYLE_HORIZONTAL_ALIGN"] = Sql.ToDBString (ctlNewRecord.ITEMSTYLE_HORIZONTAL_ALIGN);
							row["ITEMSTYLE_VERTICAL_ALIGN"  ] = Sql.ToDBString (ctlNewRecord.ITEMSTYLE_VERTICAL_ALIGN  );
							row["ITEMSTYLE_WRAP"            ] = Sql.ToDBBoolean(ctlNewRecord.ITEMSTYLE_WRAP            );
							row["URL_FIELD"                 ] = Sql.ToDBString (ctlNewRecord.URL_FIELD                 );
							row["URL_FORMAT"                ] = Sql.ToDBString (ctlNewRecord.URL_FORMAT                );
							row["URL_TARGET"                ] = Sql.ToDBString (ctlNewRecord.URL_TARGET                );
							row["URL_MODULE"                ] = Sql.ToDBString (ctlNewRecord.URL_MODULE                );
							row["URL_ASSIGNED_FIELD"        ] = Sql.ToDBString (ctlNewRecord.URL_ASSIGNED_FIELD        );
							row["LIST_NAME"                 ] = Sql.ToDBString (ctlNewRecord.LIST_NAME                 );
							// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
							row["MODULE_TYPE"               ] = Sql.ToDBString (ctlNewRecord.MODULE_TYPE               );
							// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
							row["PARENT_FIELD"              ] = Sql.ToDBString (ctlNewRecord.PARENT_FIELD              );
						}
						SaveFieldState();
						LayoutView_Bind(false);
						if ( ctlNewRecord != null )
							ctlNewRecord.Clear();
					}
				}
				else if ( e.CommandName == "Defaults" )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sSQL;
						sSQL = "select *                         " + ControlChars.CrLf
						     + "  from vwGRIDVIEWS_COLUMNS       " + ControlChars.CrLf
						     + " where GRID_NAME = @GRID_NAME    " + ControlChars.CrLf
						     + "   and DEFAULT_VIEW = 1          " + ControlChars.CrLf
						     + " order by " + LayoutIndexName() + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@GRID_NAME", Sql.ToString(ViewState["LAYOUT_VIEW_NAME"]));
						
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								//dtFields = new DataTable();
								// 01/09/2006 Paul.  Mark existing records for deletion. 
								// This is so that the save operation can update only records that have changed. 
								foreach(DataRow row in dtFields.Rows)
									row["DELETED"] = 1;
								da.Fill(dtFields);
								// 01/09/2006 Paul.  We need to change the IDs for two reasons, one is to prevent updating the Default Values,
								// the second reason is that we need the row to get a Modified state.  Otherwise the update loop will skip it. 
								foreach(DataRow row in dtFields.Rows)
								{
									if ( Sql.ToInteger(row["DELETED"]) == 0 )
										row["ID"] = Guid.NewGuid();
								}
							}
						}
					}
					SaveFieldState();
					LayoutView_Bind(false);
					
					if ( ctlNewRecord != null )
						ctlNewRecord.Clear();
				}
				// 04/11/2011 Paul.  Update the view on PreviewChanged. 
				else if ( e.CommandName == "PreviewChanged")
				{
					LayoutView_Bind(false);
					tblViewEventsPanel.Visible = !ctlLayoutButtons.Preview(false);
				}
				else
				{
					base.Page_Command(sender, e);
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
			SetPageTitle(L10n.Term("DynamicLayout.LBL_EDIT_VIEW_LAYOUT"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			// 08/02/2010 Paul.  Hide the Export button on the Community Edition. 
			if ( !IsPostBack )
			{
				// 08/25/2013 Paul.  File IO is slow, so cache existance test. 
				bool bShowExport = Utils.CachedFileExists(Context, "~/Administration/DynamicLayout/GridViews/export.aspx");
				ctlLayoutButtons.ShowExport(bShowExport);
			}

			// 02/08/2007 Paul.  The NewRecord control is now in the MasterPage. 
			ContentPlaceHolder plcSidebar = Page.Master.FindControl("cntSidebar") as ContentPlaceHolder;
			if ( plcSidebar != null )
			{
				if ( plcSidebar.FindControl("ctlNewRecord") != null )
					ctlNewRecord = plcSidebar.FindControl("ctlNewRecord") as NewRecord;
			}
			// 05/17/2010 Paul.  Move the NewRecord control to the bottom of the ListView so that it will be visible with the Six theme. 
			// 07/27/2010 Paul.  The NewRecord was moved from the parent to this control, so we don't need to find it. 
			/*
			if ( ctlNewRecord == null )
			{
				ctlNewRecord = Parent.FindControl("ctlNewRecord") as NewRecord;
			}
			*/
			if ( ctlNewRecord != null )
			{
				ctlNewRecord.Command += new CommandEventHandler(Page_Command);
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
			ctlLayoutButtons.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "DynamicLayout";
			// 05/06/2010 Paul.  The menu will show the admin Module Name in the Six theme. 
			SetMenu(m_sMODULE);
		}
		#endregion
	}
}

