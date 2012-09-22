$(document).ready(function () {
    var DataUrl = '../backkick/public_entities/bottom_ten.json?rnd=' + Math.random(100000);
	var rank = 1;
    $.getJSON(DataUrl, function (data) {
        $.each(data, function (index, item) {
			var html = '<div class="box">' + rank + '</div><div class="descr"><div class="left"><img src="images/protimediafora/left.png" /></div><div class="rpt"><div class="pt10 pl15"><h1>' + item.name + '</h1><h2>' + item.count + ' περιστατικά διαφθοράς</h2></div></div><div class="clear"></div></div><div class="given">' + item.total_money_given + '</div><div class="clear"></div>'
            var holder = document.createElement("div")
			rank++;
            $(holder).hide();
            $(holder).append(html)
            $('#rpt').append(holder)
            $(holder).fadeIn(1000)
        })
    });
});