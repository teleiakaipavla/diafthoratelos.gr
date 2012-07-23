class AnswersController < ApplicationController
  before_filter :login_required, :except => [:show, :create, :index, :history, :diff]
  before_filter :check_permissions, :only => [:destroy, :create]
  before_filter :check_update_permissions, :only => [:edit, :update, :revert]
  before_filter :track_pageview

  helper :votes

  def index
    exclude = [:votes, :_keywords]
    if params[:question_id]
      @question = current_group.questions.by_slug(params[:question_id])
      @answers = @question.answers.without(exclude).page(params["page"])
    else
      @answers = current_group.answers.without(exclude).page(params["page"])
    end

    respond_to do |format|
      format.html
      format.json { render :json => @answers }
    end
  end

  def history
    @answer = current_group.answers.find(params[:id])
    @question = @answer.question

    respond_to do |format|
      format.html
      format.json { render :json => @answer.versions.to_json }
    end
  end

  def diff
    @answer = current_group.answers.find(params[:id])
    @question = @answer.question
    @prev = params[:prev]
    @curr = params[:curr]
    if @prev.blank? || @curr.blank? || @prev == @curr
      flash[:error] = "please, select two versions"
      render :history
    else
      if @prev
        @prev = (@prev == "current" ? :current : @prev.to_i)
      end

      if @curr
        @curr = (@curr == "current" ? :current : @curr.to_i)
      end
    end
  end

  def revert
    @question = @answer.question
    @answer.load_version(params[:version].to_i)

    respond_to do |format|
      format.html
    end
  end

  def show
    @answer = current_group.answers.find!(params[:id])
    @question = @answer.question
    respond_to do |format|
      format.html
      format.mobile
      format.json  { render :json => @answer.to_json }
    end
  end

  def create
    @answer = Answer.new
    @answer.safe_update(%w[body wiki anonymous position], params[:answer])
    @answer.anonymous = params[:answer][:anonymous] if current_group.enable_anonymous
    @question = current_group.questions.by_slug(params[:question_id])

    @answer.question = @question
    @answer.group_id = @question.group_id

    # workaround, seems like mm default values are broken
    @answer.votes_count = 0
    @answer.votes_average = 0
    @answer.flags_count = 0

    @answer.user = current_user
    if !logged_in?
      if recaptcha_valid? && params[:user]
        @user = User.where(:email => params[:user][:email]).first
        if @user.present?
          if !@user.anonymous
            flash[:notice] = I18n.t('answers.create.annon_notice')
            return create_draft!
          else
            @answer.user = @user
          end
        elsif current_group.enable_anonymous
          @user = User.new(:anonymous => true, :login => "Anonymous")
          @user.safe_update(%w[name email website], params[:user])
          @user.login = @user.name if @user.name.present?
          @user.save!
          @answer.user = @user
        end
      elsif !AppConfig.recaptcha["activate"] || !current_group.enable_anonymous
        return create_draft!
      end
    end

    respond_to do |format|
      if (logged_in? || (recaptcha_valid? && @answer.user.valid?)) && @answer.save
        @question.add_contributor(current_user || @answer.user)
        link = question_answer_url(@question, @answer)

        Jobs::Activities.async.on_create_answer(@answer.id).commit!
        Jobs::Answers.async.on_create_answer(@question.id, @answer.id, link).commit!

        @question.answer_added!
        sweep_question(@question) # TODO move to magent
        html = ""
        if params[:facebook]
          html = render_to_string(:partial => "facebook/answer",
                                  :locals => {:answer => @answer, :question => @question})
        else
          html = render_to_string(:partial => "questions/answer",
                                  :locals => {:answer => @answer, :question => @question})
        end
        Magent::WebSocketChannel.push({id: "newanswer", object_id: @answer.id, name: @answer.body, channel_id: current_group.slug,
                                       owner_id: @answer.user.id, owner_name: @answer.user.login,
                                       question_id: @question.id, question_title: @question.title,
                                       html: html})
        flash[:notice] = t(:flash_notice, :scope => "answers.create")
        format.html{redirect_to question_path(@question)}
        format.mobile{
          redirect_to question_path(@question, :format => :mobile)
        }
        format.json { render :json => @answer.to_json(:except => %w[_keywords]) }
        format.js do
          render(:json => {:success => true, :message => flash[:notice],
                           :html => html, :question_id => @question.id}.to_json)
        end
      else
        @answer.errors.add(:captcha, "is invalid") if !logged_in? && !recaptcha_valid?

        errors = @answer.errors
        errors.merge!(@answer.user.errors) if @answer.user && @answer.user.anonymous && !@answer.user.valid?
        puts errors.full_messages

        format.html{
          flash[:error] = errors.full_messages
          redirect_to question_path(@question)
        }
        format.json { render :json => errors, :status => :unprocessable_entity }
        format.js {
          flash.now[:error] = errors.full_messages
          render :json => {:success => false, :message => flash.now[:error] }.to_json
        }
      end
    end
  end

  def edit
    @question = @answer.question
    respond_to do |format|
      format.html
      format.js {render :json => {:success => false, :html => render_to_string(:partial => "answers/edit_form",
                                   :locals => {:question => @question, :answer => @answer}) }.to_json }
    end
  end

  def update
    respond_to do |format|
      @question = @answer.question
      @answer.safe_update(%w[body wiki version_message], params[:answer])
      @answer.updated_by = current_user

      if @answer.valid? && @answer.save
        @question.add_contributor(current_user)

        sweep_answer(@answer)

        Question.update_last_target(@question.id, @answer)

        flash[:notice] = t(:flash_notice, :scope => "answers.update")

        Jobs::Activities.async.on_update_answer(@answer.id).commit!

        Magent::WebSocketChannel.push({id: "updateanswer", object_id: @answer.id, name: @answer.body, channel_id: current_group.slug,
                                       owner_id: @answer.user.id, owner_name: @answer.user.login,
                                       question_id: @question.id, question_title: @question.title,
                                       html: render_to_string(:partial => "questions/answer",
                                                              :locals => {:answer => @answer, :question => @question})})

        format.html { redirect_to(question_path(@answer.question, :anchor => "answer#{@answer.id}")) }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @answer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @question = @answer.question
    if @answer.user_id == current_user.id
      @answer.user.update_reputation(:delete_answer, current_group)
    end
    Jobs::Activities.async.on_destroy_answer(current_user.id, @answer.attributes).commit!
    sweep_answer(@answer)
    @answer.destroy
    @question.answer_removed!
    sweep_question(@question)

    respond_to do |format|
      format.html { redirect_to(question_path(@question)) }
      format.json { head :ok }
    end
  end

  def favorite
    @answer = Answer.find(params[:id])
    @answer.add_favorite!(current_user)
    link = question_answer_url(@answer.question, @answer)
    Jobs::Mailer.async.on_favorite_answer(@answer.id, current_user.id).commit!
    Jobs::Answers.async.on_favorite_answer(@answer.id, current_user.id, link).commit!

    respond_to do |format|
      flash[:notice] = t("favorites.create.success")
      format.html { redirect_to(question_path(@answer.question)) }
      format.mobile { redirect_to(question_path(@answer.question, :format => :mobile)) }
      format.json { head :ok }
      format.js {
        render(:json => {:success => true,
                 :message => flash[:notice], :increment => 1 }.to_json)
      }
    end
  end

  def unfavorite
    @answer = Answer.find(params[:id])
    @answer.remove_favorite!(current_user)

    flash[:notice] = t("unfavorites.create.success")
    respond_to do |format|
      format.html { redirect_to(question_path(@answer.question)) }
      format.mobile { redirect_to(question_path(@answer.question, :format => :mobile)) }
      format.js {
        render(:json => {:success => true,
                 :message => flash[:notice], :increment => -1 }.to_json)
      }
      format.json  { head :ok }
    end
  end

  protected
  def check_permissions
    if params[:id]
      @answer = current_group.answers.find(params[:id])
      if !@answer.nil?
        unless (current_user.can_modify?(@answer) || current_user.mod_of?(@answer.group))
          flash[:error] = t("global.permission_denied")
          redirect_to question_path(@answer.question)
        end
      else
        redirect_to questions_path
      end
    else
      if logged_in? && !current_user.can_answer_on?(current_group)
        reputation = current_group.reputation_constrains["answer"]

        flash[:error] = I18n.t("users.messages.errors.reputation_needed",
                              :min_reputation => reputation,
                              :action => I18n.t("users.actions.answer"))

        respond_to do |format|
          format.html {redirect_to questions_path}
          format.js {
            render(:json => {:success => false,
                           :message => flash[:error] }.to_json)
          }
        end
      end
    end
  end

  def check_update_permissions
    @answer = current_group.answers.find!(params[:id])

    allow_update = true
    unless @answer.nil?
      if !current_user.can_modify?(@answer)
        if @answer.wiki
          if !current_user.can_edit_wiki_post_on?(@answer.group)
            allow_update = false
            reputation = @answer.group.reputation_constrains["edit_wiki_post"]
            flash[:error] = I18n.t("users.messages.errors.reputation_needed",
                                        :min_reputation => reputation,
                                        :action => I18n.t("users.actions.edit_wiki_post"))
          end
        else
          if !current_user.can_edit_others_posts_on?(@answer.group)
            allow_update = false
            reputation = @answer.group.reputation_constrains["edit_others_posts"]
            flash[:error] = I18n.t("users.messages.errors.reputation_needed",
                                        :min_reputation => reputation,
                                        :action => I18n.t("users.actions.edit_others_posts"))
          end
        end
        return redirect_to question_path(@answer.question) if !allow_update
      end
    else
      return redirect_to questions_path
    end
  end

  def create_draft!
    draft = Draft.create(:answer => @answer)
    session[:draft] = draft.id
    login_required
  end
end
