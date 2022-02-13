using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Collections.ObjectModel;
using System.Runtime.CompilerServices;
using System.Data;
using System.Globalization;
using ExcelDataReader.Core;

namespace ExcelDataReader
{

    /// <summary>
    /// Main class implementation
    /// </summary>
    public class ExcelDataReader
    {
        private Stream m_file = null;
        private XlsHeader m_hdr = null;
        private XlsBiffStream m_stream = null;
        private XlsWorkbookGlobals m_globals = null;
        private List<XlsWorksheet> m_sheets = new List<XlsWorksheet>();
        private DataSet m_workbookData = null;
        private ushort m_version = 0x0600;
        private Encoding m_encoding = Encoding.Default;

        /// <summary>
        /// Default constructor
        /// </summary>
        /// <param name="file">Stream with source data</param>
        public ExcelDataReader(Stream file)
        {
            m_file = file; // new BufferedStream(file);
            m_hdr = XlsHeader.ReadHeader(m_file);
            XlsRootDirectory dir = new XlsRootDirectory(m_hdr);
            XlsDirectoryEntry workbookEntry = dir.FindEntry("Workbook");
            if (workbookEntry == null)
                workbookEntry = dir.FindEntry("Book");
            if (workbookEntry == null)
                throw new FileNotFoundException("Oops! Neither stream 'Workbook' nor 'Book' was found in file");
            if (workbookEntry.EntryType != STGTY.STGTY_STREAM)
                throw new FormatException("Oops! Workbook directory entry is not a Stream");
            m_stream = new XlsBiffStream(m_hdr, workbookEntry.StreamFirstSector);
            ReadWorkbookGlobals();
            GC.Collect();
            m_workbookData = new DataSet();
            for (int i = 0; i < m_sheets.Count; i++)
                if (ReadWorksheet(m_sheets[i]))
                    m_workbookData.Tables.Add(m_sheets[i].Data);
            m_globals.SST = null;
            m_globals = null;
            m_sheets = null;
            m_stream = null;
            m_hdr = null;
            GC.Collect();
        }

        /// <summary>
        /// DataSet with workbook data, Tables represent Sheets
        /// </summary>
        public DataSet WorkbookData
        {
            get { return m_workbookData; }
        }

        /// <summary>
        /// Private method, reads Workbook Globals section
        /// </summary>
        private void ReadWorkbookGlobals()
        {
            m_globals = new XlsWorkbookGlobals();
            m_stream.Seek(0, SeekOrigin.Begin);
            XlsBiffRecord rec = m_stream.Read();
            XlsBiffBOF bof = rec as XlsBiffBOF;
            if (bof == null || bof.Type != BIFFTYPE.WorkbookGlobals)
                throw new InvalidDataException("Oops! Stream has invalid data");
            m_version = bof.Version;
            m_encoding = Encoding.Unicode;
            bool isV8 = (m_version >= 0x600);
            bool sst = false;
            while ((rec = m_stream.Read()) != null)
            {
                switch (rec.ID)
                { 
                    case BIFFRECORDTYPE.INTERFACEHDR:
                        m_globals.InterfaceHdr = (XlsBiffInterfaceHdr)rec;
                        break;
                    case BIFFRECORDTYPE.BOUNDSHEET:
                        XlsBiffBoundSheet sheet = (XlsBiffBoundSheet)rec;
                        //if (sheet.Type != XlsBiffBoundSheet.SheetType.Worksheet) break;
						// 05/01/2008 Paul.  Allow load of hidden worksheets. 
						// http://www.codeproject.com/KB/office/Excel_DataReader.aspx?display=PrintAll&fid=320417&df=90&mpp=25&noise=3&sort=Position&view=Quick&fr=26&select=2513532#xx0xx
						if (!(sheet.Type == XlsBiffBoundSheet.SheetType.Worksheet || sheet.Type == XlsBiffBoundSheet.SheetType.MacroSheet)) break;
                        sheet.IsV8 = isV8;
                        sheet.UseEncoding = m_encoding;
                        m_sheets.Add(new XlsWorksheet(m_globals.Sheets.Count, sheet));
                        m_globals.Sheets.Add(sheet);
                        break;
                    case BIFFRECORDTYPE.MMS:
                        m_globals.MMS = rec;
                        break;
                    case BIFFRECORDTYPE.COUNTRY:
                        m_globals.Country = rec;
                        break;
                    case BIFFRECORDTYPE.CODEPAGE:
                        m_globals.CodePage = (XlsBiffSimpleValueRecord)rec;
                        m_encoding = Encoding.GetEncoding(m_globals.CodePage.Value);
                        break;
                    case BIFFRECORDTYPE.FONT:
                    case BIFFRECORDTYPE.FONT_V34:
                        m_globals.Fonts.Add(rec);
                        break;
                    case BIFFRECORDTYPE.FORMAT:
                    case BIFFRECORDTYPE.FORMAT_V23:
                        m_globals.Formats.Add(rec);
                        break;
                    case BIFFRECORDTYPE.XF:
                    case BIFFRECORDTYPE.XF_V4:
                    case BIFFRECORDTYPE.XF_V3:
                    case BIFFRECORDTYPE.XF_V2:
                        m_globals.ExtendedFormats.Add(rec);
                        break;
                    case BIFFRECORDTYPE.SST:
                        m_globals.SST = (XlsBiffSST)rec;
                        sst = true;
                        break;
                    case BIFFRECORDTYPE.CONTINUE:
                        if (!sst) break;
                        XlsBiffContinue contSST = (XlsBiffContinue)rec;
                        m_globals.SST.Append(contSST);
                        break;
                    case BIFFRECORDTYPE.EXTSST:
                        m_globals.ExtSST = rec;
                        sst = false;
                        break;
                    case BIFFRECORDTYPE.EOF:
                        if (m_globals.SST != null)
                            m_globals.SST.ReadStrings();
                        return;
                    default:
                        continue;
                }
            }
        }

