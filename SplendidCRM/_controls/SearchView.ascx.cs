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
using System.Text;
using System.Data;
using System.Data.Common;
using System.Collections.Generic;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for SearchView.
	/// </summary>
	public class SearchView : SplendidControl
	{
		public delegate void SearchViewEditViewLoad(DataTable dt);
		public delegate void SearchViewSavedSearchApplied(XmlDocument xml);

		protected string        sGridID                = "grdMain";
		protected Label         lblError               ;
		protected DataTable     dtFields               ;
		protected string        sSEARCH_VIEW           ;
		protected string        sSearchMode            ;
		// 04/14/2013 Paul.  A dashlet should use a separate view than the base module view. 
		protected bool          bIsDashlet             ;
		protected string        sDynamicSearch         ;
		protected bool          bRegisterEnterKeyPress = true;
		protected int           nAdvanced              = 0;
		protected bool          bShowSearchTabs        = true;
		protected bool          bShowSearchViews       = true;
		// 06/27/2009 Paul.  On the home page, we don't want to show search views, but we do want to auto-save. 
		protected bool          bAutoSaveSearch        = false;
		// 04/09/2011 Paul.  The DashletReport must always save its settings, otherwise it will forget the selected report. 
		protected bool          bAlwaysSaveSearch      = false;
		// 03/04/2009 Paul.  We need the ability to hide the search buttons so that the SearchView can be used in the Reassign area. 
		protected bool          bShowSearchButtons     = true;
		protected bool          bIsPopupSearch         = false;
		protected bool          bShowDuplicateSearch   = false;
		// 06/20/2010 Paul.  When inside a subpanel, we cannot use Transfer. 
		protected bool          bIsSubpanelSearch      = false;
		// 06/27/2009 Paul.  Save the Last Applied search so that we can use it to determine if there was a change. 
		// We want to avoid updating if there was not change.  This is particularly important with all the search controls on the home page. 
		protected string        sXML_LastApplied       = String.Empty;

		protected HtmlTable     tblSearch              ;
		protected HyperLink     lnkBasicSearch         ;
		protected HyperLink     lnkAdvancedSearch      ;
		protected HyperLink     lnkDuplicateSearch     ;
		protected Button        btnSearch              ;
		protected Button        btnClear               ;
		protected Panel         pnlSearchPanel         ;
		protected Panel         pnlSavedSearchPanel    ;
		protected Image         imgBasicSearch         ;
		protected Image         imgAdvancedSearch      ;
		protected ListBox       lstDuplicateColumns    ;
		protected DropDownList  lstColumns             ;
		protected DropDownList  lstSavedSearches       ;
		protected RadioButton   radSavedSearchDESC     ;
		protected RadioButton   radSavedSearchASC      ;
		protected TextBox       txtSavedSearchName     ;
		protected Label         lblSavedNameRequired   ;
		// 06/05/2015 Paul.  New style for Seven theme. 
		protected Button        btnSavedSearchSave     ;
		protected Button        btnSavedSearchUpdate   ;
		protected Button        btnSavedSearchDelete   ;
		protected Label         lblCurrentSearch       ;
		protected Label         lblCurrentXML          ;

		public CommandEventHandler    Command       ;
		// 04/10/2011 Paul.  Allow the report dashlets to add fields. 
		public SearchViewEditViewLoad EditViewLoaded;
		public SearchViewSavedSearchApplied SavedSearchApplied;

		public string GridID
		{
			get { return sGridID; }
			set { sGridID = value; }
		}

		public string Module
		{
			get { return m_sMODULE; }
			set { m_sMODULE = value; }
		}

		public string SearchMode
		{
			get { return sSearchMode; }
			set { sSearchMode = value; }
		}

		// 04/14/2013 Paul.  A dashlet should use a separate view than the base module view. 
		public bool IsDashlet
		{
			get { return bIsDashlet; }
			set { bIsDashlet = value; }
		}

		public string DynamicSearch
		{
			get { return sDynamicSearch; }
			set { sDynamicSearch = value; }
		}

		public bool RegisterEnterKeyPress
		{
			get { return bRegisterEnterKeyPress; }
			set { bRegisterEnterKeyPress = value; }
		}

		public bool ShowSearchTabs
		{
			get { return bShowSearchTabs; }
			set { bShowSearchTabs = value; }
		}

		public bool ShowSearchViews
		{
			get { return bShowSearchViews; }
			set { bShowSearchViews = value; }
		}

		public bool AutoSaveSearch
		{
			get { return bAutoSaveSearch; }
			set { bAutoSaveSearch = value; }
		}

		// 01/01/2020 Paul.  Missing public declaration. 
		public bool AlwaysSaveSearch
		{
			get { return bAlwaysSaveSearch; }
			set { bAlwaysSaveSearch = value; }
		}

		public bool ShowSearchButtons
		{
			get { return bShowSearchButtons; }
			set { bShowSearchButtons = value; }
		}

		// 01/24/2010 Paul.  The Report Dashlet does not show the Clear Button. 
		public bool ShowClearButton
		{
			get { return btnClear.Visible; }
			set { btnClear.Visible = value; }
		}

		public bool ShowDuplicateSearch
		{
			get { return bShowDuplicateSearch; }
			set { bShowDuplicateSearch = value; }
		}

		// 06/20/2010 Paul.  When inside a subpanel, we cannot use Transfer. 
		public bool IsSubpanelSearch
		{
			get { return bIsSubpanelSearch; }
			set { bIsSubpanelSearch = value; }
		}

		public bool IsPopupSearch
		{
			get { return bIsPopupSearch; }
			set { bIsPopupSearch = value; }
		}

		public bool SavedSearchesChanged()
		{
			return lstSavedSearches.SelectedValue != Sql.ToString(ViewState["SavedSearches_PreviousValue"]);
		}

		// 06/26/2010 Paul.  We need to be able to submit the search from javascript. 
		public string SearchClientID
		{
			get { return btnSearch.ClientID; }
		}

		// 04/09/2011 Paul.  The DashletReport must always save its settings, otherwise it will forget the selected report. 
		private bool SaveEnabled()
		{
			return bAlwaysSaveSearch || (Sql.ToBoolean(Application["CONFIG.save_query"]) && Sql.ToBoolean(Session["USER_SETTINGS/SAVE_QUERY"]));
		}

		// 12/07/2008 Paul.  It is useful to be able to save defaults on an external event. 
		public void SaveDefaultView()
		{
			try
			{
				string sXML = GenerateSavedSearch(true);
				// 06/27/2009 Paul.  Save the Last Applied search so that we can use it to determine if there was a change. 
				// We want to avoid updating if there was not change.  This is particularly important with all the search controls on the home page. 
				if ( sXML_LastApplied != sXML )
				{
					Guid gID = Guid.Empty;
					// 01/24/2010 Paul.  New dynamic saved-search. 
					// 09/02/2010 Paul.  Instead of saving both a .SearchBasic and a .SearchAdvanced, 
					// only save a single profile so that the previous saved search will be remembered across basic and advanced. 
					string sDYNAMIC_SEARCH_VIEW = m_sMODULE;
					if ( !Sql.IsEmptyString(sDynamicSearch) )
						sDYNAMIC_SEARCH_VIEW = sSEARCH_VIEW + "." + sDynamicSearch;
					// 04/14/2013 Paul.  A dashlet should use a separate view than the base module view. 
					else if ( bIsDashlet )
						sDYNAMIC_SEARCH_VIEW = sSEARCH_VIEW;
					
					// 12/17/2007 Paul.  The default view must include the SearchModule in the name so that it does not get confused. 
					DataView vwSavedSearch = new DataView(SplendidCache.SavedSearch(sDYNAMIC_SEARCH_VIEW));
					vwSavedSearch.RowFilter = "NAME is null";
					if ( vwSavedSearch.Count > 0 )
						gID = Sql.ToGuid(vwSavedSearch[0]["ID"]);
					
					// 09/01/2010 Paul.  Store a copy of the DEFAULT_SEARCH_ID in the table so that we don't need to read the XML in order to get the value. 
					Guid gDEFAULT_SEARCH_ID = Sql.ToGuid(lstSavedSearches.SelectedValue);
					SqlProcs.spSAVED_SEARCH_Update(ref gID, Security.USER_ID, String.Empty, sDYNAMIC_SEARCH_VIEW, sXML, String.Empty, gDEFAULT_SEARCH_ID);
					// 12/09/2007 Paul.  If the default already exists, then just update its contents, saving us from having to clear the cache. 
					if ( vwSavedSearch.Count == 0 )
					{
						SplendidCache.ClearSavedSearch(sDYNAMIC_SEARCH_VIEW);
					}
					else
					{
						vwSavedSearch[0]["CONTENTS"] = sXML;
						vwSavedSearch[0]["DEFAULT_SEARCH_ID"] = gDEFAULT_SEARCH_ID;
					}
					sXML_LastApplied = sXML;
					// 03/04/2010 Paul.  We need to remember if we were successful loading the search, otherwise the Assigned-User code in the My* dashlets would get applied. 
					ViewState["SearchLoaded"] = true;
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
			}
		}

		// 06/27/2009 Paul.  Return TRUE if search was loaded. 
		public bool ApplySavedSearch()
		{
			// 12/08/2007 Paul.  Clear before we apply, just in case some fields were added since the view was saved. 
			ClearForm();
			string sXML = String.Empty;
			if ( !IsPostBack )
			{
				// 12/09/2007 Paul.  The last search will be saved with no name. 
				// 12/17/2007 Paul.  The default view must include the SearchModule in the name so that it does not get confused. 
				// 01/24/2010 Paul.  New dynamic saved-search. 
				// 09/02/2010 Paul.  Instead of saving both a .SearchBasic and a .SearchAdvanced, 
				// only save a single profile so that the previous saved search will be remembered across basic and advanced. 
				string sDYNAMIC_SEARCH_VIEW = m_sMODULE;
				if ( !Sql.IsEmptyString(sDynamicSearch) )
					sDYNAMIC_SEARCH_VIEW = sSEARCH_VIEW + "." + sDynamicSearch;
				// 04/14/2013 Paul.  A dashlet should use a separate view than the base module view. 
				else if ( bIsDashlet )
					sDYNAMIC_SEARCH_VIEW = sSEARCH_VIEW;
				
				DataView vwSavedSearches = new DataView(SplendidCache.SavedSearch(sDYNAMIC_SEARCH_VIEW));
				vwSavedSearches.RowFilter = "NAME is null";
				if ( vwSavedSearches.Count > 0 )
				{
					sXML = Sql.ToString(vwSavedSearches[0]["CONTENTS"]);
					ApplySavedSearch(sXML);
					try
					{
						// 02/23/2008 Paul.  After applying the default search, we may need to apply the last saved search. 
						// 02/23/2008 Paul.  lstSavedSearches.SelectedValue does not update immediately, so manually apply the default search. 
						if ( !Sql.IsEmptyString(sXML) )
						{
							//XmlDocument xml = new XmlDocument();
							// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
							// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
							// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
							//xml.XmlResolver = null;
							//xml.LoadXml(sXML);
							//string sDefaultSearch = XmlUtil.SelectSingleNode(xml, "DefaultSearch");
							// 09/01/2010 Paul.  Store a copy of the DEFAULT_SEARCH_ID in the table so that we don't need to read the XML in order to get the value. 
							string sDefaultSearch = Sql.ToString(vwSavedSearches[0]["DEFAULT_SEARCH_ID"]);
							if ( !Sql.IsEmptyString(sDefaultSearch) )
							{
								// 02/23/2008 Paul.  Saved Search uses a different list, so get the new data. 
								vwSavedSearches = new DataView(SplendidCache.SavedSearch(m_sMODULE));
								vwSavedSearches.RowFilter = "ID = '" + sDefaultSearch + "'";
								if ( vwSavedSearches.Count > 0 )
								{
									btnSavedSearchUpdate.Enabled = true;
									btnSavedSearchDelete.Enabled = true;
									lblCurrentSearch.Text = "\"" + Sql.ToString(vwSavedSearches[0]["NAME"]) + "\"";
									lblCurrentXML.Text = String.Empty;
									sXML = Sql.ToString(vwSavedSearches[0]["CONTENTS"]);
									ApplySavedSearch(sXML);
								}
							}
						}
					}
					catch
					{
					}
				}
			}
			else
			{
				// 09/13/2011 Paul.  We don't want to apply the saved search in a popup. 
				if ( !Sql.IsEmptyString(lstSavedSearches.SelectedValue) && (!bIsPopupSearch && bShowSearchViews) )
				{
					DataView vwSavedSearches = new DataView(SplendidCache.SavedSearch(m_sMODULE));
					vwSavedSearches.RowFilter = "ID = '" + lstSavedSearches.SelectedValue + "'";
					if ( vwSavedSearches.Count > 0 )
					{
						sXML = Sql.ToString(vwSavedSearches[0]["CONTENTS"]);
						ApplySavedSearch(sXML);
					}
				}
			}
			return !Sql.IsEmptyString(sXML);
		}

		public void ApplySavedSearch(string sXML)
		{
			try
			{
				// 06/27/2009 Paul.  Save the Last Applied search so that we can use it to determine if there was a change. 
				// We want to avoid updating if there was not change.  This is particularly important with all the search controls on the home page. 
				sXML_LastApplied = sXML;
				if ( !Sql.IsEmptyString(sXML) )
				{
					XmlDocument xml = new XmlDocument();
					// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
					// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
					// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
					xml.XmlResolver = null;
					xml.LoadXml(sXML);

					string sSortColumn = XmlUtil.SelectSingleNode(xml, "SortColumn");
					string sSortOrder  = XmlUtil.SelectSingleNode(xml, "SortOrder" );
					if ( !Sql.IsEmptyString(sSortColumn) && ! Sql.IsEmptyString(sSortOrder) && Command != null )
					{
						// 12/14/2007 Paul.  The ViewState in the search control is different than the view state on the page or the grid control. 
						// We need to send a command to set the sort fields.
						string[] arrSort = new string[] { sSortColumn, sSortOrder };
						CommandEventArgs eSortGrid = new CommandEventArgs("SortGrid", arrSort);
						Command(this, eSortGrid);
					}
					// 09/01/2010 Paul.  Set the previous saved search values. 
					// 02/25/2014 Paul.  Not sure why SortColumn is blank, bit it is throwing an exception. 
					if ( !Sql.IsEmptyString(sSortColumn) )
						Utils.SetSelectedValue(lstColumns      , sSortColumn   );
					radSavedSearchASC .Checked = (sSortOrder == "asc");
					radSavedSearchDESC.Checked = !radSavedSearchASC.Checked;
					
					string sDefaultSearch = XmlUtil.SelectSingleNode(xml, "DefaultSearch");
					if ( !Sql.IsEmptyString(sDefaultSearch) )
					{
						// 08/19/2010 Paul.  Check the list before assigning the value. 
						Utils.SetSelectedValue(lstSavedSearches, sDefaultSearch);
					}

					XmlNodeList nlSearchFields = xml.DocumentElement.SelectNodes("SearchFields/Field");
					foreach ( XmlNode xField in nlSearchFields )
					{
						string sDATA_FIELD = XmlUtil.GetNamedItem(xField, "Name");
						string sFIELD_TYPE = XmlUtil.GetNamedItem(xField, "Type");
						if ( !Sql.IsEmptyString(sDATA_FIELD) )
						{
							DynamicControl ctl = new DynamicControl(this, sDATA_FIELD);
							if ( ctl != null )
							{
								// 04/09/2011 Paul.  Change the field to a hidden field so that we can add Report Parameters. 
								if ( sFIELD_TYPE == "Hidden" )
								{
									ctl.Text = xField.InnerText;
								}
								// 04/05/2012 Paul.  Add searching support for checkbox list. 
								else if ( sFIELD_TYPE == "ListBox" || sFIELD_TYPE == "CheckBoxList" || sFIELD_TYPE == "Radio" )
								{
									ListControl lst = FindControl(sDATA_FIELD) as ListControl;
									if ( lst != null )
									{
										// 06/17/2010 Paul.  Add support for RadioButtonList and CheckBoxList. 
										// 11/17/2019 Paul.  Radio stores a single value, not XML. 
										if ( lst is ListBox || lst is CheckBoxList )
										{
											XmlNodeList nlValues = xField.SelectNodes("Value");
											if ( nlValues.Count > 0 )
											{
												foreach ( XmlNode xValue in nlValues )
												{
													foreach ( ListItem item in lst.Items )
													{
														if ( item.Value == xValue.InnerText )
															item.Selected = true;
													}
												}
											}
											// 09/02/2010 Paul.  If there are to Value tags, then try and use the value of field. 
											// This is to allow a saved DropDownList value to set a ListBox control. 
											else if ( !Sql.IsEmptyString(xField.InnerText) )
											{
												foreach ( ListItem item in lst.Items )
												{
													if ( item.Value == xField.InnerText )
													{
														item.Selected = true;
														break;
													}
												}
											}
										}
										// 11/17/2019 Paul.  Radio stores a single value, not XML. 
										else if ( lst is DropDownList || lst is RadioButtonList )
										{
											// 12/13/2007 Paul.  DropDownLists must be handled separately to ensure that only one item is selected. 
											try
											{
												// 08/19/2010 Paul.  Check the list before assigning the value. 
												Utils.SetValue(lst, xField.InnerText);
											}
											catch
											{
											}
										}
									}
									// 04/09/2011 Paul.  Change the field to a hidden field so that we can add Report Parameters. 
									// Instead of updating the SAVED_SEARCH data, just redirect the data. 
									else if ( FindControl(sDATA_FIELD) is HtmlInputHidden )
									{
										ctl.Text = xField.InnerText;
									}
								}
								else if ( sFIELD_TYPE == "DatePicker" )
								{
									// 01/01/2018 Paul.  Allow searching of multiple date fields. 
									DatePicker ctlDate = FindControl(sDATA_FIELD.Replace(" ", "_")) as DatePicker;
									if ( ctlDate != null )
									{
										if ( !Sql.IsEmptyString(xField.InnerText) )
										{
											ctlDate.DateText = xField.InnerText;
										}
									}
								}
								else if ( sFIELD_TYPE == "DateRange" )
								{
									XmlNode xStart = xField.SelectSingleNode("After");
									if ( xStart != null )
									{
										// 01/01/2018 Paul.  Allow searching of multiple date fields. 
										DatePicker ctlDateStart = FindControl(sDATA_FIELD.Replace(" ", "_") + "_AFTER") as DatePicker;
										if ( ctlDateStart != null )
										{
											if ( !Sql.IsEmptyString(xStart.InnerText) )
											{
												ctlDateStart.DateText = xStart.InnerText;
											}
										}
									}
									XmlNode xEnd = xField.SelectSingleNode("Before");
									if ( xEnd != null )
									{
										// 01/01/2018 Paul.  Allow searching of multiple date fields. 
										DatePicker ctlDateEnd = FindControl(sDATA_FIELD.Replace(" ", "_") + "_BEFORE") as DatePicker;
										if ( ctlDateEnd != null )
										{
											if ( !Sql.IsEmptyString(xEnd.InnerText) )
											{
												ctlDateEnd.DateText = xEnd.InnerText;
											}
										}
									}
								}
								else if ( sFIELD_TYPE == "CheckBox" )
								{
									ctl.Checked = Sql.ToBoolean(xField.InnerText);
								}
								// 04/13/2016 Paul.  Add ZipCode lookup. 
								else if ( sFIELD_TYPE == "TextBox" || sFIELD_TYPE == "ZipCodePopup" )
								{
									ctl.Text = xField.InnerText;
								}
								else if ( sFIELD_TYPE == "ChangeButton" || sFIELD_TYPE == "ModulePopup" )
								{
									ctl.Text = xField.InnerText;
								}
								else if ( sFIELD_TYPE == "TeamSelect" )
								{
									TeamSelect ctlTeamSelect = FindControl(sDATA_FIELD) as TeamSelect;
									if ( ctlTeamSelect != null )
									{
										ctlTeamSelect.InitTable();
										DataTable dtLineItems = ctlTeamSelect.LineItems;

										XmlNodeList nlTeams = xField.SelectNodes("Team");
										foreach ( XmlNode xTeam in nlTeams )
										{
											Guid gTEAM_ID = Sql.ToGuid(XmlUtil.SelectSingleNode(xTeam, "TEAM_ID"));
											if ( gTEAM_ID != Guid.Empty )
											{
												DataRow rowNew = dtLineItems.NewRow();
												dtLineItems.Rows.Add(rowNew);
												rowNew["TEAM_ID"     ] = gTEAM_ID;
												// 05/15/2016 Paul.  TeamSelect does not have a NAME field.  Must use TEAM_NAME. 
												rowNew["TEAM_NAME"   ] = XmlUtil.SelectSingleNode(xTeam, "NAME");
												rowNew["PRIMARY_TEAM"] = Sql.ToBoolean(XmlUtil.SelectSingleNode(xTeam, "PRIMARY_TEAM"));
											}
										}
										if ( dtLineItems.Rows.Count > 0 )
										{
											ctlTeamSelect.LineItems = dtLineItems;
										}
									}
								}
								// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
								else if ( sFIELD_TYPE == "UserSelect" )
								{
									UserSelect ctlUserSelect = FindControl(sDATA_FIELD) as UserSelect;
									if ( ctlUserSelect != null )
									{
										ctlUserSelect.InitTable();
										DataTable dtLineItems = ctlUserSelect.LineItems;

										XmlNodeList nlUsers = xField.SelectNodes("User");
										foreach ( XmlNode xUser in nlUsers )
										{
											Guid gUSER_ID = Sql.ToGuid(XmlUtil.SelectSingleNode(xUser, "USER_ID"));
											if ( gUSER_ID != Guid.Empty )
											{
												DataRow rowNew = dtLineItems.NewRow();
												dtLineItems.Rows.Add(rowNew);
												rowNew["USER_ID"     ] = gUSER_ID;
												// 11/30/2017 Paul.  UserSelect does not have a NAME field.  Must use USER_NAME. 
												rowNew["USER_NAME"   ] = XmlUtil.SelectSingleNode(xUser, "NAME");
												rowNew["PRIMARY_USER"] = Sql.ToBoolean(XmlUtil.SelectSingleNode(xUser, "PRIMARY_USER"));
											}
										}
										if ( dtLineItems.Rows.Count > 0 )
										{
											ctlUserSelect.LineItems = dtLineItems;
										}
									}
								}
								// 05/12/2016 Paul.  Add Tags module. 
								else if ( sFIELD_TYPE == "TagSelect" )
								{
									TagSelect ctlTagSelect = FindControl(sDATA_FIELD) as TagSelect;
									if ( ctlTagSelect != null )
									{
										ctlTagSelect.InitTable();
										DataTable dtLineItems = ctlTagSelect.LineItems;

										XmlNodeList nlTags = xField.SelectNodes("Tag");
										foreach ( XmlNode xTag in nlTags )
										{
											string sTAG_NAME = Sql.ToString(XmlUtil.SelectSingleNode(xTag, "NAME"));
											if ( !Sql.IsEmptyString(sTAG_NAME) )
											{
												DataRow rowNew = dtLineItems.NewRow();
												dtLineItems.Rows.Add(rowNew);
												rowNew["TAG_NAME"] = sTAG_NAME;
											}
										}
										if ( dtLineItems.Rows.Count > 0 )
										{
											ctlTagSelect.LineItems = dtLineItems;
										}
									}
								}
								// 06/07/2017 Paul.  Add NAICSCodes modules. 
								else if ( sFIELD_TYPE == "NAICSCodeSelect" )
								{
									NAICSCodeSelect ctlNAICSCodeSelect = FindControl(sDATA_FIELD) as NAICSCodeSelect;
									if ( ctlNAICSCodeSelect != null )
									{
										ctlNAICSCodeSelect.InitTable();
										DataTable dtLineItems = ctlNAICSCodeSelect.LineItems;

										XmlNodeList nlTags = xField.SelectNodes("Tag");
										foreach ( XmlNode xTag in nlTags )
										{
											string sNAICS_CODE_NAME = Sql.ToString(XmlUtil.SelectSingleNode(xTag, "NAME"));
											if ( !Sql.IsEmptyString(sNAICS_CODE_NAME) )
											{
												DataRow rowNew = dtLineItems.NewRow();
												dtLineItems.Rows.Add(rowNew);
												rowNew["NAICS_CODE_NAME"] = sNAICS_CODE_NAME;
											}
										}
										if ( dtLineItems.Rows.Count > 0 )
										{
											ctlNAICSCodeSelect.LineItems = dtLineItems;
										}
									}
								}
								else if ( sFIELD_TYPE == "ModuleAutoComplete" )
								{
									ctl.Text = xField.InnerText;
								}
							}
						}
					}
					// 12/28/2008 Paul.  Restore the duplicate fields. 
					if ( nAdvanced == 2 )
					{
						nlSearchFields = xml.DocumentElement.SelectNodes("DuplicateFields/Field");
						foreach ( XmlNode xField in nlSearchFields )
						{
							string sDATA_FIELD = XmlUtil.GetNamedItem(xField, "Name");
							string sFIELD_TYPE = XmlUtil.GetNamedItem(xField, "Type");
							if ( !Sql.IsEmptyString(sDATA_FIELD) )
							{
								if ( sDATA_FIELD == "lstDuplicateColumns" && sFIELD_TYPE == "ListBox" )
								{
									ListControl lst = lstDuplicateColumns;
									if ( lst != null )
									{
										if ( lst is ListBox )
										{
											foreach ( ListItem item in lst.Items )
											{
												item.Selected = false;
											}
											XmlNodeList nlValues = xField.SelectNodes("Value");
											foreach ( XmlNode xValue in nlValues )
											{
												foreach ( ListItem item in lst.Items )
												{
													if ( item.Value == xValue.InnerText )
														item.Selected = true;
												}
											}
										}
									}
								}
							}
						}
					}
					// 04/15/2011 Paul.  We need an event so that default report parameters can be applied. 
					if ( SavedSearchApplied != null )
					{
						SavedSearchApplied(xml);
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
			}
		}

		protected string GenerateSavedSearch(bool bDefaultSearch)
		{
			XmlDocument xml = new XmlDocument();
			xml.AppendChild(xml.CreateXmlDeclaration("1.0", "UTF-8", null));
			XmlNode xSavedSearch = xml.CreateElement("SavedSearch");
			xml.AppendChild(xSavedSearch);
			if ( dtFields != null )
			{
				if ( bDefaultSearch )
				{
					// 12/14/2007 Paul.  Although it might be better to use events to get the sort field, 
					// that could cause an endless loop as this control sets the sort field and retrieves the sort field. 
					SplendidGrid grdMain = Parent.FindControl(sGridID) as SplendidGrid;
					if ( grdMain != null )
					{
						if ( !String.IsNullOrEmpty(grdMain.SortColumn) )
						{
							XmlNode xSortColumn = xml.CreateElement("SortColumn");
							xSavedSearch.AppendChild(xSortColumn);
							xSortColumn.InnerText = grdMain.SortColumn;
						}
						if ( !String.IsNullOrEmpty(grdMain.SortOrder) )
						{
							XmlNode xSortOrder = xml.CreateElement("SortOrder");
							xSavedSearch.AppendChild(xSortOrder);
							xSortOrder.InnerText =grdMain.SortOrder;
						}
					}
					if ( !Sql.IsEmptyString(lstSavedSearches.SelectedValue) )
					{
						XmlNode xDefaultSearch = xml.CreateElement("DefaultSearch");
						xSavedSearch.AppendChild(xDefaultSearch);
						xDefaultSearch.InnerText = lstSavedSearches.SelectedValue;
					}
				}
				else
				{
					if ( !Sql.IsEmptyString(lstColumns.SelectedValue) )
					{
						XmlNode xSortColumn = xml.CreateElement("SortColumn");
						xSavedSearch.AppendChild(xSortColumn);
						xSortColumn.InnerText = lstColumns.SelectedValue;
					}
					if ( radSavedSearchASC.Checked || radSavedSearchDESC.Checked )
					{
						XmlNode xSortOrder = xml.CreateElement("SortOrder");
						xSavedSearch.AppendChild(xSortOrder);
						if ( radSavedSearchASC.Checked )
							xSortOrder.InnerText ="asc";
						else if ( radSavedSearchDESC.Checked )
							xSortOrder.InnerText ="desc";
					}
				}

				XmlNode xSearchFields = xml.CreateElement("SearchFields");
				xSavedSearch.AppendChild(xSearchFields);
				foreach(DataRowView row in dtFields.DefaultView)
				{
					string sFIELD_TYPE        = Sql.ToString (row["FIELD_TYPE"       ]);
					string sDATA_FIELD        = Sql.ToString (row["DATA_FIELD"       ]);
					string sDISPLAY_FIELD     = Sql.ToString (row["DISPLAY_FIELD"    ]);
					int    nFORMAT_MAX_LENGTH = Sql.ToInteger(row["FORMAT_MAX_LENGTH"]);
					int    nFORMAT_ROWS       = Sql.ToInteger(row["FORMAT_ROWS"      ]);

					// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
					if ( (sDATA_FIELD == "TEAM_ID" || sDATA_FIELD == "TEAM_SET_NAME") )
					{
						if ( Crm.Config.enable_team_management() && !Crm.Config.enable_dynamic_teams() && sFIELD_TYPE == "TeamSelect" )
						{
							sDATA_FIELD     = "TEAM_ID";
							sDISPLAY_FIELD  = "TEAM_NAME";
							sFIELD_TYPE     = "ModulePopup";
							//sMODULE_TYPE    = "Teams";
						}
					}
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					if ( (sDATA_FIELD == "ASSIGNED_USER_ID" || sDATA_FIELD == "ASSIGNED_SET_NAME") )
					{
						if ( !Crm.Config.enable_dynamic_assignment() && sFIELD_TYPE == "UserSelect" )
						{
							sDATA_FIELD     = "USER_ID";
							sDISPLAY_FIELD  = "USER_NAME";
							sFIELD_TYPE     = "ModulePopup";
							//sMODULE_TYPE    = "Users";
						}
					}
					// 12/07/2007 Paul.  Create the field but don't append it unless it is used. 
					// This is how we will distinguish from unspecified field. 
					XmlNode xField = xml.CreateElement("Field");
					XmlUtil.SetSingleNodeAttribute(xml, xField, "Name", sDATA_FIELD);
					XmlUtil.SetSingleNodeAttribute(xml, xField, "Type", sFIELD_TYPE);
					DynamicControl ctl = new DynamicControl(this, sDATA_FIELD);
					if ( ctl != null )
					{
						// 04/09/2011 Paul.  Change the field to a hidden field so that we can add Report Parameters. 
						if ( sFIELD_TYPE == "Hidden" )
						{
							xSearchFields.AppendChild(xField);
							xField.InnerText = ctl.Text;
						}
						// 04/05/2012 Paul.  Add searching support for checkbox list. 
						else if ( sFIELD_TYPE == "ListBox" || sFIELD_TYPE == "CheckBoxList" || sFIELD_TYPE == "Radio" )
						{
							ListControl lst = FindControl(sDATA_FIELD) as ListControl;
							if ( lst != null )
							{
								// 06/17/2010 Paul.  Add support for RadioButtonList and CheckBoxList. 
								// 11/17/2019 Paul.  Radio stores a single value, not XML. 
								if ( lst is ListBox || lst is CheckBoxList )
								{
									int nSelected = 0;
									foreach(ListItem item in lst.Items)
									{
										if ( item.Selected )
											nSelected++;
									}
									if ( nSelected > 0 )
									{
										xSearchFields.AppendChild(xField);
										foreach(ListItem item in lst.Items)
										{
											if ( item.Selected )
											{
												XmlNode xValue = xml.CreateElement("Value");
												xField.AppendChild(xValue);
												xValue.InnerText = item.Value;
											}
										}
									}
								}
								// 11/17/2019 Paul.  Radio stores a single value, not XML. 
								else if ( lst is DropDownList || lst is RadioButtonList )
								{
									// 12/13/2007 Paul.  DropDownLists must be handled separately to ensure that only one item is selected. 
									// 04/02/2008 Fabio.  SelectedValue was not getting saved. 
									xSearchFields.AppendChild(xField);
									xField.InnerText = lst.SelectedValue;
								}
							}
							// 04/09/2011 Paul.  Change the field to a hidden field so that we can add Report Parameters. 
							// Instead of updating the SAVED_SEARCH data, just redirect the data. 
							else if ( FindControl(sDATA_FIELD) is HtmlInputHidden )
							{
								xSearchFields.AppendChild(xField);
								xField.InnerText = ctl.Text;
							}
						}
						else if ( sFIELD_TYPE == "DatePicker" )
						{
							// 01/01/2018 Paul.  Allow searching of multiple date fields. 
							DatePicker ctlDate = FindControl(sDATA_FIELD.Replace(" ", "_")) as DatePicker;
							if ( ctlDate != null )
							{
								if ( !Sql.IsEmptyString(ctlDate.DateText) )
								{
									xSearchFields.AppendChild(xField);
									xField.InnerText = ctlDate.DateText;
								}
							}
						}
						else if ( sFIELD_TYPE == "DateRange" )
						{
							// 01/01/2018 Paul.  Allow searching of multiple date fields. 
							DatePicker ctlDateStart = FindControl(sDATA_FIELD.Replace(" ", "_") + "_AFTER") as DatePicker;
							if ( ctlDateStart != null )
							{
								if ( !Sql.IsEmptyString(ctlDateStart.DateText) )
								{
									xSearchFields.AppendChild(xField);
									XmlUtil.SetSingleNode(xml, xField, "After", ctlDateStart.DateText);
								}
							}
							// 01/01/2018 Paul.  Allow searching of multiple date fields. 
							DatePicker ctlDateEnd = FindControl(sDATA_FIELD.Replace(" ", "_") + "_BEFORE") as DatePicker;
							if ( ctlDateEnd != null )
							{
								if ( !Sql.IsEmptyString(ctlDateEnd.DateText) )
								{
									xSearchFields.AppendChild(xField);
									XmlUtil.SetSingleNode(xml, xField, "Before", ctlDateEnd.DateText);
								}
							}
						}
						else if ( sFIELD_TYPE == "CheckBox" )
						{
							if ( ctl.Checked )
							{
								xSearchFields.AppendChild(xField);
								xField.InnerText = "true";
							}
						}
						// 04/13/2016 Paul.  Add ZipCode lookup. 
						else if ( sFIELD_TYPE == "TextBox" || sFIELD_TYPE == "ZipCodePopup" )
						{
							ctl.Text = ctl.Text.Trim();
							if ( !Sql.IsEmptyString(ctl.Text) )
							{
								xSearchFields.AppendChild(xField);
								xField.InnerText = ctl.Text;
							}
						}
						else if ( sFIELD_TYPE == "ChangeButton" || sFIELD_TYPE == "ModulePopup" )
						{
							ctl.Text = ctl.Text.Trim();
							if ( !Sql.IsEmptyString(ctl.Text) )
							{
								xSearchFields.AppendChild(xField);
								xField.InnerText = ctl.Text;
							}
							// 12/08/2007 Paul.  Save the display field as a separate XML node. 
							// Treat it as a text box and it will get populated just like any other search field. 
							DynamicControl ctlDISPLAY_FIELD = new DynamicControl(this, sDISPLAY_FIELD);
							if ( ctlDISPLAY_FIELD != null )
							{
								ctlDISPLAY_FIELD.Text = ctlDISPLAY_FIELD.Text.Trim();
								xField = xml.CreateElement("Field");
								XmlUtil.SetSingleNodeAttribute(xml, xField, "Name", sDISPLAY_FIELD);
								XmlUtil.SetSingleNodeAttribute(xml, xField, "Type", "TextBox");
								if ( !Sql.IsEmptyString(ctlDISPLAY_FIELD.Text) )
								{
									xSearchFields.AppendChild(xField);
									xField.InnerText = ctlDISPLAY_FIELD.Text;
								}
							}
						}
						else if ( sFIELD_TYPE == "TeamSelect" )
						{
							TeamSelect ctlTeamSelect = FindControl(sDATA_FIELD) as TeamSelect;
							if ( ctlTeamSelect != null )
							{
								DataTable dtLineItems = ctlTeamSelect.LineItems;
								if ( dtLineItems != null )
								{
									int nSelected = 0;
									DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
									foreach ( DataRow rowTeam in aCurrentRows )
									{
										Guid gTEAM_ID = Sql.ToGuid(rowTeam["TEAM_ID"]);
										if ( gTEAM_ID != Guid.Empty )
										{
											nSelected++;
										}
									}
									if ( nSelected > 0 )
									{
										xSearchFields.AppendChild(xField);
										foreach ( DataRow rowTeam in aCurrentRows )
										{
											Guid gTEAM_ID = Sql.ToGuid(rowTeam["TEAM_ID"]);
											if ( gTEAM_ID != Guid.Empty )
											{
												XmlNode xTeam = xml.CreateElement("Team");
												xField.AppendChild(xTeam);
												
												XmlNode xTEAM_ID = xml.CreateElement("TEAM_ID");
												xTeam.AppendChild(xTEAM_ID);
												xTEAM_ID.InnerText = gTEAM_ID.ToString();
												
												XmlNode xNAME = xml.CreateElement("NAME");
												xTeam.AppendChild(xNAME);
												// 05/15/2016 Paul.  TeamSelect does not have a NAME field.  Must use TEAM_NAME. 
												xNAME.InnerText = Sql.ToString(rowTeam["TEAM_NAME"]);
												
												XmlNode xPRIMARY_TEAM = xml.CreateElement("PRIMARY_TEAM");
												xTeam.AppendChild(xPRIMARY_TEAM);
												xPRIMARY_TEAM.InnerText = Sql.ToString(rowTeam["PRIMARY_TEAM"]);
											}
										}
									}
								}
							}
						}
						// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
						else if ( sFIELD_TYPE == "UserSelect" )
						{
							UserSelect ctlUserSelect = FindControl(sDATA_FIELD) as UserSelect;
							if ( ctlUserSelect != null )
							{
								DataTable dtLineItems = ctlUserSelect.LineItems;
								if ( dtLineItems != null )
								{
									int nSelected = 0;
									DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
									foreach ( DataRow rowUser in aCurrentRows )
									{
										Guid gUSER_ID = Sql.ToGuid(rowUser["USER_ID"]);
										if ( gUSER_ID != Guid.Empty )
										{
											nSelected++;
										}
									}
									if ( nSelected > 0 )
									{
										xSearchFields.AppendChild(xField);
										foreach ( DataRow rowUser in aCurrentRows )
										{
											Guid gUSER_ID = Sql.ToGuid(rowUser["USER_ID"]);
											if ( gUSER_ID != Guid.Empty )
											{
												XmlNode xUser = xml.CreateElement("User");
												xField.AppendChild(xUser);
												
												XmlNode xUSER_ID = xml.CreateElement("USER_ID");
												xUser.AppendChild(xUSER_ID);
												xUSER_ID.InnerText = gUSER_ID.ToString();
												
												XmlNode xNAME = xml.CreateElement("NAME");
												xUser.AppendChild(xNAME);
												// 11/30/2017 Paul.  UserSelect does not have a NAME field.  Must use USER_NAME. 
												xNAME.InnerText = Sql.ToString(rowUser["USER_NAME"]);
												
												XmlNode xPRIMARY_USER = xml.CreateElement("PRIMARY_USER");
												xUser.AppendChild(xPRIMARY_USER);
												xPRIMARY_USER.InnerText = Sql.ToString(rowUser["PRIMARY_USER"]);
											}
										}
									}
								}
							}
						}
						// 05/12/2016 Paul.  Add Tags module. 
						else if ( sFIELD_TYPE == "TagSelect" )
						{
							TagSelect ctlTagSelect = FindControl(sDATA_FIELD) as TagSelect;
							if ( ctlTagSelect != null )
							{
								DataTable dtLineItems = ctlTagSelect.LineItems;
								if ( dtLineItems != null )
								{
									int nSelected = 0;
									DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
									foreach ( DataRow rowTag in aCurrentRows )
									{
										string sTAG_NAME = Sql.ToString(rowTag["TAG_NAME"]);
										if ( !Sql.IsEmptyString(sTAG_NAME) )
										{
											nSelected++;
										}
									}
									if ( nSelected > 0 )
									{
										xSearchFields.AppendChild(xField);
										foreach ( DataRow rowTag in aCurrentRows )
										{
											string sTAG_NAME = Sql.ToString(rowTag["TAG_NAME"]);
											if ( !Sql.IsEmptyString(sTAG_NAME) )
											{
												XmlNode xTag = xml.CreateElement("Tag");
												xField.AppendChild(xTag);
												
												XmlNode xNAME = xml.CreateElement("NAME");
												xTag.AppendChild(xNAME);
												xNAME.InnerText = sTAG_NAME;
											}
										}
									}
								}
							}
						}
						// 06/07/2017 Paul.  Add NAICSCodes module. 
						else if ( sFIELD_TYPE == "NAICSCodeSelect" )
						{
							NAICSCodeSelect ctlNAICSCodeSelect = FindControl(sDATA_FIELD) as NAICSCodeSelect;
							if ( ctlNAICSCodeSelect != null )
							{
								DataTable dtLineItems = ctlNAICSCodeSelect.LineItems;
								if ( dtLineItems != null )
								{
									int nSelected = 0;
									DataRow[] aCurrentRows = dtLineItems.Select(String.Empty, String.Empty, DataViewRowState.CurrentRows);
									foreach ( DataRow rowTag in aCurrentRows )
									{
										string sNAICS_CODE_NAME = Sql.ToString(rowTag["NAICS_CODE_NAME"]);
										if ( !Sql.IsEmptyString(sNAICS_CODE_NAME) )
										{
											nSelected++;
										}
									}
									if ( nSelected > 0 )
									{
										xSearchFields.AppendChild(xField);
										foreach ( DataRow rowTag in aCurrentRows )
										{
											string sNAICS_CODE_NAME = Sql.ToString(rowTag["NAICS_CODE_NAME"]);
											if ( !Sql.IsEmptyString(sNAICS_CODE_NAME) )
											{
												XmlNode xTag = xml.CreateElement("Tag");
												xField.AppendChild(xTag);
												
												XmlNode xNAME = xml.CreateElement("NAME");
												xTag.AppendChild(xNAME);
												xNAME.InnerText = sNAICS_CODE_NAME;
											}
										}
									}
								}
							}
						}
						else if ( sFIELD_TYPE == "ModuleAutoComplete" )
						{
							ctl.Text = ctl.Text.Trim();
							if ( !Sql.IsEmptyString(ctl.Text) )
							{
								xSearchFields.AppendChild(xField);
								xField.InnerText = ctl.Text;
							}
						}
					}
				}
				// 12/28/2008 Paul.  Save the duplicate fields. 
				if ( nAdvanced == 2 )
				{
					XmlNode xDuplicateFields = xml.CreateElement("DuplicateFields");
					xSavedSearch.AppendChild(xDuplicateFields);
					
					XmlNode xField = xml.CreateElement("Field");
					XmlUtil.SetSingleNodeAttribute(xml, xField, "Name", "lstDuplicateColumns");
					XmlUtil.SetSingleNodeAttribute(xml, xField, "Type", "ListBox");
					
					ListControl lst = lstDuplicateColumns;
					int nSelected = 0;
					foreach(ListItem item in lst.Items)
					{
						if ( item.Selected )
							nSelected++;
					}
					if ( nSelected > 0 )
					{
						xDuplicateFields.AppendChild(xField);
						foreach(ListItem item in lst.Items)
						{
							if ( item.Selected )
							{
								XmlNode xValue = xml.CreateElement("Value");
								xField.AppendChild(xValue);
								xValue.InnerText = item.Value;
							}
						}
					}
				}
			}
			return xml.OuterXml;
		}

		protected void lstSavedSearches_Changed(object sender, System.EventArgs e)
		{
			if ( Sql.IsEmptyString(lstSavedSearches.SelectedValue) )
			{
				btnSavedSearchUpdate.Enabled = false;
				btnSavedSearchDelete.Enabled = false;
				lblCurrentSearch.Text = String.Empty;
				lblCurrentXML.Text = String.Empty;
			}
			else
			{
				btnSavedSearchUpdate.Enabled = true;
				btnSavedSearchDelete.Enabled = true;
				lblCurrentSearch.Text = "\"" + lstSavedSearches.SelectedItem.Text + "\"";
				lblCurrentXML.Text = String.Empty;
#if DEBUG
				DataView vwSavedSearches = new DataView(SplendidCache.SavedSearch(m_sMODULE));
				vwSavedSearches.RowFilter = "ID = '" + lstSavedSearches.SelectedValue + "'";
				if ( vwSavedSearches.Count > 0 )
				{
					string sXML = Sql.ToString(vwSavedSearches[0]["CONTENTS"]);
					lblCurrentXML.Text = Server.HtmlEncode(sXML);
				}
#endif
			}
			if ( Command != null )
			{
				// 12/08/2007 Paul.  We need to make sure the table is rebound after the view change event. 
				CommandEventArgs eSearch = new CommandEventArgs("Search", null);
				Command(sender, eSearch);
			}
		}

		protected void Page_Command(object sender, CommandEventArgs e)
		{
			if ( e.CommandName == "AdvancedSearch" )
			{
				// 02/21/2018 Paul.  Make sure to maintain the ArchiveView state. 
				Response.Redirect(Page.AppRelativeVirtualPath + "?Advanced=1" + (ArchiveViewEnabled() ? "&ArchiveView=1" : String.Empty));
			}
			else if ( e.CommandName == "BasicSearch" )
			{
				// 02/21/2018 Paul.  Make sure to maintain the ArchiveView state. 
				Response.Redirect(Page.AppRelativeVirtualPath + "?Advanced=0" + (ArchiveViewEnabled() ? "&ArchiveView=1" : String.Empty));
			}
			else if ( e.CommandName == "Clear" )
			{
				// 12/17/2007 Paul.  Clear the sort order as well. 
				CommandEventArgs eSortGrid = new CommandEventArgs("SortGrid", null);
				Command(this, eSortGrid);
				// 12/04/2007 Paul.  Clearing the form is not needed as the redirect will do the same. 
				// However, when we start to save the last search view, that is when the clear will be useful. 
				ClearForm();
				// 02/23/2008 Paul.  We must also clear the saved search, otherwise it will re-apply its saved values. 
				lstSavedSearches.SelectedIndex = 0;
				// 12/09/2007 Paul.  We have to save the cleared form, otherwise the default view will restore settings. 
				// 08/12/2009 Paul.  A customer wants the ability to turn off the saved searches, both globally and on a per user basis. 
				// 04/09/2011 Paul.  The DashletReport must always save its settings, otherwise it will forget the selected report. 
				// 09/13/2011 Paul.  We don't want to save the search in a popup.
				if ( SaveEnabled() && (!bIsPopupSearch && bShowSearchViews) )
					SaveDefaultView();
				// 06/20/2010 Paul.  When inside a subpanel, we cannot use Transfer. 
				Command(this, e);
				// 08/05/2018 Paul.  Need to retain the ArchiveView flag. 
				if ( !bIsSubpanelSearch )
					Server.Transfer(Page.AppRelativeVirtualPath + "?Advanced=" + nAdvanced.ToString() + (ArchiveView() ? "&ArchiveView=1" : String.Empty));
			}
			else if ( e.CommandName == "SavedSearch.Save" )
			{
				txtSavedSearchName.Text = txtSavedSearchName.Text.Trim();
				if ( Sql.IsEmptyString(txtSavedSearchName.Text) )
				{
					lblSavedNameRequired.Visible =true;
				}
				else
				{
					try
					{
						string sXML = GenerateSavedSearch(false);

						Guid gID = Guid.Empty;
						// 09/01/2010 Paul.  Store a copy of the DEFAULT_SEARCH_ID in the table so that we don't need to read the XML in order to get the value. 
						SqlProcs.spSAVED_SEARCH_Update(ref gID, Security.USER_ID, txtSavedSearchName.Text, m_sMODULE, sXML, String.Empty, Guid.Empty);

						// 12/14/2007 Paul.  The sort may have changed, so send an update event. 
						if ( !Sql.IsEmptyString(lstColumns.SelectedValue) && (radSavedSearchASC.Checked || radSavedSearchDESC.Checked) )
						{
							string[] arrSort = new string[] { lstColumns.SelectedValue, (radSavedSearchASC.Checked ? "asc" : "desc") };
							CommandEventArgs eSortGrid = new CommandEventArgs("SortGrid", arrSort);
							Command(this, eSortGrid);
						}
						RefreshSavedSearches(gID);
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
						lblError.Text = ex.Message;
					}
				}
			}
			else if ( e.CommandName == "SavedSearch.Update" )
			{
				try
				{
					string sXML = GenerateSavedSearch(false);

					Guid gID = Sql.ToGuid(lstSavedSearches.SelectedItem.Value);
					// 09/01/2010 Paul.  Store a copy of the DEFAULT_SEARCH_ID in the table so that we don't need to read the XML in order to get the value. 
					SqlProcs.spSAVED_SEARCH_Update(ref gID, Security.USER_ID, txtSavedSearchName.Text, m_sMODULE, sXML, String.Empty, Guid.Empty);

					// 12/14/2007 Paul.  The sort may have changed, so send an update event. 
					if ( !Sql.IsEmptyString(lstColumns.SelectedValue) && (radSavedSearchASC.Checked || radSavedSearchDESC.Checked) )
					{
						string[] arrSort = new string[] { lstColumns.SelectedValue, (radSavedSearchASC.Checked ? "asc" : "desc") };
						CommandEventArgs eSortGrid = new CommandEventArgs("SortGrid", arrSort);
						Command(this, eSortGrid);
					}
					RefreshSavedSearches(gID);
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					lblError.Text = ex.Message;
				}
			}
			else if ( e.CommandName == "SavedSearch.Delete" )
			{
				try
				{
					Guid gID = Sql.ToGuid(lstSavedSearches.SelectedItem.Value);
					SqlProcs.spSAVED_SEARCH_Delete(gID);
					// 09/02/2010 Paul.  We don't want to reset the sort column or the sort direction on Update or Save, just delete. 
					lstColumns.SelectedIndex = 0;
					radSavedSearchASC.Checked = true;
					RefreshSavedSearches(Guid.Empty);
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					lblError.Text = ex.Message;
				}
			}
			else if ( e.CommandName == "Search" )
			{
				// 06/27/2009 Paul.  On the home page, we don't want to show search views, but we do want to auto-save. 
				// 08/12/2009 Paul.  A customer wants the ability to turn off the saved searches, both globally and on a per user basis. 
				// 04/09/2011 Paul.  The DashletReport must always save its settings, otherwise it will forget the selected report. 
				if ( SaveEnabled() && (bAutoSaveSearch || (!bIsPopupSearch && bShowSearchViews)) )
					SaveDefaultView();
				if ( Command != null )
					Command(this, e) ;
			}
			else if ( Command != null )
				Command(this, e) ;
		}

		public void RefreshSavedSearches(Guid gID)
		{
			txtSavedSearchName.Text = String.Empty;
			// 09/02/2010 Paul.  We don't want to reset the sort column or the sort direction on Update or Save, just delete. 
			//lstColumns.SelectedIndex = 0;
			//radSavedSearchASC.Checked = true;
			SplendidCache.ClearSavedSearch(m_sMODULE);
			
			DataView vwSavedSearch = new DataView(SplendidCache.SavedSearch(m_sMODULE));
			vwSavedSearch.RowFilter = "NAME is not null";
			lstSavedSearches.DataSource = vwSavedSearch;
			lstSavedSearches.DataBind();
			lstSavedSearches.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));

			// 06/17/2008 Paul.  A customer reported a problem with a deleted saved search item throwing an exception. 
			// This seems like the only place that could cause the problem. 
			try
			{
				if ( Sql.IsEmptyGuid(gID) )
				{
					lstSavedSearches.SelectedIndex = 0;
				}
				else
				{
					// 08/19/2010 Paul.  Check the list before assigning the value. 
					Utils.SetSelectedValue(lstSavedSearches, gID.ToString());
				}
			}
			catch
			{
			}
			lstSavedSearches_Changed(lstSavedSearches, null);
		}

		public void InitializeDynamicView()
		{
			// 10/22/2010 Paul.  Allow the module to be defined later in the pipeline. 
			// We need this in the RulesWizard where the module is dynamic. 
			if ( Sql.IsEmptyString(m_sMODULE) )
				return;

			// 09/01/2010 Paul.  We need to move the lstSavedSearches binding to InitializeDynamicView. 
			// This should solve the problem with the listbox not getting set properly. 
			if ( !IsPostBack )
			{
				DataView vwSavedSearch = new DataView(SplendidCache.SavedSearch(m_sMODULE));
				vwSavedSearch.RowFilter = "NAME is not null";
				lstSavedSearches.DataSource = vwSavedSearch;
				lstSavedSearches.DataBind();
				lstSavedSearches.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
			}
			// 12/04/2007 Paul.  We need to be able to initialize the view manually as the OnInit event occurs before we have had a chance to set the mode. 
			sSEARCH_VIEW = m_sMODULE + "." + sSearchMode + (this.IsMobile ? ".Mobile" : "");
			if ( !String.IsNullOrEmpty(m_sMODULE) && !String.IsNullOrEmpty(sSearchMode) )
			{
				// 10/13/2011 Paul.  Special list of EditViews for the search area with IS_MULTI_SELECT. 
				// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
				// 05/10/2016 Paul.  Must not re-declare the dtFields variable. 
				dtFields = SplendidCache.EditViewFields(sSEARCH_VIEW, Security.PRIMARY_ROLE_NAME, true);
				// 04/10/2011 Paul.  Allow the report dashlets to add fields. 
				if ( EditViewLoaded != null )
				{
					// 04/15/2011 Paul.  We need to clone the data table, otherwise changes would be propagated across dashlets. 
					dtFields = dtFields.Clone();
					EditViewLoaded(dtFields);
				}
				// 06/20/2010 Paul.  We don't need to populate the EditViewFields if there are no records. 
				if ( dtFields.Rows.Count > 0 )
				{
					tblSearch.Rows.Clear();
					// 01/24/2008 Paul.  AppendEditViewFields was recently modified to append .Mobile to the name, so make sure it is not appended twice. 
					//this.AppendEditViewFields(m_sMODULE + "." + sSearchMode, tblSearch, null, btnSearch.ClientID);
					// 06/20/2010 Paul.  Use the existing table should be more efficient. 
					SplendidDynamic.AppendEditViewFields(dtFields.DefaultView, tblSearch, null, GetL10n(), GetT10n(), null, false, btnSearch.ClientID);
					
					// 05/02/2014 Kevin.  Add support for Business Rules Engine in the SearchView. 
					this.ApplyEditViewNewEventRules(sSEARCH_VIEW);
					
					string sVIEW_NAME = Sql.ToString(dtFields.Rows[0]["VIEW_NAME"]);
					DataTable dtColumns = SplendidCache.SearchColumns(sVIEW_NAME).Copy();
					foreach(DataRow row in dtColumns.Rows)
					{
						// 07/04/2006 Paul.  Some columns have global terms. 
						row["DISPLAY_NAME"] = Utils.TableColumnName(L10n, m_sMODULE, Sql.ToString(row["DISPLAY_NAME"]));
					}
					
					DataView vwColumns = new DataView(dtColumns);
					vwColumns.Sort = "DISPLAY_NAME";
					lstColumns.DataSource = vwColumns;
					lstColumns.DataBind();
					lstColumns.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
					
					if ( nAdvanced == 2 )
					{
						lstDuplicateColumns.DataSource = vwColumns;
						lstDuplicateColumns.DataBind();
					}
				}
				else
				{
					// 06/20/2010 Paul.  If there are no fields, then hide the SearchView panel. 
					this.Visible = false;
				}
			}
		}

		public virtual void ClearForm()
		{
			if ( dtFields != null )
			{
				foreach(DataRowView row in dtFields.DefaultView)
				{
					string sFIELD_TYPE        = Sql.ToString (row["FIELD_TYPE"       ]);
					string sDATA_FIELD        = Sql.ToString (row["DATA_FIELD"       ]);
					string sDISPLAY_FIELD     = Sql.ToString (row["DISPLAY_FIELD"    ]);
					int    nFORMAT_MAX_LENGTH = Sql.ToInteger(row["FORMAT_MAX_LENGTH"]);
					// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
					if ( (sDATA_FIELD == "TEAM_ID" || sDATA_FIELD == "TEAM_SET_NAME") )
					{
						if ( Crm.Config.enable_team_management() && !Crm.Config.enable_dynamic_teams() && sFIELD_TYPE == "TeamSelect" )
						{
							sDATA_FIELD     = "TEAM_ID";
							sDISPLAY_FIELD  = "TEAM_NAME";
							sFIELD_TYPE     = "ModulePopup";
							//sMODULE_TYPE    = "Teams";
						}
					}
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					if ( (sDATA_FIELD == "ASSIGNED_USER_ID" || sDATA_FIELD == "ASSIGNED_SET_NAME") )
					{
						if ( !Crm.Config.enable_dynamic_assignment() && sFIELD_TYPE == "UserSelect" )
						{
							sDATA_FIELD     = "USER_ID";
							sDISPLAY_FIELD  = "USER_NAME";
							sFIELD_TYPE     = "ModulePopup";
							//sMODULE_TYPE    = "Users";
						}
					}
					DynamicControl ctl = new DynamicControl(this, sDATA_FIELD);
					if ( ctl != null )
					{
						// 04/09/2011 Paul.  Change the field to a hidden field so that we can add Report Parameters. 
						if ( sFIELD_TYPE == "Hidden" )
						{
							ctl.Text = String.Empty;
						}
						// 04/05/2012 Paul.  Add searching support for checkbox list. 
						else if ( sFIELD_TYPE == "ListBox" || sFIELD_TYPE == "CheckBoxList" || sFIELD_TYPE == "Radio" )
						{
							ListControl lst = FindControl(sDATA_FIELD) as ListControl;
							if ( lst != null )
							{
								// 06/17/2010 Paul.  Add support for RadioButtonList and CheckBoxList. 
								if ( lst is ListBox || lst is RadioButtonList || lst is CheckBoxList )
								{
									// 12/12/2007 Paul.  ClearSelection is the correct way to reset a ListBox. 
									lst.ClearSelection();
								}
								else if ( lst is DropDownList )
								{
									// 12/13/2007 Paul.  Clear a drop-down by selecting the top item. 
									lst.ClearSelection();
									lst.SelectedIndex = 0;
								}
							}
						}
						else if ( sFIELD_TYPE == "DatePicker" )
						{
							// 01/01/2018 Paul.  Allow searching of multiple date fields. 
							DatePicker ctlDate = FindControl(sDATA_FIELD.Replace(" ", "_")) as DatePicker;
							if ( ctlDate != null )
							{
								ctlDate.DateText = String.Empty;
							}
						}
						else if ( sFIELD_TYPE == "DateRange" )
						{
							// 01/01/2018 Paul.  Allow searching of multiple date fields. 
							DatePicker ctlDateStart = FindControl(sDATA_FIELD.Replace(" ", "_") + "_AFTER") as DatePicker;
							if ( ctlDateStart != null )
							{
								ctlDateStart.DateText = String.Empty;
							}
							// 01/01/2018 Paul.  Allow searching of multiple date fields. 
							DatePicker ctlDateEnd = FindControl(sDATA_FIELD.Replace(" ", "_") + "_BEFORE") as DatePicker;
							if ( ctlDateEnd != null )
							{
								ctlDateEnd.DateText = String.Empty;
							}
						}
						else if ( sFIELD_TYPE == "CheckBox" )
						{
							ctl.Checked = false;
						}
						// 04/13/2016 Paul.  Add ZipCode lookup. 
						else if ( sFIELD_TYPE == "TextBox" || sFIELD_TYPE == "ZipCodePopup" )
						{
							ctl.Text = String.Empty;
						}
						else if ( sFIELD_TYPE == "ChangeButton" || sFIELD_TYPE == "ModulePopup" )
						{
							ctl.Text = String.Empty;
							DynamicControl ctlDISPLAY_FIELD = new DynamicControl(this, sDISPLAY_FIELD);
							if ( ctlDISPLAY_FIELD != null )
								ctlDISPLAY_FIELD.Text = String.Empty;
						}
						else if ( sFIELD_TYPE == "TeamSelect" )
						{
							TeamSelect ctlTeamSelect = FindControl(sDATA_FIELD) as TeamSelect;
							if ( ctlTeamSelect != null )
							{
								ctlTeamSelect.Clear();
							}
						}
						// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
						else if ( sFIELD_TYPE == "UserSelect" )
						{
							UserSelect ctlUserSelect = FindControl(sDATA_FIELD) as UserSelect;
							if ( ctlUserSelect != null )
							{
								ctlUserSelect.Clear();
							}
						}
						// 05/12/2016 Paul.  Add Tags module. 
						else if ( sFIELD_TYPE == "TagSelect" )
						{
							TagSelect ctlTagSelect = FindControl(sDATA_FIELD) as TagSelect;
							if ( ctlTagSelect != null )
							{
								ctlTagSelect.Clear();
							}
						}
						// 06/07/2017 Paul.  Add NAICSCodes module. 
						else if ( sFIELD_TYPE == "NAICSCodeSelect" )
						{
							NAICSCodeSelect ctlNAICSCodeSelect = FindControl(sDATA_FIELD) as NAICSCodeSelect;
							if ( ctlNAICSCodeSelect != null )
							{
								ctlNAICSCodeSelect.Clear();
							}
						}
						else if ( sFIELD_TYPE == "ModuleAutoComplete" )
						{
							ctl.Text = String.Empty;
						}
					}
				}
				if ( nAdvanced == 2 )
				{
					foreach ( ListItem item in lstDuplicateColumns.Items )
						item.Selected = false;
				}
			}
		}

		// 02/08/2008 Paul.  We need to build a list of the fields used by the search clause. 
		// 02/08/2008 Paul.  Search fields do not need to be in the select list. 
		// 06/27/2009 Paul.  Return TRUE if search was loaded. 
		public bool SqlSearchClause(IDbCommand cmd)
		{
			bool bSearchLoaded = false;
			if ( dtFields == null )
				InitializeDynamicView();
			// 06/20/2010 Paul.  We can skip this logic if there are no fields. 
			if ( dtFields != null && dtFields.Rows.Count > 0 )
			{
				// 12/28/2007 Paul.  Disable the auto-save in a popup. 
				// 06/27/2009 Paul.  On the home page, we don't want to show search views, but we do want to auto-save. 
				if ( bAutoSaveSearch || (!bIsPopupSearch && bShowSearchViews) )
				{
					// 12/08/2007 Paul.  By apply the saved search here, we can automatically apply across old code. 
					// 08/12/2009 Paul.  A customer wants the ability to turn off the saved searches, both globally and on a per user basis. 
					// 03/04/2010 Paul.  We need to remember if we were successful loading the search, otherwise the Assigned-User code in the My* dashlets would get applied. 
					// 04/09/2011 Paul.  The DashletReport must always save its settings, otherwise it will forget the selected report. 
					if ( SavedSearchesChanged() || (SaveEnabled() && !IsPostBack) )
					{
						bSearchLoaded = ApplySavedSearch();
						ViewState["SearchLoaded"] = bSearchLoaded;
					}
					else
					{
						bSearchLoaded = Sql.ToBoolean(ViewState["SearchLoaded"]);
					}
				}

				foreach(DataRowView row in dtFields.DefaultView)
				{
					string sEDIT_NAME         = Sql.ToString (row["EDIT_NAME"        ]);
					string sFIELD_TYPE        = Sql.ToString (row["FIELD_TYPE"       ]);
					string sDATA_FIELD        = Sql.ToString (row["DATA_FIELD"       ]);
					// 10/19/2016 Paul.  DATA_FORMAT will be FullText to indicate full-text search. 
					string sDATA_FORMAT       = Sql.ToString (row["DATA_FORMAT"      ]);
					int    nFORMAT_MAX_LENGTH = Sql.ToInteger(row["FORMAT_MAX_LENGTH"]);
					int    nFORMAT_ROWS       = Sql.ToInteger(row["FORMAT_ROWS"      ]);
					// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
					if ( (sDATA_FIELD == "TEAM_ID" || sDATA_FIELD == "TEAM_SET_NAME") )
					{
						if ( Crm.Config.enable_team_management() && !Crm.Config.enable_dynamic_teams() && sFIELD_TYPE == "TeamSelect" )
						{
							sDATA_FIELD     = "TEAM_ID";
							//sDISPLAY_FIELD  = "TEAM_NAME";
							sFIELD_TYPE     = "ModulePopup";
							//sMODULE_TYPE    = "Teams";
						}
					}
					// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
					if ( (sDATA_FIELD == "ASSIGNED_USER_ID" || sDATA_FIELD == "ASSIGNED_SET_NAME") )
					{
						if ( !Crm.Config.enable_dynamic_assignment() && sFIELD_TYPE == "UserSelect" )
						{
							sDATA_FIELD     = "USER_ID";
							//sDISPLAY_FIELD  = "USER_NAME";
							sFIELD_TYPE     = "ModulePopup";
							//sMODULE_TYPE    = "Users";
						}
					}
					DynamicControl ctl = new DynamicControl(this, sDATA_FIELD);
					if ( ctl != null )
					{
						// 04/09/2011 Paul.  Change the field to a hidden field so that we can add Report Parameters. 
						if ( sFIELD_TYPE == "Hidden" )
						{
							Sql.AppendParameter(cmd, ctl.Text, sDATA_FIELD);
						}
						// 11/17/2019 Paul.  Radio stores a single value, not XML. 
						else if ( sFIELD_TYPE == "Radio" )
						{
							Sql.AppendParameter(cmd, ctl.Text, sDATA_FIELD);
						}
						// 04/05/2012 Paul.  Add searching support for checkbox list. 
						else if ( sFIELD_TYPE == "CheckBoxList" )
						{
							ListControl lst = FindControl(sDATA_FIELD) as ListControl;
							if ( lst != null )
							{
								int nSelected = 0;
								foreach(ListItem item in lst.Items)
								{
									if ( item.Selected )
										nSelected++;
								}
								if ( nSelected > 0 )
								{
									List<string> arr = new List<string>();
									foreach(ListItem item in lst.Items)
									{
										if ( item.Selected )
										{
											if ( item.Value.Length > 0 )
											{
												arr.Add("<Value>" + Sql.EscapeXml(item.Value) + "</Value>");
											}
											else
											{
												// 10/13/2011 Paul.  A multi-selection list box does not have NULL, so look for any empty value. 
												arr.Add("<Value></Value>");
											}
										}
									}
									Sql.AppendLikeParameters(cmd, arr.ToArray(), sDATA_FIELD);
								}
							}
						}
						else if ( sFIELD_TYPE == "ListBox" )
						{
							// 10/13/2011 Paul.  Special list of EditViews for the search area with IS_MULTI_SELECT. 
							bool bIS_MULTI_SELECT = false;
							try
							{
								bIS_MULTI_SELECT = Sql.ToBoolean(row["IS_MULTI_SELECT"]);
							}
							catch(Exception ex)
							{
								SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
							}
							ListControl lst = FindControl(sDATA_FIELD) as ListControl;
							if ( lst != null )
							{
								int nSelected = 0;
								foreach(ListItem item in lst.Items)
								{
									if ( item.Selected )
										nSelected++;
								}
								// 01/10/2008 Paul.  When drawing the search dialog the first time (not postback), 
								// we need to assume the the first item is selected if it is DropDownList. 
								if ( !IsPostBack && lst is DropDownList && lst.Items.Count > 0 && nSelected == 0 )
								{
									lst.SelectedIndex = 0;
									nSelected = 1;
								}
								// 12/03/2007 Paul.  If the NONE item is selected, then search for value of NULL. 
								// 12/03/2017 Paul.  Need to use the full build if using dynamic teams or dynamic assignments. 
								if ( nSelected == 1 && String.IsNullOrEmpty(lst.SelectedValue) && !(sDATA_FIELD == "TEAM_ID" && Crm.Config.enable_dynamic_teams() || sDATA_FIELD == "ASSIGNED_USER_ID" && Crm.Config.enable_dynamic_assignment()) )
								{
									if ( sDATA_FIELD.IndexOf(' ') > 0 )
									{
										cmd.CommandText += "   and (1 = 0";
										foreach ( string sField in sDATA_FIELD.Split(' ') )
										{
											cmd.CommandText += "        or " + sField + " is null";
										}
										cmd.CommandText += ")";
									}
									else
										cmd.CommandText += "   and " + sDATA_FIELD + " is null" + ControlChars.CrLf;
								}
								else if ( nSelected > 0 )
								{
									if ( sDATA_FIELD.IndexOf(' ') > 0 )
									{
										cmd.CommandText += "   and (1 = 0" + ControlChars.CrLf;
										foreach ( string sField in sDATA_FIELD.Split(' ') )
										{
											cmd.CommandText += "        or (1 = 1";
											// 03/04/2009 Paul.  Need to allow NULL or the selected values. 
											// 10/13/2011 Paul.  Special list of EditViews for the search area with IS_MULTI_SELECT. 
											if ( bIS_MULTI_SELECT )
											{
												List<string> arr = new List<string>();
												foreach(ListItem item in lst.Items)
												{
													if ( item.Selected )
													{
														if ( item.Value.Length > 0 )
														{
															// 04/05/2012 Paul.  Enclose in tags so that the search is more exact. 
															arr.Add("<Value>" + Sql.EscapeXml(item.Value) + "</Value>");
														}
														else
														{
															//bIncludeNull = true;
															// 10/13/2011 Paul.  A multi-selection list box does not have NULL, so look for any empty value. 
															arr.Add("<Value></Value>");
														}
													}
												}
												Sql.AppendLikeParameters(cmd, arr.ToArray(), sField);
											}
											else
											{
												Sql.AppendParameterWithNull(cmd, lst, sField);
											}
											cmd.CommandText += "           )" + ControlChars.CrLf;
										}
										cmd.CommandText += "       )" + ControlChars.CrLf;
									}
									// 08/25/2009 Paul.  Add support for dynamic teams. 
									else if ( sDATA_FIELD == "TEAM_ID" )
									{
										if ( Crm.Config.enable_dynamic_teams() )
										{
											cmd.CommandText += "   and TEAM_SET_ID in (select MEMBERSHIP_TEAM_SET_ID" + ControlChars.CrLf;
											cmd.CommandText += "                         from vwTEAM_SET_MEMBERSHIPS" + ControlChars.CrLf;
											cmd.CommandText += "                        where 1 = 1                 " + ControlChars.CrLf;
											cmd.CommandText += "                       ";
											Sql.AppendParameterWithNull(cmd, lst, "MEMBERSHIP_TEAM_ID");
											cmd.CommandText += "                      )" + ControlChars.CrLf;
										}
										// 05/11/2010 Paul.  If we are in a list, then it does not make sense to get a single ID. 
										//else if ( !Sql.IsEmptyGuid(ctl.ID) )
										//{
										//	Sql.AppendParameter(cmd, ctl.ID, sDATA_FIELD);
										//}
										else
										{
											Sql.AppendParameterWithNull(cmd, lst, sDATA_FIELD);
										}
									}
									// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
									else if ( sDATA_FIELD == "ASSIGNED_USER_ID" )
									{
										if ( Crm.Config.enable_dynamic_assignment() )
										{
											cmd.CommandText += "   and ASSIGNED_SET_ID in (select MEMBERSHIP_ASSIGNED_SET_ID" + ControlChars.CrLf;
											cmd.CommandText += "                             from vwASSIGNED_SET_MEMBERSHIPS" + ControlChars.CrLf;
											cmd.CommandText += "                            where 1 = 1                     " + ControlChars.CrLf;
											cmd.CommandText += "                           ";
											Sql.AppendParameterWithNull(cmd, lst, "MEMBERSHIP_ASSIGNED_USER_ID");
											cmd.CommandText += "                          )" + ControlChars.CrLf;
										}
										else
										{
											Sql.AppendParameterWithNull(cmd, lst, sDATA_FIELD);
										}
									}
									// 04/25/2013 Paul.  Special list of EditViews for the search area with IS_MULTI_SELECT. 
									else if ( bIS_MULTI_SELECT )
									{
										List<string> arr = new List<string>();
										foreach(ListItem item in lst.Items)
										{
											if ( item.Selected )
											{
												if ( item.Value.Length > 0 )
												{
													// 04/05/2012 Paul.  Enclose in tags so that the search is more exact. 
													arr.Add("<Value>" + Sql.EscapeXml(item.Value) + "</Value>");
												}
												else
												{
													//bIncludeNull = true;
													// 10/13/2011 Paul.  A multi-selection list box does not have NULL, so look for any empty value. 
													arr.Add("<Value></Value>");
												}
											}
										}
										Sql.AppendLikeParameters(cmd, arr.ToArray(), sDATA_FIELD);
									}
									else
									{
										// 03/04/2009 Paul.  Need to allow NULL or the selected values. 
										Sql.AppendParameterWithNull(cmd, lst, sDATA_FIELD);
									}
								}
							}
							// 04/09/2011 Paul.  Change the field to a hidden field so that we can add Report Parameters. 
							// Instead of updating the SAVED_SEARCH data, just redirect the data. 
							else if ( FindControl(sDATA_FIELD) is HtmlInputHidden )
							{
								Sql.AppendParameter(cmd, ctl.Text, sDATA_FIELD);
							}
						}
						else if ( sFIELD_TYPE == "DatePicker" )
						{
							// 01/01/2018 Paul.  Allow searching of multiple date fields. 
							DatePicker ctlDate = FindControl(sDATA_FIELD.Replace(" ", "_")) as DatePicker;
							if ( ctlDate != null )
							{
								if ( !Sql.IsEmptyString(ctlDate.DateText) )
								{
									// 01/01/2018 Paul.  Allow searching of multiple date fields. 
									if ( sDATA_FIELD.IndexOf(' ') > 0 )
										Sql.AppendParameter(cmd, ctlDate.Value, sDATA_FIELD.Split(' '));
									else
										Sql.AppendParameter(cmd, ctlDate.Value, sDATA_FIELD);
								}
							}
						}
						else if ( sFIELD_TYPE == "DateRange" )
						{
							// 01/01/2018 Paul.  Allow searching of multiple date fields. 
							DatePicker ctlDateStart = FindControl(sDATA_FIELD.Replace(" ", "_") + "_AFTER" ) as DatePicker;
							DatePicker ctlDateEnd   = FindControl(sDATA_FIELD.Replace(" ", "_") + "_BEFORE") as DatePicker;
							DateTime dtDateStart = DateTime.MinValue;
							DateTime dtDateEnd   = DateTime.MinValue;
							if ( ctlDateStart != null )
							{
								if ( !Sql.IsEmptyString(ctlDateStart.DateText) )
								{
									dtDateStart = ctlDateStart.Value;
								}
							}
							if ( ctlDateEnd != null )
							{
								if ( !Sql.IsEmptyString(ctlDateEnd.DateText) )
								{
									dtDateEnd = ctlDateEnd.Value;
								}
							}
							if ( dtDateStart != DateTime.MinValue ||dtDateEnd != DateTime.MinValue )
							{
								// 01/01/2018 Paul.  Allow searching of multiple date fields. 
								if ( sDATA_FIELD.IndexOf(' ') > 0 )
									Sql.AppendParameter(cmd, dtDateStart, dtDateEnd, sDATA_FIELD.Split(' '));
								else
									Sql.AppendParameter(cmd, dtDateStart, dtDateEnd, sDATA_FIELD);
							}
						}
						else if ( sFIELD_TYPE == "CheckBox" )
						{
							// 12/02/2007 Paul.  Only search for checked fields if they are checked. 
							if ( ctl.Checked )
							{
								// 12/02/2007 Paul.  Unassigned checkbox has a special meaning. 
								if ( sDATA_FIELD == "UNASSIGNED_ONLY" )
								{
									// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
									if ( Crm.Config.enable_dynamic_assignment() )
									{
										cmd.CommandText += "   and ASSIGNED_SET_ID is null" + ControlChars.CrLf;
									}
									else
									{
										// 10/04/2006 Paul.  Add flag to show only records that are not assigned. 
										cmd.CommandText += "   and ASSIGNED_USER_ID is null" + ControlChars.CrLf;
									}
								}
								else if ( sDATA_FIELD == "CURRENT_USER_ONLY" )
								{
									// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
									if ( Crm.Config.enable_dynamic_assignment() )
									{
										cmd.CommandText += "   and ASSIGNED_SET_ID in (select MEMBERSHIP_ASSIGNED_SET_ID" + ControlChars.CrLf;
										cmd.CommandText += "                             from vwASSIGNED_SET_MEMBERSHIPS" + ControlChars.CrLf;
										cmd.CommandText += "                            where 1 = 1                     " + ControlChars.CrLf;
										cmd.CommandText += "                              ";
										Sql.AppendParameter(cmd, Security.USER_ID, "MEMBERSHIP_ASSIGNED_USER_ID");
										cmd.CommandText += "                          )" + ControlChars.CrLf;
									}
									else
									{
										Sql.AppendParameter(cmd, Security.USER_ID, "ASSIGNED_USER_ID", false);
									}
								}
								// 03/31/2012 Paul.  FAVORITE_RECORD_ID has a special meaning. 
								else if ( sDATA_FIELD == "FAVORITE_RECORD_ID" )
								{
									cmd.CommandText += "   and FAVORITE_RECORD_ID is not null" + ControlChars.CrLf;
								}
								else
								{
									// 04/27/2008 Paul.  The boolean AppendParameter now requires the IsEmpty flag. 
									// In this case, it is false when the value is checked. 
									Sql.AppendParameter(cmd, ctl.Checked, sDATA_FIELD, !ctl.Checked);
								}
							}
						}
						// 10/19/2016 Paul.  DATA_FORMAT will be FullText to indicate full-text search. 
						else if ( sFIELD_TYPE == "TextBox" )
						{
							string sMODULE_NAME = sEDIT_NAME.Split('.')[0];
							// 10/19/2016 Paul.  A full-text query needs to be a subquery as it is too complicated to create an indexed view. 
							if ( sDATA_FORMAT.ToLower().StartsWith("fulltext") )
							{
								string[] arrDATA_FORMAT = sDATA_FORMAT.Split(' ');
								string sFULL_TEXT_TABLE = String.Empty;
								string sFULL_TEXT_FIELD = String.Empty;
								string sFULL_TEXT_KEY   = String.Empty;
								if ( arrDATA_FORMAT.Length >= 2 )
								{
									sFULL_TEXT_TABLE = arrDATA_FORMAT[1];
								}
								if ( String.Compare(sFULL_TEXT_TABLE, "Documents", true) == 0 )
								{
									sFULL_TEXT_TABLE = "DOCUMENT_REVISIONS";
									sFULL_TEXT_FIELD = "CONTENT"           ;
									sFULL_TEXT_KEY   = "DOCUMENT_ID"       ;
								}
								else if ( String.Compare(sFULL_TEXT_TABLE, "Notes", true) == 0 )
								{
									sFULL_TEXT_TABLE = "NOTE_ATTACHMENTS";
									sFULL_TEXT_FIELD = "ATTACHMENT"      ;
									sFULL_TEXT_KEY   = "NOTE_ID"         ;
								}
								// 10/24/2016 Paul.  KBDocuments use the NOTE_ATTACHMENTS table for attachments and EMAIL_IMAGES table for images. 
								else if ( String.Compare(sFULL_TEXT_TABLE, "KBDocuments", true) == 0 )
								{
									sFULL_TEXT_TABLE = "NOTE_ATTACHMENTS";
									sFULL_TEXT_FIELD = "ATTACHMENT"      ;
									sFULL_TEXT_KEY   = "NOTE_ID"         ;
								}
								else if ( arrDATA_FORMAT.Length >= 4 )
								{
									sFULL_TEXT_FIELD = arrDATA_FORMAT[2];
									sFULL_TEXT_KEY   = arrDATA_FORMAT[3];
								}
								if ( !Sql.IsEmptyString(ctl.Text) && !Sql.IsEmptyString(sFULL_TEXT_TABLE) && !Sql.IsEmptyString(sFULL_TEXT_FIELD) && !Sql.IsEmptyString(sFULL_TEXT_KEY) )
								{
									cmd.CommandText += "   and ID in (select " + sFULL_TEXT_KEY + " from " + sFULL_TEXT_TABLE + " where contains(" + sFULL_TEXT_FIELD + ", @" + sFULL_TEXT_FIELD + "))" + ControlChars.CrLf;
									Sql.AddParameter(cmd, "@" + sFULL_TEXT_FIELD, ctl.Text, ctl.Text.Length);
								}
							}
							// 07/26/2018 Paul.  Allow a normalized phone search that used the special phone tables. 
							else if ( sDATA_FORMAT.ToLower().StartsWith("normalizedphone") && (sMODULE_NAME == "Accounts" || sMODULE_NAME == "Contacts" || sMODULE_NAME == "Leads" || sMODULE_NAME == "Prospects") )
							{
								if ( !Sql.IsEmptyString(ctl.Text) )
								{
									string sNORMALIZED_NUMBER = Utils.NormalizePhone(ctl.Text);
									//string vwNORMALIZED_VIEW  = "vwPHONE_NUMBERS_" + Crm.Modules.TableName(sMODULE_NAME);
									// 08/08/2018 Paul.  Use like clause for more flexible phone number lookup. 
									// 06/12/2020 Paul.  Use base view instead so that the filter will work in an archive view. 
									cmd.CommandText += "   and ID in (select PARENT_ID from vwPHONE_NUMBERS where NORMALIZED_NUMBER like @NORMALIZED_NUMBER)" + ControlChars.CrLf;
									Sql.AddParameter(cmd, "@NORMALIZED_NUMBER", sNORMALIZED_NUMBER + "%");
								}
							}
							// 09/20/2022 Paul.  Need a way to default to exact search.  Exclude if text contains any search builder token, including space. 
							else if ( sDATA_FORMAT.ToLower().StartsWith("exact") && !Sql.IsEmptyString(ctl.Text) && ctl.Text.IndexOfAny("=\"+-<>!\r\n\t ;,*".ToCharArray()) == -1 )
							{
								Sql.AppendParameter(cmd, ctl.Text, nFORMAT_MAX_LENGTH, Sql.SqlFilterMode.Exact, sDATA_FIELD);
							}
							else if ( sDATA_FIELD.IndexOf(' ') > 0 )
								Sql.AppendParameter(cmd, ctl.Text, nFORMAT_MAX_LENGTH, Sql.SqlFilterMode.StartsWith, sDATA_FIELD.Split(' '));
							else
								Sql.AppendParameter(cmd, ctl.Text, nFORMAT_MAX_LENGTH, Sql.SqlFilterMode.StartsWith, sDATA_FIELD);
						}
						// 04/13/2016 Paul.  Add ZipCode lookup. 
						else if ( sFIELD_TYPE == "ZipCodePopup" )
						{
							if ( sDATA_FIELD.IndexOf(' ') > 0 )
								Sql.AppendParameter(cmd, ctl.Text, nFORMAT_MAX_LENGTH, Sql.SqlFilterMode.StartsWith, sDATA_FIELD.Split(' '));
							else
								Sql.AppendParameter(cmd, ctl.Text, nFORMAT_MAX_LENGTH, Sql.SqlFilterMode.StartsWith, sDATA_FIELD);
						}
						else if ( sFIELD_TYPE == "ChangeButton" || sFIELD_TYPE == "ModulePopup" )
						{
							// 09/05/2010 Paul.  Also allow for a custom field to be treated as an ID. 
							if ( nFORMAT_MAX_LENGTH == 0 && (sDATA_FIELD.EndsWith("_ID") || sDATA_FIELD.EndsWith("_ID_C")) )
							{
								if ( !Sql.IsEmptyGuid(ctl.ID) )
								{
									// 08/25/2009 Paul.  Add support for dynamic teams. 
									if ( sDATA_FIELD == "TEAM_ID" || sDATA_FIELD == "TEAM_SET_NAME" )
									{
										if ( Crm.Config.enable_dynamic_teams() )
										{
											cmd.CommandText += "   and TEAM_SET_ID in (select MEMBERSHIP_TEAM_SET_ID" + ControlChars.CrLf;
											cmd.CommandText += "                         from vwTEAM_SET_MEMBERSHIPS" + ControlChars.CrLf;
											cmd.CommandText += "                        where 1 = 1                 " + ControlChars.CrLf;
											cmd.CommandText += "                       ";
											Sql.AppendParameter(cmd, ctl.ID, "MEMBERSHIP_TEAM_ID");
											cmd.CommandText += "                      )" + ControlChars.CrLf;
										}
										else
										{
											Sql.AppendParameter(cmd, ctl.ID, sDATA_FIELD);
										}

									}
									else
									{
										Sql.AppendParameter(cmd, ctl.ID, sDATA_FIELD);
									}
								}
							}
							else
							{
								Sql.AppendParameter(cmd, ctl.Text, nFORMAT_MAX_LENGTH, Sql.SqlFilterMode.StartsWith, sDATA_FIELD);
							}
						}
						else if ( sFIELD_TYPE == "TeamSelect" )
						{
							TeamSelect ctlTeamSelect = FindControl(sDATA_FIELD) as TeamSelect;
							if ( ctlTeamSelect != null )
							{
								if ( Crm.Config.enable_dynamic_teams() )
								{
									string sTEAM_SET_LIST = ctlTeamSelect.TEAM_SET_LIST;
									// 09/01/2009 Paul.  Make sure not to filter if nothing is selected. 
									if ( !Sql.IsEmptyString(sTEAM_SET_LIST) )
									{
										string[] arr = sTEAM_SET_LIST.Split(',');
										if ( arr.Length > 0 )
										{
											cmd.CommandText += "   and TEAM_SET_ID in (select MEMBERSHIP_TEAM_SET_ID" + ControlChars.CrLf;
											cmd.CommandText += "                         from vwTEAM_SET_MEMBERSHIPS" + ControlChars.CrLf;
											cmd.CommandText += "                        where 1 = 1                 " + ControlChars.CrLf;
											cmd.CommandText += "                       ";
											Sql.AppendGuids(cmd, arr, "MEMBERSHIP_TEAM_ID");
											cmd.CommandText += "                      )" + ControlChars.CrLf;
										}
									}
								}
								else
								{
									// 04/18/2010 Paul.  Make sure not to filter if nothing is selected. 
									if ( !Sql.IsEmptyGuid(ctlTeamSelect.TEAM_ID) )
										Sql.AppendParameter(cmd, ctlTeamSelect.TEAM_ID, "TEAM_ID");
								}
							}
						}
						// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
						else if ( sFIELD_TYPE == "UserSelect" )
						{
							UserSelect ctlUserSelect = FindControl(sDATA_FIELD) as UserSelect;
							if ( ctlUserSelect != null )
							{
								if ( Crm.Config.enable_dynamic_assignment() )
								{
									string sASSIGNED_SET_LIST = ctlUserSelect.ASSIGNED_SET_LIST;
									// 11/30/2017 Paul.  Make sure not to filter if nothing is selected. 
									if ( !Sql.IsEmptyString(sASSIGNED_SET_LIST) )
									{
										string[] arr = sASSIGNED_SET_LIST.Split(',');
										if ( arr.Length > 0 )
										{
											cmd.CommandText += "   and ASSIGNED_SET_ID in (select MEMBERSHIP_ASSIGNED_SET_ID" + ControlChars.CrLf;
											cmd.CommandText += "                             from vwASSIGNED_SET_MEMBERSHIPS" + ControlChars.CrLf;
											cmd.CommandText += "                            where 1 = 1                     " + ControlChars.CrLf;
											cmd.CommandText += "                              ";
											Sql.AppendGuids(cmd, arr, "MEMBERSHIP_ASSIGNED_USER_ID");
											cmd.CommandText += "                          )" + ControlChars.CrLf;
										}
									}
								}
								else
								{
									// 11/30/2017 Paul.  Make sure not to filter if nothing is selected. 
									if ( !Sql.IsEmptyGuid(ctlUserSelect.USER_ID) )
										Sql.AppendParameter(cmd, ctlUserSelect.USER_ID, "USER_ID");
								}
							}
						}
						// 05/12/2016 Paul.  Add Tags module. 
						else if ( sFIELD_TYPE == "TagSelect" )
						{
							TagSelect ctlTagSelect = FindControl(sDATA_FIELD) as TagSelect;
							if ( ctlTagSelect != null )
							{
								string sTAG_SET_NAME = ctlTagSelect.TAG_SET_NAME;
								if ( !Sql.IsEmptyString(sTAG_SET_NAME) )
								{
									string[] arr = sTAG_SET_NAME.Split(',');
									if ( arr.Length > 0 )
									{
										cmd.CommandText += "   and ID in (select BEAN_ID       " + ControlChars.CrLf;
										cmd.CommandText += "                from vwTAG_BEAN_REL" + ControlChars.CrLf;
										cmd.CommandText += "               where 1 = 0         " + ControlChars.CrLf;
										cmd.CommandText += "                  ";
										Sql.AppendParameter(cmd, arr, "TAG_NAME", true);
										cmd.CommandText += "             )" + ControlChars.CrLf;
									}
								}
							}
						}
						// 06/07/2017 Paul.  Add NAICSCodes module. 
						else if ( sFIELD_TYPE == "NAICSCodeSelect" )
						{
							NAICSCodeSelect ctlNAICSCodeSelect = FindControl(sDATA_FIELD) as NAICSCodeSelect;
							if ( ctlNAICSCodeSelect != null )
							{
								string sNAICS_SET_NAME = ctlNAICSCodeSelect.NAICS_SET_NAME;
								if ( !Sql.IsEmptyString(sNAICS_SET_NAME) )
								{
									string[] arr = sNAICS_SET_NAME.Split(',');
									if ( arr.Length > 0 )
									{
										cmd.CommandText += "   and ID in (select PARENT_ID            " + ControlChars.CrLf;
										cmd.CommandText += "                from vwNAICS_CODES_RELATED" + ControlChars.CrLf;
										cmd.CommandText += "               where 1 = 0                " + ControlChars.CrLf;
										cmd.CommandText += "                  ";
										Sql.AppendParameter(cmd, arr, "NAICS_CODE_NAME", true);
										cmd.CommandText += "             )" + ControlChars.CrLf;
									}
								}
							}
						}
						else if ( sFIELD_TYPE == "ModuleAutoComplete" )
						{
							Sql.AppendParameter(cmd, ctl.Text, nFORMAT_MAX_LENGTH, Sql.SqlFilterMode.StartsWith, sDATA_FIELD);
						}
					}
				}
				// 09/02/2010 Paul.  We need a second pass to set values specified in the Saved Search but not available in the EditView. 
				// 09/13/2011 Paul.  We don't want to apply the saved search in a popup. 
				if ( !Sql.IsEmptyString(lstSavedSearches.SelectedValue) && (!bIsPopupSearch && bShowSearchViews) )
				{
					DataView vwSavedSearches = new DataView(SplendidCache.SavedSearch(m_sMODULE));
					vwSavedSearches.RowFilter = "ID = '" + lstSavedSearches.SelectedValue + "'";
					if ( vwSavedSearches.Count > 0 )
					{
						string sXML = Sql.ToString(vwSavedSearches[0]["CONTENTS"]);
						if ( !Sql.IsEmptyString(sXML) )
						{
							XmlDocument xml = new XmlDocument();
							// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
							// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
							// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
							xml.XmlResolver = null;
							xml.LoadXml(sXML);
							XmlNodeList nlSearchFields = xml.DocumentElement.SelectNodes("SearchFields/Field");
							foreach ( XmlNode xField in nlSearchFields )
							{
								string sDATA_FIELD = XmlUtil.GetNamedItem(xField, "Name");
								string sFIELD_TYPE = XmlUtil.GetNamedItem(xField, "Type");
								if ( !Sql.IsEmptyString(sDATA_FIELD) )
								{
									DynamicControl ctl = new DynamicControl(this, sDATA_FIELD);
									if ( !ctl.Exists )
									{
										// 04/09/2011 Paul.  Change the field to a hidden field so that we can add Report Parameters. 
										if ( sFIELD_TYPE == "Hidden" )
										{
											Sql.AppendParameter(cmd, xField.InnerText, sDATA_FIELD);
										}
										else if ( sFIELD_TYPE == "ListBox" )
										{
											ListControl lst = FindControl(sDATA_FIELD) as ListControl;
											if ( lst == null )
											{
												// 06/17/2010 Paul.  Add support for RadioButtonList and CheckBoxList. 
												XmlNodeList nlValues = xField.SelectNodes("Value");
												if ( nlValues.Count > 0 )
												{
													string[] arr = new string[nlValues.Count];
													for ( int i = 0; i < nlValues.Count; i++ )
													{
														arr[i] = nlValues[i].InnerText;
													}
													
													if ( sDATA_FIELD.IndexOf(' ') > 0 )
													{
														cmd.CommandText += "   and (1 = 0" + ControlChars.CrLf;
														foreach ( string sField in sDATA_FIELD.Split(' ') )
														{
															cmd.CommandText += "        or (1 = 1";
															// 03/04/2009 Paul.  Need to allow NULL or the selected values. 
															Sql.AppendParameterWithNull(cmd, arr, sField);
															cmd.CommandText += "           )" + ControlChars.CrLf;
														}
														cmd.CommandText += "       )" + ControlChars.CrLf;
													}
													else
													{
														Sql.AppendParameterWithNull(cmd, arr, sDATA_FIELD);
													}
												}
												else
												{
													// 09/02/2010 Paul.  We should be safe in assuming that if the field exists but is empty, 
													// that we want to search for the NULL value.  This is because a multi-select ListBox will 
													// not save the field if there are no values selected. 
													if ( Sql.IsEmptyString(xField.InnerText) )
													{
														if ( sDATA_FIELD.IndexOf(' ') > 0 )
														{
															cmd.CommandText += "   and (1 = 0";
															foreach ( string sField in sDATA_FIELD.Split(' ') )
															{
																cmd.CommandText += "        or " + sField + " is null";
															}
															cmd.CommandText += "       )" + ControlChars.CrLf;
														}
														else
															cmd.CommandText += "   and " + sDATA_FIELD + " is null" + ControlChars.CrLf;
													}
													else
													{
														if ( sDATA_FIELD.IndexOf(' ') > 0 )
														{
															cmd.CommandText += "   and (1 = 0" + ControlChars.CrLf;
															foreach ( string sField in sDATA_FIELD.Split(' ') )
															{
																cmd.CommandText += "        or ";
																Sql.AppendParameter(cmd, xField.InnerText, sField);
															}
															cmd.CommandText += "       )" + ControlChars.CrLf;
														}
														// 08/25/2009 Paul.  Add support for dynamic teams. 
														else if ( sDATA_FIELD == "TEAM_ID" )
														{
															Guid gTEAM_ID = Sql.ToGuid(xField.InnerText);
															if ( !Sql.IsEmptyGuid(gTEAM_ID) )
															{
																if ( Crm.Config.enable_dynamic_teams() )
																{
																	cmd.CommandText += "   and TEAM_SET_ID in (select MEMBERSHIP_TEAM_SET_ID" + ControlChars.CrLf;
																	cmd.CommandText += "                         from vwTEAM_SET_MEMBERSHIPS" + ControlChars.CrLf;
																	cmd.CommandText += "                        where 1 = 1                 " + ControlChars.CrLf;
																	cmd.CommandText += "                       ";
																	Sql.AppendParameter(cmd, gTEAM_ID, "MEMBERSHIP_TEAM_ID");
																	cmd.CommandText += "                      )" + ControlChars.CrLf;
																}
																else
																{
																	Sql.AppendParameter(cmd, gTEAM_ID, sDATA_FIELD);
																}
															}
														}
														// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
														else if ( sDATA_FIELD == "ASSIGNED_USER_ID" )
														{
															Guid gUSER_ID = Sql.ToGuid(xField.InnerText);
															if ( !Sql.IsEmptyGuid(gUSER_ID) )
															{
																if ( Crm.Config.enable_dynamic_assignment() )
																{
																	cmd.CommandText += "   and ASSIGNED_SET_ID in (select MEMBERSHIP_ASSIGNED_SET_ID" + ControlChars.CrLf;
																	cmd.CommandText += "                             from vwASSIGNED_SET_MEMBERSHIPS" + ControlChars.CrLf;
																	cmd.CommandText += "                            where 1 = 1                     " + ControlChars.CrLf;
																	cmd.CommandText += "                              ";
																	Sql.AppendParameter(cmd, gUSER_ID, "MEMBERSHIP_ASSIGNED_USER_ID");
																	cmd.CommandText += "                          )" + ControlChars.CrLf;
																}
																else
																{
																	Sql.AppendParameter(cmd, gUSER_ID, sDATA_FIELD);
																}
															}
														}
														else
														{
															Sql.AppendParameter(cmd, xField.InnerText, sDATA_FIELD);
														}
													}
												}
											}
										}
										else if ( sFIELD_TYPE == "DatePicker" )
										{
											// 01/01/2018 Paul.  Allow searching of multiple date fields. 
											DatePicker ctlDate = FindControl(sDATA_FIELD.Replace(" ", "_")) as DatePicker;
											if ( ctlDate == null )
											{
												if ( !Sql.IsEmptyString(xField.InnerText) )
												{
													DateTime dtDate = Sql.ToDateTime(xField.InnerText);
													Sql.AppendParameter(cmd, dtDate, sDATA_FIELD);
												}
											}
										}
										else if ( sFIELD_TYPE == "DateRange" )
										{
											DateTime dtDateStart = DateTime.MinValue;
											DateTime dtDateEnd   = DateTime.MinValue;
											XmlNode xStart = xField.SelectSingleNode("After");
											if ( xStart != null )
											{
												// 01/01/2018 Paul.  Allow searching of multiple date fields. 
												DatePicker ctlDateStart = FindControl(sDATA_FIELD.Replace(" ", "_") + "_AFTER") as DatePicker;
												if ( ctlDateStart == null )
												{
													if ( !Sql.IsEmptyString(xStart.InnerText) )
													{
														dtDateStart = Sql.ToDateTime(xStart.InnerText);
													}
												}
											}
											XmlNode xEnd = xField.SelectSingleNode("Before");
											if ( xEnd != null )
											{
												// 01/01/2018 Paul.  Allow searching of multiple date fields. 
												DatePicker ctlDateEnd = FindControl(sDATA_FIELD.Replace(" ", "_") + "_BEFORE") as DatePicker;
												if ( ctlDateEnd == null )
												{
													if ( !Sql.IsEmptyString(xEnd.InnerText) )
													{
														dtDateEnd = Sql.ToDateTime(xEnd.InnerText);
													}
												}
											}
											if ( dtDateStart != DateTime.MinValue ||dtDateEnd != DateTime.MinValue )
												Sql.AppendParameter(cmd, dtDateStart, dtDateEnd, sDATA_FIELD);
										}
										else if ( sFIELD_TYPE == "CheckBox" )
										{
											bool bChecked = Sql.ToBoolean(xField.InnerText);
											if ( bChecked )
											{
												// 12/02/2007 Paul.  Unassigned checkbox has a special meaning. 
												if ( sDATA_FIELD == "UNASSIGNED_ONLY" )
												{
													// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
													if ( Crm.Config.enable_dynamic_assignment() )
													{
														cmd.CommandText += "   and ASSIGNED_SET_ID is null" + ControlChars.CrLf;
													}
													else
													{
														// 10/04/2006 Paul.  Add flag to show only records that are not assigned. 
														cmd.CommandText += "   and ASSIGNED_USER_ID is null" + ControlChars.CrLf;
													}
												}
												else if ( sDATA_FIELD == "CURRENT_USER_ONLY" )
												{
													// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
													if ( Crm.Config.enable_dynamic_assignment() )
													{
														cmd.CommandText += "   and ASSIGNED_SET_ID in (select MEMBERSHIP_ASSIGNED_SET_ID" + ControlChars.CrLf;
														cmd.CommandText += "                             from vwASSIGNED_SET_MEMBERSHIPS" + ControlChars.CrLf;
														cmd.CommandText += "                            where 1 = 1                     " + ControlChars.CrLf;
														cmd.CommandText += "                              ";
														Sql.AppendParameter(cmd, Security.USER_ID, "MEMBERSHIP_ASSIGNED_USER_ID");
														cmd.CommandText += "                          )" + ControlChars.CrLf;
													}
													else
													{
														Sql.AppendParameter(cmd, Security.USER_ID, "ASSIGNED_USER_ID", false);
													}
												}
												// 03/31/2012 Paul.  FAVORITE_RECORD_ID has a special meaning. 
												else if ( sDATA_FIELD == "FAVORITE_RECORD_ID" )
												{
													cmd.CommandText += "   and FAVORITE_RECORD_ID is not null" + ControlChars.CrLf;
												}
												else
												{
													// 04/27/2008 Paul.  The boolean AppendParameter now requires the IsEmpty flag. 
													// In this case, it is false when the value is checked. 
													Sql.AppendParameter(cmd, bChecked, sDATA_FIELD, false);
												}
											}
										}
										// 04/13/2016 Paul.  Add ZipCode lookup. 
										else if ( sFIELD_TYPE == "TextBox" || sFIELD_TYPE == "ZipCodePopup" )
										{
											if ( sDATA_FIELD.IndexOf(' ') > 0 )
												Sql.AppendParameter(cmd, xField.InnerText, 4000, Sql.SqlFilterMode.StartsWith, sDATA_FIELD.Split(' '));
											else
												Sql.AppendParameter(cmd, xField.InnerText, 4000, Sql.SqlFilterMode.StartsWith, sDATA_FIELD);  // 11/16/2011 Paul.  Include format size to get SearchBuilder logic. 
										}
										else if ( sFIELD_TYPE == "ChangeButton" || sFIELD_TYPE == "ModulePopup" )
										{
											if ( sDATA_FIELD.EndsWith("_ID") )
											{
												Guid gID = Sql.ToGuid(xField.InnerText);
												if ( !Sql.IsEmptyGuid(gID) )
												{
													// 08/25/2009 Paul.  Add support for dynamic teams. 
													if ( sDATA_FIELD == "TEAM_ID" || sDATA_FIELD == "TEAM_SET_NAME" )
													{
														if ( Crm.Config.enable_dynamic_teams() )
														{
															cmd.CommandText += "   and TEAM_SET_ID in (select MEMBERSHIP_TEAM_SET_ID" + ControlChars.CrLf;
															cmd.CommandText += "                         from vwTEAM_SET_MEMBERSHIPS" + ControlChars.CrLf;
															cmd.CommandText += "                        where 1 = 1                 " + ControlChars.CrLf;
															cmd.CommandText += "                       ";
															Sql.AppendParameter(cmd, ctl.ID, "MEMBERSHIP_TEAM_ID");
															cmd.CommandText += "                      )" + ControlChars.CrLf;
														}
														else
														{
															Sql.AppendParameter(cmd, gID, sDATA_FIELD);
														}
													}
													// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
													else if ( sDATA_FIELD == "ASSIGNED_USER_ID" || sDATA_FIELD == "ASSIGNED_SET_NAME" )
													{
														if ( Crm.Config.enable_dynamic_assignment() )
														{
															cmd.CommandText += "   and ASSIGNED_SET_ID in (select MEMBERSHIP_ASSIGNED_SET_ID" + ControlChars.CrLf;
															cmd.CommandText += "                             from vwASSIGNED_SET_MEMBERSHIPS" + ControlChars.CrLf;
															cmd.CommandText += "                            where 1 = 1                     " + ControlChars.CrLf;
															cmd.CommandText += "                              ";
															Sql.AppendParameter(cmd, ctl.ID, "MEMBERSHIP_ASSIGNED_USER_ID");
															cmd.CommandText += "                          )" + ControlChars.CrLf;
														}
														else
														{
															Sql.AppendParameter(cmd, gID, sDATA_FIELD);
														}
													}
													else
													{
														Sql.AppendParameter(cmd, gID, sDATA_FIELD);
													}
												}
											}
											else
											{
												Sql.AppendParameter(cmd, xField.InnerText, Sql.SqlFilterMode.StartsWith, sDATA_FIELD);
											}
										}
										else if ( sFIELD_TYPE == "TeamSelect" )
										{
											TeamSelect ctlTeamSelect = FindControl(sDATA_FIELD) as TeamSelect;
											if ( ctlTeamSelect == null )
											{
												if ( Crm.Config.enable_dynamic_teams() )
												{
													StringBuilder sbTEAM_SET_LIST = new StringBuilder();
													XmlNodeList nlTeams = xField.SelectNodes("Team");
													foreach ( XmlNode xTeam in nlTeams )
													{
														if ( sbTEAM_SET_LIST.Length > 0 )
															sbTEAM_SET_LIST.Append(",");
														Guid gTEAM_ID = Sql.ToGuid(XmlUtil.SelectSingleNode(xTeam, "TEAM_ID"));
														if ( gTEAM_ID != Guid.Empty )
														{
															sbTEAM_SET_LIST.Append(gTEAM_ID.ToString());
														}
													}
													if ( sbTEAM_SET_LIST.Length > 0 )
													{
														string[] arr = sbTEAM_SET_LIST.ToString().Split(',');
														if ( arr.Length > 0 )
														{
															cmd.CommandText += "   and TEAM_SET_ID in (select MEMBERSHIP_TEAM_SET_ID" + ControlChars.CrLf;
															cmd.CommandText += "                         from vwTEAM_SET_MEMBERSHIPS" + ControlChars.CrLf;
															cmd.CommandText += "                        where 1 = 1                 " + ControlChars.CrLf;
															cmd.CommandText += "                       ";
															Sql.AppendGuids(cmd, arr, "MEMBERSHIP_TEAM_ID");
															cmd.CommandText += "                      )" + ControlChars.CrLf;
														}
													}
												}
												else
												{
													XmlNodeList nlTeams = xField.SelectNodes("Team");
													foreach ( XmlNode xTeam in nlTeams )
													{
														Guid gTEAM_ID = Sql.ToGuid(XmlUtil.SelectSingleNode(xTeam, "TEAM_ID"));
														if ( !Sql.IsEmptyGuid(gTEAM_ID) )
														{
															Sql.AppendParameter(cmd, ctlTeamSelect.TEAM_ID, "TEAM_ID");
														}
													}
												}
											}
										}
										// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
										else if ( sFIELD_TYPE == "UserSelect" )
										{
											UserSelect ctlUserSelect = FindControl(sDATA_FIELD) as UserSelect;
											if ( ctlUserSelect == null )
											{
												if ( Crm.Config.enable_dynamic_assignment() )
												{
													StringBuilder sbASSIGNED_SET_LIST = new StringBuilder();
													XmlNodeList nlUsers = xField.SelectNodes("User");
													foreach ( XmlNode xUser in nlUsers )
													{
														if ( sbASSIGNED_SET_LIST.Length > 0 )
															sbASSIGNED_SET_LIST.Append(",");
														Guid gUSER_ID = Sql.ToGuid(XmlUtil.SelectSingleNode(xUser, "USER_ID"));
														if ( gUSER_ID != Guid.Empty )
														{
															sbASSIGNED_SET_LIST.Append(gUSER_ID.ToString());
														}
													}
													if ( sbASSIGNED_SET_LIST.Length > 0 )
													{
														string[] arr = sbASSIGNED_SET_LIST.ToString().Split(',');
														if ( arr.Length > 0 )
														{
															cmd.CommandText += "   and ASSIGNED_SET_ID in (select MEMBERSHIP_ASSIGNED_SET_ID" + ControlChars.CrLf;
															cmd.CommandText += "                             from vwASSIGNED_SET_MEMBERSHIPS" + ControlChars.CrLf;
															cmd.CommandText += "                            where 1 = 1                     " + ControlChars.CrLf;
															cmd.CommandText += "                              ";
															Sql.AppendGuids(cmd, arr, "MEMBERSHIP_ASSIGNED_USER_ID");
															cmd.CommandText += "                          )" + ControlChars.CrLf;
														}
													}
												}
												else
												{
													XmlNodeList nlUsers = xField.SelectNodes("User");
													foreach ( XmlNode xUser in nlUsers )
													{
														Guid gUSER_ID = Sql.ToGuid(XmlUtil.SelectSingleNode(xUser, "USER_ID"));
														if ( !Sql.IsEmptyGuid(gUSER_ID) )
														{
															Sql.AppendParameter(cmd, ctlUserSelect.USER_ID, "USER_ID");
														}
													}
												}
											}
										}
										// 05/12/2016 Paul.  Add Tags module. 
										else if ( sFIELD_TYPE == "TagSelect" )
										{
											TagSelect ctlTagSelect = FindControl(sDATA_FIELD) as TagSelect;
											if ( ctlTagSelect == null )
											{
												StringBuilder sbTAG_SET_LIST = new StringBuilder();
												XmlNodeList nlTags = xField.SelectNodes("Tag");
												foreach ( XmlNode xTag in nlTags )
												{
													if ( sbTAG_SET_LIST.Length > 0 )
														sbTAG_SET_LIST.Append(",");
													string sTAG_NAME = Sql.ToString(XmlUtil.SelectSingleNode(xTag, "NAME"));
													if ( sTAG_NAME != String.Empty )
													{
														sbTAG_SET_LIST.Append(sTAG_NAME.ToString());
													}
												}
												if ( sbTAG_SET_LIST.Length > 0 )
												{
													string[] arr = sbTAG_SET_LIST.ToString().Split(',');
													if ( arr.Length > 0 )
													{
														cmd.CommandText += "   and ID in (select BEAN_ID       " + ControlChars.CrLf;
														cmd.CommandText += "                from vwTAG_BEAN_REL" + ControlChars.CrLf;
														cmd.CommandText += "               where 1 = 0         " + ControlChars.CrLf;
														cmd.CommandText += "                  ";
														Sql.AppendParameter(cmd, arr, "TAG_NAME", true);
														cmd.CommandText += "             )" + ControlChars.CrLf;
													}
												}
											}
										}
										// 06/07/2017 Paul.  Add NAICSCodes module. 
										else if ( sFIELD_TYPE == "NAICSCodeSelect" )
										{
											NAICSCodeSelect ctlNAICSCodeSelect = FindControl(sDATA_FIELD) as NAICSCodeSelect;
											if ( ctlNAICSCodeSelect == null )
											{
												StringBuilder sbNAICS_SET_LIST = new StringBuilder();
												XmlNodeList nlTags = xField.SelectNodes("Tag");
												foreach ( XmlNode xTag in nlTags )
												{
													if ( sbNAICS_SET_LIST.Length > 0 )
														sbNAICS_SET_LIST.Append(",");
													string sNAICS_CODE_NAME = Sql.ToString(XmlUtil.SelectSingleNode(xTag, "NAME"));
													if ( sNAICS_CODE_NAME != String.Empty )
													{
														sbNAICS_SET_LIST.Append(sNAICS_CODE_NAME.ToString());
													}
												}
												if ( sbNAICS_SET_LIST.Length > 0 )
												{
													string[] arr = sbNAICS_SET_LIST.ToString().Split(',');
													if ( arr.Length > 0 )
													{
														cmd.CommandText += "   and ID in (select PARENT_ID            " + ControlChars.CrLf;
														cmd.CommandText += "                from vwNAICS_CODES_RELATED" + ControlChars.CrLf;
														cmd.CommandText += "               where 1 = 0                " + ControlChars.CrLf;
														cmd.CommandText += "                  ";
														Sql.AppendParameter(cmd, arr, "NAICS_CODE_NAME", true);
														cmd.CommandText += "             )" + ControlChars.CrLf;
													}
												}
											}
										}
										else if ( sFIELD_TYPE == "ModuleAutoComplete" )
										{
											Sql.AppendParameter(cmd, xField.InnerText, Sql.SqlFilterMode.StartsWith, sDATA_FIELD);
										}
									}
								}
							}
						}
					}
				}
				
				// 12/28/2008 Paul.  Apply the duplicate filter at the end of the search filter. 
				// It would probably be more efficient to place the above filters within the duplicate filter. 
				// Lets keep the SQL simple for now.  We can optimize later. 
				if ( nAdvanced == 2 )
				{
					ListControl lst = lstDuplicateColumns;
					int nSelected = 0;
					foreach(ListItem item in lst.Items)
					{
						if ( item.Selected )
							nSelected++;
					}
					if ( nSelected > 0 )
					{
						string sTABLE_NAME = Sql.ToString(Application["Modules." + m_sMODULE + ".TableName"]);
						StringBuilder sbSelect = new StringBuilder();
						StringBuilder sbGroup  = new StringBuilder();
						StringBuilder sbJoin   = new StringBuilder();
						foreach(ListItem item in lst.Items)
						{
							if ( item.Selected )
							{
								if ( sbSelect.Length == 0 )
								{
									sbSelect.Append("select " + item.Value);
									sbGroup .Append(" group by " + item.Value);
									sbJoin  .Append("         on DUPS." + item.Value + " = " + sTABLE_NAME + "." + item.Value + ControlChars.CrLf);
								}
								else
								{
									sbSelect.Append(", " + item.Value);
									sbGroup .Append(", " + item.Value);
									sbJoin  .Append("        and DUPS." + item.Value + " = " + sTABLE_NAME + "." + item.Value + ControlChars.CrLf);
								}
							}
						}
						// 04/28/2009 Paul.  Dups is any time the count is >= 2.
						string sDupSQL = String.Empty;
						sDupSQL = "select ID " + ControlChars.CrLf
						        + "  from      vw" + sTABLE_NAME + "_Edit " + sTABLE_NAME + ControlChars.CrLf
						        + " inner join (" + sbSelect.ToString() + ControlChars.CrLf
						        + "               from vw" + sTABLE_NAME + "_Edit" + ControlChars.CrLf
						        + "             " + sbGroup.ToString() + ControlChars.CrLf
						        + "              having count(*) >= 2) DUPS" + ControlChars.CrLf
						        + sbJoin.ToString();
						cmd.CommandText += "   and ID in " + ControlChars.CrLf + "(" + ControlChars.CrLf + sDupSQL + ")";
					}
				}
			}
			return bSearchLoaded;
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			if ( !IsPostBack )
			{
				// 06/05/2015 Paul.  New style for Seven theme. 
				if ( SplendidDynamic.StackedLayout(Page.Theme) )
				{
					btnSearch           .CssClass = "EditHeaderOtherButton";
					btnClear            .CssClass = "EditHeaderOtherButton";
					btnSavedSearchSave  .CssClass = "EditHeaderOtherButton";
					btnSavedSearchUpdate.CssClass = "EditHeaderOtherButton";
					btnSavedSearchDelete.CssClass = "EditHeaderOtherButton";
				}
				try
				{
					// 12/08/2007 Paul.  We may need to initialize inside SqlSearchClause. 
					if ( dtFields == null )
						InitializeDynamicView();
					// 09/01/2010 Paul.  We need to move the lstSavedSearches binding to InitializeDynamicView. 
					// This should solve the problem with the listbox not getting set properly. 
					if ( lstSavedSearches.Items.Count == 0 )
					{
						DataView vwSavedSearch = new DataView(SplendidCache.SavedSearch(m_sMODULE));
						vwSavedSearch.RowFilter = "NAME is not null";
						lstSavedSearches.DataSource = vwSavedSearch;
						// 07/23/2008 Paul.  The saved search may use a deleted named item. Catch the error and fix it. 
						try
						{
							lstSavedSearches.DataBind();
							lstSavedSearches.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							// 07/23/2008 Paul.  If there is an error, clear the sort and clear the search. 
							CommandEventArgs eSortGrid = new CommandEventArgs("SortGrid", null);
							Command(this, eSortGrid);
							ClearForm();
							lstSavedSearches.SelectedIndex = 0;
							// 08/12/2009 Paul.  Since this is exception code, lets not put any conditions around saving the default view. 
							// We need to ensure that the exceptions stop. 
							SaveDefaultView();
							// 06/20/2010 Paul.  When inside a subpanel, we cannot use Transfer. 
							if ( !bIsSubpanelSearch )
								Server.Transfer(Page.AppRelativeVirtualPath + "?Advanced=" + nAdvanced.ToString());
						}
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					lblError.Text = ex.Message;
				}
			}
			else
			{
				// 12/03/2007 Paul.  We've stopped using the unassigned checkbox.  Instead, use a NONE row. 
				ListBox  lstASSIGNED_USER_ID = FindControl("ASSIGNED_USER_ID") as ListBox;
				CheckBox chkUNASSIGNED_ONLY  = FindControl("UNASSIGNED_ONLY" ) as CheckBox;
				if ( lstASSIGNED_USER_ID != null && chkUNASSIGNED_ONLY != null )
					lstASSIGNED_USER_ID.Enabled = !chkUNASSIGNED_ONLY.Checked;
			}
		}

		protected override void OnPreRender(EventArgs e)
		{
			// 12/08/2007 Paul.  We need a way to detect the listbox change inside the Page_Load event. 
			ViewState["SavedSearches_PreviousValue"] = lstSavedSearches.SelectedValue;

			if ( IsPostBack )
			{
				// 12/28/2007 Paul.  Disable the auto-save in a popup. 
				// 08/12/2009 Paul.  A customer wants the ability to turn off the saved searches, both globally and on a per user basis. 
				// 04/09/2011 Paul.  The DashletReport must always save its settings, otherwise it will forget the selected report. 
				if ( SaveEnabled() && (!bIsPopupSearch && bShowSearchViews) )
					SaveDefaultView();
			}
			base.OnPreRender(e);
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
			nAdvanced = Sql.ToInteger(Request["Advanced"]);
			// 12/17/2007 Paul.  Allow the SearchMode default to be specified in SearchView definition. 
			// Campaigns.SearchPreview is one such area. 
			if ( Sql.IsEmptyString(sSearchMode) )
			{
				if ( bIsPopupSearch )
					sSearchMode = "SearchPopup";  // SearchBasic.Mobile is automatic. 
				else if ( nAdvanced == 0 )
					sSearchMode = "SearchBasic";  // SearchBasic.Mobile is automatic. 
				else if ( nAdvanced == 2 )
					sSearchMode = "SearchDuplicates";
				else
					sSearchMode = "SearchAdvanced";
			}
			if ( bShowSearchTabs )
			{
				lnkBasicSearch    .CssClass = (nAdvanced == 0) ? "current" : "";
				lnkAdvancedSearch .CssClass = (nAdvanced == 1) ? "current" : "";
				lnkDuplicateSearch.CssClass = (nAdvanced == 2) ? "current" : "";
				// 02/27/2018 Paul.  Make sure to maintain the ArchiveView state. 
				lnkBasicSearch    .NavigateUrl = Page.AppRelativeVirtualPath + "?Advanced=0" + (ArchiveViewEnabled() ? "&ArchiveView=1" : String.Empty);
				lnkAdvancedSearch .NavigateUrl = Page.AppRelativeVirtualPath + "?Advanced=1" + (ArchiveViewEnabled() ? "&ArchiveView=1" : String.Empty);
				lnkDuplicateSearch.NavigateUrl = Page.AppRelativeVirtualPath + "?Advanced=2" + (ArchiveViewEnabled() ? "&ArchiveView=1" : String.Empty);
			}
			if ( IsPostBack )
			{
				// 12/02/2007 Paul.  AppendEditViewFields should be called inside Page_Load when not a postback, 
				// and in InitializeComponent when it is a postback. If done wrong, 
				// the page will bind after the list is populated, causing the list to populate again. 
				// 04/10/2011 Paul.  Initialize is happening too early.  When we are tracking the load, then we need to defer the initialize. 
				if ( EditViewLoaded == null )
					InitializeDynamicView();
			}
		}
		#endregion
	}
}

