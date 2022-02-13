

print 'DETAILVIEWS_RELATIONSHIPS ArchiveView';
set nocount on;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Accounts.ArchiveView' and CONTROL_NAME in ('Contacts', 'Opportunities', 'Leads') and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Accounts.ArchiveView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.ArchiveView'      , 'Activities'       , 'ActivitiesHistory'  ,  0, 'Activities.LBL_HISTORY'           , 'vwACCOUNTS_ACTIVITIES_ARCHIVE'     , 'ACCOUNT_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.ArchiveView'      , 'Contacts'         , 'Contacts'           ,  1, 'Contacts.LBL_MODULE_NAME'         , 'vwACCOUNTS_CONTACTS_ARCHIVE'       , 'ACCOUNT_ID', 'CONTACT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.ArchiveView'      , 'Opportunities'    , 'Opportunities'      ,  2, 'Opportunities.LBL_MODULE_NAME'    , 'vwACCOUNTS_OPPORTUNITIES_ARCHIVE'  , 'ACCOUNT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.ArchiveView'      , 'Leads'            , 'Leads'              ,  3, 'Leads.LBL_MODULE_NAME'            , 'vwACCOUNTS_LEADS_ARCHIVE'          , 'ACCOUNT_ID', 'LEAD_NAME'    , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.ArchiveView'      , 'Cases'            , 'Cases'              ,  4, 'Cases.LBL_MODULE_NAME'            , 'vwACCOUNTS_CASES_ARCHIVE'          , 'ACCOUNT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.ArchiveView'      , 'Bugs'             , 'Bugs'               ,  5, 'Bugs.LBL_MODULE_NAME'             , 'vwACCOUNTS_BUGS_ARCHIVE'           , 'ACCOUNT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.ArchiveView'      , 'Project'          , 'Projects'           ,  6, 'Project.LBL_MODULE_NAME'          , 'vwACCOUNTS_PROJECTS_ARCHIVE'       , 'ACCOUNT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.ArchiveView'      , 'Documents'        , 'Documents'          ,  7, 'Documents.LBL_MODULE_NAME'        , 'vwACCOUNTS_DOCUMENTS_ARCHIVE'      , 'ACCOUNT_ID', 'DOCUMENT_NAME', 'asc';
end -- if;
GO

-- 01/27/2020 Paul.  Early state had missing sort fields that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Bugs.ArchiveView' and CONTROL_NAME = 'ActivitiesHistory' and SORT_FIELD is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Bugs.ArchiveView';
end -- if;
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Bugs.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Bugs.ArchiveView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.ArchiveView'          , 'Activities'       , 'ActivitiesHistory'  ,  0, 'Activities.LBL_HISTORY'           , 'vwBUGS_ACTIVITIES_ARCHIVE'         , 'BUG_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.ArchiveView'          , 'Contacts'         , 'Contacts'           ,  1, 'Contacts.LBL_MODULE_NAME'         , 'vwBUGS_CONTACTS_ARCHIVE'           , 'BUG_ID', 'CONTACT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.ArchiveView'          , 'Accounts'         , 'Accounts'           ,  2, 'Accounts.LBL_MODULE_NAME'         , 'vwBUGS_ACCOUNTS_ARCHIVE'           , 'BUG_ID', 'ACCOUNT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.ArchiveView'          , 'Cases'            , 'Cases'              ,  3, 'Cases.LBL_MODULE_NAME'            , 'vwBUGS_CASES_ARCHIVE'              , 'BUG_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Bugs.ArchiveView'          , 'Documents'        , 'Documents'          ,  4, 'Documents.LBL_MODULE_NAME'        , 'vwBUGS_DOCUMENTS_ARCHIVE'          , 'BUG_ID', 'DOCUMENT_NAME', 'asc';
end -- if;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Calls.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Calls.ArchiveView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Calls.ArchiveView'         , 'Contacts'         , 'Contacts'           ,  0, 'Contacts.LBL_MODULE_NAME'         , 'vwCALLS_CONTACTS_ARCHIVE'          , 'CALL_ID', 'CONTACT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Calls.ArchiveView'         , 'Users'            , 'Users'              ,  1, 'Users.LBL_MODULE_NAME'            , 'vwCALLS_USERS_ARCHIVE'             , 'CALL_ID', 'FULL_NAME'   , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Calls.ArchiveView'         , 'Notes'            , 'Notes'              ,  2, 'Notes.LBL_MODULE_NAME'            , 'vwCALLS_NOTES_ARCHIVE'             , 'CALL_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Calls.ArchiveView'         , 'Leads'            , 'Leads'              ,  3, 'Leads.LBL_MODULE_NAME'            , 'vwCALLS_LEADS_ARCHIVE'             , 'CALL_ID', 'LEAD_NAME'   , 'asc';
end -- if;
GO

