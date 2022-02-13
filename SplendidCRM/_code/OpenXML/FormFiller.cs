// http://www.codeproject.com/KB/office/Fill_Mergefields.aspx?msg=3160774
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.IO;
using System.Data;

using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Wordprocessing;
using DocumentFormat.OpenXml;

namespace TRIS.FormFill.Lib
{
    /// <summary>
    /// Helper class for filling in data forms based on Word 2007 documents.
    /// </summary>
    public static class FormFiller
    {
        /// <summary>
        /// Regex used to parse MERGEFIELDs in the provided document.
        /// </summary>
        private static readonly Regex instructionRegEx =
            new Regex(
                        @"^[\s]*MERGEFIELD[\s]+(?<name>[#\w]*){1}               # This retrieves the field's name (Named Capture Group -> name)
                            [\s]*(\\\*[\s]+(?<Format>[\w]*){1})?                # Retrieves field's format flag (Named Capture Group -> Format)
                            [\s]*(\\b[\s]+[""]?(?<PreText>[^\\]*){1})?         # Retrieves text to display before field data (Named Capture Group -> PreText)
                                                                                # Retrieves text to display after field data (Named Capture Group -> PostText)
                            [\s]*(\\f[\s]+[""]?(?<PostText>[^\\]*){1})?",
                        RegexOptions.Compiled | RegexOptions.CultureInvariant | RegexOptions.ExplicitCapture | RegexOptions.IgnoreCase | RegexOptions.IgnorePatternWhitespace | RegexOptions.Singleline);

