class Group
  include Mongoid::Document
  include Mongoid::Timestamps

  include MongoidExt::Slugizer
  include MongoidExt::Storage
  include MongoidExt::Filter

  include Shapado::Models::CustomHtmlMethods

  BLACKLIST_GROUP_NAME = ["www", "net", "org", "admin", "ftp", "mail", "test", "blog",
                 "bug", "bugs", "dev", "ftp", "forum", "community", "mail", "email",
                 "webmail", "pop", "pop3", "imap", "smtp", "stage", "stats", "status",
                 "support", "survey", "download", "downloads", "faqs", "wiki",
                 "assets1", "assets2", "assets3", "assets4", "staging", "code"]

  identity :type => String

  field :name, :type => String
  field :subdomain, :type => String
  field :domain, :type => String
  index :domain, :unique => true
  field :legend, :type => String
  field :description, :type => String
  field :default_tags, :type => Array, :default => []
  field :has_custom_ads, :type => Boolean, :default => false
  field :state, :type => String, :default => "pending" #pending, active, closed
  field :isolate, :type => Boolean, :default => false
  field :private, :type => Boolean, :default => false
  field :owner_id, :type => String
  field :analytics_id, :type => String
  field :analytics_vendor, :type => String
  field :has_custom_analytics, :type => Boolean, :default => true

  field :auth_providers, :type => Array, :default => %w[Google Twitter Facebook]
  field :allow_any_openid, :type => Boolean, :default => true

  field :language, :type => String
  field :languages, :type => Set, :default => Set.new
  index :languages

  field :activity_rate, :type => Float, :default => 0.0
  index :activity_rate

  field :openid_only, :type => Boolean, :default => false
  field :registered_only, :type => Boolean, :default => false
  field :has_adult_content, :type => Boolean, :default => false

  field :wysiwyg_editor, :type => Boolean, :default => false

  field :enable_anonymous, :type => Boolean, :default => false

  field :has_reputation_constrains, :type => Boolean, :default => true
  field :reputation_rewards, :type => Hash, :default => REPUTATION_REWARDS
  field :reputation_constrains, :type => Hash, :default => REPUTATION_CONSTRAINS
  field :daily_cap, :type => Integer, :default => 0
  field :forum, :type => Boolean, :default => false

  embeds_one :custom_html
  field :has_custom_html, :type => Boolean, :default => true
  field :has_custom_js, :type => Boolean, :default => true
  field :fb_button, :type => Boolean, :default => true

  field :enable_latex, :type => Boolean, :default => false
  field :enable_mathjax, :type => Boolean, :default => false
  field :logo_version, :type => Integer, :default => 0
  field :custom_favicon_version, :type => Integer, :default => 0

  field :sso_url, :type => String
  field :layout, :type => String, :default => 'application'

  field :track_users, :type => Boolean, :default => true

  # can be:
  # * 'all': email, openid, oauth
  # * 'noemail': openid and oauth only
  # * 'social': only facebook, twitter, linkedin and identica
  # * 'email': only email/password
  field :signup_type, :type => String, :default => 'all'

  field :logo_info, :type => Hash, :default => {"width" => 215, "height" => 60}
  embeds_one :share

  embeds_one :notification_opts, :class_name => "GroupNotificationConfig"

  field :twitter_account, :type => Hash, :default => { }

  field :invitations_perms, :type => String, :default => 'user' # can be "moderator", "owner"
  field :columns, :type => Array, :default => ["column1", "column2", "column3"]

  file_key :logo, :max_length => 2.megabytes
  file_key :custom_css, :max_length => 256.kilobytes
  file_key :custom_favicon, :max_length => 256.kilobytes
  file_list :thumbnails

  field :used_quota, :type => Float, :default => 0.0
  field :question_views, :type => Float, :default => 0.0

  slug_key :name, :unique => true
  filterable_keys :name

  referenced_in :shapado_version, :class_name => "ShapadoVersion"
  field :next_recurring_charge, :type => Time

  field :stripe_balance, :type => String
  field :stripe_customer_id, :type => String
  index :stripe_customer_id

  field :has_late_payment, :type => Boolean, :default => false
  field :upcoming_invoice, :type => Hash

  references_many :tags, :dependent => :destroy, :validate => false
  references_many :activities, :dependent => :destroy, :validate => false

  embeds_one :mainlist_widgets, :class_name => "WidgetList", :as => "group_mainlist_widgets"
  embeds_one :question_widgets, :class_name => "WidgetList", :as => "group_questions"
  embeds_one :external_widgets, :class_name => "WidgetList", :as => "group_external"

  references_many :badges, :dependent => :destroy, :validate => false
  references_many :questions, :dependent => :destroy, :validate => false
  references_many :answers, :dependent => :destroy, :validate => false
  references_many :pages, :dependent => :destroy, :validate => false
  references_many :announcements, :dependent => :destroy, :validate => false
  references_many :constrains_configs, :dependent => :destroy, :validate => false
  references_many :invitations, :dependent => :destroy, :validate => false
  references_many :themes, :dependent => :destroy, :validate => false
  references_many :memberships, :dependent => :destroy, :validate => false
  referenced_in :current_theme, :class_name => "Theme"

  references_many :invoices, :dependent => :destroy, :validate => false

  referenced_in :owner, :class_name => "User"
  embeds_many :comments
  embeds_one :stats, :class_name => "GroupStat"

  validates_presence_of     :owner
  validates_presence_of     :name

  validates_length_of       :name,           :in => 3..40
  validates_length_of       :description,    :in => 3..10000, :allow_blank => true
  validates_length_of       :legend,         :maximum => 50
  validates_length_of       :default_tags,   :in => 0..15,
      :message =>  I18n.t('activerecord.models.default_tags_message')
  validates_uniqueness_of   :name
  validates_uniqueness_of   :subdomain
  validates_uniqueness_of   :domain
  validates_presence_of     :subdomain
  validates_format_of       :subdomain, :with => /^[a-z0-9\-]+$/i
  validates_length_of       :subdomain, :in => 3..32

  validates_uniqueness_of   :domain,
      :message => I18n.t('activerecord.models.duplicate_domain_message')

  validates_inclusion_of :language, :in => AVAILABLE_LANGUAGES, :allow_blank => true
  #validates_inclusion_of :theme, :in => AVAILABLE_THEMES

  validate :initialize_fields, :on => :create
  validate :check_domain, :on => :create

  validate :check_reputation_configs

  validates_exclusion_of      :subdomain,
                              :in => BLACKLIST_GROUP_NAME,
                              :message => "Sorry, this group subdomain is reserved by"+
                                          " our system, please choose another one"
  validates_inclusion_of :invitations_perms, :in => %w[user moderator owner]
  validates_inclusion_of :signup_type,  :in => %w[all noemail social email]

  before_create :disallow_javascript
  before_update :disallow_javascript
  before_save :modify_attributes
  before_save :check_latex
  before_create :create_widget_lists
  before_create :set_default_theme
  before_create :set_shapado_version
  after_create :create_default_tags

  def reset_custom_domain!
    self.domain = "#{self.slug}.#{AppConfig.domain}"
    self.save
  end

  # use for export script, slow
  def members(*fields)
    fields += [:user_id]
    ids = self.memberships.only(fields).map(&:user_id)
    users = User.where(:_id.in => ids)
  end

  index([
    [:state, Mongo::ASCENDING],
    [:domain, Mongo::ASCENDING],
  ], :unique => true)

  # TODO: store this variable
  def has_custom_domain?
    @has_custom_domain ||= self[:domain].to_s !~ /#{AppConfig.domain}/
  end

  def tag_list
    TagList.where(:group_id => self.id).first || TagList.create(:group_id => self.id)
  end

  def top_tags(limit=5)
    tags.desc(:count).limit(limit)
  end

  def top_tags_strings(limit=5)
    tags = []
    top_tags(limit).each do |tag|
      tags << [tag.name]
    end
    tags
  end

  def top_users(limit=5)
    User.where(:group_ids => self.id).desc(:followers_count).limit(limit)
  end

  def default_tags=(c)
    if c.kind_of?(String)
      c = c.downcase.split(",").join(" ").split(" ")
    end
    self[:default_tags] = c
  end
  alias :user :owner

  def add_member(user, role)
    user.join!(self) do |membership|
      if membership.reputation < 5
        membership.reputation = 5
      end
      membership.role = role
    end
    if user.memberships.count == 1 && !user.memberships.first.group.track_users
      user.hide_country = true
      user.save
    end
  end

  def is_member?(user)
    user.member_of?(self)
  end

  def owners
    self.memberships.where(:role => 'owner')
  end

  def mods
    self.memberships.where(:role => 'moderator')
  end
  alias_method :moderators, :mods

  def mods_owners
    self.memberships.where(:role.in => ['owner', 'moderator'])
  end

  def pending?
    state == "pending"
  end

  def on_activity(action)
    value = 0
    case action
      when :ask_question
        value = 0.1
      when :answer_question
        value = 0.3
    end
    self.increment(:activity_rate => value)
  end

  def language=(lang)
    if lang != "none"
      self[:language] = lang
    else
      self[:language] = nil
    end
  end

  def self.humanize_reputation_constrain(key)
    I18n.t("groups.shared.reputation_constrains.#{key}", :default => key.humanize)
  end

  def self.humanize_reputation_rewards(key)
    I18n.t("groups.shared.reputation_rewards.#{key}", :default => key.humanize)
  end

  def self.find_file_from_params(params, request)
    if request.path =~ /\/(logo|big|medium|small|css|favicon)\/([^\/\.?]+)/
      @group = Group.find($2)

      logo = @group.has_logo? ? @group.logo : Shapado::FileWrapper.new("#{Rails.root}/app/assets/images/logo.png", "image/png")
      case $1
      when "logo"
        logo
      when "big"
        @group.thumbnails["big"] ? @group.thumbnails.get("big") : logo
      when "medium"
        @group.thumbnails["medium"] ? @group.thumbnails.get("medium") : logo
      when "small"
        @group.thumbnails["small"] ? @group.thumbnails.get("small") : logo
      when "css"
        css=@group.current_theme.stylesheet
        css.content_type = "text/css"
        css
      when "favicon"
        @group.custom_favicon if @group.has_custom_favicon?
      end
    end
  end

  def reset_twitter_account
    self.twitter_account = { }
    self.save!
  end

  def update_twitter_account_with_oauth_token(token, secret, screen_name)
    self.twitter_account = self.twitter_account ? self.twitter_account : { }
    self.twitter_account["token"] = token
    self.twitter_account["secret"] = secret
    self.twitter_account["screen_name"] = screen_name
    self.save!
  end

  def has_twitter_oauth?
    self.twitter_account && self.twitter_account["token"] && self.twitter_account["secret"]
  end

  def twitter_client
      if self.has_twitter_oauth? && (config = Multiauth.providers["Twitter"])
        TwitterOAuth::Client.new(
          :consumer_key => config["id"],
          :consumer_secret => config["token"],
          :token => self.twitter_account["token"],
          :secret => self.twitter_account["secret"]
        )
      end
  end

  def reset_widgets!
    self.question_widgets = WidgetList.new
    self.mainlist_widgets = WidgetList.new
    self.external_widgets = WidgetList.new
    self.create_default_widgets

  end

  def create_default_widgets
    [ContributorsWidget, QuestionBadgesWidget, RelatedQuestionsWidget].each do |w|
      self.question_widgets.sidebar << w.new
    end

    [TagCloudWidget].each do |w|
      self.mainlist_widgets.navbar << w.new
    end

    [AboutWidget, BadgesWidget, PagesWidget, TopGroupsWidget, TopUsersWidget].each do |w|
      self.mainlist_widgets.sidebar << w.new
    end

    self.external_widgets.sidebar << AskQuestionWidget.new
  end

  def is_all_signup?
    signup_type == 'all'
  end

  def is_social_only_signup?
    signup_type == 'social'
  end

  def is_email_only_signup?
    signup_type == 'email'
  end

  def is_noemail_signup?
    signup_type == 'noemail'
  end

  def has_facebook_login?
    (self.auth_providers.include?("Facebook") && self.domain.index(AppConfig.domain)) || (self.share && self.share.fb_active)
  end

  def version_expired?
    return false if self.shapado_version.nil?

    Time.now > self.plan_expires_at
  end

  def is_stripe_customer?
    self.stripe_customer_id && !self.stripe_customer_id.empty?
  end

  def set_stripe_balance!
    Stripe.api_key = PaymentsConfig['secret']
    cu = Stripe::Customer.retrieve(self.stripe_customer_id)
    self.stripe_balance = cu.account_balance
    self.save
  end

  def downgrade!
    Stripe.api_key = PaymentsConfig['secret']
    cu = Stripe::Customer.retrieve(self.stripe_customer_id)
    cu.cancel_subscription
    self.set_shapado_version
    self.upcoming_invoice = nil
    self.save
    self.set_stripe_balance!
  end

  def upgrade!(user, version)
    group = self
    if self.is_stripe_customer?
      begin
        Stripe.api_key = PaymentsConfig['secret']
        customer = Stripe::Customer.retrieve(self.stripe_customer_id)
        customer.update_subscription(:plan => version.token)
        self.update_plan!(version.token,customer)
        self.set_incoming_invoice
      rescue => e
        Rails.logger.error "ERROR: while retrieving customer: #{e}"
        customer = nil
      end
    end
  end

  def unset_late_payment
    self.override(:has_late_payment => false)
  end

  def set_late_payment
    self.override(:has_late_payment => true)
  end

  def set_incoming_invoice
    return unless self.is_stripe_customer?
    Stripe.api_key = PaymentsConfig['secret']
    upcoming = Stripe::Invoice.
      upcoming(:customer => self.stripe_customer_id)
    self.override(:upcoming_invoice => JSON.parse(upcoming.to_json))
  end

  def update_card!(stripe_token)
    begin
      Stripe.api_key = PaymentsConfig['secret']
      cu = Stripe::Customer.retrieve(self.stripe_customer_id)
      cu.card = stripe_token # obtained with Stripe.js
      cu.save
      return true
    rescue => e
      return e.to_s
    end
  end

  def charge!(token,stripe_token)
    # create a Customer
    begin
      if true
        customer = Stripe::Customer.create(
          :card => stripe_token,
          :plan => token,
          :email => self.owner.email
        )
        self.update_plan!(token,customer)
        self.set_incoming_invoice
      end
      # check setting payed to true for private plan

      return true
    rescue => e
      Rails.logger.error "ERROR: while charging customer: #{e}"
      return false
    end
  end

  def update_plan!(token,customer)
    self.override(:shapado_version_id => ShapadoVersion.where(:token => token).
                  first.id, :next_recurring_charge => Time.
                  parse(customer.next_recurring_charge["date"]),
                  :stripe_customer_id => customer.id)
    self.create_invoices(customer)
  end

  def create_invoices(customer=nil)
    if customer.nil?
      customer = Stripe::Customer.retrieve(self.stripe_customer_id)
    end
    customer_hash = JSON.parse(customer.to_json)
    invoices = Stripe::Invoice.
      all(:customer => customer["id"])
    # invoice_ids = invoices
    existing_invoices = self.invoices.
      map(&:stripe_invoice_id)
    invoices.data.each do |invoice|
      if !(existing_invoices.include? invoice.id)
        version = ShapadoVersion.where(:token => invoice.lines.subscriptions.first.plan.id).first
        invoice = JSON.parse(invoice.to_json)
        i = self.invoices.new(:stripe_invoice_id => invoice["id"],
                              :stripe_invoice => invoice,
                              :action => "upgrade_plan",
                              :user_id => self.owner_id,
                              :stripe_customer =>customer_hash)
        i.payed = true
        i.save
      end
    end
  end

  def upcoming_invoice_date
    Time.at(self.upcoming_invoice["date"])
  end

  protected
  # don't enable both latex
  def check_latex
    if self.enable_latex && self.enable_mathjax
      self.enable_mathjax = false
    end
  end
  #validations
  def initialize_fields
    self["subdomain"] ||= self["slug"]
    self.custom_html = CustomHtml.new
    self.share = Share.new if self.share.nil?
    self.notification_opts = NotificationConfig.new
    self.stats = GroupStat.new
  end

  def check_domain
    if domain.blank?
      self[:domain] = "#{self[:subdomain]}.#{AppConfig.domain}"
    end
  end

  def check_reputation_configs
    if self.reputation_constrains_changed?
      self.reputation_constrains.each do |k,v|
        self.reputation_constrains[k] = v.to_i
        if !REPUTATION_CONSTRAINS.has_key?(k)
          self.errors.add(:reputation_constrains, "Invalid key")
          return false
        end
      end

      if self.reputation_constrains["ask"] > 0
        self.errors.add(:reputation_constrains, I18n.t('activerecord.models.reputation_rewards_ask_constrain'))
        return false
      end

      if self.reputation_constrains["answer"] > 0
        self.errors.add(:reputation_constrains, I18n.t('activerecord.models.reputation_rewards_answer_constrain'))
        return false
      end
    end

    if self.reputation_rewards_changed?
      valid = true
      [["vote_up_question", "undo_vote_up_question"],
       ["vote_down_question", "undo_vote_down_question"],
       ["question_receives_up_vote", "question_undo_up_vote"],
       ["question_receives_follow", "question_undo_follow"],
       ["question_receives_down_vote", "question_undo_down_vote"],
       ["vote_up_answer", "undo_vote_up_answer"],
       ["vote_down_answer", "undo_vote_down_answer"],
       ["answer_receives_up_vote", "answer_undo_up_vote"],
       ["answer_receives_down_vote", "answer_undo_down_vote"],
       ["answer_picked_as_solution", "answer_unpicked_as_solution"]].each do |action, undo|
        if self.reputation_rewards[action].to_i > (self.reputation_rewards[undo].to_i*-1)
          valid = false
          self.errors.add(undo, "should be less than #{(self.reputation_rewards[action].to_i)*-1}")
        end
      end
      return false unless valid

      self.reputation_rewards.each do |k,v|
        self.reputation_rewards[k] = v.to_i
        if !REPUTATION_REWARDS.has_key?(k)
          self.errors.add(:reputation_rewards, I18n.t('activerecord.models.reputation_rewards_key'))
          return false
        end
      end
    end

    return true
  end

  #callbacks
  def modify_attributes
    self.domain.downcase!
    self.subdomain.downcase!
    if !self.language.blank? && !self.languages.include?(self.language)
      self.languages << self.language
    end

    # HACK
    self.languages = self.languages.map! do |l|
      if l =~ /.+:(.+)/
        $1
      else
        l
      end
    end
  end

  def disallow_javascript
    %w[footer head question_help question_prompt head_tag].each do |key|
      value = self.custom_html[key]
      if value.kind_of?(Hash)
        value.each do |k,v|
          value[k] = v.to_s.gsub(/<*.?script.*?>/, "")
        end
      elsif value.kind_of?(String)
        value = value.gsub(/<*.?script.*?>/, "")
      end
      self.custom_html[key] = value
    end
  end

  def create_widget_lists
    self.mainlist_widgets = WidgetList.new
    self.question_widgets = WidgetList.new
    self.external_widgets = WidgetList.new
  end

  def set_default_theme
    theme = Theme.where(:is_default => true).only(:_id).first
    if theme.nil?
      theme = Theme.create_default
    end
    self.current_theme_id =theme.id
  end

  def create_default_tags
    default_tags.each do |tag|
      Tag.create(:name => tag, :group_id => self.id)
    end
  end

  def set_shapado_version
    self.shapado_version_id = ShapadoVersion.where(:token => 'free').first.id
  end

end
