class Reward
  include Mongoid::Document

  identity :type => String

  field :started_at, :type => Time, :default => Time.now
  field :ends_at, :type => Time

  field :active, :type => Boolean, :default => true
  field :reputation, :type => Integer

  referenced_in :created_by, :class_name => "User"
  embedded_in :question, :inverse_of => :reward

  validates_presence_of :reputation
  validates_presence_of :started_at
  validates_presence_of :created_by
  validates_inclusion_of :reputation, :in => (50..500)

  def reward(group, answer = nil)
    if answer
      if answer.user_id != self.created_by_id
        u = answer.user
        u.update_reputation(:reward, group, self.reputation)
        answer.override(:rewarded => true)
      end
    elsif elegible_answer = self.question.answers.where(:votes_average.gt => 2, :created_at.gt => self.started_at).order_by([[:votes_average, :desc], [:created_at, :asc]]).first
      if elegible_answer.user_id != self.created_by_id
        u = elegible_answer.user
        u.update_reputation(:half_reward, group, self.reputation/2)
        elegible_answer.override(:rewarded => true)
      end
    end

    self.question.unset(:reward => true)
  end
  protected
end
