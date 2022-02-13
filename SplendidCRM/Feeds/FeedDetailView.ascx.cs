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
using System.Net;
using System.Xml;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics;

namespace SplendidCRM.Feeds
{
	/// <summary>
	///		Summary description for FeedDetailView.
	/// </summary>
	public class FeedDetailView : SplendidControl
	{
		protected string    sChannelTitle ;
		protected string    sChannelLink  ;
		protected string    sLastBuildDate;
		protected string    sURL          ;
		protected DataGrid  grdMain       ;
		protected DataTable dtChannel     ;
		protected DataTable dtItems       ;

		public string URL
		{
			get
			{
				return sURL;
			}
			set
			{
				sURL = value;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				// 02/11/2009 Paul.  Prevent any errors when page is viewed as part of a precompile. 
				if ( !Sql.IsEmptyString(sURL) )
				{
					// 12/06/2005 Paul.  Can't use the DataSet reader because it returns the following error:
					// The same table (description) cannot be the child table in two nested relations, caused by News.com feed. 
					XmlDocument xml = new XmlDocument();
					// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
					// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
					// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
					xml.XmlResolver = null;
					xml.Load(sURL);
					sChannelTitle  = XmlUtil.SelectSingleNode(xml, "channel/title"        );
					sChannelLink   = XmlUtil.SelectSingleNode(xml, "channel/link"         );
					sLastBuildDate = XmlUtil.SelectSingleNode(xml, "channel/lastBuildDate");

					dtItems = new DataTable();
					DataColumn colTitle       = new DataColumn("title"      , Type.GetType("System.String"));
					DataColumn colLink        = new DataColumn("link"       , Type.GetType("System.String"));
					DataColumn colDescription = new DataColumn("description", Type.GetType("System.String"));
					DataColumn colCategory    = new DataColumn("category"   , Type.GetType("System.String"));
					DataColumn colPubDate     = new DataColumn("pubDate"    , Type.GetType("System.String"));
					dtItems.Columns.Add(colTitle      );
					dtItems.Columns.Add(colLink       );
					dtItems.Columns.Add(colDescription);
					dtItems.Columns.Add(colCategory   );
					dtItems.Columns.Add(colPubDate    );
					try
					{
						XmlNodeList nl = xml.DocumentElement.SelectNodes("channel/item");
						foreach(XmlNode item in nl)
						{
							DataRow row = dtItems.NewRow();
							dtItems.Rows.Add(row);
							row["title"      ] = XmlUtil.SelectSingleNode(item, "title"      );
							row["link"       ] = XmlUtil.SelectSingleNode(item, "link"       );
							row["description"] = XmlUtil.SelectSingleNode(item, "description");
							row["category"   ] = XmlUtil.SelectSingleNode(item, "category"   );
							row["pubDate"    ] = XmlUtil.SelectSingleNode(item, "pubDate"    );
						}
						grdMain.DataSource = dtItems;
						grdMain.DataBind();
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						// Ignore errors for now. 
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				Response.Write(ex.Message);
			}
			// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
			//Page.DataBind();
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