        /// <summary>
        /// Fills in a .docx file with the provided data.
        /// </summary>
        /// <param name="filename">Path to the template that must be used.</param>
        /// <param name="dataset">Dataset with the datatables to use to fill the document tables with.  Table names in the dataset should match the table names in the document.</param>
        /// <param name="values">Values to fill the document.  Keys should match the MERGEFIELD names.</param>
        /// <returns>The filled-in document.</returns>
        public static byte[] GetWordReport(byte[] original, DataSet dataset, Dictionary<string, string> values)
        {
            // first read document in as stream
            //byte[] original = File.ReadAllBytes(filename);
            string[] switches = null;

            using (MemoryStream stream = new MemoryStream())
            {
                stream.Write(original, 0, original.Length);

                // Create a Wordprocessing document object. 
                using (WordprocessingDocument docx = WordprocessingDocument.Open(stream, true))
                {
                    //  2010/08/01: addition
                    ConvertFieldCodes(docx.MainDocumentPart.Document);

                    // first: process all tables
                    foreach (var field in docx.MainDocumentPart.Document.Descendants<SimpleField>())
                    {
                        string fieldname = GetFieldName(field, out switches);
                        if (!string.IsNullOrEmpty(fieldname) &&
                            fieldname.StartsWith("TBL_"))
                        {
                            TableRow wrow = GetFirstParent<TableRow>(field);
                            if (wrow == null)
                            {
                                continue;   // can happen: is because table contains multiple fields, and after 1 pass, the initial row is already deleted
                            }

                            Table wtable = GetFirstParent<Table>(wrow);
                            if (wtable == null)
                            {
                                continue;   // can happen: is because table contains multiple fields, and after 1 pass, the initial row is already deleted
                            }

                            string tablename = GetTableNameFromFieldName(fieldname);
                            if (dataset == null ||
                                !dataset.Tables.Contains(tablename) ||
                                dataset.Tables[tablename].Rows.Count == 0)
                            {
                                continue;   // don't remove table here: will be done in next pass
                            }

                            DataTable table = dataset.Tables[tablename];

                            List<TableCellProperties> props = new List<TableCellProperties>();
                            List<string> cellcolumnnames = new List<string>();
                            List<string> paragraphInfo = new List<string>();
                            List<SimpleField> cellfields = new List<SimpleField>();

                            foreach (TableCell cell in wrow.Descendants<TableCell>())
                            {
                                props.Add(cell.GetFirstChild<TableCellProperties>());
                                Paragraph p = cell.GetFirstChild<Paragraph>();
                                if (p != null)
                                {
                                    ParagraphProperties pp = p.GetFirstChild<ParagraphProperties>();
                                    if (pp != null)
                                    {
                                        paragraphInfo.Add(pp.OuterXml);
                                    }
                                    else
                                    {
                                        paragraphInfo.Add(null);
                                    }
                                }
                                else
                                {
                                    paragraphInfo.Add(null);
                                }

                                string colname = string.Empty;
                                SimpleField colfield = null;
                                foreach (SimpleField cellfield in cell.Descendants<SimpleField>())
                                {
                                    colfield = cellfield;
                                    colname = GetColumnNameFromFieldName(GetFieldName(cellfield, out switches));
                                    break;  // supports only 1 cellfield per table
                                }

                                cellcolumnnames.Add(colname);
                                cellfields.Add(colfield);
                            }

                            // keep reference to row properties
                            TableRowProperties rprops = wrow.GetFirstChild<TableRowProperties>();

                            foreach (DataRow row in table.Rows)
                            {
                                TableRow nrow = new TableRow();

                                if (rprops != null)
                                {
                                    nrow.Append(new TableRowProperties(rprops.OuterXml));
                                }

                                for (int i = 0; i < props.Count; i++)
                                {
                                    TableCellProperties cellproperties = new TableCellProperties(props[i].OuterXml);
                                    TableCell cell = new TableCell();
                                    cell.Append(cellproperties);
                                    Paragraph p = new Paragraph(new ParagraphProperties(paragraphInfo[i]));
                                    cell.Append(p);   // cell must contain at minimum a paragraph !

                                    if (!string.IsNullOrEmpty(cellcolumnnames[i]))
                                    {
                                        if (!table.Columns.Contains(cellcolumnnames[i]))
                                        {
                                            throw new Exception(string.Format("Unable to complete template: column name '{0}' is unknown in parameter tables !", cellcolumnnames[i]));
                                        }

                                        if (!row.IsNull(cellcolumnnames[i]))
                                        {
                                            string val = row[cellcolumnnames[i]].ToString();
                                            p.Append(GetRunElementForText(val, cellfields[i]));
                                        }
                                    }

                                    nrow.Append(cell);
                                }

                                wtable.Append(nrow);
                            }

                            // finally : delete template-row (and thus also the mergefields in the table)
                            wrow.Remove();
                        }
                    }

                    // clean empty tables
                    foreach (var field in docx.MainDocumentPart.Document.Descendants<SimpleField>())
                    {
                        string fieldname = GetFieldName(field, out switches);
                        if (!string.IsNullOrEmpty(fieldname) &&
                            fieldname.StartsWith("TBL_"))
                        {
                            TableRow wrow = GetFirstParent<TableRow>(field);
                            if (wrow == null)
                            {
                                continue;   // can happen: is because table contains multiple fields, and after 1 pass, the initial row is already deleted
                            }

                            Table wtable = GetFirstParent<Table>(wrow);
                            if (wtable == null)
                            {
                                continue;   // can happen: is because table contains multiple fields, and after 1 pass, the initial row is already deleted
                            }

                            string tablename = GetTableNameFromFieldName(fieldname);
                            if (dataset == null ||
                                !dataset.Tables.Contains(tablename) ||
                                dataset.Tables[tablename].Rows.Count == 0)
                            {
                                // if there's a 'dt' switch: delete Word-table
                                if (switches.Contains("dt"))
                                {
                                    wtable.Remove();
                                }
                            }
                        }
                    }

                    // next : process all remaining fields in the main document
                    FillWordFieldsInElement(values, docx.MainDocumentPart.Document);

                    docx.MainDocumentPart.Document.Save();  // save main document back in package

                    // process header(s)
                    foreach (HeaderPart hpart in docx.MainDocumentPart.HeaderParts)
                    {
                        //  2010/08/01: addition
                        ConvertFieldCodes(hpart.Header);

                        FillWordFieldsInElement(values, hpart.Header);
                        hpart.Header.Save();    // save header back in package
                    }

                    // process footer(s)
                    foreach (FooterPart fpart in docx.MainDocumentPart.FooterParts)
                    {
                        //  2010/08/01: addition
                        ConvertFieldCodes(fpart.Footer);

                        FillWordFieldsInElement(values, fpart.Footer);
                        fpart.Footer.Save();    // save footer back in package
                    }
					// 05/11/2011 Paul.  Delete MailMerge Data Source Part
					// http://openxmldeveloper.org/articles/7708.aspx
					DocumentSettingsPart settingsPart = docx.MainDocumentPart.DocumentSettingsPart;
					if ( settingsPart != null )
					{
						var mailMerge = settingsPart.Settings.GetFirstChild<MailMerge>();
						if ( mailMerge != null )
						{
							settingsPart.Settings.RemoveChild(mailMerge);
						}
						MailMergeRecipientDataPart mmrPart = settingsPart.MailMergeRecipientDataPart;
						if ( mmrPart != null )
						{
							settingsPart.DeletePart(mmrPart);
						}
						if ( mailMerge != null || mmrPart != null )
							settingsPart.RootElement.Save();
					}
				}
                // get package bytes
                stream.Seek(0, SeekOrigin.Begin);
                byte[] data = stream.ToArray();
                return data;
            }
        }

