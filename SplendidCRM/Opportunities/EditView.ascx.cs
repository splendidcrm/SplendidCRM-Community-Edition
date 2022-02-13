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

namespace SplendidCRM.Opportunities
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
		// 08/07/2015 Paul.  Revenue Line Items. 
		protected EditLineItemsView ctlEditLineItemsView;

		protected Guid            gID                          ;
		protected HtmlTable       tblMain                      ;
		protected PlaceHolder     plcSubPanel                  ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			Guid   gQUOTE_ID    = Sql.ToGuid(Request["QUOTE_ID"]);
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
					// 01/16/2006 Paul.  Enable validator before validating page. 
					this.ValidateEditViewFields(m_sMODULE + "." + LayoutEditView);
					// 11/10/2010 Paul.  Apply Business Rules. 
					this.ApplyEditViewValidationEventRules(m_sMODULE + "." + LayoutEditView);
					
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
									// 08/07/2015 Paul.  Revenue Line Items. 
									if ( Sql.ToString(Application["CONFIG.OpportunitiesMode"]) == "Revenue" )
									{
										DataTable dtCustomLineItems = SplendidCache.FieldsMetaData_UnvalidatedCustomFields(sTABLE_NAME + "_LINE_ITEMS");
										ctlEditLineItemsView.UpdateTotals();
										// 08/08/2015 Paul.  Separate relationship for Leads/Opportunities. 
										SqlProcs.spOPPORTUNITIES_Update
											( ref gID
											, new DynamicControl(this, rowCurrent, "ASSIGNED_USER_ID").ID
											, new DynamicControl(this, rowCurrent, "ACCOUNT_ID"      ).ID
											, new DynamicControl(this, rowCurrent, "NAME"            ).Text
											, new DynamicControl(this, rowCurrent, "OPPORTUNITY_TYPE").SelectedValue
											, new DynamicControl(this, rowCurrent, "LEAD_SOURCE"     ).SelectedValue
											, new DynamicControl(ctlEditLineItemsView, rowCurrent, "TOTAL"           ).DecimalValue
											, new DynamicControl(ctlEditLineItemsView, rowCurrent, "CURRENCY_ID"     ).ID
											, new DynamicControl(this, rowCurrent, "DATE_CLOSED"     ).DateValue
											, new DynamicControl(this, rowCurrent, "NEXT_STEP"       ).Text
											, new DynamicControl(this, rowCurrent, "SALES_STAGE"     ).SelectedValue
											, new DynamicControl(this, rowCurrent, "PROBABILITY"     ).FloatValue
											, new DynamicControl(this, rowCurrent, "DESCRIPTION"     ).Text
											, sMODULE
											, gPARENT_ID
											, String.Empty  // 11/02/2006 Paul.  ACCOUNT_NAME is only used for import. 
											, new DynamicControl(this, rowCurrent, "TEAM_ID"         ).ID
											, new DynamicControl(this, rowCurrent, "TEAM_SET_LIST"   ).Text
											, new DynamicControl(this, rowCurrent, "CAMPAIGN_ID"     ).ID  // 12/16/2009 Paul.  Add Campaign tracking. 
											, new DynamicControl(this, rowCurrent, "EXCHANGE_FOLDER" ).Checked
											, new DynamicControl(this, rowCurrent, "B2C_CONTACT_ID"  ).ID
											, new DynamicControl(this, rowCurrent, "LEAD_ID"         ).ID
											// 05/12/2016 Paul.  Add Tags module. 
											, new DynamicControl(this, rowCurrent, "TAG_SET_NAME"    ).Text
											// 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
											, new DynamicControl(this, rowCurrent, "OPPORTUNITY_NUMBER").Text
											// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
											, new DynamicControl(this, rowCurrent, "ASSIGNED_SET_LIST" ).Text
											, trn
											);
										// 08/27/2017 Paul.  UpdateCustomFields was not getting called when in Revenue mode. 
										SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
										
										DataTable dtLineItems = ctlEditLineItemsView.LineItems;
										Guid gDuplicateID = Sql.ToGuid(ViewState["DuplicateID"]);
										if ( Sql.IsEmptyGuid(gDuplicateID) )
										{
											foreach ( DataRow row in dtLineItems.Rows )
											{
												if ( row.RowState == DataRowState.Deleted )
												{
													Guid gITEM_ID = Sql.ToGuid(row["ID", DataRowVersion.Original]);
													if ( !Sql.IsEmptyGuid(gITEM_ID) )
														SqlProcs.spREVENUE_LINE_ITEMS_Delete(gITEM_ID, trn);
												}
											}
										}
										int nPOSITION = 1;
										foreach ( DataRow row in dtLineItems.Rows )
										{
											if ( row.RowState != DataRowState.Deleted )
											{
												Guid     gITEM_ID             = Sql.ToGuid    (row["ID"                 ]);
												Guid     gLINE_GROUP_ID       = Sql.ToGuid    (row["LINE_GROUP_ID"      ]);
												string   sLINE_ITEM_TYPE      = Sql.ToString  (row["LINE_ITEM_TYPE"     ]);
												//int      nPOSITION            = Sql.ToInteger (row["POSITION"           ]);
												string   sNAME                = Sql.ToString  (row["NAME"               ]);
												string   sMFT_PART_NUM        = Sql.ToString  (row["MFT_PART_NUM"       ]);
												string   sVENDOR_PART_NUM     = Sql.ToString  (row["VENDOR_PART_NUM"    ]);
												Guid     gPRODUCT_TEMPLATE_ID = Sql.ToGuid    (row["PRODUCT_TEMPLATE_ID"]);
												Guid     gPARENT_TEMPLATE_ID  = Sql.ToGuid    (row["PARENT_TEMPLATE_ID" ]);
												string   sTAX_CLASS           = Sql.ToString  (row["TAX_CLASS"          ]);
												float    nQUANTITY            = Sql.ToFloat   (row["QUANTITY"           ]);
												Decimal  dCOST_PRICE          = Sql.ToDecimal (row["COST_PRICE"         ]);
												Decimal  dLIST_PRICE          = Sql.ToDecimal (row["LIST_PRICE"         ]);
												Decimal  dUNIT_PRICE          = Sql.ToDecimal (row["UNIT_PRICE"         ]);
												string   sDESCRIPTION         = Sql.ToString  (row["DESCRIPTION"        ]);
												Guid     gDISCOUNT_ID         = Sql.ToGuid    (row["DISCOUNT_ID"        ]);
												Decimal  dDISCOUNT_PRICE      = Sql.ToDecimal (row["DISCOUNT_PRICE"     ]);
												string   sPRICING_FORMULA     = Sql.ToString  (row["PRICING_FORMULA"    ]);
												float    fPRICING_FACTOR      = Sql.ToFloat   (row["PRICING_FACTOR"     ]);
												Guid     gTAXRATE_ID          = Sql.ToGuid    (row["TAXRATE_ID"         ]);
												string   sOPPORTUNITY_TYPE    = Sql.ToString  (row["OPPORTUNITY_TYPE"   ]);
												string   sLEAD_SOURCE         = Sql.ToString  (row["LEAD_SOURCE"        ]);
												DateTime dtDATE_CLOSED        = Sql.ToDateTime(row["DATE_CLOSED"        ]);
												string   sNEXT_STEP           = Sql.ToString  (row["NEXT_STEP"          ]);
												string   sSALES_STAGE         = Sql.ToString  (row["SALES_STAGE"        ]);
												float    fPROBABILITY         = Sql.ToFloat   (row["PROBABILITY"        ]);
												
												if ( EditLineItemsView.IsLineItemNotEmpty(row) )
												{
													SqlProcs.spREVENUE_LINE_ITEMS_Update
														( ref gITEM_ID        
														, gID                 
														, gLINE_GROUP_ID      
														, sLINE_ITEM_TYPE     
														, nPOSITION           
														, sNAME               
														, sMFT_PART_NUM       
														, sVENDOR_PART_NUM    
														, gPRODUCT_TEMPLATE_ID
														, sTAX_CLASS          
														, nQUANTITY           
														, dCOST_PRICE         
														, dLIST_PRICE         
														, dUNIT_PRICE         
														, sDESCRIPTION        
														, gPARENT_TEMPLATE_ID 
														, gDISCOUNT_ID        
														, dDISCOUNT_PRICE     
														, sPRICING_FORMULA    
														, fPRICING_FACTOR     
														, gTAXRATE_ID         
														, sOPPORTUNITY_TYPE   
														, sLEAD_SOURCE        
														, dtDATE_CLOSED       
														, sNEXT_STEP          
														, sSALES_STAGE        
														, fPROBABILITY        
														, trn
														);
													SplendidDynamic.UpdateCustomFields(row, trn, gITEM_ID, "REVENUE_LINE_ITEMS", dtCustomLineItems);
													nPOSITION++;
												}
											}
										}
									}
									else
									{
										// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
										// 12/29/2007 Paul.  TEAM_ID is now in the stored procedure. 
										// 04/07/2010 Paul.  Add EXCHANGE_FOLDER. 
										// 05/01/2013 Paul.  Add Contacts field to support B2C. 
										// 08/08/2015 Paul.  Separate relationship for Leads/Opportunities. 
										SqlProcs.spOPPORTUNITIES_Update
											( ref gID
											, new DynamicControl(this, rowCurrent, "ASSIGNED_USER_ID").ID
											, new DynamicControl(this, rowCurrent, "ACCOUNT_ID"      ).ID
											, new DynamicControl(this, rowCurrent, "NAME"            ).Text
											, new DynamicControl(this, rowCurrent, "OPPORTUNITY_TYPE").SelectedValue
											, new DynamicControl(this, rowCurrent, "LEAD_SOURCE"     ).SelectedValue
											, new DynamicControl(this, rowCurrent, "AMOUNT"          ).DecimalValue
											, new DynamicControl(this, rowCurrent, "CURRENCY_ID"     ).ID  // 03/04/2006 Paul.  Correct name is CURRENCY_ID. 
											, new DynamicControl(this, rowCurrent, "DATE_CLOSED"     ).DateValue
											, new DynamicControl(this, rowCurrent, "NEXT_STEP"       ).Text
											, new DynamicControl(this, rowCurrent, "SALES_STAGE"     ).SelectedValue
											, new DynamicControl(this, rowCurrent, "PROBABILITY"     ).FloatValue
											, new DynamicControl(this, rowCurrent, "DESCRIPTION"     ).Text
											, sMODULE
											, gPARENT_ID
											, String.Empty  // 11/02/2006 Paul.  ACCOUNT_NAME is only used for import. 
											, new DynamicControl(this, rowCurrent, "TEAM_ID"         ).ID
											, new DynamicControl(this, rowCurrent, "TEAM_SET_LIST"   ).Text
											, new DynamicControl(this, rowCurrent, "CAMPAIGN_ID"     ).ID  // 12/16/2009 Paul.  Add Campaign tracking. 
											, new DynamicControl(this, rowCurrent, "EXCHANGE_FOLDER" ).Checked
											, new DynamicControl(this, rowCurrent, "B2C_CONTACT_ID"  ).ID
											, new DynamicControl(this, rowCurrent, "LEAD_ID"         ).ID
											// 05/12/2016 Paul.  Add Tags module. 
											, new DynamicControl(this, rowCurrent, "TAG_SET_NAME"    ).Text
											// 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
											, new DynamicControl(this, rowCurrent, "OPPORTUNITY_NUMBER").Text
											// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
											, new DynamicControl(this, rowCurrent, "ASSIGNED_SET_LIST" ).Text
											, trn
											);
										SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
									}
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
									// 04/28/2007 Paul.  Assign quote relationship if this came from a quote. 
									if ( !Sql.IsEmptyGuid(gQUOTE_ID) )
									{
										SqlProcs.spQUOTES_OPPORTUNITIES_Update(gQUOTE_ID, gID, trn);
									}
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
						}
						
						if ( !Sql.IsEmptyString(RulesRedirectURL) )
							Response.Redirect(RulesRedirectURL);
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
					// 08/07/2015 Paul.  Revenue Line Items. 
					ctlEditLineItemsView.Visible = (Sql.ToString(Application["CONFIG.OpportunitiesMode"]) == "Revenue");
					
					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							string sSQL ;
							// 04/03/2010 Paul.  Add EXCHANGE_FOLDER. 
							// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
							sSQL = "select " + m_sVIEW_NAME + ".*"                                                    + ControlChars.CrLf
							     + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
							     + "     , (case when vwOPPORTUNITIES_USERS.OPPORTUNITY_ID is null then 0 else 1 end) as EXCHANGE_FOLDER" + ControlChars.CrLf
							     + "  from            " + m_sVIEW_NAME                                                + ControlChars.CrLf
							     + "  left outer join vwOPPORTUNITIES_USERS                                         " + ControlChars.CrLf
							     + "               on vwOPPORTUNITIES_USERS.OPPORTUNITY_ID = " + m_sVIEW_NAME + ".ID" + ControlChars.CrLf
							     + "              and vwOPPORTUNITIES_USERS.USER_ID        = @SYNC_USER_ID          " + ControlChars.CrLf;
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
											ctlDynamicButtons.Title = Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											Utils.UpdateTracker(Page, m_sMODULE, gID, ctlDynamicButtons.Title);
											ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;

											// 02/13/2013 Paul.  Move relationship append so that it can be controlled by business rules. 
											this.AppendEditViewRelationships(m_sMODULE + "." + LayoutEditView, plcSubPanel, Sql.IsEmptyGuid(Request["ID"]));
											this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, rdr);
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
												new DynamicControl(this, "OPPORTUNITY_NUMBER").Text = String.Empty;
											}
											// 12/09/2008 Paul.  Throw an exception if the record has been edited since the last load. 
											ViewState["LAST_DATE_MODIFIED"] = Sql.ToDateTime(rdr["DATE_MODIFIED"]);
											
											// 01/28/2010 Paul.  Use ViewState and Page.Items to be compatible with the DetailViews. 
											ViewState ["NAME"            ] = Sql.ToString(rdr["NAME"]);
											ViewState ["ASSIGNED_USER_ID"] = Sql.ToGuid  (rdr["ASSIGNED_USER_ID"]);
											Page.Items["NAME"            ] = ViewState ["NAME"            ];
											Page.Items["ASSIGNED_USER_ID"] = ViewState ["ASSIGNED_USER_ID"];
											// 08/07/2015 Paul.  Revenue Line Items. 
											if ( Sql.ToString(Application["CONFIG.OpportunitiesMode"]) == "Revenue" )
												ctlEditLineItemsView.LoadLineItems(gID, gDuplicateID, con, rdr);
											// 11/10/2010 Paul.  Apply Business Rules. 
											this.ApplyEditViewPostLoadEventRules(m_sMODULE + "." + LayoutEditView, rdr);
										}
										else
										{
											// 08/07/2015 Paul.  Revenue Line Items. 
											if ( Sql.ToString(Application["CONFIG.OpportunitiesMode"]) == "Revenue" )
												ctlEditLineItemsView.LoadLineItems(gID, gDuplicateID, con, null);
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
						this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, null);
						// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						ctlFooterButtons .AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
						// 02/18/2009 Paul.  On load, the focus should be set to the NAME field. 
						TextBox txtNAME = this.FindControl("NAME") as TextBox;
						if ( txtNAME != null )
							txtNAME.Focus();

						// 04/28/2007 Paul.  If created from a Quote, then load quote values. 
						Guid gQUOTE_ID = Sql.ToGuid(Request["QUOTE_ID"]);
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							// 09/21/2010 Paul.  Move con.open to top. 
							con.Open();
							string sSQL ;
							// 09/16/2010 Paul.  Only lookup Quote if QUOTE_ID provided. 
							if ( !Sql.IsEmptyGuid(gQUOTE_ID) )
							{
								sSQL = "select *       " + ControlChars.CrLf
								     + "  from vwQUOTES" + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									// 10/07/2010 Paul.  Filter by Quotes module. 
									Security.Filter(cmd, "Quotes", "view");
									Sql.AppendParameter(cmd, gQUOTE_ID, "ID", false);

									if ( bDebug )
										RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

									using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
									{
										if ( rdr.Read() )
										{
											new DynamicControl(this, "ACCOUNT_ID"  ).ID   = Sql.ToGuid  (rdr["BILLING_ACCOUNT_ID"  ]);
											new DynamicControl(this, "ACCOUNT_NAME").Text = Sql.ToString(rdr["BILLING_ACCOUNT_NAME"]);
											new DynamicControl(this, "AMOUNT"      ).DecimalValue = C10n.ToCurrency(Sql.ToDecimal(rdr["TOTAL_USDOLLAR"]));
											// 05/01/2013 Paul.  Add Contacts field to support B2C. 
											new DynamicControl(this, "B2C_CONTACT_ID"  ).ID   = Sql.ToGuid  (rdr["BILLING_CONTACT_ID"  ]);
											new DynamicControl(this, "B2C_CONTACT_NAME").Text = Sql.ToString(rdr["BILLING_CONTACT_NAME"]);
										}
									}
								}
							}

							// 09/18/2008 Paul.  Account should be prepopulated if created from Account. 
							Guid gPARENT_ID = Sql.ToGuid(Request["PARENT_ID"]);
							sSQL = "select *         " + ControlChars.CrLf
							     + "  from vwACCOUNTS" + ControlChars.CrLf;
							if ( !Sql.IsEmptyGuid(gPARENT_ID) )
							{
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									// 10/07/2010 Paul.  Filter by Accounts module. 
									Security.Filter(cmd, "Accounts", "view");
									Sql.AppendParameter(cmd, gPARENT_ID, "ID", false);

									if ( bDebug )
										RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

									using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
									{
										if ( rdr.Read() )
										{
											new DynamicControl(this, "ACCOUNT_ID"  ).ID   = Sql.ToGuid  (rdr["ID"  ]);
											new DynamicControl(this, "ACCOUNT_NAME").Text = Sql.ToString(rdr["NAME"]);
										}
									}
								}
								// 09/08/2010 Paul.  Prefill the Account for the Opportunity from a Contact parent. 
								sSQL = "select *         " + ControlChars.CrLf
								     + "  from vwCONTACTS" + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									// 10/07/2010 Paul.  Filter by Contacts module. 
									Security.Filter(cmd, "Contacts", "view");
									Sql.AppendParameter(cmd, gPARENT_ID, "ID", false);

									if ( bDebug )
										RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

									using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
									{
										if ( rdr.Read() )
										{
											new DynamicControl(this, "ACCOUNT_ID"  ).ID   = Sql.ToGuid  (rdr["ACCOUNT_ID"  ]);
											new DynamicControl(this, "ACCOUNT_NAME").Text = Sql.ToString(rdr["ACCOUNT_NAME"]);
											// 05/01/2013 Paul.  Add Contacts field to support B2C. 
											new DynamicControl(this, "B2C_CONTACT_ID"  ).ID   = Sql.ToGuid  (rdr["ID"          ]);
											new DynamicControl(this, "B2C_CONTACT_NAME").Text = Sql.ToString(rdr["NAME"        ]);
										}
									}
								}
							}
							// 04/04/2017 Paul.  Allow create from Lead. 
							Guid gLEAD_ID = Sql.ToGuid(Request["LEAD_ID"]);
							if ( !Sql.IsEmptyGuid(gLEAD_ID) )
							{
								sSQL = "select *         " + ControlChars.CrLf
								     + "  from vwLEADS   " + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Security.Filter(cmd, "Leads", "view");
									Sql.AppendParameter(cmd, gLEAD_ID, "ID", false);

									if ( bDebug )
										RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

									using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
									{
										if ( rdr.Read() )
										{
											new DynamicControl(this, "LEAD_ID"      ).ID   = Sql.ToGuid  (rdr["ID"           ]);
											new DynamicControl(this, "LEAD_NAME"    ).Text = Sql.ToString(rdr["NAME"         ]);
											// 11/29/2017 Paul.  Migrate the Campaign ID for a customer. 
											new DynamicControl(this, "CAMPAIGN_ID"  ).ID   = Sql.ToGuid  (rdr["CAMPAIGN_ID"  ]);
											new DynamicControl(this, "CAMPAIGN_NAME").Text = Sql.ToString(rdr["CAMPAIGN_NAME"]);
											// 08/30/2017 Paul.  Apply inherit rules. 
											if ( Sql.ToBoolean(Application["CONFIG.inherit_assigned_user"]) )
											{
												new DynamicControl(this, "ASSIGNED_USER_ID").ID   = Sql.ToGuid  (rdr["ASSIGNED_USER_ID"]);
												new DynamicControl(this, "ASSIGNED_TO"     ).Text = Sql.ToString(rdr["ASSIGNED_TO"     ]);
												new DynamicControl(this, "ASSIGNED_TO_NAME").Text = Sql.ToString(rdr["ASSIGNED_TO_NAME"]);
												// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
												if ( Crm.Config.enable_dynamic_assignment() )
												{
													SplendidCRM._controls.UserSelect ctlUserSelect = FindControl("ASSIGNED_SET_NAME") as SplendidCRM._controls.UserSelect;
													if ( ctlUserSelect != null )
														ctlUserSelect.LoadLineItems(Sql.ToGuid(rdr["ASSIGNED_SET_ID"]), true, true);
												}
											}
											if ( Sql.ToBoolean(Application["CONFIG.inherit_team"]) )
											{
												new DynamicControl(this, "TEAM_ID"  ).ID   = Sql.ToGuid  (rdr["TEAM_ID"  ]);
												new DynamicControl(this, "TEAM_NAME").Text = Sql.ToString(rdr["TEAM_NAME"]);
												SplendidCRM._controls.TeamSelect ctlTeamSelect = FindControl("TEAM_SET_NAME") as SplendidCRM._controls.TeamSelect;
												if ( ctlTeamSelect != null )
													ctlTeamSelect.LoadLineItems(Sql.ToGuid(rdr["TEAM_SET_ID"]), true, true);
											}
										}
									}
								}
							}
						}
						// 08/07/2015 Paul.  Revenue Line Items. 
						if ( Sql.ToString(Application["CONFIG.OpportunitiesMode"]) == "Revenue" )
							ctlEditLineItemsView.LoadLineItems(gID, gDuplicateID, null, null);
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
			m_sMODULE = "Opportunities";
			// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
			m_sVIEW_NAME = "vw" + Crm.Modules.TableName(m_sMODULE) + "_Edit";
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				// 04/19/2010 Paul.  New approach to EditView Relationships will distinguish between New Record and Existing Record.
				// 02/13/2013 Paul.  Move relationship append so that it can be controlled by business rules. 
				this.AppendEditViewRelationships(m_sMODULE + "." + LayoutEditView, plcSubPanel, Sql.IsEmptyGuid(Request["ID"]));
				// 12/02/2005 Paul.  Need to add the edit fields in order for events to fire. 
				this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, null);
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

