

print 'DETAILVIEWS_RELATIONSHIPS BusinessRules';
GO

set nocount on;
GO

-- 12/07/2010 Paul.  The Business Rules admin link should be visible in all editions. 
-- 10/13/2012 Paul.  Add table info for HTML5 Offline Client. 
if not exists(select * from DETAILVIEWS_RELATIONSHIPS where DETAIL_NAME = 'Administration.ListView' and CONTROL_NAME = 'WorkflowView' and DELETED = 0) begin -- then
	print 'DETAILVIEWS_RELATIONSHIPS Administration.ListView';
	exec dbo.spDETAILVIEWS_RELATIONSHIPS_InsertOnly 'Administration.ListView'   , 'Administration'   , 'WorkflowView'       ,  9, 'Administration.LBL_WORKFLOW_TITLE'            , null, null, null, null;
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

call dbo.spDETAILVIEWS_RELATIONSHIPS_BusinessRules()
/

call dbo.spSqlDropProcedure('spDETAILVIEWS_RELATIONSHIPS_BusinessRules')
/

-- #endif IBM_DB2 */

