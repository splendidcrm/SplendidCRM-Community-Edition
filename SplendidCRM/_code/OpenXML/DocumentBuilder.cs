/***************************************************************************

Copyright (c) Microsoft Corporation 2009.

This code is licensed using the Microsoft Public License (Ms-PL).  The text of the license can be found here:

http://www.microsoft.com/resources/sharedsource/licensingbasics/publiclicense.mspx

***************************************************************************/

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;
using System.Xml.Linq;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Wordprocessing;

namespace OpenXml.PowerTools
{
    /// <summary>
    /// Source is a simple helper class used for arguments to the document building functions	
    /// </summary>
    public class Source
    {
        private static XNamespace ns = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

        private WordprocessingDocument m_Source;
        private IEnumerable<XElement> m_Contents;
        private bool m_KeepSections;

        /// <summary>
        /// Specify the entire source document	
        /// </summary>
        public Source(WordprocessingDocument source, bool keepSections)
        {
            m_Source = source;
            m_Contents = source.MainDocumentPart.GetXDocument().Descendants(ns + "body").Elements();
            m_KeepSections = keepSections;
        }
        /// <summary>
        /// Specify from "start" to the end of the document	
        /// </summary>
        public Source(WordprocessingDocument source, int start, bool keepSections)
        {
            m_Source = source;
            m_Contents = source.MainDocumentPart.GetXDocument().Descendants(ns + "body").Elements().Skip(start);
            m_KeepSections = keepSections;
        }
        /// <summary>
        /// Specify from "start" and include "count" number of paragraphs
        /// </summary>
        public Source(WordprocessingDocument source, int start, int count, bool keepSections)
        {
            m_Source = source;
            m_Contents = source.MainDocumentPart.GetXDocument().Descendants(ns + "body").Elements().Skip(start).Take(count);
            m_KeepSections = keepSections;
        }
        /// <summary>
        /// Close the source document	
        /// </summary>
        public void Close()
        {
            m_Source.Close();
        }

        internal WordprocessingDocument Document
        {
            get { return m_Source; }
        }
        internal IEnumerable<XElement> Contents
        {
            get { return m_Contents; }
        }
        internal bool KeepSections
        {
            get { return m_KeepSections; }
        }
    }

    // This class is used to prevent duplication of images
    class ImageData
    {
        private byte[] m_Image;
        private string m_ContentType;
        private string m_ResourceID;

        public ImageData(ImagePart part)
        {
            m_ContentType = part.ContentType;
            using (Stream s = part.GetStream(FileMode.Open, FileAccess.Read))
            {
                m_Image = new byte[s.Length];
                s.Read(m_Image, 0, (int)s.Length);
            }
        }

        public void WriteImage(ImagePart part)
        {
            using (Stream s = part.GetStream(FileMode.Create, FileAccess.ReadWrite))
            {
                s.Write(m_Image, 0, m_Image.GetUpperBound(0) + 1);
            }
        }

        public string ResourceID
        {
            get { return m_ResourceID; }
            set { m_ResourceID = value; }
        }

        public bool Compare(ImageData arg)
        {
            if (m_ContentType != arg.m_ContentType)
                return false;
            if (m_Image.GetLongLength(0) != arg.m_Image.GetLongLength(0))
                return false;
            // Compare the arrays byte by byte
            long length = m_Image.GetLongLength(0);
            for (long n = 0; n < length; n++)
                if (m_Image[n] != arg.m_Image[n])
                    return false;
            return true;
        }
    }
    /// <summary>
    /// DocumentBuilder contains functions to build documents from multiple source documents.
    /// </summary>
    public static class DocumentBuilder
    {
        private static XNamespace ns = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";
        private static XNamespace ns_ve = "http://schemas.openxmlformats.org/markup-compatibility/2006";
        private static XNamespace ns_o = "urn:schemas-microsoft-com:office:office";
        private static XNamespace ns_r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships";
        private static XNamespace ns_m = "http://schemas.openxmlformats.org/officeDocument/2006/math";
        private static XNamespace ns_v = "urn:schemas-microsoft-com:vml";
        private static XNamespace ns_wp = "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing";
        private static XNamespace ns_w10 = "urn:schemas-microsoft-com:office:word";
        private static XNamespace ns_wne = "http://schemas.microsoft.com/office/word/2006/wordml";
        private static XNamespace ns_a = "http://schemas.openxmlformats.org/drawingml/2006/main";
        private static XNamespace ns_pic = "http://schemas.openxmlformats.org/drawingml/2006/picture";
        private static XNamespace ns_dgm = "http://schemas.openxmlformats.org/drawingml/2006/diagram";
        private static XNamespace ns_ds = "http://schemas.openxmlformats.org/officeDocument/2006/customXml";
        private static XNamespace ns_c = "http://schemas.openxmlformats.org/drawingml/2006/chart";
        private static XAttribute[] ns_attrs =
        {
            new XAttribute(XNamespace.Xmlns + "ve", ns_ve),
            new XAttribute(XNamespace.Xmlns + "o", ns_o),
            new XAttribute(XNamespace.Xmlns + "r", ns_r),
            new XAttribute(XNamespace.Xmlns + "m", ns_m),
            new XAttribute(XNamespace.Xmlns + "v", ns_v),
            new XAttribute(XNamespace.Xmlns + "wp", ns_wp),
            new XAttribute(XNamespace.Xmlns + "w10", ns_w10),
            new XAttribute(XNamespace.Xmlns + "w", ns),
            new XAttribute(XNamespace.Xmlns + "wne", ns_wne)
        };

        /// <summary>
        /// BuildDocument creates a new file-based document containing all the specified source paragraphs.
        /// </summary>
        public static void BuildDocument(List<Source> sources, string fileName)
        {
            using (WordprocessingDocument output = WordprocessingDocument.Create(fileName, DocumentFormat.OpenXml.WordprocessingDocumentType.Document))
            {
                BuildDocument(sources, output);
                output.FlushParts();
            }
        }

        /// <summary>
        /// BuildOpenDocument creates a new file-based document containing all the specified source paragraphs.
        /// The resulting document is kept open so that other operations can be performed on it.
        /// </summary>
        public static WordprocessingDocument BuildOpenDocument(List<Source> sources, string fileName)
        {
            WordprocessingDocument output = WordprocessingDocument.Create(fileName, DocumentFormat.OpenXml.WordprocessingDocumentType.Document);
            BuildDocument(sources, output);
            output.FlushParts();
            return output;
        }

