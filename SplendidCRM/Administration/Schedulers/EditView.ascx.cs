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
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Administration.Schedulers
{
	/// <summary>
	///		Summary description for EditView.
	/// </summary>
	public class EditView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		// 01/13/2010 Paul.  Add footer buttons. 
		protected _controls.DynamicButtons ctlFooterButtons ;
		protected _controls.CRON           ctlCRON          ;

		protected Guid         gID            ;
		protected TextBox      NAME           ;
		protected DropDownList STATUS         ;
		protected DropDownList JOB            ;
		protected CheckBox     CATCH_UP       ;

		protected _controls.DateTimePicker DATE_TIME_START;
		protected _controls.DateTimePicker DATE_TIME_END  ;
		protected _controls.TimePicker     TIME_FROM      ;
		protected _controls.TimePicker     TIME_TO        ;

		protected RequiredFieldValidator NAME_REQUIRED;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Save" )
			{
				NAME.Text = NAME.Text.Trim();
				NAME_REQUIRED.Enabled = true;
				NAME_REQUIRED.Validate();
				if ( Page.IsValid )
				{
					try
					{
						// 07/15/2010 Paul.  Use new CRON control. 
						ctlCRON.Validate();
						string sJOB_INTERVAL = ctlCRON.Value;
						SqlProcs.spSCHEDULERS_Update(ref gID, NAME.Text, JOB.SelectedValue, DATE_TIME_START.Value, DATE_TIME_END.Value, sJOB_INTERVAL, TIME_FROM.Value, TIME_TO.Value, STATUS.SelectedValue, CATCH_UP.Checked);
					}
					catch(Exception ex)
					{
						ctlDynamicButtons.ErrorText = ex.Message;
						return;
					}
					Response.Redirect("view.aspx?ID=" + gID.ToString());
				}
			}
			else if ( e.CommandName == "Cancel" )
			{
				Response.Redirect("default.aspx");
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList.Schedulers"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			NAME_REQUIRED.DataBind();
			try
			{
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
					ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
					ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);

					STATUS.DataSource = SplendidCache.List("scheduler_status_dom");
					STATUS.DataBind();
					// 03/26/2019 Paul.  Scheduler list so that it can be returned by REST API. 
					//foreach ( string sJob in SchedulerUtils.Jobs )
					//{
					//	JOB.Items.Add(new ListItem(sJob, "function::" + sJob));
					//}
					SplendidCache.SetListSource("SchedulerJobs", JOB);
					JOB.DataBind();

					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
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
								if ( !Sql.IsEmptyGuid(gDuplicateID) )
								{
									Sql.AddParameter(cmd, "@ID", gDuplicateID);
									gID = Guid.Empty;
								}
								else
								{
									Sql.AddParameter(cmd, "@ID", gID);
								}
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
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;

											NAME    .Text    = Sql.ToString (rdr["NAME"    ]);
											CATCH_UP.Checked = Sql.ToBoolean(rdr["CATCH_UP"]);

											string sJOB_INTERVAL = Sql.ToString(rdr["JOB_INTERVAL"]);
											// 07/15/2010 Paul.  Use new CRON control. 
											ctlCRON.Value = sJOB_INTERVAL;

											if ( rdr["DATE_TIME_START"] != DBNull.Value ) DATE_TIME_START.Value = T10n.FromServerTime(Sql.ToDateTime(rdr["DATE_TIME_START"]));
											if ( rdr["DATE_TIME_END"  ] != DBNull.Value ) DATE_TIME_END  .Value = T10n.FromServerTime(Sql.ToDateTime(rdr["DATE_TIME_END"  ]));
											// 12/31/2007 Paul.  TIME_FROM and TIME_TO are just time components, so they should not be translated. 
											if ( rdr["TIME_FROM"      ] != DBNull.Value ) TIME_FROM      .Value = Sql.ToDateTime(rdr["TIME_FROM"]);
											if ( rdr["TIME_TO"        ] != DBNull.Value ) TIME_TO        .Value = Sql.ToDateTime(rdr["TIME_TO"  ]);
											try
											{
												// 08/19/2010 Paul.  Check the list before assigning the value. 
												Utils.SetSelectedValue(JOB, Sql.ToString(rdr["JOB"]));
											}
											catch(Exception ex)
											{
												SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
											}
											try
											{
												// 08/19/2010 Paul.  Check the list before assigning the value. 
												Utils.SetSelectedValue(STATUS, Sql.ToString(rdr["STATUS"]));
											}
											catch(Exception ex)
											{
												SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
											}
										}
									}
								}
							}
						}
					}
				}
				else
				{
					// 12/02/2005 Paul.  When validation fails, the header title does not retain its value.  Update manually. 
					// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					SetPageTitle(L10n.Term(".moduleList.Schedulers") + " - " + ctlDynamicButtons.Title);
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
			// CODEGEN: This Task is required by the ASP.NET Web Form Designer.
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
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			ctlFooterButtons .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Schedulers";
			// 05/06/2010 Paul.  The menu will show the admin Module Name in the Six theme. 
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
			}
		}
		#endregion
	}
}

