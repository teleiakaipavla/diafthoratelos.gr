(function($){
  $.fn.searcher = function(options) {
    var defaults = { timeout: 500,
      threshold: 100,
      minLength: 1,
      extraParams: {},
      url: "",
      target: $("body"),
      behaviour : "live",
      success: function(data) {},
      before_query: function(target) {},
      after_reset: function(target) {},
    }

    var options =  $.extend(defaults, options);

    return this.each(function() {
      var timer = null;
      var last = "";
      var settings = options;
      var self = $(this);
      var extraParams = [];
      var cache = settings.target.html();

      if(typeof settings.fields == "undefined") {
        settings.fields = $(this).find("input[type=text],textarea");
      }

       /*HACK?*/
      for(var property in settings.extraParams) {
        extraParams.push({ name : property, value : settings.extraParams[property]});
      }

      var query = function() {
        settings.before_query.call(self, settings.target);

        $.ajax({
          url: settings.url,
          dataType: "json",
          type: "GET",
          data: $.merge(settings.fields.serializeArray(), extraParams),
          success: function(data) {
            settings.target.empty();
            settings.target.append(data.html);
            settings.success(data);
          }
        });
      }

      $.each(settings.fields, function(){
        if(this.value) {
          query();
          return false;
        }
      });

      var live = function() {
        $.each(settings.fields, function(){
          var timer = null;
          $(this).keyup(function() {
            if(!($(this).val().length <= settings.minLength)){
              if(this.value != last) {
                if (timer){
                  clearTimeout(timer);
                }
                last = this.value;
                timer = setTimeout(query, settings.timeout);
              }
            } else {
              settings.target.empty();
              settings.target.append(cache);
              settings.after_reset.call(self, settings.target);
            }
          });
        });
      }

      var focusout = function() {
        $.each(settings.fields, function(){
          $(this).blur(function() {
            if (!($(this).val().length <= settings.minLength)) {
              if(this.value != last) {
                query();
              }
            } else {
              settings.target.empty();
              settings.target.append(cache);
              settings.after_reset.call(self, settings.target);
            }
          });
        });
      }

      switch(settings.behaviour) {
        case "live":
          live();
          break;
        case "focusout":
          focusout();
          live();
          break;
      }
    });
  }
})(jQuery);
