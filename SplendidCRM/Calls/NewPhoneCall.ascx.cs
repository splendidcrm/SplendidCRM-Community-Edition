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
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Calls
{
	/// <summary>
	///		Summary description for New.
	/// </summary>
	public class NewPhoneCall : NewRecordControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		protected _controls.DynamicButtons ctlFooterButtons ;

		protected Guid            gID                             ;
		protected HtmlTable       tblMain                         ;
		protected Panel           pnlMain                         ;

		// 05/06/2010 Paul.  We need a common way to attach a command from the Toolbar. 
		// 05/05/2010 Paul.  We need a common way to access the parent from the Toolbar. 

		// 04/20/2010 Paul.  Add functions to allow this control to be used as part of an InlineEdit operation. 
		public override bool IsEmpty()
		{
			string sNAME = new DynamicControl(this, "NAME").Text;
			return Sql.IsEmptyString(sNAME);
		}

		public override void ValidateEditViewFields()
		{
			if ( !IsEmpty() )
			{
				this.ValidateEditViewFields(m_sMODULE + "." + sEditView);
				// 10/20/2011 Paul.  Apply Business Rules to NewRecord. 
				this.ApplyEditViewValidationEventRules(m_sMODULE + "." + sEditView);
			}
		}

		public override void Save(Guid gPARENT_ID, string sPARENT_TYPE, IDbTransaction trn)
		{
			if ( IsEmpty() )
				return;
			
			string    sTABLE_NAME    = Crm.Modules.TableName(m_sMODULE);
			DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
			
			Guid gASSIGNED_USER_ID = new DynamicControl(this, "ASSIGNED_USER_ID").ID;
			Guid gTEAM_ID          = new DynamicControl(this, "TEAM_ID"         ).ID;
			if ( Sql.IsEmptyGuid(gASSIGNED_USER_ID) )
				gASSIGNED_USER_ID = Security.USER_ID;
			if ( Sql.IsEmptyGuid(gTEAM_ID) )
				gTEAM_ID = Security.TEAM_ID;

			// 07/27/2012 Paul.  We will calculate the duration. 
			DateTime DURATION_START = Sql.ToDateTime(ViewState["DURATION_START"]);
			TimeSpan tsDuration = DateTime.Now - DURATION_START;
			// 12/26/2012 Paul.  Add EMAIL_REMINDER_TIME. 
			// 03/07/2013 Paul.  Add ALL_DAY_EVENT. 
			// 03/20/2013 Paul.  Add REPEAT fields. 
			// 12/23/2013 Paul.  Add SMS_REMINDER_TIME. 
			// 09/14/2015 Paul.  Default for reminders should be 0. 
			SqlProcs.spCALLS_Update
				( ref gID
				, gASSIGNED_USER_ID
				, new DynamicControl(this, "NAME"               ).Text
				, tsDuration.Hours
				, tsDuration.Minutes
				, new DynamicControl(this, "DATE_START"         ).DateValue
				, sPARENT_TYPE
				, gPARENT_ID
				, "Held"     // STATUS
				, "Inbound"  // DIRECTION
				,(new DynamicControl(this, "REMINDER_TIME"      ).IntegerValue > 0 ? new DynamicControl(this, "REMINDER_TIME").IntegerValue : 0)
				, new DynamicControl(this, "DESCRIPTION"        ).Text
				, String.Empty
				, gTEAM_ID
				, new DynamicControl(this, "TEAM_SET_LIST"      ).Text
				,(new DynamicControl(this, "EMAIL_REMINDER_TIME").IntegerValue > 0 ? new DynamicControl(this, "EMAIL_REMINDER_TIME").IntegerValue : 0)
				, new DynamicControl(this, "ALL_DAY_EVENT"      ).Checked
				, new DynamicControl(this, "REPEAT_TYPE"        ).SelectedValue
				, new DynamicControl(this, "REPEAT_INTERVAL"    ).IntegerValue
				, new DynamicControl(this, "REPEAT_DOW"         ).Text
				, new DynamicControl(this, "REPEAT_UNTIL"       ).DateValue
				, new DynamicControl(this, "REPEAT_COUNT"       ).IntegerValue
				,(new DynamicControl(this, "SMS_REMINDER_TIME"  ).IntegerValue > 0 ? new DynamicControl(this, "SMS_REMINDER_TIME").IntegerValue : 0)
				// 05/17/2017 Paul.  Add Tags module. 
				, new DynamicControl(this, "TAG_SET_NAME"       ).Text
				// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
				, new DynamicControl(this, "IS_PRIVATE"         ).Checked
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				, new DynamicControl(this, "ASSIGNED_SET_LIST"  ).Text
				, trn
				);
			SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "NewRecord" )
				{
					// 06/20/2009 Paul.  Use a Dynamic View that is nearly idential to the EditView version. 
					this.ValidateEditViewFields(m_sMODULE + "." + sEditView);
					// 10/20/2011 Paul.  Apply Business Rules to NewRecord. 
					this.ApplyEditViewValidationEventRules(m_sMODULE + "." + sEditView);
					if ( Page.IsValid )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							// 10/20/2011 Paul.  Apply Business Rules to NewRecord. 
							this.ApplyEditViewPreSaveEventRules(m_sMODULE + "." + sEditView, null);
							
							// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									Guid   gPARENT_ID   = new DynamicControl(this, "PARENT_ID"  ).ID;
									// 02/04/2011 Paul.  We gave the PARENT_TYPE a unique name, but we need to update all EditViews and NewRecords. 
									string sPARENT_TYPE = new DynamicControl(this, "PARENT_ID_PARENT_TYPE").SelectedValue;
									if ( Sql.IsEmptyGuid(gPARENT_ID) )
										gPARENT_ID = this.PARENT_ID;
									// 07/14/2010 Paul.  We should be checking the sPARENT_TYPE value and not the ViewState value. 
									if ( Sql.IsEmptyString(sPARENT_TYPE) )
										sPARENT_TYPE = this.PARENT_TYPE;
									Save(gPARENT_ID, sPARENT_TYPE, trn);
									trn.Commit();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									if ( bShowFullForm || bShowCancel )
										ctlFooterButtons.ErrorText = ex.Message;
									else
										ctlDynamicButtons.ErrorText = ex.Message;
									return;
								}
							}
							// 10/20/2011 Paul.  Apply Business Rules to NewRecord. 
							// 12/10/2012 Paul.  Provide access to the item data. 
							DataRow rowCurrent = Crm.Modules.ItemEdit(m_sMODULE, gID);
							this.ApplyEditViewPostSaveEventRules(m_sMODULE + "." + sEditView, rowCurrent);
						}
						if ( !Sql.IsEmptyString(RulesRedirectURL) )
							Response.Redirect(RulesRedirectURL);
						// 02/21/2010 Paul.  An error should not forward the command so that the error remains. 
						// In case of success, send the command so that the page can be rebuilt. 
						// 06/02/2010 Paul.  We need a way to pass the ID up the command chain. 
						else if ( Command != null )
							Command(sender, new CommandEventArgs(e.CommandName, gID.ToString()));
						else if ( !Sql.IsEmptyGuid(gID) )
							Response.Redirect("~/" + m_sMODULE + "/view.aspx?ID=" + gID.ToString());
					}
				}
				// 04/14/2010 Paul.  We need to launch the Full Form specific to this module type. 
				else if ( e.CommandName == "NewRecord.FullForm" )
				{
					Response.Redirect("~/Calls/edit.aspx?PARENT_ID=" + PARENT_ID.ToString());
				}
				else if ( Command != null )
				{
					Command(sender, e);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				if ( bShowFullForm || bShowCancel )
					ctlFooterButtons.ErrorText = ex.Message;
				else
					ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 06/04/2006 Paul.  NewRecord should not be displayed if the user does not have edit rights. 
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
				bool bIsPostBack = this.IsPostBack && !NotPostBack;
				if ( !bIsPostBack )
				{
					// 05/06/2010 Paul.  When the control is created out-of-band, we need to manually bind the controls. 
					if ( NotPostBack )
						this.DataBind();
					this.AppendEditViewFields(m_sMODULE + "." + sEditView, tblMain, null, ctlFooterButtons.ButtonClientID("NewRecord"));
					// 07/27/2012 Paul.  We will calculate the duration. 
					// 04/20/2011 Paul.  Default value for duration is 15 minutes. 
					//new DynamicControl(this, "DURATION_MINUTES").Text = "15";
					// 04/20/2011 Paul.  Default to 0 hours. 
					//new DynamicControl(this, "DURATION_HOURS"  ).Text = "0";
					ViewState["DURATION_START"] = DateTime.Now;
					
					// 06/04/2010 Paul.  Notify the parent that the fields have been loaded. 
					if ( EditViewLoad != null )
						EditViewLoad(this, null);
					
					// 07/27/2012 Paul.  Date Start could be picker or edit. 
					if ( FindControl("DATE_START") is _controls.DateTimePicker )
					{
						(FindControl("DATE_START") as _controls.DateTimePicker).Value = T10n.FromServerTime(DateTime.Now);
					}
					else if ( FindControl("DATE_START") is _controls.DateTimeEdit )
					{
						(FindControl("DATE_START") as _controls.DateTimeEdit).Value = T10n.FromServerTime(DateTime.Now);
					}
					// 10/20/2011 Paul.  Apply Business Rules to NewRecord. 
					this.ApplyEditViewNewEventRules(m_sMODULE + "." + sEditView);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				if ( bShowFullForm || bShowCancel )
					ctlFooterButtons.ErrorText = ex.Message;
				else
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

			ctlDynamicButtons.AppendButtons("NewRecord." + (bShowFullForm ? "FullForm" : (bShowCancel ? "WithCancel" : "SaveOnly")), Guid.Empty, Guid.Empty);
			ctlFooterButtons .AppendButtons("NewRecord." + (bShowFullForm ? "FullForm" : (bShowCancel ? "WithCancel" : "SaveOnly")), Guid.Empty, Guid.Empty);
			m_sMODULE = "Calls";
			sEditView = "NewPhoneCall";
			// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
			bool bIsPostBack = this.IsPostBack && !NotPostBack;
			if ( bIsPostBack )
			{
				this.AppendEditViewFields(m_sMODULE + "." + sEditView, tblMain, null, ctlFooterButtons.ButtonClientID("NewRecord"));
				// 06/04/2010 Paul.  Notify the parent that the fields have been loaded. 
				if ( EditViewLoad != null )
					EditViewLoad(this, null);
				// 10/20/2011 Paul.  Apply Business Rules to NewRecord. 
				Page.Validators.Add(new RulesValidator(this));
			}
		}
		#endregion
	}
}

