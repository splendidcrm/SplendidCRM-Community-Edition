

print 'TERMINOLOGY QueryBuilder en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Reports', null, null, N'Module Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RELATED'                                   , N'en-US', N'Reports', null, null, N'Related:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FILTERS'                                   , N'en-US', N'Reports', null, null, N'Filters:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADD_FILTER_BUTTON_LABEL'                   , N'en-US', N'Reports', null, null, N'Add Filter';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SHOW_QUERY'                                , N'en-US', N'Reports', null, null, N'Show Query:';
GO

exec dbo.spTERMINOLOGY_InsertOnly N'equals'                                        , N'en-US', null, N'ansistring_operator_dom'           ,   1, N'Equals';
exec dbo.spTERMINOLOGY_InsertOnly N'contains'                                      , N'en-US', null, N'ansistring_operator_dom'           ,   2, N'Contains';
exec dbo.spTERMINOLOGY_InsertOnly N'starts_with'                                   , N'en-US', null, N'ansistring_operator_dom'           ,   3, N'Starts With';
exec dbo.spTERMINOLOGY_InsertOnly N'ends_with'                                     , N'en-US', null, N'ansistring_operator_dom'           ,   4, N'Ends With';
exec dbo.spTERMINOLOGY_InsertOnly N'not_equals_str'                                , N'en-US', null, N'ansistring_operator_dom'           ,   5, N'Does Not Equal';
exec dbo.spTERMINOLOGY_InsertOnly N'empty'                                         , N'en-US', null, N'ansistring_operator_dom'           ,   6, N'Is Empty';
exec dbo.spTERMINOLOGY_InsertOnly N'not_empty'                                     , N'en-US', null, N'ansistring_operator_dom'           ,   7, N'Is Not Empty';

exec dbo.spTERMINOLOGY_InsertOnly N'equals'                                        , N'en-US', null, N'bool_operator_dom'                 ,   1, N'Equals';
exec dbo.spTERMINOLOGY_InsertOnly N'empty'                                         , N'en-US', null, N'bool_operator_dom'                 ,   2, N'Is Empty';
exec dbo.spTERMINOLOGY_InsertOnly N'not_empty'                                     , N'en-US', null, N'bool_operator_dom'                 ,   3, N'Is Not Empty';

