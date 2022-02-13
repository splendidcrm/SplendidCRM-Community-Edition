

print 'RELATIONSHIPS defaults';
GO

set nocount on;
GO

-- 08/22/2008 Paul.  Move professional modules to a separate file. 
-- 10/10/2008 Paul.  Add relationships used in workflow. 
exec dbo.spRELATIONSHIPS_InsertOnly 'account_calls'               , 'Accounts'     , 'accounts'      , 'id', 'Calls'         , 'calls', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Accounts', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'account_cases'               , 'Accounts'     , 'accounts'      , 'id', 'Cases'         , 'cases', 'account_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'account_emails'              , 'Accounts'     , 'accounts'      , 'id', 'Emails'        , 'emails', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Accounts', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'account_leads'               , 'Accounts'     , 'accounts'      , 'id', 'Leads'         , 'leads', 'account_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'account_meetings'            , 'Accounts'     , 'accounts'      , 'id', 'Meetings'      , 'meetings', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Accounts', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'account_notes'               , 'Accounts'     , 'accounts'      , 'id', 'Notes'         , 'notes', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Accounts', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'account_tasks'               , 'Accounts'     , 'accounts'      , 'id', 'Tasks'         , 'tasks', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Accounts', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'accounts_assigned_user'      , 'Users'        , 'users'         , 'id', 'Accounts'      , 'accounts', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'accounts_bugs'               , 'Accounts'     , 'accounts'      , 'id', 'Bugs'          , 'bugs', 'id', 'accounts_bugs', 'account_id', 'bug_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'accounts_contacts'           , 'Accounts'     , 'accounts'      , 'id', 'Contacts'      , 'contacts', 'id', 'accounts_contacts', 'account_id', 'contact_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'accounts_created_by'         , 'Users'        , 'users'         , 'id', 'Accounts'      , 'accounts', 'created_by_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'accounts_modified_user'      , 'Users'        , 'users'         , 'id', 'Accounts'      , 'accounts', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'accounts_opportunities'      , 'Accounts'     , 'accounts'      , 'id', 'Opportunities' , 'opportunities', 'id', 'accounts_opportunities', 'account_id', 'opportunity_id', 'many-to-many', null, null, 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'acl_roles_users'             , 'ACLRoles'     , 'acl_roles'     , 'id', 'Users'         , 'users'        , 'id', 'acl_roles_users', 'role_id', 'user_id', 'many-to-many', null, null, 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'bug_calls'                   , 'Bugs'         , 'bugs'          , 'id', 'Calls'         , 'calls', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Bugs', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'bug_emails'                  , 'Bugs'         , 'bugs'          , 'id', 'Emails'        , 'emails', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Bugs', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'bug_meetings'                , 'Bugs'         , 'bugs'          , 'id', 'Meetings'      , 'meetings', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Bugs', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'bug_notes'                   , 'Bugs'         , 'bugs'          , 'id', 'Notes'         , 'notes', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Bugs', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'bug_tasks'                   , 'Bugs'         , 'bugs'          , 'id', 'Tasks'         , 'tasks', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Bugs', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'bugs_assigned_user'          , 'Users'        , 'users'         , 'id', 'Bugs'          , 'bugs', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'bugs_created_by'             , 'Users'        , 'users'         , 'id', 'Bugs'          , 'bugs', 'created_by_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'bugs_fixed_in_release'       , 'Releases'     , 'releases'      , 'id', 'Bugs'          , 'bugs', 'fixed_in_release', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'bugs_modified_user'          , 'Users'        , 'users'         , 'id', 'Bugs'          , 'bugs', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'bugs_release'                , 'Releases'     , 'releases'      , 'id', 'Bugs'          , 'bugs', 'found_in_release', null, null, null, 'one-to-many', null, null, 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'calls_assigned_user'         , 'Users'        , 'users'         , 'id', 'Calls'         , 'calls', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'calls_contacts'              , 'Calls'        , 'calls'         , 'id', 'Contacts'      , 'contacts', 'id', 'calls_contacts', 'call_id', 'contact_id', 'many-to-many', null, null, 0;
-- 04/01/2012 Paul.  Add Calls/Leads relationship. 
exec dbo.spRELATIONSHIPS_InsertOnly 'calls_leads'                 , 'Calls'        , 'calls'         , 'id', 'Leads'         , 'leads', 'id', 'calls_leads', 'call_id', 'lead_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'calls_created_by'            , 'Users'        , 'users'         , 'id', 'Calls'         , 'calls', 'created_by_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'calls_modified_user'         , 'Users'        , 'users'         , 'id', 'Calls'         , 'calls', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'calls_notes'                 , 'Calls'        , 'calls'         , 'id', 'Notes'         , 'notes', 'parent_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'calls_users'                 , 'Calls'        , 'calls'         , 'id', 'Users'         , 'users'         , 'id', 'calls_users', 'call_id', 'user_id', 'many-to-many', null, null, 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'campaign_campaignlog'        , 'Campaigns'    , 'campaigns'     , 'id', 'CampaignLog'   , 'campaign_log', 'campaign_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'campaign_campaigntrakers'    , 'Campaigns'    , 'campaigns'     , 'id', 'CampaignTrackers', 'campaign_trkrs', 'campaign_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'campaign_email_marketing'    , 'Campaigns'    , 'campaigns'     , 'id', 'EmailMarketing', 'email_marketing', 'campaign_id', null, null, null, 'one-to-many', null, null, 0;
-- 08/28/2012 Paul.  Add Call Marketing. 
exec dbo.spRELATIONSHIPS_InsertOnly 'campaign_call_marketing'     , 'Campaigns'    , 'campaigns'     , 'id', 'CallMarketing' , 'call_marketing', 'campaign_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'campaign_emailman'           , 'Campaigns'    , 'campaigns'     , 'id', 'EmailMan'      , 'emailman', 'campaign_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'campaigns_assigned_user'     , 'Users'        , 'users'         , 'id', 'Campaigns'     , 'campaigns', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'campaigns_created_by'        , 'Users'        , 'users'         , 'id', 'Campaigns'     , 'campaigns', 'created_by_id'   , null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'campaigns_modified_user'     , 'Users'        , 'users'         , 'id', 'Campaigns'     , 'campaigns', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'case_calls'                  , 'Cases'        , 'cases'         , 'id', 'Calls'         , 'calls', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Cases', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'case_emails'                 , 'Cases'        , 'cases'         , 'id', 'Emails'        , 'emails', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Cases', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'case_meetings'               , 'Cases'        , 'cases'         , 'id', 'Meetings'      , 'meetings', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Cases', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'case_notes'                  , 'Cases'        , 'cases'         , 'id', 'Notes'         , 'notes', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Cases', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'case_tasks'                  , 'Cases'        , 'cases'         , 'id', 'Tasks'         , 'tasks', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Cases', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'cases_assigned_user'         , 'Users'        , 'users'         , 'id', 'Cases'         , 'cases', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'cases_bugs'                  , 'Cases'        , 'cases'         , 'id', 'Bugs'          , 'bugs', 'id', 'cases_bugs', 'case_id', 'bug_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'cases_created_by'            , 'Users'        , 'users'         , 'id', 'Cases'         , 'cases', 'created_by_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'cases_modified_user'         , 'Users'        , 'users'         , 'id', 'Cases'         , 'cases', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'contact_campaign_log'        , 'Contacts'     , 'contacts'      , 'id', 'CampaignLog'   , 'campaign_log', 'target_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'contact_direct_reports'      , 'Contacts'     , 'contacts'      , 'id', 'Contacts'      , 'contacts', 'reports_to_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'contact_leads'               , 'Contacts'     , 'contacts'      , 'id', 'Leads'         , 'leads', 'contact_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'contact_notes'               , 'Contacts'     , 'contacts'      , 'id', 'Notes'         , 'notes', 'contact_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'contact_tasks'               , 'Contacts'     , 'contacts'      , 'id', 'Tasks'         , 'tasks', 'contact_id', null, null, null, 'one-to-many', null, null, 0;
-- 05/24/2016 Paul.  Add activity relationships for Contacts module. 
exec dbo.spRELATIONSHIPS_InsertOnly 'contact_calls'               , 'Contacts'     , 'contacts'      , 'id', 'Calls'         , 'calls'   , 'parent_id', null, null, null, 'one-to-many', 'parent_type'   , 'Contacts', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'contact_meetings'            , 'Contacts'     , 'contacts'      , 'id', 'Meetings'      , 'meetings', 'parent_id', null, null, null, 'one-to-many', 'parent_type'   , 'Contacts', 0;
--exec dbo.spRELATIONSHIPS_InsertOnly 'contact_notes'               , 'Contacts'     , 'contacts'      , 'id', 'Notes'         , 'notes'   , 'parent_id', null, null, null, 'one-to-many', 'parent_type'   , 'Contacts', 0;
--exec dbo.spRELATIONSHIPS_InsertOnly 'contact_tasks'               , 'Contacts'     , 'contacts'      , 'id', 'Tasks'         , 'tasks'   , 'parent_id', null, null, null, 'one-to-many', 'parent_type'   , 'Contacts', 0;
-- 01/20/2010 Paul.  We want the ability to access account information from a Contacts report. 
-- delete from RELATIONSHIPS where RELATIONSHIP_NAME = 'contacts_accounts';
exec dbo.spRELATIONSHIPS_InsertOnly 'contacts_accounts'           , 'Contacts'     , 'contacts'      , 'id', 'Accounts'      , 'accounts', 'id', 'accounts_contacts', 'contact_id', 'account_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'contacts_assigned_user'      , 'Users'        , 'users'         , 'id', 'Contacts'      , 'contacts', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'contacts_bugs'               , 'Contacts'     , 'contacts'      , 'id', 'Bugs'          , 'bugs', 'id', 'contacts_bugs', 'contact_id', 'bug_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'contacts_cases'              , 'Contacts'     , 'contacts'      , 'id', 'Cases'         , 'cases', 'id', 'contacts_cases', 'contact_id', 'case_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'contacts_created_by'         , 'Users'        , 'users'         , 'id', 'Contacts'      , 'contacts', 'created_by_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'contacts_modified_user'      , 'Users'        , 'users'         , 'id', 'Contacts'      , 'contacts', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'document_revisions'          , 'Documents'    , 'documents'     , 'id', 'Documents'     , 'document_revisions', 'document_id', null, null, null, 'one-to-many', null, null, 0;
-- 03/24/2011 Paul.  Allow an opportunity relationship within a Contacts search. 
exec dbo.spRELATIONSHIPS_InsertOnly 'contacts_opportunities'      , 'Contacts'     , 'contacts'      , 'id', 'Opportunities' , 'opportunities', 'id', 'opportunities_contacts', 'contact_id', 'opportunity_id', 'many-to-many', null, null, 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'emails_accounts_rel'         , 'Emails'       , 'emails'        , 'id', 'Accounts'      , 'accounts', 'id', 'emails_accounts', 'email_id', 'account_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'emails_assigned_user'        , 'Users'        , 'users'         , 'id', 'Emails'        , 'emails', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'emails_bugs_rel'             , 'Emails'       , 'emails'        , 'id', 'Bugs'          , 'bugs', 'id', 'emails_bugs', 'email_id', 'bug_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'emails_cases_rel'            , 'Emails'       , 'emails'        , 'id', 'Cases'         , 'cases', 'id', 'emails_cases', 'email_id', 'case_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'emails_contacts_rel'         , 'Emails'       , 'emails'        , 'id', 'Contacts'      , 'contacts', 'id', 'emails_contacts', 'email_id', 'contact_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'emails_created_by'           , 'Users'        , 'users'         , 'id', 'Emails'        , 'emails', 'created_by_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'emails_leads_rel'            , 'Emails'       , 'emails'        , 'id', 'Leads'         , 'leads', 'id', 'emails_leads', 'email_id', 'lead_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'emails_modified_user'        , 'Users'        , 'users'         , 'id', 'Emails'        , 'emails', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'emails_opportunities_rel'    , 'Emails'       , 'emails'        , 'id', 'Opportunities' , 'opportunities', 'id', 'emails_opportunities', 'email_id', 'opportunity_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'emails_project_task_rel'     , 'Emails'       , 'emails'        , 'id', 'ProjectTask'   , 'project_task', 'id', 'emails_project_tasks', 'email_id', 'project_task_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'emails_projects_rel'         , 'Emails'       , 'emails'        , 'id', 'Project'       , 'project', 'id', 'emails_projects', 'email_id', 'project_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'emails_prospects_rel'        , 'Emails'       , 'emails'        , 'id', 'Prospect'      , 'prospects', 'id', 'emails_prospects', 'email_id', 'prospect_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'emails_tasks_rel'            , 'Emails'       , 'emails'        , 'id', 'Tasks'         , 'tasks', 'id', 'emails_tasks', 'email_id', 'task_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'emails_users_rel'            , 'Emails'       , 'emails'        , 'id', 'Users'         , 'users'         , 'id', 'emails_users', 'email_id', 'user_id', 'many-to-many', null, null, 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'feeds_assigned_user'         , 'Users'        , 'users'         , 'id', 'Feeds'         , 'feeds', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'feeds_created_by'            , 'Users'        , 'users'         , 'id', 'Feeds'         , 'feeds', 'created_by_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'feeds_modified_user'         , 'Users'        , 'users'         , 'id', 'Feeds'         , 'feeds', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'lead_calls'                  , 'Leads'        , 'leads'         , 'id', 'Calls'         , 'calls', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Leads', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'lead_campaign_log'           , 'Leads'        , 'leads'         , 'id', 'CampaignLog'   , 'campaign_log', 'target_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'lead_direct_reports'         , 'Leads'        , 'leads'         , 'id', 'Leads'         , 'leads', 'reports_to_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'lead_emails'                 , 'Leads'        , 'leads'         , 'id', 'Emails'        , 'emails', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Leads', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'lead_meetings'               , 'Leads'        , 'leads'         , 'id', 'Meetings'      , 'meetings', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Leads', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'lead_notes'                  , 'Leads'        , 'leads'         , 'id', 'Notes'         , 'notes', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Leads', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'lead_tasks'                  , 'Leads'        , 'leads'         , 'id', 'Tasks'         , 'tasks', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Leads', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'leads_assigned_user'         , 'Users'        , 'users'         , 'id', 'Leads'         , 'leads', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'leads_created_by'            , 'Users'        , 'users'         , 'id', 'Leads'         , 'leads', 'created_by_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'leads_modified_user'         , 'Users'        , 'users'         , 'id', 'Leads'         , 'leads', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'meetings_assigned_user'      , 'Users'        , 'users'         , 'id', 'Meetings'      , 'meetings', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'meetings_contacts'           , 'Meetings'     , 'meetings'      , 'id', 'Contacts'      , 'contacts', 'id', 'meetings_contacts', 'meeting_id', 'contact_id', 'many-to-many', null, null, 0;
-- 04/01/2012 Paul.  Add Meetings/Leads relationship. 
exec dbo.spRELATIONSHIPS_InsertOnly 'meetings_leads'              , 'Meetings'     , 'meetings'      , 'id', 'Leads'         , 'leads', 'id', 'meetings_leads', 'meeting_id', 'lead_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'meetings_created_by'         , 'Users'        , 'users'         , 'id', 'Meetings'      , 'meetings', 'created_by_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'meetings_modified_user'      , 'Users'        , 'users'         , 'id', 'Meetings'      , 'meetings', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'meetings_notes'              , 'Meetings'     , 'meetings'      , 'id', 'Notes'         , 'notes', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Meetings', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'meetings_users'              , 'Meetings'     , 'meetings'      , 'id', 'Users'         , 'users'         , 'id', 'meetings_users', 'meeting_id', 'user_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'member_accounts'             , 'Accounts'     , 'accounts'      , 'id', 'Accounts'      , 'accounts', 'parent_id', null, null, null, 'one-to-many', null, null, 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'notes_assigned_user'         , 'Users'        , 'users'         , 'id', 'Notes'         , 'notes', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'notes_created_by'            , 'Users'        , 'users'         , 'id', 'Notes'         , 'notes', 'created_by_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'notes_modified_user'         , 'Users'        , 'users'         , 'id', 'Notes'         , 'notes', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;
-- 03/02/2010 Paul.  Allow reporting or workflow on Notes event.  Must be many-to-many. 
exec dbo.spRELATIONSHIPS_InsertOnly 'notes_account'               , 'Notes'        , 'notes'         , 'parent_id' , 'Accounts'     , 'accounts'      , 'id', null, null, null, 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'notes_bug'                   , 'Notes'        , 'notes'         , 'parent_id' , 'Bugs'         , 'bugs'          , 'id', null, null, null, 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'notes_calls'                 , 'Notes'        , 'notes'         , 'parent_id' , 'Calls'        , 'calls'         , 'id', null, null, null, 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'notes_case'                  , 'Notes'        , 'notes'         , 'parent_id' , 'Cases'        , 'cases'         , 'id', null, null, null, 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'notes_contact'               , 'Notes'        , 'notes'         , 'contact_id', 'Contacts'     , 'contacts'      , 'id', null, null, null, 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'notes_lead'                  , 'Notes'        , 'notes'         , 'parent_id' , 'Leads'        , 'leads'         , 'id', null, null, null, 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'notes_meetings'              , 'Notes'        , 'notes'         , 'parent_id' , 'Meetings'     , 'meetings'      , 'id', null, null, null, 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'notes_opportunity'           , 'Notes'        , 'notes'         , 'parent_id' , 'Opportunities', 'opportunities' , 'id', null, null, null, 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'notes_project'               , 'Notes'        , 'notes'         , 'parent_id' , 'Project'      , 'project'       , 'id', null, null, null, 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'notes_project_task'          , 'Notes'        , 'notes'         , 'parent_id' , 'ProjectTask'  , 'project_task'  , 'id', null, null, null, 'many-to-many', null, null, 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'opportunities_assigned_user' , 'Users'        , 'users'         , 'id', 'Opportunities' , 'opportunities', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'opportunities_contacts'      , 'Opportunities', 'opportunities' , 'id', 'Contacts'      , 'contacts', 'id', 'opportunities_contacts', 'opportunity_id', 'contact_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'opportunities_created_by'    , 'Users'        , 'users'         , 'id', 'Opportunities' , 'opportunities', 'created_by_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'opportunities_modified_user' , 'Users'        , 'users'         , 'id', 'Opportunities' , 'opportunities', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'opportunity_calls'           , 'Opportunities', 'opportunities' , 'id', 'Calls'         , 'calls', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Opportunities', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'opportunity_emails'          , 'Opportunities', 'opportunities' , 'id', 'Emails'        , 'emails', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Opportunities', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'opportunity_leads'           , 'Opportunities', 'opportunities' , 'id', 'Leads'         , 'leads', 'opportunity_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'opportunity_meetings'        , 'Opportunities', 'opportunities' , 'id', 'Meetings'      , 'meetings', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Opportunities', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'opportunity_notes'           , 'Opportunities', 'opportunities' , 'id', 'Notes'         , 'notes', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Opportunities', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'opportunity_tasks'           , 'Opportunities', 'opportunities' , 'id', 'Tasks'         , 'tasks', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Opportunities', 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'project_calls'               , 'Project'      , 'project'       , 'id', 'Calls'         , 'calls', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Project', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'project_emails'              , 'Project'      , 'project'       , 'id', 'Emails'        , 'emails', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Project', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'project_meetings'            , 'Project'      , 'project'       , 'id', 'Meetings'      , 'meetings', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Project', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'project_notes'               , 'Project'      , 'project'       , 'id', 'Notes'         , 'notes', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Project', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'project_project_tasks'       , 'Project'      , 'project'       , 'id', 'ProjectTask'   , 'project_task', 'parent_id', null, null, null, 'one-to-many', null, null, 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'project_task_assigned_user'  , 'Users'        , 'users'         , 'id', 'ProjectTask'   , 'project_task', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'project_task_calls'          , 'ProjectTask'  , 'project_task'  , 'id', 'Calls'         , 'calls', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'ProjectTask', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'project_task_created_by'     , 'Users'        , 'users'         , 'id', 'ProjectTask'   , 'project_task', 'created_by_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'project_task_emails'         , 'ProjectTask'  , 'project_task'  , 'id', 'Emails'        , 'emails', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'ProjectTask', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'project_task_meetings'       , 'ProjectTask'  , 'project_task'  , 'id', 'Meetings'      , 'meetings', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'ProjectTask', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'project_task_modified_user'  , 'Users'        , 'users'         , 'id', 'ProjectTask'   , 'project_task', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'project_task_notes'          , 'ProjectTask'  , 'project_task'  , 'id', 'Notes'         , 'notes', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'ProjectTask', 0;
-- 11/17/2009 Paul.  Add relationship to Tasks so that we can create a task as part of a workflow. 
exec dbo.spRELATIONSHIPS_InsertOnly 'project_task_tasks'          , 'ProjectTask'  , 'project_task'  , 'id', 'Tasks'         , 'tasks', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'ProjectTask', 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'projects_assigned_user'      , 'Users'        , 'users'         , 'id', 'Project'       , 'project', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'projects_created_by'         , 'Users'        , 'users'         , 'id', 'Project'       , 'project', 'created_by_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'projects_modified_user'      , 'Users'        , 'users'         , 'id', 'Project'       , 'project', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'prospect_campaign_log'       , 'Prospects'    , 'prospects'     , 'id', 'CampaignLog'   , 'campaign_log', 'target_id', null, null, null, 'one-to-many', null, null, 0;
-- 05/24/2016 Paul.  Add activity relationships for Prospects module. 
exec dbo.spRELATIONSHIPS_InsertOnly 'prospect_calls'              , 'Prospects'    , 'prospects'     , 'id', 'Calls'         , 'calls'   , 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Prospects', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'prospect_meetings'           , 'Prospects'    , 'prospects'     , 'id', 'Meetings'      , 'meetings', 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Prospects', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'prospect_notes'              , 'Prospects'    , 'prospects'     , 'id', 'Notes'         , 'notes'   , 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Prospects', 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'prospect_tasks'              , 'Prospects'    , 'prospects'     , 'id', 'Tasks'         , 'tasks'   , 'parent_id', null, null, null, 'one-to-many', 'parent_type', 'Prospects', 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'prospect_lists_campaigns'    , 'ProspectLists', 'prospect_lists', 'id', 'Campaigns'     , 'campaigns', 'id', 'prospect_list_campaigns', 'prospect_list_id', 'campaign_id', 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'prospect_lists_assigned_user', 'Users'        , 'users'         , 'id', 'ProspectLists' , 'prospect_lists', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'prospect_lists_created_by'   , 'Users'        , 'users'         , 'id', 'ProspectLists' , 'prospect_lists', 'created_by_id'   , null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'prospect_lists_modified_user', 'Users'        , 'users'         , 'id', 'ProspectLists' , 'prospect_lists', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;
-- 10/31/2008 Paul.  Some Prospect List relationships were removed by mistake. 
-- 07/07/2014 Paul.  The relationship views already define RELATED_TYPE, so remove from table. 
exec dbo.spRELATIONSHIPS_InsertOnly 'prospect_list_contacts'      , 'ProspectLists', 'prospect_lists', 'id', 'Contacts'      , 'contacts'      , 'id', 'prospect_lists_contacts' , 'prospect_list_id', 'contact_id' , 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'prospect_list_leads'         , 'ProspectLists', 'prospect_lists', 'id', 'Leads'         , 'leads'         , 'id', 'prospect_lists_leads'    , 'prospect_list_id', 'lead_id'    , 'many-to-many', null, null, 0;
-- 08/30/2014 Paul.  prospect_list_prospects still uses related_id. 
exec dbo.spRELATIONSHIPS_InsertOnly 'prospect_list_prospects'     , 'ProspectLists', 'prospect_lists', 'id', 'Prospects'     , 'prospects'     , 'id', 'prospect_lists_prospects', 'prospect_list_id', 'related_id' , 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'prospect_list_users'         , 'ProspectLists', 'prospect_lists', 'id', 'Users'         , 'users'         , 'id', 'prospect_lists_users'    , 'prospect_list_id', 'user_id'    , 'many-to-many', null, null, 0;
-- 10/31/2008 Paul.  Fix bad Prospect List relationships. 
if exists(select * from RELATIONSHIPS where RELATIONSHIP_NAME = 'prospect_list_contacts' and (JOIN_TABLE = 'prospect_lists_prospects' or JOIN_KEY_RHS = 'related_id') and DELETED = 0) begin -- then
	print 'Fix RELATIONSHIPS: prospect_list_contacts';
	update RELATIONSHIPS
	   set JOIN_TABLE        = 'prospect_lists_contacts'
	     , JOIN_KEY_RHS      = 'contact_id'
	     , RELATIONSHIP_ROLE_COLUMN       = null
	     , RELATIONSHIP_ROLE_COLUMN_VALUE = null
	     , DATE_MODIFIED_UTC = getutcdate()
	     , DATE_MODIFIED     = getdate()
	     , MODIFIED_USER_ID  = null
	 where RELATIONSHIP_NAME = 'prospect_list_contacts'
	   and (JOIN_TABLE       = 'prospect_lists_prospects' or JOIN_KEY_RHS = 'related_id')
	   and DELETED           = 0;
