/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

var nChatInputHeight = 60;

function ChatDashboardUI()
{
	this.CURRENT_CHAT_CHANNEL_ID = getCookie('LastChatChannel');
}

ChatDashboardUI.prototype.Clear = function(sLayoutPanel, sActionsPanel)
{
	try
	{
		SplendidUI_Clear(sLayoutPanel, sActionsPanel);
		SplendidUI_ModuleHeader(sLayoutPanel, sActionsPanel, 'ChatDashboard', L10n.ListTerm('moduleList', 'ChatDashboard'));
		var divChatDashboard = document.createElement('div');
		divChatDashboard.id          = 'divChatDashboard';
		divChatDashboard.style.width = '100%';
		var divMainLayoutPanel = document.getElementById(sLayoutPanel);
		divMainLayoutPanel.appendChild(divChatDashboard);
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'ChatDashboardUI.Clear');
	}
}

ChatDashboardUI.prototype.RenderRow = function(divMessages, row)
{
	try
	{
		var bgPage = chrome.extension.getBackgroundPage();
		var sREMOTE_SERVER = bgPage.RemoteServer();
		var dtDATE_ENTERED = FromJsonDate(row.DATE_ENTERED)
		var sDATE_ENTERED  = formatDate(dtDATE_ENTERED, Security.USER_DATE_FORMAT() + ' ' + Security.USER_TIME_FORMAT());
		
		dtDATE_ENTERED.setHours(0, 0, 0, 0);
		var sDateValueID = 'ChatMessages_Day_' + dtDATE_ENTERED.getTime().toString();
		var divDay = document.getElementById(sDateValueID);
		if ( divDay == null )
		{
			divDay = document.createElement('div');
			divDay.id = sDateValueID;
			// 11/20/2014 Paul.  If firstChild is null, then insertBefore will append to end. 
			divMessages.insertBefore(divDay, divMessages.firstChild);
			var tblDayDivider = document.createElement('table');
			tblDayDivider.border = 0;
			tblDayDivider.style.width = '100%';
			divDay.appendChild(tblDayDivider);
			var tbodyDayDivider = document.createElement('tbody');
			tblDayDivider.appendChild(tbodyDayDivider);
			var trDayDivider = document.createElement('tr');
			tbodyDayDivider.appendChild(trDayDivider);
			
			var tdDayDividerHR = document.createElement('td');
			trDayDivider.appendChild(tdDayDividerHR);
			var hr = document.createElement('hr');
			hr.className = 'ChatMessagesDateRule';
			tdDayDividerHR.appendChild(hr);
			
			var sLAST_DATE = formatDate(dtDATE_ENTERED, L10n.Term('Calendar.LongDatePattern'));
			var tdDayDividerDate = document.createElement('td');
			tdDayDividerDate.style.width = '1px';
			tdDayDividerDate.style.padding = '0 10px';
			tdDayDividerDate.style.whiteSpace = 'nowrap';
			tdDayDividerDate.className = 'ChatMessagesLastDate';
			tdDayDividerDate.appendChild(document.createTextNode(sLAST_DATE));
			trDayDivider.appendChild(tdDayDividerDate);
			
			var tdDayDividerHR = document.createElement('td');
			trDayDivider.appendChild(tdDayDividerHR);
			var hr = document.createElement('hr');
			hr.className = 'ChatMessagesDateRule';
			tdDayDividerHR.appendChild(hr);
		}
		
		var div = document.createElement('div');
		div.className = 'ChatMessagesRow';
		div.id = row.ID;
		if ( divDay.firstChild != null )
			divDay.insertBefore(div, divDay.firstChild.nextSibling);
		else
			divDay.appendChild(div);

		var divPICTURE = document.createElement('div');
		//divPICTURE.className = 'ChatMessagesPicture';
		div.appendChild(divPICTURE);
		var imgPICTURE = document.createElement('img');
		imgPICTURE.className = 'ChatMessagesPicture';
		if ( Sql.IsEmptyString(row.CREATED_BY_PICTURE) )
			imgPICTURE.src = sREMOTE_SERVER + 'Include/images/SplendidCRM_Icon.gif';
		else
			imgPICTURE.src = row.CREATED_BY_PICTURE;
		divPICTURE.appendChild(imgPICTURE);
		
		var divIDENTITY = document.createElement('div');
		divIDENTITY.className = 'ChatMessagesIdentity';
		div.appendChild(divIDENTITY);
		
		var divCREATED_BY = document.createElement('span');
		divCREATED_BY.className = 'ChatMessagesCreatedBy';
		divIDENTITY.appendChild(divCREATED_BY);
		divCREATED_BY.appendChild(document.createTextNode(row.CREATED_BY ));
		
		var divDATE_ENTERED = document.createElement('span');
		divDATE_ENTERED.className = 'ChatMessagesDateEntered';
		divIDENTITY.appendChild(divDATE_ENTERED);
		divDATE_ENTERED.appendChild(document.createTextNode(sDATE_ENTERED  ));
		
		var divPARENT_ID = document.createElement('span');
		divPARENT_ID.className = 'ChatMessagesParent';
		divIDENTITY.appendChild(divPARENT_ID);
		if ( row.PARENT_ID != null )
		{
			var a = document.createElement('a');
			a.href = '../' + row.PARENT_TYPE + '/view.aspx?ID=' + row.PARENT_ID;
			a.appendChild(document.createTextNode(row.PARENT_NAME));
			divPARENT_ID.appendChild(a);
		}
		
		if ( Sql.ToBoolean(row.ATTACHMENT_READY) )
		{
			var divFILENAME = document.createElement('div');
			divFILENAME.id = row.ID + '_FILENAME';
			div.appendChild(divFILENAME);
			
			var aFILENAME = document.createElement('a');
			aFILENAME.href = '../Notes/attachment.aspx?ID=' + row.NOTE_ATTACHMENT_ID;
			aFILENAME.className = 'ChatMessagesFilename';
			aFILENAME.appendChild(document.createTextNode(row.FILENAME));
			divFILENAME.appendChild(aFILENAME);
			
			var sFILE_EXT = row.FILE_EXT.replace('.', '');
			var imgMIME_TYPE = document.createElement('img');
			divFILENAME.appendChild(imgMIME_TYPE);
			imgMIME_TYPE.className = 'ChatMessagesMimeType';
			imgMIME_TYPE.src = sREMOTE_SERVER + 'App_Themes/Atlantic/images/mime-' + sFILE_EXT + '.gif';
			
			var lFILE_SIZE = row.FILE_SIZE;
			var sSIZE_UNITS = 'B';
			if ( lFILE_SIZE > 1024 )
			{
				lFILE_SIZE /= 1024;
				sSIZE_UNITS = 'KB';
				if ( lFILE_SIZE > 1024 )
				{
					lFILE_SIZE /= 1024;
					sSIZE_UNITS = 'MB';
					if ( lFILE_SIZE > 1024 )
					{
						lFILE_SIZE /= 1024;
						sSIZE_UNITS = 'GB';
						if ( lFILE_SIZE > 1024 )
						{
							lFILE_SIZE /= 1024;
							sSIZE_UNITS = 'TB';
						}
					}
				}
			}
			var sFILE_SIZE = Math.floor(lFILE_SIZE).toString() + sSIZE_UNITS;
			var spnFILE_SIZE = document.createElement('span');
			spnFILE_SIZE.className = 'ChatMessagesFileSize';
			spnFILE_SIZE.appendChild(document.createTextNode(sFILE_SIZE));
			divFILENAME.appendChild(spnFILE_SIZE);
			
			var spnFILE_EXT = document.createElement('span');
			spnFILE_EXT.className = 'ChatMessagesFileType';
			spnFILE_EXT.appendChild(document.createTextNode(sFILE_EXT.toUpperCase()));
			divFILENAME.appendChild(spnFILE_EXT);
			
			if ( StartsWith(row.FILE_MIME_TYPE, 'image') )
			{
				var divIMAGE = document.createElement('div');
				divIMAGE.style.display = 'none';
				div.appendChild(divIMAGE);
				var img = document.createElement('img');
				img.id = row.NOTE_ATTACHMENT_ID;
				divIMAGE.appendChild(img);
				// 11/25/2014 Paul.  Differ the get. 
				//img.src = sREMOTE_SERVER + 'Notes/attachment.aspx?ID=' + row.NOTE_ATTACHMENT_ID;
				
				var aMore = document.createElement('a');
				aMore.className = 'ChatMessagesMore';
				aMore.style.display = 'inline';
				aMore.href = '#';
				aMore.appendChild(document.createTextNode(L10n.Term('ChatDashboard.LBL_MORE')));
				divFILENAME.appendChild(aMore);
				var aLess = document.createElement('a');
				aLess.className = 'ChatMessagesLess';
				aLess.style.display = 'none';
				aLess.href = '#';
				aLess.appendChild(document.createTextNode(L10n.Term('ChatDashboard.LBL_LESS')));
				divFILENAME.appendChild(aLess);
				
				aMore.onclick = function()
				{
					aMore.style.display = 'none';
					aLess.style.display = 'inline';
					divIMAGE.style.display = 'inline';
					if ( Sql.IsEmptyString(img.src) )
						img.src = sREMOTE_SERVER + 'Notes/attachment.aspx?ID=' + row.NOTE_ATTACHMENT_ID;
				};
				aLess.onclick = function()
				{
					aMore.style.display = 'inline';
					aLess.style.display = 'none';
					divIMAGE.style.display = 'none';
				};
			}
		}
		
		var divNAME = document.createElement('div');
		divNAME.id = row.ID + '_NAME';
		divNAME.className = 'ChatMessagesDescription';
		div.appendChild(divNAME);
		if ( row.NAME != null )
		{
			divNAME.appendChild(document.createTextNode(row.NAME));
			if ( row.NAME != row.DESCRIPTION )
			{
				var divDESCRIPTION = document.createElement('div');
				divDESCRIPTION.id = row.ID + '_DESCRIPTION';
				divDESCRIPTION.className = 'ChatMessagesDescription';
				divDESCRIPTION.style.display = 'none';
				div.appendChild(divDESCRIPTION);
				divDESCRIPTION.appendChild(document.createTextNode(row.DESCRIPTION));
			
				var aMore = document.createElement('a');
				aMore.className = 'ChatMessagesMore';
				aMore.href = '#';
				aMore.appendChild(document.createTextNode(L10n.Term('ChatDashboard.LBL_MORE')));
				aMore.onclick = function()
				{
					divNAME.style.display = 'none';
					divDESCRIPTION.style.display = 'inline';
				};
				divNAME.appendChild(aMore);
			
				var aLess = document.createElement('a');
				aLess.className = 'ChatMessagesLess';
				aLess.href = '#';
				aLess.appendChild(document.createTextNode(L10n.Term('ChatDashboard.LBL_LESS')));
				aLess.onclick = function()
				{
					divNAME.style.display = 'inline';
					divDESCRIPTION.style.display = 'none';
				};
				divDESCRIPTION.appendChild(aLess);
			}
		}
		
		var divClearFloat = document.createElement('div');
		divClearFloat.className = 'ChatMessagesClearFloat';
		div.appendChild(divClearFloat);
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'ChatDashboardUI.RenderRow');
	}
}

