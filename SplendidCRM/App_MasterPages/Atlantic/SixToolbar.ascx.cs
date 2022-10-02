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
using System.IO;
using System.Data;
using System.Data.Common;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Themes.Atlantic
{
	/// <summary>
	///		Summary description for SixToolbar.
	/// </summary>
	public class SixToolbar : SplendidControl
	{
		protected PlaceHolder plcSubPanel         ;
		protected PlaceHolder plcDynamicNewRecords;
		protected Panel       cntUnifiedSearch    ;
		protected HiddenField hidDynamicNewRecord ;
		protected TextBox     txtUnifiedSearch    ;
		protected ImageButton btnUnifiedSearch    ;
		// 08/14/2020 Paul.  Hide Quick Create hover if nothing to display. 
		protected HtmlTable   tabToolbarQuickCreate;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Admin.Reload" )
			{
				if( Security.IS_ADMIN )
				{
					// 10/26/2008 Paul.  IIS7 Integrated Pipeline does not allow HttpContext access inside Application_Start. 
					SplendidInit.InitApp(HttpContext.Current);
					// 11/17/2007 Paul.  New function to determine if user is authenticated. 
					if ( Security.IsAuthenticated() )
						SplendidInit.LoadUserPreferences(Security.USER_ID, Sql.ToString(Session["USER_SETTINGS/THEME"]), Sql.ToString(Session["USER_SETTINGS/CULTURE"]));
					// 06/30/2007 Paul.  Perform a redirect so that the entire page will reload and rebind. 
					Response.Redirect(Request.RawUrl);
				}
			}
			else if ( e.CommandName == "Toolbar.Show" )
			{
				plcDynamicNewRecords.Controls.Clear();
				string[] arrArguments = Sql.ToString(e.CommandArgument).Split('|');
				if ( arrArguments.Length == 3 )
				{
					string sMODULE_NAME    = arrArguments[0];
					string sCONTROL_NAME   = arrArguments[1];
					string sALTERNATE_VIEW = arrArguments[2];
					Control ctl = LoadControl(sCONTROL_NAME + ".ascx");
					NewRecordControl ctlNewRecord = ctl as NewRecordControl;
					if ( ctlNewRecord != null )
					{
						// 07/15/2017 Paul.  Request["ID"] might not be a valid ID, so we need a safe convert and not an exception. 
						Guid   gPARENT_ID   = Sql.ToGuidSafe(Request["ID"]);
						string sPARENT_TYPE = Sql.ToString(Page.Items["ActiveTabMenu"]);
						
						HtmlTable tbl = new HtmlTable();
						plcDynamicNewRecords.Controls.Add(tbl);
						tbl.Width       = "100%";
						tbl.CellPadding = 0;
						tbl.CellSpacing = 0;
						HtmlTableRow tr = new HtmlTableRow();
						tbl.Rows.Add(tr);
						HtmlTableCell td = new HtmlTableCell();
						tr.Cells.Add(td);
						td.Attributes.Add("class", "ToolbarInnerTableCell");
						
						ctlNewRecord.ID                = "ctlDynamicNewRecord" + sMODULE_NAME;
						ctlNewRecord.EditView          = sALTERNATE_VIEW;
						ctlNewRecord.ShowHeader        = false;
						ctlNewRecord.ShowInlineHeader  = true ;
						ctlNewRecord.ShowTopButtons    = true ;
						ctlNewRecord.ShowBottomButtons = false;
						ctlNewRecord.ShowCancel        = true ;
						ctlNewRecord.PARENT_ID         = gPARENT_ID  ;
						ctlNewRecord.PARENT_TYPE       = sPARENT_TYPE;
						ctlNewRecord.Command          += new CommandEventHandler(Page_Command);
						
						// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
						ctlNewRecord.NotPostBack = true;
						td.Controls.Add(ctlNewRecord);
						// 05/16/2010 Paul.  The ViewState is not working for dynamic NewRecord controls in the toolbar, so store in the hidden field. 
						hidDynamicNewRecord.Value = Sql.ToString(e.CommandArgument + "|" + sPARENT_TYPE + "|" + gPARENT_ID.ToString());
					}
				}
			}
			else if ( e.CommandName == "NewRecord" )
			{
				plcDynamicNewRecords.Controls.Clear();
				// 05/16/2010 Paul.  We need the subpanels to be updated, so lets require the page. 
				Response.Redirect(Request.RawUrl);
			}
			else if ( e.CommandName == "Save" || e.CommandName == "Send" )
			{
				plcDynamicNewRecords.Controls.Clear();
			}
			else if ( e.CommandName == "NewRecord.Cancel" || e.CommandName == "Cancel" )
			{
				plcDynamicNewRecords.Controls.Clear();
			}
		}
		
		// 06/13/2010 Paul.  Use the new keyword as we are replacing the functionality of a method in the base class. 
		// 08/14/2020 Paul.  Hide Quick Create hover if nothing to display. 
		new protected int AppendEditViewRelationships(string sEDIT_NAME, PlaceHolder plc, bool bNewRecord)
		{
			// 07/15/2017 Paul.  Request["ID"] might not be a valid ID, so we need a safe convert and not an exception. 
			Guid   gPARENT_ID   = Sql.ToGuidSafe(Request["ID"]);
			string sPARENT_TYPE = Sql.ToString(Page.Items["ActiveTabMenu"]);
			DataTable dtFields = SplendidCache.EditViewRelationships(sEDIT_NAME, bNewRecord);
			foreach(DataRow row in dtFields.Rows)
			{
				string sMODULE_NAME    = Sql.ToString(row["MODULE_NAME"   ]);
				string sCONTROL_NAME   = Sql.ToString(row["CONTROL_NAME"  ]);
				string sALTERNATE_VIEW = Sql.ToString(row["ALTERNATE_VIEW"]);
				if ( Sql.IsEmptyString(sALTERNATE_VIEW) )
					sALTERNATE_VIEW = "EditView.Inline";
				// 04/19/2010 Paul.  Only add the control if the user has access. 
				if ( Security.GetUserAccess(sMODULE_NAME, "edit") >= 0 )
				{
					try
					{
						LinkButton lnkQuickCreate = new LinkButton();
						lnkQuickCreate.ID              = "lnkQuickCreate" + sMODULE_NAME;
						lnkQuickCreate.Command        += new CommandEventHandler(Page_Command);
						lnkQuickCreate.CommandName     = "Toolbar.Show";
						lnkQuickCreate.CommandArgument = sMODULE_NAME + "|" + sCONTROL_NAME + "|" + sALTERNATE_VIEW;
						lnkQuickCreate.ToolTip         = L10n.Term(".moduleList." + sMODULE_NAME);
						lnkQuickCreate.Text            = L10n.Term(sMODULE_NAME + ".LNK_NEW_" + Crm.Modules.SingularTableName(Crm.Modules.TableName(sMODULE_NAME)));
						// 08/21/2022 Paul.  Only difference for Pacific is the home image. 
						if ( this.Page.Theme == "Pacific" )
							lnkQuickCreate.CssClass        = "QuickCreateOtherButton";
						else
							lnkQuickCreate.CssClass        = "ModuleActionsMenuItems";
						plc.Controls.Add(lnkQuickCreate);
					}
					catch(Exception ex)
					{
						Label lblError = new Label();
						// 06/09/2006 Paul.  Catch the error and display a message instead of crashing. 
						// 12/27/2008 Paul.  Don't specify an ID as there can be multiple errors. 
						lblError.Text            = Utils.ExpandException(ex) + " " + ex.StackTrace;
						lblError.ForeColor       = System.Drawing.Color.Red;
						lblError.EnableViewState = false;
						plc.Controls.Add(lblError);
					}
				}
			}
			return dtFields.Rows.Count;
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( !IsPostBack )
			{
				// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
				//Page.DataBind();
				// 04/28/2006 Paul.  If the user has not authenticated, then this must be during login.  Disable the search. 
				// 11/17/2007 Paul.  New function to determine if user is authenticated. 
				// 05/11/2010 Paul.  Toolbar should only be visible if we are authenticated. 
				// 10/09/2010 Paul.  Provide a way to hide the Six toolbar. 
				// 11/30/2012 Paul.  hide_theme_toolbar does not apply to the Atlantic theme. 
				// 12/26/2009 Paul.  The objects may not exist, so catch any errors. 
				try
				{
					this.Visible = Security.IsAuthenticated();
					if ( !Security.IsAuthenticated() )
					{
						if ( cntUnifiedSearch != null )
						{
							cntUnifiedSearch.Visible = false;
						}
					}
					// 10/20/2015 Paul.  The theme code is now shared with portal, so we need to manually hide things on the portal. 
					if ( PortalCache.IsPortal() )
						cntUnifiedSearch.Visible = false;
				}
				catch
				{
				}
			}
			// 06/21/2009 Paul.  Move EnterKey processing to code-behind.  We don't need to use the AJAX Script manager because this code will not be part of an UpdatePanel. 
			// 06/21/2009 Paul.  Use RegisterStartupScript instead of RegisterClientScriptBlock so that the script will run after the control has been created. 
			// 07/14/2009 Paul.  Make sure not to register if the txtUnifiedSearch is not visible, otherwise a client-side exception will be thrown on the login page. 
			// 12/26/2009 Paul.  The objects may not exist, so catch any errors. 
			try
			{
				if ( cntUnifiedSearch != null && txtUnifiedSearch != null && btnUnifiedSearch != null )
				{
					if ( cntUnifiedSearch.Visible )
					{
						Page.ClientScript.RegisterStartupScript(typeof(System.String), txtUnifiedSearch.ClientID + "_EnterKey", Utils.RegisterEnterKeyPress(txtUnifiedSearch.ClientID, btnUnifiedSearch.ClientID));
						// 08/31/2012 Paul.  Apple and Android devices should support speech and handwriting. 
						if ( Utils.SupportsSpeech && Sql.ToBoolean(Application["CONFIG.enable_speech"]) )
						{
							txtUnifiedSearch.Attributes.Add("speech", "speech");
							txtUnifiedSearch.Attributes.Add("x-webkit-speech", "x-webkit-speech");
						}
					}
				}
			}
			catch
			{
			}
			ScriptManager mgrAjax = ScriptManager.GetCurrent(this.Page);
			// 11/23/2009 Paul.  SplendidCRM 4.0 is very slow on Blackberry devices.  Lets try and turn off AJAX AutoComplete. 
			bool bAjaxAutoComplete = (mgrAjax != null);
			if ( this.IsMobile )
			{
				// 11/24/2010 Paul.  .NET 4 has broken the compatibility of the browser file system. 
				// We are going to minimize our reliance on browser files in order to reduce deployment issues. 
				bAjaxAutoComplete = Utils.AllowAutoComplete && (mgrAjax != null);
			}
			if ( bAjaxAutoComplete )
			{
				// 05/06/2010 Paul.  File IO is expensive, so cache the results of the Exists test. 
				// 08/25/2013 Paul.  File IO is slow, so cache existance test. 
				if ( Utils.CachedFileExists(Context, "~/KBDocuments/KBTags/AutoComplete.asmx") )
				{
					// 05/12/2016 Paul.  Move AddScriptReference and AddStyleSheet to Sql object. 
					Sql.AddServiceReference(mgrAjax, "~/KBDocuments/KBTags/AutoComplete.asmx");
					Sql.AddScriptReference (mgrAjax, "~/KBDocuments/KBTags/AutoComplete.js"  );
				}
				
				// 05/06/2010 Paul.  File IO is expensive, so cache the results of the Exists test. 
				// 08/25/2013 Paul.  File IO is slow, so cache existance test. 
				if ( SplendidCRM.Crm.Config.enable_team_management() &&  Utils.CachedFileExists(Context, "~/Administration/Teams/AutoComplete.asmx") )
				{
					// 05/12/2016 Paul.  Move AddScriptReference and AddStyleSheet to Sql object. 
					Sql.AddServiceReference(mgrAjax, "~/Administration/Teams/AutoComplete.asmx");
					Sql.AddScriptReference (mgrAjax, "~/Administration/Teams/AutoComplete.js"  );
				}
				// 05/12/2016 Paul.  Add Tags module.  It is effectively global, so always include. 
				Sql.AddServiceReference(mgrAjax, "~/Administration/Tags/AutoComplete.asmx");
				Sql.AddScriptReference (mgrAjax, "~/Administration/Tags/AutoComplete.js"  );
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
			GetL10n();
			this.Load += new System.EventHandler(this.Page_Load);
			int nQuickCreateItems = AppendEditViewRelationships("Home.EditView", plcSubPanel, true);
			// 08/14/2020 Paul.  Hide Quick Create hover if nothing to display. 
			if ( nQuickCreateItems == 0 && tabToolbarQuickCreate != null )
			{
				tabToolbarQuickCreate.Visible = false;
			}
			
			// 05/16/2010 Paul.  The ViewState is not working for dynamic NewRecord controls in the toolbar, so store in the hidden field. 
			string[] arrArguments = Sql.ToString(Request[hidDynamicNewRecord.UniqueID]).Split('|');
			if ( arrArguments.Length == 5 )
			{
				string sMODULE_NAME    = arrArguments[0];
				string sCONTROL_NAME   = arrArguments[1];
				string sALTERNATE_VIEW = arrArguments[2];
				string sPARENT_TYPE    = arrArguments[3];
				Guid   gPARENT_ID      = Sql.ToGuid(arrArguments[4]);
				Control ctl = LoadControl(sCONTROL_NAME + ".ascx");
				NewRecordControl ctlNewRecord = ctl as NewRecordControl;
				if ( ctlNewRecord != null )
				{
					HtmlTable tbl = new HtmlTable();
					plcDynamicNewRecords.Controls.Add(tbl);
					tbl.Width       = "100%";
					tbl.CellPadding = 0;
					tbl.CellSpacing = 0;
					HtmlTableRow tr = new HtmlTableRow();
					tbl.Rows.Add(tr);
					HtmlTableCell td = new HtmlTableCell();
					tr.Cells.Add(td);
					td.Attributes.Add("class", "ToolbarInnerTableCell");
					
					ctlNewRecord.ID                = "ctlDynamicNewRecord" + sMODULE_NAME;
					ctlNewRecord.EditView          = sALTERNATE_VIEW;
					ctlNewRecord.ShowHeader        = false;
					ctlNewRecord.ShowInlineHeader  = true ;
					ctlNewRecord.ShowTopButtons    = true ;
					ctlNewRecord.ShowBottomButtons = false;
					ctlNewRecord.ShowCancel        = true ;
					// 05/16/2010 Paul.  The ViewState is not working for dynamic NewRecord controls in the toolbar, so store in the hidden field. 
					ctlNewRecord.PARENT_ID         = gPARENT_ID  ;
					ctlNewRecord.PARENT_TYPE       = sPARENT_TYPE;
					ctlNewRecord.Command          += new CommandEventHandler(Page_Command);
					td.Controls.Add(ctlNewRecord);
				}
			}
		}
		#endregion
	}
}

