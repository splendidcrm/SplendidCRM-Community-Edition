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
using AjaxControlToolkit;

namespace SplendidCRM.Administration.Dropdown
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		// 06/05/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons ctlModuleHeader;
		//protected _controls.ListHeader ctlListHeader ;
		
		protected DataView        vwMain       ;
		protected Label           lblError     ;
		protected SearchBasic     ctlSearch    ;
		protected SplendidGrid    grdMain      ;
		protected HiddenField     txtINDEX     ;
		protected Button          btnINDEX_MOVE;
		protected bool            bEnableAdd   ;
		
		protected void grdMain_ItemCreated(object sender, DataGridItemEventArgs e)
		{
			if ( e.Item.ItemType == ListItemType.Header || e.Item.ItemType == ListItemType.Footer )
			{
				e.Item.CssClass += " nodrag nodrop";
			}
		}

		protected void grdMain_ItemCommand(object source, DataGridCommandEventArgs e)
		{
			try
			{
				switch ( e.CommandName )
				{
					case "Edit":
					{
						grdMain.EditItemIndex = e.Item.ItemIndex;
						grdMain.ShowFooter = false;
						grdMain.DataBind();
						break;
					}
					case "Cancel":
					{
						grdMain.EditItemIndex = -1;
						grdMain.ShowFooter = bEnableAdd;
						grdMain.DataBind();
						break;
					}
					case "Delete":
					{
						Guid gID = Sql.ToGuid(e.CommandArgument);
						SqlProcs.spTERMINOLOGY_LIST_Delete(gID);
						grdMain.EditItemIndex = -1;
						grdMain.ShowFooter = bEnableAdd;
						TERMINOLOGY_BindData(true);
						break;
					}
					case "Update":
					{
						Guid    gID             = Sql.ToGuid   (vwMain[e.Item.ItemIndex]["ID"        ]);
						int     nLIST_ORDER     = Sql.ToInteger(vwMain[e.Item.ItemIndex]["LIST_ORDER"]);
						string  sOLD_NAME       = Sql.ToString (vwMain[e.Item.ItemIndex]["NAME"      ]);
						TextBox txtNAME         = e.Item.FindControl("txtNAME"        ) as TextBox;
						TextBox txtDISPLAY_NAME = e.Item.FindControl("txtDISPLAY_NAME") as TextBox;
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									// 07/25/2010 Paul.  If hte name has changed, then we need to delete the old and insert the new. 
									if ( sOLD_NAME != txtNAME.Text )
									{
										SqlProcs.spTERMINOLOGY_LIST_Delete(gID, trn);
										gID = Guid.Empty;
									}
									SqlProcs.spTERMINOLOGY_LIST_Insert(ref gID, txtNAME.Text, ctlSearch.LANGUAGE, String.Empty, ctlSearch.DROPDOWN, nLIST_ORDER, txtDISPLAY_NAME.Text, trn);
									trn.Commit();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									lblError.Text = ex.Message;
									return;
								}
							}
						}
						L10N.SetTerm(ctlSearch.LANGUAGE, String.Empty, ctlSearch.DROPDOWN, txtNAME.Text, txtDISPLAY_NAME.Text);
						SplendidCache.ClearList(ctlSearch.LANGUAGE, ctlSearch.DROPDOWN);
						grdMain.EditItemIndex = -1;
						grdMain.ShowFooter = bEnableAdd;
						TERMINOLOGY_BindData(true);
						break;
					}
					case "Insert":
					{
						int  nLIST_ORDER = -1;
						TextBox txtNAME         = e.Item.FindControl("txtNAME"        ) as TextBox;
						TextBox txtDISPLAY_NAME = e.Item.FindControl("txtDISPLAY_NAME") as TextBox;
						if ( txtNAME != null && txtDISPLAY_NAME != null )
						{
							Guid gID = Guid.Empty;
							SqlProcs.spTERMINOLOGY_LIST_Insert(ref gID, txtNAME.Text, ctlSearch.LANGUAGE, String.Empty, ctlSearch.DROPDOWN, nLIST_ORDER, txtDISPLAY_NAME.Text);
							txtNAME        .Text = String.Empty;
							txtDISPLAY_NAME.Text = String.Empty;
							grdMain.ShowFooter = bEnableAdd;
							TERMINOLOGY_BindData(true);
						}
						break;
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
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
				
				int nOLD_INDEX = Sql.ToInteger(vwMain[nOLD_VALUE]["LIST_ORDER"]);
				int nNEW_INDEX = Sql.ToInteger(vwMain[nNEW_VALUE]["LIST_ORDER"]);
				SqlProcs.spTERMINOLOGY_LIST_MoveItem(ctlSearch.LANGUAGE, ctlSearch.DROPDOWN, nOLD_INDEX, nNEW_INDEX);
				SplendidCache.ClearList(ctlSearch.LANGUAGE, ctlSearch.DROPDOWN);
				TERMINOLOGY_BindData(true);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				Guid gID = Sql.ToGuid(e.CommandArgument);
				if ( e.CommandName == "Select" )
				{
					TERMINOLOGY_BindData(true);
				}
				// 09/18/2012 Paul.  Provide quick access to the create option. 
				else if ( e.CommandName == "Create" )
				{
					Response.Redirect("edit.aspx");
				}
				else if ( e.CommandName == "Dropdown.MoveUp" )
				{
					if ( Sql.IsEmptyGuid(gID) )
						throw(new Exception("Unspecified argument"));
					SqlProcs.spTERMINOLOGY_LIST_MoveUp(gID);
					// 09/08/2005 Paul.  If the list changes, reset the cached values. 
					SplendidCache.ClearList(ctlSearch.LANGUAGE, ctlSearch.DROPDOWN);
					//TERMINOLOGY_BindData(true);
					//Response.Redirect("default.aspx?Dropdown=" + ctlSearch.DROPDOWN);
					SplendidCache.ClearList(ctlSearch.LANGUAGE, ctlSearch.DROPDOWN);
					TERMINOLOGY_BindData(true);
				}
				else if ( e.CommandName == "Dropdown.MoveDown" )
				{
					if ( Sql.IsEmptyGuid(gID) )
						throw(new Exception("Unspecified argument"));
					SqlProcs.spTERMINOLOGY_LIST_MoveDown(gID);
					// 09/08/2005 Paul.  If the list changes, reset the cached values. 
					SplendidCache.ClearList(ctlSearch.LANGUAGE, ctlSearch.DROPDOWN);
					//TERMINOLOGY_BindData(true);
					//Response.Redirect("default.aspx?Dropdown=" + ctlSearch.DROPDOWN);
					SplendidCache.ClearList(ctlSearch.LANGUAGE, ctlSearch.DROPDOWN);
					TERMINOLOGY_BindData(true);
				}
				else if ( e.CommandName == "Dropdown.Delete" )
				{
					if ( Sql.IsEmptyGuid(gID) )
						throw(new Exception("Unspecified argument"));
					SqlProcs.spTERMINOLOGY_LIST_Delete(gID);
					// 09/08/2005 Paul.  If the list changes, reset the cached values. 
					SplendidCache.ClearList(ctlSearch.LANGUAGE, ctlSearch.DROPDOWN);
					//TERMINOLOGY_BindData(true);
					//Response.Redirect("default.aspx?Dropdown=" + ctlSearch.DROPDOWN);
					SplendidCache.ClearList(ctlSearch.LANGUAGE, ctlSearch.DROPDOWN);
					TERMINOLOGY_BindData(true);
				}
				else
				{
					TERMINOLOGY_BindData(true);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void TERMINOLOGY_BindData(bool bBind)
		{
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			//ctlListHeader.Visible = true;
			
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					sSQL = "select *                 " + ControlChars.CrLf
					     + "  from vwTERMINOLOGY_List" + ControlChars.CrLf
					     + " where 1 = 1             " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						// 01/16/2006 Paul.  New lists should go directly to list editing. 
						string sDROPDOWN = Sql.ToString(Request.QueryString["DROPDOWN"]);
						// 11/19/2005 Paul.  The language must be initialized before the search clause is applied. 
						if ( !IsPostBack )
						{
							// 01/05/2006 Paul.  Fix Form Action so that Query String parameters will not continue to get passed around. 
							if ( !Sql.IsEmptyString(sDROPDOWN) )
							{
								ctlSearch.DROPDOWN = sDROPDOWN;
								RegisterClientScriptBlock("frmRedirect", "<script type=\"text/javascript\">document.forms[0].action='default.aspx';</script>");
							}
							// 09/18/2012 Paul.  Allow direct access to language. 
							string sLANG = Sql.ToString(Request["LANG"]);
							if ( Sql.IsEmptyString(sLANG) )
								ctlSearch.LANGUAGE = L10n.NAME;
							ctlSearch.LANGUAGE = sLANG;
						}
						ctlSearch.SqlSearchClause(cmd);
						cmd.CommandText += " order by LIST_ORDER";

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
			SetPageTitle(L10n.Term("Dropdown.LBL_LIST_FORM_TITLE"));
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
				//ScriptReference  scrJQuery         = new ScriptReference ("~/Include/javascript/jquery-1.4.2.min.js"   );
				ScriptReference  scrJQueryTableDnD = new ScriptReference ("~/Include/javascript/jquery.tablednd_0_5.js");
				//if ( !mgrAjax.Scripts.Contains(scrJQuery) )
				//	mgrAjax.Scripts.Add(scrJQuery);
				if ( !mgrAjax.Scripts.Contains(scrJQueryTableDnD) )
					mgrAjax.Scripts.Add(scrJQueryTableDnD);

				bEnableAdd = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
				if ( !IsPostBack )
				{
					grdMain.ShowFooter = bEnableAdd;
					string sDROPDOWN = Sql.ToString(Request["Dropdown"]);
					if ( !Sql.IsEmptyString(sDROPDOWN) )
					{
						TERMINOLOGY_BindData(true);
					}
				}
				else
				{
					// Must bind in order for LinkButton to get the argument. 
					// ImageButton does not work no matter what I try. 
					// 07/25/2010 Paul.  The ImageButtons are working without binding. 
					// 07/25/2010 Paul.  The problem with the ReorderList commands not firing was that the OnCommand was still set to Page_Command. 
					TERMINOLOGY_BindData(false);
				}
			}
			catch(Exception ex)
			{
				// 01/20/2006 Paul.  Need to catch all errors.  Saw a dropdown error when creating a new dropdown. 
				lblError.Text = ex.Message;
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
#if DEBUG
				lblError.Text += ex.StackTrace;
#endif
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
			ctlSearch.Command      += new CommandEventHandler(Page_Command);
			grdMain  .ItemCommand  += new DataGridCommandEventHandler(grdMain_ItemCommand);
			grdMain  .ItemCreated  += new DataGridItemEventHandler(grdMain_ItemCreated);
			txtINDEX .ValueChanged += new EventHandler(txtINDEX_ValueChanged);
			m_sMODULE = "Dropdown";
			// 05/06/2010 Paul.  The menu will show the admin Module Name in the Six theme. 
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

