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
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for SubPanelButtons.
	/// </summary>
	public class SubPanelButtons : SplendidControl
	{
		protected SplendidCRM.Themes.Sugar.SubPanelButtons ctlSubPanelButtons;
		protected Panel     pnlSubPanelButtons;

		#region ListHeader
		protected string    sModule   = String.Empty;
		protected string    sTitle    = String.Empty;
		protected string    sSubPanel = String.Empty;

		public string Module
		{
			get
			{
				if ( ctlSubPanelButtons != null )
					return ctlSubPanelButtons.Module;
				else
					return sModule;
			}
			set
			{
				sModule = value;
				if ( ctlSubPanelButtons != null )
					ctlSubPanelButtons.Module = value;
			}
		}

		public string Title
		{
			get
			{
				if ( ctlSubPanelButtons != null )
					return ctlSubPanelButtons.Title;
				else
					return sTitle;
			}
			set
			{
				sTitle = value;
				if ( ctlSubPanelButtons != null )
					ctlSubPanelButtons.Title = value;
			}
		}

		public string SubPanel
		{
			get
			{
				if ( ctlSubPanelButtons != null )
					return ctlSubPanelButtons.SubPanel;
				else
					return sSubPanel;
			}
			set
			{
				sSubPanel = value;
				if ( ctlSubPanelButtons != null )
					ctlSubPanelButtons.SubPanel = value;
			}
		}
		#endregion

		#region DynamicButtons
		protected CommandEventHandler ehCommand         = null;
		protected HorizontalAlign     hzHorizontalAlign = HorizontalAlign.Left;
		protected bool                bShowRequired     = false;
		// 10/05/2015 Paul.  We need to default to true when it comes to the errors, otherwise an error will not get displayed. 
		protected bool                bShowError        = true;
		protected string              sErrorText        = String.Empty;
		protected string              sErrorClass       = "error";

		public CommandEventHandler Command
		{
			get
			{
				if ( ctlSubPanelButtons != null )
					return ctlSubPanelButtons.Command;
				else
					return ehCommand;
			}
			set
			{
				ehCommand = value;
				if ( ctlSubPanelButtons != null )
					ctlSubPanelButtons.Command = value;
			}
		}
		
		public HorizontalAlign HorizontalAlign
		{
			get
			{
				if ( ctlSubPanelButtons != null )
					return ctlSubPanelButtons.HorizontalAlign;
				else
					return hzHorizontalAlign;
			}
			set
			{
				hzHorizontalAlign = value;
				if ( ctlSubPanelButtons != null )
					ctlSubPanelButtons.HorizontalAlign = value;
			}
		}

		public bool ShowRequired
		{
			get
			{
				if ( ctlSubPanelButtons != null )
					return ctlSubPanelButtons.ShowRequired;
				else
					return bShowRequired;
			}
			set
			{
				bShowRequired = value;
				if ( ctlSubPanelButtons != null )
					ctlSubPanelButtons.ShowRequired = value;
			}
		}

		public bool ShowError
		{
			get
			{
				if ( ctlSubPanelButtons != null )
					return ctlSubPanelButtons.ShowError;
				else
					return bShowError;
			}
			set
			{
				bShowError = value;
				if ( ctlSubPanelButtons != null )
					ctlSubPanelButtons.ShowError = value;
			}
		}

		public string ErrorText
		{
			get
			{
				if ( ctlSubPanelButtons != null )
					return ctlSubPanelButtons.ErrorText;
				else
					return sErrorText;
			}
			set
			{
				sErrorText = value;
				if ( ctlSubPanelButtons != null )
					ctlSubPanelButtons.ErrorText = value;
			}
		}

		public string ErrorClass
		{
			get
			{
				if ( ctlSubPanelButtons != null )
					return ctlSubPanelButtons.ErrorClass;
				else
					return sErrorClass;
			}
			set
			{
				sErrorClass = value;
				if ( ctlSubPanelButtons != null )
					ctlSubPanelButtons.ErrorClass = value;
			}
		}

		public void DisableAll()
		{
			if ( ctlSubPanelButtons != null )
				ctlSubPanelButtons.DisableAll();
		}

		public void HideAll()
		{
			if ( ctlSubPanelButtons != null )
				ctlSubPanelButtons.HideAll();
		}

		public void ShowAll()
		{
			if ( ctlSubPanelButtons != null )
				ctlSubPanelButtons.ShowAll();
		}

		public void ShowButton(string sCommandName, bool bVisible)
		{
			if ( ctlSubPanelButtons != null )
				ctlSubPanelButtons.ShowButton(sCommandName, bVisible);
		}

		public void ShowHyperLink(string sURL, bool bVisible)
		{
			if ( ctlSubPanelButtons != null )
				ctlSubPanelButtons.ShowHyperLink(sURL, bVisible);
		}

		public void EnableButton(string sCommandName, bool bEnabled)
		{
			if ( ctlSubPanelButtons != null )
				ctlSubPanelButtons.EnableButton(sCommandName, bEnabled);
		}

		public void SetButtonText(string sCommandName, string sText)
		{
			if ( ctlSubPanelButtons != null )
				ctlSubPanelButtons.SetButtonText(sCommandName, sText);
		}

		public string ButtonClientID(string sCommandName)
		{
			if ( ctlSubPanelButtons != null )
				return ctlSubPanelButtons.ButtonClientID(sCommandName);
			return String.Empty;
		}

		public Button FindButton(string sCommandName)
		{
			if ( ctlSubPanelButtons != null )
				return ctlSubPanelButtons.FindButton(sCommandName);
			return null;
		}

		public void AppendButtons(string sVIEW_NAME, Guid gASSIGNED_USER_ID, DataRow rdr)
		{
			if ( ctlSubPanelButtons != null )
				ctlSubPanelButtons.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, rdr);
		}

		public void AppendButtons(string sVIEW_NAME, Guid gASSIGNED_USER_ID, Guid gID)
		{
			if ( ctlSubPanelButtons != null )
				ctlSubPanelButtons.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, gID);
		}
		#endregion

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
			string sTheme = Page.Theme;
			// 10/16/2015 Paul.  Change default theme to our newest theme. 
			if ( String.IsNullOrEmpty(sTheme) )
				sTheme = SplendidDefaults.Theme();
			string sModuleHeaderPath = "~/App_MasterPages/" + Page.Theme + "/SubPanelButtons.ascx";
			if ( Utils.CachedFileExists(Context, sModuleHeaderPath) )
			{
				ctlSubPanelButtons = LoadControl(sModuleHeaderPath) as SplendidCRM.Themes.Sugar.SubPanelButtons;
				if ( ctlSubPanelButtons != null )
				{
					ctlSubPanelButtons.Module            = sModule           ;
					ctlSubPanelButtons.Title             = sTitle            ;
					ctlSubPanelButtons.SubPanel          = sSubPanel         ;

					ctlSubPanelButtons.Command          += ehCommand         ;
					ctlSubPanelButtons.HorizontalAlign   = hzHorizontalAlign ;
					ctlSubPanelButtons.ShowRequired      = bShowRequired     ;
					ctlSubPanelButtons.ShowError         = bShowError        ;
					ctlSubPanelButtons.ErrorText         = sErrorText        ;
					ctlSubPanelButtons.ErrorClass        = sErrorClass       ;
					pnlSubPanelButtons.Controls.Add(ctlSubPanelButtons);
				}
			}
		}
		#endregion
	}
}

