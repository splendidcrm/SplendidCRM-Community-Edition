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
using System.Web;
using System.Web.UI.WebControls;
using System.Diagnostics;

namespace SplendidCRM.Meetings
{
	/// <summary>
	///		Summary description for SearchInvitees.
	/// </summary>
	public class SearchInvitees : SearchControl
	{
		protected TextBox  txtFIRST_NAME       ;
		protected TextBox  txtLAST_NAME        ;
		protected TextBox  txtEMAIL            ;

		public override void ClearForm()
		{
			txtFIRST_NAME       .Text    = String.Empty;
			txtLAST_NAME        .Text    = String.Empty;
			txtEMAIL            .Text    = String.Empty;
		}

		public override void SqlSearchClause(IDbCommand cmd)
		{
			Sql.AppendParameter(cmd, txtFIRST_NAME  .Text,  25, Sql.SqlFilterMode.StartsWith, "FIRST_NAME"  );
			Sql.AppendParameter(cmd, txtLAST_NAME   .Text,  25, Sql.SqlFilterMode.StartsWith, "LAST_NAME"   );
			// 04/08/2008 Paul.  EMAIL1 and EMAIL2 are not available.  Just EMAIL. 
			// 04/01/2012 Paul.  The query has been updated to use EMAIL1. 
			Sql.AppendParameter(cmd, txtEMAIL       .Text, 100, Sql.SqlFilterMode.StartsWith, "EMAIL1"      );
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// Put user code to initialize the page here
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

