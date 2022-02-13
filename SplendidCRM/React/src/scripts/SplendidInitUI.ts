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
// 2. Store and Types. 
// 3. Scripts. 
import SplendidCache                 from '../scripts/SplendidCache';
import { Application_GetReactState, Admin_GetReactState } from '../scripts/Application'  ;
import { UpdateLastAuthenticated }   from '../scripts/Login'        ;
import { UpdateApplicationTheme }    from '../scripts/utility'      ;
// 4. Components and Views. 

// 09/25/2011 Paul.  sIMAGE_SERVER is usually blank, but is used with the HTML5 client. 
let sIMAGE_SERVER        : string  = '';
// 06/24/2017 Paul.  We need a way to turn off bootstrap for BPMN, ReportDesigner and ChatDashboard. 
let bDESKTOP_LAYOUT      : boolean = false;
let sPLATFORM_LAYOUT     : string  = '';
let bGLOBAL_LAYOUT_CACHE : boolean = false;
// 10/24/2014 Paul.  bREMOTE_ENABLED needs to be in the UI page so that it can be quickly accessed by the Formatting functions. 
let bWINDOWS_AUTH        : boolean = false;
let bREMOTE_ENABLED      : boolean = false;
// 12/01/2014 Paul.  We need to distinguish between Offline Client and Mobile Client. 
let bMOBILE_CLIENT       : boolean = false;
// 06/20/2015 Paul.  Provide a way to go directly to the DetailView or EditView of a record. 
let sINIT_MODE           : string  = '';
let sINIT_MODULE         : string  = '';
let sINIT_ID             : string  = '';
// 01/10/2017 Paul.  Add support for ADFS or Azure AD Single Sign on. 
// 04/30/2017 Paul.  Default to Single-Sign-On as disabled. 
let bADFS_SINGLE_SIGN_ON : boolean = false;
let bAZURE_SINGLE_SIGN_ON: boolean = false;
// 0621/2017 Paul.  Change startup module to Home. 
let sSTARTUP_MODULE      : string  = 'Home';
let bIsInitializing      : boolean = false;

export { sIMAGE_SERVER         }
export { bDESKTOP_LAYOUT       }
export { sPLATFORM_LAYOUT      }
export { bGLOBAL_LAYOUT_CACHE  }
export { bWINDOWS_AUTH         }
export { bREMOTE_ENABLED       }
export { bMOBILE_CLIENT        }
export { sINIT_MODE            }
export { sINIT_MODULE          }
export { sINIT_ID              }
export { bADFS_SINGLE_SIGN_ON  }
export { bAZURE_SINGLE_SIGN_ON }
export { sSTARTUP_MODULE       }

export async function SplendidUI_Init(source): Promise<any>
{
	//console.log((new Date()).toISOString() + ' ' + 'SplendidUI_Init', source, window.location.href);
	if ( !SplendidCache.IsInitialized && !bIsInitializing )
	{
		bIsInitializing = true;
		try
		{
			SplendidCache.Reset();
			// 10/19/2020 Paul.  Load Admin state
			if ( window.location.href.indexOf('/Administration/') > 0 )
			{
				await Admin_GetReactState(source);
			}
			else
			{
				await Application_GetReactState(source);
			}
			//console.log((new Date()).toISOString() + ' ' + 'SplendidUI_Init GetReactState Done');
			// 06/23/2019 Paul.  Update last authenticated so that next request will not hit the server. 
			UpdateLastAuthenticated();
			//status = await IsAuthenticated('SplendidUI_Init');
			//console.log((new Date()).toISOString() + ' ' + 'SplendidUI_Init IsAuthenticated', status);
			
			// 09/02/2019 Paul.  After authentication, change the theme to user selected value. 
			UpdateApplicationTheme();
		}
		catch(error)
		{
			console.error((new Date()).toISOString() + ' ' + 'SplendidUI_Init', error);
		}
		bIsInitializing = false;
		SplendidCache.IsInitialized = true;
		//console.log((new Date()).toISOString() + ' ' + 'SplendidUI_Init Done');
	}
	else if ( SplendidCache.IsInitialized )
	{
		//console.log((new Date()).toISOString() + ' ' + 'SplendidUI_Init Already Initialized');
	}
	else if ( bIsInitializing )
	{
		//console.log((new Date()).toISOString() + ' ' + 'SplendidUI_Init is initializing');
	}
	return SplendidCache.IsInitialized;
}

