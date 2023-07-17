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
import { Route, Switch, Redirect }     from 'react-router-dom'                                                     ;
// 4. Components and Views. 
import PrivateRoute                   from './PrivateRoute'                                                        ;
import App                            from './App'                                                                 ;
import CalendarView                   from './views/CalendarView'                                                  ;
import BigCalendarView                from './views/BigCalendarView'                                               ;
import ChatDashboardView              from './views/ChatDashboardView'                                             ;
import DashboardView                  from './views/DashboardView'                                                 ;
import DashboardEditView              from './views/DashboardEditView'                                             ;
import HomeDashboardEditView          from './views/HomeDashboardEditView'                                         ;
import DynamicDetailView              from './views/DynamicDetailView'                                             ;
import DynamicEditView                from './views/DynamicEditView'                                               ;
import DynamicListView                from './views/DynamicListView'                                               ;
import DynamicLayoutView              from './views/DynamicLayoutView'                                             ;
import AdministrationView             from './views/AdministrationView'                                            ;
import AdminDynamicDetailView         from './views/DynamicAdminDetailView'                                        ;
import AdminDynamicEditView           from './views/DynamicAdminEditView'                                          ;
import AdminDynamicListView           from './views/DynamicAdminListView'                                          ;
import AdminReadOnlyListView          from './views/AdminReadOnlyListView'                                         ;
import AdminReadOnlyConfigView        from './views/AdminReadOnlyConfigView'                                       ;
import AdminConfigView                from './views/AdminConfigView'                                               ;
// 12/07/2022 Paul.  Allow the LoginView to be customized. 
import DynamicLoginView               from './views/DynamicLoginView'                                              ;
import HomeView                       from './views/HomeView'                                                      ;
import RootView                       from './views/RootView'                                                      ;
import ResetView                      from './views/ResetView'                                                     ;
import ReloadView                     from './views/ReloadView'                                                    ;
import UnifiedSearch                  from './views/UnifiedSearch'                                                 ;
import ImportView                     from './views/ImportView'                                                    ;
import StreamView                     from './views/StreamView'                                                    ;
import PlaceholderView                from './views/PlaceholderView'                                               ;
import ReportView                     from './views/ReportView'                                                    ;
import ParentsView                    from './views/ParentsView'                                                   ;
import ReportEditView                 from './ReportDesigner/EditView'                                             ;
import ReportImportView               from './ModuleViews/Reports/ImportView'                                      ;
import ReportSignatureView            from './views/ReportSignatureView'                                           ;
import ReportAttachmentView           from './views/ReportAttachmentView'                                          ;
// 09/04/2022 Paul.  A customer wants to change MailMerge, so make it dynamic. 
//import MailMergeView                  from './views/MailMergeView'                                                 ;
import DynamicMailMerge               from './views/DynamicMailMerge'                                              ;
// 10/05/2022 Paul.  Add support for MassMerge. 
import MergeView                      from './views/MergeView'                                                     ;

import ChartEditView                  from './ModuleViews/Charts/EditView'                                         ;
import ChartImportView                from './ModuleViews/Charts/ImportView'                                       ;
import ChartDetailView                from './ModuleViews/Charts/DetailView'                                       ;

import AboutView                      from './ModuleViews/Home/AboutView'                                          ;
import TrainingPortal                 from './ModuleViews/Home/TrainingPortal'                                     ;
import MyAccountView                  from './ModuleViews/Users/MyAccountView'                                     ;
import MyAccountEdit                  from './ModuleViews/Users/MyAccountEdit'                                     ;
import UserWizard                     from './ModuleViews/Users/Wizard'                                            ;

