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
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using SplendidCRM._controls;

namespace SplendidCRM.Leads
{
	/// <summary>
	///		Summary description for ConvertViewAppointment.
	/// </summary>
	public class ConvertViewAppointment : InlineEditControl
	{
		protected Guid                   gAPPOINTMENT_ID                      ;
		protected Guid                   gASSIGNED_USER_ID                    ;
		protected Guid                   gTEAM_ID                             ;
		protected string                 sTEAM_SET_LIST                       ;
		// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		protected string                 sASSIGNED_SET_LIST                   ;

		protected HtmlTable              tblMain                              ;

		protected CheckBox               chkCreateAppointment                 ;
		protected RadioButton            radScheduleCall                      ;
		protected RadioButton            radScheduleMeeting                   ;

		public Guid APPOINTMENT_ID
		{
			get { return gAPPOINTMENT_ID; }
			set { gAPPOINTMENT_ID = value; }
		}

		public Guid ASSIGNED_USER_ID
		{
			get { return gASSIGNED_USER_ID; }
			set { gASSIGNED_USER_ID = value; }
		}

		public Guid TEAM_ID
		{
			get { return gTEAM_ID; }
			set { gTEAM_ID = value; }
		}

		public string TEAM_SET_LIST
		{
			get { return sTEAM_SET_LIST; }
			set { sTEAM_SET_LIST = value; }
		}

		// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		public string ASSIGNED_SET_LIST
		{
			get { return sASSIGNED_SET_LIST; }
			set { sASSIGNED_SET_LIST = value; }
		}

		public override bool IsEmpty()
		{
			string sNAME = new DynamicControl(this, "NAME").Text;
			return Sql.IsEmptyString(sNAME);
		}

		public override void ValidateEditViewFields()
		{
			if ( chkCreateAppointment.Checked )
			{
				this.ValidateEditViewFields           ("Leads.ConvertViewAppointment");
				this.ApplyEditViewValidationEventRules("Leads.ConvertViewAppointment");
			}
		}

