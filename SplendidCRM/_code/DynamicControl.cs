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
using System.Xml;
using System.Data;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Diagnostics;
// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
using CKEditor.NET;
using SplendidCRM._controls;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for DynamicControl.
	/// </summary>
	public class DynamicControl
	{
		protected string          sNAME     ;
		protected SplendidControl ctlPARENT ;  // Use colon separator to access child items with FindControl. this.GetDynamicControl("ctlSearchView:lnkAdvancedSearch")
		protected DataRow         rowCurrent;

		// 08/01/2010 Paul.  Fixed bug in Import.  The Exist check was failing because we were not converting TEAM_SET_LIST to TEAM_SET_NAME. 
		public bool Exists
		{
			get
			{
				Control ctl = ctlPARENT.FindControl(sNAME);
				// 08/01/2010 Paul.  Allow TEAM_SET_LIST to also imply TEAM_SET_NAME. 
				if ( ctl == null && sNAME == "TEAM_SET_LIST" )
					ctl = ctlPARENT.FindControl("TEAM_SET_NAME");
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( ctl == null && sNAME == "ASSIGNED_SET_LIST" )
					ctl = ctlPARENT.FindControl("ASSIGNED_SET_NAME");
				// 05/12/2016 Paul.  Allow TAG_SET_LIST to also imply TAG_SET_NAME. 
				else if ( ctl == null && sNAME == "TAG_SET_LIST" )
					ctl = ctlPARENT.FindControl("TAG_SET_NAME");
				// 08/01/2010 Paul.  Allow KBTAG_SET_LIST to also imply KBTAG_NAME. 
				else if ( ctl == null && sNAME == "KBTAG_SET_LIST" )
					ctl = ctlPARENT.FindControl("KBTAG_NAME");
				return (ctl != null);
			}
		}

		public string Type
		{
			get
			{
				Control ctl = ctlPARENT.FindControl(sNAME);
				// 08/01/2010 Paul.  Allow TEAM_SET_LIST to also imply TEAM_SET_NAME. 
				if ( ctl == null && sNAME == "TEAM_SET_LIST" )
					ctl = ctlPARENT.FindControl("TEAM_SET_NAME");
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( ctl == null && sNAME == "ASSIGNED_SET_LIST" )
					ctl = ctlPARENT.FindControl("ASSIGNED_SET_NAME");
				// 05/12/2016 Paul.  Allow TAG_SET_LIST to also imply TAG_SET_NAME. 
				else if ( ctl == null && sNAME == "TAG_SET_LIST" )
					ctl = ctlPARENT.FindControl("TAG_SET_NAME");
				// 08/01/2010 Paul.  Allow KBTAG_SET_LIST to also imply KBTAG_NAME. 
				else if ( ctl == null && sNAME == "KBTAG_SET_LIST" )
					ctl = ctlPARENT.FindControl("KBTAG_NAME");
				if ( ctl != null )
					return ctl.GetType().Name;
				return String.Empty;
			}
		}

		public string ClientID
		{
			get
			{
				string sClientID = ctlPARENT.ID + ":" + sNAME;
				Control ctl = ctlPARENT.FindControl(sNAME);
				// 08/01/2010 Paul.  Allow TEAM_SET_LIST to also imply TEAM_SET_NAME. 
				if ( ctl == null && sNAME == "TEAM_SET_LIST" )
					ctl = ctlPARENT.FindControl("TEAM_SET_NAME");
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( ctl == null && sNAME == "ASSIGNED_SET_LIST" )
					ctl = ctlPARENT.FindControl("ASSIGNED_SET_NAME");
				// 05/12/2016 Paul.  Allow TAG_SET_LIST to also imply TAG_SET_NAME. 
				else if ( ctl == null && sNAME == "TAG_SET_LIST" )
					ctl = ctlPARENT.FindControl("TAG_SET_NAME");
				// 08/01/2010 Paul.  Allow KBTAG_SET_LIST to also imply KBTAG_NAME. 
				else if ( ctl == null && sNAME == "KBTAG_SET_LIST" )
					ctl = ctlPARENT.FindControl("KBTAG_NAME");
				if ( ctl != null )
				{
					sClientID = ctl.ClientID;
				}
				return sClientID;
			}
		}

		public string Text
		{
			get
			{
				string sVALUE = String.Empty;
				Control ctl = ctlPARENT.FindControl(sNAME);
				// 08/24/2009 Paul.  Allow TEAM_SET_LIST to also imply TEAM_SET_NAME. 
				if ( ctl == null && sNAME == "TEAM_SET_LIST" )
					ctl = ctlPARENT.FindControl("TEAM_SET_NAME");
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				// 05/06/2018 Paul.  The correct alternate is ASSIGNED_USER_ID as it is a GUID. 
				else if ( ctl == null && sNAME == "ASSIGNED_SET_LIST" )
				{
					ctl = ctlPARENT.FindControl("ASSIGNED_SET_NAME");
					if ( ctl == null )
						ctl = ctlPARENT.FindControl("ASSIGNED_USER_ID");
				}
				else if ( ctl == null && sNAME == "ASSIGNED_SET_NAME" )
					ctl = ctlPARENT.FindControl("ASSIGNED_USER_ID");
				// 05/12/2016 Paul.  Allow TAG_SET_LIST to also imply TAG_SET_NAME. 
				else if ( ctl == null && sNAME == "TAG_SET_LIST" )
					ctl = ctlPARENT.FindControl("TAG_SET_NAME");
				// 10/25/2009 Paul.  Allow KBTAG_SET_LIST to also imply KBTAG_NAME. 
				else if ( ctl == null && sNAME == "KBTAG_SET_LIST" )
					ctl = ctlPARENT.FindControl("KBTAG_NAME");
				// 01/10/2008 Paul.  Simplify by using the IS clause instead of GetType(). 
				if ( ctl != null )
				{
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					if ( ctl is TextBox )
					{
						TextBox txt = ctl as TextBox;
						// 01/29/2008 Paul.  Lets trim the text everwhere.  The only place that trimming is not wanted is in the terminology editor. 
						sVALUE = txt.Text.Trim();
					}
					// 04/02/2009 Paul.  Add support for FCKEditor to the EditView. 
					// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
					else if ( ctl is CKEditorControl )
					{
						CKEditorControl txt = ctl as CKEditorControl;
						sVALUE = txt.Text;
					}
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					else if ( ctl is Label )
					{
						Label lbl = ctl as Label;
						sVALUE = lbl.Text;
					}
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					else if ( ctl is DropDownList )
					{
						DropDownList lst = ctl as DropDownList;
						sVALUE = lst.SelectedValue;
					}
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					else if ( ctl is HtmlInputHidden )
					{
						HtmlInputHidden txt = ctl as HtmlInputHidden;
						sVALUE = txt.Value;
					}
					// 05/28/2007 Paul.  .NET 2.0 has a new control for the hidden field and we are starting to use it in the Payments module. 
					else if ( ctl is HiddenField )
					{
						HiddenField txt = ctl as HiddenField;
						sVALUE = txt.Value;
					}
					// 09/05/2006 Paul.  DetailViews place the literal in a span. 
					else if ( ctl is HtmlGenericControl )
					{
						HtmlGenericControl spn = ctl as HtmlGenericControl;
						if ( spn.Controls.Count > 0 )
						{
							if ( spn.Controls[0] is Literal )
							{
								Literal txt = spn.Controls[0] as Literal;
								sVALUE = txt.Text;
							}
						}
						else
						{
							sVALUE = spn.InnerText;
						}
					}
					// 12/30/2007 Paul.  A customer needed the ability to save and restore the multiple selection. 
					else if ( ctl is ListBox )
					{
						ListBox lst = ctl as ListBox;
						// 01/06/2018 Paul.  Add DATA_FORMAT to ListBox support multi-select CSV. 
						// 01/06/2018 Paul.  Use the class name to distinguish if this is multiple-select 
						if ( lst.SelectionMode == ListSelectionMode.Multiple && lst.CssClass.Contains("multiple-select") )
						{
							System.Text.StringBuilder sbValues = new System.Text.StringBuilder();
							foreach ( ListItem item in lst.Items )
							{
								if ( item.Selected )
								{
									if ( sbValues.Length > 0 )
										sbValues.Append(",");
									sbValues.Append(item.Value);
								}
							}
							// 05/07/2014 Paul.  Store NULL when nothing selected for multi-selection control. 
							sVALUE = sbValues.ToString();
						}
						else if ( lst.SelectionMode == ListSelectionMode.Multiple )
						{
							XmlDocument xml = new XmlDocument();
							// 12/30/2007 Paul.  The XML declaration is important as it will be used to determine if the XML is valid during rendering. 
							xml.AppendChild(xml.CreateXmlDeclaration("1.0", "UTF-8", null));
							xml.AppendChild(xml.CreateElement("Values"));
							int nSelected = 0;
							foreach(ListItem item in lst.Items)
							{
								if ( item.Selected )
									nSelected++;
							}
							if ( nSelected > 0 )
							{
								foreach(ListItem item in lst.Items)
								{
									if ( item.Selected )
									{
										XmlNode xValue = xml.CreateElement("Value");
										xml.DocumentElement.AppendChild(xValue);
										xValue.InnerText = item.Value;
									}
								}
								// 05/07/2014 Paul.  Store NULL when nothing selected for multi-selection control. 
								sVALUE = xml.OuterXml;
							}
						}
						else
						{
							sVALUE = lst.SelectedValue;
						}
					}
					// 06/16/2010 Paul.  Add support for CheckBoxList. 
					else if ( ctl is CheckBoxList )
					{
						CheckBoxList lst = ctl as CheckBoxList;
						// 03/22/2013 Paul.  REPEAT_DOW is a special list that returns 0 = sunday, 1 = monday, etc. 
						if ( lst.ID == "REPEAT_DOW" )
						{
							sVALUE = String.Empty;
							for ( int i = 0; i < lst.Items.Count; i++ )
							{
								if ( lst.Items[i].Selected )
									sVALUE += i.ToString();
							}
						}
						else
						{
							XmlDocument xml = new XmlDocument();
							// 12/30/2007 Paul.  The XML declaration is important as it will be used to determine if the XML is valid during rendering. 
							xml.AppendChild(xml.CreateXmlDeclaration("1.0", "UTF-8", null));
							xml.AppendChild(xml.CreateElement("Values"));
							int nSelected = 0;
							foreach(ListItem item in lst.Items)
							{
								if ( item.Selected )
									nSelected++;
							}
							if ( nSelected > 0 )
							{
								foreach(ListItem item in lst.Items)
								{
									if ( item.Selected )
									{
										XmlNode xValue = xml.CreateElement("Value");
										xml.DocumentElement.AppendChild(xValue);
										xValue.InnerText = item.Value;
									}
								}
							}
							sVALUE = xml.OuterXml;
						}
					}
					// 06/16/2010 Paul.  Add support for Radio buttons. 
					else if ( ctl is RadioButtonList )
					{
						RadioButtonList lst = ctl as RadioButtonList;
						sVALUE = lst.SelectedValue;
					}
					// 03/13/2009 Paul.  We need to allow a date value to be stored in a text field. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DatePicker) )
					{
						TimeZone T10n = ctlPARENT.GetT10n();
						_controls.DatePicker dt = ctl as _controls.DatePicker;
						DateTime dtVALUE = T10n.ToServerTime(dt.Value);
						if ( dtVALUE != DateTime.MinValue )
						{
							// 11/16/2017 Paul.  First check for null before adding 12:00 pm. 
							if ( !Sql.ToBoolean(ctlPARENT.Application["CONFIG.LegacyDatePicker"]) )
							{
								// 08/25/2017 Paul.  With DatePicker, force time to 12:00 pm. 
								dtVALUE = new DateTime(dt.Value.Year, dt.Value.Month, dt.Value.Day, 12, 0, 0);
							}
							sVALUE = dtVALUE.ToString();
						}
					}
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimePicker) )
					{
						TimeZone T10n = ctlPARENT.GetT10n();
						_controls.DateTimePicker dt = ctl as _controls.DateTimePicker;
						DateTime dtVALUE = T10n.ToServerTime(dt.Value);
						if ( dtVALUE != DateTime.MinValue )
							sVALUE = dtVALUE.ToString();
					}
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimeEdit) )
					{
						TimeZone T10n = ctlPARENT.GetT10n();
						_controls.DateTimeEdit dt = ctl as _controls.DateTimeEdit;
						DateTime dtVALUE = T10n.ToServerTime(dt.Value);
						if ( dtVALUE != DateTime.MinValue )
							sVALUE = dtVALUE.ToString();
					}
					// 08/24/2009 Paul.  If we are getting a text string from TeamSelect, then it should return the list. 
					else if ( ctl.GetType().BaseType == typeof(_controls.TeamSelect) )
					{
						_controls.TeamSelect ts = ctl as _controls.TeamSelect;
						sVALUE = ts.TEAM_SET_LIST;
					}
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					else if ( ctl.GetType().BaseType == typeof(_controls.UserSelect) )
					{
						_controls.UserSelect ts = ctl as _controls.UserSelect;
						sVALUE = ts.ASSIGNED_SET_LIST;
					}
					// 05/12/2016 Paul.  Add Tags module. 
					else if ( ctl.GetType().BaseType == typeof(_controls.TagSelect) )
					{
						_controls.TagSelect ts = ctl as _controls.TagSelect;
						sVALUE = ts.TAG_SET_NAME;
					}
					// 06/07/2017 Paul.  Add NAICSCodes module. 
					else if ( ctl.GetType().BaseType == typeof(_controls.NAICSCodeSelect) )
					{
						_controls.NAICSCodeSelect ts = ctl as _controls.NAICSCodeSelect;
						sVALUE = ts.NAICS_SET_NAME;
					}
					// 10/21/2009 Paul.  If we are getting a text string from KBTagSelect, then it should return the list. 
					else if ( ctl.GetType().BaseType == typeof(_controls.KBTagSelect) )
					{
						_controls.KBTagSelect kbt = ctl as _controls.KBTagSelect;
						sVALUE = kbt.KBTAG_SET_LIST;
					}
					// 09/09/2009 Paul.  A literal control should be the clue to pull from the existing recordset. 
					else if ( ctl is Literal )
					{
						// 09/20/2009 Paul.  Always check if rowCurrent is not null.  It is null for a new record. 
						if ( rowCurrent != null )
						{
							// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
							if ( rowCurrent.Table.Columns.Contains(sNAME) )
								sVALUE = Sql.ToString(rowCurrent[sNAME]);
						}
						// 06/12/2014 Paul.  If recordset not available, then pull from control. 
						else
						{
							Literal txt = ctl as Literal;
							sVALUE = txt.Text;
						}
					}
					// 01/14/2015 Paul.  Include CheckBox in text response so that import default values will work. 
					else if ( ctl is CheckBox )
					{
						CheckBox chk = ctl as CheckBox;
						sVALUE = chk.Checked.ToString();
					}
				}
				else if ( rowCurrent != null )
				{
					// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
					if ( rowCurrent.Table.Columns.Contains(sNAME) )
						sVALUE = Sql.ToString(rowCurrent[sNAME]);
				}
				return sVALUE;
			}
			set
			{
				Control ctl = ctlPARENT.FindControl(sNAME);
				// 04/14/2013 Paul.  Allow TEAM_SET_LIST to also imply TEAM_SET_NAME. 
				if ( ctl == null && sNAME == "TEAM_SET_LIST" )
					ctl = ctlPARENT.FindControl("TEAM_SET_NAME");
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( ctl == null && sNAME == "ASSIGNED_SET_LIST" )
					ctl = ctlPARENT.FindControl("ASSIGNED_SET_NAME");
				// 05/12/2016 Paul.  Allow TAG_SET_LIST to also imply TAG_SET_NAME. 
				else if ( ctl == null && sNAME == "TAG_SET_LIST" )
					ctl = ctlPARENT.FindControl("TAG_SET_NAME");
				// 04/14/2013 Paul.  Allow KBTAG_SET_LIST to also imply KBTAG_NAME. 
				else if ( ctl == null && sNAME == "KBTAG_SET_LIST" )
					ctl = ctlPARENT.FindControl("KBTAG_NAME");
				if ( ctl != null )
				{
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					if ( ctl is TextBox )
					{
						TextBox txt = ctl as TextBox;
						txt.Text = value;
					}
					// 04/02/2009 Paul.  Add support for FCKEditor to the EditView. 
						// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
					else if ( ctl is CKEditorControl )
					{
						CKEditorControl txt = ctl as CKEditorControl;
						txt.Text = value;
					}
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					else if ( ctl is Label )
					{
						Label lbl = ctl as Label;
						lbl.Text = value;
					}
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					else if ( ctl is DropDownList )
					{
						DropDownList lst = ctl as DropDownList;
						try
						{
							// 08/19/2010 Paul.  Check the list before assigning the value. 
							Utils.SetValue(lst, value);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					else if ( ctl is HtmlInputHidden )
					{
						HtmlInputHidden txt = ctl as HtmlInputHidden;
						txt.Value = value;
					}
					// 06/05/2007 Paul.  .NET 2.0 has a new control for the hidden field and we are starting to use it in the Payments module. 
					else if ( ctl is HiddenField )
					{
						HiddenField txt = ctl as HiddenField;
						txt.Value = value;
					}
					// 07/24/2006 Paul.  Allow the text of a literal to be set. 
					else if ( ctl is Literal )
					{
						Literal txt = ctl as Literal;
						txt.Text = value;
					}
					// 09/05/2006 Paul.  DetailViews place the literal in a span. 
					else if ( ctl is HtmlGenericControl )
					{
						HtmlGenericControl spn = ctl as HtmlGenericControl;
						if ( spn.Controls.Count > 0 )
						{
							if ( spn.Controls[0] is Literal )
							{
								Literal txt = spn.Controls[0] as Literal;
								txt.Text = value;
							}
						}
						else
						{
							spn.InnerText = value;
						}
					}
					// 12/30/2007 Paul.  A customer needed the ability to save and restore the multiple selection. 
					else if ( ctl is ListBox )
					{
						ListBox lst = ctl as ListBox;
						try
						{
							// 12/30/2007 Paul.  Require the XML declaration in the data before trying to treat as XML. 
							string sVALUE = value;
							if ( lst.SelectionMode == ListSelectionMode.Multiple && sVALUE.StartsWith("<?xml") )
							{
								XmlDocument xml = new XmlDocument();
								// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
								// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
								// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
								xml.XmlResolver = null;
								xml.LoadXml(sVALUE);
								XmlNodeList nlValues = xml.DocumentElement.SelectNodes("Value");
								foreach ( XmlNode xValue in nlValues )
								{
									foreach ( ListItem item in lst.Items )
									{
										if ( item.Value == xValue.InnerText )
											item.Selected = true;
									}
								}
							}
							else
							{
								// 08/19/2010 Paul.  Check the list before assigning the value. 
								Utils.SetValue(lst, sVALUE);
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
					// 11/15/2011 Paul.  Allow a date text value to be set. This is primarily for report parameters. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DatePicker) )
					{
						_controls.DatePicker dt = ctl as _controls.DatePicker;
						dt.DateText = value;
					}
					/*
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimePicker) )
					{
						_controls.DateTimePicker dt = ctl as _controls.DateTimePicker;
					}
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimeEdit) )
					{
						_controls.DateTimeEdit dt = ctl as _controls.DateTimeEdit;
					}
					*/
					// 04/14/2013 Paul.  If we are getting a text string from TeamSelect, then it should return the list. 
					else if ( ctl.GetType().BaseType == typeof(_controls.TeamSelect) )
					{
						_controls.TeamSelect ts = ctl as _controls.TeamSelect;
						ts.TEAM_SET_LIST = value;
					}
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					else if ( ctl.GetType().BaseType == typeof(_controls.UserSelect) )
					{
						_controls.UserSelect ts = ctl as _controls.UserSelect;
						ts.ASSIGNED_SET_LIST = value;
					}
					// 05/12/2016 Paul.  Add Tags module. 
					else if ( ctl.GetType().BaseType == typeof(_controls.TagSelect) )
					{
						_controls.TagSelect ts = ctl as _controls.TagSelect;
						ts.TAG_SET_NAME = value;
					}
					// 06/07/2017 Paul.  Add NAICSCodes module. 
					else if ( ctl.GetType().BaseType == typeof(_controls.NAICSCodeSelect) )
					{
						_controls.NAICSCodeSelect ts = ctl as _controls.NAICSCodeSelect;
						ts.NAICS_SET_NAME = value;
					}
					// 04/14/2013 Paul.  If we are getting a text string from KBTagSelect, then it should return the list. 
					else if ( ctl.GetType().BaseType == typeof(_controls.KBTagSelect) )
					{
						_controls.KBTagSelect kbt = ctl as _controls.KBTagSelect;
						kbt.KBTAG_SET_LIST = value;
					}
				}
			}
		}

		public string SelectedValue
		{
			get
			{
				return this.Text;
			}
			set
			{
				this.Text = value;
			}
		}
		
		public Guid ID
		{
			get
			{
				// 12/03/2005 Paul.  Don't catch the Guid conversion error as this should not happen. 
				Guid gVALUE = Guid.Empty;
				Control ctl = ctlPARENT.FindControl(sNAME);
				// 08/24/2009 Paul.  Allow TEAM_ID to also imply TEAM_SET_NAME. 
				if ( ctl == null && sNAME == "TEAM_ID" )
					ctl = ctlPARENT.FindControl("TEAM_SET_NAME");
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				// 05/06/2018 Paul.  The correct alternate is ASSIGNED_SET_NAME. 
				else if ( ctl == null && sNAME == "ASSIGNED_USER_ID" )
					ctl = ctlPARENT.FindControl("ASSIGNED_SET_NAME");
				if ( ctl != null )
				{
					// 08/24/2009 Paul.  If we are getting an ID from TeamSelect, then it should return the primary team ID. 
					if ( ctl.GetType().BaseType == typeof(_controls.TeamSelect) )
					{
						_controls.TeamSelect ts = ctl as _controls.TeamSelect;
						gVALUE = ts.TEAM_ID;
					}
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					else if ( ctl.GetType().BaseType == typeof(_controls.UserSelect) )
					{
						_controls.UserSelect ts = ctl as _controls.UserSelect;
						gVALUE = ts.USER_ID;
					}
					else
					{
						string sVALUE = this.Text;
						if ( !Sql.IsEmptyString(sVALUE) )
						{
							// 05/11/2010 Paul.  We have seen where a multi-selection listbox was turned off. 
							if ( sVALUE.StartsWith("<?xml") )
							{
								XmlDocument xml = new XmlDocument();
								// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
								// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
								// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
								xml.XmlResolver = null;
								xml.LoadXml(sVALUE);
								XmlNodeList nlValues = xml.DocumentElement.SelectNodes("Value");
								foreach ( XmlNode xValue in nlValues )
								{
									gVALUE = Sql.ToGuid(xValue.InnerText);
									break;
								}
							}
							else
							{
								gVALUE = Sql.ToGuid(sVALUE);
							}
						}
					}
				}
				else if ( rowCurrent != null )
				{
					// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
					if ( rowCurrent.Table.Columns.Contains(sNAME) )
						gVALUE = Sql.ToGuid(rowCurrent[sNAME]);
				}
				return gVALUE;
			}
			set
			{
				this.Text = value.ToString();
			}
		}

		public int IntegerValue
		{
			get
			{
				// 12/03/2005 Paul.  Don't catch the Integer conversion error as this should not happen. 
				int nVALUE = 0;
				Control ctl = ctlPARENT.FindControl(sNAME);
				if ( ctl != null )
				{
					string sVALUE = this.Text;
					if ( !Sql.IsEmptyString(sVALUE) )
						nVALUE = Sql.ToInteger(sVALUE);
				}
				else if ( rowCurrent != null )
				{
					// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
					if ( rowCurrent.Table.Columns.Contains(sNAME) )
						nVALUE = Sql.ToInteger(rowCurrent[sNAME]);
				}
				return nVALUE;
			}
			set
			{
				this.Text = value.ToString();
			}
		}

		// 10/22/2013 Paul.  A Twitter ID is a long. 
		public long LongValue
		{
			get
			{
				long nVALUE = 0;
				Control ctl = ctlPARENT.FindControl(sNAME);
				if ( ctl != null )
				{
					string sVALUE = this.Text;
					if ( !Sql.IsEmptyString(sVALUE) )
						nVALUE = Sql.ToLong(sVALUE);
				}
				else if ( rowCurrent != null )
				{
					if ( rowCurrent.Table.Columns.Contains(sNAME) )
						nVALUE = Sql.ToInteger(rowCurrent[sNAME]);
				}
				return nVALUE;
			}
			set
			{
				this.Text = value.ToString();
			}
		}

		public Decimal DecimalValue
		{
			get
			{
				// 12/03/2005 Paul.  Don't catch the Decimal conversion error as this should not happen. 
				Decimal dVALUE = Decimal.Zero;
				Control ctl = ctlPARENT.FindControl(sNAME);
				if ( ctl != null )
				{
					string sVALUE = this.Text;
					if ( !Sql.IsEmptyString(sVALUE) )
						dVALUE = Sql.ToDecimal(sVALUE);
				}
				else if ( rowCurrent != null )
				{
					// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
					if ( rowCurrent.Table.Columns.Contains(sNAME) )
						dVALUE = Sql.ToDecimal(rowCurrent[sNAME]);
				}
				return dVALUE;
			}
			set
			{
				this.Text = value.ToString();
			}
		}

		public float FloatValue
		{
			get
			{
				// 12/03/2005 Paul.  Don't catch the float conversion error as this should not happen. 
				float fVALUE = 0;
				Control ctl = ctlPARENT.FindControl(sNAME);
				if ( ctl != null )
				{
					string sVALUE = this.Text;
					if ( !Sql.IsEmptyString(sVALUE) )
						fVALUE = Sql.ToFloat(sVALUE);
				}
				else if ( rowCurrent != null )
				{
					// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
					if ( rowCurrent.Table.Columns.Contains(sNAME) )
						fVALUE = Sql.ToFloat(rowCurrent[sNAME]);
				}
				return fVALUE;
			}
			set
			{
				this.Text = value.ToString();
			}
		}

		public bool Checked
		{
			get
			{
				bool bVALUE = false;
				Control ctl = ctlPARENT.FindControl(sNAME);
				if ( ctl != null )
				{
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					if ( ctl is CheckBox )
					{
						CheckBox chk = ctl as CheckBox;
						bVALUE = chk.Checked;
					}
					// 09/09/2009 Paul.  A literal control should be the clue to pull from the existing recordset. 
					else if ( ctl is Literal )
					{
						// 09/20/2009 Paul.  Always check if rowCurrent is not null.  It is null for a new record. 
						if ( rowCurrent != null )
						{
							// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
							if ( rowCurrent.Table.Columns.Contains(sNAME) )
								bVALUE = Sql.ToBoolean(rowCurrent[sNAME]);
						}
					}
					// 04/06/2016 Paul.  Modules Custom Enabled is a label, so use database for any unknown type. 
					else if ( rowCurrent != null )
					{
						if ( rowCurrent.Table.Columns.Contains(sNAME) )
							bVALUE = Sql.ToBoolean(rowCurrent[sNAME]);
					}
				}
				else if ( rowCurrent != null )
				{
					// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
					if ( rowCurrent.Table.Columns.Contains(sNAME) )
						bVALUE = Sql.ToBoolean(rowCurrent[sNAME]);
				}
				return bVALUE;
			}
			set
			{
				Control ctl = ctlPARENT.FindControl(sNAME);
				if ( ctl != null )
				{
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					if ( ctl is CheckBox )
					{
						CheckBox chk = ctl as CheckBox;
						chk.Checked = value;
					}
				}
			}
		}

		public DateTime DateValue
		{
			get
			{
				DateTime dtVALUE = DateTime.MinValue;
				Control ctl = ctlPARENT.FindControl(sNAME);
				if ( ctl != null )
				{
					TimeZone T10n = ctlPARENT.GetT10n();
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					if ( ctl is TextBox )
					{
						TextBox txt = ctl as TextBox;
						dtVALUE = T10n.ToServerTime(txt.Text);
					}
					// 03/10/2006 Paul.  User controls end in "_ascx".  Compare to the base type. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DatePicker) )
					{
						_controls.DatePicker dt = ctl as _controls.DatePicker;
						dtVALUE = T10n.ToServerTime(dt.Value);
						// 11/16/2017 Paul.  First check for null before adding 12:00 pm. 
						if ( dtVALUE != DateTime.MinValue )
						{
							// 08/25/2017 Paul.  With DatePicker, force time to 12:00 pm. 
							if ( !Sql.ToBoolean(ctlPARENT.Application["CONFIG.LegacyDatePicker"]) )
							{
								dtVALUE = new DateTime(dt.Value.Year, dt.Value.Month, dt.Value.Day, 12, 0, 0);
							}
						}
					}
					// 03/10/2006 Paul.  User controls end in "_ascx".  Compare to the base type. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimePicker) )
					{
						_controls.DateTimePicker dt = ctl as _controls.DateTimePicker;
						dtVALUE = T10n.ToServerTime(dt.Value);
					}
					// 03/10/2006 Paul.  User controls end in "_ascx".  Compare to the base type. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimeEdit) )
					{
						_controls.DateTimeEdit dt = ctl as _controls.DateTimeEdit;
						dtVALUE = T10n.ToServerTime(dt.Value);
					}
					// 06/12/2014 Paul.  A literal control should be the clue to pull from the existing recordset. 
					else if ( ctl is Literal || ctl is Label )
					{
						// 06/12/2014 Paul.  Always check if rowCurrent is not null.  It is null for a new record. 
						if ( rowCurrent != null )
						{
							// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
							if ( rowCurrent.Table.Columns.Contains(sNAME) )
								dtVALUE = Sql.ToDateTime(rowCurrent[sNAME]);
						}
						// 06/12/2014 Paul.  If recordset not available, then pull from control. 
						else if( ctl is Literal )
						{
							Literal txt = ctl as Literal;
							dtVALUE = T10n.ToServerTime(txt.Text);
						}
						else if( ctl is Label )
						{
							Label txt = ctl as Label;
							dtVALUE = T10n.ToServerTime(txt.Text);
						}
					}
				}
				else if ( rowCurrent != null )
				{
					// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
					if ( rowCurrent.Table.Columns.Contains(sNAME) )
						dtVALUE = Sql.ToDateTime(rowCurrent[sNAME]);
				}
				return dtVALUE;
			}
			set
			{
				Control ctl = ctlPARENT.FindControl(sNAME);
				if ( ctl != null )
				{
					TimeZone T10n = ctlPARENT.GetT10n();
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					if ( ctl is TextBox )
					{
						TextBox txt = ctl as TextBox;
						txt.Text = T10n.FromServerTime(value).ToString();
					}
					// 03/10/2006 Paul.  User controls end in "_ascx".  Compare to the base type. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DatePicker) )
					{
						_controls.DatePicker dt = ctl as _controls.DatePicker;
						dt.Value = T10n.FromServerTime(value);
						// 11/16/2017 Paul.  First check for null before adding 12:00 pm. 
						if ( dt.Value != DateTime.MinValue )
						{
							// 08/25/2017 Paul.  With DatePicker, force time to 12:00 pm. 
							if ( !Sql.ToBoolean(ctlPARENT.Application["CONFIG.LegacyDatePicker"]) )
							{
								dt.Value = new DateTime(value.Year, value.Month, value.Day, 12, 0, 0);
							}
						}
					}
					// 03/10/2006 Paul.  User controls end in "_ascx".  Compare to the base type. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimePicker) )
					{
						_controls.DateTimePicker dt = ctl as _controls.DateTimePicker;
						dt.Value = T10n.FromServerTime(value);
					}
					// 03/10/2006 Paul.  User controls end in "_ascx".  Compare to the base type. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimeEdit) )
					{
						_controls.DateTimeEdit dt = ctl as _controls.DateTimeEdit;
						dt.Value = T10n.FromServerTime(value);
					}
				}
			}
		}

		public bool Visible
		{
			get
			{
				bool bVisible = false;
				Control ctl = ctlPARENT.FindControl(sNAME);
				if ( ctl != null )
				{
					bVisible = ctl.Visible;
				}
				return bVisible;
			}
			set
			{
				Control ctl = ctlPARENT.FindControl(sNAME);
				if ( ctl != null )
				{
					ctl.Visible = value;
				}
			}
		}

		public override string ToString()
		{
			return this.Text;
		}
		
		// 10/11/2011 Paul.  Add access to WebControl properties. 
		// 05/28/2018 Paul.  We need to disable custom controls. 
		public bool Enabled
		{
			get
			{
				bool bEnabled = false;
				Control ctl = ctlPARENT.FindControl(sNAME) as Control;
				if ( ctl != null )
				{
					if ( ctl is WebControl )
						bEnabled = (ctl as WebControl).Enabled;
					else if ( ctl is DatePicker )
						bEnabled = (ctl as DatePicker).Enabled;
					else if ( ctl is DateTimeEdit )
						bEnabled = (ctl as DateTimeEdit).Enabled;
					else if ( ctl is DateTimePicker )
						bEnabled = (ctl as DateTimePicker).Enabled;
					else if ( ctl is TeamSelect )
						bEnabled = (ctl as TeamSelect).Enabled;
					else if ( ctl is UserSelect )
						bEnabled = (ctl as UserSelect).Enabled;
					else if ( ctl is TagSelect )
						bEnabled = (ctl as TagSelect).Enabled;
					else if ( ctl is NAICSCodeSelect )
						bEnabled = (ctl as NAICSCodeSelect).Enabled;
					else if ( ctl is KBTagSelect )
						bEnabled = (ctl as KBTagSelect).Enabled;
				}
				return bEnabled;
			}
			set
			{
				Control ctl = ctlPARENT.FindControl(sNAME) as Control;
				if ( ctl != null )
				{
					if ( ctl is WebControl )
						(ctl as WebControl ).Enabled = value;
					else if ( ctl is DatePicker )
						(ctl as DatePicker).Enabled = value;
					else if ( ctl is DateTimeEdit )
						(ctl as DateTimeEdit).Enabled = value;
					else if ( ctl is DateTimePicker )
						(ctl as DateTimePicker).Enabled = value;
					else if ( ctl is TeamSelect )
						(ctl as TeamSelect).Enabled = value;
					else if ( ctl is UserSelect )
						(ctl as UserSelect).Enabled = value;
					else if ( ctl is TagSelect )
						(ctl as TagSelect).Enabled = value;
					else if ( ctl is NAICSCodeSelect )
						(ctl as NAICSCodeSelect).Enabled = value;
					else if ( ctl is KBTagSelect )
						(ctl as KBTagSelect).Enabled = value;
					// 05/28/2018 Paul.  Disabling a hidden field means to disable the Select/Clear buttons. 
					else if ( ctl is HtmlInputHidden )
					{
						HtmlInputButton btnChange = ctlPARENT.FindControl(sNAME + "_btnChange") as HtmlInputButton;
						if ( btnChange != null )
							btnChange.Disabled = !value;
						HtmlInputButton btnClear = ctlPARENT.FindControl(sNAME + "_btnClear") as HtmlInputButton;
						if ( btnClear != null )
							btnClear.Disabled = !value;
					}
				}
			}
		}

		public string CssClass
		{
			get
			{
				string sCssClass = String.Empty;
				WebControl ctl = ctlPARENT.FindControl(sNAME) as WebControl;
				if ( ctl != null )
				{
					sCssClass = ctl.CssClass;
				}
				return sCssClass;
			}
			set
			{
				WebControl ctl = ctlPARENT.FindControl(sNAME) as WebControl;
				if ( ctl != null )
				{
					ctl.CssClass = value;
				}
			}
		}

		public string BackColor
		{
			get
			{
				string sBackColor = String.Empty;
				WebControl ctl = ctlPARENT.FindControl(sNAME) as WebControl;
				if ( ctl != null )
				{
					sBackColor = System.Drawing.ColorTranslator.ToHtml(ctl.BackColor);
				}
				return sBackColor;
			}
			set
			{
				WebControl ctl = ctlPARENT.FindControl(sNAME) as WebControl;
				if ( ctl != null )
				{
					ctl.BackColor = System.Drawing.ColorTranslator.FromHtml(value);
				}
			}
		}

		public string ForeColor
		{
			get
			{
				string sForeColor = String.Empty;
				WebControl ctl = ctlPARENT.FindControl(sNAME) as WebControl;
				if ( ctl != null )
				{
					sForeColor = System.Drawing.ColorTranslator.ToHtml(ctl.ForeColor);
				}
				return sForeColor;
			}
			set
			{
				WebControl ctl = ctlPARENT.FindControl(sNAME) as WebControl;
				if ( ctl != null )
				{
					ctl.ForeColor = System.Drawing.ColorTranslator.FromHtml(value);
				}
			}
		}

		public DynamicControl(SplendidControl ctlPARENT, string sNAME)
		{
			this.ctlPARENT  = ctlPARENT ;
			this.sNAME      = sNAME     ;
			this.rowCurrent = null      ;
		}
		
		// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
		public DynamicControl(SplendidControl ctlPARENT, DataRow rowCurrent, string sNAME)
		{
			this.ctlPARENT  = ctlPARENT ;
			this.sNAME      = sNAME     ;
			this.rowCurrent = rowCurrent;
		}

	}

	// 10/17/2015 Paul.  SplendidPortal needs similar features when working within Wizard control. 
	public class DynamicControl2
	{
		protected string          sNAME      ;
		protected SplendidControl ctlSplendid;
		protected Control         ctlPARENT  ;
		protected DataRow         rowCurrent ;

		public DynamicControl2(SplendidControl ctlSplendid, Control ctlPARENT, string sNAME)
		{
			this. ctlSplendid = ctlSplendid;
			this.ctlPARENT    = ctlPARENT ;
			this.sNAME        = sNAME     ;
			this.rowCurrent   = null      ;
		}
		
		public DynamicControl2(SplendidControl ctlSplendid, Control ctlPARENT, DataRow rowCurrent, string sNAME)
		{
			this. ctlSplendid = ctlSplendid;
			this.ctlPARENT    = ctlPARENT ;
			this.sNAME        = sNAME     ;
			this.rowCurrent   = rowCurrent;
		}

		public string Text
		{
			get
			{
				string sVALUE = String.Empty;
				Control ctl = ctlPARENT.FindControl(sNAME);
				// 08/24/2009 Paul.  Allow TEAM_SET_LIST to also imply TEAM_SET_NAME. 
				if ( ctl == null && sNAME == "TEAM_SET_LIST" )
					ctl = ctlPARENT.FindControl("TEAM_SET_NAME");
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( ctl == null && sNAME == "ASSIGNED_SET_LIST" )
					ctl = ctlPARENT.FindControl("ASSIGNED_SET_NAME");
				// 05/12/2016 Paul.  Allow TAG_SET_LIST to also imply TAG_SET_NAME. 
				else if ( ctl == null && sNAME == "TAG_SET_LIST" )
					ctl = ctlPARENT.FindControl("TAG_SET_NAME");
				// 10/25/2009 Paul.  Allow KBTAG_SET_LIST to also imply KBTAG_NAME. 
				else if ( ctl == null && sNAME == "KBTAG_SET_LIST" )
					ctl = ctlPARENT.FindControl("KBTAG_NAME");
				// 01/10/2008 Paul.  Simplify by using the IS clause instead of GetType(). 
				if ( ctl != null )
				{
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					if ( ctl is TextBox )
					{
						TextBox txt = ctl as TextBox;
						// 01/29/2008 Paul.  Lets trim the text everwhere.  The only place that trimming is not wanted is in the terminology editor. 
						sVALUE = txt.Text.Trim();
					}
					// 04/02/2009 Paul.  Add support for FCKEditor to the EditView. 
					// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
					else if ( ctl is CKEditorControl )
					{
						CKEditorControl txt = ctl as CKEditorControl;
						sVALUE = txt.Text;
					}
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					else if ( ctl is Label )
					{
						Label lbl = ctl as Label;
						sVALUE = lbl.Text;
					}
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					else if ( ctl is DropDownList )
					{
						DropDownList lst = ctl as DropDownList;
						sVALUE = lst.SelectedValue;
					}
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					else if ( ctl is HtmlInputHidden )
					{
						HtmlInputHidden txt = ctl as HtmlInputHidden;
						sVALUE = txt.Value;
					}
					// 05/28/2007 Paul.  .NET 2.0 has a new control for the hidden field and we are starting to use it in the Payments module. 
					else if ( ctl is HiddenField )
					{
						HiddenField txt = ctl as HiddenField;
						sVALUE = txt.Value;
					}
					// 09/05/2006 Paul.  DetailViews place the literal in a span. 
					else if ( ctl is HtmlGenericControl )
					{
						HtmlGenericControl spn = ctl as HtmlGenericControl;
						if ( spn.Controls.Count > 0 )
						{
							if ( spn.Controls[0] is Literal )
							{
								Literal txt = spn.Controls[0] as Literal;
								sVALUE = txt.Text;
							}
						}
						else
						{
							sVALUE = spn.InnerText;
						}
					}
					// 12/30/2007 Paul.  A customer needed the ability to save and restore the multiple selection. 
					else if ( ctl is ListBox )
					{
						ListBox lst = ctl as ListBox;
						if ( lst.SelectionMode == ListSelectionMode.Multiple )
						{
							XmlDocument xml = new XmlDocument();
							// 12/30/2007 Paul.  The XML declaration is important as it will be used to determine if the XML is valid during rendering. 
							xml.AppendChild(xml.CreateXmlDeclaration("1.0", "UTF-8", null));
							xml.AppendChild(xml.CreateElement("Values"));
							int nSelected = 0;
							foreach(ListItem item in lst.Items)
							{
								if ( item.Selected )
									nSelected++;
							}
							if ( nSelected > 0 )
							{
								foreach(ListItem item in lst.Items)
								{
									if ( item.Selected )
									{
										XmlNode xValue = xml.CreateElement("Value");
										xml.DocumentElement.AppendChild(xValue);
										xValue.InnerText = item.Value;
									}
								}
								// 05/07/2014 Paul.  Store NULL when nothing selected for multi-selection control. 
								sVALUE = xml.OuterXml;
							}
						}
						else
						{
							sVALUE = lst.SelectedValue;
						}
					}
					// 06/16/2010 Paul.  Add support for CheckBoxList. 
					else if ( ctl is CheckBoxList )
					{
						CheckBoxList lst = ctl as CheckBoxList;
						// 03/22/2013 Paul.  REPEAT_DOW is a special list that returns 0 = sunday, 1 = monday, etc. 
						if ( lst.ID == "REPEAT_DOW" )
						{
							sVALUE = String.Empty;
							for ( int i = 0; i < lst.Items.Count; i++ )
							{
								if ( lst.Items[i].Selected )
									sVALUE += i.ToString();
							}
						}
						else
						{
							XmlDocument xml = new XmlDocument();
							// 12/30/2007 Paul.  The XML declaration is important as it will be used to determine if the XML is valid during rendering. 
							xml.AppendChild(xml.CreateXmlDeclaration("1.0", "UTF-8", null));
							xml.AppendChild(xml.CreateElement("Values"));
							int nSelected = 0;
							foreach(ListItem item in lst.Items)
							{
								if ( item.Selected )
									nSelected++;
							}
							if ( nSelected > 0 )
							{
								foreach(ListItem item in lst.Items)
								{
									if ( item.Selected )
									{
										XmlNode xValue = xml.CreateElement("Value");
										xml.DocumentElement.AppendChild(xValue);
										xValue.InnerText = item.Value;
									}
								}
							}
							sVALUE = xml.OuterXml;
						}
					}
					// 06/16/2010 Paul.  Add support for Radio buttons. 
					else if ( ctl is RadioButtonList )
					{
						RadioButtonList lst = ctl as RadioButtonList;
						sVALUE = lst.SelectedValue;
					}
					// 03/13/2009 Paul.  We need to allow a date value to be stored in a text field. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DatePicker) )
					{
						TimeZone T10n = ctlSplendid.GetT10n();
						_controls.DatePicker dt = ctl as _controls.DatePicker;
						DateTime dtVALUE = T10n.ToServerTime(dt.Value);
						if ( dtVALUE != DateTime.MinValue )
						{
							// 11/16/2017 Paul.  First check for null before adding 12:00 pm. 
							// 08/25/2017 Paul.  With DatePicker, force time to 12:00 pm. 
							if ( !Sql.ToBoolean(ctlSplendid.Application["CONFIG.LegacyDatePicker"]) )
							{
								dtVALUE = new DateTime(dt.Value.Year, dt.Value.Month, dt.Value.Day, 12, 0, 0);
							}
							sVALUE = dtVALUE.ToString();
						}
					}
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimePicker) )
					{
						TimeZone T10n = ctlSplendid.GetT10n();
						_controls.DateTimePicker dt = ctl as _controls.DateTimePicker;
						DateTime dtVALUE = T10n.ToServerTime(dt.Value);
						if ( dtVALUE != DateTime.MinValue )
							sVALUE = dtVALUE.ToString();
					}
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimeEdit) )
					{
						TimeZone T10n = ctlSplendid.GetT10n();
						_controls.DateTimeEdit dt = ctl as _controls.DateTimeEdit;
						DateTime dtVALUE = T10n.ToServerTime(dt.Value);
						if ( dtVALUE != DateTime.MinValue )
							sVALUE = dtVALUE.ToString();
					}
					// 08/24/2009 Paul.  If we are getting a text string from TeamSelect, then it should return the list. 
					else if ( ctl.GetType().BaseType == typeof(_controls.TeamSelect) )
					{
						_controls.TeamSelect ts = ctl as _controls.TeamSelect;
						sVALUE = ts.TEAM_SET_LIST;
					}
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					else if ( ctl.GetType().BaseType == typeof(_controls.UserSelect) )
					{
						_controls.UserSelect ts = ctl as _controls.UserSelect;
						sVALUE = ts.ASSIGNED_SET_LIST;
					}
					// 05/12/2016 Paul.  Add Tags module. 
					else if ( ctl.GetType().BaseType == typeof(_controls.TagSelect) )
					{
						_controls.TagSelect ts = ctl as _controls.TagSelect;
						sVALUE = ts.TAG_SET_NAME;
					}
					// 06/07/2017 Paul.  Add NAICSCodes module. 
					else if ( ctl.GetType().BaseType == typeof(_controls.NAICSCodeSelect) )
					{
						_controls.NAICSCodeSelect ts = ctl as _controls.NAICSCodeSelect;
						sVALUE = ts.NAICS_SET_NAME;
					}
					// 10/21/2009 Paul.  If we are getting a text string from KBTagSelect, then it should return the list. 
					else if ( ctl.GetType().BaseType == typeof(_controls.KBTagSelect) )
					{
						_controls.KBTagSelect kbt = ctl as _controls.KBTagSelect;
						sVALUE = kbt.KBTAG_SET_LIST;
					}
					// 09/09/2009 Paul.  A literal control should be the clue to pull from the existing recordset. 
					else if ( ctl is Literal )
					{
						// 09/20/2009 Paul.  Always check if rowCurrent is not null.  It is null for a new record. 
						if ( rowCurrent != null )
						{
							// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
							if ( rowCurrent.Table.Columns.Contains(sNAME) )
								sVALUE = Sql.ToString(rowCurrent[sNAME]);
						}
						// 06/12/2014 Paul.  If recordset not available, then pull from control. 
						else
						{
							Literal txt = ctl as Literal;
							sVALUE = txt.Text;
						}
					}
					// 01/14/2015 Paul.  Include CheckBox in text response so that import default values will work. 
					else if ( ctl is CheckBox )
					{
						CheckBox chk = ctl as CheckBox;
						sVALUE = chk.Checked.ToString();
					}
				}
				else if ( rowCurrent != null )
				{
					// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
					if ( rowCurrent.Table.Columns.Contains(sNAME) )
						sVALUE = Sql.ToString(rowCurrent[sNAME]);
				}
				return sVALUE;
			}
			set
			{
				Control ctl = ctlPARENT.FindControl(sNAME);
				// 04/14/2013 Paul.  Allow TEAM_SET_LIST to also imply TEAM_SET_NAME. 
				if ( ctl == null && sNAME == "TEAM_SET_LIST" )
					ctl = ctlPARENT.FindControl("TEAM_SET_NAME");
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( ctl == null && sNAME == "ASSIGNED_SET_LIST" )
					ctl = ctlPARENT.FindControl("ASSIGNED_SET_NAME");
				// 05/12/2016 Paul.  Allow TAG_SET_LIST to also imply TAG_SET_NAME. 
				else if ( ctl == null && sNAME == "TAG_SET_LIST" )
					ctl = ctlPARENT.FindControl("TAG_SET_NAME");
				// 04/14/2013 Paul.  Allow KBTAG_SET_LIST to also imply KBTAG_NAME. 
				else if ( ctl == null && sNAME == "KBTAG_SET_LIST" )
					ctl = ctlPARENT.FindControl("KBTAG_NAME");
				if ( ctl != null )
				{
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					if ( ctl is TextBox )
					{
						TextBox txt = ctl as TextBox;
						txt.Text = value;
					}
					// 04/02/2009 Paul.  Add support for FCKEditor to the EditView. 
						// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
					else if ( ctl is CKEditorControl )
					{
						CKEditorControl txt = ctl as CKEditorControl;
						txt.Text = value;
					}
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					else if ( ctl is Label )
					{
						Label lbl = ctl as Label;
						lbl.Text = value;
					}
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					else if ( ctl is DropDownList )
					{
						DropDownList lst = ctl as DropDownList;
						try
						{
							// 08/19/2010 Paul.  Check the list before assigning the value. 
							Utils.SetValue(lst, value);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					else if ( ctl is HtmlInputHidden )
					{
						HtmlInputHidden txt = ctl as HtmlInputHidden;
						txt.Value = value;
					}
					// 06/05/2007 Paul.  .NET 2.0 has a new control for the hidden field and we are starting to use it in the Payments module. 
					else if ( ctl is HiddenField )
					{
						HiddenField txt = ctl as HiddenField;
						txt.Value = value;
					}
					// 07/24/2006 Paul.  Allow the text of a literal to be set. 
					else if ( ctl is Literal )
					{
						Literal txt = ctl as Literal;
						txt.Text = value;
					}
					// 09/05/2006 Paul.  DetailViews place the literal in a span. 
					else if ( ctl is HtmlGenericControl )
					{
						HtmlGenericControl spn = ctl as HtmlGenericControl;
						if ( spn.Controls.Count > 0 )
						{
							if ( spn.Controls[0] is Literal )
							{
								Literal txt = spn.Controls[0] as Literal;
								txt.Text = value;
							}
						}
						else
						{
							spn.InnerText = value;
						}
					}
					// 12/30/2007 Paul.  A customer needed the ability to save and restore the multiple selection. 
					else if ( ctl is ListBox )
					{
						ListBox lst = ctl as ListBox;
						try
						{
							// 12/30/2007 Paul.  Require the XML declaration in the data before trying to treat as XML. 
							string sVALUE = value;
							if ( lst.SelectionMode == ListSelectionMode.Multiple && sVALUE.StartsWith("<?xml") )
							{
								XmlDocument xml = new XmlDocument();
								// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
								// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
								// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
								xml.XmlResolver = null;
								xml.LoadXml(sVALUE);
								XmlNodeList nlValues = xml.DocumentElement.SelectNodes("Value");
								foreach ( XmlNode xValue in nlValues )
								{
									foreach ( ListItem item in lst.Items )
									{
										if ( item.Value == xValue.InnerText )
											item.Selected = true;
									}
								}
							}
							// 01/06/2018 Paul.  Add DATA_FORMAT to ListBox support multi-select CSV. 
							// 01/06/2018 Paul.  Use the class name to distinguish if this is multiple-select 
							else if ( lst.SelectionMode == ListSelectionMode.Multiple && lst.CssClass.Contains("multiple-select") )
							{
								string[] nlValues = sVALUE.Split(',');
								foreach ( string xValue in nlValues )
								{
									Utils.SelectItem(lst, xValue);
								}
							}
							else
							{
								// 08/19/2010 Paul.  Check the list before assigning the value. 
								Utils.SetValue(lst, sVALUE);
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
					// 11/15/2011 Paul.  Allow a date text value to be set. This is primarily for report parameters. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DatePicker) )
					{
						_controls.DatePicker dt = ctl as _controls.DatePicker;
						dt.DateText = value;
					}
					/*
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimePicker) )
					{
						_controls.DateTimePicker dt = ctl as _controls.DateTimePicker;
					}
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimeEdit) )
					{
						_controls.DateTimeEdit dt = ctl as _controls.DateTimeEdit;
					}
					*/
					// 04/14/2013 Paul.  If we are getting a text string from TeamSelect, then it should return the list. 
					else if ( ctl.GetType().BaseType == typeof(_controls.TeamSelect) )
					{
						_controls.TeamSelect ts = ctl as _controls.TeamSelect;
						ts.TEAM_SET_LIST = value;
					}
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					else if ( ctl.GetType().BaseType == typeof(_controls.UserSelect) )
					{
						_controls.UserSelect ts = ctl as _controls.UserSelect;
						ts.ASSIGNED_SET_LIST = value;
					}
					// 05/12/2016 Paul.  Add Tags module. 
					else if ( ctl.GetType().BaseType == typeof(_controls.TagSelect) )
					{
						_controls.TagSelect ts = ctl as _controls.TagSelect;
						ts.TAG_SET_NAME = value;
					}
					// 06/07/2017 Paul.  Add NAICSCodes module. 
					else if ( ctl.GetType().BaseType == typeof(_controls.NAICSCodeSelect) )
					{
						_controls.NAICSCodeSelect ts = ctl as _controls.NAICSCodeSelect;
						ts.NAICS_SET_NAME = value;
					}
					// 04/14/2013 Paul.  If we are getting a text string from KBTagSelect, then it should return the list. 
					else if ( ctl.GetType().BaseType == typeof(_controls.KBTagSelect) )
					{
						_controls.KBTagSelect kbt = ctl as _controls.KBTagSelect;
						kbt.KBTAG_SET_LIST = value;
					}
				}
			}
		}

		public string SelectedValue
		{
			get
			{
				return this.Text;
			}
			set
			{
				this.Text = value;
			}
		}
		
		public Guid ID
		{
			get
			{
				// 12/03/2005 Paul.  Don't catch the Guid conversion error as this should not happen. 
				Guid gVALUE = Guid.Empty;
				Control ctl = ctlPARENT.FindControl(sNAME);
				// 08/24/2009 Paul.  Allow TEAM_ID to also imply TEAM_SET_NAME. 
				if ( ctl == null && sNAME == "TEAM_ID" )
					ctl = ctlPARENT.FindControl("TEAM_SET_NAME");
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( ctl == null && sNAME == "ASSIGNED_USER_ID" )
					ctl = ctlPARENT.FindControl("ASSIGNED_SET_NAME");
				if ( ctl != null )
				{
					// 08/24/2009 Paul.  If we are getting an ID from TeamSelect, then it should return the primary team ID. 
					if ( ctl.GetType().BaseType == typeof(_controls.TeamSelect) )
					{
						_controls.TeamSelect ts = ctl as _controls.TeamSelect;
						gVALUE = ts.TEAM_ID;
					}
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					else if ( ctl.GetType().BaseType == typeof(_controls.UserSelect) )
					{
						_controls.UserSelect ts = ctl as _controls.UserSelect;
						gVALUE = ts.USER_ID;
					}
					else
					{
						string sVALUE = this.Text;
						if ( !Sql.IsEmptyString(sVALUE) )
						{
							// 05/11/2010 Paul.  We have seen where a multi-selection listbox was turned off. 
							if ( sVALUE.StartsWith("<?xml") )
							{
								XmlDocument xml = new XmlDocument();
								// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
								// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
								// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
								xml.XmlResolver = null;
								xml.LoadXml(sVALUE);
								XmlNodeList nlValues = xml.DocumentElement.SelectNodes("Value");
								foreach ( XmlNode xValue in nlValues )
								{
									gVALUE = Sql.ToGuid(xValue.InnerText);
									break;
								}
							}
							else
							{
								gVALUE = Sql.ToGuid(sVALUE);
							}
						}
					}
				}
				else if ( rowCurrent != null )
				{
					// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
					if ( rowCurrent.Table.Columns.Contains(sNAME) )
						gVALUE = Sql.ToGuid(rowCurrent[sNAME]);
				}
				return gVALUE;
			}
			set
			{
				this.Text = value.ToString();
			}
		}

		public int IntegerValue
		{
			get
			{
				// 12/03/2005 Paul.  Don't catch the Integer conversion error as this should not happen. 
				int nVALUE = 0;
				Control ctl = ctlPARENT.FindControl(sNAME);
				if ( ctl != null )
				{
					string sVALUE = this.Text;
					if ( !Sql.IsEmptyString(sVALUE) )
						nVALUE = Sql.ToInteger(sVALUE);
				}
				else if ( rowCurrent != null )
				{
					// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
					if ( rowCurrent.Table.Columns.Contains(sNAME) )
						nVALUE = Sql.ToInteger(rowCurrent[sNAME]);
				}
				return nVALUE;
			}
			set
			{
				this.Text = value.ToString();
			}
		}

		public bool Checked
		{
			get
			{
				bool bVALUE = false;
				Control ctl = ctlPARENT.FindControl(sNAME);
				if ( ctl != null )
				{
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					if ( ctl is CheckBox )
					{
						CheckBox chk = ctl as CheckBox;
						bVALUE = chk.Checked;
					}
					// 09/09/2009 Paul.  A literal control should be the clue to pull from the existing recordset. 
					else if ( ctl is Literal )
					{
						// 09/20/2009 Paul.  Always check if rowCurrent is not null.  It is null for a new record. 
						if ( rowCurrent != null )
						{
							// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
							if ( rowCurrent.Table.Columns.Contains(sNAME) )
								bVALUE = Sql.ToBoolean(rowCurrent[sNAME]);
						}
					}
				}
				else if ( rowCurrent != null )
				{
					// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
					if ( rowCurrent.Table.Columns.Contains(sNAME) )
						bVALUE = Sql.ToBoolean(rowCurrent[sNAME]);
				}
				return bVALUE;
			}
			set
			{
				Control ctl = ctlPARENT.FindControl(sNAME);
				if ( ctl != null )
				{
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					if ( ctl is CheckBox )
					{
						CheckBox chk = ctl as CheckBox;
						chk.Checked = value;
					}
				}
			}
		}

		public DateTime DateValue
		{
			get
			{
				DateTime dtVALUE = DateTime.MinValue;
				Control ctl = ctlPARENT.FindControl(sNAME);
				if ( ctl != null )
				{
					TimeZone T10n = ctlSplendid.GetT10n();
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					if ( ctl is TextBox )
					{
						TextBox txt = ctl as TextBox;
						dtVALUE = T10n.ToServerTime(txt.Text);
					}
					// 03/10/2006 Paul.  User controls end in "_ascx".  Compare to the base type. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DatePicker) )
					{
						_controls.DatePicker dt = ctl as _controls.DatePicker;
						dtVALUE = T10n.ToServerTime(dt.Value);
						// 11/16/2017 Paul.  First check for null before adding 12:00 pm. 
						if ( dtVALUE != DateTime.MinValue )
						{
							// 08/25/2017 Paul.  With DatePicker, force time to 12:00 pm. 
							if ( !Sql.ToBoolean(ctlSplendid.Application["CONFIG.LegacyDatePicker"]) )
							{
								dtVALUE = new DateTime(dt.Value.Year, dt.Value.Month, dt.Value.Day, 12, 0, 0);
							}
						}
					}
					// 03/10/2006 Paul.  User controls end in "_ascx".  Compare to the base type. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimePicker) )
					{
						_controls.DateTimePicker dt = ctl as _controls.DateTimePicker;
						dtVALUE = T10n.ToServerTime(dt.Value);
					}
					// 03/10/2006 Paul.  User controls end in "_ascx".  Compare to the base type. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimeEdit) )
					{
						_controls.DateTimeEdit dt = ctl as _controls.DateTimeEdit;
						dtVALUE = T10n.ToServerTime(dt.Value);
					}
					// 06/12/2014 Paul.  A literal control should be the clue to pull from the existing recordset. 
					else if ( ctl is Literal || ctl is Label )
					{
						// 06/12/2014 Paul.  Always check if rowCurrent is not null.  It is null for a new record. 
						if ( rowCurrent != null )
						{
							// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
							if ( rowCurrent.Table.Columns.Contains(sNAME) )
								dtVALUE = Sql.ToDateTime(rowCurrent[sNAME]);
						}
						// 06/12/2014 Paul.  If recordset not available, then pull from control. 
						else if( ctl is Literal )
						{
							Literal txt = ctl as Literal;
							dtVALUE = T10n.ToServerTime(txt.Text);
						}
						else if( ctl is Label )
						{
							Label txt = ctl as Label;
							dtVALUE = T10n.ToServerTime(txt.Text);
						}
					}
				}
				else if ( rowCurrent != null )
				{
					// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
					if ( rowCurrent.Table.Columns.Contains(sNAME) )
						dtVALUE = Sql.ToDateTime(rowCurrent[sNAME]);
				}
				return dtVALUE;
			}
			set
			{
				Control ctl = ctlPARENT.FindControl(sNAME);
				if ( ctl != null )
				{
					TimeZone T10n = ctlSplendid.GetT10n();
					// 03/10/2006 Paul.  Compare to the type as .NET 2.0 returns the name in lowercase. We don't want to have this problem again. 
					if ( ctl is TextBox )
					{
						TextBox txt = ctl as TextBox;
						txt.Text = T10n.FromServerTime(value).ToString();
					}
					// 03/10/2006 Paul.  User controls end in "_ascx".  Compare to the base type. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DatePicker) )
					{
						_controls.DatePicker dt = ctl as _controls.DatePicker;
						dt.Value = T10n.FromServerTime(value);
						// 11/16/2017 Paul.  First check for null before adding 12:00 pm. 
						if ( dt.Value != DateTime.MinValue )
						{
							// 08/25/2017 Paul.  With DatePicker, force time to 12:00 pm. 
							if ( !Sql.ToBoolean(ctlSplendid.Application["CONFIG.LegacyDatePicker"]) )
							{
								dt.Value = new DateTime(value.Year, value.Month, value.Day, 12, 0, 0);
							}
						}
					}
					// 03/10/2006 Paul.  User controls end in "_ascx".  Compare to the base type. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimePicker) )
					{
						_controls.DateTimePicker dt = ctl as _controls.DateTimePicker;
						dt.Value = T10n.FromServerTime(value);
					}
					// 03/10/2006 Paul.  User controls end in "_ascx".  Compare to the base type. 
					else if ( ctl.GetType().BaseType == typeof(_controls.DateTimeEdit) )
					{
						_controls.DateTimeEdit dt = ctl as _controls.DateTimeEdit;
						dt.Value = T10n.FromServerTime(value);
					}
				}
			}
		}

	}
}

