

print 'TIMEZONES Name Changes';
GO
-- delete TIMEZONES
set nocount on;
GO

-- 04/08/2010 Paul.  Name Changes must occur before TIMEZONES defaults.1.sql.

-- 02/22/2007 Paul.  2007 time zone update for Microsoft Windows operating systems
-- http://support.microsoft.com/kb/928388
if exists (select * from TIMEZONES where NAME = N'(GMT+04:00) Baku, Tbilisi, Yerevan' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT+04:00) Baku, Tbilisi, Yerevan';
	update TIMEZONES
	   set NAME          = N'(GMT+04:00) Baku'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT+04:00) Baku, Tbilisi, Yerevan'
	   and DELETED = 0;
end -- if;

if exists (select * from TIMEZONES where NAME = N'(GMT+02:00) Athens, Istanbul, Minsk' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT+02:00) Athens, Istanbul, Minsk';
	update TIMEZONES
	   set NAME          = N'(GMT+02:00) Athens, Bucharest, Istanbul'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT+02:00) Athens, Istanbul, Minsk'
	   and DELETED = 0;
end -- if;

if exists (select * from TIMEZONES where NAME = N'(GMT-06:00) Guadalajara, Mexico City, Monterrey' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT-06:00) Guadalajara, Mexico City, Monterrey';
	update TIMEZONES
	   set NAME          = N'(GMT-06:00) Guadalajara, Mexico City, Monterrey - Old'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT-06:00) Guadalajara, Mexico City, Monterrey'
	   and DELETED = 0;
end -- if;

if exists (select * from TIMEZONES where NAME = N'(GMT) Casablanca, Monrovia' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT) Casablanca, Monrovia';
	update TIMEZONES
	   set NAME          = N'(GMT) Casablanca, Monrovia, Reykjavik'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT) Casablanca, Monrovia'
	   and DELETED = 0;
end -- if;

if exists (select * from TIMEZONES where NAME = N'(GMT-07:00) Chihuahua, La Paz, Mazatlan' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT-07:00) Chihuahua, La Paz, Mazatlan';
	update TIMEZONES
	   set NAME          = N'(GMT-07:00) Chihuahua, La Paz, Mazatlan - Old'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT-07:00) Chihuahua, La Paz, Mazatlan'
	   and DELETED = 0;
end -- if;

if exists (select * from TIMEZONES where NAME = N'(GMT+06:00) Sri Jayawardenepura' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT+06:00) Sri Jayawardenepura';
	update TIMEZONES
	   set NAME          = N'(GMT+05:30) Sri Jayawardenepura'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT+06:00) Sri Jayawardenepura'
	   and DELETED = 0;
end -- if;

if exists (select * from TIMEZONES where NAME = N'(GMT-08:00) Pacific Time (US & Canada); Tijuana' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT-08:00) Pacific Time (US & Canada), Tijuana';
	update TIMEZONES
	   set NAME          = N'(GMT-08:00) Pacific Time (US & Canada)'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT-08:00) Pacific Time (US & Canada); Tijuana'
	   and DELETED = 0;
end -- if;

/*
-- 04/08/2010 Paul.  (GMT-05:00) Bogota, Lima, Quito changes in 2010. 
if exists (select * from TIMEZONES where NAME = N'(GMT-05:00) Bogota, Lima, Quito' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT-05:00) Bogota, Lima, Quito';
	update TIMEZONES
	   set NAME          = N'(GMT-05:00) Bogota, Lima, Quito, Rio Branco'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT-05:00) Bogota, Lima, Quito'
	   and DELETED = 0;
end -- if;
*/

-- 04/08/2010 Paul.  2010 time zone update for Microsoft Windows operating systems
-- http://support.microsoft.com/kb/914387
if exists (select * from TIMEZONES where NAME = N'(GMT-03:00) Buenos Aires, Georgetown' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT-03:00) Buenos Aires, Georgetown';
	update TIMEZONES
	   set NAME          = N'(GMT-03:00) Buenos Aires'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT-03:00) Buenos Aires, Georgetown'
	   and DELETED = 0;
end -- if;
if exists (select * from TIMEZONES where NAME = N'(GMT+06:00) Astana, Dhaka' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT+06:00) Astana, Dhaka';
	update TIMEZONES
	   set NAME          = N'(GMT+06:00) Astana'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT+06:00) Astana, Dhaka'
	   and DELETED = 0;
