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
	///		Summary description for MassUpdateButtons.
	/// </summary>
	public class MassUpdateButtons : SplendidControl
	{
		protected SplendidCRM.Themes.Sugar.MassUpdateButtons ctlMassUpdateButtons;
		protected Panel     pnlMassUpdateButtons;

		#region ListHeader
		protected string    sModule   = String.Empty;
		protected string    sTitle    = String.Empty;
		protected string    sSubPanel = String.Empty;

		public string Module
		{
			get
			{
				if ( ctlMassUpdateButtons != null )
					return ctlMassUpdateButtons.Module;
				else
					return sModule;
			}
			set
			{
				sModule = value;
				if ( ctlMassUpdateButtons != null )
					ctlMassUpdateButtons.Module = value;
			}
		}

		public string Title
		{
			get
			{
				if ( ctlMassUpdateButtons != null )
					return ctlMassUpdateButtons.Title;
				else
					return sTitle;
			}
			set
			{
				sTitle = value;
				if ( ctlMassUpdateButtons != null )
					ctlMassUpdateButtons.Title = value;
			}
		}

		public string SubPanel
		{
			get
			{
				if ( ctlMassUpdateButtons != null )
					return ctlMassUpdateButtons.SubPanel;
				else
					return sSubPanel;
			}
			set
			{
				sSubPanel = value;
				if ( ctlMassUpdateButtons != null )
					ctlMassUpdateButtons.SubPanel = value;
			}
		}
		#endregion

		#region DynamicButtons
		protected CommandEventHandler ehCommand         = null;
		protected HorizontalAlign     hzHorizontalAlign = HorizontalAlign.Left;
		protected bool                bShowRequired     = false;
		protected bool                bShowError        = false;
		protected string              sErrorText        = String.Empty;
		protected string              sErrorClass       = String.Empty;

		public CommandEventHandler Command
		{
			get
			{
				if ( ctlMassUpdateButtons != null )
					return ctlMassUpdateButtons.Command;
				else
					return ehCommand;
			}
			set
			{
				ehCommand = value;
				if ( ctlMassUpdateButtons != null )
					ctlMassUpdateButtons.Command = value;
			}
		}
		
		public HorizontalAlign HorizontalAlign
		{
			get
			{
				if ( ctlMassUpdateButtons != null )
					return ctlMassUpdateButtons.HorizontalAlign;
				else
					return hzHorizontalAlign;
			}
			set
			{
				hzHorizontalAlign = value;
				if ( ctlMassUpdateButtons != null )
					ctlMassUpdateButtons.HorizontalAlign = value;
			}
		}

		public bool ShowRequired
		{
			get
			{
				if ( ctlMassUpdateButtons != null )
					return ctlMassUpdateButtons.ShowRequired;
				else
					return bShowRequired;
			}
			set
			{
				bShowRequired = value;
				if ( ctlMassUpdateButtons != null )
					ctlMassUpdateButtons.ShowRequired = value;
			}
		}

		public bool ShowError
		{
			get
			{
				if ( ctlMassUpdateButtons != null )
					return ctlMassUpdateButtons.ShowError;
				else
					return bShowError;
			}
			set
			{
				bShowError = value;
				if ( ctlMassUpdateButtons != null )
					ctlMassUpdateButtons.ShowError = value;
			}
		}

		public string ErrorText
		{
			get
			{
				if ( ctlMassUpdateButtons != null )
					return ctlMassUpdateButtons.ErrorText;
				else
					return sErrorText;
			}
			set
			{
				sErrorText = value;
				if ( ctlMassUpdateButtons != null )
					ctlMassUpdateButtons.ErrorText = value;
			}
		}

		public string ErrorClass
		{
			get
			{
				if ( ctlMassUpdateButtons != null )
					return ctlMassUpdateButtons.ErrorClass;
				else
					return sErrorClass;
			}
			set
			{
				sErrorClass = value;
				if ( ctlMassUpdateButtons != null )
					ctlMassUpdateButtons.ErrorClass = value;
			}
		}

		public void DisableAll()
		{
			if ( ctlMassUpdateButtons != null )
				ctlMassUpdateButtons.DisableAll();
		}

		public void HideAll()
		{
			if ( ctlMassUpdateButtons != null )
				ctlMassUpdateButtons.HideAll();
		}

		public void ShowAll()
		{
			if ( ctlMassUpdateButtons != null )
				ctlMassUpdateButtons.ShowAll();
		}

		public void ShowButton(string sCommandName, bool bVisible)
		{
			if ( ctlMassUpdateButtons != null )
				ctlMassUpdateButtons.ShowButton(sCommandName, bVisible);
		}

		public void ShowHyperLink(string sURL, bool bVisible)
		{
			if ( ctlMassUpdateButtons != null )
				ctlMassUpdateButtons.ShowHyperLink(sURL, bVisible);
		}

		public void EnableButton(string sCommandName, bool bEnabled)
		{
			if ( ctlMassUpdateButtons != null )
				ctlMassUpdateButtons.EnableButton(sCommandName, bEnabled);
		}

		public void SetButtonText(string sCommandName, string sText)
		{
			if ( ctlMassUpdateButtons != null )
				ctlMassUpdateButtons.SetButtonText(sCommandName, sText);
		}

		public string ButtonClientID(string sCommandName)
		{
			if ( ctlMassUpdateButtons != null )
				return ctlMassUpdateButtons.ButtonClientID(sCommandName);
			return String.Empty;
		}

		public Button FindButton(string sCommandName)
		{
			if ( ctlMassUpdateButtons != null )
				return ctlMassUpdateButtons.FindButton(sCommandName);
			return null;
		}

		public void AppendButtons(string sVIEW_NAME, Guid gASSIGNED_USER_ID, DataRow rdr)
		{
			if ( ctlMassUpdateButtons != null )
				ctlMassUpdateButtons.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, rdr);
		}

		public void AppendButtons(string sVIEW_NAME, Guid gASSIGNED_USER_ID, Guid gID)
		{
			if ( ctlMassUpdateButtons != null )
				ctlMassUpdateButtons.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, gID);
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
			string sModuleHeaderPath = "~/App_MasterPages/" + Page.Theme + "/MassUpdateButtons.ascx";
			if ( Utils.CachedFileExists(Context, sModuleHeaderPath) )
			{
				ctlMassUpdateButtons = LoadControl(sModuleHeaderPath) as SplendidCRM.Themes.Sugar.MassUpdateButtons;
				if ( ctlMassUpdateButtons != null )
				{
					ctlMassUpdateButtons.Module            = sModule           ;
					ctlMassUpdateButtons.Title             = sTitle            ;
					ctlMassUpdateButtons.SubPanel          = sSubPanel         ;

					ctlMassUpdateButtons.Command          += ehCommand         ;
					ctlMassUpdateButtons.HorizontalAlign   = hzHorizontalAlign ;
					ctlMassUpdateButtons.ShowRequired      = bShowRequired     ;
					ctlMassUpdateButtons.ShowError         = bShowError        ;
					ctlMassUpdateButtons.ErrorText         = sErrorText        ;
					ctlMassUpdateButtons.ErrorClass        = sErrorClass       ;
					pnlMassUpdateButtons.Controls.Add(ctlMassUpdateButtons);
				}
			}
		}
		#endregion
	}
}

