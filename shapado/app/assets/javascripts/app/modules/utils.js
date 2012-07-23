Utils = function() {
  var self=this;
  function urlVars() {
    var vars = {}, hash;
    var hashes = {}
    if(window.location.href.indexOf('?') > 0) {
      window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
    }

    for(var i = 0; i < hashes.length; i++) {
      hash = hashes[i].split('=');
      vars[hash[0]] = hash[1];
    }
    return vars;
  }

  function appendParams(url, params) {
    if(url.indexOf('?')==-1)
      url += '?'+params;
    else
      url += '&'+params;

    return url;
  }

  function log(data) {
    window.console && window.console.log(data);
  }

  return {
    urlVars:urlVars,
    appendParams:appendParams,
    log:log
  }
}();
