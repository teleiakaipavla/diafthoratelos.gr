//needed for IE
fix_html5_on_ie();
Modernizr.load([{
  load: '//ajax.googleapis.com/ajax/libs/jquery/1.6.4/jquery.min.js',
  callback: function() {
    if (!window.jQuery) {
      Modernizr.load('/javascripts/vendor/jquery-1.6.4.js');
    }
  },
  complete: function() {
    Modernizr.load([{
      test: window.JSON,
      nope: jsassets.json
    }, {
      test: navigator.geolocation,
      nope: jsassets.geolocation
    }, {
      load: jsassets.base,
      complete: function(){
        if(typeof(Jqmath)!='undefined')
          Jqmath.initialize();
      }
    }, {
        load: cssassets.jqueryui
    }]);
   $(document).ready(function() {
     Modernizr.load([{
      test: ($('.offline').length == 0 || (location.pathname != '/' && location.pathname.indexOf('/questions' != 0))),
      yep: jsassets.extra
    }, {
      test: typeof(window.WebSocket)!=='undefined',
      nope: jsassets.websocket,
      complete: function() {
        ShapadoSocket.initialize();
        }
    }, {
      test: $('meta[data-has-js]').length > 0,
      yep: $('meta[data-theme-js]').attr('data-theme-js')
    }, {
      test: $('meta[data-js=show]').length > 0 && $('.auto-link').length > 0,
      yep: jsassets.jqueryautovideo,
      complete: function(){
        if($.fn.autoVideo)
          $('.auto-link').autoVideo();
      }
    }, {
       test: $("input[type=color]").length>0,
       yep: jsassets.jpicker,
       complete: function(){
        if($.jPicker)
          Form.initialize();
       }
       }, {
          test: $("input[type=color]").length>0,
          yep: cssassets.jpicker
     }])
   })
  }
}]);

function fix_html5_on_ie() {
  document.createElement('header');
  document.createElement('footer');
  document.createElement('section');
  document.createElement('aside');
  document.createElement('nav');
  document.createElement('article');
  document.createElement('hgroup');
}