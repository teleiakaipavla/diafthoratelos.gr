Pages = function() {
  var self = this;

  function initialize($body) {
    if($body.hasClass("new") || $body.hasClass("edit") || $body.hasClass("create") || $body.hasClass("update") ) {
      Editor.initialize();
    }
  }

  return {
    initialize:initialize
  }
}();