        /// <summary>
        /// BuildOpenDocument creates a new stream-based document containing all the specified source paragraphs.
        /// The resulting document is kept open so that other operations can be performed on it.
        /// </summary>
        public static WordprocessingDocument BuildOpenDocument(List<Source> sources, Stream stream)
        {
            WordprocessingDocument output = WordprocessingDocument.Create(stream, DocumentFormat.OpenXml.WordprocessingDocumentType.Document);
            BuildDocument(sources, output);
            output.FlushParts();
            return output;
        }

        private static void BuildDocument(List<Source> sources, WordprocessingDocument output)
        {
            // This list is used to eliminate duplicate images
            List<ImageData> images = new List<ImageData>();
            output.AddMainDocumentPart();
            XDocument mainPart = output.MainDocumentPart.GetXDocument();
            mainPart.Add(new XElement(ns + "document", ns_attrs, new XElement(ns + "body")));
            if (sources.Count > 0)
            {
                output.CopyStartingParts(sources[0].Document, images);
                bool lastKeepSections = false;
                foreach (Source source in sources)
                {
                    output.AppendDocument(source.Document, source.Contents, source.KeepSections, lastKeepSections, images);
                    lastKeepSections = source.KeepSections;
                }
            }
        }

		public static void FlushParts(WordprocessingDocument output)
		{
			output.FlushParts();
		}

		// 05/12/2011 Paul.  Add ability to append chunks. 
		// http://blogs.msdn.com/b/ericwhite/archive/2008/10/27/how-to-use-altchunk-for-document-assembly.aspx
		public static void AppendAltChunk(WordprocessingDocument docx, int nID, byte[] byChunk)
		{
			string altChunkId = "AltChunkId" + nID.ToString();
			MainDocumentPart mainPart = docx.MainDocumentPart;
			if ( mainPart == null )
			{
				mainPart = docx.AddMainDocumentPart();
				mainPart.AddNewPart<WebSettingsPart>("rId3");
				mainPart.AddNewPart<DocumentSettingsPart>("rId2");
				mainPart.AddNewPart<StyleDefinitionsPart>("rId1");
				mainPart.AddNewPart<ThemePart>("rId5");
				mainPart.AddNewPart<FontTablePart>("rId4");
				mainPart.Document = new Document();
				mainPart.Document.Body = new Body();
			}
			AlternativeFormatImportPart chunk = mainPart.AddAlternativeFormatImportPart(AlternativeFormatImportPartType.WordprocessingML, altChunkId);
			using ( MemoryStream stmChunk = new MemoryStream() )
			{
				stmChunk.Write(byChunk, 0, byChunk.Length);
				stmChunk.Seek(0, SeekOrigin.Begin);
				chunk.FeedData(stmChunk);
			}
			AltChunk altChunk = new AltChunk();
			altChunk.Id = altChunkId;
			mainPart.Document.Body.InsertAt<AltChunk>(altChunk, mainPart.Document.Body.Elements().Count());
			//mainPart.Document.Body.InsertAfter(altChunk, mainPart.Document.Body.Elements<Paragraph>().Last());
		}

        private static void AppendDocument(this WordprocessingDocument doc, WordprocessingDocument source, IEnumerable<XElement> contents,
            bool keepSection, bool lastKeepSection, List<ImageData> images)
        {
            FixRanges(source.MainDocumentPart.GetXDocument(), contents);
            CopyReferences(source, doc, contents, images);

            // Append contents
            XDocument mainPart = doc.MainDocumentPart.GetXDocument();
            XElement section = mainPart.Root.Element(ns + "body").Element(ns + "sectPr");
            XElement newSection = contents.Last();
            if (newSection.Name != ns + "sectPr")
                newSection = null;
            if (newSection == null)
                keepSection = false;
            bool newContainsSection = contents.Descendants(ns + "pPr").Descendants(ns + "sectPr").Any();
            if (section != null)
            {
                section.Remove();
                if (lastKeepSection)
                {
                    if (newContainsSection || keepSection)
                    {
                        XElement paragraph = mainPart.Root.Element(ns + "body").Elements(ns + "p").Last();
                        XElement prop = paragraph.Element(ns + "pPr");
                        if (prop == null)
                        {
                            prop = new XElement(ns + "pPr");
                            paragraph.AddFirst(prop);
                        }
                        if (newContainsSection && !keepSection)
                            prop.Add(new XElement(section));
                        else
                            prop.Add(section);
                    }
                }
                else if (keepSection)
                    section = null;
            }
            mainPart.Root.Element(ns + "body").Add(contents);
            if (!keepSection && section != null)
            {
                newSection = mainPart.Root.Element(ns + "body").Element(ns + "sectPr");
                if (newSection != null)
                    newSection.Remove();
                mainPart.Root.Element(ns + "body").Add(section);
            }
        }

