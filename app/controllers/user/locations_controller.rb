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
end
