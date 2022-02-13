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

namespace SplendidCRM.ActivityStream
{
	/// <summary>
	///		Summary description for New.
	/// </summary>
	public class NewRecord : NewRecordControl
	{
		protected _controls.HeaderLeft  ctlHeaderLeft;
		protected HtmlTable             tblMain      ;
		protected Label                 lblError     ;
		protected Panel                 pnlMain      ;
		protected Panel                 pnlEdit      ;
		protected Button                btnSubmit    ;
		protected Button                btnCancel    ;

		public string Module
		{
			get { return m_sMODULE; }
			set { m_sMODULE = value; }
		}

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
				this.ApplyEditViewValidationEventRules(m_sMODULE + "." + sEditView);
			}
		}

		public override void Save(Guid gPARENT_ID, string sPARENT_TYPE, IDbTransaction trn)
		{
			if ( IsEmpty() )
				return;
			
			string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
			
			// 09/27/2015 Paul.  Things are non-standard in this control.  The PARENT_ID comes from a post within the DetailView of a record of this module. 
			// The PARENT_ID is a user-selected value to which the post refers, which might be different than this module. 
			IDbCommand spSTREAM_InsertPost = SqlProcs.Factory(trn.Connection, "sp" + sTABLE_NAME + "_STREAM_InsertPost");
			IDbDataParameter parMODIFIED_USER_ID = Sql.FindParameter(spSTREAM_InsertPost, "@MODIFIED_USER_ID");
			IDbDataParameter parASSIGNED_USER_ID = Sql.FindParameter(spSTREAM_InsertPost, "@ASSIGNED_USER_ID");
			IDbDataParameter parTEAM_ID          = Sql.FindParameter(spSTREAM_InsertPost, "@TEAM_ID"         );
			IDbDataParameter parNAME             = Sql.FindParameter(spSTREAM_InsertPost, "@NAME"            );
			IDbDataParameter parRELATED_ID       = Sql.FindParameter(spSTREAM_InsertPost, "@RELATED_ID"      );
			IDbDataParameter parRELATED_MODULE   = Sql.FindParameter(spSTREAM_InsertPost, "@RELATED_MODULE"  );
			IDbDataParameter parRELATED_NAME     = Sql.FindParameter(spSTREAM_InsertPost, "@RELATED_NAME"    );
			IDbDataParameter parID               = Sql.FindParameter(spSTREAM_InsertPost, "@ID"              );
			Guid   gMODIFIED_USER_ID = Security.USER_ID;
			// 09/28/2015 Paul.  We are not using the standard ASSIGNED_USER_ID layout field because we do not want to set the default to the current user. 
			Guid   gASSIGNED_USER_ID = new DynamicControl(this, "USER_ID"    ).ID  ;
			Guid   gTEAM_ID          = Security.TEAM_ID;
			string sNAME             = new DynamicControl(this, "NAME"       ).Text;
			Guid   gRELATED_ID       = new DynamicControl(this, "PARENT_ID"  ).ID  ;
			string sRELATED_MODULE   = (!Sql.IsEmptyGuid(gRELATED_ID) ? new DynamicControl(this, "PARENT_ID_PARENT_TYPE").SelectedValue : String.Empty);
			string sRELATED_NAME     = new DynamicControl(this, "PARENT_NAME").Text;
			Guid   gID               = this.PARENT_ID;
			// 03/17/2020 Paul.  Correct length issue. 
			if ( sRELATED_MODULE.Length > parRELATED_MODULE.Size )
				sRELATED_MODULE = sRELATED_MODULE.Substring(0, parRELATED_MODULE.Size);
			if ( sRELATED_NAME.Length > parRELATED_NAME.Size )
				sRELATED_NAME = sRELATED_NAME.Substring(0, parRELATED_NAME.Size);
			parMODIFIED_USER_ID.Value = Sql.ToDBGuid  (gMODIFIED_USER_ID);
			parASSIGNED_USER_ID.Value = Sql.ToDBGuid  (gASSIGNED_USER_ID);
			parTEAM_ID         .Value = Sql.ToDBGuid  (gTEAM_ID         );
			parNAME            .Value = Sql.ToDBString(sNAME            );
			parRELATED_ID      .Value = Sql.ToDBGuid  (gRELATED_ID      );
			parRELATED_MODULE  .Value = Sql.ToDBString(sRELATED_MODULE  );
			parRELATED_NAME    .Value = Sql.ToDBString(sRELATED_NAME    );
			parID              .Value = Sql.ToDBGuid  (gID              );
			spSTREAM_InsertPost.Transaction = trn;
			spSTREAM_InsertPost.ExecuteNonQuery();
			// 09/28/2015 Paul.  Clear after saving. 
			new DynamicControl(this, "NAME"     ).Text = String.Empty;
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "NewRecord" )
				{
					this.ValidateEditViewFields(m_sMODULE + "." + sEditView);
					this.ApplyEditViewValidationEventRules(m_sMODULE + "." + sEditView);
					if ( Page.IsValid )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							this.ApplyEditViewPreSaveEventRules(m_sMODULE + "." + sEditView, null);
							
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									Save(Guid.Empty, String.Empty, trn);
									trn.Commit();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									lblError.Text = ex.Message;
									return;
								}
							}
						}
						if ( !Sql.IsEmptyString(RulesRedirectURL) )
							Response.Redirect(RulesRedirectURL);
						else if ( Command != null )
							Command(sender, new CommandEventArgs("InsertPost", null));
						else
							Response.Redirect("stream.aspx");
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
				lblError.Text = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 01/02/2020 Paul.  Allow the NewRecord to be disabled per module using config table. 
			this.Visible = (!Sql.ToBoolean(Application["CONFIG." + m_sMODULE + ".DisableNewRecord"]) || sEditView != "NewRecord") && (SplendidCRM.Security.GetUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				bool bIsPostBack = this.IsPostBack && !NotPostBack;
				if ( !bIsPostBack )
				{
					if ( NotPostBack )
						this.DataBind();
					this.AppendEditViewFields("ActivityStream.NewRecord", tblMain, null, btnSubmit.ClientID);
					if ( EditViewLoad != null )
						EditViewLoad(this, null);
					
					//if ( bShowFullForm || bShowCancel || sEditView != "NewRecord" )
					//{
					//	pnlMain.CssClass = "";
					//	pnlEdit.CssClass = "tabForm";
					//}
					btnCancel.Visible = bShowCancel;
					this.ApplyEditViewNewEventRules(m_sMODULE + "." + sEditView);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
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

			bool bIsPostBack = this.IsPostBack && !NotPostBack;
			if ( bIsPostBack )
			{
				this.AppendEditViewFields("ActivityStream.NewRecord", tblMain, null, btnSubmit.ClientID);
				if ( EditViewLoad != null )
					EditViewLoad(this, null);
				Page.Validators.Add(new RulesValidator(this));
			}
		}
		#endregion
	}
}

