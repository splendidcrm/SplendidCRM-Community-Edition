

print 'GRIDVIEWS_COLUMNS ListView defaults';
-- delete from GRIDVIEWS_COLUMNS -- where GRID_NAME like '%.ArchiveView'
--GO

set nocount on;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.ArchiveView'          , 'Accounts', 'vwACCOUNTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.ArchiveView'          ,  2, 'Accounts.LBL_LIST_ACCOUNT_NAME'               , 'NAME'                    , 'NAME'                    , '30%', 'listViewTdLinkS1', 'ID'         , '~/Accounts/view.aspx?id={0}&ArchiveView=1', null, 'Accounts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ArchiveView'          ,  3, 'Accounts.LBL_LIST_BILLING_ADDRESS_CITY'       , 'BILLING_ADDRESS_CITY'    , 'BILLING_ADDRESS_CITY'    , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ArchiveView'          ,  4, 'Accounts.LBL_LIST_BILLING_ADDRESS_STATE'      , 'BILLING_ADDRESS_STATE'   , 'BILLING_ADDRESS_STATE'   , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ArchiveView'          ,  5, 'Accounts.LBL_LIST_PHONE'                      , 'PHONE_OFFICE'            , 'PHONE_OFFICE'            , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Accounts.ArchiveView'          ,  6, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ArchiveView'          ,  7, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Accounts.ArchiveView'          ,  8, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'               , 'TEAM_NAME'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.ArchiveView'          ,  9, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Bugs.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Bugs.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Bugs.ArchiveView'              , 'Bugs', 'vwBUGS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.ArchiveView'              ,  2, 'Bugs.LBL_LIST_NUMBER'                         , 'BUG_NUMBER'              , 'BUG_NUMBER'              , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Bugs.ArchiveView'              ,  3, 'Bugs.LBL_LIST_SUBJECT'                        , 'NAME'                    , 'NAME'                    , '20%', 'listViewTdLinkS1', 'ID'         , '~/Bugs/view.aspx?id={0}&ArchiveView=1', null, 'Bugs', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.ArchiveView'              ,  4, 'Bugs.LBL_LIST_STATUS'                         , 'STATUS'                  , 'STATUS'                  , '10%', 'bug_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.ArchiveView'              ,  5, 'Bugs.LBL_LIST_TYPE'                           , 'TYPE'                    , 'TYPE'                    , '10%', 'bug_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Bugs.ArchiveView'              ,  6, 'Bugs.LBL_LIST_PRIORITY'                       , 'PRIORITY'                , 'PRIORITY'                , '10%', 'bug_priority_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.ArchiveView'              ,  7, 'Bugs.LBL_LIST_RELEASE'                        , 'FOUND_IN_RELEASE'        , 'FOUND_IN_RELEASE'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Bugs.ArchiveView'              ,  8, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.ArchiveView'              ,  9, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Bugs.ArchiveView'              , 10, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'               , 'TEAM_NAME'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Bugs.ArchiveView'              , 11, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end -- if;
GO

