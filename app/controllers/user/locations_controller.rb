class User::LocationsController < ApplicationController
  def index
    @start_location = RGeo::Geos::Factory.create({has_z_coordinate: true}).point(0.1477639423685, 52.27332049515, 14)
  end

  def new
    @location = current_user.locations.new
    @start_location = RGeo::Geos::Factory.create({has_z_coordinate: true}).point(0.1477639423685, 52.27332049515, 14)
  end

  def create
    @location = current_user.locations.new(params[:user_location])

    if @location.save
      redirect_to action: :index
    else
      @start_location = RGeo::Geos::Factory.create({has_z_coordinate: true}).point(0.1477639423685, 52.27332049515, 14)
      render :new
    end
  end

  def edit
    @location = current_user.locations.find(params[:id])
    @start_location = RGeo::Geos::Factory.create({has_z_coordinate: true}).point(0.1477639423685, 52.27332049515, 10)
  end

  def update
    @location = current_user.locations.find(params[:id])

    if @location.update_attributes(params[:user_location])
      flash.notice = t(".user.locations.update.location_updated")
      redirect_to action: :index
    else
      render :edit
    end
  end

  def destroy
    if current_user.locations.find(params[:id]).destroy
      flash.notice = t(".user.locations.destroy.success")
    else
      flash.notice = t(".user.locations.destroy.failure")
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
    multi = current_user.buffered_user_locations
    respond_to do |format|
      format.json { render json: RGeo::GeoJSON.encode(multi) }
    end
  end
end
