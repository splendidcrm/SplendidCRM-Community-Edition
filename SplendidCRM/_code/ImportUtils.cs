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
using System.Collections;
using System.Collections.Specialized;
using System.Web;
using System.Web.SessionState;
using System.Diagnostics;
using System.Xml;
using System.Text;
using System.Workflow.Activities.Rules;

namespace SplendidCRM
{
	public class ImportUtils
	{
		public static void GenerateImport(HttpApplicationState Application, L10N L10n, SplendidControl Container, string sImportModule, string sSOURCE, DataView vwColumns, XmlDocument xmlMapping, DataTable dtRules, string sLayoutEditView, string sTempFileName, bool bPreview, bool bHAS_HEADER, bool bUSE_TRANSACTION, Guid gPROSPECT_LIST_ID, StringBuilder sbImport, StringBuilder sbErrors, string sProcessedFileID, DataTable dtProcessed, ref int nImported, ref int nFailed, ref int nDuplicates)
		{
			HttpSessionState Session  = HttpContext.Current.Session ;
			HttpResponse     Response = HttpContext.Current.Response;

			// 11/01/2006 Paul.  Max errors is now a config value. 
			int nMAX_ERRORS = Sql.ToInteger(Application["CONFIG.import_max_errors"]);
			if ( nMAX_ERRORS <= 0 )
				nMAX_ERRORS = 200;
			
			try
			{
				XmlDocument xmlImport = new XmlDocument();
				// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
				// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
				// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
				xmlImport.XmlResolver = null;
				xmlImport.Load(Path.Combine(Path.GetTempPath(), sTempFileName));
				
				XmlNodeList nlRows = xmlImport.DocumentElement.SelectNodes(sImportModule.ToLower());
				// 05/23/2020 Paul.  Try non-lower case. 
				if ( nlRows.Count == 0 )
					nlRows = xmlImport.DocumentElement.SelectNodes(sImportModule);
				if ( nlRows.Count == 0 )
					throw(new Exception(L10n.Term("Import.LBL_NOTHING")));
				
				// 09/17/2013 Paul.  Add Business Rules to import. 
				SplendidRulesTypeProvider typeProvider = new SplendidRulesTypeProvider();
				RuleValidation validation = new RuleValidation(typeof(SplendidImportThis), typeProvider);
				RuleSet rules = null;
				// 06/02/2014 Paul.  No sense in building the rules if the rows are empty. 
				if ( dtRules != null && dtRules.Rows.Count > 0 )
				{
					rules = RulesUtil.BuildRuleSet(dtRules, validation);
				}
				
				// 08/20/2006 Paul.  Also map the header names to allow for a flexible XML. 
				StringDictionary hashHeaderMappings   = new StringDictionary();
				StringDictionary hashReverseMappings  = new StringDictionary();
				StringDictionary hashDuplicateFilters = new StringDictionary ();
				Hashtable hashDefaultMappings = new Hashtable();
				XmlNodeList nlFields = xmlMapping.DocumentElement.SelectNodes("Fields/Field");
				foreach ( XmlNode xField in nlFields )
				{
					string sName    = xField.Attributes.GetNamedItem("Name").Value;
					string sMapping = XmlUtil.SelectSingleNode(xField, "Mapping");
					string sDefault = XmlUtil.SelectSingleNode(xField, "Default");
					if ( !Sql.IsEmptyString(sMapping) )
					{
						// 11/02/2009 Rick.  We need to protect against duplicate dictionary entries. 
						if ( !hashHeaderMappings.ContainsKey(sMapping) )
							hashHeaderMappings.Add(sMapping, sName);
						if ( !hashReverseMappings.ContainsKey(sName) )
							hashReverseMappings.Add(sName, sMapping);
					}
					if ( !Sql.IsEmptyString(sDefault) )
					{
						// 11/02/2009 Rick.  We need to protect against duplicate dictionary entries. 
						if ( !hashDefaultMappings.ContainsKey(sName) )
							hashDefaultMappings.Add(sName, sDefault);
					}
					bool bDuplicateFilter = Sql.ToBoolean(XmlUtil.SelectSingleNode(xField, "DuplicateFilter"));
					if ( bDuplicateFilter )
					{
						// 11/02/2009 Rick.  We need to protect against duplicate dictionary entries. 
						if ( !hashDuplicateFilters.ContainsKey(sName) )
							hashDuplicateFilters.Add(sName, String.Empty);
					}
				}
				StringBuilder sbDuplicateFilters = new StringBuilder();
				foreach ( string sDuplicateField in hashDuplicateFilters.Keys )
				{
					if ( sbDuplicateFilters.Length > 0 )
						sbDuplicateFilters.Append(", ");
					sbDuplicateFilters.Append(sDuplicateField.ToUpper());
				}
				
				// 11/01/2006 Paul.  Use a hash for quick access to required fields. 
				Hashtable hashColumns = new Hashtable();
				foreach ( DataRowView row in vwColumns )
				{
					// 11/02/2009 Rick.  We need to protect against duplicate dictionary entries. 
					if ( !hashColumns.ContainsKey(row["NAME"]) )
						hashColumns.Add(row["NAME"], row["DISPLAY_NAME"]);
				}
				
				Hashtable hashRequiredFields = new Hashtable();
				DataTable dtRequiredFields = SplendidCache.EditViewFields(sImportModule + "." + sLayoutEditView, Security.PRIMARY_ROLE_NAME);
				DataView dvRequiredFields = new DataView(dtRequiredFields);
				dvRequiredFields.RowFilter = "UI_REQUIRED = 1";
				foreach(DataRowView row in dvRequiredFields)
				{
					string sDATA_FIELD = Sql.ToString (row["DATA_FIELD"]);
					if (!Sql.IsEmptyString(sDATA_FIELD) )
					{
						if ( !hashRequiredFields.ContainsKey(sDATA_FIELD) )
							hashRequiredFields.Add(sDATA_FIELD, null);
					}
				}
				dvRequiredFields = null;
				dtRequiredFields = null;
				
				//int nSkipped  = 0;
				dtProcessed.Columns.Add("IMPORT_ROW_STATUS", typeof(bool));
				dtProcessed.Columns.Add("IMPORT_ROW_NUMBER", typeof(Int32));
				dtProcessed.Columns.Add("IMPORT_ROW_ERROR"  );
				dtProcessed.Columns.Add("IMPORT_LAST_COLUMN");
				dtProcessed.Columns.Add("ID");  // 10/10/2006 Paul.  Every record will have an ID, either implied or specified. 
				SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "Import Database Table: " + sImportModule);
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					Hashtable hashTeamNames = new Hashtable();
					if ( Crm.Config.enable_team_management() )
					{
						string sSQL;
						sSQL = "select ID          " + ControlChars.CrLf
						     + "     , NAME        " + ControlChars.CrLf
						     + "  from vwTEAMS_List" + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							using ( IDataReader rdr = cmd.ExecuteReader() )
							{
								while ( rdr.Read() )
								{
									Guid   gTEAM_ID   = Sql.ToGuid  (rdr["ID"  ]);
									string sTEAM_NAME = Sql.ToString(rdr["NAME"]);
									sTEAM_NAME = sTEAM_NAME.Trim().ToUpper();
									if ( !Sql.IsEmptyString(sTEAM_NAME) )
									{
										// 11/02/2009 Rick.  We need to protect against duplicate dictionary entries. 
										if ( !hashTeamNames.ContainsKey(sTEAM_NAME) )
											hashTeamNames.Add(sTEAM_NAME, gTEAM_ID);
									}
								}
							}
						}
					}

