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
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Reflection;

namespace SplendidCRM.Home
{
	/// <summary>
	///		Summary description for AboutSugarCRM.
	/// </summary>
	public class AboutSugarCRM : SplendidControl
	{
		protected Label         lblError        ;
		protected Label         lblVersionNumber;
		protected Label         lblBuildNumber  ;
		protected Label         lblLicense      ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			try
			{
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".LBL_BROWSER_TITLE"));
			if ( !IsPostBack )
			{
				//Assembly asm = Assembly.GetExecutingAssembly();
				// 11/23/2010 Paul.  The Sugar version has been removed. 
				if ( lblVersionNumber != null )
					lblVersionNumber.Text = Sql.ToString(Application["CONFIG.sugar_version"]);
				// 10/06/2009 Paul.  The Splendid Version is already in the Application cache, so the assembly does not need to be loaded. 
				if ( lblBuildNumber != null )
					lblBuildNumber.Text = Sql.ToString(Application["SplendidVersion"]);
				string sServiceLevel = Sql.ToString(Application["CONFIG.service_level"]);
				if ( lblLicense != null )
				{
					if ( String.Compare(sServiceLevel, "Community", true) == 0 )
						lblLicense.Text = Sql.ToString(Application["CONFIG.gnu_license"]);
					else
						lblLicense.Text = Sql.ToString(Application["CONFIG.license"]);
				}
				// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
				//Page.DataBind();
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

