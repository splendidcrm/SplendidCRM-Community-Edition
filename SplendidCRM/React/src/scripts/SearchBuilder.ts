/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 1. React and fabric. 
// 2. Store and Types. 
// 3. Scripts. 
import { StartsWith, EndsWith, Left, Right } from '../scripts/utility';
import Sql from '../scripts/Sql';

// 11/10/2012 Paul.  We need a way to turn of National character set for SQLite. 
var bIsSQLServer   = true  ;

export default class SearchBuilder
{
	protected m_bFeatureOR     = true  ;  //OR keyword
	protected m_bFeatureAND    = true  ;  //AND keyword
	protected m_bFeatureNOT    = true  ;  //NOT keyword
	protected m_bFeatureMIMUS  = true  ;  //- symbol
	protected m_bFeaturePLUS   = true  ;  //+ symbol
	protected m_bFeatureSTAR   = true  ;  //* symbol
	protected m_bFeatureSINGLE = false ;  //Single letter filtering.  01/17/2005 Paul.  Don't do this. 
	protected m_bFeatureLESS   = true  ;  // < or > symbol
	protected m_bFeatureEXCL   = true  ;  //! symbol
	protected m_bFeatureEQUAL  = true  ;  //= sumbol
	protected m_bIsOracle      = false ;
	protected m_bIsDB2         = false ;
	protected m_bIsMySQL       = false ;
	protected m_bIsPostgreSQL  = false ;
	protected m_bIsSQLServer   = bIsSQLServer;
	protected m_sTermOR        = 'OR'  ;
	protected m_sTermAND       = 'AND' ;
	protected m_sTermNOT       = 'NOT' ;
	protected m_sInput         = ''    ;
	protected m_arrTokens      = new Array();

	public Init(str)
	{
		this.ParseInput(str);
	}

	public IsEmptyString(str)
	{
		// 12/01/2020 Paul.  Numeric 0 is equal to an empty string, so use strict operator to correct. 
		if ( str === undefined || str == null || str === '' )
		{
			return true;
		}
		return false;
	}

	// 06/14/2015 Paul.  We should be replacing all and not just the first item. 
	//String.prototype.replaceAll = function (find, replace)
	//{
	//	var str = this;
	//	return str.replace(new RegExp(find.replace(/[-\/\\^$*+?.()|[\]{}]/g, '\\$&'), 'g'), replace);
	//};

	public EscapeSql(str)
	{
		// 06/14/2015 Paul.  We should be replacing all and not just the first item. 
		return Sql.replaceAll(str, '\'', '\'\'');
	}

	public EscapeLike(str)
	{
		// 06/14/2015 Paul.  We should be replacing all and not just the first item. 
		var sEscaped = this.EscapeSql(str);
		sEscaped = Sql.replaceAll(sEscaped, '\\', '\\\\');
		sEscaped = Sql.replaceAll(sEscaped, '%' , '\\%');
		sEscaped = Sql.replaceAll(sEscaped, '_' , '\\_');
		return sEscaped;
	}

