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

namespace SplendidCRM.Administration.FullTextSearch
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		protected _controls.SearchButtons ctlSearchButtons;
		protected ListBox       lstTABLES      ;
		protected TextBox       txtSEARCH_TEXT ;
		
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected Label         lblError       ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Search" )
				{
					grdMain.CurrentPageIndex = 0;
					grdMain.ApplySort();
					grdMain.DataBind();
				}
				else if ( e.CommandName == "FullTextSearch.Delete" )
				{
					Response.Redirect("default.aspx");
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
			SetPageTitle(L10n.Term("FullTextSearch.LBL_LIST_FORM_TITLE"));
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "list") >= 0);
			if ( !this.Visible )
			{
				Parent.DataBind();
				return;
			}

			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					if ( Sql.IsSQLServer(con) )
					{
						string sSQL;
						int nFullTextCatalogID = 0;
						sSQL = "select fulltext_catalog_id         " + ControlChars.CrLf
						     + "  from sys.fulltext_catalogs       " + ControlChars.CrLf
						     + " where name = db_name() + 'Catalog'" + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							nFullTextCatalogID = Sql.ToInteger(cmd.ExecuteScalar());
						}
						if ( !IsPostBack )
						{
							sSQL = "select object_name(object_id) as TABLE_NAME      " + ControlChars.CrLf
							     + "  from sys.fulltext_indexes                      " + ControlChars.CrLf
							     + " where fulltext_catalog_id = @fulltext_catalog_id" + ControlChars.CrLf
							     + " order by TABLE_NAME                             " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@fulltext_catalog_id", nFullTextCatalogID);
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dt = new DataTable() )
									{
										da.Fill(dt);
										foreach ( DataRow row in dt.Rows )
										{
											lstTABLES.Items.Add(Sql.ToString(row["TABLE_NAME"]));
										}
									}
								}
							}
						}
						if ( IsPostBack )
						{
							if ( !Sql.IsEmptyString(lstTABLES.SelectedValue) && !Sql.IsEmptyString(txtSEARCH_TEXT.Text) )
							{
								string sTABLE_NAME  = lstTABLES.SelectedValue;
								string sCOLUMN_NAME = String.Empty;
								string sSEARCH_TEXT = txtSEARCH_TEXT.Text;
								sSQL = "select col_name(columns.object_id, columns.column_id) as COLUMN_NAME" + ControlChars.CrLf
								     + "  from      sys.fulltext_index_columns columns                      " + ControlChars.CrLf
								     + " inner join sys.fulltext_indexes       indexes                      " + ControlChars.CrLf
								     + "         on indexes.object_id        = columns.object_id            " + ControlChars.CrLf
								     + " where object_name(indexes.object_id) = @TABLE_NAME                 " + ControlChars.CrLf
								     + "   and indexes.fulltext_catalog_id    = @fulltext_catalog_id        " + ControlChars.CrLf
								     + " order by COLUMN_NAME                                               " + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@TABLE_NAME"         , sTABLE_NAME       );
									Sql.AddParameter(cmd, "@fulltext_catalog_id", nFullTextCatalogID);
									sCOLUMN_NAME = Sql.ToString(cmd.ExecuteScalar());
								}
								if ( !Sql.IsEmptyString(sCOLUMN_NAME) && (sTABLE_NAME == "DOCUMENT_REVISIONS" || sTABLE_NAME == "NOTE_ATTACHMENTS") )
								{
									if ( sTABLE_NAME == "DOCUMENT_REVISIONS" )
									{
										sSQL = "select DOCUMENT_ID  as ID         " + ControlChars.CrLf
										     + "     , FILENAME     as NAME       " + ControlChars.CrLf
										     + "     , 'Documents'  as MODULE_NAME" + ControlChars.CrLf
										     + "  from " + sTABLE_NAME          + ControlChars.CrLf
										     + " where contains(" + sCOLUMN_NAME + ", @SEARCH_TEXT)" + ControlChars.CrLf
										     + " order by DATE_ENTERED" + ControlChars.CrLf;
									}
									else if ( sTABLE_NAME == "NOTE_ATTACHMENTS" )
									{
										sSQL = "select NOTE_ID  as ID         " + ControlChars.CrLf
										     + "     , FILENAME as NAME       " + ControlChars.CrLf
										     + "     , 'Notes'  as MODULE_NAME" + ControlChars.CrLf
										     + "  from " + sTABLE_NAME          + ControlChars.CrLf
										     + " where contains(" + sCOLUMN_NAME + ", @SEARCH_TEXT)" + ControlChars.CrLf
										     + " order by DATE_ENTERED" + ControlChars.CrLf;
									}
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.CommandText = sSQL;
										Sql.AddParameter(cmd, "@SEARCH_TEXT", sSEARCH_TEXT);
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
													grdMain.DataBind();
												}
											}
										}
									}
								}
							}
							else if ( Sql.IsEmptyString(lstTABLES.SelectedValue) )
							{
								lblError.Text = "Please select a table.";
							}
							else if ( Sql.IsEmptyString(txtSEARCH_TEXT.Text) )
							{
								lblError.Text = "Please specify the search text.";
							}
						}
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
			ctlSearchButtons.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "FullTextSearch";
			SetMenu(m_sMODULE);
		}
		#endregion
	}
}

