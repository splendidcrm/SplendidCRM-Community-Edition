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
	///		Summary description for PipelineByMonthByOutcome.
	/// </summary>
	public class PipelineByMonthByOutcome : DashletControl
	{
		protected _controls.DashletHeader  ctlDashletHeader ;

		protected TextBox     txtYEAR            ;
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
			double[] arrSeriesWon   = new double[12];
			double[] arrSeriesLost  = new double[12];
			double[] arrSeriesOther = new double[12];
			arrSeriesData.Add(arrSeriesLost );
			arrSeriesData.Add(arrSeriesWon  );
			arrSeriesData.Add(arrSeriesOther);
			try
			{
				string[] arrASSIGNED_USER_ID = (lstASSIGNED_USER_ID != null) ? Sql.ToStringArray(lstASSIGNED_USER_ID) : new string[] { Security.USER_ID.ToString() };

				int nYEAR = Sql.ToInteger(txtYEAR.Text);
				nYEAR = Math.Max(1900, nYEAR);
				nYEAR = Math.Min(2100, nYEAR);
				DateTime dtDATE_START  = new DateTime(nYEAR,  1,  1);
				// 05/29/2017 Paul.  We were exlcuding the last day of the year. 
				DateTime dtDATE_END    = new DateTime(nYEAR, 12, 31, 23, 59, 59);

				Hashtable hashUSER = new Hashtable();
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					// 08/07/2015 Paul.  Revenue Line Items. 
					sSQL = "select SALES_STAGE                                   " + ControlChars.CrLf
					     + "     , MONTH_CLOSED                                  " + ControlChars.CrLf
					     + "     , sum(AMOUNT_USDOLLAR/1000) as TOTAL            " + ControlChars.CrLf
					     + "     , count(*)                  as OPPORTUNITY_COUNT" + ControlChars.CrLf
					     + "  from vw" + Crm.Config.OpportunitiesMode().ToUpper() + "_PipelineMonth" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Opportunities", "list");
						cmd.CommandText += "   and DATE_CLOSED >= @DATE_START" + ControlChars.CrLf;
						cmd.CommandText += "   and DATE_CLOSED <= @DATE_END  " + ControlChars.CrLf;
						// 09/14/2005 Paul.  Use add because <= and >= are not supported. 
						Sql.AddParameter   (cmd, "@DATE_START"      , dtDATE_START      );
						Sql.AddParameter   (cmd, "@DATE_END"        , dtDATE_END        );
						// 09/14/2005 Paul.  Use append because it supports arrays using the IN clause. 
						// 06/23/2018 Paul.  Need to allow multiple users to see the data they are assigned to. 
						if ( Crm.Config.enable_dynamic_assignment() )
							Sql.AppendLikeParameters(cmd, arrASSIGNED_USER_ID, "ASSIGNED_SET_LIST");
						else
							Sql.AppendGuids    (cmd, arrASSIGNED_USER_ID, "ASSIGNED_USER_ID");
						
						cmd.CommandText += ""
						     + " group by SALES_STAGE                                " + ControlChars.CrLf
						     + "        , MONTH_CLOSED                               " + ControlChars.CrLf
						     + " order by MONTH_CLOSED, SALES_STAGE desc             " + ControlChars.CrLf;
						
						if ( bDebug )
							RegisterClientScriptBlock("html5PipelineByMonthByOutcome", Sql.ClientScriptBlock(cmd));
						
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							double dMAX_TOTAL      = 0;
							double dPIPELINE_TOTAL = 0.0;
							string sMONTHYEAR_FORMAT = System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat.ShortDatePattern;
							// 09/21/2005 Paul.  Remove day from format. 
							sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.Replace("dd", "");
							sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.Replace("--", "-");
							sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.Replace("//", "/");
							sMONTHYEAR_FORMAT = sMONTHYEAR_FORMAT.Replace("  ", " ");
							while ( rdr.Read() )
							{
								int      nMONTH_CLOSED      = Sql.ToInteger(rdr["MONTH_CLOSED"     ]);
								string   sSALES_STAGE       = Sql.ToString (rdr["SALES_STAGE"      ]);
								double   dTOTAL             = Sql.ToDouble (rdr["TOTAL"            ]);
								int      nOPPORTUNITY_COUNT = Sql.ToInteger(rdr["OPPORTUNITY_COUNT"]);
								DateTime dtMONTH_CLOSED     = new DateTime(nYEAR, nMONTH_CLOSED, 1);
								string   sMONTH_CLOSED      = dtMONTH_CLOSED.ToString(sMONTHYEAR_FORMAT);
								
								dPIPELINE_TOTAL += dTOTAL;
								if ( dTOTAL > dMAX_TOTAL )
									dMAX_TOTAL = dTOTAL;
								
								switch ( sSALES_STAGE )
								{
									case "Closed Lost":  arrSeriesLost [nMONTH_CLOSED - 1] = dTOTAL;  break;
									case "Closed Won" :  arrSeriesWon  [nMONTH_CLOSED - 1] = dTOTAL;  break;
									case "Other"      :  arrSeriesOther[nMONTH_CLOSED - 1] = dTOTAL;  break;
								}
								//XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "altText"    , sMONTH_CLOSED + ": " + nOPPORTUNITY_COUNT.ToString() + " " + L10n.Term("Dashboard.LBL_OPPS_WORTH") + " " + dTOTAL.ToString("0") + L10n.Term("Dashboard.LBL_OPP_THOUSANDS") + " " + L10n.Term("Dashboard.LBL_OPPS_OUTCOME") + " " + Sql.ToString(L10n.Term(".sales_stage_dom.", sSALES_STAGE)) );
								//XmlUtil.SetSingleNodeAttribute(xml, nodeBar, "url"        , Sql.ToString(Application["rootURL"]) + "Opportunities/default.aspx?DATE_CLOSED=" + Server.UrlEncode(Sql.ToDateString(T10n.FromServerTime(dtMONTH_CLOSED))) + "&SALES_STAGE=" + Server.UrlEncode(sSALES_STAGE) );

							}
							int    nNumLength   = Math.Floor(dMAX_TOTAL).ToString("0").Length - 1;
							double dWhole       = Math.Pow(10, nNumLength);
							double dDecimal     = 1 / dWhole;
							double dMAX_ROUNDED = Math.Ceiling(dMAX_TOTAL * dDecimal) * dWhole;
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
				// 05/29/2017 Paul.  We should be using AssignedUser() and not ActiveUsers(). 
				lstASSIGNED_USER_ID.DataSource = SplendidCache.AssignedUser();
				lstASSIGNED_USER_ID.DataBind();
				txtYEAR.Text = DateTime.Today.Year.ToString();
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