ChatDashboardUI.prototype.LoadChannel = function(sCHAT_CHANNEL_ID, callback)
{
	try
	{
		this.CURRENT_CHAT_CHANNEL_ID = sCHAT_CHANNEL_ID;
		setCookie('LastChatChannel', this.CURRENT_CHAT_CHANNEL_ID);
		var divMessages = document.getElementById('divChatDashboard_divMessages');
		while ( divMessages.childNodes.length > 0 )
		{
			divMessages.removeChild(divMessages.firstChild);
		}

		var sMODULE_NAME     = 'ChatMessages';
		var sSORT_FIELD      = 'DATE_ENTERED';
		var sSORT_DIRECTION  = 'asc';
		var sSELECT_FIELDS   = 'ID, NAME, DESCRIPTION, DATE_ENTERED, PARENT_ID, PARENT_TYPE, PARENT_NAME, CREATED_BY, CREATED_BY_PICTURE, NOTE_ATTACHMENT_ID, FILENAME, FILE_EXT, FILE_MIME_TYPE, FILE_SIZE, ATTACHMENT_READY';
		var sSEARCH_FILTER   = 'CHAT_CHANNEL_ID eq \'' + sCHAT_CHANNEL_ID + '\'';

		var txtSearch = document.getElementById('divChatDashboard_txtSearch');
		if ( txtSearch != null )
		{
			var oSearchBuilder = new SearchBuilder();
			sSEARCH_FILTER += oSearchBuilder.BuildQuery(' and ', 'DESCRIPTION', txtSearch.value);
		}

		var rowSEARCH_VALUES = null;
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.ListView_LoadModule(sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT_FIELDS, sSEARCH_FILTER, rowSEARCH_VALUES, function(status, message)
		{
			if ( status == 1 )
			{
				results = message;
				try
				{
					for ( var i = 0; i < results.length; i++ )
					{
						var row = results[i];
						this.RenderRow(divMessages, row);
					}
				}
				catch(e)
				{
					alert(e.message);
				}
				callback(1, null);
			}
			else
			{
				callback(status, message);
			}
		}, this);
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'ChatDashboardUI.LoadChannel');
	}
}

