/**********************************************************************************************************************
 * SplendidCRM is a Customer Relationship Management program created by SplendidCRM Software, Inc. 
 * Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved.
 * 
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; 
 * without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
 * See the GNU Affero General Public License for more details.
 * 
 * You should have received a copy of the GNU Affero General Public License along with this program. 
 * If not, see <http://www.gnu.org/licenses/>. 
 * 
 * You can contact SplendidCRM Software, Inc. at email address support@splendidcrm.com. 
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2011 SplendidCRM Software, Inc. All rights reserved."
 *********************************************************************************************************************/
using System;
using System.Data;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Web.SessionState;
using System.Diagnostics;

namespace SplendidCRM
{
	public class ACL_ACCESS
	{
		// 09/26/2017 Paul.  Add Archive access right. 
		public const int FULL_ACCESS = 100;
		public const int ARCHIVE   = 91;
		public const int VIEW      = 90;
		public const int ALL       = 90;
		public const int ENABLED  =  89;
		public const int OWNER    =  75;
		public const int DISABLED = -98;
		public const int NONE     = -99;
	}

// 10/31/2021 Paul.  Don't need any of the ACLGrid code.
#if !ReactOnlyUI
	public class CreateHeaderTemplateACL : ITemplate
	{
		protected string sLABEL;
		
		public CreateHeaderTemplateACL(string sLABEL)
		{
			this.sLABEL  = sLABEL ;
		}
		public void InstantiateIn(Control objContainer)
		{
			HtmlGenericControl divLabel = new HtmlGenericControl("div");
			objContainer.Controls.Add(divLabel);
			divLabel.Attributes.Add("align", "center");

			Literal lit = new Literal();
			lit.DataBinding += new EventHandler(lit_OnDataBinding);
			divLabel.Controls.Add(lit);
			lit.Text = sLABEL;
		}
		private void lit_OnDataBinding(object sender, EventArgs e)
		{
			Literal lbl = (Literal)sender;
			DataGridItem objContainer = (DataGridItem) lbl.NamingContainer;
			// 04/30/2006 Paul.  Use the Context to store pointers to the localization objects.
			// This is so that we don't need to require that the page inherits from SplendidPage. 
			L10N L10n = HttpContext.Current.Items["L10n"] as L10N;
			if ( L10n == null )
			{
				// 04/26/2006 Paul.  We want to have the AccessView on the SystemCheck page. 
				L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
			}
			lbl.Text = L10n.Term(sLABEL);
		}
	}


	public class CreateItemTemplateACL : ITemplate
	{
		protected string sDATA_FIELD ;
		protected string sACCESS_TYPE;
		protected HtmlGenericControl divList ;
		protected HtmlGenericControl divLabel;
		protected Literal            lbl;
		protected HtmlInputHidden    hid;
		protected DropDownList       lst;
		
		public CreateItemTemplateACL(string sDATA_FIELD, string sACCESS_TYPE)
		{
			this.sDATA_FIELD  = sDATA_FIELD ;
			this.sACCESS_TYPE = sACCESS_TYPE;
		}

