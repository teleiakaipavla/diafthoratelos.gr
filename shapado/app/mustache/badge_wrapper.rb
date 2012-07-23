class BadgeWrapper < ModelWrapper

  # returns url of a given badge
  def badge_url
    view_context.badge_url(@target)
  end

  # returns url of a given user
  def user_url
    view_context.user_url(@target.user)
  end

  # return the name of a user
  def user_name
    @target.user.display_name
  end

  # returns the name of a user
  def user
    UserWrapper.new(@target.user, view_context)
  end
end
