

print 'TERMINOLOGY ActivityStream en-us';
GO

set nocount on;
GO

-- delete from TERMINOLOGY where MODULE_NAME = 'ActivityStream';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ACTIVITY_STREAM'                           , N'en-US', null, null, null, N'Activity Stream';
exec dbo.spTERMINOLOGY_InsertOnly N'LNK_ACTIVITY_STREAM'                           , N'en-US', null, null, null, N'Activity Stream';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MY_ACTIVITY_STREAM'                        , N'en-US', N'ActivityStream', null, null, N'My Activity Stream';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_POST_BUTTON'                               , N'en-US', N'ActivityStream', null, null, N'Post Message';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MODULE_ABBREVIATION'                       , N'en-US', N'ActivityStream', null, null, N'Stm';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_CREATED'                                   , N'en-US', N'ActivityStream', null, null, N'Created';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UPDATED'                                   , N'en-US', N'ActivityStream', null, null, N'Updated';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_DELETED'                                   , N'en-US', N'ActivityStream', null, null, N'Deleted';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_LINKED'                                    , N'en-US', N'ActivityStream', null, null, N'Linked';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_UNLINKED'                                  , N'en-US', N'ActivityStream', null, null, N'Unlinked';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_POST'                                      , N'en-US', N'ActivityStream', null, null, N'Post';

exec dbo.spTERMINOLOGY_InsertOnly N'Created'                                       , N'en-US', null, N'activity_stream_action',  1, N'Created';
exec dbo.spTERMINOLOGY_InsertOnly N'Updated'                                       , N'en-US', null, N'activity_stream_action',  2, N'Updated';
exec dbo.spTERMINOLOGY_InsertOnly N'Deleted'                                       , N'en-US', null, N'activity_stream_action',  3, N'Deleted';
exec dbo.spTERMINOLOGY_InsertOnly N'Linked'                                        , N'en-US', null, N'activity_stream_action',  4, N'Linked';
exec dbo.spTERMINOLOGY_InsertOnly N'Unlinked'                                      , N'en-US', null, N'activity_stream_action',  5, N'Unlinked';
exec dbo.spTERMINOLOGY_InsertOnly N'Post'                                          , N'en-US', null, N'activity_stream_action',  6, N'Post';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_TO'                                        , N'en-US', N'ActivityStream', null, null, N'to';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_FROM'                                      , N'en-US', N'ActivityStream', null, null, N'from';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NOTHING'                                   , N'en-US', N'ActivityStream', null, null, N'(nothing)';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ALL'                                       , N'en-US', N'ActivityStream', null, null, N'(all)';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_MORE'                                      , N'en-US', N'ActivityStream', null, null, N'(more)';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NONE'                                      , N'en-US', N'ActivityStream', null, null, N'(none)';
-- 08/23/2019 Paul.  When manually constructing text. 
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_ON'                                        , N'en-US', N'ActivityStream', null, null, N'on';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_NAME'                                      , N'en-US', N'ActivityStream', null, null, N'Name:';

-- select * from TERMINOLOGY where list_name = 'modulelist' order by list_order desc
-- 03/06/2016 Paul.  Add moduleList entry. 
exec dbo.spTERMINOLOGY_InsertOnly N'ActivityStream'                                , N'en-US', null, N'moduleList', 158, N'ActivityStream';
-- select * from TERMINOLOGY where list_name = 'moduleListSingular' order by list_order desc
-- 06/02/2016 Paul.  Add moduleListSingular entry. 
exec dbo.spTERMINOLOGY_InsertOnly N'ActivityStream'                                , N'en-US', null, N'moduleListSingular', 33, N'ActivityStream';

delete from TERMINOLOGY
 where LIST_NAME         = 'ActivityStream'
   and NAME              = 'AuthorizeNet';