		#region Helpers
		private int NormalizeAccessValue(string sACCESS_TYPE, int nACCESS)
		{
			if ( sACCESS_TYPE == "access" )
			{
				// 04/25/2006 Paul.  Be flexible with the values, so don't compare directly to 89 and -98.
				if ( nACCESS > 0 )
					nACCESS = 89;
				else
					nACCESS = -98;
			}
			else if ( sACCESS_TYPE == "import" )
			{
				// 04/25/2006 Paul.  Be flexible with the values, so don't compare directly to 90 and -99.
				if ( nACCESS > 0 )
					nACCESS = 90;
				else
					nACCESS = -99;
			}
			// 09/26/2017 Paul.  Add Archive access right. 
			else if ( sACCESS_TYPE == "archive" )
			{
				if ( nACCESS > 90 )
					nACCESS = 91;
				else if ( nACCESS > 75 )
					nACCESS = 90;
				else if ( nACCESS > 0 )
					nACCESS = 75;
				else
					nACCESS = -99;
			}
			else
			{
				// 04/25/2006 Paul.  Be flexible with the values, so don't compare directly to 90, 75 and -99.
				if ( nACCESS > 75 )
					nACCESS = 90;
				else if ( nACCESS > 0 )
					nACCESS = 75;
				else
					nACCESS = -99;
			}
			return nACCESS;
		}
		private string AccessClassName(string sACCESS_TYPE, int nACCESS)
		{
			string sClass = "aclNormal";
			if ( sACCESS_TYPE == "access" )
			{
				if ( nACCESS > 0 )
					sClass = "aclEnabled";
				else
					sClass = "aclDisabled";
			}
			else if ( sACCESS_TYPE == "import" )
			{
				if ( nACCESS > 0 )
					sClass = "aclAll";
				else
					sClass = "aclNone";
			}
			// 09/26/2017 Paul.  Add Archive access right. 
			else if ( sACCESS_TYPE == "archive" )
			{
				if ( nACCESS > 75 )
					sClass = "aclAll";
				else if ( nACCESS > 0 )
					sClass = "aclOwner";
				else
					sClass = "aclNone";
			}
			else
			{
				if ( nACCESS > 75 )
					sClass = "aclAll";
				else if ( nACCESS > 0 )
					sClass = "aclOwner";
				else
					sClass = "aclNone";
			}
			return sClass;
		}
		private string AccessLabel(string sACCESS_TYPE, int nACCESS)
		{
			string sACCESS;
			if ( sACCESS_TYPE == "access" )
			{
				if ( nACCESS > 0 )
					sACCESS = "ACLActions.LBL_ACCESS_ENABLED";
				else
					sACCESS = "ACLActions.LBL_ACCESS_DISABLED";
			}
			else if ( sACCESS_TYPE == "import" )
			{
				if ( nACCESS > 0 )
					sACCESS = "ACLActions.LBL_ACCESS_ALL";
				else
					sACCESS = "ACLActions.LBL_ACCESS_NONE";
			}
			// 09/26/2017 Paul.  Add Archive access right. 
			else if ( sACCESS_TYPE == "archive" )
			{
				if ( nACCESS > 90 )
					sACCESS = "ACLActions.LBL_ACCESS_ARCHIVE";
				else if ( nACCESS > 75 )
					sACCESS = "ACLActions.LBL_ACCESS_VIEW";
				else if ( nACCESS > 0 )
					sACCESS = "ACLActions.LBL_ACCESS_OWNER";
				else
					sACCESS = "ACLActions.LBL_ACCESS_NONE";
			}
			else
			{
				if ( nACCESS > 75 )
					sACCESS = "ACLActions.LBL_ACCESS_ALL";
				else if ( nACCESS > 0 )
					sACCESS = "ACLActions.LBL_ACCESS_OWNER";
				else
					sACCESS = "ACLActions.LBL_ACCESS_NONE";
			}
			return sACCESS;
		}
		#endregion