-- 04/27/2020 Paul.  Contacts relationship will not be created. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Calls.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Calls.ArchiveView'             , 'Calls', 'vwCALLS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Calls.ArchiveView'             ,  2, 'Calls.LBL_LIST_CLOSE'                         , 'STATUS'                  , 'STATUS'                  , '10%', 'call_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Calls.ArchiveView'             ,  3, 'Calls.LBL_LIST_DIRECTION'                     , 'DIRECTION'               , 'DIRECTION'               , '10%', 'call_direction_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.ArchiveView'             ,  4, 'Calls.LBL_LIST_SUBJECT'                       , 'NAME'                    , 'NAME'                    , '20%', 'listViewTdLinkS1', 'ID'         , '~/Calls/view.aspx?id={0}&ArchiveView=1', null, 'Calls', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Calls.ArchiveView'             ,  5, 'Calls.LBL_LIST_RELATED_TO'                    , 'PARENT_NAME'             , 'PARENT_NAME'             , '10%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}&ArchiveView=1', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Calls.ArchiveView'             ,  6, 'Calls.LBL_LIST_DATE'                          , 'DATE_START'              , 'DATE_START'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.ArchiveView'             ,  7, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Calls.ArchiveView'             ,  8, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'               , 'TEAM_NAME'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Calls.ArchiveView'             ,  9, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end else begin
	-- 04/27/2020 Paul.  Contacts relationship will not be created. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Calls.ArchiveView' and DATA_FIELD = 'CONTACT_NAME' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Calls.ArchiveView'
		   and DATA_FIELD        = 'CONTACT_NAME'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.ArchiveView'             , 'Cases', 'vwCASES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.ArchiveView'             ,  2, 'Cases.LBL_LIST_NUMBER'                        , 'CASE_NUMBER'             , 'CASE_NUMBER'             , '10%', 'listViewTdLinkS1', 'ID'         , '~/Cases/view.aspx?id={0}&ArchiveView=1'   , null, 'Cases'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.ArchiveView'             ,  3, 'Cases.LBL_LIST_SUBJECT'                       , 'NAME'                    , 'NAME'                    , '15%', 'listViewTdLinkS1', 'ID'         , '~/Cases/view.aspx?id={0}&ArchiveView=1'   , null, 'Cases'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.ArchiveView'             ,  4, 'Cases.LBL_LIST_ACCOUNT_NAME'                  , 'ACCOUNT_NAME'            , 'ACCOUNT_NAME'            , '15%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}&ArchiveView=1', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.ArchiveView'             ,  5, 'Cases.LBL_LIST_PRIORITY'                      , 'PRIORITY'                , 'PRIORITY'                , '10%', 'case_priority_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Cases.ArchiveView'             ,  6, 'Cases.LBL_LIST_STATUS'                        , 'STATUS'                  , 'STATUS'                  , '10%', 'case_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Cases.ArchiveView'             ,  7, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.ArchiveView'             ,  8, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.ArchiveView'             ,  9, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'               , 'TEAM_NAME'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Cases.ArchiveView'             , 10, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.ArchiveView'          , 'Contacts', 'vwCONTACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.ArchiveView'          ,  2, 'Contacts.LBL_LIST_NAME'                       , 'NAME'                    , 'NAME'                    , '15%', 'listViewTdLinkS1', 'ID'         , '~/Contacts/view.aspx?id={0}&ArchiveView=1', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ArchiveView'          ,  3, 'Contacts.LBL_LIST_TITLE'                      , 'TITLE'                   , 'TITLE'                   , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.ArchiveView'          ,  4, 'Contacts.LBL_LIST_ACCOUNT_NAME'               , 'ACCOUNT_NAME'            , 'ACCOUNT_NAME'            , '15%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}&ArchiveView=1', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.ArchiveView'          ,  5, 'Contacts.LBL_LIST_EMAIL_ADDRESS'              , 'EMAIL1'                  , 'EMAIL1'                  , '10%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}'  , null, 'Emails'  , null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ArchiveView'          ,  6, 'Contacts.LBL_LIST_PHONE'                      , 'PHONE_WORK'              , 'PHONE_WORK'              , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Contacts.ArchiveView'          ,  7, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.ArchiveView'          ,  8, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'           , 'DATE_MODIFIED'           , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ArchiveView'          ,  9, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '8%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contacts.ArchiveView'          , 10, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'               , 'TEAM_NAME'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.ArchiveView'          , 11, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.ArchiveView'         , 'Documents', 'vwDOCUMENTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.ArchiveView'         ,  2, 'Documents.LBL_LIST_DOCUMENT'                  , 'NAME'                    , 'NAME'                    , '25%', 'listViewTdLinkS1', 'ID', '~/Documents/view.aspx?id={0}&ArchiveView=1', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ArchiveView'         ,  3, 'Documents.LBL_LIST_CATEGORY'                  , 'CATEGORY_ID'             , 'CATEGORY_ID'             , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ArchiveView'         ,  4, 'Documents.LBL_LIST_SUBCATEGORY'               , 'SUBCATEGORY_ID'          , 'SUBCATEGORY_ID'          , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ArchiveView'         ,  5, 'Documents.LBL_LIST_REVISION'                  , 'REVISION'                , 'REVISION'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ArchiveView'         ,  6, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'               , 'TEAM_NAME'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ArchiveView'         ,  7, 'Documents.LBL_LIST_LAST_REV_CREATOR'          , 'REVISION_CREATED_BY_NAME', 'REVISION_CREATED_BY_NAME', '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.ArchiveView'         ,  8, 'Documents.LBL_LIST_LAST_REV_DATE'             , 'REVISION_DATE_ENTERED'   , 'REVISION_DATE_ENTERED'   , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.ArchiveView'         ,  9, 'Documents.LBL_LIST_ACTIVE_DATE'               , 'ACTIVE_DATE'             , 'ACTIVE_DATE'             , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.ArchiveView'         , 10, 'Documents.LBL_LIST_EXP_DATE'                  , 'EXP_DATE'                , 'EXP_DATE'                , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Documents.ArchiveView'         , 11, '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.ArchiveView'         , 12, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.ArchiveView'         , 13, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end -- if;
