// Sets up sn (super netball) canvas
var sn;

// Margins
sn = {};
sn.margin = {
    top:20,
    left:20,
    right:20,
    bottom:20
}

// Canvas dims
sn.width = 900 - sn.margin.left - sn.margin.right;
sn.height = 500 - sn.margin.top - sn.margin.bottom;

// Add to the dom (end of body, but could be elsewhere, see muyueh)
svg = d3.select("body").select(".svg-canvas").append("svg")
    .attr("width", sn.width + sn.margin.left + sn.margin.right)
    .attr("height", sn.height + sn.margin.top + sn.margin.bottom)
    .style("border", "1px solid #F78536");

// Now let's just see what happens if we try to add a chart
var dataset = [ 5, 10, 13, 19, 21, 25, 22, 18, 15, 13,
                11, 12, 15, 20, 18, 17, 16, 18, 23, 25 ];

svg.selectAll("rect")
    .data(dataset)
    .enter()
    .append("rect")
    .attr("x", function(d, i){
	return sn.margin.left + i * (sn.width / dataset.length);
    })
    .attr("y", function(d){
	return Math.max(...dataset) + sn.margin.top - d;
    })
    .attr("width", (sn.width / dataset.length) - 1)
    .attr("height", function(d, i){
	return d;
    });
