class Announcement
  include Mongoid::Document
  include Mongoid::Timestamps

  identity :type => String

  field :message, :type => String
  field :starts_at, :type => Timestamp
  field :ends_at, :type => Timestamp

  field :only_anonymous, :type => Boolean, :default => false

  referenced_in :group

  validates_presence_of :message
  validates_presence_of :starts_at
  validates_presence_of :ends_at
  validates_length_of   :message,     :minimum => 5

  validate :check_dates

  protected
  def check_dates
    if self.ends_at > Time.zone.now.yesterday
      if self.starts_at < Time.zone.now.yesterday
        self.errors.add(:starts_at, "Starting date should be setted to a future date")
      end

      if self.ends_at <= self.starts_at
        self.errors.add(:ends_at, "Ending date should be greater than starting date")
      end
    else
      self.errors.add(:ends_at, "Ending date should be greater than yesterday")
    end
    return true
  end
end
