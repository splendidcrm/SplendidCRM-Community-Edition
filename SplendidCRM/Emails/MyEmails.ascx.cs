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
	///		Summary description for MyEmails.
	/// </summary>
	public class MyEmails : DashletControl
	{
		protected _controls.DashletHeader  ctlDashletHeader ;
		protected _controls.SearchView     ctlSearchView    ;

		protected UniqueStringCollection arrSelectFields;
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected Label         lblError       ;
		protected bool          bShowEditDialog = false;
		protected Button        btnSELECT_USER ;
		protected HiddenField   hidEMAIL_ID    ;
		protected HiddenField   hidUSER_ID     ;
		protected int           nASSIGNED_TO_Column = -1;

		protected void grdMain_OnItemDataBound(object sender, DataGridItemEventArgs e)
		{
			if ( e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem )
			{
				DataView vw = grdMain.DataSource as DataView;
				if ( vw != null && vw.Count > 0 )
				{
					DataGridItem itm = e.Item;
					DataRowView row = itm.DataItem as DataRowView;
					if ( row != null )
					{
						if ( nASSIGNED_TO_Column >= 0 && Sql.IsEmptyGuid(row["ASSIGNED_USER_ID"]) )
						{
							if ( nASSIGNED_TO_Column < itm.Controls.Count )
							{
								TableCell tdASSIGNED_TO = itm.Controls[nASSIGNED_TO_Column] as TableCell;
								if ( tdASSIGNED_TO != null )
								{
									LinkButton lnkSelect = new LinkButton();
									lnkSelect.CssClass      = "listViewTdToolsS1";
									lnkSelect.Text          = L10n.Term(".LBL_SELECT_BUTTON_LABEL");
									lnkSelect.ToolTip       = L10n.Term(".LBL_SELECT_BUTTON_TITLE");
									lnkSelect.OnClientClick = "document.getElementById('" + hidEMAIL_ID.ClientID + "').value='" + Sql.ToGuid(row["ID"]) + "'; return ModulePopup('Users', '" + hidUSER_ID.ClientID + "', null, null, false, null, '" + btnSELECT_USER.ClientID + "');";
									tdASSIGNED_TO.Controls.Add(lnkSelect);
								}
							}
						}
					}
				}
			}
		}
		
		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Search" )
				{
					bShowEditDialog = true;
					grdMain.CurrentPageIndex = 0;
					Bind(true);
				}
				else if ( e.CommandName == "Refresh" )
				{
					Bind(true);
				}
				// 07/10/2009 Paul.  Allow the dashlet to be removed. 
				else if ( e.CommandName == "Remove" )
				{
					if ( !Sql.IsEmptyString(sDetailView) )
					{
						SqlProcs.spDASHLETS_USERS_InitDisable(Security.USER_ID, sDetailView, m_sMODULE, this.AppRelativeVirtualPath.Substring(0, this.AppRelativeVirtualPath.Length-5));
						SplendidCache.ClearUserDashlets(sDetailView);
						Response.Redirect(Page.AppRelativeVirtualPath + Request.Url.Query);
					}
				}
				else if ( e.CommandName == "AssignUser" )
				{
					Guid gEMAIL_ID = Sql.ToGuid(hidEMAIL_ID.Value);
					Guid gUSER_ID  = Sql.ToGuid(hidUSER_ID .Value);
					hidEMAIL_ID.Value = String.Empty;
					hidUSER_ID .Value = String.Empty;
					
					if ( !Sql.IsEmptyGuid(gEMAIL_ID) && !Sql.IsEmptyGuid(gUSER_ID) )
					{
						SqlProcs.spEMAILS_MassAssign(gEMAIL_ID.ToString(), gUSER_ID, Guid.Empty);
					}
					Bind(true);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		protected void Bind(bool bBind)
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				sSQL = "  from vwEMAILS_MyList" + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Security.Filter(cmd, m_sMODULE, "list");
					// 11/02/2010 Paul.  The default sort should put the unassigned at the top. 
					// 11/02/2010 Paul.  It is important to note that the sort column will make it into the select fields, 
					// so we cannot use asc or desc clauses.  Search for arrSelectFields.Add(grdMain.SortColumn) for the locations where this is done. 
					grdMain.OrderByClause("ASSIGNED_USER_ID, DATE_START", "desc");
					// 06/27/2009 Paul.  Only apply Assigned default if no search was loaded. 
					if ( !ctlSearchView.SqlSearchClause(cmd) )
					{
						// 06/23/2018 Paul.  Need to allow multiple users to see the data they are assigned to. 
						if ( Crm.Config.enable_dynamic_assignment() )
							cmd.CommandText += "   and ASSIGNED_SET_LIST like '%" + Security.USER_ID.ToString() + "%'" + ControlChars.CrLf;
						else
							Sql.AppendParameter(cmd, Security.USER_ID, "ASSIGNED_USER_ID", false);
						ListBox lstASSIGNED_USER_ID = ctlSearchView.FindControl("ASSIGNED_USER_ID") as ListBox;
						if ( lstASSIGNED_USER_ID != null )
						{
							Utils.SelectItem(lstASSIGNED_USER_ID, Security.USER_ID.ToString());
						}
					}
					cmd.CommandText = "select " + Sql.FormatSelectFields(arrSelectFields)
					                + cmd.CommandText
					                + grdMain.OrderByClause();

					if ( bDebug )
						RegisterClientScriptBlock("vwEMAILS_MyList", Sql.ClientScriptBlock(cmd));

					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								// 03/07/2013 Paul.  Apply business rules to subpanel. 
								this.ApplyGridViewRules(m_sMODULE + ".MyEmails", dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								if ( bBind )
									grdMain.DataBind();
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						lblError.Text = ex.Message;
					}
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			this.Visible = this.Visible && (SplendidCRM.Security.GetUserAccess(m_sMODULE, "list") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				Bind(!IsPostBack);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		protected override void OnPreRender(EventArgs e)
		{
			// 06/21/2009 Paul.  We are having an issue with other panels losing pagination information 
			// during a refresh of an alternate panel.
			if ( IsPostBack )
			{
				grdMain.DataBind();
			}
			base.OnPreRender(e);
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
			this.Load                += new System.EventHandler(this.Page_Load);
			ctlDashletHeader.Command += new CommandEventHandler(Page_Command);
			ctlSearchView.Command    += new CommandEventHandler(Page_Command);
			grdMain.ItemDataBound    += new DataGridItemEventHandler(grdMain_OnItemDataBound);
			m_sMODULE = "Emails";
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("ID"              );
			arrSelectFields.Add("DATE_START"      );
			arrSelectFields.Add("ASSIGNED_USER_ID");
			arrSelectFields.Add("ATTACHMENT_COUNT");
			this.AppendGridColumns(grdMain, "Emails.MyEmails", arrSelectFields);
			for ( int i = 0; i < grdMain.Columns.Count; i++ )
			{
				DataGridColumn col = grdMain.Columns[i];
				if ( col.SortExpression == "ASSIGNED_TO_NAME" || col.SortExpression == "ASSIGNED_TO" )
				{
					nASSIGNED_TO_Column = i;
					break;
				}
			}
		}
		#endregion
	}
}

