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
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
using CKEditor.NET;

namespace SplendidCRM.EmailTemplates
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
		protected _controls.TeamSelect     ctlTeamSelect    ;
		// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		protected _controls.UserSelect     ctlUserSelect    ;

		// 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
		protected HiddenField     ASSIGNED_USER_ID             ;
		protected TextBox         ASSIGNED_TO                  ;
		protected Guid            gID                          ;
		protected Guid            gCAMPAIGN_ID                 ;
		protected TextBox         txtNAME                      ;
		protected TextBox         txtDESCRIPTION               ;
		protected DropDownList    lstVariableModule            ;
		protected DropDownList    lstVariableName              ;
		protected TextBox         txtVariableText              ;
		protected TextBox         txtSUBJECT                   ;
		// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
		protected CKEditorControl txtBODY                      ;
		protected CheckBox        chkREAD_ONLY                 ;
		protected DropDownList    lstTrackerName               ;
		protected TextBox         txtTrackerText               ;
		protected Repeater        ctlAttachments               ;
		// 03/31/2010 Paul.  Manually manage singular Team field. 
		protected TextBox         TEAM_NAME                    ;
		protected HiddenField     TEAM_ID                      ;
		protected HiddenField     hidREMOVE_LABEL              ;
		protected HiddenField     hidATTACHMENT_COUNT          ;
		// 08/02/2013 Paul.  Allow a survey to be added to an email template. 
		protected TableRow        trINSERT_SURVEY              ;
		protected CheckBox        chkSURVEY_CONTACT            ;

		protected string GetSurveySiteURL()
		{
			string sSurveySiteURL = Sql.ToString(Application["CONFIG.Surveys.SurveySiteURL"]);
			if ( Sql.IsEmptyString(sSurveySiteURL) )
				sSurveySiteURL = Crm.Config.SiteURL(Application) + "Surveys";
			if ( !sSurveySiteURL.EndsWith("/") )
				sSurveySiteURL += "/";
			return sSurveySiteURL;
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			// 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
			// 03/15/2014 Paul.  Enable override of concurrency error. 
			if ( e.CommandName == "Save" || e.CommandName == "SaveDuplicate" || e.CommandName == "SaveConcurrency" )
			{
				try
				{
					if ( Page.IsValid )
					{
						// 11/22/2006 Paul.  Fix name of custom module. 
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
							// 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
							// Apply duplicate checking after PreSave business rules, but before trasnaction. 
							bool bDUPLICATE_CHECHING_ENABLED = Sql.ToBoolean(Application["CONFIG.enable_duplicate_check"]) && Sql.ToBoolean(Application["Modules." + m_sMODULE + ".DuplicateCheckingEnabled"]) && (e.CommandName != "SaveDuplicate");
							if ( bDUPLICATE_CHECHING_ENABLED )
							{
								if ( Utils.DuplicateCheck(Application, con, m_sMODULE, gID, this, rowCurrent) > 0 )
								{
									ctlDynamicButtons.ShowButton("SaveDuplicate", true);
									ctlFooterButtons .ShowButton("SaveDuplicate", true);
									throw(new Exception(L10n.Term(".ERR_DUPLICATE_EXCEPTION")));
								}
							}

							// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									// 12/19/2006 Paul.  Add READ_ONLY field. 
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
									// 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
									SqlProcs.spEMAIL_TEMPLATES_Update
										( ref gID
										, false  // 11/17/2005 Paul.  The PUBLISH flag is no longer used in SugarCRM 3.5.0B
										, chkREAD_ONLY.Checked
										, txtNAME.Text
										, txtDESCRIPTION.Text
										, txtSUBJECT.Text
										, String.Empty   // BODY
										, txtBODY.Text   // BODY_HTML
										, gTEAM_ID
										, ctlTeamSelect.TEAM_SET_LIST
										, gASSIGNED_USER_ID
										// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
										, ctlUserSelect.ASSIGNED_SET_LIST
										, trn
										);
									// 09/13/2011 Paul.  Use a more generic way to get the files. 
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
														, L10n.Term("EmailTemplates.LBL_EMAIL_ATTACHMENT") + ": " + sFILENAME
														, "EmailTemplates"   // Parent Type
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

									// 09/13/2011 Paul.  Deleted attachments need to have their relationship removed. 
									DataTable dtAttachments = ViewState["Attachments"] as DataTable;
									if ( dtAttachments != null )
									{
										foreach ( DataRow row in dtAttachments.Rows )
										{
											if ( row.RowState == DataRowState.Deleted )
											{
												// 09/13/2011 Paul.  Deleted row information cannot be accessed through the row.
												// Need to get the Original version. 
												Guid gNOTE_ID = Sql.ToGuid(row["ID", DataRowVersion.Original]);
												SqlProcs.spNOTES_Delete(gNOTE_ID, trn);
											}
										}
									}

									SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
									// 08/26/2010 Paul.  Add new record to tracker. 
									// 03/08/2012 Paul.  Add ACTION to the tracker table so that we can create quick user activity reports. 
									SqlProcs.spTRACKER_Update
										( Security.USER_ID
										, m_sMODULE
										, gID
										, txtNAME.Text
										, "save"
										, trn
										);
									trn.Commit();
									// 04/03/2012 Paul.  Just in case the name changes, clear the favorites. 
									SplendidCache.ClearFavorites();
									// 05/01/2020 Paul.  Cache EmailTemplates for use in React Client. 
									SplendidCache.ClearEmailTemplates();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									ctlDynamicButtons.ErrorText = ex.Message;
									return;
								}
							}
						}
						if ( Request.AppRelativeCurrentExecutionFilePath == "~/EmailTemplates/PopupEdit.aspx" )
							Response.Redirect("Popup.aspx?CAMPAIGN_ID=" + gCAMPAIGN_ID.ToString() + "&ID=" + gID.ToString());
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
				if ( Request.AppRelativeCurrentExecutionFilePath == "~/EmailTemplates/PopupEdit.aspx" )
					Response.Redirect("Popup.aspx?CAMPAIGN_ID=" + gCAMPAIGN_ID.ToString());
				else if ( Sql.IsEmptyGuid(gID) )
					Response.Redirect("default.aspx");
				else
					Response.Redirect("view.aspx?ID=" + gID.ToString());
			}
			// 09/13/2011 Paul.  Store the attachments in ViewState so that we can manipulate the table. 
			else if ( e.CommandName == "Attachments.Delete" )
			{
				Guid gNOTE_ATTACHMENT_ID = Sql.ToGuid(e.CommandArgument);
				DataTable dt = ViewState["Attachments"] as DataTable;
				if ( dt != null && !Sql.IsEmptyGuid(gNOTE_ATTACHMENT_ID) )
				{
					foreach ( DataRow row in dt.Rows )
					{
						if ( gNOTE_ATTACHMENT_ID == Sql.ToGuid(row["NOTE_ATTACHMENT_ID"]) )
						{
							row.Delete();
						}
					}
					// 09/13/2011 Paul.  Do not accept changes so that we can use the deleted flag to update the relationships. 
					ctlAttachments.DataSource = dt.DefaultView;
					ctlAttachments.DataBind();
					ViewState["Attachments"] = dt;
				}
			}
		}

		protected void lstVariableModule_Changed(Object sender, EventArgs e)
		{
			lstVariableName.Items.Clear();
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL ;
				// 02/29/2008 Niall.  Some SQL Server 2005 installations require matching case for the parameters. 
				// Since we force the parameter to be uppercase, we must also make it uppercase in the command text. 
				sSQL = "select *                       " + ControlChars.CrLf
				     + "  from vwSqlColumns            " + ControlChars.CrLf
				     + " where ObjectName = @OBJECTNAME" + ControlChars.CrLf
				     + " order by colid                " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					string sTABLE_NAME = Sql.ToString(Application["Modules." + lstVariableModule.SelectedValue + ".TableName"]);
					// 09/02/2008 Paul.  Standardize the case of metadata tables to uppercase.  PostgreSQL defaults to lowercase. 
					// 09/11/2008 Paul.  Get fields for the Edit view. 
					Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, "vw" + sTABLE_NAME + "_Edit"));
					con.Open();
					using ( IDataReader rdr = cmd.ExecuteReader() )
					{
						while ( rdr.Read() )
						{
							string sValue  = Sql.ToString(rdr["ColumnName"]);
							// 02/11/2009 Paul.  Use the TableColumnName function so that common names are properly converted to the common label. 
							string sText   = Utils.TableColumnName(L10n, lstVariableModule.SelectedValue, sValue.ToUpper());  //L10n.Term(lstVariableModule.SelectedValue + ".LBL_" + sValue.ToUpper());
							string sModule = lstVariableModule.SelectedValue;
							// 09/03/2008 Paul.  Add support for all modules by converting the module to a singular name. 
							sModule = sModule.ToLower();
							if ( sModule.EndsWith("ies") )
								sModule = sModule.Substring(0, sModule.Length-3) + "y";
							else if ( sModule.EndsWith("s") )
								sModule = sModule.Substring(0, sModule.Length-1);
							sText = sText.Replace(":", "");
							lstVariableName.Items.Add(new ListItem(sText, sModule + "_" + sValue.ToLower()));
						}
					}
				}
			}
			if ( lstVariableName.Items.Count > 0 )
				txtVariableText.Text = "$" + lstVariableName.Items[0].Value;
		}

		private void lstTrackerName_Bind()
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL ;
				sSQL = "select *                         " + ControlChars.CrLf
				     + "  from vwCAMPAIGNS_CAMPAIGN_TRKRS" + ControlChars.CrLf
				     + " where CAMPAIGN_ID = @CAMPAIGN_ID" + ControlChars.CrLf
				     + " order by TRACKER_NAME asc       " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@CAMPAIGN_ID", gCAMPAIGN_ID);
		
					if ( bDebug )
						RegisterClientScriptBlock("vwCAMPAIGNS_CAMPAIGN_TRKRS", Sql.ClientScriptBlock(cmd));
		
					con.Open();
					using ( IDataReader rdr = cmd.ExecuteReader() )
					{
						while ( rdr.Read() )
						{
							string sValue  = Sql.ToString(rdr["TRACKER_NAME"]);
							string sText   = Sql.ToString(rdr["TRACKER_NAME"]) + " : " + Sql.ToString(rdr["TRACKER_URL"]);
							lstTrackerName.Items.Add(new ListItem(sText, sValue));
						}
					}
				}
			}
			if ( lstTrackerName.Items.Count > 0 )
				txtTrackerText.Text = "{" + lstTrackerName.Items[0].Value + "}";
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
				gCAMPAIGN_ID = Sql.ToGuid(Request["CAMPAIGN_ID"]);
				if ( !IsPostBack )
				{
					// 08/02/2013 Paul.  Community Edition does not include the survey module. 
					trINSERT_SURVEY.Visible = Directory.Exists(Server.MapPath("~/Surveys"));
					
					lstVariableModule.Items.Add(new ListItem(L10n.Term(".LBL_ACCOUNT"                         ), "Accounts"));
					lstVariableModule.Items.Add(new ListItem(L10n.Term("EmailTemplates.LBL_CONTACT_AND_OTHERS"), "Contacts"));
					// 09/03/2008 Paul.  Add support for all modules by converting the module to a singular name. 
					// 09/03/2008 Paul.  We are not ready to give full access to all modules. 
					//lstVariableModule.DataValueField = "MODULE_NAME" ;
					//lstVariableModule.DataTextField  = "DISPLAY_NAME";
					//lstVariableModule.DataSource = SplendidCache.ReportingModules();
					//lstVariableModule.DataBind();
					lstVariableModule_Changed(null, null);

					if ( !Sql.IsEmptyGuid(gCAMPAIGN_ID) )
					{
						lstTrackerName_Bind();
					}

					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
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
										// 10/31/2017 Paul.  Provide a way to inject Record level ACL. 
										if ( dtCurrent.Rows.Count > 0 && (SplendidCRM.Security.GetRecordAccess(dtCurrent.Rows[0], m_sMODULE, "edit", "ASSIGNED_USER_ID") >= 0) )
										{
											DataRow rdr = dtCurrent.Rows[0];
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;

											// 03/04/2006 Paul.  Name was not being set. 
											txtNAME       .Text  = Sql.ToString(rdr["NAME"       ]);
											txtDESCRIPTION.Text  = Sql.ToString(rdr["DESCRIPTION"]);
											txtSUBJECT    .Text  = Sql.ToString(rdr["SUBJECT"    ]);
											// 04/21/2006 Paul.  Change BODY to BODY_HTML. 
											txtBODY       .Text  = Sql.ToString(rdr["BODY_HTML"  ]);
											// 12/19/2006 Paul.  Add READ_ONLY field. 
											chkREAD_ONLY.Checked = Sql.ToBoolean(rdr["READ_ONLY"]);
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											// 05/13/2008 Paul.  An EmailTemplate does not have an ASSIGNED_USER_ID. 
											// 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
											ASSIGNED_TO     .Text  = Sql.ToString(rdr["ASSIGNED_TO"     ]);
											ASSIGNED_USER_ID.Value = Sql.ToString(rdr["ASSIGNED_USER_ID"]);
											// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
											Guid gASSIGNED_SET_ID = Sql.ToGuid(rdr["ASSIGNED_SET_ID"]);
											ctlUserSelect.LoadLineItems(gASSIGNED_SET_ID, true);
											ViewState ["ASSIGNED_USER_ID"] = Sql.ToGuid(rdr["ASSIGNED_USER_ID"]);
											Page.Items["ASSIGNED_USER_ID"] = ViewState["ASSIGNED_USER_ID"];
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											// 02/18/2009 Paul.  On load, the focus should be set to the NAME field. 
											if ( txtNAME != null )
												txtNAME.Focus();
											// 12/09/2008 Paul.  Throw an exception if the record has been edited since the last load. 
											ViewState["LAST_DATE_MODIFIED"] = Sql.ToDateTime(rdr["DATE_MODIFIED"]);
											
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
											
											// 11/25/2006 Paul.  If item is not visible, then don't allow save 
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
											ctlFooterButtons .DisableAll();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
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
								Sql.AddParameter(cmd, "@EMAIL_TEMPLATE_ID", gID);

								if ( bDebug )
									RegisterClientScriptBlock("vwEMAIL_TEMPLATES_Attachments", Sql.ClientScriptBlock(cmd));

								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dt = new DataTable() )
									{
										da.Fill(dt);
										ctlAttachments.DataSource = dt.DefaultView;
										ctlAttachments.DataBind();
										// 09/13/2011 Paul.  Store the attachments in ViewState so that we can manipulate the table. 
										ViewState["Attachments"] = dt;
									}
								}
							}
						}
					}
					else
					{
						// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						// 02/18/2009 Paul.  On load, the focus should be set to the NAME field. 
						if ( txtNAME != null )
							txtNAME.Focus();
						
						// 03/31/2010 Paul.  Manually manage singular Team field. 
						TEAM_NAME.Text    = Security.TEAM_NAME;
						TEAM_ID.Value     = Security.TEAM_ID.ToString();
						// 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
						ASSIGNED_TO     .Text  = Security.USER_NAME;
						ASSIGNED_USER_ID.Value = Security.USER_ID.ToString();
						// 12/21/2006 Paul.  The team name should always default to the current user's private team. 
						// 08/23/2009 Paul.  Let the TeamSelect control manage the teams completely. 
						// 08/31/2009 Paul.  We only need to pass the TEAM_SET_ID. 
						ctlTeamSelect.LoadLineItems(Guid.Empty, true);
					}
				}
				else
				{
					// 12/02/2005 Paul.  When validation fails, the header title does not retain its value.  Update manually. 
					// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
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
			m_sMODULE = "EmailTemplates";
			// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
			m_sVIEW_NAME = "vw" + Crm.Modules.TableName(m_sMODULE) + "_Edit";
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

