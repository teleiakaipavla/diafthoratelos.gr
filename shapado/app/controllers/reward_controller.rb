class RewardController < ApplicationController
  before_filter :login_required
  before_filter :find_question

  def start
    if @question.reward && @question.reward.active
      flash[:notice] =  I18n.t('rewards.start.active_notice')
      redirect_to question_path(@question)
      return
    end

    if Time.now - @question.created_at < 2.days
      flash[:notice] = I18n.t('rewards.start.wait_notice')
      redirect_to question_path(@question)
      return
    end

    @question.build_reward(params[:reward])

    config = current_user.config_for(current_group)

    if config.reputation < 75 || config.reputation-25 < @question.reward.reputation
      flash[:notice] =  I18n.t('rewards.start.reputation_notice')
      redirect_to question_path(@question)
      return
    end

    @question.reward.created_by = current_user
    @question.reward.started_at = Time.now
    @question.reward.ends_at = Time.now + 1.week

    if !@question.reward.valid?
      flash[:notice] = @question.reward.errors.full_messages.join(" ")
      redirect_to question_path(@question)
      return
    end

    @question.override(:reward => @question.reward.raw_attributes) # FIXME: buggy mongoid assocs

    current_user.update_reputation(:start_reward, current_group, -@question.reward.reputation)

    Jobs::Questions.async.on_start_reward(@question.id).commit!

    redirect_to question_path(@question)
  end

  def close
    if @question.reward.ends_at < Time.now
      flash[:notice] = "the reward has expired"
      @question.reward.reward(current_group)
      redirect_to question_path(@question)
      return
    end

    if (Time.now - @question.reward.started_at) < 1.day
      flash[:error] = I18n.t('rewards.close.error', :time => distance_of_time_in_words(Time.now, @question.reward.started_at+1.day))
      redirect_to question_path(@question)
      return
    end

    user_id = @question.reward.created_by_id

    @answer = @question.answers.where(:_id => params[:answer_id]).first
    @question.reward.reward(current_group, @answer)

    Jobs::Questions.async.on_close_reward(@question.id, @answer.id, user_id).commit!

    redirect_to question_path(@question)
  end

  protected
  def find_question
    @question = Question.minimal.by_slug(params[:id])
  end

  private
  include ActionView::Helpers::DateHelper
end
