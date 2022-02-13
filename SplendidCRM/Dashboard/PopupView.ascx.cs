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

namespace SplendidCRM.Dashboard
{
	/// <summary>
	///		Summary description for PopupView.
	/// </summary>
	public class PopupView : SplendidControl
	{
		protected _controls.SearchView     ctlSearchView    ;

		protected UniqueStringCollection arrSelectFields;
		protected Label         lblError       ;
		protected DataView      vwMain         ;
		protected DataView      vwHome         ;
		protected DataView      vwDashboard    ;
		protected SplendidGrid  grdMain        ;
		protected SplendidGrid  grdHome        ;
		protected SplendidGrid  grdDashboard   ;
		protected Panel         pnlMain        ;
		protected Panel         pnlHome        ;
		protected Panel         pnlDashboard   ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Search" )
				{
					grdMain.CurrentPageIndex = 0;
					grdMain.DataBind();
				}
				else if ( e.CommandName == "SortGrid" )
				{
					grdMain.SetSortFields(e.CommandArgument as string[]);
					arrSelectFields.AddFields(grdMain.SortColumn);
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
			SetPageTitle(L10n.Term(m_sMODULE + ".LBL_LIST_FORM_TITLE"));
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "list") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				pnlMain     .Visible = !Sql.ToString(Application["Modules.Home.RelativePath"]).ToLower().Contains("/html5");
				pnlHome     .Visible =  Sql.ToString(Application["Modules.Home.RelativePath"]).ToLower().Contains("/html5");
				pnlDashboard.Visible =  Sql.ToString(Application["Modules.Dashboard.RelativePath"]).ToLower().Contains("/html5");

				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						grdMain.OrderByClause("NAME", "asc");
						
						cmd.CommandText = "  from vwDASHBOARDS" + ControlChars.CrLf;
						Security.Filter(cmd, m_sMODULE, "list");
						// 06/19/2017 Paul.  We need to make sure not to only show the user-specific dashboards. 
						Sql.AppendParameter(cmd, Security.USER_ID, "ASSIGNED_USER_ID");
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
								DataRow row = dt.NewRow();
								row["ID"      ] = DBNull.Value;
								row["NAME"    ] = "Home.DetailView.Body";
								row["CATEGORY"] = DBNull.Value;
								dt.Rows.Add(row);
								row = dt.NewRow();
								row["ID"      ] = DBNull.Value;
								row["NAME"    ] = "Home.DetailView.Right";
								row["CATEGORY"] = DBNull.Value;
								dt.Rows.Add(row);
								vwMain = new DataView(dt);
								vwMain.RowFilter = "CATEGORY is null";
								grdMain.DataSource = vwMain;
								
								vwHome = new DataView(dt);
								vwHome.RowFilter = "CATEGORY = 'Home'";
								grdHome.DataSource = vwHome;
								vwDashboard = new DataView(dt);
								vwDashboard.RowFilter = "CATEGORY = 'Dashboard'";
								grdDashboard.DataSource = vwDashboard;
							}
						}
					}
				}
				if ( !IsPostBack )
				{
					grdMain.DataBind();
					grdHome.DataBind();
					grdDashboard.DataBind();
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
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);
			ctlSearchView    .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Dashboard";
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("ID"      );
			arrSelectFields.Add("NAME"    );
			arrSelectFields.Add("CATEGORY");
			this.AppendGridColumns(grdMain, m_sMODULE + ".PopupView", arrSelectFields);
		}
		#endregion
	}
}

