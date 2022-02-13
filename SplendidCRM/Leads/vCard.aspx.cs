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
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Xml;
using System.Diagnostics;

namespace SplendidCRM.Leads
{
	/// <summary>
	/// Summary description for vCard.
	/// </summary>
	public class vCard : SplendidPage
	{
		protected Guid   gID       ;
		protected string m_sMODULE = "Leads";

		private void Page_Load(object sender, System.EventArgs e)
		{
			Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			try
			{
				if ( !IsPostBack )
				{
					gID = Sql.ToGuid(Request["ID"]);
					string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
					if ( !Sql.IsEmptyGuid(gID) && !Sql.IsEmptyString(sTABLE_NAME) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL;
							sSQL = "select *               " + ControlChars.CrLf
							     + "  from vw" + sTABLE_NAME + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Security.Filter(cmd, m_sMODULE, "view");
								Sql.AppendParameter(cmd, gID, "ID");
								con.Open();

								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dt = new DataTable() )
									{
										da.Fill(dt);
										if ( dt.Rows.Count > 0 )
										{
											DataRow row = dt.Rows[0];
											string sNAME           = Sql.ToString(row["NAME"]).Trim();
											Guid gASSIGNED_USER_ID = Sql.ToGuid(row["ASSIGNED_USER_ID"]);
											foreach ( DataColumn col in dt.Columns )
											{
												if ( SplendidInit.bEnableACLFieldSecurity )
												{
													Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(m_sMODULE, col.ColumnName, gASSIGNED_USER_ID);
													if ( !acl.IsReadable() )
													{
														row[col.Ordinal] = DBNull.Value;
													}
												}
											}
											string sVCard = Utils.GenerateVCard(row);
											
											Response.ContentEncoding = System.Text.UTF8Encoding.UTF8;
											Response.ContentType     = "text/x-vcard";
											Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(Request.Browser, sNAME + ".vcf"));
											Response.Write(sVCard);
											Response.Flush();
										}
									}
								}
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				Response.Write(ex.Message);
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

