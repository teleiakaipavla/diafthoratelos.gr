Groups = function() {
  var self = this;

  function initialize($body) {
    if($body.hasClass("index")) {
      initializeOnIndex($body);
    }
    if($body.hasClass("manage-layout")) {
      initializeOnEdit($body);
    }
  }

  function initializeOnEdit($body) {
      $('#group_enable_latex').change(function(){
        $('#group_enable_mathjax').removeAttr('checked')
      })
      $('#group_enable_mathjax').change(function(){
        $('#group_enable_latex').removeAttr('checked')
      })
  }

  function initializeOnManageProperties($body) {
    $('#group_language').chosen();
    $('#group_languages').chosen();
  }

  function initializeOnIndex($body) {
    $("#filter_groups").find("input[type=submit]").hide();

    $("#filter_groups").searcher({ url : "/groups.js",
                                target : $("#groups"),
                                behaviour : "live",
                                timeout : 500,
                                extraParams : { 'format' : 'js' },
                                success: function(data) {
                                  $('#additional_info .pagination').html(data.pagination);
                                }
    });
  }

  function join(link){
          var href = $(link).attr('href');
          $.ajax({
            type: 'POST',
            url: href,
            dataType: 'json',
            success: function(data){
                      Messages.show(data.message, "notice");
                      $('#join_dialog').dialog('close');
                      $('.not_member').remove();
            }
          });
          return false;
  }

  return {
    initialize:initialize,
    initializeOnEdit:initializeOnEdit,
    initializeOnManageProperties:initializeOnManageProperties,
    initializeOnIndex:initializeOnIndex,
    join:join
  }
}();

