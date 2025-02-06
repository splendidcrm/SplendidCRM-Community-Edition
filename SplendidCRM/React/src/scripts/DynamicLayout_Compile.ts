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
//Types and interfaces need to be imported, everything else can be required.
const React                                  = require('react'                                );
const { Modal }                              = require('react-bootstrap'                      );
// 09/19/2024 Paul.  To use XMLParser in dynamic control, must use root. 
const XMLParser                              = require('fast-xml-parser'                      );
const qs                                     = require('query-string'                         ).default;
const posed                                  = require('react-pose'                           ).default;
const Babel                                  = require('@babel/standalone'                    );
const { SplendidHistory, RouteComponentProps, withRouter, Link, Route, Navigate }    = require('../Router5');
const am4core                                = require('@amcharts/amcharts4/core'             );
const am4charts                              = require('@amcharts/amcharts4/charts'           );
const { observer }                           = require('mobx-react'                           );
const mobx                                   = require('mobx'                                 );
const BootstrapTable                         = require('react-bootstrap-table-next'           );
const { FontAwesomeIcon }                    = require('@fortawesome/react-fontawesome'       );
const moment                                 = require('moment'                               );
const { Appear }                             = require('react-lifecycle-appear'               );
const { RouterStore }                        = require('mobx-react-router'                    );
// 2. Types
const ACL_ACCESS                             = require('../types/ACL_ACCESS'                  ).default;
const ACL_FIELD_ACCESS                       = require('../types/ACL_FIELD_ACCESS'            ).default;
const DYNAMIC_BUTTON                         = require('../types/DYNAMIC_BUTTON'              ).default;
const DETAILVIEWS_RELATIONSHIP               = require('../types/DETAILVIEWS_RELATIONSHIP'    ).default;
const MODULE                                 = require('../types/MODULE'                      ).default;
const RELATIONSHIPS                          = require('../types/RELATIONSHIPS'               ).default;
const SINGLE_SIGN_ON                         = require('../types/SINGLE_SIGN_ON'              ).default;
const DASHBOARDS_PANELS                      = require('../types/DASHBOARDS_PANELS'           ).default;
const SHORTCUT                               = require('../types/SHORTCUT'                    ).default;
const TAB_MENU                               = require('../types/TAB_MENU'                    ).default;
const IDashletProps                          = require('../types/IDashletProps'               ).default;
const IOrdersLineItemsEditorProps            = require('../types/IOrdersLineItemsEditorProps' ).default;
const IOrdersLineItemsEditorState            = require('../types/IOrdersLineItemsEditorState' ).default;
const OrdersLineItemsEditor                  = require('../types/OrdersLineItemsEditor'       ).default;
const { IEditComponentProps, EditComponent } = require('../types/EditComponent'               );
const { IDetailViewProps, IDetailComponentProps, IDetailComponentState, DetailComponent } = require('../types/DetailComponent');
const { HeaderButtons }                      = require('../types/HeaderButtons'               );
// 3. Scripts
const Sql                                    = require('../scripts/Sql'                       ).default;
const L10n                                   = require('../scripts/L10n'                      ).default;
// 10/16/2021 Paul.  Add support for user currency. 
const C10n                                   = require('../scripts/C10n'                      ).default;
const Security                               = require('../scripts/Security'                  ).default;
const { Crm_Config, Crm_Modules, Crm_Teams, Crm_Users } = require('../scripts/Crm');
const { FromJsonDate, ToJsonDate, formatDate, formatCurrency, formatNumber } = require('../scripts/Formatting');
const Credentials                            = require('../scripts/Credentials'               ).default;
const SplendidCache                          = require('../scripts/SplendidCache'             ).default;
const SplendidDynamic                        = require('../scripts/SplendidDynamic'           ).default;
const SplendidDynamic_DetailView             = require('../scripts/SplendidDynamic_DetailView').default;
const { sPLATFORM_LAYOUT }                   = require('../scripts/SplendidInitUI'            );
// 11/28/2021 Paul.  UpdateRelatedList is needed to allow customize of popups. 
const { UpdateModule, DeleteModuleItem, DeleteModuleRecurrences, MassDeleteModule, MassUpdateModule, MassSync, MassUnsync, ArchiveMoveData, ArchiveRecoverData, UpdateSavedSearch, DeleteRelatedItem, UpdateRelatedItem, UpdateRelatedList, AdminProcedure, ExecProcedure } = require('../scripts/ModuleUpdate');
const { CreateSplendidRequest, GetSplendidResult                                              } = require('../scripts/SplendidRequest');
const { DetailView_LoadItem, DetailView_LoadLayout, DetailView_LoadPersonalInfo, DetailView_RemoveField, DetailView_HideField, DetailView_FindField, DetailView_GetTabList, DetailView_ActivateTab} = require('../scripts/DetailView'     );
// 11/25/2020 Paul.  EditView_UpdateREPEAT_TYPE is used in Calls/Meetings EditView. 
const { EditView_LoadItem, EditView_LoadLayout, EditView_ConvertItem, EditView_RemoveField, EditView_InitItem, EditView_FindField, EditView_HideField, EditView_UpdateREPEAT_TYPE, EditView_GetTabList, EditView_ActivateTab } = require('../scripts/EditView'       );
const { Application_GetReactLoginState }     = require('../scripts/Application'               );
const { AppName, AppVersion }                = require('../AppVersion'                        );
const { AuthenticatedMethod, IsAuthenticated, LoginRedirect, GetUserProfile, GetMyUserProfile, GetUserID, Login, ForgotPassword } = require('../scripts/Login'          );
const { Right, Left, StartsWith, EndsWith, Trim, uuidFast, isEmptyObject, isTouchDevice, base64ArrayBuffer, isMobile, screenWidth, screenHeight } = require('../scripts/utility'        );
const { NormalizeDescription, XssFilter                                                       } = require('../scripts/EmailUtils'     );
const { ListView_LoadTable, ListView_LoadModule, ListView_LoadLayout, ListView_LoadModulePaginated, ListView_LoadTablePaginated, ListView_LoadTableWithAggregate } = require('../scripts/ListView');
const { ConvertEditViewFieldToDetailViewField                                                 } = require('../scripts/ConvertLayoutField');
const { GetInviteesActivities }              = require('../scripts/CalendarView'                  );
const { DynamicButtons_LoadLayout }          = require('../scripts/DynamicButtons'                );

