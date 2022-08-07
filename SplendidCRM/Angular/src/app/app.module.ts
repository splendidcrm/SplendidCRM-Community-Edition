import { NgModule, NO_ERRORS_SCHEMA          } from '@angular/core'                                      ;
import { CommonModule                        } from '@angular/common'                                    ;
import { BrowserModule                       } from '@angular/platform-browser'                          ;
import { FormsModule                         } from '@angular/forms'                                     ;
import { HttpClientModule                    } from '@angular/common/http'                               ;
import { RouterModule                        } from '@angular/router'                                    ;
import { FontAwesomeModule                   } from '@fortawesome/angular-fontawesome'                   ;
import { NgbConfig, NgbModule                } from '@ng-bootstrap/ng-bootstrap'                         ;
import { NgSelectModule                      } from '@ng-select/ng-select'                               ;

import { AppComponent                        } from './app.component'                                    ;
import { NavMenuComponent                    } from './Themes/NavMenu'                                   ;
import { ArcticTopNavComponent               } from './Themes/Arctic/TopNav'                             ;
import { ArcticModuleDropdown                } from './Themes/Arctic/ModuleDropdown'                     ;
import { ArcticHeaderButtons                 } from './Themes/Arctic/HeaderButtons'                      ;

import { PacificTopNavComponent              } from './Themes/Pacific/TopNav'                            ;
import { PacificModuleDropdown               } from './Themes/Pacific/ModuleDropdown'                    ;
import { PacificHeaderButtons                } from './Themes/Pacific/HeaderButtons'                     ;
import { SubPanelButtonsFactoryComponent     } from './Themes/SubPanelHeaderButtons'                     ;
import { HeaderButtonsFactoryComponent       } from './Themes/HeaderButtonsFactory'                      ;

import { LayoutTabsComponent                 } from './components/LayoutTabs'                            ;
import { DumpSQLComponent                    } from './components/DumpSQL'                               ;
import { DynamicButtonsComponent             } from './components/DynamicButtons'                        ;
import { ProcessButtonsComponent             } from './components/ProcessButtons'                        ;
import { ErrorComponent                      } from './components/ErrorComponent'                        ;
import { ExportHeaderComponent               } from './components/ExportHeader'                          ;
import { ListHeaderComponent                 } from './components/ListHeader'                            ;
import { ModuleHeaderComponent               } from './components/ModuleHeader'                          ;
import { SearchTabsComponent                 } from './components/SearchTabs'                            ;
import { SplendidDynamic_DetailViewComponent } from './components/SplendidDynamic_DetailView'            ;
import { SplendidDynamic_EditViewComponent   } from './components/SplendidDynamic_EditView'              ;
import { SplendidGridComponent               } from './components/SplendidGrid'                          ;
import { AutoCompleteComponent               } from './components/AutoComplete'                          ;

import { DetailViewDynamicField              } from './DetailComponents/DynamicField'                    ;
import { DetailViewBlankComponent            } from './DetailComponents/Blank'                           ;
import { DetailViewCheckBoxComponent         } from './DetailComponents/CheckBox'                        ;
import { DetailViewStringComponent           } from './DetailComponents/String'                          ;
import { DetailViewTextBoxComponent          } from './DetailComponents/TextBox'                         ;
import { DetailViewLineComponent             } from './DetailComponents/Line'                            ;
import { DetailViewHeaderComponent           } from './DetailComponents/Header'                          ;
import { DetailViewImageComponent            } from './DetailComponents/Image'                           ;
import { DetailViewiFrameComponent           } from './DetailComponents/iFrame'                          ;
import { DetailViewModuleLinkComponent       } from './DetailComponents/ModuleLink'                      ;
import { DetailViewHyperLinkComponent        } from './DetailComponents/HyperLink'                       ;
import { DetailViewTagsComponent             } from './DetailComponents/Tags'                            ;
import { DetailViewFileComponent             } from './DetailComponents/File'                            ;
import { DetailViewButtonComponent           } from './DetailComponents/Button'                          ;
import { DetailViewJavaScriptComponent       } from './DetailComponents/JavaScript'                      ;
import { DetailViewUnknownComponent          } from './DetailComponents/Unknown'                         ;

