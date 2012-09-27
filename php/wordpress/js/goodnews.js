var pageno = 0
var myscroller;
$(document).ready(function () {
    $('#category').nk_dropdown({ width: 202, pointerUrl: 'js/nkal/dropdown/themes/telia/pointer.png',  classname: 'telia', srcType: false, datasource: '../backkick/categories.json', datatext: 'name', datavalue: 'id', resultExtraStyle: 'font-size:12px' });
    //$('#city').nk_dropdown({ width: 202, pointerUrl: 'js/nkal/dropdown/themes/telia/pointer.png', srcText: 'Αναζήτηση..', classname: 'telia', srcType: true, datasource: 'datasource/city.htm', datatext: 'name', datavalue: 'id', resultExtraStyle: 'font-size:12px' });
    //$('#carrier').nk_dropdown({ width: 286, pointerUrl: 'js/nkal/dropdown/themes/telia/pointer.png', srcText: 'Αναζήτηση..', classname: 'telia', srcType: true, datasource: 'datasource/foreas.htm', datatext: 'name', datavalue: 'id', resultExtraStyle: 'font-size:12px' });
    
	BindGrid(true)
    myscroller = $('.grid').jScrollPane({ animateScroll: true, horizontalGutter: 3, autoReinitialise: true })
    SetScrollLoad()

    BindTopTen()
});

function BindTopTen() {
    
    var DataUrl = '../backkick/public_entities/top_rank.json?limit=5&rnd=' + Math.random(100000) ;
	var rank = 1;
    $.getJSON(DataUrl, function (data) {
        $.each(data, function (index, item) {
            if (item.count == 1) count_text = 'καλό νέο'; else count_text = 'καλά νέα';
            var html = '<div class="box">' + rank + '</div><div class="holder"><div class="p5"><h1>' + item.name + '</h1><h2>' + item.count + ' ' + count_text + '</h2></div></div><div class="clear"></div>'
            rank ++
			var holder = document.createElement("div")
            $(holder).hide();
            $(holder).append(html)
            $('#rpttopten').append(holder)
            $(holder).fadeIn(1000)
        })


    });
}


function reWriteDescription(desc){
	
	if (desc.length > 120){
		return desc.substr(0,120) + ' ...';
	}
	else return desc;
}

function BindGrid(gotonextpage) {
    if (gotonextpage)
        pageno = pageno + 1
    var category_id = $('#category').val()
    var city = $('#city').val()
    var carrier = $('#carrier').val()
    if (category_id == null){category_id = ''};
	if ((city == null)||(city == 'Περιοχή / Πόλη')){city = ''};
	if ((carrier == null)||(carrier == 'Υπηρεσία / Οργανισμός')){carrier = ''};    
var DataUrl = '../backkick/incidents/search.json?rnd=' + Math.random(100000) + '&pageno=' + pageno + '&praise=true' + '&category_id=' + category_id + '&place_name_filter=' + city + '&public_entity_name_filter=' + carrier;


$.getJSON(DataUrl, function (data) {
        $.each(data, function (index, item) {
		    var html = '<a style="text-decoration: none;" href="?cat=23&inc=' + item.id + '"><div class="incidents"><div class="categories">' + item.public_entity.category.name + ' | ' + item.place.name + ' | ' + item.public_entity.name + '</div><div class="descr">' + reWriteDescription(item.description) + '</div><div class="datetime">' + item.incident_date + '</div></a></div>'
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
