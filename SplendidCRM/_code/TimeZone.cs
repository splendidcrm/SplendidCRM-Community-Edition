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
using System.Diagnostics;
using System.Runtime.InteropServices;
using Microsoft.Win32;

namespace SplendidCRM
{
	/// <summary>
	/// Summary description for TimeZone.
	/// </summary>
	public class TimeZone
	{
		[StructLayout( LayoutKind.Sequential )]
		private struct SYSTEMTIME
		{
			public UInt16 wYear        ;
			public UInt16 wMonth       ;
			public UInt16 wDayOfWeek   ;
			public UInt16 wDay         ;
			public UInt16 wHour        ;
			public UInt16 wMinute      ;
			public UInt16 wSecond      ;
			public UInt16 wMilliseconds;
		}

		[StructLayout( LayoutKind.Sequential )]
		private struct TZI
		{
			public int        nBias         ;
			public int        nStandardBias ;
			public int        nDaylightBias ;
			public SYSTEMTIME dtStandardDate;
			public SYSTEMTIME dtDaylightDate;
		}
		
		protected Guid   m_gID                    ;
		protected string m_sNAME                  ;
		protected string m_sSTANDARD_NAME         ;
		protected string m_sSTANDARD_ABBREVIATION ;
		protected string m_sDAYLIGHT_NAME         ;
		protected string m_sDAYLIGHT_ABBREVIATION ;
		protected int    m_nBIAS                  ;
		protected int    m_nSTANDARD_BIAS         ;
		protected int    m_nDAYLIGHT_BIAS         ;
		protected int    m_nSTANDARD_YEAR         ;
		protected int    m_nSTANDARD_MONTH        ;
		protected int    m_nSTANDARD_WEEK         ;
		protected int    m_nSTANDARD_DAYOFWEEK    ;
		protected int    m_nSTANDARD_HOUR         ;
		protected int    m_nSTANDARD_MINUTE       ;
		protected int    m_nDAYLIGHT_YEAR         ;
		protected int    m_nDAYLIGHT_MONTH        ;
		protected int    m_nDAYLIGHT_WEEK         ;
		protected int    m_nDAYLIGHT_DAYOFWEEK    ;
		protected int    m_nDAYLIGHT_HOUR         ;
		protected int    m_nDAYLIGHT_MINUTE       ;
		protected bool   m_bGMTStorage            ;
		// 01/02/2012 Paul.  Add iCal TZID. 
		protected string m_sTZID                  ;
		
		public Guid ID
		{
			get
			{
				return m_gID;
			}
		}

		// 09/25/2010 Paul.  We need access to the time zone properties in ReportService2010.asmx. 
		public int Bias                     { get { return m_nBIAS              ; } }
		public int StandardBias             { get { return m_nSTANDARD_BIAS     ; } }
		public int StandardDateYear         { get { return m_nSTANDARD_YEAR     ; } }
		public int StandardDateMonth        { get { return m_nSTANDARD_MONTH    ; } }
		public int StandardDateWeek         { get { return m_nSTANDARD_WEEK     ; } }
		public int StandardDateDay          { get { return m_nSTANDARD_DAYOFWEEK; } }
		public int StandardDateHour         { get { return m_nSTANDARD_HOUR     ; } }
		public int StandardDateMinute       { get { return m_nSTANDARD_MINUTE   ; } }
		public int DaylightBias             { get { return m_nDAYLIGHT_BIAS     ; } }
		public int DaylightDateYear         { get { return m_nDAYLIGHT_YEAR     ; } }
		public int DaylightDateMonth        { get { return m_nDAYLIGHT_MONTH    ; } }
		public int DaylightDateWeek         { get { return m_nDAYLIGHT_WEEK     ; } }
		public int DaylightDateDay          { get { return m_nDAYLIGHT_DAYOFWEEK; } }
		public int DaylightDateHour         { get { return m_nDAYLIGHT_HOUR     ; } }
		public int DaylightDateMinute       { get { return m_nDAYLIGHT_MINUTE   ; } }
		public string StandardAbbreviation  { get { return m_sSTANDARD_ABBREVIATION; } }
		public string DaylightAbbreviation  { get { return m_sDAYLIGHT_ABBREVIATION; } }
		// 01/02/2012 Paul.  Add iCal TZID. 
		public string TZID                  { get { return m_sTZID              ; } }

