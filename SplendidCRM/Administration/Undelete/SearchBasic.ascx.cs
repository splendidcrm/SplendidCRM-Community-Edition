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

namespace SplendidCRM.Administration.Undelete
{
	/// <summary>
	///		Summary description for SearchBasic.
	/// </summary>
	public class SearchBasic : SearchControl
	{
		protected TextBox              txtNAME       ;
		protected TextBox              txtAUDIT_TOKEN;
		protected DropDownList         lstMODULE_NAME;
		protected DropDownList         lstUSERS      ;
		protected _controls.DatePicker ctlSTART_DATE ;
		protected _controls.DatePicker ctlEND_DATE   ;
		protected Button               btnSearch     ;
		protected Button               btnClear      ;
		protected Button               btnUndelete   ;
		protected CheckBox             chkBackground ;
		
		public string MODULE_NAME
		{
			get { return lstMODULE_NAME.SelectedValue; }
		}

		public bool BackgroundOperation
		{
			get { return chkBackground.Checked; }
		}

		protected void lstMODULE_NAME_Changed(object sender, System.EventArgs e)
		{
			lstMODULE_NAME.Focus();
			if ( Command != null )
				Command(this, new CommandEventArgs("Search", null)) ;
		}

		protected void lstUSERS_Changed(object sender, System.EventArgs e)
		{
			if ( Command != null )
				Command(this, new CommandEventArgs("Search", null)) ;
		}

		public override void ClearForm()
		{
			txtNAME       .Text     = String.Empty;
			txtAUDIT_TOKEN.Text     = String.Empty;
			ctlSTART_DATE .DateText = String.Empty;
			ctlEND_DATE   .DateText = String.Empty;
			lstUSERS.SelectedIndex  = 0;
		}

		public override void SqlSearchClause(IDbCommand cmd)
		{
			Sql.AppendParameter(cmd, txtNAME.Text          , 200, Sql.SqlFilterMode.StartsWith, "NAME"            );
			Sql.AppendParameter(cmd, txtAUDIT_TOKEN.Text   , 200, Sql.SqlFilterMode.Exact     , "AUDIT_TOKEN"     );
			Sql.AppendParameter(cmd, lstUSERS                                                 , "MODIFIED_USER_ID");
			DateTime dtDateStart = DateTime.MinValue;
			DateTime dtDateEnd   = DateTime.MinValue;
			if ( !Sql.IsEmptyString(ctlSTART_DATE.DateText) )
			{
				dtDateStart = ctlSTART_DATE.Value;
			}
			if ( !Sql.IsEmptyString(ctlEND_DATE.DateText) )
			{
				dtDateEnd = ctlEND_DATE.Value;
			}
			if ( dtDateStart != DateTime.MinValue ||dtDateEnd != DateTime.MinValue )
				Sql.AppendParameter(cmd, dtDateStart, dtDateEnd, "AUDIT_DATE");
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( !IsPostBack )
			{
				lstMODULE_NAME.DataSource = SplendidCache.AuditedModules();
				lstMODULE_NAME.DataBind();
				lstMODULE_NAME.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));

				lstUSERS.DataSource = SplendidCache.ActiveUsers();
				lstUSERS.DataBind();
				lstUSERS.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
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
		}
		#endregion
	}
}
