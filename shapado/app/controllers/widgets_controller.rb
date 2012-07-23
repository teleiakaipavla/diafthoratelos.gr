class WidgetsController < ApplicationController
  before_filter :login_required, :except => :embedded
  before_filter :check_permissions, :except => :embedded
  layout "manage"
  tabs :default => :widgets

  subtabs :widgets => [[:mainlist, "mainlist"],
                       [:question, "question"],
                       [:external, "external"]]

  # GET /widgets
  # GET /widgets.json
  def index
    @active_subtab ||= "mainlist"

    @widget = Widget.new
    @widget_list = @group.send(:"#{@active_subtab}_widgets")
  end

  def edit
    @widget_list = @group.send(:"#{params[:tab]}_widgets")
    @widget = @widget_list.send(params[:position]).find(params[:id])
    respond_to do |format|
      format.html
      format.js do
        render :json => {
          :html => render_to_string(:partial => "widgets/form",
                                    :locals => {:widget => @widget,
                                               :position => params[:position],
                                               :tab => params[:tab]}),
          :success => true
        }
      end
    end
  end

  # POST /widgets
  # POST /widgets.json
  def create
    if Widget.types(params[:tab],current_group.has_custom_ads).include?(params[:widget][:_type])
      @widget = params[:widget][:_type].constantize.new
    end

    @widget_list = @group.send(:"#{params[:tab]}_widgets")
    @widget_list.send(:"#{params[:widget][:position]}") << @widget

    respond_to do |format|
      if @widget.save
        sweep_widgets
        flash[:notice] = I18n.t('widgets.create.notice')
        format.html { redirect_to widgets_path(:tab => params[:tab], :anchor => @widget.id) }
        format.json  { render :json => @widget.to_json, :status => :created, :location => widget_path(:id => @widget.id) }
      else
        format.html { render :action => "index" }
        format.json  { render :json => @widget.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /widgets
  # PUT /widgets.json
  def update
    @widget_list = @group.send(:"#{params[:tab]}_widgets")

    @widget = nil
    if WidgetList::POSITIONS.include? params[:position]
      @widget = @widget_list.send(params[:position]).find(params[:id])
      @widget.update_settings(params)
    end

    respond_to do |format|
      if @widget.valid? && @widget.save
        sweep_widgets
        flash[:notice] = I18n.t('widgets.update.notice')
        format.html { redirect_to widgets_path(:tab => params[:tab], :anchor => @widget.id) }
        format.json  { render :json => @widget.to_json, :status => :updated, :location => widget_path(:id => @widget.id) }
      else
        format.html { render :action => "index" }
        format.json  { render :json => @widget.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /ads/1
  # DELETE /ads/1.json
  def destroy
    widget_list = @group.send(:"#{params[:tab]}_widgets")

  if WidgetList::POSITIONS.include? params[:position]
    @widget = widget_list.send(params[:position]).find(params[:id])
    @widget.destroy

    sweep_widgets
  end

    respond_to do |format|
      format.html { redirect_to(widgets_url) }
      format.json { head :ok }
      format.js { render :nothing => true }
    end
  end

  def move
    widget_list = @group.send(:"#{params[:tab]}_widgets")

    if WidgetList::POSITIONS.include? params[:position]
      widget_list.move_to(params[:move_to], params[:id], params[:position])
      sweep_widgets
    end

    redirect_to widgets_path(:tab => params[:tab])
  end

  def embedded
    @widget = current_group.external_widgets.sidebar.find(params[:id])
    render :layout => false
  end

  private
  def check_permissions
    @group = current_group

    if @group.nil?
      redirect_to groups_path
    elsif !current_user.owner_of?(@group)
      flash[:error] = t("global.permission_denied")
      redirect_to root_path
    end
  end
end
