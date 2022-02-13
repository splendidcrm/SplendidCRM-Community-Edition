

print 'ACL_ACTIONS defaults';
GO

set nocount on;
GO

exec dbo.spACL_ACTIONS_Initialize;
GO

-- 05/28/2007 Paul.  Delete duplicate ProjectTasks categories. 
if exists (select * from ACL_ACTIONS where Category = 'ProjectTasks' and DELETED = 0) begin -- then
	print 'Delete the invalid ProjectTasks category from ACL_ACTIONS.';
	update ACL_ACTIONS
	   set DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	     , DELETED          = 1
	 where Category         = 'ProjectTasks'
	   and DELETED          = 0;
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

call dbo.spACL_ACTIONS_Defaults()
/

call dbo.spSqlDropProcedure('spACL_ACTIONS_Defaults')
/

-- #endif IBM_DB2 */