        /// <summary>
        /// Applies any formatting specified to the pre and post text as 
        /// well as to fieldValue.
        /// </summary>
        /// <param name="format">The format flag to apply.</param>
        /// <param name="fieldValue">The data value being inserted.</param>
        /// <param name="preText">The text to appear before fieldValue, if any.</param>
        /// <param name="postText">The text to appear after fieldValue, if any.</param>
        /// <returns>The formatted text; [0] = fieldValue, [1] = preText, [2] = postText.</returns>
        /// <exception cref="">Throw if fieldValue, preText, or postText are null.</exception>
        internal static string[] ApplyFormatting(string format, string fieldValue, string preText, string postText)
        {
            string[] valuesToReturn = new string[3];

            if ("UPPER".Equals(format))
            {
                // Convert everything to uppercase.
                valuesToReturn[0] = fieldValue.ToUpper(CultureInfo.CurrentCulture);
                valuesToReturn[1] = preText.ToUpper(CultureInfo.CurrentCulture);
                valuesToReturn[2] = postText.ToUpper(CultureInfo.CurrentCulture);
            }
            else if ("LOWER".Equals(format))
            {
                // Convert everything to lowercase.
                valuesToReturn[0] = fieldValue.ToLower(CultureInfo.CurrentCulture);
                valuesToReturn[1] = preText.ToLower(CultureInfo.CurrentCulture);
                valuesToReturn[2] = postText.ToLower(CultureInfo.CurrentCulture);
            }
            else if ("FirstCap".Equals(format))
            {
                // Capitalize the first letter, everything else is lowercase.
                if (!string.IsNullOrEmpty(fieldValue))
                {
                    valuesToReturn[0] = fieldValue.Substring(0, 1).ToUpper(CultureInfo.CurrentCulture);
                    if (fieldValue.Length > 1)
                    {
                        valuesToReturn[0] = valuesToReturn[0] + fieldValue.Substring(1).ToLower(CultureInfo.CurrentCulture);
                    }
                }

                if (!string.IsNullOrEmpty(preText))
                {
                    valuesToReturn[1] = preText.Substring(0, 1).ToUpper(CultureInfo.CurrentCulture);
                    if (fieldValue.Length > 1)
                    {
                        valuesToReturn[1] = valuesToReturn[1] + preText.Substring(1).ToLower(CultureInfo.CurrentCulture);
                    }
                }

                if (!string.IsNullOrEmpty(postText))
                {
                    valuesToReturn[2] = postText.Substring(0, 1).ToUpper(CultureInfo.CurrentCulture);
                    if (fieldValue.Length > 1)
                    {
                        valuesToReturn[2] = valuesToReturn[2] + postText.Substring(1).ToLower(CultureInfo.CurrentCulture);
                    }
                }
            }
            else if ("Caps".Equals(format))
            {
                // Title casing: the first letter of every word should be capitalized.
                valuesToReturn[0] = ToTitleCase(fieldValue);
                valuesToReturn[1] = ToTitleCase(preText);
                valuesToReturn[2] = ToTitleCase(postText);
            }
            else
            {
                valuesToReturn[0] = fieldValue;
                valuesToReturn[1] = preText;
                valuesToReturn[2] = postText;
            }

            return valuesToReturn;
        }