end -- if;
if exists(select * from RELATIONSHIPS where RELATIONSHIP_NAME = 'prospect_list_leads' and (JOIN_TABLE = 'prospect_lists_prospects' or JOIN_KEY_RHS = 'related_id') and DELETED = 0) begin -- then
	print 'Fix RELATIONSHIPS: prospect_list_leads';
	update RELATIONSHIPS
	   set JOIN_TABLE        = 'prospect_lists_leads'
	     , JOIN_KEY_RHS      = 'lead_id'
	     , RELATIONSHIP_ROLE_COLUMN       = null
	     , RELATIONSHIP_ROLE_COLUMN_VALUE = null
	     , DATE_MODIFIED_UTC = getutcdate()
	     , DATE_MODIFIED     = getdate()
	     , MODIFIED_USER_ID  = null
	 where RELATIONSHIP_NAME = 'prospect_list_leads'
	   and (JOIN_TABLE       = 'prospect_lists_prospects' or JOIN_KEY_RHS = 'related_id')
	   and DELETED           = 0;
end -- if;
-- 08/30/2014 Paul.  prospect_list_prospects still uses related_id. 
if exists(select * from RELATIONSHIPS where RELATIONSHIP_NAME = 'prospect_list_prospects' and (JOIN_TABLE = 'prospect_lists_prospects' and JOIN_KEY_RHS = 'prospect_id') and DELETED = 0) begin -- then
	print 'Fix RELATIONSHIPS: prospect_list_prospects';
	update RELATIONSHIPS
	   set JOIN_TABLE        = 'prospect_lists_prospects'
	     , JOIN_KEY_RHS      = 'related_id'
	     , RELATIONSHIP_ROLE_COLUMN       = null
	     , RELATIONSHIP_ROLE_COLUMN_VALUE = null
	     , DATE_MODIFIED_UTC = getutcdate()
	     , DATE_MODIFIED     = getdate()
	     , MODIFIED_USER_ID  = null
	 where RELATIONSHIP_NAME = 'prospect_list_prospects'
	   and (JOIN_TABLE       = 'prospect_lists_prospects' and JOIN_KEY_RHS = 'prospect_id')
	   and DELETED           = 0;
