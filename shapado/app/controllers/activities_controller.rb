class ActivitiesController < ApplicationController
  tabs :default => :activities
  before_filter :track_pageview
  subtabs :index => [[:all, [:created_at, :desc]],
                    [:questions, [:created_at, :desc]],
                    [:answers, [:created_at, :desc]],
                    [:pages, [:created_at, :desc]],
                    [:users, [:created_at, :desc]]],
          :default => :all
  def index
    conds = {}
    if params[:context] == "by_me" && logged_in?
      conds[:user_id] = current_user.id
    end

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

    @active_subtab ||= params[:tab] || "all"
    @activities = current_group.activities.where(conds).order(:created_at.desc).
                                           page(params[:page].to_i)

    respond_to do |format|
      format.html
      format.json { render :json => @activities }
    end
  end

  def show
    @activity = Activity.find(params[:id])

    if params[:notif]
      render :partial => "notifications/notification_item", :layout => false, :locals => {:activity => @activity}
    else
      @activity.to_html(self)
    end

  end

end
