<%@ Control CodeBehind="PipelineBySalesStage.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Opportunities.xaml.PipelineBySalesStage" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Collections" %>
<Canvas x:Name="container" Loaded="mainCanvasLoaded" MouseMove="whenMouseMoves" MouseLeave="mainCanvasMouseLeave" xmlns="http://schemas.microsoft.com/client/2007" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
	<Canvas x:Name="bound_box" <%= L10n.IsLanguageRTL() ? "FlowDirection=\"RightToLeft\"" : String.Empty %> Canvas.Top="10" Canvas.Left="10" Width="780" Height="380" Background="White">
		<TextBlock Text="<%# HttpUtility.HtmlEncode(sGraphData_Title) %>" Canvas.Top="3" Canvas.Left="302" Foreground="#393839" FontFamily="Arial" FontSize="12" FontWeight="Bold" />

		<Canvas Canvas.Top="24">
			<Canvas.Clip>
				<RectangleGeometry Rect="0, 0, 612, 226" />
			</Canvas.Clip>
			<Canvas x:Name="myScroller1_Container" Canvas.Left="602" Height="226">
				<Canvas x:Name="myScroller1_Up" MouseLeftButtonDown="scrollerArrowPress" MouseLeftButtonUp="scrollerArrowRelease">
					<Rectangle Fill="#777" Width="10" Height="10" />
					<Path Data="M 0,0 L4,4 -4,4z" Fill="#EEE" Canvas.Left="5" Canvas.Top="3" />
				</Canvas>
				<Canvas x:Name="myScroller1_Down" MouseLeftButtonDown="scrollerArrowPress" MouseLeftButtonUp="scrollerArrowRelease" Canvas.Top="216" >
					<Rectangle Fill="#777" Width="10" Height="10" />
					<Path Data="M 0,0 L4,-4 -4,-4z" Fill="#EEE" Canvas.Left="5" Canvas.Top="7" />
				</Canvas>
				<Rectangle x:Name="myScroller1_TrackBar_Visual" Fill="#AAA" Height="206" Width="10" Canvas.Top="11" />
				<Rectangle x:Name="myScroller1_TrackBar" MouseLeftButtonDown="pressTrackBar" Fill="transparent" Height="206" Width="10" Canvas.Top="12" />
				<Rectangle x:Name="myScroller1_Scrubber" MouseLeftButtonDown="startDrag" MouseLeftButtonUp="endDrag" Fill="#000" Height="50" Width="8" Canvas.Top="12" Canvas.Left="1" />
			</Canvas>
			<Canvas x:Name="scroll_region" Height="<%# Math.Min(nGridHeight, 226) %>">
<asp:Repeater DataSource="<%# nlDataRows %>" runat="server">
	<HeaderTemplate>
				<Canvas x:Name="y_labels" Canvas.Top="4" Canvas.Left="0" Width="150" Height="<%# nlDataRows.Count * 20 %>">
	</HeaderTemplate>
	<ItemTemplate>
					<TextBlock x:Name="y_label_<%# Container.ItemIndex.ToString("000") %>" Text="<%# HttpUtility.HtmlEncode((Container.DataItem as System.Xml.XmlNode).Attributes["title"].Value) %>" Canvas.Top="<%# Container.ItemIndex * 20 - 2 %>"   Foreground="#395163" FontFamily="Arial" FontSize="11" />
	</ItemTemplate>
	<FooterTemplate>
				</Canvas>
	</FooterTemplate>
</asp:Repeater>

				<Canvas x:Name="grid" Canvas.Top="0" Canvas.Left="160" Width="801" Height="<%# nGridHeight %>">
					<Rectangle Width="<%# nGridWidth + nGridWidth / nAxis_xData_length + 1 %>" Height="<%# nGridHeight %>" Stroke="#D6D3D6" StrokeThickness="1" Fill="#08080808" />
<asp:Repeater DataSource="<%# (new int[nAxis_xData_length+1]) %>" runat="server">
	<ItemTemplate>
					<Line X1="<%# Container.ItemIndex * nGridWidth / nAxis_xData_length %>.5"  X2="<%# Container.ItemIndex * nGridWidth / nAxis_xData_length %>.5"  Y1="0" Y2="<%# nGridHeight %>" Stroke="#D6D3D6" StrokeThickness="1" />
	</ItemTemplate>
</asp:Repeater>
<asp:Repeater DataSource="<%# (new int[nAxis_xData_length+1]) %>" runat="server">
	<ItemTemplate>
					<Line X1="<%# (nGridWidth / nAxis_xData_length) / 2 + Container.ItemIndex * nGridWidth / nAxis_xData_length %>.5"  X2="<%# (nGridWidth / nAxis_xData_length) / 2 + Container.ItemIndex * nGridWidth / nAxis_xData_length %>.5"  Y1="<%# nGridHeight - 3 %>" Y2="<%# nGridHeight %>" Stroke="#D6D3D6" StrokeThickness="1" />
	</ItemTemplate>
