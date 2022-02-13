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
using System.Text;
using System.Data;
using System.Data.Common;
using System.Drawing;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Net;
using System.Net.Mail;
using System.Collections;
using System.Diagnostics;
// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
using CKEditor.NET;

namespace SplendidCRM.EmailClient
{
	/// <summary>
	///		Summary description for EditView.
	/// </summary>
	public class EditView : SplendidControl
	{
		protected _controls.TeamSelect                 ctlTeamSelect    ;
		// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		protected _controls.UserSelect                 ctlUserSelect    ;
		// 11/10/2010 Paul.  Convert EmailButtons.ascx to DynamicButtons. 
		protected _controls.DynamicButtons             ctlDynamicButtons;

		protected string          sEMAIL_STATUS                ;
		protected string          sEMAIL_TYPE                  ;
		protected Guid            gID                          ;
		protected HiddenField     ASSIGNED_USER_ID             ;
		protected TextBox         ASSIGNED_TO                  ;
		protected DropDownList    lstEMAIL_TEMPLATE            ;
		protected CheckBox        chkPREPEND_TEMPLATE          ;
		// 09/10/2012 Paul.  Add User Signatures. 
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

		public CommandEventHandler Command;

		public string NAME
		{
			get { return txtNAME.Text; }
			set { txtNAME.Text = value; }
		}

		public string TO_ADDRS
		{
			get { return txtTO_ADDRS.Text; }
			set { txtTO_ADDRS.Text = value; }
		}

		public string CC_ADDRS
		{
			get { return txtCC_ADDRS.Text; }
			set { txtCC_ADDRS.Text = value; }
		}

		public string DESCRIPTION
		{
			get { return txtDESCRIPTION.Text; }
			set { txtDESCRIPTION.Text = value; }
		}