exec dbo.spTERMINOLOGY_InsertOnly N'on'                                            , N'en-US', null, N'datetime_operator_dom'             ,   1, N'On';
exec dbo.spTERMINOLOGY_InsertOnly N'before'                                        , N'en-US', null, N'datetime_operator_dom'             ,   2, N'Before';
exec dbo.spTERMINOLOGY_InsertOnly N'after'                                         , N'en-US', null, N'datetime_operator_dom'             ,   3, N'After';
exec dbo.spTERMINOLOGY_InsertOnly N'between_dates'                                 , N'en-US', null, N'datetime_operator_dom'             ,   4, N'Is Between';
exec dbo.spTERMINOLOGY_InsertOnly N'not_equals_str'                                , N'en-US', null, N'datetime_operator_dom'             ,   5, N'Does Not Equal';
exec dbo.spTERMINOLOGY_InsertOnly N'empty'                                         , N'en-US', null, N'datetime_operator_dom'             ,   6, N'Is Empty';
exec dbo.spTERMINOLOGY_InsertOnly N'not_empty'                                     , N'en-US', null, N'datetime_operator_dom'             ,   7, N'Is Not Empty';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_yesterday'                                  , N'en-US', null, N'datetime_operator_dom'             ,   8, N'Yesterday';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_today'                                      , N'en-US', null, N'datetime_operator_dom'             ,   9, N'Today';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_tomorrow'                                   , N'en-US', null, N'datetime_operator_dom'             ,  10, N'Tomorrow';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_last_7_days'                                , N'en-US', null, N'datetime_operator_dom'             ,  11, N'Last 7 Days';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_next_7_days'                                , N'en-US', null, N'datetime_operator_dom'             ,  12, N'Next 7 Days';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_last_month'                                 , N'en-US', null, N'datetime_operator_dom'             ,  13, N'Last Month';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_this_month'                                 , N'en-US', null, N'datetime_operator_dom'             ,  14, N'This Month';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_next_month'                                 , N'en-US', null, N'datetime_operator_dom'             ,  15, N'Next Month';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_last_30_days'                               , N'en-US', null, N'datetime_operator_dom'             ,  16, N'Last 30 Days';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_next_30_days'                               , N'en-US', null, N'datetime_operator_dom'             ,  17, N'Next 30 Days';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_last_year'                                  , N'en-US', null, N'datetime_operator_dom'             ,  18, N'Last Year';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_this_year'                                  , N'en-US', null, N'datetime_operator_dom'             ,  19, N'This Year';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_next_year'                                  , N'en-US', null, N'datetime_operator_dom'             ,  20, N'Next Year';
exec dbo.spTERMINOLOGY_InsertOnly N'is_before'                                     , N'en-US', null, N'datetime_operator_dom'             ,  21, N'Is Before';
exec dbo.spTERMINOLOGY_InsertOnly N'is_after'                                      , N'en-US', null, N'datetime_operator_dom'             ,  22, N'Is After';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_minutes_after'                              , N'en-US', null, N'datetime_operator_dom'             ,  23, N'Minutes After';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_hours_after'                                , N'en-US', null, N'datetime_operator_dom'             ,  24, N'Hours After';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_days_after'                                 , N'en-US', null, N'datetime_operator_dom'             ,  25, N'Days After';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_weeks_after'                                , N'en-US', null, N'datetime_operator_dom'             ,  26, N'Weeks After';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_months_after'                               , N'en-US', null, N'datetime_operator_dom'             ,  27, N'Months After';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_years_after'                                , N'en-US', null, N'datetime_operator_dom'             ,  28, N'Years After';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_minutes_before'                             , N'en-US', null, N'datetime_operator_dom'             ,  29, N'Minutes Before';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_hours_before'                               , N'en-US', null, N'datetime_operator_dom'             ,  30, N'Hours Before';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_days_before'                                , N'en-US', null, N'datetime_operator_dom'             ,  31, N'Days Before';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_weeks_before'                               , N'en-US', null, N'datetime_operator_dom'             ,  32, N'Weeks Before';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_months_before'                              , N'en-US', null, N'datetime_operator_dom'             ,  33, N'Months Before';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_years_before'                               , N'en-US', null, N'datetime_operator_dom'             ,  34, N'Years Before';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_days_old'                                   , N'en-US', null, N'datetime_operator_dom'             ,  35, N'Days Old';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_weeks_old'                                  , N'en-US', null, N'datetime_operator_dom'             ,  36, N'Weeks Old';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_months_old'                                 , N'en-US', null, N'datetime_operator_dom'             ,  37, N'Months Old';
exec dbo.spTERMINOLOGY_InsertOnly N'tp_years_old'                                  , N'en-US', null, N'datetime_operator_dom'             ,  38, N'Years Old';

exec dbo.spTERMINOLOGY_InsertOnly N'equals'                                        , N'en-US', null, N'decimal_operator_dom'              ,   1, N'Equals';
exec dbo.spTERMINOLOGY_InsertOnly N'less'                                          , N'en-US', null, N'decimal_operator_dom'              ,   2, N'Less Than';
exec dbo.spTERMINOLOGY_InsertOnly N'greater'                                       , N'en-US', null, N'decimal_operator_dom'              ,   3, N'Greater Than';
exec dbo.spTERMINOLOGY_InsertOnly N'between'                                       , N'en-US', null, N'decimal_operator_dom'              ,   4, N'Is Between';
exec dbo.spTERMINOLOGY_InsertOnly N'not_equals'                                    , N'en-US', null, N'decimal_operator_dom'              ,   5, N'Does Not Equal';
exec dbo.spTERMINOLOGY_InsertOnly N'empty'                                         , N'en-US', null, N'decimal_operator_dom'              ,   6, N'Is Empty';
exec dbo.spTERMINOLOGY_InsertOnly N'not_empty'                                     , N'en-US', null, N'decimal_operator_dom'              ,   7, N'Is Not Empty';

exec dbo.spTERMINOLOGY_InsertOnly N'tabular'                                       , N'en-US', null, N'dom_report_types'                  ,   1, N'Tabular';
exec dbo.spTERMINOLOGY_InsertOnly N'summary'                                       , N'en-US', null, N'dom_report_types'                  ,   2, N'Summary';
exec dbo.spTERMINOLOGY_InsertOnly N'detailed_summary'                              , N'en-US', null, N'dom_report_types'                  ,   3, N'Detailed Summary';
exec dbo.spTERMINOLOGY_InsertOnly N'Freeform'                                      , N'en-US', null, N'dom_report_types'                  ,   4, N'Freeform';

exec dbo.spTERMINOLOGY_InsertOnly N'is'                                            , N'en-US', null, N'enum_operator_dom'                 ,   1, N'Is';
exec dbo.spTERMINOLOGY_InsertOnly N'one_of'                                        , N'en-US', null, N'enum_operator_dom'                 ,   2, N'One Of';
exec dbo.spTERMINOLOGY_InsertOnly N'empty'                                         , N'en-US', null, N'enum_operator_dom'                 ,   3, N'Is Empty';
exec dbo.spTERMINOLOGY_InsertOnly N'not_empty'                                     , N'en-US', null, N'enum_operator_dom'                 ,   4, N'Is Not Empty';

