
class MembersController < ApplicationController
  layout "manage"
  before_filter :login_required
  before_filter :check_permissions
  tabs :default => :members

  def index
    @group = current_group
    conditions = {}
    conditions = {:display_name => /^#{Regexp.escape(params[:q])}/} if params[:q]

    @members = current_group.memberships.where(conditions).order_by([%W[role asc], %W[reputation desc]]).page(params["page"])

    respond_to do |format|
      format.html
      format.js {
        html = render_to_string(:partial => "members/member", :collection  => @members)
        pagination = render_to_string(:partial => "shared/pagination", :object => @members,
                                      :format => "html")
        render :json => {:html => html, :pagination => pagination }
      }
    end
  end

  def update
    @member = @group.memberships.find(params[:id])
    if @member.id != current_user.id || current_user.admin?
      @member.role = params[:role]
      @member.save
    else
      flash[:error] = I18n.t('members.update.error', :login => @member.login)
    end
    redirect_to members_path
  end

  def destroy
    @member = @group.memberships.find(params[:id])
    if (@member.user_id != current_user.id)
      @member.leave(@group)
    else
      flash[:error] = "Sorry, you cannot destroy the **#{@member.user.login}'s** membership"
    end
    redirect_to members_path
  end

  protected
  def check_permissions
    @group = current_group

    if !current_user.owner_of?(@group)
      flash[:notice] = t("global.permission_denied")
      redirect_to domain_url(:custom => current_group.domain)
    end
  end
end
