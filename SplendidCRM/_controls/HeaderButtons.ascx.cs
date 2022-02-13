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
	///		Summary description for HeaderButtons.
	/// </summary>
	public class HeaderButtons : SplendidControl
	{
		protected SplendidCRM.Themes.Sugar.HeaderButtons ctlHeaderButtons;
		protected Panel     pnlHeaderButtons;

		#region ModuleHeader
		// 01/02/2020 Paul.  Provide a way to set the module name. 
		protected string    sModuleTitle       = String.Empty;
		protected string    sModule            = String.Empty;
		protected string    sTitle             = String.Empty;
		protected string    sHelpName          = String.Empty;
		protected string    sTitleText         = String.Empty;
		protected bool      bEnableModuleLabel = true;
		protected bool      bEnablePrint       = false;
		protected bool      bEnableHelp        = false;
		// 03/31/2012 Paul.  Add support for favorites. 
		protected bool      bEnableFavorites   = false;

		// 01/02/2020 Paul.  Provide a way to set the module name. 
		public string ModuleTitle
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.ModuleTitle;
				else
					return sModuleTitle;
			}
			set
			{
				sModuleTitle = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.ModuleTitle = value;
			}
		}

		public string Module
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.Module;
				else
					return sModule;
			}
			set
			{
				sModule = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.Module = value;
			}
		}

		public string Title
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.Title;
				else
					return sTitle;
			}
			set
			{
				sTitle = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.Title = value;
			}
		}

		public string HelpName
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.HelpName;
				else
					return sHelpName;
			}
			set
			{
				sHelpName = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.HelpName = value;
			}
		}

		public string TitleText
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.TitleText;
				else
					return sTitleText;
			}
			set
			{
				sTitleText = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.TitleText = value;
			}
		}

		public bool EnableModuleLabel
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.EnableModuleLabel;
				else
					return bEnableModuleLabel;
			}
			set
			{
				bEnableModuleLabel = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.EnableModuleLabel = value;
			}
		}

		public bool EnablePrint
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.EnablePrint;
				else
					return bEnablePrint;
			}
			set
			{
				bEnablePrint = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.EnablePrint = value;
			}
		}

		public bool EnableHelp
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.EnableHelp;
				else
					return bEnableHelp;
			}
			set
			{
				bEnableHelp = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.EnableHelp = value;
			}
		}

		// 03/31/2012 Paul.  Add support for favorites. 
		public bool EnableFavorites
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.EnableFavorites;
				else
					return bEnableFavorites;
			}
			set
			{
				bEnableFavorites = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.EnableFavorites = value;
			}
		}
		#endregion

		#region DynamicButtons
		protected CommandEventHandler ehCommand         = null;
		protected HorizontalAlign     hzHorizontalAlign = HorizontalAlign.Left;
		protected bool                bEditView         = false;
		protected bool                bShowRequired     = false;
		protected bool                bShowError        = true ;
		protected bool                bShowButtons      = true ;
		protected string              sErrorText        = String.Empty;
		protected string              sErrorClass       = "error";

		public CommandEventHandler Command
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.Command;
				else
					return ehCommand;
			}
			set
			{
				ehCommand = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.Command = value;
			}
		}
		
		public HorizontalAlign HorizontalAlign
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.HorizontalAlign;
				else
					return hzHorizontalAlign;
			}
			set
			{
				hzHorizontalAlign = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.HorizontalAlign = value;
			}
		}

		public bool EditView
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.EditView;
				else
					return bEditView;
			}
			set
			{
				bEditView = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.EditView = value;
			}
		}

		public bool ShowRequired
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.ShowRequired;
				else
					return bShowRequired;
			}
			set
			{
				bShowRequired = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.ShowRequired = value;
			}
		}

		public bool ShowError
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.ShowError;
				else
					return bShowError;
			}
			set
			{
				bShowError = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.ShowError = value;
			}
		}

		public bool ShowButtons
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.ShowButtons;
				else
					return bShowButtons;
			}
			set
			{
				bShowButtons = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.ShowButtons = value;
			}
		}

		public string ErrorText
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.ErrorText;
				else
					return sErrorText;
			}
			set
			{
				sErrorText = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.ErrorText = value;
			}
		}

		public string ErrorClass
		{
			get
			{
				if ( ctlHeaderButtons != null )
					return ctlHeaderButtons.ErrorClass;
				else
					return sErrorClass;
			}
			set
			{
				sErrorClass = value;
				if ( ctlHeaderButtons != null )
					ctlHeaderButtons.ErrorClass = value;
			}
		}

		public string ErrorClientID
		{
			get
			{
				return ctlHeaderButtons.ErrorClientID;
			}
		}

		public void DisableAll()
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.DisableAll();
		}

		public void HideAll()
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.HideAll();
		}

		public void HideAllLinks()
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.HideAllLinks();
		}

		public void ShowAll()
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.ShowAll();
		}

		public void ShowButton(string sCommandName, bool bVisible)
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.ShowButton(sCommandName, bVisible);
		}

		// 10/31/2017 Paul.  Provide a way to inject Record level ACL. 
		public bool IsButtonVisible(string sCommandName)
		{
			bool bVisible = false;
			if ( ctlHeaderButtons != null )
				bVisible = ctlHeaderButtons.IsButtonVisible(sCommandName);
			return bVisible;
		}

		public void ShowHyperLink(string sURL, bool bVisible)
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.ShowHyperLink(sURL, bVisible);
		}

		// 03/27/2016 Paul.  We want to be able to change an order pdf per language. 
		public void ReplaceHyperLinkString(string sOldValue, string sNewValue)
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.ReplaceHyperLinkString(sOldValue, sNewValue);
		}

		public void EnableButton(string sCommandName, bool bEnabled)
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.EnableButton(sCommandName, bEnabled);
		}

		public void SetButtonText(string sCommandName, string sText)
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.SetButtonText(sCommandName, sText);
		}

		public string ButtonClientID(string sCommandName)
		{
			if ( ctlHeaderButtons != null )
				return ctlHeaderButtons.ButtonClientID(sCommandName);
			return String.Empty;
		}

		public Button FindButton(string sCommandName)
		{
			if ( ctlHeaderButtons != null )
				return ctlHeaderButtons.FindButton(sCommandName);
			return null;
		}

		public void AppendButtons(string sVIEW_NAME, Guid gASSIGNED_USER_ID, DataRow rdr)
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, rdr);
		}

		// 08/06/2015 Paul.  Separate method to include process buttons so that we don't do a process query for all the non-detailview buttons. 
		// 07/01/2019 Paul.  Perform archive lookup to see if record is archived. 
		public void AppendProcessButtons(DataRow rdr)
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.AppendProcessButtons(rdr);
		}
		
		// 06/29/2018 Paul.  Separate method to include data privacy buttons. 
		public void AppendDataPrivacyButtons(DataRow rdr)
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.AppendDataPrivacyButtons(rdr);
		}

		public void AppendButtons(string sVIEW_NAME, Guid gASSIGNED_USER_ID, Guid gID)
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, gID);
		}

		public void AppendButton(string sCommandName, string sCommandArgument, string sText, string sToolTip, string sButtonStyle)
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.AppendButton(sCommandName, sCommandArgument, sText, sToolTip, sButtonStyle);
		}

		public void AppendLinks(string sVIEW_NAME, Guid gASSIGNED_USER_ID, DataRow rdr)
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.AppendLinks(sVIEW_NAME, gASSIGNED_USER_ID, rdr);
		}

		public void AppendLinks(string sVIEW_NAME, Guid gASSIGNED_USER_ID, Guid gID)
		{
			if ( ctlHeaderButtons != null )
				ctlHeaderButtons.AppendLinks(sVIEW_NAME, gASSIGNED_USER_ID, gID);
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
			string sModuleHeaderPath = "~/App_MasterPages/" + Page.Theme + "/HeaderButtons.ascx";
			// 08/25/2013 Paul.  File IO is slow, so cache existance test. 
			if ( Utils.CachedFileExists(Context, sModuleHeaderPath) )
			{
				ctlHeaderButtons = LoadControl(sModuleHeaderPath) as SplendidCRM.Themes.Sugar.HeaderButtons;
				if ( ctlHeaderButtons != null )
				{
					ctlHeaderButtons.Module            = sModule           ;
					// 01/02/2020 Paul.  Provide a way to set the module name. 
					ctlHeaderButtons.ModuleTitle       = sModuleTitle      ;
					ctlHeaderButtons.Title             = sTitle            ;
					ctlHeaderButtons.HelpName          = sHelpName         ;
					ctlHeaderButtons.TitleText         = sTitleText        ;
					ctlHeaderButtons.EnableModuleLabel = bEnableModuleLabel;
					ctlHeaderButtons.EnablePrint       = bEnablePrint      ;
					ctlHeaderButtons.EnableHelp        = bEnableHelp       ;
					ctlHeaderButtons.EnableFavorites   = bEnableFavorites  ;

					ctlHeaderButtons.Command          += ehCommand         ;
					ctlHeaderButtons.HorizontalAlign   = hzHorizontalAlign ;
					ctlHeaderButtons.EditView          = bEditView         ;
					ctlHeaderButtons.ShowRequired      = bShowRequired     ;
					ctlHeaderButtons.ShowError         = bShowError        ;
					ctlHeaderButtons.ShowButtons       = bShowButtons      ;
					ctlHeaderButtons.ErrorText         = sErrorText        ;
					ctlHeaderButtons.ErrorClass        = sErrorClass       ;
					pnlHeaderButtons.Controls.Add(ctlHeaderButtons);
				}
			}
		}
		#endregion
	}
}