function ClearFileInput(ctl)
{
	// http://stackoverflow.com/questions/1703228/how-to-clear-file-input-with-javascript
	try
	{
		ctl.value = null;
	}
	catch(e)
	{
	}
	if ( ctl.value )
	{
		var fileUpload = ctl.cloneNode(true)
		ctl.parentNode.replaceChild(fileUpload, ctl);
		// 11/19/2014 Paul.  The onchange event needs to be reset after clone. 
		fileUpload.onchange = FileUploadEvent;
	}
}

function FileUploadEvent()
{
	var files = this.files;
	if ( files.length > 0 )
	{
		var file = files[0];
		if ( file.size > Crm.Config.ToInteger('upload_maxsize') )
		{
			alert('uploaded file was too big: max filesize: ' + Crm.Config.ToInteger('upload_maxsize'));
			var fileUpload = document.getElementById('divChatDashboard_fileUpload');
			ClearFileInput(fileUpload);
			return;
		}
		else //if ( file.type.match(/image.*/) )
		{
			// http://www.javascripture.com/FileReader
			var reader = new FileReader();
			reader.onload = function()
			{
				var arrayBuffer = reader.result;
				var hidUploadNAME = document.getElementById('divChatDashboard_hidUploadNAME');
				var hidUploadTYPE = document.getElementById('divChatDashboard_hidUploadTYPE');
				var hidUploadDATA = document.getElementById('divChatDashboard_hidUploadDATA');
				hidUploadNAME.value = file.name;
				hidUploadTYPE.value = file.type;
				hidUploadDATA.value = base64ArrayBuffer(arrayBuffer);
				//alert(file.name + ' -> ' + file.type);
			};
			reader.readAsArrayBuffer(file);
		}
	}
}

ChatDashboardUI.prototype.Submit = function(context)
{
	try
	{
		var txtMessage     = document.getElementById('divChatDashboard_txtMessage'    );
		var PARENT_TYPE    = document.getElementById('divChatDashboard_PARENT_TYPE'   );
		var PARENT_ID      = document.getElementById('divChatDashboard_PARENT_ID'     );
		var PARENT_NAME    = document.getElementById('divChatDashboard_PARENT_NAME'   );
		var hidUploadNAME  = document.getElementById('divChatDashboard_hidUploadNAME' );
		var hidUploadTYPE  = document.getElementById('divChatDashboard_hidUploadTYPE' );
		var hidUploadDATA  = document.getElementById('divChatDashboard_hidUploadDATA' );
		var lblSubmitError = document.getElementById('divChatDashboard_lblSubmitError');
		lblSubmitError.innerHTML = '';
		var bgPage = chrome.extension.getBackgroundPage();
		if ( hidUploadDATA.value.length > 0 )
		{
			var row = new Object();
			var arrFileParts = hidUploadNAME.value.split('.');
			row.DESCRIPTION    = hidUploadNAME.value;
			row.FILENAME       = hidUploadNAME.value;
			row.FILE_EXT       = arrFileParts[arrFileParts.length - 1];
			row.FILE_MIME_TYPE = hidUploadTYPE.value;
			row.FILE_DATA      = hidUploadDATA.value;
			bgPage.UpdateModuleTable('vwNOTE_ATTACHMENTS', row, null, function(status, message)
			{
				if ( status == 1 )
				{
					var sNOTE_ATTACHMENT_ID = message;
					
					var row = new Object();
					row.CHAT_CHANNEL_ID    = (context||this).CURRENT_CHAT_CHANNEL_ID;
					row.NOTE_ATTACHMENT_ID = sNOTE_ATTACHMENT_ID;
					row.ID                 = null;
					row.NAME               = null;
					row.DESCRIPTION        = txtMessage.value;
					row.PARENT_ID          = null;
					row.PARENT_TYPE        = null;
					if ( PARENT_ID.value.length > 0 )
					{
						row.PARENT_ID       = PARENT_ID.value;
						row.PARENT_TYPE     = PARENT_TYPE.options[PARENT_TYPE.options.selectedIndex].value;
					}
					bgPage.UpdateModule('ChatMessages', row, null, function(status, message)
					{
						if ( status == 1 )
						{
							txtMessage.value  = '';
							PARENT_ID.value   = '';
							PARENT_NAME.value = '';
							if ( hidUploadDATA.value.length > 0 )
							{
								hidUploadNAME.value = '';
								hidUploadTYPE.value = '';
								hidUploadDATA.value = '';
								var fileUpload = document.getElementById('divChatDashboard_fileUpload');
								ClearFileInput(fileUpload);
							}
						}
						else
						{
							lblSubmitError.innerHTML = message;
						}
					}, this);
				}
				else
				{
					lblSubmitError.innerHTML = message;
				}
			}, context||this);
		}
		else
		{
			var row = new Object();
			row.CHAT_CHANNEL_ID    = (context||this).CURRENT_CHAT_CHANNEL_ID;
			row.NOTE_ATTACHMENT_ID = null;
			row.ID                 = null;
			row.NAME               = null;
			row.DESCRIPTION        = txtMessage.value;
			row.PARENT_ID          = null;
			row.PARENT_TYPE        = null;
			if ( PARENT_ID.value.length > 0 )
			{
				row.PARENT_ID       = PARENT_ID.value;
				row.PARENT_TYPE     = PARENT_TYPE.options[PARENT_TYPE.options.selectedIndex].value;
			}
			bgPage.UpdateModule('ChatMessages', row, null, function(status, message)
			{
				if ( status == 1 )
				{
					txtMessage.value  = '';
					PARENT_ID.value   = '';
					PARENT_NAME.value = '';
					if ( hidUploadDATA.value.length > 0 )
					{
						hidUploadNAME.value = '';
						hidUploadTYPE.value = '';
						hidUploadDATA.value = '';
						var fileUpload = document.getElementById('divChatDashboard_fileUpload');
						ClearFileInput(fileUpload);
					}
				}
				else
				{
					lblSubmitError.innerHTML = message;
				}
			}, context||this);
		}
		return false;
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'ChatDashboardUI.Submit');
	}
}

