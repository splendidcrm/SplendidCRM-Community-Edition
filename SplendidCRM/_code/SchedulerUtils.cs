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
using System.Web;
using System.Text;
using System.Data;
using System.Data.Common;
using System.Globalization;
using System.Diagnostics;

namespace SplendidCRM
{
	public class SchedulerUtils
	{
		private static bool bInsideTimer = false;

		public static string[] Jobs = new string[]
			{ "pollMonitoredInboxes"
			, "runMassEmailCampaign"
			, "pruneDatabase"
			, "pollMonitoredInboxesForBouncedCampaignEmails"
			, "BackupDatabase"
			, "BackupTransactionLog"
			, "CleanSystemLog"
			, "CleanSystemSyncLog"
			, "CheckVersion"
			, "pollOutboundEmails"
			, "RunAllArchiveRules"    // 02/17/2018 Paul.  ModulesArchiveRules module to Professional. 
			, "RunExternalArchive"    // 04/10/2018 Paul.  Run External Archive. 
			};

		#region CronDescription
		/// <summary>
		/// CronDescription
		/// </summary>
		public static string CronDescription(L10N L10n, string sCRON)
		{
			StringBuilder sb = new StringBuilder();
			sCRON = sCRON.Replace(" ", "");
			if ( sCRON == "*::*::*::*::*" )
				return L10n.Term("Schedulers.LBL_OFTEN");
			// 01/28/2009 Paul.  Catch any processing errors during Cron processing. 
			try
			{
				CultureInfo culture = CultureInfo.CreateSpecificCulture(L10n.NAME);
				string sCRON_MONTH       = "*";
				string sCRON_DAYOFMONTH  = "*";
				string sCRON_DAYOFWEEK   = "*";
				string sCRON_HOUR        = "*";
				string sCRON_MINUTE      = "*";
				string[] arrCRON         = sCRON.Replace("::", "|").Split('|');
				string[] arrCRON_TEMP    = new string[] {};
				string[] arrCRON_VALUE   = new string[] {};
				string[] arrDaySuffixes  = new string[32];
				int    nCRON_VALUE       = 0;
				int    nCRON_VALUE_START = 0;
				int    nCRON_VALUE_END   = 0;
				int    nON_THE_MINUTE    = -1;
				for ( int n = 0; n < arrDaySuffixes.Length; n++ )
					arrDaySuffixes[n] = "th";
				arrDaySuffixes[0] = "";
				arrDaySuffixes[1] = "st";
				arrDaySuffixes[2] = "nd";
				arrDaySuffixes[3] = "rd";

				// minute  hour  dayOfMonth  month  dayOfWeek
				if ( arrCRON.Length > 0 ) sCRON_MINUTE     = arrCRON[0];
				if ( arrCRON.Length > 1 ) sCRON_HOUR       = arrCRON[1];
				if ( arrCRON.Length > 2 ) sCRON_DAYOFMONTH = arrCRON[2];
				if ( arrCRON.Length > 3 ) sCRON_MONTH      = arrCRON[3];
				if ( arrCRON.Length > 4 ) sCRON_DAYOFWEEK  = arrCRON[4];
				if ( sCRON_MINUTE != "*" )
				{
					arrCRON_TEMP = sCRON_MINUTE.Split(',');
					// 12/31/2007 Paul.  Check for either comma or dash. 
					if ( sCRON_MINUTE.Split(",-".ToCharArray()).Length == 1 )
					{
						nON_THE_MINUTE = Sql.ToInteger(sCRON_MINUTE);
						sb.Append(L10n.Term("Schedulers.LBL_ON_THE"));
						if ( nON_THE_MINUTE == 0 )
						{
							sb.Append(L10n.Term("Schedulers.LBL_HOUR_SING"));
						}
						else
						{
							sb.Append(nON_THE_MINUTE.ToString("00"));
							sb.Append(L10n.Term("Schedulers.LBL_MIN_MARK"));
						}
					}
					else
					{
						for ( int i = 0, nCronEntries = 0; i < arrCRON_TEMP.Length; i++ )
						{
							if ( arrCRON_TEMP[i].IndexOf('-') >= 0 )
							{
								arrCRON_VALUE = arrCRON_TEMP[i].Split('-');
								if ( arrCRON_VALUE.Length >= 2 )
								{
									nCRON_VALUE_START = Sql.ToInteger(arrCRON_VALUE[0]);
									nCRON_VALUE_END   = Sql.ToInteger(arrCRON_VALUE[1]);
									if ( nCRON_VALUE_START >= 0 && nCRON_VALUE_START <= 23 && nCRON_VALUE_END >= 0 && nCRON_VALUE_END <= 23 )
									{
										if ( nCronEntries > 0 )
											sb.Append(L10n.Term("Schedulers.LBL_AND"));
										sb.Append(L10n.Term("Schedulers.LBL_FROM"));
										sb.Append(L10n.Term("Schedulers.LBL_ON_THE"));
										if ( nCRON_VALUE_START == 0 )
										{
											sb.Append(L10n.Term("Schedulers.LBL_HOUR_SING"));
										}
										else
										{
											sb.Append(nCRON_VALUE_START.ToString("0"));
											sb.Append(L10n.Term("Schedulers.LBL_MIN_MARK"));
										}
										sb.Append(L10n.Term("Schedulers.LBL_RANGE"));
										sb.Append(L10n.Term("Schedulers.LBL_ON_THE"));
										sb.Append(nCRON_VALUE_END.ToString("0"));
										sb.Append(L10n.Term("Schedulers.LBL_MIN_MARK"));
										nCronEntries++;
									}
								}
							}
							else
							{
								nCRON_VALUE = Sql.ToInteger(arrCRON_TEMP[i]);
								if ( nCRON_VALUE >= 0 && nCRON_VALUE <= 23 )
								{
									if ( nCronEntries > 0 )
										sb.Append(L10n.Term("Schedulers.LBL_AND"));
									sb.Append(L10n.Term("Schedulers.LBL_ON_THE"));
									if ( nCRON_VALUE == 0 )
									{
										sb.Append(L10n.Term("Schedulers.LBL_HOUR_SING"));
									}
									else
									{
										sb.Append(nCRON_VALUE.ToString("0"));
										sb.Append(L10n.Term("Schedulers.LBL_MIN_MARK"));
									}
									nCronEntries++;
								}
							}
						}
					}
				}
				if ( sCRON_HOUR != "*" )
				{
					if ( sb.Length > 0 )
						sb.Append("; ");
					arrCRON_TEMP = sCRON_HOUR.Split(',');
					for ( int i = 0, nCronEntries = 0; i < arrCRON_TEMP.Length; i++ )
					{
						if ( arrCRON_TEMP[i].IndexOf('-') >= 0 )
						{
							arrCRON_VALUE = arrCRON_TEMP[i].Split('-');
							if ( arrCRON_VALUE.Length >= 2 )
							{
								nCRON_VALUE_START = Sql.ToInteger(arrCRON_VALUE[0]);
								nCRON_VALUE_END   = Sql.ToInteger(arrCRON_VALUE[1]);
								if ( nCRON_VALUE_START >= 1 && nCRON_VALUE_START <= 31 && nCRON_VALUE_END >= 1 && nCRON_VALUE_END <= 31 )
								{
									if ( nCronEntries > 0 )
										sb.Append(L10n.Term("Schedulers.LBL_AND"));
									sb.Append(L10n.Term("Schedulers.LBL_FROM"));
									sb.Append(arrCRON_VALUE[0]);
									if ( nON_THE_MINUTE >= 0 )
										sb.Append(":" + nON_THE_MINUTE.ToString("00"));
									sb.Append(L10n.Term("Schedulers.LBL_RANGE"));
									sb.Append(arrCRON_VALUE[1]);
									if ( nON_THE_MINUTE >= 0 )
										sb.Append(":" + nON_THE_MINUTE.ToString("00"));
									nCronEntries++;
								}
							}
						}
						else
						{
							nCRON_VALUE = Sql.ToInteger(arrCRON_TEMP[i]);
							if ( nCRON_VALUE >= 1 && nCRON_VALUE <= 31 )
							{
								if ( nCronEntries > 0 )
									sb.Append(L10n.Term("Schedulers.LBL_AND"));
								sb.Append(arrCRON_TEMP[i]);
								if ( nON_THE_MINUTE >= 0 )
									sb.Append(":" + nON_THE_MINUTE.ToString("00"));
								nCronEntries++;
							}
						}
					}
				}
				if ( sCRON_DAYOFMONTH != "*" )
				{
					if ( sb.Length > 0 )
						sb.Append("; ");
					arrCRON_TEMP = sCRON_DAYOFMONTH.Split(',');
					for ( int i = 0, nCronEntries = 0; i < arrCRON_TEMP.Length; i++ )
					{
						if ( arrCRON_TEMP[i].IndexOf('-') >= 0 )
						{
							arrCRON_VALUE = arrCRON_TEMP[i].Split('-');
							if ( arrCRON_VALUE.Length >= 2 )
							{
								nCRON_VALUE_START = Sql.ToInteger(arrCRON_VALUE[0]);
								nCRON_VALUE_END   = Sql.ToInteger(arrCRON_VALUE[1]);
								if ( nCRON_VALUE_START >= 1 && nCRON_VALUE_START <= 31 && nCRON_VALUE_END >= 1 && nCRON_VALUE_END <= 31 )
								{
									if ( nCronEntries > 0 )
										sb.Append(L10n.Term("Schedulers.LBL_AND"));
									sb.Append(L10n.Term("Schedulers.LBL_FROM"));
									sb.Append(nCRON_VALUE_START.ToString() + arrDaySuffixes[nCRON_VALUE_START]);
									sb.Append(L10n.Term("Schedulers.LBL_RANGE"));
									sb.Append(nCRON_VALUE_END.ToString() + arrDaySuffixes[nCRON_VALUE_END]);
									nCronEntries++;
								}
							}
						}
						else
						{
							nCRON_VALUE = Sql.ToInteger(arrCRON_TEMP[i]);
							if ( nCRON_VALUE >= 1 && nCRON_VALUE <= 31 )
							{
								if ( nCronEntries > 0 )
									sb.Append(L10n.Term("Schedulers.LBL_AND"));
								sb.Append(nCRON_VALUE.ToString() + arrDaySuffixes[nCRON_VALUE]);
								nCronEntries++;
							}
						}
					}
				}
				if ( sCRON_MONTH != "*" )
				{
					if ( sb.Length > 0 )
						sb.Append("; ");
					arrCRON_TEMP = sCRON_MONTH.Split(',');
					for ( int i = 0, nCronEntries = 0; i < arrCRON_TEMP.Length; i++ )
					{
						if ( arrCRON_TEMP[i].IndexOf('-') >= 0 )
						{
							arrCRON_VALUE = arrCRON_TEMP[i].Split('-');
							if ( arrCRON_VALUE.Length >= 2 )
							{
								nCRON_VALUE_START = Sql.ToInteger(arrCRON_VALUE[0]);
								nCRON_VALUE_END   = Sql.ToInteger(arrCRON_VALUE[1]);
								if ( nCRON_VALUE_START >= 1 && nCRON_VALUE_START <= 12 && nCRON_VALUE_END >= 1 && nCRON_VALUE_END <= 12 )
								{
									if ( nCronEntries > 0 )
										sb.Append(L10n.Term("Schedulers.LBL_AND"));
									sb.Append(L10n.Term("Schedulers.LBL_FROM"));
									sb.Append(culture.DateTimeFormat.MonthNames[nCRON_VALUE_START]);
									sb.Append(L10n.Term("Schedulers.LBL_RANGE"));
									sb.Append(culture.DateTimeFormat.MonthNames[nCRON_VALUE_END]);
									nCronEntries++;
								}
							}
						}
						else
						{
							nCRON_VALUE = Sql.ToInteger(arrCRON_TEMP[i]);
							if ( nCRON_VALUE >= 1 && nCRON_VALUE <= 12 )
							{
								if ( nCronEntries > 0 )
									sb.Append(L10n.Term("Schedulers.LBL_AND"));
								sb.Append(culture.DateTimeFormat.MonthNames[nCRON_VALUE]);
								nCronEntries++;
							}
						}
					}
				}
				if ( sCRON_DAYOFWEEK != "*" )
				{
					if ( sb.Length > 0 )
						sb.Append("; ");
					arrCRON_TEMP = sCRON_DAYOFWEEK.Split(',');
					for ( int i = 0, nCronEntries = 0; i < arrCRON_TEMP.Length; i++ )
					{
						if ( arrCRON_TEMP[i].IndexOf('-') >= 0 )
						{
							arrCRON_VALUE = arrCRON_TEMP[i].Split('-');
							if ( arrCRON_VALUE.Length >= 2 )
							{
								nCRON_VALUE_START = Sql.ToInteger(arrCRON_VALUE[0]);
								nCRON_VALUE_END   = Sql.ToInteger(arrCRON_VALUE[1]);
								if ( nCRON_VALUE_START >= 0 && nCRON_VALUE_START <= 6 && nCRON_VALUE_END >= 0 && nCRON_VALUE_END <= 6 )
								{
									if ( nCronEntries > 0 )
										sb.Append(L10n.Term("Schedulers.LBL_AND"));
									sb.Append(L10n.Term("Schedulers.LBL_FROM"));
									sb.Append(culture.DateTimeFormat.DayNames[nCRON_VALUE_START]);
									sb.Append(L10n.Term("Schedulers.LBL_RANGE"));
									sb.Append(culture.DateTimeFormat.DayNames[nCRON_VALUE_END]);
									nCronEntries++;
								}
							}
						}
						else
						{
							nCRON_VALUE = Sql.ToInteger(arrCRON_TEMP[i]);
							if ( nCRON_VALUE >= 0 && nCRON_VALUE <= 6 )
							{
								if ( nCronEntries > 0 )
									sb.Append(L10n.Term("Schedulers.LBL_AND"));
								sb.Append(culture.DateTimeFormat.DayNames[nCRON_VALUE]);
								nCronEntries++;
							}
						}
					}
				}
				return sb.ToString();
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				return "<font class=error>" + ex.Message + "</font>";
			}
		}
		#endregion