		public override void Save(Guid gPARENT_ID, string sPARENT_TYPE, IDbTransaction trn)
		{
			if ( IsEmpty() )
				return;
			
			if ( chkCreateAppointment.Checked )
			{
				bool bALL_DAY_EVENT = new DynamicControl(this, "ALL_DAY_EVENT").Checked;
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
				if ( radScheduleCall.Checked )
				{
					string    sTABLE_NAME    = Crm.Modules.TableName("Calls");
					DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
			
					if ( FindControl("ASSIGNED_USER_ID") != null )
						gASSIGNED_USER_ID = new DynamicControl(this, "ASSIGNED_USER_ID").ID;
					if ( FindControl("TEAM_ID") != null || FindControl("TEAM_SET_NAME") != null )
						gTEAM_ID = new DynamicControl(this, "TEAM_ID").ID;
					if ( FindControl("TEAM_SET_LIST") != null || FindControl("TEAM_SET_NAME") != null )
						sTEAM_SET_LIST = new DynamicControl(this, "TEAM_SET_LIST").Text;
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					if ( FindControl("ASSIGNED_SET_LIST") != null || FindControl("ASSIGNED_SET_NAME") != null )
						sASSIGNED_SET_LIST = new DynamicControl(this, "ASSIGNED_SET_LIST").Text;

					// 12/23/2013 Paul.  Add SMS_REMINDER_TIME. 
					// 09/14/2015 Paul.  Default for reminders should be 0. 
					string sREPEAT_TYPE = new DynamicControl(this, "REPEAT_TYPE").SelectedValue;
					SqlProcs.spCALLS_Update
						( ref gAPPOINTMENT_ID
						, gASSIGNED_USER_ID
						, new DynamicControl(this, "NAME"               ).Text
						,(bALL_DAY_EVENT ? 24 : new DynamicControl(this, "DURATION_HOURS"  ).IntegerValue)
						,(bALL_DAY_EVENT ?  0 : new DynamicControl(this, "DURATION_MINUTES").IntegerValue)
						, new DynamicControl(this, "DATE_START"         ).DateValue
						, sPARENT_TYPE
						, gPARENT_ID
						, new DynamicControl(this, "STATUS"             ).SelectedValue
						, new DynamicControl(this, "DIRECTION"          ).SelectedValue
						,(new DynamicControl(this, "SHOULD_REMIND"      ).Checked ? new DynamicControl(this, "REMINDER_TIME").IntegerValue : 0)
						, new DynamicControl(this, "DESCRIPTION"        ).Text
						, gPARENT_ID.ToString()         // 01/31/2006 Paul.  This is were we relate this call to the contact. 
						, gTEAM_ID
						, sTEAM_SET_LIST
						,(new DynamicControl(this, "EMAIL_REMINDER_TIME").IntegerValue > 0 ? new DynamicControl(this, "EMAIL_REMINDER_TIME").IntegerValue : 0)
						, bALL_DAY_EVENT
						, sREPEAT_TYPE
						,(sREPEAT_TYPE == String.Empty ? 0                 : new DynamicControl(this, "REPEAT_INTERVAL").IntegerValue)
						,(sREPEAT_TYPE != "Weekly"     ? String.Empty      : new DynamicControl(this, "REPEAT_DOW"     ).Text        )
						,(sREPEAT_TYPE == String.Empty ? DateTime.MinValue : new DynamicControl(this, "REPEAT_UNTIL"   ).DateValue   )
						,(sREPEAT_TYPE == String.Empty ? 0                 : new DynamicControl(this, "REPEAT_COUNT"   ).IntegerValue)
						,(new DynamicControl(this, "SMS_REMINDER_TIME"  ).IntegerValue > 0 ? new DynamicControl(this, "SMS_REMINDER_TIME").IntegerValue : 0)
						// 05/17/2017 Paul.  Add Tags module. 
						, new DynamicControl(this, "TAG_SET_NAME"       ).Text
						// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
						, new DynamicControl(this, "IS_PRIVATE"         ).Checked
						// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
						, sASSIGNED_SET_LIST
						, trn
						);
					SplendidDynamic.UpdateCustomFields(this, trn, gAPPOINTMENT_ID, sTABLE_NAME, dtCustomFields);
				}
				else
				{
					string    sTABLE_NAME    = Crm.Modules.TableName("Meetings");
					DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
			
					if ( FindControl("ASSIGNED_USER_ID") != null )
						gASSIGNED_USER_ID = new DynamicControl(this, "ASSIGNED_USER_ID").ID;
					if ( FindControl("TEAM_ID") != null || FindControl("TEAM_SET_NAME") != null )
						gTEAM_ID = new DynamicControl(this, "TEAM_ID").ID;
					if ( FindControl("TEAM_SET_LIST") != null || FindControl("TEAM_SET_NAME") != null )
						sTEAM_SET_LIST = new DynamicControl(this, "TEAM_SET_LIST").Text;
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					if ( FindControl("ASSIGNED_SET_LIST") != null || FindControl("ASSIGNED_SET_NAME") != null )
						sASSIGNED_SET_LIST = new DynamicControl(this, "ASSIGNED_SET_LIST").Text;

					// 12/23/2013 Paul.  Add SMS_REMINDER_TIME. 
					// 09/14/2015 Paul.  Default for reminders should be 0. 
					string sREPEAT_TYPE = new DynamicControl(this, "REPEAT_TYPE").SelectedValue;
					SqlProcs.spMEETINGS_Update
						( ref gAPPOINTMENT_ID
						, gASSIGNED_USER_ID
						, new DynamicControl(this, "NAME"               ).Text
						, new DynamicControl(this, "LOCATION"           ).Text
						,(bALL_DAY_EVENT ? 24 : new DynamicControl(this, "DURATION_HOURS"  ).IntegerValue)
						,(bALL_DAY_EVENT ?  0 : new DynamicControl(this, "DURATION_MINUTES").IntegerValue)
						, new DynamicControl(this, "DATE_START"         ).DateValue
						, new DynamicControl(this, "STATUS"             ).SelectedValue
						, sPARENT_TYPE
						, gPARENT_ID
						,(new DynamicControl(this, "SHOULD_REMIND"      ).Checked ? new DynamicControl(this, "REMINDER_TIME").IntegerValue : 0)
						, new DynamicControl(this, "DESCRIPTION"        ).Text
						, gPARENT_ID.ToString()         // 01/31/2006 Paul.  This is were we relate this meeting to the contact. 
						, gTEAM_ID
						, sTEAM_SET_LIST
						,(new DynamicControl(this, "EMAIL_REMINDER_TIME").IntegerValue > 0 ? new DynamicControl(this, "EMAIL_REMINDER_TIME").IntegerValue : 0)
						, bALL_DAY_EVENT
						, sREPEAT_TYPE
						,(sREPEAT_TYPE == String.Empty ? 0                 : new DynamicControl(this, "REPEAT_INTERVAL").IntegerValue)
						,(sREPEAT_TYPE != "Weekly"     ? String.Empty      : new DynamicControl(this, "REPEAT_DOW"     ).Text        )
						,(sREPEAT_TYPE == String.Empty ? DateTime.MinValue : new DynamicControl(this, "REPEAT_UNTIL"   ).DateValue   )
						,(sREPEAT_TYPE == String.Empty ? 0                 : new DynamicControl(this, "REPEAT_COUNT"   ).IntegerValue)
						,(new DynamicControl(this, "SMS_REMINDER_TIME"  ).IntegerValue > 0 ? new DynamicControl(this, "SMS_REMINDER_TIME").IntegerValue : 0)
						// 05/17/2017 Paul.  Add Tags module. 
						, new DynamicControl(this, "TAG_SET_NAME"       ).Text
						// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
						, new DynamicControl(this, "IS_PRIVATE"         ).Checked
						// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
						, sASSIGNED_SET_LIST
						, trn
						);
					SplendidDynamic.UpdateCustomFields(this, trn, gAPPOINTMENT_ID, sTABLE_NAME, dtCustomFields);
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 04/17/2016 Paul.  Hide panel if module disabled. 
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "edit") >= 0) && Sql.ToBoolean(Application["Modules." + m_sMODULE + ".Valid"]);
			if ( !this.Visible )
				return;

			try
			{
				Guid gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					chkCreateAppointment.Attributes.Add("onclick", "return toggleDisplay('divCreateAppointment');");
					if ( !Sql.IsEmptyGuid(gID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							sSQL = "select *                         " + ControlChars.CrLf
							     + "  from vwLEADS_ConvertAppointment" + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Security.Filter(cmd, m_sMODULE, "edit");
								Sql.AppendParameter(cmd, gID, "ID", false);
								con.Open();

								if ( bDebug )
									RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dtCurrent = new DataTable() )
									{
										da.Fill(dtCurrent);
										if ( dtCurrent.Rows.Count > 0 )
										{
											DataRow rdr = dtCurrent.Rows[0];
											this.ApplyEditViewPreLoadEventRules ("Leads.ConvertViewAppointment", rdr);
											this.AppendEditViewFields           ("Leads.ConvertViewAppointment", tblMain, rdr);
											this.ApplyEditViewPostLoadEventRules("Leads.ConvertViewAppointment", rdr);
										}
									}
								}
							}
						}
					}
					else
					{
						this.AppendEditViewFields      ("Leads.ConvertViewAppointment", tblMain, null);
						this.ApplyEditViewNewEventRules("Leads.ConvertViewAppointment");
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				//ctlDynamicButtons.ErrorText = ex.Message;
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
			m_sMODULE = "Calls";
			if ( IsPostBack )
			{
				this.AppendEditViewFields("Leads.ConvertViewAppointment", tblMain, null);
				Page.Validators.Add(new RulesValidator(this));
			}
		}
		#endregion
	}
}

