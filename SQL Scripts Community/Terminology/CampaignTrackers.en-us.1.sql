

-- Terminology generated from database [SplendidCRM5_50] on 11/18/2010 1:19:35 AM.
print 'TERMINOLOGY CampaignTrackers en-us';
GO

set nocount on;
GO

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CAMPAIGN_ID'                               , N'en-US', N'CampaignTrackers', null, null, N'Campaign ID:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CAMPAIGN_NAME'                             , N'en-US', N'CampaignTrackers', null, null, N'Campaign Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EDIT_CAMPAIGN_NAME'                        , N'en-US', N'CampaignTrackers', null, null, N'Campaign Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EDIT_MESSAGE_URL'                          , N'en-US', N'CampaignTrackers', null, null, N'Message Url:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EDIT_OPT_OUT'                              , N'en-US', N'CampaignTrackers', null, null, N'Opt Out:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EDIT_TRACKER_KEY'                          , N'en-US', N'CampaignTrackers', null, null, N'Tracker Key:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EDIT_TRACKER_NAME'                         , N'en-US', N'CampaignTrackers', null, null, N'Tracker Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_EDIT_TRACKER_URL'                          , N'en-US', N'CampaignTrackers', null, null, N'Tracker Url:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_IS_OPTOUT'                                 , N'en-US', N'CampaignTrackers', null, null, N'Is Optout:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CAMPAIGN_ID'                          , N'en-US', N'CampaignTrackers', null, null, N'Campaign ID';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_CAMPAIGN_NAME'                        , N'en-US', N'CampaignTrackers', null, null, N'Campaign Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_FORM_TITLE'                           , N'en-US', N'CampaignTrackers', null, null, N'Campaign Tracker List';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_IS_OPTOUT'                            , N'en-US', N'CampaignTrackers', null, null, N'Is Optout';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_NAME'                                 , N'en-US', N'CampaignTrackers', null, null, N'Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TRACKER_KEY'                          , N'en-US', N'CampaignTrackers', null, null, N'Tracker Key';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TRACKER_NAME'                         , N'en-US', N'CampaignTrackers', null, null, N'Tracker Name';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LIST_TRACKER_URL'                          , N'en-US', N'CampaignTrackers', null, null, N'Tracker Url';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'CampaignTrackers', null, null, N'Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TRACKER_KEY'                               , N'en-US', N'CampaignTrackers', null, null, N'Tracker Key:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TRACKER_NAME'                              , N'en-US', N'CampaignTrackers', null, null, N'Tracker Name:';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TRACKER_URL'                               , N'en-US', N'CampaignTrackers', null, null, N'Tracker Url:';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_CAMPAIGN_LIST'                             , N'en-US', N'CampaignTrackers', null, null, N'Campaigns';
-- 06/04/2015 Paul.  Add module abbreviation. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'CampaignTrackers', null, null, N'CT';
-- 08/03/2019 Paul.  LBL_MODULE_NAME is needed on the React Client. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_NAME'                               , N'en-US', N'CampaignTrackers', null, null, N'Campaign Trackers';
GO
/* -- #if Oracle
	COMMIT WORK;
END;
/

BEGIN
-- #endif Oracle */
exec dbo.spTERMINOLOGY_InsertOnly N'CampaignTrackers'                              , N'en-US', null, N'moduleList'                        ,  49, N'Campaign Trackers';
GO


set nocount off;
GO

/* -- #if Oracle
	COMMIT WORK;
END;
/
-- #endif Oracle */

/* -- #if IBM_DB2
	commit;
  end
/

call dbo.spTERMINOLOGY_CampaignTrackers_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_CampaignTrackers_en_us')
/
-- #endif IBM_DB2 */
