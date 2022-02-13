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
using System.Web.UI.HtmlControls;
using System.Data;

namespace SplendidCRM.Themes.Sugar
{
	/// <summary>
	///		Summary description for ModuleHeader.
	/// </summary>
	public class ModuleHeader : SplendidControl
	{
		// 01/02/2020 Paul.  Provide a way to set the module name. 
		protected string    sModuleTitle       = String.Empty;
		protected string    sModule            = String.Empty;
		protected string    sTitle             = String.Empty;
		protected string    sHelpName          = String.Empty;
		protected bool      bEnableModuleLabel = true;
		protected bool      bEnablePrint;
		protected bool      bEnableHelp ;
		// 03/31/2012 Paul.  Add support for favorites. 
		protected bool      bEnableFavorites   ;
		protected Guid      gFAVORITE_RECORD_ID;
		protected Image     imgFavoritesAdd    ;
		protected Image     imgFavoritesRemove ;
		// 07/28/2010 Paul.  The module will become a link to the module list. 
		protected HyperLink lnkModule   ;
		protected Label     lblPointer  ;
		protected Label     lblTitle    ;
		protected HyperLink lnkHelpImage;
		protected HyperLink lnkHelpText ;
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

		// 09/03/2006 Paul.  Import needs to update the text directly. 
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

		// 03/31/2012 Paul.  Add support for favorites. 
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
		}
		
		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( lblTitle != null )
			{
				// 07/28/2010 Paul.  The module will become a link to the module list. 
				// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
				// 11/10/2014 Paul.  Legacy code does use HTML in the title.  Until we fix the code, we need to support it. 
				if ( sTitle.StartsWith("<a href=\"default.aspx\">") && sTitle.Contains( "</a><span class=\"pointer\">&raquo;</span>") )
					lblTitle.Text = L10n.Term(sTitle);
				else
					lblTitle.Text = HttpUtility.HtmlEncode(L10n.Term(sTitle));
				if ( bEnableModuleLabel )
				{
					// 10/20/2010 Paul.  lnkModule will not exist on the old Sugar2006 theme. 
					if ( lnkModule != null )
					{
						// 01/02/2020 Paul.  Provide a way to set the module name. 
						if ( Sql.IsEmptyString(sModuleTitle) )
							sModuleTitle = L10n.Term(".moduleList." + sModule);
						lnkModule .Text        = sModuleTitle;
						lnkModule .Visible     = true;
						lblPointer.Visible     = true;
						if ( Sql.ToBoolean(Application["Modules." + sModule + ".Valid"]) )
						{
							// 09/02/2012 Paul.  The Users module is an admin module that is not under the admin folder. This should have been fixed long ago. 
							// 10/23/2015 Paul.  We should have been using the module setting many years ago.  Keep the old code just in case there is problems with legacy systems. 
							string sRelativePath = Sql.ToString(Application["Modules." + sModule + ".RelativePath"]);
							if ( sRelativePath.StartsWith("~/") )
								lnkModule .NavigateUrl = sRelativePath;
							else if ( sModule == "Users" )
								lnkModule .NavigateUrl = "~/" + sModule;
							// 05/12/2012 Paul.  If the module points to the administration root, then we do not need to append the module name. 
							else if ( Sql.ToBoolean(Application["Modules." + sModule + ".IsAdmin"]) && sModule != "Administration" )
								lnkModule .NavigateUrl = "~/Administration/" + sModule;
							// 12/09/2010 Paul.  Need to create Project and ProjectTask folders. 
							else if ( sModule == "Project" || sModule == "ProjectTask" )
								lnkModule .NavigateUrl = "~/" + sModule + "s";
							// 09/15/2014 Paul.  ReportRules is under the Reports folder. 
							else if ( sModule == "ReportRules" )
								lnkModule .NavigateUrl = "~/Reports/" + sModule;
							else
								lnkModule .NavigateUrl = "~/" + sModule;
						}
					}
				}
			}
			if ( bEnableHelp )
			{
				// 01/26/2011 Paul.  Don't show the Help Wiki on a mobile device. 
				if ( !Sql.IsEmptyString(sHelpName) && !this.IsMobile )
				{
					if ( lnkHelpImage != null )
						lnkHelpImage.NavigateUrl = "~/Help/view.aspx?MODULE=" + sModule + "&NAME=" + sHelpName;
					if ( lnkHelpText != null )
					{
						// 02/07/2010 Paul.  Defensive programming, build URL just in case lnkHelpImage is null. 
						lnkHelpText.NavigateUrl = "~/Help/view.aspx?MODULE=" + sModule + "&NAME=" + sHelpName;
						// 10/25/2006 Paul.  There is a config flag to disable the wiki entirely. 
						if ( (SplendidCRM.Security.GetUserAccess("Help", "edit") >= 0) && Sql.ToBoolean(Application["CONFIG.enable_help_wiki"]) )
							lnkHelpText.Text = L10n.Term(".LNK_HELP_WIKI");
						else
							lnkHelpText.Text = L10n.Term(".LNK_HELP");
					}
				}
				else
				{
					bEnableHelp = false;
					// 12/31/2010 Paul.  Need to manually hide the help links. 
					if ( lnkHelpImage != null )
						lnkHelpImage.Visible = bEnableHelp;
					if ( lnkHelpText != null )
						lnkHelpText.Visible = bEnableHelp;
				}
			}
			// 03/31/2012 Paul.  Add support for favorites. 
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
			// 10/09/2015 Paul.  Add support for subscriptions. 
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

