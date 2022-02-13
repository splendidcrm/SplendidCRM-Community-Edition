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
using System.Data;
using System.Data.Common;
using System.Drawing;
using System.Web;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Collections.Generic;
using System.Diagnostics;

namespace SplendidCRM._controls
{
	/// <summary>
	///		Summary description for MassUpdate.
	/// </summary>
	public class DynamicMassUpdate : SplendidCRM.MassUpdate
	{
		protected _controls.MassUpdateButtons ctlDynamicButtons;

		protected HtmlTable           tblMain ;
		public    CommandEventHandler Command ;

		public string Module
		{
			get
			{
				return m_sMODULE;
			}
			set
			{
				m_sMODULE = value;
			}
		}

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
			if ( Command != null )
			{
				if ( e.CommandName == "MassUpdate" )
				{
					CommandEventArgs eDynamic = new CommandEventArgs("DynamicMassUpdate", e.CommandArgument);
					Command(this, eDynamic);
				}
				// 07/29/2018 Paul.  All other commands must pass through. 
				else
				{
					Command(this, e);
				}
			}
		}

		public void Update(System.Collections.Stack stk)
		{
			if ( stk.Count > 0 )
			{
				DataTable dtFields = SplendidCache.EditViewFields(m_sMODULE + ".MassUpdate", Security.PRIMARY_ROLE_NAME);
				DataView vwFields = new DataView(dtFields);
				vwFields.RowFilter = "DATA_FIELD is not null";
				if ( vwFields.Count > 0 )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sTABLE_NAME = Crm.Modules.TableName(m_sMODULE);
						using ( DataTable dtData = new DataTable() )
						{
							string sSQL;
							sSQL = "select *"                + ControlChars.CrLf
							     + "  from vw" + sTABLE_NAME + ControlChars.CrLf
							     + " where 1 = 1"            + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								List<Guid> arr = new List<Guid>();
								while ( stk.Count > 0 )
								{
									Guid gID = Sql.ToGuid(stk.Pop());
									arr.Add(gID);
								}
								Sql.AppendParameter(cmd, arr.ToArray(), "ID");
								using ( DbDataAdapter da = dbf.CreateDataAdapter() )
								{
									((IDbDataAdapter)da).SelectCommand = cmd;
									da.Fill(dtData);
								}
							}
							if ( dtData.Rows.Count > 0 )
							{
								IDbCommand cmdImport = null;
								cmdImport = SqlProcs.Factory(con, "sp" + sTABLE_NAME + "_Update");

								DataTable dtColumns = new DataTable();
								dtColumns.Columns.Add("ColumnName"  , Type.GetType("System.String"));
								dtColumns.Columns.Add("NAME"        , Type.GetType("System.String"));
								dtColumns.Columns.Add("DISPLAY_NAME", Type.GetType("System.String"));
								dtColumns.Columns.Add("ColumnType"  , Type.GetType("System.String"));
								dtColumns.Columns.Add("Size"        , Type.GetType("System.Int32" ));
								dtColumns.Columns.Add("Scale"       , Type.GetType("System.Int32" ));
								dtColumns.Columns.Add("Precision"   , Type.GetType("System.Int32" ));
								dtColumns.Columns.Add("colid"       , Type.GetType("System.Int32" ));
								dtColumns.Columns.Add("CustomField" , Type.GetType("System.Boolean"));
								for ( int i =0; i < cmdImport.Parameters.Count; i++ )
								{
									IDbDataParameter par = cmdImport.Parameters[i] as IDbDataParameter;
									DataRow row = dtColumns.NewRow();
									dtColumns.Rows.Add(row);
									row["ColumnName"  ] = par.ParameterName;
									row["NAME"        ] = Sql.ExtractDbName(cmdImport, par.ParameterName);
									row["DISPLAY_NAME"] = row["NAME"];
									row["ColumnType"  ] = par.DbType.ToString();
									row["Size"        ] = par.Size         ;
									row["Scale"       ] = par.Scale        ;
									row["Precision"   ] = par.Precision    ;
									row["colid"       ] = i                ;
									row["CustomField" ] = false            ;
								}
								sSQL = "select *                       " + ControlChars.CrLf
								     + "  from vwSqlColumns            " + ControlChars.CrLf
								     + " where ObjectName = @OBJECTNAME" + ControlChars.CrLf
								     + "   and ColumnName <> 'ID_C'    " + ControlChars.CrLf
								     + " order by colid                " + ControlChars.CrLf;
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.CommandText = sSQL;
									Sql.AddParameter(cmd, "@OBJECTNAME", Sql.MetadataName(cmd, sTABLE_NAME + "_CSTM"));
									using ( DbDataAdapter da = dbf.CreateDataAdapter() )
									{
										((IDbDataAdapter)da).SelectCommand = cmd;
										DataTable dtCSTM = new DataTable();
										da.Fill(dtCSTM);
										foreach ( DataRow rowCSTM in dtCSTM.Rows )
										{
											DataRow row = dtColumns.NewRow();
											row["ColumnName"  ] = Sql.ToString (rowCSTM["ColumnName"]);
											row["NAME"        ] = Sql.ToString (rowCSTM["ColumnName"]);
											row["DISPLAY_NAME"] = Sql.ToString (rowCSTM["ColumnName"]);
											row["ColumnType"  ] = Sql.ToString (rowCSTM["CsType"    ]);
											row["Size"        ] = Sql.ToInteger(rowCSTM["length"    ]);
											row["colid"       ] = dtColumns.Rows.Count;
											row["CustomField" ] = true;
											dtColumns.Rows.Add(row);
										}
									}
								}
								DataView vwColumns = new DataView(dtColumns);
								IDbCommand cmdImportCSTM = null;
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
										string sNAME   = Sql.ToString(row["ColumnName"]).ToUpper();
										string sCsType = Sql.ToString(row["ColumnType"]);
										int    nMAX_SIZE = Sql.ToInteger(row["Size"]);
										if ( nFieldIndex == 0 )
											cmdImportCSTM.CommandText += "   set ";
										else
											cmdImportCSTM.CommandText += "     , ";
										cmdImportCSTM.CommandText += sNAME + " = @" + sNAME + ControlChars.CrLf;
										
										IDbDataParameter par = null;
										switch ( sCsType )
										{
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
									cmdImportCSTM.CommandText += " where ID_C = @ID_C" + ControlChars.CrLf;
									Sql.AddParameter(cmdImportCSTM, "@ID_C", Guid.Empty);
								}
								vwColumns.RowFilter = "";
								Dictionary<string, object> dictValues = new Dictionary<string,object>();
								Dictionary<string, string> dictTypes  = new Dictionary<string,string>();
								foreach ( DataRowView rowField in vwFields )
								{
									string sDATA_FIELD = Sql.ToString(rowField["DATA_FIELD"]).ToUpper();
									vwColumns.RowFilter = "NAME = '" + sDATA_FIELD +"'";
									if ( vwColumns.Count > 0 )
									{
										string sCsType  = Sql.ToString(vwColumns[0]["ColumnType"]);
										if ( (sDATA_FIELD == "ASSIGNED_USER_ID" || sDATA_FIELD == "ASSIGNED_TO" || sDATA_FIELD == "ASSIGNED_TO_NAME" || sDATA_FIELD == "ASSIGNED_SET_NAME") && Crm.Config.enable_dynamic_assignment() )
										{
											UserSelect ctlUserSelect = FindControl("ASSIGNED_SET_NAME") as UserSelect;
											if ( ctlUserSelect != null )
											{
												if ( !Sql.IsEmptyString(ctlUserSelect.ASSIGNED_SET_LIST) )
												{
													if ( !dictValues.ContainsKey("ASSIGNED_SET_LIST") )
													{
														dictValues.Add("ASSIGNED_SET_LIST", ctlUserSelect.ASSIGNED_SET_LIST);
														dictTypes .Add("ASSIGNED_SET_LIST", "string");
													}
													if ( !dictValues.ContainsKey("ASSIGNED_USER_ID") && (!Sql.IsEmptyGuid(ctlUserSelect.PRIMARY_USER_ID) || !ctlUserSelect.ADD_USER_SET) )
													{
														if ( !ctlUserSelect.ADD_USER_SET )
															dictValues.Add("ASSIGNED_USER_ID", ctlUserSelect.USER_ID);
														else
															dictValues.Add("ASSIGNED_USER_ID", ctlUserSelect.PRIMARY_USER_ID);
														dictTypes .Add("ASSIGNED_USER_ID", "Guid");
													}
													if ( !dictValues.ContainsKey("ADD_USER_SET") )
													{
														dictValues.Add("ADD_USER_SET", ctlUserSelect.ADD_USER_SET);
														dictTypes .Add("ADD_USER_SET", "bool");
													}
												}
											}
											else
											{
												object objValue = new DynamicControl(this, "ASSIGNED_USER_ID").ID;
												if ( !Sql.IsEmptyGuid(objValue) )
												{
													dictValues.Add("ASSIGNED_USER_ID", objValue);
													dictTypes .Add("ASSIGNED_USER_ID", "Guid");
												}
											}
										}
										else if ( (sDATA_FIELD == "TEAM_ID" || sDATA_FIELD == "TEAM_SET_NAME") && Crm.Config.enable_team_management() && Crm.Config.enable_dynamic_teams() )
										{
											TeamSelect ctlTeamSelect = FindControl("TEAM_SET_NAME") as TeamSelect;
											if ( ctlTeamSelect != null )
											{
												if ( !Sql.IsEmptyString(ctlTeamSelect.TEAM_SET_LIST) )
												{
													if ( !dictValues.ContainsKey("TEAM_SET_LIST") )
													{
														dictValues.Add("TEAM_SET_LIST", ctlTeamSelect.TEAM_SET_LIST);
														dictTypes .Add("TEAM_SET_LIST", "string");
													}
													if ( !dictValues.ContainsKey("TEAM_ID") && (!Sql.IsEmptyGuid(ctlTeamSelect.PRIMARY_TEAM_ID) || !ctlTeamSelect.ADD_TEAM_SET) )
													{
														if ( !ctlTeamSelect.ADD_TEAM_SET )
															dictValues.Add("TEAM_ID", ctlTeamSelect.TEAM_ID);
														else
															dictValues.Add("TEAM_ID", ctlTeamSelect.PRIMARY_TEAM_ID);
														dictTypes .Add("TEAM_ID", "Guid");
													}
													if ( !dictValues.ContainsKey("ADD_TEAM_SET") )
													{
														dictValues.Add("ADD_TEAM_SET", ctlTeamSelect.ADD_TEAM_SET);
														dictTypes .Add("ADD_TEAM_SET", "bool");
													}
												}
											}
											else
											{
												object objValue = new DynamicControl(this, "TEAM_ID").ID;
												if ( !Sql.IsEmptyGuid(objValue) )
												{
													dictValues.Add("TEAM_ID", objValue);
													dictTypes .Add("TEAM_ID", "Guid");
												}
											}
										}
										else if ( sDATA_FIELD == "TAG_SET_NAME" )
										{
											TagSelect ctlTagSelect = FindControl("TAG_SET_NAME") as TagSelect;
											if ( ctlTagSelect != null )
											{
												if ( !Sql.IsEmptyString(ctlTagSelect.TAG_SET_NAME) )
												{
													if ( !dictValues.ContainsKey("TAG_SET_NAME") )
													{
														dictValues.Add("TAG_SET_NAME", ctlTagSelect.TAG_SET_NAME);
														dictTypes .Add("TAG_SET_NAME", "string");
													}
													if ( !dictValues.ContainsKey("ADD_TAG_SET") )
													{
														dictValues.Add("ADD_TAG_SET", ctlTagSelect.ADD_TAG_SET);
														dictTypes .Add("ADD_TAG_SET", "bool");
													}
												}
											}
										}
										else if ( sDATA_FIELD == "NAICS_SET_NAME" )
										{
											NAICSCodeSelect ctlNaicsSelect = FindControl("NAICS_SET_NAME") as NAICSCodeSelect;
											if ( ctlNaicsSelect != null )
											{
												if ( !Sql.IsEmptyString(ctlNaicsSelect.NAICS_SET_NAME) )
												{
													if ( !dictValues.ContainsKey("NAICS_SET_NAME"))
													{
														dictValues.Add("NAICS_SET_NAME", ctlNaicsSelect.NAICS_SET_NAME);
														dictTypes .Add("NAICS_SET_NAME", "string");
													}
													if ( !dictValues.ContainsKey("ADD_NAICS_CODE_SET") )
													{
														dictValues.Add("ADD_NAICS_CODE_SET", ctlNaicsSelect.ADD_NAICS_CODE_SET);
														dictTypes .Add("ADD_NAICS_CODE_SET", "bool");
													}
												}
											}
										}
										else if ( sDATA_FIELD == "KBTAG_SET_LIST" )
										{
											KBTagSelect ctlTagSelect = FindControl("KBTAG_SET_LIST") as KBTagSelect;
											if ( ctlTagSelect != null )
											{
												if ( !Sql.IsEmptyString(ctlTagSelect.KBTAG_SET_LIST) )
												{
													if ( !dictValues.ContainsKey("KBTAG_SET_LIST") )
													{
														dictValues.Add("KBTAG_SET_LIST", ctlTagSelect.KBTAG_SET_LIST);
														dictTypes .Add("KBTAG_SET_LIST", "string");
													}
													if ( !dictValues.ContainsKey("ADD_KBTAG_SET") )
													{
														dictValues.Add("ADD_KBTAG_SET", ctlTagSelect.ADD_KBTAG_SET);
														dictTypes .Add("ADD_KBTAG_SET", "bool");
													}
												}
											}
										}
										else
										{
											object objValue = new DynamicControl(this, sDATA_FIELD).Text;
											if ( !Sql.IsEmptyString(objValue) )
											{
												switch ( sCsType )
												{
													case "Guid"    :  objValue = new DynamicControl(this, sDATA_FIELD).ID          ;  break;
													case "short"   :  objValue = new DynamicControl(this, sDATA_FIELD).IntegerValue;  break;
													case "Int32"   :  objValue = new DynamicControl(this, sDATA_FIELD).IntegerValue;  break;
													case "Int64"   :  objValue = new DynamicControl(this, sDATA_FIELD).IntegerValue;  break;
													case "float"   :  objValue = new DynamicControl(this, sDATA_FIELD).FloatValue  ;  break;
													case "decimal" :  objValue = new DynamicControl(this, sDATA_FIELD).DecimalValue;  break;
													case "bool"    :  objValue = new DynamicControl(this, sDATA_FIELD).Checked     ;  break;
													case "DateTime":  objValue = new DynamicControl(this, sDATA_FIELD).DateValue   ;  break;
													default        :  objValue = new DynamicControl(this, sDATA_FIELD).Text        ;  break;
												}
												if ( !dictValues.ContainsKey(sDATA_FIELD) )
												{
													dictValues.Add(sDATA_FIELD, objValue);
													dictTypes .Add(sDATA_FIELD, sCsType);
												}
											}
										}
									}
								}
								vwColumns.RowFilter = "";
//#if DEBUG
//								foreach ( string fld in dictValues.Keys )
//								{
//									Debug.WriteLine(fld + " = " + Sql.ToString(dictValues[fld]));
//								}
//#endif
								
								using ( IDbTransaction trn = Sql.BeginTransaction(con) )
								{
									cmdImport.Transaction = trn;
									if ( cmdImportCSTM != null )
										cmdImportCSTM.Transaction = trn;
									try
									{
										int nRowNumber = 0;
										foreach ( DataRow row in dtData.Rows )
										{
											if ( !Response.IsClientConnected )
											{
												break;
											}
											Guid gID = Sql.ToGuid(row["ID"]);
											foreach ( IDbDataParameter par in cmdImport.Parameters )
											{
												par.Value = DBNull.Value;
											}
											if ( cmdImportCSTM != null )
											{
												foreach ( IDbDataParameter par in cmdImportCSTM.Parameters )
												{
													par.Value = DBNull.Value;
												}
											}
											Sql.SetParameter(cmdImport, "@MODIFIED_USER_ID", Security.USER_ID);
											foreach ( DataColumn col in dtData.Columns )
											{
												string sName = col.ColumnName;
												IDbDataParameter par = Sql.FindParameter(cmdImport, sName);
												if ( par != null )
												{
													par.Value = row[sName];
													if ( dictValues.ContainsKey(sName) )
													{
														string sCsType = "string";
														if ( dictTypes.ContainsKey(sName) )
															sCsType = dictTypes[sName];
														if ( sName == "TEAM_SET_LIST" && Crm.Config.enable_dynamic_teams() )
														{
															if ( Sql.ToBoolean(dictValues["ADD_TEAM_SET"]) )
															{
																if ( !Sql.IsEmptyString(par.Value) )
																	par.Value = Sql.ToString(par.Value) + "," + Sql.ToString(dictValues[sName]);
																else
																	par.Value = Sql.ToString(dictValues[sName]);
															}
															else
															{
																par.Value = Sql.ToString(dictValues[sName]);
															}
														}
														else if ( sName == "ASSIGNED_SET_LIST" && Crm.Config.enable_dynamic_assignment() )
														{
															if ( Sql.ToBoolean(dictValues["ADD_USER_SET"]) )
															{
																if ( !Sql.IsEmptyString(par.Value) )
																	par.Value = Sql.ToString(par.Value) + "," + Sql.ToString(dictValues[sName]);
																else
																	par.Value = Sql.ToString(dictValues[sName]);
															}
															else
															{
																par.Value = Sql.ToString(dictValues[sName]);
															}
														}
														else if ( sName == "TAG_SET_NAME" )
														{
															if ( Sql.ToBoolean(dictValues["ADD_TAG_SET"]) )
															{
																if ( !Sql.IsEmptyString(par.Value) )
																	par.Value = Sql.ToString(par.Value) + "," + Sql.ToString(dictValues[sName]);
																else
																	par.Value = Sql.ToString(dictValues[sName]);
															}
															else
															{
																par.Value = Sql.ToString(dictValues[sName]);
															}
														}
														else if ( sName == "NAICS_SET_NAME" )
														{
															if ( Sql.ToBoolean(dictValues["ADD_NAICS_CODE_SET"]) )
															{
																if ( !Sql.IsEmptyString(par.Value) )
																	par.Value = Sql.ToString(par.Value) + "," + Sql.ToString(dictValues[sName]);
																else
																	par.Value = Sql.ToString(dictValues[sName]);
															}
															else
															{
																par.Value = Sql.ToString(dictValues[sName]);
															}
														}
														else if ( sName == "KBTAG_SET_LIST" )
														{
															if ( Sql.ToBoolean(dictValues["ADD_KBTAG_SET"]) )
															{
																if ( !Sql.IsEmptyString(par.Value) )
																	par.Value = Sql.ToString(par.Value) + "," + Sql.ToString(dictValues[sName]);
																else
																	par.Value = Sql.ToString(dictValues[sName]);
															}
															else
															{
																par.Value = Sql.ToString(dictValues[sName]);
															}
														}
														else
														{
															switch ( sCsType )
															{
																case "Guid"    :  par.Value = Sql.ToDBGuid    (dictValues[sName]);  break;
																case "short"   :  par.Value = Sql.ToDBInteger (dictValues[sName]);  break;
																case "Int32"   :  par.Value = Sql.ToDBInteger (dictValues[sName]);  break;
																case "Int64"   :  par.Value = Sql.ToDBInteger (dictValues[sName]);  break;
																case "float"   :  par.Value = Sql.ToDBFloat   (dictValues[sName]);  break;
																case "decimal" :  par.Value = Sql.ToDBDecimal (dictValues[sName]);  break;
																case "bool"    :  par.Value = Sql.ToDBBoolean (dictValues[sName]);  break;
																case "DateTime":  par.Value = Sql.ToDBDateTime(dictValues[sName]);  break;
																default        :  par.Value = Sql.ToDBString  (dictValues[sName]);  break;
															}
														}
//#if DEBUG
//														Debug.WriteLine(sName + " (old) = " + Sql.ToString(row[sName]));
//														Debug.WriteLine(sName + " (new) = " + Sql.ToString(par.Value));
//#endif
													}
												}
												else if ( cmdImportCSTM != null )
												{
													par = Sql.FindParameter(cmdImportCSTM, sName);
													if ( par != null )
													{
														par.Value = row[sName];
														if ( dictValues.ContainsKey(sName) )
														{
															string sCsType = "string";
															if ( dictTypes.ContainsKey(sName) )
																sCsType = dictTypes[sName];
															switch ( sCsType )
															{
																case "Guid"    :  par.Value = Sql.ToDBGuid    (dictValues[sName]);  break;
																case "short"   :  par.Value = Sql.ToDBInteger (dictValues[sName]);  break;
																case "Int32"   :  par.Value = Sql.ToDBInteger (dictValues[sName]);  break;
																case "Int64"   :  par.Value = Sql.ToDBInteger (dictValues[sName]);  break;
																case "float"   :  par.Value = Sql.ToDBFloat   (dictValues[sName]);  break;
																case "decimal" :  par.Value = Sql.ToDBDecimal (dictValues[sName]);  break;
																case "bool"    :  par.Value = Sql.ToDBBoolean (dictValues[sName]);  break;
																case "DateTime":  par.Value = Sql.ToDBDateTime(dictValues[sName]);  break;
																default        :  par.Value = Sql.ToDBString  (dictValues[sName]);  break;
															}
//#if DEBUG
//															Debug.WriteLine(sName + " (old) = " + Sql.ToString(row[sName]));
//															Debug.WriteLine(sName + " (new) = " + Sql.ToString(par.Value));
//#endif
														}
													}
												}
											}
											cmdImport.ExecuteNonQuery();
											if ( cmdImportCSTM != null )
											{
												Sql.SetParameter(cmdImportCSTM, "ID_C", gID);
												cmdImportCSTM.ExecuteNonQuery();
											}
											nRowNumber++;
										}
										trn.Commit();
										// 04/03/2018 Paul.  Redirect after update means that we cannot display a success message. 
										//ctlDynamicButtons.ErrorText = String.Format(L10n.Term("RulesWizard.LBL_SUCCESSFULLY" ), nRowNumber);
									}
									catch(Exception ex)
									{
										trn.Rollback();
										ctlDynamicButtons.ErrorText = ex.Message;
										throw(new Exception(ex.Message, ex.InnerException));
									}
								}
							}
						}
					}
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			try
			{
				if ( !IsPostBack && Crm.Config.enable_dynamic_mass_update() )
				{
					int nACLACCESS_Delete = Security.GetUserAccess(m_sMODULE, "delete");
					int nACLACCESS_Edit   = Security.GetUserAccess(m_sMODULE, "edit"  );
					ctlDynamicButtons.ShowButton("MassUpdate", nACLACCESS_Edit   >= 0);
					ctlDynamicButtons.ShowButton("MassDelete", nACLACCESS_Delete >= 0);
					int nACLACCESS_Archive = Security.GetUserAccess(m_sMODULE, "archive");
					ctlDynamicButtons.ShowButton("Archive.MoveData"   , (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) && !ArchiveView() && ArchiveEnabled());
					ctlDynamicButtons.ShowButton("Archive.RecoverData", (nACLACCESS_Archive >= ACL_ACCESS.ARCHIVE || Security.IS_ADMIN) &&  ArchiveView() && ArchiveEnabled());
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
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
			if ( Crm.Config.enable_dynamic_mass_update() )
			{
				ctlDynamicButtons.AppendButtons(m_sMODULE + ".MassUpdate" + (ArchiveView() ? ".ArchiveView" : String.Empty), Guid.Empty, null);
				ctlDynamicButtons.ShowButton("Sync"  , SplendidCRM.Crm.Modules.ExchangeFolders(m_sMODULE) && Security.HasExchangeAlias());
				ctlDynamicButtons.ShowButton("Unsync", SplendidCRM.Crm.Modules.ExchangeFolders(m_sMODULE) && Security.HasExchangeAlias());
				this.AppendEditViewFields(m_sMODULE + ".MassUpdate", tblMain, null);
			}
		}
		#endregion
	}
}

