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
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Xml;

namespace SplendidCRM.Administration.Backups
{
	/// <summary>
	///		Summary description for ListView.
	/// </summary>
	public class ListView : SplendidControl
	{
		protected Label        lblError       ;
		protected TextBox      NAME           ;
		protected RequiredFieldValidator NAME_REQUIRED;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "Next" )
			{
				NAME.Text = NAME.Text.Trim();
				// 12/31/2007 Paul.  The NAME is not required.  If not provided, it will be generated. 
				//NAME_REQUIRED.Enabled = true;
				//NAME_REQUIRED.Validate();
				if ( Page.IsValid )
				{
					try
					{
						// 01/28/2008 Paul.  Cannot perform a backup or restore operation within a transaction. BACKUP DATABASE is terminating abnormally.
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							string sFILENAME = String.Empty;
							string sTYPE     = "FULL";
							//SqlProcs.spSqlBackupDatabase(ref sNAME, "FULL");
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandType = CommandType.StoredProcedure;
								cmd.CommandText = "spSqlBackupDatabase";
								// 02/09/2008 Paul.  A database backup can take a long time.  Don't timeout. 
								cmd.CommandTimeout = 0;
								IDbDataParameter parFILENAME = Sql.AddParameter(cmd, "@FILENAME", sFILENAME  , 255);
								IDbDataParameter parTYPE     = Sql.AddParameter(cmd, "@TYPE"    , sTYPE      ,  20);
								parFILENAME.Direction = ParameterDirection.InputOutput;
								cmd.ExecuteNonQuery();
								sFILENAME = Sql.ToString(parFILENAME.Value);
							}
							lblError.Text = L10n.Term("Administration.LBL_DONE") + " " + sFILENAME;
							SplendidError.SystemMessage(Context, "Information", new StackTrace(true).GetFrame(0), "Database backup complete " + sFILENAME);
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						lblError.Text = ex.Message;
						return;
					}
				}
			}
			else if ( e.CommandName == "Back" )
			{
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term("Administration.LBL_MODULE_NAME"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = SplendidCRM.Security.IS_ADMIN;
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			NAME_REQUIRED.DataBind();
			if ( !IsPostBack )
			{
				NAME.Text = "SplendidCRM_db_" + DateTime.Now.ToString("yyyyMMddHHmm") + ".bak";
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
			m_sMODULE = "Administration";
			// 05/06/2010 Paul.  The menu will show the admin Module Name in the Six theme. 
			SetMenu(m_sMODULE);
		}
		#endregion
	}
}

