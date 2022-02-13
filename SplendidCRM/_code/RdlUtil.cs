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
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.Common;
using System.Web;
using System.Web.UI.WebControls;
using System.Xml;
using System.Xml.Schema;
using System.Text;
using System.Text.RegularExpressions;
using System.Globalization;
using System.Diagnostics;

namespace SplendidCRM
{
	public class RdlDocument : XmlDocument
	{
		// "http://schemas.microsoft.com/sqlserver/reporting/2003/10/reportdefinition"
		// 06/20/2006 Paul.  Use the 2005 spec as it has better support for custom properties. 
		public string sDefaultNamespace  = "http://schemas.microsoft.com/sqlserver/reporting/2005/01/reportdefinition";
		public string sDesignerNamespace = "http://schemas.microsoft.com/SQLServer/reporting/reportdesigner";
		public string sComponentNamespace = "http://schemas.microsoft.com/sqlserver/reporting/2010/01/componentdefinition";

		private XmlNamespaceManager nsmgr;
		private StringBuilder sbValidationErrors;

		public XmlNamespaceManager NamespaceManager
		{
			get { return nsmgr; }
		}

		private void ValidationHandler(object sender, ValidationEventArgs args)
		{
			sbValidationErrors.AppendLine(args.Message);
			XmlSchemaValidationException vx = args.Exception as XmlSchemaValidationException;
			// 02/07/2010 Paul.  Defensive programming, also check for valid SourceObject. 
			if ( vx != null && vx.SourceObject != null )
			{
				if ( vx.SourceObject is XmlElement )
				{
					XmlElement xSourceObject = vx.SourceObject as XmlElement;
					sbValidationErrors.AppendLine("Source object for the exception is " + xSourceObject.Name + ". ");
					sbValidationErrors.AppendLine(xSourceObject.OuterXml);
				}
				else if ( vx.SourceObject is XmlAttribute )
				{
					XmlAttribute xSourceObject = vx.SourceObject as XmlAttribute;
					sbValidationErrors.AppendLine("Source object for the exception is " + xSourceObject.Name + ". ");
					sbValidationErrors.AppendLine(xSourceObject.OuterXml);
					if ( xSourceObject.ParentNode != null )
						sbValidationErrors.AppendLine(xSourceObject.ParentNode.OuterXml);
				}
			}
#if DEBUG
			Debug.WriteLine(sbValidationErrors);
#endif
		}

		public void Validate(HttpContext Context)
		{
			// 01/05/2016 Paul.  Add support for ReportBuilder 2016 files. 
			if ( sDefaultNamespace == "http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition" )
			{
				// 08/25/2013 Paul.  File IO is slow, so cache existance test. 
				if ( Utils.CachedFileExists(Context, "~/Reports/RDL 2016 ReportDefinition.xsd") )
				{
					string sRDLSchemaXSD = Context.Server.MapPath("~/Reports/RDL 2016 ReportDefinition.xsd");
					XmlTextReader rdrRDLSchema = new XmlTextReader(sRDLSchemaXSD);
					XmlSchema schRDL = XmlSchema.Read(rdrRDLSchema, new ValidationEventHandler(ValidationHandler));
					this.Schemas.Add(schRDL);
					this.Validate(new ValidationEventHandler(ValidationHandler));
					this.Schemas.Remove(schRDL);
				}
			}
			// 09/26/2010 Paul.  Add support for ReportBuilder 3.0 files. 
			else if ( sDefaultNamespace == "http://schemas.microsoft.com/sqlserver/reporting/2010/01/reportdefinition" )
			{
				// 08/25/2013 Paul.  File IO is slow, so cache existance test. 
				if ( Utils.CachedFileExists(Context, "~/Reports/RDL 2010 ReportDefinition.xsd") )
				{
					string sRDLSchemaXSD = Context.Server.MapPath("~/Reports/RDL 2010 ReportDefinition.xsd");
					XmlTextReader rdrRDLSchema = new XmlTextReader(sRDLSchemaXSD);
					XmlSchema schRDL = XmlSchema.Read(rdrRDLSchema, new ValidationEventHandler(ValidationHandler));
					this.Schemas.Add(schRDL);
					this.Validate(new ValidationEventHandler(ValidationHandler));
					this.Schemas.Remove(schRDL);
				}
			}
			else if ( sDefaultNamespace == "http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition" )
			{
				// 08/25/2013 Paul.  File IO is slow, so cache existance test. 
				if ( Utils.CachedFileExists(Context, "~/Reports/RDL 2008 ReportDefinition.xsd") )
				{
					string sRDLSchemaXSD = Context.Server.MapPath("~/Reports/RDL 2008 ReportDefinition.xsd");
					XmlTextReader rdrRDLSchema = new XmlTextReader(sRDLSchemaXSD);
					XmlSchema schRDL = XmlSchema.Read(rdrRDLSchema, new ValidationEventHandler(ValidationHandler));
					this.Schemas.Add(schRDL);
					this.Validate(new ValidationEventHandler(ValidationHandler));
					this.Schemas.Remove(schRDL);
				}
			}
			else
			{
				// 08/25/2013 Paul.  File IO is slow, so cache existance test. 
				if ( Utils.CachedFileExists(Context, "~/Reports/RDL 2005 ReportDefinition.xsd") )
				{
					string sRDLSchemaXSD = Context.Server.MapPath("~/Reports/RDL 2005 ReportDefinition.xsd");
					XmlTextReader rdrRDLSchema = new XmlTextReader(sRDLSchemaXSD);
					XmlSchema schRDL = XmlSchema.Read(rdrRDLSchema, new ValidationEventHandler(ValidationHandler));
					this.Schemas.Add(schRDL);
					this.Validate(new ValidationEventHandler(ValidationHandler));
					this.Schemas.Remove(schRDL);
				}
			}
			if ( sbValidationErrors.Length > 0 )
			{
				throw(new Exception("RDL Schema validation failed: " + sbValidationErrors.ToString()));
			}
		}

		public static string ConvertRDL2010ToRDL2008(string sXml)
		{
			// 09/27/2010 Paul.  The current version of the ReportBuilder does not support the 2010/01 schema. 
			sXml = sXml.Replace("http://schemas.microsoft.com/sqlserver/reporting/2010/01/reportdefinition", "http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition");
			// 01/05/2016 Paul.  Add support for ReportBuilder 2016 files. 
			// 02/16/2016 Paul.  Let's not convert 2016 to a 2008 report.  
			//sXml = sXml.Replace("http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition", "http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition");
			sXml = sXml.Replace("xmlns:cl=\"http://schemas.microsoft.com/sqlserver/reporting/2010/01/componentdefinition\"", String.Empty);
			
			XmlDocument xml = new XmlDocument();
			// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
			// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
			// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
			xml.XmlResolver = null;
			xml.LoadXml(sXml);
			string sDefaultNamespace = "http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition";
			XmlNamespaceManager nsmgr = new XmlNamespaceManager(xml.NameTable);
			nsmgr.AddNamespace("defaultns", sDefaultNamespace );
			XmlNode xPage = xml.DocumentElement.SelectSingleNode("defaultns:ReportSections/defaultns:ReportSection/defaultns:Page", nsmgr);
			if( xPage != null )
			{
				xml.DocumentElement.AppendChild(xPage);
			}
			XmlNode xWidth = xml.DocumentElement.SelectSingleNode("defaultns:ReportSections/defaultns:ReportSection/defaultns:Width", nsmgr);
			if( xWidth != null )
			{
				xml.DocumentElement.AppendChild(xWidth);
			}
			XmlNode xBody = xml.DocumentElement.SelectSingleNode("defaultns:ReportSections/defaultns:ReportSection/defaultns:Body", nsmgr);
			if( xBody != null )
			{
				xml.DocumentElement.AppendChild(xBody);
				XmlNode xReportSections = xml.DocumentElement.SelectSingleNode("defaultns:ReportSections", nsmgr);
				if ( xReportSections != null )
				{
					xReportSections.ParentNode.RemoveChild(xReportSections);
				}
				XmlUtil.SetSingleNode         (xml, "defaultns:DataSources/defaultns:DataSource", String.Empty, nsmgr, sDefaultNamespace);
				XmlUtil.SetSingleNodeAttribute(xml, "defaultns:DataSources/defaultns:DataSource", "Name", "dataSource1", nsmgr, sDefaultNamespace);
				XmlUtil.SetSingleNode         (xml, "defaultns:DataSources/defaultns:DataSource/defaultns:ConnectionProperties/defaultns:DataProvider" , "SQL", nsmgr, sDefaultNamespace);
				XmlUtil.SetSingleNode         (xml, "defaultns:DataSources/defaultns:DataSource/defaultns:ConnectionProperties/defaultns:ConnectString", String.Empty , nsmgr, sDefaultNamespace);
				
				XmlNodeList xDataSets = xml.DocumentElement.SelectNodes("defaultns:DataSets/defaultns:DataSet", nsmgr);
				foreach ( XmlNode xDataSet in xDataSets )
				{
					XmlNode xQuery = xDataSet.SelectSingleNode("defaultns:Query", nsmgr);
					if ( xQuery == null )
					{
						xQuery = xml.CreateElement("Query", sDefaultNamespace);
						xDataSet.AppendChild(xQuery);
						XmlUtil.SetSingleNode(xml, xQuery, "DataSourceName", "dataSource1", nsmgr, sDefaultNamespace);
						XmlUtil.SetSingleNode(xml, xQuery, "CommandText", String.Empty, nsmgr, sDefaultNamespace);
					}
					else
					{
						// 07/06/2011 Paul.  We need to update the data source for any existing query. 
						// The other option is to change the name of the data source to dataSource1. 
						// The dataset 'vwLEADS' refers to the data source 'SplendidCRM', which does not exist. 
						XmlUtil.SetSingleNode(xml, xQuery, "DataSourceName", "dataSource1", nsmgr, sDefaultNamespace);
					}
					XmlNode xSharedDataSet = xDataSet.SelectSingleNode("defaultns:SharedDataSet", nsmgr);
					if ( xSharedDataSet != null )
					{
						XmlNode xQueryParameters = xSharedDataSet.SelectSingleNode("defaultns:QueryParameters", nsmgr);
						if ( xQueryParameters != null )
						{
							xQuery.AppendChild(xQueryParameters);
						}
						string sSharedDataSetReference = XmlUtil.SelectSingleNode(xDataSet, "defaultns:SharedDataSet/defaultns:SharedDataSetReference", nsmgr);
						if ( !Sql.IsEmptyString(sSharedDataSetReference) )
						{
							if ( sSharedDataSetReference.StartsWith("/") )
								sSharedDataSetReference = sSharedDataSetReference.Substring(1);
							if ( sSharedDataSetReference.EndsWith(".rds") )
								sSharedDataSetReference = sSharedDataSetReference.Substring(0, sSharedDataSetReference.Length - 4);
							if ( sSharedDataSetReference.StartsWith("vw") )
							{
								string sVIEW_NAME  = sSharedDataSetReference;
								string sTABLE_NAME = sVIEW_NAME.Substring(2, sVIEW_NAME.Length - 2);
								StringBuilder sbCommandText = new StringBuilder();
								DbProviderFactory dbf = DbProviderFactories.GetFactory();
								using ( IDbConnection con = dbf.CreateConnection() )
								{
									using ( DataTable dtColumns = new DataTable() )
									{
										string sSQL;
										sSQL = "select ColumnName              " + ControlChars.CrLf
										     + "  from vwSqlColumns            " + ControlChars.CrLf
										     + " where ObjectName = @OBJECTNAME" + ControlChars.CrLf
										     + " order by colid                " + ControlChars.CrLf;
										
										using ( IDbCommand cmd = con.CreateCommand() )
										{
											cmd.CommandText = sSQL;
											// 02/20/2016 Paul.  Make sure to use upper case for Oracle. 
											Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, sVIEW_NAME));
											using ( DbDataAdapter da = dbf.CreateDataAdapter() )
											{
												((IDbDataAdapter)da).SelectCommand = cmd;
												da.Fill(dtColumns);
											}
											foreach ( DataRow rowColumn in dtColumns.Rows )
											{
												string sColumnName = Sql.ToString (rowColumn["ColumnName"]).ToUpper();
												if ( sbCommandText.Length == 0 )
													sbCommandText.AppendLine("select " + sTABLE_NAME + "." + sColumnName);
												else
													sbCommandText.AppendLine("     , " + sTABLE_NAME + "." + sColumnName);
											}
											sbCommandText.AppendLine("  from " + sVIEW_NAME + " " + sTABLE_NAME);
										}
										bool bWhereFilter = true;
										XmlNodeList nlFilters = xDataSet.SelectNodes("defaultns:Filters/defaultns:Filter", nsmgr);
										foreach ( XmlNode xFilter in nlFilters )
										{
											string sFilterExpression = XmlUtil.SelectSingleNode(xFilter, "defaultns:FilterExpression", nsmgr);
											string sOperator         = XmlUtil.SelectSingleNode(xFilter, "defaultns:Operator"        , nsmgr);
											sFilterExpression = RdlValue(sFilterExpression);
											if ( sFilterExpression.StartsWith("Fields!") && sFilterExpression.EndsWith(".Value") )
											{
												if ( bWhereFilter )
													sbCommandText.Append(" where ");
												else
													sbCommandText.Append("   and ");
												
												string sFieldName = sFilterExpression.Substring(7, sFilterExpression.Length-7-6);
												sbCommandText.Append(sFieldName + " ");
												if ( sOperator == "Between" )
												{
													string sValueA = String.Empty;
													string sValueB = String.Empty;
													XmlNodeList nlFilterValues = xFilter.SelectNodes("defaultns:FilterValues/defaultns:FilterValue", nsmgr);
													if ( nlFilterValues.Count > 0 )
														sValueA = nlFilterValues[0].InnerText;
													if ( nlFilterValues.Count > 1 )
														sValueB = nlFilterValues[1].InnerText;
													sbCommandText.AppendLine("between \'" + Sql.EscapeSQL(sValueA) + "\' and \'" + Sql.EscapeSQL(sValueB) + "\'");
												}
												else if ( sOperator == "In" )
												{
													sbCommandText.Append("in (");
													XmlNodeList nlFilterValues = xFilter.SelectNodes("defaultns:FilterValues/defaultns:FilterValue", nsmgr);
													for ( int i = 0; i < nlFilterValues.Count; i++ )
													{
														XmlNode xFilterValue = nlFilterValues[i];
														if ( i > 0 )
															sbCommandText.Append(", ");
														sbCommandText.Append("\'" + Sql.EscapeSQL(xFilterValue.InnerText) + "\'");
													}
													sbCommandText.AppendLine(")");
												}
												else
												{
													string sValue = XmlUtil.SelectSingleNode(xFilter, "defaultns:FilterValues/defaultns:FilterValue", nsmgr);
													switch ( sOperator )
													{
														case "Equal"             :  sbCommandText.Append("=" )  ;  break;
														case "NotEqual"          :  sbCommandText.Append("<>")  ;  break;
														case "GreaterThan"       :  sbCommandText.Append(">" )  ;  break;
														case "GreaterThanOrEqual":  sbCommandText.Append(">=")  ;  break;
														case "LessThan"          :  sbCommandText.Append("<" )  ;  break;
														case "LessThanOrEqual"   :  sbCommandText.Append("<=")  ;  break;
														case "Like"              :
															sbCommandText.Append("like");
															if ( sValue.IndexOf('*') >= 0 )
															{
																sValue = sValue.Replace(@"\", @"\\");
																sValue = sValue.Replace("%" , @"\%");
																sValue = sValue.Replace("*" , "%"  );
															}
															else
															{
																sValue = "%" + sValue + "%";
															}
															break;
														default:
															throw(new Exception(sOperator + " is not currently supported."));
													}
													sbCommandText.AppendLine(" \'" + Sql.EscapeSQL(sValue) + "\'");
												}
											}
										}
									}
								}
								XmlUtil.SetSingleNode(xml, xQuery, "CommandText", sbCommandText.ToString(), nsmgr, sDefaultNamespace);
							}
							else
							{
								throw(new Exception("Unknown shared dataset: " + sSharedDataSetReference));
							}
						}
						xSharedDataSet.ParentNode.RemoveChild(xSharedDataSet);
					}
				}
			}
#if DEBUG
//			xml.Save("C:\\Temp\\RDL2008.rdl.xml");
#endif
			return xml.OuterXml;
		}

