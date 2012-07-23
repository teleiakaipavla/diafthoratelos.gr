class PagesWidget < Widget
  field :settings, :type => Hash, :default => { 'limit' => 5 }
  before_save :limit_to_int

  def recent_pages(group)
    group.pages.order_by(:created_at.desc).where(:wiki => true).limit(self[:settings]['limit'])
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
