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

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for ParentPopupScripts.
	/// </summary>
	public class ParentPopupScripts : SplendidControl
	{
		// 08/23/2006 Paul.  Specify default values for the fields. 
		protected string sListField   = "PARENT_TYPE";
		protected string sNameField   = "PARENT_NAME";
		protected string sHiddenField = "PARENT_ID"  ;

		public string ListField
		{
			get { return sListField; }
			set { sListField = value; }
		}

		public string NameField
		{
			get { return sNameField; }
			set { sNameField = value; }
		}

		public string HiddenField
		{
			get { return sHiddenField; }
			set { sHiddenField = value; }
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// ListField="lstPARENT_TYPE" NameField="txtPARENT_NAME" HiddenField="txtPARENT_ID" 
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

