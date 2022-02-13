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
using System.Xml;
using System.Data.Common;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Users
{
	/// <summary>
	/// Summary description for SetTimezone.
	/// </summary>
	public class SetTimezone : SplendidPage
	{
		protected Label        lblError   ;
		protected DropDownList lstTIMEZONE;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Save" )
			{
				try
				{
					//12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
					//string sUSER_PREFERENCES = Sql.ToString(Session["USER_PREFERENCES"]);
					//if ( Sql.IsEmptyString(sUSER_PREFERENCES) )
					//	sUSER_PREFERENCES = "<xml></xml>";
					
					//XmlDocument xml = SplendidInit.InitUserPreferences(sUSER_PREFERENCES);
					//XmlUtil.SetSingleNode(xml, "timezone", lstTIMEZONE.SelectedValue);
					Session["USER_SETTINGS/TIMEZONE"] = lstTIMEZONE.SelectedValue;
					Session["USER_SETTINGS/TIMEZONE/ORIGINAL"] = lstTIMEZONE.SelectedValue;
					
					//SqlProcs.spUSERS_PreferencesUpdate(Security.USER_ID, xml.OuterXml);
					//Session["USER_PREFERENCES"] = xml.OuterXml;
					
					// 12/15/2012 Paul.  Move USER_PREFERENCES to separate fields for easier access on Surface RT. 
					SqlProcs.spUSERS_TimeZoneUpdate(Security.USER_ID, Sql.ToGuid(lstTIMEZONE.SelectedValue));
				}
				catch(Exception ex)
				{
					lblError.Text = ex.Message;
					return;
				}
				string sDefaultModule = Sql.ToString(Application["CONFIG.default_module"]);
				if ( sDefaultModule.StartsWith("~") )
					Response.Redirect(sDefaultModule);
				else if ( !Sql.IsEmptyString(sDefaultModule) )
					Response.Redirect("~/" + sDefaultModule + "/");
				else
					// 06/15/2017 Paul.  Add support for HTML5 Home Page. 
					Response.Redirect(Sql.ToString(Application["Modules.Home.RelativePath"]));
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( !IsPostBack )
			{
				// 03/11/2008 Paul.  Move the primary binding to SplendidPage. 
				//Page DataBind();
				lstTIMEZONE.DataSource = SplendidCache.TimezonesListbox();
				try
				{
					//lstTIMEZONE.SelectedValue = SplendidDefaults.TimeZone().ToLower();
					// 09/01/2008 Paul.  We might have a case issue, so instead of using SelectedValue, manually search. 
					string sDEFAULT_TIMEZONE = SplendidDefaults.TimeZone();
					lstTIMEZONE.DataBind();
					// 08/19/2010 Paul.  We have a function that will do a case-insignificant selection. 
					Utils.SetValue(lstTIMEZONE, sDEFAULT_TIMEZONE);
				}
				catch (Exception ex)
				{
					lblError.Text = ex.Message;
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
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);
		}
		#endregion
	}
}

