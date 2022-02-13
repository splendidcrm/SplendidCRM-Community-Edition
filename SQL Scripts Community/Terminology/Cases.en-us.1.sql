

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:35 AM.
print 'TERMINOLOGY Cases en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'ERR_CASE_NOT_FOUND'                            , N'en-US', N'Cases', null, null, N'Case Not Found.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCOUNT_ID'                                , N'en-US', N'Cases', null, null, N'Account ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCOUNT_NAME'                              , N'en-US', N'Cases', null, null, N'Account Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CASE_NUMBER'                               , N'en-US', N'Cases', null, null, N'Case Number:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DESCRIPTION'                               , N'en-US', N'Cases', null, null, N'Description:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ACCOUNT_ID'                           , N'en-US', N'Cases', null, null, N'Account ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_ACCOUNT_NAME'                         , N'en-US', N'Cases', null, null, N'Account Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CASE_NUMBER'                          , N'en-US', N'Cases', null, null, N'Case Number';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_DESCRIPTION'                          , N'en-US', N'Cases', null, null, N'Description';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'Cases', null, null, N'Case List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MY_CASES'                             , N'en-US', N'Cases', null, null, N'My Cases';
-- 07/31/2017 Paul.  Add My Team dashlets. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MY_TEAM_CASES'                        , N'en-US', N'Cases', null, null, N'My Team Cases';
-- 07/31/2017 Paul.  Add My Favorite dashlets. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_MY_FAVORITE_CASES'                    , N'en-US', N'Cases', null, null, N'My Favorite Cases';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'Cases', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NUMBER'                               , N'en-US', N'Cases', null, null, N'Number';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_PRIORITY'                             , N'en-US', N'Cases', null, null, N'Priority';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_RESOLUTION'                           , N'en-US', N'Cases', null, null, N'Resolution';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_STATUS'                               , N'en-US', N'Cases', null, null, N'Status';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_SUBJECT'                              , N'en-US', N'Cases', null, null, N'Subject';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TYPE'                                 , N'en-US', N'Cases', null, null, N'Type';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_WORK_LOG'                             , N'en-US', N'Cases', null, null, N'Work Log';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'Cases', null, null, N'Cases';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'Cases', null, null, N'Cas';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'Cases', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NEW_FORM_TITLE'                            , N'en-US', N'Cases', null, null, N'Create Case';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PARENT_ID'                                 , N'en-US', N'Cases', null, null, N'Parent ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PARENT_NAME'                               , N'en-US', N'Cases', null, null, N'Parent Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PARENT_TYPE'                               , N'en-US', N'Cases', null, null, N'Parent Type:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_PRIORITY'                                  , N'en-US', N'Cases', null, null, N'Priority:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_RESOLUTION'                                , N'en-US', N'Cases', null, null, N'Resolution:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STATUS'                                    , N'en-US', N'Cases', null, null, N'Status:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_SUBJECT'                                   , N'en-US', N'Cases', null, null, N'Subject:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TYPE'                                      , N'en-US', N'Cases', null, null, N'Type:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_WORK_LOG'                                  , N'en-US', N'Cases', null, null, N'Work Log:';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_CASE_LIST'                                 , N'en-US', N'Cases', null, null, N'Cases';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_NEW_CASE'                                  , N'en-US', N'Cases', null, null, N'Create Case';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_REPORTS'                                   , N'en-US', N'Cases', null, null, N'Case Reports';
exec dbo.spTERMINOLOGY_InsertOnly N'NTC_REMOVE_FROM_BUG_CONFIRMATION'              , N'en-US', N'Cases', null, null, N'Are you sure?';
exec dbo.spTERMINOLOGY_InsertOnly N'NTC_REMOVE_INVITEE'                            , N'en-US', N'Cases', null, null, N'Are you sure?';
GO

-- 05/01/2013 Paul.  Add Contacts field to support B2C. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_B2C_CONTACT_ID'                            , N'en-US', N'Cases', null, null, N'Contact ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_B2C_CONTACT_NAME'                          , N'en-US', N'Cases', null, null, N'Contact Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_B2C_CONTACT_ID'                       , N'en-US', N'Cases', null, null, N'Contact ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_B2C_CONTACT_NAME'                     , N'en-US', N'Cases', null, null, N'Contact Name';

-- 08/29/2016 Paul.  Missing, but used in Business Process. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCOUNT_ASSIGNED_USER_ID'                  , N'en-US', N'Cases', null, null, N'Account Assigned User ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACCOUNT_EMAIL1'                            , N'en-US', N'Cases', null, null, N'Account Email:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_B2C_CONTACT_ASSIGNED_USER_ID'              , N'en-US', N'Cases', null, null, N'Contact Assigned User ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_B2C_CONTACT_EMAIL1'                        , N'en-US', N'Cases', null, null, N'Contact Email:';
-- 09/26/2017 Paul.  Add Archive access right. 
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_ARCHIVED_CASES'                            , N'en-US', N'Cases', null, null, N'Archived Cases';
GO

/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'Cases'                                         , N'en-US', null, N'moduleList'                        ,   6, N'Cases';
exec dbo.spTERMINOLOGY_InsertOnly N'Cases'                                         , N'en-US', null, N'moduleListSingular'                ,   6, N'Case';

exec dbo.spTERMINOLOGY_InsertOnly N'P1'                                            , N'en-US', null, N'case_priority_dom'                 ,   1, N'High';
exec dbo.spTERMINOLOGY_InsertOnly N'P2'                                            , N'en-US', null, N'case_priority_dom'                 ,   2, N'Medium';
exec dbo.spTERMINOLOGY_InsertOnly N'P3'                                            , N'en-US', null, N'case_priority_dom'                 ,   3, N'Low';

exec dbo.spTERMINOLOGY_InsertOnly N'New'                                           , N'en-US', null, N'case_status_dom'                   ,   1, N'New';
exec dbo.spTERMINOLOGY_InsertOnly N'Assigned'                                      , N'en-US', null, N'case_status_dom'                   ,   2, N'Assigned';
exec dbo.spTERMINOLOGY_InsertOnly N'Closed'                                        , N'en-US', null, N'case_status_dom'                   ,   3, N'Closed';
exec dbo.spTERMINOLOGY_InsertOnly N'Pending Input'                                 , N'en-US', null, N'case_status_dom'                   ,   4, N'Pending input';
exec dbo.spTERMINOLOGY_InsertOnly N'Rejected'                                      , N'en-US', null, N'case_status_dom'                   ,   5, N'Rejected';
exec dbo.spTERMINOLOGY_InsertOnly N'Duplicate'                                     , N'en-US', null, N'case_status_dom'                   ,   6, N'Duplicate';
GO

-- 04/02/2012 Paul.  Add Type field. 
-- 01/19/2013 Paul.  List name was not properly set to case_type_dom. 
exec dbo.spTERMINOLOGY_InsertOnly N'Administration'                                , N'en-US', null, N'case_type_dom'                     ,   1, N'Administration';
exec dbo.spTERMINOLOGY_InsertOnly N'Product'                                       , N'en-US', null, N'case_type_dom'                     ,   2, N'Product';
exec dbo.spTERMINOLOGY_InsertOnly N'User'                                          , N'en-US', null, N'case_type_dom'                     ,   3, N'User';
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

call dbo.spTERMINOLOGY_Cases_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_Cases_en_us')
/
-- #endif IBM_DB2 */
