class PublicEntitiesController < ApplicationController

  skip_before_filter :authorize, only: [:search]
  
  # GET /public_entities
  # GET /public_entities.json
  def index
    @public_entities = PublicEntity.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @public_entities }
    end
  end

  # GET /public_entities/search
  def search
    
    @public_entities = nil
    if params.has_key?(:term) && params[:term] != ""
      if params.has_key?(:exact) && params[:exact] == "1"
        @public_entities = PublicEntity.where('name = ?', "#{params[:term]}")
      else
        @public_entities = PublicEntity.where('name like ?', "%#{params[:term]}%")
      end
    else
      @public_entities = PublicEntity.all
    end

    if params.has_key?(:category_id) && params[:category_id] != ""
      category_id = params[:category_id]
      @public_entities = @public_entities.where(:category_id => category_id)
    end
    
    respond_to do |format|
      format.html { render "index" }
      format.json do
        if params[:form] == "short"
          names = @public_entities.collect do |pe|
            { value: pe.id, label: pe.name }
          end
          render :json => names
        else
          render :json => @public_entities
        end
      end 
    end
  end
  
  # GET /public_entities/1
  # GET /public_entities/1.json
  def show
    @public_entity = PublicEntity.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @public_entity }
    end
  end

  # GET /public_entities/new
  # GET /public_entities/new.json
  def new
    @public_entity = PublicEntity.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @public_entity }
    end
  end

  # GET /public_entities/1/edit
  def edit
    @public_entity = PublicEntity.find(params[:id])
  end

  # POST /public_entities
  # POST /public_entities.json
  def create
    @public_entity = PublicEntity.new(params[:public_entity])

    respond_to do |format|
      if @public_entity.save
        format.html { redirect_to @public_entity, notice: 'Public entity was successfully created.' }
        format.json { render json: @public_entity, status: :created, location: @public_entity }
      else
        format.html { render action: "new" }
        format.json { render json: @public_entity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /public_entities/1
  # PUT /public_entities/1.json
  def update
    @public_entity = PublicEntity.find(params[:id])

    respond_to do |format|
      if @public_entity.update_attributes(params[:public_entity])
        format.html { redirect_to @public_entity, notice: 'Public entity was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @public_entity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /public_entities/1
  # DELETE /public_entities/1.json
  def destroy
    @public_entity = PublicEntity.find(params[:id])
    @public_entity.destroy

    respond_to do |format|
      format.html { redirect_to public_entities_url }
      format.json { head :no_content }
    end
  end
end
