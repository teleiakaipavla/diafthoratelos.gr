class IncidentsController < ApplicationController

  skip_before_filter :authorize, only: [:new,
                                        :count_approved,
                                        :create,
                                        :index,
                                        :show,
                                        :search,
                                        :total_given,
                                        :approval_status,
                                        :parallel,
                                        :time_barchart]
  
  PAGE_SIZE = 20
  RSS_LIMIT = 50
  
  INCLUDE_INCIDENT_JSON_DESC = {
    :include => {
      :public_entity => {
        :only => :name,
        :include => { :category => {
            :only => :name }
        }
      },
      :place => { :only => [:name, :latitude, :longitude] }
    }
  }
  
  # GET /incidents
  # GET /incidents.json
  def index
    @incidents = Incident.order("updated_at desc")
    unless session[:user_id]
      @incidents =
        @incidents.where(:approval_status => Incident::APPROVED_STATUS)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.rss do
        @incidents = @incidents.limit(RSS_LIMIT)
        render :layout => false
      end
      format.json do
        render json: @incidents
      end
    end
  end

  # GET /incidents/parallel
  # GET /incidents/parallel.json
  def parallel
    @incidents = Incident.order("updated_at desc")
    unless session[:user_id]
      @incidents =
        @incidents.where(:approval_status => Incident::APPROVED_STATUS)
    end

    respond_to do |format|
      format.html
      format.json do
        render(:json => @incidents,
               :only => [:id,
                         :incident_date,
                         :money_asked,
                         :money_given,
                         :praise])
      end
    end
  end

  def time_barchart
    time_barchart_results = Incident.time_series
    respond_to do |format|
      format.html
      format.json do
        render(:json => time_barchart_results)
      end
    end
  end
  
  # GET /incidents/search
  # GET /incidents/search.json
  # GET /incidents/search.text
  def search
    @incidents = Incident.includes(:public_entity, :place,
                                   :public_entity => :category)
      .order("incidents.updated_at desc")

    @approval_status = params[:approval_status]
    if session[:user_id]
      if !(@approval_status.nil? || @approval_status.find {|v| v != ""}.nil?)
        @incidents =
          @incidents.where(:approval_status => @approval_status)
      end
    else
      @approval_status = Incident::APPROVED_STATUS
      @incidents =
        @incidents.where(:approval_status => @approval_status)
    end
    
    @praise = params[:praise]
    
    if @praise == "true"
      @incidents = @incidents.where(:praise => true)
    elsif @praise == "false"
      @incidents = @incidents.where(:praise => false)
    end

    @category_id = params[:category_id]
    if !(@category_id.nil? || @category_id == "")
      @incidents = @incidents.joins(:public_entity => :category)
        .where('category_id = ?', "#{params[:category_id]}")
    end

    @place_name_filter = params[:place_name_filter]
    if !(@place_name_filter.nil? || @place_name_filter == "")
      @incidents = @incidents.joins(:place)
        .where('places.name = ?', @place_name_filter)
    end

    if (params.has_key?(:public_entity_id))
      @incidents = @incidents.joins(:public_entity)
        .where('public_entity_id = ?', params[:public_entity_id])
    elsif (params.has_key?(:public_entity_name_appr_filter) &&
           params[:public_entity_name_appr_filter] != "" && 
           params[:public_entity_name_appr_filter] != t(:public_entity_name))
      capitalized_appr_name_filter =
        Unicode::upcase(params[:public_entity_name_appr_filter])
      @incidents = @incidents.joins(:public_entity)
        .where('public_entities.name like ?',
               "%#{capitalized_appr_name_filter}%")
    elsif (params.has_key?(:public_entity_name_filter) &&
        params[:public_entity_name_filter] != "" && 
        params[:public_entity_name_filter] != t(:public_entity_name))
      @incidents = @incidents.joins(:public_entity)
        .where('public_entities.name = ?',
               "#{params[:public_entity_name_filter]}")
    end

    @pageno = params[:pageno].to_i
    @pagesize = params[:pagesize].to_i
    if @pagesize <= 0
      @pagesize = PAGE_SIZE
    end
    if (@pageno > 0)
      @incidents = @incidents.limit(@pagesize)
        .offset((@pageno - 1) * @pagesize)
    end

    if params[:commit] == I18n.t(:text_search_results)
      self.request.format = "text"
    end
    
    respond_to do |format|
      format.html { render action: "index" }
      format.json { render :json => @incidents, 
        :include => INCLUDE_INCIDENT_JSON_DESC[:include] }
      format.text do
        self.response.headers["Content-Type"] ||= 'text/plain'
        self.response.headers["Content-Disposition"] =
          "attachment; filename=search.txt"
        self.response.headers['Last-Modified'] = Time.now.ctime.to_s
        self.response_body = Enumerator.new do |yielder|
          @incidents.each do |incident|
            yielder.yield incident.to_text + "\n"
          end
        end
      end
    end
  end
  
  # GET /incidents/1
  # GET /incidents/1.json
  def show
    incident_query = Incident.where(:id => params[:id])
    
    unless session[:user_id]
      incident_query =
        incident_query.where(:approval_status => Incident::APPROVED_STATUS)
    end

    @incident = incident_query.first
    
    respond_to do |format|
      format.html do # show.html.erb
        if @incident.nil?
          render nothing: true
        else
          render action: "show"
        end
      end
      format.json { render json: @incident,
        :include => INCLUDE_INCIDENT_JSON_DESC[:include] }
    end
  end

  # GET /incidents/new
  # GET /incidents/new.json
  def new
    @incident = Incident.new
    @place = Place.new
    
    if params[:praise]
      @incident.praise = params[:praise]
    end

    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.json { render json: @incident }
    end
  end

  # GET /incidents/1/edit
  def edit
    @incident = Incident.find(params[:id])
    @category_id =
      @incident.public_entity.nil? ? nil : @incident.public_entity.id
    @place = @incident.place || Place.new()
    @praise = @incident.praise.to_s
  end

  # POST /incidents
  # POST /incidents.json
  def create
    @incident = Incident.new(params[:incident])

    if !@incident.copy_public_entity_id_from!(params[:public_entity_name])
      @incident.set_public_entity_name_comment(params[:public_entity_name])
    end
    @category_id = params[:category_id]
    @place = @incident.copy_or_create_place_from!(params[:place])

    respond_to do |format|
      if @place.errors.empty? && @incident.save
        if session[:used_id]
          format.html { redirect_to @incident,
            notice: 'Incident was successfully created.' }
        else
          format.html { redirect_to approval_status_incident_path(@incident) }
        end
        format.json { render json: @incident, status: :created,
          location: @incident }
      else
        format.html { render action: "new" }
        format.json { render json: @incident.errors,
          status: :unprocessable_entity }
      end
    end
  end

  # PUT /incidents/1
  # PUT /incidents/1.json
  def update
    @incident = Incident.find(params[:id])

    @incident.copy_public_entity_id_from!(params[:public_entity_name])
    @category_id = params[:category_id]
    @place = @incident.copy_or_create_place_from!(params[:place])
    
    respond_to do |format|
      if @incident.update_attributes(params[:incident])
        format.html { redirect_to @incident, notice: 'Incident was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @incident.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /incidents/1
  # DELETE /incidents/1.json
  def destroy
    @incident = Incident.find(params[:id])
    @incident.destroy

    respond_to do |format|
      format.html { redirect_to incidents_url }
      format.json { head :no_content }
    end
  end

  # GET /incidents/total_given
  def total_given
    sum = Incident.where(:approval_status => Incident::APPROVED_STATUS)
      .sum("money_given")
        
    respond_to do |format|     
      format.json { render json: sum}
    end
  end

  def approval_status
    @incident = Incident.find(params[:id])
    respond_to do |format|
      format.html # approva_status.html.erb
    end
  end
  
  def count_approved
    count_approved =
      Incident.where(:approval_status => Incident::APPROVED_STATUS)
    
    @praise = params[:praise]
    
    if @praise == "true"
      count_approved = count_approved.where(:praise => true)
    elsif @praise == "false"
      count_approved = count_approved.where(:praise => false)
    end

   count_approved = count_approved.count
    
    respond_to do |format|     
      format.json { render json: count_approved }
    end    
  end
  
end
