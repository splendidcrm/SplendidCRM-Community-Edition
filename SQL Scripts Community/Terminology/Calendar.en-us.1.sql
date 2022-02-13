

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:35 AM.
print 'TERMINOLOGY Calendar en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DAY'                                       , N'en-US', N'Calendar', null, null, N'Day';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EDIT'                                      , N'en-US', N'Calendar', null, null, N'Edit';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_TITLE'                              , N'en-US', N'Calendar', null, null, N'Calendar';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MONTH'                                     , N'en-US', N'Calendar', null, null, N'Month';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEXT_DAY'                                  , N'en-US', N'Calendar', null, null, N'Next Day';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEXT_MONTH'                                , N'en-US', N'Calendar', null, null, N'Next Month';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEXT_WEEK'                                 , N'en-US', N'Calendar', null, null, N'Next Week';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEXT_YEAR'                                 , N'en-US', N'Calendar', null, null, N'Next Year';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PREVIOUS_DAY'                              , N'en-US', N'Calendar', null, null, N'Previous Day';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PREVIOUS_MONTH'                            , N'en-US', N'Calendar', null, null, N'Previous Month';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PREVIOUS_WEEK'                             , N'en-US', N'Calendar', null, null, N'Previous Week';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PREVIOUS_YEAR'                             , N'en-US', N'Calendar', null, null, N'Previous Year';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SELECT_USERS'                              , N'en-US', N'Calendar', null, null, N'Select Users';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SHARED'                                    , N'en-US', N'Calendar', null, null, N'Shared';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SHARED_CAL_TITLE'                          , N'en-US', N'Calendar', null, null, N'Shared Calendar';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USERS'                                     , N'en-US', N'Calendar', null, null, N'Users';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WEEK'                                      , N'en-US', N'Calendar', null, null, N'Week';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_YEAR'                                      , N'en-US', N'Calendar', null, null, N'Year';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_CALL_LIST'                                 , N'en-US', N'Calendar', null, null, N'Calls';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_MEETING_LIST'                              , N'en-US', N'Calendar', null, null, N'Meetings';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_APPOINTMENT'                           , N'en-US', N'Calendar', null, null, N'Create Appointment';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_CALL'                                  , N'en-US', N'Calendar', null, null, N'Create Call';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_MEETING'                               , N'en-US', N'Calendar', null, null, N'Create Meeting';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_TASK_LIST'                                 , N'en-US', N'Calendar', null, null, N'Tasks';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_VIEW_CALENDAR'                             , N'en-US', N'Calendar', null, null, N'Today';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Calendar', null, null, N'Calendar';
-- 03/10/2013 Paul.  Add ALL_DAY_EVENT. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ALL_DAY'                                   , N'en-US', N'Calendar', null, null, N'All Day';

-- 03/20/2013 Paul.  Add REPEAT fields. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPEAT_TAB'                                , N'en-US', N'Calendar', null, null, N'Recurrence';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPEAT_TYPE'                               , N'en-US', N'Calendar', null, null, N'Repeat:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPEAT_INTERVAL'                           , N'en-US', N'Calendar', null, null, N'Interval:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPEAT_END'                                , N'en-US', N'Calendar', null, null, N'End:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPEAT_END_AFTER'                          , N'en-US', N'Calendar', null, null, N'End After:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPEAT_OCCURRENCES'                        , N'en-US', N'Calendar', null, null, N'occurrences';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPEAT_END_BY'                             , N'en-US', N'Calendar', null, null, N'By:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPEAT_DOW'                                , N'en-US', N'Calendar', null, null, N'Days of the Week:';	
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPEAT_UNTIL'                              , N'en-US', N'Calendar', null, null, N'Repeat Until:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPEAT_COUNT'                              , N'en-US', N'Calendar', null, null, N'Repeat Count:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REPEAT_LIMIT_ERROR'                        , N'en-US', N'Calendar', null, null, N'Repeat limit error.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EDIT_ALL_RECURRENCES'                      , N'en-US', N'Calendar', null, null, N'Edit All Recurrences';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REMOVE_ALL_RECURRENCES'                    , N'en-US', N'Calendar', null, null, N'Delete All Recurrences';
-- 06/04/2015 Paul.  Add module abbreviation. 
-- delete from TERMINOLOGY where NAME = 'LBL_MODULE_ABBREVIATION' and MODULE_NAME = 'Calendar';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Calendar', null, null, N'Cdr';

exec dbo.spTERMINOLOGY_InsertOnly N'Calendar'                                      , N'en-US', null, N'moduleList'                        ,  12, N'Calendar';
exec dbo.spTERMINOLOGY_InsertOnly N'Calendar'                                      , N'en-US', null, N'moduleListSingular'                ,  12, N'Calendar';
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

call dbo.spTERMINOLOGY_Calendar_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Calendar_en_us')
/
-- #endif IBM_DB2 */
