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
using System.Text;
using System.Xml;
using System.Web;
using System.Collections;
using System.Collections.Generic;
using DocumentFormat.OpenXml;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using System.Diagnostics;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for SplendidExport.
	/// </summary>
	public class SplendidExport
	{
		// 10/05/2009 Paul.  If we are using custom paging, we need to change the way we export the entire page. 
		public static void Export(DataView vw, string sModuleName, string sExportFormat, string sExportRange, int nCurrentPage, int nPageSize, string[] arrID, bool bCustomPaging)
		{
			int nStartRecord = 0;
			int nEndRecord   = vw.Count;
			switch ( sExportRange )
			{
				case "Page":
				{
					// 10/05/2009 Paul.  When using custom paging, we want to return all records when exporting the entire page. 
					if ( !bCustomPaging )
					{
						nStartRecord = nCurrentPage * nPageSize;
						nEndRecord   = Math.Min(nStartRecord + nPageSize, vw.Count);
					}
					break;
				}
				case "Selected":
				{
					// 10/17/2006 Paul.  There must be one selected record to continue. 
					if ( arrID == null )
					{
						L10N L10n = HttpContext.Current.Items["L10n"] as L10N;
						throw(new Exception(L10n.Term(".LBL_LISTVIEW_NO_SELECTED")));
					}
					StringBuilder sbIDs = new StringBuilder();
					int nCount = 0;
					foreach(string item in arrID)
					{
						if ( nCount > 0 )
							sbIDs.Append(" or ");
						// 04/30/2011 Paul.  RowFilter does not like using Guids in the IN clause, but we could use convert to solve the problem. 
						// http://weblogs.asp.net/emilstoichev/archive/2008/03/26/tip-rowfilter-with-in-operator-over-a-column-of-type-guid.aspx
						//sbIDs.Append("Convert('" + item.Replace("\'", "\'\'") + "', 'System.Guid')");
						sbIDs.AppendLine("ID = \'" + item.Replace("\'", "\'\'") + "\'");
						nCount++;
					}
					//vw.RowFilter = "ID in (" + sbIDs.ToString() + ")";
					// 11/03/2006 Paul.  A filter might already exist, so make sure to maintain the existing filter. 
					if ( vw.RowFilter.Length > 0 )
						vw.RowFilter = " and (" + sbIDs.ToString() + ")";
					else
						vw.RowFilter = sbIDs.ToString();
					nEndRecord = vw.Count;
					break;
				}
			}
			
			HttpResponse Response = HttpContext.Current.Response;
			// 11/29/2013 Paul.  If an exception is thrown, clear the content and the headers so that the error can be displayed to the user. 
			try
			{
				StringBuilder sb = new StringBuilder();
				switch ( sExportFormat )
				{
					case "csv"  :
						Response.ContentType = "text/csv";
						// 08/06/2008 yxy21969.  Make sure to encode all URLs. 
						// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
						Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(HttpContext.Current.Request.Browser, sModuleName + ".csv"));
						ExportDelimited(Response.OutputStream, vw, sModuleName, nStartRecord, nEndRecord, ',' );
						Response.End();
						break;
					case "tab"  :
						Response.ContentType = "text/txt";
						// 08/06/2008 yxy21969.  Make sure to encode all URLs. 
						// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
						Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(HttpContext.Current.Request.Browser, sModuleName + ".txt"));
						ExportDelimited(Response.OutputStream, vw, sModuleName, nStartRecord, nEndRecord, '\t');
						Response.End();
						break;
					case "xml"  :
						Response.ContentType = "text/xml";
						// 08/06/2008 yxy21969.  Make sure to encode all URLs. 
						// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
						Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(HttpContext.Current.Request.Browser, sModuleName + ".xml"));
						ExportXml(Response.OutputStream, vw, sModuleName, nStartRecord, nEndRecord);
						Response.End();
						break;
					//case "Excel":
					default     :
						// 08/25/2012 Paul.  Change Excel export type to use Open XML as the previous format is not supported on Office 2010. 
						Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";  //"application/vnd.ms-excel";
						// 08/06/2008 yxy21969.  Make sure to encode all URLs. 
						// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
						Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(HttpContext.Current.Request.Browser, sModuleName + ".xlsx"));
						ExportExcelOpenXML(Response.OutputStream, vw, sModuleName, nStartRecord, nEndRecord);
						Response.End();
						break;
				}
			}
			catch(Exception ex)
			{
				if ( !(ex is System.Threading.ThreadAbortException) )
				{
					// 11/29/2013 Paul.  In case of exception, try and clear the response type
					Response.ClearContent();
					Response.ClearHeaders();
					Response.ContentType = "text/html";
					throw(ex);
				}
			}
			//vw.RowFilter = null;
		}

		// http://lateral8.com/articles/2010/3/5/openxml-sdk-20-export-a-datatable-to-excel.aspx
		private static string OpenXML_GetColumnName(int nColumnIndex)
		{
			string sColumnName = String.Empty;
			while ( nColumnIndex > 0 )
			{
				int nRemainder = (nColumnIndex - 1) % 26;
				sColumnName = Convert.ToChar(65 + nRemainder).ToString() + sColumnName;
				nColumnIndex = (nColumnIndex - nRemainder) / 26;
			}
			return sColumnName;
		}

		// 11/29/2013 Paul.  We need to remove items that cause an invalid character exception. 
		private static void OpenXML_RemoveText(SharedStringTablePart shareStringPart, string text, Dictionary<string, int> dictStringToInt)
		{
			if ( shareStringPart.SharedStringTable == null )
			{
				return;
			}

			int i = 0;
			// 11/29/2013 Paul.  Use dictionary to increase performance. 
			if ( dictStringToInt.ContainsKey(text) )
			{
				int iExisting = dictStringToInt[text];
				dictStringToInt.Remove(text);
				// 11/29/2013 Paul.  Most of the time the last item will be the item to remove, so try it first. 
				SharedStringItem last = shareStringPart.SharedStringTable.LastChild as SharedStringItem;
				if ( last != null && last.InnerText == text )
				{
					shareStringPart.SharedStringTable.RemoveChild<SharedStringItem>(last);
					shareStringPart.SharedStringTable.Save();
				}
				else
				{
					foreach ( SharedStringItem item in shareStringPart.SharedStringTable.Elements<SharedStringItem>() )
					{
						// 11/29/2013 Paul.  Comparing integers should make this loop significantly faster. 
						if ( i == iExisting )
						{
							// 11/29/2013 Paul.  Keep the text comparison as a form of defensive programming. 
							if ( item.InnerText == text )
							{
								shareStringPart.SharedStringTable.RemoveChild<SharedStringItem>(item);
								shareStringPart.SharedStringTable.Save();
								break;
							}
						}
						i++;
					}
				}
			}
		}

		// 11/29/2013 Paul.  Use dictionary to increase performance. 
		private static int OpenXML_InsertSharedStringItem(SharedStringTablePart shareStringPart, string text, Dictionary<string, int> dictStringToInt)
		{
			if ( shareStringPart.SharedStringTable == null )
			{
				shareStringPart.SharedStringTable = new SharedStringTable();
			}

			int i = 0;
			// 11/29/2013 Paul.  Use dictionary to increase performance. 
			if ( dictStringToInt.ContainsKey(text) )
			{
				i = dictStringToInt[text];
				return i;
			}
			// 11/29/2013 Paul.  shareStringPart.SharedStringTable.Count seems to always be null. 
			if ( shareStringPart.SharedStringTable.ChildElements != null )
				i = shareStringPart.SharedStringTable.ChildElements.Count;
			// Iterate through all the items in the SharedStringTable. If the text already exists, return its index.
			//foreach ( SharedStringItem item in shareStringPart.SharedStringTable.Elements<SharedStringItem>() )
			//{
			//	if ( item.InnerText == text )
			//	{
			//		return i;
			//	}
			//	i++;
			//}

			// The text does not exist in the part. Create the SharedStringItem and return its index.
			shareStringPart.SharedStringTable.AppendChild(new SharedStringItem(new DocumentFormat.OpenXml.Spreadsheet.Text(text)));
			// 11/29/2013 Paul.  Add to dictionary before save as save can throw an exception. 
			dictStringToInt.Add(text, i);
			shareStringPart.SharedStringTable.Save();
			return i;
		}

		// 11/29/2013 Paul.  Use dictionary to increase performance. 
		private static DocumentFormat.OpenXml.Spreadsheet.Cell OpenXML_CreateText(int nColumnIndex, int nRowIndex, SharedStringTablePart shareStringPart, string sText, Dictionary<string, int> dictStringToInt)
		{
			//int nSharedIndex = OpenXML_InsertSharedStringItem(shareStringPart, sText, dictStringToInt);
			DocumentFormat.OpenXml.Spreadsheet.Cell cell = new DocumentFormat.OpenXml.Spreadsheet.Cell();
			cell.CellReference = OpenXML_GetColumnName(nColumnIndex) + nRowIndex.ToString();
			// 12/02/2013 Paul.  SharedString got very slow after 2000 records.  7000 records was taking an hour to export. 
			// http://social.msdn.microsoft.com/Forums/office/en-US/0dcb58a0-5193-4ab7-b2c6-2742dd9e1be8/openxmlwriter-performance-issue-while-writing-large-excel-file-35000-rows-and-100-cells?forum=oxmlsdk
			//cell.DataType      = CellValues.SharedString;
			//cell.CellValue     = new CellValue(nSharedIndex.ToString());
			cell.SetAttribute(new OpenXmlAttribute("", "t", "", "inlineStr"));
			// 12/02/2013 Paul.  Try and filter invalid characters. 
			if ( sText.Length > 0 )
			{
				char[] arr = sText.ToCharArray();
				for ( int i = 0; i < arr.Length; i++ )
				{
					char ch = arr[i];
					// http://social.technet.microsoft.com/Forums/en-US/4a51a8e8-7697-44a2-813f-d3704c8cfc02/hexadecimal-value-is-an-invalid-character-cant-generate-reports?forum=map
					if ( ch == ControlChars.Cr || ch == ControlChars.Lf || ch == ControlChars.Tab )
					{
						continue;
					}
					else if ( ch < ' ' )
					{
						throw(new Exception("Invalid character 0x" + Convert.ToInt32(ch).ToString("x")));
					}
				}
			}
			cell.InlineString = new DocumentFormat.OpenXml.Spreadsheet.InlineString { Text = new Text { Text = sText } };
			return cell;
		}

		private static DocumentFormat.OpenXml.Spreadsheet.Cell OpenXML_CreateNumber(int nColumnIndex, int nRowIndex, string sText, UInt32Value styleId)
		{
			DocumentFormat.OpenXml.Spreadsheet.Cell cell = new DocumentFormat.OpenXml.Spreadsheet.Cell();
			cell.CellReference = OpenXML_GetColumnName(nColumnIndex) + nRowIndex.ToString();
			cell.DataType      = CellValues.Number;
			cell.CellValue     = new CellValue(sText);
			cell.StyleIndex    = styleId;
			return cell;
		}

		private static DocumentFormat.OpenXml.Spreadsheet.Cell OpenXML_CreateDate(int nColumnIndex, int nRowIndex, DateTime dtValue, UInt32Value styleId)
		{
			DocumentFormat.OpenXml.Spreadsheet.Cell cell = new DocumentFormat.OpenXml.Spreadsheet.Cell();
			cell.CellReference = OpenXML_GetColumnName(nColumnIndex) + nRowIndex.ToString();
			cell.DataType      = CellValues.Date;
			cell.CellValue     = new CellValue(dtValue.ToUniversalTime().ToString("s"));
			cell.StyleIndex    = styleId;
			return cell;
		}

		private static DocumentFormat.OpenXml.Spreadsheet.Cell OpenXML_CreateBoolean(int nColumnIndex, int nRowIndex, string sText)
		{
			DocumentFormat.OpenXml.Spreadsheet.Cell cell = new DocumentFormat.OpenXml.Spreadsheet.Cell();
			cell.CellReference = OpenXML_GetColumnName(nColumnIndex) + nRowIndex.ToString();
			cell.DataType      = CellValues.Boolean;
			cell.CellValue     = new CellValue(sText);
			return cell;
		}

		// http://www.lateral8.com/articles/2010/6/11/openxml-sdk-20-formatting-excel-values.aspx
		private static UInt32Value OpenXML_CreateCellFormat(Stylesheet styleSheet, UInt32Value fontIndex, UInt32Value fillIndex, UInt32Value numberFormatId)
		{
			CellFormat cellFormat = new CellFormat();
			if ( fontIndex != null )
				cellFormat.FontId = fontIndex;
			if ( fillIndex != null )
				cellFormat.FillId = fillIndex;
 
			if ( numberFormatId != null )
			{
				cellFormat.NumberFormatId = numberFormatId;
				cellFormat.ApplyNumberFormat = BooleanValue.FromBoolean(true);
			}
			if ( styleSheet.CellFormats == null )
				styleSheet.CellFormats = new CellFormats() { Count = 0 };
			styleSheet.CellFormats.Append(cellFormat);
			UInt32Value result = styleSheet.CellFormats.Count;
			styleSheet.CellFormats.Count++;
			return result;
		}

		private static Stylesheet OpenXML_CreateStylesheet()
		{
			// 08/25/2012 Paul.  The file will be corrupt unless fonts, fills and borders are also provided. 
			var stylesheet = new Stylesheet();
			var fonts       = new Fonts      (new[] { new Font      () }) { Count = 1 };
			var fills       = new Fills      (new[] { new Fill      () }) { Count = 1 };
			var borders     = new Borders    (new[] { new Border    () }) { Count = 1 };
			var cellFormats = new CellFormats(new[] { new CellFormat() }) { Count = 1 };
			stylesheet.Append(fonts      );
			stylesheet.Append(fills      );
			stylesheet.Append(borders    );
			stylesheet.Append(cellFormats);
			return stylesheet;
		}

		// 09/08/2020 Paul.  Some customers want exported lists to be translated. 
		private static Dictionary<string, string> GetExportTranslatedLists(string sModuleName)
		{
			HttpContext Context = HttpContext.Current;
			Dictionary<string, string> dict = new Dictionary<string, string>();
			if ( Context != null )
			{
				// 09/08/2020 Paul.  This feature is configurable with the default being off. 
				if ( Sql.ToBoolean(Context.Application["CONFIG.export_translate_lists"]) )
				{
					DataTable dt = SplendidCache.GridViewColumns(sModuleName + ".Export", Security.PRIMARY_ROLE_NAME);
					if ( dt != null )
					{
						foreach(DataRow row in dt.Rows)
						{
							string sCOLUMN_TYPE = Sql.ToString (row["COLUMN_TYPE"]);
							string sDATA_FIELD  = Sql.ToString (row["DATA_FIELD" ]);
							string sLIST_NAME   = Sql.ToString (row["LIST_NAME"  ]);
							if ( String.Compare(sCOLUMN_TYPE, "BoundColumn", true) == 0 )
							{
								if ( !Sql.IsEmptyString(sLIST_NAME) )
								{
									if ( !dict.ContainsKey(sDATA_FIELD) )
									{
										dict.Add(sDATA_FIELD, sLIST_NAME);
									}
								}
							}
						}
					}
				}
			}
			return dict;
		}

		private static string TranslateExportedvalue(Dictionary<string, string> dict, L10N L10n, string sDATA_FIELD, DataRowView row)
		{
			string sValue = Sql.ToString(row[sDATA_FIELD]);
			if ( dict.ContainsKey(sDATA_FIELD) )
			{
				string sLIST_NAME = dict[sDATA_FIELD];
				if ( !Sql.IsEmptyString(sLIST_NAME) )
				{
					// 09/08/2020 Paul.  This code is very similar to CreateItemTemplateLiteralList.OnDataBinding(). 
					string sList = sLIST_NAME;
					bool bCustomCache = false;
					sValue = SplendidCache.CustomList(sLIST_NAME, sValue, ref bCustomCache);
					if ( bCustomCache )
						return sValue;
					// 01/18/2007 Paul.  If AssignedUser list, then use the cached value to find the value. 
					if ( sLIST_NAME == "AssignedUser" )
					{
						sValue = SplendidCache.AssignedUser(Sql.ToGuid(row[sDATA_FIELD]));
					}
					// 12/05/2005 Paul.  The activity status needs to be dynamically converted to the correct list. 
					else if ( sLIST_NAME == "activity_status" && row.Row.Table.Columns.Contains("ACTIVITY_TYPE") )
					{
						string sACTIVITY_TYPE = String.Empty;
						try
						{
							sACTIVITY_TYPE = Sql.ToString(row["ACTIVITY_TYPE"]);
							switch ( sACTIVITY_TYPE )
							{
								case "Tasks"   :  sList = "task_status_dom"   ;  break;
								case "Meetings":  sList = "meeting_status_dom";  break;
								case "Calls"   :  sList = "call_status_dom"   ;  break;
								case "Notes"   :
									// 07/15/2006 Paul.  Note Status is not normally as it does not have a status. 
									sValue = L10n.Term(".activity_dom.Note");
									return sValue;
								// 06/15/2006 Paul.  This list name for email_status does not follow the standard. 
								case "Emails"  :  sList = "dom_email_status"  ;  break;
								// 09/26/2013 Paul.  Add Sms Messages status. 
								case "SmsMessages":  sList = "dom_sms_status"  ;  break;
								// 04/21/2006 Paul.  If the activity does not have a status (such as a Note), then use activity_dom. 
								default        :  sList = "activity_dom"      ;  break;
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						sValue = Sql.ToString(L10n.Term("." + sList + ".", row[sDATA_FIELD]));
					}
					// 02/12/2008 Paul.  If the list contains XML, then treat as a multi-selection. 
					else if ( Sql.ToString(row[sDATA_FIELD]).StartsWith("<?xml") )
					{
						// 07/12/2018 Paul.  XML data may not be formatted properly. 
						try
						{
							StringBuilder sb = new StringBuilder();
							XmlDocument xml = new XmlDocument();
							// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
							// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
							// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
							xml.XmlResolver = null;
							xml.LoadXml(Sql.ToString(row[sDATA_FIELD]));
							XmlNodeList nlValues = xml.DocumentElement.SelectNodes("Value");
							foreach ( XmlNode xValue in nlValues )
							{
								if ( sb.Length > 0 )
									sb.Append(", ");
								sb.Append(L10n.Term("." + sLIST_NAME + ".", xValue.InnerText));
							}
							sValue = sb.ToString();
						}
						catch(Exception ex)
						{
							// 07/12/2018 Paul.  We might want to display more detailed information in the error log. 
							// Less likely needed in the cell of the grid because the row has the ID and the column header has the field name. 
							//string sID = String.Empty;
							//if ( row.Row.Table.Columns.Contains("ID") )
							//	sID = Sql.ToString(row["ID"]);
							//sValue = "Error loading xml data for " + sDATA_FIELD + " for ID " + sID + " :" + ex.Message;
							sValue = ex.Message;
						}
					}
					else
					{
						sValue = Sql.ToString(L10n.Term("." + sList + ".", row[sDATA_FIELD]));
					}
				}
			}
			return sValue;
		}

		// 08/25/2012 Paul.  Change Excel export type to use Open XML as the previous format is not supported on Office 2010. 
		// 12/23/2015 Paul.  Public access to make it easier to export Survey Results. 
		public static void ExportExcelOpenXML(Stream stmResponse, DataView vw, string sModuleName, int nStartRecord, int nEndRecord)
		{
			// 09/08/2020 Paul.  Some customers want exported lists to be translated. 
			Dictionary<string, string> dictTranslatedList = GetExportTranslatedLists(sModuleName);
			
			// 09/23/2015 Paul.  Only export specified fields.  This should get rid of the ID field. 
			UniqueStringCollection arrExportFields = new UniqueStringCollection();
			SplendidDynamic.GridColumns(sModuleName + ".Export", arrExportFields, null);
			DataTable tbl = vw.Table;
			UniqueStringCollection arrValidatedFields = new UniqueStringCollection();
			foreach ( string sField in arrExportFields )
			{
				// 02/26/2018 Paul.  There is a special case where we have a custom field module lookup. 
				if ( sField.Contains(" AS ") )
				{
					string sSubQueryField = sField.Substring(sField.LastIndexOf(" AS ") + 4);
					if ( tbl.Columns.Contains(sSubQueryField) )
						arrValidatedFields.Add(sSubQueryField);
				}
				else if ( tbl.Columns.Contains(sField) )
					arrValidatedFields.Add(sField);
			}
			// 09/23/2015 Paul.  If no fields specified, then use all fields. 
			if ( arrValidatedFields.Count == 0 )
			{
				foreach ( DataColumn col in tbl.Columns )
				{
					arrValidatedFields.Add(col.ColumnName);
				}
			}
			// 09/28/2015 Paul.  Use the label from the grid view. 
			L10N L10n = HttpContext.Current.Items["L10n"] as L10N;
			// 12/15/2019 Paul.  L10n will be nul for Rest service call. 
			if ( L10n == null )
			{
				L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			}
			// 05/10/2016 Paul.  The User Primary Role is used with role-based views. 
			DataTable dtExport = SplendidCache.GridViewColumns(sModuleName + ".Export", Security.PRIMARY_ROLE_NAME);
			Dictionary<string, string> dictTerms = new Dictionary<string, string>();
			foreach ( DataRow row in dtExport.Rows )
			{
				string sDATA_FIELD  = Sql.ToString(row["DATA_FIELD" ]);
				string sHEADER_TEXT = Sql.ToString(row["HEADER_TEXT"]);
				dictTerms[sDATA_FIELD] = L10n.Term(sHEADER_TEXT);
			}

			// http://msdn.microsoft.com/en-us/library/office/ff478153.aspx
			// http://msdn.microsoft.com/en-us/library/office/cc850837
			using ( MemoryStream stm = new MemoryStream() )
			{
				using ( SpreadsheetDocument spreadsheetDocument = SpreadsheetDocument.Create(stm, SpreadsheetDocumentType.Workbook) )
				{
					WorkbookPart workbookPart = spreadsheetDocument.AddWorkbookPart();
					workbookPart.Workbook = new Workbook();
					WorksheetPart worksheetPart = workbookPart.AddNewPart<WorksheetPart>();
					worksheetPart.Worksheet = new Worksheet(new SheetData());
					worksheetPart.Worksheet.Save();
					
					// http://www.codeproject.com/Articles/371203/Creating-basic-Excel-workbook-with-Open-XML
					WorkbookStylesPart workbookStylesPart = workbookPart.AddNewPart<WorkbookStylesPart>();
					workbookStylesPart.Stylesheet = OpenXML_CreateStylesheet();
					workbookStylesPart.Stylesheet.Save();
					
					Sheets sheets = spreadsheetDocument.WorkbookPart.Workbook.AppendChild<Sheets>(new Sheets());
					Sheet sheet = new Sheet() { Id = spreadsheetDocument.WorkbookPart.GetIdOfPart(worksheetPart), SheetId = 1, Name = sModuleName };
					sheets.Append(sheet);
					workbookPart.Workbook.Save();
					
					SharedStringTablePart shareStringPart = spreadsheetDocument.WorkbookPart.AddNewPart<SharedStringTablePart>();
				
					Worksheet worksheet = worksheetPart.Worksheet;
					SheetData sheetData = worksheet.GetFirstChild<SheetData>();
					UInt32Value numberStyleId = OpenXML_CreateCellFormat(workbookStylesPart.Stylesheet, null, null, UInt32Value.FromUInt32( 3));
					UInt32Value doubleStyleId = OpenXML_CreateCellFormat(workbookStylesPart.Stylesheet, null, null, UInt32Value.FromUInt32( 4));
					UInt32Value dateStyleId   = OpenXML_CreateCellFormat(workbookStylesPart.Stylesheet, null, null, UInt32Value.FromUInt32(14));
					
					int rowIndex = 1;
					Dictionary<string, int> dictStringToInt = new Dictionary<string, int>();
					DocumentFormat.OpenXml.Spreadsheet.Cell cell = null;
					DocumentFormat.OpenXml.Spreadsheet.Row xRow = new DocumentFormat.OpenXml.Spreadsheet.Row();
					xRow.RowIndex = (uint) rowIndex;
					sheetData.Append(xRow);
					// 09/23/2015 Paul.  Only export specified fields.  This should get rid of the ID field. 
					for ( int nFieldIndex = 0; nFieldIndex < arrValidatedFields.Count; nFieldIndex++ )
					{
						string sField = arrValidatedFields[nFieldIndex];
						DataColumn col = tbl.Columns[sField];
						// 11/29/2013 Paul.  Use dictionary to increase performance. 
						string sHEADER_TEXT = String.Empty;
						if ( dictTerms.ContainsKey(col.ColumnName) )
							sHEADER_TEXT = dictTerms[col.ColumnName];
						else
							sHEADER_TEXT = Utils.TableColumnName(L10n, sModuleName, col.ColumnName);
						cell = OpenXML_CreateText(nFieldIndex + 1, rowIndex, shareStringPart, sHEADER_TEXT, dictStringToInt);
						xRow.AppendChild(cell);
					}
					rowIndex++;
					
					// 12/02/2013 Paul.  Add a blank string to the shared array so that there is at least one. 
					OpenXML_InsertSharedStringItem(shareStringPart, String.Empty, dictStringToInt);
					for ( int i = nStartRecord; i < nEndRecord; i++, rowIndex++ )
					{
						xRow = new DocumentFormat.OpenXml.Spreadsheet.Row();
						xRow.RowIndex = (uint) rowIndex;
						sheetData.Append(xRow);
						DataRowView row = vw[i];
						// 09/23/2015 Paul.  Only export specified fields.  This should get rid of the ID field. 
						for ( int nFieldIndex = 0; nFieldIndex < arrValidatedFields.Count; nFieldIndex++ )
						{
							string sField = arrValidatedFields[nFieldIndex];
							DataColumn col = tbl.Columns[sField];
							if ( row[sField] != DBNull.Value )
							{
								switch ( col.DataType.FullName )
								{
									case "System.Boolean" :
										//xw.WriteAttributeString("ss:Type", "String");
										cell = OpenXML_CreateBoolean(nFieldIndex + 1, rowIndex, Sql.ToBoolean (row[sField]) ? "1" : "0");
										xRow.AppendChild(cell);
										break;
									case "System.Single"  :
										//xw.WriteAttributeString("ss:Type", "Number");
										cell = OpenXML_CreateNumber(nFieldIndex + 1, rowIndex, Sql.ToDouble  (row[sField]).ToString(), doubleStyleId);
										xRow.AppendChild(cell);
										break;
									case "System.Double"  :
										//xw.WriteAttributeString("ss:Type", "Number");
										cell = OpenXML_CreateNumber(nFieldIndex + 1, rowIndex, Sql.ToDouble  (row[sField]).ToString(), doubleStyleId);
										xRow.AppendChild(cell);
										break;
									case "System.Int16"   :
										//xw.WriteAttributeString("ss:Type", "Number");
										cell = OpenXML_CreateNumber(nFieldIndex + 1, rowIndex, Sql.ToInteger (row[sField]).ToString(), numberStyleId);
										xRow.AppendChild(cell);
										break;
									case "System.Int32"   :
										//xw.WriteAttributeString("ss:Type", "Number");
										cell = OpenXML_CreateNumber(nFieldIndex + 1, rowIndex, Sql.ToInteger (row[sField]).ToString(), numberStyleId);
										xRow.AppendChild(cell);
										break;
									case "System.Int64"   :
										//xw.WriteAttributeString("ss:Type", "Number");
										cell = OpenXML_CreateNumber(nFieldIndex + 1, rowIndex, Sql.ToLong    (row[sField]).ToString(), numberStyleId);
										xRow.AppendChild(cell);
										break;
									case "System.Decimal" :
										//xw.WriteAttributeString("ss:Type", "Number");
										cell = OpenXML_CreateNumber(nFieldIndex + 1, rowIndex, Sql.ToDecimal (row[sField]).ToString(), doubleStyleId);
										xRow.AppendChild(cell);
										break;
									case "System.DateTime":
										//xw.WriteAttributeString("ss:Type", "DateTime");
										cell = OpenXML_CreateDate(nFieldIndex + 1, rowIndex, Sql.ToDateTime(row[sField]), dateStyleId);
										xRow.AppendChild(cell);
										break;
									case "System.Guid"    :
										//xw.WriteAttributeString("ss:Type", "String");
										// 11/29/2013 Paul.  Use dictionary to increase performance. 
										cell = OpenXML_CreateText(nFieldIndex + 1, rowIndex, shareStringPart, Sql.ToGuid    (row[sField]).ToString().ToUpper(), dictStringToInt);
										xRow.AppendChild(cell);
										break;
									case "System.String"  :
									{
										//xw.WriteAttributeString("ss:Type", "String");
										// 11/29/2013 Paul.  Catch and ignore bad data exceptions. This can happen with imported unicode data. 
										// '', hexadecimal value 0x13, is an invalid character.
										// 09/08/2020 Paul.  Some customers want exported lists to be translated. 
										string sValue = TranslateExportedvalue(dictTranslatedList, L10n, sField, row);
										try
										{
											// 11/29/2013 Paul.  Use dictionary to increase performance. 
											cell = OpenXML_CreateText(nFieldIndex + 1, rowIndex, shareStringPart, sValue, dictStringToInt);
										}
										catch
										{
											// 11/29/2013 Paul.  After exception, the item still remains in the list and causes future save operations to fail. 
											// 11/29/2013 Paul.  Use dictionary to increase performance. 
											OpenXML_RemoveText(shareStringPart, sValue, dictStringToInt);
											cell = OpenXML_CreateText(nFieldIndex + 1, rowIndex, shareStringPart, String.Empty, dictStringToInt);
										}
										xRow.AppendChild(cell);
										break;
									}
									case "System.Byte[]"  :
									{
										//xw.WriteAttributeString("ss:Type", "String");
										//byte[] buffer = Sql.ToByteArray((System.Array) row[sField]);
										//xw.WriteBase64(buffer, 0, buffer.Length);
										// 11/29/2013 Paul.  Use dictionary to increase performance. 
										cell = OpenXML_CreateText(nFieldIndex + 1, rowIndex, shareStringPart, String.Empty, dictStringToInt);
										xRow.AppendChild(cell);
										break;
									}
									default:
										//	throw(new Exception("Unsupported field type: " + rdr.GetFieldType(nColumn).FullName));
										// 08/25/2012 Paul.  We need to write the type even for empty cells. 
										//xw.WriteAttributeString("ss:Type", "String");
										// 11/29/2013 Paul.  Use dictionary to increase performance. 
										cell = OpenXML_CreateText(nFieldIndex + 1, rowIndex, shareStringPart, String.Empty, dictStringToInt);
										xRow.AppendChild(cell);
										break;
								}
							}
							else
							{
								// 08/25/2012 Paul.  We need to write the type even for empty cells. 
								// 11/29/2013 Paul.  Use dictionary to increase performance. 
								cell = OpenXML_CreateText(nFieldIndex + 1, rowIndex, shareStringPart, String.Empty, dictStringToInt);
								xRow.AppendChild(cell);
							}
						}
					}
					workbookPart.Workbook.Save();
					spreadsheetDocument.Close();
				}
				stm.WriteTo(stmResponse);
			}
		}

		// 12/23/2015 Paul.  Public access to make it easier to export Survey Results. 
		public static void ExportExcel(Stream stm, DataView vw, string sModuleName, int nStartRecord, int nEndRecord)
		{
			// 09/08/2020 Paul.  Some customers want exported lists to be translated. 
			Dictionary<string, string> dictTranslatedList = GetExportTranslatedLists(sModuleName);
			L10N L10n = HttpContext.Current.Items["L10n"] as L10N;
			if ( L10n == null )
			{
				L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			}
			
			// 09/23/2015 Paul.  Only export specified fields.  This should get rid of the ID field. 
			UniqueStringCollection arrExportFields = new UniqueStringCollection();
			SplendidDynamic.GridColumns(sModuleName + ".Export", arrExportFields, null);
			DataTable tbl = vw.Table;
			UniqueStringCollection arrValidatedFields = new UniqueStringCollection();
			foreach ( string sField in arrExportFields )
			{
				// 02/26/2018 Paul.  There is a special case where we have a custom field module lookup. 
				if ( sField.Contains(" AS ") )
				{
					string sSubQueryField = sField.Substring(sField.LastIndexOf(" AS ") + 4);
					if ( tbl.Columns.Contains(sSubQueryField) )
						arrValidatedFields.Add(sSubQueryField);
				}
				else if ( tbl.Columns.Contains(sField) )
					arrValidatedFields.Add(sField);
			}
			// 09/23/2015 Paul.  If no fields specified, then use all fields. 
			if ( arrValidatedFields.Count == 0 )
			{
				foreach ( DataColumn col in tbl.Columns )
				{
					arrValidatedFields.Add(col.ColumnName);
				}
			}

			XmlTextWriter xw = new XmlTextWriter(stm, Encoding.UTF8);
			xw.Formatting  = Formatting.Indented;
			xw.IndentChar  = ControlChars.Tab;
			xw.Indentation = 1;
			xw.WriteStartDocument();
			xw.WriteProcessingInstruction("mso-application", "progid=\"Excel.Sheet\"");

			xw.WriteStartElement("Workbook");
				xw.WriteAttributeString("xmlns", "urn:schemas-microsoft-com:office:spreadsheet");
				xw.WriteAttributeString("xmlns:o", "urn:schemas-microsoft-com:office:office");
				xw.WriteAttributeString("xmlns:x", "urn:schemas-microsoft-com:office:excel");
				xw.WriteAttributeString("xmlns:ss", "urn:schemas-microsoft-com:office:spreadsheet");
				xw.WriteAttributeString("xmlns:html", "http://www.w3.org/TR/REC-html40");

			xw.WriteStartElement("DocumentProperties");
				xw.WriteAttributeString("xmlns", "urn:schemas-microsoft-com:office:office");
				xw.WriteStartElement("Author");
					xw.WriteString(Security.FULL_NAME);
				xw.WriteEndElement();
				xw.WriteStartElement("Created");
					xw.WriteString(DateTime.Now.ToUniversalTime().ToString("s"));
				xw.WriteEndElement();
				xw.WriteStartElement("Version");
					xw.WriteString("11.6568");
				xw.WriteEndElement();
			xw.WriteEndElement();
			xw.WriteStartElement("ExcelWorkbook");
				xw.WriteAttributeString("xmlns", "urn:schemas-microsoft-com:office:excel");
				xw.WriteStartElement("WindowHeight");
					xw.WriteString("15465");
				xw.WriteEndElement();
				xw.WriteStartElement("WindowWidth");
					xw.WriteString("23820");
				xw.WriteEndElement();
				xw.WriteStartElement("WindowTopX");
					xw.WriteString("120");
				xw.WriteEndElement();
				xw.WriteStartElement("WindowTopY");
					xw.WriteString("75");
				xw.WriteEndElement();
				xw.WriteStartElement("ProtectStructure");
					xw.WriteString("False");
				xw.WriteEndElement();
				xw.WriteStartElement("ProtectWindows");
					xw.WriteString("False");
				xw.WriteEndElement();
			xw.WriteEndElement();

			xw.WriteStartElement("Styles");
				xw.WriteStartElement("Style");
					xw.WriteAttributeString("ss:ID", "Default");
					xw.WriteAttributeString("ss:Name", "Normal");
					xw.WriteStartElement("Alignment");
						xw.WriteAttributeString("ss:Vertical", "Bottom");
					xw.WriteEndElement();
					xw.WriteStartElement("Borders");
					xw.WriteEndElement();
					xw.WriteStartElement("Font");
					xw.WriteEndElement();
					xw.WriteStartElement("Interior");
					xw.WriteEndElement();
					xw.WriteStartElement("NumberFormat");
					xw.WriteEndElement();
					xw.WriteStartElement("Protection");
					xw.WriteEndElement();
				xw.WriteEndElement();
				xw.WriteStartElement("Style");
					xw.WriteAttributeString("ss:ID", "s21");
					xw.WriteStartElement("NumberFormat");
						xw.WriteAttributeString("ss:Format", "General Date");
					xw.WriteEndElement();
				xw.WriteEndElement();
			xw.WriteEndElement();

			xw.WriteStartElement("Worksheet");
				xw.WriteAttributeString("ss:Name", sModuleName);
			xw.WriteStartElement("Table");
				xw.WriteAttributeString("ss:ExpandedColumnCount", tbl.Columns.Count.ToString());
				xw.WriteAttributeString("ss:FullColumns"        , tbl.Columns.Count.ToString());
				// 11/03/2006 Paul.  Add one row for the header. 
				xw.WriteAttributeString("ss:ExpandedRowCount"   , (nEndRecord - nStartRecord + 1).ToString());

			xw.WriteStartElement("Row");
			// 09/23/2015 Paul.  Only export specified fields.  This should get rid of the ID field. 
			for ( int nFieldIndex = 0; nFieldIndex < arrValidatedFields.Count; nFieldIndex++ )
			{
				string sField = arrValidatedFields[nFieldIndex];
				DataColumn col = tbl.Columns[sField];
				xw.WriteStartElement("Cell");
				xw.WriteStartElement("Data");
				xw.WriteAttributeString("ss:Type", "String");
				xw.WriteString(col.ColumnName.ToLower());
				xw.WriteEndElement();
				xw.WriteEndElement();
			}
			xw.WriteEndElement();
			for ( int i = nStartRecord; i < nEndRecord; i++ )
			{
				xw.WriteStartElement("Row");
				DataRowView row = vw[i];
				// 09/23/2015 Paul.  Only export specified fields.  This should get rid of the ID field. 
				for ( int nFieldIndex = 0; nFieldIndex < arrValidatedFields.Count; nFieldIndex++ )
				{
					string sField = arrValidatedFields[nFieldIndex];
					DataColumn col = tbl.Columns[sField];
					xw.WriteStartElement("Cell");
					// 11/03/2006 Paul.  The style must be set in order for a date to be displayed properly. 
					if ( col.DataType.FullName == "System.DateTime" && row[sField] != DBNull.Value )
						xw.WriteAttributeString("ss:StyleID", "s21");
					xw.WriteStartElement("Data");
					if ( row[sField] != DBNull.Value )
					{
						switch ( col.DataType.FullName )
						{
							case "System.Boolean" :
								xw.WriteAttributeString("ss:Type", "String");
								xw.WriteString(Sql.ToBoolean (row[sField]) ? "1" : "0");
								break;
							case "System.Single"  :
								xw.WriteAttributeString("ss:Type", "Number");
								xw.WriteString(Sql.ToDouble  (row[sField]).ToString() );
								break;
							case "System.Double"  :
								xw.WriteAttributeString("ss:Type", "Number");
								xw.WriteString(Sql.ToDouble  (row[sField]).ToString() );
								break;
							case "System.Int16"   :
								xw.WriteAttributeString("ss:Type", "Number");
								xw.WriteString(Sql.ToInteger (row[sField]).ToString() );
								break;
							case "System.Int32"   :
								xw.WriteAttributeString("ss:Type", "Number");
								xw.WriteString(Sql.ToInteger (row[sField]).ToString() );
								break;
							case "System.Int64"   :
								xw.WriteAttributeString("ss:Type", "Number");
								xw.WriteString(Sql.ToLong    (row[sField]).ToString() );
								break;
							case "System.Decimal" :
								xw.WriteAttributeString("ss:Type", "Number");
								xw.WriteString(Sql.ToDecimal (row[sField]).ToString() );
								break;
							case "System.DateTime":
								xw.WriteAttributeString("ss:Type", "DateTime");
								xw.WriteString(Sql.ToDateTime(row[sField]).ToUniversalTime().ToString("s"));
								break;
							case "System.Guid"    :
								xw.WriteAttributeString("ss:Type", "String");
								xw.WriteString(Sql.ToGuid    (row[sField]).ToString().ToUpper());
								break;
							case "System.String"  :
							{
								// 09/08/2020 Paul.  Some customers want exported lists to be translated. 
								string sValue = TranslateExportedvalue(dictTranslatedList, L10n, sField, row);
								xw.WriteAttributeString("ss:Type", "String");
								xw.WriteString(sValue);
								break;
							}
							case "System.Byte[]"  :
							{
								xw.WriteAttributeString("ss:Type", "String");
								byte[] buffer = Sql.ToByteArray((System.Array) row[sField]);
								xw.WriteBase64(buffer, 0, buffer.Length);
								break;
							}
							default:
								//	throw(new Exception("Unsupported field type: " + rdr.GetFieldType(nColumn).FullName));
								// 11/03/2006 Paul.  We need to write the type even for empty cells. 
								xw.WriteAttributeString("ss:Type", "String");
								break;
						}
					}
					else
					{
						// 11/03/2006 Paul.  We need to write the type even for empty cells. 
						xw.WriteAttributeString("ss:Type", "String");
					}
					xw.WriteEndElement();
					xw.WriteEndElement();
				}
				xw.WriteEndElement();
			}
			xw.WriteEndElement();  // Table
			xw.WriteStartElement("WorksheetOptions");
				xw.WriteAttributeString("xmlns", "urn:schemas-microsoft-com:office:excel");
				xw.WriteStartElement("Selected");
				xw.WriteEndElement();
				xw.WriteStartElement("ProtectObjects");
					xw.WriteString("False");
				xw.WriteEndElement();
				xw.WriteStartElement("ProtectScenarios");
					xw.WriteString("False");
				xw.WriteEndElement();
			xw.WriteEndElement();  // WorksheetOptions
			xw.WriteEndElement();  // Worksheet
			xw.WriteEndElement();  // Workbook
			xw.WriteEndDocument();
			xw.Flush();
		}

		// 12/23/2015 Paul.  Public access to make it easier to export Survey Results. 
		public static void ExportXml(Stream stm, DataView vw, string sModuleName, int nStartRecord, int nEndRecord)
		{
			// 09/08/2020 Paul.  Some customers want exported lists to be translated. 
			Dictionary<string, string> dictTranslatedList = GetExportTranslatedLists(sModuleName);
			L10N L10n = HttpContext.Current.Items["L10n"] as L10N;
			if ( L10n == null )
			{
				L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			}
			
			// 09/23/2015 Paul.  Only export specified fields.  This should get rid of the ID field. 
			UniqueStringCollection arrExportFields = new UniqueStringCollection();
			SplendidDynamic.GridColumns(sModuleName + ".Export", arrExportFields, null);
			DataTable tbl = vw.Table;
			UniqueStringCollection arrValidatedFields = new UniqueStringCollection();
			foreach ( string sField in arrExportFields )
			{
				// 02/26/2018 Paul.  There is a special case where we have a custom field module lookup. 
				if ( sField.Contains(" AS ") )
				{
					string sSubQueryField = sField.Substring(sField.LastIndexOf(" AS ") + 4);
					if ( tbl.Columns.Contains(sSubQueryField) )
						arrValidatedFields.Add(sSubQueryField);
				}
				else if ( tbl.Columns.Contains(sField) )
					arrValidatedFields.Add(sField);
			}
			// 09/23/2015 Paul.  If no fields specified, then use all fields. 
			if ( arrValidatedFields.Count == 0 )
			{
				foreach ( DataColumn col in tbl.Columns )
				{
					arrValidatedFields.Add(col.ColumnName);
				}
			}

			XmlTextWriter xw = new XmlTextWriter(stm, Encoding.UTF8);
			xw.Formatting  = Formatting.Indented;
			xw.IndentChar  = ControlChars.Tab;
			xw.Indentation = 1;
			xw.WriteStartDocument();
			xw.WriteStartElement("splendidcrm");

			for ( int i = nStartRecord; i < nEndRecord; i++ )
			{
				xw.WriteStartElement(sModuleName);
				DataRowView row = vw[i];
				// 09/23/2015 Paul.  Only export specified fields.  This should get rid of the ID field. 
				for ( int nFieldIndex = 0; nFieldIndex < arrValidatedFields.Count; nFieldIndex++ )
				{
					string sField = arrValidatedFields[nFieldIndex];
					DataColumn col = tbl.Columns[sField];
					xw.WriteStartElement(col.ColumnName.ToLower());
					if ( row[sField] != DBNull.Value )
					{
						switch ( col.DataType.FullName )
						{
							case "System.Boolean" :  xw.WriteString(Sql.ToBoolean (row[sField]) ? "1" : "0");  break;
							case "System.Single"  :  xw.WriteString(Sql.ToDouble  (row[sField]).ToString() );  break;
							case "System.Double"  :  xw.WriteString(Sql.ToDouble  (row[sField]).ToString() );  break;
							case "System.Int16"   :  xw.WriteString(Sql.ToInteger (row[sField]).ToString() );  break;
							case "System.Int32"   :  xw.WriteString(Sql.ToInteger (row[sField]).ToString() );  break;
							case "System.Int64"   :  xw.WriteString(Sql.ToLong    (row[sField]).ToString() );  break;
							case "System.Decimal" :  xw.WriteString(Sql.ToDecimal (row[sField]).ToString() );  break;
							case "System.DateTime":  xw.WriteString(Sql.ToDateTime(row[sField]).ToUniversalTime().ToString(CalendarControl.SqlDateTimeFormat));  break;
							case "System.Guid"    :  xw.WriteString(Sql.ToGuid    (row[sField]).ToString().ToUpper());  break;
							case "System.String"  :
							{
								// 09/08/2020 Paul.  Some customers want exported lists to be translated. 
								string sValue = TranslateExportedvalue(dictTranslatedList, L10n, sField, row);
								xw.WriteString(sValue);
								break;
							}
							case "System.Byte[]"  :
							{
								byte[] buffer = Sql.ToByteArray((System.Array) row[sField]);
								xw.WriteBase64(buffer, 0, buffer.Length);
								break;
							}
							//default:
							//	throw(new Exception("Unsupported field type: " + rdr.GetFieldType(nColumn).FullName));
						}
					}
					xw.WriteEndElement();
				}
				xw.WriteEndElement();
			}
			xw.WriteEndElement();
			xw.WriteEndDocument();
			xw.Flush();
		}

		// 12/23/2015 Paul.  Public access to make it easier to export Survey Results. 
		public static void ExportDelimited(Stream stm, DataView vw, string sModuleName, int nStartRecord, int nEndRecord, char chDelimiter)
		{
			// 09/08/2020 Paul.  Some customers want exported lists to be translated. 
			Dictionary<string, string> dictTranslatedList = GetExportTranslatedLists(sModuleName);
			L10N L10n = HttpContext.Current.Items["L10n"] as L10N;
			if ( L10n == null )
			{
				L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			}
			
			// 09/23/2015 Paul.  Only export specified fields.  This should get rid of the ID field. 
			UniqueStringCollection arrExportFields = new UniqueStringCollection();
			SplendidDynamic.GridColumns(sModuleName + ".Export", arrExportFields, null);
			DataTable tbl = vw.Table;
			UniqueStringCollection arrValidatedFields = new UniqueStringCollection();
			foreach ( string sField in arrExportFields )
			{
				// 02/26/2018 Paul.  There is a special case where we have a custom field module lookup. 
				if ( sField.Contains(" AS ") )
				{
					string sSubQueryField = sField.Substring(sField.LastIndexOf(" AS ") + 4);
					if ( tbl.Columns.Contains(sSubQueryField) )
						arrValidatedFields.Add(sSubQueryField);
				}
				else if ( tbl.Columns.Contains(sField) )
					arrValidatedFields.Add(sField);
			}
			// 09/23/2015 Paul.  If no fields specified, then use all fields. 
			if ( arrValidatedFields.Count == 0 )
			{
				foreach ( DataColumn col in tbl.Columns )
				{
					arrValidatedFields.Add(col.ColumnName);
				}
			}

			StreamWriter wt = new StreamWriter(stm);
			// 09/23/2015 Paul.  Only export specified fields.  This should get rid of the ID field. 
			for ( int nFieldIndex = 0; nFieldIndex < arrValidatedFields.Count; nFieldIndex++ )
			{
				string sField = arrValidatedFields[nFieldIndex];
				if ( nFieldIndex > 0 )
					wt.Write(chDelimiter);
				DataColumn col = tbl.Columns[sField];
				wt.Write(col.ColumnName.ToLower());
			}
			wt.WriteLine("");

			for ( int i = nStartRecord; i < nEndRecord; i++ )
			{
				DataRowView row = vw[i];
				// 09/23/2015 Paul.  Only export specified fields.  This should get rid of the ID field. 
				for ( int nFieldIndex = 0; nFieldIndex < arrValidatedFields.Count; nFieldIndex++ )
				{
					string sField = arrValidatedFields[nFieldIndex];
					if ( nFieldIndex > 0 )
						wt.Write(chDelimiter);
					DataColumn col = tbl.Columns[sField];
					if ( row[sField] != DBNull.Value )
					{
						string sValue = String.Empty;
						switch ( col.DataType.FullName )
						{
							case "System.Boolean" :  sValue = Sql.ToBoolean (row[sField]) ? "1" : "0";  break;
							case "System.Single"  :  sValue = Sql.ToDouble  (row[sField]).ToString() ;  break;
							case "System.Double"  :  sValue = Sql.ToDouble  (row[sField]).ToString() ;  break;
							case "System.Int16"   :  sValue = Sql.ToInteger (row[sField]).ToString() ;  break;
							case "System.Int32"   :  sValue = Sql.ToInteger (row[sField]).ToString() ;  break;
							case "System.Int64"   :  sValue = Sql.ToLong    (row[sField]).ToString() ;  break;
							case "System.Decimal" :  sValue = Sql.ToDecimal (row[sField]).ToString() ;  break;
							case "System.DateTime":  sValue = Sql.ToDateTime(row[sField]).ToUniversalTime().ToString(CalendarControl.SqlDateTimeFormat);  break;
							case "System.Guid"    :  sValue = Sql.ToGuid    (row[sField]).ToString().ToUpper();  break;
							case "System.String"  :
							{
								// 09/08/2020 Paul.  Some customers want exported lists to be translated. 
								sValue = TranslateExportedvalue(dictTranslatedList, L10n, sField, row);
								break;
							}
							case "System.Byte[]"  :
							{
								byte[] buffer = Sql.ToByteArray((System.Array) row[0]);
								sValue = Convert.ToBase64String(buffer, 0, buffer.Length);
								break;
							}
							//default:
							//	throw(new Exception("Unsupported field type: " + rdr.GetFieldType(sField).FullName));
						}
						if( sValue.IndexOf(chDelimiter) >= 0 || sValue.IndexOf('\"') >= 0 )
							sValue = "\"" + sValue.Replace("\"", "\"\"") + "\"";
						wt.Write(sValue);
					}
				}
				wt.WriteLine("");
			}
			wt.Flush();
		}

		// 12/23/2015 Paul.  The survey module needs to export a raw table with untranslated headers. 
		public static void ExportExcelOpenXML(Stream stmResponse, DataTable dt, string[] arrHeaders, string sTitle, string sSubTitle1, string sSubTitle2)
		{
			// http://msdn.microsoft.com/en-us/library/office/ff478153.aspx
			// http://msdn.microsoft.com/en-us/library/office/cc850837
			using ( MemoryStream stm = new MemoryStream() )
			{
				using ( SpreadsheetDocument spreadsheetDocument = SpreadsheetDocument.Create(stm, SpreadsheetDocumentType.Workbook) )
				{
					WorkbookPart workbookPart = spreadsheetDocument.AddWorkbookPart();
					workbookPart.Workbook = new Workbook();
					WorksheetPart worksheetPart = workbookPart.AddNewPart<WorksheetPart>();
					worksheetPart.Worksheet = new Worksheet(new SheetData());
					worksheetPart.Worksheet.Save();
					
					// http://www.codeproject.com/Articles/371203/Creating-basic-Excel-workbook-with-Open-XML
					WorkbookStylesPart workbookStylesPart = workbookPart.AddNewPart<WorkbookStylesPart>();
					workbookStylesPart.Stylesheet = OpenXML_CreateStylesheet();
					workbookStylesPart.Stylesheet.Save();
					
					Sheets sheets = spreadsheetDocument.WorkbookPart.Workbook.AppendChild<Sheets>(new Sheets());
					Sheet sheet = new Sheet() { Id = spreadsheetDocument.WorkbookPart.GetIdOfPart(worksheetPart), SheetId = 1, Name = "Results" };
					sheets.Append(sheet);
					workbookPart.Workbook.Save();
					
					SharedStringTablePart shareStringPart = spreadsheetDocument.WorkbookPart.AddNewPart<SharedStringTablePart>();
				
					Worksheet worksheet = worksheetPart.Worksheet;
					SheetData sheetData = worksheet.GetFirstChild<SheetData>();
					UInt32Value numberStyleId = OpenXML_CreateCellFormat(workbookStylesPart.Stylesheet, null, null, UInt32Value.FromUInt32( 3));
					UInt32Value doubleStyleId = OpenXML_CreateCellFormat(workbookStylesPart.Stylesheet, null, null, UInt32Value.FromUInt32( 4));
					UInt32Value dateStyleId   = OpenXML_CreateCellFormat(workbookStylesPart.Stylesheet, null, null, UInt32Value.FromUInt32(14));
					
					int rowIndex = 1;
					Dictionary<string, int> dictStringToInt = new Dictionary<string, int>();
					DocumentFormat.OpenXml.Spreadsheet.Row  xRow = null;
					DocumentFormat.OpenXml.Spreadsheet.Cell cell = null;
					if ( !Sql.IsEmptyString(sTitle) )
					{
						xRow = new DocumentFormat.OpenXml.Spreadsheet.Row();
						xRow.RowIndex = (uint) rowIndex;
						sheetData.Append(xRow);
						cell = OpenXML_CreateText(1, rowIndex, shareStringPart, sTitle, dictStringToInt);
						xRow.AppendChild(cell);
						rowIndex++;
					}
					if ( !Sql.IsEmptyString(sSubTitle1) )
					{
						xRow = new DocumentFormat.OpenXml.Spreadsheet.Row();
						xRow.RowIndex = (uint) rowIndex;
						sheetData.Append(xRow);
						cell = OpenXML_CreateText(1, rowIndex, shareStringPart, sSubTitle1, dictStringToInt);
						xRow.AppendChild(cell);
						rowIndex++;
					}
					if ( !Sql.IsEmptyString(sSubTitle2) )
					{
						xRow = new DocumentFormat.OpenXml.Spreadsheet.Row();
						xRow.RowIndex = (uint) rowIndex;
						sheetData.Append(xRow);
						cell = OpenXML_CreateText(1, rowIndex, shareStringPart, sSubTitle2, dictStringToInt);
						xRow.AppendChild(cell);
						rowIndex++;
					}
					
					xRow = new DocumentFormat.OpenXml.Spreadsheet.Row();
					xRow.RowIndex = (uint) rowIndex;
					sheetData.Append(xRow);
					for ( int nFieldIndex = 0; nFieldIndex < arrHeaders.Length; nFieldIndex++ )
					{
						string sHEADER_TEXT = arrHeaders[nFieldIndex];
						cell = OpenXML_CreateText(nFieldIndex + 1, rowIndex, shareStringPart, sHEADER_TEXT, dictStringToInt);
						xRow.AppendChild(cell);
					}
					rowIndex++;
					
					// 12/02/2013 Paul.  Add a blank string to the shared array so that there is at least one. 
					OpenXML_InsertSharedStringItem(shareStringPart, String.Empty, dictStringToInt);
					for ( int i = 0; i < dt.Rows.Count; i++, rowIndex++ )
					{
						xRow = new DocumentFormat.OpenXml.Spreadsheet.Row();
						xRow.RowIndex = (uint) rowIndex;
						sheetData.Append(xRow);
						DataRow row = dt.Rows[i];
						// 09/23/2015 Paul.  Only export specified fields.  This should get rid of the ID field. 
						for ( int nFieldIndex = 0; nFieldIndex < arrHeaders.Length; nFieldIndex++ )
						{
							DataColumn col = dt.Columns[nFieldIndex];
							if ( row[nFieldIndex] != DBNull.Value )
							{
								switch ( col.DataType.FullName )
								{
									case "System.Boolean" :
										//xw.WriteAttributeString("ss:Type", "String");
										cell = OpenXML_CreateBoolean(nFieldIndex + 1, rowIndex, Sql.ToBoolean (row[nFieldIndex]) ? "1" : "0");
										xRow.AppendChild(cell);
										break;
									case "System.Single"  :
										//xw.WriteAttributeString("ss:Type", "Number");
										cell = OpenXML_CreateNumber(nFieldIndex + 1, rowIndex, Sql.ToDouble  (row[nFieldIndex]).ToString(), doubleStyleId);
										xRow.AppendChild(cell);
										break;
									case "System.Double"  :
										//xw.WriteAttributeString("ss:Type", "Number");
										cell = OpenXML_CreateNumber(nFieldIndex + 1, rowIndex, Sql.ToDouble  (row[nFieldIndex]).ToString(), doubleStyleId);
										xRow.AppendChild(cell);
										break;
									case "System.Int16"   :
										//xw.WriteAttributeString("ss:Type", "Number");
										cell = OpenXML_CreateNumber(nFieldIndex + 1, rowIndex, Sql.ToInteger (row[nFieldIndex]).ToString(), numberStyleId);
										xRow.AppendChild(cell);
										break;
									case "System.Int32"   :
										//xw.WriteAttributeString("ss:Type", "Number");
										cell = OpenXML_CreateNumber(nFieldIndex + 1, rowIndex, Sql.ToInteger (row[nFieldIndex]).ToString(), numberStyleId);
										xRow.AppendChild(cell);
										break;
									case "System.Int64"   :
										//xw.WriteAttributeString("ss:Type", "Number");
										cell = OpenXML_CreateNumber(nFieldIndex + 1, rowIndex, Sql.ToLong    (row[nFieldIndex]).ToString(), numberStyleId);
										xRow.AppendChild(cell);
										break;
									case "System.Decimal" :
										//xw.WriteAttributeString("ss:Type", "Number");
										cell = OpenXML_CreateNumber(nFieldIndex + 1, rowIndex, Sql.ToDecimal (row[nFieldIndex]).ToString(), doubleStyleId);
										xRow.AppendChild(cell);
										break;
									case "System.DateTime":
										//xw.WriteAttributeString("ss:Type", "DateTime");
										cell = OpenXML_CreateDate(nFieldIndex + 1, rowIndex, Sql.ToDateTime(row[nFieldIndex]), dateStyleId);
										xRow.AppendChild(cell);
										break;
									case "System.Guid"    :
										//xw.WriteAttributeString("ss:Type", "String");
										// 11/29/2013 Paul.  Use dictionary to increase performance. 
										cell = OpenXML_CreateText(nFieldIndex + 1, rowIndex, shareStringPart, Sql.ToGuid    (row[nFieldIndex]).ToString().ToUpper(), dictStringToInt);
										xRow.AppendChild(cell);
										break;
									case "System.String"  :
										//xw.WriteAttributeString("ss:Type", "String");
										// 11/29/2013 Paul.  Catch and ignore bad data exceptions. This can happen with imported unicode data. 
										// '', hexadecimal value 0x13, is an invalid character.
										try
										{
											// 11/29/2013 Paul.  Use dictionary to increase performance. 
											cell = OpenXML_CreateText(nFieldIndex + 1, rowIndex, shareStringPart, Sql.ToString  (row[nFieldIndex]), dictStringToInt);
										}
										catch
										{
											// 11/29/2013 Paul.  After exception, the item still remains in the list and causes future save operations to fail. 
											// 11/29/2013 Paul.  Use dictionary to increase performance. 
											OpenXML_RemoveText(shareStringPart, Sql.ToString(row[nFieldIndex]), dictStringToInt);
											cell = OpenXML_CreateText(nFieldIndex + 1, rowIndex, shareStringPart, String.Empty, dictStringToInt);
										}
										xRow.AppendChild(cell);
										break;
									case "System.Byte[]"  :
									{
										//xw.WriteAttributeString("ss:Type", "String");
										//byte[] buffer = Sql.ToByteArray((System.Array) row[nFieldIndex]);
										//xw.WriteBase64(buffer, 0, buffer.Length);
										// 11/29/2013 Paul.  Use dictionary to increase performance. 
										cell = OpenXML_CreateText(nFieldIndex + 1, rowIndex, shareStringPart, String.Empty, dictStringToInt);
										xRow.AppendChild(cell);
										break;
									}
									default:
										//	throw(new Exception("Unsupported field type: " + rdr.GetFieldType(nColumn).FullName));
										// 08/25/2012 Paul.  We need to write the type even for empty cells. 
										//xw.WriteAttributeString("ss:Type", "String");
										// 11/29/2013 Paul.  Use dictionary to increase performance. 
										cell = OpenXML_CreateText(nFieldIndex + 1, rowIndex, shareStringPart, String.Empty, dictStringToInt);
										xRow.AppendChild(cell);
										break;
								}
							}
							else
							{
								// 08/25/2012 Paul.  We need to write the type even for empty cells. 
								// 11/29/2013 Paul.  Use dictionary to increase performance. 
								cell = OpenXML_CreateText(nFieldIndex + 1, rowIndex, shareStringPart, String.Empty, dictStringToInt);
								xRow.AppendChild(cell);
							}
						}
					}
					workbookPart.Workbook.Save();
					spreadsheetDocument.Close();
				}
				stm.WriteTo(stmResponse);
			}
		}
	}
}

