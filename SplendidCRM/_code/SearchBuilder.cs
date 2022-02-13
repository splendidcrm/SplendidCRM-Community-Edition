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
using System.Text;
using System.Collections;
using System.Diagnostics;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for SearchBuilder.
	/// </summary>
	public class SearchBuilder
	{
		private   bool     m_bFeatureOR     = true  ;  //OR keyword
		private   bool     m_bFeatureAND    = true  ;  //AND keyword
		private   bool     m_bFeatureNOT    = true  ;  //NOT keyword
		private   bool     m_bFeatureMIMUS  = true  ;  //- symbol
		private   bool     m_bFeaturePLUS   = true  ;  //+ symbol
		private   bool     m_bFeatureSTAR   = true  ;  //* symbol
		private   bool     m_bFeatureSINGLE = false ;  //Single letter filtering.  01/17/2005 Paul.  Don't do this. 
		private   bool     m_bFeatureLESS   = true  ;  // < or > symbol
		private   bool     m_bFeatureEXCL   = true  ;  //! symbol
		private   bool     m_bFeatureEQUAL  = true  ;  //= sumbol
		private   bool     m_bIsOracle      = false ;
		private   bool     m_bIsDB2         = false ;
		private   bool     m_bIsMySQL       = false ;
		private   bool     m_bIsPostgreSQL  = false ;
		private   bool     m_bIsSQLServer   = true  ;

		protected string   m_sTermOR        = "OR"  ;  //UCase(LmsConfigTermInternal("OR" ))
		protected string   m_sTermAND       = "AND" ;  //UCase(LmsConfigTermInternal("AND"))
		protected string   m_sTermNOT       = "NOT" ;  //UCase(LmsConfigTermInternal("NOT"))

		protected string   m_sInput         = String.Empty;
		protected string[] m_arrTokens      = new String[] {};

		private   IDbCommand m_cmd = null;

		// 07/16/2006 Paul.  We need to know the database platform in order to build the like escape clause properly. 
		public SearchBuilder(string str, IDbCommand cmd)
		{
			m_cmd = cmd;
			// 09/02/2009 Paul.  No need to create a new connection when we already have a command object. 
			m_bIsOracle     = Sql.IsOracle    (m_cmd);
			m_bIsDB2        = Sql.IsDB2       (m_cmd);
			m_bIsMySQL      = Sql.IsMySQL     (m_cmd);
			m_bIsPostgreSQL = Sql.IsPostgreSQL(m_cmd);
			m_bIsSQLServer  = Sql.IsSQLServer (m_cmd);
			ParseInput(str);
		}

		public string[] Tokens
		{
			get
			{
				return m_arrTokens;
			}
		}

		protected bool IsEmptyString(string str)
		{
			if ( str == null || str == String.Empty )
			{
				return true;
			}
			return false;
		}

		protected string EscapeSql(string str)
		{
			return str.Replace("\'", "\'\'");
		}

		protected string EscapeLike(string str)
		{
			string sEscaped = EscapeSql(str);
			// 07/16/2006 Paul.  SQL Server, Oracle and DB2 all support the ESCAPE clause. 
			// MySQL works, but requires ESCAPE '\\'. 
			sEscaped = sEscaped.Replace(@"\", @"\\");
			sEscaped = sEscaped.Replace("%" , @"\%");
			sEscaped = sEscaped.Replace("_" , @"\_");
			return sEscaped;
		}

		protected void ParseInput(string sInput)
		{
			m_sInput  = sInput;
			m_arrTokens = new String[] {};
			if ( !IsEmptyString(sInput) )
			{
				// 09/02/2009 Paul.  Now that we know the database platform, only use the upper clause if Oracle or DB2. 
				if ( m_bIsOracle || m_bIsDB2 || m_bIsPostgreSQL )
					sInput = sInput.ToUpper();
		
				char          chPreviousChar = ' ';
				char[]        arrText        = sInput.ToCharArray();
				bool          bInsideQuotes  = false;
				ArrayList     arrTokens      = new ArrayList();
				StringBuilder sbToken        = new StringBuilder();
				for ( int i = 0 ; i < arrText.Length ; i++ )
				{
					char ch = arrText[i];
					if ( ch == '\"' )
					{
						if ( bInsideQuotes )
						{
							//Add empty quoted strings so that -"" or +"" can be filtered later. 
							//They are filtered later so that the - or + will not be applied to the following token. 
							arrTokens.Add(sbToken.ToString());
							sbToken = new StringBuilder();
						}
						else
						{
							//If starting a quoted token, then add existing token. 
							if ( sbToken.Length > 0 )
								arrTokens.Add(sbToken.ToString());
							sbToken = new StringBuilder();
							sbToken.Append("\"") ; //Place quote as first character as a flag. 
						}
						bInsideQuotes = !bInsideQuotes;
					}
					else if ( bInsideQuotes )
						sbToken.Append(ch);
					//The -/+ should be preceded by a space; so says the Google documentation.
					else if ( m_bFeatureMIMUS && ch == '-' && chPreviousChar == ' ' )
					{
						if ( sbToken.Length > 0 )
							arrTokens.Add(sbToken.ToString());
						sbToken = new StringBuilder();
						arrTokens.Add(ch.ToString());
					}
					else if ( m_bFeaturePLUS && ch == '+' && chPreviousChar == ' ' )
					{
						if ( sbToken.Length > 0 )
							arrTokens.Add(sbToken.ToString());
						sbToken = new StringBuilder();
						arrTokens.Add(ch.ToString());
					}
					else if ( m_bFeatureLESS && ch == '<' )
					{
						if ( sbToken.Length > 0 )
							arrTokens.Add(sbToken.ToString());
						sbToken = new StringBuilder();
						arrTokens.Add(ch.ToString());
					}
					else if ( m_bFeatureLESS && ch == '>' )
					{
						if ( sbToken.Length > 0 )
							arrTokens.Add(sbToken.ToString());
						sbToken = new StringBuilder();
						arrTokens.Add(ch.ToString());
					}
					else if ( m_bFeatureEXCL && ch == '!' )
					{
						if ( sbToken.Length > 0 )
							arrTokens.Add(sbToken.ToString());
						sbToken = new StringBuilder();
						arrTokens.Add(ch.ToString());
					}
					else if ( m_bFeatureEQUAL && ch == '=' )
					{
						if ( sbToken.Length > 0 )
							arrTokens.Add(sbToken.ToString());
						sbToken = new StringBuilder();
						arrTokens.Add(ch.ToString());
					}
					else if ( ch == ControlChars.Cr || ch == ControlChars.Lf || ch == ControlChars.Tab || ch == ' ' || ch == ',' || ch == ';' )
					{
						//CR, LF, TAB, SPACE, COMMA and SEMICOLON can all be used as token separators. 
						if ( sbToken.Length > 0 )
						{
							string strToken = sbToken.ToString();
							arrTokens.Add(strToken);
						}
						sbToken = new StringBuilder();
					}
					else
					{
						sbToken.Append(ch);
					}
					chPreviousChar = ch;
				}
				if ( sbToken.Length > 0 )
					arrTokens.Add(sbToken.ToString());
				m_arrTokens = (string[]) arrTokens.ToArray(Type.GetType("System.String"));
			}
		}

		//Can't do an upper() on NTEXT.  SQL Server complains. 
		public string BuildQuery(string sCondition, string sField, string sInput)
		{
			return BuildQuery(sCondition, sField, sInput, true);
		}

		public string BuildQuery(string sCondition, string sField, string sInput, bool bTextField)
		{
			ParseInput(sInput);
			return BuildQuery(sCondition, sField, bTextField);
		}

		//To determine if the string is valid, build a query and return true if a result is built.
		//The goal is to avoid user queries like "" AND "" where nothing is provided in the quotes. 
		//BuildQuery will properly return nothing, but there are times when we need to know this before we build. 
		public bool IsValidQuery()
		{
			string str = BuildQuery("  ", "xxxx", true);
			return !IsEmptyString(str);
		}

		public string BuildQuery(string sCondition, string sField)
		{
			return BuildQuery(sCondition, sField, true);
		}

		public string BuildQuery(string sCondition, string sField, bool bTextField)
		{
			StringBuilder sbSqlQuery  = new StringBuilder();
			int           nNotFlag    = 0;
			bool          bOrFlag     = false;
			int           nQueryLine  = 0;
			int           nLessFlag   = 0;
			bool          bEqualFlag  = false;
			sbSqlQuery.Append(sCondition);
			sbSqlQuery.Append("(");

				// 07/16/2006 Paul.  Now that we know the database platform, only use the upper clause if Oracle or DB2. 
			// 09/02/2008 Paul.  PostgreSQL is case significant. 
			if ( m_bIsOracle || m_bIsDB2 || m_bIsPostgreSQL )
			{
				//Can't do an upper() on NTEXT.  SQL Server complains. 
				// 01/16/2008 Paul.  We don't use the bTextField anymore, and I could not find any places where we searched an NTEXT field anyway. 
				//if ( !bTextField )
					sField = "upper(" + sField + ")";
			}

			foreach ( string sThisToken in m_arrTokens )
			{
				if      ( m_bFeatureMIMUS && sThisToken == "-" )
					nNotFlag = 1;
				else if ( m_bFeaturePLUS  && sThisToken == "+" )
					nNotFlag = 2;
				// 01/20/2010 Paul.  AND, OR and NOT clauses have been broken for a very long time.  We need to allow mixed-case for these tokens. 
				else if ( m_bFeatureOR    && (String.Compare(sThisToken, m_sTermOR , true) == 0) )
					bOrFlag = true;
				else if ( m_bFeatureAND   && (String.Compare(sThisToken, m_sTermAND, true) == 0) )
					bOrFlag = false;
				else if ( m_bFeatureNOT   && (String.Compare(sThisToken, m_sTermNOT, true) == 0) )
					nNotFlag = 1;
				// 12/17/2007 Paul.  Add support for <, <=, > and >=. 
				else if ( m_bFeatureLESS  && sThisToken == "<" )
					nLessFlag = 1;
				else if ( m_bFeatureLESS  && sThisToken == ">" )
					nLessFlag = -1;
				// 12/17/2007 Paul.  Add support for ! and !=.  They are both the same. 
				else if ( m_bFeatureEXCL  && sThisToken == "!" )
					nNotFlag = 1;
				else if ( m_bFeatureEQUAL && sThisToken == "=" )
					bEqualFlag = true;
				else
				{
					if ( sThisToken.Length > 0 )
					{
						//Google ignores single digit and single letters unless + or - is used. 
						if ( !m_bFeatureSINGLE || nNotFlag > 0 || sThisToken.Length > 1 || !Char.IsLetterOrDigit(sThisToken[0]) )
						{
							//Ignore quoted strings that contain nothing after the quote. 
							if ( sThisToken[0] != '\"' || sThisToken.Length > 1 )
							{
								//Add spaces to the line to align the fields.
								if ( nQueryLine > 0 )
								{
									sbSqlQuery.Append(Strings.Space(sCondition.Length));
									if ( bOrFlag )
										sbSqlQuery.Append("    or ");
									else
										sbSqlQuery.Append("   and ");
								}
								else
									sbSqlQuery.Append("      ");
								if ( nNotFlag == 1 )
									sbSqlQuery.Append("not ");
								else
									sbSqlQuery.Append("    ");
								
								//Remove the double quote flag from a quoted string. 
								string sToken = sThisToken;
								if ( sToken[0] == '\"' )
									sToken = sThisToken.Substring(1);
								
								// 12/17/2007 Paul.  Wildcards will have a higher priority over greater than or less than. 
								if ( m_bFeatureSTAR && sToken.IndexOf('*') >= 0 )
								{
									//Escape to prevent use of % as a wild-card.
									sToken = EscapeLike(sToken);
									// 07/16/2006 Paul.  SQL Server, Oracle and DB2 all support the ESCAPE '\' clause. 
									// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
									if ( m_bIsMySQL || m_bIsPostgreSQL )
										sToken = sToken.Replace("\\", "\\\\");
									sToken = sToken.Replace("*", "%");
									// 12/04/2008 Paul.  SQL Server needs to know to use the national character set. 
									// This solves a problem searching farsi. 
									if ( m_bIsSQLServer )
										sbSqlQuery.Append(sField + " like N'" + sToken + "'");
									else
										sbSqlQuery.Append(sField + " like '" + sToken + "'");
									// 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
									// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
									if ( m_bIsMySQL || m_bIsPostgreSQL )
										sbSqlQuery.AppendLine(" escape '\\\\'");
									else
										sbSqlQuery.AppendLine(" escape '\\'");
								}
								else
								{
									if ( nLessFlag == 0 )
									{
										if ( bEqualFlag )
										{
											// 12/17/2007 Paul.  Single quotes need to be manually escaped. 
											sToken = EscapeSql(sToken);
											// 12/04/2008 Paul.  SQL Server needs to know to use the national character set. 
											// This solves a problem searching farsi. 
											// 07/12/2018 Paul.  Allow searching of null values. 
											if ( String.Compare(sToken, "null", true) == 0 )
												sbSqlQuery.Append(sField + " is null");
											else if ( String.Compare(sToken, "not null", true) == 0 )
												sbSqlQuery.Append(sField + " is not null");
											else if ( m_bIsSQLServer )
												sbSqlQuery.Append(sField + " = N'" + sToken + "'");
											else
												sbSqlQuery.Append(sField + " = '" + sToken + "'");
										}
										else
										{
											//Escape to prevent use of % as a wild-card.
											sToken = EscapeLike(sToken);
											// 07/16/2006 Paul.  SQL Server, Oracle and DB2 all support the ESCAPE '\' clause. 
											// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
											if ( m_bIsMySQL || m_bIsPostgreSQL )
												sToken = sToken.Replace("\\", "\\\\");
											// 12/04/2008 Paul.  SQL Server needs to know to use the national character set. 
											// This solves a problem searching farsi. 
											if ( m_bIsSQLServer )
												sbSqlQuery.Append(sField + " like N'%" + sToken + "%'");
											else
												sbSqlQuery.Append(sField + " like '%" + sToken + "%'");
											// 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
											// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
											if ( m_bIsMySQL || m_bIsPostgreSQL )
												sbSqlQuery.AppendLine(" escape '\\\\'");
											else
												sbSqlQuery.AppendLine(" escape '\\'");
										}
									}
									else
									{
										// 12/17/2007 Paul.  Single quotes need to be manually escaped. 
										sToken = EscapeSql(sToken);
										if ( nLessFlag == 1 )
										{
											// 12/04/2008 Paul.  SQL Server needs to know to use the national character set. 
											// This solves a problem searching farsi. 
											if ( m_bIsSQLServer )
											{
												if ( bEqualFlag )
													sbSqlQuery.Append(sField + " <= N'" + sToken + "'");
												else
													sbSqlQuery.Append(sField + " < N'" + sToken + "'");
											}
											else
											{
												if ( bEqualFlag )
													sbSqlQuery.Append(sField + " <= '" + sToken + "'");
												else
													sbSqlQuery.Append(sField + " < '" + sToken + "'");
											}
										}
										else if ( nLessFlag == -1 )
										{
											// 12/04/2008 Paul.  SQL Server needs to know to use the national character set. 
											// This solves a problem searching farsi. 
											if ( m_bIsSQLServer )
											{
												if ( bEqualFlag )
													sbSqlQuery.Append(sField + " >= N'" + sToken + "'");
												else
													sbSqlQuery.Append(sField + " > N'" + sToken + "'");
											}
											else
											{
												if ( bEqualFlag )
													sbSqlQuery.Append(sField + " >= '" + sToken + "'");
												else
													sbSqlQuery.Append(sField + " > '" + sToken + "'");
											}
										}
									}
								}
								
								nQueryLine += 1;
							}
						}
					}
					nNotFlag = 0;
					bOrFlag  = false;
					bEqualFlag = false;
					nLessFlag = 0;
				}
			}
			if ( nQueryLine > 0 )
			{
				sbSqlQuery.AppendLine(Strings.Space(sCondition.Length) + ")");
				return sbSqlQuery.ToString();
			}
			return String.Empty;
		}
	}
}


