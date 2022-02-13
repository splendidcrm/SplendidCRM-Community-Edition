

print 'TERMINOLOGY ModulesArchiveRules en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ARCHIVE_RULES_TITLE'                , N'en-US', N'Administration'     , null, null, N'Modules Archive Rules';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ARCHIVE_RULES'                      , N'en-US', N'Administration'     , null, null, N'Manage and run Modules Archive Rules';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'ModulesArchiveRules', null, null, N'Modules Archive Rules';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'ModulesArchiveRules', null, null, N'AR';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_ARCHIVE_RULE'                          , N'en-US', N'ModulesArchiveRules', null, null, N'Create Archive Rule';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_ARCHIVE_RULE_LIST'                         , N'en-US', N'ModulesArchiveRules', null, null, N'Archive Rules List';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'ModulesArchiveRules', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'ModulesArchiveRules', null, null, N'Module Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DESCRIPTION'                               , N'en-US', N'ModulesArchiveRules', null, null, N'Description:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STATUS'                                    , N'en-US', N'ModulesArchiveRules', null, null, N'Status:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'ModulesArchiveRules', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MODULE_NAME'                          , N'en-US', N'ModulesArchiveRules', null, null, N'Module';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_STATUS'                               , N'en-US', N'ModulesArchiveRules', null, null, N'Status';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PREVIEW_BUTTON'                            , N'en-US', N'ModulesArchiveRules', null, null, N'Preview Filter';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RUN_CONFIRMATION'                          , N'en-US', N'ModulesArchiveRules', null, null, N'Are you sure you want to run this Modules Archive Rule?';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RUN'                                       , N'en-US', N'ModulesArchiveRules', null, null, N'Run';

exec dbo.spTERMINOLOGY_InsertOnly N'ERR_FILTERS_REQUIRED'                          , N'en-US', N'ModulesArchiveRules', null, null, N'You must specify at least one filter, otherwise all records will be archived.';
-- 07/10/2018 Paul.  Don't run normal archive rules if external archive is enabled. 
exec dbo.spTERMINOLOGY_InsertOnly N'ERR_EXTERNAL_ARCHIVE_ONLY'                     , N'en-US', N'ModulesArchiveRules', null, null, N'Rules cannot be run manually when External Archive is enabled.';

exec dbo.spTERMINOLOGY_InsertOnly N'ModulesArchiveRules'                           , N'en-US', null, N'moduleList'             , 173, N'Modules Archive Rules';

-- 01/05/2021 Paul.  Status is a bit, so React Client treats as 1 and 0. 
exec dbo.spTERMINOLOGY_InsertOnly N'1'                                             , N'en-US', null, N'archive_rule_status_dom',   1, N'Active';
exec dbo.spTERMINOLOGY_InsertOnly N'0'                                             , N'en-US', null, N'archive_rule_status_dom',   2, N'Inactive';
if exists(select * from TERMINOLOGY where LANG = 'en-US' and NAME = 'True' and LIST_NAME = 'archive_rule_status_dom' and DELETED = 0) begin -- then
	update TERMINOLOGY
	   set NAME              = '1'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getdate()
	 where LANG              = 'en-US'
	   and NAME              = 'True'
	   and LIST_NAME         = 'archive_rule_status_dom'
	   and DELETED           = 0;
end -- if;
if exists(select * from TERMINOLOGY where LANG = 'en-US' and NAME = 'False' and LIST_NAME = 'archive_rule_status_dom' and DELETED = 0) begin -- then
	update TERMINOLOGY
	   set NAME              = '0'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getdate()
	 where LANG              = 'en-US'
	   and NAME              = 'False'
	   and LIST_NAME         = 'archive_rule_status_dom'
	   and DELETED           = 0;
end -- if;
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

call dbo.spTERMINOLOGY_ModulesArchiveRules_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_ModulesArchiveRules_en_us')
/
-- #endif IBM_DB2 */
