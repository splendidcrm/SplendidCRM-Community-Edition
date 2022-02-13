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

namespace SplendidCRM.Administration.DynamicLayout.DetailViews
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
				//sb.AppendLine("delete from DETAILVIEWS_FIELDS where DETAIL_NAME = '" + sNAME + "';");
				sb.AppendLine("update DETAILVIEWS_FIELDS set DELETED = 1, DATE_MODIFIED_UTC = getutcdate(), MODIFIED_USER_ID = null where DELETED = 0 and DETAIL_NAME = '" + sNAME + "';");
				
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select *                         " + ControlChars.CrLf
					     + "  from vwDETAILVIEWS_FIELDS      " + ControlChars.CrLf
					     + " where DETAIL_NAME = @DETAIL_NAME" + ControlChars.CrLf
					     + "   and DEFAULT_VIEW = 0          " + ControlChars.CrLf
					     + " order by FIELD_INDEX            " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@DETAIL_NAME", sNAME);
					
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dtFields = new DataTable() )
							{
								da.Fill(dtFields);
								if ( dtFields.Rows.Count > 0 )
								{
									int nFIELD_INDEX_Length = 2;
									int nDATA_LABEL_Length  = 4;
									int nDATA_FIELD_Length  = 4;
									int nDATA_FORMAT_Length = 4;
									int nLIST_NAME_Length   = 4;
									int nURL_FIELD_Length   = 4;
									int nURL_FORMAT_Length  = 4;
									int nURL_TARGET_Length  = 4;
									foreach(DataRow row in dtFields.Rows)
									{
										nFIELD_INDEX_Length = Math.Max(nFIELD_INDEX_Length, Sql.EscapeSQL(Sql.ToString(row["FIELD_INDEX"])).Length);
										nDATA_LABEL_Length  = Math.Max(nDATA_LABEL_Length , Sql.EscapeSQL(Sql.ToString(row["DATA_LABEL" ])).Length + 2);
										nDATA_FIELD_Length  = Math.Max(nDATA_FIELD_Length , Sql.EscapeSQL(Sql.ToString(row["DATA_FIELD" ])).Length + 2);
										nDATA_FORMAT_Length = Math.Max(nDATA_FORMAT_Length, Sql.EscapeSQL(Sql.ToString(row["DATA_FORMAT"])).Length + 2);
										nLIST_NAME_Length   = Math.Max(nLIST_NAME_Length  , Sql.EscapeSQL(Sql.ToString(row["LIST_NAME"  ])).Length + 2);
										nURL_FIELD_Length   = Math.Max(nURL_FIELD_Length  , Sql.EscapeSQL(Sql.ToString(row["URL_FIELD"  ])).Length + 2);
										nURL_FORMAT_Length  = Math.Max(nURL_FORMAT_Length , Sql.EscapeSQL(Sql.ToString(row["URL_FORMAT" ])).Length + 2);
										nURL_TARGET_Length  = Math.Max(nURL_TARGET_Length , Sql.EscapeSQL(Sql.ToString(row["URL_TARGET" ])).Length + 2);
									}

									sb.AppendLine("if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = '" + sNAME + "' and DELETED = 0) begin -- then");
									sb.AppendLine("	print 'DETAILVIEWS_FIELDS " + sNAME + "';");

									string sLABEL_WIDTH  = Sql.ToString(dtFields.Rows[0]["LABEL_WIDTH" ]);
									string sFIELD_WIDTH  = Sql.ToString(dtFields.Rows[0]["FIELD_WIDTH" ]);
									string sDATA_COLUMNS = Sql.ToString(dtFields.Rows[0]["DATA_COLUMNS"]);
									string sVIEW_NAME    = Sql.ToString(dtFields.Rows[0]["VIEW_NAME"   ]);
									string sMODULE_NAME  = Sql.ToString(dtFields.Rows[0]["MODULE_NAME" ]);
									if ( Sql.IsEmptyString(sDATA_COLUMNS) ) sDATA_COLUMNS = "null";
									sb.AppendLine("	exec dbo.spDETAILVIEWS_InsertOnly          '" + sNAME + "', " + Sql.FormatSQL(sMODULE_NAME, 0) + ", " + Sql.FormatSQL(sVIEW_NAME, 0) + ", " + Sql.FormatSQL(sLABEL_WIDTH, 0) + ", " + Sql.FormatSQL(sFIELD_WIDTH, 0) + ", " + sDATA_COLUMNS + ";");
									foreach(DataRow row in dtFields.Rows)
									{
										string sDETAIL_NAME = Sql.ToString(row["DETAIL_NAME"]);
										string sFIELD_INDEX = Sql.ToString(row["FIELD_INDEX"]);
										string sFIELD_TYPE  = Sql.ToString(row["FIELD_TYPE" ]);
										string sDATA_LABEL  = Sql.ToString(row["DATA_LABEL" ]);
										string sDATA_FIELD  = Sql.ToString(row["DATA_FIELD" ]);
										string sDATA_FORMAT = Sql.ToString(row["DATA_FORMAT"]);
										string sURL_FIELD   = Sql.ToString(row["URL_FIELD"  ]);
										string sURL_FORMAT  = Sql.ToString(row["URL_FORMAT" ]);
										string sURL_TARGET  = Sql.ToString(row["URL_TARGET" ]);
										string sLIST_NAME   = Sql.ToString(row["LIST_NAME"  ]);
										string sCOLSPAN     = Sql.ToString(row["COLSPAN"    ]);
										// 06/12/2009 Paul.  Add TOOL_TIP for help hover.
										string sTOOL_TIP    = Sql.ToString(row["TOOL_TIP"   ]);
										// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
										string sMODULE_TYPE = Sql.ToString(row["MODULE_TYPE"]);
										
										sFIELD_INDEX = Strings.Space(nFIELD_INDEX_Length - sFIELD_INDEX.Length) + sFIELD_INDEX;
										if ( Sql.IsEmptyString(sCOLSPAN          ) || sCOLSPAN        == "0" ) sCOLSPAN           = "null";
										switch ( sFIELD_TYPE )
										{
											case "Blank"     :  sb.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsBlank      '" + sDETAIL_NAME + "', " + sFIELD_INDEX + ", " + sCOLSPAN + ";");  break;
											case "CheckBox"  :  sb.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsCheckBox   '" + sDETAIL_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + sCOLSPAN + ";");  break;
											// 02/16/2010 Paul.  Add MODULE_TYPE so that we can lookup custom field IDs. 
											// 09/21/2012 Paul.  Fix parameters to spDETAILVIEWS_FIELDS_InsModuleLink. 
											// 04/08/2018 Paul.  Single quote needed to be removed. 
											case "ModuleLink":  sb.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsModuleLink '" + sDETAIL_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + Sql.FormatSQL(sDATA_FORMAT, nDATA_FORMAT_Length) + ", " + Sql.FormatSQL(sURL_FIELD, nURL_FIELD_Length) + ", " + Sql.FormatSQL(sURL_TARGET, nURL_TARGET_Length) + ", " + Sql.FormatSQL(sMODULE_TYPE, 0) + ", " + sCOLSPAN + ";");  break;
											case "HyperLink" :
												if ( Sql.IsEmptyString(sMODULE_TYPE) )
													            sb.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink  '" + sDETAIL_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + Sql.FormatSQL(sDATA_FORMAT, nDATA_FORMAT_Length) + ", " + Sql.FormatSQL(sURL_FIELD, nURL_FIELD_Length) + ", " + Sql.FormatSQL(sURL_FORMAT, nURL_FORMAT_Length) + ", " + Sql.FormatSQL(sURL_TARGET, nURL_TARGET_Length) + ", " + sCOLSPAN + ";");
												else
													            sb.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsModuleLink '" + sDETAIL_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + Sql.FormatSQL(sDATA_FORMAT, nDATA_FORMAT_Length) + ", " + Sql.FormatSQL(sURL_FIELD, nURL_FIELD_Length) + ", " + Sql.FormatSQL(sURL_TARGET, nURL_TARGET_Length) + ", " + Sql.FormatSQL(sMODULE_TYPE, 0) + ", " + sCOLSPAN + ";");
													break;
											case "String"    :
												if ( Sql.IsEmptyString(sLIST_NAME) )
												{
													if ( Sql.IsEmptyString(sMODULE_TYPE) )
														        sb.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsBound      '" + sDETAIL_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + Sql.FormatSQL(sDATA_FORMAT, nDATA_FORMAT_Length) + ", " + sCOLSPAN + ";");
													else
														        sb.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsModule     '" + sDETAIL_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + Sql.FormatSQL(sDATA_FORMAT, nDATA_FORMAT_Length) + ", '" + sMODULE_TYPE + "', " + sCOLSPAN + ";");
												}
												else
													            sb.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList  '" + sDETAIL_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sDATA_LABEL, nDATA_LABEL_Length) + ", " + Sql.FormatSQL(sDATA_FIELD, nDATA_FIELD_Length) + ", " + Sql.FormatSQL(sDATA_FORMAT, nDATA_FORMAT_Length) + ", " + Sql.FormatSQL(sLIST_NAME  , nLIST_NAME_Length  ) + ", " + sCOLSPAN + ";");
												break;
											default          :  sb.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly    '" + sDETAIL_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sFIELD_TYPE, 0) + ", " + Sql.FormatSQL(sDATA_LABEL, 0) + ", " + Sql.FormatSQL(sDATA_FIELD, 0) + ", " + Sql.FormatSQL(sDATA_FORMAT, 0) + ", " + Sql.FormatSQL(sURL_FIELD, 0) + ", " + Sql.FormatSQL(sURL_FORMAT, 0) + ", " + Sql.FormatSQL(sURL_TARGET, 0) + ", " + Sql.FormatSQL(sLIST_NAME, 0) + ", " + sCOLSPAN + ";");  break;
										}
										// 06/12/2009 Paul.  Add TOOL_TIP for help hover.
										if ( !Sql.IsEmptyString(sTOOL_TIP) )
										{
											// 09/20/2012 Paul.  Remove break at the end of the line. 
											sb.AppendLine("	exec dbo.spDETAILVIEWS_FIELDS_UpdateTip  null, '" + sDETAIL_NAME + "', " + sFIELD_INDEX + ", " + Sql.FormatSQL(sTOOL_TIP, 0) + ";");
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
				Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(Request.Browser, "DETAILVIEWS_FIELDS " + sNAME + ".1.sql"));
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

