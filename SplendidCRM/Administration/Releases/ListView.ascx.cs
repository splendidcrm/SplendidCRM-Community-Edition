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

namespace SplendidCRM.Administration.Releases
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		// 06/05/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons ctlModuleHeader;
		protected _controls.SearchView   ctlSearchView  ;
		protected _controls.CheckAll     ctlCheckAll    ;

		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected Label         lblError       ;
		protected MassUpdate    ctlMassUpdate  ;
		// 06/06/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected Panel         pnlMassUpdateSeven;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Search" )
				{
					grdMain.CurrentPageIndex = 0;
					grdMain.DataBind();
				}
				// 11/17/2010 Paul.  Populate the hidden Selected field with all IDs. 
				else if ( e.CommandName == "SelectAll" )
				{
					ctlCheckAll.SelectAll(vwMain, "ID");
					grdMain.DataBind();
				}
				else if ( e.CommandName == "Releases.Delete" )
				{
					Guid gID = Sql.ToGuid(e.CommandArgument);
					SqlProcs.spRELEASES_Delete(gID);
					Response.Redirect("default.aspx");
				}
				// 06/06/2015 Paul.  Change standard MassUpdate command to a command to toggle visibility. 
				else if ( e.CommandName == "ToggleMassUpdate" )
				{
					pnlMassUpdateSeven.Visible = !pnlMassUpdateSeven.Visible;
				}
				else if ( e.CommandName == "MassUpdate" )
				{
					// 11/27/2010 Paul.  Use new selected items. 
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( arrID != null )
					{
						string sIDs = Utils.ValidateIDs(arrID);
						if ( !Sql.IsEmptyString(sIDs) )
						{
							SqlProcs.spRELEASES_MassUpdate(sIDs, ctlMassUpdate.STATUS);
							Response.Redirect("default.aspx");
						}
					}
				}
				else if ( e.CommandName == "MassDelete" )
				{
					// 11/27/2010 Paul.  Use new selected items. 
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( arrID != null )
					{
						string sIDs = Utils.ValidateIDs(arrID);
						if ( !Sql.IsEmptyString(sIDs) )
						{
							SqlProcs.spRELEASES_MassDelete(sIDs);
							Response.Redirect("default.aspx");
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

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term("Releases.LBL_LIST_FORM_TITLE"));
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
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					sSQL = "select *              " + ControlChars.CrLf
					     + "  from vwRELEASES_List" + ControlChars.CrLf
					     + " where 1 = 1          " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						grdMain.OrderByClause("LIST_ORDER", "asc");
						cmd.CommandText = sSQL;
						ctlSearchView.SqlSearchClause(cmd);
						cmd.CommandText += grdMain.OrderByClause();

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
							}
						}
					}
				}
				if ( !IsPostBack )
				{
					grdMain.DataBind();
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
			if ( !IsPostBack )
			{
				// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
				//Page.DataBind();
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
			ctlSearchView.Command += new CommandEventHandler(Page_Command);
			ctlMassUpdate.Command += new CommandEventHandler(Page_Command);
			ctlCheckAll  .Command += new CommandEventHandler(Page_Command);
			// 11/26/2005 Paul.  Add fields early so that sort events will get called. 
			m_sMODULE = "Releases";
			SetMenu(m_sMODULE);
			this.AppendGridColumns(grdMain, m_sMODULE + "." + LayoutListView);
			
			// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
			if ( SplendidDynamic.StackedLayout(Page.Theme) )
			{
				ctlModuleHeader.Command += new CommandEventHandler(Page_Command);
				ctlModuleHeader.AppendButtons(m_sMODULE + "." + LayoutListView, Guid.Empty, null);
				// 06/05/2015 Paul.  Move MassUpdate buttons to the SplendidGrid. 
				grdMain.IsMobile       = this.IsMobile;
				grdMain.MassUpdateView = m_sMODULE + ".MassUpdate";
				grdMain.Command       += new CommandEventHandler(Page_Command);
				if ( !IsPostBack )
					pnlMassUpdateSeven.Visible = false;
			}
		}
		#endregion
	}
}

