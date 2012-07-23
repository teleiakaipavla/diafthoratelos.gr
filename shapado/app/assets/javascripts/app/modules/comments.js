Comments = function() {
  var self = this;

  function initializeOnQuestion(data) {
    $('.comment-votes form.comment-form button.vote').hide();
    var forms = $('.question_comment_form, .answer_comment_form');
    forms.find('.buttons').hide();

    forms.delegate('textarea', 'focus', function() {
      var form = $(this).parents('form');
      form.find('.buttons').show();
      if(!form.find('textarea').hasClass(form.data('editor'))) {
        form.find('textarea').addClass(form.data('editor'));
        Editor.setup(form.find('textarea'));
      }
    });

    $.each($("a.toggle_comments"), function() {
      var l = $(this);
      var n = l.nextAll("article.read");
      var s = n.length;
      if(s < 5) {
        l.hide();
      } else {
        l.show();
        var t = l.find('.counter').text(s);
        l.text(t);
        n.hide();
        l.parents('.comments').find("article.comment:last").show();
      }
    });

    $("a.toggle_comments").click(function() {
      $(this).nextAll("article.read").toggle();
      return false;
    });

    $(".content-panel").on("hover", ".comment",  function(handlerIn, handlerOut) {
      var show = (handlerIn.type == "mouseenter");
      $(this).find(".comment-votes form.comment-form button.vote").toggle(show);
    });

    $(".content-panel").on("submit", ".comment-votes .comment-form",  function(event) {
      var form = $(this);
      var btn = form.find('button');
      btn.attr('disabled', true);
      btn.hide();
      $.post(form.attr("action"), form.serialize()+"&"+btn.attr("name")+"=1", function(data){
        if(data.success){
          if(data.vote_state == "destroyed") {
            btn.addClass("vote");
            btn.hide();
          } else {
            btn.removeClass("vote");
            btn.show();
          }
          btn.parents(".comment-votes").children(".votes_average").html(data.average);
          Messages.show(data.message, "notice");
        } else {
          Messages.show(data.message, "error");
        }
        btn.attr('disabled', false);
        btn.show();
      }, "json");
      return false;
    });

    $(".Question-commentable").click(showCommentForm);

    $(".content-panel").delegate(".Answer-commentable, .Comment-commentable", "click", showCommentForm);

    $('.cancel_comment').on('click', function(){
      var form = $(this).parents('form');
      form.find('.buttons').hide();
      var htmlarea = form.find('.jHtmlArea')
      if(htmlarea.length > 0) {
        htmlarea.remove();
        form.find('.markdown').append('<textarea class="text_area" cols="auto" id="comment_body" name="comment[body]" placeholder="Add comment" rows="auto"></textarea>');
      } else {
        form.find('.markdown_toolbar').remove();
        form.find('textarea').removeClass('markdown_editor')
      }
      return false;
    });
  }

  function showCommentForm() {
      var link = $(this);
      var answer_id = link.attr('data-commentable');
      var form = $('form[data-commentable='+answer_id+']');
      var textarea = form.find('textarea');
      form.slideToggle();
      textarea.focus();
      var viewportHeight = window.innerHeight ? window.innerHeight : $(window).height();
      var top = form.offset().top - viewportHeight/2;

      $('html,body').animate({scrollTop: top}, 1000);
      return false;
  }

  function createOnIndex(data) {
  }

  function createOnShow(data) {
    var comment = $('#'+data.object_id);
    if(comment.length==0){
      var commentable = $('.'+data.commentable_id);
      var comments = commentable.find('.comments');
      comments.append(data.html);
      Effects.fade(comment);
    }
  }

  function updateOnIndex(data) {

  }

  function updateOnShow(data) {
    var comment = $('#'+data.object_id);
    if($.trim(comment.html()) != data.html){
      comment.replaceWith(data.html);
      Effects.fade(comment);
    }
  }

  function vote(data) {
  }

  return {
    initializeOnQuestion:initializeOnQuestion,
    showCommentForm:showCommentForm,
    createOnIndex:createOnIndex,
    createOnShow:createOnShow,
    updateOnIndex:updateOnIndex,
    updateOnShow:updateOnShow,
    vote:vote
  }
}();