		public static TimeZone CreateTimeZone(Guid gTIMEZONE)
		{
			HttpApplicationState Application = HttpContext.Current.Application;
			return CreateTimeZone(Application, gTIMEZONE);
		}

		// 06/26/2010 Paul.  We need to be able to create a timezone from within the Workflow engine. 
		public static TimeZone CreateTimeZone(HttpApplicationState Application, Guid gTIMEZONE)
		{
			TimeZone T10z = Application["TIMEZONE." + gTIMEZONE.ToString()] as SplendidCRM.TimeZone;
			if ( T10z == null )
			{
				// 08/29/2005 Paul. First try and use the default from CONFIG. 
				gTIMEZONE = Sql.ToGuid(Application["CONFIG.default_timezone"]);
				T10z = Application["TIMEZONE." + gTIMEZONE.ToString()] as SplendidCRM.TimeZone;
				if ( T10z == null )
				{
					// Default to EST if default not specified. 
					gTIMEZONE = new Guid("BFA61AF7-26ED-4020-A0C1-39A15E4E9E0A");
					T10z = Application["TIMEZONE." + gTIMEZONE.ToString()] as SplendidCRM.TimeZone;
				}
				// If timezone is still null, then create a blank zone. 
				if ( T10z == null )
				{
					string sMessage = "Could not load default timezone " + Sql.ToString(Application["CONFIG.default_timezone"]) + " nor EST timezone BFA61AF7-26ED-4020-A0C1-39A15E4E9E0A. "
					                + "Eastern Standard Time will be extracted from the Windows Registry and used as the default.";
					SplendidError.SystemMessage(Application, "Error", new StackTrace(true).GetFrame(0), sMessage);
					// T10z = new TimeZone();
					// 07/25/2006  Paul.  Still having a problem with the hosting company.  
					// Try and skip the entire registry code. 
					// 01/02/2012 Paul.  Add iCal TZID. 
					T10z = new TimeZone
						( new Guid("BFA61AF7-26ED-4020-A0C1-39A15E4E9E0A")
						, "(GMT-05:00) Eastern Time (US & Canada)"
						, "EST"
						, "Eastern Standard Time"
						, "Eastern Daylight Time"
						, "EDT"
						, 300
						,   0
						, -60
						,   0
						,  10
						,   5
						,   0
						,   2
						,   0
						,   0
						,   4
						,   1
						,   0
						,   2
						,   0
						, false
						, "America/New_York"
						);
					Application["TIMEZONE." + gTIMEZONE.ToString()] = T10z;
					// 09/14/2015 Paul.  TZID is used with Google Sync and iCloud Sync. 
					Application["TIMEZONE.TZID." + T10z.TZID] = T10z;
				}
			}
			return T10z;
		}
		
