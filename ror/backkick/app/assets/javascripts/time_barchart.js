var margin = {top: 20, right: 120, bottom: 40, left: 50},
width = 960 - margin.left - margin.right,
height = 500 - margin.top - margin.bottom;

var parseDate = d3.time.format("%Y-%m-%d").parse;

var x = d3.scale.ordinal()
    .rangeRoundBands([0, width], 0.05);

var timeX = d3.time.scale()
    .range([0, width]);

var y = d3.scale.linear()
    .range([height, 0]);

var totalY = d3.scale.linear()
    .range([height, 0]);

var xAxis = d3.svg.axis()
    .scale(x)
    .tickFormat(d3.time.format("%d"))
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left");

var yTotalAxis = d3.svg.axis()
    .scale(totalY)
    .orient("right");

var color = d3.scale.ordinal()
    .range(["steelblue", "darksalmon"]);

var totalLine = d3.svg.line()
    .interpolate("basis")
    .x(function(d) { return x(d.date); })
    .y(function(d) { return totalY(d.total_count); });

var totalPraiseLine = d3.svg.line()
    .interpolate("basis")
    .x(function(d) { return x(d.date); })
    .y(function(d) { return totalY(d.total_count_praise); });

var totalNoPraiseLine = d3.svg.line()
    .interpolate("basis")
    .x(function(d) { return x(d.date); })
    .y(function(d) { return totalY(d.total_count_no_praise); });

var svg = d3.select("body").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
    .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

d3.json("../incidents/time_barchart.json", function(data) {

    color.domain(["count_no_praise", "count_praise"]);
    
    for (var i = 0, j = i + 1; j < data.length; j++) {
        data[i].date = data[i].created_at_date;
        data[j].date = data[j].created_at_date;        
        delete(data[i]["created_at_date"]);
        data[i].date = parseDate(data[i].date);
        data[j].date = parseDate(data[j].date);
        var days = d3.time.days(data[i].date, data[j].date);
        if (days.length >= 2) {
            days.slice(1).forEach(function(d, indx) {
                data.splice(i + 1 + indx, 0, {
                    count_created_at: 0,
                    count_no_praise: 0,
                    count_praise: 0,
                    date: d,
                    sum_money_asked: 0
                });
                j++;
            });
        }
        i = j;
    }

    var total_count = 0;
    var total_count_no_praise = 0;
    var total_count_praise = 0;

    data.forEach(function(d) {
        var y0 = 0;
        d.groups = color.domain().map(function(name) {
            return {
                name: name,
                y0: y0,
                y1: y0 += +d[name]
            }
        });
        d.total_count = total_count += d.count_created_at;
        d.total_count_praise = total_count_praise += +d.count_praise;
        d.total_count_no_praise = total_count_no_praise
            = d.total_count - d.total_count_praise;
    });
    
    //timeX.domain(d3.extent(data, function(d) { return d.date; }));
    x.domain(data.map(function(d) { return d.date; }));
    y.domain([0, d3.max(data, function(d) { return d.count_created_at; })]);
    totalY.domain([0, total_count]);

    var xAxisSVG = svg.append("g");

    xAxis.tickValues(x.domain().filter(function(d, i) { return !(i % 10); }));

    xAxisSVG.attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)
        .append("text")
        .attr("y", 30)
        .style("text-anchor", "start")
        .text(data[0].date);

    xAxisSVG.append("text")
        .attr("y", 30)
        .attr("dx", width)
        .style("text-anchor", "end")
        .text(data[data.length - 1].date);

    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .text("Incidents per day");

    var yAxisSVG = svg.append("g");
    
    yAxisSVG.attr("class", "y axis")
        .attr("transform", "translate(" + width + ")")
        .call(yTotalAxis)

    yAxisSVG.append("text")
        .attr("transform", "rotate(+90)")
        .attr("x", ".5em")
        .attr("y", 16)
        .attr("dy", ".71em")
        .style("text-anchor", "start")
        .text("Incidents");

    var dateBar = svg.selectAll(".date")
        .data(data)
        .enter().append("g")
        .attr("class", "g")
        .attr("transform", function(d) {
            return "translate(" + x(d.date) + ",0)";
        });
    
    dateBar.selectAll("rect")
        .data(function(d) { return d.groups; })
        .enter().append("rect")
        .attr("width", x.rangeBand())
        .attr("y", function(d) { return y(d.y1); })
        .attr("height", function(d) { return y(d.y0) - y(d.y1); })
        .style("fill", function(d) { return color(d.name); });

    svg.append("defs")
        .append("g")
        .attr("id", "total-line")
        .append("path")
        .datum(data)
        .attr("transform", "translate(" + .5 * x.rangeBand() + ")")
        .attr("d", totalLine);

    svg.append("g")
        .append("use")
        .attr("xlink:href", "#total-line")
        .attr("class", "aura");

    svg.append("g")
        .append("use")
        .attr("xlink:href", "#total-line")
        .attr("class", "line");

    svg.append("defs")
        .append("g")
        .attr("id", "total-praise-line")
        .append("path")
        .datum(data)
        .attr("transform", "translate(" + .5 * x.rangeBand() + ")")
        .attr("d", totalPraiseLine);

    svg.append("g")
        .append("use")
        .attr("xlink:href", "#total-praise-line")
        .attr("class", "aura");

    svg.append("g")
        .append("use")
        .attr("xlink:href", "#total-praise-line")
        .attr("class", "line praise");

    svg.append("defs")
        .append("g")
        .attr("id", "total-no-praise-line")
        .append("path")
        .datum(data)
        .attr("transform", "translate(" + .5 * x.rangeBand() + ")")
        .attr("d", totalNoPraiseLine);

    svg.append("g")
        .append("use")
        .attr("xlink:href", "#total-no-praise-line")
        .attr("class", "aura");

    svg.append("g")
        .append("use")
        .attr("xlink:href", "#total-no-praise-line")
        .attr("class", "line no-praise");

var legend = svg.selectAll(".legend")
        .data(["Positive", "Negative"])
        .enter().append("g")
        .attr("class", "legend")
        .attr("transform", function(d, i) {
            return "translate(0," + i * 20 + ")"; });

    legend.append("rect")
        .attr("x", width + 72)
        .attr("width", 18)
        .attr("height", 18)
        .style("fill", color);
    
    legend.append("text")
        .attr("x", width + 66)
        .attr("y", 9)
        .attr("dy", ".35em")
        .style("text-anchor", "end")
        .text(function(d) { return d; });

    svg.append("g")
        .append("text")
        .attr("x", x(data[data.length-1].date))
        .attr("y", totalY(data[data.length-1].total_count))
        .attr("dy", "-0.7em")
        .attr("dx", "-1em")
        .style("text-anchor", "end")
        .text("Total " + data[data.length - 1].total_count);

    svg.append("g")
        .append("text")
        .attr("x", x(data[data.length-1].date))
        .attr("y", totalY(data[data.length-1].total_count_no_praise))
        .attr("dy", "-0.7em")
        .attr("dx", "-1em")
        .style("text-anchor", "end")
        .text("Total negative " + total_count_no_praise);

    svg.append("g")
        .append("text")
        .attr("x", x(data[data.length-1].date))
        .attr("y", totalY(data[data.length-1].total_count_praise))
        .attr("dy", "-0.7em")
        .attr("dx", "-1em")
        .style("text-anchor", "end")
        .text("Total positive " + total_count_praise);
});
