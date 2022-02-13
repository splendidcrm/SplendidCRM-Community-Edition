<%@ Control CodeBehind="OppByLeadSource.ascx.cs" Language="c#" AutoEventWireup="false" Inherits="SplendidCRM.Opportunities.xaml2.OppByLeadSource" %>
<UserControl 
	xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
	xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
	xmlns:controls="clr-namespace:System.Windows.Controls;assembly=System.Windows.Controls.Toolkit"
	xmlns:datavis="clr-namespace:System.Windows.Controls.DataVisualization;assembly=System.Windows.Controls.DataVisualization.Toolkit"
	xmlns:charting="clr-namespace:System.Windows.Controls.DataVisualization.Charting;assembly=System.Windows.Controls.DataVisualization.Toolkit"
	xmlns:chartingprimitives="clr-namespace:System.Windows.Controls.DataVisualization.Charting.Primitives;assembly=System.Windows.Controls.DataVisualization.Toolkit"
	xmlns:splendid="clr-namespace:SplendidCRM.SilverlightContainer;assembly=SplendidCRM.SilverlightContainer"
	Width="800" Height="400">
	<Grid Background="White">
		<Rectangle Canvas.Top="0" Canvas.Left="0" Width="800" Height="400" Stroke="#777777" StrokeThickness="1">
			<Rectangle.Fill>
				<LinearGradientBrush StartPoint="0.0,0.0" EndPoint="0.0,1.0">
					<GradientStop Offset="0.0" Color="#fdfdfd" />
					<GradientStop Offset="1.0" Color="#e2e2e2" />
				</LinearGradientBrush>
			</Rectangle.Fill>
		</Rectangle>
		<Grid.Resources>
			<controls:ObjectCollection x:Key="SeriesData">
<asp:Repeater DataSource="<%# vwMain %>" runat="server">
	<ItemTemplate>
				<splendid:ChartDataElement Label="<%# HttpUtility.HtmlEncode(Sql.ToString(Eval("LABEL"))) %>" Value="<%# HttpUtility.HtmlEncode(Sql.ToString(Eval("VALUE"))) %>" DisplayValue="<%# HttpUtility.HtmlEncode(Sql.ToString(Eval("DISPLAY_VALUE"))) %>" Description="<%# HttpUtility.HtmlEncode(Sql.ToString(Eval("DESCRIPTION"))) %>" URL="<%# HttpUtility.HtmlEncode(Sql.ToString(Eval("URL"))) %>" />
	</ItemTemplate>
