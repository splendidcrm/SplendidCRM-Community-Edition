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
using System.Drawing;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using SplendidCRM._controls;

namespace SplendidCRM.Administration.DynamicLayout.EditViews
{
	/// <summary>
	///		Summary description for EditView.
	/// </summary>
	public class EditView : DynamicLayoutView
	{
		protected Table     tblForm           ;
		protected NewRecord ctlNewRecord      ;
		protected Table     tblViewEventsPanel;
		protected Panel     pnlDynamicMain    ;

		// 10/30/2010 Paul.  Add support for Business Rules Framework. 
		protected override string LayoutEventsTableName()
		{
			return "EDITVIEWS";
		}

		protected override string LayoutEventsEditViewName()
		{
			return "EventsEditView";
		}

		// 02/14/2013 Paul.  Allow a layout to be copied. 
		protected override void LayoutEventsSave(string sLayoutViewName, IDbTransaction trn)
		{
			// 11/11/2010 Paul.  Change to Pre Load and Post Load. 
			// 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
			SqlProcs.spEDITVIEWS_UpdateEvents
				( sLayoutViewName
				, new DynamicControl(this, "NEW_EVENT_ID"       ).ID
				, new DynamicControl(this, "PRE_LOAD_EVENT_ID"  ).ID
				, new DynamicControl(this, "POST_LOAD_EVENT_ID" ).ID
				, new DynamicControl(this, "VALIDATION_EVENT_ID").ID
				, new DynamicControl(this, "PRE_SAVE_EVENT_ID"  ).ID
				, new DynamicControl(this, "POST_SAVE_EVENT_ID" ).ID
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
			     + "  from vwEDITVIEWS  " + ControlChars.CrLf
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
							string sLABEL_WIDTH  = Sql.ToString (row["LABEL_WIDTH" ]);
							string sFIELD_WIDTH  = Sql.ToString (row["FIELD_WIDTH" ]);
							int    nDATA_COLUMNS = Sql.ToInteger(row["DATA_COLUMNS"]);
							if ( nDATA_COLUMNS == 0 )
								nDATA_COLUMNS = 2;
							SqlProcs.spEDITVIEWS_InsertOnly
								( sNewLayoutViewName
								, sMODULE_NAME
								, sVIEW_NAME
								, sLABEL_WIDTH
								, sFIELD_WIDTH
								, nDATA_COLUMNS
								, trn
								);
						}
					}
				}
			}
			
			// 02/14/2013 Paul.  Just in case the user tries to copy over to a layout that already exists, we need to delete that layout first. 
			sSQL = "select ID                    " + ControlChars.CrLf
			     + "  from vwEDITVIEWS_FIELDS    " + ControlChars.CrLf
			     + " where EDIT_NAME = @EDIT_NAME" + ControlChars.CrLf;
			using ( IDbCommand cmd = con.CreateCommand() )
			{
				cmd.CommandText = sSQL;
				cmd.Transaction = trn;
				Sql.AddParameter(cmd, "@EDIT_NAME", sNewLayoutViewName);
				using ( DbDataAdapter da = dbf.CreateDataAdapter() )
				{
					((IDbDataAdapter)da).SelectCommand = cmd;
					using ( DataTable dt = new DataTable() )
					{
						da.Fill(dt);
						foreach ( DataRow row in dt.Rows )
						{
							Guid gID = Sql.ToGuid(row["ID"]);
							SqlProcs.spEDITVIEWS_FIELDS_Delete(gID, trn);
						}
					}
				}
			}
			
			// 02/14/2013 Paul.  Now copy all the relationships. 
			sSQL = "select *                               " + ControlChars.CrLf
			     + "  from " + Sql.MetadataName(con, "vwEDITVIEWS_RELATIONSHIPS_Layout") + ControlChars.CrLf
			     + " where @EDIT_NAME = EDIT_NAME          " + ControlChars.CrLf
			     + " order by RELATIONSHIP_ENABLED, RELATIONSHIP_ORDER, MODULE_NAME" + ControlChars.CrLf;
			using ( IDbCommand cmd = con.CreateCommand() )
			{
				cmd.CommandText = sSQL;
				cmd.Transaction = trn;
				Sql.AddParameter(cmd, "@EDIT_NAME", sOldLayoutViewName);
				using ( DbDataAdapter da = dbf.CreateDataAdapter() )
				{
					((IDbDataAdapter)da).SelectCommand = cmd;
					using ( DataTable dt = new DataTable() )
					{
						da.Fill(dt);
						foreach ( DataRow row in dt.Rows )
						{
							string sMODULE_NAME             = Sql.ToString (row["MODULE_NAME"            ]);
							string sCONTROL_NAME            = Sql.ToString (row["CONTROL_NAME"           ]);
							bool   bRELATIONSHIP_ENABLED    = Sql.ToBoolean(row["RELATIONSHIP_ENABLED"   ]);
							int    nRELATIONSHIP_ORDER      = Sql.ToInteger(row["RELATIONSHIP_ORDER"     ]);
							bool   bNEW_RECORD_ENABLED      = Sql.ToBoolean(row["NEW_RECORD_ENABLED"     ]);
							bool   bEXISTING_RECORD_ENABLED = Sql.ToBoolean(row["EXISTING_RECORD_ENABLED"]);
							string sTITLE                   = Sql.ToString (row["TITLE"                  ]);
							string sALTERNATE_VIEW          = Sql.ToString (row["ALTERNATE_VIEW"         ]);
							SqlProcs.spEDITVIEWS_RELATIONSHIPS_InsertOnly
								( sNewLayoutViewName 
								, sMODULE_NAME            
								, sCONTROL_NAME           
								, bRELATIONSHIP_ENABLED   
								, nRELATIONSHIP_ORDER     
								, bNEW_RECORD_ENABLED     
								, bEXISTING_RECORD_ENABLED
								, sTITLE                  
								, sALTERNATE_VIEW         
								, trn
								);
						}
					}
				}
			}
			
			// 02/14/2013 Paul.  Now copy all the buttons. 
			sSQL = "select *                                  " + ControlChars.CrLf
			     + "  from vwDYNAMIC_BUTTONS                  " + ControlChars.CrLf
			     + " where @VIEW_NAME = VIEW_NAME             " + ControlChars.CrLf
			     + " order by VIEW_NAME asc, CONTROL_INDEX asc" + ControlChars.CrLf;
			using ( IDbCommand cmd = con.CreateCommand() )
			{
				cmd.CommandText = sSQL;
				cmd.Transaction = trn;
				Sql.AddParameter(cmd, "@VIEW_NAME", sOldLayoutViewName);
				using ( DbDataAdapter da = dbf.CreateDataAdapter() )
				{
					((IDbDataAdapter)da).SelectCommand = cmd;
					using ( DataTable dt = new DataTable() )
					{
						da.Fill(dt);
						foreach ( DataRow row in dt.Rows )
						{
							int    nCONTROL_INDEX      = Sql.ToInteger(row["CONTROL_INDEX"     ]);
							string sCONTROL_TYPE       = Sql.ToString (row["CONTROL_TYPE"      ]);
							string sMODULE_NAME        = Sql.ToString (row["MODULE_NAME"       ]);
							string sMODULE_ACCESS_TYPE = Sql.ToString (row["MODULE_ACCESS_TYPE"]);
							string sTARGET_NAME        = Sql.ToString (row["TARGET_NAME"       ]);
							string sTARGET_ACCESS_TYPE = Sql.ToString (row["TARGET_ACCESS_TYPE"]);
							string sCONTROL_TEXT       = Sql.ToString (row["CONTROL_TEXT"      ]);
							string sCONTROL_TOOLTIP    = Sql.ToString (row["CONTROL_TOOLTIP"   ]);
							string sCONTROL_ACCESSKEY  = Sql.ToString (row["CONTROL_ACCESSKEY" ]);
							string sCONTROL_CSSCLASS   = Sql.ToString (row["CONTROL_CSSCLASS"  ]);
							string sTEXT_FIELD         = Sql.ToString (row["TEXT_FIELD"        ]);
							string sARGUMENT_FIELD     = Sql.ToString (row["ARGUMENT_FIELD"    ]);
							string sCOMMAND_NAME       = Sql.ToString (row["COMMAND_NAME"      ]);
							string sURL_FORMAT         = Sql.ToString (row["URL_FORMAT"        ]);
							string sURL_TARGET         = Sql.ToString (row["URL_TARGET"        ]);
							string sONCLICK_SCRIPT     = Sql.ToString (row["ONCLICK_SCRIPT"    ]);
							bool   bMOBILE_ONLY        = Sql.ToBoolean(row["MOBILE_ONLY"       ]);
							bool   bADMIN_ONLY         = Sql.ToBoolean(row["ADMIN_ONLY"        ]);
							SqlProcs.spDYNAMIC_BUTTONS_InsertOnly
								( sNewLayoutViewName
								, nCONTROL_INDEX     
								, sCONTROL_TYPE      
								, sMODULE_NAME       
								, sMODULE_ACCESS_TYPE
								, sTARGET_NAME       
								, sTARGET_ACCESS_TYPE
								, sCONTROL_TEXT      
								, sCONTROL_TOOLTIP   
								, sCONTROL_ACCESSKEY 
								, sCONTROL_CSSCLASS  
								, sTEXT_FIELD        
								, sARGUMENT_FIELD    
								, sCOMMAND_NAME      
								, sURL_FORMAT        
								, sURL_TARGET        
								, sONCLICK_SCRIPT    
								, bMOBILE_ONLY       
								, bADMIN_ONLY        
								, trn
								);
						}
					}
				}
			}
		}

		protected override string LayoutTableName()
		{
			return "EDITVIEWS_FIELDS";
		}

		// 01/20/2010 Paul.  We need to know the name field. 
		protected override string LayoutNameField()
		{
			return "EDIT_NAME";
		}

		protected override string LayoutIndexName()
		{
			return "FIELD_INDEX";
		}

		protected override string LayoutTypeName()
		{
			return "FIELD_TYPE";
		}

		protected override string LayoutUpdateProcedure()
		{
			return "spEDITVIEWS_FIELDS_Update";
		}

		protected override string LayoutDeleteProcedure()
		{
			return "spEDITVIEWS_FIELDS_Delete";
		}

		protected override void GetLayoutFields(string sNAME)
		{
			dtFields = null;
			if ( !Sql.IsEmptyString(sNAME) )
			{
				dtFields = SplendidCache.EditViewFields(sNAME).Copy();
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
					     + "  from vwEDITVIEWS  " + ControlChars.CrLf
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
			SplendidCache.ClearEditView(sNAME);
		}

		protected override void LayoutView_Bind(bool bInitialize)
		{
			tblMain.Rows.Clear();
			// 09/02/2012 Paul.  Now that we are creating multiple tables, we need to remove the dynamic tables. 
			for ( int n = pnlDynamicMain.Controls.Count - 1; n >= 0; n-- )
			{
				if ( !(pnlDynamicMain.Controls[n] is LiteralControl) && pnlDynamicMain.Controls[n] != tblForm )
					pnlDynamicMain.Controls.RemoveAt(n);
			}
			if ( dtFields != null )
			{
				// 09/12/2009 Paul.  A previous pass may have hidden the table, so we need to reset the visibility state. 
				tblMain.Visible = true;
				DataView dv = dtFields.DefaultView;
				dv.RowFilter = "DELETED = 0";
				dv.Sort      = LayoutIndexName();
				// 04/11/2011 Paul.  Allow the layout mode to be turned off to preview the result. 
				SplendidDynamic.AppendEditViewFields(dv, tblMain, null, GetL10n(), GetT10n(), new CommandEventHandler(Page_Command), !ctlLayoutButtons.Preview(bInitialize), String.Empty);
				// 07/27/2010 Paul.  Hide the border when nothing is displayed. 
				tblForm.CssClass = (tblMain.Rows.Count > 0) ? "tabForm" : String.Empty;
				tblForm.DataBind();
			}
			else
			{
				tblForm.CssClass = String.Empty;
				tblForm.DataBind();
			}
		}

		protected override void Page_Command(Object sender, CommandEventArgs e)
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
								ctlNewRecord.FIELD_ID                = Sql.ToGuid   (row["ID"                     ]);
								ctlNewRecord.FIELD_INDEX             = Sql.ToInteger(row[LayoutIndexName()        ]);
								ctlNewRecord.FIELD_TYPE              = Sql.ToString (row[LayoutTypeName()         ]);
								ctlNewRecord.DATA_LABEL              = Sql.ToString (row["DATA_LABEL"             ]);
								ctlNewRecord.DATA_FIELD              = Sql.ToString (row["DATA_FIELD"             ]);
								// 01/19/2010 Paul.  Add support for new DATA_FORMAT field. 
								ctlNewRecord.DATA_FORMAT             = Sql.ToString (row["DATA_FORMAT"            ]);
								ctlNewRecord.DISPLAY_FIELD           = Sql.ToString (row["DISPLAY_FIELD"          ]);
								ctlNewRecord.LIST_NAME               = Sql.ToString (row["LIST_NAME"              ]);
								ctlNewRecord.DATA_REQUIRED           = Sql.ToBoolean(row["DATA_REQUIRED"          ]);
								ctlNewRecord.UI_REQUIRED             = Sql.ToBoolean(row["UI_REQUIRED"            ]);
								ctlNewRecord.ONCLICK_SCRIPT          = Sql.ToString (row["ONCLICK_SCRIPT"         ]);
								ctlNewRecord.FORMAT_SCRIPT           = Sql.ToString (row["FORMAT_SCRIPT"          ]);
								ctlNewRecord.FORMAT_TAB_INDEX        = Sql.ToInteger(row["FORMAT_TAB_INDEX"       ]);
								ctlNewRecord.FORMAT_MAX_LENGTH       = Sql.ToInteger(row["FORMAT_MAX_LENGTH"      ]);
								ctlNewRecord.FORMAT_SIZE             = Sql.ToInteger(row["FORMAT_SIZE"            ]);
								ctlNewRecord.FORMAT_ROWS             = Sql.ToInteger(row["FORMAT_ROWS"            ]);
								ctlNewRecord.FORMAT_COLUMNS          = Sql.ToInteger(row["FORMAT_COLUMNS"         ]);
								ctlNewRecord.COLSPAN                 = Sql.ToInteger(row["COLSPAN"                ]);
								ctlNewRecord.ROWSPAN                 = Sql.ToInteger(row["ROWSPAN"                ]);
								// 05/17/2009 Paul.  Add support for a generic module popup. 
								ctlNewRecord.MODULE_TYPE             = Sql.ToString (row["MODULE_TYPE"            ]);
								// 06/12/2009 Paul.  Add TOOL_TIP for help hover.
								ctlNewRecord.TOOL_TIP                = Sql.ToString (row["TOOL_TIP"               ]);
								// 09/12/2009 Paul.  Add FIELD_VALIDATOR_ID. 
								ctlNewRecord.FIELD_VALIDATOR_ID      = Sql.ToGuid   (row["FIELD_VALIDATOR_ID"     ]);
								ctlNewRecord.FIELD_VALIDATOR_MESSAGE = Sql.ToString (row["FIELD_VALIDATOR_MESSAGE"]);
								// 09/13/2010 Paul.  Add relationship fields. 
								ctlNewRecord.RELATED_SOURCE_MODULE_NAME   = Sql.ToString(row["RELATED_SOURCE_MODULE_NAME"  ]);
								ctlNewRecord.RELATED_SOURCE_VIEW_NAME     = Sql.ToString(row["RELATED_SOURCE_VIEW_NAME"    ]);
								ctlNewRecord.RELATED_SOURCE_ID_FIELD      = Sql.ToString(row["RELATED_SOURCE_ID_FIELD"     ]);
								ctlNewRecord.RELATED_SOURCE_NAME_FIELD    = Sql.ToString(row["RELATED_SOURCE_NAME_FIELD"   ]);
								ctlNewRecord.RELATED_VIEW_NAME            = Sql.ToString(row["RELATED_VIEW_NAME"           ]);
								ctlNewRecord.RELATED_ID_FIELD             = Sql.ToString(row["RELATED_ID_FIELD"            ]);
								ctlNewRecord.RELATED_NAME_FIELD           = Sql.ToString(row["RELATED_NAME_FIELD"          ]);
								ctlNewRecord.RELATED_JOIN_FIELD           = Sql.ToString(row["RELATED_JOIN_FIELD"          ]);
								// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
								ctlNewRecord.PARENT_FIELD                 = Sql.ToString(row["PARENT_FIELD"                ]);
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
								row[LayoutTypeName()         ] = Sql.ToDBString (ctlNewRecord.FIELD_TYPE             );
								row["DATA_LABEL"             ] = Sql.ToDBString (ctlNewRecord.DATA_LABEL             );
								row["DATA_FIELD"             ] = Sql.ToDBString (ctlNewRecord.DATA_FIELD             );
								// 01/19/2010 Paul.  Add support for new DATA_FORMAT field. 
								row["DATA_FORMAT"            ] = Sql.ToDBString (ctlNewRecord.DATA_FORMAT            );
								row["DISPLAY_FIELD"          ] = Sql.ToDBString (ctlNewRecord.DISPLAY_FIELD          );
								row["LIST_NAME"              ] = Sql.ToDBString (ctlNewRecord.LIST_NAME              );
								// 01/20/2006 Paul.  Need to duplicate the the LIST_NAME in the CACHE_NAME as the dynamic code uses CACHE_NAME. 
								row["CACHE_NAME"             ] = Sql.ToDBString (ctlNewRecord.LIST_NAME              );
								row["DATA_REQUIRED"          ] = Sql.ToDBBoolean(ctlNewRecord.DATA_REQUIRED          );
								row["UI_REQUIRED"            ] = Sql.ToDBBoolean(ctlNewRecord.UI_REQUIRED            );
								row["ONCLICK_SCRIPT"         ] = Sql.ToDBString (ctlNewRecord.ONCLICK_SCRIPT         );
								row["FORMAT_SCRIPT"          ] = Sql.ToDBString (ctlNewRecord.FORMAT_SCRIPT          );
								row["FORMAT_TAB_INDEX"       ] = Sql.ToDBInteger(ctlNewRecord.FORMAT_TAB_INDEX       );
								row["FORMAT_MAX_LENGTH"      ] = Sql.ToDBInteger(ctlNewRecord.FORMAT_MAX_LENGTH      );
								row["FORMAT_SIZE"            ] = Sql.ToDBInteger(ctlNewRecord.FORMAT_SIZE            );
								row["FORMAT_ROWS"            ] = Sql.ToDBInteger(ctlNewRecord.FORMAT_ROWS            );
								row["FORMAT_COLUMNS"         ] = Sql.ToDBInteger(ctlNewRecord.FORMAT_COLUMNS         );
								row["COLSPAN"                ] = Sql.ToDBInteger(ctlNewRecord.COLSPAN                );
								row["ROWSPAN"                ] = Sql.ToDBInteger(ctlNewRecord.ROWSPAN                );
								// 05/17/2009 Paul.  Add support for a generic module popup. 
								row["MODULE_TYPE"            ] = Sql.ToDBString (ctlNewRecord.MODULE_TYPE            );
								// 06/12/2009 Paul.  Add TOOL_TIP for help hover.
								row["TOOL_TIP"               ] = Sql.ToDBString (ctlNewRecord.TOOL_TIP               );
								// 09/12/2009 Paul.  Add FIELD_VALIDATOR_ID. 
								row["FIELD_VALIDATOR_ID"     ] = Sql.ToDBGuid   (ctlNewRecord.FIELD_VALIDATOR_ID     );
								row["FIELD_VALIDATOR_MESSAGE"] = Sql.ToDBString (ctlNewRecord.FIELD_VALIDATOR_MESSAGE);
								// 09/13/2010 Paul.  Add relationship fields. 
								row["RELATED_SOURCE_MODULE_NAME"  ] = Sql.ToDBString (ctlNewRecord.RELATED_SOURCE_MODULE_NAME  );
								row["RELATED_SOURCE_VIEW_NAME"    ] = Sql.ToDBString (ctlNewRecord.RELATED_SOURCE_VIEW_NAME    );
								row["RELATED_SOURCE_ID_FIELD"     ] = Sql.ToDBString (ctlNewRecord.RELATED_SOURCE_ID_FIELD     );
								row["RELATED_SOURCE_NAME_FIELD"   ] = Sql.ToDBString (ctlNewRecord.RELATED_SOURCE_NAME_FIELD   );
								row["RELATED_VIEW_NAME"           ] = Sql.ToDBString (ctlNewRecord.RELATED_VIEW_NAME           );
								row["RELATED_ID_FIELD"            ] = Sql.ToDBString (ctlNewRecord.RELATED_ID_FIELD            );
								row["RELATED_NAME_FIELD"          ] = Sql.ToDBString (ctlNewRecord.RELATED_NAME_FIELD          );
								row["RELATED_JOIN_FIELD"          ] = Sql.ToDBString (ctlNewRecord.RELATED_JOIN_FIELD          );
								// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
								row["PARENT_FIELD"                ] = Sql.ToDBString (ctlNewRecord.PARENT_FIELD                );
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
							row["ID"                     ] = Guid.NewGuid();
							row["DELETED"                ] = 0;
							row["EDIT_NAME"              ] = Sql.ToDBString (ViewState["LAYOUT_VIEW_NAME"]       );
							row[LayoutIndexName()        ] = Sql.ToDBInteger(ctlNewRecord.FIELD_INDEX            );
							row[LayoutTypeName()         ] = Sql.ToDBString (ctlNewRecord.FIELD_TYPE             );
							row["DATA_LABEL"             ] = Sql.ToDBString (ctlNewRecord.DATA_LABEL             );
							row["DATA_FIELD"             ] = Sql.ToDBString (ctlNewRecord.DATA_FIELD             );
							// 01/19/2010 Paul.  Add support for new DATA_FORMAT field. 
							row["DATA_FORMAT"            ] = Sql.ToDBString (ctlNewRecord.DATA_FORMAT            );
							row["DISPLAY_FIELD"          ] = Sql.ToDBString (ctlNewRecord.DISPLAY_FIELD          );
							row["LIST_NAME"              ] = Sql.ToDBString (ctlNewRecord.LIST_NAME              );
							// 01/20/2006 Paul.  Need to duplicate the the LIST_NAME in the CACHE_NAME as the dynamic code uses CACHE_NAME. 
							row["CACHE_NAME"             ] = Sql.ToDBString (ctlNewRecord.LIST_NAME              );
							row["DATA_REQUIRED"          ] = Sql.ToDBBoolean(ctlNewRecord.DATA_REQUIRED          );
							row["UI_REQUIRED"            ] = Sql.ToDBBoolean(ctlNewRecord.UI_REQUIRED            );
							row["ONCLICK_SCRIPT"         ] = Sql.ToDBString (ctlNewRecord.ONCLICK_SCRIPT         );
							row["FORMAT_SCRIPT"          ] = Sql.ToDBString (ctlNewRecord.FORMAT_SCRIPT          );
							row["FORMAT_TAB_INDEX"       ] = Sql.ToDBInteger(ctlNewRecord.FORMAT_TAB_INDEX       );
							row["FORMAT_MAX_LENGTH"      ] = Sql.ToDBInteger(ctlNewRecord.FORMAT_MAX_LENGTH      );
							row["FORMAT_SIZE"            ] = Sql.ToDBInteger(ctlNewRecord.FORMAT_SIZE            );
							row["FORMAT_ROWS"            ] = Sql.ToDBInteger(ctlNewRecord.FORMAT_ROWS            );
							row["FORMAT_COLUMNS"         ] = Sql.ToDBInteger(ctlNewRecord.FORMAT_COLUMNS         );
							row["COLSPAN"                ] = Sql.ToDBInteger(ctlNewRecord.COLSPAN                );
							row["ROWSPAN"                ] = Sql.ToDBInteger(ctlNewRecord.ROWSPAN                );
							// 05/17/2009 Paul.  Add support for a generic module popup. 
							row["MODULE_TYPE"            ] = Sql.ToDBString (ctlNewRecord.MODULE_TYPE            );
							// 06/12/2009 Paul.  Add TOOL_TIP for help hover.
							row["TOOL_TIP"               ] = Sql.ToDBString (ctlNewRecord.TOOL_TIP               );
							// 09/12/2009 Paul.  Add FIELD_VALIDATOR_ID. 
							row["FIELD_VALIDATOR_ID"     ] = Sql.ToDBGuid   (ctlNewRecord.FIELD_VALIDATOR_ID     );
							row["FIELD_VALIDATOR_MESSAGE"] = Sql.ToDBString (ctlNewRecord.FIELD_VALIDATOR_MESSAGE);
							// 09/13/2010 Paul.  Add relationship fields. 
							row["RELATED_SOURCE_MODULE_NAME"  ] = Sql.ToDBString (ctlNewRecord.RELATED_SOURCE_MODULE_NAME  );
							row["RELATED_SOURCE_VIEW_NAME"    ] = Sql.ToDBString (ctlNewRecord.RELATED_SOURCE_VIEW_NAME    );
							row["RELATED_SOURCE_ID_FIELD"     ] = Sql.ToDBString (ctlNewRecord.RELATED_SOURCE_ID_FIELD     );
							row["RELATED_SOURCE_NAME_FIELD"   ] = Sql.ToDBString (ctlNewRecord.RELATED_SOURCE_NAME_FIELD   );
							row["RELATED_VIEW_NAME"           ] = Sql.ToDBString (ctlNewRecord.RELATED_VIEW_NAME           );
							row["RELATED_ID_FIELD"            ] = Sql.ToDBString (ctlNewRecord.RELATED_ID_FIELD            );
							row["RELATED_NAME_FIELD"          ] = Sql.ToDBString (ctlNewRecord.RELATED_NAME_FIELD          );
							row["RELATED_JOIN_FIELD"          ] = Sql.ToDBString (ctlNewRecord.RELATED_JOIN_FIELD          );
							// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
							row["PARENT_FIELD"                ] = Sql.ToDBString (ctlNewRecord.PARENT_FIELD                );
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
						     + "  from vwEDITVIEWS_FIELDS        " + ControlChars.CrLf
						     + " where EDIT_NAME = @EDIT_NAME    " + ControlChars.CrLf
						     + "   and DEFAULT_VIEW = 1          " + ControlChars.CrLf
						     + " order by " + LayoutIndexName() + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@EDIT_NAME", Sql.ToString(ViewState["LAYOUT_VIEW_NAME"]));
						
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
				bool bShowExport = Utils.CachedFileExists(Context, "~/Administration/DynamicLayout/EditViews/export.aspx");
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

