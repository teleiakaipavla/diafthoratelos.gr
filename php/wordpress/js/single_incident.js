$(document).ready(function () {
    var DataUrl = '../backkick/incidents/' + incident_id + '.json?rnd=' + Math.random(100000);
	//var DataUrl = 'datasource/incident.htm?rnd=' + Math.random(100000);
	
    $.getJSON(DataUrl, function (data) {
                        var place = data.place == undefined ? "" : data.place.name;
			var public_entity = data.public_entity.name
			var longitude = data.place.longitude
			var latitude = data.place.latitude 
			var desc = data.description
			var category = data.public_entity.category.name
			var date = data.incident_date
			var money_asked = groupThousands(Math.round( data.money_asked ))
			var money_given = groupThousands(Math.round( data.money_given )) 
			
			var praise = data.praise
			if (data.praise == 1){
					$('#incident_type').append('Καλό νέο')
					$('#more_link').append('<a href="?cat=14">Δες περισσότερα καλά νέα</α>')
					$('#money_details').empty()
					$("#incid_desc").attr("class", "PeristatikoIn-TextLeft-big");
					$("#incident_type").attr("class", "goodnews-icon");
					document.title = 'Καλό νέο για ' + public_entity;
					
				}
				else
				{
					$('#incident_type').append('Περιστατικό διαφθοράς')	
					$('#more_link').append('<a href="?cat=20">Δες περισσότερα περιστατικά διαφθοράς</α>')
					$("#incident_type").attr("class", "protoimediafora-icon");
					document.title = 'Περιστατικό διαφθοράς σε ' + public_entity;
					
				};
			
			var incid_meta = category + ' | ' + place + ' | ' + public_entity + ' | <b>' + date + '</b>'		
			var meta_div = document.createElement("div")
	        $(meta_div).append(incid_meta)
            $('#incid_meta').append(meta_div)
            
			var desc_div = document.createElement("div")
			$(desc_div).append(desc)
            $('#incid_desc').append(desc_div)
			
			var incid_asked_div = document.createElement("div")
			$(incid_asked_div).append(money_asked)
		    $('#incid_asked').append(incid_asked_div)
			
			var incid_given_div = document.createElement("div")
			$(incid_given_div).append(money_given)
		    $('#incid_given').append(incid_given_div)
			
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


