class Draft
  include Mongoid::Document
  include Mongoid::Timestamps

  identity :type => String
  embeds_one :question
  embeds_one :answer

  def self.cleanup!
    Draft.delete_all(:created_at.lt => 8.days.ago)
  end
end
