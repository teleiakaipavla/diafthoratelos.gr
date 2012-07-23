Notifier = function() {
  var self = this;

  function initialize() {
    if(isValid()) {
      updateCheckbox();

      $("#desktop_notifs").click(function() {
        window.webkitNotifications.requestPermission();
        updateCheckbox();
      })
    }
  }

  function sendMessage(title, message, icon) {
    if(!icon)
      icon = "/images/rails.png"

    if(isValid() && isAllowed()) {
      window.webkitNotifications.createNotification(icon, title, message).show();
    }
  }

  function isValid() {
    return window.webkitNotifications != null;
  }

  function isAllowed() {
    return window.webkitNotifications.checkPermission() == 0;
  }

  //private
  function updateCheckbox() {
    var cbox = $("#desktop_notifs");
    var v = window.webkitNotifications.checkPermission();
    if(v == 0 && $("#desktop_notifs").is(':not:checked')) {
      cbox.attr("checked", true)
    } else {
      cbox.attr("checked", false)
    }
  }

  return {
    initialize:initialize,
    sendMessage:sendMessage,
    isValid:isAllowed
  }
}();
