

print 'SCHEDULERS defaults';
GO

set nocount on;
GO

-- 12/28/2007 Paul.  Oracle is having trouble with the date format, so just use NULL.  We will treat NULL as perpetual. 
-- 12/31/2007 Paul.  The only active job is the email campaign. 
-- minute  hour  dayOfMonth  month  dayOfWeek
-- 12/31/2007 Paul.  Create database backup job to run once a week. 
-- 01/26/2008 Paul.  Enable Inbound Mailboxes and Inbound Bounces. 
exec dbo.spSCHEDULERS_InsertOnly null, N'Check Inbound Mailboxes'                    , N'function::pollMonitoredInboxes'                        , null, null, N'*::*::*::*::*'   , null, null, N'Active'  , 0;
exec dbo.spSCHEDULERS_InsertOnly null, N'Run Nightly Process Bounced Campaign Emails', N'function::pollMonitoredInboxesForBouncedCampaignEmails', null, null, N'0::*::*::*::*'   , null, null, N'Active'  , 1;
-- 04/05/2010 Paul.  There is a lot of confusion around running Email Campaigns.  Change to have it run every hour. 
exec dbo.spSCHEDULERS_InsertOnly null, N'Run Nightly Mass Email Campaigns'           , N'function::runMassEmailCampaign'                        , null, null, N'0::*::*::*::*'   , null, null, N'Active'  , 1;
exec dbo.spSCHEDULERS_InsertOnly null, N'Prune Database on 1st of Month'             , N'function::pruneDatabase'                               , null, null, N'0::4::1::*::*'   , null, null, N'Inactive', 0;
exec dbo.spSCHEDULERS_InsertOnly null, N'Backup Database Sunday at 11pm'             , N'function::BackupDatabase'                              , null, null, N'0::23::*::*::0'  , null, null, N'Active'  , 0;
exec dbo.spSCHEDULERS_InsertOnly null, N'Backup Transaction Log Mon-Sat at 11pm'     , N'function::BackupTransactionLog'                        , null, null, N'0::23::*::*::1-6', null, null, N'Inactive', 0;
-- 01/14/2008 Paul.  Perform a version check at 8 AM Tuesdays and Fridays. 
exec dbo.spSCHEDULERS_InsertOnly null, N'Run Nightly SplendidCRM Version Check'      , N'function::CheckVersion'                                , null, null, N'0::8::*::*::2,5' , null, null, N'Active'  , 0;
-- 05/15/2008 Paul.  Check for outbound emails. 
exec dbo.spSCHEDULERS_InsertOnly null, N'Check Outbound Emails'                      , N'function::pollOutboundEmails'                          , null, null, N'*::*::*::*::*'   , null, null, N'Active'  , 0;
-- 02/26/2010 Paul.  Clean the SYSTEM_LOG table of warnings once a week. 
exec dbo.spSCHEDULERS_InsertOnly null, N'Clean System Log Sunday at 10pm'            , N'function::CleanSystemLog'                              , null, null, N'0::22::*::*::0'  , null, null, N'Active'  , 0;
-- 04/10/2018 Paul.  Run External Archive. 
exec dbo.spSCHEDULERS_InsertOnly null, N'Run External Archive'                       , N'function::RunExternalArchive'                          , null, null, N'0::3::1::*::*'   , null, null, N'Inactive', 0;



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

call dbo.spSCHEDULERS_Defaults()
/

call dbo.spSqlDropProcedure('spSCHEDULERS_Defaults')
/

-- #endif IBM_DB2 */

