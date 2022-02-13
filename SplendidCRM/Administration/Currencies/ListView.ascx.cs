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
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Administration.Currencies
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		protected _controls.HeaderButtons ctlModuleHeader;
		protected _controls.SearchView    ctlSearchView  ;
		protected _controls.CheckAll      ctlCheckAll    ;

		protected DataView      vwMain            ;
		protected SplendidGrid  grdMain           ;
		protected Label         lblError          ;
		protected MassUpdate    ctlMassUpdate     ;
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
				else if ( e.CommandName == "Currencies.Delete" )
				{
					Guid gID = Sql.ToGuid(e.CommandArgument);
					SqlProcs.spCURRENCIES_Delete(gID);
					// 04/20/2006 Paul.  Make sure to clear the cache. 
					Cache.Remove("vwCURRENCIES_LISTBOX");
					// 05/01/2016 Paul.  Rebind after update. 
					Bind(true);
				}
				else if ( e.CommandName == "Currencies.MakeDefault" )
				{
					// 08/08/2006 Paul.  Update the config value. 
					string sNAME     = "default_currency";
					string sCATEGORY = "system";
					string sVALUE    = Sql.ToString(e.CommandArgument);
					SqlProcs.spCONFIG_Update(sCATEGORY, sNAME, sVALUE);
					Application["CONFIG." + sNAME] = sVALUE;
					// 05/01/2016 Paul.  Rebind after update. 
					Bind(true);
				}
				else if ( e.CommandName == "Currencies.UpdateRate" )
				{
					StringBuilder sbErrors = new StringBuilder();
					string sISO4217 = Sql.ToString(e.CommandArgument);
					float dRate = OrderUtils.GetCurrencyConversionRate(Application, sISO4217, sbErrors);
					if ( sbErrors.Length == 0 )
					{
						Bind(true);
					}
					else
					{
						lblError.Text = sbErrors.ToString();
					}
				}
				// 05/01/2016 Paul.  Add support for mass update. 
				else if ( e.CommandName == "ToggleMassUpdate" )
				{
					pnlMassUpdateSeven.Visible = !pnlMassUpdateSeven.Visible;
				}
				else if ( e.CommandName == "MassUpdate" )
				{
					string[] arrID = ctlCheckAll.SelectedItemsArray;
					if ( arrID != null )
					{
						string sIDs = Utils.ValidateIDs(arrID);
						if ( !Sql.IsEmptyString(sIDs) )
						{
							SqlProcs.spCURRENCIES_MassUpdate(sIDs, ctlMassUpdate.STATUS);
							Bind(true);
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

		// 05/01/2016 Paul.  Rebind after update. 
		protected void Bind(bool bBind)
		{
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					sSQL = "select *                 " + ControlChars.CrLf
					     + "  from vwCURRENCIES_List " + ControlChars.CrLf
					     + " where 1 = 1             " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						// 05/01/2016 Paul.  Enable searching of currencies. 
						grdMain.OrderByClause("NAME", "asc");
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
								// 05/01/2016 Paul.  We are now using a dynamic layout. 
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
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term("Currencies.LBL_CURRENCY"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "list") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			Bind(!IsPostBack);
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
			m_sMODULE = "Currencies";
			// 05/06/2010 Paul.  The menu will show the admin Module Name in the Six theme. 
			SetMenu(m_sMODULE);
			this.AppendGridColumns(grdMain, m_sMODULE + "." + LayoutListView);

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