-- delete from TERMINOLOGY where NAME like 'LBL_STREAM_FORMAT_%' or NAME like 'LBL_STREAM_FIELDS_%';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_CREATED'                     , N'en-US', N'Accounts', null, null, N'Created <a href="~/Accounts/view.aspx?ID={0}">{1}</a> Account.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_UPDATED'                     , N'en-US', N'Accounts', null, null, N'Updated <span class="ActivityStreamUpdateFields">{0}</span> on <a href="~/Accounts/view.aspx?ID={1}">{2}</a>.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_DELETED'                     , N'en-US', N'Accounts', null, null, N'Deleted {0} Account.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_CREATED'                     , N'en-US', N'Accounts', null, null, N'ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_UPDATED'                     , N'en-US', N'Accounts', null, null, N'STREAM_COLUMNS ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_DELETED'                     , N'en-US', N'Accounts', null, null, N'NAME';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_CREATED'                     , N'en-US', N'Contacts', null, null, N'Created <a href="~/Contacts/view.aspx?ID={0}">{1}</a> Contact.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_UPDATED'                     , N'en-US', N'Contacts', null, null, N'Updated <span class="ActivityStreamUpdateFields">{0}</span> on <a href="~/Contacts/view.aspx?ID={1}">{2}</a>.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_DELETED'                     , N'en-US', N'Contacts', null, null, N'Deleted {0} Contact.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_CREATED'                     , N'en-US', N'Contacts', null, null, N'ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_UPDATED'                     , N'en-US', N'Contacts', null, null, N'STREAM_COLUMNS ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_DELETED'                     , N'en-US', N'Contacts', null, null, N'NAME';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_CREATED'                     , N'en-US', N'Leads', null, null, N'Created <a href="~/Leads/view.aspx?ID={0}">{1}</a> Lead.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_UPDATED'                     , N'en-US', N'Leads', null, null, N'Updated <span class="ActivityStreamUpdateFields">{0}</span> on <a href="~/Leads/view.aspx?ID={1}">{2}</a>.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_DELETED'                     , N'en-US', N'Leads', null, null, N'Deleted {0} Lead.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_CREATED'                     , N'en-US', N'Leads', null, null, N'ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_UPDATED'                     , N'en-US', N'Leads', null, null, N'STREAM_COLUMNS ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_DELETED'                     , N'en-US', N'Leads', null, null, N'NAME';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_CREATED'                     , N'en-US', N'Prospects', null, null, N'Created <a href="~/Prospects/view.aspx?ID={0}">{1}</a> Target.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_UPDATED'                     , N'en-US', N'Prospects', null, null, N'Updated <span class="ActivityStreamUpdateFields">{0}</span> on <a href="~/Prospects/view.aspx?ID={1}">{2}</a>.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_DELETED'                     , N'en-US', N'Prospects', null, null, N'Deleted {0} Target.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_CREATED'                     , N'en-US', N'Prospects', null, null, N'ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_UPDATED'                     , N'en-US', N'Prospects', null, null, N'STREAM_COLUMNS ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_DELETED'                     , N'en-US', N'Prospects', null, null, N'NAME';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_CREATED'                     , N'en-US', N'Opportunities', null, null, N'Created <a href="~/Opportunities/view.aspx?ID={0}">{1}</a> Opportunity.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_UPDATED'                     , N'en-US', N'Opportunities', null, null, N'Updated <span class="ActivityStreamUpdateFields">{0}</span> on <a href="~/Opportunities/view.aspx?ID={1}">{2}</a>.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_DELETED'                     , N'en-US', N'Opportunities', null, null, N'Deleted {0} Opportunity.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_CREATED'                     , N'en-US', N'Opportunities', null, null, N'ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_UPDATED'                     , N'en-US', N'Opportunities', null, null, N'STREAM_COLUMNS ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_DELETED'                     , N'en-US', N'Opportunities', null, null, N'NAME';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_CREATED'                     , N'en-US', N'ProspectLists', null, null, N'Created <a href="~/ProspectLists/view.aspx?ID={0}">{1}</a> Target List.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_UPDATED'                     , N'en-US', N'ProspectLists', null, null, N'Updated <span class="ActivityStreamUpdateFields">{0}</span> on <a href="~/ProspectLists/view.aspx?ID={1}">{2}</a>.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_DELETED'                     , N'en-US', N'ProspectLists', null, null, N'Deleted {0} Target List.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_CREATED'                     , N'en-US', N'ProspectLists', null, null, N'ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_UPDATED'                     , N'en-US', N'ProspectLists', null, null, N'STREAM_COLUMNS ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_DELETED'                     , N'en-US', N'ProspectLists', null, null, N'NAME';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_CREATED'                     , N'en-US', N'Campaigns', null, null, N'Created <a href="~/Campaigns/view.aspx?ID={0}">{1}</a> Campaign.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_UPDATED'                     , N'en-US', N'Campaigns', null, null, N'Updated <span class="ActivityStreamUpdateFields">{0}</span> on <a href="~/Campaigns/view.aspx?ID={1}">{2}</a>.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_DELETED'                     , N'en-US', N'Campaigns', null, null, N'Deleted {0} Campaign.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_CREATED'                     , N'en-US', N'Campaigns', null, null, N'ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_UPDATED'                     , N'en-US', N'Campaigns', null, null, N'STREAM_COLUMNS ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_DELETED'                     , N'en-US', N'Campaigns', null, null, N'NAME';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_CREATED'                     , N'en-US', N'EmailTemplates', null, null, N'Created <a href="~/EmailTemplates/view.aspx?ID={0}">{1}</a> Email Template.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_UPDATED'                     , N'en-US', N'EmailTemplates', null, null, N'Updated <span class="ActivityStreamUpdateFields">{0}</span> on <a href="~/EmailTemplates/view.aspx?ID={1}">{2}</a>.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_DELETED'                     , N'en-US', N'EmailTemplates', null, null, N'Deleted {0} Email Template.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_CREATED'                     , N'en-US', N'EmailTemplates', null, null, N'ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_UPDATED'                     , N'en-US', N'EmailTemplates', null, null, N'STREAM_COLUMNS ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_DELETED'                     , N'en-US', N'EmailTemplates', null, null, N'NAME';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_CREATED'                     , N'en-US', N'Bugs', null, null, N'Created <a href="~/Bugs/view.aspx?ID={0}">{1}</a> Bug.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_UPDATED'                     , N'en-US', N'Bugs', null, null, N'Updated <span class="ActivityStreamUpdateFields">{0}</span> on <a href="~/Bugs/view.aspx?ID={1}">{2}</a>.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_DELETED'                     , N'en-US', N'Bugs', null, null, N'Deleted {0} Bug.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_CREATED'                     , N'en-US', N'Bugs', null, null, N'ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_UPDATED'                     , N'en-US', N'Bugs', null, null, N'STREAM_COLUMNS ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_DELETED'                     , N'en-US', N'Bugs', null, null, N'NAME';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_CREATED'                     , N'en-US', N'Cases', null, null, N'Created <a href="~/Cases/view.aspx?ID={0}">{1}</a> Case.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_UPDATED'                     , N'en-US', N'Cases', null, null, N'Updated <span class="ActivityStreamUpdateFields">{0}</span> on <a href="~/Cases/view.aspx?ID={1}">{2}</a>.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_DELETED'                     , N'en-US', N'Cases', null, null, N'Deleted {0} Case.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_CREATED'                     , N'en-US', N'Cases', null, null, N'ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_UPDATED'                     , N'en-US', N'Cases', null, null, N'STREAM_COLUMNS ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_DELETED'                     , N'en-US', N'Cases', null, null, N'NAME';

exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_CREATED'                     , N'en-US', N'Documents', null, null, N'Created <a href="~/Documents/view.aspx?ID={0}">{1}</a> Document.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_UPDATED'                     , N'en-US', N'Documents', null, null, N'Updated <span class="ActivityStreamUpdateFields">{0}</span> on <a href="~/Documents/view.aspx?ID={1}">{2}</a>.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FORMAT_DELETED'                     , N'en-US', N'Documents', null, null, N'Deleted {0} Document.';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_CREATED'                     , N'en-US', N'Documents', null, null, N'ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_UPDATED'                     , N'en-US', N'Documents', null, null, N'STREAM_COLUMNS ID NAME';
exec dbo.spTERMINOLOGY_InsertOnly N'LBL_STREAM_FIELDS_DELETED'                     , N'en-US', N'Documents', null, null, N'NAME';
GO

-- 08/02/2017 Paul.  Some terms are not translated.  These stream labels are used to allow customization but they should not be translated. 
if exists(select * from TERMINOLOGY where NAME = 'LBL_STREAM_FIELDS_CREATED' and DISPLAY_NAME = 'ID-NAME') begin -- then
	update TERMINOLOGY
	   set DISPLAY_NAME      = 'ID NAME'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getdate()
	     , MODIFIED_USER_ID  = null
	 where NAME              = 'LBL_STREAM_FIELDS_CREATED';
	update TERMINOLOGY
	   set DISPLAY_NAME      = 'STREAM_COLUMNS ID NAME'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getdate()
	     , MODIFIED_USER_ID  = null
	 where NAME              = 'LBL_STREAM_FIELDS_UPDATED';
	update TERMINOLOGY
	   set DISPLAY_NAME      = 'NAME'
	     , DATE_MODIFIED     = getdate()
	     , DATE_MODIFIED_UTC = getdate()
	     , MODIFIED_USER_ID  = null
	 where NAME              = 'LBL_STREAM_FIELDS_DELETED';
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

call dbo.spTERMINOLOGY_ActivityStream_en_us()
/

call dbo.spSqlDropProcedure('spTERMINOLOGY_ActivityStream_en_us')
/
-- #endif IBM_DB2 */
