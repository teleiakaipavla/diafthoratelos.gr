Members = function() {
  var self = this;

  function initialize(data) {
    //TODO use data-foo
    $("#filter_members").searcher({
      url : "/manage/members.js",
      target : $("#members"),
      behaviour : "live",
      timeout : 500,
      extraParams : { 'format' : 'js' },
      success: function(data) {
        $('.pagination').html(data.pagination)
      }
    });
    $('.filter_input').hide();
  }

  return {
    initialize:initialize
  }
}();
