class UserWrapper < ModelWrapper

  # returns URL of user
  def url
    view_context.user_url(@target)
  end

  # returns avatar img tag of user
  def avatar
    view_context.avatar_img(@target, :size => 'small')
  end

  # returns URL of user's tag
  def avatar_url
    view_context.avatar_url(@target, :size => 'small')
  end

  # returns user's name
  def name
    @target.display_name
  end

  # returns reputation of user
  def reputation
    view_context.format_number(current_config.reputation.to_i)
  end

  # returns a user's gold badges count
  def gold_badges_count
    current_config.gold_badges_count
  end

  # returns a user's silver badges count
  def silver_badges_count
    current_config.silver_badges_count
  end

  # returns a user's bronze badges count
  def bronze_badges_count
    current_config.bronze_badges_count
  end

  # returns button to follow a user
  def follow_button
    view_context.follow_suggestion_link(@target)
  end

  def respond_to?(method, priv = false)
    super(method, priv) || method =~ /avatar_url_(\d+)/
  end

  protected
  def current_config
    @current_config ||= @target.config_for(current_group)
  end

  def method_missing(name, *args, &block)
    if name =~ /(avatar_url)_(\d+)/
      avatar_url.sub("size=32", "size=#{$2}")
    else
      @target.send(name, *args, &block)
    end
  end
end
