class User::LocationsController < ApplicationController
  def index
  end

  def new
    # Get the start location before creating a new blank one
    @start_location = current_user.start_location
    @location = current_user.locations.new
  end

  def create
    @location = current_user.locations.new(params[:user_location])

    if @location.save
      set_flash_message(:success)
      redirect_to action: :index
    else
      @start_location = Geo::NOWHERE_IN_PARTICULAR
      render :new
    end
  end

  def edit
    @location = current_user.locations.find(params[:id])
    @start_location = @location.location
  end

  def update
    @location = current_user.locations.find(params[:id])

    if @location.update_attributes(params[:user_location])
      set_flash_message(:success)
      redirect_to action: :index
    else
      render :edit
    end
  end

  def destroy
    if current_user.locations.find(params[:id]).destroy
      set_flash_message(:success)
    else
      set_flash_message(:failure)
    end
    redirect_to action: :index
  end

  def geometry
    @location = current_user.locations.find(params[:id])
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(@location.location) }
    end
  end

  def combined_geometry
    multi = current_user.buffered_locations
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(multi) }
    end
  end
end
