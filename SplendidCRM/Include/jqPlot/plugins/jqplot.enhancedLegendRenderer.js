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
function($) {
    // class $.jqplot.EnhancedLegendRenderer
    // Legend renderer which can specify the number of rows and/or columns in the legend.
    $.jqplot.EnhancedLegendRenderer = function(){
        $.jqplot.TableLegendRenderer.call(this);
    };
    
    $.jqplot.EnhancedLegendRenderer.prototype = new $.jqplot.TableLegendRenderer();
    $.jqplot.EnhancedLegendRenderer.prototype.constructor = $.jqplot.EnhancedLegendRenderer;
    
    // called with scope of legend.
    $.jqplot.EnhancedLegendRenderer.prototype.init = function(options) {
        // prop: numberRows
        // Maximum number of rows in the legend.  0 or null for unlimited.
        this.numberRows = null;
        // prop: numberColumns
        // Maximum number of columns in the legend.  0 or null for unlimited.
        this.numberColumns = null;
        // prop: seriesToggle
        // false to not enable series on/off toggling on the legend.
        // true or a fadein/fadeout speed (number of milliseconds or 'fast', 'normal', 'slow') 
        // to enable show/hide of series on click of legend item.
        this.seriesToggle = 'normal';
        // prop: seriesToggleReplot
        // True to replot the chart after toggling series on/off.
        // This will set the series show property to false.
        // This allows for rescaling or other maniplation of chart.
        // Set to an options object (e.g. {resetAxes: true}) for replot options.
        this.seriesToggleReplot = false;
        // prop: disableIEFading
        // true to toggle series with a show/hide method only and not allow fading in/out.  
        // This is to overcome poor performance of fade in some versions of IE.
        this.disableIEFading = true;
        // 06/21/2013 Paul.  Reverse is not a property. 
        this.reverse = false;
        $.extend(true, this, options);
        
        if (this.seriesToggle) {
            $.jqplot.postDrawHooks.push(postDraw);
        }
    };
    
    // called with scope of legend
    $.jqplot.EnhancedLegendRenderer.prototype.draw = function(offsets, plot) {
        var legend = this;
        if (this.show) {
            var series = this._series;
            var s;
            var ss = 'position:absolute;';
            ss += (this.background) ? 'background:'+this.background+';' : '';
            ss += (this.border) ? 'border:'+this.border+';' : '';
            ss += (this.fontSize) ? 'font-size:'+this.fontSize+';' : '';
            ss += (this.fontFamily) ? 'font-family:'+this.fontFamily+';' : '';
            ss += (this.textColor) ? 'color:'+this.textColor+';' : '';
            ss += (this.marginTop != null) ? 'margin-top:'+this.marginTop+';' : '';
            ss += (this.marginBottom != null) ? 'margin-bottom:'+this.marginBottom+';' : '';
            ss += (this.marginLeft != null) ? 'margin-left:'+this.marginLeft+';' : '';
            ss += (this.marginRight != null) ? 'margin-right:'+this.marginRight+';' : '';
            this._elem = $('<table class="jqplot-table-legend" style="'+ss+'"></table>');
            if (this.seriesToggle) {
                this._elem.css('z-index', '3');
            }
        
            var pad = false;
            // 06/21/2013 Paul.  Reverse is not a property. 
            //var reverse = false;
            var nr, nc;
            if (this.numberRows) {
                nr = this.numberRows;
                if (!this.numberColumns){
                    nc = Math.ceil(series.length/nr);
                }
                else{
                    nc = this.numberColumns;
                }
            }
            else if (this.numberColumns) {
                nc = this.numberColumns;
                nr = Math.ceil(series.length/this.numberColumns);
            }
            else {
                nr = series.length;
                nc = 1;
            }
                
            var i, j, tr, td1, td2, lt, rs, div, div0, div1;
            var idx = 0;
            // check to see if we need to reverse
            for (i=series.length-1; i>=0; i--) {
                if (nc == 1 && series[i]._stack || series[i].renderer.constructor == $.jqplot.BezierCurveRenderer)
                {
                    // 06/21/2013 Paul.  Reverse is not a property. 
                    this.reverse = true;
                }
            }    
                
            for (i=0; i<nr; i++) {
                tr = $(document.createElement('tr'));
                tr.addClass('jqplot-table-legend');
                // 06/21/2013 Paul.  Reverse is not a property. 
                if (this.reverse){
                    tr.prependTo(this._elem);
                }
                else{
                    tr.appendTo(this._elem);
                }
                for (j=0; j<nc; j++) {
                    if (idx < series.length && (series[idx].show || series[idx].showLabel)){
                        s = series[idx];
                        lt = this.labels[idx] || s.label.toString();
                        if (lt) {
                            var color = s.color;
                            // 06/21/2013 Paul.  Reverse is not a property. 
                            if (!this.reverse){
                                if (i>0){
                                    pad = true;
                                }
                                else{
                                    pad = false;
                                }
                            }
                            else{
                                if (i == nr -1){
                                    pad = false;
                                }
                                else{
                                    pad = true;
                                }
                            }
                            rs = (pad) ? this.rowSpacing : '0';

                            td1 = $(document.createElement('td'));
                            td1.addClass('jqplot-table-legend jqplot-table-legend-swatch');
                            td1.css({textAlign: 'center', paddingTop: rs});

                            div0 = $(document.createElement('div'));
                            div0.addClass('jqplot-table-legend-swatch-outline');
                            div1 = $(document.createElement('div'));
                            div1.addClass('jqplot-table-legend-swatch');
                            div1.css({backgroundColor: color, borderColor: color});

                            td1.append(div0.append(div1));

                            td2 = $(document.createElement('td'));
                            td2.addClass('jqplot-table-legend jqplot-table-legend-label');
                            td2.css('paddingTop', rs);
                    
                            // td1 = $('<td class="jqplot-table-legend" style="text-align:center;padding-top:'+rs+';">'+
                            //     '<div><div class="jqplot-table-legend-swatch" style="background-color:'+color+';border-color:'+color+';"></div>'+
                            //     '</div></td>');
                            // td2 = $('<td class="jqplot-table-legend" style="padding-top:'+rs+';"></td>');
                            if (this.escapeHtml){
                                td2.text(lt);
                            }
                            else {
                                td2.html(lt);
                            }
                            // 06/21/2013 Paul.  Reverse is not a property. 
                            if (this.reverse) {
                                if (this.showLabels) {td2.prependTo(tr);}
                                if (this.showSwatches) {td1.prependTo(tr);}
                            }
                            else {
                                if (this.showSwatches) {td1.appendTo(tr);}
                                if (this.showLabels) {td2.appendTo(tr);}
                            }
                            
                            if (this.seriesToggle) {

                                // add an overlay for clicking series on/off
                                // div0 = $(document.createElement('div'));
                                // div0.addClass('jqplot-table-legend-overlay');
                                // div0.css({position:'relative', left:0, top:0, height:'100%', width:'100%'});
                                // tr.append(div0);

                                var speed;
                                if (typeof(this.seriesToggle) === 'string' || typeof(this.seriesToggle) === 'number') {
                                    if (!$.jqplot.use_excanvas || !this.disableIEFading) {
                                        speed = this.seriesToggle;
                                    }
                                } 
                                if (this.showSwatches) {
                                    td1.bind('click', {series:s, speed:speed, plot: plot, replot:this.seriesToggleReplot}, handleToggle);
                                    td1.addClass('jqplot-seriesToggle');
                                }
                                if (this.showLabels)  {
                                    td2.bind('click', {series:s, speed:speed, plot: plot, replot:this.seriesToggleReplot}, handleToggle);
                                    td2.addClass('jqplot-seriesToggle');
                                }

                                // for series that are already hidden, add the hidden class
                                if (!s.show && s.showLabel) {
                                    td1.addClass('jqplot-series-hidden');
                                    td2.addClass('jqplot-series-hidden');
                                }
                            }
                            
                            pad = true;
                        }
                    }
                    idx++;
                }
                
                td1 = td2 = div0 = div1 = null;   
            }
        }
        return this._elem;
    };

    var handleToggle = function (ev) {
        var d = ev.data,
            s = d.series,
            replot = d.replot,
            plot = d.plot,
            speed = d.speed,
            sidx = s.index,
            showing = false;

        if (s.canvas._elem.is(':hidden') || !s.show) {
            showing = true;
        }

        var doLegendToggle = function() {

            if (replot) {
                var opts = {};

                if ($.isPlainObject(replot)) {
                    $.extend(true, opts, replot);
                }

                plot.replot(opts);
                // if showing, there was no canvas element to fade in, so hide here
                // and then do a fade in.
                if (showing && speed) {
                    var s = plot.series[sidx];

                    if (s.shadowCanvas._elem) {
                        s.shadowCanvas._elem.hide().fadeIn(speed);
                    }
                    s.canvas._elem.hide().fadeIn(speed);
                    s.canvas._elem.nextAll('.jqplot-point-label.jqplot-series-'+s.index).hide().fadeIn(speed);
                }

            }

            else {
                var s = plot.series[sidx];

                if (s.canvas._elem.is(':hidden') || !s.show) {
                    // Not sure if there is a better way to check for showSwatches and showLabels === true.
                    // Test for "undefined" since default values for both showSwatches and showLables is true.
                    if (typeof plot.options.legend.showSwatches === 'undefined' || plot.options.legend.showSwatches === true) {
                        plot.legend._elem.find('td').eq(sidx * 2).addClass('jqplot-series-hidden');
                    }
                    if (typeof plot.options.legend.showLabels === 'undefined' || plot.options.legend.showLabels === true) {
                        plot.legend._elem.find('td').eq((sidx * 2) + 1).addClass('jqplot-series-hidden');
                    }
                }
                else {
                    if (typeof plot.options.legend.showSwatches === 'undefined' || plot.options.legend.showSwatches === true) {
                        plot.legend._elem.find('td').eq(sidx * 2).removeClass('jqplot-series-hidden');
                    }
                    if (typeof plot.options.legend.showLabels === 'undefined' || plot.options.legend.showLabels === true) {
                        plot.legend._elem.find('td').eq((sidx * 2) + 1).removeClass('jqplot-series-hidden');
                    }
                }

            }

        };

        s.toggleDisplay(ev, doLegendToggle);
    };
    
    // called with scope of plot.
    var postDraw = function () {
        if (this.legend.renderer.constructor == $.jqplot.EnhancedLegendRenderer && this.legend.seriesToggle){
            var e = this.legend._elem.detach();
            this.eventCanvas._elem.after(e);
        }
    };
})(jQuery);
