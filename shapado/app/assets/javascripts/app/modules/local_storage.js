LocalStorage = function() {
  var self = this;

  function initialize() {
    if(Modernizr.localstorage) {
      loadTextareas();
      initializeTextAreas();
    }
  }

  function remove(key, id) {
    if(hasStorage()){
      var ls = localStorage[key];
      if(typeof(ls)=='string'){
        var storageArr = getObject(key);

        storageArr = $.map(storageArr, function(n, i){
            if(n.id == id){
              return null;
            } else {
                return n;
            }
        });
        setObject(key, storageArr);
      }
    }
  }

  function initializeTextAreas() {
    $("form").live('submit', function() {
      var textarea = $(this).find('textarea');
      remove(location.href, textarea.attr('id'));
      window.onbeforeunload = null;
    });

    $('textarea').live('keyup',function(){
      var value = $(this).val();
      var id = $(this).attr('id');
      add(location.href, id, value);
    });
  }

  function hasStorage(){
    if (Modernizr.localstorage
        && localStorage['setObject']
        && localStorage['getObject']){
      return true;
    } else {
        return false;
    }
  }

  function loadTextareas(){
     if(hasStorage() && localStorage[location.href]!=null && localStorage[location.href]!='null'){
         localStorageArr = getObject(location.href);
         $.each(localStorageArr, function(i, n){
             $("#"+n.id).val(n.value);
             $("#"+n.id).parents('form.commentForm').show();
             $("#"+n.id).parents('form.nestedAnswerForm').show();
         })
      }
  }

  function add(key, id, value){
    if(hasStorage()){
      var ls = localStorage[key];
      if($.trim(value)!=""){
        if(ls == null || ls == "null" || typeof(ls)=="undefined"){
            setObject(key,[{id: id, value: value}]);
        } else {
            var storageArr = getObject(key);
            var isIn = false;
            storageArr = $.map(storageArr, function(n, i){
                if(n.id == id){
                  n.value = value;
                  isIn = true;
                }
            return n;
          })
        if(!isIn)
          storageArr = $.merge(storageArr, [{id: id, value: value}]);
        setObject(key, storageArr);
      }
      } else {remove(key, id);}
    }
  }

  //private
  if(Modernizr.localstorage) {
    function setObject(key, value) {
      this.setItem(key, JSON.stringify(value));
    }

    function getObject(key) {
      return JSON.parse(this.getItem(key));
    }
  }

  return {
    initialize:initialize,
    remove:remove,
    initializeTextAreas:initializeTextAreas,
    hasStorage:hasStorage,
    loadTextareas:loadTextareas,
    add:add
  }
}();
