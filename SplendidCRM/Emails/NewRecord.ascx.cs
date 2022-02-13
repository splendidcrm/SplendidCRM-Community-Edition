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
using System.IO;
using System.Data;
using System.Data.Common;
using System.Drawing;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
using CKEditor.NET;

namespace SplendidCRM.Emails
{
	/// <summary>
	///		Summary description for New.
	/// </summary>
	public class NewRecord : NewRecordControl
	{
		protected _controls.DynamicButtons ctlDynamicButtons;
		protected _controls.DynamicButtons ctlFooterButtons ;
		protected _controls.HeaderLeft     ctlHeaderLeft    ;
		protected _controls.TeamSelect     ctlTeamSelect    ;
		// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		protected _controls.UserSelect     ctlUserSelect    ;
		// 11/10/2010 Paul.  Convert EmailButtons.ascx to DynamicButtons. 

		protected Guid            gID                             ;
		protected HtmlTable       tblMain                         ;
		protected Label           lblError                        ;
		protected Panel           pnlMain                         ;
		protected Panel           pnlEdit                         ;

		// 05/06/2010 Paul.  We need a common way to attach a command from the Toolbar. 

		protected string          sEMAIL_STATUS                ;
		protected string          sEMAIL_TYPE                  ;
		protected HiddenField     ASSIGNED_USER_ID             ;
		protected TextBox         ASSIGNED_TO                  ;
		protected DropDownList    lstEMAIL_TEMPLATE            ;
		protected CheckBox        chkPREPEND_TEMPLATE          ;
		// 07/18/2013 Paul.  Add User Signatures. 
		protected DropDownList    lstSIGNATURE                 ;
		protected DropDownList    lstPARENT_TYPE               ;
		protected TextBox         txtPARENT_NAME               ;
		protected HiddenField     txtPARENT_ID                 ;
		protected TableRow        trNOTE_SEMICOLON             ;
		// 11/20/2005.  Not used by SugarCRM 3.5.1.
		// 07/21/2013 Paul.  From values will come from mailbox. 
		//protected HiddenField     txtFROM_NAME                 ;
		//protected TextBox         txtFROM_ADDR                 ;
		protected TextBox         txtTO_ADDRS                  ;
		protected TextBox         txtCC_ADDRS                  ;
		protected TextBox         txtBCC_ADDRS                 ;
		protected HiddenField     txtTO_ADDRS_IDS              ;
		protected HiddenField     txtTO_ADDRS_NAMES            ;
		protected HiddenField     txtTO_ADDRS_EMAILS           ;
		protected HiddenField     txtCC_ADDRS_IDS              ;
		protected HiddenField     txtCC_ADDRS_NAMES            ;
		protected HiddenField     txtCC_ADDRS_EMAILS           ;
		protected HiddenField     txtBCC_ADDRS_IDS             ;
		protected HiddenField     txtBCC_ADDRS_NAMES           ;
		protected HiddenField     txtBCC_ADDRS_EMAILS          ;
		protected TextBox         txtNAME                      ;
		// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
		protected CKEditorControl txtDESCRIPTION               ;
		// 04/16/2006 Paul.  The subject is not required. 
		//protected Label           lblNAME_REQUIRED             ;
		//protected RequiredFieldValidator reqNAME               ;
		// 03/31/2010 Paul.  Manually manage singular Team field. 
		protected TextBox         TEAM_NAME                    ;
		protected HiddenField     TEAM_ID                      ;
		protected TableRow               trDATE_START          ;
		protected HtmlGenericControl     spnTEMPLATE_LABEL     ;
		protected _controls.DateTimeEdit ctlDATE_START         ;
		protected Repeater               ctlAttachments        ;
		protected Repeater               ctlTemplateAttachments;
		protected HiddenField     hidREMOVE_LABEL              ;
		protected HiddenField     hidATTACHMENT_COUNT          ;
		// 07/18/2013 Paul.  Add support for multiple outbound emails. 
		protected DropDownList           MAILBOX_ID            ;
		protected RequiredFieldValidatorForDropDownList reqMAILBOX_ID;

		// 05/05/2010 Paul.  We need a common way to access the parent from the Toolbar. 

