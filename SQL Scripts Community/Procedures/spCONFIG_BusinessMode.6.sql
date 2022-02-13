if exists (select * from INFORMATION_SCHEMA.ROUTINES where ROUTINE_NAME = 'spCONFIG_BusinessMode' and ROUTINE_TYPE = 'PROCEDURE')
	Drop Procedure dbo.spCONFIG_BusinessMode;
GO


/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 *********************************************************************************************************************/
Create Procedure dbo.spCONFIG_BusinessMode
	( @MODIFIED_USER_ID  uniqueidentifier
	, @BUSINESS_MODE     nvarchar(25)
	)
as
  begin
	set nocount on

	exec dbo.spCONFIG_Update @MODIFIED_USER_ID, N'System', N'BusinessMode', @BUSINESS_MODE;
	if @BUSINESS_MODE = N'B2C' begin -- then
		if exists(select * from vwMODULES where MODULE_NAME = N'Accounts' and MODULE_ENABLED = 1) begin -- then
			update MODULES
			   set MODULE_ENABLED    = 0
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
			 where MODULE_NAME       = N'Accounts'
			   and MODULE_ENABLED    = 1
			   and DELETED           = 0;

			exec dbo.spMODULES_TAB_ORDER_Reorder @MODIFIED_USER_ID;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where DATA_FIELD like N'%ACCOUNT_ID' and FIELD_TYPE = N'ModulePopup' and DEFAULT_VIEW = 0) begin -- then
			update EDITVIEWS_FIELDS
			   set DELETED           = 1
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
			 where DATA_FIELD        like N'%ACCOUNT_ID'
			   and FIELD_TYPE        = N'ModulePopup'
			   and DEFAULT_VIEW      = 0
			   and DELETED           = 0;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where (DATA_FIELD like N'%ACCOUNT_NAME' or URL_FIELD like N'%ACCOUNT_ID') and DEFAULT_VIEW = 0) begin -- then
			update DETAILVIEWS_FIELDS
			   set DELETED           = 1
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
			 where (DATA_FIELD like N'%ACCOUNT_NAME' or URL_FIELD like N'%ACCOUNT_ID')
			   and DEFAULT_VIEW      = 0
			   and DELETED           = 0;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where (DATA_FIELD like N'%ACCOUNT_NAME' or URL_FIELD = N'%ACCOUNT_ID') and DEFAULT_VIEW = 0) begin -- then
			update GRIDVIEWS_COLUMNS
			   set DELETED           = 1
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
			 where (DATA_FIELD like N'%ACCOUNT_NAME' or URL_FIELD = N'%ACCOUNT_ID')
			   and DEFAULT_VIEW      = 0
			   and DELETED           = 0;
		end -- if;
/*
select 
'		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N''' + EDIT_NAME + ''') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N''' + EDIT_NAME + ''' and DATA_FIELD = N''' + replace(DATA_FIELD, 'ACCOUNT', 'B2C_CONTACT') + ''') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup ''' + EDIT_NAME + ''', null, ' + isnull('''' + replace(DATA_LABEL, 'ACCOUNT', 'B2C_CONTACT') + '''', 'null') + ', ' + isnull('''' + replace(DATA_FIELD, 'ACCOUNT', 'B2C_CONTACT') + '''', 'null') + ', ' + cast(DATA_REQUIRED as varchar(10)) + ', ' + cast(isnull(FORMAT_TAB_INDEX, 0) as varchar(10)) + ', ' + isnull('''' + replace(DISPLAY_FIELD, 'ACCOUNT', 'B2C_CONTACT') + '''', 'null') + ', ''Contacts'', null;
			end -- if;
		end -- if;
'
  from EDITVIEWS_FIELDS
 where DATA_FIELD like 'ACCOUNT_ID'
   and FIELD_TYPE not in ('Hidden')
   and DEFAULT_VIEW = 0
   and (EDIT_NAME like 'Cases.%' or EDIT_NAME like 'Contracts.%' or EDIT_NAME like 'Opportunities.%' or EDIT_NAME like 'Payments.%')
 order by EDIT_NAME, DATA_FIELD
*/
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView', null, 'Cases.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView.Gmail' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView.Gmail', null, 'Cases.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView.Inline' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView.Inline', null, 'Cases.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView.Mobile' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView.Mobile', null, 'Cases.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 2, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.NewRecord') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.NewRecord' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.NewRecord', null, 'Cases.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.PopupView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.PopupView.Inline' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.PopupView.Inline', null, 'Cases.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchAdvanced') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchAdvanced' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.SearchAdvanced', null, 'Cases.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 0, 0, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchBasic') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchBasic' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.SearchBasic', null, 'Cases.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 0, 0, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchBasic.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchBasic.Gmail' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.SearchBasic.Gmail', null, 'Cases.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 0, 0, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchDuplicates') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchDuplicates' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.SearchDuplicates', null, 'Cases.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 0, 0, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contracts.EditView', null, 'Contracts.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView.Gmail' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contracts.EditView.Gmail', null, 'Contracts.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView.Inline' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contracts.EditView.Inline', null, 'Contracts.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView.Mobile' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contracts.EditView.Mobile', null, 'Contracts.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.SearchAdvanced') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.SearchAdvanced' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contracts.SearchAdvanced', null, 'Contracts.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 0, 0, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.SearchBasic') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.SearchBasic' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contracts.SearchBasic', null, 'Contracts.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 0, 0, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.SearchBasic.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.SearchBasic.Gmail' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contracts.SearchBasic.Gmail', null, 'Contracts.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 0, 0, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView', null, 'Opportunities.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView.Gmail' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView.Gmail', null, 'Opportunities.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView.Inline' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView.Inline', null, 'Opportunities.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView.Mobile' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView.Mobile', null, 'Opportunities.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.NewRecord') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.NewRecord' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.NewRecord', null, 'Opportunities.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.PopupView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.PopupView.Inline' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.PopupView.Inline', null, 'Opportunities.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Payments.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Payments.EditView' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Payments.EditView', null, 'Payments.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 2, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Payments.EditView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Payments.EditView.Inline' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Payments.EditView.Inline', null, 'Payments.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 1, 1, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Payments.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Payments.EditView.Mobile' and DATA_FIELD = N'B2C_CONTACT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Payments.EditView.Mobile', null, 'Payments.LBL_B2C_CONTACT_NAME', 'B2C_CONTACT_ID', 0, 2, 'B2C_CONTACT_NAME', 'Contacts', null;
			end -- if;
		end -- if;
