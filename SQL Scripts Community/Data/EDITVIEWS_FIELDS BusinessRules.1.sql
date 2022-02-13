

print 'EDITVIEWS_FIELDS BusinessRules';
GO

set nocount on;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'BusinessRules.SearchBasic';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'BusinessRules.SearchBasic' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS BusinessRules.SearchBasic';
	exec dbo.spEDITVIEWS_InsertOnly             'BusinessRules.SearchBasic' , 'BusinessRules', 'vwBUSINESS_RULES', '11%', '22%', 3;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'BusinessRules.SearchBasic' ,  0, 'Rules.LBL_NAME'                         , 'NAME'                       , 0, null, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBoundList    'BusinessRules.SearchBasic' ,  1, 'Rules.LBL_MODULE_NAME'                  , 'MODULE_NAME'                , 0, null, 'RulesModules', null, 6;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'BusinessRules.SearchBasic' ,  2, null;
end -- if;
GO

-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'BusinessRules.SearchPopup';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'BusinessRules.SearchPopup' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS BusinessRules.SearchPopup';
	exec dbo.spEDITVIEWS_InsertOnly             'BusinessRules.SearchPopup' , 'BusinessRules', 'vwBUSINESS_RULES', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsBound        'BusinessRules.SearchPopup' ,  0, 'Rules.LBL_NAME'                         , 'NAME'                       , 0, null, 150, 35, null;
	exec dbo.spEDITVIEWS_FIELDS_InsBlank        'BusinessRules.SearchPopup' ,  1, null;
end -- if;
GO

-- 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'BusinessRules.EventsEditView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'BusinessRules.EventsEditView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS BusinessRules.EventsEditView';
	exec dbo.spEDITVIEWS_InsertOnly             'BusinessRules.EventsEditView', 'BusinessRules', 'vwEDITVIEWS', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'BusinessRules.EventsEditView',  0, 'BusinessRules.LBL_NEW_EVENT_NAME'       , 'NEW_EVENT_ID'             , 0, null, 'NEW_EVENT_NAME'       , 'BusinessRules', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'BusinessRules.EventsEditView',  1, 'BusinessRules.LBL_VALIDATION_EVENT_NAME', 'VALIDATION_EVENT_ID'      , 0, null, 'VALIDATION_EVENT_NAME', 'BusinessRules', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'BusinessRules.EventsEditView',  2, 'BusinessRules.LBL_PRE_LOAD_EVENT_NAME'  , 'PRE_LOAD_EVENT_ID'        , 0, null, 'PRE_LOAD_EVENT_NAME'  , 'BusinessRules', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'BusinessRules.EventsEditView',  3, 'BusinessRules.LBL_POST_LOAD_EVENT_NAME' , 'POST_LOAD_EVENT_ID'       , 0, null, 'POST_LOAD_EVENT_NAME' , 'BusinessRules', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'BusinessRules.EventsEditView',  4, 'BusinessRules.LBL_PRE_SAVE_EVENT_NAME'  , 'PRE_SAVE_EVENT_ID'        , 0, null, 'PRE_SAVE_EVENT_NAME'  , 'BusinessRules', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'BusinessRules.EventsEditView',  5, 'BusinessRules.LBL_POST_SAVE_EVENT_NAME' , 'POST_SAVE_EVENT_ID'       , 0, null, 'POST_SAVE_EVENT_NAME' , 'BusinessRules', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine    'BusinessRules.EventsEditView',  6, 'BusinessRules.LBL_SCRIPT'               , 'SCRIPT'                   , 0, null,   3, 180, 3;
	exec dbo.spEDITVIEWS_FIELDS_UpdateOnClick  null, 'BusinessRules.EventsEditView', 'NEW_EVENT_ID'       , 'return NewEventPopup();'       ;
	exec dbo.spEDITVIEWS_FIELDS_UpdateOnClick  null, 'BusinessRules.EventsEditView', 'PRE_LOAD_EVENT_ID'  , 'return PreLoadEventPopup();'   ;
	exec dbo.spEDITVIEWS_FIELDS_UpdateOnClick  null, 'BusinessRules.EventsEditView', 'POST_LOAD_EVENT_ID' , 'return PostLoadEventPopup();'  ;
	exec dbo.spEDITVIEWS_FIELDS_UpdateOnClick  null, 'BusinessRules.EventsEditView', 'VALIDATION_EVENT_ID', 'return ValidationEventPopup();';
	exec dbo.spEDITVIEWS_FIELDS_UpdateOnClick  null, 'BusinessRules.EventsEditView', 'PRE_SAVE_EVENT_ID'  , 'return PreSaveEventPopup();'   ;
	exec dbo.spEDITVIEWS_FIELDS_UpdateOnClick  null, 'BusinessRules.EventsEditView', 'POST_SAVE_EVENT_ID' , 'return PostSaveEventPopup();'  ;
