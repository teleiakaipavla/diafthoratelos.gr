Networks = function() {
  var self = this;

  function initialize(form) {
    form = form || $('form')
    form.find(".network-config").hide();

    form.find(".network-field").each(function(index, network_field) {
      network_field = $(network_field);
      var $network_select = network_field.find("select.network_select");

      network_field.delegate("a.save_network", 'click', function(){
        var entry = $(this).parents(".network-config-entry");
        var network = entry.find("input.network_name").val();

        entry.find("input").hide();
        entry.find(".text").empty().append(network);
        entry.find(".buttons").empty();

        return false;
      });

      network_field.delegate("a.cancel_network", 'click', function(){
        var entry = $(this).parents(".network-config-entry");
        var network = entry.find("input.network_name").val();
        entry.remove();

        $.each($network_select.find('option[data-picked="true"]'), function(i, v) {
          var opt = $(v);
          if(opt.text() == network) {
            opt.attr("data-picked", false);
            opt.css("color", "black");
            return;
          }
        });

          return false;
        });

        $network_select.change(function() {
          var networks = network_field.find(".networks");

          var opt = $(this).find("option:selected");
          if( opt.val() == "")
            return false;

          if(opt.attr("data-picked") == "true")
            return false;

          opt.attr("data-picked", true);
          opt.css("color", "grey");

          if(opt.text() == "google") {
            var text = "enter the "+opt.val()+" for your "+opt.text()+ " account:<br/>";
            var config = network_field.find(".network-config").clone();
            config.removeClass("network-config");
            config.attr("id", ".network-config-"+opt.text());
            config.find("input.network_name").val(opt.text());
            config.find("input.network_param").hide();
            config.addClass("network-config-entry");
            config.find(".text").append("google plus one");
            config.show();
          } else {
            var text = "enter the "+opt.val()+" for your "+opt.text()+ " account:<br/>";
            var config = network_field.find(".network-config").clone();
            config.removeClass("network-config");
            config.attr("id", ".network-config-"+opt.text());
            config.find("input.network_name").val(opt.text());
            config.addClass("network-config-entry");
            config.find(".text").append(text);
            config.show();
          }
          networks.append(config);
        });
    });
  }

  return {
    initialize:initialize,
  }
}();