        /// <summary>
        /// private method, reads sheet data
        /// </summary>
        /// <param name="sheet">Sheet object, whose data to read</param>
        /// <returns>True if sheet was read successfully, otherwise False</returns>
        private bool ReadWorksheet(XlsWorksheet sheet)
        {
            m_stream.Seek((int)sheet.DataOffset, SeekOrigin.Begin);
            XlsBiffBOF bof = m_stream.Read() as XlsBiffBOF;
            if (bof == null || bof.Type != BIFFTYPE.Worksheet)
                return false;
            XlsBiffIndex idx = m_stream.Read() as XlsBiffIndex;
            bool isV8 = (m_version >= 0x600);
            if (idx != null)
            {
                idx.IsV8 = isV8;
                DataTable dt = new DataTable(sheet.Name);

                XlsBiffRecord trec;
                XlsBiffDimensions dims = null;
                do
                {
                    trec = m_stream.Read();
                    if (trec.ID == BIFFRECORDTYPE.DIMENSIONS)
                    {
                        dims = (XlsBiffDimensions)trec;
                        break;
                    }
                }
                while (trec.ID != BIFFRECORDTYPE.ROW);
                int maxCol = 256;
                if (dims != null)
                {
                    dims.IsV8 = isV8;
                    maxCol = dims.LastColumn;
                    sheet.Dimensions = dims;
                }
                for (int i = 0; i < maxCol; i++)
                    dt.Columns.Add("Column" + (i + 1).ToString(), typeof(string));
                sheet.Data = dt;
                uint maxRow = idx.LastExistingRow;
                if (idx.LastExistingRow <= idx.FirstExistingRow)
                    return true;
                dt.BeginLoadData();
                for (int i = 0; i <= maxRow; i++)
                    dt.Rows.Add(dt.NewRow());
                uint[] dbCellAddrs = idx.DbCellAddresses;
                for (int i = 0; i < dbCellAddrs.Length; i++)
                {
                    XlsBiffDbCell dbCell = (XlsBiffDbCell)m_stream.ReadAt((int)dbCellAddrs[i]);
                    XlsBiffRow row = null;
                    int offs = (int)dbCell.RowAddress;
                    do
                    {
                        row = m_stream.ReadAt(offs) as XlsBiffRow;
                        if (row == null) break;
                        offs += row.Size;
                    }
                    while (row != null);
                    while (true)
                    {
                        XlsBiffRecord rec = m_stream.ReadAt(offs);
                        offs += rec.Size;
                        if (rec is XlsBiffDbCell) break;
                        if (rec is XlsBiffEOF) break;
                        XlsBiffBlankCell cell = rec as XlsBiffBlankCell;
                        if (cell == null)
                        {
                            continue;
                        }
                        if (cell.ColumnIndex >= maxCol) continue;
                        if (cell.RowIndex > maxRow) continue;
                        switch (cell.ID)
                        {
                            case BIFFRECORDTYPE.INTEGER:
                            case BIFFRECORDTYPE.INTEGER_OLD:
                                dt.Rows[cell.RowIndex][cell.ColumnIndex] = ((XlsBiffIntegerCell)cell).Value.ToString();
                                break;
                            case BIFFRECORDTYPE.NUMBER:
                            case BIFFRECORDTYPE.NUMBER_OLD:
                                dt.Rows[cell.RowIndex][cell.ColumnIndex] = FormatNumber(((XlsBiffNumberCell)cell).Value);
                                break;
                            case BIFFRECORDTYPE.LABEL:
                            case BIFFRECORDTYPE.LABEL_OLD:
                            case BIFFRECORDTYPE.RSTRING:
                                dt.Rows[cell.RowIndex][cell.ColumnIndex] = ((XlsBiffLabelCell)cell).Value;
                                break;
                            case BIFFRECORDTYPE.LABELSST:
                                {
                                    string tmp = m_globals.SST.GetString(((XlsBiffLabelSSTCell)cell).SSTIndex);
                                    dt.Rows[cell.RowIndex][cell.ColumnIndex] = tmp;
                                }
                                break;
                            case BIFFRECORDTYPE.RK:
                                dt.Rows[cell.RowIndex][cell.ColumnIndex] = FormatNumber(((XlsBiffRKCell)cell).Value);
                                break;
                            case BIFFRECORDTYPE.MULRK:
                                for (ushort j = cell.ColumnIndex; j <= ((XlsBiffMulRKCell)cell).LastColumnIndex; j++)
                                    dt.Rows[cell.RowIndex][j] = FormatNumber(((XlsBiffMulRKCell)cell).GetValue(j));
                                break;
                            case BIFFRECORDTYPE.BLANK:
                            case BIFFRECORDTYPE.BLANK_OLD:
                            case BIFFRECORDTYPE.MULBLANK:
                                // Skip blank cells
                                break;
                            case BIFFRECORDTYPE.FORMULA:
                            case BIFFRECORDTYPE.FORMULA_OLD:
                                //((XlsBiffFormulaCell)cell).UseEncoding = m_encoding; 
								// 05/01/2008 Paul.  Use calculated values of a formula. 
								// http://www.codeproject.com/KB/office/Excel_DataReader.aspx?display=PrintAll&fid=320417&df=90&mpp=25&noise=3&sort=Position&view=Quick&fr=76&select=2513532#xx2513532xx
								((XlsBiffFormulaCell)cell).UseEncoding = System.Text.Encoding.Default;
                                object val = ((XlsBiffFormulaCell)cell).Value;
                                if (val == null)
                                    val = string.Empty;
                                else if (val is FORMULAERROR)
                                    val = "#" + ((FORMULAERROR)val).ToString();
                                else if (val is double)
                                    val = FormatNumber((double)val);
                                dt.Rows[cell.RowIndex][cell.ColumnIndex] = val.ToString();
                                break;
							// 05/01/2008 Paul..  Fix problem with boolean values. 
							// http://www.codeproject.com/KB/office/Excel_DataReader.aspx?display=PrintAll&fid=320417&df=90&mpp=25&noise=3&sort=Position&view=Quick&fr=51&select=2513532#xx0xx
							case BIFFRECORDTYPE.BOOLERR:
								dt.Rows[cell.RowIndex][cell.ColumnIndex] = ((XlsBiffBoolErrCell)cell).Value;
								break;
                            default:
                                break;
                        }
                    }
                }
                dt.EndLoadData();
            }
            else
            {
                return false;
            }

            return true;
        }

        private string FormatNumber(double x)
        {
            if (Math.Floor(x) == x)
                return Math.Floor(x).ToString();
            else
				// 05/01/2008 Paul.  Increase rounding to 3. 
                return Math.Round(x, 3).ToString(CultureInfo.InvariantCulture);
        }

    }
}
