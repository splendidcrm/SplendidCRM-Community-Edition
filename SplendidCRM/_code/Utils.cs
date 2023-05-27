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
using System.Data;
using System.Data.Common;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Collections;
using System.Diagnostics;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for Utils.
	/// </summary>
	public class Utils
	{
		public static void SetPageTitle(Page page, string sTitle)
		{
			try
			{
				Literal litPageTitle = page.FindControl("litPageTitle") as Literal;
				if ( litPageTitle != null )
					litPageTitle.Text = sTitle;
			}
			catch(Exception ex)
			{
				SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
			}
		}

		// 10/20/2010 Paul.  We are still having a problem with the Enter Key hijacking the Auto-Complete logic. The most practical solution is to block the Enter Key. 
		public static string PreventEnterKeyPress(string sTextID)
		{
			// 05/09/2008 Paul.  There is the rare possibility that the IDs are NULL.  Such as on the login page. 
			if ( !Sql.IsEmptyString(sTextID) )
			{
				// 03/28/2007 Paul.  Fix to support Firefox, which passes the event object in the first parameter. 
				StringBuilder sb = new StringBuilder();
				sb.AppendLine("<script type=\"text/javascript\">");
				// 06/21/2009 Paul.  We are having issues with the controls not being found.  Report the error instead of throwing an exception. 
				sb.AppendLine("if ( document.getElementById('" + sTextID + "') != null )");
				sb.AppendLine("{");
				sb.AppendLine(" document.getElementById('" + sTextID + "').onkeypress = function(e)");
				sb.AppendLine(" {");
				sb.AppendLine("  if ( e != null )");
				sb.AppendLine("  {");
				sb.AppendLine("   if ( e.which == 13 )");
				sb.AppendLine("   {");
				sb.AppendLine("    return false;");
				sb.AppendLine("   }");
				sb.AppendLine("  }");
				sb.AppendLine("  else if ( event != null )");
				sb.AppendLine("  {");
				sb.AppendLine("   if ( event.keyCode == 13 )");
				sb.AppendLine("   {");
				sb.AppendLine("    event.returnValue = false;");
				sb.AppendLine("    event.cancel = true;");
				sb.AppendLine("   }");
				sb.AppendLine("  }");
				sb.AppendLine(" }");
				sb.AppendLine("}");
				sb.AppendLine("</script>");
				return sb.ToString();
			}
			return String.Empty;
		}

		public static string RegisterEnterKeyPress(string sTextID, string sButtonID)
		{
			// 05/09/2008 Paul.  There is the rare possibility that the IDs are NULL.  Such as on the login page. 
			if ( !Sql.IsEmptyString(sTextID) && !Sql.IsEmptyString(sButtonID) )
			{
				// 03/28/2007 Paul.  Fix to support Firefox, which passes the event object in the first parameter. 
				StringBuilder sb = new StringBuilder();
				sb.AppendLine("<script type=\"text/javascript\">");
				// 06/21/2009 Paul.  We are having issues with the controls not being found.  Report the error instead of throwing an exception. 
				sb.AppendLine("if ( document.getElementById('" + sTextID + "') != null && document.getElementById('" + sButtonID + "') != null )");
				sb.AppendLine("{");
				sb.AppendLine(" document.getElementById('" + sTextID + "').onkeypress = function(e)");
				sb.AppendLine(" {");
				sb.AppendLine("  if ( e != null )");
				sb.AppendLine("  {");
				sb.AppendLine("   if ( e.which == 13 )");
				sb.AppendLine("   {");
				sb.AppendLine("    document.getElementById('" + sButtonID + "').click();");
				sb.AppendLine("    return false;");
				sb.AppendLine("   }");
				sb.AppendLine("  }");
				sb.AppendLine("  else if ( event != null )");
				sb.AppendLine("  {");
				sb.AppendLine("   if ( event.keyCode == 13 )");
				sb.AppendLine("   {");
				sb.AppendLine("    event.returnValue = false;");
				sb.AppendLine("    event.cancel = true;");
				sb.AppendLine("    document.getElementById('" + sButtonID + "').click();");
				sb.AppendLine("   }");
				sb.AppendLine("  }");
				sb.AppendLine(" }");
				sb.AppendLine("}");
// 01/13/2010 Paul.  Don't need these alerts any more. 
#if false
				sb.AppendLine("else");
				sb.AppendLine("{");
				sb.AppendLine(" alert('Could not find " + sTextID + " for EnterKey processing');");
				sb.AppendLine(" if ( document.getElementById('" + sButtonID + "') == null )");
				sb.AppendLine("  alert('Could not find " + sButtonID + " for EnterKey processing');");
				sb.AppendLine("}");
#endif

				sb.AppendLine("</script>");
				return sb.ToString();
			}
			return String.Empty;
		}

		public static string RegisterSetFocus(string sTextID)
		{
			StringBuilder sb = new StringBuilder();
			sb.AppendLine("<script type=\"text/javascript\">");
			// 09/07/2009 Paul.  Prevent a runtime error by checking if the element exists before setting the focus. 
			sb.AppendLine("if ( document.getElementById('" + sTextID + "') == null )");
			sb.AppendLine("	document.getElementById('" + sTextID + "').focus();");
			sb.AppendLine("</script>");
			return sb.ToString();
		}
	
		public static WebControl CreateArrowControl(bool bAscending)
		{
			Label lblArrow = new Label();
			lblArrow.Font.Name = "Webdings";
			if ( bAscending )
				lblArrow.Text = "5";
			else
				lblArrow.Text = "6";
			return lblArrow;
		}

		public static string ValidateIDs(string[] arrID, bool bQuoted)
		{
			if ( arrID.Length == 0 )
				return String.Empty;
			if ( arrID.Length > 200 )
			{
				// 11/03/2021 Paul.  Utils calls may come from REST API and therefore will not have L10n in Current.Items. 
				//L10N L10n = HttpContext.Current.Items["L10n"] as L10N;
				// 05/14/2023 Paul.  Should use Session, not Application. 
				L10N L10n = new L10N(HttpContext.Current.Session["USER_SETTINGS/CULTURE"] as string);
				throw(new Exception(L10n.Term(".LBL_TOO_MANY_RECORDS")));
			}
			
			foreach(string sID in arrID)
			{
				Guid gID = Sql.ToGuid(sID);
				if ( Sql.IsEmptyGuid(gID) )
				{
					// 05/02/2006 Paul.  Provide a more descriptive error message by including the ID. 
					throw(new Exception("Invalid ID: " + sID));
				}
			}
			string sIDs = String.Empty;
			if ( bQuoted )
				sIDs = "'" + String.Join("','", arrID) + "'";
			else
				sIDs = String.Join(",", arrID);
			return sIDs;
		}

		public static string ValidateIDs(string[] arrID)
		{
			return ValidateIDs(arrID, false);
		}

		// 07/16/2019 Paul.  Add support for Rest API for MassSync. 
		public static string ValidateIDs(Guid[] arrID, bool bQuoted)
		{
			if ( arrID.Length == 0 )
				return String.Empty;
			if ( arrID.Length > 200 )
			{
				// 11/03/2021 Paul.  Utils calls may come from REST API and therefore will not have L10n in Current.Items. 
				//L10N L10n = HttpContext.Current.Items["L10n"] as L10N;
				// 05/14/2023 Paul.  Should use Session, not Application. 
				L10N L10n = new L10N(HttpContext.Current.Session["USER_SETTINGS/CULTURE"] as string);
				throw(new Exception(L10n.Term(".LBL_TOO_MANY_RECORDS")));
			}
			
			StringBuilder sbIDs = new StringBuilder();
			foreach(Guid gID in arrID)
			{
				if ( sbIDs.Length > 0 )
					sbIDs.Append(",");
				if ( bQuoted )
					sbIDs.Append("\'" + gID.ToString() + "\'");
				else
					sbIDs.Append(gID.ToString());
			}
			return sbIDs.ToString();
		}

		public static string FilterByACL(string sMODULE_NAME, string sACCESS_TYPE, string[] arrID, string sTABLE_NAME)
		{
			StringBuilder sb = new StringBuilder();
			int nACLACCESS = Security.GetUserAccess(sMODULE_NAME, sACCESS_TYPE);
			if ( nACLACCESS >= 0 && arrID.Length > 0 )
			{
				if ( nACLACCESS == ACL_ACCESS.OWNER )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						// 09/26/2006 Paul.  The connection needed to be opened. 
						con.Open();
						string sSQL;
						sSQL = "select ID              " + ControlChars.CrLf
						     + "  from vw" + sTABLE_NAME + ControlChars.CrLf
						     + " where 1 = 1           " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AppendGuids(cmd, arrID, "ID");
							Sql.AppendParameter(cmd, Security.USER_ID, "ASSIGNED_USER_ID", false);
							// 10/16/2006 Paul.  Fix execute to allow more than one row. 
							using ( IDataReader rdr = cmd.ExecuteReader() )
							{
								while ( rdr.Read() )
								{
									if ( sb.Length > 0 )
										sb.Append(",");
									sb.Append(Sql.ToString(rdr["ID"]));
								}
							}
						}
					}
					if ( sb.Length == 0 )
					{
						// 11/03/2021 Paul.  Utils calls may come from REST API and therefore will not have L10n in Current.Items. 
						//L10N L10n = HttpContext.Current.Items["L10n"] as L10N;
						// 05/14/2023 Paul.  Should use Session, not Application. 
						L10N L10n = new L10N(HttpContext.Current.Session["USER_SETTINGS/CULTURE"] as string);
						throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
					}
				}
				else
				{
					return String.Join(",", arrID);
				}
			}
			return sb.ToString();
		}

		public static string BuildMassIDs(Stack stk, int nCapacity)
		{
			if ( stk.Count == 0 )
				return String.Empty;
			
			StringBuilder sb = new StringBuilder();
			for ( int i = 0; i < nCapacity && stk.Count > 0; i++ )
			{
				string sID = Sql.ToString(stk.Pop());
				if ( sb.Length > 0 )
					sb.Append(",");
				sb.Append(sID);
			}
			return sb.ToString();
		}

		public static string BuildMassIDs(Stack stkID)
		{
			return BuildMassIDs(stkID, 200);
		}

		public static Stack FilterByACL_Stack(string sMODULE_NAME, string sACCESS_TYPE, string[] arrID, string sTABLE_NAME)
		{
			int nACLACCESS = Security.GetUserAccess(sMODULE_NAME, sACCESS_TYPE);
			Stack stk = FilterByACL_Stack(sMODULE_NAME, nACLACCESS, arrID, sTABLE_NAME);
			return stk;
		}

		// 03/03/2021 Paul.  We need a version of FilterByACL_Stack() that does not require Context.Session so that it can be called from a Rest thread. 
		public static Stack FilterByACL_Stack(string sMODULE_NAME, int nACLACCESS, string[] arrID, string sTABLE_NAME)
		{
			Stack stk = new Stack();
			if ( nACLACCESS >= 0 && arrID.Length > 0 )
			{
				if ( nACLACCESS == ACL_ACCESS.OWNER )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory();
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						// 09/26/2006 Paul.  The connection needed to be opened. 
						con.Open();
						string sSQL;
						sSQL = "select ID              " + ControlChars.CrLf
						     + "  from vw" + sTABLE_NAME + ControlChars.CrLf
						     + " where 1 = 1           " + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							Sql.AppendGuids(cmd, arrID, "ID");
							Sql.AppendParameter(cmd, Security.USER_ID, "ASSIGNED_USER_ID", false);
							using ( IDataReader rdr = cmd.ExecuteReader() )
							{
								while ( rdr.Read() )
								{
									stk.Push(Sql.ToString(rdr["ID"]));
								}
							}
						}
					}
					if ( stk.Count == 0 )
					{
						// 11/03/2021 Paul.  Utils calls may come from REST API and therefore will not have L10n in Current.Items. 
						//L10N L10n = HttpContext.Current.Items["L10n"] as L10N;
						// 05/14/2023 Paul.  Should use Session, not Application. 
						L10N L10n = new L10N(HttpContext.Current.Session["USER_SETTINGS/CULTURE"] as string);
						throw(new Exception(L10n.Term("ACL.LBL_INSUFFICIENT_ACCESS")));
					}
				}
				else
				{
					foreach ( string sID in arrID )
					{
						if ( sID.Length > 0 )
							stk.Push(sID);
					}
				}
			}
			return stk;
		}

