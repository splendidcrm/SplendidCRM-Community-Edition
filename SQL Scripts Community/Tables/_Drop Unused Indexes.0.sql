-- 09/15/2009 Paul.  Use new syntax to drop an index. 
-- Deprecated feature 'DROP INDEX with two-part name' is not supported in this version of SQL Server.
-- 'Multi-part names with Server or Database specifier' is not supported in this version of SQL Server.
if exists (select * from sys.indexes where name = 'IDX_ACCOUNTS_OPPORTUNITIES_OPPORTUNITY_ID_ACCOUNT_ID') begin -- then
	print 'drop index IDX_ACCOUNTS_OPPORTUNITIES_OPPORTUNITY_ID_ACCOUNT_ID';
	drop index IDX_ACCOUNTS_OPPORTUNITIES_OPPORTUNITY_ID_ACCOUNT_ID on ACCOUNTS_OPPORTUNITIES;
end -- if;
GO

if exists (select * from sys.indexes where name = 'IDX_CONTRACT_TYPES_DOCUMENTS_DOCUMENT_ID_TYPE_ID') begin -- then
	print 'drop index IDX_CONTRACT_TYPES_DOCUMENTS_DOCUMENT_ID_TYPE_ID';
	drop index IDX_CONTRACT_TYPES_DOCUMENTS_DOCUMENT_ID_TYPE_ID on CONTRACT_TYPES_DOCUMENTS;
end -- if;
GO

if exists (select * from sys.indexes where name = 'IDX_CONTRACTS_OPPORTUNITIES_OPPORTUNITY_ID_CONTRACT_ID') begin -- then
	print 'drop index IDX_CONTRACTS_OPPORTUNITIES_OPPORTUNITY_ID_CONTRACT_ID';
	drop index IDX_CONTRACTS_OPPORTUNITIES_OPPORTUNITY_ID_CONTRACT_ID on CONTRACTS_OPPORTUNITIES;
end -- if;
GO

if exists (select * from sys.indexes where name = 'IDX_EMAIL_MARKETING_PROSPECT_LISTS_RELATED') begin -- then
	print 'drop index IDX_EMAIL_MARKETING_PROSPECT_LISTS_RELATED';
	drop index IDX_EMAIL_MARKETING_PROSPECT_LISTS_RELATED on EMAIL_MARKETING_PROSPECT_LISTS;
end -- if;
GO

if exists (select * from sys.indexes where name = 'IDX_PROSPECT_LISTS_PROSPECTS_RELATED') begin -- then
	print 'drop index IDX_PROSPECT_LISTS_PROSPECTS_RELATED';
	drop index IDX_PROSPECT_LISTS_PROSPECTS_RELATED on PROSPECT_LISTS_PROSPECTS;
end -- if;
GO

if exists (select * from sys.indexes where name = 'IDX_ROLES_MODULES_ROLE_ID_MODULE_ID') begin -- then
	print 'drop index IDX_ROLES_MODULES_ROLE_ID_MODULE_ID';
	drop index IDX_ROLES_MODULES_ROLE_ID_MODULE_ID on ROLES_MODULES;
end -- if;
GO

if exists (select * from sys.indexes where name = 'IDX_TEAM_MEMBERSHIPS_USER') begin -- then
	print 'drop index IDX_TEAM_MEMBERSHIPS_USER';
	drop index IDX_TEAM_MEMBERSHIPS_USER on TEAM_MEMBERSHIPS;
end -- if;
GO