</asp:Repeater>
			</controls:ObjectCollection>
			<ControlTemplate x:Key="MyPieDataPointTemplate" TargetType="charting:PieDataPoint">
				<Grid x:Name="Root" Opacity="0" >
					<VisualStateManager.VisualStateGroups>
						<VisualStateGroup x:Name="CommonStates">
							<VisualStateGroup.Transitions>
								<VisualTransition GeneratedDuration="0:0:0.1" />
							</VisualStateGroup.Transitions>
							<VisualState x:Name="Normal" />
							<VisualState x:Name="MouseOver">
								<Storyboard>
									<DoubleAnimation Storyboard.TargetName="MouseOverHighlight" Storyboard.TargetProperty="Opacity" To="0.6" Duration="0" />
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
									<DoubleAnimation Storyboard.TargetName="SelectionHighlight" Storyboard.TargetProperty="Opacity" To="0.6" Duration="0" />
								</Storyboard>
							</VisualState>
						</VisualStateGroup>
						<VisualStateGroup x:Name="RevealStates">
							<VisualStateGroup.Transitions>
								<VisualTransition GeneratedDuration="0:0:0.5" />
							</VisualStateGroup.Transitions>
							<VisualState x:Name="Shown">
								<Storyboard>
									<DoubleAnimation Storyboard.TargetName="Root" Storyboard.TargetProperty="Opacity" To="1" Duration="0" />
								</Storyboard>
							</VisualState>
							<VisualState x:Name="Hidden">
								<Storyboard>
									<DoubleAnimation Storyboard.TargetName="Root" Storyboard.TargetProperty="Opacity" To="0" Duration="0" />
								</Storyboard>
							</VisualState>
						</VisualStateGroup>
					</VisualStateManager.VisualStateGroups>
					<Path x:Name="Slice" Data="{TemplateBinding Geometry}" Fill="{TemplateBinding Background}" Stroke="{TemplateBinding BorderBrush}" StrokeMiterLimit="1">
						<ToolTipService.ToolTip>
							<StackPanel>
								<ContentControl Content="{Binding Path=Label}" FontWeight="Bold" />
								<ContentControl Content="{Binding Path=DisplayValue}" />
								<ContentControl Content="{TemplateBinding FormattedRatio}" />
								<TextBlock Text="{Binding Path=Description}" TextWrapping="Wrap" />
							</StackPanel>
						</ToolTipService.ToolTip>
					</Path>
					<Path x:Name="SelectionHighlight" Data="{TemplateBinding GeometrySelection}" Fill="Red" StrokeMiterLimit="1" IsHitTestVisible="False" Opacity="0" />
					<Path x:Name="MouseOverHighlight" Data="{TemplateBinding GeometryHighlight}" Fill="White" StrokeMiterLimit="1" IsHitTestVisible="False" Opacity="0" />
				</Grid>
			</ControlTemplate>
		</Grid.Resources>

		<charting:Chart Title="<%# HttpUtility.HtmlEncode(sGraphData_Title) %>">
			<charting:Chart.Template>
				<ControlTemplate TargetType="charting:Chart">
					<Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" Padding="10">
						<Grid>
							<Grid.RowDefinitions>
								<RowDefinition Height="Auto" />
								<RowDefinition Height="*" />
							</Grid.RowDefinitions>
							<StackPanel>
								<datavis:Title Content="{TemplateBinding Title}" Foreground="#555555" FontFamily="Arial" FontSize="12" FontWeight="Bold" HorizontalContentAlignment="Center" />
								<datavis:Title Content="<%# HttpUtility.HtmlEncode(sGraphData_SubTitle) %>" Foreground="#666666" FontFamily="Arial" FontSize="10" HorizontalContentAlignment="Center" />
							</StackPanel>
							<Grid Grid.Row="1" Margin="0,15,0,15">
								<Grid.ColumnDefinitions>
									<ColumnDefinition Width="*" />
									<ColumnDefinition Width="Auto" />
								</Grid.ColumnDefinitions>
								<datavis:Legend x:Name="Legend" Title="{TemplateBinding LegendTitle}" Style="{TemplateBinding LegendStyle}" Grid.Column="1" />
								<chartingprimitives:EdgePanel x:Name="ChartArea" Style="{TemplateBinding ChartAreaStyle}" />
							</Grid>
						</Grid>
					</Border>
				</ControlTemplate>
			</charting:Chart.Template>
			<charting:Chart.Series>
				<charting:PieSeries 
					AnimationSequence="FirstToLast" 
					ItemsSource="{StaticResource SeriesData}" 
					IndependentValueBinding="{Binding Label}" 
					DependentValueBinding="{Binding Value}">
					<charting:PieSeries.StylePalette>
						<datavis:StylePalette>
							<!--Blue-->
							<Style TargetType="Control">
								<Setter Property="Template" Value="{StaticResource MyPieDataPointTemplate}" />
								<Setter Property="Background">
									<Setter.Value>
										<RadialGradientBrush>
											<RadialGradientBrush.RelativeTransform>
												<TransformGroup>
													<ScaleTransform CenterX="0.5" CenterY="0.5" ScaleX="2.09" ScaleY="1.819" />
													<TranslateTransform X="-0.425" Y="-0.486" />
												</TransformGroup>
											</RadialGradientBrush.RelativeTransform>
											<GradientStop Color="#FFB9D6F7" />
											<GradientStop Color="#FF284B70" Offset="1" />
										</RadialGradientBrush>
									</Setter.Value>
								</Setter>
							</Style>
							<!--Red-->
							<Style TargetType="Control">
								<Setter Property="Template" Value="{StaticResource MyPieDataPointTemplate}" />
								<Setter Property="Background">
									<Setter.Value>
										<RadialGradientBrush>
											<RadialGradientBrush.RelativeTransform>
												<TransformGroup>
													<ScaleTransform CenterX="0.5" CenterY="0.5" ScaleX="2.09" ScaleY="1.819" />
													<TranslateTransform X="-0.425" Y="-0.486" />
												</TransformGroup>
											</RadialGradientBrush.RelativeTransform>
											<GradientStop Color="#FFFBB7B5" />
											<GradientStop Color="#FF702828" Offset="1" />
										</RadialGradientBrush>
									</Setter.Value>
								</Setter>
							</Style>
							<!-- Light Green -->
							<Style TargetType="Control">
								<Setter Property="Template" Value="{StaticResource MyPieDataPointTemplate}" />
								<Setter Property="Background">
									<Setter.Value>
										<RadialGradientBrush>
											<RadialGradientBrush.RelativeTransform>
												<TransformGroup>
													<ScaleTransform CenterX="0.5" CenterY="0.5" ScaleX="2.09" ScaleY="1.819" />
													<TranslateTransform X="-0.425" Y="-0.486" />
												</TransformGroup>
											</RadialGradientBrush.RelativeTransform>
											<GradientStop Color="#FFB8C0AC" />
											<GradientStop Color="#FF5F7143" Offset="1" />
										</RadialGradientBrush>
									</Setter.Value>
								</Setter>
							</Style>
							<!-- Yellow -->
							<Style TargetType="Control">
								<Setter Property="Template" Value="{StaticResource MyPieDataPointTemplate}" />
								<Setter Property="Background">
									<Setter.Value>
										<RadialGradientBrush>
											<RadialGradientBrush.RelativeTransform>
												<TransformGroup>
													<ScaleTransform CenterX="0.5" CenterY="0.5" ScaleX="2.09" ScaleY="1.819" />
													<TranslateTransform X="-0.425" Y="-0.486" />
												</TransformGroup>
											</RadialGradientBrush.RelativeTransform>
											<GradientStop Color="#FFFDE79C" />
											<GradientStop Color="#FFF6BC0C" Offset="1" />
										</RadialGradientBrush>
									</Setter.Value>
								</Setter>
							</Style>
							<!-- Indigo -->
							<Style TargetType="Control">
								<Setter Property="Template" Value="{StaticResource MyPieDataPointTemplate}" />
								<Setter Property="Background">
									<Setter.Value>
										<RadialGradientBrush>
											<RadialGradientBrush.RelativeTransform>
												<TransformGroup>
													<ScaleTransform CenterX="0.5" CenterY="0.5" ScaleX="2.09" ScaleY="1.819" />
													<TranslateTransform X="-0.425" Y="-0.486" />
												</TransformGroup>
											</RadialGradientBrush.RelativeTransform>
											<GradientStop Color="#FFA9A3BD" />
											<GradientStop Color="#FF382C6C" Offset="1" />
										</RadialGradientBrush>
									</Setter.Value>
								</Setter>
							</Style>
							<!-- Magenta -->
							<Style TargetType="Control">
								<Setter Property="Template" Value="{StaticResource MyPieDataPointTemplate}" />
								<Setter Property="Background">
									<Setter.Value>
										<RadialGradientBrush>
											<RadialGradientBrush.RelativeTransform>
												<TransformGroup>
													<ScaleTransform CenterX="0.5" CenterY="0.5" ScaleX="2.09" ScaleY="1.819" />
													<TranslateTransform X="-0.425" Y="-0.486" />
												</TransformGroup>
											</RadialGradientBrush.RelativeTransform>
											<GradientStop Color="#FFB1A1B1" />
											<GradientStop Color="#FF50224F" Offset="1" />
										</RadialGradientBrush>
									</Setter.Value>
								</Setter>
							</Style>
							<!-- Dark Green -->
							<Style TargetType="Control">
								<Setter Property="Template" Value="{StaticResource MyPieDataPointTemplate}" />
								<Setter Property="Background">
									<Setter.Value>
										<RadialGradientBrush>
											<RadialGradientBrush.RelativeTransform>
												<TransformGroup>
													<ScaleTransform CenterX="0.5" CenterY="0.5" ScaleX="2.09" ScaleY="1.819" />
													<TranslateTransform X="-0.425" Y="-0.486" />
												</TransformGroup>
											</RadialGradientBrush.RelativeTransform>
											<GradientStop Color="#FF9DC2B3" />
											<GradientStop Color="#FF1D7554" Offset="1" />
										</RadialGradientBrush>
									</Setter.Value>
								</Setter>
							</Style>
							<!--Gray Shade-->
							<Style TargetType="Control">
								<Setter Property="Template" Value="{StaticResource MyPieDataPointTemplate}" />
								<Setter Property="Background">
									<Setter.Value>
										<RadialGradientBrush>
											<RadialGradientBrush.RelativeTransform>
												<TransformGroup>
													<ScaleTransform CenterX="0.5" CenterY="0.5" ScaleX="2.09" ScaleY="1.819" />
													<TranslateTransform X="-0.425" Y="-0.486" />
												</TransformGroup>
											</RadialGradientBrush.RelativeTransform>
											<GradientStop Color="#FFB5B5B5" />
											<GradientStop Color="#FF4C4C4C" Offset="1" />
										</RadialGradientBrush>
									</Setter.Value>
								</Setter>
							</Style>
							<!--Blue-->
							<Style TargetType="Control">
								<Setter Property="Template" Value="{StaticResource MyPieDataPointTemplate}" />
								<Setter Property="Background">
									<Setter.Value>
										<RadialGradientBrush>
											<RadialGradientBrush.RelativeTransform>
												<TransformGroup>
													<ScaleTransform CenterX="0.5" CenterY="0.5" ScaleX="2.09" ScaleY="1.819" />
													<TranslateTransform X="-0.425" Y="-0.486" />
												</TransformGroup>
											</RadialGradientBrush.RelativeTransform>
											<GradientStop Color="#FF98C1DC" />
											<GradientStop Color="#FF0271AE" Offset="1" />
										</RadialGradientBrush>
									</Setter.Value>
								</Setter>
							</Style>
							<!-- Brown -->
							<Style TargetType="Control">
								<Setter Property="Template" Value="{StaticResource MyPieDataPointTemplate}" />
								<Setter Property="Background">
									<Setter.Value>
										<RadialGradientBrush>
											<RadialGradientBrush.RelativeTransform>
												<TransformGroup>
													<ScaleTransform CenterX="0.5" CenterY="0.5" ScaleX="2.09" ScaleY="1.819" />
													<TranslateTransform X="-0.425" Y="-0.486" />
												</TransformGroup>
											</RadialGradientBrush.RelativeTransform>
											<GradientStop Color="#FFC1C0AE" />
											<GradientStop Color="#FF706E41" Offset="1" />
										</RadialGradientBrush>
									</Setter.Value>
								</Setter>
							</Style>
							<!--Cyan-->
							<Style TargetType="Control">
								<Setter Property="Template" Value="{StaticResource MyPieDataPointTemplate}" />
								<Setter Property="Background">
									<Setter.Value>
										<RadialGradientBrush>
											<RadialGradientBrush.RelativeTransform>
												<TransformGroup>
													<ScaleTransform CenterX="0.5" CenterY="0.5" ScaleX="2.09" ScaleY="1.819" />
													<TranslateTransform X="-0.425" Y="-0.486" />
												</TransformGroup>
											</RadialGradientBrush.RelativeTransform>
											<GradientStop Color="#FFADBDC0" />
											<GradientStop Color="#FF446A73" Offset="1" />
										</RadialGradientBrush>
									</Setter.Value>
								</Setter>
							</Style>
							<!-- Special Blue -->
							<Style TargetType="Control">
								<Setter Property="Template" Value="{StaticResource MyPieDataPointTemplate}" />
								<Setter Property="Background">
									<Setter.Value>
										<RadialGradientBrush>
											<RadialGradientBrush.RelativeTransform>
												<TransformGroup>
													<ScaleTransform CenterX="0.5" CenterY="0.5" ScaleX="2.09" ScaleY="1.819" />
													<TranslateTransform X="-0.425" Y="-0.486" />
												</TransformGroup>
											</RadialGradientBrush.RelativeTransform>
											<GradientStop Color="#FF2F8CE2" />
											<GradientStop Color="#FF0C3E69" Offset="1" />
										</RadialGradientBrush>
									</Setter.Value>
								</Setter>
							</Style>
							<!--Gray Shade 2-->
							<Style TargetType="Control">
								<Setter Property="Template" Value="{StaticResource MyPieDataPointTemplate}" />
								<Setter Property="Background">
									<Setter.Value>
										<RadialGradientBrush>
											<RadialGradientBrush.RelativeTransform>
												<TransformGroup>
													<ScaleTransform CenterX="0.5" CenterY="0.5" ScaleX="2.09" ScaleY="1.819" />
													<TranslateTransform X="-0.425" Y="-0.486" />
												</TransformGroup>
											</RadialGradientBrush.RelativeTransform>
											<GradientStop Color="#FFDCDCDC" />
											<GradientStop Color="#FF757575" Offset="1" />
										</RadialGradientBrush>
									</Setter.Value>
								</Setter>
							</Style>
							<!--Gray Shade 3-->
							<Style TargetType="Control">
								<Setter Property="Template" Value="{StaticResource MyPieDataPointTemplate}" />
								<Setter Property="Background">
									<Setter.Value>
										<RadialGradientBrush>
											<RadialGradientBrush.RelativeTransform>
												<TransformGroup>
													<ScaleTransform CenterX="0.5" CenterY="0.5" ScaleX="2.09" ScaleY="1.819" />
													<TranslateTransform X="-0.425" Y="-0.486" />
												</TransformGroup>
											</RadialGradientBrush.RelativeTransform>
											<GradientStop Color="#FFF4F4F4" />
											<GradientStop Color="#FFB7B7B7" Offset="1" />
										</RadialGradientBrush>
									</Setter.Value>
								</Setter>
							</Style>
							<!--Gray Shade 4-->
							<Style TargetType="Control">
								<Setter Property="Template" Value="{StaticResource MyPieDataPointTemplate}" />
								<Setter Property="Background">
									<Setter.Value>
										<RadialGradientBrush>
											<RadialGradientBrush.RelativeTransform>
												<TransformGroup>
													<ScaleTransform CenterX="0.5" CenterY="0.5" ScaleX="2.09" ScaleY="1.819" />
													<TranslateTransform X="-0.425" Y="-0.486" />
												</TransformGroup>
											</RadialGradientBrush.RelativeTransform>
											<GradientStop Color="#FFF4F4F4" />
											<GradientStop Color="#FFA3A3A3" Offset="1" />
										</RadialGradientBrush>
									</Setter.Value>
								</Setter>
							</Style>
						</datavis:StylePalette>
					</charting:PieSeries.StylePalette>
				</charting:PieSeries>
			</charting:Chart.Series>
		</charting:Chart>
	</Grid>
</UserControl>
