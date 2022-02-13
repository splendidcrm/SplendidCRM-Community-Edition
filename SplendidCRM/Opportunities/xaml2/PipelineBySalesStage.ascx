<%@ Control CodeBehind="PipelineBySalesStage.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Opportunities.xaml2.PipelineBySalesStage" %>
<UserControl 
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	xmlns:controls="clr-namespace:System.Windows.Controls;assembly=System.Windows.Controls.Toolkit"
	xmlns:datavis="clr-namespace:System.Windows.Controls.DataVisualization;assembly=System.Windows.Controls.DataVisualization.Toolkit"
	xmlns:charting="clr-namespace:System.Windows.Controls.DataVisualization.Charting;assembly=System.Windows.Controls.DataVisualization.Toolkit"
	xmlns:chartingprimitives="clr-namespace:System.Windows.Controls.DataVisualization.Charting.Primitives;assembly=System.Windows.Controls.DataVisualization.Toolkit"
	xmlns:splendid="clr-namespace:SplendidCRM.SilverlightContainer;assembly=SplendidCRM.SilverlightContainer"
	Width="600" Height="400">
	<UserControl.Resources>
	</UserControl.Resources>
	<Grid Background="White">
		<Grid.Resources>
<asp:Repeater DataSource="<%# dsMain.Tables %>" runat="server">
	<ItemTemplate>
			<controls:ObjectCollection x:Key="<%# (Container.DataItem as System.Data.DataTable).TableName %>">
		<asp:Repeater DataSource=<%# (Container.DataItem as System.Data.DataTable) %> runat="server">
			<ItemTemplate>
				<splendid:ChartDataElement Label="<%# HttpUtility.HtmlEncode(Sql.ToString(Eval("LABEL"))) %>" Value="<%# HttpUtility.HtmlEncode(Sql.ToString(Eval("VALUE"))) %>" DisplayValue="<%# HttpUtility.HtmlEncode(Sql.ToString(Eval("DISPLAY_VALUE"))) %>" Description="<%# HttpUtility.HtmlEncode(Sql.ToString(Eval("DESCRIPTION"))) %>" URL="<%# HttpUtility.HtmlEncode(Sql.ToString(Eval("URL"))) %>" />
			</ItemTemplate>
		</asp:Repeater>
			</controls:ObjectCollection>
	</ItemTemplate>
</asp:Repeater>

<asp:Repeater DataSource="<%# dsMain.Tables %>" runat="server">
	<ItemTemplate>
			<Style x:Key="<%# (Container.DataItem as System.Data.DataTable).TableName %>_BarDataPointStyle" TargetType="charting:BarDataPoint">
				<Setter Property="Background" Value="<%# Sql.ToString(hashColorLegend[(Container.DataItem as System.Data.DataTable).TableName]).Replace("0x", "#") %>" />
				<Setter Property="BorderBrush" Value="Black" />
				<Setter Property="BorderThickness" Value="1" />
				<Setter Property="IsTabStop" Value="False" />
				<Setter Property="DependentValueStringFormat" Value="{}{0:0.0}" />
				<Setter Property="Template">
					<Setter.Value>
						<ControlTemplate TargetType="charting:BarDataPoint">
							<Border x:Name="Root" Opacity="0" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}">
								<VisualStateManager.VisualStateGroups>
									<VisualStateGroup x:Name="CommonStates">
										<VisualStateGroup.Transitions>
											<VisualTransition GeneratedDuration="0:0:0.1" />
										</VisualStateGroup.Transitions>
										<VisualState x:Name="Normal" />
										<VisualState x:Name="MouseOver">
											<Storyboard>
												<DoubleAnimation Duration="0" Storyboard.TargetName="MouseOverHighlight" Storyboard.TargetProperty="Opacity" To="0.6" />
											</Storyboard>
										</VisualState>
									</VisualStateGroup>
									<VisualStateGroup x:Name="SelectionStates">
										<VisualStateGroup.Transitions>
											<VisualTransition GeneratedDuration="0:0:0.1" />
										</VisualStateGroup.Transitions>
										<VisualState x:Name="Unselected" />
										<VisualState x:Name="Selected">
											<Storyboard>
												<DoubleAnimation Duration="0" Storyboard.TargetName="SelectionHighlight" Storyboard.TargetProperty="Opacity" To="0.6" />
											</Storyboard>
										</VisualState>
									</VisualStateGroup>
									<VisualStateGroup x:Name="RevealStates">
										<VisualStateGroup.Transitions>
											<VisualTransition GeneratedDuration="0:0:0.5" />
										</VisualStateGroup.Transitions>
										<VisualState x:Name="Shown">
											<Storyboard>
												<DoubleAnimation Duration="0" Storyboard.TargetName="Root" Storyboard.TargetProperty="Opacity" To="1" />
											</Storyboard>
										</VisualState>
										<VisualState x:Name="Hidden">
											<Storyboard>
												<DoubleAnimation Duration="0" Storyboard.TargetName="Root" Storyboard.TargetProperty="Opacity" To="0" />
											</Storyboard>
										</VisualState>
									</VisualStateGroup>
								</VisualStateManager.VisualStateGroups>
								<ToolTipService.ToolTip>
									<StackPanel>
										<TextBlock Text="{Binding Path=DisplayValue}" />
										<TextBlock Text="{Binding Path=Description}" TextWrapping="Wrap" />
									</StackPanel>
								</ToolTipService.ToolTip>
								<Grid Background="{TemplateBinding Background}">
									<Rectangle>
										<Rectangle.Fill>
											<LinearGradientBrush>
												<GradientStop Color="#77ffffff" Offset="0" />
												<GradientStop Color="#00ffffff" Offset="1" />
											</LinearGradientBrush>
										</Rectangle.Fill>
									</Rectangle>
									<Border BorderBrush="#ccffffff" BorderThickness="1">
										<Border BorderBrush="#77ffffff" BorderThickness="1" />
									</Border>
									<Rectangle x:Name="SelectionHighlight" Fill="Red" Opacity="0" />
									<Rectangle x:Name="MouseOverHighlight" Fill="White" Opacity="0" />
								</Grid>
							</Border>
						</ControlTemplate>
					</Setter.Value>
				</Setter>
			</Style>
	</ItemTemplate>
