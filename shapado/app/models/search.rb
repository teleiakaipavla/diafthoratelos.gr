class Search
  include Mongoid::Document
  include MongoidExt::Slugizer

  identity :type => String

  field :name, :type => String
  field :query, :type => String
  field :_conditions, :type => String

  slug_key :name

  referenced_in :group
  referenced_in :user

  validates_presence_of :name
  validates_presence_of :query
  validates_presence_of :user
  validates_uniqueness_of :slug, :scope => [:user_id, :group_id]

  before_save :update_conditions

  def conditions
    Object.module_eval(self[:_conditions])
  end

  protected
  def update_conditions
    parsed_query, conds = Question.filter_conditions(self.query, {})
    puts ">>>>>>>>>> #{conds.inspect}"

    self[:_conditions] = conds.inspect
  end
end
