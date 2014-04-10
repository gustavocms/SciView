/**
 * Created by paulmestemaker on 3/25/14.
 */
// This is a manifest file that'll be compiled into paulD3.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery.js
//= require d3.v3
//= require nv.d3.js
//= require stream_layers



//$(document).ready(
//    function(){
//        var dataArray = [5, 40, 50, 57];
//        var width = 500;
//        var height = 500;
//        var widthScale = d3.scale.linear()
//            .domain([0, 60])
//            .range([0, width]);
//
//        var colorScale = d3.scale.linear()
//            .domain([0, 60])
//            .range(["red", "blue"]);
//
//        var axis = d3.svg.axis()
//            .scale(widthScale)
//            .ticks(5);
//
//        var canvas = d3.select("body")
//            .append("svg")
//            .attr("width", width)
//            .attr("height", height);
//
//        var groupBackground = canvas.append("g");
//        var groupForeground = canvas.append("g");
//        var gAxis = canvas.append("g");
//
//        groupBackground.append("rect")
//            .attr("width", "100%")
//            .attr("height", "100%")
//            .attr("fill", "pink");
//
//        gAxis.attr("transform", "translate(0, 400)").call(axis);
//
//        var bars = groupForeground.selectAll("rect")
//            .data(dataArray)
//            .enter()
//            .append("rect")
//            .attr("width", function(d) {return widthScale(d); })
//            .attr("height", 50)
//            .attr("fill", function(d) {return colorScale(d); })
//            .attr("y", function(d, i) {return i * 100; });
//    }
//);