		public void LoadRdl(string rdl)
		{
			// 01/05/2016 Paul.  Add support for ReportBuilder 2016 files. 
			// 02/16/2016 Paul.  Let's not convert 2016 to a 2008 report.  
			if ( rdl.IndexOf("http://schemas.microsoft.com/sqlserver/reporting/2010/01/reportdefinition") > 0 /* || rdl.IndexOf("http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition") > 0*/ )
			{
				rdl = ConvertRDL2010ToRDL2008(rdl);
			}

			base.LoadXml(rdl);
			// 01/24/2010 Paul.  The Report tag does not support the Name attribute. 
			XmlAttribute attrName = this.DocumentElement.Attributes.GetNamedItem("Name") as XmlAttribute;
			if ( attrName != null )
				this.DocumentElement.Attributes.Remove(attrName);

			nsmgr = new XmlNamespaceManager(this.NameTable);
			// 02/16/2016 Paul.  Set the namespace to 2016. 
			if ( rdl.IndexOf("http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition") > 0 )
			{
				sDefaultNamespace = "http://schemas.microsoft.com/sqlserver/reporting/2016/01/reportdefinition";
				nsmgr.AddNamespace("defaultns", sDefaultNamespace  );
				nsmgr.AddNamespace("cl"       , sComponentNamespace);
				// 02/25/2018 Paul.  We also have to correct PageHeight & PageWidth in ReportSection. 
				XmlNodeList nlReportSection = this.SelectNodesNS("ReportSections/ReportSection");
				foreach ( XmlNode xReportSection in nlReportSection )
				{
					string sPageHeight = this.SelectNodeValue(xReportSection, "Page/PageHeight");
					string sPageWidth  = this.SelectNodeValue(xReportSection, "Page/PageWidth" );
					if ( sPageHeight == "0in" )
					{
						sPageHeight = this.SelectNodeValue(xReportSection, "Body/Height");
						if ( Sql.IsEmptyString(sPageHeight) || sPageHeight == "0in" )
							sPageHeight = "8.5in";
						this.SetSingleNode(xReportSection, "Page/PageHeight", sPageHeight);
					}
					if ( sPageWidth == "0in" )
					{
						sPageWidth = this.SelectNodeValue(xReportSection, "Width");
						if ( Sql.IsEmptyString(sPageWidth) || sPageWidth == "0in" )
							sPageWidth = "11in";
						this.SetSingleNode(xReportSection, "Page/PageWidth", sPageWidth);
					}
					// 02/25/2018 Paul.  The only supported Palette at this time is Default. 
					XmlNodeList nlCharts = this.SelectNodesNS(xReportSection, "Body/ReportItems/Chart");
					foreach ( XmlNode xChart in nlCharts )
					{
						string sPalette = this.SelectNodeValue(xChart, "Palette");
						if ( sPalette != "Default" )
							this.SetSingleNode(xChart, "Palette", "Default");
					}
				}
			}
			// 09/26/2010 Paul.  Add support for ReportBuilder 3.0 files. 
			else if ( rdl.IndexOf("http://schemas.microsoft.com/sqlserver/reporting/2010/01/reportdefinition") > 0 )
			{
				sDefaultNamespace = "http://schemas.microsoft.com/sqlserver/reporting/2010/01/reportdefinition";
				nsmgr.AddNamespace("defaultns", sDefaultNamespace  );
				nsmgr.AddNamespace("cl"       , sComponentNamespace);
			}
			// 06/20/2006 Paul.  The default namespace cannot be selected, so create an alias and reference the alias. 
			// 12/08/2009 Paul.  If this is a 2008 schema, then specify the 2008 namespace. 
			else if ( rdl.IndexOf("http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition") > 0 )
			{
				// 01/24/2010 Paul.  In order to properly process ReportBuilder 2.0 report parameters, 
				// we need to change the value of sDefaultNamespace (this property cannot be static). 
				sDefaultNamespace = "http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition";
				nsmgr.AddNamespace("defaultns", sDefaultNamespace );
				// 01/12/2012 Paul.  Report Builder 3.0 is having an issue with the width and height. 
				string sPageHeight = this.SelectNodeValue("Page/PageHeight");
				string sPageWidth  = this.SelectNodeValue("Page/PageWidth" );
				if ( sPageHeight == "0in" )
				{
					sPageHeight = this.SelectNodeValue("Body/Height");
					if ( Sql.IsEmptyString(sPageHeight) || sPageHeight == "0in" )
						sPageHeight = "8.5in";
					this.SetSingleNode("Page/PageHeight", sPageHeight);
				}
				if ( sPageWidth == "0in" )
				{
					sPageWidth = this.SelectNodeValue("Width");
					if ( Sql.IsEmptyString(sPageWidth) || sPageWidth == "0in" )
						sPageWidth = "11in";
					this.SetSingleNode("Page/PageWidth", sPageWidth);
				}
			}
			else
			{
				sDefaultNamespace  = "http://schemas.microsoft.com/sqlserver/reporting/2005/01/reportdefinition";
				nsmgr.AddNamespace("defaultns", sDefaultNamespace );
			}
			// 06/22/2006 Paul.  The designer namespace must be manually added. 
			nsmgr.AddNamespace("rd", sDesignerNamespace);
			
			bool bValidate = false;
#if DEBUG
			// 09/28/2010 Paul.  The Workflow RDL will fail validation because we do not create a full document. 
			//bValidate = true;
#endif
			if ( bValidate )
			{
				Validate(HttpContext.Current);
			}
		}

		public XmlNode SelectNode(string sNode)
		{
			return XmlUtil.SelectNode(this, sNode, nsmgr);
		}

		public string SelectNodeValue(string sNode)
		{
			string sValue = String.Empty;
			XmlNode xValue = XmlUtil.SelectNode(this, sNode, nsmgr);
			if ( xValue != null )
				sValue = xValue.InnerText;
			return sValue;
		}

		public string SelectNodeAttribute(string sNode, string sAttribute)
		{
			string sValue = String.Empty;
			XmlNode xNode = null;
			if ( sNode == String.Empty )
				xNode = this.DocumentElement;
			else
				xNode = XmlUtil.SelectNode(this, sNode, nsmgr);
			if ( xNode != null )
			{
				if ( xNode.Attributes != null )
				{
					XmlNode xValue = xNode.Attributes.GetNamedItem(sAttribute);
					if ( xValue != null )
						sValue = xValue.Value;
				}
			}
			return sValue;
		}

		public string SelectNodeValue(XmlNode parent, string sNode)
		{
			return XmlUtil.SelectSingleNode(parent, sNode, nsmgr);
		}

		public XmlNodeList SelectNodesNS(string sXPath)
		{
			string[] arrXPath = sXPath.Split('/');
			for ( int i = 0; i < arrXPath.Length; i++ )
			{
				// 06/20/2006 Paul.  The default namespace cannot be selected, so create an alias and reference the alias. 
				if ( arrXPath[i].IndexOf(':') < 0 )
					arrXPath[i] = "defaultns:" + arrXPath[i];
			}
			sXPath = String.Join("/", arrXPath);
			return this.DocumentElement.SelectNodes(sXPath, nsmgr);
		}

		public XmlNodeList SelectNodesNS(XmlNode parent, string sXPath)
		{
			string[] arrXPath = sXPath.Split('/');
			for ( int i = 0; i < arrXPath.Length; i++ )
			{
				// 06/20/2006 Paul.  The default namespace cannot be selected, so create an alias and reference the alias. 
				if ( arrXPath[i].IndexOf(':') < 0 )
					arrXPath[i] = "defaultns:" + arrXPath[i];
			}
			sXPath = String.Join("/", arrXPath);
			return parent.SelectNodes(sXPath, nsmgr);
		}

		public void SetSingleNode(string sNode, string sValue)
		{
			XmlUtil.SetSingleNode(this, sNode, sValue, nsmgr, sDefaultNamespace);
		}

		// 11/20/2011 Paul.  Charting needs a way to skip updating if value exists. 
		public void SetSingleNode_InsertOnly(string sNode, string sValue)
		{
			XmlUtil.SetSingleNode_InsertOnly(this, sNode, sValue, nsmgr, sDefaultNamespace);
		}

		public void SetSingleNode(XmlNode parent, string sNode, string sValue)
		{
			XmlUtil.SetSingleNode(this, parent, sNode, sValue, nsmgr, sDefaultNamespace);
		}

		public void SetSingleNodeAttribute(string sNode, string sAttribute, string sValue)
		{
			XmlUtil.SetSingleNodeAttribute(this, sNode, sAttribute, sValue, nsmgr, sDefaultNamespace);
		}

		public void SetSingleNodeAttribute(XmlNode parent, string sAttribute, string sValue)
		{
			XmlUtil.SetSingleNodeAttribute(this, parent, sAttribute, sValue, nsmgr, sDefaultNamespace);
		}

		public RdlDocument() : base()
		{
			sbValidationErrors = new StringBuilder();
		}

		public RdlDocument(string sNAME) : base()
		{
			this.AppendChild(this.CreateXmlDeclaration("1.0", "UTF-8", null));
			//this.AppendChild(this.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));

			this.AppendChild(this.CreateElement("Report", sDefaultNamespace));
			// 01/24/2010 Paul.  The Report tag does not support the Name attribute. 
			//XmlUtil.SetSingleNodeAttribute(this, this.DocumentElement, "Name", sNAME);
			// 06/20/2006 Paul.  Add the RD namespace manually. 
			XmlUtil.SetSingleNodeAttribute(this, this.DocumentElement, "xmlns:rd", sDesignerNamespace);

			nsmgr = new XmlNamespaceManager(this.NameTable);
			nsmgr.AddNamespace(""  , sDefaultNamespace );
			nsmgr.AddNamespace("rd", sDesignerNamespace);
			// 06/20/2006 Paul.  The default namespace cannot be selected, so create an alias and reference the alias. 
			nsmgr.AddNamespace("defaultns", sDefaultNamespace );
			// 02/11/2010 Paul.  The Report Name is important, so store in the Custom area. 
			SetCustomProperty("ReportName", sNAME);
		}

		public RdlDocument(string sNAME, string sAUTHOR, bool bChart) : base()
		{
			this.AppendChild(this.CreateXmlDeclaration("1.0", "UTF-8", null));
			//this.AppendChild(this.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));

			if ( bChart )
				sDefaultNamespace = "http://schemas.microsoft.com/sqlserver/reporting/2008/01/reportdefinition";
			this.AppendChild(this.CreateElement("Report", sDefaultNamespace));
			// 01/24/2010 Paul.  The Report tag does not support the Name attribute. 
			//XmlUtil.SetSingleNodeAttribute(this, this.DocumentElement, "Name", sNAME);
			// 06/20/2006 Paul.  Add the RD namespace manually. 
			XmlUtil.SetSingleNodeAttribute(this, this.DocumentElement, "xmlns:rd", sDesignerNamespace);

			nsmgr = new XmlNamespaceManager(this.NameTable);
			nsmgr.AddNamespace(""  , sDefaultNamespace );
			nsmgr.AddNamespace("rd", sDesignerNamespace);
			// 06/20/2006 Paul.  The default namespace cannot be selected, so create an alias and reference the alias. 
			nsmgr.AddNamespace("defaultns", sDefaultNamespace );

			// 06/18/2006 Paul.  The report definition element 'Report' is empty at line 14, position 5054. It is missing a mandatory child element of type 'Width'. 
			// Change PageWidth to Width, and remove namespace. 
			SetSingleNode("Width"       , "11in"      );
			if ( !bChart )
			{
				SetSingleNode("PageWidth"   , "11in"      );
				SetSingleNode("PageHeight"  , "8.5in"     );
				SetSingleNode("LeftMargin"  , ".5in"      );
				SetSingleNode("RightMargin" , ".5in"      );
				SetSingleNode("TopMargin"   , ".5in"      );
				SetSingleNode("BottomMargin", ".5in"      );
			}
			//SetSingleNode("Language"    , "en-US"     );
			SetSingleNode("Description" , String.Empty);
			SetSingleNode("Author"      , sAUTHOR     );

			string sDataProvider = String.Empty;
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				if ( Sql.IsSQLServer(con) )
					sDataProvider = "SQL";
				else if ( Sql.IsOracle(con) )
					sDataProvider = "Oracle";
				else if ( Sql.IsDB2(con) )
					sDataProvider = "DB2";
				else if ( Sql.IsMySQL(con) )
					sDataProvider = "MySQL";
				else if ( Sql.IsSybase(con) )
					sDataProvider = "Sybase";
				else if ( Sql.IsSqlAnywhere(con) )
					sDataProvider = "SQL Anywhere";
				
			}

			SetSingleNode         ("CustomProperties", String.Empty);

			SetSingleNode         ("DataSources/DataSource", String.Empty);
			SetSingleNodeAttribute("DataSources/DataSource", "Name", "dataSource1");
			SetSingleNode         ("DataSources/DataSource/ConnectionProperties/DataProvider" , sDataProvider);
			SetSingleNode         ("DataSources/DataSource/ConnectionProperties/ConnectString", String.Empty );
			
			SetSingleNode         ("DataSets/DataSet", String.Empty);
			SetSingleNodeAttribute("DataSets/DataSet", "Name", "dataSet");
			SetSingleNode         ("DataSets/DataSet/Query/DataSourceName", "dataSource1");
			SetSingleNode         ("DataSets/DataSet/Query/CommandText"   , String.Empty );
			SetSingleNode         ("DataSets/DataSet/Fields"              , String.Empty );
			
			if ( !bChart )
			{
				SetSingleNode         ("Body/ReportItems/Table", String.Empty);
				SetSingleNodeAttribute("Body/ReportItems/Table", "Name", "table1");
				SetSingleNode         ("Body/ReportItems/Table/DataSetName"                          , "dataSet"   );
				SetSingleNode         ("Body/ReportItems/Table/Header/RepeatOnNewPage"               , "true"      );
			
				// 06/21/2006 Paul.  TableRow requires a Height element. 
				SetSingleNode         ("Body/ReportItems/Table/Header/TableRows/TableRow/Height"     , "0.21in"    );
				SetSingleNode         ("Body/ReportItems/Table/Details/TableRows/TableRow/Height"    , "0.21in"    );

				SetSingleNode         ("Body/ReportItems/Table/Header/TableRows/TableRow/TableCells" , String.Empty);
				SetSingleNode         ("Body/ReportItems/Table/Details/TableRows/TableRow/TableCells", String.Empty);
				// 06/21/2006 Paul.  Table requires a TableColumns element. 
				SetSingleNode         ("Body/ReportItems/Table/TableColumns"                         , String.Empty);
			}
			// 06/21/2006 Paul.  Body requires a Height element. 
			SetSingleNode         ("Body/Height"                                                 , "8.5in"      );
			