// 11/03/2021 Paul.  ASP.Net components are not needed. 
#if !ReactOnlyUI
		public static void UpdateTracker(Page pParent, string sModule, Guid gID, string sName)
		{
			// 08/21/2005 Paul.  This function is also called after a user clicks Duplicate.
			// In this scenerio, the gID will be NULL, so don't do anything. 
			if ( !Sql.IsEmptyGuid(gID) )
			{
				// 03/08/2012 Paul.  Add ACTION to the tracker table so that we can create quick user activity reports. 
				SqlProcs.spTRACKER_Update(Security.USER_ID, sModule, gID, sName, "detailview");
				if ( pParent != null )
				{
					// 02/08/2007 Paul.  The control is in the master page. 
					// 06/16/2017 Paul.  Page may not be within a master page. 
					if ( pParent.Master != null )
					{
						ContentPlaceHolder plcLastViewed = pParent.Master.FindControl("cntLastViewed") as ContentPlaceHolder;
						if ( plcLastViewed != null )
						{
							_controls.LastViewed ctlLastViewed = plcLastViewed.FindControl("ctlLastViewed") as _controls.LastViewed;
							if ( ctlLastViewed != null )
							{
								ctlLastViewed.Refresh();
								return;
							}
						}
						Themes.Six.TabMenu ctlTabMenu = pParent.Master.FindControl("ctlTabMenu") as Themes.Six.TabMenu;
						if ( ctlTabMenu != null )
						{
							ctlTabMenu.Refresh();
							return;
						}
					}
				}
			}
		}

		public static void AdminShortcuts(Page pParent, bool bAdminShortcuts)
		{
			// 02/08/2007 Paul.  The control is in the master page. 
			ContentPlaceHolder plcShortcuts = pParent.Master.FindControl("cntSidebar") as ContentPlaceHolder;
			if ( plcShortcuts != null )
			{
				_controls.Shortcuts ctlShortcuts = plcShortcuts.FindControl("ctlShortcuts") as _controls.Shortcuts;
				if ( ctlShortcuts != null )
				{
					ctlShortcuts.AdminShortcuts = bAdminShortcuts;
				}
			}
		}
