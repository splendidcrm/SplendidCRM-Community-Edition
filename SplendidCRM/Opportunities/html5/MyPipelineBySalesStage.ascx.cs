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

namespace SplendidCRM.Opportunities.html5
{
	/// <summary>
	///		Summary description for MyPipelineBySalesStage.
	/// </summary>
	public class MyPipelineBySalesStage : DashletControl
	{
		protected _controls.DashletHeader  ctlDashletHeader ;

		protected _controls.ChartDatePicker ctlDATE_START      ;
		protected _controls.ChartDatePicker ctlDATE_END        ;
		protected ListBox                   lstSALES_STAGE     ;
		protected ListBox                   lstASSIGNED_USER_ID;
		protected bool                      bShowEditDialog    ;
		protected Label                     lblError           ;
		protected HiddenField               hidSERIES_DATA     ;
		protected HiddenField               hidACTIVE_USERS    ;
		protected HiddenField               hidPIPELINE_TOTAL  ;

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
			
			List<double[]> arrSeriesData  = new List<double[]>();
			try
			{
				DateTime dtDATE_START  = (ctlDATE_START != null) ? ctlDATE_START.Value : DateTime.MinValue;
				DateTime dtDATE_END    = (ctlDATE_END   != null) ? ctlDATE_END.Value   : DateTime.MinValue;
				if ( dtDATE_START == DateTime.MinValue )
				{
					dtDATE_START = DateTime.Today;
				}
				if ( dtDATE_END == DateTime.MinValue )
				{
					// 07/06/2016 Paul.  Use +5 years instead of 2100 to reduce truncation when displaying year as yy. 
					dtDATE_END = new DateTime(DateTime.Today.Year + 5, 1, 1);
				}

				string[] arrASSIGNED_USER_ID = (lstASSIGNED_USER_ID != null) ? Sql.ToStringArray(lstASSIGNED_USER_ID) : new string[] { Security.USER_ID.ToString() };
				string[] arrSALES_STAGE      = (lstSALES_STAGE      != null) ? Sql.ToStringArray(lstSALES_STAGE     ) : null;

				// 01/31/2008 Paul.  Add space after TO. 
				//nodeGraphInfo.InnerText = L10n.Term("Dashboard.LBL_DATE_RANGE") + " " + Sql.ToDateString(T10n.FromServerTime(dtDATE_START)) + " " + L10n.Term("Dashboard.LBL_DATE_RANGE_TO") + " " + Sql.ToDateString(T10n.FromServerTime(dtDATE_END)) + "<BR/>"
				//                        + L10n.Term("Dashboard.LBL_OPP_SIZE"  ) + " " + 1.ToString("c0") + L10n.Term("Dashboard.LBL_OPP_THOUSANDS");
				
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					List<String> arrUSERS = new List<String>();
					// 09/19/2005 Paul.  Prepopulate the user key with all the users specified. 
					// 09/26/2009 Paul.  The AppendGuids function will protected against an empty list. 
					// We want to keep the empty list as we still need to pre-populate the users. 
					//if ( arrASSIGNED_USER_ID != null && arrASSIGNED_USER_ID.Length > 0 )
					{
						sSQL = "select ID          " + ControlChars.CrLf
						     + "     , USER_NAME   " + ControlChars.CrLf
						     + "  from vwUSERS_List" + ControlChars.CrLf
						     + " where 1 = 1       " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AppendGuids(cmd, arrASSIGNED_USER_ID, "ID");
							cmd.CommandText += " order by USER_NAME" + ControlChars.CrLf;
							using ( IDataReader rdr = cmd.ExecuteReader() )
							{
								while ( rdr.Read() )
								{
									Guid   gUSER_ID   = Sql.ToGuid   (rdr["ID"       ]);
									string sUSER_NAME = Sql.ToString (rdr["USER_NAME"]);
									arrUSERS.Insert(0, gUSER_ID.ToString());
								}
							}
						}
					}
					// 09/26/2009 Paul.  We need to prepopulate the sales stage, so if none are provided, then build the set in advance. 
					if ( arrSALES_STAGE == null || arrSALES_STAGE.Length == 0 )
					{
						// 08/07/2015 Paul.  Revenue Line Items. 
						sSQL = "select distinct                                      " + ControlChars.CrLf
						     + "       SALES_STAGE                                   " + ControlChars.CrLf
						     + "     , LIST_ORDER                                    " + ControlChars.CrLf
						     + "  from vw" + Crm.Config.OpportunitiesMode().ToUpper() + "_Pipeline" + ControlChars.CrLf;
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
							Sql.AppendParameter(cmd, arrSALES_STAGE     , "SALES_STAGE"     );
							
							cmd.CommandText += " order by LIST_ORDER" + ControlChars.CrLf;
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									arrSALES_STAGE = new String[dt.Rows.Count];
									for ( int i = 0; i < dt.Rows.Count; i++ )
									{
										DataRow row = dt.Rows[i];
										arrSALES_STAGE[i] = Sql.ToString(row["SALES_STAGE"]);
									}
								}
							}
						}
					}
					// 01/12/2015 Paul.  If no data, we still need to show an empty grid. 
					if ( arrSALES_STAGE == null || arrSALES_STAGE.Length == 0 )
					{
						DataTable dt = SplendidCache.List("sales_stage_dom");
						arrSALES_STAGE = new String[dt.Rows.Count];
						for ( int i = 0; i < dt.Rows.Count; i++ )
						{
							DataRow row = dt.Rows[i];
							arrSALES_STAGE[i] = Sql.ToString(row["DISPLAY_NAME"]);
						}
					}
					
					List<string> arrActiveUsers  = new List<string>();
					List<string> arrActiveStages = new List<string>();
					for ( int i = 0; i < arrSALES_STAGE.Length; i ++ )
					{
						arrActiveStages.Insert(0, arrSALES_STAGE[i]);
					}
					// 08/07/2015 Paul.  Revenue Line Items. 
					sSQL = "select distinct                                      " + ControlChars.CrLf
					     + "       USER_NAME                                     " + ControlChars.CrLf
					     + "  from vw" + Crm.Config.OpportunitiesMode().ToUpper() + "_Pipeline" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Opportunities", "list");
						cmd.CommandText += "   and DATE_CLOSED >= @DATE_START" + ControlChars.CrLf;
						cmd.CommandText += "   and DATE_CLOSED <= @DATE_END  " + ControlChars.CrLf;
						Sql.AddParameter   (cmd, "@DATE_START"      , dtDATE_START      );
						Sql.AddParameter   (cmd, "@DATE_END"        , dtDATE_END        );
						// 06/23/2018 Paul.  Need to allow multiple users to see the data they are assigned to. 
						if ( Crm.Config.enable_dynamic_assignment() )
							Sql.AppendLikeParameters(cmd, arrASSIGNED_USER_ID, "ASSIGNED_SET_LIST");
						else
							Sql.AppendGuids    (cmd, arrASSIGNED_USER_ID, "ASSIGNED_USER_ID");
						Sql.AppendParameter(cmd, arrSALES_STAGE     , "SALES_STAGE"     );
						cmd.CommandText += " order by USER_NAME" + ControlChars.CrLf;
						
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								foreach ( DataRow rdr in dt.Rows )
								{
									string sUSER_NAME = Sql.ToString(rdr["USER_NAME"]);
									arrActiveUsers.Add(sUSER_NAME);
									// 01/09/2015 Paul.  This is where we create the data matrix. 
									double[] arrStageSeries = new double[arrSALES_STAGE.Length];
									arrSeriesData.Add(arrStageSeries);
								}
								// 01/12/2015 Paul.  If no data, we still need to show an empty grid. 
								if ( dt.Rows.Count == 0 )
								{
									arrActiveUsers.Add(Security.USER_NAME);
									double[] arrStageSeries = new double[arrSALES_STAGE.Length];
									arrSeriesData.Add(arrStageSeries);
								}
							}
						}
					}
					hidACTIVE_USERS.Value = json.Serialize(arrActiveUsers);
					
					// 08/07/2015 Paul.  Revenue Line Items. 
					sSQL = "select SALES_STAGE                                   " + ControlChars.CrLf
					     + "     , ASSIGNED_USER_ID                              " + ControlChars.CrLf
					     + "     , USER_NAME                                     " + ControlChars.CrLf
					     + "     , LIST_ORDER                                    " + ControlChars.CrLf
					     + "     , sum(AMOUNT_USDOLLAR/1000) as TOTAL            " + ControlChars.CrLf
					     + "     , count(*)                  as OPPORTUNITY_COUNT" + ControlChars.CrLf
					     + "  from vw" + Crm.Config.OpportunitiesMode().ToUpper() + "_Pipeline" + ControlChars.CrLf;
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
						Sql.AppendParameter(cmd, arrSALES_STAGE     , "SALES_STAGE"     );
						
						cmd.CommandText += ""
						     + " group by SALES_STAGE                                " + ControlChars.CrLf
						     + "        , LIST_ORDER                                 " + ControlChars.CrLf
						     + "        , ASSIGNED_USER_ID                           " + ControlChars.CrLf
						     + "        , USER_NAME                                  " + ControlChars.CrLf
						     + " order by LIST_ORDER                                 " + ControlChars.CrLf
						     + "        , USER_NAME                                  " + ControlChars.CrLf;
						
						if ( bDebug )
							RegisterClientScriptBlock("html5MyPipelineBySalesStage", Sql.ClientScriptBlock(cmd));
						
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							double dPIPELINE_TOTAL = 0;
							while ( rdr.Read() )
							{
								string  sSALES_STAGE       = Sql.ToString (rdr["SALES_STAGE"      ]);
								double  dTOTAL             = Sql.ToDouble (rdr["TOTAL"            ]);
								int     nOPPORTUNITY_COUNT = Sql.ToInteger(rdr["OPPORTUNITY_COUNT"]);
								Guid    gASSIGNED_USER_ID  = Sql.ToGuid   (rdr["ASSIGNED_USER_ID" ]);
								string  sUSER_NAME         = Sql.ToString (rdr["USER_NAME"        ]);
								dPIPELINE_TOTAL += dTOTAL;
								
								int nSALES_STAGE = arrActiveStages.IndexOf(sSALES_STAGE);
								int nUSER_NAME   = arrActiveUsers.IndexOf (sUSER_NAME  );
								double[] arrStageSeries = arrSeriesData[nUSER_NAME];
								arrStageSeries[nSALES_STAGE] += dTOTAL;
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
				lstSALES_STAGE.DataSource = SplendidCache.List("sales_stage_dom");
				lstSALES_STAGE.DataBind();
				foreach(ListItem item in lstSALES_STAGE.Items)
				{
					item.Selected = true;
				}
				ctlDATE_START.Value = T10n.FromServerTime(DateTime.Today);
				// 07/06/2016 Paul.  Use +5 years instead of 2100 to reduce truncation when displaying year as yy. 
				ctlDATE_END  .Value = T10n.FromServerTime(new DateTime(DateTime.Today.Year + 5, 1, 1));
				
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

