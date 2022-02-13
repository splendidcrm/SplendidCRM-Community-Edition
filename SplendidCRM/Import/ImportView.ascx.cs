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
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Drawing;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;
using System.Xml;
using System.Text;
using System.Workflow.Activities.Rules;

namespace SplendidCRM.Import
{
	/// <summary>
	///		Summary description for ImportView.
	/// </summary>
	public class ImportView : SplendidControl
	{
		#region Properties
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		protected _controls.ListHeader     ctlListHeader   ;
		protected _controls.Chooser        ctlDuplicateFilterChooser;
		protected PlaceHolder              phDefaultsView  ;
		protected SplendidControl          ctlDefaultsView ;

		protected Guid                   gID                          ;
		protected TextBox                txtNAME                      ;
		protected RequiredFieldValidator reqNAME                      ;

		protected RadioButton            radEXCEL                     ;
		protected RadioButton            radXML_SPREADSHEET           ;
		protected RadioButton            radXML                       ;
		protected RadioButton            radSALESFORCE                ;
		protected RadioButton            radACT_2005                  ;
		protected RadioButton            radDBASE                     ;
		protected RadioButton            radCUSTOM_CSV                ;
		protected RadioButton            radCUSTOM_TAB                ;
		protected RadioButton            radCUSTOM_DELIMITED          ;
		protected TextBox                txtCUSTOM_DELIMITER_VAL      ;
		// 04/08/2012 Paul.  Add LinkedIn to the source. 
		protected RadioButton            radLINKEDIN                  ;
		protected RadioButton            radTWITTER                   ;
		protected RadioButton            radFACEBOOK                  ;
		protected RadioButton            radQUICKBOOKS                ;
		// 06/03/2014 Paul.  QuickBooks Online is going to use a different API than standard QuickBooks. 
		protected RadioButton            radQUICKBOOKS_ONLINE         ;
		// 04/23/2015 Paul.  HubSpot uses OAuth2, similar to Facebook. 
		protected RadioButton            radHUBSPOT                   ;
		protected Button                 btnSignIn                    ;
		protected Button                 btnConnect                   ;
		protected Button                 btnSignOut                   ;
		protected HiddenField            txtOAUTH_TOKEN               ;
		protected HiddenField            txtOAUTH_SECRET              ;
		protected HiddenField            txtOAUTH_VERIFIER            ;
		protected HiddenField            txtOAUTH_ACCESS_TOKEN        ;
		protected HiddenField            txtOAUTH_ACCESS_SECRET       ;
		// 06/03/2014 Paul.  Extract the QuickBooks realmId (same as Company ID). 
		protected HiddenField            txtOAUTH_REALMID             ;
		// 04/23/2015 Paul.  HubSpot has more data. 
		protected HiddenField            txtOAUTH_REFRESH_TOKEN       ;
		protected HiddenField            txtOAUTH_EXPIRES_IN          ;
		protected Button                 btnOAuthChanged              ;

		protected DataView               vwMain                       ;
		protected DataView               vwColumns                    ;
		protected SplendidGrid           grdMain                      ;
		protected DataView               vwMySaved                    ;
		protected SplendidGrid           grdMySaved                   ;

		protected XmlDocument            xml                          ;
		protected XmlDocument            xmlMapping                   ;
		protected string                 sImportModule                ;
		protected HtmlInputFile          fileIMPORT                   ;
		protected RequiredFieldValidator reqFILENAME                  ;
		protected CheckBox               chkHasHeader                 ;
		protected HtmlTable              tblImportMappings            ;
		protected StringBuilder          sbImport                     ;

		protected Label                  lblStatus                    ;
		protected Label                  lblSuccessCount              ;
		protected Label                  lblDuplicateCount            ;
		protected Label                  lblFailedCount               ;
		protected CheckBox               chkUseTransaction            ;

		protected HiddenField            txtACTIVE_TAB                ;
		protected bool                   bDuplicateFields = false;

		// 09/17/2013 Paul.  Add Business Rules to import. 
		protected DataTable       dtRules               ;
		protected DataGrid        dgRules               ;
		protected HiddenField     txtRULE_ID            ;
		protected TextBox         txtRULE_NAME          ;
		protected TextBox         txtPRIORITY           ;
		protected DropDownList    lstREEVALUATION       ;
		protected CheckBox        chkACTIVE             ;
		protected TextBox         txtCONDITION          ;
		protected TextBox         txtTHEN_ACTIONS       ;
		protected TextBox         txtELSE_ACTIONS       ;
		protected RequiredFieldValidator reqRULE_NAME   ;
		protected RequiredFieldValidator reqCONDITION   ;
		protected RequiredFieldValidator reqTHEN_ACTIONS;

		protected DataTable       dtRuleColumns  ;
		protected Repeater        ctlConditionSchemaRepeater;
		protected Repeater        ctlThenSchemaRepeater;
		protected Repeater        ctlElseSchemaRepeater;
		// 08/15/2017 Paul.  Provide a way to export errors. 
		protected HyperLink       lnkExportErrors      ;

		public string Module
		{
			get { return sImportModule; }
			set { sImportModule = value; }
		}
		#endregion

		#region Helper methods
		protected string SourceType()
		{
			string sSourceType = "";
			if      ( radEXCEL            .Checked ) sSourceType = "excel"           ;
			else if ( radXML_SPREADSHEET  .Checked ) sSourceType = "xmlspreadsheet"  ;
			else if ( radXML              .Checked ) sSourceType = "xml"             ;
			else if ( radSALESFORCE       .Checked ) sSourceType = "salesforce"      ;
			else if ( radACT_2005         .Checked ) sSourceType = "act"             ;
			else if ( radDBASE            .Checked ) sSourceType = "dbase"           ;
			else if ( radCUSTOM_CSV       .Checked ) sSourceType = "other"           ;
			else if ( radCUSTOM_TAB       .Checked ) sSourceType = "other_tab"       ;
			else if ( radCUSTOM_DELIMITED .Checked ) sSourceType = "custom_delimited";
			else if ( radLINKEDIN         .Checked ) sSourceType = "LinkedIn"        ;
			else if ( radTWITTER          .Checked ) sSourceType = "Twitter"         ;
			else if ( radFACEBOOK         .Checked ) sSourceType = "Facebook"        ;
			else if ( radQUICKBOOKS       .Checked ) sSourceType = "QuickBooks"      ;
			// 06/03/2014 Paul.  QuickBooks Online is going to use a different API than standard QuickBooks. 
			else if ( radQUICKBOOKS_ONLINE.Checked ) sSourceType = "QuickBooksOnline";
			// 04/23/2015 Paul.  HubSpot uses OAuth2, similar to Facebook. 
			else if ( radHUBSPOT          .Checked ) sSourceType = "HubSpot"         ;
			return sSourceType;
		}

		protected void SourceType(string sSOURCE)
		{
			// 05/21/2020 Paul.  First clear all so that effect will be immediate. 
			radEXCEL            .Checked = false;
			radXML_SPREADSHEET  .Checked = false;
			radXML              .Checked = false;
			radSALESFORCE       .Checked = false;
			radACT_2005         .Checked = false;
			radDBASE            .Checked = false;
			radCUSTOM_CSV       .Checked = false;
			radCUSTOM_TAB       .Checked = false;
			radCUSTOM_DELIMITED .Checked = false;
			radLINKEDIN         .Checked = false;
			radTWITTER          .Checked = false;
			radFACEBOOK         .Checked = false;
			radQUICKBOOKS       .Checked = false;
			radQUICKBOOKS_ONLINE.Checked = false;
			radHUBSPOT          .Checked = false;

			switch ( sSOURCE.ToLower() )
			{
				case "excel"           :  radEXCEL            .Checked = true;  break;
				case "xmlspreadsheet"  :  radXML_SPREADSHEET  .Checked = true;  break;
				case "xml"             :  radXML              .Checked = true;  break;
				case "salesforce"      :  radSALESFORCE       .Checked = true;  break;
				case "act"             :  radACT_2005         .Checked = true;  break;
				case "dbase"           :  radDBASE            .Checked = true;  break;
				case "other"           :  radCUSTOM_CSV       .Checked = true;  break;
				case "other_tab"       :  radCUSTOM_TAB       .Checked = true;  break;
				case "custom_delimited":  radCUSTOM_DELIMITED .Checked = true;  break;
				case "LinkedIn"        :  radLINKEDIN         .Checked = true;  break;
				case "Twitter"         :  radTWITTER          .Checked = true;  break;
				case "Facebook"        :  radFACEBOOK         .Checked = true;  break;
				case "QuickBooks"      :  radQUICKBOOKS       .Checked = true;  break;
				// 06/03/2014 Paul.  QuickBooks Online is going to use a different API than standard QuickBooks. 
				case "QuickBooksOnline":  radQUICKBOOKS_ONLINE.Checked = true;  break;
				// 04/23/2015 Paul.  HubSpot uses OAuth2, similar to Facebook. 
				case "HubSpot"         :  radHUBSPOT          .Checked = true;  break;
			}
		}