end -- if;
if exists(select * from RELATIONSHIPS where RELATIONSHIP_NAME = 'prospect_list_users' and (JOIN_TABLE = 'prospect_lists_prospects' or JOIN_KEY_RHS = 'related_id') and DELETED = 0) begin -- then
	print 'Fix RELATIONSHIPS: prospect_list_users';
	update RELATIONSHIPS
	   set JOIN_TABLE        = 'prospect_lists_users'
	     , JOIN_KEY_RHS      = 'user_id'
	     , RELATIONSHIP_ROLE_COLUMN       = null
	     , RELATIONSHIP_ROLE_COLUMN_VALUE = null
	     , DATE_MODIFIED_UTC = getutcdate()
	     , DATE_MODIFIED     = getdate()
	     , MODIFIED_USER_ID  = null
	 where RELATIONSHIP_NAME = 'prospect_list_users'
	   and (JOIN_TABLE       = 'prospect_lists_prospects' or JOIN_KEY_RHS = 'related_id')
	   and DELETED           = 0;
end -- if;
GO

-- 07/07/2014 Paul.  The relationship views already define RELATED_TYPE, so remove from table. 
if exists(select * from RELATIONSHIPS where RELATIONSHIP_NAME = 'prospect_list_contacts' and RELATIONSHIP_ROLE_COLUMN = 'related_type' and DELETED = 0) begin -- then
	print 'Fix RELATIONSHIPS: prospect_list_contacts, related_type';
	update RELATIONSHIPS
	   set RELATIONSHIP_ROLE_COLUMN       = null
	     , RELATIONSHIP_ROLE_COLUMN_VALUE = null
	     , DATE_MODIFIED                  = getdate()
	     , DATE_MODIFIED_UTC              = getutcdate()
	     , MODIFIED_USER_ID               = null
	 where RELATIONSHIP_NAME              = 'prospect_list_contacts'
	   and RELATIONSHIP_ROLE_COLUMN       = 'related_type'
	   and DELETED                        = 0;
