

print 'MODULES_GROUPS defaults';
GO

set nocount on;
GO

-- 02/24/2010 Paul.  We need to specify an order to the modules for the tab menu. 
if exists(select * from MODULES_GROUPS where MODULE_ORDER is null and DELETED = 0) begin -- then
	update MODULES_GROUPS
	   set DELETED           = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where MODULE_ORDER is null
	   and DELETED           = 0;
end -- if;

-- 02/24/2010 Paul.  We need to specify an order to the modules for the tab menu. 
exec dbo.spMODULES_GROUPS_InsertOnly 'Home'         , 'Home'            ,  1, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Home'         , 'Dashboard'       ,  2, 1;

-- LBL_TABGROUP_SALES
exec dbo.spMODULES_GROUPS_InsertOnly 'Sales'        , 'Accounts'        ,  1, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Sales'        , 'Opportunities'   ,  2, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Sales'        , 'Leads'           ,  3, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Sales'        , 'Contacts'        ,  4, 1;

-- LBL_TABGROUP_MARKETING
exec dbo.spMODULES_GROUPS_InsertOnly 'Marketing'    , 'Campaigns'       ,  1, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Marketing'    , 'Contacts'        ,  2, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Marketing'    , 'Accounts'        ,  3, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Marketing'    , 'Leads'           ,  4, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Marketing'    , 'CampaignTrackers',  5, 0;
exec dbo.spMODULES_GROUPS_InsertOnly 'Marketing'    , 'EmailMarketing'  ,  6, 0;
-- 01/09/2009 Paul.  Prospects are in the marketing group. 
exec dbo.spMODULES_GROUPS_InsertOnly 'Marketing'    , 'Prospects'       ,  7, 0;
exec dbo.spMODULES_GROUPS_InsertOnly 'Marketing'    , 'ProspectLists'   ,  8, 0;
-- 08/28/2012 Paul.  Add Call Marketing. 
exec dbo.spMODULES_GROUPS_InsertOnly 'Marketing'    , 'CallMarketing'   ,  9, 0;

-- LBL_TABGROUP_SUPPORT
exec dbo.spMODULES_GROUPS_InsertOnly 'Support'      , 'Cases'           ,  1, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Support'      , 'Accounts'        ,  2, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Support'      , 'Contacts'        ,  3, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Support'      , 'Bugs'            ,  4, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Support'      , 'Products'        ,  5, 0;

-- LBL_TABGROUP_ACTIVITIES
exec dbo.spMODULES_GROUPS_InsertOnly 'Activities'   , 'Activities'      ,  1, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Activities'   , 'Open'            ,  2, 0;
exec dbo.spMODULES_GROUPS_InsertOnly 'Activities'   , 'History'         ,  3, 0;
exec dbo.spMODULES_GROUPS_InsertOnly 'Activities'   , 'Calendar'        ,  4, 1;
-- 02/24/2010 Paul.  Disable Emails from Activites tab so that it can appear in the Collaboration tab. 
exec dbo.spMODULES_GROUPS_InsertOnly 'Activities'   , 'Emails'          ,  5, 0;
exec dbo.spMODULES_GROUPS_InsertOnly 'Activities'   , 'Calls'           ,  6, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Activities'   , 'Meetings'        ,  7, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Activities'   , 'Tasks'           ,  8, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Activities'   , 'Notes'           ,  9, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Activities'   , 'EmailTemplates'  , 10, 0;

-- LBL_TABGROUP_COLLABORATION
exec dbo.spMODULES_GROUPS_InsertOnly 'Collaboration', 'Emails'          ,  1, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Collaboration', 'Project'         ,  2, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Collaboration', 'Documents'       ,  3, 1;

-- LBL_TABGROUP_TOOLS
exec dbo.spMODULES_GROUPS_InsertOnly 'Tools'        , 'Feeds'           ,  1, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Tools'        , 'iFrames'         ,  2, 1;

-- LBL_TABGROUP_REPORTS
exec dbo.spMODULES_GROUPS_InsertOnly 'Reports'      , 'Dashboard'       ,  2, 1;

-- LBL_TABGROUP_OTHER
exec dbo.spMODULES_GROUPS_InsertOnly 'Other'        , 'Documents'       ,  1, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Other'        , 'Notes'           ,  2, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Other'        , 'Users'           ,  3, 1;
exec dbo.spMODULES_GROUPS_InsertOnly 'Other'        , 'ProjectTask'     ,  4, 1;
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

call dbo.spMODULES_GROUPS_Defaults()
/

call dbo.spSqlDropProcedure('spMODULES_GROUPS_Defaults')
/

-- #endif IBM_DB2 */

