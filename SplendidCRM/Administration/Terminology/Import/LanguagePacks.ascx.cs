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
using System.Xml;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Administration.Terminology.Import
{
	/// <summary>
	///		Summary description for LanguagePacks.
	/// </summary>
	public class LanguagePacks : SplendidControl
	{
		protected DataView        vwMain         ;
		protected SplendidGrid    grdMain        ;
		protected Label           lblError       ;

		public CommandEventHandler Command ;

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			if ( Command != null )
				Command(this, e) ;
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "import") >= 0);
			if ( !this.Visible )
				return;
			try
			{
				// 10/27/2008 Paul.  Skip during precompile. 
				if ( !Sql.ToBoolean(Request["PrecompileOnly"]) )
				{
					DataTable dt = Cache.Get("PublicSugarCRMLanguagePacks.xml") as DataTable;
					if ( dt == null )
					{
						XmlDocument xml = new XmlDocument();
						// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
						// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
						// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
						xml.XmlResolver = null;
						// 12/24/2008 Paul.  The data needs to be loaded every time. 
						try
						{
#if DEBUG
							xml.Load(Server.MapPath("PublicSugarCRMLanguagePacks.xml"));
#else
							xml.Load("http://demo.splendidcrm.com/Administration/Terminology/Import/PublicSugarCRMLanguagePacks.xml");
#endif
						}
						catch
						{
							xml.Load(Server.MapPath("PublicSugarCRMLanguagePacks.xml"));
						}
						dt = XmlUtil.CreateDataTable(xml.DocumentElement, "LanguagePack", new string[] {"Name", "Date", "Description", "URL"});
						Cache.Insert("PublicSugarCRMLanguagePacks.xml", dt, null, DateTime.Now.AddHours(1), System.Web.Caching.Cache.NoSlidingExpiration);
					}

					vwMain = new DataView(dt);
					vwMain.RowFilter = "URL > ''";
					vwMain.Sort      = "Name";
					grdMain.DataSource = vwMain ;
					// 12/24/2008 Paul.  We need to rebind every time.  Pagination will still work. 
					//if ( !IsPostBack )
					{
						grdMain.DataBind();
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
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
			m_sMODULE = "Terminology";
		}
		#endregion
	}
}

