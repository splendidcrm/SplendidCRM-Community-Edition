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
using System.Collections;
using System.Drawing;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Accounts
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
			// 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
			// 03/15/2014 Paul.  Enable override of concurrency error. 
			if ( e.CommandName == "Save" || e.CommandName == "SaveDuplicate" || e.CommandName == "SaveConcurrency" )
			{
				try
				{
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
									// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
									// 12/29/2007 Paul.  TEAM_ID is now in the stored procedure. 
									// 08/06/2009 Paul.  ACCOUNT_NUMBER now uses our number sequence table. 
									// 04/07/2010 Paul.  Add EXCHANGE_FOLDER. 
									SqlProcs.spACCOUNTS_Update
										( ref gID
										, new DynamicControl(this, rowCurrent, "ASSIGNED_USER_ID"           ).ID
										, new DynamicControl(this, rowCurrent, "NAME"                       ).Text
										, new DynamicControl(this, rowCurrent, "ACCOUNT_TYPE"               ).SelectedValue
										, new DynamicControl(this, rowCurrent, "PARENT_ID"                  ).ID
										, new DynamicControl(this, rowCurrent, "INDUSTRY"                   ).SelectedValue
										, new DynamicControl(this, rowCurrent, "ANNUAL_REVENUE"             ).Text
										, new DynamicControl(this, rowCurrent, "PHONE_FAX"                  ).Text
										, new DynamicControl(this, rowCurrent, "BILLING_ADDRESS_STREET"     ).Text
										, new DynamicControl(this, rowCurrent, "BILLING_ADDRESS_CITY"       ).Text
										, new DynamicControl(this, rowCurrent, "BILLING_ADDRESS_STATE"      ).Text
										, new DynamicControl(this, rowCurrent, "BILLING_ADDRESS_POSTALCODE" ).Text
										, new DynamicControl(this, rowCurrent, "BILLING_ADDRESS_COUNTRY"    ).Text
										, new DynamicControl(this, rowCurrent, "DESCRIPTION"                ).Text
										, new DynamicControl(this, rowCurrent, "RATING"                     ).Text
										, new DynamicControl(this, rowCurrent, "PHONE_OFFICE"               ).Text
										, new DynamicControl(this, rowCurrent, "PHONE_ALTERNATE"            ).Text
										, new DynamicControl(this, rowCurrent, "EMAIL1"                     ).Text
										, new DynamicControl(this, rowCurrent, "EMAIL2"                     ).Text
										, new DynamicControl(this, rowCurrent, "WEBSITE"                    ).Text
										, new DynamicControl(this, rowCurrent, "OWNERSHIP"                  ).Text
										, new DynamicControl(this, rowCurrent, "EMPLOYEES"                  ).Text
										, new DynamicControl(this, rowCurrent, "SIC_CODE"                   ).Text
										, new DynamicControl(this, rowCurrent, "TICKER_SYMBOL"              ).Text
										, new DynamicControl(this, rowCurrent, "SHIPPING_ADDRESS_STREET"    ).Text
										, new DynamicControl(this, rowCurrent, "SHIPPING_ADDRESS_CITY"      ).Text
										, new DynamicControl(this, rowCurrent, "SHIPPING_ADDRESS_STATE"     ).Text
										, new DynamicControl(this, rowCurrent, "SHIPPING_ADDRESS_POSTALCODE").Text
										, new DynamicControl(this, rowCurrent, "SHIPPING_ADDRESS_COUNTRY"   ).Text
										, new DynamicControl(this, rowCurrent, "ACCOUNT_NUMBER"             ).Text
										, new DynamicControl(this, rowCurrent, "TEAM_ID"                    ).ID
										, new DynamicControl(this, rowCurrent, "TEAM_SET_LIST"              ).Text
										, new DynamicControl(this, rowCurrent, "EXCHANGE_FOLDER"            ).Checked
										// 08/07/2015 Paul.  Add picture. 
										, new DynamicControl(this, rowCurrent, "PICTURE"                    ).Text
										// 05/12/2016 Paul.  Add Tags module. 
										, new DynamicControl(this, rowCurrent, "TAG_SET_NAME"               ).Text
										// 06/07/2017 Paul.  Add NAICSCodes module. 
										, new DynamicControl(this, rowCurrent, "NAICS_SET_NAME"             ).Text
										// 10/27/2017 Paul.  Add Accounts as email source. 
										, new DynamicControl(this, rowCurrent, "DO_NOT_CALL"                ).Checked
										, new DynamicControl(this, rowCurrent, "EMAIL_OPT_OUT"              ).Checked
										, new DynamicControl(this, rowCurrent, "INVALID_EMAIL"              ).Checked
										// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
										, new DynamicControl(this, rowCurrent, "ASSIGNED_SET_LIST"          ).Text
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
						else if ( !Sql.IsEmptyGuid(gPARENT_ID) )
							Response.Redirect("~/Accounts/view.aspx?ID=" + gPARENT_ID.ToString());
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
					Response.Redirect("~/Accounts/view.aspx?ID=" + gPARENT_ID.ToString());
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
					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							// 04/03/2010 Paul.  Add EXCHANGE_FOLDER. 
							// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
							sSQL = "select " + m_sVIEW_NAME + ".*"                                                    + ControlChars.CrLf
							     + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
							     + "     , (case when vwACCOUNTS_USERS.ACCOUNT_ID is null then 0 else 1 end) as EXCHANGE_FOLDER" + ControlChars.CrLf
							     + "  from            " + m_sVIEW_NAME                                                + ControlChars.CrLf
							     + "  left outer join vwACCOUNTS_USERS                                              " + ControlChars.CrLf
							     + "               on vwACCOUNTS_USERS.ACCOUNT_ID = " + m_sVIEW_NAME + ".ID         " + ControlChars.CrLf
							     + "              and vwACCOUNTS_USERS.USER_ID    = @SYNC_USER_ID                   " + ControlChars.CrLf;
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
											
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = Sql.ToString(rdr["NAME"]);
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
											TextBox txtNAME = this.FindControl("NAME") as TextBox;
											if ( txtNAME != null )
												txtNAME.Focus();
											// 10/02/2017 Paul.  We needed to make sure that the number gets reset when copying a record. 
											if ( !Sql.IsEmptyGuid(ViewState["DuplicateID"]) )
											{
												new DynamicControl(this, "ACCOUNT_NUMBER").Text = String.Empty;
											}
											// 12/09/2008 Paul.  Throw an exception if the record has been edited since the last load. 
											ViewState["LAST_DATE_MODIFIED"] = Sql.ToDateTime(rdr["DATE_MODIFIED"]);
											
											// 01/28/2010 Paul.  Use ViewState and Page.Items to be compatible with the DetailViews. 
											ViewState ["NAME"            ] = Sql.ToString(rdr["NAME"            ]);
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
						TextBox txtNAME = this.FindControl("NAME") as TextBox;
						if ( txtNAME != null )
							txtNAME.Focus();
						
						Guid   gPARENT_ID   = Sql.ToGuid(Request["PARENT_ID"]);
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
						// 05/09/2010 Paul.  The Parent can only be an Account in this context. 
						if ( !Sql.IsEmptyGuid(gPARENT_ID) && sPARENT_TYPE == "Accounts" )
						{
							new DynamicControl(this, "PARENT_ID"  ).ID   = gPARENT_ID  ;
							new DynamicControl(this, "PARENT_NAME").Text = sPARENT_NAME;
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
			m_sMODULE = "Accounts";
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

