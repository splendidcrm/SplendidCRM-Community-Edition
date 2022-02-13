

print 'DETAILVIEWS_FIELDS Professional';
-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME like '%.ArchiveView'
--GO

set nocount on;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Contracts.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Contracts.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Contracts.ArchiveView', 'Contracts', 'vwCONTRACTS_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contracts.ArchiveView'      , -1, 'Contracts.LBL_NAME'                      , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contracts.ArchiveView'      , -1, 'Contracts.LBL_START_DATE'                , 'START_DATE'                            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contracts.ArchiveView'      , -1, 'Contracts.LBL_REFERENCE_CODE'            , 'REFERENCE_CODE'                        , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contracts.ArchiveView'      , -1, 'Contracts.LBL_END_DATE'                  , 'END_DATE'                              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Contracts.ArchiveView'      , -1, 'Contracts.LBL_ACCOUNT_NAME'              , 'ACCOUNT_NAME'                          , '{0}'        , 'ACCOUNT_ID'          , '~/Accounts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Contracts.ArchiveView'      , -1, 'Contracts.LBL_STATUS'                    , 'STATUS'                                , '{0}'        , 'contract_status_dom' , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Contracts.ArchiveView'      , -1, 'Contracts.LBL_OPPORTUNITY_NAME'          , 'OPPORTUNITY_NAME'                      , '{0}'        , 'OPPORTUNITY_ID'      , '~/Opportunities/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contracts.ArchiveView'      , -1, 'Contracts.LBL_COMPANY_SIGNED_DATE'       , 'COMPANY_SIGNED_DATE'                   , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contracts.ArchiveView'      , -1, 'Contracts.LBL_CONTRACT_VALUE'            , 'TOTAL_CONTRACT_VALUE'                  , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contracts.ArchiveView'      , -1, 'Contracts.LBL_CUSTOMER_SIGNED_DATE'      , 'CUSTOMER_SIGNED_DATE'                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contracts.ArchiveView'      , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contracts.ArchiveView'      , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contracts.ArchiveView'      , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contracts.ArchiveView'      , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contracts.ArchiveView'      , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contracts.ArchiveView'      , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contracts.ArchiveView'      , -1, 'Contracts.LBL_EXPIRATION_NOTICE'         , 'EXPIRATION_NOTICE'                     , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Contracts.ArchiveView'      , -1, 'Contracts.LBL_TYPE'                      , 'TYPE'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags      'Contracts.ArchiveView'      , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Contracts.ArchiveView'      , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Contracts.ArchiveView'      , -1, 'TextBox', 'Contracts.LBL_DESCRIPTION'    , 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Quotes.ArchiveView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Quotes.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Quotes.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Quotes.ArchiveView', 'Quotes', 'vwQUOTES_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_NAME'                         , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_OPPORTUNITY_NAME'             , 'OPPORTUNITY_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_QUOTE_NUM'                    , 'QUOTE_NUM'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Quotes.ArchiveView'         , -1, 'Quotes.LBL_QUOTE_STAGE'                  , 'QUOTE_STAGE'                           , '{0}'        , 'quote_stage_dom' , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_PURCHASE_ORDER_NUM'           , 'PURCHASE_ORDER_NUM'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_DATE_VALID_UNTIL'             , 'DATE_QUOTE_EXPECTED_CLOSED'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Quotes.ArchiveView'         , -1, 'Quotes.LBL_PAYMENT_TERMS'                , 'PAYMENT_TERMS'                         , '{0}'        , 'payment_terms_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_ORIGINAL_PO_DATE'             , 'ORIGINAL_PO_DATE'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags      'Quotes.ArchiveView'         , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Quotes.ArchiveView'         , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Quotes.ArchiveView'         , -1, 'Quotes.LBL_BILLING_CONTACT_NAME'         , 'BILLING_CONTACT_NAME'                  , '{0}'        , 'BILLING_CONTACT_ID' , '~/Contacts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Quotes.ArchiveView'         , -1, 'Quotes.LBL_SHIPPING_CONTACT_NAME'        , 'SHIPPING_CONTACT_NAME'                 , '{0}'        , 'SHIPPING_CONTACT_ID', '~/Contacts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Quotes.ArchiveView'         , -1, 'Quotes.LBL_BILLING_ACCOUNT_NAME'         , 'BILLING_ACCOUNT_NAME'                  , '{0}'        , 'BILLING_ACCOUNT_ID' , '~/Accounts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Quotes.ArchiveView'         , -1, 'Quotes.LBL_SHIPPING_ACCOUNT_NAME'        , 'SHIPPING_ACCOUNT_NAME'                 , '{0}'        , 'SHIPPING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_BILLING_ADDRESS_STREET'       , 'BILLING_ADDRESS_STREET'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_SHIPPING_ADDRESS_STREET'      , 'SHIPPING_ADDRESS_STREET'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_BILLING_ADDRESS_CITY'         , 'BILLING_ADDRESS_CITY'                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_SHIPPING_ADDRESS_CITY'        , 'SHIPPING_ADDRESS_CITY'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_BILLING_ADDRESS_STATE'        , 'BILLING_ADDRESS_STATE'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_SHIPPING_ADDRESS_STATE'       , 'SHIPPING_ADDRESS_STATE'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_BILLING_ADDRESS_POSTALCODE'   , 'BILLING_ADDRESS_POSTALCODE'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_SHIPPING_ADDRESS_POSTALCODE'  , 'SHIPPING_ADDRESS_POSTALCODE'           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_BILLING_ADDRESS_COUNTRY'      , 'BILLING_ADDRESS_COUNTRY'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Quotes.ArchiveView'         , -1, 'Quotes.LBL_SHIPPING_ADDRESS_COUNTRY'     , 'SHIPPING_ADDRESS_COUNTRY'              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Quotes.ArchiveView'         , -1, 'TextBox', 'Quotes.LBL_DESCRIPTION'       , 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Orders.ArchiveView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Orders.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Orders.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Orders.ArchiveView', 'Orders', 'vwORDERS_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Orders.LBL_NAME'                         , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Orders.ArchiveView'       , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Orders.LBL_ORDER_NUM'                    , 'ORDER_NUM'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Orders.ArchiveView'         , -1, 'Orders.LBL_ORDER_STAGE'                  , 'ORDER_STAGE'                           , '{0}'        , 'order_stage_dom' , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Orders.LBL_PURCHASE_ORDER_NUM'           , 'PURCHASE_ORDER_NUM'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Orders.LBL_DATE_ORDER_DUE'               , 'DATE_ORDER_DUE'                        , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Orders.ArchiveView'         , -1, 'Orders.LBL_PAYMENT_TERMS'                , 'PAYMENT_TERMS'                         , '{0}'        , 'payment_terms_dom', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Orders.LBL_DATE_ORDER_SHIPPED'           , 'DATE_ORDER_SHIPPED'                    , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags      'Orders.ArchiveView'         , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Orders.ArchiveView'         , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Orders.ArchiveView'         , -1, 'Orders.LBL_BILLING_CONTACT_NAME'         , 'BILLING_CONTACT_NAME'                  , '{0}'        , 'BILLING_CONTACT_ID' , '~/Contacts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Orders.ArchiveView'         , -1, 'Orders.LBL_SHIPPING_CONTACT_NAME'        , 'SHIPPING_CONTACT_NAME'                 , '{0}'        , 'SHIPPING_CONTACT_ID', '~/Contacts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Orders.ArchiveView'         , -1, 'Orders.LBL_BILLING_ACCOUNT_NAME'         , 'BILLING_ACCOUNT_NAME'                  , '{0}'        , 'BILLING_ACCOUNT_ID' , '~/Accounts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Orders.ArchiveView'         , -1, 'Orders.LBL_SHIPPING_ACCOUNT_NAME'        , 'SHIPPING_ACCOUNT_NAME'                 , '{0}'        , 'SHIPPING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Orders.LBL_BILLING_ADDRESS_STREET'       , 'BILLING_ADDRESS_STREET'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Orders.LBL_SHIPPING_ADDRESS_STREET'      , 'SHIPPING_ADDRESS_STREET'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Orders.LBL_BILLING_ADDRESS_CITY'         , 'BILLING_ADDRESS_CITY'                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Orders.LBL_SHIPPING_ADDRESS_CITY'        , 'SHIPPING_ADDRESS_CITY'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Orders.LBL_BILLING_ADDRESS_STATE'        , 'BILLING_ADDRESS_STATE'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Orders.LBL_SHIPPING_ADDRESS_STATE'       , 'SHIPPING_ADDRESS_STATE'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Orders.LBL_BILLING_ADDRESS_POSTALCODE'   , 'BILLING_ADDRESS_POSTALCODE'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Orders.LBL_SHIPPING_ADDRESS_POSTALCODE'  , 'SHIPPING_ADDRESS_POSTALCODE'           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Orders.LBL_BILLING_ADDRESS_COUNTRY'      , 'BILLING_ADDRESS_COUNTRY'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Orders.ArchiveView'         , -1, 'Orders.LBL_SHIPPING_ADDRESS_COUNTRY'     , 'SHIPPING_ADDRESS_COUNTRY'              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Orders.ArchiveView'         , -1, 'TextBox', 'Orders.LBL_DESCRIPTION'       , 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'OrdersLineItems.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS OrdersLineItems.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'OrdersLineItems.ArchiveView', 'Orders', 'vwORDERS_LINE_ITEMS_Detail', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, 'Orders.LBL_ITEM_NAME'                    , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'OrdersLineItems.ArchiveView', -1, 'Orders.LBL_ITEM_TAX_CLASS'               , 'TAX_CLASS'                             , '{0}'        , 'tax_class_dom'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, 'Orders.LBL_ITEM_MFT_PART_NUM'            , 'MFT_PART_NUM'                          , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, 'Orders.LBL_ITEM_VENDOR_PART_NUM'         , 'VENDOR_PART_NUM'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, 'Orders.LBL_ITEM_QUANTITY'                , 'QUANTITY'                              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'OrdersLineItems.ArchiveView', -1, null;                                                                               
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, 'Orders.LBL_ITEM_COST_PRICE'              , 'COST_USDOLLAR'                         , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, 'Orders.LBL_ITEM_LIST_PRICE'              , 'LIST_USDOLLAR'                         , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, 'Orders.LBL_ITEM_UNIT_PRICE'              , 'UNIT_USDOLLAR'                         , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, 'Orders.LBL_ITEM_EXTENDED_PRICE'          , 'EXTENDED_USDOLLAR'                     , '{0:c}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'OrdersLineItems.ArchiveView', -1, 'TextBox', 'Orders.LBL_ITEM_DESCRIPTION'  , 'DESCRIPTION', null, null, null, null, null, 3, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'OrdersLineItems.ArchiveView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'OrdersLineItems.ArchiveView', -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, 'Products.LBL_SERIAL_NUMBER'              , 'SERIAL_NUMBER'                         , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, 'Products.LBL_ASSET_NUMBER'               , 'ASSET_NUMBER'                          , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, 'Orders.LBL_DATE_ORDER_SHIPPED'           , 'DATE_ORDER_SHIPPED'                    , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, 'Products.LBL_DATE_SUPPORT_EXPIRES'       , 'DATE_SUPPORT_EXPIRES'                  , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, 'Products.LBL_DATE_SUPPORT_STARTS'        , 'DATE_SUPPORT_STARTS'                   , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, 'Products.LBL_SUPPORT_NAME'               , 'SUPPORT_NAME'                          , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'OrdersLineItems.ArchiveView', -1, 'Products.LBL_SUPPORT_CONTACT'            , 'SUPPORT_CONTACT'                       , '{0}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'OrdersLineItems.ArchiveView', -1, 'Products.LBL_SUPPORT_TERM'               , 'SUPPORT_TERM'                          , '{0}', 'support_term_dom'   , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'OrdersLineItems.ArchiveView', -1, 'TextBox', 'Products.LBL_SUPPORT_DESCRIPTION', 'SUPPORT_DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