-- 08/04/2019 Paul.  Early state had missing table names that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Cases.ArchiveView' and TABLE_NAME is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Cases.ArchiveView';
end -- if;
-- 01/27/2020 Paul.  Early state had missing sort fields that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Cases.ArchiveView' and CONTROL_NAME = 'ActivitiesHistory' and SORT_FIELD is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Cases.ArchiveView';
end -- if;
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Cases.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Cases.ArchiveView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.ArchiveView'         , 'Activities'       , 'ActivitiesHistory'  ,  0, 'Activities.LBL_HISTORY'           , 'vwCASES_ACTIVITIES_ARCHIVE'        , 'CASE_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.ArchiveView'         , 'Contacts'         , 'Contacts'           ,  1, 'Contacts.LBL_MODULE_NAME'         , 'vwCASES_CONTACTS_ARCHIVE'          , 'CASE_ID', 'CONTACT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.ArchiveView'         , 'Bugs'             , 'Bugs'               ,  2, 'Bugs.LBL_MODULE_NAME'             , 'vwCASES_BUGS_ARCHIVE'              , 'CASE_ID', 'BUG_NAME'     , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.ArchiveView'         , 'Documents'        , 'Documents'          ,  3, 'Documents.LBL_MODULE_NAME'        , 'vwCASES_DOCUMENTS_ARCHIVE'         , 'CASE_ID', 'DOCUMENT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.ArchiveView'         , 'Project'          , 'Projects'           ,  4, 'Project.LBL_MODULE_NAME'          , 'vwCASES_PROJECTS_ARCHIVE'          , 'CASE_ID', 'ESTIMATED_START_DATE', 'asc';
end -- if;
GO

-- 01/27/2020 Paul.  Early state had missing sort fields that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Contacts.ArchiveView' and CONTROL_NAME = 'ActivitiesHistory' and SORT_FIELD is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Contacts.ArchiveView';
end -- if;
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Contacts.ArchiveView' and CONTROL_NAME in ('Leads', 'Opportunities', 'Cases') and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Contacts.ArchiveView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.ArchiveView'      , 'Activities'       , 'ActivitiesHistory'  ,  0, 'Activities.LBL_HISTORY'           , 'vwCONTACTS_ACTIVITIES_ARCHIVE'     , 'CONTACT_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.ArchiveView'      , 'Leads'            , 'Leads'              ,  1, 'Leads.LBL_MODULE_NAME'            , 'vwCONTACTS_LEADS_ARCHIVE'          , 'CONTACT_ID', 'LEAD_NAME'    , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.ArchiveView'      , 'Opportunities'    , 'Opportunities'      ,  2, 'Opportunities.LBL_MODULE_NAME'    , 'vwCONTACTS_OPPORTUNITIES_ARCHIVE'  , 'CONTACT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.ArchiveView'      , 'Cases'            , 'Cases'              ,  3, 'Cases.LBL_MODULE_NAME'            , 'vwCONTACTS_CASES_ARCHIVE'          , 'CONTACT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.ArchiveView'      , 'Bugs'             , 'Bugs'               ,  4, 'Bugs.LBL_MODULE_NAME'             , 'vwCONTACTS_BUGS_ARCHIVE'           , 'CONTACT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.ArchiveView'      , 'Project'          , 'Projects'           ,  5, 'Project.LBL_MODULE_NAME'          , 'vwCONTACTS_PROJECTS_ARCHIVE'       , 'CONTACT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.ArchiveView'      , 'ProspectLists'    , 'ProspectLists'      ,  6, 'ProspectLists.LBL_MODULE_NAME'    , 'vwCONTACTS_PROSPECT_LISTS_ARCHIVE' , 'CONTACT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.ArchiveView'      , 'Documents'        , 'Documents'          ,  7, 'Documents.LBL_MODULE_NAME'        , 'vwCONTACTS_DOCUMENTS_ARCHIVE'      , 'CONTACT_ID', 'DOCUMENT_NAME', 'asc';
end -- if;
GO

-- 08/04/2019 Paul.  Early state had missing table names that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Documents.ArchiveView' and TABLE_NAME is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Documents.ArchiveView';
end -- if;

