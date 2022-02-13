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
using System.Data.Common;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Web.Script.Serialization;
using System.Runtime.Serialization;
using System.Diagnostics;

namespace SplendidCRM.Dashboard.html5
{
	/// <summary>
	///		Summary description for OppByLeadSourceByOutcome.
	/// </summary>
	public class OppByLeadSourceByOutcome : DashletControl
	{
		protected _controls.DashletHeader  ctlDashletHeader ;

		protected ListBox     lstLEAD_SOURCE     ;
		protected ListBox     lstASSIGNED_USER_ID;
		protected bool        bShowEditDialog    ;
		protected Label       lblError           ;
		protected HiddenField hidSERIES_DATA     ;
		protected HiddenField hidPIPELINE_TOTAL  ;

		public string GetCurrencyPrefix()
		{
			string sCurrencyPrefix = String.Empty;
			string sCurrencySuffix = String.Empty;
			System.Globalization.CultureInfo culture = System.Threading.Thread.CurrentThread.CurrentCulture;
			switch ( culture.NumberFormat.CurrencyPositivePattern )
			{
				case 0:  // $n
					sCurrencyPrefix = culture.NumberFormat.CurrencySymbol;
					break;
				case 1:  // n$
					sCurrencySuffix = culture.NumberFormat.CurrencySymbol;
					break;
				case 2:  // $ n
					sCurrencyPrefix = culture.NumberFormat.CurrencySymbol + " ";
					break;
				case 3:  // n $
					sCurrencySuffix = " " + culture.NumberFormat.CurrencySymbol;
					break;
			}
			return sCurrencyPrefix;
		}

		public string GetCurrencySuffix()
		{
			string sCurrencyPrefix = String.Empty;
			string sCurrencySuffix = String.Empty;
			System.Globalization.CultureInfo culture = System.Threading.Thread.CurrentThread.CurrentCulture;
			switch ( culture.NumberFormat.CurrencyPositivePattern )
			{
				case 0:  // $n
					sCurrencyPrefix = culture.NumberFormat.CurrencySymbol;
					break;
				case 1:  // n$
					sCurrencySuffix = culture.NumberFormat.CurrencySymbol;
					break;
				case 2:  // $ n
					sCurrencyPrefix = culture.NumberFormat.CurrencySymbol + " ";
					break;
				case 3:  // n $
					sCurrencySuffix = " " + culture.NumberFormat.CurrencySymbol;
					break;
			}
			return sCurrencySuffix;
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Submit" )
				{
					bShowEditDialog = true;
					UpdateChartData();
				}
				else if ( e.CommandName == "Remove" )
				{
					if ( !Sql.IsEmptyString(sDetailView) )
					{
						SqlProcs.spDASHLETS_USERS_InitDisable(Security.USER_ID, sDetailView, m_sMODULE, this.AppRelativeVirtualPath.Substring(0, this.AppRelativeVirtualPath.Length-5));
						SplendidCache.ClearUserDashlets(sDetailView);
						Response.Redirect(Page.AppRelativeVirtualPath + Request.Url.Query);
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				//lblError.Text = ex.Message;
			}
		}

		private void UpdateChartData()
		{
			JavaScriptSerializer json = new JavaScriptSerializer();
			json.MaxJsonLength = 20 * 1024 * 1024;
			
			List<object> arrSeriesData  = new List<object>();
			try
			{
				string[] arrASSIGNED_USER_ID = (lstASSIGNED_USER_ID != null) ? Sql.ToStringArray(lstASSIGNED_USER_ID) : new string[] { Security.USER_ID.ToString() };
				string[] arrLEAD_SOURCE      = (lstLEAD_SOURCE      != null) ? Sql.ToStringArray(lstLEAD_SOURCE     ) : null;

				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					// 09/19/2005 Paul.  Prepopulate the outcome. 
					string[] arrOUTCOME = new string[] { "Closed Lost", "Closed Won", "Other" };
					// 09/26/2009 Paul.  We need to prepopulate the sales stage, so if none are provided, then build the set in advance. 
					if ( arrLEAD_SOURCE == null || arrLEAD_SOURCE.Length == 0 )
					{
						// 08/07/2015 Paul.  Revenue Line Items. 
						sSQL = "select distinct                                      " + ControlChars.CrLf
						     + "       LEAD_SOURCE                                   " + ControlChars.CrLf
						     + "     , LIST_ORDER                                    " + ControlChars.CrLf
						     + "  from vw" + Crm.Config.OpportunitiesMode().ToUpper() + "_ByLeadOutcome" + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Security.Filter(cmd, "Opportunities", "list");
							// 09/14/2005 Paul.  Use append because it supports arrays using the IN clause. 
							// 06/23/2018 Paul.  Need to allow multiple users to see the data they are assigned to. 
							if ( Crm.Config.enable_dynamic_assignment() )
								Sql.AppendLikeParameters(cmd, arrASSIGNED_USER_ID, "ASSIGNED_SET_LIST");
							else
								Sql.AppendGuids    (cmd, arrASSIGNED_USER_ID, "ASSIGNED_USER_ID");
							Sql.AppendParameter(cmd, arrLEAD_SOURCE     , "LEAD_SOURCE"     );
							
							cmd.CommandText += " order by LIST_ORDER desc                            " + ControlChars.CrLf;
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									arrLEAD_SOURCE = new String[dt.Rows.Count];
									for ( int i = 0; i < dt.Rows.Count; i++ )
									{
										DataRow row = dt.Rows[i];
										arrLEAD_SOURCE[i] = Sql.ToString(row["LEAD_SOURCE"]);
									}
								}
							}
						}
					}
					