GO

-- 07/27/2018 Paul.  Contacts relationship will not be created. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.ArchiveView'            , 'Emails', 'vwEMAILS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.ArchiveView'            ,  2, 'Emails.LBL_LIST_SUBJECT'                      , 'NAME'                    , 'NAME'                    , '25%', 'listViewTdLinkS1', 'ID'         , '~/Emails/view.aspx?id={0}&ArchiveView=1', null, 'Emails', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.ArchiveView'            ,  3, 'Emails.LBL_LIST_RELATED_TO'                   , 'PARENT_NAME'             , 'PARENT_NAME'             , '15%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}&ArchiveView=1', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Emails.ArchiveView'            ,  4, '.LBL_LIST_CREATED'                            , 'DATE_ENTERED'            , 'DATE_ENTERED'            , '15%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Emails.ArchiveView'            ,  5, 'Emails.LBL_LIST_STATUS'                       , 'STATUS'                  , 'STATUS'                  , '10%', 'dom_email_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ArchiveView'            ,  6, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Emails.ArchiveView'            ,  7, 'Emails.LBL_LIST_TYPE'                         , 'TYPE_TERM'               , 'TYPE_TERM'               , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Emails.ArchiveView'            ,  8, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end else begin
	-- 07/27/2018 Paul.  Contacts relationship will not be created. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.ArchiveView' and DATA_FIELD = 'CONTACT_NAME' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Emails.ArchiveView'
		   and DATA_FIELD        = 'CONTACT_NAME'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.ArchiveView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Leads.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Leads.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Leads.ArchiveView'             , 'Leads', 'vwLEADS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.ArchiveView'             ,  2, 'Leads.LBL_LIST_NAME'                          , 'NAME'                    , 'NAME'                    , '15%', 'listViewTdLinkS1', 'ID'         , '~/Leads/view.aspx?id={0}&ArchiveView=1', null, 'Leads', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Leads.ArchiveView'             ,  3, 'Leads.LBL_LIST_STATUS'                        , 'STATUS'                  , 'STATUS'                  , '10%', 'lead_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ArchiveView'             ,  4, 'Leads.LBL_LIST_ACCOUNT_NAME'                  , 'ACCOUNT_NAME'            , 'ACCOUNT_NAME'            , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Leads.ArchiveView'             ,  5, 'Leads.LBL_LIST_EMAIL_ADDRESS'                 , 'EMAIL1'                  , 'EMAIL1'                  , '10%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}'  , null, 'Emails'  , null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ArchiveView'             ,  6, 'Leads.LBL_LIST_PHONE'                         , 'PHONE_WORK'              , 'PHONE_WORK'              , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Leads.ArchiveView'             ,  7, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ArchiveView'             ,  8, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '8%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Leads.ArchiveView'             ,  9, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'               , 'TEAM_NAME'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Leads.ArchiveView'             , 10, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end -- if;
