class PlacesController < ApplicationController

  skip_before_filter :authorize, only: [:index]
  
  def index
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
      format.json do
        names = @places.collect { |pe| {value: pe.id, label: pe.name} }
        render :json => names
      end 
    end

  end
end