/*
select 
'		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N''' + DETAIL_NAME + ''') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N''' + DETAIL_NAME + ''' and DATA_FIELD = N''' + replace(DATA_FIELD, 'ACCOUNT', 'B2C_CONTACT') + ''') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N''' + DETAIL_NAME + ''',  null, N''' + replace(DATA_LABEL, 'ACCOUNT', 'B2C_CONTACT') + ''', N''' + replace(DATA_FIELD, 'ACCOUNT', 'B2C_CONTACT') + ''', ''{0}'', N''' + replace(URL_FIELD, 'ACCOUNT', 'B2C_CONTACT') + ''', ''~/Accounts/view.aspx?ID={0}'', null, null;
			end -- if;
		end -- if;
'--, DETAIL_NAME, FIELD_TYPE, DATA_LABEL, DATA_FIELD, URL_FIELD, URL_FORMAT
  from DETAILVIEWS_FIELDS
 where DATA_FIELD like '%ACCOUNT_NAME'
   and DEFAULT_VIEW = 0
   and (DETAIL_NAME like 'Cases.%' or DETAIL_NAME like 'Contracts.%' or DETAIL_NAME like 'Opportunities.%' or DETAIL_NAME like 'Payments.%')
 order by DETAIL_NAME, DATA_FIELD
*/
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Cases.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Cases.DetailView' and DATA_FIELD = N'B2C_CONTACT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Cases.DetailView',  null, N'Cases.LBL_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '{0}', N'B2C_CONTACT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Cases.DetailView.Gmail') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Cases.DetailView.Gmail' and DATA_FIELD = N'B2C_CONTACT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Cases.DetailView.Gmail',  null, N'Cases.LBL_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '{0}', N'B2C_CONTACT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Cases.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Cases.DetailView.Mobile' and DATA_FIELD = N'B2C_CONTACT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Cases.DetailView.Mobile',  null, N'Cases.LBL_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '{0}', N'B2C_CONTACT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contracts.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contracts.DetailView' and DATA_FIELD = N'B2C_CONTACT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Contracts.DetailView',  null, N'Contracts.LBL_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '{0}', N'B2C_CONTACT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contracts.DetailView.Gmail') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contracts.DetailView.Gmail' and DATA_FIELD = N'B2C_CONTACT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Contracts.DetailView.Gmail',  null, N'Contracts.LBL_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '{0}', N'B2C_CONTACT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contracts.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contracts.DetailView.Mobile' and DATA_FIELD = N'B2C_CONTACT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Contracts.DetailView.Mobile',  null, N'Contracts.LBL_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '{0}', N'B2C_CONTACT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Opportunities.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Opportunities.DetailView' and DATA_FIELD = N'B2C_CONTACT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Opportunities.DetailView',  null, N'Opportunities.LBL_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '{0}', N'B2C_CONTACT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Opportunities.DetailView.Gmail') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Opportunities.DetailView.Gmail' and DATA_FIELD = N'B2C_CONTACT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Opportunities.DetailView.Gmail',  null, N'Opportunities.LBL_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '{0}', N'B2C_CONTACT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Opportunities.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Opportunities.DetailView.Mobile' and DATA_FIELD = N'B2C_CONTACT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Opportunities.DetailView.Mobile',  null, N'Opportunities.LBL_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '{0}', N'B2C_CONTACT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Payments.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Payments.DetailView' and DATA_FIELD = N'B2C_CONTACT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Payments.DetailView',  null, N'Payments.LBL_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '{0}', N'B2C_CONTACT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Payments.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Payments.DetailView.Mobile' and DATA_FIELD = N'B2C_CONTACT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Payments.DetailView.Mobile',  null, N'Payments.LBL_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '{0}', N'B2C_CONTACT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
/*
select (case when DATA_FORMAT = 'HyperLink' then 
'		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N''' + GRID_NAME + ''') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N''' + GRID_NAME + ''' and DATA_FIELD = N''' + DATA_FIELD + ''') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N''' + GRID_NAME + ''', null, N''' + replace(HEADER_TEXT, 'ACCOUNT', 'B2C_CONTACT') + ''', N''' + replace(DATA_FIELD, 'ACCOUNT', 'B2C_CONTACT') + ''', N''' + replace(SORT_EXPRESSION, 'ACCOUNT', 'B2C_CONTACT') + ''', ''20%'', ''listViewTdLinkS1'', N''' + replace(URL_FIELD, 'ACCOUNT', 'B2C_CONTACT') + ''', ''~/Contacts/view.aspx?id={0}'', null, ''Contacts'', N''' + replace(URL_ASSIGNED_FIELD, 'ACCOUNT', 'B2C_CONTACT') + ''';
			end -- if;
		end -- if;
'
       when DATA_FORMAT is null then
'		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N''' + GRID_NAME + ''') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N''' + GRID_NAME + ''' and DATA_FIELD = N''' + DATA_FIELD + ''') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N''' + GRID_NAME + ''', null, N''' + replace(HEADER_TEXT, 'ACCOUNT', 'B2C_CONTACT') + ''', N''' + replace(DATA_FIELD, 'ACCOUNT', 'B2C_CONTACT') + ''', N' + isnull('''' + replace(SORT_EXPRESSION, 'ACCOUNT', 'B2C_CONTACT') + '''', 'null') + ', ''25%'';
			end -- if;
		end -- if;
' end)--, GRID_NAME, COLUMN_TYPE, HEADER_TEXT, DATA_FIELD, SORT_EXPRESSION, DATA_FORMAT, URL_FIELD, URL_FORMAT, URL_MODULE, URL_ASSIGNED_FIELD
  from GRIDVIEWS_COLUMNS
 where DATA_FIELD like '%ACCOUNT_NAME'
   and DEFAULT_VIEW = 0
   and (GRID_NAME like '%Cases%' or GRID_NAME like '%Contracts%' or GRID_NAME like '%Opportunities%' or GRID_NAME like '%Payments%')
 order by GRID_NAME, DATA_FIELD
*/
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Accounts.Cases', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Contracts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Contracts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Accounts.Contracts', null, N'Contracts.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Opportunities') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Opportunities' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Accounts.Opportunities', null, N'Opportunities.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Bugs.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Bugs.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Bugs.Cases', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Campaigns.Opportunities') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Campaigns.Opportunities' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Campaigns.Opportunities', null, N'Opportunities.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.Contacts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.Contacts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Cases.Contacts', null, N'Contacts.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Cases.Export', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.ListView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.ListView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Cases.ListView', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.ListView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.ListView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Cases.ListView.Gmail', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.ListView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.ListView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Cases.ListView.Mobile', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.MyCases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.MyCases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Cases.MyCases', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.PopupView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.PopupView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Cases.PopupView', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.PopupView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.PopupView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Cases.PopupView.Gmail', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.PopupView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.PopupView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Cases.PopupView.Mobile', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.Search') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.Search' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Cases.Search', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Contacts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Contacts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contracts.Contacts', null, N'Contacts.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contracts.Export', null, N'Contracts.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.ListView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.ListView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contracts.ListView', null, N'Contracts.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.ListView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.ListView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contracts.ListView.Gmail', null, N'Contracts.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.ListView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.ListView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contracts.ListView.Mobile', null, N'Contracts.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.PopupView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.PopupView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contracts.PopupView', null, N'Contracts.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.PopupView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.PopupView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contracts.PopupView.Gmail', null, N'Contracts.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.PopupView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.PopupView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contracts.PopupView.Mobile', null, N'Contracts.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Products') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Products' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contracts.Products', null, N'Products.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Quotes') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Quotes' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contracts.Quotes', null, N'Quotes.LBL_LIST_B2C_CONTACT_NAME', N'BILLING_B2C_CONTACT_NAME', N'BILLING_B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'BILLING_B2C_CONTACT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Search') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Search' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contracts.Search', null, N'Contracts.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Documents.Cases', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Contracts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Contracts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Documents.Contracts', null, N'Contracts.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Opportunities') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Opportunities' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Documents.Opportunities', null, N'Opportunities.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Emails.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Emails.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Emails.Cases', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Emails.Opportunities') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Emails.Opportunities' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Emails.Opportunities', null, N'Opportunities.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Invoices.Cases', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'KBDocuments.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'KBDocuments.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'KBDocuments.Cases', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Contracts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Contracts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Opportunities.Contracts', null, N'Contracts.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Opportunities.Export', null, N'Opportunities.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.ListView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.ListView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Opportunities.ListView', null, N'Opportunities.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.ListView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.ListView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Opportunities.ListView.Gmail', null, N'Opportunities.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.ListView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.ListView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Opportunities.ListView.Mobile', null, N'Opportunities.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.MyOpportunities') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.MyOpportunities' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Opportunities.MyOpportunities', null, N'Opportunities.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.PopupView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.PopupView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Opportunities.PopupView', null, N'Opportunities.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.PopupView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.PopupView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Opportunities.PopupView.Gmail', null, N'Opportunities.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.PopupView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.PopupView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Opportunities.PopupView.Mobile', null, N'Opportunities.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Quotes') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Quotes' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Opportunities.Quotes', null, N'Quotes.LBL_LIST_B2C_CONTACT_NAME', N'BILLING_B2C_CONTACT_NAME', N'BILLING_B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'BILLING_B2C_CONTACT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Search') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Search' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Opportunities.Search', null, N'Opportunities.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Orders.Cases', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Payments.Export', null, N'Payments.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.ListView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.ListView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Payments.ListView', null, N'Payments.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.ListView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.ListView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Payments.ListView.Mobile', null, N'Payments.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.PopupView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.PopupView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Payments.PopupView', null, N'Payments.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.PopupView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.PopupView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Payments.PopupView.Mobile', null, N'Payments.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.Search') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.Search' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Payments.Search', null, N'Payments.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Project.Opportunities') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Project.Opportunities' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Project.Opportunities', null, N'Opportunities.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Quotes.Cases', null, N'Cases.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Contracts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Contracts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Quotes.Contracts', null, N'Contracts.LBL_LIST_B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', N'B2C_CONTACT_NAME', '20%', 'listViewTdLinkS1', N'B2C_CONTACT_ID', '~/Contacts/view.aspx?id={0}', null, 'Contacts', N'B2C_CONTACT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
	end -- if;

	if @BUSINESS_MODE = N'B2B' begin -- then
		if exists(select * from vwMODULES where MODULE_NAME = N'Accounts' and MODULE_ENABLED = 0) begin -- then
			update MODULES
			   set MODULE_ENABLED    = 0
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
			 where MODULE_NAME       = N'Accounts'
			   and MODULE_ENABLED    = 0
			   and DELETED           = 0;

			exec dbo.spMODULES_TAB_ORDER_Reorder @MODIFIED_USER_ID;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where DATA_FIELD like N'%B2C_CONTACT_ID' and FIELD_TYPE = N'ModulePopup' and DEFAULT_VIEW = 0) begin -- then
			update EDITVIEWS_FIELDS
			   set DELETED           = 1
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
			 where DATA_FIELD        like N'%B2C_CONTACT_ID'
			   and FIELD_TYPE        = N'ModulePopup'
			   and DEFAULT_VIEW      = 0
			   and DELETED           = 0;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where (DATA_FIELD like N'%B2C_CONTACT_NAME' or URL_FIELD like N'%B2C_CONTACT_ID') and DEFAULT_VIEW = 0) begin -- then
			update DETAILVIEWS_FIELDS
			   set DELETED           = 1
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
			 where (DATA_FIELD like N'%B2C_CONTACT_NAME' or URL_FIELD like N'%B2C_CONTACT_ID')
			   and DEFAULT_VIEW      = 0
			   and DELETED           = 0;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where (DATA_FIELD like N'%B2C_CONTACT_NAME' or URL_FIELD = N'%B2C_CONTACT_ID') and DEFAULT_VIEW = 0) begin -- then
			update GRIDVIEWS_COLUMNS
			   set DELETED           = 1
			     , DATE_MODIFIED     = getdate()
			     , DATE_MODIFIED_UTC = getutcdate()
			     , MODIFIED_USER_ID  = @MODIFIED_USER_ID
			 where (DATA_FIELD like N'%B2C_CONTACT_NAME' or URL_FIELD = N'%B2C_CONTACT_ID')
			   and DEFAULT_VIEW      = 0
			   and DELETED           = 0;
		end -- if;
