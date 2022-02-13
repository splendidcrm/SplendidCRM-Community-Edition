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

namespace SplendidCRM.Administration
{
	/// <summary>
	///		Summary description for StudioView.
	/// </summary>
	public class StudioView : SplendidControl
	{
		protected Label     lblError;
		protected Image     imgMODULE_BUILDER;
		protected HyperLink lnkMODULE_BUILDER;
		protected Label     lblMODULE_BUILDER;
		protected LinkButton lnkUpdateModel;

		// 09/11/2007 Paul.  Provide quick access to team management flags. 
		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "System.RebuildAudit" )
				{
					// 12/31/2007 Paul.  In case there is a problem, we need a way to rebuild the audit tables and triggers. 
					// 12/02/2009 Paul.  Use a special version of spSqlBuildAllAuditTables that does not timeout. 
					// 02/18/2021 Paul.  Rebuild audit tables in the background. 
					if ( Application["System.RebuildAudit.Start"] == null )
					{
						System.Threading.Thread t = new System.Threading.Thread(Utils.BuildAllAuditTables);
						t.Start(this.Context);
						lblError.Text = L10n.Term(".LBL_BACKGROUND_OPERATION");
					}
					else
					{
						lblError.Text = "Already started at " + Sql.ToString(Application["System.RebuildAudit.Start"]);
					}
				}
				else if ( e.CommandName == "System.RecompileViews" )
				{
					// 12/31/2007 Paul.  Use a special version of spSqlRefreshAllViews that does not timeout. 
					//Utils.RefreshAllViews();
					// 03/11/2016 Paul.  Recompile in the background, then update the Semantic Model. 
					if ( Application["System.Recompile.Start"] == null )
					{
						// 10/31/2021 Paul.  Moved RecompileViews to ModuleUtils. 
						System.Threading.Thread t = new System.Threading.Thread(ModuleUtils.EditCustomFields.RecompileViews);
						t.Start(this.Context);
					}
					else
					{
						Application["System.Recompile.Restart"] = true;
					}
				}
				else if ( e.CommandName == "System.UpdateModel" )
				{
					// 12/12/2009 Paul.  Use a special version of spSEMANTIC_MODEL_Rebuild that does not timeout. 
					Utils.UpdateSemanticModel(this.Context);
				}
				else if ( e.CommandName == "System.Reload" )
				{
					// 01/18/2008 Paul.  Speed the reload by doing directly instead of going to SystemCheck page. 
					// 10/26/2008 Paul.  IIS7 Integrated Pipeline does not allow HttpContext access inside Application_Start. 
					SplendidInit.InitApp(HttpContext.Current);
					SplendidInit.LoadUserPreferences(Security.USER_ID, Sql.ToString(Session["USER_SETTINGS/THEME"]), Sql.ToString(Session["USER_SETTINGS/CULTURE"]));
				}
				// 09/11/2009 Paul.  Make it easy to enable and disable custom paging. 
				else if ( e.CommandName == "CustomPaging.Enable"   )
				{
					SqlProcs.spCONFIG_Update("system", "allow_custom_paging", "true");
					Application["CONFIG.allow_custom_paging"] = true;
				}
				else if ( e.CommandName == "CustomPaging.Disable"  )
				{
					SqlProcs.spCONFIG_Update("system", "allow_custom_paging", "false");
					Application["CONFIG.allow_custom_paging"] = false;
				}
				// 07/06/2021 Paul.  Provide an quick and easy way to enable/disable React client. 
				else if ( e.CommandName == "ReactClient.Enable" )
				{
					SqlProcs.spMODULES_UpdateRelativePath("Home", "~/React/Home");
					Application["Modules.Home.RelativePath"] = "~/React/Home";
				}
				else if ( e.CommandName == "ReactClient.Disable" )
				{
					SqlProcs.spMODULES_UpdateRelativePath("Home", "~/Home");
					Application["Modules.Home.RelativePath"] = "~/Home";
				}
				Response.Redirect("default.aspx");
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( !IsPostBack )
			{
				// 09/12/2009 Paul.  Only show the module builder if the files exist. 
				// 03/08/2010 Paul.  The Module Builder can be disabled in the Web.config. 
				// 08/25/2013 Paul.  File IO is slow, so cache existance test. 
				imgMODULE_BUILDER.Visible = Utils.CachedFileExists(Context, lnkMODULE_BUILDER.NavigateUrl) && !Sql.ToBoolean(Utils.AppSettings["DisableModuleBuilder"]);
				lnkMODULE_BUILDER.Visible = imgMODULE_BUILDER.Visible;
				lblMODULE_BUILDER.Visible = imgMODULE_BUILDER.Visible;

				// 12/12/2009 Paul.  Only show update model link if this is the Enterprise or Professional edition. 
				// 08/07/2013 Paul.  The Semantic Model is not being supported. 
				//string sServiceLevel = Sql.ToString(Application["CONFIG.service_level"]).ToLower();
				//lnkUpdateModel.Visible = (sServiceLevel == "enterprise" || sServiceLevel == "professional");
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

