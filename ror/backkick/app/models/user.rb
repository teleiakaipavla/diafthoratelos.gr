class User < ActiveRecord::Base
  attr_accessible :name, :password, :password_confirmation, :superuser
  validates :name, presence: true, uniqueness: true
  has_secure_password

  def can_edit_su?
    User.count == 1 || user.superuser?
  end
  
end
