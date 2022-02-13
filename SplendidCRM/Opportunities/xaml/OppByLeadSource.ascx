<%@ Control CodeBehind="OppByLeadSource.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Opportunities.xaml.OppByLeadSource" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="System.Collections" %>
<Canvas x:Name="container" Loaded="mainPieCanvasLoaded" xmlns="http://schemas.microsoft.com/client/2007" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
	<Rectangle Canvas.Top="0" Canvas.Left="0" Width="800" Height="400" Stroke="#777777" StrokeThickness="1">
		<Rectangle.Fill>
			<LinearGradientBrush StartPoint="0.0,0.0" EndPoint="0.0,1.0">
				<GradientStop Offset="0.0" Color="#fdfdfd" />
				<GradientStop Offset="1.0" Color="#e2e2e2" />
			</LinearGradientBrush>
		</Rectangle.Fill>
	</Rectangle>
	<Canvas x:Name="bound_box" <%= L10n.IsLanguageRTL() ? "FlowDirection=\"RightToLeft\"" : String.Empty %> Canvas.Top="10" Canvas.Left="10" Width="780" Height="380">
		<TextBlock Text="<%# HttpUtility.HtmlEncode(sGraphData_Title) %>" Canvas.Top="3" Canvas.Left="302" Foreground="#555555" FontFamily="Arial" FontSize="12" FontWeight="Bold" />

		<TextBlock Text="<%# HttpUtility.HtmlEncode(sGraphData_SubTitle) %>" Canvas.Top="23" Canvas.Left="302" Foreground="#666666" FontFamily="Arial" FontSize="10" TextWrapping="Wrap" />

		<Canvas Canvas.Top="90" Canvas.Left="20">
			<Rectangle Canvas.Top="0" Canvas.Left="0" Width="220" Height="30" Stroke="#666666" StrokeThickness="1" Fill="#fff9b7" />
			<TextBlock x:Name="DetailsBar" Text="<%# HttpUtility.HtmlEncode(sPie_defaultAltText) %>" Tag="<%# HttpUtility.HtmlEncode(sPie_defaultAltText) %>" Canvas.Left="3" Canvas.Top="3" Width="214" Height="24" Foreground="#636963" FontFamily="Arial" FontSize="10" TextWrapping="Wrap" Visibility="Visible" />
		</Canvas>

		<Canvas Canvas.Top="190" Canvas.Left="390">
<asp:Repeater DataSource="<%# nlDataRows %>" runat="server">
	<ItemTemplate>
			<Path Fill="#cccccc" Data="<%# (Container.DataItem as System.Xml.XmlNode).Attributes["data"].Value %>" Tag="<%# HttpUtility.HtmlEncode((Container.DataItem as System.Xml.XmlNode).Attributes["altText"].Value) %>">
				<Path.RenderTransform>
					<TransformGroup>
						<ScaleTransform CenterX="0" CenterY="0" ScaleX="1.0" ScaleY="1.0"/>
						<RotateTransform Angle="0.0"/>
						<TranslateTransform X="<%# 4.0 + Sql.ToDouble((Container.DataItem as System.Xml.XmlNode).Attributes["translation_x"].Value) %>" Y="<%# 4.0 + Sql.ToDouble((Container.DataItem as System.Xml.XmlNode).Attributes["translation_y"].Value) %>"/>
					</TransformGroup>
				</Path.RenderTransform>
			</Path>
	</ItemTemplate>
</asp:Repeater>