-- 08/04/2019 Paul.  Correct so that records are created even if professional file runs first. 
-- 11/23/2021 Paul.  Correct DocumentRevisions title for React client. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Documents.ArchiveView' and CONTROL_NAME = 'Accounts' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Documents.ArchiveView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.ArchiveView'     , 'Documents'        , 'DocumentRevisions'  ,  0, 'DocumentRevisions.LBL_MODULE_NAME', 'vwDOCUMENT_REVISIONS_ARCHIVE'      , 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.ArchiveView'     , 'Accounts'         , 'Accounts'           ,  1, 'Accounts.LBL_MODULE_NAME'         , 'vwDOCUMENTS_ACCOUNTS_ARCHIVE'      , 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.ArchiveView'     , 'Contacts'         , 'Contacts'           ,  2, 'Contacts.LBL_MODULE_NAME'         , 'vwDOCUMENTS_CONTACTS_ARCHIVE'      , 'DOCUMENT_ID', 'CONTACT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.ArchiveView'     , 'Leads'            , 'Leads'              ,  3, 'Leads.LBL_MODULE_NAME'            , 'vwDOCUMENTS_LEADS_ARCHIVE'         , 'DOCUMENT_ID', 'LEAD_NAME'   , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.ArchiveView'     , 'Opportunities'    , 'Opportunities'      ,  4, 'Opportunities.LBL_MODULE_NAME'    , 'vwDOCUMENTS_OPPORTUNITIES_ARCHIVE' , 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.ArchiveView'     , 'Bugs'             , 'Bugs'               ,  5, 'Bugs.LBL_MODULE_NAME'             , 'vwDOCUMENTS_BUGS_ARCHIVE'          , 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.ArchiveView'     , 'Cases'            , 'Cases'              ,  6, 'Cases.LBL_MODULE_NAME'            , 'vwDOCUMENTS_CASES_ARCHIVE'         , 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
end else begin
	-- 11/23/2021 Paul.  Correct DocumentRevisions title for React client. 
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Documents.ArchiveView' and CONTROL_NAME = 'DocumentRevisions' and TITLE = 'Documents.LBL_MODULE_NAME' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set TITLE            = 'DocumentRevisions.LBL_MODULE_NAME'
		     , DATE_MODIFIED    = getdate()
		     , DATE_MODIFIED_UTC= getutcdate()
		     , MODIFIED_USER_ID = null
		 where DETAIL_NAME      = 'Documents.ArchiveView'
		   and CONTROL_NAME     = 'DocumentRevisions'
		   and TITLE            = 'Documents.LBL_MODULE_NAME'
		   and DELETED          = 0;
	end -- if;
end -- if;
GO

-- 08/04/2019 Paul.  Early state had missing table names that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Emails.ArchiveView' and TABLE_NAME is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Emails.ArchiveView';
end -- if;

-- 08/04/2019 Paul.  Correct so that records are created even if professional file runs first. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Emails.ArchiveView' and CONTROL_NAME = 'Accounts' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Emails.ArchiveView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.ArchiveView'        , 'Accounts'         , 'Accounts'           ,  0, 'Accounts.LBL_MODULE_NAME'         , 'vwEMAILS_ACCOUNTS_ARCHIVE'         , 'EMAIL_ID', 'ACCOUNT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.ArchiveView'        , 'Contacts'         , 'Contacts'           ,  1, 'Contacts.LBL_MODULE_NAME'         , 'vwEMAILS_CONTACTS_ARCHIVE'         , 'EMAIL_ID', 'CONTACT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.ArchiveView'        , 'Opportunities'    , 'Opportunities'      ,  2, 'Opportunities.LBL_MODULE_NAME'    , 'vwEMAILS_OPPORTUNITIES_ARCHIVE'    , 'EMAIL_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.ArchiveView'        , 'Leads'            , 'Leads'              ,  3, 'Leads.LBL_MODULE_NAME'            , 'vwEMAILS_LEADS_ARCHIVE'            , 'EMAIL_ID', 'LEAD_NAME'   , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.ArchiveView'        , 'Cases'            , 'Cases'              ,  4, 'Cases.LBL_MODULE_NAME'            , 'vwEMAILS_CASES_ARCHIVE'            , 'EMAIL_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.ArchiveView'        , 'Users'            , 'Users'              ,  5, 'Users.LBL_MODULE_NAME'            , 'vwEMAILS_USERS_ARCHIVE'            , 'EMAIL_ID', 'FULL_NAME'   , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.ArchiveView'        , 'Bugs'             , 'Bugs'               ,  6, 'Bugs.LBL_MODULE_NAME'             , 'vwEMAILS_BUGS_ARCHIVE'             , 'EMAIL_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.ArchiveView'        , 'Project'          , 'Projects'           ,  7, 'Project.LBL_MODULE_NAME'          , 'vwEMAILS_PROJECTS_ARCHIVE'         , 'EMAIL_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.ArchiveView'        , 'ProjectTask'      , 'ProjectTasks'       ,  8, 'ProjectTask.LBL_MODULE_NAME'      , 'vwEMAILS_PROJECT_TASKS_ARCHIVE'    , 'EMAIL_ID', 'DATE_DUE'    , 'desc';
end -- if;
GO