end -- if;
if exists(select * from RELATIONSHIPS where RELATIONSHIP_NAME = 'prospect_list_leads' and RELATIONSHIP_ROLE_COLUMN = 'related_type' and DELETED = 0) begin -- then
	print 'Fix RELATIONSHIPS: prospect_list_leads, related_type';
	update RELATIONSHIPS
	   set RELATIONSHIP_ROLE_COLUMN       = null
	     , RELATIONSHIP_ROLE_COLUMN_VALUE = null
	     , DATE_MODIFIED                  = getdate()
	     , DATE_MODIFIED_UTC              = getutcdate()
	     , MODIFIED_USER_ID               = null
	 where RELATIONSHIP_NAME              = 'prospect_list_leads'
	   and RELATIONSHIP_ROLE_COLUMN       = 'related_type'
	   and DELETED                        = 0;
end -- if;
if exists(select * from RELATIONSHIPS where RELATIONSHIP_NAME = 'prospect_list_prospects' and RELATIONSHIP_ROLE_COLUMN = 'related_type' and DELETED = 0) begin -- then
	print 'Fix RELATIONSHIPS: prospect_list_prospects, related_type';
	update RELATIONSHIPS
	   set RELATIONSHIP_ROLE_COLUMN       = null
	     , RELATIONSHIP_ROLE_COLUMN_VALUE = null
	     , DATE_MODIFIED                  = getdate()
	     , DATE_MODIFIED_UTC              = getutcdate()
	     , MODIFIED_USER_ID               = null
	 where RELATIONSHIP_NAME              = 'prospect_list_prospects'
	   and RELATIONSHIP_ROLE_COLUMN       = 'related_type'
	   and DELETED                        = 0;
