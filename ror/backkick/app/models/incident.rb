require 'i18n'

class Incident < ActiveRecord::Base

  attr_accessible :description
  attr_accessible :incident_date
  attr_accessible :money_asked
  attr_accessible :money_given
  attr_accessible :public_entity_id
  attr_accessible :place_id
  attr_accessible :approval_status
  attr_accessible :praise
  attr_accessible :moderator_public_comment

  APPROVED_STATUS = I18n.t(:approved, :locale => :en)
  REJECTED_STATUS = I18n.t(:rejected, :locale => :en)
  PENDING_STATUS = I18n.t(:pending, :locale => :en)
  TO_APPROVE = I18n.t(:to_approve, :locale => :en)
  TO_REJECT = I18n.t(:to_reject, :locale => :en)
  NEEDS_SECOND_CHECK = I18n.t(:needs_second_check, :locale => :en)

  APPROVED_STATUS_L = I18n.t(:approved)
  REJECTED_STATUS_L = I18n.t(:rejected)
  PENDING_STATUS_L = I18n.t(:pending)
  TO_APPROVE_L = I18n.t(:to_approve)
  TO_REJECT_L = I18n.t(:to_reject)
  NEEDS_SECOND_CHECK_L = I18n.t(:needs_second_check)
  
  ALL_APPROVAL_STATUSES =
    [APPROVED_STATUS,
     REJECTED_STATUS,
     PENDING_STATUS,
     TO_APPROVE,
     TO_REJECT,
     NEEDS_SECOND_CHECK
    ]

  ALL_APPROVAL_STATUSES_L =
    [APPROVED_STATUS_L,
     REJECTED_STATUS_L,
     PENDING_STATUS_L,
     TO_APPROVE_L,
     TO_REJECT_L,
     NEEDS_SECOND_CHECK_L
    ]

  ALL_APPROVAL_STATUSES_PAIRS =
    ALL_APPROVAL_STATUSES_L.zip(ALL_APPROVAL_STATUSES)
  
  validates_inclusion_of :approval_status, :in => ALL_APPROVAL_STATUSES
  
  belongs_to :public_entity
  validates :public_entity_id, :presence => true
  belongs_to :place

  def self.status_counts
    result = {}
    Incident.select("approval_status, count(*) as status_count")
      .group("approval_status").each do |r|
        result[r.approval_status] = r.status_count
      end
    result
  end

  def self.status_counts_to_s
    status_counts = Incident.status_counts
    Incident::ALL_APPROVAL_STATUSES.each_with_index.map do |s, i|
      "#{ALL_APPROVAL_STATUSES_L[i]}: #{status_counts[s] || 0}"
    end.join(", ")
  end
  
  def to_text
    "description: #{self.description}\n" +
      "incident date: #{self.incident_date}\n" +
      "money asked: #{self.money_asked}\n" +
      "money given: #{self.money_given}\n" +
      "public entity name: #{self.public_entity_name}\n" +
      "place_name: #{self.place_name}\n" +
      "approval status: #{self.approval_status}\n" +
      "praise: #{self.praise}\n"
  end
  
  def public_entity_name
    if self.public_entity
      self.public_entity.name
    else
      nil
    end
  end

  def place_name
    if self.place
      self.place.name
    else
      nil
    end
  end

  def category_id
    if self.public_entity
      self.public_entity.category_id
    else
      nil
    end
  end
  
  def copy_public_entity_id_from!(public_entity_name)
    
    if !(public_entity_name.nil? || public_entity_name == "")
      public_entity_query = PublicEntity.where(:name => public_entity_name)
      if public_entity_query.any?
        self.public_entity_id = public_entity_query.first.id
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def copy_or_create_place_from!(place_params)
    
    place  = Place.new()

    if place_params.nil?
      return place
    end

    place_name = place_params[:name]
    if !(place_name.nil? || place_name == "")
      place = Place.where(:name => place_name).first_or_create(place_params)
      if place.errors.empty?
        self.place_id = place.id
      end
    end

    return place
    
  end
    
end
