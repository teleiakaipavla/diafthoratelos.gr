class Badge
  include Mongoid::Document
  include Mongoid::Timestamps

  TYPES = %w[gold silver bronze]
  GOLD = %w[rockstar popstar fanatic service_medal famous_question celebrity
            great_answer great_question stellar_answer stellar_question]
  SILVER = %w[popular_person guru favorite_answer favorite_question addict good_question
              good_answer notable_question civic_duty enlightened necromancer]
  BRONZE = %w[pioneer supporter critic inquirer troubleshooter commentator
              merit_medal effort_medal student shapado editor popular_question
              friendly interesting_person citizen_patrol cleanup disciplined
              nice_answer nice_question peer_pressure self-learner scholar autobiographer
              organizer tutor altruist benefactor investor promoter]

  def self.TOKENS
    @tokens ||= GOLD + SILVER + BRONZE
  end

  identity :type => String

  referenced_in :user
  validates_presence_of :user

  referenced_in :group
  validates_presence_of :group

  field :token, :type => String
  validates_presence_of :token
  index :token

  field :type, :type => String
  validates_presence_of :type

  field :for_tag, :type => Boolean

  field :source_id, :type => String
  field :source_type, :type => String

  validates_inclusion_of :type,  :in => TYPES
  validates_inclusion_of :token, :in => self.TOKENS, :if => Proc.new { |b| !b.for_tag }

  before_save :set_type

  def self.gold_badges
    self.find_all_by_type("gold")
  end

  def self.type_of(token)
    if BRONZE.include?(token)
      "bronze"
    elsif SILVER.include?(token)
      "silver"
    elsif GOLD.include?(token)
      "gold"
    end
  end

  def to_param
    self.token
  end

  def name(locale=I18n.locale)
    @name ||= I18n.t("badges.shared.#{self.token}.name", :default => self.token.titleize.downcase, :locale => locale) if self.token
  end

  def description
    if self.for_tag
      @description ||= I18n.t("badges.show.for_tag_#{self.type}", tag: self.token)
    else
      @description ||= I18n.t("badges.shared.#{self.token}.description") if self.token
    end
  end

  def type
    self[:type] ||= Badge.type_of(self.token)
  end

  def source=(s)
    if s
      self[:source_id] = s.id
      self[:source_type] = s.class.to_s
    else
      self[:source_id] = nil
      self[:source_type] = nil
    end
  end

  def source
    if self[:source_type]
      self[:source_type].constantize.find(self[:source_id])
    end
  end

  protected
  def set_type
    self[:type] ||= self.class.type_of(self[:token])
  end
end
