<%@ WebService Language="C#" Class="SplendidCRM.$modulename$.AutoComplete" %>
using System;
using System.Data;
using System.Data.Common;
using System.Collections;
using System.Web.Services;
using System.ComponentModel;
using SplendidCRM;

namespace SplendidCRM.$modulename$
{
	public class $modulenamesingular$
	{
		public Guid    ID  ;
		public string  $firsttextfield$;

		public $modulenamesingular$()
		{
			ID   = Guid.Empty  ;
			$firsttextfield$ = String.Empty;
		}
	}

	/// <summary>
	/// Summary description for AutoComplete
	/// </summary>
	[WebService(Namespace = "http://tempuri.org/")]
	[WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
	[System.Web.Script.Services.ScriptService]
	[ToolboxItem(false)]
	public class AutoComplete : System.Web.Services.WebService
	{
		[WebMethod(EnableSession=true)]
		public $modulenamesingular$ $tablename$_$tablenamesingular$_$firsttextfield$_Get(string s$firsttextfield$)
		{
			$modulenamesingular$ item = new $modulenamesingular$();
			//try
			{
				if ( !Security.IsAuthenticated() )
					throw(new Exception("Authentication required"));

				SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select ID        " + ControlChars.CrLf
					     + "     , $firsttextfield$      " + ControlChars.CrLf
					     + "  from vw$tablename$" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "$modulename$", "list");
						Sql.AppendParameter(cmd, s$firsttextfield$, (Sql.ToBoolean(Application["CONFIG.AutoComplete.Contains"]) ? Sql.SqlFilterMode.Contains : Sql.SqlFilterMode.StartsWith), "$firsttextfield$");
						// 07/02/2007 Paul.  Sort is important so that the first match is selected. 
						cmd.CommandText += " order by $firsttextfield$" + ControlChars.CrLf;
						using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
						{
							if ( rdr.Read() )
							{
								item.ID   = Sql.ToGuid   (rdr["ID"  ]);
								item.$firsttextfield$ = Sql.ToString (rdr["$firsttextfield$"]);
							}
						}
					}
				}
				if ( Sql.IsEmptyGuid(item.ID) )
				{
					string sCULTURE = Sql.ToString (Session["USER_SETTINGS/CULTURE"]);
					L10N L10n = new L10N(sCULTURE);
					throw(new Exception(L10n.Term("$modulename$.ERR_$tablenamesingular$_NOT_FOUND")));
				}
			}
			//catch
			{
				// 02/04/2007 Paul.  Don't catch the exception.  
				// It is a web service, so the exception will be handled properly by the AJAX framework. 
			}
			return item;
		}

		// 03/30/2007 Paul.  Enable sessions so that we can require authentication to access the data. 
		// 03/29/2007 Paul.  In order for AutoComplete to work, the parameter names must be "prefixText" and "count". 
		[WebMethod(EnableSession=true)]
		public string[] $tablename$_$tablenamesingular$_$firsttextfield$_List(string prefixText, int count)
		{
			string[] arrItems = new string[0];
			try
			{
				if ( !Security.IsAuthenticated() )
					throw(new Exception("Authentication required"));

				SplendidCRM.DbProviderFactory dbf = SplendidCRM.DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					string sSQL;
					sSQL = "select distinct  " + ControlChars.CrLf
					     + "       $firsttextfield$      " + ControlChars.CrLf
					     + "  from vw$tablename$" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Security.Filter(cmd, "$modulename$", "list");
						Sql.AppendParameter(cmd, prefixText, (Sql.ToBoolean(Application["CONFIG.AutoComplete.Contains"]) ? Sql.SqlFilterMode.Contains : Sql.SqlFilterMode.StartsWith), "$firsttextfield$");
						cmd.CommandText += " order by $firsttextfield$" + ControlChars.CrLf;
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(0, count, dt);
								arrItems = new string[dt.Rows.Count];
								for ( int i=0; i < dt.Rows.Count; i++ )
									arrItems[i] = Sql.ToString(dt.Rows[i]["$firsttextfield$"]);
							}
						}
					}
				}
			}
			catch
			{
			}
			return arrItems;
		}

		// 09/03/2009 Paul.  The list can be retrived for the base module, or for a ModulePopup, 
		// so the field name can be NAME or $tablenamesingular$_NAME. 
		[WebMethod(EnableSession=true)]
		public string[] $tablename$_$firsttextfield$_List(string prefixText, int count)
		{
			return $tablename$_$tablenamesingular$_$firsttextfield$_List(prefixText, count);
		}
	}
}
