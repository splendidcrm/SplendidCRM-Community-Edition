

print 'GRIDVIEWS_COLUMNS ArchiveView Professional';
-- delete from GRIDVIEWS_COLUMNS -- where GRID_NAME like '%.ArchiveView'
--GO

set nocount on;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Contracts.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Contracts.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Contracts.ArchiveView'         , 'Contracts', 'vwCONTRACTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contracts.ArchiveView'         ,  2, 'Contracts.LBL_LIST_NAME'                      , 'NAME'                      , 'NAME'                      , '15%', 'ArchiveViewTdLinkS1', 'ID'         , '~/Contracts/view.aspx?id={0}&ArchiveView=1', null, 'Contracts', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Contracts.ArchiveView'         ,  3, 'Contracts.LBL_LIST_ACCOUNT_NAME'              , 'ACCOUNT_NAME'              , 'ACCOUNT_NAME'              , '15%', 'ArchiveViewTdLinkS1', 'ACCOUNT_ID' , '~/Accounts/view.aspx?id={0}&ArchiveView=1' , null, 'Accounts' , 'ACCOUNT_ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Contracts.ArchiveView'         ,  4, 'Contracts.LBL_LIST_STATUS'                    , 'STATUS'                    , 'STATUS'                    , '15%', 'contract_status_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contracts.ArchiveView'         ,  5, 'Contracts.LBL_LIST_START_DATE'                , 'START_DATE'                , 'START_DATE'                , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contracts.ArchiveView'         ,  6, 'Contracts.LBL_LIST_END_DATE'                  , 'END_DATE'                  , 'END_DATE'                  , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Contracts.ArchiveView'         ,  7, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contracts.ArchiveView'         ,  8, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'          , 'ASSIGNED_TO_NAME'          , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Contracts.ArchiveView'         ,  9, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'                 , 'TEAM_NAME'                 , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Contracts.ArchiveView'         , 10, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'          , 'ARCHIVE_DATE_UTC'          , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Quotes.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Quotes.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Quotes.ArchiveView'            , 'Quotes', 'vwQUOTES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.ArchiveView'            ,  2, 'Quotes.LBL_LIST_QUOTE_NUM'                    , 'QUOTE_NUM'                 , 'QUOTE_NUM'                 , '10%', 'ArchiveViewTdLinkS1', 'ID'                , '~/Quotes/view.aspx?id={0}&ArchiveView=1'   , null, 'Quotes'  , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.ArchiveView'            ,  3, 'Quotes.LBL_LIST_NAME'                         , 'NAME'                      , 'NAME'                      , '15%', 'ArchiveViewTdLinkS1', 'ID'                , '~/Quotes/view.aspx?id={0}&ArchiveView=1'   , null, 'Quotes'  , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Quotes.ArchiveView'            ,  4, 'Quotes.LBL_LIST_ACCOUNT_NAME'                 , 'BILLING_ACCOUNT_NAME'      , 'BILLING_ACCOUNT_NAME'      , '15%', 'ArchiveViewTdLinkS1', 'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}&ArchiveView=1' , null, 'Accounts', 'BILLING_ACCOUNT_ASSIGNED_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Quotes.ArchiveView'            ,  5, 'Quotes.LBL_LIST_QUOTE_STAGE'                  , 'QUOTE_STAGE'               , 'QUOTE_STAGE'               , '10%', 'quote_stage_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.ArchiveView'            ,  6, 'Quotes.LBL_LIST_AMOUNT'                       , 'TOTAL_USDOLLAR'            , 'TOTAL_USDOLLAR'            , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.ArchiveView'            ,  7, 'Quotes.LBL_LIST_DATE_VALID_UNTIL'             , 'DATE_QUOTE_EXPECTED_CLOSED', 'DATE_QUOTE_EXPECTED_CLOSED', '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Quotes.ArchiveView'            ,  8, '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Quotes.ArchiveView'            ,  9, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'          , 'ASSIGNED_TO_NAME'          , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Quotes.ArchiveView'            , 10, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'                 , 'TEAM_NAME'                 , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Quotes.ArchiveView'            , 11, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'          , 'ARCHIVE_DATE_UTC'          , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Orders.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Orders.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Orders.ArchiveView'            , 'Orders', 'vwORDERS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Orders.ArchiveView'            ,  2, 'Orders.LBL_LIST_ORDER_NUM'                    , 'ORDER_NUM'                 , 'ORDER_NUM'                 , '10%', 'ArchiveViewTdLinkS1', 'ID'                , '~/Orders/view.aspx?id={0}&ArchiveView=1'   , null, 'Orders'  , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Orders.ArchiveView'            ,  3, 'Orders.LBL_LIST_NAME'                         , 'NAME'                      , 'NAME'                      , '15%', 'ArchiveViewTdLinkS1', 'ID'                , '~/Orders/view.aspx?id={0}&ArchiveView=1'   , null, 'Orders'  , 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Orders.ArchiveView'            ,  4, 'Orders.LBL_LIST_ACCOUNT_NAME'                 , 'BILLING_ACCOUNT_NAME'      , 'BILLING_ACCOUNT_NAME'      , '15%', 'ArchiveViewTdLinkS1', 'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}&ArchiveView=1' , null, 'Accounts', 'BILLING_ACCOUNT_ASSIGNED_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Orders.ArchiveView'            ,  5, 'Orders.LBL_LIST_ORDER_STAGE'                  , 'ORDER_STAGE'               , 'ORDER_STAGE'               , '10%', 'order_stage_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Orders.ArchiveView'            ,  6, 'Orders.LBL_LIST_AMOUNT'                       , 'TOTAL_USDOLLAR'            , 'TOTAL_USDOLLAR'            , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Orders.ArchiveView'            ,  7, 'Orders.LBL_LIST_DATE_ORDER_DUE'               , 'DATE_ORDER_DUE'            , 'DATE_ORDER_DUE'            , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Orders.ArchiveView'            ,  8, '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Orders.ArchiveView'            ,  9, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'          , 'ASSIGNED_TO_NAME'          , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Orders.ArchiveView'            , 10, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'                 , 'TEAM_NAME'                 , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Orders.ArchiveView'            , 11, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'          , 'ARCHIVE_DATE_UTC'          , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'Invoices.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS Invoices.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'Invoices.ArchiveView'          , 'Invoices', 'vwINVOICES_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Invoices.ArchiveView'          ,  2, 'Invoices.LBL_LIST_INVOICE_NUM'                , 'INVOICE_NUM'               , 'INVOICE_NUM'               , '5%' , 'ArchiveViewTdLinkS1', 'ID'                , '~/Invoices/view.aspx?id={0}&ArchiveView=1' , null, 'Invoices', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Invoices.ArchiveView'          ,  3, 'Invoices.LBL_LIST_NAME'                       , 'NAME'                      , 'NAME'                      , '15%', 'ArchiveViewTdLinkS1', 'ID'                , '~/Invoices/view.aspx?id={0}&ArchiveView=1' , null, 'Invoices', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'Invoices.ArchiveView'          ,  4, 'Invoices.LBL_LIST_ACCOUNT_NAME'               , 'BILLING_ACCOUNT_NAME'      , 'BILLING_ACCOUNT_NAME'      , '15%', 'ArchiveViewTdLinkS1', 'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}&ArchiveView=1' , null, 'Accounts', 'BILLING_ACCOUNT_ASSIGNED_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundList 'Invoices.ArchiveView'          ,  5, 'Invoices.LBL_LIST_INVOICE_STAGE'              , 'INVOICE_STAGE'             , 'INVOICE_STAGE'             , '10%', 'invoice_stage_dom';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Invoices.ArchiveView'          ,  6, 'Invoices.LBL_LIST_AMOUNT'                     , 'TOTAL_USDOLLAR'            , 'TOTAL_USDOLLAR'            , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Invoices.ArchiveView'          ,  7, 'Invoices.LBL_LIST_AMOUNT_DUE'                 , 'AMOUNT_DUE_USDOLLAR'       , 'AMOUNT_DUE_USDOLLAR'       , '10%', 'Currency';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Invoices.ArchiveView'          ,  8, 'Invoices.LBL_LIST_DUE_DATE'                   , 'DUE_DATE'                  , 'DUE_DATE'                  , '10%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'Invoices.ArchiveView'          ,  9, '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Invoices.ArchiveView'          , 10, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'          , 'ASSIGNED_TO_NAME'          , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'Invoices.ArchiveView'          , 11, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'                 , 'TEAM_NAME'                 , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'Invoices.ArchiveView'          , 12, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'          , 'ARCHIVE_DATE_UTC'          , '10%', 'Date';
end -- if;
GO

