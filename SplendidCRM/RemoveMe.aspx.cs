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
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for RemoveMe.
	/// </summary>
	public class RemoveMe : SplendidPage
	{
		protected Literal         litREMOVE_ME_HEADER;
		protected Literal         litREMOVE_ME_FOOTER;
		protected RadioButtonList radREASON          ;
		protected Button          btnSubmit          ;
		protected Label           lblError           ;
		protected Label           lblWarning         ;

		override protected bool AuthenticationRequired()
		{
			return false;
		}

		// 08/26/2012 Paul.  Provide a way to customize the Remove Me page. 
		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Submit" )
				{
					litREMOVE_ME_HEADER.Text = L10n.Term("Campaigns.LBL_REMOVE_ME_HEADER_STEP2");
					litREMOVE_ME_FOOTER.Text = L10n.Term("Campaigns.LBL_REMOVE_ME_FOOTER_STEP2");
					radREASON.Visible = false;
					btnSubmit.Visible = false;
					
					Guid   gNOTE_ID     = Guid.Empty;
					Guid   gTARGET_ID   = Sql.ToGuid  (ViewState["TARGET_ID"  ]);
					string sTARGET_TYPE = Sql.ToString(ViewState["TARGET_TYPE"]);
					// 05/17/2017 Paul.  Add Tags module. 
					// 11/07/2017 Paul.  Add IS_PRIVATE for use by a large customer. 
					SqlProcs.spNOTES_Update
						( ref gNOTE_ID
						, "RemoveMe " + radREASON.Text
						, sTARGET_TYPE
						, gTARGET_ID
						, Guid.Empty
						, String.Empty
						, Guid.Empty
						, String.Empty
						, Guid.Empty
						, String.Empty
						, false
						// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
						, String.Empty   // ASSIGNED_SET_LIST
						);
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
			if ( !IsPostBack )
			{
				SplendidError.SystemMessage("Log", new StackTrace(true).GetFrame(0), "Remove Me " + Request["identifier"]);
				radREASON.DataSource = SplendidCache.List("remove_me_reason_dom");
				radREASON.DataBind();
			}
			try
			{
				Guid gID = Sql.ToGuid(Request["identifier"]);
				if ( !Sql.IsEmptyGuid(gID) )
				{
					Guid   gTARGET_ID   = Guid.Empty;
					string sTARGET_TYPE = string.Empty;
					SqlProcs.spCAMPAIGN_LOG_UpdateTracker(gID, "removed", Guid.Empty, ref gTARGET_ID, ref sTARGET_TYPE);
					if ( sTARGET_TYPE == "Users" )
					{
						lblError.Text = L10n.Term("Campaigns.LBL_USERS_CANNOT_OPTOUT");
						radREASON.Visible = false;
						btnSubmit.Visible = false;
					}
					else
					{
						ViewState["TARGET_ID"  ] = gTARGET_ID  ;
						ViewState["TARGET_TYPE"] = sTARGET_TYPE;
						litREMOVE_ME_HEADER.Text = L10n.Term("Campaigns.LBL_REMOVE_ME_HEADER_STEP1");
						litREMOVE_ME_FOOTER.Text = L10n.Term("Campaigns.LBL_REMOVE_ME_FOOTER_STEP1");
						radREASON.Visible = true;
						btnSubmit.Visible = true;
						SqlProcs.spCAMPAIGNS_OptOut(gTARGET_ID, sTARGET_TYPE);
						//lblError.Text = L10n.Term("Campaigns.LBL_ELECTED_TO_OPTOUT");
					}
				}
				// 11/23/2012 Paul.  Skip during precompile. 
				else if ( !Sql.ToBoolean(Request["PrecompileOnly"]) )
				{
					// 11/23/2012 Paul.  Don't use the standard error label as it will cause the precompile to stop. 
					lblWarning.Text = L10n.Term("Campaigns.LBL_REMOVE_ME_INVALID_IDENTIFIER");
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
				radREASON.Visible = false;
				btnSubmit.Visible = false;
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
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);
		}
		#endregion
	}
}