exec dbo.spTERMINOLOGY_InsertOnly N'equals'                                        , N'en-US', null, N'float_operator_dom'                ,   1, N'Equals';
exec dbo.spTERMINOLOGY_InsertOnly N'less'                                          , N'en-US', null, N'float_operator_dom'                ,   2, N'Less Than';
exec dbo.spTERMINOLOGY_InsertOnly N'greater'                                       , N'en-US', null, N'float_operator_dom'                ,   3, N'Greater Than';
exec dbo.spTERMINOLOGY_InsertOnly N'between'                                       , N'en-US', null, N'float_operator_dom'                ,   4, N'Is Between';
exec dbo.spTERMINOLOGY_InsertOnly N'not_equals'                                    , N'en-US', null, N'float_operator_dom'                ,   5, N'Does Not Equal';
exec dbo.spTERMINOLOGY_InsertOnly N'empty'                                         , N'en-US', null, N'float_operator_dom'                ,   6, N'Is Empty';
exec dbo.spTERMINOLOGY_InsertOnly N'not_empty'                                     , N'en-US', null, N'float_operator_dom'                ,   7, N'Is Not Empty';

exec dbo.spTERMINOLOGY_InsertOnly N'is'                                            , N'en-US', null, N'guid_operator_dom'                 ,   1, N'Is';
exec dbo.spTERMINOLOGY_InsertOnly N'one_of'                                        , N'en-US', null, N'guid_operator_dom'                 ,   2, N'One Of';
exec dbo.spTERMINOLOGY_InsertOnly N'equals'                                        , N'en-US', null, N'guid_operator_dom'                 ,   3, N'Equals';
exec dbo.spTERMINOLOGY_InsertOnly N'contains'                                      , N'en-US', null, N'guid_operator_dom'                 ,   4, N'Contains';
exec dbo.spTERMINOLOGY_InsertOnly N'starts_with'                                   , N'en-US', null, N'guid_operator_dom'                 ,   5, N'Starts With';
exec dbo.spTERMINOLOGY_InsertOnly N'ends_with'                                     , N'en-US', null, N'guid_operator_dom'                 ,   6, N'Ends With';
exec dbo.spTERMINOLOGY_InsertOnly N'not_equals_str'                                , N'en-US', null, N'guid_operator_dom'                 ,   7, N'Does Not Equal';
exec dbo.spTERMINOLOGY_InsertOnly N'empty'                                         , N'en-US', null, N'guid_operator_dom'                 ,   8, N'Is Empty';
exec dbo.spTERMINOLOGY_InsertOnly N'not_empty'                                     , N'en-US', null, N'guid_operator_dom'                 ,   9, N'Is Not Empty';

exec dbo.spTERMINOLOGY_InsertOnly N'equals'                                        , N'en-US', null, N'int32_operator_dom'                ,   1, N'Equals';
exec dbo.spTERMINOLOGY_InsertOnly N'less'                                          , N'en-US', null, N'int32_operator_dom'                ,   2, N'Less Than';
exec dbo.spTERMINOLOGY_InsertOnly N'greater'                                       , N'en-US', null, N'int32_operator_dom'                ,   3, N'Greater Than';
exec dbo.spTERMINOLOGY_InsertOnly N'between'                                       , N'en-US', null, N'int32_operator_dom'                ,   4, N'Is Between';
exec dbo.spTERMINOLOGY_InsertOnly N'not_equals'                                    , N'en-US', null, N'int32_operator_dom'                ,   5, N'Does Not Equal';
exec dbo.spTERMINOLOGY_InsertOnly N'empty'                                         , N'en-US', null, N'int32_operator_dom'                ,   6, N'Is Empty';
exec dbo.spTERMINOLOGY_InsertOnly N'not_empty'                                     , N'en-US', null, N'int32_operator_dom'                ,   7, N'Is Not Empty';