        private static void CopyStartingParts(this WordprocessingDocument doc, WordprocessingDocument source, List<ImageData> images)
        {
            // Copy core attributes
            CoreFilePropertiesPart corePart = source.CoreFilePropertiesPart;
            if (corePart != null)
            {
                doc.AddCoreFilePropertiesPart();
                doc.CoreFilePropertiesPart.GetXDocument().Add(corePart.GetXDocument().Root);
            }

            // Copy application attributes
            ExtendedFilePropertiesPart extPart = source.ExtendedFilePropertiesPart;
            if (extPart != null)
            {
                doc.AddExtendedFilePropertiesPart();
                doc.ExtendedFilePropertiesPart.GetXDocument().Add(extPart.GetXDocument().Root);
            }

            // Copy custom attributes
            CustomFilePropertiesPart customPart = source.CustomFilePropertiesPart;
            if (customPart != null)
            {
                doc.AddCustomFilePropertiesPart();
                doc.CustomFilePropertiesPart.GetXDocument().Add(customPart.GetXDocument().Root);
            }

            // Copy document settings
            DocumentSettingsPart settingsPart = source.MainDocumentPart.DocumentSettingsPart;
            if (settingsPart != null)
            {
                doc.MainDocumentPart.AddNewPart<DocumentSettingsPart>();
                XDocument newSettings = doc.MainDocumentPart.DocumentSettingsPart.GetXDocument();
                newSettings.Add(settingsPart.GetXDocument().Root);
                foreach (ExternalRelationship rel in settingsPart.ExternalRelationships)
                    doc.MainDocumentPart.DocumentSettingsPart.AddExternalRelationship(rel.RelationshipType, rel.Uri, rel.Id);
                CopyFootnotes(doc, source, newSettings);
                CopyEndnotes(doc, source, newSettings);
            }

            // Copy web settings
            WebSettingsPart webPart = source.MainDocumentPart.WebSettingsPart;
            if (webPart != null)
            {
                doc.MainDocumentPart.AddNewPart<WebSettingsPart>();
                doc.MainDocumentPart.WebSettingsPart.GetXDocument().Add(webPart.GetXDocument().Root);
            }

            // Copy theme
            // NOTE: Currently, copying of images does not work. As a workaround, if the theme has any images, it is not copied.
            ThemePart themePart = source.MainDocumentPart.ThemePart;
            if (themePart != null && !themePart.GetXDocument().Descendants(ns_a + "blip").Any())
            {
                doc.MainDocumentPart.AddNewPart<ThemePart>();
                doc.MainDocumentPart.ThemePart.GetXDocument().Add(themePart.GetXDocument().Root);
                // Copy theme images
                foreach (XElement imageReference in themePart.GetXDocument().Descendants(ns_a + "blip"))
                {
                    string relId = imageReference.Attribute(ns_r + "embed").Value;
                    ImagePart oldPart = (ImagePart)themePart.GetPartById(relId);
                    ImageData temp = ManageImageCopy(oldPart, images);
                    if (temp.ResourceID == null)
                    {
                        ImagePart newPart = doc.MainDocumentPart.ThemePart.AddImagePart(oldPart.ContentType);
                        temp.ResourceID = doc.MainDocumentPart.ThemePart.GetIdOfPart(newPart);
                        temp.WriteImage(newPart);
                    }
                    imageReference.Attribute(ns_r + "embed").Value = temp.ResourceID;
                }

            }

            // Copy styles
            StyleDefinitionsPart stylesPart = source.MainDocumentPart.StyleDefinitionsPart;
            if (stylesPart != null)
            {
                doc.MainDocumentPart.AddNewPart<StyleDefinitionsPart>();
                doc.MainDocumentPart.StyleDefinitionsPart.GetXDocument().Add(stylesPart.GetXDocument().Root);
            }

            // Copy font table
            FontTablePart fontTablePart = source.MainDocumentPart.FontTablePart;
            if (fontTablePart != null)
            {
                doc.MainDocumentPart.AddNewPart<FontTablePart>();
                doc.MainDocumentPart.FontTablePart.GetXDocument().Add(fontTablePart.GetXDocument().Root);
            }
        }
        private static void CopyFootnotes(WordprocessingDocument doc, WordprocessingDocument source, XDocument settings)
        {
            int number = 0;
            XDocument oldFootnotes = null;
            XDocument newFootnotes = null;
            XElement footnotePr = settings.Root.Element(ns + "footnotePr");
            if (footnotePr == null)
                return;
            foreach (XElement footnote in footnotePr.Elements(ns + "footnote"))
            {
                if (oldFootnotes == null)
                    oldFootnotes = source.MainDocumentPart.FootnotesPart.GetXDocument();
                if (newFootnotes == null)
                {
                    if (doc.MainDocumentPart.FootnotesPart != null)
                    {
                        newFootnotes = doc.MainDocumentPart.FootnotesPart.GetXDocument();
                        var ids = newFootnotes.Root.Elements(ns + "footnote").Select(f => (int)f.Attribute(ns + "id"));
                        if (ids.Any())
                            number = ids.Max() + 1;
                    }
                    else
                    {
                        doc.MainDocumentPart.AddNewPart<FootnotesPart>();
                        newFootnotes = doc.MainDocumentPart.FootnotesPart.GetXDocument();
                        newFootnotes.Add(new XElement(ns + "footnotes", ns_attrs));
                    }
                }
                string id = (string)footnote.Attribute(ns + "id");
                XElement element = oldFootnotes.Descendants().Elements(ns + "footnote").Where(p => ((string)p.Attribute(ns + "id")) == id).First();
                XElement newElement = new XElement(element);
                newElement.Attribute(ns + "id").Value = number.ToString();
                newFootnotes.Root.Add(newElement);
                footnote.Attribute(ns + "id").Value = number.ToString();
                number++;
            }
        }
        private static void CopyEndnotes(WordprocessingDocument doc, WordprocessingDocument source, XDocument settings)
        {
            int number = 0;
            XDocument oldEndnotes = null;
            XDocument newEndnotes = null;
            XElement endnotePr = settings.Root.Element(ns + "endnotePr");
            if (endnotePr == null)
                return;
            foreach (XElement endnote in endnotePr.Elements(ns + "endnote"))
            {
                if (oldEndnotes == null)
                    oldEndnotes = source.MainDocumentPart.EndnotesPart.GetXDocument();
                if (newEndnotes == null)
                {
                    if (doc.MainDocumentPart.EndnotesPart != null)
                    {
                        newEndnotes = doc.MainDocumentPart.EndnotesPart.GetXDocument();
                        var ids = newEndnotes.Root.Elements(ns + "endnote").Select(f => (int)f.Attribute(ns + "id"));
                        if (ids.Any())
                            number = ids.Max() + 1;
                    }
                    else
                    {
                        doc.MainDocumentPart.AddNewPart<EndnotesPart>();
                        newEndnotes = doc.MainDocumentPart.EndnotesPart.GetXDocument();
                        newEndnotes.Add(new XElement(ns + "endnotes", ns_attrs));
                    }
                }
                string id = (string)endnote.Attribute(ns + "id");
                XElement element = oldEndnotes.Descendants().Elements(ns + "endnote").Where(p => ((string)p.Attribute(ns + "id")) == id).First();
                XElement newElement = new XElement(element);
                newElement.Attribute(ns + "id").Value = number.ToString();
                newEndnotes.Root.Add(newElement);
                endnote.Attribute(ns + "id").Value = number.ToString();
                number++;
            }
        }