					// 11/01/2006 Paul.  The transaction is optional, just make sure to always dispose it. 
					//using ( IDbTransaction trn = Sql.BeginTransaction(con) )
					{
						IDbTransaction trn = null;
						try
						{
							string sTABLE_NAME = Sql.ToString(Application["Modules." + sImportModule + ".TableName"]);
							if ( Sql.IsEmptyString(sTABLE_NAME) )
								sTABLE_NAME = sImportModule.ToUpper();
							
							// 03/13/2008 Paul.  Allow the use of a special Import procedure. 
							// This is so that we can convert text values to their associated GUID value. 
							IDbCommand cmdImport = null;
							try
							{
								// 03/13/2008 Paul.  The factory will throw an exception if the procedure is not found. 
								// Catching an exception is expensive, but trivial considering all the other processing that will occur. 
								// We need this same logic in SplendidCache.ImportColumns. 
								cmdImport = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Import");
							}
							catch
							{
								cmdImport = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Update");
							}
							// 02/02/2010 Paul.  ACT! import will also import Notes and Activities (Calls or Meetings). 
							IDbCommand cmdNOTES_Import    = null;
							IDbCommand cmdCALLS_Import    = null;
							IDbCommand cmdMEETINGS_Import = null;
							IDbCommand cmdPROSPECT_LISTS_Import = null;
							IDbCommand cmdPROSPECT_LISTS_CONTACTS_Import  = null;
							// 01/11/2011 Paul.  Use a separate procedure as it has different parameters. 
							IDbCommand cmdPROSPECT_LISTS_LEADS_Import     = null;
							IDbCommand cmdPROSPECT_LISTS_PROSPECTS_Import = null;
							// 10/27/2017 Paul.  Add Accounts as email source. 
							IDbCommand cmdPROSPECT_LISTS_ACCOUNTS_Import  = null;
							if ( sSOURCE == "act" )
							{
								try
								{
									cmdNOTES_Import = SqlProcs.Factory(con, "spNOTES_Import");
								}
								catch
								{
									cmdNOTES_Import = SqlProcs.Factory(con, "spNOTES_Update");
								}
								try
								{
									cmdCALLS_Import = SqlProcs.Factory(con, "spCALLS_Import");
								}
								catch
								{
									cmdCALLS_Import = SqlProcs.Factory(con, "spCALLS_Update");
								}
								try
								{
									cmdMEETINGS_Import = SqlProcs.Factory(con, "spMEETINGS_Import");
								}
								catch
								{
									cmdMEETINGS_Import = SqlProcs.Factory(con, "spMEETINGS_Update");
								}
								try
								{
									cmdPROSPECT_LISTS_Import = SqlProcs.Factory(con, "spPROSPECT_LISTS_Import");
								}
								catch
								{
									cmdPROSPECT_LISTS_Import = SqlProcs.Factory(con, "spPROSPECT_LISTS_Update");
								}
							}
							// 01/10/2011 Paul.  When importing into the Leads module, we need to use the Leads relationship table. 
							// 10/24/2013 Paul.  These import procedures need to be available to all imports and not just ACT import 
							// to allow direct import into a Prospect List.
							if ( sTABLE_NAME == "CONTACTS" )
							{
								try
								{
									cmdPROSPECT_LISTS_CONTACTS_Import = SqlProcs.Factory(con, "spPROSPECT_LISTS_CONTACTS_Import");
								}
								catch
								{
									cmdPROSPECT_LISTS_CONTACTS_Import = SqlProcs.Factory(con, "spPROSPECT_LISTS_CONTACTS_Update");
								}
							}
							else if ( sTABLE_NAME == "LEADS" )
							{
								try
								{
									cmdPROSPECT_LISTS_LEADS_Import = SqlProcs.Factory(con, "spPROSPECT_LISTS_LEADS_Import");
								}
								catch
								{
									cmdPROSPECT_LISTS_LEADS_Import = SqlProcs.Factory(con, "spPROSPECT_LISTS_LEADS_Update");
								}
							}
							else if ( sTABLE_NAME == "PROSPECTS" )
							{
								try
								{
									cmdPROSPECT_LISTS_PROSPECTS_Import = SqlProcs.Factory(con, "spPROSPECT_LISTS_PROSPECTS_Import");
								}
								catch
								{
									cmdPROSPECT_LISTS_PROSPECTS_Import = SqlProcs.Factory(con, "spPROSPECT_LISTS_PROSPECTS_Update");
								}
							}
							// 10/27/2017 Paul.  Add Accounts as email source. 
							else if ( sTABLE_NAME == "ACCOUNTS" )
							{
								try
								{
									cmdPROSPECT_LISTS_CONTACTS_Import = SqlProcs.Factory(con, "spPROSPECT_LISTS_ACCOUNTS_Import");
								}
								catch
								{
									cmdPROSPECT_LISTS_CONTACTS_Import = SqlProcs.Factory(con, "spPROSPECT_LISTS_ACCOUNTS_Update");
								}
							}
							IDbCommand cmdImportCSTM = null;
							//IDbCommand cmdImportTeam = null;
							// 09/17/2007 Paul.  Only activate the custom field code if there are fields in the custom fields table. 
							vwColumns.RowFilter = "CustomField = 1";
							if ( vwColumns.Count > 0 )
							{
								vwColumns.Sort = "colid";
								cmdImportCSTM = con.CreateCommand();
								cmdImportCSTM.CommandType = CommandType.Text;
								cmdImportCSTM.CommandText = "update " + sTABLE_NAME + "_CSTM" + ControlChars.CrLf;
								int nFieldIndex = 0;
								foreach ( DataRowView row in vwColumns )
								{
									// 01/11/2006 Paul.  Uppercase looks better. 
									string sNAME   = Sql.ToString(row["ColumnName"]).ToUpper();
									string sCsType = Sql.ToString(row["ColumnType"]);
									// 02/07/2018 Paul.  Only set the custom field if there is a mapping or a default value. 
									if ( !hashReverseMappings.ContainsKey(sNAME) && !hashDefaultMappings.ContainsKey(sNAME) )
										continue;
									// 01/13/2007 Paul.  We need to truncate any long strings to prevent SQL error. 
									// String or binary data would be truncated. The statement has been terminated. 
									int    nMAX_SIZE = Sql.ToInteger(row["Size"]);
									if ( nFieldIndex == 0 )
										cmdImportCSTM.CommandText += "   set ";
									else
										cmdImportCSTM.CommandText += "     , ";
									// 01/10/2006 Paul.  We can't use a StringBuilder because the Sql.AddParameter function
									// needs to be able to replace the @ with the appropriate database specific token. 
									cmdImportCSTM.CommandText += sNAME + " = @" + sNAME + ControlChars.CrLf;
									
									IDbDataParameter par = null;
									switch ( sCsType )
									{
										// 09/19/2007 Paul.  In order to leverage the existing AddParameter functions, we need to provide default values. 
										case "Guid"    :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, Guid.Empty             );  break;
										case "short"   :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, 0                      );  break;
										case "Int32"   :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, 0                      );  break;
										case "Int64"   :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, 0                      );  break;
										case "float"   :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, 0.0f                   );  break;
										case "decimal" :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, new Decimal()          );  break;
										case "bool"    :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, false                  );  break;
										case "DateTime":  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, DateTime.MinValue      );  break;
										default        :  par = Sql.AddParameter(cmdImportCSTM, "@" + sNAME, String.Empty, nMAX_SIZE);  break;
									}
									nFieldIndex++;
								}
								// 09/19/2007 Paul.  Exclude ID_C as it is expect and required. We don't want it to appear in the mapping table. 
								cmdImportCSTM.CommandText += " where ID_C = @ID_C" + ControlChars.CrLf;
								Sql.AddParameter(cmdImportCSTM, "@ID_C", Guid.Empty);
								// 10/24/2010 Paul.  This execute does not seem correct, so remove it. 
								//cmdImportCSTM.ExecuteNonQuery();
								// 02/07/2018 Paul.  If no custom fields added/mapped, then disable. 
								if ( nFieldIndex == 0 )
									cmdImportCSTM = null;
							}
							vwColumns.RowFilter = "";
							/*
							if ( Crm.Config.enable_team_management() )
							{
								cmdImportTeam = con.CreateCommand();
								cmdImportTeam.CommandType = CommandType.Text;
								cmdImportTeam.CommandText  = "update " + sTABLE_NAME     + ControlChars.CrLf;
								cmdImportTeam.CommandText += "   set TEAM_ID = @TEAM_ID" + ControlChars.CrLf;
								cmdImportTeam.CommandText += " where ID      = @ID     " + ControlChars.CrLf;
								Sql.AddParameter(cmdImportTeam, "@TEAM_ID", Guid.Empty);
								Sql.AddParameter(cmdImportTeam, "@ID"     , Guid.Empty);
							}
							*/
							
							// 11/01/2006 Paul.  The transaction is optional, but on by default. 
							if ( bUSE_TRANSACTION || bPreview )
							{
								// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
								trn = Sql.BeginTransaction(con);
								cmdImport.Transaction = trn;
								if ( cmdImportCSTM != null )
									cmdImportCSTM.Transaction = trn;
								//if ( cmdImportTeam != null )
								//	cmdImportTeam.Transaction = trn;
							}
							int i = 0;
							// 05/24/2020 Paul.  Don't skip the first record of an XML import. 
							if ( bHAS_HEADER && sSOURCE != "xml" )
								i++;
							// 06/04/2009 Paul.  If Team is required, then make sure to initialize the TEAM_ID.  Same is true for ASSIGNED_USER_ID. 
							bool bEnableTeamManagement  = Crm.Config.enable_team_management();
							// 01/11/2011 Paul.  Ignore the Required flag. 
							//bool bRequireTeamManagement = Crm.Config.require_team_management();
							//bool bRequireUserAssignment = Crm.Config.require_user_assignment();
							// 02/04/2010 Paul.  An ACT! group should be treated as a Prospect List. 
							Hashtable hashProspectLists = new Hashtable();
							if ( sSOURCE == "act" && cmdPROSPECT_LISTS_Import != null )
							{
								if ( bUSE_TRANSACTION || bPreview )
								{
									cmdPROSPECT_LISTS_Import.Transaction = trn;
								}
								// 02/04/2010 Paul.  Prospect Lists should assume the owner of the parent record. 
								Guid gTEAM_ID          = Security.TEAM_ID;
								Guid gASSIGNED_USER_ID = Security.USER_ID;
								// 03/27/2010 Paul.  Use FindParameter as the Parameter Name may start with @. 
								// 01/10/2011 Paul.  This logic is the source of a bug where the Prospect List owner was not getting set. 
								// The problem is that cmdImport has not been initialized at this stage, so it does not make sense to use it as the base. 
								/*
								IDbDataParameter parTEAM_ID          = Sql.FindParameter(cmdImport, "@TEAM_ID"         );
								IDbDataParameter parASSIGNED_USER_ID = Sql.FindParameter(cmdImport, "@ASSIGNED_USER_ID");
								if ( parTEAM_ID != null )
									gTEAM_ID = Sql.ToGuid(parTEAM_ID.Value);
								if ( parASSIGNED_USER_ID != null )
									gASSIGNED_USER_ID = Sql.ToGuid(parASSIGNED_USER_ID.Value);
								*/
								
								IDbDataParameter parID = Sql.FindParameter(cmdPROSPECT_LISTS_Import, "ID");
								if ( parID != null )
								{
									XmlNodeList nlGroups = xmlImport.DocumentElement.SelectNodes("groups");
									foreach ( XmlNode xGroup in nlGroups )
									{
										foreach(IDbDataParameter par in cmdPROSPECT_LISTS_Import.Parameters)
										{
											// 03/27/2010 Paul.  The ParameterName will start with @, so we need to remove it. 
											string sParameterName = Sql.ExtractDbName(cmdPROSPECT_LISTS_Import, par.ParameterName).ToUpper();
											if ( sParameterName == "TEAM_ID" && bEnableTeamManagement ) // 01/11/2011 Paul.  Ignore the Required flag. && bRequireTeamManagement )
												par.Value = Sql.ToDBGuid(gTEAM_ID);  // 01/10/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
											else if ( sParameterName == "ASSIGNED_USER_ID" ) // 01/11/2011 Paul.  Always set the Assigned User ID. && bRequireUserAssignment )
												par.Value = Sql.ToDBGuid(gASSIGNED_USER_ID);  // 01/10/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
											// 02/20/2013 Paul.  We need to set the MODIFIED_USER_ID. 
											else if ( sParameterName == "MODIFIED_USER_ID" )
												par.Value = Sql.ToDBGuid(gASSIGNED_USER_ID);
											else
												par.Value = DBNull.Value;
										}
										// 05/10/2010 Paul.  We now support ACT! etime. 
										DateTime dtDATE_MODIFIED = Sql.ToDateTime(XmlUtil.SelectSingleNode(xGroup, "etime"      ));
										string   sNAME           = Sql.ToString  (XmlUtil.SelectSingleNode(xGroup, "grp_name"   )).Trim();
										string   sDESCRIPTION    = Sql.ToString  (XmlUtil.SelectSingleNode(xGroup, "description")).Trim();
										if ( !Sql.IsEmptyString(sNAME) && !hashProspectLists.ContainsKey(sNAME) )
										{
											// 02/04/2010 Paul.  The modified user is always the person who imported the data. 
											Sql.SetParameter(cmdPROSPECT_LISTS_Import, "@DATE_MODIFIED"   , dtDATE_MODIFIED );
											Sql.SetParameter(cmdPROSPECT_LISTS_Import, "@MODIFIED_USER_ID", Security.USER_ID);
											Sql.SetParameter(cmdPROSPECT_LISTS_Import, "@NAME"            , sNAME           );
											Sql.SetParameter(cmdPROSPECT_LISTS_Import, "@DESCRIPTION"     , sDESCRIPTION    );
											
											sbImport.Append(Sql.ExpandParameters(cmdPROSPECT_LISTS_Import));
											sbImport.AppendLine(";");
											cmdPROSPECT_LISTS_Import.ExecuteNonQuery();
											
											hashProspectLists.Add(sNAME, Sql.ToGuid(parID.Value).ToString());
										}
									}
								}
							}
							for ( int iRowNumber = 1; i < nlRows.Count ; i++ )
							{
								XmlNode node = nlRows[i];
								int nEmptyColumns = 0;
								for ( int j = 0; j < node.ChildNodes.Count; j++ )
								{
									string sText = node.ChildNodes[j].InnerText;
									if ( sText == String.Empty )
										nEmptyColumns++;
								}
								// 09/04/2006 Paul.  If all columns are empty, then skip the row. 
								if ( nEmptyColumns == node.ChildNodes.Count )
									continue;
								DataRow row = dtProcessed.NewRow();
								row["IMPORT_ROW_NUMBER"] = iRowNumber ;
								iRowNumber++;
								dtProcessed.Rows.Add(row);
								try
								{
									if ( !Response.IsClientConnected )
									{
										break;
									}
									foreach(IDbDataParameter par in cmdImport.Parameters)
									{
										// 06/04/2009 Paul.  If Team is required, then make sure to initialize the TEAM_ID.  Same is true for ASSIGNED_USER_ID. 
										// 03/27/2010 Paul.  The ParameterName will start with @, so we need to remove it. 
										string sParameterName = Sql.ExtractDbName(cmdImport, par.ParameterName).ToUpper();
										if ( sParameterName == "TEAM_ID" && bEnableTeamManagement ) // 01/11/2011 Paul.  Ignore the Required flag. && bRequireTeamManagement )
											par.Value = Sql.ToDBGuid(Security.TEAM_ID);  // 02/26/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
										else if ( sParameterName == "ASSIGNED_USER_ID" ) // 01/11/2011 Paul.  Always set the Assigned User ID. && bRequireUserAssignment )
											par.Value = Sql.ToDBGuid(Security.USER_ID);  // 02/26/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
										// 02/20/2013 Paul.  We need to set the MODIFIED_USER_ID. 
										else if ( sParameterName == "MODIFIED_USER_ID" )
											par.Value = Sql.ToDBGuid(Security.USER_ID);
										else
											par.Value = DBNull.Value;
									}
									if ( cmdImportCSTM != null )
									{
										foreach(IDbDataParameter par in cmdImportCSTM.Parameters)
										{
											par.Value = DBNull.Value;
										}
									}
									/*
									if ( cmdImportTeam != null )
									{
										foreach(IDbDataParameter par in cmdImportTeam.Parameters)
										{
											par.Value = DBNull.Value;
										}
									}
									*/
									// 09/19/2007 Paul.  parID and parID_C are frequently used, so obtain outside the import loop. 
									IDbDataParameter parID   = Sql.FindParameter(cmdImport, "ID");
									IDbDataParameter parID_C = null;
									if ( cmdImportCSTM != null )
										parID_C = Sql.FindParameter(cmdImportCSTM, "ID_C");

									// 10/31/2006 Paul.  The modified user is always the person who imported the data. 
									// 11/01/2006 Paul.  The real problem with importing a contact is that the SYNC_CONTACT flag was null, and treated as 1. 
									// It still makes sense to set the modified id. 
									Sql.SetParameter(cmdImport, "@MODIFIED_USER_ID", Security.USER_ID);
									foreach(string sName in hashDefaultMappings.Keys)
									{
										string sDefault = Sql.ToString(hashDefaultMappings[sName]);
										if ( !dtProcessed.Columns.Contains(sName) )
										{
											dtProcessed.Columns.Add(sName);
										}
										row["IMPORT_ROW_STATUS" ] = true ;
										row["IMPORT_LAST_COLUMN"] = sName;
										row[sName] = sDefault;
										Sql.SetParameter(cmdImport, sName, sDefault);
										if ( cmdImportCSTM != null )
											Sql.SetParameter(cmdImportCSTM, sName, sDefault);
										//if ( cmdImportTeam != null && sName == "team_id" )
										//	Sql.SetParameter(cmdImportTeam, "@TEAM_ID", sDefault);
									}
									for ( int j = 0; j < node.ChildNodes.Count; j++ )
									{
										string sText = node.ChildNodes[j].InnerText;
										string sName = String.Empty;
										// 08/22/2006 Paul.  We should always use the header mappings instead of an index as nodes may move around. 
										sName = Sql.ToString(hashHeaderMappings[node.ChildNodes[j].Name]);
										// 09/08/2006 Paul.  There is no need to set the field if the value is empty. 
										if ( sName.Length > 0 && sText.Length > 0 )
										{
											sName = sName.ToUpper();
											// 08/20/2006 Paul.  Fix IDs. 
											// 09/30/2006 Paul.  CREATED_BY counts as an ID. 
											if ( sName == "ID" || sName.EndsWith("_ID") || sName == "CREATED_BY" )
											{
												// 09/30/2006 Paul.  IDs must be in upper case.  This is primarily for platforms that are case-significant. 
												// 10/05/2006 Paul.  We need to use upper case for SQL Server as well so that the SugarCRM user names are correctly replaced. 
												sText = sText.ToUpper();
												if ( sText.Length < 36 && sText.Length > 0 )
												{
													sText = "00000000-0000-0000-0000-000000000000".Substring(0, 36 - sText.Length) + sText;
													switch ( sText )
													{
														case "00000000-0000-0000-0000-000000JIM_ID":  sText = "00000000-0000-0000-0001-000000000000";  break;
														case "00000000-0000-0000-0000-000000MAX_ID":  sText = "00000000-0000-0000-0002-000000000000";  break;
														case "00000000-0000-0000-0000-00000WILL_ID":  sText = "00000000-0000-0000-0003-000000000000";  break;
														case "00000000-0000-0000-0000-0000CHRIS_ID":  sText = "00000000-0000-0000-0004-000000000000";  break;
														case "00000000-0000-0000-0000-0000SALLY_ID":  sText = "00000000-0000-0000-0005-000000000000";  break;
														case "00000000-0000-0000-0000-0000SARAH_ID":  sText = "00000000-0000-0000-0006-000000000000";  break;
														// 11/30/2006 Paul.  The following mappings will really only help when importing SugarCRM sample data. 
														case "00000000-0000-0000-0000-000000000001":  sText = "00000000-0000-0001-0000-000000000000";  break;
														case "00000000-0000-0000-0000-0PRIVATE.JIM":  sText = "00000000-0000-0001-0001-000000000000";  break;
														case "00000000-0000-0000-0000-0PRIVATE.MAX":  sText = "00000000-0000-0001-0002-000000000000";  break;
														case "00000000-0000-0000-0000-PRIVATE.WILL":  sText = "00000000-0000-0001-0003-000000000000";  break;
														case "00000000-0000-0000-0000PRIVATE.CHRIS":  sText = "00000000-0000-0001-0004-000000000000";  break;
														case "00000000-0000-0000-0000PRIVATE.SALLY":  sText = "00000000-0000-0001-0005-000000000000";  break;
														case "00000000-0000-0000-0000PRIVATE.SARAH":  sText = "00000000-0000-0001-0006-000000000000";  break;
														case "00000000-0000-0000-0000-00000000EAST":  sText = "00000000-0000-0001-0101-000000000000";  break;
														case "00000000-0000-0000-0000-00000000WEST":  sText = "00000000-0000-0001-0102-000000000000";  break;
														case "00000000-0000-0000-0000-0000000NORTH":  sText = "00000000-0000-0001-0103-000000000000";  break;
														case "00000000-0000-0000-0000-0000000SOUTH":  sText = "00000000-0000-0001-0104-000000000000";  break;
														// 07/09/2010 Paul.  New IDs used in a prepopulated SugarCRM database. 
														case "00000000-0000-0000-0000-0SEED_JIM_ID":  sText = "00000000-0000-0000-0011-000000000000";  break;
														case "00000000-0000-0000-0000-0SEED_MAX_ID":  sText = "00000000-0000-0000-0012-000000000000";  break;
														case "00000000-0000-0000-0000-SEED_WILL_ID":  sText = "00000000-0000-0000-0013-000000000000";  break;
														case "00000000-0000-0000-0000SEED_CHRIS_ID":  sText = "00000000-0000-0000-0014-000000000000";  break;
														case "00000000-0000-0000-0000SEED_SALLY_ID":  sText = "00000000-0000-0000-0015-000000000000";  break;
														case "00000000-0000-0000-0000SEED_SARAH_ID":  sText = "00000000-0000-0000-0016-000000000000";  break;
													}
												}
											}
											// 02/20/2008 Paul.  Most modules have the TEAM_ID in the main update procedure, 
											// so we need to translate the TEAM_NAME to TEAM_ID inside this loop. 
											else if ( sName == "TEAM_NAME" && Crm.Config.enable_team_management() )
											{
												Guid gTEAM_ID = Guid.Empty;
												string sTEAM_NAME = sText.Trim().ToUpper();
												if ( hashTeamNames.ContainsKey(sTEAM_NAME) )
												{
													gTEAM_ID = Sql.ToGuid(hashTeamNames[sTEAM_NAME]);
												}
												sName = "TEAM_ID";
												sText = gTEAM_ID.ToString();
											}
											if ( !dtProcessed.Columns.Contains(sName) )
											{
												dtProcessed.Columns.Add(sName);
											}
											row["IMPORT_ROW_STATUS" ] = true ;
											row["IMPORT_LAST_COLUMN"] = sName;
											row[sName] = sText;
											Sql.SetParameter(cmdImport, sName, sText);
											if ( cmdImportCSTM != null )
												Sql.SetParameter(cmdImportCSTM, sName, sText);
										}
									}
									
									// 09/17/2013 Paul.  Add Business Rules to import. 
									// Apply rules before Required Fields or Duplicates check. 
									// For efficiency, don't apply rules engine if no rules were defined. 
									if ( rules != null && dtRules != null && dtRules.Rows.Count > 0 )
									{
										row["IMPORT_LAST_COLUMN"] = "Business Rules Engine";
										// 04/27/2018 Paul.  We need to be able to generate an error message. 
										SplendidImportThis swThis = new SplendidImportThis(Container, L10n, sImportModule, row, cmdImport, cmdImportCSTM);
										RuleExecution exec = new RuleExecution(validation, swThis);
										rules.Execute(exec);
										// 05/23/2018 Paul.  If there is no error, then clear last column. 
										if ( !Sql.IsEmptyString(swThis.ErrorMessage) )
											throw(new Exception(swThis.ErrorMessage));
										else
											row["IMPORT_LAST_COLUMN"] = String.Empty;
									}
									
									StringBuilder sbRequiredFieldErrors = new StringBuilder();
									foreach ( string sRequiredField in hashRequiredFields.Keys )
									{
										IDbDataParameter par = Sql.FindParameter(cmdImport, sRequiredField);
										if ( par == null && cmdImportCSTM != null )
											par = Sql.FindParameter(cmdImportCSTM, sRequiredField);
										if ( par != null )
										{
											if ( par.Value == DBNull.Value || par.Value.ToString() == String.Empty )
											{
												// 02/05/2010 Paul.  If this is an ACT! import of contacts, then there may not be a Last Name. 
												// In this case, use the Account Name as we want to keep the record. 
												if ( sSOURCE == "act" && sRequiredField == "LAST_NAME" && sImportModule == "Contacts" )
												{
													IDbDataParameter parACCOUNT_NAME = Sql.FindParameter(cmdImport, "ACCOUNT_NAME");
													if ( parACCOUNT_NAME != null )
													{
														// 02/05/2010 Paul.  Check the value not the parameter. 
														if ( !Sql.IsEmptyString(parACCOUNT_NAME.Value) )
														{
															par.Value = parACCOUNT_NAME.Value;
															continue;
														}
													}
												}
												// 11/02/2006 Paul.  If ACCOUNT_ID is required, then also allow ACCOUNT_NAME. 
												else if ( sRequiredField == "ACCOUNT_ID" && (sImportModule == "Cases " || sImportModule == "Opportunities") )
												{
													par = Sql.FindParameter(cmdImport, "ACCOUNT_NAME");
													if ( par != null )
													{
														if ( par.Value != DBNull.Value && par.Value.ToString() != String.Empty )
														{
															continue;
														}
													}
												}
												if ( sbRequiredFieldErrors.Length > 0 )
													sbRequiredFieldErrors.Append(", ");
												if ( hashColumns.ContainsKey(sRequiredField) )
													sbRequiredFieldErrors.Append(hashColumns[sRequiredField]);
												else
													sbRequiredFieldErrors.Append(sRequiredField);
											}
										}
									}
									// 12/17/2008 Paul.  Now that all the data is available in cmdImport, we can use the data in a filter. 
									if ( hashDuplicateFilters.Count > 0 )
									{
										string sSQL = String.Empty;
										sSQL = "select count(*)        " + ControlChars.CrLf
										     + "  from vw" + sTABLE_NAME + ControlChars.CrLf
										     + " where 1 = 1           " + ControlChars.CrLf;
										using ( IDbCommand cmdDuplicate = con.CreateCommand() )
										{
											cmdDuplicate.Transaction = trn;
											cmdDuplicate.CommandText = sSQL;
											foreach ( string sDuplicateField in hashDuplicateFilters.Keys )
											{
												string sFieldName = sDuplicateField.ToUpper();
												IDbDataParameter par = Sql.FindParameter(cmdImport, sFieldName);
												if ( par == null )
												{
													par = Sql.FindParameter(cmdImportCSTM, sFieldName);
												}
												if ( par != null )
												{
													if ( par.Value == DBNull.Value )
													{
														cmdDuplicate.CommandText += "   and " + sFieldName + " is null" + ControlChars.CrLf;
													}
													else
													{
														cmdDuplicate.CommandText += "   and " + sFieldName + " = @" + sFieldName + ControlChars.CrLf;
														IDbDataParameter parDup = Sql.CreateParameter(cmdDuplicate, "@" + sFieldName);
														parDup.DbType    = par.DbType   ;
														parDup.Size      = par.Size     ;
														parDup.Scale     = par.Scale    ;
														parDup.Precision = par.Precision;
														parDup.Value     = par.Value    ;
													}
												}
											}
											sbImport.Append(Sql.ExpandParameters(cmdDuplicate));
											sbImport.AppendLine(";");
											
											int nDuplicateCount = Sql.ToInteger(cmdDuplicate.ExecuteScalar());
											if ( nDuplicateCount > 0 )
											{
												nDuplicates++;
												row["IMPORT_ROW_STATUS"] = false;
												row["IMPORT_ROW_ERROR" ] = L10n.Term("Import.ERR_DUPLICATE_FIELDS") + " " + sbDuplicateFilters.ToString();
												continue;
											}
										}
									}
									if ( sbRequiredFieldErrors.Length > 0 )
									{
										row["IMPORT_ROW_STATUS"] = false;
										row["IMPORT_ROW_ERROR" ] = L10n.Term("Import.ERR_MISSING_REQUIRED_FIELDS") + " " + sbRequiredFieldErrors.ToString();
										nFailed++;
										// 10/31/2006 Paul.  Abort after 200 errors. 
										if ( nFailed >= nMAX_ERRORS )
										{
											sbErrors.AppendLine(L10n.Term("Import.LBL_MAX_ERRORS"));
											break;
										}
									}
									else
									{
										sbImport.Append(Sql.ExpandParameters(cmdImport));
										sbImport.AppendLine(";");
										// 05/23/2018 Paul.  Note that next error will come from stored procedure. 
										row["IMPORT_LAST_COLUMN"] = cmdImport.CommandText + " execution.";
										cmdImport.ExecuteNonQuery();
										if ( parID != null )
										{
											row["ID"] = parID.Value;

											Guid gID = Sql.ToGuid(parID.Value);
											if ( cmdImportCSTM != null && parID_C != null )
											{
												parID_C.Value = gID;
												sbImport.Append(Sql.ExpandParameters(cmdImportCSTM));
												sbImport.AppendLine(";");
												cmdImportCSTM.ExecuteNonQuery();
											}
											if ( sSOURCE == "act" )
											{
												// 02/02/2010 Paul.  Notes and Activities should assume the owner of the parent record. 
												Guid gTEAM_ID          = Security.TEAM_ID;
												Guid gASSIGNED_USER_ID = Security.USER_ID;
												// 03/27/2010 Paul.  Use FindParameter as the Parameter Name may start with @. 
												IDbDataParameter parTEAM_ID          = Sql.FindParameter(cmdImport, "@TEAM_ID"         );
												IDbDataParameter parASSIGNED_USER_ID = Sql.FindParameter(cmdImport, "@ASSIGNED_USER_ID");
												if ( parTEAM_ID != null )
													gTEAM_ID = Sql.ToGuid(parTEAM_ID.Value);
												if ( parASSIGNED_USER_ID != null )
													gASSIGNED_USER_ID = Sql.ToGuid(parASSIGNED_USER_ID.Value);
												// 02/02/2010 Paul.  If this is an ACT! import, then we need to look for Notes and Activities. 
												if ( cmdNOTES_Import != null )
												{
													// 02/04/2010 Paul.  The Note and Activity import must also be part of the transaction. 
													if ( bUSE_TRANSACTION || bPreview )
													{
														cmdNOTES_Import.Transaction = trn;
													}
													XmlNodeList nlNotes = node.SelectNodes("notes");
													foreach ( XmlNode xNote in nlNotes )
													{
														foreach(IDbDataParameter par in cmdNOTES_Import.Parameters)
														{
															// 03/27/2010 Paul.  The ParameterName will start with @, so we need to remove it. 
															string sParameterName = Sql.ExtractDbName(cmdNOTES_Import, par.ParameterName).ToUpper();
															if ( sParameterName == "TEAM_ID" && bEnableTeamManagement ) // 01/11/2011 Paul.  Ignore the Required flag. && bRequireTeamManagement )
																par.Value = Sql.ToDBGuid(gTEAM_ID);  // 01/10/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
															else if ( sParameterName == "ASSIGNED_USER_ID" ) // 01/11/2011 Paul.  Always set the Assigned User ID. && bRequireUserAssignment )
																par.Value = Sql.ToDBGuid(gASSIGNED_USER_ID);  // 01/10/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
															// 02/20/2013 Paul.  We need to set the MODIFIED_USER_ID. 
															else if ( sParameterName == "MODIFIED_USER_ID" )
																par.Value = Sql.ToDBGuid(gASSIGNED_USER_ID);
															else
																par.Value = DBNull.Value;
														}
														DateTime dtDATE_MODIFIED = Sql.ToDateTime(XmlUtil.SelectSingleNode(xNote, "user_time"  ));
														string   sDESCRIPTION    = Sql.ToString  (XmlUtil.SelectSingleNode(xNote, "description")).Trim();
														string   sNAME           = sDESCRIPTION;
														if ( sNAME.IndexOf(ControlChars.CrLf) > 0 )
															sNAME = sNAME.Substring(0, sNAME.IndexOf(ControlChars.CrLf));
														if ( Sql.IsEmptyString(sNAME) )
															sNAME = "Note";
														// 02/04/2010 Paul.  The modified user is always the person who imported the data. 
														Sql.SetParameter(cmdNOTES_Import, "@MODIFIED_USER_ID", Security.USER_ID);
														Sql.SetParameter(cmdNOTES_Import, "@DATE_MODIFIED"   , dtDATE_MODIFIED );
														Sql.SetParameter(cmdNOTES_Import, "@NAME"            , sNAME           );
														Sql.SetParameter(cmdNOTES_Import, "@PARENT_TYPE"     , sImportModule   );
														Sql.SetParameter(cmdNOTES_Import, "@PARENT_ID"       , gID             );
														Sql.SetParameter(cmdNOTES_Import, "@DESCRIPTION"     , sDESCRIPTION    );
														
														sbImport.Append(Sql.ExpandParameters(cmdNOTES_Import));
														sbImport.AppendLine(";");
														cmdNOTES_Import.ExecuteNonQuery();
													}
												}
												if ( cmdCALLS_Import != null && cmdMEETINGS_Import != null )
												{
													// 02/04/2010 Paul.  The Note and Activity import must also be part of the transaction. 
													if ( bUSE_TRANSACTION || bPreview )
													{
														cmdCALLS_Import.Transaction = trn;
														cmdMEETINGS_Import.Transaction = trn;
													}
													XmlNodeList nlActivities = node.SelectNodes("activities");
													foreach ( XmlNode xActivity in nlActivities )
													{
														foreach(IDbDataParameter par in cmdCALLS_Import.Parameters)
														{
															// 03/27/2010 Paul.  The ParameterName will start with @, so we need to remove it. 
															string sParameterName = Sql.ExtractDbName(cmdCALLS_Import, par.ParameterName).ToUpper();
															if ( sParameterName == "TEAM_ID" && bEnableTeamManagement ) // 01/11/2011 Paul.  Ignore the Required flag. && bRequireTeamManagement )
																par.Value = Sql.ToDBGuid(gTEAM_ID);  // 01/10/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
															else if ( sParameterName == "ASSIGNED_USER_ID" ) // 01/11/2011 Paul.  Always set the Assigned User ID. && bRequireUserAssignment )
																par.Value = Sql.ToDBGuid(gASSIGNED_USER_ID);  // 01/10/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
															// 02/20/2013 Paul.  We need to set the MODIFIED_USER_ID. 
															else if ( sParameterName == "MODIFIED_USER_ID" )
																par.Value = Sql.ToDBGuid(gASSIGNED_USER_ID);
															else
																par.Value = DBNull.Value;
														}
														foreach(IDbDataParameter par in cmdMEETINGS_Import.Parameters)
														{
															// 03/27/2010 Paul.  The ParameterName will start with @, so we need to remove it. 
															string sParameterName = Sql.ExtractDbName(cmdMEETINGS_Import, par.ParameterName).ToUpper();
															if ( sParameterName == "TEAM_ID" && bEnableTeamManagement ) // 01/11/2011 Paul.  Ignore the Required flag. && bRequireTeamManagement )
																par.Value = Sql.ToDBGuid(gTEAM_ID);  // 01/10/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
															else if ( sParameterName == "ASSIGNED_USER_ID" ) // 01/11/2011 Paul.  Always set the Assigned User ID. && bRequireUserAssignment )
																par.Value = Sql.ToDBGuid(gASSIGNED_USER_ID);  // 01/10/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
															// 02/20/2013 Paul.  We need to set the MODIFIED_USER_ID. 
															else if ( sParameterName == "MODIFIED_USER_ID" )
																par.Value = Sql.ToDBGuid(gASSIGNED_USER_ID);
															else
																par.Value = DBNull.Value;
														}
														int      nTYPE             = Sql.ToInteger (XmlUtil.SelectSingleNode(xActivity, "type"      ));
														DateTime dtSTART_TIME      = Sql.ToDateTime(XmlUtil.SelectSingleNode(xActivity, "start_time"));
														DateTime dtEND_TIME        = Sql.ToDateTime(XmlUtil.SelectSingleNode(xActivity, "end_time"  ));
														// 02/04/2010 Paul.  An activity does not have a user_time, so use the start time. 
														// 05/10/2010 Paul.  We now support ACT! etime. 
														DateTime dtDATE_MODIFIED   = Sql.ToDateTime(XmlUtil.SelectSingleNode(xActivity, "etime"     ));
														int      nREMINDER_TIME    = Sql.ToInteger (XmlUtil.SelectSingleNode(xActivity, "lead_time" ));
														int      nDURATION         = Sql.ToInteger (XmlUtil.SelectSingleNode(xActivity, "duration"  ));
														int      nDURATION_HOURS   = nDURATION / 60;
														int      nDURATION_MINUTES = nDURATION % 60;
														string   sDESCRIPTION      = Sql.ToString  (XmlUtil.SelectSingleNode(xActivity, "description")).Trim();
														string   sNAME             = Sql.ToString  (XmlUtil.SelectSingleNode(xActivity, "regarding"  ));
														if ( Sql.IsEmptyString(sNAME) )
															sNAME = "Activity";
														if ( nTYPE == 0 )  // Call when TYPE == 0. 
														{
															// 02/04/2010 Paul.  The modified user is always the person who imported the data. 
															Sql.SetParameter(cmdCALLS_Import, "@MODIFIED_USER_ID", Security.USER_ID );
															Sql.SetParameter(cmdCALLS_Import, "@DATE_MODIFIED"   , dtDATE_MODIFIED  );
															Sql.SetParameter(cmdCALLS_Import, "@NAME"            , sNAME            );
															Sql.SetParameter(cmdCALLS_Import, "@DURATION_HOURS"  , nDURATION_HOURS  );
															Sql.SetParameter(cmdCALLS_Import, "@DURATION_MINUTES", nDURATION_MINUTES);
															Sql.SetParameter(cmdCALLS_Import, "@DATE_TIME"       , dtSTART_TIME     );
															Sql.SetParameter(cmdCALLS_Import, "@PARENT_TYPE"     , sImportModule    );
															Sql.SetParameter(cmdCALLS_Import, "@PARENT_ID"       , gID              );
															Sql.SetParameter(cmdCALLS_Import, "@REMINDER_TIME"   , nREMINDER_TIME   );
															Sql.SetParameter(cmdCALLS_Import, "@DESCRIPTION"     , sDESCRIPTION     );
															
															sbImport.Append(Sql.ExpandParameters(cmdCALLS_Import));
															sbImport.AppendLine(";");
															cmdCALLS_Import.ExecuteNonQuery();
														}
														else // Meeting when TYPE == 1, TO-DO when TYPE == 2. 
														{
															// 02/04/2010 Paul.  The modified user is always the person who imported the data. 
															Sql.SetParameter(cmdMEETINGS_Import, "@MODIFIED_USER_ID", Security.USER_ID );
															Sql.SetParameter(cmdMEETINGS_Import, "@DATE_MODIFIED"   , dtDATE_MODIFIED  );
															Sql.SetParameter(cmdMEETINGS_Import, "@NAME"            , sNAME            );
															Sql.SetParameter(cmdMEETINGS_Import, "@DURATION_HOURS"  , nDURATION_HOURS  );
															Sql.SetParameter(cmdMEETINGS_Import, "@DURATION_MINUTES", nDURATION_MINUTES);
															Sql.SetParameter(cmdMEETINGS_Import, "@DATE_TIME"       , dtSTART_TIME     );
															Sql.SetParameter(cmdMEETINGS_Import, "@PARENT_TYPE"     , sImportModule    );
															Sql.SetParameter(cmdMEETINGS_Import, "@PARENT_ID"       , gID              );
															Sql.SetParameter(cmdMEETINGS_Import, "@REMINDER_TIME"   , nREMINDER_TIME   );
															Sql.SetParameter(cmdMEETINGS_Import, "@DESCRIPTION"     , sDESCRIPTION     );
															
															sbImport.Append(Sql.ExpandParameters(cmdMEETINGS_Import));
															sbImport.AppendLine(";");
															cmdMEETINGS_Import.ExecuteNonQuery();
														}
													}
												}
												if ( cmdPROSPECT_LISTS_CONTACTS_Import != null )
												{
													// 02/04/2010 Paul.  The Note and Activity import must also be part of the transaction. 
													if ( bUSE_TRANSACTION || bPreview )
													{
														cmdPROSPECT_LISTS_CONTACTS_Import.Transaction = trn;
													}
													XmlNodeList nlProspectLists = node.SelectNodes("prospect_lists");
													foreach ( XmlNode xProspectList in nlProspectLists )
													{
														string sNAME = Sql.ToString(XmlUtil.SelectSingleNode(xProspectList, "name"));
														if ( hashProspectLists.ContainsKey(sNAME) )
														{
															Guid gPROSPECT_LIST_ID2 = Sql.ToGuid(hashProspectLists[sNAME]);
															foreach(IDbDataParameter par in cmdPROSPECT_LISTS_CONTACTS_Import.Parameters)
															{
																par.Value = DBNull.Value;
															}
															// 02/04/2010 Paul.  The modified user is always the person who imported the data. 
															Sql.SetParameter(cmdPROSPECT_LISTS_CONTACTS_Import, "@MODIFIED_USER_ID", Security.USER_ID );
															Sql.SetParameter(cmdPROSPECT_LISTS_CONTACTS_Import, "@PROSPECT_LIST_ID", gPROSPECT_LIST_ID2);
															Sql.SetParameter(cmdPROSPECT_LISTS_CONTACTS_Import, "@CONTACT_ID"      , gID              );
															
															sbImport.Append(Sql.ExpandParameters(cmdPROSPECT_LISTS_CONTACTS_Import));
															sbImport.AppendLine(";");
															cmdPROSPECT_LISTS_CONTACTS_Import.ExecuteNonQuery();
														}
													}
												}
												// 01/11/2011 Paul.  Use a separate procedure as it has different parameters. 
												if ( cmdPROSPECT_LISTS_LEADS_Import != null )
												{
													// 02/04/2010 Paul.  The Note and Activity import must also be part of the transaction. 
													if ( bUSE_TRANSACTION || bPreview )
													{
														cmdPROSPECT_LISTS_LEADS_Import.Transaction = trn;
													}
													XmlNodeList nlProspectLists = node.SelectNodes("prospect_lists");
													foreach ( XmlNode xProspectList in nlProspectLists )
													{
														string sNAME = Sql.ToString(XmlUtil.SelectSingleNode(xProspectList, "name"));
														if ( hashProspectLists.ContainsKey(sNAME) )
														{
															gPROSPECT_LIST_ID = Sql.ToGuid(hashProspectLists[sNAME]);
															foreach(IDbDataParameter par in cmdPROSPECT_LISTS_LEADS_Import.Parameters)
															{
																par.Value = DBNull.Value;
															}
															// 02/04/2010 Paul.  The modified user is always the person who imported the data. 
															Sql.SetParameter(cmdPROSPECT_LISTS_LEADS_Import, "@MODIFIED_USER_ID", Security.USER_ID );
															Sql.SetParameter(cmdPROSPECT_LISTS_LEADS_Import, "@PROSPECT_LIST_ID", gPROSPECT_LIST_ID);
															Sql.SetParameter(cmdPROSPECT_LISTS_LEADS_Import, "@LEAD_ID"         , gID              );
															
															sbImport.Append(Sql.ExpandParameters(cmdPROSPECT_LISTS_LEADS_Import));
															sbImport.AppendLine(";");
															cmdPROSPECT_LISTS_LEADS_Import.ExecuteNonQuery();
														}
													}
												}
												// 01/11/2011 Paul.  Use a separate procedure as it has different parameters. 
												if ( cmdPROSPECT_LISTS_PROSPECTS_Import != null )
												{
													// 02/04/2010 Paul.  The Note and Activity import must also be part of the transaction. 
													if ( bUSE_TRANSACTION || bPreview )
													{
														cmdPROSPECT_LISTS_PROSPECTS_Import.Transaction = trn;
													}
													XmlNodeList nlProspectLists = node.SelectNodes("prospect_lists");
													foreach ( XmlNode xProspectList in nlProspectLists )
													{
														string sNAME = Sql.ToString(XmlUtil.SelectSingleNode(xProspectList, "name"));
														if ( hashProspectLists.ContainsKey(sNAME) )
														{
															gPROSPECT_LIST_ID = Sql.ToGuid(hashProspectLists[sNAME]);
															foreach(IDbDataParameter par in cmdPROSPECT_LISTS_PROSPECTS_Import.Parameters)
															{
																par.Value = DBNull.Value;
															}
															// 02/04/2010 Paul.  The modified user is always the person who imported the data. 
															Sql.SetParameter(cmdPROSPECT_LISTS_PROSPECTS_Import, "@MODIFIED_USER_ID", Security.USER_ID );
															Sql.SetParameter(cmdPROSPECT_LISTS_PROSPECTS_Import, "@PROSPECT_LIST_ID", gPROSPECT_LIST_ID);
															Sql.SetParameter(cmdPROSPECT_LISTS_PROSPECTS_Import, "@PROSPECT_ID"     , gID              );
															
															sbImport.Append(Sql.ExpandParameters(cmdPROSPECT_LISTS_PROSPECTS_Import));
															sbImport.AppendLine(";");
															cmdPROSPECT_LISTS_PROSPECTS_Import.ExecuteNonQuery();
														}
													}
												}
												// 10/27/2017 Paul.  Add Accounts as email source. 
												if ( cmdPROSPECT_LISTS_ACCOUNTS_Import != null )
												{
													// 02/04/2010 Paul.  The Note and Activity import must also be part of the transaction. 
													if ( bUSE_TRANSACTION || bPreview )
													{
														cmdPROSPECT_LISTS_ACCOUNTS_Import.Transaction = trn;
													}
													XmlNodeList nlProspectLists = node.SelectNodes("prospect_lists");
													foreach ( XmlNode xProspectList in nlProspectLists )
													{
														string sNAME = Sql.ToString(XmlUtil.SelectSingleNode(xProspectList, "name"));
														if ( hashProspectLists.ContainsKey(sNAME) )
														{
															gPROSPECT_LIST_ID = Sql.ToGuid(hashProspectLists[sNAME]);
															foreach(IDbDataParameter par in cmdPROSPECT_LISTS_ACCOUNTS_Import.Parameters)
															{
																par.Value = DBNull.Value;
															}
															// 02/04/2010 Paul.  The modified user is always the person who imported the data. 
															Sql.SetParameter(cmdPROSPECT_LISTS_ACCOUNTS_Import, "@MODIFIED_USER_ID", Security.USER_ID );
															Sql.SetParameter(cmdPROSPECT_LISTS_ACCOUNTS_Import, "@PROSPECT_LIST_ID", gPROSPECT_LIST_ID);
															Sql.SetParameter(cmdPROSPECT_LISTS_ACCOUNTS_Import, "@ACCOUNT_ID"      , gID              );
															
															sbImport.Append(Sql.ExpandParameters(cmdPROSPECT_LISTS_ACCOUNTS_Import));
															sbImport.AppendLine(";");
															cmdPROSPECT_LISTS_ACCOUNTS_Import.ExecuteNonQuery();
														}
													}
												}
											}
											// 09/06/2012 Paul.  Allow direct import into prospect list. 
											// 10/27/2017 Paul.  Add Accounts as email source. 
											else if ( (sImportModule == "Contacts" || sImportModule == "Leads" || sImportModule == "Prospects" || sImportModule == "Accounts") && !Sql.IsEmptyGuid(gPROSPECT_LIST_ID) )
											{
												//Guid gPROSPECT_LIST_ID = Sql.ToGuid(ViewState["PROSPECT_LIST_ID"]);
												if ( cmdPROSPECT_LISTS_CONTACTS_Import != null )
												{
													if ( bUSE_TRANSACTION || bPreview )
													{
														cmdPROSPECT_LISTS_CONTACTS_Import.Transaction = trn;
													}
													foreach(IDbDataParameter par in cmdPROSPECT_LISTS_CONTACTS_Import.Parameters)
													{
														par.Value = DBNull.Value;
													}
													Sql.SetParameter(cmdPROSPECT_LISTS_CONTACTS_Import, "@MODIFIED_USER_ID", Security.USER_ID );
													Sql.SetParameter(cmdPROSPECT_LISTS_CONTACTS_Import, "@PROSPECT_LIST_ID", gPROSPECT_LIST_ID);
													Sql.SetParameter(cmdPROSPECT_LISTS_CONTACTS_Import, "@CONTACT_ID"      , gID              );
													
													sbImport.Append(Sql.ExpandParameters(cmdPROSPECT_LISTS_CONTACTS_Import));
													sbImport.AppendLine(";");
													cmdPROSPECT_LISTS_CONTACTS_Import.ExecuteNonQuery();
												}
												if ( cmdPROSPECT_LISTS_LEADS_Import != null )
												{
													if ( bUSE_TRANSACTION || bPreview )
													{
														cmdPROSPECT_LISTS_LEADS_Import.Transaction = trn;
													}
													foreach(IDbDataParameter par in cmdPROSPECT_LISTS_LEADS_Import.Parameters)
													{
														par.Value = DBNull.Value;
													}
													Sql.SetParameter(cmdPROSPECT_LISTS_LEADS_Import, "@MODIFIED_USER_ID", Security.USER_ID );
													Sql.SetParameter(cmdPROSPECT_LISTS_LEADS_Import, "@PROSPECT_LIST_ID", gPROSPECT_LIST_ID);
													Sql.SetParameter(cmdPROSPECT_LISTS_LEADS_Import, "@LEAD_ID"         , gID              );
													
													sbImport.Append(Sql.ExpandParameters(cmdPROSPECT_LISTS_LEADS_Import));
													sbImport.AppendLine(";");
													cmdPROSPECT_LISTS_LEADS_Import.ExecuteNonQuery();
												}
												if ( cmdPROSPECT_LISTS_PROSPECTS_Import != null )
												{
													if ( bUSE_TRANSACTION || bPreview )
													{
														cmdPROSPECT_LISTS_PROSPECTS_Import.Transaction = trn;
													}
													foreach(IDbDataParameter par in cmdPROSPECT_LISTS_PROSPECTS_Import.Parameters)
													{
														par.Value = DBNull.Value;
													}
													Sql.SetParameter(cmdPROSPECT_LISTS_PROSPECTS_Import, "@MODIFIED_USER_ID", Security.USER_ID );
													Sql.SetParameter(cmdPROSPECT_LISTS_PROSPECTS_Import, "@PROSPECT_LIST_ID", gPROSPECT_LIST_ID);
													Sql.SetParameter(cmdPROSPECT_LISTS_PROSPECTS_Import, "@PROSPECT_ID"     , gID              );
													
													sbImport.Append(Sql.ExpandParameters(cmdPROSPECT_LISTS_PROSPECTS_Import));
													sbImport.AppendLine(";");
													cmdPROSPECT_LISTS_PROSPECTS_Import.ExecuteNonQuery();
												}
												// 10/27/2017 Paul.  Add Accounts as email source. 
												if ( cmdPROSPECT_LISTS_ACCOUNTS_Import != null )
												{
													if ( bUSE_TRANSACTION || bPreview )
													{
														cmdPROSPECT_LISTS_ACCOUNTS_Import.Transaction = trn;
													}
													foreach(IDbDataParameter par in cmdPROSPECT_LISTS_ACCOUNTS_Import.Parameters)
													{
														par.Value = DBNull.Value;
													}
													Sql.SetParameter(cmdPROSPECT_LISTS_ACCOUNTS_Import, "@MODIFIED_USER_ID", Security.USER_ID );
													Sql.SetParameter(cmdPROSPECT_LISTS_ACCOUNTS_Import, "@PROSPECT_LIST_ID", gPROSPECT_LIST_ID);
													Sql.SetParameter(cmdPROSPECT_LISTS_ACCOUNTS_Import, "@ACCOUNT_ID"      , gID              );
													
													sbImport.Append(Sql.ExpandParameters(cmdPROSPECT_LISTS_ACCOUNTS_Import));
													sbImport.AppendLine(";");
													cmdPROSPECT_LISTS_ACCOUNTS_Import.ExecuteNonQuery();
												}
											}
										}
										nImported++;
										row["IMPORT_LAST_COLUMN"] = DBNull.Value;
									}
									Response.Write(" ");
								}
								catch(Exception ex)
								{
									row["IMPORT_ROW_STATUS"] = false;
									row["IMPORT_ROW_ERROR" ] = L10n.Term("Import.LBL_ERROR") + " " + Sql.ToString(row["IMPORT_LAST_COLUMN"]) + ". " + ex.Message;
									nFailed++;
									// 10/31/2006 Paul.  Abort after 200 errors. 
									if ( nFailed >= nMAX_ERRORS )
									{
										sbErrors.AppendLine(L10n.Term("Import.LBL_MAX_ERRORS"));
										break;
									}
								}
							}
							// 10/29/2006 Paul.  Save the processed table so that the result can be browsed. 
							string sProcessedFileName = Security.USER_ID.ToString() + " " + Guid.NewGuid().ToString() + ".xml";
							DataSet dsProcessed = new DataSet();
							dsProcessed.Tables.Add(dtProcessed);
							dsProcessed.WriteXml(Path.Combine(Path.GetTempPath(), sProcessedFileName), XmlWriteMode.WriteSchema);
							Session["TempFile." + sProcessedFileID] = sProcessedFileName;

							// 10/31/2006 Paul.  The transaction should rollback if it is not explicitly committed. 
							// Manually rolling back is causing a timeout. 
							//if ( bPreview || nFailed > 0 )
							//	trn.Rollback();
							//else
							if ( trn != null && !bPreview && nFailed == 0 )
							{
								trn.Commit();
							}
						}
						catch(Exception ex)
						{
							// 10/31/2006 Paul.  The transaction should rollback if it is not explicitly committed. 
							//if ( trn.Connection != null )
							//	trn.Rollback();
							// 10/31/2006 Paul.  Don't throw this exception.  We want to be able to display the failed count. 
							nFailed++;
							//throw(new Exception(ex.Message, ex.InnerException));
							sbErrors.AppendLine(ex.Message);
						}
						finally
						{
							if ( trn != null )
								trn.Dispose();
						}
					}
				}
			}
			catch ( Exception ex )
			{
				sbErrors.AppendLine(ex.Message);
			}
		}

	}
}

