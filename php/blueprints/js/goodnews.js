var pageno = 0
var myscroller;
$(document).ready(function () {
    $('#category').nk_dropdown({ width: 202, pointerUrl: 'js/nkal/dropdown/themes/telia/pointer.png', srcText: 'Αναζήτηση..', classname: 'telia', srcType: true, datasource: '/telia/datasource/category.htm', datatext: 'name', datavalue: 'id', resultExtraStyle: 'font-size:12px' });
    $('#city').nk_dropdown({ width: 202, pointerUrl: 'js/nkal/dropdown/themes/telia/pointer.png', srcText: 'Αναζήτηση..', classname: 'telia', srcType: true, datasource: '/telia/datasource/city.htm', datatext: 'name', datavalue: 'id', resultExtraStyle: 'font-size:12px' });
    $('#carrier').nk_dropdown({ width: 286, pointerUrl: 'js/nkal/dropdown/themes/telia/pointer.png', srcText: 'Αναζήτηση..', classname: 'telia', srcType: true, datasource: '/telia/datasource/foreas.htm', datatext: 'name', datavalue: 'id', resultExtraStyle: 'font-size:12px' });
    BindGrid(true)
    myscroller = $('.grid').jScrollPane({ animateScroll: true, horizontalGutter: 3, autoReinitialise: true })
    SetScrollLoad()

    BindTopTen()
});

function BindTopTen() {
    
    var DataUrl = 'datasource/topten.htm?rnd=' + Math.random(100000) ;
    $.getJSON(DataUrl, function (data) {
        $.each(data, function (index, item) {
            var html = '<div class="box">' + item.no + '</div><div class="holder"><div class="p5"><h1>' + item.title + '</h1><h2>' + item.text + '</h2></div></div><div class="clear"></div>'
            var holder = document.createElement("div")
            $(holder).hide();
            $(holder).append(html)
            $('#rpttopten').append(holder)
            $(holder).fadeIn(1000)
        })


    });
}

function BindGrid(gotonextpage) {
    if (gotonextpage)
        pageno = pageno + 1
    var category = $('#category').val()
    var city = $('#city').val()
    var carrier = $('#carrier').val()
    var DataUrl = 'datasource/goodnews.htm?rnd=' + Math.random(100000) + '&pageno=' + pageno + '&category=' + category + '&city=' + city + '&carrier=' + carrier;
    $.getJSON(DataUrl, function (data) {
        $.each(data, function (index, item) {
            var html = '<div class="incidents"><div class="categories">' + item.categories + '</div><div class="descr">' + item.descr + '</div><div class="datetime">' + item.datetime + '</div></div>'
            var holder = document.createElement("div")
            $(holder).hide();
            $(holder).append(html)
            $('#rpt').append(holder)
            $(holder).fadeIn(1000)
        })


    });
}


function SetScrollLoad() {

    $(myscroller).bind('scroll', function (e) {
        var api = myscroller.data('jsp');
        var Position = 500 + api.getContentPositionY()
        var Limiter = 500 + parseInt(api.getContentPositionY()) + 390 // 130 = 1 row ( set how many rows before you want to load next page)
        var All = $('#rpt').height()
        if (Limiter > All) {
            BindGrid(true)
        }
    }
);


}