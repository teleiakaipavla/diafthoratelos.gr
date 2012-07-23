Searches = function() {
  var self = this;

  function initialize($body) {
    $(".advanced-search").click(function(){
      $(".advanced-form").toggleClass("open").slideToggle("slow");
      return false;
    });
  }

  return {
    initialize:initialize
  }
}

