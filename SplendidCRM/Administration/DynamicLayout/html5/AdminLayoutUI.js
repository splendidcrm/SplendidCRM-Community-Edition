/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

var nFieldListWidth = 200;

function zTree_BuildAdminLayoutModuleNodes(message)
{
	var zNodes = new Array();
	var oGlobal = new Object();
	oGlobal.name        = L10n.Term('DynamicLayout.LBL_GLOBAL');
	oGlobal.open        = false;
	oGlobal.chkDisabled = true;
	oGlobal.children    = new Array();
	zNodes.push(oGlobal);
	var oModules = new Object();
	oModules.name        = L10n.Term('DynamicLayout.LBL_USER_MODULES');
	oModules.open        = true;
	oModules.chkDisabled = true;
	oModules.children    = new Array();
	zNodes.push(oModules);
	var oAdminModules = new Object();
	oAdminModules.name        = L10n.Term('DynamicLayout.LBL_ADMIN_MODULES');
	oAdminModules.open        = false;
	oAdminModules.chkDisabled = true;
	oAdminModules.children    = new Array();
	zNodes.push(oAdminModules);
	if ( message instanceof Array )
	{
		// 07/05/2016 Paul.  arrModules is a local variable. 
		var arrModules = message;
		for ( var i = 0; i < arrModules.length; i++ )
		{
			var module = arrModules[i];
			var oModuleNode        = new Object();
			oModuleNode.name       = module.DisplayName;
			oModuleNode.open       = false;
			oModuleNode.ModuleName = module.ModuleName;
			if ( Sql.ToBoolean(module.IsAdmin) )
				oAdminModules.children.push(oModuleNode);
			else if ( Sql.IsEmptyString(module.ModuleName) )
				oModuleNode = oGlobal;
			else
				oModules.children.push(oModuleNode);
			if ( module.DetailViews !== undefined && module.DetailViews instanceof Array && module.DetailViews.length > 0 )
			{
				if ( oModuleNode.children == null )
					oModuleNode.children = new Array();
				var oDetailView = new Object();
				oDetailView.name     = L10n.Term('DynamicLayout.LBL_DETAIL_VIEWS');
				oDetailView.children = new Array();
				oModuleNode.children.push(oDetailView);
				for ( var j = 0; j < module.DetailViews.length; j++ )
				{
					var view = module.DetailViews[j];
					var oViewNode = new Object();
					oViewNode.name       = view.DisplayName ;
					oViewNode.ModuleName = module.ModuleName;
					oViewNode.ViewName   = view.ViewName    ;
					oViewNode.LayoutType = view.LayoutType  ;
					oDetailView.children.push(oViewNode);
				}
			}
			if ( module.EditViews !== undefined && module.EditViews instanceof Array && module.EditViews.length > 0 )
			{
				if ( oModuleNode.children == null )
					oModuleNode.children = new Array();
				var oEditView = new Object();
				oEditView.name     = L10n.Term('DynamicLayout.LBL_EDIT_VIEWS');
				oEditView.children = new Array();
				oModuleNode.children.push(oEditView);
				for ( var j = 0; j < module.EditViews.length; j++ )
				{
					var view = module.EditViews[j];
					var oViewNode = new Object();
					oViewNode.name       = view.DisplayName ;
					oViewNode.ModuleName = module.ModuleName;
					oViewNode.ViewName   = view.ViewName    ;
					oViewNode.LayoutType = view.LayoutType  ;
					oEditView.children.push(oViewNode);
				}
			}
			if ( module.Search !== undefined && module.Search instanceof Array && module.Search.length > 0 )
			{
				if ( oModuleNode.children == null )
					oModuleNode.children = new Array();
				var oEditView = new Object();
				oEditView.name     = L10n.Term('DynamicLayout.LBL_SEARCH_EDIT_VIEWS');
				oEditView.children = new Array();
				oModuleNode.children.push(oEditView);
				for ( var j = 0; j < module.Search.length; j++ )
				{
					var view = module.Search[j];
					var oViewNode = new Object();
					oViewNode.name       = view.DisplayName ;
					oViewNode.ModuleName = module.ModuleName;
					oViewNode.ViewName   = view.ViewName    ;
					oViewNode.LayoutType = view.LayoutType  ;
					oEditView.children.push(oViewNode);
				}
			}
			if ( module.ListViews !== undefined && module.ListViews instanceof Array && module.ListViews.length > 0 )
			{
				if ( oModuleNode.children == null )
					oModuleNode.children = new Array();
				var oListView = new Object();
				oListView.name     = L10n.Term('DynamicLayout.LBL_GRID_VIEWS');
				oListView.children = new Array();
				oModuleNode.children.push(oListView);
				for ( var j = 0; j < module.ListViews.length; j++ )
				{
					var view = module.ListViews[j];
					var oViewNode = new Object();
					oViewNode.name       = view.DisplayName ;
					oViewNode.ModuleName = module.ModuleName;
					oViewNode.ViewName   = view.ViewName    ;
					oViewNode.LayoutType = view.LayoutType  ;
					oListView.children.push(oViewNode);
				}
			}
			if ( module.SubPanels !== undefined && module.SubPanels instanceof Array && module.SubPanels.length > 0 )
			{
				if ( oModuleNode.children == null )
					oModuleNode.children = new Array();
				var oListView = new Object();
				oListView.name     = L10n.Term('DynamicLayout.LBL_SUBPANEL_GRID_VIEWS');
				oListView.children = new Array();
				oModuleNode.children.push(oListView);
				for ( var j = 0; j < module.SubPanels.length; j++ )
				{
					var view = module.SubPanels[j];
					var oViewNode = new Object();
					oViewNode.name       = view.DisplayName ;
					oViewNode.ModuleName = module.ModuleName;
					oViewNode.ViewName   = view.ViewName    ;
					oViewNode.LayoutType = view.LayoutType  ;
					oListView.children.push(oViewNode);
				}
			}
			if ( module.Relationships !== undefined && module.Relationships instanceof Array && module.Relationships.length > 0 )
			{
				if ( oModuleNode.children == null )
					oModuleNode.children = new Array();
				var oRelationshipView = new Object();
				oRelationshipView.name     = L10n.Term('DynamicLayout.LBL_SUBPANEL_RELATIONSHIPS');
				oRelationshipView.children = new Array();
				oModuleNode.children.push(oRelationshipView);
				for ( var j = 0; j < module.Relationships.length; j++ )
				{
					var view = module.Relationships[j];
					var oViewNode = new Object();
					oViewNode.name       = view.DisplayName ;
					oViewNode.ModuleName = module.ModuleName;
					oViewNode.ViewName   = view.ViewName    ;
					oViewNode.LayoutType = view.LayoutType  ;
					oRelationshipView.children.push(oViewNode);
				}
			}
			if ( module.Terminology !== undefined && module.Terminology instanceof Array && module.Terminology.length > 0 )
			{
				if ( oModuleNode.children == null )
					oModuleNode.children = new Array();
				var oTerminologyView = new Object();
				oTerminologyView.name     = L10n.Term('DynamicLayout.LBL_TERMINOLOGY');
				oTerminologyView.children = new Array();
				oModuleNode.children.push(oTerminologyView);
				for ( var j = 0; j < module.Terminology.length; j++ )
				{
					var view = module.Terminology[j];
					var oViewNode = new Object();
					oViewNode.name       = view.DisplayName ;
					oViewNode.ModuleName = module.ModuleName;
					oViewNode.ViewName   = view.ViewName    ;
					oViewNode.LayoutType = view.LayoutType  ;
					oTerminologyView.children.push(oViewNode);
				}
			}
		}
	}
	return zNodes;
}

