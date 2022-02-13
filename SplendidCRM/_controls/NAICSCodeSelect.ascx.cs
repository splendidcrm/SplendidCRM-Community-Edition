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
	///		Summary description for NAICSCodeSelect.
	/// </summary>
	public class NAICSCodeSelect : SplendidControl
	{
		protected DataTable       dtLineItems           ;
		protected GridView        grdMain               ;
		protected String          sNAICS_SET_NAME       ;
		protected Panel           pnlAddReplace         ;
		protected RadioButton     radNaicsSetReplace    ;
		protected RadioButton     radNaicsSetAdd        ;
		protected bool            bShowAddReplace       = false;
		protected bool            bSupportsPopups       = true;
		protected RequiredFieldValidatorForNAICSCodeSelect valNAICSCodeSelect;
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
				if ( dtLineItems == null )
					dtLineItems = ViewState["LineItems"] as DataTable;
				return dtLineItems;
			}
			set
			{
				dtLineItems = value;
				
				DataRow rowNew = dtLineItems.NewRow();
				dtLineItems.Rows.Add(rowNew);
				
				ViewState["LineItems"] = dtLineItems;
				grdMain.DataSource = dtLineItems;
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

		public string NAICS_SET_NAME
		{
			get
			{
				StringBuilder sb = new StringBuilder();
				if ( dtLineItems == null )
					dtLineItems = ViewState["LineItems"] as DataTable;
				if ( dtLineItems != null )
				{
					DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
					foreach ( DataRow row in aCurrentRows )
					{
						string sNAICS_CODE_NAME = Sql.ToString(row["NAICS_CODE_NAME"]);
						if ( !Sql.IsEmptyString(sNAICS_CODE_NAME) )
						{
							if ( sb.Length > 0 )
								sb.Append(",");
							sb.Append(sNAICS_CODE_NAME.ToString());
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
				string[] arrNAICS_CODES = value.Split(',');
				List<string> lstNew = new List<string>();
				foreach ( string sNAICS_CODE_NAME in arrNAICS_CODES )
				{
					try
					{
						if ( !Sql.IsEmptyString(sNAICS_CODE_NAME) )
						{
							if ( !lstNew.Contains(sNAICS_CODE_NAME) )
								lstNew.Add(sNAICS_CODE_NAME);
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
					string sNAICS_CODE_NAME = Sql.ToString(row["NAICS_CODE_NAME"]);
					if ( !lstNew.Contains(sNAICS_CODE_NAME) )
						row.Delete();
					else if ( !lstExisting.Contains(sNAICS_CODE_NAME) )
						lstExisting.Add(sNAICS_CODE_NAME);
				}
				foreach ( string sNAICS_CODE_NAME in lstNew )
				{
					if ( !lstExisting.Contains(sNAICS_CODE_NAME) )
					{
						if ( !Sql.IsEmptyString(sNAICS_CODE_NAME) )
						{
							DataRow rowNew = dtLineItems.NewRow();
							dtLineItems.Rows.Add(rowNew);
							rowNew["NAICS_CODE_ID"     ] = Guid.Empty;
							rowNew["NAICS_CODE_NAME"   ] = sNAICS_CODE_NAME;
						}
					}
				}
				DataRow rowBlank = dtLineItems.NewRow();
				dtLineItems.Rows.Add(rowBlank);
				ViewState["LineItems"] = dtLineItems;
			}
		}

		public void AddNAICSCode(Guid gNEW_NAICS_CODE_ID)
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
				Guid gNAICS_CODE_ID = Sql.ToGuid(row["NAICS_CODE_ID"]);
				if ( Sql.IsEmptyGuid(gNAICS_CODE_ID) )
					row.Delete();
				else if ( !lstExisting.Contains(gNAICS_CODE_ID) )
					lstExisting.Add(gNAICS_CODE_ID);
			}
			if ( !lstExisting.Contains(gNEW_NAICS_CODE_ID) )
			{
				string sNAICS_CODE_NAME = Crm.Modules.ItemName(HttpContext.Current.Application, "NAICSCodes", gNEW_NAICS_CODE_ID);
				if ( !Sql.IsEmptyString(sNAICS_CODE_NAME) )
				{
					DataRow rowNew = dtLineItems.NewRow();
					dtLineItems.Rows.Add(rowNew);
					rowNew["NAICS_CODE_ID"     ] = gNEW_NAICS_CODE_ID;
					rowNew["NAICS_CODE_NAME"   ] = sNAICS_CODE_NAME;
				}
			}
			DataRow rowBlank = dtLineItems.NewRow();
			dtLineItems.Rows.Add(rowBlank);
			ViewState["LineItems"] = dtLineItems;
			
			aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
			grdMain.DataSource = dtLineItems;
			grdMain.EditIndex = aCurrentRows.Length - 1;
			grdMain.DataBind();
		}

		public void RemoveNAICSCode(Guid gREMOVE_NAICS_CODE_ID)
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
				Guid gNAICS_CODE_ID = Sql.ToGuid(row["NAICS_CODE_ID"]);
				if ( Sql.IsEmptyGuid(gNAICS_CODE_ID) || gNAICS_CODE_ID == gREMOVE_NAICS_CODE_ID )
					row.Delete();
			}
			DataRow rowBlank = dtLineItems.NewRow();
			dtLineItems.Rows.Add(rowBlank);
			ViewState["LineItems"] = dtLineItems;
			
			aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
			grdMain.DataSource = dtLineItems;
			grdMain.EditIndex = aCurrentRows.Length - 1;
			grdMain.DataBind();
		}

		public bool ADD_NAICS_CODE_SET
		{
			get
			{
				return pnlAddReplace.Visible && radNaicsSetAdd.Checked;
			}
		}

		public void InitTable()
		{
			dtLineItems = new DataTable();
			DataColumn colNAICS_CODE_ID      = new DataColumn("NAICS_CODE_ID"     , Type.GetType("System.Guid"   ));
			DataColumn colNAICS_CODE_NAME    = new DataColumn("NAICS_CODE_NAME"   , Type.GetType("System.String" ));
			dtLineItems.Columns.Add(colNAICS_CODE_ID     );
			dtLineItems.Columns.Add(colNAICS_CODE_NAME   );
		}

		public void Clear()
		{
			InitTable();

			DataRow rowNew = dtLineItems.NewRow();
			dtLineItems.Rows.Add(rowNew);

			ViewState["LineItems"] = dtLineItems;
			grdMain.DataSource = dtLineItems;
			grdMain.EditIndex = dtLineItems.Rows.Count - 1;
			grdMain.DataBind();
		}

		public void Validate()
		{
			Validate(true);
		}

		public void Validate(bool bEnabled)
		{
			valNAICSCodeSelect.Enabled = bEnabled;
			valNAICSCodeSelect.Validate();
		}

		#region Line Item Editing
		protected void grdMain_RowCreated(object sender, GridViewRowEventArgs e)
		{
			if ( (e.Row.RowState & DataControlRowState.Edit) == DataControlRowState.Edit )
			{
				if ( bAjaxAutoComplete || Sql.ToBoolean(Page.Items["AjaxAutoComplete"]) )
				{
					// <ajaxToolkit:AutoCompleteExtender ID="autoNAICS_CODE_NAME" TargetControlID="NAICS_CODE_NAME" ServiceMethod="NAICS_CODES_NAICS_CODE_NAME_List" OnClientItemSelected="NAICS_CODES_NAICS_CODE_NAME_ItemSelected" ServicePath="~/Administration/NAICSCodes/AutoComplete.asmx" MinimumPrefixLength="2" CompletionInterval="250" EnableCaching="true" CompletionSetCount="12" runat="server" />
					AjaxControlToolkit.AutoCompleteExtender auto = new AjaxControlToolkit.AutoCompleteExtender();
					e.Row.Cells[0].Controls.Add(auto);
					auto.ID                   = "autoNAICS_CODE_NAME";
					auto.TargetControlID      = "NAICS_CODE_NAME";
					auto.ServiceMethod        = "NAICS_CODES_NAICS_CODE_NAME_List";
					auto.OnClientItemSelected = "NAICS_CODES_NAICS_CODE_NAME_ItemSelected";
					auto.ServicePath          = "~/Administration/NAICSCodes/AutoComplete.asmx";
					auto.MinimumPrefixLength  = 2;
					auto.CompletionInterval   = 250;
					auto.EnableCaching        = true;
					auto.CompletionSetCount   = Crm.Config.CompletionSetCount();
				}
			}
		}

		protected void grdMain_RowDataBound(object sender, GridViewRowEventArgs e)
		{
			if ( e.Row.RowType == DataControlRowType.DataRow )
			{
				if ( !(bSupportsPopups || Sql.ToBoolean(Page.Items["SupportsPopups"])) )
				{
					DropDownList lstNAICS_CODE_ID = e.Row.FindControl("lstNAICS_CODE_ID") as DropDownList;
					if ( lstNAICS_CODE_ID != null )
					{
						try
						{
							Utils.SetValue(lstNAICS_CODE_ID, Sql.ToGuid(DataBinder.Eval(e.Row.DataItem, "NAICS_CODE_ID")).ToString() );
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
				DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
				aCurrentRows[e.RowIndex].Delete();
				
				aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
				if ( aCurrentRows.Length == 0 || !Sql.IsEmptyString(aCurrentRows[aCurrentRows.Length-1]["NAICS_CODE_NAME"]) || !Sql.IsEmptyGuid(aCurrentRows[aCurrentRows.Length-1]["NAICS_CODE_ID"]) )
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
		}

		protected void grdMain_RowUpdating(object sender, GridViewUpdateEventArgs e)
		{
			if ( dtLineItems != null )
			{
				GridViewRow gr = grdMain.Rows[e.RowIndex];
				DropDownList       lstNAICS_CODE_ID      = gr.FindControl("lstNAICS_CODE_ID"          ) as DropDownList;
				HiddenField        txtNAICS_CODE_ID      = gr.FindControl("NAICS_CODE_ID"             ) as HiddenField;
				TextBox            txtNAICS_CODE_NAME    = gr.FindControl("NAICS_CODE_NAME"           ) as TextBox    ;
				HtmlGenericControl spnAjaxErrors   = gr.FindControl("NAICS_CODE_NAME_AjaxErrors") as HtmlGenericControl;
				Guid   gNAICS_CODE_ID   = Guid.Empty;
				string sNAICS_CODE_NAME = String.Empty;
				if ( !bSupportsPopups && lstNAICS_CODE_ID != null )
				{
					gNAICS_CODE_ID   = Sql.ToGuid(lstNAICS_CODE_ID.SelectedValue);
					sNAICS_CODE_NAME = Sql.ToString(lstNAICS_CODE_ID.SelectedItem.Text);
				}
				else
				{
					if ( txtNAICS_CODE_ID != null )
						gNAICS_CODE_ID = Sql.ToGuid(txtNAICS_CODE_ID.Value);
					if ( txtNAICS_CODE_NAME    != null ) 
						sNAICS_CODE_NAME = txtNAICS_CODE_NAME.Text;
				}

				if ( gNAICS_CODE_ID != Guid.Empty )
				{
					DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
					DataRow row = aCurrentRows[e.RowIndex];
					row["NAICS_CODE_ID"     ] = gNAICS_CODE_ID;
					row["NAICS_CODE_NAME"   ] = sNAICS_CODE_NAME;
					
					if ( aCurrentRows.Length == 0 || !Sql.IsEmptyString(aCurrentRows[aCurrentRows.Length-1]["NAICS_CODE_NAME"]) || !Sql.IsEmptyGuid(aCurrentRows[aCurrentRows.Length-1]["NAICS_CODE_ID"]) )
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
				else if ( spnAjaxErrors != null )
				{
					spnAjaxErrors.InnerHtml = "<br />" + L10n.Term("NAICSCodes.ERR_INVALID_NAICS_CODE");
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
				grdMain.EditIndex = aCurrentRows.Length - 1;
				grdMain.DataBind();
			}
		}
		#endregion

		public void LoadLineItems(Guid gNAICS_CODE_SET_ID, bool bAllowDefaults)
		{
			LoadLineItems(gNAICS_CODE_SET_ID, bAllowDefaults, false);
		}
	
		public void LoadLineItems(Guid gPARENT_ID, bool bAllowDefaults, bool bReload)
		{
			if ( this.IsMobile )
			{
				bSupportsPopups = Utils.SupportsPopups;
			}
			bool bIsPostBack = this.IsPostBack && !NotPostBack;
			if ( !bIsPostBack || bReload )
			{
				pnlAddReplace     .DataBind();
				radNaicsSetReplace.DataBind();
				radNaicsSetAdd    .DataBind();
				foreach ( DataControlField col in grdMain.Columns )
				{
					if ( !Sql.IsEmptyString(col.HeaderText) )
					{
						col.HeaderText = L10n.Term(col.HeaderText);
					}
					CommandField cf = col as CommandField;
					if ( cf != null )
					{
						cf.ShowEditButton   = bEnabled;
						cf.ShowDeleteButton = bEnabled;
					}
				}
				if ( (!Sql.IsEmptyGuid(gPARENT_ID)) )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						string sSQL;
						sSQL = "select *                     " + ControlChars.CrLf
						     + "  from vwNAICS_CODES_RELATED " + ControlChars.CrLf
						     + " where PARENT_ID = @PARENT_ID" + ControlChars.CrLf
						     + " order by NAICS_CODE_NAME asc" + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@PARENT_ID", gPARENT_ID);
							
							if ( bDebug )
								RegisterClientScriptBlock("vwNAICS_CODES_RELATED", Sql.ClientScriptBlock(cmd));
							
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								dtLineItems = new DataTable();
								da.Fill(dtLineItems);
								
								DataRow rowNew = dtLineItems.NewRow();
								dtLineItems.Rows.Add(rowNew);
								
								ViewState["LineItems"] = dtLineItems;
								grdMain.DataSource = dtLineItems;
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
					grdMain.EditIndex = dtLineItems.Rows.Count - 1;
					grdMain.DataBind();
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			valNAICSCodeSelect.ErrorMessage = L10n.Term(".ERR_REQUIRED_FIELD");
			if ( this.IsMobile )
			{
				bSupportsPopups = Utils.SupportsPopups;
			}
			bool bIsPostBack = this.IsPostBack && !NotPostBack;
			if ( bIsPostBack )
			{
				dtLineItems = ViewState["LineItems"] as DataTable;
				grdMain.DataSource = dtLineItems;
			}
			
			ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
			bAjaxAutoComplete = (mgrAjax != null);
			if ( this.IsMobile )
			{
				bAjaxAutoComplete = Utils.AllowAutoComplete && (mgrAjax != null);
			}
			if ( bAjaxAutoComplete )
			{
				Sql.AddServiceReference(mgrAjax, "~/Administration/NAICSCodes/AutoComplete.asmx");
				Sql.AddScriptReference (mgrAjax, "~/Administration/NAICSCodes/AutoComplete.js"  );
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
