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
using System.Web.SessionState;
using System.Diagnostics;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for L10n.
	/// </summary>
	public class L10N
	{
		protected string m_sNAME;
		
		public string NAME
		{
			get
			{
				return m_sNAME;
			}
		}

		public L10N(string sNAME)
		{
			// 11/19/2005 Paul.  We may be connecting to MySQL, so the language may have an underscore. 
			m_sNAME = NormalizeCulture(sNAME);
		}

		public bool IsLanguageRTL()
		{
			bool bRTL = false;
			switch ( m_sNAME.Substring(0, 2) )
			{
				case "ar":  bRTL = true;  break;
				case "he":  bRTL = true;  break;
				case "ur":  bRTL = true;  break;
				case "fa":  bRTL = true;  break;  // 12/17/2008 Paul.  Farsi is also RTL. 
			}
			return bRTL;
		}

		// 04/20/2018 Paul.  Alternate language mapping to convert en-CA to en_US. 
		public static string AlternateLanguage(HttpApplicationState Application, string sCulture)
		{
			string sAlternateName = Sql.ToString(Application["CONFIG.alternate_language." + sCulture]);
			if ( !Sql.IsEmptyString(sAlternateName) )
				sCulture = sAlternateName;
			return sCulture;
		}

		public static string NormalizeCulture(string sCulture)
		{
			// 08/28/2005 Paul.  Default to English if nothing specified. 
			// 09/02/2008 Paul.  Default to English if nothing specified.  This can happen if a user is created programatically. 
			if ( Sql.IsEmptyString(sCulture) )
				sCulture = "en-US";
			sCulture = sCulture.Replace("_", "-");
			// 05/20/2008 Paul.  We are now storing the language in the proper case, so make sure to normalize with proper case. 
			sCulture = sCulture.Substring(0, 2).ToLower() + sCulture.Substring(2).ToUpper();
			return sCulture;
		}

		public object Term(string sListName, object oField)
		{
			return Term(HttpContext.Current.Application, m_sNAME, sListName, oField);
		}

		// 08/17/2005 Paul.  Special Term function that helps with a list. 
		public static object Term(HttpApplicationState Application, string sCultureName, string sListName, object oField)
		{
			// 01/11/2008 Paul.  Protect against uninitialized variables. 
			if ( String.IsNullOrEmpty(sListName) )
				return String.Empty;

			if ( oField == null || oField == DBNull.Value )
				return oField;
			// 11/28/2005 Paul.  Convert field to string instead of cast.  Cast will not work for integer fields. 
			return Term(Application, sCultureName, sListName + oField.ToString());
		}

		public string Term(string sEntryName)
		{
			return Term(HttpContext.Current.Application, m_sNAME, sEntryName);
		}

		public static string Term(HttpApplicationState Application, string sCultureName, string sEntryName)
		{
			// 01/11/2008 Paul.  Protect against uninitialized variables. 
			if ( String.IsNullOrEmpty(sEntryName) || Application == null )
				return String.Empty;

			//string sNAME = "en-us";
			object oDisplayName = Application[sCultureName + "." + sEntryName];
			if ( oDisplayName == null )
			{
				// 01/11/2007 Paul.  Default to English if term not found. 
				// There are just too many untranslated terms when importing a SugarCRM Language Pack. 
				oDisplayName = Application["en-US." + sEntryName];
				if ( oDisplayName == null )
				{
					// Prevent parameter out of range errors with <asp:Button AccessKey="" />
					if ( sEntryName.EndsWith("_BUTTON_KEY") )
						return String.Empty;
					// 07/07/2008 Paul.  If the entry name is not found, post a warning message
					// then define the entry so that we will only get one warning per run. 
					if ( sEntryName.Contains(".") )
					{
						Application["en-US." + sEntryName] = sEntryName;
#if DEBUG
						// 09/18/2009 Paul.  The end-user should not see these any more. 
						// There are simply too many false-positives that are caused by a page or control being bound twice. 
						SplendidError.SystemMessage(Application, "Warning", new StackTrace(true).GetFrame(0), "L10N.Term: \"" + sEntryName + "\" not found.");
#endif
					}
					return sEntryName;
				}
			}
			return oDisplayName.ToString();
		}

		// 06/30/2007 Paul.  Prevent parameter out of range errors with <asp:Button AccessKey="" />.  Not all access keys end in _BUTTON_KEY. 
		public string AccessKey(string sEntryName)
		{
			// 01/11/2008 Paul.  Protect against uninitialized variables. 
			if ( String.IsNullOrEmpty(sEntryName) )
				return String.Empty;

			HttpApplicationState Application = HttpContext.Current.Application;
			//string sNAME = "en-us";
			object oDisplayName = Application[NAME + "." + sEntryName];
			if ( oDisplayName == null )
			{
				// 01/11/2007 Paul.  Default to English if term not found. 
				// There are just too many untranslated terms when importing a SugarCRM Language Pack. 
				oDisplayName = Application["en-US." + sEntryName];
				if ( oDisplayName == null )
				{
					return String.Empty;
				}
			}
			// 06/30/2007 Paul.  AccessKey too long, cannot be more than one character.
			// 07/03/2007 Paul.  Protect against an empty AccessKey string. 
			string sAccessKey = oDisplayName.ToString();
			if ( sAccessKey.Length == 0 )
				return String.Empty;
			return sAccessKey.Substring(0, 1);
		}

		public string AliasedTerm(string sEntryName)
		{
			// 01/11/2008 Paul.  Protect against uninitialized variables. 
			if ( String.IsNullOrEmpty(sEntryName) )
				return String.Empty;

			HttpApplicationState Application = HttpContext.Current.Application;
			object oAliasedName = Application["ALIAS_" + sEntryName];
			if ( oAliasedName == null )
				return Term(sEntryName);
			return Term(oAliasedName.ToString());
		}

		// 01/20/2009 Paul.  We need to pass the Application to the Term function. 
		public static void SetTerm(string sLANG, string sMODULE_NAME, string sNAME, string sDISPLAY_NAME)
		{
			SetTerm(HttpContext.Current.Application, sLANG, sMODULE_NAME, sNAME, sDISPLAY_NAME);
		}

		public static void SetTerm(HttpApplicationState Application, string sLANG, string sMODULE_NAME, string sNAME, string sDISPLAY_NAME)
		{
			Application[sLANG + "." + sMODULE_NAME + "." + sNAME] = sDISPLAY_NAME;
		}

		// 01/20/2009 Paul.  We need to pass the Application to the Term function. 
		public static void SetTerm(string sLANG, string sMODULE_NAME, string sLIST_NAME, string sNAME, string sDISPLAY_NAME)
		{
			SetTerm(HttpContext.Current.Application, sLANG, sMODULE_NAME, sLIST_NAME, sNAME, sDISPLAY_NAME);
		}

		public static void SetTerm(HttpApplicationState Application, string sLANG, string sMODULE_NAME, string sLIST_NAME, string sNAME, string sDISPLAY_NAME)
		{
			// 01/13/2006 Paul.  Don't include MODULE_NAME when used with a list. DropDownLists are populated without the module name in the list name. 
			// 01/13/2006 Paul.  We can remove the module, but not the dot.  Otherwise it breaks all other code that references a list term. 
			sMODULE_NAME = String.Empty;
			Application[sLANG + "." + sMODULE_NAME + "." + sLIST_NAME + "." + sNAME] = sDISPLAY_NAME;
		}

		public static void SetAlias(HttpApplicationState Application, string sALIAS_MODULE_NAME, string sALIAS_LIST_NAME, string sALIAS_NAME, string sMODULE_NAME, string sLIST_NAME, string sNAME)
		{
			if ( Sql.IsEmptyString(sALIAS_LIST_NAME) )
				Application["ALIAS_" + sALIAS_MODULE_NAME + "." + sALIAS_NAME] = sMODULE_NAME + "." + sNAME;
			else
				Application["ALIAS_" + sALIAS_MODULE_NAME + "." + sALIAS_LIST_NAME + "." + sALIAS_NAME] = sMODULE_NAME + "." + sLIST_NAME + "." + sNAME;
		}
		
		public string TermJavaScript(string sEntryName)
		{
			string sDisplayName = Term(sEntryName);
			sDisplayName = sDisplayName.Replace("\'", "\\\'");
			sDisplayName = sDisplayName.Replace("\"", "\\\"");
			sDisplayName = sDisplayName.Replace(ControlChars.CrLf, @"\r\n");
			return sDisplayName;
		}
	}
}

