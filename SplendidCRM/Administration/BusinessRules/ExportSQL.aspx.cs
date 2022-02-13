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
using System.Text;
using System.Data;
using System.Data.Common;
using System.Runtime.InteropServices;
using System.Diagnostics;

namespace SplendidCRM.Administration.BusinessRules
{
	/// <summary>
	/// Summary description for ExportSQL.
	/// </summary>
	public class ExportSQL : SplendidPage
	{
		private void Page_Load(object sender, System.EventArgs e)
		{
			// 03/10/2010 Paul.  Apply full ACL security rules. 
			this.Visible = (SplendidCRM.Security.GetUserAccess("BusinessRules", "export") >= 0);
			if ( !this.Visible )
				return;
			
			try
			{
				Guid gID = Sql.ToGuid(Request["ID"]);
				if ( !IsPostBack )
				{
					if ( !Sql.IsEmptyGuid(gID) )
					{
						string sFileName = String.Empty;
						string sProcedureName = String.Empty;
						StringBuilder sb = new StringBuilder();
						
						DbProviderFactory dbf = DbProviderFactories.GetFactory();
						using ( IDbConnection con = dbf.CreateConnection() )
						{
							con.Open();
							string sSQL ;
							sSQL = "select *               " + ControlChars.CrLf
							     + "  from vwRULES_Edit    " + ControlChars.CrLf
							     + " where ID = @ID        " + ControlChars.CrLf;
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.CommandText = sSQL;
								Sql.AddParameter(cmd, "@ID", gID);
								using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
								{
									if ( rdr.Read() )
									{
										Guid   gASSIGNED_USER_ID = Sql.ToGuid  (rdr["ASSIGNED_USER_ID"]);
										string sNAME             = Sql.ToString(rdr["NAME"            ]);
										string sMODULE_NAME      = Sql.ToString(rdr["MODULE_NAME"     ]);
										string sRULE_TYPE        = Sql.ToString(rdr["RULE_TYPE"       ]);
										string sDESCRIPTION      = Sql.ToString(rdr["DESCRIPTION"     ]);
										string sFILTER_SQL       = Sql.ToString(rdr["FILTER_SQL"      ]);
										string sFILTER_XML       = Sql.ToString(rdr["FILTER_XML"      ]);
										string sRULES_XML        = Sql.ToString(rdr["RULES_XML"       ]);
										string sXOML             = Sql.ToString(rdr["XOML"            ]);
										Guid   gTEAM_ID          = Sql.ToGuid  (rdr["TEAM_ID"         ]);
										string sTEAM_SET_LIST    = Sql.ToString(rdr["TEAM_SET_LIST"   ]);
										// 09/12/2012 Paul.  Assigned User ID and Team ID are not used when migrating. 
										gASSIGNED_USER_ID = Guid.Empty;
										gTEAM_ID          = Guid.Empty;
										sTEAM_SET_LIST    = String.Empty;

										// 01/23/2012 Paul.  Remove some of the bulk of the XML. 
										int nRelatedModulesStart = sFILTER_XML.IndexOf("<CustomProperty><Name>crm:RelatedModules</Name>");
										if ( nRelatedModulesStart >= 0 )
										{
											int nRelatedModulesEnd = sFILTER_XML.IndexOf("</CustomProperty>", nRelatedModulesStart);
											sFILTER_XML = sFILTER_XML.Substring(0, nRelatedModulesStart) + sFILTER_XML.Substring(nRelatedModulesEnd + "</CustomProperty>".Length);
										}
										int nRelationshipsStart = sFILTER_XML.IndexOf("<CustomProperty><Name>crm:Relationships</Name>");
										if ( nRelationshipsStart >= 0 )
										{
											int nRelationshipsEnd = sFILTER_XML.IndexOf("</CustomProperty>", nRelationshipsStart);
											sFILTER_XML = sFILTER_XML.Substring(0, nRelationshipsStart) + sFILTER_XML.Substring(nRelationshipsEnd + "</CustomProperty>".Length);
										}

										sFileName = sNAME;
										sProcedureName = "spRULES_" + sNAME.Replace(" ", "_").Replace("\'", "").Replace(":", "").Replace("/", "");
										sb.AppendLine("/* -- #if IBM_DB2");
										sb.AppendLine("call dbo.spSqlDropProcedure('" + sProcedureName + "')");
										sb.AppendLine("/");
										sb.AppendLine("");
										sb.AppendLine("Create Procedure dbo." + sProcedureName + "()");
										sb.AppendLine("language sql");
										sb.AppendLine("  begin");
										sb.AppendLine("	declare in_USER_ID char(36);");
										sb.AppendLine("-- #endif IBM_DB2 */");
										sb.AppendLine("");
										sb.AppendLine("/* -- #if Oracle");
										sb.AppendLine("Declare");
										sb.AppendLine("	StoO_selcnt INTEGER := 0;");
										sb.AppendLine("	in_ID char(36);");
										sb.AppendLine("BEGIN");
										sb.AppendLine("	BEGIN");
										sb.AppendLine("-- #endif Oracle */");
										sb.AppendLine("");
										sb.AppendLine("print 'RULES " + Sql.EscapeSQL(sNAME) + "';");
										sb.AppendLine("GO");
										sb.AppendLine("");
										sb.AppendLine("set nocount on;");
										sb.AppendLine("GO");
										sb.AppendLine("");
										sb.AppendLine("declare @ID uniqueidentifier;");
										sb.AppendLine("set @ID = '" + gID.ToString() + "';");
										sb.AppendLine("if not exists(select * from RULES where ID = @ID) begin -- then");
										sb.AppendLine("	exec dbo.spRULES_Update @ID, null, "
														+ Sql.FormatSQL(gASSIGNED_USER_ID.ToString(), 0) + ", "
														+ Sql.FormatSQL(sNAME                       , 0) + ", "
														+ Sql.FormatSQL(sMODULE_NAME                , 0) + ", "
														+ Sql.FormatSQL(sRULE_TYPE                  , 0) + ", "
														+ Sql.FormatSQL(sDESCRIPTION                , 0) + ", "
														+ Sql.FormatSQL(sFILTER_SQL                 , 0) + ", "
														+ Sql.FormatSQL(sFILTER_XML                 , 0) + ", "
														+ Sql.FormatSQL(sRULES_XML                  , 0) + ", "
														+ Sql.FormatSQL(sXOML                       , 0) + ", "
														+ Sql.FormatSQL(gTEAM_ID.ToString()         , 0) + ", "
														+ Sql.FormatSQL(sTEAM_SET_LIST              , 0) + ";");
										sb.AppendLine("");
									}
								}
							}
							
							sb.AppendLine("end -- if;");
							sb.AppendLine("GO");
							sb.AppendLine("");
							sb.AppendLine("set nocount off;");
							sb.AppendLine("GO");
							sb.AppendLine("");
							sb.AppendLine("/* -- #if Oracle");
							sb.AppendLine("	EXCEPTION");
							sb.AppendLine("		WHEN NO_DATA_FOUND THEN");
							sb.AppendLine("			StoO_selcnt := 0;");
							sb.AppendLine("		WHEN OTHERS THEN");
							sb.AppendLine("			RAISE;");
							sb.AppendLine("	END;");
							sb.AppendLine("	COMMIT WORK;");
							sb.AppendLine("END;");
							sb.AppendLine("/");
							sb.AppendLine("-- #endif Oracle */");
							sb.AppendLine("");
							sb.AppendLine("/* -- #if IBM_DB2");
							sb.AppendLine("	commit;");
							sb.AppendLine("  end");
							sb.AppendLine("/");
							sb.AppendLine("");
							sb.AppendLine("call dbo." + sProcedureName + "()");
							sb.AppendLine("/");
							sb.AppendLine("");
							sb.AppendLine("call dbo.spSqlDropProcedure('" + sProcedureName + "')");
							sb.AppendLine("/");
							sb.AppendLine("");
							sb.AppendLine("-- #endif IBM_DB2 */");
							sb.AppendLine("");
						}
						
						Response.ContentType = "text/sql";
						// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
						Response.AddHeader("Content-Disposition", "attachment;filename=" + Utils.ContentDispositionEncode(Request.Browser, sFileName + ".sql"));
						Response.Write(sb.ToString());
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				Response.Write(ex.Message);
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
