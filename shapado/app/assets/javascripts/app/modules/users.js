Users = function() {
  var self = this;

  function initialize($body) {
    if($body.hasClass("index")) {
      Users.initializeOnIndex($body);
    } else if($body.hasClass("edit")) {
      Networks.initialize($body);
    }
  }

  function initializeOnEdit($body) {
    if($body.hasClass("index")) {
      Users.initialize_on_index($body);
    } else if($body.hasClass("edit")) {
      Networks.initialize($body);
    }
  }

  function initializeOnIndex($body) {
    $("#filter_users input[type=submit]").remove();

    $("#filter_users").searcher({ url : "/users.js",
                                target : $("#users"),
                                behaviour : "live",
                                timeout : 500,
                                extraParams : { 'format' : 'js' },
                                success: function(data) {
                                  $('#additional_info .pagination').html(data.pagination)
                                }
    });
  }

  function initializeOnShow($body) {
    $('#user_language').chosen();
    $('#user_timezone').chosen();
    $('#user_preferred_languages').chosen();
  }

  return {
    initialize:initialize,
    initializeOnIndex:initializeOnIndex,
    initializeOnShow:initializeOnShow
  }
}();
