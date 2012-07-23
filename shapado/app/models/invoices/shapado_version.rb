class ShapadoVersion
  include Mongoid::Document

  field :token, :type => String, :index => true
  field :price, :type => Integer

  field :page_views, :type => Integer
  field :custom_ads, :type => Boolean
  field :custom_js, :type => Boolean
  field :custom_domain, :type => Boolean
  field :private, :type => Boolean
  field :custom_themes, :type => Boolean
  field :basic_support, :type => Boolean
  field :phone_support, :type => Boolean
  field :uses_stripe, :type => Boolean

  references_many :groups, :validate => false

  validates_presence_of :token, :price
  validates_uniqueness_of :token

  def uses_stripe?
    self.uses_stripe
  end

  def has_custom_ads?
    self.custom_ads
  end

  def has_custom_js?
    self.custom_js
  end

  def has_custom_domain?
    self.custom_domain
  end

  def is_private?
    self.private
  end

  def has_custom_themes?
    self.custom_themes
  end

  def has_basic_support?
    self.basic_support
  end

  def has_phone_support?
    self.phone_support
  end

  def name
    I18n.t("versions.#{token}")
  end

  def in_dollars
    self.price / 100.0
  end

  def self.libre
    @libre ||= ShapadoVersion.new(:page_views => 0, :custom_ads => true, :custom_js => true,
                                  :custom_domain => true, :private => false, :custom_themes => true,
                                  :basic_support => false, :phone_support => false, :price => 0)
  end

  def self.reload!
    return unless AppConfig.is_shapadocom

    versions_data = YAML.load_file("#{Rails.root}/config/versions.yml")

    versions_data.each do |token, data|
      version = ShapadoVersion.where(:token => token).first
      if version.nil?
        version = ShapadoVersion.create!(data.merge(:token => token))
        if version.uses_stripe?
          Stripe.api_key = PaymentsConfig['secret']
          plan = Stripe::Plan.retrieve(version.token) rescue plan = nil
          if plan
            puts "Plan #{version.token} already exists."
            plan.name = version.token.titleize
            plan.save
          else
            Stripe::Plan.create(
                                :amount => version.price,
                                :interval => 'month',
                                :name => version.token.titleize,
                                :currency => 'usd',
                                :id => version.token
                                )
          end
        else
          puts "#{version.token} not a Stripe plan"
        end
      else
        version.update_attributes(data)
        if version.uses_stripe?
          Stripe.api_key = PaymentsConfig['secret']
          plan = Stripe::Plan.retrieve(version.token) rescue plan = nil
          if plan
            puts "Plan #{version.token} already exists."
            plan.name = version.token.titleize
            plan.save
          end
        end
      end
    end
  end
end
