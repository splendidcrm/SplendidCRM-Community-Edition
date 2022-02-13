

print 'DETAILVIEWS defaults';
--delete from DETAILVIEWS
--GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 09/14/2008 Paul.  DB2 does not work well with optional parameters. 
exec dbo.spDETAILVIEWS_InsertOnly 'Accounts.DetailView'        , 'Accounts'        , 'vwACCOUNTS_Edit'       , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Activities.DetailView'      , 'Activities'      , 'vwACTIVITIES_Edit'     , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Bugs.DetailView'            , 'Bugs'            , 'vwBUGS_Edit'           , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Calendar.DetailView'        , 'Calendar'        , 'vwCALENDAR_Edit'       , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Calls.DetailView'           , 'Calls'           , 'vwCALLS_Edit'          , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Campaigns.DetailView'       , 'Campaigns'       , 'vwCAMPAIGNS_Edit'      , '20%', '30%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Cases.DetailView'           , 'Cases'           , 'vwCASES_Edit'          , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Contacts.DetailView'        , 'Contacts'        , 'vwCONTACTS_Edit'       , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Dashboard.DetailView'       , 'Dashboard'       , 'vwDASHBOARD_Edit'      , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Documents.DetailView'       , 'Documents'       , 'vwDOCUMENTS_Edit'      , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Dropdown.DetailView'        , 'Dropdown'        , 'vwDROPDOWN_Edit'       , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Emails.DetailView'          , 'Emails'          , 'vwEMAILS_Edit'         , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'EmailTemplates.DetailView'  , 'EmailTemplates'  , 'vwEMAIL_TEMPLATES_Edit', '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Employees.DetailView'       , 'Employees'       , 'vwEMPLOYEES_Edit'      , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Feeds.DetailView'           , 'Feeds'           , 'vwFEEDS_Edit'          , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Home.DetailView'            , 'Home'            , 'vwHOME_Edit'           , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'iFrames.DetailView'         , 'iFrames'         , 'vwIFRAMES_Edit'        , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Leads.DetailView'           , 'Leads'           , 'vwLEADS_Edit'          , '20%', '30%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Meetings.DetailView'        , 'Meetings'        , 'vwMEETINGS_Edit'       , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Notes.DetailView'           , 'Notes'           , 'vwNOTES_Edit'          , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Opportunities.DetailView'   , 'Opportunities'   , 'vwOPPORTUNITIES_Edit'  , '20%', '30%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Project.DetailView'         , 'Project'         , 'vwPROJECTS_Edit'       , '20%', '20%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'ProjectTask.DetailView'     , 'ProjectTask'     , 'vwPROJECT_TASKS_Edit'  , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'ProspectLists.DetailView'   , 'ProspectLists'   , 'vwPROSPECT_LISTS_Edit' , '20%', '30%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Prospects.DetailView'       , 'Prospects'       , 'vwPROSPECTS_Edit'      , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Releases.DetailView'        , 'Releases'        , 'vwRELEASES_Edit'       , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Tasks.DetailView'           , 'Tasks'           , 'vwTASKS_Edit'          , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Users.DetailView'           , 'Users'           , 'vwUSERS_Edit'          , '15%', '35%', null;
-- 07/08/2007 Paul.  Add CampaignTrackers and EmailMarketing modules. 
exec dbo.spDETAILVIEWS_InsertOnly 'CampaignTrackers.DetailView', 'CampaignTrackers', 'vwCAMPAIGN_TRKRS_Edit' , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'EmailMarketing.DetailView'  , 'EmailMarketing'  , 'vwEMAIL_MARKETING_Edit', '15%', '35%', null;
-- 08/28/2012 Paul.  Add Call Marketing. 
exec dbo.spDETAILVIEWS_InsertOnly 'CallMarketing.DetailView'   , 'CallMarketing'   , 'vwCALL_MARKETING_Edit' , '15%', '35%', null;
-- 04/06/2011 Paul.  Add the home views as a precaution. 
exec dbo.spDETAILVIEWS_InsertOnly 'Home.UnifiedSearch'         , 'Home'            , 'vwHOME_Edit'           , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Home.DetailView.Left'       , 'Home'            , 'vwHOME_Edit'           , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Home.DetailView.Body'       , 'Home'            , 'vwHOME_Edit'           , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Home.DetailView.Right'      , 'Home'            , 'vwHOME_Edit'           , '15%', '35%', null;
exec dbo.spDETAILVIEWS_InsertOnly 'Dashboard.DetailView'       , 'Dashboard'       , 'vwDASHBOARD_Edit'      , '15%', '35%', null;
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

call dbo.spDETAILVIEWS_Defaults()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_Defaults')
/

-- #endif IBM_DB2 */