        /// <summary>
        /// Executes the field switches on a given element.
        /// The possible switches are:
        /// <list>
        /// <li>dt : delete table</li>
        /// <li>dr : delete row</li>
        /// <li>dp : delete paragraph</li>
        /// </list>
        /// </summary>
        /// <param name="element">The element being operated on.</param>
        /// <param name="switches">The switched to be executed.</param>
        internal static void ExecuteSwitches(OpenXmlElement element, string[] switches)
        {
            if (switches == null || switches.Count() == 0)
            {
                return;
            }

            // check switches (switches are always lowercase)
            if (switches.Contains("dp"))
            {
                Paragraph p = GetFirstParent<Paragraph>(element);
                if (p != null)
                {
                    p.Remove();
                }
            }
            else if (switches.Contains("dr"))
            {
                TableRow row = GetFirstParent<TableRow>(element);
                if (row != null)
                {
                    row.Remove();
                }
            }
            else if (switches.Contains("dt"))
            {
                Table table = GetFirstParent<Table>(element);
                if (table != null)
                {
                    table.Remove();
                }
            }
        }

        /// <summary>
        /// Fills all the <see cref="SimpleFields"/> that are found in a given <see cref="OpenXmlElement"/>.
        /// </summary>
        /// <param name="values">The values to insert; keys should match the placeholder names, values are the data to insert.</param>
        /// <param name="element">The document element taht will contain the new values.</param>
        internal static void FillWordFieldsInElement(Dictionary<string, string> values, OpenXmlElement element)
        {
            string[] switches;
            string[] options;
            string[] formattedText;

            Dictionary<SimpleField, string[]> emptyfields = new Dictionary<SimpleField, string[]>();

            // First pass: fill in data, but do not delete empty fields.  Deletions silently break the loop.
            // 06/09/2011 Paul.  Fix problem with two merge fields on the same row. 
            // http://www.codeproject.com/KB/office/Fill_Mergefields.aspx?msg=3196184
            foreach (var field in element.Descendants<SimpleField>().ToArray() )
            {
                string fieldname = GetFieldNameWithOptions(field, out switches, out options);
                if (!string.IsNullOrEmpty(fieldname))
                {
                    if (values.ContainsKey(fieldname)
                        && !string.IsNullOrEmpty(values[fieldname]))
                    {
                        formattedText = ApplyFormatting(options[0], values[fieldname], options[1], options[2]);

                        // Prepend any text specified to appear before the data in the MergeField
                        if (!string.IsNullOrEmpty(options[1]))
                        {
                            field.Parent.InsertBeforeSelf<Paragraph>(GetPreOrPostParagraphToInsert(formattedText[1], field));
                        }

                        // Append any text specified to appear after the data in the MergeField
                        if (!string.IsNullOrEmpty(options[2]))
                        {
                            field.Parent.InsertAfterSelf<Paragraph>(GetPreOrPostParagraphToInsert(formattedText[2], field));
                        }

                        // replace mergefield with text
                        field.Parent.ReplaceChild<SimpleField>(GetRunElementForText(formattedText[0], field), field);
                    }
                    else
                    {
                        // keep track of unknown or empty fields
                        emptyfields[field] = switches;
                    }
                }
            }

            // second pass : clear empty fields
            foreach (KeyValuePair<SimpleField, string[]> kvp in emptyfields)
            {
                // if field is unknown or empty: execute switches and remove it from document !
                ExecuteSwitches(kvp.Key, kvp.Value);
                kvp.Key.Remove();
            }
        }

        /// <summary>
        /// Returns the columnname from a given fieldname from a Mergefield
        /// The instruction of a table-Mergefield is formatted as TBL_tablename_columnname
        /// </summary>
        /// <param name="fieldname">The field name.</param>
        /// <returns>The column name.</returns>
        /// <exception cref="ArgumentException">Thrown when fieldname is not formatted as TBL_tablename_columname.</exception>
        internal static string GetColumnNameFromFieldName(string fieldname)
        {
            // Column name is after the second underscore.
            int pos1 = fieldname.IndexOf('_');
            if (pos1 <= 0)
            {
                throw new ArgumentException("Error: table-MERGEFIELD should be formatted as follows: TBL_tablename_columnname.");
            }

            int pos2 = fieldname.IndexOf('_', pos1 + 1);
            if (pos2 <= 0)
            {
                throw new ArgumentException("Error: table-MERGEFIELD should be formatted as follows: TBL_tablename_columnname.");
            }

            return fieldname.Substring(pos2 + 1);
        }

