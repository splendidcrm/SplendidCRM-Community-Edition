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
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Xml;
using System.Text;
using System.Collections;
using System.Threading;
using System.Globalization;

namespace SplendidCRM.Reports
{
	/// <summary>
	///		Summary description for QueryBuilder.
	/// </summary>
	public class QueryBuilder : SplendidControl
	{
		protected Label           lblError                ;
		protected RdlDocument     rdl                = null;
		protected DropDownList    lstMODULE               ;
		protected DropDownList    lstRELATED              ;
		protected DropDownList    lstMODULE_COLUMN_SOURCE ;
		protected CheckBox        chkSHOW_QUERY           ;

		protected string          sReportSQL              ;
		protected DataGrid        dgFilters               ;
		protected HtmlInputHidden txtFILTER_ID            ;
		protected DropDownList    lstFILTER_COLUMN_SOURCE ;
		protected DropDownList    lstFILTER_COLUMN        ;
		protected DropDownList    lstFILTER_OPERATOR      ;
		protected Label           lblMODULE               ;
		protected Label           lblRELATED              ;
		protected Label           lblMODULE_COLUMN_SOURCE ;
		protected Label           lblFILTER_COLUMN_SOURCE ;
		protected Label           lblFILTER_COLUMN        ;
		protected Label           lblFILTER_OPERATOR_TYPE ;
		protected Label           lblFILTER_OPERATOR      ;
		protected Label           lblFILTER_ID            ;
		
		protected HtmlInputHidden txtFILTER_SEARCH_ID        ;
		protected HtmlInputHidden txtFILTER_SEARCH_DATA_TYPE ;
		protected TextBox         txtFILTER_SEARCH_TEXT      ;
		protected TextBox         txtFILTER_SEARCH_TEXT2     ;
		protected DropDownList    lstFILTER_SEARCH_DROPDOWN  ;
		protected ListBox         lstFILTER_SEARCH_LISTBOX   ;
		protected Button          btnFILTER_SEARCH_SELECT    ;
		protected Label           lblFILTER_AND_SEPARATOR    ;

		protected _controls.DatePicker ctlFILTER_SEARCH_START_DATE;
		protected _controls.DatePicker ctlFILTER_SEARCH_END_DATE  ;

		protected Literal         litREPORT_QUERY         ;
		protected Literal         litREPORT_RDL           ;
		protected string[]        arrModules              ;
		protected bool            bUserSpecific           = false;
		protected bool            bPrimaryKeyOnly         = true;
		protected TableRow        trRelated               ;
		protected TableRow        trModule                ;
		// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
		protected bool            bUseSQLParameters       = false;
		protected HtmlInputHidden txtACTIVE_TAB           ;
		protected _controls.Chooser        ctlDisplayColumnsChooser;

		protected bool            bDesignChart            = false;
		protected RadioButton     radChartTypeColumn       ;
		protected RadioButton     radChartTypeBar          ;
		protected RadioButton     radChartTypeLine         ;
		protected RadioButton     radChartTypeShape        ;
		protected DropDownList    lstSERIES_COLUMN         ;
		protected Label           lblSERIES_COLUMN         ;
		protected DropDownList    lstSERIES_OPERATOR       ;
		protected Label           lblSERIES_OPERATOR_TYPE  ;
		protected Label           lblSERIES_OPERATOR       ;
		protected DropDownList    lstCATEGORY_COLUMN       ;
		protected Label           lblCATEGORY_OPERATOR_TYPE;
		protected Label           lblCATEGORY_COLUMN       ;
		protected DropDownList    lstCATEGORY_OPERATOR     ;
		protected Label           lblCATEGORY_OPERATOR     ;

		// 10/23/2010 Paul.  Provide a way to tap into the events. This is needed by the RulesWizard. 
		public CommandEventHandler Command ;

		public string Modules
		{
			get { return (arrModules == null ? String.Empty : String.Join(",", arrModules)); }
			set { arrModules = value.Replace(" ", "").Split(','); }
		}

		// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
		public bool UseSQLParameters
		{
			get { return bUseSQLParameters; }
			set { bUseSQLParameters = value; }
		}

		// 02/17/2018 Paul.  ModulesArchiveRules needs to turn off the query so that the preview results will appear. 
		public bool ShowQuery
		{
			get { return chkSHOW_QUERY.Checked; }
			set { chkSHOW_QUERY.Checked = value; }
		}

		public bool DesignChart
		{
			get { return bDesignChart; }
			set { bDesignChart = value; }
		}

		public string ActiveTab
		{
			get { return txtACTIVE_TAB.Value; }
			set { txtACTIVE_TAB.Value = value; }
		}

		public string MODULE
		{
			get { return lstMODULE.SelectedValue; }
		}

		public int SelectedColumns
		{
			get { return rdl.SelectNodesNS("Body/ReportItems/Table/Details/TableRows/TableRow/TableCells/TableCell/ReportItems").Count; }
		}

		public bool UserSpecific
		{
			get { return bUserSpecific; }
			set { bUserSpecific = value; }
		}

		public bool PrimaryKeyOnly
		{
			get { return bPrimaryKeyOnly; }
			set { bPrimaryKeyOnly = value; }
		}

		public bool ShowRelated
		{
			get { return trRelated.Visible; }
			set { trRelated.Visible = value; }
		}

		public bool ShowModule
		{
			get { return trModule.Visible; }
			set { trModule.Visible = value; }
		}

		public string ReportSQL
		{
			get { return sReportSQL; }
		}

		public string ReportRDL
		{
			get { return (rdl != null) ? rdl.OuterXml : String.Empty; }
		}

		public void SetCustomProperty(string sName, string sValue)
		{
			rdl.SetCustomProperty(sName, sValue);
		}

		// 11/09/2011 Paul.  We need a quick way to set the chart title. 
		public void UpdateChartTitle(string sChartTitle)
		{
			rdl.UpdateChartTitle(sChartTitle);
		}

		public string GetCustomPropertyValue(string sName)
		{
			return rdl.GetCustomPropertyValue(sName);
		}

		public void SetSingleNode(string sName, string sValue)
		{
			rdl.SetSingleNode(sName, sValue);
		}

		public string SelectNodeValue(string sName)
		{
			return rdl.SelectNodeValue(sName);
		}

		public string SelectNodeAttribute(string sNode, string sAttribute)
		{
			return rdl.SelectNodeAttribute(sNode, sAttribute);
		}

		protected void ResetSearchText()
		{
			lstFILTER_COLUMN_SOURCE.SelectedIndex = 0;
			lstFILTER_COLUMN_SOURCE_Changed(null, null);
			lstFILTER_COLUMN.SelectedIndex = 0;
			lstFILTER_COLUMN_Changed(null, null);
			lstFILTER_OPERATOR.SelectedIndex = 0;
			lstFILTER_OPERATOR_Changed(null, null);

			txtFILTER_ID               .Value    = String.Empty;
			lblFILTER_ID               .Text     = String.Empty;
			txtFILTER_SEARCH_TEXT      .Text     = String.Empty;
			txtFILTER_SEARCH_TEXT2     .Text     = String.Empty;
			ctlFILTER_SEARCH_START_DATE.DateText = String.Empty;
			ctlFILTER_SEARCH_END_DATE  .DateText = String.Empty;
		}

