

print 'DASHLETS html5';
--delete from DASHLETS
--GO

set nocount on;
GO

-- 
if not exists(select * from DASHLETS where CATEGORY = 'My Dashlets' and CONTROL_NAME like '%/html5/%' and DELETED = 0) begin -- then
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Opportunities'    , '~/Opportunities/html5/MyPipelineBySalesStage'    , 'Home.LBL_PIPELINE_FORM_TITLE'         , 0;
end -- if;
GO

if not exists(select * from DASHLETS where CATEGORY = 'Dashboard' and CONTROL_NAME like '%/html5/%' and DELETED = 0) begin -- then
	exec dbo.spDASHLETS_InsertOnly 'Dashboard'  , 'Opportunities'    , '~/Dashboard/html5/PipelineBySalesStage'          , 'Dashboard.LBL_SALES_STAGE_FORM_TITLE' , 0;
	exec dbo.spDASHLETS_InsertOnly 'Dashboard'  , 'Opportunities'    , '~/Dashboard/html5/OppByLeadSourceByOutcome'      , 'Dashboard.LBL_LEAD_SOURCE_BY_OUTCOME' , 0;
	exec dbo.spDASHLETS_InsertOnly 'Dashboard'  , 'Opportunities'    , '~/Dashboard/html5/PipelineByMonthByOutcome'      , 'Dashboard.LBL_YEAR_BY_OUTCOME'        , 0;
	exec dbo.spDASHLETS_InsertOnly 'Dashboard'  , 'Opportunities'    , '~/Dashboard/html5/OppByLeadSource'               , 'Dashboard.LBL_LEAD_SOURCE_FORM_TITLE' , 0;
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

call dbo.spDASHLETS_html5()
/

call dbo.spSqlDropProcedure('spDASHLETS_html5')
/

-- #endif IBM_DB2 */

