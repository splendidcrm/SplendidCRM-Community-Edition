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

namespace SplendidCRM.Administration.RenameTabs
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		protected DataView        vwMain       ;
		protected SplendidGrid    grdMain      ;
		protected Label           lblError     ;
		protected SearchBasic     ctlSearch    ;
		protected HtmlInputHidden txtRENAME    ;
		protected HtmlInputHidden txtKEY       ;
		protected HtmlInputHidden txtVALUE     ;
		protected bool            bEnableAdd   ;

		protected _controls.ListHeader ctlListHeader ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
		}

		private void TERMINOLOGY_BindData(bool bBind)
		{
			bEnableAdd = true;
			ctlListHeader.Visible = true;
			
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					sSQL = "select *                   " + ControlChars.CrLf
					     + "  from vwMODULES_RenameTabs" + ControlChars.CrLf
					     + " where 1 = 1               " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						// 11/19/2005 Paul.  The language must be initialized before the search clause is applied. 
						if ( !IsPostBack )
							ctlSearch.LANGUAGE = L10n.NAME;
						ctlSearch.SqlSearchClause(cmd);

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
								
								// 12/14/2007 Paul.  Only set the default sort if it is not already set.  It may have been set by SearchView. 
								if ( String.IsNullOrEmpty(grdMain.SortColumn) )
								{
									grdMain.SortColumn = "TAB_ORDER";
									grdMain.SortOrder  = "asc" ;
								}
								grdMain.ApplySort();
								if ( bBind )
									grdMain.DataBind();
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
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term("Administration.LBL_RENAME_TABS"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "list") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			// 09/08/2005 Paul. An empty key is valid, so use a separate INSERT field. 
			if ( txtRENAME.Value == "1" )
			{
				try
				{
					SqlProcs.spMODULES_TAB_Rename(Guid.Empty, txtKEY.Value, ctlSearch.LANGUAGE, txtVALUE.Value);
					SplendidCache.ClearList(ctlSearch.LANGUAGE, "moduleList");
					// 01/17/2006 Paul.  Also need to clear the TabMenu. 
					SplendidCache.ClearTabMenu();
					// 04/20/2006 Paul.  Also clear the term for the list. 
					L10N.SetTerm(ctlSearch.LANGUAGE, String.Empty, "moduleList", txtKEY.Value, txtVALUE.Value);
					txtRENAME.Value = "";
					// 09/09/2005 Paul.  Transfer so that viewstate will be reset completely. 
					// 01/04/2005 Paul.  Redirecting to default.aspx will loose the language setting.  Just rebind. 
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					lblError.Text = ex.Message;
				}
			}
			// Must bind in order for LinkButton to get the argument. 
			// ImageButton does not work no matter what I try. 
			TERMINOLOGY_BindData(true);
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
			// We have to load the control in here, otherwise the control will not initialized before the Page_Load above. 
			ctlSearch.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Modules";
			// 05/06/2010 Paul.  The menu will show the admin Module Name in the Six theme. 
			SetMenu(m_sMODULE);
		}
		#endregion
	}
}