exec dbo.spTERMINOLOGY_InsertOnly N''                                              , N'en-US', null, N'published_reports_dom'             ,   1, N'All Published Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Contacts'                                      , N'en-US', null, N'published_reports_dom'             ,   2, N'Published Contact Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Accounts'                                      , N'en-US', null, N'published_reports_dom'             ,   3, N'Published Account Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Opportunities'                                 , N'en-US', null, N'published_reports_dom'             ,   4, N'Published Opportunity Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Cases'                                         , N'en-US', null, N'published_reports_dom'             ,   5, N'Published Case Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Notes'                                         , N'en-US', null, N'published_reports_dom'             ,   6, N'Published Note Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Calls'                                         , N'en-US', null, N'published_reports_dom'             ,   7, N'Published Call Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Emails'                                        , N'en-US', null, N'published_reports_dom'             ,   8, N'Published Email Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Meetings'                                      , N'en-US', null, N'published_reports_dom'             ,   9, N'Published Meeting Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Tasks'                                         , N'en-US', null, N'published_reports_dom'             ,  10, N'Published Task Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Leads'                                         , N'en-US', null, N'published_reports_dom'             ,  11, N'Published Lead Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Bugs'                                          , N'en-US', null, N'published_reports_dom'             ,  12, N'Published Bug Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Quotes'                                        , N'en-US', null, N'published_reports_dom'             ,  13, N'Published Quote Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Contracts'                                     , N'en-US', null, N'published_reports_dom'             ,  15, N'Published Contract Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Orders'                                        , N'en-US', null, N'published_reports_dom'             ,  16, N'Published Order Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Invoices'                                      , N'en-US', null, N'published_reports_dom'             ,  17, N'Published Invoice Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'ProjectTask'                                   , N'en-US', null, N'published_reports_dom'             ,  18, N'Published Project Task Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Prospects'                                     , N'en-US', null, N'published_reports_dom'             ,  19, N'Published Target Reports';

exec dbo.spTERMINOLOGY_InsertOnly N''                                              , N'en-US', null, N'saved_reports_dom'                 ,   1, N'My Saved Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Contacts'                                      , N'en-US', null, N'saved_reports_dom'                 ,   2, N'My Contact Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Accounts'                                      , N'en-US', null, N'saved_reports_dom'                 ,   3, N'My Account Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Opportunities'                                 , N'en-US', null, N'saved_reports_dom'                 ,   4, N'My Opportunity Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Cases'                                         , N'en-US', null, N'saved_reports_dom'                 ,   5, N'My Case Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Notes'                                         , N'en-US', null, N'saved_reports_dom'                 ,   6, N'My Note Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Calls'                                         , N'en-US', null, N'saved_reports_dom'                 ,   7, N'My Call Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Emails'                                        , N'en-US', null, N'saved_reports_dom'                 ,   8, N'My Email Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Meetings'                                      , N'en-US', null, N'saved_reports_dom'                 ,   9, N'My Meeting Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Tasks'                                         , N'en-US', null, N'saved_reports_dom'                 ,  10, N'My Task Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Leads'                                         , N'en-US', null, N'saved_reports_dom'                 ,  11, N'My Lead Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Bugs'                                          , N'en-US', null, N'saved_reports_dom'                 ,  12, N'My Bug Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Quotes'                                        , N'en-US', null, N'saved_reports_dom'                 ,  13, N'My Quote Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Contracts'                                     , N'en-US', null, N'saved_reports_dom'                 ,  15, N'My Contract Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Orders'                                        , N'en-US', null, N'saved_reports_dom'                 ,  16, N'My Order Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Invoices'                                      , N'en-US', null, N'saved_reports_dom'                 ,  17, N'My Invoice Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'ProjectTask'                                   , N'en-US', null, N'saved_reports_dom'                 ,  18, N'My Project Task Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'Prospects'                                     , N'en-US', null, N'saved_reports_dom'                 ,  19, N'My Target Reports';

exec dbo.spTERMINOLOGY_InsertOnly N'equals'                                        , N'en-US', null, N'string_operator_dom'               ,   1, N'Equals';
exec dbo.spTERMINOLOGY_InsertOnly N'contains'                                      , N'en-US', null, N'string_operator_dom'               ,   2, N'Contains';
exec dbo.spTERMINOLOGY_InsertOnly N'starts_with'                                   , N'en-US', null, N'string_operator_dom'               ,   3, N'Starts With';
exec dbo.spTERMINOLOGY_InsertOnly N'ends_with'                                     , N'en-US', null, N'string_operator_dom'               ,   4, N'Ends With';
exec dbo.spTERMINOLOGY_InsertOnly N'not_equals_str'                                , N'en-US', null, N'string_operator_dom'               ,   5, N'Does Not Equal';
exec dbo.spTERMINOLOGY_InsertOnly N'empty'                                         , N'en-US', null, N'string_operator_dom'               ,   6, N'Is Empty';
exec dbo.spTERMINOLOGY_InsertOnly N'not_empty'                                     , N'en-US', null, N'string_operator_dom'               ,   7, N'Is Not Empty';
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

call dbo.spTERMINOLOGY_QueryBuilder_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_QueryBuilder_en_us')
/
-- #endif IBM_DB2 */
