

print 'EDITVIEWS defaults';
--delete from EDITVIEWS
--GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 09/14/2008 Paul.  DB2 does not work well with optional parameters. 
exec dbo.spEDITVIEWS_InsertOnly 'Accounts.EditView'        , 'Accounts'        , 'vwACCOUNTS_Edit'       , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Activities.EditView'      , 'Activities'      , 'vwACTIVITIES_Edit'     , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Bugs.EditView'            , 'Bugs'            , 'vwBUGS_Edit'           , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Calendar.EditView'        , 'Calendar'        , 'vwCALENDAR_Edit'       , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Calls.EditView'           , 'Calls'           , 'vwCALLS_Edit'          , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Campaigns.EditView'       , 'Campaigns'       , 'vwCAMPAIGNS_Edit'      , '20%', '30%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Cases.EditView'           , 'Cases'           , 'vwCASES_Edit'          , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Contacts.EditView'        , 'Contacts'        , 'vwCONTACTS_Edit'       , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Dashboard.EditView'       , 'Dashboard'       , 'vwDASHBOARD_Edit'      , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Documents.EditView'       , 'Documents'       , 'vwDOCUMENTS_Edit'      , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Dropdown.EditView'        , 'Dropdown'        , 'vwDROPDOWN_Edit'       , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Emails.EditView'          , 'Emails'          , 'vwEMAILS_Edit'         , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'EmailTemplates.EditView'  , 'EmailTemplates'  , 'vwEMAIL_TEMPLATES_Edit', '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Employees.EditView'       , 'Employees'       , 'vwEMPLOYEES_Edit'      , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Feeds.EditView'           , 'Feeds'           , 'vwFEEDS_Edit'          , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Home.EditView'            , 'Home'            , 'vwHOME_Edit'           , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'iFrames.EditView'         , 'iFrames'         , 'vwIFRAMES_Edit'        , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Leads.EditView'           , 'Leads'           , 'vwLEADS_Edit'          , '20%', '30%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Meetings.EditView'        , 'Meetings'        , 'vwMEETINGS_Edit'       , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Notes.EditView'           , 'Notes'           , 'vwNOTES_Edit'          , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Opportunities.EditView'   , 'Opportunities'   , 'vwOPPORTUNITIES_Edit'  , '20%', '30%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Project.EditView'         , 'Project'         , 'vwPROJECTS_Edit'       , '20%', '30%', null;
exec dbo.spEDITVIEWS_InsertOnly 'ProjectTask.EditView'     , 'ProjectTask'     , 'vwPROJECT_TASKS_Edit'  , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'ProspectLists.EditView'   , 'ProspectLists'   , 'vwPROSPECT_LISTS_Edit' , '20%', '30%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Prospects.EditView'       , 'Prospects'       , 'vwPROSPECTS_Edit'      , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Releases.EditView'        , 'Releases'        , 'vwRELEASES_Edit'       , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Tasks.EditView'           , 'Tasks'           , 'vwTASKS_Edit'          , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'Users.EditView'           , 'Users'           , 'vwUSERS_Edit'          , '15%', '35%', null;
-- 07/08/2007 Paul.  Add CampaignTrackers and EmailMarketing modules. 
exec dbo.spEDITVIEWS_InsertOnly 'CampaignTrackers.EditView', 'CampaignTrackers', 'vwCAMPAIGN_TRKRS_Edit' , '15%', '35%', null;
exec dbo.spEDITVIEWS_InsertOnly 'EmailMarketing.EditView'  , 'EmailMarketing'  , 'vwEMAIL_MARKETING_Edit', '15%', '35%', null;
-- 08/28/2012 Paul.  Add Call Marketing. 
exec dbo.spEDITVIEWS_InsertOnly 'CallMarketing.EditView'   , 'CallMarketing'   , 'vwCALL_MARKETING_Edit' , '15%', '35%', null;
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

call dbo.spEDITVIEWS_Defaults()
/

call dbo.spSqlDropProcedure('spEDITVIEWS_Defaults')
/

-- #endif IBM_DB2 */

