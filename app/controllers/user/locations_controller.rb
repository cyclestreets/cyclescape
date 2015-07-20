class User::LocationsController < ApplicationController
  def index
  end

  def new
    # Get the start location before creating a new blank one
    @start_location = current_user.start_location
    @location = current_user.locations.new
  end

  def create
    @location = current_user.locations.new permitted_params

    if @location.save
      set_flash_message :success
      redirect_to action: :index
    else
      @start_location = Geo::NOWHERE_IN_PARTICULAR
      render :new
    end
  end

  def edit
    @location = current_user.locations.find params[:id]
    @start_location = @location.location
  end

  def update
    @location = current_user.locations.find params[:id]

    if @location.update permitted_params
      set_flash_message :success
      redirect_to action: :index
    else
      render :edit
    end
  end

  def destroy
    if current_user.locations.find(params[:id]).destroy
      set_flash_message :success
    else
      set_flash_message :failure
    end
    redirect_to action: :index
  end

  def geometry
    @location = current_user.locations.find params[:id]
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(@location.loc_feature(thumbnail: view_context.image_path('map-icons/m-misc.png'))) }
    end
  end

  def combined_geometry
    multi = current_user.buffered_locations
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(multi) }
    end
  end

  protected

  def permitted_params
    params.require(:user_location).permit :category_id, :loc_json
  end
end
