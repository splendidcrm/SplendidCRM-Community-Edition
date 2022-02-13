

print 'SHORTCUTS RulesWizard';
-- delete SHORTCUTS
GO

set nocount on;
GO

-- delete from SHORTCUTS where MODULE_NAME = 'RulesWizard';
if not exists (select * from SHORTCUTS where MODULE_NAME = 'RulesWizard' and DELETED = 0) begin -- then
	exec dbo.spSHORTCUTS_InsertOnly null, 'RulesWizard'           , 'RulesWizard.LBL_CREATE_BUTTON_LABEL'          , '~/RulesWizard/edit.aspx'                  , 'CreateRule.gif'     , 1,  1, 'RulesWizard', 'edit';
	exec dbo.spSHORTCUTS_InsertOnly null, 'RulesWizard'           , 'RulesWizard.LNK_RULES'                        , '~/RulesWizard/default.aspx'               , 'Rules.gif'          , 1,  2, 'RulesWizard', 'list';
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

call dbo.spSHORTCUTS_RulesWizard()
/

call dbo.spSqlDropProcedure('spSHORTCUTS_RulesWizard')
/

-- #endif IBM_DB2 */

