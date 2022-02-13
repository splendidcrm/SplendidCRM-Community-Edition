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
using System.Data.Common;

namespace SplendidCRM.Themes.Sugar
{
	/// <summary>
	///		Summary description for HeaderButtons.
	/// </summary>
	public class HeaderButtons : SplendidControl
	{
		#region ModuleHeader
		// 01/02/2020 Paul.  Provide a way to set the module name. 
		protected string    sModuleTitle       = String.Empty;
		protected string    sModule            = String.Empty;
		protected string    sTitle             = String.Empty;
		protected string    sHelpName          = String.Empty;
		protected bool      bEnableModuleLabel = true;
		protected bool      bEnablePrint       ;
		protected bool      bEnableHelp        ;
		protected bool      bEnableFavorites   ;
		protected Guid      gFAVORITE_RECORD_ID;
		protected Image     imgFavoritesAdd    ;
		protected Image     imgFavoritesRemove ;
		protected HyperLink lnkModule          ;
		protected Label     lblPointer         ;
		protected Label     lblTitle           ;
		protected HyperLink lnkHelpImage       ;
		protected HyperLink lnkHelpText        ;
		// 10/09/2015 Paul.  Add support for subscriptions. 
		protected Guid       gSUBSCRIPTION_PARENT_ID;
		protected WebControl imgFollow              ;
		protected WebControl imgFollowing           ;

		// 01/02/2020 Paul.  Provide a way to set the module name. 
		public string ModuleTitle
		{
			get
			{
				return sModuleTitle;
			}
			set
			{
				sModuleTitle = value;
				if ( lnkModule != null )
					lnkModule .Text = sModuleTitle;
			}
		}

		public string Module
		{
			get
			{
				return sModule;
			}
			set
			{
				sModule = value;
				// 10/10/2015 Paul.  Allow activity streams to be disabled for performance reasons. 
				this.m_bStreamEnabled = Sql.ToBoolean(Application["Modules." + sModule + ".StreamEnabled"]) && Sql.ToBoolean(Application["CONFIG.enable_activity_streams"]);
			}
		}

		public string Title
		{
			get
			{
				return sTitle;
			}
			set
			{
				sTitle = value;
			}
		}

		public string HelpName
		{
			get
			{
				return sHelpName;
			}
			set
			{
				sHelpName = value;
			}
		}

		public string TitleText
		{
			get
			{
				if ( lblTitle != null )
					return lblTitle.Text;
				else
					return String.Empty;
			}
			set
			{
				if ( lblTitle != null )
					lblTitle.Text = value;
			}
		}

		public bool EnableModuleLabel
		{
			get
			{
				return bEnableModuleLabel;
			}
			set
			{
				bEnableModuleLabel = value;
			}
		}

		public bool EnablePrint
		{
			get
			{
				return bEnablePrint;
			}
			set
			{
				bEnablePrint = value;
			}
		}

		public bool EnableHelp
		{
			get
			{
				return bEnableHelp;
			}
			set
			{
				bEnableHelp = value;
			}
		}

		public bool EnableFavorites
		{
			get
			{
				return bEnableFavorites;
			}
			set
			{
				bEnableFavorites = value;
			}
		}

