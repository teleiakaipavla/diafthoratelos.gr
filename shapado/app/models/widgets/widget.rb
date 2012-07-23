class Widget
  include Mongoid::Document

  identity :type => String
  field :name, :type => String
  field :settings, :type => Hash
  field :position, :type => String

#   validate :set_name, :on => :create
  validates_presence_of :name
  validate :check_settings

  embedded_in :widget_list_questions, :inverse_of => :question_widgets
  embedded_in :widget_list_external, :inverse_of => :external_widgets
  embedded_in :widget_list_mainlist, :inverse_of => :mainlist_widgets

  def group
    self._parent._parent
  end

  def initialize(*args)
    super(*args)

    self[:name] ||= self.class.to_s.sub("Widget", "").underscore
  end

  def self.types(tab="",ads=false)
    types = %w[UsersWidget AboutWidget BadgesWidget TopUsersWidget TagCloudWidget
 PagesWidget CurrentTagsWidget CustomHtmlWidget SuggestionsWidget GroupNetworksWidget ShareWidget]
    if ads
      types += %w[AdsenseWidget]
    end

    if tab == 'question'
      types += %w[ContributorsWidget QuestionBadgesWidget QuestionStatsWidget RelatedQuestionsWidget]
    end
    if tab == 'external'
      types += ["AskQuestionWidget"]
    end
    if AppConfig.enable_groups
      types += %w[GroupsWidget TopGroupsWidget]
    end

    types
  end


  def question_only?
    false
  end

  def partial_name
    "widgets/#{self.name}"
  end

  def update_settings(options)
    options[:notitle] = ["on", "true"].include?(options[:notitle])
    self.settings = options
    ##TODO: check what's going in
    self.settings = options[:settings]
  end

  def description
    @description ||= I18n.t("widgets.#{self.name}.description") if self.name
  end

  def cache_keys(params)
    ""
  end

  protected
  def limit_to_int
    self[:settings]['limit'] = self[:settings]['limit'].to_i
  end

  def set_name
    self[:name] ||= self.class.to_s.sub("Widget", "").underscore
  end

  def check_settings
  end
end