const { jsonReactState, Application_GetReactState, Admin_GetReactState, Application_ClearStore, Application_UpdateStoreLastDate} = require('../scripts/Application'                   );
// 4. Components and Views. 
const DumpSQL                                = require('../components/DumpSQL'                    ).default;
const SearchView                             = require('../views/SearchView'                      ).default;
// 08/11/2021 Paul.  Allow custom popups from custom layouts. 
const DynamicPopupView                       = require('../views/DynamicPopupView'                ).default;
const EditView                               = require('../views/EditView'                        ).default;
const ListView                               = require('../views/ListView'                        ).default;
const DetailView                             = require('../views/DetailView'                      ).default;
const DynamicButtons                         = require('../components/DynamicButtons'             ).default;
const ModuleHeader                           = require('../components/ModuleHeader'               ).default;
const ProcessButtons                         = require('../components/ProcessButtons'             ).default;
const ErrorComponent                         = require('../components/ErrorComponent'             ).default;
const Collapsable                            = require('../components/Collapsable'                ).default;
const DetailViewLineItems                    = require('../views/DetailViewLineItems'             ).default;
const DetailViewRelationships                = require('../views/DetailViewRelationships'         ).default;
const SplendidGrid                           = require('../components/SplendidGrid'               ).default;
const SchedulingGrid                         = require('../components/SchedulingGrid'             ).default;
const ListHeader                             = require('../components/ListHeader'                 ).default;
const SearchTabs                             = require('../components/SearchTabs'                 ).default;
const ExportHeader                           = require('../components/ExportHeader'               ).default;
const PreviewDashboard                       = require('../views/PreviewDashboard'                ).default;
const MassUpdate                             = require('../views/MassUpdate'                      ).default;
const DynamicMassUpdate                      = require('../views/DynamicMassUpdate'               ).default;
// 08/30/2022 Paul.  A customer needs to have DynamicDetailView for a custom DetailView. 
const DynamicDetailView                      = require('../views/DynamicDetailView'               ).default;
// 07/10/2019 Paul.  Cannot use DynamicEditView as it causes any file that includes SearchView, PopupView to fail to load in DynamicLayout, including SplendidDynamic_EditView. 
// 02/03/2024 Paul.  DynamicEditView seems to be cause SplendidDynamic_EditView to fail again. 
const DynamicEditView                        = require('../views/DynamicEditView'                 ).default;
const DynamicListView                        = require('../views/DynamicListView'                 ).default;
const AuditView                              = require('../views/AuditView'                       ).default;
const HeaderButtonsFactory                   = require('../ThemeComponents/HeaderButtonsFactory'  ).default;
const SubPanelButtonsFactory                 = require('../ThemeComponents/SubPanelButtonsFactory').default;
const EditViewLineItems                      = require('../views/EditViewLineItems'               ).default;
// 02/10/2022 Paul.  AcocuntsDetailViewJS uses ActivitiesPopupView and PersonalInfoView, so we must export these views. 
const ActivitiesPopupView                    = require('../views/ActivitiesPopupView'             ).default;
const PersonalInfoView                       = require('../views/PersonalInfoView'                ).default;
// 04/13/2022 Paul.  Add LayoutTabs to Pacific theme. 
const LayoutTabs                             = require('../components/LayoutTabs'                 ).default;
// 10/01/2022 Paul.  Base dashlets should have been added long ago.  They are needed when making custom from base. 
const BaseMyDashlet                          = require('../Dashlets/BaseMyDashlet'                ).default;
const BaseMyFavoriteDashlet                  = require('../Dashlets/BaseMyFavoriteDashlet'        ).default;
const BaseMyTeamDashlet                      = require('../Dashlets/BaseMyTeamDashlet'            ).default;

