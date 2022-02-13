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
using CKEditor.NET;

namespace SplendidCRM.SmsMessages
{
	/// <summary>
	///		Summary description for EditView.
	/// </summary>
	public class EditView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		protected _controls.TeamSelect     ctlTeamSelect    ;
		// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		protected _controls.UserSelect     ctlUserSelect    ;
		protected _controls.DynamicButtons ctlFooterButtons ;

		protected string          sSMS_STATUS                  ;
		protected string          sSMS_TYPE                    ;
		protected Guid            gID                          ;
		protected HiddenField     ASSIGNED_USER_ID             ;
		protected TextBox         ASSIGNED_TO                  ;
		protected DropDownList    lstPARENT_TYPE               ;
		protected TextBox         txtPARENT_NAME               ;
		protected HiddenField     txtPARENT_ID                 ;
		protected TextBox         txtTO_NUMBER                 ;
		protected HiddenField     txtTO_NUMBER_ID              ;
		protected TextBox         txtNAME                      ;
		protected PlaceHolder     plcSubPanel                  ;
		protected TextBox         TEAM_NAME                    ;
		protected HiddenField     TEAM_ID                      ;
		protected RequiredFieldValidator reqNAME               ;
		protected RequiredFieldValidator reqTO_NUMBER          ;

		protected Label                  lblDATE_START         ;
		protected _controls.DateTimeEdit ctlDATE_START         ;
		protected Repeater               ctlAttachments        ;
		protected Repeater               ctlTemplateAttachments;
		protected HiddenField            hidREMOVE_LABEL       ;
		protected HiddenField            hidATTACHMENT_COUNT   ;
		protected DropDownList           MAILBOX_ID            ;
		protected RequiredFieldValidatorForDropDownList reqMAILBOX_ID;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
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
					if ( reqMAILBOX_ID.Enabled )
						reqMAILBOX_ID.Validate();
					
