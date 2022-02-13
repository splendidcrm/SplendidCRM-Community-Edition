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

namespace SplendidCRM.Campaigns
{
	/// <summary>
	/// Summary description for Preview.
	/// </summary>
	public class Preview : SplendidPage
	{
		protected _controls.SearchView     ctlSearchView    ;
		protected _controls.DynamicButtons ctlDynamicButtons;

		protected UniqueStringCollection arrSelectFields;
		protected Guid          gID           ;
		protected DataView      vwMain        ;
		protected SplendidGrid  grdMain       ;

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
				else if ( e.CommandName == "Preview.Production" )
				{
					ViewState["TEST"] = false;
					CAMPAIGNS_BindData(true);
				}
				else if ( e.CommandName == "Preview.Test" )
				{
					ViewState["TEST"] = true;
					CAMPAIGNS_BindData(true);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		protected void CAMPAIGNS_BindData(bool bBind)
		{
			bool bTEST = Sql.ToBoolean(ViewState["TEST"]);
			ctlDynamicButtons.EnableButton("Preview.Production",  bTEST);
			ctlDynamicButtons.EnableButton("Preview.Test"      , !bTEST);

			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				// 02/08/2008 Paul.  We need to build a list of the fields used by the search clause. 
				sSQL = "  from vwCAMPAIGNS_Send          " + ControlChars.CrLf
				     + " where CAMPAIGN_ID = @CAMPAIGN_ID" + ControlChars.CrLf
				     + "   and TEST        = @TEST       " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					// 09/18/2012 Paul.  Campaign emails can take a long time, so make sure not to timeout. 
					cmd.CommandTimeout = 0;
					cmd.CommandText = sSQL;
					// 11/24/2006 Paul.  Use new Security.Filter() function to apply Team and ACL security rules.
					// 03/27/2012 Paul.  We cannot use Security.Filter here because ASSIGNED_USER_ID and TEAM_ID are always NULL. 
					//Security.Filter(cmd, "Campaigns", "list");
					Sql.AddParameter(cmd, "@CAMPAIGN_ID", gID);
					// 09/09/2007 Paul.  AppendParameter is ignoring false values.  Apply the filter manually. 
					// 04/27/2008 Paul.  Fix the boolean AppendParameter by requiring thee IsEmpty flag. 
					// 03/27/2012 Paul.  Test flag was not doing what we expected.  Use AddParameter instead. 
					Sql.AddParameter(cmd, "@TEST", bTEST);
					// 04/27/2008 Paul.  A ListView will need to set and build the order clause in two setps 
					// so that the SavedSearch sort value can be taken into account. 
					grdMain.OrderByClause("RELATED_NAME", "asc");
					ctlSearchView.SqlSearchClause(cmd);
					// 04/27/2008 Paul.  The fields in the search clause need to be prepended after any Saved Search sort has been determined.
					// 12/05/2011 Paul.  Only show distinct as we are now going to remove duplicates by EMAIL1 in spCAMPAIGNS_SendEmail. 
					cmd.CommandText = "select distinct " + Sql.FormatSelectFields(arrSelectFields)
					                + cmd.CommandText
					                + grdMain.OrderByClause();

					if ( bDebug )
						Page.ClientScript.RegisterClientScriptBlock(System.Type.GetType("System.String"), "SQLCode", Sql.ClientScriptBlock(cmd));

					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								if ( bBind )
								{
									// 12/14/2007 Paul.  Only set the default sort if it is not already set.  It may have been set by SearchView. 
									// 04/27/2008 Paul.  Sorting has been moved to the database to increase performance. 
									grdMain.DataBind();
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
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			gID = Sql.ToGuid(Request["ID"]);
			SetPageTitle(L10n.Term("Campaigns.LBL_LIST_FORM_TITLE"));
			try
			{
				if ( !IsPostBack )
				{
					// 01/10/2010 Paul.  Update any dynamic lists before running the campaign. 
					DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						using ( IDbTransaction trn = Sql.BeginTransaction(con) )
						{
							try
							{
								// 02/11/2013 Paul.  We need to use the command object so that we can increase the timeout. 
								//SqlProcs.spCAMPAIGNS_UpdateDynamic(gID);
								using ( IDbCommand cmdCAMPAIGNS_UpdateDynamic = SqlProcs.cmdCAMPAIGNS_UpdateDynamic(con) )
								{
									cmdCAMPAIGNS_UpdateDynamic.Transaction    = trn;
									cmdCAMPAIGNS_UpdateDynamic.CommandTimeout = 0;
									Sql.SetParameter(cmdCAMPAIGNS_UpdateDynamic, "@ID"              , gID             );
									Sql.SetParameter(cmdCAMPAIGNS_UpdateDynamic, "@MODIFIED_USER_ID", Security.USER_ID);
									cmdCAMPAIGNS_UpdateDynamic.ExecuteNonQuery();
								}
								trn.Commit();
							}
							catch
							{
								trn.Rollback();
								throw;
							}
						}
					}

					ViewState["TEST"] = false;
					CAMPAIGNS_BindData(true);
					// 03/11/2008 Paul.  Move the primary binding to SplendidPage. 
					//Page.DataBind();
					// 04/28/2008 Paul.  Make use of dynamic buttons. 
					// 03/27/2012 Paul.  ASSIGNED_USER_ID is always NULL. 
					ctlDynamicButtons.AppendButtons("Campaigns.PreviewView", Guid.Empty, gID);
					
					// 05/16/2010 Paul.  We need to update the buttons after creating them. 
					bool bTEST = Sql.ToBoolean(ViewState["TEST"]);
					ctlDynamicButtons.EnableButton("Preview.Production",  bTEST);
					ctlDynamicButtons.EnableButton("Preview.Test"      , !bTEST);
				}
				else
				{
					// 03/27/2012 Paul.  The SQL is not being displayed properly when the buttons are pressed, likely due to the registration being called twice. 
					// By only binding if neither button is pressed it will save us from two binding events. 
					Button btnPREVIEW_TEST       = ctlDynamicButtons.FindControl("btnPREVIEW_TEST"      ) as Button;
					Button btnPREVIEW_PRODUCTION = ctlDynamicButtons.FindControl("btnPREVIEW_PRODUCTION") as Button;
					string sPREVIEW_TEST       = String.Empty;
					string sPREVIEW_PRODUCTION = String.Empty;
					if ( btnPREVIEW_TEST       != null ) sPREVIEW_TEST       = btnPREVIEW_TEST.UniqueID;
					if ( btnPREVIEW_PRODUCTION != null ) sPREVIEW_PRODUCTION = btnPREVIEW_PRODUCTION.UniqueID;
					if ( Request.Form[sPREVIEW_TEST] == null && Request.Form[sPREVIEW_PRODUCTION] == null )
						CAMPAIGNS_BindData(false);
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
			// 02/08/2008 Paul.  We need to build a list of the fields used by the search clause. 
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("RELATED_NAME");
			// 07/26/2007 Paul.  Use the new PopupView so that the view is customizable. 
			this.AppendGridColumns(grdMain, "Campaigns.PreviewView", arrSelectFields);
			// 04/28/2008 Paul.  Make use of dynamic buttons. 
			if ( IsPostBack )
				ctlDynamicButtons.AppendButtons("Campaigns.PreviewView", Guid.Empty, Guid.Empty);
		}
		#endregion
	}
}

