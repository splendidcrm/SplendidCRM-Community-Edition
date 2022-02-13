

print 'TERMINOLOGY NumberSequences en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'NumberSequences', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ALPHA_PREFIX'                              , N'en-US', N'NumberSequences', null, null, N'Alpha Prefix:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ALPHA_SUFFIX'                              , N'en-US', N'NumberSequences', null, null, N'Alpha Suffix:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SEQUENCE_STEP'                             , N'en-US', N'NumberSequences', null, null, N'Sequence Step:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NUMERIC_PADDING'                           , N'en-US', N'NumberSequences', null, null, N'Numeric Padding:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CURRENT_VALUE'                             , N'en-US', N'NumberSequences', null, null, N'Current Value:';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'NumberSequences', null, null, N'Number Sequences';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'NumberSequences', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ALPHA_PREFIX'                         , N'en-US', N'NumberSequences', null, null, N'Prefix';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ALPHA_SUFFIX'                         , N'en-US', N'NumberSequences', null, null, N'Suffix';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SEQUENCE_STEP'                        , N'en-US', N'NumberSequences', null, null, N'Step';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NUMERIC_PADDING'                      , N'en-US', N'NumberSequences', null, null, N'Padding';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CURRENT_VALUE'                        , N'en-US', N'NumberSequences', null, null, N'Value';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'NumberSequences', null, null, N'Seq';


GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'NumberSequences'                                 , N'en-US', null, N'moduleList'                        , 102, N'Number Sequences';
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

call dbo.spTERMINOLOGY_NumberSequences_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_NumberSequences_en_us')
/
-- #endif IBM_DB2 */
