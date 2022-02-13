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
using System.Data;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for DynamicButtons.
	/// </summary>
	public class DynamicButtons : SplendidControl
	{
		protected Panel     pnlDynamicButtons;
		protected Label     lblError         ;
		protected TableCell tdButtons        ;
		protected TableCell tdError          ;
		protected TableCell tdRequired       ;

		public CommandEventHandler Command;

		public HorizontalAlign HorizontalAlign
		{
			get { return tdButtons.HorizontalAlign; }
			set { tdButtons.HorizontalAlign = value; }
		}

		public void DisableAll()
		{
			foreach ( Control ctl in pnlDynamicButtons.Controls )
			{
				if ( ctl is Button )
					(ctl as Button).Enabled = false;
				else if ( ctl is HyperLink )
					(ctl as HyperLink).Enabled = false;
			}
		}

		public void HideAll()
		{
			foreach ( Control ctl in pnlDynamicButtons.Controls )
			{
				if ( ctl is Button )
					(ctl as Button).Visible = false;
				else if ( ctl is HyperLink )
					(ctl as HyperLink).Visible = false;
			}
		}

		// 02/21/2010 Paul.  Create Inline needs to be able to show all buttons. 
		public void ShowAll()
		{
			foreach ( Control ctl in pnlDynamicButtons.Controls )
			{
				if ( ctl is Button )
					(ctl as Button).Visible = true;
				else if ( ctl is HyperLink )
					(ctl as HyperLink).Visible = true;
			}
		}

		public void ShowButton(string sCommandName, bool bVisible)
		{
			foreach ( Control ctl in pnlDynamicButtons.Controls )
			{
				if ( ctl is Button )
				{
					Button btn = ctl as Button;
					if ( btn.CommandName == sCommandName )
						btn.Visible = bVisible;
				}
			}
		}

		// 03/01/2015 Paul.  Provide a way to disable HyperLinks. 
		public void ShowHyperLink(string sURL, bool bVisible)
		{
			foreach ( Control ctl in pnlDynamicButtons.Controls )
			{
				if ( ctl is HyperLink )
				{
					HyperLink lnk = ctl as HyperLink;
					if ( lnk.NavigateUrl == sURL )
						lnk.Visible = bVisible;
				}
			}
		}

		// 03/24/2016 Paul.  We want to be able to change an order pdf per language. 
		public void ReplaceHyperLinkString(string sOldValue, string sNewValue)
		{
			foreach ( Control ctl in pnlDynamicButtons.Controls )
			{
				if ( ctl is HyperLink )
				{
					HyperLink lnk = ctl as HyperLink;
					lnk.NavigateUrl = lnk.NavigateUrl.Replace(sOldValue, sNewValue);
				}
			}
		}

		public void EnableButton(string sCommandName, bool bEnabled)
		{
			foreach ( Control ctl in pnlDynamicButtons.Controls )
			{
				if ( ctl is Button )
				{
					Button btn = ctl as Button;
					if ( btn.CommandName == sCommandName )
						btn.Enabled = bEnabled;
				}
			}
		}

		// 03/11/2014 Paul.  Provide business rule access to the text. 
		public void SetButtonText(string sCommandName, string sText)
		{
			foreach ( Control ctl in pnlDynamicButtons.Controls )
			{
				if ( ctl is Button )
				{
					Button btn = ctl as Button;
					if ( btn.CommandName == sCommandName )
						btn.Text = sText;
				}
			}
		}

		public string ButtonClientID(string sCommandName)
		{
			foreach ( Control ctl in pnlDynamicButtons.Controls )
			{
				if ( ctl is Button )
				{
					Button btn = ctl as Button;
					if ( btn.CommandName == sCommandName )
						return btn.ClientID;
				}
			}
			return String.Empty;
		}

		// 07/15/2010 Paul.  We ned a quick way to find a button. 
		public Button FindButton(string sCommandName)
		{
			foreach ( Control ctl in pnlDynamicButtons.Controls )
			{
				if ( ctl is Button )
				{
					Button btn = ctl as Button;
					if ( btn.CommandName == sCommandName )
						return btn;
				}
			}
			return null;
		}

		public bool ShowRequired
		{
			get
			{
				return tdRequired.Visible;
			}
			set
			{
				tdRequired.Visible = value;
			}
		}

		public bool ShowError
		{
			get
			{
				return lblError.Visible;
			}
			set
			{
				tdError.Visible = value;
				lblError.Visible = value;
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

		// 10/29/2013 Paul.  Provide a way to change the class name of the text. 
		public string ErrorClass
		{
			get
			{
				return lblError.CssClass;
			}
			set
			{
				lblError.CssClass = value;
			}
		}

		public void AppendButtons(string sVIEW_NAME, Guid gASSIGNED_USER_ID, DataRow rdr)
		{
			SplendidDynamic.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, pnlDynamicButtons, this.IsMobile, rdr, this.GetL10n(), new CommandEventHandler(Page_Command));
		}

		public void AppendButtons(string sVIEW_NAME, Guid gASSIGNED_USER_ID, Guid gID)
		{
			// 04/29/2008 Paul.  Don't create a reader if the ID is null. 
			// 04/28/2009 Paul.  Always create the reader and read the first row.. 
			using ( DataTable dt = new DataTable() )
			{
				dt.Columns.Add("ID", typeof(Guid));
				DataRow row = dt.NewRow();
				dt.Rows.Add(row);
				row["ID"] = gID;

				// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
				//using ( DataTableReader rdr = dt.CreateDataReader() )
				{
					// 04/28/2009 Paul.  Make sure to read the first row, otherwise an exception will be thrown when the reader is accessed. 
					//rdr.Read();
					SplendidDynamic.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, pnlDynamicButtons, this.IsMobile, row, this.GetL10n(), new CommandEventHandler(Page_Command));
				}
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

