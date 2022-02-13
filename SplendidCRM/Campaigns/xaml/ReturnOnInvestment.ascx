<%@ Control CodeBehind="ReturnOnInvestment.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Campaigns.xaml.ReturnOnInvestment" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Collections" %>
<Canvas x:Name="container" Loaded="mainVerticalCanvasLoaded" MouseMove="whenMouseMoves" MouseLeave="mainVerticalCanvasMouseLeave" xmlns="http://schemas.microsoft.com/client/2007" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
	<Canvas x:Name="bound_box" <%= L10n.IsLanguageRTL() ? "FlowDirection=\"RightToLeft\"" : String.Empty %> Canvas.Top="10" Canvas.Left="10" Width="780" Height="380" Background="White">
		<TextBlock Text="<%# HttpUtility.HtmlEncode(sGraphData_Title) %>" Canvas.Top="3" Canvas.Left="302" Foreground="#393839" FontFamily="Arial" FontSize="12" FontWeight="Bold" />

		<Canvas Canvas.Top="24">
			<Canvas.Clip>
				<RectangleGeometry Rect="0, 0, 800, <%# nGridHeight + 1 %>" />
			</Canvas.Clip>
			<Canvas x:Name="myScroller1_Container" Canvas.Left="<%# nGridWidth + 202 %>" Height="<%# nGridHeight %>">
				<Canvas x:Name="myScroller1_Up" MouseLeftButtonDown="scrollerArrowPress" MouseLeftButtonUp="scrollerArrowRelease">
					<Rectangle Fill="#777" Width="10" Height="10" />
					<Path Data="M 0,0 L4,4 -4,4z" Fill="#EEE" Canvas.Left="5" Canvas.Top="3" />
				</Canvas>
				<Canvas x:Name="myScroller1_Down" MouseLeftButtonDown="scrollerArrowPress" MouseLeftButtonUp="scrollerArrowRelease" Canvas.Top="<%# nGridHeight - 10 %>" >
					<Rectangle Fill="#777" Width="10" Height="10" />
					<Path Data="M 0,0 L4,-4 -4,-4z" Fill="#EEE" Canvas.Left="5" Canvas.Top="7" />
				</Canvas>
				<Rectangle x:Name="myScroller1_TrackBar_Visual" Fill="#AAA" Height="<%# nGridHeight - 20 %>" Width="10" Canvas.Top="11" />
				<Rectangle x:Name="myScroller1_TrackBar" MouseLeftButtonDown="pressTrackBar" Fill="transparent" Height="<%# nGridHeight - 20 %>" Width="10" Canvas.Top="12" />
				<Rectangle x:Name="myScroller1_Scrubber" MouseLeftButtonDown="startDrag" MouseLeftButtonUp="endDrag" Fill="#000" Height="50" Width="8" Canvas.Top="12" Canvas.Left="1" />
			</Canvas>
			<Canvas x:Name="scroll_region" Height="<%# nGridHeight + 1 %>">
<asp:Repeater DataSource="<%# (new int[nAxis_yData_length+1]) %>" runat="server">
	<HeaderTemplate>
			<Canvas x:Name="y_labels" Canvas.Top="4" Canvas.Left="0" Width="90" Height="<%# nAxis_yData_length * 20 %>">
	</HeaderTemplate>
	<ItemTemplate>
				<TextBlock x:Name="y_label_<%# Container.ItemIndex.ToString("000") %>" Text="<%# HttpUtility.HtmlEncode(sAxis_yData_prefix + (Container.ItemIndex * dAxis_yData_section + nAxis_yData_min).ToString("0") + sAxis_yData_suffix) %>" 
					Canvas.Top="<%# nGridHeight - nGridHeight / (nAxis_yData_length+1) - (Container.ItemIndex * nGridHeight / (nAxis_yData_length+1) - 5) %>" Foreground="#395163" FontFamily="Arial" FontSize="11" />
	</ItemTemplate>
	<FooterTemplate>
			</Canvas>
	</FooterTemplate>
</asp:Repeater>

				<Canvas x:Name="legend" Canvas.Top="0" Canvas.Left="<%# 120 + nGridWidth + nGridWidth / nAxis_xData_length + 1 %>" Width="150" Height="<%# nGridHeight %>">
