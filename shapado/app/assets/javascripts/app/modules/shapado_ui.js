ShapadoUI = function() {
  var self = this;

  function newQuestion(data) {
    if(isOnQuestionIndex()){
      Questions.createOnIndex(data);
    } else if(isOnQuestionShow()) {
      Questions.createOnShow(data);
    } else {
      // update widgets?
    }
  }

  function updateQuestion(data) {
    if(isOnQuestionIndex()){
      Questions.updateOnIndex(data);
    } else if(isOnQuestionShow()) {
      Questions.updateOnShow(data);
    } else {
      // update widgets?
    }
  }

  function deleteQuestion(data) {
    $("article.Question#"+data.object_id).fadeOut();
  }

  function newAnswer(data) {
    if(isOnQuestionIndex()){
      Answers.updateOnIndex(data);
    } else if(isOnQuestionShow()) {
      Answers.createOnShow(data);
    }
  }

  function updateAnswer(data) {
    if(isOnQuestionIndex()){
      Answers.updateOnIndex(data);
    } else if(isOnQuestionShow()) {
      Answers.updateOnShow(data);
    }
  }

  function newComment(data) {
    if(isOnQuestionShow()) {
      Comments.createOnShow(data);
    }
  }

  function updateComment(data) {
    if(isOnQuestionShow()) {
      Comments.updateOnShow(data);
    }
  }

  function vote(data) {
    switch(data.on) {
      case 'Question': {
      }
      break;
      case 'Answer': {
        Answers.vote(data);
      }
      break;
    }
  }

  function newActivity(data) {
    Activities.createOnIndex(data);
  }

  //PRIVATE
  function isOnQuestionIndex() {
    // TODO: Use body class
    return $("section.questions-index")[0] != null;
  }

  function isOnQuestionShow() {
    // TODO: Use body class
    return $("section.main-question#question")[0] != null;
  }

  return {
    newQuestion:newQuestion,
    updateQuestion:updateQuestion,
    deleteQuestion:deleteQuestion,
    newAnswer:newAnswer,
    updateAnswer:updateAnswer,
    newComment:newComment,
    updateComment:updateComment,
    vote:vote,
    newActivity:newActivity
  }
}();


