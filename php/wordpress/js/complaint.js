var pageno = 0;
var myscroller;
var pagesize = 9;
var total_incidents = 0;
var displaying_incidents = 0;


$(document).ready(function () {
   $('#category').nk_dropdown({ width: 202, pointerUrl: 'js/nkal/dropdown/themes/telia/pointer.png',  classname: 'telia', srcType: false, datasource: '../backkick/categories.json', datatext: 'name', datavalue: 'id', resultExtraStyle: 'font-size:12px', DefaultValue: '', DefaultText: 'Όλες οι κατηγορίες' });
//  $('#category').nk_dropdown({ width: 202, pointerUrl: 'js/nkal/dropdown/themes/telia/pointer.png', classname: 'telia', srcType: false, datasource: 'datasource/category.htm', datatext: 'name', datavalue: 'id', resultExtraStyle: 'font-size:12px', DefaultValue: '', DefaultText: 'Όλες οι κατηγορίες' });

    BindGrid(true)

    myscroller = $('.grid').jScrollPane({ animateScroll: true, horizontalGutter: 3, autoReinitialise: true })
    SetScrollLoad()

		$.ajax({
		  url: '../backkick/incidents/count_approved.json?praise=false&r=' + (Math.random() * 11000000),
		  success: function(data) {
		    total_incidents = data
		  }
		});


});



function BindGrid(gotonextpage) {
    if (gotonextpage)
        pageno = pageno + 1
    var category_id = $('#category').val();


    var city = $('#place').val();
    var public_entity_id = $('#public_entity_selected_value').val();

      
    if (category_id == null){category_id = ''};
	if ((city == null)||(city == 'Περιοχή / Πόλη')){city = ''};

	var DataUrl = '../backkick/incidents/search.json?rnd=' + Math.random(100000) + '&pageno=' + pageno + '&praise=false' + '&place_name_filter=' + city + '&pagesize=' + pagesize + '&category_id=' + category_id;

//var DataUrl = 'datasource/incidents.htm?rnd=' + Math.random(100000) + '&pageno=' + pageno + '&praise=false' + '&place_name_filter=' + city + '&pagesize=' + pagesize + '&category_id=' + category_id;


if (public_entity_id != '') {  DataUrl += '&public_entity_id=' + public_entity_id }


// Create title for incidents header to show total number of results


$.getJSON(DataUrl, function (data) {
    
	$.each(data, function (index, item) {
		
			
		if (index==pagesize){
	
			return;
		}
	displaying_incidents++;
		var html = '<a href="?cat=22&inc=' + item.id + '"><div class="incidents"><div class="categories">' + item.public_entity.category.name + ' | ' + item.place.name + ' | ' + item.public_entity.name + '</div><div class="descr">' + reWriteDescription(item.description) + '</div><div class="datetime">' + item.incident_date + '</div></div><div class="money"> <a class="asked">' + groupThousands(Math.round( item.money_asked )) + '</a><a class="given">' + groupThousands(Math.round( item.money_given )) + '</a><div class="clear"></div></div><div class="clear"></div></a>'
    
        	var holder = document.createElement("div")
            $(holder).hide();
            $(holder).append(html)
            $('#rpt').append(holder)
            $(holder).fadeIn(1000)
			
			
        })
		
	

		$('#incidents_title').empty();
		//$('#incidents_title').append('Εμφανίζονται ' + displaying_incidents + ' σε σύνολο ' + total_incidents + ' περιστατικών')
		$('#incidents_title').append('Περιστατικά διαφθοράς');

    });


}


function doSearch() {

    $('#rpt').empty();
    pageno = 0; 
	//total_incidents = 0;
	displaying_incidents = 0;
    
    BindGrid(true);


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
        var Limiter = 500 + parseInt(api.getContentPositionY()) + 130 // 130 = 1 row ( set how many rows before you want to load next page)
        var All = $('#rpt').height()
		
        if (Limiter > All) {
      		
			if (displaying_incidents >= total_incidents){return;} 
			BindGrid(true)
        }
    }
);

   
}


$(function () {

    $("#public_entity").autocomplete({
       source: "../backkick/public_entities/search.json?form=short",
       // source: 'datasource/foreas.htm?form=short',
		
        minLength: 2,

        select: function (event, ui) {
            event.preventDefault();
            $("#public_entity").val(ui.item.label);
            $("#public_entity_selected_value").val(ui.item.value);

        },

        focus: function (event, ui) {
            event.preventDefault();
            $("#public_entity").val(ui.item.label);
        }
    });

});

