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

namespace SplendidCRM.Administration.DynamicLayout.EditRelationships
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		protected _controls.SearchBasic            ctlSearch    ;
		protected SplendidCRM._controls.ListHeader ctlListHeader;

		protected DataView        vwMain       ;
		protected SplendidGrid    grdMain      ;
		protected Label           lblError     ;
		protected HiddenField     txtINDEX     ;
		protected Button          btnINDEX_MOVE;

		protected void grdMain_ItemCreated(object sender, DataGridItemEventArgs e)
		{
			if ( e.Item.ItemType == ListItemType.Header || e.Item.ItemType == ListItemType.Footer )
			{
				e.Item.CssClass += " nodrag nodrop";
			}
			else if ( e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem )
			{
				DataRowView row = e.Item.DataItem as DataRowView;
				if ( row != null )
				{
					if ( !(Sql.ToBoolean(row["RELATIONSHIP_ENABLED"]) && (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0)) )
						e.Item.CssClass += " nodrag nodrop";
				}
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
				
				int nOLD_INDEX = Sql.ToInteger(vwMain[nOLD_VALUE]["RELATIONSHIP_ORDER"]);
				int nNEW_INDEX = Sql.ToInteger(vwMain[nNEW_VALUE]["RELATIONSHIP_ORDER"]);
				SqlProcs.spEDITVIEWS_RELATIONSHIPS_Item(ctlSearch.NAME, nOLD_INDEX, nNEW_INDEX);
				SplendidCache.ClearEditViewRelationships(ctlSearch.NAME);
				EDITVIEWS_RELATIONSHIPS_BindData(true);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
#if DEBUG
				lblError.Text += ex.StackTrace;
#endif
			}
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				Guid gID = Sql.ToGuid(e.CommandArgument);
				if ( e.CommandName == "Relationships.MoveUp" )
				{
					if ( Sql.IsEmptyGuid(gID) )
						throw(new Exception("Unspecified argument"));
					SqlProcs.spEDITVIEWS_RELATIONSHIPS_MoveUp(gID);
				}
				else if ( e.CommandName == "Relationships.MoveDown" )
				{
					if ( Sql.IsEmptyGuid(gID) )
						throw(new Exception("Unspecified argument"));
					// 09/08/2007 Paul.  The name is not MoveDown because Oracle will truncate to 30 characters
					// and we need to ensure there is no collision with MoveUp.
					SqlProcs.spEDITVIEWS_RELATIONSHIPS_Down(gID);
				}
				else if ( e.CommandName == "Relationships.Disable" )
				{
					if ( Sql.IsEmptyGuid(gID) )
						throw(new Exception("Unspecified argument"));
					SqlProcs.spEDITVIEWS_RELATIONSHIPS_Disable(gID);
				}
				else if ( e.CommandName == "Relationships.Enable" )
				{
					if ( Sql.IsEmptyGuid(gID) )
						throw(new Exception("Unspecified argument"));
					SqlProcs.spEDITVIEWS_RELATIONSHIPS_Enable(gID);
				}
				// 01/04/2005 Paul.  If the list changes, reset the cached values. 
				// 12/11/2008 Paul.  We needed to clear the view name.
				SplendidCache.ClearEditViewRelationships(ctlSearch.NAME);
				EDITVIEWS_RELATIONSHIPS_BindData(true);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void EDITVIEWS_RELATIONSHIPS_BindData(bool bBind)
		{
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					sSQL = "select *                             " + ControlChars.CrLf
					     + "  from " + Sql.MetadataName(con, "vwEDITVIEWS_RELATIONSHIPS_Layout") + ControlChars.CrLf
					     + " where @EDIT_NAME = EDIT_NAME        " + ControlChars.CrLf
					     + " order by RELATIONSHIP_ENABLED, RELATIONSHIP_ORDER, MODULE_NAME" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@EDIT_NAME", ctlSearch.NAME);

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
			SetPageTitle(L10n.Term("DynamicLayout.LBL_RELATIONSHIPS_LAYOUT"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
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
				// 08/25/2013 Paul.  jQuery now registered in the master pages. 
				//ScriptReference  scrJQuery         = new ScriptReference ("~/Include/javascript/jquery-1.4.2.min.js"   );
				ScriptReference  scrJQueryTableDnD = new ScriptReference ("~/Include/javascript/jquery.tablednd_0_5.js");
				//if ( !mgrAjax.Scripts.Contains(scrJQuery) )
				//	mgrAjax.Scripts.Add(scrJQuery);
				if ( !mgrAjax.Scripts.Contains(scrJQueryTableDnD) )
					mgrAjax.Scripts.Add(scrJQueryTableDnD);

				// 01/08/2006 Paul.  The viewstate is no longer disabled, so we can go back to using ctlSearch.NAME.
				string sNAME = ctlSearch.NAME;  //Sql.ToString(Request[ctlSearch.ListUniqueID]);
				// 07/26/2010 Paul.  Lets stop hiding the search after selection. 
				//ctlSearch.Visible = Sql.IsEmptyString(sNAME);
				ctlListHeader.Visible = !Sql.IsEmptyString(sNAME);
				ctlListHeader.Title = sNAME;
				ctlListHeader.DataBind();

				if ( !Sql.IsEmptyString(sNAME) && sNAME != Sql.ToString(ViewState["LAYOUT_VIEW_NAME"]) )
				{
					// 01/08/2006 Paul.  We are having a problem with the ViewState not loading properly.
					// This problem only seems to occur when the NewRecord is visible and we try and load a different view.
					// The solution seems to be to hide the Search dialog so that the user must Cancel out of editing the current view.
					// This works very well to clear the ViewState because we GET the next page instead of POST to it. 
					
					SetPageTitle(sNAME);
					// 07/27/2010 Paul.  Binding the page at this time is causing a TreeView exception. 
					//Page.DataBind();

					// Must bind in order for LinkButton to get the argument. 
					// ImageButton does not work no matter what I try. 
					EDITVIEWS_RELATIONSHIPS_BindData(true);
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
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
			grdMain.ItemCreated += new DataGridItemEventHandler(grdMain_ItemCreated);
			txtINDEX.ValueChanged += new EventHandler(txtINDEX_ValueChanged);
			m_sMODULE = "DynamicLayout";
			// 05/06/2010 Paul.  The menu will show the admin Module Name in the Six theme. 
			SetMenu(m_sMODULE);
		}
		#endregion
	}
}