        private static void FixRanges(XDocument oldDoc, IEnumerable<XElement> paragraphs)
        {
            FixRange(oldDoc, paragraphs, ns + "commentRangeStart", ns + "commentRangeEnd", ns + "id", ns + "commentReference");
            FixRange(oldDoc, paragraphs, ns + "bookmarkStart", ns + "bookmarkEnd", ns + "id", null);
            FixRange(oldDoc, paragraphs, ns + "permStart", ns + "permEnd", ns + "id", null);
            FixRange(oldDoc, paragraphs, ns + "moveFromRangeStart", ns + "moveFromRangeEnd", ns + "id", null);
            FixRange(oldDoc, paragraphs, ns + "moveToRangeStart", ns + "moveToRangeEnd", ns + "id", null);
            DeleteUnmatchedRange(oldDoc, paragraphs, ns + "moveFromRangeStart", ns + "moveFromRangeEnd", ns + "moveToRangeStart", ns + "name", ns + "id");
            DeleteUnmatchedRange(oldDoc, paragraphs, ns + "moveToRangeStart", ns + "moveToRangeEnd", ns + "moveFromRangeStart", ns + "name", ns + "id");
        }
        private static void FixRange(XDocument oldDoc, IEnumerable<XElement> paragraphs, XName startElement, XName endElement, XName idAttribute, XName refElement)
        {
            foreach (XElement start in paragraphs.Elements(startElement))
            {
                string rangeId = start.Attribute(idAttribute).Value;
                if (paragraphs.Elements(endElement).Where(e => e.Attribute(idAttribute).Value == rangeId).Count() == 0)
                {
                    XElement end = oldDoc.Descendants().Elements(endElement).Where(o => o.Attribute(idAttribute).Value == rangeId).First();
                    if (end != null)
                    {
                        paragraphs.Last().Add(new XElement(end));
                        if (refElement != null)
                        {
                            XElement newRef = new XElement(refElement, new XAttribute(idAttribute, rangeId));
                            paragraphs.Last().Add(newRef);
                        }
                    }
                }
            }
            foreach (XElement end in paragraphs.Elements(endElement))
            {
                string rangeId = end.Attribute(idAttribute).Value;
                if (paragraphs.Elements(startElement).Where(s => s.Attribute(idAttribute).Value == rangeId).Count() == 0)
                {
                    XElement start = oldDoc.Descendants().Elements(startElement).Where(o => o.Attribute(idAttribute).Value == rangeId).First();
                    if (start != null)
                        paragraphs.First().AddFirst(new XElement(start));
                }
            }
        }
        private static void DeleteUnmatchedRange(XDocument oldDoc, IEnumerable<XElement> paragraphs, XName startElement, XName endElement, XName matchTo, XName matchAttr, XName idAttr)
        {
            List<string> deleteList = new List<string>();
            foreach (XElement start in paragraphs.Elements(startElement))
            {
                string id = start.Attribute(matchAttr).Value;
                if (!paragraphs.Elements(matchTo).Where(n => n.Attribute(matchAttr).Value == id).Any())
                    deleteList.Add(start.Attribute(idAttr).Value);
            }
            foreach (string item in deleteList)
            {
                paragraphs.Elements(startElement).Where(n => n.Attribute(idAttr).Value == item).Remove();
                paragraphs.Elements(endElement).Where(n => n.Attribute(idAttr).Value == item).Remove();
                paragraphs.Where(p => p.Name == startElement && p.Attribute(idAttr).Value == item).Remove();
                paragraphs.Where(p => p.Name == endElement && p.Attribute(idAttr).Value == item).Remove();
            }
        }

