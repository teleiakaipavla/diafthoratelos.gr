class UsersWidget < Widget
  field :settings, :type => Hash, :default => { 'limit' => 5, :on_mainlist => true  }
  before_save :limit_to_int

  def recent_users(group)
    group.memberships.order_by(%W[created_at desc]).limit(self[:settings]['limit']).map(&:user)
  end

  protected
  def check_settings
    valid = settings["limit"].to_i > 1
    unless valid
      self.errors.add(:limit, I18n.t(:"errors.messages.greater_than", :count => settings["limit"].to_i))
    end
    valid
  end
end
