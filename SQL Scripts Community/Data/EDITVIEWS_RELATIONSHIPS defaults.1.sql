

print 'EDITVIEWS_RELATIONSHIPS defaults';
--delete from EDITVIEWS_RELATIONSHIPS
--GO

set nocount on;
GO

-- 06/13/2010 Paul.  Remove Contracts subpanel. 
-- 06/13/2010 Paul.  Disable the Account relationships by default. 
-- delete from EDITVIEWS_RELATIONSHIPS where EDIT_NAME = 'Accounts.EditView';
if not exists(select * from EDITVIEWS_RELATIONSHIPS where EDIT_NAME = 'Accounts.EditView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_RELATIONSHIPS Accounts.EditView';
	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.EditView', 'Contacts'     , '~/Contacts/NewRecord'     ,  0,  0, 1, 0, 'Contacts.LBL_NEW_FORM_TITLE'     , null;
	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.EditView', 'Opportunities', '~/Opportunities/NewRecord',  0,  1, 1, 0, 'Opportunities.LBL_NEW_FORM_TITLE', 'EditView.Inline.Accounts';
	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.EditView', 'Cases'        , '~/Cases/NewRecord'        ,  0,  2, 1, 0, 'Cases.LBL_NEW_FORM_TITLE'        , 'EditView.Inline.Accounts';
	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly 'Accounts.EditView', 'Bugs'         , '~/Bugs/NewRecord'         ,  0,  3, 1, 0, 'Bugs.LBL_NEW_FORM_TITLE'         , null;
end -- if;
GO

-- 05/05/2010 Paul.  Home.EditView will be used on the SixToolbar. 
if not exists(select * from EDITVIEWS_RELATIONSHIPS where EDIT_NAME = 'Home.EditView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_RELATIONSHIPS Home.EditView';
	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly 'Home.EditView'    , 'Accounts'     , '~/Accounts/NewRecord'     ,  1,  0, 1, 0, 'Accounts.LBL_NEW_FORM_TITLE'     , null;
	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly 'Home.EditView'    , 'Contacts'     , '~/Contacts/NewRecord'     ,  1,  1, 1, 0, 'Contacts.LBL_NEW_FORM_TITLE'     , null;
	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly 'Home.EditView'    , 'Opportunities', '~/Opportunities/NewRecord',  1,  2, 1, 0, 'Opportunities.LBL_NEW_FORM_TITLE', null;
	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly 'Home.EditView'    , 'Leads'        , '~/Leads/NewRecord'        ,  1,  3, 1, 0, 'Leads.LBL_NEW_FORM_TITLE'        , null;
	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly 'Home.EditView'    , 'Cases'        , '~/Cases/NewRecord'        ,  1,  4, 1, 0, 'Cases.LBL_NEW_FORM_TITLE'        , null;
	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly 'Home.EditView'    , 'Bugs'         , '~/Bugs/NewRecord'         ,  1,  5, 1, 0, 'Bugs.LBL_NEW_FORM_TITLE'         , null;
	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly 'Home.EditView'    , 'Emails'       , '~/Emails/NewRecord'       ,  1,  6, 1, 0, 'Emails.LBL_NEW_FORM_TITLE'       , null;
	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly 'Home.EditView'    , 'Notes'        , '~/Notes/NewRecord'        ,  1,  7, 1, 0, 'Notes.LBL_NEW_FORM_TITLE'        , null;
	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly 'Home.EditView'    , 'Tasks'        , '~/Tasks/NewRecord'        ,  1,  8, 1, 0, 'Tasks.LBL_NEW_FORM_TITLE'        , null;
	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly 'Home.EditView'    , 'Meetings'     , '~/Meetings/NewRecord'     ,  1,  9, 1, 0, 'Meetings.LBL_NEW_FORM_TITLE'     , null;
	exec dbo.spEDITVIEWS_RELATIONSHIPS_InsertOnly 'Home.EditView'    , 'Calls'        , '~/Calls/NewRecord'        ,  1, 10, 1, 0, 'Calls.LBL_NEW_FORM_TITLE'        , null;
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

call dbo.spEDITVIEWS_RELATIONSHIPS_Defaults()
/

call dbo.spSqlDropProcedure('spEDITVIEWS_RELATIONSHIPS_Defaults')
/

-- #endif IBM_DB2 */