-- 01/27/2020 Paul.  Early state had missing sort fields that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Leads.ArchiveView' and CONTROL_NAME = 'ActivitiesHistory' and SORT_FIELD is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Leads.ArchiveView';
end -- if;
-- 10/29/2020 Paul.  Correct vwLEADS_CONTACT_ARCHIVE, remove the S on the end. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Leads.ArchiveView' and CONTROL_NAME in ('ActivityStream', 'ActivitiesOpen', 'ActivitiesHistory') and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Leads.ArchiveView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.ArchiveView'         , 'Activities'       , 'ActivitiesHistory'  ,  0, 'Activities.LBL_HISTORY'           , 'vwLEADS_ACTIVITIES_ARCHIVE'        , 'LEAD_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.ArchiveView'         , 'ProspectLists'    , 'ProspectLists'      ,  1, 'ProspectLists.LBL_MODULE_NAME'    , 'vwLEADS_PROSPECT_LISTS_ARCHIVE'    , 'LEAD_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.ArchiveView'         , 'Documents'        , 'Documents'          ,  2, 'Documents.LBL_MODULE_NAME'        , 'vwLEADS_DOCUMENTS_ARCHIVE'         , 'LEAD_ID', 'DOCUMENT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Leads.ArchiveView'         , 'Contacts'         , 'Contacts'           ,  3, 'Contacts.LBL_MODULE_NAME'         , 'vwLEADS_CONTACTS_ARCHIVE'          , 'LEAD_ID', 'CONTACT_NAME' , 'asc';
end else begin
	if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Leads.ArchiveView' and TABLE_NAME = 'vwLEADS_CONTACT_ARCHIVES' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set TABLE_NAME        = 'vwLEADS_CONTACTS_ARCHIVE'
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where DETAIL_NAME       = 'Leads.ArchiveView'
		   and TABLE_NAME        = 'vwLEADS_CONTACT_ARCHIVES'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Meetings.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Meetings.ArchiveView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Meetings.ArchiveView'      , 'Contacts'         , 'Contacts'           ,  0, 'Contacts.LBL_MODULE_NAME'         , 'vwMEETINGS_CONTACTS_ARCHIVE'       , 'MEETING_ID', 'CONTACT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Meetings.ArchiveView'      , 'Users'            , 'Users'              ,  1, 'Users.LBL_MODULE_NAME'            , 'vwMEETINGS_USERS_ARCHIVE'          , 'MEETING_ID', 'FULL_NAME'   , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Meetings.ArchiveView'      , 'Leads'            , 'Leads'              ,  2, 'Leads.LBL_MODULE_NAME'            , 'vwMEETINGS_LEADS_ARCHIVE'          , 'MEETING_ID', 'LEAD_NAME'   , 'asc';
end -- if;
GO

-- 08/04/2019 Paul.  Early state had missing table names that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Opportunities.ArchiveView' and TABLE_NAME is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Opportunities.ArchiveView';
end -- if;
-- 01/27/2020 Paul.  Early state had missing sort fields that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Opportunities.ArchiveView' and CONTROL_NAME = 'ActivitiesHistory' and SORT_FIELD is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Opportunities.ArchiveView';
end -- if;

