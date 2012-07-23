require 'digest/sha1'

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include MultiauthSupport
  include MongoidExt::Storage
  include Shapado::Models::GeoCommon
  include Shapado::Models::Networks

  devise :database_authenticatable, :recoverable, :registerable, :rememberable,
         :lockable, :token_authenticatable, :encryptable, :trackable, :omniauthable, :encryptor => :restful_authentication_sha1

  ROLES = %w[user moderator admin]
  LANGUAGE_FILTERS = %w[any user] + AVAILABLE_LANGUAGES
  LOGGED_OUT_LANGUAGE_FILTERS = %w[any] + AVAILABLE_LANGUAGES

  identity :type => String
  field :login,                     :type => String, :limit => 40
  index :login

  field :name,                      :type => String, :limit => 100, :default => '', :null => true

  field :bio,                       :type => String, :limit => 200
  field :website,                   :type => String, :limit => 200
  field :location,                  :type => String, :limit => 200
  field :birthday,                  :type => Time

  field :identity_url,              :type => String
  index :identity_url

  field :role,                      :type => String, :default => "user"
  field :last_logged_at,            :type => Time

  field :preferred_languages,       :type => Set, :default => []

  field :language,                  :type => String, :default => "en"
  index :language
  field :timezone,                  :type => String
  field :language_filter,           :type => String, :default => "user", :in => LANGUAGE_FILTERS

  field :ip,                        :type => String
  field :country_code,              :type => String
  field :country_name,              :type => String, :default => "unknown"
  field :hide_country,              :type => Boolean, :default => false

  field :default_subtab,            :type => Hash, :default => {}

  field :followers_count,           :type => Integer, :default => 0
  field :following_count,           :type => Integer, :default => 0

  field :group_ids,                 :type => Array, :default => []

  field :feed_token,                :type => String, :default => lambda { BSON::ObjectId.new.to_s }
  field :socket_key,                :type => String, :default => lambda { BSON::ObjectId.new.to_s }

  field :anonymous,                 :type => Boolean, :default => false
  index :anonymous

  attr_accessible :anonymous, :login

  field :networks, :type => Hash, :default => {}

  field :friend_list_id, :type => String
  embeds_one :notification_opts, :class_name => "NotificationConfig"

  file_key :avatar, :max_length => 1.megabytes
  field :use_gravatar, :type => Boolean, :default => true
  file_list :thumbnails

  referenced_in :friend_list

  references_many :memberships, :class_name => "Membership", :validate => false
  references_many :owned_groups, :inverse_of => :user, :class_name => "Group", :validate => false
  references_many :questions, :dependent => :destroy, :validate => false
  references_many :answers, :dependent => :destroy, :validate => false
  references_many :badges, :dependent => :destroy, :validate => false
  references_many :searches, :dependent => :destroy, :validate => false
  references_many :activities, :dependent => :destroy, :validate => false
  references_many :invitations, :dependent => :destroy, :validate => false
  references_one :external_friends_list, :dependent => :destroy, :validate => false

  references_one :read_list, :dependent => :destroy, :validate => false

  before_create :initialize_fields
  after_create :create_lists

  before_create :generate_uuid
  after_create :update_anonymous_user

  validates_inclusion_of :language, :in => AVAILABLE_LOCALES, :if => lambda { AppConfig.enable_i18n }
  validates_inclusion_of :role,  :in => ROLES

  with_options :unless => :anonymous do |v|
    v.validates_presence_of     :login
    v.validates_length_of       :login,    :in => 3..40
    v.validates_uniqueness_of   :login
    v.validates_format_of       :login,    :with => /\w+/
  end

  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email,    :if => lambda { |e| !e.openid_login? && !e.twitter_login? }
  validates_uniqueness_of   :email,    :if => lambda { |e| e.anonymous || (!e.openid_login? && !e.twitter_login?) }
  validates_length_of       :email,    :in => 6..100, :allow_nil => true, :if => lambda { |e| !e.email.blank? }

  with_options :if => :password_required? do |v|
    v.validates_presence_of     :password
    v.validates_confirmation_of :password
    v.validates_length_of       :password, :in => 6..20, :allow_blank => true
  end

  before_save :update_languages

  attr_accessible :remember_me

  def custom_domain_owned_groups
    groups = Group.where(:owner_id => self.id)
    customs = []
    groups.each { |group| customs << group if group.has_custom_domain? }
    customs
  end

  def owns_custom_domain_groups?
    custom_domain_owned_groups.count > 0
  end

  def display_name
    name.blank? ? login : name
  end

  def self.find_for_authentication(conditions={})
    where(conditions).first || where(:login => conditions[:email]).first
  end

  def inactive_membership_list
    self.memberships.where(:state => 'inactive')
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def networks=(params)
    self[:networks] = self.find_networks(params)
  end

  def self.find_by_login_or_id(login, conds = {})
    where(conds.merge(:login => login)).first || where(conds.merge(:_id => login)).first
  end

  def self.find_experts(tags, langs = nil, options = {})
    opts = {}

    if except = options[:except]
      except = [except] unless except.is_a?(Array)
      opts[:user_id] = {:$nin => except}
    end

    user_ids = UserStat.only(:user_id).where(opts.merge({:answer_tags => {:$in => tags}})).all.map(&:user_id)

    conditions = {:"notification_opts.give_advice" => {:$in => ["1", true]},
                  :_id => {:$in => user_ids}}

    if langs
      conditions[:preferred_languages] = {:$in => langs}
    end

    if group_id = options[:group_id]
      conditions[:"group_ids"] = {:$in => [group_id]}
    end

    User.only([:email, :login, :name, :language]).where(conditions)
  end

  def to_param
    if self.login.blank? || !self.login.match(/^\w[\w\s]*$/)
      self.id
    else
      self.login
    end
  end

  def add_preferred_tags(t, group)
    if !self.member_of? group
      join!(group)
    end

    if t.kind_of?(String)
      t = t.split(",").map{|e| e.strip}
    end

    Membership.push_uniq({:group_id => group.id, :user_id => self.id}, {:preferred_tags => {:$each => t.uniq}})

    Tag.increment({:name => {:$in => t}, :group_id => group.id}, {:followers_count => 1})
  end

  def remove_preferred_tags(t, group)
    if t.kind_of?(String)
      t = t.split(",").join(" ").split(" ")
    end
    Membership.pull_all({:group_id => group.id, :user_id => self.id}, {:preferred_tags => t})
    Tag.increment({:name => {:$in => t}, :group_id => group.id}, {:followers_count => -1})
  end

  def preferred_tags_on(group)
    @group_preferred_tags ||= begin
      membership = config_for(group, false)
      if membership
        membership.preferred_tags || []
      else
        []
      end
    end
  end

  def language_filter=(filter)
    if LANGUAGE_FILTERS.include? filter
      self[:language_filter] = filter
      true
    else
      false
    end
  end

  def languages_to_filter(group)
    @languages_to_filter ||= begin
      languages = nil
      if group.languages.empty?
        languages = group.languages
        return languages
      end
      case self.language_filter
      when "any"
        languages = group.languages
      when "user"
        languages = (self.preferred_languages.blank?) ? group.languages : self.preferred_languages
      else
        languages = [self.language_filter]
      end
      languages
    end
  end

  def is_preferred_tag?(group, *tags)
    if config = config_for(group, false)
      ptags = config.preferred_tags
      tags.detect { |t| ptags.include?(t) } if ptags
    else
      false
    end
  end

  def admin?
    self.role == "admin"
  end

  def age
    return if self.birthday.blank?

    Time.zone.now.year - self.birthday.year - (self.birthday.to_time.change(:year => Time.zone.now.year) >
Time.zone.now ? 1 : 0)
  end

  def can_modify?(model)
    return false unless model.respond_to?(:user)
    self.admin? || self == model.user
  end

  def can_create_reward?(question)
    if config = config_for(question.group_id)
      (Time.now - question.created_at) >= 2.days &&
      config.reputation >= 75 &&
      (question.reward.nil? || !question.reward.active)
     end
  end

  def groups(options = {})
    Group.where(options.merge(:_id.in => self.group_ids)).order_by([:activity_rate, :desc])
  end

  def member_of?(group)
    if group.kind_of?(Group)
      group = group.id
    end

    self.group_ids.include?(group)
  end

  def role_on(group)
    if config = config_for(group, false)
      config.role
    end
  end

  def owner_of?(group)
    admin? || group.owner_id == self.id || role_on(group) == "owner"
  end

  def admin_of?(group)
    role_on(group) == "admin" || owner_of?(group)
  end

  def mod_of?(group)
    owner_of?(group) || role_on(group) == "moderator" || self.reputation_on(group).to_i >= group.reputation_constrains["moderate"].to_i
  end

  def editor_of?(group)
    if c = config_for(group, false)
      c.is_editor
    else
      false
    end
  end

  def user_of?(group)
    mod_of?(group) || member_of?(group)
  end

  def main_language
    @main_language ||= self.language.split("-").first
  end

  def openid_login?
    !self.auth_keys.blank? || (AppConfig.enable_facebook_auth && !facebook_id.blank?)
  end

  def linked_in_login?
    user_info && !user_info["linked_in"].blank? && linked_in_id
  end

  def identica_login?
    user_info && !user_info["identica"].blank? && identica_id
  end

  def twitter_login?
    user_info && !user_info["twitter"].blank? && twitter_id
  end

  def facebook_login?
    user_info && !user_info["facebook"].blank? && facebook_id
  end

  def openid_login?
    user_info && !user_info["open_id"].blank?
  end

  def social_connections
    connections = []
    connections << "linked_in" if linked_in_login?
    connections << "identica" if identica_login?
    connections << "twitter" if twitter_login?
    connections << "facebook" if facebook_login?
    return connections
  end

  def is_socially_connected?
    linked_in_login? || identica_login? || twitter_login? ||
      facebook_login?
  end

  def has_voted?(voteable)
    !vote_on(voteable).nil?
  end

  def vote_on(voteable)
    voteable.votes[self.id] if voteable.votes
  end

  def favorites(opts = {})
    Answer.where(opts.merge(:favoriter_ids.in => [id]))
  end

  def logged!(group = nil)
    now = Time.zone.now

    if group
      if !member_of?(group) && !group.shapado_version.is_private?
        join!(group)
      end

      if member_of?(group)
        on_activity(:login, group)
      end
    end
  end

  def on_activity(activity, group)
    self.update_reputation(activity, group) if activity != :login
    activity_on(group, Time.zone.now)
  end

  def activity_on(group, date)

    day = date.utc.at_beginning_of_day
    last_day = nil
    membership = config_for(group, false)
    if last_activity_at = membership.last_activity_at
      last_day = last_activity_at.at_beginning_of_day
    end
    membership.override(:last_activity_at => date.utc)

    if last_day != day
      if last_day
        if last_day.utc.between?(day.yesterday - 12.hours, day.tomorrow)
          membership.increment(:activity_days => 1)
          Jobs::Activities.async.on_activity(group.id, self.id).commit!
        elsif !last_day.utc.today? && (last_day.utc != Time.now.utc.yesterday)
          Rails.logger.info ">> Resetting act days!! last known day: #{last_day}"
          reset_activity_days!(group)
        end
      end
    end
  end

  def reset_activity_days!(group)
    Membership.override({:group_id => group.id, :user_id => self.id}, {:activity_days => 0})
  end

  def upvote!(group, v = 1.0)
    Membership.increment({:group_id => group.id, :user_id => self.id}, {:votes_up => v.to_f})
  end

  def downvote!(group, v = 1.0)
    Membership.increment({:group_id => group.id, :user_id => self.id}, {:votes_down => v.to_f})
  end

  def update_reputation(key, group, v = nil)
    unless member_of?(group)
      join!(group)
    end

    if v.nil?
      value = group.reputation_rewards[key.to_s].to_i
      value = key if key.kind_of?(Integer)
    else
      value = v
    end

    return if !value

    Rails.logger.info "#{self.login} received #{value} points of karma by #{key} on #{group.name}"
    membership = config_for(group, false)
    current_reputation = membership.reputation

    today = Time.now.to_s(:ymd)
    if membership.reputation_today.include?(today)
      total_today = membership.reputation_today[today] + value
      if group.daily_cap != 0 && total_today > group.daily_cap
        Rails.logger.info "#{membership.id} hitted daily cap"
        return
      end

      membership.reputation_today[today] = total_today
    else
      membership.reputation_today = {today => value} # override
    end
    membership.reputation = current_reputation + value
    membership.save(:validate => false)

    stats = self.reputation_stats(group)
    stats.save if stats.new?

    event = ReputationEvent.new(:time => Time.now, :event => key,
                                :reputation => current_reputation,
                                :delta => value )
    ReputationStat.collection.update({:_id => stats.id}, {:$addToSet => {:events => event.attributes}})
  end

  def reputation_on(group)
    if config = config_for(group, false)
      config.reputation.to_i
    else
      0
    end
  end

  def views_on(group)
    if config = config_for(group, false)
      config.views_count.to_i
    else
      0
    end
  end

  def comments_count_on(group)
    if config = config_for(group, false)
      config.comments_count.to_i
    else
      0
    end
  end

  def stats(*extra_fields)
    fields = [:_id]

    UserStat.only(fields+extra_fields).where(:user_id => self.id).first || UserStat.create(:user_id => self.id)
  end

  def badges_count_on(group)
    config = config_for(group, false)
    if config
      [config.bronze_badges_count, config.silver_badges_count, config.gold_badges_count]
    else
      [0,0,0]
    end
  end

  def badges_on(group, opts = {})
    grouped = opts.delete(:grouped)
    if grouped
      Badge.collection.master.group({key: [:token, :type], initial: {count: 0}, reduce: "function(doc, prev) { prev.count += 1}", cond: {group_id: group.id, user_id: self.id}}).map do |attributes|
        Badge.new(attributes)
      end
    else
      self.badges.where(opts.merge(group_id: group.id)).order_by(:created_at.desc)
    end
  end

  def find_badge_on(group, token, opts = {})
    self.badges.where(opts.merge(:token => token, :group_id => group.id)).first
  end

  # self follows user
  def add_friend(user)
    return false if user == self
    FriendList.collection.update({ "_id" => self.friend_list_id}, { "$addToSet" => { :following_ids => user.id } })
    FriendList.collection.update({ "_id" => user.friend_list_id}, { "$addToSet" => { :follower_ids => self.id } })

    self.inc(:following_count, 1)
    user.inc(:followers_count, 1)
    true
  end

  def remove_friend(user)
    return false if user == self
    FriendList.collection.update({ "_id" => self.friend_list_id}, { "$pull" => { :following_ids => user.id } })
    FriendList.collection.update({ "_id" => user.friend_list_id}, { "$pull" => { :follower_ids => self.id } })

    self.inc(:following_count, -1)
    user.inc(:followers_count, -1)
    true
  end

  def followers(scope = {}, memberships=false)
    conditions = {}

    conditions[:preferred_languages] = {:$in => scope[:languages]}  if scope[:languages]

    # FIXME
    if !memberships
      conditions[:group_ids] = {:$in => [scope[:group_id]]} if scope[:group_id]

      conditions.merge!(:_id => {:$in => self.friend_list.follower_ids})

      User.where(conditions)
    else
      conditions.merge!(:user_id => {:$in => self.friend_list.follower_ids})
      if scope[:group_id]
        conditions[:group_id] = scope[:group_id]
      end
      Membership.where(conditions)
    end
  end

  def following(group=nil)
    if group.nil?
      User.where(:_id.in => self.friend_list.following_ids)
    else
      Membership.where(:user_id => {:$in => self.friend_list.following_ids}, :group_id => group.id)
    end
  end

  def following?(user)
    FriendList.only(:following_ids).where(:_id => self.friend_list_id).first.following_ids.include?(user.id)
  end

  def viewed_on!(group, ip)
    if member_of? group
      view_count_id = "#{self.id}-#{group.id}-#{ip}"
      if ViewsCount.where({:_id => view_count_id}).first.nil?
        ViewsCount.create(:_id => view_count_id)
        Membership.increment({:group_id => group.id, :user_id => self.id}, {:views_count => 1.0})
      end
    end
  end

  def method_missing(method, *args, &block)
    if !args.empty? && method.to_s =~ /can_(\w*)\_on?/
      key = $1
      group = args.first
      if group.reputation_constrains.include?(key.to_s)
        if group.has_reputation_constrains
          if self.member_of? group
            return self.owner_of?(group) || self.mod_of?(group) || (self.reputation_on(group) >= group.reputation_constrains[key].to_i)
          else
            return false
          end
        else
          return true
        end
      end
    end
    super(method, *args, &block)
  end

  def config_for(group, init = false)
    membership_selector_for(group).first
  end

  def membership_selector_for(group)
    if group.kind_of?(Group)
      group = group.id
    end

    Membership.unscoped.where(:user_id => self.id, :group_id => group)
  end

  def leave(group)
    if group.kind_of?(Group)
      group = group.id
    end

    membership = config_for(group)
    if membership
      membership.state = 'inactive'
      membership.save
      self.pull(group_ids: group)
      user = User.find(self.id)
    end
  end

  def join(group, &block)
    if !self.member_of? group
      if group.kind_of?(Group)
        group = group.id
      end

      membership = config_for(group)
      if membership.nil?
        membership = Membership.new({
          :user_id => self.id,
          :group_id => group,
          :last_activity_at => Time.now,
          :joined_at => Time.now
        })
      else
        membership.state = 'active'
        membership.save
      end
      self.group_ids << group

      block.call(membership) if block

      membership
    end
  end

  def join!(group, &block)
    if membership = join(group, &block)
      membership.save!
      self.save!
    end
  end

  def reputation_stats(group, options = {})
    if group.kind_of?(Group)
      group = group.id
    end
    default_options = { :user_id => self.id,
                        :group_id => group}
    stats = ReputationStat.where(default_options.merge(options)).first ||
            ReputationStat.new(default_options)
  end

  def has_flagged?(flaggeable)
    flaggeable.flags.detect do |flag|
      flag.user_id == self.id
    end
  end

  def has_requested_to_close?(question)
    question.close_requests.detect do |close_request|
      close_request.user_id == self.id
    end
  end

  def has_requested_to_open?(question)
    question.open_requests.detect do |open_request|
      open_request.user_id == self.id
    end
  end

  def generate_uuid
    self.feed_token = UUIDTools::UUID.random_create.hexdigest
  end

  def self.find_file_from_params(params, request)
    if request.path =~ %r{/(avatar|big|medium|small)/([^/\.\?]+)}
      @user = User.find($2)
      avatar = @user.has_avatar? ? @user.avatar : Shapado::FileWrapper.new("#{Rails.root}/public/images/avatar-25.png", "image/png")
      case $1
      when "avatar"
        avatar
      when "big"
        @user.thumbnails["big"] ? @user.thumbnails.get("big") : avatar
      when "medium"
        @user.thumbnails["medium"] ? @user.thumbnails.get("medium") : avatar
      when "small"
        @user.thumbnails["small"] ? @user.thumbnails.get("small") : avatar
      end
    end
  end

  def facebook_friends
    self.external_friends_list.friends["facebook"]
  end

  def social_friends_ids(provider)
    self.send(provider+'_friends').map do |friend| friend["id"].to_s end
  end

  def twitter_friends
    self.external_friends_list.friends["twitter"]
  end

  def identica_friends
    self.external_friends_list.friends["identica"]
  end

  def linked_in_friends
    self.external_friends_list.friends["linked_in"]
  end

  ## TODO: add google contacts
  def suggestions(group, limit = 5)
    rand = Random.rand(2)
    (rand == 0)? rand_tags = suggested_tags(group, limit) :
      rand_tags = suggested_tags_by_suggested_friends(group, limit)
    sample = (suggested_social_friends(group, limit) | rand_tags ).sample(limit)

    # if we find less suggestions than requested, complete with
    # most popular users and tags
    (sample.size < limit) ? sample |
      (group.top_tags_strings(limit+15)-self.preferred_tags_on(group) +
       group.top_users(limit+5)-[self]).
      sample(limit-sample.size) : sample
  end

  # returns tags followed by my friends but not by self
  # TODO: optimize
  def suggested_tags(group, limit = 5)
    friends = Membership.where(:group_id => group.id,
                               :user_id.in => self.friend_list.following_ids,
                               :preferred_tags => {"$ne" => [], "$ne" => nil}).
                         only(:preferred_tags, :login, :name, :user_id)

    friends_tags = { }
    friends.each do |friend|
      (friend.preferred_tags-self.preferred_tags_on(group)).each do |tag|
        friends_tags["#{tag}"] ||= { }
        friends_tags["#{tag}"]["followed_by"] ||= []
        friends_tags["#{tag}"]["followed_by"] << friend
      end
    end
     result = friends_tags.to_a.sample(limit)
     if result.blank?
       return suggested_tags_by_suggested_friends(group, limit = 5)
     else
       return result
     end
  end

  #returns tags followed by self suggested friends
  def suggested_tags_by_suggested_friends(group, limit = 5)
    if suggested_social_friends(group, limit).count > 0
      friends = suggested_social_friends(group, limit).only(:_id).map{|u| u.id}
    end
    unless friends.blank?
      memberships = Membership.where(:group_id => group.id,
                                     :user_id.in => friends,
                                     :preferred_tags => {"$ne" => [], "$ne" => nil},
                                     :_id => {:$not => {:$in => self.friend_list.following_ids}}).
                         only(:preferred_tags, :login, :name, :user_id)

      friends_tags = { }
      memberships.each do |membership|
        friend_preferred_tags = membership.preferred_tags

        if friend_preferred_tags
          (friend_preferred_tags-self.preferred_tags_on(group)).each do |tag|
            friends_tags["#{tag}"] ||= { }
            friends_tags["#{tag}"]["followed_by"] ||= []
            friends_tags["#{tag}"]["followed_by"] << membership.user
          end
        end
      end
      friends_tags.to_a.sample(limit)
    end
    []
  end

  # returns user's providers friends that have an account
  # on shapado but that user is not following
  def suggested_social_friends(group, limit = 5)
    array_hash = []
    social_connections.to_a.each do |provider|
      unless external_friends_list.friends[provider].blank?
        array_hash << { "#{provider}_id".to_sym => {:$in => self.social_friends_ids(provider)}}
      end
    end
    (array_hash.blank?)? [] : self.class.any_of(array_hash).
      where({:group_ids => group.id,
             :_id => {:$not => {:$in => self.friend_list.following_ids << self._id}}}).
      limit(limit)
  end

  # returns user's friends on other social networks that already have an account on shapado
  def social_external_friends
    array_hash = []
    provider_ids = []
    social_connections.to_a.each do |provider|
      array_hash << { "#{provider}_id".to_sym => {:$in => self.social_friends_ids(provider)}}
      provider_ids << "#{provider}_id"
    end
    User.where(:_id => {:$not => self._id}).any_of(array_hash).
      only(provider_ids)
  end

  # returns a follower that is someone self follows
  # if self follows bob and bob follows bill
  # self.common_follower(bill) will return bob
  def common_follower(user)
    User.where(:_id => (self.friend_list.following_ids & user.friend_list.follower_ids).sample).first
  end

  def invite(email, user_role, group, body)
    if self.can_invite_on?(group)
      Invitation.create(:user_id => self.id,
                        :email => email,
                        :group_id => group.id,
                        :user_role => user_role,
                        :body => body,
                        :state => 'pending')
    end
  end

  def revoke_invite(invitation)
    invitation.destroy if self.can_modify?(invitation)
  end

  def can_invite_on?(group)
    return true if self.admin_of?(group) || self.role == 'admin' ||
      group.invitations_perms == 'user' ||
      (group.invitations_perms == 'moderator' &&
       self.mod_of?(group))
    return false
  end

  def accept_invitation(invitation_id)
    invitation = Invitation.find(invitation_id)
    group = invitation.group
    invitation.update_attributes(:accepted => true,
                                 :accepted_by => self.id,
                                 :accepted_at => Time.now) &&
      group.add_member(self, invitation.user_role)
  end

  def pending_invitations(group)
      Invitation.where(:state => 'pending',
                       :group_id => group.id,
                       :user_id => self.id)
  end

  def after_viewing(question)
    rl = ReadList.where(:user_id => self.id).only(:_id).first
    if rl.nil?
      rl = ReadList.create(:user_id => self.id)
    end

    rl.override(:"questions.#{question.id}" => Time.now)
  end

  protected
  def update_languages
    languages = self.preferred_languages.map { |e| e.split("-").first }
    # HACK
    languages.map! do |l|
      if l =~ /.+:(.+)/
        $1
      else
        l
      end
    end
    self.preferred_languages = languages
  end

  def password_required?
    return false if openid_login? || twitter_login? || self.anonymous

    (encrypted_password.blank? || !password.blank?)
  end

  def initialize_fields
    self.friend_list = FriendList.create if self.friend_list.nil?
    self.notification_opts = NotificationConfig.new if self.notification_opts.nil?
  end

  def update_anonymous_user
    return if self.anonymous

    user = User.where({:email => self.email, :anonymous => true}).first
    if user.present?
      Rails.logger.info "Merging #{self.email}(#{self.id}) into #{user.email}(#{user.id})"
      merge_user(user)

      user.destroy
    end
  end

  def create_lists
    external_friends_list = ExternalFriendsList.create
    self.external_friends_list = external_friends_list

    read_list = ReadList.create
    self.read_list = read_list
  end
end
