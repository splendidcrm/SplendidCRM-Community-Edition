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

namespace SplendidCRM.Administration.Shortcuts
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		// 06/05/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons ctlModuleHeader;
		protected _controls.SearchView   ctlSearchView  ;

		protected UniqueStringCollection arrSelectFields;
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected Label         lblError       ;
		protected string        sMODULE_NAME   ;
		protected HiddenField   txtINDEX       ;
		protected Button        btnINDEX_MOVE  ;

		protected void grdMain_ItemCreated(object sender, DataGridItemEventArgs e)
		{
			if ( e.Item.ItemType == ListItemType.Header || e.Item.ItemType == ListItemType.Footer )
			{
				e.Item.CssClass += " nodrag nodrop";
			}
		}

		protected void txtINDEX_ValueChanged(object sender, EventArgs e)
		{
			try
			{
				DropDownList lst = ctlSearchView.FindControl("MODULE_NAME") as DropDownList;
				string[] arrValueChanged = txtINDEX.Value.Split(',');
				if ( arrValueChanged.Length < 2 )
					throw(new Exception("Invalid changed values: " + txtINDEX.Value));
				
				txtINDEX.Value = String.Empty;
				int nOLD_VALUE = Sql.ToInteger(arrValueChanged[0]);
				int nNEW_VALUE = Sql.ToInteger(arrValueChanged[1]);
				if ( nOLD_VALUE < 0 )
					throw(new Exception("OldIndex cannot be negative."));
				if ( nNEW_VALUE < 0 )
					throw(new Exception("NewIndex cannot be negative."));
				if ( nOLD_VALUE >= vwMain.Count )
					throw(new Exception("OldIndex cannot exceed " + vwMain.Count.ToString()));
				if ( nNEW_VALUE >= vwMain.Count )
					throw(new Exception("NewIndex cannot exceed " + vwMain.Count.ToString()));
				
				int nOLD_INDEX = Sql.ToInteger(vwMain[nOLD_VALUE]["SHORTCUT_ORDER"]);
				int nNEW_INDEX = Sql.ToInteger(vwMain[nNEW_VALUE]["SHORTCUT_ORDER"]);
				SqlProcs.spSHORTCUTS_ORDER_MoveItem(lst.SelectedValue, nOLD_INDEX, nNEW_INDEX);
				SplendidCache.ClearShortcuts(lst.SelectedValue);
				BindGrid(true);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
#if DEBUG
				lblError.Text += ex.StackTrace;
#endif
			}
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				DropDownList lst = ctlSearchView.FindControl("MODULE_NAME") as DropDownList;
				if ( e.CommandName == "Search" )
				{
					// 10/13/2005 Paul.  Make sure to clear the page index prior to applying search. 
					grdMain.CurrentPageIndex = 0;
					// 04/27/2008 Paul.  Sorting has been moved to the database to increase performance. 
					grdMain.DataBind();
				}
				// 12/14/2007 Paul.  We need to capture the sort event from the SearchView. 
				else if ( e.CommandName == "SortGrid" )
				{
					grdMain.SetSortFields(e.CommandArgument as string[]);
					// 04/27/2008 Paul.  Sorting has been moved to the database to increase performance. 
					// 03/17/2011 Paul.  We need to treat a comma-separated list of fields as an array. 
					arrSelectFields.AddFields(grdMain.SortColumn);
				}
				else if ( e.CommandName == "Shortcuts.Delete" )
				{
					Guid gID = Sql.ToGuid(e.CommandArgument);
					SqlProcs.spSHORTCUTS_Delete(gID);
					SplendidCache.ClearShortcuts(lst.SelectedValue);
					//Response.Redirect("default.aspx");
					// 05/22/2008 Paul.  Use AJAX and rebind after move operation. 
					BindGrid(true);
				}
				else if ( e.CommandName == "Shortcuts.Edit" )
				{
					Guid gID = Sql.ToGuid(e.CommandArgument);
					Response.Redirect("edit.aspx?ID=" + gID.ToString());
				}
				else if ( lst != null )
				{
					Guid gID = Sql.ToGuid(e.CommandArgument);
					if ( e.CommandName == "Shortcuts.MoveUp" )
					{
						SqlProcs.spSHORTCUTS_ORDER_MoveUp(gID);
						SplendidCache.ClearShortcuts(lst.SelectedValue);
						//Response.Redirect("default.aspx");
						// 05/22/2008 Paul.  Use AJAX and rebind after move operation. 
						BindGrid(true);
					}
					else if ( e.CommandName == "Shortcuts.MoveDown" )
					{
						SqlProcs.spSHORTCUTS_ORDER_MoveDown(gID);
						SplendidCache.ClearShortcuts(lst.SelectedValue);
						//Response.Redirect("default.aspx");
						// 05/22/2008 Paul.  Use AJAX and rebind after move operation. 
						BindGrid(true);
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		protected void MODULE_NAME_Changed(object sender, System.EventArgs e)
		{
			grdMain.DataBind();
		}

		protected void BindGrid(bool bBind)
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				sSQL = "  from vwSHORTCUTS_Edit" + ControlChars.CrLf
				     + " where 1 = 1           " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					// 04/27/2008 Paul.  A ListView will need to set and build the order clause in two setps 
					// so that the SavedSearch sort value can be taken into account. 
					grdMain.OrderByClause("SHORTCUT_ORDER", "asc");
					ctlSearchView.SqlSearchClause(cmd);
					// 04/27/2008 Paul.  The fields in the search clause need to be prepended after any Saved Search sort has been determined.
					cmd.CommandText = "select " + Sql.FormatSelectFields(arrSelectFields) 
					                + cmd.CommandText
					                + grdMain.OrderByClause();

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
							if ( bBind )
							{
								grdMain.DataBind();
							}
						}
					}
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(m_sMODULE + ".LBL_LIST_FORM_TITLE"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "list") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			try
			{
				// 07/25/2010 Paul.  Lets experiment with jQuery drag and drop. 
				ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
				// 08/25/2013 Paul.  jQuery now registered in the master pages. 
				//ScriptReference  scrJQuery         = new ScriptReference ("~/Include/javascript/jquery-1.4.2.min.js"   );
				ScriptReference  scrJQueryTableDnD = new ScriptReference ("~/Include/javascript/jquery.tablednd_0_5.js");
				//if ( !mgrAjax.Scripts.Contains(scrJQuery) )
				//	mgrAjax.Scripts.Add(scrJQuery);
				if ( !mgrAjax.Scripts.Contains(scrJQueryTableDnD) )
					mgrAjax.Scripts.Add(scrJQueryTableDnD);

				BindGrid(!IsPostBack);
				DropDownList MODULE_NAME = ctlSearchView.FindControl("MODULE_NAME") as DropDownList;
				if ( !IsPostBack )
				{
					// 12/13/2007 Paul.  Manually enable AutoPostBack. 
					if ( MODULE_NAME != null )
					{
						MODULE_NAME.AutoPostBack = true;
						MODULE_NAME.SelectedIndexChanged += new EventHandler(MODULE_NAME_Changed);
					}
					// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
					//Page.DataBind();
				}
				// 10/02/2013 Paul.  Always get the current module name. 
				if ( MODULE_NAME != null )
					sMODULE_NAME = MODULE_NAME.SelectedValue;
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
			ctlSearchView.Command      += new CommandEventHandler(Page_Command);
			grdMain      .ItemCreated  += new DataGridItemEventHandler(grdMain_ItemCreated);
			txtINDEX     .ValueChanged += new EventHandler(txtINDEX_ValueChanged);
			// 11/24/2005 Paul.  Add fields early so that sort events will get called. 
			m_sMODULE = "Shortcuts";
			SetMenu(m_sMODULE);
			// 04/27/2008 Paul.  We need to build a list of the fields used by the search clause. 
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("ID"             );
			arrSelectFields.Add("MODULE_NAME"   );
			arrSelectFields.Add("DISPLAY_NAME"  );
			arrSelectFields.Add("RELATIVE_PATH" );
			arrSelectFields.Add("SHORTCUT_ORDER");
			if ( IsPostBack )
			{
				DropDownList MODULE_NAME = ctlSearchView.FindControl("MODULE_NAME") as DropDownList;
				if ( MODULE_NAME != null )
				{
					sMODULE_NAME = MODULE_NAME.SelectedValue;
					MODULE_NAME.AutoPostBack = true;
					MODULE_NAME.SelectedIndexChanged += new EventHandler(MODULE_NAME_Changed);
				}
			}
			
			// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
			if ( SplendidDynamic.StackedLayout(Page.Theme) )
			{
				ctlModuleHeader.Command += new CommandEventHandler(Page_Command);
				ctlModuleHeader.AppendButtons(m_sMODULE + "." + LayoutListView, Guid.Empty, null);
			}
		}
		#endregion
	}
}

