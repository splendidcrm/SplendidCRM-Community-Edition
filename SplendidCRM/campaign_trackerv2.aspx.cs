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
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for campaign_trackerv2.
	/// </summary>
	public class campaign_trackerv2 : SplendidPage
	{
		// 01/25/2008 Paul.  This page must be accessible without authentication. 
		override protected bool AuthenticationRequired()
		{
			return false;
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 04/11/2008 Paul.  Expire immediately so that all clicks are counted. 
			Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);

			SplendidError.SystemMessage("Log", new StackTrace(true).GetFrame(0), "Campaign Tracker v2 " + Request["identifier"] + ", " + Request["track"]);
			Guid gID      = Sql.ToGuid(Request["identifier"]);
			Guid gTrackID = Sql.ToGuid(Request["track"     ]);
			try
			{
				if ( !Sql.IsEmptyGuid(gID) )
				{
					Guid   gTARGET_ID   = Guid.Empty;
					string sTARGET_TYPE = string.Empty;
					SqlProcs.spCAMPAIGN_LOG_UpdateTracker(gID, "link", gTrackID, ref gTARGET_ID, ref sTARGET_TYPE);
				}
				else
				{
					// 09/10/2007 Paul.  Web campaigns will not have an identifier. 
					SqlProcs.spCAMPAIGN_LOG_BannerTracker("link", gTrackID, Request.UserHostAddress);
				}
				if ( !Sql.IsEmptyGuid(gTrackID) )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sSQL ;
						sSQL = "select TRACKER_URL     " + ControlChars.CrLf
						     + "  from vwCAMPAIGN_TRKRS" + ControlChars.CrLf
						     + " where ID = @ID        " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@ID", gTrackID);
							string sTRACKER_URL = Sql.ToString(cmd.ExecuteScalar());
							if ( !Sql.IsEmptyString(sTRACKER_URL) )
								Response.Redirect(sTRACKER_URL);
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
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

