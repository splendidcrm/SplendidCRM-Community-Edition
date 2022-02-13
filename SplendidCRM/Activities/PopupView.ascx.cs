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

namespace SplendidCRM.Activities
{
	/// <summary>
	///		Summary description for PopupView.
	/// </summary>
	public class PopupView : SplendidControl
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
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		protected void grdMain_OnSelectMethod(int nCurrentPageIndex, int nPageSize)
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
					// 03/15/2016 Paul.  We don't use the _List view here because it has an old meaning. 
					cmd.CommandText = "  from vwACTIVITIES" + ControlChars.CrLf;
					Security.Filter(cmd, m_sMODULE, "list");
					ctlSearchView.SqlSearchClause(cmd);
					
					Guid   gPARENT_ID   = new DynamicControl(ctlSearchView, "PARENT_ID"            ).ID;
					string sPARENT_TYPE = new DynamicControl(ctlSearchView, "PARENT_ID_PARENT_TYPE").SelectedValue;
					// 04/04/2016 Paul.  ApplyRelationshipView will replace default @PARENT_ID with new filter, so it can be called even if parent not specified. 
					bool bIncludeRelationships = Sql.ToBoolean(Request["IncludeRelationships"]);
					// 10/31/2021 Paul.  Moved ApplyRelationshipView to ModuleUtils. 
					ModuleUtils.Activities.ApplyRelationshipView(cmd, sPARENT_TYPE, gPARENT_ID, bIncludeRelationships);
					
					cmd.CommandText = "select " + Sql.FormatSelectFields(arrSelectFields)
					                + cmd.CommandText;
					if ( nPageSize > 0 )
					{
						Sql.PageResults(cmd, sTABLE_NAME, grdMain.OrderByClause(), nCurrentPageIndex, nPageSize);
					}
					else
					{
						cmd.CommandText += grdMain.OrderByClause();
					}
					
					if ( bDebug )
						RegisterClientScriptBlock("SQLPaged", Sql.ClientScriptBlock(cmd));
					
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						using ( DataTable dt = new DataTable() )
						{
							da.Fill(dt);
							this.ApplyGridViewRules(m_sMODULE + "." + LayoutListView, dt);
							
							vwMain = dt.DefaultView;
							grdMain.DataSource = vwMain ;
						}
					}
				}
			}
		}

		// 10/31/2021 Paul.  Moved ApplyRelationshipView to ModuleUtils. 

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(m_sMODULE + ".LBL_LIST_FORM_TITLE"));
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "list") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				if ( Crm.Config.allow_custom_paging() && Crm.Modules.CustomPaging(m_sMODULE) )
				{
					// 10/09/2018 Paul.  Custom paging was not being enabled. 
					grdMain.AllowCustomPaging = true;
					grdMain.SelectMethod     += new SelectMethodHandler(grdMain_OnSelectMethod);
				}

				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						grdMain.OrderByClause("DATE_MODIFIED", "desc");
						// 03/15/2016 Paul.  We don't use the _List view here because it has an old meaning. 
						cmd.CommandText = "  from vwACTIVITIES" + ControlChars.CrLf;
						Security.Filter(cmd, m_sMODULE, "list");
						ctlSearchView.SqlSearchClause(cmd);
						// 04/04/2016 Paul.  Always filter by parent to ensure pagination works. 
						Guid   gPARENT_ID   = Guid.Empty;
						string sPARENT_TYPE = String.Empty;
						if ( !IsPostBack )
						{
							gPARENT_ID = Sql.ToGuid(Request["PARENT_ID"]);
							if ( !Sql.IsEmptyGuid(gPARENT_ID) )
							{
								string sMODULE      = String.Empty;
								string sPARENT_NAME = String.Empty;
								SqlProcs.spPARENT_Get(ref gPARENT_ID, ref sMODULE, ref sPARENT_TYPE, ref sPARENT_NAME);
								if ( !Sql.IsEmptyGuid(gPARENT_ID) )
								{
									if ( sPARENT_TYPE != "Project" && sPARENT_TYPE != "ProjectTask" )
										sPARENT_TYPE = sMODULE;
									new DynamicControl(ctlSearchView, "PARENT_ID"  ).ID   = gPARENT_ID;
									new DynamicControl(ctlSearchView, "PARENT_NAME").Text = sPARENT_NAME;
									new DynamicControl(ctlSearchView, "PARENT_ID_PARENT_TYPE").SelectedValue = sPARENT_TYPE;
									Sql.AppendParameter(cmd, gPARENT_ID, "PARENT_ID");
								}
							}
						}
						else
						{
							gPARENT_ID   = new DynamicControl(ctlSearchView, "PARENT_ID"            ).ID;
							sPARENT_TYPE = new DynamicControl(ctlSearchView, "PARENT_ID_PARENT_TYPE").SelectedValue;
						}
						// 04/04/2016 Paul.  ApplyRelationshipView will replace default @PARENT_ID with new filter, so it can be called even if parent not specified. 
						bool bIncludeRelationships = Sql.ToBoolean(Request["IncludeRelationships"]);
						// 10/31/2021 Paul.  Moved ApplyRelationshipView to ModuleUtils. 
						ModuleUtils.Activities.ApplyRelationshipView(cmd, sPARENT_TYPE, gPARENT_ID, bIncludeRelationships);
						if ( grdMain.AllowCustomPaging )
						{
							cmd.CommandText = "select count(*)" + ControlChars.CrLf
							                + cmd.CommandText;
							
							if ( bDebug )
								RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));
							
							grdMain.VirtualItemCount = Sql.ToInteger(cmd.ExecuteScalar());
						}
						else
						{
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
									this.ApplyGridViewRules(m_sMODULE + "." + LayoutListView, dt);
							
									vwMain = dt.DefaultView;
									grdMain.DataSource = vwMain ;
								}
							}
						}
					}
				}
				if ( !IsPostBack )
				{
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
			m_sMODULE = "Activities";
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("ID"              );
			arrSelectFields.Add("NAME"            );
			arrSelectFields.Add("DATE_MODIFIED"   );
			arrSelectFields.Add("ACTIVITY_TYPE"   );
			arrSelectFields.Add("ASSIGNED_USER_ID");
			this.AppendGridColumns(grdMain, m_sMODULE + ".PopupView", arrSelectFields);
			ctlDynamicButtons.AppendButtons(m_sMODULE + ".PopupView", Guid.Empty, Guid.Empty);
		}
		#endregion
	}
}

