/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// 1. React and fabric. 
import * as React from 'react';
// 2. Store and Types. 
// 3. Scripts. 
// 4. Components and Views. 
// 5. Dashlets
import AccountsDetailView        from './Accounts/DetailView'       ;
import AccountsEditView          from './Accounts/EditView'         ;
import ActivitiesDetailView      from './Activities/DetailView'     ;
import ActivitiesEditView        from './Activities/EditView'       ;
import BugsEditView              from './Bugs/EditView'             ;
import CallMarketingEditView     from './CallMarketing/EditView'    ;
import CallsDetailView           from './Calls/DetailView'          ;
import CallsEditView             from './Calls/EditView'            ;
import CallsEditViewInline       from './Calls/EditView.Inline'     ;
import CampaignsEditView         from './Campaigns/EditView'        ;
import CampaignsDetailView       from './Campaigns/DetailView'      ;
import CampaignsRoiDetailView    from './Campaigns/RoiDetailView'   ;
import CampaignsTrackDetailView  from './Campaigns/TrackDetailView' ;
// 02/16/2022 Paul.  Campaign subpanels were not being included. 
import CampaignsCallMarketing    from './Campaigns/CallMarketing'   ;
import CampaignsEmailMarketing   from './Campaigns/EmailMarketing'  ;
import CampaignsCampaignTrackers from './Campaigns/CampaignTrackers';
import CampaignTrackersEditView  from './CampaignTrackers/EditView' ;
import CasesEditView             from './Cases/EditView'            ;
import ChartsListView            from './Charts/ListView'           ;
import ChatChannelsChatMessages  from './ChatChannels/ChatMessages' ;
import ChatMessagesEditView      from './ChatMessages/EditView'     ;
import ContactsDetailView        from './Contacts/DetailView'       ;
import ContactsEditView          from './Contacts/EditView'         ;
import ContactsListView          from './Contacts/ListView'         ;
import CreditCardsEditView       from './CreditCards/EditView'      ;
// 11/18/2021 Paul.  CreditCards requires ACCOUNT_ID. 
import CreditCardsPopupView      from './CreditCards/PopupView'     ;
import DocumentsEditView         from './Documents/EditView'        ;
import DocumentsDocumentRevisions from './Documents/DocumentRevisions';
import DocumentRevisionsEditView  from './DocumentRevisions/EditView' ;
import EmailsDetailView          from './Emails/DetailView'         ;
import EmailsEditView            from './Emails/EditView'           ;
import EmailsListView            from './Emails/ListView'           ;
import EmailMarketingEditView    from './EmailMarketing/EditView'   ;
import EmailTemplatesDetailView  from './EmailTemplates/DetailView' ;
import EmailTemplatesEditView    from './EmailTemplates/EditView'   ;
import EmployeesDetailView       from './Employees/DetailView'      ;
import EmployeesEditView         from './Employees/EditView'        ;
import EmployeesListView         from './Employees/ListView'        ;
import InvoicesEditView          from './Invoices/EditView'         ;
import InvoicesPayments          from './Invoices/Payments'         ;
import KBDocumentsDetailView     from './KBDocuments/DetailView'    ;
import KBDocumentsEditView       from './KBDocuments/EditView'      ;
import LeadsDetailView           from './Leads/DetailView'          ;
import LeadsEditView             from './Leads/EditView'            ;
import LeadsListView             from './Leads/ListView'            ;
import MeetingsDetailView        from './Meetings/DetailView'       ;
import MeetingsEditView          from './Meetings/EditView'         ;
import MeetingsEditViewInline    from './Meetings/EditView.Inline'  ;
import NotesEditView             from './Notes/EditView'            ;
import OpportunitiesEditView     from './Opportunities/EditView'    ;
import OrdersEditView            from './Orders/EditView'           ;
import PaymentsEditView          from './Payments/EditView'         ;
import PaymentsDetailView        from './Payments/DetailView'       ;
import ProcessesListView         from './Processes/ListView'        ;
import ProcessesDetailView       from './Processes/DetailView'      ;
import ProductsEditView          from './Products/EditView'         ;
import ProjectTaskEditView       from './ProjectTask/EditView'      ;
import ProspectsDetailView       from './Prospects/DetailView'      ;
import ProspectsEditView         from './Prospects/EditView'        ;
import ProspectListsEditView     from './ProspectLists/EditView'    ;
import QuotesEditView            from './Quotes/EditView'           ;
import ReportsListView           from './Reports/ListView'          ;
import RulesWizardEditView       from './RulesWizard/EditView'      ;
import RulesWizardListView       from './RulesWizard/ListView'      ;
import ReportRulesEditView       from './ReportRules/EditView'      ;
import ReportRulesListView       from './ReportRules/ListView'      ;
import SmsMessagesDetailView     from './SmsMessages/DetailView'    ;
// 02/05/2023 Paul.  Add support for SMS Messages. 
import SmsMessagesEditView       from './SmsMessages/EditView'      ;
import SurveysDetailView         from './Surveys/DetailView'        ;
import SurveysResultsView        from './Surveys/ResultsView'       ;
import SurveysSummaryView        from './Surveys/SummaryView'       ;
import SurveysSurveyPages        from './Surveys/SurveyPages'       ;
import SurveyPagesEditView       from './SurveyPages/EditView'      ;
import SurveyPagesSurveyQuestions from './SurveyPages/SurveyQuestions';
import SurveyQuestionsDetailView from './SurveyQuestions/DetailView';
import SurveyQuestionsEditView   from './SurveyQuestions/EditView'  ;
import TasksEditView             from './Tasks/EditView'            ;
import ThreadsEditView           from './Threads/EditView'          ;
import UsersDetailView           from './Users/DetailView'          ;
import UsersEditView             from './Users/EditView'            ;
import UsersPopupView            from './Users/PopupView'           ;
import UsersLogins               from './Users/UsersLogins'         ;
import UsersACLRoles             from './Users/UsersACLRoles'       ;
import UsersTeams                from './Users/UsersTeams'          ;
import UsersSurveyResults        from './Users/UsersSurveyResults'  ;
import UsersUserSignatures       from './Users/UsersUserSignatures' ;
import UserSignaturesEditView    from './UserSignatures/EditView'   ;
import UserSignaturesListView    from './UserSignatures/ListView'   ;
// Administration 
import AdminConfigView           from '../views/AdminConfigView'                  ;
import AdminReadOnlyConfigView   from '../views/AdminReadOnlyConfigView'          ;
import AdminReadOnlyListView     from '../views/AdminReadOnlyListView'            ;
import DropdownListView          from './Administration/Dropdown/ListView'        ;
import DropdownEditView          from './Administration/Dropdown/EditView'        ;
import RegionsCountries          from './Administration/Regions/RegionsCountries' ;
import TeamsUsers                from './Administration/Teams/TeamsUsers'         ;
import TeamsHierarchy            from './Administration/Teams/TeamsHierarchy'     ;
import ACLRolesUsers             from './Administration/ACLRoles/ACLRolesUsers'   ;
import ACLRolesListView          from './Administration/ACLRoles/ListView'        ;
import ACLRolesEditView          from './Administration/ACLRoles/EditView'        ;
import ACLRolesDetailView        from './Administration/ACLRoles/DetailView'      ;
import ACLRolesFieldSecurity     from './Administration/ACLRoles/FieldSecurity'   ;
import ACLRolesByUser            from './Administration/ACLRoles/ByUser'          ;
import EditCustomFieldsListView  from './Administration/EditCustomFields/ListView';
import EditCustomFieldsEditView  from './Administration/EditCustomFields/EditView';
import DynamicButtonsListView    from './Administration/DynamicButtons/ListView'  ;
import FieldValidatorsListView   from './Administration/FieldValidators/ListView' ;
import LanguagesListView         from './Administration/Languages/ListView'       ;
import ModulesDetailView         from './Administration/Modules/DetailView'       ;
import ProductTemplatesEditView  from './Administration/ProductTemplates/EditView';
import PaymentGatewayListView    from './Administration/PaymentGateway/ListView'  ;
import CurrenciesListView        from './Administration/Currencies/ListView'      ;
import CurrenciesDetailView      from './Administration/Currencies/DetailView'    ;
import CurrenciesPopupView       from './Administration/Currencies/PopupView'     ;
import ConfigListView            from './Administration/Config/ListView'          ;
import ConfigEditView            from './Administration/Config/EditView'          ;
import OutboundEmailEditView     from './Administration/OutboundEmail/EditView'   ;
import OutboundEmailDetailView   from './Administration/OutboundEmail/DetailView' ;
import InboundEmailEditView      from './Administration/InboundEmail/EditView'    ;
import InboundEmailDetailView    from './Administration/InboundEmail/DetailView'  ;
import SchedulersDetailView      from './Administration/Schedulers/DetailView'    ;
import EmailManListView          from './Administration/EmailMan/ListView'        ;
import EmailManConfigView        from './Administration/EmailMan/ConfigView'      ;
import ExchangeListView          from './Administration/Exchange/ListView'        ;
import ExchangeDetailView        from './Administration/Exchange/DetailView'      ;
import DataPrivacyDetailView     from './Administration/DataPrivacy/DetailView'   ;
import DataPrivacySubPanelView   from './Administration/DataPrivacy/SubPanelView' ;
import BusinessRulesListView     from './Administration/BusinessRules/ListView'   ;
import BusinessRulesEditView     from './Administration/BusinessRules/EditView'   ;
import ModulesArchiveRulesEditView      from './Administration/ModulesArchiveRules/EditView'       ;
import ModulesArchiveRulesListView      from './Administration/ModulesArchiveRules/ListView'       ;
import TerminologyLanguagePacks         from './Administration/Terminology/LanguagePacks'          ;
import TerminologySplendidLanguagePacks from './Administration/Terminology/SplendidLanguagePacks'  ;
import UndeleteListView                 from './Administration/Undelete/ListView'                  ;
// Admin logs
import SystemLogListView                 from './Administration/SystemLog/ListView'                ;
import SystemSyncLogListView             from './Administration/SystemSyncLog/ListView'            ;
import WorkflowEventLogListView          from './Administration/WorkflowEventLog/ListView'         ;
import BusinessProcessesLogListView      from './Administration/BusinessProcessesLog/ListView'     ;
import UserLoginsListView                from './Administration/UserLogins/ListView'               ;
// Cloud services
import ExchangeConfigView                from './Administration/Exchange/ConfigView'               ;
import GoogleConfigView                  from './Administration/Google/ConfigView'                 ;
import AsteriskListView                  from './Administration/Asterisk/ListView'                 ;
import AsteriskDetailView                from './Administration/Asterisk/DetailView'               ;
import AvayaListView                     from './Administration/Avaya/ListView'                    ;
import AvayaDetailView                   from './Administration/Avaya/DetailView'                  ;
import CurrencyLayerSystemCurrencyLog    from './Administration/CurrencyLayer/SystemCurrencyLog'   ;
import QuickBooksConfigView              from './Administration/QuickBooks/ConfigView'             ;
import HubSpotConfigView                 from './Administration/HubSpot/ConfigView'                ;
import iContactConfigView                from './Administration/iContact/ConfigView'               ;
import ConstantContactConfigView         from './Administration/ConstantContact/ConfigView'        ;
import MarketoConfigView                 from './Administration/Marketo/ConfigView'                ;
import MailChimpConfigView               from './Administration/MailChimp/ConfigView'              ;
import WatsonConfigView                  from './Administration/Watson/ConfigView'                 ;
import PhoneBurnerConfigView             from './Administration/PhoneBurner/ConfigView'            ;
import AuthorizeNetListView              from './Administration/AuthorizeNet/ListView'             ;
import PayPalListView                    from './Administration/PayPal/ListView'                   ;
import PayPalDetailView                  from './Administration/PayPal/DetailView'                 ;
import PayTraceListView                  from './Administration/PayTrace/ListView'                 ;
import PayTraceDetailView                from './Administration/PayTrace/DetailView'               ;
// 12/26/2022 Paul.  Add support for Microsoft Teams. 
import MicrosoftTeamsConfigView          from './Administration/MicrosoftTeams/ConfigView'         ;
// Workflow
import WorkflowAlertTemplatesDetailView  from './Administration/WorkflowAlertTemplates/DetailView' ;
import WorkflowAlertTemplatesEditView    from './Administration/WorkflowAlertTemplates/EditView'   ;
import WorkflowsConditions               from './Administration/Workflows/Conditions'              ;
import WorkflowsActions                  from './Administration/Workflows/Actions'                 ;
import WorkflowsAlerts                   from './Administration/Workflows/Alerts'                  ;
import WorkflowsEvents                   from './Administration/Workflows/Events'                  ;
import WorkflowsListView                 from './Administration/Workflows/ListView'                ;
import WorkflowsEditView                 from './Administration/Workflows/EditView'                ;
import WorkflowsDetailView               from './Administration/Workflows/DetailView'              ;
import WorkflowActionShellsEditView      from './Administration/WorkflowActionShells/EditView'     ;
import WorkflowAlertShellsEditView       from './Administration/WorkflowAlertShells/EditView'      ;
import WorkflowsSequenceView             from './Administration/Workflows/SequenceView'            ;
import MachineLearningModelsDetailView   from './Administration/MachineLearningModels/DetailView'  ;
import BusinessProcessesEditView         from './Administration/BusinessProcesses/EditView'        ;
import BusinessProcessesDetailView       from './Administration/BusinessProcesses/DetailView'      ;
import BusinessProcessesListView         from './Administration/BusinessProcesses/ListView'        ;
// Azure
import AzureSystemLogListView            from './Administration/Azure/AzureSystemLog/ListView'     ;
import AzureOrdersListView               from './Administration/Azure/AzureOrders/ListView'        ;
import AzureOrdersDetailView             from './Administration/Azure/AzureOrders/DetailView'      ;
import AzureOrdersChangeLog              from './Administration/Azure/AzureOrders/ChangeLog'       ;
import AzureOrdersAppUpdates             from './Administration/Azure/AzureOrders/AzureAppUpdates' ;
import AzureSqlPricesListView            from './Administration/Azure/AzureSqlPrices/ListView'     ;
import AzureSqlPricesEditView            from './Administration/Azure/AzureSqlPrices/EditView'     ;
import AzureSqlPricesSearchBasic         from './Administration/Azure/AzureSqlPrices/SearchBasic'  ;
import AzureVmPricesListView             from './Administration/Azure/AzureVmPrices/ListView'      ;
import AzureVmPricesEditView             from './Administration/Azure/AzureVmPrices/EditView'      ;
import AzureVmPricesSearchBasic          from './Administration/Azure/AzureVmPrices/SearchBasic'   ;
import AzureAppUpdatesAzureOrders        from './Administration/Azure/AzureAppUpdates/AzureOrders' ;
import AzureAppUpdatesFiles              from './Administration/Azure/AzureAppUpdates/Files'       ;
import AzureAppUpdatesEditView           from './Administration/Azure/AzureAppUpdates/EditView'    ;
import AzureServiceLevelsAzureAppPrices  from './Administration/Azure/AzureServiceLevels/AzureAppPrices';
import AzureServiceLevelsEditView        from './Administration/Azure/AzureServiceLevels/EditView'      ;
import AzureAppPricesAzureServiceLevels  from './Administration/Azure/AzureAppPrices/AzureServiceLevels';
import AzureAppPricesAzureOrders         from './Administration/Azure/AzureAppPrices/AzureOrders'       ;
import AzureAppPricesFiles               from './Administration/Azure/AzureAppPrices/Files'             ;
import AzureAppPricesEditView            from './Administration/Azure/AzureAppPrices/EditView'          ;
import DnsNamesListView                  from './Administration/Azure/DnsNames/ListView'                ;
import DnsNamesEditView                  from './Administration/Azure/DnsNames/EditView'                ;
import DnsNamesDetailView                from './Administration/Azure/DnsNames/DetailView'              ;
import ResourceGroupsListView            from './Administration/Azure/ResourceGroups/ListView'          ;
import ResourceGroupsEditView            from './Administration/Azure/ResourceGroups/EditView'          ;
import ResourceGroupsDetailView          from './Administration/Azure/ResourceGroups/DetailView'        ;
import SqlDatabasesListView              from './Administration/Azure/SqlDatabases/ListView'            ;
import SqlServersListView                from './Administration/Azure/SqlServers/ListView'              ;
import StorageAccountsListView           from './Administration/Azure/StorageAccounts/ListView'         ;
import StorageAccountsEditView           from './Administration/Azure/StorageAccounts/EditView'         ;
import StorageAccountsDetailView         from './Administration/Azure/StorageAccounts/DetailView'       ;
import StorageAccountsFiles              from './Administration/Azure/StorageAccounts/Files'            ;
import VirtualMachinesListView           from './Administration/Azure/VirtualMachines/ListView'         ;
import AzureServicesView                 from './Administration/Azure/ServicesView'                     ;
import AzureVirtualMachines              from './Administration/Azure/VirtualMachines/VirtualMachines'  ;
import AzureSqlDatabases                 from './Administration/Azure/SqlDatabases/SqlDatabases'        ;
import AzureDnsNames                     from './Administration/Azure/DnsNames/DnsNames'                ;
import AzureResourceGroups               from './Administration/Azure/ResourceGroups/ResourceGroups'    ;
import AzureStorageAccounts              from './Administration/Azure/StorageAccounts/StorageAccounts'  ;
import CloudServicesListView             from './Administration/Azure/CloudServices/ListView'           ;
import AzureCloudServices                from './Administration/Azure/CloudServices/CloudServices'      ;

