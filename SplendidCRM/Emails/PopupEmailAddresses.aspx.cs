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

namespace SplendidCRM.Emails
{
	/// <summary>
	/// Summary description for PopupEmailAddresses.
	/// </summary>
	public class PopupEmailAddresses : SplendidPopup
	{
		protected _controls.SearchView     ctlSearchView    ;
		protected _controls.DynamicButtons ctlDynamicButtons;

		protected UniqueStringCollection arrSelectFields;
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;

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
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term("Contacts.LBL_LIST_FORM_TITLE"));
			// 09/13/2011 Paul.  Make sure to catch database connection issues. 
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dtCombined = new DataTable() )
							{
								// 02/08/2008 Paul.  We need to build a list of the fields used by the search clause. 
								arrSelectFields = new UniqueStringCollection();
								arrSelectFields.Add("ID");
								arrSelectFields.Add("NAME");
								arrSelectFields.Add("EMAIL1");
								// 10/13/2011 Paul.  Allow EMAIL2 to be selected. 
								arrSelectFields.Add("EMAIL2");
								// 05/08/2008 Paul.  ADDRESS_TYPE should not be added to the list as it will be manually added to the select statement. 
								//arrSelectFields.Add("ADDRESS_TYPE");
								arrSelectFields.Add("ACCOUNT_NAME");

								// 12/19/2006 Paul.  As much as we would like to combine the threee separate queries into 
								// a single query using a union, we cannot because the Security.Filter rules must be applied separately. 
								// We simply combine three DataTables as quickly and efficiently as possible. 
								// 02/08/2008 Paul.  We need to build a list of the fields used by the search clause. 
								cmd.CommandText = "     , N'Contacts'  as ADDRESS_TYPE" + ControlChars.CrLf
								                + "  from vwCONTACTS_EmailList        " + ControlChars.CrLf;
								Security.Filter(cmd, "Contacts", "list");
								// 04/27/2008 Paul.  A ListView will need to set and build the order clause in two setps 
								// so that the SavedSearch sort value can be taken into account. 
								grdMain.OrderByClause("NAME", "asc");
								ctlSearchView.SqlSearchClause(cmd);
								// 04/27/2008 Paul.  The fields in the search clause need to be prepended after any Saved Search sort has been determined.
								cmd.CommandText = "select " + Sql.FormatSelectFields(arrSelectFields)
								                + cmd.CommandText
								                + grdMain.OrderByClause();
								
								if ( bDebug )
									Page.ClientScript.RegisterClientScriptBlock(System.Type.GetType("System.String"), "vwCONTACTS_EmailList", Sql.ClientScriptBlock(cmd));
								da.Fill(dtCombined);
								
								cmd.Parameters.Clear();
								// 02/08/2008 Paul.  We need to build a list of the fields used by the search clause. 
								cmd.CommandText = "     , N'Leads'     as ADDRESS_TYPE" + ControlChars.CrLf
								                + "  from vwLEADS_EmailList           " + ControlChars.CrLf;
								Security.Filter(cmd, "Leads", "list");
								ctlSearchView.SqlSearchClause(cmd);
								// 04/27/2008 Paul.  The fields in the search clause need to be prepended after any Saved Search sort has been determined.
								cmd.CommandText = "select " + Sql.FormatSelectFields(arrSelectFields)
								                + cmd.CommandText
								                + grdMain.OrderByClause();
								
								if ( bDebug )
									Page.ClientScript.RegisterClientScriptBlock(System.Type.GetType("System.String"), "vwLEADS_EmailList", Sql.ClientScriptBlock(cmd));
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									foreach ( DataRow row in dt.Rows)
									{
										DataRow rowNew = dtCombined.NewRow();
										//rowNew.ItemArray = row.ItemArray;
										// 12/19/2006 Paul.  Using the ItemArray would certainly be faster,
										// but someone may accidentally modify one of the columns of the three views, 
										// so we shall be safe and check each column before setting its value. 
										foreach ( DataColumn col in dt.Columns )
										{
											if ( dtCombined.Columns.Contains(col.ColumnName) )
											{
												rowNew[col.ColumnName] = row[col.ColumnName];
											}
										}
										dtCombined.Rows.Add(rowNew);
									}
								}
								
								cmd.Parameters.Clear();
								// 02/08/2008 Paul.  We need to build a list of the fields used by the search clause. 
								cmd.CommandText = "     , N'Prospects' as ADDRESS_TYPE" + ControlChars.CrLf
								                + "  from vwPROSPECTS_EmailList       " + ControlChars.CrLf;
								Security.Filter(cmd, "Prospects", "list");
								ctlSearchView.SqlSearchClause(cmd);
								// 04/27/2008 Paul.  The fields in the search clause need to be prepended after any Saved Search sort has been determined.
								cmd.CommandText = "select " + Sql.FormatSelectFields(arrSelectFields)
								                + cmd.CommandText
								                + grdMain.OrderByClause();
								
								if ( bDebug )
									Page.ClientScript.RegisterClientScriptBlock(System.Type.GetType("System.String"), "vwPROSPECTS_EmailList", Sql.ClientScriptBlock(cmd));
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									foreach ( DataRow row in dt.Rows)
									{
										DataRow rowNew = dtCombined.NewRow();
										//rowNew.ItemArray = row.ItemArray;
										// 12/19/2006 Paul.  Using the ItemArray would certainly be faster,
										// but someone may accidentally modify one of the columns of the three views, 
										// so we shall be safe and check each column before setting its value. 
										foreach ( DataColumn col in dt.Columns )
										{
											if ( dtCombined.Columns.Contains(col.ColumnName) )
											{
												rowNew[col.ColumnName] = row[col.ColumnName];
											}
										}
										dtCombined.Rows.Add(rowNew);
									}
								}
								
								cmd.Parameters.Clear();
								// 10/27/2017 Paul.  Add Accounts as email source. 
								cmd.CommandText = "     , N'Accounts' as ADDRESS_TYPE" + ControlChars.CrLf
								                + "  from vwACCOUNTS_EmailList       " + ControlChars.CrLf;
								Security.Filter(cmd, "Accounts", "list");
								ctlSearchView.SqlSearchClause(cmd);
								cmd.CommandText = "select " + Sql.FormatSelectFields(arrSelectFields)
								                + cmd.CommandText
								                + grdMain.OrderByClause();
								
								if ( bDebug )
									Page.ClientScript.RegisterClientScriptBlock(System.Type.GetType("System.String"), "vwPROSPECTS_EmailList", Sql.ClientScriptBlock(cmd));
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									foreach ( DataRow row in dt.Rows)
									{
										DataRow rowNew = dtCombined.NewRow();
										foreach ( DataColumn col in dt.Columns )
										{
											if ( dtCombined.Columns.Contains(col.ColumnName) )
											{
												rowNew[col.ColumnName] = row[col.ColumnName];
											}
										}
										dtCombined.Rows.Add(rowNew);
									}
								}
								
								vwMain = dtCombined.DefaultView;
								grdMain.DataSource = vwMain ;
								if ( !IsPostBack )
								{
									// 12/14/2007 Paul.  Only set the default sort if it is not already set.  It may have been set by SearchView. 
									// 04/27/2008 Paul.  Sorting has been moved to the database to increase performance. 
									grdMain.DataBind();
								}
							}
						}
					}
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
			ctlSearchView.Command += new CommandEventHandler(Page_Command);
			// 04/28/2008 Paul.  Make use of dynamic buttons. 
			ctlDynamicButtons.AppendButtons("Emails.PopupEmailAddresses", Guid.Empty, Guid.Empty);
			if ( !IsPostBack )
				ctlDynamicButtons.ShowButton("Clear", !Sql.ToBoolean(Request["ClearDisabled"]));
		}
		#endregion
	}
}

