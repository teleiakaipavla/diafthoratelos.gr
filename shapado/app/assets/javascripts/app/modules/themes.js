Themes = function() {
  var self = this;
  function initialize($body) {
    if($body.hasClass("show")) {
      var message = $body.find("#not_ready")
      if(message.length > 0) {
        var show_theme = document.location.href;
        $.poll(5000, function(retry){
          $.getJSON(show_theme+"/ready", {format: "js"}, function(response, status) {
            if(status == 'success' && (response.ready))
              if(response.message) {
                message.text(response.message);
                Effects.fade(message);
                if(show_theme == document.location.href)
                  document.location.href = document.location.href;
              } else if(response.last_error) {
                message.text(response.last_error);
                message.addClass("error");
                Effects.fade(message);
              }
            else
              retry();
          });
        });
      }
    } else if( $body.hasClass("new") || $body.hasClass("edit") || $body.hasClass("create") || $body.hasClass("update")) {

      $(".show_dialog").click(function(e){
        var self = $(this);
        var target = $('.'+self.data('target')+"-code-editor");
        target.dialog({width: ($body.width()-50)});
        if(self.data("actived") != "1") {
          target.find("textarea.code").each(function(i, e){
            CodeMirror.fromTextArea(e, {lineNumbers: true, theme: "default", mode: $(e).data("lang")});
          });
          self.data({"actived": "1"});
        }

        return false;
      });
    } else if($body.hasClass("index")) {
      $(".import_theme").click(function() {
        $(".import_dialog").dialog();
      });
    }
  }

  return {
    initialize:initialize
  }
}();
