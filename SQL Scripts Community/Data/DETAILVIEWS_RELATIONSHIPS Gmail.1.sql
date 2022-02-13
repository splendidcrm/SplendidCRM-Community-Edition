

print 'DETAILVIEWS_RELATIONSHIPS Gmail';
--delete from DETAILVIEWS_RELATIONSHIPS
--GO

set nocount on;
GO

-- 10/13/2012 Paul.  Add table info for HTML5 Offline Client. 
-- delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'TabMenu.Gmail';
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'TabMenu.Gmail' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS TabMenu.Gmail';
	exec dbo.spDETAILVIEWS_InsertOnly               'TabMenu.Gmail'       , 'Home'              , 'vwHOME_Edit', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu.Gmail'       , 'Accounts'         , '~/Accounts/SearchAccounts'          ,  0, 'Accounts.LBL_LIST_FORM_TITLE'     , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu.Gmail'       , 'Contacts'         , '~/Contacts/SearchContacts'          ,  1, 'Contacts.LBL_LIST_FORM_TITLE'     , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu.Gmail'       , 'Leads'            , '~/Leads/SearchLeads'                ,  2, 'Leads.LBL_LIST_FORM_TITLE'        , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu.Gmail'       , 'Opportunities'    , '~/Opportunities/SearchOpportunities',  3, 'Opportunities.LBL_LIST_FORM_TITLE', null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu.Gmail'       , 'Bugs'             , '~/Bugs/SearchBugs'                  ,  4, 'Cases.LBL_LIST_FORM_TITLE'        , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu.Gmail'       , 'Cases'            , '~/Cases/SearchCases'                ,  5, 'Cases.LBL_LIST_FORM_TITLE'        , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu.Gmail'       , 'Quotes'           , '~/Quotes/SearchQuotes'              ,  6, 'Quotes.LBL_LIST_FORM_TITLE'       , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu.Gmail'       , 'Orders'           , '~/Orders/SearchOrders'              ,  7, 'Orders.LBL_LIST_FORM_TITLE'       , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu.Gmail'       , 'Invoices'         , '~/Invoices/SearchInvoices'          ,  8, 'Invoices.LBL_LIST_FORM_TITLE'     , null, null, null, null;
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu.Gmail'       , 'Contracts'        , '~/Contracts/SearchContracts'        ,  9, 'Contracts.LBL_LIST_FORM_TITLE'    , null, null, null, null;
--	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'TabMenu.Gmail'       , 'Project'          , '~/Projects/SearchProjects'          , 10, 'Projects.LBL_LIST_FORM_TITLE'     , null, null, null, null;
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

call dbo.spDETAILVIEWS_RELATIONSHIPS_Gmail()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_RELATIONSHIPS_Gmail')
/

-- #endif IBM_DB2 */