-- delete from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Invoices.ArchiveView';
if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'Invoices.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS Invoices.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'Invoices.ArchiveView', 'Invoices', 'vwINVOICES_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Invoices.LBL_NAME'                       , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Invoices.ArchiveView'       , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Invoices.LBL_INVOICE_NUM'                , 'INVOICE_NUM'                           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Invoices.ArchiveView'       , -1, 'Invoices.LBL_INVOICE_STAGE'              , 'INVOICE_STAGE'                         , '{0}'        , 'invoice_stage_dom' , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Invoices.ArchiveView'       , -1, 'Invoices.LBL_QUOTE_NAME'                 , 'QUOTE_NAME'                            , '{0}'        , 'QUOTE_ID'       , '~/Quotes/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'Invoices.ArchiveView'       , -1, 'Invoices.LBL_PAYMENT_TERMS'              , 'PAYMENT_TERMS'                         , '{0}'        , 'payment_terms_dom' , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Invoices.ArchiveView'       , -1, 'Invoices.LBL_ORDER_NAME'                 , 'ORDER_NAME'                            , '{0}'        , 'ORDER_ID'       , '~/Orders/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Invoices.LBL_DUE_DATE'                   , 'DUE_DATE'                              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Invoices.LBL_SHIP_DATE'                  , 'SHIP_DATE'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Invoices.LBL_PURCHASE_ORDER_NUM'         , 'PURCHASE_ORDER_NUM'                    , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, '.LBL_ASSIGNED_TO'                        , 'ASSIGNED_TO_NAME'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags      'Invoices.ArchiveView'       , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'Invoices.ArchiveView'       , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Invoices.ArchiveView'       , -1, 'Invoices.LBL_BILLING_CONTACT_NAME'       , 'BILLING_CONTACT_NAME'                  , '{0}'        , 'BILLING_CONTACT_ID' , '~/Contacts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Invoices.ArchiveView'       , -1, 'Invoices.LBL_SHIPPING_CONTACT_NAME'      , 'SHIPPING_CONTACT_NAME'                 , '{0}'        , 'SHIPPING_CONTACT_ID', '~/Contacts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Invoices.ArchiveView'       , -1, 'Invoices.LBL_BILLING_ACCOUNT_NAME'       , 'BILLING_ACCOUNT_NAME'                  , '{0}'        , 'BILLING_ACCOUNT_ID' , '~/Accounts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink 'Invoices.ArchiveView'       , -1, 'Invoices.LBL_SHIPPING_ACCOUNT_NAME'      , 'SHIPPING_ACCOUNT_NAME'                 , '{0}'        , 'SHIPPING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}&ArchiveView=1', null, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Invoices.LBL_BILLING_ADDRESS_STREET'     , 'BILLING_ADDRESS_STREET'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Invoices.LBL_SHIPPING_ADDRESS_STREET'    , 'SHIPPING_ADDRESS_STREET'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Invoices.LBL_BILLING_ADDRESS_CITY'       , 'BILLING_ADDRESS_CITY'                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Invoices.LBL_SHIPPING_ADDRESS_CITY'      , 'SHIPPING_ADDRESS_CITY'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Invoices.LBL_BILLING_ADDRESS_STATE'      , 'BILLING_ADDRESS_STATE'                 , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Invoices.LBL_SHIPPING_ADDRESS_STATE'     , 'SHIPPING_ADDRESS_STATE'                , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Invoices.LBL_BILLING_ADDRESS_POSTALCODE' , 'BILLING_ADDRESS_POSTALCODE'            , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Invoices.LBL_SHIPPING_ADDRESS_POSTALCODE', 'SHIPPING_ADDRESS_POSTALCODE'           , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Invoices.LBL_BILLING_ADDRESS_COUNTRY'    , 'BILLING_ADDRESS_COUNTRY'               , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'Invoices.ArchiveView'       , -1, 'Invoices.LBL_SHIPPING_ADDRESS_COUNTRY'   , 'SHIPPING_ADDRESS_COUNTRY'              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'Invoices.ArchiveView'       , -1, 'TextBox', 'Invoices.LBL_DESCRIPTION'     , 'DESCRIPTION', null, null, null, null, null, 3, null;
end -- if;
GO

