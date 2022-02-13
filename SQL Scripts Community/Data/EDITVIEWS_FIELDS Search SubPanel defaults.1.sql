

print 'EDITVIEWS_FIELDS Search SubPanel defaults';
-- delete from EDITVIEWS_FIELDS where EDIT_NAME like '%.SearchSubpanel'
--GO

set nocount on;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Activities.SearchSubpanel';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Activities.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Activities.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'Activities.SearchSubpanel'  , 'Activities', 'vwACTIVITIES', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Activities.SearchSubpanel'  ,  0, 'Calls.LBL_SUBJECT'                      , 'ACTIVITY_NAME'               , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Activities.SearchSubpanel'  ,  1, null;
end -- if;
GO

-- 04/20/2020 Paul.  ActivitiesOpen and ActivitiesHistory need to have a different EDIT_NAME as it is used in the ID. 
-- Most relationship panels have both Open and History, so we need to ensure that unqiue IDs are generated. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Activities.SearchSubpanelHistory';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Activities.SearchSubpanelHistory' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Activities.SearchSubpanelHistory';
	exec dbo.spEDITVIEWS_InsertOnly             'Activities.SearchSubpanelHistory'  , 'Activities', 'vwACTIVITIES', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Activities.SearchSubpanelHistory'  ,  0, 'Calls.LBL_SUBJECT'                      , 'ACTIVITY_NAME'               , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Activities.SearchSubpanelHistory'  ,  1, null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Accounts.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Accounts.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'Accounts.SearchSubpanel'    , 'Accounts', 'vwACCOUNTS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Accounts.SearchSubpanel'    ,  0, 'Accounts.LBL_ACCOUNT_NAME'              , 'NAME'                       , 0, null, 150, 25, 'Accounts', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Accounts.SearchSubpanel'    ,  1, null;
end -- if;
GO

-- 09/22/2010 Paul.  Fix edit name to remove Bugs.SearchAdvanced. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Bugs.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Bugs.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'Bugs.SearchSubpanel'        , 'Bugs', 'vwBUGS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Bugs.SearchSubpanel'        ,  0, 'Bugs.LBL_SUBJECT'                       , 'NAME'                       , 0, null, 150, 25, 'Bugs', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Bugs.SearchSubpanel'        ,  1, 'Bugs.LBL_STATUS'                        , 'STATUS'                     , 0, null, 'bug_status_dom'      , null, 6;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Calls.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Calls.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'Calls.SearchSubpanel'       , 'Calls', 'vwCALLS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Calls.SearchSubpanel'       ,  0, 'Calls.LBL_SUBJECT'                      , 'NAME'                       , 0, null, 150, 25, 'Calls'   , null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Calls.SearchSubpanel'       ,  1, 'Calls.LBL_STATUS'                       , 'STATUS'                     , 0, null, 'call_status_dom'     , null, 6;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Cases.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Cases.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'Cases.SearchSubpanel'       , 'Cases', 'vwCASES_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Cases.SearchSubpanel'       ,  0, 'Cases.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Cases', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Cases.SearchSubpanel'       ,  1, 'Cases.LBL_STATUS'                       , 'STATUS'                     , 0, null, 'case_status_dom'  , null, 6;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Contacts.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Contacts.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'Contacts.SearchSubpanel'    , 'Contacts', 'vwCONTACTS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchSubpanel'    ,  0, 'Contacts.LBL_FIRST_NAME'                , 'FIRST_NAME'                 , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Contacts.SearchSubpanel'    ,  1, 'Contacts.LBL_LAST_NAME'                 , 'LAST_NAME'                  , 0, null,  25, 25, null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Documents.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Documents.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'Documents.SearchSubpanel'   , 'Documents', 'vwDOCUMENTS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Documents.SearchSubpanel'   ,  0, 'Documents.LBL_SF_DOCUMENT'              , 'DOCUMENT_NAME'              , 0, null, 255, 25, 'Documents', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Documents.SearchSubpanel'   ,  1, null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Emails.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Emails.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'Emails.SearchSubpanel'      , 'Emails', 'vwEMAILS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Emails.SearchSubpanel'      ,  0, 'Emails.LBL_SUBJECT'                     , 'NAME'                       , 0, null,  50, 25, 'Emails'  , null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Emails.SearchSubpanel'      ,  1, null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Leads.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Leads.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'Leads.SearchSubpanel'       , 'Leads', 'vwLEADS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchSubpanel'       ,  0, 'Leads.LBL_FIRST_NAME'                   , 'FIRST_NAME'                 , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Leads.SearchSubpanel'       ,  1, 'Leads.LBL_LAST_NAME'                    , 'LAST_NAME'                  , 0, null,  25, 25, null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Meetings.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Meetings.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'Meetings.SearchSubpanel'    , 'Meetings', 'vwMEETINGS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Meetings.SearchSubpanel'    ,  0, 'Meetings.LBL_SUBJECT'                   , 'NAME'                       , 0, null, 150, 25, 'Meetings', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Meetings.SearchSubpanel'    ,  1, 'Meetings.LBL_STATUS'                    , 'STATUS'                     , 0, null, 'call_status_dom'     , null, 6;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Notes.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Notes.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'Notes.SearchSubpanel'       , 'Notes', 'vwNOTES_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Notes.SearchSubpanel'       ,  0, 'Notes.LBL_SUBJECT'                      , 'NAME'                       , 0, null, 150, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Notes.SearchSubpanel'       ,  1, null;
end -- if;
GO