end -- if;
if exists(select * from RELATIONSHIPS where RELATIONSHIP_NAME = 'prospect_list_users' and RELATIONSHIP_ROLE_COLUMN = 'related_type' and DELETED = 0) begin -- then
	print 'Fix RELATIONSHIPS: prospect_list_users, related_type';
	update RELATIONSHIPS
	   set RELATIONSHIP_ROLE_COLUMN       = null
	     , RELATIONSHIP_ROLE_COLUMN_VALUE = null
	     , DATE_MODIFIED                  = getdate()
	     , DATE_MODIFIED_UTC              = getutcdate()
	     , MODIFIED_USER_ID               = null
	 where RELATIONSHIP_NAME              = 'prospect_list_users'
	   and RELATIONSHIP_ROLE_COLUMN       = 'related_type'
	   and DELETED                        = 0;
end -- if;

exec dbo.spRELATIONSHIPS_InsertOnly 'prospects_assigned_user'     , 'Users'        , 'users'         , 'id', 'Prospects'     , 'prospects', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'prospects_created_by'        , 'Users'        , 'users'         , 'id', 'Prospects'     , 'prospects', 'created_by_id'   , null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'prospects_modified_user'     , 'Users'        , 'users'         , 'id', 'Prospects'     , 'prospects', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;