        /// <summary>
        /// Returns the fieldname and switches from the given mergefield-instruction
        /// Note: the switches are always returned lowercase !
        /// </summary>
        /// <param name="field">The field being examined.</param>
        /// <param name="switches">An array of switches to apply to the field.</param>
        /// <returns>The name of the field.</returns>
        internal static string GetFieldName(SimpleField field, out string[] switches)
        {
            var a = field.GetAttribute("instr", "http://schemas.openxmlformats.org/wordprocessingml/2006/main");
            switches = new string[0];
            string fieldname = string.Empty;
            string instruction = a.Value;

            if (!string.IsNullOrEmpty(instruction))
            {
                Match m = instructionRegEx.Match(instruction);
                if (m.Success)
                {
                    fieldname = m.Groups["name"].ToString().Trim();
                    int pos = fieldname.IndexOf('#');
                    if (pos > 0)
                    {
                        // Process the switches, correct the fieldname.
                        switches = fieldname.Substring(pos + 1).ToLower().Split(new char[] { '#' }, StringSplitOptions.RemoveEmptyEntries);
                        fieldname = fieldname.Substring(0, pos);
                    }
                }
            }

            return fieldname;
        }

        /// <summary>
        /// Returns the fieldname and switches from the given mergefield-instruction
        /// Note: the switches are always returned lowercase !
        /// Note 2: options holds values for formatting and text to insert before and/or after the field value.
        ///         options[0] = Formatting (Upper, Lower, Caps a.k.a. title case, FirstCap)
        ///         options[1] = Text to insert before data
        ///         options[2] = Text to insert after data
        /// </summary>
        /// <param name="field">The field being examined.</param>
        /// <param name="switches">An array of switches to apply to the field.</param>
        /// <param name="options">Formatting options to apply.</param>
        /// <returns>The name of the field.</returns>
        internal static string GetFieldNameWithOptions(SimpleField field, out string[] switches, out string[] options)
        {
            var a = field.GetAttribute("instr", "http://schemas.openxmlformats.org/wordprocessingml/2006/main");
            switches = new string[0];
            options = new string[3];
            string fieldname = string.Empty;
            string instruction = a.Value;

            if (!string.IsNullOrEmpty(instruction))
            {
                Match m = instructionRegEx.Match(instruction);
                if (m.Success)
                {
                    fieldname = m.Groups["name"].ToString().Trim();
                    options[0] = m.Groups["Format"].Value.Trim();
                    options[1] = m.Groups["PreText"].Value.Trim();
                    options[2] = m.Groups["PostText"].Value.Trim();
                    int pos = fieldname.IndexOf('#');
                    if (pos > 0)
                    {
                        // Process the switches, correct the fieldname.
                        switches = fieldname.Substring(pos + 1).ToLower().Split(new char[] { '#' }, StringSplitOptions.RemoveEmptyEntries);
                        fieldname = fieldname.Substring(0, pos);
                    }
                }
            }

            return fieldname;
        }

        /// <summary>
        /// Returns the first parent of a given <see cref="OpenXmlElement"/> that corresponds
        /// to the given type.
        /// This methods is different from the Ancestors-method on the OpenXmlElement in the sense that
        /// this method will return only the first-parent in direct line (closest to the given element).
        /// </summary>
        /// <typeparam name="T">The type of element being searched for.</typeparam>
        /// <param name="element">The element being examined.</param>
        /// <returns>The first parent of the element of the specified type.</returns>
        internal static T GetFirstParent<T>(OpenXmlElement element)
            where T : OpenXmlElement
        {
            if (element.Parent == null)
            {
                return null;
            }
            else if (element.Parent.GetType() == typeof(T))
            {
                return element.Parent as T;
            }
            else
            {
                return GetFirstParent<T>(element.Parent);
            }
        }

