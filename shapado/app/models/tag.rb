class Tag
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoidExt::Storage

  identity :type => String
  paginates_per 100

  field :name,  :type => String
  field :description, :type => String
  field :count, :type => Integer, :default => 0
  field :langs, :type => Array
  field :color, :type => String
  field :used_at, :type => Time, :default => Time.now
  field :followers_count, :type => Integer, :default => 0

  file_key :icon, :max_length => 256.kilobytes

  referenced_in :group
  referenced_in :user

  index :name
  index :group_id

  validates_uniqueness_of :name, :scope => :group_id, :allow_blank => false

  validates_length_of       :name,     :minimum => 1

  def self.find_file_from_params(params, request)
    if request.path =~ %r{/(icon)/([^/\.\?]+)/([^\/\.\?]+)}
      @group = Group.find($2)
      @tag = @group.tags.where(:name => $3).first
      case $1
      when "icon"
        @tag.icon
      end
    end
  end
end