ChatDashboardUI.prototype.Search = function(context)
{
	try
	{
		var sCHAT_CHANNEL_ID = (context||this).CURRENT_CHAT_CHANNEL_ID;
		context.LoadChannel(sCHAT_CHANNEL_ID, function(status, message)
		{
		});
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'ChatDashboardUI.Search');
	}
}

ChatDashboardUI.prototype.Render = function(sLayoutPanel, sActionsPanel, callback, context)
{
	var bgPage = chrome.extension.getBackgroundPage();
	var sREMOTE_SERVER = bgPage.RemoteServer();
	try
	{
		this.Clear(sLayoutPanel, sActionsPanel);
		// 12/06/2014 Paul.  LayoutMode is used on the Mobile view. 
		if ( ctlActiveMenu != null )
			ctlActiveMenu.ActivateTab('ChatDashboard', null, 'ChatDashboardView');
		// 12/02/2014 Paul.  We need to start the connection when the page is loaded on the Mobile Client. 
		if ( bMOBILE_CLIENT )
		{
			$.connection.hub.url = sREMOTE_SERVER + '/signalr';
			SignalR_Connection_Stop();
			SignalR_Connection_Start();
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'ChatDashboardUI.Render SignalR start');
	}
	try
	{
		nChatInputHeight = 60;
		var bIsMobile = isMobileDevice();
		if ( isMobileLandscape() )
			bIsMobile = false;
		// 12/08/2014 Paul.  On mobile, make room for related on a separate line. 
		if ( bIsMobile )
			nChatInputHeight = 80;
		
		var divChatDashboard = document.getElementById('divChatDashboard');
		var tblDashboard = document.createElement('table');
		tblDashboard.style.width  = '100%';
		tblDashboard.style.height = '100%';
		tblDashboard.cellPadding  = 0;
		tblDashboard.cellSpacing  = 0;
		divChatDashboard.appendChild(tblDashboard);
		var tbody = document.createElement('tbody');
		tblDashboard.appendChild(tbody);
		var tr = document.createElement('tr');
		tbody.appendChild(tr);
		var tdChannels = document.createElement('td');
		tdChannels.id = 'divChatDashboard_ChatChannelsCell';
		tdChannels.className = 'ChatChannelsCell';
		if ( bIsMobile )
			tdChannels.style.display = 'none';
		tr.appendChild(tdChannels);
		var tdMessages = document.createElement('td');
		tdMessages.className = 'ChatMessagesCell';
		tr.appendChild(tdMessages);
		var divChannels = document.createElement('div');
		divChannels.id = 'divChatDashboard_divChannels';
		divChannels.className = 'ChatChannelsDiv';
		tdChannels.appendChild(divChannels);
		
		// 12/08/2014 Paul.  Add the search to the top of the messages cell. 
		var divSearch = document.createElement('div');
		divSearch.id = 'divChatDashboard_divSearch';
		tdMessages.appendChild(divSearch);
		var txtSearch = document.createElement('input');
		txtSearch.id        = 'divChatDashboard_txtSearch';
		txtSearch.type      = 'search';
		txtSearch.className = 'ChatInputText';
		divSearch.appendChild(txtSearch);
		var btnSearch = document.createElement('button');
		btnSearch.id    = 'divChatDashboard_btnSearch';
		btnSearch.className = 'ChatInputSubmit';
		btnSearch.innerHTML = L10n.Term('.LBL_SEARCH_BUTTON_LABEL');
		divSearch.appendChild(btnSearch);
		txtSearch.onkeypress = function(e)
		{
			return RegisterEnterKeyPress(e, btnSearch.id);
		};
		// 05/19/2023 Paul.  Need to prevent default, otherwise we get page submit. 
		var self = this;
		btnSearch.onclick = function(e)
		{
			e.preventDefault();
			e.stopPropagation();
			self.Search(self);
		}
		if ( bIsMobile )
		{
			txtSearch.style.marginTop = '3px';
			txtSearch.style.verticalAlign = 'top';
			btnSearch.style.display = 'none';
			var aSearch = document.createElement('a');
			divSearch.appendChild(aSearch);
			var iSearch = document.createElement('i');
			iSearch.className = 'fa fa-2x fa-search navButton';
			aSearch.appendChild(iSearch);
			aSearch.onclick = BindArguments(this.Search, this);
			txtSearch.style.width = ($(tdMessages).width() - $(aSearch).width() - 30).toString() + 'px';
		}
		else
		{
			txtSearch.style.width = ($(tdMessages).width() - $(btnSearch).width()).toString() + 'px';
		}

		var divMessages = document.createElement('div');
		divMessages.id = 'divChatDashboard_divMessages';
		divMessages.className = 'ChatMessagesDiv';
		tdMessages.appendChild(divMessages);
		
		tr = document.createElement('tr');
		tr.style.height = (nChatInputHeight).toString() + 'px';
		tbody.appendChild(tr);
		var tdUser = document.createElement('td');
		tr.appendChild(tdUser);
		tdUser.id = 'divChatDashboard_ChatUserCell';
		tdUser.className = 'ChatUserCell';
		if ( bIsMobile )
			tdUser.style.display = 'none';
		var divUserPicture = document.createElement('div');
		tdUser.appendChild(divUserPicture);
		var imgUserPicture = document.createElement('img');
		imgUserPicture.className = 'ChatUserPicture';
		if ( Sql.IsEmptyString(Security.PICTURE()) )
			imgUserPicture.src = sREMOTE_SERVER + 'Include/images/SplendidCRM_Icon.gif';
		else
			imgUserPicture.src = Security.PICTURE();
		divUserPicture.appendChild(imgUserPicture);
		var divUserName = document.createElement('div');
		divUserName.className = 'ChatUserName';
		divUserName.appendChild(document.createTextNode(Security.USER_NAME()));
		tdUser.appendChild(divUserName);
		
		var tdInput = document.createElement('td');
		tr.appendChild(tdInput);
		tdInput.className = 'ChatInputCell';
		var txtMessage = document.createElement('input');
		txtMessage.id = 'divChatDashboard_txtMessage';
		txtMessage.className = 'ChatInputText';
		tdInput.appendChild(txtMessage);
		var btnSubmit = document.createElement('button');
		btnSubmit.id    = 'divChatDashboard_btnSubmit';
		btnSubmit.className = 'ChatInputSubmit';
		btnSubmit.innerHTML = L10n.Term('.LBL_SUBMIT_BUTTON_LABEL');
		tdInput.appendChild(btnSubmit);
		txtMessage.onkeypress = function(e)
		{
			return RegisterEnterKeyPress(e, btnSubmit.id);
		};
		btnSubmit.onclick = BindArguments(this.Submit, this);
		if ( bIsMobile )
		{
			txtMessage.style.verticalAlign = 'top';
			btnSubmit.style.display = 'none';
			var aSubmit = document.createElement('a');
			tdInput.appendChild(aSubmit);
			var iSubmit = document.createElement('i');
			iSubmit.className = 'fa fa-2x fa-arrow-circle-right navButton';
			aSubmit.appendChild(iSubmit);
			aSubmit.onclick = BindArguments(this.Submit, this);
			txtMessage.style.width = ($(tdMessages).width() - $(iSubmit).width() - 30).toString() + 'px';
		}
		else
		{
			txtMessage.style.width = ($(tdMessages).width() - $(btnSubmit).width()).toString() + 'px';
		}
		
		var divParent = document.createElement('div');
		divParent.id = 'divChatDashboard_divParent';
		divParent.className = 'ChatParentPanel';
		tdInput.appendChild(divParent);

		var spnUpload = document.createElement('span');
		divParent.appendChild(spnUpload);
		var spnUPLOAD_LABEL = document.createElement('span');
		spnUPLOAD_LABEL.className = 'ChatParentLabel';
		spnUPLOAD_LABEL.innerHTML = L10n.Term('ChatMessages.LBL_UPLOAD_FILE');
		spnUpload.appendChild(spnUPLOAD_LABEL);

		var hidUploadNAME  = document.createElement('input');
		hidUploadNAME.id   = 'divChatDashboard_hidUploadNAME';
		hidUploadNAME.type = 'hidden';
		spnUpload.appendChild(hidUploadNAME);
		var hidUploadTYPE  = document.createElement('input');
		hidUploadTYPE.id   = 'divChatDashboard_hidUploadTYPE';
		hidUploadTYPE.type = 'hidden';
		spnUpload.appendChild(hidUploadTYPE);
		var hidUploadDATA  = document.createElement('input');
		hidUploadDATA.id   = 'divChatDashboard_hidUploadDATA';
		hidUploadDATA.type = 'hidden';
		spnUpload.appendChild(hidUploadDATA);
		var fileUpload = document.createElement('input');
		fileUpload.id        = 'divChatDashboard_fileUpload';
		fileUpload.className = 'ChatFileUpload';
		fileUpload.type      = 'file';
		fileUpload.onchange = FileUploadEvent;
		spnUpload.appendChild(fileUpload);
		var btnFileClear = document.createElement('button');
		btnFileClear.className = 'ChatParentClear';
		btnFileClear.innerHTML = L10n.Term('.LBL_CLEAR_BUTTON_LABEL');
		btnFileClear.onclick = function()
		{
			var hidUploadNAME = document.getElementById('divChatDashboard_hidUploadNAME');
			var hidUploadTYPE = document.getElementById('divChatDashboard_hidUploadTYPE');
			var hidUploadDATA = document.getElementById('divChatDashboard_hidUploadDATA');
			var fileUpload    = document.getElementById('divChatDashboard_fileUpload'   );
			hidUploadNAME.value = '';
			hidUploadTYPE.value = '';
			hidUploadDATA.value = '';
			ClearFileInput(fileUpload);
			return false;
		};
		spnUpload.appendChild(btnFileClear);
		if ( bIsMobile )
		{
			fileUpload.style.verticalAlign = 'top';
			btnFileClear.style.display = 'none';
			// 12/14/2014 Paul.  Can't seem to set the size of the file input on iPhone 4.  Hide the label instead. 
			spnUPLOAD_LABEL.style.display = 'none';
			var aFileClear = document.createElement('a');
			spnUpload.appendChild(aFileClear);
			var iFileClear = document.createElement('i');
			iFileClear.className = 'fa fa-2x fa-remove navButton';
			aFileClear.appendChild(iFileClear);
			aFileClear.onclick = function()
			{
				btnFileClear.click();
			};
			fileUpload.style.width = ($(tdMessages).width() - $(aFileClear).width() - 13).toString() + 'px';
		}

		// 12/08/2014 Paul.  On a mobile device, move related to a new line. 
		if ( bIsMobile )
		{
			divParent = document.createElement('div');
			divParent.className = 'ChatParentPanel';
			tdInput.appendChild(divParent);
		}

		var spnRelatedType = document.createElement('span');
		divParent.appendChild(spnRelatedType);
		var spnPARENT_LABEL = document.createElement('span');
		spnPARENT_LABEL.className = 'ChatParentLabel';
		spnPARENT_LABEL.innerHTML = L10n.Term('ChatMessages.LBL_PARENT_NAME');
		spnRelatedType.appendChild(spnPARENT_LABEL);
		var PARENT_TYPE = document.createElement('select');
		PARENT_TYPE.id = 'divChatDashboard_PARENT_TYPE';
		PARENT_TYPE.className = 'ChatParentType';
		spnRelatedType.appendChild(PARENT_TYPE);
		var arrRecordTypes = L10n.GetList('record_type_display');
		for ( var iType in arrRecordTypes )
		{
			var opt = document.createElement('option');
			opt.value = arrRecordTypes[iType];
			opt.text  = L10n.Term('.record_type_display.' + arrRecordTypes[iType]);
			PARENT_TYPE.add(opt);
		}
		PARENT_TYPE.onchange = function()
		{
			var PARENT_ID   = document.getElementById('divChatDashboard_PARENT_ID'  );
			var PARENT_NAME = document.getElementById('divChatDashboard_PARENT_NAME');
			PARENT_ID.value   = '';
			PARENT_NAME.value = '';
		};
		var PARENT_ID = document.createElement('input');
		PARENT_ID.id = 'divChatDashboard_PARENT_ID';
		PARENT_ID.type = 'hidden';
		divParent.appendChild(PARENT_ID);
		var PARENT_NAME = document.createElement('input');
		PARENT_NAME.id = 'divChatDashboard_PARENT_NAME';
		PARENT_NAME.className = 'ChatParentName';
		PARENT_NAME.disabled = 'disabled';
		PARENT_NAME.style.width = '10px';
		//PARENT_NAME.readonly = true;
		divParent.appendChild(PARENT_NAME);
		var btnParentSelect = document.createElement('button');
		btnParentSelect.className = 'ChatParentSelect';
		btnParentSelect.innerHTML = L10n.Term('.LBL_SELECT_BUTTON_LABEL');
		btnParentSelect.onclick = BindArguments(function(PARENT_TYPE, PARENT_NAME, PARENT_ID)
		{
			// 01/18/2015 Paul.  Catch dialog creation errors. 
			try
			{
				var sPOPUP_TITLE = '';
				var sMODULE_TYPE = PARENT_TYPE.options[PARENT_TYPE.options.selectedIndex].value;
				// 01/18/2015 Paul.  LBL_LIST_FORM_TITLE might not be defined. 
				if ( L10n.Term(sMODULE_TYPE + '.LBL_LIST_FORM_TITLE') == sMODULE_TYPE + '.LBL_LIST_FORM_TITLE' )
					sPOPUP_TITLE = L10n.Term('.record_type_display.' + sMODULE_TYPE);
				else
					sPOPUP_TITLE = L10n.Term(sMODULE_TYPE + '.LBL_LIST_FORM_TITLE');

				var $dialog = $('<div id="' + PARENT_ID.id + '_divPopup"><div id="divPopupActionsPanel" /><div id="divPopupLayoutPanel" /></div>');
				$dialog.dialog(
				{
					  modal    : true
					, resizable: true
					// 04/13/2017 Paul.  Use Bootstrap for responsive design.
					, position : { of: '#divMainPageContent' }
					, width    : $('#divMainPageContent').width() > 0 ? ($('#divMainPageContent').width() - 60) : 800
					// 04/26/2017 Paul.  Use Bootstrap for responsive design.
					//, height   : (navigator.userAgent.indexOf('iPad') > 0 ? 'auto' : ($(window).height() > 0 ? $(window).height() - 60 : 800))
					, height   : $('#divMainPageContent').height() > 0 ? $('#divMainPageContent').height() - 60 : 800
					, title    : sPOPUP_TITLE
					, create   : function(event, ui)
					{
						try
						{
							var oPopupViewUI = new PopupViewUI();
							oPopupViewUI.Load('divPopupLayoutPanel', 'divPopupActionsPanel', sMODULE_TYPE, false, function(status, message)
							{
								if ( status == 1 )
								{
									PARENT_ID.value   = message.ID  ;
									PARENT_NAME.value = message.NAME;
									// 02/21/2013 Paul.  Use close instead of destroy. 
									$dialog.dialog('close');
								}
								else if ( status == -2 )
								{
									// 02/21/2013 Paul.  Use close instead of destroy. 
									$dialog.dialog('close');
								}
								else if ( status == -1 )
								{
									SplendidError.SystemMessage(message);
								}
							});
						}
						catch(e)
						{
							// 01/18/2015 Paul.  SplendidError.SystemError() was not supported on ASPX version of ChatDashboard. It is now, but alert is better. 
							SplendidError.SystemAlert(e, 'PopupViewUI dialog');
						}
					}
					, close    : function(event, ui)
					{
						$dialog.dialog('destroy');
						// 10/17/2011 Paul.  We have to remove the new HTML, otherwise there will be multiple definitions for divPopupLayoutPanel. 
						var divPopup = document.getElementById(PARENT_ID.id + '_divPopup');
						if ( divPopup != null )
							divPopup.parentNode.removeChild(divPopup);
					}
				});
			}
			catch(e)
			{
				SplendidError.SystemAlert(e, 'ChatDashboardUI.Related Select');
			}
			return false;
		}, PARENT_TYPE, PARENT_NAME, PARENT_ID);


		divParent.appendChild(btnParentSelect);
		var aParentSelect = null;
		if ( bIsMobile )
		{
			btnParentSelect.style.display = 'none';
			aParentSelect = document.createElement('a');
			divParent.appendChild(aParentSelect);
			var iParentSelect = document.createElement('i');
			iParentSelect.className = 'fa fa-2x fa-location-arrow navButton';
			aParentSelect.style.verticalAlign = 'bottom';
			// 02/25/2016 Paul.  Use pointer cursor. 
			aParentSelect.style.cursor = 'pointer';
			aParentSelect.appendChild(iParentSelect);
			aParentSelect.onclick = function()
			{
				btnParentSelect.click();
			};
			PARENT_NAME.onclick = function()
			{
				btnParentSelect.click();
			};
		}

		var btnParentClear = document.createElement('button');
		btnParentClear.className = 'ChatParentClear';
		btnParentClear.innerHTML = L10n.Term('.LBL_CLEAR_BUTTON_LABEL');
		btnParentClear.onclick = function()
		{
			var PARENT_ID   = document.getElementById('divChatDashboard_PARENT_ID'  );
			var PARENT_NAME = document.getElementById('divChatDashboard_PARENT_NAME');
			PARENT_ID.value   = '';
			PARENT_NAME.value = '';
			return false;
		};
		divParent.appendChild(btnParentClear);
		if ( bIsMobile )
		{
			btnParentClear.style.display = 'none';
			var aParentClear = document.createElement('a');
			divParent.appendChild(aParentClear);
			var iParentClear = document.createElement('i');
			iParentClear.className = 'fa fa-2x fa-remove navButton';
			aParentClear.style.verticalAlign = 'bottom';
			// 02/25/2016 Paul.  Use pointer cursor. 
			aParentClear.style.cursor = 'pointer';
			aParentClear.appendChild(iParentClear);
			aParentClear.onclick = function()
			{
				btnParentClear.click();
			};
			PARENT_NAME.style.width = ($(tdMessages).width() - $(spnRelatedType).width() - $(aParentSelect).width() - $(aParentClear).width() - 13).toString() + 'px';
		}
		else
		{
			PARENT_NAME.style.width = ($(tdMessages).width() - $(spnUpload).width() - $(spnRelatedType).width() - $(btnParentSelect).width() - $(btnParentClear).width() - 57).toString() + 'px';
		}

		var spnSubmitError = document.createElement('span');
		spnSubmitError.id = 'divChatDashboard_lblSubmitError';
		spnSubmitError.className = 'error';
		divParent.appendChild(spnSubmitError);
		DashboardResize();

		var sMODULE_NAME     = 'ChatChannels';
		var sSORT_FIELD      = 'NAME';
		var sSORT_DIRECTION  = 'asc';
		var sSELECT_FIELDS   = 'ID, NAME, PARENT_ID, PARENT_TYPE, PARENT_NAME';
		var sSEARCH_FILTER   = '';
		var rowSEARCH_VALUES = null;
		var bgPage = chrome.extension.getBackgroundPage();
		bgPage.ListView_LoadModule(sMODULE_NAME, sSORT_FIELD, sSORT_DIRECTION, sSELECT_FIELDS, sSEARCH_FILTER, rowSEARCH_VALUES, function(status, message)
		{
			if ( status == 1 )
			{
				var results = message;
				this.CURRENT_CHAT_CHANNEL_ID = getCookie('LastChatChannel');
				for ( var i = 0; i < results.length; i++ )
				{
					var div = document.createElement('div');
					divChannels.appendChild(div);
					div.className  = 'ChatChannelsInactive';
					div.id         = results[i].ID;
					div.appendChild(document.createTextNode(results[i].NAME));
					if ( Sql.IsEmptyString(this.CURRENT_CHAT_CHANNEL_ID) )
					{
						this.CURRENT_CHAT_CHANNEL_ID = results[i].ID;
						// 11/25/2014 Paul.  If the current value is not set, the nwe have to update the cookie. 
						setCookie('LastChatChannel', this.CURRENT_CHAT_CHANNEL_ID);
					}
					
					if ( this.CURRENT_CHAT_CHANNEL_ID == results[i].ID )
					{
						div.className = 'ChatChannelsActive';
						if ( bIsMobile )
						{
							var spnChatChannel   = document.getElementById('ctlAtlanticToolbar_spnChatChannel'  );
							var aNavChatChannels = document.getElementById('ctlAtlanticToolbar_aNavChatChannels');
							if ( spnChatChannel != null && aNavChatChannels != null )
							{
								spnChatChannel.style.display = 'inline';
								aNavChatChannels.style.display = 'inline';
								while ( spnChatChannel.childNodes != null && spnChatChannel.childNodes.length > 0 )
								{
									spnChatChannel.removeChild(spnChatChannel.firstChild);
								}
								spnChatChannel.appendChild(document.createTextNode(results[i].NAME));
							}
						}
					}
					div.onclick = BindArguments(function(sCHAT_CHANNEL_ID, context)
					{
						var divLastChatChannel = document.getElementById(context.CURRENT_CHAT_CHANNEL_ID);
						divLastChatChannel.className = 'ChatChannelsInactive';
						context.CURRENT_CHAT_CHANNEL_ID = sCHAT_CHANNEL_ID;
						divLastChatChannel = document.getElementById(context.CURRENT_CHAT_CHANNEL_ID);
						divLastChatChannel.className = 'ChatChannelsActive';
						setCookie('LastChatChannel', sCHAT_CHANNEL_ID);
						context.LoadChannel(sCHAT_CHANNEL_ID, function(status, message)
						{
						});
					}, results[i].ID, this);
				}
				if ( bIsMobile )
				{
					var spnChatChannel   = document.getElementById('ctlAtlanticToolbar_spnChatChannel'  );
					var aNavChatChannels = document.getElementById('ctlAtlanticToolbar_aNavChatChannels');
					var iNavChatChannels = document.getElementById('ctlAtlanticToolbar_iNavChatChannels');
					if ( aNavChatChannels != null && iNavChatChannels != null )
					{
						var menu = new Array();
						var options =
						{ triggerOn    : 'click'
						, displayAround: 'trigger'
						, sizeStyle    : 'content'
						, mouseClick   : 'left'
						, left         : 0
						, top          : $(iNavChatChannels).height()
						, position     : 'bottom'
						, containment  : '#' + aNavChatChannels.id
						};
						for ( var i = 0; i < results.length; i++ )
						{
							var item = new Object();
							item.name  = results[i].NAME;
							item.title = results[i].NAME;
							item.fun   = BindArguments(function(sCHAT_CHANNEL_ID, sCHAT_CHANNEL_NAME, context)
							{
								context.LoadChannel(sCHAT_CHANNEL_ID, function(status, message)
								{
								});
								while ( spnChatChannel.childNodes != null && spnChatChannel.childNodes.length > 0 )
								{
									spnChatChannel.removeChild(spnChatChannel.firstChild);
								}
								spnChatChannel.appendChild(document.createTextNode(sCHAT_CHANNEL_NAME));
							}, results[i].ID, results[i].NAME, this);
							menu.push(item);
						}
						$(iNavChatChannels).contextMenu('menu', menu, options);
					}
				}

				if ( !Sql.IsEmptyString(this.CURRENT_CHAT_CHANNEL_ID) )
				{
					this.LoadChannel(this.CURRENT_CHAT_CHANNEL_ID, callback);
				}
				else
				{
					callback(1, null);
				}
			}
			else
			{
				callback(status, message);
			}
		}, this);

		// 11/24/2014 Paul.  We don't have an easy way to disable the resize event, so code it carefully. 
		$(window).resize(DashboardResize);
		//$(window).off("resize", DashboardResize);
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'ChatDashboardUI.Render');
	}
}

