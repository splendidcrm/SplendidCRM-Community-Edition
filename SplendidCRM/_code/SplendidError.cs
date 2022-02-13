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
using System.Web;
using System.Diagnostics;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for SplendidError.
	/// </summary>
	public class SplendidError
	{
		public static void SystemWarning(StackFrame stack, string sMESSAGE)
		{
			SystemMessage("Warning", stack, sMESSAGE);
		}
		
		public static void SystemError(StackFrame stack, string sMESSAGE)
		{
			SystemMessage("Error", stack, sMESSAGE);
		}
		
		public static void SystemWarning(StackFrame stack, Exception ex)
		{
			// 08/13/2007 Paul.  Instead of ignoring the the english abort message, ignore the abort exception. 
			if ( ex.GetType() != Type.GetType("System.Threading.ThreadAbortException") )
			{
				string sMESSAGE = Utils.ExpandException(ex);
				SystemMessage("Warning", stack, sMESSAGE);
			}
		}
		
		public static void SystemError(StackFrame stack, Exception ex)
		{
			// 08/13/2007 Paul.  Instead of ignoring the the english abort message, ignore the abort exception. 
			if ( ex.GetType() != Type.GetType("System.Threading.ThreadAbortException") )
			{
				string sMESSAGE = Utils.ExpandException(ex);
				// 01/14/2009 Paul.  Save the stack trace to help locate the source of a bug. 
				if ( ex.StackTrace != null )
					sMESSAGE += "<br />\r\n" + ex.StackTrace.Replace(ControlChars.CrLf, "<br />\r\n");
				SystemMessage("Error", stack, sMESSAGE);
			}
		}
		
		public static void SystemMessage(string sERROR_TYPE, StackFrame stack, string sMESSAGE)
		{
			if ( HttpContext.Current == null || HttpContext.Current.Application == null )
				return;
			SystemMessage(HttpContext.Current.Application, HttpContext.Current, sERROR_TYPE, stack, sMESSAGE);
		}
		
		public static void SystemMessage(HttpContext Context, string sERROR_TYPE, StackFrame stack, Exception ex)
		{
			string sMESSAGE = Utils.ExpandException(ex);
			if ( sERROR_TYPE == "Error" )
			{
				// 01/14/2009 Paul.  Save the stack trace to help locate the source of a bug. 
				if ( ex.StackTrace != null )
					sMESSAGE += "<br />\r\n" + ex.StackTrace.Replace(ControlChars.CrLf, "<br />\r\n");
			}
			SystemMessage(Context.Application, Context, sERROR_TYPE, stack, sMESSAGE);
		}
		
		public static void SystemMessage(HttpContext Context, string sERROR_TYPE, StackFrame stack, string sMESSAGE)
		{
			SystemMessage(Context.Application, Context, sERROR_TYPE, stack, sMESSAGE);
		}
		
		// 10/2009 Paul.  The cache functions need to pass an Exception object. 
		public static void SystemMessage(HttpApplicationState Application, string sERROR_TYPE, StackFrame stack, Exception ex)
		{
			string sMESSAGE = Utils.ExpandException(ex);
			if ( sERROR_TYPE == "Error" )
			{
				// 01/14/2009 Paul.  Save the stack trace to help locate the source of a bug. 
				if ( ex.StackTrace != null )
					sMESSAGE += "<br />\r\n" + ex.StackTrace.Replace(ControlChars.CrLf, "<br />\r\n");
			}
			SystemMessage(Application, null, sERROR_TYPE, stack, sMESSAGE);
		}
		
		public static void SystemMessage(HttpApplicationState Application, string sERROR_TYPE, StackFrame stack, string sMESSAGE)
		{
			SystemMessage(Application, null, sERROR_TYPE, stack, sMESSAGE);
		}
		
		public static void SystemMessage(HttpApplicationState Application, HttpContext Context, string sERROR_TYPE, StackFrame stack, string sMESSAGE)
		{
			if ( Application == null )
				return;
			// 08/12/2007 Paul.  Ignore the exception generated by Response.Redirect. 
			// 08/13/2007 Paul.  Instead of ignoring the the english abort message, 
			// transition to the above function that ignores the abort exception.  Every file will need to be touched. 
			//if ( sMESSAGE == "Thread was being aborted." )
			//	return;
			try
			{
				Application.Lock();
				DataTable dt = Application["SystemErrors"] as DataTable;
				if ( dt == null )
				{
					dt = new DataTable();
					DataColumn colCREATED_BY   = new DataColumn("CREATED_BY"  , Type.GetType("System.Guid"    ));
					DataColumn colDATE_ENTERED = new DataColumn("DATE_ENTERED", Type.GetType("System.DateTime"));
					DataColumn colERROR_TYPE   = new DataColumn("ERROR_TYPE"  , Type.GetType("System.String"  ));
					DataColumn colUSER_NAME    = new DataColumn("USER_NAME"   , Type.GetType("System.String"  ));
					DataColumn colFILE_NAME    = new DataColumn("FILE_NAME"   , Type.GetType("System.String"  ));
					DataColumn colMETHOD       = new DataColumn("METHOD"      , Type.GetType("System.String"  ));
					DataColumn colLINE_NUMBER  = new DataColumn("LINE_NUMBER" , Type.GetType("System.String"  ));
					DataColumn colMESSAGE      = new DataColumn("MESSAGE"     , Type.GetType("System.String"  ));
					dt.Columns.Add(colCREATED_BY  );
					dt.Columns.Add(colDATE_ENTERED);
					dt.Columns.Add(colERROR_TYPE  );
					dt.Columns.Add(colUSER_NAME   );
					dt.Columns.Add(colFILE_NAME   );
					dt.Columns.Add(colMETHOD      );
					dt.Columns.Add(colLINE_NUMBER );
					dt.Columns.Add(colMESSAGE     );
					Application["SystemErrors"] = dt;
				}

				Guid   gUSER_ID          = Guid.Empty;
				string sUSER_NAME        = String.Empty;
				string sMACHINE          = String.Empty;
				string sASPNET_SESSIONID = String.Empty;
				string sREMOTE_HOST      = String.Empty;
				string sSERVER_HOST      = String.Empty;
				string sTARGET           = String.Empty;
				string sRELATIVE_PATH    = String.Empty;
				string sPARAMETERS       = String.Empty;
				string sFILE_NAME        = String.Empty;
				string sMETHOD           = String.Empty;
				Int32  nLINE_NUMBER      = 0;

				try
				{
					// 09/17/2009 Paul.  Azure does not support MachineName.  Just ignore the error. 
					sMACHINE = System.Environment.MachineName;
				}
				catch
				{
				}
				DataRow row = dt.NewRow();
				dt.Rows.Add(row);
				try
				{
					// 12/22/2007 Paul.  The current context will be null when inside a timer. 
					if ( Context != null && Context.Session != null )
					{
						gUSER_ID          = Security.USER_ID  ;
						sUSER_NAME        = Security.USER_NAME;
						sASPNET_SESSIONID = Context.Session.SessionID;
					}
				}
				catch
				{
				}
				row["CREATED_BY"  ] = gUSER_ID    ;
				row["USER_NAME"   ] = sUSER_NAME  ;
				row["DATE_ENTERED"] = DateTime.Now;
				row["ERROR_TYPE"  ] = sERROR_TYPE ;
				row["MESSAGE"     ] = sMESSAGE    ;
				try
				{
					if ( Context != null && Context.Request != null )
					{
						HttpRequest Request = Context.Request;
						sREMOTE_HOST      = Request.UserHostName;
						sSERVER_HOST      = Request.Url.Host    ;
						sTARGET           = Request.Path        ;
						sRELATIVE_PATH    = Request.AppRelativeCurrentExecutionFilePath;
						sPARAMETERS       = Request.QueryString.ToString();
					}
				}
				catch
				{
				}
				if ( stack != null )
				{
					sFILE_NAME   = stack.GetFileName();
					sMETHOD      = stack.GetMethod().ToString();
					nLINE_NUMBER = stack.GetFileLineNumber();
					try
					{
						if ( Context != null && Context.Request != null )
						{
							if ( !Sql.IsEmptyString(sFILE_NAME) )
							{
								// 04/16/2006 Paul.  Use native function to get file name. 
								// 08/01/2007 Paul.  Include part of the path in the file name. Remove the physical root as it is not useful. 
								sFILE_NAME = sFILE_NAME.Replace(Context.Request.PhysicalApplicationPath, "~" + Path.DirectorySeparatorChar);
								sFILE_NAME = sFILE_NAME.Replace(Path.DirectorySeparatorChar, '/');
							}
						}
					}
					catch
					{
					}
					row["FILE_NAME"   ] = sFILE_NAME;
					row["METHOD"      ] = sMETHOD;
					row["LINE_NUMBER" ] = nLINE_NUMBER;
				}

				try
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
						using ( IDbTransaction trn = Sql.BeginTransaction(con) )
						{
							try
							{
								SqlProcs.spSYSTEM_LOG_InsertOnly(gUSER_ID, sUSER_NAME, sMACHINE, sASPNET_SESSIONID, sREMOTE_HOST, sSERVER_HOST, sTARGET, sRELATIVE_PATH, sPARAMETERS, sERROR_TYPE, sFILE_NAME, sMETHOD, nLINE_NUMBER, sMESSAGE, trn);
								trn.Commit();
							}
							catch//(Exception ex)
							{
								trn.Rollback();
								// 10/26/2008 Paul.  Can't throw an exception here as it could create an endless loop. 
								//SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
							}
						}
					}
				}
#if DEBUG
				catch(Exception ex)
				{
					// 09/16/2015 Paul.  Change to Debug as it is automatically not included in a release build. 
					System.Diagnostics.Debug.WriteLine(ex.Message);
				}
#else
				catch
				{
				}
#endif
				try
				{
					// 04/23/2010 Paul.  Lets cap the error cache at 100 messages. 
					// We are going to assume that the top rows are the oldest records. 
					while ( dt.Rows.Count > 100 )
					{
						dt.Rows.RemoveAt(0);
					}
				}
				catch
				{
				}
			}
			finally
			{
				Application.UnLock();
			}
		}
	}
}

