$(document).ready(function () {
    var DataUrl = '../backkick/incidents/' + incident_id + '.json?rnd=' + Math.random(100000);
	//var DataUrl = 'datasource/incident.htm?rnd=' + Math.random(100000);
	
    $.getJSON(DataUrl, function (data) {
        		var place = data.place.name
			var public_entity = data.public_entity.name
			var longitude = data.place.longitude
			var latitude = data.place.latitude 
			var desc = data.description
			var category = data.public_entity.category.name
			var date = data.incident_date

			var incid_meta = category + ' | ' + place + ' | ' + public_entity + ' | <b>' + date + '</b>'		
			var meta_div = document.createElement("div")
	        $(meta_div).append(incid_meta)
            $('#incid_meta').append(meta_div)
            
			var desc_div = document.createElement("div")
			$(desc_div).append(desc)
            $('#incid_desc').append(desc_div)
			
	
			showOnMap(latitude, longitude, place)


        })
    });

function showOnMap(latitude, longitude, placename){
  var myLatlng = new google.maps.LatLng(latitude, longitude);
  var mapOptions = {
    zoom: 12,
    center: myLatlng,
	draggable:true,
    mapTypeId: google.maps.MapTypeId.ROADMAP
	
  }

  var map = new google.maps.Map(document.getElementById("googlemaps"), mapOptions);


  var marker = new google.maps.Marker({
      position: myLatlng,
      map: map,
      title:placename
  });
marker.setMap(map);
}


