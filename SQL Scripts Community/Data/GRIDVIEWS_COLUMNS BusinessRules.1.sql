

print 'GRIDVIEWS_COLUMNS BusinessRules';
GO

set nocount on;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'BusinessRules.ListView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'BusinessRules.ListView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS BusinessRules.ListView';
	exec dbo.spGRIDVIEWS_InsertOnly           'BusinessRules.ListView', 'BusinessRules', 'vwREPORTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'BusinessRules.ListView'       , 2, 'Rules.LBL_LIST_NAME'                      , 'NAME'                 , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID'         , '~/Administration/BusinessRules/edit.aspx?id={0}', null, 'BusinessRules', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'BusinessRules.ListView'       , 3, 'Rules.LBL_LIST_MODULE_NAME'               , 'MODULE_NAME'          , 'MODULE_NAME'     , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'BusinessRules.ListView'       , 4, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'        , 'DATE_MODIFIED'   , '20%';
end -- if;
GO

-- delete from GRIDVIEWS_COLUMNS where GRID_NAME = 'BusinessRules.PopupView';
if not exists(select * from GRIDVIEWS_COLUMNS where GRID_NAME = 'BusinessRules.PopupView' and DELETED = 0) begin -- then
	print 'GRIDVIEWS_COLUMNS BusinessRules.PopupView';
	exec dbo.spGRIDVIEWS_InsertOnly           'BusinessRules.PopupView', 'BusinessRules', 'vwREPORTS_List';
	exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink 'BusinessRules.PopupView'      , 1, 'Rules.LBL_LIST_NAME'                      , 'NAME'                 , 'NAME'            , '50%', 'listViewTdLinkS1', 'ID NAME'    , 'SelectBusinessRule(''{0}'', ''{1}'');', null, 'BusinessRules', null;
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'BusinessRules.PopupView'      , 2, 'Rules.LBL_LIST_MODULE_NAME'               , 'MODULE_NAME'          , 'MODULE_NAME'     , '20%';
	exec dbo.spGRIDVIEWS_COLUMNS_InsBound     'BusinessRules.PopupView'      , 3, '.LBL_LIST_DATE_MODIFIED'                  , 'DATE_MODIFIED'        , 'DATE_MODIFIED'   , '20%';
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

call dbo.spGRIDVIEWS_COLUMNS_BusinessRules()
/

call dbo.spSqlDropProcedure('spGRIDVIEWS_COLUMNS_BusinessRules')
/

-- #endif IBM_DB2 */

