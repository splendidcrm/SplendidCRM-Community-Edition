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
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for ProcessButtons.
	/// </summary>
	public class ProcessButtons : SplendidControl
	{
		protected Label       txtProcessStatus     ;
		protected HiddenField hidPROCESS_USER_ID   ;
		protected HiddenField hidPROCESS_NOTES     ;
		protected HiddenField hidPROCESS_ACTION    ;
		protected HiddenField hidPENDING_PROCESS_ID;
		protected HiddenField hidASSIGNED_TEAM_ID  ;
		protected HiddenField hidPROCESS_TEAM_ID   ;
		protected HiddenField hidSTATUS            ;
		protected HiddenField hidERASED_COUNT      ;
		protected Button      btnChangeProcessUser ;

		public CommandEventHandler Command;

		protected string ErrorText
		{
			set
			{
				if ( Command != null )
				{
					Command(this, new CommandEventArgs("ErrorText", value));
				}
			}
		}

		// 07/01/2019 Paul.  Perform archive lookup to see if record is archived. 
		public void AppendProcessButtons(SplendidCRM.Themes.Sugar.HeaderButtons ctlHeaderButtons, PlaceHolder pnlProcessButtons, DataRow rdr)
		{
			// 08/02/2016 Paul.  Add buttons used with Business Processes. 
			// 08/03/2016 Paul.  The existence of the PENDING_PROCESS_ID field means that the record requires approval. 
			if ( pnlProcessButtons != null )
			{
				// 07/01/2019 Paul.  Perform archive lookup to see if record is archived. 
				Button btnViewArchivedData = new Button();
				btnViewArchivedData.Command         += new CommandEventHandler(Page_Command);
				btnViewArchivedData.CommandName      = "Archive.ViewData";
				btnViewArchivedData.Visible          = false;
				btnViewArchivedData.CssClass         = "button";
				btnViewArchivedData.Text             = "  " + L10n.Term(".LBL_VIEW_ARCHIVED_DATA") + "  ";
				btnViewArchivedData.ToolTip          = L10n.Term(".LBL_VIEW_ARCHIVED_DATA");
				btnViewArchivedData.Attributes.Add("style", "margin-right: 3px;");
				pnlProcessButtons.Controls.Add(btnViewArchivedData);

				Button btnComplete = new Button();
				btnComplete.Command         += new CommandEventHandler(Page_Command);
				btnComplete.CommandName      = "Processes.Approve";
				btnComplete.Visible          = false;
				btnComplete.CssClass         = "button ProcessApprove";
				btnComplete.Text             = "  " + L10n.Term("Processes.LBL_APPROVE") + "  ";
				btnComplete.ToolTip          = L10n.Term("Processes.LBL_APPROVE");
				btnComplete.Attributes.Add("style", "margin-right: 3px;");
				pnlProcessButtons.Controls.Add(btnComplete);
				
				Button btnReject = new Button();
				btnReject.Command         += new CommandEventHandler(Page_Command);
				btnReject.CommandName      = "Processes.Reject";
				btnReject.Visible          = false;
				btnReject.CssClass         = "button ProcessReject";
				btnReject.Text             = "  " + L10n.Term("Processes.LBL_REJECT") + "  ";
				btnReject.ToolTip          = L10n.Term("Processes.LBL_REJECT");
				btnReject.Attributes.Add("style", "margin-right: 3px;");
				pnlProcessButtons.Controls.Add(btnReject);
				
				Button btnErase = new Button();
				btnErase.Command         += new CommandEventHandler(Page_Command);
				btnErase.CommandName      = "Processes.Route";
				btnErase.Visible          = false;
				btnErase.CssClass         = "button ProcessRoute";
				btnErase.Text             = "  " + L10n.Term("Processes.LBL_ROUTE") + "  ";
				btnErase.ToolTip          = L10n.Term("Processes.LBL_ROUTE");
				btnErase.Attributes.Add("style", "margin-right: 3px;");
				pnlProcessButtons.Controls.Add(btnErase);
				
				Button btnClaim = new Button();
				btnClaim.Command         += new CommandEventHandler(Page_Command);
				btnClaim.CommandName      = "Processes.Claim";
				btnClaim.Visible          = false;
				btnClaim.CssClass         = "button ProcessClaim";
				btnClaim.Text             = "  " + L10n.Term("Processes.LBL_CLAIM") + "  ";
				btnClaim.ToolTip          = L10n.Term("Processes.LBL_CLAIM");
				btnClaim.Attributes.Add("style", "margin-right: 3px;");
				pnlProcessButtons.Controls.Add(btnClaim);
				
				Guid gPENDING_PROCESS_ID = Guid.Empty;
				// 08/06/2016 Paul.  All buttons need to be created before the dataset test as rdr will be null on postback. 
				if ( rdr != null && rdr.Table.Columns.Contains("PENDING_PROCESS_ID") )
					gPENDING_PROCESS_ID = Sql.ToGuid(rdr["PENDING_PROCESS_ID"]);
				else if ( this.IsPostBack )
					gPENDING_PROCESS_ID = Sql.ToGuid(hidPENDING_PROCESS_ID.Value);
				if ( !Sql.IsEmptyGuid(gPENDING_PROCESS_ID) )
				{
					string sPENDING_PROCESS_ID = gPENDING_PROCESS_ID.ToString();
					hidPENDING_PROCESS_ID.Value = sPENDING_PROCESS_ID;
					btnComplete         .CommandArgument = sPENDING_PROCESS_ID;
					btnReject           .CommandArgument = sPENDING_PROCESS_ID;
					btnErase            .CommandArgument = sPENDING_PROCESS_ID;
					btnClaim            .CommandArgument = sPENDING_PROCESS_ID;
					btnChangeProcessUser.CommandArgument = sPENDING_PROCESS_ID;
					try
					{
						string sProcessStatus    = String.Empty;
						bool   bShowApprove      = false;
						bool   bShowReject       = false;
						bool   bShowRoute        = false;
						bool   bShowClaim        = false;
						string sUSER_TASK_TYPE   = String.Empty;
						Guid   gPROCESS_USER_ID  = Guid.Empty;
						Guid   gASSIGNED_TEAM_ID = Guid.Empty;
						Guid   gPROCESS_TEAM_ID  = Guid.Empty;
						bool bFound = WF4ApprovalActivity.GetProcessStatus(Application, L10n, gPENDING_PROCESS_ID, ref sProcessStatus, ref bShowApprove, ref bShowReject, ref bShowRoute, ref bShowClaim, ref sUSER_TASK_TYPE, ref gPROCESS_USER_ID, ref gASSIGNED_TEAM_ID, ref gPROCESS_TEAM_ID);
						if ( bFound )
						{
							// 08/06/2016 Paul.  For now, we will show the status even if the user is not the process user. 
							if ( txtProcessStatus != null )
							{
								txtProcessStatus.Visible = true;
								txtProcessStatus.Text    = sProcessStatus;
							}
							string sVIEW_NAME = "Processes.DetailView";
							if ( sUSER_TASK_TYPE == "Route" )
								sVIEW_NAME = "Processes.DetailView.Route";
							if ( Sql.IsEmptyGuid(gPROCESS_USER_ID) )
								sVIEW_NAME = "Processes.DetailView.Claim";
							if ( Sql.IsEmptyGuid(gPROCESS_USER_ID) || gPROCESS_USER_ID == Security.USER_ID )
							{
								btnComplete.Visible = bShowApprove;
								btnReject .Visible = bShowReject ;
								btnErase  .Visible = bShowRoute  ;
								btnClaim  .Visible = bShowClaim  ;
								hidASSIGNED_TEAM_ID.Value = gASSIGNED_TEAM_ID.ToString();
								hidPROCESS_TEAM_ID .Value = gPROCESS_TEAM_ID .ToString();
							}
							if ( Command != null )
							{
								// 08/10/2016 Paul.  Send these buttons to the DynamicButtons panel. 
								Command(this, new CommandEventArgs(sVIEW_NAME, rdr));
							}
							ctlHeaderButtons.ShowButton("Processes.SelectAssignedUser", !Sql.IsEmptyGuid(gASSIGNED_TEAM_ID) && gPROCESS_USER_ID == Security.USER_ID);
							ctlHeaderButtons.ShowButton("Processes.SelectProcessUser" , !Sql.IsEmptyGuid(gPROCESS_TEAM_ID ) && gPROCESS_USER_ID == Security.USER_ID);
							//this.AppendButtons(sVIEW_NAME, Guid.Empty, rdr);
							//SplendidDynamic.AppendButtons(sVIEW_NAME, Guid.Empty, this.pnlProcessButtons, this.IsMobile, rdr, this.GetL10n(), new CommandEventHandler(Page_Command));
						}
					}
					catch(Exception ex)
					{
						this.ErrorText = ex.Message;
					}
				}
			}
		}

		// 06/29/2018 Paul.  Separate method to include data privacy buttons. 
		public void AppendDataPrivacyButtons(SplendidCRM.Themes.Sugar.HeaderButtons ctlHeaderButtons, PlaceHolder pnlProcessButtons, DataRow rdr)
		{
			if ( pnlProcessButtons != null )
			{
				Button btnComplete = new Button();
				btnComplete.Command         += new CommandEventHandler(Page_Command);
				btnComplete.CommandName      = "DataPrivacy.Complete";
				btnComplete.Visible          = false;
				btnComplete.CssClass         = "button DataPrivacyComplete";
				btnComplete.Text             = "  " + L10n.Term("DataPrivacy.LBL_COMPLETE_BUTTON") + "  ";
				btnComplete.ToolTip          = L10n.Term("DataPrivacy.LBL_COMPLETE_BUTTON");
				btnComplete.Attributes.Add("style", "margin-right: 3px;");
				pnlProcessButtons.Controls.Add(btnComplete);
				
				Button btnErase = new Button();
				btnErase.Command         += new CommandEventHandler(Page_Command);
				btnErase.CommandName      = "DataPrivacy.Erase";
				btnErase.Visible          = false;
				btnErase.CssClass         = "button DataPrivacyErase";
				btnErase.Text             = "  " + L10n.Term("DataPrivacy.LBL_ERASE_BUTTON") + "  ";
				btnErase.ToolTip          = L10n.Term("DataPrivacy.LBL_ERASE_BUTTON");
				btnErase.Attributes.Add("style", "margin-right: 3px;");
				pnlProcessButtons.Controls.Add(btnErase);
				
				Button btnReject = new Button();
				btnReject.Command         += new CommandEventHandler(Page_Command);
				btnReject.CommandName      = "DataPrivacy.Reject";
				btnReject.Visible          = false;
				btnReject.CssClass         = "button DataPrivacyReject";
				btnReject.Text             = "  " + L10n.Term("DataPrivacy.LBL_REJECT_BUTTON") + "  ";
				btnReject.ToolTip          = L10n.Term("DataPrivacy.LBL_REJECT_BUTTON");
				btnReject.Attributes.Add("style", "margin-right: 3px;");
				pnlProcessButtons.Controls.Add(btnReject);
				
				string sSTATUS = String.Empty;
				int    nERASED_COUNT = 0;
				if ( rdr != null && rdr.Table.Columns.Contains("STATUS") )
				{
					sSTATUS = Sql.ToString(rdr["STATUS"]);
				}
				if ( rdr != null && rdr.Table.Columns.Contains("ERASED_COUNT") )
				{
					nERASED_COUNT = Sql.ToInteger(rdr["ERASED_COUNT"]);
				}
				else if ( this.IsPostBack )
				{
					sSTATUS       = Sql.ToString (hidSTATUS      .Value);
					nERASED_COUNT = Sql.ToInteger(hidERASED_COUNT.Value);
				}
				if ( !Sql.IsEmptyString(sSTATUS) )
				{
					hidSTATUS      .Value = sSTATUS;
					hidERASED_COUNT.Value = nERASED_COUNT.ToString();
					// 07/02/2018 Paul.  The Data Privacy Manager and admin can complete or reject. 
					btnComplete.Visible = (sSTATUS == "Open" && nERASED_COUNT == 0) && (Security.IS_ADMIN || Security.GetACLRoleAccess("Data Privacy Manager Role"));
					btnErase   .Visible = (sSTATUS == "Open" && nERASED_COUNT >  0) && (Security.IS_ADMIN || Security.GetACLRoleAccess("Data Privacy Manager Role"));
					btnReject  .Visible = (sSTATUS == "Open") && (Security.IS_ADMIN || Security.GetACLRoleAccess("Data Privacy Manager Role"));
					string sDATA_PRIVACY_ID = Sql.ToString(rdr["ID"]);
					btnComplete.CommandArgument = sDATA_PRIVACY_ID;
					btnErase   .CommandArgument = sDATA_PRIVACY_ID;
					btnReject  .CommandArgument = sDATA_PRIVACY_ID;
				}
			}
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Processes.Approve" )
			{
				try
				{
					Guid gPENDING_PROCESS_ID = Sql.ToGuid(e.CommandArgument);
					if ( !Sql.IsEmptyGuid(gPENDING_PROCESS_ID) )
					{
						WF4ApprovalActivity.Approve(Application, L10n, gPENDING_PROCESS_ID, Security.USER_ID);
						Response.Redirect(Request.RawUrl);
					}
					else
						this.ErrorText = "gPENDING_PROCESS_ID is empty";
				}
				catch(Exception ex)
				{
					this.ErrorText = ex.Message;
				}
			}
			else if ( e.CommandName == "Processes.Reject" )
			{
				try
				{
					Guid gPENDING_PROCESS_ID = Sql.ToGuid(e.CommandArgument);
					if ( !Sql.IsEmptyGuid(gPENDING_PROCESS_ID) )
					{
						WF4ApprovalActivity.Reject(Application, gPENDING_PROCESS_ID, Security.USER_ID);
						Response.Redirect(Request.RawUrl);
					}
					else
						this.ErrorText = "gPENDING_PROCESS_ID is empty";
				}
				catch(Exception ex)
				{
					this.ErrorText = ex.Message;
				}
			}
			else if ( e.CommandName == "Processes.Route" )
			{
				try
				{
					Guid gPENDING_PROCESS_ID = Sql.ToGuid(e.CommandArgument);
					if ( !Sql.IsEmptyGuid(gPENDING_PROCESS_ID) )
					{
						WF4ApprovalActivity.Route(Application, L10n, gPENDING_PROCESS_ID, Security.USER_ID);
						Response.Redirect(Request.RawUrl);
					}
					else
						this.ErrorText = "gPENDING_PROCESS_ID is empty";
				}
				catch(Exception ex)
				{
					this.ErrorText = ex.Message;
				}
			}
			else if ( e.CommandName == "Processes.Claim" )
			{
				try
				{
					Guid gPENDING_PROCESS_ID = Sql.ToGuid(e.CommandArgument);
					if ( !Sql.IsEmptyGuid(gPENDING_PROCESS_ID) )
					{
						WF4ApprovalActivity.Claim(Application, gPENDING_PROCESS_ID, Security.USER_ID);
						Response.Redirect(Request.RawUrl);
					}
					else
						this.ErrorText = "gPENDING_PROCESS_ID is empty";
				}
				catch(Exception ex)
				{
					this.ErrorText = ex.Message;
				}
			}
			else if ( e.CommandName == "Processes.Cancel" )
			{
				try
				{
					Guid gPENDING_PROCESS_ID = Sql.ToGuid(e.CommandArgument);
					if ( !Sql.IsEmptyGuid(gPENDING_PROCESS_ID) )
					{
						WF4ApprovalActivity.Cancel(Application, gPENDING_PROCESS_ID, Security.USER_ID);
						Response.Redirect(Request.RawUrl);
					}
					else
						this.ErrorText = "gPENDING_PROCESS_ID is empty";
				}
				catch(Exception ex)
				{
					this.ErrorText = ex.Message;
				}
			}
			else if ( e.CommandName == "Processes.ChangeUser" )
			{
				try
				{
					Guid gPENDING_PROCESS_ID = Sql.ToGuid(e.CommandArgument);
					if ( !Sql.IsEmptyGuid(gPENDING_PROCESS_ID) )
					{
						Guid   gPROCESS_USER_ID = Sql.ToGuid  (hidPROCESS_USER_ID.Value);
						string sPROCESS_NOTES   = Sql.ToString(hidPROCESS_NOTES  .Value);
						if ( !Sql.IsEmptyGuid(gPROCESS_USER_ID) )
						{
							if ( hidPROCESS_ACTION.Value == "ChangeProcessUser" )
							{
								WF4ApprovalActivity.ChangeProcessUser(Application, gPENDING_PROCESS_ID, gPROCESS_USER_ID, sPROCESS_NOTES);
								Response.Redirect(Request.RawUrl);
							}
							else if ( hidPROCESS_ACTION.Value == "ChangeAssignedUser" )
							{
								WF4ApprovalActivity.ChangeAssignedUser(Application, gPENDING_PROCESS_ID, gPROCESS_USER_ID, sPROCESS_NOTES);
								Response.Redirect(Request.RawUrl);
							}
						}
						else
							this.ErrorText = "gUSER_ID is empty";
					}
					else
						this.ErrorText = "gPENDING_PROCESS_ID is empty";
				}
				catch(Exception ex)
				{
					this.ErrorText = ex.Message;
				}
			}
			else if ( Command != null )
			{
				Command(this, e);
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
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
		}
		#endregion
	}
}

