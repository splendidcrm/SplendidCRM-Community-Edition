

print 'DETAILVIEWS_RELATIONSHIPS ArchiveView Professional';
set nocount on;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Accounts.ArchiveView' and MODULE_NAME in ('Quotes', 'Invoices', 'Orders') and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Accounts.ArchiveView Professional';
--	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.ArchiveView'      , 'Activities'       , 'ActivitiesHistory'  ,  0, 'Activities.LBL_HISTORY'           , 'vwACCOUNTS_ACTIVITIES_ARCHIVE'     , 'ACCOUNT_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.ArchiveView'      , 'Products'         , 'Products'           , -1, 'Products.LBL_MODULE_NAME'         , 'vwACCOUNTS_PRODUCTS_ARCHIVE'       , 'ACCOUNT_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.ArchiveView'      , 'Quotes'           , 'Quotes'             , -1, 'Quotes.LBL_MODULE_NAME'           , 'vwACCOUNTS_QUOTES_ARCHIVE'         , 'ACCOUNT_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.ArchiveView'      , 'Contracts'        , 'Contracts'          , -1, 'Contracts.LBL_MODULE_NAME'        , 'vwACCOUNTS_CONTRACTS_ARCHIVE'      , 'ACCOUNT_ID', 'CONTRACT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.ArchiveView'      , 'Invoices'         , 'Invoices'           , -1, 'Invoices.LBL_MODULE_NAME'         , 'vwACCOUNTS_INVOICES_ARCHIVE'       , 'ACCOUNT_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.ArchiveView'      , 'Payments'         , 'Payments'           , -1, 'Payments.LBL_MODULE_NAME'         , 'vwACCOUNTS_PAYMENTS_ARCHIVE'       , 'ACCOUNT_ID', 'DATE_ENTERED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.ArchiveView'      , 'Orders'           , 'Orders'             , -1, 'Orders.LBL_MODULE_NAME'           , 'vwACCOUNTS_ORDERS_ARCHIVE'         , 'ACCOUNT_ID', 'DATE_ENTERED', 'desc';
end -- if;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Cases.ArchiveView' and MODULE_NAME = 'KBDocuments' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Cases.ArchiveView Professional';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Cases.ArchiveView'         , 'KBDocuments'      , 'KBDocuments'        , -1, 'KBDocuments.LBL_MODULE_NAME'      , 'vwCASES_KBDOCUMENTS_ARCHIVE'       , 'CASE_ID', 'DATE_ENTERED', 'desc';
end -- if;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'KBDocuments.ArchiveView' and MODULE_NAME = 'Cases' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS KBDocuments.ArchiveView Professional';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'KBDocuments.ArchiveView'   , 'Cases'            , 'Cases'              ,  1, 'Cases.LBL_MODULE_NAME'            , 'vwKBDOCUMENTS_CASES_ARCHIVE'       , 'KBDOCUMENT_ID', 'DATE_ENTERED', 'desc';
end -- if;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Contacts.ArchiveView' and MODULE_NAME in ('Quotes') and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Contacts.ArchiveView Professional';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.ArchiveView'      , 'Quotes'           , 'Quotes'             , -1, 'Quotes.LBL_MODULE_NAME'           , 'vwCONTACTS_QUOTES_ARCHIVE'         , 'CONTACT_ID', 'DATE_ENTERED'    , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.ArchiveView'      , 'Invoices'         , 'Invoices'           , -1, 'Invoices.LBL_MODULE_NAME'         , 'vwCONTACTS_INVOICES_ARCHIVE'       , 'CONTACT_ID', 'DATE_ENTERED'    , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.ArchiveView'      , 'Orders'           , 'Orders'             , -1, 'Orders.LBL_MODULE_NAME'           , 'vwCONTACTS_ORDERS_ARCHIVE'         , 'CONTACT_ID', 'DATE_ENTERED'    , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contacts.ArchiveView'      , 'Contracts'        , 'Contracts'          , -1, 'Contracts.LBL_MODULE_NAME'        , 'vwCONTACTS_CONTRACTS_ARCHIVE'      , 'CONTACT_ID', 'CONTRACT_NAME'   , 'asc';
	-- 06/14/2016 Paul.  Add Contracts but disable. 
	update DETAILVIEWS_RELATIONSHIPS
	   set RELATIONSHIP_ENABLED = 0
	 where DETAIL_NAME          = 'Contacts.ArchiveView'
	   and MODULE_NAME          = 'Contracts'
	   and DELETED              = 0;
