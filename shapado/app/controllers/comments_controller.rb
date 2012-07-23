class CommentsController < ApplicationController
  before_filter :login_required, :except => [:index]
  before_filter :find_scope
  before_filter :check_permissions, :except => [:create, :index]

  def index
    @comments = @answer ? @answer.comments : @question.comments

    respond_to do |format|
      format.json { render :json => @comments }
    end
  end

  def create
    @comment = Comment.new
    @comment.body = params[:comment][:body]
    @comment.user = current_user

    current_scope << @comment

    if @comment.valid? && saved = @comment.save
      current_user.on_activity(:comment_question, current_group)

      current_user.membership_selector_for(current_group).first.increment(:comments_count => 1)
      link = question_url(@question)

      Jobs::Activities.async.on_comment(scope.id, scope.class.to_s, @comment.id, link).commit!
      Jobs::Mailer.async.on_new_comment(scope.id, scope.class.to_s, @comment.id).commit!
      if @answer
        sweep_answer(@answer)
      else
        sweep_question(@question)
      end
      if question_id = @comment.question_id
        Question.update_last_target(question_id, @comment)
      end

      html = render_to_string(:partial => "comments/comment",
                                      :object => @comment,
                                      :locals => {:source => params[:source], :mini => true})

      Magent::WebSocketChannel.push({:id => "newcomment",
                                  :object_id => @comment.id,
                                  :commentable_id => @comment.commentable.id,
                                  :name => @comment.body,
                                  :html => html,
                                  :channel_id => current_group.slug})

    end

    respond_to do |format|
      if saved
        format.html do
          flash[:notice] = t("comments.create.flash_notice")
          redirect_to params[:source]||question_path(:id => @question.slug)
        end
        format.json {render json: @comment.to_json, status: :created}
        format.js
      else
        format.html do
          redirect_to params[:source]||question_path(id: @question.slug)
        end
        format.json {render json: @comment.errors.to_json, status: :unprocessable_entity }
        format.js { render 'show_errors' }
      end
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    respond_to do |format|
      @comment = current_scope.find(params[:id])
      @comment.body = params[:comment][:body]
      if @comment.valid? && scope.save
        sweep_question(@question)
        sweep_answer(@answer) if @answer

        if question_id = @comment.question_id
          Question.update_last_target(question_id, @comment)
        end
        html = render_to_string(:partial => "comments/comment",
                                      :object => @comment,
                                      :locals => {
                                        :source => params[:source],
                                        :mini => true})
        Magent::WebSocketChannel.push({:id => "updatedcomment",
                                        :object_id => @comment.id,
                                        :commentable_id => @comment.commentable.id,
                                        :name => @comment.body,
                                        :html => html,
                                        :channel_id => current_group.slug})
        flash[:notice] = t(:flash_notice, :scope => "comments.update")
        format.html { redirect_to(params[:source]||question_path(:id => @question.slug)) }
        format.json { render :json => @comment.to_json, :status => :ok}
        format.js
      else
        flash[:error] = @comment.errors.full_messages.join(", ")
        format.html { render :action => "edit" }
        format.json { render :json => @comment.errors, :status => :unprocessable_entity }
        format.js { render 'show_errors' }
      end
    end
  end

  def destroy
    @scope = scope
    @comment = @scope.comments.find(params[:id])
    @comment.destroy
    sweep_question(@question)
    sweep_answer(@answer) if @answer
    if @comment.user.member_of? @comment.group
      @comment.user.membership_selector_for(@comment.group).first.decrement(:comments_count => 1)
    end

    respond_to do |format|
      format.html { redirect_to(params[:source]||question_path(:id => @question.slug)) }
      format.json { head :ok }
    end
  end

  protected
  def check_permissions
    @comment = current_scope.find(params[:id])
    valid = false
    if params[:action] == "destroy"
      valid = @comment.can_be_deleted_by?(current_user)
    else
      valid = current_user.can_modify?(@comment) || current_user.mod_of?(@comment.group)
    end

    if !valid
      respond_to do |format|
        format.html do
          flash[:error] = t("global.permission_denied")
          redirect_to params[:source] || questions_path
        end
        format.js { render :json => {:success => false, :message => t("global.permission_denied") } }
        format.json { render :json => {:message => t("global.permission_denied")}, :status => :unprocessable_entity }
      end
    end
  end

  def current_scope
    scope.comments
  end

  def find_scope
    @question = current_group.questions.by_slug(params[:question_id])
    @answer = @question.answers.find(params[:answer_id]) unless params[:answer_id].blank?
  end

  def scope
    unless @answer.nil?
      @answer
    else
      @question
    end
  end

  def full_scope
    unless @answer.nil?
      [@question, @answer]
    else
      [@question]
    end
  end
  helper_method :full_scope

end
