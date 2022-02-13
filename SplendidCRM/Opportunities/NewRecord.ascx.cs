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
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Opportunities
{
	/// <summary>
	///		Summary description for New.
	/// </summary>
	public class NewRecord : NewRecordControl
	{
		protected _controls.DynamicButtons ctlDynamicButtons;
		protected _controls.DynamicButtons ctlFooterButtons ;
		protected _controls.HeaderLeft     ctlHeaderLeft    ;

		protected Guid            gID                             ;
		protected HtmlTable       tblMain                         ;
		protected Label           lblError                        ;
		protected Panel           pnlMain                         ;
		protected Panel           pnlEdit                         ;

		// 05/06/2010 Paul.  We need a common way to attach a command from the Toolbar. 

		public Guid ACCOUNT_ID
		{
			get
			{
				// 02/21/2010 Paul.  An EditView Inline will use the ViewState, and a NewRecord Inline will use the Request. 
				Guid gACCOUNT_ID = Sql.ToGuid(ViewState["ACCOUNT_ID"]);
				if ( Sql.IsEmptyGuid(gACCOUNT_ID) )
					gACCOUNT_ID = Sql.ToGuid(Request["ACCOUNT_ID"]);
				return gACCOUNT_ID;
			}
			set
			{
				ViewState["ACCOUNT_ID"] = value;
			}
		}

		// 08/08/2015 Paul.  Separate relationship for Leads/Opportunities. 
		public Guid LEAD_ID
		{
			get
			{
				// 02/21/2010 Paul.  An EditView Inline will use the ViewState, and a NewRecord Inline will use the Request. 
				Guid gLEAD_ID = Sql.ToGuid(ViewState["LEAD_ID"]);
				if ( Sql.IsEmptyGuid(gLEAD_ID) )
					gLEAD_ID = Sql.ToGuid(Request["LEAD_ID"]);
				return gLEAD_ID;
			}
			set
			{
				ViewState["ACCOUNT_ID"] = value;
			}
		}


		// 05/01/2013 Paul.  Add Contacts field to support B2C. 
		public Guid B2C_CONTACT_ID
		{
			get
			{
				// 02/21/2010 Paul.  An EditView Inline will use the ViewState, and a NewRecord Inline will use the Request. 
				Guid gB2C_CONTACT_ID = Sql.ToGuid(ViewState["B2C_CONTACT_ID"]);
				if ( Sql.IsEmptyGuid(gB2C_CONTACT_ID) )
					gB2C_CONTACT_ID = Sql.ToGuid(Request["B2C_CONTACT_ID"]);
				return gB2C_CONTACT_ID;
			}
			set
			{
				ViewState["B2C_CONTACT_ID"] = value;
			}
		}

		// 04/20/2010 Paul.  Add functions to allow this control to be used as part of an InlineEdit operation. 
		public override bool IsEmpty()
		{
			string sNAME = new DynamicControl(this, "NAME").Text;
			return Sql.IsEmptyString(sNAME);
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

		public override void Save(Guid gPARENT_ID, string sPARENT_TYPE, IDbTransaction trn)
		{
			if ( IsEmpty() )
				return;
			
			string    sTABLE_NAME    = Crm.Modules.TableName(m_sMODULE);
			DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
			
			Guid gASSIGNED_USER_ID = new DynamicControl(this, "ASSIGNED_USER_ID").ID;
			Guid gTEAM_ID          = new DynamicControl(this, "TEAM_ID"         ).ID;
			Guid gACCOUNT_ID       = new DynamicControl(this, "ACCOUNT_ID"      ).ID;
			// 05/01/2013 Paul.  Add Contacts field to support B2C. 
			Guid gB2C_CONTACT_ID   = new DynamicControl(this, "B2C_CONTACT_ID"  ).ID;
			if ( Sql.IsEmptyGuid(gASSIGNED_USER_ID) )
				gASSIGNED_USER_ID = Security.USER_ID;
			if ( Sql.IsEmptyGuid(gTEAM_ID) )
				gTEAM_ID = Security.TEAM_ID;
			if ( Sql.IsEmptyGuid(gACCOUNT_ID) )
				gACCOUNT_ID = this.ACCOUNT_ID;
			if ( sPARENT_TYPE == "Accounts" && !Sql.IsEmptyGuid(gPARENT_ID) )
				gACCOUNT_ID = gPARENT_ID;
			// 05/01/2013 Paul.  Add Contacts field to support B2C. 
			if ( Sql.IsEmptyGuid(gB2C_CONTACT_ID) )
				gB2C_CONTACT_ID = this.B2C_CONTACT_ID;
			if ( sPARENT_TYPE == "Contacts" && !Sql.IsEmptyGuid(gPARENT_ID) )
				gB2C_CONTACT_ID = gPARENT_ID;
			// 05/01/2013 Paul.  Add Contacts field to support B2C. 
			// 08/08/2015 Paul.  Separate relationship for Leads/Opportunities. 
			Guid gLEAD_ID          = new DynamicControl(this, "LEAD_ID"         ).ID;
			if ( Sql.IsEmptyGuid(gLEAD_ID) )
				gLEAD_ID = this.LEAD_ID;
			SqlProcs.spOPPORTUNITIES_Update
				( ref gID
				, gASSIGNED_USER_ID
				, gACCOUNT_ID
				, new DynamicControl(this, "NAME"            ).Text
				, new DynamicControl(this, "OPPORTUNITY_TYPE").SelectedValue
				, new DynamicControl(this, "LEAD_SOURCE"     ).SelectedValue
				, new DynamicControl(this, "AMOUNT"          ).DecimalValue
				, new DynamicControl(this, "CURRENCY_ID"     ).ID  // 03/04/2006 Paul.  Correct name is CURRENCY_ID. 
				, new DynamicControl(this, "DATE_CLOSED"     ).DateValue
				, new DynamicControl(this, "NEXT_STEP"       ).Text
				, new DynamicControl(this, "SALES_STAGE"     ).SelectedValue
				, new DynamicControl(this, "PROBABILITY"     ).FloatValue
				, new DynamicControl(this, "DESCRIPTION"     ).Text
				, String.Empty
				, Guid.Empty
				, String.Empty  // 11/02/2006 Paul.  ACCOUNT_NAME is only used for import. 
				, gTEAM_ID
				, new DynamicControl(this, "TEAM_SET_LIST"   ).Text
				, new DynamicControl(this, "CAMPAIGN_ID"     ).ID  // 12/16/2009 Paul.  Add Campaign tracking. 
				, new DynamicControl(this, "EXCHANGE_FOLDER" ).Checked
				, gB2C_CONTACT_ID
				, gLEAD_ID
				// 05/12/2016 Paul.  Add Tags module. 
				, new DynamicControl(this, "TAG_SET_NAME"    ).Text
				// 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
				, new DynamicControl(this, "OPPORTUNITY_NUMBER").Text
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				, new DynamicControl(this, "ASSIGNED_SET_LIST" ).Text
				, trn
				);
			SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
			// 04/20/2010 Paul.  For those procedures that do not include a PARENT_TYPE, 
			// we need a new relationship procedure. 
			SqlProcs.spOPPORTUNITIES_InsRelated(gID, sPARENT_TYPE, gPARENT_ID, trn);
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "NewRecord" )
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
									// 10/11/2010 Paul.  The Parent can be a Contact, so pass it along. 
									Save(this.PARENT_ID, this.PARENT_TYPE, trn);
									trn.Commit();
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
						else if ( Command != null )
							Command(sender, new CommandEventArgs(e.CommandName, gID.ToString()));
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
					this.AppendEditViewFields(m_sMODULE + "." + sEditView, tblMain, null, ctlFooterButtons.ButtonClientID("NewRecord"));
					// 06/04/2010 Paul.  Notify the parent that the fields have been loaded. 
					if ( EditViewLoad != null )
						EditViewLoad(this, null);
					
					// 02/21/2010 Paul.  When the Full Form buttons are used, we don't want the panel to have margins. 
					if ( bShowFullForm || bShowCancel || sEditView != "NewRecord" )
					{
						pnlMain.CssClass = "";
						pnlEdit.CssClass = "tabForm";
						
						Guid   gACCOUNT_ID   = this.ACCOUNT_ID;
						string sACCOUNT_NAME = String.Empty;
						if ( !Sql.IsEmptyGuid(gACCOUNT_ID) )
						{
							sACCOUNT_NAME = Crm.Modules.ItemName(Application, "Accounts", gACCOUNT_ID);
						}
						if ( Sql.IsEmptyString(sACCOUNT_NAME) )
						{
							// 05/05/2010 Paul.  The Toolbar will only set the Parent, so we need to populate with this value. 
							Guid gPARENT_ID = this.PARENT_ID;
							if ( !Sql.IsEmptyGuid(gPARENT_ID) && this.PARENT_TYPE == "Accounts" )
							{
								gACCOUNT_ID   = gPARENT_ID;
								sACCOUNT_NAME = Crm.Modules.ItemName(Application, "Accounts", gACCOUNT_ID);
							}
							// 09/10/2010 Paul.  Prefill the Account for the Opportunity from a Contact parent. 
							else if ( !Sql.IsEmptyGuid(gPARENT_ID) && this.PARENT_TYPE == "Contacts" )
							{
								DbProviderFactory dbf = DbProviderFactories.GetFactory();
								using ( IDbConnection con = dbf.CreateConnection() )
								{
									con.Open();
									string sSQL ;
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
												gACCOUNT_ID   = Sql.ToGuid  (rdr["ACCOUNT_ID"  ]);
												sACCOUNT_NAME = Sql.ToString(rdr["ACCOUNT_NAME"]);
											}
										}
									}
								}
							}
							else
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
									if ( sPARENT_TYPE == "Accounts" )
									{
										gACCOUNT_ID   = gPARENT_ID;
										sACCOUNT_NAME = sPARENT_NAME;
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
								}
							}
						}
						if ( !Sql.IsEmptyGuid(gACCOUNT_ID) && !Sql.IsEmptyString(sACCOUNT_NAME) )
						{
							new DynamicControl(this, "ACCOUNT_ID"  ).ID   = gACCOUNT_ID;
							new DynamicControl(this, "ACCOUNT_NAME").Text = sACCOUNT_NAME;
						}
						// 05/01/2013 Paul.  Add Contacts field to support B2C. 
						Guid   gB2C_CONTACT_ID   = this.B2C_CONTACT_ID;
						string sB2C_CONTACT_NAME = String.Empty;
						if ( !Sql.IsEmptyGuid(gB2C_CONTACT_ID) )
						{
							sB2C_CONTACT_NAME = Crm.Modules.ItemName(Application, "Contacts", gB2C_CONTACT_ID);
						}
						else if ( Sql.IsEmptyString(sB2C_CONTACT_NAME) )
						{
							// 05/05/2010 Paul.  The Toolbar will only set the Parent, so we need to populate with this value. 
							Guid gPARENT_ID = this.PARENT_ID;
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
								if ( sPARENT_TYPE == "Contacts" )
								{
									gB2C_CONTACT_ID   = gPARENT_ID;
									sB2C_CONTACT_NAME = sPARENT_NAME;
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
							}
						}
						// 09/12/2010 Paul.  Initialize the AMOUNT. 
						string sAMOUNT = Sql.ToString(Request["AMOUNT"]);
						if ( !Sql.IsEmptyString(sAMOUNT) )
						{
							new DynamicControl(this, "AMOUNT").Text = sAMOUNT;
						}
					}
					// 10/20/2011 Paul.  Apply Business Rules to NewRecord. 
					this.ApplyEditViewNewEventRules(m_sMODULE + "." + sEditView);
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

			ctlDynamicButtons.AppendButtons("NewRecord." + (bShowFullForm ? "FullForm" : (bShowCancel ? "WithCancel" : "SaveOnly")), Guid.Empty, Guid.Empty);
			ctlFooterButtons .AppendButtons("NewRecord." + (bShowFullForm ? "FullForm" : (bShowCancel ? "WithCancel" : "SaveOnly")), Guid.Empty, Guid.Empty);
			m_sMODULE = "Opportunities";
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

