class CreditCard
  include Mongoid::Document
  include Mongoid::Timestamps
  include MongoidExt::Encryptor

  encrypted_field :number, :type => Integer, :key => AppConfig.session_secret
  encrypted_field :month, :type => Integer, :key => AppConfig.session_secret
  encrypted_field :year, :type => Integer, :key => AppConfig.session_secret
  encrypted_field :first_name, :type => String, :key => AppConfig.session_secret
  encrypted_field :last_name, :type => String, :key => AppConfig.session_secret
  encrypted_field :verification_code, :type => Integer, :key => AppConfig.session_secret

  field :email, :type => String
  field :address1, :type => String
  field :address2, :type => String
  field :country, :type => String
  field :remember, :type => Boolean, :default => false
  field :credit_card_type, :type => String

  has_many :invoices, :class_name => "Invoice", :validate => false

  referenced_in :group

  validates_presence_of :number
  validates_presence_of :month
  validates_presence_of :year
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :verification_code

  validates_numericality_of :number
  validates_numericality_of :month
  validates_numericality_of :year
  validates_numericality_of :verification_code

  def to_am
    ActiveMerchant::Billing::CreditCard.new(
      :number     => self.number.to_s,
      :month      => self.month.to_s,
      :year       => self.year.to_s,
      :first_name => self.first_name,
      :last_name  => self.last_name,
      :verification_value => self.verification_code.to_s
    )
  end

  def valid?(*args)
    ok = super(*args)
    if ok
      am = to_am
      ok = am.valid?
      if !ok
        self.errors.merge(am.errors.symbolize_keys)
      end
    end

    ok
  end

  def inspect
    number = self.number.to_s
    "Credit Card ending in #{self.ending_in}"
  end

  def ending_in
    number[number.size-4, number.size]
  end


end
