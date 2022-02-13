

print 'DETAILVIEWS_FIELDS Preview';
--delete from DETAILVIEWS_FIELDS where DETAIL_NAME like '%.Preview'
--GO

set nocount on;
GO

-- delete from DETAILVIEWS where NAME = 'Accounts.DetailView.Preview'; delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Accounts.DetailView.Preview';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Accounts.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Accounts.DetailView.Preview';
	exec dbo.spDETAILVIEWS_InsertOnly          'Accounts.DetailView.Preview', 'Accounts', 'vwACCOUNTS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Preview',  0, 'Accounts.LBL_ACCOUNT_NAME'       , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Preview',  1, 'Accounts.LBL_BILLING_ADDRESS'    , 'BILLING_ADDRESS_HTML'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Preview',  2, 'Accounts.LBL_PHONE'              , 'PHONE_OFFICE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Preview',  3, 'Accounts.LBL_FAX'                , 'PHONE_FAX'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Accounts.DetailView.Preview',  4, 'Accounts.LBL_WEBSITE'            , 'WEBSITE'                          , '{0}'        , 'WEBSITE'             , '{0}'                        , '_blank', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Accounts.DetailView.Preview',  5, 'Accounts.LBL_EMAIL'              , 'EMAIL1'                           , '{0}'        , 'EMAIL1'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Accounts.DetailView.Preview',  6, 'Accounts.LBL_OTHER_EMAIL_ADDRESS', 'EMAIL2'                           , '{0}'        , 'EMAIL2'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Accounts.DetailView.Preview',  7, 'Accounts.LBL_TYPE'               , 'ACCOUNT_TYPE'                     , '{0}'        , 'account_type_dom'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Accounts.DetailView.Preview',  8, 'Accounts.LBL_INDUSTRY'           , 'INDUSTRY'                         , '{0}'        , 'industry_dom'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Preview',  9, 'Accounts.LBL_RATING'             , 'RATING'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Preview', 10, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.DetailView.Preview', 11, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Accounts.DetailView.Preview', 12, 'TextBox', 'Accounts.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Bugs.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Bugs.DetailView.Preview';
	exec dbo.spDETAILVIEWS_InsertOnly          'Bugs.DetailView.Preview', 'Bugs', 'vwBUGS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.DetailView.Preview'   ,  0, 'Bugs.LBL_BUG_NUMBER'              , 'BUG_NUMBER'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.DetailView.Preview'   ,  1, 'Bugs.LBL_SUBJECT'                 , 'NAME'                             , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.DetailView.Preview'   ,  2, 'Bugs.LBL_PRIORITY'                , 'PRIORITY'                         , '{0}'        , 'bug_priority_dom'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.DetailView.Preview'   ,  3, 'Bugs.LBL_STATUS'                  , 'STATUS'                           , '{0}'        , 'bug_status_dom'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.DetailView.Preview'   ,  4, 'Bugs.LBL_TYPE'                    , 'TYPE'                             , '{0}'        , 'bug_type_dom'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.DetailView.Preview'   ,  5, 'Bugs.LBL_SOURCE'                  , 'SOURCE'                           , '{0}'        , 'source_dom'          , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.DetailView.Preview'   ,  6, 'Bugs.LBL_PRODUCT_CATEGORY'        , 'PRODUCT_CATEGORY'                 , '{0}'        , 'product_category_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Bugs.DetailView.Preview'   ,  7, 'Bugs.LBL_RESOLUTION'              , 'RESOLUTION'                       , '{0}'        , 'bug_resolution_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.DetailView.Preview'   ,  8, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Bugs.DetailView.Preview'   ,  9, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Bugs.DetailView.Preview'   , 10, 'TextBox', 'Bugs.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Calls.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Calls.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Calls.DetailView.Preview', 'Calls', 'vwCALLS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView.Preview'  ,  0, 'Calls.LBL_SUBJECT'                , 'NAME'                                                                         , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView.Preview'  ,  1, 'Calls.LBL_DATE_TIME'              , 'DATE_START'                                                                   , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView.Preview'  ,  2, 'Calls.LBL_DURATION'               , 'DURATION_HOURS Calls.LBL_HOURS_ABBREV DURATION_MINUTES Calls.LBL_MINSS_ABBREV', '{0} {1} {2} {3}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Calls.DetailView.Preview'  ,  3, 'Calls.LBL_STATUS'                 , 'DIRECTION STATUS'                                                             , '{0} {1}'        , 'call_direction_dom call_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Calls.DetailView.Preview'  ,  4, 'PARENT_TYPE'                      , 'PARENT_NAME'                                                                  , '{0}'            , 'PARENT_ID', '~/Parents/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView.Preview'  ,  5, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                                                                    , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Calls.DetailView.Preview'  ,  6, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                                                             , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Calls.DetailView.Preview'  ,  7, 'TextBox', 'Calls.LBL_DESCRIPTION' , 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Cases.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Cases.DetailView.Preview';
	exec dbo.spDETAILVIEWS_InsertOnly          'Cases.DetailView.Preview', 'Cases', 'vwCASES_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.DetailView.Preview'  ,  0, 'Cases.LBL_CASE_NUMBER'            , 'CASE_NUMBER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.DetailView.Preview'  ,  1, 'Cases.LBL_SUBJECT'                , 'NAME'                             , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Cases.DetailView.Preview'  ,  2, 'Cases.LBL_ACCOUNT_NAME'           , 'ACCOUNT_NAME'                     , '{0}'        , 'ACCOUNT_ID'       , '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Cases.DetailView.Preview'  ,  3, 'Cases.LBL_PRIORITY'               , 'PRIORITY'                         , '{0}'        , 'case_priority_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Cases.DetailView.Preview'  ,  4, 'Cases.LBL_STATUS'                 , 'STATUS'                           , '{0}'        , 'case_status_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.DetailView.Preview'  ,  5, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Cases.DetailView.Preview'  ,  6, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Cases.DetailView.Preview'  ,  7, 'TextBox', 'Cases.LBL_DESCRIPTION' , 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Contacts.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Contacts.DetailView.Preview';
	exec dbo.spDETAILVIEWS_InsertOnly          'Contacts.DetailView.Preview', 'Contacts', 'vwCONTACTS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Preview',  0, 'Contacts.LBL_NAME'               , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Preview',  1, 'Contacts.LBL_TITLE'              , 'TITLE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Contacts.DetailView.Preview',  2, 'Contacts.LBL_ACCOUNT_NAME'       , 'ACCOUNT_NAME'                     , '{0}'        , 'ACCOUNT_ID'       , '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Preview',  3, 'Contacts.LBL_PRIMARY_ADDRESS'    , 'PRIMARY_ADDRESS_HTML'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Contacts.DetailView.Preview',  4, 'Contacts.LBL_EMAIL_ADDRESS'      , 'EMAIL1'                           , '{0}'        , 'EMAIL1'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Preview',  5, 'Contacts.LBL_OFFICE_PHONE'       , 'PHONE_WORK'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Preview',  6, 'Contacts.LBL_MOBILE_PHONE'       , 'PHONE_MOBILE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Preview',  7, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.DetailView.Preview',  8, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Contacts.DetailView.Preview',  9, 'TextBox', 'Contacts.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Documents.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Documents.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Documents.DetailView.Preview', 'Documents', 'vwDOCUMENTS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.DetailView.Preview',  0, 'Documents.LBL_DOC_NAME'         , 'DOCUMENT_NAME'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Documents.DetailView.Preview',  1, 'Documents.LBL_TEMPLATE_TYPE'    , 'TEMPLATE_TYPE'                    , '{0}'        , 'document_template_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Documents.DetailView.Preview',  2, 'Documents.LBL_CATEGORY_VALUE'   , 'CATEGORY_ID'                      , '{0}'        , 'document_category_dom'   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Documents.DetailView.Preview',  3, 'Documents.LBL_DOC_STATUS'       , 'STATUS_ID'                        , '{0}'        , 'document_status_dom'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.DetailView.Preview',  4, 'Documents.LBL_DOC_ACTIVE_DATE'  , 'ACTIVE_DATE'                      , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.DetailView.Preview',  5, 'Documents.LBL_DOC_EXP_DATE'     , 'EXP_DATE'                         , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Documents.DetailView.Preview',  6, 'Documents.LBL_DOWNNLOAD_FILE'   , 'FILENAME'                        , '{0}'        , 'DOCUMENT_REVISION_ID'    , '~/Documents/Document.aspx?ID={0}', '_blank', 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.DetailView.Preview',  7, 'Teams.LBL_TEAM'                 , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Documents.DetailView.Preview',  8, '.LBL_ASSIGNED_TO'               , 'ASSIGNED_TO_NAME'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Documents.DetailView.Preview',  9, 'TextBox', 'Documents.LBL_DOC_DESCRIPTION', 'DESCRIPTION', '10,90', null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Emails.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Emails.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Emails.DetailView.Preview', 'Emails', 'vwEMAILS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Preview'  ,  0, 'Emails.LBL_SUBJECT'              , 'NAME'                             , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Preview'  ,  1, 'Emails.LBL_DATE_SENT'            , 'DATE_START'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Preview'  ,  2, 'Emails.LBL_FROM'                 , 'FROM_NAME FROM_ADDR'              , '{0} &lt;{1}&gt;', 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Preview'  ,  3, 'Emails.LBL_TO'                   , 'TO_ADDRS'                         , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Emails.DetailView.Preview'  ,  4, 'PARENT_TYPE'                     , 'PARENT_NAME'                      , '{0}'        , 'PARENT_ID', '~/Parents/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Preview'  ,  5, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Emails.DetailView.Preview'  ,  6, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Emails.DetailView.Preview'  ,  7, 'TextBox', 'Emails.LBL_BODY', 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Leads.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Leads.DetailView.Preview';
	exec dbo.spDETAILVIEWS_InsertOnly          'Leads.DetailView.Preview', 'Leads', 'vwLEADS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Preview'   ,  0, 'Leads.LBL_NAME'                   , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Preview'   ,  1, 'Leads.LBL_TITLE'                  , 'TITLE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Leads.DetailView.Preview'   ,  2, 'Leads.LBL_ACCOUNT_NAME'           , 'ACCOUNT_NAME'                     , '{0}'        , 'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Preview'   ,  3, 'Leads.LBL_PRIMARY_ADDRESS'        , 'PRIMARY_ADDRESS_HTML'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Leads.DetailView.Preview'   ,  4, 'Leads.LBL_EMAIL_ADDRESS'          , 'EMAIL1'                           , '{0}'        , 'EMAIL1', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Preview'   ,  5, 'Leads.LBL_OFFICE_PHONE'           , 'PHONE_WORK'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Preview'   ,  6, 'Leads.LBL_MOBILE_PHONE'           , 'PHONE_MOBILE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Leads.DetailView.Preview'   ,  7, 'Leads.LBL_LEAD_SOURCE'            , 'LEAD_SOURCE'                      , '{0}'        , 'lead_source_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Leads.DetailView.Preview'   ,  8, 'Leads.LBL_STATUS'                 , 'STATUS'                           , '{0}'        , 'lead_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Preview'   ,  9, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.DetailView.Preview'   , 10, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Leads.DetailView.Preview'   , 11, 'TextBox', 'Leads.LBL_DESCRIPTION' , 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Meetings.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Meetings.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Meetings.DetailView.Preview', 'Meetings', 'vwMEETINGS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView.Preview',  0, 'Meetings.LBL_SUBJECT'             , 'NAME'                                                                         , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView.Preview',  1, 'Meetings.LBL_DATE_TIME'           , 'DATE_START'                                                                   , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView.Preview',  2, 'Meetings.LBL_DURATION'            , 'DURATION_HOURS Calls.LBL_HOURS_ABBREV DURATION_MINUTES Calls.LBL_MINSS_ABBREV', '{0} {1} {2} {3}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Meetings.DetailView.Preview',  3, 'Meetings.LBL_STATUS'              , 'STATUS'                                                                       , '{0}'            , 'meeting_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView.Preview',  4, 'Meetings.LBL_LOCATION'            , 'LOCATION'                                                                     , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Meetings.DetailView.Preview',  5, 'PARENT_TYPE'                      , 'PARENT_NAME'                                                                  , '{0}'            , 'PARENT_ID', '~/Parents/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView.Preview',  6, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                                                                    , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Meetings.DetailView.Preview',  7, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                                                             , '{0}'            , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Meetings.DetailView.Preview',  8, 'TextBox', 'Meetings.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Notes.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Notes.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Notes.DetailView.Preview', 'Notes', 'vwNOTES_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.DetailView.Preview'   ,  0, 'Notes.LBL_SUBJECT'               , 'NAME'                             , '{0}'        , 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Notes.DetailView.Preview'   ,  1, 'PARENT_TYPE'                     , 'PARENT_NAME'                      , '{0}'        , 'PARENT_ID'         , '~/Parents/view.aspx?ID={0}'    , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Notes.DetailView.Preview'   ,  2, 'Notes.LBL_CONTACT_NAME'          , 'CONTACT_NAME'                     , '{0}'        , 'CONTACT_ID'        , '~/Contacts/view.aspx?ID={0}'   , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Notes.DetailView.Preview'   ,  3, 'Notes.LBL_FILENAME'              , 'FILENAME'                         , '{0}'        , 'NOTE_ATTACHMENT_ID', '~/Notes/Attachment.aspx?ID={0}', null, 3;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.DetailView.Preview'   ,  4, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Notes.DetailView.Preview'   ,  5, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Notes.DetailView.Preview'   ,  6, 'TextBox', 'Notes.LBL_NOTE', 'DESCRIPTION', '30,90', null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Opportunities.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Opportunities.DetailView.Preview';
	exec dbo.spDETAILVIEWS_InsertOnly          'Opportunities.DetailView.Preview' , 'Opportunities' , 'vwOPPORTUNITIES_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Preview',  0, 'Opportunities.LBL_OPPORTUNITY_NAME', 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Opportunities.DetailView.Preview',  1, 'Opportunities.LBL_ACCOUNT_NAME'    , 'ACCOUNT_NAME'                     , '{0}'        , 'ACCOUNT_ID'          , '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Preview',  2, 'Opportunities.LBL_AMOUNT'          , 'AMOUNT_USDOLLAR'                  , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Opportunities.DetailView.Preview',  3, 'Opportunities.LBL_TYPE'            , 'OPPORTUNITY_TYPE'                 , '{0}'        , 'opportunity_type_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Preview',  4, 'Opportunities.LBL_NEXT_STEP'       , 'NEXT_STEP'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Opportunities.DetailView.Preview',  5, 'Opportunities.LBL_LEAD_SOURCE'     , 'LEAD_SOURCE'                      , '{0}'        , 'lead_source_dom'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Opportunities.DetailView.Preview',  6, 'Opportunities.LBL_SALES_STAGE'     , 'SALES_STAGE'                      , '{0}'        , 'sales_stage_dom'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Preview',  7, 'Opportunities.LBL_PROBABILITY'     , 'PROBABILITY'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Preview',  8, 'Opportunities.LBL_DATE_CLOSED'     , 'DATE_CLOSED'                      , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Preview',  9, 'Teams.LBL_TEAM'                    , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Opportunities.DetailView.Preview', 10, '.LBL_ASSIGNED_TO'                  , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Opportunities.DetailView.Preview', 11, 'TextBox', 'Opportunities.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Project.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Project.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Project.DetailView.Preview', 'Project', 'vwPROJECTS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView.Preview',  0, 'Project.LBL_NAME'                    , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Project.DetailView.Preview',  1, 'ProjectTask.LBL_STATUS'              , 'STATUS'                           , '{0}'        , 'project_status_dom'       , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Project.DetailView.Preview',  2, 'ProjectTask.LBL_PRIORITY'            , 'PRIORITY'                         , '{0}'        , 'projects_priority_options', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView.Preview',  3, 'ProjectTask.LBL_ESTIMATED_START_DATE', 'ESTIMATED_START_DATE'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView.Preview',  4, 'ProjectTask.LBL_ESTIMATED_END_DATE'  , 'ESTIMATED_END_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView.Preview',  5, '.LBL_LAST_ACTIVITY_DATE'             , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView.Preview',  6, 'Teams.LBL_TEAM'                      , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Project.DetailView.Preview',  7, '.LBL_ASSIGNED_TO'                    , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Project.DetailView.Preview',  8, 'TextBox', 'Project.LBL_DESCRIPTION'  , 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'ProjectTask.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS ProjectTask.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'ProjectTask.DetailView.Preview', 'ProjectTask', 'vwPROJECT_TASKS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Preview',  0, 'Project.LBL_NAME'                , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Preview',  1, 'ProjectTask.LBL_DATE_START'      , 'DATE_START'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Preview',  2, 'ProjectTask.LBL_DATE_DUE'        , 'DATE_DUE'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'ProjectTask.DetailView.Preview',  3, 'ProjectTask.LBL_STATUS'          , 'STATUS'                           , '{0}'        , 'project_task_status_options'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'ProjectTask.DetailView.Preview',  4, 'ProjectTask.LBL_PRIORITY'        , 'PRIORITY'                         , '{0}'        , 'project_task_priority_options'   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Preview',  5, 'ProjectTask.LBL_PERCENT_COMPLETE', 'PERCENT_COMPLETE'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'ProjectTask.DetailView.Preview',  6, 'ProjectTask.LBL_UTILIZATION'     , 'UTILIZATION'                      , '{0}'        , 'project_task_utilization_options', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Preview',  7, 'ProjectTask.LBL_ESTIMATED_EFFORT', 'ESTIMATED_EFFORT'                 , '{0:f1}'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Preview',  8, 'ProjectTask.LBL_ACTUAL_EFFORT'   , 'ACTUAL_EFFORT'                    , '{0:f1}'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Preview',  9, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'ProjectTask.DetailView.Preview', 10, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'ProjectTask.DetailView.Preview', 11, 'TextBox', 'ProjectTask.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Prospects.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Prospects.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Prospects.DetailView.Preview', 'Prospects', 'vwPROSPECTS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Preview',  0, 'Prospects.LBL_NAME'               , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Preview',  1, 'Prospects.LBL_TITLE'              , 'TITLE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Preview',  2, 'Prospects.LBL_PRIMARY_ADDRESS'    , 'PRIMARY_ADDRESS_HTML'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Prospects.DetailView.Preview',  3, 'Prospects.LBL_EMAIL_ADDRESS'      , 'EMAIL1'                           , '{0}'        , 'EMAIL1', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Preview',  4, 'Prospects.LBL_OFFICE_PHONE'       , 'PHONE_WORK'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Preview',  5, 'Prospects.LBL_MOBILE_PHONE'       , 'PHONE_MOBILE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Preview',  6, 'Prospects.LBL_DEPARTMENT'         , 'DEPARTMENT'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Preview',  7, '.LBL_LAST_ACTIVITY_DATE'          , 'LAST_ACTIVITY_DATE'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Preview',  8, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.DetailView.Preview',  9, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Prospects.DetailView.Preview', 10, 'TextBox', 'Prospects.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Tasks.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Tasks.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Tasks.DetailView.Preview', 'Tasks', 'vwTASKS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.DetailView.Preview'   ,  0, 'Tasks.LBL_SUBJECT'               , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.DetailView.Preview'   ,  1, 'Tasks.LBL_START_DATE_AND_TIME'   , 'DATE_START'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.DetailView.Preview'   ,  2, 'Tasks.LBL_DUE_DATE_AND_TIME'     , 'DATE_DUE'                         , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Tasks.DetailView.Preview'   ,  3, 'PARENT_TYPE'                     , 'PARENT_NAME'                      , '{0}'        , 'PARENT_ID'        , '~/Parents/view.aspx?ID={0}' , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Tasks.DetailView.Preview'   ,  4, 'Tasks.LBL_STATUS'                , 'STATUS'                           , '{0}'        , 'task_status_dom'  , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Tasks.DetailView.Preview'   ,  5, 'Tasks.LBL_PRIORITY'              , 'PRIORITY'                         , '{0}'        , 'task_priority_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.DetailView.Preview'   ,  6, 'Teams.LBL_TEAM'                  , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Tasks.DetailView.Preview'   ,  7, '.LBL_ASSIGNED_TO'                , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Tasks.DetailView.Preview'   ,  8, 'TextBox', 'Tasks.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'SmsMessages.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS SmsMessages.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'SmsMessages.DetailView.Preview', 'SmsMessages', 'vwSMS_MESSAGES_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.DetailView.Preview',  0, 'SmsMessages.LBL_NAME'                , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.DetailView.Preview',  1, 'SmsMessages.LBL_DATE_START'          , 'DATE_START'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.DetailView.Preview',  2, 'SmsMessages.LBL_FROM_NUMBER'         , 'FROM_NUMBER'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.DetailView.Preview',  3, 'SmsMessages.LBL_TO_NUMBER'           , 'TO_NUMBER'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'SmsMessages.DetailView.Preview',  4, 'SmsMessages.LBL_STATUS'              , 'STATUS'                           , '{0}'        , 'dom_sms_status', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'SmsMessages.DetailView.Preview',  5, 'PARENT_TYPE'                         , 'PARENT_NAME'                      , '{0}'        , 'PARENT_ID', '~/Parents/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.DetailView.Preview',  6, 'Teams.LBL_TEAM'                      , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'SmsMessages.DetailView.Preview',  7, '.LBL_ASSIGNED_TO'                    , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'TwitterMessages.DetailView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS TwitterMessages.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'TwitterMessages.DetailView.Preview', 'TwitterMessages', 'vwTWITTER_MESSAGES_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'TwitterMessages.DetailView.Preview',  0, 'TwitterMessages.LBL_NAME'               , 'DESCRIPTION'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'TwitterMessages.DetailView.Preview',  1, 'TwitterMessages.LBL_DATE_START'         , 'DATE_START'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'TwitterMessages.DetailView.Preview',  2, 'TwitterMessages.LBL_TWITTER_SCREEN_NAME', 'TWITTER_SCREEN_NAME'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'TwitterMessages.DetailView.Preview',  3, 'PARENT_TYPE'                            , 'PARENT_NAME'                           , '{0}'        , 'PARENT_ID', '~/Parents/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'TwitterMessages.DetailView.Preview',  4, 'Teams.LBL_TEAM'                         , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'TwitterMessages.DetailView.Preview',  5, '.LBL_ASSIGNED_TO'                       , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