/*
select 
'		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N''' + EDIT_NAME + ''') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N''' + EDIT_NAME + ''' and DATA_FIELD = N''' + DATA_FIELD + ''') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup ''' + EDIT_NAME + ''', null, ' + isnull('''' + DATA_LABEL + '''', 'null') + ', ' + isnull('''' + DATA_FIELD + '''', 'null') + ', ' + cast(DATA_REQUIRED as varchar(10)) + ', ' + cast(isnull(FORMAT_TAB_INDEX, 0) as varchar(10)) + ', ' + isnull('''' + DISPLAY_FIELD + '''', 'null') + ', ' + isnull('''' + MODULE_TYPE + '''', '''Accounts''') + ', null;
			end -- if;
		end -- if;
'
  from EDITVIEWS_FIELDS
 where DATA_FIELD like '%ACCOUNT_ID'
   and FIELD_TYPE not in ('Hidden')
   and DEFAULT_VIEW = 0
 order by EDIT_NAME, DATA_FIELD
*/
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView', null, 'Cases.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView.Gmail' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView.Gmail', null, 'Cases.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView.Inline' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView.Inline', null, 'Cases.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.EditView.Mobile' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.EditView.Mobile', null, 'Cases.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 2, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.NewRecord') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.NewRecord' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.NewRecord', null, 'Cases.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.PopupView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.PopupView.Inline' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.PopupView.Inline', null, 'Cases.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchAdvanced') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchAdvanced' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.SearchAdvanced', null, 'Cases.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchBasic') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchBasic' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.SearchBasic', null, 'Cases.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchBasic.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchBasic.Gmail' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.SearchBasic.Gmail', null, 'Cases.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchDuplicates') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Cases.SearchDuplicates' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Cases.SearchDuplicates', null, 'Cases.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.EditView' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.EditView', null, 'Contacts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.EditView.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.EditView.Gmail' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.EditView.Gmail', null, 'Contacts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.EditView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.EditView.Inline' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.EditView.Inline', null, 'Contacts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.EditView.Mobile' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.EditView.Mobile', null, 'Cases.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.PopupView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.PopupView.Inline' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.PopupView.Inline', null, 'Contacts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.SearchAdvanced') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.SearchAdvanced' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.SearchAdvanced', null, 'Contacts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.SearchBasic') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.SearchBasic' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.SearchBasic', null, 'Contacts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.SearchBasic.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.SearchBasic.Gmail' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.SearchBasic.Gmail', null, 'Contacts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.SearchBasic.Portal') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.SearchBasic.Portal' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.SearchBasic.Portal', null, 'Contacts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.SearchDuplicates') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contacts.SearchDuplicates' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contacts.SearchDuplicates', null, 'Contacts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contracts.EditView', null, 'Contracts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView.Gmail' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contracts.EditView.Gmail', null, 'Contracts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView.Inline' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contracts.EditView.Inline', null, 'Contracts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.EditView.Mobile' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contracts.EditView.Mobile', null, 'Contracts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.SearchAdvanced') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.SearchAdvanced' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contracts.SearchAdvanced', null, 'Contracts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.SearchBasic') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.SearchBasic' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contracts.SearchBasic', null, 'Contracts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.SearchBasic.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Contracts.SearchBasic.Gmail' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Contracts.SearchBasic.Gmail', null, 'Contracts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.EditView' and DATA_FIELD = N'BILLING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Invoices.EditView', null, 'Invoices.LBL_ACCOUNT', 'BILLING_ACCOUNT_ID', 0, 3, 'BILLING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.EditView' and DATA_FIELD = N'SHIPPING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Invoices.EditView', null, 'Invoices.LBL_ACCOUNT', 'SHIPPING_ACCOUNT_ID', 0, 4, 'SHIPPING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.EditView.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.EditView.Gmail' and DATA_FIELD = N'BILLING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Invoices.EditView.Gmail', null, 'Invoices.LBL_ACCOUNT', 'BILLING_ACCOUNT_ID', 1, 3, 'BILLING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.EditView.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.EditView.Gmail' and DATA_FIELD = N'SHIPPING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Invoices.EditView.Gmail', null, 'Invoices.LBL_ACCOUNT', 'SHIPPING_ACCOUNT_ID', 0, 4, 'SHIPPING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.EditView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.EditView.Inline' and DATA_FIELD = N'BILLING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Invoices.EditView.Inline', null, 'Invoices.LBL_ACCOUNT', 'BILLING_ACCOUNT_ID', 1, 1, 'BILLING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.EditView.Mobile' and DATA_FIELD = N'BILLING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Invoices.EditView.Mobile', null, 'Invoices.LBL_ACCOUNT', 'BILLING_ACCOUNT_ID', 1, 3, 'BILLING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.EditView.Mobile' and DATA_FIELD = N'SHIPPING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Invoices.EditView.Mobile', null, 'Invoices.LBL_ACCOUNT', 'SHIPPING_ACCOUNT_ID', 0, 4, 'SHIPPING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.SearchAdvanced') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.SearchAdvanced' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Invoices.SearchAdvanced', null, 'Invoices.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.SearchBasic') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.SearchBasic' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Invoices.SearchBasic', null, 'Invoices.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.SearchBasic.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.SearchBasic.Gmail' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Invoices.SearchBasic.Gmail', null, 'Invoices.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.SearchPopup') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.SearchPopup' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Invoices.SearchPopup', null, 'Invoices.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.SearchPopup.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Invoices.SearchPopup.Gmail' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Invoices.SearchPopup.Gmail', null, 'Invoices.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView', null, 'Opportunities.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView.Gmail' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView.Gmail', null, 'Opportunities.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView.Inline' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView.Inline', null, 'Opportunities.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.EditView.Mobile' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.EditView.Mobile', null, 'Opportunities.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.NewRecord') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.NewRecord' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.NewRecord', null, 'Opportunities.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.PopupView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Opportunities.PopupView.Inline' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Opportunities.PopupView.Inline', null, 'Opportunities.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EditView' and DATA_FIELD = N'BILLING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Orders.EditView', null, 'Orders.LBL_ACCOUNT', 'BILLING_ACCOUNT_ID', 1, 3, 'BILLING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EditView' and DATA_FIELD = N'SHIPPING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Orders.EditView', null, 'Orders.LBL_ACCOUNT', 'SHIPPING_ACCOUNT_ID', 0, 4, 'SHIPPING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EditView.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EditView.Gmail' and DATA_FIELD = N'BILLING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Orders.EditView.Gmail', null, 'Orders.LBL_ACCOUNT', 'BILLING_ACCOUNT_ID', 1, 3, 'BILLING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EditView.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EditView.Gmail' and DATA_FIELD = N'SHIPPING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Orders.EditView.Gmail', null, 'Orders.LBL_ACCOUNT', 'SHIPPING_ACCOUNT_ID', 0, 4, 'SHIPPING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EditView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EditView.Inline' and DATA_FIELD = N'BILLING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Orders.EditView.Inline', null, 'Orders.LBL_ACCOUNT', 'BILLING_ACCOUNT_ID', 1, 1, 'BILLING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EditView.Mobile' and DATA_FIELD = N'BILLING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Orders.EditView.Mobile', null, 'Orders.LBL_ACCOUNT', 'BILLING_ACCOUNT_ID', 1, 3, 'BILLING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EditView.Mobile' and DATA_FIELD = N'SHIPPING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Orders.EditView.Mobile', null, 'Orders.LBL_ACCOUNT', 'SHIPPING_ACCOUNT_ID', 0, 4, 'SHIPPING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EntryView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.EntryView' and DATA_FIELD = N'BILLING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Orders.EntryView', null, 'Orders.LBL_ACCOUNT', 'BILLING_ACCOUNT_ID', 1, 3, 'BILLING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.SearchAdvanced') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.SearchAdvanced' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Orders.SearchAdvanced', null, 'Orders.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.SearchBasic') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.SearchBasic' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Orders.SearchBasic', null, 'Orders.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.SearchBasic.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Orders.SearchBasic.Gmail' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Orders.SearchBasic.Gmail', null, 'Orders.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Payments.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Payments.EditView' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Payments.EditView', null, 'Payments.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 2, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Payments.EditView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Payments.EditView.Inline' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Payments.EditView.Inline', null, 'Payments.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Payments.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Payments.EditView.Mobile' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Payments.EditView.Mobile', null, 'Payments.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 2, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Products.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Products.EditView' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Products.EditView', null, 'Contracts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Products.EditView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Products.EditView.Inline' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Products.EditView.Inline', null, 'Contracts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Products.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Products.EditView.Mobile' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Products.EditView.Mobile', null, 'Contracts.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.EditView' and DATA_FIELD = N'BILLING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Quotes.EditView', null, 'Quotes.LBL_ACCOUNT', 'BILLING_ACCOUNT_ID', 1, 3, 'BILLING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.EditView') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.EditView' and DATA_FIELD = N'SHIPPING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Quotes.EditView', null, 'Quotes.LBL_ACCOUNT', 'SHIPPING_ACCOUNT_ID', 0, 4, 'SHIPPING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.EditView.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.EditView.Gmail' and DATA_FIELD = N'BILLING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Quotes.EditView.Gmail', null, 'Quotes.LBL_ACCOUNT', 'BILLING_ACCOUNT_ID', 1, 3, 'BILLING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.EditView.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.EditView.Gmail' and DATA_FIELD = N'SHIPPING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Quotes.EditView.Gmail', null, 'Quotes.LBL_ACCOUNT', 'SHIPPING_ACCOUNT_ID', 0, 4, 'SHIPPING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.EditView.Inline') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.EditView.Inline' and DATA_FIELD = N'BILLING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Quotes.EditView.Inline', null, 'Quotes.LBL_ACCOUNT', 'BILLING_ACCOUNT_ID', 1, 1, 'BILLING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.EditView.Mobile' and DATA_FIELD = N'BILLING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Quotes.EditView.Mobile', null, 'Quotes.LBL_ACCOUNT', 'BILLING_ACCOUNT_ID', 1, 3, 'BILLING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.EditView.Mobile') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.EditView.Mobile' and DATA_FIELD = N'SHIPPING_ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Quotes.EditView.Mobile', null, 'Quotes.LBL_ACCOUNT', 'SHIPPING_ACCOUNT_ID', 0, 4, 'SHIPPING_ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.NewRecord') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.NewRecord' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Quotes.NewRecord', null, 'Quotes.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 1, 1, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.SearchBasic') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.SearchBasic' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Quotes.SearchBasic', null, 'Quotes.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
		if exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.SearchBasic.Gmail') begin -- then
			if not exists(select * from vwEDITVIEWS_FIELDS where EDIT_NAME = N'Quotes.SearchBasic.Gmail' and DATA_FIELD = N'ACCOUNT_ID') begin -- then
				exec dbo.spEDITVIEWS_FIELDS_InsModulePopup 'Quotes.SearchBasic.Gmail', null, 'Quotes.LBL_ACCOUNT_NAME', 'ACCOUNT_ID', 0, 0, 'ACCOUNT_NAME', 'Accounts', null;
			end -- if;
		end -- if;
