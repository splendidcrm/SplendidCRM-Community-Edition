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
using System.Web;
using System.Web.UI.WebControls;

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for DetailButtons.
	/// </summary>
	public class DetailButtons : SplendidControl
	{
		protected Label  lblError    ;
		protected Button btnEdit     ;
		protected Button btnDuplicate;
		protected Button btnDelete   ;

		public CommandEventHandler Command;

		public void DisableAll()
		{
			btnEdit     .Enabled = false;
			btnDuplicate.Enabled = false;
			btnDelete   .Enabled = false;
		}

		public bool EnableEdit
		{
			get
			{
				return btnEdit.Enabled;
			}
			set
			{
				btnEdit.Enabled = value;
			}
		}

		public bool EnableDuplicate
		{
			get
			{
				return btnDuplicate.Enabled;
			}
			set
			{
				btnDuplicate.Enabled = value;
			}
		}

		public bool EnableDelete
		{
			get
			{
				return btnDelete.Enabled;
			}
			set
			{
				btnDelete.Enabled = value;
			}
		}

		public bool ShowEdit
		{
			get
			{
				return btnEdit.Visible;
			}
			set
			{
				btnEdit.Visible = value;
			}
		}

		public bool ShowDuplicate
		{
			get
			{
				return btnDuplicate.Visible;
			}
			set
			{
				btnDuplicate.Visible = value;
			}
		}

		public bool ShowDelete
		{
			get
			{
				return btnDelete.Visible;
			}
			set
			{
				btnDelete.Visible = value;
			}
		}

		public string ErrorText
		{
			get
			{
				return lblError.Text;
			}
			set
			{
				lblError.Text = value;
			}
		}

		// 04/27/2006 Paul.  This function should be virtual so that it could be 
		// over-ridden by LeadDetailButtons, or ProspectDetailButtons.
		public virtual void SetUserAccess(string sMODULE_NAME, Guid gASSIGNED_USER_ID)
		{
			// 05/22/2006 Paul.  Disable button if NOT Owner.
			int nACLACCESS_Delete = Security.GetUserAccess(sMODULE_NAME, "delete");
			if ( nACLACCESS_Delete == ACL_ACCESS.NONE || (nACLACCESS_Delete == ACL_ACCESS.OWNER && Security.USER_ID != gASSIGNED_USER_ID) )
			{
				btnDelete.Visible = false;
			}
			
			// 05/22/2006 Paul.  Disable button if NOT Owner.
			int nACLACCESS_Edit = Security.GetUserAccess(sMODULE_NAME, "edit");
			if ( nACLACCESS_Edit == ACL_ACCESS.NONE || (nACLACCESS_Edit == ACL_ACCESS.OWNER && Security.USER_ID != gASSIGNED_USER_ID) )
			{
				btnEdit.Visible      = false;
				btnDuplicate.Visible = false;
			}
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			if ( Command != null )
				Command(this, e);
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
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
		}
		#endregion
	}
}

