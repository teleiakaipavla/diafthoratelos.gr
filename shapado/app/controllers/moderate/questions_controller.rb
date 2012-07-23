class Moderate::QuestionsController < ApplicationController
  before_filter :login_required
  before_filter :moderator_required

  tabs :default => :questions
  subtabs :index => [[:retag, "created_at desc"]],
          :flagged => [[:flagged, "created_at desc"]]


  def index
    @active_subtab = "retag"
    options = {:banned => false}

    @questions = current_group.questions.where(options.merge(:tags => {:$size => 0})).
                                         page(params["page"])
  end

  def flagged
    options = {:banned => false}

    if params[:filter] == "banned"
       options[:banned] = true
    else
      options[:flags_count] = {:$gt => 0}
    end

    @questions = current_group.questions.where(options).
                            order_by("flags_count desc").
                            page(params["page"])
  end

  def to_close
    options = { :closed => false}

    @questions = current_group.questions.
                            where(options.merge(:close_requests_count.gt => 0)).
                            order_by("close_requests_count desc").
                            page(params["page"])
  end

  def to_open
    options = {:closed => true}

    @questions = current_group.questions.
                        where(options.merge(:open_requests_count.gt => 0)).
                        order_by("open_requests_count desc").
                        page(params["page"])
  end

  def manage
    case params[:commit]
    when "ban"
      Question.ban(params[:question_ids] || [], {:group_id => current_group.id})
    when "unban"
      Question.unban(params[:question_ids] || [], {:group_id => current_group.id})
    when "delete"
      Question.delete_all({:_id.in =>  params[:question_ids], :group_id => current_group.id})
    end

    respond_to do |format|
      format.html do
        redirect_to flagged_moderate_questions_path
      end
    end
  end

  def banning
    @question = current_group.questions.by_slug(params[:id])

    respond_to do |format|
      format.html

      format.js {
        html = render_to_string(:partial => "moderate/shared/banning_form", :locals => {:flaggeable => @question})
        render :json => {:html => html, :success => true}
      }
    end
  end

  def ban
    @question = current_group.questions.by_slug(params[:id])
    if params[:undo] == "1"
      @question.unban
    else
      @question.ban
    end

    sweep_question(@question)

    respond_to do |format|
      format.html {redirect_to question_path(@question)}

      format.js {
        render :json => {:success => true}
      }
    end
  end

  def closing
    @question = current_group.questions.by_slug(params[:id])

    respond_to do |format|
      format.html

      format.js {
        html = render_to_string(:partial => "closing_form", :locals => {:question => @question})
        render :json => {:html => html, :success => true}
      }
    end
  end

  def close
    @question = Question.by_slug(params[:id])
    @close_request = CloseRequest.new(params[:close_request])
    @close_request.user = current_user
    @close_request.closeable = @question

    if @question.reward && @question.reward.active
      flash[:error] = I18n.t('questions.close.failure')
    end

    respond_to do |format|
      if @close_request
        @question.closed = true
        @question.closed_at = Time.zone.now
        @question.close_reason_id = @close_request.id
        @question.save(:validate => false)

        sweep_question(@question)

        format.html { redirect_to question_path(@question) }
        format.json { head :ok }
      else
        flash[:error] = @close_request.errors.full_messages.join(", ")
        format.html { redirect_to question_path(@question) }
        format.json { render :json => @question.errors, :status => :unprocessable_entity  }
      end
    end
  end

  def opening
    @question = current_group.questions.by_slug(params[:id])

    respond_to do |format|
      format.html

      format.js {
        html = render_to_string(:partial => "opening_form", :locals => {:question => @question})
        render :json => {:html => html, :success => true}
      }
    end
  end

  def open
    @question = current_group.questions.by_slug(params[:id])

    @question.closed = false
    @question.close_reason_id = nil

    respond_to do |format|
      if @question.save
        sweep_question(@question)

        format.html { redirect_to question_path(@question) }
        format.json { head :ok }
      else
        flash[:error] = @question.errors.full_messages.join(", ")
        format.html { redirect_to question_path(@question) }
        format.json { render :json => @question.errors, :status => :unprocessable_entity  }
      end
    end
  end

  protected
  def current_scope
  end
end
