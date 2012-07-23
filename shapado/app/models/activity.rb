class Activity
  include Mongoid::Document
  include Mongoid::Timestamps

  paginates_per 10

  ACTIONS = %w[create update destroy]

  identity :type => String

  field :action, :type => String
  field :scope, :type => Hash
  field :login, :type => String

  field :times, :type => Integer, :default => 1

  field :group_id, :type => String
  referenced_in :group

  field :user_id, :type => String
  referenced_in :user

  field :trackable_info, :type => Hash
  field :trackable_param, :type => String
  belongs_to :trackable, :polymorphic => true

  # optional fields (can be nil)
  field :target_info, :type => Hash
  field :target_param, :type => String
  belongs_to :target, :polymorphic => true

  field :follower_ids, :type => Array, :default => []

  index :action

  before_validation :store_user_name, :on => :create
  validates_presence_of :user
  validates_presence_of :trackable
  validates_presence_of :login

  validates_inclusion_of :action, :in => ACTIONS, :allow_blank => false


  after_create :update_websocket

  def url_for_trackable(domain)
    url_helper = Rails.application.routes.url_helpers

    case (self[:target_type] || self[:trackable_type]).to_s
    when "Question"
      url_helper.question_path(self.target_param, :host => domain)
    when "Answer"
      url_helper.question_answer_path(:question_id => self.target_info["question_param"], :id =>  self.target_param, :host => domain)
    when "Page"
      url_helper.page_path(self.target_param, :host => domain)
    when "User"
      url_helper.user_path(self.target_param, :host => domain)
    else
      raise ArgumentError, "#{self.target_type.inspect} is not handled yet. Activity #{self.id}"
    end
  end

  def params_for_trackable
    result = {'action' => 'show', 'id' => self.target_param}

    case (self[:target_type] || self[:trackable_type]).to_s
    when "Question"
      result['controller'] = "questions"
    when "Answer"
      result['controller'] = "answers"
      result['question_id'] = self.target_info["question_param"]
    when "Page"
      result['controller'] = "pages"
    when "User"
      result['controller'] = "users"
    else
      raise ArgumentError, "#{self.target_type.inspect} is not handled yet. Activity #{self.id}"
    end
    result
  end


  def layout_for_trackable
    case (self[:target_type] || self[:trackable_type]).to_s
    when "Question"
      "question"
    when "Answer"
      "question"
    when "Page"
      "pages"
    when "User"
      "user"
    else
      "index"
    end
  end

  def to_activity_stream
    url_helper = Rails.application.routes.url_helpers
    domain = self.group.domain

    {
      "postedTime" => self.created_at.xmlschema,
      "actor" => {
        "url" => url_helper.user_url(self.user, :host => self.group.domain),
        "objectType" => "person",
        "id" => "tag:#{domain},#{Time.now.year}:#{self.user.id}",
        "image" => {
          "url" => "#{domain}/_files/users/big/#{self.user.id}",
          "width" => 250,
          "height" => 250
        },
        "displayName" => self.user.name || self.user.login
      },
      "verb" => self.action,
      "object" => {
        "url" => url_for_trackable(domain),
        "id" => "tag:#{domain},#{Time.now.year}:#{self.trackable_id}"
      },
      "target" => {
        "url" => "#{domain}",
        "objectType" => "group",
        "id" => "tag:#{domain},2011:#{self.group_id}",
        "displayName" => self.group.name
      }
    }
  end

  def humanize_action
    if trackable_class.respond_to?(:humanize_action)
      I18n.t("activity.#{trackable_class.humanize_action(self.action)}")
    else
      case action
      when "create"
        I18n.t("activity.created")
      when "destroy"
        I18n.t("activity.destroyed")
      when "update"
        I18n.t("activity.updated")
      end
    end
  end

  def trackable_class
    @trackable_class ||= self.trackable_type.constantize
  end

  def trackable_name
    trackable_info["name"] || trackable_info["title"] || trackable_info["body"]
  end

  def trackable_param
    self[:trackable_param] || self[:trackable_id]
  end

  def target_info
    self[:target_info] || self[:trackable_info]
  end

  def target_param
    self[:target_param] || trackable_param
  end

  def target_name
    self[:target_name] || (trackable_name ? trackable_name.gsub(/<\/?[^>]*>/, " ").gsub(/[\S]{245,}/, ""): "")
  end

  def has_target?
    self[:target_type].present?
  end

  def target_class
    if has_target?
      @target_class ||= self[:target_type].constantize
    else
      trackable_class
    end
  end

  def to_html(view_renderer)
    view_renderer.render(
      :partial => 'activities/activity',
      :layout => false,
      :format => :haml,
      :locals => { :activity => self}
    )
  end

  def add_followers(*follower_ids)
    if self.new?
      self.follower_ids += follower_ids
    else
      self.follower_ids += follower_ids
      self.push_uniq(:follower_ids => {:$each => follower_ids})
    end
  end

  def remove_followers(*follower_ids)
    self.pull(:follower_ids => {:$each => follower_ids})
    self.follower_ids -= follower_ids
  end

  private
  def store_user_name
    u = User.only(:login, :name).where(:_id => self.user_id).first
    self[:login] = u[:login] || u[:name] if u

    self[:trackable_param] = self.trackable.to_param if self.trackable.to_param != self.trackable.id
    if self.target.present?
      self[:target_param] = self.target.to_param
      self[:target_name] = (self.target["name"] || self.target["title"] || self.target["body"] || self.target["description"])
      self[:target_name] =  self[:target_name].gsub(/<\/?[^>]*>/, " ").gsub(/[\S]{245,}/, "") if  self[:target_name]
    end
  end

  def update_websocket
    opts = {
      id: "newactivity",
      object_id: self._id,
      name: self.target_name,
      channel_id: self.group.slug
    }
    # "POSTING NEW ACTIVITY: #{opts.inspect}"
    Magent::WebSocketChannel.push(opts)
  end
end
