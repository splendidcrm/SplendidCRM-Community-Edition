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
using System.Xml;
using System.Text;
using System.Collections;
using System.Data;
using System.Data.Common;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.SessionState;
using System.Diagnostics;
using SplendidCRM._controls;
// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
using CKEditor.NET;

namespace SplendidCRM.Import
{
	public class MergeView : SplendidControl
	{
		// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
		protected _controls.HeaderButtons  ctlDynamicButtons;
		protected string                   sMergeModule      ;

		protected HtmlTable                tblMain           ;
		protected HtmlTable                tblSimilar        ;
		protected Button                   btnSetPrimary     ;
		protected Button                   btnRemove         ;
		protected HiddenField              hidRecords        ;
		protected HiddenField              hidPrimaryRecord  ;
		protected HiddenField              hidRemoveRecord   ;
		protected HiddenField              hidRecordCount    ;
		protected HiddenField              hidDifferentFields;
		protected HiddenField              hidSimilarFields  ;

		public string Module
		{
			get { return sMergeModule; }
			set { sMergeModule = value; }
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			try
			{
				if ( e.CommandName == "SetPrimary" )
				{
					string[] arrID = hidRecords.Value.Split(',');
					// 12/27/2008 Paul.  Binding again causes the Set Primary and Remove to be disconnected. 
					// Our solution is to have the links click buttons that are not within the table. 
					Bind(hidPrimaryRecord.Value, arrID);
				}
				else if ( e.CommandName == "Remove" )
				{
					string[] arrID = hidRecords.Value.Split(',');
					ArrayList lst = new ArrayList();
					foreach ( string s in arrID )
					{
						if ( String.Compare(s, hidRemoveRecord.Value, true) != 0 )
							lst.Add(s);
					}
					hidRemoveRecord.Value = String.Empty;
					arrID = lst.ToArray(typeof(System.String)) as string[];
					// 12/27/2008 Paul.  Binding again causes the Set Primary and Remove to be disconnected. 
					// Our solution is to have the links click buttons that are not within the table. 
					Bind(hidPrimaryRecord.Value, arrID);
				}
				// 03/15/2014 Paul.  Enable override of concurrency error. 
				else if ( e.CommandName == "Save" || e.CommandName == "SaveConcurrency" )
				{
					this.ValidateEditViewFields(m_sMODULE + ".EditView"       );
					if ( m_sMODULE == "Accounts" )
					{
						this.ValidateEditViewFields(m_sMODULE + ".EditAddress"    );
						this.ValidateEditViewFields(m_sMODULE + ".EditDescription");
					}
					if ( Page.IsValid )
					{
						string[] arrID = hidRecords.Value.Split(',');
						Guid gID = Sql.ToGuid(hidPrimaryRecord.Value);
						// 09/09/2009 Paul.  Use the new function to get the table name. 
						string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
						DataTable dtCustomFields = SplendidCache.FieldsMetaData_Validated(sTABLE_NAME);
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							// 11/18/2007 Paul.  Use the current values for any that are not defined in the edit view. 
							DataRow   rowCurrent = null;
							DataTable dtCurrent  = new DataTable();
							if ( !Sql.IsEmptyGuid(gID) )
							{
								string sSQL ;
								sSQL = "select *              " + ControlChars.CrLf
								     + "  from vw" + sTABLE_NAME + "_Edit" + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Security.Filter(cmd, m_sMODULE, "edit");
									Sql.AppendParameter(cmd, gID, "ID", false);
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										da.Fill(dtCurrent);
										if ( dtCurrent.Rows.Count > 0 )
										{
											rowCurrent = dtCurrent.Rows[0];
											// 12/09/2008 Paul.  Throw an exception if the record has been edited since the last load. 
											DateTime dtLAST_DATE_MODIFIED = Sql.ToDateTime(ViewState["LAST_DATE_MODIFIED"]);
											// 03/15/2014 Paul.  Enable override of concurrency error. 
											if ( Sql.ToBoolean(Application["CONFIG.enable_concurrency_check"])  && (e.CommandName != "SaveConcurrency") && dtLAST_DATE_MODIFIED != DateTime.MinValue && Sql.ToDateTime(rowCurrent["DATE_MODIFIED"]) > dtLAST_DATE_MODIFIED )
											{
												ctlDynamicButtons.ShowButton("SaveConcurrency", true);
												throw(new Exception(String.Format(L10n.Term(".ERR_CONCURRENCY_OVERRIDE"), dtLAST_DATE_MODIFIED)));
											}
										}
										else
										{
											// 11/19/2007 Paul.  If the record is not found, clear the ID so that the record cannot be updated.
											// It is possible that the record exists, but that ACL rules prevent it from being selected. 
											gID = Guid.Empty;
										}
									}
								}
							}

							// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
							using ( IDbTransaction trn = Sql.BeginTransaction(con) )
							{
								try
								{
									using ( IDbCommand cmdUpdate = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Update") )
									{
										cmdUpdate.Transaction = trn;
										foreach(IDbDataParameter par in cmdUpdate.Parameters)
										{
											// 03/27/2010 Paul.  The ParameterName will start with @, so we need to remove it. 
											string sParameterName = Sql.ExtractDbName(cmdUpdate, par.ParameterName).ToUpper();
											switch ( par.DbType )
											{
												case DbType.Guid    :  Sql.SetParameter(cmdUpdate, sParameterName, new DynamicControl(this, rowCurrent, sParameterName).ID       );  break;
												case DbType.Boolean :  Sql.SetParameter(cmdUpdate, sParameterName, new DynamicControl(this, rowCurrent, sParameterName).Checked.ToString());  break;
												case DbType.DateTime:  Sql.SetParameter(cmdUpdate, sParameterName, new DynamicControl(this, rowCurrent, sParameterName).DateValue);  break;
												default             :  Sql.SetParameter(cmdUpdate, sParameterName, new DynamicControl(this, rowCurrent, sParameterName).Text     );  break;
											}
										}
										Sql.SetParameter(cmdUpdate, "@ID"              , gID             );
										Sql.SetParameter(cmdUpdate, "@MODIFIED_USER_ID", Security.USER_ID);
										cmdUpdate.ExecuteNonQuery();
									}
									SplendidDynamic.UpdateCustomFields(this, trn, gID, sTABLE_NAME, dtCustomFields);
									
									// 12/27/2008 Paul.  After updating the primary record, merge all remaining records. 
									using ( IDbCommand cmdMerge = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Merge") )
									{
										cmdMerge.Transaction = trn;
										Sql.SetParameter(cmdMerge, "@ID"              , gID             );
										Sql.SetParameter(cmdMerge, "@MODIFIED_USER_ID", Security.USER_ID);
										foreach ( string sMERGE_ID in arrID )
										{
											Guid gMERGE_ID = Sql.ToGuid(sMERGE_ID);
											if ( gMERGE_ID != gID )
											{
												Sql.SetParameter(cmdMerge, "@MERGE_ID", gMERGE_ID);
												// 06/02/2009 Paul.  Only execute if not the primary record. 
												cmdMerge.ExecuteNonQuery();
											}
										}
									}
									trn.Commit();
								}
								catch(Exception ex)
								{
									trn.Rollback();
									SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									ctlDynamicButtons.ErrorText = ex.Message;
									return;
								}
							}
						}
						// 08/07/2014 Peter.  Allow return to search area so that more merge operations can be performed quickly. 
						if ( Sql.ToBoolean(Application["CONFIG.Merge.ReturnToSearch"]) )
							Response.Redirect("~/" + m_sMODULE + "/default.aspx?Advanced=2");
						else
							Response.Redirect("~/" + m_sMODULE + "/view.aspx?ID=" + gID.ToString());
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
				ctlDynamicButtons.ErrorText = ex.Message;
			}
		}

		#region AppendEditViewFields
		public void AppendEditViewFields(HtmlTable tbl, DataRowView rdr, int nRecordIndex, string sFIELD_WIDTH, Hashtable hashIncludedFields, bool bIsPostBack)
		{
			int nRowIndex = 0;
			if ( nRecordIndex == 0 )
			{
				this.AppendEditViewFieldsEdit(m_sMODULE + ".EditView"       , tbl, rdr, ref nRowIndex, sFIELD_WIDTH, hashIncludedFields, bIsPostBack);
				// 09/12/2012 Paul.  Even though we have compbined EditAddress and EditDescription into EditView, lets fix this code for Contacts, Leads and Prospects. 
				if ( m_sMODULE == "Accounts" || m_sMODULE == "Contacts" || m_sMODULE == "Leads" || m_sMODULE == "Prospects" )
				{
					this.AppendEditViewFieldsEdit(m_sMODULE + ".EditAddress"    , tbl, rdr, ref nRowIndex, sFIELD_WIDTH, hashIncludedFields, bIsPostBack);
					this.AppendEditViewFieldsEdit(m_sMODULE + ".EditDescription", tbl, rdr, ref nRowIndex, sFIELD_WIDTH, hashIncludedFields, bIsPostBack);
				}
			}
			else
			{
				this.AppendEditViewFieldsReadOnly(m_sMODULE + ".EditView"       , tbl, rdr, ref nRowIndex, nRecordIndex, sFIELD_WIDTH, hashIncludedFields, bIsPostBack);
				// 09/12/2012 Paul.  Even though we have compbined EditAddress and EditDescription into EditView, lets fix this code for Contacts, Leads and Prospects. 
				if ( m_sMODULE == "Accounts" || m_sMODULE == "Contacts" || m_sMODULE == "Leads" || m_sMODULE == "Prospects" )
				{
					this.AppendEditViewFieldsReadOnly(m_sMODULE + ".EditAddress"    , tbl, rdr, ref nRowIndex, nRecordIndex, sFIELD_WIDTH, hashIncludedFields, bIsPostBack);
					this.AppendEditViewFieldsReadOnly(m_sMODULE + ".EditDescription", tbl, rdr, ref nRowIndex, nRecordIndex, sFIELD_WIDTH, hashIncludedFields, bIsPostBack);
				}
			}
		}

		public void AppendEditViewFieldsReadOnly(string sEDIT_NAME, HtmlTable tbl, DataRowView rdr, ref int nRowIndex, int nRecordIndex, string sFIELD_WIDTH, Hashtable hashIncludedFields, bool bIsPostBack)
		{
			// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
			DataTable dtFields = SplendidCache.EditViewFields(sEDIT_NAME, Security.PRIMARY_ROLE_NAME);
			DataView dvFields = dtFields.DefaultView;

			string sIDSuffix = nRecordIndex.ToString("_##");

			int nColIndex = 0;
			HtmlTableRow  tr      = null;
			HtmlTableCell tdLabel = null;
			HtmlTableCell tdField = null;
			if ( dvFields.Count == 0 && tbl.Rows.Count <= 1 )
				tbl.Visible = false;

			// 01/18/2010 Paul.  To apply ACL Field Security, we need to know if the current record has an ASSIGNED_USER_ID field, and its value. 
			Guid gASSIGNED_USER_ID = Guid.Empty;
			DataColumnCollection vwSchema = null;
			if ( rdr != null )
			{
				vwSchema = rdr.DataView.Table.Columns;
				if ( vwSchema.Contains("ASSIGNED_USER_ID") )
				{
					gASSIGNED_USER_ID = Sql.ToGuid(rdr["ASSIGNED_USER_ID"]);
				}
			}

			bool bEnableTeamManagement  = Crm.Config.enable_team_management();
			bool bRequireTeamManagement = Crm.Config.require_team_management();
			bool bRequireUserAssignment = Crm.Config.require_user_assignment();
			// 08/01/2010 Paul.  Allow dynamic teams to be turned off. 
			bool bEnableDynamicTeams   = Crm.Config.enable_dynamic_teams();
			// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			bool bEnableDynamicAssignment = Crm.Config.enable_dynamic_assignment();
			HttpSessionState Session = HttpContext.Current.Session;
			foreach(DataRowView row in dvFields)
			{
				Guid   gID                = Sql.ToGuid   (row["ID"               ]);
				int    nFIELD_INDEX       = Sql.ToInteger(row["FIELD_INDEX"      ]);
				string sFIELD_TYPE        = Sql.ToString (row["FIELD_TYPE"       ]);
				string sDATA_LABEL        = Sql.ToString (row["DATA_LABEL"       ]);
				string sDATA_FIELD        = Sql.ToString (row["DATA_FIELD"       ]);
				string sDATA_FORMAT       = Sql.ToString (row["DATA_FORMAT"      ]);
				string sDISPLAY_FIELD     = Sql.ToString (row["DISPLAY_FIELD"    ]);
				string sCACHE_NAME        = Sql.ToString (row["CACHE_NAME"       ]);
				bool   bDATA_REQUIRED     = Sql.ToBoolean(row["DATA_REQUIRED"    ]);
				string sONCLICK_SCRIPT    = Sql.ToString (row["ONCLICK_SCRIPT"   ]);
				string sFORMAT_SCRIPT     = Sql.ToString (row["FORMAT_SCRIPT"    ]);
				short  nFORMAT_TAB_INDEX  = Sql.ToShort  (row["FORMAT_TAB_INDEX" ]);
				int    nFORMAT_MAX_LENGTH = Sql.ToInteger(row["FORMAT_MAX_LENGTH"]);
				int    nFORMAT_SIZE       = Sql.ToInteger(row["FORMAT_SIZE"      ]);
				int    nFORMAT_ROWS       = Sql.ToInteger(row["FORMAT_ROWS"      ]);
				int    nFORMAT_COLUMNS    = Sql.ToInteger(row["FORMAT_COLUMNS"   ]);
				int    nCOLSPAN           = Sql.ToInteger(row["COLSPAN"          ]);
				// 04/04/2011 Paul.  Add support for a generic module popup. 
				string sMODULE_TYPE       = String.Empty;
				try
				{
					sMODULE_TYPE = Sql.ToString (row["MODULE_TYPE"]);
				}
				catch(Exception ex)
				{
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
				}
				
				// 12/24/2008 Paul.  Each field should be on a new line. 
				nCOLSPAN = 0;
				// 12/27/2008 Paul.  The data field will need to be in upper case in order for it to be found and saved. 
				sDATA_FIELD    = sDATA_FIELD.ToUpper();
				sDISPLAY_FIELD = sDISPLAY_FIELD.ToUpper();

				// 08/01/2010 Paul.  To apply ACL Field Security, we need to know if the Module Name, which we will extract from the EditView Name. 
				string sMODULE_NAME = String.Empty;
				string[] arrEDIT_NAME = sEDIT_NAME.Split('.');
				if ( arrEDIT_NAME.Length > 0 )
					sMODULE_NAME = arrEDIT_NAME[0];
				bool bIsReadable  = true;
				bool bIsWriteable = true;
				if ( SplendidInit.bEnableACLFieldSecurity )
				{
					Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, sDATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
					bIsWriteable = acl.IsWriteable();
				}
				// 08/01/2010 Paul.  If not readable, then just skip the field. 
				if ( !bIsReadable )
					continue;

				// 11/25/2006 Paul.  If Team Management has been disabled, then convert the field to a blank. 
				// Keep the field, but treat it as blank so that field indexes will still be valid. 
				// 12/03/2006 Paul.  Allow the team field to be visible during layout. 
				if ( sDATA_FIELD == "TEAM_ID" || sDATA_FIELD == "TEAM_SET_NAME" )
				{
					if ( !bEnableTeamManagement )
					{
						sFIELD_TYPE = "Blank";
					}
					else
					{
						if ( bEnableDynamicTeams )
						{
							// 08/31/2009 Paul.  Don't convert to TeamSelect inside a Search view or Popup view. 
							if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".Popup") < 0 )
							{
								sDATA_LABEL     = ".LBL_TEAM_SET_NAME";
								sDATA_FIELD     = "TEAM_SET_ID";
								sDISPLAY_FIELD  = "TEAM_SET_NAME";
								sFIELD_TYPE     = "TeamSelect";
								sONCLICK_SCRIPT = String.Empty;
							}
						}
						else
						{
							// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
							if ( sFIELD_TYPE == "TeamSelect" )
							{
								sDATA_LABEL     = "Teams.LBL_TEAM";
								sDATA_FIELD     = "TEAM_ID";
								sDISPLAY_FIELD  = "TEAM_NAME";
								sFIELD_TYPE     = "ModulePopup";
								sONCLICK_SCRIPT = String.Empty;
							}
						}
					}
				}
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( sDATA_FIELD == "ASSIGNED_USER_ID" || sDATA_FIELD == "ASSIGNED_SET_NAME" )
				{
					// 12/17/2017 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
					if ( bEnableDynamicAssignment && sDATA_FORMAT != "1" )
					{
						if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".Popup") < 0 )
						{
							sDATA_LABEL     = ".LBL_ASSIGNED_SET_NAME";
							sDATA_FIELD     = "ASSIGNED_SET_ID";
							sDISPLAY_FIELD  = "ASSIGNED_SET_NAME";
							sFIELD_TYPE     = "UserSelect";
							sONCLICK_SCRIPT = String.Empty;
						}
					}
					else
					{
						if ( sFIELD_TYPE == "UserSelect" )
						{
							sDATA_LABEL     = ".LBL_ASSIGNED_TO";
							sDATA_FIELD     = "ASSIGNED_USER_ID";
							sDISPLAY_FIELD  = "ASSIGNED_TO_NAME";
							sFIELD_TYPE     = "ModulePopup";
							sONCLICK_SCRIPT = String.Empty;
						}
					}
				}
				// 08/01/2010 Paul.  Hide the Exchange Folder field if disabled for this module or user. 
				if ( sDATA_FIELD == "EXCHANGE_FOLDER" )
				{
					if ( !Crm.Modules.ExchangeFolders(sMODULE_NAME) || !Security.HasExchangeAlias() )
					{
						sFIELD_TYPE = "Blank";
					}
				}
				if ( String.Compare(sFIELD_TYPE, "AddressButtons", true) == 0 )
					continue;
				else if ( String.Compare(sFIELD_TYPE, "Blank", true) == 0 )
					continue;
				else if ( hashIncludedFields != null && !hashIncludedFields.ContainsKey(sDATA_FIELD) )
					continue;

