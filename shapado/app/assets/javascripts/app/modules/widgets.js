Widgets = function() {
  var self=this;

  function initialize(data) {
    Networks.initialize();
    var widget = $('.widget-container');

    $('a.delete-widget').bind('ajax:success', function() {
      var link = $(this);
      var parent = link.parents('.widget-container');
      parent.remove();
      return false;
    });

    var dialogContainer = $('#edit-widget-dialog');

    widget.delegate('.edit_widget', 'click', function(event) {
      var link = $(this);
      var parent = link.parents('.widget-container');
      var display = parent.find('.widget-info');

      var preview = display.find('.widget');

      $.ajax( link.attr('href'), {
        dataType: 'json',
        data: {format: 'js'},
        success: function(data) {
          var form = $(data.html);
          Ui.initializeLangFields(form);

          dialogContainer.html(form);
          var dialog = dialogContainer.dialog({modal: true, minWidth: 620, title: link.data('title')});

          form.find('.cancel').bind('click', function(event) {
            dialogContainer.dialog("close");
            return false;
          });

          if(form.attr('id').match(/edit_group_networks_widget/)) {
            Networks.initialize(form);
          }
        }
      });
      return false;
    });

    $('#widget_position').change(function() {
      var opt = $(this).find("option:selected");
      $('.select-widget .zone img').attr({src: '/images/zone-'+opt.val()+'.gif'});
      $('.zone .name').text(opt.text())

    });
  }

  function createOnIndex(data) {
  }

  function createOnShow(data) {
  }

  function updateOnIndex(data) {

  }

  function updateOnShow(data) {

  }

  return {
    initialize:initialize,
    createOnIndex:createOnIndex,
    createOnShow:createOnShow,
    updateOnIndex:updateOnIndex,
    updateOnShow:updateOnShow
  }
}();
