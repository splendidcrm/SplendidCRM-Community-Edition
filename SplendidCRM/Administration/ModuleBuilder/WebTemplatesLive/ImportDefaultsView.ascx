<%@ Control Language="c#" AutoEventWireup="false" Codebehind="ImportDefaultsView.ascx.cs" Inherits="SplendidCRM.SplendidControl" TargetSchema="http://schemas.microsoft.com/intellisense/ie5" %>
<script runat="server">
		protected Guid            gID                             ;

		protected void Page_Command(Object sender, CommandEventArgs e)
		{
		}

		private void Page_Load(object sender, System.EventArgs e)
		{
		}

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
</script>
<div id="divDefaultsView">
	<p></p>

	<asp:Table SkinID="tabForm" runat="server">
		<asp:TableRow>
			<asp:TableCell>
				<table ID="tblMain" class="tabEditView" runat="server">
				</table>
			</asp:TableCell>
		</asp:TableRow>
	</asp:Table>
	<p></p>
</div>