function DashboardResize()
{
	try
	{
		var divChatDashboard = document.getElementById('divChatDashboard');
		if ( divChatDashboard != null )
		{
			var rect = divChatDashboard.getBoundingClientRect();
			var nHeight = $(window).height() - rect.top;
			// 05/08/2017 Paul.  Make space for Bootstrap header. 
			if ( SplendidDynamic.BootstrapLayout() && $('#divMainPageContent').height() > 0 )
				nHeight = $('#divMainPageContent').height() - rect.top;
			
			var divFooterCopyright = document.getElementById('divFooterCopyright');
			if ( divFooterCopyright != null )
			{
				rect = divFooterCopyright.getBoundingClientRect();
				nHeight -= (rect.bottom - rect.top) + 8;
			}
			divChatDashboard.style.height = nHeight.toString() + 'px';

			nHeight -= nChatInputHeight;
			var nSearchHeight = 0;
			var divChannels = document.getElementById('divChatDashboard_divChannels');
			var divMessages = document.getElementById('divChatDashboard_divMessages');
			var divSearch   = document.getElementById('divChatDashboard_divSearch'  );
			if ( divSearch )
				nSearchHeight = $(divSearch).height();
			if ( divChannels )
				divChannels.style.height = nHeight.toString() + 'px';
			if ( divMessages )
				divMessages.style.height = (nHeight - nSearchHeight).toString() + 'px';
		}
	}
	catch(e)
	{
		SplendidError.SystemAlert(e, 'DashboardResize');
	}
}