end -- if;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Emails.ArchiveView' and MODULE_NAME = 'Quotes' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Emails.ArchiveView Professional';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Emails.ArchiveView'        , 'Quotes'           , 'Quotes'             , -1, 'Quotes.LBL_MODULE_NAME'           , 'vwEMAILS_QUOTES_ARCHIVE'           , 'EMAIL_ID', 'DATE_ENTERED', 'desc';
end -- if;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Opportunities.ArchiveView' and MODULE_NAME in ('Quotes', 'Contracts') and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Opportunities.ArchiveView Professional';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.ArchiveView' , 'Quotes'           , 'Quotes'             , -1, 'Quotes.LBL_MODULE_NAME'           , 'vwOPPORTUNITIES_QUOTES_ARCHIVE'    , 'OPPORTUNITY_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Opportunities.ArchiveView' , 'Contracts'        , 'Contracts'          , -1, 'Contracts.LBL_MODULE_NAME'        , 'vwOPPORTUNITIES_CONTRACTS_ARCHIVE' , 'OPPORTUNITY_ID', 'CONTRACT_NAME', 'asc';
end -- if;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Project.ArchiveView' and MODULE_NAME in ('Quotes') and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Project.ArchiveView Professional';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Project.ArchiveView'       , 'Quotes'           , 'Quotes'             , -1, 'Quotes.LBL_MODULE_NAME'           , 'vwPROJECTS_QUOTES_ARCHIVE'         , 'PROJECT_ID', 'DATE_ENTERED', 'desc';
end -- if;
GO

-- 01/27/2020 Paul.  Early state had missing sort fields that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Contracts.ArchiveView' and CONTROL_NAME = 'ActivitiesHistory' and SORT_FIELD is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Contracts.ArchiveView';
end -- if;
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Contracts.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Contracts.ArchiveView Professional';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contracts.ArchiveView'     , 'Activities'       , 'ActivitiesHistory'  ,  0, 'Activities.LBL_HISTORY'           , 'vwCONTRACTS_ACTIVITIES_ARCHIVE'    , 'CONTRACT_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contracts.ArchiveView'     , 'Documents'        , 'Documents'          ,  1, 'Documents.LBL_MODULE_NAME'        , 'vwCONTRACTS_DOCUMENTS_ARCHIVE'     , 'CONTRACT_ID', 'DOCUMENT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contracts.ArchiveView'     , 'Notes'            , 'Notes'              ,  2, 'Notes.LBL_MODULE_NAME'            , 'vwCONTRACTS_NOTES_ARCHIVE'         , 'CONTRACT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contracts.ArchiveView'     , 'Contacts'         , 'Contacts'           ,  3, 'Contacts.LBL_MODULE_NAME'         , 'vwCONTRACTS_CONTACTS_ARCHIVE'      , 'CONTRACT_ID', 'CONTACT_NAME' , 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contracts.ArchiveView'     , 'Products'         , 'Products'           ,  4, 'Products.LBL_MODULE_NAME'         , 'vwCONTRACTS_PRODUCTS_ARCHIVE'      , 'CONTRACT_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Contracts.ArchiveView'     , 'Quotes'           , 'Quotes'             ,  5, 'Quotes.LBL_MODULE_NAME'           , 'vwCONTRACTS_QUOTES_ARCHIVE'        , 'CONTRACT_ID', 'DATE_ENTERED' , 'desc';
end -- if;
GO

