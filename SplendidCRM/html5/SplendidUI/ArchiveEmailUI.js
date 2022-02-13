/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

var sARCHIVE_MESSAGE_SOURCE = '';
var sARCHIVE_MESSAGE_ID     = null;

function ArchiveEmailUI_PageCommand(sLayoutPanel, sActionsPanel, sCommandName, sCommandArguments)
{
	try
	{
		//alert('ArchiveEmailUI_PageCommand ' + sCommandName);
		if ( sCommandName == 'Source' )
		{
			var divRawMessage = document.getElementById('divRawMessage');
			divRawMessage.className = (divRawMessage.className == 'RawMessage') ? 'RawMessageHidden' : 'RawMessage';
		}
		else if ( sCommandName == 'Cancel' )
		{
			window.close();
		}
		else if ( sCommandName == 'Save' )
		{
			// 09/04/2011 Paul.  Convert selection to an array. 
			var arr = new Array();
			for ( var sID in arrSELECTED )
			{
				var oSelected = arrSELECTED[sID];
				arr.push(oSelected);
			}
			//alert(dumpObj(arr, 'arr'));
			var bgPage = chrome.extension.getBackgroundPage();
			if ( sARCHIVE_MESSAGE_ID == null )
			{
				SplendidError.SystemMessage('Archiving email.');
				bgPage.EmailService_ArchiveEmail(sARCHIVE_MESSAGE_SOURCE, function(status, message)
				{
					if ( status == 1 )
					{
						// 10/19/2011 Paul.  EmailService_ArchiveEmail now returns the result without the d. 
						sARCHIVE_MESSAGE_ID = message.ID;
						bgPage.EmailService_SetEmailRelationships(sARCHIVE_MESSAGE_ID, arr, function(status, message)
						{
							if ( status == 1 )
							{
								SelectionUI_RemoveAll();
								// 10/19/2011 Paul.  EmailService_SetEmailRelationships now returns the result without the d. 
								SplendidError.SystemMessage(message + ' relationship(s) assigned.');
							}
							else
							{
								SplendidError.SystemMessage(message);
							}
						});
					}
					else
					{
						SplendidError.SystemMessage(message);
					}
				});
			}
			else
			{
				bgPage.EmailService_SetEmailRelationships(sARCHIVE_MESSAGE_ID, arr, function(status, message)
				{
					if ( status == 1 )
					{
						SelectionUI_RemoveAll();
						// 10/19/2011 Paul.  EmailService_SetEmailRelationships now returns the result without the d. 
						SplendidError.SystemMessage(message + ' relationship(s) assigned.');
					}
					else
					{
						SplendidError.SystemMessage(message);
					}
				});
			}
		}
		else
		{
			alert(sCommandName + ' is not supported.');
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'ArchiveEmailUI_PageCommand');
	}
}

function ArchiveEmailUI_InitUI(sModule, bValidMessage, row, rowDefaultSearch, callback)
{
		SplendidUI_Init('divMainLayoutPanel', 'divMainActionsPanel', sModule, rowDefaultSearch, function(status, message)
		{
			if ( status == 1 )
			{
				callback(status, '');
			}
			// 09/04/2011 Paul.  Status of 2 means that the globals are done loading. 
			// 10/02/2011 Paul.  Status of 3 means that the globals are done loading. 
			// 11/18/2013 Paul.  Change to status 4 so that only a browser extension will process the event. 
			else if ( status == 4 )
			{
				callback(status, '');
				if ( bValidMessage )
				{
					var oDetailViewUI = new DetailViewUI();
					oDetailViewUI.LoadObject('divArchiveEmail_DetailView', 'divArchiveEmail_Buttons', 'Emails.ArchiveView.Gmail', 'Emails', row, ArchiveEmailUI_PageCommand, function(status, message)
					{
						if ( status == 1 )
						{
							var divSelectionTitle = document.getElementById('divSelectionTitle');
							divSelectionTitle.innerHTML = L10n.Term('Emails.LBL_RELATIONSHIPS');
							var tblMain_CC_ADDRS = document.getElementById('divArchiveEmail_DetailView_ctlDetailView_tblMain_CC_ADDRS');
							if ( tblMain_CC_ADDRS != null && Sql.IsEmptyString(row.CC_ADDRS) )
							{
								tblMain_CC_ADDRS.parentNode.style.display = 'none';
							}
							callback(status, '');
						}
						else
						{
							callback(status, message);
						}
					}, this);
				}
				else
				{
					var divSelection = document.getElementById('divSelection');
					divSelection.style.display = 'none';
					divRawMessage.className = 'RawMessageError';
				}
			}
			else
			{
				callback(status, message);
			}
		});
}