GO

-- 04/27/2020 Paul.  Contacts relationship will not be created. 
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Meetings.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Meetings.ArchiveView'          , 'Meetings', 'vwMEETINGS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Meetings.ArchiveView'          ,  2, 'Meetings.LBL_LIST_CLOSE'                      , 'STATUS'                  , 'STATUS'                  , '10%', 'meeting_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.ArchiveView'          ,  3, 'Meetings.LBL_LIST_SUBJECT'                    , 'NAME'                    , 'NAME'                    , '25%', 'listViewTdLinkS1', 'ID'         , '~/Meetings/view.aspx?id={0}&ArchiveView=1', null, 'Meetings', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Meetings.ArchiveView'          ,  4, 'Meetings.LBL_LIST_RELATED_TO'                 , 'PARENT_NAME'             , 'PARENT_NAME'             , '10%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}&ArchiveView=1', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Meetings.ArchiveView'          ,  5, 'Meetings.LBL_LIST_DATE'                       , 'DATE_START'              , 'DATE_START'              , '15%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.ArchiveView'          ,  6, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Meetings.ArchiveView'          ,  7, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'               , 'TEAM_NAME'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Meetings.ArchiveView'          ,  8, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end else begin
	-- 04/27/2020 Paul.  Contacts relationship will not be created. 
	if exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Meetings.ArchiveView' and DATA_FIELD = 'CONTACT_NAME' and DELETED = 0) begin -- then
		update GRIDVIEWS_COLUMNS
		   set DELETED           = 1
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		 where GRID_NAME         = 'Meetings.ArchiveView'
		   and DATA_FIELD        = 'CONTACT_NAME'
		   and DELETED           = 0;
	end -- if;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Notes.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Notes.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Notes.ArchiveView'             , 'Notes', 'vwNOTES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Notes.ArchiveView'             ,  2, 'Notes.LBL_LIST_SUBJECT'                       , 'NAME'                    , 'NAME'                    , '30%', 'listViewTdLinkS1', 'ID'         , '~/Notes/view.aspx?id={0}&ArchiveView=1', null, 'Notes', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Notes.ArchiveView'             ,  3, 'Notes.LBL_LIST_CONTACT_NAME'                  , 'CONTACT_NAME'            , 'CONTACT_NAME'            , '10%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}&ArchiveView=1', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Notes.ArchiveView'             ,  4, 'Notes.LBL_LIST_RELATED_TO'                    , 'PARENT_NAME'             , 'PARENT_NAME'             , '10%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}&ArchiveView=1', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.ArchiveView'             ,  5, 'Notes.LBL_LIST_FILENAME'                      , 'FILENAME'                , 'FILENAME'                , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Notes.ArchiveView'             ,  6, '.LBL_LIST_DATE_MODIFIED'                      , 'DATE_MODIFIED'           , 'DATE_MODIFIED'           , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Notes.ArchiveView'             ,  7, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Notes.ArchiveView'             ,  8, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.ArchiveView'     , 'Opportunities', 'vwOPPORTUNITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.ArchiveView'     ,  2, 'Opportunities.LBL_LIST_OPPORTUNITY_NAME'      , 'NAME'                    , 'NAME'                    , '20%', 'listViewTdLinkS1', 'ID'         , '~/Opportunities/view.aspx?id={0}&ArchiveView=1', null, 'Opportunities', 'ASSIGNED_USER_ID'        ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.ArchiveView'     ,  3, 'Opportunities.LBL_LIST_ACCOUNT_NAME'          , 'ACCOUNT_NAME'            , 'ACCOUNT_NAME'            , '10%', 'listViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}&ArchiveView=1'     , null, 'Accounts'     , 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.ArchiveView'     ,  4, 'Opportunities.LBL_LIST_LEAD_NAME'             , 'LEAD_NAME'               , 'LEAD_NAME'               , '10%', 'listViewTdLinkS1', 'LEAD_ID'    , '~/Leads/view.aspx?id={0}&ArchiveView=1'        , null, 'Leads'        , 'LEAD_ASSIGNED_USER_ID'   ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Opportunities.ArchiveView'     ,  5, 'Opportunities.LBL_LIST_SALES_STAGE'           , 'SALES_STAGE'             , 'SALES_STAGE'             , '10%', 'sales_stage_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.ArchiveView'     ,  6, 'Opportunities.LBL_LIST_AMOUNT'                , 'AMOUNT_USDOLLAR'         , 'AMOUNT_USDOLLAR'         , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.ArchiveView'     ,  7, 'Opportunities.LBL_LIST_DATE_CLOSED'           , 'DATE_CLOSED'             , 'DATE_CLOSED'             , '10%', 'Date'    ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Opportunities.ArchiveView'     ,  8, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.ArchiveView'     ,  9, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.ArchiveView'     , 10, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'               , 'TEAM_NAME'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.ArchiveView'     , 11, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.ArchiveView'           , 'Project', 'vwPROJECTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.ArchiveView'           ,  2, 'Project.LBL_LIST_NAME'                        , 'NAME'                    , 'NAME'                    , '20%', 'listViewTdLinkS1', 'ID'         , '~/Projects/view.aspx?id={0}&ArchiveView=1', null, 'Project', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.ArchiveView'           ,  3, 'Project.LBL_LIST_ESTIMATED_START_DATE'        , 'ESTIMATED_START_DATE'    , 'ESTIMATED_START_DATE'    , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.ArchiveView'           ,  4, 'Project.LBL_LIST_ESTIMATED_END_DATE'          , 'ESTIMATED_END_DATE'      , 'ESTIMATED_END_DATE'      , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Project.ArchiveView'           ,  5, 'Project.LBL_LIST_STATUS'                      , 'STATUS'                  , 'STATUS'                  , '15%', 'project_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Project.ArchiveView'           ,  6, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.ArchiveView'           ,  7, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Project.ArchiveView'           ,  8, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'               , 'TEAM_NAME'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.ArchiveView'           ,  9, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Prospects.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Prospects.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Prospects.ArchiveView'         , 'Prospects', 'vwPROSPECTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.ArchiveView'         ,  2, 'Prospects.LBL_LIST_NAME'                      , 'NAME'                    , 'NAME'                    , '25%', 'listViewTdLinkS1', 'ID'         , '~/Prospects/view.aspx?id={0}&ArchiveView=1', null, 'Prospects', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ArchiveView'         ,  3, 'Prospects.LBL_LIST_TITLE'                     , 'TITLE'                   , 'TITLE'                   , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Prospects.ArchiveView'         ,  4, 'Prospects.LBL_LIST_EMAIL_ADDRESS'             , 'EMAIL1'                  , 'EMAIL1'                  , '15%', 'listViewTdLinkS1', 'ID'         , '~/Emails/edit.aspx?PARENT_ID={0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ArchiveView'         ,  5, 'Prospects.LBL_LIST_PHONE'                     , 'PHONE_WORK'              , 'PHONE_WORK'              , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Prospects.ArchiveView'         ,  6, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ArchiveView'         ,  7, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Prospects.ArchiveView'         ,  8, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'               , 'TEAM_NAME'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Prospects.ArchiveView'         ,  9, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Tasks.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Tasks.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Tasks.ArchiveView'             , 'Tasks', 'vwTASKS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Tasks.ArchiveView'             ,  2, 'Tasks.LBL_LIST_SUBJECT'                       , 'NAME'                    , 'NAME'                    , '30%', 'listViewTdLinkS1', 'ID'         , '~/Tasks/view.aspx?id={0}&ArchiveView=1', null, 'Tasks', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Tasks.ArchiveView'             ,  3, 'Tasks.LBL_LIST_CONTACT'                       , 'CONTACT_NAME'            , 'CONTACT_NAME'            , '10%', 'listViewTdLinkS1', 'CONTACT_ID' , '~/Contacts/view.aspx?id={0}&ArchiveView=1', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Tasks.ArchiveView'             ,  4, 'Tasks.LBL_LIST_RELATED_TO'                    , 'PARENT_NAME'             , 'PARENT_NAME'             , '10%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}&ArchiveView=1', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Tasks.ArchiveView'             ,  5, 'Tasks.LBL_LIST_DUE_DATE'                      , 'DATE_DUE'                , 'DATE_DUE'                , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.ArchiveView'             ,  6, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Tasks.ArchiveView'             ,  7, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'               , 'TEAM_NAME'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Tasks.ArchiveView'             ,  8, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'SmsMessages.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS SmsMessages.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'SmsMessages.ArchiveView'       , 'SmsMessages', 'vwSMS_MESSAGES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'SmsMessages.ArchiveView'       ,  2, 'SmsMessages.LBL_LIST_NAME'                    , 'NAME'                    , 'NAME'                    , '25%', 'listViewTdLinkS1', 'ID'         , '~/SmsMessages/view.aspx?id={0}&ArchiveView=1', null, 'SmsMessages', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'SmsMessages.ArchiveView'       ,  3, 'SmsMessages.LBL_LIST_DATE_START'              , 'DATE_START'              , 'DATE_START'              , '15%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SmsMessages.ArchiveView'       ,  4, 'SmsMessages.LBL_LIST_FROM_NUMBER'             , 'FROM_NUMBER'             , 'FROM_NUMBER'             , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SmsMessages.ArchiveView'       ,  5, 'SmsMessages.LBL_LIST_TO_NUMBER'               , 'TO_NUMBER'               , 'TO_NUMBER'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'SmsMessages.ArchiveView'       ,  6, 'SmsMessages.LBL_LIST_RELATED_TO'              , 'PARENT_NAME'             , 'PARENT_NAME'             , '18%', 'listViewTdLinkS1', 'PARENT_ID'  , '~/Parents/view.aspx?id={0}&ArchiveView=1', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SmsMessages.ArchiveView'       ,  7, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'SmsMessages.ArchiveView'       ,  8, 'SmsMessages.LBL_LIST_STATUS'                  , 'STATUS'                  , 'STATUS'                  , '5%', 'dom_sms_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'SmsMessages.ArchiveView'       ,  9, 'SmsMessages.LBL_LIST_TYPE'                    , 'TYPE_TERM'               , 'TYPE_TERM'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'SmsMessages.ArchiveView'       , 10, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'TwitterMessages.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS TwitterMessages.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'TwitterMessages.ArchiveView'   , 'TwitterMessages', 'vwTWITTER_MESSAGES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'TwitterMessages.ArchiveView'   ,  2, 'TwitterMessages.LBL_LIST_NAME'                , 'NAME'                    , 'NAME'                    , '25%', 'listViewTdLinkS1', 'ID'       , '~/TwitterMessages/view.aspx?id={0}&ArchiveView=1', null, 'TwitterMessages', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'TwitterMessages.ArchiveView'   ,  3, 'TwitterMessages.LBL_LIST_DATE_START'          , 'DATE_START'              , 'DATE_START'              , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'TwitterMessages.ArchiveView'   ,  4, 'TwitterMessages.LBL_LIST_TWITTER_SCREEN_NAME' , 'TWITTER_SCREEN_NAME'     , 'TWITTER_SCREEN_NAME'     , '10%', 'listViewTdLinkS1', 'TWITTER_SCREEN_NAME', 'http://twitter.com/{0}', 'TwitterUser', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'TwitterMessages.ArchiveView'   ,  5, 'TwitterMessages.LBL_LIST_RELATED_TO'          , 'PARENT_NAME'             , 'PARENT_NAME'             , '10%', 'listViewTdLinkS1', 'PARENT_ID', '~/Parents/view.aspx?id={0}&ArchiveView=1', null, 'Parents', 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'TwitterMessages.ArchiveView'   ,  6, 'TwitterMessages.LBL_LIST_IS_RETWEET'          , 'IS_RETWEET'              , 'IS_RETWEET'              , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'TwitterMessages.ArchiveView'   ,  7, 'TwitterMessages.LBL_LIST_ORIGINAL_SCREEN_NAME', 'ORIGINAL_SCREEN_NAME'    , 'ORIGINAL_SCREEN_NAME'    , '10%', 'listViewTdLinkS1', 'ORIGINAL_SCREEN_NAME', 'http://twitter.com/{0}', 'TwitterUser', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'TwitterMessages.ArchiveView'   ,  8, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'        , 'ASSIGNED_TO_NAME'        , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'TwitterMessages.ArchiveView'   ,  9, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'               , 'TEAM_NAME'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'TwitterMessages.ArchiveView'   , 10, 'TwitterMessages.LBL_LIST_STATUS'              , 'STATUS'                  , 'STATUS'                  , '5%', 'dom_twitter_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'TwitterMessages.ArchiveView'   , 11, 'TwitterMessages.LBL_LIST_TYPE'                , 'TYPE_TERM'               , 'TYPE_TERM'               , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'TwitterMessages.ArchiveView'   , 12, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'ChatMessages.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS ChatMessages.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'ChatMessages.ArchiveView'      , 'ChatMessages', 'vwCHAT_MESSAGES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ChatMessages.ArchiveView'      ,  2, 'ChatMessages.LBL_LIST_NAME'                   , 'NAME'                    , 'NAME'                    , '33%', 'listViewTdLinkS1', 'ID'             , '~/ChatMessages/view.aspx?id={0}&ArchiveView=1', null, 'ChatMessages', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ChatMessages.ArchiveView'      ,  3, 'ChatMessages.LBL_LIST_PARENT_NAME'            , 'PARENT_NAME'             , 'PARENT_NAME'             , '15%', 'listViewTdLinkS1', 'PARENT_ID'      , '~/Parents/view.aspx?id={0}&ArchiveView=1'     , null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ChatMessages.ArchiveView'      ,  4, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'            , 'DATE_ENTERED'            , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ChatMessages.ArchiveView'      ,  5, '.LBL_LIST_CREATED_BY_NAME'                    , 'CREATED_BY_NAME'         , 'CREATED_BY_NAME'         , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'ChatMessages.ArchiveView'      ,  6, 'ChatMessages.LBL_LIST_CHAT_CHANNEL_NAME'      , 'CHAT_CHANNEL_NAME'       , 'CHAT_CHANNEL_NAME'       , '10%', 'listViewTdLinkS1', 'CHAT_CHANNEL_ID', '~/ChatChannels/view.aspx?id={0}&ArchiveView=1', null, 'ChatChannels', 'CHAT_CHANNEL_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'ChatMessages.ArchiveView'      ,  7, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'               , 'TEAM_NAME'               , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'ChatMessages.ArchiveView'      ,  8, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'        , 'ARCHIVE_DATE_UTC'        , '10%', 'Date';
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

call dbo.spGRIDVIEWS_COLUMNS_ArchiveViews()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_ArchiveViews')
/

-- #endif IBM_DB2 */

