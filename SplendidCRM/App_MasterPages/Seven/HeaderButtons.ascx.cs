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
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Data;

namespace SplendidCRM.Themes.Seven
{
	/// <summary>
	///		Summary description for HeaderButtons.
	/// </summary>
	public class HeaderButtons : SplendidCRM.Themes.Sugar.HeaderButtons
	{
		// 03/27/2016 Paul.  Move phButtonHover to base class to centralize management. 
		//protected Panel       phButtonHover;
		protected AjaxControlToolkit.HoverMenuExtender hexHoverMenuExtender;

		#region ModuleHeader methods
		public override void SetTitle()
		{
			if ( lblTitle != null )
			{
				if ( sTitle == ".moduleList.Home" )
					sTitle = ".moduleList." + sModule;
				
				// 06/30/2018 Paul.  If title is a link, then there will not be a term lookup. 
				if ( sTitle.StartsWith("<a href=\"default.aspx\">") && sTitle.Contains( "</a><span class=\"pointer\">&raquo;</span>") )
					lblTitle.Text = sTitle;
				// 06/30/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
				else if ( sTitle.Contains("<span class=\"Erased\">") )
					lblTitle.Text = HttpUtility.HtmlEncode(sTitle.Replace(Sql.DataPrivacyErasedPill(L10n), String.Empty)) + Sql.DataPrivacyErasedPill(L10n);
				else
					lblTitle.Text = HttpUtility.HtmlEncode(L10n.Term(sTitle));
			}
		}
		#endregion

		#region DynamicButton methods

