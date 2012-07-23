Tags = function() {
  var self = this;

  function initialize($body) {
    if($body.hasClass("index")) {
      Tags.initializeOnIndex($body);
    }
  }

  function initializeOnIndex($body) {
    // TODO: Use data-foo
    $("#filter_tags").find("input[type=submit]").hide();
    $("#filter_tags").searcher({ url : "/questions/tags.js",
                                target : $("#tag_table"),
                                behaviour : "live",
                                timeout : 500,
                                extraParams : { 'format' : 'js' },
                                success: function(data) { $('#tags').hide() }
    });
  }

  return {
    initialize:initialize,
    initializeOnIndex:initializeOnIndex
  }
}();