if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'KBDocuments.ArchiveView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS KBDocuments.ArchiveView';
	exec dbo.spGRIDVIEWS_InsertOnly           'KBDocuments.ArchiveView'       , 'KBDocuments', 'vwKBDOCUMENTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'KBDocuments.ArchiveView'       ,  2, 'KBDocuments.LBL_LIST_NAME'                    , 'NAME'                      , 'NAME'                      , '20%', 'ArchiveViewTdLinkS1', 'ID', '~/KBDocuments/view.aspx?id={0}&ArchiveView=1', null, 'KBDocuments', 'ASSIGNED_USER_ID';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'KBDocuments.ArchiveView'       ,  3, 'KBDocuments.LBL_LIST_VIEW_FREQUENCY'          , 'VIEW_FREQUENCY'            , 'VIEW_FREQUENCY'            , '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'KBDocuments.ArchiveView'       ,  4, 'KBDocuments.LBL_LIST_KBDOC_APPROVER_NAME'     , 'KBDOC_APPROVER_NAME'       , 'KBDOC_APPROVER_NAME'       , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsTagSelect 'KBDocuments.ArchiveView'       ,  5, '10%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'KBDocuments.ArchiveView'       ,  6, '.LBL_LIST_DATE_ENTERED'                       , 'DATE_ENTERED'              , 'DATE_ENTERED'              , '15%', 'Date';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'KBDocuments.ArchiveView'       ,  7, '.LBL_LIST_ASSIGNED_USER'                      , 'ASSIGNED_TO_NAME'          , 'ASSIGNED_TO_NAME'          , '15%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'KBDocuments.ArchiveView'       ,  8, 'Teams.LBL_LIST_TEAM'                          , 'TEAM_NAME'                 , 'TEAM_NAME'                 , '5%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBoundDate 'KBDocuments.ArchiveView'       ,  9, '.LBL_LIST_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'          , 'ARCHIVE_DATE_UTC'          , '10%', 'Date';
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

call dbo.spGRIDVIEWS_COLUMNS_ArchiveView_Pro()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_ArchiveView_Pro')
/

-- #endif IBM_DB2 */

