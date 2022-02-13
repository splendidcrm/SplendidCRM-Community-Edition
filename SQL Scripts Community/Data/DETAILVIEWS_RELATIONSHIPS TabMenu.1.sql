

print 'DETAILVIEWS_RELATIONSHIPS TabMenu';
--delete from DETAILVIEWS_RELATIONSHIPS
--GO

set nocount on;
GO

-- 10/13/2012 Paul.  Add table info for HTML5 Offline Client. 
-- 02/23/2013 Paul.  Add Calendar for HTML5 Offline Client. 
-- 03/08/2016 Paul.  Move Quotes, Orders and Invoices to separate file so that this file can be included in Community build. 
-- 05/09/2017 Paul.  Add HTML5 Dashboard. 
-- 06/14/2017 Paul.  Add Home/My Dashboard. 
-- 07/25/2017 Paul.  Make sure to insert Accounts, Contacts and Leads. 
-- delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'TabMenu';
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'TabMenu' and MODULE_NAME = 'Accounts' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS TabMenu';
	exec dbo.spDETAILVIEWS_InsertOnly               'TabMenu'       , 'Home'              , 'vwHOME_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'Home'             , '~/Home/default'                     ,  0, 'Home.LBL_LIST_FORM_TITLE'         , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'Accounts'         , '~/Accounts/SearchAccounts'          ,  1, 'Accounts.LBL_LIST_FORM_TITLE'     , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'Contacts'         , '~/Contacts/SearchContacts'          ,  2, 'Contacts.LBL_LIST_FORM_TITLE'     , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'Leads'            , '~/Leads/SearchLeads'                ,  3, 'Leads.LBL_LIST_FORM_TITLE'        , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'Opportunities'    , '~/Opportunities/SearchOpportunities',  4, 'Opportunities.LBL_LIST_FORM_TITLE', null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'Calendar'         , '~/Calendar/html5/default'           ,  5, 'Calendar.LBL_LIST_FORM_TITLE'     , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'Bugs'             , '~/Bugs/SearchBugs'                  ,  6, 'Cases.LBL_LIST_FORM_TITLE'        , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'Cases'            , '~/Cases/SearchCases'                ,  7, 'Cases.LBL_LIST_FORM_TITLE'        , null, null, null, null;
--	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'Tasks'            , '~/Tasks/SearchTasks'                ,  8, 'Tasks.LBL_LIST_FORM_TITLE'        , null, null, null, null;
--	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'Project'          , '~/Projects/SearchProjects'          ,  9, 'Projects.LBL_LIST_FORM_TITLE'     , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'ChatDashboard'    , '~/ChatDashboard/default'            , 11, 'ChatDashboard.LBL_LIST_FORM_TITLE', null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'Dashboard'        , '~/Dashboard/default'                , 12, 'Dashboard.LBL_LIST_FORM_TITLE'    , null, null, null, null;
end else begin
	-- 02/23/2013 Paul.  Add Calendar for HTML5 Offline Client. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'TabMenu' and MODULE_NAME = 'Calendar' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'TabMenu'
		   and RELATIONSHIP_ORDER > 3
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'Calendar'         , '~/Calendar/html5/default'           ,  4, 'Calendar.LBL_LIST_FORM_TITLE'     , null, null, null, null;
	end -- if;
	-- 11/24/2014 Paul.  Add ChatDashboard. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'TabMenu' and MODULE_NAME = 'ChatDashboard' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'TabMenu'
		   and RELATIONSHIP_ORDER >= 11
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'ChatDashboard'    , '~/ChatDashboard/default'            , 11, 'ChatDashboard.LBL_LIST_FORM_TITLE', null, null, null, null;
	end -- if;
	-- 05/09/2017 Paul.  Add Dashboard. 
	-- select * from vwDETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'TabMenu' order by RELATIONSHIP_ORDER;
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'TabMenu' and MODULE_NAME = 'Dashboard' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'TabMenu'
		   and RELATIONSHIP_ORDER >= 12
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'Dashboard'        , '~/Dashboard/default'                , 12, 'Dashboard.LBL_LIST_FORM_TITLE'    , null, null, null, null;
	end -- if;
	-- 06/14/2017 Paul.  Add Home/My Dashboard. 
	if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'TabMenu' and MODULE_NAME = 'Home' and DELETED = 0) begin -- then
		update DETAILVIEWS_RELATIONSHIPS
		   set RELATIONSHIP_ORDER = RELATIONSHIP_ORDER + 1
		     , DATE_MODIFIED      = getdate()
		     , DATE_MODIFIED_UTC  = getutcdate()
		     , MODIFIED_USER_ID   = null
		 where DETAIL_NAME        = 'TabMenu'
		   and DELETED            = 0;
		exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu'       , 'Home'             , '~/Home/default'                     ,  0, 'Home.LBL_LIST_FORM_TITLE'         , null, null, null, null;
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

call dbo.spDETAILVIEWS_RELATIONSHIPS_TabMenu()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_RELATIONSHIPS_TabMenu')
/

-- #endif IBM_DB2 */

