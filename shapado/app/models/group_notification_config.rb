class GroupNotificationConfig
  include Mongoid::Document

  identity :type => String

  field :questions_to_twitter, :type => Boolean, :default => false
  field :badges_to_twitter, :type => Boolean, :default => false
  field :favorites_to_twitter, :type => Boolean, :default => false
  field :answers_to_twitter, :type => Boolean, :default => false
  field :comments_to_twitter, :type => Boolean, :default => false

  #TODO implement rules such as:
  #field :questions_to_twitter_rules, :type => Array, :default => [{ :answers => '>=0' }, {:views_count => '>0'}]
  # and then in job something such as:
  # if group.notification_opts.questions_to_twitter &&
  #  group.notification_opts.questions_to_twitter_rules.all do |k,v|
  #     eval("if group.#{k} #{v}; return false") end
  #   send_tweet
  # end

  embedded_in :group, :inverse_of => :notification_opts
end