// 02/04/2024 Paul.  Some modules need fixing.  Don't know why. 
//const AuthenticationContext                  = require('../scripts/adal'                          ).default;
//const SplendidDynamic_EditView               = require('../scripts/SplendidDynamic_EditView'      ).default;
//const PopupView                              = require('../views/PopupView'                       ).default;
//const ModuleViewFactory                      = require('../ModuleViews'                           ).default;
//const { DynamicLayout_Module }               = require('../scripts/DynamicLayout'                 );
import * as All_AuthenticationContext        from '../scripts/adal'                    ;
import * as All_PopupView                    from '../views/PopupView'                 ;
import * as All_SplendidDynamic_EditView     from '../scripts/SplendidDynamic_EditView';
import * as All_ModuleViewFactory            from '../ModuleViews'                     ;
import * as All_DynamicLayout_Module         from '../scripts/DynamicLayout'           ;
let AuthenticationContext                    = All_AuthenticationContext.default            ;
let PopupView                                = All_PopupView.default                        ;
let SplendidDynamic_EditView                 = All_SplendidDynamic_EditView.default         ;
let ModuleViewFactory                        = All_ModuleViewFactory.default                ;
let DynamicLayout_Module                     = All_DynamicLayout_Module.DynamicLayout_Module;

// 02/04/2024 Paul.  Modules being null is back. 
const allModules: any[] =
// 3. Scripts
[ { Module: Sql                       , Name: 'Sql'                        }
, { Module: L10n                      , Name: 'L10n'                       }
, { Module: C10n                      , Name: 'C10n'                       }
, { Module: Security                  , Name: 'Security'                   }
, { Module: Credentials               , Name: 'Credentials'                }
, { Module: SplendidCache             , Name: 'SplendidCache'              }
, { Module: SplendidDynamic           , Name: 'SplendidDynamic'            }
, { Module: SplendidDynamic_EditView  , Name: 'SplendidDynamic_EditView'   }
, { Module: SplendidDynamic_DetailView, Name: 'SplendidDynamic_DetailView' }
, { Module: DynamicButtons_LoadLayout , Name: 'DynamicButtons_LoadLayout'  }
, { Module: AuthenticationContext     , Name: 'AuthenticationContext'      }
, { Module: DynamicLayout_Module      , Name: 'DynamicLayout_Module'       }
// 4. Components and Views.
, { Module: DumpSQL                   , Name: 'DumpSQL'                    }
, { Module: SearchView                , Name: 'SearchView'                 }
, { Module: PopupView                 , Name: 'PopupView'                  }
, { Module: DynamicPopupView          , Name: 'DynamicPopupView'           }
, { Module: EditView                  , Name: 'EditView'                   }
, { Module: ListView                  , Name: 'ListView'                   }
, { Module: DetailView                , Name: 'DetailView'                 }
, { Module: DynamicButtons            , Name: 'DynamicButtons'             }
, { Module: ModuleHeader              , Name: 'ModuleHeader'               }
, { Module: ProcessButtons            , Name: 'ProcessButtons'             }
, { Module: ErrorComponent            , Name: 'ErrorComponent'             }
, { Module: Collapsable               , Name: 'Collapsable'                }
, { Module: DetailViewLineItems       , Name: 'DetailViewLineItems'        }
, { Module: DetailViewRelationships   , Name: 'DetailViewRelationships'    }
, { Module: SplendidGrid              , Name: 'SplendidGrid'               }
, { Module: SchedulingGrid            , Name: 'SchedulingGrid'             }
, { Module: ListHeader                , Name: 'ListHeader'                 }
, { Module: SearchTabs                , Name: 'SearchTabs'                 }
, { Module: ExportHeader              , Name: 'ExportHeader'               }
, { Module: PreviewDashboard          , Name: 'PreviewDashboard'           }
, { Module: MassUpdate                , Name: 'MassUpdate'                 }
, { Module: DynamicMassUpdate         , Name: 'DynamicMassUpdate'          }
, { Module: DynamicDetailView         , Name: 'DynamicDetailView'          }
, { Module: DynamicEditView           , Name: 'DynamicEditView'            }
, { Module: DynamicListView           , Name: 'DynamicListView'            }
, { Module: ModuleViewFactory         , Name: 'ModuleViewFactory'          }
, { Module: AuditView                 , Name: 'AuditView'                  }
, { Module: HeaderButtonsFactory      , Name: 'HeaderButtonsFactory'       }
, { Module: SubPanelButtonsFactory    , Name: 'SubPanelButtonsFactory'     }
, { Module: EditViewLineItems         , Name: 'EditViewLineItems'          }
, { Module: ActivitiesPopupView       , Name: 'ActivitiesPopupView'        }
, { Module: PersonalInfoView          , Name: 'PersonalInfoView'           }
, { Module: LayoutTabs                , Name: 'LayoutTabs'                 }
, { Module: BaseMyDashlet             , Name: 'BaseMyDashlet'              }
, { Module: BaseMyFavoriteDashlet     , Name: 'BaseMyFavoriteDashlet'      }
, { Module: BaseMyTeamDashlet         , Name: 'BaseMyTeamDashlet'          }
];

