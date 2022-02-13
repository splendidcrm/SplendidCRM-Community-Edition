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
using System.Threading;
using System.Globalization;
using System.Collections;
using System.Drawing;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Web.SessionState;
using System.Diagnostics;

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for RelatedSelect.
	/// </summary>
	public class RelatedSelect : SplendidControl
	{
		protected DataTable       dtLineItems                  ;
		protected GridView        grdMain                      ;
		protected String          sRELATED_SET_LIST            ;
		protected RequiredFieldValidatorForRelatedSelect valRelatedSelect;
		protected bool            bEnabled              = true ;
		protected bool            bAjaxAutoComplete     = false;
		protected bool            bSupportsPopups       = true ;

		#region Related Properties
		protected String          sRELATED_SOURCE_MODULE_NAME  ;
		protected String          sRELATED_SOURCE_VIEW_NAME    ;
		protected String          sRELATED_SOURCE_ID_FIELD     ;
		protected String          sRELATED_SOURCE_NAME_FIELD;
		protected String          sRELATED_VIEW_NAME           ;
		protected String          sRELATED_ID_FIELD            ;
		protected String          sRELATED_NAME_FIELD       ;
		protected String          sRELATED_JOIN_FIELD          ;

		public String RELATED_SOURCE_MODULE_NAME
		{
			get { return sRELATED_SOURCE_MODULE_NAME; }
			set { sRELATED_SOURCE_MODULE_NAME = value; }
		}

		public String RELATED_SOURCE_VIEW_NAME
		{
			get { return sRELATED_SOURCE_VIEW_NAME; }
			set { sRELATED_SOURCE_VIEW_NAME = value; }
		}

		public String RELATED_SOURCE_ID_FIELD
		{
			get { return sRELATED_SOURCE_ID_FIELD; }
			set { sRELATED_SOURCE_ID_FIELD = value; }
		}

		public String RELATED_SOURCE_NAME_FIELD
		{
			get { return sRELATED_SOURCE_NAME_FIELD; }
			set { sRELATED_SOURCE_NAME_FIELD = value; }
		}

		public String RELATED_VIEW_NAME
		{
			get { return sRELATED_VIEW_NAME; }
			set { sRELATED_VIEW_NAME = value; }
		}

		public String RELATED_ID_FIELD
		{
			get { return sRELATED_ID_FIELD; }
			set { sRELATED_ID_FIELD = value; }
		}

		public String RELATED_NAME_FIELD
		{
			get { return sRELATED_NAME_FIELD; }
			set { sRELATED_NAME_FIELD = value; }
		}

		public String RELATED_JOIN_FIELD
		{
			get { return sRELATED_JOIN_FIELD; }
			set { sRELATED_JOIN_FIELD = value; }
		}
		#endregion

		public DataTable LineItems
		{
			get
			{
				// 08/31/2009 Paul.  When called from within the SearchView control, dtLineItems is not initialized. 
				if ( dtLineItems == null )
					dtLineItems = ViewState["LineItems"] as DataTable;
				return dtLineItems;
			}
			set
			{
				dtLineItems = value;
				
				// 08/31/2009 Paul.  Add a blank row after loading. 
				DataRow rowNew = dtLineItems.NewRow();
				dtLineItems.Rows.Add(rowNew);
				
				ViewState["LineItems"] = dtLineItems;
				grdMain.DataSource = dtLineItems;
				// 02/03/2007 Paul.  Start with last line enabled for editing. 
				grdMain.EditIndex = dtLineItems.Rows.Count - 1;
				grdMain.DataBind();
			}
		}

		public bool Enabled
		{
			get { return bEnabled; }
			set { bEnabled = value; }
		}

		public string RELATED_SET_LIST
		{
			get
			{
				StringBuilder sb = new StringBuilder();
				// 08/31/2009 Paul.  When called from within the SearchView control, dtLineItems is not initialized. 
				if ( dtLineItems == null )
					dtLineItems = ViewState["LineItems"] as DataTable;
				if ( dtLineItems != null )
				{
					DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
					foreach ( DataRow row in aCurrentRows )
					{
						// 08/23/2009 Paul.  Although the RELATED_ID should never be NULL or Empty, check for this condition anyway. 
						Guid gRELATED_ID = Sql.ToGuid(row["RELATED_ID"]);
						if ( gRELATED_ID != Guid.Empty )
						{
							if ( sb.Length > 0 )
								sb.Append(",");
							sb.Append(gRELATED_ID.ToString());
						}
					}
				}
				return sb.ToString();
			}
		}

		public void InitTable()
		{
			dtLineItems = new DataTable();
			DataColumn colRELATED_ID      = new DataColumn(sRELATED_ID_FIELD     , Type.GetType("System.Guid"   ));
			DataColumn colRELATED_NAME    = new DataColumn(sRELATED_NAME_FIELD, Type.GetType("System.String" ));
			dtLineItems.Columns.Add(colRELATED_ID     );
			dtLineItems.Columns.Add(colRELATED_NAME   );
		}

		public void Clear()
		{
			InitTable();

			DataRow rowNew = dtLineItems.NewRow();
			dtLineItems.Rows.Add(rowNew);

			ViewState["LineItems"] = dtLineItems;
			grdMain.DataSource = dtLineItems;
			// 02/03/2007 Paul.  Start with last line enabled for editing. 
			grdMain.EditIndex = dtLineItems.Rows.Count - 1;
			grdMain.DataBind();
		}

		public void Validate()
		{
			valRelatedSelect.Enabled = true;
			valRelatedSelect.Validate();
		}

		// 01/24/2010 Paul.  Place the report list in the cache so that it would be available in SearchView. 
		public DataTable SourceData()
		{
			DataTable dt = Session[sRELATED_SOURCE_VIEW_NAME + "." + sRELATED_VIEW_NAME] as DataTable;
			if ( dt == null )
			{
				dt = new DataTable();
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					Regex r = new Regex(@"[^A-Za-z0-9_]");
					sRELATED_SOURCE_VIEW_NAME     = r.Replace(sRELATED_SOURCE_VIEW_NAME    , "");
					sRELATED_SOURCE_ID_FIELD      = r.Replace(sRELATED_SOURCE_ID_FIELD     , "");
					sRELATED_SOURCE_NAME_FIELD = r.Replace(sRELATED_SOURCE_NAME_FIELD, "");

					string sSQL;
					sSQL = "select " + sRELATED_SOURCE_ID_FIELD         + ControlChars.CrLf
					     + "     , " + sRELATED_SOURCE_NAME_FIELD    + ControlChars.CrLf
					     + "  from " + sRELATED_SOURCE_VIEW_NAME        + ControlChars.CrLf
					     + " order by " + sRELATED_SOURCE_NAME_FIELD + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						// 09/19/2010 Paul.  It would not be practical to navigate a large drop down. 
						Sql.LimitResults(cmd, 2000);
						
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dt);
							Session[sRELATED_SOURCE_VIEW_NAME + "." + sRELATED_VIEW_NAME] = dt;
						}
					}
				}
			}
			return dt;
		}

		#region Line Item Editing
		protected void plcSELECT_Init(object sender, EventArgs e)
		{
			PlaceHolder plcSELECT = sender as PlaceHolder;
			if ( plcSELECT != null )
			{
				if ( !bSupportsPopups )
				{
					DropDownList       lstRELATED_ID = new DropDownList();
					HtmlGenericControl spnAjaxErrors = new HtmlGenericControl("span");
					plcSELECT.Controls.Add(lstRELATED_ID);
					plcSELECT.Controls.Add(spnAjaxErrors);
					lstRELATED_ID.ID             = "lst" + sRELATED_ID_FIELD;
					lstRELATED_ID.Enabled        = bEnabled;
					lstRELATED_ID.DataValueField = sRELATED_SOURCE_ID_FIELD     ;
					lstRELATED_ID.DataTextField  = sRELATED_SOURCE_NAME_FIELD;
					try
					{
						lstRELATED_ID.DataSource = SourceData();
						lstRELATED_ID.DataBind();
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						spnAjaxErrors.InnerHtml = "<br />" + ex.Message;
					}
				}
				else
				{
					string sTABLE_NAME    = Sql.ToString(Application["Modules." + sRELATED_SOURCE_MODULE_NAME + ".TableName"   ]);
					string sRELATIVE_PATH = Sql.ToString(Application["Modules." + sRELATED_SOURCE_MODULE_NAME + ".RelativePath"]);
					string sSINGULAR_NAME = sTABLE_NAME;
					if ( sSINGULAR_NAME.EndsWith("IES") )
						sSINGULAR_NAME = sSINGULAR_NAME.Substring(0, sSINGULAR_NAME.Length-3) + "Y";
					else if ( sSINGULAR_NAME.EndsWith("S") )
						sSINGULAR_NAME = sSINGULAR_NAME.Substring(0, sSINGULAR_NAME.Length-1);
					
					HtmlGenericControl nobr = new HtmlGenericControl("nobr");
					plcSELECT.Controls.Add(nobr);

					HiddenField        RELATED_ID        = new HiddenField();
					HiddenField        PREV_RELATED_NAME = new HiddenField();
					TextBox            RELATED_NAME      = new TextBox();
					Literal            SPACER            = new Literal();
					Button             SELECT_NAME       = new Button();
					HtmlGenericControl spnAjaxErrors     = new HtmlGenericControl("span");
					
					nobr.Controls.Add(RELATED_ID        );
					nobr.Controls.Add(PREV_RELATED_NAME );
					nobr.Controls.Add(RELATED_NAME      );
					nobr.Controls.Add(SPACER            );
					nobr.Controls.Add(SELECT_NAME       );
					plcSELECT.Controls.Add(spnAjaxErrors);
					
					RELATED_ID.ID                = sRELATED_ID_FIELD;
					PREV_RELATED_NAME.ID         = "PREV_" + sRELATED_NAME_FIELD;
					RELATED_NAME.ID              = sRELATED_NAME_FIELD;
					RELATED_NAME.Enabled         = bEnabled;
					SPACER.Text                  = " ";
					SELECT_NAME.ID               = "SELECT_NAME";
					SELECT_NAME.Enabled          = bEnabled;
					SELECT_NAME.CssClass         = "button";
					SELECT_NAME.Text             = L10n.Term(".LBL_SELECT_BUTTON_LABEL");
					SELECT_NAME.ToolTip          = L10n.Term(".LBL_SELECT_BUTTON_TITLE");
					RELATED_NAME.Attributes.Add("autocomplete", "off");
					RELATED_NAME.Attributes.Add("onblur", sTABLE_NAME + "_" + sSINGULAR_NAME + "_" + sRELATED_NAME_FIELD + "_Changed(this);");
					
					ImageButton btnUpdate     = plcSELECT.FindControl("btnUpdate") as ImageButton;
					SELECT_NAME.OnClientClick = "return ModulePopup('" + sRELATED_SOURCE_MODULE_NAME + "', '" + RELATED_ID.ClientID + "', '" + RELATED_NAME.ClientID + "', null, false, null, '" + btnUpdate.ClientID + "');";

					// 07/28/2010 Paul.  Save AjaxAutoComplete and SupportsPopups for use in RelatedSelect. 
					// We are having issues with the data binding event occurring before the page load. 
					if ( bAjaxAutoComplete || Sql.ToBoolean(Page.Items["AjaxAutoComplete"]) )
					{
						AjaxControlToolkit.AutoCompleteExtender auto = new AjaxControlToolkit.AutoCompleteExtender();
						plcSELECT.Controls.Add(auto);
						auto.ID                   = "auto" + sRELATED_NAME_FIELD;
						auto.TargetControlID      = sRELATED_NAME_FIELD;
						// 10/14/2011 Paul.  We need to include the singular name as that is part of the convention. 
						auto.ServiceMethod        = sTABLE_NAME + "_" + sSINGULAR_NAME + "_" + sRELATED_NAME_FIELD + "_List";
						auto.OnClientItemSelected = sTABLE_NAME + "_" + sSINGULAR_NAME + "_" + sRELATED_NAME_FIELD + "_ItemSelected";
						auto.ServicePath          = "~/" + sRELATED_SOURCE_MODULE_NAME + "/AutoComplete.asmx";
						auto.MinimumPrefixLength  = 2;
						auto.CompletionInterval   = 250;
						auto.EnableCaching        = true;
						// 12/09/2010 Paul.  Provide a way to customize the AutoComplete.CompletionSetCount. 
						auto.CompletionSetCount   = Crm.Config.CompletionSetCount();
					}
				}
			}
		}

		protected void grdMain_RowCreated(object sender, GridViewRowEventArgs e)
		{
			if ( (e.Row.RowState & DataControlRowState.Edit) == DataControlRowState.Edit )
			{
			}
		}

		protected void grdMain_RowDataBound(object sender, GridViewRowEventArgs e)
		{
			if ( e.Row.RowType == DataControlRowType.DataRow )
			{
				// 12/07/2009 Paul.  The Opera Mini browser does not support popups. Use a DropdownList instead. 
				// 07/28/2010 Paul.  Save AjaxAutoComplete and SupportsPopups for use in RelatedSelect. 
				// We are having issues with the data binding event occurring before the page load. 
				if ( !bSupportsPopups )
				{
					DropDownList lstRELATED_ID = e.Row.FindControl("lst" + sRELATED_ID_FIELD) as DropDownList;
					if ( lstRELATED_ID != null )
					{
						try
						{
							// 02/07/2010 Paul.  Defensive programming, we don't need to convert the Eval result to a string before using it. 
							// 08/19/2010 Paul.  Check the list before assigning the value. 
							Utils.SetValue(lstRELATED_ID, Sql.ToGuid(DataBinder.Eval(e.Row.DataItem, sRELATED_ID_FIELD)).ToString() );
						}
						catch
						{
						}
					}
				}
				else
				{
					GridViewRow gr = e.Row;
					DataRowView row = gr.DataItem as DataRowView;
					HiddenField RELATED_ID        = gr.FindControl(sRELATED_ID_FIELD               ) as HiddenField;
					HiddenField PREV_RELATED_NAME = gr.FindControl("PREV_" + sRELATED_NAME_FIELD) as HiddenField;
					TextBox     RELATED_NAME      = gr.FindControl(sRELATED_NAME_FIELD          ) as TextBox;
					if ( RELATED_ID        != null ) RELATED_ID       .Value = Sql.ToString(row[sRELATED_ID_FIELD     ]);
					if ( PREV_RELATED_NAME != null ) PREV_RELATED_NAME.Value = Sql.ToString(row[sRELATED_NAME_FIELD]);
					if ( RELATED_NAME      != null ) RELATED_NAME     .Text  = Sql.ToString(row[sRELATED_NAME_FIELD]);
				}
			}
		}

		protected void grdMain_RowEditing(object sender, GridViewEditEventArgs e)
		{
			grdMain.EditIndex = e.NewEditIndex;
			if ( dtLineItems != null )
			{
				grdMain.DataSource = dtLineItems;
				grdMain.DataBind();
			}
		}

		protected void grdMain_RowDeleting(object sender, GridViewDeleteEventArgs e)
		{
			if ( dtLineItems != null )
			{
				//dtLineItems.Rows.RemoveAt(e.RowIndex);
				//dtLineItems.Rows[e.RowIndex].Delete();
				// 08/07/2007 fhsakai.  There might already be deleted rows, so make sure to first obtain the current rows. 
				DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
				aCurrentRows[e.RowIndex].Delete();
				
				aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
				// 02/04/2007 Paul.  Always allow editing of the last empty row. Add blank row if necessary. 
				// 08/11/2007 Paul.  Allow an item to be manually added.  Require either a product ID or a name. 
				if ( aCurrentRows.Length == 0 || !Sql.IsEmptyString(aCurrentRows[aCurrentRows.Length-1]["CONTACT_NAME"]) || !Sql.IsEmptyGuid(aCurrentRows[aCurrentRows.Length-1]["CONTACT_ID"]) )
				{
					DataRow rowNew = dtLineItems.NewRow();
					dtLineItems.Rows.Add(rowNew);
					aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
				}

				ViewState["LineItems"] = dtLineItems;
				grdMain.DataSource = dtLineItems;
				// 03/15/2007 Paul.  Make sure to use the last row of the current set, not the total rows of the table.  Some rows may be deleted. 
				grdMain.EditIndex = aCurrentRows.Length - 1;
				grdMain.DataBind();
			}
		}

		protected void grdMain_RowUpdating(object sender, GridViewUpdateEventArgs e)
		{
			if ( dtLineItems != null )
			{
				GridViewRow gr = grdMain.Rows[e.RowIndex];
				DropDownList       lstRELATED_ID   = gr.FindControl("lst" + sRELATED_ID_FIELD) as DropDownList;
				HiddenField        RELATED_ID      = gr.FindControl(sRELATED_ID_FIELD        ) as HiddenField;
				TextBox            RELATED_NAME    = gr.FindControl(sRELATED_NAME_FIELD   ) as TextBox    ;
				HtmlGenericControl spnAjaxErrors   = gr.FindControl(sRELATED_ID_FIELD + "_AjaxErrors") as HtmlGenericControl;
				Guid   gRELATED_ID   = Guid.Empty;
				string sRELATED_NAME = String.Empty;
				// 12/07/2009 Paul.  The Opera Mini browser does not support popups. Use a DropdownList instead. 
				if ( !bSupportsPopups && lstRELATED_ID != null )
				{
					if ( lstRELATED_ID.SelectedItem != null )
					{
						gRELATED_ID   = Sql.ToGuid(lstRELATED_ID.SelectedValue);
						sRELATED_NAME = Sql.ToString(lstRELATED_ID.SelectedItem.Text);
					}
				}
				else
				{
					if ( RELATED_ID != null )
						gRELATED_ID = Sql.ToGuid(RELATED_ID.Value);
					if ( RELATED_NAME    != null ) 
						sRELATED_NAME = RELATED_NAME.Text;
				}

				if ( gRELATED_ID != Guid.Empty )
				{
					//DataRow row = dtLineItems.Rows[e.RowIndex];
					// 12/07/2007 garf.  If there are deleted rows in the set, then the index will be wrong.  Make sure to use the current rowset. 
					DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
					DataRow row = aCurrentRows[e.RowIndex];
					row[sRELATED_ID_FIELD     ] = gRELATED_ID;
					row[sRELATED_NAME_FIELD] = sRELATED_NAME;
					
					// 12/07/2007 Paul.  aCurrentRows is defined above. 
					//DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
					// 03/30/2007 Paul.  Always allow editing of the last empty row. Add blank row if necessary. 
					// 08/11/2007 Paul.  Allow an item to be manually added.  Require either a product ID or a name. 
					if ( aCurrentRows.Length == 0 || !Sql.IsEmptyString(aCurrentRows[aCurrentRows.Length-1][sRELATED_NAME_FIELD]) || !Sql.IsEmptyGuid(aCurrentRows[aCurrentRows.Length-1][sRELATED_ID_FIELD]) )
					{
						DataRow rowNew = dtLineItems.NewRow();
						dtLineItems.Rows.Add(rowNew);
						aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
					}

					ViewState["LineItems"] = dtLineItems;
					grdMain.DataSource = dtLineItems;
					// 03/30/2007 Paul.  Make sure to use the last row of the current set, not the total rows of the table.  Some rows may be deleted. 
					grdMain.EditIndex = aCurrentRows.Length - 1;
					grdMain.DataBind();
				}
				// 02/07/2010 Paul.  Defensive programming, check for valid spnAjaxErrors control. 
				else if ( spnAjaxErrors != null )
				{
					spnAjaxErrors.InnerHtml = "<br />" + L10n.Term("Related.ERR_INVALID_RELATED");
				}
			}
		}

		protected void grdMain_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
		{
			grdMain.EditIndex = -1;
			if ( dtLineItems != null )
			{
				DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
				grdMain.DataSource = dtLineItems;
				// 03/15/2007 Paul.  Make sure to use the last row of the current set, not the total rows of the table.  Some rows may be deleted. 
				grdMain.EditIndex = aCurrentRows.Length - 1;
				grdMain.DataBind();
			}
		}
		#endregion

		public void LoadLineItems(Guid gPARENT_ID)
		{
			// 12/07/2009 Paul.  The Opera Mini browser does not support popups. Use a DropdownList instead. 
			bSupportsPopups = Sql.ToBoolean(Page.Items["SupportsPopups"]);
			if ( this.IsMobile )
			{
				// 11/24/2010 Paul.  .NET 4 has broken the compatibility of the browser file system. 
				// We are going to minimize our reliance on browser files in order to reduce deployment issues. 
				bSupportsPopups = Utils.SupportsPopups;
			}
			// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
			bool bIsPostBack = this.IsPostBack && !NotPostBack;
			if ( !bIsPostBack )
			{
				DataControlField col = grdMain.Columns[0];
				col.HeaderText = L10n.Term(Sql.ToString(Application["Modules." + sRELATED_SOURCE_MODULE_NAME + ".DisplayName"]));
				if ( (!Sql.IsEmptyGuid(gPARENT_ID)) )
				{
					// 08/24/2009 Paul.  We need to create another connection, even though there is usually an existing open connection. 
					// This is because we cannot perform another query while the rdr in the existing connection is still open. 
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						Regex r = new Regex(@"[^A-Za-z0-9_]");
						sRELATED_VIEW_NAME            = r.Replace(sRELATED_VIEW_NAME           , "");
						sRELATED_ID_FIELD             = r.Replace(sRELATED_ID_FIELD            , "");
						sRELATED_NAME_FIELD        = r.Replace(sRELATED_NAME_FIELD       , "");
						sRELATED_JOIN_FIELD           = r.Replace(sRELATED_JOIN_FIELD          , "");

						string sSQL;
						sSQL = "select " + sRELATED_ID_FIELD         + ControlChars.CrLf
						     + "     , " + sRELATED_NAME_FIELD    + ControlChars.CrLf
						     + "  from " + sRELATED_VIEW_NAME        + ControlChars.CrLf
						     + " where " + sRELATED_JOIN_FIELD       + " = @" + sRELATED_JOIN_FIELD + ControlChars.CrLf
						     + " order by " + sRELATED_NAME_FIELD + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@" + sRELATED_JOIN_FIELD, gPARENT_ID);
							
							if ( bDebug )
								RegisterClientScriptBlock(sRELATED_VIEW_NAME, Sql.ClientScriptBlock(cmd));
							
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								dtLineItems = new DataTable();
								da.Fill(dtLineItems);
								
								// 03/27/2007 Paul.  Always add blank line to allow quick editing. 
								DataRow rowNew = dtLineItems.NewRow();
								dtLineItems.Rows.Add(rowNew);
								
								ViewState["LineItems"] = dtLineItems;
								grdMain.DataSource = dtLineItems;
								// 03/27/2007 Paul.  Start with last line enabled for editing. 
								grdMain.EditIndex = dtLineItems.Rows.Count - 1;
								grdMain.DataBind();
							}
						}
					}
				}
				else
				{
					InitTable();

					DataRow rowNew = dtLineItems.NewRow();
					dtLineItems.Rows.Add(rowNew);

					ViewState["LineItems"] = dtLineItems;
					grdMain.DataSource = dtLineItems;
					// 02/03/2007 Paul.  Start with last line enabled for editing. 
					grdMain.EditIndex = dtLineItems.Rows.Count - 1;
					grdMain.DataBind();
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			valRelatedSelect.ErrorMessage = L10n.Term(".ERR_REQUIRED_FIELD");
			bSupportsPopups = Sql.ToBoolean(Page.Items["SupportsPopups"]);
			if ( this.IsMobile )
			{
				// 11/24/2010 Paul.  .NET 4 has broken the compatibility of the browser file system. 
				// We are going to minimize our reliance on browser files in order to reduce deployment issues. 
				bSupportsPopups = Utils.SupportsPopups;
			}
			// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
			bool bIsPostBack = this.IsPostBack && !NotPostBack;
			if ( bIsPostBack )
			{
				dtLineItems = ViewState["LineItems"] as DataTable;
				grdMain.DataSource = dtLineItems;
			}
			else
			{
				Session.Remove(sRELATED_SOURCE_VIEW_NAME + "." + sRELATED_VIEW_NAME);
			}
			
			// 05/06/2010 Paul.  Move the ajax refence code to Page_Load as it only needs to be called once. 
			ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
			// 11/23/2009 Paul.  SplendidCRM 4.0 is very slow on Blackberry devices.  Lets try and turn off AJAX AutoComplete. 
			bAjaxAutoComplete = (mgrAjax != null);
			if ( this.IsMobile )
			{
				// 11/24/2010 Paul.  .NET 4 has broken the compatibility of the browser file system. 
				// We are going to minimize our reliance on browser files in order to reduce deployment issues. 
				bAjaxAutoComplete = Utils.AllowAutoComplete && (mgrAjax != null);
			}
			if ( bAjaxAutoComplete )
			{
				ServiceReference svc = new ServiceReference("~/" + sRELATED_SOURCE_MODULE_NAME + "/AutoComplete.asmx");
				ScriptReference  scr = new ScriptReference ("~/" + sRELATED_SOURCE_MODULE_NAME + "/AutoComplete.js"  );
				if ( !mgrAjax.Services.Contains(svc) )
					mgrAjax.Services.Add(svc);
				if ( !mgrAjax.Scripts.Contains(scr) )
					mgrAjax.Scripts.Add(scr);
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
		}
		#endregion
	}
}

