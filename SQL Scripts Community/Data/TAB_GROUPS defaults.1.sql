

print 'TAB_GROUPS defaults';
GO

set nocount on;
GO

-- 02/25/2010 Paul.  We need a flag to determine if the group is displayed on the menu. 
if exists(select * from TAB_GROUPS where GROUP_MENU is null and DELETED = 0) begin -- then
	update TAB_GROUPS
	   set DELETED           = 1
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	     , MODIFIED_USER_ID  = null
	 where GROUP_MENU is null
	   and DELETED           = 0;
end -- if;

exec dbo.spTAB_GROUPS_InsertOnly 'All'          , '.LBL_TABGROUP_ALL'          , 0, 0;
exec dbo.spTAB_GROUPS_InsertOnly 'Home'         , '.LBL_TABGROUP_HOME'         , 0, 1;
exec dbo.spTAB_GROUPS_InsertOnly 'Sales'        , '.LBL_TABGROUP_SALES'        , 1, 1;
exec dbo.spTAB_GROUPS_InsertOnly 'Marketing'    , '.LBL_TABGROUP_MARKETING'    , 2, 1;
exec dbo.spTAB_GROUPS_InsertOnly 'Support'      , '.LBL_TABGROUP_SUPPORT'      , 3, 1;
exec dbo.spTAB_GROUPS_InsertOnly 'Activities'   , '.LBL_TABGROUP_ACTIVITIES'   , 4, 1;
exec dbo.spTAB_GROUPS_InsertOnly 'Collaboration', '.LBL_TABGROUP_COLLABORATION', 5, 1;
exec dbo.spTAB_GROUPS_InsertOnly 'Tools'        , '.LBL_TABGROUP_TOOLS'        , 6, 0;
exec dbo.spTAB_GROUPS_InsertOnly 'Reports'      , '.LBL_TABGROUP_REPORTS'      , 7, 1;
exec dbo.spTAB_GROUPS_InsertOnly 'Other'        , '.LBL_TABGROUP_OTHER'        , 8, 0;
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

call dbo.spTAB_GROUPS_Defaults()
/

call dbo.spSqlDropProcedure('spTAB_GROUPS_Defaults')
/

-- #endif IBM_DB2 */

