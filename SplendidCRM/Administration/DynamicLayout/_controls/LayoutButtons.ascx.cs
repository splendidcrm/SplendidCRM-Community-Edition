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

namespace SplendidCRM.Administration.DynamicLayout._controls
{
	/// <summary>
	///		Summary description for LayoutButtons.
	/// </summary>
	public class LayoutButtons : SplendidCRM._controls.EditButtons
	{
		protected Button   btnNew       ;
		protected Button   btnDefaults  ;
		protected Button   btnExport    ;
		protected TextBox  txtCopyLayout;
		protected CheckBox chkPreview   ;
		protected HiddenField hidPreviousPreview;
		protected string   sVIEW_NAME   ;

		// 05/22/2009 Paul.  We need to pass the view name to the Export popup. 
		public string VIEW_NAME
		{
			get { return sVIEW_NAME; }
			set { sVIEW_NAME = value; }
		}

		public bool Preview(bool bInitialize)
		{
			// 04/11/2011 Paul.  We cannot use the chkPreview.checked field because we are calling Preview too early. 
			// We need to get the flag directly from the Request. 
			// 04/11/2011 Paul.  We need to save the previous value so that the the binding can happen properly in the InitializeComponent. 
			if ( bInitialize )
				return Sql.ToBoolean(Request[hidPreviousPreview.UniqueID]);
			else
				return Sql.ToBoolean(Request[chkPreview.UniqueID]);
		}

		public void ShowExport(bool bValue)
		{
			btnExport.Visible = bValue;
		}

		public void ShowDefaults(bool bValue)
		{
			btnDefaults.Visible = bValue;
		}

		// 02/14/2013 Paul.  Provide access to the CopyLayout textbox. 
		public TextBox CopyLayout
		{
			get { return txtCopyLayout; }
		}

		// 04/11/2011 Paul.  Allow the layout mode to be turned off to preview the result. 
		protected void chkPreview_CheckedChanged(object sender, EventArgs e)
		{
			if ( Command != null )
			{
				CommandEventArgs ePreview = new CommandEventArgs("PreviewChanged", null);
				Command(sender, ePreview);
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			hidPreviousPreview.Value = chkPreview.Checked.ToString();
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

