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
using System.Data.Odbc;
using System.Data.OleDb;
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
	/// Summary description for Excel2007Reader.
	/// </summary>
	public class Excel2007Reader
	{
		public static DateTime FromOADate(string sValue)
		{
			DateTime dt = new DateTime(1899, 12, 30);
			dt = dt.AddDays(Int32.Parse(sValue));
			return dt;
		}

		public static string GetCellValue(SharedStringTablePart stringTablePart, Stylesheet style, Cell cell, ref string sFormat)
		{
			string sValue = String.Empty;
			if ( cell.CellValue != null )
				sValue = cell.CellValue.InnerXml;
			if ( cell.DataType != null )
			{
				if ( cell.DataType.Value == CellValues.SharedString )
					return stringTablePart.SharedStringTable.ChildElements[Int32.Parse(sValue)].InnerText;
				// 05/23/2020 Paul.  The spreadsheet that SplendidCRM creates uses InlineString. 
				else if ( cell.DataType.Value == CellValues.InlineString )
					return cell.InnerText;
				else if ( cell.DataType.Value == CellValues.Date )
				{
					return FromOADate(sValue).ToString();
				}
			}
			else if ( cell.StyleIndex != null )
			{
				int nStyleIndex = (int) cell.StyleIndex.Value;
				// 05/10/2011 Paul.  Lets get the format for future reference. 
				CellFormat cellXfs = style.CellFormats.ChildElements[nStyleIndex] as CellFormat;
				if ( cellXfs.NumberFormatId != null )
				{
					// http://www.lateral8.com/articles/2010/6/11/openxml-sdk-20-formatting-excel-values.aspx
					switch ( cellXfs.NumberFormatId.Value )
					{
						case  0: sFormat = "General"                 ;  break;
						case  1: sFormat = "0"                       ;  break;
						case  2: sFormat = "0.00"                    ;  break;
						case  3: sFormat = "#,##0"                   ;  break;
						case  4: sFormat = "#,##0.00"                ;  break;
						case  9: sFormat = "0%"                      ;  break;
						case 10: sFormat = "0.00%"                   ;  break;
						case 11: sFormat = "0.00E+00"                ;  break;
						case 12: sFormat = "# ?/?"                   ;  break;
						case 13: sFormat = "# ??/??"                 ;  break;
						case 14: sFormat = "mm-dd-yy"                ;  break;
						case 15: sFormat = "d-mmm-yy"                ;  break;
						case 16: sFormat = "d-mmm"                   ;  break;
						case 17: sFormat = "mmm-yy"                  ;  break;
						case 18: sFormat = "h:mm AM/PM"              ;  break;
						case 19: sFormat = "h:mm:ss AM/PM"           ;  break;
						case 20: sFormat = "h:mm"                    ;  break;
						case 21: sFormat = "h:mm:ss"                 ;  break;
						case 22: sFormat = "m/d/yy h:mm"             ;  break;
						case 37: sFormat = "#,##0 ;(#,##0)"          ;  break;
						case 38: sFormat = "#,##0 ;[Red](#,##0)"     ;  break;
						case 39: sFormat = "#,##0.00;(#,##0.00)"     ;  break;
						case 40: sFormat = "#,##0.00;[Red](#,##0.00)";  break;
						case 45: sFormat = "mm:ss"                   ;  break;
						case 46: sFormat = "[h]:mm:ss"               ;  break;
						case 47: sFormat = "mmss.0"                  ;  break;
						case 48: sFormat = "##0.0E+0"                ;  break;
						case 49: sFormat = "@"                       ;  break;
						default:
						{
							foreach ( NumberingFormat numFmt in style.NumberingFormats.ChildElements )
							{
								if ( numFmt.NumberFormatId.Value == cellXfs.NumberFormatId.Value )
								{
									sFormat = numFmt.FormatCode.Value;
									break;
								}
							}
							break;
						}
					}
					// 09/29/2013 Paul.  It seems the only way to detect a date format is if it contacts a date formatting character. 
					// We must be careful to exclude number fields as they can contain colors. 
					// http://office.microsoft.com/en-us/excel-help/create-a-custom-number-format-HP010342372.aspx
					// http://stackoverflow.com/questions/894805/excel-number-format-what-is-409
					// 09/30/2013 Paul.  We need to do the date conversion outside the switch statement so that standard formats get converted. 
					if ( sFormat.Contains("#") || sFormat.Contains("?") )
					{
					}
					else if ( sFormat.Contains("yy") || sFormat.Contains("m") || sFormat.Contains("h") || sFormat.Contains("s") )
					{
						sValue = FromOADate(sValue).ToString();
					}
				}
			}
			return sValue;
		}

		public static string SplitDimensions(string sCellRef, ref string sColumn, ref int nRow)
		{
			int i = 0;
			while ( i < sCellRef.Length && Char.IsLetter(sCellRef[i]) )
				i++;
			sColumn = sCellRef.Substring(0, i);
			string sRow = sCellRef.Substring(i);
			Int32.TryParse(sRow, out nRow);
			return sColumn;
		}

		public static int GetCellIndex(string sID)
		{
			int nCellIndex = 0;
			if ( sID.Length == 1 )
			{
				nCellIndex = sID[0] - 'A';
			}
			else if ( sID.Length == 2 )
			{
				// 01/04/2015 Paul.  Need to offset the index by 1. 
				nCellIndex  = (sID[0] - 'A' + 1) * 26;
				nCellIndex += (sID[1] - 'A');
			}
			// 01/04/2015 Paul.  Add another level of columns. 
			else if ( sID.Length == 3 )
			{
				nCellIndex  = (sID[0] - 'A' + 1) * 26 * 26;
				nCellIndex  = (sID[1] - 'A' + 1) * 26;
				nCellIndex += (sID[2] - 'A');
			}
			return nCellIndex;
		}

		public static XmlDocument ConvertSpreadsheetToXml(Stream stm, string sRecordName)
		{
			XmlDocument xmlImport = new XmlDocument();
			xmlImport.AppendChild(xmlImport.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
			xmlImport.AppendChild(xmlImport.CreateElement("xml"));
			
			using ( SpreadsheetDocument doc = SpreadsheetDocument.Open(stm, false) )
			{
				WorkbookPart wb = doc.WorkbookPart;
				if ( wb.Workbook.Sheets.HasChildren )
				{
					Sheet sheet = wb.Workbook.Sheets.GetFirstChild<Sheet>();
					if ( sheet != null )
					{
						WorksheetPart part = doc.WorkbookPart.GetPartById(sheet.Id.Value) as WorksheetPart;
						if ( part != null && part.Worksheet != null )
						{
							SharedStringTablePart stringTablePart = doc.WorkbookPart.SharedStringTablePart;
							WorkbookStylesPart style = doc.WorkbookPart.WorkbookStylesPart;
							SheetData data = part.Worksheet.GetFirstChild<SheetData>();
							foreach ( Row rowExcel in data.Elements<Row>() )
							{
								XmlNode xRecord = xmlImport.CreateElement(sRecordName);
								xmlImport.DocumentElement.AppendChild(xRecord);
								
								List<Cell> cells = new List<Cell>();
								foreach ( Cell cell in rowExcel.Elements<Cell>() )
								{
									cells.Add(cell);
								}
								for ( int j = 0, nField = 0; j < cells.Count; j++, nField++ )
								{
									XmlNode xField = xmlImport.CreateElement("ImportField" + nField.ToString("000"));
									xRecord.AppendChild(xField);
									
									Cell cell = cells[j];
									string sColumn = String.Empty;
									int    nRow    = 0;
									SplitDimensions(cell.CellReference, ref sColumn, ref nRow);
									int nCellIndex = GetCellIndex(sColumn);
									// 08/22/2006 Paul.  If there are any missing cells, then add them.
									// 10/01/2013 Paul.  nField + 1 is wrong for XLSX (but correct for an Excel Spreadsheet).  nCellIndex is zero based. 
									while ( nField < nCellIndex )
									{
										nField++;
										xField = xmlImport.CreateElement("ImportField" + nField.ToString("000"));
										xRecord.AppendChild(xField);
									}
									try
									{
										string sFormat = String.Empty;
										xField.InnerText = GetCellValue(stringTablePart, style.Stylesheet, cell, ref sFormat);
									}
									catch(Exception ex)
									{
										// 09/16/2015 Paul.  Change to Debug as it is automatically not included in a release build. 
										Debug.WriteLine(ex.Message);
									}
								}
							}
						}
					}
				}
			}
			return xmlImport;
		}
	}
}

