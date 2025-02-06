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
using System.Collections;
using System.Text;
using System.IO;
using System.Diagnostics;

namespace SplendidCRM.Administration.DynamicLayout.EditViews
{
	/// <summary>
	/// Summary description for Export.
	/// </summary>
	public class Export : System.Web.UI.Page
	{
		private void Page_Load(object sender, System.EventArgs e)
		{
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.GetUserAccess("DynamicLayout", "export") >= 0);
			if ( !this.Visible )
				return;
			
			string sNAME = Sql.ToString(Request["NAME"]);
			if ( !Sql.IsEmptyString(sNAME) )
			{
				StringBuilder sb = new StringBuilder();
				StringBuilder sbUpdates = new StringBuilder();
				// 03/15/2018 Paul.  Mark record as deleted instead of deleting. 
				//sb.AppendLine("delete from EDITVIEWS_FIELDS where EDIT_NAME = '" + sNAME + "';");
				sb.AppendLine("update EDITVIEWS_FIELDS set DELETED = 1, DATE_MODIFIED_UTC = getutcdate(), MODIFIED_USER_ID = null where DELETED = 0 and EDIT_NAME = '" + sNAME + "';");
				
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select *                         " + ControlChars.CrLf
					     + "  from vwEDITVIEWS_FIELDS        " + ControlChars.CrLf
					     + " where EDIT_NAME = @EDIT_NAME    " + ControlChars.CrLf
					     + "   and DEFAULT_VIEW = 0          " + ControlChars.CrLf
					     + " order by FIELD_INDEX            " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@EDIT_NAME", sNAME);
					
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dtFields = new DataTable() )
							{
								da.Fill(dtFields);
								if ( dtFields.Rows.Count > 0 )
								{
									int nFIELD_INDEX_Length = 2;
									int nDATA_LABEL_Length  = 4;
									int nDATA_FIELD_Length  = 4;
									int nCACHE_NAME_Length  = 4;
									foreach(DataRow row in dtFields.Rows)
									{
										nFIELD_INDEX_Length = Math.Max(nFIELD_INDEX_Length, Sql.EscapeSQL(Sql.ToString(row["FIELD_INDEX"])).Length);
										nDATA_LABEL_Length  = Math.Max(nDATA_LABEL_Length , Sql.EscapeSQL(Sql.ToString(row["DATA_LABEL" ])).Length + 2);
										nDATA_FIELD_Length  = Math.Max(nDATA_FIELD_Length , Sql.EscapeSQL(Sql.ToString(row["DATA_FIELD" ])).Length + 2);
										nCACHE_NAME_Length  = Math.Max(nCACHE_NAME_Length , Sql.EscapeSQL(Sql.ToString(row["CACHE_NAME" ])).Length + 2);
									}

									sb.AppendLine("if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = '" + sNAME + "' and DELETED = 0) begin -- then");
									sb.AppendLine("	print 'EDITVIEWS_FIELDS " + sNAME + "';");

									string sLABEL_WIDTH  = Sql.ToString(dtFields.Rows[0]["LABEL_WIDTH" ]);
									string sFIELD_WIDTH  = Sql.ToString(dtFields.Rows[0]["FIELD_WIDTH" ]);
									string sDATA_COLUMNS = Sql.ToString(dtFields.Rows[0]["DATA_COLUMNS"]);
									string sVIEW_NAME    = Sql.ToString(dtFields.Rows[0]["VIEW_NAME"   ]);
									string sMODULE_NAME  = Sql.ToString(dtFields.Rows[0]["MODULE_NAME" ]);
									if ( Sql.IsEmptyString(sDATA_COLUMNS) ) sDATA_COLUMNS = "null";
									sb.AppendLine("	exec dbo.spEDITVIEWS_InsertOnly             '" + sNAME + "', " + Sql.FormatSQL(sMODULE_NAME, 0) + ", " + Sql.FormatSQL(sVIEW_NAME, 0) + ", " + Sql.FormatSQL(sLABEL_WIDTH, 0) + ", " + Sql.FormatSQL(sFIELD_WIDTH, 0) + ", " + sDATA_COLUMNS + ";");
									foreach(DataRow row in dtFields.Rows)
									{
										string sEDIT_NAME               = Sql.ToString (row["EDIT_NAME"              ]);
										string sFIELD_INDEX             = Sql.ToString (row["FIELD_INDEX"            ]);
										string sFIELD_TYPE              = Sql.ToString (row["FIELD_TYPE"             ]);
										string sDATA_LABEL              = Sql.ToString (row["DATA_LABEL"             ]);
										string sDATA_FIELD              = Sql.ToString (row["DATA_FIELD"             ]);
										string sDATA_FORMAT             = Sql.ToString (row["DATA_FORMAT"            ]);
										string sDISPLAY_FIELD           = Sql.ToString (row["DISPLAY_FIELD"          ]);
										string sCACHE_NAME              = Sql.ToString (row["CACHE_NAME"             ]);
										int    nDATA_REQUIRED           = Sql.ToInteger(row["DATA_REQUIRED"          ]);
										int    nUI_REQUIRED             = Sql.ToInteger(row["UI_REQUIRED"            ]);
										string sONCLICK_SCRIPT          = Sql.ToString (row["ONCLICK_SCRIPT"         ]);
										string sFORMAT_SCRIPT           = Sql.ToString (row["FORMAT_SCRIPT"          ]);
										string sFORMAT_TAB_INDEX        = Sql.ToString (row["FORMAT_TAB_INDEX"       ]);
										string sFORMAT_MAX_LENGTH       = Sql.ToString (row["FORMAT_MAX_LENGTH"      ]);
										string sFORMAT_SIZE             = Sql.ToString (row["FORMAT_SIZE"            ]);
										string sFORMAT_ROWS             = Sql.ToString (row["FORMAT_ROWS"            ]);
										string sFORMAT_COLUMNS          = Sql.ToString (row["FORMAT_COLUMNS"         ]);
										string sCOLSPAN                 = Sql.ToString (row["COLSPAN"                ]);
										string sROWSPAN                 = Sql.ToString (row["ROWSPAN"                ]);
										string sFIELD_VALIDATOR_NAME    = Sql.ToString (row["FIELD_VALIDATOR_NAME"   ]);
										string sFIELD_VALIDATOR_MESSAGE = Sql.ToString (row["FIELD_VALIDATOR_MESSAGE"]);
										string sMODULE_TYPE             = Sql.ToString (row["MODULE_TYPE"            ]);
										// 01/06/2018 Paul.  Change to spEDITVIEWS_FIELDS_Update to capture all fields. 
										string sFIELD_VALIDATOR_ID         = Sql.ToString (row["FIELD_VALIDATOR_ID"        ]);
										string sRELATED_SOURCE_MODULE_NAME = Sql.ToString (row["RELATED_SOURCE_MODULE_NAME"]);
										string sRELATED_SOURCE_VIEW_NAME   = Sql.ToString (row["RELATED_SOURCE_VIEW_NAME"  ]);
										string sRELATED_SOURCE_ID_FIELD    = Sql.ToString (row["RELATED_SOURCE_ID_FIELD"   ]);
										string sRELATED_SOURCE_NAME_FIELD  = Sql.ToString (row["RELATED_SOURCE_NAME_FIELD" ]);
										string sRELATED_VIEW_NAME          = Sql.ToString (row["RELATED_VIEW_NAME"         ]);
										string sRELATED_ID_FIELD           = Sql.ToString (row["RELATED_ID_FIELD"          ]);
										string sRELATED_NAME_FIELD         = Sql.ToString (row["RELATED_NAME_FIELD"        ]);
										string sRELATED_JOIN_FIELD         = Sql.ToString (row["RELATED_JOIN_FIELD"        ]);
										string sPARENT_FIELD               = Sql.ToString (row["PARENT_FIELD"              ]);

										// 06/12/2009 Paul.  Add TOOL_TIP for help hover.
										string sTOOL_TIP    = Sql.ToString(row["TOOL_TIP"   ]);
										
										string sDATA_REQUIRED = nDATA_REQUIRED.ToString();
										string sUI_REQUIRED   = nUI_REQUIRED.ToString();
										sFIELD_INDEX = Strings.Space(nFIELD_INDEX_Length - sFIELD_INDEX.Length) + sFIELD_INDEX;
										if ( Sql.IsEmptyString(sFORMAT_TAB_INDEX ) ) sFORMAT_TAB_INDEX  = "null";
										if ( Sql.IsEmptyString(sFORMAT_MAX_LENGTH) ) sFORMAT_MAX_LENGTH = "null";
										if ( Sql.IsEmptyString(sFORMAT_SIZE      ) ) sFORMAT_SIZE       = "null";
										if ( Sql.IsEmptyString(sFORMAT_ROWS      ) || sFORMAT_ROWS    == "0" ) sFORMAT_ROWS       = "null";
										if ( Sql.IsEmptyString(sFORMAT_COLUMNS   ) || sFORMAT_COLUMNS == "0" ) sFORMAT_COLUMNS    = "null";
										if ( Sql.IsEmptyString(sCOLSPAN          ) || sCOLSPAN        == "0" ) sCOLSPAN           = "null";
										if ( Sql.IsEmptyString(sROWSPAN          ) || sROWSPAN        == "0" ) sROWSPAN           = "null";
										switch ( sFIELD_TYPE )
										{
											case "Blank"             :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBlank        '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + sCOLSPAN + ";");  break;
											// 09/02/2012 Paul.  A separator is just like a blank. 
											case "Separator"         :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsSeparator    '" + sEDIT_NAME + "', " + sFIELD_INDEX + ";");  break;
											case "ChangeButton"      :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsChange       '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + Sql.FormatSQL(sDISPLAY_FIELD, 0) + ", " + Sql.FormatSQL(sONCLICK_SCRIPT, 0) + ", " + sCOLSPAN + ";");  break;
											case "HtmlEditor"        :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsHtmlEditor   '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + sFORMAT_ROWS + ", " + sFORMAT_COLUMNS + ", " + sCOLSPAN + ";");  break;
											case "ListBox"           :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + Sql.FormatSQL(sCACHE_NAME, nCACHE_NAME_Length) + ", " + sCOLSPAN + ", " + sFORMAT_ROWS + ";");  break;
											case "Password"          :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsPassword     '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + sFORMAT_MAX_LENGTH + ", " + sFORMAT_SIZE + ", " + sCOLSPAN + ";");  break;
											case "File"              :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsFile         '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + sFORMAT_MAX_LENGTH + ", " + sFORMAT_SIZE + ", " + sCOLSPAN + ";");  break;
											// 02/16/2010 Paul.  Allow export of ModulePopup. 
											case "ModulePopup"       :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + Sql.FormatSQL(sDISPLAY_FIELD, 0) + ", '" + sMODULE_TYPE + "', " + sCOLSPAN + ";");  break;
											// 04/13/2016 Paul.  Add ZipCode lookup. 
											// 06/21/2017 Paul.  The correct procedure name is spEDITVIEWS_FIELDS_InsZipCode. 
											case "ZipCodePopup"      :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsZipCode      '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + sFORMAT_MAX_LENGTH + ", " + sFORMAT_SIZE + ", " + sCOLSPAN + ";");  break;
											// 01/06/2018 Paul.  Allow export of ModuleAutoComplete, CheckBox, CheckBoxList, Header, Label, TeamSelect, TagSelect, NAICSCodeSelect, UserSelect, DatePicker, DateRange, DateTimePicker, DateTimeEdit, DateTimeNewRecord.
											case "ModuleAutoComplete":  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + sFORMAT_MAX_LENGTH + ", " + sFORMAT_SIZE + ", '" + sMODULE_TYPE + "', " + sCOLSPAN + ";");  break;
											case "CheckBox"          :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsCheckBox     '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + Sql.FormatSQL(sONCLICK_SCRIPT, 0) + ", " + sCOLSPAN + ", " + sROWSPAN + ";");  break;
											case "CheckBoxList"      :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsCheckLst     '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + Sql.FormatSQL(sCACHE_NAME, nCACHE_NAME_Length) + ", " + Sql.FormatSQL(sDATA_FORMAT, 0) + ", " + sCOLSPAN + ", " + sROWSPAN + ";");  break;
											case "Label"             :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsLabel        '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sCOLSPAN + ";");  break;
											case "Header"            :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsHeader       '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + sCOLSPAN + ";");  break;
											case "TeamSelect"        :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsTeamSelect   '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + sFORMAT_TAB_INDEX + ", " + sCOLSPAN + ";");  break;
											case "TagSelect"         :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsTagSelect    '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + sFORMAT_TAB_INDEX + ", " + sCOLSPAN + ";");  break;
											case "NAICSCodeSelect"   :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsNaicsSelect  '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + sFORMAT_TAB_INDEX + ", " + sCOLSPAN + ";");  break;
											case "UserSelect"        :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsUserSelect   '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + sFORMAT_TAB_INDEX + ", " + sCOLSPAN + ";");  break;
											case "DatePicker"        :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsDatePick     '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + sCOLSPAN + ", " + sROWSPAN + ";");  break;
											case "DateRange"         :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsDateRng      '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + sCOLSPAN + ", " + sROWSPAN + ";");  break;
											case "DateTimePicker"    :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsTimePick     '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + sCOLSPAN + ", " + sROWSPAN + ";");  break;
											case "DateTimeEdit"      :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsTimeEdit     '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + sCOLSPAN + ", " + sROWSPAN + ";");  break;
											case "DateTimeNewRecord" :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsTimeNew      '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + sCOLSPAN + ", " + sROWSPAN + ";");  break;
											case "TextBox"           :
												// 05/12/2013 Paul.  sFORMAT_ROWS and sFORMAT_COLUMNS are set to null a file lines above. 
												if ( (Sql.IsEmptyString(sFORMAT_ROWS) && Sql.IsEmptyString(sFORMAT_COLUMNS)) || (sFORMAT_ROWS == "null" && sFORMAT_COLUMNS == "null") )
													sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsBound        '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + sFORMAT_MAX_LENGTH + ", " + sFORMAT_SIZE + ", " + sCOLSPAN + ";");
												else
													sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine    '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + sFORMAT_ROWS + ", " + sFORMAT_COLUMNS + ", " + sCOLSPAN + ";");
												break;
											// 06/02/2009 Paul.  Fix export to support DatePicker. 
											// 01/06/2018 Paul.  Change to spEDITVIEWS_FIELDS_Update to capture all fields. 
											//default                  :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsControl      '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sDATA_REQUIRED + ", " + sFORMAT_TAB_INDEX + ", " + Sql.FormatSQL(sFIELD_TYPE, 0) + ", " + Sql.FormatSQL(sONCLICK_SCRIPT, 0) + ", " + sCOLSPAN + ", " + sROWSPAN + ";");  break;
											default                  :  sb.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_Update null, null, '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sFIELD_TYPE, 0) + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + Sql.FormatSQL(sDISPLAY_FIELD, 0) + ", " + Sql.FormatSQL(sCACHE_NAME, nCACHE_NAME_Length) + ", " + sDATA_REQUIRED + ", " + sUI_REQUIRED + ", " + Sql.FormatSQL(sONCLICK_SCRIPT, 0) + ", " + Sql.FormatSQL(sFORMAT_SCRIPT, 0) + ", " + sFORMAT_TAB_INDEX + ", " + sFORMAT_MAX_LENGTH + ", " + sFORMAT_SIZE + ", " + sFORMAT_ROWS + ", " + sFORMAT_COLUMNS + ", " + sCOLSPAN + ", " + sROWSPAN + ", " + Sql.FormatSQL(sMODULE_TYPE, 0) + ", " + Sql.FormatSQL(sTOOL_TIP, 0) + ", " + Sql.FormatSQL(sFIELD_VALIDATOR_ID, 0) + ", " + Sql.FormatSQL(sFIELD_VALIDATOR_MESSAGE, 0) + ", " + Sql.FormatSQL(sDATA_FORMAT, 0) + ", " + Sql.FormatSQL(sRELATED_SOURCE_MODULE_NAME, 0) + ", " + Sql.FormatSQL(sRELATED_SOURCE_VIEW_NAME, 0) + ", " + Sql.FormatSQL(sRELATED_SOURCE_ID_FIELD, 0) + ", " + Sql.FormatSQL(sRELATED_SOURCE_NAME_FIELD, 0) + ", " + Sql.FormatSQL(sRELATED_VIEW_NAME, 0) + ", " + Sql.FormatSQL(sRELATED_ID_FIELD, 0) + ", " + Sql.FormatSQL(sRELATED_NAME_FIELD, 0) + ", " + Sql.FormatSQL(sRELATED_JOIN_FIELD, 0) + ", " + Sql.FormatSQL(sPARENT_FIELD, 0) + ";");  break;
										}
										// 06/12/2009 Paul.  Add TOOL_TIP for help hover.
										if ( !Sql.IsEmptyString(sTOOL_TIP) )
										{
											// 09/20/2012 Paul.  Remove break at the end of the line. 
											sbUpdates.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_UpdateTip  null, '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sTOOL_TIP, 0) + ";");
										}
										// 01/19/2010 Paul.  Add support for new DATA_FORMAT field. 
										if ( !Sql.IsEmptyString(sDATA_FORMAT) )
										{
											// 09/20/2012 Paul.  Remove break at the end of the line. 
											sbUpdates.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_UpdateDataFormat  null, '" + sEDIT_NAME + "', '" + sDATA_FIELD + "', " + Sql.FormatSQL(sDATA_FORMAT, 0) + ";");
										}
										if ( !Sql.IsEmptyString(sFIELD_VALIDATOR_NAME) )
										{
											sbUpdates.AppendLine("	exec dbo.spEDITVIEWS_FIELDS_InsValidator   '" + sEDIT_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sFIELD_VALIDATOR_NAME, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + Sql.FormatSQL(sFIELD_VALIDATOR_MESSAGE, 0) + ";");
										}
									}
									// 01/06/2018 Paul.  Place updates at the end. 
									if ( sbUpdates.Length > 0 )
										sb.Append(sbUpdates.ToString());
									sb.AppendLine("end -- if;");
								}
							}
						}
					}
				}
				sb.AppendLine("GO");
				sb.AppendLine("");
				// 08/17/2024 Paul.  The correct MIME type is text/plain. 
				Response.ContentType = "text/plain";
				// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
				// 02/16/2010 Paul.  Must include all parts of the name in the encoding. 
				Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(Request.Browser, "EDITVIEWS_FIELDS " + sNAME + ".1.sql"));
				Response.Write(sb.ToString());
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
		}
		#endregion
	}
}

