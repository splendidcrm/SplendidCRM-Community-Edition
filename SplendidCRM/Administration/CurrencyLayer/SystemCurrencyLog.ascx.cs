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

namespace SplendidCRM.Administration.CurrencyLayer
{
	/// <summary>
	///		Summary description for SystemCurrencyLog.
	/// </summary>
	public class SystemCurrencyLog : SplendidControl
	{
		protected _controls.DynamicButtons ctlDynamicButtons;
		protected DataView        vwMain         ;
		protected SplendidGrid    grdMain        ;
		protected Label           lblError       ;
		public    string          DestinationISO4217 { get; set; }

		protected void Page_Command(object sender, CommandEventArgs e)
		{
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			this.Visible = (SplendidCRM.Security.AdminUserAccess("CurrencyLayer", "list") >= 0);
			if ( !this.Visible )
				return;
			
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					sSQL = "select *                    " + ControlChars.CrLf
					     + "  from vwSYSTEM_CURRENCY_LOG" + ControlChars.CrLf
					     + " where 1 = 1                " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						if ( !Sql.IsEmptyString(this.DestinationISO4217) )
						{
							Sql.AppendParameter(cmd, this.DestinationISO4217, "DESTINATION_ISO4217");
						}
						cmd.CommandText += grdMain.OrderByClause("DATE_ENTERED", "desc");

						if ( bDebug )
							RegisterClientScriptBlock("vwSYSTEM_CURRENCY_LOG", Sql.ClientScriptBlock(cmd));

						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								vwMain = dt.DefaultView;
								grdMain.DataSource = vwMain ;
								grdMain.DataBind();
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}

			if ( !IsPostBack )
			{
				ctlDynamicButtons.AppendButtons("CurrencyLayer.SystemCurrencyLog", Guid.Empty, Guid.Empty);
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
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "CurrencyLayer";
			if ( IsPostBack )
				ctlDynamicButtons.AppendButtons("CurrencyLayer.SystemCurrencyLog", Guid.Empty, Guid.Empty);
		}
		#endregion
	}
}