import { EditViewDynamicField                } from './EditComponents/DynamicField'                      ;
import { EditViewTextBoxComponent            } from './EditComponents/TextBox'                           ;
import { EditViewListBoxComponent            } from './EditComponents/ListBox'                           ;
import { EditViewCheckBoxComponent           } from './EditComponents/CheckBox'                          ;
import { EditViewHeaderComponent             } from './EditComponents/Header'                            ;
import { EditViewBlankComponent              } from './EditComponents/Blank'                             ;
import { EditViewHiddenComponent             } from './EditComponents/Hidden'                            ;
import { EditViewLabelComponent              } from './EditComponents/Label'                             ;
import { EditViewSeparatorComponent          } from './EditComponents/Separator'                         ;
import { EditViewspanComponent               } from './EditComponents/Span'                              ;
import { EditViewModulePopupComponent        } from './EditComponents/ModulePopup'                       ;
import { EditViewModuleAutoCompleteComponent } from './EditComponents/ModuleAutoComplete'                ;
import { EditViewUnknownComponent            } from './EditComponents/Unknown'                           ;

import { SplendidGridDefaultHeaderComponent  } from './GridComponents/DefaultHeader'                     ;
import { SplendidGridDynamicColumnComponent  } from './GridComponents/DynamicColumn'                     ;
import { SplendidGridStringComponent         } from './GridComponents/String'                            ;
import { SplendidGridTextBoxComponent        } from './GridComponents/TextBox'                           ;
import { SplendidGridCheckBoxComponent       } from './GridComponents/CheckBox'                          ;
import { SplendidGridCurrencyComponent       } from './GridComponents/Currency'                          ;
import { SplendidGridHiddenComponent         } from './GridComponents/Hidden'                            ;
import { SplendidGridDateTimeComponent       } from './GridComponents/DateTime'                          ;
import { SplendidGridTagsComponent           } from './GridComponents/Tags'                              ;
import { SplendidGridImageComponent          } from './GridComponents/Image'                             ;
import { SplendidGridImageButtonComponent    } from './GridComponents/ImageButton'                       ;
import { SplendidGridHoverComponent          } from './GridComponents/Hover'                             ;
import { SplendidGridJavaImageComponent      } from './GridComponents/JavaImage'                         ;
import { SplendidGridLinkButtonComponent     } from './GridComponents/LinkButton'                        ;
import { SplendidGridHyperLinkComponent      } from './GridComponents/HyperLink'                         ;

import { HomeViewComponent                   } from './views/home-view/HomeView'                         ;
import { ListViewComponent                   } from './views/list-view/ListView'                         ;
import { EditViewComponent                   } from './views/edit-view/EditView'                         ;
import { DetailViewComponent                 } from './views/detail-view/DetailView'                     ;
import { AuditViewComponent                  } from './views/audit-view/AuditView'                       ;
import { ActivitiesPopupViewComponent        } from './views/activities-popup-view/ActivitiesPopupView'  ;
import { DetailViewRelationshipsComponent    } from './views/detail-view-relationships/DetailViewRelationships';
import { DetailViewLineItemsComponent        } from './views/detail-view-line-items/DetailViewLineItems' ;
import { PreviewDashboardComponent           } from './views/preview-dashboard/PreviewDashboard'         ;
import { SearchViewComponent                 } from './views/search-view/SearchView'                     ;
import { MassUpdateComponent                 } from './views/mass-update/MassUpdate'                     ;
import { DynamicMassUpdateComponent          } from './views/dynamic-mass-update/DynamicMassUpdate'      ;
import { DynamicEditViewComponent            } from './views/dynamic-edit-view/DynamicEditView'          ;
import { PopupViewComponent                  } from './views/popup-view/PopupView'                       ;
import { DynamicPopupViewComponent           } from './views/dynamic-popup-view/DynamicPopupView'        ;

import { HelpViewComponent                   } from './views/help-view/HelpView'                         ;
import { LoginViewComponent                  } from './views/login-view/LoginView'                       ;
import { ReloadViewComponent                 } from './views/ReloadView'                                 ;
import { ResetViewComponent                  } from './views/ResetView'                                  ;

