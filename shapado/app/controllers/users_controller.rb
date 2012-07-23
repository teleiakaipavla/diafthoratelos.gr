class UsersController < ApplicationController
  before_filter :login_required, :only => [:edit, :update,
                                           :follow, :follow_tags, :leave,
                                           :unfollow_tags, :connect, :social_connect]
  skip_before_filter :check_group_access, :only => :auth
  before_filter :find_user, :only => [:show, :answers, :follows, :activity]
  tabs :default => :users

  before_filter :check_signup_type, :only => [:new]
  before_filter :track_pageview

  tab_config = [[:newest, [:created_at, Mongo::DESCENDING]],
                [:hot, [:hotness, Mongo::DESCENDING]],
                [:votes, [:votes_average, Mongo::DESCENDING], [:created_at, Mongo::DESCENDING]],
                [:oldest, [:created_at, Mongo::ASCENDING]]]

  subtabs :index => [[:reputation, "reputation"],
                     [:newest, %w(joined_at desc)],
                     [:oldest, %w(joined_at asc)],
                     [:name, %w(display_name asc)],
                     [:near, ""]],
          :show => [[:votes, [[:votes_average, :desc], [:created_at, :desc]]],
                    [:views, [:views, :desc]],
                    [:newest, [:created_at, :desc]],
                    [:oldest, [:created_at, :asc]]],
        :answers => [[:votes, [[:votes_average, :desc], [:created_at, :desc]]],
                    [:views,  [:views, :desc]],
                    [:newest, [:created_at, :desc]],
                    [:oldest, [:created_at, :asc]]],
        :follows => [[:questions, []],
                     [:following, []],
                     [:followers, []]],
        :by_me => tab_config,
        :preferred => tab_config,
        :expertise => tab_config,
        :feed => tab_config,
        :contributed => tab_config

  def index
    set_page_title(t("users.index.title"))

    order = current_order
    conditions = {}
    conditions = {:display_name => /^#{Regexp.escape(params[:q])}/} if params[:q]

    if order == "reputation"
      order = %w(reputation desc)
    end

    @memberships = current_group.memberships.where(conditions).order_by(order).page(params["page"])

    respond_to do |format|
      format.html
      format.json {
        render :json => @memberships.to_json(:only => %w[name login bio website location language])
      }
      format.js {
        html = render_to_string(:partial => "membership", :collection  => @memberships)
        pagination = render_to_string(:partial => "shared/pagination", :object => @memberships,
                                      :format => "html")
        render :json => {:html => html, :pagination => pagination }
      }
    end

  end

  # render new.rhtml
  def new
    @user = User.new
    @user.preferred_languages = current_languages.to_a
    @user.timezone = AppConfig.default_timezone
  end

  def create
    @user = User.new
    @user.safe_update(%w[login email name password_confirmation password  website
                         language timezone identity_url bio hide_country
                         preferred_languages], params[:user])
    if params[:user]["birthday(1i)"]
      @user.birthday = build_date(params[:user], "birthday")
    end
    success = @user && @user.save
    if success && @user.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      sweep_new_users(current_group)
      if !params[:invitation_id].blank?
        @user.accept_invitation(params[:invitation_id])
        @invitation = Invitation.find(params[:invitation_id])
        @invitation.confirm if @invitation
      end
      flash[:notice] = t("flash_notice", :scope => "users.create")
      sign_in_and_redirect(:user, @user) # !! now logged in
    else
      flash[:error]  = t("flash_error", :scope => "users.create")
      render :action => 'new'
    end
  end

  def show
    @resources = @user.questions.where(:group_id => current_group.id,
                                       :banned => false,
                                       :anonymous => false).
                       order_by(current_order).
                       page(params["page"])

    respond_to do |format|
      format.html
      format.atom { @questions = @resources }
      format.json {
        if params[:tooltip]
          html = render_to_string(:partial => "users/show/show_json", :object => @user)
          render :json => {:success => true, :html => html}
        else
          render :json => @user.to_json(:only => %w[name login bio website location language])
        end
      }
      format.js do
        html = ""
        if params[:facebook]
          html = render_to_string(:partial => "facebook/user", :object => @user)
        else
          html = render_to_string(:partial => "users/user", :object => @user)
        end

        render :json => {:success => true, :html => html}
      end
    end
  end

  def answers
    @resources = @user.answers.where(:group_id => current_group.id,
                                     :banned => false,
                                     :anonymous => false).
                              order_by(current_order).
                              page(params["page"])
    respond_to do |format|
      format.html{render :show}
    end
  end

  def follows
    case @active_subtab.to_s
    when "following"
      @resources = @user.following(current_group).page(params["page"])
    when "followers"
      @resources = @user.followers({:group_id => current_group.id}, true).page(params["page"])
    when "answers"
      @resources = Answer.where(:favoriter_ids.in => [@user.id],
                                :banned => false,
                                :group_id => current_group.id,
                                :anonymous => false).
      order_by(current_order).
      page(params["page"])
    else
      @resources = Question.where(:follower_ids.in => [@user.id],
                                :banned => false,
                                :group_id => current_group.id,
                                :anonymous => false).
                          order_by(current_order).
                          page(params["page"])
    end
    respond_to do |format|
      format.html{render :show}
    end
  end

  def activity
    conds = {}
    case params[:tab]
    when "questions"
      conds[:trackable_type] = "Question"
    when "answers"
      conds[:trackable_type] = "Answer"
    when "users"
      conds[:trackable_type] = "User"
    when "pages"
      conds[:trackable_type] = "Page"
    end
    if current_group
      conds[:group_id] = current_group.id
    end
    @resources = @user.activities.where(conds).page(params["page"])
    respond_to do |format|
      format.html{render :show}
    end
  end

  def edit
    @user = current_user
    @user.timezone = AppConfig.default_timezone if @user.timezone.blank?
  end

  def update
    if params[:id] == 'login' && params[:user].nil? # HACK for facebook-connectable
      redirect_to root_path
      return
    end

    @user = current_user

    if params[:current_password] && @user.valid_password?(params[:current_password])
      @user.encrypted_password = ""
      @user.password = params[:user][:password]
      @user.password_confirmation = params[:user][:password_confirmation]
    end
    if params[:user][:preferred_languages]
      params[:user][:preferred_languages].reject! { |lang| lang.blank? }
    end
    @user.networks = params[:networks]
    @user.safe_update(%w[preferred_languages login email name
                         language timezone bio hide_country
                         website avatar use_gravatar], params[:user])
    @user.notification_opts.safe_update(%w[new_answer give_advice activities reports
       questions_to_twitter badges_to_twitter favorites_to_twitter answers_to_twitter
       comments_to_twitter], params[:user][:notification_opts]) if params[:user][:notification_opts]
    if params[:user]["birthday(1i)"]
      @user.birthday = build_date(params[:user], "birthday")
    end

    Jobs::Users.async.on_update_user(@user.id, current_group.id).commit!

    preferred_tags = params[:user][:preferred_tags]

    if @user.valid? && @user.save
      if params[:user][:avatar]
        Jobs::Images.async.generate_user_thumbnails(@user.id).commit!
      end
      @user.add_preferred_tags(preferred_tags, current_group) if preferred_tags
      if params[:next_step]
        current_user.accept_invitation(params[:invitation_id])
        @invitation = Invitation.find(params[:invitation_id])
        @invitation.confirm if @invitation
        redirect_to accept_invitation_path(:step => params[:next_step], :id => params[:invitation_id])
      else
        redirect_to root_path
      end
    else
      render :action => "edit"
    end
  end

  def connect
    target = User.find(params[:target_id])

    if target.email != current_user.email
      flash[:error] = "you can't merge this account"
      redirect_to social_connect_path and return
    end


    if current_user.merge_user(target)
      target.destroy
      flash[:notice] = "#{target.login} account was merged"
      redirect_to social_connect_path
    else
      flash[:error] = "there was a problem while merging the account #{target.login}"
      redirect_to social_connect_path
    end
  end

  def follow_tags
    @user = current_user
    if tags = params[:tags]
      @user.add_preferred_tags(tags, current_group) if tags
    end
    flash[:notice] = t("users.update_followed_tags.followed.flash_notice",
                       :tag => params[:tags])
    respond_to do |format|
      format.html {redirect_to questions_path}
      format.js {
        render(:json => {:success => true,
                 :message => flash[:notice] }.to_json)
      }
    end
  end

  def unfollow_tags
    @user = current_user
    if tags = params[:tags]
      @user.remove_preferred_tags(tags, current_group)
    end
    flash[:notice] = t("users.update_followed_tags.unfollowed.flash_notice",
                       :tag => params[:tags])
    respond_to do |format|
      format.html {redirect_to questions_path}
      format.js {
        render(:json => {:success => true,
                 :message => flash[:notice] }.to_json)
      }
    end
  end

  def follow
    @user = User.find_by_login_or_id(params[:id])

    if @user != current_user && @user.member_of?(current_group)
      current_user.add_friend(@user)

      flash[:notice] = t("flash_notice", :scope => "users.follow", :user => @user.login)
      message = flash[:notice]
      Jobs::Activities.async.on_follow(current_user.id, @user.id, current_group.id).commit!
      Jobs::Mailer.async.on_follow(current_user.id, @user.id, current_group.id).commit!
      success = true
    else
      success = false
      flash[:error] = t("flash_error", :scope => "users.follow", :user => @user.login)
      message = flash[:error]
    end

    respond_to do |format|
      format.html do
        redirect_to user_path(@user)
      end
      format.json {
        render(json: {success: success, message: message }.to_json)
      }
    end
  end

  def unfollow
    @user = User.find_by_login_or_id(params[:id])
    current_user.remove_friend(@user)

    flash[:notice] = t("flash_notice", :scope => "users.unfollow", :user => @user.login)

    Jobs::Activities.async.on_unfollow(current_user.id, @user.id, current_group.id).commit!

    respond_to do |format|
      format.html do
        redirect_to user_path(@user)
      end
      format.js { render(json: {success: true, message: flash[:notice] }.to_json) }
    end
  end

  def autocomplete_for_user_login
    @users = User.only(:login).
                  where(:login =>  /^#{Regexp.escape(params[:term].to_s.downcase)}.*/).
                  limit(20).
                  order_by(:login.desc).
                  all

    respond_to do |format|
      format.json {render :json=>@users}
    end
  end

  def destroy
    if false && current_user.delete # FIXME We need a better way to delete users
      flash[:notice] = t("destroyed", :scope => "devise.registrations")
    else
      flash[:notice] = t("destroy_failed", :scope => "devise.registrations")
    end
    return redirect_to(:root)
  end

  def suggestions
  end

  def leave
    current_user.leave(current_group)
    return redirect_to :root
  end

  def join
    current_user.join(current_group)
    return redirect_to :root
  end

  def auth
    if params["pp"]
      cookies["pp"] = 1
    end

    head :status => 404
  end

  def social_connect
  end

  def new_password
    sign_out(current_user)
    redirect_to new_user_password_path
  end

  protected
  def check_signup_type
    if current_group.is_social_only_signup? ||
        current_group.is_noemail_signup?
      redirect_to '/'
    end
  end

  def active_subtab(param)
    key = params.fetch(param, "votes")
    order = "votes_average desc, created_at desc"
    case key
      when "votes"
        order = "votes_average desc, created_at desc"
      when "views"
        order = "views desc, created_at desc"
      when "newest"
        order = "created_at desc"
      when "oldest"
        order = "created_at asc"
    end
    [key, order]
  end

  def find_user
    conds = {}
    conds[:se_id] = params[:se_id] if params[:se_id]
    @user = User.find_by_login_or_id(params[:id], conds)
    raise Error404 unless @user
    set_page_title(t("users.show.title", :user => @user.login))
    @badges = @user.badges_on(current_group, grouped: true);

    add_feeds_url(url_for(:format => "atom"), t("feeds.user"))

    @user.viewed_on!(current_group, request.remote_ip) if @user != current_user && !is_bot?
  end
end