        /// <summary>
        /// Creates a paragraph to house text that should appear before or after the MergeField.
        /// </summary>
        /// <param name="text">The text to display.</param>
        /// <param name="fieldToMimic">The MergeField that will have its properties mimiced.</param>
        /// <returns>An OpenXml Paragraph ready to insert.</returns>
        internal static Paragraph GetPreOrPostParagraphToInsert(string text, SimpleField fieldToMimic)
        {
            Run runToInsert = GetRunElementForText(text, fieldToMimic);
            Paragraph paragraphToInsert = new Paragraph();
            paragraphToInsert.Append(runToInsert);

            return paragraphToInsert;
        }

        /// <summary>
        /// Returns a <see cref="Run"/>-openxml element for the given text.
        /// Specific about this run-element is that it can describe multiple-line and tabbed-text.
        /// The <see cref="SimpleField"/> placeholder can be provided too, to allow duplicating the formatting.
        /// </summary>
        /// <param name="text">The text to be inserted.</param>
        /// <param name="placeHolder">The placeholder where the text will be inserted.</param>
        /// <returns>A new <see cref="Run"/>-openxml element containing the specified text.</returns>
        internal static Run GetRunElementForText(string text, SimpleField placeHolder)
        {
            string rpr = null;
            if (placeHolder != null)
            {
                foreach (RunProperties placeholderrpr in placeHolder.Descendants<RunProperties>())
                {
                    rpr = placeholderrpr.OuterXml;
                    break;  // break at first
                }
            }

            Run r = new Run();
            if (!string.IsNullOrEmpty(rpr))
            {
                r.Append(new RunProperties(rpr));
            }

            if (!string.IsNullOrEmpty(text))
            {
                // first process line breaks
                string[] split = text.Split(new string[] { "\n" }, StringSplitOptions.None);
                bool first = true;
                foreach (string s in split)
                {
                    if (!first)
                    {
                        r.Append(new Break());
                    }

                    first = false;

                    // then process tabs
                    bool firsttab = true;
                    string[] tabsplit = s.Split(new string[] { "\t" }, StringSplitOptions.None);
                    foreach (string tabtext in tabsplit)
                    {
                        if (!firsttab)
                        {
                            r.Append(new TabChar());
                        }

                        r.Append(new Text(tabtext));
                        firsttab = false;
                    }
                }
            }

            return r;
        }

        /// <summary>
        /// Returns the table name from a given fieldname from a Mergefield.
        /// The instruction of a table-Mergefield is formatted as TBL_tablename_columnname
        /// </summary>
        /// <param name="fieldname">The field name.</param>
        /// <returns>The table name.</returns>
        /// <exception cref="ArgumentException">Thrown when fieldname is not formatted as TBL_tablename_columname.</exception>
        internal static string GetTableNameFromFieldName(string fieldname)
        {
            int pos1 = fieldname.IndexOf('_');
            if (pos1 <= 0)
            {
                throw new ArgumentException("Error: table-MERGEFIELD should be formatted as follows: TBL_tablename_columnname.");
            }

            int pos2 = fieldname.IndexOf('_', pos1 + 1);
            if (pos2 <= 0)
            {
                throw new ArgumentException("Error: table-MERGEFIELD should be formatted as follows: TBL_tablename_columnname.");
            }

            return fieldname.Substring(pos1 + 1, pos2 - pos1 - 1);
        }

        /// <summary>
        /// Title-cases a string, capitalizing the first letter of every word.
        /// </summary>
        /// <param name="toConvert">The string to convert.</param>
        /// <returns>The string after title-casing.</returns>
        internal static string ToTitleCase(string toConvert)
        {
            return ToTitleCaseHelper(toConvert, string.Empty);
        }