function zTree_AdminLayoutOnClick(event, treeId, treeNode)
{
	SplendidError.SystemMessage('');
	if ( treeNode.LayoutType == 'EditView' )
	{
		var layout = new LayoutEditViewUI();
		layout.MODULE_NAME = treeNode.ModuleName;
		layout.EDIT_NAME   = treeNode.ViewName  ;
		layout.Load();
	}
	else if ( treeNode.LayoutType == 'DetailView' )
	{
		var layout = new LayoutDetailViewUI();
		layout.MODULE_NAME = treeNode.ModuleName;
		layout.DETAIL_NAME = treeNode.ViewName  ;
		layout.Load();
	}
	else if ( treeNode.LayoutType == 'ListView' )
	{
		var layout = new LayoutListViewUI();
		layout.MODULE_NAME = treeNode.ModuleName;
		layout.GRID_NAME = treeNode.ViewName  ;
		layout.Load();
	}
	else if ( treeNode.LayoutType == 'DetailViewRelationship' )
	{
		var layout = new LayoutDetailViewRelationshipUI();
		layout.MODULE_NAME = treeNode.ModuleName;
		layout.DETAIL_NAME = treeNode.ViewName  ;
		layout.Load();
	}
	else if ( treeNode.LayoutType == 'EditViewRelationship' )
	{
		var layout = new LayoutEditViewRelationshipUI();
		layout.MODULE_NAME = treeNode.ModuleName;
		layout.EDIT_NAME   = treeNode.ViewName  ;
		layout.Load();
	}
	else if ( treeNode.LayoutType == 'Terminology' )
	{
		var layout = new LayoutTerminologyUI();
		layout.MODULE_NAME = treeNode.ModuleName;
		layout.LANG        = treeNode.ViewName  ;
		layout.Load();
	}
	else
	{
		// 02/20/2016 Paul.  Do nothing of click on other node.  Don't warn either. 
	}
}

