$(document).ready(function () {
    var DataUrl = '../backkick/incidents/total_given.json';
    $.getJSON(DataUrl, function (data) {
        $.each(data, function (index, item) {
           $('.master-black-hole .money').html(data)
        })
})
    });