import Precompile                     from './ModuleViews/Administration/_devtools/Precompile'                     ;
import AdminPasswordManager           from './ModuleViews/Administration/PasswordManager/ConfigView'               ;
import AdminBusinessMode              from './ModuleViews/Administration/BusinessMode/AdminBusinessMode'           ;
import ExchangeConfigView             from './ModuleViews/Administration/Exchange/ConfigView'                      ;
import AdminCampaignEditView          from './ModuleViews/Administration/CampaignEmailSettings/ConfigView'         ;
import EmailManConfigView             from './ModuleViews/Administration/EmailMan/ConfigView'                      ;
import ACLRolesFieldSecurity          from './ModuleViews/Administration/ACLRoles/FieldSecurity'                   ;
import ACLRolesByUser                 from './ModuleViews/Administration/ACLRoles/ByUser'                          ;
import AdminRenameTabs                from './ModuleViews/Administration/RenameTabs/ListView'                      ;
import AdminConfigureTabs             from './ModuleViews/Administration/ConfigureTabs/ListView'                   ;
import GoogleConfigView               from './ModuleViews/Administration/Google/ConfigView'                        ;
import SystemLogListView              from './ModuleViews/Administration/SystemLog/ListView'                       ;
import SystemSyncLogListView          from './ModuleViews/Administration/SystemSyncLog/ListView'                   ;
import WorkflowEventLogListView       from './ModuleViews/Administration/WorkflowEventLog/ListView'                ;
import WorkflowsSequenceView          from './ModuleViews/Administration/Workflows/SequenceView'                   ;
import BusinessProcessesLogListView   from './ModuleViews/Administration/BusinessProcessesLog/ListView'            ;
import UserLoginsListView             from './ModuleViews/Administration/UserLogins/ListView'                      ;
import UsersReassignView              from './ModuleViews/Administration/Users/ReassignView'                       ;
import ConfiguratorAdminWizard        from './ModuleViews/Administration/Configurator/AdminWizard'                 ;

import QuickBooksConfigView           from './ModuleViews/Administration/QuickBooks/ConfigView'                    ;
import HubSpotConfigView              from './ModuleViews/Administration/HubSpot/ConfigView'                       ;
import iContactConfigView             from './ModuleViews/Administration/iContact/ConfigView'                      ;
import ConstantContactConfigView      from './ModuleViews/Administration/ConstantContact/ConfigView'               ;
import MarketoConfigView              from './ModuleViews/Administration/Marketo/ConfigView'                       ;
import MailChimpConfigView            from './ModuleViews/Administration/MailChimp/ConfigView'                     ;
import WatsonConfigView               from './ModuleViews/Administration/Watson/ConfigView'                        ;
import PhoneBurnerConfigView          from './ModuleViews/Administration/PhoneBurner/ConfigView'                   ;
import AsteriskListView               from './ModuleViews/Administration/Asterisk/ListView'                        ;
import AsteriskDetailView             from './ModuleViews/Administration/Asterisk/DetailView'                      ;
import AvayaListView                  from './ModuleViews/Administration/Avaya/ListView'                           ;
import AvayaDetailView                from './ModuleViews/Administration/Avaya/DetailView'                         ;
import AuthorizeNetListView           from './ModuleViews/Administration/AuthorizeNet/ListView'                    ;
import AuthorizeNetCustomerListView   from './ModuleViews/Administration/AuthorizeNet/CustomerProfiles/ListView'   ;
import AuthorizeNetCustomerDetailView from './ModuleViews/Administration/AuthorizeNet/CustomerProfiles/DetailView' ;
import PayPalListView                 from './ModuleViews/Administration/PayPal/ListView'                          ;
import PayPalDetailView               from './ModuleViews/Administration/PayPal/DetailView'                        ;
import PayTraceListView               from './ModuleViews/Administration/PayTrace/ListView'                        ;
import PayTraceDetailView             from './ModuleViews/Administration/PayTrace/DetailView'                      ;
// 12/26/2022 Paul.  Add support for Microsoft Teams. 
import MicrosoftTeamsConfigView       from './ModuleViews/Administration/MicrosoftTeams/ConfigView'                ;

import AdminDynamicLayout             from './DynamicLayoutComponents/DynamicLayoutEditor'                         ;
import GoogleOAuth                    from './views/GoogleOAuth'                                                   ;
import Office365OAuth                 from './views/Office365OAuth'                                                ;
import AzureDetailView                from './ModuleViews/Administration/Azure/AzureDetailView'                    ;
import AzureConfigView                from './ModuleViews/Administration/Azure/AzureConfigView'                    ;
import FullTextSearchConfigView       from './ModuleViews/Administration/FullTextSearch/ConfigView'                ;
import BackupsConfigView              from './ModuleViews/Administration/Backups/ConfigView'                       ;
import UpdaterConfigView              from './ModuleViews/Administration/Updater/ConfigView'                       ;
import TerminologyImportView          from './ModuleViews/Administration/Terminology/ImportView'                   ;
import DatabaseImportView             from './ModuleViews/Administration/Import/ImportView'                        ;
import ModuleBuilderWizardView        from './ModuleBuilder/WizardView'                                            ;

