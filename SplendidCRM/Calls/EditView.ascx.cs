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
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using SplendidCRM._controls;

namespace SplendidCRM.Calls
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

		protected Guid            gID                          ;
		protected HtmlTable       tblMain                      ;
		protected PlaceHolder     plcSubPanel                  ;

		protected InviteesView    ctlInviteesView              ;
		protected HiddenField     txtINVITEE_ID                ;

		protected Activities.SchedulingGrid ctlSchedulingGrid  ;
		//protected _controls.DateTimePicker  ctlDATE_START      ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			// 08/21/2005 Paul.  Redirect to parent if that is where the note was originated. 
			Guid   gPARENT_ID   = Sql.ToGuid(Request["PARENT_ID"]);
			string sMODULE      = String.Empty;
			string sPARENT_TYPE = String.Empty;
			string sPARENT_NAME = String.Empty;
			try
			{
				SqlProcs.spPARENT_Get(ref gPARENT_ID, ref sMODULE, ref sPARENT_TYPE, ref sPARENT_NAME);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				// The only possible error is a connection failure, so just ignore all errors. 
				gPARENT_ID = Guid.Empty;
			}
			// 12/26/2012 Paul.  Add send invites button. 
			// 03/15/2014 Paul.  Enable override of concurrency error. 
			if ( e.CommandName == "Save" || e.CommandName == "SaveConcurrency" || e.CommandName == "Save.SendInvites" )
			{
				try
				{
					/*
					DateTimePicker ctlDATE_START = FindControl("DATE_START") as DateTimePicker;
					if ( ctlDATE_START != null )
						ctlDATE_START.Validate();
					*/
					// 01/16/2006 Paul.  Enable validator before validating page. 
					this.ValidateEditViewFields(m_sMODULE + "." + LayoutEditView);
					// 11/10/2010 Paul.  Apply Business Rules. 
					this.ApplyEditViewValidationEventRules(m_sMODULE + "." + LayoutEditView);
					
					// 04/19/2010 Paul.  We now need to validate the sub panels as they can contain an inline NewRecord control. 
					if ( plcSubPanel.Visible )
					{
						foreach ( Control ctl in plcSubPanel.Controls )
						{
							InlineEditControl ctlSubPanel = ctl as InlineEditControl;
							if ( ctlSubPanel != null )
							{
								ctlSubPanel.ValidateEditViewFields();
							}
						}
					}
					if ( Page.IsValid )
					{
						// 09/09/2009 Paul.  Use the new function to get the table name. 
						string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
						DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
							DataRow   rowCurrent = null;
							DataTable dtCurrent  = new DataTable();
							if ( !Sql.IsEmptyGuid(gID) )
							{
								string sSQL ;
								sSQL = "select *"               + ControlChars.CrLf
								     + "  from " + m_sVIEW_NAME + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Security.Filter(cmd, m_sMODULE, "edit");
									Sql.AppendParameter(cmd, gID, "ID", false);
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										da.Fill(dtCurrent);
										if ( dtCurrent.Rows.Count > 0 )
										{
											rowCurrent = dtCurrent.Rows[0];
											// 12/09/2008 Paul.  Throw an exception if the record has been edited since the last load. 
											DateTime dtLAST_DATE_MODIFIED = Sql.ToDateTime(ViewState["LAST_DATE_MODIFIED"]);
											// 03/15/2014 Paul.  Enable override of concurrency error. 
											if ( Sql.ToBoolean(Application["CONFIG.enable_concurrency_check"])  && (e.CommandName != "SaveConcurrency") && dtLAST_DATE_MODIFIED != DateTime.MinValue && Sql.ToDateTime(rowCurrent["DATE_MODIFIED"]) > dtLAST_DATE_MODIFIED )
											{
												ctlDynamicButtons.ShowButton("SaveConcurrency", true);
												ctlFooterButtons .ShowButton("SaveConcurrency", true);
												throw(new Exception(String.Format(L10n.Term(".ERR_CONCURRENCY_OVERRIDE"), dtLAST_DATE_MODIFIED)));
											}
										}
										else
										{
											// 11/19/2007 Paul.  If the record is not found, clear the ID so that the record cannot be updated.
											// It is possible that the record exists, but that ACL rules prevent it from being selected. 
											gID = Guid.Empty;
										}
									}
								}
							}

							// 11/10/2010 Paul.  Apply Business Rules. 
							this.ApplyEditViewPreSaveEventRules(m_sMODULE + "." + LayoutEditView, rowCurrent);
							
							// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
									// 12/29/2007 Paul.  TEAM_ID is now in the stored procedure. 
									// 12/26/2012 Paul.  Add EMAIL_REMINDER_TIME. 
									// 03/07/2013 Paul.  Add ALL_DAY_EVENT. 
									bool bALL_DAY_EVENT = new DynamicControl(this, rowCurrent, "ALL_DAY_EVENT").Checked;
									if ( bALL_DAY_EVENT )
									{
										DateTimePicker DATE_START = FindControl("DATE_START") as DateTimePicker;
										if ( DATE_START != null )
										{
											DropDownList lstHOUR     = DATE_START.FindControl("lstHOUR"    ) as DropDownList;
											DropDownList lstMINUTE   = DATE_START.FindControl("lstMINUTE"  ) as DropDownList;
											DropDownList lstMERIDIEM = DATE_START.FindControl("lstMERIDIEM") as DropDownList;
											lstHOUR    .SelectedIndex = 0;
											lstMINUTE  .SelectedIndex = 0;
											lstMERIDIEM.SelectedIndex = 0;
										}
									}
									// 03/20/2013 Paul.  Add REPEAT fields. 
									// 12/23/2013 Paul.  Add SMS_REMINDER_TIME. 
									string sREPEAT_TYPE = new DynamicControl(this, rowCurrent, "REPEAT_TYPE").SelectedValue;
									SqlProcs.spCALLS_Update(ref gID
										, new DynamicControl(this, rowCurrent, "ASSIGNED_USER_ID"   ).ID
										, new DynamicControl(this, rowCurrent, "NAME"               ).Text
										,(bALL_DAY_EVENT ? 24 : new DynamicControl(this, rowCurrent, "DURATION_HOURS"  ).IntegerValue)
										,(bALL_DAY_EVENT ?  0 : new DynamicControl(this, rowCurrent, "DURATION_MINUTES").IntegerValue)
										, new DynamicControl(this, rowCurrent, "DATE_START"         ).DateValue
										// 02/04/2011 Paul.  We gave the PARENT_TYPE a unique name, but we need to update all EditViews and NewRecords. 
										, new DynamicControl(this, rowCurrent, "PARENT_ID_PARENT_TYPE").SelectedValue
										, new DynamicControl(this, rowCurrent, "PARENT_ID"          ).ID
										, new DynamicControl(this, rowCurrent, "STATUS"             ).SelectedValue
										, new DynamicControl(this, rowCurrent, "DIRECTION"          ).SelectedValue
										,(new DynamicControl(this, rowCurrent, "SHOULD_REMIND"      ).Checked ? new DynamicControl(this, "REMINDER_TIME").IntegerValue : -1)
										, new DynamicControl(this, rowCurrent, "DESCRIPTION"        ).Text
										, txtINVITEE_ID.Value
										, new DynamicControl(this, rowCurrent, "TEAM_ID"            ).ID
										, new DynamicControl(this, rowCurrent, "TEAM_SET_LIST"      ).Text
										,(new DynamicControl(this, rowCurrent, "EMAIL_REMINDER_TIME").IntegerValue > 0 ? new DynamicControl(this, rowCurrent, "EMAIL_REMINDER_TIME").IntegerValue : -1)
										, bALL_DAY_EVENT
										, sREPEAT_TYPE
										,(sREPEAT_TYPE == String.Empty ? 0                 : new DynamicControl(this, rowCurrent, "REPEAT_INTERVAL"    ).IntegerValue)
										,(sREPEAT_TYPE != "Weekly"     ? String.Empty      : new DynamicControl(this, rowCurrent, "REPEAT_DOW"         ).Text        )
										,(sREPEAT_TYPE == String.Empty ? DateTime.MinValue : new DynamicControl(this, rowCurrent, "REPEAT_UNTIL"       ).DateValue   )
										,(sREPEAT_TYPE == String.Empty ? 0                 : new DynamicControl(this, rowCurrent, "REPEAT_COUNT"       ).IntegerValue)
										,(new DynamicControl(this, rowCurrent, "SMS_REMINDER_TIME"  ).IntegerValue > 0 ? new DynamicControl(this, rowCurrent, "SMS_REMINDER_TIME").IntegerValue : -1)
										// 05/17/2017 Paul.  Add Tags module. 
										, new DynamicControl(this, rowCurrent, "TAG_SET_NAME"       ).Text
										// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
										, new DynamicControl(this, rowCurrent, "IS_PRIVATE"         ).Checked
										// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
										, new DynamicControl(this, rowCurrent, "ASSIGNED_SET_LIST"  ).Text
										, trn
										);
									SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
									// 08/26/2010 Paul.  Add new record to tracker. 
									// 03/08/2012 Paul.  Add ACTION to the tracker table so that we can create quick user activity reports. 
									SqlProcs.spTRACKER_Update
										( Security.USER_ID
										, m_sMODULE
										, gID
										, new DynamicControl(this, rowCurrent, "NAME").Text
										, "save"
										, trn
										);
									if ( plcSubPanel.Visible )
									{
										// 01/27/2010 Paul.  The SubPanel can now have state that needs to be saved. 
										foreach ( Control ctl in plcSubPanel.Controls )
										{
											InlineEditControl ctlSubPanel = ctl as InlineEditControl;
											if ( ctlSubPanel != null )
											{
												ctlSubPanel.Save(gID, m_sMODULE, trn);
											}
										}
									}
									trn.Commit();
									// 04/03/2012 Paul.  Just in case the name changes, clear the favorites. 
									SplendidCache.ClearFavorites();
									// 06/10/2017 Paul.  We need to clear the reminders just in case the changed. 
									SplendidCache.ClearUserReminders();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									ctlDynamicButtons.ErrorText = ex.Message;
									return;
								}
							}
							// 11/10/2010 Paul.  Apply Business Rules. 
							// 12/10/2012 Paul.  Provide access to the item data. 
							rowCurrent = Crm.Modules.ItemEdit(m_sMODULE, gID);
							// 12/26/2012 Paul.  Add send invites button. 
							if ( e.CommandName == "Save.SendInvites" )
							{
								// 12/26/2012 Paul.  Update the last modified to prevent a concurrency error if the user tries to save again. 
								ViewState["LAST_DATE_MODIFIED"] = Sql.ToDateTime(rowCurrent["DATE_MODIFIED"]);
								EmailUtils.SendActivityInvites(gID);
							}
							this.ApplyEditViewPostSaveEventRules(m_sMODULE + "." + LayoutEditView, rowCurrent);
						}
						
						if ( !Sql.IsEmptyString(RulesRedirectURL) )
							Response.Redirect(RulesRedirectURL);
						else if ( !Sql.IsEmptyGuid(gPARENT_ID) )
							Response.Redirect("~/" + sMODULE + "/view.aspx?ID=" + gPARENT_ID.ToString());
						else
							Response.Redirect("view.aspx?ID=" + gID.ToString());
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					ctlDynamicButtons.ErrorText = ex.Message;
				}
			}
			else if ( e.CommandName == "Cancel" )
			{
				if ( !Sql.IsEmptyGuid(gPARENT_ID) )
					Response.Redirect("~/" + sMODULE + "/view.aspx?ID=" + gPARENT_ID.ToString());
				else if ( Sql.IsEmptyGuid(gID) )
					Response.Redirect("default.aspx");
				else
					Response.Redirect("view.aspx?ID=" + gID.ToString());
			}
			else if ( e.CommandName == "Invitees.Add" )
			{
				if ( txtINVITEE_ID.Value.Length > 0 )
					txtINVITEE_ID.Value += ",";
				txtINVITEE_ID.Value += e.CommandArgument;
				ctlInviteesView.INVITEES = txtINVITEE_ID.Value.Split(',');
				// 04/07/2014 Paul.  When adding or removing a user to a call or meeting, we also need to add the private team to the dynamic teams. 
				if ( Crm.Config.enable_team_management() && Crm.Config.enable_dynamic_teams() )
				{
					try
					{
						Guid gPRIVATE_TEAM_ID = Crm.Users.PRIVATE_TEAM_ID(Sql.ToGuid(e.CommandArgument));
						if ( !Sql.IsEmptyGuid(gPRIVATE_TEAM_ID) )
						{
							SplendidCRM._controls.TeamSelect ctlTEAM_SET_NAME = this.FindControl("TEAM_SET_NAME") as SplendidCRM._controls.TeamSelect;
							if ( ctlTEAM_SET_NAME != null )
							{
								ctlTEAM_SET_NAME.AddTeam(gPRIVATE_TEAM_ID);
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						ctlDynamicButtons.ErrorText = ex.Message;
					}
				}
				BindSchedule();
			}
			else if ( e.CommandName == "Invitees.Delete" )
			{
				string sDELETE_ID = e.CommandArgument.ToString().ToLower();
				string[] arrINVITEES = txtINVITEE_ID.Value.Split(',');
				StringBuilder sb = new StringBuilder();
				foreach(string sINVITEE_ID in arrINVITEES)
				{
					if ( sINVITEE_ID != sDELETE_ID )
					{
						if ( sb.Length > 0 )
							sb.Append(",");
						sb.Append(sINVITEE_ID);
					}
				}
				txtINVITEE_ID.Value = sb.ToString();
				ctlInviteesView.INVITEES = txtINVITEE_ID.Value.Split(',');
				// 04/07/2014 Paul.  When adding or removing a user to a call or meeting, we also need to add the private team to the dynamic teams. 
				if ( Crm.Config.enable_team_management() && Crm.Config.enable_dynamic_teams() )
				{
					try
					{
						Guid gPRIVATE_TEAM_ID = Crm.Users.PRIVATE_TEAM_ID(Sql.ToGuid(e.CommandArgument));
						// 04/07/2014 Paul.  Do not automatically remove the private team of the current user. 
						if ( !Sql.IsEmptyGuid(gPRIVATE_TEAM_ID) && gPRIVATE_TEAM_ID != Security.TEAM_ID )
						{
							SplendidCRM._controls.TeamSelect ctlTEAM_SET_NAME = this.FindControl("TEAM_SET_NAME") as SplendidCRM._controls.TeamSelect;
							if ( ctlTEAM_SET_NAME != null )
							{
								ctlTEAM_SET_NAME.RemoveTeam(gPRIVATE_TEAM_ID);
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						ctlDynamicButtons.ErrorText = ex.Message;
					}
				}
				BindSchedule();
			}
			else if ( e.CommandName == "Search" )
			{
				BindSchedule();
			}
		}

		protected void Date_Changed(object sender, System.EventArgs e)
		{
			BindSchedule();
		}

		// 09/02/2018 Paul.  Show/hide recurrence fields. 
		protected void REPEAT_TYPE_Changed(object sender, System.EventArgs e)
		{
			DropDownList ctlREPEAT_TYPE = FindControl("REPEAT_TYPE") as DropDownList;
			if ( ctlREPEAT_TYPE != null )
			{
				string sREPEAT_TYPE = ctlREPEAT_TYPE.SelectedValue;
				TextBox      txtREPEAT_COUNT       = FindControl("REPEAT_COUNT"         ) as TextBox;
				TextBox      txtREPEAT_INTERVAL    = FindControl("REPEAT_INTERVAL"      ) as TextBox;
				DatePicker   ctlREPEAT_UNTIL       = FindControl("REPEAT_UNTIL"         ) as DatePicker;
				CheckBoxList ctlREPEAT_DOW         = FindControl("REPEAT_DOW"           ) as CheckBoxList;
				Label        lblREPEAT_COUNT       = FindControl("REPEAT_COUNT_LABEL"   ) as Label;
				Label        lblREPEAT_OCCURRENCES = FindControl("Calendar.LBL_REPEAT_OCCURRENCES") as Label;
				Label        lblREPEAT_INTERVAL    = FindControl("REPEAT_INTERVAL_LABEL") as Label;
				Label        lblREPEAT_UNTIL       = FindControl("REPEAT_UNTIL_LABEL"   ) as Label;
				Label        lblREPEAT_DOW         = FindControl("REPEAT_DOW_LABEL"     ) as Label;
				if ( txtREPEAT_COUNT       != null ) txtREPEAT_COUNT      .Visible = !Sql.IsEmptyString(sREPEAT_TYPE);
				if ( txtREPEAT_INTERVAL    != null ) txtREPEAT_INTERVAL   .Visible = !Sql.IsEmptyString(sREPEAT_TYPE);
				if ( ctlREPEAT_UNTIL       != null ) ctlREPEAT_UNTIL      .Visible = !Sql.IsEmptyString(sREPEAT_TYPE);
				if ( ctlREPEAT_DOW         != null ) ctlREPEAT_DOW        .Visible = !Sql.IsEmptyString(sREPEAT_TYPE) && sREPEAT_TYPE == "Weekly";
				if ( lblREPEAT_COUNT       != null ) lblREPEAT_COUNT      .Visible = !Sql.IsEmptyString(sREPEAT_TYPE);
				if ( lblREPEAT_OCCURRENCES != null ) lblREPEAT_OCCURRENCES.Visible = !Sql.IsEmptyString(sREPEAT_TYPE);
				if ( lblREPEAT_INTERVAL    != null ) lblREPEAT_INTERVAL   .Visible = !Sql.IsEmptyString(sREPEAT_TYPE);
				if ( lblREPEAT_UNTIL       != null ) lblREPEAT_UNTIL      .Visible = !Sql.IsEmptyString(sREPEAT_TYPE);
				if ( lblREPEAT_DOW         != null ) lblREPEAT_DOW        .Visible = !Sql.IsEmptyString(sREPEAT_TYPE) && sREPEAT_TYPE == "Weekly";
			}
		}

		private void BindSchedule()
		{
			DateTimePicker ctlDATE_START = FindControl("DATE_START" ) as DateTimePicker;
			if ( ctlDATE_START != null )
			{
				int nDURATION_HOURS   = new DynamicControl(this, "DURATION_HOURS"  ).IntegerValue;
				int nDURATION_MINUTES = new DynamicControl(this, "DURATION_MINUTES").IntegerValue;
				DateTime dtDATE_END = ctlDATE_START.Value.AddHours(nDURATION_HOURS).AddMinutes(nDURATION_MINUTES);
				// 07/09/2006 Paul.  The date values are sent to the scheduling grid in TimeZone time. 
				// The dates are converted to server time when the database is queried. 
				ctlSchedulingGrid.DATE_START = ctlDATE_START.Value;
				ctlSchedulingGrid.DATE_END   = dtDATE_END;
				ctlSchedulingGrid.INVITEES   = txtINVITEE_ID.Value.Split(',');
				ctlSchedulingGrid.BuildSchedule();
				// 07/23/2014 Paul.  Add meeting times so that we can display current user status. 
				ctlInviteesView.DATE_START = ctlDATE_START.Value;
				ctlInviteesView.DATE_END   = dtDATE_END;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							string sSQL ;
							// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
							sSQL = "select *"               + ControlChars.CrLf
							     + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
							     + "  from " + m_sVIEW_NAME + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								// 11/24/2006 Paul.  Use new Security.Filter() function to apply Team and ACL security rules.
								Security.Filter(cmd, m_sMODULE, "edit");
								if ( !Sql.IsEmptyGuid(gDuplicateID) )
								{
									Sql.AppendParameter(cmd, gDuplicateID, "ID", false);
									gID = Guid.Empty;
								}
								else
								{
									Sql.AppendParameter(cmd, gID, "ID", false);
								}

								if ( bDebug )
									RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

								// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dtCurrent = new DataTable() )
									{
										da.Fill(dtCurrent);
										// 10/31/2017 Paul.  Provide a way to inject Record level ACL. 
										if ( dtCurrent.Rows.Count > 0 && (SplendidCRM.Security.GetRecordAccess(dtCurrent.Rows[0], m_sMODULE, "edit", "ASSIGNED_USER_ID") >= 0) )
										{
											DataRow rdr = dtCurrent.Rows[0];
											// 11/11/2010 Paul.  Apply Business Rules. 
											this.ApplyEditViewPreLoadEventRules(m_sMODULE + "." + LayoutEditView, rdr);
											
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
											// 12/09/2008 Paul.  Throw an exception if the record has been edited since the last load. 
											ViewState["LAST_DATE_MODIFIED"] = Sql.ToDateTime(rdr["DATE_MODIFIED"]);
											
											// 01/28/2010 Paul.  Use ViewState and Page.Items to be compatible with the DetailViews. 
											ViewState ["NAME"            ] = Sql.ToString(rdr["NAME"            ]);
											ViewState ["ASSIGNED_USER_ID"] = Sql.ToGuid  (rdr["ASSIGNED_USER_ID"]);
											Page.Items["NAME"            ] = ViewState ["NAME"            ];
											Page.Items["ASSIGNED_USER_ID"] = ViewState ["ASSIGNED_USER_ID"];
											
											// 02/13/2013 Paul.  Move relationship append so that it can be controlled by business rules. 
											this.AppendEditViewRelationships(m_sMODULE + "." + LayoutEditView, plcSubPanel, Sql.IsEmptyGuid(Request["ID"]));
											this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, rdr);
											// 02/18/2009 Paul.  On load, the focus should be set to the NAME field. 
											TextBox txtNAME = this.FindControl("NAME") as TextBox;
											if ( txtNAME != null )
												txtNAME.Focus();

											// 07/12/2006 Paul.  Need to enable schedule updates. 
											DateTimePicker ctlDATE_START = FindControl("DATE_START") as DateTimePicker;
											if ( ctlDATE_START != null )
											{
												ctlDATE_START.Changed += new System.EventHandler(this.Date_Changed);
												ctlDATE_START.AutoPostBack = true;
											}
											// 08/02/2005 Paul.  Set status to Held when closing from Home page.
											// 06/21/2006 Paul.  Change parameter to Close so that the same parameter can be used for Calls, Meetings and Tasks. 
											try
											{
												if ( Sql.ToString(Request["Status"]) == "Close" )
													new DynamicControl(this, "STATUS").SelectedValue = "Held";
												else
													new DynamicControl(this, "STATUS").SelectedValue = Sql.ToString(rdr["STATUS"]);
											}
											catch(Exception ex)
											{
												SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
											}
											int nDURATION_MINUTES = Sql.ToInteger(rdr["DURATION_MINUTES"]);
											// 02/17/2009 Paul.  Allow the duration to be something other than a 15 minute interval. 
											DropDownList ctlDURATION_MINUTES = FindControl("DURATION_MINUTES") as DropDownList;
											try
											{
												if ( ctlDURATION_MINUTES != null )
												{
													// 03/19/2009 Paul.  The selected value may already be set, so we must clear it otherwise an exception will be thrown. 
													// Cannot have multiple items selected in a DropDownList.
													ctlDURATION_MINUTES.ClearSelection();
													bool bFound = false;
													foreach(ListItem itm in ctlDURATION_MINUTES.Items)
													{
														if ( nDURATION_MINUTES == Sql.ToInteger(itm.Value) )
														{
															itm.Selected = true;
															bFound = true;
															break;
														}
													}
													// 02/17/2009 Paul.  If there is no match. then just add the custom value. 
													if ( !bFound )
													{
														ListItem itmCustom = new ListItem();
														// 04/23/2010 Paul.  Fix the presentation of the odd minutes. 
														itmCustom.Text  = String.Format(Sql.ToString(L10n.Term(".reminder_time_dom.", "300")).Replace("5", "{0}"), nDURATION_MINUTES);
														itmCustom.Value = nDURATION_MINUTES.ToString();
														ctlDURATION_MINUTES.Items.Add(itmCustom);
														itmCustom.Selected = true;
													}
												}
											}
											catch(Exception ex)
											{
												SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
											}
											// 09/02/2018 Paul.  Update SchedulingGrid when duration changes. 
											TextBox ctlDURATION_HOURS = FindControl("DURATION_HOURS") as TextBox;
											if ( ctlDURATION_HOURS != null )
											{
												ctlDURATION_HOURS.TextChanged += new System.EventHandler(this.Date_Changed);
												ctlDURATION_HOURS.AutoPostBack = true;
											}
											if ( ctlDURATION_MINUTES != null )
											{
												ctlDURATION_MINUTES.SelectedIndexChanged += new System.EventHandler(this.Date_Changed);
												ctlDURATION_MINUTES.AutoPostBack = true;
											}
											CheckBox ctlALL_DAY_EVENT = FindControl("ALL_DAY_EVENT") as CheckBox;
											if ( ctlALL_DAY_EVENT != null )
											{
												ctlALL_DAY_EVENT.CheckedChanged += new System.EventHandler(this.Date_Changed);
												ctlALL_DAY_EVENT.AutoPostBack = true;
											}
											// 09/02/2018 Paul.  Show/hide recurrence fields. 
											DropDownList ctlREPEAT_TYPE = FindControl("REPEAT_TYPE") as DropDownList;
											if ( ctlREPEAT_TYPE != null )
											{
												ctlREPEAT_TYPE.SelectedIndexChanged += new System.EventHandler(this.REPEAT_TYPE_Changed);
												ctlREPEAT_TYPE.AutoPostBack = true;
												REPEAT_TYPE_Changed(null, null);
											}
											int nREMINDER_TIME = Sql.ToInteger(rdr["REMINDER_TIME"]);
											if ( nREMINDER_TIME >= 0 )
											{
												// 02/17/2009 Paul.  Allow the reminder to be something other than a 15 minute interval. 
												try
												{
													DropDownList ctlREMINDER_TIME = FindControl("REMINDER_TIME") as DropDownList;
													if ( ctlREMINDER_TIME != null )
													{
														// 03/19/2009 Paul.  The selected value may already be set, so we must clear it otherwise an exception will be thrown. 
														// Cannot have multiple items selected in a DropDownList.
														ctlREMINDER_TIME.ClearSelection();
														bool bFound = false;
														foreach(ListItem itm in ctlREMINDER_TIME.Items)
														{
															if ( nREMINDER_TIME == Sql.ToInteger(itm.Value) )
															{
																itm.Selected = true;
																bFound = true;
																break;
															}
														}
														// 02/17/2009 Paul.  If there is no match. then just add the custom value. 
														if ( !bFound && (nREMINDER_TIME / 60 > 0) )
														{
															ListItem itmCustom = new ListItem();
															// 04/23/2010 Paul.  Fix the presentation of the odd minutes. 
															itmCustom.Text  = String.Format(Sql.ToString(L10n.Term(".reminder_time_dom.", "300")).Replace("5", "{0}"), nREMINDER_TIME / 60);
															itmCustom.Value = nREMINDER_TIME.ToString();
															ctlREMINDER_TIME.Items.Add(itmCustom);
															itmCustom.Selected = true;
														}
													}
												}
												catch(Exception ex)
												{
													SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
												}
												new DynamicControl(this, "SHOULD_REMIND").Checked = true;
											}
											else
											{
												// 03/04/2009 Paul.  If reminder is not specified, then hide the dropdown. 
												DropDownList ctlREMINDER_TIME = FindControl("REMINDER_TIME") as DropDownList;
												if ( ctlREMINDER_TIME != null )
												{
													ctlREMINDER_TIME.Style.Add("display", "none");
												}
											}
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											// 11/10/2010 Paul.  Apply Business Rules. 
											this.ApplyEditViewPostLoadEventRules(m_sMODULE + "." + LayoutEditView, rdr);
										}
										else
										{
											// 11/25/2006 Paul.  If item is not visible, then don't allow save 
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
											ctlFooterButtons .DisableAll();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
											// 01/27/2010 Paul.  Hide any subpanel data. 
											plcSubPanel.Visible = false;
										}
									}
								}
							}
							sSQL = "select INVITEE_ID                            " + ControlChars.CrLf
							     + "  from vwCALLS_Invitees                      " + ControlChars.CrLf
							     + " where CALL_ID = @ID                         " + ControlChars.CrLf
							     + " order by INVITEE_TYPE desc, INVITEE_NAME asc" + ControlChars.CrLf;
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

								if ( bDebug )
									RegisterClientScriptBlock("vwCALLS_Invitees", Sql.ClientScriptBlock(cmd));

								using ( IDataReader rdr = cmd.ExecuteReader() )
								{
									StringBuilder sb = new StringBuilder();
									while ( rdr.Read() )
									{
										if ( sb.Length > 0 )
											sb.Append(",");
										sb.Append(Sql.ToString(rdr["INVITEE_ID"]).ToLower());
									}
									txtINVITEE_ID.Value = sb.ToString();
								}
							}
						}
					}
					else
					{
						// 02/13/2013 Paul.  Move relationship append so that it can be controlled by business rules. 
						this.AppendEditViewRelationships(m_sMODULE + "." + LayoutEditView, plcSubPanel, Sql.IsEmptyGuid(Request["ID"]));
						this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, null);
						// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						// 02/18/2009 Paul.  On load, the focus should be set to the NAME field. 
						TextBox txtNAME = this.FindControl("NAME") as TextBox;
						if ( txtNAME != null )
							txtNAME.Focus();
						
						DateTimePicker ctlDATE_START = FindControl("DATE_START") as DateTimePicker;
						if ( ctlDATE_START != null )
						{
							ctlDATE_START.Changed += new System.EventHandler(this.Date_Changed);
							ctlDATE_START.AutoPostBack = true;
							// Default start date and time is now. 
							ctlDATE_START.Value = T10n.FromServerTime(DateTime.Now);
							// 05/10/2013 Paul.  Accept defaults to simplify VoIP creation. 
							if ( !Sql.IsEmptyString(Request["DATE_START"]) )
							{
								DateTime dt = DateTime.MinValue;
								if ( DateTime.TryParse(Request["DATE_START"], out dt) )
									ctlDATE_START.Value = T10n.FromServerTime(dt);
							}
						}
						// Default value for duration is 15 minutes. 
						new DynamicControl(this, "DURATION_MINUTES").Text = "15";
						// Default to 0 hours. 
						new DynamicControl(this, "DURATION_HOURS"  ).Text = "0";
						// Default to remind. 
						new DynamicControl(this, "SHOULD_REMIND"   ).Checked = true;
						// 05/10/2013 Paul.  Accept defaults to simplify VoIP creation. 
						if ( !Sql.IsEmptyString(Request["DURATION_MINUTES"]) )
						{
							int nDURATION_MINUTES = 15;
							if ( int.TryParse(Request["DURATION_MINUTES"], out nDURATION_MINUTES) )
								new DynamicControl(this, "DURATION_MINUTES").Text = nDURATION_MINUTES.ToString();
						}
						if ( !Sql.IsEmptyString(Request["DURATION_HOURS"]) )
						{
							int nDURATION_HOURS = 0;
							if ( int.TryParse(Request["DURATION_HOURS"], out nDURATION_HOURS) )
								new DynamicControl(this, "DURATION_HOURS").Text = nDURATION_HOURS.ToString();
						}
						// 09/02/2018 Paul.  Update SchedulingGrid when duration changes. 
						TextBox ctlDURATION_HOURS = FindControl("DURATION_HOURS") as TextBox;
						if ( ctlDURATION_HOURS != null )
						{
							ctlDURATION_HOURS.TextChanged += new System.EventHandler(this.Date_Changed);
							ctlDURATION_HOURS.AutoPostBack = true;
						}
						DropDownList ctlDURATION_MINUTES = FindControl("DURATION_MINUTES") as DropDownList;
						if ( ctlDURATION_MINUTES != null )
						{
							ctlDURATION_MINUTES.SelectedIndexChanged += new System.EventHandler(this.Date_Changed);
							ctlDURATION_MINUTES.AutoPostBack = true;
						}
						CheckBox ctlALL_DAY_EVENT = FindControl("ALL_DAY_EVENT") as CheckBox;
						if ( ctlALL_DAY_EVENT != null )
						{
							ctlALL_DAY_EVENT.CheckedChanged += new System.EventHandler(this.Date_Changed);
							ctlALL_DAY_EVENT.AutoPostBack = true;
						}
						// 09/02/2018 Paul.  Show/hide recurrence fields. 
						DropDownList ctlREPEAT_TYPE = FindControl("REPEAT_TYPE") as DropDownList;
						if ( ctlREPEAT_TYPE != null )
						{
							ctlREPEAT_TYPE.SelectedIndexChanged += new System.EventHandler(this.REPEAT_TYPE_Changed);
							ctlREPEAT_TYPE.AutoPostBack = true;
							REPEAT_TYPE_Changed(null, null);
						}
						// 08/25/2013 Paul.  Correct variable name. 
						DropDownList lstDIRECTION = FindControl("DIRECTION") as DropDownList;
						if ( lstDIRECTION != null & !Sql.IsEmptyString(Request["DIRECTION"]) )
							Utils.SetSelectedValue(lstDIRECTION, Request["DIRECTION"]);
						// 08/25/2013 Paul.  Allow status to be sent from VoIP event. 
						DropDownList lstSTATUS = FindControl("STATUS") as DropDownList;
						if ( lstSTATUS != null & !Sql.IsEmptyString(Request["STATUS"]) )
							Utils.SetSelectedValue(lstSTATUS, Request["STATUS"]);

						Guid gPARENT_ID = Sql.ToGuid(Request["PARENT_ID"]);
						if ( !Sql.IsEmptyGuid(gPARENT_ID) )
						{
							// 04/14/2016 Paul.  New spPARENT_GetWithTeam procedure so that we can inherit Assigned To and Team values. 
							string sMODULE           = String.Empty;
							string sPARENT_TYPE      = String.Empty;
							string sPARENT_NAME      = String.Empty;
							Guid   gASSIGNED_USER_ID = Guid.Empty;
							string sASSIGNED_TO      = String.Empty;
							string sASSIGNED_TO_NAME = String.Empty;
							Guid   gTEAM_ID          = Guid.Empty;
							string sTEAM_NAME        = String.Empty;
							Guid   gTEAM_SET_ID      = Guid.Empty;
							// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
							Guid   gASSIGNED_SET_ID  = Guid.Empty;
							SqlProcs.spPARENT_GetWithTeam(ref gPARENT_ID, ref sMODULE, ref sPARENT_TYPE, ref sPARENT_NAME, ref gASSIGNED_USER_ID, ref sASSIGNED_TO, ref sASSIGNED_TO_NAME, ref gTEAM_ID, ref sTEAM_NAME, ref gTEAM_SET_ID, ref gASSIGNED_SET_ID);
							if ( !Sql.IsEmptyGuid(gPARENT_ID) )
							{
								// 12/17/2013 Paul.  sMODULE contains the internal module name and sPARENT_TYPE contains the folder name (only different for Projects and ProjectTasks). 
								// 01/23/2015 Paul.  Need to exclude Project and ProjectTask.  Not entirely sure why we update the parent type in the first place, but it is safer to leave the code. 
								if ( sPARENT_TYPE != "Project" && sPARENT_TYPE != "ProjectTask" )
									sPARENT_TYPE = sMODULE;
								new DynamicControl(this, "PARENT_ID"  ).ID   = gPARENT_ID;
								new DynamicControl(this, "PARENT_NAME").Text = sPARENT_NAME;
								// 02/04/2011 Paul.  We gave the PARENT_TYPE a unique name, but we need to update all EditViews and NewRecords. 
								new DynamicControl(this, "PARENT_ID_PARENT_TYPE").SelectedValue = sPARENT_TYPE;
								// 04/14/2016 Paul.  New spPARENT_GetWithTeam procedure so that we can inherit Assigned To and Team values. 
								if ( Sql.ToBoolean(Application["CONFIG.inherit_assigned_user"]) )
								{
									new DynamicControl(this, "ASSIGNED_USER_ID").ID   = gASSIGNED_USER_ID;
									new DynamicControl(this, "ASSIGNED_TO"     ).Text = sASSIGNED_TO     ;
									new DynamicControl(this, "ASSIGNED_TO_NAME").Text = sASSIGNED_TO_NAME;
									// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
									if ( Crm.Config.enable_dynamic_assignment() )
									{
										SplendidCRM._controls.UserSelect ctlUserSelect = FindControl("ASSIGNED_SET_NAME") as SplendidCRM._controls.UserSelect;
										if ( ctlUserSelect != null )
											ctlUserSelect.LoadLineItems(gASSIGNED_SET_ID, true, true);
									}
								}
								if ( Sql.ToBoolean(Application["CONFIG.inherit_team"]) )
								{
									new DynamicControl(this, "TEAM_ID"  ).ID   = gTEAM_ID  ;
									new DynamicControl(this, "TEAM_NAME").Text = sTEAM_NAME;
									SplendidCRM._controls.TeamSelect ctlTeamSelect = FindControl("TEAM_SET_NAME") as SplendidCRM._controls.TeamSelect;
									if ( ctlTeamSelect != null )
										ctlTeamSelect.LoadLineItems(gTEAM_SET_ID, true, true);
								}
							}
						}
						// 11/10/2010 Paul.  Apply Business Rules. 
						this.ApplyEditViewNewEventRules(m_sMODULE + "." + LayoutEditView);
					}
					// Default to current user. 
					if ( txtINVITEE_ID.Value.Length == 0 )
						txtINVITEE_ID.Value = Security.USER_ID.ToString();
					BindSchedule();
					// 12/26/2012 Paul.  Add send invites button. 
					// 01/20/2017 Paul.  Add support for Office365 and GoogleApps. 
					ctlDynamicButtons.EnableButton("Save.SendInvites", !Utils.IsOfflineClient && EmailUtils.ValidCampaignManagerSettings(Application));
					ctlFooterButtons .EnableButton("Save.SendInvites", !Utils.IsOfflineClient && EmailUtils.ValidCampaignManagerSettings(Application));
				}
				else
				{
					// 12/02/2005 Paul.  When validation fails, the header title does not retain its value.  Update manually. 
					// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
					// 01/28/2010 Paul.  We need to restore the page items on each postback. 
					Page.Items["NAME"            ] = ViewState ["NAME"            ];
					Page.Items["ASSIGNED_USER_ID"] = ViewState ["ASSIGNED_USER_ID"];
					// 11/09/2005 Paul.  Need to rebind early so that the Delete event will fire. 
					BindSchedule();
					ctlInviteesView.INVITEES = txtINVITEE_ID.Value.Split(',');
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
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			ctlFooterButtons .Command += new CommandEventHandler(Page_Command);
			ctlInviteesView.Command += new CommandEventHandler(this.Page_Command);
			ctlSchedulingGrid.Command += new CommandEventHandler(this.Page_Command);
			m_sMODULE = "Calls";
			// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
			m_sVIEW_NAME = "vw" + Crm.Modules.TableName(m_sMODULE) + "_Edit";
			// 02/13/2007 Paul.  Calls should highlight the Activities menu. 
			// 03/15/2011 Paul.  Change menu to use main module. 
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				// 04/19/2010 Paul.  New approach to EditView Relationships will distinguish between New Record and Existing Record.
				// 02/13/2013 Paul.  Move relationship append so that it can be controlled by business rules. 
				this.AppendEditViewRelationships(m_sMODULE + "." + LayoutEditView, plcSubPanel, Sql.IsEmptyGuid(Request["ID"]));
				// 12/02/2005 Paul.  Need to add the edit fields in order for events to fire. 
				this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, null);
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);

				DateTimePicker ctlDATE_START = FindControl("DATE_START") as DateTimePicker;
				if ( ctlDATE_START != null )
				{
					ctlDATE_START.Changed += new System.EventHandler(this.Date_Changed);
					ctlDATE_START.AutoPostBack = true;
				}
				// 09/02/2018 Paul.  Update SchedulingGrid when duration changes. 
				TextBox ctlDURATION_HOURS = FindControl("DURATION_HOURS") as TextBox;
				if ( ctlDURATION_HOURS != null )
				{
					ctlDURATION_HOURS.TextChanged += new System.EventHandler(this.Date_Changed);
					ctlDURATION_HOURS.AutoPostBack = true;
				}
				DropDownList ctlDURATION_MINUTES = FindControl("DURATION_MINUTES") as DropDownList;
				if ( ctlDURATION_MINUTES != null )
				{
					ctlDURATION_MINUTES.SelectedIndexChanged += new System.EventHandler(this.Date_Changed);
					ctlDURATION_MINUTES.AutoPostBack = true;
				}
				CheckBox ctlALL_DAY_EVENT = FindControl("ALL_DAY_EVENT") as CheckBox;
				if ( ctlALL_DAY_EVENT != null )
				{
					ctlALL_DAY_EVENT.CheckedChanged += new System.EventHandler(this.Date_Changed);
					ctlALL_DAY_EVENT.AutoPostBack = true;
				}
				// 09/02/2018 Paul.  Show/hide recurrence fields. 
				DropDownList ctlREPEAT_TYPE = FindControl("REPEAT_TYPE") as DropDownList;
				if ( ctlREPEAT_TYPE != null )
				{
					ctlREPEAT_TYPE.SelectedIndexChanged += new System.EventHandler(this.REPEAT_TYPE_Changed);
					ctlREPEAT_TYPE.AutoPostBack = true;
				}
				// 11/10/2010 Paul.  Make sure to add the RulesValidator early in the pipeline. 
				Page.Validators.Add(new RulesValidator(this));
			}
		}
		#endregion
	}
}