					this.ValidateEditViewFields(m_sMODULE + "." + LayoutEditView);
					this.ApplyEditViewValidationEventRules(m_sMODULE + "." + LayoutEditView);
					
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
					reqNAME     .Enabled = true;
					reqTO_NUMBER.Enabled = true;
					reqNAME     .Validate();
					reqTO_NUMBER.Validate();
					if ( Page.IsValid )
					{
						string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
						DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
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
											gID = Guid.Empty;
										}
									}
								}
							}
							
							this.ApplyEditViewPreSaveEventRules(m_sMODULE + "." + LayoutEditView, rowCurrent);
							
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									string sFROM_NUMBER = String.Empty;
									if ( e.CommandName == "Send" )
									{
										if ( sSMS_TYPE == "draft" )
											sSMS_TYPE = "out";
										if ( txtTO_NUMBER.Text.Length == 0 )
											throw(new Exception(L10n.Term("SmsMessages.ERR_NOT_ADDRESSED")));
									}
									
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
									Guid gMAILBOX_ID  = new DynamicControl(this, "MAILBOX_ID").ID;
									if ( !Sql.IsEmptyGuid(gMAILBOX_ID) )
									{
										DataView vwOutboundMail = new DataView(SplendidCache.OutboundSms());
										vwOutboundMail.RowFilter = "ID = '" + gMAILBOX_ID.ToString() + "'";
										if ( vwOutboundMail.Count > 0 )
										{
											sFROM_NUMBER = Sql.ToString(vwOutboundMail[0]["FROM_NUMBER"]);
										}
									}
									SqlProcs.spSMS_MESSAGES_Update
										( ref gID
										, gASSIGNED_USER_ID
										, gTEAM_ID
										, ctlTeamSelect.TEAM_SET_LIST
										, gMAILBOX_ID
										, txtNAME.Text
										, T10n.ToServerTime(ctlDATE_START.Value)
										, (!Sql.IsEmptyString(txtPARENT_ID.Value) ? lstPARENT_TYPE.SelectedValue : String.Empty)
										, Sql.ToGuid(txtPARENT_ID.Value)
										, sFROM_NUMBER
										, txtTO_NUMBER.Text
										, Sql.ToGuid(txtTO_NUMBER_ID.Value)
										, sSMS_TYPE
										, new DynamicControl(this, rowCurrent, "MESSAGE_ID"   ).Text
										, new DynamicControl(this, rowCurrent, "FROM_LOCATION").Text
										, new DynamicControl(this, rowCurrent, "TO_LOCATION"  ).Text
										// 05/17/2017 Paul.  Add Tags module. 
										, new DynamicControl(this, rowCurrent, "TAG_SET_NAME" ).Text
										// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
										, new DynamicControl(this, rowCurrent, "IS_PRIVATE"   ).Checked
										// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
										, ctlUserSelect.ASSIGNED_SET_LIST
										, trn
										);
									
									foreach ( string sHTML_FIELD_NAME in Request.Files.AllKeys )
									{
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
												if ( pstATTACHMENT.FileName.Length > 0 )
												{
													string sFILENAME       = Path.GetFileName (pstATTACHMENT.FileName);
													string sFILE_EXT       = Path.GetExtension(sFILENAME);
													string sFILE_MIME_TYPE = pstATTACHMENT.ContentType;
													Guid gIMAGE_ID = Guid.Empty;
													SqlProcs.spEMAIL_IMAGES_Insert
														( ref gIMAGE_ID
														, gID
														, sFILENAME
														, sFILE_EXT
														, sFILE_MIME_TYPE
														, trn
														);
													Crm.EmailImages.LoadFile(gIMAGE_ID, pstATTACHMENT.InputStream, trn);
												}
											}
										}
									}
									DataTable dtAttachments = ViewState["Attachments"] as DataTable;
									if ( dtAttachments != null )
									{
										foreach ( DataRow row in dtAttachments.Rows )
										{
											if ( row.RowState == DataRowState.Deleted )
											{
												Guid gIMAGE_ID = Sql.ToGuid(row["ID", DataRowVersion.Original]);
												SqlProcs.spEMAIL_IMAGES_Delete(gIMAGE_ID, trn);
											}
										}
									}
									
									DataTable dtTemplateAttachments = ViewState["TemplateAttachments"] as DataTable;
									if ( dtTemplateAttachments != null )
									{
										foreach ( DataRow row in dtTemplateAttachments.Rows )
										{
											if ( row.RowState != DataRowState.Deleted )
											{
												Guid gIMAGE_ID = Guid.Empty;
												Guid gCOPY_ID = Sql.ToGuid(row["ID"]);
												SqlProcs.spEMAIL_IMAGES_Copy(ref gIMAGE_ID, gCOPY_ID, gID, trn);
											}
										}
									}
									SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
									SqlProcs.spTRACKER_Update
										( Security.USER_ID
										, m_sMODULE
										, gID
										, txtNAME.Text
										, "save"
										, trn
										);
									if ( plcSubPanel.Visible )
									{
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
									ViewState["ID"] = gID;
									SplendidCache.ClearFavorites();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0),  Utils.ExpandException(ex));
									ctlDynamicButtons.ErrorText = Utils.ExpandException(ex);
									return;
								}
								if ( e.CommandName == "Send" )
								{
									try
									{
										SqlProcs.spSMS_MESSAGES_UpdateStatus(gID, "draft", String.Empty);
										if ( !Utils.IsOfflineClient )
										{
											string sMESSAGE_SID = TwilioManager.SendText(Application, gID);
											// 12/27/2020 Paul.  Don't mark as sent if we did not get a SID. 
											if ( !Sql.IsEmptyString(sMESSAGE_SID) )
												SqlProcs.spSMS_MESSAGES_UpdateStatus(gID, "sent", sMESSAGE_SID);
										}
									}
									catch(Exception ex)
									{
										SqlProcs.spSMS_MESSAGES_UpdateStatus(gID, "send_error", String.Empty);
										SplendidError.SystemError(new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
										ctlDynamicButtons.ErrorText = Utils.ExpandException(ex);
										return;
									}
								}
							}
							rowCurrent = Crm.Modules.ItemEdit(m_sMODULE, gID);
							this.ApplyEditViewPostSaveEventRules(m_sMODULE + "." + LayoutEditView, rowCurrent);
						}
						if ( !Sql.IsEmptyString(RulesRedirectURL) )
							Response.Redirect(RulesRedirectURL);
						else if ( !Sql.IsEmptyGuid(gPARENT_ID) )
							Response.Redirect("~/" + sMODULE + "/view.aspx?ID=" + gPARENT_ID.ToString());
						else if ( sSMS_TYPE == "draft" )
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
				if ( !Sql.IsEmptyGuid(gPARENT_ID) )
					Response.Redirect("~/" + sMODULE + "/view.aspx?ID=" + gPARENT_ID.ToString());
				else if ( Sql.IsEmptyGuid(gID) || Sql.ToString(ViewState["TYPE"]) == "draft" )
					Response.Redirect("default.aspx");
				else
					Response.Redirect("view.aspx?ID=" + gID.ToString());
			}
			else if ( e.CommandName == "Attachments.Delete" )
			{
				Guid gIMAGE_ID = Sql.ToGuid(e.CommandArgument);
				DataTable dt = ViewState["Attachments"] as DataTable;
				if ( dt != null && !Sql.IsEmptyGuid(gIMAGE_ID) )
				{
					foreach ( DataRow row in dt.Rows )
					{
						if ( gIMAGE_ID == Sql.ToGuid(row["ID"]) )
						{
							row.Delete();
						}
					}
					ctlAttachments.DataSource = dt.DefaultView;
					ctlAttachments.DataBind();
					ViewState["Attachments"] = dt;
				}
			}
			else if ( e.CommandName == "TemplateAttachments.Delete" )
			{
				Guid gIMAGE_ID = Sql.ToGuid(e.CommandArgument);
				DataTable dt = ViewState["TemplateAttachments"] as DataTable;
				if ( dt != null && !Sql.IsEmptyGuid(gIMAGE_ID) )
				{
					foreach ( DataRow row in dt.Rows )
					{
						if ( gIMAGE_ID == Sql.ToGuid(row["ID"]) )
						{
							row.Delete();
						}
					}
					ctlTemplateAttachments.DataSource = dt.DefaultView;
					ctlTemplateAttachments.DataBind();
					ViewState["TemplateAttachments"] = dt;
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				gID = Sql.ToGuid(ViewState["ID"]);
				reqNAME     .DataBind();
				reqTO_NUMBER.DataBind();
				if ( !IsPostBack )
				{
					if ( Sql.IsEmptyGuid(gID) )
						gID = Sql.ToGuid(Request["ID"]);
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					sSMS_TYPE = Sql.ToString(Request["TYPE"]).ToLower();
					if ( sSMS_TYPE != "archived" )
						sSMS_TYPE = "draft";
					
					if ( Sql.IsEmptyGuid(gID) )
					{
						// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
						ctlDynamicButtons.EnableModuleLabel = false;
						if ( sSMS_TYPE == "archived" )
							ctlDynamicButtons.Title = "<a href=\"default.aspx\">" + L10n.Term("SmsMessages.LBL_ARCHIVED_MODULE_NAME") + "</a><span class=\"pointer\">&raquo;</span>";
						else
							ctlDynamicButtons.Title = "<a href=\"default.aspx\">" + L10n.Term("SmsMessages.LBL_NEW_FORM_TITLE") + "</a><span class=\"pointer\">&raquo;</span>";
						ctlDATE_START.Visible = (sSMS_TYPE == "archived");
						lblDATE_START.Visible = (sSMS_TYPE == "archived");
						MAILBOX_ID   .Visible = (sSMS_TYPE == "draft"   );
						reqMAILBOX_ID.Enabled = (sSMS_TYPE == "draft"   );
						reqMAILBOX_ID.DataBind();
						ViewState["TYPE"] = sSMS_TYPE;
						ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
						txtTO_NUMBER.Focus();
					}

					lstPARENT_TYPE.DataSource = SplendidCache.List("record_type_display");
					lstPARENT_TYPE.DataBind();
					int nMAILBOX_COUNT = 0;
					if ( sSMS_TYPE == "draft" )
					{
						DataTable dtOutboundSms = SplendidCache.OutboundSms();
						MAILBOX_ID.DataSource = dtOutboundSms;
						MAILBOX_ID.DataBind();
						nMAILBOX_COUNT = dtOutboundSms.Rows.Count;
						if ( Sql.ToBoolean(Application["CONFIG.SmsMessages.RequireSelectMailbox"]) )
							MAILBOX_ID.Items.Insert(0, new ListItem("", ""));
					}
					string sRequestType = Sql.ToString(Request["type"]).ToLower();
					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
							sSQL = "select *"               + ControlChars.CrLf
							     + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
							     + "  from " + m_sVIEW_NAME + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
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
								con.Open();
								
								if ( bDebug )
									RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));
								
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
											this.ApplyEditViewPreLoadEventRules(m_sMODULE + "." + LayoutEditView, rdr);
											
											ctlDynamicButtons.Title += Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
											ViewState["ID"] = gID;
											
											if ( txtNAME != null )
												txtNAME.Focus();
											
											txtNAME       .Text  = Sql.ToString(rdr["NAME"            ]);
											ctlDATE_START .Value = T10n.FromServerTime(rdr["DATE_START"]);
											txtPARENT_ID  .Value = Sql.ToString(rdr["PARENT_ID"       ]);
											txtPARENT_NAME.Text  = Sql.ToString(rdr["PARENT_NAME"     ]);
											
											try
											{
												Utils.SetSelectedValue(lstPARENT_TYPE, Sql.ToString(rdr["PARENT_TYPE"]));
											}
											catch(Exception ex)
											{
												SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
											}
											try
											{
												Utils.SetSelectedValue(MAILBOX_ID, Sql.ToString(rdr["MAILBOX_ID"]));
											}
											catch(Exception ex)
											{
												SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
											}
											ASSIGNED_TO     .Text  = Sql.ToString(rdr["ASSIGNED_TO"     ]);
											ASSIGNED_USER_ID.Value = Sql.ToString(rdr["ASSIGNED_USER_ID"]);
											// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
											Guid gASSIGNED_SET_ID = Sql.ToGuid(rdr["ASSIGNED_SET_ID"]);
											ctlUserSelect.LoadLineItems(gASSIGNED_SET_ID, true);
											
											sSMS_TYPE   = Sql.ToString(rdr["TYPE"  ]).ToLower();
											sSMS_STATUS = Sql.ToString(rdr["STATUS"]).ToLower();
											if ( !Sql.IsEmptyGuid(gDuplicateID) )
											{
												sSMS_TYPE   = "draft";
												sSMS_STATUS = "draft";
											}
											if ( sRequestType == "forward" || sRequestType == "reply" || sRequestType == "replyall" )
											{
												string sFROM_NUMBER = Sql.ToString(rdr["FROM_NUMBER"]);
												sSMS_TYPE = "draft";
												ASSIGNED_TO     .Text  = Security.USER_NAME;
												ASSIGNED_USER_ID.Value = Security.USER_ID.ToString();
												if ( sRequestType == "reply" )
												{
													txtTO_NUMBER.Text  = sFROM_NUMBER;
												}
												ctlDATE_START.Value = DateTime.MinValue;
												if ( Sql.ToString(rdr["PARENT_TYPE"]) == "Cases" )
												{
													Guid gPARENT_ID = Sql.ToGuid(rdr["PARENT_ID"]);
													string sMacro = Crm.Config.inbound_email_case_subject_macro().Replace("%1", gPARENT_ID.ToString());
													string sNAME = Sql.ToString(rdr["NAME"]);
													if ( !sNAME.ToLower().Contains(sMacro.ToLower()) )
													{
														if (sNAME.Length + sMacro.Length + 1 > 200 )
														{
															sNAME = sNAME.Substring(0, 200 - sMacro.Length);
														}
														txtNAME.Text = sNAME + " " + sMacro;
													}
												}
												else if ( !Sql.IsEmptyString(Request["CASE_ID"]) )
												{
													Guid gPARENT_ID = Sql.ToGuid(Request["CASE_ID"]);
													string sMacro = Crm.Config.inbound_email_case_subject_macro().Replace("%1", gPARENT_ID.ToString());
													string sNAME = Sql.ToString(rdr["NAME"]);
													if ( !sNAME.ToLower().Contains(sMacro.ToLower()) )
													{
														if (sNAME.Length + sMacro.Length + 1 > 200 )
														{
															sNAME = sNAME.Substring(0, 200 - sMacro.Length);
														}
														txtNAME.Text = sNAME + " " + sMacro;
													}
												}
											}
											else
											{
												txtTO_NUMBER   .Text  = Sql.ToString(rdr["TO_NUMBER"]);
												txtTO_NUMBER_ID.Value = Sql.ToString(rdr["TO_ID"    ]);
											}
											if ( sRequestType == "forward" || sRequestType == "reply_attachments" || !Sql.IsEmptyGuid(gDuplicateID) )
											{
												sSQL = "select *                         " + ControlChars.CrLf
												     + "  from vwSMS_MESSAGES_Attachments" + ControlChars.CrLf
												     + " where PARENT_ID = @PARENT_ID    " + ControlChars.CrLf;
												cmd.Parameters.Clear();
												cmd.CommandText = sSQL;
												Sql.AddParameter(cmd, "@PARENT_ID", gDuplicateID);
												if ( bDebug )
													RegisterClientScriptBlock("vwSMS_MESSAGES_Attachments", Sql.ClientScriptBlock(cmd));
												((IDbDataAdapter)da).SelectCommand = cmd;
												using ( DataTable dtAttachments = new DataTable() )
												{
													da.Fill(dtAttachments);
													ctlTemplateAttachments.DataSource = dtAttachments.DefaultView;
													ctlTemplateAttachments.DataBind();
													ViewState["TemplateAttachments"] = dtAttachments;
												}
											}
											if ( (sSMS_TYPE == "out" && sSMS_STATUS == "draft") || sSMS_TYPE == "sent" || sSMS_TYPE == "campaign" )
											{
												Response.Redirect("view.aspx?ID=" + gID.ToString());
												return;
											}
											else if ( sSMS_TYPE == "inbound" )
											{
												Response.Redirect("inbound.aspx?ID=" + gID.ToString());
												return;
											}
											switch ( sSMS_TYPE )
											{
												case "archived":
													// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
													ctlDynamicButtons.Title = "<a href=\"default.aspx\">" + L10n.Term("SmsMessages.LBL_ARCHIVED_MODULE_NAME") + "</a><span class=\"pointer\">&raquo;</span>" + txtNAME.Text;
													break;
												case "out":
													// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
													ctlDynamicButtons.Title = "<a href=\"default.aspx\">" + L10n.Term("SmsMessages.LBL_LIST_FORM_SENT_TITLE") + "</a><span class=\"pointer\">&raquo;</span>" + txtNAME.Text;
													break;
												default:
													sSMS_TYPE = "draft";
													// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
													ctlDynamicButtons.Title = "<a href=\"default.aspx\">" + L10n.Term("SmsMessages.LBL_NEW_FORM_TITLE" ) + "</a><span class=\"pointer\">&raquo;</span>" + txtNAME.Text;
													break;
											}
											ctlDATE_START.Visible = (sSMS_TYPE == "archived");
											lblDATE_START.Visible = (sSMS_TYPE == "archived");
											ctlDynamicButtons.EnableModuleLabel = false;
											
											ViewState["TYPE"] = sSMS_TYPE;
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											ctlDynamicButtons.Visible  = !PrintView;
											ctlDynamicButtons.ShowButton  ("Save", (sSMS_TYPE == "draft" || sSMS_TYPE == "archived"));
											ctlDynamicButtons.ShowButton  ("Send", (sSMS_TYPE == "draft"));
											ctlDynamicButtons.EnableButton("Send", nMAILBOX_COUNT > 0);
											ctlFooterButtons .Visible  = !PrintView;
											ctlFooterButtons .ShowButton  ("Save", (sSMS_TYPE == "draft" || sSMS_TYPE == "archived"));
											ctlFooterButtons .ShowButton  ("Send", (sSMS_TYPE == "draft"));
											ctlFooterButtons .EnableButton("Send", nMAILBOX_COUNT > 0);
											ViewState["LAST_DATE_MODIFIED"] = Sql.ToDateTime(rdr["DATE_MODIFIED"]);
											
											ViewState ["NAME"            ] = Sql.ToString(rdr["NAME"            ]);
											ViewState ["ASSIGNED_USER_ID"] = Sql.ToGuid  (rdr["ASSIGNED_USER_ID"]);
											Page.Items["NAME"            ] = ViewState ["NAME"            ];
											Page.Items["ASSIGNED_USER_ID"] = ViewState ["ASSIGNED_USER_ID"];
											
											TEAM_NAME.Text    = Sql.ToString(rdr["TEAM_NAME"]);
											TEAM_ID.Value     = Sql.ToString(rdr["TEAM_ID"  ]);
											Guid gTEAM_SET_ID = Sql.ToGuid(rdr["TEAM_SET_ID"]);
											ctlTeamSelect.LoadLineItems(gTEAM_SET_ID, true);
											this.ApplyEditViewPostLoadEventRules(m_sMODULE + "." + LayoutEditView, rdr);
										}
										else
										{
											TEAM_NAME.Text    = Security.TEAM_NAME;
											TEAM_ID.Value     = Security.TEAM_ID.ToString();
											ctlTeamSelect.LoadLineItems(Guid.Empty, true);
											
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
											ctlFooterButtons .DisableAll();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
											plcSubPanel.Visible = false;
										}
									}
								}
							}
							if ( !Sql.IsEmptyGuid(gID) )
							{
								sSQL = "select *                         " + ControlChars.CrLf
								     + "  from vwSMS_MESSAGES_Attachments" + ControlChars.CrLf
								     + " where PARENT_ID = @PARENT_ID    " + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@PARENT_ID", gID);
									if ( bDebug )
										RegisterClientScriptBlock("vwSMS_MESSAGES_Attachments", Sql.ClientScriptBlock(cmd));
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										using ( DataTable dt = new DataTable() )
										{
											da.Fill(dt);
											ctlAttachments.DataSource = dt.DefaultView;
											ctlAttachments.DataBind();
											ViewState["Attachments"] = dt;
										}
									}
								}
							}
						}
					}
					else
					{
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						ctlDynamicButtons.Visible  = !PrintView;
						ctlDynamicButtons.ShowButton  ("Save", (sSMS_TYPE == "draft" || sSMS_TYPE == "archived"));
						ctlDynamicButtons.ShowButton  ("Send", (sSMS_TYPE == "draft"));
						ctlDynamicButtons.EnableButton("Send", nMAILBOX_COUNT > 0);
						ctlFooterButtons .Visible  = !PrintView;
						ctlFooterButtons .ShowButton  ("Save", (sSMS_TYPE == "draft" || sSMS_TYPE == "archived"));
						ctlFooterButtons .ShowButton  ("Send", (sSMS_TYPE == "draft"));
						ctlFooterButtons .EnableButton("Send", nMAILBOX_COUNT > 0);
						
						if ( txtNAME != null )
							txtNAME.Focus();
						
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
								txtPARENT_ID  .Value = gPARENT_ID.ToString();
								txtPARENT_NAME.Text  = sPARENT_NAME;
								try
								{
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
								if ( sPARENT_TYPE == "Cases" )
								{
									string sMacro = Crm.Config.inbound_email_case_subject_macro();
									txtNAME.Text = sMacro.Replace("%1", gPARENT_ID.ToString());
								}
								else if ( sPARENT_TYPE == "Contacts" || sPARENT_TYPE == "Leads" || sPARENT_TYPE == "Prospects" || sPARENT_TYPE == "Users" )
								{
									string sTABLE_NAME = Crm.Modules.TableName(sPARENT_TYPE);
									using ( IDbConnection con = dbf.CreateConnection() )
									{
										string sSQL ;
										// 08/11/2014 Paul.  Apply standard security rules when looking up the phone number. 
										sSQL = "select PHONE_MOBILE   " + ControlChars.CrLf
										     + "     , ID             " + ControlChars.CrLf
										     + "     , NAME           " + ControlChars.CrLf
										     + "  from vw" + sTABLE_NAME + "_SmsNumbers" + ControlChars.CrLf;
										using ( IDbCommand cmd = con.CreateCommand() )
										{
											cmd.CommandText = sSQL;
											Security.Filter(cmd, sPARENT_TYPE, "list");
											Sql.AppendParameter(cmd, gPARENT_ID, "ID");
											con.Open();
											
											if ( bDebug )
												RegisterClientScriptBlock("vw" + sTABLE_NAME + "_SmsNumbers", Sql.ClientScriptBlock(cmd));
											
											using ( IDataReader rdr = cmd.ExecuteReader() )
											{
												if ( rdr.Read() )
												{
													txtTO_NUMBER   .Text  = Sql.ToString(rdr["PHONE_MOBILE"]);
													txtTO_NUMBER_ID.Value = Sql.ToString(rdr["ID"          ]);
												}
											}
										}
									}
								}
							}
						}
						// 11/15/2016 Paul.  New spPARENT_GetWithTeam procedure so that we can inherit Assigned To and Team values. 
						if ( Sql.IsEmptyGuid(gPARENT_ID) )
						{
							TEAM_NAME.Text    = Security.TEAM_NAME;
							TEAM_ID.Value     = Security.TEAM_ID.ToString();
							ctlTeamSelect.LoadLineItems(Guid.Empty, true);
						
							ASSIGNED_TO     .Text  = Security.USER_NAME;
							ASSIGNED_USER_ID.Value = Security.USER_ID.ToString();
						}
						this.ApplyEditViewNewEventRules(m_sMODULE + "." + LayoutEditView);
					}
				}
				else
				{
					// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
					if ( Sql.IsEmptyGuid(gID) )
						ctlDynamicButtons.EnableModuleLabel = false;
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
					sSMS_TYPE = Sql.ToString(ViewState["TYPE"]);
					reqMAILBOX_ID.Enabled = (sSMS_TYPE == "draft");
					reqMAILBOX_ID.DataBind();
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
			ctlFooterButtons .Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "SmsMessages";
			// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
			m_sVIEW_NAME = "vw" + Crm.Modules.TableName(m_sMODULE) + "_Edit";
			SetMenu(m_sMODULE);
			bool bNewRecord = Sql.IsEmptyGuid(Request["ID"]);
			this.AppendEditViewRelationships(m_sMODULE + "." + LayoutEditView, plcSubPanel, bNewRecord);
			if ( IsPostBack )
			{
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				Page.Validators.Add(new RulesValidator(this));
			}
		}
		#endregion
	}
}