		// 10/27/2008 Paul.  Pass the context instead of the Application so that more information will be available to the error handling. 
		public static void RunJob(HttpContext Context, string sJOB)
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
			switch ( sJOB )
			{
				case "function::BackupDatabase":
				{
					// 01/28/2008 Paul.  Cannot perform a backup or restore operation within a transaction. BACKUP DATABASE is terminating abnormally.
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						try
						{
							string sFILENAME = String.Empty;
							string sTYPE     = "FULL";
							//SqlProcs.spSqlBackupDatabase(ref sNAME, "FULL", trn);
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandType = CommandType.StoredProcedure;
								cmd.CommandText = "spSqlBackupDatabase";
								// 02/09/2008 Paul.  A database backup can take a long time.  Don't timeout. 
								cmd.CommandTimeout = 0;
								IDbDataParameter parFILENAME = Sql.AddParameter(cmd, "@FILENAME", sFILENAME  , 255);
								IDbDataParameter parTYPE     = Sql.AddParameter(cmd, "@TYPE"    , sTYPE      ,  20);
								parFILENAME.Direction = ParameterDirection.InputOutput;
								cmd.ExecuteNonQuery();
								sFILENAME = Sql.ToString(parFILENAME.Value);
							}
							SplendidError.SystemMessage(Context, "Information", new StackTrace(true).GetFrame(0), "Database backup complete " + sFILENAME);
						}
						catch(Exception ex)
						{
							SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
						}
					}
					break;
				}
				case "function::BackupTransactionLog":
				{
					// 01/28/2008 Paul.  Cannot perform a backup or restore operation within a transaction. BACKUP DATABASE is terminating abnormally.
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						try
						{
							string sFILENAME = String.Empty;
							string sTYPE     = "LOG";
							//SqlProcs.spSqlBackupDatabase(ref sNAME, "LOG", trn);
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandType = CommandType.StoredProcedure;
								cmd.CommandText = "spSqlBackupDatabase";
								// 02/09/2008 Paul.  A database backup can take a long time.  Don't timeout. 
								cmd.CommandTimeout = 0;
								IDbDataParameter parFILENAME = Sql.AddParameter(cmd, "@FILENAME", sFILENAME  , 255);
								IDbDataParameter parTYPE     = Sql.AddParameter(cmd, "@TYPE"    , sTYPE      ,  20);
								parFILENAME.Direction = ParameterDirection.InputOutput;
								cmd.ExecuteNonQuery();
								sFILENAME = Sql.ToString(parFILENAME.Value);
							}
							SplendidError.SystemMessage(Context, "Information", new StackTrace(true).GetFrame(0), "Transaction Log backup complete " + sFILENAME);
						}
						catch(Exception ex)
						{
							SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
						}
					}
					break;
				}
				case "function::runMassEmailCampaign":
				{
					// 12/30/2007 Paul.  Update the last run date before running so that the date marks the start of the run. 
					EmailUtils.SendQueued(Context, Guid.Empty, Guid.Empty, false);
					break;
				}
				case "function::pruneDatabase"       :
				{
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
						using ( IDbTransaction trn = Sql.BeginTransaction(con) )
						{
							try
							{
								SqlProcs.spSqlPruneDatabase(trn);
								trn.Commit();
							}
							catch(Exception ex)
							{
								trn.Rollback();
								SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
							}
						}
					}
					break;
				}
				// 02/26/2010 Paul.  Allow system log to be cleaned. 
				case "function::CleanSystemLog"       :
				{
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						using ( IDbTransaction trn = Sql.BeginTransaction(con) )
						{
							try
							{
								// SqlProcs.spSYSTEM_LOG_Cleanup(trn);
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									// 02/26/2010 Paul.  If the database is very old, then the first cleanup can take a long time. 
									cmd.Transaction    = trn;
									cmd.CommandType    = CommandType.StoredProcedure;
									cmd.CommandText    = "spSYSTEM_LOG_Cleanup";
									cmd.CommandTimeout = 0;
									cmd.ExecuteNonQuery();
								}
								trn.Commit();
							}
							catch(Exception ex)
							{
								trn.Rollback();
								SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
							}
						}
						// 09/22/2010 Paul.  We need to cleanup the WORKFLOW_EVENTS table on the Community Edition. 
						using ( IDbTransaction trn = Sql.BeginTransaction(con) )
						{
							try
							{
								// SqlProcs.spWORKFLOW_EVENTS_ProcessAll(trn);
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.Transaction    = trn;
									cmd.CommandType    = CommandType.StoredProcedure;
									cmd.CommandText    = "spWORKFLOW_EVENTS_ProcessAll";
									cmd.CommandTimeout = 0;
									cmd.ExecuteNonQuery();
								}
								trn.Commit();
							}
							catch(Exception ex)
							{
								trn.Rollback();
								SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
							}
						}
					}
					break;
				}
				// 03/27/2010 Paul.  Allow system log to be cleaned. 
				case "function::CleanSystemSyncLog"   :
				{
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						using ( IDbTransaction trn = Sql.BeginTransaction(con) )
						{
							try
							{
								// SqlProcs.spSYSTEM_SYNC_LOG_Cleanup(trn);
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									// 02/26/2010 Paul.  If the database is very old, then the first cleanup can take a long time. 
									cmd.Transaction    = trn;
									cmd.CommandType    = CommandType.StoredProcedure;
									cmd.CommandText    = "spSYSTEM_SYNC_LOG_Cleanup";
									cmd.CommandTimeout = 0;
									cmd.ExecuteNonQuery();
								}
								trn.Commit();
							}
							catch(Exception ex)
							{
								trn.Rollback();
								SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
							}
						}
					}
					break;
				}
				case "function::pollMonitoredInboxes":
				{
					EmailUtils.CheckMonitored(Context, Guid.Empty);
					break;
				}
				case "function::pollMonitoredInboxesForBouncedCampaignEmails":
				{
					EmailUtils.CheckBounced(Context, Guid.Empty);
					break;
				}
				case "function::CheckVersion":
				{
					try
					{
						DataTable dtVersions = Utils.CheckVersion(Context.Application);

						DataView vwVersions = dtVersions.DefaultView;
						vwVersions.RowFilter = "New = '1'";
						if ( vwVersions.Count > 0 )
						{
							Context.Application["available_version"            ] = Sql.ToString(vwVersions[0]["Build"      ]);
							Context.Application["available_version_description"] = Sql.ToString(vwVersions[0]["Description"]);
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
					}
					break;
				}
				case "function::pollOutboundEmails":
				{
					// 05/15/2008 Paul.  Check for outbound emails. 
					EmailUtils.SendOutbound(Context);
					break;
				}
				case "function::OfflineClientSync":
				{
					Context.Application["SystemSync.LastBackgroundSync"] = DateTime.Now;
					// 05/22/2011 Paul.  We need to catch any exceptions as a failure in a thread will abort the entire session. 
					try
					{
						// 11/21/2009 Paul.  This is an Offline Client scheduled task. It cannot be configured on the server as the SCHEDULES table is not sync'd.
						SyncUtils.Retrieve(Context, false, false);
						SyncUtils.Sync    (Context, false, false);
						SyncUtils.Send    (Context);
					}
					catch(Exception ex)
					{
						SyncError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), ex);
					}
					break;
				}
				// 04/10/2018 Paul.  ModulesArchiveRules module to Professional. 
				case "function::RunAllArchiveRules":
				{
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						using ( IDbTransaction trn = Sql.BeginTransaction(con) )
						{
							try
							{
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.Transaction    = trn;
									cmd.CommandType    = CommandType.StoredProcedure;
									cmd.CommandText    = "spMODULES_ARCHIVE_RULES_RunAll";
									cmd.CommandTimeout = 0;
									cmd.ExecuteNonQuery();
								}
								trn.Commit();
							}
							catch(Exception ex)
							{
								trn.Rollback();
								SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
							}
						}
					}
					break;
				}
