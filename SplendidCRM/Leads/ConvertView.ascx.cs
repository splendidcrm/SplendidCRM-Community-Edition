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
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using SplendidCRM._controls;

namespace SplendidCRM.Leads
{
	/// <summary>
	///		Summary description for ConvertView.
	/// </summary>
	public class ConvertView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;

		protected Guid                   gID                                  ;
		protected HtmlTable              tblMain                              ;

		protected CheckBox               chkCreateNote                        ;
		protected ConvertViewNote        ctlConvertViewNote                   ;

		protected ConvertViewAccount     ctlConvertViewAccount                ;
		protected ConvertViewOpportunity ctlConvertViewOpportunity            ;
		protected ConvertViewAppointment ctlConvertViewAppointment            ;

		// 05/01/2013 Paul.  Add Contacts field to support B2C. 
		protected string                 sBusinessMode                        ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			// 03/22/2016 Paul.  Duplicate check during conversion. 
			if ( e.CommandName == "Save" || e.CommandName == "SaveDuplicate" )
			{
				try
				{
					// 01/31/2006 Paul.  Enable validator before validating page. 
					this.ValidateEditViewFields(m_sMODULE + "." + LayoutEditView);
					CheckBox chkCreateOpportunity = ctlConvertViewOpportunity.FindControl("chkCreateOpportunity") as CheckBox;
					if ( chkCreateOpportunity != null )
						Page.Items["chkCreateOpportunity.Checked"] = chkCreateOpportunity.Checked;
					ctlConvertViewAccount    .ValidateEditViewFields();
					ctlConvertViewOpportunity.ValidateEditViewFields();
					ctlConvertViewAppointment.ValidateEditViewFields();
					// 02/27/2006 Paul.  Fix condition on notes.  Enable only if text exists. 
					if ( chkCreateNote.Checked )
					{
						ctlConvertViewNote.ValidateEditViewFields();
					}
					
					// 05/25/2011 Paul.  Apply Business Rules. 
					this.ApplyEditViewValidationEventRules(m_sMODULE + "." + LayoutEditView);
					if ( Page.IsValid )
					{
						// 01/15/2009 Paul.  When converting a lead, the custom module is the destination module. 
						// 09/09/2009 Paul.  Use the new function to get the table name. 
						string sTABLE_NAME = Crm.Modules.TableName("Contacts");
						DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							// 05/25/2011 Paul.  Use the current values for any that are not defined in the edit view. 
							DataRow   rowCurrent = null;
							DataTable dtCurrent  = new DataTable();
							if ( !Sql.IsEmptyGuid(gID) )
							{
								string sSQL ;
								sSQL = "select *              " + ControlChars.CrLf
								     + "  from vwLEADS_Convert" + ControlChars.CrLf;
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
										}
									}
								}
							}
							// 03/22/2016 Paul.  Duplicate check during conversion. 
							bool bDUPLICATE_CHECHING_ENABLED = Sql.ToBoolean(Application["CONFIG.enable_duplicate_check"]) && Sql.ToBoolean(Application["Modules." + "Contacts" + ".DuplicateCheckingEnabled"]) && (e.CommandName != "SaveDuplicate");
							if ( bDUPLICATE_CHECHING_ENABLED )
							{
								if ( Utils.DuplicateCheck(Application, con, "Contacts", Guid.Empty, this, rowCurrent) > 0 )
								{
									ctlDynamicButtons.ShowButton("SaveDuplicate", true);
									throw(new Exception(L10n.Term(".ERR_DUPLICATE_EXCEPTION")));
								}
							}
							ctlConvertViewAccount    .DuplicateCheck(e.CommandName, con, ctlDynamicButtons);
							ctlConvertViewOpportunity.DuplicateCheck(e.CommandName, con, ctlDynamicButtons);
							
							// 05/25/2011 Paul.  Apply Business Rules. 
							this.ApplyEditViewPreSaveEventRules(m_sMODULE + "." + LayoutEditView, rowCurrent);
							
							// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									Guid   gCONTACT_ID       = Guid.Empty;
									Guid   gASSIGNED_USER_ID = new DynamicControl(this, rowCurrent, "ASSIGNED_USER_ID").ID;
									Guid   gTEAM_ID          = new DynamicControl(this, rowCurrent, "TEAM_ID"         ).ID;
									string sTEAM_SET_LIST    = new DynamicControl(this, rowCurrent, "TEAM_SET_LIST"   ).Text;
									// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
									string sASSIGNED_SET_LIST= new DynamicControl(this, rowCurrent, "ASSIGNED_SET_LIST").Text;
									// 01/31/2006 Paul.  Create the contact first so that it can be used as the parent of the related records. 
									// We would normally create the related records second, but then it will become a pain to update the Contact ACCOUNT_ID field. 
									// 01/16/2012 Paul.  Assigned User ID and Team ID are now parameters. 
									SqlProcs.spCONTACTS_New
										( ref gCONTACT_ID
										, new DynamicControl(this, rowCurrent, "FIRST_NAME").Text
										, new DynamicControl(this, rowCurrent, "LAST_NAME" ).Text
										, new DynamicControl(this, rowCurrent, "PHONE_WORK").Text
										, new DynamicControl(this, rowCurrent, "EMAIL1"    ).Text
										, gASSIGNED_USER_ID
										, gTEAM_ID
										, sTEAM_SET_LIST
										// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
										, sASSIGNED_SET_LIST
										, trn
										);
									
									ctlConvertViewAccount    .ASSIGNED_USER_ID = gASSIGNED_USER_ID;
									ctlConvertViewAccount    .TEAM_ID          = gTEAM_ID         ;
									ctlConvertViewAccount    .TEAM_SET_LIST    = sTEAM_SET_LIST   ;
									ctlConvertViewOpportunity.ASSIGNED_USER_ID = gASSIGNED_USER_ID;
									ctlConvertViewOpportunity.TEAM_ID          = gTEAM_ID         ;
									ctlConvertViewOpportunity.TEAM_SET_LIST    = sTEAM_SET_LIST   ;
									ctlConvertViewAppointment.ASSIGNED_USER_ID = gASSIGNED_USER_ID;
									ctlConvertViewAppointment.TEAM_ID          = gTEAM_ID         ;
									ctlConvertViewAppointment.TEAM_SET_LIST    = sTEAM_SET_LIST   ;
									
