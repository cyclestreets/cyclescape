class User::LocationsController < ApplicationController
  def index
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
end
