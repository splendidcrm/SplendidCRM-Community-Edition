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
	///		Summary description for ResponseByRecipientActivity.
	/// </summary>
	public class ResponseByRecipientActivity : DashletControl
	{
		protected ListBox     lstACTIVITY_TYPE   ;
		protected Label       lblError           ;
		protected HiddenField hidSERIES_DATA     ;

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
			try
			{
				string[] arrACTIVITY_TYPE = (lstACTIVITY_TYPE != null) ? Sql.ToStringArray(lstACTIVITY_TYPE) : null;

				Guid gID = Sql.ToGuid(Request["ID"]);
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					List<string> arrActiveActivityType = new List<string>(arrACTIVITY_TYPE);
					for ( int i = 0; i < arrACTIVITY_TYPE.Length; i ++ )
					{
						arrActiveActivityType.Insert(0, arrACTIVITY_TYPE[i]);
					}
					int[] arrSeriesContacts  = new int[arrACTIVITY_TYPE.Length];
					int[] arrSeriesLeads     = new int[arrACTIVITY_TYPE.Length];
					int[] arrSeriesProspects = new int[arrACTIVITY_TYPE.Length];
					int[] arrSeriesUsers     = new int[arrACTIVITY_TYPE.Length];
					arrSeriesData.Add(arrSeriesContacts );
					arrSeriesData.Add(arrSeriesLeads    );
					arrSeriesData.Add(arrSeriesProspects);
					arrSeriesData.Add(arrSeriesUsers    );
					
					sSQL = "select ACTIVITY_TYPE                         " + ControlChars.CrLf
					     + "     , TARGET_TYPE                           " + ControlChars.CrLf
					     + "     , LIST_ORDER                            " + ControlChars.CrLf
					     + "     , count(*)                  as HIT_COUNT" + ControlChars.CrLf
					     + "  from vwCAMPAIGNS_Activity                  " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "Campaigns", "view");
						Sql.AppendParameter(cmd, gID, "ID", false);
						cmd.CommandText += ""
						     + " group by ACTIVITY_TYPE                      " + ControlChars.CrLf
						     + "        , LIST_ORDER                         " + ControlChars.CrLf
						     + "        , TARGET_TYPE                        " + ControlChars.CrLf
						     + " order by LIST_ORDER                         " + ControlChars.CrLf
						     + "        , TARGET_TYPE                        " + ControlChars.CrLf;
						
						if ( bDebug )
							RegisterClientScriptBlock("html5ResponseByRecipientActivity", Sql.ClientScriptBlock(cmd));
						
						using ( IDataReader rdr = cmd.ExecuteReader() )
						{
							while ( rdr.Read() )
							{
								string  sACTIVITY_TYPE = Sql.ToString (rdr["ACTIVITY_TYPE"]);
								string  sTARGET_TYPE   = Sql.ToString (rdr["TARGET_TYPE"  ]);
								int     nHIT_COUNT     = Sql.ToInteger(rdr["HIT_COUNT"    ]);
								
								int nACTIVITY_TYPE = arrActiveActivityType.IndexOf(sACTIVITY_TYPE);
								if ( nACTIVITY_TYPE >= 0 )
								{
									switch ( sTARGET_TYPE )
									{
										case "Contacts" :  arrSeriesContacts [nACTIVITY_TYPE] += nHIT_COUNT;  break;
										case "Leads"    :  arrSeriesLeads    [nACTIVITY_TYPE] += nHIT_COUNT;  break;
										case "Prospects":  arrSeriesProspects[nACTIVITY_TYPE] += nHIT_COUNT;  break;
										case "Useres"   :  arrSeriesUsers    [nACTIVITY_TYPE] += nHIT_COUNT;  break;
									}
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
				lstACTIVITY_TYPE.DataSource = SplendidCache.List("campainglog_activity_type_dom");
				lstACTIVITY_TYPE.DataBind();
				lstACTIVITY_TYPE.Items.Insert(0, new ListItem(L10n.Term("Campaigns.NTC_NO_LEGENDS"), ""));
				foreach(ListItem item in lstACTIVITY_TYPE.Items)
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
			m_sMODULE = "Opportunities";
		}
		#endregion
	}
}

