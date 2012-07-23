Messages = function() {
  var self = this;

  function initialize() {
    $("a#hide_announcement").click(function() {
      $(".announcement").fadeOut();
      $.get($(this).attr("href"), "format=js");
      return false;
    });
  }

  function show(message, t, delay) {
    $("#notifyBar").remove();
    $.notifyBar({
      html: "<div class='message "+t+"' style='width: 100%; height: 100%; padding: 5px'>"+message+"</div>",
      delay: delay||3000,
      animationSpeed: "normal",
      barClass: "flash"
    });
  }

  function ajaxErrorHandler(XMLHttpRequest, textStatus, errorThrown) {
    show("sorry, something went wrong.", "error");
  }

  return {
    initialize:initialize,
    show:show,
    ajaxErrorHandler:ajaxErrorHandler
  }
}();