/*
select 
'		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N''' + DETAIL_NAME + ''') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N''' + DETAIL_NAME + ''' and DATA_FIELD = N''' + DATA_FIELD + ''') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N''' + DETAIL_NAME + ''',  null, N''' + DATA_LABEL + ''', N''' + DATA_FIELD + ''', ''{0}'', N''' + URL_FIELD + ''', ''~/Accounts/view.aspx?ID={0}'', null, null;
			end -- if;
		end -- if;
'
  from DETAILVIEWS_FIELDS
 where DATA_FIELD like '%ACCOUNT_NAME'
   and DEFAULT_VIEW = 0
 order by DETAIL_NAME, DATA_FIELD
*/
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Cases.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Cases.DetailView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Cases.DetailView',  null, N'Cases.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Cases.DetailView.Gmail') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Cases.DetailView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Cases.DetailView.Gmail',  null, N'Cases.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Cases.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Cases.DetailView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Cases.DetailView.Mobile',  null, N'Cases.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contacts.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contacts.DetailView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Contacts.DetailView',  null, N'Contacts.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contacts.DetailView.Gmail') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contacts.DetailView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Contacts.DetailView.Gmail',  null, N'Contacts.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contacts.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contacts.DetailView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Contacts.DetailView.Mobile',  null, N'Contacts.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contracts.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contracts.DetailView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Contracts.DetailView',  null, N'Contracts.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contracts.DetailView.Gmail') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contracts.DetailView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Contracts.DetailView.Gmail',  null, N'Contracts.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contracts.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Contracts.DetailView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Contracts.DetailView.Mobile',  null, N'Contracts.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Invoices.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Invoices.DetailView' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Invoices.DetailView',  null, N'Invoices.LBL_BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '{0}', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Invoices.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Invoices.DetailView' and DATA_FIELD = N'SHIPPING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Invoices.DetailView',  null, N'Invoices.LBL_SHIPPING_ACCOUNT_NAME', N'SHIPPING_ACCOUNT_NAME', '{0}', N'SHIPPING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Invoices.DetailView.Gmail') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Invoices.DetailView.Gmail' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Invoices.DetailView.Gmail',  null, N'Invoices.LBL_BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '{0}', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Invoices.DetailView.Gmail') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Invoices.DetailView.Gmail' and DATA_FIELD = N'SHIPPING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Invoices.DetailView.Gmail',  null, N'Invoices.LBL_SHIPPING_ACCOUNT_NAME', N'SHIPPING_ACCOUNT_NAME', '{0}', N'SHIPPING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Invoices.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Invoices.DetailView.Mobile' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Invoices.DetailView.Mobile',  null, N'Invoices.LBL_BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '{0}', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Invoices.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Invoices.DetailView.Mobile' and DATA_FIELD = N'SHIPPING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Invoices.DetailView.Mobile',  null, N'Invoices.LBL_SHIPPING_ACCOUNT_NAME', N'SHIPPING_ACCOUNT_NAME', '{0}', N'SHIPPING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Leads.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Leads.DetailView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Leads.DetailView',  null, N'Leads.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Leads.DetailView.Gmail') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Leads.DetailView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Leads.DetailView.Gmail',  null, N'Leads.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Leads.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Leads.DetailView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Leads.DetailView.Mobile',  null, N'Leads.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Opportunities.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Opportunities.DetailView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Opportunities.DetailView',  null, N'Opportunities.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Opportunities.DetailView.Gmail') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Opportunities.DetailView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Opportunities.DetailView.Gmail',  null, N'Opportunities.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Opportunities.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Opportunities.DetailView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Opportunities.DetailView.Mobile',  null, N'Opportunities.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Orders.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Orders.DetailView' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Orders.DetailView',  null, N'Orders.LBL_BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '{0}', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Orders.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Orders.DetailView' and DATA_FIELD = N'SHIPPING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Orders.DetailView',  null, N'Orders.LBL_SHIPPING_ACCOUNT_NAME', N'SHIPPING_ACCOUNT_NAME', '{0}', N'SHIPPING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Orders.DetailView.Gmail') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Orders.DetailView.Gmail' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Orders.DetailView.Gmail',  null, N'Orders.LBL_BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '{0}', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Orders.DetailView.Gmail') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Orders.DetailView.Gmail' and DATA_FIELD = N'SHIPPING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Orders.DetailView.Gmail',  null, N'Orders.LBL_SHIPPING_ACCOUNT_NAME', N'SHIPPING_ACCOUNT_NAME', '{0}', N'SHIPPING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Orders.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Orders.DetailView.Mobile' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Orders.DetailView.Mobile',  null, N'Orders.LBL_BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '{0}', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Orders.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Orders.DetailView.Mobile' and DATA_FIELD = N'SHIPPING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Orders.DetailView.Mobile',  null, N'Orders.LBL_SHIPPING_ACCOUNT_NAME', N'SHIPPING_ACCOUNT_NAME', '{0}', N'SHIPPING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Payments.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Payments.DetailView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Payments.DetailView',  null, N'Payments.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Payments.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Payments.DetailView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Payments.DetailView.Mobile',  null, N'Payments.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Products.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Products.DetailView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Products.DetailView',  null, N'Products.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Products.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Products.DetailView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Products.DetailView.Mobile',  null, N'Products.LBL_ACCOUNT_NAME', N'ACCOUNT_NAME', '{0}', N'ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Quotes.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Quotes.DetailView' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Quotes.DetailView',  null, N'Quotes.LBL_BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '{0}', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Quotes.DetailView') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Quotes.DetailView' and DATA_FIELD = N'SHIPPING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Quotes.DetailView',  null, N'Quotes.LBL_SHIPPING_ACCOUNT_NAME', N'SHIPPING_ACCOUNT_NAME', '{0}', N'SHIPPING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Quotes.DetailView.Gmail') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Quotes.DetailView.Gmail' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Quotes.DetailView.Gmail',  null, N'Quotes.LBL_BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '{0}', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Quotes.DetailView.Gmail') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Quotes.DetailView.Gmail' and DATA_FIELD = N'SHIPPING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Quotes.DetailView.Gmail',  null, N'Quotes.LBL_SHIPPING_ACCOUNT_NAME', N'SHIPPING_ACCOUNT_NAME', '{0}', N'SHIPPING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Quotes.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Quotes.DetailView.Mobile' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Quotes.DetailView.Mobile',  null, N'Quotes.LBL_BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '{0}', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
		if exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Quotes.DetailView.Mobile') begin -- then
			if not exists(select * from vwDETAILVIEWS_FIELDS where DETAIL_NAME = N'Quotes.DetailView.Mobile' and DATA_FIELD = N'SHIPPING_ACCOUNT_NAME') begin -- then
				exec dbo.spDETAILVIEWS_FIELDS_InsHyperLink N'Quotes.DetailView.Mobile',  null, N'Quotes.LBL_SHIPPING_ACCOUNT_NAME', N'SHIPPING_ACCOUNT_NAME', '{0}', N'SHIPPING_ACCOUNT_ID', '~/Accounts/view.aspx?ID={0}', null, null;
			end -- if;
		end -- if;
