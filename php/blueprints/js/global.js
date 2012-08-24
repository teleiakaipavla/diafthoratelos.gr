$(document).ready(function () {
    var DataUrl = 'datasource/menu.htm?rnd=' + Math.random(100000);
    $.getJSON(DataUrl, function (data) {
        $.each(data, function (index, item) {
            $('#menu').append('<li><a href="' + item.link + '">' + item.title + '</a></li>')
        })
    });
});



function ClearTxt(obj, text) {
    if ($(obj).val() == text) {
        $(obj).val('')
    }
}

function ResetTxt(obj, text) {
    if ($(obj).val() == '') {
        $(obj).val(text)
    }
}