module VotesHelper
  def vote_box(voteable, source, closed = false)
    class_name = voteable.class.name
    url = ""
    if voteable.is_a?(Question)
      url = question_votes_path(voteable)
    elsif voteable.is_a?(Answer)
      url = question_answer_votes_path(voteable.question, voteable)
    elsif voteable.is_a?(Comment)
      commentable = voteable.commentable
      if commentable.is_a?(Question)
        url = question_comment_votes_path(commentable, voteable)
      elsif commentable.is_a?(Answer)
        url = question_answer_comment_votes_path(commentable.question,commentable,voteable)
      end
    end

    render 'shared/vote_box', :handlers => [:haml], :url => url, :voteable => voteable,
                                        :class_name => class_name, :source => source,
                                        :closed => closed
  end

  def calculate_votes_average(voteable)
    if voteable.respond_to?(:votes_average)
      voteable.votes_average
    else
      t = 0
      voteable.votes.each {|e| t += e.value }
      t
    end
  end

  def comment_vote_title(user_voted, voteable)
    votes = voteable.votes.count
    if user_voted
      I18n.t('votes.comments.title.has_user_vote', :count => votes-1)
    else
      I18n.t('votes.comments.title.has_no_user_vote', :count => votes-1)
    end
  end

end
