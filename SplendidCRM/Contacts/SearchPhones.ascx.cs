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
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Contacts
{
	/// <summary>
	///		Summary description for SearchPhones.
	/// </summary>
	public class SearchPhones : SplendidControl
	{
		// 05/15/2016 Paul.  Combine ListHeader and DynamicButtons. 
		protected _controls.SubPanelButtons ctlListHeader;

		protected UniqueStringCollection arrSelectFields;
		protected DataView      vwMain         ;
		protected SplendidGrid  grdMain        ;
		protected Label         lblError       ;
		protected bool          bShowCheckboxColumn;

		protected string        sPhoneSearchURL;

		private void Page_Load(object sender, System.EventArgs e)
		{
			// 07/27/2012 Paul.  Match the normalization within database function fnNormalizePhone. 
			string sPhoneNumber = Utils.NormalizePhone(Request["PhoneNumber"]);
			if ( Page.Items.Contains("PhoneNumber") )
			{
				bShowCheckboxColumn = true;
				sPhoneNumber = Sql.ToString(Page.Items["PhoneNumber"]);
			}
			if ( !Sql.IsEmptyString(sPhoneNumber) )
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					// 11/01/2017 Paul.  Use a module-based flag so that Record Level Security is only enabled when needed. 
					m_sVIEW_NAME = "vwPHONE_NUMBERS_CONTACTS";
					sSQL = "select " + Sql.FormatSelectFields(arrSelectFields) + ControlChars.CrLf
					     + Sql.AppendRecordLevelSecurityField(m_sMODULE, "edit", m_sVIEW_NAME)
					     + "  from " + m_sVIEW_NAME + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, m_sMODULE, "list");
						//Sql.AppendParameter(cmd, sPhoneNumber, Sql.SqlFilterMode.Contains, "NORMALIZED_NUMBER");
						SearchBuilder sb = new SearchBuilder(sPhoneNumber, cmd);
						cmd.CommandText += sb.BuildQuery("   and ", "NORMALIZED_NUMBER");
						cmd.CommandText += grdMain.OrderByClause("NAME", "asc");

						if ( bDebug )
							RegisterClientScriptBlock("vwPHONE_NUMBERS_CONTACTS", Sql.ClientScriptBlock(cmd));

						try
						{
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									// 03/10/2014 Paul.  Apply Business Rules to unified search. 
									this.ApplyGridViewRules(m_sMODULE + ".Search", dt);
									
									vwMain = dt.DefaultView;
									grdMain.DataSource = vwMain ;
									// 08/26/2010 Paul.  Hide panel if no results. 
									this.Visible = (dt.Rows.Count > 0);
									if ( this.Visible )
										grdMain.DataBind();
									// 07/08/2012 Paul.  If there is only one, then we might navigate directly to it. 
									if ( dt.Rows.Count == 1 )
										sPhoneSearchURL = "sPhoneSearchURL = \'" + Sql.ToString(Application["rootURL"]) + m_sMODULE + "/view.aspx?ID=" + Sql.ToString(dt.Rows[0]["ID"]) + "&PhoneNumber=" + Server.UrlEncode(sPhoneNumber) + "\';";
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							lblError.Text = ex.Message;
						}
					}
				}
				ctlListHeader.Visible = true;
			}
			else
			{
				ctlListHeader.Visible = false;
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
			m_sMODULE = "Contacts";
			arrSelectFields = new UniqueStringCollection();
			arrSelectFields.Add("ID"               );
			arrSelectFields.Add("NAME"             );
			arrSelectFields.Add("ASSIGNED_USER_ID" );
			arrSelectFields.Add("NORMALIZED_NUMBER");
			this.AppendGridColumns(grdMain, m_sMODULE + ".SearchPhones", arrSelectFields);
		}
		#endregion
	}
}

