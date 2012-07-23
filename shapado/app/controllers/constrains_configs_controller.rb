class ConstrainsConfigsController < ApplicationController
  before_filter :login_required
  before_filter :check_permissions
  layout "manage"

  def index
    @active_subtab = "constrains"
    if params[:mode].present?
      mode = ConstrainsConfig.find(params[:mode])
      if mode
        @group.reputation_constrains = mode.content
      end
    end
  end

  def new
    @active_subtab = "constrains"
    @constrains = ConstrainsConfig.new
  end

  def edit
    @active_subtab = "constrains"
    @constrains = current_group.constrains_configs.find(params[:id])
  end

  def create
    @active_subtab = "constrains"
    @constrains = ConstrainsConfig.new
    @constrains.safe_update(%w[name content], params[:constrains_config])
    @constrains.group = current_group
    @constrains.user = current_user

    if @constrains.save
      redirect_to constrains_configs_path
    else
      render :action => :new
    end
  end

  def update
    @constrains = current_group.constrains_configs.find_by_slug_or_id(params[:id])
    @constrains.safe_update(%w[name content], params[:constrains_config])
    if @constrains.save
      redirect_to constrains_configs_path
    else
      render :action => :edit
    end
  end

  def destroy
    @constrains = current_group.constrains_configs.find_by_slug_or_id(params[:id])
    @constrains.destroy
    redirect_to constrains_configs_path
  end

  def check_permissions
    @group = current_group

    if @group.nil?
      redirect_to groups_path
    elsif !current_user.owner_of?(@group) && !current_user.admin?
      flash[:error] = t("global.permission_denied")
      redirect_to domain_url(:custom => @group.domain)
    end
  end
end
