class Invoice
  include Mongoid::Document
  include Mongoid::Timestamps
  field :stripe_invoice, :type => Hash
  field :stripe_customer, :type => Hash
  field :payed, :type => Boolean, :default => false
  field :payed_at, :type => Time

  field :action, :type => String
  field :version, :type => String

  field :items, :type => Array, :default => []
  field :total, :type => Float, :default => 0.0

  field :order_number, :type => String

  field :stripe_token, :type => String
  field :stripe_invoice_id, :type => String

  field :last4, :type => String
  field :cc_type, :type => String
  field :exp_year, :type => Integer
  field :country, :type => Integer

  referenced_in :group
  referenced_in :user

  validates_presence_of :action, :group, :user
  validates_inclusion_of :action, :in => %w[upgrade_plan]

  attr_protected :payed, :total, :items

  before_create :generate_order_number

  def reset!
    self.items = []
    self.total = 0.0
  end

  def add_item(name, description, value, doc)
    self.items << {
      "name" => name,
      "description" => description,
      "value" => value,
      "item_class" => doc.class.to_s,
      "item_id" => doc.id
    }
    self.total += value
  end

  def total_in_dollars
    return self.stripe_invoice["total"] / 100.0 if self.stripe_invoice
    self.total / 100.0
  end

  def display_name
    self.user.display_name
  end

  def email
    self.user.email
  end

  protected
  def generate_order_number
    self[:order_number] = (self.group.invoices.count+1).to_s.rjust(8, "0")
  end
end
