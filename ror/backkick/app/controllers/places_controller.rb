class PlacesController < ApplicationController

  skip_before_filter :authorize, only: [:index, :search]
  
  def index
    @places = Place.all

    respond_to do |format|
      format.html { render "index" }
      format.json { render :json => @places }
    end 
  end

  def search
    @places = nil
    if params[:term]
      if params[:exact]
        @places = Place.where('name = ?', "#{params[:term]}")
      else
        @places = Place.where('name like ?', "%#{params[:term]}%")
      end
    else
      @places = Place.all
    end

    respond_to do |format|
      format.html { render "index" }
      format.json { render :json => @places }
    end 
  end
  
end