end -- if;
GO

-- 06/29/2018 Paul.  Allow preview of archive record. 
-- delete from DETAILVIEWS where NAME = 'Accounts.ArchiveView.Preview'; delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Accounts.ArchiveView.Preview';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Accounts.ArchiveView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Accounts.ArchiveView.Preview';
	exec dbo.spDETAILVIEWS_InsertOnly          'Accounts.ArchiveView.Preview', 'Accounts', 'vwACCOUNTS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView.Preview',  0, 'Accounts.LBL_ACCOUNT_NAME'          , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView.Preview',  1, 'Accounts.LBL_BILLING_ADDRESS_STREET', 'BILLING_ADDRESS_STREET'           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView.Preview',  2, 'Accounts.LBL_BILLING_ADDRESS_CITY'  , 'BILLING_ADDRESS_CITY'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView.Preview',  3, 'Accounts.LBL_BILLING_ADDRESS_STATE' , 'BILLING_ADDRESS_STATE'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView.Preview',  4, 'Accounts.LBL_PHONE'                 , 'PHONE_OFFICE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView.Preview',  5, 'Accounts.LBL_FAX'                   , 'PHONE_FAX'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Accounts.ArchiveView.Preview',  6, 'Accounts.LBL_WEBSITE'               , 'WEBSITE'                          , '{0}'        , 'WEBSITE'             , '{0}'                        , '_blank', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Accounts.ArchiveView.Preview',  7, 'Accounts.LBL_EMAIL'                 , 'EMAIL1'                           , '{0}'        , 'EMAIL1'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Accounts.ArchiveView.Preview',  8, 'Accounts.LBL_OTHER_EMAIL_ADDRESS'   , 'EMAIL2'                           , '{0}'        , 'EMAIL2'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Accounts.ArchiveView.Preview',  9, 'Accounts.LBL_TYPE'                  , 'ACCOUNT_TYPE'                     , '{0}'        , 'account_type_dom'    , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Accounts.ArchiveView.Preview', 10, 'Accounts.LBL_INDUSTRY'              , 'INDUSTRY'                         , '{0}'        , 'industry_dom'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView.Preview', 11, 'Accounts.LBL_RATING'                , 'RATING'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView.Preview', 12, 'Teams.LBL_TEAM'                     , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Accounts.ArchiveView.Preview', 13, '.LBL_ASSIGNED_TO'                   , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Accounts.ArchiveView.Preview', 14, 'TextBox', 'Accounts.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Contacts.ArchiveView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Contacts.ArchiveView.Preview';
	exec dbo.spDETAILVIEWS_InsertOnly          'Contacts.ArchiveView.Preview', 'Contacts', 'vwCONTACTS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView.Preview',  0, 'Contacts.LBL_NAME'                  , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView.Preview',  1, 'Contacts.LBL_TITLE'                 , 'TITLE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Contacts.ArchiveView.Preview',  2, 'Contacts.LBL_ACCOUNT_NAME'          , 'ACCOUNT_NAME'                     , '{0}'        , 'ACCOUNT_ID'       , '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView.Preview',  3, 'Contacts.LBL_PRIMARY_ADDRESS_STREET', 'PRIMARY_ADDRESS_STREET'           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView.Preview',  4, 'Contacts.LBL_PRIMARY_ADDRESS_CITY'  , 'PRIMARY_ADDRESS_CITY'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView.Preview',  5, 'Contacts.LBL_PRIMARY_ADDRESS_STATE' , 'PRIMARY_ADDRESS_STATE'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Contacts.ArchiveView.Preview',  6, 'Contacts.LBL_EMAIL_ADDRESS'         , 'EMAIL1'                           , '{0}'        , 'EMAIL1'              , 'mailto:{0}'                 , null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView.Preview',  7, 'Contacts.LBL_OFFICE_PHONE'          , 'PHONE_WORK'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView.Preview',  8, 'Contacts.LBL_MOBILE_PHONE'          , 'PHONE_MOBILE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView.Preview',  9, 'Teams.LBL_TEAM'                     , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contacts.ArchiveView.Preview', 10, '.LBL_ASSIGNED_TO'                   , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Contacts.ArchiveView.Preview', 11, 'TextBox', 'Contacts.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Leads.ArchiveView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Leads.ArchiveView.Preview';
	exec dbo.spDETAILVIEWS_InsertOnly          'Leads.ArchiveView.Preview', 'Leads', 'vwLEADS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView.Preview'   ,  0, 'Leads.LBL_NAME'                   , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView.Preview'   ,  1, 'Leads.LBL_TITLE'                  , 'TITLE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Leads.ArchiveView.Preview'   ,  2, 'Leads.LBL_ACCOUNT_NAME'           , 'ACCOUNT_NAME'                     , '{0}'        , 'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView.Preview'   ,  3, 'Leads.LBL_PRIMARY_ADDRESS_STREET' , 'PRIMARY_ADDRESS_STREET'           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView.Preview'   ,  4, 'Leads.LBL_PRIMARY_ADDRESS_CITY'   , 'PRIMARY_ADDRESS_CITY'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView.Preview'   ,  5, 'Leads.LBL_PRIMARY_ADDRESS_STATE'  , 'PRIMARY_ADDRESS_STATE'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Leads.ArchiveView.Preview'   ,  6, 'Leads.LBL_EMAIL_ADDRESS'          , 'EMAIL1'                           , '{0}'        , 'EMAIL1', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView.Preview'   ,  7, 'Leads.LBL_OFFICE_PHONE'           , 'PHONE_WORK'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView.Preview'   ,  8, 'Leads.LBL_MOBILE_PHONE'           , 'PHONE_MOBILE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Leads.ArchiveView.Preview'   ,  9, 'Leads.LBL_LEAD_SOURCE'            , 'LEAD_SOURCE'                      , '{0}'        , 'lead_source_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Leads.ArchiveView.Preview'   , 10, 'Leads.LBL_STATUS'                 , 'STATUS'                           , '{0}'        , 'lead_status_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView.Preview'   , 11, 'Teams.LBL_TEAM'                   , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Leads.ArchiveView.Preview'   , 12, '.LBL_ASSIGNED_TO'                 , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Leads.ArchiveView.Preview'   , 13, 'TextBox', 'Leads.LBL_DESCRIPTION' , 'DESCRIPTION', null, null, null, null, null, null, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Prospects.ArchiveView.Preview' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Prospects.DetailView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Prospects.ArchiveView.Preview', 'Prospects', 'vwPROSPECTS_Edit', '35%', '65%', 1;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView.Preview',  0, 'Prospects.LBL_NAME'                  , 'NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView.Preview',  1, 'Prospects.LBL_TITLE'                 , 'TITLE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView.Preview',  2, 'Prospects.LBL_PRIMARY_ADDRESS_STREET', 'PRIMARY_ADDRESS_STREET'           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView.Preview',  3, 'Prospects.LBL_PRIMARY_ADDRESS_CITY'  , 'PRIMARY_ADDRESS_CITY'             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView.Preview',  4, 'Prospects.LBL_PRIMARY_ADDRESS_STATE' , 'PRIMARY_ADDRESS_STATE'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Prospects.ArchiveView.Preview',  5, 'Prospects.LBL_EMAIL_ADDRESS'         , 'EMAIL1'                           , '{0}'        , 'EMAIL1', 'mailto:{0}', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView.Preview',  6, 'Prospects.LBL_OFFICE_PHONE'          , 'PHONE_WORK'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView.Preview',  7, 'Prospects.LBL_MOBILE_PHONE'          , 'PHONE_MOBILE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView.Preview',  8, 'Prospects.LBL_DEPARTMENT'            , 'DEPARTMENT'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView.Preview',  9, 'Teams.LBL_TEAM'                      , 'TEAM_NAME'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Prospects.ArchiveView.Preview', 10, '.LBL_ASSIGNED_TO'                    , 'ASSIGNED_TO_NAME'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Prospects.ArchiveView.Preview', 11, 'TextBox', 'Prospects.LBL_DESCRIPTION', 'DESCRIPTION', null, null, null, null, null, null, null;
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

call dbo.spDETAILVIEWS_FIELDS_Preview()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_FIELDS_Preview')
/

-- #endif IBM_DB2 */

