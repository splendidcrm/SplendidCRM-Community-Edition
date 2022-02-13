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

namespace SplendidCRM.Activities
{
	/// <summary>
	/// Summary description for View.
	/// </summary>
	public class View : SplendidPage
	{
		protected Label     lblError                        ;

		// 10/11/2017 Paul.  Add Archive access right. 
		protected bool?       m_bArchiveView      ;

		public bool ArchiveView()
		{
			if ( !m_bArchiveView.HasValue )
			{
				this.m_bArchiveView = Sql.ToBoolean(Request["ArchiveView"]);
			}
			return m_bArchiveView.Value;
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				Guid gID = Sql.ToGuid(Request["ID"]);
				if ( !Sql.IsEmptyGuid(gID) )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						string sSQL ;
						// 10/11/2017 Paul.  Add Archive access right. 
						sSQL = "select *           " + ControlChars.CrLf
						     + "  from vwACTIVITIES" + (ArchiveView() ? "_ARCHIVE" : String.Empty) + ControlChars.CrLf
						     + " where ID = @ID    " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@ID", gID);
							con.Open();
#if DEBUG
							Page.ClientScript.RegisterClientScriptBlock(System.Type.GetType("System.String"), "SQLCode", Sql.ClientScriptBlock(cmd));
#endif
							using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
							{
								if ( rdr.Read() )
								{
									string sACTIVITY_TYPE = Sql.ToString (rdr["ACTIVITY_TYPE"]);
									if ( !Sql.IsEmptyString(sACTIVITY_TYPE) )
									{
										Response.Redirect("~/" + sACTIVITY_TYPE + "/view.aspx?ID="+ gID.ToString() + (ArchiveView() ? "&ArchiveView=1" : String.Empty));
									}
								}
								lblError.Text = "Activity not found with ID " + gID.ToString();
							}
						}
					}
				}
				if ( !IsPostBack )
				{
					// 06/09/2006 Paul.  The primary data binding will now only occur in the ASPX pages so that this is only one per cycle. 
					// 03/11/2008 Paul.  Move the primary binding to SplendidPage. 
					//Page DataBind();
				}
			}
			catch(Exception ex)
			{
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

