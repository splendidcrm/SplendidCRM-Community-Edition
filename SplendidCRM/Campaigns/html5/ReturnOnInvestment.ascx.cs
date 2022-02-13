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
	///		Summary description for ReturnOnInvestment.
	/// </summary>
	public class ReturnOnInvestment : SplendidControl
	{
		protected Label       lblError           ;
		protected HiddenField hidSERIES_DATA     ;

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
			double[] arrSeriesRevenue    = new double[4];
			double[] arrSeriesInvestment = new double[4];
			double[] arrSeriesExpected   = new double[4];
			double[] arrSeriesBudget     = new double[4];
			arrSeriesData.Add(arrSeriesRevenue   );
			arrSeriesData.Add(arrSeriesInvestment);
			arrSeriesData.Add(arrSeriesExpected  );
			arrSeriesData.Add(arrSeriesBudget    );
			try
			{
				Guid gID = Sql.ToGuid(Request["ID"]);
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select *              " + ControlChars.CrLf
					     + "  from vwCAMPAIGNS_Roi" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Campaigns", "view");
						Sql.AppendParameter(cmd, gID, "ID", false);
						
						if ( bDebug )
							RegisterClientScriptBlock("html5ReturnOnInvestment", Sql.ClientScriptBlock(cmd));
						
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							if ( rdr.Read() )
							{
								double dREVENUE          = 0.0;
								double dINVESTMENT       = 0.0;
								double dEXPECTED_REVENUE = 0.0;
								double dBUDGET           = 0.0;
								try
								{
									dREVENUE          = Sql.ToDouble(rdr["REVENUE"         ]);
									dINVESTMENT       = Sql.ToDouble(rdr["ACTUAL_COST"     ]);
									dEXPECTED_REVENUE = Sql.ToDouble(rdr["EXPECTED_REVENUE"]);
									dBUDGET           = Sql.ToDouble(rdr["BUDGET"          ]);
									arrSeriesRevenue   [0] = dREVENUE         ;
									arrSeriesInvestment[1] = dINVESTMENT      ;
									arrSeriesExpected  [2] = dEXPECTED_REVENUE;
									arrSeriesBudget    [3] = dBUDGET          ;
								}
								catch(Exception ex)
								{
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
								}
							}
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
			m_sMODULE = "Opportunities";
		}
		#endregion
	}
}

