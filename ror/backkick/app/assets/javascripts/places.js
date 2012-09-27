$(function() {

    var mapOptions = {
        center: new google.maps.LatLng(38.074208, 23.824312),
        zoom: 7,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };

    
    var markers = [];

    var mapElement =
            document.getElementById('where_it_happens_map_canvas');

    var map = new google.maps.Map(mapElement, mapOptions);

    $.getJSON('/places/index.json', function(placeObjects) {
        for (var i = 0; i < placeObjects.length; i++) {
            var latitude = placeObjects[i].latitude;
            var longitude = placeObjects[i].longitude;
            var latLng = new google.maps.LatLng(latitude, longitude);
            var marker = new google.maps.Marker({'position': latLng});
            markers.push(marker);
        }
        var markerCluster = new MarkerClusterer(map, markers);

    });


});