// 11/04/2021 Paul.  ArchiveExternalDB is not used in ReactOnlyUI. 
#if !ReactOnlyUI
				// 04/10/2018 Paul.  Run External Archive. 
				case "function::RunExternalArchive":
				{
					System.Threading.Thread t = new System.Threading.Thread(ArchiveExternalDB.RunArchive);
					t.Start(Context);
					break;
				}
#endif
			}
		}

		// 10/27/2008 Paul.  Pass the context instead of the Application so that more information will be available to the error handling. 
		public static void OnTimer(Object sender)
		{
			// 12/22/2007 Paul.  In case the timer takes a long time, only allow one timer event to be processed. 
			if ( !bInsideTimer )
			{
				bInsideTimer = true;
				HttpContext Context = sender as HttpContext;
				try
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sSQL ;
						DateTime dtLastUpdate = Sql.ToDateTime(Context.Application["SYSTEM_EVENTS.MaxDate"]);
						if ( dtLastUpdate == DateTime.MinValue )
						{
							dtLastUpdate = DateTime.Now;
							// 02/24/2009 Paul.  Update app variable so that we will know when the last update ran. 
							Context.Application["SYSTEM_EVENTS.MaxDate"] = dtLastUpdate;
						}
						
						// 08/20/2008 Paul.  We reload the system data if a system table or cached table changes. 
						// The primary reason we do this is to support a load-balanced system where changes 
						// on one server need to be replicated to the cache of the other servers. 
						sSQL = "select TABLE_NAME                  " + ControlChars.CrLf
						     + "  from vwSYSTEM_EVENTS             " + ControlChars.CrLf
						     + " where DATE_ENTERED > @DATE_ENTERED" + ControlChars.CrLf
						     + " group by TABLE_NAME               " + ControlChars.CrLf
						     + " order by TABLE_NAME               " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@DATE_ENTERED", dtLastUpdate);
							using ( DataTable dt = new DataTable() )
							{
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									da.Fill(dt);
									if ( dt.Rows.Count > 0 )
									{
										cmd.Parameters.Clear();
										sSQL = "select max(DATE_ENTERED)" + ControlChars.CrLf
										     + "  from vwSYSTEM_EVENTS  " + ControlChars.CrLf;
										cmd.CommandText = sSQL;
										dtLastUpdate = Sql.ToDateTime(cmd.ExecuteScalar());
										Context.Application["SYSTEM_EVENTS.MaxDate"] = dtLastUpdate;

										StringBuilder sbTables = new StringBuilder();
										foreach ( DataRow row in dt.Rows )
										{
											if ( sbTables.Length > 0 )
												sbTables.Append(", ");
											sbTables.Append(Sql.ToString(row["TABLE_NAME"]));
										}
										// 03/02/2009 Paul.  We must pass the context to the error handler. 
										SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "System Events: " + sbTables.ToString());
										SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "System Events Last Update on " + dtLastUpdate.ToString());

										foreach ( DataRow row in dt.Rows )
										{
											string sTABLE_NAME = Sql.ToString(row["TABLE_NAME"]);
											SplendidCache.ClearTable(sTABLE_NAME);
											// 10/26/2008 Paul.  IIS7 Integrated Pipeline does not allow HttpContext access inside Application_Start. 
											if ( sTABLE_NAME.StartsWith("TERMINOLOGY") )
												SplendidInit.InitTerminology(Context);
											else if ( sTABLE_NAME == "MODULES" || sTABLE_NAME.StartsWith("ACL_") )
												SplendidInit.InitModuleACL(Context);
											else if ( sTABLE_NAME == "CONFIG" )
												SplendidInit.InitConfig(Context);
											else if ( sTABLE_NAME == "TIMEZONES" )
												SplendidInit.InitTimeZones(Context);
											else if ( sTABLE_NAME == "CURRENCIES" )
												SplendidInit.InitCurrencies(Context);
										}
									}
								}
							}
						}
						// 10/13/2008 Paul.  Clear out old system events so that future queries are fast. 
						// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
						using ( IDbTransaction trn = Sql.BeginTransaction(con) )
						{
							try
							{
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.Transaction = trn;
									cmd.CommandType = CommandType.StoredProcedure;
									cmd.CommandText = "spSYSTEM_EVENTS_ProcessAll";
									cmd.ExecuteNonQuery();
								}
								trn.Commit();
							}
							catch(Exception ex)
							{
								trn.Rollback();
								SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
							}
						}
					}

					// 12/30/2007 Paul.  Workflow events always get processed. 
					// 07/26/2008 Paul.  Provide a way to disable workflow. 
					bool bEnableWorkflow = Sql.ToBoolean(Context.Application["CONFIG.enable_workflow"]);
					if ( bEnableWorkflow )
						WorkflowUtils.Process(Context);
					
					// 01/27/2009 Paul.  If multiple apps connect to the same database, make sure that only one is the job server. 
					// This is primarily for load-balanced sites. 
					int nSplendidJobServer = Sql.ToInteger(Context.Application["SplendidJobServer"]);
					if ( nSplendidJobServer == 0 )
					{
						string sSplendidJobServer = System.Configuration.ConfigurationManager.AppSettings["SplendidJobServer"];
						// 09/17/2009 Paul.  If we are running in Azure, then assume that this is the only instance. 
						string sMachineName = sSplendidJobServer;
						try
						{
							// 09/17/2009 Paul.  Azure does not support MachineName.  Just ignore the error. 
							sMachineName = System.Environment.MachineName;
						}
						catch
						{
						}
						if ( Sql.IsEmptyString(sSplendidJobServer) || String.Compare(sMachineName, sSplendidJobServer, true) == 0 )
						{
							nSplendidJobServer = 1;
							SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), sMachineName + " is a Splendid Job Server.");
						}
						else
						{
							nSplendidJobServer = -1;
							SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), sMachineName + " is not a Splendid Job Server.");
						}
						Context.Application["SplendidJobServer"] = nSplendidJobServer;
					}
					if ( nSplendidJobServer > 0 )
					{
						using ( DataTable dt = new DataTable() )
						{
							using ( IDbConnection con = dbf.CreateConnection() )
							{
								con.Open();
								string sSQL ;
								sSQL = "select *               " + ControlChars.CrLf
								     + "  from vwSCHEDULERS_Run" + ControlChars.CrLf
								     + " order by NEXT_RUN     " + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									// 01/01/2008 Paul.  The scheduler query should always be very fast. 
									// In the off chance that there is a problem, abort after 15 seconds. 
									cmd.CommandTimeout = 15;

									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										da.Fill(dt);
									}
								}
							}
							// 05/14/2009 Paul.  Provide a way to track scheduler events. 
							if ( !Sql.ToBoolean(Context.Application["CONFIG.suppress_scheduler_warning"]) )
							{
								SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "Scheduler Jobs to run: " + dt.Rows.Count.ToString() );
							}
							// 01/13/2008 Paul.  Loop outside the connection so that only one connection will be used. 
							foreach ( DataRow row in dt.Rows )
							{
								Guid     gID        = Sql.ToGuid    (row["ID"      ]);
								string   sJOB       = Sql.ToString  (row["JOB"     ]);
								// 01/31/2008 Paul.  Next run becomes last run. 
								DateTime dtLAST_RUN = Sql.ToDateTime(row["NEXT_RUN"]);
								try
								{
									// 01/29/2008 Paul.  Put jobs into separate function for easy access. 
									if ( !Sql.ToBoolean(Context.Application["CONFIG.suppress_scheduler_warning"]) )
									{
										SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "Scheduler Job: " + sJOB + " at " + dtLAST_RUN.ToString() );
									}
									RunJob(Context, sJOB);
								}
								finally
								{
									using ( IDbConnection con = dbf.CreateConnection() )
									{
										con.Open();
										// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
										using ( IDbTransaction trn = Sql.BeginTransaction(con) )
										{
											try
											{
												// 01/12/2008 Paul.  Make sure the Last Run value is updated after the operation.
												SqlProcs.spSCHEDULERS_UpdateLastRun(gID, dtLAST_RUN, trn);
												trn.Commit();
											}
											catch(Exception ex)
											{
												trn.Rollback();
												SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
											}
										}
									}
								}
							}
						}
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
				}
				finally
				{
					bInsideTimer = false;
				}
			}
		}
	}
}
