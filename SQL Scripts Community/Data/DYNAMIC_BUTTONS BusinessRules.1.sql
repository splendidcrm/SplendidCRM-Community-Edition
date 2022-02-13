

print 'DYNAMIC_BUTTONS BusinessRules';
GO

set nocount on;
GO

-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'BusinessRules.EditView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'BusinessRules.EditView' and DELETED = 0) begin -- then
	print 'DYNAMIC_BUTTONS BusinessRules.EditView';
	exec dbo.spDYNAMIC_BUTTONS_InsButton 'BusinessRules.EditView'    , 0, 'BusinessRules'   , 'edit', null              , null, 'Save'                    , null, '.LBL_SAVE_BUTTON_LABEL'        , '.LBL_SAVE_BUTTON_TITLE'        , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsCancel 'BusinessRules.EditView'    , 1, 'BusinessRules'   , 0;
end -- if;
GO

exec dbo.spDYNAMIC_BUTTONS_CopyDefault '.PopupView', 'BusinessRules.PopupView'     , 'BusinessRules'     ;
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

call dbo.spDYNAMIC_BUTTONS_BusinessRules()
/

call dbo.spSqlDropProcedure('spDYNAMIC_BUTTONS_BusinessRules')
/

-- #endif IBM_DB2 */