		public TimeZone()
		{
			m_gID                    = Guid.Empty  ;
			m_sNAME                  = String.Empty;
			m_sSTANDARD_NAME         = String.Empty;
			m_sSTANDARD_ABBREVIATION = String.Empty;
			m_sDAYLIGHT_NAME         = String.Empty;
			m_sDAYLIGHT_ABBREVIATION = String.Empty;
			try
			{
				RegistryKey keyEST = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Time Zones\Eastern Standard Time");
				if ( keyEST != null )
				{
					m_sSTANDARD_NAME = keyEST.GetValue("Std"    ).ToString();
					m_sNAME          = keyEST.GetValue("Display").ToString();
					m_sDAYLIGHT_NAME = keyEST.GetValue("Dlt"    ).ToString();
					byte[] byTZI         = (byte[]) keyEST.GetValue("TZI");

					TZI tzi ;
					GCHandle h = GCHandle.Alloc(byTZI, GCHandleType.Pinned);
					try
					{
						tzi = (TZI) Marshal.PtrToStructure( h.AddrOfPinnedObject(), typeof(TZI) );
						m_nBIAS                = tzi.nBias                    ;
						m_nSTANDARD_BIAS       = tzi.nStandardBias            ;
						m_nDAYLIGHT_BIAS       = tzi.nDaylightBias            ;
						m_nSTANDARD_YEAR       = tzi.dtStandardDate.wYear     ;
						m_nSTANDARD_MONTH      = tzi.dtStandardDate.wMonth    ;
						m_nSTANDARD_WEEK       = tzi.dtStandardDate.wDay      ;
						m_nSTANDARD_DAYOFWEEK  = tzi.dtStandardDate.wDayOfWeek;
						m_nSTANDARD_HOUR       = tzi.dtStandardDate.wHour     ;
						m_nSTANDARD_MINUTE     = tzi.dtStandardDate.wMinute   ;
						m_nDAYLIGHT_YEAR       = tzi.dtDaylightDate.wYear     ;
						m_nDAYLIGHT_MONTH      = tzi.dtDaylightDate.wMonth    ;
						m_nDAYLIGHT_WEEK       = tzi.dtDaylightDate.wDay      ;
						m_nDAYLIGHT_DAYOFWEEK  = tzi.dtDaylightDate.wDayOfWeek;
						m_nDAYLIGHT_HOUR       = tzi.dtDaylightDate.wHour     ;
						m_nDAYLIGHT_MINUTE     = tzi.dtDaylightDate.wMinute   ;
					}
					finally
					{
						h.Free();
					}
				}
			}
			catch
			{
				// 07/25/2006 Paul.  Some web hosting companies have tight security and block all access to the registry. 
				// In those cases, just assume EST. 
				m_sNAME                  = "(GMT-05:00) Eastern Time (US & Canada)";
				m_sSTANDARD_ABBREVIATION = "EST";
				m_sSTANDARD_NAME         = "Eastern Standard Time";
				m_sDAYLIGHT_NAME         = "Eastern Daylight Time";
				m_sDAYLIGHT_ABBREVIATION = "EDT";
				m_nBIAS                  = 300;
				m_nSTANDARD_BIAS         =   0;
				m_nDAYLIGHT_BIAS         = -60;
				m_nSTANDARD_YEAR         =   0;
				m_nSTANDARD_MONTH        =  10;
				m_nSTANDARD_WEEK         =   5;
				m_nSTANDARD_DAYOFWEEK    =   0;
				m_nSTANDARD_HOUR         =   2;
				m_nSTANDARD_MINUTE       =   0;
				m_nDAYLIGHT_YEAR         =   0;
				m_nDAYLIGHT_MONTH        =   4;
				m_nDAYLIGHT_WEEK         =   1;
				m_nDAYLIGHT_DAYOFWEEK    =   0;
				m_nDAYLIGHT_HOUR         =   2;
				m_nDAYLIGHT_MINUTE       =   0;
				// 01/02/2012 Paul.  Add iCal TZID. 
				m_sTZID                  = "America/New_York";
			}
		}
		
		public TimeZone
			( Guid   gID                   
			, string sNAME                 
			, string sSTANDARD_NAME        
			, string sSTANDARD_ABBREVIATION
			, string sDAYLIGHT_NAME        
			, string sDAYLIGHT_ABBREVIATION
			, int    nBIAS                 
			, int    nSTANDARD_BIAS        
			, int    nDAYLIGHT_BIAS        
			, int    nSTANDARD_YEAR        
			, int    nSTANDARD_MONTH       
			, int    nSTANDARD_WEEK        
			, int    nSTANDARD_DAYOFWEEK   
			, int    nSTANDARD_HOUR        
			, int    nSTANDARD_MINUTE      
			, int    nDAYLIGHT_YEAR        
			, int    nDAYLIGHT_MONTH       
			, int    nDAYLIGHT_WEEK        
			, int    nDAYLIGHT_DAYOFWEEK   
			, int    nDAYLIGHT_HOUR        
			, int    nDAYLIGHT_MINUTE      
			, bool   bGMTStorage           
			, string sTZID                 
			)
		{
			m_gID                    = gID                    ;
			m_sNAME                  = sNAME                  ;
			m_sSTANDARD_NAME         = sSTANDARD_NAME         ;
			m_sSTANDARD_ABBREVIATION = sSTANDARD_ABBREVIATION ;
			m_sDAYLIGHT_NAME         = sDAYLIGHT_NAME         ;
			m_sDAYLIGHT_ABBREVIATION = sDAYLIGHT_ABBREVIATION ;
			m_nBIAS                  = nBIAS                  ;
			m_nSTANDARD_BIAS         = nSTANDARD_BIAS         ;
			m_nDAYLIGHT_BIAS         = nDAYLIGHT_BIAS         ;
			m_nSTANDARD_YEAR         = nSTANDARD_YEAR         ;
			m_nSTANDARD_MONTH        = nSTANDARD_MONTH        ;
			m_nSTANDARD_WEEK         = nSTANDARD_WEEK         ;
			m_nSTANDARD_DAYOFWEEK    = nSTANDARD_DAYOFWEEK    ;
			m_nSTANDARD_HOUR         = nSTANDARD_HOUR         ;
			m_nSTANDARD_MINUTE       = nSTANDARD_MINUTE       ;
			m_nDAYLIGHT_YEAR         = nDAYLIGHT_YEAR         ;
			m_nDAYLIGHT_MONTH        = nDAYLIGHT_MONTH        ;
			m_nDAYLIGHT_WEEK         = nDAYLIGHT_WEEK         ;
			m_nDAYLIGHT_DAYOFWEEK    = nDAYLIGHT_DAYOFWEEK    ;
			m_nDAYLIGHT_HOUR         = nDAYLIGHT_HOUR         ;
			m_nDAYLIGHT_MINUTE       = nDAYLIGHT_MINUTE       ;
			m_bGMTStorage            = bGMTStorage            ;
			// 01/02/2012 Paul.  Add iCal TZID. 
			m_sTZID                  = sTZID                  ;
		}

