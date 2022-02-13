

print 'GRIDVIEWS defaults';
GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
exec dbo.spGRIDVIEWS_InsertOnly 'Accounts.ListView'      , 'Accounts'      , 'vwACCOUNTS_List'      ;
exec dbo.spGRIDVIEWS_InsertOnly 'Activities.ListView'    , 'Activities'    , 'vwACTIVITIES_List'    ;
exec dbo.spGRIDVIEWS_InsertOnly 'Administration.ListView', 'Administration', 'vwADMINISTRATION_List';
exec dbo.spGRIDVIEWS_InsertOnly 'Bugs.ListView'          , 'Bugs'          , 'vwBUGS_List'          ;
exec dbo.spGRIDVIEWS_InsertOnly 'Calendar.ListView'      , 'Calendar'      , 'vwCALENDAR_List'      ;
exec dbo.spGRIDVIEWS_InsertOnly 'Calls.ListView'         , 'Calls'         , 'vwCALLS_List'         ;
exec dbo.spGRIDVIEWS_InsertOnly 'Campaigns.ListView'     , 'Campaigns'     , 'vwCAMPAIGNS_List'     ;
exec dbo.spGRIDVIEWS_InsertOnly 'Cases.ListView'         , 'Cases'         , 'vwCASES_List'         ;
exec dbo.spGRIDVIEWS_InsertOnly 'Contacts.ListView'      , 'Contacts'      , 'vwCONTACTS_List'      ;
exec dbo.spGRIDVIEWS_InsertOnly 'Dashboard.ListView'     , 'Dashboard'     , 'vwDASHBOARD_List'     ;
exec dbo.spGRIDVIEWS_InsertOnly 'Documents.ListView'     , 'Documents'     , 'vwDOCUMENTS_List'     ;
exec dbo.spGRIDVIEWS_InsertOnly 'Dropdown.ListView'      , 'Dropdown'      , 'vwDROPDOWN_List'      ;
exec dbo.spGRIDVIEWS_InsertOnly 'Emails.ListView'        , 'Emails'        , 'vwEMAILS_List'        ;
exec dbo.spGRIDVIEWS_InsertOnly 'EmailTemplates.ListView', 'EmailTemplates', 'vwEMAIL_TEMPLATES_List';
exec dbo.spGRIDVIEWS_InsertOnly 'Employees.ListView'     , 'Employees'     , 'vwEMPLOYEES_List'     ;
exec dbo.spGRIDVIEWS_InsertOnly 'Feeds.ListView'         , 'Feeds'         , 'vwFEEDS_List'         ;
exec dbo.spGRIDVIEWS_InsertOnly 'Home.ListView'          , 'Home'          , 'vwHOME_List'          ;
exec dbo.spGRIDVIEWS_InsertOnly 'iFrames.ListView'       , 'iFrames'       , 'vwIFRAMES_List'       ;
exec dbo.spGRIDVIEWS_InsertOnly 'Leads.ListView'         , 'Leads'         , 'vwLEADS_List'         ;
exec dbo.spGRIDVIEWS_InsertOnly 'Meetings.ListView'      , 'Meetings'      , 'vwMEETINGS_List'      ;
exec dbo.spGRIDVIEWS_InsertOnly 'Notes.ListView'         , 'Notes'         , 'vwNOTES_List'         ;
exec dbo.spGRIDVIEWS_InsertOnly 'Opportunities.ListView' , 'Opportunities' , 'vwOPPORTUNITIES_List' ;
-- 05/07/2006 Paul.  Fix view name.
exec dbo.spGRIDVIEWS_InsertOnly 'Project.ListView'       , 'Project'       , 'vwPROJECTS_List'      ;
-- 05/07/2006 Paul.  Fix module name. 
exec dbo.spGRIDVIEWS_InsertOnly 'ProjectTask.ListView'   , 'ProjectTask'   , 'vwPROJECT_TASKS_List' ;
exec dbo.spGRIDVIEWS_InsertOnly 'ProspectLists.ListView' , 'ProspectLists' , 'vwPROSPECT_LISTS_List';
exec dbo.spGRIDVIEWS_InsertOnly 'Prospects.ListView'     , 'Prospects'     , 'vwPROSPECTS_List'     ;
exec dbo.spGRIDVIEWS_InsertOnly 'Releases.ListView'      , 'Releases'      , 'vwRELEASES_List'      ;
exec dbo.spGRIDVIEWS_InsertOnly 'Tasks.ListView'         , 'Tasks'         , 'vwTASKS_List'         ;
exec dbo.spGRIDVIEWS_InsertOnly 'Users.ListView'         , 'Users'         , 'vwUSERS_List'         ;
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

call dbo.spGRIDVIEWS_Defaults()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_Defaults')
/

-- #endif IBM_DB2 */