        /// <summary>
        /// Title-cases a string, capitalizing the first letter of every word.
        /// </summary>
        /// <param name="toConvert">The string to convert.</param>
        /// <param name="alreadyConverted">The part of the string already converted.  Seed with an empty string.</param>
        /// <returns>The string after title-casing.</returns>
        internal static string ToTitleCaseHelper(string toConvert, string alreadyConverted)
        {
            /*
             * Tail-recursive title-casing implementation.
             * Edge case: toConvert is empty, null, or just white space.  If so, return alreadyConverted.
             * Else: Capitalize the first letter of the first word in toConvert, append that to alreadyConverted and recur.
             */
            if (string.IsNullOrEmpty(toConvert))
            {
                return alreadyConverted;
            }
            else
            {
                int indexOfFirstSpace = toConvert.IndexOf(' ');
                string firstWord, restOfString;

                // Check to see if we're on the last word or if there are more.
                if (indexOfFirstSpace != -1)
                {
                    firstWord = toConvert.Substring(0, indexOfFirstSpace);
                    restOfString = toConvert.Substring(indexOfFirstSpace).Trim();
                }
                else
                {
                    firstWord = toConvert.Substring(0);
                    restOfString = string.Empty;
                }

                System.Text.StringBuilder sb = new StringBuilder();

                sb.Append(alreadyConverted);
                sb.Append(" ");
                sb.Append(firstWord.Substring(0, 1).ToUpper(CultureInfo.CurrentCulture));

                if (firstWord.Length > 1)
                {
                    sb.Append(firstWord.Substring(1).ToLower(CultureInfo.CurrentCulture));
                }

                return ToTitleCaseHelper(restOfString, sb.ToString());
            }
        }

        /// <summary>
        /// Since MS Word 2010 the SimpleField element is not longer used. It has been replaced by a combination of
        /// Run elements and a FieldCode element. This method will convert the new format to the old SimpleField-compliant 
        /// format.
        /// </summary>
        /// <param name="mainElement"></param>
        internal static void ConvertFieldCodes(OpenXmlElement mainElement)
        {
            //  search for all the Run elements 
            Run[] runs = mainElement.Descendants<Run>().ToArray();
            Dictionary<Run, Run[]> newfields = new Dictionary<Run, Run[]>();
            int cursor = 0;
            do
            {
                Run run = runs[cursor];
                if (run.HasChildren && run.Descendants<FieldChar>().Count() > 0
                    && (run.Descendants<FieldChar>().First().FieldCharType & FieldCharValues.Begin) == FieldCharValues.Begin)
                {
                    List<Run> innerRuns = new List<Run>();
                    innerRuns.Add(run);

                    //  loop until we find the 'end' FieldChar
                    bool found = false;
                    string instruction = null;
                    RunProperties runprop = null;
                    do
                    {
                        cursor++;
                        run = runs[cursor];
                        innerRuns.Add(run);
                        if (run.HasChildren && run.Descendants<FieldCode>().Count() > 0)
                            instruction += run.GetFirstChild<FieldCode>().Text;
                        if (run.HasChildren && run.Descendants<FieldChar>().Count() > 0
                            && (run.Descendants<FieldChar>().First().FieldCharType & FieldCharValues.End) == FieldCharValues.End)
                        {
                            found = true;
                        }
                        if (run.HasChildren && run.Descendants<RunProperties>().Count() > 0)
                            runprop = run.GetFirstChild<RunProperties>();
                    } while (found == false && cursor < runs.Length);

                    //  something went wrong : found Begin but no End. Throw exception
                    if (!found)
                        throw new Exception("Found a Begin FieldChar but no End !");

                    if (!string.IsNullOrEmpty(instruction))
                    {
                        //  build new Run containing a SimpleField
                        Run newrun = new Run();
                        if (runprop != null)
                            newrun.AppendChild(runprop.CloneNode(true));
                        SimpleField simplefield = new SimpleField();
                        simplefield.Instruction = instruction;
                        newrun.AppendChild(simplefield);

                        newfields.Add(newrun, innerRuns.ToArray());
                    }
                }
                
                cursor++;
            } while (cursor < runs.Length);

            //  replace all FieldCodes by old-style SimpleFields
            foreach (KeyValuePair<Run, Run[]> kvp in newfields)
            {
                kvp.Value[0].Parent.ReplaceChild(kvp.Key, kvp.Value[0]);
                for (int i = 1; i < kvp.Value.Length; i++)
                    kvp.Value[i].Remove();
            }
        }
    }
}