if not exists(select * from DETAILVIEWS_FIELDS where DETAIL_NAME = 'KBDocuments.ArchiveView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_FIELDS KBDocuments.ArchiveView';
	exec dbo.spDETAILVIEWS_InsertOnly          'KBDocuments.ArchiveView', 'KBDocuments', 'vwKBDOCUMENTS_ARCHIVE', '15%', '35%', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'KBDocuments.ArchiveView'    , -1, 'KBDocuments.LBL_NAME'                    , 'NAME'                                  , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'KBDocuments.ArchiveView'    , -1, 'KBDocuments.LBL_REVISION'                , 'REVISION'                              , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBoundList 'KBDocuments.ArchiveView'    , -1, 'KBDocuments.LBL_STATUS'                  , 'STATUS'                                , '{0}'        , 'kbdocument_status_dom'     , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'KBDocuments.ArchiveView'    , -1, 'Teams.LBL_TEAM'                          , 'TEAM_NAME'                             , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'KBDocuments.ArchiveView'    , -1, 'KBDocuments.LBL_ACTIVE_DATE'             , 'ACTIVE_DATE'                           , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'KBDocuments.ArchiveView'    , -1, 'KBDocuments.LBL_EXP_DATE'                , 'EXP_DATE'                              , '{0:d}'      , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'KBDocuments.ArchiveView'    , -1, '.LBL_DATE_ENTERED'                       , 'DATE_ENTERED .LBL_BY CREATED_BY_NAME'  , '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'KBDocuments.ArchiveView'    , -1, '.LBL_DATE_MODIFIED'                      , 'DATE_MODIFIED .LBL_BY MODIFIED_BY_NAME', '{0} {1} {2}', null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'KBDocuments.ArchiveView'    , -1, '.LBL_ARCHIVE_DATE_UTC'                   , 'ARCHIVE_DATE_UTC'                      , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBound     'KBDocuments.ArchiveView'    , -1, '.LBL_ARCHIVE_USER_ID'                    , 'ARCHIVE_BY_NAME'                       , '{0}'        , null;
	exec dbo.spDETAILVIEWS_FIELDS_InsTags      'KBDocuments.ArchiveView'    , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsBlank     'KBDocuments.ArchiveView'    , -1, null;
	exec dbo.spDETAILVIEWS_FIELDS_InsertOnly   'KBDocuments.ArchiveView'    , -1, 'TextBox', 'KBDocuments.LBL_DESCRIPTION'  , 'DESCRIPTION', '10,90', null, null, null, null, 3, null;
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

call dbo.spDETAILVIEWS_FIELDS_ArchiveViewPro()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_FIELDS_ArchiveViewPro')
/

-- #endif IBM_DB2 */