<asp:Repeater DataSource="<%# nlColorLegend %>" runat="server">
	<HeaderTemplate>
					<Canvas x:Name="y_legend" Canvas.Top="4" Canvas.Left="0" Width="150" Height="<%# nlDataRows.Count * 18 %>">
	</HeaderTemplate>
	<ItemTemplate>
						<Rectangle Width="15" Height="15" Stroke="#777777" StrokeThickness="1" Fill="<%# (Container.DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("color").Value.Replace("0x", "#") %>" Canvas.Top="<%# Container.ItemIndex * 18 - 2 %>" />
						<TextBlock x:Name="y_legend_<%# HttpUtility.HtmlEncode((Container.DataItem as System.Xml.XmlNode).Attributes["id"].Value) %>" Text="<%# HttpUtility.HtmlEncode((Container.DataItem as System.Xml.XmlNode).Attributes["name"].Value) %>" Canvas.Left="24" Canvas.Top="<%# Container.ItemIndex * 18 + 1 %>" Foreground="#395163" FontFamily="Arial" FontSize="11" />
	</ItemTemplate>
	<FooterTemplate>
					</Canvas>
	</FooterTemplate>
</asp:Repeater>
				</Canvas>

				<Canvas x:Name="grid" Canvas.Top="0" Canvas.Left="100" Width="801" Height="<%# nGridHeight + 1 %>">
					<Rectangle Width="<%# nGridWidth %>" Height="<%# nGridHeight + 1 %>" Stroke="#D6D3D6" StrokeThickness="1" Fill="#08080808" />
<asp:Repeater DataSource="<%# (new int[nAxis_yData_length+1]) %>" runat="server">
	<ItemTemplate>
					<Line Y1="<%# nGridHeight - (Container.ItemIndex * nGridHeight / (nAxis_yData_length+1)) %>.5"  Y2="<%# nGridHeight - (Container.ItemIndex * nGridHeight / (nAxis_yData_length+1)) %>.5"  X1="0" X2="<%# nGridWidth %>" Stroke="#D6D3D6" StrokeThickness="1" />
	</ItemTemplate>
</asp:Repeater>
<asp:Repeater DataSource="<%# (new int[nAxis_yData_length+1]) %>" runat="server">
	<ItemTemplate>
					<Line Y1="<%# nGridHeight - ((nGridHeight / (nAxis_yData_length+1)) / 2 + Container.ItemIndex * nGridHeight / (nAxis_yData_length+1)) %>.5"  Y2="<%# nGridHeight - ((nGridHeight / (nAxis_yData_length+1)) / 2 + Container.ItemIndex * nGridHeight / (nAxis_yData_length+1)) %>.5"  X1="0" X2="3" Stroke="#D6D3D6" StrokeThickness="1" />
	</ItemTemplate>
</asp:Repeater>

