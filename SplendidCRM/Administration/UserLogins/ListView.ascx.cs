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

namespace SplendidCRM.Administration.UserLogins
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		protected _controls.ExportHeader ctlExportHeader;
		protected _controls.SearchView   ctlSearchView  ;
		protected _controls.CheckAll     ctlCheckAll    ;

		protected UniqueStringCollection arrSelectFields;
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected Label         lblError       ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
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
				// 07/11/2018 Paul.  Populate the hidden Selected field with all IDs. 
				else if ( e.CommandName == "SelectAll" )
				{
					// 05/22/2011 Paul.  When using custom paging, vwMain may not be defined. 
					if ( vwMain == null )
						grdMain.DataBind();
					ctlCheckAll.SelectAll(vwMain, "ID");
					grdMain.DataBind();
				}
				else if ( e.CommandName == "Export" )
				{
					// 11/03/2006 Paul.  Apply ACL rules to Export. 
					int nACLACCESS = SplendidCRM.Security.AdminUserAccess(m_sMODULE, "export");
					if ( nACLACCESS  >= 0 )
					{
						// 06/13/2018 Paul.  When exporting, we may need to manually bind.  Custom paging should be disabled when exporting all. 
						if ( vwMain == null )
							grdMain.DataBind();
						// 06/13/2018 Paul.  If there is still no view, then there was an error in the select. 
						if ( vwMain != null )
						{
							// 07/11/2018 Paul.  Use new selected items. 
							string[] arrID = ctlCheckAll.SelectedItemsArray;
							SplendidExport.Export(vwMain, m_sMODULE, ctlExportHeader.ExportFormat, ctlExportHeader.ExportRange, grdMain.CurrentPageIndex, grdMain.PageSize, arrID, grdMain.AllowCustomPaging);
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
			SetPageTitle(L10n.Term("Users.LBL_LIST_FORM_TITLE"));
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
				// 07/11/2018 Paul.  Hide the checkbox column on a mobile browser. 
				if ( this.IsMobile && grdMain.Columns.Count > 0 )
					grdMain.Columns[0].Visible = false;
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					// 02/08/2008 Paul.  We need to build a list of the fields used by the search clause. 
					sSQL = "  from vwUSERS_LOGINS" + ControlChars.CrLf
					     + " where 1 = 1         " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						// 04/27/2008 Paul.  A ListView will need to set and build the order clause in two setps 
						// so that the SavedSearch sort value can be taken into account. 
						grdMain.OrderByClause("DATE_MODIFIED", "desc");
						ctlSearchView.SqlSearchClause(cmd);
						// 04/20/2008 Paul.  The Saved Search may contain a sort column that has not been included in the select fields. 
						// The safe solution is to prepend it to the top of the select clause as this code will not run often.  Most people will sort on a displayed field. 
						// 04/27/2008 Paul.  The fields in the search clause need to be prepended after any Saved Search sort has been determined.
						// 04/20/2011 Paul.  If there are no fields in the GridView.Export, then return all fields (*). 
						// 09/23/2015 Paul.  Need to include the data grid fields as it will be bound using the same data set. 
						cmd.CommandText = "select " + (Request.Form[ctlExportHeader.ExportUniqueID] != null ? SplendidDynamic.ExportGridColumns(m_sMODULE + ".Export", arrSelectFields) : Sql.FormatSelectFields(arrSelectFields)) 
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
								if ( !IsPostBack )
								{
									// 12/14/2007 Paul.  Only set the default sort if it is not already set.  It may have been set by SearchView. 
									// 04/27/2008 Paul.  Sorting has been moved to the database to increase performance. 
									grdMain.DataBind();
								}
							}
						}
						// 07/11/2018 Paul.  Change standard MassUpdate command to a command to toggle visibility. 
						ctlCheckAll  .Visible = ctlExportHeader.Visible && !PrintView && SplendidCRM.Crm.Modules.MassUpdate(m_sMODULE);
					}
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
			ctlSearchView  .Command += new CommandEventHandler(Page_Command);
			ctlExportHeader.Command += new CommandEventHandler(Page_Command);
			// 07/11/2018 Paul.  Add export checkboxes. 
			ctlCheckAll    .Command += new CommandEventHandler(Page_Command);
			// 11/26/2005 Paul.  Add fields early so that sort events will get called. 
			m_sMODULE = "UserLogins";
			SetMenu("Users");
			// 02/08/2008 Paul.  We need to build a list of the fields used by the search clause. 
			arrSelectFields = new UniqueStringCollection();
			// 07/11/2018 Paul.  ID is required for export. 
			arrSelectFields.Add("ID"       );
			arrSelectFields.Add("FULL_NAME");
			// 02/21/2008 Paul.  IS_ADMIN is used in the grid. 
			arrSelectFields.Add("IS_ADMIN");
			arrSelectFields.Add("DATE_MODIFIED");
			this.AppendGridColumns(grdMain, "Users.LoginView", arrSelectFields);
			// 07/11/2018 Paul.  Combine ModuleHeader and DynamicButtons. 
			if ( SplendidDynamic.StackedLayout(Page.Theme) )
			{
				// 06/05/2015 Paul.  Move MassUpdate buttons to the SplendidGrid. 
				grdMain.IsMobile       = this.IsMobile;
				grdMain.MassUpdateView = m_sMODULE + ".MassUpdate";
				grdMain.Command       += new CommandEventHandler(Page_Command);
			}
		}
		#endregion
	}
}