function ArchiveEmailUI_Load(sModule, bValidMessage, sMessageText, callback)
{
	try
	{
		var row = null;
		var rowDefaultSearch = null;
		if ( bValidMessage )
		{
			sARCHIVE_MESSAGE_SOURCE = sMessageText;
			var arrHeaders = parseEmailHeaders(sMessageText);
			//alert(dumpObj(arrHeaders, 'arrHeaders'));
			row = new Object();
			// 10/24/2014 Paul.  The email does not need to be escaped as the DetailView text is now encoded using createTextNode(). 
			row.TO_NAME    = arrHeaders['Delivered-To'];
			row.FROM_ADDR  = arrHeaders['From'        ];
			row.TO_ADDRS   = arrHeaders['To'          ];
			row.CC_ADDRS   = arrHeaders['CC'          ];
			row.DATE_START = arrHeaders['Date'        ];
			row.NAME       = arrHeaders['Subject'     ];
			row.MESSAGE_ID = arrHeaders['Message-ID'  ];
			
			var sHeadersText = geteEmailHeaders(sMessageText);
			var bgPage = chrome.extension.getBackgroundPage();
			// 10/26/2014 Paul.  We need to go back to using the server to parse encoded addresses. 
			bgPage.EmailService_ParseEmail(sHeadersText, function(status, message)
			{
				if ( status == 1 )
				{
					row.NAME      = message.NAME     ;
					row.FROM_ADDR = message.FROM_ADDR;
					row.TO_ADDRS  = message.TO_ADDRS ;
					row.CC_ADDRS  = message.CC_ADDRS ;
				}
				// 04/29/2017 Paul.  Missing IF. 
				else if ( status == -1 )
				{
					SplendidError.SystemMessage('EmailService_ParseEmail: ' + message);
				}
				if ( sModule == 'Contacts' || sModule == 'Leads' )
				{
					var sFrom = row.FROM_ADDR;
					rowDefaultSearch = new Object();
					if ( !Sql.IsEmptyString(sFrom) )
					{
						if ( sFrom.lastIndexOf(' ') >= 0 )
						{
							var sName = sFrom.substring(0, sFrom.lastIndexOf(' '));
							// 11/18/2013 Paul.  Replace all occurrences of the double quote. 
							sName = Trim(sName.replace(/\"/g, ''));
							var arrName = sName.split(' ');
							if ( arrName.length > 0 )
								rowDefaultSearch.FIRST_NAME = '=' + arrName[0];
							if ( arrName.length > 1 )
								rowDefaultSearch.LAST_NAME  = '=' + arrName[arrName.length - 1];
						
							var sEmail = sFrom.substring(sFrom.lastIndexOf(' ')+1);
							sEmail = sEmail.replace('<', '');
							sEmail = sEmail.replace('>', '');
							rowDefaultSearch.EMAIL1 = '=' + sEmail;
						}
						else
						{
							var sEmail = sFrom;
							sEmail = sEmail.replace('<', '');
							sEmail = sEmail.replace('>', '');
							rowDefaultSearch.EMAIL1 = '=' + sEmail;
						}
					}
				}
				ArchiveEmailUI_InitUI(sModule, bValidMessage, row, rowDefaultSearch, callback);
			});
		}
		else
		{
			ArchiveEmailUI_InitUI(sModule, bValidMessage, row, rowDefaultSearch, callback);
		}
	}
	catch(e)
	{
		callback(-1, SplendidError.FormatError(e, 'ArchiveEmailUI_Load'));
	}
}