function FixNulledModules()
{
	if ( AuthenticationContext == null || AuthenticationContext === undefined )
	{
		const m = allModules.find(x => x.Name == 'AuthenticationContext');
		m.Module              = All_AuthenticationContext.default.AuthenticationContext;
		AuthenticationContext = All_AuthenticationContext.default.AuthenticationContext;
		console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Compile.FixNulledModules: AuthenticationContext Restored');
	}
	if ( PopupView == null || PopupView === undefined )
	{
		const m = allModules.find(x => x.Name == 'PopupView');
		m.Module  = All_PopupView.default;
		PopupView = All_PopupView.default;
		console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Compile.FixNulledModules: PopupView Restored');
	}
	if ( SplendidDynamic_EditView == null || SplendidDynamic_EditView === undefined )
	{
		const m = allModules.find(x => x.Name == 'SplendidDynamic_EditView');
		m.Module                 = All_SplendidDynamic_EditView.default;
		SplendidDynamic_EditView = All_SplendidDynamic_EditView.default;
		console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Compile.FixNulledModules: SplendidDynamic_EditView Restored');
	}
	if ( ModuleViewFactory == null || ModuleViewFactory === undefined )
	{
		const m = allModules.find(x => x.Name == 'ModuleViewFactory');
		m.Module          = All_ModuleViewFactory.default;
		ModuleViewFactory = All_ModuleViewFactory.default;
		console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Compile.FixNulledModules: ModuleViewFactory Restored');
	}
	if ( DynamicLayout_Module == null || DynamicLayout_Module === undefined )
	{
		const m = allModules.find(x => x.Name == 'DynamicLayout_Module');
		m.Module             = All_DynamicLayout_Module.DynamicLayout_Module;
		DynamicLayout_Module = All_DynamicLayout_Module.DynamicLayout_Module;
		console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Compile.FixNulledModules: DynamicLayout_Module Restored');
	}
}

function DumpRequiredModules()
{
	for ( let i = 0; i < allModules.length; i++ )
	{
		if ( allModules[i].Module === null || allModules[i].Module === undefined )
		{
			console.error((new Date()).toISOString() + ' ' + 'DynamicLayout_Compile.DumpRequiredModules: ' + i.toString() + '. ' + Trim(allModules[i].Name) + ' is ' + allModules[i].Module);
		}
	}
}

export async function DynamicLayout_Compile(responseText: string)
{
	// 02/07/2024 Paul.  Fix is still required, but stop dumping to reduce delay. 
	FixNulledModules();
	//DumpRequiredModules();
	let view = await (async () =>
	{
		return eval((Babel.transform(responseText, { presets: ['es2015', 'react', ['stage-0', { decoratorsBeforeExport: true}], ['typescript', { isTSX: true, allExtensions: true }]] })).code);
	})();
	return view;
}

