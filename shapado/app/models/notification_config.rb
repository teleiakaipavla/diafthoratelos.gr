class NotificationConfig
  include Mongoid::Document

  identity :type => String

  field :give_advice, :type => Boolean, :default => true
  field :activities, :type => Boolean, :default => true
  field :reports, :type => Boolean, :default => true
  field :new_answer, :type => Boolean, :default => true
  field :questions_to_twitter, :type => Boolean, :default => false
  field :badges_to_twitter, :type => Boolean, :default => false
  field :favorites_to_twitter, :type => Boolean, :default => false
  field :answers_to_twitter, :type => Boolean, :default => false
  field :comments_to_twitter, :type => Boolean, :default => false
  field :desktop_notifs, :type => Boolean, :default => false

  embedded_in :user, :inverse_of => :notification_opts
end
