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

namespace SplendidCRM.Administration.Terminology
{
	/// <summary>
	///		Summary description for New.
	/// </summary>
	public class NewRecord : SplendidControl
	{
		protected Label                      lblError           ;
		protected TextBox                    txtNAME            ;
		protected TextBox                    txtDISPLAY_NAME    ;
		protected DropDownList               lstLANGUAGE        ;
		protected DropDownList               lstMODULE_NAME     ;
		protected DropDownList               lstLIST_NAME       ;
		protected TextBox                    txtLIST_ORDER      ;
		protected RequiredFieldValidator     reqNAME            ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "NewRecord" )
			{
				reqNAME.Enabled = true;
				reqNAME.Validate();
				if ( Page.IsValid )
				{
					Guid gID = Guid.Empty;
					try
					{
						SqlProcs.spTERMINOLOGY_InsertOnly(txtNAME.Text, lstLANGUAGE.SelectedValue, lstMODULE_NAME.SelectedValue, lstLIST_NAME.SelectedValue, Sql.ToInteger(txtLIST_ORDER.Text), txtDISPLAY_NAME.Text);
						// 01/16/2006 Paul.  Update language cache. 
						if ( Sql.IsEmptyString(lstLIST_NAME.SelectedValue) )
							L10N.SetTerm(lstLANGUAGE.SelectedValue, lstMODULE_NAME.SelectedValue, txtNAME.Text, txtDISPLAY_NAME.Text);
						else
							L10N.SetTerm(lstLANGUAGE.SelectedValue, lstMODULE_NAME.SelectedValue, lstLIST_NAME.SelectedValue, txtNAME.Text, txtDISPLAY_NAME.Text);
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						lblError.Text = ex.Message;
					}
					if ( !Sql.IsEmptyGuid(gID) )
						Response.Redirect("default.aspx");
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
				return;
			// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
			//this.DataBind();  // Need to bind so that Text of the Button gets updated. 
			reqNAME.ErrorMessage = L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("Terminology.LBL_LIST_NAME") + "<br>";
			// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
			bool bIsPostBack = this.IsPostBack && !NotPostBack;
			if ( !bIsPostBack )
			{
				// 05/06/2010 Paul.  When the control is created out-of-band, we need to manually bind the controls. 
				if ( NotPostBack )
					this.DataBind();
				// 01/12/2006 Paul.  Language cannot be null. 
				lstLANGUAGE.DataSource = SplendidCache.Languages();
				lstLANGUAGE.DataBind();

				DataTable dtModules = SplendidCache.Modules().Copy();
				dtModules.Rows.InsertAt(dtModules.NewRow(), 0);
				lstMODULE_NAME.DataSource = dtModules;
				lstMODULE_NAME.DataBind();
				// 01/12/2006 Paul.  Insert is failing, but I don't know why.  
				// It might be because the NewRecord control is loaded using LoadControl. 
				// Very odd as the Search Control is not having a problem inserting a value. 
				//lstMODULE_NAME.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));

				DataTable dtPickLists = SplendidCache.TerminologyPickLists().Copy();
				dtPickLists.Rows.InsertAt(dtPickLists.NewRow(), 0);
				lstLIST_NAME.DataSource = dtPickLists;
				lstLIST_NAME.DataBind();
				//lstLIST_NAME.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));

				try
				{
					// 01/12/2006 Paul.  Set default value to current language. 
					// 01/12/2006 Paul.  This is not working.  Use client-side script to select the default. 
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstLANGUAGE, L10N.NormalizeCulture(L10n.NAME));
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				}
				//this.DataBind();
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
			m_sMODULE = "Terminology";
		}
		#endregion
	}
}

