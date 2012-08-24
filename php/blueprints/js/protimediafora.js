$(document).ready(function () {
    var DataUrl = 'datasource/protimediafora.htm?rnd=' + Math.random(100000);
    $.getJSON(DataUrl, function (data) {
        $.each(data, function (index, item) {
            var html = '<div class="box">' + item.no + '</div><div class="descr"><div class="left"><img src="images/protimediafora/left.png" /></div><div class="rpt"><div class="pt10 pl15"><h1>' + item.title + '</h1><h2>' + item.text + '</h2></div></div><div class="clear"></div></div><div class="given">' + item.money + '</div><div class="clear"></div>'
            var holder = document.createElement("div")
            $(holder).hide();
            $(holder).append(html)
            $('#rpt').append(holder)
            $(holder).fadeIn(1000)
        })
    });
});