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

namespace SplendidCRM.Leads
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
		// 05/05/2010 Paul.  We need a common way to access the parent from the Toolbar. 

		public Guid CALL_ID
		{
			get { return Sql.ToGuid(ViewState["CALL_ID"]); }
			set { ViewState["CALL_ID"] = value; }
		}

		public Guid MEETING_ID
		{
			get { return Sql.ToGuid(ViewState["MEETING_ID"]); }
			set { ViewState["MEETING_ID"] = value; }
		}

		// 04/20/2010 Paul.  Add functions to allow this control to be used as part of an InlineEdit operation. 
		public override bool IsEmpty()
		{
			string sNAME = new DynamicControl(this, "LAST_NAME").Text;
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
			
			Guid   gASSIGNED_USER_ID = new DynamicControl(this, "ASSIGNED_USER_ID").ID;
			Guid   gTEAM_ID          = new DynamicControl(this, "TEAM_ID"         ).ID;
			Guid   gACCOUNT_ID       = new DynamicControl(this, "ACCOUNT_ID"      ).ID;
			string sACCOUNT_NAME     = new DynamicControl(this, "ACCOUNT_NAME"    ).Text;
			Guid   gCALL_ID          = this.CALL_ID   ;
			Guid   gMEETING_ID       = this.MEETING_ID;
			if ( Sql.IsEmptyGuid(gASSIGNED_USER_ID) )
				gASSIGNED_USER_ID = Security.USER_ID;
			if ( Sql.IsEmptyGuid(gTEAM_ID) )
				gTEAM_ID = Security.TEAM_ID;
			// 05/16/2010 Paul.  The Account may come from the toolbar. 
			if ( sPARENT_TYPE == "Accounts" && Sql.IsEmptyGuid(gACCOUNT_ID) )
				gACCOUNT_ID = gPARENT_ID;
			// 04/02/2012 Paul.  Add ASSISTANT, ASSISTANT_PHONE, BIRTHDATE, WEBSITE. 
			SqlProcs.spLEADS_Update
				( ref gID
				, gASSIGNED_USER_ID
				, new DynamicControl(this, "SALUTATION"                ).SelectedValue
				, new DynamicControl(this, "FIRST_NAME"                ).Text
				, new DynamicControl(this, "LAST_NAME"                 ).Text
				, new DynamicControl(this, "TITLE"                     ).Text
				, new DynamicControl(this, "REFERED_BY"                ).Text
				, new DynamicControl(this, "LEAD_SOURCE"               ).SelectedValue
				, new DynamicControl(this, "LEAD_SOURCE_DESCRIPTION"   ).Text
				, new DynamicControl(this, "STATUS"                    ).SelectedValue
				, new DynamicControl(this, "STATUS_DESCRIPTION"        ).Text
				, new DynamicControl(this, "DEPARTMENT"                ).Text
				, Guid.Empty  // 06/24/2005. REPORTS_TO_ID is not used in version 3.0. 
				, new DynamicControl(this, "DO_NOT_CALL"               ).Checked
				, new DynamicControl(this, "PHONE_HOME"                ).Text
				, new DynamicControl(this, "PHONE_MOBILE"              ).Text
				, new DynamicControl(this, "PHONE_WORK"                ).Text
				, new DynamicControl(this, "PHONE_OTHER"               ).Text
				, new DynamicControl(this, "PHONE_FAX"                 ).Text
				, new DynamicControl(this, "EMAIL1"                    ).Text
				, new DynamicControl(this, "EMAIL2"                    ).Text
				, new DynamicControl(this, "EMAIL_OPT_OUT"             ).Checked
				, new DynamicControl(this, "INVALID_EMAIL"             ).Checked
				, new DynamicControl(this, "PRIMARY_ADDRESS_STREET"    ).Text
				, new DynamicControl(this, "PRIMARY_ADDRESS_CITY"      ).Text
				, new DynamicControl(this, "PRIMARY_ADDRESS_STATE"     ).Text
				, new DynamicControl(this, "PRIMARY_ADDRESS_POSTALCODE").Text
				, new DynamicControl(this, "PRIMARY_ADDRESS_COUNTRY"   ).Text
				, new DynamicControl(this, "ALT_ADDRESS_STREET"        ).Text
				, new DynamicControl(this, "ALT_ADDRESS_CITY"          ).Text
				, new DynamicControl(this, "ALT_ADDRESS_STATE"         ).Text
				, new DynamicControl(this, "ALT_ADDRESS_POSTALCODE"    ).Text
				, new DynamicControl(this, "ALT_ADDRESS_COUNTRY"       ).Text
				, new DynamicControl(this, "DESCRIPTION"               ).Text
				, sACCOUNT_NAME
				, new DynamicControl(this, "CAMPAIGN_ID"               ).ID
				, gTEAM_ID
				, new DynamicControl(this, "TEAM_SET_LIST"             ).Text
				, new DynamicControl(this, "CONTACT_ID"                ).ID
				, gACCOUNT_ID
				, new DynamicControl(this, "EXCHANGE_FOLDER"           ).Checked
				, new DynamicControl(this, "BIRTHDATE"                 ).DateValue
				, new DynamicControl(this, "ASSISTANT"                 ).Text
				, new DynamicControl(this, "ASSISTANT_PHONE"           ).Text
				, new DynamicControl(this, "WEBSITE"                   ).Text
				// 09/27/2013 Paul.  SMS messages need to be opt-in. 
				, new DynamicControl(this, "SMS_OPT_IN"                ).SelectedValue
				// 10/22/2013 Paul.  Provide a way to map Tweets to a parent. 
				, new DynamicControl(this, "TWITTER_SCREEN_NAME"       ).Text
				// 08/07/2015 Paul.  Add picture. 
				, new DynamicControl(this, "PICTURE"                   ).Text
				// 05/12/2016 Paul.  Add Tags module. 
				, new DynamicControl(this, "TAG_SET_NAME"              ).Text
				// 06/20/2017 Paul.  Add number fields to Contacts, Leads, Prospects, Opportunities and Campaigns. 
				, new DynamicControl(this, "LEAD_NUMBER"               ).Text
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				, new DynamicControl(this, "ASSIGNED_SET_LIST"         ).Text
				// 06/23/2018 Paul.  Add DP_BUSINESS_PURPOSE and DP_CONSENT_LAST_UPDATED for data privacy. 
				, new DynamicControl(this, "DP_BUSINESS_PURPOSE"       ).Text
				, new DynamicControl(this, "DP_CONSENT_LAST_UPDATED"   ).DateValue
				, trn
				);
			SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
			
			// 04/01/2012 Paul.  Use separate request fields when creating a contact from a call or a meeting. 
			if ( !Sql.IsEmptyGuid(gCALL_ID) )
				SqlProcs.spCALLS_LEADS_Update(gCALL_ID, gID, false, String.Empty, trn);
			if ( !Sql.IsEmptyGuid(gMEETING_ID) )
				SqlProcs.spMEETINGS_LEADS_Update(gMEETING_ID, gID, false, String.Empty, trn);
			// 04/20/2010 Paul.  For those procedures that do not include a PARENT_TYPE, 
			// we need a new relationship procedure. 
			SqlProcs.spLEADS_InsRelated(gID, sPARENT_TYPE, gPARENT_ID, trn);
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
									Guid   gPARENT_ID   = this.PARENT_ID  ;
									String sPARENT_TYPE = this.PARENT_TYPE;
									Save(gPARENT_ID, sPARENT_TYPE, trn);
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
					// 07/02/2018 Paul.  Allow defaults to display as checked for Opt Out and Do Not Call. 
					new DynamicControl(this, "EMAIL_OPT_OUT").Checked = Sql.ToBoolean(Application["CONFIG.default_email_opt_out"]);
					new DynamicControl(this, "DO_NOT_CALL"  ).Checked = Sql.ToBoolean(Application["CONFIG.default_do_not_call"  ]);
					// 06/04/2010 Paul.  Notify the parent that the fields have been loaded. 
					if ( EditViewLoad != null )
						EditViewLoad(this, null);
					
					// 02/21/2010 Paul.  When the Full Form buttons are used, we don't want the panel to have margins. 
					if ( bShowFullForm || bShowCancel || sEditView != "NewRecord" )
					{
						pnlMain.CssClass = "";
						pnlEdit.CssClass = "tabForm";
						
						Guid gPARENT_ID = this.PARENT_ID;
						if ( !Sql.IsEmptyGuid(gPARENT_ID) )
						{
							string sMODULE      = String.Empty;
							string sPARENT_TYPE = String.Empty;
							string sPARENT_NAME = String.Empty;
							SqlProcs.spPARENT_Get( ref gPARENT_ID, ref sMODULE, ref sPARENT_TYPE, ref sPARENT_NAME);
							if ( !Sql.IsEmptyGuid(gPARENT_ID) )
							{
								this.PARENT_ID   = gPARENT_ID;
								this.PARENT_TYPE = sPARENT_TYPE;
								// 05/16/2010 Paul.  The Account may come from the toolbar. 
								if ( sPARENT_TYPE == "Accounts" )
									new DynamicControl(this, "ACCOUNT_NAME").Text = sPARENT_NAME;
							}
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
			m_sMODULE = "Leads";
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

