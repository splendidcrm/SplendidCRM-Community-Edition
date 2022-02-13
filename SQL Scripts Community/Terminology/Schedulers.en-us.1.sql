

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:42 AM.
print 'TERMINOLOGY Schedulers en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADV_OPTIONS'                               , N'en-US', N'Schedulers', null, null, N'Adv Options';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ALWAYS'                                    , N'en-US', N'Schedulers', null, null, N'Always';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AND'                                       , N'en-US', N'Schedulers', null, null, N' and ';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_BASIC_OPTIONS'                             , N'en-US', N'Schedulers', null, null, N'Basic Options';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CATCH_UP'                                  , N'en-US', N'Schedulers', null, null, N'Catch Up:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CATCH_UP_WARNING'                          , N'en-US', N'Schedulers', null, null, N'';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CRONTAB_EXAMPLES'                          , N'en-US', N'Schedulers', null, null, N'';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_TIME_END'                             , N'en-US', N'Schedulers', null, null, N'Date & Time End:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATE_TIME_START'                           , N'en-US', N'Schedulers', null, null, N'Date & Time Start:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DAY_OF_MONTH'                              , N'en-US', N'Schedulers', null, null, N'date';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DAY_OF_WEEK'                               , N'en-US', N'Schedulers', null, null, N'day';
-- 05/02/2016 Paul.  Add space to the end of the From term. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FROM'                                      , N'en-US', N'Schedulers', null, null, N'From ';
update TERMINOLOGY
   set DISPLAY_NAME      = 'From '
     , DATE_MODIFIED     = getdate()
     , DATE_MODIFIED_UTC = getutcdate()
 where NAME              = 'LBL_FROM'
   and LANG              = 'en-US'
   and '[' + DISPLAY_NAME + ']' = '[From]';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HOUR'                                      , N'en-US', N'Schedulers', null, null, N' hours';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HOUR_SING'                                 , N'en-US', N'Schedulers', null, null, N' hour';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_HOURS'                                     , N'en-US', N'Schedulers', null, null, N'hrs';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DAYS'                                      , N'en-US', N'Schedulers', null, null, N'days';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SECONDS'                                   , N'en-US', N'Schedulers', null, null, N'seconds';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IN'                                        , N'en-US', N'Schedulers', null, null, N' in ';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INTERVAL'                                  , N'en-US', N'Schedulers', null, null, N'Interval';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_JOB'                                       , N'en-US', N'Schedulers', null, null, N'Job:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_JOB_INTERVAL'                              , N'en-US', N'Schedulers', null, null, N'Job Interval:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LAST_RUN'                                  , N'en-US', N'Schedulers', null, null, N'Last Run:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CATCH_UP'                             , N'en-US', N'Schedulers', null, null, N'Catch Up';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DATE_TIME_END'                        , N'en-US', N'Schedulers', null, null, N'Date & Time End';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DATE_TIME_START'                      , N'en-US', N'Schedulers', null, null, N'Date & Time Start';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_JOB'                                  , N'en-US', N'Schedulers', null, null, N'Job';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_JOB_INTERVAL'                         , N'en-US', N'Schedulers', null, null, N'Job Interval';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LAST_RUN'                             , N'en-US', N'Schedulers', null, null, N'Last Run';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Schedulers', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_RANGE'                                , N'en-US', N'Schedulers', null, null, N'Range';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_STATUS'                               , N'en-US', N'Schedulers', null, null, N'Status';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TIME_FROM'                            , N'en-US', N'Schedulers', null, null, N'Time From';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TIME_TO'                              , N'en-US', N'Schedulers', null, null, N'Time To';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TITLE'                                , N'en-US', N'Schedulers', null, null, N'Title';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MIN_MARK'                                  , N'en-US', N'Schedulers', null, null, N' minute mark';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MINS'                                      , N'en-US', N'Schedulers', null, null, N'min';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_TITLE'                              , N'en-US', N'Schedulers', null, null, N'Schedulers';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MON'                                       , N'en-US', N'Schedulers', null, null, N'Monday';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MONTH'                                     , N'en-US', N'Schedulers', null, null, N' month';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MONTHS'                                    , N'en-US', N'Schedulers', null, null, N'mo';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'Schedulers', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEVER'                                     , N'en-US', N'Schedulers', null, null, N'Never';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OFTEN'                                     , N'en-US', N'Schedulers', null, null, N' As often as possible.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ON_THE'                                    , N'en-US', N'Schedulers', null, null, N'On The';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PERENNIAL'                                 , N'en-US', N'Schedulers', null, null, N'perpetual';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RANGE'                                     , N'en-US', N'Schedulers', null, null, N' to ';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RUN'                                       , N'en-US', N'Schedulers', null, null, N'Run';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SCHEDULER'                                 , N'en-US', N'Schedulers', null, null, N'Scheduler:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STATUS'                                    , N'en-US', N'Schedulers', null, null, N'Status:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TIME_FROM'                                 , N'en-US', N'Schedulers', null, null, N'Time From:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TIME_TO'                                   , N'en-US', N'Schedulers', null, null, N'Time To:';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_LIST_SCHEDULER'                            , N'en-US', N'Schedulers', null, null, N'Schedulers';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_SCHEDULER'                             , N'en-US', N'Schedulers', null, null, N'Create Scheduler';
