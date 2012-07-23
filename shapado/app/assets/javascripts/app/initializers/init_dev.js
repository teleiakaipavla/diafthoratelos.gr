// any initializing code from init_modernizer.js should go here for dev

$(document).ready(function() {
  Jqmath.initialize();
  ShapadoSocket.initialize();
  $('.auto-link').autoVideo();
  Form.initialize();
  Modernizr.load({
      test: $('meta[data-has-js]').length > 0,
      yep: $('meta[data-theme-js]').attr('data-theme-js')
    })
})
