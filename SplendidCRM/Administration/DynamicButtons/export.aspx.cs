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

namespace SplendidCRM.Administration.DynamicButtons
{
	/// <summary>
	/// Summary description for Export.
	/// </summary>
	public class Export : System.Web.UI.Page
	{
		private void Page_Load(object sender, System.EventArgs e)
		{
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.AdminUserAccess("DynamicButtons", "export") >= 0);
			if ( !this.Visible )
				return;
			
			string sNAME = Sql.ToString(Request["NAME"]);
			if ( !Sql.IsEmptyString(sNAME) )
			{
				StringBuilder sb = new StringBuilder();
				// 03/15/2018 Paul.  Mark record as deleted instead of deleting. 
				//sb.AppendLine("delete from DYNAMIC_BUTTONS where VIEW_NAME = '" + sNAME + "';");
				sb.AppendLine("update DYNAMIC_BUTTONS set DELETED = 1, DATE_MODIFIED_UTC = getutcdate(), MODIFIED_USER_ID = null where DELETED = 0 and VIEW_NAME = '" + sNAME + "';");
				
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select *                         " + ControlChars.CrLf
					     + "  from vwDYNAMIC_BUTTONS         " + ControlChars.CrLf
					     + " where VIEW_NAME = @VIEW_NAME    " + ControlChars.CrLf
					     + " order by CONTROL_INDEX         " + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@VIEW_NAME", sNAME);
					
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dtFields = new DataTable() )
							{
								da.Fill(dtFields);
								if ( dtFields.Rows.Count > 0 )
								{
									int nCONTROL_INDEX_Length      = 2;
									int nCONTROL_TYPE_Length       = 4;
									int nMODULE_NAME_Length        = 4;
									int nMODULE_ACCESS_TYPE_Length = 4;
									int nTARGET_NAME_Length        = 4;
									int nTARGET_ACCESS_TYPE_Length = 4;
									int nCONTROL_TEXT_Length       = 4;
									int nCONTROL_TOOLTIP_Length    = 4;
									int nCONTROL_ACCESSKEY_Length  = 4;
									int nCONTROL_CSSCLASS_Length   = 4;
									int nTEXT_FIELD_Length         = 4;
									int nARGUMENT_FIELD_Length     = 4;
									int nCOMMAND_NAME_Length       = 4;
									int nURL_FORMAT_Length         = 4;
									int nURL_TARGET_Length         = 4;
									int nONCLICK_SCRIPT_Length     = 4;
									foreach(DataRow row in dtFields.Rows)
									{
										nCONTROL_INDEX_Length      = Math.Max(nCONTROL_INDEX_Length     , Sql.EscapeSQL(Sql.ToString(row["CONTROL_INDEX"     ])).Length);
										nCONTROL_TYPE_Length       = Math.Max(nCONTROL_TYPE_Length      , Sql.EscapeSQL(Sql.ToString(row["CONTROL_TYPE"      ])).Length + 2);
										nMODULE_NAME_Length        = Math.Max(nMODULE_NAME_Length       , Sql.EscapeSQL(Sql.ToString(row["MODULE_NAME"       ])).Length + 2);
										nMODULE_ACCESS_TYPE_Length = Math.Max(nMODULE_ACCESS_TYPE_Length, Sql.EscapeSQL(Sql.ToString(row["MODULE_ACCESS_TYPE"])).Length + 2);
										nTARGET_NAME_Length        = Math.Max(nTARGET_NAME_Length       , Sql.EscapeSQL(Sql.ToString(row["TARGET_NAME"       ])).Length + 2);
										nTARGET_ACCESS_TYPE_Length = Math.Max(nTARGET_ACCESS_TYPE_Length, Sql.EscapeSQL(Sql.ToString(row["TARGET_ACCESS_TYPE"])).Length + 2);
										nCONTROL_TEXT_Length       = Math.Max(nCONTROL_TEXT_Length      , Sql.EscapeSQL(Sql.ToString(row["CONTROL_TEXT"      ])).Length + 2);
										nCONTROL_TOOLTIP_Length    = Math.Max(nCONTROL_TOOLTIP_Length   , Sql.EscapeSQL(Sql.ToString(row["CONTROL_TOOLTIP"   ])).Length + 2);
										nCONTROL_ACCESSKEY_Length  = Math.Max(nCONTROL_ACCESSKEY_Length , Sql.EscapeSQL(Sql.ToString(row["CONTROL_ACCESSKEY" ])).Length + 2);
										nCONTROL_CSSCLASS_Length   = Math.Max(nCONTROL_CSSCLASS_Length  , Sql.EscapeSQL(Sql.ToString(row["CONTROL_CSSCLASS"  ])).Length + 2);
										nTEXT_FIELD_Length         = Math.Max(nTEXT_FIELD_Length        , Sql.EscapeSQL(Sql.ToString(row["TEXT_FIELD"        ])).Length + 2);
										nARGUMENT_FIELD_Length     = Math.Max(nARGUMENT_FIELD_Length    , Sql.EscapeSQL(Sql.ToString(row["ARGUMENT_FIELD"    ])).Length + 2);
										nCOMMAND_NAME_Length       = Math.Max(nCOMMAND_NAME_Length      , Sql.EscapeSQL(Sql.ToString(row["COMMAND_NAME"      ])).Length + 2);
										nURL_FORMAT_Length         = Math.Max(nURL_FORMAT_Length        , Sql.EscapeSQL(Sql.ToString(row["URL_FORMAT"        ])).Length + 2);
										nURL_TARGET_Length         = Math.Max(nURL_TARGET_Length        , Sql.EscapeSQL(Sql.ToString(row["URL_TARGET"        ])).Length + 2);
										nONCLICK_SCRIPT_Length     = Math.Max(nONCLICK_SCRIPT_Length    , Sql.EscapeSQL(Sql.ToString(row["ONCLICK_SCRIPT"    ])).Length + 2);
									}

									sb.AppendLine("if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = '" + sNAME + "' and DELETED = 0) begin -- then");
									sb.AppendLine("	print 'DYNAMIC_BUTTONS " + sNAME + "';");

									foreach(DataRow row in dtFields.Rows)
									{
										string sVIEW_NAME          = Sql.ToString (row["VIEW_NAME"         ]);
										string sCONTROL_INDEX      = Sql.ToString (row["CONTROL_INDEX"     ]);
										string sCONTROL_TYPE       = Sql.ToString (row["CONTROL_TYPE"      ]);
										string sMODULE_NAME        = Sql.ToString (row["MODULE_NAME"       ]);
										string sMODULE_ACCESS_TYPE = Sql.ToString (row["MODULE_ACCESS_TYPE"]);
										string sTARGET_NAME        = Sql.ToString (row["TARGET_NAME"       ]);
										string sTARGET_ACCESS_TYPE = Sql.ToString (row["TARGET_ACCESS_TYPE"]);
										int    nMOBILE_ONLY        = Sql.ToInteger(row["MOBILE_ONLY"       ]);
										int    nADMIN_ONLY         = Sql.ToInteger(row["ADMIN_ONLY"        ]);
										string sCONTROL_TEXT       = Sql.ToString (row["CONTROL_TEXT"      ]);
										string sCONTROL_TOOLTIP    = Sql.ToString (row["CONTROL_TOOLTIP"   ]);
										string sCONTROL_ACCESSKEY  = Sql.ToString (row["CONTROL_ACCESSKEY" ]);
										string sCONTROL_CSSCLASS   = Sql.ToString (row["CONTROL_CSSCLASS"  ]);
										string sTEXT_FIELD         = Sql.ToString (row["TEXT_FIELD"        ]);
										string sARGUMENT_FIELD     = Sql.ToString (row["ARGUMENT_FIELD"    ]);
										string sCOMMAND_NAME       = Sql.ToString (row["COMMAND_NAME"      ]);
										string sURL_FORMAT         = Sql.ToString (row["URL_FORMAT"        ]);
										string sURL_TARGET         = Sql.ToString (row["URL_TARGET"        ]);
										string sONCLICK_SCRIPT     = Sql.ToString (row["ONCLICK_SCRIPT"    ]);

										sCONTROL_INDEX = Strings.Space(nCONTROL_INDEX_Length - sCONTROL_INDEX.Length) + sCONTROL_INDEX;
										if ( sCONTROL_TYPE == "ButtonLink" )
										{
											if ( sCOMMAND_NAME == "Edit"           && sTEXT_FIELD == "ID" && sURL_FORMAT == "edit.aspx?ID={0}"          )
												sCONTROL_TYPE = "Edit";
											else if ( sCOMMAND_NAME == "Duplicate" && sTEXT_FIELD == "ID" && sURL_FORMAT == "edit.aspx?DuplicateID={0}" )
												sCONTROL_TYPE = "Duplicate";
											else if ( sCOMMAND_NAME == "Cancel"    && sTEXT_FIELD == "ID" && sURL_FORMAT == "default.aspx"              )
												sCONTROL_TYPE = "Cancel";
										}
										else if ( sCONTROL_TYPE == "Button" )
										{
											if ( sCOMMAND_NAME == "Delete"         && sTEXT_FIELD == "" && sURL_FORMAT == "" )
												sCONTROL_TYPE = "Delete";
										}
										switch ( sCONTROL_TYPE )
										{
											// 04/20/2014 Paul.  Procedures do not have leading null. 
											case "Edit"      :  sb.AppendLine("	exec dbo.spDYNAMIC_BUTTONS_InsEdit       '" + sVIEW_NAME + "', " + sCONTROL_INDEX + ", " + Sql.FormatSQL(sMODULE_NAME, nMODULE_NAME_Length) + ";");  break;
											case "Duplicate" :  sb.AppendLine("	exec dbo.spDYNAMIC_BUTTONS_InsDuplicate  '" + sVIEW_NAME + "', " + sCONTROL_INDEX + ", " + Sql.FormatSQL(sMODULE_NAME, nMODULE_NAME_Length) + ";");  break;
											case "Delete"    :  sb.AppendLine("	exec dbo.spDYNAMIC_BUTTONS_InsDelete     '" + sVIEW_NAME + "', " + sCONTROL_INDEX + ", " + Sql.FormatSQL(sMODULE_NAME, nMODULE_NAME_Length) + ";");  break;
											case "Cancel"    :  sb.AppendLine("	exec dbo.spDYNAMIC_BUTTONS_InsCancel     '" + sVIEW_NAME + "', " + sCONTROL_INDEX + ", " + Sql.FormatSQL(sMODULE_NAME, nMODULE_NAME_Length) + ", " + nMOBILE_ONLY.ToString() + ";");  break;
											case "Button"    :  sb.AppendLine("	exec dbo.spDYNAMIC_BUTTONS_InsButton     '" + sVIEW_NAME + "', " + sCONTROL_INDEX + ", " + Sql.FormatSQL(sMODULE_NAME, nMODULE_NAME_Length) + ", " + Sql.FormatSQL(sMODULE_ACCESS_TYPE, nMODULE_ACCESS_TYPE_Length) + ", " + Sql.FormatSQL(sTARGET_NAME, nTARGET_NAME_Length) + ", " + Sql.FormatSQL(sTARGET_ACCESS_TYPE, nTARGET_ACCESS_TYPE_Length) + ", " + Sql.FormatSQL(sCOMMAND_NAME, nCOMMAND_NAME_Length) + ", "                                                         + Sql.FormatSQL(sARGUMENT_FIELD, nARGUMENT_FIELD_Length) + ", " + Sql.FormatSQL(sCONTROL_TEXT, nCONTROL_TEXT_Length) + ", " + Sql.FormatSQL(sCONTROL_TOOLTIP, nCONTROL_TOOLTIP_Length) + ", " + Sql.FormatSQL(sCONTROL_ACCESSKEY, nCONTROL_ACCESSKEY_Length) + ", " + Sql.FormatSQL(sONCLICK_SCRIPT, nONCLICK_SCRIPT_Length) + ", "                                                                 + nMOBILE_ONLY.ToString() + ";");  break;
											// 08/22/2010 Paul.  Add ONCLICK_SCRIPT. 
											case "ButtonLink":  sb.AppendLine("	exec dbo.spDYNAMIC_BUTTONS_InsButtonLink '" + sVIEW_NAME + "', " + sCONTROL_INDEX + ", " + Sql.FormatSQL(sMODULE_NAME, nMODULE_NAME_Length) + ", " + Sql.FormatSQL(sMODULE_ACCESS_TYPE, nMODULE_ACCESS_TYPE_Length) + ", " + Sql.FormatSQL(sTARGET_NAME, nTARGET_NAME_Length) + ", " + Sql.FormatSQL(sTARGET_ACCESS_TYPE, nTARGET_ACCESS_TYPE_Length) + ", " + Sql.FormatSQL(sCOMMAND_NAME, nCOMMAND_NAME_Length) + ", " + Sql.FormatSQL(sURL_FORMAT, nURL_FORMAT_Length) + ", " + Sql.FormatSQL(sTEXT_FIELD    , nTEXT_FIELD_Length    ) + ", " + Sql.FormatSQL(sCONTROL_TEXT, nCONTROL_TEXT_Length) + ", " + Sql.FormatSQL(sCONTROL_TOOLTIP, nCONTROL_TOOLTIP_Length) + ", " + Sql.FormatSQL(sCONTROL_ACCESSKEY, nCONTROL_ACCESSKEY_Length) + ", "                                                                 + Sql.FormatSQL(sURL_TARGET    , nURL_TARGET_Length    ) + ", " + nMOBILE_ONLY.ToString() + ", " + Sql.FormatSQL(sONCLICK_SCRIPT, nONCLICK_SCRIPT_Length) + ";");  break;
											case "HyperLink" :  sb.AppendLine("	exec dbo.spDYNAMIC_BUTTONS_InsHyperLink  '" + sVIEW_NAME + "', " + sCONTROL_INDEX + ", " + Sql.FormatSQL(sMODULE_NAME, nMODULE_NAME_Length) + ", " + Sql.FormatSQL(sMODULE_ACCESS_TYPE, nMODULE_ACCESS_TYPE_Length) + ", " + Sql.FormatSQL(sTARGET_NAME, nTARGET_NAME_Length) + ", " + Sql.FormatSQL(sTARGET_ACCESS_TYPE, nTARGET_ACCESS_TYPE_Length) + ", "                                                             + Sql.FormatSQL(sURL_FORMAT, nURL_FORMAT_Length) + ", " + Sql.FormatSQL(sTEXT_FIELD    , nTEXT_FIELD_Length    ) + ", " + Sql.FormatSQL(sCONTROL_TEXT, nCONTROL_TEXT_Length) + ", " + Sql.FormatSQL(sCONTROL_TOOLTIP, nCONTROL_TOOLTIP_Length) + ", " + Sql.FormatSQL(sCONTROL_ACCESSKEY, nCONTROL_ACCESSKEY_Length) + ", " + Sql.FormatSQL(sONCLICK_SCRIPT, nONCLICK_SCRIPT_Length) + ", " + Sql.FormatSQL(sURL_TARGET    , nURL_TARGET_Length    ) + ", " + nMOBILE_ONLY.ToString() + ";");  break;
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
				Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(Request.Browser, "DYNAMIC_BUTTONS " + sNAME + ".1.sql"));
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