#endif

		// 08/19/2010 Paul.  Use ListControl to be more generic. 
		// 11/14/2014 Paul.  Return found status. 
		public static bool SetValue(ListControl lst, string sValue)
		{
			bool bFound = false;
			for ( int i=0 ; i < lst.Items.Count; i++ )
			{
				if ( String.Compare(lst.Items[i].Value, sValue, true) == 0 )
				{
					// 08/19/2010 Paul.  We are doing a case-insignificant search, but then trying to set the case-significant value. 
					// Instead, just use the value of the index. 
					//lst.SelectedValue = lst.Items[i].Value;
					lst.SelectedIndex = i;
					bFound = true;
					break;
				}
			}
			return bFound;
		}

		// 08/19/2010 Paul.  Check the list before assigning the value. 
		public static bool SetSelectedValue(ListControl lst, string sValue)
		{
			bool bFound = false;
			ListItem itm = lst.Items.FindByValue(sValue);
			if ( itm != null )
			{
				lst.SelectedValue = sValue;
				bFound = true;
			}
			return bFound;
		}

		public static string ExpandException(Exception ex)
		{
			StringBuilder sb = new StringBuilder();
			do
			{
				sb.Append(ex.Message);
				// 08/13/2007 Paul.  Only add the line break if there is more data. 
				if ( ex.InnerException != null )
					sb.Append("<br />\r\n");
				ex = ex.InnerException;
			}
			while ( ex != null );
			return sb.ToString();
		}

		public static string GetUserEmail(Guid gID)
		{
			string sEmail = String.Empty;
			if ( !Sql.IsEmptyGuid(gID) )
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					sSQL = "select EMAIL1  " + ControlChars.CrLf
					     + "     , EMAIL2  " + ControlChars.CrLf
					     + "  from vwUSERS " + ControlChars.CrLf
					     + " where ID = @ID" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@ID", gID);
						using ( IDataReader rdr = cmd.ExecuteReader(CommandBehavior.SingleRow) )
						{
							while ( rdr.Read() )
							{
								sEmail = Sql.ToString(rdr["EMAIL1"]);
								if ( Sql.IsEmptyString(sEmail) )
									sEmail = Sql.ToString(rdr["EMAIL2"]);
							}
						}
					}
				}
			}
			return sEmail;
		}

		public static System.Collections.Specialized.NameValueCollection AppSettings
		{
			get
			{
				#pragma warning disable 618
				return System.Configuration.ConfigurationSettings.AppSettings;
				#pragma warning restore 618
			}
		}

		// 11/06/2009 Paul.  We need a common way to detect the offline client. 
		public static bool IsOfflineClient
		{
			get
			{
				string sOfflineClient = Utils.AppSettings["OfflineClient"];
				return Sql.ToBoolean(sOfflineClient);
			}
		}

		public static bool IsMobileDevice
		{
			get
			{
				// 11/24/2010 Paul.  .NET 4 has broken the compatibility of the browser file system. 
				// We are going to minimize our reliance on browser files in order to reduce deployment issues. 
				return Sql.ToBoolean(HttpContext.Current.Session["IsMobileDevice"]);
			}
		}

		public static bool SupportsPopups
		{
			get
			{
				// 11/24/2010 Paul.  .NET 4 has broken the compatibility of the browser file system. 
				// We are going to minimize our reliance on browser files in order to reduce deployment issues. 
				return Sql.ToBoolean(HttpContext.Current.Session["SupportsPopups"]);
			}
		}

		// 08/22/2012 Paul.  Apple and Android devices should support speech and handwriting. 
		public static bool SupportsSpeech
		{
			get
			{
				return Sql.ToBoolean(HttpContext.Current.Session["SupportsSpeech"]);
			}
		}

		public static bool SupportsHandwriting
		{
			get
			{
				return Sql.ToBoolean(HttpContext.Current.Session["SupportsHandwriting"]);
			}
		}

		public static bool SupportsTouch
		{
			get
			{
				// 11/14/2012 Paul.  Microsoft Surface has Touch in the agent string. 
				return Sql.ToBoolean(HttpContext.Current.Session["SupportsTouch"]);
			}
		}

		public static bool AllowAutoComplete
		{
			get
			{
				// 11/24/2010 Paul.  .NET 4 has broken the compatibility of the browser file system. 
				// We are going to minimize our reliance on browser files in order to reduce deployment issues. 
				return Sql.ToBoolean(HttpContext.Current.Session["AllowAutoComplete"]);
			}
		}

		// 02/05/2016 Paul.  This function is used by the html5 layout editor. 
		public static string BuildTermName(string sModule, string sDISPLAY_NAME)
		{
			// 05/16/2016 Paul.  Add Tags module. 
			// 08/20/2016 Paul.  PENDING_PROCESS_ID should be a global term. 
			// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			// 04/19/2018 Paul.  MODIFIED_BY_ID is not the correct name, use MODIFIED_USER_ID instead. 
			// 07/18/2018 Paul.  Add LBL_ARCHIVE_BY. 
			string sTERM_NAME = String.Empty;
			if (  sDISPLAY_NAME == "ID"              
			   || sDISPLAY_NAME == "DELETED"         
			   || sDISPLAY_NAME == "CREATED_BY"      
			   || sDISPLAY_NAME == "CREATED_BY_ID"   
			   || sDISPLAY_NAME == "CREATED_BY_NAME" 
			   || sDISPLAY_NAME == "DATE_ENTERED"    
			   || sDISPLAY_NAME == "MODIFIED_USER_ID"
			   || sDISPLAY_NAME == "DATE_MODIFIED"   
			   || sDISPLAY_NAME == "DATE_MODIFIED_UTC"
			   || sDISPLAY_NAME == "MODIFIED_BY"     
			   || sDISPLAY_NAME == "MODIFIED_USER_ID"  
			   || sDISPLAY_NAME == "MODIFIED_BY_NAME"
			   || sDISPLAY_NAME == "ASSIGNED_USER_ID"
			   || sDISPLAY_NAME == "ASSIGNED_TO"     
			   || sDISPLAY_NAME == "ASSIGNED_TO_NAME"
			   || sDISPLAY_NAME == "TEAM_ID"         
			   || sDISPLAY_NAME == "TEAM_NAME"       
			   || sDISPLAY_NAME == "TEAM_SET_ID"     
			   || sDISPLAY_NAME == "TEAM_SET_NAME"   
			   || sDISPLAY_NAME == "TEAM_SET_LIST"   
			   || sDISPLAY_NAME == "ASSIGNED_SET_ID"  
			   || sDISPLAY_NAME == "ASSIGNED_SET_NAME"
			   || sDISPLAY_NAME == "ASSIGNED_SET_LIST"
			   || sDISPLAY_NAME == "ID_C"            
			   || sDISPLAY_NAME == "AUDIT_ID"        
			   || sDISPLAY_NAME == "AUDIT_ACTION"    
			   || sDISPLAY_NAME == "AUDIT_DATE"      
			   || sDISPLAY_NAME == "AUDIT_COLUMNS"   
			   || sDISPLAY_NAME == "AUDIT_TABLE"     
			   || sDISPLAY_NAME == "AUDIT_TOKEN"     
			   || sDISPLAY_NAME == "LAST_ACTIVITY_DATE"
			   || sDISPLAY_NAME == "TAG_SET_NAME"    
			   || sDISPLAY_NAME == "PENDING_PROCESS_ID"
			   || sDISPLAY_NAME == "ARCHIVE_BY"      
			   || sDISPLAY_NAME == "ARCHIVE_BY_NAME" 
			   || sDISPLAY_NAME == "ARCHIVE_DATE_UTC"
			   || sDISPLAY_NAME == "ARCHIVE_USER_ID" 
			   || sDISPLAY_NAME == "ARCHIVE_VIEW"    
				)
			{
				sTERM_NAME = ".LBL_" + sDISPLAY_NAME;
			}
			else
			{
				sTERM_NAME = sModule + ".LBL_" + sDISPLAY_NAME;
			}
			return sTERM_NAME;
		}

		public static string TableColumnName(L10N L10n, string sModule, string sDISPLAY_NAME)
		{
			// 07/04/2006 Paul.  Some columns have global terms. 
			// 06/05/2007 Paul.  Add Team global term. 
			// 07/23/2008 Paul.  Add Audit terms. 
			// 10/04/2008 Paul.  CREATED_BY_ID is used in most module views. 
			// 12/03/2008 Paul.  AUDIT_TABLE is also a common field. 
			// 08/24/2009 Paul.  Add support for dynamic teams. 
			// 09/16/2009 Paul.  DATE_MODIFIED_UTC is a new common field used to sync. 
			// 09/01/2010 Paul.  Add CREATED_BY_NAME, MODIFIED_BY_NAME and ASSIGNED_TO_NAME as global names. 
			// 10/29/2010 Paul.  Add TEAM_SET_LIST. 
			// 12/07/2010 Paul.  Add TEAM_SET_ID. 
			// 09/01/2012 Paul.  Add LAST_ACTIVITY_DATE. 
			// 05/16/2016 Paul.  Add Tags module. 
			// 08/20/2016 Paul.  PENDING_PROCESS_ID should be a global term. 
			// 11/30/2017 Paul.  Add ASSIGNED_SET_ID for Dynamic User Assignment. 
			// 04/19/2018 Paul.  MODIFIED_BY_ID is not the correct name, use MODIFIED_USER_ID instead. 
			// 07/18/2018 Paul.  Add Archive terms. 
			if (  sDISPLAY_NAME == "ID"              
			   || sDISPLAY_NAME == "DELETED"         
			   || sDISPLAY_NAME == "CREATED_BY"      
			   || sDISPLAY_NAME == "CREATED_BY_ID"   
			   || sDISPLAY_NAME == "CREATED_BY_NAME" 
			   || sDISPLAY_NAME == "DATE_ENTERED"    
			   || sDISPLAY_NAME == "MODIFIED_USER_ID"
			   || sDISPLAY_NAME == "DATE_MODIFIED"   
			   || sDISPLAY_NAME == "DATE_MODIFIED_UTC"
			   || sDISPLAY_NAME == "MODIFIED_BY"     
			   || sDISPLAY_NAME == "MODIFIED_USER_ID"  
			   || sDISPLAY_NAME == "MODIFIED_BY_NAME"
			   || sDISPLAY_NAME == "ASSIGNED_USER_ID"
			   || sDISPLAY_NAME == "ASSIGNED_TO"     
			   || sDISPLAY_NAME == "ASSIGNED_TO_NAME"
			   || sDISPLAY_NAME == "TEAM_ID"         
			   || sDISPLAY_NAME == "TEAM_NAME"       
			   || sDISPLAY_NAME == "TEAM_SET_ID"     
			   || sDISPLAY_NAME == "TEAM_SET_NAME"   
			   || sDISPLAY_NAME == "TEAM_SET_LIST"   
			   || sDISPLAY_NAME == "ASSIGNED_SET_ID"  
			   || sDISPLAY_NAME == "ASSIGNED_SET_NAME"
			   || sDISPLAY_NAME == "ASSIGNED_SET_LIST"
			   || sDISPLAY_NAME == "ID_C"            
			   || sDISPLAY_NAME == "AUDIT_ID"        
			   || sDISPLAY_NAME == "AUDIT_ACTION"    
			   || sDISPLAY_NAME == "AUDIT_DATE"      
			   || sDISPLAY_NAME == "AUDIT_COLUMNS"   
			   || sDISPLAY_NAME == "AUDIT_TABLE"     
			   || sDISPLAY_NAME == "AUDIT_TOKEN"     
			   || sDISPLAY_NAME == "LAST_ACTIVITY_DATE"
			   || sDISPLAY_NAME == "TAG_SET_NAME"    
			   || sDISPLAY_NAME == "PENDING_PROCESS_ID"
			   || sDISPLAY_NAME == "ARCHIVE_BY"      
			   || sDISPLAY_NAME == "ARCHIVE_BY_NAME" 
			   || sDISPLAY_NAME == "ARCHIVE_DATE_UTC"
			   || sDISPLAY_NAME == "ARCHIVE_USER_ID" 
			   || sDISPLAY_NAME == "ARCHIVE_VIEW"    
				)
			{
				sDISPLAY_NAME = L10n.Term(".LBL_" + sDISPLAY_NAME).Replace(":", "");
			}
			else
			{
				// 07/04/2006 Paul.  Column names are aliased so that we don't have to redefine terms. 
				sDISPLAY_NAME = L10n.AliasedTerm(sModule + ".LBL_" + sDISPLAY_NAME).Replace(":", "");
			}
			return sDISPLAY_NAME;
		}

		public static string MassEmailerSiteURL(HttpApplicationState Application)
		{
			string sSiteURL = Sql.ToString(Application["CONFIG.site_url"]);
			if ( Sql.ToString(Application["CONFIG.massemailer_tracking_entities_location_type"]) == "2" && !Sql.IsEmptyString(Application["CONFIG.massemailer_tracking_entities_location"]) )
				sSiteURL = Sql.ToString(Application["CONFIG.massemailer_tracking_entities_location"]);
			if ( Sql.IsEmptyString(sSiteURL) )
			{
				// 12/15/2007 Paul.  Use the environment as it is always available. 
				// The Request object is not always available, such as when inside a timer event. 
				// 12/22/2007 Paul.  We are now storing the server name in an application variable. 
				// 12/27/2020 Paul.  We need the initial scheme when creating the default site_url. 
				string sServerScheme    = Sql.ToString(Application["ServerScheme"   ]);
				string sServerName      = Sql.ToString(Application["ServerName"     ]);
				string sApplicationPath = Sql.ToString(Application["ApplicationPath"]);
				sSiteURL = sServerScheme + "://" + sServerName + sApplicationPath;
			}
			if ( !sSiteURL.StartsWith("http") )
				sSiteURL = "http://" + sSiteURL;
			if ( !sSiteURL.EndsWith("/") )
				sSiteURL += "/";
			return sSiteURL;
		}

		public static void RefreshAllViews()
		{
			// 05/08/2007 Paul.  Keep the original procedure call so that we will get a compiler error if something changes. 
			bool bIncreaseTimeout = true;
			if ( !bIncreaseTimeout )
			{
				SqlProcs.spSqlRefreshAllViews();
			}
			else
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
					using ( IDbTransaction trn = Sql.BeginTransaction(con) )
					{
						try
						{
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.Transaction = trn;
								cmd.CommandType = CommandType.StoredProcedure;
								cmd.CommandText = "spSqlRefreshAllViews";
								// 05/08/2007 Paul.  Allow this to run until it completes. 
								cmd.CommandTimeout = 0;
								cmd.ExecuteNonQuery();
							}
							trn.Commit();
						}
						catch(Exception ex)
						{
							trn.Rollback();
							throw(new Exception(ex.Message, ex.InnerException));
						}
					}
				}
			}
		}

		// 12/12/2009 Paul.  We are going to call inside a thread as it can take a minute to run. 
		public static void UpdateSemanticModel(object o)
		{
			HttpContext Context = o as HttpContext;
			DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				con.Open();
				using ( IDbTransaction trn = Sql.BeginTransaction(con) )
				{
					try
					{
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.Transaction = trn;
							cmd.CommandType = CommandType.StoredProcedure;
							cmd.CommandText = "spSEMANTIC_MODEL_Rebuild";
							cmd.CommandTimeout = 0;
							cmd.ExecuteNonQuery();
						}
						trn.Commit();
					}
					catch(Exception ex)
					{
						trn.Rollback();
						SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), ex);
					}
				}
			}
			// 12/12/2009 Paul.  The semantic model is user-specific. 
			SplendidCache.ClearSet("SEMANTIC_MODEL.");
		}

		// 02/18/2021 Paul.  Rebuild audit tables in the background. 
		public static void BuildAllAuditTables(object o)
		{
			HttpContext Context = o as HttpContext;
			HttpApplicationState Application = Context.Application;
			// 12/02/2009 Paul.  Keep the original procedure call so that we will get a compiler error if something changes. 
			bool bIncreaseTimeout = true;
			if ( !bIncreaseTimeout )
			{
				// 12/10/2009 Paul.  The Offline Client does not support auditing. 
				//SqlProcs.spSqlBuildAllAuditTables();
			}
			else
			{
				Application["System.RebuildAudit.Start"] = DateTime.Now;
				DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					// 10/07/2009 Paul.  We need to create our own global transaction ID to support auditing and workflow on SQL Azure, PostgreSQL, Oracle, DB2 and MySQL. 
					using ( IDbTransaction trn = Sql.BeginTransaction(con) )
					{
						try
						{
							using ( IDbCommand cmd = con.CreateCommand() )
							{
								cmd.Transaction = trn;
								cmd.CommandType = CommandType.StoredProcedure;
								cmd.CommandText = "spSqlBuildAllAuditTables";
								// 12/02/2009 Paul.  Allow this to run until it completes. 
								cmd.CommandTimeout = 0;
								cmd.ExecuteNonQuery();
							}
							trn.Commit();
						}
						catch(Exception ex)
						{
							trn.Rollback();
							throw(new Exception(ex.Message, ex.InnerException));
						}
						finally
						{
							Application["System.RebuildAudit.Start"] = null;
						}
					}
				}
			}
		}

		public static DataTable CheckVersion(HttpApplicationState Application)
		{
			XmlDocument xml = new XmlDocument();
			// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
			// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
			// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
			xml.XmlResolver = null;
			// 12/18/2008 Paul.  Check the version of the appropriate service level. 
			string sVersionXmlURL = String.Empty;
			string sServiceLevel = Sql.ToString(Application["CONFIG.service_level"]);
			if ( String.Compare(sServiceLevel, "Basic", true) == 0 || String.Compare(sServiceLevel, "Community", true) == 0 )
				sVersionXmlURL = "http://community.splendidcrm.com/Administration/Versions.xml";
			else if ( String.Compare(sServiceLevel, "Enterprise", true) == 0 )
				sVersionXmlURL = "http://enterprise.splendidcrm.com/Administration/Versions.xml";
			// 11/06/2015 Paul.  Add support for the Ultimate edition. 
			else if ( String.Compare(sServiceLevel, "Ultimate", true) == 0 )
				sVersionXmlURL = "http://ultimate.splendidcrm.com/Administration/Versions.xml";
			else // if ( String.Compare(sServiceLevel, "Professional", true) == 0 )
				sVersionXmlURL = "http://professional.splendidcrm.com/Administration/Versions.xml";

			xml.Load(sVersionXmlURL + (Sql.ToBoolean(Application["CONFIG.send_usage_info"]) ? Utils.UsageInfo(Application) : String.Empty));

			Version vSplendidVersion = new Version(Sql.ToString(Application["SplendidVersion"]));
			DataTable dt = XmlUtil.CreateDataTable(xml.DocumentElement, "Version", new string[] {"Build", "Date", "Description", "URL", "New"});
			foreach ( DataRow row in dt.Rows )
			{
				Version vBuild = new Version(Sql.ToString(row["Build"]));
				if ( vSplendidVersion < vBuild )
					row["New"] = "1";
			}
			return dt;
		}

		public static string UsageInfo(HttpApplicationState Application)
		{
			StringBuilder sb = new StringBuilder();
			//sb.Append("&Machine="  + HttpUtility.UrlEncode(System.Environment.MachineName                   ));
			//sb.Append("&Procs="    + HttpUtility.UrlEncode(System.Environment.ProcessorCount.ToString()     ));
			//sb.Append("&IP="       + HttpUtility.UrlEncode(Sql.ToString(Application["ServerIPAddress"     ])));
			sb.Append("?Server="   + HttpUtility.UrlEncode(Sql.ToString(Application["ServerName"          ])));
			sb.Append("&Splendid=" + HttpUtility.UrlEncode(Sql.ToString(Application["SplendidVersion"     ])));
			sb.Append("&Key="      + HttpUtility.UrlEncode(Sql.ToString(Application["CONFIG.unique_key"   ])));
			try
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory(Application);
				using ( IDbConnection con = dbf.CreateConnection() )
				{
					con.Open();
					string sSQL;
					// 10/21/2008 Paul.  Exclude employees from user count. 
					sSQL = "select count(*)    " + ControlChars.CrLf
					     + "  from vwUSERS_List" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						sb.Append("&Users=" + Sql.ToString(cmd.ExecuteScalar()));
					}
					sSQL = "select count(*)    " + ControlChars.CrLf
					     + "  from vwUSERS     " + ControlChars.CrLf
					     + " where IS_ADMIN = 1" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						sb.Append("&Admins=" + Sql.ToString(cmd.ExecuteScalar()));
					}
					sSQL = "select count(*)    " + ControlChars.CrLf
					     + "  from vwUSERS     " + ControlChars.CrLf
					     + " where IS_GROUP = 1" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						sb.Append("&Groups=" + Sql.ToString(cmd.ExecuteScalar()));
					}
					/*
					// Remove redundant information. 
					sSQL = "select count(*)    " + ControlChars.CrLf
					     + "  from vwUSERS     " + ControlChars.CrLf
					     + " where (IS_ADMIN is null or IS_ADMIN = 0)" + ControlChars.CrLf
					     + "   and (IS_GROUP is null or IS_GROUP = 0)" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						sb.Append("&Registered=" + Sql.ToString(cmd.ExecuteScalar()));
					}
					*/
					// 01/14/2008 Paul.  SQL Server 2000 cannot count unique Guids. 
					sSQL = "select count(distinct cast(USER_ID as char(36)))" + ControlChars.CrLf
					     + "  from TRACKER                      " + ControlChars.CrLf
					     + " where DATE_ENTERED >= @DATE_ENTERED" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						Sql.AddParameter(cmd, "@DATE_ENTERED", DateTime.Today.AddMonths(-1));
						sb.Append("&Activity=" + Sql.ToString(cmd.ExecuteScalar()));
					}

					// 01/14/2008 Paul.  Put the OS Version and SQL Version at the end as they may get truncated. 
					// INETLOG only saves the first 255 of the query string. 
					sSQL = "select Version     " + ControlChars.CrLf
					     + "  from vwSqlVersion" + ControlChars.CrLf;
					using ( IDbCommand cmd = con.CreateCommand() )
					{
						cmd.CommandText = sSQL;
						string sDBVersion = Sql.ToString(cmd.ExecuteScalar());
						sDBVersion = sDBVersion.Replace("Microsoft ", "");
						sDBVersion = sDBVersion.Replace("Intel "    , "");
						sb.Append("&DB=" + HttpUtility.UrlEncode(sDBVersion));
					}
				}
			}
			catch //(Exception ex)
			{
			}
			string sOSVersion = System.Environment.OSVersion.ToString();
			sOSVersion = sOSVersion.Replace("Microsoft "  , "");
			sOSVersion = sOSVersion.Replace("Service Pack", "SP");
			sb.Append("&OS="      + HttpUtility.UrlEncode(sOSVersion));
			// 01/19/2008 Paul.  The application path seems useful, but will usually be /SplendidCRM. 
			sb.Append("&AppPath=" + HttpUtility.UrlEncode(Sql.ToString(Application["ApplicationPath"     ])));
			// 01/19/2008 Paul.  The second least is the .NET version because it will almost always be the current shipping version. 
			sb.Append("&System="  + HttpUtility.UrlEncode(System.Environment.Version.ToString()            ));
			// 01/19/2008 Paul.  The least important piece of information is the SugarVersion.  
			// 06/29/2011 Paul.  Sugar compatibility is no longer useful. 
			//sb.Append("&Sugar="   + HttpUtility.UrlEncode(Sql.ToString(Application["CONFIG.sugar_version"])));
			return sb.ToString();
		}

		// 06/27/2009 Paul.  Add quick function to select a single item in a listbox. 
		public static void SelectItem(ListBox lst, string sValue)
		{
			foreach ( ListItem itm in lst.Items )
			{
				if ( String.Compare(itm.Value, sValue, true) == 0 )
					itm.Selected = true;
			}
		}

		// 12/20/2009 Paul.  Use our own encoding so that a space does not get converted to a +. 
		// 12/20/2009 Paul.  UrlPathEncode converts a space to a %20 whereas UrlEncode converts a space to +. 
		// http://jeays.net/asp.htm
		// http://msdn.microsoft.com/en-us/library/system.web.httpserverutility.urlpathencode.aspx
		public static string ContentDispositionEncode(HttpBrowserCapabilities Browser, string sURL)
		{
			// 01/27/2011 Paul.  Don't use GetFileName as the name may contain reserved directory characters, but expect them to be removed in Utils.ContentDispositionEncode. 
			sURL = sURL.Replace('\\', '_');
			sURL = sURL.Replace(':' , '_');
			// 12/20/2009 Paul.  Make sure that the URL is not null. 
			sURL = Sql.ToString(sURL);
			if ( Browser != null )
			{
				if ( Browser.Browser == "IE" )
				{
					sURL = HttpUtility.UrlPathEncode(sURL);
				}
			}
			sURL = "\"" + sURL + "\"";
			return sURL;
		}

		public static string GenerateVCard(DataRow row)
		{
			StringBuilder sbVCard = new StringBuilder();
			sbVCard.AppendLine("BEGIN:VCARD");
			sbVCard.AppendLine("VERSION:3.0");
			Guid     gID                         = Sql.ToGuid    (row["ID"                        ]);
			string   sSALUTATION                 = Sql.ToString  (row["SALUTATION"                ]).Trim();
			string   sNAME                       = Sql.ToString  (row["NAME"                      ]).Trim();
			string   sFIRST_NAME                 = Sql.ToString  (row["FIRST_NAME"                ]).Trim();
			string   sLAST_NAME                  = Sql.ToString  (row["LAST_NAME"                 ]).Trim();
			string   sTITLE                      = Sql.ToString  (row["TITLE"                     ]).Trim();
			string   sPHONE_HOME                 = Sql.ToString  (row["PHONE_HOME"                ]).Trim();
			string   sPHONE_MOBILE               = Sql.ToString  (row["PHONE_MOBILE"              ]).Trim();
			string   sPHONE_WORK                 = Sql.ToString  (row["PHONE_WORK"                ]).Trim();
			string   sPHONE_OTHER                = Sql.ToString  (row["PHONE_OTHER"               ]).Trim();
			string   sPHONE_FAX                  = Sql.ToString  (row["PHONE_FAX"                 ]).Trim();
			string   sEMAIL1                     = Sql.ToString  (row["EMAIL1"                    ]).Trim();
			string   sEMAIL2                     = Sql.ToString  (row["EMAIL2"                    ]).Trim();
			string   sASSISTANT                  = Sql.ToString  (row["ASSISTANT"                 ]).Trim();
			string   sASSISTANT_PHONE            = Sql.ToString  (row["ASSISTANT_PHONE"           ]).Trim();
			string   sPRIMARY_ADDRESS_STREET     = Sql.ToString  (row["PRIMARY_ADDRESS_STREET"    ]).Trim();
			string   sPRIMARY_ADDRESS_CITY       = Sql.ToString  (row["PRIMARY_ADDRESS_CITY"      ]).Trim();
			string   sPRIMARY_ADDRESS_STATE      = Sql.ToString  (row["PRIMARY_ADDRESS_STATE"     ]).Trim();
			string   sPRIMARY_ADDRESS_POSTALCODE = Sql.ToString  (row["PRIMARY_ADDRESS_POSTALCODE"]).Trim();
			string   sPRIMARY_ADDRESS_COUNTRY    = Sql.ToString  (row["PRIMARY_ADDRESS_COUNTRY"   ]).Trim();
			string   sALT_ADDRESS_STREET         = Sql.ToString  (row["ALT_ADDRESS_STREET"        ]).Trim();
			string   sALT_ADDRESS_CITY           = Sql.ToString  (row["ALT_ADDRESS_CITY"          ]).Trim();
			string   sALT_ADDRESS_STATE          = Sql.ToString  (row["ALT_ADDRESS_STATE"         ]).Trim();
			string   sALT_ADDRESS_POSTALCODE     = Sql.ToString  (row["ALT_ADDRESS_POSTALCODE"    ]).Trim();
			string   sALT_ADDRESS_COUNTRY        = Sql.ToString  (row["ALT_ADDRESS_COUNTRY"       ]).Trim();
			string   sACCOUNT_NAME               = Sql.ToString  (row["ACCOUNT_NAME"              ]).Trim();
			DateTime dtBIRTHDATE                 = DateTime.MinValue;
			// 01/01/2011 Paul.  The Leads module will not have a BIRTHDATE field. 
			if ( row.Table.Columns.Contains("BIRTHDATE") )
				dtBIRTHDATE = Sql.ToDateTime(row["BIRTHDATE"                 ]);
			DateTime dtDATE_MODIFIED_UTC         = Sql.ToDateTime(row["DATE_MODIFIED_UTC"         ]);

			sPRIMARY_ADDRESS_STREET = sPRIMARY_ADDRESS_STREET.Replace("\r\n", "\n");
			sPRIMARY_ADDRESS_STREET = sPRIMARY_ADDRESS_STREET.Replace("\r"  , "\n");
			sALT_ADDRESS_STREET     = sALT_ADDRESS_STREET    .Replace("\r\n", "\n");
			sALT_ADDRESS_STREET     = sALT_ADDRESS_STREET    .Replace("\r"  , "\n");
			string sADDRESS1 = String.Empty;
			string sADDRESS2 = String.Empty;
			if ( !Sql.IsEmptyString(sPRIMARY_ADDRESS_STREET) )
			{
				string[] arrPRIMARY_ADDRESS_STREET = sPRIMARY_ADDRESS_STREET.Split('\n');
				string sPRIMARY_ADDRESS_STREET1 = String.Empty;
				string sPRIMARY_ADDRESS_STREET2 = String.Empty;
				string sPRIMARY_ADDRESS_STREET3 = String.Empty;
				if ( arrPRIMARY_ADDRESS_STREET.Length == 1 )
				{
					sPRIMARY_ADDRESS_STREET3 = arrPRIMARY_ADDRESS_STREET[0];
				}
				else if ( arrPRIMARY_ADDRESS_STREET.Length == 2 )
				{
					sPRIMARY_ADDRESS_STREET2 = arrPRIMARY_ADDRESS_STREET[0];
					sPRIMARY_ADDRESS_STREET3 = arrPRIMARY_ADDRESS_STREET[1];
				}
				else if ( arrPRIMARY_ADDRESS_STREET.Length >= 3 )
				{
					sPRIMARY_ADDRESS_STREET1 = arrPRIMARY_ADDRESS_STREET[0];
					sPRIMARY_ADDRESS_STREET2 = arrPRIMARY_ADDRESS_STREET[1];
					sPRIMARY_ADDRESS_STREET3 = arrPRIMARY_ADDRESS_STREET[2];
				}
				sADDRESS1  =       sPRIMARY_ADDRESS_STREET1   ;  // 1. Post Office Address
				sADDRESS1 += ";" + sPRIMARY_ADDRESS_STREET2   ;  // 2. Extended Address
				sADDRESS1 += ";" + sPRIMARY_ADDRESS_STREET3   ;  // 3. Street
				sADDRESS1 += ";" + sPRIMARY_ADDRESS_CITY      ;  // 4. Locality
				sADDRESS1 += ";" + sPRIMARY_ADDRESS_STATE     ;  // 5. Region
				sADDRESS1 += ";" + sPRIMARY_ADDRESS_POSTALCODE;  // 6. Postal Code
				sADDRESS1 += ";" + sPRIMARY_ADDRESS_COUNTRY   ;  // 7. Country
				//sADDRESS1 = sADDRESS1.Replace("\n", "=0D=0A\n");
			}
			if ( !Sql.IsEmptyString(sALT_ADDRESS_STREET) )
			{
				string[] arrALT_ADDRESS_STREET = sALT_ADDRESS_STREET.Split('\n');
				string sALT_ADDRESS_STREET1 = String.Empty;
				string sALT_ADDRESS_STREET2 = String.Empty;
				string sALT_ADDRESS_STREET3 = String.Empty;
				if ( arrALT_ADDRESS_STREET.Length == 1 )
				{
					sALT_ADDRESS_STREET3 = arrALT_ADDRESS_STREET[0];
				}
				else if ( arrALT_ADDRESS_STREET.Length == 2 )
				{
					sALT_ADDRESS_STREET2 = arrALT_ADDRESS_STREET[0];
					sALT_ADDRESS_STREET3 = arrALT_ADDRESS_STREET[1];
				}
				else if ( arrALT_ADDRESS_STREET.Length >= 3 )
				{
					sALT_ADDRESS_STREET1 = arrALT_ADDRESS_STREET[0];
					sALT_ADDRESS_STREET2 = arrALT_ADDRESS_STREET[1];
					sALT_ADDRESS_STREET3 = arrALT_ADDRESS_STREET[2];
				}
				sADDRESS2  =       sALT_ADDRESS_STREET1       ;  // 1. Post Office Address
				sADDRESS2 += ";" + sALT_ADDRESS_STREET2       ;  // 2. Extended Address
				sADDRESS2 += ";" + sALT_ADDRESS_STREET3       ;  // 3. Street
				sADDRESS2 += ";" + sALT_ADDRESS_CITY          ;  // 4. Locality
				sADDRESS2 += ";" + sALT_ADDRESS_STATE         ;  // 5. Region
				sADDRESS2 += ";" + sALT_ADDRESS_POSTALCODE    ;  // 6. Postal Code
				sADDRESS2 += ";" + sALT_ADDRESS_COUNTRY       ;  // 7. Country
				//sADDRESS2 = sADDRESS2.Replace("\n", "=0D=0A\n");
			}
			
			// http://en.wikipedia.org/wiki/VCard
			// http://www.imc.org/pdi/vcard-21.doc
			sbVCard.AppendLine("N:"  + sLAST_NAME + ";" + sFIRST_NAME + (Sql.IsEmptyString(sSALUTATION) ? String.Empty : ";" + sSALUTATION));
			sbVCard.AppendLine("FN:" + (sSALUTATION + " " + sNAME).Trim());
			if ( !Sql.IsEmptyString(sACCOUNT_NAME) ) sbVCard.AppendLine("ORG:"                 + sACCOUNT_NAME);
			if ( !Sql.IsEmptyString(sTITLE       ) ) sbVCard.AppendLine("TITLE:"               + sTITLE       );
			if ( !Sql.IsEmptyString(sPHONE_HOME  ) ) sbVCard.AppendLine("TEL;TYPE=HOME,VOICE:" + sPHONE_HOME  );
			if ( !Sql.IsEmptyString(sPHONE_MOBILE) ) sbVCard.AppendLine("TEL;TYPE=CELL,VOICE:" + sPHONE_MOBILE);
			if ( !Sql.IsEmptyString(sPHONE_WORK  ) ) sbVCard.AppendLine("TEL;TYPE=WORK,VOICE:" + sPHONE_WORK  );
			if ( !Sql.IsEmptyString(sPHONE_FAX   ) ) sbVCard.AppendLine("TEL;TYPE=WORK,FAX:"   + sPHONE_FAX   );
			if ( !Sql.IsEmptyString(sEMAIL1      ) ) sbVCard.AppendLine("EMAIL;TYPE=INTERNET:" + sEMAIL1      );
			if ( !Sql.IsEmptyString(sASSISTANT   ) ) sbVCard.AppendLine("X-ASSISTANT:"         + sASSISTANT   );
			if ( !Sql.IsEmptyString(sADDRESS1    ) ) sbVCard.AppendLine("ADR;TYPE=WORK"        + (sADDRESS1.IndexOf("=0A=0D") >= 0 ? ";ENCODING=QUOTED-PRINTABLE" : String.Empty) + ":" + sADDRESS1);
			if ( !Sql.IsEmptyString(sADDRESS2    ) ) sbVCard.AppendLine("ADR;TYPE=OTHER"       + (sADDRESS2.IndexOf("=0A=0D") >= 0 ? ";ENCODING=QUOTED-PRINTABLE" : String.Empty) + ":" + sADDRESS2);
			if ( dtBIRTHDATE != DateTime.MinValue  ) sbVCard.AppendLine("BDAY:"                + dtBIRTHDATE.ToString("yyyy-MM-dd"));
			sbVCard.AppendLine("UID:" + gID.ToString());
			// 01/11/2012 Paul.  REV not REF. 
			sbVCard.AppendLine("REV:" + dtDATE_MODIFIED_UTC.ToString("yyyyMMddTHHmmssZ"));
			sbVCard.AppendLine("END:VCARD");
			return sbVCard.ToString();
		}

		public static string CalDAV_Unescape(string s)
		{
			s = s.Replace("\\," , "," );
			s = s.Replace("\\;" , ";" );
			s = s.Replace("\\n" , "\n");
			s = s.Replace("\\N" , "\n");
			s = s.Replace("\\\\", "\\");
			return s;
		}

		public static string CalDAV_Escape(string s)
		{
			s = s.Replace("\\"  , "\\\\");
			s = s.Replace("\r\n", "\n"  );
			s = s.Replace("\r"  , "\n"  );
			s = s.Replace("\n"  , "\\n" );
			s = s.Replace(","   , "\\," );
			s = s.Replace(";"   , "\\;" );
			s = s.Replace("\n"  , "\\n" );
			return s;
		}

		public static string CalDAV_FoldLines(string s)
		{
			StringBuilder sb = new StringBuilder();
			using ( TextReader rdr = new StringReader(s) )
			{
				char[] arr = new char[75];
				int n = 0;
				while ( (n = rdr.ReadBlock(arr, 0, 75)) > 0 )
				{
					if ( sb.Length > 0 )
						sb.Append("\r\n ");
					sb.Append(arr, 0, n);
				}
			}
			return sb.ToString();
		}

		public static DateTime CalDAV_ParseDate(string sDate)
		{
			System.Globalization.DateTimeFormatInfo dateInfo = System.Threading.Thread.CurrentThread.CurrentCulture.DateTimeFormat;
			DateTime date = DateTime.MinValue;
			if ( sDate.EndsWith("Z") )
			{
				if ( sDate.Contains("-") )
				{
					if ( DateTime.TryParseExact(sDate, "yyyy-MM-ddTHH:mm:ssZ", dateInfo, System.Globalization.DateTimeStyles.AssumeUniversal, out date) )
						date = date.ToLocalTime();
				}
				else
				{
					if ( DateTime.TryParseExact(sDate, "yyyyMMddTHHmmssZ"    , dateInfo, System.Globalization.DateTimeStyles.AssumeUniversal, out date) )
						date = date.ToLocalTime();
				}
			}
			// 02/12/2012 Paul.  An All-Day event does not include the time in the date strings. 
			else if ( sDate.Length == 8 )
			{
				if ( sDate.Contains("-") )
					DateTime.TryParseExact(sDate, "yyyy-MM-dd", dateInfo, System.Globalization.DateTimeStyles.AssumeLocal, out date);
				else
					DateTime.TryParseExact(sDate, "yyyyMMdd"  , dateInfo, System.Globalization.DateTimeStyles.AssumeLocal, out date);
			}
			else
			{
				if ( sDate.Contains("-") )
					DateTime.TryParseExact(sDate, "yyyy-MM-ddTHH:mm:ss", dateInfo, System.Globalization.DateTimeStyles.AssumeLocal, out date);
				else
					DateTime.TryParseExact(sDate, "yyyyMMddTHHmmss"    , dateInfo, System.Globalization.DateTimeStyles.AssumeLocal, out date);
			}
			return date;
		}

		// 09/09/2015 Paul.  Recurrence parsing for Google Calendar and for iCloud. 
		public static void CalDAV_ParseRule(string sRRULE, ref string sREPEAT_TYPE, ref int nREPEAT_INTERVAL, ref string sREPEAT_DOW, ref DateTime dtREPEAT_UNTIL, ref int nREPEAT_COUNT)
		{
			int nBeginTimezone = sRRULE.IndexOf("BEGIN:VTIMEZONE");
			if ( nBeginTimezone > 0 )
			{
				sRRULE = sRRULE.Substring(0, nBeginTimezone).Trim();
			}
			sREPEAT_TYPE     = String.Empty     ;
			nREPEAT_INTERVAL = 0                ;
			sREPEAT_DOW      = String.Empty     ;
			dtREPEAT_UNTIL   = DateTime.MinValue;
			nREPEAT_COUNT    = 0                ;
			// 09/09/2015 Paul.  Add the trailing separator to simplify parsing. 
			sRRULE += ";";
			
			// RFC5545
			// https://tools.ietf.org/html/rfc5545#section-3.3.10
			if ( sRRULE.Contains("FREQ=DAILY") )
				sREPEAT_TYPE = "Daily";
			else if ( sRRULE.Contains("FREQ=WEEKLY") )
				sREPEAT_TYPE = "Weekly";
			else if ( sRRULE.Contains("FREQ=MONTHLY") )
				sREPEAT_TYPE = "Monthly";
			else if ( sRRULE.Contains("FREQ=YEARLY") )
				sREPEAT_TYPE = "Yearly";
			
			if ( sRRULE.Contains("INTERVAL=") )
			{
				int nStart = sRRULE.IndexOf("INTERVAL=") + "INTERVAL=".Length;
				int nEnd   = sRRULE.IndexOf(";", nStart);
				string sREPEAT_INTERVAL = sRRULE.Substring(nStart, nEnd - nStart);
				nREPEAT_INTERVAL = Sql.ToInteger(sREPEAT_INTERVAL);
			}
			
			if ( sRRULE.Contains("BYDAY=") )
			{
				int nStart = sRRULE.IndexOf("BYDAY=") + "BYDAY=".Length;
				int nEnd   = sRRULE.IndexOf(";", nStart);
				string sGOOGLE_DOW = sRRULE.Substring(nStart , nEnd - nStart);
				sREPEAT_DOW = String.Empty;
				if ( sGOOGLE_DOW.Contains("SU") ) sREPEAT_DOW += "0";
				if ( sGOOGLE_DOW.Contains("MO") ) sREPEAT_DOW += "1";
				if ( sGOOGLE_DOW.Contains("TU") ) sREPEAT_DOW += "2";
				if ( sGOOGLE_DOW.Contains("WE") ) sREPEAT_DOW += "3";
				if ( sGOOGLE_DOW.Contains("TH") ) sREPEAT_DOW += "4";
				if ( sGOOGLE_DOW.Contains("FR") ) sREPEAT_DOW += "5";
				if ( sGOOGLE_DOW.Contains("SA") ) sREPEAT_DOW += "6";
			}
			
			if ( sRRULE.Contains("UNTIL=") )
			{
				int nStart = sRRULE.IndexOf("UNTIL=") + "UNTIL=".Length;
				int nEnd   = sRRULE.IndexOf(";", nStart);
				dtREPEAT_UNTIL = Utils.CalDAV_ParseDate(sRRULE.Substring(nStart , nEnd - nStart));
			}
			
			if ( sRRULE.Contains("COUNT=") )
			{
				int nStart = sRRULE.IndexOf("COUNT=") + "COUNT=".Length;
				int nEnd   = sRRULE.IndexOf(";", nStart);
				string sREPEAT_COUNT = sRRULE.Substring(nStart, nEnd - nStart);
				nREPEAT_COUNT = Sql.ToInteger(sREPEAT_COUNT);
			}
		}


		public static string CalDAV_BuildRule(string sREPEAT_TYPE, int nREPEAT_INTERVAL, string sREPEAT_DOW, DateTime dtREPEAT_UNTIL, int nREPEAT_COUNT)
		{
			string sRRULE = String.Empty;
			switch ( sREPEAT_TYPE )
			{
				case "Daily":
					sRRULE += "RRULE:FREQ=DAILY";
					break;
				case "Weekly":
					if ( !Sql.IsEmptyString(sREPEAT_DOW) )
					{
						sRRULE += "RRULE:FREQ=WEEKLY";
						string sCalDAV_DOW = String.Empty;
						for ( int n = 0; n < sREPEAT_DOW.Length; n++ )
						{
							if ( sCalDAV_DOW.Length > 0 )
								sCalDAV_DOW += ",";
							switch ( sREPEAT_DOW.Substring(n, 1) )
							{
								case "0":  sCalDAV_DOW += "SU";  break;
								case "1":  sCalDAV_DOW += "MO";  break;
								case "2":  sCalDAV_DOW += "TU";  break;
								case "3":  sCalDAV_DOW += "WE";  break;
								case "4":  sCalDAV_DOW += "TH";  break;
								case "5":  sCalDAV_DOW += "FR";  break;
								case "6":  sCalDAV_DOW += "SA";  break;
							}
						}
						sRRULE += ";BYDAY=" + sCalDAV_DOW;
					}
					break;
				case "Monthly":
					sRRULE += "RRULE:FREQ=MONTHLY";
					break;
				case "Yearly":
					sRRULE += "RRULE:FREQ=YEARLY";
					break;
			}
			if ( !Sql.IsEmptyString(sRRULE) )
			{
				if ( nREPEAT_INTERVAL > 1 )
					sRRULE += ";INTERVAL=" + nREPEAT_INTERVAL.ToString();
				if ( nREPEAT_COUNT > 0 )
					sRRULE += ";COUNT=" + nREPEAT_COUNT.ToString();
				if ( dtREPEAT_UNTIL != DateTime.MinValue )
					sRRULE += ";UNTIL:" + dtREPEAT_UNTIL.ToString("yyyyMMdd");
			}
			return sRRULE;
		}

		// 12/27/2012 Paul.  VCalendar is used by the email reminders. 
		public static string GenerateVCalendar(DataRow row, bool bIncludeAlarm)
		{
			StringBuilder sbVCalendar = new StringBuilder();
			sbVCalendar.AppendLine("BEGIN:VCALENDAR");
			sbVCalendar.AppendLine("VERSION:2.0");
			sbVCalendar.AppendLine("CALSCALE:GREGORIAN");
			sbVCalendar.AppendLine("PRODID:-//CALENDARSERVER.ORG//NONSGML Version 1//EN");
			// 12/27/2012 Paul.  Outlook 2010 requires the Publish method, otherwise it will rename the file "not supported calendar message.ics". 
			sbVCalendar.AppendLine("METHOD:PUBLISH");
			// 01/05/2012 Paul.  Lets try not using the timezone data and instead store date in UTC format. 
			/*
			SplendidCRM.TimeZone oTimeZone = Context.Application["TIMEZONE.TZID." + this.TZID] as SplendidCRM.TimeZone;
			if ( oTimeZone == null )
				oTimeZone = Context.Application["TIMEZONE.TZID.America/New_York"] as SplendidCRM.TimeZone;
			if ( oTimeZone == null )
			{
				sbVCalendar.AppendLine("BEGIN:VTIMEZONE");
				sbVCalendar.AppendLine("TZID:"           + oTimeZone.TZID);
				sbVCalendar.AppendLine("TZURL:"          + "http://tzurl.org/zoneinfo-outlook/" + oTimeZone.TZID);
				sbVCalendar.AppendLine("X-LIC-LOCATION:" + oTimeZone.TZID);
				sbVCalendar.AppendLine("BEGIN:DAYLIGHT" );
				sbVCalendar.AppendLine("TZOFFSETFROM:"   + (- oTimeZone.Bias/60).ToString("00") + (oTimeZone.Bias % 60).ToString("00") );
				sbVCalendar.AppendLine("TZOFFSETTO:"     + (-(oTimeZone.Bias + oTimeZone.StandardBias)/60).ToString("00") + (oTimeZone.Bias % 60).ToString("00") );
				sbVCalendar.AppendLine("TZNAME:"         + oTimeZone.DaylightAbbreviation);
				// 01/02/2012 Paul.  Need to figure out how to convert week to 08.  There does not seem to be a clear pattern in the zoneinfo-outlook data. 
				sbVCalendar.AppendLine("DTSTART:"        + "1970" + oTimeZone.DaylightDateMonth.ToString("00") + "08" + "T" + oTimeZone.DaylightDateHour.ToString("00") + oTimeZone.DaylightDateMinute.ToString("00") + "00");
				sbVCalendar.AppendLine("RRULE:"          + "FREQ=YEARLY;BYDAY=" + oTimeZone.DaylightDateWeek.ToString() + "SU;BYMONTH=" + oTimeZone.DaylightDateMonth.ToString());
				sbVCalendar.AppendLine("END:DAYLIGHT"   );
				sbVCalendar.AppendLine("BEGIN:STANDARD" );
				sbVCalendar.AppendLine("TZOFFSETFROM:"   + (- oTimeZone.Bias/60).ToString("00") + (oTimeZone.Bias % 60).ToString("00") );
				sbVCalendar.AppendLine("TZOFFSETTO:"     + (-(oTimeZone.Bias + oTimeZone.StandardBias)/60).ToString("00") + (oTimeZone.Bias % 60).ToString("00") );
				sbVCalendar.AppendLine("TZNAME:"         + oTimeZone.StandardAbbreviation);
				// 01/02/2012 Paul.  Need to figure out how to convert week to 01.  There does not seem to be a clear pattern in the zoneinfo-outlook data. 
				sbVCalendar.AppendLine("DTSTART:"        + "1970" + oTimeZone.StandardDateMonth.ToString("00") + "01" + "T" + oTimeZone.StandardDateHour.ToString("00") + oTimeZone.StandardDateMinute.ToString("00") + "00");
				sbVCalendar.AppendLine("RRULE:"          + "FREQ=YEARLY;BYDAY=" + oTimeZone.StandardDateWeek.ToString() + "SU;BYMONTH=" + oTimeZone.StandardDateMonth.ToString());
				sbVCalendar.AppendLine("END:STANDARD"   );
				sbVCalendar.AppendLine("END:VTIMEZONE"  );
			}
			*/
			
			sbVCalendar.AppendLine("BEGIN:VEVENT");
			sbVCalendar.AppendLine("CLASS:PUBLIC");
			sbVCalendar.AppendLine("SEQUENCE:0");
			sbVCalendar.AppendLine("UID:"           + Sql.ToGuid(row["ID"]).ToString());
			sbVCalendar.AppendLine("CREATED:"       + Sql.ToDateTime(row["DATE_ENTERED" ]).ToUniversalTime().ToString("yyyyMMddTHHmmssZ"));
			// 01/15/2012 Paul.  Not sure why, but DTSTAMP is not UTC time as it is 4 hours from the LAST-MODIFIED. 
			// DTSTAMP should be placed before LAST-MODIFIED so that LAST-MODIFIED is the last value used. 
			sbVCalendar.AppendLine("DTSTAMP:"       + Sql.ToDateTime(row["DATE_MODIFIED"]).ToUniversalTime().ToString("yyyyMMddTHHmmssZ"));
			sbVCalendar.AppendLine("LAST-MODIFIED:" + Sql.ToDateTime(row["DATE_MODIFIED"]).ToUniversalTime().ToString("yyyyMMddTHHmmssZ"));
			// 01/07/2012 Paul.  The folding includes the line header. RFC 5545 Page 9. 
			sbVCalendar.AppendLine(CalDAV_FoldLines("SUMMARY:" + CalDAV_Escape(Sql.ToString(row["NAME"]))));
			if ( !Sql.IsEmptyString(row["DESCRIPTION"]) )
			{
				// 01/05/2012 Paul.  The VCalendar spec requires that we split the line at 75 characters. 
				// We are not going to do that unless iCloud crashes or rejects the data. 
				sbVCalendar.AppendLine(CalDAV_FoldLines("DESCRIPTION:" + CalDAV_Escape(Sql.ToString(row["DESCRIPTION"]))));
			}
			if ( !Sql.IsEmptyString(row["LOCATION"]) )
				sbVCalendar.AppendLine("LOCATION:"  + Sql.ToString(row["LOCATION"]));
			
			int nDURATION_HOURS   = Sql.ToInteger(row["DURATION_HOURS"  ]);
			int nDURATION_MINUTES = Sql.ToInteger(row["DURATION_MINUTES"]);
			DateTime dtDATE_START = Sql.ToDateTime(row["DATE_START"]);
			DateTime dtDATE_END   = Sql.ToDateTime(row["DATE_END"  ]);
			// 01/05/2012 Paul.  Lets try not using the timezone data and instead store date in UTC format.  RFC 5545 Page 34. 
			//sbVCalendar.AppendLine("DTSTART;TZID=" + this.TZID + ":" + this.Times[0].StartTime.ToString("yyyyMMddTHHmmss"));
			//sbVCalendar.AppendLine("DTEND;TZID="   + this.TZID + ":" + this.Times[0].EndTime  .ToString("yyyyMMddTHHmmss"));
			// 02/12/2012 Paul.  An All-Day event does not include the time in the date strings. 
			if ( nDURATION_HOURS == 24 )
			{
				sbVCalendar.AppendLine("DTSTART:" + dtDATE_START.ToString("yyyyMMdd"));
				sbVCalendar.AppendLine("DTEND:"   + dtDATE_END  .ToString("yyyyMMdd"));
			}
			else
			{
				sbVCalendar.AppendLine("DTSTART:" + dtDATE_START.ToUniversalTime().ToString("yyyyMMddTHHmmss") + "Z");
				sbVCalendar.AppendLine("DTEND:"   + dtDATE_END  .ToUniversalTime().ToString("yyyyMMddTHHmmss") + "Z");
			}

			StringBuilder sbWho = new StringBuilder();
			if ( Sql.ToGuid(row["INVITEE_ID"]) == Sql.ToGuid(row["ASSIGNED_USER_ID"]) )
				sbWho.Append("ORGANIZER");
			else
				sbWho.Append("ATTENDEE");
			if ( !Sql.IsEmptyString(row["ACCEPT_STATUS"]) )
			{
				sbWho.Append(";PARTSTAT=");
				switch ( Sql.ToString(row["ACCEPT_STATUS"]) )
				{
					case "accept"   :  sbWho.Append("ACCEPTED" );  break;
					case "decline"  :  sbWho.Append("DECLINED" );  break;
					case "none"     :  sbWho.Append("INVITED"  );  break;
					case "tentative":  sbWho.Append("TENTATIVE");  break;
				}
			}
			sbWho.Append(";CN=" + (Sql.ToString(row["FIRST_NAME"]) + " " + Sql.ToString(row["LAST_NAME"])).Trim());
			if ( !Sql.IsEmptyString(row["EMAIL1"]) )
				sbWho.Append(":mailto:" + Sql.ToString(row["EMAIL1"]));
			else
				sbWho.Append(":invalid:nomail");
			sbVCalendar.AppendLine(CalDAV_FoldLines(sbWho.ToString()));
			
			int nREMINDER_MINUTES = Sql.ToInteger(row["REMINDER_TIME"]) / 60;
			if ( bIncludeAlarm && nREMINDER_MINUTES > 0 )
			{
				StringBuilder sbAlarm = new StringBuilder();
				sbAlarm.AppendLine("BEGIN:VALARM");
				sbAlarm.AppendLine("ACTION:" + "DISPLAY");
				sbAlarm.AppendLine(CalDAV_FoldLines("DESCRIPTION:" + CalDAV_Escape("Event reminder")));
				if ( nREMINDER_MINUTES / (24 * 60) > 0 )
					sbAlarm.AppendLine("TRIGGER;VALUE=DURATION:" + "-P" + nREMINDER_MINUTES / (24 * 60)  + "D");
				else if ( nREMINDER_MINUTES % 60 == 0 )
					sbAlarm.AppendLine("TRIGGER;VALUE=DURATION:" + "-PT" + nREMINDER_MINUTES / 60  + "H");
				else
					sbAlarm.AppendLine("TRIGGER;VALUE=DURATION:" + "-PT" + nREMINDER_MINUTES + "M");
				sbAlarm.AppendLine("X-WR-ALARMUID:" + Guid.NewGuid().ToString());
				sbAlarm.AppendLine("END:VALARM");
				sbVCalendar.Append(sbAlarm);
			}
			sbVCalendar.AppendLine("END:VEVENT");

			sbVCalendar.AppendLine("END:VCALENDAR");
			return sbVCalendar.ToString();
		}

		// 07/27/2012 Paul.  Match the normalization within database function fnNormalizePhone. 
		public static string NormalizePhone(string sPhoneNumber)
		{
			sPhoneNumber = Sql.ToString(sPhoneNumber);
			sPhoneNumber = sPhoneNumber.Replace(" ", String.Empty);
			sPhoneNumber = sPhoneNumber.Replace("+", String.Empty);
			sPhoneNumber = sPhoneNumber.Replace("(", String.Empty);
			sPhoneNumber = sPhoneNumber.Replace(")", String.Empty);
			sPhoneNumber = sPhoneNumber.Replace("-", String.Empty);
			sPhoneNumber = sPhoneNumber.Replace(".", String.Empty);
			// 08/08/2018 Paul.  Use like clause for more flexible phone number lookup. 
			sPhoneNumber = sPhoneNumber.Replace("[", String.Empty);
			sPhoneNumber = sPhoneNumber.Replace("]", String.Empty);
			sPhoneNumber = sPhoneNumber.Replace("#", String.Empty);
			sPhoneNumber = sPhoneNumber.Replace("*", String.Empty);
			sPhoneNumber = sPhoneNumber.Replace("%", String.Empty);
			return sPhoneNumber;
		}

		// 08/25/2013 Paul.  File IO is slow, so cache existance test. 
		public static bool CachedFileExists(HttpContext Context, string sVirtualPath)
		{
			int nFileExists = Sql.ToInteger(Context.Application["Exists." + sVirtualPath]);
			if ( nFileExists == 0 )
			{
				if ( File.Exists(Context.Server.MapPath(sVirtualPath)) )
					nFileExists = 1;
				else
					nFileExists = -1;
				Context.Application["Exists." + sVirtualPath] = nFileExists;
			}
			return nFileExists == 1;
		}

		// 08/30/2013 Paul.  Move jQuery registration to Utils class. 
		public static void RegisterJQuery(Page Page, ScriptManager mgrAjax)
		{
			if ( mgrAjax != null )
			{
				// 04/27/2012 Paul.  Need to add support for favorites as the icons are visible. 
				ServiceReference svc = new ServiceReference("~/Include/javascript/Utilities.asmx");
				ScriptReference  scr = new ScriptReference ("~/Include/javascript/Utilities.js"  );
				if ( !mgrAjax.Services.Contains(svc) ) mgrAjax.Services.Add(svc);
				if ( !mgrAjax.Scripts .Contains(scr) ) mgrAjax.Scripts .Add(scr);
				
				// 08/25/2013 Paul.  jQuery now registered in the master pages. 
				// 09/02/2013 Paul.  The jQuery UI stylesheet will now be manually embedded in the master pages. 
				//HtmlLink cssJQuery = new HtmlLink();
				//cssJQuery.Attributes.Add("href" , "~/Include/javascript/jquery-ui-1.9.1.custom.css");
				//cssJQuery.Attributes.Add("type" , "text/css"  );
				//cssJQuery.Attributes.Add("rel"  , "stylesheet");
				//Page.Header.Controls.Add(cssJQuery);
				
				// 08/28/2013 Paul.  json2.js now registered in the master pages. 
				ScriptReference scrJQuery   = new ScriptReference("~/Include/javascript/jquery-1.9.1.min.js"      );
				ScriptReference scrJQueryUI = new ScriptReference("~/Include/javascript/jquery-ui-1.9.1.custom.js");
				ScriptReference scrJSON2    = new ScriptReference("~/Include/javascript/json2.min.js"             );
				if ( !mgrAjax.Scripts.Contains(scrJQuery  ) ) mgrAjax.Scripts.Add(scrJQuery  );
				if ( !mgrAjax.Scripts.Contains(scrJQueryUI) ) mgrAjax.Scripts.Add(scrJQueryUI);
				if ( !mgrAjax.Scripts.Contains(scrJSON2   ) ) mgrAjax.Scripts.Add(scrJSON2   );
				
				// 01/17/2018 Paul.  multiple-select is failing on postback, so always include. 
				ScriptReference scrMultiSelect = new ScriptReference("~/html5/jQuery/multiple-select.js");
				if ( !mgrAjax.Scripts.Contains(scrMultiSelect) ) mgrAjax.Scripts.Add(scrMultiSelect);
				HtmlLink cssMultiSelect = new HtmlLink();
				cssMultiSelect.Attributes.Add("href" , "~/html5/jQuery/multiple-select.css");
				cssMultiSelect.Attributes.Add("type" , "text/css"  );
				cssMultiSelect.Attributes.Add("rel"  , "stylesheet");
				Page.Header.Controls.Add(cssMultiSelect);
			}
		}

