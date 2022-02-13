

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:42 AM.
print 'TERMINOLOGY UserSignatures en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'UserSignatures', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PRIMARY_SIGNATURE'                    , N'en-US', N'UserSignatures', null, null, N'Primary';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SIGNATURE'                            , N'en-US', N'UserSignatures', null, null, N'Signature';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SIGNATURE_HTML'                       , N'en-US', N'UserSignatures', null, null, N'Signature';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_USER_ID'                              , N'en-US', N'UserSignatures', null, null, N'User';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'UserSignatures', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SIGNATURE'                                 , N'en-US', N'UserSignatures', null, null, N'Signature:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SIGNATURE_HTML'                            , N'en-US', N'UserSignatures', null, null, N'Signature:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PRIMARY_SIGNATURE'                         , N'en-US', N'UserSignatures', null, null, N'Primary Signature:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_USER_ID'                                   , N'en-US', N'UserSignatures', null, null, N'User:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MY_SIGNATURES'                             , N'en-US', N'UserSignatures', null, null, N'My Signatures';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'UserSignatures', null, null, N'UsS';
-- 05/28/2020 Paul.  React Client allows list view for signatures. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'UserSignatures', null, null, N'User Signatures';

exec dbo.spTERMINOLOGY_InsertOnly N'UserSignatures'                                , N'en-US', null, N'moduleList'                        , 108, N'UserSignatures';
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

call dbo.spTERMINOLOGY_UserSignatures_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_UserSignatures_en_us')
/
-- #endif IBM_DB2 */
