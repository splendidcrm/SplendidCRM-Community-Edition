

print 'DYNAMIC_BUTTONS EditView CurrecyLayer';

set nocount on;
GO

-- 04/30/2016 Paul.  Add CurrencyLayer. 
-- delete from DYNAMIC_BUTTONS where VIEW_NAME = 'CurrencyLayer.ConfigView';
if not exists(select * from DYNAMIC_BUTTONS where VIEW_NAME = 'CurrencyLayer.ConfigView' and DELETED = 0) begin -- then
	exec dbo.spDYNAMIC_BUTTONS_InsButton  'CurrencyLayer.ConfigView', 0, null, 'edit', null, null, 'Save'  , null, '.LBL_SAVE_BUTTON_LABEL'               , '.LBL_SAVE_BUTTON_TITLE'               , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton  'CurrencyLayer.ConfigView', 1, null, null  , null, null, 'Cancel', null, '.LBL_CANCEL_BUTTON_LABEL'             , '.LBL_CANCEL_BUTTON_TITLE'             , null, null, null;
	exec dbo.spDYNAMIC_BUTTONS_InsButton  'CurrencyLayer.ConfigView', 2, null, null  , null, null, 'Test'  , null, '.LBL_TEST_BUTTON_LABEL'               , '.LBL_TEST_BUTTON_TITLE'               , null, null, null;
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

call dbo.spDYNAMIC_BUTTONS_EditView_CurrencyLayer()
/

call dbo.spSqlDropProcedure('spDYNAMIC_BUTTONS_EditView_CurrencyLayer')
/

-- #endif IBM_DB2 */

