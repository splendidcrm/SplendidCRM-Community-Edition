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

namespace SplendidCRM.Documents
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

		// 10/18/2009 Paul.  Move blob logic to LoadFile. 
		// 04/24/2011 Paul.  Move LoadFile() to Crm.DocumentRevisions. 

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			// 05/08/2014 Paul.  Redirect to parent if that is where the note was originated. 
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
			// 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
			// 03/15/2014 Paul.  Enable override of concurrency error. 
			if ( e.CommandName == "Save" || e.CommandName == "SaveDuplicate" || e.CommandName == "SaveConcurrency" )
			{
				try
				{
					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						// 03/04/2006 Paul.  The Enable flag cannot be modified prior to ValidateEditViewFields because the change will get over-ridden. 
						//RequiredFieldValidator reqCONTENT  = FindControl("CONTENT_REQUIRED" ) as RequiredFieldValidator;
						//RequiredFieldValidator reqREVISION = FindControl("REVISION_REQUIRED") as RequiredFieldValidator;
						//if ( reqCONTENT != null )
						//	reqCONTENT.Enabled = false;
						//if ( reqREVISION != null )
						//	reqREVISION.Enabled = false;
					}
					// 01/16/2006 Paul.  Enable validator before validating page. 
					this.ValidateEditViewFields(m_sMODULE + "." + LayoutEditView);
					// 03/05/2011 Paul.  If the document already exists, then don't require a new content upload. 
					// 08/11/2014 Paul.  The FILENAME field is now a label, not a literal. 
					Label litFILENAME = FindControl("FILENAME") as Label;
					if ( litFILENAME != null && !Sql.IsEmptyString(litFILENAME.Text) )
					{
						RequiredFieldValidator reqCONTENT = FindControl("CONTENT_REQUIRED" ) as RequiredFieldValidator;
						if ( reqCONTENT != null )
						{
							reqCONTENT.Visible = false;
							reqCONTENT.Enabled = false;
							reqCONTENT.Validate();
						}
					}

					// 11/10/2010 Paul.  Apply Business Rules. 
					this.ApplyEditViewValidationEventRules(m_sMODULE + "." + LayoutEditView);
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
									// 12/01/2010 Paul.  New naming convention for file upload fields. 
									HtmlInputFile fileCONTENT = FindControl("CONTENT_File") as HtmlInputFile;
									HttpPostedFile pstCONTENT  = null;
									if ( fileCONTENT != null )
										pstCONTENT = fileCONTENT.PostedFile;
									// 03/04/2006 Paul.  This is a new document if gID and gDuplicateID are both empty.
									bool bNewDocument = Sql.IsEmptyGuid(gID) && Sql.IsEmptyGuid(gDuplicateID);
									if ( bNewDocument )
									{
										//die("ERROR: uploaded file was too big: max filesize: {$sugar_config['upload_maxsize']}");
										if ( pstCONTENT != null )
										{
											long lFileSize      = pstCONTENT.ContentLength;
											long lUploadMaxSize = Sql.ToLong(Application["CONFIG.upload_maxsize"]);
											if ( (lUploadMaxSize > 0) && (lFileSize > lUploadMaxSize) )
											{
												throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
											}
										}
									}
									// 04/24/2006 Paul.  Upgrade to SugarCRM 4.2 Schema. 
									// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
									// 12/29/2007 Paul.  TEAM_ID is now in the stored procedure. 
									// 05/15/2011 Paul.  We need to include the Master and Secondary so that the user selects the correct template. 
									// 04/02/2012 Paul.  Add ASSIGNED_USER_ID. 
									SqlProcs.spDOCUMENTS_Update
										( ref gID
										, new DynamicControl(this, rowCurrent, "DOCUMENT_NAME"      ).Text
										, new DynamicControl(this, rowCurrent, "ACTIVE_DATE"        ).DateValue
										, new DynamicControl(this, rowCurrent, "EXP_DATE"           ).DateValue
										, new DynamicControl(this, rowCurrent, "CATEGORY_ID"        ).SelectedValue
										, new DynamicControl(this, rowCurrent, "SUBCATEGORY_ID"     ).SelectedValue
										, new DynamicControl(this, rowCurrent, "STATUS_ID"          ).SelectedValue
										, new DynamicControl(this, rowCurrent, "DESCRIPTION"        ).Text
										, new DynamicControl(this, rowCurrent, "MAIL_MERGE_DOCUMENT").Checked
										, new DynamicControl(this, rowCurrent, "RELATED_DOC_ID"     ).ID
										, new DynamicControl(this, rowCurrent, "RELATED_DOC_REV_ID" ).ID
										, new DynamicControl(this, rowCurrent, "IS_TEMPLATE"        ).Checked
										, new DynamicControl(this, rowCurrent, "TEMPLATE_TYPE"      ).Text
										, new DynamicControl(this, rowCurrent, "TEAM_ID"            ).ID
										, new DynamicControl(this, rowCurrent, "TEAM_SET_LIST"      ).Text
										, new DynamicControl(this, rowCurrent, "PRIMARY_MODULE"     ).Text
										, new DynamicControl(this, rowCurrent, "SECONDARY_MODULE"   ).Text
										, new DynamicControl(this, rowCurrent, "ASSIGNED_USER_ID"   ).ID
										// 05/12/2016 Paul.  Add Tags module. 
										, new DynamicControl(this, rowCurrent, "TAG_SET_NAME"       ).Text
										// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
										, new DynamicControl(this, rowCurrent, "ASSIGNED_SET_LIST"  ).Text
										, trn
										);
									if ( bNewDocument )
									{
										if ( pstCONTENT != null )
										{
											// 08/20/2005 Paul.  File may not have been provided. 
											if ( pstCONTENT.FileName.Length > 0 )
											{
												string sFILENAME       = Path.GetFileName (pstCONTENT.FileName);
												string sFILE_EXT       = Path.GetExtension(sFILENAME);
												string sFILE_MIME_TYPE = pstCONTENT.ContentType;
										
												Guid gRevisionID = Guid.Empty;
												// 01/16/2006 Paul.  spDOCUMENT_REVISIONS_Insert needs to be in the transaction, 
												// otherwise the entire transaction will timeout. This is because the transaction has 
												// locked the tables that are needed by spDOCUMENT_REVISIONS_Insert. 
												SqlProcs.spDOCUMENT_REVISIONS_Insert
													( ref gRevisionID
													, gID
													, new DynamicControl(this, "REVISION").Text
													, "Document Created"
													, sFILENAME
													, sFILE_EXT
													, sFILE_MIME_TYPE
													, trn
													);
												// 09/06/2008 Paul.  PostgreSQL does not require that we stream the bytes, so lets explore doing this for all platforms. 
												// 10/18/2009 Paul.  Move blob logic to LoadFile. 
												// 04/24/2011 Paul.  Move LoadFile() to Crm.DocumentRevisions. 
												Crm.DocumentRevisions.LoadFile(gRevisionID, pstCONTENT.InputStream, trn);
											}
										}
									}
									else if ( Sql.IsEmptyGuid(Request["ID"]) && !Sql.IsEmptyGuid(gDuplicateID) )
									{
										Guid gRevisionID = Guid.Empty;
										// 03/04/2006 Paul.  We need a separate procedure to copy the document stored in the revisions table. 
										SqlProcs.spDOCUMENT_REVISIONS_Duplicate
											( ref gRevisionID
											, gID
											, gDuplicateID
											, new DynamicControl(this, "REVISION").Text
											, "Document Created"
											, trn
											);
									}
									SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
									// 05/08/2014 Paul.  Apply the related module relationship. 
									if ( !Sql.IsEmptyGuid(gPARENT_ID) )
										SqlProcs.spDOCUMENTS_InsRelated(gID, sMODULE, gPARENT_ID, trn);
									// 08/26/2010 Paul.  Add new record to tracker. 
									// 03/08/2012 Paul.  Add ACTION to the tracker table so that we can create quick user activity reports. 
									SqlProcs.spTRACKER_Update
										( Security.USER_ID
										, m_sMODULE
										, gID
										, new DynamicControl(this, rowCurrent, "DOCUMENT_NAME").Text
										, "save"
										, trn
										);
									trn.Commit();
									// 04/03/2012 Paul.  Just in case the name changes, clear the favorites. 
									SplendidCache.ClearFavorites();
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
							this.ApplyEditViewPostSaveEventRules(m_sMODULE + "." + LayoutEditView, rowCurrent);
						}
						
						if ( !Sql.IsEmptyString(RulesRedirectURL) )
							Response.Redirect(RulesRedirectURL);
						// 05/08/2014 Paul.  Redirect to parent if that is where the note was originated. 
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
				// 05/08/2014 Paul.  Redirect to parent if that is where the note was originated. 
				if ( !Sql.IsEmptyGuid(gPARENT_ID) )
					Response.Redirect("~/" + sMODULE + "/view.aspx?ID=" + gPARENT_ID.ToString());
				else if ( Sql.IsEmptyGuid(gID) )
					Response.Redirect("default.aspx");
				else
					Response.Redirect("view.aspx?ID=" + gID.ToString());
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
				// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
				//Page.DataBind();
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					// 07/29/2005 Paul.  SugarCRM 3.0 does not allow the NONE option. 
					//lstSTATUS_ID     .Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
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
											// 11/11/2010 Paul.  Apply Business Rules. 
											this.ApplyEditViewPreLoadEventRules(m_sMODULE + "." + LayoutEditView, rdr);
											
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = Sql.ToString(rdr["DOCUMENT_NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;

											this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, rdr);
											// 08/29/2010 Paul.  Automatically populate the report name based on the file name. 
											// 12/01/2010 Paul.  New naming convention for file upload fields. 
											HtmlInputFile CONTENT = FindControl("CONTENT_File") as HtmlInputFile;
											if ( CONTENT != null )
												CONTENT.Attributes.Add("onchange", "FileNameChanged(this)");
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											// 02/18/2009 Paul.  On load, the focus should be set to the NAME field. 
											TextBox txtDOCUMENT_NAME = this.FindControl("DOCUMENT_NAME") as TextBox;
											if ( txtDOCUMENT_NAME != null )
												txtDOCUMENT_NAME.Focus();

											RequiredFieldValidator reqCONTENT = FindControl("CONTENT_REQUIRED" ) as RequiredFieldValidator;
											if ( reqCONTENT != null )
											{
												reqCONTENT.Visible = false;
												reqCONTENT.Enabled = false;
											}
											// 12/01/2010 Paul.  Not sure why we were hiding the upload control. 
											//if ( CONTENT != null )
											//	CONTENT.Visible = false;
											// 03/04/2006 Paul.  Revision is editable if we are duplicating the document. 
											if ( Sql.IsEmptyGuid(gDuplicateID) )
											{
												// 12/06/2005 Paul.  The Revision is not editable.  SugarCRM 3.5 allows editing, but does not honor any changes. 
												TextBox txtREVISION = FindControl("REVISION") as TextBox;
												if ( txtREVISION != null )
												{
													HtmlTableCell td = txtREVISION.Parent as HtmlTableCell;
													if ( td != null )
													{
														txtREVISION.ReadOnly = true;
													}
												}
											}
											// 12/09/2008 Paul.  Throw an exception if the record has been edited since the last load. 
											ViewState["LAST_DATE_MODIFIED"] = Sql.ToDateTime(rdr["DATE_MODIFIED"]);
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
										}
									}
								}
							}
						}
					}
					else
					{
						this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, null);
						// 08/29/2010 Paul.  Automatically populate the report name based on the file name. 
						// 12/01/2010 Paul.  New naming convention for file upload fields. 
						HtmlInputFile CONTENT = FindControl("CONTENT_File") as HtmlInputFile;
						if ( CONTENT != null )
							CONTENT.Attributes.Add("onchange", "FileNameChanged(this)");
						// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						// 02/18/2009 Paul.  On load, the focus should be set to the NAME field. 
						TextBox txtDOCUMENT_NAME = this.FindControl("DOCUMENT_NAME") as TextBox;
						if ( txtDOCUMENT_NAME != null )
							txtDOCUMENT_NAME.Focus();
						// 03/04/2006 Paul.  Initialize Publish Date to Today. 
						new DynamicControl(this, "ACTIVE_DATE").DateValue = DateTime.Today;
						// 11/10/2010 Paul.  Apply Business Rules. 
						this.ApplyEditViewNewEventRules(m_sMODULE + "." + LayoutEditView);
					}
				}
				else
				{
					// 12/02/2005 Paul.  When validation fails, the header title does not retain its value.  Update manually. 
					// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
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
			m_sMODULE = "Documents";
			// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
			m_sVIEW_NAME = "vw" + Crm.Modules.TableName(m_sMODULE) + "_Edit";
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				// 12/02/2005 Paul.  Need to add the edit fields in order for events to fire. 
				this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, null);
				// 01/27/2011 Paul.  Automatically populate the report name based on the file name. Need to do this on a PostBack. 
				HtmlInputFile CONTENT = FindControl("CONTENT_File") as HtmlInputFile;
				if ( CONTENT != null )
					CONTENT.Attributes.Add("onchange", "FileNameChanged(this)");
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
				// 11/10/2010 Paul.  Make sure to add the RulesValidator early in the pipeline. 
				Page.Validators.Add(new RulesValidator(this));
			}
		}
		#endregion
	}
}

