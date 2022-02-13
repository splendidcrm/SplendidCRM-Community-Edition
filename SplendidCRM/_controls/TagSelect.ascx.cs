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
using System.Threading;
using System.Globalization;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for TagSelect.
	/// </summary>
	public class TagSelect : SplendidControl
	{
		protected DataTable       dtLineItems           ;
		protected GridView        grdMain               ;
		protected String          sTAG_SET_LIST         ;
		protected Panel           pnlAddReplace         ;
		protected RadioButton     radTagSetReplace      ;
		protected RadioButton     radTagSetAdd          ;
		protected bool            bShowAddReplace       = false;
		protected bool            bSupportsPopups       = true;
		protected RequiredFieldValidatorForTagSelect valTagSelect;
		protected bool            bEnabled              = true;
		protected bool            bAjaxAutoComplete     = false;
		protected short           nTagIndex             = 12;

		// 12/10/2017 Paul.  Provide a way to set the tab index. 
		public short TabIndex
		{
			get
			{
				return nTagIndex;
			}
			set
			{
				nTagIndex = value;
			}
		}

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

		public bool ShowAddReplace
		{
			get { return bShowAddReplace; }
			set { bShowAddReplace = value; }
		}

		public bool Enabled
		{
			get { return bEnabled; }
			set { bEnabled = value; }
		}

		public string TAG_SET_NAME
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
						string sTAG_NAME = Sql.ToString(row["TAG_NAME"]);
						if ( !Sql.IsEmptyString(sTAG_NAME) )
						{
							// 05/12/2016 Paul.  Cap the max to match the SQL nvarchar(4000). 
							if ( sb.Length + sTAG_NAME.Length + 1 < 4000 )
							{
								if ( sb.Length > 0 )
									sb.Append(",");
								sb.Append(sTAG_NAME);
							}
						}
					}
				}
				return sb.ToString();
			}
			set
			{
				if ( dtLineItems == null )
				{
					dtLineItems = ViewState["LineItems"] as DataTable;
					if ( dtLineItems == null )
						InitTable();
				}
				string[] arrTAGS = value.Split(',');
				List<string> lstNew = new List<string>();
				foreach ( string sTAG_NAME in arrTAGS )
				{
					try
					{
						if ( !Sql.IsEmptyString(sTAG_NAME.Trim()) )
						{
							if ( !lstNew.Contains(sTAG_NAME.Trim()) )
								lstNew.Add(sTAG_NAME.Trim());
						}
					}
					catch
					{
					}
				}
				List<string> lstExisting = new List<string>();
				DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
				foreach ( DataRow row in aCurrentRows )
				{
					string sTAG_NAME = Sql.ToString(row["TAG_NAME"]);
					// 04/14/2013 Paul.  Delete existing records that do not exist in the new list. 
					if ( !lstNew.Contains(sTAG_NAME) )
						row.Delete();
					else if ( !lstExisting.Contains(sTAG_NAME) )
						lstExisting.Add(sTAG_NAME);
				}
				foreach ( string sTAG_NAME in lstNew )
				{
					// 04/14/2013 Paul.  Add new records not found in existing list. 
					if ( !lstExisting.Contains(sTAG_NAME) )
					{
						DataRow rowNew = dtLineItems.NewRow();
						dtLineItems.Rows.Add(rowNew);
						rowNew["TAG_ID"     ] = Guid.Empty;
						rowNew["TAG_NAME"   ] = sTAG_NAME;
					}
				}
				// 04/14/2013 Paul.  The blank row at the bottom is always deleted, so always add it back. 
				DataRow rowBlank = dtLineItems.NewRow();
				dtLineItems.Rows.Add(rowBlank);
				ViewState["LineItems"] = dtLineItems;
			}
		}

		// 04/07/2014 Paul.  When adding or removing a user to a call or meeting, we also need to add the private team to the dynamic teams. 
		public void AddTag(Guid gNEW_TAG_ID)
		{
			if ( dtLineItems == null )
			{
				dtLineItems = ViewState["LineItems"] as DataTable;
				if ( dtLineItems == null )
					InitTable();
			}
			List<Guid> lstExisting = new List<Guid>();
			DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
			foreach ( DataRow row in aCurrentRows )
			{
				Guid gTAG_ID = Sql.ToGuid(row["TAG_ID"]);
				if ( Sql.IsEmptyGuid(gTAG_ID) )
					row.Delete();
				else if ( !lstExisting.Contains(gTAG_ID) )
					lstExisting.Add(gTAG_ID);
			}
			// 04/08/2014 Paul.  Add new records not found in existing list. 
			if ( !lstExisting.Contains(gNEW_TAG_ID) )
			{
				string sTAG_NAME = Crm.Modules.ItemName(HttpContext.Current.Application, "Tags", gNEW_TAG_ID);
				if ( !Sql.IsEmptyString(sTAG_NAME) )
				{
					DataRow rowNew = dtLineItems.NewRow();
					dtLineItems.Rows.Add(rowNew);
					rowNew["TAG_ID"     ] = gNEW_TAG_ID;
					rowNew["TAG_NAME"   ] = sTAG_NAME;
				}
			}
			// 04/08/2014 Paul.  The blank row at the bottom is always deleted, so always add it back. 
			DataRow rowBlank = dtLineItems.NewRow();
			dtLineItems.Rows.Add(rowBlank);
			ViewState["LineItems"] = dtLineItems;
			
			aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
			grdMain.DataSource = dtLineItems;
			grdMain.EditIndex = aCurrentRows.Length - 1;
			grdMain.DataBind();
		}

		// 04/07/2014 Paul.  When adding or removing a user to a call or meeting, we also need to add the private team to the dynamic teams. 
		public void RemoveTag(Guid gREMOVE_TAG_ID)
		{
			if ( dtLineItems == null )
			{
				dtLineItems = ViewState["LineItems"] as DataTable;
				if ( dtLineItems == null )
					InitTable();
			}
			List<Guid> lstExisting = new List<Guid>();
			DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
			foreach ( DataRow row in aCurrentRows )
			{
				Guid gTAG_ID = Sql.ToGuid(row["TAG_ID"]);
				if ( Sql.IsEmptyGuid(gTAG_ID) || gTAG_ID == gREMOVE_TAG_ID )
					row.Delete();
			}
			// 04/08/2014 Paul.  The blank row at the bottom is always deleted, so always add it back. 
			DataRow rowBlank = dtLineItems.NewRow();
			dtLineItems.Rows.Add(rowBlank);
			ViewState["LineItems"] = dtLineItems;
			
			aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
			grdMain.DataSource = dtLineItems;
			grdMain.EditIndex = aCurrentRows.Length - 1;
			grdMain.DataBind();
		}

		public bool ADD_TAG_SET
		{
			get
			{
				return pnlAddReplace.Visible && radTagSetAdd.Checked;
			}
		}

		public void InitTable()
		{
			dtLineItems = new DataTable();
			DataColumn colTAG_ID      = new DataColumn("TAG_ID"     , Type.GetType("System.Guid"   ));
			DataColumn colTAG_NAME    = new DataColumn("TAG_NAME"   , Type.GetType("System.String" ));
			dtLineItems.Columns.Add(colTAG_ID     );
			dtLineItems.Columns.Add(colTAG_NAME   );
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

		// 11/11/2010 Paul.  Provide a way to disable validation in a rule. 
		public void Validate()
		{
			Validate(true);
		}

		public void Validate(bool bEnabled)
		{
			valTagSelect.Enabled = bEnabled;
			valTagSelect.Validate();
		}

		#region Line Item Editing
		protected void grdMain_RowCreated(object sender, GridViewRowEventArgs e)
		{
			if ( (e.Row.RowState & DataControlRowState.Edit) == DataControlRowState.Edit )
			{
				// 12/07/2009 Paul.  The Opera Mini browser does not support popups. Use a DropdownList instead. 
				// 07/28/2010 Paul.  Save AjaxAutoComplete and SupportsPopups for use in TagSelect and KBSelect. 
				// We are having issues with the data binding event occurring before the page load. 
				if ( !(bSupportsPopups || Sql.ToBoolean(Page.Items["SupportsPopups"])) )
				{
					DropDownList lstTAG_ID = e.Row.FindControl("lstTAG_ID") as DropDownList;
					if ( lstTAG_ID != null )
					{
						lstTAG_ID.DataSource = SplendidCache.Tags();
						lstTAG_ID.DataBind();
						lstTAG_ID.Visible = !bSupportsPopups;
					}
					// 12/10/2009 Paul.  The existing user controls were not being hidden on a Blackberry by the span as expected. 
					// So we need to hide the popup fields manually. 
					TextBox TAG_NAME = e.Row.FindControl("TAG_NAME") as TextBox;
					if ( TAG_NAME != null )
						TAG_NAME.Visible = bSupportsPopups;
					Button SELECT_NAME = e.Row.FindControl("SELECT_NAME") as Button;
					if ( SELECT_NAME != null )
						SELECT_NAME.Visible = bSupportsPopups;
				}
				else
				{
					// 07/28/2010 Paul.  Save AjaxAutoComplete and SupportsPopups for use in TagSelect and KBSelect. 
					// We are having issues with the data binding event occurring before the page load. 
					if ( bAjaxAutoComplete || Sql.ToBoolean(Page.Items["AjaxAutoComplete"]) )
					{
						// <ajaxToolkit:AutoCompleteExtender ID="autoTAG_NAME" TargetControlID="TAG_NAME" ServiceMethod="TAGS_TAG_NAME_List" OnClientItemSelected="TAGS_TAG_NAME_ItemSelected" ServicePath="~/Administration/Tags/AutoComplete.asmx" MinimumPrefixLength="2" CompletionInterval="250" EnableCaching="true" CompletionSetCount="12" runat="server" />
						AjaxControlToolkit.AutoCompleteExtender auto = new AjaxControlToolkit.AutoCompleteExtender();
						e.Row.Cells[0].Controls.Add(auto);
						auto.ID                   = "autoTAG_NAME";
						auto.TargetControlID      = "TAG_NAME";
						auto.ServiceMethod        = "TAGS_TAG_NAME_List";
						auto.OnClientItemSelected = "TAGS_TAG_NAME_ItemSelected";
						auto.ServicePath          = "~/Administration/Tags/AutoComplete.asmx";
						auto.MinimumPrefixLength  = 2;
						auto.CompletionInterval   = 250;
						auto.EnableCaching        = true;
						// 12/09/2010 Paul.  Provide a way to customize the AutoComplete.CompletionSetCount. 
						auto.CompletionSetCount   = Crm.Config.CompletionSetCount();
					}
				}
			}
		}

		protected void grdMain_RowDataBound(object sender, GridViewRowEventArgs e)
		{
			if ( e.Row.RowType == DataControlRowType.DataRow )
			{
				// 12/07/2009 Paul.  The Opera Mini browser does not support popups. Use a DropdownList instead. 
				// 07/28/2010 Paul.  Save AjaxAutoComplete and SupportsPopups for use in TagSelect and KBSelect. 
				// We are having issues with the data binding event occurring before the page load. 
				if ( !(bSupportsPopups || Sql.ToBoolean(Page.Items["SupportsPopups"])) )
				{
					DropDownList lstTAG_ID = e.Row.FindControl("lstTAG_ID") as DropDownList;
					if ( lstTAG_ID != null )
					{
						try
						{
							// 02/07/2010 Paul.  Defensive programming, we don't need to convert the Eval result to a string before using it. 
							// 08/19/2010 Paul.  Check the list before assigning the value. 
							Utils.SetValue(lstTAG_ID, Sql.ToGuid(DataBinder.Eval(e.Row.DataItem, "TAG_ID")).ToString() );
						}
						catch
						{
						}
					}
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
				if ( aCurrentRows.Length == 0 || !Sql.IsEmptyString(aCurrentRows[aCurrentRows.Length-1]["TAG_NAME"]) || !Sql.IsEmptyGuid(aCurrentRows[aCurrentRows.Length-1]["TAG_ID"]) )
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
				DropDownList       lstTAG_ID       = gr.FindControl("lstTAG_ID"          ) as DropDownList;
				HiddenField        txtTAG_ID       = gr.FindControl("TAG_ID"             ) as HiddenField;
				TextBox            txtTAG_NAME     = gr.FindControl("TAG_NAME"           ) as TextBox    ;
				HtmlGenericControl spnAjaxErrors   = gr.FindControl("TAG_NAME_AjaxErrors") as HtmlGenericControl;
				Guid   gTAG_ID   = Guid.Empty;
				string sTAG_NAME = String.Empty;
				// 12/07/2009 Paul.  The Opera Mini browser does not support popups. Use a DropdownList instead. 
				if ( !bSupportsPopups && lstTAG_ID != null )
				{
					gTAG_ID   = Sql.ToGuid(lstTAG_ID.SelectedValue);
					sTAG_NAME = Sql.ToString(lstTAG_ID.SelectedItem.Text);
				}
				else
				{
					if ( txtTAG_ID != null )
						gTAG_ID = Sql.ToGuid(txtTAG_ID.Value);
					if ( txtTAG_NAME    != null ) 
						sTAG_NAME = txtTAG_NAME.Text;
				}
				if ( sTAG_NAME.Contains(",") )
				{
					string[] arrTAG_NAME = sTAG_NAME.Split(',');
					int nRowIndex = e.RowIndex;
					DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
					foreach ( string sNAME in arrTAG_NAME )
					{
						// 10/31/2021 Paul.  Moved Tag.Get to ModuleUtils. 
						ModuleUtils.Tag item = ModuleUtils.Tag.Get(Application, sNAME);
						DataRow row = aCurrentRows[nRowIndex];
						row["TAG_ID"     ] = item.ID;
						row["TAG_NAME"   ] = item.NAME;
						DataRow rowNew = dtLineItems.NewRow();
						dtLineItems.Rows.Add(rowNew);
						aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
						// 05/12/2016 Paul.  The user may be editing an item in the middle of the list, but add more than one item.  Make sure that other items are appended. 
						nRowIndex = aCurrentRows.Length - 1;
					}
					
					if ( aCurrentRows.Length == 0 || !Sql.IsEmptyString(aCurrentRows[aCurrentRows.Length-1]["TAG_NAME"]) || !Sql.IsEmptyGuid(aCurrentRows[aCurrentRows.Length-1]["TAG_ID"]) )
					{
						DataRow rowNew = dtLineItems.NewRow();
						dtLineItems.Rows.Add(rowNew);
						aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
					}

					ViewState["LineItems"] = dtLineItems;
					grdMain.DataSource = dtLineItems;
					grdMain.EditIndex = aCurrentRows.Length - 1;
					grdMain.DataBind();
				}
				else if ( !Sql.IsEmptyString(sTAG_NAME) )
				{
					//DataRow row = dtLineItems.Rows[e.RowIndex];
					// 12/07/2007 garf.  If there are deleted rows in the set, then the index will be wrong.  Make sure to use the current rowset. 
					DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
					DataRow row = aCurrentRows[e.RowIndex];
					row["TAG_ID"     ] = gTAG_ID;
					row["TAG_NAME"   ] = sTAG_NAME;
					
					// 12/07/2007 Paul.  aCurrentRows is defined above. 
					//DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
					// 03/30/2007 Paul.  Always allow editing of the last empty row. Add blank row if necessary. 
					// 08/11/2007 Paul.  Allow an item to be manually added.  Require either a product ID or a name. 
					if ( aCurrentRows.Length == 0 || !Sql.IsEmptyString(aCurrentRows[aCurrentRows.Length-1]["TAG_NAME"]) || !Sql.IsEmptyGuid(aCurrentRows[aCurrentRows.Length-1]["TAG_ID"]) )
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
					spnAjaxErrors.InnerHtml = "<br />" + L10n.Term("Tags.ERR_INVALID_TAG");
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

		// 04/14/2016 Paul.  Provide a way to reload the line items. 
		public void LoadLineItems(Guid gID, bool bAllowDefaults)
		{
			LoadLineItems(gID, bAllowDefaults, false);
		}
	
		public void LoadLineItems(Guid gID, bool bAllowDefaults, bool bReload)
		{
			// 12/07/2009 Paul.  The Opera Mini browser does not support popups. Use a DropdownList instead. 
			if ( this.IsMobile )
			{
				// 11/24/2010 Paul.  .NET 4 has broken the compatibility of the browser file system. 
				// We are going to minimize our reliance on browser files in order to reduce deployment issues. 
				bSupportsPopups = Utils.SupportsPopups;
			}
			// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
			bool bIsPostBack = this.IsPostBack && !NotPostBack;
			if ( !bIsPostBack || bReload )
			{
				// 08/29/2009 Paul.  Not sure why, but we need to manually bind the Add/Replace controls. 
				pnlAddReplace    .DataBind();
				radTagSetReplace.DataBind();
				radTagSetAdd    .DataBind();
				foreach ( DataControlField col in grdMain.Columns )
				{
					if ( !Sql.IsEmptyString(col.HeaderText) )
					{
						col.HeaderText = L10n.Term(col.HeaderText);
					}
					CommandField cf = col as CommandField;
					if ( cf != null )
					{
						// 01/18/2010 Paul.  These fields must be set in code as they are not bindable. 
						cf.ShowEditButton   = bEnabled;
						cf.ShowDeleteButton = bEnabled;
						// 08/31/2009 Paul.  Now that we are using our own ImageButtons in a TemplateField, 
						// we no longer need this CommandField logic. 
						/*
						if ( cf.Visible )
						{
							cf.EditText       = L10n.Term(cf.EditText  );
							cf.DeleteText     = L10n.Term(cf.DeleteText);
							cf.UpdateText     = L10n.Term(cf.UpdateText);
							cf.CancelText     = L10n.Term(cf.CancelText);
							cf.EditImageUrl   = Session["themeURL"] + "images/edit_inline.gif"   ;
							cf.DeleteImageUrl = Session["themeURL"] + "images/delete_inline.gif" ;
							cf.UpdateImageUrl = Session["themeURL"] + "images/accept_inline.gif" ;
							cf.CancelImageUrl = Session["themeURL"] + "images/decline_inline.gif";
						}
						*/
					}
				}
				if ( (!Sql.IsEmptyGuid(gID)) )
				{
					// 08/24/2009 Paul.  We need to create another connection, even though there is usually an existing open connection. 
					// This is because we cannot perform another query while the rdr in the existing connection is still open. 
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						string sSQL;
						sSQL = "select *                " + ControlChars.CrLf
						     + "  from vwTAG_BEAN_REL   " + ControlChars.CrLf
						     + " where BEAN_ID = @ID    " + ControlChars.CrLf
						     + " order by TAG_NAME asc  " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@ID", gID);
							
							if ( bDebug )
								RegisterClientScriptBlock("vwTAG_BEAN_REL", Sql.ClientScriptBlock(cmd));
							
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
			valTagSelect.ErrorMessage = L10n.Term(".ERR_REQUIRED_FIELD");
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
				// 03/31/2007 Paul.  Don't bind the grid, otherwise edits will be lost. 
				//grdMain.DataBind();
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
				Sql.AddServiceReference(mgrAjax, "~/Administration/Tags/AutoComplete.asmx");
				Sql.AddScriptReference (mgrAjax, "~/Administration/Tags/AutoComplete.js"  );
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