		public virtual void SetTitle()
		{
			if ( lblTitle != null )
			{
				// 06/30/2018 Paul.  If title is a link, then there will not be a term lookup. 
				if ( sTitle.StartsWith("<a href=\"default.aspx\">") && sTitle.Contains( "</a><span class=\"pointer\">&raquo;</span>") )
					lblTitle.Text = sTitle;
				// 06/30/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
				else if ( sTitle.Contains("<span class=\"Erased\">") )
					lblTitle.Text = HttpUtility.HtmlEncode(sTitle.Replace(Sql.DataPrivacyErasedPill(L10n), String.Empty)) + Sql.DataPrivacyErasedPill(L10n);
				else
					lblTitle.Text = HttpUtility.HtmlEncode(L10n.Term(sTitle));
				if ( bEnableModuleLabel )
				{
					if ( lnkModule != null )
					{
						// 01/02/2020 Paul.  Provide a way to set the module name. 
						if ( Sql.IsEmptyString(sModuleTitle) )
							sModuleTitle = L10n.Term(".moduleList." + sModule);
						lnkModule .Text        = sModuleTitle;
						// 09/25/2016 Paul.  The Arctic theme does not include the module name. 
						lnkModule .Visible     = (Page.Theme != "Arctic");
						if ( lblPointer != null )
							lblPointer.Visible     = (Page.Theme != "Arctic");
						if ( Sql.ToBoolean(Application["Modules." + sModule + ".Valid"]) )
						{
							// 10/23/2015 Paul.  We should have been using the module setting many years ago.  Keep the old code just in case there is problems with legacy systems. 
							string sRelativePath = Sql.ToString(Application["Modules." + sModule + ".RelativePath"]);
							if ( sRelativePath.StartsWith("~/") )
								lnkModule .NavigateUrl = sRelativePath;
							else if ( sModule == "Users" )
								lnkModule .NavigateUrl = "~/" + sModule;
							else if ( Sql.ToBoolean(Application["Modules." + sModule + ".IsAdmin"]) && sModule != "Administration" )
								lnkModule .NavigateUrl = "~/Administration/" + sModule;
							else if ( sModule == "Project" || sModule == "ProjectTask" )
								lnkModule .NavigateUrl = "~/" + sModule + "s";
							else if ( sModule == "ReportRules" )
								lnkModule .NavigateUrl = "~/Reports/" + sModule;
							else
								lnkModule .NavigateUrl = "~/" + sModule;
						}
					}
				}
			}
		}

		public virtual void SetHelp()
		{
			if ( bEnableHelp )
			{
				if ( !Sql.IsEmptyString(sHelpName) && !this.IsMobile )
				{
					if ( lnkHelpImage != null )
						lnkHelpImage.NavigateUrl = "~/Help/view.aspx?MODULE=" + sModule + "&NAME=" + sHelpName;
					if ( lnkHelpText != null )
					{
						lnkHelpText.NavigateUrl = "~/Help/view.aspx?MODULE=" + sModule + "&NAME=" + sHelpName;
						if ( (SplendidCRM.Security.GetUserAccess("Help", "edit") >= 0) && Sql.ToBoolean(Application["CONFIG.enable_help_wiki"]) )
							lnkHelpText.Text = L10n.Term(".LNK_HELP_WIKI");
						else
							lnkHelpText.Text = L10n.Term(".LNK_HELP");
					}
				}
				else
				{
					bEnableHelp = false;
					if ( lnkHelpImage != null )
						lnkHelpImage.Visible = bEnableHelp;
					if ( lnkHelpText != null )
						lnkHelpText.Visible = bEnableHelp;
				}
			}
		}

		public virtual void SetFavorites()
		{
			if ( bEnableFavorites && !Sql.IsEmptyString(sModule) )
			{
				Guid gID = Sql.ToGuid(Request["ID"]);
				if ( !Sql.IsEmptyGuid(gID) )
				{
					DataTable dtFavorites = SplendidCache.Favorites();
					DataView  vwFavorites = new DataView(dtFavorites);
					vwFavorites.RowFilter = "MODULE_NAME = '" + sModule + "' and ITEM_ID = '" + gID.ToString() + "'";
					if ( vwFavorites.Count > 0 )
					{
						gFAVORITE_RECORD_ID = Sql.ToGuid(vwFavorites[0]["ITEM_ID"]);
						if ( imgFavoritesAdd    != null ) imgFavoritesAdd   .DataBind();
						if ( imgFavoritesRemove != null ) imgFavoritesRemove.DataBind();
					}
				}
			}
		}

		// 10/09/2015 Paul.  Add support for subscriptions. 
		public virtual void SetSubscritions()
		{
			// 10/09/2015 Paul.  We will only be using the follow icons when we have favorites. 
			// 10/10/2015 Paul.  Allow activity streams to be disabled for performance reasons. 
			this.m_bStreamEnabled = Sql.ToBoolean(Application["Modules." + sModule + ".StreamEnabled"]) && Sql.ToBoolean(Application["CONFIG.enable_activity_streams"]);
			if ( bEnableFavorites && !Sql.IsEmptyString(sModule) && this.StreamEnabled() )
			{
				Guid gID = Sql.ToGuid(Request["ID"]);
				if ( !Sql.IsEmptyGuid(gID) )
				{
					DataTable dtSubscriptions = SplendidCache.Subscriptions();
					DataView  vwSubscriptions = new DataView(dtSubscriptions);
					vwSubscriptions.RowFilter = "SUBSCRIPTION_PARENT_TYPE = '" + sModule + "' and SUBSCRIPTION_PARENT_ID = '" + gID.ToString() + "'";
					if ( vwSubscriptions.Count > 0 )
					{
						gSUBSCRIPTION_PARENT_ID = Sql.ToGuid(vwSubscriptions[0]["SUBSCRIPTION_PARENT_ID"]);
						if ( imgFollow    != null ) imgFollow   .DataBind();
						if ( imgFollowing != null ) imgFollowing.DataBind();
					}
				}
			}
		}