<asp:Repeater DataSource="<%# nlDataRows %>" Visible="<%# nlDataRows != null && nlDataRows.Count > 1 %>" runat="server">
	<ItemTemplate>
			<Rectangle x:Name="<%# "Slice_" + Container.ItemIndex.ToString("000") + "_link" %>" Tag="<%# HttpUtility.HtmlEncode((Container.DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("url").Value) %>" 
				Canvas.Top="0" Canvas.Left="0" Width="0" Height="0" Visibility="Collapsed" />
			<Path x:Name="<%# "Slice_" + Container.ItemIndex.ToString("000") %>" Stroke="#9b9b9b" 
				Data="<%# (Container.DataItem as System.Xml.XmlNode).Attributes["data"].Value %>" Tag="<%# HttpUtility.HtmlEncode((Container.DataItem as System.Xml.XmlNode).Attributes["altText"].Value) %>" MouseEnter="PieEnter" MouseLeave="PieLeave" MouseLeftButtonUp="PieClick">
				<Path.RenderTransform>
					<TransformGroup>
						<ScaleTransform CenterX="0" CenterY="0" ScaleX="1.0" ScaleY="1.0"/>
						<RotateTransform Angle="0.0"/>
						<TranslateTransform X="<%# (Container.DataItem as System.Xml.XmlNode).Attributes["translation_x"].Value %>" Y="<%# (Container.DataItem as System.Xml.XmlNode).Attributes["translation_y"].Value %>"/>
					</TransformGroup>
				</Path.RenderTransform>
				<Path.Fill>
					<RadialGradientBrush RadiusX=".5" RadiusY=".5" GradientOrigin="<%# (Container.DataItem as System.Xml.XmlNode).Attributes["gradient_x"].Value %>,<%# (Container.DataItem as System.Xml.XmlNode).Attributes["gradient_y"].Value %>">
						<RadialGradientBrush.GradientStops>
							<GradientStop Offset="0.0" Color="<%# ((Container.DataItem as System.Xml.XmlNode).Attributes["color"].Value).Replace("0x", "#") %>" />
							<GradientStop Offset="0.4" Color="<%# ((Container.DataItem as System.Xml.XmlNode).Attributes["color"].Value).Replace("0x", "#") %>" />
							<GradientStop Offset="1.2" Color="#efefef"/>
						</RadialGradientBrush.GradientStops>
					</RadialGradientBrush>
				</Path.Fill>
			</Path>
			<TextBlock Text="<%# HttpUtility.HtmlEncode((Container.DataItem as System.Xml.XmlNode).Attributes["labelText"].Value) %>" Canvas.Top="<%# (Container.DataItem as System.Xml.XmlNode).Attributes["label_y"].Value %>" Canvas.Left="<%# (Container.DataItem as System.Xml.XmlNode).Attributes["label_x"].Value %>" Foreground="#444444" FontFamily="Arial" FontSize="10" />
	</ItemTemplate>
</asp:Repeater>
<asp:Repeater DataSource="<%# nlDataRows %>" Visible="<%# nlDataRows != null && nlDataRows.Count == 1 %>" runat="server">
	<ItemTemplate>
			<Rectangle x:Name="<%# "Slice_" + Container.ItemIndex.ToString("000") + "_link" %>" Tag="<%# HttpUtility.HtmlEncode((Container.DataItem as System.Xml.XmlNode).Attributes.GetNamedItem("url").Value) %>" 
				Canvas.Top="0" Canvas.Left="0" Width="0" Height="0" Visibility="Collapsed" />
			<Ellipse x:Name="<%# "Slice_" + Container.ItemIndex.ToString("000") %>" 
				Canvas.Left="<%# -nPIE_RADIUS %>" Canvas.Top="<%# -nPIE_RADIUS %>" Width="<%# 2*nPIE_RADIUS %>" Height="<%# 2*nPIE_RADIUS %>" Stroke="#9b9b9b"
				Tag="<%# HttpUtility.HtmlEncode((Container.DataItem as System.Xml.XmlNode).Attributes["altText"].Value) %>" MouseEnter="PieEnter" MouseLeave="PieLeave" MouseLeftButtonUp="PieClick">
				<Ellipse.Fill>
					<RadialGradientBrush RadiusX=".5" RadiusY=".5" GradientOrigin="<%# (Container.DataItem as System.Xml.XmlNode).Attributes["gradient_x"].Value %>,<%# (Container.DataItem as System.Xml.XmlNode).Attributes["gradient_y"].Value %>">
						<RadialGradientBrush.GradientStops>
							<GradientStop Offset="0.0" Color="<%# ((Container.DataItem as System.Xml.XmlNode).Attributes["color"].Value).Replace("0x", "#") %>" />
							<GradientStop Offset="0.4" Color="<%# ((Container.DataItem as System.Xml.XmlNode).Attributes["color"].Value).Replace("0x", "#") %>" />
							<GradientStop Offset="1.2" Color="#efefef"/>
						</RadialGradientBrush.GradientStops>
					</RadialGradientBrush>
				</Ellipse.Fill>
			</Ellipse>
	</ItemTemplate>
</asp:Repeater>
		</Canvas>
	</Canvas>
</Canvas>
