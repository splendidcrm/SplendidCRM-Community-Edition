

print 'ACL_ROLES ReadOnly';
GO
-- delete ACL_ROLES
set nocount on;
GO

if exists(select *
	    from            MODULES
	         inner join ACL_ACTIONS
	                 on ACL_ACTIONS.CATEGORY = MODULE_NAME
	                and ACL_ACTIONS.DELETED  = 0
	    left outer join ACL_ROLES_ACTIONS
	                 on ACL_ROLES_ACTIONS.ACTION_ID = ACL_ACTIONS.ID
	                and ACL_ROLES_ACTIONS.ROLE_ID   = '5E1B75FC-6885-41CA-8ED9-7A26E72A8FA9'
	                and ACL_ROLES_ACTIONS.DELETED   = 0
	   where MODULES.DELETED  = 0
	     and ACL_ACTIONS.NAME in (N'access', N'view', N'list', N'edit', N'delete', N'import', N'export', N'admin', N'archive')
	     and MODULES.IS_ADMIN = 0
	     and ACL_ROLES_ACTIONS.ID is null
	 ) begin -- then
	exec dbo.spACL_ROLES_InsertOnly '5E1B75FC-6885-41CA-8ED9-7A26E72A8FA9', 'Read-Only Role', 'Read-Only access to core modules.';
	
	-- Access (Enabled = 89, Disabled = -98)
	-- View (All = 90, Owner = 75, None -99)
	-- delete from ACL_ROLES_ACTIONS where ROLE_ID = '5E1B75FC-6885-41CA-8ED9-7A26E72A8FA9';
	insert into ACL_ROLES_ACTIONS
		( ID
		, ROLE_ID
		, ACTION_ID
		, ACCESS_OVERRIDE
		)
	select newid()
	     , '5E1B75FC-6885-41CA-8ED9-7A26E72A8FA9'
	     , ACL_ACTIONS.ID
	     , (case ACL_ACTIONS.NAME
	        when N'access'  then 89
	        when N'view'    then 89
	        when N'list'    then 89
	        when N'edit'    then -99
	        when N'delete'  then -99
	        when N'import'  then -99
	        when N'export'  then -99
	        when N'admin'   then -99
	        when N'archive' then -99
	        end)
	  from            MODULES
	       inner join ACL_ACTIONS
	               on ACL_ACTIONS.CATEGORY = MODULE_NAME
	              and ACL_ACTIONS.DELETED  = 0
	  left outer join ACL_ROLES_ACTIONS
	               on ACL_ROLES_ACTIONS.ACTION_ID = ACL_ACTIONS.ID
	              and ACL_ROLES_ACTIONS.ROLE_ID   = '5E1B75FC-6885-41CA-8ED9-7A26E72A8FA9'
	              and ACL_ROLES_ACTIONS.DELETED   = 0
	 where MODULES.DELETED  = 0
	   and ACL_ACTIONS.NAME in (N'access', N'view', N'list', N'edit', N'delete', N'import', N'export', N'admin', N'archive')
	   and MODULES.IS_ADMIN = 0
	   and ACL_ROLES_ACTIONS.ID is null
	 order by MODULES.MODULE_NAME, ACL_ACTIONS.NAME;
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

call dbo.spACL_ROLES_ReadOnly()
/

call dbo.spSqlDropProcedure('spACL_ROLES_ReadOnly')
/

-- #endif IBM_DB2 */

