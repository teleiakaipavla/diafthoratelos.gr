class Incident < ActiveRecord::Base
  attr_accessible :description
  attr_accessible :incident_date
  attr_accessible :money_asked
  attr_accessible :money_given
  attr_accessible :public_entity_id
  
  belongs_to :public_entity

  def public_entiry_name
    public_entity.name
  end
  
end
