class InvoicesController < ApplicationController
  include ActionView::Helpers::DateHelper
  layout "manage"
  tabs :default => :invoices
  before_filter :authenticate_user!, :except => [:create, :webhook]
  before_filter :owner_required, :except => [:create, :webhook]
  before_filter :check_new_invoice, :only => ['index']
  skip_before_filter :find_group, :only => [:webhook]


  def index
    if params[:ccsuccess] == '1'
      flash[:notice] = 'Credit card updated successfully.'
    elsif params[:ccsuccess] == '0'
      flash[:error] = "Credit card failed \n
          to update for the following reason: #{result}"
    end

    if current_group.shapado_version.uses_stripe &&
      current_group.upcoming_invoice.nil?
      current_group.set_incoming_invoice
    end
    @domain = if current_group.has_custom_domain?
                @group_id = current_group.id
                AppConfig.domain
              else
                current_group.domain
              end
    @invoices = current_group.invoices.where(:payed => true).page(params["page"])
  end

  def show
    @invoice = current_group.invoices.find(params[:id])

    ropts = {}
    ropts[:layout] = "printing" if params[:print] == '1'

    render ropts
  end

  def upcoming
    if current_group.is_stripe_customer?
      @invoice = current_group.upcoming_invoice
    end
  end

  def create
    if !current_user && !params[:group_id]
      @user = User.new
      @user.login = params[:login]
      @user.name = params[:name]
      @user.email = params[:email]
      @user.password = params[:password]
      @user.password_confirmation = params[:password_confirmation]
      return if !@user.save
      sign_in @user
    elsif !current_user && params[:group_id]
      @user = User.where(email: params[:email]).first
      if @user.valid_password?(params[:password])
        sign_in(@user)
      else
        @user = nil
        return
      end
    end
    user = @user || current_user
    if user && !user.owner_of?(current_group) &&
      !params[:group_id]
      @group = Group.new(:language => 'en',
        :subdomain => params[:subdomain],
        :name => params[:group_name],
      )

      @group.owner = user
      @group.state = "active"

      if @group.save
        @group.create_default_widgets
        Jobs::Images.async.generate_group_thumbnails(@group.id)
        @group.add_member(user, "owner")
      end
    end
    if params[:group_id]
      @group = Group.find(params[:group_id])
    else
      @group ||= current_group
    end
    return unless @group
    group = @group || current_group
    return unless user.owner_of?(group)
    token = params[:token]
    shapado_version = ShapadoVersion.where(:token=>token).first
    if shapado_version && shapado_version.uses_stripe?
      Stripe.api_key = PaymentsConfig['secret']
      stripe_token = params[:stripeToken]
      group.charge!(token,stripe_token)
    end
    if group.has_custom_domain?
      redirect_to("http://#{group.domain}#{invoices_path}")
    else
      redirect_to("#{request.protocol}#{group.domain}#{invoices_path}")
    end
  end

  def success
    @invoice = current_group.invoices.find(params[:id])
  end

  def webhook
    group = Group.where(:stripe_customer_id => params["data"]["object"]["customer"]).first
    if ['invoice.payment_succeeded','customer.subscription.updated'].include? params["type"]
      if group && group.shapado_version && group.shapado_version.token == 'private' &&
        ((params["data"] && params["data"]["object"] && params["data"]["object"]["total"] == 0) ||
        params["type"] == 'customer.subscription.updated')
        Stripe.api_key = PaymentsConfig["secret"]
        Stripe::InvoiceItem.create(
          :customer => group.stripe_customer_id,
          :amount => group.memberships.count*group.shapado_version.per_user,
          :currency => "usd",
          :description => I18n.t("invoices.webhook.has_users_fees",
                                 :count => group.memberships.count)
        )

      end
    elsif ['invoice.created','invoiceitem.created','invoice.payment_succeeded'].include?(params["type"]) &&
      group.shapado_version.token == 'private'
      group.set_incoming_invoice
    elsif ['charge.failed','invoice.payment_failed'].include?(params["type"])
      group.set_late_payment
    end

    if ['charge.succeeded','invoice.payment_succeeded'].include?(params["type"])
      group.unset_late_payment
    end
    respond_to do |format|
      format.xml {  head :accepted }
    end
  end

  protected
  def check_new_invoice
    return unless current_group.is_stripe_customer?
    if (current_group.next_recurring_charge &&
        current_group.next_recurring_charge <= Time.now) ||
        current_group.invoices.count == 0
      Stripe.api_key = PaymentsConfig['secret']
      current_group.create_invoices
    end
  end
end
