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

namespace SplendidCRM.Leads
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

		protected Guid            gID                             ;
		protected HtmlTable       tblMain                         ;
		// 09/02/2012 Paul.  EditViews were combined into a single view. 
		//protected HtmlTable       tblAddress                      ;
		//protected HtmlTable       tblDescription                  ;
		protected PlaceHolder     plcSubPanel                     ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			// 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
			// 03/15/2014 Paul.  Enable override of concurrency error. 
			if ( e.CommandName == "Save" || e.CommandName == "SaveDuplicate" || e.CommandName == "SaveConcurrency" )
			{
				try
				{
					// 01/16/2006 Paul.  Enable validator before validating page. 
					this.ValidateEditViewFields(m_sMODULE + "." + LayoutEditView);
					this.ValidateEditViewFields(m_sMODULE + ".EditAddress"    );
					this.ValidateEditViewFields(m_sMODULE + ".EditDescription");
					// 11/10/2010 Paul.  Apply Business Rules. 
					this.ApplyEditViewValidationEventRules(m_sMODULE + "." + LayoutEditView);
					this.ApplyEditViewValidationEventRules(m_sMODULE + ".EditAddress"    );
					this.ApplyEditViewValidationEventRules(m_sMODULE + ".EditDescription");
					
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
							this.ApplyEditViewPreSaveEventRules(m_sMODULE + ".EditAddress"    , rowCurrent);
							this.ApplyEditViewPreSaveEventRules(m_sMODULE + ".EditDescription", rowCurrent);
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
									// 04/24/2006 Paul.  Upgrade to SugarCRM 4.2 Schema. 
									// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
									// 12/29/2007 Paul.  TEAM_ID is now in the stored procedure. 
									// 02/14/2010 Paul.  spLEADS_Update has changed to allow links to Account and Contact. 
									// 04/07/2010 Paul.  Add EXCHANGE_FOLDER. 
									// 04/02/2012 Paul.  Add ASSISTANT, ASSISTANT_PHONE, BIRTHDATE, WEBSITE. 
									SqlProcs.spLEADS_Update
										( ref gID
										, new DynamicControl(this, rowCurrent, "ASSIGNED_USER_ID"          ).ID
										, new DynamicControl(this, rowCurrent, "SALUTATION"                ).SelectedValue
										, new DynamicControl(this, rowCurrent, "FIRST_NAME"                ).Text
										, new DynamicControl(this, rowCurrent, "LAST_NAME"                 ).Text
										, new DynamicControl(this, rowCurrent, "TITLE"                     ).Text
										, new DynamicControl(this, rowCurrent, "REFERED_BY"                ).Text
										, new DynamicControl(this, rowCurrent, "LEAD_SOURCE"               ).SelectedValue
										, new DynamicControl(this, rowCurrent, "LEAD_SOURCE_DESCRIPTION"   ).Text
										, new DynamicControl(this, rowCurrent, "STATUS"                    ).SelectedValue
										, new DynamicControl(this, rowCurrent, "STATUS_DESCRIPTION"        ).Text
										, new DynamicControl(this, rowCurrent, "DEPARTMENT"                ).Text
										, Guid.Empty  // 06/24/2005. REPORTS_TO_ID is not used in version 3.0. 
										, new DynamicControl(this, rowCurrent, "DO_NOT_CALL"               ).Checked
										, new DynamicControl(this, rowCurrent, "PHONE_HOME"                ).Text
										, new DynamicControl(this, rowCurrent, "PHONE_MOBILE"              ).Text
										, new DynamicControl(this, rowCurrent, "PHONE_WORK"                ).Text
										, new DynamicControl(this, rowCurrent, "PHONE_OTHER"               ).Text
										, new DynamicControl(this, rowCurrent, "PHONE_FAX"                 ).Text
										, new DynamicControl(this, rowCurrent, "EMAIL1"                    ).Text
										, new DynamicControl(this, rowCurrent, "EMAIL2"                    ).Text
										, new DynamicControl(this, rowCurrent, "EMAIL_OPT_OUT"             ).Checked
										, new DynamicControl(this, rowCurrent, "INVALID_EMAIL"             ).Checked
										, new DynamicControl(this, rowCurrent, "PRIMARY_ADDRESS_STREET"    ).Text
										, new DynamicControl(this, rowCurrent, "PRIMARY_ADDRESS_CITY"      ).Text
										, new DynamicControl(this, rowCurrent, "PRIMARY_ADDRESS_STATE"     ).Text
										, new DynamicControl(this, rowCurrent, "PRIMARY_ADDRESS_POSTALCODE").Text
										, new DynamicControl(this, rowCurrent, "PRIMARY_ADDRESS_COUNTRY"   ).Text
										, new DynamicControl(this, rowCurrent, "ALT_ADDRESS_STREET"        ).Text
										, new DynamicControl(this, rowCurrent, "ALT_ADDRESS_CITY"          ).Text
										, new DynamicControl(this, rowCurrent, "ALT_ADDRESS_STATE"         ).Text
										, new DynamicControl(this, rowCurrent, "ALT_ADDRESS_POSTALCODE"    ).Text
										, new DynamicControl(this, rowCurrent, "ALT_ADDRESS_COUNTRY"       ).Text
										, new DynamicControl(this, rowCurrent, "DESCRIPTION"               ).Text
										, new DynamicControl(this, rowCurrent, "ACCOUNT_NAME"              ).Text
										, new DynamicControl(this, rowCurrent, "CAMPAIGN_ID"               ).ID
										, new DynamicControl(this, rowCurrent, "TEAM_ID"                   ).ID
										, new DynamicControl(this, rowCurrent, "TEAM_SET_LIST"             ).Text
										, new DynamicControl(this, rowCurrent, "CONTACT_ID"                ).ID
										, new DynamicControl(this, rowCurrent, "ACCOUNT_ID"                ).ID
										, new DynamicControl(this, rowCurrent, "EXCHANGE_FOLDER"           ).Checked
										, new DynamicControl(this, rowCurrent, "BIRTHDATE"                 ).DateValue
										, new DynamicControl(this, rowCurrent, "ASSISTANT"                 ).Text
										, new DynamicControl(this, rowCurrent, "ASSISTANT_PHONE"           ).Text
										, new DynamicControl(this, rowCurrent, "WEBSITE"                   ).Text
										// 09/27/2013 Paul.  SMS messages need to be opt-in. 
										, new DynamicControl(this, rowCurrent, "SMS_OPT_IN"                ).SelectedValue
										// 10/22/2013 Paul.  Provide a way to map Tweets to a parent. 
										, new DynamicControl(this, rowCurrent, "TWITTER_SCREEN_NAME"       ).Text
										// 08/07/2015 Paul.  Add picture. 
										, new DynamicControl(this, rowCurrent, "PICTURE"                   ).Text
										// 05/12/2016 Paul.  Add Tags module. 
										, new DynamicControl(this, rowCurrent, "TAG_SET_NAME"              ).Text
										// 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
										, new DynamicControl(this, rowCurrent, "LEAD_NUMBER"               ).Text
										// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
										, new DynamicControl(this, rowCurrent, "ASSIGNED_SET_LIST"         ).Text
										// 06/23/2018 Paul.  Add DP_BUSINESS_PURPOSE and DP_CONSENT_LAST_UPDATED for data privacy. 
										, new DynamicControl(this, rowCurrent, "DP_BUSINESS_PURPOSE"       ).Text
										, new DynamicControl(this, rowCurrent, "DP_CONSENT_LAST_UPDATED"   ).DateValue
										, trn
										);
									SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
									// 08/26/2010 Paul.  Add new record to tracker. 
									string sNAME = new DynamicControl(this, rowCurrent, "SALUTATION").SelectedValue + " " + new DynamicControl(this, rowCurrent, "FIRST_NAME").Text + " " + new DynamicControl(this, rowCurrent, "LAST_NAME").Text;
									// 03/08/2012 Paul.  Add ACTION to the tracker table so that we can create quick user activity reports. 
									SqlProcs.spTRACKER_Update
										( Security.USER_ID
										, m_sMODULE
										, gID
										, sNAME
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
							this.ApplyEditViewPostSaveEventRules(m_sMODULE + ".EditAddress"    , rowCurrent);
							this.ApplyEditViewPostSaveEventRules(m_sMODULE + ".EditDescription", rowCurrent);
						}
						
						if ( !Sql.IsEmptyString(RulesRedirectURL) )
							Response.Redirect(RulesRedirectURL);
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
				if ( Sql.IsEmptyGuid(gID) )
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
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							// 04/03/2010 Paul.  Add EXCHANGE_FOLDER. 
							// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
							sSQL = "select " + m_sVIEW_NAME + ".*"                                                 + ControlChars.CrLf
							     + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
							     + "     , (case when vwLEADS_USERS.LEAD_ID is null then 0 else 1 end) as EXCHANGE_FOLDER" + ControlChars.CrLf
							     + "  from            " + m_sVIEW_NAME                                             + ControlChars.CrLf
							     + "  left outer join vwLEADS_USERS                                              " + ControlChars.CrLf
							     + "               on vwLEADS_USERS.LEAD_ID = " + m_sVIEW_NAME + ".ID            " + ControlChars.CrLf
							     + "              and vwLEADS_USERS.USER_ID = @SYNC_USER_ID                      " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@SYNC_USER_ID", Security.USER_ID);
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
											this.ApplyEditViewPreLoadEventRules(m_sMODULE + ".EditAddress"    , rdr);
											this.ApplyEditViewPreLoadEventRules(m_sMODULE + ".EditDescription", rdr);
											
											// 10/20/2010 Paul.  Salutation needed to be translated.  Salutation may be empty. 
											string sSALUTATION = Sql.ToString(rdr["SALUTATION"]);
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = (!Sql.IsEmptyString(sSALUTATION) ? L10n.Term(".salutation_dom." + sSALUTATION) + " " : String.Empty) + Sql.ToString(rdr["FIRST_NAME"]) + " " + Sql.ToString(rdr["LAST_NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
											
											// 02/13/2013 Paul.  Move relationship append so that it can be controlled by business rules. 
											this.AppendEditViewRelationships(m_sMODULE + "." + LayoutEditView, plcSubPanel, Sql.IsEmptyGuid(Request["ID"]));
											this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain       , rdr);
											// 09/02/2012 Paul.  EditViews were combined into a single view. 
											//this.AppendEditViewFields(m_sMODULE + ".EditAddress"    , tblAddress    , rdr);
											//this.AppendEditViewFields(m_sMODULE + ".EditDescription", tblDescription, rdr);
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											// 02/18/2009 Paul.  On load, the focus should be set to the NAME field. 
											TextBox txtFIRST_NAME = this.FindControl("FIRST_NAME") as TextBox;
											if ( txtFIRST_NAME != null )
												txtFIRST_NAME.Focus();
											// 10/02/2017 Paul.  We needed to make sure that the number gets reset when copying a record. 
											if ( !Sql.IsEmptyGuid(ViewState["DuplicateID"]) )
											{
												new DynamicControl(this, "LEAD_NUMBER").Text = String.Empty;
											}
											// 12/09/2008 Paul.  Throw an exception if the record has been edited since the last load. 
											ViewState["LAST_DATE_MODIFIED"] = Sql.ToDateTime(rdr["DATE_MODIFIED"]);
											
											// 01/28/2010 Paul.  Use ViewState and Page.Items to be compatible with the DetailViews. 
											// 10/20/2010 Paul.  Salutation needed to be translated.  Salutation may be empty. 
											ViewState ["NAME"            ] = (!Sql.IsEmptyString(sSALUTATION) ? L10n.Term(".salutation_dom." + sSALUTATION) + " " : String.Empty) + Sql.ToString(rdr["FIRST_NAME"]) + " " + Sql.ToString(rdr["LAST_NAME"]);
											ViewState ["ASSIGNED_USER_ID"] = Sql.ToGuid  (rdr["ASSIGNED_USER_ID"]);
											Page.Items["NAME"            ] = ViewState ["NAME"            ];
											Page.Items["ASSIGNED_USER_ID"] = ViewState ["ASSIGNED_USER_ID"];
											// 11/10/2010 Paul.  Apply Business Rules. 
											this.ApplyEditViewPostLoadEventRules(m_sMODULE + "." + LayoutEditView, rdr);
											this.ApplyEditViewPostLoadEventRules(m_sMODULE + ".EditAddress"    , rdr);
											this.ApplyEditViewPostLoadEventRules(m_sMODULE + ".EditDescription", rdr);
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
						}
					}
					else
					{
						// 02/13/2013 Paul.  Move relationship append so that it can be controlled by business rules. 
						this.AppendEditViewRelationships(m_sMODULE + "." + LayoutEditView, plcSubPanel, Sql.IsEmptyGuid(Request["ID"]));
						this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain       , null);
						// 07/02/2018 Paul.  Allow defaults to display as checked for Opt Out and Do Not Call. 
						new DynamicControl(this, "EMAIL_OPT_OUT").Checked = Sql.ToBoolean(Application["CONFIG.default_email_opt_out"]);
						new DynamicControl(this, "DO_NOT_CALL"  ).Checked = Sql.ToBoolean(Application["CONFIG.default_do_not_call"  ]);
						// 09/02/2012 Paul.  EditViews were combined into a single view. 
						//this.AppendEditViewFields(m_sMODULE + ".EditAddress"    , tblAddress    , null);
						//this.AppendEditViewFields(m_sMODULE + ".EditDescription", tblDescription, null);
						// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						// 02/18/2009 Paul.  On load, the focus should be set to the NAME field. 
						TextBox txtFIRST_NAME = this.FindControl("FIRST_NAME") as TextBox;
						if ( txtFIRST_NAME != null )
							txtFIRST_NAME.Focus();
						// 11/10/2010 Paul.  Apply Business Rules. 
						this.ApplyEditViewNewEventRules(m_sMODULE + "." + LayoutEditView);
						this.ApplyEditViewNewEventRules(m_sMODULE + ".EditAddress"    );
						this.ApplyEditViewNewEventRules(m_sMODULE + ".EditDescription");
					}
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
			m_sMODULE = "Leads";
			// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
			m_sVIEW_NAME = "vw" + Crm.Modules.TableName(m_sMODULE) + "_Edit";
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				// 04/19/2010 Paul.  New approach to EditView Relationships will distinguish between New Record and Existing Record.
				// 02/13/2013 Paul.  Move relationship append so that it can be controlled by business rules. 
				this.AppendEditViewRelationships(m_sMODULE + "." + LayoutEditView, plcSubPanel, Sql.IsEmptyGuid(Request["ID"]));
				// 12/02/2005 Paul.  Need to add the edit fields in order for events to fire. 
				this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain       , null);
				// 09/02/2012 Paul.  EditViews were combined into a single view. 
				//this.AppendEditViewFields(m_sMODULE + ".EditAddress"    , tblAddress    , null);
				//this.AppendEditViewFields(m_sMODULE + ".EditDescription", tblDescription, null);
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