end else begin
	-- 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine    'BusinessRules.EventsEditView',  6, 'BusinessRules.LBL_SCRIPT'               , 'SCRIPT'                   , 0, null,   3, 180, 3;
end -- if;
GO

-- 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'BusinessRules.EventsDetailView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'BusinessRules.EventsDetailView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS BusinessRules.EventsDetailView';
	exec dbo.spEDITVIEWS_InsertOnly             'BusinessRules.EventsDetailView', 'BusinessRules', 'vwDETAILVIEWS', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'BusinessRules.EventsDetailView',  0, 'BusinessRules.LBL_PRE_LOAD_EVENT_NAME'  , 'PRE_LOAD_EVENT_ID'        , 0, null, 'PRE_LOAD_EVENT_NAME'  , 'BusinessRules', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'BusinessRules.EventsDetailView',  1, 'BusinessRules.LBL_POST_LOAD_EVENT_NAME' , 'POST_LOAD_EVENT_ID'       , 0, null, 'POST_LOAD_EVENT_NAME' , 'BusinessRules', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine    'BusinessRules.EventsDetailView',  2, 'BusinessRules.LBL_SCRIPT'               , 'SCRIPT'                   , 0, null,   3, 180, 3;
	exec dbo.spEDITVIEWS_FIELDS_UpdateOnClick  null, 'BusinessRules.EventsDetailView', 'PRE_LOAD_EVENT_ID'  , 'return PreLoadEventPopup();'   ;
	exec dbo.spEDITVIEWS_FIELDS_UpdateOnClick  null, 'BusinessRules.EventsDetailView', 'POST_LOAD_EVENT_ID' , 'return PostLoadEventPopup();'  ;
end else begin
	-- 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine    'BusinessRules.EventsDetailView',  2, 'BusinessRules.LBL_SCRIPT'               , 'SCRIPT'                   , 0, null,   3, 180, 3;
end -- if;
GO

-- 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
-- delete from EDITVIEWS_FIELDS where EDIT_NAME = 'BusinessRules.EventsGridView';
if not exists(select * from EDITVIEWS_FIELDS where EDIT_NAME = 'BusinessRules.EventsGridView' and DELETED = 0) begin -- then
	print 'EDITVIEWS_FIELDS BusinessRules.EventsGridView';
	exec dbo.spEDITVIEWS_InsertOnly             'BusinessRules.EventsGridView', 'BusinessRules', 'vwGRIDVIEWS', '15%', '35%', 2;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'BusinessRules.EventsGridView',  0, 'BusinessRules.LBL_TABLE_LOAD_EVENT_NAME', 'PRE_LOAD_EVENT_ID'        , 0, null, 'PRE_LOAD_EVENT_NAME'  , 'BusinessRules', null;
	exec dbo.spEDITVIEWS_FIELDS_InsModulePopup  'BusinessRules.EventsGridView',  1, 'BusinessRules.LBL_ROW_LOAD_EVENT_NAME'  , 'POST_LOAD_EVENT_ID'       , 0, null, 'POST_LOAD_EVENT_NAME' , 'BusinessRules', null;
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine    'BusinessRules.EventsGridView',  2, 'BusinessRules.LBL_SCRIPT'               , 'SCRIPT'                   , 0, null,   3, 180, 3;
	exec dbo.spEDITVIEWS_FIELDS_UpdateOnClick  null, 'BusinessRules.EventsGridView', 'PRE_LOAD_EVENT_ID'  , 'return PreLoadEventPopup();'   ;
	exec dbo.spEDITVIEWS_FIELDS_UpdateOnClick  null, 'BusinessRules.EventsGridView', 'POST_LOAD_EVENT_ID' , 'return PostLoadEventPopup();'  ;
end else begin
	-- 09/20/2012 Paul.  We need a SCRIPT field that is form specific. 
	exec dbo.spEDITVIEWS_FIELDS_InsMultiLine    'BusinessRules.EventsGridView',  2, 'BusinessRules.LBL_SCRIPT'               , 'SCRIPT'                   , 0, null,   3, 180, 3;
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

call dbo.spEDITVIEWS_FIELDS_BusinessRules()
/

call dbo.spSqlDropProcedure('spEDITVIEWS_FIELDS_BusinessRules')
/

-- #endif IBM_DB2 */

