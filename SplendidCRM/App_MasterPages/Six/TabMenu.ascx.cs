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
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Themes.Six
{
	/// <summary>
	///		Summary description for TabMenu.
	/// </summary>
	public class TabMenu : SplendidControl
	{
		protected HtmlTable   tblSixMenu    ;
		protected Panel       pnlTabMenuMore;
		protected PlaceHolder phMoreInnerCell;
		protected PlaceHolder phHoverControls;

		public void Refresh()
		{
			bool   bAjaxAutoComplete = false;
			string sActiveTab        = Sql.ToString(Page.Items["ActiveTabMenu"]);
			int    nMaxTabs          = Sql.ToInteger(Session["max_tabs"]);
			int nHistoryMaxViewed    = Sql.ToInteger(Application["CONFIG.history_max_viewed"]);
			// 08/16/2005 Paul.  Instead of TOP, use Fill to restrict the records. 
			if ( nHistoryMaxViewed == 0 )
				nHistoryMaxViewed = 10;
			// 09/24/2007 Paul.  Max tabs is a config variable and needs the CONFIG in front of the name. 
			if ( nMaxTabs == 0 )
				nMaxTabs = Sql.ToInteger(Application["CONFIG.default_max_tabs"]);
			if ( nMaxTabs == 0 )
				nMaxTabs = 12;
			
			ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
			// 11/23/2009 Paul.  SplendidCRM 4.0 is very slow on Blackberry devices.  Lets try and turn off AJAX AutoComplete. 
			bAjaxAutoComplete = (mgrAjax != null);
			if ( this.IsMobile )
			{
				// 11/24/2010 Paul.  .NET 4 has broken the compatibility of the browser file system. 
				// We are going to minimize our reliance on browser files in order to reduce deployment issues. 
				bAjaxAutoComplete = Utils.AllowAutoComplete && (mgrAjax != null);
			}
			
			// 09/12/2010 Paul.  Need to use the Portal menu. 
			// 10/20/2015 Paul.  Share code with Portal. 
			DataTable dtMenu = PortalCache.IsPortal() ? PortalCache.TabMenu() : SplendidCache.TabMenu();
			// 04/28/2006 Paul.  Hide the tab menu if there is no menu to display. 
			// This should only occur during login. 
			if ( dtMenu.Rows.Count == 0 )
			{
				this.Visible = false;
				return;
			}

			DataTable dtTracker = new DataTable();
			SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				sSQL = "select *                   " + ControlChars.CrLf
				     + "  from vwTRACKER_LastViewed" + ControlChars.CrLf
				     + " where USER_ID = @USER_ID  " + ControlChars.CrLf
				     + " order by DATE_ENTERED desc" + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@USER_ID", Security.USER_ID);
					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dtTracker);
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					}
				}
			}
			
			// 10/13/2010 Paul.  Clear the containers so that we can refresh the tab menu. 
			PlaceHolder plcMenuPopups = Page.Master.FindControl("plcMenuPopups") as PlaceHolder;
			plcMenuPopups.Controls.Clear();
			tblSixMenu.Rows.Clear();
			phMoreInnerCell.Controls.Clear();
			phHoverControls.Controls.Clear();
			
			HtmlTableRow  tr = new HtmlTableRow();
			HtmlTableCell td = new HtmlTableCell();
			tblSixMenu.Rows.Add(tr);
			tr.Cells.Add(td);
			td.Attributes.Add("style", "padding-left:14px;");
			td.Attributes.Add("class", "otherTabRight");
			Literal nbsp = new Literal();
			nbsp.Text = "&nbsp;";
			td.Controls.Add(nbsp);
			
			bool bActiveAdminTab = false;
			bool bActiveHighlighted = false;
			Image imgBlank = null;
			
			DataView vwTracker = new DataView(dtTracker);
			DataView vwMenu    = new DataView(dtMenu   );
			vwMenu.RowFilter = "MODULE_NAME = '" + sActiveTab + "'";
			if ( vwMenu.Count == 0 )
				bActiveAdminTab = true;
			// 08/04/2015 Paul.  Admin tab requires correction of max tabs. 
			if ( bActiveAdminTab && nMaxTabs > dtMenu.Rows.Count )
				nMaxTabs = dtMenu.Rows.Count;
			for ( int nRow = 0, nDisplayedTabs = 0; nRow < dtMenu.Rows.Count; nRow++ )
			{
				DataRow row = dtMenu.Rows[nRow];
				string sMODULE_NAME   = Sql.ToString(row["MODULE_NAME"  ]);
				string sRELATIVE_PATH = Sql.ToString(row["RELATIVE_PATH"]);
				string sDISPLAY_NAME  = L10n.Term(Sql.ToString(row["DISPLAY_NAME"]));
				string sTAB_CLASS     = (sMODULE_NAME == sActiveTab) ? "currentTab" : "otherTab";
				// 05/06/2010 Paul.  If the the ActiveTab is an admin page, then we need to force the last tab to be the active admin tab. 
				if ( bActiveAdminTab && !bActiveHighlighted && (nDisplayedTabs == nMaxTabs - 1) && !Sql.IsEmptyString(sActiveTab) )
				{
					// 06/13/2010 Paul.  Make sure to add the current tab to then More cell before converting to the Admin tab. 
					HyperLink lnk = new HyperLink();
					lnk.Text        = sDISPLAY_NAME;
					lnk.NavigateUrl = sRELATIVE_PATH;
					lnk.CssClass    = "otherTabMoreLink";
					phMoreInnerCell.Controls.Add(lnk);
					
					sMODULE_NAME   = sActiveTab;
					sRELATIVE_PATH = Sql.ToString(Application["Modules." + sMODULE_NAME + ".RelativePath"]);
					sDISPLAY_NAME  = L10n.Term(Sql.ToString(Application["Modules." + sMODULE_NAME + ".DisplayName"]));
					// 05/22/2010 Paul.  If the module is not defined, then it is likely being developed, so assume the typical defaults. 
					if ( Sql.IsEmptyString(sRELATIVE_PATH) )
					{
						// 07/24/2010 Paul.  We need an admin flag for the areas that don't have a record in the Modules table. 
						if ( Sql.ToBoolean(Page.Items["ActiveTabMenu.IsAdmin"]) )
							sRELATIVE_PATH = "~/Administration/" + sMODULE_NAME;
						else
							sRELATIVE_PATH = "~/" + sMODULE_NAME;
					}
					if ( Sql.IsEmptyString(sDISPLAY_NAME) )
						sDISPLAY_NAME = sMODULE_NAME;
					sTAB_CLASS     = "currentTab";
				}
				// 12/05/2006 Paul.  The TabMenu view does not filter the Calendar or activities tabs as they are virtual. 
				if ( SplendidCRM.Security.GetUserAccess(sMODULE_NAME, "access") >= 0 )
				{
					// 05/06/2010 Paul.  Always show the last tab as the Active Tab, if the active tab is not already highlighted. 
					if ( !bAjaxAutoComplete || (nDisplayedTabs < nMaxTabs - 1) || (nDisplayedTabs == nMaxTabs - 1 && (bActiveHighlighted || (sMODULE_NAME == sActiveTab))) )
					{
						if ( sMODULE_NAME == sActiveTab )
							bActiveHighlighted = true;
						
						nDisplayedTabs++;
						td = new HtmlTableCell();
						tr.Cells.Add(td);
						td.Attributes.Add("valign", "bottom");
						
						HtmlTable tblInner = new HtmlTable();
						tblInner.ID = "tabMenuInner" + sMODULE_NAME;
						td.Controls.Add(tblInner);
						tblInner.Attributes.Add("class"      , "tabFrame");
						tblInner.Attributes.Add("cellspacing", "0" );
						tblInner.Attributes.Add("cellpadding", "0" );
						tblInner.Attributes.Add("height"     , "25");
						HtmlTableRow  trInner = new HtmlTableRow();
						tblInner.Rows.Add(trInner);
						
						HtmlTableCell tdInner = new HtmlTableCell();
						trInner.Cells.Add(tdInner);
						tdInner.Attributes.Add("class" , sTAB_CLASS + "Left");
						imgBlank = new Image();
						imgBlank.SkinID = "blank";
						imgBlank.Width  = 5;
						imgBlank.Height = 25;
						// 08/31/2013 Paul.  In .NET 4.0, the default behavior does not set the border width, so do it manually. 
						imgBlank.BorderWidth = 0;
						tdInner.Controls.Add(imgBlank);
						
						tdInner = new HtmlTableCell();
						trInner.Cells.Add(tdInner);
						tdInner.Attributes.Add("class" , sTAB_CLASS);
						tdInner.Attributes.Add("nowrap", "1");
						HyperLink lnk = new HyperLink();
						tdInner.Controls.Add(lnk);
						lnk.CssClass    = sTAB_CLASS + "Link";
						lnk.NavigateUrl = sRELATIVE_PATH;
						lnk.Text        = sDISPLAY_NAME;
						
						tdInner = new HtmlTableCell();
						trInner.Cells.Add(tdInner);
						tdInner.Attributes.Add("class" , sTAB_CLASS + "Right");
						imgBlank = new Image();
						imgBlank.SkinID = "blank";
						imgBlank.Width  = 5;
						imgBlank.Height = 25;
						// 08/31/2013 Paul.  In .NET 4.0, the default behavior does not set the border width, so do it manually. 
						imgBlank.BorderWidth = 0;
						tdInner.Controls.Add(imgBlank);
						
						if ( (plcMenuPopups != null) && bAjaxAutoComplete && ((SplendidCRM.Security.AdminUserAccess(sMODULE_NAME, "access") >= 0) || !(Page as SplendidPage).IsAdminPage) )
						{
							DataTable dtShortcuts = SplendidCache.Shortcuts(sMODULE_NAME);
							if ( dtShortcuts.Rows.Count > 0 || vwTracker.Count > 0 )
							{
								Panel pnlModuleActions = new Panel();
								pnlModuleActions.ID = "pnlModuleActions" + sMODULE_NAME;
								// 05/03/2010 Paul.  Set the initial visibility to hidden to prevent flicker. 
								//pnlModuleActions.Attributes.Add("style", "visibility:hidden;");
								// 08/02/2010 Paul.  Need both display: none; visibility: hidden;
								pnlModuleActions.Attributes.Add("class", "PanelHoverHidden");
								// 05/06/2010 Paul.  Move popups to the end of the file. 
								plcMenuPopups.Controls.Add(pnlModuleActions);
								
								HtmlTable tblShading = new HtmlTable();
								tblShading.Attributes.Add("cellpadding", "0");
								tblShading.Attributes.Add("cellspacing", "0");
								tblShading.Attributes.Add("class"      , "ModuleActionsShadingTable");
								pnlModuleActions.Controls.Add(tblShading);
								
								// Top shading. 
								HtmlTableRow trShading = new HtmlTableRow();
								tblShading.Rows.Add(trShading);
								HtmlTableCell tdShading = new HtmlTableCell();
								trShading.Cells.Add(tdShading);
								tdShading.Attributes.Add("colspan", "3");
								tdShading.Attributes.Add("class", "ModuleActionsShadingHorizontal");
								
								trShading = new HtmlTableRow();
								tblShading.Rows.Add(trShading);
								// Left shading. 
								tdShading = new HtmlTableCell();
								trShading.Cells.Add(tdShading);
								tdShading.Attributes.Add("class", "ModuleActionsShadingVertical");
								
								tdShading = new HtmlTableCell();
								trShading.Cells.Add(tdShading);
								
								HtmlTable tblModuleActions = new HtmlTable();
								tblModuleActions.Attributes.Add("cellpadding", "0");
								tblModuleActions.Attributes.Add("cellspacing", "0");
								tblModuleActions.Attributes.Add("class"      , "ModuleActionsInnerTable");
								tdShading.Controls.Add(tblModuleActions);
								
								// Right shading. 
								tdShading = new HtmlTableCell();
								trShading.Cells.Add(tdShading);
								tdShading.Attributes.Add("class", "ModuleActionsShadingVertical");
								
								// Bottom shading. 
								trShading = new HtmlTableRow();
								tblShading.Rows.Add(trShading);
								tdShading = new HtmlTableCell();
								trShading.Cells.Add(tdShading);
								tdShading.Attributes.Add("colspan", "3");
								tdShading.Attributes.Add("class", "ModuleActionsShadingHorizontal");
			
								HtmlTableRow trShortcuts = new HtmlTableRow();
								tblModuleActions.Rows.Add(trShortcuts);
								HtmlTableCell tdShortcuts = new HtmlTableCell();
								HtmlTableCell tdLastViewed = new HtmlTableCell();
								tdShortcuts .Attributes.Add("class", "ModuleActionsInnerCell");
								tdLastViewed.Attributes.Add("class", "ModuleActionsInnerCell");
								trShortcuts.Cells.Add(tdShortcuts);
								trShortcuts.Cells.Add(tdLastViewed);
								Label lblActions    = new Label();
								Label lblLastViewed = new Label();
								lblActions   .Font.Bold = true;
								lblLastViewed.Font.Bold = true;
								lblActions   .Attributes.Add("class", "ModuleActionsInnerHeader");
								lblLastViewed.Attributes.Add("class", "ModuleActionsInnerHeader");
								lblActions   .Text = L10n.Term(".LBL_ACTIONS"    );
								lblLastViewed.Text = L10n.Term(".LBL_LAST_VIEWED");
								tdShortcuts .Controls.Add(lblActions   );
								tdLastViewed.Controls.Add(lblLastViewed);
								
								foreach ( DataRow rowShortcuts in dtShortcuts.Rows )
								{
									sRELATIVE_PATH = Sql.ToString(rowShortcuts["RELATIVE_PATH"]);
									//string sIMAGE_NAME    = Sql.ToString(rowShortcuts["IMAGE_NAME"   ]);
									sDISPLAY_NAME  = L10n.Term(Sql.ToString(rowShortcuts["DISPLAY_NAME"]));
									// 09/26/2017 Paul.  Add Archive access right. 
									string sSHORTCUT_ACLTYPE = Sql.ToString(rowShortcuts["SHORTCUT_ACLTYPE"]);
									if ( sSHORTCUT_ACLTYPE == "archive" )
									{
										// 09/26/2017 Paul.  If the module does not have an archive table, then hide the link. 
										bool bArchiveEnabled = Sql.ToBoolean(Application["Modules." + Sql.ToString(rowShortcuts["MODULE_NAME"]) + ".ArchiveEnabled"]);
										if ( !bArchiveEnabled )
											continue;
									}
									
									HyperLink lnkPopup = new HyperLink();
									lnkPopup.Text        = sDISPLAY_NAME;
									lnkPopup.NavigateUrl = sRELATIVE_PATH;
									lnkPopup.CssClass    = "ModuleActionsMenuItems";
									tdShortcuts.Controls.Add(lnkPopup);
								}
								vwTracker.RowFilter = "MODULE_NAME = '" + sMODULE_NAME + "'";
								int nLastViewedCount = 0;
								foreach ( DataRowView rowLastViewed in vwTracker )
								{
									sRELATIVE_PATH = Sql.ToString(rowLastViewed["RELATIVE_PATH"]);
									//string sIMAGE_NAME    = Sql.ToString(rowLastViewed["IMAGE_NAME"   ]);
									// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
									sDISPLAY_NAME  = HttpUtility.HtmlEncode(Sql.ToString(rowLastViewed["ITEM_SUMMARY"]));
									
									HyperLink lnkPopup = new HyperLink();
									lnkPopup.Text        = sDISPLAY_NAME;
									lnkPopup.NavigateUrl = sRELATIVE_PATH + "view.aspx?ID=" + Sql.ToString(rowLastViewed["ITEM_ID"]);
									lnkPopup.CssClass    = "ModuleActionsMenuItems";
									tdLastViewed.Controls.Add(lnkPopup);
									
									nLastViewedCount++;
									if ( nLastViewedCount > nHistoryMaxViewed )
										break;
								}
								if ( nLastViewedCount == 0 )
								{
									Label lblNone = new Label();
									lblNone.Text = L10n.Term(".LBL_LINK_NONE");
									tdLastViewed.Controls.Add(lblNone);
								}
								
								AjaxControlToolkit.HoverMenuExtender hovModuleActionsPopup = new AjaxControlToolkit.HoverMenuExtender();
								hovModuleActionsPopup.TargetControlID = tblInner.ID;
								hovModuleActionsPopup.PopupControlID  = pnlModuleActions.ID;
								hovModuleActionsPopup.PopupPosition   = AjaxControlToolkit.HoverMenuPopupPosition.Bottom;
								// 05/17/2010 Paul.  The hover delay prevents accidental popups as the mouse is moved to the toolbar. 
								hovModuleActionsPopup.PopDelay        =  250;  // Delay popup remains visible after mouse leaves. 
								hovModuleActionsPopup.HoverDelay      =  500;  // Delay before the popup displays.
								// 11/06/2013 Paul.  Add support for RTL languages. 
								hovModuleActionsPopup.OffsetX         =  L10n.IsLanguageRTL() ? -390 : -1;
								hovModuleActionsPopup.OffsetY         =  -1;
								phHoverControls.Controls.Add(hovModuleActionsPopup);
							}
						}
					}
					else
					{
						HyperLink lnk = new HyperLink();
						lnk.Text        = sDISPLAY_NAME;
						lnk.NavigateUrl = sRELATIVE_PATH;
						lnk.CssClass    = "otherTabMoreLink";
						phMoreInnerCell.Controls.Add(lnk);
					}
				}
			}
			// 01/05/2017 Paul.  Adding Feeds to the tab menu is a configuration option. 
			if ( Sql.ToBoolean(Application["CONFIG.add_feeds_to_menu"]) )
			{
				DataTable dtFeeds = SplendidCache.TabFeeds();
				foreach ( DataRow row in dtFeeds.Rows )
				{
					string sTITLE = Sql.ToString(row["TITLE"]);
					string sURL   = Sql.ToString(row["URL"  ]);
					HyperLink lnk = new HyperLink();
					lnk.Text        = sTITLE;
					lnk.NavigateUrl = sURL;
					lnk.CssClass    = "otherTabMoreLink";
					lnk.Target      = "_blank";
					phMoreInnerCell.Controls.Add(lnk);
				}
			}

			td = new HtmlTableCell();
			tr.Cells.Add(td);
			td.Attributes.Add("valign", "bottom");
			td.Attributes.Add("style" , "DISPLAY: " + ((pnlTabMenuMore.Controls.Count > 0) ? "inline" : "none"));
			
			HtmlTable tblMore = new HtmlTable();
			td.Controls.Add(tblMore);
			tblMore.ID = "tblMore";
			tblMore.Attributes.Add("class"      , "tabFrame");
			tblMore.Attributes.Add("cellspacing", "0" );
			tblMore.Attributes.Add("cellpadding", "0" );
			HtmlTableRow trMore = new HtmlTableRow();
			tblMore.Rows.Add(trMore);
			
			HtmlTableCell tdMore = new HtmlTableCell();
			trMore.Cells.Add(tdMore);
			tdMore.Attributes.Add("class" , "otherTabLeft");
			imgBlank = new Image();
			imgBlank.SkinID = "blank";
			imgBlank.Width  = 5;
			imgBlank.Height = 25;
			// 08/31/2013 Paul.  In .NET 4.0, the default behavior does not set the border width, so do it manually. 
			imgBlank.BorderWidth = 0;
			tdMore.Controls.Add(imgBlank);
			
			tdMore = new HtmlTableCell();
			trMore.Cells.Add(tdMore);
			tdMore.Attributes.Add("class" , "otherTab");
			imgBlank = new Image();
			imgBlank.ID     = "imgTabMenuMore";
			imgBlank.SkinID = "more";
			imgBlank.Width  = 5;
			imgBlank.Height = 25;
			// 08/31/2013 Paul.  In .NET 4.0, the default behavior does not set the border width, so do it manually. 
			imgBlank.BorderWidth = 0;
			tdMore.Controls.Add(imgBlank);
			
			tdMore = new HtmlTableCell();
			trMore.Cells.Add(tdMore);
			tdMore.Attributes.Add("class" , "otherTabRight");
			imgBlank = new Image();
			imgBlank.SkinID = "blank";
			imgBlank.Width  = 5;
			imgBlank.Height = 25;
			// 08/31/2013 Paul.  In .NET 4.0, the default behavior does not set the border width, so do it manually. 
			imgBlank.BorderWidth = 0;
			tdMore.Controls.Add(imgBlank);

			td = new HtmlTableCell();
			tr.Cells.Add(td);
			td.Attributes.Add("width", "100%");
			td.Attributes.Add("class", "tabRow");
			imgBlank = new Image();
			imgBlank.SkinID = "blank";
			imgBlank.Width  = 1;
			imgBlank.Height = 1;
			// 08/31/2013 Paul.  In .NET 4.0, the default behavior does not set the border width, so do it manually. 
			imgBlank.BorderWidth = 0;
			td.Controls.Add(imgBlank);

			// 05/19/2010 Paul.  We don't need the more if there are no additional modules. 
			if ( bAjaxAutoComplete && phMoreInnerCell.Controls.Count > 0 )
			{
				// <ajaxToolkit:HoverMenuExtender TargetControlID="imgTabMenuMore" PopupControlID="pnlTabMenuMore" PopupPosition="Bottom" PopDelay="50" OffsetX="-12" OffsetY="-3" runat="server" />
				AjaxControlToolkit.HoverMenuExtender hovMore = new AjaxControlToolkit.HoverMenuExtender();
				hovMore.TargetControlID = tblMore.ID;
				hovMore.PopupControlID  = pnlTabMenuMore.ID;
				hovMore.PopupPosition   = AjaxControlToolkit.HoverMenuPopupPosition.Bottom;
				// 05/17/2010 Paul.  The hover delay prevents accidental popups as the mouse is moved to the toolbar. 
				hovMore.PopDelay        =  250;  // Delay popup remains visible after mouse leaves. 
				hovMore.HoverDelay      =  500;  // Delay before the popup displays.
				// 11/06/2013 Paul.  Add support for RTL languages. 
				hovMore.OffsetX         =  L10n.IsLanguageRTL() ? -140 : 0;
				hovMore.OffsetY         =   -1;
				phHoverControls.Controls.Add(hovMore);
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			Refresh();
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