function AdminLayoutResize()
{
	try
	{
		var tblLayoutFrame = document.getElementById('tblLayoutFrame');
		var rect = tblLayoutFrame.getBoundingClientRect();
		var nHeight = $(window).height() - rect.top;
		nHeight -= 42;
		tblLayoutFrame.style.height = nHeight.toString() + 'px';
		
		// 02/14/2016 Paul.  IE10 is not honoring the bounds of the layout frame. 
		var divTreeModulesFrame = document.getElementById('divTreeModulesFrame');
		var divFieldListFrame   = document.getElementById('divFieldListFrame'  );
		var tblLayoutTableFrame = document.getElementById('tblLayoutTableFrame');
		var tblPropertiesFrame  = document.getElementById('tblPropertiesFrame' );
		divTreeModulesFrame.style.height = (nHeight - 12) + 'px';
		divFieldListFrame.style.height   = (nHeight - 22) + 'px';
		tblLayoutTableFrame.style.height = (nHeight - 22) + 'px';
		tblPropertiesFrame.style.height  = (nHeight - 22) + 'px';
	}
	catch(e)
	{
		alert(e.message);
	}
}

function AdminLayoutClear()
{
	var tdLayoutFrameFieldList  = document.getElementById('tdLayoutFrameFieldList' );
	tdLayoutFrameFieldList.style.display = '';
	var tdLayoutFrameProperties = document.getElementById('tdLayoutFrameProperties');
	tdLayoutFrameProperties.style.display = '';
	var tdLayoutFrameLayout = document.getElementById('tdLayoutFrameLayout');
	tdLayoutFrameLayout.width = 550;

	var divFieldList = document.getElementById('divFieldList');
	while ( divFieldList.childNodes.length > 0 )
	{
		divFieldList.removeChild(divFieldList.firstChild);
	}
	var divLayoutButtons = document.getElementById('divLayoutButtons');
	while ( divLayoutButtons.childNodes.length > 0 )
	{
		divLayoutButtons.removeChild(divLayoutButtons.firstChild);
	}
	var tblLayout = document.getElementById('tblLayout');
	while ( tblLayout.childNodes.length > 0 )
	{
		tblLayout.removeChild(tblLayout.firstChild);
	}
	var divPropertiesButtons = document.getElementById('divPropertiesButtons');
	while ( divPropertiesButtons.childNodes.length > 0 )
	{
		divPropertiesButtons.removeChild(divPropertiesButtons.firstChild);
	}
	var tblProperties = document.getElementById('tblProperties');
	while ( tblProperties.childNodes.length > 0 )
	{
		tblProperties.removeChild(tblProperties.firstChild);
	}
	var tblEvents = document.getElementById('tblEvents');
	while ( tblEvents.childNodes.length > 0 )
	{
		tblEvents.removeChild(tblEvents.firstChild);
	}
	// 05/04/2016 Paul.  Error moved to header line for more space. 
	var divLayoutError = document.getElementById('divLayoutError');
	if ( divLayoutError != null )
	{
		$(divLayoutError).text('');
	}
}