<asp:Repeater DataSource="<%# nlDataRows %>" runat="server">
	<ItemTemplate>
		<asp:Repeater ID="Repeater1" DataSource=<%# (Container.DataItem as System.Xml.XmlNode).SelectNodes("bar") %> runat="server">
			<HeaderTemplate>
					<Canvas Canvas.Top="0" Canvas.Left="<%# (Container.Parent.Parent as RepeaterItem).ItemIndex * (nAxis_xData_length + dAxis_xData_section) + (dAxis_xData_section) / 2 %>" Width="<%# nAxis_xData_length + 3 %>" Height="<%# nGridHeight %>" Visibility="<%# ((Container.Parent.Parent as RepeaterItem).DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("totalSize").Value == "0" ? "Collapsed" : "Visible" %>">
						<Rectangle Canvas.Top="<%# nGridHeight - 3 - ((Sql.ToInteger(((Container.Parent.Parent as RepeaterItem).DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("totalSize").Value) - nAxis_yData_min) * nGridHeight) / (nAxis_yData_max + dAxis_yData_section) %>" Canvas.Left="2.5" 
							Height="<%# 1 + ((Sql.ToInteger(((Container.Parent.Parent as RepeaterItem).DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("totalSize").Value) - nAxis_yData_min) * nGridHeight) / (nAxis_yData_max + dAxis_yData_section) %>" Width="<%# nAxis_xData_length %>" Fill="#cccccc" />
			</HeaderTemplate>
			<ItemTemplate>
						<Rectangle x:Name="<%# "Bar_" + (Container.Parent.Parent as RepeaterItem).ItemIndex.ToString("000") + "_" + Container.ItemIndex.ToString("000") + "_link" %>" Tag="<%# HttpUtility.HtmlEncode((Container.DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("url").Value) %>" 
							Canvas.Top="0" Canvas.Left="0" Width="0" Height="0" Visibility="Collapsed" />
						<Rectangle x:Name="<%# "Bar_" + (Container.Parent.Parent as RepeaterItem).ItemIndex.ToString("000") + "_" + Container.ItemIndex.ToString("000") %>" Tag="<%# HttpUtility.HtmlEncode((Container.DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("altText").Value) %>" MouseEnter="VerticalBarEnter" MouseLeave="VerticalBarLeave" MouseLeftButtonUp="HorizontalBarClick" Canvas.Left="0" 
							Canvas.Top="<%# nGridHeight - 1 - (((Sql.ToInteger((Container.DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("startOffset").Value) + Sql.ToInteger((Container.DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("totalSize").Value)) - nAxis_yData_min) * nGridHeight) / (nAxis_yData_max + dAxis_yData_section) %>" 
							Width="<%# nAxis_xData_length %>" 
							Height="<%# 1 + ((Sql.ToInteger((Container.DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("totalSize").Value) - nAxis_yData_min) * nGridHeight) / (nAxis_yData_max + dAxis_yData_section) %>" Stroke="#eeeeee" StrokeThickness="1">
							<Rectangle.Fill>
								<LinearGradientBrush StartPoint="-0.9,0.0" EndPoint="1.0,0.0">
									<GradientStop Offset="0.0" Color="#efefef" />
									<GradientStop Offset="1.0" Color="<%# Sql.ToString(hashColorLegend[(Container.DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("id").Value]).Replace("0x", "#") %>" />
								</LinearGradientBrush>
							</Rectangle.Fill>
						</Rectangle>
			</ItemTemplate>
			<FooterTemplate>
						<TextBlock Text="<%# HttpUtility.HtmlEncode(((Container.Parent.Parent as RepeaterItem).DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("endLabel").Value) %>" 
							Canvas.Top="<%# nGridHeight - 15 - ((Sql.ToInteger(((Container.Parent.Parent as RepeaterItem).DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("totalSize").Value) - nAxis_yData_min) * nGridHeight) / (nAxis_yData_max + dAxis_yData_section) %>" Canvas.Left="<%# nAxis_xData_length / 2 %>" Foreground="#395163" FontFamily="Arial" FontSize="11" />
					</Canvas>
			</FooterTemplate>
		</asp:Repeater>
	</ItemTemplate>
</asp:Repeater>
				</Canvas>
			</Canvas>
		</Canvas>

		<Canvas Canvas.Left="100">
<asp:Repeater DataSource="<%# nlDataRows %>" runat="server">
	<HeaderTemplate>
			<Canvas x:Name="x_labels" Canvas.Top="<%# nGridHeight + 32 %>" Width="<%# nGridWidth %>" Height="20">
	</HeaderTemplate>
	<ItemTemplate>
				<TextBlock x:Name="x_label_<%# Container.ItemIndex.ToString("000") %>" Text="<%# HttpUtility.HtmlEncode((Container.DataItem as System.Xml.XmlNode).Attributes["title"].Value) %>" Canvas.Left="<%# Container.ItemIndex * (nAxis_xData_length + dAxis_xData_section) + (dAxis_xData_section) / 2 %>" Width="<%# nAxis_xData_length %>" FontFamily="Arial" Foreground="#395163" FontSize="9" />
	</ItemTemplate>
	<FooterTemplate>
			</Canvas>
	</FooterTemplate>
</asp:Repeater>
			<TextBlock x:Name="DetailsBar" Text="<%# HttpUtility.HtmlEncode(sAxis_yData_defaultAltText) %>" Tag="<%# HttpUtility.HtmlEncode(sAxis_yData_defaultAltText) %>" Canvas.Top="284" Width="<%# nGridWidth %>" Foreground="#636963" FontFamily="Arial" FontSize="10" TextWrapping="Wrap" Visibility="Visible" />

			<TextBlock Text="<%# HttpUtility.HtmlEncode(sGraphData_GraphInfo) %>" Canvas.Top="332" Width="<%# nGridWidth %>" Foreground="#9C9C9C" FontFamily="Arial" FontSize="10" TextWrapping="Wrap" />
		</Canvas>
	</Canvas>
</Canvas>