end -- if;
if exists (select * from TIMEZONES where NAME = N'(GMT+12:00) Fiji, Kamchatka, Marshall Is.' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT+12:00) Fiji, Kamchatka, Marshall Is.';
	update TIMEZONES
	   set NAME          = N'(GMT+12:00) Fiji'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT+12:00) Fiji, Kamchatka, Marshall Is.'
	   and DELETED = 0;
end -- if;
if exists (select * from TIMEZONES where NAME = N'(GMT+03:00) Tbilisi' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT+03:00) Tbilisi';
	update TIMEZONES
	   set NAME          = N'(GMT+04:00) Tbilisi'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT+03:00) Tbilisi'
	   and DELETED = 0;
end -- if;
if exists (select * from TIMEZONES where NAME = N'(GMT) Casablanca, Monrovia, Reykjavik' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT) Casablanca, Monrovia, Reykjavik';
	update TIMEZONES
	   set NAME          = N'(GMT) Casablanca'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT) Casablanca, Monrovia, Reykjavik'
	   and DELETED = 0;
end -- if;
if exists (select * from TIMEZONES where NAME = N'(GMT+08:00) Irkutsk, Ulaan Bataar' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT+08:00) Irkutsk, Ulaan Bataar';
	update TIMEZONES
	   set NAME          = N'(GMT+08:00) Irkutsk'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT+08:00) Irkutsk, Ulaan Bataar'
	   and DELETED = 0;
end -- if;
if exists (select * from TIMEZONES where NAME = N'(GMT-08:00) Tijuana, Baja California' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT-08:00) Tijuana, Baja California';
	update TIMEZONES
	   set NAME          = N'(GMT-08:00) Tijuana'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT-08:00) Tijuana, Baja California'
	   and DELETED = 0;
end -- if;
if exists (select * from TIMEZONES where NAME = N'(GMT+05:00) Islamabad, Karachi, Tashkent' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT+05:00) Islamabad, Karachi, Tashkent';
	update TIMEZONES
	   set NAME          = N'(GMT+05:00) Islamabad, Karachi'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT+05:00) Islamabad, Karachi, Tashkent'
	   and DELETED = 0;
end -- if;
if exists (select * from TIMEZONES where NAME = N'(GMT-05:00) Bogota, Lima, Quito, Rio Branco' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT-05:00) Bogota, Lima, Quito, Rio Branco';
	update TIMEZONES
	   set NAME          = N'(GMT-05:00) Bogota, Lima, Quito'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT-05:00) Bogota, Lima, Quito, Rio Branco'
	   and DELETED = 0;
end -- if;
if exists (select * from TIMEZONES where NAME = N'(GMT-11:00) Midway Island, Samoa' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT-11:00) Midway Island, Samoa';
	update TIMEZONES
	   set NAME          = N'(GMT-11:00) Samoa'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT-11:00) Midway Island, Samoa'
	   and DELETED = 0;
end -- if;
if exists (select * from TIMEZONES where NAME = N'(GMT+06:00) Almaty, Novosibirsk' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT+06:00) Almaty, Novosibirsk';
	update TIMEZONES
	   set NAME          = N'(GMT+06:00) Novosibirsk'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT+06:00) Almaty, Novosibirsk'
	   and DELETED = 0;
end -- if;
if exists (select * from TIMEZONES where NAME = N'(GMT-04:00) Caracas, La Paz' and DELETED = 0) begin -- then
	print N'Rename Time Zone: (GMT-04:00) Caracas, La Paz';
	update TIMEZONES
	   set NAME          = N'(GMT-04:30) Caracas'
	     , DATE_MODIFIED =  getdate()             
	 where NAME          = N'(GMT-04:00) Caracas, La Paz'
	   and DELETED = 0;
end -- if;

GO


set nocount off;
GO


/* -- #if Oracle
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			StoO_selcnt := 0;
		WHEN OTHERS THEN
			RAISE;
	END;
	COMMIT WORK;
END;
/
-- #endif Oracle */

/* -- #if IBM_DB2
	commit;
  end
/

call dbo.spTIMEZONES_Changes()
/

call dbo.spSqlDropProcedure('spTIMEZONES_Changes')
/

-- #endif IBM_DB2 */

