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
using System.Text;
using System.Data;
using System.Data.Common;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.Administration.Currencies
{
	/// <summary>
	/// Summary description for DetailView.
	/// </summary>
	public class DetailView : SplendidControl
	{
		protected _controls.HeaderButtons         ctlDynamicButtons   ;
		protected CurrencyLayer.SystemCurrencyLog ctlSystemCurrencyLog;

		protected Guid          gID              ;
		protected HtmlTable     tblMain          ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Currencies.MakeDefault" )
				{
					string sNAME     = "default_currency";
					string sCATEGORY = "system";
					string sVALUE    = gID.ToString();
					SqlProcs.spCONFIG_Update(sCATEGORY, sNAME, sVALUE);
					Application["CONFIG." + sNAME] = sVALUE;
					Response.Redirect("view.aspx?ID=" + gID.ToString());
				}
				else if ( e.CommandName == "Currencies.MakeBase" )
				{
					string sNAME     = "base_currency";
					string sCATEGORY = "system";
					string sVALUE    = gID.ToString();
					SqlProcs.spCONFIG_Update(sCATEGORY, sNAME, sVALUE);
					// 05/01/2016 Paul.  The conversion rate for the base currency is always 1.0. 
					string sISO4217 = new DynamicControl(this, "ISO4217").Text;
					SqlProcs.spCURRENCIES_UpdateRateByISO( sISO4217, 1.0f, Guid.Empty);
					Application["CONFIG." + sNAME] = sVALUE;
					Response.Redirect("view.aspx?ID=" + gID.ToString());
				}
				else if ( e.CommandName == "Currencies.UpdateRate" )
				{
					StringBuilder sbErrors = new StringBuilder();
					string sISO4217 = new DynamicControl(this, "ISO4217").Text;
					float dRate = OrderUtils.GetCurrencyConversionRate(Application, sISO4217, sbErrors);
					if ( sbErrors.Length == 0 )
					{
						Response.Redirect("view.aspx?ID=" + gID.ToString());
					}
					else
					{
						ctlDynamicButtons.ErrorText = sbErrors.ToString();
					}
				}
				else if ( e.CommandName == "Edit" )
				{
					Response.Redirect("edit.aspx?ID=" + gID.ToString());
				}
				else if ( e.CommandName == "Cancel" )
				{
					Response.Redirect("default.aspx");
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
			this.Visible = (SplendidCRM.Security.AdminUserAccess(m_sMODULE, "view") >= 0);
			if ( !this.Visible )
			{
				Parent.DataBind();
				return;
			}

			try
			{
				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					if ( !Sql.IsEmptyGuid(gID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL ;
							sSQL = "select *                " + ControlChars.CrLf
							     + "  from vwCURRENCIES_Edit" + ControlChars.CrLf
							     + " where 1 = 1            " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AppendParameter(cmd, gID, "ID", false);
								con.Open();

								if ( bDebug )
									RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dtCurrent = new DataTable() )
									{
										da.Fill(dtCurrent);
										if ( dtCurrent.Rows.Count > 0 )
										{
											DataRow rdr = dtCurrent.Rows[0];
											ctlDynamicButtons.Title = Sql.ToString(rdr["NAME"]);
											SetPageTitle(L10n.Term(".moduleList." + m_sMODULE) + " - " + ctlDynamicButtons.Title);
											
											this.AppendDetailViewFields(m_sMODULE + "." + LayoutDetailView, tblMain, rdr);
											ctlSystemCurrencyLog.DestinationISO4217 = Sql.ToString(rdr["ISO4217"]);
											
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, rdr);
											ctlDynamicButtons.ShowButton("Currencies.MakeDefault", !Sql.ToBoolean(rdr["IS_DEFAULT"]));
											ctlDynamicButtons.ShowButton("Currencies.MakeBase"   , !Sql.ToBoolean(rdr["IS_BASE"   ]));
											ctlDynamicButtons.ShowButton("Currencies.UpdateRate" , !Sql.ToBoolean(rdr["IS_BASE"   ]) && !Sql.IsEmptyString(Application["CONFIG.CurrencyLayer.AccessKey"]));
											
										}
										else
										{
											ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
											ctlDynamicButtons.DisableAll();
											ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
										}
									}
								}
							}
						}
					}
					else
					{
						ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
						ctlDynamicButtons.DisableAll();
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
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
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Currencies";
			SetMenu(m_sMODULE);
			if ( IsPostBack )
			{
				this.AppendDetailViewFields(m_sMODULE + "." + LayoutDetailView, tblMain, null);
				ctlDynamicButtons.AppendButtons(m_sMODULE + "." + LayoutDetailView, Guid.Empty, null);
			}
		}
		#endregion
	}
}