/*
select (case when DATA_FORMAT = 'HyperLink' then 
'		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N''' + GRID_NAME + ''') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N''' + GRID_NAME + ''' and DATA_FIELD = N''' + DATA_FIELD + ''') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N''' + GRID_NAME + ''', null, N''' + HEADER_TEXT + ''', N''' + DATA_FIELD + ''', N''' + SORT_EXPRESSION + ''', ''20%'', ''listViewTdLinkS1'', N''' + URL_FIELD + ''', ''~/Accounts/view.aspx?id={0}'', null, ''Accounts'', N''' + URL_ASSIGNED_FIELD + ''';
			end -- if;
		end -- if;
'
       when DATA_FORMAT is null then
'		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N''' + GRID_NAME + ''') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N''' + GRID_NAME + ''' and DATA_FIELD = N''' + DATA_FIELD + ''') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N''' + GRID_NAME + ''', null, N''' + HEADER_TEXT + ''', N''' + DATA_FIELD + ''', N' + isnull('''' + SORT_EXPRESSION + '''', 'null') + ', ''25%'';
			end -- if;
		end -- if;
' end)--, GRID_NAME, COLUMN_TYPE, HEADER_TEXT, DATA_FIELD, SORT_EXPRESSION, DATA_FORMAT, URL_FIELD, URL_FORMAT, URL_MODULE, URL_ASSIGNED_FIELD
  from GRIDVIEWS_COLUMNS
 where DATA_FIELD like '%ACCOUNT_NAME'
   and DEFAULT_VIEW = 0
 order by GRID_NAME, DATA_FIELD
*/
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Activities.History') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Activities.History' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Accounts.Activities.History', null, N'Activities.LBL_LIST_RELATED_TO', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Activities.Open') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Activities.Open' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Accounts.Activities.Open', null, N'Activities.LBL_LIST_RELATED_TO', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Accounts.Cases', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Contacts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Contacts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Accounts.Contacts', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Contracts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Contracts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Accounts.Contracts', null, N'Contracts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Opportunities') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Opportunities' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Accounts.Opportunities', null, N'Opportunities.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Products') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Products' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Accounts.Products', null, N'Products.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Quotes') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Accounts.Quotes' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Accounts.Quotes', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Bugs.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Bugs.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Bugs.Cases', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Bugs.Contacts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Bugs.Contacts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Bugs.Contacts', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Calls.Contacts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Calls.Contacts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Calls.Contacts', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Calls.Leads') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Calls.Leads' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Calls.Leads', null, N'Leads.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Campaigns.Opportunities') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Campaigns.Opportunities' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Campaigns.Opportunities', null, N'Opportunities.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.Contacts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.Contacts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Cases.Contacts', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Cases.Export', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.ListView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.ListView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Cases.ListView', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.ListView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.ListView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Cases.ListView.Gmail', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.ListView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.ListView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Cases.ListView.Mobile', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.MyCases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.MyCases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Cases.MyCases', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.PopupView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.PopupView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Cases.PopupView', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.PopupView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.PopupView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Cases.PopupView.Gmail', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.PopupView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.PopupView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Cases.PopupView.Mobile', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.Search') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Cases.Search' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Cases.Search', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.CreditCards') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.CreditCards' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contacts.CreditCards', null, N'CreditCards.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.DirectReports') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.DirectReports' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contacts.DirectReports', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contacts.Export', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.ListView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.ListView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contacts.ListView', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.ListView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.ListView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contacts.ListView.Gmail', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.ListView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.ListView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contacts.ListView.Mobile', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.MyContacts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.MyContacts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contacts.MyContacts', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.PopupView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.PopupView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contacts.PopupView', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.PopupView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.PopupView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contacts.PopupView.Gmail', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.PopupView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.PopupView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contacts.PopupView.Mobile', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.Products') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.Products' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contacts.Products', null, N'Products.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.Quotes') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.Quotes' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contacts.Quotes', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.Search') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.Search' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contacts.Search', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.SearchPhones') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contacts.SearchPhones' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contacts.SearchPhones', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Contacts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Contacts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contracts.Contacts', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contracts.Export', null, N'Contracts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.ListView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.ListView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contracts.ListView', null, N'Contracts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.ListView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.ListView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contracts.ListView.Gmail', null, N'Contracts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.ListView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.ListView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contracts.ListView.Mobile', null, N'Contracts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.PopupView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.PopupView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contracts.PopupView', null, N'Contracts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.PopupView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.PopupView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contracts.PopupView.Gmail', null, N'Contracts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.PopupView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.PopupView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Contracts.PopupView.Mobile', null, N'Contracts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Products') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Products' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contracts.Products', null, N'Products.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Quotes') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Quotes' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contracts.Quotes', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Search') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Contracts.Search' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Contracts.Search', null, N'Contracts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Documents.Cases', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Contacts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Contacts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Documents.Contacts', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Contracts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Contracts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Documents.Contracts', null, N'Contracts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Opportunities') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Opportunities' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Documents.Opportunities', null, N'Opportunities.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Quotes') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Documents.Quotes' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Documents.Quotes', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Emails.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Emails.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Emails.Cases', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Emails.Contacts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Emails.Contacts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Emails.Contacts', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Emails.Opportunities') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Emails.Opportunities' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Emails.Opportunities', null, N'Opportunities.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Emails.Quotes') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Emails.Quotes' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Emails.Quotes', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Activities.History') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Activities.History' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Invoices.Activities.History', null, N'Activities.LBL_LIST_RELATED_TO', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Activities.Open') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Activities.Open' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Invoices.Activities.Open', null, N'Activities.LBL_LIST_RELATED_TO', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Invoices.Cases', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Invoices.Export', null, N'Invoices.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Export' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Invoices.Export', null, N'Invoices.LBL_LIST_BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Export' and DATA_FIELD = N'SHIPPING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Invoices.Export', null, N'Invoices.LBL_LIST_SHIPPING_ACCOUNT_NAME', N'SHIPPING_ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.ListView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.ListView' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Invoices.ListView', null, N'Invoices.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.ListView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.ListView.Gmail' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Invoices.ListView.Gmail', null, N'Invoices.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.ListView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.ListView.Mobile' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Invoices.ListView.Mobile', null, N'Invoices.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.MyInvoices') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.MyInvoices' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Invoices.MyInvoices', null, N'Invoices.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.PopupView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.PopupView' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Invoices.PopupView', null, N'Invoices.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.PopupView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.PopupView.Gmail' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Invoices.PopupView.Gmail', null, N'Invoices.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.PopupView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.PopupView.Mobile' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Invoices.PopupView.Mobile', null, N'Invoices.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Search') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Invoices.Search' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Invoices.Search', null, N'Invoices.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'KBDocuments.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'KBDocuments.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'KBDocuments.Cases', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Leads.Export', null, N'Leads.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.Export' and DATA_FIELD = N'CONVERTED_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Leads.Export', null, N'Leads.LBL_LIST_CONVERTED_ACCOUNT_NAME', N'CONVERTED_ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.ListView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.ListView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Leads.ListView', null, N'Leads.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.ListView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.ListView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Leads.ListView.Gmail', null, N'Leads.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.ListView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.ListView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Leads.ListView.Mobile', null, N'Leads.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.PopupView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.PopupView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Leads.PopupView', null, N'Leads.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.PopupView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.PopupView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Leads.PopupView.Gmail', null, N'Leads.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.PopupView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.PopupView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Leads.PopupView.Mobile', null, N'Leads.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.Search') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.Search' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Leads.Search', null, N'Leads.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.SearchPhones') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Leads.SearchPhones' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Leads.SearchPhones', null, N'Leads.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Meetings.Contacts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Meetings.Contacts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Meetings.Contacts', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Meetings.Leads') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Meetings.Leads' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Meetings.Leads', null, N'Leads.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Contracts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Contracts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Opportunities.Contracts', null, N'Contracts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Opportunities.Export', null, N'Opportunities.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.ListView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.ListView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Opportunities.ListView', null, N'Opportunities.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.ListView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.ListView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Opportunities.ListView.Gmail', null, N'Opportunities.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.ListView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.ListView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Opportunities.ListView.Mobile', null, N'Opportunities.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.MyOpportunities') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.MyOpportunities' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Opportunities.MyOpportunities', null, N'Opportunities.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.PopupView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.PopupView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Opportunities.PopupView', null, N'Opportunities.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.PopupView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.PopupView.Gmail' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Opportunities.PopupView.Gmail', null, N'Opportunities.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.PopupView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.PopupView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Opportunities.PopupView.Mobile', null, N'Opportunities.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Quotes') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Quotes' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Opportunities.Quotes', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Search') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Opportunities.Search' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Opportunities.Search', null, N'Opportunities.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Orders.Cases', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Orders.Export', null, N'Orders.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.Export' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Orders.Export', null, N'Orders.LBL_LIST_BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.Export' and DATA_FIELD = N'SHIPPING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Orders.Export', null, N'Orders.LBL_LIST_SHIPPING_ACCOUNT_NAME', N'SHIPPING_ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.ListView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.ListView' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Orders.ListView', null, N'Orders.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.ListView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.ListView.Gmail' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Orders.ListView.Gmail', null, N'Orders.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.ListView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.ListView.Mobile' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Orders.ListView.Mobile', null, N'Orders.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.MyOrders') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.MyOrders' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Orders.MyOrders', null, N'Orders.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.PopupView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.PopupView' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Orders.PopupView', null, N'Orders.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.PopupView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.PopupView.Gmail' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Orders.PopupView.Gmail', null, N'Orders.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.PopupView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.PopupView.Mobile' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Orders.PopupView.Mobile', null, N'Orders.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.Search') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Orders.Search' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Orders.Search', null, N'Orders.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'OrdersLineItems.Search') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'OrdersLineItems.Search' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'OrdersLineItems.Search', null, N'Orders.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Payments.Export', null, N'Payments.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.ListView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.ListView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Payments.ListView', null, N'Payments.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.ListView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.ListView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Payments.ListView.Mobile', null, N'Payments.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.PopupView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.PopupView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Payments.PopupView', null, N'Payments.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.PopupView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.PopupView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Payments.PopupView.Mobile', null, N'Payments.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.Search') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Payments.Search' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Payments.Search', null, N'Payments.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Products.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Products.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Products.Export', null, N'Products.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Products.ListView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Products.ListView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Products.ListView', null, N'Products.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Products.ListView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Products.ListView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Products.ListView.Mobile', null, N'Products.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Products.PopupView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Products.PopupView' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Products.PopupView', null, N'Products.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Products.PopupView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Products.PopupView.Mobile' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Products.PopupView.Mobile', null, N'Products.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Products.RelatedProducts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Products.RelatedProducts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Products.RelatedProducts', null, N'Products.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'ProductTemplates.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'ProductTemplates.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'ProductTemplates.Export', null, N'ProductTemplates.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Project.Contacts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Project.Contacts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Project.Contacts', null, N'Contacts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Project.Opportunities') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Project.Opportunities' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Project.Opportunities', null, N'Opportunities.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Project.Quotes') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Project.Quotes' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Project.Quotes', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Prospects.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Prospects.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Prospects.Export', null, N'Prospects.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Prospects.Search') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Prospects.Search' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Prospects.Search', null, N'Prospects.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Prospects.SearchPhones') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Prospects.SearchPhones' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Prospects.SearchPhones', null, N'Prospects.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Activities.History') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Activities.History' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Quotes.Activities.History', null, N'Activities.LBL_LIST_RELATED_TO', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Activities.Open') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Activities.Open' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Quotes.Activities.Open', null, N'Activities.LBL_LIST_RELATED_TO', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Cases') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Cases' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Quotes.Cases', null, N'Cases.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Contracts') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Contracts' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Quotes.Contracts', null, N'Contracts.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', N'ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'ACCOUNT_ASSIGNED_USER_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Export' and DATA_FIELD = N'ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Quotes.Export', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Export' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Quotes.Export', null, N'Quotes.LBL_LIST_BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Export') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Export' and DATA_FIELD = N'SHIPPING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Quotes.Export', null, N'Quotes.LBL_LIST_SHIPPING_ACCOUNT_NAME', N'SHIPPING_ACCOUNT_NAME', null, '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.ListView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.ListView' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Quotes.ListView', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.ListView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.ListView.Gmail' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Quotes.ListView.Gmail', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.ListView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.ListView.Mobile' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Quotes.ListView.Mobile', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.MyQuotes') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.MyQuotes' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Quotes.MyQuotes', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.PopupView') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.PopupView' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Quotes.PopupView', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.PopupView.Gmail') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.PopupView.Gmail' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Quotes.PopupView.Gmail', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.PopupView.Mobile') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.PopupView.Mobile' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsBound     N'Quotes.PopupView.Mobile', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '25%';
			end -- if;
		end -- if;
		if exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Search') begin -- then
			if not exists(select * from vwGRIDVIEWS_COLUMNS where GRID_NAME = N'Quotes.Search' and DATA_FIELD = N'BILLING_ACCOUNT_NAME') begin -- then
				exec dbo.spGRIDVIEWS_COLUMNS_InsHyperLink N'Quotes.Search', null, N'Quotes.LBL_LIST_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', N'BILLING_ACCOUNT_NAME', '20%', 'listViewTdLinkS1', N'BILLING_ACCOUNT_ID', '~/Accounts/view.aspx?id={0}', null, 'Accounts', N'BILLING_ACCOUNT_ASSIGNED_ID';
			end -- if;
		end -- if;
	end -- if;
  end
GO

Grant Execute on dbo.spCONFIG_BusinessMode to public;
GO

