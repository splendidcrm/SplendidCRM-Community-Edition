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

namespace SplendidCRM.EmailClient
{
	/// <summary>
	/// Summary description for Default.
	/// </summary>
	public class Default : SplendidPage
	{
		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( !Sql.IsEmptyString(Security.EXCHANGE_ALIAS) )
				Response.Redirect("~/EmailClient/Exchange/");
			else
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL ;
					sSQL = "select *                    " + ControlChars.CrLf
					     + "  from vwINBOUND_EMAILS     " + ControlChars.CrLf
					     + " where GROUP_ID = @GROUP_ID " + ControlChars.CrLf
					     + " order by SERVICE           " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@GROUP_ID", Security.USER_ID);
						using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
						{
							if ( rdr.Read() )
							{
								string sSERVICE = Sql.ToString(rdr["SERVICE"]);
								if ( String.Compare(sSERVICE, "Exchange", true) == 0 )
									Response.Redirect("~/EmailClient/Exchange/");
								else if ( String.Compare(sSERVICE, "imap", true) == 0 )
									Response.Redirect("~/EmailClient/Imap/");
								else if ( String.Compare(sSERVICE, "pop3", true) == 0 )
									Response.Redirect("~/EmailClient/Pop/");
								else
									Response.Redirect("~/EmailClient/Imap/");
							}
						}
					}
				}
			}
			// 07/30/2010 Paul.  If nothing was found, then redirect to Imap as the preferred email client. 
			Response.Redirect("~/EmailClient/Imap/");
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

