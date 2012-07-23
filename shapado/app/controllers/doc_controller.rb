class DocController < ApplicationController
  layout 'doc'
  before_filter :check_ssl, :only => ['plans']
  def privacy
    set_page_title("Privacy")
  end
  def tos
    set_page_title("Terms of service")
  end

  def plans
    if params[:group_id]
      @group = Group.find(params[:group_id])
    else
      @group = current_group
    end
    set_page_title(t('doc.plans.title'))
    render :layout => 'plans'
  end

  def chat
    set_page_title(t('doc.chat.title'))
  end

  protected

  def check_ssl
    return unless AppConfig.force_ssl_on_plans
    if request.protocol == 'http://'
      if current_group.has_custom_domain? && !current_group.is_stripe_customer?
        redirect_to "https://#{AppConfig.domain}/plans?group_id=#{current_group.id}"
      elsif current_group.has_custom_domain? && current_group.is_stripe_customer?
        return
      else
        redirect_to "https://#{current_group.domain}/plans"
      end
    end
  end

end