		public void ClearForm()
		{
			try
			{
				sEMAIL_STATUS                = String.Empty;
				// 03/23/2012 Paul.  Email Type will always be draft. 
				sEMAIL_TYPE                  = "draft";
				gID                          = Guid.Empty;
				txtPARENT_NAME        .Text  = String.Empty;
				txtPARENT_ID          .Value = String.Empty;
				txtTO_ADDRS           .Text  = String.Empty;
				txtCC_ADDRS           .Text  = String.Empty;
				txtBCC_ADDRS          .Text  = String.Empty;
				txtTO_ADDRS_IDS       .Value = String.Empty;
				txtTO_ADDRS_NAMES     .Value = String.Empty;
				txtTO_ADDRS_EMAILS    .Value = String.Empty;
				txtCC_ADDRS_IDS       .Value = String.Empty;
				txtCC_ADDRS_NAMES     .Value = String.Empty;
				txtCC_ADDRS_EMAILS    .Value = String.Empty;
				txtBCC_ADDRS_IDS      .Value = String.Empty;
				txtBCC_ADDRS_NAMES    .Value = String.Empty;
				txtBCC_ADDRS_EMAILS   .Value = String.Empty;
				txtNAME               .Text  = String.Empty;
				txtDESCRIPTION        .Text  = String.Empty;

				hidREMOVE_LABEL              .Value = String.Empty;
				hidATTACHMENT_COUNT          .Value = String.Empty;

				// 04/16/2006 Paul.  The subject is not required. 
				//lblNAME_REQUIRED .Visible = (sEMAIL_TYPE == "archived");
				//reqNAME.Enabled          =  lblNAME_REQUIRED.Visible;
				ctlDATE_START    .Visible = (sEMAIL_TYPE == "archived");
				trDATE_START     .Visible =  ctlDATE_START.Visible;
				spnTEMPLATE_LABEL.Visible = (sEMAIL_TYPE == "draft"   );
				lstEMAIL_TEMPLATE.Visible = spnTEMPLATE_LABEL.Visible;
				trNOTE_SEMICOLON .Visible = (sEMAIL_TYPE == "draft"   );
				ViewState["TYPE"] = sEMAIL_TYPE;
				// 09/10/2012 Paul.  Add User Signatures. 
				ViewState["SIGNATURE_HTML"] = String.Empty;
				
				ctlAttachments.DataSource = null;
				ctlAttachments.DataBind();
				ctlTemplateAttachments.DataSource = null;
				ctlTemplateAttachments.DataBind();

				TEAM_NAME.Text    = Security.TEAM_NAME;
				TEAM_ID.Value     = Security.TEAM_ID.ToString();
				// 05/28/2010 Paul.  We have to make sure to not treat as a postback. 
				ctlTeamSelect.NotPostBack = true;
				ctlTeamSelect.LoadLineItems(Guid.Empty, true);
				
				ASSIGNED_TO     .Text  = Security.USER_NAME;
				ASSIGNED_USER_ID.Value = Security.USER_ID.ToString();
				// 11/05/2010 Paul.  Each user can have their own email account, but they all will share the same server. 
				// Remove all references to USER_SETTINGS/MAIL_FROMADDRESS and USER_SETTINGS/MAIL_FROMNAME. 
				// 07/21/2013 Paul.  From values will come from mailbox. 
				//txtFROM_NAME    .Value = Security.FULL_NAME;
				//txtFROM_ADDR    .Text  = Security.EMAIL1;

				lstPARENT_TYPE     .DataSource = SplendidCache.List("record_type_display");
				lstPARENT_TYPE     .DataBind();
				if ( lstEMAIL_TEMPLATE.Visible )
				{
					// 05/01/2020 Paul.  Cache EmailTemplates for use in React Client. 
					lstEMAIL_TEMPLATE.DataSource = SplendidCache.EmailTemplates();
					lstEMAIL_TEMPLATE.DataBind();
					lstEMAIL_TEMPLATE.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
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
			// 03/15/2014 Paul.  Enable override of concurrency error. 
			if ( e.CommandName == "Save" || e.CommandName == "SaveConcurrency" || e.CommandName == "Send" )
			{
				try
				{
					if ( ctlDATE_START.Visible )
						ctlDATE_START.Validate();
					// 07/18/2013 Paul.  Add support for multiple outbound emails. 
					if ( reqMAILBOX_ID.Enabled )
						reqMAILBOX_ID.Validate();
					
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
								sSQL = "select *            " + ControlChars.CrLf
								     + "  from vwEMAILS_Edit" + ControlChars.CrLf;
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

							// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
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
									if ( e.CommandName == "Send" )
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
									Guid gTEAM_ID = Guid.Empty;
									if ( SplendidCRM.Crm.Config.enable_dynamic_teams() )
										gTEAM_ID = ctlTeamSelect.TEAM_ID;
									else
										gTEAM_ID = Sql.ToGuid(TEAM_ID.Value);
									// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
									Guid gASSIGNED_USER_ID = Guid.Empty;
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
										, new DynamicControl(this, rowCurrent, "MESSAGE_ID"   ).Text
										, new DynamicControl(this, rowCurrent, "REPLY_TO_NAME").Text
										, new DynamicControl(this, rowCurrent, "REPLY_TO_ADDR").Text
										, new DynamicControl(this, rowCurrent, "INTENT"       ).Text
										, gMAILBOX_ID
										, gTEAM_ID
										, ctlTeamSelect.TEAM_SET_LIST
										// 05/17/2017 Paul.  Add Tags module. 
										, new DynamicControl(this, rowCurrent, "TAG_SET_NAME").Text
										// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
										, new DynamicControl(this, rowCurrent, "IS_PRIVATE"  ).Checked
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
														, String.Empty // TAG_SET_NAME
														// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
														, false        // IS_PRIVATE
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
									trn.Commit();
									// 01/21/2006 Paul.  In case the SendMail function fails, we want to make sure to reuse the GUID. 
									ViewState["ID"] = gID;
									// 03/03/2010 Paul.  Clear the NOTE_ID if save was successful. 
									ViewState.Remove("NOTE_ID");
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0),  Utils.ExpandException(ex));
									ctlDynamicButtons.ErrorText = Utils.ExpandException(ex);
									return;
								}
								int nEmailsSent = 0;
								if ( e.CommandName == "Send" )
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
										return;
									}
								}
							}
						}
						if ( Command != null )
							Command(this, e);
						else if ( !Sql.IsEmptyGuid(gPARENT_ID) )
							Response.Redirect("~/" + sMODULE + "/view.aspx?ID=" + gPARENT_ID.ToString());
						else if ( sEMAIL_TYPE == "draft" )
							Response.Redirect("default.aspx");
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
				if ( Command != null )
					Command(this, e);
				else if ( !Sql.IsEmptyGuid(gPARENT_ID) )
					Response.Redirect("~/" + sMODULE + "/view.aspx?ID=" + gPARENT_ID.ToString());
				// 09/07/2006 Paul.  If in draft mode, redirect to list.  Viewing a draft will re-direct you to edit mode.
				else if ( Sql.IsEmptyGuid(gID) || Sql.ToString(ViewState["TYPE"]) == "draft" )
					Response.Redirect("default.aspx");
				else
					Response.Redirect("view.aspx?ID=" + gID.ToString());
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
							// 04/12/2011 Paul.  Allow template to be prepended to an email.  This is so that a reply can be prepended with a template response. 
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

		// 05/18/2014 Paul.  Import the message if it does not already exist in the system so that we can include attachments in forward. 
		public void LoadEmailAttachments(Guid gEMAIL_ID)
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL ;
				sSQL = "select *                   " + ControlChars.CrLf
				     + "  from vwEMAILS_Attachments" + ControlChars.CrLf
				     + " where EMAIL_ID = @EMAIL_ID" + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@EMAIL_ID", gEMAIL_ID);
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						using ( DataTable dtAttachments = new DataTable() )
						{
							da.Fill(dtAttachments);
							ctlTemplateAttachments.DataSource = dtAttachments.DefaultView;
							ctlTemplateAttachments.DataBind();
							ViewState["TemplateAttachments"] = dtAttachments;
						}
					}
				}
			}
		}

		// 09/10/2012 Paul.  Add User Signatures. 
		public void lstSIGNATURE_Changed(Object sender, EventArgs e)
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
			SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
			// 03/23/2012 Paul.  The visible state is managed elsewhere. 
			//if ( !this.Visible )
			//	return;

			try
			{
				if ( !IsPostBack )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					sEMAIL_TYPE = Sql.ToString(Request["TYPE"]).ToLower();
					if ( sEMAIL_TYPE != "archived" )
						sEMAIL_TYPE = "draft";
					
					if ( Sql.IsEmptyGuid(gID) )
					{
						// 04/16/2006 Paul.  The subject is not required. 
						//lblNAME_REQUIRED .Visible = (sEMAIL_TYPE == "archived");
						//reqNAME.Enabled          =  lblNAME_REQUIRED.Visible;
						ctlDATE_START    .Visible = (sEMAIL_TYPE == "archived");
						trDATE_START     .Visible = (sEMAIL_TYPE == "archived");
						spnTEMPLATE_LABEL.Visible = (sEMAIL_TYPE == "draft"   );
						lstEMAIL_TEMPLATE.Visible = (sEMAIL_TYPE == "draft"   );
						// 09/10/2012 Paul.  Add User Signatures. 
						lstSIGNATURE     .Visible = (sEMAIL_TYPE == "draft"   );
						trNOTE_SEMICOLON .Visible = (sEMAIL_TYPE == "draft"   );
						// 07/18/2013 Paul.  Add support for multiple outbound emails. 
						MAILBOX_ID       .Visible = (sEMAIL_TYPE == "draft"   );
						reqMAILBOX_ID    .Enabled = (sEMAIL_TYPE == "draft"   );
						reqMAILBOX_ID.DataBind();
						ViewState["TYPE"] = sEMAIL_TYPE;
					}

					lstPARENT_TYPE     .DataSource = SplendidCache.List("record_type_display");
					lstPARENT_TYPE     .DataBind();
					if ( lstEMAIL_TEMPLATE.Visible )
					{
						// 05/01/2020 Paul.  Cache EmailTemplates for use in React Client. 
						lstEMAIL_TEMPLATE.DataSource = SplendidCache.EmailTemplates();
						lstEMAIL_TEMPLATE.DataBind();
						lstEMAIL_TEMPLATE.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
					}
					// 09/10/2012 Paul.  Add User Signatures. 
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
					string sRequestType = Sql.ToString(Request["type"]).ToLower();
					if ( !Sql.IsEmptyGuid(gID) )
					{
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							sSQL = "select *            " + ControlChars.CrLf
							     + "  from vwEMAILS_Edit" + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								// 11/24/2006 Paul.  Use new Security.Filter() function to apply Team and ACL security rules.
								Security.Filter(cmd, m_sMODULE, "edit");
								Sql.AppendParameter(cmd, gID, "ID", false);
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
											ViewState["ID"] = gID;

											// 02/18/2009 Paul.  On load, the focus should be set to the NAME field. 
											if ( txtNAME != null )
												txtNAME.Focus();

											txtNAME            .Text  = Sql.ToString(rdr["NAME"            ]);
											ctlDATE_START      .Value = T10n.FromServerTime(rdr["DATE_START"]);
											txtPARENT_ID       .Value = Sql.ToString(rdr["PARENT_ID"       ]);
											txtPARENT_NAME     .Text  = Sql.ToString(rdr["PARENT_NAME"     ]);
											// 07/21/2013 Paul.  From values will come from mailbox. 
											//txtFROM_NAME       .Value = Sql.ToString(rdr["FROM_NAME"       ]);
											//txtFROM_ADDR       .Text  = Sql.ToString(rdr["FROM_ADDR"       ]);

											txtTO_ADDRS        .Text  = Sql.ToString(rdr["TO_ADDRS"        ]);
											txtCC_ADDRS        .Text  = Sql.ToString(rdr["CC_ADDRS"        ]);
											txtBCC_ADDRS       .Text  = Sql.ToString(rdr["BCC_ADDRS"       ]);
											txtTO_ADDRS_IDS    .Value = Sql.ToString(rdr["TO_ADDRS_IDS"    ]);
											txtTO_ADDRS_NAMES  .Value = Sql.ToString(rdr["TO_ADDRS_NAMES"  ]);
											txtTO_ADDRS_EMAILS .Value = Sql.ToString(rdr["TO_ADDRS_EMAILS" ]);
											txtCC_ADDRS_IDS    .Value = Sql.ToString(rdr["CC_ADDRS_IDS"    ]);
											txtCC_ADDRS_NAMES  .Value = Sql.ToString(rdr["CC_ADDRS_NAMES"  ]);
											txtCC_ADDRS_EMAILS .Value = Sql.ToString(rdr["CC_ADDRS_EMAILS" ]);
											txtBCC_ADDRS_IDS   .Value = Sql.ToString(rdr["BCC_ADDRS_IDS"   ]);
											txtBCC_ADDRS_NAMES .Value = Sql.ToString(rdr["BCC_ADDRS_NAMES" ]);
											txtBCC_ADDRS_EMAILS.Value = Sql.ToString(rdr["BCC_ADDRS_EMAILS"]);

											// 04/16/2006 Paul.  Since the Plug-in saves body in DESCRIPTION, we need to continue to use it as the primary source of data. 
											string sDESCRIPTION      = Sql.ToString(rdr["DESCRIPTION"]);
											// 12/03/2008 Paul.  The plain-text description may not contain anything.  If HTML exists, then always use it. 
											string sDESCRIPTION_HTML = Sql.ToString(rdr["DESCRIPTION_HTML"]);
											if ( !Sql.IsEmptyString(sDESCRIPTION_HTML) )
											{
												sDESCRIPTION = sDESCRIPTION_HTML;
											}
											else
											{
												// 06/07/2009 Paul.  Email from the Outlook plug-in may not be in HTML, so we need to make it readable in the HTML editor. 
												// 06/04/2010 Paul.  Try and prevent excess blank lines. 
												sDESCRIPTION = EmailUtils.NormalizeDescription(sDESCRIPTION);
											}
											txtDESCRIPTION.Text = sDESCRIPTION;
											try
											{
												// 08/19/2010 Paul.  Check the list before assigning the value. 
												Utils.SetSelectedValue(lstPARENT_TYPE, Sql.ToString(rdr["PARENT_TYPE"]));
											}
											catch(Exception ex)
											{
												SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
											}
											// 07/18/2013 Paul.  Add support for multiple outbound emails. 
											try
											{
												Utils.SetSelectedValue(MAILBOX_ID, Sql.ToString(rdr["MAILBOX_ID"]));
											}
											catch(Exception ex)
											{
												SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
											}
											// 12/21/2006 Paul.  Change Assigned To to a Change button. 
											ASSIGNED_TO     .Text  = Sql.ToString(rdr["ASSIGNED_TO"     ]);
											ASSIGNED_USER_ID.Value = Sql.ToString(rdr["ASSIGNED_USER_ID"]);

											// 11/17/2005 Paul.  Archived emails allow editing of the Date & Time Sent. 
											sEMAIL_TYPE   = Sql.ToString(rdr["TYPE"  ]).ToLower();
											sEMAIL_STATUS = Sql.ToString(rdr["STATUS"]).ToLower();
											// 06/30/2007 Paul.  A forward or reply is just like a draft. 
											if ( sRequestType == "forward" || sRequestType == "reply" || sRequestType == "replyall" )
											{
												// 07/21/2013 Paul.  From values will come from mailbox. 
												string sFROM_NAME = Sql.ToString(rdr["FROM_NAME"]);
												string sFROM_ADDR = Sql.ToString(rdr["FROM_ADDR"]);
												string sFrom = EmailUtils.FormatEmailDisplayName(sFROM_NAME, sFROM_ADDR);
												// 06/30/2007 Paul.  We are going to use an HR tag as the delimiter. 
												string sReplyDelimiter = String.Empty;  //"> ";
												StringBuilder sbReplyHeader = new StringBuilder();
												//sbReplyHeader.Append(                  L10n.Term("Emails.LBL_FORWARD_HEADER") + "<br /><br />\r\n");
												sbReplyHeader.Append("<br />\r\n");
												sbReplyHeader.Append("<br />\r\n");
												sbReplyHeader.Append("<hr />\r\n");
												sbReplyHeader.Append(sReplyDelimiter + "<b>" + L10n.Term("Emails.LBL_FROM"     ) + "</b> " + sFrom.Trim()                   + "<br />\r\n");
												sbReplyHeader.Append(sReplyDelimiter + "<b>" + L10n.Term("Emails.LBL_DATE_SENT") + "</b> " + ctlDATE_START.Value.ToString() + "<br />\r\n");
												sbReplyHeader.Append(sReplyDelimiter + "<b>" + L10n.Term("Emails.LBL_TO"       ) + "</b> " + txtTO_ADDRS  .Text             + "<br />\r\n");
												sbReplyHeader.Append(sReplyDelimiter + "<b>" + L10n.Term("Emails.LBL_SUBJECT"  ) + "</b> " + txtNAME      .Text             + "<br />\r\n");
												sbReplyHeader.Append(sReplyDelimiter + "<br />\r\n");
												txtDESCRIPTION.Text = sbReplyHeader.ToString() + txtDESCRIPTION.Text;
												// 09/10/2012 Paul.  Fire the event so that the signature will be populated. 
												lstSIGNATURE_Changed(null, null);

												sEMAIL_TYPE = "draft";
												ASSIGNED_TO     .Text  = Security.USER_NAME;
												ASSIGNED_USER_ID.Value = Security.USER_ID.ToString();
												// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
												Guid gASSIGNED_SET_ID = Sql.ToGuid(rdr["ASSIGNED_SET_ID"]);
												ctlUserSelect.LoadLineItems(gASSIGNED_SET_ID, true);
												if ( sRequestType == "forward" )
												{
													txtTO_ADDRS        .Text  = String.Empty;
													txtTO_ADDRS_IDS    .Value = String.Empty;
													txtTO_ADDRS_NAMES  .Value = String.Empty;
													txtTO_ADDRS_EMAILS .Value = String.Empty;

													txtCC_ADDRS        .Text  = String.Empty;
													txtCC_ADDRS_IDS    .Value = String.Empty;
													txtCC_ADDRS_NAMES  .Value = String.Empty;
													txtCC_ADDRS_EMAILS .Value = String.Empty;
												}
												else if ( sRequestType == "reply" )
												{
													// 05/20/2009 Paul.  When replying, the FROM becomes the TO.  We were previously appending. 
													// 07/21/2013 Paul.  From values will come from mailbox. 
													//txtTO_ADDRS_IDS    .Value = String.Empty;
													txtTO_ADDRS        .Text  = sFROM_ADDR;
													txtTO_ADDRS_NAMES  .Value = sFROM_NAME;
													txtTO_ADDRS_EMAILS .Value = sFROM_ADDR;

													txtCC_ADDRS        .Text  = String.Empty;
													txtCC_ADDRS_IDS    .Value = String.Empty;
													txtCC_ADDRS_NAMES  .Value = String.Empty;
													txtCC_ADDRS_EMAILS .Value = String.Empty;
												}
												else if ( sRequestType == "replyall" )
												{
													// 05/20/2009 Paul.  When replying to all, we need to make sure that all fields are separated properly. 
													// 07/21/2013 Paul.  From values will come from mailbox. 
													if ( !Sql.IsEmptyString(txtTO_ADDRS        .Text ) && !Sql.IsEmptyString(sFROM_ADDR) ) txtTO_ADDRS       .Text  += ";";
													if ( !Sql.IsEmptyString(txtTO_ADDRS_NAMES  .Value) && !Sql.IsEmptyString(sFROM_NAME) ) txtTO_ADDRS_NAMES .Value += ";";
													if ( !Sql.IsEmptyString(txtTO_ADDRS_EMAILS .Value) && !Sql.IsEmptyString(sFROM_ADDR) ) txtTO_ADDRS_EMAILS.Value += ";";
													//txtTO_ADDRS_IDS    .Value = String.Empty;
													txtTO_ADDRS        .Text  += sFROM_ADDR;
													txtTO_ADDRS_NAMES  .Value += sFROM_NAME;
													txtTO_ADDRS_EMAILS .Value += sFROM_ADDR;
												}
												ctlDATE_START      .Value = DateTime.MinValue;
												// 11/05/2010 Paul.  Each user can have their own email account, but they all will share the same server. 
												// Remove all references to USER_SETTINGS/MAIL_FROMADDRESS and USER_SETTINGS/MAIL_FROMNAME. 
												// 07/21/2013 Paul.  From values will come from mailbox. 
												//txtFROM_NAME       .Value = Security.FULL_NAME;
												//txtFROM_ADDR       .Text  = Security.EMAIL1;
												txtBCC_ADDRS       .Text  = String.Empty;
												txtBCC_ADDRS_IDS   .Value = String.Empty;
												txtBCC_ADDRS_NAMES .Value = String.Empty;
												txtBCC_ADDRS_EMAILS.Value = String.Empty;
											}
											switch ( sEMAIL_TYPE )
											{
												case "archived":
													break;
												case "out":
													break;
												default:
													sEMAIL_TYPE = "draft";
													break;
											}
											// 12/20/2006 Paul.  Editing is not allowed for sent emails. 
											// 01/13/2008 Paul.  Editing is not allowed for campaign emails. 
											// 05/15/2008 Paul.  Allow editing of an email that previously generated a send_error. 
											if ( (sEMAIL_TYPE == "out" && sEMAIL_STATUS == "draft") || sEMAIL_TYPE == "sent" || sEMAIL_TYPE == "campaign" )
											{
												// 01/21/2006 Paul.  Editing is not allowed for sent emails. 
												Response.Redirect("view.aspx?ID=" + gID.ToString());
												return;
											}
											else if ( sEMAIL_TYPE == "inbound" )
											{
												// 01/13/2008 Paul.  Editing is not allowed for inbound emails, and they have their own viewer. 
												Response.Redirect("inbound.aspx?ID=" + gID.ToString());
												return;
											}
											// 04/16/2006 Paul.  The subject is not required. 
											//lblNAME_REQUIRED .Visible = (sEMAIL_TYPE == "archived");
											//reqNAME.Enabled = lblNAME_REQUIRED.Visible;
											ctlDATE_START    .Visible = (sEMAIL_TYPE == "archived");
											trDATE_START     .Visible = (sEMAIL_TYPE == "archived");
											spnTEMPLATE_LABEL.Visible = (sEMAIL_TYPE == "draft"   );
											lstEMAIL_TEMPLATE.Visible = (sEMAIL_TYPE == "draft"   );
											trNOTE_SEMICOLON .Visible = (sEMAIL_TYPE == "draft"   );

											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, rdr);
											ctlDynamicButtons.Visible  = !PrintView;
											ctlDynamicButtons.ShowButton  ("Save", (sEMAIL_TYPE == "draft"));
											ctlDynamicButtons.ShowButton  ("Send", (sEMAIL_TYPE == "draft"));
											ctlDynamicButtons.EnableButton("Send", !Sql.IsEmptyString(Security.EMAIL1));
											ViewState["TYPE"] = sEMAIL_TYPE;
											// 12/09/2008 Paul.  Throw an exception if the record has been edited since the last load. 
											ViewState["LAST_DATE_MODIFIED"] = Sql.ToDateTime(rdr["DATE_MODIFIED"]);
											
											// 01/28/2010 Paul.  Use ViewState and Page.Items to be compatible with the DetailViews. 
											ViewState ["NAME"            ] = Sql.ToString(rdr["NAME"            ]);
											ViewState ["ASSIGNED_USER_ID"] = Sql.ToGuid  (rdr["ASSIGNED_USER_ID"]);
											Page.Items["NAME"            ] = ViewState ["NAME"            ];
											Page.Items["ASSIGNED_USER_ID"] = ViewState ["ASSIGNED_USER_ID"];
											
											// 03/31/2010 Paul.  Manually manage singular Team field. 
											TEAM_NAME.Text    = Sql.ToString(rdr["TEAM_NAME"]);
											TEAM_ID.Value     = Sql.ToString(rdr["TEAM_ID"  ]);
											// 08/23/2009 Paul.  Let the TeamSelect control manage the teams completely. 
											// 08/31/2009 Paul.  We only need to pass the TEAM_SET_ID. 
											Guid gTEAM_SET_ID = Sql.ToGuid(rdr["TEAM_SET_ID"]);
											ctlTeamSelect.LoadLineItems(gTEAM_SET_ID, true);
										}
										else
										{
											// 03/31/2010 Paul.  Manually manage singular Team field. 
											TEAM_NAME.Text    = Security.TEAM_NAME;
											TEAM_ID.Value     = Security.TEAM_ID.ToString();
											// 08/23/2009 Paul.  Let the TeamSelect control manage the teams completely. 
											// 08/31/2009 Paul.  We only need to pass the TEAM_SET_ID. 
											ctlTeamSelect.LoadLineItems(Guid.Empty, true);
										}
									}
								}
							}
							sSQL = "select *                   " + ControlChars.CrLf
							     + "  from vwEMAILS_Attachments" + ControlChars.CrLf
							     + " where EMAIL_ID = @EMAIL_ID" + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@EMAIL_ID", gID);

								if ( bDebug )
									RegisterClientScriptBlock("vwEMAILS_Attachments", Sql.ClientScriptBlock(cmd));

								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dt = new DataTable() )
									{
										da.Fill(dt);
										ctlAttachments.DataSource = dt.DefaultView;
										ctlAttachments.DataBind();
									}
								}
							}
						}
					}
					else
					{
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						ctlDynamicButtons.Visible  = !PrintView;
						ctlDynamicButtons.ShowButton  ("Save", (sEMAIL_TYPE == "draft"));
						ctlDynamicButtons.ShowButton  ("Send", (sEMAIL_TYPE == "draft"));
						ctlDynamicButtons.EnableButton("Send", !Sql.IsEmptyString(Security.EMAIL1));
						
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
						// 11/05/2010 Paul.  Each user can have their own email account, but they all will share the same server. 
						// Remove all references to USER_SETTINGS/MAIL_FROMADDRESS and USER_SETTINGS/MAIL_FROMNAME. 
						//txtFROM_NAME    .Value = Security.FULL_NAME;
						//txtFROM_ADDR    .Text  = Security.EMAIL1;
					}
				}
				else
				{
					// 12/02/2005 Paul.  When validation fails, the header title does not retain its value.  Update manually. 
					sEMAIL_TYPE = Sql.ToString(ViewState["TYPE"]);
					// 07/18/2013 Paul.  Add support for multiple outbound emails. 
					reqMAILBOX_ID.Enabled = (sEMAIL_TYPE == "draft");
					reqMAILBOX_ID.DataBind();
					// 03/23/2012 Paul.  Need to add the dynamic buttons on postback. 
					ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
					ctlDynamicButtons.Visible  = !PrintView;
					ctlDynamicButtons.ShowButton  ("Save", (sEMAIL_TYPE == "draft"));
					ctlDynamicButtons.ShowButton  ("Send", (sEMAIL_TYPE == "draft"));
					ctlDynamicButtons.EnableButton("Send", !Sql.IsEmptyString(Security.EMAIL1));
					// 01/28/2010 Paul.  We need to restore the page items on each postback. 
					Page.Items["NAME"            ] = ViewState ["NAME"            ];
					Page.Items["ASSIGNED_USER_ID"] = ViewState ["ASSIGNED_USER_ID"];
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
			// CODEGEN: This Meeting is required by the ASP.NET Web Form Designer.
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
			m_sMODULE = "Emails";
			// 02/13/2007 Paul.  Emails should highlight the Activities menu. 
			// 05/26/2007 Paul.  We are display the emails tab, so we must highlight the tab. 
			SetMenu(m_sMODULE);
			// 04/19/2010 Paul.  New approach to EditView Relationships will distinguish between New Record and Existing Record.
			bool bNewRecord = Sql.IsEmptyGuid(Request["ID"]);
			if ( !IsPostBack )
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
		}
		#endregion
	}
}