				if ( (nCOLSPAN >= 0 && nColIndex == 0) || tr == null )
				{
					if ( nRowIndex == 0 && tbl == tblMain )
					{
						if ( tbl.Rows.Count > nRowIndex )
						{
							tr = tbl.Rows[nRowIndex];
						}
						else
						{
							tr = new HtmlTableRow();
							tbl.Rows.Insert(nRowIndex, tr);
						}
						nRowIndex++;
						tdLabel = new HtmlTableCell();
						tdField = new HtmlTableCell();
						tr.Cells.Add(tdLabel);
						tr.Cells.Add(tdField);
						tdLabel.Attributes.Add("class", "dataField");
						tdField.Attributes.Add("class", "dataField");
						
						LinkButton lnkSetPrimary = new LinkButton();
						tdField.Controls.Add(lnkSetPrimary);
						
						Literal litSeparator = new Literal();
						tdField.Controls.Add(litSeparator);
						litSeparator.Text = " | ";
						
						LinkButton lnkRemove = new LinkButton();
						tdField.Controls.Add(lnkRemove);
						
						if ( rdr != null )
						{
							Guid gPrimaryID = Sql.ToGuid(rdr["ID"]);
							lnkSetPrimary.Text          = L10n.Term("Merge.LBL_CHANGE_PARENT");
							lnkSetPrimary.OnClientClick = "SetPrimaryRecord('" + gPrimaryID + "'); return false;";
							lnkRemove    .Text          = L10n.Term("Merge.LBL_REMOVE_FROM_MERGE");
							lnkRemove    .OnClientClick = "RemoveRecord('" + gPrimaryID + "'); return false;";
						}
					}
					if ( tbl.Rows.Count > nRowIndex )
					{
						tr = tbl.Rows[nRowIndex];
					}
					else
					{
						tr = new HtmlTableRow();
						tbl.Rows.Insert(nRowIndex, tr);
					}
					nRowIndex++;
				}
				Button btnCopyField = new Button();
				if ( !Sql.IsEmptyString(sDATA_FIELD) )
				{
					btnCopyField.ID   = sDATA_FIELD + "_COPY" + sIDSuffix;
					btnCopyField.Text = "<<";
					btnCopyField.Attributes.Add("class", "button");
					btnCopyField.OnClientClick = "alert('" + L10n.Term(".LBL_FAILED") + "'); return false;";
					// 08/01/2010 Paul.  Apply Field Level Security. 
					btnCopyField.Enabled = bIsWriteable;
				}
				if ( nCOLSPAN >= 0 || tdLabel == null || tdField == null )
				{
					tdLabel = new HtmlTableCell();
					tdField = new HtmlTableCell();
					tr.Cells.Add(tdLabel);
					tr.Cells.Add(tdField);
					if ( nCOLSPAN > 0 )
					{
						tdField.ColSpan = nCOLSPAN;
					}
					tdLabel.Attributes.Add("class", "dataField");
					tdLabel.VAlign = "top";
					tdLabel.Width  = "1%";
					tdField.Attributes.Add("class", "dataField");
					tdField.VAlign = "top";
					tdField.Width  = sFIELD_WIDTH;

					tdLabel.Controls.Add(btnCopyField);
				}
				
