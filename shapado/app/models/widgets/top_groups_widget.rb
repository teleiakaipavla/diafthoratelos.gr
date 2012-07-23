class TopGroupsWidget < Widget
  field :settings, :type => Hash, :default => { 'limit' => 5, :on_mainlist => true  }
  before_save :limit_to_int

  def top_groups
    Group.where({:state => "active", :private => false, :isolate => false}).
          order_by(:activity_rate.desc).limit(self[:settings]['limit'])
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
