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
import { useParams, useSearchParams, useLocation, useNavigate, useMatches }   from  'react-router-dom';
// 4., Components and Views. 
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

export interface SplendidRedirect
{
	exact?   : boolean;
	from     : string;
	to       : string;
}

export interface SplendidRoute
{
	exact?    : boolean;
	path      : string;
	Component?: any   ;
	element?  : any   ;
}

const UnknownRoute = () =>
{
	const params   = useParams();
	const search   = useSearchParams();
	const location = useLocation();
	const navigate = useNavigate();
	const matches  = useMatches();
	console.log((new Date()).toISOString() + ' UnknownRoute', params, search, location, navigate, matches);
	return <div id='divUnknownRoute' style={ {fontSize: '20px', fontWeight: 'bold', padding: '20px'} }>
		Unkown Route: { JSON.stringify(params) }
		<br />
		Search: { JSON.stringify(search) }
		<br />
		Location: { JSON.stringify(location) }
		<br />
		Navigate: { JSON.stringify(navigate) }
		<br />
		Matches: { JSON.stringify(matches) }
	</div>;
};

// 02/15/2020 Paul.  To debug the router, use DebugRouter in index.tsx. 
export function cleanupRoutes()
{
	const r: SplendidRoute[] = [
/*
		{ path: "*", Component: 
			<Routes>
				<Route path="*" element={ <div id='divUnknownRoute'>Unkown Route</div> } />
			</Routes>
		},
*/
		{ path: "*", element: <UnknownRoute /> },
	];
	return r;
}

export function redirectRoutes()
{
	const r: SplendidRedirect[] = [
		{     exact: true , from: "/About"                                      , to: "/Home/About"                                 },
		{     exact: false, from: "/Campaigns/roi/:ID"                          , to: "/Campaigns/RoiDetailView/:ID"                },
		{     exact: false, from: "/Campaigns/track/:ID"                        , to: "/Campaigns/TrackDetailView/:ID"              },
		{     exact: false, from: "/Surveys/results/:ID"                        , to: "/Surveys/ResultsView/:ID"                    },
		{     exact: false, from: "/Surveys/summary/:ID"                        , to: "/Surveys/SummaryView/:ID"                    },
		{     exact: false, from: "/Emails/Drafts"                              , to: "/Emails/List?Type=draft"                     },
		{     exact: false, from: "/Projects/View/:ID"                          , to: "/Project/View/:ID"                           },
		{     exact: false, from: "/Projects/Edit/*"                            , to: "/Project/Edit/*"                             },
		{     exact: false, from: "/Projects/List"                              , to: "/Project/List"                               },
		{     exact: false, from: "/Projects/*"                                 , to: "/Project/*"                                  },
		{     exact: false, from: "/ProjectTasks/View/:ID"                      , to: "/ProjectTask/View/:ID"                       },
		{     exact: false, from: "/ProjectTasks/Edit/*"                        , to: "/ProjectTask/Edit/*"                         },
		{     exact: false, from: "/ProjectTasks/List"                          , to: "/ProjectTask/List"                           },
		{     exact: false, from: "/ProjectTasks/*"                             , to: "/ProjectTask/*"                              },
		{     exact: false, from: "/ReportDesigner/View/:ID"                    , to: "/Reports/View/:ID"                           },
		{     exact: false, from: "/ReportDesigner/Edit/*"                      , to: "/Reports/Edit/*"                             },
		{     exact: false, from: "/ReportDesigner/List"                        , to: "/Reports/List"                               },
		{     exact: false, from: "/ReportDesigner/*"                           , to: "/Reports/*"                                  },
		{     exact: false, from: "/RulesWizard/View/*"                         , to: "/RulesWizard/Edit/*"                         },
		{     exact: false, from: "/Administration/Users/EditMyAccount"         , to: "/Users/EditMyAccount"                        },
		{     exact: false, from: "/Administration/iFrames/View/:ID"            , to: "/iFrames/View/:ID"                           },
		{     exact: false, from: "/Administration/iFrames/Edit/*"              , to: "/iFrames/Edit/*"                             },
		{     exact: false, from: "/Administration/iFrames/List"                , to: "/iFrames/List"                               },
		{     exact: false, from: "/Administration/iFrames/*"                   , to: "/iFrames/*"                                  },
		{     exact: false, from: "/Reports/ReportRules/View/:ID"               , to: "/ReportRules/View/:ID"                       },
		{     exact: false, from: "/Reports/ReportRules/Edit/*"                 , to: "/ReportRules/Edit/*"                         },
		{     exact: false, from: "/Reports/ReportRules/List"                   , to: "/ReportRules/List"                           },
		{     exact: false, from: "/Reports/ReportRules/*"                      , to: "/ReportRules/*"                              },
		{     exact: false, from: "/ReportRules/View/:ID"                       , to: "/ReportRules/Edit/:ID"                       },
		{     exact: false, from: "/Administration/ModulesArchiveRules/View/:ID", to: "/Administration/ModulesArchiveRules/Edit/:ID"},
		{     exact: false, from: "/Administration/BusinessRules/View/:ID"      , to: "/Administration/BusinessRules/Edit/:ID"      },
		{                   from: "/Users/Reassign"                             , to: "/Administration/Users/Reassign"              },
	];
	return r;
}