		#region Page_Command
		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Filters.Cancel" )
				{
					ResetSearchText();
					if ( Command != null )
						Command(sender, e);
				}
				else if ( e.CommandName == "Filters.Add" )
				{
					ResetSearchText();
					if ( Command != null )
						Command(sender, e);
				}
				else if ( e.CommandName == "Filters.Delete" )
				{
					FiltersDelete(Sql.ToString(e.CommandArgument));
					ResetSearchText();
					if ( Command != null )
						Command(sender, e);
				}
				else if ( e.CommandName == "Filters.Edit" )
				{
					string sFILTER_ID = Sql.ToString(e.CommandArgument);
					string sMODULE_NAME  = String.Empty;
					string sDATA_FIELD   = String.Empty;
					string sDATA_TYPE    = String.Empty;
					string sOPERATOR     = String.Empty;
					string sSEARCH_TEXT1 = String.Empty;
					string sSEARCH_TEXT2 = String.Empty;
					string[] arrSEARCH_TEXT = new string[0];
					FiltersGet(sFILTER_ID, ref sMODULE_NAME, ref sDATA_FIELD, ref sDATA_TYPE, ref sOPERATOR, ref arrSEARCH_TEXT );
					txtFILTER_ID               .Value    = sFILTER_ID;
					lblFILTER_ID               .Text     = txtFILTER_ID.Value;
					txtFILTER_SEARCH_DATA_TYPE .Value    = sDATA_TYPE;
					txtFILTER_SEARCH_TEXT      .Text     = String.Empty;
					txtFILTER_SEARCH_TEXT2     .Text     = String.Empty;
					ctlFILTER_SEARCH_START_DATE.DateText = String.Empty;
					ctlFILTER_SEARCH_END_DATE  .DateText = String.Empty;
					
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstFILTER_COLUMN_SOURCE, sMODULE_NAME);
					lstFILTER_COLUMN_SOURCE_Changed(null, null);
					
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstFILTER_COLUMN       , sDATA_FIELD );
					lstFILTER_COLUMN_Changed(null, null);
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstFILTER_OPERATOR     , sOPERATOR   );
					lstFILTER_OPERATOR_Changed(null, null);
					
					if ( arrSEARCH_TEXT.Length > 0 )
						sSEARCH_TEXT1 = arrSEARCH_TEXT[0];
					if ( arrSEARCH_TEXT.Length > 1 )
						sSEARCH_TEXT2 = arrSEARCH_TEXT[1];
					
					// 07/06/2007 Paul.  ansistring is treated the same as string. 
					string sCOMMON_DATA_TYPE = sDATA_TYPE;
					if ( sCOMMON_DATA_TYPE == "ansistring" )
						sCOMMON_DATA_TYPE = "string";
					switch ( sCOMMON_DATA_TYPE )
					{
						case "string":
						{
							switch ( sOPERATOR )
							{
								case "equals"        :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "contains"      :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "starts_with"   :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "ends_with"     :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "not_equals_str":  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "empty"         :  break;
								case "not_empty"     :  break;
								// 08/25/2011 Paul.  A customer wants more use of NOT in string filters. 
								case "not_contains"   :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "not_starts_with":  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "not_ends_with"  :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								// 02/14/2013 Paul.  A customer wants to use like in string filters. 
								case "like"           :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "not_like"       :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								// 07/23/2013 Paul.  Add greater and less than conditions. 
								case "less"           :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "less_equal"     :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "greater"        :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "greater_equal"  :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
							}
							break;
						}
						case "datetime":
						{
							if ( arrSEARCH_TEXT.Length > 0 )
							{
								DateTime dtSEARCH_TEXT1 = DateTime.MinValue;
								DateTime dtSEARCH_TEXT2 = DateTime.MinValue;
								if ( !(sOPERATOR.EndsWith("_after") || sOPERATOR.EndsWith("_before") || sOPERATOR.EndsWith("_old")) )
								{
									dtSEARCH_TEXT1 = DateTime.ParseExact(sSEARCH_TEXT1, "yyyy/MM/dd", Thread.CurrentThread.CurrentCulture.DateTimeFormat);
									dtSEARCH_TEXT2 = DateTime.MinValue;
									if ( arrSEARCH_TEXT.Length > 1 )
										dtSEARCH_TEXT2 = DateTime.ParseExact(sSEARCH_TEXT2, "yyyy/MM/dd", Thread.CurrentThread.CurrentCulture.DateTimeFormat);
								}
								switch ( sOPERATOR )
								{
									case "on"               :  ctlFILTER_SEARCH_START_DATE.DateText = dtSEARCH_TEXT1.ToShortDateString();  break;
									case "before"           :  ctlFILTER_SEARCH_START_DATE.DateText = dtSEARCH_TEXT1.ToShortDateString();  break;
									case "after"            :  ctlFILTER_SEARCH_START_DATE.DateText = dtSEARCH_TEXT1.ToShortDateString();  break;
									case "not_equals_str"   :  ctlFILTER_SEARCH_START_DATE.DateText = dtSEARCH_TEXT1.ToShortDateString();  break;
									case "between_dates"    :
										ctlFILTER_SEARCH_START_DATE.DateText = dtSEARCH_TEXT1.ToShortDateString();
										if ( arrSEARCH_TEXT.Length > 1 )
											ctlFILTER_SEARCH_END_DATE  .DateText = dtSEARCH_TEXT2.ToShortDateString();
										break;
									case "empty"            :  break;
									case "not_empty"        :  break;
									case "is_before"        :  break;
									case "is_after"         :  break;
									case "tp_yesterday"     :  break;
									case "tp_today"         :  break;
									case "tp_tomorrow"      :  break;
									case "tp_last_7_days"   :  break;
									case "tp_next_7_days"   :  break;
									case "tp_last_month"    :  break;
									case "tp_this_month"    :  break;
									case "tp_next_month"    :  break;
									case "tp_last_30_days"  :  break;
									case "tp_next_30_days"  :  break;
									case "tp_last_year"     :  break;
									case "tp_this_year"     :  break;
									case "tp_next_year"     :  break;
									case "changed"          :  break;
									case "unchanged"        :  break;
									case "increased"        :  break;
									case "decreased"        :  break;
									// 11/16/2008 Paul.  Days old 
									case "tp_minutes_after" :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
									case "tp_hours_after"   :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
									case "tp_days_after"    :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
									case "tp_weeks_after"   :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
									case "tp_months_after"  :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
									case "tp_years_after"   :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
									case "tp_minutes_before":  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
									case "tp_hours_before"  :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
									case "tp_days_before"   :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
									case "tp_weeks_before"  :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
									case "tp_months_before" :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
									case "tp_years_before"  :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
									// 12/04/2008 Paul.  We need to be able to do an an equals. 
									case "tp_days_old"      :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
									case "tp_weeks_old"     :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
									case "tp_months_old"    :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
									case "tp_years_old"     :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								}
							}
							break;
						}
						case "int32":
						{
							switch ( sOPERATOR )
							{
								case "equals"    :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "less"      :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "greater"   :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "between"   :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  txtFILTER_SEARCH_TEXT2.Text = sSEARCH_TEXT2;  break;
								case "not_equals":  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "empty"     :  break;
								case "not_empty" :  break;
								// 07/23/2013 Paul.  Add greater and less than conditions. 
								case "less_equal"     :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "greater_equal"  :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
							}
							break;
						}
						case "decimal":
						{
							switch ( sOPERATOR )
							{
								case "equals"    :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "less"      :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "greater"   :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "between"   :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  txtFILTER_SEARCH_TEXT2.Text = sSEARCH_TEXT2;  break;
								case "not_equals":  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "empty"     :  break;
								case "not_empty" :  break;
								// 07/23/2013 Paul.  Add greater and less than conditions. 
								case "less_equal"     :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "greater_equal"  :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
							}
							break;
						}
						case "float":
						{
							switch ( sOPERATOR )
							{
								case "equals"    :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "less"      :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "greater"   :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "between"   :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  txtFILTER_SEARCH_TEXT2.Text = sSEARCH_TEXT2;  break;
								case "not_equals":  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "empty"     :  break;
								case "not_empty" :  break;
								// 07/23/2013 Paul.  Add greater and less than conditions. 
								case "less_equal"     :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
								case "greater_equal"  :  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT1;  break;
							}
							break;
						}
						case "bool":
						{
							switch ( sOPERATOR )
							{
								case "equals"    :
									try
									{
										// 12/20/2006 Paul.  Catch and ignore the exception. 
										// 08/19/2010 Paul.  Check the list before assigning the value. 
										Utils.SetSelectedValue(lstFILTER_SEARCH_DROPDOWN, sSEARCH_TEXT1);
									}
									catch
									{
									}
									break;
								case "empty"     :  break;
								case "not_empty" :  break;
							}
							break;
						}
						case "guid":
						{
							switch ( sOPERATOR )
							{
								// 05/05/2010 Paul.  We store both the ID and the Name for a Guid IS. 
								case "is"            :  txtFILTER_SEARCH_ID  .Value = sSEARCH_TEXT1;  txtFILTER_SEARCH_TEXT.Text = sSEARCH_TEXT2;  break;
								case "equals"        :  txtFILTER_SEARCH_TEXT.Text  = sSEARCH_TEXT1;  break;
								case "contains"      :  txtFILTER_SEARCH_TEXT.Text  = sSEARCH_TEXT1;  break;
								case "starts_with"   :  txtFILTER_SEARCH_TEXT.Text  = sSEARCH_TEXT1;  break;
								case "ends_with"     :  txtFILTER_SEARCH_TEXT.Text  = sSEARCH_TEXT1;  break;
								case "not_equals_str":  txtFILTER_SEARCH_TEXT.Text  = sSEARCH_TEXT1;  break;
								case "empty"         :  break;
								case "not_empty"     :  break;
								case "one_of"        :
								{
									// 05/20/2009 Paul.  If this is a one-of guid, then populate the listbox user or team names. 
									foreach ( string s in arrSEARCH_TEXT )
									{
										for ( int i = 0; i < lstFILTER_SEARCH_LISTBOX.Items.Count; i++ )
										{
											if ( s == lstFILTER_SEARCH_LISTBOX.Items[i].Value )
												lstFILTER_SEARCH_LISTBOX.Items[i].Selected = true;
										}
									}
									break;
								}
							}
							break;
						}
						case "enum":
						{
							switch ( sOPERATOR )
							{
								case "is"            :
									try
									{
										// 12/20/2006 Paul.  Catch and ignore the exception. 
										// 08/19/2010 Paul.  Check the list before assigning the value. 
										Utils.SetSelectedValue(lstFILTER_SEARCH_DROPDOWN, sSEARCH_TEXT1);
									}
									catch
									{
									}
									break;
								case "one_of":
								{
									foreach ( string s in arrSEARCH_TEXT )
									{
										for ( int i = 0; i < lstFILTER_SEARCH_LISTBOX.Items.Count; i++ )
										{
											if ( s == lstFILTER_SEARCH_LISTBOX.Items[i].Value )
												lstFILTER_SEARCH_LISTBOX.Items[i].Selected = true;
										}
									}
									break;
								}
								case "empty"         :  break;
								case "not_empty"     :  break;
							}
							break;
						}
					}
					if ( Command != null )
						Command(sender, e);
				}
				else if ( e.CommandName == "Filters.Update" )
				{
					string sFILTER_ID    = txtFILTER_ID.Value;
					string sMODULE_NAME  = lstFILTER_COLUMN_SOURCE.SelectedValue;
					string sDATA_FIELD   = lstFILTER_COLUMN       .SelectedValue;
					string sDATA_TYPE    = txtFILTER_SEARCH_DATA_TYPE.Value;
					string sOPERATOR     = lstFILTER_OPERATOR     .SelectedValue;
					
					string[] arrSEARCH_TEXT = new string[0];
					// 07/06/2007 Paul.  ansistring is treated the same as string. 
					string sCOMMON_DATA_TYPE = sDATA_TYPE;
					if ( sCOMMON_DATA_TYPE == "ansistring" )
						sCOMMON_DATA_TYPE = "string";
					switch ( sCOMMON_DATA_TYPE )
					{
						case "string":
						{
							switch ( sOPERATOR )
							{
								case "equals"        :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "contains"      :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "starts_with"   :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "ends_with"     :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "not_equals_str":  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "empty"         :  break;
								case "not_empty"     :  break;
								// 08/25/2011 Paul.  A customer wants more use of NOT in string filters. 
								case "not_contains"   :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "not_starts_with":  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "not_ends_with"  :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								// 02/14/2013 Paul.  A customer wants to use like in string filters. 
								case "like"           :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "not_like"       :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								// 07/23/2013 Paul.  Add greater and less than conditions. 
								case "less"          :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "less_equal"    :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "greater"       :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "greater_equal" :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
							}
							break;
						}
						case "datetime":
						{
							switch ( sOPERATOR )
							{
								case "on"               :  arrSEARCH_TEXT = new string[] { Sql.ToDateTime(ctlFILTER_SEARCH_START_DATE.DateText).ToString("yyyy/MM/dd") };  break;
								case "before"           :  arrSEARCH_TEXT = new string[] { Sql.ToDateTime(ctlFILTER_SEARCH_START_DATE.DateText).ToString("yyyy/MM/dd") };  break;
								case "after"            :  arrSEARCH_TEXT = new string[] { Sql.ToDateTime(ctlFILTER_SEARCH_START_DATE.DateText).ToString("yyyy/MM/dd") };  break;
								case "not_equals_str"   :  arrSEARCH_TEXT = new string[] { Sql.ToDateTime(ctlFILTER_SEARCH_START_DATE.DateText).ToString("yyyy/MM/dd") };  break;
								case "between_dates"    :  arrSEARCH_TEXT = new string[] { Sql.ToDateTime(ctlFILTER_SEARCH_START_DATE.DateText).ToString("yyyy/MM/dd"), Sql.ToDateTime(ctlFILTER_SEARCH_END_DATE.DateText).ToString("yyyy/MM/dd") };  break;
								case "empty"            :  break;
								case "not_empty"        :  break;
								case "is_before"        :  break;
								case "is_after"         :  break;
								case "tp_yesterday"     :  break;
								case "tp_today"         :  break;
								case "tp_tomorrow"      :  break;
								case "tp_last_7_days"   :  break;
								case "tp_next_7_days"   :  break;
								case "tp_last_month"    :  break;
								case "tp_this_month"    :  break;
								case "tp_next_month"    :  break;
								case "tp_last_30_days"  :  break;
								case "tp_next_30_days"  :  break;
								case "tp_last_year"     :  break;
								case "tp_this_year"     :  break;
								case "tp_next_year"     :  break;
								case "changed"          :  break;
								case "unchanged"        :  break;
								case "increased"        :  break;
								case "decreased"        :  break;
								case "tp_minutes_after" :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "tp_hours_after"   :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "tp_days_after"    :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "tp_weeks_after"   :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "tp_months_after"  :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "tp_years_after"   :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "tp_minutes_before":  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "tp_hours_before"  :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "tp_days_before"   :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "tp_weeks_before"  :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "tp_months_before" :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "tp_years_before"  :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								// 12/04/2008 Paul.  We need to be able to do an an equals. 
								case "tp_days_old"      :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "tp_weeks_old"     :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "tp_months_old"    :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "tp_years_old"     :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
							}
							break;
						}
						case "int32":
						{
							switch ( sOPERATOR )
							{
								case "equals"    :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "less"      :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "greater"   :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "between"   :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text, txtFILTER_SEARCH_TEXT2.Text };  break;
								case "not_equals":  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "empty"     :  break;
								case "not_empty" :  break;
								// 07/23/2013 Paul.  Add greater and less than conditions. 
								case "less_equal"    :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "greater_equal" :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
							}
							break;
						}
						case "decimal":
						{
							switch ( sOPERATOR )
							{
								case "equals"    :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "less"      :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "greater"   :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "between"   :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text, txtFILTER_SEARCH_TEXT2.Text };  break;
								case "not_equals":  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "empty"     :  break;
								case "not_empty" :  break;
								// 07/23/2013 Paul.  Add greater and less than conditions. 
								case "less_equal"    :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "greater_equal" :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
							}
							break;
						}
						case "float":
						{
							switch ( sOPERATOR )
							{
								case "equals"    :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "less"      :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "greater"   :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "between"   :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text, txtFILTER_SEARCH_TEXT2.Text };  break;
								case "not_equals":  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "empty"     :  break;
								case "not_empty" :  break;
								// 07/23/2013 Paul.  Add greater and less than conditions. 
								case "less_equal"    :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "greater_equal" :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
							}
							break;
						}
						case "bool":
						{
							switch ( sOPERATOR )
							{
								case "equals"    :  arrSEARCH_TEXT = new string[] { lstFILTER_SEARCH_DROPDOWN.SelectedValue };  break;
								case "empty"     :  break;
								case "not_empty" :  break;
							}
							break;
						}
						case "guid":
						{
							switch ( sOPERATOR )
							{
								// 05/05/2010 Paul.  We store both the ID and the Name for a Guid IS. 
								// 05/05/2010 Paul.  Since the txtFILTER_SEARCH_TEXT field is ReadOnly, .NET will not get the value. 
								// The submitted value is still available from the Request object. 
								case "is"            :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_ID.Value , Sql.ToString(Request[txtFILTER_SEARCH_TEXT.UniqueID]) };  break;
								case "equals"        :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "contains"      :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "starts_with"   :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "ends_with"     :  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "not_equals_str":  arrSEARCH_TEXT = new string[] { txtFILTER_SEARCH_TEXT.Text };  break;
								case "empty"         :  break;
								case "not_empty"     :  break;
								// 05/20/2009 Paul.  If this is a one-of guid, then populate the listbox user or team names. 
								case "one_of"        :  arrSEARCH_TEXT = Sql.ToStringArray(lstFILTER_SEARCH_LISTBOX);  break;
							}
							break;
						}
						case "enum":
						{
							switch ( sOPERATOR )
							{
								case "is"            :  arrSEARCH_TEXT = new string[] { lstFILTER_SEARCH_DROPDOWN.SelectedValue };  break;
								case "one_of"        :  arrSEARCH_TEXT = Sql.ToStringArray(lstFILTER_SEARCH_LISTBOX);  break;
								case "empty"         :  break;
								case "not_empty"     :  break;
							}
							break;
						}
					}
					FiltersUpdate(sFILTER_ID, sMODULE_NAME, sDATA_FIELD, sDATA_TYPE, sOPERATOR, arrSEARCH_TEXT );
					// 05/14/2021 Paul.  Convert to static method so that we can use in the React client. 
					Hashtable hashAvailableModules = new Hashtable();
					StringBuilder sbErrors = new StringBuilder();
					sReportSQL = BuildReportSQL(Application, rdl, bPrimaryKeyOnly, bUseSQLParameters, bDesignChart, bUserSpecific, lstMODULE.SelectedValue, lstRELATED.SelectedValue, hashAvailableModules, sbErrors);
					if ( sbErrors.Length > 0 )
						lblError.Text = sbErrors.ToString();
					ResetSearchText();
					if ( Command != null )
						Command(sender, e);
				}
				else if ( e.CommandName == "Cancel" )
				{
					Response.Redirect("default.aspx");
				}
			}
			catch(Exception ex)
			{
				lblError.Text = ex.Message;
			}
		}
		#endregion

		#region Changed
		protected void lstMODULE_Changed(Object sender, EventArgs e)
		{
			lblMODULE.Text = lstMODULE.SelectedValue;
			// 05/26/2006 Paul.  If the module changes, then throw away everything. 
			// The display columns don't count, the group columns don't count, etc. 
			rdl = new RdlDocument(String.Empty, String.Empty, bDesignChart);
			rdl.SetCustomProperty("Module"        , lstMODULE.SelectedValue );
			rdl.SetCustomProperty("Related"       , String.Empty);
			rdl.SetCustomProperty("RelatedModules", String.Empty);
			rdl.SetCustomProperty("Relationships" , String.Empty);
			rdl.SetCustomProperty("Filters"       , String.Empty);
			if ( bDesignChart )
			{
				rdl.SetCustomProperty("Charts"       , String.Empty);
			}
			lstRELATED_Bind();
			// 11/09/2011 Paul.  If the module changes, then we need to update the chart. 
			if ( bDesignChart )
			{
				DisplayColumnsUpdate();
				UpdateChart();
			}
			dgFilters.DataSource = ReportFilters();
			dgFilters.DataBind();
			// 05/14/2021 Paul.  Convert to static method so that we can use in the React client. 
			Hashtable hashAvailableModules = new Hashtable();
			StringBuilder sbErrors = new StringBuilder();
			sReportSQL = BuildReportSQL(Application, rdl, bPrimaryKeyOnly, bUseSQLParameters, bDesignChart, bUserSpecific, lstMODULE.SelectedValue, lstRELATED.SelectedValue, hashAvailableModules, sbErrors);
			if ( sbErrors.Length > 0 )
				lblError.Text = sbErrors.ToString();
			// 07/13/2006 Paul.  The DisplayColumns List must be bound after the ReportSQL is built. 
			lstLeftListBox_Bind();
			if ( Command != null )
			{
				CommandEventArgs args = new CommandEventArgs("Filters.Change", "Module");
				Command(sender, args);
			}
		}

		protected void lstRELATED_Changed(Object sender, EventArgs e)
		{
			lblRELATED.Text = lstRELATED.SelectedValue;
			rdl.SetCustomProperty("Related"      , lstRELATED.SelectedValue);
			rdl.SetCustomProperty("Relationships", String.Empty);
			lstFILTER_COLUMN_SOURCE_Bind();
			// 06/13/2006 Paul.  If the related module changes, then make sure to remove any unavailable filters. 
			RemoveInvalidFilters();
			// 07/13/2006 Paul.  Remove invalid display columns as well. 
			RemoveInvalidDisplayColumns();
			// 05/14/2021 Paul.  Convert to static method so that we can use in the React client. 
			Hashtable hashAvailableModules = new Hashtable();
			StringBuilder sbErrors = new StringBuilder();
			sReportSQL = BuildReportSQL(Application, rdl, bPrimaryKeyOnly, bUseSQLParameters, bDesignChart, bUserSpecific, lstMODULE.SelectedValue, lstRELATED.SelectedValue, hashAvailableModules, sbErrors);
			if ( sbErrors.Length > 0 )
				lblError.Text = sbErrors.ToString();
			// 07/13/2006 Paul.  The DisplayColumns List must be bound after the ReportSQL is built. 
			lstLeftListBox_Bind();
			if ( Command != null )
			{
				CommandEventArgs args = new CommandEventArgs("Filters.Change", "Related");
				Command(sender, args);
			}
		}

		protected void lstMODULE_COLUMN_SOURCE_Changed(Object sender, EventArgs e)
		{
			lblMODULE_COLUMN_SOURCE.Text = lstMODULE_COLUMN_SOURCE.SelectedValue;
			ctlDisplayColumnsChooser_Bind();
			// 11/09/2011 Paul.  If the module changes, then we need to update the chart. 
			if ( bDesignChart )
			{
				DisplayColumnsUpdate();
				UpdateChart();
			}
			if ( Command != null )
			{
				CommandEventArgs args = new CommandEventArgs("Filters.Change", "ModuleColumnSource");
				Command(sender, args);
			}
		}

		protected void lstFILTER_COLUMN_SOURCE_Changed(Object sender, EventArgs e)
		{
			lblFILTER_COLUMN_SOURCE.Text = lstFILTER_COLUMN_SOURCE.SelectedValue;
			lstFILTER_COLUMN_Bind();
			if ( Command != null )
			{
				CommandEventArgs args = new CommandEventArgs("Filters.Change", "FilterColumnSource");
				Command(sender, args);
			}
		}

		protected void lstFILTER_COLUMN_Changed(Object sender, EventArgs e)
		{
			lblFILTER_COLUMN.Text = lstFILTER_COLUMN.SelectedValue;
			lstFILTER_OPERATOR_Bind();
			if ( Command != null )
			{
				CommandEventArgs args = new CommandEventArgs("Filters.Change", "FilterColumn");
				Command(sender, args);
			}
		}

		protected void lstFILTER_OPERATOR_Changed(Object sender, EventArgs e)
		{
			lblFILTER_OPERATOR.Text = lstFILTER_OPERATOR.SelectedValue;
			BindSearchText();
			if ( Command != null )
			{
				CommandEventArgs args = new CommandEventArgs("Filters.Change", "FilterOperator");
				Command(sender, args);
			}
		}
		#endregion

		#region Bind
		private void lstRELATED_Bind()
		{
			DataView vwRelationships = new DataView(SplendidCache.ReportingRelationships());
			vwRelationships.RowFilter = "       RELATIONSHIP_TYPE = 'many-to-many' " + ControlChars.CrLf
			                          + "   and LHS_MODULE        = \'" + lstMODULE.SelectedValue + "\'" + ControlChars.CrLf;
			// 06/10/2006 Paul.  Filter by the modules that the user has access to. 
			Sql.AppendParameter(vwRelationships, SplendidCache.ReportingModulesList(), "RHS_MODULE", false);

			XmlDocument xmlRelationships = new XmlDocument();
			xmlRelationships.AppendChild(xmlRelationships.CreateElement("Relationships"));
			
			XmlNode xRelationship = null;
			foreach(DataRowView row in vwRelationships)
			{
				string sRELATIONSHIP_NAME              = Sql.ToString(row["RELATIONSHIP_NAME"             ]);
				string sLHS_MODULE                     = Sql.ToString(row["LHS_MODULE"                    ]);
				string sLHS_TABLE                      = Sql.ToString(row["LHS_TABLE"                     ]).ToUpper();
				string sLHS_KEY                        = Sql.ToString(row["LHS_KEY"                       ]).ToUpper();
				string sRHS_MODULE                     = Sql.ToString(row["RHS_MODULE"                    ]);
				string sRHS_TABLE                      = Sql.ToString(row["RHS_TABLE"                     ]).ToUpper();
				string sRHS_KEY                        = Sql.ToString(row["RHS_KEY"                       ]).ToUpper();
				string sJOIN_TABLE                     = Sql.ToString(row["JOIN_TABLE"                    ]).ToUpper();
				string sJOIN_KEY_LHS                   = Sql.ToString(row["JOIN_KEY_LHS"                  ]).ToUpper();
				string sJOIN_KEY_RHS                   = Sql.ToString(row["JOIN_KEY_RHS"                  ]).ToUpper();
				// 11/20/2008 Paul.  Quotes, Orders and Invoices have a relationship column. 
				string sRELATIONSHIP_ROLE_COLUMN       = Sql.ToString(row["RELATIONSHIP_ROLE_COLUMN"      ]).ToUpper();
				string sRELATIONSHIP_ROLE_COLUMN_VALUE = Sql.ToString(row["RELATIONSHIP_ROLE_COLUMN_VALUE"]);
				string sMODULE_NAME       = sRHS_MODULE + " " + sRHS_TABLE;
				string sDISPLAY_NAME      = L10n.Term(".moduleList." + sRHS_MODULE);
				// 10/26/2011 Paul.  Use the join table so that the display is more descriptive. 
				if ( !Sql.IsEmptyString(sJOIN_TABLE) )
					sDISPLAY_NAME = Sql.CamelCaseModules(L10n, sJOIN_TABLE);
				if ( bDebug )
				{
					sDISPLAY_NAME = "[" + sMODULE_NAME + "] " + sDISPLAY_NAME;
				}
				// 02/18/2009 Paul.  Include the relationship column if provided. 
				// 10/26/2011 Paul.  Include the role. 
				if ( !Sql.IsEmptyString(sRELATIONSHIP_ROLE_COLUMN) && !Sql.IsEmptyString(sRELATIONSHIP_ROLE_COLUMN_VALUE) && sRELATIONSHIP_ROLE_COLUMN_VALUE != lstMODULE.SelectedValue )
					sDISPLAY_NAME += " " + sRELATIONSHIP_ROLE_COLUMN_VALUE;
				// 10/26/2011 Paul.  Add the relationship so that we can have a unique lookup. 
				sMODULE_NAME += " " + sRELATIONSHIP_NAME;
				
				xRelationship = xmlRelationships.CreateElement("Relationship");
				xmlRelationships.DocumentElement.AppendChild(xRelationship);
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RELATIONSHIP_NAME"             , sRELATIONSHIP_NAME             );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "LHS_MODULE"                    , sLHS_MODULE                    );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "LHS_TABLE"                     , sLHS_TABLE                     );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "LHS_KEY"                       , sLHS_KEY                       );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RHS_MODULE"                    , sRHS_MODULE                    );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RHS_TABLE"                     , sRHS_TABLE                     );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RHS_KEY"                       , sRHS_KEY                       );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "JOIN_TABLE"                    , sJOIN_TABLE                    );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "JOIN_KEY_LHS"                  , sJOIN_KEY_LHS                  );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "JOIN_KEY_RHS"                  , sJOIN_KEY_RHS                  );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RELATIONSHIP_TYPE"             , "many-to-many"                 );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "MODULE_NAME"                   , sMODULE_NAME                   );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "DISPLAY_NAME"                  , sDISPLAY_NAME                  );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RELATIONSHIP_ROLE_COLUMN"      , sRELATIONSHIP_ROLE_COLUMN      );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RELATIONSHIP_ROLE_COLUMN_VALUE", sRELATIONSHIP_ROLE_COLUMN_VALUE);
			}
			rdl.SetCustomProperty("RelatedModules", xmlRelationships.OuterXml.Replace("</Relationship>", "</Relationship>" + ControlChars.CrLf));

			DataTable dtModules = XmlUtil.CreateDataTable(xmlRelationships.DocumentElement, "Relationship", new string[] {"MODULE_NAME", "DISPLAY_NAME"});
			DataView vwModules = new DataView(dtModules);
			vwModules.Sort = "DISPLAY_NAME";
			lstRELATED.DataSource = vwModules;
			lstRELATED.DataBind();
			lstRELATED.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
			
			lstFILTER_COLUMN_SOURCE_Bind();
			lblRELATED.Text = lstRELATED.SelectedValue;
		}

		private void lstFILTER_COLUMN_SOURCE_Bind()
		{
			// 07/13/2006 Paul.  Convert the module name to the correct table name. 
			string sModule = lstMODULE.SelectedValue;
			DataView vwRelationships = new DataView(SplendidCache.ReportingRelationships());
			vwRelationships.RowFilter = "       RELATIONSHIP_TYPE = 'one-to-many' " + ControlChars.CrLf
			                          + "   and RHS_MODULE        = \'" + sModule + "\'" + ControlChars.CrLf;
			// 06/10/2006 Paul.  Filter by the modules that the user has access to. 
			Sql.AppendParameter(vwRelationships, SplendidCache.ReportingModulesList(), "RHS_MODULE", false);
			vwRelationships.Sort = "RHS_KEY";


			XmlDocument xmlRelationships = new XmlDocument();
			xmlRelationships.AppendChild(xmlRelationships.CreateElement("Relationships"));
			
			XmlNode xRelationship = xmlRelationships.CreateElement("Relationship");
			xmlRelationships.DocumentElement.AppendChild(xRelationship);

			string sMODULE_TABLE = Sql.ToString(Application["Modules." + sModule + ".TableName"]);
			XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RELATIONSHIP_NAME", sModule      );
			XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "LHS_MODULE"       , sModule      );
			XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "LHS_TABLE"        , sMODULE_TABLE);
			XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "LHS_KEY"          , String.Empty );
			XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RHS_MODULE"       , String.Empty );
			XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RHS_TABLE"        , String.Empty );
			XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RHS_KEY"          , String.Empty );
			XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RELATIONSHIP_TYPE", String.Empty );
			XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "MODULE_ALIAS"     , sMODULE_TABLE);
			XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "MODULE_NAME"      , sModule + " " + sMODULE_TABLE);
			// 07/29/2008 Paul.  The module name needs to be translated as it will be used in the field headers. 
			if ( bDebug )
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "DISPLAY_NAME"     , "[" + L10n.Term(".moduleList." + sModule) + " " + sMODULE_TABLE + "] " + L10n.Term(".moduleList." + sModule));
			else
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "DISPLAY_NAME"     , L10n.Term(".moduleList." + sModule));
			
			foreach(DataRowView row in vwRelationships)
			{
				string sRELATIONSHIP_NAME = Sql.ToString(row["RELATIONSHIP_NAME"]);
				string sLHS_MODULE        = Sql.ToString(row["LHS_MODULE"       ]);
				string sLHS_TABLE         = Sql.ToString(row["LHS_TABLE"        ]).ToUpper();
				string sLHS_KEY           = Sql.ToString(row["LHS_KEY"          ]).ToUpper();
				string sRHS_MODULE        = Sql.ToString(row["RHS_MODULE"       ]);
				string sRHS_TABLE         = Sql.ToString(row["RHS_TABLE"        ]).ToUpper();
				string sRHS_KEY           = Sql.ToString(row["RHS_KEY"          ]).ToUpper();
				// 07/13/2006 Paul.  It may seem odd the way we are combining LHS_TABLE and RHS_KEY,  but we do it this way for a reason.  
				// The table alias to get to an Email Assigned User ID will be USERS_ASSIGNED_USER_ID. 
				string sMODULE_NAME       = sLHS_MODULE + " " + sLHS_TABLE + "_" + sRHS_KEY;
				// 11/15/2013 Paul.  The module name needs to be translated as it will be used in the field headers. 
				string sDISPLAY_NAME      = L10n.Term(".moduleList." + sRHS_MODULE);
				
				// 07/09/2007 Paul.  Fixes from Version 1.2 on 04/17/2007 were not included in Version 1.4 tree.
				switch ( sRHS_KEY.ToUpper() )
				{
					// 04/17/2007 Paul.  CREATED_BY was renamed CREATED_BY_ID in all views a long time ago. It is just now being fixed here. 
					case "CREATED_BY_ID":
						sDISPLAY_NAME = L10n.Term(".moduleList." + sRHS_MODULE) + ": " + L10n.Term(".LBL_CREATED_BY_USER");
						break;
					case "MODIFIED_USER_ID":
						sDISPLAY_NAME = L10n.Term(".moduleList." + sRHS_MODULE) + ": " + L10n.Term(".LBL_MODIFIED_BY_USER");
						break;
					case "ASSIGNED_USER_ID":
						sDISPLAY_NAME = L10n.Term(".moduleList." + sRHS_MODULE) + ": " + L10n.Term(".LBL_ASSIGNED_TO_USER");
						break;
					// 04/17/2007 Paul.  PARENT_ID is a special case where we want to know the type of the parent. 
					case "PARENT_ID":
						sDISPLAY_NAME = L10n.Term(".moduleList." + sRHS_MODULE) + ": " + L10n.Term(".moduleList." + sLHS_MODULE) + " " + L10n.Term(".LBL_PARENT_ID");
						break;
					default:
						sDISPLAY_NAME = L10n.Term(".moduleList." + sRHS_MODULE) + ": " + Utils.TableColumnName(L10n, sRHS_MODULE, sRHS_KEY);
						break;
				}
				if ( bDebug )
				{
					sDISPLAY_NAME = "[" + sMODULE_NAME + "] " + sDISPLAY_NAME;
				}
				
				xRelationship = xmlRelationships.CreateElement("Relationship");
				xmlRelationships.DocumentElement.AppendChild(xRelationship);
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RELATIONSHIP_NAME", sRELATIONSHIP_NAME);
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "LHS_MODULE"       , sLHS_MODULE       );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "LHS_TABLE"        , sLHS_TABLE        );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "LHS_KEY"          , sLHS_KEY          );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RHS_MODULE"       , sRHS_MODULE       );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RHS_TABLE"        , sRHS_TABLE        );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RHS_KEY"          , sRHS_KEY          );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RELATIONSHIP_TYPE", "one-to-many"     );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "MODULE_ALIAS"     , sLHS_TABLE + "_" + sRHS_KEY);  // This is just the alias. 
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "MODULE_NAME"      , sMODULE_NAME      );  // Module name includes the alias. 
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "DISPLAY_NAME"     , sDISPLAY_NAME     );
			}
			if ( !Sql.IsEmptyString(lstRELATED.SelectedValue) )
			{
				xRelationship = xmlRelationships.CreateElement("Relationship");
				xmlRelationships.DocumentElement.AppendChild(xRelationship);
				string sRELATED_MODULE    = lstRELATED.SelectedValue.Split(' ')[0];
				string sRELATED_ALIAS     = lstRELATED.SelectedValue.Split(' ')[1];
				// 10/26/2011 Paul.  Add the relationship so that we can have a unique lookup. 
				string sRELATIONSHIP_NAME = lstRELATED.SelectedValue.Split(' ')[2];
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RELATIONSHIP_NAME", sRELATIONSHIP_NAME);
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "LHS_MODULE"       , sRELATED_MODULE   );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "LHS_TABLE"        , sRELATED_ALIAS    );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "LHS_KEY"          , String.Empty      );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RHS_MODULE"       , String.Empty      );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RHS_TABLE"        , String.Empty      );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RHS_KEY"          , String.Empty      );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "RELATIONSHIP_TYPE", "many-to-many"    );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "MODULE_ALIAS"     , sRELATED_ALIAS    );
				XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "MODULE_NAME"      , sRELATED_MODULE + " " + sRELATED_ALIAS);
				// 07/29/2008 Paul.  The module name needs to be translated as it will be used in the field headers. 
				if ( bDebug )
					XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "DISPLAY_NAME"     , "[" + L10n.Term(".moduleList." + sRELATED_MODULE) + " " + sRELATED_ALIAS + "] " + L10n.Term(".moduleList." + sRELATED_MODULE));
				else
					XmlUtil.SetSingleNode(xmlRelationships, xRelationship, "DISPLAY_NAME"     , L10n.Term(".moduleList." + sRELATED_MODULE));
			}
			rdl.SetCustomProperty("Relationships", xmlRelationships.OuterXml.Replace("</Relationship>", "</Relationship>" + ControlChars.CrLf));

			DataTable dtModuleColumnSource = XmlUtil.CreateDataTable(xmlRelationships.DocumentElement, "Relationship", new string[] {"MODULE_NAME", "DISPLAY_NAME"});
			lstMODULE_COLUMN_SOURCE.DataSource = dtModuleColumnSource;
			lstMODULE_COLUMN_SOURCE.DataBind();
			lblMODULE_COLUMN_SOURCE.Text = lstMODULE_COLUMN_SOURCE.SelectedValue;
			// 05/29/2006 Paul.  Filter column source is always the same as module column source. 
			lstFILTER_COLUMN_SOURCE.DataSource = dtModuleColumnSource;
			lstFILTER_COLUMN_SOURCE.DataBind();
			lblFILTER_COLUMN_SOURCE.Text = lstFILTER_COLUMN_SOURCE.SelectedValue;

			ctlDisplayColumnsChooser_Bind();
			lstFILTER_COLUMN_Bind();
		}

		private void ctlDisplayColumnsChooser_Bind()
		{
			string[] arrModule = lstMODULE_COLUMN_SOURCE.SelectedValue.Split(' ');
			string sModule     = arrModule[0];
			string sTableAlias = arrModule[1];

			string sMODULE_TABLE = Sql.ToString(Application["Modules." + sModule + ".TableName"]);
			DataTable dtColumns = SplendidCache.ReportingFilterColumns(sMODULE_TABLE).Copy();
			foreach(DataRow row in dtColumns.Rows)
			{
				row["NAME"] = sTableAlias + "." + Sql.ToString(row["NAME"]);
				// 07/04/2006 Paul.  Some columns have global terms. 
				row["DISPLAY_NAME"] = Utils.TableColumnName(L10n, sModule, Sql.ToString(row["DISPLAY_NAME"]));
			}
			// 06/21/2006 Paul.  Do not sort the columns  We want it to remain sorted by COLID. This should keep the NAME at the top. 
			DataView vwColumns = new DataView(dtColumns);

			// 06/15/2006 Paul.  The list of Display Columns is now stored in a custom field. 
			// This is because the DataSet/Fields tag is used to store all available fields and their data types. 
			StringBuilder sbFieldsList = new StringBuilder();
			
			XmlDocument xmlDisplayColumns = rdl.GetCustomProperty("DisplayColumns");
			XmlNodeList nlFields = xmlDisplayColumns.DocumentElement.SelectNodes("DisplayColumn/Field");
			foreach ( XmlNode xField in nlFields )
			{
				if ( sbFieldsList.Length > 0 )
					sbFieldsList.Append(", ");
				sbFieldsList.Append("'" + xField.InnerText + "'");
			}
			
			string sSelectedFields = sbFieldsList.ToString();
			if ( !Sql.IsEmptyString(sSelectedFields) )
				vwColumns.RowFilter = "NAME not in (" + sSelectedFields + ")";
			
			ListBox lstRight = ctlDisplayColumnsChooser.RightListBox;
			lstRight.DataValueField = "NAME";
			lstRight.DataTextField  = "DISPLAY_NAME";
			lstRight.DataSource     = vwColumns;
			lstRight.DataBind();

			if ( bDesignChart )
			{
				// 11/08/2011 Paul.  Make sure not to filter by selected values. 
				vwColumns.RowFilter = String.Empty;
				lstSERIES_COLUMN.DataSource = null;
				lstSERIES_COLUMN.DataBind();
				lstSERIES_COLUMN.DataSource = vwColumns;
				lstSERIES_COLUMN.DataBind();
				lblSERIES_COLUMN.Text = lstSERIES_COLUMN.SelectedValue;
				lstSERIES_OPERATOR_Bind();

				lstCATEGORY_COLUMN.DataSource = null;
				lstCATEGORY_COLUMN.DataBind();
				lstCATEGORY_COLUMN.DataSource = vwColumns;
				lstCATEGORY_COLUMN.DataBind();
				lblCATEGORY_COLUMN.Text = lstCATEGORY_COLUMN.SelectedValue;
				lstCATEGORY_OPERATOR_Bind();
			}
			// 12/08/2015 Paul.  We need to also rebind the LeftListBox. 
			else
			{
				lstLeftListBox_Bind();
			}
		}
		#endregion

		#region Filter
		private void lstFILTER_COLUMN_Bind()
		{
			lstFILTER_COLUMN.DataSource = null;
			lstFILTER_COLUMN.DataBind();

			string[] arrModule = lstFILTER_COLUMN_SOURCE.SelectedValue.Split(' ');
			string sModule     = arrModule[0];
			string sTableAlias = arrModule[1];

			string sMODULE_TABLE = Sql.ToString(Application["Modules." + sModule + ".TableName"]);
			DataTable dtColumns = SplendidCache.ReportingFilterColumns(sMODULE_TABLE).Copy();
			foreach(DataRow row in dtColumns.Rows)
			{
				row["NAME"        ] = sTableAlias + "." + Sql.ToString(row["NAME"]);
				// 07/04/2006 Paul.  Some columns have global terms. 
				row["DISPLAY_NAME"] = Utils.TableColumnName(L10n, sModule, Sql.ToString(row["DISPLAY_NAME"]));
			}
			ViewState["FILTER_COLUMNS"] = dtColumns;
			
			// 06/21/2006 Paul.  Do not sort the columns  We want it to remain sorted by COLID. This should keep the NAME at the top. 
			DataView vwColumns = new DataView(dtColumns);
			lstFILTER_COLUMN.DataSource = vwColumns;
			lstFILTER_COLUMN.DataBind();
			lblFILTER_COLUMN.Text = lstFILTER_COLUMN.SelectedValue;

			lstFILTER_OPERATOR_Bind();
		}

		private void lstFILTER_OPERATOR_Bind()
		{
			lstFILTER_OPERATOR.DataSource = null;
			lstFILTER_OPERATOR.Items.Clear();

			string[] arrModule = lstFILTER_COLUMN_SOURCE.SelectedValue.Split(' ');
			string sModule     = arrModule[0];
			string sTableAlias = arrModule[1];
			
			string[] arrColumn = lstFILTER_COLUMN.SelectedValue.Split('.');
			string sColumnName = arrColumn[0];
			if ( arrColumn.Length > 1 )
				sColumnName = arrColumn[1];
			
			string sMODULE_TABLE = Sql.ToString(Application["Modules." + sModule + ".TableName"]);
			DataView vwColumns = new DataView(SplendidCache.ReportingFilterColumns(sMODULE_TABLE).Copy());
			vwColumns.RowFilter = "ColumnName = '" + sColumnName + "'";
			
			if ( vwColumns.Count > 0 )
			{
				DataRowView row = vwColumns[0];
				string sCsType = Sql.ToString(row["CsType"]);
				lblFILTER_OPERATOR_TYPE.Text = sCsType.ToLower();
				txtFILTER_SEARCH_DATA_TYPE.Value = sCsType.ToLower();
				
				lstFILTER_OPERATOR.DataSource = SplendidCache.List(sCsType.ToLower() + "_operator_dom");
				lstFILTER_OPERATOR.DataBind();
				lblFILTER_OPERATOR.Text = lstFILTER_OPERATOR.SelectedValue;
			}
			BindSearchText();
		}

		private void lstLeftListBox_Bind()
		{
			// This is because it requires the Fields node be fully populated, and that does not occur 
			// until after the ReportSQL is built. 
			ListBox lstLeftListBox = ctlDisplayColumnsChooser.LeftListBox;
			lstLeftListBox.DataTextField  = "text";
			lstLeftListBox.DataValueField = "value";
			lstLeftListBox.DataSource     = rdl.CreateDataTable();
			lstLeftListBox.DataBind();
		}

		private void BindSearchText()
		{
			// 10/22/2008 Paul.  Make sure to clear the ReadOnly flag that may have been set on the previous operator change. 
			txtFILTER_SEARCH_TEXT      .ReadOnly = false;
			txtFILTER_SEARCH_TEXT      .Visible = false;
			txtFILTER_SEARCH_TEXT2     .Visible = false;
			lstFILTER_SEARCH_LISTBOX   .Visible = false;
			lstFILTER_SEARCH_DROPDOWN  .Visible = false;
			ctlFILTER_SEARCH_START_DATE.Visible = false;
			ctlFILTER_SEARCH_END_DATE  .Visible = false;
			lblFILTER_AND_SEPARATOR    .Visible = false;
			btnFILTER_SEARCH_SELECT    .Visible = false;
			// 02/09/2007 Paul.  Clear the lookups if not used. 
			if ( txtFILTER_SEARCH_DATA_TYPE.Value != "enum" )
			{
				lstFILTER_SEARCH_DROPDOWN.DataSource = null;
				lstFILTER_SEARCH_LISTBOX .DataSource = null;
				lstFILTER_SEARCH_DROPDOWN.DataBind();
				lstFILTER_SEARCH_LISTBOX .DataBind();
			}
			// 07/06/2007 Paul.  ansistring is treated the same as string. 
			string sCOMMON_DATA_TYPE = txtFILTER_SEARCH_DATA_TYPE.Value;
			if ( sCOMMON_DATA_TYPE == "ansistring" )
				sCOMMON_DATA_TYPE = "string";
			switch ( sCOMMON_DATA_TYPE )
			{
				case "string":
				{
					switch ( lstFILTER_OPERATOR.SelectedValue )
					{
						case "equals"        :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "contains"      :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "starts_with"   :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "ends_with"     :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "not_equals_str":  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "empty"         :  break;
						case "not_empty"     :  break;
						// 08/25/2011 Paul.  A customer wants more use of NOT in string filters. 
						case "not_contains"   :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "not_starts_with":  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "not_ends_with"  :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						// 02/14/2013 Paul.  A customer wants to use like in string filters. 
						case "like"           :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "not_like"       :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						// 07/23/2013 Paul.  Add greater and less than conditions. 
						case "less"          :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "less_equal"    :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "greater"       :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "greater_equal" :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
					}
					break;
				}
				case "datetime":
				{
					switch ( lstFILTER_OPERATOR.SelectedValue )
					{
						case "on"               :  ctlFILTER_SEARCH_START_DATE.Visible = true;  break;
						case "before"           :  ctlFILTER_SEARCH_START_DATE.Visible = true;  break;
						case "after"            :  ctlFILTER_SEARCH_START_DATE.Visible = true;  break;
						case "between_dates"    :  ctlFILTER_SEARCH_START_DATE.Visible = true;  lblFILTER_AND_SEPARATOR.Visible = true;  ctlFILTER_SEARCH_END_DATE.Visible = true;  break;
						case "not_equals_str"   :  ctlFILTER_SEARCH_START_DATE.Visible = true;  break;
						case "empty"            :  break;
						case "not_empty"        :  break;
						case "is_before"        :  break;
						case "is_after"         :  break;
						case "tp_yesterday"     :  break;
						case "tp_today"         :  break;
						case "tp_tomorrow"      :  break;
						case "tp_last_7_days"   :  break;
						case "tp_next_7_days"   :  break;
						case "tp_last_month"    :  break;
						case "tp_this_month"    :  break;
						case "tp_next_month"    :  break;
						case "tp_last_30_days"  :  break;
						case "tp_next_30_days"  :  break;
						case "tp_last_year"     :  break;
						case "tp_this_year"     :  break;
						case "tp_next_year"     :  break;
						case "changed"          :  break;
						case "unchanged"        :  break;
						case "increased"        :  break;
						case "decreased"        :  break;
						case "tp_minutes_after" :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "tp_hours_after"   :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "tp_days_after"    :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "tp_weeks_after"   :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "tp_months_after"  :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "tp_years_after"   :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "tp_minutes_before":  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "tp_hours_before"  :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "tp_days_before"   :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "tp_weeks_before"  :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "tp_months_before" :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "tp_years_before"  :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						// 12/04/2008 Paul.  We need to be able to do an an equals. 
						case "tp_days_old"      :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "tp_weeks_old"     :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "tp_months_old"    :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "tp_years_old"     :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
					}
					break;
				}
				case "int32":
				{
					switch ( lstFILTER_OPERATOR.SelectedValue )
					{
						case "equals"    :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "less"      :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "greater"   :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "between"   :  txtFILTER_SEARCH_TEXT.Visible = true ;  lblFILTER_AND_SEPARATOR.Visible = true;  txtFILTER_SEARCH_TEXT2.Visible = true ;  break;
						case "not_equals":  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "empty"     :  break;
						case "not_empty" :  break;
						// 07/23/2013 Paul.  Add greater and less than conditions. 
						case "less_equal"    :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "greater_equal" :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
					}
					break;
				}
				case "decimal":
				{
					switch ( lstFILTER_OPERATOR.SelectedValue )
					{
						case "equals"    :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "less"      :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "greater"   :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "between"   :  txtFILTER_SEARCH_TEXT.Visible = true ;  lblFILTER_AND_SEPARATOR.Visible = true;  txtFILTER_SEARCH_TEXT2.Visible = true ;  break;
						case "not_equals":  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "empty"     :  break;
						case "not_empty" :  break;
						// 07/23/2013 Paul.  Add greater and less than conditions. 
						case "less_equal"    :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "greater_equal" :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
					}
					break;
				}
				case "float":
				{
					switch ( lstFILTER_OPERATOR.SelectedValue )
					{
						case "equals"    :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "less"      :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "greater"   :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "between"   :  txtFILTER_SEARCH_TEXT.Visible = true ;  lblFILTER_AND_SEPARATOR.Visible = true;  txtFILTER_SEARCH_TEXT2.Visible = true ;  break;
						case "not_equals":  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "empty"     :  break;
						case "not_empty" :  break;
						// 07/23/2013 Paul.  Add greater and less than conditions. 
						case "less_equal"    :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "greater_equal" :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
					}
					break;
				}
				case "bool":
				{
					switch ( lstFILTER_OPERATOR.SelectedValue )
					{
						case "equals"    :
							// 12/20/2006 Paul.  We need to populate the dropdown for booleans with 1 and 0. 
							lstFILTER_SEARCH_DROPDOWN.Visible = true ;
							lstFILTER_SEARCH_DROPDOWN.Items.Clear();
							lstFILTER_SEARCH_DROPDOWN.Items.Add(new ListItem(L10n.Term(".LBL_YES"), "1"));
							lstFILTER_SEARCH_DROPDOWN.Items.Add(new ListItem(L10n.Term(".LBL_NO" ), "0"));
							break;
						case "empty"     :  break;
						case "not_empty" :  break;
					}
					break;
				}
				case "guid":
				{
					switch ( lstFILTER_OPERATOR.SelectedValue )
					{
						// 05/05/2010 Paul.  The Select button was not being made visible. 
						case "is"            :
						{
							string[] arrModule = lstFILTER_COLUMN_SOURCE.SelectedValue.Split(' ');
							string sModule = arrModule[0];
							
							string[] arrColumn = lstFILTER_COLUMN.SelectedValue.Split('.');
							string sColumnName = arrColumn[0];
							if ( arrColumn.Length > 1 )
								sColumnName = arrColumn[1];
							
							string sMODULE_TYPE = String.Empty;
							switch ( sColumnName )
							{
								case "ID"              :  sMODULE_TYPE = sModule;  break;
								case "CREATED_BY_ID"   :  sMODULE_TYPE = "Users";  break;
								case "MODIFIED_USER_ID":  sMODULE_TYPE = "Users";  break;
								case "ASSIGNED_USER_ID":  sMODULE_TYPE = "Users";  break;
								case "TEAM_ID"         :  sMODULE_TYPE = "Teams";  break;
							}
							txtFILTER_SEARCH_TEXT.Visible   = true;
							txtFILTER_SEARCH_TEXT.ReadOnly  = true;
							btnFILTER_SEARCH_SELECT.Visible = true;
							if ( !Sql.IsEmptyString(sMODULE_TYPE) )
								btnFILTER_SEARCH_SELECT.OnClientClick = "return ModulePopup('" + sMODULE_TYPE + "', '" + txtFILTER_SEARCH_ID.ClientID + "', '" + txtFILTER_SEARCH_TEXT.ClientID + "', null, false, null);";
							break;
						}
						case "equals"        :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "contains"      :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "starts_with"   :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "ends_with"     :  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "not_equals_str":  txtFILTER_SEARCH_TEXT.Visible = true ;  break;
						case "empty"         :  break;
						case "not_empty"     :  break;
						case "one_of"        :
						{
							// 05/20/2009 Paul.  If this is a one-of guid, then populate the listbox user or team names. 
							string[] arrModule = lstFILTER_COLUMN_SOURCE.SelectedValue.Split(' ');
							string sModule = arrModule[0];
							
							string[] arrColumn = lstFILTER_COLUMN.SelectedValue.Split('.');
							string sColumnName = arrColumn[0];
							if ( arrColumn.Length > 1 )
								sColumnName = arrColumn[1];
							
							string sLIST_NAME = String.Empty;
							switch ( sColumnName )
							{
								case "CREATED_BY_ID"   :  sLIST_NAME = "AssignedUser";  break;
								case "MODIFIED_USER_ID":  sLIST_NAME = "AssignedUser";  break;
								case "ASSIGNED_USER_ID":  sLIST_NAME = "AssignedUser";  break;
								case "TEAM_ID"         :  sLIST_NAME = "Teams"       ;  break;
							}
							if ( Sql.IsEmptyString(sLIST_NAME) )
							{
								lstFILTER_SEARCH_LISTBOX .DataSource = null;
								lstFILTER_SEARCH_LISTBOX .DataBind();
							}
							else
							{
								// 10/04/2015 Paul.  Changed custom caches to a dynamic list. 
								System.Collections.Generic.List<SplendidCacheReference> arrCustomCaches = SplendidCache.CustomCaches;
								foreach ( SplendidCacheReference cache in arrCustomCaches )
								{
									if ( cache.Name == sLIST_NAME )
									{
										SplendidCacheCallback cbkDataSource = cache.DataSource;
										lstFILTER_SEARCH_LISTBOX.DataValueField = cache.DataValueField;
										lstFILTER_SEARCH_LISTBOX.DataTextField  = cache.DataTextField ;
										lstFILTER_SEARCH_LISTBOX.DataSource     = cbkDataSource();
										lstFILTER_SEARCH_LISTBOX.DataBind();
										lstFILTER_SEARCH_LISTBOX.Visible = true;
										break;
									}
								}
							}
							break;
						}
					}
					break;
				}
				case "enum":
				{
					// 02/09/2007 Paul.  If this is an enum, then populate the listbox with list names pulled from EDITVIEWS_FIELDS.
					string[] arrModule = lstFILTER_COLUMN_SOURCE.SelectedValue.Split(' ');
					string sModule = arrModule[0];
					
					string[] arrColumn = lstFILTER_COLUMN.SelectedValue.Split('.');
					string sColumnName = arrColumn[0];
					if ( arrColumn.Length > 1 )
						sColumnName = arrColumn[1];
					
					string sMODULE_TABLE = Sql.ToString(Application["Modules." + sModule + ".TableName"]);
					string sLIST_NAME = SplendidCache.ReportingFilterColumnsListName(sMODULE_TABLE, sColumnName);
					if ( Sql.IsEmptyString(sLIST_NAME) )
					{
						lstFILTER_SEARCH_DROPDOWN.DataSource = null;
						lstFILTER_SEARCH_LISTBOX .DataSource = null;
						lstFILTER_SEARCH_DROPDOWN.DataBind();
						lstFILTER_SEARCH_LISTBOX .DataBind();
					}
					else
					{
						lstFILTER_SEARCH_DROPDOWN.DataSource = SplendidCache.List(sLIST_NAME);
						lstFILTER_SEARCH_DROPDOWN.DataBind();
						// 05/20/2009 Paul.  We need to restore the field names as they may have changed in Guid one_of. 
						lstFILTER_SEARCH_LISTBOX.DataValueField = "NAME";
						lstFILTER_SEARCH_LISTBOX.DataTextField  = "DISPLAY_NAME";
						lstFILTER_SEARCH_LISTBOX .DataSource = lstFILTER_SEARCH_DROPDOWN.DataSource;
						lstFILTER_SEARCH_LISTBOX .DataBind();
						switch ( lstFILTER_OPERATOR.SelectedValue )
						{
							case "is"            :  lstFILTER_SEARCH_DROPDOWN.Visible = true;  break;
							case "one_of"        :  lstFILTER_SEARCH_LISTBOX .Visible = true;  break;
							case "empty"         :  break;
							case "not_empty"     :  break;
						}
					}
					break;
				}
			}
		}
		#endregion

		#region Build
		// 04/17/2007 Paul.  We need to apply ACL rules a little different from the standard.
		// 07/09/2007 Paul.  Fixes from Version 1.2 on 04/17/2007 were not included in Version 1.4 tree.
		// 05/14/2021 Paul.  Convert to static method so that we can use in the React client. 
		private static void ACLFilter(HttpApplicationState Application, bool bUseSQLParameters, StringBuilder sbJoin, StringBuilder sbWhere, string sMODULE_NAME, string sACCESS_TYPE, string sASSIGNED_USER_ID_Field, bool bIsCaseSignificantDB)
		{
			// 12/07/2006 Paul.  Not all views use ASSIGNED_USER_ID as the assigned field.  Allow an override. 
			// 11/25/2006 Paul.  Administrators should not be restricted from seeing items because of the team rights.
			// This is so that an administrator can fix any record with a bad team value. 
			// 11/27/2009 Paul.  We need a dynamic way to determine if the module record can be assigned or placed in a team. 
			// Teamed and Assigned flags are automatically determined based on the existence of TEAM_ID and ASSIGNED_USER_ID fields. 
			bool bModuleIsTeamed        = Sql.ToBoolean(Application["Modules." + sMODULE_NAME + ".Teamed"  ]);
			bool bModuleIsAssigned      = Sql.ToBoolean(Application["Modules." + sMODULE_NAME + ".Assigned"]);
			bool bEnableTeamManagement  = Crm.Config.enable_team_management();
			bool bRequireTeamManagement = Crm.Config.require_team_management();
			bool bRequireUserAssignment = Crm.Config.require_user_assignment();
			// 11/27/2009 Paul.  Allow dynamic teams to be turned off. 
			bool bEnableDynamicTeams    = Crm.Config.enable_dynamic_teams();
			// 02/13/2018 Paul.  Allow team hierarchy. 
			bool bEnableTeamHierarchy   = Crm.Config.enable_team_hierarchy();
			bool bIsAdmin = Security.IS_ADMIN;
			// 11/27/2009 Paul.  Don't apply admin rules when debugging so that we can test the code. 
#if DEBUG
			bIsAdmin = false;
#endif
			if ( bModuleIsTeamed )
			{
				// 02/10/2008 Kerry.  Remove debug code to force non-admin. 
				if ( bIsAdmin )
					bRequireTeamManagement = false;

				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					if ( bEnableTeamManagement )
					{
						if ( bEnableDynamicTeams )
						{
							// 08/31/2009 Paul.  Dynamic Teams are handled just like regular teams except using a different view. 
							if ( bRequireTeamManagement )
								sbJoin.Append("       inner ");
							else
								sbJoin.Append("  left outer ");
							// 02/13/2018 Paul.  Allow team hierarchy. 
							if ( !bEnableTeamHierarchy )
							{
								// 11/27/2009 Paul.  Use Sql.MetadataName() so that the view name can exceed 30 characters, but still be truncated for Oracle. 
								// 11/27/2009 Paul.  vwTEAM_SET_MEMBERSHIPS_Security has a distinct clause to reduce duplicate rows. 
								// 12/07/2009 Paul.  Must include the module when referencing the TEAM_SET_ID. 
								// 03/08/2011 Paul.  We need to make sure not to exceed 30 characters in the alias name. 
								sbJoin.AppendLine("join " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_Security") + " " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME) + ControlChars.CrLf);
								sbJoin.AppendLine("               on " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_TEAM_SET_ID = " + sMODULE_NAME + ".TEAM_SET_ID" + ControlChars.CrLf);
								// 05/05/2010 Paul.  We need to hard-code the value of the MEMBERSHIP_USER_ID as there is no practical way to use a runtime-value. 
								// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
								if ( bUseSQLParameters )
									sbJoin.AppendLine("              and " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_USER_ID     = @MEMBERSHIP_USER_ID" + ControlChars.CrLf);
								else
									sbJoin.AppendLine("              and " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_USER_ID     = '" + Security.USER_ID.ToString() + "'" + ControlChars.CrLf);
							}
							else
							{
								if ( Sql.IsOracle(con) )
								{
									sbJoin.AppendLine("join table(" + Sql.MetadataName(con, "fnTEAM_SET_HIERARCHY_MEMBERSHIPS") + "(@MEMBERSHIP_USER_ID))  " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME));
									sbJoin.AppendLine("               on " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_TEAM_SET_ID = TEAM_SET_ID");
								}
								else
								{
									string fnPrefix = (Sql.IsSQLServer(con) ? "dbo." : String.Empty);
									sbJoin.AppendLine("join " + fnPrefix + Sql.MetadataName(con, "fnTEAM_SET_HIERARCHY_MEMBERSHIPS") + "(@MEMBERSHIP_USER_ID)  " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME));
									sbJoin.AppendLine("               on " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_TEAM_SET_ID = TEAM_SET_ID");
								}
							}
						}
						else
						{
							if ( bRequireTeamManagement )
								sbJoin.Append("       inner ");
							else
								sbJoin.Append("  left outer ");
							// 02/13/2018 Paul.  Allow team hierarchy. 
							if ( !bEnableTeamHierarchy )
							{
								// 03/08/2011 Paul.  We need to make sure not to exceed 30 characters in the alias name. 
								sbJoin.AppendLine("join vwTEAM_MEMBERSHIPS  " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME));
								sbJoin.AppendLine("               on " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_TEAM_ID = " + sMODULE_NAME + ".TEAM_ID");
								// 05/05/2010 Paul.  We need to hard-code the value of the MEMBERSHIP_USER_ID as there is no practical way to use a runtime-value. 
								// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
								if ( bUseSQLParameters )
									sbJoin.AppendLine("              and " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_USER_ID = @MEMBERSHIP_USER_ID");
								else
									sbJoin.AppendLine("              and " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_USER_ID = '" + Security.USER_ID.ToString() + "'");
							}
							else
							{
								if ( Sql.IsOracle(con) )
								{
									sbJoin.AppendLine("join table(fnTEAM_HIERARCHY_MEMBERSHIPS(@MEMBERSHIP_USER_ID))  " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME));
									sbJoin.AppendLine("               on " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_TEAM_ID = TEAM_ID");
								}
								else
								{
									string fnPrefix = (Sql.IsSQLServer(con) ? "dbo." : String.Empty);
									sbJoin.AppendLine("join " + fnPrefix + "fnTEAM_HIERARCHY_MEMBERSHIPS(@MEMBERSHIP_USER_ID)  " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME));
									sbJoin.AppendLine("               on " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_TEAM_ID = TEAM_ID");
								}
							}
							//Sql.AddParameter(cmd, "@MEMBERSHIP_USER_ID", Security.USER_ID);
						}
					}

					if ( bEnableTeamManagement && !bRequireTeamManagement && !bIsAdmin )
					{
						// 11/27/2009 Paul.  Dynamic Teams are handled just like regular teams except using a different view. 
						// 03/08/2011 Paul.  We need to make sure not to exceed 30 characters in the alias name. 
						if ( bEnableDynamicTeams )
							sbWhere.AppendLine("   and (" + sMODULE_NAME + ".TEAM_SET_ID is null or " + Sql.MetadataName(con, "vwTEAM_SET_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_TEAM_SET_ID is not null)");
						else
							sbWhere.AppendLine("   and (" + sMODULE_NAME + ".TEAM_ID is null or " + Sql.MetadataName(con, "vwTEAM_MEMBERSHIPS_" + sMODULE_NAME) + ".MEMBERSHIP_ID is not null)");
					}
				}
			}
			if ( bModuleIsAssigned )
			{
				int nACLACCESS = Security.GetUserAccess(sMODULE_NAME, sACCESS_TYPE);
				// 11/27/2009 Paul.  Make sure owner rule does not apply to admins. 
				if ( nACLACCESS == ACL_ACCESS.OWNER || (bRequireUserAssignment && !bIsAdmin) )
				{
					sASSIGNED_USER_ID_Field = sMODULE_NAME + "." + sASSIGNED_USER_ID_Field;
					string sFieldPlaceholder = "MEMBERSHIP_USER_ID";  //Sql.NextPlaceholder(cmd, sASSIGNED_USER_ID_Field);
					// 01/22/2007 Paul.  If ASSIGNED_USER_ID is null, then let everybody see it. 
					// This was added to work around a bug whereby the ASSIGNED_USER_ID was not automatically assigned to the creating user. 
					bool bShowUnassigned = Crm.Config.show_unassigned();
					if ( bShowUnassigned )
					{
						if ( bIsCaseSignificantDB )
							sbWhere.AppendLine("   and (" + sASSIGNED_USER_ID_Field + " is null or upper(" + sASSIGNED_USER_ID_Field + ") = upper(@" + sFieldPlaceholder + "))");
						else
							sbWhere.AppendLine("   and (" + sASSIGNED_USER_ID_Field + " is null or "       + sASSIGNED_USER_ID_Field +  " = @"       + sFieldPlaceholder + ")" );
					}
					else
					{
						if ( bIsCaseSignificantDB )
							sbWhere.AppendLine("   and upper(" + sASSIGNED_USER_ID_Field + ") = upper(@" + sFieldPlaceholder + ")");
						else
							sbWhere.AppendLine("   and "       + sASSIGNED_USER_ID_Field +  " = @"       + sFieldPlaceholder      );
					}
					//Sql.AddParameter(cmd, "@" + sFieldPlaceholder, Security.USER_ID);
				}
			}
		}

		// 05/14/2021 Paul.  Convert to static method so that we can use in the React client. 
		public static string BuildReportSQL(HttpApplicationState Application, RdlDocument rdl, bool bPrimaryKeyOnly, bool bUseSQLParameters, bool bDesignChart, bool bUserSpecific, string sBASE_MODULE, string sBASE_RELATED, Hashtable hashAvailableModules, StringBuilder sbErrors)
		{
			bool bIsOracle     = false;
			bool bIsDB2        = false;
			bool bIsMySQL      = false;
			bool bIsPostgreSQL = false;
			string sSplendidProvider = Sql.ToString(Application["SplendidProvider"]);
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					bIsOracle     = Sql.IsOracle    (cmd);
					bIsDB2        = Sql.IsDB2       (cmd);
					bIsMySQL      = Sql.IsMySQL     (cmd);
					bIsPostgreSQL = Sql.IsPostgreSQL(cmd);
				}
			}
			
			StringBuilder sb = new StringBuilder();
			StringBuilder sbACLWhere = new StringBuilder();
			if ( rdl.DocumentElement != null )
			{
				string sMODULE_TABLE = Sql.ToString(Application["Modules." + sBASE_MODULE + ".TableName"]);
				int nMaxLen = Math.Max(sMODULE_TABLE.Length, 15);
				Hashtable hashRequiredModules  = new Hashtable();
				// 02/05/2012 Paul.  Prevent duplicate columns. 
				Hashtable hashSelectColumns    = new Hashtable();
				sb.Append("select ");
				
				bool bSelectAll = true;
				// 05/29/2006 Paul.  If the module is used in a filter, then it is required. 
				XmlDocument xmlDisplayColumns = rdl.GetCustomProperty("DisplayColumns");
				XmlNodeList nlFields = xmlDisplayColumns.DocumentElement.SelectNodes("DisplayColumn/Field");
				foreach ( XmlNode xField in nlFields )
					nMaxLen = Math.Max(nMaxLen, xField.InnerText.Length);
				
				// 01/10/2010 Paul.  The ProspectList Dynamic SQL must only return an ID. 
				if ( bPrimaryKeyOnly && !bUseSQLParameters )
				{
					sb.AppendLine(sMODULE_TABLE + ".ID");
				}
				else
				{
					string sFieldSeparator = "";
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						foreach ( XmlNode xField in nlFields )
						{
							bSelectAll = false;
							string sMODULE_ALIAS = xField.InnerText.Split('.')[0];
							if ( !hashRequiredModules.ContainsKey(sMODULE_ALIAS) )
							{
								hashRequiredModules.Add(sMODULE_ALIAS, null);
								// 02/05/2012 Paul.  Don't add the ID if this is a chart. 
								if ( !bDesignChart )
								{
									// 01/18/2012 Paul.  When a new module is encountered, take this opportunity to add a reference to the ID. 
									// 01/18/2012 Paul.  ReportViewer is not able to convert a Guid to a text string, so do it manually. 
									if ( Sql.IsSQLServer(con) || Sql.IsSybase(con) || Sql.IsSqlAnywhere(con) || Sql.IsEffiProz(con) )
									{
										string sIDField = "cast(" + sMODULE_ALIAS + ".ID as char(36))";
										sb.Append(sFieldSeparator + sIDField);
										if ( nMaxLen - sIDField.Length > 0 )
											sb.Append(Strings.Space(nMaxLen - sIDField.Length));
									}
									else
									{
										sb.Append(sFieldSeparator + sMODULE_ALIAS + ".ID");
										sb.Append(Strings.Space(nMaxLen - (sMODULE_ALIAS + ".ID").Length));
									}
									sb.Append(" as \"" + Sql.MetadataName(con, sMODULE_ALIAS + ".ID") + "\"");
									sb.AppendLine();
									sFieldSeparator = "     , ";
								}
							}
							// 02/05/2012 Paul.  Prevent duplicate columns. 
							if ( !hashSelectColumns.ContainsKey(xField.InnerText) )
							{
								sb.Append(sFieldSeparator + xField.InnerText);
								sb.Append(Strings.Space(nMaxLen - xField.InnerText.Length));
								// 03/08/2011 Paul.  We need to make sure not to exceed 30 characters in the alias name. 
								sb.Append(" as \"" + Sql.MetadataName(con, xField.InnerText) + "\"");
								sb.AppendLine();
								sFieldSeparator = "     , ";
								hashSelectColumns.Add(xField.InnerText, null);
							}
						}
						if ( bSelectAll )
						{
							sb.AppendLine("*");
						}
					}
				}
				
				// 05/29/2006 Paul.  If the module is used in a filter, then it is required. 
				XmlDocument xmlFilters = rdl.GetCustomProperty("Filters");
				XmlNodeList nlFilters = xmlFilters.DocumentElement.SelectNodes("Filter");
				foreach ( XmlNode xFilter in nlFilters )
				{
					string sDATA_FIELD = XmlUtil.SelectSingleNode(xFilter, "DATA_FIELD");
					string sMODULE_ALIAS = sDATA_FIELD.Split('.')[0];
					if ( !hashRequiredModules.ContainsKey(sMODULE_ALIAS) )
						hashRequiredModules.Add(sMODULE_ALIAS, null);
				}

				if ( hashRequiredModules.ContainsKey(sMODULE_TABLE) )
					hashRequiredModules.Remove(sMODULE_TABLE);
				
				sb.AppendLine("  from            vw" + sMODULE_TABLE + " " + Strings.Space(nMaxLen - sMODULE_TABLE.Length) + sMODULE_TABLE);
				// 01/10/2010 Paul.  The Compaigns module will not need user-specific filtering. 
				if ( bUserSpecific || bUseSQLParameters )
				{
					// 04/17/2007 Paul.  Apply ACL rules. 
					if ( sMODULE_TABLE != "USERS" )
						ACLFilter(Application, bUseSQLParameters, sb, sbACLWhere, sMODULE_TABLE, "list", "ASSIGNED_USER_ID", bIsOracle || bIsDB2);
				}
				hashAvailableModules.Add(sMODULE_TABLE, sMODULE_TABLE);
				if ( !Sql.IsEmptyString(sBASE_RELATED) )
				{
					XmlDocument xmlRelatedModules = rdl.GetCustomProperty("RelatedModules");
					string sRELATED           = sBASE_RELATED.Split(' ')[0];
					string sRELATED_ALIAS     = sBASE_RELATED.Split(' ')[1];
					// 10/26/2011 Paul.  Add the relationship so that we can have a unique lookup. 
					string sRELATIONSHIP_NAME = sBASE_RELATED.Split(' ')[2];
					
					if ( hashRequiredModules.ContainsKey(sRELATED_ALIAS) )
						hashRequiredModules.Remove(sRELATED_ALIAS);

					// 10/26/2011 Paul.  Add the relationship so that we can have a unique lookup. 
					XmlNode xRelationship = xmlRelatedModules.DocumentElement.SelectSingleNode("Relationship[RELATIONSHIP_NAME=\'" + sRELATIONSHIP_NAME + "\']");
					if ( xRelationship != null )
					{
						sRELATIONSHIP_NAME                     = XmlUtil.SelectSingleNode(xRelationship, "RELATIONSHIP_NAME"             );
						//string sLHS_MODULE                     = XmlUtil.SelectSingleNode(xRelationship, "LHS_MODULE"                    );
						string sLHS_TABLE                      = XmlUtil.SelectSingleNode(xRelationship, "LHS_TABLE"                     );
						string sLHS_KEY                        = XmlUtil.SelectSingleNode(xRelationship, "LHS_KEY"                       );
						//string sRHS_MODULE                     = XmlUtil.SelectSingleNode(xRelationship, "RHS_MODULE"                    );
						string sRHS_TABLE                      = XmlUtil.SelectSingleNode(xRelationship, "RHS_TABLE"                     );
						string sRHS_KEY                        = XmlUtil.SelectSingleNode(xRelationship, "RHS_KEY"                       );
						string sJOIN_TABLE                     = XmlUtil.SelectSingleNode(xRelationship, "JOIN_TABLE"                    );
						string sJOIN_KEY_LHS                   = XmlUtil.SelectSingleNode(xRelationship, "JOIN_KEY_LHS"                  );
						string sJOIN_KEY_RHS                   = XmlUtil.SelectSingleNode(xRelationship, "JOIN_KEY_RHS"                  );
						// 11/20/2008 Paul.  Quotes, Orders and Invoices have a relationship column. 
						string sRELATIONSHIP_ROLE_COLUMN       = XmlUtil.SelectSingleNode(xRelationship, "RELATIONSHIP_ROLE_COLUMN"      );
						string sRELATIONSHIP_ROLE_COLUMN_VALUE = XmlUtil.SelectSingleNode(xRelationship, "RELATIONSHIP_ROLE_COLUMN_VALUE");
						if ( Sql.IsEmptyString(sJOIN_TABLE) )
						{
							nMaxLen = Math.Max(nMaxLen, sRHS_TABLE.Length + sRHS_KEY.Length + 1);
							sb.AppendLine("       inner join vw" + sRHS_TABLE + " "            + Strings.Space(nMaxLen - sRHS_TABLE.Length                      ) + sRHS_TABLE);
							sb.AppendLine("               on "   + sRHS_TABLE + "." + sRHS_KEY + Strings.Space(nMaxLen - sRHS_TABLE.Length - sRHS_KEY.Length - 1) + " = " + sLHS_TABLE + "." + sLHS_KEY);
							// 05/05/2010 Paul.  The Compaigns module will not need user-specific filtering. 
							if ( bUserSpecific || bUseSQLParameters )
							{
								// 04/17/2007 Paul.  Apply ACL rules. 
								if ( sRHS_TABLE != "USERS" )
									ACLFilter(Application, bUseSQLParameters, sb, sbACLWhere, sRHS_TABLE, "list", "ASSIGNED_USER_ID", bIsOracle || bIsDB2);
							}
						}
						else
						{
							nMaxLen = Math.Max(nMaxLen, sJOIN_TABLE.Length + sJOIN_KEY_LHS.Length + 1);
							nMaxLen = Math.Max(nMaxLen, sRHS_TABLE.Length + sRHS_KEY.Length      + 1);
							sb.AppendLine("       inner join vw" + sJOIN_TABLE + " "                 + Strings.Space(nMaxLen - sJOIN_TABLE.Length                           ) + sJOIN_TABLE);
							sb.AppendLine("               on "   + sJOIN_TABLE + "." + sJOIN_KEY_LHS + Strings.Space(nMaxLen - sJOIN_TABLE.Length - sJOIN_KEY_LHS.Length - 1) + " = " + sLHS_TABLE  + "." + sLHS_KEY     );
							// 10/31/2009 Paul.  The value should be escaped. 
							if ( !Sql.IsEmptyString(sRELATIONSHIP_ROLE_COLUMN) && !Sql.IsEmptyString(sRELATIONSHIP_ROLE_COLUMN_VALUE) )
								sb.AppendLine("              and "   + sJOIN_TABLE + "." + sRELATIONSHIP_ROLE_COLUMN + " = N'" + Sql.EscapeSQL(sRELATIONSHIP_ROLE_COLUMN_VALUE) + "'");
							sb.AppendLine("       inner join vw" + sRHS_TABLE + " "                  + Strings.Space(nMaxLen - sRHS_TABLE.Length                            ) + sRHS_TABLE);
							sb.AppendLine("               on "   + sRHS_TABLE + "." + sRHS_KEY       + Strings.Space(nMaxLen - sRHS_TABLE.Length - sRHS_KEY.Length - 1      ) + " = " + sJOIN_TABLE + "." + sJOIN_KEY_RHS);
							// 05/05/2010 Paul.  The Compaigns module will not need user-specific filtering. 
							if ( bUserSpecific || bUseSQLParameters )
							{
								// 04/17/2007 Paul.  Apply ACL rules. 
								if ( sRHS_TABLE != "USERS" )
									ACLFilter(Application, bUseSQLParameters, sb, sbACLWhere, sRHS_TABLE, "list", "ASSIGNED_USER_ID", bIsOracle || bIsDB2);
							}
						}
						if ( !hashAvailableModules.ContainsKey(sRHS_TABLE) )
							hashAvailableModules.Add(sRHS_TABLE, sRHS_TABLE);
					}
				}
				if ( hashRequiredModules.Count > 0 )
				{
					XmlDocument xmlRelationships = rdl.GetCustomProperty("Relationships");
					foreach ( string sMODULE_ALIAS in hashRequiredModules.Keys )
					{
						XmlNode xRelationship = xmlRelationships.DocumentElement.SelectSingleNode("Relationship[MODULE_ALIAS=\'" + sMODULE_ALIAS + "\']");
						if ( xRelationship != null )
						{
							string sRELATIONSHIP_NAME = XmlUtil.SelectSingleNode(xRelationship, "RELATIONSHIP_NAME");
							//string sLHS_MODULE        = XmlUtil.SelectSingleNode(xRelationship, "LHS_MODULE"       );
							string sLHS_TABLE         = XmlUtil.SelectSingleNode(xRelationship, "LHS_TABLE"        );
							string sLHS_KEY           = XmlUtil.SelectSingleNode(xRelationship, "LHS_KEY"          );
							//string sRHS_MODULE        = XmlUtil.SelectSingleNode(xRelationship, "RHS_MODULE"       );
							string sRHS_TABLE         = XmlUtil.SelectSingleNode(xRelationship, "RHS_TABLE"        );
							string sRHS_KEY           = XmlUtil.SelectSingleNode(xRelationship, "RHS_KEY"          );
							nMaxLen = Math.Max(nMaxLen, sLHS_TABLE.Length );
							nMaxLen = Math.Max(nMaxLen, sMODULE_ALIAS.Length + sLHS_KEY.Length + 1);
							sb.AppendLine("  left outer join vw" + sLHS_TABLE + " "               + Strings.Space(nMaxLen - sLHS_TABLE.Length                        ) + sMODULE_ALIAS);
							sb.AppendLine("               on "   + sMODULE_ALIAS + "." + sLHS_KEY + Strings.Space(nMaxLen - sMODULE_ALIAS.Length - sLHS_KEY.Length - 1) + " = " + sRHS_TABLE + "." + sRHS_KEY);
							// 05/05/2010 Paul.  The Compaigns module will not need user-specific filtering. 
							if ( bUserSpecific || bUseSQLParameters )
							{
								// 04/17/2007 Paul.  Apply ACL rules. 
								if ( sLHS_TABLE != "USERS" )
									ACLFilter(Application, bUseSQLParameters, sb, sbACLWhere, sMODULE_ALIAS, "list", "ASSIGNED_USER_ID", bIsOracle || bIsDB2);
							}
							// 07/13/2006 Paul.  The key needs to be the alias, and the value is the main table. 
							// This is because the same table may be referenced more than once, 
							// such as the Users table to display the last modified user and the assigned to user. 
							if ( !hashAvailableModules.ContainsKey(sMODULE_ALIAS) )
								hashAvailableModules.Add(sMODULE_ALIAS, sLHS_TABLE);
						}
					}
				}
				sb.AppendLine(" where 1 = 1");
				sb.Append(sbACLWhere.ToString());
				try
				{
					rdl.SetSingleNode("DataSets/DataSet/Query/QueryParameters", String.Empty);
					XmlNode xQueryParameters = rdl.SelectNode("DataSets/DataSet/Query/QueryParameters");
					xQueryParameters.RemoveAll();
					if ( xmlFilters.DocumentElement != null )
					{
						int nParameterIndex = 0;
						// 10/25/2014 Paul.  Filters that use NOT should protect against NULL values. 
						// 10/25/2014 Paul.  Coalesce works across all database platforms, so use instead of isnull. 
						string sISNULL = "coalesce";
						//if ( bIsOracle )
						//	sISNULL = "nvl";
						//else if ( bIsMySQL || bIsDB2 )
						//	sISNULL = "ifnull";
						//else if ( bIsPostgreSQL )
						//	sISNULL = "coalesce";
						foreach ( XmlNode xFilter in xmlFilters.DocumentElement )
						{
							string sMODULE_NAME    = XmlUtil.SelectSingleNode(xFilter, "MODULE_NAME");
							string sDATA_FIELD     = XmlUtil.SelectSingleNode(xFilter, "DATA_FIELD" );
							string sDATA_TYPE      = XmlUtil.SelectSingleNode(xFilter, "DATA_TYPE"  );
							string sOPERATOR       = XmlUtil.SelectSingleNode(xFilter, "OPERATOR"   );
							// 07/04/2006 Paul.  We need to use the parameter index in the parameter name 
							// because a parameter can be used more than once and we need a unique name. 
							string sPARAMETER_NAME = RdlDocument.RdlParameterName(sDATA_FIELD, nParameterIndex, false);
							string sSECONDARY_NAME = RdlDocument.RdlParameterName(sDATA_FIELD, nParameterIndex, true );
							string sSEARCH_TEXT1   = String.Empty;
							string sSEARCH_TEXT2   = String.Empty;
							// 03/14/2011 Paul.  Oracle does not like parameter names longer than 30 characters. 
							if ( bIsOracle && (sPARAMETER_NAME.Length > 30 || sSECONDARY_NAME.Length > 30) )
							{
								sPARAMETER_NAME = "@PARAMETER__" + nParameterIndex.ToString("00") + "A";
								sSECONDARY_NAME = "@PARAMETER__" + nParameterIndex.ToString("00") + "B";
							}
							
							XmlNodeList nlValues = xFilter.SelectNodes("SEARCH_TEXT_VALUES");
							string[] arrSEARCH_TEXT = new string[nlValues.Count];
							int i = 0;
							foreach ( XmlNode xValue in nlValues )
							{
								arrSEARCH_TEXT[i++] = xValue.InnerText;
							}
							if ( arrSEARCH_TEXT.Length > 0 )
								sSEARCH_TEXT1 = arrSEARCH_TEXT[0];
							if ( arrSEARCH_TEXT.Length > 1 )
								sSEARCH_TEXT2 = arrSEARCH_TEXT[1];

							string sSQL = string.Empty;
							// 07/09/2007 Paul.  ansistring is treated the same as string. 
							string sCOMMON_DATA_TYPE = sDATA_TYPE;
							if ( sCOMMON_DATA_TYPE == "ansistring" )
								sCOMMON_DATA_TYPE = "string";
							switch ( sCOMMON_DATA_TYPE )
							{
								case "string":
								{
									// 07/16/2006 Paul.  Oracle and DB2 are case-significant.  Keep SQL Server code fast by not converting to uppercase. 
									if ( bIsOracle || bIsDB2 )
									{
										sSEARCH_TEXT1 = sSEARCH_TEXT1.ToUpper();
										sSEARCH_TEXT2 = sSEARCH_TEXT2.ToUpper();
										sDATA_FIELD   = "upper(" + sDATA_FIELD + ")";
									}
									// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
									// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
									if ( sSEARCH_TEXT1.StartsWith("=") )
									{
										// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
										var sCAT_SEP = (bIsOracle ? " || " : " + ");
										sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.Substring(1));
										switch ( sOPERATOR )
										{
											case "equals"         :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
											case "less"           :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sSEARCH_TEXT1);  break;
											case "less_equal"     :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sSEARCH_TEXT1);  break;
											case "greater"        :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sSEARCH_TEXT1);  break;
											case "greater_equal"  :  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sSEARCH_TEXT1);  break;
											case "contains"       :  sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
											case "starts_with"    :  sb.AppendLine("   and " + sDATA_FIELD + " like " +                     sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
											case "ends_with"      :  sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1);  break;
											case "like"           :  sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
											case "empty"          :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty"      :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											// 10/25/2014 Paul.  Filters that use NOT should protect against NULL values. 
											case "not_equals_str" :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " <> "   + sSEARCH_TEXT1);  break;
											case "not_contains"   :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
											case "not_starts_with":  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " +                     sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
											case "not_ends_with"  :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1);  break;
											case "not_like"       :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
										}
									}
									else if ( bUseSQLParameters )
									{
										switch ( sOPERATOR )
										{
											case "equals"        :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											// 07/23/2013 Paul.  Add greater and less than conditions. 
											case "less"          :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "less_equal"    :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "greater"       :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "greater_equal" :  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "contains"      :  sb.AppendLine("   and " + sDATA_FIELD + " like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
												sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
												// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
												break;
											case "starts_with"   :  sb.AppendLine("   and " + sDATA_FIELD + " like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
												sSQL =       Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
												// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
												break;
											case "ends_with"     :  sb.AppendLine("   and " + sDATA_FIELD + " like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
												sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1)      ;
												// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
												break;
											// 02/14/2013 Paul.  A customer wants to use like in string filters. 
											case "like"          :  sb.AppendLine("   and " + sDATA_FIELD + " like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
												sSQL = sSEARCH_TEXT1;
												// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
												break;
											case "empty"         :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											// 08/25/2011 Paul.  A customer wants more use of NOT in string filters. 
												// 10/25/2014 Paul.  Filters that use NOT should protect against NULL values. 
											case "not_equals_str"    :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " <> "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "not_contains"      :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
												sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
												// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
												break;
											case "not_starts_with"   :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
												sSQL =       Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
												// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
												break;
											case "not_ends_with"     :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
												sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1)      ;
												// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
												break;
											case "not_like"          :  sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + sPARAMETER_NAME + (bIsMySQL || bIsPostgreSQL ? " escape '\\\\'" : " escape '\\'"));
												sSQL = sSEARCH_TEXT1;
												// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
												break;
										}
									}
									else
									{
										switch ( sOPERATOR )
										{
											case "equals"        :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + "N'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
											// 07/23/2013 Paul.  Add greater and less than conditions. 
											case "less"          :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + "N'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
											case "less_equal"    :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + "N'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
											case "greater"       :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + "N'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
											case "greater_equal" :  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + "N'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
											case "contains"      :
												sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
												// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
												break;
											case "starts_with"   :
												sSQL =       Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
												// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
												break;
											case "ends_with"     :
												sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1)      ;
												// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
												break;
											// 02/14/2013 Paul.  A customer wants to use like in string filters. 
											case "like"          :
												sSQL = sSEARCH_TEXT1;
												// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
												break;
											case "empty"         :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											case "not_equals_str":
												sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " <> "   + "N'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");
												break;
											// 08/25/2011 Paul.  A customer wants more use of NOT in string filters. 
											case "not_contains"      :
												sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
												// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
												break;
											case "not_starts_with"   :
												sSQL =       Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
												// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
												break;
											case "not_ends_with"     :
												sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1)      ;
												// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
												break;
											case "not_like"      :
												sSQL = sSEARCH_TEXT1;
												// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												sb.AppendLine("   and " + sISNULL + "(" + sDATA_FIELD + ", N'')" + " not like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
												break;
										}
									}
									break;
								}
								case "datetime":
								{
									string fnPrefix = "dbo.";
									if ( bIsOracle || bIsDB2 || bIsMySQL || bIsPostgreSQL )
									{
										fnPrefix = "";
									}
									// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
									// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
									if ( sSEARCH_TEXT1.StartsWith("=") )
									{
										// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
										var sCAT_SEP = (bIsOracle ? " || " : " + ");
										sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.Substring(1));
										if ( sSEARCH_TEXT2.StartsWith("=") )
											sSEARCH_TEXT2 = RdlUtil.ReportColumnName(sSEARCH_TEXT2.Substring(1));
										switch ( sOPERATOR )
										{
											case "on"               :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = "  + sSEARCH_TEXT1);  break;
											case "before"           :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") < "  + sSEARCH_TEXT1);  break;
											case "after"            :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") > "  + sSEARCH_TEXT1);  break;
											case "not_equals_str"   :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") <> " + sSEARCH_TEXT1);  break;
											case "between_dates"    :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
											case "tp_days_after"    :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('day', "    +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
											case "tp_weeks_after"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('week', "   +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
											case "tp_months_after"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('month', "  +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
											case "tp_years_after"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('year', "   +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
											case "tp_days_before"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('day', "    + "-" + sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
											case "tp_weeks_before"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('week', "   + "-" + sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
											case "tp_months_before" :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('month', "  + "-" + sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
											case "tp_years_before"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('year', "   + "-" + sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
											case "tp_minutes_after" :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('minute', " +       sSEARCH_TEXT1        + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('minute', " + "1+" + sSEARCH_TEXT1 + ", " + sDATA_FIELD + ")");  break;
											case "tp_hours_after"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('hour', "   +       sSEARCH_TEXT1        + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('hour', "   + "1+" + sSEARCH_TEXT1 + ", " + sDATA_FIELD + ")");  break;
											case "tp_minutes_before":  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('minute', " + "-" + sSEARCH_TEXT1 + "-1" + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('minute', " + "-"  + sSEARCH_TEXT1 + ", " + sDATA_FIELD + ")");  break;
											case "tp_hours_before"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('hour', "   + "-" + sSEARCH_TEXT1 + "-1" + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('hour', "   + "-"  + sSEARCH_TEXT1 + ", " + sDATA_FIELD + ")");  break;
											case "tp_days_old"      :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('day', "    +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
											case "tp_weeks_old"     :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('week', "   +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
											case "tp_months_old"    :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('month', "  +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
											case "tp_years_old"     :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('year', "   +       sSEARCH_TEXT1        + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
										}
									}
									else if ( bUseSQLParameters )
									{
										if ( arrSEARCH_TEXT.Length > 0 )
										{
											//CalendarControl.SqlDateTimeFormat, ciEnglish.DateTimeFormat
											DateTime dtSEARCH_TEXT1 = DateTime.MinValue;
											DateTime dtSEARCH_TEXT2 = DateTime.MinValue;
											int nINTERVAL = 0;
											// 11/16/2008 Paul.  Days old. 
											if ( !(sOPERATOR.EndsWith("_after") || sOPERATOR.EndsWith("_before") || sOPERATOR.EndsWith("_old")) )
											{
												dtSEARCH_TEXT1 = DateTime.ParseExact(sSEARCH_TEXT1, "yyyy/MM/dd", Thread.CurrentThread.CurrentCulture.DateTimeFormat);
												dtSEARCH_TEXT2 = DateTime.MinValue;
												if ( arrSEARCH_TEXT.Length > 1 )
													dtSEARCH_TEXT2 = DateTime.ParseExact(sSEARCH_TEXT2, "yyyy/MM/dd", Thread.CurrentThread.CurrentCulture.DateTimeFormat);
											}
											else
											{
												nINTERVAL = Sql.ToInteger(sSEARCH_TEXT1);
											}
											switch ( sOPERATOR )
											{
												case "on"               :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = "  + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSEARCH_TEXT1);  break;
												case "before"           :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") < "  + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSEARCH_TEXT1);  break;
												case "after"            :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") > "  + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSEARCH_TEXT1);  break;
												case "not_equals_str"   :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") <> " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSEARCH_TEXT1);  break;
												case "between_dates"    :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + sPARAMETER_NAME + " and " + sSECONDARY_NAME);
													rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, dtSEARCH_TEXT1.ToShortDateString());
													rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, dtSEARCH_TEXT2.ToShortDateString());
													break;
												// 11/16/2008 Paul.  Days old. 
												case "tp_days_after"    :  sb.AppendLine("   and " + sPARAMETER_NAME + " > "       + fnPrefix + "fnDateAdd('day', "    +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
												case "tp_weeks_after"   :  sb.AppendLine("   and " + sPARAMETER_NAME + " > "       + fnPrefix + "fnDateAdd('week', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
												case "tp_months_after"  :  sb.AppendLine("   and " + sPARAMETER_NAME + " > "       + fnPrefix + "fnDateAdd('month', "  +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
												case "tp_years_after"   :  sb.AppendLine("   and " + sPARAMETER_NAME + " > "       + fnPrefix + "fnDateAdd('year', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
												case "tp_days_before"   :  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('day', "    + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
												case "tp_weeks_before"  :  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('week', "   + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
												case "tp_months_before" :  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('month', "  + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
												case "tp_years_before"  :  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('year', "   + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
												case "tp_minutes_after" :  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('minute', " +   nINTERVAL   .ToString() + ", " + sDATA_FIELD + "                            ) and " + fnPrefix + "fnDateAdd('minute', " + (1+nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "GETDATE()");  break;
												case "tp_hours_after"   :  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('hour', "   +   nINTERVAL   .ToString() + ", " + sDATA_FIELD + "                            ) and " + fnPrefix + "fnDateAdd('hour', "   + (1+nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "GETDATE()");  break;
												case "tp_minutes_before":  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('minute', " + (-nINTERVAL-1).ToString() + ", " + sDATA_FIELD + "                            ) and " + fnPrefix + "fnDateAdd('minute', " +  (-nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "GETDATE()");  break;
												case "tp_hours_before"  :  sb.AppendLine("   and " + sPARAMETER_NAME + " between " + fnPrefix + "fnDateAdd('hour', "   + (-nINTERVAL-1).ToString() + ", " + sDATA_FIELD + "                            ) and " + fnPrefix + "fnDateAdd('hour', "   +  (-nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "GETDATE()");  break;
												// 12/04/2008 Paul.  We need to be able to do an an equals. 
												case "tp_days_old"      :  sb.AppendLine("   and " + sPARAMETER_NAME + " = "       + fnPrefix + "fnDateAdd('day', "    +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
												case "tp_weeks_old"     :  sb.AppendLine("   and " + sPARAMETER_NAME + " = "       + fnPrefix + "fnDateAdd('week', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
												case "tp_months_old"    :  sb.AppendLine("   and " + sPARAMETER_NAME + " = "       + fnPrefix + "fnDateAdd('month', "  +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
												case "tp_years_old"     :  sb.AppendLine("   and " + sPARAMETER_NAME + " = "       + fnPrefix + "fnDateAdd('year', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
											}
										}
										else
										{
											switch ( sOPERATOR )
											{
												case "empty"          :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
												case "not_empty"      :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
												case "is_before"      :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") < " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
												case "is_after"       :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") > " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
												case "tp_yesterday"   :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "DATEADD(DAY, -1, TODAY())");  break;
												case "tp_today"       :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");  break;
												case "tp_tomorrow"    :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "DATEADD(DAY, 1, TODAY())");  break;
												case "tp_last_7_days" :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + sPARAMETER_NAME + " and " + sSECONDARY_NAME);
													rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "DATEADD(DAY, -7, TODAY())");
													rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, "TODAY()");
													break;
												case "tp_next_7_days" :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + sPARAMETER_NAME + " and " + sSECONDARY_NAME);
													rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");
													rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, "DATEADD(DAY, 7, TODAY())");
													break;
												// 07/05/2006 Paul.  Month math must also include the year. 
												case "tp_last_month"  :  sb.AppendLine("   and month(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);
													                     sb.AppendLine("   and year("  + sDATA_FIELD + ") = " + sSECONDARY_NAME);
													rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "MONTH(DATEADD(MONTH, -1, TODAY()))");
													rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, "YEAR(DATEADD(MONTH, -1, TODAY()))");
													break;
												case "tp_this_month"  :  sb.AppendLine("   and month(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);
													                     sb.AppendLine("   and year("  + sDATA_FIELD + ") = " + sSECONDARY_NAME);
													rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "MONTH(TODAY())");
													rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, "YEAR(TODAY())");
													break;
												case "tp_next_month"  :  sb.AppendLine("   and month(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);
													                     sb.AppendLine("   and year("  + sDATA_FIELD + ") = " + sSECONDARY_NAME);
													rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "MONTH(DATEADD(MONTH, 1, TODAY()))");
													rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, "YEAR(DATEADD(MONTH, 1, TODAY()))");
													break;
												case "tp_last_30_days":  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + sPARAMETER_NAME + " and " + sSECONDARY_NAME);
													rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "DATEADD(DAY, -30, TODAY())");
													rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, "TODAY()");
													break;
												case "tp_next_30_days":  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + sPARAMETER_NAME + " and " + sSECONDARY_NAME);
													rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "TODAY()");
													rdl.AddQueryParameter(xQueryParameters, sSECONDARY_NAME, sDATA_TYPE, "DATEADD(DAY, 30, TODAY())");
													break;
												case "tp_last_year"   :  sb.AppendLine("   and year(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "YEAR(DATEADD(YEAR, -1, TODAY()))");  break;
												case "tp_this_year"   :  sb.AppendLine("   and year(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "YEAR(TODAY())");  break;
												case "tp_next_year"   :  sb.AppendLine("   and year(" + sDATA_FIELD + ") = " + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, "YEAR(DATEADD(YEAR, 1, TODAY()))");  break;
											}
										}
									}
									else
									{
										if ( arrSEARCH_TEXT.Length > 0 )
										{
											//CalendarControl.SqlDateTimeFormat, ciEnglish.DateTimeFormat
											DateTime dtSEARCH_TEXT1 = DateTime.MinValue;
											DateTime dtSEARCH_TEXT2 = DateTime.MinValue;
											int nINTERVAL = 0;
											// 11/16/2008 Paul.  Days old. 
											if ( !(sOPERATOR.EndsWith("_after") || sOPERATOR.EndsWith("_before") || sOPERATOR.EndsWith("_old")) )
											{
												dtSEARCH_TEXT1 = DateTime.ParseExact(sSEARCH_TEXT1, "yyyy/MM/dd", Thread.CurrentThread.CurrentCulture.DateTimeFormat);
												dtSEARCH_TEXT2 = DateTime.MinValue;
												if ( arrSEARCH_TEXT.Length > 1 )
												{
													dtSEARCH_TEXT2 = DateTime.ParseExact(sSEARCH_TEXT2, "yyyy/MM/dd", Thread.CurrentThread.CurrentCulture.DateTimeFormat);
													if ( bIsOracle )
														sSEARCH_TEXT2 = "to_date('" + dtSEARCH_TEXT2.ToString("yyyy-MM-dd") + "','YYYY-MM-DD')";
													else
														sSEARCH_TEXT2 = "'" + dtSEARCH_TEXT2.ToString("yyyy/MM/dd") + "'";
												}
												if ( bIsOracle )
													sSEARCH_TEXT1 = "to_date('" + dtSEARCH_TEXT1.ToString("yyyy-MM-dd") + "','YYYY-MM-DD')";
												else
													sSEARCH_TEXT1 = "'" + dtSEARCH_TEXT1.ToString("yyyy/MM/dd") + "'";
											}
											else
											{
												nINTERVAL = Sql.ToInteger(sSEARCH_TEXT1);
											}
											switch ( sOPERATOR )
											{
												case "on"               :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = "  + sSEARCH_TEXT1);  break;
												case "before"           :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") < "  + sSEARCH_TEXT1);  break;
												case "after"            :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") > "  + sSEARCH_TEXT1);  break;
												case "not_equals_str"   :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") <> " + sSEARCH_TEXT1);  break;
												case "between_dates"    :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
												// 11/16/2008 Paul.  Days old. 
												case "tp_days_after"    :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('day', "    +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
												case "tp_weeks_after"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('week', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
												case "tp_months_after"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('month', "  +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
												case "tp_years_after"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " > "       + fnPrefix + "fnDateAdd('year', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
												case "tp_days_before"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('day', "    + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
												case "tp_weeks_before"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('week', "   + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
												case "tp_months_before" :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('month', "  + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
												case "tp_years_before"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " between " + fnPrefix + "fnDateAdd('year', "   + (-nINTERVAL)  .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")) and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ")");  break;
												case "tp_minutes_after" :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('minute', " +   nINTERVAL   .ToString() + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('minute', " + (1+nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  break;
												case "tp_hours_after"   :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('hour', "   +   nINTERVAL   .ToString() + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('hour', "   + (1+nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  break;
												case "tp_minutes_before":  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('minute', " + (-nINTERVAL-1).ToString() + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('minute', " +  (-nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  break;
												case "tp_hours_before"  :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "GETDATE()") + " between " + fnPrefix + "fnDateAdd('hour', "   + (-nINTERVAL-1).ToString() + ", " + sDATA_FIELD                             + ") and " + fnPrefix + "fnDateAdd('hour', "   +  (-nINTERVAL).ToString() + ", " + sDATA_FIELD + ")");  break;
												// 12/04/2008 Paul.  We need to be able to do an an equals. 
												case "tp_days_old"      :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('day', "    +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
												case "tp_weeks_old"     :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('week', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
												case "tp_months_old"    :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('month', "  +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
												case "tp_years_old"     :  sb.AppendLine("   and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"  ) + " = "       + fnPrefix + "fnDateAdd('year', "   +   nINTERVAL   .ToString() + ", " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + "))");  break;
											}
										}
										else
										{
											switch ( sOPERATOR )
											{
												case "empty"            :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
												case "not_empty"        :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
												case "is_before"        :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") < " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"                  ));  break;
												case "is_after"         :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") > " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"                  ));  break;
												case "tp_yesterday"     :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "DATEADD(DAY, -1, TODAY())"));  break;
												case "tp_today"         :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"                  ));  break;
												case "tp_tomorrow"      :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "DATEADD(DAY, 1, TODAY())" ));  break;
												case "tp_last_7_days"   :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + RdlDocument.DbSpecificDate(sSplendidProvider, "DATEADD(DAY, -7, TODAY())") + " and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"));
													break;
												case "tp_next_7_days"   :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()" ) + " and " + RdlDocument.DbSpecificDate(sSplendidProvider, "DATEADD(DAY, 7, TODAY())"));
													break;
												// 07/05/2006 Paul.  Month math must also include the year. 
												case "tp_last_month"    :  sb.AppendLine("   and month(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "MONTH(DATEADD(MONTH, -1, TODAY()))"));
													                       sb.AppendLine("   and year("  + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "YEAR(DATEADD(MONTH, -1, TODAY()))" ));
													break;
												case "tp_this_month"    :  sb.AppendLine("   and month(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "MONTH(TODAY())"));
													                       sb.AppendLine("   and year("  + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "YEAR(TODAY())" ));
													break;
												case "tp_next_month"    :  sb.AppendLine("   and month(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "MONTH(DATEADD(MONTH, 1, TODAY()))"));
													                       sb.AppendLine("   and year("  + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "YEAR(DATEADD(MONTH, 1, TODAY()))" ));
													break;
												case "tp_last_30_days"  :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + RdlDocument.DbSpecificDate(sSplendidProvider, "DATEADD(DAY, -30, TODAY())") + " and " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()"));
													break;
												case "tp_next_30_days"  :  sb.AppendLine("   and " + fnPrefix + "fnDateOnly(" + sDATA_FIELD + ") between " + RdlDocument.DbSpecificDate(sSplendidProvider, "TODAY()") + " and " + RdlDocument.DbSpecificDate(sSplendidProvider, "DATEADD(DAY, 30, TODAY())"));
													break;
												case "tp_last_year"     :  sb.AppendLine("   and year(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "YEAR(DATEADD(YEAR, -1, TODAY()))"));  break;
												case "tp_this_year"     :  sb.AppendLine("   and year(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "YEAR(TODAY())"                   ));  break;
												case "tp_next_year"     :  sb.AppendLine("   and year(" + sDATA_FIELD + ") = " + RdlDocument.DbSpecificDate(sSplendidProvider, "YEAR(DATEADD(YEAR, 1, TODAY()))" ));  break;
											}
										}
									}
									break;
								}
								case "int32":
								{
									// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
									// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
									if ( sSEARCH_TEXT1.StartsWith("=") )
									{
										// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
										var sCAT_SEP = (bIsOracle ? " || " : " + ");
										sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.Substring(1));
										if ( sSEARCH_TEXT2.StartsWith("=") )
											sSEARCH_TEXT2 = RdlUtil.ReportColumnName(sSEARCH_TEXT2.Substring(1));
										switch ( sOPERATOR )
										{
											case "equals"       :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
											case "less"         :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sSEARCH_TEXT1);  break;
											case "greater"      :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sSEARCH_TEXT1);  break;
											case "not_equals"   :  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sSEARCH_TEXT1);  break;
											case "between"      :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
											case "empty"        :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty"    :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "    + sSEARCH_TEXT1);  break;
											case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "    + sSEARCH_TEXT1);  break;
										}
									}
									else if ( bUseSQLParameters )
									{
										switch ( sOPERATOR )
										{
											case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "less"      :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "greater"   :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "not_equals":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "between"   :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sPARAMETER_NAME + "1 and " + sPARAMETER_NAME + "2");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSEARCH_TEXT1, sSEARCH_TEXT2);  break;
											case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											// 07/23/2013 Paul.  Add greater and less than conditions. 
											case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										}
									}
									else
									{
										sSEARCH_TEXT1 = Sql.ToInteger(sSEARCH_TEXT1).ToString();
										sSEARCH_TEXT2 = Sql.ToInteger(sSEARCH_TEXT2).ToString();
										switch ( sOPERATOR )
										{
											case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
											case "less"      :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sSEARCH_TEXT1);  break;
											case "greater"   :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sSEARCH_TEXT1);  break;
											case "not_equals":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sSEARCH_TEXT1);  break;
											case "between"   :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
											case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											// 07/23/2013 Paul.  Add greater and less than conditions. 
											case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sSEARCH_TEXT1);  break;
											case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sSEARCH_TEXT1);  break;
										}
									}
									break;
								}
								case "decimal":
								{
									// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
									// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
									if ( sSEARCH_TEXT1.StartsWith("=") )
									{
										// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
										var sCAT_SEP = (bIsOracle ? " || " : " + ");
										sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.Substring(1));
										if ( sSEARCH_TEXT2.StartsWith("=") )
											sSEARCH_TEXT2 = RdlUtil.ReportColumnName(sSEARCH_TEXT2.Substring(1));
										switch ( sOPERATOR )
										{
											case "equals"       :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
											case "less"         :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sSEARCH_TEXT1);  break;
											case "greater"      :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sSEARCH_TEXT1);  break;
											case "not_equals"   :  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sSEARCH_TEXT1);  break;
											case "between"      :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
											case "empty"        :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty"    :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "    + sSEARCH_TEXT1);  break;
											case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "    + sSEARCH_TEXT1);  break;
										}
									}
									else if ( bUseSQLParameters )
									{
										switch ( sOPERATOR )
										{
											case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "less"      :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "greater"   :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "not_equals":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "between"   :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sPARAMETER_NAME + "1 and " + sPARAMETER_NAME + "2");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSEARCH_TEXT1, sSEARCH_TEXT2);  break;
											case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											// 07/23/2013 Paul.  Add greater and less than conditions. 
											case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										}
									}
									else
									{
										sSEARCH_TEXT1 = Sql.ToDecimal(sSEARCH_TEXT1).ToString();
										sSEARCH_TEXT2 = Sql.ToDecimal(sSEARCH_TEXT2).ToString();
										switch ( sOPERATOR )
										{
											case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
											case "less"      :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sSEARCH_TEXT1);  break;
											case "greater"   :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sSEARCH_TEXT1);  break;
											case "not_equals":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sSEARCH_TEXT1);  break;
											case "between"   :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
											case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											// 07/23/2013 Paul.  Add greater and less than conditions. 
											case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sSEARCH_TEXT1);  break;
											case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sSEARCH_TEXT1);  break;
										}
									}
									break;
								}
								case "float":
								{
									// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
									// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
									if ( sSEARCH_TEXT1.StartsWith("=") )
									{
										// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
										var sCAT_SEP = (bIsOracle ? " || " : " + ");
										sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.Substring(1));
										if ( sSEARCH_TEXT2.StartsWith("=") )
											sSEARCH_TEXT2 = RdlUtil.ReportColumnName(sSEARCH_TEXT2.Substring(1));
										switch ( sOPERATOR )
										{
											case "equals"       :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
											case "less"         :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sSEARCH_TEXT1);  break;
											case "greater"      :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sSEARCH_TEXT1);  break;
											case "not_equals"   :  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sSEARCH_TEXT1);  break;
											case "between"      :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
											case "empty"        :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty"    :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "    + sSEARCH_TEXT1);  break;
											case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "    + sSEARCH_TEXT1);  break;
										}
									}
									else if ( bUseSQLParameters )
									{
										switch ( sOPERATOR )
										{
											case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "less"      :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "greater"   :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "not_equals":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "between"   :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sPARAMETER_NAME + "1 and " + sPARAMETER_NAME + "2");  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSEARCH_TEXT1, sSEARCH_TEXT2);  break;
											case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											// 07/23/2013 Paul.  Add greater and less than conditions. 
											case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
										}
									}
									else
									{
										sSEARCH_TEXT1 = Sql.ToFloat(sSEARCH_TEXT1).ToString();
										sSEARCH_TEXT2 = Sql.ToFloat(sSEARCH_TEXT2).ToString();
										switch ( sOPERATOR )
										{
											case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
											case "less"      :  sb.AppendLine("   and " + sDATA_FIELD + " < "    + sSEARCH_TEXT1);  break;
											case "greater"   :  sb.AppendLine("   and " + sDATA_FIELD + " > "    + sSEARCH_TEXT1);  break;
											case "not_equals":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sSEARCH_TEXT1);  break;
											case "between"   :  sb.AppendLine("   and " + sDATA_FIELD + " between "   + sSEARCH_TEXT1 + " and " + sSEARCH_TEXT2);  break;
											case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											// 07/23/2013 Paul.  Add greater and less than conditions. 
											case "less_equal"   :  sb.AppendLine("   and " + sDATA_FIELD + " <= "   + sSEARCH_TEXT1);  break;
											case "greater_equal":  sb.AppendLine("   and " + sDATA_FIELD + " >= "   + sSEARCH_TEXT1);  break;
										}
									}
									break;
								}
								case "bool":
								{
									// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
									// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
									if ( sSEARCH_TEXT1.StartsWith("=") )
									{
										// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
										var sCAT_SEP = (bIsOracle ? " || " : " + ");
										sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.Substring(1));
										switch ( sOPERATOR )
										{
											case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
											case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										}
									}
									else if ( bUseSQLParameters )
									{
										switch ( sOPERATOR )
										{
											case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										}
									}
									else
									{
										sSEARCH_TEXT1 = Sql.ToBoolean(sSEARCH_TEXT1) ? "1" : "0";
										switch ( sOPERATOR )
										{
											case "equals"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
											case "empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty" :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										}
									}
									break;
								}
								case "guid":
								{
									// 07/16/2006 Paul.  Oracle and DB2 are case-significant.  Keep SQL Server code fast by not converting to uppercase. 
									if ( bIsOracle || bIsDB2 )
									{
										sSEARCH_TEXT1 = sSEARCH_TEXT1.ToUpper();
										sSEARCH_TEXT2 = sSEARCH_TEXT2.ToUpper();
										sDATA_FIELD   = "upper(" + sDATA_FIELD + ")";
									}
									// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
									// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
									if ( sSEARCH_TEXT1.StartsWith("=") )
									{
										// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
										var sCAT_SEP = (bIsOracle ? " || " : " + ");
										sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.Substring(1));
										if ( sSEARCH_TEXT2.StartsWith("=") )
											sSEARCH_TEXT2 = RdlUtil.ReportColumnName(sSEARCH_TEXT2.Substring(1));
										switch ( sOPERATOR )
										{
											case "is"             :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
											case "equals"         :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sSEARCH_TEXT1);  break;
											case "contains"       :  sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
											case "starts_with"    :  sb.AppendLine("   and " + sDATA_FIELD + " like " +                     sSEARCH_TEXT1 + sCAT_SEP + "N'%'");  break;
											case "ends_with"      :  sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'%'" + sCAT_SEP + sSEARCH_TEXT1);  break;
											case "not_equals_str" :  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sSEARCH_TEXT1);  break;
											case "empty"          :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty"      :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											case "one_of":
											{
												// 12/03/2008 Paul.  arrSEARCH_TEXT should already be populated.  Do not pull from lstFILTER_SEARCH_LISTBOX. 
												if ( arrSEARCH_TEXT != null && arrSEARCH_TEXT.Length > 0 )
												{
													sb.Append("   and " + sDATA_FIELD + " in (");
													for ( int j = 0; j < arrSEARCH_TEXT.Length; j++ )
													{
														if ( j > 0 )
															sb.Append(", ");
														sb.Append("N'" + Sql.EscapeSQL(arrSEARCH_TEXT[j]) + "'");
													}
													sb.AppendLine(")");
												}
												break;
											}
										}
									}
									else if ( bUseSQLParameters )
									{
										switch ( sOPERATOR )
										{
											case "is"            :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "equals"        :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "contains"      :  sb.AppendLine("   and " + sDATA_FIELD + " like " + sPARAMETER_NAME + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
												sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
												if ( bIsMySQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
												break;
											case "starts_with"   :  sb.AppendLine("   and " + sDATA_FIELD + " like " + sPARAMETER_NAME + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
												sSQL =       Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
												if ( bIsMySQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
												break;
											case "ends_with"     :  sb.AppendLine("   and " + sDATA_FIELD + " like " + sPARAMETER_NAME + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
												sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1)      ;
												if ( bIsMySQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE, sSQL);
												break;
											case "not_equals_str":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "empty"         :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											// 05/05/2010 Paul.  one_of was available in the UI, but was not generating the SQL. 
											case "one_of":
											{
												// 12/03/2008 Paul.  arrSEARCH_TEXT should already be populated.  Do not pull from lstFILTER_SEARCH_LISTBOX. 
												if ( arrSEARCH_TEXT != null && arrSEARCH_TEXT.Length > 0 )
												{
													sb.Append("   and " + sDATA_FIELD + " in (");
													for ( int j = 0; j < arrSEARCH_TEXT.Length; j++ )
													{
														if ( j > 0 )
															sb.Append(", ");
														sb.Append("N'" + Sql.EscapeSQL(arrSEARCH_TEXT[j]) + "'");
													}
													sb.AppendLine(")");
												}
												break;
											}
										}
									}
									else
									{
										switch ( sOPERATOR )
										{
											case "is"            :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + "'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
											case "equals"        :  sb.AppendLine("   and " + sDATA_FIELD + " = "    + "'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
											case "contains"      :
												sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
												// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
												break;
											case "starts_with"   :
												sSQL =       Sql.EscapeSQLLike(sSEARCH_TEXT1) + '%';
												// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
												break;
											case "ends_with"     :
												sSQL = '%' + Sql.EscapeSQLLike(sSEARCH_TEXT1)      ;
												// 01/10/2010 Paul.  PostgreSQL requires two slashes. 
												if ( bIsMySQL || bIsPostgreSQL )
													sSQL = sSQL.Replace("\\", "\\\\");  // 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
												sb.AppendLine("   and " + sDATA_FIELD + " like " + "N'" + Sql.EscapeSQL(sSQL) + "'" + (bIsMySQL ? " escape '\\\\'" : " escape '\\'"));
												break;
											case "not_equals_str":  sb.AppendLine("   and " + sDATA_FIELD + " <> "   + "'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
											case "empty"         :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
											// 05/05/2010 Paul.  one_of was available in the UI, but was not generating the SQL. 
											case "one_of":
											{
												// 12/03/2008 Paul.  arrSEARCH_TEXT should already be populated.  Do not pull from lstFILTER_SEARCH_LISTBOX. 
												if ( arrSEARCH_TEXT != null && arrSEARCH_TEXT.Length > 0 )
												{
													sb.Append("   and " + sDATA_FIELD + " in (");
													for ( int j = 0; j < arrSEARCH_TEXT.Length; j++ )
													{
														if ( j > 0 )
															sb.Append(", ");
														sb.Append("N'" + Sql.EscapeSQL(arrSEARCH_TEXT[j]) + "'");
													}
													sb.AppendLine(")");
												}
												break;
											}
										}
									}
									break;
								}
								case "enum":
								{
									// 07/16/2006 Paul.  Oracle and DB2 are case-significant.  Keep SQL Server code fast by not converting to uppercase. 
									if ( bIsOracle || bIsDB2 )
									{
										sSEARCH_TEXT1 = sSEARCH_TEXT1.ToUpper();
										sSEARCH_TEXT2 = sSEARCH_TEXT2.ToUpper();
										sDATA_FIELD   = "upper(" + sDATA_FIELD + ")";
									}
									// 10/28/2011 Paul.  QueryBuilder is now being used in the report builder. 
									// 07/23/2013 Paul.  Allow leading equals to indicate direct SQL statement, but limit to column name for now. 
									if ( sSEARCH_TEXT1.StartsWith("=") )
									{
										// 07/23/2013 Paul.  Use RdlUtil.ReportColumnName() to restrict the SQL to a column name. 
										var sCAT_SEP = (bIsOracle ? " || " : " + ");
										sSEARCH_TEXT1 = RdlUtil.ReportColumnName(sSEARCH_TEXT1.Substring(1));
										switch ( sOPERATOR )
										{
											// 02/09/2007 Paul.  enum uses is instead of equals operator. 
											case "is"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "   + sSEARCH_TEXT1);  break;
											case "one_of":
											{
												// 12/03/2008 Paul.  arrSEARCH_TEXT should already be populated.  Do not pull from lstFILTER_SEARCH_LISTBOX. 
												if ( arrSEARCH_TEXT != null && arrSEARCH_TEXT.Length > 0 )
												{
													sb.Append("   and " + sDATA_FIELD + " in (");
													for ( int j = 0; j < arrSEARCH_TEXT.Length; j++ )
													{
														if ( j > 0 )
															sb.Append(", ");
														sb.Append("'" + Sql.EscapeSQL(arrSEARCH_TEXT[j]) + "'");
													}
													sb.AppendLine(")");
												}
												break;
											}
											case "empty"         :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										}
									}
									else if ( bUseSQLParameters )
									{
										switch ( sOPERATOR )
										{
											// 02/09/2007 Paul.  enum uses is instead of equals operator. 
											case "is"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "   + sPARAMETER_NAME);  rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME, sDATA_TYPE,       sSEARCH_TEXT1      );  break;
											case "one_of":
											{
												// 12/03/2008 Paul.  arrSEARCH_TEXT should already be populated.  Do not pull from lstFILTER_SEARCH_LISTBOX. 
												if ( arrSEARCH_TEXT != null && arrSEARCH_TEXT.Length > 0 )
												{
													sb.Append("   and " + sDATA_FIELD + " in (");
													for ( int j = 0; j < arrSEARCH_TEXT.Length; j++ )
													{
														if ( j > 0 )
															sb.Append(", ");
														sb.Append(sPARAMETER_NAME + "_" + j.ToString("000"));
														rdl.AddQueryParameter(xQueryParameters, sPARAMETER_NAME + "_" + j.ToString("000"), "string", Sql.ToString(arrSEARCH_TEXT[j]));
													}
													sb.AppendLine(")");
												}
												break;
											}
											case "empty"         :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										}
									}
									else
									{
										switch ( sOPERATOR )
										{
											// 02/09/2007 Paul.  enum uses is instead of equals operator. 
											case "is"    :  sb.AppendLine("   and " + sDATA_FIELD + " = "   + "N'" + Sql.EscapeSQL(sSEARCH_TEXT1) + "'");  break;
											case "one_of":
											{
												// 12/03/2008 Paul.  arrSEARCH_TEXT should already be populated.  Do not pull from lstFILTER_SEARCH_LISTBOX. 
												if ( arrSEARCH_TEXT != null && arrSEARCH_TEXT.Length > 0 )
												{
													sb.Append("   and " + sDATA_FIELD + " in (");
													for ( int j = 0; j < arrSEARCH_TEXT.Length; j++ )
													{
														if ( j > 0 )
															sb.Append(", ");
														sb.Append("N'" + Sql.EscapeSQL(arrSEARCH_TEXT[j]) + "'");
													}
													sb.AppendLine(")");
												}
												break;
											}
											case "empty"         :  sb.AppendLine("   and " + sDATA_FIELD + " is null"    );  break;
											case "not_empty"     :  sb.AppendLine("   and " + sDATA_FIELD + " is not null");  break;
										}
									}
									break;
								}
							}
							nParameterIndex++;
						}
					}
					// 06/18/2006 Paul.  The element 'QueryParameters' in namespace 'http://schemas.microsoft.com/sqlserver/reporting/2005/01/reportdefinition' has incomplete content. List of possible elements expected: 'http://schemas.microsoft.com/sqlserver/reporting/2005/01/reportdefinition:QueryParameter'. 
					if ( xQueryParameters.ChildNodes.Count == 0 )
					{
						xQueryParameters.ParentNode.RemoveChild(xQueryParameters);
					}
				}
				catch(Exception ex)
				{
					sbErrors.Append(ex.Message);
				}
				// 06/02/2021 Paul.  React client needs to share code. 
				rdl.SetDataSetFields(hashAvailableModules);
			}
			string sReportSQL = sb.ToString();
			rdl.SetSingleNode("DataSets/DataSet/Query/CommandText", sReportSQL);
			return sReportSQL;
		}

		// 02/18/2018 Paul.  We need external access to the filter table for ModulesArchiveRules. 
		public DataTable ReportFilters()
		{
			DataTable dtFilters = new DataTable();
			XmlDocument xmlFilters = rdl.GetCustomProperty("Filters");
			dtFilters = XmlUtil.CreateDataTable(xmlFilters.DocumentElement, "Filter", new string[] {"ID", "MODULE_NAME", "DATA_FIELD", "DATA_TYPE", "OPERATOR", "SEARCH_TEXT"});
			return dtFilters;
		}

		private DataTable ReportColumnSource()
		{
			DataTable dtColumnSource = new DataTable();
			XmlDocument xmlRelationships = rdl.GetCustomProperty("Relationships");
			dtColumnSource = XmlUtil.CreateDataTable(xmlRelationships.DocumentElement, "Relationship", new string[] {"MODULE_NAME", "DISPLAY_NAME"});
			return dtColumnSource;
		}
		#endregion

		#region Filter Editing
		protected void FiltersGet(string sID, ref string sMODULE_NAME, ref string sDATA_FIELD, ref string sDATA_TYPE, ref string sOPERATOR, ref string[] arrSEARCH_TEXT)
		{
			XmlDocument xmlFilters = rdl.GetCustomProperty("Filters");
			XmlNode xFilter = xmlFilters.DocumentElement.SelectSingleNode("Filter[ID=\'" + sID + "\']");
			if ( xFilter != null )
			{
				sMODULE_NAME = XmlUtil.SelectSingleNode(xFilter, "MODULE_NAME");
				sDATA_FIELD  = XmlUtil.SelectSingleNode(xFilter, "DATA_FIELD" );
				sDATA_TYPE   = XmlUtil.SelectSingleNode(xFilter, "DATA_TYPE"  );
				sOPERATOR    = XmlUtil.SelectSingleNode(xFilter, "OPERATOR"   );
				//sSEARCH_TEXT = XmlUtil.GetSingleNode(xFilter, "SEARCH_TEXT");
				XmlNodeList nlValues = xFilter.SelectNodes("SEARCH_TEXT_VALUES");
				arrSEARCH_TEXT = new string[nlValues.Count];
				int i = 0;
				foreach ( XmlNode xValue in nlValues )
				{
					arrSEARCH_TEXT[i++] = xValue.InnerText;
				}
			}
		}

		protected void RemoveInvalidDisplayColumns()
		{
			Hashtable hashMODULES = new Hashtable();
			string sMODULE_TABLE = Sql.ToString(Application["Modules." + lstMODULE.SelectedValue + ".TableName"]);
			hashMODULES.Add(sMODULE_TABLE, lstMODULE.SelectedValue);

			XmlDocument xmlRelationships = rdl.GetCustomProperty("Relationships");
			DataView vwModuleColumnSource = new DataView(XmlUtil.CreateDataTable(xmlRelationships.DocumentElement, "Relationship", new string[] { "MODULE_NAME", "MODULE_ALIAS", "DISPLAY_NAME", "RELATIONSHIP_TYPE" }));
			vwModuleColumnSource.RowFilter = "RELATIONSHIP_TYPE = 'one-to-many'";
			foreach ( DataRowView row in vwModuleColumnSource )
			{
				// 10/31/2008 Paul.  Make sure not to add the same module twice. 
				if ( !hashMODULES.ContainsKey(Sql.ToString(row["MODULE_ALIAS"])) )
					hashMODULES.Add(Sql.ToString(row["MODULE_ALIAS"]), Sql.ToString(row["MODULE_NAME"]));
			}
			// 07/13/2006 Paul.  Related may not exist, so not forget to check. 
			if ( lstRELATED.SelectedValue.IndexOf(' ') >= 0 )
			{
				string sRELATED       = lstRELATED.SelectedValue.Split(' ')[0];
				string sRELATED_ALIAS = lstRELATED.SelectedValue.Split(' ')[1];
				// 10/31/2008 Paul.  Make sure not to add the same module twice. 
				if ( !hashMODULES.ContainsKey(sRELATED_ALIAS) )
					hashMODULES.Add(sRELATED_ALIAS, sRELATED);
			}
			XmlDocument xmlDisplayColumns = rdl.GetCustomProperty("DisplayColumns");
			try
			{
				ArrayList arrDeleted = new ArrayList();
				XmlNodeList nlFields = xmlDisplayColumns.DocumentElement.SelectNodes("DisplayColumn/Field");
				foreach ( XmlNode xField in nlFields )
				{
					// 07/13/2006 Paul.  The column stores the module and the alias.  We need to verify the alias. 
					string sDATA_FIELD = xField.InnerText;
					if ( sDATA_FIELD.IndexOf('.') >= 0 )
					{
						string sMODULE_ALIAS = sDATA_FIELD.Split('.')[0];
						if ( !hashMODULES.ContainsKey(sMODULE_ALIAS) )
						{
							arrDeleted.Add(xField);
						}
					}
					else
					{
						// Delete filter if not formatted properly.  It must include the table alias. 
						arrDeleted.Add(xField);
					}
				}
				foreach ( XmlNode xField in arrDeleted )
				{
					rdl.RemoveField(xField.InnerText);
					xmlDisplayColumns.DocumentElement.RemoveChild(xField.ParentNode);
				}
				rdl.SetCustomProperty("DisplayColumns", xmlDisplayColumns.OuterXml.Replace("</DisplayColumn>", "</DisplayColumn>" + ControlChars.CrLf));
			}
			catch(Exception ex)
			{
				lblError.Text = ex.Message;
			}
		}

		protected void RemoveInvalidFilters()
		{
			Hashtable hashMODULES = new Hashtable();
			string sMODULE_TABLE = Sql.ToString(Application["Modules." + lstMODULE.SelectedValue + ".TableName"]);
			hashMODULES.Add(sMODULE_TABLE, lstMODULE.SelectedValue);

			XmlDocument xmlRelationships = rdl.GetCustomProperty("Relationships");
			DataView vwModuleColumnSource = new DataView(XmlUtil.CreateDataTable(xmlRelationships.DocumentElement, "Relationship", new string[] { "MODULE_NAME", "MODULE_ALIAS", "DISPLAY_NAME", "RELATIONSHIP_TYPE" }));
			vwModuleColumnSource.RowFilter = "RELATIONSHIP_TYPE = 'one-to-many'";
			foreach ( DataRowView row in vwModuleColumnSource )
			{
				// 10/31/2008 Paul.  Make sure not to add the same module twice. 
				if ( !hashMODULES.ContainsKey(Sql.ToString(row["MODULE_ALIAS"])) )
					hashMODULES.Add(Sql.ToString(row["MODULE_ALIAS"]), Sql.ToString(row["MODULE_NAME"]));
			}
			// 07/13/2006 Paul.  Related may not exist, so not forget to check. 
			if ( lstRELATED.SelectedValue.IndexOf(' ') >= 0 )
			{
				string sRELATED       = lstRELATED.SelectedValue.Split(' ')[0];
				string sRELATED_ALIAS = lstRELATED.SelectedValue.Split(' ')[1];
				// 10/31/2008 Paul.  Make sure not to add the same module twice. 
				if ( !hashMODULES.ContainsKey(sRELATED_ALIAS) )
					hashMODULES.Add(sRELATED_ALIAS, sRELATED);
			}

			XmlDocument xmlFilters = rdl.GetCustomProperty("Filters");
			try
			{
				ArrayList arrDeleted = new ArrayList();
				XmlNodeList nlFilters = xmlFilters.DocumentElement.SelectNodes("Filter");
				foreach ( XmlNode xFilter in nlFilters )
				{
					// 07/13/2006 Paul.  The filter stores the module and the alias.  We need to verify the alias. 
					string sDATA_FIELD = XmlUtil.SelectSingleNode(xFilter, "DATA_FIELD");
					if ( sDATA_FIELD.IndexOf('.') >= 0 )
					{
						string sMODULE_ALIAS = sDATA_FIELD.Split('.')[0];
						if ( !hashMODULES.ContainsKey(sMODULE_ALIAS) )
						{
							arrDeleted.Add(xFilter);
						}
					}
					else
					{
						// Delete filter if not formatted properly.  It must include the table alias. 
						arrDeleted.Add(xFilter);
					}
				}
				foreach ( XmlNode xFilter in arrDeleted )
				{
					xmlFilters.DocumentElement.RemoveChild(xFilter);
				}
				rdl.SetCustomProperty("Filters", xmlFilters.OuterXml);
				
				dgFilters.DataSource = ReportFilters();
				dgFilters.DataBind();
			}
			catch(Exception ex)
			{
				lblError.Text = ex.Message;
			}
		}

		protected void FiltersUpdate(string sID, string sMODULE_NAME, string sDATA_FIELD, string sDATA_TYPE, string sOPERATOR, string[] arrSEARCH_TEXT)
		{
			XmlDocument xmlFilters = rdl.GetCustomProperty("Filters");
			try
			{
				XmlNode xFilter = xmlFilters.DocumentElement.SelectSingleNode("Filter[ID=\'" + sID + "\']");
				if ( xFilter == null || Sql.IsEmptyString(sID) )
				{
					xFilter = xmlFilters.CreateElement("Filter");
					xmlFilters.DocumentElement.AppendChild(xFilter);
					XmlUtil.SetSingleNode(xmlFilters, xFilter, "ID", Guid.NewGuid().ToString());
				}
				else
				{
					// 06/12/2006 Paul.  The easiest way to remove the old text values is to delete them all. 
					xFilter.RemoveAll();
					XmlUtil.SetSingleNode(xmlFilters, xFilter, "ID", sID);
				}
				XmlUtil.SetSingleNode(xmlFilters, xFilter, "MODULE_NAME", sMODULE_NAME  );
				XmlUtil.SetSingleNode(xmlFilters, xFilter, "DATA_FIELD" , sDATA_FIELD   );
				XmlUtil.SetSingleNode(xmlFilters, xFilter, "DATA_TYPE"  , sDATA_TYPE    );
				XmlUtil.SetSingleNode(xmlFilters, xFilter, "OPERATOR"   , sOPERATOR     );
				XmlUtil.SetSingleNode(xmlFilters, xFilter, "SEARCH_TEXT", String.Join(", ", arrSEARCH_TEXT));
				foreach ( string sSEARCH_TEXT in arrSEARCH_TEXT )
				{
					XmlNode xSearchText = xmlFilters.CreateElement("SEARCH_TEXT_VALUES");
					xFilter.AppendChild(xSearchText);
					xSearchText.InnerText = sSEARCH_TEXT;
				}
				
				rdl.SetCustomProperty("Filters", xmlFilters.OuterXml);
				
				dgFilters.DataSource = ReportFilters();
				dgFilters.DataBind();
			}
			catch(Exception ex)
			{
				lblError.Text = ex.Message;
			}
		}

		protected void FiltersDelete(string sID)
		{
			dgFilters.EditItemIndex = -1;
			XmlDocument xmlFilters = rdl.GetCustomProperty("Filters");
			XmlNode xFilter = xmlFilters.DocumentElement.SelectSingleNode("Filter[ID=\'" + sID + "\']");
			if ( xFilter != null )
			{
				xFilter.ParentNode.RemoveChild(xFilter);
				rdl.SetCustomProperty("Filters", xmlFilters.OuterXml);
			}
			dgFilters.DataSource = ReportFilters();
			dgFilters.DataBind();
		}

		protected void DisplayColumnsUpdate()
		{
			// 06/15/2006 Paul.  There is no need to load the existing Fields data as we are going to completely replace it. 
			//string sFields = rdl.GetCustomProperty("DisplayColumns");
			try
			{
				XmlDocument xmlDisplayColumns = new XmlDocument();
				xmlDisplayColumns.AppendChild(xmlDisplayColumns.CreateElement("DisplayColumns"));

				if ( bDesignChart )
				{
					XmlNode xDisplayColumn = xmlDisplayColumns.CreateElement("DisplayColumn");
					xmlDisplayColumns.DocumentElement.AppendChild(xDisplayColumn);

					XmlNode xLabel = xmlDisplayColumns.CreateElement("Label");
					XmlNode xField = xmlDisplayColumns.CreateElement("Field");
					xDisplayColumn.AppendChild(xLabel);
					xDisplayColumn.AppendChild(xField);
					xLabel.InnerText = lstCATEGORY_COLUMN.SelectedItem.Text;
					xField.InnerText = lstCATEGORY_COLUMN.SelectedValue;

					xDisplayColumn = xmlDisplayColumns.CreateElement("DisplayColumn");
					xmlDisplayColumns.DocumentElement.AppendChild(xDisplayColumn);

					xLabel = xmlDisplayColumns.CreateElement("Label");
					xField = xmlDisplayColumns.CreateElement("Field");
					xDisplayColumn.AppendChild(xLabel);
					xDisplayColumn.AppendChild(xField);
					xLabel.InnerText = lstSERIES_COLUMN.SelectedItem.Text;
					xField.InnerText = lstSERIES_COLUMN.SelectedValue;
				}
				else
				{
					DataTable dtDisplayColumns = ctlDisplayColumnsChooser.LeftValuesTable;
					if ( dtDisplayColumns != null )
					{
						foreach ( DataRow row in dtDisplayColumns.Rows )
						{
							// 07/15/2006 Paul.  Store  both the header and the field. 
							// The previous method of relying upon the RDL Header notes has a greater potential for errors. 
							XmlNode xDisplayColumn = xmlDisplayColumns.CreateElement("DisplayColumn");
							xmlDisplayColumns.DocumentElement.AppendChild(xDisplayColumn);

							XmlNode xLabel = xmlDisplayColumns.CreateElement("Label");
							XmlNode xField = xmlDisplayColumns.CreateElement("Field");
							xDisplayColumn.AppendChild(xLabel);
							xDisplayColumn.AppendChild(xField);
							xLabel.InnerText = Sql.ToString(row["text" ]);
							xField.InnerText = Sql.ToString(row["value"]);
						}
					}
				}
				rdl.SetCustomProperty("DisplayColumns", xmlDisplayColumns.OuterXml.Replace("</DisplayColumn>", "</DisplayColumn>" + ControlChars.CrLf));
			}
			catch(Exception ex)
			{
				lblError.Text = ex.Message;
			}
		}
		#endregion

		#region Chart Editing
		private string GetFieldTitle(string sField)
		{
			string sTitle = String.Empty;
			string[] arrField = sField.Split('.');
			if ( arrField.Length >= 2 )
			{
				string sTableName = arrField[0];
				string sFieldName = arrField[1];
				sTitle = Utils.TableColumnName(L10n, Crm.Modules.ModuleName(sTableName), sFieldName);
			}
			return sTitle;
		}

		public string GetChartType()
		{
			// 03/12/2012 Paul.  An early release used Columns and not Column and broke compatibility with MS Report Builder 3.0. 
			string sChartType = "Column";
			if      ( radChartTypeColumn.Checked ) sChartType = "Column" ;
			else if ( radChartTypeBar   .Checked ) sChartType = "Bar"    ;
			else if ( radChartTypeLine  .Checked ) sChartType = "Line"   ;
			else if ( radChartTypeShape .Checked ) sChartType = "Shape"  ;
			return sChartType;
		}

		private void UpdateChart()
		{
			// 11/08/2011 Paul.  Getting the chart name is a bit of a cludge, but it works and it is safe. 
			string sChartTitle       = Sql.ToString(Request["ctl00$cntBody$ctlEditView$txtNAME"]);
			string sChartType        = GetChartType();
			string sSeriesColumn     = lstSERIES_COLUMN.SelectedValue;
			string sSeriesOperator   = lstSERIES_OPERATOR.SelectedValue;
			string sSeriesTitle      = GetFieldTitle(lstSERIES_COLUMN.SelectedValue);
			string sCategoryColumn   = lstCATEGORY_COLUMN.SelectedValue;
			string sCategoryOperator = lstCATEGORY_OPERATOR.Items.Count > 0 ? lstCATEGORY_OPERATOR.SelectedValue : String.Empty;
			string sCategoryTitle    = GetFieldTitle(lstCATEGORY_COLUMN.SelectedValue);
			if ( sSeriesOperator == "count" )
			{
				string[] arrModule = lstMODULE_COLUMN_SOURCE.SelectedValue.Split(' ');
				string sModule     = arrModule[0];
				string sTableAlias = arrModule[1];
				sSeriesTitle = L10n.Term(".moduleList." + sModule);
			}
			//Thread.CurrentThread.CurrentCulture.DateTimeFormat.MonthNames
			//Thread.CurrentThread.CurrentCulture.DateTimeFormat.AbbreviatedMonthNames
			rdl.UpdateChart(sChartTitle, sChartType, sSeriesTitle, sSeriesColumn, sSeriesOperator, sCategoryTitle, sCategoryColumn, sCategoryOperator, Thread.CurrentThread.CurrentCulture.DateTimeFormat.ShortDatePattern);
		}

		protected void CHART_TYPE_Changed(Object sender, EventArgs e)
		{
			UpdateChart();
			if ( Command != null )
			{
				CommandEventArgs args = new CommandEventArgs("Chart.Change", "Type");
				Command(sender, args);
			}
		}

		private void lstSERIES_OPERATOR_Bind()
		{
			lstSERIES_OPERATOR.DataSource = null;
			lstSERIES_OPERATOR.Items.Clear();

			string[] arrModule = lstMODULE_COLUMN_SOURCE.SelectedValue.Split(' ');
			string sModule     = arrModule[0];
			string sTableAlias = arrModule[1];
			
			string[] arrColumn = lstSERIES_COLUMN.SelectedValue.Split('.');
			string sColumnName = arrColumn[0];
			if ( arrColumn.Length > 1 )
				sColumnName = arrColumn[1];
			
			string sMODULE_TABLE = Sql.ToString(Application["Modules." + sModule + ".TableName"]);
			DataView vwColumns = new DataView(SplendidCache.ReportingFilterColumns(sMODULE_TABLE).Copy());
			vwColumns.RowFilter = "ColumnName = '" + sColumnName + "'";
			
			if ( vwColumns.Count > 0 )
			{
				DataRowView row = vwColumns[0];
				string sCsType = Sql.ToString(row["CsType"]);
				lblSERIES_OPERATOR_TYPE.Text = sCsType.ToLower();
				
				lstSERIES_OPERATOR.DataSource = SplendidCache.List("series_" + sCsType.ToLower() + "_operator_dom");
				lstSERIES_OPERATOR.DataBind();
				lblSERIES_OPERATOR.Text = lstSERIES_OPERATOR.SelectedValue;
			}
		}

		protected void lstSERIES_COLUMN_Changed(Object sender, EventArgs e)
		{
			lblSERIES_COLUMN.Text = lstSERIES_COLUMN.SelectedValue;
			lstSERIES_OPERATOR_Bind();
			UpdateChart();
			if ( Command != null )
			{
				CommandEventArgs args = new CommandEventArgs("Chart.Change", "Series");
				Command(sender, args);
			}
		}

		protected void lstSERIES_OPERATOR_Changed(Object sender, EventArgs e)
		{
			UpdateChart();
			if ( Command != null )
			{
				CommandEventArgs args = new CommandEventArgs("Chart.Change", "Series");
				Command(sender, args);
			}
		}

		private void lstCATEGORY_OPERATOR_Bind()
		{
			lstCATEGORY_OPERATOR.DataSource = null;
			lstCATEGORY_OPERATOR.Items.Clear();

			string[] arrModule = lstMODULE_COLUMN_SOURCE.SelectedValue.Split(' ');
			string sModule     = arrModule[0];
			string sTableAlias = arrModule[1];
			
			string[] arrColumn = lstCATEGORY_COLUMN.SelectedValue.Split('.');
			string sColumnName = arrColumn[0];
			if ( arrColumn.Length > 1 )
				sColumnName = arrColumn[1];
			
			string sMODULE_TABLE = Sql.ToString(Application["Modules." + sModule + ".TableName"]);
			DataView vwColumns = new DataView(SplendidCache.ReportingFilterColumns(sMODULE_TABLE).Copy());
			vwColumns.RowFilter = "ColumnName = '" + sColumnName + "'";
			
			if ( vwColumns.Count > 0 )
			{
				DataRowView row = vwColumns[0];
				string sCsType = Sql.ToString(row["CsType"]);
				lblCATEGORY_OPERATOR_TYPE.Text = sCsType.ToLower();
				
				lstCATEGORY_OPERATOR.DataSource = SplendidCache.List("category_" + sCsType.ToLower() + "_operator_dom");
				lstCATEGORY_OPERATOR.DataBind();
				lblCATEGORY_OPERATOR.Text = lstCATEGORY_OPERATOR.SelectedValue;
			}
			lstCATEGORY_OPERATOR.Visible      = (lstCATEGORY_OPERATOR.Items.Count > 0);
			lblCATEGORY_OPERATOR.Visible      = lstCATEGORY_OPERATOR.Visible;
			lblCATEGORY_OPERATOR_TYPE.Visible = lstCATEGORY_OPERATOR.Visible;
		}

		protected void lstCATEGORY_COLUMN_Changed(Object sender, EventArgs e)
		{
			lblCATEGORY_COLUMN.Text = lstCATEGORY_COLUMN.SelectedValue;
			lstCATEGORY_OPERATOR_Bind();
			UpdateChart();
			if ( Command != null )
			{
				CommandEventArgs args = new CommandEventArgs("Chart.Change", "Category");
				Command(sender, args);
			}
		}

		protected void lstCATEGORY_OPERATOR_Changed(Object sender, EventArgs e)
		{
			lblCATEGORY_OPERATOR.Text = lstCATEGORY_OPERATOR.SelectedValue;
			UpdateChart();
			if ( Command != null )
			{
				CommandEventArgs args = new CommandEventArgs("Chart.Change", "Category");
				Command(sender, args);
			}
		}

		#endregion

		public void CreateRdl(string sNAME, string sAUTHOR, string sASSIGNED_USER_ID)
		{
			LoadRdl(String.Empty);
			rdl.SetCustomProperty("ReportName"    , sNAME            );
			rdl.SetSingleNode    ("Author"        , sAUTHOR          );
			rdl.SetCustomProperty("AssignedUserID", sASSIGNED_USER_ID);
		}

		public void LoadRdl(string sRDL)
		{
			try
			{
				rdl = new RdlDocument();
				DataView vwModules = new DataView(SplendidCache.ReportingModules());
				if ( arrModules != null && arrModules.Length > 0 )
				{
					vwModules.RowFilter = "MODULE_NAME in ('" + String.Join("', '", arrModules) + "')";
				}
				vwModules.Sort = "DISPLAY_NAME";
				lstMODULE.DataSource = vwModules;
				lstMODULE.DataBind();
				// 03/29/2012 Paul.  Add Rules Wizard support to Terminology module. 
				if ( Security.IS_ADMIN && arrModules != null && arrModules.Length > 0 && arrModules[0] == "Terminology" )
				{
					lstMODULE.Items.Add(new ListItem(L10n.Term(".moduleList.Terminology"), "Terminology"));
				}
				lblMODULE.Text = lstMODULE.SelectedValue;
				
				try
				{
					if ( !Sql.IsEmptyString(sRDL) )
					{
						rdl.LoadRdl(sRDL);
						
						// 08/19/2010 Paul.  Check the list before assigning the value. 
						string sMODULE_NAME = rdl.GetCustomPropertyValue("Module");
						// 11/08/2011 Paul.  The chart may have been created in Report Builder and will not have custom properties. 
						if ( Sql.IsEmptyString(sMODULE_NAME) )
						{
							string sCommandText = rdl.CommandText();
							foreach ( DataRowView row in vwModules )
							{
								string sTABLE_NAME = Sql.ToString(row["TABLE_NAME"]);
								if ( sCommandText.Contains("from vw" + sTABLE_NAME + " ") )
								{
									sMODULE_NAME = Sql.ToString(row["MODULE_NAME"]);
									break;
								}
							}
						}
						Utils.SetSelectedValue(lstMODULE, sMODULE_NAME);
						lblMODULE.Text = lstMODULE.SelectedValue;
					}
				}
				catch
				{
				}
				// 05/27/2006 Paul.  This is a catch-all statement to create a new report if all else fails. 
				if ( rdl.DocumentElement == null )
				{
					rdl = new RdlDocument(String.Empty, String.Empty, bDesignChart);
					rdl.SetCustomProperty("Module"        , lstMODULE.SelectedValue  );
					rdl.SetCustomProperty("Related"       , lstRELATED.SelectedValue );
				}
				// 10/24/2010 Paul.  We need to clear the related control before rebinding, otherwise it will throw an exception if the selected value is already set. 
				// This was first encountered when used inthe RulesWizard. 
				lstRELATED.DataSource = null;
				lstRELATED.DataBind();
				lstRELATED_Bind();
				try
				{
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstRELATED, rdl.GetCustomPropertyValue("Related"));
					lblRELATED.Text = lstRELATED.SelectedValue;
				}
				catch
				{
				}
				// 07/26/2007 Paul.  The column sources need to be updated after the related has changed. 
				lstFILTER_COLUMN_SOURCE_Bind();
				//ctlDisplayColumnsChooser_Bind();  // 07/26/2007 Paul.  Already called inside lstFILTER_COLUMN_SOURCE_Bind. 
				if ( bDesignChart )
				{
					try
					{
						string sChartType = rdl.SelectNodeValue("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/Type");
						switch ( sChartType )
						{
							// 03/12/2012 Paul.  An early release used Columns and not Column and broke compatibility with MS Report Builder 3.0. 
							case "Column" :  radChartTypeColumn.Checked = true;  break;
							case "Columns":  radChartTypeColumn.Checked = true;  break;
							case "Bar"    :  radChartTypeBar   .Checked = true;  break;
							case "Line"   :  radChartTypeLine  .Checked = true;  break;
							case "Shape"  :  radChartTypeShape .Checked = true;  break;
							default       :  radChartTypeColumn.Checked = true;  break;
						}
					}
					catch
					{
					}
					// 11/05/2011 Paul.  lstSERIES_COLUMN will be bound in lstFILTER_COLUMN_SOURCE_Bind(). 
					try
					{
						string sYField = rdl.SelectNodeValue("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartDataPoints/ChartDataPoint/ChartDataPointValues/Y");
						// 05/26/2021 Paul.  Must determine the operator before it is changed due to *.  This is to match React client code. 
						string sSeriesOperator = "sum";
						if      ( sYField.StartsWith("=Avg("    ) ) sSeriesOperator = "avg";
						else if ( sYField.StartsWith("=Sum("    ) ) sSeriesOperator = "sum";
						else if ( sYField.StartsWith("=Min("    ) ) sSeriesOperator = "min";
						else if ( sYField.StartsWith("=Max("    ) ) sSeriesOperator = "max";
						else if ( sYField.StartsWith("=Count(*)") ) sSeriesOperator = "count";
						else if ( sYField.StartsWith("=Count("  ) ) sSeriesOperator = "count_not_empty";

						if ( sYField.Contains("*") )
							sYField = rdl.SelectNodeAttribute("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries", "Name");
						string sFieldName = rdl.LookupDateField(sYField);
						//Utils.SetSelectedValue(lstSERIES_COLUMN, sFieldName);
						// 11/08/2011 Paul.  If the item does not exist, then add it. 
						if ( !Sql.IsEmptyString(sFieldName) )
						{
							ListItem itm = lstSERIES_COLUMN.Items.FindByValue(sFieldName);
							if ( itm == null )
							{
								lstSERIES_COLUMN.Items.Add(new ListItem(sFieldName, sFieldName));
							}
							lstSERIES_COLUMN.SelectedValue = sFieldName;
						}
						lblSERIES_COLUMN.Text = lstSERIES_COLUMN.SelectedValue;
						lstSERIES_OPERATOR_Bind();

						// 11/12/2011 Paul.  The series operator needs to be set after the series column so that the correct values are in the list. 
						Utils.SetSelectedValue(lstSERIES_OPERATOR, sSeriesOperator);
						lblSERIES_OPERATOR.Text = lstSERIES_OPERATOR.SelectedValue;
						lblSERIES_OPERATOR_TYPE.Text = rdl.LookupDateFieldType(sYField);
					}
					catch
					{
					}
					try
					{
						string sXField = rdl.SelectNodeValue("Body/ReportItems/Chart/ChartCategoryHierarchy/ChartMembers/ChartMember/Group/GroupExpressions/GroupExpression");
						string sFieldName = rdl.LookupDateField(sXField);
						//Utils.SetSelectedValue(lstCATEGORY_COLUMN, sFieldName);
						// 11/08/2011 Paul.  If the item does not exist, then add it. 
						if ( !Sql.IsEmptyString(sFieldName) )
						{
							ListItem itm = lstCATEGORY_COLUMN.Items.FindByValue(sFieldName);
							if ( itm == null )
							{
								lstCATEGORY_COLUMN.Items.Add(new ListItem(sFieldName, sFieldName));
							}
							lstCATEGORY_COLUMN.SelectedValue = sFieldName;
						}
						lblCATEGORY_COLUMN.Text = lstCATEGORY_COLUMN.SelectedValue;
						lstCATEGORY_OPERATOR_Bind();
						
						string sCategoryOperator = String.Empty;
						string sCategoryAxesFormat  = rdl.SelectNodeValue("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis/Style/Format");
						if ( sCategoryAxesFormat.Contains("d") )
							sCategoryOperator = "day";
						else if ( sCategoryAxesFormat.Contains("w") )
							sCategoryOperator = "week";
						else if ( sCategoryAxesFormat.Contains("M") )
							sCategoryOperator = "month";
						else if ( sCategoryAxesFormat.Contains("q") )
							sCategoryOperator = "quarter";
						else if ( sCategoryAxesFormat.Contains("y") )
							sCategoryOperator = "year";
						Utils.SetSelectedValue(lstCATEGORY_OPERATOR, sCategoryOperator);
						lblCATEGORY_OPERATOR.Text = lstCATEGORY_OPERATOR.SelectedValue;
						lblCATEGORY_OPERATOR_TYPE.Text = rdl.LookupDateFieldType(sXField);
					}
					catch
					{
					}
					// 11/15/2011 Paul.  DisplayColumnsUpdate will work for charts because values are taken from populated controls. 
					DisplayColumnsUpdate();
				}
				// 11/15/2011 Paul.  DisplayColumnsUpdate will not work here for reports because the hidden fields are not populated after loading the report. 
				//DisplayColumnsUpdate();
				// 05/14/2021 Paul.  Convert to static method so that we can use in the React client. 
				Hashtable hashAvailableModules = new Hashtable();
				StringBuilder sbErrors = new StringBuilder();
				sReportSQL = BuildReportSQL(Application, rdl, bPrimaryKeyOnly, bUseSQLParameters, bDesignChart, bUserSpecific, lstMODULE.SelectedValue, lstRELATED.SelectedValue, hashAvailableModules, sbErrors);
				if ( sbErrors.Length > 0 )
					lblError.Text = sbErrors.ToString();
				// 07/13/2006 Paul.  The DisplayColumns List must be bound after the ReportSQL is built. 
				lstLeftListBox_Bind();
				if ( bDesignChart && Sql.IsEmptyString(sRDL) )
				{
					UpdateChart();
					if ( Command != null )
					{
						CommandEventArgs args = new CommandEventArgs("Chart.Change", "New");
						Command(null, args);
					}
				}

				dgFilters.DataSource = ReportFilters();
				dgFilters.DataBind();
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			lblMODULE              .Visible = bDebug;
			lblRELATED             .Visible = bDebug;
			lblMODULE_COLUMN_SOURCE.Visible = bDebug;
			lblFILTER_COLUMN_SOURCE.Visible = bDebug;
			lblFILTER_COLUMN       .Visible = bDebug;
			lblFILTER_OPERATOR_TYPE.Visible = bDebug;
			lblFILTER_OPERATOR     .Visible = bDebug;
			lblFILTER_ID           .Visible = bDebug;
			try
			{
				// 02/02/2010 Paul.  On initial load, the Dynamic List flag is disabled and the RDL does not get generated and saved in the PreRender 
				// because the control is not visible (and therefore not rendered).  So, if there is no RDL, then we need go generate it. 
				string sRdl = Sql.ToString(ViewState["rdl"]);
				if ( !IsPostBack || Sql.IsEmptyString(sRdl) )
				{
					txtACTIVE_TAB.Value = "1";
					// 07/13/2006 Paul.  We don't store the SHOW_QUERY value in the RDL, so we must retrieve it from the session. 
					chkSHOW_QUERY.Checked = Sql.ToBoolean(Session["QueryBuilder.SHOW_QUERY"]);
					
					if ( rdl == null )
					{
						DataView vwModules = new DataView(SplendidCache.ReportingModules());
						if ( arrModules != null && arrModules.Length > 0 )
						{
							vwModules.RowFilter = "MODULE_NAME in ('" + String.Join("', '", arrModules) + "')";
						}
						vwModules.Sort = "DISPLAY_NAME";
						lstMODULE.DataSource = vwModules;
						lstMODULE.DataBind();
						// 03/29/2012 Paul.  Add Rules Wizard support to Terminology module. 
						// 02/17/2018 Paul.  arrModules might be null. 
						if ( Security.IS_ADMIN && arrModules != null && arrModules.Length > 0 && arrModules[0] == "Terminology" )
						{
							lstMODULE.Items.Add(new ListItem(L10n.Term(".moduleList.Terminology"), "Terminology"));
						}
						lblMODULE.Text = lstMODULE.SelectedValue;
						
						rdl = new RdlDocument(String.Empty, String.Empty, bDesignChart);
						rdl.SetCustomProperty("Module"        , lstMODULE.SelectedValue  );
						rdl.SetCustomProperty("Related"       , lstRELATED.SelectedValue );
						
						lstRELATED_Bind();
						try
						{
							// 08/19/2010 Paul.  Check the list before assigning the value. 
							Utils.SetSelectedValue(lstRELATED, rdl.GetCustomPropertyValue("Related"));
						}
						catch
						{
						}
						// 07/26/2007 Paul.  The column sources need to be updated after the related has changed. 
						lstFILTER_COLUMN_SOURCE_Bind();
						if ( bDesignChart )
						{
							radChartTypeColumn.Checked = true;
							lstSERIES_OPERATOR_Changed(null, null);
							lstCATEGORY_OPERATOR_Changed(null, null);
						}
						if ( bUseSQLParameters )
						{
							DisplayColumnsUpdate();
							// 11/06/2011 Paul.  A chart cannot have the Table cells. 
							if ( !bDesignChart )
							{
								XmlDocument xmlDisplayColumns = rdl.GetCustomProperty("DisplayColumns");
								DataTable dtDisplayColumns = XmlUtil.CreateDataTable(xmlDisplayColumns.DocumentElement, "DisplayColumn", new string[] { "Label", "Field"});
								rdl.UpdateDataTable(dtDisplayColumns);
								xmlDisplayColumns = null;
							}
						}
						// 05/14/2021 Paul.  Convert to static method so that we can use in the React client. 
						Hashtable hashAvailableModules = new Hashtable();
						StringBuilder sbErrors = new StringBuilder();
						sReportSQL = BuildReportSQL(Application, rdl, bPrimaryKeyOnly, bUseSQLParameters, bDesignChart, bUserSpecific, lstMODULE.SelectedValue, lstRELATED.SelectedValue, hashAvailableModules, sbErrors);
						if ( sbErrors.Length > 0 )
							lblError.Text = sbErrors.ToString();

						dgFilters.DataSource = ReportFilters();
						dgFilters.DataBind();
					}
				}
				else
				{
					// 07/13/2006 Paul.  Save the SHOW_QUERY flag in the Session so that it will be available across redirects. 
					Session["QueryBuilder.SHOW_QUERY"] = chkSHOW_QUERY.Checked;

					rdl = new RdlDocument();
					rdl.LoadRdl(sRdl);

					if ( bUseSQLParameters )
					{
						// 07/15/2006 Paul.  The DisplayColumns custom node will not be the primary location of the column data. 
						// Always just push to the RDL Headers instead of trying to read from them. 
						DisplayColumnsUpdate();
						// 11/06/2011 Paul.  A chart cannot have the Table cells. 
						if ( !bDesignChart )
						{
							XmlDocument xmlDisplayColumns = rdl.GetCustomProperty("DisplayColumns");
							DataTable dtDisplayColumns = XmlUtil.CreateDataTable(xmlDisplayColumns.DocumentElement, "DisplayColumn", new string[] { "Label", "Field"});
							rdl.UpdateDataTable(dtDisplayColumns);
							xmlDisplayColumns = null;
						}
					}

					// 05/14/2021 Paul.  Convert to static method so that we can use in the React client. 
					Hashtable hashAvailableModules = new Hashtable();
					StringBuilder sbErrors = new StringBuilder();
					sReportSQL = BuildReportSQL(Application, rdl, bPrimaryKeyOnly, bUseSQLParameters, bDesignChart, bUserSpecific, lstMODULE.SelectedValue, lstRELATED.SelectedValue, hashAvailableModules, sbErrors);
					if ( sbErrors.Length > 0 )
						lblError.Text = sbErrors.ToString();

					dgFilters.DataSource = ReportFilters();
					dgFilters.DataBind();
				}
				// 01/22/2015 Paul.  Need event when loading is complete. 
				if ( Command != null )
					Command(this, new CommandEventArgs("QueryBuilder.Loaded", null));
#if DEBUG
				//RegisterClientScriptBlock("ReportSQL", "<script type=\"text/javascript\">sDebugSQL += '" + Sql.EscapeJavaScript("\r" + sReportSQL) + "';</script>");
#endif
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				lblError.Text = ex.Message;
			}
		}

		private void Page_PreRender(object sender, System.EventArgs e)
		{
			if ( chkSHOW_QUERY.Checked )
			{
				litREPORT_QUERY.Text = "<br /><table border=\"1\" cellpadding=\"3\" cellspacing=\"0\" width=\"100%\" bgcolor=\"LightGrey\"><tr><td>";
				litREPORT_QUERY.Text += "<pre><b>" + sReportSQL + "</b></pre>";
				litREPORT_QUERY.Text += "</td></tr></table><br />";
#if DEBUG
				// 07/15/2010 Paul.  Use new function to format Rdl. 
				if ( rdl != null && rdl.DocumentElement != null)
					litREPORT_RDL.Text = RdlUtil.RdlEncode(rdl);
#endif
			}
			else
			{
				// 07/15/2010 Paul.  If not checked, we must clear the literal. 
				litREPORT_QUERY.Text = String.Empty;
			}
			ViewState["rdl"] = rdl.OuterXml;
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
			this.PreRender += new System.EventHandler(this.Page_PreRender);
		}
		#endregion
	}
}