export default function ModuleViewFactory(sLAYOUT_NAME: string)
{
	let view = null;
	switch ( sLAYOUT_NAME )
	{
		case 'Accounts.DetailView'       :  view = AccountsDetailView       ;  break;
		case 'Accounts.EditView'         :  view = AccountsEditView         ;  break;
		case 'Activities.DetailView'     :  view = ActivitiesDetailView     ;  break;
		case 'Activities.EditView'       :  view = ActivitiesEditView       ;  break;
		case 'Bugs.EditView'             :  view = BugsEditView             ;  break;
		case 'CallMarketing.EditView'    :  view = CallMarketingEditView    ;  break;
		case 'Calls.DetailView'          :  view = CallsDetailView          ;  break;
		case 'Calls.EditView'            :  view = CallsEditView            ;  break;
		case 'Calls.EditView.Inline'     :  view = CallsEditViewInline      ;  break;
		case 'Campaigns.EditView'        :  view = CampaignsEditView        ;  break;
		case 'Campaigns.DetailView'      :  view = CampaignsDetailView      ;  break;
		case 'Campaigns.RoiDetailView'   :  view = CampaignsRoiDetailView   ;  break;
		case 'Campaigns.TrackDetailView' :  view = CampaignsTrackDetailView ;  break;
		// 02/16/2022 Paul.  Campaign subpanels were not being included. 
		case 'Campaigns.CallMarketing'   :  view = CampaignsCallMarketing   ;  break;
		case 'Campaigns.EmailMarketing'  :  view = CampaignsEmailMarketing  ;  break;
		case 'Campaigns.CampaignTrackers':  view = CampaignsCampaignTrackers;  break;
		case 'CampaignTrackers.EditView' :  view = CampaignTrackersEditView ;  break;
		case 'Cases.EditView'            :  view = CasesEditView            ;  break;
		case 'Charts.ListView'           :  view = ChartsListView           ;  break;
		case 'ChatChannels.ChatMessages' :  view = ChatChannelsChatMessages ;  break;
		case 'ChatMessages.EditView'     :  view = ChatMessagesEditView     ;  break;
		case 'Contacts.DetailView'       :  view = ContactsDetailView       ;  break;
		case 'Contacts.EditView'         :  view = ContactsEditView         ;  break;
		case 'Contacts.ListView'         :  view = ContactsListView         ;  break;
		case 'CreditCards.EditView'      :  view = CreditCardsEditView      ;  break;
		// 11/18/2021 Paul.  CreditCards requires ACCOUNT_ID. 
		case 'CreditCards.PopupView'     :  view = CreditCardsPopupView     ;  break;
		case 'Documents.EditView'        :  view = DocumentsEditView        ;  break;
		// 11/21/2021 Paul.  Need to customize the revisions layout to handle document download. 
		case 'Documents.DocumentRevisions': view = DocumentsDocumentRevisions; break;
		case 'DocumentRevisions.EditView' : view = DocumentRevisionsEditView ; break;
		case 'Emails.DetailView'         :  view = EmailsDetailView         ;  break;
		case 'Emails.EditView'           :  view = EmailsEditView           ;  break;
		case 'Emails.ListView'           :  view = EmailsListView           ;  break;
		// 04/18/2022 Paul.  Add missing EmailMarketingEditView custom view, otherwise CAMPAIGN_ID does not get saved with the record. 
		case 'EmailMarketing.EditView'   :  view = EmailMarketingEditView   ;  break;
		case 'EmailTemplates.DetailView' :  view = EmailTemplatesDetailView ;  break;
		case 'EmailTemplates.EditView'   :  view = EmailTemplatesEditView   ;  break;
		case 'Employees.DetailView'      :  view = EmployeesDetailView      ;  break;
		case 'Employees.EditView'        :  view = EmployeesEditView        ;  break;
		case 'Employees.ListView'        :  view = EmployeesListView        ;  break;
		case 'Invoices.EditView'         :  view = InvoicesEditView         ;  break;
		// 05/06/2022 Paul.  Inline editing is not enabled for Invoice Payments. 
		case 'Invoices.Payments'         :  view = InvoicesPayments         ;  break;
		case 'KBDocuments.DetailView'    :  view = KBDocumentsDetailView    ;  break;
		case 'KBDocuments.EditView'      :  view = KBDocumentsEditView      ;  break;
		case 'Leads.DetailView'          :  view = LeadsDetailView          ;  break;
		case 'Leads.EditView'            :  view = LeadsEditView            ;  break;
		case 'Leads.ListView'            :  view = LeadsListView            ;  break;
		case 'Meetings.DetailView'       :  view = MeetingsDetailView       ;  break;
		case 'Meetings.EditView'         :  view = MeetingsEditView         ;  break;
		case 'Meetings.EditView.Inline'  :  view = MeetingsEditViewInline   ;  break;
		case 'Notes.EditView'            :  view = NotesEditView            ;  break;
		case 'Opportunities.EditView'    :  view = OpportunitiesEditView    ;  break;
		case 'Orders.EditView'           :  view = OrdersEditView           ;  break;
		case 'Payments.DetailView'       :  view = PaymentsDetailView       ;  break;
		case 'Payments.EditView'         :  view = PaymentsEditView         ;  break;
		// 11/18/2021 Paul.  Payments.EditView.Inline requires same custom logic as main EditView. 
		case 'Payments.EditView.Inline'  :  view = PaymentsEditView         ;  break;
		case 'Processes.ListView'        :  view = ProcessesListView        ;  break;
		case 'Processes.DetailView'      :  view = ProcessesDetailView      ;  break;
		case 'Products.EditView'         :  view = ProductsEditView         ;  break;
		case 'ProjectTask.EditView'      :  view = ProjectTaskEditView      ;  break;
		case 'Prospects.DetailView'      :  view = ProspectsDetailView      ;  break;
		case 'Prospects.EditView'        :  view = ProspectsEditView        ;  break;
		case 'ProspectLists.EditView'    :  view = ProspectListsEditView    ;  break;
		case 'Quotes.EditView'           :  view = QuotesEditView           ;  break;
		case 'Reports.ListView'          :  view = ReportsListView          ;  break;
		case 'ReportDesigner.ListView'   :  view = ReportsListView          ;  break;
		case 'RulesWizard.EditView'      :  view = RulesWizardEditView      ;  break;
		case 'RulesWizard.ListView'      :  view = RulesWizardListView      ;  break;
		case 'ReportRules.EditView'      :  view = ReportRulesEditView      ;  break;
		case 'ReportRules.ListView'      :  view = ReportRulesListView      ;  break;
		// 02/05/2023 Paul.  Add support for SMS Messages. 
		case 'SmsMessages.DetailView'    :  view = SmsMessagesDetailView    ;  break;
		case 'SmsMessages.EditView'      :  view = SmsMessagesEditView      ;  break;
		case 'SurveyQuestions.DetailView':  view = SurveyQuestionsDetailView;  break;
		case 'SurveyQuestions.EditView'  :  view = SurveyQuestionsEditView  ;  break;
		case 'Surveys.DetailView'        :  view = SurveysDetailView        ;  break;
		case 'Surveys.ResultsView'       :  view = SurveysResultsView       ;  break;
		case 'Surveys.SummaryView'       :  view = SurveysSummaryView       ;  break;
		case 'Surveys.SurveyPages'       :  view = SurveysSurveyPages       ;  break;
		case 'SurveyPages.EditView'      :  view = SurveyPagesEditView      ;  break;
		case 'SurveyPages.SurveyQuestions':  view = SurveyPagesSurveyQuestions;  break;
		case 'Tasks.EditView'            :  view = TasksEditView            ;  break;
		case 'Threads.EditView'          :  view = ThreadsEditView          ;  break;
		case 'Users.DetailView'          :  view = UsersDetailView          ;  break;
		case 'Users.EditView'            :  view = UsersEditView            ;  break;
		case 'Users.PopupView'           :  view = UsersPopupView           ;  break;
		case 'Users.Logins'              :  view = UsersLogins              ;  break;
		case 'Users.ACLRoles'            :  view = UsersACLRoles            ;  break;
		case 'Users.Teams'               :  view = UsersTeams               ;  break;
		case 'Users.SurveyResults'       :  view = UsersSurveyResults       ;  break;
		case 'Users.UserSignatures'      :  view = UsersUserSignatures      ;  break;
		case 'UserSignatures.EditView'   :  view = UserSignaturesEditView   ;  break;
		case 'UserSignatures.ListView'   :  view = UserSignaturesListView   ;  break;
		// Administration 
		case 'Dropdown.ListView'                :  view = DropdownListView         ;  break;
		case 'Dropdown.EditView'                :  view = DropdownEditView         ;  break;
		case 'Regions.Countries'                :  view = RegionsCountries         ;  break;
		case 'Teams.Hierarchy'                  :  view = TeamsHierarchy           ;  break;
		case 'Teams.Users'                      :  view = TeamsUsers               ;  break;
		case 'ACLRoles.Users'                   :  view = ACLRolesUsers            ;  break;
		case 'ACLRoles.ListView'                :  view = ACLRolesListView         ;  break;
		case 'ACLRoles.EditView'                :  view = ACLRolesEditView         ;  break;
		case 'ACLRoles.DetailView'              :  view = ACLRolesDetailView       ;  break;
		case 'ACLRoles.FieldSecurity'           :  view = ACLRolesFieldSecurity    ;  break;
		case 'ACLRoles.ByUser'                  :  view = ACLRolesByUser           ;  break;
		case 'EditCustomFields.ListView'        :  view = EditCustomFieldsListView ;  break;
		case 'EditCustomFields.EditView'        :  view = EditCustomFieldsEditView ;  break;
		case 'DynamicButtons.ListView'          :  view = DynamicButtonsListView   ;  break;
		case 'FieldValidators.ListView'         :  view = FieldValidatorsListView  ;  break;
		case 'Languages.ListView'               :  view = LanguagesListView        ;  break;
		case 'Modules.DetailView'               :  view = ModulesDetailView        ;  break;
		case 'ProductTemplates.EditView'        :  view = ProductTemplatesEditView ;  break;
		case 'PaymentGateway.ListView'          :  view = PaymentGatewayListView   ;  break;
		case 'Currencies.ListView'              :  view = CurrenciesListView       ;  break;
		case 'Currencies.DetailView'            :  view = CurrenciesDetailView     ;  break;
		case 'Currencies.PopupView'             :  view = CurrenciesPopupView      ;  break;
		case 'Config.ListView'                  :  view = ConfigListView           ;  break;
		case 'Config.EditView'                  :  view = ConfigEditView           ;  break;
		case 'OutboundEmail.EditView'           :  view = OutboundEmailEditView    ;  break;
		case 'OutboundEmail.DetailView'         :  view = OutboundEmailDetailView  ;  break;
		case 'InboundEmail.EditView'            :  view = InboundEmailEditView     ;  break;
		case 'InboundEmail.DetailView'          :  view = InboundEmailDetailView   ;  break;
		case 'Schedulers.DetailView'            :  view = SchedulersDetailView     ;  break;
		case 'EmailMan.ListView'                :  view = EmailManListView         ;  break;
		case 'Exchange.ListView'                :  view = ExchangeListView         ;  break;
		case 'Exchange.DetailView'              :  view = ExchangeDetailView       ;  break;
		case 'DataPrivacy.DetailView'           :  view = DataPrivacyDetailView    ;  break;
		case 'DataPrivacy.Contacts'             :  view = DataPrivacySubPanelView  ;  break;
		case 'DataPrivacy.Leads'                :  view = DataPrivacySubPanelView  ;  break;
		case 'DataPrivacy.Prospects'            :  view = DataPrivacySubPanelView  ;  break;
		case 'DataPrivacy.Accounts'             :  view = DataPrivacySubPanelView  ;  break;
		case 'DataPrivacy.ContactsArchived'     :  view = DataPrivacySubPanelView  ;  break;
		case 'DataPrivacy.LeadsArchived'        :  view = DataPrivacySubPanelView  ;  break;
		case 'DataPrivacy.ProspectsArchived'    :  view = DataPrivacySubPanelView  ;  break;
		case 'DataPrivacy.AccountsArchived'     :  view = DataPrivacySubPanelView  ;  break;
		case 'BusinessRules.ListView'           :  view = BusinessRulesListView    ;  break;
		case 'BusinessRules.EditView'           :  view = BusinessRulesEditView    ;  break;
		case 'ModulesArchiveRules.EditView'     :  view = ModulesArchiveRulesEditView     ;  break;
		case 'ModulesArchiveRules.ListView'     :  view = ModulesArchiveRulesListView     ;  break;
		case 'Terminology.LanguagePacks'        :  view = TerminologyLanguagePacks        ;  break;
		case 'Terminology.SplendidLanguagePacks':  view = TerminologySplendidLanguagePacks;  break;
		case 'Undelete.ListView'                :  view = UndeleteListView                ;  break;
		// Admin Logs
		case 'SystemLog.ListView'               :  view = SystemLogListView               ;  break;
		case 'SystemSyncLog.ListView'           :  view = SystemSyncLogListView           ;  break;
		case 'UserLogins.ListView'              :  view = UserLoginsListView              ;  break;
		case 'AuditEvents.ListView'             :  view = AdminReadOnlyListView           ;  break;
		case 'WorkflowEventLog.ListView'        :  view = WorkflowEventLogListView        ;  break;
		case 'BusinessProcessesLog.ListView'    :  view = BusinessProcessesLogListView    ;  break;
		// Admin Config
		case 'EmailMan.ConfigView'              :  view = EmailManConfigView              ;  break;
		case 'Exchange.ConfigView'              :  view = ExchangeConfigView              ;  break;
		case 'Google.ConfigView'                :  view = GoogleConfigView                ;  break;
		case 'Facebook.ConfigView'              :  view = AdminConfigView                 ;  break;
		case 'LinkedIn.ConfigView'              :  view = AdminConfigView                 ;  break;
		case 'Salesforce.ConfigView'            :  view = AdminConfigView                 ;  break;
		case 'Twitter.ConfigView'               :  view = AdminConfigView                 ;  break;
		// Cloud services
		case 'Asterisk.ConfigView'              :  view = AdminConfigView                 ;  break;
		case 'Asterisk.ListView'                :  view = AsteriskListView                ;  break;
		case 'Asterisk.DetailView'              :  view = AsteriskDetailView              ;  break;
		case 'Avaya.ConfigView'                 :  view = AdminConfigView                 ;  break;
		case 'Avaya.ListView'                   :  view = AvayaListView                   ;  break;
		case 'Avaya.DetailView'                 :  view = AvayaDetailView                 ;  break;
		case 'CurrencyLayer.ConfigView'         :  view = AdminConfigView                 ;  break;
		case 'CurrencyLayer.DetailView'         :  view = AdminReadOnlyConfigView         ;  break;
		case 'CurrencyLayer.SystemCurrencyLog'  :  view = CurrencyLayerSystemCurrencyLog  ;  break;
		case 'Currencies.SystemCurrencyLog'     :  view = CurrencyLayerSystemCurrencyLog  ;  break;
		case 'Twilio.ConfigView'                :  view = AdminConfigView                 ;  break;
		case 'Twilio.ListView'                  :  view = AdminReadOnlyListView           ;  break;
		case 'GetResponse.ConfigView'           :  view = AdminConfigView                 ;  break;
		case 'GetResponse.DetailView'           :  view = AdminReadOnlyListView           ;  break;
		case 'Pardot.ConfigView'                :  view = AdminConfigView                 ;  break;
		case 'Pardot.DetailView'                :  view = AdminReadOnlyListView           ;  break;
		case 'Watson.ConfigView'                :  view = WatsonConfigView                ;  break;
		case 'Watson.DetailView'                :  view = AdminReadOnlyListView           ;  break;
		case 'QuickBooks.ConfigView'            :  view = QuickBooksConfigView            ;  break;
		case 'QuickBooks.DetailView'            :  view = AdminReadOnlyListView           ;  break;
		case 'HubSpot.ConfigView'               :  view = HubSpotConfigView               ;  break;
		case 'HubSpot.DetailView'               :  view = AdminReadOnlyListView           ;  break;
		case 'iContact.ConfigView'              :  view = iContactConfigView              ;  break;
		case 'iContact.DetailView'              :  view = AdminReadOnlyListView           ;  break;
		case 'ConstantContact.ConfigView'       :  view = ConstantContactConfigView       ;  break;
		case 'ConstantContact.DetailView'       :  view = AdminReadOnlyListView           ;  break;
		case 'Marketo.ConfigView'               :  view = MarketoConfigView               ;  break;
		case 'Marketo.DetailView'               :  view = AdminReadOnlyListView           ;  break;
		case 'MailChimp.ConfigView'             :  view = MailChimpConfigView             ;  break;
		case 'MailChimp.DetailView'             :  view = AdminReadOnlyListView           ;  break;
		case 'PhoneBurner.ConfigView'           :  view = PhoneBurnerConfigView           ;  break;
		case 'PhoneBurner.DetailView'           :  view = AdminReadOnlyListView           ;  break;
		case 'AuthorizeNet.ConfigView'          :  view = AdminConfigView                 ;  break;
		case 'AuthorizeNet.ListView'            :  view = AuthorizeNetListView            ;  break;
		case 'PayPal.ConfigView'                :  view = AdminConfigView                 ;  break;
		case 'PayPal.DetailView'                :  view = PayPalDetailView                ;  break;
		case 'PayPal.ListView'                  :  view = PayPalListView                  ;  break;
		case 'PayTrace.ConfigView'              :  view = AdminConfigView                 ;  break;
		case 'PayTrace.DetailView'              :  view = PayTraceDetailView              ;  break;
		case 'PayTrace.ListView'                :  view = PayTraceListView                ;  break;
		// 12/26/2022 Paul.  Add support for Microsoft Teams. 
		case 'MicrosoftTeams.ConfigView'        :  view = MicrosoftTeamsConfigView        ;  break;
		case 'MicrosoftTeams.DetailView'        :  view = AdminReadOnlyListView           ;  break;
		// Workflow
		case 'WorkflowAlertTemplates.DetailView':  view = WorkflowAlertTemplatesDetailView;  break;
		case 'WorkflowAlertTemplates.EditView'  :  view = WorkflowAlertTemplatesEditView  ;  break;
		case 'Workflows.Conditions'             :  view = WorkflowsConditions             ;  break;
		case 'Workflows.Actions'                :  view = WorkflowsActions                ;  break;
		case 'Workflows.Alerts'                 :  view = WorkflowsAlerts                 ;  break;
		case 'Workflows.Events'                 :  view = WorkflowsEvents                 ;  break;
		case 'Workflows.ListView'               :  view = WorkflowsListView               ;  break;
		case 'Workflows.EditView'               :  view = WorkflowsEditView               ;  break;
		case 'Workflows.DetailView'             :  view = WorkflowsDetailView             ;  break;
		case 'WorkflowActionShells.EditView'    :  view = WorkflowActionShellsEditView    ;  break;
		case 'WorkflowAlertShells.EditView'     :  view = WorkflowAlertShellsEditView     ;  break;
		case 'Workflows.SequenceView'           :  view = WorkflowsSequenceView           ;  break;
		case 'MachineLearningModels.DetailView' :  view = MachineLearningModelsDetailView ;  break;
		case 'BusinessProcesses.EditView'       :  view = BusinessProcessesEditView       ;  break;
		case 'BusinessProcesses.DetailView'     :  view = BusinessProcessesDetailView     ;  break;
		case 'BusinessProcesses.ListView'       :  view = BusinessProcessesListView       ;  break;
		// Azure
		case 'AzureSystemLog.ListView'          :  view = AzureSystemLogListView          ;  break;
		case 'AzureOrders.ListView'             :  view = AzureOrdersListView             ;  break;
		case 'AzureOrders.DetailView'           :  view = AzureOrdersDetailView           ;  break;
		case 'AzureOrders.ChangeLog'            :  view = AzureOrdersChangeLog            ;  break;
		case 'AzureOrders.AzureAppUpdates'      :  view = AzureOrdersAppUpdates           ;  break;
		case 'AzureSqlPrices.ListView'          :  view = AzureSqlPricesListView          ;  break;
		case 'AzureSqlPrices.EditView'          :  view = AzureSqlPricesEditView          ;  break;
		case 'AzureSqlPrices.SearchBasic'       :  view = AzureSqlPricesSearchBasic       ;  break;
		case 'AzureVmPrices.ListView'           :  view = AzureVmPricesListView           ;  break;
		case 'AzureVmPrices.EditView'           :  view = AzureVmPricesEditView           ;  break;
		case 'AzureVmPrices.SearchBasic'        :  view = AzureVmPricesSearchBasic        ;  break;
		case 'AzureAppUpdates.AzureOrders'      :  view = AzureAppUpdatesAzureOrders      ;  break;
		case 'AzureAppUpdates.Files'            :  view = AzureAppUpdatesFiles            ;  break;
		case 'AzureAppUpdates.EditView'         :  view = AzureAppUpdatesEditView         ;  break;
		case 'AzureServiceLevels.AzureAppPrices':  view = AzureServiceLevelsAzureAppPrices;  break;
		case 'AzureServiceLevels.EditView'      :  view = AzureServiceLevelsEditView      ;  break;
		case 'AzureAppPrices.AzureServiceLevels':  view = AzureAppPricesAzureServiceLevels;  break;
		case 'AzureAppPrices.AzureOrders'       :  view = AzureAppPricesAzureOrders       ;  break;
		case 'AzureAppPrices.Files'             :  view = AzureAppPricesFiles             ;  break;
		case 'AzureAppPrices.EditView'          :  view = AzureAppPricesEditView          ;  break;
		case 'DnsNames.ListView'                :  view = DnsNamesListView                ;  break;
		case 'DnsNames.EditView'                :  view = DnsNamesEditView                ;  break;
		case 'DnsNames.DetailView'              :  view = DnsNamesDetailView              ;  break;
		case 'ResourceGroups.ListView'          :  view = ResourceGroupsListView          ;  break;
		case 'ResourceGroups.EditView'          :  view = ResourceGroupsEditView          ;  break;
		case 'ResourceGroups.DetailView'        :  view = ResourceGroupsDetailView        ;  break;
		case 'SqlDatabases.ListView'            :  view = SqlDatabasesListView            ;  break;
		case 'SqlServers.ListView'              :  view = SqlServersListView              ;  break;
		case 'StorageAccounts.ListView'         :  view = StorageAccountsListView         ;  break;
		case 'StorageAccounts.EditView'         :  view = StorageAccountsEditView         ;  break;
		case 'StorageAccounts.DetailView'       :  view = StorageAccountsDetailView       ;  break;
		case 'StorageAccounts.Files'            :  view = StorageAccountsFiles            ;  break;
		case 'VirtualMachines.ListView'         :  view = VirtualMachinesListView         ;  break;
		case 'Azure.~/Administration/Azure/AzureServicesView'              :  view = AzureServicesView    ;  break;
		case 'Azure.~/Administration/Azure/VirtualMachines/VirtualMachines':  view = AzureVirtualMachines ;  break;
		case 'Azure.~/Administration/Azure/SqlDatabases/SqlDatabases'      :  view = AzureSqlDatabases    ;  break;
		case 'Azure.~/Administration/Azure/DnsNames/DnsNames'              :  view = AzureDnsNames        ;  break;
		case 'Azure.~/Administration/Azure/ResourceGroups/ResourceGroups'  :  view = AzureResourceGroups  ;  break;
		case 'Azure.~/Administration/Azure/StorageAccounts/StorageAccounts':  view = AzureStorageAccounts ;  break;
		// 04/26/2022 Paul.  Add support for CloudServices module. 
		case 'Azure.~/Administration/Azure/CloudServices/CloudServices'    :  view = AzureCloudServices   ;  break;
		case 'CloudServices.ListView'           :  view = CloudServicesListView           ;  break;
	}
	if ( view )
	{
		//console.log((new Date()).toISOString() + ' ' + 'ModuleViewFactory found ' + sLAYOUT_NAME);
	}
	else
	{
		//console.log((new Date()).toISOString() + ' ' + 'ModuleViewFactory NOT found ' + sLAYOUT_NAME);
	}
	return view;
}