</asp:Repeater>

			<Style x:Key="CategoryAxisLabelStyle" TargetType="charting:AxisLabel">
				<Setter Property="IsTabStop" Value="False"/>
				<Setter Property="StringFormat" Value="{}{0} "/>
				<Setter Property="Template">
					<Setter.Value>
						<ControlTemplate TargetType="charting:AxisLabel">
							<TextBlock Text="{TemplateBinding FormattedContent}"/>
						</ControlTemplate>
					</Setter.Value>
				</Setter>
			</Style>
			<Style x:Key="LinearAxisLabelStyle" TargetType="charting:AxisLabel">
				<Setter Property="IsTabStop" Value="False"/>
				<Setter Property="IsTabStop" Value="False"/>
				<Setter Property="StringFormat" Value="{}{0:c0}"/>
				<Setter Property="Template">
					<Setter.Value>
						<ControlTemplate TargetType="charting:AxisLabel">
							<TextBlock Text="{TemplateBinding FormattedContent}"/>
						</ControlTemplate>
					</Setter.Value>
				</Setter>
			</Style>
			<Style x:Key="GridLineStyle" TargetType="Line">
				<Setter Property="Stroke" Value="LightGray" />
			</Style>
		</Grid.Resources>
		<charting:Chart Title="<%# HttpUtility.HtmlEncode(sGraphData_Title) %>" Height="360" BorderThickness="0">
			<charting:Chart.Template>
				<ControlTemplate TargetType="charting:Chart">
					<Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Padding="10">
						<Grid>
							<Grid.RowDefinitions>
								<RowDefinition Height="Auto" />
								<RowDefinition Height="*" />
							</Grid.RowDefinitions>
							<datavis:Title Content="{TemplateBinding Title}" Style="{TemplateBinding TitleStyle}" Foreground="#393839" FontFamily="Arial" FontSize="12" FontWeight="Bold" />
							<Grid Grid.Row="1" Margin="0,0,0,15">
								<Grid.ColumnDefinitions>
									<ColumnDefinition Width="*" />
									<ColumnDefinition Width="Auto" />
								</Grid.ColumnDefinitions>
								<chartingprimitives:EdgePanel x:Name="ChartArea" Style="{TemplateBinding ChartAreaStyle}">
									<Grid Canvas.ZIndex="-1" Style="{TemplateBinding PlotAreaStyle}" />
									<Border Canvas.ZIndex="10" BorderBrush="#FF919191" BorderThickness="1" />
								</chartingprimitives:EdgePanel>
							</Grid>
						</Grid>
					</Border>
				</ControlTemplate>
			</charting:Chart.Template>
			<charting:Chart.Series>
<asp:Repeater DataSource="<%# dsMain.Tables %>" runat="server">
	<ItemTemplate>
				<splendid:StackedBarSeries ItemsSource="{StaticResource <%# (Container.DataItem as System.Data.DataTable).TableName %>}" IndependentValueBinding="{Binding Label}" DependentValueBinding="{Binding Value}" DataPointStyle="{StaticResource <%# (Container.DataItem as System.Data.DataTable).TableName %>_BarDataPointStyle}" Foreground="#395163" FontFamily="Arial" FontSize="11" IsSelectionEnabled="True" />
	</ItemTemplate>
</asp:Repeater>
			</charting:Chart.Series>
			<charting:Chart.Axes>
				<charting:LinearAxis Orientation="X" ShowGridLines="True" GridLineStyle="{StaticResource GridLineStyle}" Minimum="<%# nAxis_xData_min %>" Maximum="<%# nAxis_xData_max %>" Foreground="#395163" FontWeight="Normal" FontFamily="Arial" FontSize="9" AxisLabelStyle="{StaticResource LinearAxisLabelStyle}" />
				<charting:CategoryAxis Orientation="Y" Foreground="#395163" FontWeight="Normal" FontFamily="Arial" FontSize="11" AxisLabelStyle="{StaticResource CategoryAxisLabelStyle}" />
			</charting:Chart.Axes>
		</charting:Chart>
		<Canvas>
			<TextBlock Text="<%# HttpUtility.HtmlEncode(sGraphData_GraphInfo) %>" Canvas.Left="120" Canvas.Top="360" Width="<%# nGridWidth %>" Foreground="#9C9C9C" FontFamily="Arial" FontSize="10" TextWrapping="Wrap" />
		</Canvas>
	</Grid>
</UserControl>