		public void InstantiateIn(Control objContainer)
		{
			// 04/25/2006 Paul.  The label needs to be created first as the List will need to access it. 
			divLabel = new HtmlGenericControl("div");
			objContainer.Controls.Add(divLabel);
			divLabel.Attributes.Add("style", "display: inline");

			lbl = new Literal();
			lbl.DataBinding += new EventHandler(lit_OnDataBinding);
			divLabel.Controls.Add(lbl);

			hid = new HtmlInputHidden();
			objContainer.Controls.Add(hid);

			divList = new HtmlGenericControl("div");
			objContainer.Controls.Add(divList);
			divList.Attributes.Add("style", "display: none");

			lst = new DropDownList();
			lst.DataBinding += new EventHandler(lst_OnDataBinding);
			divList.Controls.Add(lst);
			
			if ( sACCESS_TYPE == "access" )
			{
				lst.Items.Add(new ListItem("ACLActions.LBL_ACCESS_ENABLED" , ACL_ACCESS.ENABLED .ToString()));
				lst.Items.Add(new ListItem("ACLActions.LBL_ACCESS_DISABLED", ACL_ACCESS.DISABLED.ToString()));
			}
			else if ( sACCESS_TYPE == "import" )
			{
				lst.Items.Add(new ListItem("ACLActions.LBL_ACCESS_ALL" , ACL_ACCESS.ALL .ToString()));
				lst.Items.Add(new ListItem("ACLActions.LBL_ACCESS_NONE", ACL_ACCESS.NONE.ToString()));
			}
			// 09/26/2017 Paul.  Add Archive access right. 
			else if ( sACCESS_TYPE == "archive" )
			{
				lst.Items.Add(new ListItem("ACLActions.LBL_ACCESS_ARCHIVE", ACL_ACCESS.ARCHIVE.ToString()));
				lst.Items.Add(new ListItem("ACLActions.LBL_ACCESS_VIEW"   , ACL_ACCESS.VIEW   .ToString()));
				lst.Items.Add(new ListItem("ACLActions.LBL_ACCESS_OWNER"  , ACL_ACCESS.OWNER  .ToString()));
				lst.Items.Add(new ListItem("ACLActions.LBL_ACCESS_NONE"   , ACL_ACCESS.NONE   .ToString()));
			}
			else
			{
				lst.Items.Add(new ListItem("ACLActions.LBL_ACCESS_ALL"  , ACL_ACCESS.ALL  .ToString()));
				lst.Items.Add(new ListItem("ACLActions.LBL_ACCESS_OWNER", ACL_ACCESS.OWNER.ToString()));
				lst.Items.Add(new ListItem("ACLActions.LBL_ACCESS_NONE" , ACL_ACCESS.NONE .ToString()));
			}
		}
		private void lit_OnDataBinding(object sender, EventArgs e)
		{
			DataGridItem objContainer = (DataGridItem) lbl.NamingContainer;
			DataRowView row = objContainer.DataItem as DataRowView;

			// 04/25/2006 Paul.  We don't have access to the ACLGrid in InstantiateIn(), so do so here. 
			ACLGrid grd = objContainer.Parent.Parent as ACLGrid;
			if ( !grd.EnableACLEditing )
			{
				divList.Controls.Clear();
				// 04/25/2006 Paul.  I'd like to remove the dvList, but I can't do it here. 
				//divList.Parent.Controls.Remove(divList);
				//divList = null;
			}
			if ( row != null )
			{
				string sMODULE_NAME = Sql.ToString(row["MODULE_NAME"]);
				// 04/25/2006 Paul.  We could use GUIDS like SugarCRM, but since there is only one ACL grid, 
				// there is no need for that kind of uniqueness. 
				divLabel.ID = sMODULE_NAME + "_" + sACCESS_TYPE + "link";
				hid.ID = "hid" + sMODULE_NAME + "_" + sACCESS_TYPE;
				
				if ( row[sDATA_FIELD] != DBNull.Value )
				{
					// 04/30/2006 Paul.  Use the Context to store pointers to the localization objects.
					// This is so that we don't need to require that the page inherits from SplendidPage. 
					L10N L10n = HttpContext.Current.Items["L10n"] as L10N;
					if ( L10n == null )
					{
						// 04/26/2006 Paul.  We want to have the AccessView on the SystemCheck page. 
						L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
					}
					int nACCESS = Sql.ToInteger(row[sDATA_FIELD]);
					divLabel.Attributes.Add("class", AccessClassName(sACCESS_TYPE, nACCESS));
					// 04/25/2006 Paul.  Don't update values on postback, otherwise it will over-write modified values. 
					// 04/26/2006 Paul.  Make sure to set the division color, even on postback. 
					// 05/03/2006 Paul.  If we are not editing, then always bind to the query. 
					// This is so that the AccessView control can be placed in an unrelated control that have postbacks. 
					// This was first noticed in the UserRolesView.ascx. 
					if ( !objContainer.Page.IsPostBack || !grd.EnableACLEditing )
					{
						lbl.Text  = L10n.Term(AccessLabel(sACCESS_TYPE, nACCESS));
						hid.Value = lbl.Text;
					}
					else
					{
						// 04/25/2006 Paul.  The label will not retain its value, so restore from the hidden field.
						// We use the hidden field because the value my have been changed by the user. 
						// 04/25/2006 Paul.  We are too early in the ASP.NET lifecycle to access hid.Value,
						// so go directly to the Request to get the submitted value. 
						lbl.Text = hid.Page.Request[hid.UniqueID];
					}
				}
			}
		}
		private void lst_OnDataBinding(object sender, EventArgs e)
		{
			DataGridItem objContainer = (DataGridItem) lst.NamingContainer;
			DataRowView row = objContainer.DataItem as DataRowView;
			if ( row != null )
			{
				string sMODULE_NAME = Sql.ToString(row["MODULE_NAME"]);
				// 04/25/2006 Paul.  We could use GUIDS like SugarCRM, but since there is only one ACL grid, 
				// there is no need for that kind of uniqueness. 
				// 04/25/2006 Paul.  toggleDisplay() will automatically reverse toggle of a linked control. 
				divList.ID = sMODULE_NAME + "_" + sACCESS_TYPE;
				lst.ID = "lst" + sMODULE_NAME + "_" + sACCESS_TYPE;
				// 04/25/2006 Paul.  OnChange, update the the innerHTML and the hidden field. 
				lst.Attributes.Add("onchange", "document.getElementById('" + divLabel.ClientID + "').innerHTML=this.options[this.selectedIndex].text; document.getElementById('" + hid.ClientID + "').value=document.getElementById('" + divLabel.ClientID + "').innerHTML; toggleDisplay('" + divList.ClientID + "');");
				// 04/25/2006 Paul.  The first parent is the DIV, the second is the TableCell. 
				TableCell td = divList.Parent as TableCell;
				if ( td != null )
					td.Attributes.Add("ondblclick", "toggleDisplay('" + divList.ClientID + "')");
				
				if ( row[sDATA_FIELD] != DBNull.Value )
				{
					int nACCESS = Sql.ToInteger(row[sDATA_FIELD]);
					lst.Attributes.Add("class", AccessClassName(sACCESS_TYPE, nACCESS));
					try
					{
						// 04/25/2006 Paul.  Don't update values on postback, otherwise it will over-write modified values. 
						if ( !objContainer.Page.IsPostBack )
						{
							// 08/19/2010 Paul.  Check the list before assigning the value. 
							Utils.SetSelectedValue(lst, NormalizeAccessValue(sACCESS_TYPE, nACCESS).ToString());
						}
					}
					catch
					{
					}
				}
				
				// 04/25/2006 Paul.  We always need to translate the items, even during postback.
				// This is because we always build the DropDownList. 
				// 04/30/2006 Paul.  Use the Context to store pointers to the localization objects.
				// This is so that we don't need to require that the page inherits from SplendidPage. 
				L10N L10n = HttpContext.Current.Items["L10n"] as L10N;
				if ( L10n == null )
				{
					// 04/26/2006 Paul.  We want to have the AccessView on the SystemCheck page. 
					L10n = new L10N(Sql.ToString(HttpContext.Current.Session["USER_SETTINGS/CULTURE"]));
				}
				// 04/25/2006 Paul.  Make sure to translate the text.  
				// It cannot be translated in InstantiateIn() because the Page is not defined. 
				foreach(ListItem itm in lst.Items )
				{
					itm.Text = L10n.Term(itm.Text);
				}
			}
		}
	}