// 02/15/2020 Paul.  To debug the router, use DebugRouter in index.tsx. 
export const routes = (
	<App>
		<Switch>
			<Route        exact path="/login"                                                    component={DynamicLoginView} />
			<Redirect     exact from="/Campaigns/roi/:ID"                                        to="/Campaigns/RoiDetailView/:ID"   />
			<Redirect     exact from="/Campaigns/track/:ID"                                      to="/Campaigns/TrackDetailView/:ID" />
			<Redirect     exact from="/Surveys/results/:ID"                                      to="/Surveys/ResultsView/:ID" />
			<Redirect     exact from="/Surveys/summary/:ID"                                      to="/Surveys/SummaryView/:ID" />
v			<Redirect     exact from="/Emails/Drafts"                                            to="/Emails/List?Type=draft" />
			<Redirect     exact from="/Projects/*"                                               to="/Project/*" />
			<Redirect     exact from="/ProjectTasks/*"                                           to="/ProjectTask/*" />
			<Redirect     exact from="/ReportDesigner/*"                                         to="/Reports/*" />
			<Redirect     exact from="/RulesWizard/View/*"                                       to="/RulesWizard/Edit/*" />
			<Redirect     exact from="/Administration/Users/EditMyAccount"                       to="/Users/EditMyAccount" />
			<Redirect     exact from="/Administration/iFrames/*"                                 to="/iFrames/*" />
			<Redirect     exact from="/Reports/ReportRules/*"                                    to="/ReportRules/*" />
			<Redirect     exact from="/ReportRules/View/*"                                       to="/ReportRules/Edit/*" />
			<Redirect     exact from="/Administration/ModulesArchiveRules/View/*"                to="/Administration/ModulesArchiveRules/Edit/*" />
			<Redirect     exact from="/Administration/BusinessRules/View/*"                      to="/Administration/BusinessRules/Edit/*" />
			<Redirect           from="/Users/Reassign"                                           to="/Administration/Users/Reassign" />

			<PrivateRoute       path="/Administration/_devtools/Precompile"                      component={Precompile} />

			<PrivateRoute exact path="/GoogleOAuth"                                              component={GoogleOAuth} />
			<PrivateRoute exact path="/Office365OAuth"                                           component={Office365OAuth} />
			<PrivateRoute exact path="/Home/About"                                               component={AboutView} />
			<PrivateRoute exact path="/Home/TrainingPortal"                                      component={TrainingPortal} />
			<PrivateRoute exact path="/Home/DashboardEdit/:ID"                                   component={HomeDashboardEditView} />
			<PrivateRoute exact path="/Home/DashboardEdit"                                       component={HomeDashboardEditView} />
			<PrivateRoute exact path="/Home/:ID"                                                 component={HomeView} />
			<PrivateRoute exact path="/Home"                                                     component={HomeView} />
			<PrivateRoute exact path="/Reset/*"                                                  component={ResetView } />
			<PrivateRoute exact path="/Reload"                                                   component={ReloadView} />
			<PrivateRoute exact path="/Reload/*"                                                 component={ReloadView} />
			<PrivateRoute exact path="/BigCalendar"                                              component={BigCalendarView} />
			<PrivateRoute       path="/Calendar"                                                 component={CalendarView} />
			<PrivateRoute exact path="/Dashboard/DashboardEdit/:ID"                              component={DashboardEditView} />
			<PrivateRoute exact path="/Dashboard/DashboardEdit"                                  component={DashboardEditView} />
			<PrivateRoute exact path="/Dashboard/:ID"                                            component={DashboardView} />
			<PrivateRoute exact path="/Dashboard"                                                component={DashboardView} />
			<PrivateRoute exact path="/UnifiedSearch/:search"                                    component={UnifiedSearch} />
			<PrivateRoute exact path="/UnifiedSearch"                                            component={UnifiedSearch} />

			<PrivateRoute exact path="/ChatDashboard/:ID"                                        component={ChatDashboardView} />
			<PrivateRoute exact path="/ChatDashboard"                                            component={ChatDashboardView} />
			<PrivateRoute exact path="/Reports/Edit/:ID"                                         component={ReportEditView} />
			<PrivateRoute exact path="/Reports/Edit"                                             component={ReportEditView} />
			<PrivateRoute exact path="/Reports/Import"                                           component={ReportImportView} />
			<PrivateRoute exact path="/Reports/View/:ID"                                         component={ReportView} />
			<PrivateRoute exact path="/Reports/View/:ID/*"                                       component={ReportView} />
			<PrivateRoute exact path="/Reports/Attachment/:ID/:PARENT_NAME/:PARENT_ID/*"         component={ReportAttachmentView} />
			<PrivateRoute exact path="/Reports/Attachment/:ID"                                   component={ReportAttachmentView} />
			<PrivateRoute exact path="/Reports/Signature/:ID/:PARENT_NAME/:PARENT_ID/*"          component={ReportSignatureView} />
			<PrivateRoute exact path="/Reports/Signature/:ID"                                    component={ReportSignatureView} />

			<PrivateRoute exact path="/Charts/Edit/:ID"                                         component={ChartEditView} />
			<PrivateRoute exact path="/Charts/Edit"                                             component={ChartEditView} />
			<PrivateRoute exact path="/Charts/Import"                                           component={ChartImportView} />
			<PrivateRoute exact path="/Charts/View/:ID"                                         component={ChartDetailView} />
			<PrivateRoute exact path="/Charts/View/:ID/*"                                       component={ChartDetailView} />

			<PrivateRoute exact path="/Users/MyAccount"                                          component={MyAccountView} />
			<PrivateRoute exact path="/Users/EditMyAccount"                                      component={MyAccountEdit} />
			<PrivateRoute exact path="/Users/Wizard"                                             component={UserWizard} />
			<PrivateRoute exact path="/Feeds/MyFeeds"                                            component={PlaceholderView} />
			<PrivateRoute exact path="/MailMerge/:MODULE_NAME/:ID"                               component={DynamicMailMerge} />
			<PrivateRoute exact path="/MailMerge/:MODULE_NAME"                                   component={DynamicMailMerge} />
			<PrivateRoute exact path="/MailMerge"                                                component={DynamicMailMerge} />
			<PrivateRoute exact path="/Merge/:MODULE_NAME/:ID"                                   component={MergeView} />
			<PrivateRoute exact path="/MassMerge/:MODULE_NAME/:ID"                               component={MergeView} />

			<PrivateRoute exact path="/Administration/EmailMan/AdminCampaignEditView"            component={AdminCampaignEditView} />
			<PrivateRoute exact path="/Administration/EmailMan/ConfigView"                       component={EmailManConfigView} />
			<PrivateRoute       path="/Administration/Users/Reassign"                            component={UsersReassignView} />
			<PrivateRoute       path="/Administration/Config/PasswordManager"                    component={AdminPasswordManager} />
			<PrivateRoute       path="/Administration/Config/BusinessMode"                       component={AdminBusinessMode} />
			<PrivateRoute       path="/Administration/Config/BackupDatabase"                     component={BackupsConfigView} />
			<PrivateRoute       path="/Administration/Config/Updater"                            component={UpdaterConfigView} />
			<PrivateRoute       path="/Administration/Terminology/TerminologyImport"             component={TerminologyImportView} />
			<PrivateRoute       path="/Administration/Import/ImportDatabase"                     component={DatabaseImportView} />
			<PrivateRoute exact path="/Administration/Exchange/ConfigView"                       component={ExchangeConfigView} />
			<PrivateRoute exact path="/Administration/Google/ConfigView"                         component={GoogleConfigView} />
			<PrivateRoute       path="/Administration/Google"                                    component={GoogleConfigView} />
			<PrivateRoute       path="/Administration/ModuleBuilder"                             component={ModuleBuilderWizardView} />

			<PrivateRoute       path="/Administration/Configurator"                              component={ConfiguratorAdminWizard} />
			<PrivateRoute       path="/Administration/Facebook"                                  component={AdminConfigView} />
			<PrivateRoute       path="/Administration/LinkedIn"                                  component={AdminConfigView} />
			<PrivateRoute       path="/Administration/Salesforce"                                component={AdminConfigView} />
			<PrivateRoute       path="/Administration/Twitter"                                   component={AdminConfigView} />
			<PrivateRoute exact path="/Administration/QuickBooks/ConfigView"                     component={QuickBooksConfigView} />
			<PrivateRoute       path="/Administration/QuickBooks"                                component={AdminReadOnlyConfigView} />
			<PrivateRoute exact path="/Administration/Twilio/ConfigView"                         component={AdminConfigView} />
			<PrivateRoute       path="/Administration/Twilio"                                    component={AdminReadOnlyListView} />
			<PrivateRoute exact path="/Administration/HubSpot/ConfigView"                        component={HubSpotConfigView} />
			<PrivateRoute       path="/Administration/HubSpot"                                   component={AdminReadOnlyConfigView} />
			<PrivateRoute exact path="/Administration/iContact/ConfigView"                       component={iContactConfigView} />
			<PrivateRoute       path="/Administration/iContact"                                  component={AdminReadOnlyConfigView} />
			<PrivateRoute exact path="/Administration/ConstantContact/ConfigView"                component={ConstantContactConfigView} />
			<PrivateRoute       path="/Administration/ConstantContact"                           component={AdminReadOnlyConfigView} />
			<PrivateRoute exact path="/Administration/Marketo/ConfigView"                        component={MarketoConfigView} />
			<PrivateRoute       path="/Administration/Marketo"                                   component={AdminReadOnlyConfigView} />
			<PrivateRoute exact path="/Administration/MailChimp/ConfigView"                      component={MailChimpConfigView} />
			<PrivateRoute       path="/Administration/MailChimp"                                 component={AdminReadOnlyConfigView} />
			<PrivateRoute exact path="/Administration/CurrencyLayer/ConfigView"                  component={AdminConfigView} />
			<PrivateRoute       path="/Administration/CurrencyLayer"                             component={AdminReadOnlyConfigView} />
			<PrivateRoute exact path="/Administration/GetResponse/ConfigView"                    component={AdminConfigView} />
			<PrivateRoute       path="/Administration/GetResponse"                               component={AdminReadOnlyConfigView} />
			<PrivateRoute exact path="/Administration/Pardot/ConfigView"                         component={AdminConfigView} />
			<PrivateRoute       path="/Administration/Pardot"                                    component={AdminReadOnlyConfigView} />
			<PrivateRoute exact path="/Administration/Watson/ConfigView"                         component={WatsonConfigView} />
			<PrivateRoute       path="/Administration/Watson"                                    component={AdminReadOnlyConfigView} />
			<PrivateRoute exact path="/Administration/PhoneBurner/ConfigView"                    component={PhoneBurnerConfigView} />
			<PrivateRoute       path="/Administration/PhoneBurner"                               component={AdminReadOnlyConfigView} />
			<PrivateRoute exact path="/Administration/MicrosoftTeams/ConfigView"                 component={MicrosoftTeamsConfigView} />
			<PrivateRoute       path="/Administration/MicrosoftTeams"                            component={AdminReadOnlyConfigView} />

			<PrivateRoute exact path="/Administration/DynamicLayout/AdminDynamicLayout"          component={AdminDynamicLayout} />
			<PrivateRoute exact path="/Administration/Terminology/RenameTabs"                    component={AdminRenameTabs} />
			<PrivateRoute exact path="/Administration/Modules/ConfigureTabs"                     component={AdminConfigureTabs} />

			<PrivateRoute       path="/Administration/FullTextSearch"                            component={FullTextSearchConfigView} />
			<PrivateRoute       path="/Administration/SystemLog"                                 component={SystemLogListView} />
			<PrivateRoute       path="/Administration/SystemSyncLog"                             component={SystemSyncLogListView} />
			<PrivateRoute       path="/Administration/UserLogins"                                component={UserLoginsListView} />
			<PrivateRoute       path="/Administration/AuditEvents"                               component={AdminReadOnlyListView} />
			<PrivateRoute       path="/Administration/WorkflowEventLog"                          component={WorkflowEventLogListView} />
			<PrivateRoute       path="/Administration/BusinessProcessesLog"                      component={BusinessProcessesLogListView} />

			<PrivateRoute exact path="/Administration/AuthorizeNet/ConfigView"                   component={AdminConfigView} />
			<PrivateRoute exact path="/Administration/AuthorizeNet/CustomerProfiles/View/:ID"    component={AuthorizeNetCustomerDetailView} />
			<PrivateRoute       path="/Administration/AuthorizeNet/CustomerProfiles"             component={AuthorizeNetCustomerListView} />
			<PrivateRoute       path="/Administration/AuthorizeNet"                              component={AuthorizeNetListView} />
			<PrivateRoute exact path="/Administration/PayPal/ConfigView"                         component={AdminConfigView} />
			<PrivateRoute exact path="/Administration/PayPalTransactions/View/:ID"               component={PayPalDetailView} />
			<PrivateRoute exact path="/Administration/PayPal/View/:ID"                           component={PayPalDetailView} />
			<PrivateRoute       path="/Administration/PayPalTransactions"                        component={PayPalListView} />
			<PrivateRoute       path="/Administration/PayPal/List"                               component={PayPalListView} />
			<PrivateRoute       path="/Administration/PayPal"                                    component={PayPalListView} />
			<PrivateRoute exact path="/Administration/PayTrace/ConfigView"                       component={AdminConfigView} />
			<PrivateRoute exact path="/Administration/PayTrace/View/:ID"                         component={PayTraceDetailView} />
			<PrivateRoute       path="/Administration/PayTrace"                                  component={PayTraceListView} />
			<PrivateRoute exact path="/Administration/Asterisk/ConfigView"                       component={AdminConfigView} />
			<PrivateRoute exact path="/Administration/Asterisk/View/:ID"                         component={AsteriskDetailView} />
			<PrivateRoute       path="/Administration/Asterisk"                                  component={AsteriskListView} />
			<PrivateRoute exact path="/Administration/Avaya/ConfigView"                          component={AdminConfigView} />
			<PrivateRoute exact path="/Administration/Avaya/View/:ID"                            component={AvayaDetailView} />
			<PrivateRoute       path="/Administration/Avaya"                                     component={AvayaListView} />

			<PrivateRoute exact path="/Administration/Azure/:MODULE_NAME/ConfigView"             component={AdminConfigView} />
			<PrivateRoute exact path="/Administration/Azure/:MODULE_NAME/ReadOnlyListView"       component={AdminReadOnlyListView} />
			<PrivateRoute exact path="/Administration/Azure/:MODULE_NAME/DetailView"             component={AdminReadOnlyConfigView} />
			<PrivateRoute exact path="/Administration/Azure/:MODULE_NAME/List"                   component={AdminDynamicListView} />
			<PrivateRoute exact path="/Administration/Azure/:MODULE_NAME/View/:ID"               component={AdminDynamicDetailView} />
			<PrivateRoute exact path="/Administration/Azure/:MODULE_NAME/Duplicate/:DuplicateID" component={AdminDynamicEditView} />
			<PrivateRoute exact path="/Administration/Azure/:MODULE_NAME/Edit/:ID"               component={AdminDynamicEditView} />
			<PrivateRoute exact path="/Administration/Azure/:MODULE_NAME/Edit"                   component={AdminDynamicEditView} />
			<PrivateRoute exact path="/Administration/Azure/ConfigView"                          component={AzureConfigView} />
			<PrivateRoute       path="/Administration/Azure/"                                    component={AzureDetailView} />
			
			<PrivateRoute exact path="/Administration/ACLRoles/Edit/:ID/FieldSecurity"           component={ACLRolesFieldSecurity} />
			<PrivateRoute exact path="/Administration/ACLRoles/ByUser"                           component={ACLRolesByUser} />
			<PrivateRoute exact path="/Administration/:MODULE_NAME/ReadOnlyListView"             component={AdminReadOnlyListView} />
			<PrivateRoute exact path="/Administration/:MODULE_NAME/DetailView"                   component={AdminReadOnlyConfigView} />
			<PrivateRoute exact path="/Administration/:MODULE_NAME/ConfigView"                   component={AdminConfigView} />
			<PrivateRoute exact path="/Administration/:MODULE_NAME/Config"                       component={AdminConfigView} />
			<PrivateRoute exact path="/Administration/:MODULE_NAME/List"                         component={AdminDynamicListView} />
			<PrivateRoute exact path="/Administration/:MODULE_NAME/View/:ID"                     component={AdminDynamicDetailView} />
			<PrivateRoute exact path="/Administration/:MODULE_NAME/Duplicate/:DuplicateID"       component={AdminDynamicEditView} />
			<PrivateRoute exact path="/Administration/:MODULE_NAME/Edit/:ID"                     component={AdminDynamicEditView} />
			<PrivateRoute exact path="/Administration/:MODULE_NAME/Edit"                         component={AdminDynamicEditView} />
			<PrivateRoute exact path="/Administration/:MODULE_NAME/Import"                       component={ImportView} />
			<PrivateRoute exact path="/Administration/Workflows/Sequence"                        component={WorkflowsSequenceView} />
			<PrivateRoute exact path="/Administration/SimpleEmail/Statistics"                    component={PlaceholderView} />
			<PrivateRoute exact path="/Administration/QuickBooks/:MODULE_NAME"                   component={PlaceholderView} />
			<PrivateRoute exact path="/Administration/MailChimp/:MODULE_NAME/Edit/:ID"           component={PlaceholderView} />

			<PrivateRoute exact path="/Administration/:MODULE_NAME/"                             component={AdminDynamicListView} />
			<PrivateRoute exact path="/Administration"                                           component={AdministrationView} />

			<PrivateRoute exact path="/Parents/View/:ID"                                         component={ParentsView} />
			<PrivateRoute exact path="/:MODULE_NAME/List"                                        component={DynamicListView} />
			<PrivateRoute exact path="/:MODULE_NAME/View/:ID"                                    component={DynamicDetailView} />
			<PrivateRoute exact path="/:MODULE_NAME/ArchiveView/:ID"                             component={DynamicDetailView} />
			<PrivateRoute exact path="/:MODULE_NAME/ArchiveView"                                 component={DynamicListView} />
			<PrivateRoute exact path="/:MODULE_NAME/Duplicate/:DuplicateID"                      component={DynamicEditView} />
			<PrivateRoute exact path="/:MODULE_NAME/Convert/:ConvertModule/:ConvertID"           component={DynamicEditView} />
			<PrivateRoute exact path="/:MODULE_NAME/Edit/:ID"                                    component={DynamicEditView} />
			<PrivateRoute exact path="/:MODULE_NAME/Edit"                                        component={DynamicEditView} />
			<PrivateRoute exact path="/:MODULE_NAME/Import"                                      component={ImportView} />
			<PrivateRoute exact path="/:MODULE_NAME/Stream"                                      component={StreamView} />

			<PrivateRoute exact path="/Exchange/:MODULE_NAME/Edit/:ID"                           component={PlaceholderView} />
			<PrivateRoute exact path="/GoogleApps/:MODULE_NAME/Edit/:ID"                         component={PlaceholderView} />
			<PrivateRoute exact path="/iCloud/:MODULE_NAME/Edit/:ID"                             component={PlaceholderView} />
			<PrivateRoute exact path="/QuickBooks/:MODULE_NAME/Edit/:ID"                         component={PlaceholderView} />
			<PrivateRoute exact path="/QuickBooks/:MODULE_NAME"                                  component={PlaceholderView} />

			<PrivateRoute exact path="/:MODULE_NAME/:VIEW_NAME/:ID"                              component={DynamicLayoutView} />
			<PrivateRoute exact path="/:MODULE_NAME/:VIEW_NAME"                                  component={DynamicLayoutView} />

			<PrivateRoute exact path="/:MODULE_NAME/"                                            component={DynamicListView}   />
			<Route exact path="/" component={RootView} />
			<Route render={(props) => <div id='divUnknownRoute'>Unkown Route: {JSON.stringify(props)}</div>} />
		</Switch>
	</App>
);
