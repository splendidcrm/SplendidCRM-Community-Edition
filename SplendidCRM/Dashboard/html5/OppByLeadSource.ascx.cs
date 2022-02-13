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
	///		Summary description for OppByLeadSource.
	/// </summary>
	public class OppByLeadSource : DashletControl
	{
		protected _controls.DashletHeader  ctlDashletHeader ;

		protected ListBox     lstLEAD_SOURCE     ;
		protected ListBox     lstASSIGNED_USER_ID;
		protected bool        bShowEditDialog    ;
		protected Label       lblError           ;
		protected HiddenField hidSERIES_DATA     ;
		protected HiddenField hidPIPELINE_TOTAL  ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Submit" )
				{
					// 01/19/2007 Paul.  Keep the edit dialog visible.
					bShowEditDialog = true;
					UpdateChartData();
				}
				// 09/26/2009 Paul.  Allow the dashlet to be removed. 
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
			
			try
			{
				string[] arrASSIGNED_USER_ID = (lstASSIGNED_USER_ID != null) ? Sql.ToStringArray(lstASSIGNED_USER_ID) : new string[] { Security.USER_ID.ToString() };
				string[] arrLEAD_SOURCE      = (lstLEAD_SOURCE      != null) ? Sql.ToStringArray(lstLEAD_SOURCE     ) : null;

				List<object> arrSeriesData  = new List<object>();
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					// 08/07/2015 Paul.  Revenue Line Items. 
					sSQL = "select LEAD_SOURCE                                   " + ControlChars.CrLf
					     + "     , LIST_ORDER                                    " + ControlChars.CrLf
					     + "     , sum(AMOUNT_USDOLLAR/1000) as TOTAL            " + ControlChars.CrLf
					     + "     , count(*)                  as OPPORTUNITY_COUNT" + ControlChars.CrLf
					     + "  from vw" + Crm.Config.OpportunitiesMode().ToUpper() + "_ByLeadSource" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Opportunities", "list");
						// 06/23/2018 Paul.  Need to allow multiple users to see the data they are assigned to. 
						if ( Crm.Config.enable_dynamic_assignment() )
							Sql.AppendLikeParameters(cmd, arrASSIGNED_USER_ID, "ASSIGNED_SET_LIST");
						else
							Sql.AppendGuids    (cmd, arrASSIGNED_USER_ID, "ASSIGNED_USER_ID");
						Sql.AppendParameter(cmd, arrLEAD_SOURCE     , "LEAD_SOURCE"     );
						cmd.CommandText += ""
						     + " group by LEAD_SOURCE                                " + ControlChars.CrLf
						     + "        , LIST_ORDER                                 " + ControlChars.CrLf
						     + " order by LIST_ORDER                                 " + ControlChars.CrLf;
						
						if ( bDebug )
							RegisterClientScriptBlock("html5OppByLeadSource", Sql.ClientScriptBlock(cmd));
						
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								double dPIPELINE_TOTAL = 0;
								foreach ( DataRow row in dt.Rows )
								{
									dPIPELINE_TOTAL += Sql.ToDouble (row["TOTAL"]);
								}
								foreach ( DataRow row in dt.Rows )
								{
									string  sLEAD_SOURCE       = Sql.ToString (row["LEAD_SOURCE"      ]);
									double  dTOTAL             = Sql.ToDouble (row["TOTAL"            ]);
									int     nOPPORTUNITY_COUNT = Sql.ToInteger(row["OPPORTUNITY_COUNT"]);
									
									// 05/27/2007 Paul.  LBL_NONE is --None--, so create a new term LBL_NONE_VALUE.
									string sLEAD_SOURCE_TERM = String.Empty;
									if ( sLEAD_SOURCE == String.Empty )
										sLEAD_SOURCE_TERM = L10n.Term(".LBL_NONE_VALUE");
									else
										sLEAD_SOURCE_TERM = Sql.ToString(L10n.Term(".lead_source_dom.", sLEAD_SOURCE));
									
									//row["LABEL"        ] = sLEAD_SOURCE_TERM;
									//row["VALUE"        ] = dTOTAL;
									//row["DISPLAY_VALUE"] = dTOTAL.ToString("c0");
									//row["DESCRIPTION"  ] = nOPPORTUNITY_COUNT.ToString() + " " + L10n.Term("Dashboard.LBL_OPPS_IN_LEAD_SOURCE") + " " + sLEAD_SOURCE_TERM;
									//row["URL"          ] = Sql.ToString(Application["rootURL"]) + "Opportunities/default.aspx?LEAD_SOURCE=" + Server.UrlEncode(sLEAD_SOURCE);
									
									List<object> arrRow  = new List<object>();
									arrRow.Add(sLEAD_SOURCE_TERM);
									arrRow.Add(dTOTAL           );
									arrRow.Add(dTOTAL.ToString("c0"));
									arrRow.Add( (dTOTAL * 100 / dPIPELINE_TOTAL).ToString("0.00") + " %");
									arrRow.Add(nOPPORTUNITY_COUNT.ToString() + " " + L10n.Term("Dashboard.LBL_OPPS_IN_LEAD_SOURCE") + " " + sLEAD_SOURCE_TERM);
									arrSeriesData.Add(arrRow);
								}
								hidPIPELINE_TOTAL.Value = dPIPELINE_TOTAL.ToString("c0");
							}
						}
					}
				}
				// 01/12/2015 Paul.  If no data, we still need to show an empty grid. 
				if ( arrSeriesData.Count == 0 )
					hidSERIES_DATA.Value = "[[null]]";
				else
					hidSERIES_DATA.Value = json.Serialize(arrSeriesData);
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				Response.Write(ex.Message);
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

