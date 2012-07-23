class Theme
  include Mongoid::Document
  include MongoidExt::Storage
  include Mongoid::Timestamps

  identity :type => String
  field :name, :type => String
  field :description, :type => String, :default => ""

  field :bg_color, :type => String, :default => "f2f2f2"
  field :fg_color, :type => String, :default => "404040"

  field :view_bg_color, :type => String, :default => "ffffff"
  field :brand_color, :type => String, :default => "ee681f"
  field :topbar_color, :type => String, :default => "ffffff"

  field :fluid, :type => Boolean, :default => false

  field :custom_css, :type => String, :default => ""
  field :community, :type => Boolean, :default => false
  field :ready, :type => Boolean, :default => false

  field :has_js, :type => Boolean, :default => false
  field :version, :type => Integer, :default => 0

  field :last_error, :type => String

  file_key :javascript, :max_length => 256.kilobytes
  file_key :stylesheet, :max_length => 256.kilobytes
  file_key :bg_image, :max_length => 256.kilobytes

  file_key :layout_html, :max_length => 256.kilobytes
  file_key :questions_index_html, :max_length => 256.kilobytes
  file_key :questions_show_html, :max_length => 256.kilobytes


  belongs_to :group
  before_create :js_mime
  before_destroy :set_default_theme

  validates_uniqueness_of :name, :allow_blank => false
  validates_presence_of :name

  def self.find_file_from_params(params, request)
    if request.path =~ /\/(css|bg_image|javascript)\/([^\/\.?]+)\/([^\/\.?]+)/
      @group = Group.find($2)
      @theme = Theme.find($3)
      if !@theme.community && @theme.group != @group
        @theme = @group.current_theme
      end

      case $1
      when "css"
        @theme.stylesheet
      when "bg_image"
        @theme.bg_image
      when "javascript"
        @theme.javascript
      end
    end
  end

  def self.create_default
    theme = Theme.create(:name => "Default", :community => true, :is_default => true)
    Jobs::Themes.async.generate_stylesheet(theme.id).commit!
    theme
  end

  def set_has_js(param)
    if param.blank?
      self["has_js"] = false
    else
      self["has_js"] = true
    end
  end

  def increment_version
    self.version += 1
  end

  protected
  def js_mime
    self.javascript["extension"] = "js"
    self.javascript["content_type"] = "text/javascript"
  end

  def set_default_theme
    if self.group && self.group.current_theme_id == self.id
      self.group.set_default_theme
      self.group.save
    end
  end
end