exec dbo.spRELATIONSHIPS_InsertOnly 'tasks_assigned_user'         , 'Users'        , 'users'         , 'id', 'Tasks'         , 'tasks', 'assigned_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'tasks_created_by'            , 'Users'        , 'users'         , 'id', 'Tasks'         , 'tasks', 'created_by_id'   , null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'tasks_modified_user'         , 'Users'        , 'users'         , 'id', 'Tasks'         , 'tasks', 'modified_user_id', null, null, null, 'one-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'user_direct_reports'         , 'Users'        , 'users'         , 'id', 'Users'         , 'users', 'reports_to_id'   , null, null, null, 'one-to-many', null, null, 0;
GO


-- 07/13/2006 Paul.  Project relationships are special in that they do not use the same join as SugarCRM.  
-- SplendidCRM has unique views for each relationship. 
if exists(select * from RELATIONSHIPS where RELATIONSHIP_NAME = 'projects_accounts' and JOIN_TABLE = 'project_relation') begin -- then
	delete from RELATIONSHIPS
	 where RELATIONSHIP_NAME = 'projects_accounts'
	   and JOIN_TABLE        = 'project_relation';
end -- if;

if exists(select * from RELATIONSHIPS where RELATIONSHIP_NAME = 'projects_contacts' and JOIN_TABLE = 'project_relation') begin -- then
	delete from RELATIONSHIPS
	 where RELATIONSHIP_NAME = 'projects_contacts'
	   and JOIN_TABLE        = 'project_relation';
