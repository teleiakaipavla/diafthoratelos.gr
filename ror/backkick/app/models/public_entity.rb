class PublicEntity < ActiveRecord::Base
  attr_accessible :name
  attr_accessible :category_id

  validates :name, presence: true
  validates :name, uniqueness: true

  belongs_to :category
  has_many :incidents
end
