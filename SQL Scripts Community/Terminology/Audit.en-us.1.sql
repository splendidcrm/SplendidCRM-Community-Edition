

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:35 AM.
print 'TERMINOLOGY Audit en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AUDIT_ACTION'                              , N'en-US', N'Audit', null, null, N'Action:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_AUDIT_ITEM'                                , N'en-US', N'Audit', null, null, N'Item:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CHANGED_BY'                                , N'en-US', N'Audit', null, null, N'Changed By:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FIELD_NAME'                                , N'en-US', N'Audit', null, null, N'Field Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_AUDIT_ACTION'                         , N'en-US', N'Audit', null, null, N'Action';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_AUDIT_ITEM'                           , N'en-US', N'Audit', null, null, N'Item';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DATE'                                 , N'en-US', N'Audit', null, null, N'Change Date';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MODULE_NAME'                          , N'en-US', N'Audit', null, null, N'Module';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Audit', null, null, N'Module:';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Audit', null, null, N'Aud';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_VALUE'                                 , N'en-US', N'Audit', null, null, N'New Value';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_OLD_NAME'                                  , N'en-US', N'Audit', null, null, N'Old Value';
-- 06/28/2018 Paul.  Personal Information popup. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FIELD'                                , N'en-US', N'Audit', null, null, N'Field';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_VALUE'                                , N'en-US', N'Audit', null, null, N'Value';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LEAD_SOURCE'                          , N'en-US', N'Audit', null, null, N'Source';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_LAST_UPDATED'                         , N'en-US', N'Audit', null, null, N'Last Updated';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */

exec dbo.spTERMINOLOGY_InsertOnly N'-1'                                            , N'en-US', null, N'audit_action_dom'                  ,   1, N'Delete';
exec dbo.spTERMINOLOGY_InsertOnly N'0'                                             , N'en-US', null, N'audit_action_dom'                  ,   2, N'Insert';
exec dbo.spTERMINOLOGY_InsertOnly N'1'                                             , N'en-US', null, N'audit_action_dom'                  ,   3, N'Update';
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

call dbo.spTERMINOLOGY_Audit_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Audit_en_us')
/
-- #endif IBM_DB2 */
