

print 'TERMINOLOGY OutboundSms en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'OutboundSms' or NAME = 'OutboundSms';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'OutboundSms', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FROM_NUMBER'                          , N'en-US', N'OutboundSms', null, null, N'From Number';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_USER_ID'                              , N'en-US', N'OutboundSms', null, null, N'User ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_USER_NAME'                            , N'en-US', N'OutboundSms', null, null, N'User';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'OutboundSms', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FROM_NUMBER'                               , N'en-US', N'OutboundSms', null, null, N'From Number:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USER_ID'                                   , N'en-US', N'OutboundSms', null, null, N'User ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USER_NAME'                                 , N'en-US', N'OutboundSms', null, null, N'User:';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_TITLE'                              , N'en-US', N'OutboundSms', null, null, N'Text Numbers';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_OUTBOUND_SMS_LIST'                         , N'en-US', N'OutboundSms', null, null, N'Text Numbers';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_OUTBOUND_SMS'                          , N'en-US', N'OutboundSms', null, null, N'Create Text Number';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_OUTBOUND_SMS'                       , N'en-US', N'OutboundSms', null, null, N'Text Numbers';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MANAGE_OUTBOUND_SMS_DESC'                  , N'en-US', N'OutboundSms', null, null, N'Manage Text Numbers.';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'OutboundSms', null, null, N'OSm';

exec dbo.spTERMINOLOGY_InsertOnly N'OutboundSms'                                 , N'en-US', null, N'moduleList', 118, N'Text Numbers';
GO


set nocount off;
GO

/* -- #if Oracle
	COMMIT WORK;
END;
/
-- #endif Oracle */

/* -- #if IBM_DB2
	commit;
  end
/

call dbo.spTERMINOLOGY_OutboundSms_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_OutboundSms_en_us')
/
-- #endif IBM_DB2 */
