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
using System.Data;
using System.Data.Common;
using System.Collections.Generic;
using System.Text;
using System.Diagnostics;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for ArchiveExternalDB.
	/// </summary>
	public class ArchiveExternalDB
	{
		public static bool     bInsideArchive = false;
		public static DateTime dtLastBuild    = DateTime.MinValue;

		private static string TabSpace(int nNumber)
		{
			return Strings.Space(nNumber).Replace(' ', '\t');
		}

		private static string CsDataType(string sDATA_TYPE)
		{
			string sCOLUMN_TYPE = String.Empty;
			switch ( sDATA_TYPE )
			{
				case "tinyint"         :  sCOLUMN_TYPE = "short"     ;  break;
				case "smallint"        :  sCOLUMN_TYPE = "Int32"     ;  break;
				case "int"             :  sCOLUMN_TYPE = "Int64"     ;  break;
				case "bigint"          :  sCOLUMN_TYPE = "Int64"     ;  break;
				case "bit"             :  sCOLUMN_TYPE = "bool"      ;  break;
				case "float"           :  sCOLUMN_TYPE = "float"     ;  break;
				case "money"           :  sCOLUMN_TYPE = "decimal"   ;  break;
				case "decimal"         :  sCOLUMN_TYPE = "decimal"   ;  break;
				case "numeric"         :  sCOLUMN_TYPE = "decimal"   ;  break;
				case "datetime"        :  sCOLUMN_TYPE = "DateTime"  ;  break;
				// 01/26/2020 Paul.  A customer is using the "date" type. 
				case "date"            :  sCOLUMN_TYPE = "DateTime"  ;  break;
				// 04/13/2018 Paul.  A timestamp/RowVersion column cannot be migrated, so convert to varbinary(8). 
				case "timestamp"       :  sCOLUMN_TYPE = "byte[]"    ;  break;
				case "uniqueidentifier":  sCOLUMN_TYPE = "Guid"      ;  break;
				case "char"            :  sCOLUMN_TYPE = "ansistring";  break;
				case "nvarchar"        :  sCOLUMN_TYPE = "string"    ;  break;
				case "varbinary"       :  sCOLUMN_TYPE = "byte[]"    ;  break;
				case "varchar"         :  sCOLUMN_TYPE = "string"    ;  break;
			}
			return sCOLUMN_TYPE;
		}

		private static string SqlDataType(string sDATA_TYPE, string sCHARACTER_MAXIMUM_LENGTH, string sNUMERIC_PRECISION, string sNUMERIC_SCALE)
		{
			string sCOLUMN_TYPE = String.Empty;
			switch ( sDATA_TYPE )
			{
				case "tinyint"         :  sCOLUMN_TYPE = sDATA_TYPE;  break;
				case "smallint"        :  sCOLUMN_TYPE = sDATA_TYPE;  break;
				case "int"             :  sCOLUMN_TYPE = sDATA_TYPE;  break;
				case "bigint"          :  sCOLUMN_TYPE = sDATA_TYPE;  break;
				case "bit"             :  sCOLUMN_TYPE = sDATA_TYPE;  break;
				case "float"           :  sCOLUMN_TYPE = sDATA_TYPE;  break;
				case "money"           :  sCOLUMN_TYPE = sDATA_TYPE;  break;
				case "decimal"         :  sCOLUMN_TYPE = sDATA_TYPE + "(" + sNUMERIC_PRECISION + "," + sNUMERIC_SCALE + ")";  break;
				case "numeric"         :  sCOLUMN_TYPE = sDATA_TYPE + "(" + sNUMERIC_PRECISION + "," + sNUMERIC_SCALE + ")";  break;
				case "datetime"        :  sCOLUMN_TYPE = sDATA_TYPE;  break;
				// 01/26/2020 Paul.  A customer is using the "date" type. 
				case "date"            :  sCOLUMN_TYPE = sDATA_TYPE;  break;
				// 04/13/2018 Paul.  A timestamp/RowVersion column cannot be migrated, so convert to varbinary(8). 
				case "timestamp"       :  sCOLUMN_TYPE = "varbinary(8)";  break;
				case "uniqueidentifier":  sCOLUMN_TYPE = sDATA_TYPE;  break;
				case "char"            :  sCOLUMN_TYPE = sDATA_TYPE + "(" + sCHARACTER_MAXIMUM_LENGTH + ")";  break;
				case "nvarchar"        :  sCOLUMN_TYPE = sDATA_TYPE + "(" + (sCHARACTER_MAXIMUM_LENGTH == "-1" ? "max" : sCHARACTER_MAXIMUM_LENGTH) + ")";  break;
				case "varbinary"       :  sCOLUMN_TYPE = sDATA_TYPE + "(" + (sCHARACTER_MAXIMUM_LENGTH == "-1" ? "max" : sCHARACTER_MAXIMUM_LENGTH) + ")";  break;
				case "varchar"         :  sCOLUMN_TYPE = sDATA_TYPE + "(" + (sCHARACTER_MAXIMUM_LENGTH == "-1" ? "max" : sCHARACTER_MAXIMUM_LENGTH) + ")";  break;
			}
			return sCOLUMN_TYPE;
		}

		private static string BuildArchiveTable(HttpContext Context, string sTABLE_NAME)
		{
			sTABLE_NAME = sTABLE_NAME.ToUpper();
			int nCOLUMN_MAX_LENGTH = 0;
			string sARCHIVE_TABLE = sTABLE_NAME;
			string sARCHIVE_PK    = "PK_" + sTABLE_NAME;

			StringBuilder sb = new StringBuilder();
			DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				con.Open();
				bool bEXISTS = false;
				sSQL = "select count(*)                 " + ControlChars.CrLf
				     + "  from INFORMATION_SCHEMA.TABLES" + ControlChars.CrLf
				     + " where TABLE_NAME = @TABLE_NAME " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@TABLE_NAME", sTABLE_NAME);
					bEXISTS = Sql.ToBoolean(cmd.ExecuteScalar());
				}
				if ( bEXISTS )
				{
					sSQL = "select max(len(COLUMN_NAME)) + 1 " + ControlChars.CrLf
					     + "  from INFORMATION_SCHEMA.COLUMNS" + ControlChars.CrLf
					     + " where TABLE_NAME = @TABLE_NAME  " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@TABLE_NAME", sTABLE_NAME);
						nCOLUMN_MAX_LENGTH = Sql.ToInteger(cmd.ExecuteScalar());
						if ( nCOLUMN_MAX_LENGTH < 30 )
							nCOLUMN_MAX_LENGTH = 30;
					}
					
					using ( DataTable dt = new DataTable() )
					{
						sSQL = "select COLUMN_NAME               " + ControlChars.CrLf
						     + "     , DATA_TYPE                 " + ControlChars.CrLf
						     + "     , CHARACTER_MAXIMUM_LENGTH  " + ControlChars.CrLf
						     + "     , NUMERIC_PRECISION         " + ControlChars.CrLf
						     + "     , NUMERIC_SCALE             " + ControlChars.CrLf
						     + "  from INFORMATION_SCHEMA.COLUMNS" + ControlChars.CrLf
						     + " where TABLE_NAME = @TABLE_NAME  " + ControlChars.CrLf
						     + " order by ORDINAL_POSITION       " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@TABLE_NAME", sTABLE_NAME);
							using ( DbDataAdapter da = dbf.CreateDataAdapter() )
							{
								((IDbDataAdapter)da).SelectCommand = cmd;
								da.Fill(dt);
							}
						}
						DbProviderFactory dbfArchive = DbAcrhiveFactories.GetFactory(Context.Application);
						using ( IDbConnection conArchive = dbfArchive.CreateConnection() )
						{
							conArchive.Open();
							sSQL = "select count(*)                 " + ControlChars.CrLf
							     + "  from INFORMATION_SCHEMA.TABLES" + ControlChars.CrLf
							     + " where TABLE_NAME = @TABLE_NAME " + ControlChars.CrLf;
							using ( IDbCommand cmd = conArchive.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@TABLE_NAME", sARCHIVE_TABLE);
								bEXISTS = Sql.ToBoolean(cmd.ExecuteScalar());
							}
							
							if ( !bEXISTS )
							{
								sb.AppendLine("Create Table " + sARCHIVE_TABLE);
								for ( int i = 0; i < dt.Rows.Count; i++ )
								{
									DataRow row = dt.Rows[i];
									string sCOLUMN_NAME              = Sql.ToString(row["COLUMN_NAME"             ]);
									string sDATA_TYPE                = Sql.ToString(row["DATA_TYPE"               ]);
									string sCHARACTER_MAXIMUM_LENGTH = Sql.ToString(row["CHARACTER_MAXIMUM_LENGTH"]);
									string sNUMERIC_PRECISION        = Sql.ToString(row["NUMERIC_PRECISION"       ]);
									string sNUMERIC_SCALE            = Sql.ToString(row["NUMERIC_SCALE"           ]);
									string sCOLUMN_TYPE              = SqlDataType(sDATA_TYPE, sCHARACTER_MAXIMUM_LENGTH, sNUMERIC_PRECISION, sNUMERIC_SCALE);
									sb.Append(i == 0 ? "\t( " : "\t, ");
									if ( sTABLE_NAME.EndsWith("_AUDIT") && sCOLUMN_NAME == "AUDIT_ID" )
									{
										sb.Append(sCOLUMN_NAME + Strings.Space(nCOLUMN_MAX_LENGTH + 1 - sCOLUMN_NAME.Length) + sCOLUMN_TYPE + Strings.Space(18 - sCOLUMN_TYPE.Length) + " not null constraint " + sARCHIVE_PK + " primary key");
									}
									else if ( sTABLE_NAME.EndsWith("_STREAM") && sCOLUMN_NAME == "STREAM_ID" )
									{
										sb.Append(sCOLUMN_NAME + Strings.Space(nCOLUMN_MAX_LENGTH + 1 - sCOLUMN_NAME.Length) + sCOLUMN_TYPE + Strings.Space(18 - sCOLUMN_TYPE.Length) + " not null constraint " + sARCHIVE_PK + " primary key");
									}
									else if ( sTABLE_NAME.EndsWith("_CSTM") && sCOLUMN_NAME == "ID_C" )
									{
										sb.Append(sCOLUMN_NAME + Strings.Space(nCOLUMN_MAX_LENGTH + 1 - sCOLUMN_NAME.Length) + sCOLUMN_TYPE + Strings.Space(18 - sCOLUMN_TYPE.Length) + " not null constraint " + sARCHIVE_PK + " primary key");
									}
									else if ( sCOLUMN_NAME == "ID" && !sTABLE_NAME.EndsWith("_AUDIT") && !sTABLE_NAME.EndsWith("_STREAM") )
									{
										sb.Append(sCOLUMN_NAME + Strings.Space(nCOLUMN_MAX_LENGTH + 1 - sCOLUMN_NAME.Length) + sCOLUMN_TYPE + Strings.Space(18 - sCOLUMN_TYPE.Length) + " not null constraint " + sARCHIVE_PK + " primary key");
									}
									else
									{
										sb.Append(sCOLUMN_NAME + Strings.Space(nCOLUMN_MAX_LENGTH + 1 - sCOLUMN_NAME.Length) + sCOLUMN_TYPE + Strings.Space(18 - sCOLUMN_TYPE.Length) + " null");
									}
									sb.AppendLine();
								}
								sb.AppendLine("	);");
							}
							else
							{
								using ( DataTable dtArchive = new DataTable() )
								{
									sSQL = "select COLUMN_NAME               " + ControlChars.CrLf
									     + "     , DATA_TYPE                 " + ControlChars.CrLf
									     + "     , CHARACTER_MAXIMUM_LENGTH  " + ControlChars.CrLf
									     + "     , NUMERIC_PRECISION         " + ControlChars.CrLf
									     + "     , NUMERIC_SCALE             " + ControlChars.CrLf
									     + "  from INFORMATION_SCHEMA.COLUMNS" + ControlChars.CrLf
									     + " where TABLE_NAME = @TABLE_NAME  " + ControlChars.CrLf
									     + " order by ORDINAL_POSITION       " + ControlChars.CrLf;
									using ( IDbCommand cmd = conArchive.CreateCommand() )
									{
										cmd.CommandText = sSQL;
										Sql.AddParameter(cmd, "@TABLE_NAME", sARCHIVE_TABLE);
										using ( DbDataAdapter da = dbf.CreateDataAdapter() )
										{
											((IDbDataAdapter)da).SelectCommand = cmd;
											da.Fill(dtArchive);
											DataView vwArchive = new DataView(dtArchive);
											foreach ( DataRow row in dt.Rows )
											{
												string sCOLUMN_NAME              = Sql.ToString(row["COLUMN_NAME"             ]);
												string sDATA_TYPE                = Sql.ToString(row["DATA_TYPE"               ]);
												string sCHARACTER_MAXIMUM_LENGTH = Sql.ToString(row["CHARACTER_MAXIMUM_LENGTH"]);
												string sNUMERIC_PRECISION        = Sql.ToString(row["NUMERIC_PRECISION"       ]);
												string sNUMERIC_SCALE            = Sql.ToString(row["NUMERIC_SCALE"           ]);
												string sCOLUMN_TYPE              = SqlDataType(sDATA_TYPE, sCHARACTER_MAXIMUM_LENGTH, sNUMERIC_PRECISION, sNUMERIC_SCALE);
												vwArchive.RowFilter = "COLUMN_NAME = '" + sCOLUMN_NAME + "'";
												if ( vwArchive.Count == 0 )
												{
													sb.AppendLine("alter table " + sARCHIVE_TABLE + " add " + sCOLUMN_NAME + Strings.Space(nCOLUMN_MAX_LENGTH + 1 - sCOLUMN_NAME.Length) + sCOLUMN_TYPE + Strings.Space(18 - sCOLUMN_TYPE.Length) + " null;");
												}
												else
												{
													DataRowView rowArchive = vwArchive[0];
													sDATA_TYPE                = Sql.ToString(rowArchive["DATA_TYPE"               ]);
													sCHARACTER_MAXIMUM_LENGTH = Sql.ToString(rowArchive["CHARACTER_MAXIMUM_LENGTH"]);
													sNUMERIC_PRECISION        = Sql.ToString(rowArchive["NUMERIC_PRECISION"       ]);
													sNUMERIC_SCALE            = Sql.ToString(rowArchive["NUMERIC_SCALE"           ]);
													string sARCHIVE_TYPE      = SqlDataType(sDATA_TYPE, sCHARACTER_MAXIMUM_LENGTH, sNUMERIC_PRECISION, sNUMERIC_SCALE);
													if ( sARCHIVE_TYPE !=  sCOLUMN_TYPE )
													{
														sb.AppendLine("alter table " + sARCHIVE_TABLE + " alter column " + sCOLUMN_NAME + Strings.Space(nCOLUMN_MAX_LENGTH + 1 - sCOLUMN_NAME.Length) + " " + sCOLUMN_TYPE + Strings.Space(18 - sCOLUMN_TYPE.Length) + " null;");
													}
												}
											}
										}
									}
								}
							}
							if ( sb.Length > 0 )
							{
								// 04/09/2018 Paul.  Create or update the table. 
								using ( IDbCommand cmd = conArchive.CreateCommand() )
								{
									cmd.CommandText = sb.ToString();
									cmd.CommandTimeout = 0;
									cmd.ExecuteNonQuery();
								}
							}
						}
					}
				}
			}
			sb.Append(SqlBuildArchiveIndexes(Context, sTABLE_NAME));
			if ( sb.Length > 0 )
				sb.AppendLine();
			return sb.ToString();
		}

		private static string SqlBuildArchiveIndexes(HttpContext Context, string sTABLE_NAME)
		{
			StringBuilder sb = new StringBuilder();
			DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				int nINDEX_MAX_LENGTH = 0;
				sSQL = "select max(len(name)) + 1                           " + ControlChars.CrLf
				     + "  from sys.indexes                                  " + ControlChars.CrLf
				     + " where object_id            = object_id(@TABLE_NAME)" + ControlChars.CrLf
				     + "   and type                 > 0                     " + ControlChars.CrLf
				     + "   and is_primary_key       = 0                     " + ControlChars.CrLf
				     + "   and is_unique_constraint = 0                     " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@TABLE_NAME", sTABLE_NAME);
					nINDEX_MAX_LENGTH = Sql.ToInteger(cmd.ExecuteScalar());
					if ( nINDEX_MAX_LENGTH < 30 )
						nINDEX_MAX_LENGTH = 30;
				}
				using ( DataTable dtIndexes = new DataTable() )
				{
					sSQL = "select object_id                                    " + ControlChars.CrLf
					     + "     , name                                         " + ControlChars.CrLf
					     + "  from sys.indexes                                  " + ControlChars.CrLf
					     + " where object_id            = object_id(@TABLE_NAME)" + ControlChars.CrLf
					     + "   and type                 > 0                     " + ControlChars.CrLf
					     + "   and is_primary_key       = 0                     " + ControlChars.CrLf
					     + "   and is_unique_constraint = 0                     " + ControlChars.CrLf
					     + " order by name                                      " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
							Sql.AddParameter(cmd, "@TABLE_NAME", sTABLE_NAME);
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dtIndexes);
						}
					}
					foreach ( DataRow rowIndex in dtIndexes.Rows )
					{
						string sOBJECT_ID    = Sql.ToString(rowIndex["object_id"]);
						string sINDEX_NAME   = Sql.ToString(rowIndex["name"     ]);
						bool   bINDEX_EXISTS = false;
						DbProviderFactory dbfArchive = DbAcrhiveFactories.GetFactory(Context.Application);
						using ( IDbConnection conArchive = dbfArchive.CreateConnection() )
						{
							conArchive.Open();
							sSQL = "select count(*)          " + ControlChars.CrLf
							     + "  from sys.indexes       " + ControlChars.CrLf
							     + " where name = @INDEX_NAME" + ControlChars.CrLf;
							using ( IDbCommand cmd = conArchive.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@INDEX_NAME", sINDEX_NAME);
								bINDEX_EXISTS = Sql.ToBoolean(cmd.ExecuteScalar());
							}
							if ( !bINDEX_EXISTS )
							{
								StringBuilder sbIndexColumns  = new StringBuilder();
								StringBuilder sbIncludeColumns = new StringBuilder();
								sSQL = "select col.name                              " + ControlChars.CrLf
								     + "     , ixc.is_descending_key                 " + ControlChars.CrLf
								     + "     , ixc.is_included_column                " + ControlChars.CrLf
								     + "  from      sys.indexes         ix           " + ControlChars.CrLf
								     + " inner join sys.index_columns   ixc          " + ControlChars.CrLf
								     + "         on ixc.object_id     = ix.object_id " + ControlChars.CrLf
								     + "        and ixc.index_id      = ix.index_id  " + ControlChars.CrLf
								     + " inner join sys.columns         col          " + ControlChars.CrLf
								     + "         on col.object_id     = ixc.object_id" + ControlChars.CrLf
								     + "        and col.column_id     = ixc.column_id" + ControlChars.CrLf
								     + " where ix.type                 > 0           " + ControlChars.CrLf
								     + "   and ix.is_primary_key       = 0           " + ControlChars.CrLf
								     + "   and ix.is_unique_constraint = 0           " + ControlChars.CrLf
								     + "   and ix.object_id            = @OBJECT_ID  " + ControlChars.CrLf
								     + "   and ix.name                 = @INDEX_NAME " + ControlChars.CrLf
								     + "   and ix.name                 like 'IDX_%'  " + ControlChars.CrLf
								     + " order by ixc.index_column_id                " + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@OBJECT_ID" , sOBJECT_ID);
									Sql.AddParameter(cmd, "@INDEX_NAME", sINDEX_NAME);
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										using ( DataTable dtColumns = new DataTable() )
										{
											da.Fill(dtColumns);
											foreach ( DataRow rowColumn in dtColumns.Rows )
											{
												string sCOLUMN_NAME        = Sql.ToString (rowColumn["name"              ]);
												bool   bIS_DESCENDING_KEY  = Sql.ToBoolean(rowColumn["is_descending_key" ]);
												bool   bIS_INCLUDED_COLUMN = Sql.ToBoolean(rowColumn["is_included_column"]);
												if ( !bIS_INCLUDED_COLUMN )
												{
													if ( sbIndexColumns.Length > 0 )
														sbIndexColumns.Append(", ");
													sbIndexColumns.Append(sCOLUMN_NAME);
													if ( bIS_DESCENDING_KEY )
													{
														sbIndexColumns.Append(" desc");
													}
												}
												else
												{
													if ( sbIncludeColumns.Length > 0 )
														sbIncludeColumns.Append(", ");
													sbIncludeColumns.Append(sCOLUMN_NAME);
												}
											}
										}
									}
								}
								if ( sbIndexColumns.Length > 0 )
								{
									string sCreateIndexSQL = "Create Index " + sINDEX_NAME + Strings.Space(nINDEX_MAX_LENGTH - sINDEX_NAME.Length) + " on " + sTABLE_NAME + " (" + sbIndexColumns.ToString() + ")";
									if ( sbIncludeColumns.Length > 0 )
										sCreateIndexSQL += " include (" + sbIncludeColumns.ToString() + ")";
									sb.AppendLine(sCreateIndexSQL + ";");
									// 04/09/2018 Paul.  Create the index. 
									using ( IDbCommand cmd = conArchive.CreateCommand() )
									{
										cmd.CommandText = sCreateIndexSQL;
										cmd.CommandTimeout = 0;
										cmd.ExecuteNonQuery();
									}
								}
							}
						}
					}
				}
			}
			return sb.ToString();
		}

		private static string ArchiveBuildAll(HttpContext Context)
		{
			StringBuilder sb = new StringBuilder();
			DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				sSQL = "select distinct MODULES.TABLE_NAME                                      " + ControlChars.CrLf
				     + "  from      MODULES_ARCHIVE_RELATED                                     " + ControlChars.CrLf
				     + " inner join MODULES                                                     " + ControlChars.CrLf
				     + "         on MODULES.MODULE_NAME    = MODULES_ARCHIVE_RELATED.MODULE_NAME" + ControlChars.CrLf
				     + "        and MODULES.MODULE_ENABLED = 1                                  " + ControlChars.CrLf
				     + "        and MODULES.DELETED        = 0                                  " + ControlChars.CrLf
				     + " where MODULES_ARCHIVE_RELATED.DELETED = 0                              " + ControlChars.CrLf
				     + "   and MODULES.TABLE_NAME is not null                                   " + ControlChars.CrLf
				     + " order by MODULES.TABLE_NAME                                            " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						using ( DataTable dt = new DataTable() )
						{
							da.Fill(dt);
							foreach ( DataRow row in dt.Rows )
							{
								string sTABLE_NAME   = Sql.ToString(row["TABLE_NAME"]);
								string sCUSTOM_TABLE = sTABLE_NAME   + "_CSTM"   ;
								string sAUDIT_TABLE  = sTABLE_NAME   + "_AUDIT"  ;
								string sCUSTOM_AUDIT = sCUSTOM_TABLE + "_AUDIT"  ;
								sb.Append(BuildArchiveTable(Context, sTABLE_NAME  ));
								sb.Append(BuildArchiveTable(Context, sCUSTOM_TABLE));
								sb.Append(BuildArchiveTable(Context, sAUDIT_TABLE ));
								sb.Append(BuildArchiveTable(Context, sCUSTOM_AUDIT));
								if ( sTABLE_NAME == "QUOTES" )
								{
									sTABLE_NAME   = "QUOTES_LINE_ITEMS";
									sCUSTOM_TABLE = sTABLE_NAME   + "_CSTM"   ;
									sAUDIT_TABLE  = sTABLE_NAME   + "_AUDIT"  ;
									sCUSTOM_AUDIT = sCUSTOM_TABLE + "_AUDIT"  ;
									sb.Append(BuildArchiveTable(Context, sTABLE_NAME ));
									sb.Append(BuildArchiveTable(Context, sCUSTOM_TABLE));
									sb.Append(BuildArchiveTable(Context, sAUDIT_TABLE ));
									sb.Append(BuildArchiveTable(Context, sCUSTOM_AUDIT));
								}
								else if ( sTABLE_NAME == "ORDERS" )
								{
									sTABLE_NAME   = "ORDERS_LINE_ITEMS";
									sCUSTOM_TABLE = sTABLE_NAME   + "_CSTM"   ;
									sAUDIT_TABLE  = sTABLE_NAME   + "_AUDIT"  ;
									sCUSTOM_AUDIT = sCUSTOM_TABLE + "_AUDIT"  ;
									sb.Append(BuildArchiveTable(Context, sTABLE_NAME  ));
									sb.Append(BuildArchiveTable(Context, sCUSTOM_TABLE));
									sb.Append(BuildArchiveTable(Context, sAUDIT_TABLE ));
									sb.Append(BuildArchiveTable(Context, sCUSTOM_AUDIT));
								}
								else if ( sTABLE_NAME == "INVOICES" )
								{
									sTABLE_NAME   = "INVOICES_LINE_ITEMS";
									sCUSTOM_TABLE = sTABLE_NAME   + "_CSTM"   ;
									sAUDIT_TABLE  = sTABLE_NAME   + "_AUDIT"  ;
									sCUSTOM_AUDIT = sCUSTOM_TABLE + "_AUDIT"  ;
									sb.Append(BuildArchiveTable(Context, sTABLE_NAME  ));
									sb.Append(BuildArchiveTable(Context, sCUSTOM_TABLE));
									sb.Append(BuildArchiveTable(Context, sAUDIT_TABLE ));
									sb.Append(BuildArchiveTable(Context, sCUSTOM_AUDIT));
								}
								else if ( sTABLE_NAME == "OPPORTUNITIES" )
								{
									sTABLE_NAME   = "REVENUE_LINE_ITEMS";
									sCUSTOM_TABLE = sTABLE_NAME   + "_CSTM"   ;
									sAUDIT_TABLE  = sTABLE_NAME   + "_AUDIT"  ;
									sCUSTOM_AUDIT = sCUSTOM_TABLE + "_AUDIT"  ;
									sb.Append(BuildArchiveTable(Context, sTABLE_NAME  ));
									sb.Append(BuildArchiveTable(Context, sCUSTOM_TABLE));
									sb.Append(BuildArchiveTable(Context, sAUDIT_TABLE ));
									sb.Append(BuildArchiveTable(Context, sCUSTOM_AUDIT));
								}
								else if ( sTABLE_NAME == "PROJECT" )
								{
									sTABLE_NAME   = "PROJECT_TASK";
									sCUSTOM_TABLE = sTABLE_NAME   + "_CSTM"   ;
									sAUDIT_TABLE  = sTABLE_NAME   + "_AUDIT"  ;
									sCUSTOM_AUDIT = sCUSTOM_TABLE + "_AUDIT"  ;
									sb.Append(BuildArchiveTable(Context, sTABLE_NAME  ));
									sb.Append(BuildArchiveTable(Context, sCUSTOM_TABLE));
									sb.Append(BuildArchiveTable(Context, sAUDIT_TABLE ));
									sb.Append(BuildArchiveTable(Context, sCUSTOM_AUDIT));
								}
								else if ( sTABLE_NAME == "DOCUMENTS" )
								{
									sTABLE_NAME   = "DOCUMENT_REVISIONS";
									sCUSTOM_TABLE = sTABLE_NAME   + "_CSTM"   ;
									sAUDIT_TABLE  = sTABLE_NAME   + "_AUDIT"  ;
									sCUSTOM_AUDIT = sCUSTOM_TABLE + "_AUDIT"  ;
									sb.Append(BuildArchiveTable(Context, sTABLE_NAME  ));
									sb.Append(BuildArchiveTable(Context, sCUSTOM_TABLE));
									sb.Append(BuildArchiveTable(Context, sAUDIT_TABLE ));
									sb.Append(BuildArchiveTable(Context, sCUSTOM_AUDIT));
								}
							}
							foreach ( DataRow row in dt.Rows )
							{
								string sTABLE_NAME = Sql.ToString(row["TABLE_NAME"]);
								// 04/08/2018 Paul.  Don't need to include CSTM and SYNC will not be moved. 
								// 04/09/2018 Paul.  Looking for singular name (like ACCOUNT_ID) will skip CSTM and SYNC tables. 
								// 07/10/2018 Paul.  We will not be archiving archive tables. 
								sSQL = "select COLUMNS.TABLE_NAME                         " + ControlChars.CrLf
								     + "  from      INFORMATION_SCHEMA.COLUMNS  COLUMNS   " + ControlChars.CrLf
								     + " inner join INFORMATION_SCHEMA.TABLES   TABLES    " + ControlChars.CrLf
								     + "         on TABLES.TABLE_NAME = COLUMNS.TABLE_NAME" + ControlChars.CrLf
								     + "        and TABLES.TABLE_TYPE = 'BASE TABLE'      " + ControlChars.CrLf
								     + " where COLUMNS.COLUMN_NAME = @COLUMN_NAME         " + ControlChars.CrLf
								     + "   and COLUMNS.TABLE_NAME not in (select TABLE_NAME              from vwMODULES where TABLE_NAME is not null)" + ControlChars.CrLf
								     + "   and COLUMNS.TABLE_NAME not in (select TABLE_NAME + '_AUDIT'   from vwMODULES where TABLE_NAME is not null)" + ControlChars.CrLf
								     + "   and COLUMNS.TABLE_NAME not in (select TABLE_NAME + '_ARCHIVE' from vwMODULES where TABLE_NAME is not null)" + ControlChars.CrLf
								     + " order by COLUMNS.TABLE_NAME                      " + ControlChars.CrLf;
								using ( IDbCommand cmdRelated = con.CreateCommand() )
								{
									cmdRelated.CommandText = sSQL;
									Sql.AddParameter(cmdRelated, "@COLUMN_NAME", Crm.Modules.SingularTableName(sTABLE_NAME) + "_ID");
									((IDbDataAdapter)da).SelectCommand = cmdRelated;
									using ( DataTable dtRelated = new DataTable() )
									{
										da.Fill(dtRelated);
										foreach ( DataRow rowRelated in dtRelated.Rows )
										{
											string sRELATED_NAME = Sql.ToString(rowRelated["TABLE_NAME"]);
											sb.Append(BuildArchiveTable(Context, sRELATED_NAME));
										}
									}
								}
							}
						}
					}
				}
				sSQL = "select RELATED_TABLE             " + ControlChars.CrLf
				     + "  from vwMODULES_ARCHIVE_RELATED " + ControlChars.CrLf
				     + " where MODULE_NAME = 'Activities'" + ControlChars.CrLf
				     + " order by RELATED_ORDER          " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						using ( DataTable dt = new DataTable() )
						{
							da.Fill(dt);
							foreach ( DataRow row in dt.Rows )
							{
								string sTABLE_NAME   = Sql.ToString(row["RELATED_TABLE"]);
								string sCUSTOM_TABLE = sTABLE_NAME   + "_CSTM"   ;
								string sAUDIT_TABLE  = sTABLE_NAME   + "_AUDIT"  ;
								string sCUSTOM_AUDIT = sCUSTOM_TABLE + "_AUDIT"  ;
								sb.Append(BuildArchiveTable(Context, sTABLE_NAME  ));
								sb.Append(BuildArchiveTable(Context, sCUSTOM_TABLE));
								sb.Append(BuildArchiveTable(Context, sAUDIT_TABLE ));
								sb.Append(BuildArchiveTable(Context, sCUSTOM_AUDIT));
								if ( sTABLE_NAME == "NOTES" )
								{
									sTABLE_NAME   = "NOTE_ATTACHMENTS";
									sAUDIT_TABLE  = sTABLE_NAME + "_AUDIT";
									sb.Append(BuildArchiveTable(Context, sTABLE_NAME  ));
									sb.Append(BuildArchiveTable(Context, sAUDIT_TABLE ));
								}
								else if ( sTABLE_NAME == "EMAILS" )
								{
									sTABLE_NAME   = "EMAIL_IMAGES";
									sAUDIT_TABLE  = sTABLE_NAME + "_AUDIT";
									sb.Append(BuildArchiveTable(Context, sTABLE_NAME  ));
									sb.Append(BuildArchiveTable(Context, sAUDIT_TABLE ));
								}
							}
						}
					}
				}
			}
			return sb.ToString();
		}

		private static string BuildInsertProcedures(HttpContext Context, string sTABLE_NAME, ref IDbCommand cmdPrimaryInsert, ref IDbCommand cmdCustomInsert)
		{
			sTABLE_NAME = sTABLE_NAME.ToUpper();
			string sCUSTOM_TABLE   = sTABLE_NAME  + "_CSTM";
			if ( sTABLE_NAME.EndsWith("_AUDIT") )
				sCUSTOM_TABLE   = sTABLE_NAME.Replace("_AUDIT", "_CSTM_AUDIT");
			string sARCHIVE_TABLE  = sTABLE_NAME  ;
			string sARCHIVE_CUSTOM = sCUSTOM_TABLE;
			
			cmdPrimaryInsert = null;
			cmdCustomInsert  = null;
			int nPRIMARY_EXISTS = 0;
			int nCUSTOM_EXISTS  = 0;
			List<string> lstPrimaryFields = new List<string>();
			List<string> lstCustomFields  = new List<string>();
			StringBuilder sb = new StringBuilder();
			DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				con.Open();
				using ( DataTable dtPrimary = new DataTable() )
				{
					sSQL = "select count(*)                 " + ControlChars.CrLf
					     + "  from INFORMATION_SCHEMA.TABLES" + ControlChars.CrLf
					     + " where TABLE_NAME = @TABLE_NAME " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						cmd.CommandTimeout = 0;
						Sql.AddParameter(cmd, "@TABLE_NAME", sTABLE_NAME);
						nPRIMARY_EXISTS += Sql.ToInteger(cmd.ExecuteScalar());
					}
					sSQL = "select COLUMN_NAME               " + ControlChars.CrLf
					     + "     , DATA_TYPE                 " + ControlChars.CrLf
					     + "     , CHARACTER_MAXIMUM_LENGTH  " + ControlChars.CrLf
					     + "     , NUMERIC_PRECISION         " + ControlChars.CrLf
					     + "     , NUMERIC_SCALE             " + ControlChars.CrLf
					     + "  from INFORMATION_SCHEMA.COLUMNS" + ControlChars.CrLf
					     + " where TABLE_NAME = @TABLE_NAME  " + ControlChars.CrLf
					     + " order by ORDINAL_POSITION       " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						cmd.CommandTimeout = 0;
						Sql.AddParameter(cmd, "@TABLE_NAME", sTABLE_NAME);
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							da.Fill(dtPrimary);
						}
					}
					sSQL = "select count(*)                 " + ControlChars.CrLf
					     + "  from INFORMATION_SCHEMA.TABLES" + ControlChars.CrLf
					     + " where TABLE_NAME = @TABLE_NAME " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						cmd.CommandTimeout = 0;
						Sql.AddParameter(cmd, "@TABLE_NAME", sCUSTOM_TABLE);
						nCUSTOM_EXISTS += Sql.ToInteger(cmd.ExecuteScalar());
					}
					DbProviderFactory dbfArchive = DbAcrhiveFactories.GetFactory(Context.Application);
					using ( IDbConnection conArchive = dbfArchive.CreateConnection() )
					{
						conArchive.Open();
						using ( DataTable dtPrimaryArchive = new DataTable() )
						{
							sSQL = "select count(*)                 " + ControlChars.CrLf
							     + "  from INFORMATION_SCHEMA.TABLES" + ControlChars.CrLf
							     + " where TABLE_NAME = @TABLE_NAME " + ControlChars.CrLf;
							using ( IDbCommand cmd = conArchive.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								cmd.CommandTimeout = 0;
								Sql.AddParameter(cmd, "@TABLE_NAME", sARCHIVE_TABLE);
								nPRIMARY_EXISTS += Sql.ToInteger(cmd.ExecuteScalar());
							}
							sSQL = "select COLUMN_NAME               " + ControlChars.CrLf
							     + "     , DATA_TYPE                 " + ControlChars.CrLf
							     + "     , CHARACTER_MAXIMUM_LENGTH  " + ControlChars.CrLf
							     + "     , NUMERIC_PRECISION         " + ControlChars.CrLf
							     + "     , NUMERIC_SCALE             " + ControlChars.CrLf
							     + "  from INFORMATION_SCHEMA.COLUMNS" + ControlChars.CrLf
							     + " where TABLE_NAME = @TABLE_NAME  " + ControlChars.CrLf
							     + " order by ORDINAL_POSITION       " + ControlChars.CrLf;
							using ( IDbCommand cmd = conArchive.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								cmd.CommandTimeout = 0;
								Sql.AddParameter(cmd, "@TABLE_NAME", sARCHIVE_TABLE);
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									da.Fill(dtPrimaryArchive);
									DataView vwArchive = new DataView(dtPrimaryArchive);
									foreach ( DataRow row in dtPrimary.Rows )
									{
										string sCOLUMN_NAME = Sql.ToString(row["COLUMN_NAME"]);
										vwArchive.RowFilter = "COLUMN_NAME = '" + sCOLUMN_NAME + "'";
										if ( vwArchive.Count > 0 )
										{
											lstPrimaryFields.Add(sCOLUMN_NAME);
										}
									}
								}
							}
							sSQL = "select count(*)                 " + ControlChars.CrLf
							     + "  from INFORMATION_SCHEMA.TABLES" + ControlChars.CrLf
							     + " where TABLE_NAME = @TABLE_NAME " + ControlChars.CrLf;
							using ( IDbCommand cmd = conArchive.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								cmd.CommandTimeout = 0;
								Sql.AddParameter(cmd, "@TABLE_NAME", sARCHIVE_CUSTOM);
								nCUSTOM_EXISTS += Sql.ToInteger(cmd.ExecuteScalar());
							}
						}
						if ( nPRIMARY_EXISTS == 2 )
						{
							cmdPrimaryInsert = dbfArchive.CreateCommand();
							cmdPrimaryInsert.CommandType = CommandType.Text;
							// 12/06/2019 Paul.  The archive database may be slow, so don't timeout. 
							cmdPrimaryInsert.CommandTimeout = 0;
							
							StringBuilder sbPrimaryInsert = new StringBuilder();
							sbPrimaryInsert.AppendLine("insert into " + sARCHIVE_TABLE);
							int nFieldIndex = 0;
							foreach ( DataRow row in dtPrimary.Rows )
							{
								string sCOLUMN_NAME = Sql.ToString(row["COLUMN_NAME"]);
								if ( lstPrimaryFields.Contains(sCOLUMN_NAME) )
								{
									sbPrimaryInsert.Append("\t");
									sbPrimaryInsert.Append(nFieldIndex == 0 ? "(" : ",");
									sbPrimaryInsert.AppendLine(" " + sCOLUMN_NAME);
									nFieldIndex++;
								}
							}
							sbPrimaryInsert.AppendLine("\t)");
							sbPrimaryInsert.AppendLine("values");
							nFieldIndex = 0;
							foreach ( DataRow row in dtPrimary.Rows )
							{
								string sCOLUMN_NAME              = Sql.ToString (row["COLUMN_NAME"             ]);
								string sDATA_TYPE                = Sql.ToString (row["DATA_TYPE"               ]);
								int    nCHARACTER_MAXIMUM_LENGTH = Sql.ToInteger(row["CHARACTER_MAXIMUM_LENGTH"]);
								if ( lstPrimaryFields.Contains(sCOLUMN_NAME) )
								{
									sbPrimaryInsert.Append("\t");
									sbPrimaryInsert.Append(nFieldIndex == 0 ? "(" : ",");
									sbPrimaryInsert.AppendLine(" @" + sCOLUMN_NAME);
									if ( nCHARACTER_MAXIMUM_LENGTH == -1 )
										nCHARACTER_MAXIMUM_LENGTH = 104857600;
									Sql.CreateParameter(cmdPrimaryInsert, "@" + sCOLUMN_NAME, CsDataType(sDATA_TYPE), nCHARACTER_MAXIMUM_LENGTH);
									nFieldIndex++;
								}
							}
							sbPrimaryInsert.AppendLine("\t);");
							cmdPrimaryInsert.CommandText = sbPrimaryInsert.ToString();
							sb.Append(cmdPrimaryInsert.CommandText);
							if ( nCUSTOM_EXISTS == 2 )
							{
								cmdCustomInsert = dbfArchive.CreateCommand();
								cmdCustomInsert.CommandType = CommandType.Text;
								// 12/06/2019 Paul.  The archive database may be slow, so don't timeout. 
								cmdCustomInsert.CommandTimeout = 0;
								using ( DataTable dtCustom = new DataTable() )
								{
									sSQL = "select COLUMN_NAME               " + ControlChars.CrLf
									     + "     , DATA_TYPE                 " + ControlChars.CrLf
									     + "     , CHARACTER_MAXIMUM_LENGTH  " + ControlChars.CrLf
									     + "     , NUMERIC_PRECISION         " + ControlChars.CrLf
									     + "     , NUMERIC_SCALE             " + ControlChars.CrLf
									     + "  from INFORMATION_SCHEMA.COLUMNS" + ControlChars.CrLf
									     + " where TABLE_NAME = @TABLE_NAME  " + ControlChars.CrLf
									     + " order by ORDINAL_POSITION       " + ControlChars.CrLf;
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.CommandText = sSQL;
										cmd.CommandTimeout = 0;
										Sql.AddParameter(cmd, "@TABLE_NAME", sCUSTOM_TABLE);
										using ( DbDataAdapter da = dbf.CreateDataAdapter() )
										{
											((IDbDataAdapter)da).SelectCommand = cmd;
											da.Fill(dtCustom);
										}
									}
									using ( DataTable dtCustomArchive = new DataTable() )
									{
										sSQL = "select COLUMN_NAME               " + ControlChars.CrLf
										     + "     , DATA_TYPE                 " + ControlChars.CrLf
										     + "     , CHARACTER_MAXIMUM_LENGTH  " + ControlChars.CrLf
										     + "     , NUMERIC_PRECISION         " + ControlChars.CrLf
										     + "     , NUMERIC_SCALE             " + ControlChars.CrLf
										     + "  from INFORMATION_SCHEMA.COLUMNS" + ControlChars.CrLf
										     + " where TABLE_NAME = @TABLE_NAME  " + ControlChars.CrLf
										     + " order by ORDINAL_POSITION       " + ControlChars.CrLf;
										using ( IDbCommand cmd = conArchive.CreateCommand() )
										{
											cmd.CommandText = sSQL;
											cmd.CommandTimeout = 0;
											Sql.AddParameter(cmd, "@TABLE_NAME", sARCHIVE_CUSTOM);
											using ( DbDataAdapter da = dbf.CreateDataAdapter() )
											{
												((IDbDataAdapter)da).SelectCommand = cmd;
												da.Fill(dtCustomArchive);
												DataView vwArchive = new DataView(dtCustomArchive);
												foreach ( DataRow row in dtCustom.Rows )
												{
													string sCOLUMN_NAME = Sql.ToString(row["COLUMN_NAME"]);
													vwArchive.RowFilter = "COLUMN_NAME = '" + sCOLUMN_NAME + "'";
													if ( vwArchive.Count > 0 )
													{
														lstCustomFields.Add(sCOLUMN_NAME);
													}
												}
											}
										}
									}
									StringBuilder sbCustomInsert = new StringBuilder();
									sbCustomInsert.AppendLine("insert into " + sARCHIVE_CUSTOM);
									nFieldIndex = 0;
									foreach ( DataRow row in dtCustom.Rows )
									{
										string sCOLUMN_NAME = Sql.ToString(row["COLUMN_NAME"]);
										if ( lstCustomFields.Contains(sCOLUMN_NAME) )
										{
											sbCustomInsert.Append("\t");
											sbCustomInsert.Append(nFieldIndex == 0 ? "(" : ",");
											sbCustomInsert.AppendLine(" " + sCOLUMN_NAME);
											nFieldIndex++;
										}
									}
									sbCustomInsert.AppendLine("\t)");
									sbCustomInsert.AppendLine("values");
									nFieldIndex = 0;
									foreach ( DataRow row in dtCustom.Rows )
									{
										string sCOLUMN_NAME              = Sql.ToString (row["COLUMN_NAME"             ]);
										string sDATA_TYPE                = Sql.ToString (row["DATA_TYPE"               ]);
										int    nCHARACTER_MAXIMUM_LENGTH = Sql.ToInteger(row["CHARACTER_MAXIMUM_LENGTH"]);
										if ( lstCustomFields.Contains(sCOLUMN_NAME) )
										{
											sbCustomInsert.Append("\t");
											sbCustomInsert.Append(nFieldIndex == 0 ? "(" : ",");
											sbCustomInsert.AppendLine(" @" + sCOLUMN_NAME);
											if ( nCHARACTER_MAXIMUM_LENGTH == -1 )
												nCHARACTER_MAXIMUM_LENGTH = 104857600;
											Sql.CreateParameter(cmdCustomInsert, "@" + sCOLUMN_NAME, CsDataType(sDATA_TYPE), nCHARACTER_MAXIMUM_LENGTH);
											nFieldIndex++;
										}
									}
									sbCustomInsert.AppendLine("\t);");
									cmdCustomInsert.CommandText = sbCustomInsert.ToString();
									sb.Append(cmdCustomInsert.CommandText);
								}
							}
						}
					}
				}
			}
			return sb.ToString();
		}

		private static string ArchiveMoveData(HttpContext Context, Guid gID, string sTABLE_NAME, IDbCommand cmdPrimaryInsert, IDbCommand cmdCustomInsert)
		{
			if ( cmdPrimaryInsert == null )
				return String.Empty;
			
			string sCUSTOM_TABLE = sTABLE_NAME + "_CSTM";
			if ( cmdPrimaryInsert != null )
			{
				foreach ( IDbDataParameter par in cmdPrimaryInsert.Parameters )
				{
					par.Value = DBNull.Value;
				}
			}
			if ( cmdCustomInsert != null )
			{
				foreach ( IDbDataParameter par in cmdCustomInsert.Parameters )
				{
					par.Value = DBNull.Value;
				}
			}
			StringBuilder sb = new StringBuilder();
			DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
			try
			{
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select *             " + ControlChars.CrLf
					     + "  from " + sTABLE_NAME + ControlChars.CrLf
					     + " where ID = @ID      " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						cmd.CommandTimeout = 0;
						Sql.AddParameter(cmd, "@ID", gID);
						using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
						{
							if ( rdr.Read() )
							{
								for ( int i = 0; i < rdr.FieldCount; i++ )
								{
									string sFieldName = rdr.GetName(i);
									object oValue     = rdr.GetValue(i);
									IDbDataParameter par = Sql.FindParameter(cmdPrimaryInsert, sFieldName);
									if ( par != null )
										Sql.SetParameter(par, oValue);
								}
								sb.AppendLine(Sql.ExpandParameters(cmdPrimaryInsert));
							}
							// 04/11/2018 Paul.  If record does not exist, then do nothing.  Possible when re-archiving related records. 
							else
							{
								return String.Empty;
							}
						}
					}
					if ( cmdCustomInsert != null )
					{
						sSQL = "select *               " + ControlChars.CrLf
						     + "  from " + sCUSTOM_TABLE + ControlChars.CrLf
						     + " where ID_C = @ID      " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							cmd.CommandTimeout = 0;
							Sql.AddParameter(cmd, "@ID", gID);
							using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
							{
								if ( rdr.Read() )
								{
									for ( int i = 0; i < rdr.FieldCount; i++ )
									{
										string sFieldName = rdr.GetName(i);
										object oValue     = rdr.GetValue(i);
										IDbDataParameter par = Sql.FindParameter(cmdCustomInsert, sFieldName);
										if ( par != null )
											Sql.SetParameter(par, oValue);
									}
									sb.AppendLine(Sql.ExpandParameters(cmdCustomInsert));
								}
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				// 12/06/2019 Paul.  Include sql dump, but not data dump. 
				string sRawCommand = ControlChars.CrLf + cmdPrimaryInsert.CommandText;
				if ( cmdCustomInsert != null )
				{
					sRawCommand += ControlChars.CrLf + cmdCustomInsert.CommandText;
				}
				SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex) + sRawCommand);
				throw;
			}
			// 04/11/2018 Paul.  The insert will fail if the record already exists, so check first. 
			bool bEXISTS = false;
			DbProviderFactory dbfArchive = DbAcrhiveFactories.GetFactory(Context.Application);
			using ( IDbConnection conArchive = dbfArchive.CreateConnection() )
			{
				conArchive.Open();
				using ( IDbTransaction trn = conArchive.BeginTransaction() )
				{
					try
					{
						string sSQL;
						sSQL = "select count(*)      " + ControlChars.CrLf
						     + "  from " + sTABLE_NAME + ControlChars.CrLf
						     + " where ID = @ID      " + ControlChars.CrLf;
						using ( IDbCommand cmd = conArchive.CreateCommand() )
						{
							cmd.CommandText    = sSQL;
							cmd.CommandTimeout = 0;
							cmd.Transaction    = trn;
							Sql.AddParameter(cmd, "@ID", gID);
							bEXISTS = Sql.ToBoolean(cmd.ExecuteScalar());
							if ( !bEXISTS )
							{
								cmdPrimaryInsert.Connection = conArchive;
								cmdPrimaryInsert.Transaction = trn;
								cmdPrimaryInsert.ExecuteNonQuery();
							}
						}
						if ( cmdCustomInsert != null )
						{
							sSQL = "select count(*)        " + ControlChars.CrLf
							     + "  from " + sCUSTOM_TABLE + ControlChars.CrLf
							     + " where ID_C = @ID      " + ControlChars.CrLf;
							using ( IDbCommand cmd = conArchive.CreateCommand() )
							{
								cmd.CommandText    = sSQL;
								cmd.CommandTimeout = 0;
								cmd.Transaction    = trn;
								Sql.AddParameter(cmd, "@ID", gID);
								bEXISTS = Sql.ToBoolean(cmd.ExecuteScalar());
								if ( !bEXISTS )
								{
									cmdCustomInsert.Connection = conArchive;
									cmdCustomInsert.Transaction = trn;
									cmdCustomInsert.ExecuteNonQuery();
								}
							}
						}
						trn.Commit();
					}
					catch(Exception ex)
					{
						trn.Rollback();
						// 12/06/2019 Paul.  Include sql dump, but not data dump. 
						string sRawCommand = ControlChars.CrLf + cmdPrimaryInsert.CommandText;
						if ( cmdCustomInsert != null )
						{
							sRawCommand += ControlChars.CrLf + cmdCustomInsert.CommandText;
						}
						SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex) + sRawCommand);
						throw;
					}
				}
			}
			// 04/11/2018 Paul.  After copying the record, we can delete from the main db. 
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				using ( IDbTransaction trn = Sql.BeginTransaction(con) )
				{
					try
					{
						string sSQL;
						sSQL = "delete from " + sTABLE_NAME + ControlChars.CrLf
						     + " where ID = @ID"            + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText    = sSQL;
							cmd.Transaction    = trn;
							cmd.CommandTimeout = 0;
							Sql.AddParameter(cmd, "@ID", gID);
							cmd.ExecuteNonQuery();
						}
						if ( cmdCustomInsert != null )
						{
							sSQL = "delete from " + sCUSTOM_TABLE + ControlChars.CrLf
							     + " where ID_C = @ID"            + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText    = sSQL;
								cmd.Transaction    = trn;
								cmd.CommandTimeout = 0;
								cmd.Transaction    = trn;
								Sql.AddParameter(cmd, "@ID", gID);
								cmd.ExecuteNonQuery();
							}
						}
						trn.Commit();
					}
					catch(Exception ex)
					{
						trn.Rollback();
						// 12/06/2019 Paul.  Include sql dump, but not data dump. 
						string sRawCommand = ControlChars.CrLf + cmdPrimaryInsert.CommandText;
						if ( cmdCustomInsert != null )
						{
							sRawCommand += ControlChars.CrLf + cmdCustomInsert.CommandText;
						}
						SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex) + sRawCommand);
						throw;
					}
				}
			}
			return sb.ToString();
		}

		private static string ArchiveMoveAuditData(HttpContext Context, Guid gAUDIT_ID, string sTABLE_NAME, IDbCommand cmdPrimaryInsert, IDbCommand cmdCustomInsert)
		{
			if ( cmdPrimaryInsert == null )
				return String.Empty;
			
			string sCUSTOM_TABLE = sTABLE_NAME + "_CSTM";
			if ( sTABLE_NAME.EndsWith("_AUDIT") )
				sCUSTOM_TABLE = sTABLE_NAME.Replace("_AUDIT", "_CSTM_AUDIT");
			if ( cmdPrimaryInsert != null )
			{
				foreach ( IDbDataParameter par in cmdPrimaryInsert.Parameters )
				{
					par.Value = DBNull.Value;
				}
			}
			if ( cmdCustomInsert != null )
			{
				foreach ( IDbDataParameter par in cmdCustomInsert.Parameters )
				{
					par.Value = DBNull.Value;
				}
			}
			// 12/07/2019 Paul.  Don't try and copy custom record if it does not exist. 
			bool bCustomExists = false;
			string sCustomSelectSQL = String.Empty;
			StringBuilder sb = new StringBuilder();
			DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				sSQL = "select *                   " + ControlChars.CrLf
				     + "  from " + sTABLE_NAME       + ControlChars.CrLf
				     + " where AUDIT_ID = @AUDIT_ID" + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					cmd.CommandTimeout = 0;
					Sql.AddParameter(cmd, "@AUDIT_ID", gAUDIT_ID);
					using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
					{
						if ( rdr.Read() )
						{
							for ( int i = 0; i < rdr.FieldCount; i++ )
							{
								string sFieldName = rdr.GetName(i);
								object oValue     = rdr.GetValue(i);
								IDbDataParameter par = Sql.FindParameter(cmdPrimaryInsert, sFieldName);
								if ( par != null )
									Sql.SetParameter(par, oValue);
							}
							sb.AppendLine(Sql.ExpandParameters(cmdPrimaryInsert));
						}
					}
				}
				if ( cmdCustomInsert != null )
				{
					sSQL = "select " + sCUSTOM_TABLE + ".*" + ControlChars.CrLf
					     + "  from      " + sTABLE_NAME     + ControlChars.CrLf
					     + " inner join " + sCUSTOM_TABLE   + ControlChars.CrLf
					     + "         on " + sCUSTOM_TABLE   + ".ID_C         = "  + sTABLE_NAME + ".ID         " + ControlChars.CrLf
					     + "        and " + sCUSTOM_TABLE   + ".AUDIT_TOKEN  = "  + sTABLE_NAME + ".AUDIT_TOKEN" + ControlChars.CrLf
					     + "        and " + sCUSTOM_TABLE   + ".AUDIT_ACTION = 1" + ControlChars.CrLf
					     + " where " + sTABLE_NAME   + ".AUDIT_ID = @AUDIT_ID" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						cmd.CommandTimeout = 0;
						Sql.AddParameter(cmd, "@AUDIT_ID", gAUDIT_ID);
						sCustomSelectSQL = Sql.ExpandParameters(cmd);
						using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
						{
							if ( rdr.Read() )
							{
								// 12/07/2019 Paul.  Don't try and copy custom record if it does not exist. 
								bCustomExists = true;
								for ( int i = 0; i < rdr.FieldCount; i++ )
								{
									string sFieldName = rdr.GetName(i);
									object oValue     = rdr.GetValue(i);
									IDbDataParameter par = Sql.FindParameter(cmdCustomInsert, sFieldName);
									if ( par != null )
										Sql.SetParameter(par, oValue);
								}
								sb.AppendLine(Sql.ExpandParameters(cmdCustomInsert));
							}
						}
					}
				}
			}
			// 04/11/2018 Paul.  The insert will fail if the record already exists, so check first. 
			bool bEXISTS = false;
			DbProviderFactory dbfArchive = DbAcrhiveFactories.GetFactory(Context.Application);
			using ( IDbConnection conArchive = dbfArchive.CreateConnection() )
			{
				conArchive.Open();
				using ( IDbTransaction trn = conArchive.BeginTransaction() )
				{
					try
					{
						string sSQL;
						sSQL = "select count(*)            " + ControlChars.CrLf
						     + "  from " + sTABLE_NAME       + ControlChars.CrLf
						     + " where AUDIT_ID = @AUDIT_ID" + ControlChars.CrLf;
						using ( IDbCommand cmd = conArchive.CreateCommand() )
						{
							cmd.CommandText    = sSQL;
							cmd.CommandTimeout = 0;
							cmd.Transaction    = trn;
							Sql.AddParameter(cmd, "@AUDIT_ID", gAUDIT_ID);
							bEXISTS = Sql.ToBoolean(cmd.ExecuteScalar());
							if ( !bEXISTS )
							{
								cmdPrimaryInsert.Connection = conArchive;
								cmdPrimaryInsert.Transaction = trn;
								cmdPrimaryInsert.ExecuteNonQuery();
							}
						}
						// 12/07/2019 Paul.  Don't try and copy custom record if it does not exist. 
						if ( cmdCustomInsert != null && bCustomExists )
						{
							sSQL = "select count(*)               " + ControlChars.CrLf
							     + "  from      " + sTABLE_NAME     + ControlChars.CrLf
							     + " inner join " + sCUSTOM_TABLE   + ControlChars.CrLf
							     + "         on " + sCUSTOM_TABLE   + ".ID_C         = "  + sTABLE_NAME + ".ID         " + ControlChars.CrLf
							     + "        and " + sCUSTOM_TABLE   + ".AUDIT_TOKEN  = "  + sTABLE_NAME + ".AUDIT_TOKEN" + ControlChars.CrLf
							     + "        and " + sCUSTOM_TABLE   + ".AUDIT_ACTION = 1" + ControlChars.CrLf
							     + " where " + sTABLE_NAME   + ".AUDIT_ID = @AUDIT_ID" + ControlChars.CrLf;
							using ( IDbCommand cmd = conArchive.CreateCommand() )
							{
								cmd.CommandText    = sSQL;
								cmd.CommandTimeout = 0;
								cmd.Transaction    = trn;
								Sql.AddParameter(cmd, "@AUDIT_ID", gAUDIT_ID);
								bEXISTS = Sql.ToBoolean(cmd.ExecuteScalar());
								if ( !bEXISTS )
								{
									cmdCustomInsert.Connection = conArchive;
									cmdCustomInsert.Transaction = trn;
									cmdCustomInsert.ExecuteNonQuery();
								}
							}
						}
						trn.Commit();
					}
					catch(Exception ex)
					{
						trn.Rollback();
						// 12/06/2019 Paul.  Include sql dump, but not data dump. 
						string sRawCommand = ControlChars.CrLf + cmdPrimaryInsert.CommandText;
						if ( cmdCustomInsert != null )
						{
							sRawCommand += ControlChars.CrLf + cmdCustomInsert.CommandText;
						}
						// 12/07/2019 Paul.  Include populated custom insert as we are having a problem. 
						sRawCommand += ControlChars.CrLf + Sql.ExpandParameters(cmdCustomInsert);
						sRawCommand += ControlChars.CrLf + sCustomSelectSQL;
						SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex) + sRawCommand);
						throw;
					}
				}
			}
			// 04/11/2018 Paul.  After copying the record, we can delete from the main db. 
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				using ( IDbTransaction trn = Sql.BeginTransaction(con) )
				{
					try
					{
						string sSQL;
						// 12/07/2019 Paul.  Don't try and copy custom record if it does not exist. 
						if ( cmdCustomInsert != null && bCustomExists )
						{
							sSQL = "delete "      + sCUSTOM_TABLE   + ControlChars.CrLf
							     + "  from      " + sTABLE_NAME     + ControlChars.CrLf
							     + " inner join " + sCUSTOM_TABLE   + ControlChars.CrLf
							     + "         on " + sCUSTOM_TABLE   + ".ID_C         = "  + sTABLE_NAME + ".ID         " + ControlChars.CrLf
							     + "        and " + sCUSTOM_TABLE   + ".AUDIT_TOKEN  = "  + sTABLE_NAME + ".AUDIT_TOKEN" + ControlChars.CrLf
							     + "        and " + sCUSTOM_TABLE   + ".AUDIT_ACTION = 1" + ControlChars.CrLf
							     + " where " + sTABLE_NAME   + ".AUDIT_ID = @AUDIT_ID" + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText    = sSQL;
								cmd.Transaction    = trn;
								cmd.CommandTimeout = 0;
								cmd.Transaction    = trn;
								Sql.AddParameter(cmd, "@AUDIT_ID", gAUDIT_ID);
								cmd.ExecuteNonQuery();
							}
						}
						sSQL = "delete from " + sTABLE_NAME  + ControlChars.CrLf
						     + " where AUDIT_ID = @AUDIT_ID" + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText    = sSQL;
							cmd.Transaction    = trn;
							cmd.CommandTimeout = 0;
							Sql.AddParameter(cmd, "@AUDIT_ID", gAUDIT_ID);
							cmd.ExecuteNonQuery();
						}
						trn.Commit();
					}
					catch(Exception ex)
					{
						trn.Rollback();
						// 12/06/2019 Paul.  Include sql dump, but not data dump. 
						string sRawCommand = ControlChars.CrLf + cmdPrimaryInsert.CommandText;
						if ( cmdCustomInsert != null )
						{
							sRawCommand += ControlChars.CrLf + cmdCustomInsert.CommandText;
						}
						SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex) + sRawCommand);
						throw;
					}
				}
			}
			return sb.ToString();
		}

		private static string ArchiveMoveRelationshipData(HttpContext Context, Guid gID, string sMODULE_NAME, string sTABLE_NAME)
		{
			StringBuilder sb = new StringBuilder();
			DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				// 04/08/2018 Paul.  Don't need to include CSTM and SYNC will not be moved. 
				// 04/09/2018 Paul.  Looking for singular name (like ACCOUNT_ID) will skip CSTM and SYNC tables. 
				// 07/10/2018 Paul.  We will not be archiving archive tables. 
				// 01/26/2020 Paul.  Exclude customer specific tables. 
				sSQL = "select COLUMNS.TABLE_NAME                         " + ControlChars.CrLf
				     + "  from      INFORMATION_SCHEMA.COLUMNS  COLUMNS   " + ControlChars.CrLf
				     + " inner join INFORMATION_SCHEMA.TABLES   TABLES    " + ControlChars.CrLf
				     + "         on TABLES.TABLE_NAME = COLUMNS.TABLE_NAME" + ControlChars.CrLf
				     + "        and TABLES.TABLE_TYPE = 'BASE TABLE'      " + ControlChars.CrLf
				     + " where COLUMNS.COLUMN_NAME = @COLUMN_NAME         " + ControlChars.CrLf
				     + "   and COLUMNS.TABLE_NAME not in (select TABLE_NAME              from vwMODULES where TABLE_NAME is not null)" + ControlChars.CrLf
				     + "   and COLUMNS.TABLE_NAME not in (select TABLE_NAME + '_AUDIT'   from vwMODULES where TABLE_NAME is not null)" + ControlChars.CrLf
				     + "   and COLUMNS.TABLE_NAME not in (select TABLE_NAME + '_ARCHIVE' from vwMODULES where TABLE_NAME is not null)" + ControlChars.CrLf
				     + "   and COLUMNS.TABLE_NAME not like 'USR[_]%'      " + ControlChars.CrLf
				     + " order by COLUMNS.TABLE_NAME                      " + ControlChars.CrLf;
				using ( IDbCommand cmdRelated = con.CreateCommand() )
				{
					cmdRelated.CommandText = sSQL;
					cmdRelated.CommandTimeout = 0;
					string sRELATED_COLUMN_NAME = Crm.Modules.SingularTableName(sTABLE_NAME) + "_ID";
					Sql.AddParameter(cmdRelated, "@COLUMN_NAME", sRELATED_COLUMN_NAME);
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmdRelated;
						using ( DataTable dtRelatedTables = new DataTable() )
						{
							da.Fill(dtRelatedTables);
							if ( sTABLE_NAME == "QUOTES" )
							{
								DataRow row = dtRelatedTables.NewRow();
								row["TABLE_NAME"] = "QUOTES_LINE_ITEMS";
								dtRelatedTables.Rows.Add(row);
								row = dtRelatedTables.NewRow();
								row["TABLE_NAME"] = "QUOTES_LINE_ITEMS_AUDIT";
								dtRelatedTables.Rows.Add(row);
							}
							else if ( sTABLE_NAME == "ORDERS" )
							{
								DataRow row = dtRelatedTables.NewRow();
								row["TABLE_NAME"] = "ORDERS_LINE_ITEMS";
								dtRelatedTables.Rows.Add(row);
								row = dtRelatedTables.NewRow();
								row["TABLE_NAME"] = "ORDERS_LINE_ITEMS_AUDIT";
								dtRelatedTables.Rows.Add(row);
							}
							else if ( sTABLE_NAME == "INVOICES" )
							{
								DataRow row = dtRelatedTables.NewRow();
								row["TABLE_NAME"] = "INVOICES_LINE_ITEMS";
								dtRelatedTables.Rows.Add(row);
								row = dtRelatedTables.NewRow();
								row["TABLE_NAME"] = "INVOICES_LINE_ITEMS_AUDIT";
								dtRelatedTables.Rows.Add(row);
							}
							else if ( sTABLE_NAME == "OPPORTUNITIES" )
							{
								DataRow row = dtRelatedTables.NewRow();
								row["TABLE_NAME"] = "REVENUE_LINE_ITEMS";
								dtRelatedTables.Rows.Add(row);
								row = dtRelatedTables.NewRow();
								row["TABLE_NAME"] = "REVENUE_LINE_ITEMS_AUDIT";
								dtRelatedTables.Rows.Add(row);
							}
							else if ( sTABLE_NAME == "PROJECT" )
							{
								DataRow row = dtRelatedTables.NewRow();
								row["TABLE_NAME"] = "PROJECT_TASK";
								dtRelatedTables.Rows.Add(row);
								row = dtRelatedTables.NewRow();
								row["TABLE_NAME"] = "PROJECT_TASK_AUDIT";
								dtRelatedTables.Rows.Add(row);
							}
							else if ( sTABLE_NAME == "DOCUMENTS" )
							{
								DataRow row = dtRelatedTables.NewRow();
								row["TABLE_NAME"] = "DOCUMENT_REVISIONS";
								dtRelatedTables.Rows.Add(row);
								row = dtRelatedTables.NewRow();
								row["TABLE_NAME"] = "DOCUMENT_REVISIONS_AUDIT";
								dtRelatedTables.Rows.Add(row);
							}
							foreach ( DataRow rowRelated in dtRelatedTables.Rows )
							{
								string sRELATED_TABLE = Sql.ToString(rowRelated["TABLE_NAME"]);
								if ( sRELATED_TABLE.EndsWith("_AUDIT") )
								{
									sSQL = "select AUDIT_ID                          " + ControlChars.CrLf
									     + "  from " + sRELATED_TABLE                  + ControlChars.CrLf
									     + " where " + sRELATED_COLUMN_NAME + " = @ID" + ControlChars.CrLf
									     + " order by AUDIT_VERSION                  " + ControlChars.CrLf;
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.CommandText = sSQL;
										cmd.CommandTimeout = 0;
										Sql.AddParameter(cmd, "@ID", gID);
										((IDbDataAdapter)da).SelectCommand = cmd;
										using ( DataTable dtRelatedData = new DataTable() )
										{
											da.Fill(dtRelatedData);
											IDbCommand cmdPrimaryInsert = null;
											IDbCommand cmdCustomInsert  = null;
											BuildInsertProcedures(Context, sRELATED_TABLE, ref cmdPrimaryInsert, ref cmdCustomInsert);
											// 04/12/2018 Paul.  If table does not exist on both main DB and archive DB, then the command will be null. 
											if ( cmdPrimaryInsert != null )
											{
												foreach ( DataRow row in dtRelatedData.Rows )
												{
													Guid gAUDIT_ID = Sql.ToGuid(row["AUDIT_ID"]);
													sb.Append(ArchiveMoveAuditData(Context, gAUDIT_ID, sRELATED_TABLE, cmdPrimaryInsert, cmdCustomInsert));
												}
											}
										}
									}
								}
								else
								{
									// 01/26/2020 Paul.  A customer specific table may not have the ID field.  Catch this error and ignore. 
									bool bExists = false;
									using ( IDbTransaction trn = Sql.BeginTransaction(con) )
									{
										SqlProcs.spSqlTableColumnExists(ref bExists, sRELATED_TABLE, "ID", String.Empty, trn);
										trn.Rollback();
									}
									if ( bExists )
									{
										sSQL = "select ID                                " + ControlChars.CrLf
										     + "  from " + sRELATED_TABLE                  + ControlChars.CrLf
										     + " where " + sRELATED_COLUMN_NAME + " = @ID" + ControlChars.CrLf;
										using ( IDbCommand cmd = con.CreateCommand() )
										{
											cmd.CommandText = sSQL;
											cmd.CommandTimeout = 0;
											Sql.AddParameter(cmd, "@ID", gID);
											((IDbDataAdapter)da).SelectCommand = cmd;
											using ( DataTable dtRelatedData = new DataTable() )
											{
												da.Fill(dtRelatedData);
												IDbCommand cmdPrimaryInsert = null;
												IDbCommand cmdCustomInsert  = null;
												BuildInsertProcedures(Context, sRELATED_TABLE, ref cmdPrimaryInsert, ref cmdCustomInsert);
												// 04/12/2018 Paul.  If table does not exist on both main DB and archive DB, then the command will be null. 
												if ( cmdPrimaryInsert != null )
												{
													foreach ( DataRow row in dtRelatedData.Rows )
													{
														Guid gRELATED_ID = Sql.ToGuid(row["ID"]);
														sb.Append(ArchiveMoveData(Context, gRELATED_ID, sRELATED_TABLE, cmdPrimaryInsert, cmdCustomInsert));
													}
												}
											}
										}
									}
									else
									{
#if DEBUG
// 01/26/2020 Paul.  Careful not to fill up the system log as this warning would be generated for each record being archived. 
//										SplendidError.SystemMessage(Context, "Warning", new StackTrace(true).GetFrame(0), "Ignoring " + sRELATED_TABLE + " as it does not have an ID field.");
#endif
									}
								}
							}
						}
					}
				}
			}
			return sb.ToString();
		}

		private static string ArchiveMoveActivitiesData(HttpContext Context, Guid gID, string sMODULE_NAME, string sTABLE_NAME)
		{
			IDbCommand cmdNOTE_ATTACHMENTSPrimaryInsert = null;
			IDbCommand cmdNOTE_ATTACHMENTSCustomInsert  = null;
			BuildInsertProcedures(Context, "NOTE_ATTACHMENTS", ref cmdNOTE_ATTACHMENTSPrimaryInsert, ref cmdNOTE_ATTACHMENTSCustomInsert);
			IDbCommand cmdEMAIL_IMAGESPrimaryInsert = null;
			IDbCommand cmdEMAIL_IMAGESCustomInsert  = null;
			BuildInsertProcedures(Context, "EMAIL_IMAGES", ref cmdEMAIL_IMAGESPrimaryInsert, ref cmdEMAIL_IMAGESCustomInsert);
			IDbCommand cmdNOTESPrimaryInsert = null;
			IDbCommand cmdNOTESCustomInsert  = null;
			BuildInsertProcedures(Context, "NOTES", ref cmdNOTESPrimaryInsert, ref cmdNOTESCustomInsert);

			IDbCommand cmdNOTE_ATTACHMENTS_AUDITPrimaryInsert = null;
			IDbCommand cmdNOTE_ATTACHMENTS_AUDITCustomInsert  = null;
			BuildInsertProcedures(Context, "NOTE_ATTACHMENTS", ref cmdNOTE_ATTACHMENTS_AUDITPrimaryInsert, ref cmdNOTE_ATTACHMENTS_AUDITCustomInsert);
			IDbCommand cmdEMAIL_IMAGES_AUDITPrimaryInsert = null;
			IDbCommand cmdEMAIL_IMAGES_AUDITCustomInsert  = null;
			BuildInsertProcedures(Context, "EMAIL_IMAGES_AUDIT", ref cmdEMAIL_IMAGES_AUDITPrimaryInsert, ref cmdEMAIL_IMAGES_AUDITCustomInsert);
			IDbCommand cmdNOTES_AUDITPrimaryInsert = null;
			IDbCommand cmdNOTES_AUDITCustomInsert  = null;
			BuildInsertProcedures(Context, "NOTES_AUDIT", ref cmdNOTES_AUDITPrimaryInsert, ref cmdNOTES_AUDITCustomInsert);

			StringBuilder sb = new StringBuilder();
			DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				sSQL = "select RELATED_TABLE             " + ControlChars.CrLf
				     + "  from vwMODULES_ARCHIVE_RELATED " + ControlChars.CrLf
				     + " where MODULE_NAME = 'Activities'" + ControlChars.CrLf
				     + " order by RELATED_ORDER          " + ControlChars.CrLf;
				using ( IDbCommand cmdRelated = con.CreateCommand() )
				{
					cmdRelated.CommandText = sSQL;
					cmdRelated.CommandTimeout = 0;
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmdRelated;
						using ( DataTable dtRelatedTable = new DataTable() )
						{
							da.Fill(dtRelatedTable);
							foreach ( DataRow rowRelated in dtRelatedTable.Rows )
							{
								string sRELATED_TABLE = Sql.ToString(rowRelated["RELATED_TABLE"]);
								string sRELATED_AUDIT = sRELATED_TABLE + "_AUDIT";
								bool   bEMAIL_RELATED_EXISTS = false;
								sSQL = "select ID                        " + ControlChars.CrLf
								     + "  from " + sRELATED_TABLE          + ControlChars.CrLf
								     + " where PARENT_ID   = @PARENT_ID  " + ControlChars.CrLf
								     + "   and PARENT_TYPE = @PARENT_TYPE" + ControlChars.CrLf;
								if ( sRELATED_TABLE == "EMAILS" )
								{
									// 04/14/2018 Paul.  Emails can also use separate relationship tables. 
									string sEMAIL_RELATED_TABLE = "EMAILS_" + sTABLE_NAME;
									string sSQL2;
									sSQL2 = "select count(*)                 " + ControlChars.CrLf
									      + "  from INFORMATION_SCHEMA.TABLES" + ControlChars.CrLf
									      + " where TABLE_NAME = @TABLE_NAME " + ControlChars.CrLf;
									using ( IDbCommand cmdEmailRelated = con.CreateCommand() )
									{
										cmdEmailRelated.CommandText = sSQL2;
										Sql.AddParameter(cmdEmailRelated, "@TABLE_NAME", sEMAIL_RELATED_TABLE);
										bEMAIL_RELATED_EXISTS = Sql.ToBoolean(cmdEmailRelated.ExecuteScalar());
										if ( bEMAIL_RELATED_EXISTS )
										{
											string sEMAIL_RELATED_KEY = Crm.Modules.SingularTableName(sTABLE_NAME) + "_ID";
											sSQL += "union all                        " + ControlChars.CrLf
											     +  "select EMAIL_ID                  " + ControlChars.CrLf
											     +  "  from " + sEMAIL_RELATED_TABLE    + ControlChars.CrLf
											     +  " where " + sEMAIL_RELATED_KEY + " = @" + sEMAIL_RELATED_KEY + ControlChars.CrLf;
										}
									}
								}
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									cmd.CommandTimeout = 0;
									Sql.AddParameter(cmd, "@PARENT_ID"  , gID         );
									Sql.AddParameter(cmd, "@PARENT_TYPE", sMODULE_NAME);
									if ( sRELATED_TABLE == "EMAILS" && bEMAIL_RELATED_EXISTS )
									{
										string sEMAIL_RELATED_KEY = Crm.Modules.SingularTableName(sTABLE_NAME) + "_ID";
										Sql.AddParameter(cmd, "@" + sEMAIL_RELATED_KEY, gID);
									}
									((IDbDataAdapter)da).SelectCommand = cmd;
									using ( DataTable dtRelatedData = new DataTable() )
									{
										da.Fill(dtRelatedData);
										IDbCommand cmdPrimaryInsert = null;
										IDbCommand cmdCustomInsert  = null;
										BuildInsertProcedures(Context, sRELATED_TABLE, ref cmdPrimaryInsert, ref cmdCustomInsert);
										// 04/12/2018 Paul.  If table does not exist on both main DB and archive DB, then the command will be null. 
										if ( cmdPrimaryInsert != null )
										{
											foreach ( DataRow row in dtRelatedData.Rows )
											{
												Guid gRELATED_ID = Sql.ToGuid(row["ID"]);
												sb.Append(ArchiveMoveData(Context, gRELATED_ID, sRELATED_TABLE, cmdPrimaryInsert, cmdCustomInsert));
												if ( sRELATED_TABLE == "NOTES" && cmdNOTE_ATTACHMENTSPrimaryInsert != null )
												{
													string sIMAGES_TABLE   = "NOTE_ATTACHMENTS";
													sSQL = "select ID                  " + ControlChars.CrLf
													     + "  from " + sIMAGES_TABLE     + ControlChars.CrLf
													     + " where NOTE_ID   = @NOTE_ID" + ControlChars.CrLf;
													using ( IDbCommand cmdImages = con.CreateCommand() )
													{
														cmdImages.CommandText = sSQL;
														cmdImages.CommandTimeout = 0;
														Sql.AddParameter(cmdImages, "@NOTE_ID", gRELATED_ID);
														((IDbDataAdapter)da).SelectCommand = cmdImages;
														using ( DataTable dtImagesData = new DataTable() )
														{
															da.Fill(dtImagesData);
															foreach ( DataRow rowImage in dtImagesData.Rows )
															{
																Guid gIMAGE_ID = Sql.ToGuid(rowImage["ID"]);
																sb.Append(ArchiveMoveData(Context, gIMAGE_ID, sIMAGES_TABLE, cmdNOTE_ATTACHMENTSPrimaryInsert, cmdNOTE_ATTACHMENTSCustomInsert));
															}
														}
													}
												}
												else if ( sRELATED_TABLE == "EMAILS" && cmdEMAIL_IMAGESPrimaryInsert != null )
												{
													string sIMAGES_TABLE = "EMAIL_IMAGES";
													sSQL = "select ID                      " + ControlChars.CrLf
													     + "  from " + sIMAGES_TABLE         + ControlChars.CrLf
													     + " where PARENT_ID   = @PARENT_ID" + ControlChars.CrLf;
													using ( IDbCommand cmdImages = con.CreateCommand() )
													{
														cmdImages.CommandText = sSQL;
														cmdImages.CommandTimeout = 0;
														Sql.AddParameter(cmdImages, "@PARENT_ID", gRELATED_ID);
														((IDbDataAdapter)da).SelectCommand = cmdImages;
														using ( DataTable dtImagesData = new DataTable() )
														{
															da.Fill(dtImagesData);
															foreach ( DataRow rowImage in dtImagesData.Rows )
															{
																Guid gIMAGE_ID = Sql.ToGuid(rowImage["ID"]);
																sb.Append(ArchiveMoveData(Context, gIMAGE_ID, sIMAGES_TABLE, cmdEMAIL_IMAGESPrimaryInsert, cmdEMAIL_IMAGESCustomInsert));
															}
														}
													}
													// 04/14/2018 Paul.  Emails also contain notes/attachments. 
													string sNOTES_TABLE = "NOTES";
													sSQL = "select ID                      " + ControlChars.CrLf
													     + "  from " + sNOTES_TABLE          + ControlChars.CrLf
													     + " where PARENT_ID   = @PARENT_ID" + ControlChars.CrLf;
													using ( IDbCommand cmdNotes = con.CreateCommand() )
													{
														cmdNotes.CommandText = sSQL;
														cmdNotes.CommandTimeout = 0;
														Sql.AddParameter(cmdNotes, "@PARENT_ID", gRELATED_ID);
														((IDbDataAdapter)da).SelectCommand = cmdNotes;
														using ( DataTable dtNotesData = new DataTable() )
														{
															da.Fill(dtNotesData);
															foreach ( DataRow rowNote in dtNotesData.Rows )
															{
																Guid gNOTE_ID = Sql.ToGuid(rowNote["ID"]);
																sb.Append(ArchiveMoveData(Context, gNOTE_ID, sNOTES_TABLE, cmdNOTESPrimaryInsert, cmdNOTESCustomInsert));
																if ( cmdNOTE_ATTACHMENTSPrimaryInsert != null )
																{
																	sIMAGES_TABLE   = "NOTE_ATTACHMENTS";
																	sSQL = "select ID                  " + ControlChars.CrLf
																	     + "  from " + sIMAGES_TABLE     + ControlChars.CrLf
																	     + " where NOTE_ID   = @NOTE_ID" + ControlChars.CrLf;
																	using ( IDbCommand cmdImages = con.CreateCommand() )
																	{
																		cmdImages.CommandText = sSQL;
																		cmdImages.CommandTimeout = 0;
																		Sql.AddParameter(cmdImages, "@NOTE_ID", gNOTE_ID);
																		((IDbDataAdapter)da).SelectCommand = cmdImages;
																		using ( DataTable dtImagesData = new DataTable() )
																		{
																			da.Fill(dtImagesData);
																			foreach ( DataRow rowImage in dtImagesData.Rows )
																			{
																				Guid gIMAGE_ID = Sql.ToGuid(rowImage["ID"]);
																				sb.Append(ArchiveMoveData(Context, gIMAGE_ID, sIMAGES_TABLE, cmdNOTE_ATTACHMENTSPrimaryInsert, cmdNOTE_ATTACHMENTSCustomInsert));
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
											IDbCommand cmdAuditPrimaryInsert = null;
											IDbCommand cmdAuditCustomInsert  = null;
											BuildInsertProcedures(Context, sRELATED_AUDIT, ref cmdAuditPrimaryInsert, ref cmdAuditCustomInsert);
											// 04/12/2018 Paul.  If table does not exist on both main DB and archive DB, then the command will be null. 
											if ( cmdAuditPrimaryInsert != null )
											{
												// 04/12/2018 Paul.  Repeat the loop to process Audit data. 
												foreach ( DataRow row in dtRelatedData.Rows )
												{
													Guid gRELATED_ID = Sql.ToGuid(row["ID"]);
													sSQL = "select AUDIT_ID         " + ControlChars.CrLf
													     + "  from " + sRELATED_AUDIT + ControlChars.CrLf
													     + " where ID   = @ID       " + ControlChars.CrLf
													     + " order by AUDIT_VERSION " + ControlChars.CrLf;
													using ( IDbCommand cmdAudit = con.CreateCommand() )
													{
														cmdAudit.CommandText = sSQL;
														cmdAudit.CommandTimeout = 0;
														Sql.AddParameter(cmdAudit, "@ID", gRELATED_ID);
														((IDbDataAdapter)da).SelectCommand = cmdAudit;
														using ( DataTable dtAuditData = new DataTable() )
														{
															da.Fill(dtAuditData);
															foreach ( DataRow rowAudit in dtAuditData.Rows )
															{
																Guid gAUDIT_ID = Sql.ToGuid(rowAudit["AUDIT_ID"]);
																sb.Append(ArchiveMoveAuditData(Context, gAUDIT_ID, sRELATED_AUDIT, cmdAuditPrimaryInsert, cmdAuditCustomInsert));
																if ( sRELATED_TABLE == "NOTES_AUDIT" && cmdNOTE_ATTACHMENTS_AUDITPrimaryInsert != null )
																{
																	string sIMAGES_AUDIT_TABLE = "NOTE_ATTACHMENTS_AUDIT";
																	sSQL = "select AUDIT_ID              " + ControlChars.CrLf
																	     + "  from " + sIMAGES_AUDIT_TABLE + ControlChars.CrLf
																	     + " where NOTE_ID   = @NOTE_ID  " + ControlChars.CrLf
																	     + " order by AUDIT_VERSION      " + ControlChars.CrLf;
																	using ( IDbCommand cmdImages = con.CreateCommand() )
																	{
																		cmdImages.CommandText = sSQL;
																		cmdImages.CommandTimeout = 0;
																		Sql.AddParameter(cmdImages, "@NOTE_ID", gRELATED_ID);
																		((IDbDataAdapter)da).SelectCommand = cmdImages;
																		using ( DataTable dtImagesData = new DataTable() )
																		{
																			da.Fill(dtImagesData);
																			foreach ( DataRow rowImage in dtImagesData.Rows )
																			{
																				Guid gIMAGE_AUDIT_ID = Sql.ToGuid(rowImage["AUDIT_ID"]);
																				sb.Append(ArchiveMoveAuditData(Context, gIMAGE_AUDIT_ID, sIMAGES_AUDIT_TABLE, cmdNOTE_ATTACHMENTS_AUDITPrimaryInsert, cmdNOTE_ATTACHMENTS_AUDITCustomInsert));
																			}
																		}
																	}
																}
																else if ( sRELATED_TABLE == "EMAILS_AUDIT" && cmdEMAIL_IMAGES_AUDITPrimaryInsert != null )
																{
																	string sIMAGES_AUDIT_TABLE = "EMAIL_IMAGES_AUDIT";
																	sSQL = "select AUDIT_ID                " + ControlChars.CrLf
																	     + "  from " + sIMAGES_AUDIT_TABLE   + ControlChars.CrLf
																	     + " where PARENT_ID   = @PARENT_ID" + ControlChars.CrLf;
																	using ( IDbCommand cmdImages = con.CreateCommand() )
																	{
																		cmdImages.CommandText = sSQL;
																		cmdImages.CommandTimeout = 0;
																		Sql.AddParameter(cmdImages, "@PARENT_ID", gRELATED_ID);
																		((IDbDataAdapter)da).SelectCommand = cmdImages;
																		using ( DataTable dtImagesData = new DataTable() )
																		{
																			da.Fill(dtImagesData);
																			foreach ( DataRow rowImage in dtImagesData.Rows )
																			{
																				Guid gIMAGE_AUDIT_ID = Sql.ToGuid(rowImage["AUDIT_ID"]);
																				sb.Append(ArchiveMoveAuditData(Context, gIMAGE_AUDIT_ID, sIMAGES_AUDIT_TABLE, cmdEMAIL_IMAGES_AUDITPrimaryInsert, cmdEMAIL_IMAGES_AUDITCustomInsert));
																			}
																		}
																	}
																	// 04/14/2018 Paul.  Emails also contain notes/attachments. 
																	string sNOTES_AUDIT_TABLE = "NOTES_AUDIT";
																	sSQL = "select AUDIT_ID                " + ControlChars.CrLf
																	     + "     , NOTE_ID                 " + ControlChars.CrLf
																	     + "  from " + sNOTES_AUDIT_TABLE    + ControlChars.CrLf
																	     + " where PARENT_ID   = @PARENT_ID" + ControlChars.CrLf;
																	using ( IDbCommand cmdNotes = con.CreateCommand() )
																	{
																		cmdNotes.CommandText = sSQL;
																		cmdNotes.CommandTimeout = 0;
																		Sql.AddParameter(cmdNotes, "@PARENT_ID", gRELATED_ID);
																		((IDbDataAdapter)da).SelectCommand = cmdNotes;
																		using ( DataTable dtNotesData = new DataTable() )
																		{
																			da.Fill(dtNotesData);
																			foreach ( DataRow rowNote in dtNotesData.Rows )
																			{
																				Guid gNOTE_AUDIT_ID = Sql.ToGuid(rowNote["AUDIT_ID"]);
																				Guid gNOTE_ID       = Sql.ToGuid(rowNote["NOTE_ID" ]);
																				sb.Append(ArchiveMoveAuditData(Context, gNOTE_AUDIT_ID, sNOTES_AUDIT_TABLE, cmdNOTES_AUDITPrimaryInsert, cmdNOTES_AUDITCustomInsert));
																				if ( cmdNOTE_ATTACHMENTS_AUDITPrimaryInsert != null )
																				{
																					sIMAGES_AUDIT_TABLE = "NOTE_ATTACHMENTS_AUDIT";
																					sSQL = "select AUDIT_ID              " + ControlChars.CrLf
																					     + "  from " + sIMAGES_AUDIT_TABLE + ControlChars.CrLf
																					     + " where NOTE_ID   = @NOTE_ID  " + ControlChars.CrLf
																					     + " order by AUDIT_VERSION      " + ControlChars.CrLf;
																					using ( IDbCommand cmdImages = con.CreateCommand() )
																					{
																						cmdImages.CommandText = sSQL;
																						cmdImages.CommandTimeout = 0;
																						Sql.AddParameter(cmdImages, "@NOTE_ID", gNOTE_ID);
																						((IDbDataAdapter)da).SelectCommand = cmdImages;
																						using ( DataTable dtImagesData = new DataTable() )
																						{
																							da.Fill(dtImagesData);
																							foreach ( DataRow rowImage in dtImagesData.Rows )
																							{
																								Guid gIMAGE_AUDIT_ID = Sql.ToGuid(rowImage["AUDIT_ID"]);
																								sb.Append(ArchiveMoveAuditData(Context, gIMAGE_AUDIT_ID, sIMAGES_AUDIT_TABLE, cmdNOTE_ATTACHMENTS_AUDITPrimaryInsert, cmdNOTE_ATTACHMENTS_AUDITCustomInsert));
																							}
																						}
																					}
																				}
																			}
																		}
																	}
																}
															}
														}
													}
												}
											}
										}
									}
								}
							}
						}
					}
				}
			}
			return sb.ToString();
		}

		private static string ArchiveMoveRelatedData(HttpContext Context, Guid gID, string sMODULE_NAME, string sTABLE_NAME)
		{
			StringBuilder sb = new StringBuilder();
			DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				sSQL = "select RELATED_NAME               " + ControlChars.CrLf
				     + "     , RELATED_TABLE              " + ControlChars.CrLf
				     + "  from vwMODULES_ARCHIVE_RELATED  " + ControlChars.CrLf
				     + " where MODULE_NAME = @MODULE_NAME " + ControlChars.CrLf
				     + "   and RELATED_NAME <> MODULE_NAME" + ControlChars.CrLf
				     + "   and RELATED_TABLE is not null  " + ControlChars.CrLf
				     + " order by RELATED_ORDER           " + ControlChars.CrLf;
				using ( IDbCommand cmdRelated = con.CreateCommand() )
				{
					cmdRelated.CommandText = sSQL;
					cmdRelated.CommandTimeout = 0;
					Sql.AddParameter(cmdRelated, "@MODULE_NAME", sMODULE_NAME);
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmdRelated;
						using ( DataTable dtRelatedTable = new DataTable() )
						{
							da.Fill(dtRelatedTable);
							foreach ( DataRow rowRelated in dtRelatedTable.Rows )
							{
								string sRELATED_MODULE_NAME = Sql.ToString(rowRelated["RELATED_NAME" ]);
								string sRELATED_TABLE_NAME  = Sql.ToString(rowRelated["RELATED_TABLE"]);
								string sLEFT_TABLE          = sTABLE_NAME;
								string sRIGHT_TABLE         = sRELATED_TABLE_NAME;
								string sSINGULAR_LEFT_KEY   = Crm.Modules.SingularTableName(sLEFT_TABLE ) + "_ID";
								string sSINGULAR_RIGHT_KEY  = Crm.Modules.SingularTableName(sRIGHT_TABLE) + "_ID";
								string sRELATIONSHIP_TABLE  = sTABLE_NAME + "_" + sRELATED_TABLE_NAME;
								bool bEXISTS = false;
								sSQL = "select count(*)                 " + ControlChars.CrLf
								     + "  from INFORMATION_SCHEMA.TABLES" + ControlChars.CrLf
								     + " where TABLE_NAME = @TABLE_NAME " + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									cmd.CommandTimeout = 0;
									Sql.AddParameter(cmd, "@TABLE_NAME", sRELATIONSHIP_TABLE);
									bEXISTS = Sql.ToBoolean(cmd.ExecuteScalar());
								}
								if ( !bEXISTS )
								{
									sRELATIONSHIP_TABLE = sRELATED_TABLE_NAME + "_" + sTABLE_NAME;
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.CommandText = sSQL;
										cmd.CommandTimeout = 0;
										Sql.AddParameter(cmd, "@TABLE_NAME", sRELATIONSHIP_TABLE);
										bEXISTS = Sql.ToBoolean(cmd.ExecuteScalar());
									}
									if ( !bEXISTS )
									{
										sSQL = "select count(*)                  " + ControlChars.CrLf
										     + "  from INFORMATION_SCHEMA.COLUMNS" + ControlChars.CrLf
										     + " where TABLE_NAME  = @TABLE_NAME " + ControlChars.CrLf
										     + "   and COLUMN_NAME = @COLUMN_NAME" + ControlChars.CrLf;
										using ( IDbCommand cmd = con.CreateCommand() )
										{
											cmd.CommandText = sSQL;
											cmd.CommandTimeout = 0;
											Sql.AddParameter(cmd, "@TABLE_NAME" , sRELATED_TABLE_NAME);
											Sql.AddParameter(cmd, "@COLUMN_NAME", sSINGULAR_LEFT_KEY);
											bEXISTS = Sql.ToBoolean(cmd.ExecuteScalar());
											if ( bEXISTS )
											{
												sRELATIONSHIP_TABLE = sRELATED_TABLE_NAME;
												sSINGULAR_RIGHT_KEY = "ID";
											}
										}
									}
								}
								string sRELATED_AUDIT  = sRELATED_TABLE_NAME + "_AUDIT";
								if ( bEXISTS )
								{
									sSQL = "select ID                               " + ControlChars.CrLf
									     + "     , " + sSINGULAR_RIGHT_KEY            + ControlChars.CrLf
									     + "  from " + sRELATIONSHIP_TABLE            + ControlChars.CrLf
									     + " where " + sSINGULAR_LEFT_KEY  + " = @ID" + ControlChars.CrLf;
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.CommandText = sSQL;
										cmd.CommandTimeout = 0;
										Sql.AddParameter(cmd, "@ID", gID);
										((IDbDataAdapter)da).SelectCommand = cmd;
										using ( DataTable dtRelatedData = new DataTable() )
										{
											da.Fill(dtRelatedData);
											IDbCommand cmdPrimaryInsert = null;
											IDbCommand cmdCustomInsert  = null;
											BuildInsertProcedures(Context, sRELATED_TABLE_NAME, ref cmdPrimaryInsert, ref cmdCustomInsert);
											IDbCommand cmdAuditPrimaryInsert = null;
											IDbCommand cmdAuditCustomInsert  = null;
											BuildInsertProcedures(Context, sRELATED_AUDIT, ref cmdAuditPrimaryInsert, ref cmdAuditCustomInsert);
											// 04/12/2018 Paul.  If table does not exist on both main DB and archive DB, then the command will be null. 
											if ( cmdPrimaryInsert != null )
											{
												foreach ( DataRow row in dtRelatedData.Rows )
												{
													// 04/12/2018 Paul.  We don't want the ID of the relationship table, we want the ID of the related record. 
													Guid gRELATED_ID = Sql.ToGuid(row[sSINGULAR_RIGHT_KEY]);
													sb.Append(ArchiveMoveActivitiesData  (Context, gRELATED_ID, sRELATED_MODULE_NAME, sRELATED_TABLE_NAME));
													// 04/09/2018 Paul.  Prevent a recursive loop. 
													if ( sRELATED_MODULE_NAME != sMODULE_NAME )
														sb.Append(ArchiveMoveRelatedData     (Context, gRELATED_ID, sRELATED_MODULE_NAME, sRELATED_TABLE_NAME));
													sb.Append(ArchiveMoveRelationshipData(Context, gRELATED_ID, sRELATED_MODULE_NAME, sRELATED_TABLE_NAME));
													// 04/12/2018 Paul.  Also move audit data. 
													// 04/12/2018 Paul.  If table does not exist on both main DB and archive DB, then the command will be null. 
													if ( cmdAuditPrimaryInsert != null )
													{
														sSQL = "select AUDIT_ID         " + ControlChars.CrLf
														     + "  from " + sRELATED_AUDIT + ControlChars.CrLf
														     + " where ID   = @ID       " + ControlChars.CrLf
														     + " order by AUDIT_VERSION " + ControlChars.CrLf;
														using ( IDbCommand cmdAudit = con.CreateCommand() )
														{
															cmdAudit.CommandText = sSQL;
															cmdAudit.CommandTimeout = 0;
															Sql.AddParameter(cmdAudit, "@ID", gRELATED_ID);
															((IDbDataAdapter)da).SelectCommand = cmdAudit;
															using ( DataTable dtAuditData = new DataTable() )
															{
																da.Fill(dtAuditData);
																foreach ( DataRow rowAudit in dtAuditData.Rows )
																{
																	Guid gAUDIT_ID = Sql.ToGuid(rowAudit["AUDIT_ID"]);
																	sb.Append(ArchiveMoveAuditData(Context, gAUDIT_ID, sRELATED_AUDIT, cmdAuditPrimaryInsert, cmdAuditCustomInsert));
																}
															}
														}
													}
													// 04/11/2018 Paul.  Move main record last just in case there is an error. 
													sb.Append(ArchiveMoveData(Context, gRELATED_ID, sRELATED_TABLE_NAME, cmdPrimaryInsert, cmdCustomInsert));
												}
												// 04/12/2018 Paul.  We don't need to process the relationship table itself as it is done inside ArchiveMoveRelationshipData(). 
											}
										}
									}
								}
							}
						}
					}
				}
			}
			return sb.ToString();
		}

		private static string ArchiveRulesRunAll(HttpContext Context)
		{
			StringBuilder sb = new StringBuilder();
			DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				sSQL = "select MODULES_ARCHIVE_RULES.ID                                          " + ControlChars.CrLf
				     + "     , MODULES_ARCHIVE_RULES.MODULE_NAME                                 " + ControlChars.CrLf
				     + "     , MODULES.TABLE_NAME                                                " + ControlChars.CrLf
				     + "     , MODULES_ARCHIVE_RULES.FILTER_SQL                                  " + ControlChars.CrLf
				     + "  from            MODULES_ARCHIVE_RULES                                  " + ControlChars.CrLf
				     + "  left outer join MODULES                                                " + ControlChars.CrLf
				     + "               on MODULES.MODULE_NAME = MODULES_ARCHIVE_RULES.MODULE_NAME" + ControlChars.CrLf
				     + " where MODULES_ARCHIVE_RULES.DELETED = 0                                 " + ControlChars.CrLf
				     + "   and MODULES_ARCHIVE_RULES.STATUS = 1                                  " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						using ( DataTable dtRules = new DataTable() )
						{
							da.Fill(dtRules);
							foreach ( DataRow rowRule in dtRules.Rows )
							{
								Guid   gRULE_ID     = Sql.ToGuid  (rowRule["ID"         ]);
								string sMODULE_NAME = Sql.ToString(rowRule["MODULE_NAME"]);
								string sTABLE_NAME  = Sql.ToString(rowRule["TABLE_NAME" ]);
								string sFILTER_SQL  = Sql.ToString(rowRule["FILTER_SQL" ]);
								using ( IDbTransaction trn = Sql.BeginTransaction(con) )
								{
									SqlProcs.spMODULES_ARCHIVE_LOG_InsertRule(gRULE_ID, sMODULE_NAME, sTABLE_NAME, trn);
									trn.Commit();
								}
								
								int nMaxArchiveBatchSize = Sql.ToInteger(Context.Application["CONFIG.Archive.BatchSize"]);
								if ( nMaxArchiveBatchSize == 0 )
									nMaxArchiveBatchSize = int.MaxValue;
								using ( DataTable dt = new DataTable() )
								{
#if false
									nMaxArchiveBatchSize = int.MaxValue;
									// 04/12/2018 Paul.  Pulling data out of the archive table allows us to re-run the archive rules to archive audit data. 
									DbProviderFactory dbfArchive = DbAcrhiveFactories.GetFactory(Context.Application);
									using ( IDbConnection conArchive = dbfArchive.CreateConnection() )
									{
										conArchive.Open();
										sSQL = "select ID             " + ControlChars.CrLf
										     + "  from CONTACTS       " + ControlChars.CrLf
										     + " order by DATE_ENTERED" + ControlChars.CrLf;
										using ( IDbCommand cmdArchive = conArchive.CreateCommand() )
										{
											cmdArchive.CommandText = sSQL;
											cmdArchive.CommandTimeout = 0;
											using ( DbDataAdapter daArchive = dbf.CreateDataAdapter() )
											{
												((IDbDataAdapter)daArchive).SelectCommand = cmdArchive;
												daArchive.Fill(dt);
											}
										}
									}
#else
									using ( IDbTransaction trn = Sql.BeginTransaction(con) )
									{
										using ( IDbCommand cmdRule = con.CreateCommand() )
										{
											cmdRule.CommandText = sFILTER_SQL;
											cmdRule.CommandTimeout = 0;
											cmdRule.Transaction = trn;
											((IDbDataAdapter)da).SelectCommand = cmdRule;
											da.Fill(dt);
										}
										trn.Rollback();
									}
#endif
									SplendidError.SystemMessage(Context, "Information", new StackTrace(true).GetFrame(0), "ArchiveExternalDB.ArchiveRulesRunAll " + sTABLE_NAME + " with " + dt.Rows.Count.ToString() + " records.");
									
									string sAUDIT_TABLE = sTABLE_NAME + "_AUDIT";
									IDbCommand cmdPrimaryInsert = null;
									IDbCommand cmdCustomInsert  = null;
									BuildInsertProcedures(Context, sTABLE_NAME, ref cmdPrimaryInsert, ref cmdCustomInsert);
									IDbCommand cmdAuditPrimaryInsert = null;
									IDbCommand cmdAuditCustomInsert  = null;
									BuildInsertProcedures(Context, sAUDIT_TABLE, ref cmdAuditPrimaryInsert, ref cmdAuditCustomInsert);
									
									// 04/12/2018 Paul.  If table does not exist on both main DB and archive DB, then the command will be null. 
									if ( cmdPrimaryInsert != null )
									{
										for ( int i = 0; i < dt.Rows.Count && i < nMaxArchiveBatchSize; i++ )
										{
											DataRow row = dt.Rows[i];
											Guid gID = Sql.ToGuid(row["ID"]);
											sb.Append(ArchiveMoveActivitiesData  (Context, gID, sMODULE_NAME, sTABLE_NAME));
											sb.Append(ArchiveMoveRelatedData     (Context, gID, sMODULE_NAME, sTABLE_NAME));
											sb.Append(ArchiveMoveRelationshipData(Context, gID, sMODULE_NAME, sTABLE_NAME));
											// 04/12/2018 Paul.  Also move audit data. 
											// 04/12/2018 Paul.  If table does not exist on both main DB and archive DB, then the command will be null. 
											if ( cmdAuditPrimaryInsert != null )
											{
												sSQL = "select AUDIT_ID        " + ControlChars.CrLf
												     + "  from " + sAUDIT_TABLE  + ControlChars.CrLf
												     + " where ID   = @ID      " + ControlChars.CrLf
												     + " order by AUDIT_VERSION" + ControlChars.CrLf;
												using ( IDbCommand cmdAudit = con.CreateCommand() )
												{
													cmdAudit.CommandText = sSQL;
													cmdAudit.CommandTimeout = 0;
													Sql.AddParameter(cmdAudit, "@ID", gID);
													((IDbDataAdapter)da).SelectCommand = cmdAudit;
													using ( DataTable dtAuditData = new DataTable() )
													{
														da.Fill(dtAuditData);
														foreach ( DataRow rowAudit in dtAuditData.Rows )
														{
															Guid gAUDIT_ID = Sql.ToGuid(rowAudit["AUDIT_ID"]);
															sb.Append(ArchiveMoveAuditData(Context, gAUDIT_ID, sAUDIT_TABLE, cmdAuditPrimaryInsert, cmdAuditCustomInsert));
														}
													}
												}
											}
											// 04/11/2018 Paul.  Move main record last just in case there is an error. 
											sb.Append(ArchiveMoveData(Context, gID, sTABLE_NAME, cmdPrimaryInsert, cmdCustomInsert));
										}
									}
								}
							}
						}
					}
				}
			}
			return sb.ToString();
		}

		public static void RunArchive(Object sender)
		{
			HttpContext Context = sender as HttpContext;
			if ( !bInsideArchive )
			{
				bInsideArchive = true;
				try
				{
					SplendidError.SystemMessage(Context, "Information", new StackTrace(true).GetFrame(0), "ArchiveExternalDB.RunArchive Begin");
					// 07/10/2018 Paul.  Before we run an archive, lets first test if we can connet to the archive database. 
					try
					{
						DbProviderFactory dbfArchive = DbAcrhiveFactories.GetFactory(Context.Application);
						using ( IDbConnection conArchive = dbfArchive.CreateConnection() )
						{
							conArchive.Open();
							string sSQL;
							sSQL = "select count(*)                 " + ControlChars.CrLf
							     + "  from INFORMATION_SCHEMA.TABLES" + ControlChars.CrLf;
							using ( IDbCommand cmd = conArchive.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								cmd.ExecuteScalar();
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), "Failed to connect to the external archive database: " + Utils.ExpandException(ex));
						return;
					}
					if ( !Sql.IsEmptyString(Context.Application["ArchiveConnectionString"]) )
					{
						if ( DateTime.Now > dtLastBuild.AddHours(6) )
						{
							dtLastBuild = DateTime.Now;
							string sBuildSQL = ArchiveBuildAll(Context);
							TimeSpan tsBuild = DateTime.Now - dtLastBuild;
							SplendidError.SystemMessage(Context, "Information", new StackTrace(true).GetFrame(0), "ArchiveExternalDB.RunArchive Build Complete in " + tsBuild.TotalMinutes.ToString() + " minutes");
						}
						//Debug.Write(sBuildSQL);
						string sMoveSQL = ArchiveRulesRunAll(Context);
						//Debug.Write(sMoveSQL);
					}
				}
				catch(Exception ex)
				{
					SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
				}
				finally
				{
					SplendidError.SystemMessage(Context, "Information", new StackTrace(true).GetFrame(0), "ArchiveExternalDB.RunArchive End");
					bInsideArchive = false;
				}
			}
		}
	}
}