var sRULE_CHANGE_NAME = null;
var sRULE_CHANGE_ID   = null;

function ChangeBusinessRule(sPARENT_ID, sPARENT_NAME)
{
	var fldRULE_CHANGE_NAME = document.getElementById(sRULE_CHANGE_NAME);
	if ( fldRULE_CHANGE_NAME != null )
	{
		fldRULE_CHANGE_NAME.value = sPARENT_NAME;
	}
	var fldRULE_CHANGE_ID = document.getElementById(sRULE_CHANGE_ID);
	if ( fldRULE_CHANGE_ID != null )
	{
		fldRULE_CHANGE_ID.value = sPARENT_ID;
	}
}

// 05/04/2016 Paul.  Add popup role function. 
function ChangeRole(sPARENT_ID, sPARENT_NAME)
{
	var txtCopyLayout = document.getElementById('txtCopyLayout')
	if ( txtCopyLayout != null )
	{
		// 05/05/2016 Paul.  Remove the space characters and quotes to make SQL parsing easier. 
		txtCopyLayout.value = txtCopyLayout.LAYOUT_NAME + '.' + sPARENT_NAME.replaceAll(' ', '').replaceAll('\'', '');
	}
}

// 05/04/2016 Paul.  Add view to node tree. 
function AdminLayoutAddView(sModuleName, sViewName, sLayoutType)
{
	var treeModules = $.fn.zTree.getZTreeObj("treeModules");
	var nodes = treeModules.getSelectedNodes();
	if ( nodes.length > 0 )
	{
		var bLayoutFound = false;
		var nodeView = nodes[0];
		var moduleNode = nodeView.getParentNode();
		for ( var child in moduleNode.children )
		{
			if ( child.ViewName == sViewName )
			{
				bLayoutFound = true;
				break;
			}
		}
		if ( !bLayoutFound )
		{
			var oViewNode = new Object();
			oViewNode.name       = sViewName.substring(sModuleName.length + 1, sViewName.length);
			oViewNode.ModuleName = sModuleName;
			oViewNode.ViewName   = sViewName  ;
			oViewNode.LayoutType = sLayoutType;
			treeModules.addNodes(moduleNode, oViewNode);
		}
	}
}

function AdminLayoutDeleteView(sModuleName, sViewName)
{
	var treeModules = $.fn.zTree.getZTreeObj("treeModules");
	var nodes = treeModules.getSelectedNodes();
	if ( nodes.length > 0 )
	{
		var bLayoutFound = false;
		var nodeView = nodes[0];
		if ( nodeView.ModuleName == sModuleName && nodeView.ViewName == sViewName )
		{
			treeModules.removeNode(nodeView);
		}
	}
}

function AdminLayoutMesasge(message)
{
	// 05/04/2016 Paul.  Error moved to header line for more space. 
	var divLayoutError = document.getElementById('divLayoutError');
	if ( divLayoutError != null )
	{
		$(divLayoutError).text(message);
	}
	else
	{
		SplendidError.SystemMessage(message);
	}
}