		private static DateTime TransitionDate(int nYEAR, int nMONTH, int nWEEK, int nDAYOFWEEK, int nHOUR, int nMINUTE)
		{
			DateTime dtTransitionDate = new DateTime(nYEAR, nMONTH, 1, nHOUR, nMINUTE, 0);
			// First DAYOFWEEK (typically Sunday) in the month. 
			int nFirstDayOfWeek = nDAYOFWEEK + (DayOfWeek.Sunday - dtTransitionDate.DayOfWeek);
			if ( nFirstDayOfWeek < 0 )
				nFirstDayOfWeek += 7;
			dtTransitionDate = dtTransitionDate.AddDays(nFirstDayOfWeek);
			// Now add the weeks, but watch for overflow to next month.  
			dtTransitionDate = dtTransitionDate.AddDays(7 * (nWEEK - 1));
			// In case of overflow, subtract a week until the month matches. 
			while ( dtTransitionDate.Month != nMONTH )
				dtTransitionDate = dtTransitionDate.AddDays(-7);
			return dtTransitionDate;
		}

		public DateTime FromServerTime(object objServerTime)
		{
			DateTime dtServerTime = Sql.ToDateTime(objServerTime);
			if ( dtServerTime == DateTime.MinValue )
				return dtServerTime;
			// 03/25/2013 Paul.  Force the kind so that ToUniversalTime() will work. 
			if ( dtServerTime.Kind != DateTimeKind.Local )
				dtServerTime = DateTime.SpecifyKind(dtServerTime, DateTimeKind.Local);
			// 11/07/2005 Paul.  SugarCRM 3.5 now stores time in GMT. 
			if ( m_bGMTStorage )
				return FromUniversalTime(dtServerTime);
			else
				return FromUniversalTime(dtServerTime.ToUniversalTime());
		}

		public DateTime FromServerTime(DateTime dtServerTime)
		{
			// 11/29/2008 Paul.  The time cannot be converted if it is already ad the min value. 
			if ( dtServerTime == DateTime.MinValue )
				return dtServerTime;
			// 03/25/2013 Paul.  Force the kind so that ToUniversalTime() will work. 
			if ( dtServerTime.Kind != DateTimeKind.Local )
				dtServerTime = DateTime.SpecifyKind(dtServerTime, DateTimeKind.Local);
			// 11/07/2005 Paul.  SugarCRM 3.5 now stores time in GMT. 
			if ( m_bGMTStorage )
				return FromUniversalTime(dtServerTime);
			else
				return FromUniversalTime(dtServerTime.ToUniversalTime());
		}

