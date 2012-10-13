class Incident < ActiveRecord::Base
  attr_accessible :description
  attr_accessible :incident_date
  attr_accessible :money_asked
  attr_accessible :money_given
  attr_accessible :public_entity_id
  attr_accessible :place_id
  attr_accessible :approval_status
  attr_accessible :praise

  APPROVED_STATUS = "approved"
  REJECTED_STATUS = "rejected"
  PENDING_STATUS = "pending"

  ALL_APPROVAL_STATUSES = [APPROVED_STATUS, REJECTED_STATUS, PENDING_STATUS]

  validates_inclusion_of :approval_status, :in => ALL_APPROVAL_STATUSES
  
  belongs_to :public_entity
  validates :public_entity_id, :presence => true
  belongs_to :place

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
