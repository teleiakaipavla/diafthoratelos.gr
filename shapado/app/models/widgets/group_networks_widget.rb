class GroupNetworksWidget < Widget
  include Shapado::Models::Networks

  field :settings, :type => Hash, :default => { :on_mainlist => true  }
  field :networks, :type => Hash, :default => {}
  before_save :set_default

  def update_settings(params)
    super(params)
    self[:networks] = find_networks(params[:networks])
  end

  def set_default
    self.settings = {:on_mainlist => true} if self.settings.nil?
  end
end