									if ( sBusinessMode != "B2C" )
										ctlConvertViewAccount.Save(gCONTACT_ID, "Contacts", trn);
									ctlConvertViewOpportunity.ACCOUNT_ID = ctlConvertViewAccount.ACCOUNT_ID;
									ctlConvertViewOpportunity.Save(gCONTACT_ID, "Contacts", trn);
									ctlConvertViewAppointment.Save(gCONTACT_ID, "Contacts", trn);
									// 05/25/2011 Paul.  Instead of using ViewState, load the previous record and let the DynamicControl use it if necessary. 
									SqlProcs.spCONTACTS_ConvertLead
										( ref gCONTACT_ID
										, gID                                   // 01/31/2006 Paul.  Update the Lead with this contact. 
										, gASSIGNED_USER_ID                     // 12/14/2013 Paul.  Allow user to change the Assigned User ID. 
										, new DynamicControl(this, rowCurrent, "SALUTATION"                ).SelectedValue
										, new DynamicControl(this, rowCurrent, "FIRST_NAME"                ).Text
										, new DynamicControl(this, rowCurrent, "LAST_NAME"                 ).Text
										, ctlConvertViewAccount.ACCOUNT_ID
										, new DynamicControl(this, rowCurrent, "LEAD_SOURCE"               ).SelectedValue
										, new DynamicControl(this, rowCurrent, "TITLE"                     ).Text
										, new DynamicControl(this, rowCurrent, "DEPARTMENT"                ).Text
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
										, ctlConvertViewOpportunity.OPPORTUNITY_ID
										, ctlConvertViewOpportunity.OPPORTUNITY_NAME
										, ctlConvertViewOpportunity.OPPORTUNITY_AMOUNT
										, new DynamicControl(this, rowCurrent, "CAMPAIGN_ID"               ).ID  // 12/16/2009 Paul.  Add Campaign tracking. 
										, gTEAM_ID
										, sTEAM_SET_LIST
										// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
										, sASSIGNED_SET_LIST
										, trn
										);
									if ( chkCreateNote.Checked )
									{
										ctlConvertViewNote.CONTACT_ID       = gCONTACT_ID      ;
										ctlConvertViewNote.ASSIGNED_USER_ID = gASSIGNED_USER_ID;
										ctlConvertViewNote.TEAM_ID          = gTEAM_ID         ;
										ctlConvertViewNote.TEAM_SET_LIST    = sTEAM_SET_LIST   ;
										ctlConvertViewNote.Save(gCONTACT_ID, "Contacts", trn);
									}
									// 02/26/2009 Paul.  We need to update the gCONTACT_ID, not the gID (which does nothing because it is an ID in the LEADS table).
									SplendidDynamic.UpdateCustomFields(this, trn, gCONTACT_ID, sTABLE_NAME, dtCustomFields);
									trn.Commit();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									ctlDynamicButtons.ErrorText = ex.Message;
									return;
								}
							}
							// 05/25/2011 Paul.  Apply Business Rules. 
							// 12/10/2012 Paul.  Provide access to the item data. 
							rowCurrent = Crm.Modules.ItemEdit(m_sMODULE, gID);
							this.ApplyEditViewPostSaveEventRules(m_sMODULE + "." + LayoutEditView, rowCurrent);
						}
						// 04/17/2016 Paul.  Allow redirect. 
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
			try
			{
				sBusinessMode = Sql.ToString(Application["CONFIG.BusinessMode"]);
				gID = Sql.ToGuid(Request["ID"]);
				SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
				if ( !IsPostBack )
				{
					chkCreateNote.Attributes.Add("onclick", "toggleDisplay('divCreateContactNote');");
					if ( !Sql.IsEmptyGuid(gID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							sSQL = "select *              " + ControlChars.CrLf
							     + "  from vwLEADS_Convert" + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								// 05/25/2011 Paul.  Use new Security.Filter() function to apply Team and ACL security rules.
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
											// 05/25/2011 Paul.  Apply Business Rules. 
											this.ApplyEditViewPreLoadEventRules(m_sMODULE + "." + LayoutEditView, rdr);
											
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = L10n.Term("Leads.LBL_CONVERTLEAD");
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											
											this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, rdr);
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
											// 01/31/2006 Paul.  Save all data to be used later. 
											// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
											// 05/25/2011 Paul.  Instead of using ViewState, load the previous record and let the DynamicControl use it if necessary. 
											/*
											for ( int i=0; i < dtCurrent.Columns.Count; i++ )
											{
												ViewState[dtCurrent.Columns[i].ColumnName] = rdr[dtCurrent.Columns[i].ColumnName];
											}
											*/
											// 05/25/2011 Paul.  Apply Business Rules. 
											this.ApplyEditViewPostLoadEventRules(m_sMODULE + "." + LayoutEditView, rdr);
										}
										else
										{
											// 11/25/2006 Paul.  If item is not visible, then don't allow save 
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
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
						// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
					}
				}
				else
				{
					// 12/02/2005 Paul.  When validation fails, the header title does not retain its value.  Update manually. 
					// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
					ctlDynamicButtons.Title = L10n.Term("Leads.LBL_CONVERTLEAD");
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
			m_sMODULE = "Leads";
			SetMenu(m_sMODULE);
			LayoutEditView = "ConvertView";
			if ( IsPostBack )
			{
				// 12/02/2005 Paul.  Need to add the edit fields in order for events to fire. 
				this.AppendEditViewFields(m_sMODULE + "." + LayoutEditView, tblMain, null);
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutEditView, Guid.Empty, null);
			}
		}
		#endregion
	}
}

