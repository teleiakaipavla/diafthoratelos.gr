class QuestionWrapper < ModelWrapper

  # returns the HTML of a question when listed on the front page
  def render_question
    view_context.render "questions/question", :question => @target
  end

  # returns the latest user who has interacted with a question
  def last_target_user
    UserWrapper.new(find_last_target[2], view_context)
  end

  # returns the name of the latest user who has interacted with a question
  def last_target_user_name
    find_last_target[2].display_name
  end

  # returns a link to the latest element a user interacted with for a given question
  # this could be an answer, a comment or the question itself
  def last_target_url
    lt_id = find_last_target[0]

    case @target.last_target_type
    when 'Answer'
      view_context.question_url(@target, lt_id)
    when 'Comment'
      view_context.question_url(@target, lt_id)
    else
      view_context.question_url(@target)
    end
  end

  # returns the date of the latest interaction with a question
  def last_target_date
    find_last_target[1].iso8601
  end

  # returns how long ago someone has interacted with a question
  def last_target_time_ago
    I18n.t("time.ago", :time => view_context.time_ago_in_words(find_last_target[1]))
  end

  # returns the url of a question
  def url
    view_context.question_url(@target)
  end

  # returns how many times a question has been viewed
  def views_count
    view_context.format_number(@target.views_count)
  end

  # returns a truncated version of a question's description
  # shows first 200 characters by default
  def truncated_description
    view_context.truncate(@target.body, :length => 200)
  end

  # returns the list of tags of a question
  def foreach_tag
    tags = current_group.tags.where(:name.in => @target.tags)
    CollectionWrapper.new(tags, TagWrapper, view_context)
  end

  # returns a list of related questions to a given question
  def foreach_related_question
    questions = Question.related_questions(@target)
    CollectionWrapper.new(questions, QuestionWrapper, view_context)
  end

  # returns the list of comments of a question
  def foreach_comment
    comments = @target.comments
    CollectionWrapper.new(comments, CommentWrapper, view_context)
  end

  # returns the list of answers of a question
  def foreach_answer
    answers = @target.answers
    CollectionWrapper.new(answers, AnswerWrapper, view_context)
  end

  # returns how long ago a question was created
  def time_ago
    view_context.time_ago_in_words(@target.created_at)
  end

  # returns the HTML of the description of a question
  def markdown
    md = view_context.markdown(@target.body.present? ? @target.body : @target.title)
    view_context.shapado_auto_link(md).html_safe
  end

  # returns the URL to edit a question
  def edit_question_url
    view_context.edit_question_url(@target)
  end

  # returns the URL to the history of a question
  def history_url
  end

  # returns the URL of a question's atom feed
  def feed_url
    view_context.question_url(@question, :format => "atom")
  end

  # returns true if a question has been edited
  def if_has_editor
    @target.updated_by.present?
  end

  # returns true if a question has comments
  def if_has_comments
    self.comments.count > 0
  end

  # returns the user who edited a question
  def editor
    @editor ||= UserWrapper.new(self.updated_by, view_context)
  end

  # returns the user who created a question, use it like this:
  # {{#author}} {{name}} {{/author}}
  def author
    @author ||= UserWrapper.new(self.user, view_context)
  end

  # returns the question toolbar
  # the toolbar display the action menu to edit/delete etc the question
  def render_toolbar
    view_context.render "questions/toolbar"
  end
end
