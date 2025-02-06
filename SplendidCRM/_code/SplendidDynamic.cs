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
using System.Xml;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections;
using System.Collections.Specialized;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.SessionState;
using System.Diagnostics;
// 11/03/2021 Paul.  ASP.Net components are not needed. 
#if !ReactOnlyUI
using SplendidCRM._controls;
#endif
// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
using CKEditor.NET;
using AjaxControlToolkit;
using System.Workflow.Activities.Rules;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for SplendidDynamic.
	/// </summary>
	public class SplendidDynamic
	{
		// 05/28/2015 Paul.  The stacked layout started with the Seven theme. 
		public static bool StackedLayout(string sTheme, string sViewName)
		{
			return (sTheme == "Seven" && !sViewName.EndsWith(".Preview"));
		}

		public static bool StackedLayout(string sTheme)
		{
			return (sTheme == "Seven");
		}

// 11/03/2021 Paul.  ASP.Net components are not needed. 
#if !ReactOnlyUI
		public static void AppendGridColumns(string sGRID_NAME, DataGrid grd)
		{
			AppendGridColumns(sGRID_NAME, grd, null);
		}
#endif

		// 09/23/2015 Paul.  Need to include the data grid fields as it will be bound using the same data set. 
		public static string ExportGridColumns(string sGRID_NAME, UniqueStringCollection arrDataGridSelectedFields)
		{
			StringBuilder sbSQL = new StringBuilder();
			UniqueStringCollection arrSelectFields = new UniqueStringCollection();
			if ( arrDataGridSelectedFields != null )
			{
				foreach ( string sField in arrDataGridSelectedFields )
				{
					arrSelectFields.Add(sField);
				}
			}
			// 05/03/2011 Paul.  Always include the ID as it might be used by the Export code to filter by selected items. 
			arrSelectFields.Add("ID");
			GridColumns(sGRID_NAME, arrSelectFields, null);
			// 04/20/2011 Paul.  If there are no fields in the GridView.Export, then return all fields (*). 
			if ( arrSelectFields.Count > 0 )
			{
				foreach ( string sField in arrSelectFields )
				{
					if ( sbSQL.Length > 0 )
						sbSQL.Append("     , ");
					sbSQL.AppendLine(sField);
				}
			}
			else
			{
				sbSQL.AppendLine("*");
			}
			return sbSQL.ToString();
		}

		// 01/02/2020 Paul.  We need to be able to skip fields. 
		public static string ExportGridColumns(string sGRID_NAME, UniqueStringCollection arrDataGridSelectFields, StringCollection arrSkippedFields)
		{
			StringBuilder sbSQL = new StringBuilder();
			UniqueStringCollection arrSelectFields = new UniqueStringCollection();
			foreach ( string sField in arrDataGridSelectFields )
			{
				arrSelectFields.Add(sField);
			}
			// 05/03/2011 Paul.  Always include the ID as it might be used by the Export code to filter by selected items. 
			arrSelectFields.Add("ID");
			GridColumns(sGRID_NAME, arrSelectFields, arrSkippedFields);
			// 04/20/2011 Paul.  If there are no fields in the GridView.Export, then return all fields (*). 
			if ( arrSelectFields.Count > 0 )
			{
				foreach ( string sField in arrSelectFields )
				{
					if ( sbSQL.Length > 0 )
						sbSQL.Append("     , ");
					sbSQL.AppendLine(sField);
				}
			}
			else
			{
				sbSQL.AppendLine("*");
			}
			return sbSQL.ToString();
		}

		// 01/02/2020 Paul.  We need to be able to specify a prefix. 
		public static string ExportGridColumns(string sGRID_NAME, UniqueStringCollection arrDataGridSelectFields, string sTABLE_PREFIX, StringCollection arrSkippedFields)
		{
			StringBuilder sbSQL = new StringBuilder();
			UniqueStringCollection arrSelectFields = new UniqueStringCollection();
			foreach ( string sField in arrDataGridSelectFields )
			{
				arrSelectFields.Add(sField);
			}
			// 05/03/2011 Paul.  Always include the ID as it might be used by the Export code to filter by selected items. 
			arrSelectFields.Add("ID");
			GridColumns(sGRID_NAME, arrSelectFields, arrSkippedFields);
			// 04/20/2011 Paul.  If there are no fields in the GridView.Export, then return all fields (*). 
			if ( arrSelectFields.Count > 0 )
			{
				foreach ( string sField in arrSelectFields )
				{
					if ( sbSQL.Length > 0 )
						sbSQL.Append("     , ");
					// 09/23/2015 Paul.  Special exception. 
					if ( sField == "FAVORITE_RECORD_ID" )
						sbSQL.AppendLine(sField);
					else
						sbSQL.AppendLine(sTABLE_PREFIX + "." + sField);
				}
			}
			else
			{
				sbSQL.AppendLine("*");
			}
			return sbSQL.ToString();
		}

		public static void SearchGridColumns(string sGRID_NAME, UniqueStringCollection arrSelectFields)
		{
			StringCollection arrSkippedFields = new StringCollection();
			arrSkippedFields.Add("USER_NAME"    );
			arrSkippedFields.Add("ASSIGNED_TO"  );
			arrSkippedFields.Add("CREATED_BY"   );
			arrSkippedFields.Add("MODIFIED_BY"  );
			arrSkippedFields.Add("DATE_ENTERED" );
			arrSkippedFields.Add("DATE_MODIFIED");
			arrSkippedFields.Add("TEAM_NAME"    );
			arrSkippedFields.Add("TEAM_SET_NAME");
			// 05/15/2016 Paul.  Don't need to search ASSIGNED_TO_NAME. 
			arrSkippedFields.Add("ASSIGNED_TO_NAME");
			GridColumns(sGRID_NAME, arrSelectFields, arrSkippedFields);
			// 10/03/2018 Paul.  Remove an empty field.  This can occur if Hover field is used in Search layout. 
			arrSelectFields.Remove(String.Empty);
		}

		// 04/20/2011 Paul.  Create a new method so that we can get export field. 
		public static void GridColumns(string sGRID_NAME, UniqueStringCollection arrSelectFields, StringCollection arrSkippedFields)
		{
			// 05/10/2016 Paul.  The User Primary Role is used with role-based views. 
			DataTable dt = SplendidCache.GridViewColumns(sGRID_NAME, Security.PRIMARY_ROLE_NAME);
			if ( dt != null )
			{
				// 01/18/2010 Paul.  To apply ACL Field Security, we need to know if the Module Name, which we will extract from the EditView Name. 
				string sMODULE_NAME = String.Empty;
				string[] arrGRID_NAME = sGRID_NAME.Split('.');
				if ( arrGRID_NAME.Length > 0 )
				{
					if ( arrGRID_NAME[0] == "ListView" || arrGRID_NAME[0] == "PopupView" || arrGRID_NAME[0] == "Activities" )
						sMODULE_NAME = arrGRID_NAME[0];
					// 01/18/2010 Paul.  A sub-panel should apply the access rules of the related module. 
					else if ( Sql.ToBoolean(HttpContext.Current.Application["Modules." + arrGRID_NAME[1] + ".Valid"]) )
						sMODULE_NAME = arrGRID_NAME[1];
					else
						sMODULE_NAME = arrGRID_NAME[0];
				}
				foreach(DataRow row in dt.Rows)
				{
					string sCOLUMN_TYPE = Sql.ToString (row["COLUMN_TYPE"]);
					string sDATA_FIELD  = Sql.ToString (row["DATA_FIELD" ]);
					string sDATA_FORMAT = Sql.ToString (row["DATA_FORMAT"]);
					string sMODULE_TYPE = Sql.ToString (row["MODULE_TYPE"]);
					
					// 04/20/2011 Paul.  Export requests will not exclude any fields. 
					if ( arrSkippedFields != null )
					{
						if ( arrSkippedFields.Contains(sDATA_FIELD) || sDATA_FIELD.EndsWith("_ID") || sDATA_FIELD.EndsWith("_CURRENCY") )
							continue;
					}
					
					// 01/18/2010 Paul.  A field is either visible or not.  At this time, we will not only show a field to its owner. 
					bool bIsReadable  = true;
					if ( SplendidInit.bEnableACLFieldSecurity && !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, sDATA_FIELD, Guid.Empty);
						bIsReadable  = acl.IsReadable();
					}
					
					if ( bIsReadable )
					{
						if ( String.Compare(sCOLUMN_TYPE, "TemplateColumn", true) == 0 )
						{
							if ( String.Compare(sDATA_FORMAT, "HyperLink", true) == 0 )
							{
								if ( !Sql.IsEmptyString(sDATA_FIELD) )
								{
									// 02/26/2018 Paul.  There is a special case where we have a custom field module lookup. 
									// 07/12/2018 Paul.  Use Contains instead of ends with. 
									if ( sGRID_NAME.Contains(".Export") && !Sql.IsEmptyString(sMODULE_TYPE) && sDATA_FIELD.EndsWith("_ID_C") )
									{
										string sSubQueryTable = Crm.Modules.TableName(sMODULE_TYPE);
										// 02/26/2018 Paul.  Top 1 will not work in Oracle, but this will have to be a known limitation. 
										string sSubQueryField = "(select top 1 NAME from vw" + sSubQueryTable + " where vw" + sSubQueryTable + ".ID = " + sDATA_FIELD + ") as " + sDATA_FIELD;
										if ( arrSelectFields.Contains(sDATA_FIELD) )
										{
											arrSelectFields.Remove(sDATA_FIELD);
											arrSelectFields.Add(sSubQueryField);
										}
										else
										{
											arrSelectFields.Add(sSubQueryField);
										}
									}
									else
									{
										arrSelectFields.Add(sDATA_FIELD);
									}
								}
							}
							// 05/05/2017 Paul.  Include Date, DateTime and Currency in case they were configured for export as template fields. 
							else if ( String.Compare(sDATA_FORMAT, "Date", true) == 0 || String.Compare(sDATA_FORMAT, "DateTime", true) == 0 || String.Compare(sDATA_FORMAT, "Currency", true) == 0 )
							{
								if ( !Sql.IsEmptyString(sDATA_FIELD) )
									arrSelectFields.Add(sDATA_FIELD);
							}
							// 02/11/2016 Paul.  Allow searching of hover fields. 
							else if ( String.Compare(sDATA_FORMAT, "Hover", true) == 0 )
							{
								string sURL_FIELD = Sql.ToString (row["URL_FIELD"]);
								if ( SplendidInit.bEnableACLFieldSecurity && !Sql.IsEmptyString(sURL_FIELD) )
								{
									string[] arrURL_FIELD = sURL_FIELD.Split(' ');
									for ( int i=0; i < arrURL_FIELD.Length; i++ )
									{
										if ( !arrURL_FIELD[i].Contains(".") )
										{
											Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, arrURL_FIELD[i], Guid.Empty);
											if ( acl.IsReadable() )
												arrSelectFields.Add(sDATA_FIELD);
										}
									}
								}
							}
							// 05/16/2016 Paul.  Include Tags in list of valid columns. 
							else if ( String.Compare(sDATA_FORMAT, "Tags", true) == 0 )
							{
								if ( !Sql.IsEmptyString(sDATA_FIELD) )
									arrSelectFields.Add(sDATA_FIELD);
							}
						}
						else if ( String.Compare(sCOLUMN_TYPE, "BoundColumn", true) == 0 )
						{
							// 09/23/2010 Paul.  Add the bound field. 
							if ( !Sql.IsEmptyString(sDATA_FIELD) )
								arrSelectFields.Add(sDATA_FIELD);
						}
						// 02/11/2016 Paul.  Allow searching of hidden field. 
						else if ( String.Compare(sCOLUMN_TYPE, "Hidden", true) == 0 )
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) )
								arrSelectFields.Add(sDATA_FIELD);
						}
					}
				}
			}
		}

// 11/03/2021 Paul.  ASP.Net components are not needed. 
#if !ReactOnlyUI
		public static void AppendGridColumns(string sGRID_NAME, DataGrid grd, UniqueStringCollection arrSelectFields)
		{
			AppendGridColumns(sGRID_NAME, grd, arrSelectFields, null);
		}

		// 02/08/2008 Paul.  We need to build a list of the fields used by the dynamic grid. 
		// 03/01/2014 Paul.  Add Preview button. 
		public static void AppendGridColumns(string sGRID_NAME, DataGrid grd, UniqueStringCollection arrSelectFields, CommandEventHandler Page_Command)
		{
			if ( grd == null )
			{
				SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "DataGrid is not defined for " + sGRID_NAME);
				return;
			}
			// 05/10/2016 Paul.  The User Primary Role is used with role-based views. 
			DataTable dt = SplendidCache.GridViewColumns(sGRID_NAME, Security.PRIMARY_ROLE_NAME);
			if ( dt != null )
			{
				// 01/01/2008 Paul.  Pull config flag outside the loop. 
				bool bEnableTeamManagement = Crm.Config.enable_team_management();
				// 08/28/2009 Paul.  Allow dynamic teams to be turned off. 
				bool bEnableDynamicTeams   = Crm.Config.enable_dynamic_teams();
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				bool bEnableDynamicAssignment = Crm.Config.enable_dynamic_assignment();
				// 09/16/2018 Paul.  Create a multi-tenant system. 
				if ( Crm.Config.enable_multi_tenant_teams() )
				{
					bEnableTeamManagement    = false;
					bEnableDynamicTeams      = false;
					bEnableDynamicAssignment = false;
				}
				foreach(DataRow row in dt.Rows)
				{
					int    nCOLUMN_INDEX               = Sql.ToInteger(row["COLUMN_INDEX"              ]);
					string sCOLUMN_TYPE                = Sql.ToString (row["COLUMN_TYPE"               ]);
					string sHEADER_TEXT                = Sql.ToString (row["HEADER_TEXT"               ]);
					string sSORT_EXPRESSION            = Sql.ToString (row["SORT_EXPRESSION"           ]);
					string sITEMSTYLE_WIDTH            = Sql.ToString (row["ITEMSTYLE_WIDTH"           ]);
					string sITEMSTYLE_CSSCLASS         = Sql.ToString (row["ITEMSTYLE_CSSCLASS"        ]);
					string sITEMSTYLE_HORIZONTAL_ALIGN = Sql.ToString (row["ITEMSTYLE_HORIZONTAL_ALIGN"]);
					string sITEMSTYLE_VERTICAL_ALIGN   = Sql.ToString (row["ITEMSTYLE_VERTICAL_ALIGN"  ]);
					bool   bITEMSTYLE_WRAP             = Sql.ToBoolean(row["ITEMSTYLE_WRAP"            ]);
					string sDATA_FIELD                 = Sql.ToString (row["DATA_FIELD"                ]);
					string sDATA_FORMAT                = Sql.ToString (row["DATA_FORMAT"               ]);
					string sURL_FIELD                  = Sql.ToString (row["URL_FIELD"                 ]);
					string sURL_FORMAT                 = Sql.ToString (row["URL_FORMAT"                ]);
					string sURL_TARGET                 = Sql.ToString (row["URL_TARGET"                ]);
					string sLIST_NAME                  = Sql.ToString (row["LIST_NAME"                 ]);
					// 04/28/2006 Paul.  The module is necessary in order to determine if a user has access. 
					string sURL_MODULE                 = Sql.ToString (row["URL_MODULE"                ]);
					// 05/02/2006 Paul.  The assigned user id is necessary if the user only has Owner access. 
					string sURL_ASSIGNED_FIELD         = Sql.ToString (row["URL_ASSIGNED_FIELD"        ]);
					// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
					string sMODULE_TYPE = String.Empty;
					try
					{
						sMODULE_TYPE = Sql.ToString (row["MODULE_TYPE"]);
					}
					catch(Exception ex)
					{
						// 06/16/2010 Paul.  The MODULE_TYPE is not in the view, then log the error and continue. 
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
					}
					// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
					string sPARENT_FIELD = String.Empty;
					try
					{
						sPARENT_FIELD = Sql.ToString (row["PARENT_FIELD"]);
					}
					catch(Exception ex)
					{
						// 10/09/2010 Paul.  The PARENT_FIELD is not in the view, then log the error and continue. 
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
					}

					if ( (sDATA_FIELD == "TEAM_NAME" || sDATA_FIELD == "TEAM_SET_NAME") )
					{
						// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
						if ( bEnableTeamManagement && bEnableDynamicTeams && sDATA_FORMAT != "1" && !sDATA_FORMAT.ToLower().Contains("single") )
						{
							sHEADER_TEXT = ".LBL_LIST_TEAM_SET_NAME";
							sDATA_FIELD  = "TEAM_SET_NAME";
						}
						else
						{
							sHEADER_TEXT = ".LBL_LIST_TEAM_NAME";
							sDATA_FIELD  = "TEAM_NAME";
						}
					}
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					else if ( sDATA_FIELD == "ASSIGNED_TO" || sDATA_FIELD == "ASSIGNED_TO_NAME" || sDATA_FIELD == "ASSIGNED_SET_NAME" )
					{
						// 12/17/2017 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
						// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
						if ( bEnableDynamicAssignment && !sDATA_FORMAT.ToLower().Contains("single") )
						{
							sHEADER_TEXT = ".LBL_LIST_ASSIGNED_SET_NAME";
							sDATA_FIELD  = "ASSIGNED_SET_NAME";
						}
						else if ( sDATA_FIELD == "ASSIGNED_SET_NAME" )
						{
							sHEADER_TEXT = ".LBL_LIST_ASSIGNED_USER";
							sDATA_FIELD  = "ASSIGNED_TO_NAME";
						}
					}
					// 02/08/2008 Paul.  We need to build a list of the fields used by the dynamic grid. 
					if ( arrSelectFields != null )
					{
						// 08/02/2010 Paul.  The JavaScript and Hover fields will not have a data field. 
						if ( !Sql.IsEmptyString(sDATA_FIELD) )
							arrSelectFields.Add(sDATA_FIELD);
						if ( !Sql.IsEmptyString(sSORT_EXPRESSION) )
							arrSelectFields.Add(sSORT_EXPRESSION);
						if ( !Sql.IsEmptyString(sURL_FIELD) )
						{
							// 08/02/2010 Paul.  We want to allow Terminology fields, so exclude anything with a "."
							if ( sURL_FIELD.IndexOf(' ') >= 0 )
							{
								string[] arrURL_FIELD = sURL_FIELD.Split(' ');
								foreach ( string s in arrURL_FIELD )
								{
									if ( !s.Contains(".") && !Sql.IsEmptyString(s) )
										arrSelectFields.Add(s);
								}
							}
							else if ( !sURL_FIELD.Contains(".") )
								arrSelectFields.Add(sURL_FIELD);
							if ( !Sql.IsEmptyString(sURL_ASSIGNED_FIELD) )
								arrSelectFields.Add(sURL_ASSIGNED_FIELD);
						}
						// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
						if ( !Sql.IsEmptyString(sPARENT_FIELD) )
							arrSelectFields.Add(sPARENT_FIELD);
					}
					
					HorizontalAlign eHorizontalAlign = HorizontalAlign.NotSet;
					switch ( sITEMSTYLE_HORIZONTAL_ALIGN.ToLower() )
					{
						case "left" :  eHorizontalAlign = HorizontalAlign.Left ;  break;
						case "right":  eHorizontalAlign = HorizontalAlign.Right;  break;
					}
					VerticalAlign eVerticalAlign = VerticalAlign.NotSet;
					switch ( sITEMSTYLE_VERTICAL_ALIGN.ToLower() )
					{
						case "top"   :  eVerticalAlign = VerticalAlign.Top   ;  break;
						case "middle":  eVerticalAlign = VerticalAlign.Middle;  break;
						case "bottom":  eVerticalAlign = VerticalAlign.Bottom;  break;
					}
					// 11/28/2005 Paul.  Wrap defaults to true. 
					if ( row["ITEMSTYLE_WRAP"] == DBNull.Value )
						bITEMSTYLE_WRAP = true;

					// 01/18/2010 Paul.  To apply ACL Field Security, we need to know if the Module Name, which we will extract from the EditView Name. 
					string sMODULE_NAME = String.Empty;
					string[] arrGRID_NAME = sGRID_NAME.Split('.');
					if ( arrGRID_NAME.Length > 0 )
					{
						if ( arrGRID_NAME[0] == "ListView" || arrGRID_NAME[0] == "PopupView" || arrGRID_NAME[0] == "Activities" )
							sMODULE_NAME = arrGRID_NAME[0];
						// 01/18/2010 Paul.  A sub-panel should apply the access rules of the related module. 
						else if ( Sql.ToBoolean(HttpContext.Current.Application["Modules." + arrGRID_NAME[1] + ".Valid"]) )
							sMODULE_NAME = arrGRID_NAME[1];
						else
							sMODULE_NAME = arrGRID_NAME[0];
					}
					// 01/18/2010 Paul.  A field is either visible or not.  At this time, we will not only show a field to its owner. 
					bool bIsReadable  = true;
					// 08/02/2010 Paul.  The JavaScript and Hover fields will not have a data field. 
					if ( SplendidInit.bEnableACLFieldSecurity && !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, sDATA_FIELD, Guid.Empty);
						bIsReadable  = acl.IsReadable();
					}

					DataGridColumn col = null;
					// 02/03/2006 Paul.  Date and Currency must always be handled by CreateItemTemplateLiteral. 
					// Otherwise, the date or time will not get properly translated to the correct timezone. 
					// This bug was reported by David Williams. 
					// 05/20/2009 Paul.  We need a way to preserve CRLF in description fields. 
					if (     String.Compare(sCOLUMN_TYPE, "BoundColumn", true) == 0 
					  && (   String.Compare(sDATA_FORMAT, "Date"       , true) == 0 
					      || String.Compare(sDATA_FORMAT, "DateTime"   , true) == 0 
					      || String.Compare(sDATA_FORMAT, "Currency"   , true) == 0
					      || String.Compare(sDATA_FORMAT, "Image"      , true) == 0
					      || String.Compare(sDATA_FORMAT, "MultiLine"  , true) == 0
					     )
					   )
					{
						sCOLUMN_TYPE = "TemplateColumn";
					}
					// 03/14/2014 Paul.  A hidden field does not render.  It is primarily used to add a field to the SQL select list for Business Rules management. 
					// 08/20/2016 Paul.  The hidden field is a DATA_FORMAT, not a COLUMN_TYPE, but keep COLUMN_TYPE just in case anyone used it. 
					if ( String.Compare(sCOLUMN_TYPE, "Hidden", true) == 0 || String.Compare(sDATA_FORMAT, "Hidden", true) == 0 )
					{
						continue;
					}
					if ( String.Compare(sCOLUMN_TYPE, "BoundColumn", true) == 0 )
					{
						if ( Sql.IsEmptyString(sLIST_NAME) )
						{
							// GRID_NAME, COLUMN_ORDER, COLUMN_TYPE, HEADER_TEXT, DATA_FIELD, SORT_EXPRESSION, ITEMSTYLE_WIDTH
							// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
							TemplateColumn bnd = new TemplateColumn();
							bnd.HeaderText                  = sHEADER_TEXT       ;
							//bnd.DataField                   = sDATA_FIELD        ;
							bnd.SortExpression              = sSORT_EXPRESSION   ;
							bnd.ItemStyle.Width             = new Unit(sITEMSTYLE_WIDTH);
							bnd.ItemStyle.CssClass          = sITEMSTYLE_CSSCLASS;
							bnd.ItemStyle.HorizontalAlign   = eHorizontalAlign   ;
							bnd.ItemStyle.VerticalAlign     = eVerticalAlign     ;
							bnd.ItemStyle.Wrap              = bITEMSTYLE_WRAP    ;
							// 04/13/2007 Paul.  Align the headers to match the data. 
							bnd.HeaderStyle.HorizontalAlign = eHorizontalAlign   ;
							col = bnd;
							// 01/18/2010 Paul.  Apply ACL Field Security. 
							col.Visible = bIsReadable;
							// 10/23/2012 Kevin.  Allow me to pass data format for gridview bound columns. 
							// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
							//if ( !Sql.IsEmptyString(sDATA_FORMAT) )
							//{
							//	bnd.DataFormatString = sDATA_FORMAT;
							//}
							bnd.ItemTemplate = new CreateItemTemplateLiteral(sDATA_FIELD, sDATA_FORMAT, sMODULE_TYPE);
						}
						else
						{
							// GRID_NAME, COLUMN_ORDER, COLUMN_TYPE, HEADER_TEXT, DATA_FIELD, SORT_EXPRESSION, ITEMSTYLE_WIDTH
							TemplateColumn tpl = new TemplateColumn();
							tpl.HeaderText                  = sHEADER_TEXT       ;
							tpl.SortExpression              = sSORT_EXPRESSION   ;
							tpl.ItemStyle.Width             = new Unit(sITEMSTYLE_WIDTH);
							tpl.ItemStyle.CssClass          = sITEMSTYLE_CSSCLASS;
							tpl.ItemStyle.HorizontalAlign   = eHorizontalAlign   ;
							tpl.ItemStyle.VerticalAlign     = eVerticalAlign     ;
							tpl.ItemStyle.Wrap              = bITEMSTYLE_WRAP    ;
							// 04/13/2007 Paul.  Align the headers to match the data. 
							tpl.HeaderStyle.HorizontalAlign = eHorizontalAlign   ;
							// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
							tpl.ItemTemplate = new CreateItemTemplateLiteralList(sDATA_FIELD, sLIST_NAME, sPARENT_FIELD);
							col = tpl;
							// 01/18/2010 Paul.  Apply ACL Field Security. 
							col.Visible = bIsReadable;
						}
					}
					else if ( String.Compare(sCOLUMN_TYPE, "TemplateColumn", true) == 0 )
					{
						// GRID_NAME, COLUMN_ORDER, COLUMN_TYPE, HEADER_TEXT, DATA_FIELD, SORT_EXPRESSION, ITEMSTYLE_WIDTH
						TemplateColumn tpl = new TemplateColumn();
						tpl.HeaderText                  = sHEADER_TEXT       ;
						tpl.SortExpression              = sSORT_EXPRESSION   ;
						tpl.ItemStyle.Width             = new Unit(sITEMSTYLE_WIDTH);
						tpl.ItemStyle.CssClass          = sITEMSTYLE_CSSCLASS;
						tpl.ItemStyle.HorizontalAlign   = eHorizontalAlign   ;
						tpl.ItemStyle.VerticalAlign     = eVerticalAlign     ;
						tpl.ItemStyle.Wrap              = bITEMSTYLE_WRAP    ;
						// 04/13/2007 Paul.  Align the headers to match the data. 
						tpl.HeaderStyle.HorizontalAlign = eHorizontalAlign   ;
						if ( String.Compare(sDATA_FORMAT, "JavaScript", true) == 0 )
						{
							// 08/02/2010 Paul.  In our application of Field Level Security, we will hide fields by replacing with "."
							if ( SplendidInit.bEnableACLFieldSecurity && !Sql.IsEmptyString(sURL_FIELD) )
							{
								string[] arrURL_FIELD = sURL_FIELD.Split(' ');
								for ( int i=0; i < arrURL_FIELD.Length; i++ )
								{
									Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, sDATA_FIELD, Guid.Empty);
									if ( !acl.IsReadable() )
										arrURL_FIELD[i] = ".";
								}
								sURL_FIELD = String.Join(" ", arrURL_FIELD);
							}
							tpl.ItemTemplate = new CreateItemTemplateJavaScript(sDATA_FIELD, sURL_FIELD, sURL_FORMAT, sURL_TARGET);
						}
						// 02/26/2014 Paul.  Add Preview button. 
						else if ( String.Compare(sDATA_FORMAT, "JavaImage", true) == 0 )
						{
							if ( SplendidInit.bEnableACLFieldSecurity && !Sql.IsEmptyString(sURL_FIELD) )
							{
								string[] arrURL_FIELD = sURL_FIELD.Split(' ');
								for ( int i=0; i < arrURL_FIELD.Length; i++ )
								{
									Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, sDATA_FIELD, Guid.Empty);
									if ( !acl.IsReadable() )
										arrURL_FIELD[i] = ".";
								}
								sURL_FIELD = String.Join(" ", arrURL_FIELD);
							}
							tpl.ItemTemplate = new CreateItemTemplateJavaScriptImage(sURL_FIELD, sURL_FORMAT, sURL_TARGET);
						}
						// 03/01/2014 Paul.  Add Preview button. 
						else if ( String.Compare(sDATA_FORMAT, "ImageButton", true) == 0 )
						{
							// 03/01/2014 Paul.  sURL_FIELD is an internal value, so there is no need to apply ACL rules. 
							tpl.ItemTemplate = new CreateItemTemplateImageButton(sURL_FIELD, sURL_FORMAT, sURL_TARGET, sITEMSTYLE_CSSCLASS, Page_Command);
							// 06/07/2015 Paul.  Only show the preview button on the Seven theme. 
							if ( sURL_FORMAT == "Preview" )
								bIsReadable &= SplendidDynamic.StackedLayout(grd.Page.Theme);
						}
						else if ( String.Compare(sDATA_FORMAT, "Hover", true) == 0 )
						{
							string sIMAGE_SKIN = sURL_TARGET;
							if ( Sql.IsEmptyString(sIMAGE_SKIN) )
								sIMAGE_SKIN = "info_inline";
							// 08/02/2010 Paul.  In our application of Field Level Security, we will hide fields by replacing with "."
							if ( SplendidInit.bEnableACLFieldSecurity && !Sql.IsEmptyString(sURL_FIELD) )
							{
								string[] arrURL_FIELD = sURL_FIELD.Split(' ');
								for ( int i=0; i < arrURL_FIELD.Length; i++ )
								{
									// 02/11/2016 Paul.  Exclude terminology. 
									if ( !arrURL_FIELD[i].Contains(".") )
									{
										// 02/11/2016 Paul.  Fix cut-and-paste error.  We were testing sDATA_FIELD and not arrURL_FIELD[i]. 
										Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, arrURL_FIELD[i], Guid.Empty);
										if ( !acl.IsReadable() )
											arrURL_FIELD[i] = ".";
									}
								}
								sURL_FIELD = String.Join(" ", arrURL_FIELD);
							}
							tpl.ItemTemplate = new CreateItemTemplateHover(sDATA_FIELD, sURL_FIELD, sURL_FORMAT, sIMAGE_SKIN);
						}
						else if ( String.Compare(sDATA_FORMAT, "HyperLink", true) == 0 )
						{
							// 07/26/2007 Paul.  PopupViews have special requirements.  They need an OnClick action that takes more than one parameter. 
							if ( sURL_FIELD.IndexOf(' ') >= 0 )
								tpl.ItemTemplate = new CreateItemTemplateHyperLinkOnClick(sDATA_FIELD, sURL_FIELD, sURL_FORMAT, sURL_TARGET, sITEMSTYLE_CSSCLASS, sURL_MODULE, sURL_ASSIGNED_FIELD, sMODULE_TYPE);
							else
								tpl.ItemTemplate = new CreateItemTemplateHyperLink(sDATA_FIELD, sURL_FIELD, sURL_FORMAT, sURL_TARGET, sITEMSTYLE_CSSCLASS, sURL_MODULE, sURL_ASSIGNED_FIELD, sMODULE_TYPE);
						}
						else if ( String.Compare(sDATA_FORMAT, "Image", true) == 0 )
						{
							// 08/15/2014 Paul.  Show the URL_FORMAT for Images so that we can point to the EmailImages URL. 
							tpl.ItemTemplate = new CreateItemTemplateImage(sDATA_FIELD, sURL_FORMAT, sITEMSTYLE_CSSCLASS);
						}
						else
						{
							tpl.ItemStyle.CssClass = sITEMSTYLE_CSSCLASS;
							tpl.ItemTemplate = new CreateItemTemplateLiteral(sDATA_FIELD, sDATA_FORMAT, sMODULE_TYPE);
						}
						col = tpl;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						col.Visible = bIsReadable;
					}
					else if ( String.Compare(sCOLUMN_TYPE, "HyperLinkColumn", true) == 0 )
					{
						// GRID_NAME, COLUMN_ORDER, COLUMN_TYPE, HEADER_TEXT, DATA_FIELD, SORT_EXPRESSION, ITEMSTYLE_WIDTH, ITEMSTYLE-CSSCLASS, URL_FIELD, URL_FORMAT
						HyperLinkColumn lnk = new HyperLinkColumn();
						lnk.HeaderText                  = sHEADER_TEXT       ;
						lnk.DataTextField               = sDATA_FIELD        ;
						lnk.SortExpression              = sSORT_EXPRESSION   ;
						lnk.DataNavigateUrlField        = sURL_FIELD         ;
						lnk.DataNavigateUrlFormatString = sURL_FORMAT        ;
						lnk.Target                      = sURL_TARGET        ;
						lnk.ItemStyle.Width             = new Unit(sITEMSTYLE_WIDTH);
						lnk.ItemStyle.CssClass          = sITEMSTYLE_CSSCLASS;
						lnk.ItemStyle.HorizontalAlign   = eHorizontalAlign   ;
						lnk.ItemStyle.VerticalAlign     = eVerticalAlign     ;
						lnk.ItemStyle.Wrap              = bITEMSTYLE_WRAP    ;
						// 04/13/2007 Paul.  Align the headers to match the data. 
						lnk.HeaderStyle.HorizontalAlign = eHorizontalAlign   ;
						col = lnk;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						col.Visible = bIsReadable;
					}
					if ( col != null )
					{
						// 11/25/2006 Paul.  If Team Management has been disabled, then hide the column. 
						// Keep the column, but hide it so that the remaining column positions will still be valid. 
						// 10/27/2007 Paul.  The data field was changed to TEAM_NAME on 11/25/2006. It should have been changed here as well. 
						// 08/24/2009 Paul.  Add support for dynamic teams. 
						if ( (sDATA_FIELD == "TEAM_NAME" || sDATA_FIELD == "TEAM_SET_NAME") && !bEnableTeamManagement )
						{
							col.Visible = false;
						}
						// 11/28/2005 Paul.  In case the column specified is too high, just append column. 
						if ( nCOLUMN_INDEX >= grd.Columns.Count )
							grd.Columns.Add(col);
						else
							grd.Columns.AddAt(nCOLUMN_INDEX, col);
					}
				}
			}
			// 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
			if ( dt.Rows.Count > 0 )
			{
				try
				{
					string sFORM_SCRIPT = Sql.ToString(dt.Rows[0]["SCRIPT"]);
					if ( !Sql.IsEmptyString(sFORM_SCRIPT) )
					{
						// 09/20/2012 Paul.  The base ID is not the ID of the parent, but the ID of the TemplateControl. 
						sFORM_SCRIPT = sFORM_SCRIPT.Replace("SPLENDID_GRIDVIEW_LAYOUT_ID", grd.TemplateControl.ClientID);
						ScriptManager.RegisterStartupScript(grd, typeof(System.String), sGRID_NAME.Replace(".", "_") + "_SCRIPT", sFORM_SCRIPT, true);
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
				}
			}
		}

		// 04/11/2011 Paul.  Add the layout flag so that we can provide a preview mode. 
		public static void AppendGridColumns(DataView dvFields, HtmlTable tbl, IDataReader rdr, L10N L10n, TimeZone T10n, CommandEventHandler Page_Command, bool bLayoutMode)
		{
			if ( tbl == null )
			{
				SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "HtmlTable is not defined");
				return;
			}
			// 01/07/2006 Paul.  Show table borders in layout mode. This will help distinguish blank lines from wrapped lines. 
			if ( bLayoutMode )
				tbl.Border = 1;

			HtmlTableRow trAction = new HtmlTableRow();
			HtmlTableRow trHeader = new HtmlTableRow();
			HtmlTableRow trField  = new HtmlTableRow();
			tbl.Rows.Insert(0, trAction);
			tbl.Rows.Insert(1, trHeader);
			tbl.Rows.Insert(2, trField );
			trAction.Attributes.Add("class", "listViewThS1");
			trHeader.Attributes.Add("class", "listViewThS1");
			trField .Attributes.Add("class", "oddListRowS1");
			trAction.Visible = bLayoutMode;

			HttpSessionState Session = HttpContext.Current.Session;
			bool bSupportsDraggable = Sql.ToBoolean(Session["SupportsDraggable"]);
			foreach(DataRowView row in dvFields)
			{
				Guid   gID                         = Sql.ToGuid   (row["ID"                        ]);
				int    nCOLUMN_INDEX               = Sql.ToInteger(row["COLUMN_INDEX"              ]);
				string sCOLUMN_TYPE                = Sql.ToString (row["COLUMN_TYPE"               ]);
				string sHEADER_TEXT                = Sql.ToString (row["HEADER_TEXT"               ]);
				string sSORT_EXPRESSION            = Sql.ToString (row["SORT_EXPRESSION"           ]);
				string sITEMSTYLE_WIDTH            = Sql.ToString (row["ITEMSTYLE_WIDTH"           ]);
				string sITEMSTYLE_CSSCLASS         = Sql.ToString (row["ITEMSTYLE_CSSCLASS"        ]);
				string sITEMSTYLE_HORIZONTAL_ALIGN = Sql.ToString (row["ITEMSTYLE_HORIZONTAL_ALIGN"]);
				string sITEMSTYLE_VERTICAL_ALIGN   = Sql.ToString (row["ITEMSTYLE_VERTICAL_ALIGN"  ]);
				bool   bITEMSTYLE_WRAP             = Sql.ToBoolean(row["ITEMSTYLE_WRAP"            ]);
				string sDATA_FIELD                 = Sql.ToString (row["DATA_FIELD"                ]);
				string sDATA_FORMAT                = Sql.ToString (row["DATA_FORMAT"               ]);
				string sURL_FIELD                  = Sql.ToString (row["URL_FIELD"                 ]);
				string sURL_FORMAT                 = Sql.ToString (row["URL_FORMAT"                ]);
				string sURL_TARGET                 = Sql.ToString (row["URL_TARGET"                ]);
				string sLIST_NAME                  = Sql.ToString (row["LIST_NAME"                 ]);
				
				HtmlTableCell tdAction = new HtmlTableCell();
				trAction.Cells.Add(tdAction);
				tdAction.NoWrap = true;

				Literal litIndex = new Literal();
				tdAction.Controls.Add(litIndex);
				litIndex.Text = " " + nCOLUMN_INDEX.ToString() + " ";

				// 05/18/2013 Paul.  Add drag handle. 
				if ( bSupportsDraggable )
				{
					Image imgDragIcon = new Image();
					imgDragIcon.SkinID = "draghandle_horz";
					imgDragIcon.Attributes.Add("draggable"  , "true");
					imgDragIcon.Attributes.Add("ondragstart", "event.dataTransfer.setData('Text', '" + nCOLUMN_INDEX.ToString() + "');");
					tdAction.Controls.Add(imgDragIcon);
					// 08/08/2013 Paul.  IE does not support preventDefault. 
					// http://stackoverflow.com/questions/1000597/event-preventdefault-function-not-working-in-ie
					tdAction.Attributes.Add("ondragover", "LayoutDragOver(event, '" + nCOLUMN_INDEX.ToString() + "')");
					tdAction.Attributes.Add("ondrop"    , "LayoutDropIndex(event, '" + nCOLUMN_INDEX.ToString() + "')");
				}
				else
				{
					ImageButton btnMoveUp   = CreateLayoutImageButtonSkin(gID, "Layout.MoveUp"  , nCOLUMN_INDEX, L10n.Term(".LNK_LEFT"  ), "leftarrow_inline" , Page_Command);
					ImageButton btnMoveDown = CreateLayoutImageButtonSkin(gID, "Layout.MoveDown", nCOLUMN_INDEX, L10n.Term(".LNK_RIGHT" ), "rightarrow_inline", Page_Command);
					tdAction.Controls.Add(btnMoveUp  );
					tdAction.Controls.Add(btnMoveDown);
				}
				ImageButton btnInsert   = CreateLayoutImageButtonSkin(gID, "Layout.Insert"  , nCOLUMN_INDEX, L10n.Term(".LNK_INS"   ), "plus_inline"      , Page_Command);
				ImageButton btnEdit     = CreateLayoutImageButtonSkin(gID, "Layout.Edit"    , nCOLUMN_INDEX, L10n.Term(".LNK_EDIT"  ), "edit_inline"      , Page_Command);
				ImageButton btnDelete   = CreateLayoutImageButtonSkin(gID, "Layout.Delete"  , nCOLUMN_INDEX, L10n.Term(".LNK_DELETE"), "delete_inline"    , Page_Command);
				tdAction.Controls.Add(btnInsert  );
				tdAction.Controls.Add(btnEdit    );
				tdAction.Controls.Add(btnDelete  );
				
				HtmlTableCell tdHeader = new HtmlTableCell();
				trHeader.Cells.Add(tdHeader);
				tdHeader.NoWrap = true;
				
				HtmlTableCell tdField = new HtmlTableCell();
				trField.Cells.Add(tdField);
				tdField.NoWrap = true;

				Literal litHeader = new Literal();
				tdHeader.Controls.Add(litHeader);
				if ( bLayoutMode )
					litHeader.Text = sHEADER_TEXT;
				else
					litHeader.Text = L10n.Term(sHEADER_TEXT);

				Literal litField = new Literal();
				tdField.Controls.Add(litField);
				litField.Text = sDATA_FIELD;
				litField.Visible = bLayoutMode;
			}
		}

		public static void AppendButtons(string sVIEW_NAME, Guid gASSIGNED_USER_ID, Control ctl, bool bIsMobile, DataRow rdr, L10N L10n, CommandEventHandler Page_Command)
		{
			AppendButtons(sVIEW_NAME, gASSIGNED_USER_ID, ctl, null, String.Empty, bIsMobile, rdr, L10n, Page_Command);
		}

		// 05/24/2015 Paul.  Seven theme has a hover popdown. 
		public static int AppendButtons(string sVIEW_NAME, Guid gASSIGNED_USER_ID, Control ctl, Control ctlHover, string sButtonStyle, bool bIsMobile, DataRow rdr, L10N L10n, CommandEventHandler Page_Command)
		{
			// 06/03/2015 Paul.  The button count is used by SubPanelButtons in the Seven theme. 
			int nButtonCount = 0;
			if ( ctl == null )
			{
				SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "AppendButtons ctl is not defined");
				return nButtonCount;
			}
			//ctl.Controls.Clear();

			Hashtable hashIDs = new Hashtable();
			// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
			// 06/05/2015 Paul.  ctl.Page is not available when creating MassUpdate buttons on DataGrid. 
			bool bIsPostBack = false;
			if ( ctl.Page != null )
				bIsPostBack = ctl.Page.IsPostBack;
			bool bNotPostBack = false;
			if ( ctl.TemplateControl is SplendidControl )
			{
				bNotPostBack = (ctl.TemplateControl as SplendidControl).NotPostBack;
				bIsPostBack = ctl.Page.IsPostBack && !bNotPostBack;
			}
			bool bShowUnassigned = Crm.Config.show_unassigned();
			DataTable dt = SplendidCache.DynamicButtons(sVIEW_NAME);
			if ( dt != null )
			{
				nButtonCount = dt.Rows.Count;
				for ( int iButton = 0; iButton < dt.Rows.Count; iButton++ )
				{
					DataRow row = dt.Rows[iButton];
					Guid   gID                 = Sql.ToGuid   (row["ID"                ]);
					int    nCONTROL_INDEX      = Sql.ToInteger(row["CONTROL_INDEX"     ]);
					string sCONTROL_TYPE       = Sql.ToString (row["CONTROL_TYPE"      ]);
					string sMODULE_NAME        = Sql.ToString (row["MODULE_NAME"       ]);
					string sMODULE_ACCESS_TYPE = Sql.ToString (row["MODULE_ACCESS_TYPE"]);
					string sTARGET_NAME        = Sql.ToString (row["TARGET_NAME"       ]);
					string sTARGET_ACCESS_TYPE = Sql.ToString (row["TARGET_ACCESS_TYPE"]);
					bool   bMOBILE_ONLY        = Sql.ToBoolean(row["MOBILE_ONLY"       ]);
					bool   bADMIN_ONLY         = Sql.ToBoolean(row["ADMIN_ONLY"        ]);
					string sCONTROL_TEXT       = Sql.ToString (row["CONTROL_TEXT"      ]);
					string sCONTROL_TOOLTIP    = Sql.ToString (row["CONTROL_TOOLTIP"   ]);
					string sCONTROL_ACCESSKEY  = Sql.ToString (row["CONTROL_ACCESSKEY" ]);
					string sCONTROL_CSSCLASS   = Sql.ToString (row["CONTROL_CSSCLASS"  ]);
					string sTEXT_FIELD         = Sql.ToString (row["TEXT_FIELD"        ]);
					string sARGUMENT_FIELD     = Sql.ToString (row["ARGUMENT_FIELD"    ]);
					string sCOMMAND_NAME       = Sql.ToString (row["COMMAND_NAME"      ]);
					string sURL_FORMAT         = Sql.ToString (row["URL_FORMAT"        ]);
					string sURL_TARGET         = Sql.ToString (row["URL_TARGET"        ]);
					string sONCLICK_SCRIPT     = Sql.ToString (row["ONCLICK_SCRIPT"    ]);
					// 07/28/2010 Paul.  We need a flag to exclude a button from a mobile device. 
					bool   bEXCLUDE_MOBILE     = false;
					try
					{
						bEXCLUDE_MOBILE = Sql.ToBoolean(row["EXCLUDE_MOBILE"]);
					}
					catch
					{
					}
					// 03/14/2014 Paul.  Allow hidden buttons to be created. 
					bool   bHIDDEN             = false;
					try
					{
						bHIDDEN = Sql.ToBoolean(row["HIDDEN"]);
					}
					catch
					{
					}
					// 08/16/2017 Paul.  Add ability to apply a business rule to a button. 
					string sBUSINESS_RULE      = String.Empty;
					try
					{
						sBUSINESS_RULE = Sql.ToString (row["BUSINESS_RULE"     ]);
					}
					catch
					{
					}
					// 05/25/2015 Paul.  Reuse as much existing code as possible by allowing ctlHover to be NULL. 
					if ( ctlHover != null )
					{
						if ( (iButton == 1 && (sButtonStyle == "ModuleHeader" || sButtonStyle == "ListHeader" || sButtonStyle == "MassUpdateHeader")) || (iButton == 0 && sButtonStyle == "DataGrid") )
						{
							ImageButton btnMore = new ImageButton();
							btnMore.SkinID        = sButtonStyle + "MoreButton";
							btnMore.CssClass      = sButtonStyle + "MoreButton";
							btnMore.OnClientClick = "void(0); return false;";
							btnMore.Attributes.Add("style", "vertical-align: top;");
							ctl.Controls.Add(btnMore);
							ctl = ctlHover;
						}
						// 06/06/2015 Paul.  Change standard MassUpdate command to a command to toggle visibility. 
						if ( sButtonStyle == "DataGrid" && sCOMMAND_NAME == "MassUpdate" )
						{
							sCONTROL_TEXT       = L10n.Term(".LBL_MASS_UPDATE_TITLE");
							sCONTROL_TOOLTIP    = L10n.Term(".LBL_MASS_UPDATE_TITLE");
							sCOMMAND_NAME       = "ToggleMassUpdate";
							sONCLICK_SCRIPT     = String.Empty;
							sMODULE_ACCESS_TYPE = null;
							// 05/07/2017 Paul.  Don't display MassUpdate toggle if it is disabled for the module. 
							string sMODULE = sVIEW_NAME.Split('.')[0];
							if ( !Sql.IsEmptyString(sMODULE) && !(!bIsMobile && SplendidCRM.Crm.Modules.MassUpdate(sMODULE)) )
								bHIDDEN = true;
						}
						if ( iButton == 0 && sButtonStyle == "ListHeader" && sCOMMAND_NAME.EndsWith("Create") )
						{
							sCONTROL_TEXT = "+";
						}
					}

					// 09/01/2008 Paul.  Give each button an ID to simplify validation. 
					// Attempt to name the control after the command name.  If no command name, then use the control text. 
					string sCONTROL_ID = String.Empty;
					if ( !Sql.IsEmptyString(sCOMMAND_NAME) )
					{
						sCONTROL_ID = sCOMMAND_NAME;
					}
					else if ( !Sql.IsEmptyString(sCONTROL_TEXT) )
					{
						sCONTROL_ID = sCONTROL_TEXT;
						if ( sCONTROL_TEXT.IndexOf('.') >= 0 )
						{
							sCONTROL_ID = sCONTROL_TEXT.Split('.')[1];
							sCONTROL_ID = sCONTROL_ID.Replace("LBL_", "");
							sCONTROL_ID = sCONTROL_ID.Replace("_BUTTON_LABEL", "");
						}
					}
					if ( !Sql.IsEmptyString(sCONTROL_ID) )
					{
						// 09/01/2008 Paul.  Cleanup the ID. 
						sCONTROL_ID = sCONTROL_ID.Trim();
						sCONTROL_ID = sCONTROL_ID.Replace(' ', '_');
						sCONTROL_ID = sCONTROL_ID.Replace('.', '_');
						sCONTROL_ID = "btn" + sCONTROL_ID.ToUpper();
						// 12/16/2008 Paul.  Add to hash after cleaning the ID. 
						if ( hashIDs.Contains(sCONTROL_ID) )
							sCONTROL_ID = sVIEW_NAME.Replace('.', '_') + "_" + nCONTROL_INDEX.ToString();
						if ( !hashIDs.Contains(sCONTROL_ID) )
							hashIDs.Add(sCONTROL_ID, null);
						else
							sCONTROL_ID = String.Empty;  // If ID still exists, then don't set the ID. 
					}

					// 03/21/2008 Paul.  We need to use a view to search for the rows for the ColumnName. 
					// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
					//DataView vwSchema = null;
					//if ( rdr != null )
					//	vwSchema = new DataView(rdr.GetSchemaTable());

					string[] arrTEXT_FIELD = sTEXT_FIELD.Split(' ');
					object[] objTEXT_FIELD = new object[arrTEXT_FIELD.Length];
					for ( int i=0 ; i < arrTEXT_FIELD.Length; i++ )
					{
						if ( !Sql.IsEmptyString(arrTEXT_FIELD[i]) )
						{
							objTEXT_FIELD[i] = String.Empty;
							if ( rdr != null ) // && vwSchema != null
							{
								//vwSchema.RowFilter = "ColumnName = '" + Sql.EscapeSQL(arrTEXT_FIELD[i]) + "'";
								//if ( vwSchema.Count > 0 )
								// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
								if ( rdr.Table.Columns.Contains(arrTEXT_FIELD[i]) )
									objTEXT_FIELD[i] = Sql.ToString(rdr[arrTEXT_FIELD[i]]);
							}
							// 05/24/2024 Paul.  Allow security properties to be included. 
							if ( arrTEXT_FIELD[i].Contains(".") )
							{
								string sFieldName = arrTEXT_FIELD[i].ToLower();
								if      ( sFieldName == "security.user_id"           ) objTEXT_FIELD[i] = Security.USER_ID          ;
								else if ( sFieldName == "security.user_name"         ) objTEXT_FIELD[i] = Security.USER_NAME        ;
								else if ( sFieldName == "security.team_id"           ) objTEXT_FIELD[i] = Security.TEAM_ID          ;
								else if ( sFieldName == "security.team_name"         ) objTEXT_FIELD[i] = Security.TEAM_NAME        ;
								else if ( sFieldName == "security.primary_role_id"   ) objTEXT_FIELD[i] = Security.PRIMARY_ROLE_ID  ;
								else if ( sFieldName == "security.primary_role_name" ) objTEXT_FIELD[i] = Security.PRIMARY_ROLE_NAME;
							}
						}
					}
					// 11/08/2020 Paul.  An Admin Only control should not be added as it would allow the visible/hidden flag to ignore the admin only rule. 
					// This is happening in DetailView with the Archive.MoveData command. 
					bool bVisible = (bADMIN_ONLY && Security.IS_ADMIN || !bADMIN_ONLY);
					if ( String.Compare(sCONTROL_TYPE, "Button", true) == 0 )
					{
						Button btn = new Button();
						// 11/08/2020 Paul.  An Admin Only control should not be added as it would allow the visible/hidden flag to ignore the admin only rule. 
						if ( bVisible )
							ctl.Controls.Add(btn);
						if ( !Sql.IsEmptyString(sCONTROL_ID) )
							btn.ID = sCONTROL_ID;
						// 01/05/2016 Paul.  Overload the URL_FORMAT field to set the command argument. 
						if ( !Sql.IsEmptyString(sURL_FORMAT) )
						{
							btn.CommandArgument = sURL_FORMAT;
						}
						if ( !Sql.IsEmptyString(sARGUMENT_FIELD) )
						{
							if ( rdr != null ) // && vwSchema != null )
							{
								//vwSchema.RowFilter = "ColumnName = '" + Sql.EscapeSQL(sARGUMENT_FIELD) + "'";
								//if ( vwSchema.Count > 0 )
								if ( rdr.Table.Columns.Contains(sARGUMENT_FIELD) )
									btn.CommandArgument = Sql.ToString(rdr[sARGUMENT_FIELD]);
							}
						}

						btn.Text            = "  " + L10n.Term(sCONTROL_TEXT) + "  ";
						btn.CssClass        = sCONTROL_CSSCLASS;
						// 05/25/2015 Paul.  New style for Seven theme buttons. 
						if ( ctlHover != null )
						{
							btn.CssClass = (iButton == 0 ? sButtonStyle + "FirstButton" : sButtonStyle + "OtherButton");
						}
						btn.Command        += Page_Command;
						btn.CommandName     = sCOMMAND_NAME;
						btn.OnClientClick   = sONCLICK_SCRIPT;
						// 11/21/2008 Paul.  On post back, we need to re-create the buttons, but don't change the visiblity flag. 
						// The problem is that we don't have the record at this early stage, so we cannot properly evaluate gASSIGNED_USER_ID. 
						// This is not an issue because .NET will restore the previous visibility state on post back. 
						if ( !bIsPostBack )
						{
							// 07/28/2010 Paul.  We need a flag to exclude a button from a mobile device. 
							// 03/14/2014 Paul.  Allow hidden buttons to be created. 
							btn.Visible         = (!bEXCLUDE_MOBILE || !bIsMobile) && (bMOBILE_ONLY && bIsMobile || !bMOBILE_ONLY) && (bADMIN_ONLY && Security.IS_ADMIN || !bADMIN_ONLY) && !bHIDDEN;
							if ( btn.Visible && !Sql.IsEmptyString(sMODULE_NAME) && !Sql.IsEmptyString(sMODULE_ACCESS_TYPE) )
							{
								int nACLACCESS = SplendidCRM.Security.GetUserAccess(sMODULE_NAME, sMODULE_ACCESS_TYPE);
								// 08/11/2008 John.  Fix owner access rights. 
								// 10/27/2008 Brian.  Only show button if show_unassigned is enabled.
								// 11/21/2008 Paul.  We need to make sure that an owner can create a new record. 
								btn.Visible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((Security.USER_ID == gASSIGNED_USER_ID) || (!bIsPostBack && rdr == null) || (rdr != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
								if ( btn.Visible && !Sql.IsEmptyString(sTARGET_NAME) && !Sql.IsEmptyString(sTARGET_ACCESS_TYPE) )
								{
									// 08/11/2008 John.  Fix owner access rights.
									nACLACCESS = SplendidCRM.Security.GetUserAccess(sTARGET_NAME, sTARGET_ACCESS_TYPE);
									// 11/21/2008 Paul.  We need to make sure that an owner can create a new record. 
									btn.Visible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((Security.USER_ID == gASSIGNED_USER_ID) || (!bIsPostBack && rdr == null) || (rdr != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
								}
							}
						}
						if ( !Sql.IsEmptyString(sCONTROL_ACCESSKEY) )
						{
							btn.AccessKey = L10n.AccessKey(sCONTROL_ACCESSKEY);
						}
						if ( !Sql.IsEmptyString(sCONTROL_TOOLTIP) )
						{
							btn.ToolTip = L10n.Term (sCONTROL_TOOLTIP);
							if ( btn.ToolTip.Contains("[Alt]") )
							{
								if ( btn.AccessKey.Length > 0 )
									btn.ToolTip = btn.ToolTip.Replace("[Alt]", "[Alt+" + btn.AccessKey + "]");
								else
									btn.ToolTip = btn.ToolTip.Replace("[Alt]", String.Empty);
							}
						}
						// 05/25/2015 Paul.  We don't want the spacer in the Seven module header. 
						if ( !(iButton == 0 && ctlHover != null) )
							btn.Attributes.Add("style", "margin-right: 3px;");
						// 08/16/2017 Paul.  Add ability to apply a business rule to a button. 
						if ( !Sql.IsEmptyString(sBUSINESS_RULE) )
						{
							RuleValidation validation = new RuleValidation(typeof(DynamicButtonThis), null);
							RuleSet rules = RulesUtil.BuildRuleSet(sBUSINESS_RULE, validation);
							rules.Validate(validation);
							if ( validation.Errors.HasErrors )
							{
								SplendidError.SystemError(new StackTrace(true).GetFrame(0), RulesUtil.GetValidationErrors(validation));
							}
							else
							{
								DynamicButtonThis swThis = new DynamicButtonThis(btn, L10n);
								RuleExecution exec = new RuleExecution(validation, swThis);
								rules.Execute(exec);
							}
						}
					}
					else if ( String.Compare(sCONTROL_TYPE, "HyperLink", true) == 0 )
					{
						HyperLink lnk = new HyperLink();
						// 11/08/2020 Paul.  An Admin Only control should not be added as it would allow the visible/hidden flag to ignore the admin only rule. 
						if ( bVisible )
							ctl.Controls.Add(lnk);
						if ( !Sql.IsEmptyString(sCONTROL_ID) )
							lnk.ID          = sCONTROL_ID;
						lnk.Text        = L10n.Term(sCONTROL_TEXT);
						lnk.NavigateUrl = String.Format(sURL_FORMAT, objTEXT_FIELD);
						lnk.Target      = sURL_TARGET;
						lnk.CssClass    = sCONTROL_CSSCLASS;
						// 11/21/2008 Paul.  On post back, we need to re-create the buttons, but don't change the visiblity flag. 
						// The problem is that we don't have the record at this early stage, so we cannot properly evaluate gASSIGNED_USER_ID. 
						// Not setting the visibility flag is not an issue because .NET will restore the previous visibility state on post back. 
						if ( !bIsPostBack )
						{
							// 07/28/2010 Paul.  We need a flag to exclude a button from a mobile device. 
							// 03/14/2014 Paul.  Allow hidden buttons to be created. 
							lnk.Visible     = (!bEXCLUDE_MOBILE || !bIsMobile) && (bMOBILE_ONLY && bIsMobile || !bMOBILE_ONLY) && (bADMIN_ONLY && Security.IS_ADMIN || !bADMIN_ONLY) && !bHIDDEN;
							if ( lnk.Visible && !Sql.IsEmptyString(sMODULE_NAME) && !Sql.IsEmptyString(sMODULE_ACCESS_TYPE) )
							{
								int nACLACCESS = SplendidCRM.Security.GetUserAccess(sMODULE_NAME, sMODULE_ACCESS_TYPE);
								// 08/11/2008 John.  Fix owner access rights.
								// 10/27/2008 Brian.  Only show button if show_unassigned is enabled.
								// 11/21/2008 Paul.  We need to make sure that an owner can create a new record. 
								lnk.Visible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((Security.USER_ID == gASSIGNED_USER_ID) || (!bIsPostBack && rdr == null) || (rdr != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
								if ( lnk.Visible && !Sql.IsEmptyString(sTARGET_NAME) && !Sql.IsEmptyString(sTARGET_ACCESS_TYPE) )
								{
									// 08/11/2008 John.  Fix owner access rights.
									nACLACCESS = SplendidCRM.Security.GetUserAccess(sTARGET_NAME, sTARGET_ACCESS_TYPE);
									// 10/27/2008 Brian.  Only show button if show_unassigned is enabled.
									// 11/21/2008 Paul.  We need to make sure that an owner can create a new record. 
									lnk.Visible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((Security.USER_ID == gASSIGNED_USER_ID) || (!bIsPostBack && rdr == null) || (rdr != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
								}
							}
						}
						if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
						{
							lnk.Attributes.Add("onclick", sONCLICK_SCRIPT);
						}
						if ( !Sql.IsEmptyString(sCONTROL_ACCESSKEY) )
						{
							lnk.AccessKey = L10n.AccessKey(sCONTROL_ACCESSKEY);
						}
						if ( !Sql.IsEmptyString(sCONTROL_TOOLTIP) )
						{
							lnk.ToolTip = L10n.Term(sCONTROL_TOOLTIP);
							if ( lnk.ToolTip.Contains("[Alt]") )
							{
								if ( lnk.AccessKey.Length > 0 )
									lnk.ToolTip = lnk.ToolTip.Replace("[Alt]", "[Alt+" + lnk.AccessKey + "]");
								else
									lnk.ToolTip = lnk.ToolTip.Replace("[Alt]", String.Empty);
							}
						}
						// 04/04/2008 Paul.  Links need additional spacing.
						lnk.Attributes.Add("style", "margin-right: 3px; margin-left: 3px;");
						// 08/16/2017 Paul.  Add ability to apply a business rule to a button. 
						if ( !Sql.IsEmptyString(sBUSINESS_RULE) )
						{
							RuleValidation validation = new RuleValidation(typeof(DynamicButtonThis), null);
							RuleSet rules = RulesUtil.BuildRuleSet(sBUSINESS_RULE, validation);
							rules.Validate(validation);
							if ( validation.Errors.HasErrors )
							{
								SplendidError.SystemError(new StackTrace(true).GetFrame(0), RulesUtil.GetValidationErrors(validation));
							}
							else
							{
								DynamicButtonThis swThis = new DynamicButtonThis(lnk, L10n);
								RuleExecution exec = new RuleExecution(validation, swThis);
								rules.Execute(exec);
							}
						}
					}
					else if ( String.Compare(sCONTROL_TYPE, "ButtonLink", true) == 0 )
					{
						Button btn = new Button();
						// 11/08/2020 Paul.  An Admin Only control should not be added as it would allow the visible/hidden flag to ignore the admin only rule. 
						if ( bVisible )
							ctl.Controls.Add(btn);
						if ( !Sql.IsEmptyString(sCONTROL_ID) )
							btn.ID              = sCONTROL_ID;
						btn.Text            = "  " + L10n.Term(sCONTROL_TEXT) + "  ";
						btn.CssClass        = sCONTROL_CSSCLASS;
						// 05/25/2015 Paul.  New style for Seven theme buttons. 
						if ( ctlHover != null )
						{
							btn.CssClass = iButton == 0 ? sButtonStyle + "FirstButton" : sButtonStyle + "OtherButton";
						}
						// 03/21/2008 Paul.  Keep the command just in case we are in a browser that does not support javascript. 
						btn.Command        += Page_Command;
						btn.CommandName     = sCOMMAND_NAME;
						// 04/04/2016 Paul.  We want the ability to use the ~/ root instead of just ../. 
						sURL_FORMAT = sURL_FORMAT.Replace("~/", Sql.ToString(HttpContext.Current.Application["rootURL"]));
						// 08/22/2010 Paul.  Provide a way to override the default URL behavior and run javascript. 
						if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
							btn.OnClientClick   = String.Format(sONCLICK_SCRIPT, objTEXT_FIELD);
						// 03/24/2016 Paul.  Receive signature from jQuery Signature popup. 
						else if ( sURL_TARGET.EndsWith("PDF") || sURL_TARGET == "vCard" || Sql.IsEmptyString(sURL_TARGET) )
							btn.OnClientClick   = "window.location.href='" + Sql.EscapeJavaScript(String.Format(sURL_FORMAT, objTEXT_FIELD)) + "'; return false;";
						else
							btn.OnClientClick   = "window.open('" + Sql.EscapeJavaScript(String.Format(sURL_FORMAT, objTEXT_FIELD)) + "', '" + sURL_TARGET + "', '" +  SplendidCRM.Crm.Config.PopupWindowOptions() + "'); return false;";
						// 11/21/2008 Paul.  On post back, we need to re-create the buttons, but don't change the visiblity flag. 
						// The problem is that we don't have the record at this early stage, so we cannot properly evaluate gASSIGNED_USER_ID. 
						// Not setting the visibility flag is not an issue because .NET will restore the previous visibility state on post back. 
						if ( !bIsPostBack )
						{
							// 07/28/2010 Paul.  We need a flag to exclude a button from a mobile device. 
							// 03/14/2014 Paul.  Allow hidden buttons to be created. 
							btn.Visible     = (!bEXCLUDE_MOBILE || !bIsMobile) && (bMOBILE_ONLY && bIsMobile || !bMOBILE_ONLY) && (bADMIN_ONLY && Security.IS_ADMIN || !bADMIN_ONLY) && !bHIDDEN;
							if ( btn.Visible && !Sql.IsEmptyString(sMODULE_NAME) && !Sql.IsEmptyString(sMODULE_ACCESS_TYPE) )
							{
								int nACLACCESS = SplendidCRM.Security.GetUserAccess(sMODULE_NAME, sMODULE_ACCESS_TYPE);
								// 08/11/2008 John.  Fix owner access rights.
								// 10/27/2008 Brian.  Only show button if show_unassigned is enabled.
								// 11/21/2008 Paul.  We need to make sure that an owner can create a new record. 
								btn.Visible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((Security.USER_ID == gASSIGNED_USER_ID) || (!bIsPostBack && rdr == null) || (rdr != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
								if ( btn.Visible && !Sql.IsEmptyString(sTARGET_NAME) && !Sql.IsEmptyString(sTARGET_ACCESS_TYPE) )
								{
									// 08/11/2008 John.  Fix owner access rights.
									nACLACCESS = SplendidCRM.Security.GetUserAccess(sTARGET_NAME, sTARGET_ACCESS_TYPE);
									// 10/27/2008 Brian.  Only show button if show_unassigned is enabled.
									// 11/21/2008 Paul.  We need to make sure that an owner can create a new record. 
									btn.Visible = (nACLACCESS > ACL_ACCESS.OWNER) || (nACLACCESS == ACL_ACCESS.OWNER && ((Security.USER_ID == gASSIGNED_USER_ID) || (!bIsPostBack && rdr == null) || (rdr != null && bShowUnassigned && Sql.IsEmptyGuid(gASSIGNED_USER_ID))));
								}
							}
						}
						if ( !Sql.IsEmptyString(sCONTROL_ACCESSKEY) )
						{
							btn.AccessKey = L10n.AccessKey(sCONTROL_ACCESSKEY);
						}
						if ( !Sql.IsEmptyString(sCONTROL_TOOLTIP) )
						{
							btn.ToolTip = L10n.Term (sCONTROL_TOOLTIP);
							if ( btn.ToolTip.Contains("[Alt]") )
							{
								if ( btn.AccessKey.Length > 0 )
									btn.ToolTip = btn.ToolTip.Replace("[Alt]", "[Alt+" + btn.AccessKey + "]");
								else
									btn.ToolTip = btn.ToolTip.Replace("[Alt]", String.Empty);
							}
						}
						// 05/25/2015 Paul.  We don't want the spacer in the Seven module header. 
						if ( !(iButton == 0 && ctlHover != null) )
							btn.Attributes.Add("style", "margin-right: 3px;");
						// 08/16/2017 Paul.  Add ability to apply a business rule to a button. 
						if ( !Sql.IsEmptyString(sBUSINESS_RULE) )
						{
							RuleValidation validation = new RuleValidation(typeof(DynamicButtonThis), null);
							RuleSet rules = RulesUtil.BuildRuleSet(sBUSINESS_RULE, validation);
							rules.Validate(validation);
							if ( validation.Errors.HasErrors )
							{
								SplendidError.SystemError(new StackTrace(true).GetFrame(0), RulesUtil.GetValidationErrors(validation));
							}
							else
							{
								DynamicButtonThis swThis = new DynamicButtonThis(btn, L10n);
								RuleExecution exec = new RuleExecution(validation, swThis);
								rules.Execute(exec);
							}
						}
					}
				}
			}
			return nButtonCount;
		}

		/*
		private static ImageButton CreateLayoutImageButton(Guid gID, string sCommandName, int nFIELD_INDEX, string sAlternateText, string sImageUrl, CommandEventHandler Page_Command)
		{
			ImageButton btnDelete = new ImageButton();
			// 01/07/2006 Paul.  The problem with the ImageButton Delete event was that the dynamically rendered ID 
			// was not being found on every other page request.  The solution was to manually name and number the ImageButton IDs.
			// Make sure not to use ":" in the name, otherwise it will confuse the FindControl function. 
			btnDelete.ID              = sCommandName + "." + gID.ToString();
			btnDelete.CommandName     = sCommandName        ;
			btnDelete.CommandArgument = nFIELD_INDEX.ToString();
			btnDelete.CssClass        = "listViewTdToolsS1" ;
			// 08/18/2010 Paul.  IE8 does not support alt any more, so we need to use ToolTip instead. 
			btnDelete.ToolTip         = sAlternateText      ;
			btnDelete.ImageUrl        = sImageUrl           ;
			btnDelete.BorderWidth     = 0                   ;
			btnDelete.Width           = 12                  ;
			btnDelete.Height          = 12                  ;
			btnDelete.ImageAlign      = ImageAlign.AbsMiddle;
			if ( Page_Command != null )
				btnDelete.Command += Page_Command;
			return btnDelete;
		}
		*/

		// 04/09/2008 Paul.  Use SkinID to define the image. 
		// 12/24/2008 Paul.  We need access to this function for the merge module. 
		public static ImageButton CreateLayoutImageButtonSkin(Guid gID, string sCommandName, int nFIELD_INDEX, string sAlternateText, string sSkinID, CommandEventHandler Page_Command)
		{
			ImageButton btnDelete = new ImageButton();
			// 01/07/2006 Paul.  The problem with the ImageButton Delete event was that the dynamically rendered ID 
			// was not being found on every other page request.  The solution was to manually name and number the ImageButton IDs.
			// Make sure not to use ":" in the name, otherwise it will confuse the FindControl function. 
			btnDelete.ID              = sCommandName + "." + gID.ToString();
			btnDelete.CommandName     = sCommandName        ;
			btnDelete.CommandArgument = nFIELD_INDEX.ToString();
			btnDelete.CssClass        = "listViewTdToolsS1" ;
			// 08/18/2010 Paul.  IE8 does not support alt any more, so we need to use ToolTip instead. 
			btnDelete.ToolTip         = sAlternateText      ;
			btnDelete.SkinID          = sSkinID             ;
			if ( Page_Command != null )
				btnDelete.Command += Page_Command;
			return btnDelete;
		}

		public static void AppendDetailViewFields(string sDETAIL_NAME, HtmlTable tbl, DataRow rdr, L10N L10n, TimeZone T10n, CommandEventHandler Page_Command)
		{
			if ( tbl == null )
			{
				SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "HtmlTable is not defined for " + sDETAIL_NAME);
				return;
			}
			// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
			DataTable dtFields = SplendidCache.DetailViewFields(sDETAIL_NAME, Security.PRIMARY_ROLE_NAME);
			AppendDetailViewFields(dtFields.DefaultView, tbl, rdr, L10n, T10n, Page_Command, false);
		}

		public static void AppendDetailViewFields(DataView dvFields, HtmlTable tbl, DataRow rdr, L10N L10n, TimeZone T10n, CommandEventHandler Page_Command, bool bLayoutMode)
		{
			bool bIsMobile = false;
			SplendidPage Page = tbl.Page as SplendidPage;
			if ( Page != null )
				bIsMobile = Page.IsMobile;
			// 11/23/2009 Paul.  We need to make sure that AJAX is available before we use it. 
			ScriptManager mgrAjax = ScriptManager.GetCurrent(tbl.Page);

			HtmlTableRow tr = null;
			// 11/28/2005 Paul.  Start row index using the existing count so that headers can be specified. 
			int nRowIndex = tbl.Rows.Count - 1;
			int nColIndex = 0;
			// 01/07/2006 Paul.  Show table borders in layout mode. This will help distinguish blank lines from wrapped lines. 
			if ( bLayoutMode )
				tbl.Border = 1;
			// 03/30/2007 Paul.  Convert the currency values before displaying. 
			// The UI culture should already be set to format the currency. 
			Currency C10n = HttpContext.Current.Items["C10n"] as Currency;
			HttpSessionState Session = HttpContext.Current.Session;
			// 11/15/2007 Paul.  If there are no fields in the detail view, then hide the entire table. 
			// This allows us to hide the table by removing all detail view fields. 
			// 09/12/2009 Paul.  There is no reason to hide the table when in layout mode. 
			if ( dvFields.Count == 0 && tbl.Rows.Count <= 1 && !bLayoutMode )
				tbl.Visible = false;
			
			// 01/27/2008 Paul.  We need the schema table to determine if the data label is free-form text. 
			// 03/21/2008 Paul.  We need to use a view to search for the rows for the ColumnName. 
			// 01/18/2010 Paul.  To apply ACL Field Security, we need to know if the current record has an ASSIGNED_USER_ID field, and its value. 
			// 06/30/2018 Paul.  Preprocess the erased fields for performance. 
			Guid gASSIGNED_USER_ID = Guid.Empty;
			List<string> arrERASED_FIELDS = new List<string>();
			//DataView vwSchema = null;
			if ( rdr != null )
			{
				// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
				//vwSchema = new DataView(rdr.GetSchemaTable());
				//vwSchema.RowFilter = "ColumnName = 'ASSIGNED_USER_ID'";
				//if ( vwSchema.Count > 0 )
				if ( rdr.Table.Columns.Contains("ASSIGNED_USER_ID") )
				{
					gASSIGNED_USER_ID = Sql.ToGuid(rdr["ASSIGNED_USER_ID"]);
				}
				if ( Crm.Config.enable_data_privacy() )
				{
					if ( rdr.Table.Columns.Contains("ERASED_FIELDS") )
					{
						string sERASED_FIELDS = Sql.ToString(rdr["ERASED_FIELDS"]);
						if ( !Sql.IsEmptyString(sERASED_FIELDS) )
						{
							arrERASED_FIELDS.AddRange(sERASED_FIELDS.Split(','));
						}
					}
				}
			}

			// 08/02/2010 Paul.  The cell fields need to be outside the loop in order to support COLSPAN=-1. 
			HtmlTableCell tdLabel = null;
			HtmlTableCell tdField = null;
			// 01/01/2008 Paul.  Pull config flag outside the loop. 
			bool bEnableTeamManagement = Crm.Config.enable_team_management();
			// 08/28/2009 Paul.  Allow dynamic teams to be turned off. 
			bool bEnableDynamicTeams   = Crm.Config.enable_dynamic_teams();
			// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			bool bEnableDynamicAssignment = Crm.Config.enable_dynamic_assignment();
			// 09/16/2018 Paul.  Create a multi-tenant system. 
			if ( Crm.Config.enable_multi_tenant_teams() )
			{
				bEnableTeamManagement    = false;
				bEnableDynamicTeams      = false;
				bEnableDynamicAssignment = false;
			}
			
			HttpApplicationState Application = HttpContext.Current.Application;
			// 08/22/2012 Paul.  We need to prevent duplicate names. 
			Hashtable hashLABEL_IDs = new Hashtable();
			bool bSupportsDraggable = Sql.ToBoolean(Session["SupportsDraggable"]);
			// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
			bool bEnableTaxLineItems = Sql.ToBoolean(HttpContext.Current.Application["CONFIG.Orders.TaxLineItems"]);
			foreach(DataRowView row in dvFields)
			{
				string sDETAIL_NAME = Sql.ToString (row["DETAIL_NAME"]);
				Guid   gID          = Sql.ToGuid   (row["ID"         ]);
				int    nFIELD_INDEX = Sql.ToInteger(row["FIELD_INDEX"]);
				string sFIELD_TYPE  = Sql.ToString (row["FIELD_TYPE" ]);
				string sDATA_LABEL  = Sql.ToString (row["DATA_LABEL" ]);
				string sDATA_FIELD  = Sql.ToString (row["DATA_FIELD" ]);
				string sDATA_FORMAT = Sql.ToString (row["DATA_FORMAT"]);
				string sLIST_NAME   = Sql.ToString (row["LIST_NAME"  ]);
				int    nCOLSPAN     = Sql.ToInteger(row["COLSPAN"    ]);
				string LABEL_WIDTH = Sql.ToString (row["LABEL_WIDTH"]);
				string sFIELD_WIDTH = Sql.ToString (row["FIELD_WIDTH"]);
				int    nDATA_COLUMNS= Sql.ToInteger(row["DATA_COLUMNS"]);
				// 08/02/2010 Paul.  Move URL fields to the top of the loop. 
				string sURL_FIELD   = Sql.ToString (row["URL_FIELD"  ]);
				string sURL_FORMAT  = Sql.ToString (row["URL_FORMAT" ]);
				string sURL_TARGET  = Sql.ToString (row["URL_TARGET" ]);
				// 06/12/2009 Paul.  Add TOOL_TIP for help hover.
				string sTOOL_TIP    = String.Empty;
				try
				{
					sTOOL_TIP = Sql.ToString (row["TOOL_TIP"]);
				}
				catch(Exception ex)
				{
					// 06/12/2009 Paul.  The TOOL_TIP is not in the view, then log the error and continue. 
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
				}
				// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
				string sMODULE_TYPE = String.Empty;
				try
				{
					sMODULE_TYPE = Sql.ToString (row["MODULE_TYPE"]);
				}
				catch(Exception ex)
				{
					// 06/16/2010 Paul.  The MODULE_TYPE is not in the view, then log the error and continue. 
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
				}
				// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
				string sPARENT_FIELD = String.Empty;
				try
				{
					sPARENT_FIELD = Sql.ToString (row["PARENT_FIELD"]);
				}
				catch(Exception ex)
				{
					// 10/09/2010 Paul.  The PARENT_FIELD is not in the view, then log the error and continue. 
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
				}
				// 12/02/2007 Paul.  Each view can now have its own number of data columns. 
				// This was needed so that search forms can have 4 data columns. The default is 2 columns. 
				if ( nDATA_COLUMNS == 0 )
					nDATA_COLUMNS = 2;

				// 01/18/2010 Paul.  To apply ACL Field Security, we need to know if the Module Name, which we will extract from the EditView Name. 
				string sMODULE_NAME = String.Empty;
				string[] arrDETAIL_NAME = sDETAIL_NAME.Split('.');
				if ( arrDETAIL_NAME.Length > 0 )
					sMODULE_NAME = arrDETAIL_NAME[0];
				bool bIsReadable  = true;
				// 06/16/2010 Paul.  sDATA_FIELD may be empty. 
				if ( SplendidInit.bEnableACLFieldSecurity && !Sql.IsEmptyString(sDATA_FIELD) )
				{
					Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, sDATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
				}

				// 11/25/2006 Paul.  If Team Management has been disabled, then convert the field to a blank. 
				// Keep the field, but treat it as blank so that field indexes will still be valid. 
				// 12/03/2006 Paul.  Allow the team field to be visible during layout. 
				// 12/03/2006 Paul.  The correct field is TEAM_NAME.  We don't use TEAM_ID in the detail view. 
				// 08/24/2009 Paul.  Add support for dynamic teams. 
				if ( !bLayoutMode && (sDATA_FIELD == "TEAM_NAME" || sDATA_FIELD == "TEAM_SET_NAME") )
				{
					if ( !bEnableTeamManagement )
					{
						sFIELD_TYPE = "Blank";
					}
					else if ( bEnableDynamicTeams )
					{
						// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
						if ( sDATA_FORMAT != "1" && !sDATA_FORMAT.ToLower().Contains("single") )
						{
							// 08/28/2009 Paul.  If dynamic teams are enabled, then always use the set name. 
							sDATA_LABEL = ".LBL_TEAM_SET_NAME";
							sDATA_FIELD = "TEAM_SET_NAME";
						}
						else
						{
							sDATA_LABEL = ".LBL_TEAM_NAME";
							sDATA_FIELD = "TEAM_NAME";
						}
					}
				}
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				if ( !bLayoutMode && (sDATA_FIELD == "ASSIGNED_TO" || sDATA_FIELD == "ASSIGNED_TO_NAME" || sDATA_FIELD == "ASSIGNED_SET_NAME") )
				{
					// 12/17/2017 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
					// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
					if ( bEnableDynamicAssignment && !sDATA_FORMAT.ToLower().Contains("single") )
					{
						sDATA_LABEL = ".LBL_ASSIGNED_SET_NAME";
						sDATA_FIELD = "ASSIGNED_SET_NAME";
					}
					else if ( sDATA_FIELD == "ASSIGNED_SET_NAME" )
					{
						sDATA_LABEL = ".LBL_ASSIGNED_TO";
						sDATA_FIELD = "ASSIGNED_TO_NAME";
					}
				}
				// 12/13/2013 Paul.  Allow each product to have a default tax rate. 
				if ( !bLayoutMode && sDATA_FIELD == "TAX_CLASS" )
				{
					if ( bEnableTaxLineItems )
					{
						// 08/28/2009 Paul.  If dynamic teams are enabled, then always use the set name. 
						sDATA_LABEL = "ProductTemplates.LBL_TAXRATE_ID";
						sDATA_FIELD = "TAXRATE_ID";
						sLIST_NAME  = "TaxRates";
					}
				}

				// 04/04/2010 Paul.  Hide the Exchange Folder field if disabled for this module or user. 
				if ( !bLayoutMode && sDATA_FIELD == "EXCHANGE_FOLDER" )
				{
					if ( !Crm.Modules.ExchangeFolders(sMODULE_NAME) || !Security.HasExchangeAlias() )
					{
						sFIELD_TYPE = "Blank";
					}
				}
				// 09/02/2012 Paul.  A separator will create a new table. We need to match the outer and inner layout. 
				if ( String.Compare(sFIELD_TYPE, "Separator", true) == 0 )
				{
					System.Web.UI.HtmlControls.HtmlTable tblNew = new System.Web.UI.HtmlControls.HtmlTable();
					tblNew.Attributes.Add("class", "tabDetailView");
					tblNew.Style.Add(HtmlTextWriterStyle.MarginTop, "5px");
					// 09/27/2012 Paul.  Separator can have an ID and can have a style so that it can be hidden. 
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
						tblNew.ID = sDATA_FIELD;
					if ( !Sql.IsEmptyString(sDATA_FORMAT) && !bLayoutMode )
						tblNew.Style.Add(HtmlTextWriterStyle.Display, sDATA_FORMAT);
					int nParentIndex = tbl.Parent.Controls.IndexOf(tbl);
					tbl.Parent.Controls.AddAt(nParentIndex + 1, tblNew);
					tbl = tblNew;
					
					nRowIndex = -1;
					nColIndex = 0;
					tdLabel = null;
					tdField = null;
					if ( bLayoutMode )
						tbl.Border = 1;
					else
						continue;
				}
				// 11/17/2007 Paul.  On a mobile device, each new field is on a new row. 
				// 08/02/2010 Paul. COLSPAN == -1 means that a new column should not be created. 
				if ( (nCOLSPAN >= 0 && nColIndex == 0) || tr == null || bIsMobile )
				{
					// 11/25/2005 Paul.  Don't pre-create a row as we don't want a blank
					// row at the bottom.  Add rows just before they are needed. 
					nRowIndex++;
					tr = new HtmlTableRow();
					tbl.Rows.Insert(nRowIndex, tr);
				}
				if ( bLayoutMode )
				{
					HtmlTableCell tdAction = new HtmlTableCell();
					tr.Cells.Add(tdAction);
					tdAction.Attributes.Add("class", "tabDetailViewDL");
					tdAction.NoWrap = true;

					Literal litIndex = new Literal();
					litIndex.Text = "&nbsp;" + nFIELD_INDEX.ToString() + "&nbsp;";
					tdAction.Controls.Add(litIndex   );

					// 05/26/2007 Paul.  Fix the terms. The are in the Dropdown module. 
					// 05/18/2013 Paul.  Add drag handle. 
					if ( bSupportsDraggable )
					{
						Image imgDragIcon = new Image();
						imgDragIcon.SkinID = "draghandle_table";
						imgDragIcon.Attributes.Add("draggable"  , "true");
						imgDragIcon.Attributes.Add("ondragstart", "event.dataTransfer.setData('Text', '" + nFIELD_INDEX.ToString() + "');");
						tdAction.Controls.Add(imgDragIcon);
						// 08/08/2013 Paul.  IE does not support preventDefault. 
						// http://stackoverflow.com/questions/1000597/event-preventdefault-function-not-working-in-ie
						tdAction.Attributes.Add("ondragover", "LayoutDragOver(event, '" + nFIELD_INDEX.ToString() + "')");
						tdAction.Attributes.Add("ondrop"    , "LayoutDropIndex(event, '" + nFIELD_INDEX.ToString() + "')");
					}
					else
					{
						ImageButton btnMoveUp   = CreateLayoutImageButtonSkin(gID, "Layout.MoveUp"  , nFIELD_INDEX, L10n.Term("Dropdown.LNK_UP"    ), "uparrow_inline"  , Page_Command);
						ImageButton btnMoveDown = CreateLayoutImageButtonSkin(gID, "Layout.MoveDown", nFIELD_INDEX, L10n.Term("Dropdown.LNK_DOWN"  ), "downarrow_inline", Page_Command);
						tdAction.Controls.Add(btnMoveUp  );
						tdAction.Controls.Add(btnMoveDown);
					}
					ImageButton btnInsert   = CreateLayoutImageButtonSkin(gID, "Layout.Insert"  , nFIELD_INDEX, L10n.Term("Dropdown.LNK_INS"   ), "plus_inline"     , Page_Command);
					ImageButton btnEdit     = CreateLayoutImageButtonSkin(gID, "Layout.Edit"    , nFIELD_INDEX, L10n.Term("Dropdown.LNK_EDIT"  ), "edit_inline"     , Page_Command);
					ImageButton btnDelete   = CreateLayoutImageButtonSkin(gID, "Layout.Delete"  , nFIELD_INDEX, L10n.Term("Dropdown.LNK_DELETE"), "delete_inline"   , Page_Command);
					tdAction.Controls.Add(btnInsert  );
					tdAction.Controls.Add(btnEdit    );
					tdAction.Controls.Add(btnDelete  );
				}
				// 08/02/2010 Paul.  Move literal label up so that it can be accessed when processing a blank. 
				Literal   litLabel = new Literal();
				// 08/22/2012 Paul.  Try and create a safe label ID so that it can be accessed using FindControl(). 
				// We are using the DATA_FIELD to match the logic in the EditView area. 
				if ( !Sql.IsEmptyString(sDATA_FIELD) && !hashLABEL_IDs.Contains(sDATA_FIELD) )
				{
					litLabel.ID = sDATA_FIELD.Replace(" ", "_").Replace(".", "_") + "_LABEL";
					hashLABEL_IDs.Add(sDATA_FIELD, null);
				}
				HyperLink lnkField = null;
				if ( nCOLSPAN >= 0 || tdLabel == null || tdField == null )
				{
					// 05/28/2015 Paul.  The Seven theme has labels stacked above values. 
					if ( SplendidDynamic.StackedLayout(Page.Theme, sDETAIL_NAME) )
					{
						tdLabel = new HtmlTableCell();
						tdField = tdLabel;
						//tdLabel.Attributes.Add("class", "tabDetailViewDL");
						//tdLabel.VAlign = "top";
						//tdLabel.Width  = LABEL_WIDTH;
						tdField.Attributes.Add("class", "tabStackedDetailViewDF");
						tdField.VAlign = "top";
						//tr.Cells.Add(tdLabel);
						tr.Cells.Add(tdField);
						if ( nCOLSPAN > 0 )
						{
							tdField.ColSpan = (nCOLSPAN + 1) / 2;
							if ( bLayoutMode )
								tdField.ColSpan++;
						}
						tdField.Width  = (100 / nDATA_COLUMNS).ToString() + "%";
						// 05/28/2015 Paul.  Wrap the label in a div. 
						HtmlGenericControl span = new HtmlGenericControl("span");
						span.Attributes.Add("class", "tabStackedDetailViewDL");
						tdLabel.Controls.Add(span);
						span.Controls.Add(litLabel);
					}
					else
					{
						tdLabel = new HtmlTableCell();
						tdField = new HtmlTableCell();
						tdLabel.Attributes.Add("class", "tabDetailViewDL");
						tdLabel.VAlign = "top";
						tdLabel.Width  = LABEL_WIDTH;
						tdField.Attributes.Add("class", "tabDetailViewDF");
						tdField.VAlign = "top";
						tr.Cells.Add(tdLabel);
						tr.Cells.Add(tdField);
						if ( nCOLSPAN > 0 )
						{
							tdField.ColSpan = nCOLSPAN;
							if ( bLayoutMode )
								tdField.ColSpan++;
						}
						// 11/28/2005 Paul.  Don't use the field width if COLSPAN is specified as we want it to take the rest of the table.  The label width will be sufficient. 
						if ( nCOLSPAN == 0 )
							tdField.Width  = sFIELD_WIDTH;
					
						// 08/02/2010 Paul.  The label will get skipped if we are processing COLSPAN=-1. 
						tdLabel.Controls.Add(litLabel);
					}
					// 01/18/2010 Paul.  Apply ACL Field Security. 
					litLabel.Visible = bLayoutMode || bIsReadable;
					//litLabel.Text = nFIELD_INDEX.ToString() + " (" + nRowIndex.ToString() + "," + nColIndex.ToString() + ")";
					try
					{
						if ( bLayoutMode )
							litLabel.Text = sDATA_LABEL;
						else if ( sDATA_LABEL.IndexOf(".") >= 0 )
							litLabel.Text = L10n.Term(sDATA_LABEL);
						else if ( !Sql.IsEmptyString(sDATA_LABEL) && rdr != null )
						{
							// 01/27/2008 Paul.  If the data label is not in the schema table, then it must be free-form text. 
							// It is not used often, but we allow the label to come from the result set.  For example,
							// when the parent is stored in the record, we need to pull the module name from the record. 
							litLabel.Text = sDATA_LABEL;
							// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
							//if ( vwSchema != null )
							if ( rdr != null )
							{
								//vwSchema.RowFilter = "ColumnName = '" + Sql.EscapeSQL(sDATA_LABEL) + "'";
								//if ( vwSchema.Count > 0 )
								if ( rdr.Table.Columns.Contains(sDATA_LABEL) )
									litLabel.Text = Sql.ToString(rdr[sDATA_LABEL]) + L10n.Term("Calls.LBL_COLON");
							}
						}
						// 07/15/2006 Paul.  Always put something for the label so that table borders will look right. 
						else
							litLabel.Text = "&nbsp;";
						// 05/28/2015 Paul.  The Seven theme has labels stacked above values. 
						if ( SplendidDynamic.StackedLayout(Page.Theme, sDETAIL_NAME) && litLabel.Text.EndsWith(":") )
							litLabel.Text = litLabel.Text.Substring(0, litLabel.Text.Length - 1);

						// 06/12/2009 Paul.  Add Tool Tip hover. 
						// 11/23/2009 Paul.  Only add tool tip if AJAX is available and this is not a mobile device. 
						// 01/18/2010 Paul.  Only add tool tip if the label is visible. 
						if ( !bIsMobile && mgrAjax != null && !Sql.IsEmptyString(sTOOL_TIP) && !Sql.IsEmptyString(sDATA_FIELD) && litLabel.Visible )
						{
							Image imgToolTip = new Image();
							imgToolTip.SkinID = "tooltip_inline";
							// 07/06/2017 Paul.  IDs should not have spaces, but we do allow multiple data fields. 
							imgToolTip.ID     = sDATA_FIELD.Replace(" ", "_") + "_TOOLTIP_IMAGE";
							tdLabel.Controls.Add(imgToolTip);
							
							Panel pnlToolTip = new Panel();
							pnlToolTip.ID       = sDATA_FIELD.Replace(" ", "_") + "_TOOLTIP_PANEL";
							pnlToolTip.CssClass = "tooltip";
							tdLabel.Controls.Add(pnlToolTip);

							Literal litToolTip = new Literal();
							litToolTip.Text = sDATA_FIELD.Replace(" ", "_");
							pnlToolTip.Controls.Add(litToolTip);
							if ( bLayoutMode )
								litToolTip.Text = sTOOL_TIP;
							else if ( sTOOL_TIP.IndexOf(".") >= 0 )
								litToolTip.Text = L10n.Term(sTOOL_TIP);
							else
								litToolTip.Text = sTOOL_TIP;
							
							AjaxControlToolkit.HoverMenuExtender hovToolTip = new AjaxControlToolkit.HoverMenuExtender();
							hovToolTip.TargetControlID = imgToolTip.ID;
							hovToolTip.PopupControlID  = pnlToolTip.ID;
							hovToolTip.PopupPosition   = AjaxControlToolkit.HoverMenuPopupPosition.Right;
							hovToolTip.PopDelay        = 50;
							hovToolTip.OffsetX         = 0;
							hovToolTip.OffsetY         = 0;
							tdLabel.Controls.Add(hovToolTip);
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						litLabel.Text = ex.Message;
					}
				}
				
				if ( String.Compare(sFIELD_TYPE, "Blank", true) == 0 )
				{
					Literal litField = new Literal();
					tdField.Controls.Add(litField);
					if ( bLayoutMode )
					{
						litLabel.Text = "*** BLANK ***";
						litField.Text = "*** BLANK ***";
					}
					else
					{
						// 12/03/2006 Paul.  Make sure to clear the label.  This is necessary to convert a TEAM to blank when disabled. 
						litLabel.Text = "&nbsp;";
						litField.Text = "&nbsp;";
					}
				}
				// 09/03/2012 Paul.  A separator does nothing in Layout mode. 
				else if ( String.Compare(sFIELD_TYPE, "Separator", true) == 0 )
				{
					if ( bLayoutMode )
					{
						litLabel.Text = "*** SEPARATOR ***";
						nColIndex = nDATA_COLUMNS;
						tdField.ColSpan = 2 * nDATA_COLUMNS - 1;
						// 09/03/2012 Paul.  When in layout mode, we need to add a column for arrangement. 
						tdField.ColSpan++;
					}
				}
				// 09/03/2012 Paul.  A header is similar to a label, but without the data field. 
				else if ( String.Compare(sFIELD_TYPE, "Header", true) == 0 )
				{
					// 06/05/2015 Paul.  Adding space in Seven theme is creating a blank line. 
					if ( tdField != tdLabel )
					{
						Literal litField = new Literal();
						tdField.Controls.Add(litField);
						litField.Text = "&nbsp;";
					}
					if ( !bLayoutMode )
					{
						litLabel.Text = "<h4>" + litLabel.Text + "</h4>";
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "Line", true) == 0 )
				{
					if ( bLayoutMode )
					{
						Literal litField = new Literal();
						tdField.Controls.Add(litField);
						litLabel.Text = "*** LINE ***";
						litField.Text = "*** LINE ***";
					}
					else
					{
						tr.Cells.Clear();
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "String", true) == 0 )
				{
					if ( bLayoutMode )
					{
						Literal litField = new Literal();
						litField.Text = sDATA_FIELD;
						tdField.Controls.Add(litField);
					}
					else if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/06/2005 Paul.  Wrap all string fields in a SPAN tag to simplify regression testing. 
						HtmlGenericControl spnField = new HtmlGenericControl("span");
						tdField.Controls.Add(spnField);
						spnField.ID = sDATA_FIELD;

						Literal litField = new Literal();
						spnField.Controls.Add(litField);
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						litField.Visible = bLayoutMode || bIsReadable;
						try
						{
							string[] arrLIST_NAME  = sLIST_NAME .Split(' ');
							string[] arrDATA_FIELD = sDATA_FIELD.Split(' ');
							// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
							string[] arrPARENT_FIELD = sPARENT_FIELD.Split(' ');
							object[] objDATA_FIELD = new object[arrDATA_FIELD.Length];
							for ( int i=0 ; i < arrDATA_FIELD.Length; i++ )
							{
								if ( arrDATA_FIELD[i].IndexOf(".") >= 0 )
								{
									objDATA_FIELD[i] = L10n.Term(arrDATA_FIELD[i]);
								}
								// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
								else if ( !Sql.IsEmptyString(sPARENT_FIELD) && !Sql.IsEmptyString(sLIST_NAME) )
								{
									if ( arrPARENT_FIELD.Length == arrLIST_NAME.Length && arrLIST_NAME.Length == arrDATA_FIELD.Length )
									{
										if ( rdr != null )
										{
											string sPARENT_LIST_NAME = Sql.ToString(rdr[arrPARENT_FIELD[i]]);
											if ( !Sql.IsEmptyString(sPARENT_LIST_NAME) )
											{
												bool bCustomCache = false;
												objDATA_FIELD[i] = SplendidCache.CustomList(sPARENT_LIST_NAME, Sql.ToString(rdr[arrDATA_FIELD[i]]), ref bCustomCache);
												if ( bCustomCache )
													continue;
												if ( Sql.ToString(rdr[arrDATA_FIELD[i]]).StartsWith("<?xml") )
												{
													StringBuilder sb = new StringBuilder();
													XmlDocument xml = new XmlDocument();
													// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
													// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
													// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
													xml.XmlResolver = null;
													xml.LoadXml(Sql.ToString(rdr[arrDATA_FIELD[i]]));
													XmlNodeList nlValues = xml.DocumentElement.SelectNodes("Value");
													foreach ( XmlNode xValue in nlValues )
													{
														if ( sb.Length > 0 )
															sb.Append(", ");
														sb.Append(L10n.Term("." + sPARENT_LIST_NAME + ".", xValue.InnerText));
													}
													objDATA_FIELD[i] = sb.ToString();
												}
												else
												{
													objDATA_FIELD[i] = L10n.Term("." + sPARENT_LIST_NAME + ".", rdr[arrDATA_FIELD[i]]);
												}
											}
											else
												objDATA_FIELD[i] = String.Empty;
										}
										else
											objDATA_FIELD[i] = String.Empty;
									}
								}
								// 06/30/2018 Paul.  The data field cannot be empty. 
								else if ( !Sql.IsEmptyString(sLIST_NAME) && !Sql.IsEmptyString(arrDATA_FIELD[i]) )
								{
									if ( arrLIST_NAME.Length == arrDATA_FIELD.Length )
									{
										if ( rdr != null )
										{
											// 06/30/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
											if ( rdr[arrDATA_FIELD[i]] == DBNull.Value )
											{
												if ( arrERASED_FIELDS.Contains(arrDATA_FIELD[i]) )
												{
													objDATA_FIELD[i] = Sql.DataPrivacyErasedPill(L10n);
													continue;
												}
											}
											// 08/06/2008 Paul.  Use an array to define the custom caches so that list is in the Cache module. 
											// This should reduce the number of times that we have to edit the SplendidDynamic module. 
											bool bCustomCache = false;
											// 08/10/2008 Paul.  Use a shared function to simplify access to Custom Cache.
											objDATA_FIELD[i] = SplendidCache.CustomList(arrLIST_NAME[i], Sql.ToString(rdr[arrDATA_FIELD[i]]), ref bCustomCache);
											if ( bCustomCache )
											{
												// 06/27/2018 Paul.  csv and custom list requires exception. 
												if ( sDATA_FORMAT.ToLower() == "csv" )
												{
													string[] arrValues = Sql.ToString(rdr[arrDATA_FIELD[i]]).Split(',');
													objDATA_FIELD[i] = SplendidCache.CustomListValues(arrLIST_NAME[i], arrValues);
												}
												continue;
											}
											// 02/12/2008 Paul.  If the list contains XML, then treat as a multi-selection. 
											if ( Sql.ToString(rdr[arrDATA_FIELD[i]]).StartsWith("<?xml") )
											{
												StringBuilder sb = new StringBuilder();
												XmlDocument xml = new XmlDocument();
												// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
												// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
												// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
												xml.XmlResolver = null;
												xml.LoadXml(Sql.ToString(rdr[arrDATA_FIELD[i]]));
												XmlNodeList nlValues = xml.DocumentElement.SelectNodes("Value");
												foreach ( XmlNode xValue in nlValues )
												{
													if ( sb.Length > 0 )
														sb.Append(", ");
													sb.Append(L10n.Term("." + arrLIST_NAME[i] + ".", xValue.InnerText));
												}
												objDATA_FIELD[i] = sb.ToString();
											}
											// 06/27/2018 Paul.  csv and custom list requires exception. 
											else if ( sDATA_FORMAT.ToLower() == "csv" )
											{
												StringBuilder sb = new StringBuilder();
												string[] arrValues = Sql.ToString(rdr[arrDATA_FIELD[i]]).Split(',');
												foreach ( string sValue in arrValues )
												{
													if ( sb.Length > 0 )
														sb.Append(", ");
													sb.Append(L10n.Term("." + arrLIST_NAME[i] + ".", sValue));
												}
												objDATA_FIELD[i] = sb.ToString();
											}
											else
											{
												objDATA_FIELD[i] = L10n.Term("." + arrLIST_NAME[i] + ".", rdr[arrDATA_FIELD[i]]);
											}
										}
										else
											objDATA_FIELD[i] = String.Empty;
									}
								}
								else if ( !Sql.IsEmptyString(arrDATA_FIELD[i]) )
								{
									if ( rdr != null && rdr[arrDATA_FIELD[i]] != DBNull.Value)
									{
										// 12/05/2005 Paul.  If the data is a DateTime field, then make sure to perform the timezone conversion. 
										if ( rdr[arrDATA_FIELD[i]].GetType() == Type.GetType("System.DateTime") )
											objDATA_FIELD[i] = T10n.FromServerTime(rdr[arrDATA_FIELD[i]]);
										// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
										// 02/16/2010 Paul.  Move ToGuid to the function so that it can be captured if invalid. 
										// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
										else if ( !Sql.IsEmptyString(sMODULE_TYPE) )
											objDATA_FIELD[i] = HttpUtility.HtmlEncode(Crm.Modules.ItemName(Application, sMODULE_TYPE, rdr[arrDATA_FIELD[i]]));
										else if ( rdr[arrDATA_FIELD[i]].GetType() == typeof(System.String) )
										{
											// 09/15/2014 Paul.  Special case where we format address fields in HTML in the SQL View. 
											// We need to un-enode <br>. 
											// 12/09/2104 Paul.  Encoding HTML fields makes it difficult to see the Email Template for campaigns. 
											if ( sDATA_FIELD.EndsWith("_HTML") )
												objDATA_FIELD[i] = Sql.ToString(rdr[arrDATA_FIELD[i]]);  // HttpUtility.HtmlEncode(Sql.ToString(rdr[arrDATA_FIELD[i]])).Replace("&lt;br&gt;", "<br />").Replace("&amp;nbsp;", "&nbsp;");
											else
												objDATA_FIELD[i] = HttpUtility.HtmlEncode(Sql.ToString(rdr[arrDATA_FIELD[i]]));
										}
										else
											objDATA_FIELD[i] = rdr[arrDATA_FIELD[i]];
									}
									else
									{
										// 06/30/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
										if ( arrERASED_FIELDS.Contains(arrDATA_FIELD[i]) )
										{
											objDATA_FIELD[i] = Sql.DataPrivacyErasedPill(L10n);
										}
									}
								}
							}
							if ( rdr != null )
							{
								// 01/09/2006 Paul.  Allow DATA_FORMAT to be optional.   If missing, write data directly. 
								if ( sDATA_FORMAT == String.Empty )
								{
									for ( int i=0; i < arrDATA_FIELD.Length; i++ )
										arrDATA_FIELD[i] = Sql.ToString(objDATA_FIELD[i]);
									litField.Text = String.Join(" ", arrDATA_FIELD);
								}
								else if ( sDATA_FORMAT == "{0:c}" && C10n != null )
								{
									// 03/30/2007 Paul.  Convert DetailView currencies on the fly. 
									// 05/05/2007 Paul.  In an earlier step, we convert NULLs to empty strings. 
									// Attempts to convert to decimal will generate an error: Input string was not in a correct format.
									// 04/19/2020 Paul.  Null value is no longer converted to an empty string. 
									if ( objDATA_FIELD[0] != null && !(objDATA_FIELD[0] is string) )
									{
										Decimal d = C10n.ToCurrency(Convert.ToDecimal(objDATA_FIELD[0]));
										litField.Text = d.ToString("c");
									}
								}
								// 06/27/2018 Paul.  csv and custom list requires exception. 
								else if ( sDATA_FORMAT.ToLower() == "csv" )
								{
									litField.Text = Sql.ToString(objDATA_FIELD[0]);
								}
								else
									litField.Text = String.Format(sDATA_FORMAT, objDATA_FIELD);
								/*
								// 08/02/2010 Paul.  Add javascript to the output. 
								// 08/02/2010 Paul.  The javascript will be moved to a separate record. 
								if ( !Sql.IsEmptyString(sURL_FIELD) && !Sql.IsEmptyString(sURL_FORMAT) )
								{
									Literal litUrlField = new Literal();
									tdField.Controls.Add(litUrlField);
									string[] arrURL_FIELD = sURL_FIELD.Split(' ');
									object[] objURL_FIELD = new object[arrURL_FIELD.Length];
									for ( int i=0 ; i < arrURL_FIELD.Length; i++ )
									{
										if ( !Sql.IsEmptyString(arrURL_FIELD[i]) )
										{
											// 07/26/2007 Paul.  Make sure to escape the javascript string. 
											if ( row[arrURL_FIELD[i]] != DBNull.Value )
												objURL_FIELD[i] = Sql.EscapeJavaScript(Sql.ToString(rdr[arrURL_FIELD[i]]));
											else
												objURL_FIELD[i] = String.Empty;
										}
									}
									// 12/03/2009 Paul.  LinkedIn Company Profile requires a span tag to insert the link.
									litUrlField.Text = "&nbsp;<span id=\"" + String.Format(sURL_TARGET, objURL_FIELD) + "\"></span>";
									litUrlField.Text += "<script type=\"text/javascript\"> " + String.Format(sURL_FORMAT, objURL_FIELD) + "</script>";
								}
								*/
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							litField.Text = ex.Message;
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "CheckBox", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						CheckBox chkField = new CheckBox();
						tdField.Controls.Add(chkField);
						chkField.Enabled  = false     ;
						chkField.CssClass = "checkbox";
						// 03/16/2006 Paul.  Give the checkbox a name so that it can be validated with SplendidTest. 
						chkField.ID       = sDATA_FIELD;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						chkField.Visible  = bLayoutMode || bIsReadable;
						try
						{
							if ( rdr != null )
								chkField.Checked = Sql.ToBoolean(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "Button", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Button btnField = new Button();
						tdField.Controls.Add(btnField);
						btnField.CssClass = "button";
						// 03/16/2006 Paul.  Give the button a name so that it can be validated with SplendidTest. 
						btnField.ID       = sDATA_FIELD;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						btnField.Visible  = bLayoutMode || bIsReadable;
						if ( Page_Command != null )
						{
							btnField.Command    += Page_Command;
							btnField.CommandName = sDATA_FORMAT  ;
						}
						try
						{
							if ( bLayoutMode )
							{
								btnField.Text    = sDATA_FIELD;
								btnField.Enabled = false      ;
							}
							else if ( sDATA_FIELD.IndexOf(".") >= 0 )
							{
								btnField.Text = L10n.Term(sDATA_FIELD);
							}
							else if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
							{
								btnField.Text = Sql.ToString(rdr[sDATA_FIELD]);
							}
							btnField.Attributes.Add("title", btnField.Text);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							btnField.Text = ex.Message;
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "Textbox", true) == 0 )
				{
					/*
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						TextBox txtField = new TextBox();
						tdField.Controls.Add(txtField);
						txtField.ReadOnly = true;
						txtField.TextMode = TextBoxMode.MultiLine;
						// 03/16/2006 Paul.  Give the textbox a name so that it can be validated with SplendidTest. 
						txtField.ID       = sDATA_FIELD;
						try
						{
							string[] arrDATA_FORMAT = sDATA_FORMAT.Split(',');
							if ( arrDATA_FORMAT.Length == 2 )
							{
								txtField.Rows    = Sql.ToInteger(arrDATA_FORMAT[0]);
								txtField.Columns = Sql.ToInteger(arrDATA_FORMAT[1]);
							}
							if ( bLayoutMode )
							{
								txtField.Text = sDATA_FIELD;
							}
							else if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
							{
								txtField.Text = Sql.ToString(rdr[sDATA_FIELD]);
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtField.Text = ex.Message;
						}
					}
					*/
					// 07/07/2007 Paul.  Instead of using a real textbox, just replace new lines with <br />. 
					// This will perserve a majority of the HTML formating if it exists. 
					if ( bLayoutMode )
					{
						Literal litField = new Literal();
						litField.Text = sDATA_FIELD;
						tdField.Controls.Add(litField);
					}
					else if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/06/2005 Paul.  Wrap all string fields in a SPAN tag to simplify regression testing. 
						HtmlGenericControl spnField = new HtmlGenericControl("span");
						tdField.Controls.Add(spnField);
						spnField.ID = sDATA_FIELD;

						Literal litField = new Literal();
						spnField.Controls.Add(litField);
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						litField.Visible = bLayoutMode || bIsReadable;
						try
						{
							if ( rdr != null )
							{
								// 06/30/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
								if ( rdr[sDATA_FIELD] == DBNull.Value )
								{
									if ( arrERASED_FIELDS.Contains(sDATA_FIELD) )
									{
										litField.Text = Sql.DataPrivacyErasedPill(L10n);
									}
								}
								else
								{
									string sDATA = Sql.ToString(rdr[sDATA_FIELD]);
									// 07/07/2007 Paul.  Emails may not have the proper \r\n terminators, so perform a few extra steps to ensure clean data. 
									// 06/04/2010 Paul.  Try and prevent excess blank lines. 
									sDATA = EmailUtils.NormalizeDescription(sDATA);
									litField.Text = sDATA;
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							litField.Text = ex.Message;
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "HyperLink", true) == 0 || String.Compare(sFIELD_TYPE, "ModuleLink", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) && (!Sql.IsEmptyString(sURL_FIELD) || String.Compare(sFIELD_TYPE, "ModuleLink", true) == 0) )
					{
						lnkField = new HyperLink();
						tdField.Controls.Add(lnkField);
						lnkField.Target   = sURL_TARGET;
						lnkField.CssClass = "tabDetailViewDFLink";
						// 03/16/2006 Paul.  Give the hyperlink a name so that it can be validated with SplendidTest. 
						lnkField.ID       = sDATA_FIELD;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						lnkField.Visible = bLayoutMode || bIsReadable;
						try
						{
							// 09/13/2018 Paul.  The literal must always be created, otherwise the postback with rdr == null will prevent any events from firing due to mismatched layouts. 
							Literal litField = new Literal();
							tdField.Controls.Add(litField);
							if ( bLayoutMode )
							{
								lnkField.Text    = sDATA_FIELD;
								lnkField.Enabled = false      ;
							}
							else if ( rdr != null )
							{
								if ( rdr[sDATA_FIELD] != DBNull.Value )
								{
									// 01/09/2006 Paul.  Allow DATA_FORMAT to be optional.   If missing, write data directly. 
									if ( Sql.IsEmptyString(sDATA_FORMAT) )
									{
										// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
										// 02/16/2010 Paul.  Move ToGuid to the function so that it can be captured if invalid. 
										// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
										if ( !Sql.IsEmptyString(sMODULE_TYPE) )
											lnkField.Text = HttpUtility.HtmlEncode(Crm.Modules.ItemName(Application, sMODULE_TYPE, rdr[sDATA_FIELD]));
										else
											lnkField.Text = HttpUtility.HtmlEncode(Sql.ToString(rdr[sDATA_FIELD]));
									}
									else
									{
										// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
										// 02/16/2010 Paul.  Move ToGuid to the function so that it can be captured if invalid. 
										// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
										if ( !Sql.IsEmptyString(sMODULE_TYPE) )
											lnkField.Text = String.Format(sDATA_FORMAT, HttpUtility.HtmlEncode(Crm.Modules.ItemName(Application, sMODULE_TYPE, rdr[sDATA_FIELD])));
										else
											lnkField.Text = String.Format(sDATA_FORMAT, HttpUtility.HtmlEncode(Sql.ToString(rdr[sDATA_FIELD])));
									}
								}
								else
								{
									// 06/30/2018 Paul.  Value may have been erased. If so, replace with Erased Value message. 
									lnkField.Visible = false;
									if ( arrERASED_FIELDS.Contains(sDATA_FIELD) )
									{
										litField.Text = Sql.DataPrivacyErasedPill(L10n);
									}
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							lnkField.Text = ex.Message;
						}
						try
						{
							if ( bLayoutMode )
							{
								lnkField.NavigateUrl = sURL_FIELD;
							}
							else if ( rdr != null )
							{
								// 03/19/2013 Paul.  URL_FIELD should support multiple fields. 
								string[] arrURL_FIELD = sURL_FIELD.Split(' ');
								object[] objURL_FIELD = new object[arrURL_FIELD.Length];
								for ( int i=0 ; i < arrURL_FIELD.Length; i++ )
								{
									if ( !Sql.IsEmptyString(arrURL_FIELD[i]) )
									{
										if ( rdr != null && rdr[arrURL_FIELD[i]] != DBNull.Value )
										{
											if ( rdr[arrURL_FIELD[i]].GetType() == Type.GetType("System.DateTime") )
												objURL_FIELD[i] = HttpUtility.UrlEncode(Sql.ToString(T10n.FromServerTime(rdr[arrURL_FIELD[i]])));
											else
											{
												// 04/08/2013 Paul.  Web site URLs should not be UrlEncoded as it will not be clickable. 
												string sURL_VALUE = Sql.ToString(rdr[arrURL_FIELD[i]]);
												if ( sURL_VALUE.Contains("://") )
													objURL_FIELD[i] = sURL_VALUE;
												else
													objURL_FIELD[i] = HttpUtility.UrlEncode(sURL_VALUE);
											}
										}
										else
											objURL_FIELD[i] = String.Empty;
									}
								}
								// 09/04/2010 Paul.  sURL_FIELD will be empty when used with a custom field. 
								if ( !Sql.IsEmptyString(sURL_FIELD) )
								{
									// 01/09/2006 Paul.  Allow DATA_FORMAT to be optional.   If missing, write data directly. 
									// 06/08/2012 Paul.  Check sURL_FORMAT instead of DATA_FORMAT. 
									if ( Sql.IsEmptyString(sURL_FORMAT) )
										lnkField.NavigateUrl = Sql.ToString(objURL_FIELD[0]);
									else
									{
										// 01/24/2019 Paul.  ~/Teams is not valid. 
										if ( sURL_FORMAT.Contains("~/Teams") )
										{
											sURL_FORMAT = sURL_FORMAT.Replace("~/Teams", "~/Administration/Teams");
										}
										lnkField.NavigateUrl = String.Format(sURL_FORMAT, objURL_FIELD);
									}
								}
								// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
								else if ( !Sql.IsEmptyString(sMODULE_TYPE) )
								{
									// 09/04/2010 Paul.  This should be a URL_FORMAT test. 
									if ( Sql.IsEmptyString(sURL_FORMAT) )
									{
										// 02/18/2010 Paul.  Get the Module Relative Path so that Project and Project Task will be properly handled. 
										// In these cases, the type is singular and the path is plural. 
										string sRELATIVE_PATH = Sql.ToString(Application["Modules." + sMODULE_TYPE + ".RelativePath"]);
										if ( Sql.IsEmptyString(sRELATIVE_PATH) )
											sRELATIVE_PATH = "~/" + sMODULE_TYPE + "/";
										// 08/30/2015 Paul.  sURL_FIELD will be empty for ModuleLink.  In that case we use sDATA_FIELD. 
										if ( String.Compare(sFIELD_TYPE, "ModuleLink", true) == 0 && Sql.IsEmptyString(sURL_FIELD) )
											lnkField.NavigateUrl = sRELATIVE_PATH + "view.aspx?ID=" + Sql.ToString(rdr[sDATA_FIELD]);
										else
											lnkField.NavigateUrl = sRELATIVE_PATH + "view.aspx?ID=" + Sql.ToString(objURL_FIELD[0]);
									}
									else
									{
										// 01/24/2019 Paul.  ~/Teams is not valid. 
										if ( sURL_FORMAT.Contains("~/Teams") )
										{
											sURL_FORMAT = sURL_FORMAT.Replace("~/Teams", "~/Administration/Teams");
										}
										lnkField.NavigateUrl = String.Format(sURL_FORMAT, objURL_FIELD);
									}
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							// 06/30/2018 Paul.  The error needs to be placed in the text field in order for it to be displayed. 
							lnkField.Text += " " + ex.Message;
						}
					}
				}
				// 11/23/2010 Paul.  Provide a link to the file. 
				else if ( String.Compare(sFIELD_TYPE, "File", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						lnkField = new HyperLink();
						lnkField.ID = sDATA_FIELD;
						lnkField.Visible = bLayoutMode || bIsReadable;
						try
						{
							if ( bLayoutMode )
							{
								Literal litField = new Literal();
								litField.Text = sDATA_FIELD;
								tdField.Controls.Add(litField);
							}
							else if ( rdr != null )
							{
								if ( !Sql.IsEmptyString(rdr[sDATA_FIELD]) )
								{
									lnkField.NavigateUrl = "~/Images/Image.aspx?ID=" + Sql.ToString(rdr[sDATA_FIELD]);
									// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
									lnkField.Text = HttpUtility.HtmlEncode(Crm.Modules.ItemName(Application, "Images", rdr[sDATA_FIELD]));
									tdField.Controls.Add(lnkField);
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							lnkField.Text = ex.Message;
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "Image", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Image imgField = new Image();
						// 04/13/2006 Paul.  Give the image a name so that it can be validated with SplendidTest. 
						imgField.ID = sDATA_FIELD;
						// 02/22/2022 Paul.  Allow image to be formatted. 
						if ( !Sql.IsEmptyString(sDATA_FORMAT) )
						{
							try
							{
								string[] arrDATA_FORMAT = sDATA_FORMAT.Split(';');
								for ( int i = 0; i < arrDATA_FORMAT.Length; i++ )
								{
									string[] arrNAME_VALUE = arrDATA_FORMAT[i].Split('=');
									if ( arrNAME_VALUE.Length == 2 )
									{
										string sNAME  = arrNAME_VALUE[0].Trim();
										string sVALUE = arrNAME_VALUE[1].Trim();
										if ( sNAME.ToLower() == "width" )
											imgField.Width = new Unit(sVALUE);
										else if ( sNAME.ToLower() == "height" )
											imgField.Width = new Unit(sVALUE);
									}
								}
							}
							catch
							{
								// 02/22/2022 Paul.  Ignore any errors. 
							}
						}
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						imgField.Visible = bLayoutMode || bIsReadable;
						try
						{
							if ( bLayoutMode )
							{
								Literal litField = new Literal();
								litField.Text = sDATA_FIELD;
								tdField.Controls.Add(litField);
							}
							else if ( rdr != null )
							{
								if ( !Sql.IsEmptyString(rdr[sDATA_FIELD]) )
								{
									imgField.ImageUrl = "~/Images/Image.aspx?ID=" + Sql.ToString(rdr[sDATA_FIELD]);
									// 04/13/2006 Paul.  Only add the image if it exists. 
									tdField.Controls.Add(imgField);
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							// 07/03/2014 Paul.  Add label to display error. 
							Label lblError = new Label();
							tdField.Controls.Add(lblError);
							lblError.Text = ex.Message;
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "IFrame", true) == 0 )
				{
					Literal litField = new Literal();
					litField.Visible = bLayoutMode || bIsReadable;
					tdField.Controls.Add(litField);
					try
					{
						string sIFRAME_SRC    = String.Empty;
						// 08/02/2010 Paul.  The iFrame height is stored in the URL Target field. 
						string sIFRAME_HEIGHT = sURL_TARGET;
						if ( Sql.IsEmptyString(sIFRAME_HEIGHT) )
							sIFRAME_HEIGHT = "200";
						if ( !Sql.IsEmptyString(sURL_FIELD) )
						{
							if ( bLayoutMode )
							{
								litField.Text = sURL_FIELD;
							}
							else if ( rdr != null )
							{
								string[] arrURL_FIELD = sURL_FIELD.Split(' ');
								object[] objURL_FIELD = new object[arrURL_FIELD.Length];
								for ( int i=0 ; i < arrURL_FIELD.Length; i++ )
								{
									if ( !Sql.IsEmptyString(arrURL_FIELD[i]) )
									{
										if ( rdr != null && rdr[arrURL_FIELD[i]] != DBNull.Value)
										{
											if ( rdr[arrURL_FIELD[i]].GetType() == Type.GetType("System.DateTime") )
												objURL_FIELD[i] = HttpUtility.UrlEncode(Sql.ToString(T10n.FromServerTime(rdr[arrURL_FIELD[i]])));
											else
												objURL_FIELD[i] = HttpUtility.UrlEncode(Sql.ToString(rdr[arrURL_FIELD[i]]));
										}
										else
											objURL_FIELD[i] = String.Empty;
									}
								}
								sIFRAME_SRC = String.Format(sURL_FORMAT, objURL_FIELD);
							}
						}
						else if ( !Sql.IsEmptyString(sDATA_FIELD) )
						{
							if ( bLayoutMode )
							{
								litField.Text = sDATA_FIELD;
							}
							else if ( rdr != null )
							{
								sIFRAME_SRC = Sql.ToString(rdr[sDATA_FIELD]);
							}
						}
						if ( !Sql.IsEmptyString(sIFRAME_SRC) )
							litField.Text = "<iframe src=\"" + sIFRAME_SRC + "\" height=\"" + sIFRAME_HEIGHT + "\" width=\"100%\"/></iframe>";
					}
					catch(Exception ex)
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						litField.Text = ex.Message;
					}
				}
				// 08/02/2010 Paul.  Create a seprate JavaScript field type. 
				else if ( String.Compare(sFIELD_TYPE, "JavaScript", true) == 0 )
				{
					Literal litField = new Literal();
					litField.Visible = bLayoutMode || bIsReadable;
					tdField.Controls.Add(litField);
					try
					{
						if ( bLayoutMode )
						{
							litField.Text = sURL_FIELD;
						}
						else if ( !Sql.IsEmptyString(sURL_FIELD) && !Sql.IsEmptyString(sURL_FORMAT) )
						{
							string[] arrURL_FIELD = sURL_FIELD.Split(' ');
							object[] objURL_FIELD = new object[arrURL_FIELD.Length];
							for ( int i=0 ; i < arrURL_FIELD.Length; i++ )
							{
								if ( !Sql.IsEmptyString(arrURL_FIELD[i]) )
								{
									// 07/26/2007 Paul.  Make sure to escape the javascript string. 
									if ( rdr[arrURL_FIELD[i]] != DBNull.Value )
										objURL_FIELD[i] = Sql.EscapeJavaScript(Sql.ToString(rdr[arrURL_FIELD[i]]));
									else
										objURL_FIELD[i] = String.Empty;
								}
							}
							// 12/03/2009 Paul.  LinkedIn Company Profile requires a span tag to insert the link.
							litField.Text = "&nbsp;<span id=\"" + String.Format(sURL_TARGET, objURL_FIELD) + "\"></span>";
							litField.Text += "<script type=\"text/javascript\"> " + String.Format(sURL_FORMAT, objURL_FIELD) + "</script>";
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						litField.Text = ex.Message;
					}
				}
				// 05/14/2016 Paul.  Add Tags module. 
				else if ( String.Compare(sFIELD_TYPE, "Tags", true) == 0 )
				{
					if ( bLayoutMode )
					{
						Literal litField = new Literal();
						litField.Text = sDATA_FIELD;
						tdField.Controls.Add(litField);
					}
					else if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						HtmlGenericControl spnField = new HtmlGenericControl("span");
						tdField.Controls.Add(spnField);
						spnField.ID = sDATA_FIELD;

						Literal litField = new Literal();
						spnField.Controls.Add(litField);
						litField.Visible = bLayoutMode || bIsReadable;
						try
						{
							if ( rdr != null )
							{
								string sDATA = Sql.ToString(rdr[sDATA_FIELD]);
								if ( !Sql.IsEmptyString(sDATA) )
								{
									sDATA = "<span class='Tags'>" + sDATA.Replace(",", "</span> <span class='Tags'>") + "</span>";
									litField.Text = sDATA;
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							litField.Text = ex.Message;
						}
					}
				}
				else
				{
					Literal litField = new Literal();
					tdField.Controls.Add(litField);
					litField.Text = "Unknown field type " + sFIELD_TYPE;
					// 01/07/2006 Paul.  Don't report the error in layout mode. 
					if ( !bLayoutMode )
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "Unknown field type " + sFIELD_TYPE);
				}
				// 12/02/2007 Paul.  Each view can now have its own number of data columns. 
				// This was needed so that search forms can have 4 data columns. The default is 2 columns. 
				if ( nCOLSPAN > 0 )
					nColIndex += nCOLSPAN;
				else if ( nCOLSPAN == 0 )
					nColIndex++;
				if ( nColIndex >= nDATA_COLUMNS )
					nColIndex = 0;
			}
			// 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
			if ( dvFields.Count > 0 && !bLayoutMode )
			{
				try
				{
					string sDETAIL_NAME = Sql.ToString(dvFields[0]["DETAIL_NAME"]);
					string sFORM_SCRIPT = Sql.ToString(dvFields[0]["SCRIPT"     ]);
					if ( !Sql.IsEmptyString(sFORM_SCRIPT) )
					{
						// 09/20/2012 Paul.  The base ID is not the ID of the parent, but the ID of the TemplateControl. 
						sFORM_SCRIPT = sFORM_SCRIPT.Replace("SPLENDID_DETAILVIEW_LAYOUT_ID", tbl.TemplateControl.ClientID);
						sFORM_SCRIPT = sFORM_SCRIPT.Trim();
						// 01/18/2018 Paul.  If wrapped, then treat FORM_SCRIPT as a function. 
						if ( sFORM_SCRIPT.StartsWith("(") && sFORM_SCRIPT.EndsWith(")") )
						{
							string sFormVar = tbl.TemplateControl.ClientID + "_FORM_SCRIPT";
							sFORM_SCRIPT = "var " + sFormVar + " = " + sFORM_SCRIPT + ";" + ControlChars.CrLf
							             + "if ( typeof(" + sFormVar + ") == 'function' )" + ControlChars.CrLf
							             + "{" + ControlChars.CrLf
							             + "	var fnFORM_SCRIPT = " + sFormVar + "();" + ControlChars.CrLf
							             + "	if ( fnFORM_SCRIPT !== undefined && typeof(fnFORM_SCRIPT.Initialize) == 'function' ) " + ControlChars.CrLf
							             + "	{" + ControlChars.CrLf
							//             + "		console.log('Executing form script Initialize function.');" + ControlChars.CrLf
							             + "		fnFORM_SCRIPT.Initialize();" + ControlChars.CrLf
							             + "	}" + ControlChars.CrLf
							             + "	else" + ControlChars.CrLf
							             + "	{" + ControlChars.CrLf
							//             + "		console.log('Executed form script as function.');" + ControlChars.CrLf
							             + "	}" + ControlChars.CrLf
							             + "}" + ControlChars.CrLf
							             + "else" + ControlChars.CrLf
							             + "{" + ControlChars.CrLf
							             + "	console.log('Form script not a function and will not be executed.');" + ControlChars.CrLf
							             + "}" + ControlChars.CrLf
							;
						}
						else
						{
							//sFORM_SCRIPT += ControlChars.CrLf + "console.log('Executing form script as raw script.');";
						}
						ScriptManager.RegisterStartupScript(tbl, typeof(System.String), sDETAIL_NAME.Replace(".", "_") + "_SCRIPT", sFORM_SCRIPT, true);
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
				}
			}
		}

		// 06/21/2009 Paul.  Automatically associate the TextBox with a Submit button. 
		public static void AppendEditViewFields(string sEDIT_NAME, HtmlTable tbl, DataRow rdr, L10N L10n, TimeZone T10n, string sSubmitClientID)
		{
			if ( tbl == null )
			{
				SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "HtmlTable is not defined for " + sEDIT_NAME);
				return;
			}
			// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
			DataTable dtFields = SplendidCache.EditViewFields(sEDIT_NAME, Security.PRIMARY_ROLE_NAME);
			AppendEditViewFields(dtFields.DefaultView, tbl, rdr, L10n, T10n, null, false, sSubmitClientID);
		}

		public static void AppendEditViewFields(string sEDIT_NAME, HtmlTable tbl, DataRow rdr, L10N L10n, TimeZone T10n)
		{
			if ( tbl == null )
			{
				SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "HtmlTable is not defined for " + sEDIT_NAME);
				return;
			}
			// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
			DataTable dtFields = SplendidCache.EditViewFields(sEDIT_NAME, Security.PRIMARY_ROLE_NAME);
			AppendEditViewFields(dtFields.DefaultView, tbl, rdr, L10n, T10n, null, false, String.Empty);
		}

		// 11/10/2010 Paul.  Apply Business Rules. 
		public static void ApplyEditViewRules(string sEDIT_NAME, SplendidControl parent, string sXOML_FIELD_NAME, DataRow row)
		{
			try
			{
				string sMODULE_NAME = sEDIT_NAME.Split('.')[0];
				// 05/10/2016 Paul.  The User Primary Role is used with role-based views. 
				DataTable dtFields = SplendidCache.EditViewRules(sEDIT_NAME, Security.PRIMARY_ROLE_NAME);
				if ( dtFields.Rows.Count > 0 )
				{
					string sXOML = Sql.ToString(dtFields.Rows[0][sXOML_FIELD_NAME]);
					if ( !Sql.IsEmptyString(sXOML) )
					{
						RuleSet rules = RulesUtil.Deserialize(sXOML);
						RuleValidation validation = new RuleValidation(typeof(SplendidControlThis), null);
						// 11/11/2010 Paul.  Validate so that we can get more information on a runtime error. 
						rules.Validate(validation);
						if ( validation.Errors.HasErrors )
						{
							throw(new Exception(RulesUtil.GetValidationErrors(validation)));
						}
						SplendidControlThis swThis = new SplendidControlThis(parent, sMODULE_NAME, row);
						RuleExecution exec = new RuleExecution(validation, swThis);
						rules.Execute(exec);
					}
				}
			}
			catch(Exception ex)
			{
				//SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				// 11/10/2010 Paul.  Throwing an exception will be the preferred method of displaying an error. 
				// We want to skip the filler message "The following error was encountered while executing method SplendidCRM.SplendidControlThis.Throw". 
				if ( ex.InnerException != null )
					throw(new Exception(ex.InnerException.Message));
				else
					throw(new Exception(ex.Message));
			}
		}

		public static void ApplyDetailViewRules(string sDETAIL_NAME, SplendidControl parent, string sXOML_FIELD_NAME, DataRow row)
		{
			try
			{
				string sMODULE_NAME = sDETAIL_NAME.Split('.')[0];
				// 05/10/2016 Paul.  The User Primary Role is used with role-based views. 
				DataTable dtFields = SplendidCache.DetailViewRules(sDETAIL_NAME, Security.PRIMARY_ROLE_NAME);
				if ( dtFields.Rows.Count > 0 )
				{
					string sXOML = Sql.ToString(dtFields.Rows[0][sXOML_FIELD_NAME]);
					if ( !Sql.IsEmptyString(sXOML) )
					{
						RuleSet rules = RulesUtil.Deserialize(sXOML);
						RuleValidation validation = new RuleValidation(typeof(SplendidControlThis), null);
						// 11/11/2010 Paul.  Validate so that we can get more information on a runtime error. 
						rules.Validate(validation);
						if ( validation.Errors.HasErrors )
						{
							throw(new Exception(RulesUtil.GetValidationErrors(validation)));
						}
						SplendidControlThis swThis = new SplendidControlThis(parent, sMODULE_NAME, row);
						RuleExecution exec = new RuleExecution(validation, swThis);
						rules.Execute(exec);
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
			}
		}
#endif

		// 11/22/2010 Paul.  For a ListView, it makes sense to allow a column to be added in a Pre Event and the column to be set in the Post Event. 
		public static void ApplyGridViewRules(string sGRID_NAME, SplendidControl parent, string sPRE_LOAD_XOML_FIELD_NAME, string sPOST_LOAD_XOML_FIELD_NAME, DataTable dt)
		{
			try
			{
				string sMODULE_NAME = sGRID_NAME.Split('.')[0];
				// 05/10/2016 Paul.  The User Primary Role is used with role-based views. 
				DataTable dtFields = SplendidCache.GridViewRules(sGRID_NAME, Security.PRIMARY_ROLE_NAME);
				if ( dtFields.Rows.Count > 0 )
				{
					string sXOML = Sql.ToString(dtFields.Rows[0][sPRE_LOAD_XOML_FIELD_NAME]);
					if ( !Sql.IsEmptyString(sXOML) )
					{
						RuleSet rules = RulesUtil.Deserialize(sXOML);
						RuleValidation validation = new RuleValidation(typeof(SplendidControlThis), null);
						// 11/11/2010 Paul.  Validate so that we can get more information on a runtime error. 
						rules.Validate(validation);
						if ( validation.Errors.HasErrors )
						{
							throw(new Exception(RulesUtil.GetValidationErrors(validation)));
						}
						SplendidControlThis swThis = new SplendidControlThis(parent, sMODULE_NAME, dt);
						RuleExecution exec = new RuleExecution(validation, swThis);
						rules.Execute(exec);
					}
					sXOML = Sql.ToString(dtFields.Rows[0][sPOST_LOAD_XOML_FIELD_NAME]);
					if ( !Sql.IsEmptyString(sXOML) )
					{
						RuleSet rules = RulesUtil.Deserialize(sXOML);
						RuleValidation validation = new RuleValidation(typeof(SplendidControlThis), null);
						// 11/11/2010 Paul.  Validate so that we can get more information on a runtime error. 
						rules.Validate(validation);
						if ( validation.Errors.HasErrors )
						{
							throw(new Exception(RulesUtil.GetValidationErrors(validation)));
						}
						foreach ( DataRow row in dt.Rows )
						{
							SplendidControlThis swThis = new SplendidControlThis(parent, sMODULE_NAME, row);
							RuleExecution exec = new RuleExecution(validation, swThis);
							rules.Execute(exec);
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
			}
		}

// 11/03/2021 Paul.  ASP.Net components are not needed. 
#if !ReactOnlyUI
		// 12/04/2010 Paul.  Add support for Business Rules Framework to Reports. 
		public static void ApplyReportRules(L10N L10n, Guid gPRE_LOAD_EVENT_ID, Guid gPOST_LOAD_EVENT_ID, DataTable dt)
		{
			if ( !Sql.IsEmptyGuid(gPRE_LOAD_EVENT_ID) )
			{
				DataTable dtFields = SplendidCache.ReportRules(gPRE_LOAD_EVENT_ID);
				if ( dtFields.Rows.Count > 0 )
				{
					string sMODULE_NAME = Sql.ToString(dtFields.Rows[0]["MODULE_NAME"]);
					string sXOML        = Sql.ToString(dtFields.Rows[0]["XOML"       ]);
					if ( !Sql.IsEmptyString(sXOML) )
					{
						RuleSet rules = RulesUtil.Deserialize(sXOML);
						RuleValidation validation = new RuleValidation(typeof(SplendidReportThis), null);
						// 11/11/2010 Paul.  Validate so that we can get more information on a runtime error. 
						rules.Validate(validation);
						if ( validation.Errors.HasErrors )
						{
							throw(new Exception(RulesUtil.GetValidationErrors(validation)));
						}
						SplendidReportThis swThis = new SplendidReportThis(HttpContext.Current.Application, L10n, sMODULE_NAME, dt);
						RuleExecution exec = new RuleExecution(validation, swThis);
						rules.Execute(exec);
					}
				}
			}
			if ( !Sql.IsEmptyGuid(gPOST_LOAD_EVENT_ID) )
			{
				DataTable dtFields = SplendidCache.ReportRules(gPOST_LOAD_EVENT_ID);
				if ( dtFields.Rows.Count > 0 )
				{
					string sMODULE_NAME = Sql.ToString(dtFields.Rows[0]["MODULE_NAME"]);
					string sXOML        = Sql.ToString(dtFields.Rows[0]["XOML"       ]);
					if ( !Sql.IsEmptyString(sXOML) )
					{
						RuleSet rules = RulesUtil.Deserialize(sXOML);
						RuleValidation validation = new RuleValidation(typeof(SplendidReportThis), null);
						// 11/11/2010 Paul.  Validate so that we can get more information on a runtime error. 
						rules.Validate(validation);
						if ( validation.Errors.HasErrors )
						{
							throw(new Exception(RulesUtil.GetValidationErrors(validation)));
						}
						foreach ( DataRow row in dt.Rows )
						{
							SplendidReportThis swThis = new SplendidReportThis(HttpContext.Current.Application, L10n, sMODULE_NAME, row);
							RuleExecution exec = new RuleExecution(validation, swThis);
							rules.Execute(exec);
						}
					}
				}
			}
		}

		// 08/08/2016 Paul.  Business Process validation needs to modify the layout. 
		public static void ValidateEditViewFields(string sEDIT_NAME, Control parent)
		{
			// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
			DataTable dtFields = SplendidCache.EditViewFields(sEDIT_NAME, Security.PRIMARY_ROLE_NAME);
			ValidateEditViewFields(dtFields, sEDIT_NAME, parent);
		}

		public static void ValidateEditViewFields(DataTable dtFields, string sEDIT_NAME, Control parent)
		{
			// 01/01/2008 Paul.  Pull config flag outside the loop. 
			bool bEnableTeamManagement  = Crm.Config.enable_team_management();
			bool bRequireTeamManagement = Crm.Config.require_team_management();
			bool bEnableDynamicTeams    = Crm.Config.enable_dynamic_teams();
			// 01/01/2008 Paul.  We need a quick way to require user assignments across the system. 
			bool bRequireUserAssignment = Crm.Config.require_user_assignment();
			// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			bool bEnableDynamicAssignment = Crm.Config.enable_dynamic_assignment();
			// 09/16/2018 Paul.  Create a multi-tenant system. 
			if ( Crm.Config.enable_multi_tenant_teams() )
			{
				bEnableTeamManagement    = false;
				bEnableDynamicTeams      = false;
				bEnableDynamicAssignment = false;
			}
			DataView dvFields = new DataView(dtFields);
			// 11/27/2006 Paul.  Make sure to include the TEAM_ID field since it does not use the UI_REQUIRED field. 
			// 01/01/2008 Paul.  Make sure to include the ASSIGNED_USER_ID field since it does not use the UI_REQUIRED field. 
			// 04/02/2008 Paul.  Include validated fields.
			dvFields.RowFilter = "UI_REQUIRED = 1 or UI_VALIDATOR = 1 or DATA_FIELD in ('TEAM_ID', 'TEAM_SET_NAME', 'ASSIGNED_USER_ID')";
			foreach(DataRowView row in dvFields)
			{
				string sFIELD_TYPE        = Sql.ToString (row["FIELD_TYPE"       ]);
				string sDATA_FIELD        = Sql.ToString (row["DATA_FIELD"       ]);
				// 08/28/2012 Paul.  DATA_FORMAT for TEAM_ID is 1 when we want to force ModulePopup. 
				string sDATA_FORMAT       = Sql.ToString (row["DATA_FORMAT"      ]);
				bool   bUI_REQUIRED       = Sql.ToBoolean(row["UI_REQUIRED"      ]);
				bool   bUI_VALIDATOR      = Sql.ToBoolean(row["UI_VALIDATOR"     ]);
				if ( sDATA_FIELD == "TEAM_ID" || sDATA_FIELD == "TEAM_SET_NAME" )
				{
					// 11/25/2006 Paul.  Override the required flag with the system value. 
					if ( !bEnableTeamManagement )
					{
						// 01/01/2008 Paul.  If Team Management is disabled, then we must disable the requirement. 
						bUI_REQUIRED = false;
					}
					else
					{
						// 09/21/2009 Paul.  The same conversion that happens in AppendEditViewFields must occur here. 
						// 08/28/2012 Paul.  DATA_FORMAT for TEAM_ID is 1 when we want to force ModulePopup. 
						// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
						if ( bEnableDynamicTeams && sDATA_FORMAT != "1" && !sDATA_FORMAT.ToLower().Contains("single") )
						{
							// 08/31/2009 Paul.  Don't convert to TeamSelect inside a Search view or Popup view. 
							if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".Popup") < 0 )
							{
								sDATA_FIELD     = "TEAM_SET_NAME";
								sFIELD_TYPE     = "TeamSelect";
							}
						}
						else
						{
							// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
							if ( sFIELD_TYPE == "TeamSelect" )
							{
								sDATA_FIELD     = "TEAM_ID";
								sFIELD_TYPE     = "ModulePopup";
							}
						}
						// 01/01/2008 Paul.  If Team Management is not required, then let the admin decide. 
						if ( bRequireTeamManagement )
							bUI_REQUIRED = true;
					}
				}
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				if ( sDATA_FIELD == "ASSIGNED_USER_ID" || sDATA_FIELD == "ASSIGNED_SET_NAME" )
				{
					// 11/30/2017 Paul.  DATA_FORMAT for USER_ID is 1 when we want to force ModulePopup. 
					// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
					if ( bEnableDynamicAssignment && !sDATA_FORMAT.ToLower().Contains("single") )
					{
						// 11/30/2017 Paul.  Don't convert to TeamSelect inside a Search view or Popup view. 
						if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".Popup") < 0 )
						{
							sDATA_FIELD     = "ASSIGNED_SET_NAME";
							sFIELD_TYPE     = "UserSelect";
						}
					}
					else
					{
						// 11/30/2017 Paul.  If the user manually adds a UserSelect, we need to convert to a ModulePopup. 
						if ( sFIELD_TYPE == "UserSelect" )
						{
							sDATA_FIELD     = "ASSIGNED_USER_ID";
							sFIELD_TYPE     = "ModulePopup";
						}
					}
					// 01/01/2008 Paul.  We need a quick way to require user assignments across the system. 
					if ( bRequireUserAssignment )
						bUI_REQUIRED = true;
				}
				if ( bUI_REQUIRED && !Sql.IsEmptyString(sDATA_FIELD) )
				{
					// 01/17/2018 Paul.  Add DATA_FORMAT to ListBox support force user selection. 
					if ( String.Compare(sFIELD_TYPE, "ListBox", true) == 0 && sDATA_FORMAT.ToLower().Contains("force") )
					{
						ListControl lstField = parent.FindControl(sDATA_FIELD) as ListControl;
						if ( lstField != null )
						{
							if ( lstField.Visible && Sql.IsEmptyString(lstField.SelectedValue) )
							{
								BaseValidator req = parent.FindControl(sDATA_FIELD + "_REQUIRED") as BaseValidator;
								if ( req != null )
								{
									req.Enabled = true;
									req.Validate();
								}
							}
						}
					}
					else if ( String.Compare(sFIELD_TYPE, "DateRange", true) == 0 )
					{
						// 12/17/2007 Paul.  We could use START and END as the date suffixes, but AFTER and BEFORE are not currently used in field names. 
						// 01/01/2018 Paul.  Allow searching of multiple date fields. 
						DatePicker ctlDateStart = parent.FindControl(sDATA_FIELD.Replace(" ", "_") + "_AFTER") as DatePicker;
						if ( ctlDateStart != null )
						{
							if ( ctlDateStart.Visible )
								ctlDateStart.Validate();
						}
						// 01/01/2018 Paul.  Allow searching of multiple date fields. 
						DatePicker ctlDateEnd = parent.FindControl(sDATA_FIELD.Replace(" ", "_") + "_BEFORE") as DatePicker;
						if ( ctlDateEnd != null )
						{
							if ( ctlDateEnd.Visible )
								ctlDateEnd.Validate();
						}
					}
					else if ( String.Compare(sFIELD_TYPE, "DatePicker", true) == 0 )
					{
						// 01/01/2018 Paul.  Allow searching of multiple date fields. 
						DatePicker ctlDate = parent.FindControl(sDATA_FIELD.Replace(" ", "_")) as DatePicker;
						if ( ctlDate != null )
						{
							// 03/04/2006 Paul.  Only visible controls are validated. 
							if ( ctlDate.Visible )
								ctlDate.Validate();
						}
					}
					else if ( String.Compare(sFIELD_TYPE, "DateTimePicker", true) == 0 )
					{
						DateTimePicker ctlDate = parent.FindControl(sDATA_FIELD) as DateTimePicker;
						if ( ctlDate != null )
						{
							// 03/04/2006 Paul.  Only visible controls are validated. 
							if ( ctlDate.Visible )
								ctlDate.Validate();
						}
					}
					else if ( String.Compare(sFIELD_TYPE, "DateTimeEdit", true) == 0 )
					{
						DateTimeEdit ctlDate = parent.FindControl(sDATA_FIELD) as DateTimeEdit;
						if ( ctlDate != null )
						{
							// 03/04/2006 Paul.  Only visible controls are validated. 
							if ( ctlDate.Visible )
								ctlDate.Validate();
						}
					}
					// 06/20/2009 Paul.  Add DateTimeNewRecord so that the NewRecord forms can use the Dynamic rendering. 
					else if ( String.Compare(sFIELD_TYPE, "DateTimeNewRecord", true) == 0 )
					{
						DateTimeEdit ctlDate = parent.FindControl(sDATA_FIELD) as DateTimeEdit;
						if ( ctlDate != null )
						{
							// 03/04/2006 Paul.  Only visible controls are validated. 
							if ( ctlDate.Visible )
								ctlDate.Validate();
						}
					}
					// 08/24/2009 Paul.  Add support for dynamic teams. 
					else if ( String.Compare(sFIELD_TYPE, "TeamSelect", true) == 0 )
					{
						TeamSelect ctlTeamSelect = parent.FindControl(sDATA_FIELD) as TeamSelect;
						if ( ctlTeamSelect != null )
						{
							if ( ctlTeamSelect.Visible )
								ctlTeamSelect.Validate();
						}
					}
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					else if ( String.Compare(sFIELD_TYPE, "UserSelect", true) == 0 )
					{
						UserSelect ctlUserSelect = parent.FindControl(sDATA_FIELD) as UserSelect;
						if ( ctlUserSelect != null )
						{
							if ( ctlUserSelect.Visible )
								ctlUserSelect.Validate();
						}
					}
					// 05/12/2016 Paul.  Add Tags module. 
					else if ( String.Compare(sFIELD_TYPE, "TagSelect", true) == 0 )
					{
						TagSelect ctlTagSelect = parent.FindControl(sDATA_FIELD) as TagSelect;
						if ( ctlTagSelect != null )
						{
							if ( ctlTagSelect.Visible )
								ctlTagSelect.Validate();
						}
					}
					// 06/07/2017 Paul.  Add NAICSCodes module. 
					else if ( String.Compare(sFIELD_TYPE, "NAICSCodeSelect", true) == 0 )
					{
						NAICSCodeSelect ctlNAICSCodeSelect = parent.FindControl(sDATA_FIELD) as NAICSCodeSelect;
						if ( ctlNAICSCodeSelect != null )
						{
							if ( ctlNAICSCodeSelect.Visible )
								ctlNAICSCodeSelect.Validate();
						}
					}
					// 10/21/2009 Paul.  Add support for KBTags. 
					else if ( String.Compare(sFIELD_TYPE, "KBTagSelect", true) == 0 )
					{
						KBTagSelect ctlKBTagSelect = parent.FindControl(sDATA_FIELD) as KBTagSelect;
						if ( ctlKBTagSelect != null )
						{
							if ( ctlKBTagSelect.Visible )
								ctlKBTagSelect.Validate();
						}
					}
					// 05/27/2016 Paul.  An existing file is means valid. 
					else if ( String.Compare(sFIELD_TYPE, "File", true) == 0 )
					{
						HtmlInputHidden ctlHidden = parent.FindControl(sDATA_FIELD) as HtmlInputHidden;
						if ( ctlHidden != null )
						{
							if ( !Sql.IsEmptyString(ctlHidden.Value) )
								continue;
						}
						Control ctl = parent.FindControl(sDATA_FIELD + "_File");
						if ( ctl != null )
						{
							// 03/04/2006 Paul.  Only visible controls are validated. 
							if ( ctl.Visible )
							{
								BaseValidator req = parent.FindControl(sDATA_FIELD + "_REQUIRED") as BaseValidator;
								if ( req != null )
								{
									// 01/16/2006 Paul.  Enable validator before validating page. 
									// If we leave the validator control enabled, then it may block an alternate action, like Cancel. 
									req.Enabled = true;
									req.Validate();
								}
							}
						}
					}
					else
					{
						Control ctl = parent.FindControl(sDATA_FIELD);
						if ( ctl != null )
						{
							// 03/04/2006 Paul.  Only visible controls are validated. 
							if ( ctl.Visible )
							{
								BaseValidator req = parent.FindControl(sDATA_FIELD + "_REQUIRED") as BaseValidator;
								if ( req != null )
								{
									// 01/16/2006 Paul.  Enable validator before validating page. 
									// If we leave the validator control enabled, then it may block an alternate action, like Cancel. 
									req.Enabled = true;
									req.Validate();
								}
							}
						}
					}
				}
				if ( bUI_VALIDATOR )
				{
					Control ctl = parent.FindControl(sDATA_FIELD);
					if ( ctl != null )
					{
						// 04/02/2008 Paul.  Only visible controls are validated. 
						if ( ctl.Visible )
						{
							BaseValidator req = parent.FindControl(sDATA_FIELD + "_VALIDATOR") as BaseValidator;
							if ( req != null )
							{
								// 04/02/2008 Paul.  Enable validator before validating page. 
								// If we leave the validator control enabled, then it may block an alternate action, like Cancel. 
								req.Enabled = true;
								req.Validate();
							}
						}
					}
				}
			}
		}
		/*
		// 01/16/2006 Paul.  If we disable the validator, it will hide it's error message. 
		// The solution may be to always require server-side validation (disable EnableClientScript).
		public static void DisableValidationEditViewFields(string sEDIT_NAME, Control parent)
		{
			// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
			DataTable dtFields = SplendidCache.EditViewFields(sEDIT_NAME, Security.PRIMARY_ROLE_NAME);
			DataView dvFields = new DataView(dtFields);
			dvFields.RowFilter = "UI_REQUIRED = 1";
			foreach(DataRowView row in dvFields)
			{
				string sFIELD_TYPE        = Sql.ToString (row["FIELD_TYPE"       ]);
				string sDATA_FIELD        = Sql.ToString (row["DATA_FIELD"       ]);
				bool   bUI_REQUIRED       = Sql.ToBoolean(row["UI_REQUIRED"      ]);
				if ( bUI_REQUIRED && !Sql.IsEmptyString(sDATA_FIELD) )
				{
					if ( String.Compare(sFIELD_TYPE, "DatePicker", true) == 0 )
					{
						DatePicker ctlDate = parent.FindControl(sDATA_FIELD) as DatePicker;
						if ( ctlDate != null )
							ctlDate.DisableValidation();
					}
					else if ( String.Compare(sFIELD_TYPE, "DateTimePicker", true) == 0 )
					{
						DateTimePicker ctlDate = parent.FindControl(sDATA_FIELD) as DateTimePicker;
						if ( ctlDate != null )
							ctlDate.DisableValidation();
					}
					else if ( String.Compare(sFIELD_TYPE, "DateTimeEdit", true) == 0 )
					{
						DateTimeEdit ctlDate = parent.FindControl(sDATA_FIELD) as DateTimeEdit;
						if ( ctlDate != null )
							ctlDate.DisableValidation();
					}
					else if ( String.Compare(sFIELD_TYPE, "DateTimeNewRecord", true) == 0 )
					{
						DateTimeEdit ctlDate = parent.FindControl(sDATA_FIELD) as DateTimeEdit;
						if ( ctlDate != null )
							ctlDate.DisableValidation();
					}
					else
					{
						BaseValidator req = parent.FindControl(sDATA_FIELD + "_REQUIRED") as BaseValidator;
						if ( req != null )
						{
							// 01/16/2006 Paul.  Enable validator before validating page. 
							// If we leave the validator control enabled, then it may block an alternate action, like Cancel. 
							req.Enabled = false;
						}
					}
				}
			}
		}
		*/

		public static void ListControl_DataBound_AllowNull(object sender, EventArgs e)
		{
			ListControl lst = sender as ListControl;
			if ( lst != null )
			{
				SplendidPage page = lst.Page as SplendidPage;
				if ( page != null )
				{
					L10N L10n = page.GetL10n();
					lst.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
				}
				else
				{
					lst.Items.Insert(0, new ListItem("", ""));
				}
			}
		}

		public class EditViewEventManager
		{
			ListControl lstPARENT_FIELD;
			ListControl lstField       ;
			bool        bUI_REQUIRED   ;
			int         nFORMAT_ROWS   ;
			// 01/17/2018 Paul.  Add DATA_FORMAT to ListBox support force user selection. 
			string      sDATA_FORMAT   ;
			L10N        L10n           ;

			public EditViewEventManager(ListControl lstPARENT_FIELD, ListControl lstField, bool bUI_REQUIRED, int nFORMAT_ROWS, string sDATA_FORMAT, L10N L10n)
			{
				this.lstPARENT_FIELD = lstPARENT_FIELD;
				this.lstField        = lstField       ;
				this.bUI_REQUIRED    = bUI_REQUIRED   ;
				this.nFORMAT_ROWS    = nFORMAT_ROWS   ;
				this.sDATA_FORMAT    = sDATA_FORMAT   ;
				this.L10n            = L10n           ;
			}
			
			public void SelectedIndexChanged(object sender, EventArgs e)
			{
				string sCACHE_NAME = String.Empty;
				if ( lstPARENT_FIELD.SelectedIndex >= 0 )
					sCACHE_NAME = lstPARENT_FIELD.SelectedValue;
				if ( !Sql.IsEmptyString(sCACHE_NAME) )
				{
					// 12/24/2007 Paul.  Use an array to define the custom caches so that list is in the Cache module. 
					// This should reduce the number of times that we have to edit the SplendidDynamic module. 
					// 02/16/2012 Paul.  Move custom cache logic to a method. 
					SplendidCache.SetListSource(sCACHE_NAME, lstField);
					lstField.DataBind();
					// 02/21/2006 Paul.  Move the NONE item inside the !IsPostBack code. 
					// 12/02/2007 Paul.  We don't need a NONE record when using multi-selection. 
					// 12/03/2007 Paul.  We do want the NONE record when using multi-selection. 
					// This will allow searching of fields that are null instead of using the unassigned only checkbox. 
					// 10/02/2010 Paul.  It does not seem logical to allow a NONE option on a multi-selection listbox. 
					// 11/02/2010 Paul.  We need a way to insert NONE into the a ListBox while still allowing multiple rows. 
					// The trick will be to use a negative number.  Use an absolute value here to reduce the areas to fix. 
					// 01/17/2018 Paul.  Add DATA_FORMAT to ListBox support force user selection. 
					if ( (!bUI_REQUIRED || sDATA_FORMAT.ToLower().Contains("force")) && nFORMAT_ROWS <= 0 )
					{
						lstField.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
						// 12/02/2007 Paul.  AppendEditViewFields should be called inside Page_Load when not a postback, 
						// and in InitializeComponent when it is a postback. If done wrong, 
						// the page will bind after the list is populated, causing the list to populate again. 
						// This event will cause the NONE entry to be cleared.  Add a handler to catch this problem, 
						// but the real solution is to call AppendEditViewFields at the appropriate times based on the postback event. 
						lstField.DataBound += new EventHandler(ListControl_DataBound_AllowNull);
					}
				}
				else
				{
					lstField.DataSource = null;
					lstField.DataBind();
				}
			}
		}

		public static void AppendEditViewFields(DataView dvFields, HtmlTable tbl, DataRow rdr, L10N L10n, TimeZone T10n, CommandEventHandler Page_Command, bool bLayoutMode, string sSubmitClientID)
		{
			bool bIsMobile = false;
			SplendidPage Page = tbl.Page as SplendidPage;
			if ( Page != null )
				bIsMobile = Page.IsMobile;
			// 06/21/2009 Paul.  We need the script manager to properly register EnterKey presses for text boxes. 
			ScriptManager mgrAjax = ScriptManager.GetCurrent(tbl.Page);
			// 11/23/2009 Paul.  SplendidCRM 4.0 is very slow on Blackberry devices.  Lets try and turn off AJAX AutoComplete. 
			bool bAjaxAutoComplete = (mgrAjax != null);
			// 12/07/2009 Paul.  The Opera Mini browser does not support popups. Use a DropdownList instead. 
			bool bSupportsPopups = true;
			if ( bIsMobile )
			{
				// 11/24/2010 Paul.  .NET 4 has broken the compatibility of the browser file system. 
				// We are going to minimize our reliance on browser files in order to reduce deployment issues. 
				bAjaxAutoComplete = Utils.AllowAutoComplete && (mgrAjax != null);
				bSupportsPopups = Utils.SupportsPopups;
			}
			// 07/28/2010 Paul.  Save AjaxAutoComplete and SupportsPopups for use in TeamSelect and KBSelect. 
			// We are having issues with the data binding event occurring before the page load. 
			Page.Items["AjaxAutoComplete"] = bAjaxAutoComplete;
			Page.Items["SupportsPopups"  ] = bSupportsPopups  ;
			// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
			bool bIsPostBack = tbl.Page.IsPostBack;
			bool bNotPostBack = false;
			if ( tbl.TemplateControl is SplendidControl )
			{
				bNotPostBack = (tbl.TemplateControl as SplendidControl).NotPostBack;
				bIsPostBack = tbl.Page.IsPostBack && !bNotPostBack;
			}

			HtmlTableRow tr = null;
			// 11/28/2005 Paul.  Start row index using the existing count so that headers can be specified. 
			int nRowIndex = tbl.Rows.Count - 1;
			int nColIndex = 0;
			HtmlTableCell tdLabel = null;
			HtmlTableCell tdField = null;
			// 01/07/2006 Paul.  Show table borders in layout mode. This will help distinguish blank lines from wrapped lines. 
			if ( bLayoutMode )
				tbl.Border = 1;
			// 11/15/2007 Paul.  If there are no fields in the detail view, then hide the entire table. 
			// This allows us to hide the table by removing all detail view fields. 
			// 09/12/2009 Paul.  There is no reason to hide the table when in layout mode. 
			if ( dvFields.Count == 0 && tbl.Rows.Count <= 1 && !bLayoutMode )
				tbl.Visible = false;

			// 01/27/2008 Paul.  We need the schema table to determine if the data label is free-form text. 
			// 03/21/2008 Paul.  We need to use a view to search for the rows for the ColumnName. 
			// 01/18/2010 Paul.  To apply ACL Field Security, we need to know if the current record has an ASSIGNED_USER_ID field, and its value. 
			Guid gASSIGNED_USER_ID = Guid.Empty;
			//DataView vwSchema = null;
			if ( rdr != null )
			{
				// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
				//vwSchema = new DataView(rdr.GetSchemaTable());
				//vwSchema.RowFilter = "ColumnName = 'ASSIGNED_USER_ID'";
				//if ( vwSchema.Count > 0 )
				if ( rdr.Table.Columns.Contains("ASSIGNED_USER_ID") )
				{
					gASSIGNED_USER_ID = Sql.ToGuid(rdr["ASSIGNED_USER_ID"]);
				}
			}

			// 01/01/2008 Paul.  Pull config flag outside the loop. 
			bool bEnableTeamManagement  = Crm.Config.enable_team_management();
			bool bRequireTeamManagement = Crm.Config.require_team_management();
			// 01/01/2008 Paul.  We need a quick way to require user assignments across the system. 
			bool bRequireUserAssignment = Crm.Config.require_user_assignment();
			// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			bool bEnableDynamicAssignment = Crm.Config.enable_dynamic_assignment();
			// 08/28/2009 Paul.  Allow dynamic teams to be turned off. 
			bool bEnableDynamicTeams   = Crm.Config.enable_dynamic_teams();
			// 09/16/2018 Paul.  Create a multi-tenant system. 
			if ( Crm.Config.enable_multi_tenant_teams() )
			{
				bEnableTeamManagement    = false;
				bEnableDynamicTeams      = false;
				bEnableDynamicAssignment = false;
			}
			HttpSessionState Session = HttpContext.Current.Session;
			HttpApplicationState Application = HttpContext.Current.Application;
			// 10/07/2010 Paul.  Convert the currency values before displaying. 
			// The UI culture should already be set to format the currency. 
			Currency C10n = HttpContext.Current.Items["C10n"] as Currency;
			// 05/08/2010 Paul.  Define the copy buttons outside the loop so that we can replace the javascript with embedded code. 
			// This is so that the javascript will run properly in the SixToolbar UpdatePanel. 
			HtmlInputButton btnCopyRight = null;
			HtmlInputButton btnCopyLeft  = null;
			// 09/13/2010 Paul.  We need to prevent duplicate names. 
			Hashtable hashLABEL_IDs = new Hashtable();
			bool bSupportsDraggable = Sql.ToBoolean(Session["SupportsDraggable"]);
			// 12/13/2013 Paul.  Allow each line item to have a separate tax rate. 
			bool bEnableTaxLineItems = Sql.ToBoolean(HttpContext.Current.Application["CONFIG.Orders.TaxLineItems"]);
			foreach(DataRowView row in dvFields)
			{
				string sEDIT_NAME         = Sql.ToString (row["EDIT_NAME"        ]);
				int    nFIELD_INDEX       = Sql.ToInteger(row["FIELD_INDEX"      ]);
				string sFIELD_TYPE        = Sql.ToString (row["FIELD_TYPE"       ]);
				string sDATA_LABEL        = Sql.ToString (row["DATA_LABEL"       ]);
				string sDATA_FIELD        = Sql.ToString (row["DATA_FIELD"       ]);
				// 01/19/2010 Paul.  We need to be able to format a Float field to prevent too many decimal places. 
				string sDATA_FORMAT       = Sql.ToString (row["DATA_FORMAT"      ]);
				string sDISPLAY_FIELD     = Sql.ToString (row["DISPLAY_FIELD"    ]);
				string sCACHE_NAME        = Sql.ToString (row["CACHE_NAME"       ]);
				bool   bDATA_REQUIRED     = Sql.ToBoolean(row["DATA_REQUIRED"    ]);
				bool   bUI_REQUIRED       = Sql.ToBoolean(row["UI_REQUIRED"      ]);
				string sONCLICK_SCRIPT    = Sql.ToString (row["ONCLICK_SCRIPT"   ]);
				string sFORMAT_SCRIPT     = Sql.ToString (row["FORMAT_SCRIPT"    ]);
				short  nFORMAT_TAB_INDEX  = Sql.ToShort  (row["FORMAT_TAB_INDEX" ]);
				int    nFORMAT_MAX_LENGTH = Sql.ToInteger(row["FORMAT_MAX_LENGTH"]);
				int    nFORMAT_SIZE       = Sql.ToInteger(row["FORMAT_SIZE"      ]);
				// 11/02/2010 Paul.  We need a way to insert NONE into the a ListBox while still allowing multiple rows. 
				// The trick will be to use a negative number.  Use an absolute value here to reduce the areas to fix. 
				int    nFORMAT_ROWS       = Math.Abs(Sql.ToInteger(row["FORMAT_ROWS"]));
				int    nFORMAT_COLUMNS    = Sql.ToInteger(row["FORMAT_COLUMNS"   ]);
				int    nCOLSPAN           = Sql.ToInteger(row["COLSPAN"          ]);
				int    nROWSPAN           = Sql.ToInteger(row["ROWSPAN"          ]);
				string LABEL_WIDTH       = Sql.ToString (row["LABEL_WIDTH"      ]);
				string sFIELD_WIDTH       = Sql.ToString (row["FIELD_WIDTH"      ]);
				int    nDATA_COLUMNS      = Sql.ToInteger(row["DATA_COLUMNS"     ]);
				// 05/17/2009 Paul.  Add support for a generic module popup. 
				string sMODULE_TYPE       = String.Empty;
				try
				{
					sMODULE_TYPE = Sql.ToString (row["MODULE_TYPE"]);
				}
				catch(Exception ex)
				{
					// 05/17/2009 Paul.  The MODULE_TYPE is not in the view, then log the error and continue. 
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
				}
				// 09/13/2010 Paul.  Add relationship fields. 
				bool   bVALID_RELATED                = false;
				string sRELATED_SOURCE_MODULE_NAME   = String.Empty;
				string sRELATED_SOURCE_VIEW_NAME     = String.Empty;
				string sRELATED_SOURCE_ID_FIELD      = String.Empty;
				string sRELATED_SOURCE_NAME_FIELD    = String.Empty;
				string sRELATED_VIEW_NAME            = String.Empty;
				string sRELATED_ID_FIELD             = String.Empty;
				string sRELATED_NAME_FIELD           = String.Empty;
				string sRELATED_JOIN_FIELD           = String.Empty;
				try
				{
					sRELATED_SOURCE_MODULE_NAME   = Sql.ToString (row["RELATED_SOURCE_MODULE_NAME"  ]);
					sRELATED_SOURCE_VIEW_NAME     = Sql.ToString (row["RELATED_SOURCE_VIEW_NAME"    ]);
					sRELATED_SOURCE_ID_FIELD      = Sql.ToString (row["RELATED_SOURCE_ID_FIELD"     ]);
					sRELATED_SOURCE_NAME_FIELD    = Sql.ToString (row["RELATED_SOURCE_NAME_FIELD"   ]);
					sRELATED_VIEW_NAME            = Sql.ToString (row["RELATED_VIEW_NAME"           ]);
					sRELATED_ID_FIELD             = Sql.ToString (row["RELATED_ID_FIELD"            ]);
					sRELATED_NAME_FIELD           = Sql.ToString (row["RELATED_NAME_FIELD"          ]);
					sRELATED_JOIN_FIELD           = Sql.ToString (row["RELATED_JOIN_FIELD"          ]);
					bVALID_RELATED =  !Sql.IsEmptyString(sRELATED_SOURCE_VIEW_NAME) && !Sql.IsEmptyString(sRELATED_SOURCE_ID_FIELD) && !Sql.IsEmptyString(sRELATED_SOURCE_NAME_FIELD) 
					               && !Sql.IsEmptyString(sRELATED_VIEW_NAME       ) && !Sql.IsEmptyString(sRELATED_ID_FIELD       ) && !Sql.IsEmptyString(sRELATED_NAME_FIELD       ) 
					               && !Sql.IsEmptyString(sRELATED_JOIN_FIELD      );
				}
				catch(Exception ex)
				{
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
				}
				// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
				string sPARENT_FIELD = String.Empty;
				try
				{
					sPARENT_FIELD = Sql.ToString (row["PARENT_FIELD"]);
				}
				catch(Exception ex)
				{
					// 05/17/2009 Paul.  The PARENT_FIELD is not in the view, then log the error and continue. 
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
				}

				// 04/02/2008 Paul.  Add support for Regular Expression validation. 
				string sFIELD_VALIDATOR_MESSAGE = Sql.ToString (row["FIELD_VALIDATOR_MESSAGE"]);
				string sVALIDATION_TYPE         = Sql.ToString (row["VALIDATION_TYPE"        ]);
				string sREGULAR_EXPRESSION      = Sql.ToString (row["REGULAR_EXPRESSION"     ]);
				string sDATA_TYPE               = Sql.ToString (row["DATA_TYPE"              ]);
				string sMININUM_VALUE           = Sql.ToString (row["MININUM_VALUE"          ]);
				string sMAXIMUM_VALUE           = Sql.ToString (row["MAXIMUM_VALUE"          ]);
				string sCOMPARE_OPERATOR        = Sql.ToString (row["COMPARE_OPERATOR"       ]);
				// 06/12/2009 Paul.  Add TOOL_TIP for help hover.
				string sTOOL_TIP                = String.Empty;
				try
				{
					sTOOL_TIP = Sql.ToString (row["TOOL_TIP"]);
				}
				catch(Exception ex)
				{
					// 06/12/2009 Paul.  The TOOL_TIP is not in the view, then log the error and continue. 
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
				}
				
				// 12/02/2007 Paul.  Each view can now have its own number of data columns. 
				// This was needed so that search forms can have 4 data columns. The default is 2 columns. 
				if ( nDATA_COLUMNS == 0 )
					nDATA_COLUMNS = 2;

				// 01/18/2010 Paul.  To apply ACL Field Security, we need to know if the Module Name, which we will extract from the EditView Name. 
				string sMODULE_NAME = String.Empty;
				string[] arrEDIT_NAME = sEDIT_NAME.Split('.');
				if ( arrEDIT_NAME.Length > 0 )
					sMODULE_NAME = arrEDIT_NAME[0];
				bool bIsReadable  = true;
				bool bIsWriteable = true;
				if ( SplendidInit.bEnableACLFieldSecurity )
				{
					Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, sDATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
					// 02/16/2011 Paul.  We should allow a Read-Only field to be searchable, so always allow writing if the name contains Search. 
					bIsWriteable = acl.IsWriteable() || sEDIT_NAME.Contains(".Search");
				}

				// 11/25/2006 Paul.  If Team Management has been disabled, then convert the field to a blank. 
				// Keep the field, but treat it as blank so that field indexes will still be valid. 
				// 12/03/2006 Paul.  Allow the team field to be visible during layout. 
				if ( !bLayoutMode && (sDATA_FIELD == "TEAM_ID" || sDATA_FIELD == "TEAM_SET_NAME") )
				{
					// 09/16/2018 Paul.  Create a multi-tenant system. 
					if ( Crm.Config.enable_multi_tenant_teams() )
					{
						sFIELD_TYPE  = "Hidden";
						sDATA_FIELD  = "TEAM_ID";
						bUI_REQUIRED = false;
					}
					else if ( !bEnableTeamManagement )
					{
						sFIELD_TYPE = "Blank";
						bUI_REQUIRED = false;
					}
					else
					{
						// 08/28/2012 Paul.  DATA_FORMAT for TEAM_ID is 1 when we want to force ModulePopup. 
						// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
						if ( bEnableDynamicTeams && sDATA_FORMAT != "1" && !sDATA_FORMAT.ToLower().Contains("single") )
						{
							// 08/31/2009 Paul.  Don't convert to TeamSelect inside a Search view or Popup view. 
							if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".Popup") < 0 )
							{
								sDATA_LABEL     = ".LBL_TEAM_SET_NAME";
								sDATA_FIELD     = "TEAM_SET_NAME";
								sFIELD_TYPE     = "TeamSelect";
								sONCLICK_SCRIPT = String.Empty;
							}
						}
						else
						{
							// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
							if ( sFIELD_TYPE == "TeamSelect" )
							{
								sDATA_LABEL     = "Teams.LBL_TEAM";
								sDATA_FIELD     = "TEAM_ID";
								sDISPLAY_FIELD  = "TEAM_NAME";
								sFIELD_TYPE     = "ModulePopup";
								sMODULE_TYPE    = "Teams";
								sONCLICK_SCRIPT = String.Empty;
							}
						}
						// 11/25/2006 Paul.  Override the required flag with the system value. 
						// 01/01/2008 Paul.  If Team Management is not required, then let the admin decide. 
						// 97/06/2017 Paul.  Don't show required flag in search or popup. 
						// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
						if ( bRequireTeamManagement && sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sEDIT_NAME.IndexOf(".Popup") < 0 )
							bUI_REQUIRED = true;
					}
				}
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				if ( !bLayoutMode && (sDATA_FIELD == "ASSIGNED_USER_ID" || sDATA_FIELD == "ASSIGNED_SET_NAME") )
				{
					// 11/30/2017 Paul.  DATA_FORMAT for USER_ID is 1 when we want to force ModulePopup. 
					// 05/06/2018 Paul.  Change to single instead of 1 to prevent auto-postback. 
					if ( bEnableDynamicAssignment && !sDATA_FORMAT.ToLower().Contains("single") )
					{
						// 11/30/2017 Paul.  Don't convert to UserSelect inside a Search view or Popup view. 
						if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".Popup") < 0 )
						{
							sDATA_LABEL     = ".LBL_ASSIGNED_SET_NAME";
							sDATA_FIELD     = "ASSIGNED_SET_NAME";
							sFIELD_TYPE     = "UserSelect";
							sONCLICK_SCRIPT = String.Empty;
						}
					}
					else
					{
						// 11/30/2017 Paul.  If the user manually adds a UserSelect, we need to convert to a ModulePopup. 
						if ( sFIELD_TYPE == "UserSelect" )
						{
							sDATA_LABEL     = ".LBL_ASSIGNED_TO";
							sDATA_FIELD     = "ASSIGNED_USER_ID";
							sDISPLAY_FIELD  = "ASSIGNED_TO_NAME";
							sFIELD_TYPE     = "ModulePopup";
							sMODULE_TYPE    = "Users";
							sONCLICK_SCRIPT = String.Empty;
						}
					}
					// 01/01/2008 Paul.  We need a quick way to require user assignments across the system. 
					if ( bRequireUserAssignment )
						bUI_REQUIRED = true;
				}
				// 12/13/2013 Paul.  Allow each product to have a default tax rate. 
				if ( !bLayoutMode && sDATA_FIELD == "TAX_CLASS" )
				{
					if ( bEnableTaxLineItems )
					{
						// 08/28/2009 Paul.  If dynamic teams are enabled, then always use the set name. 
						sDATA_LABEL = "ProductTemplates.LBL_TAXRATE_ID";
						sDATA_FIELD = "TAXRATE_ID";
						sCACHE_NAME = "TaxRates";
					}
				}
				// 04/04/2010 Paul.  Hide the Exchange Folder field if disabled for this module or user. 
				if ( !bLayoutMode && sDATA_FIELD == "EXCHANGE_FOLDER" )
				{
					if ( !Crm.Modules.ExchangeFolders(sMODULE_NAME) || !Security.HasExchangeAlias() )
					{
						sFIELD_TYPE = "Blank";
					}
				}
				if ( bIsMobile && String.Compare(sFIELD_TYPE, "AddressButtons", true) == 0 )
				{
					// 11/17/2007 Paul.  Skip the address buttons on a mobile device. 
					continue;
				}
				// 01/18/2010 Paul.  Clear the Required flag if the field is not writeable. 
				// Clearing at this stage will apply it to all edit types. 
				if ( bUI_REQUIRED && !bIsWriteable )
					bUI_REQUIRED = false;
				// 09/02/2012 Paul.  A separator will create a new table. We need to match the outer and inner layout. 
				if ( String.Compare(sFIELD_TYPE, "Separator", true) == 0 )
				{
					if ( tbl.Parent.Parent.Parent is System.Web.UI.WebControls.Table )
					{
						System.Web.UI.WebControls.Table tblOuter = new System.Web.UI.WebControls.Table();
						tblOuter.SkinID = "tabForm";
						tblOuter.Style.Add(HtmlTextWriterStyle.MarginTop, "5px");
						// 09/27/2012 Paul.  Separator can have an ID and can have a style so that it can be hidden. 
						if ( !Sql.IsEmptyString(sDATA_FIELD) )
							tblOuter.ID = sDATA_FIELD;
						if ( !Sql.IsEmptyString(sDATA_FORMAT) && !bLayoutMode )
							tblOuter.Style.Add(HtmlTextWriterStyle.Display, sDATA_FORMAT);
						int nParentIndex = tbl.Parent.Parent.Parent.Parent.Controls.IndexOf(tbl.Parent.Parent.Parent);
						tbl.Parent.Parent.Parent.Parent.Controls.AddAt(nParentIndex + 1, tblOuter);
						System.Web.UI.WebControls.TableRow trOuter = new System.Web.UI.WebControls.TableRow();
						tblOuter.Rows.Add(trOuter);
						System.Web.UI.WebControls.TableCell tdOuter = new System.Web.UI.WebControls.TableCell();
						trOuter.Cells.Add(tdOuter);
						System.Web.UI.HtmlControls.HtmlTable tblInner = new System.Web.UI.HtmlControls.HtmlTable();
						tblInner.Attributes.Add("class", "tabEditView");
						tdOuter.Controls.Add(tblInner);
						tbl = tblInner;
					
						nRowIndex = -1;
						nColIndex = 0;
						tdLabel = null;
						tdField = null;
						if ( bLayoutMode )
							tbl.Border = 1;
						else
							continue;
					}
				}
				// 11/17/2007 Paul.  On a mobile device, each new field is on a new row. 
				// 12/02/2005 Paul. COLSPAN == -1 means that a new column should not be created. 
				if ( (nCOLSPAN >= 0 && nColIndex == 0) || tr == null || bIsMobile )
				{
					// 11/25/2005 Paul.  Don't pre-create a row as we don't want a blank
					// row at the bottom.  Add rows just before they are needed. 
					nRowIndex++;
					tr = new HtmlTableRow();
					tbl.Rows.Insert(nRowIndex, tr);
				}
				// 06/04/2016 Paul.  We are going to use tdAction below. 
				HtmlTableCell tdAction = new HtmlTableCell();
				if ( bLayoutMode )
				{
					tr.Cells.Add(tdAction);
					tdAction.Attributes.Add("class", "tabDetailViewDL");
					tdAction.NoWrap = true;

					Literal litIndex = new Literal();
					tdAction.Controls.Add(litIndex);
					litIndex.Text = " " + nFIELD_INDEX.ToString() + " ";

					// 05/26/2007 Paul.  Fix the terms. The are in the Dropdown module. 
					// 08/24/2009 Paul.  Since this is the only area where we use the ID of the dynamic view record, only get it here. 
					Guid gID = Sql.ToGuid(row["ID"]);
					// 05/18/2013 Paul.  Add drag handle. 
					if ( bSupportsDraggable )
					{
						Image imgDragIcon = new Image();
						imgDragIcon.SkinID = "draghandle_table";
						imgDragIcon.Attributes.Add("draggable"  , "true");
						imgDragIcon.Attributes.Add("ondragstart", "event.dataTransfer.setData('Text', '" + nFIELD_INDEX.ToString() + "');");
						tdAction.Controls.Add(imgDragIcon);
						// 08/08/2013 Paul.  IE does not support preventDefault. 
						// http://stackoverflow.com/questions/1000597/event-preventdefault-function-not-working-in-ie
						tdAction.Attributes.Add("ondragover", "LayoutDragOver(event, '" + nFIELD_INDEX.ToString() + "')");
						tdAction.Attributes.Add("ondrop"    , "LayoutDropIndex(event, '" + nFIELD_INDEX.ToString() + "')");
					}
					else
					{
						ImageButton btnMoveUp   = CreateLayoutImageButtonSkin(gID, "Layout.MoveUp"  , nFIELD_INDEX, L10n.Term("Dropdown.LNK_UP"    ), "uparrow_inline"  , Page_Command);
						ImageButton btnMoveDown = CreateLayoutImageButtonSkin(gID, "Layout.MoveDown", nFIELD_INDEX, L10n.Term("Dropdown.LNK_DOWN"  ), "downarrow_inline", Page_Command);
						tdAction.Controls.Add(btnMoveUp  );
						tdAction.Controls.Add(btnMoveDown);
					}
					ImageButton btnInsert   = CreateLayoutImageButtonSkin(gID, "Layout.Insert"  , nFIELD_INDEX, L10n.Term("Dropdown.LNK_INS"   ), "plus_inline"     , Page_Command);
					ImageButton btnEdit     = CreateLayoutImageButtonSkin(gID, "Layout.Edit"    , nFIELD_INDEX, L10n.Term("Dropdown.LNK_EDIT"  ), "edit_inline"     , Page_Command);
					ImageButton btnDelete   = CreateLayoutImageButtonSkin(gID, "Layout.Delete"  , nFIELD_INDEX, L10n.Term("Dropdown.LNK_DELETE"), "delete_inline"   , Page_Command);
					tdAction.Controls.Add(btnInsert  );
					tdAction.Controls.Add(btnEdit    );
					tdAction.Controls.Add(btnDelete  );
				}
				// 12/03/2006 Paul.  Move literal label up so that it can be accessed when processing a blank. 
				// 01/02/2018 Paul.  Change from literal to label so that it can be changed in javascript. 
				Label litLabel = new Label();
				if ( !Sql.IsEmptyString(sDATA_FIELD) && !hashLABEL_IDs.Contains(sDATA_FIELD) )
				{
					litLabel.ID = sDATA_FIELD + "_LABEL";
					hashLABEL_IDs.Add(sDATA_FIELD, null);
				}
				// 06/20/2009 Paul.  The label and the field will be on separate rows for a NewRecord form. 
				HtmlTableRow trLabel = tr;
				HtmlTableRow trField = tr;
				if ( nCOLSPAN >= 0 || tdLabel == null || tdField == null )
				{
					// 05/28/2015 Paul.  The Seven theme has labels stacked above values. 
					if ( SplendidDynamic.StackedLayout(Page.Theme) )
					{
						tdLabel = new HtmlTableCell();
						tdField = tdLabel;
						trLabel.Cells.Add(tdLabel);
						// 06/20/2009 Paul.  Don't specify the normal styles for a NewRecord form. 
						// This is so that the label will be left aligned. 
						//tdLabel.Attributes.Add("class", "dataLabel");
						//tdLabel.VAlign = "top";
						//tdLabel.Width  = LABEL_WIDTH;
						tdField.Attributes.Add("class", "tabStackedEditViewDF");
						tdField.VAlign = "top";
						if ( nCOLSPAN > 0 )
						{
							tdField.ColSpan = (nCOLSPAN + 1) / 2;
							if ( bLayoutMode )
								tdField.ColSpan++;
						}
						// 11/28/2005 Paul.  Don't use the field width if COLSPAN is specified as we want it to take the rest of the table.  The label width will be sufficient. 
						//if ( nCOLSPAN == 0 && sFIELD_WIDTH != "0%" )
						//	tdField.Width  = sFIELD_WIDTH;
						
						// 05/28/2015 Paul.  Wrap the label in a div. 
						HtmlGenericControl span = new HtmlGenericControl("span");
						span.Attributes.Add("class", "tabStackedEditViewDL");
						tdLabel.Controls.Add(span);
						span.Controls.Add(litLabel);
					}
					else
					{
						tdLabel = new HtmlTableCell();
						tdField = new HtmlTableCell();
						trLabel.Cells.Add(tdLabel);
						if ( LABEL_WIDTH == "100%" && sFIELD_WIDTH == "0%" && nDATA_COLUMNS == 1 )
						{
							nRowIndex++;
							trField = new HtmlTableRow();
							tbl.Rows.Insert(nRowIndex, trField);
						}
						else
						{
							// 06/20/2009 Paul.  Don't specify the normal styles for a NewRecord form. 
							// This is so that the label will be left aligned. 
							tdLabel.Attributes.Add("class", "dataLabel");
							tdLabel.VAlign = "top";
							tdLabel.Width  = LABEL_WIDTH;
							tdField.Attributes.Add("class", "dataField");
							tdField.VAlign = "top";
						}
						trField.Cells.Add(tdField);
						if ( nCOLSPAN > 0 )
						{
							tdField.ColSpan = nCOLSPAN;
							if ( bLayoutMode )
								tdField.ColSpan++;
						}
						// 11/28/2005 Paul.  Don't use the field width if COLSPAN is specified as we want it to take the rest of the table.  The label width will be sufficient. 
						if ( nCOLSPAN == 0 && sFIELD_WIDTH != "0%" )
							tdField.Width  = sFIELD_WIDTH;

						tdLabel.Controls.Add(litLabel);
					}
					// 01/18/2010 Paul.  Apply ACL Field Security. 
					litLabel.Visible = bLayoutMode || bIsReadable;
					//litLabel.Text = nFIELD_INDEX.ToString() + " (" + nRowIndex.ToString() + "," + nColIndex.ToString() + ")";
					try
					{
						// 12/03/2006 Paul.  Move code to blank able in layout mode to blank section below. 
						if ( bLayoutMode )
							litLabel.Text = sDATA_LABEL;
						else if ( sDATA_LABEL.IndexOf(".") >= 0 )
							litLabel.Text = L10n.Term(sDATA_LABEL);
						else if ( !Sql.IsEmptyString(sDATA_LABEL) && rdr != null )
						{
							// 01/27/2008 Paul.  If the data label is not in the schema table, then it must be free-form text. 
							// It is not used often, but we allow the label to come from the result set.  For example,
							// when the parent is stored in the record, we need to pull the module name from the record. 
							litLabel.Text = sDATA_LABEL;
							// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
							if ( rdr != null )
							{
								//vwSchema.RowFilter = "ColumnName = '" + Sql.EscapeSQL(sDATA_LABEL) + "'";
								//if ( vwSchema.Count > 0 )
								if ( rdr.Table.Columns.Contains(sDATA_LABEL) )
									litLabel.Text = Sql.ToString(rdr[sDATA_LABEL]) + L10n.Term("Calls.LBL_COLON");
							}
						}
						// 07/15/2006 Paul.  Always put something for the label so that table borders will look right. 
						// 07/20/2007 Vandalo.  Skip the requirement to create a terminology entry and just so the label. 
						else
							litLabel.Text = sDATA_LABEL;  // "&nbsp;";
						// 05/28/2015 Paul.  The Seven theme has labels stacked above values. 
						if ( SplendidDynamic.StackedLayout(Page.Theme) && litLabel.Text.EndsWith(":") )
							litLabel.Text = litLabel.Text.Substring(0, litLabel.Text.Length - 1);

						// 06/12/2009 Paul.  Add Tool Tip hover. 
						// 11/23/2009 Paul.  Only add tool tip if AJAX is available and this is not a mobile device. 
						// 01/18/2010 Paul.  Only add tool tip if the label is visible. 
						if ( !bIsMobile && mgrAjax != null && !Sql.IsEmptyString(sTOOL_TIP) && !Sql.IsEmptyString(sDATA_FIELD) && litLabel.Visible )
						{
							Image imgToolTip = new Image();
							imgToolTip.SkinID = "tooltip_inline";
							// 07/06/2017 Paul.  IDs should not have spaces, but we do allow multiple data fields. 
							imgToolTip.ID     = sDATA_FIELD.Replace(" ", "_") + "_TOOLTIP_IMAGE";
							tdLabel.Controls.Add(imgToolTip);
							
							Panel pnlToolTip = new Panel();
							pnlToolTip.ID       = sDATA_FIELD.Replace(" ", "_") + "_TOOLTIP_PANEL";
							pnlToolTip.CssClass = "tooltip";
							tdLabel.Controls.Add(pnlToolTip);

							Literal litToolTip = new Literal();
							litToolTip.Text = sDATA_FIELD.Replace(" ", "_");
							pnlToolTip.Controls.Add(litToolTip);
							if ( bLayoutMode )
								litToolTip.Text = sTOOL_TIP;
							else if ( sTOOL_TIP.IndexOf(".") >= 0 )
								litToolTip.Text = L10n.Term(sTOOL_TIP);
							else
								litToolTip.Text = sTOOL_TIP;
							
							AjaxControlToolkit.HoverMenuExtender hovToolTip = new AjaxControlToolkit.HoverMenuExtender();
							hovToolTip.TargetControlID = imgToolTip.ID;
							hovToolTip.PopupControlID  = pnlToolTip.ID;
							hovToolTip.PopupPosition   = AjaxControlToolkit.HoverMenuPopupPosition.Right;
							hovToolTip.PopDelay        = 50;
							hovToolTip.OffsetX         = 0;
							hovToolTip.OffsetY         = 0;
							tdLabel.Controls.Add(hovToolTip);
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						litLabel.Text = ex.Message;
					}
					if ( !bLayoutMode && bUI_REQUIRED )
					{
						Label lblRequired = new Label();
						// 05/29/2015 Paul.  The litLabel will be inside a Span on the Seven theme. 
						if ( SplendidDynamic.StackedLayout(Page.Theme) && litLabel != null && litLabel.Parent != null )
							litLabel.Parent.Controls.Add(lblRequired);
						else
							tdLabel.Controls.Add(lblRequired);
						lblRequired.CssClass = "required";
						lblRequired.Text = L10n.Term(".LBL_REQUIRED_SYMBOL");
						// 01/31/2017 Paul.  Provide a way to hide the required symbol. 
						if ( !Sql.IsEmptyString(sDATA_FIELD) )
							lblRequired.ID = sDATA_FIELD + "_REQUIRED_SYMBOL";
					}
				}
				
				if ( String.Compare(sFIELD_TYPE, "Blank", true) == 0 )
				{
					// 06/20/2009 Paul.  There is no need for blank fields in a NewRecord form. 
					// By hiding them we are able to properly disable Team selection when Team Mangement is disabled. 
					if ( LABEL_WIDTH == "100%" && sFIELD_WIDTH == "0%" && nDATA_COLUMNS == 1 )
					{
						trLabel.Visible = false;
						trField.Visible = false;
					}
					else
					{
						Literal litField = new Literal();
						tdField.Controls.Add(litField);
						if ( bLayoutMode )
						{
							litLabel.Text = "*** BLANK ***";
							litField.Text = "*** BLANK ***";
						}
						else
						{
							// 12/03/2006 Paul.  Make sure to clear the label.  This is necessary to convert a TEAM to blank when disabled. 
							litLabel.Text = "&nbsp;";
							litField.Text = "&nbsp;";
						}
					}
				}
				// 09/03/2012 Paul.  A separator does nothing in Layout mode. 
				else if ( String.Compare(sFIELD_TYPE, "Separator", true) == 0 )
				{
					if ( bLayoutMode )
					{
						litLabel.Text = "*** SEPARATOR ***";
						nColIndex = nDATA_COLUMNS;
						tdField.ColSpan = 2 * nDATA_COLUMNS - 1;
						// 09/03/2012 Paul.  When in layout mode, we need to add a column for arrangement. 
						tdField.ColSpan++;
					}
				}
				// 09/02/2012 Paul.  A header is similar to a label, but without the data field. 
				else if ( String.Compare(sFIELD_TYPE, "Header", true) == 0 )
				{
					if ( !bLayoutMode )
						litLabel.Text = "<h4>" + litLabel.Text + "</h4>";
					tdLabel.ColSpan = 2;
					// 06/05/2015 Paul.  In the Seven theme, tdField == tdLabel and so we cannot hide it. 
					if ( tdField != tdLabel )
						tdField.Visible = false;
				}
				else if ( String.Compare(sFIELD_TYPE, "Label", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 05/23/2014 Paul.  Use a label instead of a literal so that the field can be accessed using HTML DOM. 
						Label litField = new Label();
						tdField.Controls.Add(litField);
						// 07/25/2006 Paul.  Align label values to the middle so the line-up with the label. 
						tdField.VAlign = "middle";
						// 07/24/2006 Paul.  Set the ID so that the literal control can be accessed. 
						litField.ID = sDATA_FIELD;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						// 10/07/2010 Paul.  We need to apply ACL on each part of the label. 
						//litField.Visible = bLayoutMode || bIsReadable;
						try
						{
							if ( bLayoutMode )
								litField.Text = sDATA_FIELD;
/*
							else if ( sDATA_FIELD.IndexOf(".") >= 0 )
								litField.Text = L10n.Term(sDATA_FIELD);
							else if ( rdr != null )
								litField.Text = Sql.ToString(rdr[sDATA_FIELD]);
*/
							// 10/07/2010 Paul.  Allow a label to contain multiple data entries. 
							else
							{
								string[] arrDATA_FIELD = sDATA_FIELD.Split(' ');
								object[] objDATA_FIELD = new object[arrDATA_FIELD.Length];
								for ( int i=0 ; i < arrDATA_FIELD.Length; i++ )
								{
									if ( arrDATA_FIELD[i].IndexOf(".") >= 0 )
									{
										objDATA_FIELD[i] = L10n.Term(arrDATA_FIELD[i]);
									}
									else if ( !Sql.IsEmptyString(arrDATA_FIELD[i]) )
									{
										bIsReadable = true;
										if ( SplendidInit.bEnableACLFieldSecurity )
										{
											Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, sDATA_FIELD, gASSIGNED_USER_ID);
											bIsReadable  = acl.IsReadable();
										}
										if ( bIsReadable && rdr != null && rdr[arrDATA_FIELD[i]] != DBNull.Value)
										{
											// 12/05/2005 Paul.  If the data is a DateTime field, then make sure to perform the timezone conversion. 
											if ( rdr[arrDATA_FIELD[i]].GetType() == Type.GetType("System.DateTime") )
												objDATA_FIELD[i] = T10n.FromServerTime(rdr[arrDATA_FIELD[i]]);
											// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
											// 02/16/2010 Paul.  Move ToGuid to the function so that it can be captured if invalid. 
											// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
											else if ( !Sql.IsEmptyString(sMODULE_TYPE) )
												objDATA_FIELD[i] = HttpUtility.HtmlEncode(Crm.Modules.ItemName(Application, sMODULE_TYPE, rdr[arrDATA_FIELD[i]]));
											// 06/26/2018 Paul.  Allow lookup of list term. 
											else if ( !Sql.IsEmptyString(sCACHE_NAME) )
												objDATA_FIELD[i] = L10n.Term("." + sCACHE_NAME + "." + Sql.ToString(rdr[arrDATA_FIELD[i]]));
											else if ( rdr[arrDATA_FIELD[i]].GetType() == typeof(System.String) )
												objDATA_FIELD[i] = HttpUtility.HtmlEncode(Sql.ToString(rdr[arrDATA_FIELD[i]]));
											else
												objDATA_FIELD[i] = rdr[arrDATA_FIELD[i]];
										}
										else
											objDATA_FIELD[i] = String.Empty;
									}
								}
								// 08/28/2012 Paul.  We do not need the record to display a label. 
								//if ( rdr != null )
								{
									// 10/07/2010 Paul.  There is a special case where we are show a date and a user name. 
									if ( arrDATA_FIELD.Length == 3 && objDATA_FIELD.Length == 3 && arrDATA_FIELD[1] == ".LBL_BY" && Sql.IsEmptyString(objDATA_FIELD[0]) && Sql.IsEmptyString(objDATA_FIELD[2]) )
										litField.Text = String.Empty;
									else
									// 01/09/2006 Paul.  Allow DATA_FORMAT to be optional.   If missing, write data directly. 
									if ( sDATA_FORMAT == String.Empty )
									{
										for ( int i=0; i < arrDATA_FIELD.Length; i++ )
											arrDATA_FIELD[i] = Sql.ToString(objDATA_FIELD[i]);
										litField.Text = String.Join(" ", arrDATA_FIELD);
									}
									else if ( sDATA_FORMAT == "{0:c}" && C10n != null )
									{
										// 03/30/2007 Paul.  Convert DetailView currencies on the fly. 
										// 05/05/2007 Paul.  In an earlier step, we convert NULLs to empty strings. 
										// Attempts to convert to decimal will generate an error: Input string was not in a correct format.
										if ( !(objDATA_FIELD[0] is string) )
										{
											Decimal d = C10n.ToCurrency(Convert.ToDecimal(objDATA_FIELD[0]));
											litField.Text = d.ToString("c");
										}
									}
									else
										litField.Text = String.Format(sDATA_FORMAT, objDATA_FIELD);
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							litField.Text = ex.Message;
						}
					}
				}
				// 09/13/2010 Paul.  Add relationship fields. 
				else if ( String.Compare(sFIELD_TYPE, "RelatedSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) && !Sql.IsEmptyString(sRELATED_SOURCE_MODULE_NAME) && bVALID_RELATED )
					{
						RelatedSelect ctlRelatedSelect = tbl.Page.LoadControl("~/_controls/RelatedSelect.ascx") as RelatedSelect;
						tdField.Controls.Add(ctlRelatedSelect);
						// 09/18/2010 Paul.  Using a "." in the ID caused major AJAX failures that were hard to debug. 
						//ctlRelatedSelect.ID                           = sRELATED_VIEW_NAME + "_" + sRELATED_ID_FIELD;
						// 10/14/2011 Paul.  We must use sDATA_FIELD as the ID until we can change UpdateCustomFields() to use the related ID. 
						ctlRelatedSelect.ID                           = sDATA_FIELD;
						ctlRelatedSelect.RELATED_SOURCE_MODULE_NAME   = sRELATED_SOURCE_MODULE_NAME  ;
						ctlRelatedSelect.RELATED_SOURCE_VIEW_NAME     = sRELATED_SOURCE_VIEW_NAME    ;
						ctlRelatedSelect.RELATED_SOURCE_ID_FIELD      = sRELATED_SOURCE_ID_FIELD     ;
						ctlRelatedSelect.RELATED_SOURCE_NAME_FIELD    = sRELATED_SOURCE_NAME_FIELD   ;
						ctlRelatedSelect.RELATED_VIEW_NAME            = sRELATED_VIEW_NAME           ;
						ctlRelatedSelect.RELATED_ID_FIELD             = sRELATED_ID_FIELD            ;
						ctlRelatedSelect.RELATED_NAME_FIELD           = sRELATED_NAME_FIELD          ;
						ctlRelatedSelect.RELATED_JOIN_FIELD           = sRELATED_JOIN_FIELD          ;

						ctlRelatedSelect.NotPostBack = bNotPostBack;
						ctlRelatedSelect.Visible  = bLayoutMode || bIsReadable;
						ctlRelatedSelect.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							Guid gPARENT_ID = Guid.Empty;
							if ( rdr != null )
							{
								try
								{
									gPARENT_ID = Sql.ToGuid(rdr[sDATA_FIELD]);
								}
								catch
								{
								}
							}
							ctlRelatedSelect.LoadLineItems(gPARENT_ID);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "RelatedListBox", true) == 0 || String.Compare(sFIELD_TYPE, "RelatedCheckBoxList", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) && bVALID_RELATED )
					{
						ListControl lstField = new RadioButtonList();
						if ( String.Compare(sFIELD_TYPE, "RelatedListBox", true) == 0 )
						{
							lstField = new ListBox();
							(lstField as ListBox).SelectionMode = ListSelectionMode.Multiple;
							(lstField as ListBox).Rows          = (nFORMAT_ROWS == 0) ? 6 : nFORMAT_ROWS;
							tdField.Controls.Add(lstField);
						}
						else if ( String.Compare(sFIELD_TYPE, "RelatedCheckBoxList", true) == 0 )
						{
							lstField = new CheckBoxList();
							lstField.CssClass = "checkbox";
							// 09/16/2010 Paul.  Put inside a div so that we can use auto-scroll. 
							if ( nFORMAT_ROWS > 0 )
							{
								HtmlGenericControl div = new HtmlGenericControl("div");
								div.Controls.Add(lstField);
								tdField.Controls.Add(div);
								div.Attributes.Add("style", "overflow-y: auto;height: " + nFORMAT_ROWS.ToString() + "px");
							}
							else
							{
								tdField.Controls.Add(lstField);
							}
						}
						else
						{
							lstField.CssClass = "radio";
							// 09/16/2010 Paul.  Put inside a div so that we can use auto-scroll. 
							if ( nFORMAT_ROWS > 0 )
							{
								HtmlGenericControl div = new HtmlGenericControl("div");
								div.Controls.Add(lstField);
								tdField.Controls.Add(div);
								div.Attributes.Add("style", "overflow-y: auto;height: " + nFORMAT_ROWS.ToString() + "px");
							}
							else
							{
								tdField.Controls.Add(lstField);
							}
						}
						// 09/13/2010 Paul.  We should not use the sDATA_FIELD as it might be identical for multiple RelatedListBox.  For example, it could be the ID of the record. 
						// 09/18/2010 Paul.  Using a "." in the ID caused major AJAX failures that were hard to debug. 
						//lstField.ID            = sRELATED_VIEW_NAME + "_" + sRELATED_ID_FIELD;// sDATA_FIELD;
						// 10/14/2011 Paul.  We must use sDATA_FIELD as the ID until we can change UpdateCustomFields() to use the related ID. 
						lstField.ID            = sDATA_FIELD;
						lstField.TabIndex      = nFORMAT_TAB_INDEX;
						lstField.Visible       = bLayoutMode || bIsReadable;
						lstField.Enabled       = bLayoutMode || bIsWriteable;
						try
						{
							// 09/13/2010 Paul.  As extra precaution, make sure that the table name is valid. 
							Regex r = new Regex(@"[^A-Za-z0-9_]");
							sRELATED_SOURCE_VIEW_NAME     = r.Replace(sRELATED_SOURCE_VIEW_NAME    , "");
							sRELATED_SOURCE_ID_FIELD      = r.Replace(sRELATED_SOURCE_ID_FIELD     , "");
							sRELATED_SOURCE_NAME_FIELD    = r.Replace(sRELATED_SOURCE_NAME_FIELD   , "");
							sRELATED_VIEW_NAME            = r.Replace(sRELATED_VIEW_NAME           , "");
							sRELATED_ID_FIELD             = r.Replace(sRELATED_ID_FIELD            , "");
							sRELATED_NAME_FIELD           = r.Replace(sRELATED_NAME_FIELD          , "");
							sRELATED_JOIN_FIELD           = r.Replace(sRELATED_JOIN_FIELD          , "");

							// 09/13/2010 Paul.  Add relationship fields, Don't populate list if this is a post back. 
							if ( (bLayoutMode || !bIsPostBack) )
							{
								lstField.DataValueField = sRELATED_SOURCE_ID_FIELD  ;
								lstField.DataTextField  = sRELATED_SOURCE_NAME_FIELD;
								DbProviderFactory dbf = DbProviderFactories.GetFactory();
								using ( IDbConnection con = dbf.CreateConnection() )
								{
									con.Open();
									string sSQL;
									sSQL = "select " + sRELATED_SOURCE_ID_FIELD      + ControlChars.CrLf
									     + "     , " + sRELATED_SOURCE_NAME_FIELD    + ControlChars.CrLf
									     + "  from " + sRELATED_SOURCE_VIEW_NAME     + ControlChars.CrLf
									     + " order by " + sRELATED_SOURCE_NAME_FIELD + ControlChars.CrLf;
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.CommandText = sSQL;
										// 09/13/2010 Paul.  When in layout mode, only fetch 10 records. 
										if ( bLayoutMode )
											Sql.LimitResults(cmd, 10);
										using ( DbDataAdapter da = dbf.CreateDataAdapter() )
										{
											((IDbDataAdapter)da).SelectCommand = cmd;
											DataTable dt = new DataTable();
											da.Fill(dt);
											lstField.DataSource = dt;
											lstField.DataBind();
										}
									}
								}
								if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
									lstField.Attributes.Add("onchange" , sONCLICK_SCRIPT);
								// 10/02/2010 Paul.  None does not seem appropriate for related data. 
								/*
								if ( !bUI_REQUIRED )
								{
									lstField.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
									lstField.DataBound += new EventHandler(ListControl_DataBound_AllowNull);
								}
								*/
							}
							if ( rdr != null )
							{
								try
								{
									// 10/14/2011 Paul.  When settings values, there does not seem to be a good reason to do another database lookup. 
									// The lstField binding means that the values are there. 
									if ( rdr[sDATA_FIELD].GetType() == typeof(Guid) )
									{
										string sVALUE = Sql.ToGuid(rdr[sDATA_FIELD]).ToString();
										foreach ( ListItem item in lstField.Items )
										{
											if ( item.Value == sVALUE )
												item.Selected = true;
										}
									}
									else
									{
										List<string> arrVALUE = new List<string>();
										// 10/14/2011 Paul.  If this is a multi-selection, then we need to get the list if values. 
										string sVALUE = Sql.ToString(rdr[sDATA_FIELD]);
										if ( sVALUE.StartsWith("<?xml") )
										{
											XmlDocument xml = new XmlDocument();
											// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
											// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
											// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
											xml.XmlResolver = null;
											xml.LoadXml(sVALUE);
											XmlNodeList nlValues = xml.DocumentElement.SelectNodes("Value");
											foreach ( XmlNode xValue in nlValues )
											{
												foreach ( ListItem item in lstField.Items )
												{
													if ( item.Value == xValue.InnerText )
														item.Selected = true;
												}
											}
										}
										else
										{
											foreach ( ListItem item in lstField.Items )
											{
												if ( item.Value == sVALUE )
													item.Selected = true;
											}
										}
									}
								}
								catch(Exception ex)
								{
									SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
								}
							}
							// 12/04/2005 Paul.  Assigned To field will always default to the current user. 
							else if ( rdr == null && !bIsPostBack && sCACHE_NAME == "AssignedUser")
							{
								try
								{
									// 12/02/2007 Paul.  We don't default the user when using multi-selection.  
									// This is because this mode is typically used for searching. 
									if ( nFORMAT_ROWS == 0 )
										// 08/19/2010 Paul.  Check the list before assigning the value. 
										Utils.SetValue(lstField, Security.USER_ID.ToString());
								}
								catch(Exception ex)
								{
									SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "ListBox", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/02/2007 Paul.  If format rows > 0 then this is a list box and not a drop down list. 
						ListControl lstField = null;
						if ( nFORMAT_ROWS > 0 )
						{
							ListBox lb = new ListBox();
							lb.SelectionMode = ListSelectionMode.Multiple;
							lb.Rows          = nFORMAT_ROWS;
							lstField = lb;
						}
						else
						{
							// 04/25/2008 Paul.  Use KeySortDropDownList instead of ListSearchExtender. 
							lstField = new KeySortDropDownList();
							// 07/26/2010 Paul.  Lets try the latest version of the ListSearchExtender. 
							// 07/28/2010 Paul.  We are getting an undefined exception on the Accounts List Advanced page. 
							// Lets drop back to using KeySort. 
							//lstField = new DropDownList();
						}
						tdField.Controls.Add(lstField);
						lstField.ID       = sDATA_FIELD;
						lstField.TabIndex = nFORMAT_TAB_INDEX;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						lstField.Visible  = bLayoutMode || bIsReadable;
						lstField.Enabled  = bLayoutMode || bIsWriteable;
						// 07/23/2010 Paul.  Lets try the latest version of the ListSearchExtender. 
						// 07/28/2010 Paul.  We are getting an undefined exception on the Accounts List Advanced page. 
						/*
						if ( nFORMAT_ROWS == 0 )
						{
							// 04/25/2008 Paul.  Add AJAX searching of list. 
							// The extender only looks good on dropdowns. 
							// 04/25/2008 Paul.  ListSearchExtender needs work.  I don't like the delay when a list is selected
							// and there are problems when the browser window is scrolled.  KeySortDropDownList is a better solution. 
							AjaxControlToolkit.ListSearchExtender extField = new AjaxControlToolkit.ListSearchExtender();
							extField.ID              = lstField.ID + "_ListSearchExtender";
							extField.TargetControlID = lstField.ID;
							extField.PromptText      = L10n.Term(".LBL_TYPE_TO_SEARCH");
							extField.PromptCssClass  = "ListSearchExtenderPrompt";
							tdField.Controls.Add(extField);
						}
						*/
						// 01/06/2018 Paul.  Add DATA_FORMAT to ListBox support multi-select CSV. 
						if ( nFORMAT_ROWS > 0 && sDATA_FORMAT.ToLower().Contains("csv") )
						{
							// 01/17/2018 Paul.  multiple-select is failing on postback, so always include. 
							//ScriptReference sr = new ScriptReference ("~/html5/jQuery/multiple-select.js");
							//if ( !mgrAjax.Scripts.Contains(sr) )
							//{
							//	mgrAjax.Scripts.Add(sr);
							//	HtmlLink css = new HtmlLink();
							//	css.Attributes.Add("href" , "~/html5/jQuery/multiple-select.css");
							//	css.Attributes.Add("type" , "text/css"  );
							//	css.Attributes.Add("rel"  , "stylesheet");
							//	Page.Header.Controls.Add(css);
							//}
							// 01/06/2018 Paul.  Use the class name to distinguish if this is multiple-select 
							lstField.CssClass = "multiple-select";
							string sALL_SELECTED   = L10n.Term(".LBL_ALL_SELECTED"  );
							string sCOUNT_SELECTED = L10n.Term(".LBL_COUNT_SELECTED");
							ScriptManager.RegisterStartupScript(Page, typeof(System.String), lstField.ClientID, "$('#" + lstField.ClientID + "').multipleSelect({selectAll: false, width: '75%', minimumCountSelected: 10, allSelected: '" + Sql.EscapeJavaScript(sALL_SELECTED) + "', countSelected: '" + Sql.EscapeJavaScript(sCOUNT_SELECTED) + "'});", true);
						}
						try
						{
							// 10/09/2010 Paul.  Add PARENT_FIELD so that we can establish dependent listboxes. 
							if ( !Sql.IsEmptyString(sPARENT_FIELD) )
							{
								ListControl lstPARENT_FIELD = tbl.FindControl(sPARENT_FIELD) as ListControl;
								if ( lstPARENT_FIELD != null )
								{
									lstPARENT_FIELD.AutoPostBack = true;
									// 11/02/2010 Paul.  We need a way to insert NONE into the a ListBox while still allowing multiple rows. 
									// The trick will be to use a negative number.  Use an absolute value here to reduce the areas to fix. 
									// 01/17/2018 Paul.  Add DATA_FORMAT to ListBox support force user selection. 
									EditViewEventManager mgr = new EditViewEventManager(lstPARENT_FIELD, lstField, bUI_REQUIRED, Sql.ToInteger(row["FORMAT_ROWS"]), sDATA_FORMAT, L10n);
									lstPARENT_FIELD.SelectedIndexChanged += new EventHandler(mgr.SelectedIndexChanged);
									if ( !bIsPostBack && lstPARENT_FIELD.SelectedIndex >= 0 )
									{
										sCACHE_NAME = lstPARENT_FIELD.SelectedValue;
									}
								}
							}
							// 12/04/2005 Paul.  Don't populate list if this is a post back. 
							if ( !Sql.IsEmptyString(sCACHE_NAME) && (bLayoutMode || !bIsPostBack) )
							{
								// 12/24/2007 Paul.  Use an array to define the custom caches so that list is in the Cache module. 
								// This should reduce the number of times that we have to edit the SplendidDynamic module. 
								// 02/16/2012 Paul.  Move custom cache logic to a method. 
								SplendidCache.SetListSource(sCACHE_NAME, lstField);
								lstField.DataBind();
								// 08/08/2006 Paul.  Allow onchange code to be stored in the database.  
								// ListBoxes do not have a useful onclick event, so there should be no problem overloading this field. 
								if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
									lstField.Attributes.Add("onchange" , sONCLICK_SCRIPT);
								// 02/21/2006 Paul.  Move the NONE item inside the !IsPostBack code. 
								// 12/02/2007 Paul.  We don't need a NONE record when using multi-selection. 
								// 12/03/2007 Paul.  We do want the NONE record when using multi-selection. 
								// This will allow searching of fields that are null instead of using the unassigned only checkbox. 
								// 10/02/2010 Paul.  It does not seem logical to allow a NONE option on a multi-selection listbox. 
								// 11/02/2010 Paul.  We need a way to insert NONE into the a ListBox while still allowing multiple rows. 
								// The trick will be to use a negative number.  Use an absolute value here to reduce the areas to fix. 
								// 01/17/2018 Paul.  Add DATA_FORMAT to ListBox support force user selection. 
								if ( (!bUI_REQUIRED || sDATA_FORMAT.ToLower().Contains("force")) && Sql.ToInteger(row["FORMAT_ROWS"]) <= 0 )
								{
									// 01/08/2018 Paul.  Some lists have the first entry as a blank. 
									if ( !(lstField.Items.Count > 0 && Sql.IsEmptyString(lstField.Items[0].Value)) )
										lstField.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
									// 12/02/2007 Paul.  AppendEditViewFields should be called inside Page_Load when not a postback, 
									// and in InitializeComponent when it is a postback. If done wrong, 
									// the page will bind after the list is populated, causing the list to populate again. 
									// This event will cause the NONE entry to be cleared.  Add a handler to catch this problem, 
									// but the real solution is to call AppendEditViewFields at the appropriate times based on the postback event. 
									lstField.DataBound += new EventHandler(ListControl_DataBound_AllowNull);
								}
								// 01/20/2010 Paul.  Set the default value for Currencies. 
								if ( !bLayoutMode && rdr == null && !bIsPostBack && sCACHE_NAME == "Currencies" )
								{
									try
									{
										Guid gCURRENCY_ID = Sql.ToGuid(HttpContext.Current.Session["USER_SETTINGS/CURRENCY"]);
										// 08/19/2010 Paul.  Check the list before assigning the value. 
										Utils.SetValue(lstField, gCURRENCY_ID.ToString());
									}
									catch
									{
									}
								}
							}
							if ( rdr != null )
							{
								try
								{
									// 02/21/2006 Paul.  All the DropDownLists in the Calls and Meetings edit views were not getting set.  
									// The problem was a Page.DataBind in the SchedulingGrid and in the InviteesView. Both binds needed to be removed. 
									// 12/30/2007 Paul.  A customer needed the ability to save and restore the multiple selection. 
									// 12/30/2007 Paul.  Require the XML declaration in the data before trying to treat as XML. 
									string sVALUE = Sql.ToString(rdr[sDATA_FIELD]);
									if ( nFORMAT_ROWS > 0 && sVALUE.StartsWith("<?xml") )
									{
										XmlDocument xml = new XmlDocument();
										// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
										// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
										// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
										xml.XmlResolver = null;
										xml.LoadXml(sVALUE);
										XmlNodeList nlValues = xml.DocumentElement.SelectNodes("Value");
										foreach ( XmlNode xValue in nlValues )
										{
											foreach ( ListItem item in lstField.Items )
											{
												if ( item.Value == xValue.InnerText )
													item.Selected = true;
											}
										}
									}
									// 01/06/2018 Paul.  Add DATA_FORMAT to ListBox support multi-select CSV. 
									else if ( nFORMAT_ROWS > 0 && sDATA_FORMAT.ToLower().Contains("csv") )
									{
										string[] nlValues = sVALUE.Split(',');
										ListBox lb = lstField as ListBox;
										if ( lb != null )
										{
											foreach ( string xValue in nlValues )
											{
												Utils.SelectItem(lb, xValue);
											}
										}
									}
									else
									{
										// 08/19/2010 Paul.  Check the list before assigning the value. 
										// 11/14/2014 Paul.  If the item is not in the list, then add it. 
										bool bFound = Utils.SetValue(lstField, sVALUE);
										// 06/26/2018 Paul.  We don't add the missing if this is a multi-select.  We don't want to put an empty item at the top. 
										if ( !bFound && !(Sql.IsEmptyString(sVALUE) && nFORMAT_ROWS > 0) )
											lstField.Items.Insert(0, new ListItem(sVALUE, sVALUE));
									}
								}
								catch(Exception ex)
								{
									SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
								}
							}
							// 12/04/2005 Paul.  Assigned To field will always default to the current user. 
							else if ( rdr == null && !bIsPostBack && sCACHE_NAME == "AssignedUser")
							{
								try
								{
									// 12/02/2007 Paul.  We don't default the user when using multi-selection.  
									// This is because this mode is typically used for searching. 
									if ( nFORMAT_ROWS == 0 )
										// 08/19/2010 Paul.  Check the list before assigning the value. 
										Utils.SetValue(lstField, Security.USER_ID.ToString());
								}
								catch(Exception ex)
								{
									SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
								}
							}
							// 01/17/2018 Paul.  Add DATA_FORMAT to ListBox support force user selection. 
							if ( bUI_REQUIRED && sDATA_FORMAT.ToLower().Contains("force") )
							{
								RequiredFieldValidatorForDropDownList reqID = new RequiredFieldValidatorForDropDownList();
								reqID.ID                 = sDATA_FIELD + "_REQUIRED";
								reqID.ControlToValidate  = lstField.ID;
								reqID.ErrorMessage       = L10n.Term(".ERR_REQUIRED_FIELD");
								reqID.CssClass           = "required";
								reqID.EnableViewState    = false;
								reqID.EnableClientScript = false;
								reqID.Enabled            = false;
								reqID.Style.Add("padding-left", "4px");
								tdField.Controls.Add(reqID);
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				// 06/16/2010 Paul.  Add support for CheckBoxList. 
				else if ( String.Compare(sFIELD_TYPE, "CheckBoxList", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/02/2007 Paul.  If format rows > 0 then this is a list box and not a drop down list. 
						ListControl lstField = new CheckBoxList();
						// 09/16/2010 Paul.  Put inside a div so that we can use auto-scroll. 
						if ( nFORMAT_ROWS > 0 )
						{
							HtmlGenericControl div = new HtmlGenericControl("div");
							div.Controls.Add(lstField);
							tdField.Controls.Add(div);
							div.Attributes.Add("style", "overflow-y: auto;height: " + nFORMAT_ROWS.ToString() + "px");
						}
						else
						{
							tdField.Controls.Add(lstField);
						}
						lstField.ID       = sDATA_FIELD;
						lstField.TabIndex = nFORMAT_TAB_INDEX;
						lstField.CssClass = "checkbox";
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						lstField.Visible  = bLayoutMode || bIsReadable;
						lstField.Enabled  = bLayoutMode || bIsWriteable;
						// 03/22/2013 Paul.  Allow horizontal CheckBoxList. 
						if ( sDATA_FORMAT == "1" )
						{
							(lstField as CheckBoxList).RepeatDirection = System.Web.UI.WebControls.RepeatDirection.Horizontal;
							(lstField as CheckBoxList).RepeatLayout    = System.Web.UI.WebControls.RepeatLayout.Flow;
						}
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) )
							{
								// 12/04/2005 Paul.  Don't populate list if this is a post back. 
								if ( !Sql.IsEmptyString(sCACHE_NAME) && (bLayoutMode || !bIsPostBack) )
								{
									// 12/24/2007 Paul.  Use an array to define the custom caches so that list is in the Cache module. 
									// This should reduce the number of times that we have to edit the SplendidDynamic module. 
									// 02/16/2012 Paul.  Move custom cache logic to a method. 
									SplendidCache.SetListSource(sCACHE_NAME, lstField);
									lstField.DataBind();
								}
								if ( rdr != null )
								{
									try
									{
										string sVALUE = Sql.ToString(rdr[sDATA_FIELD]);
										if ( sVALUE.StartsWith("<?xml") )
										{
											XmlDocument xml = new XmlDocument();
											// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
											// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
											// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
											xml.XmlResolver = null;
											xml.LoadXml(sVALUE);
											XmlNodeList nlValues = xml.DocumentElement.SelectNodes("Value");
											foreach ( XmlNode xValue in nlValues )
											{
												foreach ( ListItem item in lstField.Items )
												{
													if ( item.Value == xValue.InnerText )
														item.Selected = true;
												}
											}
										}
										// 03/22/2013 Paul.  REPEAT_DOW is a special list that returns 0 = sunday, 1 = monday, etc. 
										else if ( sDATA_FIELD == "REPEAT_DOW" )
										{
											for ( int i = 0; i < lstField.Items.Count; i++ )
											{
												if ( sVALUE.Contains(i.ToString()) )
													lstField.Items[i].Selected = true;
											}
										}
										else
										{
											// 08/19/2010 Paul.  Check the list before assigning the value. 
											Utils.SetValue(lstField, sVALUE);
										}
									}
									catch(Exception ex)
									{
										SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
									}
								}
								// 12/04/2005 Paul.  Assigned To field will always default to the current user. 
								else if ( rdr == null && !bIsPostBack && sCACHE_NAME == "AssignedUser")
								{
									try
									{
										// 08/19/2010 Paul.  Check the list before assigning the value. 
										Utils.SetValue(lstField, Security.USER_ID.ToString());
									}
									catch(Exception ex)
									{
										SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
									}
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				// 06/16/2010 Paul.  Add support for Radio buttons. 
				else if ( String.Compare(sFIELD_TYPE, "Radio", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						ListControl lstField = new RadioButtonList();
						// 09/16/2010 Paul.  Put inside a div so that we can use auto-scroll. 
						if ( nFORMAT_ROWS > 0 )
						{
							HtmlGenericControl div = new HtmlGenericControl("div");
							div.Controls.Add(lstField);
							tdField.Controls.Add(div);
							div.Attributes.Add("style", "overflow-y: auto;height: " + nFORMAT_ROWS.ToString() + "px");
						}
						else
						{
							tdField.Controls.Add(lstField);
						}
						lstField.ID       = sDATA_FIELD;
						lstField.TabIndex = nFORMAT_TAB_INDEX;
						lstField.CssClass = "radio";
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						lstField.Visible  = bLayoutMode || bIsReadable;
						lstField.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) )
							{
								// 12/04/2005 Paul.  Don't populate list if this is a post back. 
								if ( !Sql.IsEmptyString(sCACHE_NAME) && (bLayoutMode || !bIsPostBack) )
								{
									// 12/24/2007 Paul.  Use an array to define the custom caches so that list is in the Cache module. 
									// This should reduce the number of times that we have to edit the SplendidDynamic module. 
									// 02/16/2012 Paul.  Move custom cache logic to a method. 
									SplendidCache.SetListSource(sCACHE_NAME, lstField);
									lstField.DataBind();
									// 08/08/2006 Paul.  Allow onchange code to be stored in the database.  
									// ListBoxes do not have a useful onclick event, so there should be no problem overloading this field. 
									if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
										lstField.Attributes.Add("onchange" , sONCLICK_SCRIPT);
									// 02/21/2006 Paul.  Move the NONE item inside the !IsPostBack code. 
									// 12/02/2007 Paul.  We don't need a NONE record when using multi-selection. 
									// 12/03/2007 Paul.  We do want the NONE record when using multi-selection. 
									// This will allow searching of fields that are null instead of using the unassigned only checkbox. 
									if ( !bUI_REQUIRED )
									{
										lstField.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
										// 12/02/2007 Paul.  AppendEditViewFields should be called inside Page_Load when not a postback, 
										// and in InitializeComponent when it is a postback. If done wrong, 
										// the page will bind after the list is populated, causing the list to populate again. 
										// This event will cause the NONE entry to be cleared.  Add a handler to catch this problem, 
										// but the real solution is to call AppendEditViewFields at the appropriate times based on the postback event. 
										lstField.DataBound += new EventHandler(ListControl_DataBound_AllowNull);
									}
									else
									{
										// 06/16/2010 Paul.  If the UI is required for Radio buttons, then we need to set the first item. 
										if ( !bIsPostBack && rdr == null )
										{
											lstField.SelectedIndex = 0;
										}
									}
									// 01/20/2010 Paul.  Set the default value for Currencies. 
									if ( !bLayoutMode && rdr == null && !bIsPostBack && sCACHE_NAME == "Currencies" )
									{
										try
										{
											Guid gCURRENCY_ID = Sql.ToGuid(HttpContext.Current.Session["USER_SETTINGS/CURRENCY"]);
											// 08/19/2010 Paul.  Check the list before assigning the value. 
											Utils.SetValue(lstField, gCURRENCY_ID.ToString());
										}
										catch
										{
										}
									}
								}
								if ( rdr != null )
								{
									try
									{
										// 02/21/2006 Paul.  All the DropDownLists in the Calls and Meetings edit views were not getting set.  
										// The problem was a Page.DataBind in the SchedulingGrid and in the InviteesView. Both binds needed to be removed. 
										// 12/30/2007 Paul.  A customer needed the ability to save and restore the multiple selection. 
										// 12/30/2007 Paul.  Require the XML declaration in the data before trying to treat as XML. 
										string sVALUE = Sql.ToString(rdr[sDATA_FIELD]);
										if ( nFORMAT_ROWS > 0 && sVALUE.StartsWith("<?xml") )
										{
											XmlDocument xml = new XmlDocument();
											// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
											// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
											// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
											xml.XmlResolver = null;
											xml.LoadXml(sVALUE);
											XmlNodeList nlValues = xml.DocumentElement.SelectNodes("Value");
											foreach ( XmlNode xValue in nlValues )
											{
												foreach ( ListItem item in lstField.Items )
												{
													if ( item.Value == xValue.InnerText )
														item.Selected = true;
												}
											}
										}
										else
										{
											// 08/19/2010 Paul.  Check the list before assigning the value. 
											Utils.SetValue(lstField, sVALUE);
										}
									}
									catch(Exception ex)
									{
										SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
									}
								}
								// 12/04/2005 Paul.  Assigned To field will always default to the current user. 
								else if ( rdr == null && !bIsPostBack && sCACHE_NAME == "AssignedUser")
								{
									try
									{
										// 12/02/2007 Paul.  We don't default the user when using multi-selection.  
										// This is because this mode is typically used for searching. 
										if ( nFORMAT_ROWS == 0 )
											// 08/19/2010 Paul.  Check the list before assigning the value. 
											Utils.SetValue(lstField, Security.USER_ID.ToString());
									}
									catch(Exception ex)
									{
										SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
									}
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "CheckBox", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						CheckBox chkField = new CheckBox();
						tdField.Controls.Add(chkField);
						chkField.ID = sDATA_FIELD;
						chkField.CssClass = "checkbox";
						chkField.TabIndex = nFORMAT_TAB_INDEX;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						chkField.Visible  = bLayoutMode || bIsReadable;
						chkField.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							if ( rdr != null )
								chkField.Checked = Sql.ToBoolean(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						// 07/11/2007 Paul.  A checkbox can have a click event. 
						if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
							chkField.Attributes.Add("onclick", sONCLICK_SCRIPT);
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
							chkField.Enabled  = false     ;
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "ChangeButton", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						//05/06/2010 Paul.  Manually generate ClearModuleType so that it will be UpdatePanel safe. 
						DropDownList lstField = null;
						// 12/04/2005 Paul.  If the label is PARENT_TYPE, then change the label to a DropDownList.
						if ( sDATA_LABEL == "PARENT_TYPE" )
						{
							tdLabel.Controls.Clear();
							// 04/25/2008 Paul.  Use KeySortDropDownList instead of ListSearchExtender. 
							// 01/13/2010 Paul.  KeySortDropDownList is causing OnChange will always fire when tabbed-away. 
							// For the Parent DropDownList, we don't need the KeySort as it is a short list. 
							//DropDownList lstField = new KeySortDropDownList();
							lstField = new DropDownList();
							tdLabel.Controls.Add(lstField);
							// 11/11/2010 Paul.  Give the parent type a unique name. 
							// 02/04/2011 Paul.  We gave the PARENT_TYPE a unique name, but we need to update all EditViews and NewRecords. 
							lstField.ID       = sDATA_FIELD + "_PARENT_TYPE";
							lstField.TabIndex = nFORMAT_TAB_INDEX;
							// 04/02/2013 Paul.  Apply ACL Field Security to Parent Type field. 
							if ( SplendidInit.bEnableACLFieldSecurity )
							{
								Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, "PARENT_TYPE", gASSIGNED_USER_ID);
								lstField.Visible  = bLayoutMode || acl.IsReadable();
								lstField.Enabled  = bLayoutMode || acl.IsWriteable() || sEDIT_NAME.Contains(".Search");
							}
							
							
							// 04/25/2008 Paul.  Add AJAX searching of list. 
							// 04/25/2008 Paul.  ListSearchExtender needs work.  I don't like the delay when a list is selected
							// and there are problems when the browser window is scrolled.  KeySortDropDownList is a better solution. 
							// 07/23/2010 Paul.  Lets try the latest version of the ListSearchExtender. 
							// 07/28/2010 Paul.  We are getting an undefined exception on the Accounts List Advanced page. 
							/*
							AjaxControlToolkit.ListSearchExtender extField = new AjaxControlToolkit.ListSearchExtender();
							extField.ID              = lstField.ID + "_ListSearchExtender";
							extField.TargetControlID = lstField.ID;
							extField.PromptText      = L10n.Term(".LBL_TYPE_TO_SEARCH");
							extField.PromptCssClass  = "ListSearchExtenderPrompt";
							tdLabel.Controls.Add(extField);
							*/
							if ( bLayoutMode || !bIsPostBack )
							{
								// 07/29/2005 Paul.  SugarCRM 3.0 does not allow the NONE option. 
								lstField.DataValueField = "NAME"        ;
								lstField.DataTextField  = "DISPLAY_NAME";
								lstField.DataSource     = SplendidCache.List("record_type_display");
								lstField.DataBind();
								if ( rdr != null )
								{
									try
									{
										// 08/19/2010 Paul.  Check the list before assigning the value. 
										Utils.SetValue(lstField, Sql.ToString(rdr[sDATA_LABEL]));
									}
									catch(Exception ex)
									{
										SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
									}
								}
							}
						}
						TextBox txtNAME = new TextBox();
						tdField.Controls.Add(txtNAME);
						txtNAME.ID       = sDISPLAY_FIELD;
						txtNAME.ReadOnly = true;
						txtNAME.TabIndex = nFORMAT_TAB_INDEX;
						// 11/25/2006 Paul.   Turn off viewstate so that we can fix the text on postback. 
						txtNAME.EnableViewState = false;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						txtNAME.Visible  = bLayoutMode || bIsReadable;
						txtNAME.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							// 07/23/2014 Paul.  Allow customization of the size of a ModulePopup text field. 
							if ( nFORMAT_SIZE > 0 )
								txtNAME.Attributes.Add("size", nFORMAT_SIZE.ToString());
							if ( bLayoutMode )
							{
								txtNAME.Text    = sDISPLAY_FIELD;
								txtNAME.Enabled = false         ;
							}
							// 11/25/2006 Paul.  The Change text field is losing its value during a postback error. 
							else if ( bIsPostBack )
							{
								// 11/25/2006 Paul.  In order for this posback fix to work, viewstate must be disabled for this field. 
								if ( tbl.Page.Request[txtNAME.UniqueID] != null )
									txtNAME.Text = Sql.ToString(tbl.Page.Request[txtNAME.UniqueID]);
							}
							else if ( !Sql.IsEmptyString(sDISPLAY_FIELD) && rdr != null )
								txtNAME.Text = Sql.ToString(rdr[sDISPLAY_FIELD]);
							// 11/25/2006 Paul.  The team name should always default to the current user's private team. 
							// Make sure not to overwrite the value if this is a postback. 
							// 08/26/2009 Paul.  Don't prepopulate team or user if in a search dialog. 
							// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
							else if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sDATA_FIELD == "TEAM_ID" && rdr == null && !bIsPostBack )
								txtNAME.Text = Security.TEAM_NAME;
							// 01/15/2007 Paul.  Assigned To field will always default to the current user. 
							// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
							else if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sDATA_FIELD == "ASSIGNED_USER_ID" && rdr == null && !bIsPostBack )
							{
								// 01/29/2011 Paul.  If Full Names have been enabled, then prepopulate with the full name. 
								if ( sDISPLAY_FIELD == "ASSIGNED_TO_NAME" )
									txtNAME.Text = Security.FULL_NAME;
								else
									txtNAME.Text = Security.USER_NAME;
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						HtmlInputHidden hidID = new HtmlInputHidden();
						tdField.Controls.Add(hidID);
						hidID.ID = sDATA_FIELD;
						try
						{
							if ( !bLayoutMode )
							{
								if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
									hidID.Value = Sql.ToString(rdr[sDATA_FIELD]);
								// 11/25/2006 Paul.  The team name should always default to the current user's private team. 
								// Make sure not to overwrite the value if this is a postback. 
								// The hidden field does not require the same viewstate fix as the txtNAME field. 
								// 04/23/2009 Paul.  Make sure not to initialize the field with an empty guid as that will prevent the required field notice. 
								// 08/26/2009 Paul.  Don't prepopulate team or user if in a search dialog. 
								// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
								else if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sDATA_FIELD == "TEAM_ID" && rdr == null && !bIsPostBack && !Sql.IsEmptyGuid(Security.TEAM_ID) )
									hidID.Value = Security.TEAM_ID.ToString();
								// 01/15/2007 Paul.  Assigned To field will always default to the current user. 
								// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
								else if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sDATA_FIELD == "ASSIGNED_USER_ID" && rdr == null && !bIsPostBack )
									hidID.Value = Security.USER_ID.ToString();
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						//05/06/2010 Paul.  Manually generate ClearModuleType so that it will be UpdatePanel safe. 
						// 07/27/2010 Paul.  Add the ability to submit after clear. 
						if ( sDATA_LABEL == "PARENT_TYPE" && lstField != null )
							lstField.Attributes.Add("onChange", "ClearModuleType('', '" + hidID.ClientID + "', '" + txtNAME.ClientID + "', false);");
						
						Literal litNBSP = new Literal();
						tdField.Controls.Add(litNBSP);
						litNBSP.Text = "&nbsp;";
						
						// 06/20/2009 Paul.  The Select button will go on a separate row in the NewRecord form. 
						if ( LABEL_WIDTH == "100%" && sFIELD_WIDTH == "0%" && nDATA_COLUMNS == 1 )
						{
							nRowIndex++;
							trField = new HtmlTableRow();
							tbl.Rows.Insert(nRowIndex, trField);
							tdField = new HtmlTableCell();
							trField.Cells.Add(tdField);
						}
						HtmlInputButton btnChange = new HtmlInputButton("button");
						tdField.Controls.Add(btnChange);
						// 05/07/2006 Paul.  Specify a name for the check button so that it can be referenced by SplendidTest. 
						btnChange.ID = sDATA_FIELD + "_btnChange";
						btnChange.Attributes.Add("class", "button");
						// 05/06/2010 Paul.  Manually generate ParentPopup so that it will be UpdatePanel safe. 
						// 07/27/2010 Paul.  Use the DATA_FORMAT field to determine if the ModulePopup will auto-submit. 
						string[] arrDATA_FORMAT = sDATA_FORMAT.Split(',');
						if ( lstField != null )
						{
							btnChange.Attributes.Add("onclick", "return ModulePopup(document.getElementById('" + lstField.ClientID + "').options[document.getElementById('" + lstField.ClientID + "').options.selectedIndex].value, '" + hidID.ClientID + "', '" + txtNAME.ClientID + "', null, " + (arrDATA_FORMAT[0] == "1" ? "true" : "false") + ", null);");
						}
						else if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
							btnChange.Attributes.Add("onclick"  , sONCLICK_SCRIPT);
						// 03/31/2007 Paul.  SugarCRM now uses Select instead of Change. 
						btnChange.Attributes.Add("title"    , L10n.Term(".LBL_SELECT_BUTTON_TITLE"));
						// 07/31/2006 Paul.  Stop using VisualBasic library to increase compatibility with Mono. 
						// 03/31/2007 Paul.  Stop using AccessKey for change button. 
						//btnChange.Attributes.Add("accessKey", L10n.Term(".LBL_SELECT_BUTTON_KEY").Substring(0, 1));
						btnChange.Value = L10n.Term(".LBL_SELECT_BUTTON_LABEL");
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						btnChange.Visible  =   bLayoutMode || bIsReadable;
						btnChange.Disabled = !(bLayoutMode || bIsWriteable);

						// 12/03/2007 Paul.  Also create a Clear button. 
						// 05/06/2010 Paul.  A Parent Type will always have a clear button. 
						if ( sONCLICK_SCRIPT.IndexOf("Popup();") > 0 || sDATA_LABEL == "PARENT_TYPE" )
						{
							litNBSP = new Literal();
							tdField.Controls.Add(litNBSP);
							litNBSP.Text = "&nbsp;";
							
							HtmlInputButton btnClear = new HtmlInputButton("button");
							tdField.Controls.Add(btnClear);
							btnClear.ID = sDATA_FIELD + "_btnClear";
							btnClear.Attributes.Add("class", "button");
							// 05/06/2010 Paul.  Manually generate ClearModuleType so that it will be UpdatePanel safe. 
							// 07/27/2010 Paul.  Add the ability to submit after clear. 
							btnClear.Attributes.Add("onclick"  , "return ClearModuleType('', '" + hidID.ClientID + "', '" + txtNAME.ClientID + "', " + (arrDATA_FORMAT[0] == "1" ? "true" : "false") + ");");
							btnClear.Attributes.Add("title"    , L10n.Term(".LBL_CLEAR_BUTTON_TITLE"));
							btnClear.Value = L10n.Term(".LBL_CLEAR_BUTTON_LABEL");
							// 01/18/2010 Paul.  Apply ACL Field Security. 
							btnClear.Visible  =   bLayoutMode || bIsReadable;
							btnClear.Disabled = !(bLayoutMode || bIsWriteable);
						}
						// 11/11/2010 Paul.  Always create the Required Field Validator so that we can Enable/Disable in a Rule. 
						if ( !bLayoutMode && /* bUI_REQUIRED && */ !Sql.IsEmptyString(sDATA_FIELD) )
						{
							RequiredFieldValidatorForHiddenInputs reqID = new RequiredFieldValidatorForHiddenInputs();
							reqID.ID                 = sDATA_FIELD + "_REQUIRED";
							reqID.ControlToValidate  = hidID.ID;
							reqID.ErrorMessage       = L10n.Term(".ERR_REQUIRED_FIELD");
							reqID.CssClass           = "required";
							reqID.EnableViewState    = false;
							// 01/16/2006 Paul.  We don't enable required fields until we attempt to save. 
							// This is to allow unrelated form actions; the Cancel button is a good example. 
							reqID.EnableClientScript = false;
							reqID.Enabled            = false;
							// 02/21/2008 Paul.  Add a little padding. 
							reqID.Style.Add("padding-left", "4px");
							tdField.Controls.Add(reqID);
						}
					}
				}
				// 05/17/2009 Paul.  Add support for a generic module popup. 
				else if ( String.Compare(sFIELD_TYPE, "ModulePopup", true) == 0 )
				{
					//12/07/2009 Paul.  For cell phones that do not support popups, convert to a DropDownList. 
					if ( !Sql.IsEmptyString(sDATA_FIELD) && !bSupportsPopups )
					{
						ListControl lstField = new DropDownList();
						tdField.Controls.Add(lstField);
						lstField.ID       = sDATA_FIELD;
						lstField.TabIndex = nFORMAT_TAB_INDEX;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						lstField.Visible  = bLayoutMode || bIsReadable;
						lstField.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							// 12/04/2005 Paul.  Don't populate list if this is a post back. 
							if ( (bLayoutMode || !bIsPostBack) )
							{
								try
								{
									using ( DataTable dt = Crm.Modules.Items(sMODULE_TYPE) )
									{
										lstField.DataValueField = "ID"  ;
										lstField.DataTextField  = "NAME";
										lstField.DataSource     = dt;
										lstField.DataBind();
									}
								}
								catch(Exception ex)
								{
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
								}
								if ( !bUI_REQUIRED )
								{
									lstField.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
									// 12/02/2007 Paul.  AppendEditViewFields should be called inside Page_Load when not a postback, 
									// and in InitializeComponent when it is a postback. If done wrong, 
									// the page will bind after the list is populated, causing the list to populate again. 
									// This event will cause the NONE entry to be cleared.  Add a handler to catch this problem, 
									// but the real solution is to call AppendEditViewFields at the appropriate times based on the postback event. 
									lstField.DataBound += new EventHandler(ListControl_DataBound_AllowNull);
								}
							}
							if ( rdr != null )
							{
								// 08/19/2010 Paul.  Check the list before assigning the value. 
								Utils.SetValue(lstField, Sql.ToGuid(rdr[sDATA_FIELD]).ToString());
							}
							// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
							else if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sDATA_FIELD == "ASSIGNED_USER_ID" && rdr == null && !bIsPostBack )
							{
								// 08/19/2010 Paul.  Check the list before assigning the value. 
								Utils.SetValue(lstField, Security.USER_ID.ToString());
							}
							// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
							else if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sDATA_FIELD == "TEAM_ID" && rdr == null && !bIsPostBack )
							{
								// 08/19/2010 Paul.  Check the list before assigning the value. 
								Utils.SetValue(lstField, Security.TEAM_ID.ToString());
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
					else if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						TextBox txtNAME = new TextBox();
						tdField.Controls.Add(txtNAME);
						// 10/05/2010 Paul.  A custom field will not have a display field, but we still want to be able to access by name. 
						txtNAME.ID       = Sql.IsEmptyString(sDISPLAY_FIELD) ? sDATA_FIELD + "_NAME" : sDISPLAY_FIELD;
						txtNAME.ReadOnly = true;
						txtNAME.TabIndex = nFORMAT_TAB_INDEX;
						// 11/25/2006 Paul.   Turn off viewstate so that we can fix the text on postback. 
						txtNAME.EnableViewState = false;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						txtNAME.Visible  = bLayoutMode || bIsReadable;
						txtNAME.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							// 07/23/2014 Paul.  Allow customization of the size of a ModulePopup text field. 
							if ( nFORMAT_SIZE > 0 )
								txtNAME.Attributes.Add("size", nFORMAT_SIZE.ToString());
							if ( bLayoutMode )
							{
								txtNAME.Text    = sDISPLAY_FIELD;
								txtNAME.Enabled = false         ;
							}
							// 11/25/2006 Paul.  The Change text field is losing its value during a postback error. 
							else if ( bIsPostBack )
							{
								// 11/25/2006 Paul.  In order for this posback fix to work, viewstate must be disabled for this field. 
								if ( tbl.Page.Request[txtNAME.UniqueID] != null )
									txtNAME.Text = Sql.ToString(tbl.Page.Request[txtNAME.UniqueID]);
							}
							else if ( rdr != null )
							{
								// 12/03/2009 Paul.  We must use vwSchema to look for the desired column name. 
								// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
								//if ( vwSchema != null )
								//	vwSchema.RowFilter = "ColumnName = '" + Sql.EscapeSQL(sDISPLAY_FIELD) + "'";
								if ( !Sql.IsEmptyString(sDISPLAY_FIELD) && row != null && rdr.Table.Columns.Contains(sDISPLAY_FIELD) )
									txtNAME.Text = Sql.ToString(rdr[sDISPLAY_FIELD]);
								else
								{
									// 02/16/2010 Paul.  Move ToGuid to the function so that it can be captured if invalid. 
									txtNAME.Text = Crm.Modules.ItemName(Application, sMODULE_TYPE, rdr[sDATA_FIELD]);
								}
							}
							// 11/25/2006 Paul.  The team name should always default to the current user's private team. 
							// Make sure not to overwrite the value if this is a postback. 
							// 08/26/2009 Paul.  Don't prepopulate team or user if in a search dialog. 
							// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
							else if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sDATA_FIELD == "TEAM_ID" && rdr == null && !bIsPostBack )
								txtNAME.Text = Security.TEAM_NAME;
							// 01/15/2007 Paul.  Assigned To field will always default to the current user. 
							// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
							else if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sDATA_FIELD == "ASSIGNED_USER_ID" && rdr == null && !bIsPostBack )
							{
								// 01/29/2011 Paul.  If Full Names have been enabled, then prepopulate with the full name. 
								if ( sDISPLAY_FIELD == "ASSIGNED_TO_NAME" )
									txtNAME.Text = Security.FULL_NAME;
								else
									txtNAME.Text = Security.USER_NAME;
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						HtmlInputHidden hidID = new HtmlInputHidden();
						tdField.Controls.Add(hidID);
						hidID.ID = sDATA_FIELD;
						try
						{
							if ( !bLayoutMode )
							{
								if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
									hidID.Value = Sql.ToString(rdr[sDATA_FIELD]);
								// 11/25/2006 Paul.  The team name should always default to the current user's private team. 
								// Make sure not to overwrite the value if this is a postback. 
								// The hidden field does not require the same viewstate fix as the txtNAME field. 
								// 04/23/2009 Paul.  Make sure not to initialize the field with an empty guid as that will prevent the required field notice. 
								// 08/26/2009 Paul.  Don't prepopulate team or user if in a search dialog. 
								// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
								else if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sDATA_FIELD == "TEAM_ID" && rdr == null && !bIsPostBack && !Sql.IsEmptyGuid(Security.TEAM_ID) )
									hidID.Value = Security.TEAM_ID.ToString();
								// 01/15/2007 Paul.  Assigned To field will always default to the current user. 
								// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
								else if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sDATA_FIELD == "ASSIGNED_USER_ID" && rdr == null && !bIsPostBack )
									hidID.Value = Security.USER_ID.ToString();
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						
						Literal litNBSP = new Literal();
						tdField.Controls.Add(litNBSP);
						litNBSP.Text = "&nbsp;";
						
						// 06/20/2009 Paul.  The Select button will go on a separate row in the NewRecord form. 
						if ( LABEL_WIDTH == "100%" && sFIELD_WIDTH == "0%" && nDATA_COLUMNS == 1 )
						{
							nRowIndex++;
							trField = new HtmlTableRow();
							tbl.Rows.Insert(nRowIndex, trField);
							tdField = new HtmlTableCell();
							trField.Cells.Add(tdField);
						}
						HtmlInputButton btnChange = new HtmlInputButton("button");
						tdField.Controls.Add(btnChange);
						// 05/07/2006 Paul.  Specify a name for the check button so that it can be referenced by SplendidTest. 
						btnChange.ID = sDATA_FIELD + "_btnChange";
						btnChange.Attributes.Add("class", "button");
						// 07/27/2010 Paul.  We need to allow an onclick to override the default ModulePopup behavior. 
						string[] arrDATA_FORMAT = sDATA_FORMAT.Split(',');
						if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
							btnChange.Attributes.Add("onclick"  , sONCLICK_SCRIPT);
						else
						{
							// 08/01/2010 Paul.  We need to tell the Users popup to return the FULL NAME. 
							string sQUERY = "null";
							if ( sMODULE_TYPE == "Users" && sDISPLAY_FIELD == "ASSIGNED_TO_NAME" )
								sQUERY = "'FULL_NAME=1'";  // 08/01/201 Paul.  Query must be quoted. 
							// 07/27/2010 Paul.  Use the DATA_FORMAT field to determine if the ModulePopup will auto-submit. 
							btnChange.Attributes.Add("onclick"  , "return ModulePopup('" + sMODULE_TYPE + "', '" + hidID.ClientID + "', '" + txtNAME.ClientID + "', " + sQUERY + ", " + (arrDATA_FORMAT[0] == "1" ? "true" : "false") + ", null);");
						}
						// 03/31/2007 Paul.  SugarCRM now uses Select instead of Change. 
						btnChange.Attributes.Add("title"    , L10n.Term(".LBL_SELECT_BUTTON_TITLE"));
						btnChange.Value = L10n.Term(".LBL_SELECT_BUTTON_LABEL");
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						btnChange.Visible  =   bLayoutMode || bIsReadable;
						btnChange.Disabled = !(bLayoutMode || bIsWriteable);
						
						litNBSP = new Literal();
						tdField.Controls.Add(litNBSP);
						litNBSP.Text = "&nbsp;";
						
						HtmlInputButton btnClear = new HtmlInputButton("button");
						tdField.Controls.Add(btnClear);
						btnClear.ID = sDATA_FIELD + "_btnClear";
						btnClear.Attributes.Add("class", "button");
						// 07/27/2010 Paul.  Add the ability to submit after clear. 
						btnClear.Attributes.Add("onclick"  , "return ClearModuleType('" + sMODULE_TYPE + "', '" + hidID.ClientID + "', '" + txtNAME.ClientID + "', " + (arrDATA_FORMAT[0] == "1" ? "true" : "false") + ");");
						btnClear.Attributes.Add("title"    , L10n.Term(".LBL_CLEAR_BUTTON_TITLE"));
						btnClear.Value = L10n.Term(".LBL_CLEAR_BUTTON_LABEL");
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						btnClear.Visible  =   bLayoutMode || bIsReadable;
						btnClear.Disabled = !(bLayoutMode || bIsWriteable);
						
						// 11/11/2010 Paul.  Always create the Required Field Validator so that we can Enable/Disable in a Rule. 
						if ( !bLayoutMode && /* bUI_REQUIRED && */ !Sql.IsEmptyString(sDATA_FIELD) )
						{
							RequiredFieldValidatorForHiddenInputs reqID = new RequiredFieldValidatorForHiddenInputs();
							reqID.ID                 = sDATA_FIELD + "_REQUIRED";
							reqID.ControlToValidate  = hidID.ID;
							reqID.ErrorMessage       = L10n.Term(".ERR_REQUIRED_FIELD");
							reqID.CssClass           = "required";
							reqID.EnableViewState    = false;
							// 01/16/2006 Paul.  We don't enable required fields until we attempt to save. 
							// This is to allow unrelated form actions; the Cancel button is a good example. 
							reqID.EnableClientScript = false;
							reqID.Enabled            = false;
							// 02/21/2008 Paul.  Add a little padding. 
							reqID.Style.Add("padding-left", "4px");
							tdField.Controls.Add(reqID);
						}
						// 11/23/2009 Paul.  Allow AJAX AutoComplete to be turned off. 
						// 01/18/2010 Paul.  AutoComplete only applies if the field is Writeable. 
						if ( bAjaxAutoComplete && !bLayoutMode && mgrAjax != null && !Sql.IsEmptyString(sMODULE_TYPE) && bIsWriteable )
						{
							string sTABLE_NAME    = Sql.ToString(Application["Modules." + sMODULE_TYPE + ".TableName"   ]);
							string sRELATIVE_PATH = Sql.ToString(Application["Modules." + sMODULE_TYPE + ".RelativePath"]);
							
							// 09/03/2009 Paul.  File IO is expensive, so cache the results of the Exists test. 
							// 11/19/2009 Paul.  Simplify the exists test. 
							// 03/03/2010 Paul.  AutoComplete will not work if the DISPLAY_FIELD is not provided. 
							// 09/08/2010 Paul.  sRELATIVE_PATH must be valid. 
							// 08/25/2013 Paul.  File IO is slow, so cache existance test. 
							if ( !Sql.IsEmptyString(sDISPLAY_FIELD) && !Sql.IsEmptyString(sRELATIVE_PATH) && Utils.CachedFileExists(HttpContext.Current, sRELATIVE_PATH + "AutoComplete.asmx") )
							{
								// 09/03/2009 Paul.  If the AutoComplete file exists, then we can safely diable the ReadOnly flag. 
								txtNAME.ReadOnly = false;
								txtNAME.Attributes.Add("onblur", sTABLE_NAME + "_" + txtNAME.ID + "_Changed(this);");
								// 09/03/2009 Paul.  Add a PREV_ field so that we can detect a text change. 
								HtmlInputHidden hidPREVIOUS = new HtmlInputHidden();
								tdField.Controls.Add(hidPREVIOUS);
								hidPREVIOUS.ID = "PREV_" + sDISPLAY_FIELD;
								try
								{
									if ( !bLayoutMode )
									{
										if ( !Sql.IsEmptyString(sDISPLAY_FIELD) && rdr != null )
											hidPREVIOUS.Value = Sql.ToString(rdr[sDISPLAY_FIELD]);
										// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
										else if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sDATA_FIELD == "TEAM_ID" && rdr == null && !bIsPostBack )
											hidPREVIOUS.Value = Security.TEAM_NAME;
										// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
										else if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sDATA_FIELD == "ASSIGNED_USER_ID" && rdr == null && !bIsPostBack )
										{
											// 01/29/2011 Paul.  If Full Names have been enabled, then prepopulate with the full name. 
											if ( sDISPLAY_FIELD == "ASSIGNED_TO_NAME" )
												hidPREVIOUS.Value = Security.FULL_NAME;
											else
												hidPREVIOUS.Value = Security.USER_NAME;
										}
									}
								}
								catch(Exception ex)
								{
									SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
								}
								
								AjaxControlToolkit.AutoCompleteExtender auto = new AjaxControlToolkit.AutoCompleteExtender();
								tdField.Controls.Add(auto);
								auto.ID                   = "auto" + txtNAME.ID;
								auto.TargetControlID      = txtNAME.ID;
								auto.ServiceMethod        = sTABLE_NAME + "_" + txtNAME.ID + "_" + "List";
								auto.ServicePath          = sRELATIVE_PATH + "AutoComplete.asmx";
								auto.MinimumPrefixLength  = 2;
								auto.CompletionInterval   = 250;
								auto.EnableCaching        = true;
								// 12/09/2010 Paul.  Provide a way to customize the AutoComplete.CompletionSetCount. 
								auto.CompletionSetCount   = Crm.Config.CompletionSetCount();
								// 07/27/2010 Paul.  We need to use the ContextKey feature of AutoComplete to pass the Account Name to the Contact function. 
								// 07/27/2010 Paul.  JavaScript seems to have a problem with function overloading. 
								// Instead of trying to use function overloading, use a DataFormat flag to check the UseContextKey AutoComplete flag. 
								if ( arrDATA_FORMAT.Length > 1 && arrDATA_FORMAT[1] == "1" )
									auto.UseContextKey = true;
								
								ServiceReference svc = new ServiceReference(sRELATIVE_PATH + "AutoComplete.asmx");
								ScriptReference  scr = new ScriptReference (sRELATIVE_PATH + "AutoComplete.js"  );
								if ( !mgrAjax.Services.Contains(svc) )
									mgrAjax.Services.Add(svc);
								if ( !mgrAjax.Scripts.Contains(scr) )
									mgrAjax.Scripts.Add(scr);
								
								litNBSP = new Literal();
								tdField.Controls.Add(litNBSP);
								litNBSP.Text = "&nbsp;";
								// 09/03/2009 Paul.  We need to use a unique ID for each ajax error, 
								// otherwise we will not place the error message in the correct location. 
								HtmlGenericControl spnAjaxErrors = new HtmlGenericControl("span");
								tdField.Controls.Add(spnAjaxErrors);
								// 09/03/2009 Paul.  Don't include the table name in the AjaxErrors field so that 
								// it can be cleared from the ChangeModule() module popup script. 
								spnAjaxErrors.ID = txtNAME.ID + "_AjaxErrors";
								spnAjaxErrors.Attributes.Add("style", "color:Red");
								spnAjaxErrors.EnableViewState = false;
							}
						}
						// 10/20/2010 Paul.  Automatically associate the TextBox with a Submit button. 
						// 10/20/2010 Paul.  We are still having a problem with the Enter Key hijacking the Auto-Complete logic. The most practical solution is to block the Enter Key. 
						if ( !bLayoutMode && !Sql.IsEmptyString(sSubmitClientID) )
						{
							if ( mgrAjax != null )
							{
								ScriptManager.RegisterStartupScript(Page, typeof(System.String), txtNAME.ClientID + "_EnterKey", Utils.PreventEnterKeyPress(txtNAME.ClientID), false);
							}
							else
							{
								#pragma warning disable 618
								Page.ClientScript.RegisterStartupScript(typeof(System.String), txtNAME.ClientID + "_EnterKey", Utils.PreventEnterKeyPress(txtNAME.ClientID));
								#pragma warning restore 618
							}
						}
					}
				}
				// 09/02/2009 Paul.  Add AJAX AutoCompletion
				else if ( String.Compare(sFIELD_TYPE, "ModuleAutoComplete", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						TextBox txtField = new TextBox();
						tdField.Controls.Add(txtField);
						txtField.ID       = sDATA_FIELD;
						txtField.TabIndex = nFORMAT_TAB_INDEX;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						txtField.Visible  = bLayoutMode || bIsReadable;
						txtField.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							txtField.MaxLength = nFORMAT_MAX_LENGTH   ;
							// 06/20/2009 Paul.  The NewRecord forms do not specify a size. 
							if ( nFORMAT_SIZE > 0 )
								txtField.Attributes.Add("size", nFORMAT_SIZE.ToString());
							txtField.TextMode  = TextBoxMode.SingleLine;
							// 08/31/2012 Paul.  Apple and Android devices should support speech and handwriting. 
							// Speech does not work on text areas, only add to single line text boxes. 
							if ( Utils.SupportsSpeech && Sql.ToBoolean(Application["CONFIG.enable_speech"]) )
							{
								txtField.Attributes.Add("speech", "speech");
								txtField.Attributes.Add("x-webkit-speech", "x-webkit-speech");
							}
							if ( bLayoutMode )
							{
								txtField.Text    = sDATA_FIELD;
								txtField.Enabled = false         ;
							}
							else if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
								txtField.Text = Sql.ToString(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtField.Text = ex.Message;
						}
						// 11/23/2009 Paul.  Allow AJAX AutoComplete to be turned off. 
						// 01/18/2010 Paul.  AutoComplete only applies if the field is Writeable. 
						if ( bAjaxAutoComplete && !bLayoutMode && mgrAjax != null && !Sql.IsEmptyString(sMODULE_TYPE) && bIsWriteable )
						{
							string sTABLE_NAME    = Sql.ToString(Application["Modules." + sMODULE_TYPE + ".TableName"   ]);
							string sRELATIVE_PATH = Sql.ToString(Application["Modules." + sMODULE_TYPE + ".RelativePath"]);
							
							// 09/03/2009 Paul.  File IO is expensive, so cache the results of the Exists test. 
							// 11/19/2009 Paul.  Simplify the exists test. 
							// 09/08/2010 Paul.  sRELATIVE_PATH must be valid. 
							// 08/25/2013 Paul.  File IO is slow, so cache existance test. 
							if ( !Sql.IsEmptyString(sRELATIVE_PATH) && Utils.CachedFileExists(HttpContext.Current, sRELATIVE_PATH + "AutoComplete.asmx") )
							{
								AjaxControlToolkit.AutoCompleteExtender auto = new AjaxControlToolkit.AutoCompleteExtender();
								tdField.Controls.Add(auto);
								auto.ID                   = "auto" + txtField.ID;
								auto.TargetControlID      = txtField.ID;
								auto.ServiceMethod        = sTABLE_NAME + "_" + txtField.ID + "_" + "List";
								auto.ServicePath          = sRELATIVE_PATH + "AutoComplete.asmx";
								auto.MinimumPrefixLength  = 2;
								auto.CompletionInterval   = 250;
								auto.EnableCaching        = true;
								// 12/09/2010 Paul.  Provide a way to customize the AutoComplete.CompletionSetCount. 
								auto.CompletionSetCount   = Crm.Config.CompletionSetCount();
								
								ServiceReference svc = new ServiceReference(sRELATIVE_PATH + "AutoComplete.asmx");
								ScriptReference  scr = new ScriptReference (sRELATIVE_PATH + "AutoComplete.js"  );
								if ( !mgrAjax.Services.Contains(svc) )
									mgrAjax.Services.Add(svc);
								if ( !mgrAjax.Scripts.Contains(scr) )
									mgrAjax.Scripts.Add(scr);
							}
							else
							{
								Application["Exists." + sRELATIVE_PATH + "AutoComplete.asmx"] = false;
							}
						}
						// 06/21/2009 Paul.  Automatically associate the TextBox with a Submit button. 
						if ( !bLayoutMode && !Sql.IsEmptyString(sSubmitClientID) )
						{
							if ( mgrAjax != null )
							{
								// 06/21/2009 Paul.  The name of the script block must be unique for each instance of this control. 
								// 06/21/2009 Paul.  Use RegisterStartupScript instead of RegisterClientScriptBlock so that the script will run after the control has been created. 
								ScriptManager.RegisterStartupScript(Page, typeof(System.String), txtField.ClientID + "_EnterKey", Utils.RegisterEnterKeyPress(txtField.ClientID, sSubmitClientID), false);
							}
							else
							{
								#pragma warning disable 618
								Page.ClientScript.RegisterStartupScript(typeof(System.String), txtField.ClientID + "_EnterKey", Utils.RegisterEnterKeyPress(txtField.ClientID, sSubmitClientID));
								#pragma warning restore 618
							}
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "TextBox", true) == 0 || String.Compare(sFIELD_TYPE, "Password", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						TextBox txtField = new TextBox();
						tdField.Controls.Add(txtField);
						txtField.ID       = sDATA_FIELD;
						txtField.TabIndex = nFORMAT_TAB_INDEX;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						txtField.Visible  = bLayoutMode || bIsReadable;
						txtField.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							if ( nFORMAT_ROWS > 0 && nFORMAT_COLUMNS > 0 )
							{
								txtField.Rows     = nFORMAT_ROWS   ;
								txtField.Columns  = nFORMAT_COLUMNS;
								txtField.TextMode = TextBoxMode.MultiLine;
								
								// 08/22/2012 Paul.  Apple and Android devices should support speech and handwriting. 
								// Speech does not work on text areas, only add to single line text boxes. 
								// http://www.labnol.org/software/add-speech-recognition-to-website/19989/
								if ( Utils.SupportsSpeech && Sql.ToBoolean(Application["CONFIG.enable_speech"]) )
								{
									TextBox txtSpeech = new TextBox();
									tdField.Controls.Add(txtSpeech);
									txtSpeech.ID       = sDATA_FIELD + "_SPEECH";
									txtSpeech.TabIndex = nFORMAT_TAB_INDEX;
									txtSpeech.Visible  = bLayoutMode || bIsReadable;
									txtSpeech.Enabled  = bLayoutMode || bIsWriteable;
									txtSpeech.Attributes.Add("style", "width: 15px; height: 20px; border: 0px; background-color: transparent; vertical-align:top;");
									txtSpeech.Attributes.Add("speech", "speech");
									txtSpeech.Attributes.Add("x-webkit-speech", "x-webkit-speech");
									txtSpeech.Attributes.Add("onspeechchange"      , "SpeechTranscribe('" + txtSpeech.ClientID + "', '" + txtField.ClientID + "');");
									txtSpeech.Attributes.Add("onwebkitspeechchange", "SpeechTranscribe('" + txtSpeech.ClientID + "', '" + txtField.ClientID + "');");
								}
							}
							else
							{
								txtField.MaxLength = nFORMAT_MAX_LENGTH   ;
								// 06/20/2009 Paul.  The NewRecord forms do not specify a size. 
								if ( nFORMAT_SIZE > 0 )
									txtField.Attributes.Add("size", nFORMAT_SIZE.ToString());
								txtField.TextMode  = TextBoxMode.SingleLine;
								// 08/22/2012 Paul.  Apple and Android devices should support speech and handwriting. 
								// Speech does not work on text areas, only add to single line text boxes. 
								// 08/31/2012 Paul. Exclude speech from Password fields. 
								if ( String.Compare(sFIELD_TYPE, "TextBox", true) == 0 && Utils.SupportsSpeech && Sql.ToBoolean(Application["CONFIG.enable_speech"]) )
								{
									txtField.Attributes.Add("speech", "speech");
									txtField.Attributes.Add("x-webkit-speech", "x-webkit-speech");
								}
							}
							if ( bLayoutMode )
							{
								txtField.Text     = sDATA_FIELD;
								txtField.ReadOnly = true       ;
							}
							else if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
							{
								// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
								// 11/22/2010 Paul.  There is no way to get the DbType from a DataTable/DataRow, so just rely upon the detection of Decimal. 
								//int    nOrdinal  = rdr.GetOrdinal(sDATA_FIELD);
								string sTypeName = String.Empty;  // rdr.GetDataTypeName(nOrdinal);
								Type tDATA_FIELD = rdr[sDATA_FIELD].GetType();
								// 03/04/2006 Paul.  Display currency in the proper format. 
								// Only SQL Server is likely to return the money type, so also include the decimal type. 
								if ( sTypeName == "money" || tDATA_FIELD == typeof(System.Decimal) )
								{
									// 06/02/2016 Paul.  We need to be able to define the currency format. 
									if ( (sTypeName == "money" || sDATA_FORMAT == "{0:c}") && C10n != null )
									{
										Decimal d = C10n.ToCurrency(Convert.ToDecimal(rdr[sDATA_FIELD]));
										// 06/02/2016 Paul.  We do not want to include the currency symbol, so don't use .ToString("c") 
										txtField.Text = d.ToString("#,##0.00");
									}
									else if ( Sql.IsEmptyString(sDATA_FORMAT) )
										txtField.Text = Sql.ToDecimal(rdr[sDATA_FIELD]).ToString("#,##0.00");
									else
										txtField.Text = Sql.ToDecimal(rdr[sDATA_FIELD]).ToString(sDATA_FORMAT);
								}
								// 01/19/2010 Paul.  Now that ProjectTask.ESTIMATED_EFFORT is a float, we need to format the value. 
								else if ( tDATA_FIELD == typeof(System.Double) )
								{
									if ( Sql.IsEmptyString(sDATA_FORMAT) )
										txtField.Text = Sql.ToDouble(rdr[sDATA_FIELD]).ToString("0.00");
									else
										txtField.Text = Sql.ToDouble(rdr[sDATA_FIELD]).ToString(sDATA_FORMAT);
								}
								else if ( tDATA_FIELD == typeof(System.Int32) )
								{
									if ( Sql.IsEmptyString(sDATA_FORMAT) )
										txtField.Text = Sql.ToInteger(rdr[sDATA_FIELD]).ToString("0");
									else
										txtField.Text = Sql.ToInteger(rdr[sDATA_FIELD]).ToString(sDATA_FORMAT);
								}
								else
									txtField.Text = Sql.ToString(rdr[sDATA_FIELD]);
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtField.Text = ex.Message;
						}
						if ( String.Compare(sFIELD_TYPE, "Password", true) == 0 )
							txtField.TextMode = TextBoxMode.Password;
						// 09/16/2012 Paul.  Add onchange event to TextBox. 
						else if ( String.Compare(sFIELD_TYPE, "TextBox", true) == 0 && !bLayoutMode )
						{
							if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
								txtField.Attributes.Add("onchange" , sONCLICK_SCRIPT);
						}
						// 06/21/2009 Paul.  Automatically associate the TextBox with a Submit button. 
						// 11/01/2015 Paul.  Do not auto-submit for enter in text area. 
						if ( !bLayoutMode && !Sql.IsEmptyString(sSubmitClientID) && txtField.TextMode != TextBoxMode.MultiLine )
						{
							if ( mgrAjax != null )
							{
								// 06/21/2009 Paul.  The name of the script block must be unique for each instance of this control. 
								// 06/21/2009 Paul.  Use RegisterStartupScript instead of RegisterClientScriptBlock so that the script will run after the control has been created. 
								ScriptManager.RegisterStartupScript(Page, typeof(System.String), txtField.ClientID + "_EnterKey", Utils.RegisterEnterKeyPress(txtField.ClientID, sSubmitClientID), false);
							}
							else
							{
								#pragma warning disable 618
								Page.ClientScript.RegisterStartupScript(typeof(System.String), txtField.ClientID + "_EnterKey", Utils.RegisterEnterKeyPress(txtField.ClientID, sSubmitClientID));
								#pragma warning restore 618
							}
						}
						// 11/11/2010 Paul.  Always create the Required Field Validator so that we can Enable/Disable in a Rule. 
						if ( !bLayoutMode && /* bUI_REQUIRED && */ !Sql.IsEmptyString(sDATA_FIELD) )
						{
							RequiredFieldValidator reqNAME = new RequiredFieldValidator();
							reqNAME.ID                 = sDATA_FIELD + "_REQUIRED";
							reqNAME.ControlToValidate  = txtField.ID;
							reqNAME.ErrorMessage       = L10n.Term(".ERR_REQUIRED_FIELD");
							reqNAME.CssClass           = "required";
							reqNAME.EnableViewState    = false;
							// 01/16/2006 Paul.  We don't enable required fields until we attempt to save. 
							// This is to allow unrelated form actions; the Cancel button is a good example. 
							reqNAME.EnableClientScript = false;
							reqNAME.Enabled            = false;
							reqNAME.Style.Add("padding-left", "4px");
							tdField.Controls.Add(reqNAME);
						}
						if ( !bLayoutMode && !Sql.IsEmptyString(sDATA_FIELD) )
						{
							// 01/18/2010 Paul.  We only need to validate if the field is Writeable. 
							if ( sVALIDATION_TYPE == "RegularExpressionValidator" && !Sql.IsEmptyString(sREGULAR_EXPRESSION) && !Sql.IsEmptyString(sFIELD_VALIDATOR_MESSAGE) && bIsWriteable )
							{
								RegularExpressionValidator reqVALIDATOR = new RegularExpressionValidator();
								reqVALIDATOR.ID                   = sDATA_FIELD + "_VALIDATOR";
								reqVALIDATOR.ControlToValidate    = txtField.ID;
								reqVALIDATOR.ErrorMessage         = L10n.Term(sFIELD_VALIDATOR_MESSAGE);
								reqVALIDATOR.ValidationExpression = sREGULAR_EXPRESSION;
								reqVALIDATOR.CssClass             = "required";
								reqVALIDATOR.EnableViewState      = false;
								// 04/02/2008 Paul.  We don't enable required fields until we attempt to save. 
								// This is to allow unrelated form actions; the Cancel button is a good example. 
								reqVALIDATOR.EnableClientScript   = false;
								reqVALIDATOR.Enabled              = false;
								reqVALIDATOR.Style.Add("padding-left", "4px");
								tdField.Controls.Add(reqVALIDATOR);
							}
						}
					}
				}
				// 04/13/2016 Paul.  Add ZipCode lookup. 
				else if ( String.Compare(sFIELD_TYPE, "ZipCodePopup", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						TextBox txtField = new TextBox();
						tdField.Controls.Add(txtField);
						txtField.ID       = sDATA_FIELD;
						txtField.TabIndex = nFORMAT_TAB_INDEX;
						txtField.Visible  = bLayoutMode || bIsReadable;
						txtField.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							if ( nFORMAT_ROWS > 0 && nFORMAT_COLUMNS > 0 )
							{
								txtField.Rows     = nFORMAT_ROWS   ;
								txtField.Columns  = nFORMAT_COLUMNS;
								txtField.TextMode = TextBoxMode.MultiLine;
								
								// http://www.labnol.org/software/add-speech-recognition-to-website/19989/
								if ( Utils.SupportsSpeech && Sql.ToBoolean(Application["CONFIG.enable_speech"]) )
								{
									TextBox txtSpeech = new TextBox();
									tdField.Controls.Add(txtSpeech);
									txtSpeech.ID       = sDATA_FIELD + "_SPEECH";
									txtSpeech.TabIndex = nFORMAT_TAB_INDEX;
									txtSpeech.Visible  = bLayoutMode || bIsReadable;
									txtSpeech.Enabled  = bLayoutMode || bIsWriteable;
									txtSpeech.Attributes.Add("style", "width: 15px; height: 20px; border: 0px; background-color: transparent; vertical-align:top;");
									txtSpeech.Attributes.Add("speech", "speech");
									txtSpeech.Attributes.Add("x-webkit-speech", "x-webkit-speech");
									txtSpeech.Attributes.Add("onspeechchange"      , "SpeechTranscribe('" + txtSpeech.ClientID + "', '" + txtField.ClientID + "');");
									txtSpeech.Attributes.Add("onwebkitspeechchange", "SpeechTranscribe('" + txtSpeech.ClientID + "', '" + txtField.ClientID + "');");
								}
							}
							else
							{
								txtField.MaxLength = nFORMAT_MAX_LENGTH   ;
								if ( nFORMAT_SIZE > 0 )
									txtField.Attributes.Add("size", nFORMAT_SIZE.ToString());
								txtField.TextMode  = TextBoxMode.SingleLine;
								txtField.Attributes.Add("speech", "speech");
								txtField.Attributes.Add("x-webkit-speech", "x-webkit-speech");
							}
							if ( bLayoutMode )
							{
								txtField.Text     = sDATA_FIELD;
								txtField.ReadOnly = true       ;
							}
							else if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
							{
								string sTypeName = String.Empty;
								Type tDATA_FIELD = rdr[sDATA_FIELD].GetType();
								txtField.Text = Sql.ToString(rdr[sDATA_FIELD]);
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtField.Text = ex.Message;
						}
						if ( !bLayoutMode && !Sql.IsEmptyString(sSubmitClientID) && txtField.TextMode != TextBoxMode.MultiLine )
						{
							if ( mgrAjax != null )
							{
								ScriptManager.RegisterStartupScript(Page, typeof(System.String), txtField.ClientID + "_EnterKey", Utils.RegisterEnterKeyPress(txtField.ClientID, sSubmitClientID), false);
							}
							else
							{
								#pragma warning disable 618
								Page.ClientScript.RegisterStartupScript(typeof(System.String), txtField.ClientID + "_EnterKey", Utils.RegisterEnterKeyPress(txtField.ClientID, sSubmitClientID));
								#pragma warning restore 618
							}
						}
						Literal litNBSP = new Literal();
						tdField.Controls.Add(litNBSP);
						litNBSP.Text = "&nbsp;";
						
						// 06/20/2009 Paul.  The Select button will go on a separate row in the NewRecord form. 
						if ( LABEL_WIDTH == "100%" && sFIELD_WIDTH == "0%" && nDATA_COLUMNS == 1 )
						{
							nRowIndex++;
							trField = new HtmlTableRow();
							tbl.Rows.Insert(nRowIndex, trField);
							tdField = new HtmlTableCell();
							trField.Cells.Add(tdField);
						}
						HtmlInputButton btnLookup = new HtmlInputButton("button");
						tdField.Controls.Add(btnLookup);
						btnLookup.ID = sDATA_FIELD + "_btnLookup";
						btnLookup.Attributes.Add("class", "button");
						string[] arrDATA_FORMAT = sDATA_FORMAT.Split(',');
						if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
							btnLookup.Attributes.Add("onclick"  , sONCLICK_SCRIPT);
						else
						{
							btnLookup.Attributes.Add("onclick"  , "return ZipCode_AddressPopup('" + txtField.ClientID + "');");
						}
						btnLookup.Attributes.Add("title", L10n.Term("ZipCodes.LBL_LOOKUP_BUTTON_LABEL"));
						btnLookup.Value    = L10n.Term("ZipCodes.LBL_LOOKUP_BUTTON_LABEL");
						btnLookup.Visible  =   bLayoutMode || bIsReadable;
						btnLookup.Disabled = !(bLayoutMode || bIsWriteable);
						if ( bAjaxAutoComplete && !bLayoutMode && mgrAjax != null && bIsWriteable )
						{
							sMODULE_TYPE = "ZipCodes";
							string sTABLE_NAME    = Sql.ToString(Application["Modules." + sMODULE_TYPE + ".TableName"   ]);
							string sRELATIVE_PATH = Sql.ToString(Application["Modules." + sMODULE_TYPE + ".RelativePath"]);
							
							if ( !Sql.IsEmptyString(sDATA_FIELD) && sDATA_FIELD.EndsWith("POSTALCODE") && !Sql.IsEmptyString(sRELATIVE_PATH) && Utils.CachedFileExists(HttpContext.Current, sRELATIVE_PATH + "AutoComplete.asmx") )
							{
								txtField.Attributes.Add("onblur", "ZIPCODES_POSTALCODE_Changed(this);");
								// 09/03/2009 Paul.  Add a PREV_ field so that we can detect a text change. 
								HtmlInputHidden hidPREVIOUS = new HtmlInputHidden();
								tdField.Controls.Add(hidPREVIOUS);
								hidPREVIOUS.ID = sDATA_FIELD + "_PREV";
								try
								{
									if ( !bLayoutMode )
									{
										if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
											hidPREVIOUS.Value = Sql.ToString(rdr[sDATA_FIELD]);
									}
								}
								catch(Exception ex)
								{
									SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
								}
								
								AjaxControlToolkit.AutoCompleteExtender auto = new AjaxControlToolkit.AutoCompleteExtender();
								tdField.Controls.Add(auto);
								auto.ID                   = "auto" + txtField.ID;
								auto.TargetControlID      = txtField.ID;
								auto.ServiceMethod        = sTABLE_NAME + "_" + txtField.ID + "_" + "List";
								auto.ServicePath          = sRELATIVE_PATH + "AutoComplete.asmx";
								auto.MinimumPrefixLength  = 2;
								auto.CompletionInterval   = 250;
								auto.EnableCaching        = true;
								auto.CompletionSetCount   = Crm.Config.CompletionSetCount();
								auto.UseContextKey        = true;
								ScriptManager.RegisterStartupScript(Page, typeof(System.String), txtField.ClientID + "_ContextKey", "ZipCodes_SetContextKey('" + auto.ClientID + "', '" + txtField.ClientID + "');", true);
								
								ServiceReference svc = new ServiceReference(sRELATIVE_PATH + "AutoComplete.asmx");
								ScriptReference  scr = new ScriptReference (sRELATIVE_PATH + "AutoComplete.js"  );
								if ( !mgrAjax.Services.Contains(svc) )
									mgrAjax.Services.Add(svc);
								if ( !mgrAjax.Scripts.Contains(scr) )
									mgrAjax.Scripts.Add(scr);
								
								litNBSP = new Literal();
								tdField.Controls.Add(litNBSP);
								litNBSP.Text = "&nbsp;";
								HtmlGenericControl spnAjaxErrors = new HtmlGenericControl("span");
								tdField.Controls.Add(spnAjaxErrors);
								spnAjaxErrors.ID = txtField.ID + "_AjaxErrors";
								spnAjaxErrors.Attributes.Add("style", "color:Red");
								spnAjaxErrors.EnableViewState = false;
							}
						}
						
						if ( !bLayoutMode && /* bUI_REQUIRED && */ !Sql.IsEmptyString(sDATA_FIELD) )
						{
							RequiredFieldValidator reqNAME = new RequiredFieldValidator();
							reqNAME.ID                 = sDATA_FIELD + "_REQUIRED";
							reqNAME.ControlToValidate  = txtField.ID;
							reqNAME.ErrorMessage       = L10n.Term(".ERR_REQUIRED_FIELD");
							reqNAME.CssClass           = "required";
							reqNAME.EnableViewState    = false;
							reqNAME.EnableClientScript = false;
							reqNAME.Enabled            = false;
							reqNAME.Style.Add("padding-left", "4px");
							tdField.Controls.Add(reqNAME);
						}
						if ( !bLayoutMode && !Sql.IsEmptyString(sDATA_FIELD) )
						{
							if ( sVALIDATION_TYPE == "RegularExpressionValidator" && !Sql.IsEmptyString(sREGULAR_EXPRESSION) && !Sql.IsEmptyString(sFIELD_VALIDATOR_MESSAGE) && bIsWriteable )
							{
								RegularExpressionValidator reqVALIDATOR = new RegularExpressionValidator();
								reqVALIDATOR.ID                   = sDATA_FIELD + "_VALIDATOR";
								reqVALIDATOR.ControlToValidate    = txtField.ID;
								reqVALIDATOR.ErrorMessage         = L10n.Term(sFIELD_VALIDATOR_MESSAGE);
								reqVALIDATOR.ValidationExpression = sREGULAR_EXPRESSION;
								reqVALIDATOR.CssClass             = "required";
								reqVALIDATOR.EnableViewState      = false;
								reqVALIDATOR.EnableClientScript   = false;
								reqVALIDATOR.Enabled              = false;
								reqVALIDATOR.Style.Add("padding-left", "4px");
								tdField.Controls.Add(reqVALIDATOR);
							}
						}
					}
				}
				// 04/02/2009 Paul.  Add support for FCKEditor to the EditView. 
				else if ( String.Compare(sFIELD_TYPE, "HtmlEditor", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
						CKEditorControl txtField = new CKEditorControl();
						tdField.Controls.Add(txtField);
						txtField.ID         = sDATA_FIELD;
						txtField.Toolbar    = "SplendidCRM";
						// 09/18/2011 Paul.  Set the language for CKEditor. 
						txtField.Language   = L10n.NAME;
						txtField.BasePath   = "~/ckeditor/";
						// 04/26/2012 Paul.  Add file uploader. 
						txtField.FilebrowserUploadUrl    = txtField.ResolveUrl("~/ckeditor/upload.aspx");
						txtField.FilebrowserBrowseUrl    = txtField.ResolveUrl("~/Images/Popup.aspx");
						//txtField.FilebrowserWindowWidth  = "640";
						//txtField.FilebrowserWindowHeight = "480";
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						txtField.Visible  = bLayoutMode || bIsReadable;
						try
						{
							if ( nFORMAT_ROWS > 0 && nFORMAT_COLUMNS > 0 )
							{
								txtField.Height = nFORMAT_ROWS   ;
								txtField.Width  = nFORMAT_COLUMNS;
							}
							if ( bLayoutMode )
							{
								txtField.Text     = sDATA_FIELD;
							}
							else if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
							{
								txtField.Text = Sql.ToString(rdr[sDATA_FIELD]);
								// 01/18/2010 Paul.  FCKEditor does not have an Enable field, so just hide and replace with a Literal control. 
								if ( bIsReadable && !bIsWriteable )
								{
									txtField.Visible = false;
									Literal litField = new Literal();
									litField.ID = sDATA_FIELD + "_ReadOnly";
									tdField.Controls.Add(litField);
									litField.Text = Sql.ToString(rdr[sDATA_FIELD]);
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtField.Text = ex.Message;
						}
						// 04/02/2009 Paul.  The standard RequiredFieldValidator will not work on the FCKeditor. 
						/*
						if ( !bLayoutMode && bUI_REQUIRED && !Sql.IsEmptyString(sDATA_FIELD) )
						{
							RequiredFieldValidator reqNAME = new RequiredFieldValidator();
							reqNAME.ID                 = sDATA_FIELD + "_REQUIRED";
							reqNAME.ControlToValidate  = txtField.ID;
							reqNAME.ErrorMessage       = L10n.Term(".ERR_REQUIRED_FIELD");
							reqNAME.CssClass           = "required";
							reqNAME.EnableViewState    = false;
							// 01/16/2006 Paul.  We don't enable required fields until we attempt to save. 
							// This is to allow unrelated form actions; the Cancel button is a good example. 
							reqNAME.EnableClientScript = false;
							reqNAME.Enabled            = false;
							reqNAME.Style.Add("padding-left", "4px");
							tdField.Controls.Add(reqNAME);
						}
						*/
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "DatePicker", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/03/2005 Paul.  UserControls must be loaded. 
						DatePicker ctlDate = tbl.Page.LoadControl("~/_controls/DatePicker.ascx") as DatePicker;
						tdField.Controls.Add(ctlDate);
						// 01/01/2018 Paul.  Allow searching of multiple date fields. 
						ctlDate.ID = sDATA_FIELD.Replace(" ", "_");
						// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
						ctlDate.NotPostBack = bNotPostBack;
						// 05/10/2006 Paul.  Set the tab index. 
						ctlDate.TabIndex = nFORMAT_TAB_INDEX;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						ctlDate.Visible  = bLayoutMode || bIsReadable;
						ctlDate.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							if ( rdr != null )
								ctlDate.Value = T10n.FromServerTime(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						// 01/16/2006 Paul.  We validate elsewhere. 
						/*
						if ( !bLayoutMode && bUI_REQUIRED && !Sql.IsEmptyString(sDATA_FIELD) )
						{
							ctlDate.Required = true;
						}
						*/
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "DateRange", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/17/2007 Paul.  Use table to align before and after labels. 
						Table tblDateRange = new Table();
						tdField.Controls.Add(tblDateRange);
						TableRow trAfter = new TableRow();
						TableRow trBefore = new TableRow();
						tblDateRange.Rows.Add(trAfter);
						tblDateRange.Rows.Add(trBefore);
						TableCell tdAfterLabel  = new TableCell();
						TableCell tdAfterData   = new TableCell();
						TableCell tdBeforeLabel = new TableCell();
						TableCell tdBeforeData  = new TableCell();
						trAfter .Cells.Add(tdAfterLabel );
						trAfter .Cells.Add(tdAfterData  );
						trBefore.Cells.Add(tdBeforeLabel);
						trBefore.Cells.Add(tdBeforeData );

						// 12/03/2005 Paul.  UserControls must be loaded. 
						DatePicker ctlDateStart = tbl.Page.LoadControl("~/_controls/DatePicker.ascx") as DatePicker;
						DatePicker ctlDateEnd   = tbl.Page.LoadControl("~/_controls/DatePicker.ascx") as DatePicker;
						Literal litAfterLabel  = new Literal();
						Literal litBeforeLabel = new Literal();
						litAfterLabel .Text = L10n.Term("SavedSearch.LBL_SEARCH_AFTER" );
						litBeforeLabel.Text = L10n.Term("SavedSearch.LBL_SEARCH_BEFORE");
						//tdField.Controls.Add(litAfterLabel );
						//tdField.Controls.Add(ctlDateStart  );
						//tdField.Controls.Add(litBeforeLabel);
						//tdField.Controls.Add(ctlDateEnd    );
						tdAfterLabel .Controls.Add(litAfterLabel );
						tdAfterData  .Controls.Add(ctlDateStart  );
						tdBeforeLabel.Controls.Add(litBeforeLabel);
						tdBeforeData .Controls.Add(ctlDateEnd    );

						// 01/01/2018 Paul.  Allow searching of multiple date fields. 
						ctlDateStart.ID = sDATA_FIELD.Replace(" ", "_") + "_AFTER";
						ctlDateEnd  .ID = sDATA_FIELD.Replace(" ", "_") + "_BEFORE";
						// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
						ctlDateStart.NotPostBack = bNotPostBack;
						ctlDateEnd  .NotPostBack = bNotPostBack;
						// 05/10/2006 Paul.  Set the tab index. 
						ctlDateStart.TabIndex = nFORMAT_TAB_INDEX;
						ctlDateEnd  .TabIndex = nFORMAT_TAB_INDEX;

						// 01/18/2010 Paul.  Apply ACL Field Security. 
						tblDateRange.Visible  = bLayoutMode || bIsReadable;
						ctlDateStart.Visible  = bLayoutMode || bIsReadable;
						ctlDateStart.Enabled  = bLayoutMode || bIsWriteable;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						ctlDateEnd  .Visible  = bLayoutMode || bIsReadable;
						ctlDateEnd  .Enabled  = bLayoutMode || bIsWriteable;
						// 06/21/2009 Paul.  Move SearchView EnterKey registration from SearchView.asx to here. 
						// 01/18/2010 Paul.  Don't register the EnterKey unless the date is Writeable. 
						if ( !bLayoutMode && !Sql.IsEmptyString(sSubmitClientID) && bIsWriteable )
						{
							if ( mgrAjax != null )
							{
								// 06/21/2009 Paul.  The name of the script block must be unique for each instance of this control. 
								// 06/21/2009 Paul.  Use RegisterStartupScript instead of RegisterClientScriptBlock so that the script will run after the control has been created. 
								ScriptManager.RegisterStartupScript(Page, typeof(System.String), ctlDateStart.DateClientID + "_EnterKey", Utils.RegisterEnterKeyPress(ctlDateStart.DateClientID, sSubmitClientID), false);
								ScriptManager.RegisterStartupScript(Page, typeof(System.String), ctlDateEnd  .DateClientID + "_EnterKey", Utils.RegisterEnterKeyPress(ctlDateEnd  .DateClientID, sSubmitClientID), false);
							}
							else
							{
								#pragma warning disable 618
								Page.ClientScript.RegisterStartupScript(typeof(System.String), ctlDateStart.DateClientID + "_EnterKey", Utils.RegisterEnterKeyPress(ctlDateStart.DateClientID, sSubmitClientID));
								Page.ClientScript.RegisterStartupScript(typeof(System.String), ctlDateEnd  .DateClientID + "_EnterKey", Utils.RegisterEnterKeyPress(ctlDateEnd  .DateClientID, sSubmitClientID));
								#pragma warning restore 618
							}
						}
						try
						{
							if ( rdr != null )
							{
								ctlDateStart.Value = T10n.FromServerTime(rdr[sDATA_FIELD]);
								ctlDateEnd  .Value = T10n.FromServerTime(rdr[sDATA_FIELD]);
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						// 01/16/2006 Paul.  We validate elsewhere. 
						/*
						if ( !bLayoutMode && bUI_REQUIRED && !Sql.IsEmptyString(sDATA_FIELD) )
						{
							ctlDateStart.Required = true;
							ctlDateEnd  .Required = true;
						}
						*/
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "DateTimePicker", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/03/2005 Paul.  UserControls must be loaded. 
						DateTimePicker ctlDate = tbl.Page.LoadControl("~/_controls/DateTimePicker.ascx") as DateTimePicker;
						tdField.Controls.Add(ctlDate);
						ctlDate.ID = sDATA_FIELD;
						// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
						ctlDate.NotPostBack = bNotPostBack;
						// 05/10/2006 Paul.  Set the tab index. 
						ctlDate.TabIndex = nFORMAT_TAB_INDEX;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						ctlDate.Visible  = bLayoutMode || bIsReadable;
						ctlDate.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							if ( rdr != null )
								ctlDate.Value = T10n.FromServerTime(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "DateTimeEdit", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/03/2005 Paul.  UserControls must be loaded. 
						DateTimeEdit ctlDate = tbl.Page.LoadControl("~/_controls/DateTimeEdit.ascx") as DateTimeEdit;
						tdField.Controls.Add(ctlDate);
						ctlDate.ID = sDATA_FIELD;
						// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
						ctlDate.NotPostBack = bNotPostBack;
						// 05/10/2006 Paul.  Set the tab index. 
						ctlDate.TabIndex = nFORMAT_TAB_INDEX;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						ctlDate.Visible  = bLayoutMode || bIsReadable;
						ctlDate.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							if ( rdr != null )
								ctlDate.Value = T10n.FromServerTime(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						if ( !bLayoutMode && bUI_REQUIRED )
						{
							ctlDate.EnableNone = false;
						}
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				// 06/20/2009 Paul.  Add DateTimeNewRecord so that the NewRecord forms can use the Dynamic rendering. 
				else if ( String.Compare(sFIELD_TYPE, "DateTimeNewRecord", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/03/2005 Paul.  UserControls must be loaded. 
						DateTimeEdit ctlDate = tbl.Page.LoadControl("~/_controls/DateTimeNewRecord.ascx") as DateTimeEdit;
						tdField.Controls.Add(ctlDate);
						ctlDate.ID = sDATA_FIELD;
						// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
						ctlDate.NotPostBack = bNotPostBack;
						// 05/10/2006 Paul.  Set the tab index. 
						ctlDate.TabIndex = nFORMAT_TAB_INDEX;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						ctlDate.Visible  = bLayoutMode || bIsReadable;
						ctlDate.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							if ( rdr != null )
								ctlDate.Value = T10n.FromServerTime(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						if ( !bLayoutMode && bUI_REQUIRED )
						{
							ctlDate.EnableNone = false;
						}
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "File", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						HtmlInputHidden ctlHidden = null;
						if ( !bLayoutMode )
						{
							HtmlInputFile ctlField = new HtmlInputFile();
							tdField.Controls.Add(ctlField);
							// 04/17/2006 Paul.  The image needs to reference the file control. 
							// 11/25/2010 Paul.  Appending _File breaks the previous behavior of Notes, Bugs and Documents.
							// 11/25/2010 Paul.  The file field is special in that it may not exist as a table column. 
							// 12/01/2010 Paul.  rdr will not be available during postback, so we cannot use it do determine the field name. 
							// 12/01/2010 Paul.  The only solution is to fix the naming convention for Notes, Bugs and Documents. 
							//if ( rdr != null && rdr.Table.Columns.Contains(sDATA_FIELD) )
							{
								ctlField.ID = sDATA_FIELD + "_File";
								ctlHidden = new HtmlInputHidden();
								tdField.Controls.Add(ctlHidden);
								ctlHidden.ID = sDATA_FIELD;
							}
							//else
							//{
							//	ctlField.ID = sDATA_FIELD;
							//}
							ctlField.MaxLength = nFORMAT_MAX_LENGTH;
							ctlField.Size      = nFORMAT_SIZE;
							ctlField.Attributes.Add("TabIndex", nFORMAT_TAB_INDEX.ToString());
							// 01/18/2010 Paul.  Apply ACL Field Security. 
							ctlField.Visible  =   bLayoutMode || bIsReadable;
							ctlField.Disabled = !(bLayoutMode || bIsWriteable);

							Literal litBR = new Literal();
							litBR.Text = "<br />";
							tdField.Controls.Add(litBR);

							// 11/11/2010 Paul.  Always create the Required Field Validator so that we can Enable/Disable in a Rule. 
							if ( !bLayoutMode /* && bUI_REQUIRED */ )
							{
								RequiredFieldValidator reqNAME = new RequiredFieldValidator();
								reqNAME.ID                 = sDATA_FIELD + "_REQUIRED";
								reqNAME.ControlToValidate  = ctlField.ID;
								reqNAME.ErrorMessage       = L10n.Term(".ERR_REQUIRED_FIELD");
								reqNAME.CssClass           = "required";
								reqNAME.EnableViewState    = false;
								// 01/16/2006 Paul.  We don't enable required fields until we attempt to save. 
								// This is to allow unrelated form actions; the Cancel button is a good example. 
								reqNAME.EnableClientScript = false;
								reqNAME.Enabled            = false;
								reqNAME.Style.Add("padding-left", "4px");
								tdField.Controls.Add(reqNAME);
							}
						}
						
						// 11/23/2010 Paul.  File needs to act like an Image. 
						HyperLink lnkField = new HyperLink();
						// 04/13/2006 Paul.  Give the image a name so that it can be validated with SplendidTest. 
						lnkField.ID = "lnk" + sDATA_FIELD;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						lnkField.Visible  = bLayoutMode || bIsReadable;
						try
						{
							if ( bLayoutMode )
							{
								Literal litField = new Literal();
								litField.Text = sDATA_FIELD;
								tdField.Controls.Add(litField);
							}
							else if ( rdr != null && rdr.Table.Columns.Contains(sDATA_FIELD) )
							{
								// 11/25/2010 Paul.  The file field is special in that it may not exist as a table column. 
								if ( ctlHidden != null && !Sql.IsEmptyString(rdr[sDATA_FIELD]) )
								{
									ctlHidden.Value = Sql.ToString(rdr[sDATA_FIELD]);
									lnkField.NavigateUrl = "~/Images/Image.aspx?ID=" + ctlHidden.Value;
									lnkField.Text = Crm.Modules.ItemName(Application, "Images", ctlHidden.Value);
									// 04/13/2006 Paul.  Only add the image if it exists. 
									tdField.Controls.Add(lnkField);
									
									// 04/17/2006 Paul.  Provide a clear button. 
									Literal litClear = new Literal();
									litClear.Text = "&nbsp; <input type=\"button\" class=\"button\" onclick=\"document.getElementById('" + ctlHidden.ClientID + "').value='';document.getElementById('" + lnkField.ClientID + "').innerHTML='';" + "\"  value='" + "  " + L10n.Term(".LBL_CLEAR_BUTTON_LABEL" ) + "  " + "' title='" + L10n.Term(".LBL_CLEAR_BUTTON_TITLE" ) + "' />";
									tdField.Controls.Add(litClear);
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							Literal litField = new Literal();
							litField.Text = ex.Message;
							tdField.Controls.Add(litField);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "Image", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						HtmlInputHidden ctlHidden = new HtmlInputHidden();
						if ( !bLayoutMode )
						{
							tdField.Controls.Add(ctlHidden);
							ctlHidden.ID = sDATA_FIELD;

							HtmlInputFile ctlField = new HtmlInputFile();
							tdField.Controls.Add(ctlField);
							// 04/17/2006 Paul.  The image needs to reference the file control. 
							ctlField.ID = sDATA_FIELD + "_File";
							ctlField.MaxLength = nFORMAT_MAX_LENGTH;
							ctlField.Size      = nFORMAT_SIZE;
							ctlField.Attributes.Add("TabIndex", nFORMAT_TAB_INDEX.ToString());
							// 01/18/2010 Paul.  Apply ACL Field Security. 
							ctlField.Visible  =   bLayoutMode || bIsReadable;
							ctlField.Disabled = !(bLayoutMode || bIsWriteable);

							Literal litBR = new Literal();
							litBR.Text = "<br />";
							tdField.Controls.Add(litBR);

							// 11/25/2010 Paul.  Add required field validator. 
							if ( !bLayoutMode /* && bUI_REQUIRED */ )
							{
								RequiredFieldValidator reqNAME = new RequiredFieldValidator();
								reqNAME.ID                 = sDATA_FIELD + "_REQUIRED";
								reqNAME.ControlToValidate  = ctlField.ID;
								reqNAME.ErrorMessage       = L10n.Term(".ERR_REQUIRED_FIELD");
								reqNAME.CssClass           = "required";
								reqNAME.EnableViewState    = false;
								// 01/16/2006 Paul.  We don't enable required fields until we attempt to save. 
								// This is to allow unrelated form actions; the Cancel button is a good example. 
								reqNAME.EnableClientScript = false;
								reqNAME.Enabled            = false;
								reqNAME.Style.Add("padding-left", "4px");
								tdField.Controls.Add(reqNAME);
							}
						}
						
						Image imgField = new Image();
						// 04/13/2006 Paul.  Give the image a name so that it can be validated with SplendidTest. 
						imgField.ID = "img" + sDATA_FIELD;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						imgField.Visible  = bLayoutMode || bIsReadable;
						try
						{
							if ( bLayoutMode )
							{
								Literal litField = new Literal();
								litField.Text = sDATA_FIELD;
								tdField.Controls.Add(litField);
							}
							else if ( rdr != null )
							{
								if ( !Sql.IsEmptyString(rdr[sDATA_FIELD]) )
								{
									ctlHidden.Value = Sql.ToString(rdr[sDATA_FIELD]);
									// 04/09/2019 Paul.  Value may contain an URL. 
									if ( ctlHidden.Value.Contains("/") || ctlHidden.Value.StartsWith("http") )
										imgField.ImageUrl = ctlHidden.Value;
									else
										imgField.ImageUrl = "~/Images/Image.aspx?ID=" + ctlHidden.Value;
									// 04/13/2006 Paul.  Only add the image if it exists. 
									tdField.Controls.Add(imgField);
									// 04/09/2019 Paul.  Shrink image to fit into container. 
									imgField.Style.Add("object-fit", "scale-down");
									imgField.Style.Add("width"     , "400px");
									imgField.Style.Add("height"    , "400px");
									
									// 04/17/2006 Paul.  Provide a clear button. 
									Literal litClear = new Literal();
									litClear.Text = "&nbsp; <input type=\"button\" class=\"button\" onclick=\"document.getElementById('" + ctlHidden.ClientID + "').value='';document.getElementById('" + imgField.ClientID + "').src='';" + "\"  value='" + "  " + L10n.Term(".LBL_CLEAR_BUTTON_LABEL" ) + "  " + "' title='" + L10n.Term(".LBL_CLEAR_BUTTON_TITLE" ) + "' />";
									tdField.Controls.Add(litClear);
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							Literal litField = new Literal();
							litField.Text = ex.Message;
							tdField.Controls.Add(litField);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "AddressButtons", true) == 0 && (btnCopyRight == null) && (btnCopyLeft == null) )
				{
					// 06/04/2016 Paul.  With stacked layout, the tdField and tdLabel are the same, so removing from row would eliminate the buttons. 
					if ( !SplendidDynamic.StackedLayout(Page.Theme) )
						trField.Cells.Remove(tdField);
					tdLabel.Width = "10%";
					tdLabel.RowSpan = nROWSPAN;
					tdLabel.VAlign  = "middle";
					tdLabel.Align   = "center";
					tdLabel.Attributes.Remove("class");
					tdLabel.Attributes.Add("class", "tabFormAddDel");
					// 05/08/2010 Paul.  Define the copy buttons outside the loop so that we can replace the javascriptwith embedded code.  
					// This is so that the javascript will run properly in the SixToolbar UpdatePanel. 
					btnCopyRight = new HtmlInputButton("button");
					btnCopyLeft  = new HtmlInputButton("button");
					Literal         litSpacer    = new Literal();
					tdLabel.Controls.Add(btnCopyRight);
					tdLabel.Controls.Add(litSpacer   );
					tdLabel.Controls.Add(btnCopyLeft );
					btnCopyRight.Attributes.Add("title"  , L10n.Term("Accounts.NTC_COPY_BILLING_ADDRESS" ));
					//btnCopyRight.Attributes.Add("onclick", "return copyAddressRight()");
					btnCopyRight.Value = ">>";
					litSpacer.Text = "<br><br>";
					btnCopyLeft .Attributes.Add("title"  , L10n.Term("Accounts.NTC_COPY_SHIPPING_ADDRESS" ));
					//btnCopyLeft .Attributes.Add("onclick", "return copyAddressLeft()");
					btnCopyLeft .Value = "<<";
					nColIndex = 0;
					// 06/04/2016 Paul.  Add the label to make the actions easier to find. 
					if ( bLayoutMode && tdAction != null )
					{
						Literal litField = new Literal();
						litField.Text = "AddressButtons";
						tdAction.Controls.Add(litField);
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "Hidden", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						HtmlInputHidden hidID = new HtmlInputHidden();
						tdField.Controls.Add(hidID);
						hidID.ID = sDATA_FIELD;
						try
						{
							if ( bLayoutMode )
							{
								TextBox txtNAME = new TextBox();
								tdField.Controls.Add(txtNAME);
								txtNAME.ReadOnly = true;
								// 11/25/2006 Paul.   Turn off viewstate so that we can fix the text on postback. 
								txtNAME.EnableViewState = false;
								txtNAME.Text    = sDATA_FIELD;
								txtNAME.Enabled = false         ;
							}
							else
							{
								// 02/28/2008 Paul.  When the hidden field is the first in the row, we end up with a blank row. 
								// Just ignore for now as IE does not have a problem with the blank row. 
								nCOLSPAN = -1;
								// 11/19/2018 Paul.  Hidden field may not be the only field in the cell. 
								if ( tdField.Controls.Count == 1 )
								{
									trLabel.Cells.Remove(tdLabel);
									tdField.Attributes.Add("style", "display:none");
								}
								if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
									hidID.Value = Sql.ToString(rdr[sDATA_FIELD]);
								// 11/25/2006 Paul.  The team name should always default to the current user's private team. 
								// Make sure not to overwrite the value if this is a postback. 
								// The hidden field does not require the same viewstate fix as the txtNAME field. 
								else if ( sDATA_FIELD == "TEAM_ID" && rdr == null && !bIsPostBack )
									hidID.Value = Security.TEAM_ID.ToString();
								// 01/15/2007 Paul.  Assigned To field will always default to the current user. 
								else if ( sDATA_FIELD == "ASSIGNED_USER_ID" && rdr == null && !bIsPostBack )
									hidID.Value = Security.USER_ID.ToString();
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				// 08/24/2009 Paul.  Add support for dynamic teams. 
				else if ( String.Compare(sFIELD_TYPE, "TeamSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						TeamSelect ctlTeamSelect = tbl.Page.LoadControl("~/_controls/TeamSelect.ascx") as TeamSelect;
						tdField.Controls.Add(ctlTeamSelect);
						ctlTeamSelect.ID = sDATA_FIELD;
						// 12/10/2017 Paul.  Provide a way to set the tab index. 
						ctlTeamSelect.TabIndex = nFORMAT_TAB_INDEX;
						// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
						ctlTeamSelect.NotPostBack = bNotPostBack;
						//ctlTeamSelect.TabIndex = nFORMAT_TAB_INDEX;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						ctlTeamSelect.Visible  = bLayoutMode || bIsReadable;
						ctlTeamSelect.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							Guid gTEAM_SET_ID = Guid.Empty;
							if ( rdr != null )
							{
								// 11/22/2010 Paul.  Convert data reader to data table for Rules Wizard. 
								//vwSchema.RowFilter = "ColumnName = 'TEAM_SET_ID'";
								//if ( vwSchema.Count > 0 )
								if ( rdr.Table.Columns.Contains("TEAM_SET_ID") )
								{
									gTEAM_SET_ID = Sql.ToGuid(rdr["TEAM_SET_ID"]);
								}
							}
							// 08/31/2009 Paul. Don't provide defaults in a Search view or a Popup view. 
							// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
							bool bAllowDefaults = sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sEDIT_NAME.IndexOf(".Popup") < 0;
							if ( sEDIT_NAME.Contains(".MassUpdate") )
								ctlTeamSelect.ShowAddReplace = true;
							ctlTeamSelect.LoadLineItems(gTEAM_SET_ID, bAllowDefaults);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( String.Compare(sFIELD_TYPE, "UserSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						UserSelect ctlUserSelect = tbl.Page.LoadControl("~/_controls/UserSelect.ascx") as UserSelect;
						tdField.Controls.Add(ctlUserSelect);
						ctlUserSelect.ID = sDATA_FIELD;
						// 12/10/2017 Paul.  Provide a way to set the tab index. 
						ctlUserSelect.TabIndex = nFORMAT_TAB_INDEX;
						// 11/30/2017 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
						ctlUserSelect.NotPostBack = bNotPostBack;
						//ctlUserSelect.TabIndex = nFORMAT_TAB_INDEX;
						// 11/30/2017 Paul.  Apply ACL Field Security. 
						ctlUserSelect.Visible  = bLayoutMode || bIsReadable;
						ctlUserSelect.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							Guid gASSIGNED_SET_ID = Guid.Empty;
							if ( rdr != null )
							{
								// 11/30/2017 Paul.  Convert data reader to data table for Rules Wizard. 
								//vwSchema.RowFilter = "ColumnName = 'ASSIGNED_SET_ID'";
								//if ( vwSchema.Count > 0 )
								if ( rdr.Table.Columns.Contains("ASSIGNED_SET_ID") )
								{
									gASSIGNED_SET_ID = Sql.ToGuid(rdr["ASSIGNED_SET_ID"]);
								}
							}
							// 11/30/2017 Paul. Don't provide defaults in a Search view or a Popup view. 
							// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
							bool bAllowDefaults = sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sEDIT_NAME.IndexOf(".Popup") < 0;
							if ( sEDIT_NAME.Contains(".MassUpdate") )
								ctlUserSelect.ShowAddReplace = true;
							ctlUserSelect.LoadLineItems(gASSIGNED_SET_ID, bAllowDefaults);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				// 05/12/2016 Paul.  Add Tags module. 
				else if ( String.Compare(sFIELD_TYPE, "TagSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						TagSelect ctlTagSelect = tbl.Page.LoadControl("~/_controls/TagSelect.ascx") as TagSelect;
						tdField.Controls.Add(ctlTagSelect);
						ctlTagSelect.ID = sDATA_FIELD;
						// 12/10/2017 Paul.  Provide a way to set the tab index. 
						ctlTagSelect.TabIndex = nFORMAT_TAB_INDEX;
						ctlTagSelect.NotPostBack = bNotPostBack;
						ctlTagSelect.Visible  = bLayoutMode || bIsReadable;
						ctlTagSelect.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							Guid gID = Guid.Empty;
							if ( rdr != null )
							{
								if ( rdr.Table.Columns.Contains("ID") )
								{
									gID = Sql.ToGuid(rdr["ID"]);
								}
							}
							// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
							bool bAllowDefaults = sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sEDIT_NAME.IndexOf(".Popup") < 0;
							if ( sEDIT_NAME.Contains(".MassUpdate") )
								ctlTagSelect.ShowAddReplace = true;
							ctlTagSelect.LoadLineItems(gID, bAllowDefaults);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				// 06/07/2017 Paul.  Add NAICSCodes module. 
				else if ( String.Compare(sFIELD_TYPE, "NAICSCodeSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						NAICSCodeSelect ctlNAICSCodeSelect = tbl.Page.LoadControl("~/_controls/NAICSCodeSelect.ascx") as NAICSCodeSelect;
						tdField.Controls.Add(ctlNAICSCodeSelect);
						ctlNAICSCodeSelect.ID = sDATA_FIELD;
						// 12/10/2017 Paul.  Provide a way to set the tab index. 
						ctlNAICSCodeSelect.TabIndex = nFORMAT_TAB_INDEX;
						ctlNAICSCodeSelect.NotPostBack = bNotPostBack;
						ctlNAICSCodeSelect.Visible  = bLayoutMode || bIsReadable;
						ctlNAICSCodeSelect.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							Guid gID = Guid.Empty;
							if ( rdr != null )
							{
								if ( rdr.Table.Columns.Contains("ID") )
								{
									gID = Sql.ToGuid(rdr["ID"]);
								}
							}
							// 04/02/2018 Paul.  MassUpdate has special rules, such as no fields are required and Assigned or Team fields do not get initialized. 
							bool bAllowDefaults = sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".MassUpdate") < 0 && sEDIT_NAME.IndexOf(".Popup") < 0;
							ctlNAICSCodeSelect.LoadLineItems(gID, bAllowDefaults);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				// 10/21/2009 Paul.  Add support for dynamic teams. 
				else if ( String.Compare(sFIELD_TYPE, "KBTagSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						KBTagSelect ctlKBTagSelect = tbl.Page.LoadControl("~/_controls/KBTagSelect.ascx") as KBTagSelect;
						tdField.Controls.Add(ctlKBTagSelect);
						ctlKBTagSelect.ID = sDATA_FIELD;
						// 12/10/2017 Paul.  Provide a way to set the tab index. 
						ctlKBTagSelect.TabIndex = nFORMAT_TAB_INDEX;
						// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
						ctlKBTagSelect.NotPostBack = bNotPostBack;
						//ctlKBTagSelect.TabIndex = nFORMAT_TAB_INDEX;
						// 01/18/2010 Paul.  Apply ACL Field Security. 
						ctlKBTagSelect.Visible  = bLayoutMode || bIsReadable;
						ctlKBTagSelect.Enabled  = bLayoutMode || bIsWriteable;
						try
						{
							Guid gID = Guid.Empty;
							if ( rdr != null )
							{
								gID = Sql.ToGuid(rdr["ID"]);
							}
							ctlKBTagSelect.LoadLineItems(gID);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						if ( bLayoutMode )
						{
							Literal litField = new Literal();
							litField.Text = sDATA_FIELD;
							tdField.Controls.Add(litField);
						}
					}
				}
				else
				{
					Literal litField = new Literal();
					tdField.Controls.Add(litField);
					litField.Text = "Unknown field type " + sFIELD_TYPE;
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "Unknown field type " + sFIELD_TYPE);
				}
				// 12/02/2007 Paul.  Each view can now have its own number of data columns. 
				// This was needed so that search forms can have 4 data columns. The default is 2 columns. 
				if ( nCOLSPAN > 0 )
					nColIndex += nCOLSPAN;
				else if ( nCOLSPAN == 0 )
					nColIndex++;
				if ( nColIndex >= nDATA_COLUMNS )
					nColIndex = 0;
			}
			// 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
			if ( dvFields.Count > 0 && !bLayoutMode )
			{
				try
				{
					string sEDIT_NAME   = Sql.ToString(dvFields[0]["EDIT_NAME"]);
					string sFORM_SCRIPT = Sql.ToString(dvFields[0]["SCRIPT"   ]);
					if ( !Sql.IsEmptyString(sFORM_SCRIPT) )
					{
						// 09/20/2012 Paul.  The base ID is not the ID of the parent, but the ID of the TemplateControl. 
						sFORM_SCRIPT = sFORM_SCRIPT.Replace("SPLENDID_EDITVIEW_LAYOUT_ID", tbl.TemplateControl.ClientID);
						sFORM_SCRIPT = sFORM_SCRIPT.Trim();
						// 01/18/2018 Paul.  If wrapped, then treat FORM_SCRIPT as a function. 
						if ( sFORM_SCRIPT.StartsWith("(") && sFORM_SCRIPT.EndsWith(")") )
						{
							string sFormVar = tbl.TemplateControl.ClientID + "_FORM_SCRIPT";
							sFORM_SCRIPT = "var " + sFormVar + " = " + sFORM_SCRIPT + ";" + ControlChars.CrLf
							             + "if ( typeof(" + sFormVar + ") == 'function' )" + ControlChars.CrLf
							             + "{" + ControlChars.CrLf
							             + "	var fnFORM_SCRIPT = " + sFormVar + "();" + ControlChars.CrLf
							             + "	if ( fnFORM_SCRIPT !== undefined && typeof(fnFORM_SCRIPT.Initialize) == 'function' ) " + ControlChars.CrLf
							             + "	{" + ControlChars.CrLf
							//             + "		console.log('Executing form script Initialize function.');" + ControlChars.CrLf
							             + "		fnFORM_SCRIPT.Initialize();" + ControlChars.CrLf
							             + "	}" + ControlChars.CrLf
							             + "	else" + ControlChars.CrLf
							             + "	{" + ControlChars.CrLf
							//             + "		console.log('Executed form script as function.');" + ControlChars.CrLf
							             + "	}" + ControlChars.CrLf
							             + "}" + ControlChars.CrLf
							             + "else" + ControlChars.CrLf
							             + "{" + ControlChars.CrLf
							             + "	console.log('Form script not a function and will not be executed.');" + ControlChars.CrLf
							             + "}" + ControlChars.CrLf
							;
						}
						else
						{
							//sFORM_SCRIPT += ControlChars.CrLf + "console.log('Executing form script as raw script.');";
						}
						ScriptManager.RegisterStartupScript(tbl, typeof(System.String), sEDIT_NAME.Replace(".", "_") + "_SCRIPT", sFORM_SCRIPT, true);
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
				}
			}
			// 05/08/2010 Paul.  Define the copy buttons outside the loop so that we can replace the javascript with embedded code.  
			// This is so that the javascript will run properly in the SixToolbar UpdatePanel. 
			if ( btnCopyRight != null && btnCopyLeft != null )
			{
				string[][] arrCopyFields = new string[14][];
				arrCopyFields[0] = new string[2] { "SHIPPING_ADDRESS_STREET"    , "BILLING_ADDRESS_STREET"    };
				arrCopyFields[1] = new string[2] { "SHIPPING_ADDRESS_CITY"      , "BILLING_ADDRESS_CITY"      };
				arrCopyFields[2] = new string[2] { "SHIPPING_ADDRESS_STATE"     , "BILLING_ADDRESS_STATE"     };
				arrCopyFields[3] = new string[2] { "SHIPPING_ADDRESS_POSTALCODE", "BILLING_ADDRESS_POSTALCODE"};
				arrCopyFields[4] = new string[2] { "SHIPPING_ADDRESS_COUNTRY"   , "BILLING_ADDRESS_COUNTRY"   };
				arrCopyFields[5] = new string[2] { "ALT_ADDRESS_STREET"         , "PRIMARY_ADDRESS_STREET"    };
				arrCopyFields[6] = new string[2] { "ALT_ADDRESS_CITY"           , "PRIMARY_ADDRESS_CITY"      };
				arrCopyFields[7] = new string[2] { "ALT_ADDRESS_STATE"          , "PRIMARY_ADDRESS_STATE"     };
				arrCopyFields[8] = new string[2] { "ALT_ADDRESS_POSTALCODE"     , "PRIMARY_ADDRESS_POSTALCODE"};
				arrCopyFields[9] = new string[2] { "ALT_ADDRESS_COUNTRY"        , "PRIMARY_ADDRESS_COUNTRY"   };
				// 08/21/2010 Paul.  Also copy Account and Contact on Quotes, Orders and Invoices. 
				arrCopyFields[10] = new string[2] { "SHIPPING_ACCOUNT_NAME"      , "BILLING_ACCOUNT_NAME"      };
				arrCopyFields[11] = new string[2] { "SHIPPING_ACCOUNT_ID"        , "BILLING_ACCOUNT_ID"        };
				arrCopyFields[12] = new string[2] { "SHIPPING_CONTACT_NAME"      , "BILLING_CONTACT_NAME"      };
				arrCopyFields[13] = new string[2] { "SHIPPING_CONTACT_ID"        , "BILLING_CONTACT_ID"        };

				/*
				function copyAddressRight()
				{
					document.getElementById('<%= new DynamicControl(this, "SHIPPING_ADDRESS_STREET"    ).ClientID %>').value = document.getElementById('<%= new DynamicControl(this, "BILLING_ADDRESS_STREET"    ).ClientID %>').value;
					document.getElementById('<%= new DynamicControl(this, "SHIPPING_ADDRESS_CITY"      ).ClientID %>').value = document.getElementById('<%= new DynamicControl(this, "BILLING_ADDRESS_CITY"      ).ClientID %>').value;
					document.getElementById('<%= new DynamicControl(this, "SHIPPING_ADDRESS_STATE"     ).ClientID %>').value = document.getElementById('<%= new DynamicControl(this, "BILLING_ADDRESS_STATE"     ).ClientID %>').value;
					document.getElementById('<%= new DynamicControl(this, "SHIPPING_ADDRESS_POSTALCODE").ClientID %>').value = document.getElementById('<%= new DynamicControl(this, "BILLING_ADDRESS_POSTALCODE").ClientID %>').value;
					document.getElementById('<%= new DynamicControl(this, "SHIPPING_ADDRESS_COUNTRY"   ).ClientID %>').value = document.getElementById('<%= new DynamicControl(this, "BILLING_ADDRESS_COUNTRY"   ).ClientID %>').value;
					return true;
				}
				function copyAddressLeft()
				{
					document.getElementById('<%= new DynamicControl(this, "BILLING_ADDRESS_STREET"    ).ClientID %>').value = document.getElementById('<%= new DynamicControl(this, "SHIPPING_ADDRESS_STREET"    ).ClientID %>').value;
					document.getElementById('<%= new DynamicControl(this, "BILLING_ADDRESS_CITY"      ).ClientID %>').value = document.getElementById('<%= new DynamicControl(this, "SHIPPING_ADDRESS_CITY"      ).ClientID %>').value;
					document.getElementById('<%= new DynamicControl(this, "BILLING_ADDRESS_STATE"     ).ClientID %>').value = document.getElementById('<%= new DynamicControl(this, "SHIPPING_ADDRESS_STATE"     ).ClientID %>').value;
					document.getElementById('<%= new DynamicControl(this, "BILLING_ADDRESS_POSTALCODE").ClientID %>').value = document.getElementById('<%= new DynamicControl(this, "SHIPPING_ADDRESS_POSTALCODE").ClientID %>').value;
					document.getElementById('<%= new DynamicControl(this, "BILLING_ADDRESS_COUNTRY"   ).ClientID %>').value = document.getElementById('<%= new DynamicControl(this, "SHIPPING_ADDRESS_COUNTRY"   ).ClientID %>').value;
					return true;
				}
				*/
				StringBuilder sbCopyRight = new StringBuilder();
				StringBuilder sbCopyLeft  = new StringBuilder();
				for ( int i = 0; i < arrCopyFields.Length; i++ )
				{
					Control ctl1 = tbl.FindControl(arrCopyFields[i][0]);
					Control ctl2 = tbl.FindControl(arrCopyFields[i][1]);
					if ( ctl1 != null && ctl2 != null )
					{
						// 02/01/2011 Paul.  Cannot copy values from literal. 
						if ( !(ctl1 is Literal) && !(ctl2 is Literal) )
						{
							sbCopyRight.Append("document.getElementById('" + ctl1.ClientID + "').value = document.getElementById('" + ctl2.ClientID + "').value;");
							sbCopyLeft .Append("document.getElementById('" + ctl2.ClientID + "').value = document.getElementById('" + ctl1.ClientID + "').value;");
						}
					}
				}
				sbCopyRight.Append("return true;");
				sbCopyLeft .Append("return true;");

				btnCopyRight.Attributes.Add("onclick", sbCopyRight.ToString());
				btnCopyLeft .Attributes.Add("onclick", sbCopyLeft .ToString());
			}
		}

		// 05/26/2007 Paul.  We need a way set the fields without creating the controls. 
		public static void SetEditViewFields(System.Web.UI.UserControl Parent, string sEDIT_NAME, IDataReader rdr, L10N L10n, TimeZone T10n)
		{
			// 01/01/2008 Paul.  Pull config flag outside the loop. 
			bool bEnableTeamManagement  = Crm.Config.enable_team_management();
			// 09/16/2018 Paul.  Create a multi-tenant system. 
			if ( Crm.Config.enable_multi_tenant_teams() )
			{
				bEnableTeamManagement    = false;
			}
			// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
			DataTable dtFields = SplendidCache.EditViewFields(sEDIT_NAME, Security.PRIMARY_ROLE_NAME);
			DataView dvFields  = dtFields.DefaultView;
			foreach(DataRowView row in dvFields)
			{
				string sFIELD_TYPE        = Sql.ToString (row["FIELD_TYPE"       ]);
				string sDATA_LABEL        = Sql.ToString (row["DATA_LABEL"       ]);
				string sDATA_FIELD        = Sql.ToString (row["DATA_FIELD"       ]);
				string sDISPLAY_FIELD     = Sql.ToString (row["DISPLAY_FIELD"    ]);
				string sDATA_FORMAT       = Sql.ToString (row["DATA_FORMAT"      ]);
				// 11/02/2010 Paul.  We need a way to insert NONE into the a ListBox while still allowing multiple rows. 
				// The trick will be to use a negative number.  Use an absolute value here to reduce the areas to fix. 
				int    nFORMAT_ROWS       = Math.Abs(Sql.ToInteger(row["FORMAT_ROWS"]));
				
				if ( sDATA_FIELD == "TEAM_ID" || sDATA_FIELD == "TEAM_SET_NAME" )
				{
					if ( !bEnableTeamManagement )
					{
						sFIELD_TYPE = "Blank";
					}
				}
				if ( String.Compare(sFIELD_TYPE, "Blank", true) == 0 )
				{
				}
				else if ( String.Compare(sFIELD_TYPE, "Label", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Literal litField = Parent.FindControl(sDATA_FIELD) as Literal;
						if ( litField != null )
						{
							try
							{
								if ( sDATA_FIELD.IndexOf(".") >= 0 )
									litField.Text = L10n.Term(sDATA_FIELD);
								else
									litField.Text = Sql.ToString(rdr[sDATA_FIELD]);
							}
							catch(Exception ex)
							{
								SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
								litField.Text = ex.Message;
							}
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "ListBox", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						try
						{
							if ( nFORMAT_ROWS > 0 )
							{
								// 12/02/2007 Paul.  If format rows > 0 then this is a list box and not a drop down list. 
								ListBox lstField = Parent.FindControl(sDATA_FIELD) as ListBox;
								if ( lstField != null )
								{
									// 08/19/2010 Paul.  Check the list before assigning the value. 
									Utils.SetValue(lstField, Sql.ToString(rdr[sDATA_FIELD]));
								}
							}
							else
							{
								DropDownList lstField = Parent.FindControl(sDATA_FIELD) as DropDownList;
								if ( lstField != null )
								{
									// 08/19/2010 Paul.  Check the list before assigning the value. 
									Utils.SetValue(lstField, Sql.ToString(rdr[sDATA_FIELD]));
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				// 06/16/2010 Paul.  Add support for CheckBoxList. 
				else if ( String.Compare(sFIELD_TYPE, "CheckBoxList", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						try
						{
							CheckBoxList lstField = Parent.FindControl(sDATA_FIELD) as CheckBoxList;
							if ( lstField != null )
							{
								// 08/19/2010 Paul.  Check the list before assigning the value. 
								Utils.SetValue(lstField, Sql.ToString(rdr[sDATA_FIELD]));
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				// 06/16/2010 Paul.  Add support for Radio buttons. 
				else if ( String.Compare(sFIELD_TYPE, "Radio", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						try
						{
							RadioButtonList lstField = Parent.FindControl(sDATA_FIELD) as RadioButtonList;
							if ( lstField != null )
							{
								// 08/19/2010 Paul.  Check the list before assigning the value. 
								Utils.SetValue(lstField, Sql.ToString(rdr[sDATA_FIELD]));
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "CheckBox", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						try
						{
							CheckBox chkField = Parent.FindControl(sDATA_FIELD) as CheckBox;
							if ( chkField != null )
								chkField.Checked = Sql.ToBoolean(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "ChangeButton", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/04/2005 Paul.  If the label is PARENT_TYPE, then change the label to a DropDownList.
						if ( sDATA_LABEL == "PARENT_TYPE" )
						{
							// 02/04/2011 Paul.  We gave the PARENT_TYPE a unique name, but we need to update all EditViews and NewRecords. 
							DropDownList lstField = Parent.FindControl(sDATA_FIELD + "_PARENT_TYPE") as DropDownList;
							if ( lstField != null )
							{
								try
								{
									// 08/19/2010 Paul.  Check the list before assigning the value. 
									Utils.SetValue(lstField, Sql.ToString(rdr[sDATA_LABEL]));
								}
								catch(Exception ex)
								{
									SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
								}
							}
						}
						TextBox txtNAME = Parent.FindControl(sDISPLAY_FIELD) as TextBox;
						if ( txtNAME != null )
						{
							try
							{
								if ( !Sql.IsEmptyString(sDISPLAY_FIELD) )
									txtNAME.Text = Sql.ToString(rdr[sDISPLAY_FIELD]);
							}
							catch(Exception ex)
							{
								SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
								txtNAME.Text = ex.Message;
							}
							HtmlInputHidden hidID = Parent.FindControl(sDATA_FIELD) as HtmlInputHidden;
							if ( hidID != null )
							{
								try
								{
									hidID.Value = Sql.ToString(rdr[sDATA_FIELD]);
								}
								catch(Exception ex)
								{
									SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
									txtNAME.Text = ex.Message;
								}
							}
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "ModulePopup", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						TextBox txtNAME = Parent.FindControl(sDISPLAY_FIELD) as TextBox;
						if ( txtNAME != null )
						{
							try
							{
								if ( !Sql.IsEmptyString(sDISPLAY_FIELD) )
									txtNAME.Text = Sql.ToString(rdr[sDISPLAY_FIELD]);
							}
							catch(Exception ex)
							{
								SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
								txtNAME.Text = ex.Message;
							}
							HtmlInputHidden hidID = Parent.FindControl(sDATA_FIELD) as HtmlInputHidden;
							if ( hidID != null )
							{
								try
								{
									hidID.Value = Sql.ToString(rdr[sDATA_FIELD]);
								}
								catch(Exception ex)
								{
									SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
									txtNAME.Text = ex.Message;
								}
							}
						}
					}
				}
				// 04/13/2016 Paul.  Add ZipCode lookup. 
				else if ( String.Compare(sFIELD_TYPE, "ZipCodePopup", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						TextBox txtNAME = Parent.FindControl(sDATA_FIELD) as TextBox;
						if ( txtNAME != null )
						{
							try
							{
								if ( !Sql.IsEmptyString(sDATA_FIELD) )
									txtNAME.Text = Sql.ToString(rdr[sDATA_FIELD]);
							}
							catch(Exception ex)
							{
								SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
								txtNAME.Text = ex.Message;
							}
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "TextBox", true) == 0 || String.Compare(sFIELD_TYPE, "Password", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						TextBox txtField = Parent.FindControl(sDATA_FIELD) as TextBox;
						if ( txtField != null )
						{
							try
							{
								// 06/02/2016 Paul.  There is no way to get the DbType from a DataTable/DataRow, so just rely upon the detection of Decimal. 
								//int    nOrdinal  = rdr.GetOrdinal(sDATA_FIELD);
								string sTypeName = String.Empty;  //rdr.GetDataTypeName(nOrdinal);
								if ( sTypeName == "money" || rdr[sDATA_FIELD].GetType() == typeof(System.Decimal) )
								{
									// 06/02/2016 Paul.  We need to be able to define the currency format. 
									Currency C10n = HttpContext.Current.Items["C10n"] as Currency;
									if ( (sTypeName == "money" || sDATA_FORMAT == "{0:c}") && C10n != null )
									{
										Decimal d = C10n.ToCurrency(Convert.ToDecimal(rdr[sDATA_FIELD]));
										// 06/02/2016 Paul.  We do not want to include the currency symbol, so don't use .ToString("c") 
										txtField.Text = d.ToString("#,##0.00");
									}
									else
										txtField.Text = Sql.ToDecimal(rdr[sDATA_FIELD]).ToString("#,##0.00");
								}
								else
									txtField.Text = Sql.ToString(rdr[sDATA_FIELD]);
							}
							catch(Exception ex)
							{
								SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
								txtField.Text = ex.Message;
							}
						}
					}
				}
				// 04/02/2009 Paul.  Add support for FCKEditor to the EditView. 
				else if ( String.Compare(sFIELD_TYPE, "HtmlEditor", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
						CKEditorControl txtField = Parent.FindControl(sDATA_FIELD) as CKEditorControl;
						if ( txtField != null )
						{
							try
							{
								txtField.Text = Sql.ToString(rdr[sDATA_FIELD]);
							}
							catch(Exception ex)
							{
								SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
								txtField.Text = ex.Message;
							}
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "DatePicker", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						try
						{
							// 01/01/2018 Paul.  Allow searching of multiple date fields. 
							DatePicker ctlDate = Parent.FindControl(sDATA_FIELD.Replace(" ", "_")) as DatePicker;
							if ( ctlDate != null )
								ctlDate.Value = T10n.FromServerTime(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "DateTimePicker", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						try
						{
							DateTimePicker ctlDate = Parent.FindControl(sDATA_FIELD) as DateTimePicker;
							if ( ctlDate != null )
								ctlDate.Value = T10n.FromServerTime(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "DateTimeEdit", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						try
						{
							DateTimeEdit ctlDate = Parent.FindControl(sDATA_FIELD) as DateTimeEdit;
							if ( ctlDate != null )
								ctlDate.Value = T10n.FromServerTime(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				// 06/20/2009 Paul.  Add DateTimeNewRecord so that the NewRecord forms can use the Dynamic rendering. 
				else if ( String.Compare(sFIELD_TYPE, "DateTimeNewRecord", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						try
						{
							DateTimeEdit ctlDate = Parent.FindControl(sDATA_FIELD) as DateTimeEdit;
							if ( ctlDate != null )
								ctlDate.Value = T10n.FromServerTime(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "File", true) == 0 )
				{
				}
				else if ( String.Compare(sFIELD_TYPE, "Image", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						try
						{
							HtmlInputHidden ctlHidden = Parent.FindControl(sDATA_FIELD) as HtmlInputHidden;
							Image imgField = Parent.FindControl("img" + sDATA_FIELD) as Image;
							if ( ctlHidden != null && imgField != null )
							{
								if ( !Sql.IsEmptyString(rdr[sDATA_FIELD]) )
								{
									ctlHidden.Value = Sql.ToString(rdr[sDATA_FIELD]);
									imgField.ImageUrl = "~/Images/Image.aspx?ID=" + ctlHidden.Value;
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
			}
		}

		// 10/18/2009 Paul.  Move blob logic to LoadFile. 
		// 05/27/2016 Paul.  Move LoadFile to Crm.Images class. 

		public static bool LoadImage(SplendidControl ctlPARENT, Guid gParentID, string sFIELD_NAME, IDbTransaction trn)
		{
			bool bNewFile = false;
			HtmlInputFile fileIMAGE = ctlPARENT.FindControl(sFIELD_NAME + "_File") as HtmlInputFile;
			if ( fileIMAGE != null )
			{
				HttpPostedFile pstIMAGE  = fileIMAGE.PostedFile;
				if ( pstIMAGE != null )
				{
					long lFileSize      = pstIMAGE.ContentLength;
					long lUploadMaxSize = Sql.ToLong(HttpContext.Current.Application["CONFIG.upload_maxsize"]);
					if ( (lUploadMaxSize > 0) && (lFileSize > lUploadMaxSize) )
					{
						throw(new Exception("ERROR: uploaded file was too big: max filesize: " + lUploadMaxSize.ToString()));
					}
					// 04/13/2005 Paul.  File may not have been provided. 
					if ( pstIMAGE.FileName.Length > 0 )
					{
						string sFILENAME       = Path.GetFileName (pstIMAGE.FileName);
						string sFILE_EXT       = Path.GetExtension(sFILENAME);
						string sFILE_MIME_TYPE = pstIMAGE.ContentType;
						
						Guid gImageID = Guid.Empty;
						SqlProcs.spIMAGES_Insert
							( ref gImageID
							, gParentID
							, sFILENAME
							, sFILE_EXT
							, sFILE_MIME_TYPE
							, trn
							);
						// 09/06/2008 Paul.  PostgreSQL does not require that we stream the bytes, so lets explore doing this for all platforms. 
						// 05/27/2016 Paul.  Move LoadFile to Crm.Images class. 
						Crm.Images.LoadFile(gImageID, pstIMAGE.InputStream, trn);
						// 04/17/2006 Paul.  Update the dynamic control so that it can be accessed below. 
						DynamicControl ctlIMAGE = new DynamicControl(ctlPARENT, sFIELD_NAME);
						ctlIMAGE.ID = gImageID;
						bNewFile = true;
					}
				}
			}
			return bNewFile;
		}

		// 09/09/2009 Paul.  Change parameter name to be more logical.
		public static void UpdateCustomFields(SplendidControl ctlPARENT, IDbTransaction trn, Guid gID, string sTABLE_NAME, DataTable dtCustomFields)
		{
			if ( dtCustomFields.Rows.Count > 0 )
			{
				IDbConnection con = trn.Connection;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.Transaction = trn;
					cmd.CommandType = CommandType.Text;
					cmd.CommandText = "update " + sTABLE_NAME + "_CSTM" + ControlChars.CrLf;
					int nFieldIndex = 0;
					foreach(DataRow row in dtCustomFields.Rows)
					{
						// 01/11/2006 Paul.  Uppercase looks better. 
						string sNAME   = Sql.ToString(row["NAME"  ]).ToUpper();
						string sCsType = Sql.ToString(row["CsType"]);
						// 10/11/2016 Paul.  vwFIELDS_META_DATA_Unvalidated does not return DATA_TYPE. 
						string sDATA_TYPE = String.Empty;
						if ( row.Table.Columns.Contains("DATA_TYPE") )
							sDATA_TYPE = Sql.ToString(row["DATA_TYPE"]);
						// 01/13/2007 Paul.  We need to truncate any long strings to prevent SQL error. 
						// String or binary data would be truncated. The statement has been terminated. 
						int    nMAX_SIZE = Sql.ToInteger(row["MAX_SIZE"]);
						DynamicControl ctlCustomField = new DynamicControl(ctlPARENT, sNAME);
						// 02/10/2008 Paul.  Literals should not be updated. 
						if ( ctlCustomField.Exists && ctlCustomField.Type != "Literal" )
						{
							if ( nFieldIndex == 0 )
								cmd.CommandText += "   set ";
							else
								cmd.CommandText += "     , ";
							// 01/10/2006 Paul.  We can't use a StringBuilder because the Sql.AddParameter function
							// needs to be able to replace the @ with the appropriate database specific token. 
							cmd.CommandText += sNAME + " = @" + sNAME + ControlChars.CrLf;
							
							DynamicControl ctlCustomField_File = new DynamicControl(ctlPARENT, sNAME + "_File");
							// 04/21/2006 Paul.  If the type is Guid and it is accompanied by a File control, then assume it is an image. 
							if ( sCsType == "Guid" && ctlCustomField.Type == "HtmlInputHidden" && ctlCustomField_File.Exists )
							{
								LoadImage(ctlPARENT, gID, sNAME, trn);
							}
							// 04/21/2006 Paul.  Even if there is no image to upload, we still need to update the field.
							// This is so that the image can be cleared. 
							switch ( sCsType )
							{
								case "Guid"    :  Sql.AddParameter(cmd, "@" + sNAME, ctlCustomField.ID          );  break;
								case "short"   :  Sql.AddParameter(cmd, "@" + sNAME, ctlCustomField.IntegerValue);  break;
								case "Int32"   :  Sql.AddParameter(cmd, "@" + sNAME, ctlCustomField.IntegerValue);  break;
								case "Int64"   :  Sql.AddParameter(cmd, "@" + sNAME, ctlCustomField.IntegerValue);  break;
								case "float"   :  Sql.AddParameter(cmd, "@" + sNAME, ctlCustomField.FloatValue  );  break;
								// 06/02/2016 Paul.  We need to be able to define the currency format. 
								case "decimal" :
									if ( sDATA_TYPE == "money" )
									{
										// 12/21/2017 Paul.  When called from the REST API, C10n will not be defined in the context items. 
										Currency C10n = null;
										if ( HttpContext.Current != null && HttpContext.Current.Items != null )
											C10n = HttpContext.Current.Items["C10n"] as Currency;
										Decimal d = Sql.ToDecimal(ctlCustomField.DecimalValue);
										if ( C10n != null )
											d = C10n.FromCurrency(d);
										Sql.AddParameter(cmd, "@" + sNAME, d);
									}
									else
									{
										Sql.AddParameter(cmd, "@" + sNAME, ctlCustomField.DecimalValue);
									}
									break;
								case "bool"    :  Sql.AddParameter(cmd, "@" + sNAME, ctlCustomField.Checked     );  break;
								case "DateTime":  Sql.AddParameter(cmd, "@" + sNAME, ctlCustomField.DateValue   );  break;
								default        :  Sql.AddParameter(cmd, "@" + sNAME, ctlCustomField.Text        , nMAX_SIZE);  break;
							}
							nFieldIndex++;
						}
					}
					if ( nFieldIndex > 0 )
					{
						cmd.CommandText += " where ID_C = @ID_C" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@ID_C", gID);
						cmd.ExecuteNonQuery();
					}
					// 02/09/2021 Paul.  We need to update the custom field table even if no data has changed so that an audit record gets created.  This is a very old bug. 
					else
					{
						cmd.CommandText += "   set ID_C = ID_C" + ControlChars.CrLf;
						cmd.CommandText += " where ID_C = @ID_C" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@ID_C", gID);
						cmd.ExecuteNonQuery();
					}
				}
			}
		}

		// 09/09/2009 Paul.  Change parameter name to be more logical.
		public static void UpdateCustomFields(SplendidPage ctlPARENT, IDbTransaction trn, Guid gID, string sTABLE_NAME, DataTable dtCustomFields)
		{
			if ( dtCustomFields.Rows.Count > 0 )
			{
				IDbConnection con = trn.Connection;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.Transaction = trn;
					cmd.CommandType = CommandType.Text;
					cmd.CommandText = "update " + sTABLE_NAME + "_CSTM" + ControlChars.CrLf;
					int nFieldIndex = 0;
					foreach(DataRow row in dtCustomFields.Rows)
					{
						// 01/11/2006 Paul.  Uppercase looks better. 
						string sNAME   = Sql.ToString(row["NAME"  ]).ToUpper();
						string sCsType = Sql.ToString(row["CsType"]);
						// 10/11/2016 Paul.  vwFIELDS_META_DATA_Unvalidated does not return DATA_TYPE. 
						string sDATA_TYPE = String.Empty;
						if ( row.Table.Columns.Contains("DATA_TYPE") )
							sDATA_TYPE = Sql.ToString(row["DATA_TYPE"]);
						// 01/13/2007 Paul.  We need to truncate any long strings to prevent SQL error. 
						// String or binary data would be truncated. The statement has been terminated. 
						int    nMAX_SIZE = Sql.ToInteger(row["MAX_SIZE"]);
						if ( ctlPARENT.Request[sNAME] != null )
						{
							string sVALUE = ctlPARENT.Request[sNAME];
							if ( nFieldIndex == 0 )
								cmd.CommandText += "   set ";
							else
								cmd.CommandText += "     , ";
							// 01/10/2006 Paul.  We can't use a StringBuilder because the Sql.AddParameter function
							// needs to be able to replace the @ with the appropriate database specific token. 
							cmd.CommandText += sNAME + " = @" + sNAME + ControlChars.CrLf;
							
							// 02/08/2009 Paul.  We are not going to support images on the WebToLeadCapture page. 
							/*
							DynamicControl ctlCustomField_File = new DynamicControl(ctlPARENT, sNAME + "_File");
							// 04/21/2006 Paul.  If the type is Guid and it is accompanied by a File control, then assume it is an image. 
							if ( sCsType == "Guid" && ctlCustomField.Type == "HtmlInputHidden" && ctlCustomField_File.Exists )
							{
								LoadImage(ctlPARENT, gID, sNAME, trn);
							}
							*/
							// 04/21/2006 Paul.  Even if there is no image to upload, we still need to update the field.
							// This is so that the image can be cleared. 
							switch ( sCsType )
							{
								case "Guid"    :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToGuid    (sVALUE));  break;
								case "short"   :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToInteger (sVALUE));  break;
								case "Int32"   :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToInteger (sVALUE));  break;
								case "Int64"   :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToInteger (sVALUE));  break;
								case "float"   :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToFloat   (sVALUE));  break;
								// 06/02/2016 Paul.  We need to be able to define the currency format. 
								case "decimal" :
									if ( sDATA_TYPE == "money" )
									{
										// 12/21/2017 Paul.  When called from the REST API, C10n will not be defined in the context items. 
										Currency C10n = null;
										if ( HttpContext.Current != null && HttpContext.Current.Items != null )
											C10n = HttpContext.Current.Items["C10n"] as Currency;
										Decimal d = Sql.ToDecimal(sVALUE);
										if ( C10n != null )
											d = C10n.FromCurrency(d);
										Sql.AddParameter(cmd, "@" + sNAME, d);
									}
									else
									{
										Sql.AddParameter(cmd, "@" + sNAME, Sql.ToDecimal (sVALUE));
									}
									break;
								case "bool"    :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToBoolean (sVALUE));  break;
								case "DateTime":  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToDateTime(sVALUE));  break;
								default        :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToString  (sVALUE), nMAX_SIZE);  break;
							}
							nFieldIndex++;
						}
					}
					if ( nFieldIndex > 0 )
					{
						cmd.CommandText += " where ID_C = @ID_C" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@ID_C", gID);
						cmd.ExecuteNonQuery();
					}
					// 01/19/2021 Paul.  We need to update the custom field table even if no data has changed so that an audit record gets created.  This is a very old bug. 
					else
					{
						cmd.CommandText += "   set ID_C = ID_C" + ControlChars.CrLf;
						cmd.CommandText += " where ID_C = @ID_C" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@ID_C", gID);
						cmd.ExecuteNonQuery();
					}
				}
			}
		}
#endif

		// 05/25/2008 Paul.  We need a version of UpdateCustomFields that pulls data from a DataRow as this is how 
		// Quotes, Orders and Invoices manage their line items. 
		// 09/09/2009 Paul.  Change parameter name to be more logical.
		public static void UpdateCustomFields(DataRow rowForm, IDbTransaction trn, Guid gID, string sTABLE_NAME, DataTable dtCustomFields)
		{
			if ( dtCustomFields.Rows.Count > 0 )
			{
				IDbConnection con = trn.Connection;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.Transaction = trn;
					cmd.CommandType = CommandType.Text;
					cmd.CommandText = "update " + sTABLE_NAME + "_CSTM" + ControlChars.CrLf;
					int nFieldIndex = 0;
					foreach(DataRow row in dtCustomFields.Rows)
					{
						// 01/11/2006 Paul.  Uppercase looks better. 
						string sNAME   = Sql.ToString(row["NAME"  ]).ToUpper();
						string sCsType = Sql.ToString(row["CsType"]);
						// 06/02/2016 Paul.  We need to be able to define the currency format. 
						// 10/11/2016 Paul.  vwFIELDS_META_DATA_Unvalidated does not return DATA_TYPE. 
						string sDATA_TYPE = String.Empty;
						if ( row.Table.Columns.Contains("DATA_TYPE") )
							sDATA_TYPE = Sql.ToString(row["DATA_TYPE"]);
						// 01/13/2007 Paul.  We need to truncate any long strings to prevent SQL error. 
						// String or binary data would be truncated. The statement has been terminated. 
						int    nMAX_SIZE = Sql.ToInteger(row["MAX_SIZE"]);
						if ( rowForm.Table.Columns.Contains(sNAME) )
						{
							if ( nFieldIndex == 0 )
								cmd.CommandText += "   set ";
							else
								cmd.CommandText += "     , ";
							// 01/10/2006 Paul.  We can't use a StringBuilder because the Sql.AddParameter function
							// needs to be able to replace the @ with the appropriate database specific token. 
							cmd.CommandText += sNAME + " = @" + sNAME + ControlChars.CrLf;
							
							switch ( sCsType )
							{
								case "Guid"    :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToGuid    (rowForm[sNAME]));  break;
								case "short"   :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToInteger (rowForm[sNAME]));  break;
								case "Int32"   :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToInteger (rowForm[sNAME]));  break;
								case "Int64"   :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToInteger (rowForm[sNAME]));  break;
								case "float"   :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToFloat   (rowForm[sNAME]));  break;
								// 06/02/2016 Paul.  We need to be able to define the currency format. 
								case "decimal" :
									if ( sDATA_TYPE == "money" )
									{
										// 12/21/2017 Paul.  When called from the REST API, C10n will not be defined in the context items. 
										Currency C10n = null;
										if ( HttpContext.Current != null && HttpContext.Current.Items != null )
											C10n = HttpContext.Current.Items["C10n"] as Currency;
										Decimal d = Sql.ToDecimal(rowForm[sNAME]);
										if ( C10n != null )
											d = C10n.FromCurrency(d);
										Sql.AddParameter(cmd, "@" + sNAME, d);
									}
									else
									{
										Sql.AddParameter(cmd, "@" + sNAME, Sql.ToDecimal (rowForm[sNAME]));
									}
									break;
								case "bool"    :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToBoolean (rowForm[sNAME]));  break;
								case "DateTime":
									// 07/30/2020 Paul.  Date may be in json format. 
									Sql.AddParameter(cmd, "@" + sNAME, RestUtil.FromJsonDate(Sql.ToString(rowForm[sNAME])));
									break;
								default        :  Sql.AddParameter(cmd, "@" + sNAME, Sql.ToString  (rowForm[sNAME]), nMAX_SIZE);  break;
							}
							nFieldIndex++;
						}
					}
					if ( nFieldIndex > 0 )
					{
						cmd.CommandText += " where ID_C = @ID_C" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@ID_C", gID);
						cmd.ExecuteNonQuery();
					}
					// 02/08/2021 Paul.  We need to update the custom field table even if no data has changed so that an audit record gets created.  This is a very old bug. 
					else
					{
						cmd.CommandText += "   set ID_C = ID_C" + ControlChars.CrLf;
						cmd.CommandText += " where ID_C = @ID_C" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@ID_C", gID);
						cmd.ExecuteNonQuery();
					}
				}
			}
		}

		// 12/29/2007 Paul.  TEAM_ID is now in the stored procedure. 
		/*
		public static void UpdateTeam(SplendidControl ctlPARENT, IDbTransaction trn, Guid gID, string sMODULE)
		{
			DynamicControl ctlCustomField = new DynamicControl(ctlPARENT, "TEAM_ID");
			if ( ctlCustomField.Exists )
			{
				UpdateTeam(trn, gID, sMODULE, ctlCustomField.ID);
			}
		}

		// 11/30/2006 Paul.  We need to be able to update the team when importing data. 
		public static void UpdateTeam(IDbTransaction trn, Guid gID, string sMODULE, Guid gTEAM_ID)
		{
			// 11/22/2006 Paul.  Team management is optional. 
			if ( Crm.Config.enable_team_management() )
			{
				IDbConnection con = trn.Connection;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.Transaction = trn;
					cmd.CommandType = CommandType.Text;
					cmd.CommandText  = "update " + sMODULE.ToUpper() + ControlChars.CrLf;
					cmd.CommandText += "   set TEAM_ID = @TEAM_ID" + ControlChars.CrLf;
					cmd.CommandText += " where ID      = @ID     " + ControlChars.CrLf;
					Sql.AddParameter(cmd, "@TEAM_ID", gTEAM_ID);
					Sql.AddParameter(cmd, "@ID"     , gID);
					cmd.ExecuteNonQuery();
				}
			}
		}
		*/

	}
}

