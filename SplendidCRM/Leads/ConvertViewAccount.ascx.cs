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
	///		Summary description for ConvertViewAccount.
	/// </summary>
	public class ConvertViewAccount : InlineEditControl
	{
		protected Guid                   gACCOUNT_ID                          ;
		protected Guid                   gASSIGNED_USER_ID                    ;
		protected Guid                   gTEAM_ID                             ;
		protected string                 sTEAM_SET_LIST                       ;
		// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		protected string                 sASSIGNED_SET_LIST                   ;

		protected HtmlTable              tblMain                              ;
		protected CheckBox               chkCreateAccount                     ;
		protected HtmlInputHidden        txtSELECT_ACCOUNT_ID                 ;
		protected RequiredFieldValidatorForHiddenInputs reqSELECT_ACCOUNT_ID  ;
		protected TextBox                txtSELECT_ACCOUNT_NAME               ;
		protected Label                  lblError                             ;

		protected CheckBox               chkCreateNote                        ;
		protected ConvertViewNote        ctlConvertViewNote                   ;

		// 05/01/2013 Paul.  Add Contacts field to support B2C. 
		protected string                 sBusinessMode                        ;

		public Guid ACCOUNT_ID
		{
			get { return gACCOUNT_ID; }
			set { gACCOUNT_ID = value; }
		}

		public Guid ASSIGNED_USER_ID
		{
			get { return gASSIGNED_USER_ID; }
			set { gASSIGNED_USER_ID = value; }
		}

		public Guid TEAM_ID
		{
			get { return gTEAM_ID; }
			set { gTEAM_ID = value; }
		}

		public string TEAM_SET_LIST
		{
			get { return sTEAM_SET_LIST; }
			set { sTEAM_SET_LIST = value; }
		}

		// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		public string ASSIGNED_SET_LIST
		{
			get { return sASSIGNED_SET_LIST; }
			set { sASSIGNED_SET_LIST = value; }
		}

		public override bool IsEmpty()
		{
			string sNAME = new DynamicControl(this, "NAME").Text;
			return Sql.IsEmptyString(sNAME);
		}

		public override void ValidateEditViewFields()
		{
			if ( chkCreateAccount.Checked )
			{
				this.ValidateEditViewFields           ("Leads.ConvertViewAccount");
				this.ApplyEditViewValidationEventRules("Leads.ConvertViewAccount");
				if ( chkCreateNote.Checked )
				{
					ctlConvertViewNote.ValidateEditViewFields();
				}
			}
			else
			{
				reqSELECT_ACCOUNT_ID.Enabled = !chkCreateAccount.Checked && (Sql.ToBoolean(Page.Items["chkCreateOpportunity.Checked"]) && sBusinessMode == "B2B");
				reqSELECT_ACCOUNT_ID.Validate();
			}
		}

		// 03/22/2016 Paul.  Duplicate check during conversion. 
		public void DuplicateCheck(string sCommandName, IDbConnection con, _controls.HeaderButtons ctlDynamicButtons)
		{
			if ( chkCreateAccount.Checked )
			{
				bool bDUPLICATE_CHECHING_ENABLED = Sql.ToBoolean(Application["CONFIG.enable_duplicate_check"]) && Sql.ToBoolean(Application["Modules." + m_sMODULE + ".DuplicateCheckingEnabled"]) && (sCommandName != "SaveDuplicate");
				if ( bDUPLICATE_CHECHING_ENABLED )
				{
					if ( Utils.DuplicateCheck(Application, con, m_sMODULE, Guid.Empty, this, null) > 0 )
					{
						ctlDynamicButtons.ShowButton("SaveDuplicate", true);
						lblError.Text = L10n.Term(".ERR_DUPLICATE_EXCEPTION");
						throw(new Exception(L10n.Term(".moduleList.", m_sMODULE) + ": " + L10n.Term(".ERR_DUPLICATE_EXCEPTION")));
					}
				}
			}
		}

		public override void Save(Guid gPARENT_ID, string sPARENT_TYPE, IDbTransaction trn)
		{
			//if ( IsEmpty() )
			//	return;
			
			if ( chkCreateAccount.Checked )
			{
				string    sTABLE_NAME    = Crm.Modules.TableName(m_sMODULE);
				DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
			
				if ( FindControl("ASSIGNED_USER_ID") != null )
					gASSIGNED_USER_ID = new DynamicControl(this, "ASSIGNED_USER_ID").ID;
				if ( FindControl("TEAM_ID") != null || FindControl("TEAM_SET_NAME") != null )
					gTEAM_ID = new DynamicControl(this, "TEAM_ID").ID;
				if ( FindControl("TEAM_SET_LIST") != null || FindControl("TEAM_SET_NAME") != null )
					sTEAM_SET_LIST = new DynamicControl(this, "TEAM_SET_LIST").Text;
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				if ( FindControl("ASSIGNED_SET_LIST") != null || FindControl("ASSIGNED_SET_NAME") != null )
					sASSIGNED_SET_LIST = new DynamicControl(this, "ASSIGNED_SET_LIST").Text;
				
				this.ApplyEditViewPreSaveEventRules("Leads.ConvertViewAccount", null);
				SqlProcs.spACCOUNTS_Update
					( ref gACCOUNT_ID
					, gASSIGNED_USER_ID
					, new DynamicControl(this, "NAME"                       ).Text
					, new DynamicControl(this, "ACCOUNT_TYPE"               ).SelectedValue
					, new DynamicControl(this, "PARENT_ID"                  ).ID
					, new DynamicControl(this, "INDUSTRY"                   ).SelectedValue
					, new DynamicControl(this, "ANNUAL_REVENUE"             ).Text
					, new DynamicControl(this, "PHONE_FAX"                  ).Text
					, new DynamicControl(this, "BILLING_ADDRESS_STREET"     ).Text
					, new DynamicControl(this, "BILLING_ADDRESS_CITY"       ).Text
					, new DynamicControl(this, "BILLING_ADDRESS_STATE"      ).Text
					, new DynamicControl(this, "BILLING_ADDRESS_POSTALCODE" ).Text
					, new DynamicControl(this, "BILLING_ADDRESS_COUNTRY"    ).Text
					, new DynamicControl(this, "DESCRIPTION"                ).Text
					, new DynamicControl(this, "RATING"                     ).Text
					, new DynamicControl(this, "PHONE_OFFICE"               ).Text
					, new DynamicControl(this, "PHONE_ALTERNATE"            ).Text
					, new DynamicControl(this, "EMAIL1"                     ).Text
					, new DynamicControl(this, "EMAIL2"                     ).Text
					, new DynamicControl(this, "WEBSITE"                    ).Text
					, new DynamicControl(this, "OWNERSHIP"                  ).Text
					, new DynamicControl(this, "EMPLOYEES"                  ).Text
					, new DynamicControl(this, "SIC_CODE"                   ).Text
					, new DynamicControl(this, "TICKER_SYMBOL"              ).Text
					, new DynamicControl(this, "SHIPPING_ADDRESS_STREET"    ).Text
					, new DynamicControl(this, "SHIPPING_ADDRESS_CITY"      ).Text
					, new DynamicControl(this, "SHIPPING_ADDRESS_STATE"     ).Text
					, new DynamicControl(this, "SHIPPING_ADDRESS_POSTALCODE").Text
					, new DynamicControl(this, "SHIPPING_ADDRESS_COUNTRY"   ).Text
					, new DynamicControl(this, "ACCOUNT_NUMBER"             ).Text
					, gTEAM_ID
					, sTEAM_SET_LIST
					, new DynamicControl(this, "EXCHANGE_FOLDER"            ).Checked
					// 08/07/2015 Paul.  Add picture. 
					, new DynamicControl(this, "PICTURE"                    ).Text
					// 05/12/2016 Paul.  Add Tags module. 
					, new DynamicControl(this, "TAG_SET_NAME"               ).Text
					// 06/07/2017 Paul.  Add NAICSCodes module. 
					, new DynamicControl(this, "NAICS_SET_NAME"             ).Text
					// 10/27/2017 Paul.  Add Accounts as email source. 
					, new DynamicControl(this, "DO_NOT_CALL"                ).Checked
					, new DynamicControl(this, "EMAIL_OPT_OUT"              ).Checked
					, new DynamicControl(this, "INVALID_EMAIL"              ).Checked
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					, sASSIGNED_SET_LIST
					, trn
					);
				SplendidDynamic.UpdateCustomFields(this, trn, gACCOUNT_ID, sTABLE_NAME, dtCustomFields);
				SqlProcs.spACCOUNTS_InsRelated(gACCOUNT_ID, sPARENT_TYPE, gPARENT_ID, trn);
				
				if ( chkCreateNote.Checked )
				{
					ctlConvertViewNote.CONTACT_ID       = gPARENT_ID       ;
					ctlConvertViewNote.ASSIGNED_USER_ID = gASSIGNED_USER_ID;
					ctlConvertViewNote.TEAM_ID          = gTEAM_ID         ;
					ctlConvertViewNote.TEAM_SET_LIST    = sTEAM_SET_LIST   ;
					ctlConvertViewNote.Save(gACCOUNT_ID, "Accounts", trn);
				}
			}
			else
			{
				gACCOUNT_ID = Sql.ToGuid(txtSELECT_ACCOUNT_ID.Value);
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 04/17/2016 Paul.  Hide panel if module disabled. 
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "edit") >= 0) && Sql.ToBoolean(Application["Modules." + m_sMODULE + ".Valid"]);
			if ( !this.Visible )
				return;

			try
			{
				sBusinessMode = Sql.ToString(Application["CONFIG.BusinessMode"]);
				reqSELECT_ACCOUNT_ID.DataBind();
				Guid gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					chkCreateAccount.Attributes.Add("onclick", "return ToggleCreateAccount();");
					chkCreateNote   .Attributes.Add("onclick", "toggleDisplay('divCreateAccountNote');");
					if ( !Sql.IsEmptyGuid(gID) )
					{
						string sACCOUNT_NAME = String.Empty;
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							string sSQL ;
							sSQL = "select *                     " + ControlChars.CrLf
							     + "  from vwLEADS_ConvertAccount" + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Security.Filter(cmd, m_sMODULE, "edit");
								Sql.AppendParameter(cmd, gID, "ID", false);

								if ( bDebug )
									RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dtCurrent = new DataTable() )
									{
										da.Fill(dtCurrent);
										if ( dtCurrent.Rows.Count > 0 )
										{
											DataRow rdr = dtCurrent.Rows[0];
											sACCOUNT_NAME = Sql.ToString(rdr["NAME"]);
											this.ApplyEditViewPreLoadEventRules ("Leads.ConvertViewAccount", rdr);
											this.AppendEditViewFields           ("Leads.ConvertViewAccount", tblMain, rdr);
											this.ApplyEditViewPostLoadEventRules("Leads.ConvertViewAccount", rdr);
										}
									}
								}
							}
							if ( !Sql.IsEmptyString(sACCOUNT_NAME) )
							{
								sSQL = "select ID        " + ControlChars.CrLf
								     + "  from vwACCOUNTS" + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Security.Filter(cmd, m_sMODULE, "edit");
									Sql.AppendParameter(cmd, sACCOUNT_NAME, "NAME");

									if ( bDebug )
										RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

									// 01/20/2020 Paul.  No need to declare a new variable. 
									gACCOUNT_ID = Sql.ToGuid(cmd.ExecuteScalar());
									if ( !Sql.IsEmptyGuid(gACCOUNT_ID) )
									{
										txtSELECT_ACCOUNT_ID.Value  = gACCOUNT_ID.ToString();
										txtSELECT_ACCOUNT_NAME.Text = sACCOUNT_NAME;
									}
								}
							}
						}
					}
					else
					{
						this.AppendEditViewFields      ("Leads.ConvertViewAccount", tblMain, null);
						this.ApplyEditViewNewEventRules("Leads.ConvertViewAccount");
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				//ctlDynamicButtons.ErrorText = ex.Message;
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
			m_sMODULE = "Accounts";
			if ( IsPostBack )
			{
				this.AppendEditViewFields("Leads.ConvertViewAccount", tblMain, null);
				Page.Validators.Add(new RulesValidator(this));
			}
		}
		#endregion
	}
}

