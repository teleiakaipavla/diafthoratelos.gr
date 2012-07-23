class QuestionsController < ApplicationController
  before_filter :login_required, :except => [:new, :create, :index, :show, :related_questions, :tags_for_autocomplete, :retag, :retag_to, :random, :history, :diff]
  before_filter :admin_required, :only => [:move, :move_to]
  before_filter :moderator_required, :only => [:close]
  before_filter :check_permissions, :only => [:solve, :unsolve, :destroy]
  before_filter :check_update_permissions, :only => [:edit, :update, :revert, :remove_attachment]
  before_filter :set_active_tag
  before_filter :check_age, :only => [:show]
  before_filter :check_create_permissions, :only => [:create, :new]
  before_filter :check_retag_permissions, :only => [:retag, :retag_to]
  before_filter :track_pageview

  tabs :default => :questions, :tags => :tags,
       :new => :ask_question

  subtabs :index => [[:activity, [:activity_at, :desc]],
                     [:newest, [:created_at, Mongo::DESCENDING]],
                     [:hot, [[:hotness, Mongo::DESCENDING],
                             [:views_count, Mongo::DESCENDING]]],
                     [:followers, [:followers_count, Mongo::DESCENDING]],
                     [:votes, [:votes_average, Mongo::DESCENDING]],
                     [:expert, [:created_at, Mongo::DESCENDING]]],
          :show => [[:votes, [:votes_average, Mongo::DESCENDING]], [:oldest, [:created_at, Mongo::ASCENDING]], [:newest, [:created_at, Mongo::DESCENDING]]]
  helper :votes

  # GET /questions
  # GET /questions.xml

  # My feed, this returns:
  # - all the questions I asked
  # - all the questions I follow
  # - all the questions followed by people I follow
  #   (questions followed by people I find interesting must be interesting to me)
  # - all the questions tagged with one of the tag I follow_up

  def index
    if current_group.current_theme.has_questions_index_html? && current_group.current_theme.questions_index_html.size > 0
      @template_format = 'mustache'
      request.format = :mustache
    end

    if params[:filter] || session[:filter]
      filter = params[:filter] || session[:filter]
      session[:filter] = filter
      case filter
      when 'feed'
        tags = current_user.preferred_tags_on(current_group)
        user_ids = current_user.friend_list.following_ids
        user_ids << current_user.id
        find_questions({ }, :any_of => [{:follower_ids.in => user_ids},
                                        {:tags.in => tags},
                                        {:user_id => user_ids}])
      when 'by_me'
        find_questions(:user_id => current_user.id)
      when 'preferred'
        @current_tags = tags = current_user.preferred_tags_on(current_group)
        find_questions(:tags => {:$in => tags})
      when 'expertise'
        @current_tags = tags = current_user.stats(:expert_tags).expert_tags # TODO: optimize
        find_questions(:tags => {:$in => tags})
      when 'contributed'
        find_questions(:contributor_ids.in => [current_user.id])
      else
        session.delete :filter
        find_questions
      end
    else
      find_questions
    end
  end


  def history
    @question = current_group.questions.by_slug(params[:id])

    respond_to do |format|
      format.html
      format.json { render :json => @question.versions.to_json }
    end
  end

  def diff
    @question = current_group.questions.by_slug(params[:id])
    @prev = params[:prev]
    @curr = params[:curr]
    if @prev.blank? || @curr.blank? || @prev == @curr
      flash[:error] = "please, select two versions"
      render :history
    else
      if @prev
        @prev = (@prev == "current" ? "current" : @prev.to_i)
      end

      if @curr
        @curr = (@curr == "current" ? "current" : @curr.to_i)
      end
    end
  end

  def revert
    @question.load_version(params[:version].to_i)

    respond_to do |format|
      format.html
    end
  end

  def related_questions
    @question = nil
    if params[:id]
      @question = current_group.questions.by_slug(params[:id])
    elsif params[:question]
      @question = Question.new(params[:question])
      @question.group_id = current_group.id
    end

    return render_404 if @question.nil?

    if params[:unanswers]
      conditions[:answered_with_id] = nil
    end

    @questions = Question.related_questions(@question).page(params[:page])

    respond_to do |format|
      format.js do
        content = ''
        settings = {}
        if !@questions.empty?
          if params[:mini]
            content = render_to_string(:partial => "questions/question",
                                     :collection  => @questions,
                                     :locals => {:mini => true, :lite => true});
          else
            content = render_to_string(:partial => "shared/post",
                                       :locals => {:questions => @questions,
                                       :for_answers => params[:answers]})
          end
        end
        render :json => {:html => content, :message => t('searches.index.found_results', :quantity => @questions.total_count, :spelling_suggestion => @questions.spelling_suggestion) }.to_json
      end
    end
  end

  def tags_for_autocomplete
    respond_to do |format|
      format.js do
        result = []
        if q = params[:term]
          result = Tag.where(:name => /^#{Regexp.escape(q.downcase)}/i,
                    :group_id => current_group.id).order(:count => :desc)
        end

        results = result.map do |t|
          {:caption => "#{t.name} (#{t.count.to_i})", :value => t.name}
        end
        # if no results, show default tags
        if results.empty?
          results = current_group.default_tags.map  {|tag|{:value=> tag, :caption => tag}}
          results = [{ :value => q, :caption => q }] + results
        end
        render :json => results
      end
    end
  end

  # GET /questions/1
  # GET /questions/1.xml
  def show
    if current_group.current_theme.has_questions_show_html?
      @template_format = 'mustache'
      request.format = :mustache
    end

    if @question.reward && @question.reward.ends_at < Time.now
      Jobs::Questions.async.close_reward(@question.id).commit!(1)
    end

    options = {:banned => false}
    options[:_id] = {:$ne => @question.answer_id} if @question.answer_id
    @answers = @question.answers.where(options).
                                order_by(current_order).
                                without(:_keywords).
                                page(params["page"])

    @answer = Answer.new(params[:answer])

    if @question.user != current_user && !is_bot?
      @question.viewed!(request.remote_ip)

      if (@question.views_count % 10) == 0
        sweep_question_views
      end
    end

    set_page_title(@question.title)
    add_feeds_url(url_for(:format => "atom"), t("feeds.question"))

    if current_user && (rl=ReadList.where(:user_id => current_user.id, :"questions.#{@question.id}" => {:$exists => true}).only(:"questions.#{@question.id}").first)
      @last_read_at = rl.questions[@question.id]
    end

    respond_to do |format|
      format.html {
        if @question.views_count >= 1000
          Jobs::Questions.async.on_view_question(@question.id).commit!(5)
        end
        current_user.after_viewing(@question) if current_user

        render :layout => layout_for_theme
      }
      format.mobile
      format.json  { render :json => @question.to_json(:except => %w[_keywords slug watchers]) }
      format.atom
    end
  end

  # GET /questions/new
  # GET /questions/new.xml
  def new
    @question = Question.new(params[:question])

    if params[:from_question]
      @original_question = Question.minimal.without(:comments).where(:_id => params[:from_question]).first

      if params[:at]
        @original_answer = @original_question.answers.without(:votes, :versions, :flags, :comments).where(:_id => params[:at]).first
      end
    end

    respond_to do |format|
      format.html # new.html.erb
      format.mobile
      format.json  { render :json => @question.to_json }
    end
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.xml
  def create
    @question = Question.new
    if !params[:tag_input].blank? && params[:question][:tags].blank?
      params[:question][:tags] = params[:tag_input]
    end

    @question.group = current_group
    @question.user = current_user
    @question.safe_update(%w[title body language tags wiki position attachments], params[:question])

    if params[:original_question_id]
      @question.follow_up = FollowUp.new
      @question.follow_up.original_question_id = params[:original_question_id]
      @question.follow_up.original_answer_id = params[:original_answer_id]
    end

    @question.anonymous = params[:question][:anonymous] if current_group.enable_anonymous

    if !logged_in?
      if recaptcha_valid? && params[:user]
        @user = User.where(:email => params[:user][:email]).first
        if @user.present?
          if !@user.anonymous
            flash[:notice] = I18n.t('questions.create.already_registered', :email => params[:user][:email])
            return create_draft!
          else
            @question.user = @user
          end
        elsif current_group.enable_anonymous
          @user = User.new(:anonymous => true, :login => "Anonymous")
          @user.safe_update(%w[name email website], params[:user])
          if @user.name.present? && @user.name.size > 3
            @user.login = @user.name
          end
          @user.save!
          @question.user = @user
        else
          return login_required
        end
      elsif !AppConfig.recaptcha["activate"]
        return create_draft!
      end
    end

    return login_required if !@question.user

    respond_to do |format|
      if (logged_in? ||  (@question.user.valid? && recaptcha_valid?)) && @question.save
        @question.add_contributor(@question.user)

        sweep_question_views
        html = nil
        if params[:facebook]
          html = render_to_string(:partial => "facebook/question", :object => @question)
        else
          html = render_to_string(:partial => "questions/question", :object => @question)
        end

        Magent::WebSocketChannel.push({id: "newquestion",
                                       object_id: @question.id,
                                       name: @question.title,
                                       html: html,
                                       channel_id: current_group.slug})

        current_group.tag_list.add_tags(*@question.tags)
        unless @question.anonymous
          @question.user.stats.add_question_tags(*@question.tags)
          @question.user.on_activity(:ask_question, current_group)
          link = question_url(@question)
          Jobs::Questions.async.on_ask_question(@question.id, link).commit!
          Jobs::Mailer.async.on_ask_question(@question.id).commit!
        end

        Jobs::Tags.async.question_retagged(@question.id, @question.tags, [], Time.now).commit!

        current_group.on_activity(:ask_question)
        if !@question.removed_tags.blank?
          flash[:warning] = I18n.t("questions.model.messages.tags_not_added",
                                   :tags => @question.removed_tags.join(", "),
                                   :reputation_required => @question.group.reputation_constrains["create_new_tags"])
        else
          flash[:notice] = t(:flash_notice, :scope => "questions.create")
        end

        format.html {
          if widget = params[:question][:external_widget]
            flash[:notice] += I18n.t('widgets.ask_question.view_question', :question => question_path(@question))
            redirect_to embedded_widget_path(:id => widget)
          else
            redirect_to(question_path(@question))
          end
        }
        format.json { render :json => @question.to_json(:except => %w[_keywords watchers]), :status => :created}
        format.js {render :json => {:success => true, :message => flash[:notice], :html => html} }
      else
        @question.errors.add(:captcha, "is invalid") unless recaptcha_valid?
        format.html { render :action => "new" }
        format.json { render :json => @question.errors+@question.user.errors }
        format.js { render :json => {:success => false, :message => (@question.errors+@question.user.errors).join(", ")} }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    respond_to do |format|
      if !params[:tag_input].blank? && params[:question][:tags].blank?
        params[:question][:tags] = params[:tag_input]
      end
      @question.safe_update(%w[title body language tags wiki adult_content version_message attachments], params[:question])

      @question.updated_by = current_user
      @question.last_target = @question

      changes = @question.changes
      tags_changes = changes["tags"]

      if @question.save
        @question.add_contributor(current_user)

        sweep_question(@question)

        if tags_changes
          Jobs::Tags.async.question_retagged(@question.id, tags_changes.last, tags_changes.first, Time.now).commit!
        end

        Magent::WebSocketChannel.push({id: "updatequestion",
                                       object_id: @question.id,
                                       name: @question.title,
                                       changes: changes,
                                       channel_id: current_group.slug})

        if !@question.removed_tags.blank?
          flash[:warning] = I18n.t("questions.model.messages.tags_not_added",
                                   :tags => @question.removed_tags.join(", "),
                                   :reputation_required => @question.group.reputation_constrains["create_new_tags"])
        else
          flash[:notice] = t(:flash_notice, :scope => "questions.update")
        end
        format.html { redirect_to(question_path(@question)) }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    if @question.user_id == current_user.id
      @question.user.update_reputation(:delete_question, current_group)
    end
    sweep_question(@question)
    @question.answers.each do |answer|
      sweep_answer(answer)
    end
    @question.destroy

    Jobs::Questions.async.on_destroy_question(current_user.id, @question.attributes).commit!
    Magent::WebSocketChannel.push({id: "destroyquestion",
                                   object_id: @question.id,
                                   name: @question.title,
                                   channel_id: current_group.slug});

    respond_to do |format|
      format.html { redirect_to(questions_url) }
      format.json  { head :ok }
    end
  end

  def solve
    @answer = @question.answers.find(params[:answer_id])
    @question.answer = @answer
    @question.accepted = true
    @question.answered_with = @answer if @question.answered_with.nil?

    respond_to do |format|
      if !@question.subjetive && @question.save
        sweep_question(@question)
        sweep_answer(@answer)

        current_user.on_activity(:close_question, current_group)
        if current_user != @answer.user
          @answer.user.update_reputation(:answer_picked_as_solution, current_group)
        end

        Jobs::Questions.async.on_question_solved(@question.id, @answer.id).commit!

        flash[:notice] = t(:flash_notice, :scope => "questions.solve")
        format.html { redirect_to question_path(@question) }
        format.json  { head :ok }
      else
        options = {:banned => false}
        options[:_id] = {:$ne => @question.answer_id} if @question.answer_id
        @answers = @question.answers.where(options).page(params["page"]).order_by(current_order)
        @answer = Answer.new

        format.html { render :action => "show" }
        format.json  { render :json => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  def unsolve
    @answer_id = @question.answer.id
    @answer_owner = @question.answer.user

    @question.answer = nil
    @question.accepted = false
    @question.answered_with = nil if @question.answered_with == @question.answer

    respond_to do |format|
      if @question.save
        sweep_question(@question)
        @question.answers.each do |answer|
          sweep_answer(answer)
        end
        flash[:notice] = t(:flash_notice, :scope => "questions.unsolve")
        current_user.on_activity(:reopen_question, current_group)
        if current_user != @answer_owner
          @answer_owner.update_reputation(:answer_unpicked_as_solution, current_group)
        end

        Jobs::Questions.async.on_question_unsolved(@question.id, @answer_id).commit!

        format.html { redirect_to question_path(@question) }
        format.json  { head :ok }
      else
        options = {:banned => false}
        options[:_id] = {:$ne => @question.answer_id} if @question.answer_id
        @answers = @question.answers.where(options).
                            order_by(current_order).
                            page(params["page"])
        @answer = Answer.new

        format.html { render :action => "show" }
        format.json  { render :json => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  def follow
    @question = current_group.questions.by_slug(params[:id])
    @question.add_follower(current_user)
    flash[:notice] = t("questions.watch.success")

    sweep_question(@question)

    respond_to do |format|
      format.html {redirect_to question_path(@question)}
      format.mobile { redirect_to question_path(@question, :format => :mobile) }
      format.js {
        render(:json => {:success => true,
                 :message => flash[:notice] }.to_json)
      }
      format.json { head :ok }
    end
  end

  def unfollow
    @question = current_group.questions.by_slug(params[:id])
    @question.remove_follower(current_user)

    flash[:notice] = t("questions.unwatch.success")

    sweep_question(@question)

    respond_to do |format|
      format.html {redirect_to question_path(@question)}
      format.mobile { redirect_to question_path(@question, :format => :mobile) }
      format.js {
        render(:json => {:success => true,
                 :message => flash[:notice] }.to_json)
      }
      format.json { head :ok }
    end
  end

  def move
    @question = current_group.questions.by_slug(params[:id])
    render
  end

  def move_to
    @group = Group.by_slug(params[:question][:group])
    @question = current_group.questions.by_slug(params[:id])

    if @group
      @question.group = @group

      if @question.save
        sweep_question(@question)
        @question.answers.each do |answer|
          sweep_answer(answer)
        end

        Answer.override({"question_id" => @question.id},
                        {"group_id" => @group.id})
      end
      flash[:notice] = t("questions.move_to.success", :group => @group.name)
      redirect_to question_path(@question)
    else
      flash[:error] = t("questions.move_to.group_dont_exists",
                        :group => params[:question][:group])
      render :move
    end
  end

  def retag_to
    @question = current_group.questions.by_slug(params[:id])

    @question.tags = params[:question][:tags]
    @question.updated_by = current_user
    @question.last_target = @question

    tags_changes = @question.changes["tags"]

    if @question.save
      sweep_question(@question)

      if (Time.now - @question.created_at) < 8.days
        @question.on_activity(true)
      end

      Jobs::Questions.async.on_retag_question(@question.id, current_user.id).commit!
      if tags_changes
        Jobs::Tags.async.question_retagged(@question.id, tags_changes.last, tags_changes.first, Time.now).commit!
      end

      if !@question.removed_tags.blank?
        flash[:warning] = I18n.t("questions.model.messages.tags_not_added",
                                 :tags => @question.removed_tags.join(", "),
                                 :reputation_required => @question.group.reputation_constrains["create_new_tags"])
      else
        flash[:notice] = t("questions.retag_to.success", :group => @question.group.name)
      end

      respond_to do |format|
        format.html {redirect_to question_path(@question)}
        format.js {
          render(:json => {:success => true,
                   :message => flash[:warning] || flash[:notice], :tags => @question.tags }.to_json)
        }
      end
    else
      flash[:error] = t("questions.retag_to.failure",
                        :group => params[:question][:group])

      respond_to do |format|
        format.html {render :retag}
        format.js {
          render(:json => {:success => false,
                   :message => flash[:error] }.to_json)
        }
      end
    end
  end

  def retag
    @question = current_group.questions.by_slug(params[:id])
    respond_to do |format|
      format.html {render}
      format.js {
        render(:json => {:success => true, :html => render_to_string(:partial => "questions/retag_form",
                                                   :member  => @question)}.to_json)
      }
    end
  end

  def twitter_share
    @question = current_group.questions.only([:title, :slug]).by_slug(params[:id])
    url = question_url(@question)
    text = "#{current_group.share.starts_with} #{@question.title} - #{url} #{current_group.share.ends_with}"

    Jobs::Users.async.post_to_twitter(current_user.id, text).commit!

    respond_to do |format|
      format.html {redirect_to url}
      format.js { render :json => { :ok => true }}
    end
  end

  def random
    conds = {:group_id => current_group.id}
    conds[:answered] = false if params[:unanswered] && params[:unanswered] != "0"
    @question = Question.random(conds)
    if !@question
      conds.delete(:answered)
      @question = Question.random(conds)
    end

    respond_to do |format|
      format.html {  redirect_to @question.nil? ?  questions_path : question_path(@question) }
      format.json { render :json => @question }
    end
  end

  def remove_attachment
    @question.attachments.delete(params[:attach_id])
    @question.save
    respond_to do |format|
      format.html { redirect_to edit_question_path(@question) }
      format.json { render :json => {:ok => true} }
    end
  end

  protected
  def check_permissions
    @question = current_group.questions.by_slug(params[:id])

    if @question.nil?
      redirect_to questions_path
    elsif !(current_user.can_modify?(@question) ||
           (params[:action] != 'destroy' && @question.can_be_deleted_by?(current_user)) ||
           current_user.owner_of?(@question.group)) # FIXME: refactor
      flash[:error] = t("global.permission_denied")
      redirect_to question_path(@question)
    end
  end

  def check_update_permissions
    @question = current_group.questions.by_slug(params[:id])
    allow_update = true
    unless @question.nil?
      if !current_user.can_modify?(@question)
        if @question.wiki
          if !current_user.can_edit_wiki_post_on?(@question.group)
            allow_update = false
            reputation = @question.group.reputation_constrains["edit_wiki_post"]
            flash[:error] = I18n.t("users.messages.errors.reputation_needed",
                                        :min_reputation => reputation,
                                        :action => I18n.t("users.actions.edit_wiki_post"))
          end
        else
          if !current_user.can_edit_others_posts_on?(@question.group)
            allow_update = false
            reputation = @question.group.reputation_constrains["edit_others_posts"]
            flash[:error] = I18n.t("users.messages.errors.reputation_needed",
                                        :min_reputation => reputation,
                                        :action => I18n.t("users.actions.edit_others_posts"))
          end
        end
        return redirect_to question_path(@question) if !allow_update
      end
    else
      return redirect_to questions_path
    end
  end

  def check_retag_permissions
    @question = current_group.questions.by_slug(params[:id])
    unless logged_in? && (current_user.can_retag_others_questions_on?(current_group) ||  current_user.can_modify?(@question))
      reputation = @question.group.reputation_constrains["retag_others_questions"]
      if !logged_in?
        flash[:error] = t("questions.show.unauthenticated_retag")
      else
        flash[:error] = I18n.t("users.messages.errors.reputation_needed",
                               :min_reputation => reputation,
                               :action => I18n.t("users.actions.retag_others_questions"))
      end
      response.should be_success
      respond_to do |format|
        format.html {redirect_to @question}
        format.js {
          render(:json => {:success => false,
                   :message => flash[:error] }.to_json)
        }
      end
    end
  end

  def check_create_permissions
    if logged_in? && !current_user.can_ask_on?(current_group)
      reputation = current_group.reputation_constrains["ask"]

      flash[:error] = I18n.t("users.messages.errors.reputation_needed",
                              :min_reputation => reputation,
                              :action => I18n.t("users.actions.ask"))

      respond_to do |format|
        format.html {redirect_to questions_path}
        format.js {
          render(:json => {:success => false,
                           :message => flash[:error] }.to_json)
        }
      end
    end
  end

  def set_active_tag
    @active_tag = "tag_#{params[:tags]}" if params[:tags]
    @active_tag
  end

  def check_age
    @question = current_group.questions.by_slug(params[:id])

    if @question.nil?
      @question = current_group.questions.where(:slugs.in => [params[:id]]).only(:_id, :slug).first
      if @question.present?
        head :moved_permanently, :location => question_url(@question)
        return
      elsif params[:id] =~ /^(\d+)/ && (@question = current_group.questions.where(:se_id => $1).only(:_id, :slug).first)
        head :moved_permanently, :location => question_url(@question)
        return
      else
        raise Error404
      end
    end

    return if session[:age_confirmed] || is_bot? || !@question.adult_content

    if !logged_in? || (Date.today.year.to_i - (current_user.birthday || Date.today).year.to_i) < 18
      render :template => "welcome/confirm_age"
    end
  end

  def create_draft!
    draft = Draft.create!(:question => @question)
    session[:draft] = draft.id
    login_required
  end
end
