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
	///		Summary description for ConvertViewNote.
	/// </summary>
	public class ConvertViewNote : InlineEditControl
	{
		protected Guid                   gNOTE_ID                             ;
		protected Guid                   gCONTACT_ID                          ;
		protected Guid                   gASSIGNED_USER_ID                    ;
		protected Guid                   gTEAM_ID                             ;
		protected string                 sTEAM_SET_LIST                       ;
		// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
		protected string                 sASSIGNED_SET_LIST                   ;

		protected HtmlTable              tblMain                              ;

		public Guid NOTE_ID
		{
			get { return gNOTE_ID; }
			set { gNOTE_ID = value; }
		}

		public Guid CONTACT_ID
		{
			get { return gCONTACT_ID; }
			set { gCONTACT_ID = value; }
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
			this.ValidateEditViewFields           ("Leads.ConvertViewNote");
			this.ApplyEditViewValidationEventRules("Leads.ConvertViewNote");
		}

		public override void Save(Guid gPARENT_ID, string sPARENT_TYPE, IDbTransaction trn)
		{
			if ( IsEmpty() )
				return;
			
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
			
			if ( sPARENT_TYPE == "Contacts" )
				gCONTACT_ID = gPARENT_ID;
			if ( gCONTACT_ID == gPARENT_ID )
			{
				gPARENT_ID   = Guid.Empty  ;
				sPARENT_TYPE = String.Empty;
			}
			this.ApplyEditViewPreSaveEventRules("Leads.ConvertViewNote", null);
			SqlProcs.spNOTES_Update
				( ref gNOTE_ID
				, new DynamicControl(this, "NAME"       ).Text
				, sPARENT_TYPE
				, gPARENT_ID
				, gCONTACT_ID
				, new DynamicControl(this, "DESCRIPTION").Text
				, gTEAM_ID
				, sTEAM_SET_LIST
				, gASSIGNED_USER_ID
				// 05/17/2017 Paul.  Add Tags module. 
				, new DynamicControl(this, "TAG_SET_NAME").Text
				// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
				, new DynamicControl(this, "IS_PRIVATE"  ).Checked
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				, sASSIGNED_SET_LIST
				, trn
				);
			SplendidDynamic.UpdateCustomFields(this, trn, gNOTE_ID, sTABLE_NAME, dtCustomFields);
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 04/17/2016 Paul.  Hide panel if module disabled. 
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "edit") >= 0) && Sql.ToBoolean(Application["Modules." + m_sMODULE + ".Valid"]);
			if ( !this.Visible )
				return;

			try
			{
				Guid gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					if ( !Sql.IsEmptyGuid(gID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							sSQL = "select *                  " + ControlChars.CrLf
							     + "  from vwLEADS_ConvertNote" + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Security.Filter(cmd, m_sMODULE, "edit");
								Sql.AppendParameter(cmd, gID, "ID", false);
								con.Open();

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
											this.ApplyEditViewPreLoadEventRules ("Leads.ConvertViewNote", rdr);
											this.AppendEditViewFields           ("Leads.ConvertViewNote", tblMain, rdr);
											this.ApplyEditViewPostLoadEventRules("Leads.ConvertViewNote", rdr);
										}
									}
								}
							}
						}
					}
					else
					{
						this.AppendEditViewFields      ("Leads.ConvertViewNote", tblMain, null);
						this.ApplyEditViewNewEventRules("Leads.ConvertViewNote");
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
			m_sMODULE = "Notes";
			if ( IsPostBack )
			{
				this.AppendEditViewFields("Leads.ConvertViewNote", tblMain, null);
				Page.Validators.Add(new RulesValidator(this));
			}
		}
		#endregion
	}
}