end -- if;

if exists(select * from RELATIONSHIPS where RELATIONSHIP_NAME = 'projects_opportunities' and JOIN_TABLE = 'project_relation') begin -- then
	delete from RELATIONSHIPS
	 where RELATIONSHIP_NAME = 'projects_opportunities'
	   and JOIN_TABLE        = 'project_relation';
end -- if;

-- 07/13/2006 Paul.  Our Project relationships use views, so specify the view (without the vw) in the join table field. 
exec dbo.spRELATIONSHIPS_InsertOnly 'projects_accounts'     , 'Project' , 'project' , 'id', 'Accounts'     , 'accounts'     , 'id', 'projects_accounts'     , 'project_id', 'account_id'    , 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'projects_contacts'     , 'Project' , 'project' , 'id', 'Contacts'     , 'contacts'     , 'id', 'projects_contacts'     , 'project_id', 'contact_id'    , 'many-to-many', null, null, 0;
exec dbo.spRELATIONSHIPS_InsertOnly 'projects_opportunities', 'Project' , 'project' , 'id', 'Opportunities', 'opportunities', 'id', 'projects_opportunities', 'project_id', 'opportunity_id', 'many-to-many', null, null, 0;
GO


-- 07/16/2006 Paul.  The SplendidCRM views use CREATED_BY as the name and CREATED_BY_ID as the uniqueidentifier. 
if exists(select * from RELATIONSHIPS where RHS_KEY = 'created_by' and DELETED = 0) begin -- then
	update RELATIONSHIPS
	   set RHS_KEY          = 'created_by_id'
	     , DATE_MODIFIED    = getdate()
	     , MODIFIED_USER_ID = null
	 where RHS_KEY          = 'created_by'
	   and DELETED          = 0;
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

call dbo.spRELATIONSHIPS_Defaults()
/

call dbo.spSqlDropProcedure('spRELATIONSHIPS_Defaults')
/

-- #endif IBM_DB2 */

