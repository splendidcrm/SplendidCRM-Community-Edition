

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:37 AM.
print 'TERMINOLOGY FieldValidators en-us';
GO

set nocount on;
GO

-- 03/28/2019 Paul.  Every module should have a LBL_NEW_FORM_TITLE. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'FieldValidators', null, null, N'Field Validators';

exec dbo.spTERMINOLOGY_InsertOnly N'ERR_FIELD_VALIDATOR_NOT_FOUND'                 , N'en-US', N'FieldValidators', null, null, N'Field Validator Not Found.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_COMPARE_OPERATOR'                          , N'en-US', N'FieldValidators', null, null, N'Compare Operator:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DATA_TYPE'                                 , N'en-US', N'FieldValidators', null, null, N'Data Type:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_COMPARE_OPERATOR'                     , N'en-US', N'FieldValidators', null, null, N'Compare Operator';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DATA_TYPE'                            , N'en-US', N'FieldValidators', null, null, N'Data Type';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'FieldValidators', null, null, N'Field Validator List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MAXIMUM_VALUE'                        , N'en-US', N'FieldValidators', null, null, N'Maximum Value';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MININUM_VALUE'                        , N'en-US', N'FieldValidators', null, null, N'Mininum Value';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'FieldValidators', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_REGULAR_EXPRESSION'                   , N'en-US', N'FieldValidators', null, null, N'Regular Expression';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_VALIDATION_TYPE'                      , N'en-US', N'FieldValidators', null, null, N'Validation Type';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MAXIMUM_VALUE'                             , N'en-US', N'FieldValidators', null, null, N'Maximum Value:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MININUM_VALUE'                             , N'en-US', N'FieldValidators', null, null, N'Mininum Value:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'FieldValidators', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_REGULAR_EXPRESSION'                        , N'en-US', N'FieldValidators', null, null, N'Regular Expression:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_VALIDATION_TYPE'                           , N'en-US', N'FieldValidators', null, null, N'Validation Type:';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_FIELD_VALIDATOR_LIST'                      , N'en-US', N'FieldValidators', null, null, N'Field Validators';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_FIELD_VALIDATOR'                       , N'en-US', N'FieldValidators', null, null, N'Create Field Validator';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_REPORTS'                                   , N'en-US', N'FieldValidators', null, null, N'Field Validator Reports';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'FieldValidators', null, null, N'FV';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'FieldValidators'                               , N'en-US', null, N'moduleList'                        ,  82, N'Field Validators';
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

call dbo.spTERMINOLOGY_FieldValidators_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_FieldValidators_en_us')
/
-- #endif IBM_DB2 */