// 11/03/2021 Paul.  ASP.Net components are not needed. 
#if !ReactOnlyUI
		// 03/14/2014 Paul.  DUPLICATE_CHECHING_ENABLED enables duplicate checking. 
		// Duplicate check for EditView will provide input data from Form variables. 
		public static int DuplicateCheck(HttpApplicationState Application, IDbConnection con, string sMODULE_NAME, Guid gID, SplendidControl ctl, DataRow rowCurrent)
		{
			int nDuplicates = 0;
			string sGRID_NAME = sMODULE_NAME + ".SearchDuplicates";
			// 05/10/2016 Paul.  The User Primary Role is used with role-based views. 
			DataTable dtGridView = SplendidCache.GridViewColumns(sGRID_NAME, Security.PRIMARY_ROLE_NAME);
			if ( dtGridView != null && dtGridView.Rows.Count > 0 )
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					string sTABLE_NAME = Crm.Modules.TableName(sMODULE_NAME);
					// 04/10/2014 Paul.  The first thought was just to use a count(*), but by getting all fields for matching records, we allow business rules to further filter the result. 
					cmd.CommandText = "select *" + ControlChars.CrLf
					                + "  from vw" + sTABLE_NAME + "_List" + ControlChars.CrLf;
					Security.Filter(cmd, sMODULE_NAME, "list");
					if ( !Sql.IsEmptyGuid(gID) )
					{
						cmd.CommandText += "  and ID <> @ID" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@ID", gID);
					}
					
					int nValues = 0;
					foreach(DataRow rowSearch in dtGridView.Rows)
					{
						string sDATA_FIELD  = Sql.ToString (rowSearch["DATA_FIELD" ]);
						string sDATA_FORMAT = Sql.ToString (rowSearch["DATA_FORMAT"]);
						// 03/16/2014 Paul.  When searching for duplicates, multiple fields can match, but don't match an empty field. 
						string sVALUE = new DynamicControl(ctl, rowCurrent, sDATA_FIELD).Text;
						if ( !Sql.IsEmptyString(sVALUE) )
						{
							Sql.AppendParameter(cmd, sVALUE, sDATA_FIELD);
							nValues++;
						}
					}
					// 03/16/2014 Paul.  If no required fields were specified, then don't search. 
					if ( nValues > 0 )
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dtDuplicates = new DataTable() )
							{
								da.Fill(dtDuplicates);

								SplendidDynamic.ApplyGridViewRules(sGRID_NAME, ctl, "PRE_LOAD_EVENT_XOML", "POST_LOAD_EVENT_XOML", dtDuplicates);
								foreach ( DataRow rowDuplicates in dtDuplicates.Rows )
								{
									if ( rowDuplicates.RowState != DataRowState.Deleted )
									{
										nDuplicates++;
									}
								}
							}
						}
					}
				}
			}
			return nDuplicates;
		}
