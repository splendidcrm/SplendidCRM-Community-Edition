

print 'GRIDVIEWS_COLUMNS ArchiveView SubPanel Professional';
set nocount on;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Quotes.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Quotes.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Quotes.ArchiveView', 'Accounts', 'vwACCOUNTS_QUOTES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Quotes.ArchiveView'                 , 0, 'Quotes.LBL_LIST_NAME'                     , 'NAME'                      , 'NAME'                      , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'                , '~/Quotes/view.aspx?ID={0}&ArchiveView={1}'  , null, 'Quotes'  , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Quotes.ArchiveView'                 , 1, 'Quotes.LBL_LIST_ACCOUNT_NAME'             , 'BILLING_ACCOUNT_NAME'      , 'BILLING_ACCOUNT_NAME'      , '40%', 'listViewTdLinkS1', 'BILLING_ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'BILLING_ACCOUNT_ASSIGNED_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.Quotes.ArchiveView'                 , 2, 'Quotes.LBL_LIST_AMOUNT'                   , 'TOTAL_USDOLLAR'            , 'TOTAL_USDOLLAR'            , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.Quotes.ArchiveView'                 , 3, 'Quotes.LBL_LIST_DATE_VALID_UNTIL'         , 'DATE_QUOTE_EXPECTED_CLOSED', 'DATE_QUOTE_EXPECTED_CLOSED', '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Contracts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Contracts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Contracts.ArchiveView', 'Accounts', 'vwACCOUNTS_CONTRACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Contracts.ArchiveView'              , 0, 'Contracts.LBL_LIST_NAME'                  , 'NAME'                         , 'NAME'                         , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Contracts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contracts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Contracts.ArchiveView'              , 1, 'Contracts.LBL_LIST_ACCOUNT_NAME'          , 'ACCOUNT_NAME'                 , 'ACCOUNT_NAME'                 , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW' , '~/Accounts/view.aspx?ID={0}&ArchiveView={1}' , null, 'Accounts' , 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.Contracts.ArchiveView'              , 2, 'Contracts.LBL_LIST_START_DATE'            , 'START_DATE'                   , 'START_DATE'                   , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.Contracts.ArchiveView'              , 3, 'Contracts.LBL_LIST_END_DATE'              , 'END_DATE'                     , 'END_DATE'                     , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Accounts.Contracts.ArchiveView'              , 4, 'Contracts.LBL_LIST_STATUS'                , 'STATUS'                       , 'STATUS'                       , '15%', 'contract_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.Contracts.ArchiveView'              , 5, 'Contracts.LBL_LIST_CONTRACT_VALUE'        , 'TOTAL_CONTRACT_VALUE_USDOLLAR', 'TOTAL_CONTRACT_VALUE_USDOLLAR', '10%', 'Currency';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contracts.Activities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contracts.Activities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contracts.Activities.ArchiveView', 'Contracts', 'vwCONTRACTS_ACTIVITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contracts.Activities.ArchiveView'                , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '20%', 'listViewTdLinkS1', 'ACTIVITY_ID ARCHIVE_VIEW', '~/Activities/view.aspx?ID={0}&ArchiveView={1}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contracts.Activities.ArchiveView'                , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contracts.Activities.ArchiveView'                , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW' , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}'  , null, 'Contacts'  , 'CONTACT_ASSIGNED_USER_ID' ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contracts.Activities.ArchiveView'                , 4, 'Activities.LBL_LIST_RELATED_TO'           , 'CONTRACT_NAME'          , 'CONTRACT_NAME'          , '20%', 'listViewTdLinkS1', 'CONTRACT_ID ARCHIVE_VIEW', '~/Contracts/view.aspx?ID={0}&ArchiveView={1}' , null, 'Contracts' , 'CONTRACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contracts.Activities.ArchiveView'                , 5, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Quotes.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Quotes.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Quotes.ArchiveView', 'Contacts', 'vwCONTACTS_QUOTES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Quotes.ArchiveView'                 , 0, 'Quotes.LBL_LIST_NAME'                     , 'NAME'                      , 'NAME'                      , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'                , '~/Quotes/view.aspx?ID={0}&ArchiveView={1}'  , null, 'Quotes'  , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Quotes.ArchiveView'                 , 1, 'Quotes.LBL_LIST_ACCOUNT_NAME'             , 'BILLING_ACCOUNT_NAME'      , 'BILLING_ACCOUNT_NAME'      , '40%', 'listViewTdLinkS1', 'BILLING_ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'BILLING_ACCOUNT_ASSIGNED_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.Quotes.ArchiveView'                 , 2, 'Quotes.LBL_LIST_AMOUNT'                   , 'TOTAL_USDOLLAR'            , 'TOTAL_USDOLLAR'            , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.Quotes.ArchiveView'                 , 3, 'Quotes.LBL_LIST_DATE_VALID_UNTIL'         , 'DATE_QUOTE_EXPECTED_CLOSED', 'DATE_QUOTE_EXPECTED_CLOSED', '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Invoices.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Invoices.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Invoices.ArchiveView', 'Contacts', 'vwCONTACTS_INVOICES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Invoices.ArchiveView'               , 0, 'Invoices.LBL_LIST_INVOICE_NUM'            , 'INVOICE_NUM'            , 'INVOICE_NUM'            , '10%', 'listViewTdLinkS1', 'INVOICE_ID ARCHIVE_VIEW', '~/Invoices/view.aspx?ID={0}&ArchiveView={1}', null, 'Invoices', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Invoices.ArchiveView'               , 1, 'Invoices.LBL_LIST_NAME'                   , 'INVOICE_NAME'           , 'INVOICE_NAME'           , '30%', 'listViewTdLinkS1', 'INVOICE_ID ARCHIVE_VIEW', '~/Invoices/view.aspx?ID={0}&ArchiveView={1}', null, 'Invoices', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.Invoices.ArchiveView'               , 2, 'Invoices.LBL_LIST_DUE_DATE'               , 'DUE_DATE'               , 'DUE_DATE'               , '20%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.Invoices.ArchiveView'               , 3, 'Invoices.LBL_LIST_AMOUNT'                 , 'TOTAL_USDOLLAR'         , 'TOTAL_USDOLLAR'         , '15%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.Invoices.ArchiveView'               , 4, 'Invoices.LBL_LIST_AMOUNT_DUE'             , 'AMOUNT_DUE_USDOLLAR'    , 'AMOUNT_DUE_USDOLLAR'    , '15%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Contacts.Invoices.ArchiveView', 3, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Contacts.Invoices.ArchiveView', 4, null, null, 'right', null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Orders.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Orders.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Orders.ArchiveView', 'Contacts', 'vwCONTACTS_ORDERS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Orders.ArchiveView'                 , 0, 'Orders.LBL_LIST_ORDER_NUM'                , 'ORDER_NUM'              , 'ORDER_NUM'              , '10%', 'listViewTdLinkS1', 'ORDER_ID ARCHIVE_VIEW', '~/Orders/view.aspx?ID={0}&ArchiveView={1}', null, 'Orders', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Orders.ArchiveView'                 , 1, 'Orders.LBL_LIST_NAME'                     , 'ORDER_NAME'             , 'ORDER_NAME'             , '30%', 'listViewTdLinkS1', 'ORDER_ID ARCHIVE_VIEW', '~/Orders/view.aspx?ID={0}&ArchiveView={1}', null, 'Orders', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.Orders.ArchiveView'                 , 2, 'Orders.LBL_LIST_DATE_ORDER_DUE'           , 'DATE_ORDER_DUE'         , 'DATE_ORDER_DUE'         , '20%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.Orders.ArchiveView'                 , 3, 'Orders.LBL_LIST_AMOUNT'                   , 'TOTAL_USDOLLAR'         , 'TOTAL_USDOLLAR'         , '15%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Contacts.Orders.ArchiveView', 3, null, null, 'right', null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contacts.Contracts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contacts.Contracts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contacts.Contracts.ArchiveView', 'Contacts', 'vwCONTACTS_CONTRACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contacts.Contracts.ArchiveView'              , 0, 'Contracts.LBL_LIST_NAME'                  , 'NAME'                         , 'NAME'                         , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Contracts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contracts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.Contracts.ArchiveView'              , 1, 'Contracts.LBL_LIST_START_DATE'            , 'START_DATE'                   , 'START_DATE'                   , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.Contracts.ArchiveView'              , 2, 'Contracts.LBL_LIST_END_DATE'              , 'END_DATE'                     , 'END_DATE'                     , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contacts.Contracts.ArchiveView'              , 3, 'Contracts.LBL_LIST_STATUS'                , 'STATUS'                       , 'STATUS'                       , '15%', 'contract_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contacts.Contracts.ArchiveView'              , 4, 'Contracts.LBL_LIST_CONTRACT_VALUE'        , 'TOTAL_CONTRACT_VALUE_USDOLLAR', 'TOTAL_CONTRACT_VALUE_USDOLLAR', '10%', 'Currency';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Emails.Quotes.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Emails.Quotes.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Emails.Quotes.ArchiveView', 'Emails', 'vwEMAILS_QUOTES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Quotes.ArchiveView'                   , 0, 'Quotes.LBL_LIST_NAME'                     , 'NAME'                      , 'NAME'                      , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'                , '~/Quotes/view.aspx?ID={0}&ArchiveView={1}'  , null, 'Quotes'  , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Emails.Quotes.ArchiveView'                   , 1, 'Quotes.LBL_LIST_ACCOUNT_NAME'             , 'BILLING_ACCOUNT_NAME'      , 'BILLING_ACCOUNT_NAME'      , '40%', 'listViewTdLinkS1', 'BILLING_ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'BILLING_ACCOUNT_ASSIGNED_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Emails.Quotes.ArchiveView'                   , 2, 'Quotes.LBL_LIST_AMOUNT'                   , 'TOTAL_USDOLLAR'            , 'TOTAL_USDOLLAR'            , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Emails.Quotes.ArchiveView'                   , 3, 'Quotes.LBL_LIST_DATE_VALID_UNTIL'         , 'DATE_QUOTE_EXPECTED_CLOSED', 'DATE_QUOTE_EXPECTED_CLOSED', '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Quotes.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Quotes.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Quotes.ArchiveView', 'Opportunities', 'vwOPPORTUNITIES_QUOTES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Quotes.ArchiveView'            , 0, 'Quotes.LBL_LIST_NAME'                     , 'NAME'                      , 'NAME'                      , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'                , '~/Quotes/view.aspx?ID={0}&ArchiveView={1}'  , null, 'Quotes'  , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Quotes.ArchiveView'            , 1, 'Quotes.LBL_LIST_ACCOUNT_NAME'             , 'BILLING_ACCOUNT_NAME'      , 'BILLING_ACCOUNT_NAME'      , '40%', 'listViewTdLinkS1', 'BILLING_ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'BILLING_ACCOUNT_ASSIGNED_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.Quotes.ArchiveView'            , 2, 'Quotes.LBL_LIST_AMOUNT'                   , 'TOTAL_USDOLLAR'            , 'TOTAL_USDOLLAR'            , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.Quotes.ArchiveView'            , 3, 'Quotes.LBL_LIST_DATE_VALID_UNTIL'         , 'DATE_QUOTE_EXPECTED_CLOSED', 'DATE_QUOTE_EXPECTED_CLOSED', '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.Contracts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.Contracts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.Contracts.ArchiveView', 'Opportunities', 'vwOPPORTUNITIES_CONTRACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Contracts.ArchiveView'         , 0, 'Contracts.LBL_LIST_NAME'                  , 'NAME'                         , 'NAME'                         , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Contracts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contracts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.Contracts.ArchiveView'         , 1, 'Contracts.LBL_LIST_ACCOUNT_NAME'          , 'ACCOUNT_NAME'                 , 'ACCOUNT_NAME'                 , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW' , '~/Accounts/view.aspx?ID={0}&ArchiveView={1}' , null, 'Accounts' , 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.Contracts.ArchiveView'         , 2, 'Contracts.LBL_LIST_START_DATE'            , 'START_DATE'                   , 'START_DATE'                   , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.Contracts.ArchiveView'         , 3, 'Contracts.LBL_LIST_END_DATE'              , 'END_DATE'                     , 'END_DATE'                     , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Opportunities.Contracts.ArchiveView'         , 4, 'Contracts.LBL_LIST_STATUS'                , 'STATUS'                       , 'STATUS'                       , '15%', 'contract_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.Contracts.ArchiveView'         , 5, 'Contracts.LBL_LIST_CONTRACT_VALUE'        , 'TOTAL_CONTRACT_VALUE_USDOLLAR', 'TOTAL_CONTRACT_VALUE_USDOLLAR', '10%', 'Currency';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Project.Quotes.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Project.Quotes.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Project.Quotes.ArchiveView', 'Project', 'vwPROJECTS_QUOTES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Quotes.ArchiveView'                  , 0, 'Quotes.LBL_LIST_NAME'                     , 'NAME'                      , 'NAME'                      , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'                , '~/Quotes/view.aspx?ID={0}&ArchiveView={1}'  , null, 'Quotes'  , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Project.Quotes.ArchiveView'                  , 1, 'Quotes.LBL_LIST_ACCOUNT_NAME'             , 'BILLING_ACCOUNT_NAME'      , 'BILLING_ACCOUNT_NAME'      , '40%', 'listViewTdLinkS1', 'BILLING_ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'BILLING_ACCOUNT_ASSIGNED_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.Quotes.ArchiveView'                  , 2, 'Quotes.LBL_LIST_AMOUNT'                   , 'TOTAL_USDOLLAR'            , 'TOTAL_USDOLLAR'            , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Project.Quotes.ArchiveView'                  , 3, 'Quotes.LBL_LIST_DATE_VALID_UNTIL'         , 'DATE_QUOTE_EXPECTED_CLOSED', 'DATE_QUOTE_EXPECTED_CLOSED', '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contracts.Documents.ArciveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contracts.Documents.ArciveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contracts.Documents.ArciveView', 'Contracts', 'vwCONTRACTS_DOCUMENTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contracts.Documents.ArciveView'              , 0, 'Documents.LBL_LIST_DOCUMENT_NAME'        , 'DOCUMENT_NAME'           , 'DOCUMENT_NAME'           , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Documents/view.aspx?ID={0}&ArchiveView={1}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contracts.Documents.ArciveView'              , 1, 'Documents.LBL_LIST_IS_TEMPLATE'          , 'IS_TEMPLATE'             , 'IS_TEMPLATE'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contracts.Documents.ArciveView'              , 2, 'Documents.LBL_LIST_TEMPLATE_TYPE'        , 'TEMPLATE_TYPE'           , 'TEMPLATE_TYPE'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contracts.Documents.ArciveView'              , 3, 'Documents.LBL_LIST_SELECTED_REVISION'    , 'SELECTED_REVISION'       , 'SELECTED_REVISION'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contracts.Documents.ArciveView'              , 4, 'Documents.LBL_LIST_REVISION'             , 'REVISION'                , 'REVISION'                , '20%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contracts.Notes.ArciveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contracts.Notes.ArciveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contracts.Notes.ArciveView', 'Contracts', 'vwCONTRACTS_NOTES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contracts.Notes.ArciveView'                  , 0, 'Notes.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Notes/view.aspx?ID={0}&ArchiveView={1}'   , null, 'Notes'   , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contracts.Notes.ArciveView'                  , 1, 'Notes.LBL_LIST_CONTACT_NAME'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '10%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW' , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contracts.Notes.ArciveView'                  , 2, 'Notes.LBL_LIST_RELATED_TO'                , 'PARENT_NAME'            , 'PARENT_NAME'            , '10%', 'listViewTdLinkS1', 'PARENT_ID ARCHIVE_VIEW'  , '~/Parents/view.aspx?ID={0}&ArchiveView={1}' , null, 'Parents' , 'PARENT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contracts.Notes.ArciveView'                  , 3, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contracts.Contacts.ArciveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contracts.Contacts.ArciveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contracts.Contacts.ArciveView', 'Contracts', 'vwCONTRACTS_CONTACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contracts.Contacts.ArciveView'               , 0, 'Contacts.LBL_LIST_CONTACT_NAME'           , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contracts.Contacts.ArciveView'               , 1, 'Contacts.LBL_LIST_ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contracts.Contacts.ArciveView'               , 2, 'Contacts.LBL_LIST_EMAIL_ADDRESS'          , 'EMAIL1'                 , 'EMAIL1'                 , '25%', 'listViewTdLinkS1', 'EMAIL1'    , 'mailto:{0}', null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contracts.Contacts.ArciveView'               , 3, 'Contacts.LBL_LIST_PHONE'                  , 'PHONE_WORK'             , 'PHONE_WORK'             , '15%';  --  ItemStyle-Wrap='false'
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Contracts.Contacts.ArciveView'         , 3, null, null, null, null, 0;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contracts.Quotes.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contracts.Quotes.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contracts.Quotes.ArchiveView', 'Contracts', 'vwCONTRACTS_QUOTES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contracts.Quotes.ArchiveView'                , 0, 'Quotes.LBL_LIST_NAME'                     , 'NAME'                      , 'NAME'                      , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'                , '~/Quotes/view.aspx?ID={0}&ArchiveView={1}'  , null, 'Quotes'  , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contracts.Quotes.ArchiveView'                , 1, 'Quotes.LBL_LIST_ACCOUNT_NAME'             , 'BILLING_ACCOUNT_NAME'      , 'BILLING_ACCOUNT_NAME'      , '40%', 'listViewTdLinkS1', 'BILLING_ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'BILLING_ACCOUNT_ASSIGNED_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contracts.Quotes.ArchiveView'                , 2, 'Quotes.LBL_LIST_AMOUNT'                   , 'TOTAL_USDOLLAR'            , 'TOTAL_USDOLLAR'            , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contracts.Quotes.ArchiveView'                , 3, 'Quotes.LBL_LIST_DATE_VALID_UNTIL'         , 'DATE_QUOTE_EXPECTED_CLOSED', 'DATE_QUOTE_EXPECTED_CLOSED', '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Contracts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.Contracts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.Contracts.ArchiveView', 'Documents', 'vwDOCUMENTS_CONTRACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Contracts.ArchiveView'             , 0, 'Contracts.LBL_LIST_NAME'                  , 'NAME'                         , 'NAME'                         , '20%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Contracts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contracts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Contracts.ArchiveView'             , 1, 'Contracts.LBL_LIST_ACCOUNT_NAME'          , 'ACCOUNT_NAME'                 , 'ACCOUNT_NAME'                 , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW' , '~/Accounts/view.aspx?ID={0}&ArchiveView={1}' , null, 'Accounts' , 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.Contracts.ArchiveView'             , 2, 'Contracts.LBL_LIST_START_DATE'            , 'START_DATE'                   , 'START_DATE'                   , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.Contracts.ArchiveView'             , 3, 'Contracts.LBL_LIST_END_DATE'              , 'END_DATE'                     , 'END_DATE'                     , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Documents.Contracts.ArchiveView'             , 4, 'Contracts.LBL_LIST_STATUS'                , 'STATUS'                       , 'STATUS'                       , '10%', 'contract_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.Contracts.ArchiveView'             , 5, 'Contracts.LBL_LIST_CONTRACT_VALUE'        , 'TOTAL_CONTRACT_VALUE_USDOLLAR', 'TOTAL_CONTRACT_VALUE_USDOLLAR', '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Contracts.ArchiveView'             , 6, 'Documents.LBL_LIST_SELECTED_REVISION'     , 'SELECTED_REVISION'            , 'SELECTED_REVISION'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Documents.Contracts.ArchiveView'             , 7, 'Documents.LBL_LIST_REVISION'              , 'REVISION'                     , 'REVISION'                     , '10%';
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Quotes.Activities.ArchiveView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Quotes.Activities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Quotes.Activities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Quotes.Activities.ArchiveView', 'Quotes', 'vwQUOTES_ACTIVITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.Activities.ArchiveView'                   , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '40%', 'listViewTdLinkS1', 'ACTIVITY_ID ARCHIVE_VIEW', '~/Activities/view.aspx?ID={0}&ArchiveView={1}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Quotes.Activities.ArchiveView'                   , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.Activities.ArchiveView'                   , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW' , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.Activities.ArchiveView'                   , 4, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'DateTime';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Quotes.Project.ArciveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Quotes.Project.ArciveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Quotes.Project.ArciveView', 'Quotes', 'vwQUOTES_PROJECTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.Project.ArciveView'                   , 0, 'Project.LBL_LIST_NAME'                    , 'NAME'                   , 'NAME'                   , '23%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/Projects/view.aspx?ID={0}&ArchiveView={1}', null, 'Project', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Quotes.Project.ArciveView'                   , 1, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'       , 'ASSIGNED_TO_NAME'       , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Quotes.Project.ArciveView'                   , 2, 'Project.LBL_LIST_TOTAL_ESTIMATED_EFFORT'  , 'TOTAL_ESTIMATED_EFFORT' , 'TOTAL_ESTIMATED_EFFORT' , '23%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Quotes.Project.ArciveView'                   , 3, 'Project.LBL_LIST_TOTAL_ACTUAL_EFFORT'     , 'TOTAL_ACTUAL_EFFORT'    , 'TOTAL_ACTUAL_EFFORT'    , '23%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Quotes.Contracts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Quotes.Contracts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Quotes.Contracts.ArchiveView', 'Quotes', 'vwQUOTES_CONTRACTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.Contracts.ArchiveView'                , 0, 'Contracts.LBL_LIST_NAME'                  , 'NAME'                         , 'NAME'                         , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Contracts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contracts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.Contracts.ArchiveView'                , 1, 'Contracts.LBL_LIST_ACCOUNT_NAME'          , 'ACCOUNT_NAME'                 , 'ACCOUNT_NAME'                 , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW' , '~/Accounts/view.aspx?ID={0}&ArchiveView={1}' , null, 'Accounts' , 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.Contracts.ArchiveView'                , 2, 'Contracts.LBL_LIST_START_DATE'            , 'START_DATE'                   , 'START_DATE'                   , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.Contracts.ArchiveView'                , 3, 'Contracts.LBL_LIST_END_DATE'              , 'END_DATE'                     , 'END_DATE'                     , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Quotes.Contracts.ArchiveView'                , 4, 'Contracts.LBL_LIST_STATUS'                , 'STATUS'                       , 'STATUS'                       , '15%', 'contract_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.Contracts.ArchiveView'                , 5, 'Contracts.LBL_LIST_CONTRACT_VALUE'        , 'TOTAL_CONTRACT_VALUE_USDOLLAR', 'TOTAL_CONTRACT_VALUE_USDOLLAR', '10%', 'Currency';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Quotes.LineItems.ArciveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Quotes.LineItems.ArciveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Quotes.LineItems.ArciveView', 'Quotes', 'vwQUOTES_LINE_ITEMS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Quotes.LineItems.ArciveView'                 , 0, 'Quotes.LBL_LIST_ITEM_QUANTITY'            , 'QUANTITY'               , null, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Quotes.LineItems.ArciveView'                 , 1, 'Quotes.LBL_LIST_ITEM_NAME'                , 'NAME'                   , null, '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.LineItems.ArciveView'                 , 2, 'Quotes.LBL_LIST_ITEM_MFT_PART_NUM'        , 'MFT_PART_NUM'           , null, '15%', 'listViewTdLinkS1', 'PRODUCT_TEMPLATE_ID ARCHIVE_VIEW', '~/Products/ProductCatalog/view.aspx?ID={0}&ArchiveView={1}', null, 'Products', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.LineItems.ArciveView'                 , 3, 'Quotes.LBL_LIST_ITEM_COST_PRICE'          , 'COST_USDOLLAR'          , null, '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.LineItems.ArciveView'                 , 4, 'Quotes.LBL_LIST_ITEM_LIST_PRICE'          , 'LIST_USDOLLAR'          , null, '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.LineItems.ArciveView'                 , 5, 'Quotes.LBL_LIST_ITEM_UNIT_PRICE'          , 'UNIT_USDOLLAR'          , null, '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.LineItems.ArciveView'                 , 6, 'Quotes.LBL_LIST_ITEM_EXTENDED_PRICE'      , 'EXTENDED_USDOLLAR'      , null, '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.LineItems.ArciveView'                 , 7, 'Quotes.LBL_LIST_ITEM_DISCOUNT_PRICE'      , 'DISCOUNT_USDOLLAR'      , null, '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Quotes.LineItems.ArciveView', 0, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Quotes.LineItems.ArciveView', 3, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Quotes.LineItems.ArciveView', 4, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Quotes.LineItems.ArciveView', 5, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Quotes.LineItems.ArciveView', 6, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Quotes.LineItems.ArciveView', 7, null, null, 'right', null, null;
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Orders.Activities.ArchiveView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Orders.Activities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Orders.Activities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Orders.Activities.ArchiveView', 'Orders', 'vwORDERS_ACTIVITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Orders.Activities.ArchiveView'                   , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '40%', 'listViewTdLinkS1', 'ACTIVITY_ID ARCHIVE_VIEW', '~/Activities/view.aspx?ID={0}&ArchiveView={1}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Orders.Activities.ArchiveView'                   , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Orders.Activities.ArchiveView'                   , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW' , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}'  , null, 'Contacts'  , 'CONTACT_ASSIGNED_USER_ID' ;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Orders.Activities.ArchiveView'                   , 4, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'DateTime';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Orders.Invoices.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Orders.Invoices.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Orders.Invoices.ArchiveView', 'Payments', 'vwORDERS_INVOICES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Orders.Invoices.ArchiveView'                 , 0, 'Invoices.LBL_LIST_INVOICE_NUM'            , 'INVOICE_NUM'            , 'INVOICE_NUM'            , '10%', 'listViewTdLinkS1', 'INVOICE_ID ARCHIVE_VIEW', '~/Invoices/view.aspx?ID={0}&ArchiveView={1}', null, 'Invoices', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Orders.Invoices.ArchiveView'                 , 1, 'Invoices.LBL_LIST_NAME'                   , 'INVOICE_NAME'           , 'INVOICE_NAME'           , '30%', 'listViewTdLinkS1', 'INVOICE_ID ARCHIVE_VIEW', '~/Invoices/view.aspx?ID={0}&ArchiveView={1}', null, 'Invoices', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Orders.Invoices.ArchiveView'                 , 2, 'Invoices.LBL_LIST_AMOUNT'                 , 'TOTAL_USDOLLAR'         , 'TOTAL_USDOLLAR'         , '15%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Orders.Invoices.ArchiveView'                 , 3, 'Invoices.LBL_LIST_AMOUNT_DUE'             , 'AMOUNT_DUE_USDOLLAR'    , 'AMOUNT_DUE_USDOLLAR'    , '15%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Orders.Invoices.ArchiveView'                 , 4, '.LBL_LIST_CREATED'                        , 'DATE_ENTERED'           , 'DATE_ENTERED'           , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Orders.Invoices.ArchiveView'                 , 5, 'Invoices.LBL_LIST_DUE_DATE'               , 'DUE_DATE'               , 'DUE_DATE'               , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Orders.Invoices.ArchiveView', 2, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Orders.Invoices.ArchiveView', 3, null, null, 'right', null, null;
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'Invoices.Activities.ArchiveView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Invoices.Activities.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Invoices.Activities.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Invoices.Activities.ArchiveView', 'Invoices', 'vwINVOICES_ACTIVITIES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Invoices.Activities.ArchiveView'                 , 1, 'Activities.LBL_LIST_SUBJECT'              , 'ACTIVITY_NAME'          , 'ACTIVITY_NAME'          , '40%', 'listViewTdLinkS1', 'ACTIVITY_ID ARCHIVE_VIEW', '~/Activities/view.aspx?ID={0}&ArchiveView={1}', null, 'Activities', 'ACTIVITY_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Invoices.Activities.ArchiveView'                 , 2, 'Activities.LBL_LIST_STATUS'               , 'STATUS'                 , 'STATUS'                 , '10%', 'activity_status';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Invoices.Activities.ArchiveView'                 , 3, 'Activities.LBL_LIST_CONTACT'              , 'CONTACT_NAME'           , 'CONTACT_NAME'           , '20%', 'listViewTdLinkS1', 'CONTACT_ID ARCHIVE_VIEW' , '~/Contacts/view.aspx?ID={0}&ArchiveView={1}', null, 'Contacts', 'CONTACT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Invoices.Activities.ArchiveView'                 , 4, 'Activities.LBL_LIST_LAST_MODIFIED'        , 'DATE_MODIFIED'          , 'DATE_MODIFIED'          , '10%', 'DateTime';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Invoices.LineItems.ArciveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Invoices.LineItems.ArciveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Invoices.LineItems.ArciveView', 'Invoices', 'vwINVOICES_LINE_ITEMS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Invoices.LineItems.ArciveView'               , 0, 'Invoices.LBL_LIST_ITEM_QUANTITY'          , 'QUANTITY'               , null, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Invoices.LineItems.ArciveView'               , 1, 'Invoices.LBL_LIST_ITEM_NAME'              , 'NAME'                   , null, '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Invoices.LineItems.ArciveView'               , 2, 'Invoices.LBL_LIST_ITEM_MFT_PART_NUM'      , 'MFT_PART_NUM'           , null, '15%', 'listViewTdLinkS1', 'PRODUCT_TEMPLATE_ID ARCHIVE_VIEW', '~/Products/ProductCatalog/view.aspx?ID={0}&ArchiveView={1}', null, 'Products', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Invoices.LineItems.ArciveView'               , 3, 'Invoices.LBL_LIST_ITEM_COST_PRICE'        , 'COST_USDOLLAR'          , null, '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Invoices.LineItems.ArciveView'               , 4, 'Invoices.LBL_LIST_ITEM_LIST_PRICE'        , 'LIST_USDOLLAR'          , null, '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Invoices.LineItems.ArciveView'               , 5, 'Invoices.LBL_LIST_ITEM_UNIT_PRICE'        , 'UNIT_USDOLLAR'          , null, '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Invoices.LineItems.ArciveView'               , 6, 'Invoices.LBL_LIST_ITEM_EXTENDED_PRICE'    , 'EXTENDED_USDOLLAR'      , null, '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Invoices.LineItems.ArciveView'               , 7, 'Invoices.LBL_LIST_ITEM_DISCOUNT_PRICE'    , 'DISCOUNT_USDOLLAR'      , null, '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Invoices.LineItems.ArciveView', 0, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Invoices.LineItems.ArciveView', 3, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Invoices.LineItems.ArciveView', 4, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Invoices.LineItems.ArciveView', 5, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Invoices.LineItems.ArciveView', 6, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Invoices.LineItems.ArciveView', 7, null, null, 'right', null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Payments.Invoices.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Payments.Invoices.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Payments.Invoices.ArchiveView', 'Payments', 'vwPAYMENTS_INVOICES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Payments.Invoices.ArchiveView'               , 0, 'Invoices.LBL_LIST_INVOICE_NUM'            , 'INVOICE_NUM'            , 'INVOICE_NUM'            , '10%', 'listViewTdLinkS1', 'INVOICE_ID ARCHIVE_VIEW', '~/Invoices/view.aspx?ID={0}&ArchiveView={1}', null, 'Invoices', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Payments.Invoices.ArchiveView'               , 1, 'Invoices.LBL_LIST_NAME'                   , 'INVOICE_NAME'           , 'INVOICE_NAME'           , '30%', 'listViewTdLinkS1', 'INVOICE_ID ARCHIVE_VIEW', '~/Invoices/view.aspx?ID={0}&ArchiveView={1}', null, 'Invoices', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Payments.Invoices.ArchiveView'               , 2, 'Invoices.LBL_LIST_AMOUNT'                 , 'TOTAL_USDOLLAR'         , 'TOTAL_USDOLLAR'         , '15%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Payments.Invoices.ArchiveView'               , 3, 'Invoices.LBL_LIST_ALLOCATED'              , 'ALLOCATED_USDOLLAR'     , 'ALLOCATED_USDOLLAR'     , '15%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Payments.Invoices.ArchiveView'               , 4, 'Invoices.LBL_LIST_AMOUNT_DUE'             , 'AMOUNT_DUE_USDOLLAR'    , 'AMOUNT_DUE_USDOLLAR'    , '15%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Payments.Invoices.ArchiveView', 2, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Payments.Invoices.ArchiveView', 3, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Payments.Invoices.ArchiveView', 4, null, null, 'right', null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Invoices.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Invoices.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Invoices.ArchiveView', 'Accounts', 'vwACCOUNTS_INVOICES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Invoices.ArchiveView'               , 0, 'Invoices.LBL_LIST_INVOICE_NUM'            , 'INVOICE_NUM'            , 'INVOICE_NUM'            , '10%', 'listViewTdLinkS1', 'INVOICE_ID ARCHIVE_VIEW', '~/Invoices/view.aspx?ID={0}&ArchiveView={1}', null, 'Invoices', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Invoices.ArchiveView'               , 1, 'Invoices.LBL_LIST_NAME'                   , 'INVOICE_NAME'           , 'INVOICE_NAME'           , '30%', 'listViewTdLinkS1', 'INVOICE_ID ARCHIVE_VIEW', '~/Invoices/view.aspx?ID={0}&ArchiveView={1}', null, 'Invoices', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.Invoices.ArchiveView'               , 2, 'Invoices.LBL_LIST_DUE_DATE'               , 'DUE_DATE'               , 'DUE_DATE'               , '20%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.Invoices.ArchiveView'               , 3, 'Invoices.LBL_LIST_AMOUNT'                 , 'TOTAL_USDOLLAR'         , 'TOTAL_USDOLLAR'         , '15%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.Invoices.ArchiveView'               , 4, 'Invoices.LBL_LIST_AMOUNT_DUE'             , 'AMOUNT_DUE_USDOLLAR'    , 'AMOUNT_DUE_USDOLLAR'    , '15%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Accounts.Invoices.ArchiveView', 3, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Accounts.Invoices.ArchiveView', 4, null, null, 'right', null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Accounts.Orders.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Accounts.Orders.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Accounts.Orders.ArchiveView', 'Accounts', 'vwACCOUNTS_ORDERS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Orders.ArchiveView'                 , 0, 'Orders.LBL_LIST_ORDER_NUM'                , 'ORDER_NUM'              , 'ORDER_NUM'              , '10%', 'listViewTdLinkS1', 'ORDER_ID ARCHIVE_VIEW', '~/Orders/view.aspx?ID={0}&ArchiveView={1}', null, 'Orders', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Accounts.Orders.ArchiveView'                 , 1, 'Orders.LBL_LIST_NAME'                     , 'ORDER_NAME'             , 'ORDER_NAME'             , '30%', 'listViewTdLinkS1', 'ORDER_ID ARCHIVE_VIEW', '~/Orders/view.aspx?ID={0}&ArchiveView={1}', null, 'Orders', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.Orders.ArchiveView'                 , 2, 'Orders.LBL_LIST_DATE_ORDER_DUE'           , 'DATE_ORDER_DUE'         , 'DATE_ORDER_DUE'         , '20%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Accounts.Orders.ArchiveView'                 , 3, 'Orders.LBL_LIST_AMOUNT'                   , 'TOTAL_USDOLLAR'         , 'TOTAL_USDOLLAR'         , '15%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Accounts.Orders.ArchiveView', 3, null, null, 'right', null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Quotes.Invoices.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Quotes.Invoices.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Quotes.Invoices.ArchiveView', 'Payments', 'vwQUOTES_INVOICES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.Invoices.ArchiveView'                 , 0, 'Invoices.LBL_LIST_INVOICE_NUM'            , 'INVOICE_NUM'            , 'INVOICE_NUM'            , '10%', 'listViewTdLinkS1', 'INVOICE_ID ARCHIVE_VIEW', '~/Invoices/view.aspx?ID={0}&ArchiveView={1}', null, 'Invoices', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.Invoices.ArchiveView'                 , 1, 'Invoices.LBL_LIST_NAME'                   , 'INVOICE_NAME'           , 'INVOICE_NAME'           , '30%', 'listViewTdLinkS1', 'INVOICE_ID ARCHIVE_VIEW', '~/Invoices/view.aspx?ID={0}&ArchiveView={1}', null, 'Invoices', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.Invoices.ArchiveView'                 , 2, 'Invoices.LBL_LIST_AMOUNT'                 , 'TOTAL_USDOLLAR'         , 'TOTAL_USDOLLAR'         , '15%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.Invoices.ArchiveView'                 , 3, 'Invoices.LBL_LIST_AMOUNT_DUE'             , 'AMOUNT_DUE_USDOLLAR'    , 'AMOUNT_DUE_USDOLLAR'    , '15%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.Invoices.ArchiveView'                 , 4, '.LBL_LIST_CREATED'                        , 'DATE_ENTERED'           , 'DATE_ENTERED'           , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.Invoices.ArchiveView'                 , 5, 'Invoices.LBL_LIST_DUE_DATE'               , 'DUE_DATE'               , 'DUE_DATE'               , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Quotes.Invoices.ArchiveView', 2, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Quotes.Invoices.ArchiveView', 3, null, null, 'right', null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Quotes.Orders.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Quotes.Orders.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Quotes.Orders.ArchiveView', 'Payments', 'vwQUOTES_ORDERS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.Orders.ArchiveView'                   , 0, 'Orders.LBL_LIST_ORDER_NUM'                , 'ORDER_NUM'              , 'ORDER_NUM'              , '10%', 'listViewTdLinkS1', 'ORDER_ID ARCHIVE_VIEW', '~/Orders/view.aspx?ID={0}&ArchiveView={1}', null, 'Orders', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.Orders.ArchiveView'                   , 1, 'Orders.LBL_LIST_NAME'                     , 'ORDER_NAME'             , 'ORDER_NAME'             , '30%', 'listViewTdLinkS1', 'ORDER_ID ARCHIVE_VIEW', '~/Orders/view.aspx?ID={0}&ArchiveView={1}', null, 'Orders', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.Orders.ArchiveView'                   , 2, 'Orders.LBL_LIST_AMOUNT'                   , 'TOTAL_USDOLLAR'         , 'TOTAL_USDOLLAR'         , '15%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.Orders.ArchiveView'                   , 3, '.LBL_LIST_CREATED'                        , 'DATE_ENTERED'           , 'DATE_ENTERED'           , '10%', 'DateTime';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.Orders.ArchiveView'                   , 4, 'Orders.LBL_LIST_DATE_ORDER_DUE'           , 'DATE_ORDER_DUE'         , 'DATE_ORDER_DUE'         , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Quotes.Orders.ArchiveView', 2, null, null, 'right', null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Orders.LineItems.ArciveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Orders.LineItems.ArciveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Orders.LineItems.ArciveView', 'Orders', 'vwORDERS_LINE_ITEMS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Orders.LineItems.ArciveView'                 , 0, 'Orders.LBL_LIST_ITEM_QUANTITY'            , 'QUANTITY'               , null, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Orders.LineItems.ArciveView'                 , 1, 'Orders.LBL_LIST_ITEM_NAME'                , 'NAME'                   , null, '20%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'                 , '~/OrdersLineItems/view.aspx?ID={0}&ArchiveView={1}'        , null, null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Orders.LineItems.ArciveView'                 , 2, 'Orders.LBL_LIST_ITEM_MFT_PART_NUM'        , 'MFT_PART_NUM'           , null, '15%', 'listViewTdLinkS1', 'PRODUCT_TEMPLATE_ID ARCHIVE_VIEW', '~/Products/ProductCatalog/view.aspx?ID={0}&ArchiveView={1}', null, 'Products', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Orders.LineItems.ArciveView'                 , 3, 'Orders.LBL_LIST_ITEM_COST_PRICE'          , 'COST_USDOLLAR'          , null, '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Orders.LineItems.ArciveView'                 , 4, 'Orders.LBL_LIST_ITEM_LIST_PRICE'          , 'LIST_USDOLLAR'          , null, '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Orders.LineItems.ArciveView'                 , 5, 'Orders.LBL_LIST_ITEM_UNIT_PRICE'          , 'UNIT_USDOLLAR'          , null, '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Orders.LineItems.ArciveView'                 , 6, 'Orders.LBL_LIST_ITEM_EXTENDED_PRICE'      , 'EXTENDED_USDOLLAR'      , null, '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Orders.LineItems.ArciveView'                 , 7, 'Orders.LBL_LIST_ITEM_DISCOUNT_PRICE'      , 'DISCOUNT_USDOLLAR'      , null, '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Orders.LineItems.ArciveView', 0, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Orders.LineItems.ArciveView', 3, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Orders.LineItems.ArciveView', 4, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Orders.LineItems.ArciveView', 5, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Orders.LineItems.ArciveView', 6, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Orders.LineItems.ArciveView', 7, null, null, 'right', null, null;
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Quotes.Cases.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Quotes.Cases.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Quotes.Cases.ArchiveView', 'Quotes', 'vwQUOTES_CASES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.Cases.ArchiveView'                    , 0, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'            , 'CASE_NUMBER'            , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.Cases.ArchiveView'                    , 1, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.Cases.ArchiveView'                    , 2, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Quotes.Cases.ArchiveView'                    , 3, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'                 , 'STATUS'                 , '15%', 'case_status_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Orders.Cases.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Orders.Cases.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Orders.Cases.ArchiveView', 'Orders', 'vwORDERS_CASES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Orders.Cases.ArchiveView'                    , 0, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'            , 'CASE_NUMBER'            , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Orders.Cases.ArchiveView'                    , 1, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Orders.Cases.ArchiveView'                    , 2, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Orders.Cases.ArchiveView'                    , 3, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'                 , 'STATUS'                 , '15%', 'case_status_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Invoices.Cases.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Invoices.Cases.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Invoices.Cases.ArchiveView', 'Invoices', 'vwINVOICES_CASES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Invoices.Cases.ArchiveView'                  , 0, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'            , 'CASE_NUMBER'            , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Invoices.Cases.ArchiveView'                  , 1, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Invoices.Cases.ArchiveView'                  , 2, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Invoices.Cases.ArchiveView'                  , 3, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'                 , 'STATUS'                 , '15%', 'case_status_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'KBDocuments.Cases.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS KBDocuments.Cases.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'KBDocuments.Cases.ArchiveView', 'KBDocuments', 'vwKBDOCUMENTS_CASES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'KBDocuments.Cases.ArchiveView'               , 0, 'Cases.LBL_LIST_NUMBER'                    , 'CASE_NUMBER'            , 'CASE_NUMBER'            , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'KBDocuments.Cases.ArchiveView'               , 1, 'Cases.LBL_LIST_SUBJECT'                   , 'NAME'                   , 'NAME'                   , '25%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'   , '~/Cases/view.aspx?ID={0}&ArchiveView={1}', null, 'Cases', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'KBDocuments.Cases.ArchiveView'               , 2, 'Cases.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'           , 'ACCOUNT_NAME'           , '25%', 'listViewTdLinkS1', 'ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'KBDocuments.Cases.ArchiveView'               , 3, 'Cases.LBL_LIST_STATUS'                    , 'STATUS'                 , 'STATUS'                 , '15%', 'case_status_dom';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Cases.KBDocuments.ArciveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Cases.KBDocuments.ArciveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Cases.KBDocuments.ArciveView', 'KBDocuments', 'vwCASES_KBDOCUMENTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Cases.KBDocuments.ArciveView'               , 0, 'KBDocuments.LBL_LIST_NAME'                , 'NAME'                 , 'NAME'                 , '30', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW', '~/KBDocuments/view.aspx?ID={0}&ArchiveView={1}', null, 'KBDocuments', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.KBDocuments.ArciveView'               , 1, 'KBDocuments.LBL_LIST_KBDOC_APPROVER_NAME' , 'KBDOC_APPROVER_NAME'  , 'KBDOC_APPROVER_NAME'  , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Cases.KBDocuments.ArciveView'               , 2, '.LBL_LIST_DATE_ENTERED'                   , 'DATE_ENTERED'         , 'DATE_ENTERED'         , '20%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.KBDocuments.ArciveView'               , 3, '.LBL_LIST_ASSIGNED_USER'                  , 'ASSIGNED_TO_NAME'     , 'ASSIGNED_TO_NAME'     , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Cases.KBDocuments.ArciveView'               , 4, 'Teams.LBL_LIST_TEAM'                      , 'TEAM_NAME'            , 'TEAM_NAME'            , '5%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Quotes.Documents.ArciveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Quotes.Documents.ArciveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Quotes.Documents.ArciveView', 'Quotes', 'vwQUOTES_DOCUMENTS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.Documents.ArciveView'                , 0, 'Documents.LBL_LIST_DOCUMENT_NAME'        , 'DOCUMENT_NAME'           , 'DOCUMENT_NAME'           , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'         , '~/Documents/view.aspx?ID={0}&ArchiveView={1}', null, 'Documents', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Quotes.Documents.ArciveView'                , 1, 'Documents.LBL_LIST_IS_TEMPLATE'          , 'IS_TEMPLATE'             , 'IS_TEMPLATE'             , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Quotes.Documents.ArciveView'                , 2, 'Documents.LBL_LIST_TEMPLATE_TYPE'        , 'TEMPLATE_TYPE'           , 'TEMPLATE_TYPE'           , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Quotes.Documents.ArciveView'                , 3, 'Documents.LBL_LIST_SELECTED_REVISION'    , 'SELECTED_REVISION'       , 'SELECTED_REVISION'       , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Quotes.Documents.ArciveView'                , 4, 'Documents.LBL_LIST_REVISION'             , 'REVISION'                , 'REVISION'                , '20%';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Documents.Quotes.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Documents.Quotes.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Documents.Quotes.ArchiveView', 'Documents', 'vwDOCUMENTS_QUOTES_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Quotes.ArchiveView'                , 0, 'Quotes.LBL_LIST_NAME'                     , 'NAME'                      , 'NAME'                      , '40%', 'listViewTdLinkS1', 'ID ARCHIVE_VIEW'                , '~/Quotes/view.aspx?ID={0}&ArchiveView={1}'  , null, 'Quotes'  , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Documents.Quotes.ArchiveView'                , 1, 'Quotes.LBL_LIST_ACCOUNT_NAME'             , 'BILLING_ACCOUNT_NAME'      , 'BILLING_ACCOUNT_NAME'      , '40%', 'listViewTdLinkS1', 'BILLING_ACCOUNT_ID ARCHIVE_VIEW', '~/Accounts/view.aspx?ID={0}&ArchiveView={1}', null, 'Accounts', 'BILLING_ACCOUNT_ASSIGNED_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.Quotes.ArchiveView'                , 2, 'Quotes.LBL_LIST_AMOUNT'                   , 'TOTAL_USDOLLAR'            , 'TOTAL_USDOLLAR'            , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Documents.Quotes.ArchiveView'                , 3, 'Quotes.LBL_LIST_DATE_VALID_UNTIL'         , 'DATE_QUOTE_EXPECTED_CLOSED', 'DATE_QUOTE_EXPECTED_CLOSED', '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Opportunities.LineItems.ArciveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Opportunities.LineItems.ArciveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Opportunities.LineItems.ArciveView', 'Opportunities', 'vwOPPORTUNITIES_LINE_ITEMS_ARCHIVE';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.LineItems.ArciveView'          ,  0, 'Opportunities.LBL_LIST_ITEM_QUANTITY'        , 'QUANTITY'               , null, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.LineItems.ArciveView'          ,  1, 'Opportunities.LBL_LIST_ITEM_NAME'            , 'NAME'                   , null, '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Opportunities.LineItems.ArciveView'          ,  2, 'Opportunities.LBL_LIST_ITEM_MFT_PART_NUM'    , 'MFT_PART_NUM'           , null, '10%', 'listViewTdLinkS1', 'PRODUCT_TEMPLATE_ID ARCHIVE_VIEW', '~/Products/ProductCatalog/view.aspx?ID={0}&ArchiveView={1}', null, 'Products', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.LineItems.ArciveView'          ,  3, 'Opportunities.LBL_LIST_ITEM_LIST_PRICE'      , 'LIST_USDOLLAR'          , null, '5%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.LineItems.ArciveView'          ,  4, 'Opportunities.LBL_LIST_ITEM_UNIT_PRICE'      , 'UNIT_USDOLLAR'          , null, '5%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.LineItems.ArciveView'          ,  5, 'Opportunities.LBL_LIST_ITEM_EXTENDED_PRICE'  , 'EXTENDED_USDOLLAR'      , null, '5%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.LineItems.ArciveView'          ,  6, 'Opportunities.LBL_LIST_ITEM_DISCOUNT_PRICE'  , 'DISCOUNT_USDOLLAR'      , null, '5%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Opportunities.LineItems.ArciveView'          ,  7, 'Opportunities.LBL_LIST_ITEM_DATE_CLOSED'     , 'DATE_CLOSED'            , null, '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Opportunities.LineItems.ArciveView'          ,  8, 'Opportunities.LBL_LIST_ITEM_OPPORTUNITY_TYPE', 'OPPORTUNITY_TYPE'       , null, '5%', 'opportunity_type_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Opportunities.LineItems.ArciveView'          ,  9, 'Opportunities.LBL_LIST_ITEM_LEAD_SOURCE'     , 'LEAD_SOURCE'            , null, '5%', 'lead_source_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.LineItems.ArciveView'          , 10, 'Opportunities.LBL_LIST_ITEM_NEXT_STEP'       , 'NEXT_STEP'              , null, '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Opportunities.LineItems.ArciveView'          , 11, 'Opportunities.LBL_LIST_ITEM_SALES_STAGE'     , 'SALES_STAGE'            , null, '5%', 'sales_stage_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Opportunities.LineItems.ArciveView'          , 12, 'Opportunities.LBL_LIST_ITEM_PROBABILITY'     , 'PROBABILITY'            , null, '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Opportunities.LineItems.ArciveView'    , 0, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Opportunities.LineItems.ArciveView'    , 3, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Opportunities.LineItems.ArciveView'    , 4, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Opportunities.LineItems.ArciveView'    , 5, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Opportunities.LineItems.ArciveView'    , 6, null, null, 'right', null, null;
	exec dbo.spGRIDVIEWS_COLUMNS_UpdateStyle  null, 'Opportunities.LineItems.ArciveView'    , 7, null, null, 'right', null, null;
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

call dbo.spGRIDVIEWS_COLUMNS_ArchiveViewSubPanelsPro()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_ArchiveViewSubPanelsPro')
/

-- #endif IBM_DB2 */