-- 01/24/2012 Paul.  Missing terms. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CRONTAB_EXAMPLES'                          , N'en-US', N'Schedulers', null, null, N'CRONTAB Examples';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Schedulers', null, null, N'Sch';
-- 10/30/2020 Paul.  The React Client requires LBL_LIST_FORM_TITLE. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Schedulers', null, null, N'Schedulers';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Schedulers'                                    , N'en-US', null, N'moduleList'                        ,  60, N'Schedulers';

exec dbo.spTERMINOLOGY_InsertOnly N'0'                                             , N'en-US', null, N'scheduler_day_dom'                 ,   0, N'Sunday';
exec dbo.spTERMINOLOGY_InsertOnly N'1'                                             , N'en-US', null, N'scheduler_day_dom'                 ,   1, N'Monday';
exec dbo.spTERMINOLOGY_InsertOnly N'2'                                             , N'en-US', null, N'scheduler_day_dom'                 ,   2, N'Tuesday';
exec dbo.spTERMINOLOGY_InsertOnly N'3'                                             , N'en-US', null, N'scheduler_day_dom'                 ,   3, N'Wednesday';
exec dbo.spTERMINOLOGY_InsertOnly N'4'                                             , N'en-US', null, N'scheduler_day_dom'                 ,   4, N'Thursday';
exec dbo.spTERMINOLOGY_InsertOnly N'5'                                             , N'en-US', null, N'scheduler_day_dom'                 ,   5, N'Friday';
exec dbo.spTERMINOLOGY_InsertOnly N'6'                                             , N'en-US', null, N'scheduler_day_dom'                 ,   6, N'Saturday';

exec dbo.spTERMINOLOGY_InsertOnly N'Daily'                                         , N'en-US', null, N'scheduler_frequency_dom'           ,   1, N'Daily';
exec dbo.spTERMINOLOGY_InsertOnly N'Weekly'                                        , N'en-US', null, N'scheduler_frequency_dom'           ,   2, N'Weekly';
exec dbo.spTERMINOLOGY_InsertOnly N'Monthly'                                       , N'en-US', null, N'scheduler_frequency_dom'           ,   3, N'Monthly';
exec dbo.spTERMINOLOGY_InsertOnly N'Yearly'                                        , N'en-US', null, N'scheduler_frequency_dom'           ,   4, N'Yearly';

exec dbo.spTERMINOLOGY_InsertOnly N'1'                                             , N'en-US', null, N'scheduler_month_dom'               ,   1, N'January';
exec dbo.spTERMINOLOGY_InsertOnly N'2'                                             , N'en-US', null, N'scheduler_month_dom'               ,   2, N'February';
exec dbo.spTERMINOLOGY_InsertOnly N'3'                                             , N'en-US', null, N'scheduler_month_dom'               ,   3, N'March';
exec dbo.spTERMINOLOGY_InsertOnly N'4'                                             , N'en-US', null, N'scheduler_month_dom'               ,   4, N'April';
exec dbo.spTERMINOLOGY_InsertOnly N'5'                                             , N'en-US', null, N'scheduler_month_dom'               ,   5, N'May';
exec dbo.spTERMINOLOGY_InsertOnly N'6'                                             , N'en-US', null, N'scheduler_month_dom'               ,   6, N'June';
exec dbo.spTERMINOLOGY_InsertOnly N'7'                                             , N'en-US', null, N'scheduler_month_dom'               ,   7, N'July';
exec dbo.spTERMINOLOGY_InsertOnly N'8'                                             , N'en-US', null, N'scheduler_month_dom'               ,   8, N'August';
exec dbo.spTERMINOLOGY_InsertOnly N'9'                                             , N'en-US', null, N'scheduler_month_dom'               ,   9, N'September';
exec dbo.spTERMINOLOGY_InsertOnly N'10'                                            , N'en-US', null, N'scheduler_month_dom'               ,  10, N'October';
exec dbo.spTERMINOLOGY_InsertOnly N'11'                                            , N'en-US', null, N'scheduler_month_dom'               ,  11, N'November';
exec dbo.spTERMINOLOGY_InsertOnly N'12'                                            , N'en-US', null, N'scheduler_month_dom'               ,  12, N'December';

exec dbo.spTERMINOLOGY_InsertOnly N'Active'                                        , N'en-US', null, N'scheduler_status_dom'              ,   1, N'Active';
exec dbo.spTERMINOLOGY_InsertOnly N'Inactive'                                      , N'en-US', null, N'scheduler_status_dom'              ,   2, N'Inactive';
GO


set nocount off;
GO

/* -- #if Oracle
	COMMIT WORK;
END;
/
-- #endif Oracle */

/* -- #if IBM_DB2
	commit;
  end
/

call dbo.spTERMINOLOGY_Schedulers_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Schedulers_en_us')
/
-- #endif IBM_DB2 */
