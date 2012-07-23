class ShareWidget < Widget
  DEFAULT_SHARE = {'facebook_like' => 1, 'twitter_count' => 1, 'google_plus' => 1, 'linked_in_count' => 1, 'stumble_upon' => 1}
  field :settings, :type => Hash, :default => {:share_links => DEFAULT_SHARE}
  before_save :set_default

  SHARE_LINKS = AppConfig.share_links.keys
  def update_settings(params)
    super(params)
  end

  def set_default
    self.settings = {:share_links => DEFAULT_SHARE} if self.settings.nil?
  end
end
