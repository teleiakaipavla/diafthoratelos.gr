class ActivityWrapper < ModelWrapper
  # returns the tipe of action of an activity such as "created" or "updated"
  def action
    @target.humanize_action
  end

  # returns the user who created the activity
  def user
    UserWrapper.new(@target.user, view_context)
  end

  # returns the profile url of the user who created the activity
  def user_url
    view_context.user_url(@target.user)
  end

  # returns the username of the user who created the activity
  def user_name
    @target.user.display_name
  end

  # returns the url of the target of the activity, such as an answer or a question
  def target_url
    @target.url_for_trackable(current_group.domain)
  end

  # returns the name of the target of the activity, such as the title of a question
  def target_name
    @target.target_name
  end
end
