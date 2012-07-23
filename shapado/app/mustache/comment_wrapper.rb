class CommentWrapper < ModelWrapper

  # returns true if a comment has votes
  def if_has_votes
    self.votes_count > 0
  end

  # returns the widget to vote on a comment
  def vote_box
    question = @target.find_question
    view_context.vote_box(@target, view_context.question_path(question), question.closed)
  end

  # returns the HTML of a comment's body
  def markdown
    md = view_context.markdown(@target.body.present? ? @target.body : @target.title)
    view_context.shapado_auto_link(md).html_safe
  end

  # returns the author of a comment
  def author
    UserWrapper.new(@target.user, view_context)
  end

  # returns the creation date of a comment
  def creation_date
    self.created_at.iso8601
  end

  # formats the creation date of an answer this way: Nov 23 '11 17:31
  def formatted_creation_date
    self.created_at.strftime("%b %d '%y %H:%M")
  end
end