</asp:Repeater>

<asp:Repeater DataSource="<%# nlDataRows %>" runat="server">
	<ItemTemplate>
		<asp:Repeater DataSource=<%# (Container.DataItem as System.Xml.XmlNode).SelectNodes("bar") %> runat="server">
			<HeaderTemplate>
					<Canvas Canvas.Top="<%# (Container.Parent.Parent as RepeaterItem).ItemIndex * 20 %>" Canvas.Left="1" Width="<%# nGridWidth %>" Height="20" Visibility="<%# ((Container.Parent.Parent as RepeaterItem).DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("endLabel").Value == "0" ? "Collapsed" : "Visible" %>">
						<Rectangle Canvas.Top="3" Canvas.Left="2" Width="<%# ((Sql.ToInteger(((Container.Parent.Parent as RepeaterItem).DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("endLabel").Value) - nAxis_xData_min) * nGridWidth) / nAxis_xData_max %>" Height="15" Fill="#cccccc" />
			</HeaderTemplate>
			<ItemTemplate>
						<Rectangle x:Name="<%# "Bar_" + (Container.Parent.Parent as RepeaterItem).ItemIndex.ToString("000") + "_" + Container.ItemIndex.ToString("000") + "_link" %>" Tag="<%# HttpUtility.HtmlEncode((Container.DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("url").Value) %>" 
							Canvas.Top="0" Canvas.Left="0" Width="0" Height="0" Visibility="Collapsed" />
						<Rectangle x:Name="<%# "Bar_" + (Container.Parent.Parent as RepeaterItem).ItemIndex.ToString("000") + "_" + Container.ItemIndex.ToString("000") %>" Tag="<%# HttpUtility.HtmlEncode((Container.DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("altText").Value) %>" MouseEnter="HorizontalBarEnter" MouseLeave="HorizontalBarLeave" MouseLeftButtonUp="HorizontalBarClick" 
							Canvas.Top="0" Canvas.Left="<%# ((Sql.ToInteger((Container.DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("startOffset").Value) - nAxis_xData_min) * nGridWidth) / nAxis_xData_max %>" 
							Width="<%# ((Sql.ToInteger((Container.DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("totalSize").Value) - nAxis_xData_min) * nGridWidth) / nAxis_xData_max %>" Height="16" Stroke="#eeeeee" StrokeThickness="1">
							<Rectangle.Fill>
								<LinearGradientBrush StartPoint="0.0,-0.5" EndPoint="0.0,1.0">
									<GradientStop Color="#efefef" Offset="0.0"/>
									<GradientStop Color="<%# Sql.ToString(hashColorLegend[(Container.DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("id").Value]).Replace("0x", "#") %>" Offset="1.0" />
								</LinearGradientBrush>
							</Rectangle.Fill>
						</Rectangle>
			</ItemTemplate>
			<FooterTemplate>
						<TextBlock Text="<%# HttpUtility.HtmlEncode(((Container.Parent.Parent as RepeaterItem).DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("endLabel").Value) %>" Canvas.Top="2" Canvas.Left="<%# 10 + ((Sql.ToInteger(((Container.Parent.Parent as RepeaterItem).DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("endLabel").Value) - nAxis_xData_min) * nGridWidth) / nAxis_xData_max %>" Foreground="#395163" FontFamily="Arial" FontSize="11" />
					</Canvas>
			</FooterTemplate>
		</asp:Repeater>
	</ItemTemplate>
</asp:Repeater>
				</Canvas>
			</Canvas>
		</Canvas>

		<Canvas Canvas.Left="160">
<asp:Repeater DataSource="<%# (new int[nAxis_xData_length+1]) %>" runat="server">
	<HeaderTemplate>
			<Canvas x:Name="x_labels" Canvas.Top="<%# Math.Min(nGridHeight, 226) + 32 %>" Width="<%# nGridWidth + nGridWidth / nAxis_xData_length + 1 %>" Height="20">
	</HeaderTemplate>
	<ItemTemplate>
				<TextBlock Text="<%# HttpUtility.HtmlEncode(sAxis_xData_prefix + (Container.ItemIndex * dAxis_xData_section + nAxis_xData_min).ToString() + sAxis_xData_suffix) %>" Canvas.Left="<%# Container.ItemIndex * dAxis_xData_section * nGridWidth / nAxis_xData_max %>" FontFamily="Arial" Foreground="#395163" FontSize="9" />
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