		public DateTime FromUniversalTime(DateTime dtUniversalTime)
		{
			// 11/07/2005 Paul.  Don't modify if value is MinValue.
			if ( dtUniversalTime == DateTime.MinValue )
				return dtUniversalTime;
			DateTime dtZoneTime = dtUniversalTime.AddMinutes(-m_nBIAS);
			int nLocalMonth = dtZoneTime.Month;

			// 09/15/2008 Jake.  Changed to use IsDaylightSavings method making To and From universal time methods consistant.
			if (IsDaylightSavings(dtZoneTime))
			{
				dtZoneTime = dtZoneTime.AddMinutes(-m_nDAYLIGHT_BIAS);
			}
			return dtZoneTime;
		}

		public bool IsDaylightSavings(DateTime dtZoneTime)
		{
			bool bDaylightSavings = false;
			int nLocalMonth = dtZoneTime.Month;
			// This date/time conversion function will be called with a very high frequency.  It is therefore important to optimize as much as possible. 
			// For example, we only have to worry about complicated daylight savings calculations during the transition months.  
			// Otherwise, we are either in daylight savings or not in daylight savings. 
			// If a timezone does not observer daylight savings, then the months will be 0 and no calculations will be performed. 
			if ( nLocalMonth == m_nDAYLIGHT_MONTH )
			{
				// The transition date needs to be calculated every time because the Local year may change, and the date changes every year. 
				DateTime dtTransitionDate = TransitionDate(dtZoneTime.Year, m_nDAYLIGHT_MONTH, m_nDAYLIGHT_WEEK, m_nDAYLIGHT_DAYOFWEEK, m_nDAYLIGHT_HOUR, m_nDAYLIGHT_MINUTE);
				// 03/19/2008 Jason.  Switch if daylight month is before standard because that indicates southern hemisphere. 
				if ( m_nDAYLIGHT_MONTH > m_nSTANDARD_MONTH )
				{
					if ( dtZoneTime < dtTransitionDate )
						bDaylightSavings = true;
				}
				else
				{
					if ( dtZoneTime > dtTransitionDate )
						bDaylightSavings = true;
				}
			}
			else if ( nLocalMonth == m_nSTANDARD_MONTH )
			{
				// The transition date needs to be calculated every time because the Local year may change, and the date changes every year. 
				DateTime dtTransitionDate = TransitionDate(dtZoneTime.Year, m_nSTANDARD_MONTH, m_nSTANDARD_WEEK, m_nSTANDARD_DAYOFWEEK, m_nSTANDARD_HOUR, m_nSTANDARD_MINUTE);
				// Don't add the bias here because it is already part of the zone time. 
				// Since there is an overlap due to the drop back in time, we cannot fully be sure that the 
				// supplied time is before or after the daylight transition.  We will always assume that it is before. 
				// 03/19/2008 Jason.  Switch if daylight month is before standard because that indicates southern hemisphere. 
				if ( m_nDAYLIGHT_MONTH > m_nSTANDARD_MONTH )
				{
					if ( dtZoneTime > dtTransitionDate )
						bDaylightSavings = true;
				}
				else
				{
					if ( dtZoneTime < dtTransitionDate )
						bDaylightSavings = true;
				}
			}
			else
			{
				// 03/19/2008 Jason.  Switch if daylight month is before standard because that indicates southern hemisphere. 
				if ( m_nDAYLIGHT_MONTH > m_nSTANDARD_MONTH )
				{
					// If we are solidly in the daylight savings months, then the calculation is simple. 
					// 09/15/2008 Jake.  Fixed calculation of DLS in southern hemisphere. 
					// Correct way is current month has to be AFTER DLS month, and before standard month. 
					if ( nLocalMonth < m_nSTANDARD_MONTH && nLocalMonth > m_nDAYLIGHT_MONTH )
						bDaylightSavings = true;
				}
				else
				{
					// If we are solidly in the daylight savings months, then the calculation is simple. 
					if ( nLocalMonth > m_nDAYLIGHT_MONTH && nLocalMonth < m_nSTANDARD_MONTH )
						bDaylightSavings = true;
				}
			}
			return bDaylightSavings;
		}