				if ( String.Compare(sFIELD_TYPE, "Label", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Label litField = new Label();
						tdField.Controls.Add(litField);
						// 07/25/2006 Paul.  Align label values to the middle so the line-up with the label. 
						tdField.VAlign = "middle";
						litField.ID = sDATA_FIELD + sIDSuffix;
						try
						{
							// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
							if ( sDATA_FIELD.IndexOf(".") >= 0 )
								litField.Text = L10n.Term(sDATA_FIELD);
							else if ( rdr != null )
								litField.Text = HttpUtility.HtmlEncode(Sql.ToString(rdr[sDATA_FIELD]));
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							litField.Text = ex.Message;
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "ListBox", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Label lstField = new Label();
						tdField.Controls.Add(lstField);
						lstField.ID   = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( rdr != null )
							{
								Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
								if ( ctlPrimary != null )
									btnCopyField.OnClientClick = "return CopyListField('" + ctlPrimary.ClientID + "', '" + lstField.ClientID + "');";
								
								string sListValue = Sql.ToString(rdr[sDATA_FIELD]);
								if ( !Sql.IsEmptyString(sListValue) )
								{
									bool bCustomCache = false;
									lstField.Text = SplendidCache.CustomList(sCACHE_NAME, sListValue, ref bCustomCache);
									if ( bCustomCache )
										continue;
									// 02/12/2008 Paul.  If the list contains XML, then treat as a multi-selection. 
									if ( sListValue.StartsWith("<?xml") )
									{
										StringBuilder sb = new StringBuilder();
										StringBuilder sbArray = new StringBuilder();
										XmlDocument xml = new XmlDocument();
										// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
										// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
										// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
										xml.XmlResolver = null;
										xml.LoadXml(sListValue);
										XmlNodeList nlValues = xml.DocumentElement.SelectNodes("Value");
										foreach ( XmlNode xValue in nlValues )
										{
											if ( sb.Length > 0 )
											{
												sb.Append(", ");
												sbArray.Append(", ");
											}
											string sTermValue = Sql.ToString(L10n.Term("." + sCACHE_NAME + ".", xValue.InnerText));
											sb.Append(sTermValue);
											// 08/01/2010 Paul.  The array should use the value, not the translated value. 
											sbArray.Append("'" + Sql.EscapeJavaScript(xValue.InnerText) + "'");
										}
										lstField.Text = sb.ToString();
										// 08/01/2010 Paul.  Array should be camel case. 
										if ( ctlPrimary != null )
											btnCopyField.OnClientClick = "return SetListFields('" + ctlPrimary.ClientID + "', new Array(" + sbArray.ToString() + "));";
									}
									else
									{
										// 08/01/2010 Paul.  Was not previously displaying the old value. 
										string sTermValue = Sql.ToString(L10n.Term("." + sCACHE_NAME + ".", sListValue));
										lstField.Text = sTermValue;
										if ( ctlPrimary != null )
											btnCopyField.OnClientClick = "return SetListFields('" + ctlPrimary.ClientID + "', new Array('" + Sql.EscapeJavaScript(sListValue) + "'));";
									}
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				// 08/01/2010 Paul.  Add support for Radio buttons. 
				else if ( String.Compare(sFIELD_TYPE, "Radio", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Label lstField = new Label();
						tdField.Controls.Add(lstField);
						lstField.ID   = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( rdr != null )
							{
								Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
								string sListValue = Sql.ToString(rdr[sDATA_FIELD]);
								if ( !Sql.IsEmptyString(sListValue) )
								{
									bool bCustomCache = false;
									lstField.Text = SplendidCache.CustomList(sCACHE_NAME, sListValue, ref bCustomCache);
									if ( bCustomCache )
										continue;
									string sTermValue = Sql.ToString(L10n.Term("." + sCACHE_NAME + ".", sListValue));
									lstField.Text = sTermValue;
									if ( ctlPrimary != null )
										btnCopyField.OnClientClick = "return SetRadioFields('" + ctlPrimary.UniqueID + "', '" + Sql.EscapeJavaScript(sListValue) + "');";
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				// 08/01/2010 Paul.  Add support for CheckBoxList. 
				else if ( String.Compare(sFIELD_TYPE, "CheckBoxList", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Label lstField = new Label();
						tdField.Controls.Add(lstField);
						lstField.ID   = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( rdr != null )
							{
								Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
								string sListValue = Sql.ToString(rdr[sDATA_FIELD]);
								if ( !Sql.IsEmptyString(sListValue) )
								{
									bool bCustomCache = false;
									lstField.Text = SplendidCache.CustomList(sCACHE_NAME, sListValue, ref bCustomCache);
									if ( bCustomCache )
										continue;
									// 02/12/2008 Paul.  If the list contains XML, then treat as a multi-selection. 
									if ( sListValue.StartsWith("<?xml") )
									{
										StringBuilder sb = new StringBuilder();
										StringBuilder sbArray = new StringBuilder();
										XmlDocument xml = new XmlDocument();
										// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
										// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
										// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
										xml.XmlResolver = null;
										xml.LoadXml(sListValue);
										XmlNodeList nlValues = xml.DocumentElement.SelectNodes("Value");
										foreach ( XmlNode xValue in nlValues )
										{
											if ( sb.Length > 0 )
											{
												sb.Append(", ");
												sbArray.Append(", ");
											}
											string sTermValue = Sql.ToString(L10n.Term("." + sCACHE_NAME + ".", xValue.InnerText));
											sb.Append(sTermValue);
											// 08/01/2010 Paul.  The CheckBoxList needs to use the Display value. 
											sbArray.Append("'" + Sql.EscapeJavaScript(sTermValue) + "'");
										}
										lstField.Text = sb.ToString();
										// 08/01/2010 Paul.  Array should be camel case. 
										if ( ctlPrimary != null )
											btnCopyField.OnClientClick = "return SetCheckBoxListFields('" + ctlPrimary.ClientID + "', new Array(" + sbArray.ToString() + "));";
									}
									else
									{
										// 08/01/2010 Paul.  Was not previously displaying the old value. 
										// 08/01/2010 Paul.  The CheckBoxList needs to use the Display value. 
										string sTermValue = Sql.ToString(L10n.Term("." + sCACHE_NAME + ".", sListValue));
										lstField.Text = sTermValue;
										if ( ctlPrimary != null )
											btnCopyField.OnClientClick = "return SetCheckBoxListFields('" + ctlPrimary.ClientID + "', new Array('" + Sql.EscapeJavaScript(sTermValue) + "'));";
									}
								}
								else
								{
									if ( ctlPrimary != null )
										btnCopyField.OnClientClick = "return SetCheckBoxListFields('" + ctlPrimary.ClientID + "', new Array(''));";
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "CheckBox", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Label chkField = new Label();
						tdField.Controls.Add(chkField);
						chkField.ID = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( rdr != null )
								chkField.Text = Sql.ToBoolean(rdr[sDATA_FIELD]) ? "true" : "false";
							Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick = "return CopyCheckboxField('" + ctlPrimary.ClientID + "', '" + chkField.ClientID + "');";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "ChangeButton", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/26/2008 Paul.  Clear failure alert. 
						btnCopyField.OnClientClick = "";
						if ( sDATA_LABEL == "PARENT_TYPE" )
						{
							tdLabel.Controls.Clear();
							HiddenField lstField = new HiddenField();
							tdLabel.Controls.Add(lstField);
							lstField.ID       = sDATA_LABEL + sIDSuffix;
							if ( rdr != null )
							{
								lstField.Value = Sql.ToString(rdr[sDATA_LABEL]);
							}
							Control ctlPrimary = tbl.FindControl(sDATA_LABEL);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick += "CopyListField('" + ctlPrimary.ClientID + "', '" + lstField.ClientID + "');";
						}
						Label txtNAME = new Label();
						tdField.Controls.Add(txtNAME);
						txtNAME.ID       = sDISPLAY_FIELD + sIDSuffix;
						try
						{
							// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
							if ( !Sql.IsEmptyString(sDISPLAY_FIELD) && rdr != null )
								txtNAME.Text = HttpUtility.HtmlEncode(Sql.ToString(rdr[sDISPLAY_FIELD]));
							Control ctlPrimary = tbl.FindControl(sDISPLAY_FIELD);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick += "CopyTextField('" + ctlPrimary.ClientID + "', '" + txtNAME.ClientID + "');";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						HtmlInputHidden hidID = new HtmlInputHidden();
						tdField.Controls.Add(hidID);
						hidID.ID = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
								hidID.Value = Sql.ToString(rdr[sDATA_FIELD]);
							Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick += "CopyInputField('" + ctlPrimary.ClientID + "', '" + hidID.ClientID + "'); return false;";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
					}
				}
				// 09/01/2009 Paul.  Add support for ModulePopups. 
				// 04/04/2011 Paul.  Lets do the same for ModuleAutoComplete. 
				else if ( String.Compare(sFIELD_TYPE, "ModulePopup", true) == 0 || String.Compare(sFIELD_TYPE, "ModuleAutoComplete", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/26/2008 Paul.  Clear failure alert. 
						btnCopyField.OnClientClick = "";
						
						Label txtNAME = new Label();
						tdField.Controls.Add(txtNAME);
						// 10/05/2010 Paul.  A custom field will not have a display field, but we still want to be able to access by name. 
						txtNAME.ID       = (Sql.IsEmptyString(sDISPLAY_FIELD) ? sDATA_FIELD + "_NAME" : sDISPLAY_FIELD) + sIDSuffix;
						try
						{
							// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
							if ( !Sql.IsEmptyString(sDISPLAY_FIELD) && rdr != null )
								txtNAME.Text = HttpUtility.HtmlEncode(Sql.ToString(rdr[sDISPLAY_FIELD]));
							else if ( rdr != null )
								txtNAME.Text = HttpUtility.HtmlEncode(Crm.Modules.ItemName(Application, sMODULE_TYPE, rdr[sDATA_FIELD]));
							Control ctlPrimary = tbl.FindControl(sDISPLAY_FIELD);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick += "CopyTextField('" + ctlPrimary.ClientID + "', '" + txtNAME.ClientID + "');";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						HtmlInputHidden hidID = new HtmlInputHidden();
						tdField.Controls.Add(hidID);
						hidID.ID = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
								hidID.Value = Sql.ToString(rdr[sDATA_FIELD]);
							Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick += "CopyInputField('" + ctlPrimary.ClientID + "', '" + hidID.ClientID + "'); return false;";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
					}
				}
				// 04/13/2016 Paul.  Add ZipCode lookup. 
				else if ( String.Compare(sFIELD_TYPE, "TextBox", true) == 0 || String.Compare(sFIELD_TYPE, "Password", true) == 0 || String.Compare(sFIELD_TYPE, "ZipCodePopup", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Label txtField = new Label();
						tdField.Controls.Add(txtField);
						txtField.ID       = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
							{
								// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
								if ( rdr[sDATA_FIELD].GetType() == typeof(System.Decimal) )
									txtField.Text = Sql.ToDecimal(rdr[sDATA_FIELD]).ToString("#,##0.00");
								else
									txtField.Text = HttpUtility.HtmlEncode(Sql.ToString(rdr[sDATA_FIELD]));
								Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
								if ( ctlPrimary != null )
									btnCopyField.OnClientClick = "return CopyTextField('" + ctlPrimary.ClientID + "', '" + txtField.ClientID + "');";
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtField.Text = ex.Message;
						}
					}
				}
				// 04/04/2011 Paul.  Add support for HtmlEditor. 
				else if ( String.Compare(sFIELD_TYPE, "HtmlEditor", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Label txtField = new Label();
						tdField.Controls.Add(txtField);
						txtField.ID       = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
							{
								txtField.Text = Sql.ToString(rdr[sDATA_FIELD]);
								Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
								if ( ctlPrimary != null )
									btnCopyField.OnClientClick = "return CopyHtmlField('" + ctlPrimary.ClientID + "', '" + txtField.ClientID + "');";
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtField.Text = ex.Message;
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "DatePicker", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Label ctlDate = new Label();
						tdField.Controls.Add(ctlDate);
						ctlDate.ID = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( rdr != null )
							{
								DateTime dtValue = T10n.FromServerTime(rdr[sDATA_FIELD]);
								if ( dtValue > DateTime.MinValue )
									ctlDate.Text = dtValue.ToShortDateString();
							}
							DatePicker ctlPrimary = tbl.FindControl(sDATA_FIELD) as DatePicker;
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick = "return CopyTextField('" + ctlPrimary.DateClientID + "', '" + ctlDate.ClientID + "');";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							ctlDate.Text = ex.Message;
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "DateTimePicker", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Label ctlDate = new Label();
						tdField.Controls.Add(ctlDate);
						ctlDate.ID = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( rdr != null )
							{
								DateTime dtValue = T10n.FromServerTime(rdr[sDATA_FIELD]);
								if ( dtValue > DateTime.MinValue )
									ctlDate.Text = dtValue.ToShortTimeString();
							}
							DateTimePicker ctlPrimary = tbl.FindControl(sDATA_FIELD) as DateTimePicker;
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick = "return CopyTextField('" + ctlPrimary.DateClientID + "', '" + ctlDate.ClientID + "');";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							ctlDate.Text = ex.Message;
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "DateTimeEdit", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Label txtDATE = new Label();
						tdField.Controls.Add(txtDATE);
						txtDATE.ID = sDATA_FIELD + "_DATE" + sIDSuffix;
						
						Literal litNBSP = new Literal();
						tdField.Controls.Add(litNBSP);
						litNBSP.Text = "&nbsp;";
						
						Label txtTIME = new Label();
						tdField.Controls.Add(txtTIME);
						txtTIME.ID = sDATA_FIELD + "_TIME" + sIDSuffix;
						try
						{
							if ( rdr != null )
							{
								DateTime dtValue = T10n.FromServerTime(rdr[sDATA_FIELD]);
								if ( dtValue > DateTime.MinValue )
								{
									txtDATE.Text = Sql.ToDateString(dtValue);
									txtTIME.Text = Sql.ToTimeString(dtValue);
								}
							}
							DateTimeEdit ctlPrimary = tbl.FindControl(sDATA_FIELD) as DateTimeEdit;
							if ( ctlPrimary != null )
							{
								btnCopyField.OnClientClick += "CopyTextField('" + ctlPrimary.DateClientID + "', '" + txtDATE.ClientID + "');";
								btnCopyField.OnClientClick += "CopyTextField('" + ctlPrimary.TimeClientID + "', '" + txtTIME.ClientID + "');";
								btnCopyField.OnClientClick += "return false;";
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtDATE.Text = ex.Message;
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "File", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Label ctlField = new Label();
						tdField.Controls.Add(ctlField);
						ctlField.ID        = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( rdr != null )
								ctlField.Text = Sql.ToString(rdr[sDATA_FIELD]);
							Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick = "return CopyTextField('" + ctlPrimary.ClientID + "', '" + ctlField.ClientID + "');";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							ctlField.Text = ex.Message;
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "Image", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Label ctlHidden = new Label();
						tdField.Controls.Add(ctlHidden);
						ctlHidden.ID = sDATA_FIELD + sIDSuffix;

						Image imgField = new Image();
						imgField.ID = "img" + sDATA_FIELD + sIDSuffix;
						try
						{
							if ( rdr != null )
							{
								if ( !Sql.IsEmptyString(rdr[sDATA_FIELD]) )
								{
									ctlHidden.Text = Sql.ToString(rdr[sDATA_FIELD]);
									imgField.ImageUrl = "~/Images/Image.aspx?ID=" + ctlHidden.Text;
									// 04/13/2006 Paul.  Only add the image if it exists. 
									tdField.Controls.Add(imgField);

									Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
									if ( ctlPrimary != null )
										btnCopyField.OnClientClick = "return CopyTextField('" + ctlPrimary.ClientID + "', '" + ctlHidden.ClientID + "');";
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							Label litField = new Label();
							litField.Text = ex.Message;
							tdField.Controls.Add(litField);
						}
					}
				}
				// 04/04/2011 Paul.  Add support for hidden field. 
				else if ( String.Compare(sFIELD_TYPE, "Hidden", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/26/2008 Paul.  Clear failure alert. 
						btnCopyField.OnClientClick = "";
						
						HtmlInputHidden hidID = new HtmlInputHidden();
						tdField.Controls.Add(hidID);
						hidID.ID = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
								hidID.Value = Sql.ToString(rdr[sDATA_FIELD]);
							Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick += "CopyInputField('" + ctlPrimary.ClientID + "', '" + hidID.ClientID + "'); return false;";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						// 04/04/2011 Paul.  Copying the teams is not easy, so lets just disable it for now. 
						btnCopyField.Enabled = false;
						// 08/08/2018 Paul.  Hide the copy button so that it is easier to see that the feature is disabled. 
						btnCopyField.Visible = false;
					}
				}
				// 08/01/2010 Paul.  Add support for dynamic teams. 
				else if ( String.Compare(sFIELD_TYPE, "TeamSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/26/2008 Paul.  Clear failure alert. 
						btnCopyField.OnClientClick = "";
						
						Label txtNAME = new Label();
						tdField.Controls.Add(txtNAME);
						txtNAME.ID       = sDISPLAY_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDISPLAY_FIELD) && rdr != null )
								txtNAME.Text = Sql.ToString(rdr[sDISPLAY_FIELD]);
							Control ctlPrimary = tbl.FindControl(sDISPLAY_FIELD);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick += "CopyTeamSelectField('" + ctlPrimary.ClientID + "', '" + txtNAME.ClientID + "');";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						HtmlInputHidden hidID = new HtmlInputHidden();
						tdField.Controls.Add(hidID);
						hidID.ID = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
								hidID.Value = Sql.ToString(rdr[sDATA_FIELD]);
							Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick += "CopyInputField('" + ctlPrimary.ClientID + "', '" + hidID.ClientID + "'); return false;";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						// 08/01/2010 Paul.  Copying the teams is not easy, so lets just disable it for now. 
						btnCopyField.Enabled = false;
						// 08/08/2018 Paul.  Hide the copy button so that it is easier to see that the feature is disabled. 
						btnCopyField.Visible = false;
					}
				}
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( String.Compare(sFIELD_TYPE, "UserSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/26/2008 Paul.  Clear failure alert. 
						btnCopyField.OnClientClick = "";
						
						Label txtNAME = new Label();
						tdField.Controls.Add(txtNAME);
						txtNAME.ID       = sDISPLAY_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDISPLAY_FIELD) && rdr != null )
								txtNAME.Text = Sql.ToString(rdr[sDISPLAY_FIELD]);
							Control ctlPrimary = tbl.FindControl(sDISPLAY_FIELD);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick += "CopyUserSelectField('" + ctlPrimary.ClientID + "', '" + txtNAME.ClientID + "');";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						HtmlInputHidden hidID = new HtmlInputHidden();
						tdField.Controls.Add(hidID);
						hidID.ID = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
								hidID.Value = Sql.ToString(rdr[sDATA_FIELD]);
							Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick += "CopyInputField('" + ctlPrimary.ClientID + "', '" + hidID.ClientID + "'); return false;";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						// 08/08/2018 Paul.  Copying the users is not easy, so lets just disable it for now. 
						btnCopyField.Enabled = false;
						// 08/08/2018 Paul.  Hide the copy button so that it is easier to see that the feature is disabled. 
						btnCopyField.Visible = false;
					}
				}
				// 08/08/2018 Paul.  Add support for TagSelect. 
				else if ( String.Compare(sFIELD_TYPE, "TagSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/26/2008 Paul.  Clear failure alert. 
						btnCopyField.OnClientClick = "";
						
						Label txtNAME = new Label();
						tdField.Controls.Add(txtNAME);
						txtNAME.ID       = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
								txtNAME.Text = Sql.ToString(rdr[sDATA_FIELD]);
							Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick += "CopyTagSelectField('" + ctlPrimary.ClientID + "', '" + txtNAME.ClientID + "');";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						// 08/08/2018 Paul.  Copying the teams is not easy, so lets just disable it for now. 
						btnCopyField.Enabled = false;
						// 08/08/2018 Paul.  Hide the copy button so that it is easier to see that the feature is disabled. 
						btnCopyField.Visible = false;
					}
				}
				// 08/08/2018 Paul.  Add support for NAICSCodeSelect. 
				else if ( String.Compare(sFIELD_TYPE, "NAICSCodeSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/26/2008 Paul.  Clear failure alert. 
						btnCopyField.OnClientClick = "";
						
						Label txtNAME = new Label();
						tdField.Controls.Add(txtNAME);
						txtNAME.ID       = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
								txtNAME.Text = Sql.ToString(rdr[sDATA_FIELD]);
							Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick += "CopyNAICSCodeSelectField('" + ctlPrimary.ClientID + "', '" + txtNAME.ClientID + "');";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						// 08/08/2011 Paul.  Copying the teams is not easy, so lets just disable it for now. 
						btnCopyField.Enabled = false;
						// 08/08/2018 Paul.  Hide the copy button so that it is easier to see that the feature is disabled. 
						btnCopyField.Visible = false;
					}
				}
				// 04/04/2011 Paul.  Add support for KBTagSelect.  Still need to add the CopyKBTagSelectField code. 
				else if ( String.Compare(sFIELD_TYPE, "KBTagSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/26/2008 Paul.  Clear failure alert. 
						btnCopyField.OnClientClick = "";
						
						Label txtNAME = new Label();
						tdField.Controls.Add(txtNAME);
						txtNAME.ID       = sDISPLAY_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDISPLAY_FIELD) && rdr != null )
								txtNAME.Text = Sql.ToString(rdr[sDISPLAY_FIELD]);
							Control ctlPrimary = tbl.FindControl(sDISPLAY_FIELD);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick += "CopyKBTagSelectField('" + ctlPrimary.ClientID + "', '" + txtNAME.ClientID + "');";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						HtmlInputHidden hidID = new HtmlInputHidden();
						tdField.Controls.Add(hidID);
						hidID.ID = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
								hidID.Value = Sql.ToString(rdr[sDATA_FIELD]);
							Control ctlPrimary = tbl.FindControl(sDATA_FIELD);
							if ( ctlPrimary != null )
								btnCopyField.OnClientClick += "CopyInputField('" + ctlPrimary.ClientID + "', '" + hidID.ClientID + "'); return false;";
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						// 04/04/2011 Paul.  Copying the teams is not easy, so lets just disable it for now. 
						btnCopyField.Enabled = false;
						// 08/08/2018 Paul.  Hide the copy button so that it is easier to see that the feature is disabled. 
						btnCopyField.Visible = false;
					}
				}
				else
				{
					Literal litField = new Literal();
					tdField.Controls.Add(litField);
					litField.Text = "Unknown field type " + sFIELD_TYPE;
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "Unknown field type " + sFIELD_TYPE);
				}
				nColIndex = 0;
			}
		}

		public void AppendEditViewFieldsEdit(string sEDIT_NAME, HtmlTable tbl, DataRowView rdr, ref int nRowIndex, string sFIELD_WIDTH, Hashtable hashIncludedFields, bool bIsPostBack)
		{
			// 05/05/2016 Paul.  The User Primary Role is used with role-based views. 
			DataTable dtFields = SplendidCache.EditViewFields(sEDIT_NAME, Security.PRIMARY_ROLE_NAME);
			DataView dvFields = dtFields.DefaultView;

			string sIDSuffix = String.Empty;
			//if ( nRecordIndex > 0 )
			//	sIDSuffix = nRecordIndex.ToString("_##");

			int nColIndex = 0;
			HtmlTableRow  tr      = null;
			HtmlTableCell tdLabel = null;
			HtmlTableCell tdField = null;
			if ( dvFields.Count == 0 && tbl.Rows.Count <= 1 )
				tbl.Visible = false;

			// 01/18/2010 Paul.  To apply ACL Field Security, we need to know if the current record has an ASSIGNED_USER_ID field, and its value. 
			Guid gASSIGNED_USER_ID = Guid.Empty;
			DataColumnCollection vwSchema = null;
			if ( rdr != null )
			{
				vwSchema = rdr.DataView.Table.Columns;
				if ( vwSchema.Contains("ASSIGNED_USER_ID") )
				{
					gASSIGNED_USER_ID = Sql.ToGuid(rdr["ASSIGNED_USER_ID"]);
				}
			}

			bool bEnableTeamManagement  = Crm.Config.enable_team_management();
			bool bRequireTeamManagement = Crm.Config.require_team_management();
			bool bRequireUserAssignment = Crm.Config.require_user_assignment();
			// 08/01/2010 Paul.  Allow dynamic teams to be turned off. 
			bool bEnableDynamicTeams   = Crm.Config.enable_dynamic_teams();
			// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			bool bEnableDynamicAssignment = Crm.Config.enable_dynamic_assignment();
			HttpSessionState Session = HttpContext.Current.Session;
			foreach(DataRowView row in dvFields)
			{
				int    nFIELD_INDEX       = Sql.ToInteger(row["FIELD_INDEX"      ]);
				string sFIELD_TYPE        = Sql.ToString (row["FIELD_TYPE"       ]);
				string sDATA_LABEL        = Sql.ToString (row["DATA_LABEL"       ]);
				string sDATA_FIELD        = Sql.ToString (row["DATA_FIELD"       ]);
				string sDATA_FORMAT       = Sql.ToString (row["DATA_FORMAT"      ]);
				string sDISPLAY_FIELD     = Sql.ToString (row["DISPLAY_FIELD"    ]);
				string sCACHE_NAME        = Sql.ToString (row["CACHE_NAME"       ]);
				bool   bDATA_REQUIRED     = Sql.ToBoolean(row["DATA_REQUIRED"    ]);
				bool   bUI_REQUIRED       = Sql.ToBoolean(row["UI_REQUIRED"      ]);
				string sONCLICK_SCRIPT    = Sql.ToString (row["ONCLICK_SCRIPT"   ]);
				string sFORMAT_SCRIPT     = Sql.ToString (row["FORMAT_SCRIPT"    ]);
				short  nFORMAT_TAB_INDEX  = Sql.ToShort  (row["FORMAT_TAB_INDEX" ]);
				int    nFORMAT_MAX_LENGTH = Sql.ToInteger(row["FORMAT_MAX_LENGTH"]);
				int    nFORMAT_SIZE       = Sql.ToInteger(row["FORMAT_SIZE"      ]);
				int    nFORMAT_ROWS       = Sql.ToInteger(row["FORMAT_ROWS"      ]);
				int    nFORMAT_COLUMNS    = Sql.ToInteger(row["FORMAT_COLUMNS"   ]);
				int    nCOLSPAN           = Sql.ToInteger(row["COLSPAN"          ]);
				// 04/02/2008 Paul.  Add support for Regular Expression validation. 
				string sFIELD_VALIDATOR_MESSAGE = Sql.ToString (row["FIELD_VALIDATOR_MESSAGE"]);
				string sVALIDATION_TYPE         = Sql.ToString (row["VALIDATION_TYPE"        ]);
				string sREGULAR_EXPRESSION      = Sql.ToString (row["REGULAR_EXPRESSION"     ]);
				string sDATA_TYPE               = Sql.ToString (row["DATA_TYPE"              ]);
				string sMININUM_VALUE           = Sql.ToString (row["MININUM_VALUE"          ]);
				string sMAXIMUM_VALUE           = Sql.ToString (row["MAXIMUM_VALUE"          ]);
				string sCOMPARE_OPERATOR        = Sql.ToString (row["COMPARE_OPERATOR"       ]);
				// 09/01/2009 Paul.  Add support for a generic module popup. 
				string sMODULE_TYPE       = String.Empty;
				try
				{
					sMODULE_TYPE = Sql.ToString (row["MODULE_TYPE"]);
				}
				catch(Exception ex)
				{
					// 09/01/2009 Paul.  The MODULE_TYPE is not in the view, then log the error and continue. 
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
				}
				// 12/24/2008 Paul.  Each field should be on a new line. 
				nCOLSPAN = 0;
				// 12/27/2008 Paul.  The data field will need to be in upper case in order for it to be found and saved. 
				sDATA_FIELD    = sDATA_FIELD.ToUpper();
				sDISPLAY_FIELD = sDISPLAY_FIELD.ToUpper();

				// 08/01/2010 Paul.  To apply ACL Field Security, we need to know if the Module Name, which we will extract from the EditView Name. 
				string sMODULE_NAME = String.Empty;
				string[] arrEDIT_NAME = sEDIT_NAME.Split('.');
				if ( arrEDIT_NAME.Length > 0 )
					sMODULE_NAME = arrEDIT_NAME[0];
				bool bIsReadable  = true;
				bool bIsWriteable = true;
				if ( SplendidInit.bEnableACLFieldSecurity )
				{
					Security.ACL_FIELD_ACCESS acl = Security.GetUserFieldSecurity(sMODULE_NAME, sDATA_FIELD, gASSIGNED_USER_ID);
					bIsReadable  = acl.IsReadable();
					bIsWriteable = acl.IsWriteable();
				}
				// 08/01/2010 Paul.  If not readable, then just skip the field. 
				if ( !bIsReadable )
					continue;

				sDATA_LABEL = m_sMODULE + ".LBL_" + sDATA_FIELD;
				if ( sDATA_FIELD == "TEAM_ID" || sDATA_FIELD == "TEAM_SET_NAME" )
					sDATA_LABEL = "Teams.LBL_TEAM";
				else if ( sDATA_FIELD == "ASSIGNED_USER_ID" )
					sDATA_LABEL = ".LBL_ASSIGNED_TO";

				// 11/25/2006 Paul.  If Team Management has been disabled, then convert the field to a blank. 
				// Keep the field, but treat it as blank so that field indexes will still be valid. 
				// 12/03/2006 Paul.  Allow the team field to be visible during layout. 
				if ( sDATA_FIELD == "TEAM_ID" || sDATA_FIELD == "TEAM_SET_NAME" )
				{
					if ( !bEnableTeamManagement )
					{
						sFIELD_TYPE = "Blank";
						bUI_REQUIRED = false;
					}
					else
					{
						if ( bEnableDynamicTeams )
						{
							// 08/31/2009 Paul.  Don't convert to TeamSelect inside a Search view or Popup view. 
							if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".Popup") < 0 )
							{
								sDATA_LABEL     = ".LBL_TEAM_SET_NAME";
								sDATA_FIELD     = "TEAM_SET_NAME";
								sFIELD_TYPE     = "TeamSelect";
								sONCLICK_SCRIPT = String.Empty;
							}
						}
						else
						{
							// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
							if ( sFIELD_TYPE == "TeamSelect" )
							{
								sDATA_LABEL     = "Teams.LBL_TEAM";
								sDATA_FIELD     = "TEAM_ID";
								sDISPLAY_FIELD  = "TEAM_NAME";
								sFIELD_TYPE     = "ModulePopup";
								sMODULE_TYPE    = "Teams";
								sONCLICK_SCRIPT = String.Empty;
							}
						}
						// 11/25/2006 Paul.  Override the required flag with the system value. 
						// 01/01/2008 Paul.  If Team Management is not required, then let the admin decide. 
						if ( bRequireTeamManagement )
							bUI_REQUIRED = true;
					}
				}
				// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( sDATA_FIELD == "ASSIGNED_USER_ID" || sDATA_FIELD == "ASSIGNED_SET_NAME" )
				{
					// 12/17/2017 Paul.  Allow a layout to remain singular with DATA_FORMAT = 1. 
					if ( bEnableDynamicAssignment && sDATA_FORMAT != "1" )
					{
						// 08/31/2009 Paul.  Don't convert to UserSelect inside a Search view or Popup view. 
						if ( sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".Popup") < 0 )
						{
							sDATA_LABEL     = ".LBL_ASSIGNED_SET_NAME";
							sDATA_FIELD     = "ASSIGNED_SET_NAME";
							sFIELD_TYPE     = "UserSelect";
							sONCLICK_SCRIPT = String.Empty;
						}
					}
					else
					{
						// 04/18/2010 Paul.  If the user manually adds a TeamSelect, we need to convert to a ModulePopup. 
						if ( sFIELD_TYPE == "UserSelect" )
						{
							sDATA_LABEL     = ".LBL_ASSIGNED_TO";
							sDATA_FIELD     = "ASSIGNED_USER_ID";
							sDISPLAY_FIELD  = "ASSIGNED_TO_NAME";
							sFIELD_TYPE     = "ModulePopup";
							sMODULE_TYPE    = "Users";
							sONCLICK_SCRIPT = String.Empty;
						}
					}
					if ( bRequireUserAssignment )
						bUI_REQUIRED = true;
				}
				// 08/01/2010 Paul.  Hide the Exchange Folder field if disabled for this module or user. 
				if ( sDATA_FIELD == "EXCHANGE_FOLDER" )
				{
					if ( !Crm.Modules.ExchangeFolders(sMODULE_NAME) || !Security.HasExchangeAlias() )
					{
						sFIELD_TYPE = "Blank";
					}
				}
				if ( String.Compare(sFIELD_TYPE, "AddressButtons", true) == 0 )
					continue;
				else if ( String.Compare(sFIELD_TYPE, "Blank", true) == 0 )
					continue;
				else if ( hashIncludedFields != null && !hashIncludedFields.ContainsKey(sDATA_FIELD) )
					continue;

				if ( sDATA_FIELD == "ASSIGNED_USER_ID" )
				{
					// 01/01/2008 Paul.  We need a quick way to require user assignments across the system. 
					if ( bRequireUserAssignment )
						bUI_REQUIRED = true;
				}
				// 08/01/2010 Paul.  Clear the Required flag if the field is writeable. 
				// Clearing at this stage will apply it to all edit types. 
				if ( bUI_REQUIRED && !bIsWriteable )
					bUI_REQUIRED = false;
				if ( (nCOLSPAN >= 0 && nColIndex == 0) || tr == null )
				{
					// 12/27/2008 Paul.  We need an extra row for the set primary and remove links. 
					if ( nRowIndex == 0 && tbl == tblMain )
					{
						if ( tbl.Rows.Count > nRowIndex )
						{
							tr = tbl.Rows[nRowIndex];
						}
						else
						{
							tr = new HtmlTableRow();
							tbl.Rows.Insert(nRowIndex, tr);
						}
						nRowIndex++;
						tdLabel = new HtmlTableCell();
						tdField = new HtmlTableCell();
						tr.Cells.Add(tdLabel);
						tr.Cells.Add(tdField);
						Label lblPrimaryID = new Label();
						tdField.Controls.Add(lblPrimaryID);
						if ( rdr != null )
						{
							Guid gPrimaryID = Sql.ToGuid(rdr["ID"]);
#if DEBUG
							lblPrimaryID.Text = gPrimaryID.ToString();
#endif
						}
					}
					if ( tbl.Rows.Count > nRowIndex )
					{
						tr = tbl.Rows[nRowIndex];
					}
					else
					{
						tr = new HtmlTableRow();
						tbl.Rows.Insert(nRowIndex, tr);
					}
					nRowIndex++;
				}
				// 12/03/2006 Paul.  Move literal label up so that it can be accessed when processing a blank. 
				Literal litLabel = new Literal();
				if ( !Sql.IsEmptyString(sDATA_FIELD) )
					litLabel.ID = sDATA_FIELD + "_LABEL" + sIDSuffix;
				if ( nCOLSPAN >= 0 || tdLabel == null || tdField == null )
				{
					tdLabel = new HtmlTableCell();
					tdField = new HtmlTableCell();
					tr.Cells.Add(tdLabel);
					tr.Cells.Add(tdField);
					if ( nCOLSPAN > 0 )
					{
						tdField.ColSpan = nCOLSPAN;
					}
					tdLabel.Attributes.Add("class", "dataLabel");
					tdLabel.VAlign = "top";
					tdLabel.Width  = sFIELD_WIDTH;
					tdField.Attributes.Add("class", "dataField");
					tdField.VAlign = "top";
					tdField.Width  = sFIELD_WIDTH;

					tdLabel.Controls.Add(litLabel);
					//litLabel.Text = nFIELD_INDEX.ToString() + " (" + nRowIndex.ToString() + "," + nColIndex.ToString() + ")";
					try
					{
						// 12/03/2006 Paul.  Move code to blank able in layout mode to blank section below. 
						if ( sDATA_LABEL.IndexOf(".") >= 0 )
							litLabel.Text = L10n.Term(sDATA_LABEL);
						else if ( !Sql.IsEmptyString(sDATA_LABEL) && rdr != null )
						{
							// 01/27/2008 Paul.  If the data label is not in the schema table, then it must be free-form text. 
							// It is not used often, but we allow the label to come from the result set.  For example,
							// when the parent is stored in the record, we need to pull the module name from the record. 
							litLabel.Text = sDATA_LABEL;
							if ( rdr.DataView.Table.Columns.Contains(sDATA_LABEL) )
								litLabel.Text = Sql.ToString(rdr[sDATA_LABEL]) + L10n.Term("Calls.LBL_COLON");
						}
						// 07/15/2006 Paul.  Always put something for the label so that table borders will look right. 
						// 07/20/2007 Vandalo.  Skip the requirement to create a terminology entry and just so the label. 
						else
							litLabel.Text = sDATA_LABEL;  // "&nbsp;";
					}
					catch(Exception ex)
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						litLabel.Text = ex.Message;
					}
					if ( bUI_REQUIRED )
					{
						Label lblRequired = new Label();
						tdLabel.Controls.Add(lblRequired);
						lblRequired.CssClass = "required";
						lblRequired.Text = L10n.Term(".LBL_REQUIRED_SYMBOL");
					}
				}
				
				if ( String.Compare(sFIELD_TYPE, "Label", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						Literal litField = new Literal();
						tdField.Controls.Add(litField);
						// 07/25/2006 Paul.  Align label values to the middle so the line-up with the label. 
						tdField.VAlign = "middle";
						// 07/24/2006 Paul.  Set the ID so that the literal control can be accessed. 
						litField.ID = sDATA_FIELD + sIDSuffix;
						try
						{
							// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
							if ( sDATA_FIELD.IndexOf(".") >= 0 )
								litField.Text = L10n.Term(sDATA_FIELD);
							else if ( rdr != null )
								litField.Text = HttpUtility.HtmlEncode(Sql.ToString(rdr[sDATA_FIELD]));
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							litField.Text = ex.Message;
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "ListBox", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/02/2007 Paul.  If format rows > 0 then this is a list box and not a drop down list. 
						ListControl lstField = null;
						if ( nFORMAT_ROWS > 0 )
						{
							ListBox lb = new ListBox();
							lb.SelectionMode = ListSelectionMode.Multiple;
							lb.Rows          = nFORMAT_ROWS;
							lstField = lb;
						}
						else
						{
							// 04/25/2008 Paul.  Use KeySortDropDownList instead of ListSearchExtender. 
							lstField = new KeySortDropDownList();
							// 07/23/2010 Paul.  Lets try the latest version of the ListSearchExtender. 
							// 07/28/2010 Paul.  We are getting an undefined exception on the Accounts List Advanced page. 
							// Lets drop back to using KeySort. 
							//lstField = new DropDownList();
						}
						tdField.Controls.Add(lstField);
						lstField.ID       = sDATA_FIELD + sIDSuffix;
						lstField.TabIndex = nFORMAT_TAB_INDEX;
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						lstField.Enabled  = bIsWriteable;
						// 07/23/2010 Paul.  Lets try the latest version of the ListSearchExtender. 
						// 07/28/2010 Paul.  We are getting an undefined exception on the Accounts List Advanced page. 
						/*
						if ( nFORMAT_ROWS == 0 )
						{
							AjaxControlToolkit.ListSearchExtender extField = new AjaxControlToolkit.ListSearchExtender();
							extField.ID              = lstField.ID + "_ListSearchExtender";
							extField.TargetControlID = lstField.ID;
							extField.PromptText      = L10n.Term(".LBL_TYPE_TO_SEARCH");
							extField.PromptCssClass  = "ListSearchExtenderPrompt";
							tdField.Controls.Add(extField);
						}
						*/
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) )
							{
								// 12/04/2005 Paul.  Don't populate list if this is a post back. 
								if ( !Sql.IsEmptyString(sCACHE_NAME) && (!bIsPostBack) )
								{
									// 12/24/2007 Paul.  Use an array to define the custom caches so that list is in the Cache module. 
									// This should reduce the number of times that we have to edit the SplendidDynamic module. 
									// 02/16/2012 Paul.  Move custom cache logic to a method. 
									SplendidCache.SetListSource(sCACHE_NAME, lstField);
									lstField.DataBind();
									// 08/08/2006 Paul.  Allow onchange code to be stored in the database.  
									// ListBoxes do not have a useful onclick event, so there should be no problem overloading this field. 
									if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
										lstField.Attributes.Add("onchange" , sONCLICK_SCRIPT);
									// 02/21/2006 Paul.  Move the NONE item inside the !IsPostBack code. 
									// 12/02/2007 Paul.  We don't need a NONE record when using multi-selection. 
									// 12/03/2007 Paul.  We do want the NONE record when using multi-selection. 
									// This will allow searching of fields that are null instead of using the unassigned only checkbox. 
									if ( !bUI_REQUIRED )
									{
										lstField.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
										// 12/02/2007 Paul.  AppendEditViewFields should be called inside Page_Load when not a postback, 
										// and in InitializeComponent when it is a postback. If done wrong, 
										// the page will bind after the list is populated, causing the list to populate again. 
										// This event will cause the NONE entry to be cleared.  Add a handler to catch this problem, 
										// but the real solution is to call AppendEditViewFields at the appropriate times based on the postback event. 
										lstField.DataBound += new EventHandler(SplendidDynamic.ListControl_DataBound_AllowNull);
									}
								}
								if ( rdr != null )
								{
									try
									{
										// 02/21/2006 Paul.  All the DropDownLists in the Calls and Meetings edit views were not getting set.  
										// The problem was a Page.DataBind in the SchedulingGrid and in the InviteesView. Both binds needed to be removed. 
										// 12/30/2007 Paul.  A customer needed the ability to save and restore the multiple selection. 
										// 12/30/2007 Paul.  Require the XML declaration in the data before trying to treat as XML. 
										string sVALUE = Sql.ToString(rdr[sDATA_FIELD]);
										if ( nFORMAT_ROWS > 0 && sVALUE.StartsWith("<?xml") )
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
												foreach ( ListItem item in lstField.Items )
												{
													if ( item.Value == xValue.InnerText )
														item.Selected = true;
												}
											}
										}
										else
										{
											// 08/19/2010 Paul.  Check the list before assigning the value. 
											Utils.SetSelectedValue(lstField, sVALUE);
										}
									}
									catch(Exception ex)
									{
										SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
									}
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				// 08/21/2010 Paul.  Add support for Radio buttons. 
				else if ( String.Compare(sFIELD_TYPE, "Radio", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						ListControl lstField = new RadioButtonList();
						tdField.Controls.Add(lstField);
						lstField.ID       = sDATA_FIELD + sIDSuffix;
						lstField.TabIndex = nFORMAT_TAB_INDEX;
						lstField.CssClass = "radio";
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						lstField.Enabled  = bIsWriteable;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) )
							{
								// 12/04/2005 Paul.  Don't populate list if this is a post back. 
								if ( !Sql.IsEmptyString(sCACHE_NAME) && (!bIsPostBack) )
								{
									// 12/24/2007 Paul.  Use an array to define the custom caches so that list is in the Cache module. 
									// This should reduce the number of times that we have to edit the SplendidDynamic module. 
									// 02/16/2012 Paul.  Move custom cache logic to a method. 
									SplendidCache.SetListSource(sCACHE_NAME, lstField);
									lstField.DataBind();
									if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
										lstField.Attributes.Add("onchange" , sONCLICK_SCRIPT);
									if ( !bUI_REQUIRED )
									{
										lstField.Items.Insert(0, new ListItem(L10n.Term(".LBL_NONE"), ""));
										lstField.DataBound += new EventHandler(SplendidDynamic.ListControl_DataBound_AllowNull);
									}
								}
								if ( rdr != null )
								{
									try
									{
										string sVALUE = Sql.ToString(rdr[sDATA_FIELD]);
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
												foreach ( ListItem item in lstField.Items )
												{
													if ( item.Value == xValue.InnerText )
														item.Selected = true;
												}
											}
										}
										else
										{
											// 08/19/2010 Paul.  Check the list before assigning the value. 
											Utils.SetSelectedValue(lstField, sVALUE);
										}
									}
									catch(Exception ex)
									{
										SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
									}
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				// 08/21/2010 Paul.  Add support for CheckBoxList. 
				else if ( String.Compare(sFIELD_TYPE, "CheckBoxList", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/02/2007 Paul.  If format rows > 0 then this is a list box and not a drop down list. 
						ListControl lstField = new CheckBoxList();
						tdField.Controls.Add(lstField);
						lstField.ID       = sDATA_FIELD + sIDSuffix;
						lstField.TabIndex = nFORMAT_TAB_INDEX;
						lstField.CssClass = "checkbox";
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						lstField.Enabled  = bIsWriteable;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) )
							{
								// 12/04/2005 Paul.  Don't populate list if this is a post back. 
								if ( !Sql.IsEmptyString(sCACHE_NAME) && (!bIsPostBack) )
								{
									// 12/24/2007 Paul.  Use an array to define the custom caches so that list is in the Cache module. 
									// This should reduce the number of times that we have to edit the SplendidDynamic module. 
									// 02/16/2012 Paul.  Move custom cache logic to a method. 
									SplendidCache.SetListSource(sCACHE_NAME, lstField);
									lstField.DataBind();
									if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
										lstField.Attributes.Add("onchange" , sONCLICK_SCRIPT);
								}
								if ( rdr != null )
								{
									try
									{
										string sVALUE = Sql.ToString(rdr[sDATA_FIELD]);
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
												foreach ( ListItem item in lstField.Items )
												{
													if ( item.Value == xValue.InnerText )
														item.Selected = true;
												}
											}
										}
										else
										{
											// 08/19/2010 Paul.  Check the list before assigning the value. 
											Utils.SetSelectedValue(lstField, sVALUE);
										}
									}
									catch(Exception ex)
									{
										SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
									}
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "CheckBox", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						CheckBox chkField = new CheckBox();
						tdField.Controls.Add(chkField);
						chkField.ID = sDATA_FIELD + sIDSuffix;
						chkField.CssClass = "checkbox";
						chkField.TabIndex = nFORMAT_TAB_INDEX;
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						chkField.Enabled  = bIsWriteable;
						try
						{
							if ( rdr != null )
								chkField.Checked = Sql.ToBoolean(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						// 07/11/2007 Paul.  A checkbox can have a click event. 
						if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
							chkField.Attributes.Add("onclick", sONCLICK_SCRIPT);
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "ChangeButton", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						//05/06/2010 Paul.  Manually generate ClearModuleType so that it will be UpdatePanel safe. 
						DropDownList lstField = null;
						// 12/04/2005 Paul.  If the label is PARENT_TYPE, then change the label to a DropDownList.
						if ( sDATA_LABEL == "PARENT_TYPE" )
						{
							tdLabel.Controls.Clear();
							// 04/25/2008 Paul.  Use KeySortDropDownList instead of ListSearchExtender. 
							lstField = new KeySortDropDownList();
							// 07/23/2010 Paul.  Lets try the latest version of the ListSearchExtender. 
							// 07/28/2010 Paul.  We are getting an undefined exception on the Accounts List Advanced page. 
							// Lets drop back to using KeySort. 
							//lstField = new DropDownList();
							tdLabel.Controls.Add(lstField);
							lstField.ID       = sDATA_LABEL + sIDSuffix;
							lstField.TabIndex = nFORMAT_TAB_INDEX;
							// 07/23/2010 Paul.  Lets try the latest version of the ListSearchExtender. 
							// 07/28/2010 Paul.  We are getting an undefined exception on the Accounts List Advanced page. 
							/*
							if ( nFORMAT_ROWS == 0 )
							{
								AjaxControlToolkit.ListSearchExtender extField = new AjaxControlToolkit.ListSearchExtender();
								extField.ID              = lstField.ID + "_ListSearchExtender";
								extField.TargetControlID = lstField.ID;
								extField.PromptText      = L10n.Term(".LBL_TYPE_TO_SEARCH");
								extField.PromptCssClass  = "ListSearchExtenderPrompt";
								tdLabel.Controls.Add(extField);
							}
							*/
							if ( !bIsPostBack )
							{
								// 07/29/2005 Paul.  SugarCRM 3.0 does not allow the NONE option. 
								lstField.DataValueField = "NAME"        ;
								lstField.DataTextField  = "DISPLAY_NAME";
								lstField.DataSource     = SplendidCache.List("record_type_display");
								lstField.DataBind();
								if ( rdr != null )
								{
									try
									{
										// 08/19/2010 Paul.  Check the list before assigning the value. 
										Utils.SetSelectedValue(lstField, Sql.ToString(rdr[sDATA_LABEL]));
									}
									catch(Exception ex)
									{
										SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
									}
								}
							}
						}
						TextBox txtNAME = new TextBox();
						tdField.Controls.Add(txtNAME);
						txtNAME.ID       = sDISPLAY_FIELD + sIDSuffix;
						txtNAME.ReadOnly = true;
						txtNAME.TabIndex = nFORMAT_TAB_INDEX;
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						txtNAME.Enabled  = bIsWriteable;
						// 11/25/2006 Paul.   Turn off viewstate so that we can fix the text on postback. 
						txtNAME.EnableViewState = false;
						try
						{
							if ( bIsPostBack )
							{
								// 11/25/2006 Paul.  In order for this posback fix to work, viewstate must be disabled for this field. 
								if ( tbl.Page.Request[txtNAME.UniqueID] != null )
									txtNAME.Text = Sql.ToString(tbl.Page.Request[txtNAME.UniqueID]);
							}
							else if ( !Sql.IsEmptyString(sDISPLAY_FIELD) && rdr != null )
								txtNAME.Text = Sql.ToString(rdr[sDISPLAY_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						HtmlInputHidden hidID = new HtmlInputHidden();
						tdField.Controls.Add(hidID);
						hidID.ID = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
								hidID.Value = Sql.ToString(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						//05/06/2010 Paul.  Manually generate ClearModuleType so that it will be UpdatePanel safe. 
						// 07/27/2010 Paul.  Add the ability to submit after clear. 
						if ( sDATA_LABEL == "PARENT_TYPE" && lstField != null )
							lstField.Attributes.Add("onChange", "ClearModuleType('', '" + hidID.ClientID + "', '" + txtNAME.ClientID + "', false);");
						
						Literal litNBSP = new Literal();
						tdField.Controls.Add(litNBSP);
						litNBSP.Text = "&nbsp;";
						
						HtmlInputButton btnChange = new HtmlInputButton("button");
						tdField.Controls.Add(btnChange);
						// 05/07/2006 Paul.  Specify a name for the check button so that it can be referenced by SplendidTest. 
						btnChange.ID = sDATA_FIELD + "_btnChange" + sIDSuffix;
						btnChange.Attributes.Add("class", "button");
						//05/06/2010 Paul.  Manually generate ParentPopup so that it will be UpdatePanel safe. 
						if ( lstField != null )
							btnChange.Attributes.Add("onclick", "return ModulePopup(document.getElementById('" + lstField.ClientID + "').options[document.getElementById('" + lstField.ClientID + "').options.selectedIndex].value, '" + hidID.ClientID + "', '" + txtNAME.ClientID + "', null, false, null);");
						else if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
							btnChange.Attributes.Add("onclick"  , sONCLICK_SCRIPT);
						// 03/31/2007 Paul.  SugarCRM now uses Select instead of Change. 
						btnChange.Attributes.Add("title"    , L10n.Term(".LBL_SELECT_BUTTON_TITLE"));
						// 07/31/2006 Paul.  Stop using VisualBasic library to increase compatibility with Mono. 
						// 03/31/2007 Paul.  Stop using AccessKey for change button. 
						//btnChange.Attributes.Add("accessKey", L10n.Term(".LBL_SELECT_BUTTON_KEY").Substring(0, 1));
						btnChange.Value = L10n.Term(".LBL_SELECT_BUTTON_LABEL");
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						btnChange.Disabled = !bIsWriteable;

						// 12/03/2007 Paul.  Also create a Clear button. 
						// 05/06/2010 Paul.  A Parent Type will always have a clear button. 
						if ( sONCLICK_SCRIPT.IndexOf("Popup();") > 0 || sDATA_LABEL == "PARENT_TYPE" )
						{
							litNBSP = new Literal();
							tdField.Controls.Add(litNBSP);
							litNBSP.Text = "&nbsp;";
							
							HtmlInputButton btnClear = new HtmlInputButton("button");
							tdField.Controls.Add(btnClear);
							btnClear.ID = sDATA_FIELD + "_btnClear" + sIDSuffix;
							btnClear.Attributes.Add("class", "button");
							//05/06/2010 Paul.  Manually generate ClearModuleType so that it will be UpdatePanel safe. 
							// 07/27/2010 Paul.  Add the ability to submit after clear. 
							btnClear.Attributes.Add("onclick"  , "return ClearModuleType('', '" + hidID.ClientID + "', '" + txtNAME.ClientID + "', false);");
							btnClear.Attributes.Add("title"    , L10n.Term(".LBL_CLEAR_BUTTON_TITLE"));
							btnClear.Value = L10n.Term(".LBL_CLEAR_BUTTON_LABEL");
							// 08/01/2010 Paul.  Apply ACL Field Security. 
							btnClear.Disabled  = !bIsWriteable;
						}
						if ( bUI_REQUIRED && !Sql.IsEmptyString(sDATA_FIELD) )
						{
							RequiredFieldValidatorForHiddenInputs reqID = new RequiredFieldValidatorForHiddenInputs();
							reqID.ID                 = sDATA_FIELD + "_REQUIRED" + sIDSuffix;
							reqID.ControlToValidate  = hidID.ID;
							reqID.ErrorMessage       = L10n.Term(".ERR_REQUIRED_FIELD");
							reqID.CssClass           = "required";
							reqID.EnableViewState    = false;
							// 01/16/2006 Paul.  We don't enable required fields until we attempt to save. 
							// This is to allow unrelated form actions; the Cancel button is a good example. 
							reqID.EnableClientScript = false;
							reqID.Enabled            = false;
							// 02/21/2008 Paul.  Add a little padding. 
							reqID.Style.Add("padding-left", "4px");
							tdField.Controls.Add(reqID);
						}
					}
				}
				// 09/01/2009 Paul.  Add support for ModulePopups.
				// 08/01/2010 Paul.  Lets do the same for ModuleAutoComplete. 
				else if ( String.Compare(sFIELD_TYPE, "ModulePopup", true) == 0 || String.Compare(sFIELD_TYPE, "ModuleAutoComplete", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						TextBox txtNAME = new TextBox();
						tdField.Controls.Add(txtNAME);
						// 10/05/2010 Paul.  A custom field will not have a display field, but we still want to be able to access by name. 
						txtNAME.ID       = (Sql.IsEmptyString(sDISPLAY_FIELD) ? sDATA_FIELD + "_NAME" : sDISPLAY_FIELD) + sIDSuffix;
						txtNAME.ReadOnly = true;
						txtNAME.TabIndex = nFORMAT_TAB_INDEX;
						// 11/25/2006 Paul.   Turn off viewstate so that we can fix the text on postback. 
						txtNAME.EnableViewState = false;
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						txtNAME.Enabled  = bIsWriteable;
						try
						{
							if ( bIsPostBack )
							{
								// 11/25/2006 Paul.  In order for this posback fix to work, viewstate must be disabled for this field. 
								if ( tbl.Page.Request[txtNAME.UniqueID] != null )
									txtNAME.Text = Sql.ToString(tbl.Page.Request[txtNAME.UniqueID]);
							}
							// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
							else if ( !Sql.IsEmptyString(sDISPLAY_FIELD) && rdr != null )
								txtNAME.Text = HttpUtility.HtmlEncode(Sql.ToString(rdr[sDISPLAY_FIELD]));
							else if ( rdr != null )
								txtNAME.Text = HttpUtility.HtmlEncode(Crm.Modules.ItemName(Application, sMODULE_TYPE, rdr[sDATA_FIELD]));
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						HtmlInputHidden hidID = new HtmlInputHidden();
						tdField.Controls.Add(hidID);
						hidID.ID = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
								hidID.Value = Sql.ToString(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtNAME.Text = ex.Message;
						}
						
						Literal litNBSP = new Literal();
						tdField.Controls.Add(litNBSP);
						litNBSP.Text = "&nbsp;";
						
						HtmlInputButton btnChange = new HtmlInputButton("button");
						tdField.Controls.Add(btnChange);
						// 05/07/2006 Paul.  Specify a name for the check button so that it can be referenced by SplendidTest. 
						btnChange.ID = sDATA_FIELD + "_btnChange" + sIDSuffix;
						btnChange.Attributes.Add("class", "button");
						if ( !Sql.IsEmptyString(sONCLICK_SCRIPT) )
							btnChange.Attributes.Add("onclick"  , sONCLICK_SCRIPT);
						else
							btnChange.Attributes.Add("onclick"  , "return ModulePopup('" + sMODULE_TYPE + "', '" + hidID.ClientID + "', '" + txtNAME.ClientID + "', null, false, null);");
						// 03/31/2007 Paul.  SugarCRM now uses Select instead of Change. 
						btnChange.Attributes.Add("title"    , L10n.Term(".LBL_SELECT_BUTTON_TITLE"));
						// 07/31/2006 Paul.  Stop using VisualBasic library to increase compatibility with Mono. 
						// 03/31/2007 Paul.  Stop using AccessKey for change button. 
						//btnChange.Attributes.Add("accessKey", L10n.Term(".LBL_SELECT_BUTTON_KEY").Substring(0, 1));
						btnChange.Value = L10n.Term(".LBL_SELECT_BUTTON_LABEL");
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						btnChange.Disabled = !bIsWriteable;

						litNBSP = new Literal();
						tdField.Controls.Add(litNBSP);
						litNBSP.Text = "&nbsp;";
						
						HtmlInputButton btnClear = new HtmlInputButton("button");
						tdField.Controls.Add(btnClear);
						btnClear.ID = sDATA_FIELD + "_btnClear" + sIDSuffix;
						btnClear.Attributes.Add("class", "button");
						// 07/27/2010 Paul.  Add the ability to submit after clear. 
						btnClear.Attributes.Add("onclick"  , "return ClearModuleType('" + sMODULE_TYPE + "', '" + hidID.ClientID + "', '" + txtNAME.ClientID + "', false);");
						btnClear.Attributes.Add("title"    , L10n.Term(".LBL_CLEAR_BUTTON_TITLE"));
						btnClear.Value = L10n.Term(".LBL_CLEAR_BUTTON_LABEL");
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						btnClear.Disabled = !bIsWriteable;

						if ( bUI_REQUIRED && !Sql.IsEmptyString(sDATA_FIELD) )
						{
							RequiredFieldValidatorForHiddenInputs reqID = new RequiredFieldValidatorForHiddenInputs();
							reqID.ID                 = sDATA_FIELD + "_REQUIRED" + sIDSuffix;
							reqID.ControlToValidate  = hidID.ID;
							reqID.ErrorMessage       = L10n.Term(".ERR_REQUIRED_FIELD");
							reqID.CssClass           = "required";
							reqID.EnableViewState    = false;
							// 01/16/2006 Paul.  We don't enable required fields until we attempt to save. 
							// This is to allow unrelated form actions; the Cancel button is a good example. 
							reqID.EnableClientScript = false;
							reqID.Enabled            = false;
							// 02/21/2008 Paul.  Add a little padding. 
							reqID.Style.Add("padding-left", "4px");
							tdField.Controls.Add(reqID);
						}
					}
				}
				// 04/13/2016 Paul.  Add ZipCode lookup. 
				else if ( String.Compare(sFIELD_TYPE, "TextBox", true) == 0 || String.Compare(sFIELD_TYPE, "Password", true) == 0 || String.Compare(sFIELD_TYPE, "ZipCodePopup", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						TextBox txtField = new TextBox();
						tdField.Controls.Add(txtField);
						txtField.ID       = sDATA_FIELD + sIDSuffix;
						txtField.TabIndex = nFORMAT_TAB_INDEX;
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						txtField.Enabled  = bIsWriteable;
						try
						{
							if ( nFORMAT_ROWS > 0 && nFORMAT_COLUMNS > 0 )
							{
								txtField.Rows     = nFORMAT_ROWS   ;
								txtField.Columns  = nFORMAT_COLUMNS;
								txtField.TextMode = TextBoxMode.MultiLine;
							}
							else
							{
								txtField.MaxLength = nFORMAT_MAX_LENGTH   ;
								txtField.Attributes.Add("size", nFORMAT_SIZE.ToString());
								txtField.TextMode  = TextBoxMode.SingleLine;
							}
							if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
							{
								if ( rdr[sDATA_FIELD].GetType() == typeof(System.Decimal) )
									txtField.Text = Sql.ToDecimal(rdr[sDATA_FIELD]).ToString("#,##0.00");
								else
									txtField.Text = Sql.ToString(rdr[sDATA_FIELD]);
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtField.Text = ex.Message;
						}
						if ( String.Compare(sFIELD_TYPE, "Password", true) == 0 )
							txtField.TextMode = TextBoxMode.Password;
						if ( bUI_REQUIRED && !Sql.IsEmptyString(sDATA_FIELD) )
						{
							RequiredFieldValidator reqNAME = new RequiredFieldValidator();
							reqNAME.ID                 = sDATA_FIELD + "_REQUIRED" + sIDSuffix;
							reqNAME.ControlToValidate  = txtField.ID;
							reqNAME.ErrorMessage       = L10n.Term(".ERR_REQUIRED_FIELD");
							reqNAME.CssClass           = "required";
							reqNAME.EnableViewState    = false;
							// 01/16/2006 Paul.  We don't enable required fields until we attempt to save. 
							// This is to allow unrelated form actions; the Cancel button is a good example. 
							reqNAME.EnableClientScript = false;
							reqNAME.Enabled            = false;
							reqNAME.Style.Add("padding-left", "4px");
							tdField.Controls.Add(reqNAME);
						}
						if ( !Sql.IsEmptyString(sDATA_FIELD) )
						{
							if ( sVALIDATION_TYPE == "RegularExpressionValidator" && !Sql.IsEmptyString(sREGULAR_EXPRESSION) && !Sql.IsEmptyString(sFIELD_VALIDATOR_MESSAGE) && bIsWriteable )
							{
								RegularExpressionValidator reqVALIDATOR = new RegularExpressionValidator();
								reqVALIDATOR.ID                   = sDATA_FIELD + "_VALIDATOR" + sIDSuffix;
								reqVALIDATOR.ControlToValidate    = txtField.ID;
								reqVALIDATOR.ErrorMessage         = L10n.Term(sFIELD_VALIDATOR_MESSAGE);
								reqVALIDATOR.ValidationExpression = sREGULAR_EXPRESSION;
								reqVALIDATOR.CssClass             = "required";
								reqVALIDATOR.EnableViewState      = false;
								// 04/02/2008 Paul.  We don't enable required fields until we attempt to save. 
								// This is to allow unrelated form actions; the Cancel button is a good example. 
								reqVALIDATOR.EnableClientScript   = false;
								reqVALIDATOR.Enabled              = false;
								reqVALIDATOR.Style.Add("padding-left", "4px");
								tdField.Controls.Add(reqVALIDATOR);
							}
						}
					}
				}
				// 04/04/2011 Paul.  Add support for HtmlEditor. 
				else if ( String.Compare(sFIELD_TYPE, "HtmlEditor", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 09/18/2011 Paul.  Upgrade to CKEditor 3.6.2. 
						CKEditorControl txtField = new CKEditorControl();
						tdField.Controls.Add(txtField);
						txtField.ID         = sDATA_FIELD;
						txtField.Toolbar    = "SplendidCRM";
						// 09/18/2011 Paul.  Set the language for CKEditor. 
						txtField.Language   = L10n.NAME;
						txtField.BasePath   = "~/ckeditor/";
						// 04/26/2012 Paul.  Add file uploader. 
						txtField.FilebrowserUploadUrl    = txtField.ResolveUrl("~/ckeditor/upload.aspx");
						txtField.FilebrowserBrowseUrl    = txtField.ResolveUrl("~/Images/Popup.aspx");
						//txtField.FilebrowserWindowWidth  = "640";
						//txtField.FilebrowserWindowHeight = "480";
						txtField.Visible  = bIsWriteable;
						try
						{
							if ( nFORMAT_ROWS > 0 && nFORMAT_COLUMNS > 0 )
							{
								txtField.Height = nFORMAT_ROWS   ;
								// 04/04/2011 Paul.  Reduce the width to make it easier to edit. 
								txtField.Width  = nFORMAT_COLUMNS / 2;
							}
							if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
							{
								txtField.Text = Sql.ToString(rdr[sDATA_FIELD]);
								// 01/18/2010 Paul.  FCKEditor does not have an Enable field, so just hide and replace with a Literal control. 
								if ( !bIsWriteable )
								{
									txtField.Visible = false;
									Literal litField = new Literal();
									litField.ID = sDATA_FIELD + "_ReadOnly";
									tdField.Controls.Add(litField);
									litField.Text = Sql.ToString(rdr[sDATA_FIELD]);
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							txtField.Text = ex.Message;
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "DatePicker", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/03/2005 Paul.  UserControls must be loaded. 
						DatePicker ctlDate = tbl.Page.LoadControl("~/_controls/DatePicker.ascx") as DatePicker;
						tdField.Controls.Add(ctlDate);
						ctlDate.ID = sDATA_FIELD + sIDSuffix;
						// 05/10/2006 Paul.  Set the tab index. 
						ctlDate.TabIndex = nFORMAT_TAB_INDEX;
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						ctlDate.Enabled  = bIsWriteable;
						try
						{
							if ( rdr != null )
								ctlDate.Value = T10n.FromServerTime(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "DateRange", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/17/2007 Paul.  Use table to align before and after labels. 
						Table tblDateRange = new Table();
						tdField.Controls.Add(tblDateRange);
						TableRow trAfter = new TableRow();
						TableRow trBefore = new TableRow();
						tblDateRange.Rows.Add(trAfter);
						tblDateRange.Rows.Add(trBefore);
						TableCell tdAfterLabel  = new TableCell();
						TableCell tdAfterData   = new TableCell();
						TableCell tdBeforeLabel = new TableCell();
						TableCell tdBeforeData  = new TableCell();
						trAfter .Cells.Add(tdAfterLabel );
						trAfter .Cells.Add(tdAfterData  );
						trBefore.Cells.Add(tdBeforeLabel);
						trBefore.Cells.Add(tdBeforeData );

						// 12/03/2005 Paul.  UserControls must be loaded. 
						DatePicker ctlDateStart = tbl.Page.LoadControl("~/_controls/DatePicker.ascx") as DatePicker;
						DatePicker ctlDateEnd   = tbl.Page.LoadControl("~/_controls/DatePicker.ascx") as DatePicker;
						Literal litAfterLabel  = new Literal();
						Literal litBeforeLabel = new Literal();
						litAfterLabel .Text = L10n.Term("SavedSearch.LBL_SEARCH_AFTER" );
						litBeforeLabel.Text = L10n.Term("SavedSearch.LBL_SEARCH_BEFORE");
						//tdField.Controls.Add(litAfterLabel );
						//tdField.Controls.Add(ctlDateStart  );
						//tdField.Controls.Add(litBeforeLabel);
						//tdField.Controls.Add(ctlDateEnd    );
						tdAfterLabel .Controls.Add(litAfterLabel );
						tdAfterData  .Controls.Add(ctlDateStart  );
						tdBeforeLabel.Controls.Add(litBeforeLabel);
						tdBeforeData .Controls.Add(ctlDateEnd    );

						ctlDateStart.ID = sDATA_FIELD + "_AFTER" + sIDSuffix;
						ctlDateEnd  .ID = sDATA_FIELD + "_BEFORE" + sIDSuffix;
						// 05/10/2006 Paul.  Set the tab index. 
						ctlDateStart.TabIndex = nFORMAT_TAB_INDEX;
						ctlDateEnd  .TabIndex = nFORMAT_TAB_INDEX;
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						ctlDateStart.Enabled  = bIsWriteable;
						ctlDateEnd  .Enabled  = bIsWriteable;
						try
						{
							if ( rdr != null )
							{
								ctlDateStart.Value = T10n.FromServerTime(rdr[sDATA_FIELD]);
								ctlDateEnd  .Value = T10n.FromServerTime(rdr[sDATA_FIELD]);
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "DateTimePicker", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/03/2005 Paul.  UserControls must be loaded. 
						DateTimePicker ctlDate = tbl.Page.LoadControl("~/_controls/DateTimePicker.ascx") as DateTimePicker;
						tdField.Controls.Add(ctlDate);
						ctlDate.ID = sDATA_FIELD + sIDSuffix;
						// 05/10/2006 Paul.  Set the tab index. 
						ctlDate.TabIndex = nFORMAT_TAB_INDEX;
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						ctlDate.Enabled  = bIsWriteable;
						try
						{
							if ( rdr != null )
								ctlDate.Value = T10n.FromServerTime(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "DateTimeEdit", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						// 12/03/2005 Paul.  UserControls must be loaded. 
						DateTimeEdit ctlDate = tbl.Page.LoadControl("~/_controls/DateTimeEdit.ascx") as DateTimeEdit;
						tdField.Controls.Add(ctlDate);
						ctlDate.ID = sDATA_FIELD + sIDSuffix;
						// 05/10/2006 Paul.  Set the tab index. 
						ctlDate.TabIndex = nFORMAT_TAB_INDEX;
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						ctlDate.Enabled  = bIsWriteable;
						try
						{
							if ( rdr != null )
								ctlDate.Value = T10n.FromServerTime(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
						if ( bUI_REQUIRED )
						{
							ctlDate.EnableNone = false;
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "File", true) == 0 )
				{
					// 11/23/2010 Paul.  File should act just like an image. 
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						HtmlInputHidden ctlHidden = null;
						HtmlInputFile   ctlField  = new HtmlInputFile();
						tdField.Controls.Add(ctlField);
						// 04/17/2006 Paul.  The image needs to reference the file control. 
						// 11/25/2010 Paul.  Appending _File breaks the previous behavior of Notes, Bugs and Documents.
						// 11/25/2010 Paul.  The file field is special in that it may not exist as a table column. 
						ctlField.ID = sDATA_FIELD + sIDSuffix;
						if ( rdr != null )
						{
							if ( vwSchema.Contains(sDATA_FIELD) )
							{
								ctlField.ID = sDATA_FIELD + "_File" + sIDSuffix;
								ctlHidden = new HtmlInputHidden();
								tdField.Controls.Add(ctlHidden);
								ctlHidden.ID = sDATA_FIELD + sIDSuffix;
							}
						}
						ctlField.MaxLength = nFORMAT_MAX_LENGTH;
						ctlField.Size      = nFORMAT_SIZE;
						ctlField.Attributes.Add("TabIndex", nFORMAT_TAB_INDEX.ToString());
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						ctlField.Disabled  = !bIsWriteable;
						if ( bUI_REQUIRED )
						{
							RequiredFieldValidator reqNAME = new RequiredFieldValidator();
							reqNAME.ID                 = sDATA_FIELD + "_REQUIRED" + sIDSuffix;
							reqNAME.ControlToValidate  = ctlField.ID;
							reqNAME.ErrorMessage       = L10n.Term(".ERR_REQUIRED_FIELD");
							reqNAME.CssClass           = "required";
							reqNAME.EnableViewState    = false;
							// 01/16/2006 Paul.  We don't enable required fields until we attempt to save. 
							// This is to allow unrelated form actions; the Cancel button is a good example. 
							reqNAME.EnableClientScript = false;
							reqNAME.Enabled            = false;
							reqNAME.Style.Add("padding-left", "4px");
							tdField.Controls.Add(reqNAME);
						}

						Literal litBR = new Literal();
						litBR.Text = "<br />";
						tdField.Controls.Add(litBR);
						
						HyperLink lnkField = new HyperLink();
						// 04/13/2006 Paul.  Give the image a name so that it can be validated with SplendidTest. 
						lnkField.ID = "lnk" + sDATA_FIELD + sIDSuffix;
						try
						{
							if ( rdr != null )
							{
								// 11/25/2010 Paul.  The file field is special in that it may not exist as a table column. 
								if ( ctlHidden != null && !Sql.IsEmptyString(rdr[sDATA_FIELD]) )
								{
									ctlHidden.Value = Sql.ToString(rdr[sDATA_FIELD]);
									lnkField.NavigateUrl = "~/Images/Image.aspx?ID=" + ctlHidden.Value;
									lnkField.Text = Crm.Modules.ItemName(Application, "Images", ctlHidden.Value);
									// 04/13/2006 Paul.  Only add the image if it exists. 
									tdField.Controls.Add(lnkField);
									
									// 04/17/2006 Paul.  Provide a clear button. 
									Literal litClear = new Literal();
									litClear.Text = "&nbsp; <input type=\"button\" class=\"button\" onclick=\"document.getElementById('" + ctlHidden.ClientID + "').value='';document.getElementById('" + lnkField.ClientID + "').innerHTML='';" + "\"  value='" + "  " + L10n.Term(".LBL_CLEAR_BUTTON_LABEL" ) + "  " + "' title='" + L10n.Term(".LBL_CLEAR_BUTTON_TITLE" ) + "' />";
									tdField.Controls.Add(litClear);
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							Literal litField = new Literal();
							litField.Text = ex.Message;
							tdField.Controls.Add(litField);
						}
					}
				}
				else if ( String.Compare(sFIELD_TYPE, "Image", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						HtmlInputHidden ctlHidden = new HtmlInputHidden();
						tdField.Controls.Add(ctlHidden);
						ctlHidden.ID = sDATA_FIELD + sIDSuffix;

						HtmlInputFile ctlField = new HtmlInputFile();
						tdField.Controls.Add(ctlField);
						// 04/17/2006 Paul.  The image needs to reference the file control. 
						ctlField.ID = sDATA_FIELD + "_File" + sIDSuffix;
						ctlField.MaxLength = nFORMAT_MAX_LENGTH;
						ctlField.Size      = nFORMAT_SIZE;
						ctlField.Attributes.Add("TabIndex", nFORMAT_TAB_INDEX.ToString());
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						ctlField.Disabled  = !bIsWriteable;
						if ( bUI_REQUIRED )
						{
							RequiredFieldValidator reqNAME = new RequiredFieldValidator();
							reqNAME.ID                 = sDATA_FIELD + "_REQUIRED" + sIDSuffix;
							reqNAME.ControlToValidate  = ctlField.ID;
							reqNAME.ErrorMessage       = L10n.Term(".ERR_REQUIRED_FIELD");
							reqNAME.CssClass           = "required";
							reqNAME.EnableViewState    = false;
							// 01/16/2006 Paul.  We don't enable required fields until we attempt to save. 
							// This is to allow unrelated form actions; the Cancel button is a good example. 
							reqNAME.EnableClientScript = false;
							reqNAME.Enabled            = false;
							reqNAME.Style.Add("padding-left", "4px");
							tdField.Controls.Add(reqNAME);
						}

						Literal litBR = new Literal();
						litBR.Text = "<br />";
						tdField.Controls.Add(litBR);
						
						Image imgField = new Image();
						// 04/13/2006 Paul.  Give the image a name so that it can be validated with SplendidTest. 
						imgField.ID = "img" + sDATA_FIELD + sIDSuffix;
						try
						{
							if ( rdr != null )
							{
								if ( !Sql.IsEmptyString(rdr[sDATA_FIELD]) )
								{
									ctlHidden.Value = Sql.ToString(rdr[sDATA_FIELD]);
									imgField.ImageUrl = "~/Images/Image.aspx?ID=" + ctlHidden.Value;
									// 04/13/2006 Paul.  Only add the image if it exists. 
									tdField.Controls.Add(imgField);
									
									// 04/17/2006 Paul.  Provide a clear button. 
									Literal litClear = new Literal();
									litClear.Text = "&nbsp; <input type=\"button\" class=\"button\" onclick=\"document.getElementById('" + ctlHidden.ClientID + "').value='';document.getElementById('" + imgField.ClientID + "').src='';" + "\"  value='" + "  " + L10n.Term(".LBL_CLEAR_BUTTON_LABEL" ) + "  " + "' title='" + L10n.Term(".LBL_CLEAR_BUTTON_TITLE" ) + "' />";
									tdField.Controls.Add(litClear);
								}
							}
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
							Literal litField = new Literal();
							litField.Text = ex.Message;
							tdField.Controls.Add(litField);
						}
					}
				}
				// 04/04/2011 Paul.  Add support for hidden field. 
				else if ( String.Compare(sFIELD_TYPE, "Hidden", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						HtmlInputHidden hidID = new HtmlInputHidden();
						tdField.Controls.Add(hidID);
						hidID.ID = sDATA_FIELD + sIDSuffix;
						try
						{
							if ( !Sql.IsEmptyString(sDATA_FIELD) && rdr != null )
								hidID.Value = Sql.ToString(rdr[sDATA_FIELD]);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				// 08/01/2010 Paul.  Add support for dynamic teams. 
				else if ( String.Compare(sFIELD_TYPE, "TeamSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						TeamSelect ctlTeamSelect = tbl.Page.LoadControl("~/_controls/TeamSelect.ascx") as TeamSelect;
						tdField.Controls.Add(ctlTeamSelect);
						ctlTeamSelect.ID = sDATA_FIELD;
						// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
						ctlTeamSelect.NotPostBack = !bIsPostBack;
						//ctlTeamSelect.TabIndex = nFORMAT_TAB_INDEX;
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						ctlTeamSelect.Enabled  = bIsWriteable;
						try
						{
							Guid gTEAM_SET_ID = Guid.Empty;
							if ( rdr != null )
							{
								if ( vwSchema.Contains("TEAM_SET_ID") )
								{
									gTEAM_SET_ID = Sql.ToGuid(rdr["TEAM_SET_ID"]);
								}
							}
							// 08/31/2009 Paul. Don't provide defaults in a Search view or a Popup view. 
							bool bAllowDefaults = sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".Popup") < 0;
							ctlTeamSelect.LoadLineItems(gTEAM_SET_ID, bAllowDefaults);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				// 08/08/2018 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
				else if ( String.Compare(sFIELD_TYPE, "UserSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						UserSelect ctlUserSelect = tbl.Page.LoadControl("~/_controls/UserSelect.ascx") as UserSelect;
						tdField.Controls.Add(ctlUserSelect);
						ctlUserSelect.ID = sDATA_FIELD;
						// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
						ctlUserSelect.NotPostBack = !bIsPostBack;
						//ctlUserSelect.TabIndex = nFORMAT_TAB_INDEX;
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						ctlUserSelect.Enabled  = bIsWriteable;
						try
						{
							Guid gTEAM_SET_ID = Guid.Empty;
							if ( rdr != null )
							{
								if ( vwSchema.Contains("USER_SET_ID") )
								{
									gTEAM_SET_ID = Sql.ToGuid(rdr["USER_SET_ID"]);
								}
							}
							// 08/31/2009 Paul. Don't provide defaults in a Search view or a Popup view. 
							bool bAllowDefaults = sEDIT_NAME.IndexOf(".Search") < 0 && sEDIT_NAME.IndexOf(".Popup") < 0;
							ctlUserSelect.LoadLineItems(gTEAM_SET_ID, bAllowDefaults);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				// 08/08/2011 Paul.  Add support for Tag Select. 
				else if ( String.Compare(sFIELD_TYPE, "TagSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						TagSelect ctlTagSelect = tbl.Page.LoadControl("~/_controls/TagSelect.ascx") as TagSelect;
						tdField.Controls.Add(ctlTagSelect);
						ctlTagSelect.ID = sDATA_FIELD;
						ctlTagSelect.NotPostBack = !bIsPostBack;
						ctlTagSelect.Enabled  = bIsWriteable;
						try
						{
							Guid gID = Guid.Empty;
							if ( rdr != null )
							{
								gID = Sql.ToGuid(rdr["ID"]);
							}
							ctlTagSelect.LoadLineItems(gID, false);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				// 08/08/2011 Paul.  Add support for NAICS Code Select. 
				else if ( String.Compare(sFIELD_TYPE, "NAICSCodeSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						NAICSCodeSelect ctlNAICSCodeSelect = tbl.Page.LoadControl("~/_controls/NAICSCodeSelect.ascx") as NAICSCodeSelect;
						tdField.Controls.Add(ctlNAICSCodeSelect);
						ctlNAICSCodeSelect.ID = sDATA_FIELD;
						ctlNAICSCodeSelect.NotPostBack = !bIsPostBack;
						ctlNAICSCodeSelect.Enabled  = bIsWriteable;
						try
						{
							Guid gID = Guid.Empty;
							if ( rdr != null )
							{
								gID = Sql.ToGuid(rdr["ID"]);
							}
							ctlNAICSCodeSelect.LoadLineItems(gID, false);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				// 04/04/2011 Paul.  Add support for dynamic teams. 
				else if ( String.Compare(sFIELD_TYPE, "KBTagSelect", true) == 0 )
				{
					if ( !Sql.IsEmptyString(sDATA_FIELD) )
					{
						KBTagSelect ctlKBTagSelect = tbl.Page.LoadControl("~/_controls/KBTagSelect.ascx") as KBTagSelect;
						tdField.Controls.Add(ctlKBTagSelect);
						ctlKBTagSelect.ID = sDATA_FIELD;
						// 05/06/2010 Paul.  Use a special Page flag to override the default IsPostBack behavior. 
						ctlKBTagSelect.NotPostBack = !bIsPostBack;
						//ctlTeamSelect.TabIndex = nFORMAT_TAB_INDEX;
						// 08/01/2010 Paul.  Apply ACL Field Security. 
						ctlKBTagSelect.Enabled  = bIsWriteable;
						try
						{
							Guid gID = Guid.Empty;
							if ( rdr != null )
							{
								gID = Sql.ToGuid(rdr["ID"]);
							}
							ctlKBTagSelect.LoadLineItems(gID);
						}
						catch(Exception ex)
						{
							SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), ex);
						}
					}
				}
				else
				{
					Literal litField = new Literal();
					tdField.Controls.Add(litField);
					litField.Text = "Unknown field type " + sFIELD_TYPE;
					SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "Unknown field type " + sFIELD_TYPE);
				}
				nColIndex = 0;
			}
		}
		#endregion

		protected void Bind(string sPrimaryID, string[] arrID)
		{
			if ( arrID != null && arrID.Length > 0 )
			{
				tblMain.Rows.Clear();
				tblSimilar.Rows.Clear();
				
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL ;
					string sTABLE_NAME = Sql.ToString(Application["Modules." + m_sMODULE + ".TableName"]);
					sSQL = "select *              " + ControlChars.CrLf
					     + "  from vw" + sTABLE_NAME + "_Edit" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						// 11/24/2006 Paul.  Use new Security.Filter() function to apply Team and ACL security rules.
						Security.Filter(cmd, m_sMODULE, "edit");
						Sql.AppendGuids(cmd, arrID, "ID");
						cmd.CommandText += " order by NAME";
						con.Open();

						if ( bDebug )
							RegisterClientScriptBlock("SQLCode", Sql.ClientScriptBlock(cmd));

						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								if ( dt.Rows.Count > 0 )
								{
									Hashtable hashDifferent = new Hashtable();
									Hashtable hashSimilar = new Hashtable();
									for ( int nColumnIndex = 0; nColumnIndex < dt.Columns.Count; nColumnIndex++ )
									{
										object oPrimary = null;
										string sColumnName = dt.Columns[nColumnIndex].ColumnName;
										for ( int nRecordIndex = 0; nRecordIndex < dt.Rows.Count; nRecordIndex++ )
										{
											DataRow rdr = dt.Rows[nRecordIndex];
											if ( nRecordIndex == 0 )
												oPrimary = rdr[nColumnIndex];
											// 11/14/2009 Paul.  When comparing two columns, it is best to do so as a string. 
											else if ( Sql.ToString(oPrimary) != Sql.ToString(rdr[nColumnIndex]) && !hashDifferent.ContainsKey(sColumnName) )
												hashDifferent.Add(sColumnName, null);
										}
									}
									for ( int nColumnIndex = 0; nColumnIndex < dt.Columns.Count; nColumnIndex++ )
									{
										string sColumnName = dt.Columns[nColumnIndex].ColumnName;
										if ( !hashDifferent.ContainsKey(sColumnName) )
											hashSimilar.Add(sColumnName, null);
									}
									
									// 12/27/2008 Paul.  We need to store some information in hidden fields so that the table can be rebuilt inside Page_Init. 
									int           nRecordCount      = dt.Rows.Count;
									StringBuilder sbDifferentFields = new StringBuilder();
									StringBuilder sbSimilarFields   = new StringBuilder();
									foreach ( string sKey in hashDifferent.Keys )
									{
										if ( sbDifferentFields.Length > 0 )
											sbDifferentFields.Append(",");
										sbDifferentFields.Append(sKey);
									}
									foreach ( string sKey in hashSimilar.Keys )
									{
										if ( sbSimilarFields.Length > 0 )
											sbSimilarFields.Append(",");
										sbSimilarFields.Append(sKey);
									}
									hidRecords        .Value = String.Join(",", arrID);
									hidPrimaryRecord  .Value = sPrimaryID;
									hidRecordCount    .Value = nRecordCount     .ToString();
									hidDifferentFields.Value = sbDifferentFields.ToString();
									hidSimilarFields  .Value = sbSimilarFields  .ToString();
									
									int nFIELD_WIDTH = (100 - nRecordCount) / (nRecordCount + 1);
									string sFIELD_WIDTH = nFIELD_WIDTH.ToString() + "%";
									
									DataView vw = new DataView(dt);
									vw.RowFilter = "ID = '" + sPrimaryID + "'";
									if ( vw.Count > 0 )
									{
										DataRowView rdr = vw[0];
										// 09/15/2014 Paul.  Prevent Cross-Site Scripting by HTML encoding the data. 
										// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
										ctlDynamicButtons.Title = L10n.Term("Merge.LBL_MERGE_RECORDS_WITH") + ": " + HttpUtility.HtmlEncode(Sql.ToString(rdr["NAME"]));
										ViewState["ctlDynamicButtons.Title"] = ctlDynamicButtons.Title;
										ViewState["LAST_DATE_MODIFIED"] = Sql.ToDateTime(rdr["DATE_MODIFIED"]);
										SetPageTitle(ctlDynamicButtons.Title);
										
										int nRecordIndex = 0;
										this.AppendEditViewFields(tblMain   , rdr, nRecordIndex, sFIELD_WIDTH, hashDifferent, false);
										this.AppendEditViewFields(tblSimilar, rdr, nRecordIndex, sFIELD_WIDTH, hashSimilar  , false);
									}

									vw.RowFilter = "ID <> '" + sPrimaryID + "'";
									for ( int nRecordIndex = 0; nRecordIndex < vw.Count; nRecordIndex++ )
									{
										DataRowView rdr = vw[nRecordIndex];
										
										this.AppendEditViewFields(tblMain   , rdr, nRecordIndex+1, sFIELD_WIDTH, hashDifferent, false);
										this.AppendEditViewFields(tblSimilar, rdr, nRecordIndex+1, sFIELD_WIDTH, hashSimilar  , false);
									}
								}
								else
								{
									ctlDynamicButtons.DisableAll();
									ctlDynamicButtons.ErrorText = L10n.Term("ACL.LBL_NO_ACCESS");
								}
							}
						}
					}
				}
			}
		}

		protected void Page_Load(object sender, EventArgs e)
		{
			SetPageTitle(L10n.Term(".moduleList." + m_sMODULE));
			// 06/04/2006 Paul.  Visibility is already controlled by the ASPX page, but it is probably a good idea to skip the load. 
			this.Visible = (SplendidCRM.Security.GetUserAccess(m_sMODULE, "edit") >= 0);
			if ( !this.Visible )
				return;

			try
			{
				if ( !IsPostBack )
				{
					ctlDynamicButtons.AppendButtons(m_sMODULE + ".EditView", Guid.Empty, null);

					string sPrimaryID = String.Empty;
					string[] arrID = Request.Form.GetValues("chkMain");
					// 01/28/2009 Paul.  Check for null array. 
					if ( arrID != null && arrID.Length > 0 )
						sPrimaryID = arrID[0];
					Bind(sPrimaryID, arrID);
				}
				else
				{
					// 05/31/2015 Paul.  Combine ModuleHeader and DynamicButtons. 
					ctlDynamicButtons.Title = Sql.ToString(ViewState["ctlDynamicButtons.Title"]);
					SetPageTitle(ctlDynamicButtons.Title);
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				ctlDynamicButtons.ErrorText = ex.Message;
			}
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
			ctlDynamicButtons.Command += new CommandEventHandler(Page_Command);
			this.m_sMODULE = sMergeModule;
			SetMenu(m_sMODULE);
			ctlDynamicButtons.Module = sMergeModule;
			if ( IsPostBack )
			{
				GetL10n();
				GetT10n();
				GetC10n();
				// 12/02/2005 Paul.  Need to add the edit fields in order for events to fire. 
				Hashtable hashDifferent = new Hashtable();
				Hashtable hashSimilar   = new Hashtable();
				int    nRecordCount     = Sql.ToInteger(Request.Form[hidRecordCount    .UniqueID]);  // Use UniqueID when pulling directly from the form. 
				string sDifferentFields = Sql.ToString (Request.Form[hidDifferentFields.UniqueID]);
				string sSimilarFields   = Sql.ToString (Request.Form[hidSimilarFields  .UniqueID]);
				foreach ( string sKey in sDifferentFields.Split(',') )
					hashDifferent.Add(sKey, null);
				foreach ( string sKey in sSimilarFields.Split(',') )
					hashSimilar.Add(sKey, null);
				int    nFIELD_WIDTH     = (100 - nRecordCount) / (nRecordCount + 1);
				string sFIELD_WIDTH     = nFIELD_WIDTH.ToString() + "%";
				for ( int nRecordIndex = 0; nRecordIndex < nRecordCount ; nRecordIndex++ )
				{
					this.AppendEditViewFields(tblMain   , null, nRecordIndex, sFIELD_WIDTH, hashDifferent, true);
					this.AppendEditViewFields(tblSimilar, null, nRecordIndex, sFIELD_WIDTH, hashSimilar  , true);
				}
				ctlDynamicButtons.AppendButtons(m_sMODULE + ".EditView", Guid.Empty, null);
			}
		}
		#endregion
	}
}

