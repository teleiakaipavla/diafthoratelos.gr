$(document).ready(function () {
    var DataUrl = 'datasource/menu.htm?rnd=' + Math.random(100000);
    $.getJSON(DataUrl, function (data) {
        $.each(data, function (index, item) {
            $('#menu').append('<li><a href="' + item.link + '">' + item.title + '</a></li>')
        })
    });
});

