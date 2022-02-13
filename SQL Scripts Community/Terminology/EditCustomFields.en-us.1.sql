

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:36 AM.
print 'TERMINOLOGY EditCustomFields en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'COLUMN_TITLE_AUDIT'                            , N'en-US', N'EditCustomFields', null, null, N'Audit';
exec dbo.spTERMINOLOGY_InsertOnly N'COLUMN_TITLE_DATA_TYPE'                        , N'en-US', N'EditCustomFields', null, null, N'Data Type';
exec dbo.spTERMINOLOGY_InsertOnly N'COLUMN_TITLE_DEFAULT_VALUE'                    , N'en-US', N'EditCustomFields', null, null, N'Default Value';
exec dbo.spTERMINOLOGY_InsertOnly N'COLUMN_TITLE_DROPDOWN'                         , N'en-US', N'EditCustomFields', null, null, N'Dropdown';
exec dbo.spTERMINOLOGY_InsertOnly N'COLUMN_TITLE_LABEL'                            , N'en-US', N'EditCustomFields', null, null, N'Field Label';
exec dbo.spTERMINOLOGY_InsertOnly N'COLUMN_TITLE_MAX_SIZE'                         , N'en-US', N'EditCustomFields', null, null, N'Max Size';
exec dbo.spTERMINOLOGY_InsertOnly N'COLUMN_TITLE_NAME'                             , N'en-US', N'EditCustomFields', null, null, N'Field Name';
exec dbo.spTERMINOLOGY_InsertOnly N'COLUMN_TITLE_REQUIRED_OPTION'                  , N'en-US', N'EditCustomFields', null, null, N'Required Field';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ADD_FIELD'                                 , N'en-US', N'EditCustomFields', null, null, N'Add Field:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CUSTOM_FIELDS'                             , N'en-US', N'EditCustomFields', null, null, N'Custom Fields';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DROPDOWN_LIST'                             , N'en-US', N'EditCustomFields', null, null, N'Dropdown List:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_INVALID_FIELD_NAME'                        , N'en-US', N'EditCustomFields', null, null, N'Invalid Field Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'EditCustomFields', null, null, N'Custom Fields';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE'                                    , N'en-US', N'EditCustomFields', null, null, N'Module';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'EditCustomFields', null, null, N'Edit Custom Fields';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'EditCustomFields', null, null, N'ECF';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_SELECT'                             , N'en-US', N'EditCustomFields', null, null, N'Module to Edit';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_TITLE'                              , N'en-US', N'EditCustomFields', null, null, N'Edit Custom Fields';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEARCH_FORM_TITLE'                         , N'en-US', N'EditCustomFields', null, null, N'Search';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_SELECT_CUSTOM_FIELD'                       , N'en-US', N'EditCustomFields', null, null, N'Select Custom Field';

-- 01/30/2021 Paul.  Add EditCustomFields support to React Client. 
exec dbo.spTERMINOLOGY_InsertOnly N'varchar'                                       , N'en-US', null, N'custom_field_type_dom',  1, N'Text';
exec dbo.spTERMINOLOGY_InsertOnly N'text'                                          , N'en-US', null, N'custom_field_type_dom',  2, N'Text Area';
exec dbo.spTERMINOLOGY_InsertOnly N'int'                                           , N'en-US', null, N'custom_field_type_dom',  3, N'Integer';
exec dbo.spTERMINOLOGY_InsertOnly N'float'                                         , N'en-US', null, N'custom_field_type_dom',  4, N'Decimal';
exec dbo.spTERMINOLOGY_InsertOnly N'bool'                                          , N'en-US', null, N'custom_field_type_dom',  5, N'Checkbox';
exec dbo.spTERMINOLOGY_InsertOnly N'date'                                          , N'en-US', null, N'custom_field_type_dom',  6, N'Date';
exec dbo.spTERMINOLOGY_InsertOnly N'enum'                                          , N'en-US', null, N'custom_field_type_dom',  7, N'Dropdown';
exec dbo.spTERMINOLOGY_InsertOnly N'guid'                                          , N'en-US', null, N'custom_field_type_dom',  8, N'Guid';
exec dbo.spTERMINOLOGY_InsertOnly N'guid'                                          , N'en-US', null, N'custom_field_type_dom',  9, N'Image';
exec dbo.spTERMINOLOGY_InsertOnly N'money'                                         , N'en-US', null, N'custom_field_type_dom', 10, N'Money';

GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'EditCustomFields'                              , N'en-US', null, N'moduleList'                        ,  69, N'Edit Custom Fields';
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

call dbo.spTERMINOLOGY_EditCustomFields_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_EditCustomFields_en_us')
/
-- #endif IBM_DB2 */
