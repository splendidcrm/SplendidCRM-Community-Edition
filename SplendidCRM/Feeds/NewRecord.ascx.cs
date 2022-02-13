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
using System.Data;
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Feeds
{
	/// <summary>
	///		Summary description for New.
	/// </summary>
	public class NewRecord : SplendidControl
	{
		protected Label                      lblError;
		protected TextBox                    txtURL  ;
		protected RequiredFieldValidator     reqURL  ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "NewRecord" )
			{
				reqURL.Enabled = true;
				reqURL.Validate();
				if ( Page.IsValid )
				{
					try
					{
						// 03/13/2007 Paul.  Pull the XML processing outside the database transaction.  
						// It is not a good idea to lock the database while waiting for the XML file to download. 
						// 07/15/2006 Paul.  Require HTTP protocol to prevent user from trying to access the file system. 
						if ( !txtURL.Text.ToLower().StartsWith("http://") && !txtURL.Text.ToLower().StartsWith("https://") )
							throw(new Exception("Invalid URL."));
						// 12/06/2005 Paul.  Can't use the DataSet reader because it returns the following error:
						// The same table (description) cannot be the child table in two nested relations, caused by News.com feed. 
						XmlDocument xml = new XmlDocument();
						// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
						// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
						// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
						xml.XmlResolver = null;
						xml.Load(txtURL.Text);

						Guid gID = Guid.Empty;
						// 11/22/2006 Paul.  Use a transaction because we added team management. 
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									string sTITLE       = XmlUtil.SelectSingleNode(xml, "channel/title"      );
									string sDESCRIPTION = XmlUtil.SelectSingleNode(xml, "channel/description");
									// 12/29/2007 Paul.  TEAM_ID is now in the stored procedure. 
									SqlProcs.spFEEDS_Update
										( ref gID
										, Security.USER_ID
										, sTITLE
										, sDESCRIPTION
										, txtURL.Text
										, Security.TEAM_ID
										, String.Empty     // TEAM_SET_LIST
										// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
										, String.Empty     // ASSIGNED_SET_LIST
										, trn
										);
									// 01/31/2007 Paul.  The transaction was not being committed. 
									trn.Commit();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									throw(new Exception(ex.Message));
								}
							}
						}
						if ( !Sql.IsEmptyGuid(gID) )
							Response.Redirect("~/Feeds/view.aspx?ID=" + gID.ToString());
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						lblError.Text = ex.Message;
					}
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 06/04/2006 Paul.  NewRecord should not be displayed if the user does not have edit rights. 
			// 01/02/2020 Paul.  Allow the NewRecord to be disabled per module using config table. 
			this.Visible = !Sql.ToBoolean(Application["CONFIG." + m_sMODULE + ".DisableNewRecord"]) && (SplendidCRM.Security.GetUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
				return;

			// 06/09/2006 Paul.  Remove data binding in the user controls.  Binding is required, but only do so in the ASPX pages. 
			//this.DataBind();  // Need to bind so that Text of the Button gets updated. 
			reqURL.ErrorMessage = L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("Feeds.LBL_RSS_URL") + "<br>";
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
			m_sMODULE = "Feeds";
		}
		#endregion
	}
}

