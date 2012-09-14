class Place < ActiveRecord::Base
  attr_accessible :address, :latitude, :longitude, :name

  has_many :incidents
end
