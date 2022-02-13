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
	///		Summary description for PopupView.
	/// </summary>
	public class PopupView : SplendidControl
	{
		protected _controls.SearchView     ctlSearchView    ;
		protected _controls.DynamicButtons ctlDynamicButtons;
		protected _controls.CheckAll       ctlCheckAll      ;

		protected UniqueStringCollection arrSelectFields;
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected bool          bMultiSelect   ;
		// 02/21/2010 Paul.  Controls to manage inline create. 
		protected Button        btnCreateInline   ;
		protected Panel         pnlNewRecordInline;
		protected NewRecord     ctlNewRecord      ;

		public bool MultiSelect
		{
			get { return bMultiSelect; }
			set { bMultiSelect = value; }
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Search" || e.CommandName == "Save" )
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
				// 11/17/2010 Paul.  Populate the hidden Selected field with all IDs. 
				else if ( e.CommandName == "SelectAll" )
				{
					ctlCheckAll.SelectAll(vwMain, "ID");
					grdMain.DataBind();
				}
				// 02/21/2010 Paul.  Handle new events that hide and show the NewRecord panel. 
				else if ( e.CommandName == "NewRecord.Show" )
				{
					btnCreateInline   .Visible = false;
					pnlNewRecordInline.Style.Add(HtmlTextWriterStyle.Display, "inline");
				}
				else if ( e.CommandName == "NewRecord.Cancel" )
				{
					btnCreateInline   .Visible = true;
					pnlNewRecordInline.Style.Add(HtmlTextWriterStyle.Display, "none");
				}
				else if ( e.CommandName == "NewRecord" )
				{
					// 08/03/2010 Paul.  After creating the record, automatically select it. 
					ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
					if ( mgrAjax != null )
					{
						Guid   gID   = Sql.ToGuid(e.CommandArgument);
						string sNAME = Crm.Modules.ItemName(Application, m_sMODULE, gID);
						// 08/17/2012 Paul.  Terminate the javascript line. 
						ScriptManager.RegisterStartupScript(this.Page, this.Page.GetType(), "NewRecord", "SelectRelease('" + gID.ToString() + "', '" + Sql.EscapeJavaScript(sNAME) + "');", true);
					}
					else
					{
						// 02/21/2010 Paul.  Redirect instead of rebind so that the entire page gets reset. 
						Response.Redirect(Request.RawUrl);
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(m_sMODULE + ".LBL_LIST_FORM_TITLE"));
			// 06/30/2009 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "list") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						grdMain.OrderByClause("LIST_ORDER", "asc");
						
						string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
						cmd.CommandText = "  from vw" + sTABLE_NAME + "_List" + ControlChars.CrLf;
						Security.Filter(cmd, m_sMODULE, "list");
						ctlSearchView.SqlSearchClause(cmd);
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
								// 11/06/2012 Paul.  Apply Business Rules to PopupView. 
								this.ApplyGridViewRules(m_sMODULE + "." + LayoutListView, dt);
							
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
							}
						}
					}
				}
				if ( !IsPostBack )
				{
					// 03/11/2008 Paul.  Move the primary binding to SplendidPage. 
					//Page DataBind();
					// 09/08/2009 Paul.  Let the grid handle the differences between normal and custom paging. 
					// 09/08/2009 Paul.  Bind outside of the existing connection so that a second connect would not get created. 
					grdMain.DataBind();
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
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
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			ctlSearchView    .Command += new CommandEventHandler(Page_Command);
			ctlNewRecord     .Command += new CommandEventHandler(Page_Command);
			ctlCheckAll      .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Releases";
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("ID"  );
			arrSelectFields.Add("NAME");
			this.AppendGridColumns(grdMain, m_sMODULE + ".PopupView", arrSelectFields);
			ctlDynamicButtons.AppendButtons(m_sMODULE + ".Popup" + (bMultiSelect ? "MultiSelect" : "View"), Guid.Empty, Guid.Empty);
			if ( !IsPostBack && !bMultiSelect )
				ctlDynamicButtons.ShowButton("Clear", !Sql.ToBoolean(Request["ClearDisabled"]));
		}
		#endregion
	}
}

