

print 'MODULES RulesWizard';
GO

set nocount on;
GO

-- 09/12/2011 Paul.  REST_ENABLED provides a way to enable/disable a module in the REST API. 
exec dbo.spMODULES_InsertOnly null, 'RulesWizard', 'RulesWizard.LBL_LIST_FORM_TITLE', '~/RulesWizard/', 1, 1, 22, 0, 0, 0, 0, 0, 'RULES', 0, 1, 0, 0, 0, 0;
-- 05/19/2021 Paul.  ReportRules is needed by the React client. 
if exists(select * from vwMODULES where MODULE_NAME = 'RulesWizard' and (REST_ENABLED = 0 or REST_ENABLED is null)) begin -- then
	if not exists(select * from CONFIG where NAME = 'Module.Config.Level') or exists(select * from CONFIG where NAME = 'Module.Config.Level' and cast(VALUE as float) < 13.0) begin -- then
		update MODULES
		   set REST_ENABLED         = 1
		     , MODIFIED_USER_ID     = null    
		     , DATE_MODIFIED        =  getdate()           
		     , DATE_MODIFIED_UTC    =  getutcdate()        
		 where MODULE_NAME          = 'RulesWizard'
		   and DELETED              = 0;
	end -- if;
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

call dbo.spMODULES_RulesWizard()
/

call dbo.spSqlDropProcedure('spMODULES_RulesWizard')
/

-- #endif IBM_DB2 */