#endif

		// 03/14/2014 Paul  Duplicate check from REST API will provide input data in a DataRow. 
		public static int DuplicateCheck(HttpApplicationState Application, IDbConnection con, string sMODULE_NAME, Guid gID, DataRow row, DataRow rowCurrent)
		{
			int nDuplicates = 0;
			string sGRID_NAME = sMODULE_NAME + ".SearchDuplicates";
			// 05/10/2016 Paul.  The User Primary Role is used with role-based views. 
			DataTable dtGridView = SplendidCache.GridViewColumns(sGRID_NAME, Security.PRIMARY_ROLE_NAME);
			if ( dtGridView != null && dtGridView.Rows.Count > 0 )
			{
				DbProviderFactory dbf = DbProviderFactories.GetFactory();
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					string sTABLE_NAME = Crm.Modules.TableName(sMODULE_NAME);
					cmd.CommandText = "select *                         " + ControlChars.CrLf
					                + "  from vw" + sTABLE_NAME + "_List" + ControlChars.CrLf;
					Security.Filter(cmd, sMODULE_NAME, "list");
					if ( !Sql.IsEmptyGuid(gID) )
					{
						cmd.CommandText += "  and ID <> @ID" + ControlChars.CrLf;
						Sql.AddParameter(cmd, "@ID", gID);
					}
					
					int nValues = 0;
					foreach(DataRow rowSearch in dtGridView.Rows)
					{
						string sDATA_FIELD  = Sql.ToString (rowSearch["DATA_FIELD" ]);
						string sDATA_FORMAT = Sql.ToString (rowSearch["DATA_FORMAT"]);
						string sVALUE       = String.Empty;
						// 03/06/2016 Paul.  The row table contains the data from the HTML5 service call. 
						if ( row.Table.Columns.Contains(sDATA_FIELD) )
							sVALUE = Sql.ToString(row[sDATA_FIELD]);
						// 08/26/2014 Paul.  Field may not exist in current record either. 
						// 03/08/2016 Paul.  rowCurrent will be null if this is a new record. 
						else if ( rowCurrent != null && rowCurrent.Table.Columns.Contains(sDATA_FIELD) )
							sVALUE = Sql.ToString(rowCurrent[sDATA_FIELD]);
						// 03/16/2014 Paul.  When searching for duplicates, multiple fields can match, but don't match an empty field. 
						if ( !Sql.IsEmptyString(sVALUE) )
						{
							Sql.AppendParameter(cmd, sVALUE, sDATA_FIELD);
							nValues++;
						}
					}
					// 03/16/2014 Paul.  If no required fields were specified, then don't search. 
					if ( nValues > 0 )
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dtDuplicates = new DataTable() )
							{
								da.Fill(dtDuplicates);
								SplendidDynamic.ApplyGridViewRules(sGRID_NAME, null, "PRE_LOAD_EVENT_XOML", "POST_LOAD_EVENT_XOML", dtDuplicates);
								foreach ( DataRow rowDuplicates in dtDuplicates.Rows )
								{
									if ( rowDuplicates.RowState != DataRowState.Deleted )
									{
										nDuplicates++;
									}
								}
							}
						}
					}
				}
			}
			return nDuplicates;
		}
	}

	// 09/26/2017 Paul.  Add Archive access right. 
	public class ArchiveUtils
	{
		private HttpContext Context          ;
		private Guid        gMODIFIED_USER_ID;
		private string      sCULTURE         ;
		private int         nACLACCESS       ;
		private string      ModuleName       ;
		private string[]    arrID            ;
		private int         nMaxBulkCount    ;

		public string LastError { get; set; }

		public ArchiveUtils(HttpContext Context)
		{
			this.Context           = Context    ;
			this.LastError         = String.Empty;
			this.gMODIFIED_USER_ID = Sql.ToGuid(Context.Session["USER_ID"]);
			// 03/03/2021 Paul.  We need to grab the culture as the session will disappear when run within a thread. 
			this.sCULTURE          = Sql.ToString(Context.Session["USER_SETTINGS/CULTURE" ]);
			// 03/03/2021 Paul.  Provide a way to customize the maximum number not executed in the background. 
			this.nMaxBulkCount     = 100;
			if ( !Sql.IsEmptyString(Context.Application["CONFIG.Archive.MaxBulkCount"]) )
			{
				this.nMaxBulkCount = Sql.ToInteger(Context.Application["CONFIG.Archive.MaxBulkCount"]);
			}
		}

		public string MoveData(string sModuleName, Guid gID)
		{
			string[] arrID = new String[1];
			arrID[0] = gID.ToString();
			// 03/03/2021 Paul.  When called from Rest service, Context.Items will not contain L10n. 
			L10N L10n = new L10N(this.sCULTURE);
			if ( Utils.IsOfflineClient )
				throw(new Exception(L10n.Term(".ERR_ARCHIVE_OFFLINE_CLIENT")));
			return MoveData(sModuleName, arrID);
		}

		public string MoveData(string sModuleName, string[] arrID)
		{
			this.ModuleName = sModuleName;
			this.arrID      = arrID      ;
			// 03/03/2021 Paul.  We need a version of FilterByACL_Stack() that does not require Context.Session so that it can be called from a Rest thread. 
			this.nACLACCESS = Security.GetUserAccess(this.ModuleName, "archive");
			// 03/03/2021 Paul.  When called from Rest service, Context.Items will not contain L10n. 
			L10N L10n = new L10N(this.sCULTURE);
			if ( Utils.IsOfflineClient )
				throw(new Exception(L10n.Term(".ERR_ARCHIVE_OFFLINE_CLIENT")));
			if ( arrID != null )
			{
				// 12/18/2017 Paul.  Flag was removed.  Get from related table. 
				// 03/03/2021 Paul.  Provide a way to customize the maximum number not executed in the background. 
				bool bIncludeActivities = IncludeActivities(sModuleName);
				if ( arrID.Length > this.nMaxBulkCount || (arrID.Length > 10 && bIncludeActivities) )
				{
					System.Threading.Thread t = new System.Threading.Thread(this.MoveDataInternal);
					t.Start();
					this.LastError = L10n.Term(".LBL_BACKGROUND_OPERATION");
				}
				else
				{
					this.MoveDataInternal();
				}
			}
			else
			{
				this.LastError = L10n.Term(".LBL_NOTHING_SELECTED");
			}
			SplendidCache.ClearArchiveViewExists();
			return this.LastError;
		}

		private bool IncludeActivities(string sModuleName)
		{
			bool bIncludeActivities = false;
			try
			{
					DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						string sSQL;
						sSQL = "select count(*)                   " + ControlChars.CrLf
						     + "  from vwMODULES_ARCHIVE_RELATED  " + ControlChars.CrLf
						     + " where MODULE_NAME  = @MODULE_NAME" + ControlChars.CrLf
						     + "   and RELATED_NAME = 'Activities'" + ControlChars.CrLf;
						using ( IDbCommand cmd = con.CreateCommand() )
						{
							cmd.CommandText = sSQL;
							cmd.CommandTimeout = 0;
							Sql.AddParameter(cmd, "@MODULE_NAME", sModuleName);
							bIncludeActivities = Sql.ToBoolean(cmd.ExecuteScalar());
						}
					}
			}
			catch(Exception ex)
			{
				SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
				this.LastError = ex.Message;
			}
			return bIncludeActivities;
		}

		private void MoveDataInternal()
		{
			try
			{
				// 03/03/2021 Paul.  Can be called within a thread, so we we need to call TableName() with the Application object. 
				// 03/03/2021 Paul.  We need a version of FilterByACL_Stack() that does not require Context.Session so that it can be called from a Rest thread. 
				System.Collections.Stack stk = Utils.FilterByACL_Stack(this.ModuleName, this.nACLACCESS, arrID, Crm.Modules.TableName(this.Context.Application, this.ModuleName));
				if ( stk.Count > 0 )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						using ( IDbTransaction trn = Sql.BeginTransaction(con) )
						{
							try
							{
								// 10/18/2017 Paul.  Make sure to prevent a timeout. This may take a while. 
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.Transaction = trn;
									cmd.CommandType = CommandType.StoredProcedure;
									cmd.CommandText = "spMODULES_ArchiveBuildByName";
									cmd.CommandTimeout = 0;
									IDbDataParameter parMODIFIED_USER_ID = Sql.AddParameter(cmd, "@MODIFIED_USER_ID", this.gMODIFIED_USER_ID);
									IDbDataParameter parMODULE_NAME      = Sql.AddParameter(cmd, "@MODULE_NAME"     , this.ModuleName,  25  );
									Sql.Trace(cmd);
									cmd.ExecuteNonQuery();
								}
								while ( stk.Count > 0 )
								{
									string sIDs = Utils.BuildMassIDs(stk);
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.Transaction = trn;
										cmd.CommandType = CommandType.StoredProcedure;
										cmd.CommandText = "spMODULES_ArchiveMoveData";
										cmd.CommandTimeout = 0;
										IDbDataParameter parMODIFIED_USER_ID = Sql.AddParameter(cmd, "@MODIFIED_USER_ID", this.gMODIFIED_USER_ID);
										IDbDataParameter parMODULE_NAME      = Sql.AddParameter(cmd, "@MODULE_NAME"     , this.ModuleName,  25  );
										IDbDataParameter parID_LIST          = Sql.AddAnsiParam(cmd, "@ID_LIST"         , sIDs           , 8000 );
										Sql.Trace(cmd);
										cmd.ExecuteNonQuery();
									}
								}
								trn.Commit();
							}
							catch(Exception ex)
							{
								trn.Rollback();
								throw(new Exception(ex.Message, ex.InnerException));
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
				this.LastError = ex.Message;
			}
		}

		public string RecoverData(string sModuleName, Guid gID)
		{
			string[] arrID = new String[1];
			arrID[0] = gID.ToString();
			// 03/03/2021 Paul.  When called from Rest service, Context.Items will not contain L10n. 
			L10N L10n = new L10N(this.sCULTURE);
			if ( Utils.IsOfflineClient )
				throw(new Exception(L10n.Term(".ERR_ARCHIVE_OFFLINE_CLIENT")));
			return RecoverData(sModuleName, arrID);
		}

		public string RecoverData(string sModuleName, string[] arrID)
		{
			this.ModuleName = sModuleName;
			this.arrID      = arrID      ;
			// 03/03/2021 Paul.  We need a version of FilterByACL_Stack() that does not require Context.Session so that it can be called from a Rest thread. 
			this.nACLACCESS = Security.GetUserAccess(this.ModuleName, "archive");
			// 03/03/2021 Paul.  When called from Rest service, Context.Items will not contain L10n. 
			L10N L10n = new L10N(this.sCULTURE);
			if ( Utils.IsOfflineClient )
				throw(new Exception(L10n.Term(".ERR_ARCHIVE_OFFLINE_CLIENT")));
			if ( arrID != null )
			{
				// 12/18/2017 Paul.  Flag was removed.  Get from related table. 
				// 03/03/2021 Paul.  Provide a way to customize the maximum number not executed in the background. 
				bool bIncludeActivities = IncludeActivities(sModuleName);
				if ( arrID.Length > this.nMaxBulkCount || (arrID.Length > 10 && bIncludeActivities) )
				{
					System.Threading.Thread t = new System.Threading.Thread(this.RecoverDataInternal);
					t.Start();
					this.LastError = L10n.Term(".LBL_BACKGROUND_OPERATION");
				}
				else
				{
					this.RecoverDataInternal();
				}
			}
			else
			{
				this.LastError = L10n.Term(".LBL_NOTHING_SELECTED");
			}
			SplendidCache.ClearArchiveViewExists();
			return this.LastError;
		}

		public void RecoverDataInternal()
		{
			try
			{
				// 03/03/2021 Paul.  Can be called within a thread, so we we need to call TableName() with the Application object. 
				// 03/03/2021 Paul.  We need a version of FilterByACL_Stack() that does not require Context.Session so that it can be called from a Rest thread. 
				System.Collections.Stack stk = Utils.FilterByACL_Stack(this.ModuleName, this.nACLACCESS, arrID, Crm.Modules.TableName(this.Context.Application, this.ModuleName));
				if ( stk.Count > 0 )
				{
					DbProviderFactory dbf = DbProviderFactories.GetFactory(Context.Application);
					using ( IDbConnection con = dbf.CreateConnection() )
					{
						con.Open();
						using ( IDbTransaction trn = Sql.BeginTransaction(con) )
						{
							try
							{
								// 10/18/2017 Paul.  Make sure to prevent a timeout. This may take a while. 
								using ( IDbCommand cmd = con.CreateCommand() )
								{
									cmd.Transaction = trn;
									cmd.CommandType = CommandType.StoredProcedure;
									cmd.CommandText = "spMODULES_ArchiveBuildByName";
									cmd.CommandTimeout = 0;
									IDbDataParameter parMODIFIED_USER_ID = Sql.AddParameter(cmd, "@MODIFIED_USER_ID", this.gMODIFIED_USER_ID);
									IDbDataParameter parMODULE_NAME      = Sql.AddParameter(cmd, "@MODULE_NAME"     , this.ModuleName,  25  );
									Sql.Trace(cmd);
									cmd.ExecuteNonQuery();
								}
								while ( stk.Count > 0 )
								{
									string sIDs = Utils.BuildMassIDs(stk);
									using ( IDbCommand cmd = con.CreateCommand() )
									{
										cmd.Transaction = trn;
										cmd.CommandType = CommandType.StoredProcedure;
										cmd.CommandText = "spMODULES_ArchiveRecoverData";
										cmd.CommandTimeout = 0;
										IDbDataParameter parMODIFIED_USER_ID = Sql.AddParameter(cmd, "@MODIFIED_USER_ID", this.gMODIFIED_USER_ID);
										IDbDataParameter parMODULE_NAME      = Sql.AddParameter(cmd, "@MODULE_NAME"     , this.ModuleName,  25  );
										IDbDataParameter parID_LIST          = Sql.AddAnsiParam(cmd, "@ID_LIST"         , sIDs           , 8000 );
										Sql.Trace(cmd);
										cmd.ExecuteNonQuery();
									}
								}
								trn.Commit();
							}
							catch(Exception ex)
							{
								trn.Rollback();
								throw(new Exception(ex.Message, ex.InnerException));
							}
						}
					}
				}
			}
			catch(Exception ex)
			{
				SplendidError.SystemMessage(Context, "Error", new StackTrace(true).GetFrame(0), Utils.ExpandException(ex));
				this.LastError = ex.Message;
			}
		}
	}
}

