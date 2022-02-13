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

namespace SplendidCRM.Activities
{
	/// <summary>
	///		Summary description for MyActivities.
	/// </summary>
	public class MyActivities : DashletControl
	{
		protected MyActivitiesHeader     ctlDashletHeader ;
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
				if ( e.CommandName == "Remove" )
				{
					if ( !Sql.IsEmptyString(sDetailView) )
					{
						// 02/22/2010 Paul.  Module is Activities and not Calls. 
						SqlProcs.spDASHLETS_USERS_InitDisable(Security.USER_ID, sDetailView, "Activities", this.AppRelativeVirtualPath.Substring(0, this.AppRelativeVirtualPath.Length-5));
						SplendidCache.ClearUserDashlets(sDetailView);
						Response.Redirect(Page.AppRelativeVirtualPath + Request.Url.Query);
					}
				}
				else
				{
					Guid gID = Sql.ToGuid(e.CommandArgument);
					switch ( e.CommandName )
					{
						case "Activity.Accept"   :  SqlProcs.spACTIVITIES_UpdateStatus(gID, Security.USER_ID, "Accept"   );  break;
						case "Activity.Tentative":  SqlProcs.spACTIVITIES_UpdateStatus(gID, Security.USER_ID, "Tentative");  break;
						case "Activity.Decline"  :  SqlProcs.spACTIVITIES_UpdateStatus(gID, Security.USER_ID, "Decline"  );  break;
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
				vwFields.RowFilter = "CONTROL_NAME = '~/Activities/MyActivities'";
				this.Visible = vwFields.Count > 0;
			}
			*/
			if ( !this.Visible )
				return;

			if ( !IsPostBack )
			{
				ctlDashletHeader.THROUGH.DataSource =  SplendidCache.List("appointment_filter_dom");
				ctlDashletHeader.THROUGH.DataBind();
			}
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

		protected void Bind(bool bBind)
		{
			// 05/07/2018 Paul.  We need to detect the THROUGH change. 
			if ( ctlDashletHeader.THROUGH.SelectedValue != Sql.ToString(ViewState["Last.THROUGH"]) )
			{
				ViewState["Last.THROUGH"] = ctlDashletHeader.THROUGH.SelectedValue;
				grdMain.CurrentPageIndex = 0;
				bBind = true;
			}

			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				// 04/04/2006 Paul.  Start with today in ZoneTime and not ServerTime. 
				DateTime dtZONE_NOW   = T10n.FromUniversalTime(DateTime.Now.ToUniversalTime());
				DateTime dtZONE_TODAY = new DateTime(dtZONE_NOW.Year, dtZONE_NOW.Month, dtZONE_NOW.Day);
				DateTime dtDATE_START = dtZONE_TODAY;
				switch ( ctlDashletHeader.THROUGH.SelectedValue )
				{
					case "today"          :  dtDATE_START = dtZONE_TODAY;  break;
					case "tomorrow"       :  dtDATE_START = dtDATE_START.AddDays(1);  break;
					case "this Saturday"  :  dtDATE_START = dtDATE_START.AddDays(DayOfWeek.Saturday-dtDATE_START.DayOfWeek);  break;
					case "next Saturday"  :  dtDATE_START = dtDATE_START.AddDays(DayOfWeek.Saturday-dtDATE_START.DayOfWeek).AddDays(7);  break;
					case "last this_month":  dtDATE_START = new DateTime(dtZONE_TODAY.Year, dtZONE_TODAY.Month, DateTime.DaysInMonth(dtZONE_TODAY.Year, dtZONE_TODAY.Month));  break;
					case "last next_month":  dtDATE_START = new DateTime(dtZONE_TODAY.Year, dtZONE_TODAY.Month, DateTime.DaysInMonth(dtZONE_TODAY.Year, dtZONE_TODAY.Month)).AddMonths(1);  break;
				}
				
				// 04/04/2006 Paul.  Now that we are using ZoneTime, we don't need to convert it to server time when displaying the date. 
				ctlDashletHeader.THROUGH_TEXT = "(" + Sql.ToDateString(dtDATE_START) + ")";
				// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
				m_sVIEW_NAME = "vwACTIVITIES_MyList";
				sSQL = "select " + Sql.FormatSelectFields(arrSelectFields)
				     + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
				     + "  from " + m_sVIEW_NAME + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					// 11/24/2006 Paul.  Use new Security.Filter() function to apply Team and ACL security rules.
					Security.Filter(cmd, m_sMODULE, "list");
					// 06/23/2018 Paul.  Need to allow multiple users to see the data they are assigned to. 
					if ( Crm.Config.enable_dynamic_assignment() )
						cmd.CommandText += "   and ASSIGNED_SET_LIST like '%" + Security.USER_ID.ToString() + "%'" + ControlChars.CrLf;
					else
						Sql.AppendParameter(cmd, Security.USER_ID, "ASSIGNED_USER_ID", false);
					cmd.CommandText += "   and DATE_START < @DATE_START" + ControlChars.CrLf;
					// 04/04/2006 Paul.  DATE_START is not including all records for today. 
					// 04/04/2006 Paul.  Instead of using DATE_START <= @DATE_START, change to DATE_START < @DATE_START and increase the start date to tomorrow. 
					// 04/04/2006 Paul.  Here we do need to convert it to ServerTime because that is all that the database understands. 
					Sql.AddParameter(cmd, "@DATE_START", T10n.ToServerTime(dtDATE_START.AddDays(1)));
					// 04/26/2008 Paul.  Move Last Sort to the database.
					cmd.CommandText += grdMain.OrderByClause("DATE_START", "asc");

					if ( bDebug )
						RegisterClientScriptBlock("vwACTIVITIES_MyList", Sql.ClientScriptBlock(cmd));

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
								// 09/15/2005 Paul. We must always bind, otherwise a Dashboard refresh will display the grid with empty rows. 
								// 04/25/2008 Paul.  Enable sorting of sub panel. 
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
			if ( !IsPostBack )
			{
				// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
				//Page.DataBind();
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
			ctlDashletHeader.Command += new CommandEventHandler(Page_Command);
			// 11/25/2006 Paul.  At some point we will need to stop using vwACTIVITIES_MyList
			// and apply security to Calls and Meetings separtely.  For now, just treat all activities as Calls. 
			m_sMODULE = "Calls";
			// 02/08/2008 Paul.  We need to build a list of the fields used by the search clause. 
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("DATE_START"      );
			// 11/23/2009 Paul.  ACTIVITY_TYPE, ACCEPT_STATUS and ASSIGNED_USER_ID are used in the grid, so we need to manually add them. 
			arrSelectFields.Add("ACTIVITY_TYPE"   );
			arrSelectFields.Add("ACCEPT_STATUS"   );
			arrSelectFields.Add("ASSIGNED_USER_ID");
			this.AppendGridColumns(grdMain, "Activities.MyActivities", arrSelectFields);
		}
		#endregion
	}
}

