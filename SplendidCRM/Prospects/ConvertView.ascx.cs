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

namespace SplendidCRM.Prospects
{
	/// <summary>
	///		Summary description for ConvertView.
	/// </summary>
	public class ConvertView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;

		protected Guid            gID                             ;
		protected HtmlTable       tblMain                         ;
		// 09/02/2012 Paul.  EditViews were combined into a single view. 
		//protected HtmlTable       tblAddress                      ;
		//protected HtmlTable       tblDescription                  ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			// 03/22/2016 Paul.  Duplicate check during conversion. 
			if ( e.CommandName == "Save" || e.CommandName == "SaveDuplicate" )
			{
				// 12/26/2017 Paul.  We need to catch the duplicate exception, otherwise we get an ugly ASP.NET error screen. 
				try
				{
					// 01/16/2006 Paul.  Enable validator before validating page. 
					this.ValidateEditViewFields(m_sMODULE + ".ConvertView"       );
					this.ValidateEditViewFields(m_sMODULE + ".ConvertAddress"    );
					this.ValidateEditViewFields(m_sMODULE + ".ConvertDescription");
					// 10/28/2013 Paul.  Apply Business Rules. 
					this.ApplyEditViewValidationEventRules(m_sMODULE + ".ConvertView"       );
					this.ApplyEditViewValidationEventRules(m_sMODULE + ".ConvertAddress"    );
					this.ApplyEditViewValidationEventRules(m_sMODULE + ".ConvertDescription");
					if ( Page.IsValid )
					{
						Guid gLEAD_ID = Guid.Empty;
						string sTABLE_NAME = "LEADS";
						DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							// 10/28/2013 Paul.  Use the current values for any that are not defined in the edit view. 
							DataRow   rowCurrent = null;
							DataTable dtCurrent  = new DataTable();
							if ( !Sql.IsEmptyGuid(gID) )
							{
								string sSQL ;
								sSQL = "select *                  " + ControlChars.CrLf
								     + "  from vwPROSPECTS_Convert" + ControlChars.CrLf;
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
							bool bDUPLICATE_CHECHING_ENABLED = Sql.ToBoolean(Application["CONFIG.enable_duplicate_check"]) && Sql.ToBoolean(Application["Modules." + "Leads" + ".DuplicateCheckingEnabled"]) && (e.CommandName != "SaveDuplicate");
							if ( bDUPLICATE_CHECHING_ENABLED )
							{
								if ( Utils.DuplicateCheck(Application, con, "Leads", Guid.Empty, this, rowCurrent) > 0 )
								{
									ctlDynamicButtons.ShowButton("SaveDuplicate", true);
									throw(new Exception(L10n.Term(".ERR_DUPLICATE_EXCEPTION")));
								}
							}
							
							// 10/28/2013 Paul.  Apply Business Rules. 
							this.ApplyEditViewPreSaveEventRules(m_sMODULE + ".ConvertView"       , rowCurrent);
							this.ApplyEditViewPreSaveEventRules(m_sMODULE + ".ConvertAddress"    , rowCurrent);
							this.ApplyEditViewPreSaveEventRules(m_sMODULE + ".ConvertDescription", rowCurrent);
							
							// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									// 04/24/2006 Paul.  Upgrade to SugarCRM 4.2 Schema. 
									// 12/29/2007 Paul.  TEAM_ID is now in the stored procedure. 
									// 02/14/2010 Paul.  spLEADS_Update has changed to allow links to Account and Contact. 
									// 10/28/2013 Paul.  Instead of using ViewState, load the previous record and let the DynamicControl use it if necessary. 
									SqlProcs.spLEADS_ConvertProspect
										( ref gLEAD_ID
										, gID                                   // 01/31/2006 Paul.  Update the Prospect with this lead. 
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
										// 05/12/2016 Paul.  Add Tags module. 
										, new DynamicControl(this, rowCurrent, "TAG_SET_NAME"              ).Text
										// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
										, new DynamicControl(this, rowCurrent, "ASSIGNED_SET_LIST"         ).Text
										, trn
										);
									// 02/26/2009 Paul.  We need to update the gLEAD_ID, not the gID (which does nothing because it is an ID in the PROSPECTS table).
									SplendidDynamic.UpdateCustomFields(this, trn, gLEAD_ID, sTABLE_NAME, dtCustomFields);
									trn.Commit();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									ctlDynamicButtons.ErrorText = ex.Message;
									return;
								}
								// 10/28/2013 Paul.  Apply Business Rules. 
								rowCurrent = Crm.Modules.ItemEdit(m_sMODULE, gID);
								this.ApplyEditViewPostSaveEventRules(m_sMODULE + ".ConvertView"       , rowCurrent);
								this.ApplyEditViewPostSaveEventRules(m_sMODULE + ".ConvertAddress"    , rowCurrent);
								this.ApplyEditViewPostSaveEventRules(m_sMODULE + ".ConvertDescription", rowCurrent);
							}
							if ( !Sql.IsEmptyString(RulesRedirectURL) )
								Response.Redirect(RulesRedirectURL);
							else
								Response.Redirect("view.aspx?ID=" + gID.ToString());
						}
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
				gID = Sql.ToGuid(Request["ID"]);
				SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
				if ( !IsPostBack )
				{
					Guid gDuplicateID = Sql.ToGuid(Request["DuplicateID"]);
					if ( !Sql.IsEmptyGuid(gID) || !Sql.IsEmptyGuid(gDuplicateID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							sSQL = "select *                  " + ControlChars.CrLf
							     + "  from vwPROSPECTS_Convert" + ControlChars.CrLf
							     + " where ID = @ID           " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								if ( !Sql.IsEmptyGuid(gDuplicateID) )
								{
									Sql.AddParameter(cmd, "@ID", gDuplicateID);
									gID = Guid.Empty;
								}
								else
								{
									Sql.AddParameter(cmd, "@ID", gID);
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
										if ( dtCurrent.Rows.Count > 0 )
										{
											DataRow rdr = dtCurrent.Rows[0];
											// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
											ctlDynamicButtons.Title = L10n.Term("Prospects.LBL_CONVERTPROSPECT");
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											
											this.AppendEditViewFields(m_sMODULE + ".ConvertView"       , tblMain       , rdr);
											// 09/02/2012 Paul.  EditViews were combined into a single view. 
											//this.AppendEditViewFields(m_sMODULE + ".ConvertAddress"    , tblAddress    , rdr);
											//this.AppendEditViewFields(m_sMODULE + ".ConvertDescription", tblDescription, rdr);
											// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
											ctlDynamicButtons.AppendButtons(m_sMODULE + ".ConvertView", Sql.ToGuid(rdr["ASSIGNED_USER_ID"]), rdr);
										}
									}
								}
							}
						}
					}
					else
					{
						this.AppendEditViewFields(m_sMODULE + ".ConvertView"       , tblMain       , null);
						// 09/02/2012 Paul.  EditViews were combined into a single view. 
						//this.AppendEditViewFields(m_sMODULE + ".ConvertAddress"    , tblAddress    , null);
						//this.AppendEditViewFields(m_sMODULE + ".ConvertDescription", tblDescription, null);
						// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
						ctlDynamicButtons.AppendButtons(m_sMODULE + ".ConvertView", Guid.Empty, null);
					}
				}
				else
				{
					// 12/02/2005 Paul.  When validation fails, the header title does not retain its value.  Update manually. 
					// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
					ctlDynamicButtons.Title = L10n.Term("Prospects.LBL_CONVERTPROSPECT");
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
			m_sMODULE = "Prospects";
			if ( IsPostBack )
			{
				// 12/02/2005 Paul.  Need to add the edit fields in order for events to fire. 
				this.AppendEditViewFields(m_sMODULE + ".ConvertView"       , tblMain       , null);
				// 09/02/2012 Paul.  EditViews were combined into a single view. 
				//this.AppendEditViewFields(m_sMODULE + ".ConvertAddress"    , tblAddress    , null);
				//this.AppendEditViewFields(m_sMODULE + ".ConvertDescription", tblDescription, null);
				// 03/20/2008 Paul.  Dynamic buttons need to be recreated in order for events to fire. 
				ctlDynamicButtons.AppendButtons(m_sMODULE + ".ConvertView", Guid.Empty, null);
			}
		}
		#endregion
	}
}