		protected void DuplicateFilterUpdate()
		{
			try
			{
				DataTable dtFields = ctlDuplicateFilterChooser.LeftValuesTable;
				if ( dtFields != null )
				{
					DataView vwFields = new DataView(dtFields);
					XmlNodeList nlFields = xmlMapping.DocumentElement.SelectNodes("Fields/Field");
					foreach ( XmlNode xField in nlFields )
					{
						string sName = xField.Attributes.GetNamedItem("Name").Value;
						vwFields.RowFilter = "value = '" + sName + "'";
						bool bDuplicateFilter = (vwFields.Count > 0);
						XmlUtil.SetSingleNode(xmlMapping, xField, "DuplicateFilter", bDuplicateFilter.ToString());
					}
				}
			}
			catch(Exception ex)
			{
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		private void ctlDuplicateFilterChooser_Bind()
		{
			StringBuilder sbFieldsList = new StringBuilder();
			// 12/17/2008 Paul.  There are some common fields that are unlikely to be filtered on. 
			sbFieldsList.Append("'ID', 'MODIFIED_USER_ID', 'ASSIGNED_USER_ID', 'TEAM_ID'");

			// 04/22/2012 Paul.  vwColumns is global and does not need to be fetched here. 
			vwColumns.RowFilter = "NAME not in (" + sbFieldsList.ToString() + ")";

			ListBox lstLeft = ctlDuplicateFilterChooser.LeftListBox;
			lstLeft.Items.Clear();

			XmlNodeList nlFields = xmlMapping.DocumentElement.SelectNodes("Fields/Field[DuplicateFilter='True']");
			foreach ( XmlNode xField in nlFields )
			{
				ListItem item = new ListItem();
				item.Value = xField.Attributes["Name"].Value;
				item.Text  = Utils.TableColumnName(L10n, sImportModule, item.Value);
				lstLeft.Items.Add(item);

				// 12/17/2008 Paul.  Build the filter for the right-hand-side.
				if ( sbFieldsList.Length > 0 )
					sbFieldsList.Append(", ");
				string sName = xField.Attributes.GetNamedItem("Name").Value;
				sbFieldsList.Append("'" + sName + "'");
			}
			vwColumns.RowFilter = "NAME not in (" + sbFieldsList.ToString() + ")";
			
			ListBox lstRight = ctlDuplicateFilterChooser.RightListBox;
			lstRight.DataValueField = "NAME";
			lstRight.DataTextField  = "DISPLAY_NAME";
			lstRight.DataSource     = vwColumns;
			lstRight.DataBind();

			// 04/22/2012 Paul.  Clear filter after use. 
			vwColumns.RowFilter = "";
		}

		protected void UpdateImportMappings(XmlDocument xml, bool bInitialize, bool bUpdateMappings)
		{
			Hashtable hashFieldMappings = new Hashtable();

			tblImportMappings.Rows.Clear();
			HtmlTableRow rowHeader = new HtmlTableRow();
			tblImportMappings.Rows.Add(rowHeader);
			HtmlTableCell cellField  = new HtmlTableCell();
			HtmlTableCell cellRowHdr = new HtmlTableCell();
			HtmlTableCell cellRow1   = new HtmlTableCell();
			HtmlTableCell cellRow2   = new HtmlTableCell();
			rowHeader.Cells.Add(cellField );
			if ( chkHasHeader.Checked || radXML.Checked )
				rowHeader.Cells.Add(cellRowHdr);
			rowHeader.Cells.Add(cellRow1  );
			rowHeader.Cells.Add(cellRow2  );
			cellField .Attributes.Add("class", "tabDetailViewDL");
			cellRowHdr.Attributes.Add("class", "tabDetailViewDL");
			cellRow1  .Attributes.Add("class", "tabDetailViewDL");
			cellRow2  .Attributes.Add("class", "tabDetailViewDL");
			cellField .Attributes.Add("style", "TEXT-ALIGN: left");
			cellRowHdr.Attributes.Add("style", "TEXT-ALIGN: left");
			cellRow1  .Attributes.Add("style", "TEXT-ALIGN: left");
			cellRow2  .Attributes.Add("style", "TEXT-ALIGN: left");
			Label lblField  = new Label();
			Label lblRowHdr = new Label();
			Label lblRow1   = new Label();
			Label lblRow2   = new Label();
			cellField .Controls.Add(lblField );
			cellRowHdr.Controls.Add(lblRowHdr);
			cellRow1  .Controls.Add(lblRow1  );
			cellRow2  .Controls.Add(lblRow2  );
			lblField .Font.Bold = true;
			lblRowHdr.Font.Bold = true;
			lblRow1  .Font.Bold = true;
			lblRow2  .Font.Bold = true;
			lblField .Text = L10n.Term("Import.LBL_DATABASE_FIELD");
			lblRowHdr.Text = L10n.Term("Import.LBL_HEADER_ROW"    );
			lblRow1  .Text = L10n.Term("Import.LBL_ROW"           ) + " 1";
			lblRow2  .Text = L10n.Term("Import.LBL_ROW"           ) + " 2";
			
			if ( xml.DocumentElement != null )
			{
				XmlNodeList nl = xml.DocumentElement.SelectNodes(sImportModule.ToLower());
				// 05/23/2020 Paul.  Try non-lower case. 
				if ( nl.Count == 0 )
					nl = xml.DocumentElement.SelectNodes(sImportModule);
				if ( nl.Count > 0 )
				{
					vwColumns.Sort = "DISPLAY_NAME";
					XmlNode nodeH = nl[0];
					XmlNode node1 = nl[0];
					XmlNode node2 = null;
					// 08/22/2006 Paul.  An XML Spreadsheet will have a header record, 
					// so don't assume that an XML file will use the tag names as the header. 
					if ( chkHasHeader.Checked )
					{
						if ( nl.Count > 1 )
							node1 = nl[1];
						if ( nl.Count > 2 )
							node2 = nl[2];
					}
					else
					{
						if ( nl.Count > 1 )
							node2 = nl[1];
					}
					bDuplicateFields = false;
					Hashtable hashSelectedFields = new Hashtable();
					for ( int i = 0 ; i < nodeH.ChildNodes.Count ; i++ )
					{
						rowHeader = new HtmlTableRow();
						tblImportMappings.Rows.Add(rowHeader);
						cellField  = new HtmlTableCell();
						cellRowHdr = new HtmlTableCell();
						cellRow1   = new HtmlTableCell();
						cellRow2   = new HtmlTableCell();
						rowHeader.Cells.Add(cellField );
						if ( chkHasHeader.Checked || radXML.Checked )
							rowHeader.Cells.Add(cellRowHdr);
						rowHeader.Cells.Add(cellRow1  );
						if ( node2 != null && i < node2.ChildNodes.Count )
							rowHeader.Cells.Add(cellRow2);
						cellField .Attributes.Add("class", "tabDetailViewDF");
						cellRowHdr.Attributes.Add("class", "tabDetailViewDF");
						cellRow1  .Attributes.Add("class", "tabDetailViewDF");
						cellRow2  .Attributes.Add("class", "tabDetailViewDF");
						// 04/25/2008 Paul.  Use KeySortDropDownList instead of ListSearchExtender. 
						DropDownList lstField  = new KeySortDropDownList();
						// 07/23/2010 Paul.  Lets try the latest version of the ListSearchExtender. 
						// 07/28/2010 Paul.  We are getting an undefined exception on the Accounts List Advanced page. 
						// Lets drop back to using KeySort. 
						//DropDownList lstField  = new DropDownList();
						lblRowHdr = new Label();
						lblRow1   = new Label();
						lblRow2   = new Label();
						cellField .Controls.Add(lstField );
						cellRowHdr.Controls.Add(lblRowHdr);
						cellRow1  .Controls.Add(lblRow1  );
						cellRow2  .Controls.Add(lblRow2  );
						
						// 08/20/2006 Paul.  Clear any previous filters. 
						vwColumns.RowFilter = null;
						// 08/20/2006 Paul.  Don't use real column names as they may collide.
						lstField.ID             = "ImportField" + i.ToString("000");
						lstField.DataValueField = "NAME";
						lstField.DataTextField  = "DISPLAY_NAME";
						lstField.DataSource     = vwColumns;
						lstField.DataBind();
						
						// 04/25/2008 Paul.  Add AJAX searching. 
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
						cellField .Controls.Add(extField );
						*/
						
						lstField.Items.Insert(0, new ListItem(L10n.Term("Import.LBL_DONT_MAP"), String.Empty));
						try
						{
							if ( bInitialize )
							{
								bool bFound = false;
								if ( chkHasHeader.Checked )
								{
									// 08/22/2006 Paul.  If Has Header is checked, then always expect the body to contain the header names. 
									// 01/09/2021 Paul.  An export header may contain a colon if the wrong label is used. 
									string sFieldName = nodeH.ChildNodes[i].InnerText.Trim().Replace(":", "");
									// 08/20/2006 Paul.  Use the DataView to locate matching fields so that we don't have to worry about case significance. 
									// 05/09/2010 Paul.  Also match against a custom field name. 
									// 04/22/2012 Paul.  Calculate a display name without spaces to get better hits with Salesforce field names. 
									sFieldName = Sql.EscapeSQL(sFieldName);
									vwColumns.RowFilter = "NAME = '" + sFieldName + "' or NAME_NOUNDERSCORE = '" + sFieldName + "' or DISPLAY_NAME = '" + sFieldName + "' or DISPLAY_NAME_NOSPACE = '" + sFieldName + "' or NAME = '" + sFieldName.Replace(" ", "_") + "_C" + "'";
									if ( vwColumns.Count > 0 )
									{
										hashFieldMappings.Add(i, Sql.ToString(vwColumns[0]["NAME"]));
										// 08/19/2010 Paul.  Check the list before assigning the value. 
										Utils.SetSelectedValue(lstField, Sql.ToString(vwColumns[0]["NAME"]));
										bFound = true;
									}
								}
								// 05/23/2020 Paul.  If has header flag set, we still may not find the field, so re-check if source is xml. 
								if ( !bFound && radXML.Checked )
								{
									// 08/22/2006 Paul.  If Has Header is not checked for XML, then use the tag ame as the field name. 
									string sFieldName = nodeH.ChildNodes[i].Name;
									// 08/20/2006 Paul.  Use the DataView to locate matching fields so that we don't have to worry about case significance. 
									// 05/09/2010 Paul.  Also match against a custom field name. 
									// 04/22/2012 Paul.  Calculate a display name without spaces to get better hits with Salesforce field names. 
									sFieldName = Sql.EscapeSQL(sFieldName);
									vwColumns.RowFilter = "NAME = '" + sFieldName + "' or NAME_NOUNDERSCORE = '" + sFieldName + "' or DISPLAY_NAME = '" + sFieldName + "' or DISPLAY_NAME_NOSPACE = '" + sFieldName + "' or NAME = '" + sFieldName.Replace(" ", "_") + "_C" + "'";
									if ( vwColumns.Count > 0 )
									{
										hashFieldMappings.Add(i, Sql.ToString(vwColumns[0]["NAME"]));
										// 08/19/2010 Paul.  Check the list before assigning the value. 
										Utils.SetSelectedValue(lstField, Sql.ToString(vwColumns[0]["NAME"]));
										bFound = true;
									}
								}
								else
									hashFieldMappings.Add(i, "ImportField" + i.ToString("000"));
							}
							else
							{
								// 08/20/2006 Paul.  Manually set the last value. 
								hashFieldMappings.Add(i, Sql.ToString(Request[lstField.UniqueID]));
								// 08/19/2010 Paul.  Check the list before assigning the value. 
								Utils.SetSelectedValue(lstField, Sql.ToString(Request[lstField.UniqueID]));
								if ( lstField.SelectedValue.Length > 0 )
								{
									if ( hashSelectedFields.ContainsKey(lstField.SelectedValue) )
									{
										bDuplicateFields = true;
									}
									else
									{
										hashSelectedFields.Add(lstField.SelectedValue, null);
									}
								}
							}
						}
						catch //(Exception ex)
						{
						}
						// XML data will use the node-name as the header. 
						if ( chkHasHeader.Checked )
						{
							// 08/22/2006 Paul.  If Has Header is checked, then always expect the body to contain the header names. 
							lblRowHdr.Text = nodeH.ChildNodes[i].InnerText;
						}
						else if ( radXML.Checked )
						{
							// 08/22/2006 Paul.  If Has Header is not checked for XML, then use the tag name as the field name. 
							lblRowHdr.Text = nodeH.ChildNodes[i].Name;
						}
						
						if ( node1 != null && i < node1.ChildNodes.Count )
							lblRow1.Text = node1.ChildNodes[i].InnerText;
						if ( node2 != null && i < node2.ChildNodes.Count )
							lblRow2.Text = node2.ChildNodes[i].InnerText;
					}
					if ( bDuplicateFields )
					{
						throw(new Exception(L10n.Term("Import.ERR_MULTIPLE")));
					}
					
					if ( bUpdateMappings )
					{
						DuplicateFilterUpdate();
						XmlNodeList nlFields = xmlMapping.DocumentElement.SelectNodes("Fields/Field");
						foreach ( XmlNode xField in nlFields )
						{
							XmlUtil.SetSingleNode(xmlMapping, xField, "Mapping", String.Empty);
						}
						// 08/22/2006 Paul.  We should always use the header mappings instead of an index as nodes may move around. 
						XmlNode node = nl[0];
						for ( int j = 0; j < node.ChildNodes.Count; j++ )
						{
							XmlNode xField = xmlMapping.DocumentElement.SelectSingleNode("Fields/Field[@Name='" + hashFieldMappings[j] + "']");
							if ( xField != null )
							{
								XmlUtil.SetSingleNode(xmlMapping, xField, "Mapping", node.ChildNodes[j].Name);
							}
						}
					}
					else
					{
						// 12/17/2008 Paul.  Apply current filter fields. 
						ctlDuplicateFilterChooser_Bind();
						// 10/12/2006 Paul.  If we are not updating the mappings, then we are setting the mappings. 
						XmlNodeList nlFields = xmlMapping.DocumentElement.SelectNodes("Fields/Field");
						foreach ( XmlNode xField in nlFields )
						{
							string sName    = xField.Attributes.GetNamedItem("Name").Value;
							string sMapping = XmlUtil.SelectSingleNode(xField, "Mapping");
							if ( !Sql.IsEmptyString(sMapping) )
							{
								DropDownList lstField = tblImportMappings.FindControl(sMapping) as DropDownList;
								if ( lstField != null )
								{
									try
									{
										// 08/19/2010 Paul.  Check the list before assigning the value. 
										Utils.SetSelectedValue(lstField, sName);
									}
									catch
									{
									}
								}
							}
						}
					}
				}
			}
		}

		protected void ValidateMappings()
		{
			// 09/09/2015 Paul.  Use the EditView to determine required fields. 
			// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
			// 02/07/2018 Paul.  Provide a way to have the layout view change based on module import control. 
			string sLayoutEditView = "EditView";
			if ( ctlDefaultsView != null )
				sLayoutEditView = ctlDefaultsView.LayoutEditView;
			DataView vwFields = new DataView(SplendidCache.EditViewFields(sImportModule + "." + sLayoutEditView, Security.PRIMARY_ROLE_NAME));
			vwFields.RowFilter = "UI_REQUIRED = 1";
			StringBuilder sb = new StringBuilder();
			foreach ( DataRowView row in vwFields )
			{
				string sDATA_FIELD = Sql.ToString (row["DATA_FIELD"]);
				string sMapping = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='" + sDATA_FIELD + "']/Mapping");
				// 08/09/2017 Paul.  Default value is if mapping not provided. 
				string sDefault = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='" + sDATA_FIELD + "']/Default");
				// 02/07/2018 Paul.  Label should not be LBL_LIST_.  Just use base label. 
				// 09/26/2018 Paul.  Remove colon from term. 
				if ( Sql.IsEmptyString(sMapping) && Sql.IsEmptyString(sDefault) )
					sb.AppendLine(L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term(sImportModule + ".LBL_" + sDATA_FIELD)).Replace(":", "");
			}
			if ( sb.Length > 0 )
				throw ( new Exception(sb.ToString()) );
			/*
			switch ( sImportModule )
			{
				case "Accounts":
				{
					string sMapping = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='NAME']/Mapping");
					if ( Sql.IsEmptyString(sMapping) )
						throw ( new Exception(L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("Accounts.LBL_LIST_ACCOUNT_NAME")) );
					break;
				}
				case "Contacts":
				{
					string sMapping = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='LAST_NAME']/Mapping");
					if ( Sql.IsEmptyString(sMapping) )
						throw ( new Exception(L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("Contacts.LBL_LIST_LAST_NAME")) );
					break;
				}
				case "Leads":
				{
					string sMapping = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='LAST_NAME']/Mapping");
					if ( Sql.IsEmptyString(sMapping) )
						throw ( new Exception(L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("Contacts.LBL_LIST_LAST_NAME")) );
					break;
				}
				case "Prospects":
				{
					string sMapping = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='LAST_NAME']/Mapping");
					if ( Sql.IsEmptyString(sMapping) )
						throw ( new Exception(L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("Prospects.LBL_LIST_LAST_NAME")) );
					break;
				}
				case "Opportunities":
				{
					StringBuilder sb = new StringBuilder();
					string sMapping = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='NAME']/Mapping");
					if ( Sql.IsEmptyString(sMapping) )
						sb.AppendLine(L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("Opportunities.LBL_LIST_NAME"));
					// 11/02/2006 Paul.  Allow mapping of ACCOUNT_NAME or ACCOUNT_ID. 
					sMapping = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='ACCOUNT_NAME']/Mapping");
					// 03/04/2010 Paul.  A default value is valid when checking for required fields. 
					string sDefault = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='ACCOUNT_NAME']/Default");
					if ( Sql.IsEmptyString(sMapping) && Sql.IsEmptyString(sDefault) )
					{
						sMapping = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='ACCOUNT_ID']/Mapping");
						// 03/04/2010 Paul.  A default value is valid when checking for required fields. 
						sDefault = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='ACCOUNT_ID']/Default");
						if ( Sql.IsEmptyString(sMapping) && Sql.IsEmptyString(sDefault) )
							sb.AppendLine(L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("Opportunities.LBL_LIST_ACCOUNT_NAME"));
					}
					sMapping = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='DATE_CLOSED']/Mapping");
					if ( Sql.IsEmptyString(sMapping) )
						sb.AppendLine(L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("Opportunities.LBL_LIST_DATE_CLOSED"));
					sMapping = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='SALES_STAGE']/Mapping");
					// 03/04/2010 Paul.  A default value is valid when checking for required fields. 
					sDefault = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='SALES_STAGE']/Default");
					if ( Sql.IsEmptyString(sMapping) && Sql.IsEmptyString(sDefault) )
						sb.AppendLine(L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("Opportunities.LBL_LIST_SALES_STAGE"));
					if ( sb.Length > 0 )
						throw ( new Exception(sb.ToString()) );
					break;
				}
				case "Cases":
				{
					StringBuilder sb = new StringBuilder();
					string sMapping = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='NAME']/Mapping");
					if ( Sql.IsEmptyString(sMapping) )
						sb.AppendLine(L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("Cases.LBL_LIST_NAME"));
					// 11/02/2006 Paul.  Allow mapping of ACCOUNT_NAME or ACCOUNT_ID. 
					sMapping = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='ACCOUNT_NAME']/Mapping");
					if ( Sql.IsEmptyString(sMapping) )
					{
						sMapping = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='ACCOUNT_ID']/Mapping");
						// 03/04/2010 Paul.  A default value is valid when checking for required fields. 
						string sDefault = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='ACCOUNT_ID']/Default");
						if ( Sql.IsEmptyString(sMapping) && Sql.IsEmptyString(sDefault) )
							sb.AppendLine(L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("Cases.LBL_LIST_ACCOUNT_NAME"));
					}
					if ( sb.Length > 0 )
						throw ( new Exception(sb.ToString()) );
					break;
				}
				case "Users":
				{
					StringBuilder sb = new StringBuilder();
					string sMapping = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='USER_NAME']/Mapping");
					if ( Sql.IsEmptyString(sMapping) )
						sb.AppendLine(L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("Users.LBL_USER_NAME"));
					sMapping = XmlUtil.SelectSingleNode(xmlMapping.DocumentElement, "Fields/Field[@Name='LAST_NAME']/Mapping");
					if ( Sql.IsEmptyString(sMapping) )
					{
						sb.AppendLine(L10n.Term(".ERR_MISSING_REQUIRED_FIELDS") + " " + L10n.Term("Users.LBL_LAST_NAME"));
					}
					if ( sb.Length > 0 )
						throw ( new Exception(sb.ToString()) );
					break;
				}
			}
			*/
		}

		private void PreviewGrid(DataTable dtProcessed)
		{
			vwColumns.Sort = "DISPLAY_NAME";
			Hashtable hashColumns = new Hashtable();
			foreach ( DataRowView row in vwColumns )
			{
				// 05/24/2020 Paul.  An XML import of Accounts generated a duplicate TEAM_NAME key. 
				//Debug.WriteLine(Sql.ToString(row["NAME"]));
				hashColumns.Add(row["NAME"], row["DISPLAY_NAME"]);
			}

			// 10/31/2006 Paul.  Always reset columns before adding them. 
			grdMain.Columns.Clear();
			BoundColumn bnd = new BoundColumn();
			bnd.DataField  = "IMPORT_ROW_NUMBER";
			bnd.SortExpression = bnd.DataField;
			bnd.HeaderText = L10n.Term("Import.LBL_ROW");
			grdMain.Columns.Add(bnd);

			bnd = new BoundColumn();
			bnd.DataField  = "IMPORT_ROW_ERROR";
			bnd.SortExpression = bnd.DataField;
			bnd.HeaderText = L10n.Term("Import.LBL_ROW_STATUS");
			grdMain.Columns.Add(bnd);

			for ( int i = 4; i < dtProcessed.Columns.Count; i++ )
			{
				bnd = new BoundColumn();
				bnd.DataField = dtProcessed.Columns[i].ColumnName;
				bnd.SortExpression = bnd.DataField;
				if ( hashColumns.ContainsKey(bnd.DataField) )
					bnd.HeaderText = hashColumns[bnd.DataField] as string;
				else
					bnd.HeaderText = bnd.DataField;
				grdMain.Columns.Add(bnd);
			}
			
			grdMain.DataSource = new DataView(dtProcessed);
			grdMain.ApplySort();
			grdMain.DataBind();
		}

		private void GetOAuthAccessTokens()
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				sSQL = "select *                                   " + ControlChars.CrLf
				     + "  from vwOAUTH_TOKENS                      " + ControlChars.CrLf
				     + " where NAME             = @NAME            " + ControlChars.CrLf
				     + "   and ASSIGNED_USER_ID = @ASSIGNED_USER_ID" + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@NAME"            , this.SourceType());
					Sql.AddParameter(cmd, "@ASSIGNED_USER_ID", Security.USER_ID);
					if ( bDebug )
						RegisterClientScriptBlock("vwOAUTH_TOKENS", Sql.ClientScriptBlock(cmd));