	public ParseInput(sInput)
	{
		try
		{
			this.m_sInput  = sInput;
			this.m_arrTokens = new Array();
			// 01/01/2018 Paul.  sInput must be a string. 
			if ( !this.IsEmptyString(sInput) && typeof sInput === 'string' )
			{
				// 05/21/2018 Paul.  Missing Tab. 
				var ControlChars = { CrLf: '\r\n', Cr: '\r', Lf: '\n', Tab: '\t' };
				// 09/02/2009 Paul.  Now that we know the database platform, only use the upper clause if Oracle or DB2. 
				if ( this.m_bIsOracle || this.m_bIsDB2 || this.m_bIsPostgreSQL )
					sInput = sInput.toUpperCase();
			
				var chPreviousChar = ' ';
				var arrText        = sInput;
				var bInsideQuotes  = false;
				var arrTokens      = new Array();
				var sbToken        = '';
				for ( var i = 0 ; i < arrText.length ; i++ )
				{
					// 09/25/2011 Paul.  IE in quirks mode does not support character indexing. 
					var ch = arrText.charAt(i);
					if ( ch == '\"' )
					{
						if ( bInsideQuotes )
						{
							//Add empty quoted strings so that -"" or +"" can be filtered later. 
							//They are filtered later so that the - or + will not be applied to the following token. 
							arrTokens.push(sbToken);
							sbToken = '';
						}
						else
						{
							//If starting a quoted token, then add existing token. 
							if ( sbToken.length > 0 )
								arrTokens.push(sbToken);
							sbToken = '';
							sbToken += '\"' ; //Place quote as first character as a flag. 
						}
						bInsideQuotes = !bInsideQuotes;
					}
					else if ( bInsideQuotes )
						sbToken += ch;
					//The -/+ should be preceded by a space; so says the Google documentation.
					else if ( this.m_bFeatureMIMUS && ch == '-' && chPreviousChar == ' ' )
					{
						if ( sbToken.length > 0 )
							arrTokens.push(sbToken);
						sbToken = '';
						arrTokens.push(ch);
					}
					else if ( this.m_bFeaturePLUS && ch == '+' && chPreviousChar == ' ' )
					{
						if ( sbToken.length > 0 )
							arrTokens.push(sbToken);
						sbToken = '';
						arrTokens.push(ch);
					}
					else if ( this.m_bFeatureLESS && ch == '<' )
					{
						if ( sbToken.length > 0 )
							arrTokens.push(sbToken);
						sbToken = '';
						arrTokens.push(ch);
					}
					else if ( this.m_bFeatureLESS && ch == '>' )
					{
						if ( sbToken.length > 0 )
							arrTokens.push(sbToken);
						sbToken = '';
						arrTokens.push(ch);
					}
					else if ( this.m_bFeatureEXCL && ch == '!' )
					{
						if ( sbToken.length > 0 )
							arrTokens.push(sbToken);
						sbToken = '';
						arrTokens.push(ch);
					}
					else if ( this.m_bFeatureEQUAL && ch == '=' )
					{
						if ( sbToken.length > 0 )
							arrTokens.push(sbToken);
						sbToken = '';
						arrTokens.push(ch);
					}
					// 12/27/2017 Paul.  Treat comma as the OR operator so that Team Sets and User Sets can automatically be managed. 
					else if ( this.m_bFeatureEQUAL && ch == ',' )
					{
						if ( sbToken.length > 0 )
							arrTokens.push(sbToken);
						sbToken = '';
						arrTokens.push(ch);
					}
					else if ( ch == ControlChars.Cr || ch == ControlChars.Lf || ch == ControlChars.Tab || ch == ' ' || ch == ';' )
					{
						//CR, LF, TAB, SPACE, COMMA and SEMICOLON can all be used as token separators. 
						if ( sbToken.length > 0 )
						{
							arrTokens.push(sbToken);
						}
						sbToken = '';
					}
					else
					{
						sbToken += ch;
					}
					chPreviousChar = ch;
				}
				if ( sbToken.length > 0 )
					arrTokens.push(sbToken);
				this.m_arrTokens = arrTokens;
			}
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + this.constructor.name + '.ParseInput', error);
		}
	}

	// http://www.regular-expressions.info/reference.html
	// http://www.java2s.com/Open-Source/Javascript/Library/jshaskell/base/src/GHC/Unicode.js.htm
	public isAlphaNum(c)
	{
		return /^\w$/.test(c);
	}

	public BuildQuery(sCondition, sField, sInput?)
	{
		var sbSqlQuery  = '';
		var nNotFlag    = 0;
		var bOrFlag     = false;
		var nQueryLine  = 0;
		var nLessFlag   = 0;
		var bEqualFlag  = false;
		sbSqlQuery += sCondition;
		sbSqlQuery += '(';

		if ( sInput !== undefined )
			this.ParseInput(sInput);

			// 07/16/2006 Paul.  Now that we know the database platform, only use the upper clause if Oracle or DB2. 
		// 09/02/2008 Paul.  PostgreSQL is case significant. 
		if ( this.m_bIsOracle || this.m_bIsDB2 || this.m_bIsPostgreSQL )
		{
			//Can't do an upper() on NTEXT.  SQL Server complains. 
			sField = 'upper(' + sField + ')';
		}

		for ( var nThisToken in this.m_arrTokens )
		{
			var sThisToken = this.m_arrTokens[nThisToken];
			if      ( this.m_bFeatureMIMUS && sThisToken == '-' )
				nNotFlag = 1;
			else if ( this.m_bFeaturePLUS  && sThisToken == '+' )
				nNotFlag = 2;
			// 12/27/2017 Paul.  Treat comma as the OR operator so that Team Sets and User Sets can automatically be managed. 
			else if ( this.m_bFeaturePLUS  && sThisToken == ',' )
				bOrFlag = true;
			// 01/20/2010 Paul.  AND, OR and NOT clauses have been broken for a very long time.  We need to allow mixed-case for these tokens. 
			else if ( this.m_bFeatureOR    && (sThisToken.toUpperCase() == this.m_sTermOR ) )
				bOrFlag = true;
			else if ( this.m_bFeatureAND   && (sThisToken.toUpperCase() == this.m_sTermAND) )
				bOrFlag = false;
			else if ( this.m_bFeatureNOT   && (sThisToken.toUpperCase() == this.m_sTermNOT) )
				nNotFlag = 1;
			// 12/17/2007 Paul.  Add support for <, <=, > and >=. 
			else if ( this.m_bFeatureLESS  && sThisToken == '<' )
				nLessFlag = 1;
			else if ( this.m_bFeatureLESS  && sThisToken == '>' )
				nLessFlag = -1;
			// 12/17/2007 Paul.  Add support for ! and !=.  They are both the same. 
			else if ( this.m_bFeatureEXCL  && sThisToken == '!' )
				nNotFlag = 1;
			else if ( this.m_bFeatureEQUAL && sThisToken == '=' )
				bEqualFlag = true;
			else
			{
				if ( sThisToken.length > 0 )
				{
					//Google ignores single digit and single letters unless + or - is used. 
					// 09/25/2011 Paul.  IE in quirks mode does not support character indexing. 
					if ( !this.m_bFeatureSINGLE || nNotFlag > 0 || sThisToken.length > 1 || !this.isAlphaNum(sThisToken.charAt(0)) )
					{
						//Ignore quoted strings that contain nothing after the quote. 
						if ( sThisToken.charAt(0) != '\"' || sThisToken.length > 1 )
						{
							//Add spaces to the line to align the fields.
							if ( nQueryLine > 0 )
							{
								if ( bOrFlag )
									sbSqlQuery += ' or ';
								else
									sbSqlQuery += ' and ';
							}
							else
								sbSqlQuery += ' ';
							if ( nNotFlag == 1 )
								sbSqlQuery += 'not ';
							else
								sbSqlQuery += ' ';
								
							//Remove the double quote flag from a quoted string. 
							var sToken = sThisToken;
							// 09/25/2011 Paul.  IE in quirks mode does not support character indexing. 
							if ( sToken.charAt(0) == '\"' )
								sToken = sThisToken.substring(1);
								
							// 12/17/2007 Paul.  Wildcards will have a higher priority over greater than or less than. 
							if ( this.m_bFeatureSTAR && sToken.indexOf('*') >= 0 )
							{
								//Escape to prevent use of % as a wild-card.
								sToken = this.EscapeLike(sToken);
								// 07/16/2006 Paul.  SQL Server, Oracle and DB2 all support the ESCAPE '\' clause. 
								// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
								if ( this.m_bIsMySQL || this.m_bIsPostgreSQL )
									sToken = sToken.replace('\\', '\\\\');
								sToken = sToken.replace('*', '%');
								// 12/04/2008 Paul.  SQL Server needs to know to use the national character set. 
								// This solves a problem searching farsi. 
								if ( this.m_bIsSQLServer )
									sbSqlQuery += (sField + " like N'" + sToken + "'");
								else
									sbSqlQuery += (sField + " like '" + sToken + "'");
								// 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
								// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
								if ( this.m_bIsMySQL || this.m_bIsPostgreSQL )
									sbSqlQuery += " escape '\\\\'";
								else
									sbSqlQuery += " escape '\\'";
							}
							else
							{
								if ( nLessFlag == 0 )
								{
									if ( bEqualFlag )
									{
										// 12/17/2007 Paul.  Single quotes need to be manually escaped. 
										sToken = this.EscapeSql(sToken);
										// 12/04/2008 Paul.  SQL Server needs to know to use the national character set. 
										// This solves a problem searching farsi. 
										if ( this.m_bIsSQLServer )
											sbSqlQuery += sField + " = N'" + sToken + "'";
										else
											sbSqlQuery += sField + " = '" + sToken + "'";
									}
									else
									{
										//Escape to prevent use of % as a wild-card.
										sToken = this.EscapeLike(sToken);
										// 07/16/2006 Paul.  SQL Server, Oracle and DB2 all support the ESCAPE '\' clause. 
										// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
										if ( this.m_bIsMySQL || this.m_bIsPostgreSQL )
											sToken = sToken.replace('\\', '\\\\');
										// 12/04/2008 Paul.  SQL Server needs to know to use the national character set. 
										// This solves a problem searching farsi. 
										if ( this.m_bIsSQLServer )
											sbSqlQuery += sField + " like N'%" + sToken + "%'";
										else
											sbSqlQuery += sField + " like '%" + sToken + "%'";
										// 07/16/2006 Paul.  MySQL requires that slashes be escaped, even in the escape clause. 
										// 09/02/2008 Paul.  PostgreSQL requires two slashes. 
										if ( this.m_bIsMySQL || this.m_bIsPostgreSQL )
											sbSqlQuery += " escape '\\\\'";
										else
											sbSqlQuery += " escape '\\'";
									}
								}
								else
								{
									// 12/17/2007 Paul.  Single quotes need to be manually escaped. 
									sToken = this.EscapeSql(sToken);
									if ( nLessFlag == 1 )
									{
										// 12/04/2008 Paul.  SQL Server needs to know to use the national character set. 
										// This solves a problem searching farsi. 
										if ( this.m_bIsSQLServer )
										{
											if ( bEqualFlag )
												sbSqlQuery += sField + " <= N'" + sToken + "'";
											else
												sbSqlQuery += sField + " < N'" + sToken + "'";
										}
										else
										{
											if ( bEqualFlag )
												sbSqlQuery += sField + " <= '" + sToken + "'";
											else
												sbSqlQuery += sField + " < '" + sToken + "'";
										}
									}
									else if ( nLessFlag == -1 )
									{
										// 12/04/2008 Paul.  SQL Server needs to know to use the national character set. 
										// This solves a problem searching farsi. 
										if ( this.m_bIsSQLServer )
										{
											if ( bEqualFlag )
												sbSqlQuery += sField + " >= N'" + sToken + "'";
											else
												sbSqlQuery += sField + " > N'" + sToken + "'";
										}
										else
										{
											if ( bEqualFlag )
												sbSqlQuery += sField + " >= '" + sToken + "'";
											else
												sbSqlQuery += sField + " > '" + sToken + "'";
										}
									}
								}
							}
								
							nQueryLine += 1;
						}
					}
				}
				nNotFlag   = 0;
				bOrFlag    = false;
				bEqualFlag = false;
				nLessFlag  = 0;
			}
		}
		if ( nQueryLine > 0 )
		{
			sbSqlQuery += ')';
			return sbSqlQuery;
		}
		return '';
	}

	public ApplyFilter(sField, sInput)
	{
		var nSuccess    = 0;
		var nNotFlag    = 0;
		var bOrFlag     = false;
		var nLessFlag   = 0;
		var bEqualFlag  = false;

		if ( sInput !== undefined )
			this.ParseInput(sInput);
		// 10/24/2012 Paul.  Special case when input is only an equals. 
		if ( sInput == '=' )
			return true;

		for ( var nThisToken in this.m_arrTokens )
		{
			var sThisToken = this.m_arrTokens[nThisToken];
			if      ( this.m_bFeatureMIMUS && sThisToken == '-' )
				nNotFlag = 1;
			else if ( this.m_bFeaturePLUS  && sThisToken == '+' )
				nNotFlag = 2;
			// 12/27/2017 Paul.  Treat comma as the OR operator so that Team Sets and User Sets can automatically be managed. 
			else if ( this.m_bFeaturePLUS  && sThisToken == ',' )
				bOrFlag = true;
			// 01/20/2010 Paul.  AND, OR and NOT clauses have been broken for a very long time.  We need to allow mixed-case for these tokens. 
			else if ( this.m_bFeatureOR    && (sThisToken.toUpperCase() == this.m_sTermOR ) )
				bOrFlag = true;
			else if ( this.m_bFeatureAND   && (sThisToken.toUpperCase() == this.m_sTermAND) )
				bOrFlag = false;
			else if ( this.m_bFeatureNOT   && (sThisToken.toUpperCase() == this.m_sTermNOT) )
				nNotFlag = 1;
			// 12/17/2007 Paul.  Add support for <, <=, > and >=. 
			else if ( this.m_bFeatureLESS  && sThisToken == '<' )
				nLessFlag = 1;
			else if ( this.m_bFeatureLESS  && sThisToken == '>' )
				nLessFlag = -1;
			// 12/17/2007 Paul.  Add support for ! and !=.  They are both the same. 
			else if ( this.m_bFeatureEXCL  && sThisToken == '!' )
				nNotFlag = 1;
			else if ( this.m_bFeatureEQUAL && sThisToken == '=' )
				bEqualFlag = true;
			else
			{
				if ( sThisToken.length > 0 )
				{
					//Google ignores single digit and single letters unless + or - is used. 
					// 09/25/2011 Paul.  IE in quirks mode does not support character indexing. 
					if ( !this.m_bFeatureSINGLE || nNotFlag > 0 || sThisToken.length > 1 || !this.isAlphaNum(sThisToken.charAt(0)) )
					{
						//Ignore quoted strings that contain nothing after the quote. 
						if ( sThisToken.charAt(0) != '\"' || sThisToken.length > 1 )
						{
							//Remove the double quote flag from a quoted string. 
							var sToken = sThisToken;
							// 09/25/2011 Paul.  IE in quirks mode does not support character indexing. 
							if ( sToken.charAt(0) == '\"' )
								sToken = sThisToken.substring(1);
								
							// 12/17/2007 Paul.  Wildcards will have a higher priority over greater than or less than. 
							if ( this.m_bFeatureSTAR && sToken.indexOf('*') >= 0 )
							{
								//sbSqlQuery += (sField + " like '" + sToken + "'");
								if ( sToken.charAt(0) == '*' && sToken.charAt(sToken.length - 1) == "*" )
								{
									if ( sField.toLowerCase().indexOf(sToken.substring(1, sToken.length-1).toLowerCase()) >= 0 )
									{
										if ( nSuccess == 0 || bOrFlag )
											nSuccess = 1;
									}
								}
								else if ( sToken.charAt(0) == '*' )
								{
									if ( EndsWith(sField.toLowerCase(), Right(sToken, sToken.length-1).toLowerCase()) )
									{
										if ( nSuccess == 0 || bOrFlag )
											nSuccess = 1;
									}
								}
								else if ( sToken.charAt(sToken.length - 1) == "*" )
								{
									if ( StartsWith(sField.toLowerCase(), Left(sToken, sToken.length-1).toLowerCase()) )
									{
										if ( nSuccess == 0 || bOrFlag )
											nSuccess = 1;
									}
								}
								else
								{
									var arrWild = sToken.split('*');
									if ( arrWild.length == 2 )
									{
										if ( StartsWith(sField.toLowerCase(), arrWild[0].toLowerCase()) && EndsWith(sField.toLowerCase(), arrWild[1].toLowerCase()) )
										{
											if ( nSuccess == 0 || bOrFlag )
												nSuccess = 1;
										}
									}
								}
							}
							else
							{
								if ( nLessFlag == 0 )
								{
									if ( bEqualFlag )
									{
										if ( nNotFlag == 1 )
										{
											if ( sField.toLowerCase() != sToken.toLowerCase() )
											{
												if ( nSuccess == 0 || bOrFlag )
													nSuccess = 1;
											}
										}
										else
										{
											if ( sField.toLowerCase() == sToken.toLowerCase() )
											{
												if ( nSuccess == 0 || bOrFlag )
													nSuccess = 1;
											}
										}
									}
									else
									{
										if ( sField.toLowerCase().indexOf(sToken.toLowerCase()) >= 0 )
										{
											if ( nSuccess == 0 || bOrFlag )
												nSuccess = 1;
										}
									}
								}
								else
								{
									if ( nNotFlag == 1 )
									{
										if ( nLessFlag == 1 )
											nLessFlag = -1;
										else
											nLessFlag = 1;
										bEqualFlag = !bEqualFlag;
									}
									if ( nLessFlag == 1 )
									{
										if ( bEqualFlag )
										{
											if ( sField.toLowerCase() <= sToken.toLowerCase() )
											{
												if ( nSuccess == 0 || bOrFlag )
													nSuccess = 1;
											}
										}
										else
										{
											if ( sField.toLowerCase() < sToken.toLowerCase() )
											{
												if ( nSuccess == 0 || bOrFlag )
													nSuccess = 1;
											}
										}
									}
									else if ( nLessFlag == -1 )
									{
										if ( bEqualFlag )
										{
											if ( sField.toLowerCase() >= sToken.toLowerCase() )
											{
												if ( nSuccess == 0 || bOrFlag )
													nSuccess = 1;
											}
										}
										else
										{
											if ( sField.toLowerCase() > sToken.toLowerCase() )
											{
												if ( nSuccess == 0 || bOrFlag )
													nSuccess = 1;
											}
										}
									}
								}
							}
						}
					}
				}
				nNotFlag   = 0;
				bOrFlag    = false;
				bEqualFlag = false;
				nLessFlag  = 0;
			}
		}
		return nSuccess == 1;
	}
}
