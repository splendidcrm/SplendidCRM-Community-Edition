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

namespace SplendidCRM.Administration.DynamicButtons
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		// 06/05/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons ctlModuleHeader;
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected Label         lblError       ;
		protected DropDownList  lstVIEW_NAME   ;
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
				
				int nOLD_INDEX = Sql.ToInteger(vwMain[nOLD_VALUE]["CONTROL_INDEX"]);
				int nNEW_INDEX = Sql.ToInteger(vwMain[nNEW_VALUE]["CONTROL_INDEX"]);
				SqlProcs.spDYNAMIC_BUTTONS_ORDER_MoveItem(lstVIEW_NAME.SelectedValue, nOLD_INDEX, nNEW_INDEX);
				SplendidCache.ClearDynamicButtons(lstVIEW_NAME.SelectedValue);
				Bind(true);
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
				if ( e.CommandName == "Search" )
				{
					// 10/13/2005 Paul.  Make sure to clear the page index prior to applying search. 
					grdMain.CurrentPageIndex = 0;
					grdMain.ApplySort();
					Bind(true);
				}
				// 12/14/2007 Paul.  We need to capture the sort event from the SearchView. 
				else if ( e.CommandName == "SortGrid" )
				{
					grdMain.SetSortFields(e.CommandArgument as string[]);
				}
				else if ( e.CommandName == "DynamicButtons.Delete" )
				{
					Guid gID = Sql.ToGuid(e.CommandArgument);
					SqlProcs.spDYNAMIC_BUTTONS_Delete(gID);
					SplendidCache.ClearDynamicButtons(lstVIEW_NAME.SelectedValue);
					Bind(true);
				}
				else if ( e.CommandName == "DynamicButtons.Edit" )
				{
					Guid gID = Sql.ToGuid(e.CommandArgument);
					Response.Redirect("edit.aspx?ID=" + gID.ToString());
				}
				else if ( e.CommandName == "DynamicButtons.MoveUp" )
				{
					Guid gID = Sql.ToGuid(e.CommandArgument);
					SqlProcs.spDYNAMIC_BUTTONS_ORDER_MoveUp(gID);
					SplendidCache.ClearDynamicButtons(lstVIEW_NAME.SelectedValue);
					Bind(true);
				}
				else if ( e.CommandName == "DynamicButtons.MoveDown" )
				{
					Guid gID = Sql.ToGuid(e.CommandArgument);
					SqlProcs.spDYNAMIC_BUTTONS_ORDER_MoveDown(gID);
					SplendidCache.ClearDynamicButtons(lstVIEW_NAME.SelectedValue);
					Bind(true);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void Bind(bool bBind)
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				sSQL = "select *                     " + ControlChars.CrLf
				     + "  from vwDYNAMIC_BUTTONS_Edit" + ControlChars.CrLf
				     + " where 1 = 1                 " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AppendParameter(cmd, lstVIEW_NAME.SelectedValue, "VIEW_NAME");
					cmd.CommandText += " order by VIEW_NAME asc, CONTROL_INDEX asc" + ControlChars.CrLf;

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

				if ( !IsPostBack )
				{
					// 04/03/2019 Paul.  DynamicButtonViews so that it can be returned by REST API. 
					lstVIEW_NAME.DataSource = SplendidCache.DynamicButtonViews();
					lstVIEW_NAME.DataBind();
					lstVIEW_NAME.Focus();
					Bind(true);
				}
				else
				{
					Bind(false);
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
			grdMain.ItemCreated += new DataGridItemEventHandler(grdMain_ItemCreated);
			txtINDEX.ValueChanged += new EventHandler(txtINDEX_ValueChanged);
			m_sMODULE = "DynamicButtons";
			SetMenu(m_sMODULE);
			
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

