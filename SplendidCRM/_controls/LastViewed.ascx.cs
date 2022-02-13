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
using System.Web.UI.WebControls;
using System.Diagnostics;

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for LastViewed.
	/// </summary>
	public class LastViewed : SplendidControl
	{
		protected DataView vwLastViewed;
		protected Repeater ctlRepeater ;

		public void Refresh()
		{
			// 05/04/2010 Paul.  LastViewed may not exist in the theme. 
			if ( ctlRepeater == null )
				return;

			DbProviderFactory dbf = DbProviderFactories.GetFactory();
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
							using ( DataSet ds = new DataSet() )
							{
								using ( DataTable dt = new DataTable("vwTRACKER") )
								{
									ds.Tables.Add(dt);
									// 08/16/2005 Paul.  Instead of TOP, use Fill to restrict the records. 
									int nHistoryMaxViewed = Sql.ToInteger(Application["CONFIG.history_max_viewed"]);
									if ( nHistoryMaxViewed == 0 )
										nHistoryMaxViewed = 10;
									// 10/18/2005 Paul.  Start record should be 0. 
									da.Fill(ds, 0, nHistoryMaxViewed, "vwTRACKER");
									
									// 08/17/2005 Paul.  Oracle is having a problem returning an integer column. 
									DataColumn colROW_NUMBER = dt.Columns.Add("ROW_NUMBER", Type.GetType("System.Int32"));
									int nRowNumber = 1;
									foreach(DataRow row in dt.Rows)
									{
										// 10/18/2005 Paul.  AccessKey must be in range of 1 to 9. 
										row["ROW_NUMBER"] = Math.Min(nRowNumber, 9);
										nRowNumber++;
									}
									vwLastViewed = dt.DefaultView;
									ctlRepeater.DataSource = vwLastViewed ;
									ctlRepeater.DataBind();
								}
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					}
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 12/02/2005 Paul.  Always bind as the repeater does not save its state on postback. 
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

