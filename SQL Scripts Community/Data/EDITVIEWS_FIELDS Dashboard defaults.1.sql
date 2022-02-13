

print 'EDITVIEWS_FIELDS Dashboard defaults';
--GO

set nocount on;
GO


-- 07/31/2017 Paul.  Add My Team dashlets. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.MyPipelineBySalesStage';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.MyPipelineBySalesStage' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.MyPipelineBySalesStage';
	exec dbo.spEDITVIEWS_InsertOnly             'Opportunities.MyPipelineBySalesStage'  , 'Opportunities', 'vwOPPORTUNITIES_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Opportunities.MyPipelineBySalesStage'  ,  0, 'Opportunities.LBL_DATE_CLOSED', 'DATE_CLOSED'                , 0, 1, 'DateRange'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.MyPipelineBySalesStage'  ,  1, 'Dashboard.LBL_SALES_STAGES'   , 'SALES_STAGE'                , 0, null, 'sales_stage_dom' , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'Opportunities.MyPipelineBySalesStage'  ,  2, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.MyPipelineBySalesStage'  ,  2, 'Dashboard.LBL_USERS'          , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'    , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.MyPipelineBySalesStage'  ,  3, 'Dashboard.LBL_TEAMS'          , 'TEAM_ID'                    , 0, null, 'Teams'           , null, 4;
end else begin
	-- 07/31/2017 Paul.  Add My Team dashlets. 
	exec dbo.spEDITVIEWS_FIELDS_CnvBoundLst     'Opportunities.MyPipelineBySalesStage'  ,  2, 'Dashboard.LBL_USERS'          , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'    , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.MyPipelineBySalesStage'  ,  3, 'Dashboard.LBL_TEAMS'          , 'TEAM_ID'                    , 0, null, 'Teams'           , null, 4;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.PipelineBySalesStage';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.PipelineBySalesStage' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.PipelineBySalesStage';
	exec dbo.spEDITVIEWS_InsertOnly             'Opportunities.PipelineBySalesStage'    , 'Opportunities', 'vwOPPORTUNITIES_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsControl      'Opportunities.PipelineBySalesStage'    ,  0, 'Opportunities.LBL_DATE_CLOSED', 'DATE_CLOSED'                , 0, 1, 'DateRange'          , null, null, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.PipelineBySalesStage'    ,  1, 'Dashboard.LBL_SALES_STAGES'   , 'SALES_STAGE'                , 0, null, 'sales_stage_dom' , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.PipelineBySalesStage'    ,  2, 'Dashboard.LBL_USERS'          , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'    , null, 4;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.OppByLeadSourceByOutcome' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.OppByLeadSourceByOutcome';
	exec dbo.spEDITVIEWS_InsertOnly             'Opportunities.OppByLeadSourceByOutcome', 'Opportunities', 'vwOPPORTUNITIES_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.OppByLeadSourceByOutcome',  0, 'Dashboard.LBL_LEAD_SOURCES'   , 'LEAD_SOURCE'                , 0, null, 'lead_source_dom' , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.OppByLeadSourceByOutcome',  1, 'Dashboard.LBL_USERS'          , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'    , null, 4;
end -- if;
GO

-- 06/21/2009 Paul.  Add ability to customize search on home page. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.PipelineByMonthByOutcome';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.PipelineByMonthByOutcome' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.PipelineByMonthByOutcome';
	exec dbo.spEDITVIEWS_InsertOnly             'Opportunities.PipelineByMonthByOutcome', 'Opportunities', 'vwOPPORTUNITIES_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'Opportunities.PipelineByMonthByOutcome',  0, 'Dashboard.LBL_YEAR'           , 'YEAR'                       , 0, null,  50, 25, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.PipelineByMonthByOutcome',  1, 'Dashboard.LBL_USERS'          , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'    , null, 4;
end -- if;
GO

if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'Opportunities.OppByLeadSource' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS Opportunities.OppByLeadSource';
	exec dbo.spEDITVIEWS_InsertOnly             'Opportunities.OppByLeadSource'         , 'Opportunities', 'vwOPPORTUNITIES_Edit', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.OppByLeadSource'         ,  0, 'Dashboard.LBL_LEAD_SOURCES'   , 'LEAD_SOURCE'                , 0, null, 'lead_source_dom' , null, 4;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'Opportunities.OppByLeadSource'         ,  1, 'Dashboard.LBL_USERS'          , 'ASSIGNED_USER_ID'           , 0, null, 'AssignedUser'    , null, 4;
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

call dbo.spEDITVIEWS_FIELDS_DashboardDefaults()
/

call dbo.spSqlDropProcedure('spEDITVIEWS_FIELDS_DashboardDefaults')
/

-- #endif IBM_DB2 */

