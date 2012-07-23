class Comment
  include Mongoid::Document
  include MongoidExt::Voteable
  include Mongoid::Timestamps

#   include Shapado::Models::GeoCommon FIXME


  identity :type => String

  field :body, :type =>  String
  field :language, :type =>  String, :default => "en"
  field :banned, :type =>  Boolean, :default => false

  field :position, :type =>  GeoPosition, :default => GeoPosition.new(0, 0) # FIXME

  field :user_id, :type => String
  referenced_in :user

  embedded_in :commentable, polymorphic: true

  validates_presence_of :body
  validates_presence_of :user

  after_destroy :update_question_last_target

  def update_question_last_target
    self.find_question.update_last_target  if self.find_question
  end

  def group
    self._parent.group
  end

#   ## FIXME quick fix for mongoid bug returning nil
#   def commentable
#     self._parent
#   end

  def can_be_deleted_by?(user)
    ok = (self.user_id == user.id && user.can_delete_own_comments_on?(self.group)) || user.mod_of?(self.group)
    if !ok && user.can_delete_comments_on_own_questions_on?(self.group) && (q = self.find_question)
      ok = (q.user_id == user.id)
    end

    ok
  end

  def find_question
    question = nil
    _parent = self._parent
    if _parent.kind_of?(Question)
      question = _parent
    elsif _parent.respond_to?(:question)
      question = _parent.question
    end

    question
  end

  def question_id
    question_id = nil

    if self._parent.is_a?(Question)
      question_id = self._parent.id
    elsif self._parent.is_a?(Answer)
      question_id = self._parent.question_id
    elsif self._parent.respond_to?(:question)
      question_id = self._parent.question_id
    end

    question_id
  end

  def find_recipient
    if self._parent.respond_to?(:user)
      self._parent.user
    end
  end
end
