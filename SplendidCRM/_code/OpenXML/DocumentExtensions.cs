/***************************************************************************

Copyright (c) Microsoft Corporation 2009.

This code is licensed using the Microsoft Public License (Ms-PL).  The text of the license can be found here:

http://www.microsoft.com/resources/sharedsource/licensingbasics/publiclicense.mspx

***************************************************************************/

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml;
using System.Xml.Linq;
using DocumentFormat.OpenXml.Packaging;

namespace OpenXml.PowerTools
{
    /// <summary>
    /// DocumentExtensions contains functions to manage the creation, reading and writing of XDocument objects
    /// that come from an OpenXmlPackage
    /// </summary>
    public static class DocumentExtensions
    {
        // Used to track changes to parts
        private class ChangedSemaphore { }
        private static EventHandler<XObjectChangeEventArgs> ElementChanged = new EventHandler<XObjectChangeEventArgs>(ElementChangedHandler);

        /// <summary>
        /// Gets the XDocument for a part	
        /// </summary>
        public static XDocument GetXDocument(this OpenXmlPart part)
        {
            XDocument xdoc = part.Annotation<XDocument>();
            if (xdoc != null)
                return xdoc;
            try
            {
                using (StreamReader sr = new StreamReader(part.GetStream()))
                using (XmlReader xr = XmlReader.Create(sr))
                {
                    xdoc = XDocument.Load(xr);
                    xdoc.Changed += ElementChanged;
                    xdoc.Changing += ElementChanged;
                }
            }
            catch (XmlException)
            {
                xdoc = new XDocument();
                xdoc.AddAnnotation(new ChangedSemaphore());
            }
            part.AddAnnotation(xdoc);
            return xdoc;
        }
        private static void ElementChangedHandler(object sender, XObjectChangeEventArgs e)
        {
            XDocument xDocument = ((XObject)sender).Document;
            if (xDocument != null)
            {
                xDocument.Changing -= ElementChanged;
                xDocument.Changed -= ElementChanged;
                xDocument.AddAnnotation(new ChangedSemaphore());
            }
        }

        /// <summary>
        /// Writes out all XDocuments	
        /// </summary>
        public static void FlushParts(this OpenXmlPackage doc)
        {
            HashSet<OpenXmlPart> visited = new HashSet<OpenXmlPart>();
            foreach (IdPartPair item in doc.Parts)
                FlushPart(item.OpenXmlPart, visited);
        }
        private static void FlushPart(OpenXmlPart part, HashSet<OpenXmlPart> visited)
        {
            visited.Add(part);
            XDocument xdoc = part.Annotation<XDocument>();
            if (xdoc != null && xdoc.Annotation<ChangedSemaphore>() != null)
            {
                using (XmlWriter xw = XmlWriter.Create(part.GetStream(FileMode.Create, FileAccess.Write)))
                {
                    xdoc.Save(xw);
                }
                xdoc.RemoveAnnotations<ChangedSemaphore>();
                xdoc.Changing += ElementChanged;
                xdoc.Changed += ElementChanged;
            }
            foreach (IdPartPair item in part.Parts)
                if (!visited.Contains(item.OpenXmlPart))
                    FlushPart(item.OpenXmlPart, visited);
        }
    }
}