		#endregion

		#region DynamicButtons
		protected PlaceHolder pnlDynamicButtons;
		protected Label       lblError         ;
		protected TableCell   tdButtons        ;
		protected TableCell   tdError          ;
		protected TableCell   tdRequired       ;
		protected TableCell   tdDynamicLinks   ;
		protected PlaceHolder pnlDynamicLinks  ;
		// 03/27/2016 Paul.  Move phButtonHover to base class to centralize management. 
		protected Panel       phButtonHover    ;
		protected bool        bEditView = false;
		// 08/02/2016 Paul.  Add buttons used with Business Processes. 
		protected PlaceHolder pnlProcessButtons;
		protected _controls.ProcessButtons ctlProcessButtons;

		public CommandEventHandler Command;

		public HorizontalAlign HorizontalAlign
		{
			get
			{
				if ( tdButtons != null )
					return tdButtons.HorizontalAlign;
				return HorizontalAlign.Left;
			}
			set
			{
				if ( tdButtons != null )
					tdButtons.HorizontalAlign = value;
			}
		}

		public bool EditView
		{
			get
			{
				return bEditView;
			}
			set
			{
				bEditView = value;
			}
		}

		public bool ShowRequired
		{
			get
			{
				if ( tdRequired != null )
					return tdRequired.Visible;
				return false;
			}
			set
			{
				if ( tdRequired != null )
					tdRequired.Visible = value;
			}
		}

		public bool ShowError
		{
			get
			{
				if ( lblError != null )
					return lblError.Visible;
				return false;
			}
			set
			{
				if ( tdError != null )
					tdError.Visible = value;
				if ( lblError != null )
					lblError.Visible = value;
			}
		}

		public virtual bool ShowButtons
		{
			get
			{
				if ( tdButtons != null )
					return tdButtons.Visible;
				return false;
			}
			set
			{
				if ( tdButtons != null )
					tdButtons.Visible = value;
			}
		}

		public string ErrorText
		{
			get
			{
				if ( lblError != null )
					return lblError.Text;
				return String.Empty;
			}
			set
			{
				if ( lblError != null )
					lblError.Text = value;
			}
		}

		public string ErrorClass
		{
			get
			{
				if ( lblError != null )
					return lblError.CssClass;
				return String.Empty;
			}
			set
			{
				if ( lblError != null )
					lblError.CssClass = value;
			}
		}

		public string ErrorClientID
		{
			get
			{
				if ( lblError != null )
					return lblError.ClientID;
				return String.Empty;
			}
		}

