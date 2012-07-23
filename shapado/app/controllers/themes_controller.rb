class ThemesController < ApplicationController
  layout "manage"
  before_filter :login_required
  before_filter :check_permissions

  # GET /themes
  # GET /themes.json
  def index

    conditions = {:_id => {:$ne => current_group.current_theme_id}}
    @themes = current_group.themes.where(conditions).page(params["page"])

    if params[:tab] == "all"
      conditions[:$or] = [{:community => true}, {:group_id => current_group.id}]

      @themes = Theme.where(conditions).page(params["page"])
    end


    respond_to do |format|
      format.html # index.html.haml
      format.json  { render :json => @themes }
    end
  end

  # GET /themes/1
  # GET /themes/1.json
  def show
    @theme = Theme.find(params[:id])

    respond_to do |format|
      format.html # show.html.haml
      format.json  { render :json => @theme }
    end
  end

  # GET /themes/new
  # GET /themes/new.json
  def new
    @theme = Theme.new

    respond_to do |format|
      format.html # new.html.haml
      format.json  { render :json => @theme }
    end
  end

  # GET /themes/1/edit
  def edit
    conditions = {}
    if params[:tab] == "community"
      conditions[:community] = true
    else
      conditions[:group_id] = current_group.id
    end

    @theme = Theme.where(conditions).find(params[:id])
  end

  # POST /themes
  # POST /themes.json
  def create
    if !current_group.shapado_version.has_custom_js?
      params[:theme].delete(:javascript)
    end
    if !current_group.shapado_version.has_custom_themes?
      params[:theme].delete(:javascript)
      params[:theme].delete(:layout_html)
      params[:theme].delete(:questions_index_html)
      params[:theme].delete(:questions_show_html)
    end
    @theme = Theme.new(params[:theme])
    @theme.group = current_group
    @theme.ready = false
    @theme.set_has_js(params[:theme][:javascript])

    respond_to do |format|
      if @theme.save
        Jobs::Themes.async.generate_stylesheet(@theme.id).commit!(4)
        format.html { redirect_to(@theme, :notice => 'Theme was successfully created.') }
        format.json { render :json => @theme, :status => :created, :location => @theme }
      else
        format.html { render :action => "new" }
        format.json { render :json => @theme.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /themes/1
  # PUT /themes/1.json
  def update
    if !current_group.shapado_version.has_custom_js?
      params[:theme].delete(:javascript)
    end
    if !current_group.shapado_version.has_custom_themes?
      params[:theme].delete(:javascript)
      params[:theme].delete(:layout_html)
      params[:theme].delete(:questions_index_html)
      params[:theme].delete(:questions_show_html)
    end
    @theme = Theme.find(params[:id])
    @theme.ready = false
    @theme.set_has_js(params[:theme][:javascript])

    respond_to do |format|
      if @theme.update_attributes(params[:theme])
        Jobs::Themes.async.generate_stylesheet(@theme.id).commit!(4)
        format.html { redirect_to(edit_theme_path(@theme), :notice => 'Theme was successfully updated.') }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @theme.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /themes/1
  # DELETE /themes/1.json
  def destroy
    @theme = current_group.themes.find(params[:id])
    @theme.destroy
    respond_to do |format|
      format.html { redirect_to(themes_url) }
      format.json  { head :ok }
    end
  end

  def remove_bg_image
    @theme = Theme.find(params[:id])
    @theme.delete_file("bg_image")
    @theme.save
    Jobs::Themes.async.generate_stylesheet(@theme.id).commit!(4)

    respond_to do |format|
      format.html { redirect_to edit_theme_path(@theme) }
      format.json { render :json => {:ok => true} }
    end
  end

  def apply
    @theme = Theme.find(params[:id])
    current_group.override(:current_theme_id => @theme.id)
    redirect_to theme_url(@theme)
  end

  def ready
    @theme = Theme.find(params[:id])
    respond_to do |format|
      result = {:ready => @theme.ready}
      if @theme.ready
        if !@theme.last_error.blank?
          result[:last_error] = @theme.last_error
        else
          result[:message] = t("themes.ready.success")
        end
      end
      format.js{render :json => result}
    end
  end

  def download
    @theme = Theme.find(params[:id])

    temp_file = "#{Dir.tmpdir}/theme-#{request.remote_ip}-#{Time.now.to_i}-#{rand(100)}-#{rand(100)}.zip"

    Zip::ZipFile.open(temp_file, Zip::ZipFile::CREATE) do |zipfile|
      zipfile.get_output_stream("theme.yml") do |f|
        atts = Hash[@theme.raw_attributes]
        %w[_id file_list group_id has_js last_error ready].each {|e| atts.delete(e) }
        f.puts atts.to_yaml
      end

      zipfile.mkdir("layout")
      zipfile.get_output_stream("layout/layout.html") do |f|
        f.puts @theme.layout_html.read
      end if @theme.has_layout_html?

      zipfile.get_output_stream("layout/main.scss") do |f|
        f.puts @theme.stylesheet.read
      end if @theme.has_stylesheet?

      zipfile.get_output_stream("layout/main.js") do |f|
        f.puts @theme.javascript.read
      end if @theme.has_javascript?

      zipfile.get_output_stream("layout/background.#{@theme.bg_image.extension}") do |f|
        f.puts @theme.bg_image.read
      end if @theme.has_bg_image?

      zipfile.mkdir("questions")
      zipfile.get_output_stream("questions/index.html") do |f|
        f.puts @theme.questions_index_html.read
      end if @theme.has_questions_index_html?

      zipfile.get_output_stream("questions/show.html") do |f|
        f.puts @theme.questions_show_html.read
      end if @theme.has_questions_show_html?
    end

    send_file temp_file, :filename => @theme.name.parameterize("-")+".zip",
                      :type => 'application/zip',
                      :disposition => "attachment"
    FileUtils.rm_f(temp_file)
  end

  def import
    file = params[:theme_file]
    @theme = Theme.new(:group => current_group)

    Zip::ZipInputStream::open(file.path) do |io|
      while entry = io.get_next_entry
        content = io.read
        next if content.strip.empty?

        case entry.name
        when 'theme.yml'
          atts = %w[bg_color brand_color community created_at custom_css description
                    fg_color fluid name updated_at version view_bg_color]
          data = YAML.load(content)
          data['name'] = "#{data['name']} #{Time.now.strftime("%F")}"
          @theme.safe_update(atts, data)
        when 'layout/layout.html'
          @theme.layout_html = content
        when 'layout/main.scss'
          @theme.stylesheet = content
        when 'layout/main.js'
          @theme.javascript = content
        when /layout\/background\.(.+)/
          @theme.bg_image = content
        when 'questions/index.html'
          @theme.questions_index_html = content
        when 'questions/show.html'
          @theme.questions_show_html = content
        end
      end
    end

    if @theme.save
      redirect_to theme_path(@theme)
    else
      redirect_to themes_path
    end
  end

  protected
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
