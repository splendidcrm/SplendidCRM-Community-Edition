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

namespace SplendidCRM.Administration.Terminology
{
	/// <summary>
	///		Summary description for SearchBasic.
	/// </summary>
	public class SearchBasic : SearchControl
	{
		protected _controls.SearchButtons ctlSearchButtons;

		protected TextBox      txtNAME            ;
		protected TextBox      txtDISPLAY_NAME    ;
		protected DropDownList lstLANGUAGE        ;
		protected DropDownList lstMODULE_NAME     ;
		protected DropDownList lstLIST_NAME       ;
		protected CheckBox     chkGLOBAL_TERMS    ;
		protected CheckBox     chkINCLUDE_LISTS   ;

		public bool GLOBAL_TERMS
		{
			get { return chkGLOBAL_TERMS.Checked; }
			set { chkGLOBAL_TERMS.Checked = value; }
		}

		public bool INCLUDE_LISTS
		{
			get { return chkINCLUDE_LISTS.Checked; }
			set { chkINCLUDE_LISTS.Checked = value; }
		}

		/*
		public string LANGUAGE
		{
			get
			{
				return lstLANGUAGE.SelectedValue;
			}
			set
			{
				if ( lstLANGUAGE.DataSource == null )
				{
					lstLANGUAGE.DataSource = SplendidCache.Languages();
					lstLANGUAGE.DataBind();
					lstLANGUAGE.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
				}
				Utils.SetValue(lstLANGUAGE, L10N.NormalizeCulture(value));
			}
		}
		*/

		public override void ClearForm()
		{
			txtNAME        .Text = String.Empty;
			txtDISPLAY_NAME.Text = String.Empty;
			lstLANGUAGE    .SelectedIndex = 0;
			lstMODULE_NAME .SelectedIndex = 0;
			lstLIST_NAME   .SelectedIndex = 0;
		}

		public override void SqlSearchClause(IDbCommand cmd)
		{
			Sql.AppendParameter(cmd, txtNAME        .Text         ,   50, Sql.SqlFilterMode.StartsWith, "NAME"        );
			Sql.AppendParameter(cmd, txtDISPLAY_NAME.Text         , 2000, Sql.SqlFilterMode.StartsWith, "DISPLAY_NAME");
			Sql.AppendParameter(cmd, lstLANGUAGE    .SelectedValue,   10, Sql.SqlFilterMode.Exact     , "LANG"        );
			// 12/14/2009 Paul.  Increase size of module name to prevent truncation. 
			Sql.AppendParameter(cmd, lstMODULE_NAME .SelectedValue,   25, Sql.SqlFilterMode.Exact     , "MODULE_NAME" );
			Sql.AppendParameter(cmd, lstLIST_NAME   .SelectedValue,   50, Sql.SqlFilterMode.Exact     , "LIST_NAME"   );
		}

		protected void chkGLOBAL_TERMS_CheckedChanged(Object sender, EventArgs e)
		{
			if ( Command != null )
				Command(this, new CommandEventArgs("Search", String.Empty)) ;
		}
		
		protected void chkINCLUDE_LISTS_CheckedChanged(Object sender, EventArgs e)
		{
			if ( Command != null )
				Command(this, new CommandEventArgs("Search", String.Empty)) ;
		}
		
		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( !IsPostBack )
			{
				lstLANGUAGE.DataSource = SplendidCache.Languages();
				lstLANGUAGE.DataBind();
				lstLANGUAGE.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
				Utils.SetValue(lstLANGUAGE, L10N.NormalizeCulture(L10n.NAME));

				lstMODULE_NAME.DataSource = SplendidCache.Modules();
				lstMODULE_NAME.DataBind();
				lstMODULE_NAME.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));

				lstLIST_NAME  .DataSource = SplendidCache.TerminologyPickLists();
				lstLIST_NAME  .DataBind();
				lstLIST_NAME  .Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
			}
			if ( !chkINCLUDE_LISTS.Checked )
				lstLIST_NAME.SelectedIndex = 0;
			lstLIST_NAME.Enabled = chkINCLUDE_LISTS.Checked;
			if ( chkGLOBAL_TERMS.Checked )
				lstMODULE_NAME.SelectedIndex = 0;
			lstMODULE_NAME.Enabled = !chkGLOBAL_TERMS.Checked;
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