					using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
					{
						if ( rdr.Read() )
						{
							txtOAUTH_ACCESS_TOKEN .Value = Sql.ToString(rdr["TOKEN" ]);
							txtOAUTH_ACCESS_SECRET.Value = Sql.ToString(rdr["SECRET"]);
						}
					}
				}
			}
		}
		#endregion

		// 09/17/2013 Paul.  Add Business Rules to import. 
		#region Business Rules Helper methods
		protected void ResetRuleText()
		{
			txtRULE_ID     .Value         = String.Empty;
			txtRULE_NAME   .Text          = String.Empty;
			txtPRIORITY    .Text          = "0";
			lstREEVALUATION.SelectedIndex = 0;
			chkACTIVE      .Checked       = true;
			txtCONDITION   .Text          = String.Empty;
			txtTHEN_ACTIONS.Text          = String.Empty;
			txtELSE_ACTIONS.Text          = String.Empty;
		}

		protected void RulesGet(Guid gID, ref string sRULE_NAME, ref int nPRIORITY, ref string sREEVALUATION, ref bool bACTIVE, ref string sCONDITION, ref string sTHEN_ACTIONS, ref string sELSE_ACTIONS)
		{
			DataView vwRules = new DataView(dtRules);
			vwRules.RowFilter = "ID = '" + gID.ToString() + "'";
			if ( vwRules.Count > 0 )
			{
				sRULE_NAME    = Sql.ToString (vwRules[0]["RULE_NAME"   ]);
				nPRIORITY     = Sql.ToInteger(vwRules[0]["PRIORITY"    ]);
				sREEVALUATION = Sql.ToString (vwRules[0]["REEVALUATION"]);
				bACTIVE       = Sql.ToBoolean(vwRules[0]["ACTIVE"      ]);
				sCONDITION    = Sql.ToString (vwRules[0]["CONDITION"   ]);
				sTHEN_ACTIONS = Sql.ToString (vwRules[0]["THEN_ACTIONS"]);
				sELSE_ACTIONS = Sql.ToString (vwRules[0]["ELSE_ACTIONS"]);
			}
		}

		protected void RulesUpdate(Guid gID, string sRULE_NAME, int nPRIORITY, string sREEVALUATION, bool bACTIVE, string sCONDITION, string sTHEN_ACTIONS, string sELSE_ACTIONS)
		{
			DataView vwRules = new DataView(dtRules);
			vwRules.RowFilter = "ID = '" + gID.ToString() + "'";
			try
			{
				if ( vwRules.Count > 0 )
				{
					vwRules[0]["RULE_NAME"   ] = sRULE_NAME   ;
					vwRules[0]["PRIORITY"    ] = nPRIORITY    ;
					vwRules[0]["REEVALUATION"] = sREEVALUATION;
					vwRules[0]["ACTIVE"      ] = bACTIVE      ;
					vwRules[0]["CONDITION"   ] = sCONDITION   ;
					vwRules[0]["THEN_ACTIONS"] = sTHEN_ACTIONS;
					vwRules[0]["ELSE_ACTIONS"] = sELSE_ACTIONS;
				}
				else
				{
					DataRow row = dtRules.NewRow();
					dtRules.Rows.Add(row);
					row["ID"          ] = Guid.NewGuid();
					row["RULE_NAME"   ] = sRULE_NAME   ;
					row["PRIORITY"    ] = nPRIORITY    ;
					row["REEVALUATION"] = sREEVALUATION;
					row["ACTIVE"      ] = bACTIVE      ;
					row["CONDITION"   ] = sCONDITION   ;
					row["THEN_ACTIONS"] = sTHEN_ACTIONS;
					row["ELSE_ACTIONS"] = sELSE_ACTIONS;
				}
				dgRules.DataSource = dtRules;
				dgRules.DataBind();
			}
			catch(Exception ex)
			{
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		protected void RulesDelete(Guid gID)
		{
			dgRules.EditItemIndex = -1;
			for ( int i = 0; i < dtRules.Rows.Count; i++ )
			{
				DataRow row = dtRules.Rows[i];
				if ( gID == Sql.ToGuid(row["ID"]) )
				{
					row.Delete();
					break;
				}
			}
			dtRules.AcceptChanges();
			dgRules.DataSource = dtRules;
			dgRules.DataBind();
		}
		#endregion

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "Import.Load" )
				{
					gID = Sql.ToGuid(e.CommandArgument);
					Response.Redirect(Request.Path + "?ID=" + gID.ToString());
				}
				else if ( e.CommandName == "Import.Delete" )
				{
					gID = Sql.ToGuid(e.CommandArgument);
					SqlProcs.spIMPORT_MAPS_Delete(gID);
					BindSaved();
					txtACTIVE_TAB.Value = "1";
					ViewState["ID"] = Guid.Empty;
				}
				else if ( e.CommandName == "Import.Save" )
				{
					reqNAME.Enabled = true;
					reqNAME.Validate();
					if ( Page.IsValid )
					{
						// 03/16/2010 Paul.  The ViewState will be the primary location for the ID. 
						gID = Sql.ToGuid(ViewState["ID"]);
						// 10/12/2006 Paul.  Save the sample data with the mappings. 
						XmlUtil.SetSingleNode(xmlMapping, "Sample", xml.OuterXml);
						
						// 09/17/2013 Paul.  Add Business Rules to import. 
						StringBuilder sbRulesXML = new StringBuilder();
						if ( dtRules != null && dtRules.Rows.Count > 0 )
						{
							SplendidRulesTypeProvider typeProvider = new SplendidRulesTypeProvider();
							RuleValidation validation = new RuleValidation(typeof(SplendidImportThis), typeProvider);
							RuleSet rules = RulesUtil.BuildRuleSet(dtRules, validation);
						
							string sXOML = RulesUtil.Serialize(rules);
							using ( StringWriter wtr = new StringWriter(sbRulesXML, System.Globalization.CultureInfo.InvariantCulture) )
							{
								dtRules.WriteXml(wtr, XmlWriteMode.WriteSchema, false);
							}
						}
						SqlProcs.spIMPORT_MAPS_Update
							( ref gID
							, Security.USER_ID
							, txtNAME.Text
							, SourceType()
							, sImportModule
							, chkHasHeader.Checked
							, false
							, xmlMapping.OuterXml
							, sbRulesXML.ToString()
							);
						XmlUtil.SetSingleNode(xmlMapping, "Sample", String.Empty);
						// 03/16/2010 Paul.  Preserve the name.
						//txtNAME.Text = String.Empty;
						BindSaved();
						ViewState["ID"] = gID;
					}
					else
					{
						txtACTIVE_TAB.Value = "1";
					}
				}
				else if ( e.CommandName == "Import.Run" || e.CommandName == "Import.Preview" )
				{
					if ( Page.IsValid && !bDuplicateFields )
					{
						// 10/10/2006 Paul.  The temp file name is stored in the session so that it is impossible for a hacker to access. 
						string sTempFileID   = Sql.ToString(ViewState["TempFileID"]);
						string sTempFileName = Sql.ToString(Session["TempFile." + sTempFileID]);
						if ( Sql.IsEmptyString(sTempFileID) || Sql.IsEmptyString(sTempFileName) )
						{
							txtACTIVE_TAB.Value = "3";
							throw(new Exception(L10n.Term("Import.LBL_NOTHING")));
						}

						// 10/10/2006 Paul.  If there is a validation error, we want to display the mappings page. 
						// If there is no error, or if the error was during import, then show the results page. 
						txtACTIVE_TAB.Value = "4";
						ValidateMappings();
						// 12/17/2008 Paul.  The results tab is now 6. 
						// 09/17/2013 Paul.  Add Business Rules to import. Results tab is now 7. 
						txtACTIVE_TAB.Value = "7";
						// 02/05/2010 Paul.  An ACT! import can take a long time. 
						Server.ScriptTimeout = 20 * 60;
						
						// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
						// 02/07/2018 Paul.  Provide a way to have the layout view change based on module import control. 
						string sLayoutEditView = "EditView";
						if ( ctlDefaultsView != null )
							sLayoutEditView = ctlDefaultsView.LayoutEditView;
						Guid gPROSPECT_LIST_ID = Sql.ToGuid(ViewState["PROSPECT_LIST_ID"]);
						
						int    nImported   = 0;
						int    nFailed     = 0;
						int    nDuplicates = 0;
						string sProcessedFileID   = Guid.NewGuid().ToString();
						DataTable dtProcessed = new DataTable();
						StringBuilder sbErrors = new StringBuilder();
						// 09/04/2010 Paul.  Log the import time. 
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "Begin Import");
						// 05/22/2020 Paul.  Move GenerateImport to separate ImportUtils file as it is now shared with the React Client. 
						ImportUtils.GenerateImport(Application, L10n, this, sImportModule, SourceType(), vwColumns, xmlMapping, dtRules, sLayoutEditView, sTempFileName, e.CommandName == "Import.Preview", chkHasHeader.Checked, chkUseTransaction.Checked, gPROSPECT_LIST_ID, sbImport, sbErrors, sProcessedFileID, dtProcessed, ref nImported, ref nFailed, ref nDuplicates);
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "End Import");
						if ( sbErrors.Length > 0 )
						{
							ctlDynamicButtons.ErrorText = sbErrors.ToString();
						}
						lblStatus.Text = String.Empty;
						// 03/20/2011 Paul.  Include a preview indicator. 
						if ( e.CommandName == "Import.Preview" )
							lblStatus.Text += L10n.Term("Import.LBL_PREVIEW_BUTTON_LABEL") + " ";
						if ( nFailed == 0 )
							lblStatus.Text += L10n.Term("Import.LBL_SUCCESS");
						else
							lblStatus.Text += L10n.Term("Import.LBL_FAIL"   );
						lblSuccessCount  .Text = nImported.ToString()   + " " + L10n.Term("Import.LBL_SUCCESSFULLY" );
						lblFailedCount   .Text = nFailed.ToString()     + " " + L10n.Term("Import.LBL_FAILED_IMPORT");
						lblDuplicateCount.Text = nDuplicates.ToString() + " " + L10n.Term("Import.LBL_DUPLICATES_IGNORED");
						// 08/15/2017 Paul.  Provide a way to export errors. 
						lnkExportErrors  .Text        = L10n.Term("Import.LNK_EXPORT_ERRORS");
						lnkExportErrors  .Visible     = (nFailed > 0);
						lnkExportErrors  .NavigateUrl = "~/Import/errors.aspx?ProcessedFileID=" + sProcessedFileID + "&SourceType=" + SourceType();
				
						grdMain.SortColumn = "IMPORT_ROW_STATUS, IMPORT_ROW_NUMBER";
						grdMain.SortOrder  = "asc" ;
						PreviewGrid(dtProcessed);
					}
				}
				else if ( e.CommandName == "Import.Upload" )
				{
					reqFILENAME.Enabled = true;
					reqFILENAME.Validate();
					if ( Page.IsValid )
					{
						HttpPostedFile pstIMPORT = fileIMPORT.PostedFile;
						if ( pstIMPORT != null )
						{
							if ( pstIMPORT.FileName.Length > 0 )
							{
								string sFILENAME       = Path.GetFileName (pstIMPORT.FileName);
								string sFILE_EXT       = Path.GetExtension(sFILENAME);
								string sFILE_MIME_TYPE = pstIMPORT.ContentType;
								// 04/27/2018 Paul.  Correct the source type based on the file type. 
								if ( sFILE_EXT == ".xlsx" || sFILE_EXT == ".xls" )
									this.SourceType("excel");
								else if ( sFILE_EXT == ".csv" )
									this.SourceType("other");
								// 05/20/2020 Paul.  txt can be for csv or custom delimited. 
								else if ( sFILE_EXT == ".txt" )
								{
									if ( !Sql.IsEmptyString(txtCUSTOM_DELIMITER_VAL.Text) )
										this.SourceType("custom_delimited");
									else
										this.SourceType("other");
								}
								else if ( sFILE_EXT == ".tab" )
									this.SourceType("other_tab");
								else if ( sFILE_EXT == ".xml" )
									this.SourceType("xml");
								
								// 09/04/2010 Paul.  ACT Imports are taking a long time.  Time the stream conversion to see where the problem lies. 
								SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "Begin Upload: " + sFILENAME);
								// 05/06/2011 Paul.  We need to be able to distinguish between Excel 2003 and Excel 2007. 
								xml = SplendidImport.ConvertStreamToXml(sImportModule, SourceType(), txtCUSTOM_DELIMITER_VAL.Text, pstIMPORT.InputStream, sFILE_EXT);
								
								if ( xml.DocumentElement == null )
									throw(new Exception(L10n.Term("Import.LBL_NOTHING")));
								
								// 08/21/2006 Paul.  Don't move to next step if there is no data. 
								XmlNodeList nlRows = xml.DocumentElement.SelectNodes(sImportModule.ToLower());
								// 05/23/2020 Paul.  Try non-lower case. 
								if ( nlRows.Count == 0 )
									nlRows = xml.DocumentElement.SelectNodes(sImportModule);
								if ( nlRows.Count == 0 )
									throw(new Exception(L10n.Term("Import.LBL_NOTHING")));
								
								// 10/10/2006 Paul.  Don't store the file name in the ViewState because a hacker could find a way to access and alter it.
								// Storing the file name in the session and an ID in the view state should be sufficiently safe. 
								string sTempFileID   = Guid.NewGuid().ToString();
								string sTempFileName = Security.USER_ID.ToString() + " " + Guid.NewGuid().ToString() + " " + sFILENAME + ".xml";
								xml.Save(Path.Combine(Path.GetTempPath(), sTempFileName));
								// 01/30/2010 Paul.  Were were not storing the full path in the Session for cleanup. 
								Session["TempFile." + sTempFileID] = Path.Combine(Path.GetTempPath(), sTempFileName);
								ViewState["TempFileID"] = sTempFileID;
								
								// 10/10/2006 Paul.  We only need to save a small portion of the imported data as a sample. 
								// Trying to save too much data in ViewState can cause memory errors. 
								// 10/31/2006 Paul.  It is taking too long to reduce the size of a large XML file. 
								// Instead, extract the three rows and attach to a new XML document. 
								XmlDocument xmlSample = new XmlDocument();
								xmlSample.AppendChild(xmlSample.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
								xmlSample.AppendChild(xmlSample.CreateElement("xml"));
								// 10/31/2006 Paul.  Select only the nodes that apply.  We need to make sure to skip unrelated nodes. 
								for ( int i = 0; i < nlRows.Count && i < 3 ; i++ )
								{
									XmlNode node = nlRows[i];
									xmlSample.DocumentElement.AppendChild(xmlSample.ImportNode(node, true));
								}
								// 10/31/2006 Paul.  We are getting an OutOfMemoryException.  Try to free the large XML file. 
								xml = null;
								nlRows = null;
								xml = xmlSample;
								GC.Collect();
								// 09/04/2010 Paul.  Store the sample data in the Session to prevent a huge download. 
								// We are seeing a 13M html file for an 8M import file. 
								Session[sImportModule + ".xmlSample." + sFILENAME] = xml.OuterXml;
								ViewState["xmlSample"] = sImportModule + ".xmlSample." + sFILENAME;

								bool bUpdateMapping = (Request["ID"] == null);
								UpdateImportMappings(xml, bUpdateMapping, bUpdateMapping);
								txtACTIVE_TAB.Value = "4";
								SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "End Upload: " + sFILENAME);
							}
						}
					}
					if ( xml.DocumentElement == null )
						throw(new Exception(L10n.Term("Import.LBL_NOTHING")));
				}
				else if ( e.CommandName == "Cancel" )
				{
					string sRelativePath = Sql.ToString(Application["Modules." + sImportModule + ".RelativePath"]);
					if ( Sql.IsEmptyString(sRelativePath) )
						sRelativePath = "~/" + sImportModule + "/";
					Response.Redirect(sRelativePath);
				}
				// 04/08/2012 Paul.  LinkedIn OAuth events. 
				// 04/13/2012 Paul.  Move the authorization URL lookup to the Soure Type change event so that the button click will do the action.  
				// Attempting window.open() after a postback has issues with popup blockers. 
				/*
				else if ( e.CommandName == "Import.SignIn" )
				{
					string sRedirectURL = Request.Url.Scheme + "://" + Request.Url.Host + Sql.ToString(Application["rootURL"]) + "Import/OAuthLanding.aspx";
					if ( this.SourceType() == "LinkedIn" )
					{
						string sLinkedInApiKey    = Sql.ToString(Application["CONFIG.LinkedIn.APIKey"   ]);
						string sLinkedInApiSecret = Sql.ToString(Application["CONFIG.LinkedIn.SecretKey"]);
						Spring.Social.LinkedIn.Connect.LinkedInServiceProvider linkedInServiceProvider = new Spring.Social.LinkedIn.Connect.LinkedInServiceProvider(sLinkedInApiKey, sLinkedInApiSecret);
						Spring.Social.OAuth1.OAuthToken oauthToken = linkedInServiceProvider.OAuthOperations.FetchRequestToken(sRedirectURL, null);
						string authenticateUrl = linkedInServiceProvider.OAuthOperations.BuildAuthorizeUrl(oauthToken.Value, null);
						txtOAUTH_TOKEN        .Value = oauthToken.Value ;
						txtOAUTH_SECRET       .Value = oauthToken.Secret;
						txtOAUTH_VERIFIER     .Value = String.Empty     ;
						txtOAUTH_REALMID      .Value = String.Empty     ;
						txtOAUTH_ACCESS_TOKEN .Value = String.Empty     ;
						txtOAUTH_ACCESS_SECRET.Value = String.Empty     ;
						
						RegisterClientScriptBlock(this.SourceType() + "Popup", "<script type=\"text/javascript\">window.open('" + authenticateUrl + "', '" + this.SourceType() + "Popup" + "', 'width=600,height=360,status=1,toolbar=0,location=0');</script>");
					}
					else if ( this.SourceType() == "Twitter" )
					{
						// 04/08/2012 Paul.  We were getting (401) Unauthorized until we specified a valid Callback URL in the Twitter Application (http://dev.twitter.com). 
						string sTwitterConsumerKey    = Sql.ToString(Application["CONFIG.Twitter.ConsumerKey"   ]);
						string sTwitterConsumerSecret = Sql.ToString(Application["CONFIG.Twitter.ConsumerSecret"]);
						Spring.Social.Twitter.Connect.TwitterServiceProvider twitterServiceProvider = new Spring.Social.Twitter.Connect.TwitterServiceProvider(sTwitterConsumerKey, sTwitterConsumerSecret);
						Spring.Social.OAuth1.OAuthToken oauthToken = twitterServiceProvider.OAuthOperations.FetchRequestToken(sRedirectURL, null);
						string authenticateUrl = twitterServiceProvider.OAuthOperations.BuildAuthorizeUrl(oauthToken.Value, null);
						txtOAUTH_TOKEN        .Value = oauthToken.Value ;
						txtOAUTH_SECRET       .Value = oauthToken.Secret;
						txtOAUTH_VERIFIER     .Value = String.Empty     ;
						txtOAUTH_REALMID      .Value = String.Empty     ;
						txtOAUTH_ACCESS_TOKEN .Value = String.Empty     ;
						txtOAUTH_ACCESS_SECRET.Value = String.Empty     ;
						
						RegisterClientScriptBlock(this.SourceType() + "Popup", "<script type=\"text/javascript\">window.open('" + authenticateUrl + "', '" + this.SourceType() + "Popup" + "', 'width=600,height=360,status=1,toolbar=0,location=0');</script>");
					}
					else if ( this.SourceType() == "Facebook" )
					{
						string sFacebookAppID     = Sql.ToString(Application["CONFIG.facebook.AppID"    ]);
						string sFacebookAppSecret = Sql.ToString(Application["CONFIG.facebook.AppSecret"]);

						Spring.Social.Facebook.Connect.FacebookServiceProvider facebookServiceProvider = new Spring.Social.Facebook.Connect.FacebookServiceProvider(sFacebookAppID, sFacebookAppSecret);
						Spring.Social.OAuth2.OAuth2Parameters parameters = new Spring.Social.OAuth2.OAuth2Parameters()
						{
							RedirectUrl = sRedirectURL,
							Scope = "publish_stream"
						};
						string authenticateUrl = facebookServiceProvider.OAuthOperations.BuildAuthorizeUrl(Spring.Social.OAuth2.GrantType.ImplicitGrant, parameters);
						txtOAUTH_TOKEN        .Value = String.Empty;
						txtOAUTH_SECRET       .Value = String.Empty;
						txtOAUTH_VERIFIER     .Value = String.Empty;
						txtOAUTH_REALMID      .Value = String.Empty;
						txtOAUTH_ACCESS_TOKEN .Value = String.Empty;
						txtOAUTH_ACCESS_SECRET.Value = String.Empty;
						
						RegisterClientScriptBlock(this.SourceType() + "Popup", "<script type=\"text/javascript\">window.open('" + authenticateUrl + "', '" + this.SourceType() + "Popup" + "', 'width=600,height=360,status=1,toolbar=0,location=0');</script>");
					}
					else if ( this.SourceType() == "salesforce" )
					{
						string sSalesforceConsumerKey    = Sql.ToString(Application["CONFIG.Salesforce.ConsumerKey"   ]);
						string sSalesforceConsumerSecret = Sql.ToString(Application["CONFIG.Salesforce.ConsumerSecret"]);
						Spring.Social.Salesforce.Connect.SalesforceServiceProvider salesforceServiceProvider = new Spring.Social.Salesforce.Connect.SalesforceServiceProvider(sSalesforceConsumerKey, sSalesforceConsumerSecret);
						Spring.Social.OAuth1.OAuthToken oauthToken = salesforceServiceProvider.OAuthOperations.FetchRequestToken(sRedirectURL, null);
						string authenticateUrl = salesforceServiceProvider.OAuthOperations.BuildAuthorizeUrl(oauthToken.Value, null);
						txtOAUTH_TOKEN        .Value = oauthToken.Value ;
						txtOAUTH_SECRET       .Value = oauthToken.Secret;
						txtOAUTH_VERIFIER     .Value = String.Empty     ;
						txtOAUTH_REALMID      .Value = String.Empty     ;
						txtOAUTH_ACCESS_TOKEN .Value = String.Empty     ;
						txtOAUTH_ACCESS_SECRET.Value = String.Empty     ;
						
						RegisterClientScriptBlock(this.SourceType() + "Popup", "<script type=\"text/javascript\">window.open('" + authenticateUrl + "', '" + this.SourceType() + "Popup" + "', 'width=600,height=360,status=1,toolbar=0,location=0');</script>");
					}
				}
				*/
				else if ( e.CommandName == "Import.SignOut" )
				{
					// 04/08/2012 Paul.  When the OAuth key is deleted, the access tokens become invalid, so delete them. 
					SqlProcs.spOAUTHKEYS_Delete(Security.USER_ID, this.SourceType());
					btnSignIn.Visible  = true;
					btnConnect.Visible = !btnSignIn.Visible;
					btnSignOut.Visible = !btnSignIn.Visible;
					txtOAUTH_TOKEN        .Value = String.Empty;
					txtOAUTH_SECRET       .Value = String.Empty;
					txtOAUTH_VERIFIER     .Value = String.Empty;
					txtOAUTH_REALMID      .Value = String.Empty;
					// 04/23/2015 Paul.  HubSpot has more data. 
					txtOAUTH_REFRESH_TOKEN.Value = String.Empty;
					txtOAUTH_EXPIRES_IN   .Value = String.Empty;
					txtOAUTH_ACCESS_TOKEN .Value = String.Empty;
					txtOAUTH_ACCESS_SECRET.Value = String.Empty;
					SOURCE_TYPE_CheckedChanged(null, null);
				}
				else if ( e.CommandName == "Import.OAuthToken" )
				{
					// 06/03/2014 Paul.  QuickBooks Online is going to use a different API than standard QuickBooks. 
					if ( this.SourceType() == "LinkedIn" && !Sql.IsEmptyString(txtOAUTH_TOKEN.Value) && !Sql.IsEmptyString(txtOAUTH_SECRET.Value) && !Sql.IsEmptyString(txtOAUTH_VERIFIER.Value) )
					{
						SqlProcs.spOAUTHKEYS_Update(Security.USER_ID, this.SourceType(), txtOAUTH_TOKEN.Value, txtOAUTH_SECRET.Value, txtOAUTH_VERIFIER.Value);
						btnSignIn.Visible  = false;
						btnConnect.Visible = !btnSignIn.Visible;
						btnSignOut.Visible = !btnSignIn.Visible;
						
						string sLinkedInApiKey    = Sql.ToString(Application["CONFIG.LinkedIn.APIKey"   ]);
						string sLinkedInApiSecret = Sql.ToString(Application["CONFIG.LinkedIn.SecretKey"]);
						Spring.Social.LinkedIn.Connect.LinkedInServiceProvider linkedInServiceProvider = new Spring.Social.LinkedIn.Connect.LinkedInServiceProvider(sLinkedInApiKey, sLinkedInApiSecret);
						Spring.Social.OAuth1.OAuthToken             oauthToken       = new Spring.Social.OAuth1.OAuthToken(txtOAUTH_TOKEN.Value, txtOAUTH_SECRET.Value);
						Spring.Social.OAuth1.AuthorizedRequestToken requestToken     = new Spring.Social.OAuth1.AuthorizedRequestToken(oauthToken, txtOAUTH_VERIFIER.Value);
						Spring.Social.OAuth1.OAuthToken             oauthAccessToken = linkedInServiceProvider.OAuthOperations.ExchangeForAccessTokenAsync(requestToken, null).Result;
						txtOAUTH_ACCESS_TOKEN .Value = oauthAccessToken.Value ;
						txtOAUTH_ACCESS_SECRET.Value = oauthAccessToken.Secret;
						// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
						SqlProcs.spOAUTH_TOKENS_Update(Security.USER_ID, this.SourceType(), oauthAccessToken.Value, oauthAccessToken.Secret, DateTime.MinValue, String.Empty);
					}
					else if ( this.SourceType() == "Twitter" && !Sql.IsEmptyString(txtOAUTH_TOKEN.Value) && !Sql.IsEmptyString(txtOAUTH_SECRET.Value) && !Sql.IsEmptyString(txtOAUTH_VERIFIER.Value) )
					{
						SqlProcs.spOAUTHKEYS_Update(Security.USER_ID, this.SourceType(), txtOAUTH_TOKEN.Value, txtOAUTH_SECRET.Value, txtOAUTH_VERIFIER.Value);
						btnSignIn.Visible  = false;
						btnConnect.Visible = !btnSignIn.Visible;
						btnSignOut.Visible = !btnSignIn.Visible;
						
						string sTwitterConsumerKey    = Sql.ToString(Application["CONFIG.Twitter.ConsumerKey"   ]);
						string sTwitterConsumerSecret = Sql.ToString(Application["CONFIG.Twitter.ConsumerSecret"]);
						Spring.Social.Twitter.Connect.TwitterServiceProvider twitterServiceProvider = new Spring.Social.Twitter.Connect.TwitterServiceProvider(sTwitterConsumerKey, sTwitterConsumerSecret);
						Spring.Social.OAuth1.OAuthToken             oauthToken       = new Spring.Social.OAuth1.OAuthToken(txtOAUTH_TOKEN.Value, txtOAUTH_SECRET.Value);
						Spring.Social.OAuth1.AuthorizedRequestToken requestToken     = new Spring.Social.OAuth1.AuthorizedRequestToken(oauthToken, txtOAUTH_VERIFIER.Value);
						Spring.Social.OAuth1.OAuthToken             oauthAccessToken = twitterServiceProvider.OAuthOperations.ExchangeForAccessTokenAsync(requestToken, null).Result;
						txtOAUTH_ACCESS_TOKEN .Value = oauthAccessToken.Value ;
						txtOAUTH_ACCESS_SECRET.Value = oauthAccessToken.Secret;
						// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
						SqlProcs.spOAUTH_TOKENS_Update(Security.USER_ID, this.SourceType(), oauthAccessToken.Value, oauthAccessToken.Secret, DateTime.MinValue, String.Empty);
					}
					else if ( this.SourceType() == "QuickBooksOnline" && !Sql.IsEmptyString(txtOAUTH_TOKEN.Value) && !Sql.IsEmptyString(txtOAUTH_SECRET.Value) && !Sql.IsEmptyString(txtOAUTH_VERIFIER.Value) )
					{
						SqlProcs.spOAUTHKEYS_Update(Security.USER_ID, this.SourceType(), txtOAUTH_TOKEN.Value, txtOAUTH_SECRET.Value, txtOAUTH_VERIFIER.Value);
						btnSignIn.Visible  = false;
						btnConnect.Visible = !btnSignIn.Visible;
						btnSignOut.Visible = !btnSignIn.Visible;
						
						string sQuickBooksApiKey    = Sql.ToString(Application["CONFIG.QuickBooks.OAuthClientID"    ]);
						string sQuickBooksApiSecret = Sql.ToString(Application["CONFIG.QuickBooks.OAuthClientSecret"]);
						Spring.Social.QuickBooks.Connect.QuickBooksServiceProvider quickBooksServiceProvider = new Spring.Social.QuickBooks.Connect.QuickBooksServiceProvider(sQuickBooksApiKey, sQuickBooksApiSecret);
						Spring.Social.OAuth1.OAuthToken             oauthToken       = new Spring.Social.OAuth1.OAuthToken(txtOAUTH_TOKEN.Value, txtOAUTH_SECRET.Value);
						Spring.Social.OAuth1.AuthorizedRequestToken requestToken     = new Spring.Social.OAuth1.AuthorizedRequestToken(oauthToken, txtOAUTH_VERIFIER.Value);
						Spring.Social.OAuth1.OAuthToken             oauthAccessToken = quickBooksServiceProvider.OAuthOperations.ExchangeForAccessTokenAsync(requestToken, null).Result;
						txtOAUTH_ACCESS_TOKEN .Value = oauthAccessToken.Value ;
						txtOAUTH_ACCESS_SECRET.Value = oauthAccessToken.Secret;
						// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
						SqlProcs.spOAUTH_TOKENS_Update(Security.USER_ID, this.SourceType(), oauthAccessToken.Value, oauthAccessToken.Secret, DateTime.MinValue, String.Empty);
					}
					else if ( this.SourceType() == "Facebook" && !Sql.IsEmptyString(txtOAUTH_TOKEN.Value) )
					{
						// 04/13/2012 Paul.  Facebook only has one token, so store in both tables so that most of the logic will remain. 
						SqlProcs.spOAUTHKEYS_Update(Security.USER_ID, this.SourceType(), txtOAUTH_TOKEN.Value, String.Empty, String.Empty);
						txtOAUTH_ACCESS_TOKEN .Value = txtOAUTH_TOKEN.Value ;
						// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
						SqlProcs.spOAUTH_TOKENS_Update(Security.USER_ID, this.SourceType(), txtOAUTH_ACCESS_TOKEN.Value, String.Empty, DateTime.MinValue, String.Empty);
						btnSignIn.Visible  = false;
						btnConnect.Visible = !btnSignIn.Visible;
						btnSignOut.Visible = !btnSignIn.Visible;
					}
					// 04/23/2015 Paul.  HubSpot uses OAuth2, similar to Facebook. 
					else if ( this.SourceType() == "HubSpot" && !Sql.IsEmptyString(txtOAUTH_TOKEN.Value) )
					{
						// 04/23/2015 Paul.  HubSpot only has one token, so store in both tables so that most of the logic will remain. 
						SqlProcs.spOAUTHKEYS_Update(Security.USER_ID, this.SourceType(), txtOAUTH_TOKEN.Value, String.Empty, String.Empty);
						txtOAUTH_ACCESS_TOKEN .Value = txtOAUTH_TOKEN.Value ;
						// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
						SqlProcs.spOAUTH_TOKENS_Update(Security.USER_ID, this.SourceType(), txtOAUTH_ACCESS_TOKEN.Value, String.Empty, DateTime.MinValue, String.Empty);
						btnSignIn.Visible  = false;
						btnConnect.Visible = !btnSignIn.Visible;
						btnSignOut.Visible = !btnSignIn.Visible;
					}
					else if ( this.SourceType() == "salesforce" && !Sql.IsEmptyString(txtOAUTH_TOKEN.Value) && !Sql.IsEmptyString(txtOAUTH_VERIFIER.Value) )
					{
						// 04/22/2012 Paul.  Salesforce only has one token, so store in both tables so that most of the logic will remain. 
						SqlProcs.spOAUTHKEYS_Update(Security.USER_ID, this.SourceType(), txtOAUTH_TOKEN.Value, String.Empty, String.Empty);
						txtOAUTH_ACCESS_TOKEN .Value = txtOAUTH_TOKEN.Value   ;
						txtOAUTH_ACCESS_SECRET.Value = txtOAUTH_VERIFIER.Value;
						// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
						SqlProcs.spOAUTH_TOKENS_Update(Security.USER_ID, this.SourceType(), txtOAUTH_ACCESS_TOKEN.Value, txtOAUTH_VERIFIER.Value, DateTime.MinValue, String.Empty);
						btnSignIn.Visible  = false;
						btnConnect.Visible = !btnSignIn.Visible;
						btnSignOut.Visible = !btnSignIn.Visible;
					}
				}
				else if ( e.CommandName == "Import.Connect" )
				{
					bool bImportSuccessful = false;
					if ( this.SourceType() == "LinkedIn" )
					{
						string sLinkedInApiKey    = Sql.ToString(Application["CONFIG.LinkedIn.APIKey"   ]);
						string sLinkedInApiSecret = Sql.ToString(Application["CONFIG.LinkedIn.SecretKey"]);
						Spring.Social.LinkedIn.Connect.LinkedInServiceProvider linkedInServiceProvider = new Spring.Social.LinkedIn.Connect.LinkedInServiceProvider(sLinkedInApiKey, sLinkedInApiSecret);
						Spring.Social.OAuth1.OAuthToken oauthToken = new Spring.Social.OAuth1.OAuthToken(txtOAUTH_TOKEN.Value, txtOAUTH_SECRET.Value);
						
						// 04/08/2012 Paul.  First try and load an existing access token. 
						bool bNewAccessToken = false;
						if ( Sql.IsEmptyString(txtOAUTH_ACCESS_TOKEN.Value) )
						{
							GetOAuthAccessTokens();
						}
						if ( Sql.IsEmptyString(txtOAUTH_ACCESS_TOKEN.Value) )
						{
							Spring.Social.OAuth1.AuthorizedRequestToken requestToken = new Spring.Social.OAuth1.AuthorizedRequestToken(oauthToken, txtOAUTH_VERIFIER.Value);
							// 10/21/2013 Paul.  We must use the Async call when Spring.NET is compiled using .NET 4.0. 
							Spring.Social.OAuth1.OAuthToken oauthAccessToken = linkedInServiceProvider.OAuthOperations.ExchangeForAccessTokenAsync(requestToken, null).Result;
							txtOAUTH_ACCESS_TOKEN .Value = oauthAccessToken.Value ;
							txtOAUTH_ACCESS_SECRET.Value = oauthAccessToken.Secret;
							// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
							SqlProcs.spOAUTH_TOKENS_Update(Security.USER_ID, this.SourceType(), oauthAccessToken.Value, oauthAccessToken.Secret, DateTime.MinValue, String.Empty);
							bNewAccessToken = true;
						}
						
						// https://developer.linkedin.com/documents/profile-fields
						// https://developer.linkedin.com/documents/linkedin-api-resource-map
						// https://developer.linkedin.com/documents/connections-api
						//string sLinkedInConnectionsURL = "https://api.linkedin.com/v1/people/~/connections:(id,first-name,last-name,industry,location,phone-numbers,main-address,positions)";
						string sLinkedInConnectionsURL = "people/~/connections:(id,first-name,last-name,industry,location,phone-numbers,main-address,positions)?format=json";
						Spring.Social.LinkedIn.Api.ILinkedIn linkedIn = null;
						Spring.Social.LinkedIn.Api.LinkedInFullProfiles connections = null;
						try
						{
							linkedIn = linkedInServiceProvider.GetApi(txtOAUTH_ACCESS_TOKEN.Value, txtOAUTH_ACCESS_SECRET.Value);
							connections = linkedIn.RestOperations.GetForObject<Spring.Social.LinkedIn.Api.LinkedInFullProfiles>(sLinkedInConnectionsURL);
						}
						catch(Exception ex)
						{
							if ( ex.Message == "The remote server returned an error: (400) Bad Request." )
								throw;
							SqlProcs.spOAUTH_TOKENS_Delete(Security.USER_ID, this.SourceType());
							// 04/08/2012 Paul.  The access token may have expired, so if the first request fails, then try again using an updated token. 
							if ( !bNewAccessToken )
							{
								try
								{
									Spring.Social.OAuth1.AuthorizedRequestToken requestToken = new Spring.Social.OAuth1.AuthorizedRequestToken(oauthToken, txtOAUTH_VERIFIER.Value);
									// 10/21/2013 Paul.  We must use the Async call when Spring.NET is compiled using .NET 4.0. 
									Spring.Social.OAuth1.OAuthToken oauthAccessToken = linkedInServiceProvider.OAuthOperations.ExchangeForAccessTokenAsync(requestToken, null).Result;
									txtOAUTH_ACCESS_TOKEN .Value = oauthAccessToken.Value ;
									txtOAUTH_ACCESS_SECRET.Value = oauthAccessToken.Secret;
									// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
									SqlProcs.spOAUTH_TOKENS_Update(Security.USER_ID, this.SourceType(), oauthAccessToken.Value, oauthAccessToken.Secret, DateTime.MinValue, String.Empty);
									bNewAccessToken = true;
								}
								catch(Exception ex1)
								{
									SqlProcs.spOAUTHKEYS_Delete(Security.USER_ID, this.SourceType());
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex1);
									btnSignIn.Visible  = true;
									btnConnect.Visible = !btnSignIn.Visible;
									btnSignOut.Visible = !btnSignIn.Visible;
									txtOAUTH_TOKEN        .Value = String.Empty;
									txtOAUTH_SECRET       .Value = String.Empty;
									txtOAUTH_VERIFIER     .Value = String.Empty;
									txtOAUTH_REALMID      .Value = String.Empty;
									// 04/23/2015 Paul.  HubSpot has more data. 
									txtOAUTH_REFRESH_TOKEN.Value = String.Empty;
									txtOAUTH_EXPIRES_IN   .Value = String.Empty;
									txtOAUTH_ACCESS_TOKEN .Value = String.Empty;
									txtOAUTH_ACCESS_SECRET.Value = String.Empty;
									// 05/17/2017 Paul.  Throw outer exception, not this inner one. 
									throw(new Exception(ex.Message, ex));
								}
								linkedIn = linkedInServiceProvider.GetApi(txtOAUTH_ACCESS_TOKEN.Value, txtOAUTH_ACCESS_SECRET.Value);
								connections = linkedIn.RestOperations.GetForObject<Spring.Social.LinkedIn.Api.LinkedInFullProfiles>(sLinkedInConnectionsURL);
							}
							else
							{
								SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							}
						}
						if ( connections != null )
						{
							bool bShortStateName   = Sql.ToBoolean(Application["CONFIG.GoogleMaps.ShortStateName"  ]);
							bool bShortCountryName = Sql.ToBoolean(Application["CONFIG.GoogleMaps.ShortCountryName"]);
							// 04/08/2012 Paul.  Must force the use of the header to allow automatic mapping of fields. 
							chkHasHeader.Checked = true;
							//DataTable dtLinkedInConnections = LinkedInImport.ConvertXmlToTable(sResponseXML, bShortStateName, bShortCountryName);
							DataTable dtLinkedInConnections = SocialImport.CreateTable(connections, bShortStateName, bShortCountryName);
							xml = SplendidImport.ConvertTableToXml(dtLinkedInConnections, sImportModule.ToLower(), chkHasHeader.Checked, false, null);
							bImportSuccessful = true;
						}
					}
					else if ( this.SourceType() == "Twitter" )
					{
						string sTwitterConsumerKey    = Sql.ToString(Application["CONFIG.Twitter.ConsumerKey"   ]);
						string sTwitterConsumerSecret = Sql.ToString(Application["CONFIG.Twitter.ConsumerSecret"]);
						Spring.Social.Twitter.Connect.TwitterServiceProvider twitterServiceProvider = new Spring.Social.Twitter.Connect.TwitterServiceProvider(sTwitterConsumerKey, sTwitterConsumerSecret);
						Spring.Social.OAuth1.OAuthToken oauthToken = new Spring.Social.OAuth1.OAuthToken(txtOAUTH_TOKEN.Value, txtOAUTH_SECRET.Value);
						
						// 04/08/2012 Paul.  First try and load an existing access token. 
						bool bNewAccessToken = false;
						if ( Sql.IsEmptyString(txtOAUTH_ACCESS_TOKEN.Value) )
						{
							GetOAuthAccessTokens();
						}
						if ( Sql.IsEmptyString(txtOAUTH_ACCESS_TOKEN.Value) )
						{
							Spring.Social.OAuth1.AuthorizedRequestToken requestToken = new Spring.Social.OAuth1.AuthorizedRequestToken(oauthToken, txtOAUTH_VERIFIER.Value);
							// 10/21/2013 Paul.  We must use the Async call when Spring.NET is compiled using .NET 4.0. 
							Spring.Social.OAuth1.OAuthToken oauthAccessToken = twitterServiceProvider.OAuthOperations.ExchangeForAccessTokenAsync(requestToken, null).Result;
							txtOAUTH_ACCESS_TOKEN .Value = oauthAccessToken.Value ;
							txtOAUTH_ACCESS_SECRET.Value = oauthAccessToken.Secret;
							// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
							SqlProcs.spOAUTH_TOKENS_Update(Security.USER_ID, this.SourceType(), oauthAccessToken.Value, oauthAccessToken.Secret, DateTime.MinValue, String.Empty);
							bNewAccessToken = true;
						}
						
						Spring.Social.Twitter.Api.CursoredList<Spring.Social.Twitter.Api.TwitterProfile> followers = null;
						try
						{
							Spring.Social.Twitter.Api.ITwitter twitter = twitterServiceProvider.GetApi(txtOAUTH_ACCESS_TOKEN.Value, txtOAUTH_ACCESS_SECRET.Value);
							// 10/21/2013 Paul.  We must use the Async call when Spring.NET is compiled using .NET 4.0. 
							followers = twitter.FriendOperations.GetFollowersAsync().Result;
						}
						catch(Exception ex)
						{
							if ( ex.Message == "The remote server returned an error: (400) Bad Request." )
								throw;
							SqlProcs.spOAUTH_TOKENS_Delete(Security.USER_ID, this.SourceType());
							// 04/08/2012 Paul.  The access token may have expired, so if the first request fails, then try again using an updated token. 
							if ( !bNewAccessToken )
							{
								try
								{
									Spring.Social.OAuth1.AuthorizedRequestToken requestToken = new Spring.Social.OAuth1.AuthorizedRequestToken(oauthToken, txtOAUTH_VERIFIER.Value);
									// 10/21/2013 Paul.  We must use the Async call when Spring.NET is compiled using .NET 4.0. 
									Spring.Social.OAuth1.OAuthToken oauthAccessToken = twitterServiceProvider.OAuthOperations.ExchangeForAccessTokenAsync(requestToken, null).Result;
									txtOAUTH_ACCESS_TOKEN .Value = oauthAccessToken.Value ;
									txtOAUTH_ACCESS_SECRET.Value = oauthAccessToken.Secret;
									// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
									SqlProcs.spOAUTH_TOKENS_Update(Security.USER_ID, this.SourceType(), oauthAccessToken.Value, oauthAccessToken.Secret, DateTime.MinValue, String.Empty);
									bNewAccessToken = true;
								}
								catch(Exception ex1)
								{
									SqlProcs.spOAUTHKEYS_Delete(Security.USER_ID, this.SourceType());
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex1);
									btnSignIn.Visible  = true;
									btnConnect.Visible = !btnSignIn.Visible;
									btnSignOut.Visible = !btnSignIn.Visible;
									txtOAUTH_TOKEN        .Value = String.Empty;
									txtOAUTH_SECRET       .Value = String.Empty;
									txtOAUTH_VERIFIER     .Value = String.Empty;
									txtOAUTH_REALMID      .Value = String.Empty;
									// 04/23/2015 Paul.  HubSpot has more data. 
									txtOAUTH_REFRESH_TOKEN.Value = String.Empty;
									txtOAUTH_EXPIRES_IN   .Value = String.Empty;
									txtOAUTH_ACCESS_TOKEN .Value = String.Empty;
									txtOAUTH_ACCESS_SECRET.Value = String.Empty;
									throw;
								}
								Spring.Social.Twitter.Api.ITwitter twitter = twitterServiceProvider.GetApi(txtOAUTH_ACCESS_TOKEN.Value, txtOAUTH_ACCESS_SECRET.Value);
								// 10/21/2013 Paul.  We must use the Async call when Spring.NET is compiled using .NET 4.0. 
								followers = twitter.FriendOperations.GetFollowersAsync().Result;
							}
							else
							{
								SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							}
						}
						if ( followers != null )
						{
							bool bShortStateName   = Sql.ToBoolean(Application["CONFIG.GoogleMaps.ShortStateName"  ]);
							bool bShortCountryName = Sql.ToBoolean(Application["CONFIG.GoogleMaps.ShortCountryName"]);
							// 04/08/2012 Paul.  Must force the use of the header to allow automatic mapping of fields. 
							chkHasHeader.Checked = true;
							DataTable dtTwitterConnections = SocialImport.CreateTable(followers, bShortStateName, bShortCountryName);
							xml = SplendidImport.ConvertTableToXml(dtTwitterConnections, sImportModule.ToLower(), chkHasHeader.Checked, false, null);
							bImportSuccessful = true;
						}
					}
					else if ( this.SourceType() == "Facebook" )
					{
						string sFacebookAppID     = Sql.ToString(Application["CONFIG.facebook.AppID"    ]);
						string sFacebookAppSecret = Sql.ToString(Application["CONFIG.facebook.AppSecret"]);
						Spring.Social.Facebook.Connect.FacebookServiceProvider facebookServiceProvider = new Spring.Social.Facebook.Connect.FacebookServiceProvider(sFacebookAppID, sFacebookAppSecret);
						
						if ( Sql.IsEmptyString(txtOAUTH_ACCESS_TOKEN.Value) )
						{
							GetOAuthAccessTokens();
						}
						
						List<Spring.Social.Facebook.Api.FacebookProfile> followers = new List<Spring.Social.Facebook.Api.FacebookProfile>();
						try
						{
							StringCollection uniqueFollowers = new StringCollection();
							// 04/13/2012 Paul.  Get friends and subscribers. 
							Spring.Social.Facebook.Api.IFacebook facebook = facebookServiceProvider.GetApi(txtOAUTH_ACCESS_TOKEN.Value);
							// 04/14/2012 Paul.  We cannot do a bunch of queries as facebook will invalidate the access token.  Use FQL to get all the data in one query. 
							string fql = "SELECT uid, username, name, first_name, last_name, email, contact_email, website, birthday_date, hometown_location, about_me FROM user WHERE uid IN (SELECT uid2 FROM friend WHERE uid1 = me())";
							followers = facebook.FqlOperations.QueryFQL<List<Spring.Social.Facebook.Api.FacebookProfile>>(fql);
							/*
							List<Spring.Social.Facebook.Api.Reference> friends = facebook.FriendOperations.GetFriends();
							foreach ( Spring.Social.Facebook.Api.Reference friend in friends )
							{
								if ( !uniqueFollowers.Contains(friend.ID) )
								{
									Spring.Social.Facebook.Api.FacebookProfile follower = facebook.UserOperations.GetUserProfile(friend.ID);
									followers.Add(follower);
									uniqueFollowers.Add(friend.ID);
								}
							}
							List<Spring.Social.Facebook.Api.Reference> subscribers = facebook.FriendOperations.GetSubscribers();
							foreach ( Spring.Social.Facebook.Api.Reference subscriber in subscribers )
							{
								if ( !uniqueFollowers.Contains(subscriber.ID) )
								{
									Spring.Social.Facebook.Api.FacebookProfile follower = facebook.UserOperations.GetUserProfile(subscriber.ID);
									followers.Add(follower);
									uniqueFollowers.Add(subscriber.ID);
								}
							}
							*/
						}
						catch(Exception ex)
						{
							//SqlProcs.spOAUTHKEYS_Delete(Security.USER_ID, this.SourceType());
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							//btnSignIn.Visible  = true;
							//btnConnect.Visible = !btnSignIn.Visible;
							//btnSignOut.Visible = !btnSignIn.Visible;
							//txtOAUTH_TOKEN        .Value = String.Empty;
							//txtOAUTH_SECRET       .Value = String.Empty;
							//txtOAUTH_VERIFIER     .Value = String.Empty;
							//txtOAUTH_REALMID      .Value = String.Empty;
							//txtOAUTH_ACCESS_TOKEN .Value = String.Empty;
							//txtOAUTH_ACCESS_SECRET.Value = String.Empty;
							throw;
						}
						if ( followers != null )
						{
							bool bShortStateName   = Sql.ToBoolean(Application["CONFIG.GoogleMaps.ShortStateName"  ]);
							bool bShortCountryName = Sql.ToBoolean(Application["CONFIG.GoogleMaps.ShortCountryName"]);
							// 04/08/2012 Paul.  Must force the use of the header to allow automatic mapping of fields. 
							chkHasHeader.Checked = true;
							DataTable dtFacebookConnections = SocialImport.CreateTable(followers, bShortStateName, bShortCountryName);
							xml = SplendidImport.ConvertTableToXml(dtFacebookConnections, sImportModule.ToLower(), chkHasHeader.Checked, false, null);
							bImportSuccessful = true;
						}
					}
					// 04/23/2015 Paul.  HubSpot uses OAuth2, similar to Facebook. 
					else if ( this.SourceType() == "HubSpot" )
					{
						string sHubSpotClientID     = Sql.ToString(Application["CONFIG.HubSpot.ClientID"    ]);
						string sHubSpotClientSecret = Sql.ToString(Application["CONFIG.HubSpot.ClientSecret"]);
						Spring.Social.HubSpot.Connect.HubSpotServiceProvider hubSpotServiceProvider = new Spring.Social.HubSpot.Connect.HubSpotServiceProvider(sHubSpotClientID, sHubSpotClientSecret);
						
						if ( Sql.IsEmptyString(txtOAUTH_ACCESS_TOKEN.Value) )
						{
							GetOAuthAccessTokens();
						}
						
						IList<Spring.Social.HubSpot.Api.Contact> contacts = new List<Spring.Social.HubSpot.Api.Contact>();
						try
						{
							// 04/13/2012 Paul.  Get friends and subscribers. 
							Spring.Social.HubSpot.Api.IHubSpot hubSpot = hubSpotServiceProvider.GetApi(txtOAUTH_ACCESS_TOKEN.Value);
							contacts = hubSpot.ContactOperations.GetAll(String.Empty);
						}
						catch(Exception ex)
						{
							//SqlProcs.spOAUTHKEYS_Delete(Security.USER_ID, this.SourceType());
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							//btnSignIn.Visible  = true;
							//btnConnect.Visible = !btnSignIn.Visible;
							//btnSignOut.Visible = !btnSignIn.Visible;
							//txtOAUTH_TOKEN        .Value = String.Empty;
							//txtOAUTH_SECRET       .Value = String.Empty;
							//txtOAUTH_VERIFIER     .Value = String.Empty;
							//txtOAUTH_REALMID      .Value = String.Empty;
							//txtOAUTH_ACCESS_TOKEN .Value = String.Empty;
							//txtOAUTH_ACCESS_SECRET.Value = String.Empty;
							throw;
						}
						if ( contacts != null )
						{
							chkHasHeader.Checked = true;
							DataTable dtHubSpotConnections = SocialImport.CreateTable(contacts);
							xml = SplendidImport.ConvertTableToXml(dtHubSpotConnections, sImportModule.ToLower(), chkHasHeader.Checked, false, null);
							bImportSuccessful = true;
						}
					}
					else if ( this.SourceType() == "salesforce" )
					{
						string sSalesforceConsumerKey    = Sql.ToString(Application["CONFIG.Salesforce.ConsumerKey"   ]);
						string sSalesforceConsumerSecret = Sql.ToString(Application["CONFIG.Salesforce.ConsumerSecret"]);
						Spring.Social.Salesforce.Connect.SalesforceServiceProvider salesforceServiceProvider = new Spring.Social.Salesforce.Connect.SalesforceServiceProvider(sSalesforceConsumerKey, sSalesforceConsumerSecret);
						
						if ( Sql.IsEmptyString(txtOAUTH_ACCESS_TOKEN.Value) )
						{
							GetOAuthAccessTokens();
						}
						
						Spring.Social.Salesforce.Api.DescribeSObject metadata = null;
						Spring.Social.Salesforce.Api.QueryResult     result   = null;
						try
						{
							// 04/22/2012 Paul.  Hardcode the version as this is what the code was developed against. 
							string sSalesforceVersion   = Sql.ToString(Application["CONFIG.Salesforce.Version"]);
							string sSalesforceTableName = Crm.Modules.SingularModuleName(sImportModule);
							if ( Sql.IsEmptyString(sSalesforceVersion) )
								sSalesforceVersion = "24.0";
							
							// 04/22/2012 Paul.  The first parameter is the Instance URL and the second parameter is the access token .
							// We are going to store the instance in the secret field. 
							Spring.Social.Salesforce.Api.ISalesforce salesforce = salesforceServiceProvider.GetApi(txtOAUTH_ACCESS_SECRET.Value, txtOAUTH_ACCESS_TOKEN.Value);
							metadata = salesforce.MetadataOperations.DescribeSObject(sSalesforceVersion, sSalesforceTableName);
							List<string> arrFields = new List<string>();
							for ( int i = 0; i < metadata.Fields.Count; i++ )
							{
								Spring.Social.Salesforce.Api.Field field = metadata.Fields[i];
								if ( field.SoapType != Spring.Social.Salesforce.Api.Field.enumSoapType.xsdbase64Binary && field.SoapType != Spring.Social.Salesforce.Api.Field.enumSoapType.xsdanyType )
									arrFields.Add(field.Name);
							}
							string sQuery = "select " + String.Join(",", arrFields.ToArray()) + " from " + sSalesforceTableName;
							result = salesforce.SearchOperations.QueryAll(sSalesforceVersion, sQuery);
						}
						catch(Exception ex)
						{
							//SqlProcs.spOAUTHKEYS_Delete(Security.USER_ID, this.SourceType());
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							//btnSignIn.Visible  = true;
							//btnConnect.Visible = !btnSignIn.Visible;
							//btnSignOut.Visible = !btnSignIn.Visible;
							//txtOAUTH_TOKEN        .Value = String.Empty;
							//txtOAUTH_SECRET       .Value = String.Empty;
							//txtOAUTH_VERIFIER     .Value = String.Empty;
							//txtOAUTH_REALMID      .Value = String.Empty;
							//txtOAUTH_ACCESS_TOKEN .Value = String.Empty;
							//txtOAUTH_ACCESS_SECRET.Value = String.Empty;
							throw;
						}
						if ( metadata != null && result != null )
						{
							chkHasHeader.Checked = true;
							DataTable dtSalesforceData = SocialImport.CreateTable(metadata, result);
							xml = SplendidImport.ConvertTableToXml(dtSalesforceData, sImportModule.ToLower(), chkHasHeader.Checked, false, null);
							bImportSuccessful = true;
						}
					}
					else if ( this.SourceType() == "QuickBooks" )
					{
						DataTable dtResults = new DataTable();
						try
						{
							string sQuickBooksTableName = "Customers";
							switch ( sImportModule )
							{
								case "Accounts"        :  sQuickBooksTableName = "Customers"     ;  break;
								case "Contacts"        :  sQuickBooksTableName = "Customers"     ;  break;
								case "ProductTemplates":  sQuickBooksTableName = "Items"         ;  break;
								case "Shippers"        :  sQuickBooksTableName = "ShippingMethod";  break;
								case "Quotes"          :  sQuickBooksTableName = "Estimates"     ;  break;
								case "Orders"          :  sQuickBooksTableName = "SalesOrder"    ;  break;
								case "Invoices"        :  sQuickBooksTableName = "Invoice"       ;  break;
							}
							// 02/06/2014 Paul.  New QuickBooks factory to allow Remote and Online. 
							QuickBooksClientFactory qbf = QuickBooksSync.CreateFactory(Application);
							using ( IDbConnection con = qbf.CreateConnection() )
							{
								con.Open();
								string sSQL;
								sSQL = "select * from " + sQuickBooksTableName + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									using ( DbDataAdapter da = qbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										da.Fill(dtResults);
										// 05/28/2012 Paul.  We don't want the QuickBooks ID to be automatically mapped as it will generate an error. 
										DataColumn dcID = dtResults.Columns["ID"];
										if ( dcID != null )
										{
											dcID.ColumnName = "QID";
										}
									}
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							throw;
						}
						if ( dtResults != null )
						{
							chkHasHeader.Checked = true;
							xml = SplendidImport.ConvertTableToXml(dtResults, sImportModule.ToLower(), chkHasHeader.Checked, false, null);
							bImportSuccessful = true;
						}
					}
					// 06/03/2014 Paul.  QuickBooks Online is going to use a different API than standard QuickBooks. 
					else if ( this.SourceType() == "QuickBooksOnline" )
					{
						DataTable dtResults = null;
						try
						{
							string sQuickBooksTableName = "Customers";
							switch ( sImportModule )
							{
								case "Accounts"        :  sQuickBooksTableName = "Accounts"      ;  break;
								case "Contacts"        :  sQuickBooksTableName = "Customers"     ;  break;
								case "ProductTemplates":  sQuickBooksTableName = "Items"         ;  break;
								case "Shippers"        :  sQuickBooksTableName = "ShippingMethod";  break;
								case "Invoices"        :  sQuickBooksTableName = "Invoice"       ;  break;
							}
							string sQuickBooksApiKey    = Sql.ToString(Application["CONFIG.QuickBooks.OAuthClientID"    ]);
							string sQuickBooksApiSecret = Sql.ToString(Application["CONFIG.QuickBooks.OAuthClientSecret"]);
							Spring.Social.QuickBooks.Connect.QuickBooksServiceProvider quickBooksServiceProvider = new Spring.Social.QuickBooks.Connect.QuickBooksServiceProvider(sQuickBooksApiKey, sQuickBooksApiSecret);
							Spring.Social.OAuth1.OAuthToken oauthToken = new Spring.Social.OAuth1.OAuthToken(txtOAUTH_TOKEN.Value, txtOAUTH_SECRET.Value);
						
							// 04/08/2012 Paul.  First try and load an existing access token. 
							bool bNewAccessToken = false;
							if ( Sql.IsEmptyString(txtOAUTH_ACCESS_TOKEN.Value) )
							{
								GetOAuthAccessTokens();
							}
							if ( Sql.IsEmptyString(txtOAUTH_ACCESS_TOKEN.Value) )
							{
								Spring.Social.OAuth1.AuthorizedRequestToken requestToken = new Spring.Social.OAuth1.AuthorizedRequestToken(oauthToken, txtOAUTH_VERIFIER.Value);
								// 10/21/2013 Paul.  We must use the Async call when Spring.NET is compiled using .NET 4.0. 
								Spring.Social.OAuth1.OAuthToken oauthAccessToken = quickBooksServiceProvider.OAuthOperations.ExchangeForAccessTokenAsync(requestToken, null).Result;
								txtOAUTH_ACCESS_TOKEN .Value = oauthAccessToken.Value ;
								txtOAUTH_ACCESS_SECRET.Value = oauthAccessToken.Secret;
								// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
								SqlProcs.spOAUTH_TOKENS_Update(Security.USER_ID, this.SourceType(), oauthAccessToken.Value, oauthAccessToken.Secret, DateTime.MinValue, String.Empty);
								bNewAccessToken = true;
							}
							string sCompanyID = txtOAUTH_REALMID.Value;
							if ( Sql.IsEmptyString(sCompanyID) )
								sCompanyID = Sql.ToString(Application["CONFIG.QuickBooks.OAuthCompanyID"]);
							
							Spring.Social.QuickBooks.Api.IQuickBooks quickBooks = null;
							try
							{
								// https://developer.intuit.com/apiexplorer?apiname=V3QBO#Account
								quickBooks = quickBooksServiceProvider.GetApi(txtOAUTH_ACCESS_TOKEN.Value, txtOAUTH_ACCESS_SECRET.Value, sCompanyID);
								if ( sQuickBooksTableName == "Accounts" )
								{
									dtResults = Spring.Social.QuickBooks.Api.Account.ConvertToTable(quickBooks.AccountOperations.GetAll(String.Empty, String.Empty));
								}
								else if ( sQuickBooksTableName == "Customers" )
								{
									dtResults = Spring.Social.QuickBooks.Api.Customer.ConvertToTable(quickBooks.CustomerOperations.GetAll(String.Empty, String.Empty));
								}
							}
							catch(Exception ex)
							{
								if ( ex.Message == "The remote server returned an error: (400) Bad Request." )
									throw;
								SqlProcs.spOAUTH_TOKENS_Delete(Security.USER_ID, this.SourceType());
								if ( !bNewAccessToken )
								{
									try
									{
										Spring.Social.OAuth1.AuthorizedRequestToken requestToken = new Spring.Social.OAuth1.AuthorizedRequestToken(oauthToken, txtOAUTH_VERIFIER.Value);
										Spring.Social.OAuth1.OAuthToken oauthAccessToken = quickBooksServiceProvider.OAuthOperations.ExchangeForAccessTokenAsync(requestToken, null).Result;
										txtOAUTH_ACCESS_TOKEN .Value = oauthAccessToken.Value ;
										txtOAUTH_ACCESS_SECRET.Value = oauthAccessToken.Secret;
										// 09/05/2015 Paul.  Google now uses OAuth 2.0. 
										SqlProcs.spOAUTH_TOKENS_Update(Security.USER_ID, this.SourceType(), oauthAccessToken.Value, oauthAccessToken.Secret, DateTime.MinValue, String.Empty);
										bNewAccessToken = true;
									}
									catch(Exception ex1)
									{
										SqlProcs.spOAUTHKEYS_Delete(Security.USER_ID, this.SourceType());
										SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex1);
										btnSignIn.Visible  = true;
										btnConnect.Visible = !btnSignIn.Visible;
										btnSignOut.Visible = !btnSignIn.Visible;
										txtOAUTH_TOKEN        .Value = String.Empty;
										txtOAUTH_SECRET       .Value = String.Empty;
										txtOAUTH_VERIFIER     .Value = String.Empty;
										txtOAUTH_REALMID      .Value = String.Empty;
										// 04/23/2015 Paul.  HubSpot has more data. 
										txtOAUTH_REFRESH_TOKEN.Value = String.Empty;
										txtOAUTH_EXPIRES_IN   .Value = String.Empty;
										txtOAUTH_ACCESS_TOKEN .Value = String.Empty;
										txtOAUTH_ACCESS_SECRET.Value = String.Empty;
										throw;
									}
									quickBooks = quickBooksServiceProvider.GetApi(txtOAUTH_ACCESS_TOKEN.Value, txtOAUTH_ACCESS_SECRET.Value);
									if ( sQuickBooksTableName == "Accounts" )
									{
										dtResults = Spring.Social.QuickBooks.Api.Account.ConvertToTable(quickBooks.AccountOperations.GetAll(String.Empty, String.Empty));
									}
									else if ( sQuickBooksTableName == "Customers" )
									{
										dtResults = Spring.Social.QuickBooks.Api.Customer.ConvertToTable(quickBooks.CustomerOperations.GetAll(String.Empty, String.Empty));
									}
								}
								else
								{
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							throw;
						}
						if ( dtResults != null )
						{
							chkHasHeader.Checked = true;
							xml = SplendidImport.ConvertTableToXml(dtResults, sImportModule.ToLower(), chkHasHeader.Checked, false, null);
							bImportSuccessful = true;
						}
					}
					if ( bImportSuccessful )
					{
						if ( xml.DocumentElement == null )
							throw(new Exception(L10n.Term("Import.LBL_NOTHING")));
						
						XmlNodeList nlRows = xml.DocumentElement.SelectNodes(sImportModule.ToLower());
						// 05/23/2020 Paul.  Try non-lower case. 
						if ( nlRows.Count == 0 )
							nlRows = xml.DocumentElement.SelectNodes(sImportModule);
						if ( nlRows.Count == 0 )
							throw(new Exception(L10n.Term("Import.LBL_NOTHING")));
						
						string sTempFileID   = Guid.NewGuid().ToString();
						string sTempFileName = Security.USER_ID.ToString() + " " + Guid.NewGuid().ToString() + " " + this.SourceType() + ".xml";
						xml.Save(Path.Combine(Path.GetTempPath(), sTempFileName));
						Session["TempFile." + sTempFileID] = Path.Combine(Path.GetTempPath(), sTempFileName);
						ViewState["TempFileID"] = sTempFileID;
						
						XmlDocument xmlSample = new XmlDocument();
						xmlSample.AppendChild(xmlSample.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
						xmlSample.AppendChild(xmlSample.CreateElement("xml"));
						for ( int i = 0; i < nlRows.Count && i < 3 ; i++ )
						{
							XmlNode node = nlRows[i];
							xmlSample.DocumentElement.AppendChild(xmlSample.ImportNode(node, true));
						}
						xml = null;
						nlRows = null;
						xml = xmlSample;
						GC.Collect();
						Session[sImportModule + ".xmlSample." + this.SourceType()] = xml.OuterXml;
						ViewState["xmlSample"] = sImportModule + ".xmlSample." + this.SourceType();
						
						bool bUpdateMapping = (Request["ID"] == null);
						UpdateImportMappings(xml, bUpdateMapping, bUpdateMapping);
						txtACTIVE_TAB.Value = "4";
					}
					else
					{
						ctlDynamicButtons.ErrorText = "Failed to get a response from " + this.SourceType();
					}
				}
				// 09/17/2013 Paul.  Add Business Rules to import. 
				else if ( e.CommandName == "Rules.Cancel" )
				{
					ResetRuleText();
				}
				else if ( e.CommandName == "Rules.Add" )
				{
					ResetRuleText();
				}
				else if ( e.CommandName == "Rules.Delete" )
				{
					RulesDelete(Sql.ToGuid(e.CommandArgument));
					ResetRuleText();
				}
				else if ( e.CommandName == "Rules.Edit" )
				{
					Guid   gRULE_ID = Sql.ToGuid(e.CommandArgument);
					string sRULE_NAME    = String.Empty;
					int    nPRIORITY     = 0           ;
					string sREEVALUATION = String.Empty;
					bool   bACTIVE       = true        ;
					string sCONDITION    = String.Empty;
					string sTHEN_ACTIONS = String.Empty;
					string sELSE_ACTIONS = String.Empty;
					RulesGet(gRULE_ID, ref sRULE_NAME, ref nPRIORITY, ref sREEVALUATION, ref bACTIVE, ref sCONDITION, ref sTHEN_ACTIONS, ref sELSE_ACTIONS);
					txtRULE_ID     .Value   = gRULE_ID.ToString() ;
					txtRULE_NAME   .Text    = sRULE_NAME          ;
					txtPRIORITY    .Text    = nPRIORITY.ToString();
					chkACTIVE      .Checked = bACTIVE             ;
					txtCONDITION   .Text    = sCONDITION          ;
					txtTHEN_ACTIONS.Text    = sTHEN_ACTIONS       ;
					txtELSE_ACTIONS.Text    = sELSE_ACTIONS       ;
					Utils.SetSelectedValue(lstREEVALUATION, sREEVALUATION);
				}
				else if ( e.CommandName == "Rules.Update" )
				{
					// 12/07/2010 Paul.  There does not seem to be a compelling reason to have a rule name. 
					if ( Sql.IsEmptyString(txtRULE_NAME.Text) )
						txtRULE_NAME.Text = Guid.NewGuid().ToString();
					
					Guid   gRULE_ID      = Sql.ToGuid(txtRULE_ID.Value);
					string sRULE_NAME    = txtRULE_NAME   .Text   ;
					int    nPRIORITY     = Sql.ToInteger(txtPRIORITY.Text);
					string sREEVALUATION = lstREEVALUATION.SelectedValue;
					bool   bACTIVE       = chkACTIVE      .Checked;
					string sCONDITION    = txtCONDITION   .Text   ;
					string sTHEN_ACTIONS = txtTHEN_ACTIONS.Text   ;
					string sELSE_ACTIONS = txtELSE_ACTIONS.Text   ;
					
					//reqRULE_NAME   .Enabled = true;
					reqCONDITION   .Enabled = true;
					reqTHEN_ACTIONS.Enabled = true;
					reqRULE_NAME   .Validate();
					reqCONDITION   .Validate();
					reqTHEN_ACTIONS.Validate();
					if ( reqRULE_NAME.IsValid && reqCONDITION.IsValid && reqTHEN_ACTIONS.IsValid )
					{
						// 12/12/2012 Paul.  For security reasons, we want to restrict the data types available to the rules wizard. 
						SplendidRulesTypeProvider typeProvider = new SplendidRulesTypeProvider();
						RulesUtil.RulesValidate(gRULE_ID, sRULE_NAME, nPRIORITY, sREEVALUATION, bACTIVE, sCONDITION, sTHEN_ACTIONS, sELSE_ACTIONS, typeof(SplendidImportThis), typeProvider);
						RulesUpdate  (gRULE_ID, sRULE_NAME, nPRIORITY, sREEVALUATION, bACTIVE, sCONDITION, sTHEN_ACTIONS, sELSE_ACTIONS);
						ResetRuleText();
						
						// 10/23/2010 Paul.  Build the ruleset so that the entire set will get validated. 
						// 12/12/2012 Paul.  For security reasons, we want to restrict the data types available to the rules wizard. 
						RuleValidation validation = new RuleValidation(typeof(SplendidImportThis), typeProvider);
						RuleSet rules = RulesUtil.BuildRuleSet(dtRules, validation);
					}
				}
			}
			catch(Exception ex)
			{
				//SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText += ex.Message;
				return;
			}
		}

		private void InitMapping()
		{
			// 10/18/2006 Paul.  Initalize the fields. 
			XmlUtil.RemoveAllChildren(xmlMapping, "Fields");
			XmlNode xFields = xmlMapping.DocumentElement.SelectSingleNode("Fields");
			if ( xFields == null )
			{
				xFields = xmlMapping.CreateElement("Fields");
				xmlMapping.DocumentElement.AppendChild(xFields);
			}

			vwColumns.Sort = "colid";
			foreach ( DataRowView row in vwColumns )
			{
				XmlNode xField = xmlMapping.CreateElement("Field");
				xFields.AppendChild(xField);
				
				string sColumnName = Sql.ToString(row["Name"]);
				XmlUtil.SetSingleNodeAttribute(xmlMapping, xField, "Name", sColumnName);
				XmlUtil.SetSingleNode(xmlMapping, xField, "Type"   , Sql.ToString(row["ColumnType"]));
				XmlUtil.SetSingleNode(xmlMapping, xField, "Length" , Sql.ToString(row["Size"]));
				XmlUtil.SetSingleNode(xmlMapping, xField, "Default", String.Empty);
				XmlUtil.SetSingleNode(xmlMapping, xField, "Mapping", String.Empty);
				XmlUtil.SetSingleNode(xmlMapping, xField, "DuplicateFilter", "false");
			}
			// 12/17/2008 Paul.  Display the available columns. 
			ctlDuplicateFilterChooser_Bind();
		}

		private void BindSaved()
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				// 03/28/2018 Paul.  Allow global. 
				sSQL = "select *                                   " + ControlChars.CrLf
				     + "  from vwIMPORT_MAPS_List                  " + ControlChars.CrLf
				     + " where MODULE           = @MODULE          " + ControlChars.CrLf
				     + "   and (ASSIGNED_USER_ID is null or ASSIGNED_USER_ID = @ASSIGNED_USER_ID)" + ControlChars.CrLf
				     + " order by NAME                             " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@MODULE"          , sImportModule   );
					Sql.AddParameter(cmd, "@ASSIGNED_USER_ID", Security.USER_ID);

					if ( bDebug )
						RegisterClientScriptBlock("vwIMPORT_MAPS_List", Sql.ClientScriptBlock(cmd));

					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						using ( DataTable dt = new DataTable() )
						{
							da.Fill(dt);
							vwMySaved = new DataView(dt);
							grdMySaved.DataSource = vwMySaved ;
							grdMySaved.DataBind();
						}
					}
				}
			}
		}

		protected void SOURCE_TYPE_CheckedChanged(object sender, EventArgs e)
		{
			try
			{
				// 04/08/2012 Paul.  Show and hide the SignIn and Connect buttons based on the OAuth Keys. 
				btnSignIn.Visible  = true;
				btnConnect.Visible = !btnSignIn.Visible;
				btnSignOut.Visible = !btnSignIn.Visible;
				txtOAUTH_TOKEN        .Value = String.Empty;
				txtOAUTH_SECRET       .Value = String.Empty;
				txtOAUTH_VERIFIER     .Value = String.Empty;
				txtOAUTH_REALMID      .Value = String.Empty;
				// 04/23/2015 Paul.  HubSpot has more data. 
				txtOAUTH_REFRESH_TOKEN.Value = String.Empty;
				txtOAUTH_EXPIRES_IN   .Value = String.Empty;
				txtOAUTH_ACCESS_TOKEN .Value = String.Empty;
				txtOAUTH_ACCESS_SECRET.Value = String.Empty;
				// 06/03/2014 Paul.  QuickBooks Online is going to use a different API than standard QuickBooks. 
				// 04/23/2015 Paul.  HubSpot uses OAuth2, similar to Facebook. 
				if ( this.SourceType() == "LinkedIn" || this.SourceType() == "Twitter" || this.SourceType() == "Facebook" || this.SourceType() == "HubSpot" || this.SourceType() == "salesforce" || this.SourceType() == "QuickBooksOnline" )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sSQL;
						sSQL = "select *                                   " + ControlChars.CrLf
						     + "  from vwOAUTHKEYS                         " + ControlChars.CrLf
						     + " where NAME             = @NAME            " + ControlChars.CrLf
						     + "   and ASSIGNED_USER_ID = @ASSIGNED_USER_ID" + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@NAME"            , this.SourceType());
							Sql.AddParameter(cmd, "@ASSIGNED_USER_ID", Security.USER_ID);
							if ( bDebug )
								RegisterClientScriptBlock("vwOAUTHKEYS", Sql.ClientScriptBlock(cmd));

							using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
							{
								if ( rdr.Read() )
								{
									txtOAUTH_TOKEN   .Value = Sql.ToString(rdr["TOKEN"   ]);
									txtOAUTH_SECRET  .Value = Sql.ToString(rdr["SECRET"  ]);
									txtOAUTH_VERIFIER.Value = Sql.ToString(rdr["VERIFIER"]);
									txtOAUTH_REALMID .Value = String.Empty;
									btnSignIn.Visible  = false;
									btnConnect.Visible = !btnSignIn.Visible;
									btnSignOut.Visible = !btnSignIn.Visible;
								}
							}
						}
					}
				}
				else if ( this.SourceType() == "QuickBooks" )
				{
					btnSignIn.Visible  = false;
					btnConnect.Visible = !btnSignIn.Visible;
					btnSignOut.Visible = false;
					//txtACTIVE_TAB.Value = "3";
				}
				if ( btnSignIn.Visible )
				{
					string sRedirectURL = Request.Url.Scheme + "://" + Request.Url.Host + Sql.ToString(Application["rootURL"]) + "Import/OAuthLanding.aspx";
					if ( this.SourceType() == "LinkedIn" )
					{
						string sLinkedInApiKey    = Sql.ToString(Application["CONFIG.LinkedIn.APIKey"   ]);
						string sLinkedInApiSecret = Sql.ToString(Application["CONFIG.LinkedIn.SecretKey"]);
						Spring.Social.LinkedIn.Connect.LinkedInServiceProvider linkedInServiceProvider = new Spring.Social.LinkedIn.Connect.LinkedInServiceProvider(sLinkedInApiKey, sLinkedInApiSecret);
						// 10/21/2013 Paul.  We must use the Async call when Spring.NET is compiled using .NET 4.0. 
						Spring.Social.OAuth1.OAuthToken oauthToken = linkedInServiceProvider.OAuthOperations.FetchRequestTokenAsync(sRedirectURL, null).Result;
						string authenticateUrl = linkedInServiceProvider.OAuthOperations.BuildAuthorizeUrl(oauthToken.Value, null);
						txtOAUTH_TOKEN        .Value = oauthToken.Value ;
						txtOAUTH_SECRET       .Value = oauthToken.Secret;
						txtOAUTH_VERIFIER     .Value = String.Empty     ;
						txtOAUTH_REALMID      .Value = String.Empty     ;
						// 04/23/2015 Paul.  HubSpot has more data. 
						txtOAUTH_REFRESH_TOKEN.Value = String.Empty;
						txtOAUTH_EXPIRES_IN   .Value = String.Empty;
						txtOAUTH_ACCESS_TOKEN .Value = String.Empty     ;
						txtOAUTH_ACCESS_SECRET.Value = String.Empty     ;
						
						btnSignIn.OnClientClick = "window.open('" + authenticateUrl + "', '" + this.SourceType() + "Popup" + "', 'width=600,height=360,status=1,toolbar=0,location=0,resizable=1'); return false;";
					}
					else if ( this.SourceType() == "Twitter" )
					{
						// 04/08/2012 Paul.  We were getting (401) Unauthorized until we specified a valid Callback URL in the Twitter Application (http://dev.twitter.com). 
						string sTwitterConsumerKey    = Sql.ToString(Application["CONFIG.Twitter.ConsumerKey"   ]);
						string sTwitterConsumerSecret = Sql.ToString(Application["CONFIG.Twitter.ConsumerSecret"]);
						Spring.Social.Twitter.Connect.TwitterServiceProvider twitterServiceProvider = new Spring.Social.Twitter.Connect.TwitterServiceProvider(sTwitterConsumerKey, sTwitterConsumerSecret);
						// 10/21/2013 Paul.  We must use the Async call when Spring.NET is compiled using .NET 4.0. 
						Spring.Social.OAuth1.OAuthToken oauthToken = twitterServiceProvider.OAuthOperations.FetchRequestTokenAsync(sRedirectURL, null).Result;
						string authenticateUrl = twitterServiceProvider.OAuthOperations.BuildAuthorizeUrl(oauthToken.Value, null);
						txtOAUTH_TOKEN        .Value = oauthToken.Value ;
						txtOAUTH_SECRET       .Value = oauthToken.Secret;
						txtOAUTH_VERIFIER     .Value = String.Empty     ;
						txtOAUTH_REALMID      .Value = String.Empty     ;
						// 04/23/2015 Paul.  HubSpot has more data. 
						txtOAUTH_REFRESH_TOKEN.Value = String.Empty;
						txtOAUTH_EXPIRES_IN   .Value = String.Empty;
						txtOAUTH_ACCESS_TOKEN .Value = String.Empty     ;
						txtOAUTH_ACCESS_SECRET.Value = String.Empty     ;
						
						btnSignIn.OnClientClick = "window.open('" + authenticateUrl + "', '" + this.SourceType() + "Popup" + "', 'width=600,height=360,status=1,toolbar=0,location=0,resizable=1'); return false;";
					}
					else if ( this.SourceType() == "Facebook" )
					{
						string sFacebookAppID     = Sql.ToString(Application["CONFIG.facebook.AppID"    ]);
						string sFacebookAppSecret = Sql.ToString(Application["CONFIG.facebook.AppSecret"]);

						Spring.Social.Facebook.Connect.FacebookServiceProvider facebookServiceProvider = new Spring.Social.Facebook.Connect.FacebookServiceProvider(sFacebookAppID, sFacebookAppSecret);
						Spring.Social.OAuth2.OAuth2Parameters parameters = new Spring.Social.OAuth2.OAuth2Parameters()
						{
							RedirectUrl = sRedirectURL,
							// https://developers.facebook.com/docs/authentication/permissions/
							Scope = "email, user_relationships,friends_relationships, user_about_me, friends_about_me, user_birthday, friends_birthday, user_hometown, friends_hometown, user_location, friends_location, user_website, friends_website"
						};
						string authenticateUrl = facebookServiceProvider.OAuthOperations.BuildAuthorizeUrl(Spring.Social.OAuth2.GrantType.ImplicitGrant, parameters);
						txtOAUTH_TOKEN        .Value = String.Empty;
						txtOAUTH_SECRET       .Value = String.Empty;
						txtOAUTH_VERIFIER     .Value = String.Empty;
						txtOAUTH_REALMID      .Value = String.Empty;
						// 04/23/2015 Paul.  HubSpot has more data. 
						txtOAUTH_REFRESH_TOKEN.Value = String.Empty;
						txtOAUTH_EXPIRES_IN   .Value = String.Empty;
						txtOAUTH_ACCESS_TOKEN .Value = String.Empty;
						txtOAUTH_ACCESS_SECRET.Value = String.Empty;
						
						btnSignIn.OnClientClick = "window.open('" + authenticateUrl + "', '" + this.SourceType() + "Popup" + "', 'width=970,height=450,status=1,toolbar=0,location=0,resizable=1'); return false;";
					}
					// 04/23/2015 Paul.  HubSpot uses OAuth2, similar to Facebook. 
					else if ( this.SourceType() == "HubSpot" )
					{
						string sHubSpotPortalID     = Sql.ToString(Application["CONFIG.HubSpot.PortalID"    ]);
						string sHubSpotClientID     = Sql.ToString(Application["CONFIG.HubSpot.ClientID"    ]);
						string sHubSpotClientSecret = Sql.ToString(Application["CONFIG.HubSpot.ClientSecret"]);

						Spring.Social.HubSpot.Connect.HubSpotServiceProvider hubSpotServiceProvider = new Spring.Social.HubSpot.Connect.HubSpotServiceProvider(sHubSpotClientID, sHubSpotClientSecret);
						Spring.Social.OAuth2.OAuth2Parameters parameters = new Spring.Social.OAuth2.OAuth2Parameters()
						{
							RedirectUrl = sRedirectURL,
							Scope = "contacts-rw offline"
						};
						parameters.Add("portalId", sHubSpotPortalID);
						string authenticateUrl = hubSpotServiceProvider.OAuthOperations.BuildAuthorizeUrl(Spring.Social.OAuth2.GrantType.ImplicitGrant, parameters);
						txtOAUTH_TOKEN        .Value = String.Empty;
						txtOAUTH_SECRET       .Value = String.Empty;
						txtOAUTH_VERIFIER     .Value = String.Empty;
						txtOAUTH_REALMID      .Value = String.Empty;
						// 04/23/2015 Paul.  HubSpot has more data. 
						txtOAUTH_REFRESH_TOKEN.Value = String.Empty;
						txtOAUTH_EXPIRES_IN   .Value = String.Empty;
						txtOAUTH_ACCESS_TOKEN .Value = String.Empty;
						txtOAUTH_ACCESS_SECRET.Value = String.Empty;
						// http://developers.hubspot.com/docs/methods/auth/initiate-oauth
						// https://app.hubspot.com/auth/authenticate?client_id=4a9c6e70-eb7a-11e3-9f41-dd07f568fa92&portalId=62515&redirect_uri=http://hubspot.com&scope=contacts-rw+offline
						// 04/23/2015 Paul.  Responds with access_token, refresh_token, expires_in (in seconds). 
						btnSignIn.OnClientClick = "window.open('" + authenticateUrl + "', '" + this.SourceType() + "Popup" + "', 'width=830,height=830,status=1,toolbar=0,location=0,resizable=1'); return false;";
					}
					else if ( this.SourceType() == "salesforce" )
					{
						string sSalesforceConsumerKey    = Sql.ToString(Application["CONFIG.Salesforce.ConsumerKey"   ]);
						string sSalesforceConsumerSecret = Sql.ToString(Application["CONFIG.Salesforce.ConsumerSecret"]);
						Spring.Social.Salesforce.Connect.SalesforceServiceProvider salesforceServiceProvider = new Spring.Social.Salesforce.Connect.SalesforceServiceProvider(sSalesforceConsumerKey, sSalesforceConsumerSecret);
						Spring.Social.OAuth2.OAuth2Parameters parameters = new Spring.Social.OAuth2.OAuth2Parameters()
						{
							RedirectUrl = sRedirectURL
						};
						string authenticateUrl = salesforceServiceProvider.OAuthOperations.BuildAuthorizeUrl(Spring.Social.OAuth2.GrantType.ImplicitGrant, parameters);
						txtOAUTH_TOKEN        .Value = String.Empty     ;
						txtOAUTH_SECRET       .Value = String.Empty     ;
						txtOAUTH_VERIFIER     .Value = String.Empty     ;
						txtOAUTH_REALMID      .Value = String.Empty     ;
						// 04/23/2015 Paul.  HubSpot has more data. 
						txtOAUTH_REFRESH_TOKEN.Value = String.Empty;
						txtOAUTH_EXPIRES_IN   .Value = String.Empty;
						txtOAUTH_ACCESS_TOKEN .Value = String.Empty     ;
						txtOAUTH_ACCESS_SECRET.Value = String.Empty     ;
						
						// http://localhost/SplendidCRM6/Import/OAuthLanding.aspx#access_token=XXXX&refresh_token=XXXX&instance_url=https%3A%2F%2Fna14.salesforce.com&id=XXXX&issued_at=1335166141529&signature=XXXX
						btnSignIn.OnClientClick = "window.open('" + authenticateUrl + "', '" + this.SourceType() + "Popup" + "', 'width=970,height=580,status=1,toolbar=0,location=0,resizable=1'); return false;";
					}
					// 06/03/2014 Paul.  QuickBooks Online is going to use a different API than standard QuickBooks. 
					else if ( this.SourceType() == "QuickBooksOnline" )
					{
						string sQuickBooksApiKey    = Sql.ToString(Application["CONFIG.QuickBooks.OAuthClientID"    ]);
						string sQuickBooksApiSecret = Sql.ToString(Application["CONFIG.QuickBooks.OAuthClientSecret"]);
						Spring.Social.QuickBooks.Connect.QuickBooksServiceProvider quickBooksServiceProvider = new Spring.Social.QuickBooks.Connect.QuickBooksServiceProvider(sQuickBooksApiKey, sQuickBooksApiSecret);
						// 10/21/2013 Paul.  We must use the Async call when Spring.NET is compiled using .NET 4.0. 
						Spring.Social.OAuth1.OAuthToken oauthToken = quickBooksServiceProvider.OAuthOperations.FetchRequestTokenAsync(sRedirectURL, null).Result;
						string authenticateUrl = quickBooksServiceProvider.OAuthOperations.BuildAuthorizeUrl(oauthToken.Value, null);
						txtOAUTH_TOKEN        .Value = oauthToken.Value ;
						txtOAUTH_SECRET       .Value = oauthToken.Secret;
						txtOAUTH_VERIFIER     .Value = String.Empty     ;
						// 06/03/2014 Paul.  Extract the QuickBooks realmId (same as Company ID). 
						txtOAUTH_REALMID      .Value = String.Empty     ;
						// 04/23/2015 Paul.  HubSpot has more data. 
						txtOAUTH_REFRESH_TOKEN.Value = String.Empty     ;
						txtOAUTH_EXPIRES_IN   .Value = String.Empty     ;
						txtOAUTH_ACCESS_TOKEN .Value = String.Empty     ;
						txtOAUTH_ACCESS_SECRET.Value = String.Empty     ;
						
						btnSignIn.OnClientClick = "window.open('" + authenticateUrl + "', '" + this.SourceType() + "Popup" + "', 'width=600,height=800,status=1,toolbar=0,location=0,resizable=1'); return false;";
					}
				}
			}
			catch(Exception ex)
			{
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		// 04/22/2012 Paul.  Calculate a display name without spaces to get better hits with Salesforce field names. 
		private void UpdateImportColumns()
		{
			DataTable dtColumns = SplendidCache.ImportColumns(sImportModule).Copy();
			dtColumns.Columns.Add("DISPLAY_NAME_NOSPACE", Type.GetType("System.String"));
			dtColumns.Columns.Add("NAME_NOUNDERSCORE"   , Type.GetType("System.String"));
			foreach ( DataRow row in dtColumns.Rows )
			{
				string sDISPLAY_NAME = Utils.TableColumnName(L10n, sImportModule, Sql.ToString(row["DISPLAY_NAME"]));
				row["DISPLAY_NAME"        ] = sDISPLAY_NAME.Trim();
				row["DISPLAY_NAME_NOSPACE"] = sDISPLAY_NAME.Replace(" ", "");
				row["NAME_NOUNDERSCORE"   ] = Sql.ToString(row["NAME"]).Replace("_", "");
			}
			vwColumns = new DataView(dtColumns);
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			SetPageTitle(L10n.Term(sImportModule + ".LBL_MODULE_NAME"));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			// 03/17/2010 Paul.  Access rights must be in reference to the Import Module. 
			this.Visible = Security.IS_ADMIN || (SplendidCRM.Security.GetUserAccess(sImportModule, "import") >= 0);
			if ( !this.Visible )
			{
				// 03/17/2010 Paul.  We need to rebind the parent in order to get the error message to display. 
				Parent.DataBind();
				return;
			}

			xml = new XmlDocument();
			// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
			// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
			// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
			xml.XmlResolver = null;
			xmlMapping = new XmlDocument();
			xmlMapping.AppendChild(xmlMapping.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
			xmlMapping.AppendChild(xmlMapping.CreateElement("Import"));

			sbImport = new StringBuilder();
			try
			{
				// 07/02/2006 Paul.  The required fields need to be bound manually. 
				reqNAME    .DataBind();
				reqFILENAME.DataBind();
				// 12/17/2005 Paul.  Don't buffer so that the connection can be kept alive. 
				Response.BufferOutput = false;

				BindSaved();
				// 10/08/2006 Paul.  Columns table is used in multiple locations.  Make sure to load only once. 
				// 04/22/2012 Paul.  Calculate a display name without spaces to get better hits with Salesforce field names. 
				UpdateImportColumns();

				gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					radEXCEL.Checked = true;
					chkHasHeader.Checked = true;
					txtACTIVE_TAB.Value = "1";

					// 09/06/2012 Paul.  Allow direct import into prospect list. 
					// 10/22/2013 Paul.  Title was not getting set properly. 
					ViewState["ctlDynamicButtons.Title"] = L10n.Term(sImportModule + ".LBL_MODULE_NAME");
					// 10/27/2017 Paul.  Add Accounts as email source. 
					if ( sImportModule == "Contacts" || sImportModule == "Leads" || sImportModule == "Prospects" || sImportModule == "Accounts" )
					{
						Guid gPROSPECT_LIST_ID = Sql.ToGuid(Request["PROSPECT_LIST_ID"]);
						if ( !Sql.IsEmptyGuid(gPROSPECT_LIST_ID) )
						{
							try
							{
								string sPROSPECT_LIST_NAME = Crm.Modules.ItemName(Application, "ProspectLists", gPROSPECT_LIST_ID);
								ViewState["PROSPECT_LIST_ID"] = gPROSPECT_LIST_ID;
								// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
								ctlDynamicButtons.Title = String.Format(L10n.Term("Import.LBL_IMPORT_INTO"), sPROSPECT_LIST_NAME);
								ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
								SetPageTitle(ctlDynamicButtons.Title);
							}
							catch
							{
							}
						}
					}

					// 09/17/2013 Paul.  Add Business Rules to import. 
					lstREEVALUATION.DataSource = SplendidCache.List("rules_reevaluation_dom");
					lstREEVALUATION.DataBind();
					foreach ( DataGridColumn col in dgRules.Columns )
					{
						if ( !Sql.IsEmptyString(col.HeaderText) )
						{
							col.HeaderText = L10n.Term(col.HeaderText);
						}
					}
					string sMODULE_TABLE = Sql.ToString(Application["Modules." + sImportModule + ".TableName"]);
					dtRuleColumns = SplendidCache.SqlColumns("vw" + sMODULE_TABLE + "_List");
					ViewState["RULE_COLUMNS"] = dtRuleColumns;
					ctlConditionSchemaRepeater.DataSource = dtRuleColumns;
					ctlThenSchemaRepeater     .DataSource = dtRuleColumns;
					ctlElseSchemaRepeater     .DataSource = dtRuleColumns;
					ctlConditionSchemaRepeater.DataBind();
					ctlThenSchemaRepeater     .DataBind();
					ctlElseSchemaRepeater     .DataBind();

					radEXCEL            .DataBind();
					radXML_SPREADSHEET  .DataBind();
					radXML              .DataBind();
					radSALESFORCE       .DataBind();
					radACT_2005         .DataBind();
					radDBASE            .DataBind();
					radCUSTOM_CSV       .DataBind();
					radCUSTOM_TAB       .DataBind();
					radCUSTOM_DELIMITED .DataBind();
					radLINKEDIN         .DataBind();
					radTWITTER          .DataBind();
					radFACEBOOK         .DataBind();
					radQUICKBOOKS       .DataBind();
					// 06/03/2014 Paul.  QuickBooks Online is going to use a different API than standard QuickBooks. 
					radQUICKBOOKS_ONLINE.DataBind();
					// 04/23/2015 Paul.  HubSpot uses OAuth2, similar to Facebook. 
					radHUBSPOT          .DataBind();

					//radEXCEL            .Attributes.Add("onclick", "SelectSourceFormat()");
					//radXML_SPREADSHEET  .Attributes.Add("onclick", "SelectSourceFormat()");
					//radXML              .Attributes.Add("onclick", "SelectSourceFormat()");
					//radSALESFORCE       .Attributes.Add("onclick", "SelectSourceFormat()");
					//radACT_2005         .Attributes.Add("onclick", "SelectSourceFormat()");
					//radDBASE            .Attributes.Add("onclick", "SelectSourceFormat()");
					//radCUSTOM_CSV       .Attributes.Add("onclick", "SelectSourceFormat()");
					//radCUSTOM_TAB       .Attributes.Add("onclick", "SelectSourceFormat()");
					//radCUSTOM_DELIMITED .Attributes.Add("onclick", "SelectSourceFormat()");
					//radLINKEDIN         .Attributes.Add("onclick", "SelectSourceFormat()");
					//radTWITTER          .Attributes.Add("onclick", "SelectSourceFormat()");
					//radFACEBOOK         .Attributes.Add("onclick", "SelectSourceFormat()");
					//radHUBSPOT          .Attributes.Add("onclick", "SelectSourceFormat()");
					//radQUICKBOOKS       .Attributes.Add("onclick", "SelectSourceFormat()");
					//radQUICKBOOKS_ONLINE.Attributes.Add("onclick", "SelectSourceFormat()");
					ctlListHeader.Title = L10n.Term("Import.LBL_LAST_IMPORTED") + " " + L10n.Term(".moduleList.", sImportModule);

					SOURCE_TYPE_CheckedChanged(null, null);
					if ( !Sql.IsEmptyGuid(gID) )
					{
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							string sSQL;
							sSQL = "select *                 " + ControlChars.CrLf
							     + "  from vwIMPORT_MAPS_Edit" + ControlChars.CrLf
							     + " where ID = @ID          " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@ID", gID);
								con.Open();

								if ( bDebug )
									RegisterClientScriptBlock("vwIMPORT_MAPS_Edit", Sql.ClientScriptBlock(cmd));

								using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
								{
									if ( rdr.Read() )
									{
										// 03/16/2010 Paul.  The ViewState will be the primary location for the ID. 
										ViewState["ID"] = gID;
										SourceType(Sql.ToString(rdr["SOURCE"]));
										// 03/16/2010 Paul.  Update the name of the loaded import. 
										txtNAME.Text = Sql.ToString(rdr["NAME"]);
										chkHasHeader.Checked = Sql.ToBoolean(rdr["HAS_HEADER"]);
										
										string sXmlMapping = Sql.ToString (rdr["CONTENT"]);
										ViewState["xmlMapping"] = sXmlMapping;
										xmlMapping.LoadXml(sXmlMapping);
										
										// 03/16/2010 Paul.  Update the loaded default values. 
										XmlNodeList nlFields = xmlMapping.DocumentElement.SelectNodes("Fields/Field");
										foreach ( XmlNode xField in nlFields )
										{
											string sFieldName = xField.Attributes.GetNamedItem("Name").Value;
											DynamicControl ctl = new DynamicControl(ctlDefaultsView, sFieldName);
											if ( ctl.Exists )
											{
												string sDefaultValue = XmlUtil.SelectSingleNode(xField, "Default");
												ctl.Text = sDefaultValue;
											}
										}
										
										// 10/12/2006 Paul.  Extract the sample from the mapping. 
										xml = new XmlDocument();
										// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
										// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
										// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
										xml.XmlResolver = null;
										string sXmlSample = XmlUtil.SelectSingleNode(xmlMapping, "Sample");
										// 09/04/2010 Paul.  Store the sample data in the Session to prevent a huge download. 
										// We are seeing a 13M html file for an 8M import file. 
										Session[sImportModule + ".xmlSample." + gID.ToString()] = sXmlSample;
										ViewState["xmlSample"] = sImportModule + ".xmlSample." + gID.ToString();
										XmlUtil.SetSingleNode(xmlMapping, "Sample", String.Empty);
										if ( sXmlSample.Length > 0 )
											xml.LoadXml(sXmlSample);
										
										// 09/17/2013 Paul.  Add Business Rules to import. 
										dtRules = new DataTable();
										string sRULES_XML = Sql.ToString(rdr["RULES_XML"]);
										// 11/08/2013 Paul.  Make sure rules exist before trying to read XML. 
										if ( !Sql.IsEmptyString(sRULES_XML) )
										{
											using ( StringReader srdr = new StringReader(sRULES_XML) )
											{
												dtRules.ReadXml(srdr);
											}
										}
										// 06/02/2014 Paul.  If no rules were loaded, then we need to clear the rules table so that it gets initialized properly. 
										if ( dtRules.Rows.Count == 0 )
										{
											dtRules = null;
										}
										
										// 03/16/2010 Paul.  The duplicate filters should be updated inside UpdateImportMappings. 
										UpdateImportMappings(xml, false, false);
										txtACTIVE_TAB.Value = "3";
									}
								}
							}
						}
					}
					else
					{
						XmlUtil.SetSingleNodeAttribute(xmlMapping, xmlMapping.DocumentElement, "Name", String.Empty);
						XmlUtil.SetSingleNode(xmlMapping, "Module"    , sImportModule);
						XmlUtil.SetSingleNode(xmlMapping, "SourceType", SourceType() );
						XmlUtil.SetSingleNode(xmlMapping, "HasHeader" , chkHasHeader.Checked.ToString());
						InitMapping();
					}
					
					// 09/17/2013 Paul.  Add Business Rules to import. 
					if ( dtRules == null )
					{
						dtRules = new DataTable();
						DataColumn colID           = new DataColumn("ID"          , typeof(System.Guid   ));
						DataColumn colRULE_NAME    = new DataColumn("RULE_NAME"   , typeof(System.String ));
						DataColumn colPRIORITY     = new DataColumn("PRIORITY"    , typeof(System.Int32  ));
						DataColumn colREEVALUATION = new DataColumn("REEVALUATION", typeof(System.String ));
						DataColumn colACTIVE       = new DataColumn("ACTIVE"      , typeof(System.Boolean));
						DataColumn colCONDITION    = new DataColumn("CONDITION"   , typeof(System.String ));
						DataColumn colTHEN_ACTIONS = new DataColumn("THEN_ACTIONS", typeof(System.String ));
						DataColumn colELSE_ACTIONS = new DataColumn("ELSE_ACTIONS", typeof(System.String ));
						dtRules.Columns.Add(colID          );
						dtRules.Columns.Add(colRULE_NAME   );
						dtRules.Columns.Add(colPRIORITY    );
						dtRules.Columns.Add(colREEVALUATION);
						dtRules.Columns.Add(colACTIVE      );
						dtRules.Columns.Add(colCONDITION   );
						dtRules.Columns.Add(colTHEN_ACTIONS);
						dtRules.Columns.Add(colELSE_ACTIONS);
					}
					ViewState["RulesDataTable"] = dtRules;

					dgRules.DataSource = dtRules;
					dgRules.DataBind();
				}
				else
				{
					// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					SetPageTitle(ctlDynamicButtons.Title);
					string sXmlMapping = Sql.ToString(ViewState["xmlMapping"]);
					if ( sXmlMapping.Length > 0 )
						xmlMapping.LoadXml(sXmlMapping);
					
					XmlUtil.SetSingleNodeAttribute(xmlMapping, xmlMapping.DocumentElement, "Name", txtNAME.Text);
					XmlUtil.SetSingleNode(xmlMapping, "Module"    , sImportModule);
					XmlUtil.SetSingleNode(xmlMapping, "SourceType", SourceType() );
					XmlUtil.SetSingleNode(xmlMapping, "HasHeader" , chkHasHeader.Checked.ToString());
					// 12/17/2008 Paul.  Update the duplicate filter and then rebind. 
					DuplicateFilterUpdate();
					ctlDuplicateFilterChooser_Bind();

					// 10/10/2006 Paul.  This loop updates the default values. Field mappings are updated inside UpdateImportMappings(). 
					XmlNodeList nlFields = xmlMapping.DocumentElement.SelectNodes("Fields/Field");
					foreach ( XmlNode xField in nlFields )
					{
						string sFieldName = xField.Attributes.GetNamedItem("Name").Value;
						DynamicControl ctl = new DynamicControl(ctlDefaultsView, sFieldName);
						// 08/01/2010 Paul.  Fixed bug in Import.  The Exist check was failing because we were not converting TEAM_SET_LIST to TEAM_SET_NAME. 
						if ( ctl.Exists )
						{
							XmlUtil.SetSingleNode(xmlMapping, xField, "Default", ctl.Text);
						}
					}

					// 09/04/2010 Paul.  Store the sample data in the Session to prevent a huge download. 
					// We are seeing a 13M html file for an 8M import file. 
					string sXmlSample = Sql.ToString(Session[Sql.ToString(ViewState["xmlSample"])]);
					if ( sXmlSample.Length > 0 )
					{
						xml.LoadXml(sXmlSample);
						UpdateImportMappings(xml, false, true);
					}
					
					string sProcessedFileID   = Sql.ToString(ViewState["ProcessedFileID"]);
					string sProcessedFileName = Sql.ToString(Session["TempFile." + sProcessedFileID]);
					string sProcessedPathName = Path.Combine(Path.GetTempPath(), sProcessedFileName);
					if ( File.Exists(sProcessedPathName) )
					{
						DataSet dsProcessed = new DataSet();
						dsProcessed.ReadXml(sProcessedPathName);
						if ( dsProcessed.Tables.Count == 1 )
						{
							PreviewGrid(dsProcessed.Tables[0]);
						}
					}
					// 09/17/2013 Paul.  Add Business Rules to import. 
					dtRuleColumns = ViewState["RULE_COLUMNS"] as DataTable;
					dtRules = ViewState["RulesDataTable"] as DataTable;
					dgRules.DataSource = dtRules;
					dgRules.DataBind();
				}
				// 09/17/2013 Paul.  Add Business Rules to import. 
				reqRULE_NAME   .DataBind();
				reqCONDITION   .DataBind();
				reqTHEN_ACTIONS.DataBind();
			}
			catch ( Exception ex )
			{
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		private void Page_PreRender(object sender, System.EventArgs e)
		{
			// 09/17/2013 Paul.  Add Business Rules to import. 
			ViewState["RulesDataTable"] = dtRules;
			ViewState["xmlMapping"] = xmlMapping.OuterXml;
			// 09/04/2010 Paul.  Store the sample data in the Session to prevent a huge download. 
			// We are seeing a 13M html file for an 8M import file. 
			if ( Sql.ToString(ViewState["xmlSample"]).StartsWith(sImportModule) )
				Session[Sql.ToString(ViewState["xmlSample"])] = xml.OuterXml;
			//ViewState["xmlSample" ] = xml.OuterXml;
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
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
			this.PreRender += new System.EventHandler(this.Page_PreRender);
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			this.m_sMODULE = "Import";
			// 07/21/2010 Paul.  Make sure to highlight the correct menu item. 
			SetMenu(sImportModule);
			
			string sRelativePath = Sql.ToString(Application["Modules." + sImportModule + ".RelativePath"]);
			if ( Sql.IsEmptyString(sRelativePath) )
			{
				// 10/14/2014 Paul.  Correct module name. 
				if ( sImportModule == "Project" || sImportModule == "ProjectTask" )
					sImportModule += "s";
				sRelativePath = "~/" + sImportModule + "/";
			}
			// 03/31/2017 Paul.  Disabled module will not exist. 
			if ( Sql.ToBoolean(Context.Application["Modules." + sImportModule + ".Exists"]) )
				ctlDefaultsView = LoadControl(sRelativePath + "ImportDefaultsView.ascx") as SplendidControl;
			if ( ctlDefaultsView != null )
				phDefaultsView.Controls.Add(ctlDefaultsView);
			// 04/29/2008 Paul.  Make use of dynamic buttons. 
			ctlDynamicButtons.AppendButtons(m_sMODULE + ".ImportView", Guid.Empty, Guid.Empty);
			// 04/27/2018 Paul.  We need to be able to generate an error message. 
			if ( IsPostBack )
			{
				Page.Validators.Add(new RulesValidator(this));
			}
		}
		#endregion
	}
}

