

print 'DASHLETS silverlight';
--delete from DASHLETS
--GO

set nocount on;
GO

-- 09/27/2009 Paul.  Base dashlets will exists, so make sure to include silverlight in the filter. 
-- 01/24/2010 Paul.  Allow multiple. 
if not exists(select * from DASHLETS where CATEGORY = 'My Dashlets' and CONTROL_NAME like '%/SilverlightCharts/%' and DELETED = 0) begin -- then
	exec dbo.spDASHLETS_InsertOnly 'My Dashlets', 'Opportunities'    , '~/Opportunities/SilverlightCharts/MyPipeline'                , 'Home.LBL_PIPELINE_FORM_TITLE'         , 0;
	exec dbo.spDASHLETS_InsertOnly 'Dashboard'  , 'Opportunities'    , '~/Dashboard/SilverlightCharts/PipelineBySalesStage'          , 'Dashboard.LBL_SALES_STAGE_FORM_TITLE' , 0;
	exec dbo.spDASHLETS_InsertOnly 'Dashboard'  , 'Opportunities'    , '~/Dashboard/SilverlightCharts/OppByLeadSourceByOutcome'      , 'Dashboard.LBL_LEAD_SOURCE_BY_OUTCOME' , 0;
	exec dbo.spDASHLETS_InsertOnly 'Dashboard'  , 'Opportunities'    , '~/Dashboard/SilverlightCharts/PipelineByMonthByOutcome'      , 'Dashboard.LBL_YEAR_BY_OUTCOME'        , 0;
	exec dbo.spDASHLETS_InsertOnly 'Dashboard'  , 'Opportunities'    , '~/Dashboard/SilverlightCharts/OppByLeadSource'               , 'Dashboard.LBL_LEAD_SOURCE_FORM_TITLE' , 0;
end -- if;
GO

-- 06/13/2017 Paul.  Silverlight charts will not be supported anymore. Users should still see them, just not be able to add them. 
if exists(select * from vwDASHLETS where CONTROL_NAME like '%SilverlightCharts%' and DASHLET_ENABLED = 1) begin -- then
	print 'DASHLETS Silverlight charts will not be supported anymore. ';
	update DASHLETS
	   set DASHLET_ENABLED   = 0
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getutcdate()
	 where CONTROL_NAME      like '%SilverlightCharts%'
	   and DASHLET_ENABLED   = 1
	   and DELETED           = 0;
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

call dbo.spDASHLETS_Silverlight()
/

call dbo.spSqlDropProcedure('spDASHLETS_Silverlight')
/

-- #endif IBM_DB2 */

