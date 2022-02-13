

-- 09/03/2017 Paul.  Add nulls for, PICTURE and MAIL_ fields. 
if not exists(select * from USERS where ID = '00000000-0000-0000-0000-00000000000E') begin -- then
	print 'USERS CampaignManager';
/* -- #if IBM_DB2
	exec dbo.spUSERS_Update in_USER_ID , '00000000-0000-0000-0000-00000000000E', 'campaignmanager', null, 'Campaign Manager', null, 0, 0, null, null, null, null, null, null, null, null, null, null, 'Inactive', null, null, null, null, null, null, 0, null, null, null, null, null, 0, null, 0, null, null, 0, 0, 0, null, null, null, 0, 0, null, null, null, null, null, null, null, null;
-- #endif IBM_DB2 */
/* -- #if Oracle
	exec dbo.spUSERS_Update in_USER_ID , '00000000-0000-0000-0000-00000000000E', 'campaignmanager', null, 'Campaign Manager', null, 0, 0, null, null, null, null, null, null, null, null, null, null, 'Inactive', null, null, null, null, null, null, 0, null, null, null, null, null, 0, null, 0, null, null, 0, 0, 0, null, null, null, 0, 0, null, null, null, null, null, null, null, null;
-- #endif Oracle */
-- #if SQL_Server /*
	exec dbo.spUSERS_Update         '00000000-0000-0000-0000-00000000000E', '00000000-0000-0000-0000-00000000000E', 'campaignmanager', null, 'Campaign Manager', null, 0, 0, null, null, null, null, null, null, null, null, null, null, 'Inactive', null, null, null, null, null, null, 0, null, null, null, null, null, 0, null, 0, null, null, 0, 0, 0, null, null, null, 0, 0, null, null, null, null, null, null, null, null;
-- #endif SQL_Server */
	exec dbo.spUSERS_PasswordUpdate '00000000-0000-0000-0000-00000000000E', '00000000-0000-0000-0000-00000000000E', '838bd1a68578bfde4c7d43fe02cb4ed9';
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

call dbo.spUSERS_CampaignManager()
/

call dbo.spSqlDropProcedure('spUSERS_CampaignManager')
/

-- #endif IBM_DB2 */


