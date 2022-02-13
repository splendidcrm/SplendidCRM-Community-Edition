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
using System.Text;
using System.Data;
using System.Data.Common;
using System.Collections.Generic;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Administration.FullTextSearch
{
	/// <summary>
	///		Summary description for ConfigView.
	/// </summary>
	public class ConfigView : SplendidControl
	{
		protected _controls.HeaderButtons  ctlDynamicButtons;

		protected Label   FULLTEXT_SUPPORTED     ;
		protected Label   SQL_SERVER_VERSION     ;
		protected Label   SQL_SERVER_EDITION     ;
		protected Label   FULLTEXT_INSTALLED     ;
		//protected Label   FULLTEXT_ENABLED       ;
		protected Label   FULLTEXT_CATALOG_EXISTS;
		protected Label   OFFICE_SUPPORTED       ;
		protected Label   PDF_SUPPORTED          ;
		protected Label   SUPPORTED_INSTRUCTIONS ;
		protected Label   INSTALLED_INSTRUCTIONS ;
		protected Label   ENABLED_INSTRUCTIONS   ;
		protected Label   CATALOG_INSTRUCTIONS   ;
		protected Label   OFFICE_INSTRUCTIONS    ;
		protected Label   PDF_INSTRUCTIONS       ;
		protected TextBox DOCUMENT_TYPES         ;
		protected TextBox INDEXED_TABLES         ;
		protected Label   POPULATION_STATUS      ;
		protected Label   POPULATION_COUNT       ;
		protected Label   LAST_POPULATION_DATE   ;

		protected bool    bIsFullTextInstalled = false;
		protected List<String> lstIndexedTables = new List<String>();

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Enable" || e.CommandName == "Disable" || e.CommandName == "RebuildIndex" )
			{
				try
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						//SqlProcs.spFULLTEXT_ConfigCatalog(e.CommandName);
						// 10/22/2016 Paul.  Full Text Catalog operations cannot be called within a transaction. 
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandType = CommandType.StoredProcedure;
							cmd.CommandText = "spFULLTEXT_ConfigCatalog";
							IDbDataParameter parMODIFIED_USER_ID = Sql.AddParameter(cmd, "@MODIFIED_USER_ID",  Security.USER_ID);
							IDbDataParameter parOPERATION        = Sql.AddParameter(cmd, "@OPERATION"       , e.CommandName, 25);
							cmd.ExecuteNonQuery();
						}
						// 10/22/2016 Paul.  Allow the layout changes to be executed in a transaction. 
						SqlProcs.spFULLTEXT_UpdateLayouts(e.CommandName);
					}
					Response.Redirect("config.aspx");
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					ctlDynamicButtons.ErrorText = ex.Message;
				}
			}
			else if ( e.CommandName == "Test" )
			{
				Response.Redirect("default.aspx");
			}
			else if ( e.CommandName == "Cancel" )
			{
				Response.Redirect("../default.aspx");
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term("FullTextSearch.LBL_LIST_FORM_TITLE"));
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
			{
				Parent.DataBind();
				return;
			}

			try
			{
				if ( !IsPostBack )
				{
					ctlDynamicButtons.AppendButtons(m_sMODULE + ".ConfigView", Guid.Empty, null);
				}
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					if ( Sql.IsSQLServer(con) )
					{
						FULLTEXT_SUPPORTED.Text = L10n.Term(".LBL_YES");
						
						string sSQL;
						sSQL = "select *                    " + ControlChars.CrLf 
						     + "  from vwFULLTEXT_Properties" + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
							{
								if ( rdr.Read() )
								{
									SQL_SERVER_VERSION     .Text =  Sql.ToString (rdr["SQL_SERVER_VERSION"  ]);
									SQL_SERVER_EDITION     .Text =  Sql.ToString (rdr["SQL_SERVER_EDITION"  ]);
									FULLTEXT_INSTALLED     .Text = (Sql.ToBoolean(rdr["FULLTEXT_INSTALLED"  ])     ? L10n.Term(".LBL_YES") : L10n.Term(".LBL_NO"));
									FULLTEXT_CATALOG_EXISTS.Text = (Sql.ToInteger(rdr["FULLTEXT_CATALOG_ID" ]) > 0 ? L10n.Term(".LBL_YES") : L10n.Term(".LBL_NO"));
									OFFICE_SUPPORTED       .Text = (Sql.ToBoolean(rdr["OFFICE_DOCUMENT_TYPE"])     ? L10n.Term(".LBL_YES") : L10n.Term(".LBL_NO"));
									PDF_SUPPORTED          .Text = (Sql.ToBoolean(rdr["PDF_DOCUMENT_TYPE"   ])     ? L10n.Term(".LBL_YES") : L10n.Term(".LBL_NO"));
									bIsFullTextInstalled = Sql.ToBoolean(rdr["FULLTEXT_INSTALLED"]);
								}
							}
						}
						sSQL = "select DOCUMENT_TYPE            " + ControlChars.CrLf
						     + "  from vwFULLTEXT_DOCUMENT_TYPES" + ControlChars.CrLf
						     + " order by DOCUMENT_TYPE         " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									StringBuilder sb = new StringBuilder();
									foreach ( DataRow row in dt.Rows )
									{
										sb.AppendLine(Sql.ToString(row["DOCUMENT_TYPE"]));
									}
									DOCUMENT_TYPES.Text = sb.ToString();
								}
							}
						}
						sSQL = "select *                 " + ControlChars.CrLf
						     + "  from vwFULLTEXT_INDEXES" + ControlChars.CrLf
						     + " order by TABLE_NAME     " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							using ( IDataReader rdr = cmd.ExecuteReader() )
							{
								StringBuilder sb = new StringBuilder();
								while ( rdr.Read() )
								{
									string sTABLE_NAME = Sql.ToString(rdr["TABLE_NAME"]);
									lstIndexedTables.Add(sTABLE_NAME);
									sb.AppendLine(sTABLE_NAME);
								}
								INDEXED_TABLES.Text = sb.ToString();
							}
						}
						// https://msdn.microsoft.com/en-us/library/ms190370(v=sql.90).aspx
						sSQL = "select *                  " + ControlChars.CrLf
						     + "  from vwFULLTEXT_CATALOGS" + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
							{
								if ( rdr.Read() )
								{
									POPULATION_STATUS   .Text = Sql.ToString(rdr["POPULATE_STATUS"     ]);
									POPULATION_COUNT    .Text = Sql.ToString(rdr["ITEM_COUNT"          ]);
									LAST_POPULATION_DATE.Text = Sql.ToString(rdr["LAST_POPULATION_DATE"]);
								}
							}
						}
					}
				}
				ctlDynamicButtons.ShowButton("Enable"      , lstIndexedTables.Count == 0 && bIsFullTextInstalled);
				ctlDynamicButtons.ShowButton("Disable"     , lstIndexedTables.Count >  0);
				ctlDynamicButtons.ShowButton("Test"        , lstIndexedTables.Count >  0);
				ctlDynamicButtons.ShowButton("RebuildIndex", lstIndexedTables.Count >  0);
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
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "FullTextSearch";
			SetAdminMenu(m_sMODULE);
			if ( IsPostBack )
			{
				ctlDynamicButtons.AppendButtons(m_sMODULE + ".ConfigView", Guid.Empty, null);
			}
		}
		#endregion
	}
}