			// 06/21/2006 Paul.  If PageFooter is included, then it must have a Height element. 
			//SetSingleNode         ("PageFooter", String.Empty);
			//SetSingleNode         ("PageHeader", String.Empty);
			// 02/11/2010 Paul.  The Report Name is important, so store in the Custom area. 
			SetCustomProperty("ReportName", sNAME);
		}

		public XmlDocument GetCustomProperty(string sName)
		{
			XmlDocument xml = new XmlDocument();
			// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
			// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
			// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
			xml.XmlResolver = null;
			xml.AppendChild(xml.CreateElement(sName));
			
			try
			{
				XmlNode xValue = this.DocumentElement.SelectSingleNode("defaultns:CustomProperties/defaultns:CustomProperty[defaultns:Name=\'crm:" + sName + "\']/defaultns:Value", nsmgr);
				if ( xValue != null )
				{
					string sValue = xValue.InnerText;
					if ( !Sql.IsEmptyString(sValue) )
					{
						xml.LoadXml(sValue);
					}
				}
			}
			catch
			{
			}
			return xml;
		}

		public string GetCustomPropertyValue(string sName)
		{
			string sValue = String.Empty;
			try
			{
				XmlNode xValue = this.DocumentElement.SelectSingleNode("defaultns:CustomProperties/defaultns:CustomProperty[defaultns:Name=\'crm:" + sName + "\']/defaultns:Value", nsmgr);
				if ( xValue != null )
				{
					sValue = xValue.InnerText;
				}
			}
			catch
			{
			}
			return sValue;
		}

		public void SetCustomProperty(string sName, string sValue)
		{
			// "CustomProperties"
			XmlNode xCustomProperties = this.DocumentElement.SelectSingleNode("defaultns:CustomProperties", nsmgr);
			if ( xCustomProperties == null )
			{
				xCustomProperties = this.CreateElement("CustomProperties", sDefaultNamespace);
				this.DocumentElement.AppendChild(xCustomProperties);
			}
			// 05/27/2006 Paul.  All SplendidCRM properties should start with "crm". 
			XmlNode xCustomProperty = xCustomProperties.SelectSingleNode("defaultns:CustomProperty[defaultns:Name=\'crm:" + sName + "\']", nsmgr);
			if ( xCustomProperty == null )
			{
				xCustomProperty = this.CreateElement("CustomProperty", sDefaultNamespace);
				xCustomProperties.AppendChild(xCustomProperty);

				XmlNode xName  = this.CreateElement("Name" , sDefaultNamespace);
				XmlNode xValue = this.CreateElement("Value", sDefaultNamespace);
				xCustomProperty.AppendChild(xName );
				xCustomProperty.AppendChild(xValue);
				xName.InnerText  = "crm:" + sName;
				xValue.InnerText = sValue;
			}
			else
			{
				XmlNode xValue = xCustomProperty.SelectSingleNode("defaultns:Value", nsmgr);
				if ( xValue == null )
				{
					xValue = this.CreateElement("Value", sDefaultNamespace);
					xCustomProperty.AppendChild(xValue);
				}
				xValue.InnerText = sValue;
			}
		}

		public DataTable CreateDataTable()
		{
			DataTable dt = new DataTable("ReportItems");
			dt.Columns.Add("text" );
			dt.Columns.Add("value");
			if ( this.DocumentElement != null )
			{
				XmlNodeList nlHeaderValues = this.SelectNodesNS("Body/ReportItems/Table/Header/TableRows/TableRow/TableCells/TableCell/ReportItems/Textbox/Value" );
				XmlNodeList nlDetailValues = this.SelectNodesNS("Body/ReportItems/Table/Details/TableRows/TableRow/TableCells/TableCell/ReportItems/Textbox/Value");
				for ( int iDetail = 0; iDetail < nlDetailValues.Count; iDetail++ )
				{
					if ( iDetail < nlHeaderValues.Count )
					{
						DataRow row = dt.NewRow();
						dt.Rows.Add(row);
						try
						{
							string sHeader = nlHeaderValues[iDetail].InnerText;
							string sDetail = nlDetailValues[iDetail].InnerText;
							if ( sDetail.StartsWith("=Fields!") && sDetail.EndsWith(".Value") )
							{
								sDetail = sDetail.Substring("=Fields!".Length, sDetail.Length - "=Fields!".Length - ".Value".Length);
								// 06/18/2006 Paul.  Now translate the field name to the column name. 
								XmlNode xField = this.SelectNode("DataSets/DataSet/Fields/Field[@Name='" + sDetail + "']/DataField");
								if ( xField != null )
									sDetail = xField.InnerText;
							}
							row["text" ] = sHeader;
							row["value"] = sDetail;
						}
						catch(Exception ex)
						{
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
			}
			return dt;
		}

		public static string RdlName(string sName)
		{
			sName = Regex.Replace(sName, @"[\[\]]" , "");
			sName = Regex.Replace(sName, @"[\.\: ]", "__");
			return sName;
		}

		// 07/12/2006 Paul.  The textbox name needs to be derived from the field name.
		// There are just too many pitfalls of attempting to derive the textbox from the display name.
		// We would have to escape all characters except alpha-numerics. 
		// When we use the field name as the base, then we only have to escape a few characters. 
		public void CreateTextboxValue(XmlNode parent, string sTextboxName, string sValue, bool bField)
		{
			XmlNode xTableCell   = this.CreateElement("TableCell"  , sDefaultNamespace);
			XmlNode xReportItems = this.CreateElement("ReportItems", sDefaultNamespace);
			XmlNode xTextbox     = this.CreateElement("Textbox"    , sDefaultNamespace);
			//XmlNode xWidth       = this.CreateElement("Width"      , sDefaultNamespace);
			XmlNode xValue       = this.CreateElement("Value"      , sDefaultNamespace);
			parent.AppendChild(xTableCell);
			xTableCell.AppendChild(xReportItems);
			xReportItems.AppendChild(xTextbox);
			xTextbox.AppendChild(xValue);
			if ( bField )
			{
				// 06/21/2006 Paul.  Textbox requires a Name attribute. 
				this.SetSingleNodeAttribute(xTextbox, "Name", RdlName(sTextboxName) + "__Value");
				// 06/18/2006 Paul.  Field names must be CLS-compliant identifiers. Use two underscores to distinguish betwen typical use of underscore. 
				xValue.InnerText = "=Fields!" + RdlName(sValue) + ".Value";
				this.SetSingleNode(xTextbox, "Style/PaddingLeft"  , "2pt");
				this.SetSingleNode(xTextbox, "Style/PaddingRight" , "2pt");
				this.SetSingleNode(xTextbox, "Style/PaddingBottom", "2pt");
				this.SetSingleNode(xTextbox, "Style/PaddingTop"   , "2pt");
				this.SetSingleNode(xTextbox, "CanGrow"            , "true");
				//this.SetSingleNode(xTextbox, "rd:DefaultName"     , sValue);
			}
			else
			{
				// 06/21/2006 Paul.  Textbox requires a Name attribute. 
				this.SetSingleNodeAttribute(xTextbox, "Name", RdlName(sTextboxName) + "__Header");
				//xTextbox.AppendChild(xWidth);
				//xWidth.InnerText = "1in";
				xValue.InnerText = sValue;
				this.SetSingleNode(xTextbox, "Style/PaddingLeft"  , "2pt");
				this.SetSingleNode(xTextbox, "Style/PaddingRight" , "2pt");
				this.SetSingleNode(xTextbox, "Style/PaddingBottom", "2pt");
				this.SetSingleNode(xTextbox, "Style/PaddingTop"   , "2pt");
				this.SetSingleNode(xTextbox, "Style/FontWeight"   , "900");
				this.SetSingleNode(xTextbox, "CanGrow"            , "true");
				//this.SetSingleNode(xTextbox, "rd:DefaultName"     , sValue);
				this.SetSingleNode(xTextbox, "Style/BorderWidth/Bottom", "2pt"  );
				this.SetSingleNode(xTextbox, "Style/BorderColor/Bottom", "Black");
				this.SetSingleNode(xTextbox, "Style/BorderStyle/Bottom", "Solid");
			}
		}

		public void CreateField(XmlNode parent, string sFieldName)
		{
			XmlNode xField     = this.CreateElement("Field"    , sDefaultNamespace);
			XmlNode xDataField = this.CreateElement("DataField", sDefaultNamespace);
			parent.AppendChild(xField);
			xField.AppendChild(xDataField);
			xDataField.InnerText = sFieldName;
			
			XmlAttribute attr = this.CreateAttribute("Name");
			// 06/18/2006 Paul.  Field names must be CLS-compliant identifiers. Use two underscores to distinguish betwen typical use of underscore. 
			attr.Value = RdlName(sFieldName);
			xField.Attributes.SetNamedItem(attr);
		}

		public void CreateField(XmlNode parent, string sFieldName, string sFieldType)
		{
			XmlNode xField     = this.CreateElement("Field"      , sDefaultNamespace );
			XmlNode xDataField = this.CreateElement("DataField"  , sDefaultNamespace );
			XmlNode xTypeName  = this.CreateElement("rd:TypeName", sDesignerNamespace);
			parent.AppendChild(xField);
			xField.AppendChild(xDataField);
			xField.AppendChild(xTypeName);
			xDataField.InnerText = sFieldName;
			xTypeName.InnerText  = sFieldType;
			
			XmlAttribute attr = this.CreateAttribute("Name");
			// 06/18/2006 Paul.  Field names must be CLS-compliant identifiers. Use two underscores to distinguish betwen typical use of underscore. 
			attr.Value = RdlName(sFieldName);
			xField.Attributes.SetNamedItem(attr);
		}

		public void RemoveField(string sFieldName)
		{
			XmlNode xHeaderCells  = this.SelectNode("Body/ReportItems/Table/Header/TableRows/TableRow/TableCells" );
			XmlNode xDetailsCells = this.SelectNode("Body/ReportItems/Table/Details/TableRows/TableRow/TableCells");
			XmlNode xTableColumns = this.SelectNode("Body/ReportItems/Table/TableColumns");
			for ( int i = 0; i < xDetailsCells.ChildNodes.Count; i++ )
			{
				XmlNode xTableCell = xDetailsCells.ChildNodes[i];
				if ( xTableCell.SelectSingleNode("defaultns:ReportItems/defaultns:Textbox[defaultns:Value=\"=Fields!" + RdlName(sFieldName) + ".Value\"]", nsmgr) != null )
				{
					if ( i < xHeaderCells .ChildNodes.Count ) xHeaderCells .RemoveChild(xHeaderCells .ChildNodes[i]);
					if ( i < xDetailsCells.ChildNodes.Count ) xDetailsCells.RemoveChild(xDetailsCells.ChildNodes[i]);
					if ( i < xTableColumns.ChildNodes.Count ) xTableColumns.RemoveChild(xTableColumns.ChildNodes[i]);
					break;
				}
			}
		}

		public void UpdateDataTable(DataTable dtDisplayColumns)
		{
			SetSingleNode("Body/ReportItems/Table/Header/TableRows/TableRow/TableCells" , String.Empty);
			SetSingleNode("Body/ReportItems/Table/Details/TableRows/TableRow/TableCells", String.Empty);
			SetSingleNode("Body/ReportItems/Table/TableColumns" , String.Empty);
			//SetSingleNode("DataSets/DataSet/Fields", String.Empty);
			
			XmlNode xHeaderCells  = this.SelectNode("Body/ReportItems/Table/Header/TableRows/TableRow/TableCells" );
			XmlNode xDetailsCells = this.SelectNode("Body/ReportItems/Table/Details/TableRows/TableRow/TableCells");
			XmlNode xTableColumns = this.SelectNode("Body/ReportItems/Table/TableColumns");
			//XmlNode xFields       = this.SelectNode("DataSets/DataSet/Fields");
			xHeaderCells .RemoveAll();
			xDetailsCells.RemoveAll();
			xTableColumns.RemoveAll();
			//xFields.RemoveAll();
			if ( dtDisplayColumns != null )
			{
				CultureInfo ciEnglish = CultureInfo.CreateSpecificCulture("en-US");
				string sDefaultWidth = SelectNodeValue("PageWidth"  );
				if ( Sql.IsEmptyString(sDefaultWidth) )
					sDefaultWidth = SelectNodeValue("Width");
				// http://technet.microsoft.com/en-US/library/ms153577(v=sql.90).aspx
				// 08/08/2014 Paul.  Units can be cm, mm, in, pt or pc. 
				string sDefaultUnits = "in";
				if ( sDefaultWidth.EndsWith("cm") )
					sDefaultUnits = "cm";
				else if ( sDefaultWidth.EndsWith("mm") )
					sDefaultUnits = "mm";
				else if ( sDefaultWidth.EndsWith("pt") )
					sDefaultUnits = "pt";
				else if ( sDefaultWidth.EndsWith("pc") )
					sDefaultUnits = "pc";
				sDefaultWidth = sDefaultWidth.Replace(sDefaultUnits, "");
				double dPageWidth = Sql.ToDouble(sDefaultWidth);
				if ( dPageWidth == 0.0 )
					dPageWidth = 15.0;
				
				// 09/15/2014 Paul.  Need to substract the margins, otherwise the columns will exceed the page and create a blank page in the PDF. 
				string sLeftMargin   = SelectNodeValue("LeftMargin" );
				string sRightMargin  = SelectNodeValue("RightMargin");
				if ( Sql.IsEmptyString(sLeftMargin) )
					sLeftMargin = ".5in";
				if ( Sql.IsEmptyString(sRightMargin) )
					sRightMargin = ".5in";
				if ( sLeftMargin.EndsWith(sDefaultUnits) )
				{
					dPageWidth -= Sql.ToDouble(sLeftMargin.Replace(sDefaultUnits, ""));
				}
				else
				{
					if ( sDefaultUnits == "in" && sLeftMargin.EndsWith("cm") )
						dPageWidth -= Sql.ToDouble(sLeftMargin.Replace("cm", "")) / 2.54;
					else if ( sDefaultUnits == "cm" && sLeftMargin.EndsWith("in") )
						dPageWidth -= Sql.ToDouble(sLeftMargin.Replace("in", "")) * 2.54;
					else if ( sDefaultUnits == "in" && sLeftMargin.EndsWith("mm") )
						dPageWidth -= Sql.ToDouble(sLeftMargin.Replace("mm", "")) / 25.4;
					else if ( sDefaultUnits == "mm" && sLeftMargin.EndsWith("in") )
						dPageWidth -= Sql.ToDouble(sLeftMargin.Replace("in", "")) * 25.4;
				}
				if ( sRightMargin.EndsWith(sDefaultUnits) )
				{
					dPageWidth -= Sql.ToDouble(sRightMargin.Replace(sDefaultUnits, ""));
				}
				else
				{
					if ( sDefaultUnits == "in" && sRightMargin.EndsWith("cm") )
						dPageWidth -= Sql.ToDouble(sRightMargin.Replace("cm", "")) / 2.54;
					else if ( sDefaultUnits == "cm" && sRightMargin.EndsWith("in") )
						dPageWidth -= Sql.ToDouble(sRightMargin.Replace("in", "")) * 2.54;
					else if ( sDefaultUnits == "in" && sRightMargin.EndsWith("mm") )
						dPageWidth -= Sql.ToDouble(sRightMargin.Replace("mm", "")) / 25.4;
					else if ( sDefaultUnits == "mm" && sRightMargin.EndsWith("in") )
						dPageWidth -= Sql.ToDouble(sRightMargin.Replace("in", "")) * 25.4;
				}
				
				if ( dPageWidth == 0.0 )
					dPageWidth = 15.0;
				if ( dtDisplayColumns.Rows.Count > 0 )
				{
					double dWidth = dPageWidth / dtDisplayColumns.Rows.Count;
					// 11/24/2006 Paul.  The ReportViewer only understands the en-US decimal format. 
					sDefaultWidth = dWidth.ToString("#.##", ciEnglish.NumberFormat) + sDefaultUnits;
				}
				// 09/15/2014 Paul.  Must specify the table width in order to prevent PDF from creating blank overflow pages. 
				SetSingleNode("Body/ReportItems/Table/Width", dPageWidth.ToString("#.##", ciEnglish.NumberFormat) + sDefaultUnits);
				bool bUseWidth = dtDisplayColumns.Columns.Contains("Width");
				foreach ( DataRow row in dtDisplayColumns.Rows )
				{
					string sWidth        = sDefaultWidth;
					string sFieldLabel   = Sql.ToString(row["Label"]);
					string sFieldName    = Sql.ToString(row["Field"]);
					string sDisplayWidth = String.Empty;
					if ( bUseWidth )
					{
						sDisplayWidth = Sql.ToString(row["Width"]).ToLower();
						if ( sDisplayWidth.EndsWith("%") )
						{
							double dWidth = Convert.ToDouble(sDisplayWidth.Substring(0, sDisplayWidth.Length-1)) * dPageWidth / 100;
							sWidth = dWidth.ToString("#.##", ciEnglish.NumberFormat) + sDefaultUnits;
						}
						else if ( sDisplayWidth.EndsWith("in") && sDisplayWidth.EndsWith("cm") && sDisplayWidth.EndsWith("mm") && sDisplayWidth.EndsWith("pt") && sDisplayWidth.EndsWith("pc") )
						{
							sWidth = sDisplayWidth;
						}
					}
					CreateTextboxValue(xHeaderCells , sFieldName , sFieldLabel, false);
					CreateTextboxValue(xDetailsCells, sFieldName , sFieldName , true );
					//CreateField(xFields, sFieldName);
					
					XmlNode xTableColumn = this.CreateElement("TableColumn", sDefaultNamespace);
					XmlNode xWidth       = this.CreateElement("Width"      , sDefaultNamespace);
					xTableColumns.AppendChild(xTableColumn);
					xTableColumn.AppendChild(xWidth);
					xWidth.InnerText = sWidth;
				}
			}
		}

		// 11/06/2011 Paul.  MS Charts do the grouping after the selected.  We will convert the select to do the grouping. 
		public void BuildChartCommand(HttpContext Context, XmlNode xDataSet, IDbCommand cmd)
		{
			if ( Sql.IsOracle(cmd) )
			{
				cmd.CommandText = "ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS'";
				cmd.ExecuteNonQuery();
			}
			cmd.CommandText = XmlUtil.SelectSingleNode(xDataSet, "Query/CommandText", nsmgr);
			// 01/30/2012 Paul.  Make sure to set the command type if it is a stored procedure. 
			if ( XmlUtil.SelectSingleNode(xDataSet, "Query/CommandType", nsmgr) == "StoredProcedure" )
				cmd.CommandType = CommandType.StoredProcedure;

			if ( !cmd.CommandText.ToLower().Contains("group by") )
			{
				string sYField            = this.SelectNodeValue("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartDataPoints/ChartDataPoint/ChartDataPointValues/Y");
				string sXField            = this.SelectNodeValue("Body/ReportItems/Chart/ChartCategoryHierarchy/ChartMembers/ChartMember/Group/GroupExpressions/GroupExpression");
				if ( !Sql.IsEmptyString(sYField) && !Sql.IsEmptyString(sXField) )
				{
					string sSeriesOperator = "sum";
					if      ( sYField.StartsWith("=Avg("    ) ) sSeriesOperator = "avg";
					else if ( sYField.StartsWith("=Sum("    ) ) sSeriesOperator = "sum";
					else if ( sYField.StartsWith("=Min("    ) ) sSeriesOperator = "min";
					else if ( sYField.StartsWith("=Max("    ) ) sSeriesOperator = "max";
					else if ( sYField.StartsWith("=Count(*)") ) sSeriesOperator = "count";
					else if ( sYField.StartsWith("=Count("  ) ) sSeriesOperator = "count_not_empty";
					
					string sSeriesField       = this.LookupDateField(sYField);
					if ( sYField.Contains("*") )
						sSeriesField = this.LookupDateField(this.SelectNodeAttribute("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries", "Name"));
					string sCategoryField     = this.LookupDateField(sXField);
					string sCategoryOperator  = String.Empty;  // this.GetCustomPropertyValue("ChartsCategoryOperator");
					string sCategoryAxesFormat  = this.SelectNodeValue("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis/Style/Format");
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
					
					string sCategoryAggregate = sCategoryField;
					switch ( sCategoryOperator )
					{
						case "day"    :  sCategoryAggregate = "dbo.fnDateOnly("    + sCategoryAggregate + ")";  break;
						case "week"   :  sCategoryAggregate = "dbo.fnWeekOnly("    + sCategoryAggregate + ")";  break;
						case "month"  :  sCategoryAggregate = "dbo.fnMonthOnly("   + sCategoryAggregate + ")";  break;
						case "quarter":  sCategoryAggregate = "dbo.fnQuarterOnly(" + sCategoryAggregate + ")";  break;
						case "year"   :  sCategoryAggregate = "year("              + sCategoryAggregate + ")";  break;
					}
					cmd.CommandText = cmd.CommandText.Replace(" " + sCategoryField + " ", " " + sCategoryAggregate + " ");
					switch ( sSeriesOperator )
					{
						case "avg"            :  cmd.CommandText = cmd.CommandText.Replace(" " + sSeriesField   + " ", " " + "Avg("   + sSeriesField + ")" + " ");  break;
						case "sum"            :  cmd.CommandText = cmd.CommandText.Replace(" " + sSeriesField   + " ", " " + "Sum("   + sSeriesField + ")" + " ");  break;
						case "min"            :  cmd.CommandText = cmd.CommandText.Replace(" " + sSeriesField   + " ", " " + "Min("   + sSeriesField + ")" + " ");  break;
						case "max"            :  cmd.CommandText = cmd.CommandText.Replace(" " + sSeriesField   + " ", " " + "Max("   + sSeriesField + ")" + " ");  break;
						case "count"          :  cmd.CommandText = cmd.CommandText.Replace(" " + sSeriesField   + " ", " " + "Count(*)"                    + " ");  break;
						case "count_not_empty":  cmd.CommandText = cmd.CommandText.Replace(" " + sSeriesField   + " ", " " + "Count(" + sSeriesField + ")" + " ");  break;
						default               :  cmd.CommandText = cmd.CommandText.Replace(" " + sSeriesField   + " ", " " + ""       + sSeriesField       + " ");  break;
					}
					cmd.CommandText += " group by " + sCategoryAggregate + ControlChars.CrLf;
					cmd.CommandText += " order by " + sCategoryAggregate + ControlChars.CrLf;
				}
			}

			if ( !Sql.IsSQLServer(cmd) && !Sql.IsSybase(cmd) )
			{
				cmd.CommandText = cmd.CommandText.Replace(" dbo.fnDateOnly("   , " fnDateOnly("   );
				cmd.CommandText = cmd.CommandText.Replace(" dbo.fnMonthOnly("  , " fnMonthOnly("  );
				cmd.CommandText = cmd.CommandText.Replace(" dbo.fnWeekOnly("   , " fnWeekOnly("   );
				cmd.CommandText = cmd.CommandText.Replace(" dbo.fnQuarterOnly(", " fnQuarterOnly(");
			}
			if ( cmd.CommandText.Contains("@MEMBERSHIP_USER_ID") )
				Sql.AddParameter(cmd, "@MEMBERSHIP_USER_ID", Security.USER_ID);
			
			XmlNodeList nlQueryParameters = this.SelectNodesNS(xDataSet, "Query/QueryParameters/QueryParameter");
			foreach ( XmlNode xQueryParameter in nlQueryParameters )
			{
				BuildCommandQueryParameter(xDataSet, xQueryParameter, cmd);
			}
		}

		public void UpdateChartTitle(string sChartTitle)
		{
			SetSingleNode("Body/ReportItems/Chart/ChartTitles/ChartTitle/Caption", sChartTitle);
		}

		public void UpdateChart(string sChartTitle, string sChartType, string sSeriesTitle, string sSeriesColumn, string sSeriesOperator, string sCategoryTitle, string sCategoryColumn, string sCategoryOperator, string sDateFormat)
		{
			sSeriesColumn   = sSeriesColumn.Replace  (".", "__");
			sCategoryColumn = sCategoryColumn.Replace(".", "__");

			//this.SetCustomProperty("ChartsCategoryOperator", sCategoryOperator);
			string sCategoryAxesFormat = String.Empty;
			switch ( sCategoryOperator )
			{
				case "day"    :  sCategoryAxesFormat = sDateFormat;  break;
				case "week"   :  sCategoryAxesFormat = "yyyy Ww"  ;  break;
				case "month"  :  sCategoryAxesFormat = "yyyy/MM"  ;  break;
				case "quarter":  sCategoryAxesFormat = "yyyy Qq"  ;  break;
				case "year"   :  sCategoryAxesFormat = "yyyy"     ;  break;
			}

			// 11/06/2011 Paul.  Remove all existing report items. 
			// 11/12/2011 Paul.  Don't remove existing items.  Just modify the first chart so that Report Builder changes will not get thrown away. 
			//SetSingleNode         ("Body/ReportItems", String.Empty);
			//SetSingleNode         ("Body/ReportItems/Chart", String.Empty);
			SetSingleNodeAttribute("Body/ReportItems/Chart", "Name", "Chart1");

			SetSingleNode         ("Body/ReportItems/Chart/ChartCategoryHierarchy/ChartMembers/ChartMember/Group", String.Empty);
			SetSingleNodeAttribute("Body/ReportItems/Chart/ChartCategoryHierarchy/ChartMembers/ChartMember/Group", "Name", "Chart1_CategoryGroup");
			SetSingleNode         ("Body/ReportItems/Chart/ChartCategoryHierarchy/ChartMembers/ChartMember/Group/GroupExpressions/GroupExpression", "=Fields!" + sCategoryColumn + ".Value");
			SetSingleNode         ("Body/ReportItems/Chart/ChartCategoryHierarchy/ChartMembers/ChartMember/SortExpressions/SortExpression/Value"  , "=Fields!" + sCategoryColumn + ".Value");
			SetSingleNode         ("Body/ReportItems/Chart/ChartCategoryHierarchy/ChartMembers/ChartMember/Label"                                 , "=Fields!" + sCategoryColumn + ".Value");

			SetSingleNode         ("Body/ReportItems/Chart/ChartSeriesHierarchy/ChartMembers/ChartMember/Label", sSeriesTitle);

			SetSingleNode         ("Body/ReportItems/Chart/ChartData/ChartSeriesCollection", String.Empty);
			SetSingleNodeAttribute("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries", "Name", sSeriesColumn);
			switch ( sSeriesOperator )
			{
				case "avg"            :  SetSingleNode("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartDataPoints/ChartDataPoint/ChartDataPointValues/Y", "=Avg(Fields!"   + sSeriesColumn + ")");  break;
				case "sum"            :  SetSingleNode("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartDataPoints/ChartDataPoint/ChartDataPointValues/Y", "=Sum(Fields!"   + sSeriesColumn + ")");  break;
				case "min"            :  SetSingleNode("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartDataPoints/ChartDataPoint/ChartDataPointValues/Y", "=Min(Fields!"   + sSeriesColumn + ")");  break;
				case "max"            :  SetSingleNode("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartDataPoints/ChartDataPoint/ChartDataPointValues/Y", "=Max(Fields!"   + sSeriesColumn + ")");  break;
				case "count"          :  SetSingleNode("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartDataPoints/ChartDataPoint/ChartDataPointValues/Y", "=Count(*)"                           );  break;
				case "count_not_empty":  SetSingleNode("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartDataPoints/ChartDataPoint/ChartDataPointValues/Y", "=Count(Fields!" + sSeriesColumn + ")");  break;
				default               :  SetSingleNode("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartDataPoints/ChartDataPoint/ChartDataPointValues/Y", "=Fields!"       + sSeriesColumn      );  break;
			}
			//SetSingleNode         ("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartDataPoints/ChartDataPoint/ChartDataLabel/Style", String.Empty);
			//SetSingleNode         ("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartDataPoints/ChartDataPoint/Style"               , String.Empty);
			//SetSingleNode         ("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartDataPoints/ChartDataPoint/ChartMarker/Style"   , String.Empty);
			// 11/20/2011 Paul.  Charting needs a way to skip updating if value exists. 
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartDataPoints/ChartDataPoint/DataElementOutput"   , "Output"    );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/Type" , sChartType  );
			//SetSingleNode         ("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/Style", String.Empty);
			//SetSingleNode         ("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartEmptyPoints/Style"               , String.Empty);
			//SetSingleNode         ("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartEmptyPoints/ChartMarker/Style"   , String.Empty);
			//SetSingleNode         ("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartEmptyPoints/ChartDataLabel/Style", String.Empty);
			SetSingleNode           ("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ValueAxisName"                        , "Primary"   );
			SetSingleNode           ("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/CategoryAxisName"                     , "Primary"   );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartSmartLabel/CalloutLineColor"     , "Black"     );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartData/ChartSeriesCollection/ChartSeries/ChartSmartLabel/MinMovingDistance"    , "0pt"       );

			//SetSingleNode         ("Body/ReportItems/Chart/ChartAreas", String.Empty);
			SetSingleNodeAttribute  ("Body/ReportItems/Chart/ChartAreas/ChartArea", "Name", "Default");
			//SetSingleNode           ("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis" , String.Empty);
			SetSingleNodeAttribute  ("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis" , "Name", "Primary");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis/Style/FontSize", "8pt");
			SetSingleNode           ("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis/Style/Format"  , sCategoryAxesFormat);  // sCategoryFormat  MM/dd/yyyy
			SetSingleNode           ("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis/ChartAxisTitle/Caption"                , sCategoryTitle);
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis/ChartAxisTitle/Style/FontSize"         , "8pt"      );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis/ChartMajorGridLines/Style/Border/Color", "Gainsboro");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis/ChartMinorGridLines/Style/Border/Color", "Gainsboro");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis/ChartMinorGridLines/Style/Border/Style", "Dotted"   );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis/ChartMinorTickMarks/Length"            , "0.5"      );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis/CrossAt", "NaN");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis/Minimum", "NaN");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis/Maximum", "NaN");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis/ChartAxisScaleBreak/Style", String.Empty);

			//SetSingleNode         ("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartValueAxes/ChartAxis", String.Empty);
			SetSingleNodeAttribute  ("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartValueAxes/ChartAxis", "Name", "Primary");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartValueAxes/ChartAxis/Style/FontSize", "8pt");
			SetSingleNode           ("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartValueAxes/ChartAxis/ChartAxisTitle/Caption"       , sSeriesTitle);
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartValueAxes/ChartAxis/ChartAxisTitle/Style/FontSize", "8pt");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartValueAxes/ChartAxis/ChartMajorGridLines/Enabled"           , "False"    );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartValueAxes/ChartAxis/ChartMajorGridLines/Style/Border/Color", "Gainsboro");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartValueAxes/ChartAxis/ChartMinorGridLines/Style/Border/Color", "Gainsboro");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartValueAxes/ChartAxis/ChartMinorGridLines/Style/Border/Style", "Dotted"   );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartValueAxes/ChartAxis/ChartMinorTickMarks/Length"            , "0.5"      );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartValueAxes/ChartAxis/CrossAt", "NaN");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartValueAxes/ChartAxis/Minimum", "NaN");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartValueAxes/ChartAxis/Maximum", "NaN");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/ChartCategoryAxes/ChartAxis/ChartAxisScaleBreak/Style", String.Empty);

			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartAreas/ChartArea/Style/BackgroundGradientType", "None");

			//SetSingleNode         ("Body/ReportItems/Chart/ChartLegends", String.Empty);
			SetSingleNodeAttribute  ("Body/ReportItems/Chart/ChartLegends/ChartLegend", "Name", "Default");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartLegends/ChartLegend/Style/BackgroundGradientType"     , "None"  );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartLegends/ChartLegend/Style/FontSize"                   , "8pt"   );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartLegends/ChartLegend/ChartLegendTitle/Caption"         , String.Empty);
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartLegends/ChartLegend/ChartLegendTitle/Style/FontSize"  , "8pt"   );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartLegends/ChartLegend/ChartLegendTitle/Style/FontWeight", "Bold"  );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartLegends/ChartLegend/ChartLegendTitle/Style/TextAlign" , "Center");

			//SetSingleNode         ("Body/ReportItems/Chart/ChartTitles", String.Empty);
			SetSingleNodeAttribute  ("Body/ReportItems/Chart/ChartTitles/ChartTitle", "Name", "Default");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartTitles/ChartTitle/Caption", sChartTitle);
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartTitles/ChartTitle/Style/BackgroundGradientType", "None"   );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartTitles/ChartTitle/Style/FontWeight"            , "Bold"   );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartTitles/ChartTitle/Style/TextAlign"             , "General");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartTitles/ChartTitle/Style/VerticalAlign"         , "Top"    );

			SetSingleNode         ("Body/ReportItems/Chart/Palette", "BrightPastel");

			//SetSingleNode         ("Body/ReportItems/Chart/ChartBorderSkin", String.Empty);
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartBorderSkin/Style/BackgroundColor"       , "Gray" );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartBorderSkin/Style/BackgroundGradientType", "None" );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartBorderSkin/Style/Color"                 , "White");

			//SetSingleNode         ("Body/ReportItems/Chart/ChartNoDataMessage", String.Empty);
			SetSingleNodeAttribute  ("Body/ReportItems/Chart/ChartNoDataMessage", "Name", "NoDataMessage");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartNoDataMessage/Caption"                     , "No Data Available");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartNoDataMessage/Style/BackgroundGradientType", "None"   );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartNoDataMessage/Style/TextAlign"             , "General");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/ChartNoDataMessage/Style/VerticalAlign"         , "Top"    );

			SetSingleNode           ("Body/ReportItems/Chart/DataSetName", "dataSet");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/Top"        , ".5in" );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/Left"       , ".5in" );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/Height"     , "4.0in");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/Width"      , "6.0in");

			SetSingleNode_InsertOnly("Body/ReportItems/Chart/Style/Border/Color"          , "LightGrey");
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/Style/Border/Style"          , "Solid"    );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/Style/BackgroundColor"       , "White"    );
			SetSingleNode_InsertOnly("Body/ReportItems/Chart/Style/BackgroundGradientType", "None"     );

			// 03/12/2012 Paul.  The chart needs the Page tags in order to be a valid RDL. 
			SetSingleNode_InsertOnly("Page/LeftMargin"  , "0.5in");
			SetSingleNode_InsertOnly("Page/RightMargin" , "0.5in");
			SetSingleNode_InsertOnly("Page/TopMargin"   , "0.5in");
			SetSingleNode_InsertOnly("Page/BottomMargin", "0.5in");
		}
		
		public string CommandText()
		{
			XmlNodeList nlDataSets = this.SelectNodesNS("DataSets/DataSet");
			foreach ( XmlNode xDataSet in nlDataSets )
			{
				return XmlUtil.SelectSingleNode(xDataSet, "Query/CommandText", nsmgr);
			}
			return String.Empty;
		}

		public string LookupDateField(string sFieldID)
		{
			string sDataField = String.Empty;
			if ( sFieldID.IndexOf("Fields!") > 0 )
			{
				string sFieldName = sFieldID.Split('!')[1];
				sFieldName = sFieldName.Replace(".Value", "");
				sFieldName = sFieldName.Replace(")", "");
				sDataField = this.SelectNodeValue("DataSets/DataSet/Fields/Field[@Name='" + sFieldName + "']/DataField");
			}
			else
			{
				sDataField = this.SelectNodeValue("DataSets/DataSet/Fields/Field[@Name='" + sFieldID + "']/DataField");
			}
			return sDataField;
		}

		public string LookupDateFieldType(string sFieldID)
		{
			string sTypeName = String.Empty;
			if ( sFieldID.IndexOf("Fields!") > 0 )
			{
				string sFieldName = sFieldID.Split('!')[1];
				sFieldName = sFieldName.Replace(".Value", "");
				sFieldName = sFieldName.Replace(")", "");
				sTypeName = this.SelectNodeValue("DataSets/DataSet/Fields/Field[@Name='" + sFieldName + "']/rd:TypeName");
			}
			else
			{
				sTypeName = this.SelectNodeValue("DataSets/DataSet/Fields/Field[@Name='" + sFieldID + "']/rd:TypeName");
			}
			return sTypeName;
		}

		protected static string RdlValue(string sValue)
		{
			if ( sValue.StartsWith("=") )
			{
				sValue = sValue.Substring(1);
				if ( sValue.StartsWith("\"") && sValue.EndsWith("\"") )
				{
					sValue = sValue.Substring(1, sValue.Length - 2);
					sValue = sValue.Replace("\"\"", "\"");
				}
			}
			return sValue;
		}

		public static string RdlParameterName(string sDATA_FIELD, int nParameterIndex, bool bSecondary)
		{
			//
			return "@" + RdlDocument.RdlName(sDATA_FIELD) + "__" + nParameterIndex.ToString("00") + (bSecondary ? "B" : "A");
		}

		public static string RdlFieldFromParameter(string sName)
		{
			// 07/13/2006 Paul.  The field name now always starts with @ and ends with __00A, with the last two digits being the parameter index. 
			if ( sName.StartsWith("@") )
			{
				if ( sName.EndsWith("A") || sName.EndsWith("B") )
					return sName.Substring(1, sName.Length - 6);
			}
			return sName;
		}

		public void ReportViewerFixups()
		{
			// 07/13/2006 Paul.  The ReportViewer does not know how to translate the date functions. 
			// These functions should work fine on the report server, so we are just going to work-around the ReportViewer problems. 
			XmlNodeList nlQueryParameters = this.SelectNodesNS("DataSets/DataSet/Query/QueryParameters/QueryParameter");
			foreach ( XmlNode xQueryParameter in nlQueryParameters )
			{
				string sName      = xQueryParameter.Attributes.GetNamedItem("Name").Value;
				string sValue     = this.SelectNodeValue(xQueryParameter, "Value");
				// 07/13/2006 Paul.  The field name now always starts with @ and ends with __00A, with the last two digits being the parameter index. 
				string sFieldName = RdlFieldFromParameter(sName);
				string sTypeName = this.SelectNodeValue("DataSets/DataSet/Fields/Field[@Name='" + sFieldName + "']/rd:TypeName");
				sValue = RdlValue(sValue);
				switch ( sTypeName )
				{
					case "System.DateTime":
					{
						switch ( sValue.ToUpper() )
						{
							case "GETDATE()"                         :  this.SetSingleNode(xQueryParameter, "Value", DateTime.Now                      .ToString()         );  break;
							case "TODAY()"                           :  this.SetSingleNode(xQueryParameter, "Value", DateTime.Today                    .ToShortDateString());  break;
							case "DATEADD(DAY, -1, TODAY())"         :  this.SetSingleNode(xQueryParameter, "Value", DateTime.Today.AddDays( -1)       .ToShortDateString());  break;
							case "DATEADD(DAY, 1, TODAY())"          :  this.SetSingleNode(xQueryParameter, "Value", DateTime.Today.AddDays(  1)       .ToShortDateString());  break;
							case "MONTH(TODAY())"                    :  this.SetSingleNode(xQueryParameter, "Value", DateTime.Today.Month              .ToString()         );  break;
							case "MONTH(DATEADD(MONTH, -1, TODAY()))":  this.SetSingleNode(xQueryParameter, "Value", DateTime.Today.AddMonths(-1).Month.ToString()         );  break;
							case "MONTH(DATEADD(MONTH, 1, TODAY()))" :  this.SetSingleNode(xQueryParameter, "Value", DateTime.Today.AddMonths( 1).Month.ToString()         );  break;
							case "YEAR(DATEADD(MONTH, -1, TODAY()))" :  this.SetSingleNode(xQueryParameter, "Value", DateTime.Today.AddMonths(-1).Year .ToString()         );  break;
							case "YEAR(DATEADD(MONTH, 1, TODAY()))"  :  this.SetSingleNode(xQueryParameter, "Value", DateTime.Today.AddMonths( 1).Year .ToString()         );  break;
							case "YEAR(TODAY())"                     :  this.SetSingleNode(xQueryParameter, "Value", DateTime.Today.Year               .ToString()         );  break;
							case "YEAR(DATEADD(YEAR, -1, TODAY()))"  :  this.SetSingleNode(xQueryParameter, "Value", DateTime.Today.AddYears(-1).Year  .ToString()         );  break;
							case "YEAR(DATEADD(YEAR, 1, TODAY()))"   :  this.SetSingleNode(xQueryParameter, "Value", DateTime.Today.AddYears( 1).Year  .ToString()         );  break;
							case "DATEADD(DAY, -7, TODAY())"         :  this.SetSingleNode(xQueryParameter, "Value", DateTime.Today.AddDays( -7)       .ToShortDateString());  break;
							case "DATEADD(DAY, 7, TODAY())"          :  this.SetSingleNode(xQueryParameter, "Value", DateTime.Today.AddDays(  7)       .ToShortDateString());  break;
							case "DATEADD(DAY, -30, TODAY())"        :  this.SetSingleNode(xQueryParameter, "Value", DateTime.Today.AddDays(-30)       .ToShortDateString());  break;
							case "DATEADD(DAY, 30, TODAY())"         :  this.SetSingleNode(xQueryParameter, "Value", DateTime.Today.AddDays( 30)       .ToShortDateString());  break;
						}
						break;
					}
				}
			}
			// 10/06/2012 Paul.  Move the DataSourceReference fix to ReportViewerFixups.
			XmlNodeList nlDataSets = this.SelectNodesNS("DataSets/DataSet");
			foreach ( XmlNode xDataSet in nlDataSets )
			{
				string sDataSetName = xDataSet.Attributes.GetNamedItem("Name").Value;
				// 12/21/2009 Paul.  The new VS 2010 ReportViewer does not like the DataSourceReference.  
				// Replace it with an empty connection string. 
				string sDataSourceName = this.SelectNodeValue(xDataSet, "Query/DataSourceName");
				XmlNode xDataSource = this.SelectNode("DataSources/DataSource[@Name='" + sDataSourceName + "']");
				if ( xDataSource != null )
				{
					XmlNode xDataSourceReference = xDataSource.SelectSingleNode("defaultns:DataSourceReference", this.NamespaceManager);
					if ( xDataSourceReference != null )
					{
						//xDataSource.RemoveChild(xDataSourceReference);
						/*
						// 01/21/2010 Paul.  This loop did not remove all nodes.  Use RemoveAll() instead. 
						foreach ( XmlNode xChild in xDataSource.ChildNodes )
						{
							xDataSource.RemoveChild(xChild);
						}
						*/
						xDataSource.RemoveAll();
						// 01/24/2010 Paul.  RemoveAll will also remove the Name attribute, which is required. 
						// An error occurred during local report processing.  
						// The definition of the report '' is invalid.  
						// The report definition is not valid.  Details: The required attribute 'Name' is missing.
						XmlAttribute attrName = this.CreateAttribute("Name");
						attrName.Value = sDataSourceName;
						xDataSource.Attributes.SetNamedItem(attrName);
						this.SetSingleNode(xDataSource, "ConnectionProperties/DataProvider", "SQL");
						this.SetSingleNode(xDataSource, "ConnectionProperties/ConnectString", "ConnectString");
					}
				}
			}
		}

		// 11/16/2008 Paul.  DbSpecificDate is only called from the workflow engine, so it is safe to convert TODAY() for SQL Server. 
		public static string DbSpecificDate(string sSplendidProvider, string sValue)
		{
			sValue = sValue.ToUpper();
			if ( sSplendidProvider == "System.Data.OracleClient" || sSplendidProvider == "Oracle.DataAccess.Client" )
			{
				switch ( sValue )
				{
					// http://www.techonthenet.com/oracle/functions/trunc_date.php
					case "GETDATE()"                         :  sValue = "sysdate"                                             ;  break;  // 
					case "TODAY()"                           :  sValue = "trunc(sysdate)"                                      ;  break;  // tp_today
					case "DATEADD(DAY, -1, TODAY())"         :  sValue = "trunc(sysdate)-1"                                    ;  break;  // tp_yesterday
					case "DATEADD(DAY, 1, TODAY())"          :  sValue = "trunc(sysdate)+1"                                    ;  break;  // tp_tomorrow
					case "MONTH(TODAY())"                    :  sValue = "to_number(to_char(sysdate, 'mm'))"                   ;  break;  // tp_this_month
					case "MONTH(DATEADD(MONTH, -1, TODAY()))":  sValue = "to_number(to_char(add_months(sysdate, -1), 'mm'))"   ;  break;  // tp_last_month
					case "MONTH(DATEADD(MONTH, 1, TODAY()))" :  sValue = "to_number(to_char(add_months(sysdate, 1), 'mm'))"    ;  break;  // tp_next_month
					case "YEAR(DATEADD(MONTH, -1, TODAY()))" :  sValue = "to_number(to_char(add_months(sysdate, -1), 'yyyy'))" ;  break;  // year of tp_last_month
					case "YEAR(DATEADD(MONTH, 1, TODAY()))"  :  sValue = "to_number(to_char(add_months(sysdate, 1), 'yyyy'))"  ;  break;  // year of tp_next_month
					case "YEAR(TODAY())"                     :  sValue = "to_number(to_char(sysdate, 'yyyy'))"                 ;  break;  // tp_this_year
					case "YEAR(DATEADD(YEAR, -1, TODAY()))"  :  sValue = "to_number(to_char(sysdate, 'yyyy'))-1"               ;  break;  // tp_last_year
					case "YEAR(DATEADD(YEAR, 1, TODAY()))"   :  sValue = "to_number(to_char(sysdate, 'yyyy'))+1"               ;  break;  // tp_next_year
					case "DATEADD(DAY, -7, TODAY())"         :  sValue = "trunc(sysdate)-7"                                    ;  break;  // tp_last_7_days
					case "DATEADD(DAY, 7, TODAY())"          :  sValue = "trunc(sysdate)+7"                                    ;  break;  // tp_next_7_days
					case "DATEADD(DAY, -30, TODAY())"        :  sValue = "trunc(sysdate)-30"                                   ;  break;  // tp_last_30_days
					case "DATEADD(DAY, 30, TODAY())"         :  sValue = "trunc(sysdate)+30"                                   ;  break;  // tp_next_30_days
				}
			}
			else if ( sSplendidProvider == "MySql.Data" )
			{
				switch ( sValue )
				{
					// http://dev.mysql.com/doc/refman/5.0/en/date-and-time-functions.html
					case "GETDATE()"                         :  sValue = "now()"                                        ;  break;  // 
					case "TODAY()"                           :  sValue = "curdate()"                                    ;  break;  // tp_today
					case "DATEADD(DAY, -1, TODAY())"         :  sValue = "date_sub(curdate(), interval 1 day)"          ;  break;  // tp_yesterday
					case "DATEADD(DAY, 1, TODAY())"          :  sValue = "date_add(curdate(), interval 1 day)"          ;  break;  // tp_tomorrow
					case "MONTH(TODAY())"                    :  sValue = "month(curdate())"                             ;  break;  // tp_this_month
					case "MONTH(DATEADD(MONTH, -1, TODAY()))":  sValue = "month(date_sub(curdate(), interval 1 month))" ;  break;  // tp_last_month
					case "MONTH(DATEADD(MONTH, 1, TODAY()))" :  sValue = "month(date_add(curdate(), interval 1 month))" ;  break;  // tp_next_month
					case "YEAR(DATEADD(MONTH, -1, TODAY()))" :  sValue = "year(date_sub(curdate(), interval 1 month))"  ;  break;  // year of tp_last_month
					case "YEAR(DATEADD(MONTH, 1, TODAY()))"  :  sValue = "year(date_add(curdate(), interval 1 month))"  ;  break;  // year of tp_next_month
					case "YEAR(TODAY())"                     :  sValue = "year(curdate())"                              ;  break;  // tp_this_year
					case "YEAR(DATEADD(YEAR, -1, TODAY()))"  :  sValue = "year(date_sub(curdate(), interval 1 year))"   ;  break;  // tp_last_year
					case "YEAR(DATEADD(YEAR, 1, TODAY()))"   :  sValue = "year(date_add(curdate(), interval 1 year))"   ;  break;  // tp_next_year
					case "DATEADD(DAY, -7, TODAY())"         :  sValue = "date_sub(curdate(), interval 7 day)"          ;  break;  // tp_last_7_days
					case "DATEADD(DAY, 7, TODAY())"          :  sValue = "date_add(curdate(), interval 7 day)"          ;  break;  // tp_next_7_days
					case "DATEADD(DAY, -30, TODAY())"        :  sValue = "date_sub(curdate(), interval 30 day)"         ;  break;  // tp_last_30_days
					case "DATEADD(DAY, 30, TODAY())"         :  sValue = "date_add(curdate(), interval 30 day)"         ;  break;  // tp_next_30_days
				}
			}
			else if ( sSplendidProvider == "IBM.Data.DB2" )
			{
				switch ( sValue )
				{
					// http://www.ibm.com/developerworks/db2/library/techarticle/0211yip/0211yip3.html
					case "GETDATE()"                         :  sValue = "current timestamp"            ;  break;  // 
					case "TODAY()"                           :  sValue = "current date"                 ;  break;  // tp_today
					case "DATEADD(DAY, -1, TODAY())"         :  sValue = "current date - 1 day"         ;  break;  // tp_yesterday
					case "DATEADD(DAY, 1, TODAY())"          :  sValue = "current date + 1 day"         ;  break;  // tp_tomorrow
					case "MONTH(TODAY())"                    :  sValue = "month(current date)"          ;  break;  // tp_this_month
					case "MONTH(DATEADD(MONTH, -1, TODAY()))":  sValue = "month(current date - 1 month)";  break;  // tp_last_month
					case "MONTH(DATEADD(MONTH, 1, TODAY()))" :  sValue = "month(current date + 1 month)";  break;  // tp_next_month
					case "YEAR(DATEADD(MONTH, -1, TODAY()))" :  sValue = "year(current date - 1 month)" ;  break;  // year of tp_last_month
					case "YEAR(DATEADD(MONTH, 1, TODAY()))"  :  sValue = "year(current date + 1 month)" ;  break;  // year of tp_next_month
					case "YEAR(TODAY())"                     :  sValue = "year(current date)"           ;  break;  // tp_this_year
					case "YEAR(DATEADD(YEAR, -1, TODAY()))"  :  sValue = "year(current date - 1 year)"  ;  break;  // tp_last_year
					case "YEAR(DATEADD(YEAR, 1, TODAY()))"   :  sValue = "year(current date + 1 year)"  ;  break;  // tp_next_year
					case "DATEADD(DAY, -7, TODAY())"         :  sValue = "current date - 7 days"        ;  break;  // tp_last_7_days
					case "DATEADD(DAY, 7, TODAY())"          :  sValue = "current date + 7 days"        ;  break;  // tp_next_7_days
					case "DATEADD(DAY, -30, TODAY())"        :  sValue = "current date - 30 days"       ;  break;  // tp_last_30_days
					case "DATEADD(DAY, 30, TODAY())"         :  sValue = "current date + 30 days"       ;  break;  // tp_next_30_days
				}
			}
			else if ( sSplendidProvider == "Npgsql" )
			{
				switch ( sValue )
				{
					// http://www.postgresql.org/docs/8.0/interactive/functions-datetime.html
					case "GETDATE()"                         :  sValue = "current_timestamp"                                    ;  break;  // 
					case "TODAY()"                           :  sValue = "current_date"                                         ;  break;  // tp_today
					case "DATEADD(DAY, -1, TODAY())"         :  sValue = "current_date - interval '1 day'"                      ;  break;  // tp_yesterday
					case "DATEADD(DAY, 1, TODAY())"          :  sValue = "current_date + interval '1 day'"                      ;  break;  // tp_tomorrow
					case "MONTH(TODAY())"                    :  sValue = "date_part('month', current_date)"                     ;  break;  // tp_this_month
					case "MONTH(DATEADD(MONTH, -1, TODAY()))":  sValue = "date_part('month', current_date - interval '1 month')";  break;  // tp_last_month
					case "MONTH(DATEADD(MONTH, 1, TODAY()))" :  sValue = "date_part('month', current_date + interval '1 month')";  break;  // tp_next_month
					case "YEAR(DATEADD(MONTH, -1, TODAY()))" :  sValue = "date_part('year', current_date - interval '1 month')" ;  break;  // year of tp_last_month
					case "YEAR(DATEADD(MONTH, 1, TODAY()))"  :  sValue = "date_part('year', current_date + interval '1 month')" ;  break;  // year of tp_next_month
					case "YEAR(TODAY())"                     :  sValue = "date_part('year', current_date)"                      ;  break;  // tp_this_year
					case "YEAR(DATEADD(YEAR, -1, TODAY()))"  :  sValue = "date_part('year', current_date - interval '1 year')"  ;  break;  // tp_last_year
					case "YEAR(DATEADD(YEAR, 1, TODAY()))"   :  sValue = "date_part('year', current_date + interval '1 year')"  ;  break;  // tp_next_year
					case "DATEADD(DAY, -7, TODAY())"         :  sValue = "current_date - interval '7 days'"                     ;  break;  // tp_last_7_days
					case "DATEADD(DAY, 7, TODAY())"          :  sValue = "current_date + interval '7 days'"                     ;  break;  // tp_next_7_days
					case "DATEADD(DAY, -30, TODAY())"        :  sValue = "current_date - interval '30 days'"                    ;  break;  // tp_last_30_days
					case "DATEADD(DAY, 30, TODAY())"         :  sValue = "current_date + interval '30 days'"                    ;  break;  // tp_next_30_days
				}
			}
			else if ( sSplendidProvider == "System.Data.SqlClient" )
			{
				// 11/20/2008 Paul.  SQL Server does not define the TODAY() function, so we must translate. 
				switch ( sValue )
				{
					case "GETDATE()"                         :  sValue = "getdate()"                                   ;  break;  // 
					case "TODAY()"                           :  sValue = "dbo.fnDateOnly(getdate())"                   ;  break;  // tp_today
					case "DATEADD(DAY, -1, TODAY())"         :  sValue = "dateadd(day, -1, dbo.fnDateOnly(getdate()))" ;  break;  // tp_yesterday
					case "DATEADD(DAY, 1, TODAY())"          :  sValue = "dateadd(day, 1, dbo.fnDateOnly(getdate()))"  ;  break;  // tp_tomorrow
					case "MONTH(TODAY())"                    :  sValue = "month(getdate())"                            ;  break;  // tp_this_month
					case "MONTH(DATEADD(MONTH, -1, TODAY()))":  sValue = "month(dateadd(month, -1, getdate()))"        ;  break;  // tp_last_month
					case "MONTH(DATEADD(MONTH, 1, TODAY()))" :  sValue = "month(dateadd(month, 1, getdate()))"         ;  break;  // tp_next_month
					case "YEAR(DATEADD(MONTH, -1, TODAY()))" :  sValue = "year(dateadd(month, -1, getdate()))"         ;  break;  // year of tp_last_month
					case "YEAR(DATEADD(MONTH, 1, TODAY()))"  :  sValue = "year(dateadd(month, 1, getdate()))"          ;  break;  // year of tp_next_month
					case "YEAR(TODAY())"                     :  sValue = "year(getdate())"                             ;  break;  // tp_this_year
					case "YEAR(DATEADD(YEAR, -1, TODAY()))"  :  sValue = "year(dateadd(year, -1, getdate()))"          ;  break;  // tp_last_year
					case "YEAR(DATEADD(YEAR, 1, TODAY()))"   :  sValue = "year(dateadd(year, 1, getdate()))"           ;  break;  // tp_next_year
					case "DATEADD(DAY, -7, TODAY())"         :  sValue = "dateadd(day, -7, dbo.fnDateOnly(getdate()))" ;  break;  // tp_last_7_days
					case "DATEADD(DAY, 7, TODAY())"          :  sValue = "dateadd(day, 7, dbo.fnDateOnly(getdate()))"  ;  break;  // tp_next_7_days
					case "DATEADD(DAY, -30, TODAY())"        :  sValue = "dateadd(day, -30, dbo.fnDateOnly(getdate()))";  break;  // tp_last_30_days
					case "DATEADD(DAY, 30, TODAY())"         :  sValue = "dateadd(day, 30, dbo.fnDateOnly(getdate()))" ;  break;  // tp_next_30_days
				}
			}
			return sValue;
		}

		public void BuildCommand(HttpContext Context, XmlNode xDataSet, IDbCommand cmd)
		{
			// 03/14/2011 Paul.  Oracle can have date formatting issues, so force a .NET friendly date format. 
			if ( Sql.IsOracle(cmd) )
			{
				// 03/14/2011 Paul.  Make sure not to include a trailing semicolon, otherwise we will get the error: ORA-00911: invalid character. 
				cmd.CommandText = "ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD HH24:MI:SS'";
				cmd.ExecuteNonQuery();
			}
			cmd.CommandText = XmlUtil.SelectSingleNode(xDataSet, "Query/CommandText", nsmgr);
			// 01/30/2012 Paul.  Make sure to set the command type if it is a stored procedure. 
			if ( XmlUtil.SelectSingleNode(xDataSet, "Query/CommandType", nsmgr) == "StoredProcedure" )
				cmd.CommandType = CommandType.StoredProcedure;
			if ( Sql.IsEmptyString(cmd.CommandText) && !Sql.IsEmptyString(XmlUtil.SelectSingleNode(xDataSet, "SharedDataSet/SharedDataSetReference", nsmgr)) )
			{
				string sSharedDataSetReference = XmlUtil.SelectSingleNode(xDataSet, "SharedDataSet/SharedDataSetReference", nsmgr);
				if ( sSharedDataSetReference.StartsWith("/") )
					sSharedDataSetReference = sSharedDataSetReference.Substring(1);
				if ( sSharedDataSetReference.EndsWith(".rds") )
					sSharedDataSetReference = sSharedDataSetReference.Substring(0, sSharedDataSetReference.Length - 4);
				if ( sSharedDataSetReference.StartsWith("vw") )
				{
					string sVIEW_NAME  = sSharedDataSetReference;
					string sTABLE_NAME = sVIEW_NAME.Substring(2, sVIEW_NAME.Length - 2);
					DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
					using ( DataTable dtColumns = new DataTable() )
					{
						string sSQL;
						sSQL = "select ColumnName              " + ControlChars.CrLf
						     + "  from vwSqlColumns            " + ControlChars.CrLf
						     + " where ObjectName = @OBJECTNAME" + ControlChars.CrLf
						     + " order by colid                " + ControlChars.CrLf;
						
						cmd.CommandText = sSQL;
						// 02/20/2016 Paul.  Make sure to use upper case for Oracle. 
						Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, sVIEW_NAME));
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dtColumns);
						}
						StringBuilder sbCommandText = new StringBuilder();
						foreach ( DataRow rowColumn in dtColumns.Rows )
						{
							string sColumnName = Sql.ToString (rowColumn["ColumnName"]).ToUpper();
							if ( sbCommandText.Length == 0 )
								sbCommandText.AppendLine("select " + sTABLE_NAME + "." + sColumnName);
							else
								sbCommandText.AppendLine("     , " + sTABLE_NAME + "." + sColumnName);
						}
						sbCommandText.AppendLine("  from " + sVIEW_NAME + " " + sTABLE_NAME);
						cmd.CommandText = sbCommandText.ToString();
						cmd.Parameters.Clear();
					}
					bool bWhereFilter = true;
					XmlNodeList nlFilters = this.SelectNodesNS(xDataSet, "Filters/Filter");
					foreach ( XmlNode xFilter in nlFilters )
					{
						string      sFilterExpression = this.SelectNodeValue(xFilter, "FilterExpression");
						string      sOperator         = this.SelectNodeValue(xFilter, "Operator"        );
						sFilterExpression = RdlValue(sFilterExpression);
						if ( sFilterExpression.StartsWith("Fields!") && sFilterExpression.EndsWith(".Value") )
						{
							if ( bWhereFilter )
								cmd.CommandText += " where ";
							else
								cmd.CommandText += "   and ";
							
							string sFieldName = sFilterExpression.Substring(7, sFilterExpression.Length-7-6);
							cmd.CommandText += sFieldName + " ";
							if ( sOperator == "Between" )
							{
								string sValueA = String.Empty;
								string sValueB = String.Empty;
								XmlNodeList nlFilterValues = this.SelectNodesNS  (xFilter, "FilterValues/FilterValue");
								if ( nlFilterValues.Count > 0 )
									sValueA = nlFilterValues[0].InnerText;
								if ( nlFilterValues.Count > 1 )
									sValueB = nlFilterValues[1].InnerText;
								cmd.CommandText += "between @" + sFieldName + "__A and @" + sFieldName + "__B" + ControlChars.CrLf;
								Sql.AddParameter(cmd, "@" + sFieldName + "__A", sValueA);
								Sql.AddParameter(cmd, "@" + sFieldName + "__B", sValueB);
							}
							else if ( sOperator == "In" )
							{
								cmd.CommandText += "in (";
								XmlNodeList nlFilterValues = this.SelectNodesNS  (xFilter, "FilterValues/FilterValue");
								for ( int i = 0; i < nlFilterValues.Count; i++ )
								{
									XmlNode xFilterValue = nlFilterValues[i];
									if ( i > 0 )
										cmd.CommandText += ", ";
									cmd.CommandText += "@" + sFieldName + "__" + i.ToString("000");
									Sql.AddParameter(cmd, "@" + sFieldName + "__" + i.ToString("000"), xFilterValue.InnerText);
								}
								cmd.CommandText += ")" + ControlChars.CrLf;
							}
							else
							{
								string sValue = this.SelectNodeValue(xFilter, "FilterValues/FilterValue");
								switch ( sOperator )
								{
									case "Equal"             :  cmd.CommandText += "="   ;  break;
									case "NotEqual"          :  cmd.CommandText += "<>"  ;  break;
									case "GreaterThan"       :  cmd.CommandText += ">"   ;  break;
									case "GreaterThanOrEqual":  cmd.CommandText += ">="  ;  break;
									case "LessThan"          :  cmd.CommandText += "<"   ;  break;
									case "LessThanOrEqual"   :  cmd.CommandText += "<="  ;  break;
									case "Like"              :
										cmd.CommandText += "like";
										if ( sValue.IndexOf('*') >= 0 )
										{
											sValue = sValue.Replace(@"\", @"\\");
											sValue = sValue.Replace("%" , @"\%");
											sValue = sValue.Replace("*" , "%"  );
										}
										else
										{
											sValue = "%" + sValue + "%";
										}
										break;
									default:
										throw(new Exception(sOperator + " is not currently supported."));
								}
								cmd.CommandText += " @" + sFieldName + ControlChars.CrLf;
								Sql.AddParameter(cmd, "@" + sFieldName, sValue);
							}
						}
					}
					XmlNodeList nlDataSetQueryParameters = this.SelectNodesNS(xDataSet, "SharedDataSet/QueryParameters/QueryParameter");
					foreach ( XmlNode xQueryParameter in nlDataSetQueryParameters )
					{
						BuildCommandQueryParameter(xDataSet, xQueryParameter, cmd);
					}
				}
				else
				{
					throw(new Exception("Unknown shared dataset: " + sSharedDataSetReference));
				}
			}
			// 07/12/2006 Paul.  If not SQL Server and not Sybase, then we must remove the DBO. 
			if ( !Sql.IsSQLServer(cmd) && !Sql.IsSybase(cmd) )
			{
				cmd.CommandText = cmd.CommandText.Replace(" dbo.fnDateOnly("   , " fnDateOnly("   );
				cmd.CommandText = cmd.CommandText.Replace(" dbo.fnMonthOnly("  , " fnMonthOnly("  );
				cmd.CommandText = cmd.CommandText.Replace(" dbo.fnWeekOnly("   , " fnWeekOnly("   );
				cmd.CommandText = cmd.CommandText.Replace(" dbo.fnQuarterOnly(", " fnQuarterOnly(");
			}
			// 04/17/2007 Paul.  @MEMBERSHIP_USER_ID is a special replacement field that we use to filter results based on ACL rules. 
			// 03/14/2011 Paul.  The special Membership User ID needs to be replaced earlier. 
			//cmd.CommandText = cmd.CommandText.Replace("@MEMBERSHIP_USER_ID", "'" + Security.USER_ID.ToString() + "'");
			// 03/14/2011 Paul.  We should use a parameter. 
			if ( cmd.CommandText.Contains("@MEMBERSHIP_USER_ID") )
				Sql.AddParameter(cmd, "@MEMBERSHIP_USER_ID", Security.USER_ID);
			
			XmlNodeList nlQueryParameters = this.SelectNodesNS(xDataSet, "Query/QueryParameters/QueryParameter");
			foreach ( XmlNode xQueryParameter in nlQueryParameters )
			{
				BuildCommandQueryParameter(xDataSet, xQueryParameter, cmd);
			}
		}

		public void BuildCommandQueryParameter(XmlNode xDataSet, XmlNode xQueryParameter, IDbCommand cmd)
		{
			string sName      = xQueryParameter.Attributes.GetNamedItem("Name").Value;
			string sValue     = this.SelectNodeValue(xQueryParameter, "Value");
			// 07/13/2006 Paul.  The field name now always starts with @ and ends with __00A, with the last two digits being the parameter index. 
			string sFieldName = RdlFieldFromParameter(sName);

			string  sTypeName = String.Empty;
			XmlNode xTypeName = XmlUtil.SelectNode(xDataSet, "Fields/Field[@Name='" + sFieldName + "']/rd:TypeName", nsmgr);
			if ( xTypeName != null )
				sTypeName = xTypeName.InnerText;

			sValue = RdlValue(sValue);
			if ( sValue.StartsWith("Parameters!") && sValue.EndsWith(".Value") )
			{
				string sParameterName = sValue.Substring(11, sValue.Length-11-6);
				XmlNode xReportParameterValue = this.SelectNode("ReportParameters/ReportParameter[@Name='" + sParameterName + "']/DefaultValue/Values/Value");
				if ( xReportParameterValue != null )
				{
					sValue = xReportParameterValue.InnerText;
					// 10/24/2007 Paul.  The ReportViewer will complain if the query parameter does not have a value. 
					this.SetSingleNode(xQueryParameter, "Value", sValue);
					// 03/04/2012 Paul.  If there are multiple values, then we need to parse the SQL manually. 
					if ( xReportParameterValue.ParentNode.ChildNodes.Count > 1 )
					{
						StringBuilder sbValues = new StringBuilder();
						foreach ( XmlNode xValue in xReportParameterValue.ParentNode.ChildNodes )
						{
							if ( sbValues.Length > 0 )
								sbValues.Append(", ");
							sbValues.Append("\'" + Sql.EscapeSQL(xValue.InnerText) + "\'");
						}
						cmd.CommandText = cmd.CommandText.Replace(sName, sbValues.ToString());
						return;
					}
				}
			}
			// 09/26/2010 Paul.  ReportBuilder 3.0 does not always include the System. in the type name. 
			if ( sTypeName.StartsWith("System.") )
				sTypeName = sTypeName.Substring(7);
			switch ( sTypeName )
			{
				case "Guid"    :  Sql.AddParameter(cmd, sName, Sql.ToGuid    (sValue));  break;
				case "Boolean" :  Sql.AddParameter(cmd, sName, Sql.ToBoolean (sValue));  break;
				case "Double"  :  Sql.AddParameter(cmd, sName, Sql.ToFloat   (sValue));  break;
				case "Decimal" :  Sql.AddParameter(cmd, sName, Sql.ToDecimal (sValue));  break;
				case "Int16"   :  Sql.AddParameter(cmd, sName, Sql.ToInteger (sValue));  break;
				case "Int32"   :  Sql.AddParameter(cmd, sName, Sql.ToInteger (sValue));  break;
				case "Int64"   :  Sql.AddParameter(cmd, sName, Sql.ToInteger (sValue));  break;
				case "DateTime":
				{
					switch ( sValue.ToUpper() )
					{
						case "TODAY()"                           :  Sql.AddParameter(cmd, sName, DateTime.Today)             ;  break;
						case "DATEADD(DAY, -1, TODAY())"         :  Sql.AddParameter(cmd, sName, DateTime.Today.AddDays( -1));  break;
						case "DATEADD(DAY, 1, TODAY())"          :  Sql.AddParameter(cmd, sName, DateTime.Today.AddDays(  1));  break;
						case "MONTH(TODAY())"                    :  Sql.AddParameter(cmd, sName, DateTime.Today.Month)       ;  break;
						case "MONTH(DATEADD(MONTH, -1, TODAY()))":  Sql.AddParameter(cmd, sName, DateTime.Today.AddMonths(-1).Month);  break;
						case "MONTH(DATEADD(MONTH, 1, TODAY()))" :  Sql.AddParameter(cmd, sName, DateTime.Today.AddMonths( 1).Month);  break;
						case "YEAR(DATEADD(MONTH, -1, TODAY()))" :  Sql.AddParameter(cmd, sName, DateTime.Today.AddMonths(-1).Year );  break;
						case "YEAR(DATEADD(MONTH, 1, TODAY()))"  :  Sql.AddParameter(cmd, sName, DateTime.Today.AddMonths( 1).Year );  break;
						case "YEAR(TODAY())"                     :  Sql.AddParameter(cmd, sName, DateTime.Today.Year)               ;  break;
						case "YEAR(DATEADD(YEAR, -1, TODAY()))"  :  Sql.AddParameter(cmd, sName, DateTime.Today.AddYears(-1).Year)  ;  break;
						case "YEAR(DATEADD(YEAR, 1, TODAY()))"   :  Sql.AddParameter(cmd, sName, DateTime.Today.AddYears( 1).Year)  ;  break;
						case "DATEADD(DAY, -7, TODAY())"         :  Sql.AddParameter(cmd, sName, DateTime.Today.AddDays( -7));  break;
						case "DATEADD(DAY, 7, TODAY())"          :  Sql.AddParameter(cmd, sName, DateTime.Today.AddDays(  7));  break;
						case "DATEADD(DAY, -30, TODAY())"        :  Sql.AddParameter(cmd, sName, DateTime.Today.AddDays(-30));  break;
						case "DATEADD(DAY, 30, TODAY())"         :  Sql.AddParameter(cmd, sName, DateTime.Today.AddDays( 30));  break;
						default                                  :  Sql.AddParameter(cmd, sName, Sql.ToDateTime(sValue))     ;  break;
					}
					break;
				}
				case "String"  :  Sql.AddParameter(cmd, sName, sValue);  break;
				default        :
					// 05/21/2012 Paul.  A date parameter type will be string, so we need another way to detect that the type is a date. 
					// This is so that we can use the correct date format string. 
					if ( sName.StartsWith("@DATE_") || sName.EndsWith("_DATE") || sName.Contains("_DATE_") )
						Sql.AddParameter(cmd, sName, Sql.ToDateTime(sValue));
					else
						Sql.AddParameter(cmd, sName, sValue);
					break;
			}
		}

		public void AddQueryParameter(XmlNode xQueryParameters, string sPARAMETER_NAME, string sDATA_TYPE, string sVALUE)
		{
			XmlNode xQueryParameter = this.CreateElement("QueryParameter", sDefaultNamespace);
			xQueryParameters.AppendChild(xQueryParameter);
			SetSingleNodeAttribute(xQueryParameter, "Name", sPARAMETER_NAME);
			if ( sDATA_TYPE == "string" || sDATA_TYPE == "enum" )
				SetSingleNode(xQueryParameter, "Value", "=\"" + sVALUE.Replace("\"", "\\\"") + "\"");
			else
				SetSingleNode(xQueryParameter, "Value", "=" + sVALUE);
		}

		public void AddQueryParameter(XmlNode xQueryParameters, string sPARAMETER_NAME, string sDATA_TYPE, string sVALUE1, string sVALUE2)
		{
			XmlNode xQueryParameter = this.CreateElement("QueryParameter", sDefaultNamespace);
			xQueryParameters.AppendChild(xQueryParameter);
			SetSingleNodeAttribute(xQueryParameter, "Name", sPARAMETER_NAME + "1");
			if ( sDATA_TYPE == "string" || sDATA_TYPE == "enum" )
				SetSingleNode(xQueryParameter, "Value", "=\"" + sVALUE1.Replace("\"", "\\\"") + "\"");
			else
				SetSingleNode(xQueryParameter, "Value", "=" + sVALUE1);

			xQueryParameter = this.CreateElement("QueryParameter", sDefaultNamespace);
			xQueryParameters.AppendChild(xQueryParameter);
			SetSingleNodeAttribute(xQueryParameter, "Name", sPARAMETER_NAME + "2");
			if ( sDATA_TYPE == "string" || sDATA_TYPE == "enum" )
				SetSingleNode(xQueryParameter, "Value", "=\"" + sVALUE2.Replace("\"", "\\\"") + "\"");
			else
				SetSingleNode(xQueryParameter, "Value", "=" + sVALUE2);
		}

		public void AddReportParameter(XmlNode xReportParameters, string sPARAMETER_NAME, string sDATA_TYPE, bool bNullable, string sPrompt, object oValue)
		{
			XmlNode xReportParameter = this.CreateElement("ReportParameter", sDefaultNamespace);
			xReportParameters.AppendChild(xReportParameter);
			SetSingleNodeAttribute(xReportParameter, "Name", sPARAMETER_NAME);
			switch ( sDATA_TYPE )
			{
				case "bool"    :  SetSingleNode(xReportParameter, "DataType", "Boolean" );  break;
				case "DateTime":  SetSingleNode(xReportParameter, "DataType", "DateTime");  break;
				case "Int16"   :  SetSingleNode(xReportParameter, "DataType", "Integer" );  break;
				case "Int32"   :  SetSingleNode(xReportParameter, "DataType", "Integer" );  break;
				case "Int64"   :  SetSingleNode(xReportParameter, "DataType", "Integer" );  break;
				case "short"   :  SetSingleNode(xReportParameter, "DataType", "Integer" );  break;
				case "float"   :  SetSingleNode(xReportParameter, "DataType", "Float"   );  break;
				case "decimal" :  SetSingleNode(xReportParameter, "DataType", "Float"   );  break;
				case "Guid"    :  SetSingleNode(xReportParameter, "DataType", "String"  );  break;
				case "string"  :  SetSingleNode(xReportParameter, "DataType", "String"  );  break;
				default        :  SetSingleNode(xReportParameter, "DataType", "String"  );  break;
			}
			SetSingleNode(xReportParameter, "AllowBlank", "true");
			SetSingleNode(xReportParameter, "Nullable"  , bNullable ? "true" : "false");
			SetSingleNode(xReportParameter, "Prompt"    , sPrompt);
			if ( oValue != null )
			{
				if ( oValue.GetType().IsArray )
				{
					SetSingleNode(xReportParameter, "MultiValue", "true" );
					// 08/09/2014 Paul.  MultiValue cannot accept null. 
					SetSingleNode(xReportParameter, "Nullable"  , "false");
					XmlNode xDefaultValue = this.CreateElement("DefaultValue", sDefaultNamespace);
					xReportParameter.AppendChild(xDefaultValue);
					XmlNode xValues = this.CreateElement("Values", sDefaultNamespace);
					xDefaultValue.AppendChild(xValues);
					object[] arrValue = oValue as object[];
					for ( int j = 0; j < arrValue.Length; j++ )
					{
						XmlNode xValue = this.CreateElement("Value", sDefaultNamespace);
						xValues.AppendChild(xValue);
						xValue.InnerText = Sql.ToString(arrValue[j]);
					}
				}
				else if ( !Sql.IsEmptyString(oValue) )
				{
					SetSingleNode(xReportParameter, "DefaultValue/Values/Value", Sql.ToString(oValue));
				}
			}
		}

		// 06/02/2021 Paul.  React client needs to share code. 
		public void SetFiltersCustomProperty(Dictionary<string, object> dictFilterXml)
		{
			this.SetCustomProperty("Filters"       , String.Empty);
			if ( dictFilterXml != null )
			{
				XmlDocument xml = new XmlDocument();
				xml.AppendChild(xml.CreateElement("Filters"));
				XmlNode xFilters = xml.DocumentElement;
				if ( dictFilterXml.ContainsKey("Filters") )
				{
					Dictionary<string, object> dictFilters = dictFilterXml["Filters"] as Dictionary<string, object>;
					if ( dictFilters != null )
					{
						if ( dictFilters.ContainsKey("Filter") )
						{
							System.Collections.ArrayList lstFilter = dictFilters["Filter"] as System.Collections.ArrayList;
							if ( lstFilter != null )
							{
								foreach ( Dictionary<string, object> dictFilter in lstFilter )
								{
									XmlNode xFilter = xml.CreateElement("Filter");
									xFilters.AppendChild(xFilter);
									XmlNode xID                 = xml.CreateElement("ID"                );
									XmlNode xMODULE_NAME        = xml.CreateElement("MODULE_NAME"       );
									XmlNode xDATA_FIELD         = xml.CreateElement("DATA_FIELD"        );
									XmlNode xDATA_TYPE          = xml.CreateElement("DATA_TYPE"         );
									XmlNode xOPERATOR           = xml.CreateElement("OPERATOR"          );
									XmlNode xSEARCH_TEXT        = xml.CreateElement("SEARCH_TEXT"       );
									xFilter.AppendChild(xID                );
									xFilter.AppendChild(xMODULE_NAME       );
									xFilter.AppendChild(xDATA_FIELD        );
									xFilter.AppendChild(xDATA_TYPE         );
									xFilter.AppendChild(xOPERATOR          );
									xFilter.AppendChild(xSEARCH_TEXT       );
									xID                .InnerText = (dictFilter.ContainsKey("ID"                ) ? Sql.ToString(dictFilter["ID"                ]) : String.Empty);
									xMODULE_NAME       .InnerText = (dictFilter.ContainsKey("MODULE_NAME"       ) ? Sql.ToString(dictFilter["MODULE_NAME"       ]) : String.Empty);
									xDATA_FIELD        .InnerText = (dictFilter.ContainsKey("DATA_FIELD"        ) ? Sql.ToString(dictFilter["DATA_FIELD"        ]) : String.Empty);
									xDATA_TYPE         .InnerText = (dictFilter.ContainsKey("DATA_TYPE"         ) ? Sql.ToString(dictFilter["DATA_TYPE"         ]) : String.Empty);
									xOPERATOR          .InnerText = (dictFilter.ContainsKey("OPERATOR"          ) ? Sql.ToString(dictFilter["OPERATOR"          ]) : String.Empty);
									xSEARCH_TEXT       .InnerText = (dictFilter.ContainsKey("SEARCH_TEXT"       ) ? Sql.ToString(dictFilter["SEARCH_TEXT"       ]) : String.Empty);
									if ( dictFilter.ContainsKey("SEARCH_TEXT_VALUES") )
									{
										if ( dictFilter["SEARCH_TEXT_VALUES"] is System.Collections.ArrayList )
										{
											System.Collections.ArrayList dictValues = dictFilter["SEARCH_TEXT_VALUES"] as System.Collections.ArrayList;
											// 02/09/2022 Paul.  Numbers in json are not strings. 
											foreach ( object value in dictValues )
											{
												XmlNode xSEARCH_TEXT_VALUES = xml.CreateElement("SEARCH_TEXT_VALUES");
												xFilter.AppendChild(xSEARCH_TEXT_VALUES);
												xSEARCH_TEXT_VALUES.InnerText = Sql.ToString(value);
											}
										}
										else
										{
											XmlNode xSEARCH_TEXT_VALUES = xml.CreateElement("SEARCH_TEXT_VALUES");
											xFilter.AppendChild(xSEARCH_TEXT_VALUES);
											xSEARCH_TEXT_VALUES.InnerText = Sql.ToString(dictFilter["SEARCH_TEXT_VALUES"]);
										}
									}
								}
							}
						}
					}
				}
				this.SetCustomProperty("Filters", xml.OuterXml);
			}
		}

		public void SetWorkflowFiltersCustomProperty(Dictionary<string, object> dictFilterXml)
		{
			this.SetCustomProperty("Filters"       , String.Empty);
			if ( dictFilterXml != null )
			{
				XmlDocument xml = new XmlDocument();
				xml.AppendChild(xml.CreateElement("Filters"));
				XmlNode xFilters = xml.DocumentElement;
				if ( dictFilterXml.ContainsKey("Filters") )
				{
					Dictionary<string, object> dictFilters = dictFilterXml["Filters"] as Dictionary<string, object>;
					if ( dictFilters != null )
					{
						if ( dictFilters.ContainsKey("Filter") )
						{
							System.Collections.ArrayList lstFilter = dictFilters["Filter"] as System.Collections.ArrayList;
							if ( lstFilter != null )
							{
								foreach ( Dictionary<string, object> dictFilter in lstFilter )
								{
									XmlNode xFilter = xml.CreateElement("Filter");
									xFilters.AppendChild(xFilter);
									XmlNode xID                 = xml.CreateElement("ID"               );
									XmlNode xACTION_TYPE        = xml.CreateElement("ACTION_TYPE"      );
									XmlNode xRELATIONSHIP_NAME  = xml.CreateElement("RELATIONSHIP_NAME");
									XmlNode xMODULE             = xml.CreateElement("MODULE"           );
									XmlNode xMODULE_NAME        = xml.CreateElement("MODULE_NAME"      );
									XmlNode xTABLE_NAME         = xml.CreateElement("TABLE_NAME"       );
									XmlNode xDATA_FIELD         = xml.CreateElement("DATA_FIELD"       );
									XmlNode xFIELD_NAME         = xml.CreateElement("FIELD_NAME"       );
									XmlNode xDATA_TYPE          = xml.CreateElement("DATA_TYPE"        );
									XmlNode xOPERATOR           = xml.CreateElement("OPERATOR"         );
									XmlNode xSEARCH_TEXT        = xml.CreateElement("SEARCH_TEXT"      );
									xFilter.AppendChild(xID               );
									xFilter.AppendChild(xACTION_TYPE      );
									xFilter.AppendChild(xRELATIONSHIP_NAME);
									xFilter.AppendChild(xMODULE           );
									xFilter.AppendChild(xMODULE_NAME      );
									xFilter.AppendChild(xTABLE_NAME       );
									xFilter.AppendChild(xDATA_FIELD       );
									xFilter.AppendChild(xFIELD_NAME       );
									xFilter.AppendChild(xDATA_TYPE        );
									xFilter.AppendChild(xOPERATOR         );
									xFilter.AppendChild(xSEARCH_TEXT      );
									xID                .InnerText = (dictFilter.ContainsKey("ID"               ) ? Sql.ToString(dictFilter["ID"               ]) : String.Empty);
									xACTION_TYPE       .InnerText = (dictFilter.ContainsKey("ACTION_TYPE"      ) ? Sql.ToString(dictFilter["ACTION_TYPE"      ]) : String.Empty);
									xRELATIONSHIP_NAME .InnerText = (dictFilter.ContainsKey("RELATIONSHIP_NAME") ? Sql.ToString(dictFilter["RELATIONSHIP_NAME"]) : String.Empty);
									xMODULE            .InnerText = (dictFilter.ContainsKey("MODULE"           ) ? Sql.ToString(dictFilter["MODULE"           ]) : String.Empty);
									xMODULE_NAME       .InnerText = (dictFilter.ContainsKey("MODULE_NAME"      ) ? Sql.ToString(dictFilter["MODULE_NAME"      ]) : String.Empty);
									xTABLE_NAME        .InnerText = (dictFilter.ContainsKey("TABLE_NAME"       ) ? Sql.ToString(dictFilter["TABLE_NAME"       ]) : String.Empty);
									xDATA_FIELD        .InnerText = (dictFilter.ContainsKey("DATA_FIELD"       ) ? Sql.ToString(dictFilter["DATA_FIELD"       ]) : String.Empty);
									xFIELD_NAME        .InnerText = (dictFilter.ContainsKey("FIELD_NAME"       ) ? Sql.ToString(dictFilter["FIELD_NAME"       ]) : String.Empty);
									xDATA_TYPE         .InnerText = (dictFilter.ContainsKey("DATA_TYPE"        ) ? Sql.ToString(dictFilter["DATA_TYPE"        ]) : String.Empty);
									xOPERATOR          .InnerText = (dictFilter.ContainsKey("OPERATOR"         ) ? Sql.ToString(dictFilter["OPERATOR"         ]) : String.Empty);
									xSEARCH_TEXT       .InnerText = (dictFilter.ContainsKey("SEARCH_TEXT"      ) ? Sql.ToString(dictFilter["SEARCH_TEXT"      ]) : String.Empty);
									if ( dictFilter.ContainsKey("SEARCH_TEXT_VALUES") )
									{
										if ( dictFilter["SEARCH_TEXT_VALUES"] is System.Collections.ArrayList )
										{
											System.Collections.ArrayList dictValues = dictFilter["SEARCH_TEXT_VALUES"] as System.Collections.ArrayList;
											// 02/09/2022 Paul.  Numbers in json are not strings. 
											foreach ( object value in dictValues )
											{
												XmlNode xSEARCH_TEXT_VALUES = xml.CreateElement("SEARCH_TEXT_VALUES");
												xFilter.AppendChild(xSEARCH_TEXT_VALUES);
												xSEARCH_TEXT_VALUES.InnerText = Sql.ToString(value);
											}
										}
										else
										{
											XmlNode xSEARCH_TEXT_VALUES = xml.CreateElement("SEARCH_TEXT_VALUES");
											xFilter.AppendChild(xSEARCH_TEXT_VALUES);
											xSEARCH_TEXT_VALUES.InnerText = Sql.ToString(dictFilter["SEARCH_TEXT_VALUES"]);
										}
									}
								}
							}
						}
					}
				}
				this.SetCustomProperty("Filters", xml.OuterXml);
			}
		}

		public void SetWorkflowAttachmentCustomProperty(Dictionary<string, object> dictAttachmentXml)
		{
			this.SetCustomProperty("ReportAttachments", String.Empty);
			if ( dictAttachmentXml != null )
			{
				XmlDocument xml = new XmlDocument();
				xml.AppendChild(xml.CreateElement("ReportAttachments"));
				XmlNode xReportAttachments = xml.DocumentElement;
				if ( dictAttachmentXml.ContainsKey("ReportAttachments") )
				{
					Dictionary<string, object> dictReportAttachments = dictAttachmentXml["ReportAttachments"] as Dictionary<string, object>;
					if ( dictReportAttachments != null )
					{
						if ( dictReportAttachments.ContainsKey("Report") )
						{
							System.Collections.ArrayList lstReport = dictReportAttachments["Report"] as System.Collections.ArrayList;
							if ( lstReport != null )
							{
								foreach ( Dictionary<string, object> dictFilter in lstReport )
								{
									XmlNode xReport = xml.CreateElement("Report");
									xReportAttachments.AppendChild(xReport);
									XmlNode xID                = xml.CreateElement("ID"               );
									XmlNode xREPORT_ID         = xml.CreateElement("REPORT_ID"        );
									XmlNode xREPORT_NAME       = xml.CreateElement("REPORT_NAME"      );
									XmlNode xREPORT_PARAMETERS = xml.CreateElement("REPORT_PARAMETERS");
									XmlNode xRENDER_FORMAT     = xml.CreateElement("RENDER_FORMAT"    );
									xReport.AppendChild(xID               );
									xReport.AppendChild(xREPORT_ID        );
									xReport.AppendChild(xREPORT_NAME      );
									xReport.AppendChild(xREPORT_PARAMETERS);
									xReport.AppendChild(xRENDER_FORMAT    );
									xID               .InnerText = (dictFilter.ContainsKey("ID"               ) ? Sql.ToString(dictFilter["ID"               ]) : String.Empty);
									xREPORT_ID        .InnerText = (dictFilter.ContainsKey("REPORT_ID"        ) ? Sql.ToString(dictFilter["REPORT_ID"        ]) : String.Empty);
									xREPORT_NAME      .InnerText = (dictFilter.ContainsKey("REPORT_NAME"      ) ? Sql.ToString(dictFilter["REPORT_NAME"      ]) : String.Empty);
									xREPORT_PARAMETERS.InnerText = (dictFilter.ContainsKey("REPORT_PARAMETERS") ? Sql.ToString(dictFilter["REPORT_PARAMETERS"]) : String.Empty);
									xRENDER_FORMAT    .InnerText = (dictFilter.ContainsKey("RENDER_FORMAT"    ) ? Sql.ToString(dictFilter["RENDER_FORMAT"    ]) : String.Empty);
								}
							}
						}
					}
				}
				this.SetCustomProperty("ReportAttachments", xml.OuterXml);
			}
		}

		public void SetRelatedModuleCustomProperty(Dictionary<string, object> dictRelatedModuleXml)
		{
			this.SetCustomProperty("RelatedModules", String.Empty);
			if ( dictRelatedModuleXml != null )
			{
				XmlDocument xml = new XmlDocument();
				xml.AppendChild(xml.CreateElement("Relationships"));
				XmlNode xRelationships = xml.DocumentElement;
				if ( dictRelatedModuleXml.ContainsKey("Relationships") )
				{
					Dictionary<string, object> dictRelationships = dictRelatedModuleXml["Relationships"] as Dictionary<string, object>;
					if ( dictRelationships != null )
					{
						if ( dictRelationships.ContainsKey("Relationship") )
						{
							System.Collections.ArrayList lstRelationship = dictRelationships["Relationship"] as System.Collections.ArrayList;
							if ( lstRelationship != null )
							{
								foreach ( Dictionary<string, object> dictRelationship in lstRelationship )
								{
									XmlNode xRelationship = xml.CreateElement("Relationship");
									xRelationships.AppendChild(xRelationship);
									XmlNode xRELATIONSHIP_NAME              = xml.CreateElement("RELATIONSHIP_NAME"             );
									XmlNode xLHS_MODULE                     = xml.CreateElement("LHS_MODULE"                    );
									XmlNode xLHS_TABLE                      = xml.CreateElement("LHS_TABLE"                     );
									XmlNode xLHS_KEY                        = xml.CreateElement("LHS_KEY"                       );
									XmlNode xRHS_MODULE                     = xml.CreateElement("RHS_MODULE"                    );
									XmlNode xRHS_TABLE                      = xml.CreateElement("RHS_TABLE"                     );
									XmlNode xRHS_KEY                        = xml.CreateElement("RHS_KEY"                       );
									XmlNode xJOIN_TABLE                     = xml.CreateElement("JOIN_TABLE"                    );
									XmlNode xJOIN_KEY_LHS                   = xml.CreateElement("JOIN_KEY_LHS"                  );
									XmlNode xJOIN_KEY_RHS                   = xml.CreateElement("JOIN_KEY_RHS"                  );
									XmlNode xRELATIONSHIP_TYPE              = xml.CreateElement("RELATIONSHIP_TYPE"             );
									XmlNode xMODULE_NAME                    = xml.CreateElement("MODULE_NAME"                   );
									XmlNode xDISPLAY_NAME                   = xml.CreateElement("DISPLAY_NAME"                  );
									XmlNode xRELATIONSHIP_ROLE_COLUMN       = xml.CreateElement("RELATIONSHIP_ROLE_COLUMN"      );
									XmlNode xRELATIONSHIP_ROLE_COLUMN_VALUE = xml.CreateElement("RELATIONSHIP_ROLE_COLUMN_VALUE");
									xRelationship.AppendChild(xRELATIONSHIP_NAME             );
									xRelationship.AppendChild(xLHS_MODULE                    );
									xRelationship.AppendChild(xLHS_TABLE                     );
									xRelationship.AppendChild(xLHS_KEY                       );
									xRelationship.AppendChild(xRHS_MODULE                    );
									xRelationship.AppendChild(xRHS_TABLE                     );
									xRelationship.AppendChild(xRHS_KEY                       );
									xRelationship.AppendChild(xJOIN_TABLE                    );
									xRelationship.AppendChild(xJOIN_KEY_LHS                  );
									xRelationship.AppendChild(xJOIN_KEY_RHS                  );
									xRelationship.AppendChild(xRELATIONSHIP_TYPE             );
									xRelationship.AppendChild(xMODULE_NAME                   );
									xRelationship.AppendChild(xDISPLAY_NAME                  );
									xRelationship.AppendChild(xRELATIONSHIP_ROLE_COLUMN      );
									xRelationship.AppendChild(xRELATIONSHIP_ROLE_COLUMN_VALUE);
									xRELATIONSHIP_NAME             .InnerText = (dictRelationship.ContainsKey("RELATIONSHIP_NAME"             ) ? Sql.ToString(dictRelationship["RELATIONSHIP_NAME"             ]) : String.Empty);
									xLHS_MODULE                    .InnerText = (dictRelationship.ContainsKey("LHS_MODULE"                    ) ? Sql.ToString(dictRelationship["LHS_MODULE"                    ]) : String.Empty);
									xLHS_TABLE                     .InnerText = (dictRelationship.ContainsKey("LHS_TABLE"                     ) ? Sql.ToString(dictRelationship["LHS_TABLE"                     ]) : String.Empty);
									xLHS_KEY                       .InnerText = (dictRelationship.ContainsKey("LHS_KEY"                       ) ? Sql.ToString(dictRelationship["LHS_KEY"                       ]) : String.Empty);
									xRHS_MODULE                    .InnerText = (dictRelationship.ContainsKey("RHS_MODULE"                    ) ? Sql.ToString(dictRelationship["RHS_MODULE"                    ]) : String.Empty);
									xRHS_TABLE                     .InnerText = (dictRelationship.ContainsKey("RHS_TABLE"                     ) ? Sql.ToString(dictRelationship["RHS_TABLE"                     ]) : String.Empty);
									xRHS_KEY                       .InnerText = (dictRelationship.ContainsKey("RHS_KEY"                       ) ? Sql.ToString(dictRelationship["RHS_KEY"                       ]) : String.Empty);
									xJOIN_TABLE                    .InnerText = (dictRelationship.ContainsKey("JOIN_TABLE"                    ) ? Sql.ToString(dictRelationship["JOIN_TABLE"                    ]) : String.Empty);
									xJOIN_KEY_LHS                  .InnerText = (dictRelationship.ContainsKey("JOIN_KEY_LHS"                  ) ? Sql.ToString(dictRelationship["JOIN_KEY_LHS"                  ]) : String.Empty);
									xJOIN_KEY_RHS                  .InnerText = (dictRelationship.ContainsKey("JOIN_KEY_RHS"                  ) ? Sql.ToString(dictRelationship["JOIN_KEY_RHS"                  ]) : String.Empty);
									xRELATIONSHIP_TYPE             .InnerText = (dictRelationship.ContainsKey("RELATIONSHIP_TYPE"             ) ? Sql.ToString(dictRelationship["RELATIONSHIP_TYPE"             ]) : String.Empty);
									xMODULE_NAME                   .InnerText = (dictRelationship.ContainsKey("MODULE_NAME"                   ) ? Sql.ToString(dictRelationship["MODULE_NAME"                   ]) : String.Empty);
									xDISPLAY_NAME                  .InnerText = (dictRelationship.ContainsKey("DISPLAY_NAME"                  ) ? Sql.ToString(dictRelationship["DISPLAY_NAME"                  ]) : String.Empty);
									xRELATIONSHIP_ROLE_COLUMN      .InnerText = (dictRelationship.ContainsKey("RELATIONSHIP_ROLE_COLUMN"      ) ? Sql.ToString(dictRelationship["RELATIONSHIP_ROLE_COLUMN"      ]) : String.Empty);
									xRELATIONSHIP_ROLE_COLUMN_VALUE.InnerText = (dictRelationship.ContainsKey("RELATIONSHIP_ROLE_COLUMN_VALUE") ? Sql.ToString(dictRelationship["RELATIONSHIP_ROLE_COLUMN_VALUE"]) : String.Empty);
								}
							}
						}
					}
				}
				this.SetCustomProperty("RelatedModules", xml.OuterXml);
			}
		}

		public void SetRelationshipCustomProperty(Dictionary<string, object> dictRelationshipXml)
		{
			this.SetCustomProperty("Relationships" , String.Empty);
			if ( dictRelationshipXml != null )
			{
				XmlDocument xml = new XmlDocument();
				xml.AppendChild(xml.CreateElement("Relationships"));
				XmlNode xRelationships = xml.DocumentElement;
				if ( dictRelationshipXml.ContainsKey("Relationships") )
				{
					Dictionary<string, object> dictRelationships = dictRelationshipXml["Relationships"] as Dictionary<string, object>;
					if ( dictRelationships != null )
					{
						if ( dictRelationships.ContainsKey("Relationship") )
						{
							System.Collections.ArrayList lstRelationship = dictRelationships["Relationship"] as System.Collections.ArrayList;
							if ( lstRelationship != null )
							{
								foreach ( Dictionary<string, object> dictRelationship in lstRelationship )
								{
									XmlNode xRelationship = xml.CreateElement("Relationship");
									xRelationships.AppendChild(xRelationship);
									XmlNode xRELATIONSHIP_NAME              = xml.CreateElement("RELATIONSHIP_NAME"             );
									XmlNode xLHS_MODULE                     = xml.CreateElement("LHS_MODULE"                    );
									XmlNode xLHS_TABLE                      = xml.CreateElement("LHS_TABLE"                     );
									XmlNode xLHS_KEY                        = xml.CreateElement("LHS_KEY"                       );
									XmlNode xRHS_MODULE                     = xml.CreateElement("RHS_MODULE"                    );
									XmlNode xRHS_TABLE                      = xml.CreateElement("RHS_TABLE"                     );
									XmlNode xRHS_KEY                        = xml.CreateElement("RHS_KEY"                       );
									XmlNode xJOIN_TABLE                     = xml.CreateElement("JOIN_TABLE"                    );
									XmlNode xJOIN_KEY_LHS                   = xml.CreateElement("JOIN_KEY_LHS"                  );
									XmlNode xJOIN_KEY_RHS                   = xml.CreateElement("JOIN_KEY_RHS"                  );
									XmlNode xRELATIONSHIP_TYPE              = xml.CreateElement("RELATIONSHIP_TYPE"             );
									XmlNode xMODULE_NAME                    = xml.CreateElement("MODULE_NAME"                   );
									XmlNode xDISPLAY_NAME                   = xml.CreateElement("DISPLAY_NAME"                  );
									XmlNode xRELATIONSHIP_ROLE_COLUMN       = xml.CreateElement("RELATIONSHIP_ROLE_COLUMN"      );
									XmlNode xRELATIONSHIP_ROLE_COLUMN_VALUE = xml.CreateElement("RELATIONSHIP_ROLE_COLUMN_VALUE");
									xRelationship.AppendChild(xRELATIONSHIP_NAME             );
									xRelationship.AppendChild(xLHS_MODULE                    );
									xRelationship.AppendChild(xLHS_TABLE                     );
									xRelationship.AppendChild(xLHS_KEY                       );
									xRelationship.AppendChild(xRHS_MODULE                    );
									xRelationship.AppendChild(xRHS_TABLE                     );
									xRelationship.AppendChild(xRHS_KEY                       );
									xRelationship.AppendChild(xJOIN_TABLE                    );
									xRelationship.AppendChild(xJOIN_KEY_LHS                  );
									xRelationship.AppendChild(xJOIN_KEY_RHS                  );
									xRelationship.AppendChild(xRELATIONSHIP_TYPE             );
									xRelationship.AppendChild(xMODULE_NAME                   );
									xRelationship.AppendChild(xDISPLAY_NAME                  );
									xRelationship.AppendChild(xRELATIONSHIP_ROLE_COLUMN      );
									xRelationship.AppendChild(xRELATIONSHIP_ROLE_COLUMN_VALUE);
									xRELATIONSHIP_NAME             .InnerText = (dictRelationship.ContainsKey("RELATIONSHIP_NAME"             ) ? Sql.ToString(dictRelationship["RELATIONSHIP_NAME"             ]) : String.Empty);
									xLHS_MODULE                    .InnerText = (dictRelationship.ContainsKey("LHS_MODULE"                    ) ? Sql.ToString(dictRelationship["LHS_MODULE"                    ]) : String.Empty);
									xLHS_TABLE                     .InnerText = (dictRelationship.ContainsKey("LHS_TABLE"                     ) ? Sql.ToString(dictRelationship["LHS_TABLE"                     ]) : String.Empty);
									xLHS_KEY                       .InnerText = (dictRelationship.ContainsKey("LHS_KEY"                       ) ? Sql.ToString(dictRelationship["LHS_KEY"                       ]) : String.Empty);
									xRHS_MODULE                    .InnerText = (dictRelationship.ContainsKey("RHS_MODULE"                    ) ? Sql.ToString(dictRelationship["RHS_MODULE"                    ]) : String.Empty);
									xRHS_TABLE                     .InnerText = (dictRelationship.ContainsKey("RHS_TABLE"                     ) ? Sql.ToString(dictRelationship["RHS_TABLE"                     ]) : String.Empty);
									xRHS_KEY                       .InnerText = (dictRelationship.ContainsKey("RHS_KEY"                       ) ? Sql.ToString(dictRelationship["RHS_KEY"                       ]) : String.Empty);
									xJOIN_TABLE                    .InnerText = (dictRelationship.ContainsKey("JOIN_TABLE"                    ) ? Sql.ToString(dictRelationship["JOIN_TABLE"                    ]) : String.Empty);
									xJOIN_KEY_LHS                  .InnerText = (dictRelationship.ContainsKey("JOIN_KEY_LHS"                  ) ? Sql.ToString(dictRelationship["JOIN_KEY_LHS"                  ]) : String.Empty);
									xJOIN_KEY_RHS                  .InnerText = (dictRelationship.ContainsKey("JOIN_KEY_RHS"                  ) ? Sql.ToString(dictRelationship["JOIN_KEY_RHS"                  ]) : String.Empty);
									xRELATIONSHIP_TYPE             .InnerText = (dictRelationship.ContainsKey("RELATIONSHIP_TYPE"             ) ? Sql.ToString(dictRelationship["RELATIONSHIP_TYPE"             ]) : String.Empty);
									xMODULE_NAME                   .InnerText = (dictRelationship.ContainsKey("MODULE_NAME"                   ) ? Sql.ToString(dictRelationship["MODULE_NAME"                   ]) : String.Empty);
									xDISPLAY_NAME                  .InnerText = (dictRelationship.ContainsKey("DISPLAY_NAME"                  ) ? Sql.ToString(dictRelationship["DISPLAY_NAME"                  ]) : String.Empty);
									xRELATIONSHIP_ROLE_COLUMN      .InnerText = (dictRelationship.ContainsKey("RELATIONSHIP_ROLE_COLUMN"      ) ? Sql.ToString(dictRelationship["RELATIONSHIP_ROLE_COLUMN"      ]) : String.Empty);
									xRELATIONSHIP_ROLE_COLUMN_VALUE.InnerText = (dictRelationship.ContainsKey("RELATIONSHIP_ROLE_COLUMN_VALUE") ? Sql.ToString(dictRelationship["RELATIONSHIP_ROLE_COLUMN_VALUE"]) : String.Empty);
								}
							}
						}
					}
				}
				this.SetCustomProperty("Relationships", xml.OuterXml);
			}
		}

		public void SetDisplayColumnsCustomProperty(Dictionary<string, object> dictDisplayColumnsXml)
		{
			this.SetCustomProperty("DisplayColumns", String.Empty);
			if ( dictDisplayColumnsXml != null )
			{
				XmlDocument xml = new XmlDocument();
				xml.AppendChild(xml.CreateElement("DisplayColumns"));
				XmlNode xDisplayColumns = xml.DocumentElement;
				if ( dictDisplayColumnsXml.ContainsKey("DisplayColumns") )
				{
					Dictionary<string, object> dictDisplayColumns = dictDisplayColumnsXml["DisplayColumns"] as Dictionary<string, object>;
					if ( dictDisplayColumns != null )
					{
						if ( dictDisplayColumns.ContainsKey("DisplayColumn") )
						{
							System.Collections.ArrayList lstDisplayColumn = dictDisplayColumns["DisplayColumn"] as System.Collections.ArrayList;
							if ( lstDisplayColumn != null )
							{
								foreach ( Dictionary<string, object> dictDisplayColumn in lstDisplayColumn )
								{
									XmlNode xDisplayColumn = xml.CreateElement("DisplayColumn");
									xDisplayColumns.AppendChild(xDisplayColumn);
									XmlNode xLabel = xml.CreateElement("Label");
									XmlNode xField = xml.CreateElement("Field");
									xDisplayColumn.AppendChild(xLabel);
									xDisplayColumn.AppendChild(xField);
									xLabel.InnerText = (dictDisplayColumn.ContainsKey("Label") ? Sql.ToString(dictDisplayColumn["Label"]) : String.Empty);
									xField.InnerText = (dictDisplayColumn.ContainsKey("Field") ? Sql.ToString(dictDisplayColumn["Field"]) : String.Empty);
								}
							}
						}
					}
				}
				this.SetCustomProperty("DisplayColumns", xml.OuterXml);
			}
		}

		public void SetDataSetFields(Hashtable hashAvailableModules)
		{
			// 06/15/2006 Paul.  Completely rebuild the Fields list based on the available modules. 
			this.SetSingleNode("DataSets/DataSet/Fields", String.Empty);
			XmlNode xFields = this.SelectNode("DataSets/DataSet/Fields");
			xFields.RemoveAll();
			// 07/13/2006 Paul.  The key is the alias and the value is the module. 
			// This is so that the same module can be referenced many times with many aliases. 
			foreach ( string sTableAlias in hashAvailableModules.Keys )
			{
				// 01/18/2012 Paul.  Add the ID so that the user can add Drillthrough actions. 
				this.CreateField(xFields, sTableAlias + ".ID", "System.Guid");
				// 07/22/2008 Paul.  Not really a bug fix, but just a better field name.  The hash table contains table names and not module names. 
				string sTABLE_NAME = Sql.ToString(hashAvailableModules[sTableAlias]);
				DataTable dtColumns = SplendidCache.ReportingFilterColumns(sTABLE_NAME).Copy();
				foreach(DataRow row in dtColumns.Rows)
				{
					string sFieldName = sTableAlias + "." + Sql.ToString(row["NAME"]);
					string sCsType = Sql.ToString(row["CsType"]);
					string sFieldType = String.Empty;
					switch ( sCsType )
					{
						case "Guid"      :  sFieldType = "System.Guid"    ;  break;
						case "string"    :  sFieldType = "System.String"  ;  break;
						case "ansistring":  sFieldType = "System.String"  ;  break;
						case "DateTime"  :  sFieldType = "System.DateTime";  break;
						case "bool"      :  sFieldType = "System.Boolean" ;  break;
						case "float"     :  sFieldType = "System.Double"  ;  break;
						case "decimal"   :  sFieldType = "System.Decimal" ;  break;
						case "short"     :  sFieldType = "System.Int16"   ;  break;
						case "Int32"     :  sFieldType = "System.Int32"   ;  break;
						case "Int64"     :  sFieldType = "System.Int64"   ;  break;
						default          :  sFieldType = "System.String"  ;  break;
					}
					this.CreateField(xFields, sFieldName, sFieldType);
				}
			}
		}
	}

	public class RdsDocument : XmlDocument
	{
		public string sDefaultNamespace         = "http://schemas.microsoft.com/sqlserver/reporting/2010/01/shareddatasetdefinition";
		public string sDesignerNamespace        = "http://schemas.microsoft.com/SQLServer/reporting/reportdesigner";
		public string sQueryDefinitionNamespace = "http://schemas.microsoft.com/ReportingServices/QueryDefinition/Relational";

		private XmlNamespaceManager nsmgr;
		private StringBuilder sbValidationErrors;

		public XmlNamespaceManager NamespaceManager
		{
			get { return nsmgr; }
		}

		private void ValidationHandler(object sender, ValidationEventArgs args)
		{
			sbValidationErrors.AppendLine(args.Message);
			XmlSchemaValidationException vx = args.Exception as XmlSchemaValidationException;
			// 02/07/2010 Paul.  Defensive programming, also check for valid SourceObject. 
			if ( vx != null && vx.SourceObject != null )
			{
				if ( vx.SourceObject is XmlElement )
				{
					XmlElement xSourceObject = vx.SourceObject as XmlElement;
					sbValidationErrors.AppendLine("Source object for the exception is " + xSourceObject.Name + ". ");
					sbValidationErrors.AppendLine(xSourceObject.OuterXml);
				}
				else if ( vx.SourceObject is XmlAttribute )
				{
					XmlAttribute xSourceObject = vx.SourceObject as XmlAttribute;
					sbValidationErrors.AppendLine("Source object for the exception is " + xSourceObject.Name + ". ");
					sbValidationErrors.AppendLine(xSourceObject.OuterXml);
					if ( xSourceObject.ParentNode != null )
						sbValidationErrors.AppendLine(xSourceObject.ParentNode.OuterXml);
				}
			}
		}

		public void Validate(HttpContext Context)
		{
			// 08/25/2013 Paul.  File IO is slow, so cache existance test. 
			if ( Utils.CachedFileExists(Context, "~/Reports/RDS 2008 Shared DataSet Definition.xsd") )
			{
				string sRDLSchemaXSD = Context.Server.MapPath("~/Reports/RDS 2008 Shared DataSet Definition.xsd");
				XmlTextReader rdrRDLSchema = new XmlTextReader(sRDLSchemaXSD);
				XmlSchema schRDL = XmlSchema.Read(rdrRDLSchema, new ValidationEventHandler(ValidationHandler));
				this.Schemas.Add(schRDL);
				this.Validate(new ValidationEventHandler(ValidationHandler));
			}
			if ( sbValidationErrors.Length > 0 )
			{
				throw(new Exception("RDS Schema validation failed: " + sbValidationErrors.ToString()));
			}
		}

		public void LoadRds(string rds)
		{
			base.LoadXml(rds);

			nsmgr = new XmlNamespaceManager(this.NameTable);
			nsmgr.AddNamespace("defaultns", sDefaultNamespace );
			nsmgr.AddNamespace("rd", sDesignerNamespace);
		}

		public XmlNode SelectNode(string sNode)
		{
			return XmlUtil.SelectNode(this, sNode, nsmgr);
		}

		public string SelectNodeValue(string sNode)
		{
			string sValue = String.Empty;
			XmlNode xValue = XmlUtil.SelectNode(this, sNode, nsmgr);
			if ( xValue != null )
				sValue = xValue.InnerText;
			return sValue;
		}

		public string SelectNodeAttribute(string sNode, string sAttribute)
		{
			string sValue = String.Empty;
			XmlNode xNode = null;
			if ( sNode == String.Empty )
				xNode = this.DocumentElement;
			else
				xNode = XmlUtil.SelectNode(this, sNode, nsmgr);
			if ( xNode != null )
			{
				if ( xNode.Attributes != null )
				{
					XmlNode xValue = xNode.Attributes.GetNamedItem(sAttribute);
					if ( xValue != null )
						sValue = xValue.Value;
				}
			}
			return sValue;
		}

		public string SelectNodeValue(XmlNode parent, string sNode)
		{
			return XmlUtil.SelectSingleNode(parent, sNode, nsmgr);
		}

		public XmlNodeList SelectNodesNS(string sXPath)
		{
			string[] arrXPath = sXPath.Split('/');
			for ( int i = 0; i < arrXPath.Length; i++ )
			{
				// 06/20/2006 Paul.  The default namespace cannot be selected, so create an alias and reference the alias. 
				if ( arrXPath[i].IndexOf(':') < 0 )
					arrXPath[i] = "defaultns:" + arrXPath[i];
			}
			sXPath = String.Join("/", arrXPath);
			return this.DocumentElement.SelectNodes(sXPath, nsmgr);
		}

		public XmlNodeList SelectNodesNS(XmlNode parent, string sXPath)
		{
			string[] arrXPath = sXPath.Split('/');
			for ( int i = 0; i < arrXPath.Length; i++ )
			{
				// 06/20/2006 Paul.  The default namespace cannot be selected, so create an alias and reference the alias. 
				if ( arrXPath[i].IndexOf(':') < 0 )
					arrXPath[i] = "defaultns:" + arrXPath[i];
			}
			sXPath = String.Join("/", arrXPath);
			return parent.SelectNodes(sXPath, nsmgr);
		}

		public void SetSingleNode(string sNode, string sValue)
		{
			XmlUtil.SetSingleNode(this, sNode, sValue, nsmgr, sDefaultNamespace);
		}

		public void SetSingleNode(XmlNode parent, string sNode, string sValue)
		{
			XmlUtil.SetSingleNode(this, parent, sNode, sValue, nsmgr, sDefaultNamespace);
		}

		public void SetSingleNodeAttribute(string sNode, string sAttribute, string sValue)
		{
			XmlUtil.SetSingleNodeAttribute(this, sNode, sAttribute, sValue, nsmgr, sDefaultNamespace);
		}

		public void SetSingleNodeAttribute(XmlNode parent, string sAttribute, string sValue)
		{
			XmlUtil.SetSingleNodeAttribute(this, parent, sAttribute, sValue, nsmgr, sDefaultNamespace);
		}

		public static string RdlName(string sName)
		{
			sName = Regex.Replace(sName, @"[\[\]]" , "");
			sName = Regex.Replace(sName, @"[\.\: ]", "__");
			return sName;
		}

		public RdsDocument(string sNAME) : base()
		{
			sbValidationErrors = new StringBuilder();
			this.AppendChild(this.CreateXmlDeclaration("1.0", "UTF-8", null));

			this.AppendChild(this.CreateElement("SharedDataSet", sDefaultNamespace));
			// 09/25/2010 Paul.  Add the RD namespace manually. 
			XmlUtil.SetSingleNodeAttribute(this, this.DocumentElement, "xmlns:rd", sDesignerNamespace);

			nsmgr = new XmlNamespaceManager(this.NameTable);
			nsmgr.AddNamespace(""  , sDefaultNamespace );
			nsmgr.AddNamespace("rd", sDesignerNamespace);
			// 06/20/2006 Paul.  The default namespace cannot be selected, so create an alias and reference the alias. 
			nsmgr.AddNamespace("defaultns", sDefaultNamespace );
			nsmgr.AddNamespace("qd", sQueryDefinitionNamespace);

			SetSingleNode         ("DataSet", String.Empty);
			SetSingleNodeAttribute("DataSet", "Name", sNAME);
			
			SetSingleNode         ("DataSet/Query", String.Empty);
			SetSingleNode         ("DataSet/Query/DataSourceReference", "");
			SetSingleNode         ("DataSet/Query/CommandText"        , "");
			SetSingleNode         ("DataSet/Fields", String.Empty);
			
			XmlNode xQuery          = this.SelectNode("DataSet/Query");
			XmlNode xDesignerState  = this.CreateElement("rd:DesignerState", sDesignerNamespace);
			xQuery.AppendChild(xDesignerState);
			XmlNode xQueryDefinition = this.CreateElement("QueryDefinition", sQueryDefinitionNamespace);
			xDesignerState.AppendChild(xQueryDefinition);
			XmlNode xSelectedColumns = this.CreateElement("SelectedColumns", sQueryDefinitionNamespace);
			xQueryDefinition.AppendChild(xSelectedColumns);
		}

		/*
		public XmlNode GetSelectedColumns()
		{
			XmlNode xDesignerState   = this.SelectNode("DataSet/Query/rd:DesignerState");
			XmlNode xSelectedColumns = XmlUtil.SelectNode(xDesignerState, "qd:QueryDefinition/qd:SelectedColumns", nsmgr);
			return xSelectedColumns;
		}
		*/

		public void AppendField(XmlNode parent, string sFieldName, string sFieldType)
		{
			XmlNode xField     = this.CreateElement("Field"      , sDefaultNamespace );
			XmlNode xDataField = this.CreateElement("DataField"  , sDefaultNamespace );
			XmlNode xTypeName  = this.CreateElement("rd:TypeName", sDesignerNamespace);
			parent.AppendChild(xField    );
			xField.AppendChild(xDataField);
			xField.AppendChild(xTypeName );
			xDataField.InnerText = sFieldName;
			xTypeName.InnerText  = sFieldType;
			
			XmlAttribute attr = this.CreateAttribute("Name");
			attr.Value = RdlName(sFieldName);
			xField.Attributes.SetNamedItem(attr);
		}

		public void AppendColumnExpression(XmlNode parent, string sColumnOwner, string sColumnName)
		{
			XmlNode xColumnExpression = this.CreateElement("ColumnExpression", sQueryDefinitionNamespace);
			parent.AppendChild(xColumnExpression);
			this.SetSingleNodeAttribute(xColumnExpression, "ColumnOwner", sColumnOwner);
			this.SetSingleNodeAttribute(xColumnExpression, "ColumnName" , sColumnName );
		}
	}

	/// <summary>
	/// Summary description for RdlUtil.
	/// </summary>
	public partial class RdlUtil
	{
		/*
		public static string GetFieldsAsString(XmlDocument xml)
		{
			StringBuilder sb = new StringBuilder();
			if ( xml.DocumentElement != null )
			{
				XmlNodeList nlDataFields = xml.DocumentElement.SelectNodes("DataSets/DataSet/Fields/Field/DataField");
				foreach ( XmlNode xDataField in nlDataFields )
				{
					if ( sb.Length > 0 )
						sb.Append(", ");
					sb.Append("'");
					sb.Append(xDataField.InnerText);
					sb.Append("'");
				}
			}
			return sb.ToString();
		}
		*/

		// 07/15/2010 Paul.  Use new function to format Rdl. 
		public static string RdlEncode(RdlDocument rdl)
		{
			StringBuilder sb = new StringBuilder();
			XmlUtil.Dump(ref sb, "", rdl.DocumentElement);
			string sDump = HttpUtility.HtmlEncode(sb.ToString());
			sDump = sDump.Replace("\n", "<br />\n");
			sDump = sDump.Replace("\t", "&nbsp;&nbsp;&nbsp;");
			sDump = "<div style=\"width: 100%; border: 1px solid black; font-family: courier new;\">" + sDump + "</div>";
			return sDump;
		}

		public static string ReportColumnName(string sColumnName)
		{
			Regex r = new Regex(@"[^A-Za-z0-9_\.]");
			sColumnName = r.Replace(sColumnName, "");
			return sColumnName;
		}
	}
}
