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
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Administration.Schedulers
{
	/// <summary>
	/// Summary description for DetailView.
	/// </summary>
	public class DetailView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons ctlDynamicButtons;

		protected Guid    gID            ;
		protected Label   JOB            ;
		protected Label   STATUS         ;
		protected Label   DATE_TIME_START;
		protected Label   TIME_FROM      ;
		protected Label   DATE_TIME_END  ;
		protected Label   TIME_TO        ;
		protected Label   LAST_RUN       ;
		protected Label   JOB_INTERVAL   ;
		protected Label   CATCH_UP       ;
		protected Label   DATE_ENTERED   ;
		protected Label   DATE_MODIFIED  ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Edit" )
				{
					Response.Redirect("edit.aspx?ID=" + gID.ToString());
				}
				else if ( e.CommandName == "Duplicate" )
				{
					Response.Redirect("edit.aspx?DuplicateID=" + gID.ToString());
				}
				else if ( e.CommandName == "Delete" )
				{
					SqlProcs.spSCHEDULERS_Delete(gID);
					Response.Redirect("default.aspx");
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList.Schedulers"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "view") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			try
			{
				gID = Sql.ToGuid(Request["ID"]);
				// 11/28/2005 Paul.  We must always populate the table, otherwise it will disappear during event processing. 
				// 03/19/2008 Paul.  Place AppendDetailViewFields inside OnInit to avoid having to re-populate the data. 
				if ( !IsPostBack )
				{
					if ( !Sql.IsEmptyGuid(gID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							sSQL = "select *           " + ControlChars.CrLf
							     + "  from vwSCHEDULERS" + ControlChars.CrLf
							     + " where ID = @ID    " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@ID", gID);
								con.Open();

								if ( bDebug )
									RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

								// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dtCurrent = new DataTable() )
									{
										da.Fill(dtCurrent);
										if ( dtCurrent.Rows.Count > 0 )
										{
											DataRow rdr = dtCurrent.Rows[0];
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList.Schedulers") + " - " + ctlDynamicButtons.Title);
											
											string   sJOB_INTERVAL     = Sql.ToString  (rdr["JOB_INTERVAL"   ]);
											DateTime dtDATE_TIME_START = Sql.ToDateTime(rdr["DATE_TIME_START"]);
											DateTime dtDATE_TIME_END   = Sql.ToDateTime(rdr["DATE_TIME_END"  ]);
											DateTime dtTIME_FROM       = Sql.ToDateTime(rdr["TIME_FROM"      ]);
											DateTime dtTIME_TO         = Sql.ToDateTime(rdr["TIME_TO"        ]);
											DateTime dtLAST_RUN        = Sql.ToDateTime(rdr["LAST_RUN"       ]);
											JOB            .Text = Sql.ToString(rdr["JOB"   ]);
											STATUS         .Text = Sql.ToString(L10n.Term(".scheduler_status_dom.", rdr["STATUS"]));
											DATE_TIME_START.Text = (dtDATE_TIME_START == DateTime.MinValue) ? L10n.Term("Schedulers.LBL_PERENNIAL") : T10n.FromServerTime(dtDATE_TIME_START).ToString();
											DATE_TIME_END  .Text = (dtDATE_TIME_END   == DateTime.MinValue) ? L10n.Term("Schedulers.LBL_PERENNIAL") : T10n.FromServerTime(dtDATE_TIME_END  ).ToString();
											LAST_RUN       .Text = (dtLAST_RUN        == DateTime.MinValue) ? L10n.Term("Schedulers.LBL_NEVER"    ) : T10n.FromServerTime(dtLAST_RUN       ).ToString();
											TIME_FROM      .Text = (dtTIME_FROM       == DateTime.MinValue) ? L10n.Term("Schedulers.LBL_ALWAYS"   ) : dtTIME_FROM.ToShortTimeString();
											TIME_TO        .Text = (dtTIME_TO         == DateTime.MinValue) ? L10n.Term("Schedulers.LBL_ALWAYS"   ) : dtTIME_TO  .ToShortTimeString();
											CATCH_UP       .Text = Sql.ToBoolean(rdr["CATCH_UP"])           ? L10n.Term("Schedulers.LBL_ALWAYS"   ) : L10n.Term("Schedulers.LBL_NEVER");
											JOB_INTERVAL   .Text = sJOB_INTERVAL + "<br>" + SchedulerUtils.CronDescription(L10n, sJOB_INTERVAL);
											DATE_ENTERED   .Text = T10n.FromServerTime(Sql.ToDateTime(rdr["DATE_ENTERED" ])).ToString() + " " + L10n.Term(".LBL_BY") + " " + Sql.ToString(rdr["CREATED_BY" ]);
											DATE_MODIFIED  .Text = T10n.FromServerTime(Sql.ToDateTime(rdr["DATE_MODIFIED"])).ToString() + " " + L10n.Term(".LBL_BY") + " " + Sql.ToString(rdr["MODIFIED_BY"]);
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, rdr);
										}
										else
										{
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
										}
									}
								}
							}
						}
					}
					else
					{
						// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
						ctlDynamicButtons.DisableAll();
						//ctlDynamicButtons.ErrorText = L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + "ID";
					}
				}
				// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
				//Page.DataBind();
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
			m_sMODULE = "Schedulers";
			// 05/06/2010 Paul.  The menu will show the admin Module Name in the Six theme. 
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
			}
		}
		#endregion
	}
}