-- 10/07/2010 Paul.  Increase size of NAME field. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'Opportunities.SearchSubpanel', 'Opportunities' , 'vwOPPORTUNITIES_Edit' , '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Opportunities.SearchSubpanel',  0, 'Opportunities.LBL_OPPORTUNITY_NAME'    , 'NAME'                       , 0, null, 150, 25, 'Opportunities', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.SearchSubpanel',  1, 'Opportunities.LBL_SALES_STAGE'         , 'SALES_STAGE'                , 0, null, 'sales_stage_dom'     , null, 6;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Project.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Project.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'Project.SearchSubpanel'     , 'Project', 'vwPROJECTS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Project.SearchSubpanel'     ,  0, 'Project.LBL_NAME'                       , 'NAME'                       , 0, null, 100, 25, 'Project', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Project.SearchSubpanel'     ,  1, 'Project.LBL_STATUS'                     , 'STATUS'                     , 0, null, 'project_status_dom'       , null, 6;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'ProjectTask.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS ProjectTask.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'ProjectTask.SearchSubpanel' , 'ProjectTask', 'vwPROJECT_TASKS_List', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'ProjectTask.SearchSubpanel' ,  0, 'ProjectTask.LBL_NAME'                   , 'NAME'                       , 0, null, 100, 25, 'ProjectTask', null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'ProjectTask.SearchSubpanel' ,  1, null;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Prospects.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Prospects.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'Prospects.SearchSubpanel'   , 'Prospects', 'vwPROSPECTS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchSubpanel'   ,  0, 'Prospects.LBL_FIRST_NAME'               , 'FIRST_NAME'                 , 0, null,  25, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Prospects.SearchSubpanel'   ,  1, 'Prospects.LBL_LAST_NAME'                , 'LAST_NAME'                  , 0, null,  25, 25, null;
end -- if;
GO

-- 03/05/2011 Paul.  The list needs to allow multi-select, otherwise it will filter by the top status value. 
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.SearchSubpanel' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Tasks.SearchSubpanel';
	exec dbo.spEDITVIEWS_InsertOnly             'Tasks.SearchSubpanel'       , 'Tasks', 'vwTASKS_List', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsAutoComplete 'Tasks.SearchSubpanel'       ,  0, 'Tasks.LBL_SUBJECT'                      , 'NAME'                       , 0, null,  50, 25, 'Tasks'   , null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Tasks.SearchSubpanel'       ,  1, 'Tasks.LBL_STATUS'                       , 'STATUS'                     , 0, null, 'task_status_dom'     , null, 6;
end else begin
	if exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Tasks.SearchSubpanel' and DATA_FIELD = 'STATUS' and FORMAT_ROWS is null and DELETED = 0) begin -- then
		update EDITVIEWS_FIELDS
		   set FORMAT_ROWS       = 6
		     , DATE_MODIFIED     = getdate()
		     , DATE_MODIFIED_UTC = getutcdate()
		     , MODIFIED_USER_ID  = null
		 where EDIT_NAME         = 'Tasks.SearchSubpanel'
		   and DATA_FIELD        = 'STATUS'
		   and FORMAT_ROWS is null
		   and DELETED           = 0;
	end -- if;
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

call dbo.spEDITVIEWS_FIELDS_SearchSubPanelDefaults()
/

call dbo.spSqlDropProcedure('spEDITVIEWS_FIELDS_SearchSubPanelDefaults')
/

-- #endif IBM_DB2 */