        private static void CopyReferences(WordprocessingDocument oldDoc, WordprocessingDocument newDoc, IEnumerable<XElement> paragraphs, List<ImageData> images)
        {
            // Copy all styles to the new document
            if (oldDoc.MainDocumentPart.StyleDefinitionsPart != null)
            {
                XDocument oldStyles = oldDoc.MainDocumentPart.StyleDefinitionsPart.GetXDocument();
                if (newDoc.MainDocumentPart.StyleDefinitionsPart == null)
                {
                    newDoc.MainDocumentPart.AddNewPart<StyleDefinitionsPart>();
                    XDocument newStyles = newDoc.MainDocumentPart.StyleDefinitionsPart.GetXDocument();
                    newStyles.Add(oldStyles.Root);
                }
                else
                {
                    XDocument newStyles = newDoc.MainDocumentPart.StyleDefinitionsPart.GetXDocument();
                    MergeStyles(oldStyles, newStyles);
                }
            }

            // Copy fontTable to the new document
            if (oldDoc.MainDocumentPart.FontTablePart != null)
            {
                XDocument oldFontTable = oldDoc.MainDocumentPart.FontTablePart.GetXDocument();
                if (newDoc.MainDocumentPart.FontTablePart == null)
                {
                    newDoc.MainDocumentPart.AddNewPart<FontTablePart>();
                    XDocument newFontTable = newDoc.MainDocumentPart.FontTablePart.GetXDocument();
                    newFontTable.Add(oldFontTable.Root);
                }
                else
                {
                    XDocument newFontTable = newDoc.MainDocumentPart.FontTablePart.GetXDocument();
                    MergeFontTables(oldFontTable, newFontTable);
                }
            }

            CopyNumbering(oldDoc, newDoc, paragraphs);
            CopyFootnotes(oldDoc, newDoc, paragraphs);
            CopyEndnotes(oldDoc, newDoc, paragraphs);
            CopyHyperlinks(oldDoc, newDoc, paragraphs);
            CopyComments(oldDoc, newDoc, paragraphs);
            CopyHeaders(oldDoc, newDoc, paragraphs, images);
            CopyFooters(oldDoc, newDoc, paragraphs, images);
            CopyImages(oldDoc, newDoc, paragraphs, images);
            CopyDiagrams(oldDoc, newDoc, paragraphs);
            CopyShapes(oldDoc, newDoc, paragraphs, images);
            CopyCustomXml(oldDoc, newDoc, paragraphs);
            CopyEmbeddedObjects(oldDoc, newDoc, paragraphs);
            CopyCharts(oldDoc, newDoc, paragraphs);
        }
        private static void MergeStyles(XDocument fromStyles, XDocument toStyles)
        {
            foreach (XElement style in fromStyles.Root.Elements(ns + "style"))
            {
                string name = style.Attribute(ns + "styleId").Value;
                if (toStyles.Root.Elements(ns + "style").Where(o => o.Attribute(ns + "styleId").Value == name).Count() == 0)
                    toStyles.Root.Add(new XElement(style));
            }
        }
        private static void MergeFontTables(XDocument fromFontTable, XDocument toFontTable)
        {
            foreach (XElement font in fromFontTable.Root.Elements(ns + "font"))
            {
                string name = font.Attribute(ns + "name").Value;
                if (toFontTable.Root.Elements(ns + "font").Where(o => o.Attribute(ns + "name").Value == name).Count() == 0)
                    toFontTable.Root.Add(new XElement(font));
            }
        }
        private static void CopyFootnotes(WordprocessingDocument oldDoc, WordprocessingDocument newDoc, IEnumerable<XElement> paragraphs)
        {
            int number = 0;
            XDocument oldFootnotes = null;
            XDocument newFootnotes = null;
            foreach (XElement footnote in paragraphs.Descendants(ns + "footnoteReference"))
            {
                if (oldFootnotes == null)
                    oldFootnotes = oldDoc.MainDocumentPart.FootnotesPart.GetXDocument();
                if (newFootnotes == null)
                {
                    if (newDoc.MainDocumentPart.FootnotesPart != null)
                    {
                        newFootnotes = newDoc.MainDocumentPart.FootnotesPart.GetXDocument();
                        var ids = newFootnotes.Root.Elements(ns + "footnote").Select(f => (int)f.Attribute(ns + "id"));
                        if (ids.Any())
                            number = ids.Max() + 1;
                    }
                    else
                    {
                        newDoc.MainDocumentPart.AddNewPart<FootnotesPart>();
                        newFootnotes = newDoc.MainDocumentPart.FootnotesPart.GetXDocument();
                        newFootnotes.Add(new XElement(ns + "footnotes", ns_attrs));
                    }
                }
                string id = (string)footnote.Attribute(ns + "id");
                XElement element = oldFootnotes.Descendants().Elements(ns + "footnote").Where(p => ((string)p.Attribute(ns + "id")) == id).First();
                XElement newElement = new XElement(element);
                newElement.Attribute(ns + "id").Value = number.ToString();
                newFootnotes.Root.Add(newElement);
                footnote.Attribute(ns + "id").Value = number.ToString();
                number++;
            }
        }
        private static void CopyEndnotes(WordprocessingDocument oldDoc, WordprocessingDocument newDoc, IEnumerable<XElement> paragraphs)
        {
            int number = 0;
            XDocument oldEndnotes = null;
            XDocument newEndnotes = null;
            foreach (XElement endnote in paragraphs.Descendants(ns + "endnoteReference"))
            {
                if (oldEndnotes == null)
                    oldEndnotes = oldDoc.MainDocumentPart.EndnotesPart.GetXDocument();
                if (newEndnotes == null)
                {
                    if (newDoc.MainDocumentPart.EndnotesPart != null)
                    {
                        newEndnotes = newDoc.MainDocumentPart.EndnotesPart.GetXDocument();
                        var ids = newEndnotes.Root.Elements(ns + "endnote").Select(f => (int)f.Attribute(ns + "id"));
                        if (ids.Any())
                            number = ids.Max() + 1;
                    }
                    else
                    {
                        newDoc.MainDocumentPart.AddNewPart<EndnotesPart>();
                        newEndnotes = newDoc.MainDocumentPart.EndnotesPart.GetXDocument();
                        newEndnotes.Add(new XElement(ns + "endnotes", ns_attrs));
                    }
                }
                string id = (string)endnote.Attribute(ns + "id");
                XElement element = oldEndnotes.Descendants().Elements(ns + "endnote").Where(p => ((string)p.Attribute(ns + "id")) == id).First();
                XElement newElement = new XElement(element);
                newElement.Attribute(ns + "id").Value = number.ToString();
                newEndnotes.Root.Add(newElement);
                endnote.Attribute(ns + "id").Value = number.ToString();
                number++;
            }
        }
        private static void CopyHyperlinks(WordprocessingDocument oldDoc, WordprocessingDocument newDoc, IEnumerable<XElement> paragraphs)
        {
            foreach (XElement hyperlink in paragraphs.Descendants(ns + "hyperlink"))
                if (hyperlink.Attribute(ns_r + "id") != null)
                {
                    string relId = hyperlink.Attribute(ns_r + "id").Value;
                    HyperlinkRelationship relLink = oldDoc.MainDocumentPart.HyperlinkRelationships.Where(rel => (rel.Id == relId)).FirstOrDefault();
                    HyperlinkRelationship newRelLink = newDoc.MainDocumentPart.AddHyperlinkRelationship(relLink.Uri, true);
                    hyperlink.Attribute(ns_r + "id").Value = newRelLink.Id;
                }
            foreach (XElement hyperlink in paragraphs.Descendants(ns_v + "imagedata"))
                if (hyperlink.Attribute(ns_r + "href") != null)
                {
                    string relId = hyperlink.Attribute(ns_r + "href").Value;
                    ExternalRelationship relLink = oldDoc.MainDocumentPart.ExternalRelationships.Where(rel => (rel.Id == relId)).FirstOrDefault();
                    ExternalRelationship newRelLink = newDoc.MainDocumentPart.AddExternalRelationship(relLink.RelationshipType, relLink.Uri);
                    hyperlink.Attribute(ns_r + "href").Value = newRelLink.Id;
                }
        }
        private static void CopyComments(WordprocessingDocument oldDoc, WordprocessingDocument newDoc, IEnumerable<XElement> paragraphs)
        {
            int number = 0;
            XDocument oldComments = null;
            XDocument newComments = null;
            foreach (XElement comment in paragraphs.Descendants(ns + "commentReference"))
            {
                if (oldComments == null)
                    oldComments = oldDoc.MainDocumentPart.WordprocessingCommentsPart.GetXDocument();
                if (newComments == null)
                {
                    if (newDoc.MainDocumentPart.WordprocessingCommentsPart != null)
                    {
                        newComments = newDoc.MainDocumentPart.WordprocessingCommentsPart.GetXDocument();
                        var ids = newComments.Root.Elements(ns + "comment").Select(f => (int)f.Attribute(ns + "id"));
                        if (ids.Any())
                            number = ids.Max() + 1;
                    }
                    else
                    {
                        newDoc.MainDocumentPart.AddNewPart<WordprocessingCommentsPart>();
                        newComments = newDoc.MainDocumentPart.WordprocessingCommentsPart.GetXDocument();
                        newComments.Add(new XElement(ns + "comments", ns_attrs));
                    }
                }
                string id = (string)comment.Attribute(ns + "id");
                XElement element = oldComments.Descendants().Elements(ns + "comment").Where(p => ((string)p.Attribute(ns + "id")) == id).First();
                XElement newElement = new XElement(element);
                newElement.Attribute(ns + "id").Value = number.ToString();
                newComments.Root.Add(newElement);
                comment.Attribute(ns + "id").Value = number.ToString();
                XElement commentRange = paragraphs.Elements(ns + "commentRangeStart").Where(s => ((string)s.Attribute(ns + "id")) == id).FirstOrDefault();
                if (commentRange != null)
                    commentRange.Attribute(ns + "id").Value = number.ToString();
                commentRange = paragraphs.Elements(ns + "commentRangeEnd").Where(s => ((string)s.Attribute(ns + "id")) == id).FirstOrDefault();
                if (commentRange != null)
                    commentRange.Attribute(ns + "id").Value = number.ToString();
                number++;
            }
        }
        private static void CopyHeaders(WordprocessingDocument oldDoc, WordprocessingDocument newDoc, IEnumerable<XElement> paragraphs, List<ImageData> images)
        {
            foreach (XElement headerReference in paragraphs.Descendants(ns + "headerReference"))
            {
                string relId = headerReference.Attribute(ns_r + "id").Value;
                HeaderPart oldPart = (HeaderPart)oldDoc.MainDocumentPart.GetPartById(relId);
                XDocument oldHeader = oldPart.GetXDocument();
                HeaderPart newPart = newDoc.MainDocumentPart.AddNewPart<HeaderPart>();
                XDocument newHeader = newPart.GetXDocument();
                newHeader.Add(oldHeader.Root);
                headerReference.Attribute(ns_r + "id").Value = newDoc.MainDocumentPart.GetIdOfPart(newPart);
                CopyHeaderShapes(oldPart, newPart, images);
                CopyHeaderEmbeddedObjects(oldPart, newPart);
                CopyHeaderImages(oldPart, newPart, images);
            }
        }
        private static void CopyFooters(WordprocessingDocument oldDoc, WordprocessingDocument newDoc, IEnumerable<XElement> paragraphs, List<ImageData> images)
        {
            foreach (XElement footerReference in paragraphs.Descendants(ns + "footerReference"))
            {
                string relId = footerReference.Attribute(ns_r + "id").Value;
                FooterPart oldPart = (FooterPart)oldDoc.MainDocumentPart.GetPartById(relId);
                XDocument oldFooter = oldPart.GetXDocument();
                FooterPart newPart = newDoc.MainDocumentPart.AddNewPart<FooterPart>();
                XDocument newFooter = newPart.GetXDocument();
                newFooter.Add(oldFooter.Root);
                footerReference.Attribute(ns_r + "id").Value = newDoc.MainDocumentPart.GetIdOfPart(newPart);
                CopyFooterShapes(oldPart, newPart, images);
                CopyFooterEmbeddedObjects(oldPart, newPart);
                CopyFooterImages(oldPart, newPart, images);
            }
        }
        private static void CopyHeaderShapes(HeaderPart oldHeader, HeaderPart newHeader, List<ImageData> images)
        {
            foreach (XElement shapeReference in newHeader.GetXDocument().Descendants(ns_v + "imagedata"))
            {
                string relId = shapeReference.Attribute(ns_r + "id").Value;
                ImagePart oldPart = (ImagePart)oldHeader.GetPartById(relId);
                ImageData temp = ManageImageCopy(oldPart, images);
                if (temp.ResourceID == null)
                {
                    ImagePart newPart = newHeader.AddImagePart(oldPart.ContentType);
                    temp.ResourceID = newHeader.GetIdOfPart(newPart);
                    temp.WriteImage(newPart);
                }
                shapeReference.Attribute(ns_r + "id").Value = temp.ResourceID;
            }
        }
        private static void CopyHeaderEmbeddedObjects(HeaderPart oldHeader, HeaderPart newHeader)
        {
            foreach (XElement oleReference in newHeader.GetXDocument().Descendants(ns_o + "OLEObject"))
            {
                string relId = oleReference.Attribute(ns_r + "id").Value;
                EmbeddedObjectPart oldPart = (EmbeddedObjectPart)oldHeader.GetPartById(relId);
                EmbeddedObjectPart newPart = newHeader.AddEmbeddedObjectPart(oldPart.ContentType);
                using (Stream oldObject = oldPart.GetStream(FileMode.Open, FileAccess.Read))
                using (Stream newObject = newPart.GetStream(FileMode.Create, FileAccess.ReadWrite))
                {
                    int byteCount;
                    byte[] buffer = new byte[65536];
                    while ((byteCount = oldObject.Read(buffer, 0, 65536)) != 0)
                        newObject.Write(buffer, 0, byteCount);
                }
                oleReference.Attribute(ns_r + "id").Value = newHeader.GetIdOfPart(newPart);
            }
        }
        private static void CopyHeaderImages(HeaderPart oldHeader, HeaderPart newHeader, List<ImageData> images)
        {
            foreach (XElement imageReference in newHeader.GetXDocument().Descendants(ns_a + "blip"))
            {
                string relId = imageReference.Attribute(ns_r + "embed").Value;
                ImagePart oldPart = (ImagePart)oldHeader.GetPartById(relId);
                ImageData temp = ManageImageCopy(oldPart, images);
                if (temp.ResourceID == null)
                {
                    ImagePart newPart = newHeader.AddImagePart(oldPart.ContentType);
                    temp.ResourceID = newHeader.GetIdOfPart(newPart);
                    temp.WriteImage(newPart);
                }
                imageReference.Attribute(ns_r + "embed").Value = temp.ResourceID;
            }
        }
        private static void CopyFooterShapes(FooterPart oldFooter, FooterPart newFooter, List<ImageData> images)
        {
            foreach (XElement shapeReference in newFooter.GetXDocument().Descendants(ns_v + "imagedata"))
            {
                string relId = shapeReference.Attribute(ns_r + "id").Value;
                ImagePart oldPart = (ImagePart)oldFooter.GetPartById(relId);
                ImageData temp = ManageImageCopy(oldPart, images);
                if (temp.ResourceID == null)
                {
                    ImagePart newPart = newFooter.AddImagePart(oldPart.ContentType);
                    temp.ResourceID = newFooter.GetIdOfPart(newPart);
                    temp.WriteImage(newPart);
                }
                shapeReference.Attribute(ns_r + "id").Value = temp.ResourceID;
            }
        }
        private static void CopyFooterEmbeddedObjects(FooterPart oldFooter, FooterPart newFooter)
        {
            foreach (XElement oleReference in newFooter.GetXDocument().Descendants(ns_o + "OLEObject"))
            {
                string relId = oleReference.Attribute(ns_r + "id").Value;
                EmbeddedObjectPart oldPart = (EmbeddedObjectPart)oldFooter.GetPartById(relId);
                EmbeddedObjectPart newPart = newFooter.AddEmbeddedObjectPart(oldPart.ContentType);
                using (Stream oldObject = oldPart.GetStream(FileMode.Open, FileAccess.Read))
                using (Stream newObject = newPart.GetStream(FileMode.Create, FileAccess.ReadWrite))
                {
                    int byteCount;
                    byte[] buffer = new byte[65536];
                    while ((byteCount = oldObject.Read(buffer, 0, 65536)) != 0)
                        newObject.Write(buffer, 0, byteCount);
                }
                oleReference.Attribute(ns_r + "id").Value = newFooter.GetIdOfPart(newPart);
            }
        }
        private static void CopyFooterImages(FooterPart oldFooter, FooterPart newFooter, List<ImageData> images)
        {
            foreach (XElement imageReference in newFooter.GetXDocument().Descendants(ns_a + "blip"))
            {
                string relId = imageReference.Attribute(ns_r + "embed").Value;
                ImagePart oldPart = (ImagePart)oldFooter.GetPartById(relId);
                ImageData temp = ManageImageCopy(oldPart, images);
                if (temp.ResourceID == null)
                {
                    ImagePart newPart = newFooter.AddImagePart(oldPart.ContentType);
                    temp.ResourceID = newFooter.GetIdOfPart(newPart);
                    temp.WriteImage(newPart);
                }
                imageReference.Attribute(ns_r + "embed").Value = temp.ResourceID;
            }
        }
        private static void CopyImages(WordprocessingDocument oldDoc, WordprocessingDocument newDoc, IEnumerable<XElement> paragraphs, List<ImageData> images)
        {
            foreach (XElement imageReference in paragraphs.Descendants(ns_a + "blip"))
            {
                string relId = imageReference.Attribute(ns_r + "embed").Value;
                ImagePart oldPart = (ImagePart)oldDoc.MainDocumentPart.GetPartById(relId);
                ImageData temp = ManageImageCopy(oldPart, images);
                if (temp.ResourceID == null)
                {
                    ImagePart newPart = newDoc.MainDocumentPart.AddImagePart(oldPart.ContentType);
                    temp.ResourceID = newDoc.MainDocumentPart.GetIdOfPart(newPart);
                    temp.WriteImage(newPart);
                }
                imageReference.Attribute(ns_r + "embed").Value = temp.ResourceID;
            }
        }
        private static void CopyNumbering(WordprocessingDocument oldDoc, WordprocessingDocument newDoc, IEnumerable<XElement> paragraphs)
        {
            int number = 1;
            int abstractNumber = 0;
            XDocument oldNumbering = null;
            XDocument newNumbering = null;
            foreach (XElement numReference in paragraphs.Descendants(ns + "numPr"))
            {
                XElement idElement = numReference.Descendants(ns + "numId").FirstOrDefault();
                if (idElement != null)
                {
                    if (oldNumbering == null)
                        oldNumbering = oldDoc.MainDocumentPart.NumberingDefinitionsPart.GetXDocument();
                    if (newNumbering == null)
                    {
                        if (newDoc.MainDocumentPart.NumberingDefinitionsPart != null)
                        {
                            newNumbering = newDoc.MainDocumentPart.NumberingDefinitionsPart.GetXDocument();
                            var numIds = newNumbering.Root.Elements(ns + "num").Select(f => (int)f.Attribute(ns + "numId"));
                            if (numIds.Any())
                                number = numIds.Max() + 1;
                            numIds = newNumbering.Root.Elements(ns + "abstractNum").Select(f => (int)f.Attribute(ns + "abstractNumId"));
                            if (numIds.Any())
                                abstractNumber = numIds.Max() + 1;
                        }
                        else
                        {
                            newDoc.MainDocumentPart.AddNewPart<NumberingDefinitionsPart>();
                            newNumbering = newDoc.MainDocumentPart.NumberingDefinitionsPart.GetXDocument();
                            newNumbering.Add(new XElement(ns + "numbering", ns_attrs));
                        }
                    }
                    string numId = idElement.Attribute(ns + "val").Value;
                    if (numId != "0")
                    {
                        XElement element = oldNumbering.Descendants().Elements(ns + "num").Where(p => ((string)p.Attribute(ns + "numId")) == numId).First();

                        // Copy abstract numbering element, if necessary (use matching NSID)
                        string abstractNumId = element.Elements(ns + "abstractNumId").First().Attribute(ns + "val").Value;
                        XElement abstractElement = oldNumbering.Descendants().Elements(ns + "abstractNum").Where(p => ((string)p.Attribute(ns + "abstractNumId")) == abstractNumId).First();
                        string abstractNSID = abstractElement.Elements(ns + "nsid").First().Attribute(ns + "val").Value;
                        XElement newAbstractElement = newNumbering.Descendants().Elements(ns + "abstractNum").Where(p => ((string)p.Elements(ns + "nsid").First().Attribute(ns + "val")) == abstractNSID).FirstOrDefault();
                        if (newAbstractElement == null)
                        {
                            newAbstractElement = new XElement(abstractElement);
                            newAbstractElement.Attribute(ns + "abstractNumId").Value = abstractNumber.ToString();
                            abstractNumber++;
                            if (newNumbering.Root.Elements(ns + "abstractNum").Any())
                                newNumbering.Root.Elements(ns + "abstractNum").Last().AddAfterSelf(newAbstractElement);
                            else
                                newNumbering.Root.Add(newAbstractElement);
                        }
                        string newAbstractId = newAbstractElement.Attribute(ns + "abstractNumId").Value;

                        // Copy numbering element, if necessary (use matching element with no overrides)
                        XElement newElement = null;
                        if (!element.Elements(ns + "lvlOverride").Any())
                            newElement = newNumbering.Descendants().Elements(ns + "num").Where(p => !p.Elements(ns + "lvlOverride").Any() && ((string)p.Elements(ns + "abstractNumId").First().Attribute(ns + "val")) == newAbstractId).FirstOrDefault();
                        if (newElement == null)
                        {
                            newElement = new XElement(element);
                            newElement.Elements(ns + "abstractNumId").First().Attribute(ns + "val").Value = newAbstractId;
                            newElement.Attribute(ns + "numId").Value = number.ToString();
                            number++;
                            newNumbering.Root.Add(newElement);
                        }
                        idElement.Attribute(ns + "val").Value = newElement.Attribute(ns + "numId").Value;
                    }
                }
            }
        }
        private static void CopyDiagrams(WordprocessingDocument oldDoc, WordprocessingDocument newDoc, IEnumerable<XElement> paragraphs)
        {
            foreach (XElement diagramReference in paragraphs.Descendants(ns_dgm + "relIds"))
            {
                // dm attribute
                string relId = diagramReference.Attribute(ns_r + "dm").Value;
                OpenXmlPart oldPart = oldDoc.MainDocumentPart.GetPartById(relId);
                OpenXmlPart newPart = newDoc.MainDocumentPart.AddNewPart<DiagramDataPart>();
                newPart.GetXDocument().Add(oldPart.GetXDocument().Root);
                diagramReference.Attribute(ns_r + "dm").Value = newDoc.MainDocumentPart.GetIdOfPart(newPart);

                // lo attribute
                relId = diagramReference.Attribute(ns_r + "lo").Value;
                oldPart = oldDoc.MainDocumentPart.GetPartById(relId);
                newPart = newDoc.MainDocumentPart.AddNewPart<DiagramLayoutDefinitionPart>();
                newPart.GetXDocument().Add(oldPart.GetXDocument().Root);
                diagramReference.Attribute(ns_r + "lo").Value = newDoc.MainDocumentPart.GetIdOfPart(newPart);

                // qs attribute
                relId = diagramReference.Attribute(ns_r + "qs").Value;
                oldPart = oldDoc.MainDocumentPart.GetPartById(relId);
                newPart = newDoc.MainDocumentPart.AddNewPart<DiagramStylePart>();
                newPart.GetXDocument().Add(oldPart.GetXDocument().Root);
                diagramReference.Attribute(ns_r + "qs").Value = newDoc.MainDocumentPart.GetIdOfPart(newPart);

                // cs attribute
                relId = diagramReference.Attribute(ns_r + "cs").Value;
                oldPart = oldDoc.MainDocumentPart.GetPartById(relId);
                newPart = newDoc.MainDocumentPart.AddNewPart<DiagramColorsPart>();
                newPart.GetXDocument().Add(oldPart.GetXDocument().Root);
                diagramReference.Attribute(ns_r + "cs").Value = newDoc.MainDocumentPart.GetIdOfPart(newPart);
            }
        }
        private static void CopyShapes(WordprocessingDocument oldDoc, WordprocessingDocument newDoc, IEnumerable<XElement> paragraphs, List<ImageData> images)
        {
            foreach (XElement shapeReference in paragraphs.Descendants(ns_v + "imagedata"))
            {
                string relId = shapeReference.Attribute(ns_r + "id").Value;
                ImagePart oldPart = (ImagePart)oldDoc.MainDocumentPart.GetPartById(relId);
                ImageData temp = ManageImageCopy(oldPart, images);
                if (temp.ResourceID == null)
                {
                    ImagePart newPart = newDoc.MainDocumentPart.AddImagePart(oldPart.ContentType);
                    temp.ResourceID = newDoc.MainDocumentPart.GetIdOfPart(newPart);
                    temp.WriteImage(newPart);
                }
                shapeReference.Attribute(ns_r + "id").Value = temp.ResourceID;
            }
        }
        private static void CopyCustomXml(WordprocessingDocument oldDoc, WordprocessingDocument newDoc, IEnumerable<XElement> paragraphs)
        {
            List<string> itemList = new List<string>();
            foreach (string itemId in paragraphs.Descendants(ns + "dataBinding").Select(e => e.Attribute(ns + "storeItemID").Value))
                if (!itemList.Contains(itemId))
                    itemList.Add(itemId);
            foreach (CustomXmlPart customXmlPart in oldDoc.MainDocumentPart.CustomXmlParts)
            {
                OpenXmlPart propertyPart = customXmlPart.Parts.Select(p => p.OpenXmlPart).Where(p => (p.ContentType == "application/vnd.openxmlformats-officedocument.customXmlProperties+xml")).First();
                XDocument propertyPartDoc = propertyPart.GetXDocument();
                if (itemList.Contains(propertyPartDoc.Root.Attribute(ns_ds + "itemID").Value))
                {
                    CustomXmlPart newPart = newDoc.MainDocumentPart.AddCustomXmlPart(customXmlPart.ContentType);
                    newPart.GetXDocument().Add(customXmlPart.GetXDocument().Root);
                    foreach (OpenXmlPart propPart in customXmlPart.Parts.Select(p => p.OpenXmlPart))
                    {
                        CustomXmlPropertiesPart newPropPart = newPart.AddNewPart<CustomXmlPropertiesPart>();
                        newPropPart.GetXDocument().Add(propPart.GetXDocument().Root);
                    }
                }
            }
        }
        private static void CopyEmbeddedObjects(WordprocessingDocument oldDoc, WordprocessingDocument newDoc, IEnumerable<XElement> paragraphs)
        {
            foreach (XElement oleReference in paragraphs.Descendants(ns_o + "OLEObject"))
            {
                string relId = oleReference.Attribute(ns_r + "id").Value;
                OpenXmlPart oldPart = oldDoc.MainDocumentPart.GetPartById(relId);
                OpenXmlPart newPart = newDoc.MainDocumentPart.AddEmbeddedObjectPart(oldPart.ContentType);
                using (Stream oldObject = oldPart.GetStream(FileMode.Open, FileAccess.Read))
                using (Stream newObject = newPart.GetStream(FileMode.Create, FileAccess.ReadWrite))
                {
                    int byteCount;
                    byte[] buffer = new byte[65536];
                    while ((byteCount = oldObject.Read(buffer, 0, 65536)) != 0)
                        newObject.Write(buffer, 0, byteCount);
                }
                oleReference.Attribute(ns_r + "id").Value = newDoc.MainDocumentPart.GetIdOfPart(newPart);
            }
        }
        private static void CopyCharts(WordprocessingDocument oldDoc, WordprocessingDocument newDoc, IEnumerable<XElement> paragraphs)
        {
            foreach (XElement chartReference in paragraphs.Descendants(ns_c + "chart"))
            {
                string relId = chartReference.Attribute(ns_r + "id").Value;
                ChartPart oldPart = (ChartPart)oldDoc.MainDocumentPart.GetPartById(relId);
                XDocument oldChart = oldPart.GetXDocument();
                ChartPart newPart = newDoc.MainDocumentPart.AddNewPart<ChartPart>();
                XDocument newChart = newPart.GetXDocument();
                newChart.Add(oldChart.Root);
                chartReference.Attribute(ns_r + "id").Value = newDoc.MainDocumentPart.GetIdOfPart(newPart);
                CopyChartObjects(oldPart, newPart);
            }
        }
        private static void CopyChartObjects(ChartPart oldChart, ChartPart newChart)
        {
            foreach (XElement dataReference in newChart.GetXDocument().Descendants(ns_c + "externalData"))
            {
                string relId = dataReference.Attribute(ns_r + "id").Value;
                EmbeddedPackagePart oldPart = (EmbeddedPackagePart)oldChart.GetPartById(relId);
                EmbeddedPackagePart newPart = newChart.AddEmbeddedPackagePart(oldPart.ContentType);
                using (Stream oldObject = oldPart.GetStream(FileMode.Open, FileAccess.Read))
                using (Stream newObject = newPart.GetStream(FileMode.Create, FileAccess.ReadWrite))
                {
                    int byteCount;
                    byte[] buffer = new byte[65536];
                    while ((byteCount = oldObject.Read(buffer, 0, 65536)) != 0)
                        newObject.Write(buffer, 0, byteCount);
                }
                dataReference.Attribute(ns_r + "id").Value = newChart.GetIdOfPart(newPart);
            }
        }

        // General function for handling images that tries to use an existing image if they are the same
        private static ImageData ManageImageCopy(ImagePart oldImage, List<ImageData> images)
        {
            ImageData oldImageData = new ImageData(oldImage);
            foreach (ImageData item in images)
            {
                if (item.Compare(oldImageData))
                    return item;
            }
            images.Add(oldImageData);
            return oldImageData;
        }
    }
}
