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

namespace SplendidCRM.Administration.EmailMan
{
	/// <summary>
	///		Summary description for SearchBasic.
	/// </summary>
	public class SearchBasic : SearchControl
	{
		protected _controls.SearchButtons ctlSearchButtons;

		protected TextBox      txtCAMPAIGN_NAME  ;
		protected TextBox      txtRECIPIENT_NAME ;
		protected TextBox      txtRECIPIENT_EMAIL;

		public override void ClearForm()
		{
			txtCAMPAIGN_NAME  .Text = String.Empty;
			txtRECIPIENT_NAME .Text = String.Empty;
			txtRECIPIENT_EMAIL.Text = String.Empty;
		}

		public override void SqlSearchClause(IDbCommand cmd)
		{
			Sql.AppendParameter(cmd, txtCAMPAIGN_NAME  .Text,  50, Sql.SqlFilterMode.StartsWith, "CAMPAIGN_NAME"  );
			Sql.AppendParameter(cmd, txtRECIPIENT_NAME .Text, 100, Sql.SqlFilterMode.StartsWith, "RECIPIENT_NAME" );
			Sql.AppendParameter(cmd, txtRECIPIENT_EMAIL.Text, 100, Sql.SqlFilterMode.StartsWith, "RECIPIENT_EMAIL");
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
			ctlSearchButtons.Command += new CommandEventHandler(Page_Command);
		}
		#endregion
	}
}

