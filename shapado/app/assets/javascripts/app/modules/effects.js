Effects = function(){
  var self =this;

  function initialize() {
  }

  function fade(object) {
    if(typeof object != "undefined") {
      object.fadeOut(400, function() {
        object.fadeIn(400)
      });
    }
  }

  return {
    initialize:initialize,
    fade:fade
  }
}();