@NgModule({
	declarations:
	[
		AppComponent,
		NavMenuComponent,

		ArcticTopNavComponent,
		ArcticModuleDropdown,
		ArcticHeaderButtons,

		PacificTopNavComponent,
		PacificModuleDropdown,
		PacificHeaderButtons,
		SubPanelButtonsFactoryComponent,
		HeaderButtonsFactoryComponent,

		LayoutTabsComponent,
		DumpSQLComponent,
		DynamicButtonsComponent,
		ProcessButtonsComponent,
		ErrorComponent,
		ExportHeaderComponent,
		ListHeaderComponent,
		ModuleHeaderComponent,
		SearchTabsComponent,
		SplendidDynamic_DetailViewComponent,
		SplendidDynamic_EditViewComponent,
		SplendidGridComponent,
		AutoCompleteComponent,

		DetailViewDynamicField,
		DetailViewBlankComponent,
		DetailViewCheckBoxComponent,
		DetailViewStringComponent,
		DetailViewTextBoxComponent,
		DetailViewLineComponent,
		DetailViewHeaderComponent,
		DetailViewImageComponent,
		DetailViewiFrameComponent,
		DetailViewModuleLinkComponent,
		DetailViewHyperLinkComponent,
		DetailViewTagsComponent,
		DetailViewFileComponent,
		DetailViewButtonComponent,
		DetailViewJavaScriptComponent,
		DetailViewUnknownComponent,

		EditViewDynamicField,
		EditViewTextBoxComponent,
		EditViewListBoxComponent,
		EditViewCheckBoxComponent,
		EditViewHeaderComponent,
		EditViewBlankComponent,
		EditViewHiddenComponent,
		EditViewLabelComponent,
		EditViewSeparatorComponent,
		EditViewspanComponent,
		EditViewModulePopupComponent,
		EditViewModuleAutoCompleteComponent,
		EditViewUnknownComponent,

		SplendidGridDefaultHeaderComponent,
		SplendidGridDynamicColumnComponent,
		SplendidGridStringComponent,
		SplendidGridTextBoxComponent,
		SplendidGridCheckBoxComponent,
		SplendidGridCurrencyComponent,
		SplendidGridHiddenComponent,
		SplendidGridDateTimeComponent,
		SplendidGridTagsComponent,
		SplendidGridImageComponent,
		SplendidGridImageButtonComponent,
		SplendidGridHoverComponent,
		SplendidGridJavaImageComponent,
		SplendidGridLinkButtonComponent,
		SplendidGridHyperLinkComponent,

		HomeViewComponent,
		ListViewComponent,
		EditViewComponent,
		DetailViewComponent,
		AuditViewComponent,
		ActivitiesPopupViewComponent,
		DetailViewRelationshipsComponent,
		DetailViewLineItemsComponent,
		PreviewDashboardComponent,
		SearchViewComponent,
		MassUpdateComponent,
		DynamicMassUpdateComponent,
		DynamicEditViewComponent,
		PopupViewComponent,
		DynamicPopupViewComponent,

		HelpViewComponent,
		LoginViewComponent,
		ReloadViewComponent,
		ResetViewComponent,
	],
	imports:
	[
		FontAwesomeModule,
		BrowserModule.withServerTransition({appId: 'ng-cli-universal'}),
		HttpClientModule,
		RouterModule.forRoot(
		[
			{ path: 'login'                , component: LoginViewComponent  },
			{ path: 'Reload'               , component: ReloadViewComponent,
				children:
				[
					{ path: "**", component: ReloadViewComponent }
				]
			},
			{ path: 'Reset'                , component: ResetViewComponent,
				children:
				[
					{ path: "**", component: ResetViewComponent }
				]
			},
			{ path: ':MODULE_NAME/View/:ID', component: DetailViewComponent },
			{ path: ':MODULE_NAME/Edit/:ID', component: EditViewComponent   },
			{ path: ':MODULE_NAME/Edit'    , component: EditViewComponent   },
			{ path: ':MODULE_NAME/List'    , component: ListViewComponent   },
			{ path: ':MODULE_NAME'         , component: ListViewComponent   },
			{ path: '**'                   , component: HomeViewComponent   },
		], { relativeLinkResolution: 'legacy' }),
		FormsModule,
		NgbModule,
		NgSelectModule,
	],
	exports:
	[
		CommonModule
	],
	providers: [],
	bootstrap: [AppComponent],
	//schemas: [ NO_ERRORS_SCHEMA ]
})
export class AppModule
{
	constructor(ngbConfig: NgbConfig)
	{
		// 06/13/2022 Paul.  Disable animations. 
		ngbConfig.animation = false;
	}
}

