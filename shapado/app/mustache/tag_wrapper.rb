class TagWrapper < ModelWrapper

  # returns the URL of a tag
  def tag_url
    view_context.tag_url(@target.name)
  end

  # returns how many times a tag has been used
  def count
    @target.count.to_i
  end

  # returns how many users follow a tag
  def followers_count
    @target.followers_count.to_i
  end

  # returns the button to follow a tag
  def follow_button
    view_renderer.follow_tag_link(@target)
  end
end
