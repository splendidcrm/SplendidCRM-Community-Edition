using System;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using System.Diagnostics;

namespace SplendidCRM.$modulename$
{
	/// <summary>
	///		Summary description for ImportDefaultsView.
	/// </summary>
	public class ImportDefaultsView : SplendidControl
	{
		protected Guid            gID                             ;
		protected HtmlTable       tblMain                         ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
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
			m_sMODULE = "$modulename$";
			this.AppendEditViewFields(m_sMODULE + ".EditView", tblMain, null);
		}
		#endregion
	}
}

