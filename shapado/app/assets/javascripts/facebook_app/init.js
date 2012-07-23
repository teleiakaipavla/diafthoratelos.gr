var FbQuestions = {
  initialize: function() {
    if($(".unauthenticated").length > 0) {
      $("input, textarea").focus(function() {
        Auth.openPopup('/users/auth/facebook');
        $(this).blur();
        return false;
      });

      $(".require_login").click(function() {
        Auth.openPopup('/users/auth/facebook');
        return false;
      });
    }

    $(".markdown a, a[rel=external]").click(function() {
      var u = $(this).attr("href");

      window.open(u);
      return false;
    });

    $("article.Question h3 a").click(function() {
      var l = $(this);
      var q = l.parents("article.Question");

      q.find(".question-body").slideToggle();

      return false;
    });

    $(".quick_question form").submit(function() {
      var f = $(this);
      var step1 = f.find(".step1");
      var step2 = f.find(".step2");

      var href = f.attr("action");

      if(!step2.is(':visible')) {
        step2.slideDown();
      } else {
        $.ajax({
          url: href+'.js',
          dataType: 'json',
          type: "POST",
          data: f.serialize()+"&facebook=1",
          success: function(data){
            if(data.success){
              step2.slideUp();

              Messages.show(data.message, "notice");
              $("section.questions-index").prepend(data.html);
            } else {
              Messages.show(data.message, "error");

              if(data.status == "unauthenticate") {
                Auth.openPopup("/users/auth/facebook");
              }
            }
          },
          error: Messages.ajax_error_handler,
          complete: function(XMLHttpRequest, textStatus) {
          }
        });
      }
      return false;
    });

    $("form.new_answer").submit(function() {
      var f = $(this);
      var href = f.attr("action");

      $.ajax({
        url: href+'.js',
        dataType: 'json',
        type: "POST",
        data: f.serialize()+"&facebook=1",
        success: function(data){
          if(data.success){
            Messages.show(data.message, "notice");
            $("article.Question#"+data.question_id+" .answers-list").prepend(data.html);
          } else {
            Messages.show(data.message, "error");

            if(data.status == "unauthenticate") {
              Auth.openPopup("/users/auth/facebook");
            }
          }
        },
        error: Messages.ajax_error_handler,
        complete: function(XMLHttpRequest, textStatus) {
        }
      });

      return false;
    });

    $("a.follow_question").click(function() {
      console.lo("!!!")
      var l = $(this);
      var href = $(this).attr("href");

      $.get(href+".js", function(data) {
        Messages.show(data.message, 'notice');
      },
      'json');
      return false;
    });
  }
};

var FbUsers = {
  initialize: function() {
    $('a[href^="/users/"]').click(function(e) {
      var href = $(this).attr("href");
      href = Utils.append_params(href, "format=js&facebook=1");

      $.facebox(function() {
        $.get(href, function(data, status, jqXHR) {
          Utils.log(data);
          $.facebox(data.html);
        }, "JSON");
      });
      return false;
    });
  }
};

$(document).ready(function() {
  $current_group = $("body").attr("data-group");

  FbQuestions.initialize();
  FbUsers.initialize();
});
