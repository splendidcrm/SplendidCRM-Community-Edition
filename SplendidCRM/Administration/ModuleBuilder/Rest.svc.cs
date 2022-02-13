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
using System.Web;
using System.Web.SessionState;
using System.Data;
using System.Data.Common;
using System.Text;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.ServiceModel.Activation;
using System.Web.Script.Serialization;
using System.Diagnostics;

namespace SplendidCRM.Administration.ModuleBuilder
{
	[ServiceContract]
	[ServiceBehavior(IncludeExceptionDetailInFaults=true)]
	[AspNetCompatibilityRequirements(RequirementsMode=AspNetCompatibilityRequirementsMode.Required)]
	public class Rest
	{
		public class ModuleField
		{
			public string FIELD_NAME        ;
			public string EDIT_LABEL        ;
			public string LIST_LABEL        ;
			public string DATA_TYPE         ;
			public int    MAX_SIZE          ;
			public bool   REQUIRED          ;
		}

		[OperationContract]
		[WebInvoke(Method="GET", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GetModuleFields(string ModuleName)
		{
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Cache-Control", "no-cache");
			WebOperationContext.Current.OutgoingResponse.Headers.Add("Pragma", "no-cache");
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			
			L10N L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			if ( !Security.IsAuthenticated() || !Security.IS_ADMIN )
			{
				throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
			}
			SplendidSession.CreateSession(HttpContext.Current.Session);
			
			if ( Sql.IsEmptyString(ModuleName) )
				throw(new Exception("The module name must be specified."));
			string sTABLE_NAME = Sql.ToString(Application["Modules." + ModuleName + ".TableName"]);
			string sVIEW_NAME  = "vw" + sTABLE_NAME;
			bool   bValid      = Sql.ToBoolean(Application["Modules." + ModuleName + ".Valid"]);
			if ( Sql.IsEmptyString(sTABLE_NAME) && !bValid )
				throw(new Exception("Unknown module: " + ModuleName));
			
			List<ModuleField> lstFields = new List<ModuleField>();
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				string sSQL;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					sSQL = "select ColumnName as FIELD_NAME        " + ControlChars.CrLf
					     + "     , dbo.fnL10nTerm('en-US', @MODULE_NAME, 'LBL_'      + ColumnName) as EDIT_LABEL" + ControlChars.CrLf
					     + "     , dbo.fnL10nTerm('en-US', @MODULE_NAME, 'LBL_LIST_' + ColumnName) as LIST_LABEL" + ControlChars.CrLf
					     + "     , (case when dbo.fnSqlColumns_IsEnum(@VIEW_NAME, ColumnName, CsType) = 1 then 'Dropdown' " + ControlChars.CrLf
					     + "             when ColumnType = 'nvarchar(max)'                                then 'Text Area'" + ControlChars.CrLf
					     + "             when SqlDbType = 'SqlDbType.NVarChar'                            then 'Text'     " + ControlChars.CrLf
					     + "             when SqlDbType = 'SqlDbType.VarChar'                             then 'Text'     " + ControlChars.CrLf
					     + "             when SqlDbType = 'SqlDbType.Text'                                then 'Text Area'" + ControlChars.CrLf
					     + "             when SqlDbType = 'SqlDbType.NText'                               then 'Text Area'" + ControlChars.CrLf
					     + "             when SqlDbType = 'SqlDbType.TinyInt'                             then 'Integer'  " + ControlChars.CrLf
					     + "             when SqlDbType = 'SqlDbType.Int'                                 then 'Integer'  " + ControlChars.CrLf
					     + "             when SqlDbType = 'SqlDbType.BigInt'                              then 'Integer'  " + ControlChars.CrLf
					     + "             when SqlDbType = 'SqlDbType.Real'                                then 'Decimal'  " + ControlChars.CrLf
					     + "             when SqlDbType = 'SqlDbType.Money'                               then 'Money'    " + ControlChars.CrLf
					     + "             when SqlDbType = 'SqlDbType.Bit'                                 then 'Checkbox' " + ControlChars.CrLf
					     + "             when SqlDbType = 'SqlDbType.DateTime'                            then 'Date'     " + ControlChars.CrLf
					     + "             when SqlDbType = 'SqlDbType.UniqueIdentifier'                    then 'Guid'     " + ControlChars.CrLf
					     + "             else CsType               " + ControlChars.CrLf
					     + "        end)      as DATA_TYPE         " + ControlChars.CrLf
					     + "     , length     as MAX_SIZE          " + ControlChars.CrLf
					     + "     , (case IsNullable when 1 then 0 else 1 end) as REQUIRED" + ControlChars.CrLf
					     + "  from vwSqlColumns                    " + ControlChars.CrLf
					     + " where ObjectName = @TABLE_NAME        " + ControlChars.CrLf
					     + " order by colid                        " + ControlChars.CrLf;
					
					cmd.CommandText = sSQL;
					Sql.AddParameter(cmd, "@MODULE_NAME", ModuleName);
					Sql.AddParameter(cmd, "@VIEW_NAME"  , Sql.MetadataName(cmd, sVIEW_NAME));
					Sql.AddParameter(cmd, "@TABLE_NAME" , sTABLE_NAME);
					
					using ( DbDataAdapter da = dbf.CreateDataAdapter() )
					{
						((IDbDataAdapter)da).SelectCommand = cmd;
						using ( DataTable dt = new DataTable() )
						{
							da.Fill(dt);
							foreach ( DataRow row in dt.Rows )
							{
								ModuleField lay = new ModuleField();
								lay.FIELD_NAME = Sql.ToString (row["FIELD_NAME"]);
								lay.EDIT_LABEL = Sql.ToString (row["EDIT_LABEL"]);
								lay.LIST_LABEL = Sql.ToString (row["LIST_LABEL"]);
								lay.DATA_TYPE  = Sql.ToString (row["DATA_TYPE" ]);
								lay.MAX_SIZE   = Sql.ToInteger(row["MAX_SIZE"  ]);
								lay.REQUIRED   = Sql.ToBoolean(row["REQUIRED"  ]);
								lstFields.Add(lay);
							}
						}
					}
				}
			}
			
			Dictionary<string, object> d = new Dictionary<string, object>();
			d.Add("d", lstFields);
			JavaScriptSerializer json = new JavaScriptSerializer();
			string sResponse = json.Serialize(d);
			byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
			return new MemoryStream(byResponse);
		}

