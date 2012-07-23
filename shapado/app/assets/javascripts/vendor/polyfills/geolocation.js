;(function(geolocation){

  if (geolocation) return;

  var cache;

  geolocation = window.navigator.geolocation = {};
  geolocation.getCurrentPosition = function(callback){

    if (cache) callback(cache);

    $.getScript('//www.google.com/jsapi',function(){

      cache = {
        coords : {
          "latitude": google.loader.ClientLocation.latitude,
          "longitude": google.loader.ClientLocation.longitude
        }
      };

      callback(cache);
    });

  };

  geolocation.watchPosition = geolocation.getCurrentPosition;

})(navigator.geolocation);