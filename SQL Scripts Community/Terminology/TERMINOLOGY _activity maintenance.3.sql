

-- 02/01/2011 Paul.  Fix Activities to use Subject instead of name. 
if exists(select *
            from TERMINOLOGY
           where NAME             = 'LBL_NAME'
             and LANG             = 'en-US'
             and MODULE_NAME      in ('Calls', 'Meetings', 'Emails', 'Notes', 'Tasks')
             and DISPLAY_NAME     = 'Name:') begin -- then
	print 'Fix Activities.LBL_NAME';
	update TERMINOLOGY
	   set DISPLAY_NAME      = 'Subject:'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where NAME              = 'LBL_NAME'
	   and LANG              = 'en-US'
	   and MODULE_NAME      in ('Calls', 'Meetings', 'Emails', 'Notes', 'Tasks')
	   and DISPLAY_NAME      = 'Name:';
end -- if;
if exists(select *
            from TERMINOLOGY
           where NAME             = 'LBL_LIST_NAME'
             and LANG             = 'en-US'
             and MODULE_NAME      in ('Calls', 'Meetings', 'Emails', 'Notes', 'Tasks')
             and DISPLAY_NAME     = 'Name') begin -- then
	print 'Fix Activities.LBL_LIST_NAME';
	update TERMINOLOGY
	   set DISPLAY_NAME      = 'Subject'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where NAME              = 'LBL_LIST_NAME'
	   and LANG              = 'en-US'
	   and MODULE_NAME       in ('Calls', 'Meetings', 'Emails', 'Notes', 'Tasks')
	   and DISPLAY_NAME      = 'Name';
end -- if;
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

call dbo.spTERMINOLOGY_activity_maintenance()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_activity_maintenance')
/

-- #endif IBM_DB2 */

