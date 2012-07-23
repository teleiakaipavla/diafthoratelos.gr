class ReadList
  include Mongoid::Document

  identity :type => String

  field :questions, :type => Hash, :default => {} # "id" => date

  belongs_to :user

  index :user_id
end