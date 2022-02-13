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
using System.Xml;
using System.Data;
using System.Data.Common;
using System.Web;
using System.Web.UI.WebControls;
using System.Diagnostics;

namespace SplendidCRM.Administration.DynamicLayout._controls
{
	/// <summary>
	///		Summary description for SearchBasic.
	/// </summary>
	public class SearchBasic : SearchControl
	{
		protected DropDownList lstLAYOUT_VIEWS;
		protected string        sViewTableName;
		protected string        sViewFieldName;
		protected XmlDataSource xdsViews      ;
		protected TreeView      treeMain      ;
		protected XmlDocument   xml           ;

		public string NAME
		{
			get
			{
				string sNAME = String.Empty;
				if ( treeMain.SelectedNode != null )
				{
					if ( treeMain.SelectedNode.Depth == 2 )
						sNAME = treeMain.SelectedNode.Value;
				}
				return sNAME;
			}
		}

		public string ViewTableName
		{
			get { return sViewTableName; }
			set { sViewTableName = value; }
		}

		public string ViewFieldName
		{
			get { return sViewFieldName; }
			set { sViewFieldName = value; }
		}

		public override void SqlSearchClause(IDbCommand cmd)
		{
			//Sql.AppendParameter(cmd, lstLAYOUT_VIEWS, sViewFieldName);
			if ( treeMain.SelectedNode != null )
			{
				Sql.AppendParameter(cmd, treeMain.SelectedNode.Value, sViewFieldName);
			}
		}

		// 02/14/2013 Paul.  Allow the layout tree to be rebuilt. 
		public void Bind()
		{
			DbProviderFactory dbf = DbProviderFactories.GetFactory();
			using ( IDbConnection con = dbf.CreateConnection() )
			{
				string sSQL;
				// 05/04/2008 Paul.  Protect against SQL Injection. A table name will never have a space character.
				sViewTableName = sViewTableName.Replace(" ", "");
				sSQL = "select *                   " + ControlChars.CrLf
				     + "  from " + sViewTableName    + ControlChars.CrLf
				     + " order by DISPLAY_NAME     " + ControlChars.CrLf;
				using ( IDbCommand cmd = con.CreateCommand() )
				{
					cmd.CommandText = sSQL;
					try
					{
						using ( DbDataAdapter da = dbf.CreateDataAdapter() )
						{
							((IDbDataAdapter)da).SelectCommand = cmd;
							using ( DataTable dt = new DataTable() )
							{
								da.Fill(dt);
								lstLAYOUT_VIEWS.DataSource = dt;
								lstLAYOUT_VIEWS.DataBind();
								lstLAYOUT_VIEWS.Items.Insert(0, String.Empty);

								xml.AppendChild(xml.CreateProcessingInstruction("xml" , "version=\"1.0\" encoding=\"UTF-8\""));
								xml.AppendChild(xml.CreateElement("Modules"));
								XmlNode xModules = xml.DocumentElement;
								// 10/31/2010 Paul.  Fix label. 
								XmlUtil.SetSingleNodeAttribute(xml, xModules, "Name", L10n.Term("Modules.LNK_MODULE_LIST"));
								foreach ( DataRow row in dt.Rows )
								{
									string sNAME         = Sql.ToString(row["NAME"        ]);
									string sDISPLAY_NAME = Sql.ToString(row["DISPLAY_NAME"]);
									string[] arrNAME     = sNAME.Split('.');
									string sMODULE_NAME  = arrNAME[0];
									string sVIEW_NAME    = String.Empty;
									try
									{
										// 11/02/2011 Paul.  TabMenu will not have a view name. 
										if ( arrNAME.Length > 0 && sNAME.Length > sMODULE_NAME.Length )
										{
											sVIEW_NAME = sNAME.Substring(sMODULE_NAME.Length + 1);
										}
										XmlNode xModule = xModules.SelectSingleNode("Module[@Name=\'" + sMODULE_NAME + "\']");
										if ( xModule == null )
										{
											xModule = xml.CreateElement("Module");
											xModules.AppendChild(xModule);
											XmlUtil.SetSingleNodeAttribute(xml, xModule, "Name", sMODULE_NAME);
										}
										XmlNode xView = xml.CreateElement("View");
										xModule.AppendChild(xView);
										XmlUtil.SetSingleNodeAttribute(xml, xView, "Name"       , sNAME     );
										XmlUtil.SetSingleNodeAttribute(xml, xView, "DisplayName", sVIEW_NAME);
									}
									catch(Exception ex)
									{
										SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
									}
								}
								//ViewState["xml"] = xml.OuterXml;
								xdsViews.Data = xml.OuterXml;
								treeMain.DataSourceID = "xdsViews";
								treeMain.DataBind();
								// 07/27/2010 Paul.  Select the first view from the first module. 
								// This did not work.  The SearchBasic control is not bound earily enough for it to take affect. 
								/*
								if ( treeMain.Nodes.Count > 0 )
								{
									TreeNode nodeModules = treeMain.Nodes[0];
									if ( nodeModules.ChildNodes.Count > 0 )
									{
										TreeNode nodeModule = nodeModules.ChildNodes[0];
										nodeModule.Expand();
										if ( nodeModule.ChildNodes.Count > 0 )
										{
											TreeNode nodeView = nodeModule.ChildNodes[0];
											nodeView.Select();
										}
									}
								}
								*/
							}
						}
					}
					catch(Exception ex)
					{
						SplendidError.SystemError(new StackTrace(true).GetFrame(0), ex);
					}
				}
			}
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
			xml = new XmlDocument();
			// 01/20/2015 Paul.  Disable XmlResolver to prevent XML XXE. 
			// https://www.owasp.org/index.php/XML_External_Entity_(XXE)_Processing
			// http://stackoverflow.com/questions/14230988/how-to-prevent-xxe-attack-xmldocument-in-net
			xml.XmlResolver = null;
			// 01/06/2006 Paul.  Try disabling viewstate of DetailView to prevent viewstate error. 
			if ( !this.IsPostBack || !Parent.EnableViewState )
			{
				Bind();
			}
			else
			{
				/*
				string sXML = Sql.ToString(ViewState["xml"]);
				if ( !Sql.IsEmptyString(sXML) )
				{
					xml.LoadXml(sXML);
					xdsViews.Data = xml.OuterXml;
				}
				*/
			}
		}

		#region Web Form Designer generated code
		override protected void OnInit(EventArgs e)
		{
			//
			// CODEGEN: This call is required by the ASP.NET Web Form Designer.
			//
			InitializeComponent();
			base.OnInit(e);
		}
		
		/// <summary>
		///		Required method for Designer support - do not modify
		///		the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
			this.Load += new System.EventHandler(this.Page_Load);
		}
		#endregion
	}
}