	/// <summary>
	/// Summary description for ACLGrid.
	/// </summary>
	public class ACLGrid : SplendidGrid
	{
		protected bool bEnableACLEditing = false;

		public ACLGrid()
		{
			this.Init += new EventHandler(OnInit);
		}

		public bool EnableACLEditing
		{
			get { return bEnableACLEditing; }
			set { bEnableACLEditing = value; }
		}

		// 04/25/2006 Paul.  FindControl needs to be executed on the DataGridItem.  I'm not sure why.
		public DropDownList FindACLControl(string sMODULE_NAME, string sACCESS_TYPE)
		{
			DropDownList lst = null;
			foreach(DataGridItem itm in Items)
			{
				lst = itm.FindControl("lst" + sMODULE_NAME + "_" + sACCESS_TYPE) as DropDownList;
				if ( lst != null )
					break;
			}
			return lst;
		}

		private void AppendACLColumn(string sLABEL, string sDATA_FIELD, string sACCESS_TYPE)
		{
			TemplateColumn tpl = new TemplateColumn();
			//tpl.HeaderText                  = sLABEL;
			tpl.ItemStyle.Width             = new Unit("12%");
			//tpl.ItemStyle.CssClass          = "tabDetailViewDF";
			tpl.ItemStyle.HorizontalAlign   = HorizontalAlign.Center   ;
			tpl.ItemStyle.VerticalAlign     = VerticalAlign.NotSet     ;
			tpl.ItemStyle.Wrap              = false;
			tpl.ItemTemplate   = new CreateItemTemplateACL(sDATA_FIELD, sACCESS_TYPE);
			tpl.HeaderTemplate = new CreateHeaderTemplateACL(sLABEL);
			this.Columns.Add(tpl);
		}

		protected void OnInit(object sender, System.EventArgs e)
		{
			TemplateColumn tpl = new TemplateColumn();
			tpl.ItemStyle.Wrap     = false;
			tpl.ItemStyle.CssClass = "tabDetailViewDL";
			tpl.ItemTemplate       = new CreateItemTemplateTranslated("DISPLAY_NAME");
			this.Columns.Add(tpl);

			//AppendACLColumn("ACLACCESS_ADMIN" , "admin" );
			AppendACLColumn("ACLActions.LBL_ACTION_ACCESS", "ACLACCESS_ACCESS", "access");
			AppendACLColumn("ACLActions.LBL_ACTION_VIEW"  , "ACLACCESS_VIEW"  , "view"  );
			AppendACLColumn("ACLActions.LBL_ACTION_LIST"  , "ACLACCESS_LIST"  , "list"  );
			AppendACLColumn("ACLActions.LBL_ACTION_EDIT"  , "ACLACCESS_EDIT"  , "edit"  );
			AppendACLColumn("ACLActions.LBL_ACTION_DELETE", "ACLACCESS_DELETE", "delete");
			AppendACLColumn("ACLActions.LBL_ACTION_IMPORT", "ACLACCESS_IMPORT", "import");
			AppendACLColumn("ACLActions.LBL_ACTION_EXPORT", "ACLACCESS_EXPORT", "export");
			// 09/26/2017 Paul.  Add Archive access right. 
			AppendACLColumn("ACLActions.LBL_ACTION_ARCHIVE", "ACLACCESS_ARCHIVE", "archive");
		}

	}
#endif
}


