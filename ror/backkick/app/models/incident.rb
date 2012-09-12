class Incident < ActiveRecord::Base
  attr_accessible :description
  attr_accessible :incident_date
  attr_accessible :money_asked
  attr_accessible :money_given
  attr_accessible :public_entity_id
  attr_accessible :status

  APPROVED_STATUS = "approved"
  REJECTED_STATUS = "rejected"
  PENDING_STATUS = "pending"

  ALL_STATUSES = [APPROVED_STATUS, REJECTED_STATUS, PENDING_STATUS]

  validates_inclusion_of :status, :in => ALL_STATUSES
  
  belongs_to :public_entity

  def public_entiry_name
    public_entity.name
  end
  
end