		public override void DisableAll()
		{
			base.DisableAll();
			if ( phButtonHover != null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is Button )
						(ctl as Button).Enabled = false;
					else if ( ctl is HyperLink )
						(ctl as HyperLink).Enabled = false;
					else if ( ctl is ImageButton )
						(ctl as ImageButton).Enabled = false;
				}
			}
		}

		public override void HideAll()
		{
			base.HideAll();
			if ( phButtonHover != null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is Button )
						(ctl as Button).Visible = false;
					else if ( ctl is HyperLink )
						(ctl as HyperLink).Visible = false;
					else if ( ctl is ImageButton )
						(ctl as ImageButton).Visible = false;
				}
			}
		}

		public override void ShowAll()
		{
			base.ShowAll();
			if ( phButtonHover != null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is Button )
						(ctl as Button).Visible = true;
					else if ( ctl is HyperLink )
						(ctl as HyperLink).Visible = true;
					else if ( ctl is ImageButton )
						(ctl as ImageButton).Visible = true;
				}
			}
		}

		public override void ShowButton(string sCommandName, bool bVisible)
		{
			base.ShowButton(sCommandName, bVisible);
			if ( phButtonHover != null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is Button )
					{
						Button btn = ctl as Button;
						if ( btn.CommandName == sCommandName )
							btn.Visible = bVisible;
					}
					else if ( ctl is ImageButton )
					{
						ImageButton btn = ctl as ImageButton;
						if ( btn.CommandName == sCommandName )
							btn.Visible = bVisible;
					}
				}
			}
		}

		// 10/31/2017 Paul.  Provide a way to inject Record level ACL. 
		public override bool IsButtonVisible(string sCommandName)
		{
			bool bVisible = false;
			bVisible = base.IsButtonVisible(sCommandName);
			if ( phButtonHover != null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is Button )
					{
						Button btn = ctl as Button;
						if ( btn.CommandName == sCommandName )
						{
							bVisible = btn.Visible;
							break;
						}
					}
					else if ( ctl is ImageButton )
					{
						ImageButton btn = ctl as ImageButton;
						if ( btn.CommandName == sCommandName )
						{
							bVisible = btn.Visible;
							break;
						}
					}
				}
			}
			return bVisible;
		}

		public override void ShowHyperLink(string sURL, bool bVisible)
		{
			base.ShowHyperLink(sURL, bVisible);
			if ( phButtonHover != null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is HyperLink )
					{
						HyperLink lnk = ctl as HyperLink;
						if ( lnk.NavigateUrl == sURL )
							lnk.Visible = bVisible;
					}
				}
			}
		}

		public override void EnableButton(string sCommandName, bool bEnabled)
		{
			base.EnableButton(sCommandName, bEnabled);
			if ( phButtonHover != null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is Button )
					{
						Button btn = ctl as Button;
						if ( btn.CommandName == sCommandName )
							btn.Enabled = bEnabled;
					}
					else if ( ctl is ImageButton )
					{
						ImageButton btn = ctl as ImageButton;
						if ( btn.CommandName == sCommandName )
							btn.Enabled = bEnabled;
					}
				}
			}
		}

		public override void SetButtonText(string sCommandName, string sText)
		{
			base.SetButtonText(sCommandName, sText);
			if ( phButtonHover != null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is Button )
					{
						Button btn = ctl as Button;
						if ( btn.CommandName == sCommandName )
							btn.Text = sText;
					}
				}
			}
		}

		public override string ButtonClientID(string sCommandName)
		{
			string sClientID = base.ButtonClientID(sCommandName);
			if ( phButtonHover != null && Sql.IsEmptyString(sClientID) )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is Button )
					{
						Button btn = ctl as Button;
						if ( btn.CommandName == sCommandName )
						{
							sClientID = btn.ClientID;
							break;
						}
					}
					else if ( ctl is ImageButton )
					{
						ImageButton btn = ctl as ImageButton;
						if ( btn.CommandName == sCommandName )
						{
							sClientID = btn.ClientID;
							break;
						}
					}
				}
			}
			return sClientID;
		}

		public override Button FindButton(string sCommandName)
		{
			Button btnCommand = base.FindButton(sCommandName);
			if ( phButtonHover != null && btnCommand == null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is Button )
					{
						Button btn = ctl as Button;
						if ( btn.CommandName == sCommandName )
						{
							btnCommand = btn;
							break;
						}
					}
				}
			}
			return btnCommand;
		}
		#endregion

		public override void AppendButtons(string sVIEW_NAME, Guid gASSIGNED_USER_ID, DataRow rdr)
		{
			if ( pnlDynamicButtons != null )
			{
				string sButtonStyle = "ModuleHeader";
				Control phButtonHover = this.phButtonHover;
				if ( this.EditView )
				{
					sButtonStyle  = "EditHeader";
					phButtonHover = this.pnlDynamicButtons;
				}
				int nButtonCount = SplendidDynamic.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, this.pnlDynamicButtons, phButtonHover, sButtonStyle, this.IsMobile, rdr, this.GetL10n(), new CommandEventHandler(Page_Command));
				hexHoverMenuExtender.Enabled = (nButtonCount > 1);
			}
		}

		public override void AppendButtons(string sVIEW_NAME, Guid gASSIGNED_USER_ID, Guid gID)
		{
			if ( pnlDynamicButtons != null )
			{
				using ( DataTable dt = new DataTable() )
				{
					dt.Columns.Add("ID", typeof(Guid));
					DataRow row = dt.NewRow();
					dt.Rows.Add(row);
					row["ID"] = gID;

					string sButtonStyle = "ModuleHeader";
					Control phButtonHover = this.phButtonHover;
					if ( this.EditView )
					{
						sButtonStyle  = "EditHeader";
						phButtonHover = this.pnlDynamicButtons;
					}
					int nButtonCount = SplendidDynamic.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, this.pnlDynamicButtons, this.phButtonHover, sButtonStyle, this.IsMobile, row, this.GetL10n(), new CommandEventHandler(Page_Command));
					hexHoverMenuExtender.Enabled = (nButtonCount > 1);
				}
			}
		}

		public override void AppendButton(string sCommandName, string sCommandArgument, string sText, string sToolTip, string sButtonStyle)
		{
			Button btn = new Button();
			btn.Command         += new CommandEventHandler(Page_Command);
			btn.CommandName      = sCommandName    ;
			btn.CommandArgument  = sCommandArgument;
			btn.CssClass         = (this.pnlDynamicButtons.Controls.Count == 0 ? sButtonStyle + "FirstButton" : sButtonStyle + "OtherButton");
			btn.Text             = "  " + sText + "  ";
			btn.ToolTip          = sToolTip        ;
			this.pnlDynamicButtons.Controls.Add(btn);
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( this.EditView )
				this.hexHoverMenuExtender.Enabled = false;
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

