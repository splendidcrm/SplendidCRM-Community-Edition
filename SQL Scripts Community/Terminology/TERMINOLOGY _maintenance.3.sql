

-- 02/16/2011 Paul.  Fix URL for ChangePassword.  It had a single " and not enclosing double quotes. 
if exists(select *
            from TERMINOLOGY
           where NAME         = 'LBL_RESET_PASSWORD_BODY'
             and LANG         = 'en-US'
             and MODULE_NAME  = 'Users'
             and DISPLAY_NAME like '%<a href={0}">%') begin -- then
	print 'Fix Users.LBL_RESET_PASSWORD_BODY';
	update TERMINOLOGY
	   set DISPLAY_NAME  = N'<p>A password reset was requested.</p><p>Please click the following link to reset your password:</p><p><a href="{0}">{0}</a></p>'
	     , DATE_MODIFIED = getdate()
	 where NAME          = 'LBL_RESET_PASSWORD_BODY'
	   and LANG          = 'en-US'
	   and MODULE_NAME   = 'Users'
	   and DISPLAY_NAME  like '%<a href={0}">%';
end -- if;
GO

-- 09/14/2012 Paul.  Fix spelling for ERR_CONCURRENCY_EXCEPTION. 
if exists(select *
            from TERMINOLOGY
           where NAME         = 'ERR_CONCURRENCY_EXCEPTION'
             and MODULE_NAME  is null
             and DISPLAY_NAME like '% lated %') begin -- then
	update TERMINOLOGY
	   set DISPLAY_NAME  = replace(DISPLAY_NAME, ' lated ', ' last ')
	     , DATE_MODIFIED = getdate()
	 where NAME          = 'ERR_CONCURRENCY_EXCEPTION'
	   and MODULE_NAME   is null
	   and DISPLAY_NAME like '% lated %';
end -- if;
GO

-- 08/07/2013 Paul.  Change My Account to Profile. 
if exists(select *
            from TERMINOLOGY
           where NAME         = 'LBL_MY_ACCOUNT'
             and MODULE_NAME  is null
             and DISPLAY_NAME = 'My Account') begin -- then
	update TERMINOLOGY
	   set DISPLAY_NAME      = 'Profile'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getdate()
	 where NAME         = 'LBL_MY_ACCOUNT'
	   and MODULE_NAME  is null
	   and DISPLAY_NAME = 'My Account';
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

call dbo.spTERMINOLOGY_maintenance()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_maintenance')
/

-- #endif IBM_DB2 */