-- 01/27/2020 Paul.  Early state had missing sort fields that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Quotes.ArchiveView' and CONTROL_NAME = 'ActivitiesHistory' and SORT_FIELD is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Quotes.ArchiveView';
end -- if;
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Quotes.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Quotes.ArchiveView Professional';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Quotes.ArchiveView'        , 'Activities'       , 'ActivitiesHistory'  ,  0, 'Activities.LBL_HISTORY'           , 'vwQUOTES_ACTIVITIES_ARCHIVE'       , 'QUOTE_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Quotes.ArchiveView'        , 'Project'          , 'Projects'           ,  1, 'Project.LBL_MODULE_NAME'          , 'vwQUOTES_PROJECTS_ARCHIVE'         , 'QUOTE_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Quotes.ArchiveView'        , 'Contracts'        , 'Contracts'          ,  2, 'Contracts.LBL_MODULE_NAME'        , 'vwQUOTES_CONTRACTS_ARCHIVE'        , 'QUOTE_ID', 'CONTRACT_NAME', 'asc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Quotes.ArchiveView'        , 'Orders'           , 'Orders'             ,  3, 'Orders.LBL_MODULE_NAME'           , 'vwQUOTES_ORDERS_ARCHIVE'           , 'QUOTE_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Quotes.ArchiveView'        , 'Invoices'         , 'Invoices'           ,  4, 'Invoices.LBL_MODULE_NAME'         , 'vwQUOTES_INVOICES_ARCHIVE'         , 'QUOTE_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Quotes.ArchiveView'        , 'Cases'            , 'Cases'              ,  5, 'Cases.LBL_MODULE_NAME'            , 'vwQUOTES_CASES_ARCHIVE'            , 'QUOTE_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Quotes.ArchiveView'        , 'Documents'        , 'Documents'          ,  6, 'Documents.LBL_MODULE_NAME'        , 'vwQUOTES_DOCUMENTS_ARCHIVE'        , 'QUOTE_ID', 'DOCUMENT_NAME', 'asc';
end -- if;
GO

-- 01/27/2020 Paul.  Early state had missing sort fields that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Orders.ArchiveView' and CONTROL_NAME = 'ActivitiesHistory' and SORT_FIELD is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Orders.ArchiveView';
end -- if;
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Orders.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Orders.ArchiveView Professional';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Orders.ArchiveView'        , 'Activities'       , 'ActivitiesHistory'  ,  0, 'Activities.LBL_HISTORY'           , 'vwORDERS_ACTIVITIES_ARCHIVE'       , 'ORDER_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Orders.ArchiveView'        , 'Invoices'         , 'Invoices'           ,  1, 'Invoices.LBL_MODULE_NAME'         , 'vwORDERS_INVOICES_ARCHIVE'         , 'ORDER_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Orders.ArchiveView'        , 'Cases'            , 'Cases'              ,  2, 'Cases.LBL_MODULE_NAME'            , 'vwORDERS_CASES_ARCHIVE'            , 'ORDER_ID', 'DATE_ENTERED' , 'desc';
end -- if;
GO

-- 01/27/2020 Paul.  Early state had missing sort fields that are needed on the React Client. 
if exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Invoices.ArchiveView' and CONTROL_NAME = 'ActivitiesHistory' and SORT_FIELD is null and DELETED = 0) begin -- then
	delete from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Invoices.ArchiveView';
end -- if;
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Invoices.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Invoices.ArchiveView Professional';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Invoices.ArchiveView'      , 'Activities'       , 'ActivitiesHistory'  ,  0, 'Activities.LBL_HISTORY'           , 'vwINVOICES_ACTIVITIES_ARCHIVE'     , 'INVOICE_ID', 'DATE_MODIFIED', 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Invoices.ArchiveView'      , 'Payments'         , 'Payments'           ,  1, 'Payments.LBL_MODULE_NAME'         , 'vwINVOICES_PAYMENTS_ARCHIVE'       , 'INVOICE_ID', 'DATE_ENTERED' , 'desc';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Invoices.ArchiveView'      , 'Cases'            , 'Cases'              ,  2, 'Cases.LBL_MODULE_NAME'            , 'vwINVOICES_CASES_ARCHIVE'          , 'INVOICE_ID', 'DATE_ENTERED' , 'desc';
end -- if;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Documents.ArchiveView' and MODULE_NAME = 'Contracts' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Documents.ArchiveView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.ArchiveView'     , 'Contracts'        , 'Contracts'          , -1, 'Contracts.LBL_MODULE_NAME'        , 'vwDOCUMENTS_CONTRACTS_ARCHIVE'     , 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
end -- if;
GO

if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Documents.ArchiveView' and MODULE_NAME = 'Quotes' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Documents.ArchiveView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Documents.ArchiveView'     , 'Quotes'           , 'Quotes'             , -1, 'Quotes.LBL_MODULE_NAME'           , 'vwDOCUMENTS_QUOTES_ARCHIVE'        , 'DOCUMENT_ID', 'DATE_ENTERED', 'desc';
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

call dbo.spDETAILVIEWS_RELATIONSHIPS_ArchiveViewPro()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_RELATIONSHIPS_ArchiveViewPro')
/

-- #endif IBM_DB2 */

