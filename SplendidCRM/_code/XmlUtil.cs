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
using System.Web;
using System.Xml;
using System.Text;
using System.Globalization;
using System.Diagnostics;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for XmlUtil.
	/// </summary>
	public class XmlUtil
	{
		public static DataTable CreateDataTable(XmlNode parent, string sTableName, string sPrimaryKey, string[] asColumns)
		{
			DataTable dt = new DataTable(sTableName);
			dt.Columns.Add(sPrimaryKey);
			foreach(string sColumn in asColumns)
			{
				dt.Columns.Add(sColumn);
			}
			if ( parent != null )
			{
				XmlNodeList nl = parent.SelectNodes(sTableName);
				if ( nl != null )
				{
					foreach(XmlNode node in nl)
					{
						DataRow row = dt.NewRow();
						dt.Rows.Add(row);
						try
						{
							row[sPrimaryKey] = node.Attributes.GetNamedItem(sPrimaryKey).Value;
						}
						catch(Exception ex)
						{
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						}
						foreach(string sColumn in asColumns)
						{
							row[sColumn] = XmlUtil.SelectSingleNode(node, sColumn);
						}
					}
				}
			}
			return dt;
		}

		public static DataTable CreateDataTable(XmlNode parent, string sTableName, string[] asColumns)
		{
			DataTable dt = new DataTable(sTableName);
			foreach(string sColumn in asColumns)
			{
				dt.Columns.Add(sColumn);
			}
			if ( parent != null )
			{
				XmlNodeList nl = parent.SelectNodes(sTableName);
				if ( nl != null )
				{
					foreach(XmlNode node in nl)
					{
						DataRow row = dt.NewRow();
						dt.Rows.Add(row);
						foreach(string sColumn in asColumns)
						{
							row[sColumn] = XmlUtil.SelectSingleNode(node, sColumn);
						}
					}
				}
			}
			return dt;
		}

		public static void RemoveAllChildren(XmlDocument xml, string sNode)
		{
			try
			{
				XmlNode node   = null;
				XmlNode parent = xml.DocumentElement;
				string[] aNode = sNode.Split('/');
				foreach ( string sNodePart in aNode )
				{
					node = parent.SelectSingleNode(sNodePart);
					if ( node == null )
					{
						return ;
					}
					parent = node;
				}
				if ( node != null )
				{
					node.RemoveAll();
				}
			}
			catch(Exception /* ex */)
			{
			}
		}

		public static string SelectSingleNode(XmlDocument xml, string sNode)
		{
			try
			{
				if ( xml.DocumentElement != null )
				{
					XmlNode node = xml.DocumentElement.SelectSingleNode(sNode);
					if ( node != null )
					{
						return node.InnerText;
					}
				}
			}
			catch(Exception /* ex */)
			{
			}
			return String.Empty;
		}

		public static string GetNamedItem(XmlNode xNode, string sAttribute)
		{
			string sValue = String.Empty;
			XmlNode xValue = xNode.Attributes.GetNamedItem(sAttribute);
			if ( xValue != null )
				sValue = xValue.Value;
			return sValue;
		}

		public static string SelectSingleNode(XmlDocument xml, string sNode, XmlNamespaceManager nsmgr)
		{
			try
			{
				if ( xml.DocumentElement != null )
				{
					// 06/20/2006 Paul.  The default namespace cannot be selected, so create an alias and reference the alias. 
					if ( sNode.IndexOf(':') < 0 )
						sNode = "defaultns:" + sNode;
					XmlNode node = xml.DocumentElement.SelectSingleNode(sNode, nsmgr);
					if ( node != null )
					{
						return node.InnerText;
					}
				}
			}
			catch(Exception /* ex */)
			{
			}
			return String.Empty;
		}

		public static string SelectSingleNode(XmlDocument xml, string sNode, string sDefault)
		{
			try
			{
				if ( xml.DocumentElement != null )
				{
					XmlNode node = xml.DocumentElement.SelectSingleNode(sNode);
					if ( node != null )
					{
						if ( !Sql.IsEmptyString(node.InnerText) )
							return node.InnerText;
					}
				}
			}
			catch(Exception /* ex */)
			{
			}
			return sDefault;
		}

		public static string SelectSingleNode(XmlNode node, string sNode)
		{
			try
			{
				if ( node != null )
				{
					node = node.SelectSingleNode(sNode);
					if ( node != null )
					{
						return node.InnerText;
					}
				}
			}
			catch(Exception /* ex */)
			{
			}
			return String.Empty;
		}

		// 03/29/2008 Paul.  We need a safe way to get the attribute. 
		public static string SelectAttribute(XmlNode parent, string sNode, string sAttribute)
		{
			try
			{
				if ( parent != null )
				{
					XmlNode node = parent.SelectSingleNode(sNode);
					if ( node != null )
					{
						XmlNode attr = node.Attributes.GetNamedItem(sAttribute);
						if ( attr != null )
							return attr.Value;
					}
				}
			}
			catch(Exception /* ex */)
			{
			}
			return String.Empty;
		}

		public static string SelectAttribute(XmlNode node, string sAttribute)
		{
			try
			{
				if ( node != null )
				{
					XmlNode attr = node.Attributes.GetNamedItem(sAttribute);
					if ( attr != null )
						return attr.Value;
				}
			}
			catch(Exception /* ex */)
			{
			}
			return String.Empty;
		}

		public static string SelectSingleNode(XmlNode parent, string sNode, XmlNamespaceManager nsmgr)
		{
			try
			{
				if ( parent != null )
				{
					XmlNode node = null;
					// 10/24/2007 Paul.  We need to support multiple tags. 
					string[] aNode = sNode.Split('/');
					int i = 0;
					for ( i=0; i < aNode.Length; i++ )
					{
						string sNodeNS = aNode[i];
						if ( sNodeNS.IndexOf(':') < 0 )
							sNodeNS = "defaultns:" + sNodeNS;
						node = parent.SelectSingleNode(sNodeNS, nsmgr);
						if ( node == null )
						{
							return null;
						}
						parent = node;
					}
					if ( node != null )
					{
						return node.InnerText;
					}
				}
			}
			catch(Exception /* ex */)
			{
			}
			return String.Empty;
		}

		public static XmlNode SelectNode(XmlDocument xml, string sNode, XmlNamespaceManager nsmgr)
		{
			try
			{
				XmlNode node = xml.SelectSingleNode(sNode, nsmgr);
				if ( node == null )
				{
					XmlNode parent = xml.DocumentElement;
					string[] aNode = sNode.Split('/');
					int i = 0;
					for ( i=0; i < aNode.Length; i++ )
					{
						// 06/20/2006 Paul.  The default namespace cannot be selected, so create an alias and reference the alias. 
						string sNodeNS = aNode[i];
						if ( sNodeNS.IndexOf(':') < 0 )
							sNodeNS = "defaultns:" + sNodeNS;
						node = parent.SelectSingleNode(sNodeNS, nsmgr);
						if ( node == null )
						{
							return null;
						}
						parent = node;
					}
					if ( i == aNode.Length )
						return parent;
				}
			}
			catch(Exception ex)
			{
				Debug.WriteLine(ex.Message);
			}
			return null;
		}

		public static XmlNode SelectNode(XmlNode parent, string sNode, XmlNamespaceManager nsmgr)
		{
			try
			{
				XmlNode node = null;
				string[] aNode = sNode.Split('/');
				int i = 0;
				for ( i=0; i < aNode.Length; i++ )
				{
					// 06/20/2006 Paul.  The default namespace cannot be selected, so create an alias and reference the alias. 
					string sNodeNS = aNode[i];
					if ( sNodeNS.IndexOf(':') < 0 )
						sNodeNS = "defaultns:" + sNodeNS;
					node = parent.SelectSingleNode(sNodeNS, nsmgr);
					if ( node == null )
					{
						return null;
					}
					parent = node;
				}
				if ( i == aNode.Length )
					return node;
			}
			catch(Exception ex)
			{
				Debug.WriteLine(ex.Message);
			}
			return null;
		}

		public static void SetSingleNode(XmlDocument xml, string sNode, string sValue)
		{
			try
			{
				XmlNode node = xml.SelectSingleNode(sNode);
				if ( node == null )
				{
					XmlNode parent = xml.DocumentElement;
					string[] aNode = sNode.Split('/');
					foreach ( string sNodePart in aNode )
					{
						node = parent.SelectSingleNode(sNodePart);
						if ( node == null )
						{
							node = xml.CreateElement(sNodePart);
							parent.AppendChild(node);
						}
						parent = node;
					}
				}
				node.InnerText = sValue;
			}
			catch(Exception ex)
			{
				Debug.WriteLine(ex.Message);
			}
		}

		public static void SetSingleNode(XmlDocument xml, string sNode, string sValue, XmlNamespaceManager nsmgr, string sNamespaceURI)
		{
			try
			{
				XmlNode node = xml.SelectSingleNode(sNode, nsmgr);
				if ( node == null )
				{
					XmlNode parent = xml.DocumentElement;
					string[] aNode = sNode.Split('/');
					foreach ( string sNodePart in aNode )
					{
						string sNodeNS = sNodePart;
						// 06/20/2006 Paul.  The default namespace cannot be selected, so create an alias and reference the alias. 
						if ( sNodeNS.IndexOf(':') < 0 )
							sNodeNS = "defaultns:" + sNodeNS;
						node = parent.SelectSingleNode(sNodeNS, nsmgr);
						if ( node == null )
						{
							node = xml.CreateElement(sNodePart, sNamespaceURI);
							parent.AppendChild(node);
						}
						parent = node;
					}
				}
				node.InnerText = sValue;
			}
			catch(Exception ex)
			{
				Debug.WriteLine(ex.Message);
			}
		}

		// 11/20/2011 Paul.  Charting needs a way to skip updating if value exists. 
		public static void SetSingleNode_InsertOnly(XmlDocument xml, string sNode, string sValue, XmlNamespaceManager nsmgr, string sNamespaceURI)
		{
			try
			{
				XmlNode node = xml.SelectSingleNode(sNode, nsmgr);
				if ( node == null )
				{
					XmlNode parent = xml.DocumentElement;
					string[] aNode = sNode.Split('/');
					foreach ( string sNodePart in aNode )
					{
						string sNodeNS = sNodePart;
						// 06/20/2006 Paul.  The default namespace cannot be selected, so create an alias and reference the alias. 
						if ( sNodeNS.IndexOf(':') < 0 )
							sNodeNS = "defaultns:" + sNodeNS;
						node = parent.SelectSingleNode(sNodeNS, nsmgr);
						if ( node == null )
						{
							node = xml.CreateElement(sNodePart, sNamespaceURI);
							parent.AppendChild(node);
						}
						parent = node;
					}
				}
				if ( Sql.IsEmptyString(node.InnerText) )
					node.InnerText = sValue;
			}
			catch(Exception ex)
			{
				Debug.WriteLine(ex.Message);
			}
		}

		public static void SetSingleNodeAttribute(XmlDocument xml, string sNode, string sAttribute, string sValue)
		{
			try
			{
				XmlNode node = xml.SelectSingleNode(sNode);
				if ( node == null )
				{
					XmlNode parent = xml.DocumentElement;
					string[] aNode = sNode.Split('/');
					foreach ( string sNodePart in aNode )
					{
						node = parent.SelectSingleNode(sNodePart);
						if ( node == null )
						{
							node = xml.CreateElement(sNodePart);
							parent.AppendChild(node);
						}
						parent = node;
					}
				}
				XmlAttribute attr = xml.CreateAttribute(sAttribute);
				attr.Value = sValue;
				node.Attributes.SetNamedItem(attr);
			}
			catch(Exception /* ex */)
			{
			}
		}

		public static void SetSingleNodeAttribute(XmlDocument xml, string sNode, string sAttribute, string sValue, XmlNamespaceManager nsmgr, string sNamespaceURI)
		{
			try
			{
				XmlNode node = xml.SelectSingleNode(sNode, nsmgr);
				if ( node == null )
				{
					XmlNode parent = xml.DocumentElement;
					string[] aNode = sNode.Split('/');
					foreach ( string sNodePart in aNode )
					{
						string sNodeNS = sNodePart;
						// 06/20/2006 Paul.  The default namespace cannot be selected, so create an alias and reference the alias. 
						if ( sNodeNS.IndexOf(':') < 0 )
							sNodeNS = "defaultns:" + sNodeNS;
						node = parent.SelectSingleNode(sNodeNS, nsmgr);
						if ( node == null )
						{
							node = xml.CreateElement(sNodePart, sNamespaceURI);
							parent.AppendChild(node);
						}
						parent = node;
					}
				}
				XmlAttribute attr = xml.CreateAttribute(sAttribute);
				attr.Value = sValue;
				node.Attributes.SetNamedItem(attr);
			}
			catch(Exception /* ex */)
			{
			}
		}

		public static void SetSingleNodeAttribute(XmlDocument xml, XmlNode parent, string sAttribute, string sValue)
		{
			try
			{
				XmlAttribute attr = xml.CreateAttribute(sAttribute);
				attr.Value = sValue;
				parent.Attributes.SetNamedItem(attr);
			}
			catch(Exception /* ex */)
			{
			}
		}

		public static void SetSingleNodeAttribute(XmlDocument xml, XmlNode parent, string sAttribute, string sValue, XmlNamespaceManager nsmgr, string sNamespaceURI)
		{
			try
			{
				XmlAttribute attr = xml.CreateAttribute(sAttribute);
				attr.Value = sValue;
				parent.Attributes.SetNamedItem(attr);
			}
			catch(Exception /* ex */)
			{
			}
		}

		// 12/10/2009 Paul.  We need to be able to set the attribute with a prefix. 
		public static void SetSingleNodeAttribute(XmlDocument xml, XmlNode parent, string prefix, string sAttribute, string sValue, XmlNamespaceManager nsmgr, string sNamespaceURI)
		{
			try
			{
				XmlAttribute attr = xml.CreateAttribute(prefix, sAttribute, sNamespaceURI);
				attr.Value = sValue;
				parent.Attributes.SetNamedItem(attr);
			}
			catch(Exception /* ex */)
			{
			}
		}

		public static void SetSingleNode(XmlDocument xml, XmlNode parent, string sNode, string sValue)
		{
			try
			{
				XmlNode node = xml.SelectSingleNode(sNode);
				if ( node == null )
				{
					string[] aNode = sNode.Split('/');
					foreach ( string sNodePart in aNode )
					{
						node = parent.SelectSingleNode(sNodePart);
						if ( node == null )
						{
							node = xml.CreateElement(sNodePart);
							parent.AppendChild(node);
						}
						parent = node;
					}
				}
				node.InnerText = sValue;
			}
			catch(Exception /* ex */)
			{
			}
		}

		public static void SetSingleNode(XmlDocument xml, XmlNode parent, string sNode, string sValue, XmlNamespaceManager nsmgr, string sNamespaceURI)
		{
			try
			{
				XmlNode node = xml.SelectSingleNode(sNode, nsmgr);
				if ( node == null )
				{
					string[] aNode = sNode.Split('/');
					foreach ( string sNodePart in aNode )
					{
						string sNodeNS = sNodePart;
						// 06/20/2006 Paul.  The default namespace cannot be selected, so create an alias and reference the alias. 
						if ( sNodeNS.IndexOf(':') < 0 )
							sNodeNS = "defaultns:" + sNodeNS;
						node = parent.SelectSingleNode(sNodeNS, nsmgr);
						if ( node == null )
						{
							node = xml.CreateElement(sNodePart, sNamespaceURI);
							parent.AppendChild(node);
						}
						parent = node;
					}
				}
				node.InnerText = sValue;
			}
			catch(Exception /* ex */)
			{
			}
		}

		public static void AppendNode(XmlDocument xml, XmlNode parent, string sNode, string sValue, XmlNamespaceManager nsmgr, string sNamespaceURI)
		{
			try
			{
				XmlNode node = null;
				string[] aNode = sNode.Split('/');
				foreach ( string sNodePart in aNode )
				{
					node = xml.CreateElement(sNodePart, sNamespaceURI);
					parent.AppendChild(node);
					parent = node;
				}
				node.InnerText = sValue;
			}
			catch(Exception /* ex */)
			{
			}
		}

		public static void Dump(ref StringBuilder sb, string sIndent, XmlNode parent)
		{
			if ( parent == null )
				return;
			sb.Append(sIndent + "<" + parent.Name);
			if ( parent.Attributes != null )
			{
				foreach ( XmlAttribute attr in parent.Attributes )
				{
					sb.Append(" "  + attr.Name  + "=");
					sb.Append("\"" + attr.Value + "\""); // TODO: encode the value.  
				}
			}
			if ( parent.HasChildNodes )
			{
				if ( parent.ChildNodes.Count == 1 && parent.ChildNodes[0].NodeType == XmlNodeType.Text )
				{
					XmlNode child = parent.ChildNodes[0];
					if ( child.Value != String.Empty )
					{
						// 10/12/2006 Paul.  Reduce the XML dump. 
						if ( child.Value.IndexOf(' ') > 0 )
						{
							sb.AppendLine(">");
							// 07/15/2010 Paul.  Use tab to make it easier to format. 
							sb.AppendLine(sIndent + "\t" + child.Value);
							sb.AppendLine(sIndent + "</" + parent.Name + ">");
						}
						else
						{
							sb.AppendLine(">" + child.Value + "</" + parent.Name + ">");
						}
					}
					else
					{
						sb.AppendLine(" />");
					}
				}
				else
				{
					sb.AppendLine(">");
					foreach ( XmlNode child in parent.ChildNodes )
					{
						if ( child.NodeType == XmlNodeType.Text )
						{
							if ( child.Value != String.Empty )
							{
								// 07/15/2010 Paul.  Use tab to make it easier to format. 
								sb.AppendLine(sIndent + "\t" + child.Value);
							}
						}
						else
						{
							// 07/15/2010 Paul.  Use tab to make it easier to format. 
							Dump(ref sb, sIndent + "\t", child);
						}
					}
					sb.AppendLine(sIndent + "</" + parent.Name + ">");
				}
			}
			else
			{
				sb.AppendLine(" />");
			}
		}

		public static void Dump(XmlDocument xml)
		{
			StringBuilder sb = new StringBuilder();
			if ( xml != null && xml.DocumentElement != null)
				Dump(ref sb, "", xml.DocumentElement);
			string sDump = HttpContext.Current.Server.HtmlEncode(sb.ToString());
			HttpContext.Current.Response.Write("<pre><font face='courier new'>");
			HttpContext.Current.Response.Write(sDump);
			HttpContext.Current.Response.Write("</font></pre>");
		}

		public static string BaseTypeXPath(object o)
		{
			return o.GetType().BaseType.ToString().Replace(".", "/");
		}

		private static string PHPString(MemoryStream mem)
		{
			string sSize   = String.Empty;
			string sString = String.Empty;
			int nMode = 0;
			int nChar = mem.ReadByte();
			while ( nChar != -1 )
			{
				char ch = Convert.ToChar(nChar);
				switch ( nMode )
				{
					case 0:  // Looking for ':'
						if ( ch == ':' )
							nMode = 1;
						break;
					case 1:  // Looking for a number
						if ( Char.IsDigit(ch) )
							sSize += ch;
						else if ( ch == ':' )
							nMode = 2;
						break;
					case 2: // Read string
					{
						int nSize = Int32.Parse(sSize);
						for ( int i = 0 ; i < (nSize+2) && nChar != -1 ; i++ )
						{
							if ( !(ch == '\"' && (i == 0 || i == nSize + 1)) )
								sString += ch;
							nChar = mem.ReadByte();
							if ( nChar != -1 )
								ch = Convert.ToChar(nChar);
						}
						if ( nChar != -1 && ch == ';' )
							return sString;
						nMode = 3;
						break;
					}
					case 3: // Expecting ';'
						if ( ch == ';' )
							return sString;
						break;
				}
				nChar = mem.ReadByte();
			}
			return sString;
		}

		private static string PHPInteger(MemoryStream mem)
		{
			string sNumber = String.Empty;
			int nMode = 0;
			int nChar = mem.ReadByte();
			while ( nChar != -1 )
			{
				char ch = Convert.ToChar(nChar);
				switch ( nMode )
				{
					case 0:  // Looking for ':'
						if ( ch == ':' )
							nMode = 1;
						break;
					case 1:  // Looking for a number
						if ( Char.IsDigit(ch) )
							sNumber += ch;
						else if ( ch == ';' )
						{
							return sNumber;
						}
						break;
				}
				nChar = mem.ReadByte();
			}
			return sNumber;
		}

		private static void PHPArray(XmlDocument xml, XmlElement parent, MemoryStream mem)
		{
			string sSize = String.Empty;
			string sNAME  = String.Empty;
			string sVALUE = String.Empty;
			int nChar = mem.ReadByte();
			// Skip past size and get to the begging of the array. 
			while ( nChar != -1 && Convert.ToChar(nChar) != '{' )
			{
				nChar = mem.ReadByte();
			}
			if ( nChar == -1 )
				return ;

			int nMode = 0;
			nChar = mem.ReadByte();
			while ( nChar != -1 )
			{
				char ch = Convert.ToChar(nChar);
				switch ( nMode )
				{
					case 0:  // Looking for "s" at the start of the variable. 
						if ( ch == 's' )
						{
							sNAME = PHPString(mem);
							nMode = 1;
						}
						else if ( ch == 'i' )
						{
							sNAME = PHPInteger(mem);
							XmlAttribute attr = xml.CreateAttribute("index_array");
							attr.Value = "true";
							parent.Attributes.SetNamedItem(attr);
							nMode = 2;
						}
						else if ( ch == '}' )
						{
							// End of the array was reached. 
							return;
						}
						break;
					case 1: // Read variable data type
						if ( ch == 's' )
						{
							sVALUE = PHPString(mem);
							XmlUtil.SetSingleNode(xml, parent, sNAME, sVALUE);
							nMode = 0;
						}
						else if ( ch == 'i' )
						{
							sVALUE = PHPInteger(mem);
							XmlUtil.SetSingleNode(xml, parent, sNAME, sVALUE);
							nMode = 0;
						}
						else if ( ch == 'a' )
						{
							XmlElement node = xml.CreateElement(sNAME);
							parent.AppendChild(node);
							PHPArray(xml, node, mem);
							nMode = 0;
						}
						break;
					case 2: // Index array values. 
						if ( ch == 's' )
						{
							sVALUE = PHPString(mem);
							XmlUtil.SetSingleNode(xml, parent, "index_" + sNAME, sVALUE);
							nMode = 0;
						}
						else if ( ch == 'i' )
						{
							sVALUE = PHPInteger(mem);
							XmlUtil.SetSingleNode(xml, parent, "index_" + sNAME, sVALUE);
							nMode = 0;
						}
						break;
				}
				nChar = mem.ReadByte();
			}
		}

		public static string ConvertFromPHP(string sPHP)
		{
			XmlDocument xml = new XmlDocument();
			xml.AppendChild(xml.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
			xml.AppendChild(xml.CreateElement("USER_PREFERENCE"));
			try
			{
				// 01/28/2009 Paul.  Check for empty string before attempting to convert. 
				if ( !Sql.IsEmptyString(sPHP) )
				{
					byte[] abyPHP = Convert.FromBase64String(sPHP);
					StringBuilder sb = new StringBuilder();
					foreach(char by in abyPHP)
						sb.Append(by);
					MemoryStream mem = new MemoryStream(abyPHP);

					string sSize = String.Empty;
					int nChar = mem.ReadByte();
					while ( nChar != -1 )
					{
						char ch = Convert.ToChar(nChar);
						if ( ch == 'a' )
							PHPArray(xml, xml.DocumentElement, mem);
						else if ( ch == 's' )
							PHPString(mem);
						else if ( ch == 'i' )
							PHPInteger(mem);
						nChar = mem.ReadByte();
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
			}
			return xml.OuterXml;
		}

		public static string ConvertToPHP(XmlElement parent)
		{
			StringBuilder sb = new StringBuilder();
			if ( parent.ChildNodes.Count > 1 )
			{
				sb.Append("s:" + parent.Name.Length.ToString() + ":\"" + parent.Name + "\";");
				sb.Append("a:" + parent.ChildNodes.Count.ToString() + "{");
				if ( Sql.ToBoolean(parent.GetAttribute("index_array")) )
				{
					int i = 0;
					foreach(XmlElement node in parent.ChildNodes)
					{
						sb.Append("i:" + i.ToString() + ";");
						sb.Append("s:" + node.InnerText.Length.ToString() + ":\"" + node.InnerText + "\";");
						i++;
					}
				}
				else
				{
					foreach(XmlElement node in parent.ChildNodes)
					{
						sb.Append(ConvertToPHP(node));
					}
				}
				sb.Append("}");
			}
			else
			{
				sb.Append("s:" + parent.Name.Length.ToString() + ":\"" + parent.Name + "\";");
				sb.Append("s:" + parent.InnerText.Length.ToString() + ":\"" + parent.InnerText + "\";");
			}
			return ToBase64String(sb.ToString());
		}

		public static string ToBase64String(string s)
		{
			byte[] aby = UTF8Encoding.UTF8.GetBytes(s);
			return Convert.ToBase64String(aby);
		}

		public static string FromBase64String(string s)
		{
			byte[] aby = Convert.FromBase64String(s);
			return UTF8Encoding.UTF8.GetString(aby);
		}

		// http://stackoverflow.com/questions/642125/encoding-xpath-expressions-with-both-single-and-double-quotes
		public static string EncaseXpathString(string input)
		{
			// If we don't have any " then encase string in "
			if ( !input.Contains("\"") )
				return String.Format("\"{0}\"", input);
			
			// If we have some " but no ' then encase in '
			if ( !input.Contains("'") )
				return String.Format("'{0}'", input);
			
			// If we get here we have both " and ' in the string so must use Concat 
			StringBuilder sb = new StringBuilder("concat(");
			
			// Going to look for " as they are LESS likely than ' in our data so will minimise
			// number of arguments to concat.
			int lastPos = 0;
			int nextPos = input.IndexOf("\"");
			while ( nextPos != -1 )
			{
				// If this is not the first time through the loop then seperate arguments with ,
				if ( lastPos != 0 )
					sb.Append(",");
			
				sb.AppendFormat("\"{0}\",'\"'", input.Substring(lastPos, nextPos - lastPos));
				lastPos = ++nextPos;
			
				// Find next occurance 
				nextPos = input.IndexOf("\"", lastPos);
			}
			// 01/31/2010 Paul.  Original code did not add the last part. 
			if ( lastPos < input.Length )
				sb.AppendFormat(",\"{0}\"", input.Substring(lastPos));
			
			sb.Append(")");
			return sb.ToString();
		}
	}
}

