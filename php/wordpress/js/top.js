$(document).ready(function () {
    var DataUrl = '../backkick/public_entities/bottom_rank.json?limit=10&rnd=' + Math.random(100000);
	var rank = 1;
    $.getJSON(DataUrl, function (data) {
        $.each(data, function (index, item) {
			var html = '<div class="box">' + rank + '</div><div class="descr"><div class="left"><img src="images/protimediafora/left.png" /></div><a href="?cat=20&entity_id=' + item.id  + '&entity=' + item.name + '"><div class="rpt"><div class="pt10 pl15"><h1>' + item.name + '</h1></div></div></a><div class="clear"></div></div><div class="given">' + item.count + '</div><div class="clear"></div>'
            var holder = document.createElement("div")
			rank++;
            $(holder).hide();
            $(holder).append(html)
            $('#rpt').append(holder)
            $(holder).fadeIn(1000)
        })
    });
});


