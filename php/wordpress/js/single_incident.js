$(document).ready(function () {
    var DataUrl = '../backkick/incidents/' + incident_id + '.json?rnd=' + Math.random(100000);
	//var DataUrl = 'datasource/incident.htm?rnd=' + Math.random(100000);
	
    $.getJSON(DataUrl, function (data) {
        var placeName = "";
        var longitude = 23.824312;
        var latitude = 38.074208;
        var placeDefined = data.place != undefined;
        if (placeDefined) {
            placeName = data.place.name;
            longitude = data.place.longitude
            latitude = data.place.latitude 
        }
        
		var publicEntity = 'Χωρίς όνομα φορέα';
		try{publicEntity = data.public_entity.name;}
		catch (err){}
		

		
        
		var desc = data.description

        var category = 'Χωρίς κατηγορία';

			try{category = data.public_entity.category.name;}
			catch (err){}

        var date = data.incident_date
        var moneyAsked = groupThousands(Math.round( data.money_asked ))
        var moneyGiven = groupThousands(Math.round( data.money_given )) 
                        
        var praise = data.praise
        if (data.praise == 1){
            $('#incident_type').append('Καλό νέο')
            $('#more_link').append('<a href="?cat=14">Δες περισσότερα καλά νέα</α>')
            $('#money_details').empty()
            $("#incid_desc").attr("class", "PeristatikoIn-TextLeft-big");
            $("#incident_type").attr("class", "goodnews-icon");
            document.title = 'Καλό νέο για ' + publicEntity;
            
        } else {
            $('#incident_type').append('Περιστατικό διαφθοράς') 
            $('#more_link').append('<a href="?cat=20">Δες περισσότερα περιστατικά διαφθοράς</α>')
            $("#incident_type").attr("class", "protoimediafora-icon");
            document.title = 'Περιστατικό διαφθοράς σε ' + publicEntity;
            
        };
        
        var incidMeta = category + ' | ' + placeName + ' | ' + publicEntity + ' | <b>' + date + '</b>'            
        var metaDiv = document.createElement("div")
        $(metaDiv).append(incidMeta)
        $('#incid_meta').append(metaDiv)
        
        var desc_div = document.createElement("div")
        $(desc_div).append(desc)
        $('#incid_desc').append(desc_div)
                        
        var incidAskedDiv = document.createElement("div")
        $(incidAskedDiv).append(moneyAsked)
        $('#incid_asked').append(incidAskedDiv)
        
        var incidGivenDiv = document.createElement("div")
        $(incidGivenDiv).append(moneyGiven)
        $('#incid_given').append(incidGivenDiv)

        showOnMap(latitude, longitude, placeName, placeDefined);
    })
});

function showOnMap(latitude, longitude, placeName, putMarker) {
    var myLatLng = new google.maps.LatLng(latitude, longitude);
    var mapOptions = {
        zoom: putMarker? 12 : 5,
        center: myLatLng,
        draggable: true,
        mapTypeId: google.maps.MapTypeId.ROADMAP
        
  }

    var map = new google.maps.Map(document.getElementById("googlemaps"),
                                  mapOptions);

    if (putMarker) {
        var marker = new google.maps.Marker({
            position: myLatLng,
            map: map,
            title: placeName
        });
        marker.setMap(map);
    }
}


