var pageno = 0
var myscroller;
if (init_public_entity.length == 0){init_public_entity = 'Υπηρεσία / Οργανισμός';}

$(document).ready(function () {
    $('#category').nk_dropdown({ width: 202, pointerUrl: 'js/nkal/dropdown/themes/telia/pointer.png',  classname: 'telia', srcType: false, datasource: '../backkick/categories.json', datatext: 'name', datavalue: 'id', resultExtraStyle: 'font-size:12px' });
	
	$('#carrier').val(init_public_entity) 
    BindGrid(true)

    myscroller = $('.grid').jScrollPane({ animateScroll: true, horizontalGutter: 3, autoReinitialise: true })
    SetScrollLoad()
});



function BindGrid(gotonextpage) {
    if (gotonextpage)
        pageno = pageno + 1
    var category_id = $('#category').val()
    var city = $('#city').val()
    var carrier = $('#carrier').val()
    if (category_id == null){category_id = ''};
	if ((city == null)||(city == 'Περιοχή / Πόλη')){city = ''};
	if ((carrier == null)||(carrier == 'Υπηρεσία / Οργανισμός')){carrier = ''};    

var DataUrl = '../backkick/incidents/search.json?rnd=' + Math.random(100000) + '&pageno=' + pageno + '&praise=false&category_id=' + category_id + '&place_name_filter=' + city + '&public_entity_name_appr_filter=' + carrier;

//var DataUrl = 'datasource/incidents.htm?rnd=' + Math.random(100000) + '&pageno=' + pageno + '&praise=false&category_id=' + category_id + '&place_name_filter=' + city + '&public_entity_name_filter=' + carrier;



$.getJSON(DataUrl, function (data) {
         $.each(data, function (index, item) {
	if (index==9){
		return;
	}
		    var html = '<a href="?cat=22&inc=' + item.id + '"><div class="incidents"><div class="categories">' + item.public_entity.category.name + ' | ' + item.place.name + ' | ' + item.public_entity.name + '</div><div class="descr">' + reWriteDescription(item.description) + '</div><div class="datetime">' + item.incident_date + '</div></div><div class="money"> <a class="asked">' + groupThousands(Math.round( item.money_asked )) + '</a><a class="given">' + groupThousands(Math.round( item.money_given )) + '</a><div class="clear"></div></div><div class="clear"></div></a>'
            var holder = document.createElement("div")
            $(holder).hide();
            $(holder).append(html)
            $('#rpt').append(holder)
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



