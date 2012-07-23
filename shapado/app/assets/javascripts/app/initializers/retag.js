$(document).ready(function() {
  $('.retag-link').live('click',function(){
    var link = $(this);
    link.parent('.retag').hide();
    link.parents('.tag-list').find('.tag').hide();
    $.ajax({
      dataType: "json",
      type: "GET",
      url : link.attr('href'),
      extraParams : { 'format' : 'js'},
      success: function(data) {
        if(data.success){
          link.parents(".tag-list").before(data.html);
          $(".chosen-retag").ajaxChosen({
            method: 'GET',
            url: '/questions/tags_for_autocomplete.js',
            dataType: 'json'
          }, function (data) {
            var terms = {};
            $.each(data, function (i, val) {
              console.log('i: '+i)
              console.log('val: '+val)
              terms[val["value"]] = val["caption"];
            });

          return terms;
        });
        } else {
            Messages.show(data.message, "error");
            if(data.status == "unauthenticate") {
              window.location="/users/login"
            }
        }
      }
    });
    return false;
  });

  $('.retag-form').live('submit', function() {
    form = $(this);
    var button = form.find('input[type=submit]');
    button.attr('disabled', true)
    $.ajax({url: form.attr("action")+'.js',
            dataType: "json",
            type: "POST",
            data: form.serialize()+"&format=js",
            beforeSend: function(jqXHR, settings){

            },
            success: function(data, textStatus) {
                if(data.success) {
                    var tags = $.map(data.tags, function(n){
                        return '<li><a class="tag" rel="tag" href="/questions/tags/'+n+'">'+n+'</a></li>'
                    })
                    form.next('.tag-list').find('li a.tag').remove();
                    form.next('.tag-list').prepend($.unique(tags).join(''));
                    form.remove();
                    console.log(tags.join(''))
                    $('.retag').show();
                    Messages.show(data.message, "notice");
                } else {
                    Messages.show(data.message, "error")
                    if(data.status == "unauthenticate") {
                        window.location="/users/login";
                    }
                }
            },
            error: Messages.ajax_error_handler,
            complete: function(XMLHttpRequest, textStatus) {
                button.attr('disabled', false);
            }
    });
    return false;
  });

  $('.cancel-retag').live('click', function(){
      var link = $(this);
      var form = link.parents('form');
      form.next('.tag-list').find('.tag').show();
      form.next('.tag-list').find('.retag').show();
      form.remove();
      return false;
  });
});
