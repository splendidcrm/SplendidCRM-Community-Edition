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

namespace SplendidCRM.Meetings
{
	/// <summary>
	///		Summary description for MyMeetings.
	/// </summary>
	public class MyMeetings : DashletControl
	{
		protected _controls.DashletHeader  ctlDashletHeader ;
		protected _controls.SearchView   ctlSearchView  ;

		protected UniqueStringCollection arrSelectFields;
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected Label         lblError       ;
		protected bool          bShowEditDialog = false;

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
				else if ( e.CommandName.StartsWith("Activity.") )
				{
					Guid gID = Sql.ToGuid(e.CommandArgument);
					switch ( e.CommandName )
					{
						// 12/26/2012 Paul.  Oracle is case-significant, so use lower case status values. 
						case "Activity.Accept"   :  SqlProcs.spACTIVITIES_UpdateStatus(gID, Security.USER_ID, "accept"   );  break;
						case "Activity.Tentative":  SqlProcs.spACTIVITIES_UpdateStatus(gID, Security.USER_ID, "tentative");  break;
						case "Activity.Decline"  :  SqlProcs.spACTIVITIES_UpdateStatus(gID, Security.USER_ID, "decline"  );  break;
					}
					// 08/31/2006 Paul.  Instead of redirecting, which we prefer, we are going to bind again
					// so that the THROUGH dropdown will not get reset. 
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
				// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
				m_sVIEW_NAME = "vwMEETINGS_MyList";
				sSQL = "  from " + m_sVIEW_NAME + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					// 11/24/2006 Paul.  Use new Security.Filter() function to apply Team and ACL security rules.
					Security.Filter(cmd, m_sMODULE, "list");
					// 06/21/2009 Paul.  Apply Search filter. 
					grdMain.OrderByClause("DATE_START", "desc");
					// 06/27/2009 Paul.  Only apply Assigned default if no search was loaded. 
					if ( !ctlSearchView.SqlSearchClause(cmd) )
					{
						// 06/23/2018 Paul.  Need to allow multiple users to see the data they are assigned to. 
						if ( Crm.Config.enable_dynamic_assignment() )
							cmd.CommandText += "   and ASSIGNED_SET_LIST like '%" + Security.USER_ID.ToString() + "%'" + ControlChars.CrLf;
						else
							Sql.AppendParameter(cmd, Security.USER_ID, "ASSIGNED_USER_ID", false);
						// 06/27/2009 Paul.  It is too late to use the SearchView to specify the assigned, but we can select the user for future searches. 
						ListBox lstASSIGNED_USER_ID = ctlSearchView.FindControl("ASSIGNED_USER_ID") as ListBox;
						if ( lstASSIGNED_USER_ID != null )
						{
							Utils.SelectItem(lstASSIGNED_USER_ID, Security.USER_ID.ToString());
						}
					}
					cmd.CommandText = "select " + Sql.FormatSelectFields(arrSelectFields)
					                + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
					                + cmd.CommandText
					                + grdMain.OrderByClause();

					if ( bDebug )
						RegisterClientScriptBlock("vwMEETINGS_List", Sql.ClientScriptBlock(cmd));

					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								// 03/07/2013 Paul.  Apply business rules to subpanel. 
								this.ApplyGridViewRules(m_sMODULE + ".MyMeetings", dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								// 09/15/2005 Paul. We must always bind, otherwise a Dashboard refresh will display the grid with empty rows. 
								// 04/26/2008 Paul.  Move Last Sort to the database.
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
			// 09/09/2006 Paul.  Visibility is already controlled by the ASPX page, 
			// but since this control is used on the home page, we need to apply the module specific rules. 
			// 11/05/2007 Paul.  Don't show panel if it was manually hidden. 
			this.Visible = this.Visible && (SplendidCRM.Security.GetUserAccess(m_sMODULE, "list") >= 0);
			// 09/09/2007 Paul.  We are having trouble dynamically adding user controls to the WebPartZone. 
			// Instead, control visibility manually here.  This approach as the added benefit of hiding the 
			// control even if the WebPartManager has moved it to an alternate zone. 
			// 07/10/2009 Paul.  The end-user will be able to hide or show the Dashlet controls. 
			/*
			if ( this.Visible && !Sql.IsEmptyString(sDetailView) )
			{
				// 01/17/2008 Paul.  We need to use the sDetailView property and not the hard-coded view name. 
				DataView vwFields = new DataView(SplendidCache.DetailViewRelationships(sDetailView));
				vwFields.RowFilter = "CONTROL_NAME = '~/Meetings/MyMeetings'";
				this.Visible = vwFields.Count > 0;
			}
			*/
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
			this.Load += new System.EventHandler(this.Page_Load);
			ctlDashletHeader.Command += new CommandEventHandler(Page_Command);
			ctlSearchView.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Meetings";
			// 12/05/2005 Paul.  Add fields early so that sort events will get called. 
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("ID"              );
			arrSelectFields.Add("ASSIGNED_USER_ID");
			arrSelectFields.Add("DATE_START"      );
			arrSelectFields.Add("DURATION_HOURS"  );
			arrSelectFields.Add("DURATION_MINUTES");
			arrSelectFields.Add("ACCEPT_STATUS"   );
			this.AppendGridColumns(grdMain, m_sMODULE + ".MyMeetings", arrSelectFields);
		}
		#endregion
	}
}

