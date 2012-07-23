Geo = function() {
  var self = this;

  function initialize() {
    $(document.body).delegate('#question_title', 'click', Geo.localize);
    $(document.body).delegate('#new_answer', 'hover', Geo.localize);
  }

  function localize() {
    if($('meta[geo_local]').length==1){
      if($('meta[data-geo=1]').length==0){
        $('body').append('<meta data-geo=1>');
        navigator.geolocation.getCurrentPosition(function(position){
          $('.lat_input').val(position.coords.latitude)
          $('.long_input').val(position.coords.longitude)
        }, function(){});
      }
    }
  }

  return {
    initialize:initialize,
    localize:localize
  }
}();