-- 08/04/2019 Paul.  Correct so that records are created even if professional file runs first. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Opportunities.ArchiveView' and CONTROL_NAME = 'Contacts' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Opportunities.ArchiveView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.ArchiveView' , 'Activities'       , 'ActivitiesHistory'  ,  2, 'Activities.LBL_HISTORY'           , 'vwOPPORTUNITIES_ACTIVITIES_ARCHIVE', 'OPPORTUNITY_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.ArchiveView' , 'Contacts'         , 'Contacts'           ,  3, 'Contacts.LBL_MODULE_NAME'         , 'vwOPPORTUNITIES_CONTACTS_ARCHIVE'  , 'OPPORTUNITY_ID', 'CONTACT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.ArchiveView' , 'Project'          , 'Projects'           ,  4, 'Project.LBL_MODULE_NAME'          , 'vwOPPORTUNITIES_PROJECTS_ARCHIVE'  , 'OPPORTUNITY_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.ArchiveView' , 'Documents'        , 'Documents'          ,  5, 'Documents.LBL_MODULE_NAME'        , 'vwOPPORTUNITIES_DOCUMENTS_ARCHIVE' , 'OPPORTUNITY_ID', 'DATE_ENTERED' , 'desc';
end -- if;
GO

-- 08/04/2019 Paul.  Early state had missing table names that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Project.ArchiveView' and TABLE_NAME is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Project.ArchiveView';
end -- if;
-- 01/27/2020 Paul.  Early state had missing sort fields that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Project.ArchiveView' and CONTROL_NAME = 'ActivitiesHistory' and SORT_FIELD is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Project.ArchiveView';
end -- if;

-- 08/04/2019 Paul.  Correct so that records are created even if professional file runs first. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Project.ArchiveView' and CONTROL_NAME = 'ProjectTask' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Project.ArchiveView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Project.ArchiveView'       , 'Activities'       , 'ActivitiesHistory'  ,  1, 'Activities.LBL_HISTORY'           , 'vwPROJECTS_ACTIVITIES_ARCHIVE', 'PROJECT_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Project.ArchiveView'       , 'ProjectTask'      , 'ProjectTasks'       ,  2, 'ProjectTask.LBL_MODULE_NAME'      , 'vwPROJECTS_PROJECT_TASKS_ARCHIVE'  , 'PROJECT_ID', 'DATE_DUE'     , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Project.ArchiveView'       , 'Contacts'         , 'Contacts'           ,  3, 'Contacts.LBL_MODULE_NAME'         , 'vwPROJECTS_CONTACTS_ARCHIVE'       , 'PROJECT_ID', 'CONTACT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Project.ArchiveView'       , 'Accounts'         , 'Accounts'           ,  4, 'Accounts.LBL_MODULE_NAME'         , 'vwPROJECTS_ACCOUNTS_ARCHIVE'       , 'PROJECT_ID', 'ACCOUNT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Project.ArchiveView'       , 'Opportunities'    , 'Opportunities'      ,  5, 'Opportunities.LBL_MODULE_NAME'    , 'vwPROJECTS_OPPORTUNITIES_ARCHIVE'  , 'PROJECT_ID', 'DATE_ENTERED' , 'desc';
end -- if;
GO

-- 01/27/2020 Paul.  Early state had missing sort fields that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ProjectTask.ArchiveView' and CONTROL_NAME = 'ActivitiesHistory' and SORT_FIELD is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ProjectTask.ArchiveView';
end -- if;
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'ProjectTask.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS ProjectTask.ArchiveView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'ProjectTask.ArchiveView'   , 'Activities'       , 'ActivitiesHistory'  ,  1, 'Activities.LBL_HISTORY'           , 'vwPROJECT_TASKS_ACTIVITIES_ARCHIVE'     , 'PROJECT_TASK_ID', 'DATE_MODIFIED', 'desc';
end -- if;
GO

-- 01/27/2020 Paul.  Early state had missing sort fields that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Prospects.ArchiveView' and CONTROL_NAME = 'ActivitiesHistory' and SORT_FIELD is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Prospects.ArchiveView';
end -- if;
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Prospects.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Prospects.ArchiveView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Prospects.ArchiveView'     , 'Activities'       , 'ActivitiesHistory'  ,  2, 'Activities.LBL_HISTORY'           , 'vwPROSPECTS_ACTIVITIES_ARCHIVE'    , 'PROSPECT_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Prospects.ArchiveView'     , 'ProspectLists'    , 'ProspectLists'      ,  3, 'ProspectLists.LBL_MODULE_NAME'    , 'vwPROSPECTS_PROSPECT_LISTS_ARCHIVE', 'PROSPECT_ID', 'DATE_ENTERED' , 'desc';
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

call dbo.spDETAILVIEWS_RELATIONSHIPS_ArchiveView()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_RELATIONSHIPS_ArchiveView')
/

-- #endif IBM_DB2 */

