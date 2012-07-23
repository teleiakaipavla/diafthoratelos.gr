Rewards = function() {
  var self = this;

  function initialize() {
    $("#reward_reputation" ).hide();
    if(Ui.offline) {
      $("#reward_reputation" ).hide();
      var slider_div = $("#reward_slider");
      slider_div.slider({
        value:50,
        min: 50,
        max: slider_div.data("max"),
        step: 50,
        slide: function( event, ui ) {
          $("#reward_value").text(ui.value);
          $("#reward_reputation").val( ui.value );
        }
      });
    }
  }

  return {
    initialize:initialize
  }
}();