		// 04/04/2006 Paul.  SOAP needs a quick way to convert from UniversalTime to ServerTime. 
		public DateTime ToServerTimeFromUniversalTime(DateTime dtUniversalTime)
		{
			if ( dtUniversalTime == DateTime.MinValue )
				return dtUniversalTime;
			// 03/25/2013 Paul.  Force the kind so that ToLocalTime() will work. 
			if ( dtUniversalTime.Kind != DateTimeKind.Utc )
				dtUniversalTime = DateTime.SpecifyKind(dtUniversalTime, DateTimeKind.Utc);
			// 11/07/2005 Paul.  SugarCRM 3.5 now stores time in GMT. 
			if ( m_bGMTStorage )
				return dtUniversalTime;
			else
				return dtUniversalTime.ToLocalTime();
		}

		// 08/17/2006 Paul.  SOAP needs a quick way to convert from ServerTime to UniversalTime. 
		public DateTime ToUniversalTimeFromServerTime(DateTime dtServerTime)
		{
			if ( dtServerTime == DateTime.MinValue )
				return dtServerTime;
			// 03/25/2013 Paul.  Force the kind so that ToUniversalTime() will work. 
			if ( dtServerTime.Kind != DateTimeKind.Local )
				dtServerTime = DateTime.SpecifyKind(dtServerTime, DateTimeKind.Local);
			// 11/07/2005 Paul.  SugarCRM 3.5 now stores time in GMT. 
			if ( m_bGMTStorage )
				return dtServerTime;
			else
				return dtServerTime.ToUniversalTime();
		}

		public DateTime ToServerTimeFromUniversalTime(string sUniversalTime)
		{
			DateTime dtUniversalTime = DateTime.Parse(sUniversalTime);
			// 03/25/2013 Paul.  Force the kind so that ToLocalTime() will work. 
			if ( dtUniversalTime.Kind != DateTimeKind.Utc )
				dtUniversalTime = DateTime.SpecifyKind(dtUniversalTime, DateTimeKind.Utc);
			return ToServerTimeFromUniversalTime(dtUniversalTime);
		}

		public DateTime ToServerTime(DateTime dtZoneTime)
		{
			DateTime dtUniversalTime = ToUniversalTime(dtZoneTime);
			if ( dtUniversalTime == DateTime.MinValue )
				return dtUniversalTime;
			// 11/07/2005 Paul.  SugarCRM 3.5 now stores time in GMT. 
			if ( m_bGMTStorage )
				return dtUniversalTime;
			else
				return dtUniversalTime.ToLocalTime();
		}

		public DateTime ToServerTime(string sZoneTime)
		{
			if ( sZoneTime == String.Empty )
				return DateTime.MinValue;
			DateTime dtZoneTime = Sql.ToDateTime(sZoneTime);
			if ( dtZoneTime == DateTime.MinValue )
				return dtZoneTime ;
			DateTime dtUniversalTime = ToUniversalTime(dtZoneTime);
			if ( dtUniversalTime == DateTime.MinValue )
				return dtUniversalTime;
			// 11/07/2005 Paul.  SugarCRM 3.5 now stores time in GMT. 
			if ( m_bGMTStorage )
				return dtUniversalTime;
			else
				return dtUniversalTime.ToLocalTime();
		}

		public DateTime ToUniversalTime(DateTime dtZoneTime)
		{
			// 11/07/2005 Paul.  Don't modify if value is MinValue.
			if ( dtZoneTime == DateTime.MinValue )
				return dtZoneTime;
			DateTime dtUniversalTime = dtZoneTime;
			if ( IsDaylightSavings(dtZoneTime) )
			{
				dtUniversalTime = dtUniversalTime.AddMinutes(m_nDAYLIGHT_BIAS);
			}
			// When converting to Universal Time, the bias is removed after any daylight calculations. 
			dtUniversalTime = dtUniversalTime.AddMinutes(m_nBIAS);
			// 03/25/2013 Paul.  Force the kind so that ToLocalTime() will work.  
			// This was first detected when parsing Google Calendar entries. 
			if ( dtUniversalTime.Kind != DateTimeKind.Utc )
				dtUniversalTime = DateTime.SpecifyKind(dtUniversalTime, DateTimeKind.Utc);
			return dtUniversalTime;
		}

		public string Abbreviation(DateTime dtZoneTime)
		{
			string sZone = String.Empty;
			if ( IsDaylightSavings(dtZoneTime) )
			{
				sZone = m_sDAYLIGHT_ABBREVIATION;
			}
			else
			{
				sZone = m_sSTANDARD_ABBREVIATION;
			}
			return sZone;
		}
	}
}

