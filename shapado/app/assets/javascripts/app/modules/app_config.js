AppConfig = function(){
  var self = this;

  function initialize() {
    var config = $("#appconfig");
    if(config.length > 0) {
      $.each(config[0].attributes, function() {
        var att = this;
        var m = att.name.match("^data-(.+)");
        if(m && m[1]) {
          AppConfig[m[1]] = att.value;
        }
      });
    }
  }

  return {
    initialize:initialize
  }
}();
