

print 'SHORTCUTS BusinessRules';
-- delete SHORTCUTS
GO

set nocount on;
GO

-- delete from SHORTCUTS where MODULE_NAME = 'BusinessRules';
if not exists (select * from SHORTCUTS where MODULE_NAME = 'BusinessRules' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'BusinessRules'           , 'BusinessRules.LBL_CREATE_BUTTON_LABEL'          , '~/Administration/BusinessRules/edit.aspx'   , 'CreateRule.gif', 1,  1, 'BusinessRules', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'BusinessRules'           , 'BusinessRules.LNK_RULES'                        , '~/Administration/BusinessRules/default.aspx', 'Rules.gif'     , 1,  2, 'BusinessRules', 'list';
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

call dbo.spSHORTCUTS_BusinessRules()
/

call dbo.spSqlDropProcedure('spSHORTCUTS_BusinessRules')
/

-- #endif IBM_DB2 */

