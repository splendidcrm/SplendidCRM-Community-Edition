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
using System.Collections;
using System.Text;
using System.IO;
using System.Diagnostics;

namespace SplendidCRM.Administration.DynamicLayout.GridViews
{
	/// <summary>
	/// Summary description for Export.
	/// </summary>
	public class Export : System.Web.UI.Page
	{
		private void Page_Load(object sender, System.EventArgs e)
		{
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.GetUserAccess("DynamicLayout", "export") >= 0);
			if ( !this.Visible )
				return;
			
			string sNAME = Sql.ToString(Request["NAME"]);
			if ( !Sql.IsEmptyString(sNAME) )
			{
				StringBuilder sb = new StringBuilder();
				// 03/15/2018 Paul.  Mark record as deleted instead of deleting. 
				//sb.AppendLine("delete from GRIDVIEWS_COLUMNS where GRID_NAME = '" + sNAME + "';");
				sb.AppendLine("update GRIDVIEWS_COLUMNS set DELETED = 1, DATE_MODIFIED_UTC = getutcdate(), MODIFIED_USER_ID = null where DELETED = 0 and GRID_NAME = '" + sNAME + "';");
				
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select *                     " + ControlChars.CrLf
					     + "  from vwGRIDVIEWS_COLUMNS   " + ControlChars.CrLf
					     + " where GRID_NAME = @GRID_NAME" + ControlChars.CrLf
					     + "   and DEFAULT_VIEW = 0      " + ControlChars.CrLf
					     + " order by COLUMN_INDEX       " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@GRID_NAME", sNAME);
					
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dtFields = new DataTable() )
							{
								da.Fill(dtFields);
								if ( dtFields.Rows.Count > 0 )
								{
									int nCOLUMN_INDEX_Length    = 2;
									int nHEADER_TEXT_Length     = 4;
									int nDATA_FIELD_Length      = 4;
									int nDATA_FORMAT_Length     = 4;
									int nURL_FIELD_Length       = 4;
									int nURL_FORMAT_Length      = 4;
									int nURL_TARGET_Length      = 4;
									int nLIST_NAME_Length       = 4;
									int nSORT_EXPRESSION_Length = 4;
									foreach(DataRow row in dtFields.Rows)
									{
										nCOLUMN_INDEX_Length    = Math.Max(nCOLUMN_INDEX_Length   , Sql.EscapeSQL(Sql.ToString(row["COLUMN_INDEX"   ])).Length);
										nHEADER_TEXT_Length     = Math.Max(nHEADER_TEXT_Length    , Sql.EscapeSQL(Sql.ToString(row["HEADER_TEXT"    ])).Length + 2);
										nDATA_FIELD_Length      = Math.Max(nDATA_FIELD_Length     , Sql.EscapeSQL(Sql.ToString(row["DATA_FIELD"     ])).Length + 2);
										nDATA_FORMAT_Length     = Math.Max(nDATA_FORMAT_Length    , Sql.EscapeSQL(Sql.ToString(row["DATA_FORMAT"    ])).Length + 2);
										nURL_FIELD_Length       = Math.Max(nURL_FIELD_Length      , Sql.EscapeSQL(Sql.ToString(row["URL_FIELD"      ])).Length + 2);
										nURL_FORMAT_Length      = Math.Max(nURL_FORMAT_Length     , Sql.EscapeSQL(Sql.ToString(row["URL_FORMAT"     ])).Length + 2);
										nURL_TARGET_Length      = Math.Max(nURL_TARGET_Length     , Sql.EscapeSQL(Sql.ToString(row["URL_TARGET"     ])).Length + 2);
										nLIST_NAME_Length       = Math.Max(nLIST_NAME_Length      , Sql.EscapeSQL(Sql.ToString(row["LIST_NAME"      ])).Length + 2);
										nSORT_EXPRESSION_Length = Math.Max(nSORT_EXPRESSION_Length, Sql.EscapeSQL(Sql.ToString(row["SORT_EXPRESSION"])).Length + 2);
									}

									sb.AppendLine("if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = '" + sNAME + "' and DELETED = 0) begin -- then");
									sb.AppendLine("	print 'GRIDVIEWS_COLUMNS " + sNAME + "';");

									string sVIEW_NAME    = Sql.ToString(dtFields.Rows[0]["VIEW_NAME"   ]);
									string sMODULE_NAME  = Sql.ToString(dtFields.Rows[0]["MODULE_NAME" ]);
									sb.AppendLine("	exec dbo.spGRIDVIEWS_InsertOnly           '" + sNAME + "', " + Sql.FormatSQL(sMODULE_NAME, 0) + ", " + Sql.FormatSQL(sVIEW_NAME, 0) + ";");
									foreach(DataRow row in dtFields.Rows)
									{
										string sGRID_NAME                  = Sql.ToString(row["GRID_NAME"                 ]);
										string sCOLUMN_INDEX               = Sql.ToString(row["COLUMN_INDEX"              ]);
										string sCOLUMN_TYPE                = Sql.ToString(row["COLUMN_TYPE"               ]);
										string sHEADER_TEXT                = Sql.ToString(row["HEADER_TEXT"               ]);
										string sSORT_EXPRESSION            = Sql.ToString(row["SORT_EXPRESSION"           ]);
										string sITEMSTYLE_WIDTH            = Sql.ToString(row["ITEMSTYLE_WIDTH"           ]);
										string sITEMSTYLE_CSSCLASS         = Sql.ToString(row["ITEMSTYLE_CSSCLASS"        ]);
										string sITEMSTYLE_HORIZONTAL_ALIGN = Sql.ToString(row["ITEMSTYLE_HORIZONTAL_ALIGN"]);
										string sITEMSTYLE_VERTICAL_ALIGN   = Sql.ToString(row["ITEMSTYLE_VERTICAL_ALIGN"  ]);
										string sITEMSTYLE_WRAP             = Sql.ToString(row["ITEMSTYLE_WRAP"            ]);
										string sDATA_FIELD                 = Sql.ToString(row["DATA_FIELD"                ]);
										string sDATA_FORMAT                = Sql.ToString(row["DATA_FORMAT"               ]);
										string sURL_FIELD                  = Sql.ToString(row["URL_FIELD"                 ]);
										string sURL_FORMAT                 = Sql.ToString(row["URL_FORMAT"                ]);
										string sURL_TARGET                 = Sql.ToString(row["URL_TARGET"                ]);
										string sLIST_NAME                  = Sql.ToString(row["LIST_NAME"                 ]);
										string sURL_MODULE                 = Sql.ToString(row["URL_MODULE"                ]);
										string sURL_ASSIGNED_FIELD         = Sql.ToString(row["URL_ASSIGNED_FIELD"        ]);
										// 04/05/2018 Paul.  Module Type is a separate field that requires a separate procedure. 
										string sMODULE_TYPE                = Sql.ToString(row["MODULE_TYPE"               ]);

										sCOLUMN_INDEX = Strings.Space(nCOLUMN_INDEX_Length - sCOLUMN_INDEX.Length) + sCOLUMN_INDEX;
										switch ( sCOLUMN_TYPE )
										{
											case "TemplateColumn":
												// 04/05/2018 Paul.  Module Type is a separate field that requires a separate procedure. 
												if ( sDATA_FORMAT == "HyperLink" && !Sql.IsEmptyString(sMODULE_TYPE) )
													sb.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsModule    '" + sGRID_NAME + "', " + sCOLUMN_INDEX + ", " + Sql.FormatSQL(sHEADER_TEXT, nHEADER_TEXT_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + Sql.FormatSQL(sSORT_EXPRESSION, nSORT_EXPRESSION_Length) + ", " + Sql.FormatSQL(sITEMSTYLE_WIDTH, 0) +", " + Sql.FormatSQL(sITEMSTYLE_CSSCLASS, 0) + ", " + Sql.FormatSQL(sURL_FIELD, nURL_FIELD_Length) + ", " + Sql.FormatSQL(sURL_FORMAT, nURL_FORMAT_Length) + ", " + Sql.FormatSQL(sURL_TARGET, nURL_TARGET_Length) + ", " + Sql.FormatSQL(sURL_MODULE, 0) + ", " + Sql.FormatSQL(sURL_ASSIGNED_FIELD, 0) + ";");
												else if ( sDATA_FORMAT == "HyperLink" )
													sb.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink '" + sGRID_NAME + "', " + sCOLUMN_INDEX + ", " + Sql.FormatSQL(sHEADER_TEXT, nHEADER_TEXT_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + Sql.FormatSQL(sSORT_EXPRESSION, nSORT_EXPRESSION_Length) + ", " + Sql.FormatSQL(sITEMSTYLE_WIDTH, 0) +", " + Sql.FormatSQL(sITEMSTYLE_CSSCLASS, 0) + ", " + Sql.FormatSQL(sURL_FIELD, nURL_FIELD_Length) + ", " + Sql.FormatSQL(sURL_FORMAT, nURL_FORMAT_Length) + ", " + Sql.FormatSQL(sURL_TARGET, nURL_TARGET_Length) + ", " + Sql.FormatSQL(sURL_MODULE, 0) + ", " + Sql.FormatSQL(sURL_ASSIGNED_FIELD, 0) + ";");
												else
													sb.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate '" + sGRID_NAME + "', " + sCOLUMN_INDEX + ", " + Sql.FormatSQL(sHEADER_TEXT, nHEADER_TEXT_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + Sql.FormatSQL(sSORT_EXPRESSION, nSORT_EXPRESSION_Length) + ", " + Sql.FormatSQL(sITEMSTYLE_WIDTH, 0) +", " + Sql.FormatSQL(sDATA_FORMAT, 0) + ";");
												break;
											case "BoundColumn"   :
												if ( !Sql.IsEmptyString(sLIST_NAME) )
													sb.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList '" + sGRID_NAME + "', " + sCOLUMN_INDEX + ", " + Sql.FormatSQL(sHEADER_TEXT, nHEADER_TEXT_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + Sql.FormatSQL(sSORT_EXPRESSION, nSORT_EXPRESSION_Length) + ", " + Sql.FormatSQL(sITEMSTYLE_WIDTH, 0) +", " + Sql.FormatSQL(sLIST_NAME, nLIST_NAME_Length) +";");
												// 01/11/2018 Paul.  Often the layout is configured as Bound / Date instead of Template / Date. 
												else if ( sDATA_FORMAT == "Date" || sDATA_FORMAT == "DateTime" )
													sb.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate '" + sGRID_NAME + "', " + sCOLUMN_INDEX + ", " + Sql.FormatSQL(sHEADER_TEXT, nHEADER_TEXT_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + Sql.FormatSQL(sSORT_EXPRESSION, nSORT_EXPRESSION_Length) + ", " + Sql.FormatSQL(sITEMSTYLE_WIDTH, 0) +", " + Sql.FormatSQL(sDATA_FORMAT, 0) + ";");
												else
													sb.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     '" + sGRID_NAME + "', " + sCOLUMN_INDEX + ", " + Sql.FormatSQL(sHEADER_TEXT, nHEADER_TEXT_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + Sql.FormatSQL(sSORT_EXPRESSION, nSORT_EXPRESSION_Length) + ", " + Sql.FormatSQL(sITEMSTYLE_WIDTH, 0) +";");
												break;
										}
									}
									foreach(DataRow row in dtFields.Rows)
									{
										string sGRID_NAME                  = Sql.ToString(row["GRID_NAME"                 ]);
										string sCOLUMN_INDEX               = Sql.ToString(row["COLUMN_INDEX"              ]);
										string sITEMSTYLE_WIDTH            = Sql.ToString(row["ITEMSTYLE_WIDTH"           ]);
										string sITEMSTYLE_CSSCLASS         = Sql.ToString(row["ITEMSTYLE_CSSCLASS"        ]);
										string sITEMSTYLE_HORIZONTAL_ALIGN = Sql.ToString(row["ITEMSTYLE_HORIZONTAL_ALIGN"]);
										string sITEMSTYLE_VERTICAL_ALIGN   = Sql.ToString(row["ITEMSTYLE_VERTICAL_ALIGN"  ]);
										string sITEMSTYLE_WRAP             = Sql.ToString(row["ITEMSTYLE_WRAP"            ]);
										sCOLUMN_INDEX = Strings.Space(nCOLUMN_INDEX_Length - sCOLUMN_INDEX.Length) + sCOLUMN_INDEX;
										if ( !Sql.IsEmptyString(sITEMSTYLE_HORIZONTAL_ALIGN) )
										{
											// 10/02/2013 Paul.  Need to format the SQL so that values get quoted. 
											sb.AppendLine("	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, '" + sGRID_NAME + "', " + sCOLUMN_INDEX + ", " + Sql.FormatSQL(sITEMSTYLE_WIDTH, 0) + ", " + Sql.FormatSQL(sITEMSTYLE_CSSCLASS, 0) + ", " + Sql.FormatSQL(sITEMSTYLE_HORIZONTAL_ALIGN, 0) + ", " + Sql.FormatSQL(sITEMSTYLE_VERTICAL_ALIGN, 0) + ", " + (Sql.ToBoolean(sITEMSTYLE_WRAP) ? "1" : "0") + ";");
										}
									}
									sb.AppendLine("end -- if;");
								}
							}
						}
					}
				}
				sb.AppendLine("GO");
				sb.AppendLine("");
				Response.ContentType = "text/txt";
				// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
				// 02/16/2010 Paul.  Must include all parts of the name in the encoding. 
				Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(Request.Browser, "GRIDVIEWS_COLUMNS " + sNAME + ".1.sql"));
				Response.Write(sb.ToString());
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
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{    
			this.Load += new System.EventHandler(this.Page_Load);
		}
		#endregion
	}
}

