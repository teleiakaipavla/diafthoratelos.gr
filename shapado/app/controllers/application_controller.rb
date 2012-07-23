# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Rack::Recaptcha::Helpers
  include Subdomains
  include Sweepers

  include Shapado::Controllers::Access
  include Shapado::Controllers::Routes
  include Shapado::Controllers::Locale
  include Shapado::Controllers::Utils

  if !AppConfig.recaptcha['activate']
    def recaptcha_valid?
      true
    end
  end

  protect_from_forgery

  before_filter :check_cookies
  before_filter :find_group
  before_filter :check_group_access
  before_filter :set_locale
  before_filter :find_languages
  before_filter :share_variables
  before_filter :check_social
  before_filter :set_custom_headers
  before_filter :check_sidebar

  layout :set_layout

  helper_method :recaptcha_tag

  rescue_from Error404, :with => :render_404
  rescue_from Mongoid::Errors::DocumentNotFound, :with => :render_404

  protected

  def check_social
    if logged_in? && current_group.is_social_only_signup? &&
        !current_user.is_socially_connected?
      redirect_to social_connect_path if params[:controller] == 'questions'
    end
  end

  def check_cookies
    if params[:format] == 'mobile'
      cookies.delete(:pp)
      session[:user_return_to] = '/mobile'
    end
  end

  def find_group
    @current_group ||= begin
      subdomains = request.subdomains
      subdomains.delete("www") if request.host == "www.#{AppConfig.domain}"
      _current_group = Group.where({:state => "active", :domain => request.host}).first
      unless _current_group
        if subdomain = subdomains.first
          _current_group = Group.where(:state => "active", :subdomain => subdomain).first
          unless _current_group.nil?
            redirect_to domain_url(:custom => _current_group.domain)
            return
          end
        end
        flash[:warn] = t("global.group_not_found", :url => request.host)
        redirect_to domain_url(:custom => AppConfig.domain)
        return
      end
      _current_group
    end
    @current_group
  end

  def find_questions(extra_conditions = {}, extra_scope = { })
    if params[:language] || request.query_string =~ /tags=/
      params.delete(:language)
      head :moved_permanently, :location => url_for(params)
      return
    end

    set_page_title(t("questions.index.title"))
    conditions = scoped_conditions(:banned => false)

    if params[:sort] == "hot"
      conditions[:activity_at] = {"$gt" => 5.days.ago}
    end

    @active_tab = "questions"
    if params[:unanswered]
      conditions[:answered_with_id] = nil
      @active_tab = "unanswered"
    elsif params[:answers]
      @active_tab = "answers"
    end
    @active_subtab ||= params[:sort] || "newest"

    @questions = Question.minimal.where(conditions.merge(extra_conditions)).order_by(current_order)

    extra_scope.keys.each do |key|
      @questions = @questions.send(key, extra_scope[key])
    end

    @questions = @questions.page(params["page"])

    @langs_conds = @languages

    if logged_in?
      feed_params = { :feed_token => current_user.feed_token }
    else
      feed_params = {  :lang => I18n.locale, :mylangs => current_languages }
    end
    add_feeds_url(url_for({:format => "atom"}.merge(feed_params)), t("feeds.questions"))
    if params[:tags]
      add_feeds_url(url_for({:format => "atom", :tags => params[:tags]}.merge(feed_params)),
                    "#{t("feeds.tag")} #{params[:tags].inspect}")
    end

    respond_to do |format|
      format.html { render :layout => layout_for_theme }
      format.mobile
      format.json  { render :json => @questions.to_json(:except => %w[_keywords watchers slugs]) }
      format.atom
    end
  end

  def find_activities(conds = {})
    #add_feeds_url(url_for({:format => "atom"}.merge(feed_params)), t("feeds.questions"))

    @activities = current_group.activities.where(conds).order(:created_at.desc).page(params["page"])

    respond_to do |format|
      format.html
      format.json { render :json => @activities}
    end
  end

  def current_group
    @current_group
  end
  helper_method :current_group

  def current_version
    @current_version ||= begin
      current_group.shapado_version ? current_group.shapado_version : ShapadoVersion.libre
    end
  end
  helper_method :current_version

  def scoped_conditions(conditions = {})
    unless current_tags.empty?
      conditions.deep_merge!({:tags => {:$all => current_tags}})
    end
    conditions.deep_merge!({:group_id => current_group.id})
    conditions.deep_merge!(language_conditions)
    conditions
  end
  helper_method :scoped_conditions

  def set_layout
    if !user_signed_in? && request.host == AppConfig.domain && request.path == '/'
      'shapadocom'
    elsif env && env['HTTP_X_PJAX'].present? && !params[:_refresh]
      nil
    elsif devise_controller? || (action_name == "new" && controller_name == "users")
      'sessions'
    elsif params["format"] == "mobile"
      'mobile'
    elsif current_group.current_theme.has_layout_html?
      'theme_layout.mustache.mustache'
    elsif current_group.layout.present?
      current_group.layout
    else
      'application'
    end
  end

  def check_sidebar
    return if !current_group

    @widget_context = widgets_context(params[:controller], params[:action])
    @show_sidebar = !( params[:controller] == "users")

    if @show_sidebar
      @show_sidebar = current_group.send(:"#{@widget_context}_widgets").sidebar.count > 0
    end
  end

  def widgets_context(controller, action)
    @widgets_context ||= (controller == "questions" && action == "show" && @question.present?) ? 'question' : 'mainlist'
  end

  def layout_for_theme
    if @template_format == 'mustache'
      current_group.current_theme.has_layout_html?
    else
      true
    end
  end

  def set_custom_headers
    if env && env['HTTP_X_PJAX'].present?
      response.headers['X-BODYCLASS'] = bodys_class(params).join(" ")
    end
  end

  def render_404
    Rails.logger.info "ROUTE NOT FOUND (404): #{request.url}"

    respond_to do |format|
      format.html { render "public_errors/not_found", :status => '404 Not Found' }
      format.json { render :json => {:success => false, :message => "Not Found"}, :status => '404 Not Found' }
    end
  end

  # override from devise
  def after_sign_out_path_for(resource)
    params[:format] == "mobile" ? "/mobile" : root_path
  end

  def after_sign_in_path_for(resource_or_scope)
    self.current_user.logged!(self.current_group)
    super(resource_or_scope)
  end

  def share_variables
    Thread.current[:current_group] = current_group
    Thread.current[:current_user] = current_user
    Thread.current[:current_ip] = request.remote_ip
  end

  def process_payment_and_redirect(success, invoice)
    Rails.logger.info ">> A PAYMENT WAS MADE: #{success.inspect}"
    if success
      flash[:notice] = "The payment was successful"
      case invoice.action
      when "upgrade_plan"
        invoice.items.each do |item|
          if item["item_class"] == "ShapadoVersion"
            current_group.override(:shapado_version_id => item["item_id"],
                                     :plan_expires_at => Time.now + 1.month)

          end
        end
      end

      redirect_to root_path
    else
      flash[:error] = "Something went wrong with the payment"
      redirect_to root_path
    end

  end

  def close

  end
end