// 11/25/2014 Paul.  There is no reason to have the Chat hub code in a file separate from ChatDashboardUI.js. 
// 09/28/2018 Paul.  ChatManagerHub may not be defined. 
if ( $.connection !== undefined )
{
	var chatManager = $.connection.ChatManagerHub;

	chatManager.client.newMessage = function(gCHAT_CHANNEL_ID, gID, sNAME, sDESCRIPTION, sDATE_ENTERED, gPARENT_ID, sPARENT_TYPE, sPARENT_NAME, gCREATED_BY_ID, sCREATED_BY, sCREATED_BY_PICTURE, gNOTE_ATTACHMENT_ID, sFILENAME, sFILE_EXT, sFILE_MIME_TYPE, lFILE_SIZE, bATTACHMENT_READY)
	{
		try
		{
			var oChatDashboardUI = new ChatDashboardUI();
			if ( gCHAT_CHANNEL_ID == oChatDashboardUI.CURRENT_CHAT_CHANNEL_ID )
			{
				var row = new Object();
				row.CHAT_CHANNEL_ID    = gCHAT_CHANNEL_ID   ;
				row.ID                 = gID                ;
				row.NAME               = sNAME              ;
				row.DESCRIPTION        = sDESCRIPTION       ;
				row.DATE_ENTERED       = sDATE_ENTERED      ;
				row.CREATED_BY_ID      = gCREATED_BY_ID     ;
				row.CREATED_BY         = sCREATED_BY        ;
				row.CREATED_BY_PICTURE = sCREATED_BY_PICTURE;
				row.PARENT_ID          = gPARENT_ID         ;
				row.PARENT_TYPE        = sPARENT_TYPE       ;
				row.PARENT_NAME        = sPARENT_NAME       ;
				row.NOTE_ATTACHMENT_ID = gNOTE_ATTACHMENT_ID;
				row.FILENAME           = sFILENAME          ;
				row.FILE_EXT           = sFILE_EXT          ;
				row.FILE_MIME_TYPE     = sFILE_MIME_TYPE    ;
				row.FILE_SIZE          = lFILE_SIZE         ;
				row.ATTACHMENT_READY   = bATTACHMENT_READY  ;
			
				var divMessages = document.getElementById('divChatDashboard_divMessages');
				if ( divMessages != null )
					oChatDashboardUI.RenderRow(divMessages, row);
			}
		}
		catch(e)
		{
			SplendidError.SystemAlert(e, 'ChatDashboardUI.newMessage');
		}
	};

}
