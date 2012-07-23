
class ReputationEvent
  include Mongoid::Document
  identity :type => String
  field :time, :type => Time
  field :event, :type => String
  field :reputation, :type => Float
  field :delta, :type => Float

  referenced_in :reputation_stat, :inverse_of => :events
end

class ReputationStat
  include Mongoid::Document
  identity :type => String

  references_many :events, :class_name => "ReputationEvent", :validate => false

  field :user_id, :type => String
  referenced_in :user

  field :group_id, :type => String
  referenced_in :group
end
