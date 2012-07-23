LayoutEditor = function() {
  var self = this, $sortable;

  function initialize() {
    if(window.location.search.match(/edit_layout=1/)) {
      start();
    }
  }

  function start() {
    $sortable = $("#columns").sortable({
      connectWith: '#columns',
      cursor: 'move',
      stop: dropHandler
    });
  }

  function stop() {
  }

  function dropHandler(ev, ui) {
    var cols = [];
    $.each($("#columns").children("section"), function() {
      cols.push("columns[]="+$(this).attr("id"));
    });

    $.ajax({
      url: '/groups/'+AppConfig.g+'/set_columns.js',
      data: cols.join("&"),
           dataType: 'json',
           type: "POST",
           success: function(data) {
           }
    });
  }

  return {
    initialize:initialize,
    start:start,
    stop:stop,
    dropHandler:dropHandler
  }
}();
