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
import { RouteComponentProps } from 'react-router';
//Types and interfaces need to be imported, everything else can be required.
const React                                  = require('react'                                );
const { Modal }                              = require('react-bootstrap'                      );
const XMLParser                              = require('fast-xml-parser'                      );
const qs                                     = require('query-string'                         );
const posed                                  = require('react-pose'                           ).default;
const Babel                                  = require('@babel/standalone'                    );
const { RouteComponentProps, withRouter }    = require('react-router'                         );
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
const SplendidDynamic_EditView               = require('../scripts/SplendidDynamic_EditView'  ).default;
const SplendidDynamic_DetailView             = require('../scripts/SplendidDynamic_DetailView').default;
const { sPLATFORM_LAYOUT }                   = require('../scripts/SplendidInitUI'            );
// 11/28/2021 Paul.  UpdateRelatedList is needed to allow customize of popups. 
const { UpdateModule, DeleteModuleItem, DeleteModuleRecurrences, MassDeleteModule, MassUpdateModule, MassSync, MassUnsync, ArchiveMoveData, ArchiveRecoverData, UpdateSavedSearch, DeleteRelatedItem, UpdateRelatedItem, UpdateRelatedList, AdminProcedure, ExecProcedure } = require('../scripts/ModuleUpdate');
const { CreateSplendidRequest, GetSplendidResult                                              } = require('../scripts/SplendidRequest');
const { DetailView_LoadItem, DetailView_LoadLayout, DetailView_LoadPersonalInfo, DetailView_RemoveField, DetailView_HideField, DetailView_FindField, DetailView_GetTabList, DetailView_ActivateTab} = require('../scripts/DetailView'     );
// 11/25/2020 Paul.  EditView_UpdateREPEAT_TYPE is used in Calls/Meetings EditView. 
const { EditView_LoadItem, EditView_LoadLayout, EditView_ConvertItem, EditView_RemoveField, EditView_InitItem, EditView_FindField, EditView_HideField, EditView_UpdateREPEAT_TYPE, EditView_GetTabList, EditView_ActivateTab } = require('../scripts/EditView'       );
// 12/07/2022 Paul.  Allow the LoginView to be customized. 
const AuthenticationContext                  = require('../scripts/adal'                      ).default;
const { Application_GetReactLoginState }     = require('../scripts/Application'               );
const { AppName, AppVersion }                = require('../AppVersion'                        );
const { AuthenticatedMethod, IsAuthenticated, LoginRedirect, GetUserProfile, GetMyUserProfile, GetUserID, Login, ForgotPassword } = require('../scripts/Login'          );
const { Right, Left, StartsWith, EndsWith, Trim, uuidFast, isEmptyObject, isTouchDevice, base64ArrayBuffer, isMobile, screenWidth, screenHeight } = require('../scripts/utility'        );
const { NormalizeDescription, XssFilter                                                       } = require('../scripts/EmailUtils'     );
const { ListView_LoadTable, ListView_LoadModule, ListView_LoadLayout, ListView_LoadModulePaginated, ListView_LoadTablePaginated, ListView_LoadTableWithAggregate } = require('../scripts/ListView');
const { ConvertEditViewFieldToDetailViewField                                                 } = require('../scripts/ConvertLayoutField');
const { GetInviteesActivities }              = require('../scripts/CalendarView'                  );
const { DynamicButtons_LoadLayout }          = require('../scripts/DynamicButtons'                );
const { DynamicLayout_Module }               = require('../scripts/DynamicLayout'                 );
const { jsonReactState, Application_GetReactState, Admin_GetReactState, Application_ClearStore, Application_UpdateStoreLastDate} = require('../scripts/Application'                   );
// 4. Components and Views. 
// 07/10/2019 Paul.  Cannot use DynamicEditView as it causes any file that includes SearchView, PopupView to fail to load in DynamicLayout, including SplendidDynamic_EditView. 
const DumpSQL                                = require('../components/DumpSQL'                    ).default;
const SearchView                             = require('../views/SearchView'                      ).default;
const PopupView                              = require('../views/PopupView'                       ).default;
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
const DynamicEditView                        = require('../views/DynamicEditView'                 ).default;
const DynamicListView                        = require('../views/DynamicListView'                 ).default;
const ModuleViewFactory                      = require('../ModuleViews'                           ).default;
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

export async function DynamicLayout_Compile(responseText: string)
{
	//console.log((new Date()).toISOString() + ' ' + 'SplendidDynamic_DetailView', SplendidDynamic_DetailView);
	//console.log((new Date()).toISOString() + ' ' + 'SplendidDynamic_EditView', SplendidDynamic_EditView);

	if ( Sql                        == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: Sql is null'                       );
	if ( L10n                       == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: L10n is null'                      );
	if ( Credentials                == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: Credentials is null'               );
	if ( SplendidCache              == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: SplendidCache is null'             );
	if ( SplendidDynamic_EditView   == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: SplendidDynamic_EditView is null'  );
	if ( SplendidDynamic_DetailView == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: SplendidDynamic_DetailView is null');
	if ( DynamicButtons_LoadLayout  == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: DynamicButtons_LoadLayout is null' );

	// 01/08/2020 Paul.  Importing DynamicLayout causes DynamicLayout_Module() to fail. 
	// 04/19/2020 Paul.  Moving babel transform to a shared file seems to have solved the PopupView issue. 
	if ( PopupView                  == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: PopupView is null'                 );
	if ( DynamicButtons             == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: DynamicButtons is null'            );
	if ( ModuleHeader               == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: ModuleHeader is null'              );
	if ( ProcessButtons             == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: ProcessButtons is null'            );
	if ( ErrorComponent             == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: ErrorComponent is null'            );
	if ( DetailViewLineItems        == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: DetailViewLineItems is null'       );
	if ( DetailViewRelationships    == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: DetailViewRelationships is null'   );
	if ( SearchView                 == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: SearchView is null'                );
	if ( SplendidGrid               == null ) console.log((new Date()).toISOString() + ' ' + 'DynamicLayout_Module: SplendidGrid is null'              );

	let view = await (async () =>
	{
		return eval((Babel.transform(responseText, { presets: ['es2015', 'react', ['stage-0', { decoratorsBeforeExport: true}], ['typescript', { isTSX: true, allExtensions: true }]] })).code);
	})();
	return view;
}

