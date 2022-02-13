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
using System.Data.Odbc;
using System.Data.OleDb;
using System.Text;
using System.Xml;
using System.Web;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for SplendidImport.
	/// </summary>
	public class SplendidImport
	{
		private static void LogError(ref StringBuilder sbErrors, string sCommand, string sMessage)
		{
			sbErrors.AppendLine("<hr width=\"100%\" height=\"2px\" /><table width=\"100%\"><tr><td width=\"50%\">" + sCommand + "</td><td><font color=red>" + sMessage + "</font></td></tr></table>");
		}

		public static void Import(XmlDocument xml, ArrayList arrTables, bool bTruncate)
		{
			HttpResponse Response = HttpContext.Current.Response;
			// 12/16/2005 Paul.  First create a hash table to convert tab name to a uppercase table name. 
			Hashtable hashTables = new Hashtable();
			XmlNodeList nlTables = xml.DocumentElement.ChildNodes;
			foreach(XmlNode node in nlTables)
			{
				if ( !hashTables.ContainsKey(node.Name.ToUpper()) )
					hashTables.Add(node.Name.ToUpper(), node.Name);
			}
			
			ArrayList lstReservedTables = new ArrayList();
			lstReservedTables.Add("CONFIG"                   );
			lstReservedTables.Add("DETAILVIEWS"              );
			lstReservedTables.Add("DETAILVIEWS_FIELDS"       );
			lstReservedTables.Add("DETAILVIEWS_RELATIONSHIPS");
			lstReservedTables.Add("EDITVIEWS"                );
			lstReservedTables.Add("EDITVIEWS_FIELDS"         );
			// 04/19/20910 Paul.  Add separate table for EditView Relationships. 
			lstReservedTables.Add("EDITVIEWS_RELATIONSHIPS");
			lstReservedTables.Add("GRIDVIEWS"                );
			lstReservedTables.Add("GRIDVIEWS_COLUMNS"        );
			lstReservedTables.Add("LANGUAGES"                );
			lstReservedTables.Add("MODULES"                  );
			lstReservedTables.Add("SHORTCUTS"                );
			lstReservedTables.Add("TERMINOLOGY"              );
			lstReservedTables.Add("TIMEZONES"                );

			// 09/29/2006 Paul.  The following are SugarCRM config tables. 
			lstReservedTables.Add("ACL_ACTIONS"              );
			lstReservedTables.Add("CURRENCIES"               );
			lstReservedTables.Add("RELATIONSHIPS"            );
			// 10/01/2006 Paul.  Can't reserve Users because too many other tables depend on it. 
			//lstReservedTables.Add("USERS"                    );

			StringBuilder sbErrors = new StringBuilder();
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			if ( arrTables == null )
			{
				arrTables = new ArrayList();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = "select * from vwSqlTableDependencies order by 2, 1";
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								for ( int i = 0 ; i < dt.Rows.Count ; i++ )
								{
									DataRow row = dt.Rows[i];
									arrTables.Add(row["name"].ToString());
								}
							}
						}
						// 10/02/2006 Paul.  We need to delete tables that reference the tables we are importing. 
						Hashtable hashReferenced = new Hashtable();
						StringBuilder sbReferenced = new StringBuilder();
						foreach ( string sKey in hashTables.Keys )
						{
							if ( sbReferenced.Length > 0 )
								sbReferenced.Append(", ");
							sbReferenced.Append("'" + sKey + "'");
						}
						if ( sbReferenced.Length > 0 )
						{
							cmd.CommandText = "select distinct TABLE_NAME from vwSqlForeignKeys where REFERENCED_TABLE_NAME in (" + sbReferenced.ToString() + ")";
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									for ( int i = 0 ; i < dt.Rows.Count ; i++ )
									{
										DataRow row = dt.Rows[i];
										hashReferenced.Add(row["TABLE_NAME"].ToString(), null);
									}
								}
							}
						}
						if ( bTruncate )
						{
							cmd.CommandText = "select * from vwSqlTableDependencies order by 2 desc, 1 desc";
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								using ( DataTable dt = new DataTable() )
								{
									da.Fill(dt);
									for ( int i = 0 ; i < dt.Rows.Count && Response.IsClientConnected ; i++ )
									{
										DataRow row = dt.Rows[i];
										string sTABLE_NAME = row["name"].ToString().ToUpper();
										// 12/18/2005 Paul.  Some tables are reserved and should not be truncated or imported. 
										if ( lstReservedTables.Contains(sTABLE_NAME) )
											continue;
										// 12/18/2005 Paul.  Only truncate tables that are being imported or a table it references. 
										// 10/02/2006 Paul.  We need to truncated referenced tables because they may reference a table being imported. 
										if ( hashTables.ContainsKey(sTABLE_NAME) || hashReferenced.ContainsKey(sTABLE_NAME) )
										{
											try
											{
												if ( sTABLE_NAME == "USERS" )
												{
													// 12/17/2005 Paul.  Don't delete the existing user, otherwise it will cause a login problem in the future. 
													cmd.CommandText = "delete from USERS where ID != @ID";
													Sql.AddParameter(cmd, "@ID", Security.USER_ID);
												}
												else
												{
													// 05/04/2008 Paul.  Protect against SQL Injection. A table name will never have a space character.
													sTABLE_NAME = sTABLE_NAME.Replace(" ", "");
													cmd.CommandText = "delete from " + sTABLE_NAME;
												}
												SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "Delete Database Table: " + sTABLE_NAME);
												cmd.ExecuteNonQuery();
												Response.Write(" "); // Write a singe byte to keep the connection open. 
#if DEBUG
												LogError(ref sbErrors, Sql.ExpandParameters(cmd), "");
#endif
											}
											catch(Exception ex)
											{
												LogError(ref sbErrors, Sql.ExpandParameters(cmd), ex.Message);
											}
										}
									}
								}
							}
						}
					}
				}
			}
			for ( int i = 0 ; i < arrTables.Count && Response.IsClientConnected ; i++ )
			{
				string sTABLE_NAME = arrTables[i].ToString().ToUpper();
				// 12/18/2005 Paul.  Some tables are reserved and should not be truncated or imported. 
				if ( lstReservedTables.Contains(sTABLE_NAME) )
					continue;
				if ( hashTables.ContainsKey(sTABLE_NAME) )
				{
					string sXML_TABLE_NAME = hashTables[sTABLE_NAME].ToString();
					
					XmlNodeList nlRows = xml.DocumentElement.SelectNodes(sXML_TABLE_NAME);
					if ( nlRows.Count > 0 )
					{
						LogError(ref sbErrors, sTABLE_NAME, "Importing " + nlRows.Count.ToString() + " records.");
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "Import Database Table: " + sTABLE_NAME);
						// 12/17/2005 Paul.  Use a new connection for each table import so that connection state will be reset.  
						// My main concern is that the identity_insert gets reset. 
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							try
							{
								// 12/08/2009 Paul.  Identity fields have been replaced with the NUMBER_SEQUENCES table. 
								/*
								if ( Sql.IsSQLServer(con) )
								{
									// 12/17/2005 Paul.  In SQL Server, turn on identity_insert. 
									string sIDENTITY_NAME = String.Empty;
									// 09/30/2006 Paul.  Switch needs to use sTABLE_NAME and not sIDENTITY_NAME. 
									switch ( sTABLE_NAME )
									{
										case "BUGS"          : sIDENTITY_NAME = "BUGS"          ;  break;
										case "CASES"         : sIDENTITY_NAME = "CASES"         ;  break;
										case "CAMPAIGNS"     : sIDENTITY_NAME = "CAMPAIGNS"     ;  break;
										case "PROSPECTS"     : sIDENTITY_NAME = "PROSPECTS"     ;  break;
										case "QUOTES"        : sIDENTITY_NAME = "QUOTES"        ;  break;
										case "EMAILMAN"      : sIDENTITY_NAME = "EMAILMAN"      ;  break;
										case "CAMPAIGN_TRKRS": sIDENTITY_NAME = "CAMPAIGN_TRKRS";  break;
									}
									if ( !Sql.IsEmptyString(sIDENTITY_NAME) )
									{
										IDbCommand cmdIdentity = con.CreateCommand();
										cmdIdentity.CommandText = "set identity_insert " + sIDENTITY_NAME + " on";
										cmdIdentity.ExecuteNonQuery();
									}
								}
								else if ( Sql.IsOracle(con) )
								{
									// 12/17/2005 Paul.  In Oracle, disable sequence triggers. 
									string sTRIGGER_NAME = String.Empty;
									switch ( sTABLE_NAME )
									{
										case "BUGS"          : sTRIGGER_NAME = "TR_S_BUGS_BUG_NUMBER"       ;  break;
										case "CASES"         : sTRIGGER_NAME = "TR_S_CASES_CASE_NUMBER"     ;  break;
										case "CAMPAIGNS"     : sTRIGGER_NAME = "TR_S_CAMPAIGNS_TRACKER_KEY" ;  break;
										case "PROSPECTS"     : sTRIGGER_NAME = "TR_S_PROSPECTS_TRACKER_KEY" ;  break;
										case "QUOTES"        : sTRIGGER_NAME = "TR_S_QUOTES_TRACKER_KEY"    ;  break;
										case "EMAILMAN"      : sTRIGGER_NAME = "TR_S_EMAILMAN_TRACKER_KEY"  ;  break;
										case "CAMPAIGN_TRKRS": sTRIGGER_NAME = "TR_S_CAMPAIGN_TRKRS_TRACKER";  break;
									}
									if ( !Sql.IsEmptyString(sTRIGGER_NAME) )
									{
										IDbCommand cmdTrigger = con.CreateCommand();
										cmdTrigger.CommandText = "alter trigger " + sTRIGGER_NAME + " disable";
										cmdTrigger.ExecuteNonQuery();
									}
								}
								*/

								int nTableErrors = 0;
								using ( DataTable dtColumns = new DataTable() )
								{
									string sSQL;
									// 02/29/2008 Niall.  Some SQL Server 2005 installations require matching case for the parameters. 
									// Since we force the parameter to be uppercase, we must also make it uppercase in the command text. 
									sSQL = "select *                       " + ControlChars.CrLf
									     + "  from vwSqlColumns            " + ControlChars.CrLf
									     + " where ObjectName = @OBJECTNAME" + ControlChars.CrLf
									     + "   and ObjectType = 'U'        " + ControlChars.CrLf
									     + " order by colid                " + ControlChars.CrLf;
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.CommandText = sSQL;
										// 09/02/2008 Paul.  Standardize the case of metadata tables to uppercase.  PostgreSQL defaults to lowercase. 
										Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, sTABLE_NAME));
										using ( DbDataAdapter da = dbf.CreateDataAdapter() )
										{
											((IDbDataAdapter)da).SelectCommand = cmd;
											da.Fill(dtColumns);
										}
									}
									DataView vwColumns = new DataView(dtColumns);
									foreach(XmlNode node in nlRows)
									{
										if ( !Response.IsClientConnected )
										{
											break;
										}
										// 09/28/2006 Paul.  Always start with a blank command and only insert fields that are used.  
										using ( IDbCommand cmdImport = con.CreateCommand() )
										{
											cmdImport.CommandText = "";
											cmdImport.CommandType = CommandType.Text;
											// 09/30/2006 Paul.  Count row errors so that we can skip bad rows, but continue with the rest of the import. 
											int nRowErrors = 0;
											// 09/28/2006 Paul.  Build the insert statement using only the fields provided in the data. 
											// This is so that we can allow default table values to do their job. 
											StringBuilder sbFields = new StringBuilder();
											for ( int j = 0; j < node.ChildNodes.Count; j++ )
											{
												string sName = node.ChildNodes[j].Name.ToUpper();
												vwColumns.RowFilter = "ColumnName = '" + sName + "'";
												if ( vwColumns.Count == 1 )
												{
													string sCsType = Sql.ToString (vwColumns[0]["CsType"]);
													int    nLength = Sql.ToInteger(vwColumns[0]["length"]);
													// 09/28/2006 Paul.  If the field is specified twice, then the second instance will prevail. 
													if ( Sql.FindParameter(cmdImport, "@" + sName) == null )
													{
														if ( sbFields.Length > 0 )
															sbFields.Append(", ");
														sbFields.Append(sName);
														// 09/28/2006 Paul.  We cannot use a StringBuilder for the values because we need to allow 
														// the Sql.CreateParameter() function to correct the parameter token, and it does this directly to CommandText. 
														if ( cmdImport.CommandText.Length > 0 )
															cmdImport.CommandText += ", ";
														cmdImport.CommandText += Sql.CreateDbName(cmdImport, "@" + sName);
														
														IDbDataParameter par = Sql.CreateParameter(cmdImport, "@" + sName, sCsType, nLength);
													}
													// 12/18/2005 Paul.  A short-sighted programmer at SugarCRM created GUIDs with invalid characters. 
													// We need to convert them to valid GUIDs. 
													string sText = node.ChildNodes[j].InnerText;
													// 08/20/2006 Paul.  Dynamically attempt to fix invalid GUIDs. It really only works for the ones defined below. 
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
													try
													{
														Sql.SetParameter(cmdImport, sName, sText);
													}
													catch(Exception ex)
													{
														LogError(ref sbErrors, Sql.ExpandParameters(cmdImport), ex.Message + ControlChars.CrLf + sName + "=" + sText);
														nRowErrors++;
														nTableErrors++ ;
													}
												}
											}
											// 10/01/2006 Paul.  Some tables in SugarCRM do not have an ID.  If SplendidCRM has an ID, then it is likely required. 
											// 10/01/2006 Paul.  We only need to specify the ID if the platform is not SQL Server.
											vwColumns.RowFilter = "ColumnName = 'ID'";
											if ( vwColumns.Count == 1 && !Sql.IsSQLServer(con) )
											{
												string sName = "ID";
												if ( Sql.FindParameter(cmdImport, "@ID") == null )
												{
													if ( sbFields.Length > 0 )
														sbFields.Append(", ");
													sbFields.Append(sName);
													if ( cmdImport.CommandText.Length > 0 )
														cmdImport.CommandText += ", ";
													cmdImport.CommandText += Sql.CreateDbName(cmdImport, "@" + sName);
													
													string sCsType = Sql.ToString (vwColumns[0]["CsType"]);
													int    nLength = Sql.ToInteger(vwColumns[0]["length"]);
													IDbDataParameter parID = Sql.CreateParameter(cmdImport, "@" + sName, sCsType, nLength);
													parID.Value = Guid.NewGuid();
												}
											}
											if ( nRowErrors == 0 )
											{
												try
												{
													// 09/28/2006 Paul.  We cannot use a StringBuilder for the values because we need to allow 
													// the Sql.CreateParameter() function to correct the parameter token, and it does this directly to CommandText. 
													cmdImport.CommandText = "insert into " + sTABLE_NAME + "(" + sbFields.ToString() + ")" + ControlChars.CrLf
													                      + "values(" + cmdImport.CommandText + ")" + ControlChars.CrLf;
													if ( cmdImport.Parameters.Count > 0 )
														cmdImport.ExecuteNonQuery();
													Response.Write(" ");
												}
												catch(Exception ex)
												{
													LogError(ref sbErrors, Sql.ExpandParameters(cmdImport), ex.Message);
													// 12/17/2005 Paul.  If there is an error, stop importing from this table. 
													// 12/18/2005 Paul.  I'd like to see the first 100 errors. 
													nTableErrors++ ;
													if ( nTableErrors > 100 )
														break;
												}
											}
										}
									}
								}
							}
							catch(Exception ex)
							{
								LogError(ref sbErrors, sTABLE_NAME, ex.Message);
							}
							finally
							{
								try
								{
									// 12/08/2009 Paul.  Identity fields have been replaced with the NUMBER_SEQUENCES table. 
									/*
									if ( Sql.IsSQLServer(con) )
									{
										// 12/17/2005 Paul.  In SQL Server, turn off identity_insert. 
										string sIDENTITY_NAME = String.Empty;
										// 09/30/2006 Paul.  Switch needs to use sTABLE_NAME and not sIDENTITY_NAME. 
										switch ( sTABLE_NAME )
										{
											case "BUGS"          : sIDENTITY_NAME = "BUGS"          ;  break;
											case "CASES"         : sIDENTITY_NAME = "CASES"         ;  break;
											case "CAMPAIGNS"     : sIDENTITY_NAME = "CAMPAIGNS"     ;  break;
											case "PROSPECTS"     : sIDENTITY_NAME = "PROSPECTS"     ;  break;
											case "QUOTES"        : sIDENTITY_NAME = "QUOTES"        ;  break;
											case "EMAILMAN"      : sIDENTITY_NAME = "EMAILMAN"      ;  break;
											case "CAMPAIGN_TRKRS": sIDENTITY_NAME = "CAMPAIGN_TRKRS";  break;
										}
										if ( !Sql.IsEmptyString(sIDENTITY_NAME) )
										{
											IDbCommand cmdIdentity = con.CreateCommand();
											cmdIdentity.CommandText = "set identity_insert " + sIDENTITY_NAME + " off";
											cmdIdentity.ExecuteNonQuery();
										}
									}
									else if ( Sql.IsOracle(con) )
									{
										// 12/17/2005 Paul.  In Oracle, enable sequence triggers. 
										string sTRIGGER_NAME = String.Empty;
										switch ( sTABLE_NAME )
										{
											case "BUGS"          : sTRIGGER_NAME = "TR_S_BUGS_BUG_NUMBER"       ;  break;
											case "CASES"         : sTRIGGER_NAME = "TR_S_CASES_CASE_NUMBER"     ;  break;
											case "CAMPAIGNS"     : sTRIGGER_NAME = "TR_S_CAMPAIGNS_TRACKER_KEY" ;  break;
											case "PROSPECTS"     : sTRIGGER_NAME = "TR_S_PROSPECTS_TRACKER_KEY" ;  break;
											case "QUOTES"        : sTRIGGER_NAME = "TR_S_QUOTES_TRACKER_KEY"    ;  break;
											case "EMAILMAN"      : sTRIGGER_NAME = "TR_S_EMAILMAN_TRACKER_KEY"  ;  break;
											case "CAMPAIGN_TRKRS": sTRIGGER_NAME = "TR_S_CAMPAIGN_TRKRS_TRACKER";  break;
										}
										if ( !Sql.IsEmptyString(sTRIGGER_NAME) )
										{
											IDbCommand cmdTrigger = con.CreateCommand();
											cmdTrigger.CommandText = "alter trigger " + sTRIGGER_NAME + " enable";
											cmdTrigger.ExecuteNonQuery();
										}
									}
									*/
								}
								catch(Exception ex)
								{
									LogError(ref sbErrors, sTABLE_NAME, ex.Message);
								}
							}
						}
						Response.Write(" "); // Write a singe byte to keep the connection open. 
					}
				}
			}
			// 12/18/2005 Paul.  Reserved tables will still be imported, but we use the associated spXXX_Update procedure.
			for ( int i = 0 ; i < arrTables.Count && Response.IsClientConnected ; i++ )
			{
				string sTABLE_NAME = arrTables[i].ToString().ToUpper();
				if ( hashTables.ContainsKey(sTABLE_NAME) && lstReservedTables.Contains(sTABLE_NAME) )
				{
					string sXML_TABLE_NAME = hashTables[sTABLE_NAME].ToString();
					
					XmlNodeList nlRows = xml.DocumentElement.SelectNodes(sXML_TABLE_NAME);
					if ( nlRows.Count > 0 )
					{
						SplendidError.SystemWarning(new StackTrace(true).GetFrame(0), "Import Database Table: " + sTABLE_NAME);
						// 12/17/2005 Paul.  Use a new connection for each table import so that connection state will be reset.  
						// My main concern is that the identity_insert gets reset. 
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							try
							{
								int nTableErrors = 0;
								// 06/04/2009 Paul.  If Team is required, then make sure to initialize the TEAM_ID.  Same is true for ASSIGNED_USER_ID. 
								bool bEnableTeamManagement  = Crm.Config.enable_team_management();
								bool bRequireTeamManagement = Crm.Config.require_team_management();
								bool bRequireUserAssignment = Crm.Config.require_user_assignment();
								IDbCommand cmdImport = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Update");
								foreach(XmlNode node in nlRows)
								{
									if ( !Response.IsClientConnected )
									{
										break;
									}
									// 10/10/2006 Paul.  Use IDbDataParameter to be consistent. 
									foreach(IDbDataParameter par in cmdImport.Parameters)
									{
										// 06/04/2009 Paul.  If Team is required, then make sure to initialize the TEAM_ID.  Same is true for ASSIGNED_USER_ID. 
										// 03/27/2010 Paul.  The ParameterName will start with @, so we need to remove it. 
										string sParameterName = Sql.ExtractDbName(cmdImport, par.ParameterName).ToUpper();
										if ( sParameterName == "TEAM_ID" && bEnableTeamManagement ) // 02/26/2011 Paul.  Ignore the Required flag. && bRequireTeamManagement )
											par.Value = Sql.ToDBGuid(Security.TEAM_ID);  // 02/26/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
										else if ( sParameterName == "ASSIGNED_USER_ID" ) // 02/26/2011 Paul.  Always set the Assigned User ID. && bRequireUserAssignment )
											par.Value = Sql.ToDBGuid(Security.USER_ID);  // 02/26/2011 Paul.  Make sure to convert Guid.Empty to DBNull. 
										// 02/20/2013 Paul.  We need to set the MODIFIED_USER_ID. 
										else if ( sParameterName == "MODIFIED_USER_ID" )
											par.Value = Sql.ToDBGuid(Security.USER_ID);
										else
											par.Value = DBNull.Value;
									}
									// 09/30/2006 Paul.  Count row errors so that we can skip bad rows, but continue with the rest of the import. 
									int nRowErrors = 0;
									for ( int j = 0; j < node.ChildNodes.Count; j++ )
									{
										string sName = node.ChildNodes[j].Name.ToUpper();
										string sText = node.ChildNodes[j].InnerText;
										// 08/20/2006 Paul.  Dynamically attempt to fix invalid GUIDs. It really only works for the ones defined below. 
										// 09/30/2006 Paul.  CREATED_BY counts as an ID. 
										if ( (sName == "ID" || sName.EndsWith("_ID") || sName == "CREATED_BY") )
										{
											// 10/05/2006 Paul.  IDs must be in upper case.  This is primarily for platforms that are case-significant. 
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
										try
										{
											Sql.SetParameter(cmdImport, node.ChildNodes[j].Name, sText);
										}
										catch(Exception ex)
										{
											LogError(ref sbErrors, Sql.ExpandParameters(cmdImport), ex.Message + ControlChars.CrLf + sName + "=" + sText);
											nRowErrors++;
											nTableErrors++ ;
										}
									}
									if ( nRowErrors == 0 )
									{
										try
										{
											cmdImport.ExecuteNonQuery();
											Response.Write(" ");
										}
										catch(Exception ex)
										{
											LogError(ref sbErrors, Sql.ExpandParameters(cmdImport), ex.Message);
											// 12/17/2005 Paul.  If there is an error, stop importing from this table. 
											// 12/18/2005 Paul.  I'd like to see the first 100 errors. 
											nTableErrors++ ;
											if ( nTableErrors > 100 )
												break;
										}
									}
								}
							}
							catch(Exception ex)
							{
								LogError(ref sbErrors, sTABLE_NAME, ex.Message);
							}
						}
						Response.Write(" "); // Write a singe byte to keep the connection open. 
					}
				}
			}
			if ( sbErrors.Length > 0 )
			{
				throw(new Exception(sbErrors.ToString()));
			}
		}

		public static void ZipSaveStream(Stream stm, string sTempPathName)
		{
			using ( FileStream stmDatabase = new FileStream(sTempPathName, FileMode.Create) )
			{
				using ( BinaryWriter mwtr = new BinaryWriter(stmDatabase) )
				{
					byte[] binBYTES = new byte[64*1024];
					// 01/31/2010 Paul.  When working with a ZipStream, it is better not to use a StreamReader. 
					while ( true )
					{
						int nReadBytes = stm.Read(binBYTES, 0, binBYTES.Length);
						if ( nReadBytes > 0 )
							mwtr.Write(binBYTES, 0, nReadBytes);
						else
							break;
					}
				}
			}
		}

		public static XmlDocument ConvertTableToXml(DataTable dt, string sRecordName)
		{
			return ConvertTableToXml(dt, sRecordName, false, false, null);
		}

		public static XmlDocument ConvertTableToXml(DataTable dt, string sRecordName, bool bWithHeader, bool bUseColumnName, List<String> arrIgnoreColumns)
		{
			XmlDocument xml = new XmlDocument();
			xml.AppendChild(xml.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
			xml.AppendChild(xml.CreateElement("xml"));

			// 01/30/2010 Paul.  Add ability to include table column names as the header for dBase import. 
			if ( bWithHeader )
			{
				XmlNode xRecord = xml.CreateElement(sRecordName);
				xml.DocumentElement.AppendChild(xRecord);
				for ( int nField = 0; nField < dt.Columns.Count; nField++ )
				{
					if ( arrIgnoreColumns != null && arrIgnoreColumns.Contains(dt.Columns[nField].ColumnName) )
						continue;
					XmlNode xField = xml.CreateElement("ImportField" + nField.ToString("000"));
					xRecord.AppendChild(xField);
					xField.InnerText = dt.Columns[nField].ColumnName;
				}
			}

			foreach ( DataRow row in dt.Rows )
			{
				XmlNode xRecord = xml.CreateElement(sRecordName);
				xml.DocumentElement.AppendChild(xRecord);
				for ( int nField = 0; nField < dt.Columns.Count; nField++ )
				{
					if ( arrIgnoreColumns != null && arrIgnoreColumns.Contains(dt.Columns[nField].ColumnName) )
						continue;
					string sColumnName = "ImportField" + nField.ToString("000");
					if ( bUseColumnName )
						sColumnName = dt.Columns[nField].ColumnName.ToLower();
					XmlNode xField = xml.CreateElement(sColumnName);
					xRecord.AppendChild(xField);
					if ( row[nField] != DBNull.Value )
					{
						xField.InnerText = row[nField].ToString();
					}
				}
			}
			return xml;
		}

		public static XmlDocument ConvertDBaseToXml(Stream stm, string sRecordName, bool bUseColumnName, List<String> arrIgnoreColumns)
		{
			return ConvertDBaseToXml(stm, sRecordName, bUseColumnName, arrIgnoreColumns, null);
		}

		public static XmlDocument ConvertDBaseToXml(Stream stm, string sRecordName, bool bUseColumnName, List<String> arrIgnoreColumns, List<String> arrAdditionalColumns)
		{
			XmlDocument xml = new XmlDocument();
			xml.AppendChild(xml.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
			xml.AppendChild(xml.CreateElement("xml"));

			string sTempPath = Path.GetTempPath();
			// 01/31/2010 Paul.  Due to the 8 character dBase limitation, we should create our own folder. 
			sTempPath = Path.Combine(sTempPath, "Splendid");
			if ( !Directory.Exists(sTempPath) )
			{
				Directory.CreateDirectory(sTempPath);
			}
			string sTempFileID   = Guid.NewGuid().ToString();
			// 01/30/2010 Paul.  The ODBC driver seems to have an 8 character file name limit. 
			string sTempFileName = sTempFileID.Replace("-", "").Substring(0, 8) + ".dbf";
			string sTempPathName = Path.Combine(sTempPath, sTempFileName);
			// 01/30/2010 Paul.  We should make sure that the file name is unique. 
			while ( File.Exists(sTempPathName) )
			{
				sTempFileID   = Guid.NewGuid().ToString();
				sTempFileName = sTempFileID.Replace("-", "").Substring(0, 8) + ".dbf";
				sTempPathName = Path.Combine(sTempPath, sTempFileName);
			}
			HttpContext.Current.Session["TempFile." + sTempFileID] = sTempPathName;
			
			ZipSaveStream(stm, sTempPathName);
#if true
			using ( OdbcConnection con = new OdbcConnection() )
			{
				con.ConnectionString = @"Driver={Microsoft dBase Driver (*.dbf)};SourceType=DBF;SourceDB=" + sTempPath + ";Exclusive=No;Collate=Machine;NULL=NO;DELETED=NO;BACKGROUNDFETCH=NO;";
				con.Open();
				using ( OdbcCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = @"select * from " + sTempPathName + "";
					using ( DataTable dt = new DataTable() )
					{
						try
						{
							dt.Load(cmd.ExecuteReader());
							// 02/02/2010 Paul.  We need the ability to add empty fields. 
							if ( arrAdditionalColumns != null )
							{
								foreach ( string sColumnName in arrAdditionalColumns )
								{
									dt.Columns.Add(sColumnName, typeof(System.String));
								}
							}
							// 02/02/2010 Paul.  Lets remove the column before the conversion to XML. 
							if ( arrIgnoreColumns != null )
							{
								foreach ( string sColumnName in arrIgnoreColumns )
								{
									if ( dt.Columns.Contains(sColumnName) )
									{
										dt.Columns.Remove(sColumnName);
									}
								}
							}
						}
						catch(Exception ex)
						{
							throw(new Exception(con.ConnectionString + "<br>" + cmd.CommandText + "<br>" + ex.Message));
						}
						xml = ConvertTableToXml(dt, sRecordName, !bUseColumnName, bUseColumnName, arrIgnoreColumns);
					}
				}
				con.Close();
			}
#else
			using ( OleDbConnection con = new OleDbConnection() )
			{
				con.ConnectionString = "Provider=Microsoft.Jet.OLEDB.4.0;Data Source=" + sTempPath + ";Extended Properties=dBASE IV;";
				con.Open();
				using ( OleDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = @"select * from " + sTempPathName + "";
					using ( DataTable dt = new DataTable() )
					{
						try
						{
							dt.Load(cmd.ExecuteReader());
							// 02/02/2010 Paul.  We need the ability to add empty fields. 
							if ( arrAdditionalColumns != null )
							{
								foreach ( string sColumnName in arrAdditionalColumns )
								{
									dt.Columns.Add(sColumnName, typeof(System.String));
								}
							}
							// 02/02/2010 Paul.  Lets remove the column before the conversion to XML. 
							if ( arrIgnoreColumns != null )
							{
								foreach ( string sColumnName in arrIgnoreColumns )
								{
									if ( dt.Columns.Contains(sColumnName) )
									{
										dt.Columns.Remove(sColumnName);
									}
								}
							}
						}
						catch(Exception ex)
						{
							throw(new Exception(con.ConnectionString + "<br>" + cmd.CommandText + "<br>" + ex.Message));
						}
						xml = ConvertTableToXml(dt, sImportModule.ToLower(), !bUseColumnName, bUseColumnName, arrIgnoreColumns);
					}
				}
				con.Close();
			}
#endif
			return xml;
		}

		public static XmlDocument ConvertTextToXml(string sRecordName, Stream stm, char chFieldSeparator)
		{
			int nMaxField = 0;
			XmlDocument xml = new XmlDocument();
			xml.AppendChild(xml.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
			xml.AppendChild(xml.CreateElement("xml"));
			using ( TextReader reader = new StreamReader(stm) )
			{
				string sLine = null;
				while ( (sLine = reader.ReadLine()) != null )
				{
					if ( sLine.Length == 0 )
						continue;

					XmlNode xRecord = xml.CreateElement(sRecordName);
					xml.DocumentElement.AppendChild(xRecord);
					int i = 0;
					int nMode = 0;
					int nField = 0;
					bool bContinueParsing = true;
					while ( bContinueParsing )
					{
						switch ( nMode )
						{
							case 0:  // Search for next entry. 
							{
								if ( chFieldSeparator == ControlChars.Tab )
								{
									// Don't skip the tab when it is used as a separator. 
									while ( Char.IsWhiteSpace(sLine[i]) && sLine[i] != ControlChars.Tab )
										i++;
								}
								else
								{
									while ( Char.IsWhiteSpace(sLine[i]) )
										i++;
								}
								nMode = 1;
								break;
							}
							case 1:  // Determine if field is quoted or unquoted. 
							{
								// first check if field is empty. 
								char chPunctuation = sLine[i];
								if ( chPunctuation == chFieldSeparator )
								{
									i++;
									XmlNode xField = xml.CreateElement("ImportField" + nField.ToString("000"));
									xRecord.AppendChild(xField);
									nField++;
									nMode = 0;
								}
								if ( chPunctuation == '\"' )
								{
									i++;
									// Field is quoted, so start reading until next quote. 
									nMode = 3;
								}
								else
								{
									// Field is unquoted, so start reading until next separator or end-of-line.
									nMode = 2;
								}
								break;
							}
							case 2:  // Extract unquoted field. 
							{
								XmlNode xField = xml.CreateElement("ImportField" + nField.ToString("000"));
								xRecord.AppendChild(xField);
								nField++;
								
								int nFieldStart = i;
								// Field is unquoted, so start reading until next separator or end-of-line.
								while ( i < sLine.Length && sLine[i] != chFieldSeparator )
									i++;
								int nFieldEnd = i;
								
								string sField = sLine.Substring(nFieldStart, nFieldEnd-nFieldStart);
								xField.InnerText = sField;
								nMode = 0;
								i++;
								break;
							}
							case 3:  // Extract quoted field. 
							{
								XmlNode xField = xml.CreateElement("ImportField" + nField.ToString("000"));
								xRecord.AppendChild(xField);
								nField++;
								
								int nFieldStart = i;
								// Field is quoted, so start reading until next quote.  Watch out for an escaped quote (two double quotes). 
								while ( ( i < sLine.Length && sLine[i] != '\"' ) || ( i + 1 < sLine.Length && sLine[i] == '\"' && sLine[i+1] == '\"' ) )
								{
									if ( i + 1 < sLine.Length && sLine[i] == '\"' && sLine[i+1] == '\"' )
										i++;
									i++;
								}
								int nFieldEnd = i;
								// Skip all characters until we reach the separator or end-of-line. 
								while ( i < sLine.Length && sLine[i] != chFieldSeparator )
									i++;
								
								string sField = sLine.Substring(nFieldStart, nFieldEnd-nFieldStart);
								sField = sField.Replace("\"\"", "\"");
								xField.InnerText = sField;
								nMode = 0;
								i++;
								break;
							}
							default:
								bContinueParsing = false;
								break;
						}
						if ( i >= sLine.Length )
							break;
					}
					nMaxField = Math.Max(nField, nMaxField);
				}
			}
			XmlNodeList nlRows = xml.DocumentElement.SelectNodes(sRecordName);
			if ( nlRows.Count > 0 )
			{
				// If the first record does not have all the fields, then add the missing fields. 
				XmlNode xNode = nlRows[0];
				while ( xNode.ChildNodes.Count < nMaxField )
				{
					XmlNode xField = xml.CreateElement("ImportField" + xNode.ChildNodes.Count.ToString("000"));
					xNode.AppendChild(xField);
				}
			}
			return xml;
		}

		public static XmlDocument ConvertXmlSpreadsheetToXml(XmlDocument xml, string sRecordName)
		{
			XmlDocument xmlImport = new XmlDocument();
			xmlImport.AppendChild(xmlImport.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
			xmlImport.AppendChild(xmlImport.CreateElement("xml"));
			
			XmlNamespaceManager nsmgr = new XmlNamespaceManager(xml.NameTable);
			string sSpreadsheetNamespace = "urn:schemas-microsoft-com:office:spreadsheet";
			nsmgr.AddNamespace("ss", sSpreadsheetNamespace);

			// 08/22/2006 Paul.  The Spreadsheet namespace is also the default namespace, so make sure to prefix nodes with ss.
			XmlNode xWorksheet = xml.DocumentElement.SelectSingleNode("ss:Worksheet", nsmgr);
			if ( xWorksheet != null )
			{
				XmlNode xTable = xWorksheet.SelectSingleNode("ss:Table", nsmgr);
				if ( xTable != null )
				{
					int nColumnCount = 0;
					XmlNode xColumnCount = xTable.Attributes.GetNamedItem("ss:ExpandedColumnCount");
					if ( xColumnCount != null )
						nColumnCount = Sql.ToInteger(xColumnCount.Value);
					XmlNodeList nlRows = xTable.SelectNodes("ss:Row", nsmgr);
					if ( nlRows.Count > 0 )
					{
						// 08/22/2006 Paul.  The first row is special in that we must make sure that all nodes exist. 
						XmlNode xRow = nlRows[0];
						if ( nColumnCount == 0 )
							nColumnCount = xRow.ChildNodes.Count;
						for ( int i = 0; i < nlRows.Count; i++ )
						{
							XmlNode xRecord = xmlImport.CreateElement(sRecordName);
							xmlImport.DocumentElement.AppendChild(xRecord);
							xRow = nlRows[i];
							
							for ( int j = 0, nField = 0; j < xRow.ChildNodes.Count; j++, nField++ )
							{
								XmlNode xField = xmlImport.CreateElement("ImportField" + nField.ToString("000"));
								xRecord.AppendChild(xField);
								XmlNode xCell = xRow.ChildNodes[j];
								int nCellIndex = 0;
								XmlNode xCellIndex = xCell.Attributes.GetNamedItem("ss:Index");
								if ( xCellIndex != null )
									nCellIndex = Sql.ToInteger(xCellIndex.Value);
								// 08/22/2006 Paul.  If there are any missing cells, then add them.
								while ( (nField + 1) < nCellIndex )
								{
									nField++;
									xField = xmlImport.CreateElement("ImportField" + nField.ToString("000"));
									xRecord.AppendChild(xField);
								}
								if ( xCell.ChildNodes.Count > 0 )
								{
									if ( xCell.ChildNodes[0].Name == "Data" )
									{
										xField.InnerText = xCell.ChildNodes[0].InnerText;
									}
								}
							}
						}
					}
				}
			}
			return xmlImport;
		}

		// 05/06/2011 Paul.  We need to be able to distinguish between Excel 2003 and Excel 2007. 
		public static XmlDocument ConvertStreamToXml(string sImportModule, string sSourceType, string sCustomDelimiterValue, Stream stm, string sFILE_EXT)
		{
			XmlDocument xml = new XmlDocument();
			// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
			// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
			// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
			xml.XmlResolver = null;
			xml.AppendChild(xml.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
			xml.AppendChild(xml.CreateElement("xml"));
			switch ( sSourceType )
			{
				case "xmlspreadsheet":
				{
					xml.Load(stm);
					xml = ConvertXmlSpreadsheetToXml(xml, sImportModule.ToLower());
					break;
				}
				case "xml":
				{
					// 10/10/2006 Paul.  Don't require that the file end in XML in order to be imported as a XML document. 
					// sFILE_MIME_TYPE == "text/xml"
					// 10/10/2006 Paul.  The reason we use a memory stream to load an XML file is to give us the opportunity to fix the MySQL data file. 
					// MySQL stores binary 0s and 1s for bit values, and we need them to be text 0s and 1s. 
					using ( MemoryStream mstm = new MemoryStream() )
					{
						using ( BinaryWriter mwtr = new BinaryWriter(mstm) )
						{
							using ( BinaryReader reader = new BinaryReader(stm) )
							{
								byte[] binBYTES = reader.ReadBytes(8 * 1024);
								while ( binBYTES.Length > 0 )
								{
									for ( int i = 0; i < binBYTES.Length; i++ )
									{
										// MySQL dump seems to dump binary 0 & 1 for byte values. 
										if ( binBYTES[i] == 0 )
											mstm.WriteByte(Convert.ToByte('0'));
										else if ( binBYTES[i] == 1 )
											mstm.WriteByte(Convert.ToByte('1'));
										else
											mstm.WriteByte(binBYTES[i]);
									}
									binBYTES = reader.ReadBytes(8 * 1024);
								}
							}
							mwtr.Flush();
							mstm.Seek(0, SeekOrigin.Begin);
							xml.Load(mstm);
							bool bExcelSheet = false;
							foreach ( XmlNode xNode in xml )
							{
								if ( xNode.NodeType == XmlNodeType.ProcessingInstruction )
								{
									if ( xNode.Name == "mso-application" && xNode.InnerText == "progid=\"Excel.Sheet\"" )
									{
										bExcelSheet = true;
										break;
									}
								}
							}
							if ( bExcelSheet )
								xml = ConvertXmlSpreadsheetToXml(xml, sImportModule.ToLower());
						}
					}
					break;
				}
				case "excel":
				{
					// 05/06/2011 Paul.  Use the OpenXML library to read an Excel 2007 xlsx file. 
					if ( sFILE_EXT.ToLower() == ".xlsx" )
					{
						xml = Excel2007Reader.ConvertSpreadsheetToXml(stm, sImportModule.ToLower());
					}
					else
					{
						ExcelDataReader.ExcelDataReader spreadsheet = new ExcelDataReader.ExcelDataReader(stm);
						if ( spreadsheet.WorkbookData.Tables.Count > 0 )
						{
							xml = ConvertTableToXml(spreadsheet.WorkbookData.Tables[0], sImportModule.ToLower());
						}
					}
					break;
				}
				case "other_tab":
				{
					CsvDataReader spreadsheet = new CsvDataReader(stm, ControlChars.Tab);
					if ( spreadsheet.Table != null )
					{
						xml = ConvertTableToXml(spreadsheet.Table, sImportModule.ToLower());
					}
					break;
				}
				case "custom_delimited":
				{
					// 10/10/2006 Paul.  We are only going to allow a single character separator for now. 
					if ( sCustomDelimiterValue.Length == 0 )
						sCustomDelimiterValue = ",";
					CsvDataReader spreadsheet = new CsvDataReader(stm, sCustomDelimiterValue[0]);
					if ( spreadsheet.Table != null )
					{
						xml = ConvertTableToXml(spreadsheet.Table, sImportModule.ToLower());
					}
					break;
				}
				case "dbase":
				{
					// 02/24/2010 Paul.  Test the dBase driver so that we can provide a good error message. 
					try
					{
						string sTempPath = Path.GetTempPath();
						using ( OdbcConnection con = new OdbcConnection() )
						{
							con.ConnectionString = @"Driver={Microsoft dBase Driver (*.dbf)};SourceType=DBF;SourceDB=" + sTempPath + ";Exclusive=No;Collate=Machine;NULL=NO;DELETED=NO;BACKGROUNDFETCH=NO;";
							con.Open();
						}
					}
					catch(Exception ex)
					{
						throw(new Exception("There was a problem loading the Microsoft dBase Driver.  If you are running a 64-bit OS, then you will need to set the Enable 32-bit Applications flag in IIS. " + ex.Message));
					}
					xml = ConvertDBaseToXml(stm, sImportModule.ToLower(), false, null);
					break;
				}
				case "act":
				{
					// 02/24/2010 Paul.  Test the dBase driver so that we can provide a good error message. 
					try
					{
						string sTempPath = Path.GetTempPath();
						using ( OdbcConnection con = new OdbcConnection() )
						{
							con.ConnectionString = @"Driver={Microsoft dBase Driver (*.dbf)};SourceType=DBF;SourceDB=" + sTempPath + ";Exclusive=No;Collate=Machine;NULL=NO;DELETED=NO;BACKGROUNDFETCH=NO;";
							con.Open();
						}
					}
					catch(Exception ex)
					{
						throw(new Exception("There was a problem loading the Microsoft dBase Driver.  If you are running a 64-bit OS, then you will need to set the Enable 32-bit Applications flag in IIS. " + ex.Message));
					}
					xml = ACTImport.ConvertActToXml(sImportModule, stm);
					break;
				}
				default:
				{
					// 08/21/2006 Paul.  Everything else is comma separated.  Convert to XML. 
					CsvDataReader spreadsheet = new CsvDataReader(stm, ',');
					if ( spreadsheet.Table != null )
					{
						xml = ConvertTableToXml(spreadsheet.Table, sImportModule.ToLower());
					}
					break;
				}
			}
			return xml;
		}
	}
}