		public virtual void DisableAll()
		{
			if ( pnlDynamicButtons != null )
			{
				foreach ( Control ctl in pnlDynamicButtons.Controls )
				{
					if ( ctl is Button )
						(ctl as Button).Enabled = false;
					else if ( ctl is HyperLink )
						(ctl as HyperLink).Enabled = false;
				}
			}
			if ( pnlDynamicLinks != null )
			{
				foreach ( Control ctl in pnlDynamicLinks.Controls )
				{
					if ( ctl is Button )
						(ctl as Button).Enabled = false;
					else if ( ctl is HyperLink )
						(ctl as HyperLink).Enabled = false;
				}
			}
			// 03/27/2016 Paul.  Move phButtonHover to base class to centralize management. 
			if ( phButtonHover != null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is Button )
						(ctl as Button).Enabled = false;
					else if ( ctl is HyperLink )
						(ctl as HyperLink).Enabled = false;
				}
			}
			// 08/06/2015 paul.  Separate method to include process buttons so that we don't do a process query for all the non-detailview buttons. 
			if ( pnlProcessButtons != null )
			{
				foreach ( Control ctl in pnlProcessButtons.Controls )
				{
					ctl.Visible = false;
				}
			}
		}

		public virtual void HideAll()
		{
			if ( pnlDynamicButtons != null )
			{
				foreach ( Control ctl in pnlDynamicButtons.Controls )
				{
					if ( ctl is Button )
						(ctl as Button).Visible = false;
					else if ( ctl is HyperLink )
						(ctl as HyperLink).Visible = false;
				}
			}
			if ( pnlDynamicLinks != null )
			{
				foreach ( Control ctl in pnlDynamicLinks.Controls )
				{
					if ( ctl is Button )
						(ctl as Button).Visible = false;
					else if ( ctl is HyperLink )
						(ctl as HyperLink).Visible = false;
				}
			}
			// 03/27/2016 Paul.  Move phButtonHover to base class to centralize management. 
			if ( phButtonHover != null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is Button )
						(ctl as Button).Visible = false;
					else if ( ctl is HyperLink )
						(ctl as HyperLink).Visible = false;
				}
			}
			// 08/06/2015 paul.  Separate method to include process buttons so that we don't do a process query for all the non-detailview buttons. 
			if ( pnlProcessButtons != null )
			{
				foreach ( Control ctl in pnlProcessButtons.Controls )
				{
					ctl.Visible = false;
				}
			}
		}

		public virtual void HideAllLinks()
		{
			if ( pnlDynamicLinks != null )
			{
				foreach ( Control ctl in pnlDynamicLinks.Controls )
				{
					if ( ctl is Button )
						(ctl as Button).Visible = false;
					else if ( ctl is HyperLink )
						(ctl as HyperLink).Visible = false;
				}
			}
			// 03/27/2016 Paul.  Move phButtonHover to base class to centralize management. 
			if ( phButtonHover != null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is Button )
						(ctl as Button).Visible = false;
					else if ( ctl is HyperLink )
						(ctl as HyperLink).Visible = false;
				}
			}
		}

		public virtual void ShowAll()
		{
			if ( pnlDynamicButtons != null )
			{
				foreach ( Control ctl in pnlDynamicButtons.Controls )
				{
					if ( ctl is Button )
						(ctl as Button).Visible = true;
					else if ( ctl is HyperLink )
						(ctl as HyperLink).Visible = true;
				}
			}
			if ( pnlDynamicLinks != null )
			{
				foreach ( Control ctl in pnlDynamicLinks.Controls )
				{
					if ( ctl is Button )
						(ctl as Button).Visible = true;
					else if ( ctl is HyperLink )
						(ctl as HyperLink).Visible = true;
				}
			}
			// 03/27/2016 Paul.  Move phButtonHover to base class to centralize management. 
			if ( phButtonHover != null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is Button )
						(ctl as Button).Visible = true;
					else if ( ctl is HyperLink )
						(ctl as HyperLink).Visible = true;
				}
			}
		}

		public virtual void ShowButton(string sCommandName, bool bVisible)
		{
			if ( pnlDynamicButtons != null )
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
			if ( pnlDynamicLinks != null )
			{
				foreach ( Control ctl in pnlDynamicLinks.Controls )
				{
					if ( ctl is Button )
					{
						Button btn = ctl as Button;
						if ( btn.CommandName == sCommandName )
							btn.Visible = bVisible;
					}
				}
			}
			// 03/27/2016 Paul.  Move phButtonHover to base class to centralize management. 
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
				}
			}
			// 07/01/2019 Paul.  Perform archive lookup to see if record is archived. 
			if ( pnlProcessButtons != null )
			{
				foreach ( Control ctl in pnlProcessButtons.Controls )
				{
					Button btn = ctl as Button;
					if ( btn.CommandName == sCommandName )
						btn.Visible = bVisible;
				}
			}
		}

		// 10/31/2017 Paul.  Provide a way to inject Record level ACL. 
		public virtual bool IsButtonVisible(string sCommandName)
		{
			bool bVisible = false;
			if ( pnlDynamicButtons != null )
			{
				foreach ( Control ctl in pnlDynamicButtons.Controls )
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
				}
			}
			if ( pnlDynamicLinks != null )
			{
				foreach ( Control ctl in pnlDynamicLinks.Controls )
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
				}
			}
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
				}
			}
			return bVisible;
		}

		public virtual void ShowHyperLink(string sURL, bool bVisible)
		{
			if ( pnlDynamicButtons != null )
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
			if ( pnlDynamicLinks != null )
			{
				foreach ( Control ctl in pnlDynamicLinks.Controls )
				{
					if ( ctl is HyperLink )
					{
						HyperLink lnk = ctl as HyperLink;
						if ( lnk.NavigateUrl == sURL )
							lnk.Visible = bVisible;
					}
				}
			}
			// 03/27/2016 Paul.  Move phButtonHover to base class to centralize management. 
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
					if ( ctl is Button )
					{
						Button lnk = ctl as Button;
						if ( lnk.OnClientClick.Contains(sURL) )
							lnk.Visible = bVisible;
					}
				}
			}
		}

		// 03/27/2016 Paul.  We want to be able to change an order pdf per language. 
		public void ReplaceHyperLinkString(string sOldValue, string sNewValue)
		{
			if ( pnlDynamicButtons != null )
			{
				foreach ( Control ctl in pnlDynamicButtons.Controls )
				{
					if ( ctl is HyperLink )
					{
						HyperLink lnk = ctl as HyperLink;
						lnk.NavigateUrl = lnk.NavigateUrl.Replace(sOldValue, sNewValue);
					}
					else if ( ctl is Button )
					{
						Button btn = ctl as Button;
						btn.OnClientClick = btn.OnClientClick.Replace(sOldValue, sNewValue);
					}
				}
			}
			if ( pnlDynamicLinks != null )
			{
				foreach ( Control ctl in pnlDynamicLinks.Controls )
				{
					if ( ctl is HyperLink )
					{
						HyperLink lnk = ctl as HyperLink;
						lnk.NavigateUrl = lnk.NavigateUrl.Replace(sOldValue, sNewValue);
					}
					else if ( ctl is Button )
					{
						Button btn = ctl as Button;
						btn.OnClientClick = btn.OnClientClick.Replace(sOldValue, sNewValue);
					}
				}
			}
			// 03/27/2016 Paul.  Move phButtonHover to base class to centralize management. 
			if ( phButtonHover != null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is HyperLink )
					{
						HyperLink lnk = ctl as HyperLink;
						lnk.NavigateUrl = lnk.NavigateUrl.Replace(sOldValue, sNewValue);
					}
					else if ( ctl is Button )
					{
						Button btn = ctl as Button;
						btn.OnClientClick = btn.OnClientClick.Replace(sOldValue, sNewValue);
					}
				}
			}
		}

		public virtual void EnableButton(string sCommandName, bool bEnabled)
		{
			if ( pnlDynamicButtons != null )
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
			if ( pnlDynamicLinks != null )
			{
				foreach ( Control ctl in pnlDynamicLinks.Controls )
				{
					if ( ctl is Button )
					{
						Button btn = ctl as Button;
						if ( btn.CommandName == sCommandName )
							btn.Enabled = bEnabled;
					}
				}
			}
			// 03/27/2016 Paul.  Move phButtonHover to base class to centralize management. 
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
				}
			}
		}

		public virtual void SetButtonText(string sCommandName, string sText)
		{
			if ( pnlDynamicButtons != null )
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
			if ( pnlDynamicLinks != null )
			{
				foreach ( Control ctl in pnlDynamicLinks.Controls )
				{
					if ( ctl is Button )
					{
						Button btn = ctl as Button;
						if ( btn.CommandName == sCommandName )
							btn.Text = sText;
					}
				}
			}
			// 03/27/2016 Paul.  Move phButtonHover to base class to centralize management. 
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

		public virtual string ButtonClientID(string sCommandName)
		{
			if ( pnlDynamicButtons != null )
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
			}
			if ( pnlDynamicLinks != null )
			{
				foreach ( Control ctl in pnlDynamicLinks.Controls )
				{
					if ( ctl is Button )
					{
						Button btn = ctl as Button;
						if ( btn.CommandName == sCommandName )
							return btn.ClientID;
					}
				}
			}
			// 03/27/2016 Paul.  Move phButtonHover to base class to centralize management. 
			if ( phButtonHover != null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is Button )
					{
						Button btn = ctl as Button;
						if ( btn.CommandName == sCommandName )
							return btn.ClientID;
					}
				}
			}
			return String.Empty;
		}

		public virtual Button FindButton(string sCommandName)
		{
			if ( pnlDynamicButtons != null )
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
			}
			if ( pnlDynamicLinks != null )
			{
				foreach ( Control ctl in pnlDynamicLinks.Controls )
				{
					if ( ctl is Button )
					{
						Button btn = ctl as Button;
						if ( btn.CommandName == sCommandName )
							return btn;
					}
				}
			}
			// 03/27/2016 Paul.  Move phButtonHover to base class to centralize management. 
			if ( phButtonHover != null )
			{
				foreach ( Control ctl in phButtonHover.Controls )
				{
					if ( ctl is Button )
					{
						Button btn = ctl as Button;
						if ( btn.CommandName == sCommandName )
							return btn;
					}
				}
			}
			return null;
		}

		public virtual void AppendButtons(string sVIEW_NAME, Guid gASSIGNED_USER_ID, DataRow rdr)
		{
			if ( pnlDynamicButtons != null )
				SplendidDynamic.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, this.pnlDynamicButtons, this.IsMobile, rdr, this.GetL10n(), new CommandEventHandler(Page_Command));
		}

		public virtual void AppendButtons(string sVIEW_NAME, Guid gASSIGNED_USER_ID, Guid gID)
		{
			if ( pnlDynamicButtons != null )
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
						SplendidDynamic.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, this.pnlDynamicButtons, this.IsMobile, row, this.GetL10n(), new CommandEventHandler(Page_Command));
					}
				}
			}
		}

		public virtual void AppendButton(string sCommandName, string sCommandArgument, string sText, string sToolTip, string sButtonStyle)
		{
			Button btn = new Button();
			btn.Command         += new CommandEventHandler(Page_Command);
			btn.CommandName      = sCommandName    ;
			btn.CommandArgument  = sCommandArgument;
			btn.CssClass         = "button"        ;
			btn.Text             = "  " + sText + "  ";
			btn.ToolTip          = sToolTip        ;
			btn.Attributes.Add("style", "margin-right: 3px;");
			this.pnlDynamicButtons.Controls.Add(btn);
		}

		public virtual void AppendLinks(string sVIEW_NAME, Guid gASSIGNED_USER_ID, DataRow rdr)
		{
			if ( tdDynamicLinks != null && pnlDynamicLinks != null )
			{
				tdDynamicLinks.Visible = true;
				SplendidDynamic.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, pnlDynamicLinks, this.IsMobile, rdr, this.GetL10n(), new CommandEventHandler(Page_Command));
			}
		}

		public virtual void AppendLinks(string sVIEW_NAME, Guid gASSIGNED_USER_ID, Guid gID)
		{
			if ( tdDynamicLinks != null && pnlDynamicLinks != null )
			{
				tdDynamicLinks.Visible = true;
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
						SplendidDynamic.AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, pnlDynamicLinks, this.IsMobile, row, this.GetL10n(), new CommandEventHandler(Page_Command));
					}
				}
			}
		}
		#endregion

		#region ProcessButtons
		// 08/06/2015 paul.  Separate method to include process buttons so that we don't do a process query for all the non-detailview buttons. 
		public void AppendProcessButtons(DataRow rdr)
		{
			if ( ctlProcessButtons != null )
				ctlProcessButtons.AppendProcessButtons(this, this.pnlProcessButtons, rdr);
		}
		// 06/29/2018 Paul.  Separate method to include data privacy buttons. 
		// 07/01/2019 Paul.  Perform archive lookup to see if record is archived. 
		public void AppendDataPrivacyButtons(DataRow rdr)
		{
			if ( ctlProcessButtons != null )
				ctlProcessButtons.AppendDataPrivacyButtons(this, this.pnlProcessButtons, rdr);
		}
		#endregion

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Print" )
			{
				PrintView = true;
				// 06/09/2006 Paul.  This is an exception to the new binding rule.  We want to rebind to apply the PrintView change. 
				Page.DataBind();
			}
			else if ( e.CommandName == "PrintOff" )
			{
				PrintView = false;
				// 06/09/2006 Paul.  This is an exception to the new binding rule.  We want to rebind to apply the PrintView change. 
				Page.DataBind();
			}
			else if ( e.CommandName == "ErrorText" )
			{
				this.ErrorText = Sql.ToString(e.CommandArgument);
			}
			else if ( e.CommandName.StartsWith("Processes.DetailView") )
			{
				DataRow rdr = e.CommandArgument as DataRow;
				if ( rdr != null )
				{
					this.pnlDynamicButtons.Controls.Clear();
					if ( phButtonHover != null )
						this.phButtonHover.Controls.Clear();
					this.AppendButtons(e.CommandName, Guid.Empty, rdr);
				}
			}
			else if ( Command != null )
				Command(this, e);
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetTitle();
			SetHelp();
			SetFavorites();
			SetSubscritions();
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
			if ( ctlProcessButtons != null )
				ctlProcessButtons.Command += new CommandEventHandler(Page_Command);
		}
		#endregion
	}
}

