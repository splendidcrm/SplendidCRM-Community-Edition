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
	///		Summary description for SubPanelButtons.
	/// </summary>
	public class SubPanelButtons : SplendidCRM.Themes.Sugar.SubPanelButtons
	{
		// 09/25/2016 Paul.  Move tblSubPanelFrame to base class. 
		protected Panel       phButtonHover;
		protected AjaxControlToolkit.HoverMenuExtender hexHoverMenuExtender;

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
			if ( phButtonHover != null && Sql.IsEmptyString(ClientID) )
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
				int nButtonCount = SplendidDynamic.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, this.pnlDynamicButtons, this.phButtonHover, "ListHeader", this.IsMobile, rdr, this.GetL10n(), new CommandEventHandler(Page_Command));
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

					int nButtonCount = SplendidDynamic.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, this.pnlDynamicButtons, this.phButtonHover, "ListHeader", this.IsMobile, row, this.GetL10n(), new CommandEventHandler(Page_Command));
					hexHoverMenuExtender.Enabled = (nButtonCount > 1);
				}
			}
		}

		protected override void Page_Command(object sender, CommandEventArgs e)
		{
			// 05/27/2015 Paul.  When a create operation is initiated, we need to make sure that the show panel cookie is cleared. 
			if ( e.CommandName.EndsWith(".Create") )
			{
				tblSubPanelFrame.CssClass = "h3Row";
				lnkShowSubPanel.Attributes.Remove("style");
				lnkHideSubPanel.Attributes.Remove("style");
				lnkShowSubPanel.Attributes.Add("style", "display:none"  );
				lnkHideSubPanel.Attributes.Add("style", "display:inline");
	
				HttpCookie cShowPanel = new HttpCookie(SubPanel, "0");
				cShowPanel.Expires = new DateTime(1980, 1, 1, 0, 0, 0, 0);
				cShowPanel.Path    = "/";
				Response.Cookies.Add(cShowPanel);
			}
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

