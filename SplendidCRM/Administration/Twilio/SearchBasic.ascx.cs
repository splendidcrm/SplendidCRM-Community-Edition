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

namespace SplendidCRM.Administration.Twilio
{
	/// <summary>
	///		Summary description for SearchBasic.
	/// </summary>
	public class SearchBasic : SearchControl
	{
		protected _controls.SearchButtons ctlSearchButtons;

		protected _controls.DatePicker ctlDATE_SENT         ;
		protected TextBox              txtFROM_NUMBER       ;
		protected TextBox              txtTO_NUMBER         ;

		public DateTime DATE_SENT
		{
			get { return ctlDATE_SENT.Value; }
			set { ctlDATE_SENT.Value = value; }
		}

		public string FROM_NUMBER
		{
			get
			{
				return txtFROM_NUMBER.Text;
			}
			set
			{
				txtFROM_NUMBER.Text = value;
			}
		}

		public string TO_NUMBER
		{
			get
			{
				return txtTO_NUMBER.Text;
			}
			set
			{
				txtTO_NUMBER.Text = value;
			}
		}

		public override void ClearForm()
		{
			ctlDATE_SENT  .DateText = String.Empty;
			txtFROM_NUMBER.Text     = String.Empty;
			txtTO_NUMBER  .Text     = String.Empty;
		}

		public override void SqlSearchClause(IDbCommand cmd)
		{
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