		[OperationContract]
		[WebInvoke(Method="POST", BodyStyle=WebMessageBodyStyle.WrappedRequest, RequestFormat=WebMessageFormat.Json, ResponseFormat=WebMessageFormat.Json)]
		public Stream GenerateModule(Stream input)
		{
			HttpContext          Context     = HttpContext.Current;
			HttpApplicationState Application = HttpContext.Current.Application;
			HttpSessionState     Session     = HttpContext.Current.Session    ;
			HttpRequest          Request     = HttpContext.Current.Request    ;
			HttpContext.Current.Response.ExpiresAbsolute = new DateTime(1980, 1, 1, 0, 0, 0, 0);
			try
			{
				L10N L10n = new L10N(Sql.ToString(Session["USER_SETTINGS/CULTURE"]));
				if ( !Security.IsAuthenticated() || !Security.IS_ADMIN )
				{
					throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
				}
				SplendidSession.CreateSession(HttpContext.Current.Session);
				
				string sRequest = String.Empty;
				using ( StreamReader stmRequest = new StreamReader(input, System.Text.Encoding.UTF8) )
				{
					sRequest = stmRequest.ReadToEnd();
				}
				JavaScriptSerializer json = new JavaScriptSerializer();
				json.MaxJsonLength = int.MaxValue;
				Dictionary<string, object> dict = json.Deserialize<Dictionary<string, object>>(sRequest);
				
				string sDISPLAY_NAME             = String.Empty;
				string sMODULE_NAME              = String.Empty;
				string sTABLE_NAME               = String.Empty;
				bool   bTAB_ENABLED              = false;
				bool   bMOBILE_ENABLED           = false;
				bool   bCUSTOM_ENABLED           = false;
				bool   bREPORT_ENABLED           = false;
				bool   bIMPORT_ENABLED           = false;
				bool   bREST_ENABLED             = false;
				bool   bIS_ADMIN                 = false;
				bool   bINCLUDE_ASSIGNED_USER_ID = false;
				bool   bINCLUDE_TEAM_ID          = false;
				bool   bOVERWRITE_EXISTING       = false;
				bool   bCREATE_CODE_BEHIND       = false;
				bool   bREACT_ONLY               = false;
				List<string> lstRelationships = new List<string>();
				DataTable dtFields = new DataTable();
				DataColumn colFIELD_NAME = new DataColumn("FIELD_NAME", Type.GetType("System.String" ));
				DataColumn colEDIT_LABEL = new DataColumn("EDIT_LABEL", Type.GetType("System.String" ));
				DataColumn colLIST_LABEL = new DataColumn("LIST_LABEL", Type.GetType("System.String" ));
				DataColumn colDATA_TYPE  = new DataColumn("DATA_TYPE" , Type.GetType("System.String" ));
				DataColumn colMAX_SIZE   = new DataColumn("MAX_SIZE"  , Type.GetType("System.Int32"  ));
				DataColumn colREQUIRED   = new DataColumn("REQUIRED"  , Type.GetType("System.Boolean"));
				dtFields.Columns.Add(colFIELD_NAME);
				dtFields.Columns.Add(colEDIT_LABEL);
				dtFields.Columns.Add(colLIST_LABEL);
				dtFields.Columns.Add(colDATA_TYPE );
				dtFields.Columns.Add(colMAX_SIZE  );
				dtFields.Columns.Add(colREQUIRED  );
				foreach ( string sColumnName in dict.Keys )
				{
					switch ( sColumnName )
					{
						case "DISPLAY_NAME"            :  sDISPLAY_NAME             = Sql.ToString (dict[sColumnName]);  break;
						case "MODULE_NAME"             :  sMODULE_NAME              = Sql.ToString (dict[sColumnName]);  break;
						case "TABLE_NAME"              :  sTABLE_NAME               = Sql.ToString (dict[sColumnName]);  break;
						case "TAB_ENABLED"             :  bTAB_ENABLED              = Sql.ToBoolean(dict[sColumnName]);  break;
						case "MOBILE_ENABLED"          :  bMOBILE_ENABLED           = Sql.ToBoolean(dict[sColumnName]);  break;
						case "CUSTOM_ENABLED"          :  bCUSTOM_ENABLED           = Sql.ToBoolean(dict[sColumnName]);  break;
						case "REPORT_ENABLED"          :  bREPORT_ENABLED           = Sql.ToBoolean(dict[sColumnName]);  break;
						case "IMPORT_ENABLED"          :  bIMPORT_ENABLED           = Sql.ToBoolean(dict[sColumnName]);  break;
						case "REST_ENABLED"            :  bREST_ENABLED             = Sql.ToBoolean(dict[sColumnName]);  break;
						case "IS_ADMIN"                :  bIS_ADMIN                 = Sql.ToBoolean(dict[sColumnName]);  break;
						case "INCLUDE_ASSIGNED_USER_ID":  bINCLUDE_ASSIGNED_USER_ID = Sql.ToBoolean(dict[sColumnName]);  break;
						case "INCLUDE_TEAM_ID"         :  bINCLUDE_TEAM_ID          = Sql.ToBoolean(dict[sColumnName]);  break;
						case "OVERWRITE_EXISTING"      :  bOVERWRITE_EXISTING       = Sql.ToBoolean(dict[sColumnName]);  break;
						case "CREATE_CODE_BEHIND"      :  bCREATE_CODE_BEHIND       = Sql.ToBoolean(dict[sColumnName]);  break;
						case "REACT_ONLY"              :  bREACT_ONLY               = Sql.ToBoolean(dict[sColumnName]);  break;
					}
					if ( dict[sColumnName] is System.Collections.ArrayList )
					{
						System.Collections.ArrayList lst = dict[sColumnName] as System.Collections.ArrayList;
						if ( lst != null )
						{
							if ( sColumnName == "Fields" )
							{
								foreach ( Dictionary<string, object> field in lst )
								{
									DataRow row = dtFields.NewRow();
									dtFields.Rows.Add(row);
									foreach ( string sFieldName in field.Keys )
									{
										switch ( sFieldName )
										{
											case "FIELD_NAME":  row[sFieldName] = Sql.ToString (field[sFieldName]);  break;
											case "EDIT_LABEL":  row[sFieldName] = Sql.ToString (field[sFieldName]);  break;
											case "LIST_LABEL":  row[sFieldName] = Sql.ToString (field[sFieldName]);  break;
											case "DATA_TYPE" :  row[sFieldName] = Sql.ToString (field[sFieldName]);  break;
											case "MAX_SIZE"  :  row[sFieldName] = Sql.ToInteger(field[sFieldName]);  break;
											case "REQUIRED"  :  row[sFieldName] = Sql.ToBoolean(field[sFieldName]);  break;
										}
									}
								}
							}
							else if ( sColumnName == "Relationships" )
							{
								foreach ( object obj in lst )
								{
									lstRelationships.Add(Sql.ToString(obj));
								}
							}
						}
					}
				}
				
				StringBuilder sbProgress = new StringBuilder();
				ListView.GenerateModule(Context, sDISPLAY_NAME, sMODULE_NAME, sTABLE_NAME, bTAB_ENABLED, bMOBILE_ENABLED, bCUSTOM_ENABLED, bREPORT_ENABLED, bIMPORT_ENABLED, bREST_ENABLED, bIS_ADMIN, bINCLUDE_ASSIGNED_USER_ID, bINCLUDE_TEAM_ID, bOVERWRITE_EXISTING, bCREATE_CODE_BEHIND, bREACT_ONLY, dtFields, lstRelationships, sbProgress);
				
				Dictionary<string, object> dictResponse = new Dictionary<string, object>();
				dictResponse.Add("d", sbProgress.ToString());
				string sResponse = json.Serialize(dictResponse);
				byte[] byResponse = Encoding.UTF8.GetBytes(sResponse);
				return new MemoryStream(byResponse);
			}
			catch(Exception ex)
			{
				// 03/20/2019 Paul.  Catch and log all failures, including insufficient access. 
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
				throw;
			}
		}
	}
}
