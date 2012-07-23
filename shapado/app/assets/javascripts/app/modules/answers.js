Answers = function(){
  var self = this;

  function initialize($body) {
    if($body.hasClass("edit")) {
      Editor.setup($(".markdown_editor, .wysiwyg_editor"));
    } else if($body.hasClass("show")) {
      Votes.initialize_on_question();
      Comments.initialize_on_question();
    }
  }

  function initializeOnQuestion() {
    var add_another_answer = $('#add_another_answer');
    if(add_another_answer.length > 0){
      var form = $('.add_answer');
      form.hide();
      add_another_answer.click(function() {
        add_another_answer.hide();
        form.show();
        return false;
      });
    }
  }

  function createOnIndex(data) {
  }

  function createOnShow(data) {
    var is_there = $('.'+data.object_id).length;
    if(is_there==0){
      alert(is_there);
      $(".answers-list").prepend(data.html);
      $("article.answer."+data.object_id).effect("highlight", {}, 3000);
      Ui.hide_comments_form();
    }
  }

  function updateOnIndex(data) {

  }

  function updateOnShow(data) {
    $("article.answer."+data.object_id).html(data.html);
    $("article.answer."+data.object_id).effect("highlight", {}, 3000);
  }

  function vote(data) {
    $("article.answer."+data.object_id+" li.votes_average").text(data.average);
  }

  return {
    initialize:initialize,
    initializeOnQuestion:initializeOnQuestion,
    createOnIndex:createOnIndex,
    createOnShow:createOnShow,
    updateOnIndex:updateOnIndex,
    updateOnShow:updateOnShow,
    vote:vote
  }
}();
