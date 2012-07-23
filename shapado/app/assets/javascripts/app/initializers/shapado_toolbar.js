(function($){
  $.fn.shapadoToolbar = function(options) {
    var defaults = {
      formContainer: ".panel-forms",
      afterFetchForm: function(link,form) {}
    }

    var options =  $.extend(defaults, options);

    return this.each(function() {
      var toolbar = $(this);
      var formContainer = toolbar.find(options.formContainer);
      toolbar.delegate("a.show_form", "click", function(event) {
        var link = $(this);
        var id = link.attr("data-lazy-form") || link.attr("id");
        var lazy = link.attr("data-lazy") == "1";

        var form = formContainer.find("."+id);

        if(link.hasClass("active")){
          link.removeClass("active");
          form.slideUp();
          return false;
        }

        var actionsContent = link.parents("ul");
        formContainer.find("form").slideUp();

        if(lazy && form.length < 1) {
          var href = link.attr('href');
          if(!link.hasClass('busy')){
            link.addClass('busy');
            $.getJSON(href+'.js', function(data){
              if(data.status=='unauthenticate'){
                Auth.startLoginDialog();
                return false;
              }
              var nform = $(data.html);
              formContainer.prepend(nform);
              nform.slideDown("slow");
              nform.show();
              link.removeClass('busy');
              options.afterFetchForm.call(toolbar, link, nform);
              actionsContent.find("li a").removeClass("active");
              link.addClass("active");
            });
          }
        } else {
          form.slideDown("slow");
          actionsContent.find("li a").removeClass("active");
          link.addClass("active");
        }
        return false;
      });

      formContainer.delegate("form a.cancel", "click", function(event) {
        $(this).parents('form').slideUp();
        toolbar.find("ul li a").removeClass("active");
        return false;
      });
    });
  }
})(jQuery);