export function publicRoutes()
{
	const routes: SplendidRoute[] = [
		{ exact: true, path: "/login"                                                   , Component: DynamicLoginView               },
	];
	return routes;
}

export function resetRoutes()
{
	const routes: SplendidRoute[] = [
		{ exact: true, path: "/Reset/*"                                                 , Component: ResetView                      },
		{ exact: true, path: "/Reload/*"                                                , Component: ReloadView                     },
	];
	return routes;
}

export function privateRoutes()
{
	const routes: SplendidRoute[] = [
		{              path: "/Administration/_devtools/Precompile"                     , Component: Precompile                     },
		{ exact: true, path: "/Home/About"                                              , Component: AboutView                      },

		{              path: "/GoogleOAuth"                                             , Component: GoogleOAuth                    },
		{              path: "/Office365OAuth"                                          , Component: Office365OAuth                 },
		{ exact: true, path: "/Home/TrainingPortal"                                     , Component: TrainingPortal                 },
		{ exact: true, path: "/Home/DashboardEdit/:ID"                                  , Component: HomeDashboardEditView          },
		{ exact: true, path: "/Home/DashboardEdit"                                      , Component: HomeDashboardEditView          },
		{ exact: true, path: "/Home/:ID"                                                , Component: HomeView                       },
		{ exact: true, path: "/Home"                                                    , Component: HomeView                       },
		{ exact: true, path: "/BigCalendar"                                             , Component: BigCalendarView                },
		{              path: "/Calendar"                                                , Component: CalendarView                   },
		{ exact: true, path: "/Dashboard/DashboardEdit/:ID"                             , Component: DashboardEditView              },
		{ exact: true, path: "/Dashboard/DashboardEdit"                                 , Component: DashboardEditView              },
		{ exact: true, path: "/Dashboard/:ID"                                           , Component: DashboardView                  },
		{ exact: true, path: "/Dashboard"                                               , Component: DashboardView                  },
		{ exact: true, path: "/UnifiedSearch/:search"                                   , Component: UnifiedSearch                  },
		{ exact: true, path: "/UnifiedSearch"                                           , Component: UnifiedSearch                  },

		{ exact: true, path: "/ChatDashboard/:ID"                                       , Component: ChatDashboardView              },
		{ exact: true, path: "/ChatDashboard"                                           , Component: ChatDashboardView              },
		{ exact: true, path: "/Reports/Edit/:ID"                                        , Component: ReportEditView                 },
		{ exact: true, path: "/Reports/Edit"                                            , Component: ReportEditView                 },
		{ exact: true, path: "/Reports/Import"                                          , Component: ReportImportView               },
		{ exact: true, path: "/Reports/View/:ID"                                        , Component: ReportView                     },
		{ exact: true, path: "/Reports/View/:ID/*"                                      , Component: ReportView                     },
		{ exact: true, path: "/Reports/Attachment/:ID/:PARENT_NAME/:PARENT_ID/*"        , Component: ReportAttachmentView           },
		{ exact: true, path: "/Reports/Attachment/:ID"                                  , Component: ReportAttachmentView           },
		{ exact: true, path: "/Reports/Signature/:ID/:PARENT_NAME/:PARENT_ID/*"         , Component: ReportSignatureView            },
		{ exact: true, path: "/Reports/Signature/:ID"                                   , Component: ReportSignatureView            },

		{ exact: true, path: "/Charts/Edit/:ID"                                         , Component: ChartEditView                  },
		{ exact: true, path: "/Charts/Edit"                                             , Component: ChartEditView                  },
		{ exact: true, path: "/Charts/Import"                                           , Component: ChartImportView                },
		{ exact: true, path: "/Charts/View/:ID"                                         , Component: ChartDetailView                },
		{ exact: true, path: "/Charts/View/:ID/*"                                       , Component: ChartDetailView                },

		{ exact: true, path: "/Users/MyAccount"                                         , Component: MyAccountView                  },
		{ exact: true, path: "/Users/EditMyAccount"                                     , Component: MyAccountEdit                  },
		{ exact: true, path: "/Users/Wizard"                                            , Component: UserWizard                     },
		{ exact: true, path: "/Feeds/MyFeeds"                                           , Component: PlaceholderView                },
		{ exact: true, path: "/MailMerge/:MODULE_NAME/:ID"                              , Component: DynamicMailMerge               },
		{ exact: true, path: "/MailMerge/:MODULE_NAME"                                  , Component: DynamicMailMerge               },
		{ exact: true, path: "/MailMerge"                                               , Component: DynamicMailMerge               },
		{ exact: true, path: "/Merge/:MODULE_NAME/:ID"                                  , Component: MergeView                      },
		{ exact: true, path: "/MassMerge/:MODULE_NAME/:ID"                              , Component: MergeView                      },

		{ exact: true, path: "/Administration/EmailMan/AdminCampaignEditView"           , Component: AdminCampaignEditView          },
		{ exact: true, path: "/Administration/EmailMan/ConfigView"                      , Component: EmailManConfigView             },
		{              path: "/Administration/Users/Reassign"                           , Component: UsersReassignView              },
		{              path: "/Administration/Config/PasswordManager"                   , Component: AdminPasswordManager           },
		{              path: "/Administration/Config/BusinessMode"                      , Component: AdminBusinessMode              },
		{              path: "/Administration/Config/BackupDatabase"                    , Component: BackupsConfigView              },
		{              path: "/Administration/Config/Updater"                           , Component: UpdaterConfigView              },
		{              path: "/Administration/Terminology/TerminologyImport"            , Component: TerminologyImportView          },
		{              path: "/Administration/Import/ImportDatabase"                    , Component: DatabaseImportView             },
		{ exact: true, path: "/Administration/Exchange/ConfigView"                      , Component: ExchangeConfigView             },
		{ exact: true, path: "/Administration/Google/ConfigView"                        , Component: GoogleConfigView               },
		{              path: "/Administration/Google"                                   , Component: GoogleConfigView               },
		{              path: "/Administration/ModuleBuilder"                            , Component: ModuleBuilderWizardView        },

		{              path: "/Administration/Configurator"                             , Component: ConfiguratorAdminWizard        },
		{              path: "/Administration/Facebook"                                 , Component: AdminConfigView                },
		{              path: "/Administration/LinkedIn"                                 , Component: AdminConfigView                },
		{              path: "/Administration/Salesforce"                               , Component: AdminConfigView                },
		{              path: "/Administration/Twitter"                                  , Component: AdminConfigView                },
		{ exact: true, path: "/Administration/QuickBooks/ConfigView"                    , Component: QuickBooksConfigView           },
		{              path: "/Administration/QuickBooks"                               , Component: AdminReadOnlyConfigView        },
		{ exact: true, path: "/Administration/Twilio/ConfigView"                        , Component: AdminConfigView                },
		{              path: "/Administration/Twilio"                                   , Component: AdminReadOnlyListView          },
		{ exact: true, path: "/Administration/HubSpot/ConfigView"                       , Component: HubSpotConfigView              },
		{              path: "/Administration/HubSpot"                                  , Component: AdminReadOnlyConfigView        },
		{ exact: true, path: "/Administration/iContact/ConfigView"                      , Component: iContactConfigView             },
		{              path: "/Administration/iContact"                                 , Component: AdminReadOnlyConfigView        },
		{ exact: true, path: "/Administration/ConstantContact/ConfigView"               , Component: ConstantContactConfigView      },
		{              path: "/Administration/ConstantContact"                          , Component: AdminReadOnlyConfigView        },
		{ exact: true, path: "/Administration/Marketo/ConfigView"                       , Component: MarketoConfigView              },
		{              path: "/Administration/Marketo"                                  , Component: AdminReadOnlyConfigView        },
		{ exact: true, path: "/Administration/MailChimp/ConfigView"                     , Component: MailChimpConfigView            },
		{              path: "/Administration/MailChimp"                                , Component: AdminReadOnlyConfigView        },
		{ exact: true, path: "/Administration/CurrencyLayer/ConfigView"                 , Component: AdminConfigView                },
		{              path: "/Administration/CurrencyLayer"                            , Component: AdminReadOnlyConfigView        },
		{ exact: true, path: "/Administration/GetResponse/ConfigView"                   , Component: AdminConfigView                },
		{              path: "/Administration/GetResponse"                              , Component: AdminReadOnlyConfigView        },
		{ exact: true, path: "/Administration/Pardot/ConfigView"                        , Component: AdminConfigView                },
		{              path: "/Administration/Pardot"                                   , Component: AdminReadOnlyConfigView        },
		{ exact: true, path: "/Administration/Watson/ConfigView"                        , Component: WatsonConfigView               },
		{              path: "/Administration/Watson"                                   , Component: AdminReadOnlyConfigView        },
		{ exact: true, path: "/Administration/PhoneBurner/ConfigView"                   , Component: PhoneBurnerConfigView          },
		{              path: "/Administration/PhoneBurner"                              , Component: AdminReadOnlyConfigView        },
		{ exact: true, path: "/Administration/MicrosoftTeams/ConfigView"                , Component: MicrosoftTeamsConfigView       },
		{              path: "/Administration/MicrosoftTeams"                           , Component: AdminReadOnlyConfigView        },

		{ exact: true, path: "/Administration/DynamicLayout/AdminDynamicLayout"         , Component: AdminDynamicLayout             },
		{ exact: true, path: "/Administration/Terminology/RenameTabs"                   , Component: AdminRenameTabs                },
		{ exact: true, path: "/Administration/Modules/ConfigureTabs"                    , Component: AdminConfigureTabs             },

		{              path: "/Administration/FullTextSearch"                           , Component: FullTextSearchConfigView       },
		{              path: "/Administration/SystemLog"                                , Component: SystemLogListView              },
		{              path: "/Administration/SystemSyncLog"                            , Component: SystemSyncLogListView          },
		{              path: "/Administration/UserLogins"                               , Component: UserLoginsListView             },
		{              path: "/Administration/AuditEvents"                              , Component: AdminReadOnlyListView          },
		{              path: "/Administration/WorkflowEventLog"                         , Component: WorkflowEventLogListView       },
		{              path: "/Administration/BusinessProcessesLog"                     , Component: BusinessProcessesLogListView   },

		{ exact: true, path: "/Administration/AuthorizeNet/ConfigView"                  , Component: AdminConfigView                },
		{ exact: true, path: "/Administration/AuthorizeNet/CustomerProfiles/View/:ID"   , Component: AuthorizeNetCustomerDetailView },
		{              path: "/Administration/AuthorizeNet/CustomerProfiles"            , Component: AuthorizeNetCustomerListView   },
		{              path: "/Administration/AuthorizeNet"                             , Component: AuthorizeNetListView           },
		{ exact: true, path: "/Administration/PayPal/ConfigView"                        , Component: AdminConfigView                },
		{ exact: true, path: "/Administration/PayPalTransactions/View/:ID"              , Component: PayPalDetailView               },
		{ exact: true, path: "/Administration/PayPal/View/:ID"                          , Component: PayPalDetailView               },
		{              path: "/Administration/PayPalTransactions"                       , Component: PayPalListView                 },
		{              path: "/Administration/PayPal/List"                              , Component: PayPalListView                 },
		{              path: "/Administration/PayPal"                                   , Component: PayPalListView                 },
		{ exact: true, path: "/Administration/PayTrace/ConfigView"                      , Component: AdminConfigView                },
		{ exact: true, path: "/Administration/PayTrace/View/:ID"                        , Component: PayTraceDetailView             },
		{              path: "/Administration/PayTrace"                                 , Component: PayTraceListView               },
		{ exact: true, path: "/Administration/Asterisk/ConfigView"                      , Component: AdminConfigView                },
		{ exact: true, path: "/Administration/Asterisk/View/:ID"                        , Component: AsteriskDetailView             },
		{              path: "/Administration/Asterisk"                                 , Component: AsteriskListView               },
		{ exact: true, path: "/Administration/Avaya/ConfigView"                         , Component: AdminConfigView                },
		{ exact: true, path: "/Administration/Avaya/View/:ID"                           , Component: AvayaDetailView                },
		{              path: "/Administration/Avaya"                                    , Component: AvayaListView                  },

		{ exact: true, path: "/Administration/Azure/:MODULE_NAME/ConfigView"            , Component: AdminConfigView                },
		{ exact: true, path: "/Administration/Azure/:MODULE_NAME/ReadOnlyListView"      , Component: AdminReadOnlyListView          },
		{ exact: true, path: "/Administration/Azure/:MODULE_NAME/DetailView"            , Component: AdminReadOnlyConfigView        },
		{ exact: true, path: "/Administration/Azure/:MODULE_NAME/List"                  , Component: AdminDynamicListView           },
		{ exact: true, path: "/Administration/Azure/:MODULE_NAME/View/:ID"              , Component: AdminDynamicDetailView         },
		{ exact: true, path: "/Administration/Azure/:MODULE_NAME/Duplicate/:DuplicateID", Component: AdminDynamicEditView           },
		{ exact: true, path: "/Administration/Azure/:MODULE_NAME/Edit/:ID"              , Component: AdminDynamicEditView           },
		{ exact: true, path: "/Administration/Azure/:MODULE_NAME/Edit"                  , Component: AdminDynamicEditView           },
		{ exact: true, path: "/Administration/Azure/ConfigView"                         , Component: AzureConfigView                },
		{              path: "/Administration/Azure"                                    , Component: AzureDetailView                },

		{ exact: true, path: "/Administration/ACLRoles/Edit/:ID/FieldSecurity"          , Component: ACLRolesFieldSecurity          },
		{ exact: true, path: "/Administration/ACLRoles/ByUser"                          , Component: ACLRolesByUser                 },
		{ exact: true, path: "/Administration/:MODULE_NAME/ReadOnlyListView"            , Component: AdminReadOnlyListView          },
		{ exact: true, path: "/Administration/:MODULE_NAME/DetailView"                  , Component: AdminReadOnlyConfigView        },
		{ exact: true, path: "/Administration/:MODULE_NAME/ConfigView"                  , Component: AdminConfigView                },
		{ exact: true, path: "/Administration/:MODULE_NAME/Config"                      , Component: AdminConfigView                },
		{ exact: true, path: "/Administration/:MODULE_NAME/List"                        , Component: AdminDynamicListView           },
		{ exact: true, path: "/Administration/:MODULE_NAME/View/:ID"                    , Component: AdminDynamicDetailView         },
		{ exact: true, path: "/Administration/:MODULE_NAME/Duplicate/:DuplicateID"      , Component: AdminDynamicEditView           },
		{ exact: true, path: "/Administration/:MODULE_NAME/Edit/:ID"                    , Component: AdminDynamicEditView           },
		{ exact: true, path: "/Administration/:MODULE_NAME/Edit"                        , Component: AdminDynamicEditView           },
		{ exact: true, path: "/Administration/:MODULE_NAME/Import"                      , Component: ImportView                     },
		{ exact: true, path: "/Administration/Workflows/Sequence"                       , Component: WorkflowsSequenceView          },
		{ exact: true, path: "/Administration/SimpleEmail/Statistics"                   , Component: PlaceholderView                },
		{ exact: true, path: "/Administration/QuickBooks/:MODULE_NAME"                  , Component: PlaceholderView                },
		{ exact: true, path: "/Administration/MailChimp/:MODULE_NAME/Edit/:ID"          , Component: PlaceholderView                },

		{ exact: true, path: "/Administration/:MODULE_NAME/"                            , Component: AdminDynamicListView           },
		{ exact: true, path: "/Administration"                                          , Component: AdministrationView             },

		{ exact: true, path: "/Parents/View/:ID"                                        , Component: ParentsView                    },
		{ exact: true, path: "/:MODULE_NAME/List"                                       , Component: DynamicListView                },
		{ exact: true, path: "/:MODULE_NAME/View/:ID"                                   , Component: DynamicDetailView              },
		{ exact: true, path: "/:MODULE_NAME/ArchiveView/:ID"                            , Component: DynamicDetailView              },
		{ exact: true, path: "/:MODULE_NAME/ArchiveView"                                , Component: DynamicListView                },
		{ exact: true, path: "/:MODULE_NAME/Duplicate/:DuplicateID"                     , Component: DynamicEditView                },
		{ exact: true, path: "/:MODULE_NAME/Convert/:ConvertModule/:ConvertID"          , Component: DynamicEditView                },
		{ exact: true, path: "/:MODULE_NAME/Edit/:ID"                                   , Component: DynamicEditView                },
		{ exact: true, path: "/:MODULE_NAME/Edit"                                       , Component: DynamicEditView                },
		{ exact: true, path: "/:MODULE_NAME/Import"                                     , Component: ImportView                     },
		{ exact: true, path: "/:MODULE_NAME/Stream"                                     , Component: StreamView                     },

		{ exact: true, path: "/Exchange/:MODULE_NAME/Edit/:ID"                          , Component: PlaceholderView                },
		{ exact: true, path: "/GoogleApps/:MODULE_NAME/Edit/:ID"                        , Component: PlaceholderView                },
		{ exact: true, path: "/iCloud/:MODULE_NAME/Edit/:ID"                            , Component: PlaceholderView                },
		{ exact: true, path: "/QuickBooks/:MODULE_NAME/Edit/:ID"                        , Component: PlaceholderView                },
		{ exact: true, path: "/QuickBooks/:MODULE_NAME"                                 , Component: PlaceholderView                },

		{ exact: true, path: "/Reset/:MODULE_NAME/:VIEW_NAME"                           , Component: ResetView                      },
		{ exact: true, path: "/:MODULE_NAME/:VIEW_NAME/:ID"                             , Component: DynamicLayoutView              },
		{ exact: true, path: "/:MODULE_NAME/:VIEW_NAME"                                 , Component: DynamicLayoutView              },

		{ exact: true, path: "/:MODULE_NAME/"                                           , Component: DynamicListView                },
		{ exact: true, path: "/*"                                                       , Component: RootView                       },
	];
	// 01/21/2024 Paul.  Apply non-exact rule. 
	for ( let i = 0; i < routes.length; i++ )
	{
		if ( !routes[i].exact )
		{
			routes[i].path = routes[i].path + '/*';
		}
	}
	return routes;
}