					List<string> arrActiveLeadSource = new List<string>(arrLEAD_SOURCE);
					for ( int i = 0; i < arrLEAD_SOURCE.Length; i ++ )
					{
						arrActiveLeadSource.Insert(0, arrLEAD_SOURCE[i]);
					}
					double[] arrSeriesWon   = new double[arrLEAD_SOURCE.Length];
					double[] arrSeriesLost  = new double[arrLEAD_SOURCE.Length];
					double[] arrSeriesOther = new double[arrLEAD_SOURCE.Length];
					arrSeriesData.Add(arrSeriesLost );
					arrSeriesData.Add(arrSeriesWon  );
					arrSeriesData.Add(arrSeriesOther);
					
					// 08/07/2015 Paul.  Revenue Line Items. 
					sSQL = "select LEAD_SOURCE                                   " + ControlChars.CrLf
					     + "     , SALES_STAGE                                   " + ControlChars.CrLf
					     + "     , LIST_ORDER                                    " + ControlChars.CrLf
					     + "     , sum(AMOUNT_USDOLLAR/1000) as TOTAL            " + ControlChars.CrLf
					     + "     , count(*)                  as OPPORTUNITY_COUNT" + ControlChars.CrLf
					     + "  from vw" + Crm.Config.OpportunitiesMode().ToUpper() + "_ByLeadOutcome" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Opportunities", "list");
						// 09/14/2005 Paul.  Use append because it supports arrays using the IN clause. 
						// 06/23/2018 Paul.  Need to allow multiple users to see the data they are assigned to. 
						if ( Crm.Config.enable_dynamic_assignment() )
							Sql.AppendLikeParameters(cmd, arrASSIGNED_USER_ID, "ASSIGNED_SET_LIST");
						else
							Sql.AppendGuids    (cmd, arrASSIGNED_USER_ID, "ASSIGNED_USER_ID");
						Sql.AppendParameter(cmd, arrLEAD_SOURCE     , "LEAD_SOURCE"     );
						
						cmd.CommandText += ""
						     + " group by LEAD_SOURCE                                " + ControlChars.CrLf
						     + "        , LIST_ORDER                                 " + ControlChars.CrLf
						     + "        , SALES_STAGE                                " + ControlChars.CrLf
						     + " order by LIST_ORDER desc                            " + ControlChars.CrLf
						     + "        , SALES_STAGE                                " + ControlChars.CrLf;
						
						if ( bDebug )
							RegisterClientScriptBlock("html5OppByLeadSourceByOutcome", Sql.ClientScriptBlock(cmd));
						
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							double dPIPELINE_TOTAL = 0;
							while ( rdr.Read() )
							{
								string  sLEAD_SOURCE       = Sql.ToString (rdr["LEAD_SOURCE"      ]);
								string  sSALES_STAGE       = Sql.ToString (rdr["SALES_STAGE"      ]);
								double  dTOTAL             = Sql.ToDouble (rdr["TOTAL"            ]);
								int     nOPPORTUNITY_COUNT = Sql.ToInteger(rdr["OPPORTUNITY_COUNT"]);
								dPIPELINE_TOTAL += dTOTAL;
								
								int nLEAD_SOURCE = arrActiveLeadSource.IndexOf(sLEAD_SOURCE);
								switch ( sSALES_STAGE )
								{
									case "Closed Lost":  arrSeriesLost [nLEAD_SOURCE] += dTOTAL;  break;
									case "Closed Won" :  arrSeriesWon  [nLEAD_SOURCE] += dTOTAL;  break;
									case "Other"      :  arrSeriesOther[nLEAD_SOURCE] += dTOTAL;  break;
								}
							}
							hidPIPELINE_TOTAL.Value = dPIPELINE_TOTAL.ToString("c0");
						}
					}
				}
				hidSERIES_DATA.Value = json.Serialize(arrSeriesData);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}
		
		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( !IsPostBack )
			{
				lstLEAD_SOURCE.DataSource = SplendidCache.List("lead_source_dom");
				lstLEAD_SOURCE.DataBind();
				lstLEAD_SOURCE.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
				// 05/29/2017 Paul.  We should be using AssignedUser() and not ActiveUsers(). 
				lstASSIGNED_USER_ID.DataSource = SplendidCache.AssignedUser();
				lstASSIGNED_USER_ID.DataBind();
				// 09/14/2005 Paul.  Default to today, and all leads. 
				foreach(ListItem item in lstLEAD_SOURCE.Items)
				{
					item.Selected = true;
				}
				foreach(ListItem item in lstASSIGNED_USER_ID.Items)
				{
					item.Selected = true;
				}
				
				try
				{
					UpdateChartData();
					ChartUtil.RegisterScripts(this.Page);
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					lblError.Text = ex.Message;
				}
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
			ctlDashletHeader.Command += new CommandEventHandler(Page_Command);
			m_sMODULE = "Opportunities";
		}
		#endregion
	}
}