		// 04/20/2010 Paul.  Add functions to allow this control to be used as part of an InlineEdit operation. 
		public override bool IsEmpty()
		{
			// 03/05/2011 Paul.  The name will be the required field. 
			return Sql.IsEmptyString(txtNAME.Text);
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

		private string sCommandName = String.Empty;

		public override void Save(Guid gPARENT_ID, string sPARENT_TYPE, IDbTransaction trn)
		{
			if ( IsEmpty() )
				return;
			
			string    sTABLE_NAME    = Crm.Modules.TableName(m_sMODULE);
			DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
			
			Guid gASSIGNED_USER_ID  = new DynamicControl(this, "ASSIGNED_USER_ID").ID;
			Guid gTEAM_ID           = new DynamicControl(this, "TEAM_ID"         ).ID;
			if ( Sql.IsEmptyGuid(gASSIGNED_USER_ID) )
				gASSIGNED_USER_ID = Security.USER_ID;
			if ( Sql.IsEmptyGuid(gTEAM_ID) )
				gTEAM_ID = Security.TEAM_ID;
			
			try
			{
				if ( ctlDATE_START.Visible )
					ctlDATE_START.Validate();
				// 07/18/2013 Paul.  Add support for multiple outbound emails. 
				if ( reqMAILBOX_ID.Enabled )
					reqMAILBOX_ID.Validate();
				
				if ( Page.IsValid )
				{
					//txtDESCRIPTION     .Text  = txtDESCRIPTION     .Text .Trim();
					// 07/21/2013 Paul.  From values will come from mailbox. 
					//txtFROM_NAME       .Value = txtFROM_NAME       .Value.Trim();
					//txtFROM_ADDR       .Text  = txtFROM_ADDR       .Text .Trim();
					txtTO_ADDRS        .Text  = txtTO_ADDRS        .Text .Trim();
					txtCC_ADDRS        .Text  = txtCC_ADDRS        .Text .Trim();
					txtBCC_ADDRS       .Text  = txtBCC_ADDRS       .Text .Trim();
					txtTO_ADDRS_IDS    .Value = txtTO_ADDRS_IDS    .Value.Trim();
					txtTO_ADDRS_NAMES  .Value = txtTO_ADDRS_NAMES  .Value.Trim();
					txtTO_ADDRS_EMAILS .Value = txtTO_ADDRS_EMAILS .Value.Trim();
					txtCC_ADDRS_IDS    .Value = txtCC_ADDRS_IDS    .Value.Trim();
					txtCC_ADDRS_NAMES  .Value = txtCC_ADDRS_NAMES  .Value.Trim();
					txtCC_ADDRS_EMAILS .Value = txtCC_ADDRS_EMAILS .Value.Trim();
					txtBCC_ADDRS_IDS   .Value = txtBCC_ADDRS_IDS   .Value.Trim();
					txtBCC_ADDRS_NAMES .Value = txtBCC_ADDRS_NAMES .Value.Trim();
					txtBCC_ADDRS_EMAILS.Value = txtBCC_ADDRS_EMAILS.Value.Trim();
					if ( sCommandName == "Send" )
					{
						// 01/21/2006 Paul.  Mark an email as ready-to-send.   Type becomes "out" and Status stays at "draft". 
						if ( sEMAIL_TYPE == "draft" )
							sEMAIL_TYPE = "out";
						// 01/21/2006 Paul.  Address error only when sending. 
						if ( txtTO_ADDRS.Text.Length == 0 && txtCC_ADDRS.Text.Length == 0 && txtBCC_ADDRS.Text.Length == 0 )
							throw(new Exception(L10n.Term("Emails.ERR_NOT_ADDRESSED")));
					}
					// 11/20/2005 Paul.  SugarCRM 3.5.1 lets bad data flow through.  We clear the hidden values if the visible values are empty. 
					// There still is the issue of the data getting out of sync if the user manually edits the visible values. 
					if ( txtTO_ADDRS.Text.Length == 0 )
					{
						txtTO_ADDRS_IDS    .Value = String.Empty;
						txtTO_ADDRS_NAMES  .Value = String.Empty;
						txtTO_ADDRS_EMAILS .Value = String.Empty;
					}
					if ( txtCC_ADDRS.Text.Length == 0 )
					{
						txtCC_ADDRS_IDS    .Value = String.Empty;
						txtCC_ADDRS_NAMES  .Value = String.Empty;
						txtCC_ADDRS_EMAILS .Value = String.Empty;
					}
					if ( txtBCC_ADDRS.Text.Length == 0 )
					{
						txtBCC_ADDRS_IDS   .Value = String.Empty;
						txtBCC_ADDRS_NAMES .Value = String.Empty;
						txtBCC_ADDRS_EMAILS.Value = String.Empty;
					}
					
					// 04/24/2006 Paul.  Upgrade to SugarCRM 4.2 Schema. 
					// 06/01/2006 Paul.  MESSAGE_ID is now a text string. 
					// 12/29/2007 Paul.  TEAM_ID is now in the stored procedure. 
					// 03/31/2010 Paul.  Manually manage singular Team field. 
					if ( SplendidCRM.Crm.Config.enable_dynamic_teams() )
						gTEAM_ID = ctlTeamSelect.TEAM_ID;
					else
						gTEAM_ID = Sql.ToGuid(TEAM_ID.Value);
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					if ( SplendidCRM.Crm.Config.enable_dynamic_assignment() )
						gASSIGNED_USER_ID = ctlUserSelect.USER_ID;
					else
						gASSIGNED_USER_ID = Sql.ToGuid(ASSIGNED_USER_ID.Value);
					// 07/21/2013 Paul.  From values will come from mailbox. 
					string sFROM_ADDR = String.Empty;
					string sFROM_NAME = String.Empty;
					Guid gMAILBOX_ID  = new DynamicControl(this, "MAILBOX_ID").ID;
					if ( !Sql.IsEmptyGuid(gMAILBOX_ID) )
					{
						DataView vwOutboundMail = new DataView(SplendidCache.OutboundMail());
						vwOutboundMail.RowFilter = "ID = '" + gMAILBOX_ID.ToString() + "'";
						if ( vwOutboundMail.Count > 0 )
						{
							sFROM_ADDR = Sql.ToString(vwOutboundMail[0]["FROM_ADDR"]);
							sFROM_NAME = Sql.ToString(vwOutboundMail[0]["FROM_NAME"]);
						}
					}
					SqlProcs.spEMAILS_Update
						( ref gID
						, gASSIGNED_USER_ID
						, txtNAME.Text
						, T10n.ToServerTime(ctlDATE_START.Value)
						, lstPARENT_TYPE.SelectedValue
						, Sql.ToGuid(txtPARENT_ID.Value)
						// 04/16/2006 Paul.  Since the Plug-in saves body in DESCRIPTION, we need to continue to use it as the primary source of data. 
						, txtDESCRIPTION     .Text  // DESCRIPTION
						, txtDESCRIPTION     .Text  // DESCRIPTION_HTML
						// 07/03/2007 Paul.  From Address & From Name were switched. 
						// 07/21/2013 Paul.  From values will come from mailbox. 
						, sFROM_ADDR
						, sFROM_NAME
						, txtTO_ADDRS        .Text
						, txtCC_ADDRS        .Text
						, txtBCC_ADDRS       .Text
						, txtTO_ADDRS_IDS    .Value
						, txtTO_ADDRS_NAMES  .Value
						, txtTO_ADDRS_EMAILS .Value
						, txtCC_ADDRS_IDS    .Value
						, txtCC_ADDRS_NAMES  .Value
						, txtCC_ADDRS_EMAILS .Value
						, txtBCC_ADDRS_IDS   .Value
						, txtBCC_ADDRS_NAMES .Value
						, txtBCC_ADDRS_EMAILS.Value
						, sEMAIL_TYPE
						, new DynamicControl(this, "MESSAGE_ID"   ).Text
						, new DynamicControl(this, "REPLY_TO_NAME").Text
						, new DynamicControl(this, "REPLY_TO_ADDR").Text
						, new DynamicControl(this, "INTENT"       ).Text
						, gMAILBOX_ID
						, gTEAM_ID
						, ctlTeamSelect.TEAM_SET_LIST
						// 05/17/2017 Paul.  Add Tags module. 
						, new DynamicControl(this, "TAG_SET_NAME" ).Text
						// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
						, new DynamicControl(this, "IS_PRIVATE"   ).Checked
						// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
						, ctlUserSelect.ASSIGNED_SET_LIST
						, trn
						);
					
					// 10/18/2009 Paul.  Use a more generic way to get the files. 
					foreach ( string sHTML_FIELD_NAME in Request.Files.AllKeys )
					{
						// 05/07/2010 Paul.  The attachment name is not client specific. 
						if ( sHTML_FIELD_NAME.StartsWith(this.ClientID + "_attachment") )
						{
							HttpPostedFile pstATTACHMENT = Request.Files[sHTML_FIELD_NAME];
							if ( pstATTACHMENT != null )
							{
								long lFileSize      = pstATTACHMENT.ContentLength;
								long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
								if ( (lUploadMaxSize > 0) && (lFileSize > lUploadMaxSize) )
								{
									throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
								}
								// 08/20/2005 Paul.  File may not have been provided. 
								if ( pstATTACHMENT.FileName.Length > 0 )
								{
									string sFILENAME       = Path.GetFileName (pstATTACHMENT.FileName);
									string sFILE_EXT       = Path.GetExtension(sFILENAME);
									string sFILE_MIME_TYPE = pstATTACHMENT.ContentType;
								
									Guid gNOTE_ID = Guid.Empty;
									// 12/29/2007 Paul.  TEAM_ID is now in the stored procedure. 
									// 03/31/2010 Paul.  Manually manage singular Team field. 
									// 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
									// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
									SqlProcs.spNOTES_Update
										( ref gNOTE_ID
										, L10n.Term("Emails.LBL_EMAIL_ATTACHMENT") + ": " + sFILENAME
										, "Emails"   // Parent Type
										, gID        // Parent ID
										, Guid.Empty
										, String.Empty
										, gTEAM_ID
										, ctlTeamSelect.TEAM_SET_LIST
										, gASSIGNED_USER_ID
										// 05/17/2017 Paul.  Add Tags module. 
										, String.Empty  // TAG_SET_NAME
										// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
										, false         // IS_PRIVATE
										// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
										, ctlUserSelect.ASSIGNED_SET_LIST
										, trn
										);

									Guid gNOTE_ATTACHMENT_ID = Guid.Empty;
									// 01/20/2006 Paul.  Must include in transaction
									SqlProcs.spNOTE_ATTACHMENTS_Insert(ref gNOTE_ATTACHMENT_ID, gNOTE_ID, pstATTACHMENT.FileName, sFILENAME, sFILE_EXT, sFILE_MIME_TYPE, trn);
									// 11/06/2010 Paul.  Move LoadFile() to Crm.NoteAttachments. 
									Crm.NoteAttachments.LoadFile(gNOTE_ATTACHMENT_ID, pstATTACHMENT.InputStream, trn);
								}
							}
						}
					}
					// 02/05/2010 Paul.  If a Report Attachment was provided, then copy the note. 
					// 03/03/2010 Paul.  The NOTE_ID must be stored in the ViewState so that it can be cleared 
					// when successfully copied.  Otherwise we could get multiple copies. 
					if ( !Sql.IsEmptyGuid(ViewState["NOTE_ID"]) )
					{
						Guid gNOTE_ID = Guid.Empty;
						Guid gCOPY_ID = Sql.ToGuid(ViewState["NOTE_ID"]);
						SqlProcs.spNOTES_Copy(ref gNOTE_ID, gCOPY_ID, "Emails", gID, trn);
					}

					// 12/21/2007 Paul.  The NOTES table is used as a relationship table between emails and attachments. 
					// When applying an Email Template to an Email, we copy the NOTES records. 
					DataTable dtTemplateAttachments = ViewState["TemplateAttachments"] as DataTable;
					if ( dtTemplateAttachments != null )
					{
						foreach ( DataRow row in dtTemplateAttachments.Rows )
						{
							if ( row.RowState != DataRowState.Deleted )
							{
								Guid gNOTE_ID = Guid.Empty;
								Guid gCOPY_ID = Sql.ToGuid(row["ID"]);
								SqlProcs.spNOTES_Copy(ref gNOTE_ID, gCOPY_ID, "Emails", gID, trn);
							}
						}
					}
					// 10/26/2009 Paul.  KB attachments use the same Note Attachments table, but we still need to wrap it in a note. 
					DataTable dtKBAttachments = ViewState["KBAttachments"] as DataTable;
					if ( dtKBAttachments != null )
					{
						foreach ( DataRow row in dtKBAttachments.Rows )
						{
							if ( row.RowState != DataRowState.Deleted )
							{
								Guid gNOTE_ID = Guid.Empty;
								Guid gCOPY_ID = Sql.ToGuid(row["ID"]);
								SqlProcs.spKBDOCUMENTS_ATTACHMENTS_CreateNote(ref gNOTE_ID, gCOPY_ID, "Emails", gID, trn);
							}
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

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "NewRecord" || e.CommandName == "Save" || e.CommandName == "Send" )
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
									Guid   gPARENT_ID   = new DynamicControl(this, "PARENT_ID").ID;
									String sPARENT_TYPE = String.Empty;
									if ( Sql.IsEmptyGuid(gPARENT_ID) )
									{
										gPARENT_ID   = this.PARENT_ID  ;
										sPARENT_TYPE = this.PARENT_TYPE;
									}
									sCommandName = e.CommandName;
									Save(gPARENT_ID, sPARENT_TYPE, trn);
									trn.Commit();
									// 01/21/2006 Paul.  In case the SendMail function fails, we want to make sure to reuse the GUID. 
									ViewState["ID"] = gID;
									// 03/03/2010 Paul.  Clear the NOTE_ID if save was successful. 
									ViewState.Remove("NOTE_ID");
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									if ( bShowFullForm || bShowCancel )
										ctlFooterButtons.ErrorText = ex.Message;
									else
										lblError.Text = ex.Message;
									return;
								}
							}
						}
						int nEmailsSent = 0;
						if ( sCommandName == "Send" )
						{
							try
							{
								SqlProcs.spEMAILS_UpdateStatus(gID, "draft");
								// 12/20/2007 Paul.  SendEmail was moved to EmailUtils.
								// 05/19/2008 Paul.  Application is a required parameter so that SendEmail can be called within the scheduler. 
								// 11/05/2010 Paul.  Each user can have their own email account, but they all will share the same server. 
								// Remove all references to USER_SETTINGS/MAIL_FROMADDRESS and USER_SETTINGS/MAIL_FROMNAME. 
								EmailUtils.SendEmail(HttpContext.Current, gID, Security.FULL_NAME, Security.EMAIL1, ref nEmailsSent);
								SqlProcs.spEMAILS_UpdateStatus(gID, "sent");
							}
							catch(Exception ex)
							{
								// 05/15/2008 Paul.  Mark the status as error so that scheduler will not try to resend. 
								if ( nEmailsSent > 0 )
									SqlProcs.spEMAILS_UpdateStatus(gID, "partial");
								else
									SqlProcs.spEMAILS_UpdateStatus(gID, "send_error");
								SplendidError.SystemError(new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
								ctlDynamicButtons.ErrorText = Utils.ExpandException(ex);
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
						// 03/05/2011 Paul.  A containing control expects NewRecord and not Save or Send. 
						else if ( Command != null )
							Command(sender, new CommandEventArgs("NewRecord", gID.ToString()));
						else if ( !Sql.IsEmptyGuid(gID) )
							Response.Redirect("~/" + m_sMODULE + "/view.aspx?ID=" + gID.ToString());
					}
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
					lblError.Text = ex.Message;
			}
		}

		protected void lstEMAIL_TEMPLATE_Changed(Object sender, EventArgs e)
		{
			// 12/19/2006 Paul.  A customer wanted the ability to prevent users from changing a template. 
			if ( lstEMAIL_TEMPLATE.SelectedValue == String.Empty )
			{
				txtNAME.ReadOnly = false;
				txtDESCRIPTION.Toolbar = "SplendidCRM";
				// 09/18/2011 Paul.  Set the language for CKEditor. 
				txtDESCRIPTION.Language = L10n.NAME;
				return;
			}

			Guid gEMAIL_TEMPLATE_ID = Sql.ToGuid(lstEMAIL_TEMPLATE.SelectedValue);
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL ;
				sSQL = "select *                     " + ControlChars.CrLf
				     + "  from vwEMAIL_TEMPLATES_Edit" + ControlChars.CrLf
				     + " where ID = @ID              " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@ID", gEMAIL_TEMPLATE_ID);
					using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
					{
						if ( rdr.Read() )
						{
							// 03/05/2007 Michael.  We should use the Subject of the template, not the name.
							// 11/13/2006 Paul.  We switched to BODY_HTML a while back when FCKeditor was first implemented. 
							// 07/18/2013 Paul.  Allow template to be prepended to an email.  This is so that a reply can be prepended with a template response. 
							if ( chkPREPEND_TEMPLATE != null && chkPREPEND_TEMPLATE.Checked )
							{
								if ( Sql.IsEmptyString(txtNAME.Text) )
									txtNAME.Text = Sql.ToString(rdr["SUBJECT"]);
								txtDESCRIPTION.Text = Sql.ToString(rdr["BODY_HTML"]) + txtDESCRIPTION.Text;
							}
							else
							{
								txtNAME.Text         = Sql.ToString(rdr["SUBJECT"]);
								txtDESCRIPTION.Text = Sql.ToString(rdr["BODY_HTML"]);
							}

							// 12/19/2006 Paul.  Apply READ_ONLY rules. 
							bool bREAD_ONLY = Sql.ToBoolean(rdr["READ_ONLY"]);
							txtNAME.ReadOnly = bREAD_ONLY;
							// 12/19/2006 Paul.  Had to create an empty toolbar in ~/FCKeditor/fckconfig.js
							txtDESCRIPTION.Toolbar = bREAD_ONLY ? "None" : "SplendidCRM";
							// 09/18/2011 Paul.  Set the language for CKEditor. 
							txtDESCRIPTION.Language = L10n.NAME;
							if ( bREAD_ONLY )
							{
								// 12/19/2006 Paul.  We have to disable the editor in client-side code. 
								// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
								// 07/18/2013 Paul.  We are having trouble getting teh ready event, so just use a timer. 
								ScriptManager.RegisterStartupScript(this, System.Type.GetType("System.String"), "CKEditor_instanceReady_" + txtDESCRIPTION.ClientID, 
									"window.setTimeout(function() { if ( CKEDITOR !== undefined ) { CKEDITOR.instances['" + txtDESCRIPTION.ClientID + "'].setReadOnly(true); } }, 500);", true);
							}
						}
					}
				}
				sSQL = "select *                                     " + ControlChars.CrLf
				     + "  from vwEMAIL_TEMPLATES_Attachments         " + ControlChars.CrLf
				     + " where EMAIL_TEMPLATE_ID = @EMAIL_TEMPLATE_ID" + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@EMAIL_TEMPLATE_ID", gEMAIL_TEMPLATE_ID);
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						using ( DataTable dt = new DataTable() )
						{
							da.Fill(dt);
							ctlTemplateAttachments.DataSource = dt.DefaultView;
							ctlTemplateAttachments.DataBind();
							ViewState["TemplateAttachments"] = dt;
						}
					}
				}
			}
		}

		// 07/18/2013 Paul.  Add User Signatures. 
		protected void lstSIGNATURE_Changed(Object sender, EventArgs e)
		{
			if ( lstSIGNATURE.Items.Count > 0 )
			{
				Guid gSIGNATURE_ID = Sql.ToGuid(lstSIGNATURE.SelectedValue);
				DataView vw = new DataView(SplendidCache.UserSignatures());
				vw.RowFilter = "ID = '" + gSIGNATURE_ID.ToString() + "'";
				if ( vw.Count > 0 )
				{
					string sSIGNATURE_HTML = Sql.ToString(vw[0]["SIGNATURE_HTML"]);
					string sOLD_SIGNATURE = Sql.ToString(ViewState["SIGNATURE_HTML"]);
					if ( !Sql.IsEmptyString(sOLD_SIGNATURE) )
					{
						if ( txtDESCRIPTION.Text.StartsWith(sOLD_SIGNATURE) )
						{
							txtDESCRIPTION.Text = txtDESCRIPTION.Text.Substring(sOLD_SIGNATURE.Length);
						}
						// 09/10/2012 Paul.  The HTML editor can strip the CRL, so we need to check for that. 
						else if ( txtDESCRIPTION.Text.StartsWith(sOLD_SIGNATURE.Replace("\r\n", "\n")) )
						{
							txtDESCRIPTION.Text = txtDESCRIPTION.Text.Substring(sOLD_SIGNATURE.Replace("\r\n", "\n").Length);
						}
					}
					txtDESCRIPTION.Text = sSIGNATURE_HTML + txtDESCRIPTION.Text;
					ViewState["SIGNATURE_HTML"] = sSIGNATURE_HTML;
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 06/04/2006 Paul.  NewRecord should not be displayed if the user does not have edit rights. 
			// 01/02/2020 Paul.  Allow the NewRecord to be disabled per module using config table. 
			this.Visible = (!Sql.ToBoolean(Application["CONFIG." + m_sMODULE + ".DisableNewRecord"]) || sEditView != "NewRecord") && (SplendidCRM.Security.GetUserAccess(m_sMODULE, "edit") >= 0);
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
					// 02/21/2010 Paul.  When used in a SubPanel, this line does not get executed because 
					// the Page_Load happens after the user as clicked Create, which is a PostBack event. 
					this.AppendEditViewFields(m_sMODULE + "." + sEditView, tblMain, null, ctlFooterButtons.ButtonClientID("NewRecord"));
					// 06/04/2010 Paul.  Notify the parent that the fields have been loaded. 
					if ( EditViewLoad != null )
						EditViewLoad(this, null);
					
					// 02/21/2010 Paul.  When the Full Form buttons are used, we don't want the panel to have margins. 
					if ( bShowFullForm || bShowCancel || sEditView != "NewRecord" )
					{
						pnlMain.CssClass = "";
						pnlEdit.CssClass = "tabForm";
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						sEMAIL_TYPE = "draft";
						
						ctlDATE_START    .Visible = (sEMAIL_TYPE == "archived");
						trDATE_START     .Visible = (sEMAIL_TYPE == "archived");
						spnTEMPLATE_LABEL.Visible = (sEMAIL_TYPE == "draft"   );
						lstEMAIL_TEMPLATE.Visible = (sEMAIL_TYPE == "draft"   );
						// 07/18/2013 Paul.  Add User Signatures. 
						lstSIGNATURE     .Visible = (sEMAIL_TYPE == "draft"   );
						trNOTE_SEMICOLON .Visible = (sEMAIL_TYPE == "draft"   );
						// 07/18/2013 Paul.  Add support for multiple outbound emails. 
						MAILBOX_ID       .Visible = (sEMAIL_TYPE == "draft"   );
						reqMAILBOX_ID    .Enabled = (sEMAIL_TYPE == "draft"   );
						reqMAILBOX_ID.DataBind();
						ViewState["TYPE"] = sEMAIL_TYPE;
						
						lstPARENT_TYPE     .DataSource = SplendidCache.List("record_type_display");
						lstPARENT_TYPE     .DataBind();
						if ( lstEMAIL_TEMPLATE.Visible )
						{
							// 05/01/2020 Paul.  Cache EmailTemplates for use in React Client. 
							lstEMAIL_TEMPLATE.DataSource = SplendidCache.EmailTemplates();
							lstEMAIL_TEMPLATE.DataBind();
							lstEMAIL_TEMPLATE.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
						}
						// 07/18/2013 Paul.  Add User Signatures. 
						if ( sEMAIL_TYPE == "draft" )
						{
							lstSIGNATURE.DataSource = SplendidCache.UserSignatures();
							lstSIGNATURE.DataBind();
							// 09/10/2012 Paul.  Fire the event so that the signature will be populated. 
							lstSIGNATURE_Changed(null, null);
						}
						// 07/18/2013 Paul.  Add support for multiple outbound emails. 
						if ( sEMAIL_TYPE == "draft" )
						{
							DataTable dtOutboundMail = SplendidCache.OutboundMail();
							MAILBOX_ID.DataSource = dtOutboundMail;
							MAILBOX_ID.DataBind();
							if ( Sql.ToBoolean(Application["CONFIG.Emails.RequireSelectMailbox"]) )
								MAILBOX_ID.Items.Insert(0, new ListItem("", ""));
						}

						pnlMain.CssClass = "";
						pnlEdit.CssClass = "tabForm";
						
						Guid gPARENT_ID = this.PARENT_ID;
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
								txtPARENT_ID  .Value = gPARENT_ID.ToString();
								txtPARENT_NAME.Text  = sPARENT_NAME;
								try
								{
									// 08/19/2010 Paul.  Check the list before assigning the value. 
									Utils.SetSelectedValue(lstPARENT_TYPE, sPARENT_TYPE);
								}
								catch(Exception ex)
								{
									SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
								}
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
								// 11/15/2016 Paul.  Need to set values when not inherit. 
								else
								{
									ASSIGNED_TO     .Text  = Security.USER_NAME;
									ASSIGNED_USER_ID.Value = Security.USER_ID.ToString();
								}
								if ( Sql.ToBoolean(Application["CONFIG.inherit_team"]) )
								{
									new DynamicControl(this, "TEAM_ID"  ).ID   = gTEAM_ID  ;
									new DynamicControl(this, "TEAM_NAME").Text = sTEAM_NAME;
									if ( ctlTeamSelect != null )
										ctlTeamSelect.LoadLineItems(gTEAM_SET_ID, true, true);
								}
								// 11/15/2016 Paul.  Need to set values when not inherit. 
								else
								{
									TEAM_NAME.Text    = Security.TEAM_NAME;
									TEAM_ID.Value     = Security.TEAM_ID.ToString();
									ctlTeamSelect.LoadLineItems(Guid.Empty, true);
								}
								using ( IDbConnection con = dbf.CreateConnection() )
								{
									string sSQL ;
									// 10/14/2011 Paul.  Add RECIPIENT_ID and RECIPIENT_NAME. 
									sSQL = "select PARENT_ID             " + ControlChars.CrLf
									     + "     , PARENT_NAME           " + ControlChars.CrLf
									     + "     , EMAIL1                " + ControlChars.CrLf
									     + "     , RECIPIENT_ID          " + ControlChars.CrLf
									     + "     , RECIPIENT_NAME        " + ControlChars.CrLf
									     + "  from vwQUEUE_EMAIL_ADDRESS " + ControlChars.CrLf
									     + " where PARENT_ID = @PARENT_ID" + ControlChars.CrLf;
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.CommandText = sSQL;
										Sql.AddParameter(cmd, "@PARENT_ID", gPARENT_ID);
										con.Open();

										if ( bDebug )
											RegisterClientScriptBlock("vwQUEUE_EMAIL_ADDRESS", Sql.ClientScriptBlock(cmd));

										using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
										{
											txtTO_ADDRS       .Text  = String.Empty;
											txtTO_ADDRS_IDS   .Value = String.Empty;
											txtTO_ADDRS_NAMES .Value = String.Empty;
											txtTO_ADDRS_EMAILS.Value = String.Empty;
											// 09/05/2008 Paul.  Allow the possibility that there would be more than one email address associaed with the parent. 
											// vwQUEUE_EMAIL_ADDRESS has not been coded that way, but it may in the future. 
											while ( rdr.Read() )
											{
												// 05/13/2008 Paul.  Populate all address fields. 
												if ( txtTO_ADDRS       .Text .Length > 0 ) txtTO_ADDRS       .Text  += "; ";
												if ( txtTO_ADDRS_IDS   .Value.Length > 0 ) txtTO_ADDRS_IDS   .Value += ";";
												if ( txtTO_ADDRS_NAMES .Value.Length > 0 ) txtTO_ADDRS_NAMES .Value += ";";
												if ( txtTO_ADDRS_EMAILS.Value.Length > 0 ) txtTO_ADDRS_EMAILS.Value += ";";
												// 10/13/2011 Paul.  We need to return the recipient ID and not the parent ID. 
												txtTO_ADDRS       .Text  += EmailUtils.FormatEmailDisplayName(Sql.ToString(rdr["RECIPIENT_NAME"]), Sql.ToString(rdr["EMAIL1"]));
												txtTO_ADDRS_IDS   .Value += Sql.ToString(rdr["RECIPIENT_ID"  ]);
												txtTO_ADDRS_NAMES .Value += Sql.ToString(rdr["RECIPIENT_NAME"]);
												txtTO_ADDRS_EMAILS.Value += Sql.ToString(rdr["EMAIL1"        ]);
											}
										}
									}
								}
							}
						}
						// 11/15/2016 Paul.  New spPARENT_GetWithTeam procedure so that we can inherit Assigned To and Team values. 
						if ( Sql.IsEmptyGuid(gPARENT_ID) )
						{
							// 03/31/2010 Paul.  Manually manage singular Team field. 
							TEAM_NAME.Text    = Security.TEAM_NAME;
							TEAM_ID.Value     = Security.TEAM_ID.ToString();
							// 12/21/2006 Paul.  The team name should always default to the current user's private team. 
							// 08/23/2009 Paul.  Let the TeamSelect control manage the teams completely. 
							// 08/31/2009 Paul.  We only need to pass the TEAM_SET_ID. 
							ctlTeamSelect.LoadLineItems(Guid.Empty, true);
							
							// 12/21/2006 Paul.  Change Assigned To to a Change button. 
							ASSIGNED_TO     .Text  = Security.USER_NAME;
							ASSIGNED_USER_ID.Value = Security.USER_ID.ToString();
						}
						// 11/05/2010 Paul.  Each user can have their own email account, but they all will share the same server. 
						// Remove all references to USER_SETTINGS/MAIL_FROMADDRESS and USER_SETTINGS/MAIL_FROMNAME. 
						// 07/21/2013 Paul.  From values will come from mailbox. 
						//txtFROM_NAME    .Value = Security.FULL_NAME;
						//txtFROM_ADDR    .Text  = Security.EMAIL1;
					}
					// 10/20/2011 Paul.  Apply Business Rules to NewRecord. 
					this.ApplyEditViewNewEventRules(m_sMODULE + "." + sEditView);
				}
				else
				{
					sEMAIL_TYPE = Sql.ToString(ViewState["TYPE"]);
					// 07/18/2013 Paul.  Add support for multiple outbound emails. 
					reqMAILBOX_ID.Enabled = (sEMAIL_TYPE == "draft");
					reqMAILBOX_ID.DataBind();
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				if ( bShowFullForm || bShowCancel )
					ctlFooterButtons.ErrorText = ex.Message;
				else
					lblError.Text = ex.Message;
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
			
			// 11/29/2010 Paul.  Emails have a special Send button. 
			ctlDynamicButtons.AppendButtons("Emails.NewRecord", Guid.Empty, Guid.Empty);
			ctlFooterButtons .AppendButtons("Emails.NewRecord", Guid.Empty, Guid.Empty);
			ctlDynamicButtons.ShowButton   ("Cancel", bShowCancel);
			ctlFooterButtons .ShowButton   ("Cancel", bShowCancel);
			ctlDynamicButtons.EnableButton ("Send"  , !Sql.IsEmptyString(Security.EMAIL1));
			ctlFooterButtons .EnableButton ("Send"  , !Sql.IsEmptyString(Security.EMAIL1));
			m_sMODULE = "Emails";
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

