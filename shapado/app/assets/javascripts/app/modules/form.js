Form = function() {
  var self = this;

  function initialize() {
    if(!Modernizr.inputtypes.color) {
      $("input[type=color]").jPicker({
      window: {
                expandable: true,
                position: { x: 'screenCenter', y: 'center'}
              },
      images: { clientPath: '/images/jpicker/' }
      });
      $("input[type=color]").hide();
    }
  }

  return {
    initialize:initialize
  }
}();
